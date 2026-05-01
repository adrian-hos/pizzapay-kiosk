<p align="center">
  <img src="https://github.com/adrian-hos/pizzapay-kiosk/blob/main/image/pizza.png" width="200">
</p>

# PizzaPay Kiosk

**PizzaPay Kiosk** este un sistem interactiv de tip self-service conceput pentru a simplifica procesul de comandă a pizzei într-un restaurant fizic. Aplicația permite utilizatorilor să navigheze ușor prin meniul disponibil, să își personalizeze complet comanda prin adăugarea de topping-uri și să finalizeze plata utilizând Bitcoin. Sistemul este dezvoltat în Python și utilizează o interfață grafică modernă bazată pe Qt/QML, oferind o experiență intuitivă și rapidă.

Prin automatizarea procesului de comandă și integrarea plăților cu criptomonede, PizzaPay Kiosk reduce timpul de așteptare și elimină erorile umane care pot apărea în interacțiunea clasică cu personalul. În plus, folosirea adreselor Bitcoin unice pentru fiecare tranzacție asigură un nivel ridicat de securitate și confidențialitate, oferind astfel o soluție modernă și eficientă pentru industria HoReCa.

## Tehnologii utilizate

Pentru realizarea PizzaPay Kiosk, au fost utilizate următoarele instrumente și tehnologii:

* **Python**, ca limbaj principal de programare pentru backend și logică aplicației  
* **Qt 6**, **QML** și `PySide6` pentru dezvoltarea interfeței grafice interactive și integrarea cu backend-ul  
* **MariaDB** și `mysql-connector-python` pentru gestionarea bazei de date (produse, comenzi, tranzacții)  
* Biblioteca `qrcode` și modulele `base64` și `io` pentru generarea și procesarea codurilor QR  
* `requests` pentru realizarea apelurilor către API-uri externe necesare verificării tranzacțiilor Bitcoin  
* `bip-utils` pentru generarea adreselor Bitcoin pe baza unui master public key  
* `concurrent.futures` pentru execuția paralelă a request-urilor API și optimizarea performanței  
* API-uri publice precum Blockstream și Mempool pentru verificarea tranzacțiilor în rețeaua Bitcoin Testnet 
