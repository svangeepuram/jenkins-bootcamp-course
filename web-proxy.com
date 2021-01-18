upstream jenkins {
  keepalive 32;
  server 172.26.15.248:8080 fail_timeout=0;
  server [2600:1f14:b65:2e00:113c:bf2d:bcca:4e7e]:8080 fail_timeout=0;
}

server {
  listen 80;
  listen [2600:1f14:b65:2e00:d07e:8f40:45ec:982a]:80;

  # Update with your own DNS or IP address
  server_name www.gamyam.net;

  access_log /var/log/nginx/jenkins/http-access.log combined;
  error_log /var/log/nginx/jenkins/http-error.log;

  location /.well-known {
      alias /var/www/jenkins/.well-known;
  }

  return 301 https://$host$request_uri;
}

server {
  listen 44.224.227.248:443 ssl;
  listen [2600:1f14:b65:2e00:d07e:8f40:45ec:982a]:443 ssl;

  # Update with your own DNS or IP address
  server_name www.gamyam.net;

  ssl_certificate /etc/letsencrypt/live/www.gamyam.net/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/www.gamyam.net/privkey.pem;

  ssl_stapling on;
  ssl_stapling_verify on;

  access_log /var/log/nginx/jenkins/https-access.log combined;
  error_log /var/log/nginx/jenkins/https-error.log;

  location / {
      sendfile off;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      if ($request_uri ~* "/blue(/.*)") {
        proxy_pass http://172.26.15.248:8080/blue$1;
        proxy_pass http://[2600:1f14:b65:2e00:113c:bf2d:bcca:4e7e]:8080/blue$1;
         break;
      }

      proxy_pass http://jenkins;
      proxy_redirect http://jenkins https://www.gamyam.net;
  }
}
