# Despliegue de Magento utilizando Docker en Linux

## Requerimientos
- Magento 2.3.6, se puede desde *https://magento.com/tech-resources/download*.
- Curl, generalmente viene preinstalado con Linux, se puede validar con el siguiente comando el cual deberá mostrar la versión.
  ```
  $ curl -V
  curl 7.68.0 (x86_64-pc-linux-gnu) libcurl/7.68.0 OpenSSL/1.1.1f zlib/1.2.11 brotli/1.0.7 libidn2/2.2.0 libpsl/0.21.0 (+libidn2/2.2.0) libssh/0.9.3/openssl/zlib nghttp2/1.40.0 librtmp/2.3
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
  - Al instalar docker para poder ejecutarlo será necesario hacerlo como super usuario, si no desea esto puede ejecutar el siguiente comando y luego reiniciar el SO.
  ```
  $ sudo usermod -aG docker $USER
  ```
- MySQL, si desea instalar con Docker usar este comando, sino se instala desde apt (Ubuntu/Debian), XAMPP o cualquier otra herramienta.
  - NOTA: este comando creará un un contenedor con usuario "root" y contraseña "root", si desea cambiar la contraseña cambiar el valor de MYSQL_ROOT_PASSWORD, y ejecutará en el puerto 3306
  ```
  $ docker run --name mysql5.7 -e MYSQL_ROOT_PASSWORD=root --restart always -p 3306:3306 -d mysql:5.7 --lower_case_table_names=1 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
  ```
  - Conectarse con un cliente como MySQL Workbench y crear nueva BD.

## Pasos para instalación
1. Copiar contenido de carpeta Magento en algún un directorio, por ejemplo **/home/usuario/proyectos/magento236**
2. Moverse al directorio creado con el contenido de Magento (paso 1).
  ```
  $ cd /home/usuario/proyectos/magento236
  ```

3. Dar permiso de RWX a carpetas internas de Magento
  ```
  $ chmod -R 777 var/ pub/static/ generated/ app/etc pub/media
  ```

4. Clonar repositorio y ubicarse dentro del mismo para generar imagen Docker
   - Cambiar $RUTA por la ruta donde desea clonar el repositorio, por ejemplo */home/usuario/proyectos*.
   ```
   $ git clone https://github.com/dhanieldiaz/docker-magento-installer.git $RUTA/docker-magento-installer && cd $RUTA/docker-magento-installer
   ```

5. Crear imagen Docker para servir Magento
   - NOTA: este proceso demorará un poco ya que es donde realiza la descarga de la imagen Docker PHP con Apache e instalación de extensiones PHP. Luego se puede validar que se ha creado satisfactoriamente la imagen
    ```
    $ docker build -t magento236:v1.0.0 .
    $ docker images 
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    magento236          v1.0.0              e1e5fccb56f4        12 hours ago        428MB
    ```

6. Crear contenedor Docker que ejecutará Magento.
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
   - Para validar la creación del contenedor, en PORTS se mostrará depende del puerto indicado anteriormente.
    ```
    $ docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
    96bcfa158c4d        magento236:v1.0.0   "docker-php-entrypoi…"   12 hours ago        Up 18 seconds       0.0.0.0:8088->80/tcp magento
    ```

7. Si desea ingresar con URL mas amigable se debe configurar un nuevo host en el SO (OPCIONAL)
   - Editar archivo hosts con permisos super usuario
    ```
    $ sudo nano /etc/hosts
    ```
   - Agregar y guardar la siguiente línea
    ```
    127.0.0.1   magento.everis.local.com
    ```

8. Instalar Magento, para esto es necesario que se haya creado previamento la BD que utilizará Magento.
    - Si desea instalar desde la web, debe ingresar a la URL y seguir los pasos.
      - *http://localhost:8088* o *http://127.0.0.1:8088*
      - *http://localhost* o *http://127.0.0.1* (si se ejecutó paso 5 en el puerto 80)
    - Si ejecutó paso 6 puede ingresar mediante:
      - *http://magento.everis.local.com:8088*
      - *http://magento.everis.local.com* (si se ejecutó paso 5 en el puerto 80)
    - Si desea instalar desde Magento CLI considerar lo siguiente
      - Cambiar *--base-url* por la ruta configurada localhost/127.0.0.1/magento.everis.local.com junto al puerto creado con el contenedor paso 6.
      - Cambiar *--db-host* por IP de la BD, si utilizó Docker para MySQL ejecutar el siguiente comando y tomar el valor de IPAddress.
        ```
        $ docker inspect mysql5.7 | grep \"IPAddress
          "IPAddress": "172.17.0.2"
        ```
    ```
    $ ./bin/magento setup:install \
            --base-url=http://magento.everis.local.com:8088 \
            --db-host=PUERTO_BD \
            --db-name=NOMBRE_BD \
            --db-user=USUARIO_BD \
            --db-password=CONTRASEÑA_BD \
            --admin-firstname=Dhaniel \
            --admin-lastname=Diaz \
            --admin-email=ddiazaco@everis.com \
            --admin-user=admin \
            --admin-password=123everis. \
            --currency=PEN \
            --timezone=America/Lima \
            --use-rewrites=1
    ```

# Solución de algunos errores
- Si no utiliza la opción de reiniciar los contenedores autómaticamente no funcionará al ingresar a la URL hasta iniciar el contenedor, para esto ejecutar:
```
$ docker start mysql5.7 magento236
```
- Si esta iniciado el contenedor MySQL e ingresar a la URL de Magento pero no le reconoce configuración de BD. Modificar archivo dentro de magento ubicado en *app/etc/env.php*, el valor *host* que esta dentro de *db*
  - Para conocer el valor de la IP ejecutar siguiente comando y tomar el valor IPAddress:
  ```
  $ docker inspect mysql5.7 | grep \"IPAddress
    "IPAddress": "172.17.0.2"
  ```
  - Cambiar el valor host
  ```
  'host' => '172.17.0.2'
  ```