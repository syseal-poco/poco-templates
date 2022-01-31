# Notes

## Nextcloud configuration Security

```php
  'trusted_domains' => 
  array (
    0 => 'localhost',
    1 => 'nextcloud.domain.fr',
  ),
  'trusted_proxies' => 
  array (
    0 => '127.0.0.1',
  ),
  'overwritehost' => 'nextcloud.domain.fr',
  'overwriteprotocol' => 'https',
  'session_lifefime’ => 28800,
  ‘session_keepalive’ => false,
  ‘remember_login_cookie_lifetime’ => 0,
```
