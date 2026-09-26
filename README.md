# grommunio keycloak-theme

Login theme for Keycloak 26 (parent theme `keycloak.v2`, PatternFly v5).
It is packaged as a jar and installed into Keycloak's `providers/` directory.

## Layout

```
src/META-INF/keycloak-themes.json                     theme registration
src/theme/grommunio/login/theme.properties            parent, styles, scripts
src/theme/grommunio/login/resources/css/grommunio.css all styling (loaded after the parent's css/styles.css)
src/theme/grommunio/login/resources/img/              logo.svg, pattern.svg
src/theme/grommunio/login/resources/js/grommunio.js
```

No templates are overridden; the stock `keycloak.v2` templates are styled through
their generic PatternFly classes, so every login flow (password, OTP, reset and
update password, error and info pages, authenticator selection, WebAuthn) is covered.
To customise a template anyway, copy it from `theme/keycloak.v2/login/` (or
`theme/base/login/`) inside
`/opt/grommunio-keycloak/lib/lib/main/org.keycloak.keycloak-themes-<version>.jar`
into `src/theme/grommunio/login/` and edit it there.

The stylesheet imports the site-wide `/brand/brand.css` first, so host-level
styling applies here as well. Dark mode follows `prefers-color-scheme` (Keycloak
adds the `pf-v5-theme-dark` class on `<html>`).

## Build

```
./build.sh                 # writes grommunio-theme.jar into the repo root
./build.sh /tmp/theme.jar  # alternative output path
```

Only python3 is needed (no `jar`/`zip` binaries). The jar contains
`META-INF/MANIFEST.MF`, `META-INF/keycloak-themes.json` and `theme/...`.

## Install

```
cp grommunio-theme.jar /opt/grommunio-keycloak/providers/
/opt/grommunio-keycloak/bin/kc.sh --config-file=/etc/grommunio-keycloak/keycloak.conf build
rm -rf /opt/grommunio-keycloak/data/tmp/kc-gzip-cache
systemctl restart grommunio-keycloak
```

Keycloak keeps gzipped copies of theme resources under `data/tmp/kc-gzip-cache`
keyed by the (version-only) resource path, so browsers keep receiving the previous
stylesheet until that directory is removed.

Select `grommunio` as login theme in the realm settings (Realm settings > Themes)
if it is not set already.

## Development (edit files in place)

Keycloak also loads themes from its `themes/` directory without a build step. A
folder theme takes precedence over a jar of the same name; to avoid confusion remove
the jar while developing.

```
systemctl stop grommunio-keycloak
rm /opt/grommunio-keycloak/providers/grommunio-theme.jar
/opt/grommunio-keycloak/bin/kc.sh --config-file=/etc/grommunio-keycloak/keycloak.conf build
cp -r src/theme/grommunio /opt/grommunio-keycloak/themes/
/opt/grommunio-keycloak/bin/kc.sh --config-file=/etc/grommunio-keycloak/keycloak.conf \
    --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false start
```

Files under `/opt/grommunio-keycloak/themes/grommunio/` can now be edited and the
result shows up on reload. Run `kc.sh` as the service user (`groauth`) or fix the
ownership of `/opt/grommunio-keycloak/data` afterwards. When done, remove
`themes/grommunio`, reinstall the jar (see Install) and start the service again.
