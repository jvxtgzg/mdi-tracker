# MDI Tracker

FiveM resource untuk menampilkan tracker data admin/player di MDI.

## Fitur awal

- Live Players
- Characters by framework map
- Bans list
- Insert Ban
- Framework Map

## Permission

Default akses dibuat ketat:

- QBCore permission/group/job grade/name yang mengandung `director`
- Typo lama `directror` juga diterima
- Non-QBCore fallback memakai ACE permission `mdi.tracker.director`

## Install

1. Copy folder `mdi-tracker` ke folder `resources`.
2. Pastikan `oxmysql` aktif.
3. Pastikan `qb-core` aktif jika memakai QBCore.
4. Tambahkan ke `server.cfg`:

```cfg
ensure mdi-tracker
```

5. Buka di game dengan command:

```text
/mditracker
```

## Config

Edit `shared/config.lua`:

```lua
Config.Framework = 'qb' -- qb, esx, nd, ox
Config.BansTable = 'bans'
```

## Catatan keamanan

Data sensitif seperti `license`, `discord`, dan `ip` tidak di-query dari NUI/client.
Semua data melewati server callback dan permission check.
