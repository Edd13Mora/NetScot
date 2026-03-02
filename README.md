<div align="center">

```
 ███╗   ██╗███████╗████████╗███████╗ ██████╗ ██████╗ ████████╗
 ████╗  ██║██╔════╝╚══██╔══╝██╔════╝██╔════╝██╔═══██╗╚══██╔══╝
 ██╔██╗ ██║█████╗     ██║   ███████╗██║     ██║   ██║   ██║
 ██║╚██╗██║██╔══╝     ██║   ╚════██║██║     ██║   ██║   ██║
 ██║ ╚████║███████╗   ██║   ███████║╚██████╗╚██████╔╝   ██║
 ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═════╝    ╚═╝
```

**Internal Pentest Asset Discovery Tool**

![Version](https://img.shields.io/badge/version-2.0.0-cyan?style=flat-square)
![Shell](https://img.shields.io/badge/shell-bash-green?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Kali-blueviolet?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-orange?style=flat-square)
![Author](https://img.shields.io/badge/author-Edd13Mora-red?style=flat-square&logo=github)

*Fast parallel network reconnaissance with interactive HTML reports — built for pentesters, by a pentester.*

</div>

---

## 📖 Overview

**NetScout** is a single-file bash tool for internal network asset discovery during penetration tests. It scans a target range across 8 protocols in parallel, fingerprints services, checks for low-hanging fruit (anonymous FTP, default Telnet credentials, SSL cert info, CMS detection), and generates a professional interactive HTML report you can hand directly to your client.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🔍 **Multi-protocol scanning** | HTTP/HTTPS, FTP, Telnet, SMB, RDP, SSH, Databases |
| ⚡ **Parallel engine** | Configurable thread count (default 50), processes entire /24 in under 2 minutes |
| 🏓 **Ping sweep** | Pre-filters live hosts before port scanning — major speed boost on large ranges |
| 🌐 **Web fingerprinting** | Status codes, page titles, Server headers, CMS detection (WordPress, Drupal, Laravel...) |
| 🔒 **SSL cert grabbing** | Subject, issuer, expiry date from HTTPS endpoints |
| 🔐 **Active security checks** | Anonymous FTP login, Telnet default credentials brute |
| 💡 **OS fingerprinting** | TTL-based OS detection on RDP targets (Windows / Linux / Cisco) |
| 📊 **Interactive HTML report** | Search, pagination, sort, copy IPs, export CSV — dark & light mode |
| 📄 **CSV export** | Machine-readable results for integration with other tools |
| 🎨 **Beautiful terminal UI** | Color-coded tables, progress bar, scan summary |
| 🔧 **Auto-install** | Missing dependencies installed automatically via apt/yum/pacman |

---

## 🖥️ Demo

```
  ╔═══════════════════════════════════════════════════════════════╗
  ║   ███╗   ██╗███████╗████████╗███████╗ ██████╗ ██████╗ ...   ║
  ║           Internal Pentest Asset Discovery Tool v2.0.0        ║
  ╚═══════════════════════════════════════════════════════════════╝

  ◈  🌐  WEB ASSETS  (HTTP / HTTPS)
  ─────────────────────────────────────────────────────────────────
  PROTO   IP                 PORT    CODE  SERVER                TECH/CMS            TITLE
  HTTP    192.168.1.10       80      200   Apache/2.4.54         WordPress           Login — Admin
  HTTPS   192.168.1.20       443     200   nginx/1.22.0          N/A                 Corporate Portal
  HTTP    192.168.1.35       8080    401   —                     N/A                 Unauthorized
  
  ✦ 3 web service(s) found
```

---

## 📦 Installation

```bash
# Clone the repo
git clone https://github.com/edd13mora/netscout.git
cd netscout

# Make executable
chmod +x netscout.sh

# Optional: install globally
sudo cp netscout.sh /usr/local/bin/netscout
```

**Dependencies** — auto-installed if missing:

```
nmap  curl  nc (netcat-openbsd)  openssl
```

---

## 🚀 Usage

```bash
netscout [MODES] [TARGET] [OPTIONS]
```

### Modes

| Flag | Description |
|---|---|
| `--all` | Full scan — all categories (default) |
| `--web` | HTTP/HTTPS + SSL cert info + CMS detection |
| `--ftp` | FTP + anonymous login check |
| `--telnet` | Telnet + default credentials check |
| `--smb` | SMB/Samba (445/139) |
| `--rdp` | RDP (3389) + OS hint via TTL |
| `--ssh` | SSH (22) + banner/version grab |
| `--db` | MySQL, MSSQL, PostgreSQL, MongoDB, Redis |

> Modes are **combinable**: `--web --ssh --db`

### Targets

| Flag | Example |
|---|---|
| `-i, --ip <addr>` | `-i 192.168.1.10` |
| `-r, --range <cidr>` | `-r 192.168.1.0/24` |
| `-f, --file <path>` | `-f targets.txt` |

### Options

| Flag | Default | Description |
|---|---|---|
| `-o, --output <file>` | — | Save interactive HTML report |
| `--csv <file>` | — | Also export CSV |
| `-t, --timeout <sec>` | `2` | Probe timeout |
| `-T, --threads <n>` | `50` | Parallel threads |
| `--no-ping` | off | Skip ping sweep, scan all IPs |
| `-v, --verbose` | off | Live probe output |

---

## 📋 Examples

```bash
# Full discovery on a /24 — HTML report
netscout --all -r 192.168.1.0/24 -o report.html

# Web + SSH only, verbose, also export CSV
netscout --web --ssh -r 10.0.0.0/24 -v --csv results.csv

# Database services scan, 100 threads, 3s timeout
netscout --db -r 10.10.0.0/24 -T 100 -t 3

# Scan from a list of targets, skip ping sweep
netscout --all -f targets.txt --no-ping -o report.html

# Single host full audit
netscout --all -i 10.10.10.5 -o audit.html

# FTP + Telnet only on a range
netscout --ftp --telnet -r 172.16.0.0/24
```

---

## 📊 Ports Covered

| Protocol | Ports |
|---|---|
| HTTP | 80, 8080, 8000, 8888, 3000, 3001, 5000, 8008, 8081, 8090 |
| HTTPS | 443, 8443, 4443, 9443 |
| FTP | 21, 990 |
| Telnet | 23, 2323 |
| SMB | 445, 139 |
| RDP | 3389 |
| SSH | 22 |
| MySQL | 3306 |
| MSSQL | 1433 |
| PostgreSQL | 5432 |
| MongoDB | 27017 |
| Redis | 6379 |

---

## 📄 HTML Report Features

The generated report is a **single standalone HTML file** — no internet connection required, open it anywhere.

- 🔍 **Global search** — filters all sections simultaneously with highlight
- 📄 **Pagination** — configurable rows per page (25 / 50 / 100 / 250 / All)
- ↕️ **Sortable columns** — click any header to sort
- 📋 **Copy IPs** — one click to copy all IPs from a section to clipboard
- 📋 **Copy All** — copies full table as TSV (paste into Excel / Notion)
- 💾 **Export CSV** — download filtered results as CSV per section
- ☀️🌙 **Dark / Light mode** — toggle with memory (localStorage)
- 🏷️ **Section tabs** — jump between Web / FTP / SMB / SSH etc.

---

## ⚙️ Architecture

```
netscout.sh  (single self-contained file)
│
├── check_requirements()     Auto-install nmap, curl, nc, openssl
├── build_ip_list()          Expand CIDRs via nmap -sL
├── ping_sweep()             Parallel ICMP pre-filter
├── run_scan()               Parallel job engine (configurable threads)
│   ├── scan_host_web()      HTTP/HTTPS + curl fingerprint + SSL + CMS
│   ├── scan_host_ftp()      nc banner grab + anonymous login
│   ├── scan_host_telnet()   nc banner grab + default creds check
│   ├── scan_host_smb()      nmap smb-os-discovery script
│   ├── scan_host_rdp()      nc probe + TTL-based OS hint
│   ├── scan_host_ssh()      nc banner grab + version parse
│   └── scan_host_db()       nc probe on 5 DB ports
├── generate_html()          Interactive report with embedded JS (base64)
└── export_csv()             Machine-readable CSV export
```

---

## 🔒 Legal Disclaimer

> **NetScout is designed for authorized penetration testing only.**
> Only use this tool on networks and systems you own or have explicit written permission to test.
> Unauthorized scanning may violate local laws and regulations.
> The author assumes no liability for misuse.

---

## 👤 Author

**Edd13Mora** — Penetration Tester & Red Team Lead

- 🌐 [pentester.ma](https://pentester.ma)
- 📖 *Hack 4 Living* (upcoming book)
- 🐙 [github.com/edd13mora](https://github.com/edd13mora)

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">
<i>Built with ☕</i>
</div>
