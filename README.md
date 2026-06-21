# netch

*local network recon, zero dependencies, zero nonsense*

A neofetch-style network info tool. Shows hostname, kernel, default interface, gateway, public IP, per-interface MAC/IPv4/IPv6/up-down state, and DNS — all in one colorful terminal dump.

```
 _ __   ___| |_ ___| |__
| '_ \ / _ \ __/ ___| '_ \
| | | |  __/ || (__| | | |
|_| |_|\___|\__\___|_| |_|

Host:          mymachine.local
Kernel:        23.5.0
Default IF:    en0
Gateway:       192.168.1.1
Public IP:     203.0.113.42
───────────────────────────────
en0  [up]
  MAC:    aa:bb:cc:dd:ee:ff
  IPv4:   192.168.1.42
  IPv6:   2001:db8::1
...
───────────────────────────────
Interface guide:
en0      built-in Wi-Fi (or Ethernet on Wi-Fi-less Macs)
utun0    VPN / IPSec / Tailscale-style virtual tunnel
───────────────────────────────
DNS:     1.1.1.1, 8.8.8.8
───────────────────────────────
```

## Features

- ASCII art banner, neofetch-style
- Hostname and kernel version
- Default route: interface + gateway
- Public IP (via `ifconfig.me`, with a graceful fallback if unreachable)
- Per-interface breakdown:
  - MAC address
  - IPv4 address
  - IPv6 address (link-local `fe80::`/`::1` excluded)
  - Up/down status (color-coded: green = up, red = down)
- macOS-only interface guide explaining what `en0`, `utun0`, `awdl0`, etc. actually are
- DNS servers from `/etc/resolv.conf`

## Requirements

- `bash`
- One of the following, in order of preference:
  - **macOS**: `ifconfig`, `networksetup`, `route`
  - **Linux**: `ip` (iproute2)
  - **Fallback** (no `ip`/`ifconfig` available): `/sys/class/net`, `/proc/net/route`, `/proc/net/if_inet6`, and `python3` (for IPv4 lookup via `socket`/`fcntl`)
- `curl` (optional — used to fetch your public IP; script degrades gracefully without it)

No external dependencies beyond what's typically already on macOS or a standard Linux box.

## Install (Homebrew tap)

```bash
brew tap realnishil/netch
brew install netch
```

> **Heads up — you'll likely need to run a trust step.**
> Homebrew tap formulas (anything outside `homebrew-core`) aren't automatically trusted. After tapping, run:
> ```bash
> brew trust realnishil/netch
> # or
> brew trust --formula netch
> ```
> This applies even if you skip the explicit `brew tap` step and install directly with the fully-qualified name:
> ```bash
> brew install realnishil/netch/netch
> ```
> Homebrew will auto-tap the repo for you, but the formula still won't load until you run `brew trust` — there's no shortcut around it.
>
> This trust step only applies to non-official taps like this one. There's no path to "official" status for a personal tool short of full `homebrew-core` inclusion (which requires a notability review). Even `homebrew-core` formulas aren't exempt from trust because someone reviewed them individually — they're trusted by virtue of being maintained inside Homebrew's own org, which a personal tap can't replicate.

## Manual install (no tap)

```bash
curl -O https://raw.githubusercontent.com/realnishil/netch/main/netch.sh
chmod 755 netch.sh
./netch.sh
```

## Usage

```bash
chmod 755 netch.sh
./netch.sh
```

## How it works

The script detects the OS (`Darwin` vs Linux) and picks the best available tool for each piece of info:

| Info              | macOS                          | Linux (`ip` present)     | Linux (no `ip`/`ifconfig`) |
|--------------------|---------------------------------|---------------------------|------------------------------|
| Default gateway/IF | `route -n get default`          | `ip route`                 | `/proc/net/route`            |
| Interfaces list    | `networksetup -listallhardwareports` | `/sys/class/net`      | `/sys/class/net`              |
| MAC/IPv4/IPv6/state| `ifconfig <iface>`               | `ip addr show <iface>`     | `/sys/class/net/<iface>/*`, `python3` socket call |
| Public IP          | `curl ifconfig.me`              | `curl ifconfig.me`         | `curl ifconfig.me`            |
| DNS                | `/etc/resolv.conf`               | `/etc/resolv.conf`         | `/etc/resolv.conf`            |

This means it runs on minimal/stripped-down systems (e.g. containers) where neither `ip` nor `ifconfig` is installed.

## Interface guide (macOS)

Since macOS interface names (`en0`, `utun0`, `awdl0`, ...) aren't self-explanatory, the script prints a short legend for each interface it found, e.g.:

- `en0` — built-in Wi-Fi (or Ethernet on Wi-Fi-less Macs)
- `en1` — built-in Ethernet, or second Wi-Fi radio
- `lo0` — loopback
- `utun*` — VPN / IPSec / Tailscale-style virtual tunnel
- `awdl0` — Apple Wireless Direct Link (AirDrop/Handoff/Sidecar mesh)
- `bridge0` — software bridge (Internet Sharing, virtualization)

This section is skipped entirely on Linux.

## Notes

- `lo`/`lo0` (loopback) is always skipped in the interface listing.
- If the public IP lookup fails or times out (2s), it's shown as `(unreachable)` instead of breaking the script.
- Colors are hardcoded ANSI escape codes — should render correctly in most terminal emulators.

## License

MIT (or whatever you want to slap on it)

## Author

Made by Nishil.
