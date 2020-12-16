# Despliegue de Magento utilizando Docker en Linux

## Requerimientos
- Magento 2.3.6, se puede desde *https://magento.com/tech-resources/download*.
- Curl, generalmente viene preinstalado con Linux, se puede validar con el siguiente comando el cual deberá mostrar la versión.
  ```
  $ curl -V
  curl 7.68.0 (x86_64-pc-linux-gnu) libcurl/7.68.0 OpenSSL/1.1.1f zlib/1.2.11 brotli/1.0.7 libidn2/2.2.0 libpsl/0.21.0 (+libidn2/2.2.0) libssh/0.9.3/openssl/zlib nghttp2/1.40.0 librtmp/2.3
  Release-Date: 2020-01-08
  Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtmp rtsp scp sftp smb smbs smtp smtps telnet tftp 
  Features: AsynchDNS brotli GSS-API HTTP2 HTTPS-proxy IDN IPv6 Kerberos Largefile libz NTLM NTLM_WB PSL SPNEGO SSL TLS-SRP UnixSockets
  ```
  - Sino esta instalado se puede instalar con:
    - Ubuntu o distribuciones basadas en Debian
      ```
      sudo apt install curl
      ```
    - CentOS/Fedora
      ```
      yum install curl
      ```
- Docker, se puede instalar con este comando, sino se pueden usar otras opciones existentes en *https://docs.docker.com/engine/install/* según la distribución.
  ```
  $ curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
  ```
- MySQL, si desa instalar con Docker usar este comando, sino se instala desde apt (Ubuntu/Debian), XAMPP o cualquier otra herramienta.
  - NOTA: este comando creará un un contenedor con usuario "root" y contraseña "root", si desea cambiar la contraseña cambiar el valor de MYSQL_ROOT_PASSWORD, y ejecutará en el puerto 3306
  ```
  $ docker run --name mysql5.7 -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 -d mysql:5.7 --lower_case_table_names=1 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
  ```

## Pasos para instalación
1. Copiar contenido de carpeta Magento (descargado desde la web) hacia un directorio, por ejemplo **/home/usuario/proyectos/magento236**
2. Moverse al directorio creado (paso 1) con el contenido de Magento.
  ```
  $ cd /home/usuario/proyectos/magento236
  ```

3. Dar permiso de RWX a carpetas internas de Magento
  ```
  $ chmod -R 777 var/ pub/static/ generated/ app/etc pub/media
  ```

4. Crear imagen Docker para servir Magento
   - NOTA: este proceso demorará un poco ya que es donde realiza la descarga de la imagen Docker PHP con Apache e instalación de extensiones PHP. Luego se puede validar que se ha creado satisfactoriamente la imagen
    ```
    $ docker build -t magento236:v1.0.0 .
    $ docker images 
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    magento236          v1.0.0              e1e5fccb56f4        12 hours ago        428MB
    ```

5. Crear contenedor Docker que ejecutará Magento.
   - Consideraciones:
     - $PUERTO_PC: se debe cambiar por el puerto en el cual desea ejecutar Magento, por ejemplo *8088* o si desea servirlo "sin puerto" colocar *80* (puerto por defecto de los navegadores)
     - $RUTA_MAGENTO: se debe cambiar por el directorio de Magento (creado en el Paso 1), por ejemplo */home/usuario/proyectos/magento236*
   - Si desea que el contenedor NO se inicie autómaticamente al reiniciar el PC.
    ```
    $ docker run --name magento236 -p $PUERTO_PC:80 -v $RUTA_MAGENTO:/var/www/html -d magento236:v1.0.0
    ```

   - Si desea que el contenedor se inicie autómaticamente al reiniciar el PC.
    ```
    $ docker run --name magento -p $PUERTO_PC:80 -v $RUTA_MAGENTO:/var/www/html --restart always -d magento236:v1.0.0
    ```

   - Para validar la creación del contenedor.
    ```
    $ docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
    96bcfa158c4d        magento236:v1.0.0   "docker-php-entrypoi…"   12 hours ago        Up 18 seconds       0.0.0.0:8088->80/tcp magento
    # Si se ejecutó en puerto 80 se observará de la siguiente forma
    96bcfa158c4d        magento236:v1.0.0   "docker-php-entrypoi…"   12 hours ago        Up 18 seconds       0.0.0.0:80->80/tcp   magento
    ```

6. Si desea ingresar con URL mas amigable se debe configurar un nuevo host en el SO (OPCIONAL)
   - Editar archivo hosts con permisos super usuario
    ```
    $ sudo nano /etc/hosts
    ```
   - Agregar y guardar la siguiente línea
    ```
    127.0.0.1   magento.everis.local.com
    ```
   - Luego puede ingresar con:
    - http://magento.everis.local.com:8088
    - http://magento.everis.local.com (si se ejecutó paso 5 en el puerto 80)

7. Instalar Magento, para esto es necesario que se haya creado previamento la BD que utilizará Magento.
    - Si desea instalar desde la web e ingresar a la URL y seguir los pasos.
      - http://localhost:8088 o http://127.0.0.1:8088
      - http://localhost o 127.0.0.1 (si se ejecutó paso 5 en el puerto 80)
    - Si desea instalar desde Magento CLI
    ```
    $ ./bin/magento setup:install \
            --base-url=localhost:8088 \
            --db-host=PUERTO_BD \
            --db-name=NOMBRE_BD \
            --db-user=root \
            --db-password=root \
            --admin-firstname=Dhaniel \
            --admin-lastname=Diaz \
            --admin-email=correo@gmail.com \
            --admin-user=admin \
            --admin-password=123everis. \
            --currency=PEN \
            --timezone=America/Lima \
            --use-rewrites=1
    ```

