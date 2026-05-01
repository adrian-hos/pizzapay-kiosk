# This Python file uses the following encoding: utf-8

from bip_utils import Bip84, Bip84Coins, Bip44Changes
from urllib.parse import urlencode
from datetime import date
from pathlib import Path
import concurrent.futures
import requests
import json

class Wallet:
    def __init__(self, vpub, cache_path):
        self.vpub = vpub
        self.cache_path = Path(cache_path)

        self.bip84_ctx = Bip84.FromExtendedKey(self.vpub, Bip84Coins.BITCOIN_TESTNET)
        self.max_unused_address_count = 20

        self.last_used_address_index = None
        self.current_address_index = None
        self._btc_to_leu = None

        if self.cache_path.is_file():
            self.read_cache()
            self.fetch_btc_to_leu(False)
            self.fetch_last_address(self.last_used_address_index)
        else:
            self.fetch_btc_to_leu(False)
            self.fetch_last_address()

        '''
        if self.cache_path.is_file():
            self.read_cache()
            self.fetch_btc_to_leu()
            self.last_used_address_index = 4
            self.current_address_index = 5
        '''

        self.transaction_amount = None
        self.transaction_address = None
        self._is_transaction_paid = False
        self.transaction_txid = None

    def create_transaction(self, amount, order_code):
        self.transaction_address = self.get_address_from_index(self.current_address_index)
        self.transaction_amount = amount
        params = {
            "amount": f"{(self.transaction_amount / 1e8):.8f}",
            "label": f"PizzaPay Order No. {order_code}",
            "message": f"PizzaPay Order No. {order_code}"
        }

        uri = f"bitcoin:{self.transaction_address}?{urlencode(params)}"

        print(f"Created transaction with URI: {uri}")

        return self.transaction_address, uri

    @property
    def is_transaction_paid(self):
        if self._is_transaction_paid:
            return self._is_transaction_paid

        print(f"Checking if we got payment on address {self.transaction_address}")

        for _ in range(10):
            for __ in range(2):
                url = "https://blockstream.info/testnet/api/address/{}/txs/mempool"

                has_txid, self.transaction_txid, amount = self.get_last_txid(self.transaction_address, url)

                if has_txid != None:
                    break

            if has_txid != None:
                break

            for __ in range(2):
                url = "https://mempool.space/testnet/api/address/{}/txs/mempool"

                has_txid, self.transaction_txid, amount = self.get_last_txid(self.transaction_address, url)

                if has_txid != None:
                    break

            if has_txid != None:
                break

        if has_txid == None:
            raise Exception("Couldn't fetch txid")
        elif has_txid:
            print(f"Got txid {self.transaction_txid} with amount {amount / 100000000:.7f}")
            if amount >= self.transaction_amount:
                print("Paid!")
                self._is_transaction_paid = True
            return self._is_transaction_paid
        else:
            return False

    def get_last_txid(self, address, url):
        url = url.format(address)

        try:
            response = requests.get(url, timeout=3)
        except:
            return None, None, None


        if response.status_code == 200:
            data = response.json()

            if data:
                for tx in data[0]["vout"]:
                    if tx["scriptpubkey_address"] == address:
                        return True, data[0]["txid"], tx["value"]
            else:
                return False, None, None
        else:
            return None, None, None

    def end_transaction(self):
        if self._is_transaction_paid:
            self.last_used_address_index += 1
            self.current_address_index += 1
            self.save_cache()

        self.transaction_amount = None
        self.transaction_address = None
        self._is_transaction_paid = False
        self.transaction_txid = None

    # Address generation
    def get_address_from_index(self, address_index):
        return str(self.bip84_ctx.Change(Bip44Changes.CHAIN_EXT).AddressIndex(address_index).PublicKey().ToAddress())

    def fetch_last_address(self, begin = 0, save = True):
        fetch_range = 5

        unused_addresses = 0
        begin_at = begin
        end_at = begin + fetch_range

        while unused_addresses < self.max_unused_address_count:
            with concurrent.futures.ThreadPoolExecutor() as executor:
                futures = [executor.submit(self.is_address_used_thread, address_index) for address_index in range(begin_at, end_at)]
                for future in concurrent.futures.as_completed(futures):

                    address_index, is_used = future.result()

                    if is_used:
                        unused_addresses = 0

                        if self.last_used_address_index == None or address_index > self.last_used_address_index:
                            self.last_used_address_index = address_index
                    else:
                        unused_addresses += 1

            begin_at += fetch_range
            end_at += fetch_range

        self.current_address_index = self.last_used_address_index + 1

        print(f"Fetched last used address index: {self.last_used_address_index}")
        print(f"Current address index set to: {self.current_address_index}")

        if save:
            self.save_cache()

    def is_address_used(self, address, url):
        url = url + "/" + address
        try:
            response = requests.get(url, timeout=3)
        except:
            return None

        if response.status_code == 200:
            data = response.json()

            if data["mempool_stats"]["funded_txo_count"] == 0 and data["chain_stats"]["funded_txo_count"] == 0:
                return False
            else:
                return True
        else:
            return None

    def is_address_used_thread(self, address_index):
        address = self.get_address_from_index(address_index)

        for _ in range(10):
            for __ in range(2):
                is_used = self.is_address_used(address, "https://blockstream.info/testnet/api/address")

                if is_used != None:
                    return address_index, is_used

            for __ in range(2):
                is_used = self.is_address_used(address, "https://mempool.space/testnet/api/address")

                if is_used != None:
                    return address_index, is_used

        raise Exception("Couldn't fetch balance")

    # Fetch bitcoin price
    def fetch_btc_to_leu(self, save = True):
        if self._btc_to_leu == None or date.today().isoformat() != self._btc_to_leu[1]:
            url = "https://api.coingecko.com/api/v3/simple/price"
            params = {'ids': 'bitcoin', 'vs_currencies': 'ron'}

            for _ in range(10):
                try:
                    response = requests.get(url, params=params, timeout=4)
                except:
                    pass
                else:
                    if response.status_code == 200:
                        data = response.json()

                        self._btc_to_leu = tuple([int(data['bitcoin']['ron']), date.today().isoformat()])

                        break
            print(f"Fetched BTC to LEU: {self._btc_to_leu[0]}")

            if save:
                self.save_cache()

        else:
            print(f"Used cached BTC to LEU: {self._btc_to_leu[0]}")


    @property
    def btc_to_leu(self):
        return self._btc_to_leu[0]

    # File handling
    def read_cache(self):
        with open(self.cache_path, "r") as json_file:
            data = json.load(json_file)

        self.last_used_address_index = data["last_used_address"]
        self._btc_to_leu = data["btc_to_leu"]

    def save_cache(self):
        data = dict()

        data["last_used_address"] = self.last_used_address_index

        data["btc_to_leu"] = self._btc_to_leu

        with open(self.cache_path, "w") as json_file:
            json.dump(data, json_file, indent=4)
