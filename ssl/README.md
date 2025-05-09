# ssl

Resources to set up TLS encryption for the ODFWeb service.

## Create a self-signed SSL certificate for testing purposes

```bash
openssl req \
    -x509 \
    -nodes \
    -days 30 \
    -newkey rsa:2048 \
    -keyout odfweb.example.com.key \
    -out odfweb.example.com.crt
```

## References

* [How to create a self-signed SSL certificate](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu)
  Explains how to easily create a self-signed SSL certificate for testing purposes.
