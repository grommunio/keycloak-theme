# grommunio keycloak-theme

Keycloak theme for grommunio.
Is bundled as jar into the provider directory at build time.

## Create jar

To create a jar that is deployed by `kc.sh build` just package all files in src. (e.g. `cd src ; jar -xf grommunio-theme.jar *`)

## Development

For development the theme files can be edited directly.

- stop the keycloak server if running `systemctl stop grommunio-keycloak`
- (re)move the shipped grommunio theme from /opt/grommunio-keycloak/grommunio-theme.jar
- copy theme files `cp -r src/theme/grommunio /opt/grommunio-keycloak/themes/`
- start grommunio-keycloak with disabled caching `/opt/grommunio-keycloak/bin/kc.sh --config-file=/etc/grommunio-keycloak/keycloak.conf --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false start`
- the theme files within /opt/grommunio-keycloak/themes/grommunio/ can now be edited on the fly

