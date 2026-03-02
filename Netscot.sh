#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
#  NetScout v2.0.0 — Internal Pentest Asset Discovery
#  by Fahd | pentester.ma
# ══════════════════════════════════════════════════════════════════════

VERSION="2.0.0"
SCAN_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# ─── Colors ──────────────────────────────────────────────────────────
RESET='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'
RED='\033[38;5;196m';   ORANGE='\033[38;5;208m'; YELLOW='\033[38;5;220m'
GREEN='\033[38;5;46m';  CYAN='\033[38;5;51m';    BLUE='\033[38;5;33m'
PURPLE='\033[38;5;171m';PINK='\033[38;5;213m';   WHITE='\033[38;5;255m'
GRAY='\033[38;5;245m'
BG_DARK='\033[48;5;234m'; BG_RED='\033[48;5;52m';   BG_BLUE='\033[48;5;17m'
BG_GREEN='\033[48;5;22m'; BG_PURPLE='\033[48;5;54m'; BG_TEAL='\033[48;5;23m'
BG_MAROON='\033[48;5;88m'; BG_NAVY='\033[48;5;18m'; BG_DGRAY='\033[48;5;236m'

# ─── Banner ──────────────────────────────────────────────────────────
print_banner() {
  echo -e ""
  echo -e "${CYAN}${BOLD}  ╔═══════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}${BOLD}  ║  ${RESET}${PURPLE}${BOLD} ███╗   ██╗███████╗████████╗███████╗ ██████╗ ██████╗ ████████╗${CYAN}${BOLD}  ║${RESET}"
  echo -e "${CYAN}${BOLD}  ║  ${RESET}${PURPLE}${BOLD} ████╗  ██║██╔════╝╚══██╔══╝██╔════╝██╔════╝██╔═══██╗╚══██╔══╝${CYAN}${BOLD}  ║${RESET}"
  echo -e "${CYAN}${BOLD}  ║  ${RESET}${PINK}${BOLD}  ██╔██╗ ██║█████╗     ██║   ███████╗██║     ██║   ██║   ██║  ${CYAN}${BOLD}  ║${RESET}"
  echo -e "${CYAN}${BOLD}  ║  ${RESET}${PINK}${BOLD}  ██║╚██╗██║██╔══╝     ██║   ╚════██║██║     ██║   ██║   ██║  ${CYAN}${BOLD}  ║${RESET}"
  echo -e "${CYAN}${BOLD}  ║  ${RESET}${BLUE}${BOLD}  ██║ ╚████║███████╗   ██║   ███████║╚██████╗╚██████╔╝   ██║  ${CYAN}${BOLD}  ║${RESET}"
  echo -e "${CYAN}${BOLD}  ║  ${RESET}${BLUE}${BOLD}  ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═════╝    ╚═╝  ${CYAN}${BOLD}  ║${RESET}"
  echo -e "${CYAN}${BOLD}  ║${RESET}${GRAY}        Internal Pentest Asset Discovery Tool v${VERSION}            ${CYAN}${BOLD}║${RESET}"
  echo -e "${CYAN}${BOLD}  ║${RESET}${DIM}${GRAY}                      pentester.ma  |  Fahd                     ${CYAN}${BOLD}║${RESET}"
  echo -e "${CYAN}${BOLD}  ╚═══════════════════════════════════════════════════════════════╝${RESET}"
  echo ""
}

# ─── Logging ─────────────────────────────────────────────────────────
log_info()    { echo -e "  ${CYAN}${BOLD}[*]${RESET} ${WHITE}$*${RESET}"; }
log_ok()      { echo -e "  ${GREEN}${BOLD}[✔]${RESET} ${GREEN}$*${RESET}"; }
log_warn()    { echo -e "  ${YELLOW}${BOLD}[!]${RESET} ${YELLOW}$*${RESET}"; }
log_error()   { echo -e "  ${RED}${BOLD}[✘]${RESET} ${RED}$*${RESET}"; }
log_section() {
  echo ""
  echo -e "  ${BOLD}${BG_DARK} ${PURPLE}◈${RESET}${BOLD}${BG_DARK}  $* ${RESET}"
  echo -e "  ${GRAY}$(printf '─%.0s' {1..65})${RESET}"
}

# ─── Help ────────────────────────────────────────────────────────────
print_help() {
  print_banner
  echo -e "  ${BOLD}${WHITE}USAGE${RESET}"
  echo -e "    ${CYAN}netscout${RESET} ${YELLOW}[MODES]${RESET} ${GREEN}[TARGET]${RESET} ${GRAY}[OPTIONS]${RESET}"
  echo ""
  echo -e "  ${BOLD}${WHITE}SCAN MODES  ${DIM}(combinable, default: --all)${RESET}"
  echo -e "    ${YELLOW}--all${RESET}        ${GRAY}│${RESET}  Full scan — all categories below"
  echo -e "    ${YELLOW}--web${RESET}        ${GRAY}│${RESET}  HTTP/HTTPS assets + SSL cert info + tech fingerprint"
  echo -e "    ${YELLOW}--ftp${RESET}        ${GRAY}│${RESET}  FTP services + anonymous login check"
  echo -e "    ${YELLOW}--telnet${RESET}     ${GRAY}│${RESET}  Telnet services + default creds check"
  echo -e "    ${YELLOW}--smb${RESET}        ${GRAY}│${RESET}  SMB/Samba (445/139)"
  echo -e "    ${YELLOW}--rdp${RESET}        ${GRAY}│${RESET}  RDP (3389)"
  echo -e "    ${YELLOW}--ssh${RESET}        ${GRAY}│${RESET}  SSH (22) + banner/version"
  echo -e "    ${YELLOW}--db${RESET}         ${GRAY}│${RESET}  Databases: MySQL, MSSQL, PostgreSQL, MongoDB, Redis"
  echo ""
  echo -e "  ${BOLD}${WHITE}TARGETS  ${DIM}(at least one required)${RESET}"
  echo -e "    ${GREEN}-i, --ip${RESET} ${CYAN}<addr>${RESET}       ${GRAY}│${RESET}  Single IPv4          ${DIM}e.g. -i 192.168.1.10${RESET}"
  echo -e "    ${GREEN}-r, --range${RESET} ${CYAN}<cidr>${RESET}    ${GRAY}│${RESET}  CIDR range           ${DIM}e.g. -r 192.168.1.0/24${RESET}"
  echo -e "    ${GREEN}-f, --file${RESET} ${CYAN}<path>${RESET}     ${GRAY}│${RESET}  File — one IP/CIDR per line"
  echo ""
  echo -e "  ${BOLD}${WHITE}OPTIONS${RESET}"
  echo -e "    ${GREEN}-o, --output${RESET} ${CYAN}<file>${RESET}      ${GRAY}│${RESET}  Save HTML report  ${DIM}(e.g. -o report.html)${RESET}"
  echo -e "    ${GREEN}    --csv${RESET} ${CYAN}<file>${RESET}         ${GRAY}│${RESET}  Also export CSV   ${DIM}(e.g. --csv results.csv)${RESET}"
  echo -e "    ${GREEN}-t, --timeout${RESET} ${CYAN}<sec>${RESET}      ${GRAY}│${RESET}  Probe timeout     ${DIM}(default: 2)${RESET}"
  echo -e "    ${GREEN}-T, --threads${RESET} ${CYAN}<n>${RESET}        ${GRAY}│${RESET}  Parallel threads  ${DIM}(default: 50)${RESET}"
  echo -e "    ${GREEN}    --no-ping${RESET}            ${GRAY}│${RESET}  Skip ping sweep, scan all IPs"
  echo -e "    ${GREEN}-v, --verbose${RESET}             ${GRAY}│${RESET}  Live probe output"
  echo -e "    ${GREEN}-h, --help${RESET}                ${GRAY}│${RESET}  This menu"
  echo -e "    ${GREEN}    --version${RESET}             ${GRAY}│${RESET}  Print version"
  echo ""
  echo -e "  ${BOLD}${WHITE}PORTS SCANNED${RESET}"
  echo -e "    ${BLUE}HTTP    ${RESET}${GRAY}→${RESET} ${CYAN}80 8080 8000 8888 3000 3001 5000 8008 8081 8090${RESET}"
  echo -e "    ${GREEN}HTTPS   ${RESET}${GRAY}→${RESET} ${CYAN}443 8443 4443 9443${RESET}"
  echo -e "    ${ORANGE}FTP     ${RESET}${GRAY}→${RESET} ${CYAN}21 990${RESET}"
  echo -e "    ${RED}TELNET  ${RESET}${GRAY}→${RESET} ${CYAN}23 2323${RESET}"
  echo -e "    ${PURPLE}SMB     ${RESET}${GRAY}→${RESET} ${CYAN}445 139${RESET}"
  echo -e "    ${PINK}RDP     ${RESET}${GRAY}→${RESET} ${CYAN}3389${RESET}"
  echo -e "    ${YELLOW}SSH     ${RESET}${GRAY}→${RESET} ${CYAN}22${RESET}"
  echo -e "    ${GRAY}DB      ${RESET}${GRAY}→${RESET} ${CYAN}3306(MySQL) 1433(MSSQL) 5432(PostgreSQL) 27017(MongoDB) 6379(Redis)${RESET}"
  echo ""
  echo -e "  ${BOLD}${WHITE}EXAMPLES${RESET}"
  echo -e "    ${DIM}# Full scan on /24, HTML report${RESET}"
  echo -e "    ${CYAN}netscout${RESET} ${YELLOW}--all${RESET} ${GREEN}-r${RESET} 192.168.1.0/24 ${GREEN}-o${RESET} report.html"
  echo ""
  echo -e "    ${DIM}# Web + SSH only, verbose, CSV export${RESET}"
  echo -e "    ${CYAN}netscout${RESET} ${YELLOW}--web${RESET} ${YELLOW}--ssh${RESET} ${GREEN}-r${RESET} 10.0.0.0/24 ${GREEN}-v${RESET} ${GREEN}--csv${RESET} out.csv"
  echo ""
  echo -e "    ${DIM}# FTP with anon check, skip ping sweep${RESET}"
  echo -e "    ${CYAN}netscout${RESET} ${YELLOW}--ftp${RESET} ${GREEN}-f${RESET} targets.txt ${GREEN}--no-ping${RESET}"
  echo ""
  echo -e "    ${DIM}# DB scan only, 100 threads, 3s timeout${RESET}"
  echo -e "    ${CYAN}netscout${RESET} ${YELLOW}--db${RESET} ${GREEN}-r${RESET} 10.10.0.0/24 ${GREEN}-T${RESET} 100 ${GREEN}-t${RESET} 3"
  echo ""
  echo -e "  ${GRAY}──────────────────────────────────────────────────────────────${RESET}"
  echo -e "  ${DIM}  Auto-installs missing: nmap curl nc openssl${RESET}"
  echo ""
}

# ─── Requirements ────────────────────────────────────────────────────
REQUIREMENTS=(nmap curl nc openssl)

check_requirements() {
  log_section "Checking Requirements"
  local missing=()
  for tool in "${REQUIREMENTS[@]}"; do
    if command -v "$tool" &>/dev/null; then
      log_ok "$tool  ${DIM}($(command -v "$tool"))${RESET}"
    else
      log_warn "$tool not found"
      missing+=("$tool")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    log_info "Installing: ${YELLOW}${missing[*]}${RESET}"
    if command -v apt-get &>/dev/null; then
      declare -A PKG_MAP=(["nc"]="netcat-openbsd" ["curl"]="curl" ["nmap"]="nmap" ["openssl"]="openssl")
      for tool in "${missing[@]}"; do
        apt-get install -y "${PKG_MAP[$tool]:-$tool}" -qq &>/dev/null \
          && log_ok "$tool installed" || log_error "Failed: $tool"
      done
    elif command -v yum &>/dev/null; then
      for tool in "${missing[@]}"; do yum install -y "$tool" &>/dev/null && log_ok "$tool installed" || log_error "Failed: $tool"; done
    elif command -v pacman &>/dev/null; then
      for tool in "${missing[@]}"; do pacman -Sy --noconfirm "$tool" &>/dev/null && log_ok "$tool installed" || log_error "Failed: $tool"; done
    else
      log_error "Cannot auto-install. Please install: ${missing[*]}"; exit 1
    fi
  fi
  log_ok "All requirements satisfied"
}

# ─── Target Expansion ────────────────────────────────────────────────
expand_targets() {
  local input="$1"
  if [[ "$input" =~ "/" ]]; then
    nmap -sL -n "$input" 2>/dev/null | awk '/Nmap scan report/{print $NF}'
  else
    echo "$input"
  fi
}

TMP_IPS="" TOTAL_IPS=0

build_ip_list() {
  TMP_IPS=$(mktemp)
  [[ -n "$OPT_IP"    ]] && echo "$OPT_IP" >> "$TMP_IPS"
  [[ -n "$OPT_RANGE" ]] && expand_targets "$OPT_RANGE" >> "$TMP_IPS"
  if [[ -n "$OPT_FILE" ]]; then
    while IFS= read -r line; do
      [[ -z "$line" || "$line" =~ ^# ]] && continue
      expand_targets "$line" >> "$TMP_IPS"
    done < "$OPT_FILE"
  fi
  sort -u "$TMP_IPS" -o "$TMP_IPS"
  TOTAL_IPS=$(wc -l < "$TMP_IPS" | tr -d ' ')
}

# ─── Ping Sweep ──────────────────────────────────────────────────────
ping_sweep() {
  local ip_file="$1"
  local live_file
  live_file=$(mktemp)
  log_info "Running ping sweep to filter live hosts..."
  local total
  total=$(wc -l < "$ip_file" | tr -d ' ')
  local count=0 jobs=0

  while IFS= read -r ip; do
    [[ -z "$ip" ]] && continue
    ( ping -c1 -W1 "$ip" &>/dev/null && echo "$ip" >> "$live_file" ) &
    ((jobs++))
    if [[ $jobs -ge $THREADS ]]; then wait; jobs=0; fi
    ((count++))
    printf "\r  ${CYAN}[*]${RESET} Pinging %d/%d...  " "$count" "$total"
  done < "$ip_file"
  wait
  printf "\r%-70s\r" " "

  local live_count
  live_count=$(wc -l < "$live_file" | tr -d ' ')
  log_ok "${GREEN}${live_count}${RESET} live host(s) out of ${total} pinged"
  sort -u "$live_file" -o "$live_file"
  # Replace ip_file with live hosts only
  cp "$live_file" "$ip_file"
  rm -f "$live_file"
  TOTAL_IPS=$(wc -l < "$ip_file" | tr -d ' ')
}

# ─── Generic Port Probe ──────────────────────────────────────────────
probe_port() { nc -z -w "$TIMEOUT" "$1" "$2" 2>/dev/null; }

# ─── WEB Scan ────────────────────────────────────────────────────────
scan_host_web() {
  local ip="$1"
  for port in 80 8080 8000 8888 3000 3001 5000 8008 8081 8090; do
    probe_port "$ip" "$port" || continue
    local url="http://$ip:$port"
    local tmpf; tmpf=$(mktemp)
    local code
    code=$(curl -sk --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" -o "$tmpf" -w "%{http_code}" "$url" 2>/dev/null)
    local title server powered cms ssl_info
    title=$(grep -oiP '(?<=<title>)[^<]+' "$tmpf" 2>/dev/null | head -1 | tr -d '\r\n' | sed 's/  */ /g' | cut -c1-60)
    local hdrs
    hdrs=$(curl -skI --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" "$url" 2>/dev/null)
    server=$(echo "$hdrs"  | grep -i "^server:"      | head -1 | awk -F': ' '{print $2}' | tr -d '\r\n' | cut -c1-28)
    powered=$(echo "$hdrs" | grep -i "^x-powered-by:"| head -1 | awk -F': ' '{print $2}' | tr -d '\r\n' | cut -c1-20)
    # Basic CMS/tech detection from body
    cms=""
    grep -qi "wp-content"         "$tmpf" 2>/dev/null && cms="WordPress"
    grep -qi "Drupal"             "$tmpf" 2>/dev/null && cms="Drupal"
    grep -qi "Joomla"             "$tmpf" 2>/dev/null && cms="Joomla"
    grep -qi "laravel"            "$tmpf" 2>/dev/null && cms="Laravel"
    grep -qi "django"             "$tmpf" 2>/dev/null && cms="Django"
    grep -qi "next.js\|__NEXT"   "$tmpf" 2>/dev/null && cms="Next.js"
    local tech="${powered:-${cms:-N/A}}"
    ssl_info="N/A"
    echo "HTTP|$ip|$port|$code|${title:-N/A}|${server:-Unknown}|${tech}|${ssl_info}" >> "$WEB_OUT"
    [[ "$VERBOSE" == "1" ]] && log_ok "[HTTP ] $ip:$port  $code  ${title:-N/A}  tech=$tech" >&2
    rm -f "$tmpf"
  done

  for port in 443 8443 4443 9443; do
    probe_port "$ip" "$port" || continue
    local url="https://$ip:$port"
    local tmpf; tmpf=$(mktemp)
    local code
    code=$(curl -sk --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" -o "$tmpf" -w "%{http_code}" "$url" 2>/dev/null)
    local title server powered cms
    title=$(grep -oiP '(?<=<title>)[^<]+' "$tmpf" 2>/dev/null | head -1 | tr -d '\r\n' | sed 's/  */ /g' | cut -c1-60)
    local hdrs
    hdrs=$(curl -skI --max-time "$TIMEOUT" --connect-timeout "$TIMEOUT" "$url" 2>/dev/null)
    server=$(echo "$hdrs"  | grep -i "^server:"       | head -1 | awk -F': ' '{print $2}' | tr -d '\r\n' | cut -c1-28)
    powered=$(echo "$hdrs" | grep -i "^x-powered-by:" | head -1 | awk -F': ' '{print $2}' | tr -d '\r\n' | cut -c1-20)
    cms=""
    grep -qi "wp-content"       "$tmpf" 2>/dev/null && cms="WordPress"
    grep -qi "Drupal"           "$tmpf" 2>/dev/null && cms="Drupal"
    grep -qi "Joomla"           "$tmpf" 2>/dev/null && cms="Joomla"
    grep -qi "laravel"          "$tmpf" 2>/dev/null && cms="Laravel"
    grep -qi "django"           "$tmpf" 2>/dev/null && cms="Django"
    grep -qi "next.js\|__NEXT" "$tmpf" 2>/dev/null && cms="Next.js"
    local tech="${powered:-${cms:-N/A}}"
    # SSL cert grab
    local ssl_info
    ssl_info=$(echo "" | timeout "$TIMEOUT" openssl s_client -connect "$ip:$port" -servername "$ip" 2>/dev/null \
      | openssl x509 -noout -subject -issuer -enddate 2>/dev/null \
      | awk -F'=' '/subject/{sub=""; for(i=2;i<=NF;i++) sub=sub$i"="; print sub} /enddate/{print "exp:"$2}' \
      | tr '\n' ' ' | cut -c1-60)
    [[ -z "$ssl_info" ]] && ssl_info="N/A"
    echo "HTTPS|$ip|$port|$code|${title:-N/A}|${server:-Unknown}|${tech}|${ssl_info}" >> "$WEB_OUT"
    [[ "$VERBOSE" == "1" ]] && log_ok "[HTTPS] $ip:$port  $code  ${title:-N/A}  ssl=$ssl_info" >&2
    rm -f "$tmpf"
  done
}

# ─── FTP Scan + Anon Check ───────────────────────────────────────────
scan_host_ftp() {
  local ip="$1"
  for port in 21 990; do
    probe_port "$ip" "$port" || continue
    local banner
    banner=$(echo "" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null | head -1 | tr -d '\r\n' | cut -c1-65)
    # Anonymous login check
    local anon="NO"
    local anon_resp
    anon_resp=$(printf "USER anonymous\r\nPASS pentest@pentest.com\r\nQUIT\r\n" \
      | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null | tr -d '\r')
    echo "$anon_resp" | grep -qE "^(230|331)" && anon="YES ⚠️"
    echo "$ip|$port|${banner:-No banner}|$anon" >> "$FTP_OUT"
    [[ "$VERBOSE" == "1" ]] && log_ok "[FTP   ] $ip:$port  anon=$anon  ${banner}" >&2
  done
}

# ─── TELNET Scan + Default Creds ─────────────────────────────────────
TELNET_DEFAULT_CREDS=("admin:admin" "root:root" "admin:" "root:" "user:user" "admin:1234" "admin:password")

scan_host_telnet() {
  local ip="$1"
  for port in 23 2323; do
    probe_port "$ip" "$port" || continue
    local banner
    banner=$(echo "" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null | strings | head -1 | tr -d '\r\n' | cut -c1-65)
    local found_cred="NONE"
    for cred in "${TELNET_DEFAULT_CREDS[@]}"; do
      local u="${cred%%:*}" p="${cred##*:}"
      local resp
      resp=$(printf "%s\r\n%s\r\n" "$u" "$p" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null | strings)
      if echo "$resp" | grep -qiE "(welcome|shell|\$|#|>)"; then
        found_cred="$cred ⚠️"
        break
      fi
    done
    echo "$ip|$port|${banner:-No banner}|$found_cred" >> "$TEL_OUT"
    [[ "$VERBOSE" == "1" ]] && log_ok "[TELNET] $ip:$port  creds=$found_cred  ${banner}" >&2
  done
}

# ─── SMB Scan ────────────────────────────────────────────────────────
scan_host_smb() {
  local ip="$1"
  for port in 445 139; do
    probe_port "$ip" "$port" || continue
    # Grab NetBIOS/SMB banner via nmap quick script if available, else nc
    local info
    info=$(nmap -sV -p "$port" --script=smb-os-discovery,banner -T4 --open "$ip" 2>/dev/null \
      | grep -E "OS:|Computer name:|NetBIOS|banner" | head -3 | tr '\n' ' ' | sed 's/|//g' | cut -c1-70)
    [[ -z "$info" ]] && info=$(echo "" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null | strings | head -1 | cut -c1-70)
    [[ -z "$info" ]] && info="Open"
    echo "$ip|$port|${info}" >> "$SMB_OUT"
    [[ "$VERBOSE" == "1" ]] && log_ok "[SMB   ] $ip:$port  $info" >&2
  done
}

# ─── RDP Scan ────────────────────────────────────────────────────────
scan_host_rdp() {
  local ip="$1"
  probe_port "$ip" 3389 || return
  # Detect OS hint from TTL
  local ttl os_hint
  ttl=$(ping -c1 -W1 "$ip" 2>/dev/null | grep -oP 'ttl=\K[0-9]+' | head -1)
  if   [[ "$ttl" -ge 120 && "$ttl" -le 128 ]] 2>/dev/null; then os_hint="Windows"
  elif [[ "$ttl" -ge 60  && "$ttl" -le 64  ]] 2>/dev/null; then os_hint="Linux"
  elif [[ "$ttl" -ge 250 && "$ttl" -le 255 ]] 2>/dev/null; then os_hint="Cisco/Network"
  else os_hint="Unknown (TTL:${ttl:-?})"; fi
  echo "$ip|3389|$os_hint" >> "$RDP_OUT"
  [[ "$VERBOSE" == "1" ]] && log_ok "[RDP   ] $ip:3389  OS hint=$os_hint" >&2
}

# ─── SSH Scan ────────────────────────────────────────────────────────
scan_host_ssh() {
  local ip="$1"
  probe_port "$ip" 22 || return
  local banner
  banner=$(echo "" | nc -w "$TIMEOUT" "$ip" 22 2>/dev/null | head -1 | tr -d '\r\n' | cut -c1-70)
  # Extract version
  local version
  version=$(echo "$banner" | grep -oP 'OpenSSH[_\s][^\s]+' | head -1)
  [[ -z "$version" ]] && version=$(echo "$banner" | cut -c1-40)
  echo "$ip|22|${version:-No banner}|${banner}" >> "$SSH_OUT"
  [[ "$VERBOSE" == "1" ]] && log_ok "[SSH   ] $ip:22  $version" >&2
}

# ─── DB Scan ─────────────────────────────────────────────────────────
declare -A DB_PORTS=([3306]="MySQL" [1433]="MSSQL" [5432]="PostgreSQL" [27017]="MongoDB" [6379]="Redis")

scan_host_db() {
  local ip="$1"
  for port in 3306 1433 5432 27017 6379; do
    probe_port "$ip" "$port" || continue
    local dbname="${DB_PORTS[$port]}"
    local banner
    banner=$(echo "" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null | strings | head -1 | tr -d '\r\n' | cut -c1-60)
    echo "$ip|$port|$dbname|${banner:-No banner}" >> "$DB_OUT"
    [[ "$VERBOSE" == "1" ]] && log_ok "[DB    ] $ip:$port  $dbname  ${banner}" >&2
  done
}

# ─── Parallel Engine ─────────────────────────────────────────────────
run_scan() {
  local ip_file="$1"
  local total; total=$(wc -l < "$ip_file" | tr -d ' ')
  local count=0 jobs=0

  while IFS= read -r ip; do
    [[ -z "$ip" ]] && continue
    (
      [[ "$DO_WEB"    == "1" ]] && scan_host_web    "$ip"
      [[ "$DO_FTP"    == "1" ]] && scan_host_ftp    "$ip"
      [[ "$DO_TELNET" == "1" ]] && scan_host_telnet "$ip"
      [[ "$DO_SMB"    == "1" ]] && scan_host_smb    "$ip"
      [[ "$DO_RDP"    == "1" ]] && scan_host_rdp    "$ip"
      [[ "$DO_SSH"    == "1" ]] && scan_host_ssh    "$ip"
      [[ "$DO_DB"     == "1" ]] && scan_host_db     "$ip"
    ) &
    ((jobs++))
    if [[ $jobs -ge $THREADS ]]; then wait; jobs=0; fi
    ((count++))
    local pct=$(( count * 100 / total ))
    local filled=$(( pct * 38 / 100 ))
    local bar="" k
    for ((k=0;k<filled;k++)); do bar+="█"; done
    for ((k=filled;k<38;k++)); do bar+="░"; done
    printf "\r  ${CYAN}[${GREEN}%s${GRAY}%s${CYAN}]${RESET} ${WHITE}%3d%%${RESET}  ${DIM}%d/%d${RESET}  %-22s" \
      "${bar:0:$filled}" "${bar:$filled}" "$pct" "$count" "$total" "${ip:0:22}"
  done < "$ip_file"
  wait
  printf "\r%-80s\r" " "
}

# ─── Safe Count ──────────────────────────────────────────────────────
safe_count() {
  local f="$1"
  [[ -f "$f" ]] && awk 'NF{c++}END{print c+0}' "$f" || echo 0
}

# ─── Terminal Tables ─────────────────────────────────────────────────
pad() { printf "%-${2}s" "$1" | cut -c1-"$2"; }

print_web_table() {
  mapfile -t WEB_RESULTS < "$WEB_OUT"
  [[ ${#WEB_RESULTS[@]} -eq 0 ]] && { log_warn "No Web assets found"; return; }
  log_section "🌐  WEB ASSETS  (HTTP / HTTPS)"
  echo ""
  printf "  ${BOLD}${BG_BLUE}  %-6s  %-17s  %-6s  %-4s  %-22s  %-18s  %-45s  ${RESET}\n" \
    "PROTO" "IP" "PORT" "CODE" "SERVER" "TECH/CMS" "TITLE"
  echo -e "  ${BLUE}$(printf '─%.0s' {1..127})${RESET}"
  for entry in "${WEB_RESULTS[@]}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r proto ip port code title server tech ssl <<< "$entry"
    local pc cc
    [[ "$proto" == "HTTPS" ]] && pc="${GREEN}" || pc="${BLUE}"
    case "${code:0:1}" in 2) cc="${GREEN}";; 3) cc="${YELLOW}";; 4) cc="${ORANGE}";; 5) cc="${RED}";; *) cc="${GRAY}";; esac
    printf "  ${pc}${BOLD}%-6s${RESET}  ${CYAN}%-17s${RESET}  ${YELLOW}%-6s${RESET}  ${cc}%-4s${RESET}  ${GRAY}%-22s${RESET}  ${PINK}%-18s${RESET}  ${WHITE}%-45s${RESET}\n" \
      "$proto" "$ip" "$port" "$code" "$(pad "$server" 22)" "$(pad "$tech" 18)" "$(pad "$title" 45)"
  done
  echo ""; echo -e "  ${GREEN}${BOLD} ✦ ${#WEB_RESULTS[@]} web service(s) found${RESET}"
}

print_web_ssl_table() {
  mapfile -t WEB_RESULTS < "$WEB_OUT"
  local https_entries=()
  for e in "${WEB_RESULTS[@]}"; do
    [[ "$e" == HTTPS* && "$e" != *"N/A"* ]] && https_entries+=("$e")
  done
  [[ ${#https_entries[@]} -eq 0 ]] && return
  log_section "🔒  SSL CERTIFICATES"
  echo ""
  printf "  ${BOLD}${BG_TEAL}  %-17s  %-6s  %-80s  ${RESET}\n" "IP" "PORT" "CERT INFO"
  echo -e "  ${CYAN}$(printf '─%.0s' {1..110})${RESET}"
  for entry in "${https_entries[@]}"; do
    IFS='|' read -r proto ip port code title server tech ssl <<< "$entry"
    printf "  ${CYAN}%-17s${RESET}  ${YELLOW}%-6s${RESET}  ${GREEN}%-80s${RESET}\n" "$ip" "$port" "$(pad "$ssl" 80)"
  done
  echo ""
}

print_ftp_table() {
  mapfile -t FTP_RESULTS < "$FTP_OUT"
  [[ ${#FTP_RESULTS[@]} -eq 0 ]] && { log_warn "No FTP assets found"; return; }
  log_section "📁  FTP ASSETS"
  echo ""
  printf "  ${BOLD}${BG_PURPLE}  %-18s  %-6s  %-8s  %-58s  ${RESET}\n" "IP" "PORT" "ANON?" "BANNER"
  echo -e "  ${PURPLE}$(printf '─%.0s' {1..100})${RESET}"
  for entry in "${FTP_RESULTS[@]}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r ip port banner anon <<< "$entry"
    local ac; [[ "$anon" == "YES"* ]] && ac="${RED}${BOLD}" || ac="${GREEN}"
    printf "  ${CYAN}%-18s${RESET}  ${YELLOW}%-6s${RESET}  ${ac}%-8s${RESET}  ${ORANGE}%-58s${RESET}\n" \
      "$ip" "$port" "$(pad "$anon" 8)" "$(pad "$banner" 58)"
  done
  echo ""; echo -e "  ${ORANGE}${BOLD} ✦ ${#FTP_RESULTS[@]} FTP service(s) found${RESET}"
}

print_telnet_table() {
  mapfile -t TEL_RESULTS < "$TEL_OUT"
  [[ ${#TEL_RESULTS[@]} -eq 0 ]] && { log_warn "No Telnet assets found"; return; }
  log_section "🖥️  TELNET ASSETS"
  echo ""
  printf "  ${BOLD}${BG_RED}  %-18s  %-6s  %-16s  %-52s  ${RESET}\n" "IP" "PORT" "DEFAULT CREDS" "BANNER"
  echo -e "  ${RED}$(printf '─%.0s' {1..100})${RESET}"
  for entry in "${TEL_RESULTS[@]}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r ip port banner creds <<< "$entry"
    local cc; [[ "$creds" != "NONE" ]] && cc="${RED}${BOLD}" || cc="${GREEN}"
    printf "  ${CYAN}%-18s${RESET}  ${YELLOW}%-6s${RESET}  ${cc}%-16s${RESET}  ${RED}%-52s${RESET}\n" \
      "$ip" "$port" "$(pad "$creds" 16)" "$(pad "$banner" 52)"
  done
  echo ""; echo -e "  ${RED}${BOLD} ✦ ${#TEL_RESULTS[@]} Telnet service(s) found${RESET}"
}

print_smb_table() {
  mapfile -t SMB_RESULTS < "$SMB_OUT"
  [[ ${#SMB_RESULTS[@]} -eq 0 ]] && { log_warn "No SMB assets found"; return; }
  log_section "🗂️  SMB / SAMBA ASSETS"
  echo ""
  printf "  ${BOLD}${BG_MAROON}  %-18s  %-6s  %-72s  ${RESET}\n" "IP" "PORT" "INFO"
  echo -e "  ${RED}$(printf '─%.0s' {1..103})${RESET}"
  for entry in "${SMB_RESULTS[@]}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r ip port info <<< "$entry"
    printf "  ${CYAN}%-18s${RESET}  ${YELLOW}%-6s${RESET}  ${PINK}%-72s${RESET}\n" "$ip" "$port" "$(pad "$info" 72)"
  done
  echo ""; echo -e "  ${PINK}${BOLD} ✦ ${#SMB_RESULTS[@]} SMB service(s) found${RESET}"
}

print_rdp_table() {
  mapfile -t RDP_RESULTS < "$RDP_OUT"
  [[ ${#RDP_RESULTS[@]} -eq 0 ]] && { log_warn "No RDP assets found"; return; }
  log_section "🖱️  RDP ASSETS"
  echo ""
  printf "  ${BOLD}${BG_NAVY}  %-18s  %-6s  %-30s  ${RESET}\n" "IP" "PORT" "OS HINT"
  echo -e "  ${BLUE}$(printf '─%.0s' {1..62})${RESET}"
  for entry in "${RDP_RESULTS[@]}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r ip port os <<< "$entry"
    printf "  ${CYAN}%-18s${RESET}  ${YELLOW}%-6s${RESET}  ${BLUE}%-30s${RESET}\n" "$ip" "$port" "$(pad "$os" 30)"
  done
  echo ""; echo -e "  ${BLUE}${BOLD} ✦ ${#RDP_RESULTS[@]} RDP service(s) found${RESET}"
}

print_ssh_table() {
  mapfile -t SSH_RESULTS < "$SSH_OUT"
  [[ ${#SSH_RESULTS[@]} -eq 0 ]] && { log_warn "No SSH assets found"; return; }
  log_section "🔑  SSH ASSETS"
  echo ""
  printf "  ${BOLD}${BG_DGRAY}  %-18s  %-6s  %-35s  ${RESET}\n" "IP" "PORT" "VERSION"
  echo -e "  ${GRAY}$(printf '─%.0s' {1..67})${RESET}"
  for entry in "${SSH_RESULTS[@]}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r ip port version banner <<< "$entry"
    printf "  ${CYAN}%-18s${RESET}  ${YELLOW}%-6s${RESET}  ${WHITE}%-35s${RESET}\n" "$ip" "$port" "$(pad "$version" 35)"
  done
  echo ""; echo -e "  ${WHITE}${BOLD} ✦ ${#SSH_RESULTS[@]} SSH service(s) found${RESET}"
}

print_db_table() {
  mapfile -t DB_RESULTS < "$DB_OUT"
  [[ ${#DB_RESULTS[@]} -eq 0 ]] && { log_warn "No DB assets found"; return; }
  log_section "🗄️  DATABASE ASSETS"
  echo ""
  printf "  ${BOLD}${BG_GREEN}  %-18s  %-6s  %-12s  %-52s  ${RESET}\n" "IP" "PORT" "DB TYPE" "BANNER"
  echo -e "  ${GREEN}$(printf '─%.0s' {1..97})${RESET}"
  for entry in "${DB_RESULTS[@]}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r ip port dbtype banner <<< "$entry"
    printf "  ${CYAN}%-18s${RESET}  ${YELLOW}%-6s${RESET}  ${GREEN}${BOLD}%-12s${RESET}  ${GRAY}%-52s${RESET}\n" \
      "$ip" "$port" "$(pad "$dbtype" 12)" "$(pad "$banner" 52)"
  done
  echo ""; echo -e "  ${GREEN}${BOLD} ✦ ${#DB_RESULTS[@]} database service(s) found${RESET}"
}

# ─── Summary ─────────────────────────────────────────────────────────
print_summary() {
  local elapsed=$(( $(date +%s) - START_TS ))
  local wc fc tc sc rc shc dc
  wc=$(safe_count "$WEB_OUT"); wc=${wc//[^0-9]/}; wc=$(( ${wc:-0} ))
  fc=$(safe_count "$FTP_OUT"); fc=${fc//[^0-9]/}; fc=$(( ${fc:-0} ))
  tc=$(safe_count "$TEL_OUT"); tc=${tc//[^0-9]/}; tc=$(( ${tc:-0} ))
  sc=$(safe_count "$SMB_OUT"); sc=${sc//[^0-9]/}; sc=$(( ${sc:-0} ))
  rc=$(safe_count "$RDP_OUT"); rc=${rc//[^0-9]/}; rc=$(( ${rc:-0} ))
  shc=$(safe_count "$SSH_OUT");shc=${shc//[^0-9]/};shc=$(( ${shc:-0} ))
  dc=$(safe_count "$DB_OUT");  dc=${dc//[^0-9]/};  dc=$(( ${dc:-0} ))
  local total_n=$(( TOTAL_IPS )); elapsed=$(( elapsed > 0 ? elapsed : 0 ))
  local total_findings=$(( wc+fc+tc+sc+rc+shc+dc ))

  log_section "📊  SCAN SUMMARY"
  echo ""
  echo -e "  ${GRAY}┌─────────────────────────────────────────────────┐${RESET}"
  echo -e "  ${GRAY}│${RESET}  ${WHITE}${BOLD}$(printf '%-26s' 'Hosts Scanned')${RESET}  ${CYAN}${BOLD}$(printf '%6d' "$total_n")${RESET}                ${GRAY}│${RESET}"
  echo -e "  ${GRAY}│${RESET}  ${DIM}$(printf '─%.0s' {1..44})${GRAY}│${RESET}"
  [[ "$DO_WEB"    == "1" ]] && echo -e "  ${GRAY}│${RESET}  ${BLUE}$(printf '%-26s' 'Web Services')${RESET}  ${GREEN}${BOLD}$(printf '%6d' "$wc")${RESET}                ${GRAY}│${RESET}"
  [[ "$DO_FTP"    == "1" ]] && echo -e "  ${GRAY}│${RESET}  ${ORANGE}$(printf '%-26s' 'FTP Services')${RESET}  ${GREEN}${BOLD}$(printf '%6d' "$fc")${RESET}                ${GRAY}│${RESET}"
  [[ "$DO_TELNET" == "1" ]] && echo -e "  ${GRAY}│${RESET}  ${RED}$(printf '%-26s' 'Telnet Services')${RESET}  ${GREEN}${BOLD}$(printf '%6d' "$tc")${RESET}                ${GRAY}│${RESET}"
  [[ "$DO_SMB"    == "1" ]] && echo -e "  ${GRAY}│${RESET}  ${PURPLE}$(printf '%-26s' 'SMB Services')${RESET}  ${GREEN}${BOLD}$(printf '%6d' "$sc")${RESET}                ${GRAY}│${RESET}"
  [[ "$DO_RDP"    == "1" ]] && echo -e "  ${GRAY}│${RESET}  ${PINK}$(printf '%-26s' 'RDP Services')${RESET}  ${GREEN}${BOLD}$(printf '%6d' "$rc")${RESET}                ${GRAY}│${RESET}"
  [[ "$DO_SSH"    == "1" ]] && echo -e "  ${GRAY}│${RESET}  ${YELLOW}$(printf '%-26s' 'SSH Services')${RESET}  ${GREEN}${BOLD}$(printf '%6d' "$shc")${RESET}                ${GRAY}│${RESET}"
  [[ "$DO_DB"     == "1" ]] && echo -e "  ${GRAY}│${RESET}  ${GREEN}$(printf '%-26s' 'Database Services')${RESET}  ${GREEN}${BOLD}$(printf '%6d' "$dc")${RESET}                ${GRAY}│${RESET}"
  echo -e "  ${GRAY}│${RESET}  ${DIM}$(printf '─%.0s' {1..44})${GRAY}│${RESET}"
  echo -e "  ${GRAY}│${RESET}  ${WHITE}${BOLD}$(printf '%-26s' 'Total Findings')${RESET}  ${YELLOW}${BOLD}$(printf '%6d' "$total_findings")${RESET}                ${GRAY}│${RESET}"
  echo -e "  ${GRAY}│${RESET}  ${DIM}$(printf '%-26s' 'Duration')${RESET}  ${YELLOW}$(printf '%5d' "$elapsed")s${RESET}                ${GRAY}│${RESET}"
  echo -e "  ${GRAY}└─────────────────────────────────────────────────┘${RESET}"
  echo ""
}

# ─── CSV Export ──────────────────────────────────────────────────────
export_csv() {
  local csvfile="$1"
  {
    echo "TYPE,IP,PORT,DETAIL1,DETAIL2,DETAIL3,DETAIL4"
    [[ -f "$WEB_OUT" ]] && awk -F'|' '{printf "WEB,%s,%s,%s,%s,%s,%s\n",$2,$3,$4,$5,$6,$7}' "$WEB_OUT"
    [[ -f "$FTP_OUT" ]] && awk -F'|' '{printf "FTP,%s,%s,ANON=%s,%s,,\n",$1,$2,$4,$3}' "$FTP_OUT"
    [[ -f "$TEL_OUT" ]] && awk -F'|' '{printf "TELNET,%s,%s,CREDS=%s,%s,,\n",$1,$2,$4,$3}' "$TEL_OUT"
    [[ -f "$SMB_OUT" ]] && awk -F'|' '{printf "SMB,%s,%s,%s,,,\n",$1,$2,$3}' "$SMB_OUT"
    [[ -f "$RDP_OUT" ]] && awk -F'|' '{printf "RDP,%s,%s,OS=%s,,,\n",$1,$2,$3}' "$RDP_OUT"
    [[ -f "$SSH_OUT" ]] && awk -F'|' '{printf "SSH,%s,%s,%s,,,\n",$1,$2,$3}' "$SSH_OUT"
    [[ -f "$DB_OUT"  ]] && awk -F'|' '{printf "DB,%s,%s,%s,%s,,\n",$1,$2,$3,$4}' "$DB_OUT"
  } > "$csvfile"
  log_ok "CSV saved → ${CYAN}$csvfile${RESET}"
}

# ─── HTML Report ─────────────────────────────────────────────────────
generate_html() {
  local htmlfile="$1"
  local wc fc tc sc rc shc dc elapsed
  wc=$(safe_count "$WEB_OUT");  wc=${wc//[^0-9]/};  wc=$(( ${wc:-0} ))
  fc=$(safe_count "$FTP_OUT");  fc=${fc//[^0-9]/};  fc=$(( ${fc:-0} ))
  tc=$(safe_count "$TEL_OUT");  tc=${tc//[^0-9]/};  tc=$(( ${tc:-0} ))
  sc=$(safe_count "$SMB_OUT");  sc=${sc//[^0-9]/};  sc=$(( ${sc:-0} ))
  rc=$(safe_count "$RDP_OUT");  rc=${rc//[^0-9]/};  rc=$(( ${rc:-0} ))
  shc=$(safe_count "$SSH_OUT"); shc=${shc//[^0-9]/};shc=$(( ${shc:-0} ))
  dc=$(safe_count "$DB_OUT");   dc=${dc//[^0-9]/};  dc=$(( ${dc:-0} ))
  elapsed=$(( $(date +%s) - START_TS ))
  local total_findings=$(( wc+fc+tc+sc+rc+shc+dc ))

  # ── Build JS data arrays ──────────────────────────────────────────
  build_js_array() {
    local file="$1" type="$2"
    [[ ! -f "$file" ]] && echo "[]" && return
    local entries=()
    case "$type" in
      web)
        while IFS='|' read -r proto ip port code title server tech ssl; do
          local esc_title esc_server esc_tech esc_ssl
          esc_title=$(echo "$title"  | sed 's/\\/\\\\/g;s/"/\\"/g;s/$//')
          esc_server=$(echo "$server"| sed 's/\\/\\\\/g;s/"/\\"/g;s/$//')
          esc_tech=$(echo "$tech"    | sed 's/\\/\\\\/g;s/"/\\"/g;s/$//')
          esc_ssl=$(echo "$ssl"      | sed 's/\\/\\\\/g;s/"/\\"/g;s/$//')
          entries+=("{\"proto\":\"$proto\",\"ip\":\"$ip\",\"port\":\"$port\",\"code\":\"$code\",\"title\":\"$esc_title\",\"server\":\"$esc_server\",\"tech\":\"$esc_tech\",\"ssl\":\"$esc_ssl\"}")
        done < "$file"
        ;;
      ftp)
        while IFS='|' read -r ip port banner anon; do
          local esc_banner; esc_banner=$(echo "$banner"|sed 's/\\/\\\\/g;s/"/\\"/g')
          local esc_anon;   esc_anon=$(echo "$anon"  |sed 's/\\/\\\\/g;s/"/\\"/g')
          entries+=("{\"ip\":\"$ip\",\"port\":\"$port\",\"banner\":\"$esc_banner\",\"anon\":\"$esc_anon\"}")
        done < "$file"
        ;;
      telnet)
        while IFS='|' read -r ip port banner creds; do
          local esc_banner; esc_banner=$(echo "$banner"|sed 's/\\/\\\\/g;s/"/\\"/g')
          local esc_creds;  esc_creds=$(echo "$creds" |sed 's/\\/\\\\/g;s/"/\\"/g')
          entries+=("{\"ip\":\"$ip\",\"port\":\"$port\",\"banner\":\"$esc_banner\",\"creds\":\"$esc_creds\"}")
        done < "$file"
        ;;
      smb)
        while IFS='|' read -r ip port info; do
          local esc_info; esc_info=$(echo "$info"|sed 's/\\/\\\\/g;s/"/\\"/g')
          entries+=("{\"ip\":\"$ip\",\"port\":\"$port\",\"info\":\"$esc_info\"}")
        done < "$file"
        ;;
      rdp)
        while IFS='|' read -r ip port os; do
          local esc_os; esc_os=$(echo "$os"|sed 's/\\/\\\\/g;s/"/\\"/g')
          entries+=("{\"ip\":\"$ip\",\"port\":\"$port\",\"os\":\"$esc_os\"}")
        done < "$file"
        ;;
      ssh)
        while IFS='|' read -r ip port version banner; do
          local esc_ver; esc_ver=$(echo "$version"|sed 's/\\/\\\\/g;s/"/\\"/g')
          entries+=("{\"ip\":\"$ip\",\"port\":\"$port\",\"version\":\"$esc_ver\"}")
        done < "$file"
        ;;
      db)
        while IFS='|' read -r ip port dbtype banner; do
          local esc_banner; esc_banner=$(echo "$banner"|sed 's/\\/\\\\/g;s/"/\\"/g')
          entries+=("{\"ip\":\"$ip\",\"port\":\"$port\",\"dbtype\":\"$dbtype\",\"banner\":\"$esc_banner\"}")
        done < "$file"
        ;;
    esac
    if [[ ${#entries[@]} -eq 0 ]]; then echo "[]"; return; fi
    local joined
    joined=$(printf '%s,' "${entries[@]}")
    echo "[${joined%,}]"
  }

  local js_web js_ftp js_tel js_smb js_rdp js_ssh js_db
  js_web=$(build_js_array "$WEB_OUT" "web")
  js_ftp=$(build_js_array "$FTP_OUT" "ftp")
  js_tel=$(build_js_array "$TEL_OUT" "telnet")
  js_smb=$(build_js_array "$SMB_OUT" "smb")
  js_rdp=$(build_js_array "$RDP_OUT" "rdp")
  js_ssh=$(build_js_array "$SSH_OUT" "ssh")
  js_db=$(build_js_array  "$DB_OUT"  "db")

  # ── Active sections list ──────────────────────────────────────────
  local active_sections="["
  [[ "$DO_WEB"    == "1" ]] && active_sections+="'web',"
  [[ "$DO_FTP"    == "1" ]] && active_sections+="'ftp',"
  [[ "$DO_TELNET" == "1" ]] && active_sections+="'telnet',"
  [[ "$DO_SMB"    == "1" ]] && active_sections+="'smb',"
  [[ "$DO_RDP"    == "1" ]] && active_sections+="'rdp',"
  [[ "$DO_SSH"    == "1" ]] && active_sections+="'ssh',"
  [[ "$DO_DB"     == "1" ]] && active_sections+="'db',"
  active_sections="${active_sections%,}]"

  cat > "$htmlfile" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>NetScout Report — ${SCAN_DATE}</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Inter:wght@300;400;500;600;700;800&display=swap');
:root {
  --bg:#0a0e1a;--bg2:#0f1423;--bg3:#141929;--card:#141d2e;
  --border:#1e2d45;--border2:#253550;
  --cyan:#22d3ee;--blue:#3b82f6;--purple:#a855f7;--pink:#ec4899;
  --green:#22c55e;--orange:#f97316;--red:#ef4444;--yellow:#eab308;--gray:#64748b;
  --text:#e2e8f0;--text2:#94a3b8;--text3:#64748b;
  --shadow:0 1px 3px rgba(0,0,0,.4);
}
body.light {
  --bg:#f1f5f9;--bg2:#ffffff;--bg3:#f8fafc;--card:#ffffff;
  --border:#e2e8f0;--border2:#cbd5e1;
  --text:#0f172a;--text2:#475569;--text3:#94a3b8;
  --shadow:0 1px 3px rgba(0,0,0,.1);
}
body.light .logo-ascii{background:linear-gradient(135deg,#7c3aed,#0891b2);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
body.light .header{background:linear-gradient(135deg,#f8fafc 0%,#f0f9ff 50%,#f5f3ff 100%)}
body.light .header::before{background:radial-gradient(ellipse 80% 60% at 50% -20%,rgba(8,145,178,.06),transparent)}
body.light .header-info h1{background:linear-gradient(90deg,#0891b2,#7c3aed);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
body.light .stats-bar{background:var(--border)}
body.light .stat{background:#fff}
body.light .stat:hover{background:#f8fafc}
body.light .stat.active{background:#f8fafc;box-shadow:inset 0 -2px 0 #0891b2}
body.light .toolbar{background:rgba(255,255,255,.9)}
body.light #globalSearch{background:#f8fafc;color:#0f172a}
body.light select{background:#f8fafc;color:#0f172a}
body.light tbody tr:hover{background:rgba(8,145,178,.04)}
body.light .btn-copy{background:rgba(8,145,178,.08);color:#0891b2;border-color:rgba(8,145,178,.2)}
body.light .btn-copy:hover{background:rgba(8,145,178,.15)}
body.light .btn-copy.copied{background:rgba(22,163,74,.08);color:#16a34a;border-color:rgba(22,163,74,.2)}
body.light .btn-export{background:rgba(124,58,237,.08);color:#7c3aed;border-color:rgba(124,58,237,.2)}
body.light .btn-export:hover{background:rgba(124,58,237,.15)}
body.light .tech-badge{background:rgba(124,58,237,.1);color:#7c3aed;border-color:rgba(124,58,237,.25)}
body.light .mono{color:#0891b2}
body.light .page-btn{background:#fff;border-color:var(--border);color:var(--text2)}
body.light .page-btn:hover:not(:disabled){background:var(--bg3)}
body.light .page-btn.active{background:rgba(8,145,178,.12);border-color:rgba(8,145,178,.4);color:#0891b2}
body.light #toast{background:#fff;border-color:var(--border2);color:var(--text)}
body.light .highlight{background:rgba(234,179,8,.3)}
body.light ::-webkit-scrollbar-thumb{background:var(--border2)}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Inter',sans-serif;background:var(--bg);color:var(--text);min-height:100vh}

/* Header */
.header{background:linear-gradient(135deg,#0a0e1a 0%,#0f1832 50%,#0a1628 100%);border-bottom:1px solid var(--border);padding:32px 48px 28px;position:relative;overflow:hidden}
.header::before{content:'';position:absolute;inset:0;background:radial-gradient(ellipse 80% 60% at 50% -20%,rgba(34,211,238,.08),transparent);pointer-events:none}
.header-grid{display:flex;align-items:center;gap:28px;position:relative}
.logo-ascii{font-family:'JetBrains Mono',monospace;font-size:8px;line-height:1.1;background:linear-gradient(135deg,var(--purple),var(--cyan));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;white-space:pre;flex-shrink:0}
.header-info h1{font-size:26px;font-weight:800;letter-spacing:-.5px;background:linear-gradient(90deg,var(--cyan),var(--purple));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.header-info p{color:var(--text2);font-size:13px;margin-top:5px}
.header-meta{margin-left:auto;text-align:right;flex-shrink:0}
.header-meta span{display:block;font-size:11px;color:var(--text3)}
.header-meta strong{color:var(--text2);font-size:13px}

/* Stats */
.stats-bar{display:grid;grid-template-columns:repeat(auto-fit,minmax(110px,1fr));gap:1px;background:var(--border);border-bottom:1px solid var(--border)}
.stat{background:var(--bg2);padding:16px 20px;text-align:center;cursor:pointer;transition:background .2s,transform .1s;user-select:none}
.stat:hover{background:var(--bg3)}
.stat.active{background:var(--bg3);box-shadow:inset 0 -2px 0 var(--cyan)}
.stat-val{font-size:24px;font-weight:800;font-family:'JetBrains Mono',monospace;display:block;line-height:1}
.stat-label{font-size:10px;color:var(--text3);text-transform:uppercase;letter-spacing:.06em;margin-top:4px}

/* Toolbar */
.toolbar{display:flex;align-items:center;gap:12px;padding:16px 48px;background:var(--bg2);border-bottom:1px solid var(--border);position:sticky;top:0;z-index:100;backdrop-filter:blur(8px)}
.search-wrap{position:relative;flex:1;max-width:400px}
.search-wrap svg{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--text3);pointer-events:none}
#globalSearch{width:100%;background:var(--bg3);border:1px solid var(--border2);border-radius:8px;padding:8px 12px 8px 36px;color:var(--text);font-size:13px;font-family:'Inter',sans-serif;outline:none;transition:border-color .2s}
#globalSearch:focus{border-color:var(--cyan)}
#globalSearch::placeholder{color:var(--text3)}
.toolbar-right{display:flex;gap:8px;margin-left:auto;align-items:center}
.match-count{font-size:12px;color:var(--text3);white-space:nowrap}
.page-size-wrap{display:flex;align-items:center;gap:8px;font-size:12px;color:var(--text3)}
select{background:var(--bg3);border:1px solid var(--border2);border-radius:6px;padding:6px 10px;color:var(--text);font-size:12px;outline:none;cursor:pointer}
select:focus{border-color:var(--cyan)}

/* Main */
.main{padding:24px 48px}

/* Section */
.section{margin-bottom:36px;display:none}
.section.visible{display:block}
.section-header{display:flex;align-items:center;gap:12px;margin-bottom:14px;padding-bottom:12px;border-bottom:1px solid var(--border)}
.section-icon{font-size:18px}
.section-title{font-size:15px;font-weight:700}
.section-count{margin-left:auto;background:var(--border);border-radius:20px;padding:2px 12px;font-size:11px;font-weight:600;font-family:'JetBrains Mono',monospace;color:var(--text2)}
.section-actions{display:flex;gap:8px}
.btn{display:inline-flex;align-items:center;gap:6px;padding:6px 14px;border-radius:6px;font-size:12px;font-weight:600;cursor:pointer;border:none;transition:all .15s;font-family:'Inter',sans-serif}
.btn-copy{background:rgba(34,211,238,.1);color:var(--cyan);border:1px solid rgba(34,211,238,.25)}
.btn-copy:hover{background:rgba(34,211,238,.2)}
.btn-copy.copied{background:rgba(34,197,94,.1);color:var(--green);border-color:rgba(34,197,94,.25)}
.btn-export{background:rgba(168,85,247,.1);color:var(--purple);border:1px solid rgba(168,85,247,.25)}
.btn-export:hover{background:rgba(168,85,247,.2)}
.btn-theme{background:rgba(234,179,8,.08);color:#ca8a04;border:1px solid rgba(234,179,8,.25);white-space:nowrap}
.btn-theme:hover{background:rgba(234,179,8,.15)}
body.light .btn-theme{background:rgba(15,23,42,.06);color:#334155;border-color:rgba(15,23,42,.15)}
body.light .btn-theme:hover{background:rgba(15,23,42,.1)}

/* Table */
.table-wrap{overflow-x:auto;border-radius:10px;border:1px solid var(--border)}
table{width:100%;border-collapse:collapse;font-size:13px}
thead th{background:var(--bg3);padding:10px 14px;text-align:left;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.07em;color:var(--text3);border-bottom:1px solid var(--border);white-space:nowrap;user-select:none;cursor:pointer}
thead th:hover{color:var(--text2)}
thead th .sort-icon{margin-left:4px;opacity:.4;font-style:normal}
thead th.sorted .sort-icon{opacity:1;color:var(--cyan)}
tbody tr{border-bottom:1px solid var(--border);transition:background .12s}
tbody tr:last-child{border-bottom:none}
tbody tr:hover{background:rgba(34,211,238,.04)}
tbody td{padding:10px 14px;color:var(--text);vertical-align:middle}
.mono{font-family:'JetBrains Mono',monospace;font-size:12px;color:var(--cyan)}
.badge{display:inline-block;padding:2px 8px;border-radius:4px;font-size:11px;font-weight:700;font-family:'JetBrains Mono',monospace;color:#fff;letter-spacing:.05em}
.tech-badge{display:inline-block;padding:2px 8px;border-radius:4px;font-size:11px;background:rgba(168,85,247,.15);color:var(--purple);border:1px solid rgba(168,85,247,.3)}
.ssl-cell{font-size:11px;color:var(--text3);max-width:200px;word-break:break-all}
.highlight{background:rgba(234,179,8,.25);border-radius:2px;padding:0 1px}
.empty-state{text-align:center;padding:40px;color:var(--text3);font-size:13px}
.no-results{display:none;text-align:center;padding:32px;color:var(--text3);font-size:13px}

/* Pagination */
.pagination{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;border-top:1px solid var(--border);background:var(--bg3);border-radius:0 0 10px 10px}
.pagination-info{font-size:12px;color:var(--text3)}
.pagination-controls{display:flex;gap:4px;align-items:center}
.page-btn{background:var(--bg2);border:1px solid var(--border);border-radius:6px;padding:5px 10px;font-size:12px;color:var(--text2);cursor:pointer;transition:all .15s;font-family:'Inter',sans-serif;min-width:32px;text-align:center}
.page-btn:hover:not(:disabled){background:var(--border);color:var(--text)}
.page-btn.active{background:rgba(34,211,238,.15);border-color:rgba(34,211,238,.4);color:var(--cyan);font-weight:700}
.page-btn:disabled{opacity:.3;cursor:not-allowed}
.page-btn.ellipsis{border:none;background:transparent;cursor:default;pointer-events:none}

/* Copy toast */
#toast{position:fixed;bottom:24px;right:24px;background:#1e293b;border:1px solid var(--border2);border-radius:8px;padding:12px 20px;font-size:13px;color:var(--text);z-index:9999;transform:translateY(80px);opacity:0;transition:all .3s;display:flex;align-items:center;gap:10px}
#toast.show{transform:translateY(0);opacity:1}
#toast.success{border-color:rgba(34,197,94,.4);color:var(--green)}

/* Footer */
.footer{text-align:center;padding:20px;border-top:1px solid var(--border);color:var(--text3);font-size:12px;margin-top:16px}
.footer a{color:var(--cyan);text-decoration:none}
::-webkit-scrollbar{width:6px;height:6px}
::-webkit-scrollbar-track{background:var(--bg)}
::-webkit-scrollbar-thumb{background:var(--border2);border-radius:3px}
</style>
</head>
<body>

<div class="header">
  <div class="header-grid">
    <pre class="logo-ascii"> ███╗   ██╗███████╗████████╗███████╗ ██████╗ ██████╗ ████████╗
 ████╗  ██║██╔════╝╚══██╔══╝██╔════╝██╔════╝██╔═══██╗╚══██╔══╝
 ██╔██╗ ██║█████╗     ██║   ███████╗██║     ██║   ██║   ██║   
 ██║╚██╗██║██╔══╝     ██║   ╚════██║██║     ██║   ██║   ██║   
 ██║ ╚████║███████╗   ██║   ███████║╚██████╗╚██████╔╝   ██║   
 ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═════╝    ╚═╝  </pre>
    <div class="header-info">
      <h1>Pentest Asset Discovery Report</h1>
      <p>Internal Network Reconnaissance — NetScout v${VERSION}</p>
    </div>
    <div class="header-meta">
      <span>Generated</span><strong>${SCAN_DATE}</strong>
      <span style="margin-top:8px">Hosts Scanned</span><strong>${TOTAL_IPS}</strong>
      <span style="margin-top:8px">Duration</span><strong>${elapsed}s</strong>
    </div>
  </div>
</div>

<div class="stats-bar" id="statsBar">
  <div class="stat" data-section="all" onclick="filterSection('all')">
    <span class="stat-val" style="color:var(--cyan)">${total_findings}</span>
    <span class="stat-label">All</span>
  </div>
  <div class="stat" data-section="web" onclick="filterSection('web')" style="display:$( [[ "$DO_WEB"    == "1" ]] && echo block || echo none )">
    <span class="stat-val" style="color:var(--blue)">${wc}</span>
    <span class="stat-label">Web</span>
  </div>
  <div class="stat" data-section="ftp" onclick="filterSection('ftp')" style="display:$( [[ "$DO_FTP"    == "1" ]] && echo block || echo none )">
    <span class="stat-val" style="color:var(--orange)">${fc}</span>
    <span class="stat-label">FTP</span>
  </div>
  <div class="stat" data-section="telnet" onclick="filterSection('telnet')" style="display:$( [[ "$DO_TELNET" == "1" ]] && echo block || echo none )">
    <span class="stat-val" style="color:var(--red)">${tc}</span>
    <span class="stat-label">Telnet</span>
  </div>
  <div class="stat" data-section="smb" onclick="filterSection('smb')" style="display:$( [[ "$DO_SMB"    == "1" ]] && echo block || echo none )">
    <span class="stat-val" style="color:var(--purple)">${sc}</span>
    <span class="stat-label">SMB</span>
  </div>
  <div class="stat" data-section="rdp" onclick="filterSection('rdp')" style="display:$( [[ "$DO_RDP"    == "1" ]] && echo block || echo none )">
    <span class="stat-val" style="color:var(--pink)">${rc}</span>
    <span class="stat-label">RDP</span>
  </div>
  <div class="stat" data-section="ssh" onclick="filterSection('ssh')" style="display:$( [[ "$DO_SSH"    == "1" ]] && echo block || echo none )">
    <span class="stat-val" style="color:var(--yellow)">${shc}</span>
    <span class="stat-label">SSH</span>
  </div>
  <div class="stat" data-section="db" onclick="filterSection('db')" style="display:$( [[ "$DO_DB"     == "1" ]] && echo block || echo none )">
    <span class="stat-val" style="color:var(--green)">${dc}</span>
    <span class="stat-label">DB</span>
  </div>
</div>

<div class="toolbar">
  <div class="search-wrap">
    <svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
      <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
    </svg>
    <input type="text" id="globalSearch" placeholder="Search IPs, ports, banners, tech..." autocomplete="off">
  </div>
  <span class="match-count" id="matchCount"></span>
  <div class="toolbar-right">
    <div class="page-size-wrap">
      <label for="pageSize">Rows per page</label>
      <select id="pageSize">
        <option value="25">25</option>
        <option value="50" selected>50</option>
        <option value="100">100</option>
        <option value="250">250</option>
        <option value="99999">All</option>
      </select>
    </div>
    <button class="btn btn-theme" id="themeToggle" onclick="toggleTheme()" title="Toggle light/dark mode">
      <span id="themeIcon">☀️</span> <span id="themeLabel">Light</span>
    </button>
  </div>
</div>

<div class="main" id="main">
HTMLEOF

  # ── Section template helper (write directly to file) ──────────────
  write_section() {
    local id="$1" icon="$2" title="$3" color="$4" count="$5" copy_label="$6" thead="$7"
    cat >> "$htmlfile" << SECEOF
<div class="section" id="sec-${id}" data-section="${id}">
  <div class="section-header">
    <span class="section-icon">${icon}</span>
    <span class="section-title" style="color:${color}">${title}</span>
    <span class="section-count" id="cnt-${id}">${count} found</span>
    <div class="section-actions">
      <button class="btn btn-copy" id="copy-ip-${id}" onclick="copyColumn('${id}','ip')">
        <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
        Copy IPs
      </button>
      <button class="btn btn-copy" id="copy-all-${id}" onclick="copyAll('${id}')">
        <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
        Copy All
      </button>
      <button class="btn btn-export" onclick="exportSection('${id}')">
        <svg width="12" height="12" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        Export CSV
      </button>
    </div>
  </div>
  <div class="table-wrap">
    <table id="tbl-${id}">
      <thead><tr>${thead}</tr></thead>
      <tbody id="tbody-${id}"></tbody>
    </table>
    <div class="no-results" id="no-${id}">No results match your search</div>
    <div class="pagination" id="pg-${id}"></div>
  </div>
</div>
SECEOF
  }

  [[ "$DO_WEB"    == "1" ]] && write_section "web"    "🌐" "Web Assets (HTTP / HTTPS)" "var(--blue)"   "${wc}"  "IPs" \
    "<th onclick=\"sortTable('web',0)\">Proto <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('web',1)\">IP <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('web',2)\">Port <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('web',3)\">Code <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('web',4)\">Server <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('web',5)\">Tech/CMS <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('web',6)\">Title <i class='sort-icon'>⇅</i></th><th>SSL Info</th>"

  [[ "$DO_FTP"    == "1" ]] && write_section "ftp"    "📁" "FTP Assets"                "var(--orange)" "${fc}"  "IPs" \
    "<th onclick=\"sortTable('ftp',0)\">IP <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('ftp',1)\">Port <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('ftp',2)\">Anon Login <i class='sort-icon'>⇅</i></th><th>Banner</th>"

  [[ "$DO_TELNET" == "1" ]] && write_section "telnet" "🖥️" "Telnet Assets"             "var(--red)"    "${tc}"  "IPs" \
    "<th onclick=\"sortTable('telnet',0)\">IP <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('telnet',1)\">Port <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('telnet',2)\">Default Creds <i class='sort-icon'>⇅</i></th><th>Banner</th>"

  [[ "$DO_SMB"    == "1" ]] && write_section "smb"    "🗂️" "SMB / Samba Assets"       "var(--purple)" "${sc}"  "IPs" \
    "<th onclick=\"sortTable('smb',0)\">IP <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('smb',1)\">Port <i class='sort-icon'>⇅</i></th><th>Info</th>"

  [[ "$DO_RDP"    == "1" ]] && write_section "rdp"    "🖱️" "RDP Assets"               "var(--pink)"   "${rc}"  "IPs" \
    "<th onclick=\"sortTable('rdp',0)\">IP <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('rdp',1)\">Port <i class='sort-icon'>⇅</i></th><th>OS Hint (TTL)</th>"

  [[ "$DO_SSH"    == "1" ]] && write_section "ssh"    "🔑" "SSH Assets"               "var(--yellow)" "${shc}" "IPs" \
    "<th onclick=\"sortTable('ssh',0)\">IP <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('ssh',1)\">Port <i class='sort-icon'>⇅</i></th><th>Version / Banner</th>"

  [[ "$DO_DB"     == "1" ]] && write_section "db"     "🗄️" "Database Assets"          "var(--green)"  "${dc}"  "IPs" \
    "<th onclick=\"sortTable('db',0)\">IP <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('db',1)\">Port <i class='sort-icon'>⇅</i></th><th onclick=\"sortTable('db',2)\">DB Type <i class='sort-icon'>⇅</i></th><th>Banner</th>"

  # Write closing HTML + inject JS data safely (no heredoc expansion issues)
  {
    printf '</div><!-- /main -->\n'
    printf '<div id="toast"><svg width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg><span id="toast-msg">Copied!</span></div>\n'
    printf '<div class="footer">Generated by <strong>NetScout v%s</strong> &mdash; <a href="https://pentester.ma" target="_blank">pentester.ma</a> | Fahd &nbsp;&middot;&nbsp; %s</div>\n' \
      "$VERSION" "$SCAN_DATE"
    printf '<script>\n'
    printf 'const RAW = {\n'
    printf '  web:    %s,\n'    "$js_web"
    printf '  ftp:    %s,\n'    "$js_ftp"
    printf '  telnet: %s,\n'    "$js_tel"
    printf '  smb:    %s,\n'    "$js_smb"
    printf '  rdp:    %s,\n'    "$js_rdp"
    printf '  ssh:    %s,\n'    "$js_ssh"
    printf '  db:     %s\n'     "$js_db"
    printf '};\n'
    printf 'const ACTIVE = %s;\n' "$active_sections"
  } >> "$htmlfile"

  # Append JS engine — base64-embedded, no external file needed
  base64 -d >> "$htmlfile" << 'B64JSEOF'
Ci8vIOKUgOKUgCBTdGF0ZSDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAKY29uc3Qgc3RhdGUgPSB7fTsKQUNUSVZFLmZvckVhY2gocyA9PiB7CiAgc3RhdGVbc10gPSB7IHBhZ2U6IDEsIHBhZ2VTaXplOiA1MCwgcXVlcnk6ICcnLCBzb3J0Q29sOiAtMSwgc29ydERpcjogMSwgZmlsdGVyZWQ6IFsuLi5SQVdbc11dIH07Cn0pOwoKLy8g4pSA4pSAIEhlbHBlcnMg4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSACmZ1bmN0aW9uIGVzYyhzKSB7CiAgcmV0dXJuIFN0cmluZyhzfHwnJykucmVwbGFjZSgvJi9nLCcmYW1wOycpLnJlcGxhY2UoLzwvZywnJmx0OycpLnJlcGxhY2UoLz4vZywnJmd0OycpLnJlcGxhY2UoLyIvZywnJnF1b3Q7Jyk7Cn0KZnVuY3Rpb24gaGwodGV4dCwgcSkgewogIGlmICghcSB8fCAhdGV4dCkgcmV0dXJuIGVzYyh0ZXh0IHx8ICcnKTsKICBjb25zdCBlc2NhcGVkID0gZXNjKHRleHQpOwogIGNvbnN0IHJlID0gbmV3IFJlZ0V4cCgnKCcgKyBxLnJlcGxhY2UoL1suKis/XiR7fSgpfFtcXVxcXS9nLCdcXCQmJykgKyAnKScsICdnaScpOwogIHJldHVybiBlc2NhcGVkLnJlcGxhY2UocmUsICI8bWFyayBjbGFzcz0naGlnaGxpZ2h0Jz4kMTwvbWFyaz4iKTsKfQoKLy8g4pSA4pSAIFJlbmRlcmVycyDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAKY29uc3QgUkVOREVSRVJTID0gewogIHdlYihyb3csIHEpIHsKICAgIGNvbnN0IGJjID0gcm93LnByb3RvID09PSAnSFRUUFMnID8gJyMyMmM1NWUnIDogJyMzYjgyZjYnOwogICAgY29uc3QgY2MgPSB7MjonIzIyYzU1ZScsMzonI2ZhY2MxNScsNDonI2Y5NzMxNicsNTonI2VmNDQ0NCd9W3Jvdy5jb2RlWzBdXSB8fCAnIzZiNzI4MCc7CiAgICBjb25zdCB0ZWNoID0gcm93LnRlY2ggJiYgcm93LnRlY2ggIT09ICdOL0EnCiAgICAgID8gYDxzcGFuIGNsYXNzPSd0ZWNoLWJhZGdlJz4ke2hsKHJvdy50ZWNoLHEpfTwvc3Bhbj5gCiAgICAgIDogJzxzcGFuIHN0eWxlPSJjb2xvcjp2YXIoLS10ZXh0MykiPuKAlDwvc3Bhbj4nOwogICAgcmV0dXJuIGA8dHIgZGF0YS1pcD0iJHtlc2Mocm93LmlwKX0iPgogICAgICA8dGQ+PHNwYW4gY2xhc3M9J2JhZGdlJyBzdHlsZT0nYmFja2dyb3VuZDoke2JjfSc+JHtobChyb3cucHJvdG8scSl9PC9zcGFuPjwvdGQ+CiAgICAgIDx0ZCBjbGFzcz0nbW9ubyc+JHtobChyb3cuaXAscSl9PC90ZD4KICAgICAgPHRkIGNsYXNzPSdtb25vJz4ke2hsKHJvdy5wb3J0LHEpfTwvdGQ+CiAgICAgIDx0ZD48c3BhbiBzdHlsZT0nY29sb3I6JHtjY307Zm9udC13ZWlnaHQ6NzAwJz4ke2hsKHJvdy5jb2RlLHEpfTwvc3Bhbj48L3RkPgogICAgICA8dGQgc3R5bGU9J2NvbG9yOnZhcigtLXRleHQyKSc+JHtobChyb3cuc2VydmVyLHEpfTwvdGQ+CiAgICAgIDx0ZD4ke3RlY2h9PC90ZD4KICAgICAgPHRkIHN0eWxlPSdjb2xvcjp2YXIoLS10ZXh0MiknPiR7aGwocm93LnRpdGxlLHEpfTwvdGQ+CiAgICAgIDx0ZCBjbGFzcz0nc3NsLWNlbGwnPiR7aGwocm93LnNzbCxxKX08L3RkPgogICAgPC90cj5gOwogIH0sCiAgZnRwKHJvdywgcSkgewogICAgY29uc3QgYVN0eWxlID0gKHJvdy5hbm9ufHwnJykuc3RhcnRzV2l0aCgnWUVTJykgPyAnY29sb3I6I2VmNDQ0NDtmb250LXdlaWdodDo3MDAnIDogJ2NvbG9yOiMyMmM1NWUnOwogICAgcmV0dXJuIGA8dHIgZGF0YS1pcD0iJHtlc2Mocm93LmlwKX0iPgogICAgICA8dGQgY2xhc3M9J21vbm8nPiR7aGwocm93LmlwLHEpfTwvdGQ+CiAgICAgIDx0ZCBjbGFzcz0nbW9ubyc+JHtobChyb3cucG9ydCxxKX08L3RkPgogICAgICA8dGQgc3R5bGU9JyR7YVN0eWxlfSc+JHtobChyb3cuYW5vbixxKX08L3RkPgogICAgICA8dGQgc3R5bGU9J2NvbG9yOnZhcigtLXRleHQyKSc+JHtobChyb3cuYmFubmVyLHEpfTwvdGQ+CiAgICA8L3RyPmA7CiAgfSwKICB0ZWxuZXQocm93LCBxKSB7CiAgICBjb25zdCBjU3R5bGUgPSByb3cuY3JlZHMgIT09ICdOT05FJyA/ICdjb2xvcjojZWY0NDQ0O2ZvbnQtd2VpZ2h0OjcwMCcgOiAnY29sb3I6IzIyYzU1ZSc7CiAgICByZXR1cm4gYDx0ciBkYXRhLWlwPSIke2VzYyhyb3cuaXApfSI+CiAgICAgIDx0ZCBjbGFzcz0nbW9ubyc+JHtobChyb3cuaXAscSl9PC90ZD4KICAgICAgPHRkIGNsYXNzPSdtb25vJz4ke2hsKHJvdy5wb3J0LHEpfTwvdGQ+CiAgICAgIDx0ZCBzdHlsZT0nJHtjU3R5bGV9Jz4ke2hsKHJvdy5jcmVkcyxxKX08L3RkPgogICAgICA8dGQgc3R5bGU9J2NvbG9yOnZhcigtLXRleHQyKSc+JHtobChyb3cuYmFubmVyLHEpfTwvdGQ+CiAgICA8L3RyPmA7CiAgfSwKICBzbWIocm93LCBxKSB7CiAgICByZXR1cm4gYDx0ciBkYXRhLWlwPSIke2VzYyhyb3cuaXApfSI+CiAgICAgIDx0ZCBjbGFzcz0nbW9ubyc+JHtobChyb3cuaXAscSl9PC90ZD4KICAgICAgPHRkIGNsYXNzPSdtb25vJz4ke2hsKHJvdy5wb3J0LHEpfTwvdGQ+CiAgICAgIDx0ZCBzdHlsZT0nY29sb3I6dmFyKC0tdGV4dDIpJz4ke2hsKHJvdy5pbmZvLHEpfTwvdGQ+CiAgICA8L3RyPmA7CiAgfSwKICByZHAocm93LCBxKSB7CiAgICByZXR1cm4gYDx0ciBkYXRhLWlwPSIke2VzYyhyb3cuaXApfSI+CiAgICAgIDx0ZCBjbGFzcz0nbW9ubyc+JHtobChyb3cuaXAscSl9PC90ZD4KICAgICAgPHRkIGNsYXNzPSdtb25vJz4ke2hsKHJvdy5wb3J0LHEpfTwvdGQ+CiAgICAgIDx0ZCBzdHlsZT0nY29sb3I6dmFyKC0tdGV4dDIpJz4ke2hsKHJvdy5vcyxxKX08L3RkPgogICAgPC90cj5gOwogIH0sCiAgc3NoKHJvdywgcSkgewogICAgcmV0dXJuIGA8dHIgZGF0YS1pcD0iJHtlc2Mocm93LmlwKX0iPgogICAgICA8dGQgY2xhc3M9J21vbm8nPiR7aGwocm93LmlwLHEpfTwvdGQ+CiAgICAgIDx0ZCBjbGFzcz0nbW9ubyc+JHtobChyb3cucG9ydCxxKX08L3RkPgogICAgICA8dGQgc3R5bGU9J2NvbG9yOnZhcigtLXRleHQyKSc+JHtobChyb3cudmVyc2lvbixxKX08L3RkPgogICAgPC90cj5gOwogIH0sCiAgZGIocm93LCBxKSB7CiAgICByZXR1cm4gYDx0ciBkYXRhLWlwPSIke2VzYyhyb3cuaXApfSI+CiAgICAgIDx0ZCBjbGFzcz0nbW9ubyc+JHtobChyb3cuaXAscSl9PC90ZD4KICAgICAgPHRkIGNsYXNzPSdtb25vJz4ke2hsKHJvdy5wb3J0LHEpfTwvdGQ+CiAgICAgIDx0ZD48c3BhbiBjbGFzcz0nYmFkZ2UnIHN0eWxlPSdiYWNrZ3JvdW5kOiMxNmEzNGEnPiR7aGwocm93LmRidHlwZSxxKX08L3NwYW4+PC90ZD4KICAgICAgPHRkIHN0eWxlPSdjb2xvcjp2YXIoLS10ZXh0MiknPiR7aGwocm93LmJhbm5lcixxKX08L3RkPgogICAgPC90cj5gOwogIH0KfTsKCi8vIOKUgOKUgCBGaWx0ZXIg4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSACmZ1bmN0aW9uIGdldFJvd1RleHQocywgcm93KSB7IHJldHVybiBPYmplY3QudmFsdWVzKHJvdykuam9pbignICcpLnRvTG93ZXJDYXNlKCk7IH0KCmZ1bmN0aW9uIGFwcGx5RmlsdGVyKHMpIHsKICBjb25zdCBxID0gc3RhdGVbc10ucXVlcnkudG9Mb3dlckNhc2UoKTsKICBzdGF0ZVtzXS5maWx0ZXJlZCA9IFJBV1tzXS5maWx0ZXIociA9PiAhcSB8fCBnZXRSb3dUZXh0KHMscikuaW5jbHVkZXMocSkpOwogIGlmIChzdGF0ZVtzXS5zb3J0Q29sID49IDApIHsKICAgIGNvbnN0IGtleXMgPSBPYmplY3Qua2V5cyhSQVdbc11bMF0gfHwge30pOwogICAgY29uc3Qga2V5ICA9IGtleXNbc3RhdGVbc10uc29ydENvbF07CiAgICBpZiAoa2V5KSB7CiAgICAgIHN0YXRlW3NdLmZpbHRlcmVkLnNvcnQoKGEsIGIpID0+IHsKICAgICAgICBjb25zdCBhdiA9IFN0cmluZyhhW2tleV18fCcnKS50b0xvd2VyQ2FzZSgpOwogICAgICAgIGNvbnN0IGJ2ID0gU3RyaW5nKGJba2V5XXx8JycpLnRvTG93ZXJDYXNlKCk7CiAgICAgICAgcmV0dXJuIGF2IDwgYnYgPyAtc3RhdGVbc10uc29ydERpciA6IGF2ID4gYnYgPyBzdGF0ZVtzXS5zb3J0RGlyIDogMDsKICAgICAgfSk7CiAgICB9CiAgfQogIHN0YXRlW3NdLnBhZ2UgPSAxOwp9CgovLyDilIDilIAgUmVuZGVyIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgApmdW5jdGlvbiByZW5kZXJTZWN0aW9uKHMpIHsKICBjb25zdCBzdCAgICA9IHN0YXRlW3NdOwogIGNvbnN0IHRib2R5ID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ3Rib2R5LScgKyBzKTsKICBjb25zdCBub1JlcyA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCduby0nICsgcyk7CiAgY29uc3QgcGdFbCAgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgncGctJyAgKyBzKTsKICBjb25zdCBjbnRFbCA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdjbnQtJyArIHMpOwogIGlmICghdGJvZHkpIHJldHVybjsKCiAgY29uc3QgZmlsdGVyZWQgPSBzdC5maWx0ZXJlZDsKICBjb25zdCB0b3RhbCAgICA9IGZpbHRlcmVkLmxlbmd0aDsKICBjb25zdCBwcyAgICAgICA9IHN0LnBhZ2VTaXplOwogIGNvbnN0IHBhZ2UgICAgID0gc3QucGFnZTsKICBjb25zdCBzdGFydCAgICA9IChwYWdlLTEpKnBzOwogIGNvbnN0IGVuZCAgICAgID0gTWF0aC5taW4oc3RhcnQrcHMsIHRvdGFsKTsKICBjb25zdCBwYWdlRGF0YSA9IGZpbHRlcmVkLnNsaWNlKHN0YXJ0LCBlbmQpOwogIGNvbnN0IHEgICAgICAgID0gc3QucXVlcnk7CgogIGlmICh0b3RhbCA9PT0gMCkgewogICAgdGJvZHkuaW5uZXJIVE1MID0gJyc7CiAgICBub1Jlcy5zdHlsZS5kaXNwbGF5ID0gJ2Jsb2NrJzsKICB9IGVsc2UgewogICAgbm9SZXMuc3R5bGUuZGlzcGxheSA9ICdub25lJzsKICAgIHRib2R5LmlubmVySFRNTCA9IHBhZ2VEYXRhLm1hcChyID0+IFJFTkRFUkVSU1tzXShyLCBxKSkuam9pbignJyk7CiAgfQogIGlmIChjbnRFbCkgY250RWwudGV4dENvbnRlbnQgPSBxID8gYCR7dG90YWx9IC8gJHtSQVdbc10ubGVuZ3RofSBmb3VuZGAgOiBgJHtSQVdbc10ubGVuZ3RofSBmb3VuZGA7CiAgcmVuZGVyUGFnaW5hdGlvbihzLCB0b3RhbCwgcGFnZSwgcHMsIHBnRWwpOwp9CgpmdW5jdGlvbiByZW5kZXJQYWdpbmF0aW9uKHMsIHRvdGFsLCBwYWdlLCBwcywgZWwpIHsKICBpZiAoIWVsKSByZXR1cm47CiAgaWYgKHBzID49IDk5OTk5IHx8IHRvdGFsIDw9IHBzKSB7IGVsLnN0eWxlLmRpc3BsYXkgPSAnbm9uZSc7IHJldHVybjsgfQogIGVsLnN0eWxlLmRpc3BsYXkgPSAnZmxleCc7CiAgY29uc3QgcGFnZXMgPSBNYXRoLmNlaWwodG90YWwvcHMpOwogIGNvbnN0IHN0YXJ0ID0gKHBhZ2UtMSkqcHMrMTsKICBjb25zdCBlbmQgICA9IE1hdGgubWluKHBhZ2UqcHMsIHRvdGFsKTsKCiAgbGV0IGh0bWwgPSBgPHNwYW4gY2xhc3M9InBhZ2luYXRpb24taW5mbyI+U2hvd2luZyAke3N0YXJ0fSZuZGFzaDske2VuZH0gb2YgJHt0b3RhbH08L3NwYW4+PGRpdiBjbGFzcz0icGFnaW5hdGlvbi1jb250cm9scyI+YDsKICBodG1sICs9IGA8YnV0dG9uIGNsYXNzPSJwYWdlLWJ0biIgb25jbGljaz0iZ29QYWdlKCcke3N9JywxKSIgJHtwYWdlPT09MT8nZGlzYWJsZWQnOicnfT7CqzwvYnV0dG9uPmA7CiAgaHRtbCArPSBgPGJ1dHRvbiBjbGFzcz0icGFnZS1idG4iIG9uY2xpY2s9ImdvUGFnZSgnJHtzfScsJHtwYWdlLTF9KSIgJHtwYWdlPT09MT8nZGlzYWJsZWQnOicnfT7igLk8L2J1dHRvbj5gOwogIGxldCBwYWdlTnVtcyA9IG5ldyBTZXQoWzEsIHBhZ2VzXSk7CiAgZm9yIChsZXQgaSA9IE1hdGgubWF4KDIscGFnZS0yKTsgaSA8PSBNYXRoLm1pbihwYWdlcy0xLHBhZ2UrMik7IGkrKykgcGFnZU51bXMuYWRkKGkpOwogIGNvbnN0IHNvcnRlZCA9IFsuLi5wYWdlTnVtc10uc29ydCgoYSxiKT0+YS1iKTsKICBsZXQgcHJldiA9IDA7CiAgc29ydGVkLmZvckVhY2gocCA9PiB7CiAgICBpZiAocC1wcmV2ID4gMSkgaHRtbCArPSBgPHNwYW4gY2xhc3M9InBhZ2UtYnRuIGVsbGlwc2lzIj4maGVsbGlwOzwvc3Bhbj5gOwogICAgaHRtbCArPSBgPGJ1dHRvbiBjbGFzcz0icGFnZS1idG4ke3A9PT1wYWdlPycgYWN0aXZlJzonJ30iIG9uY2xpY2s9ImdvUGFnZSgnJHtzfScsJHtwfSkiPiR7cH08L2J1dHRvbj5gOwogICAgcHJldiA9IHA7CiAgfSk7CiAgaHRtbCArPSBgPGJ1dHRvbiBjbGFzcz0icGFnZS1idG4iIG9uY2xpY2s9ImdvUGFnZSgnJHtzfScsJHtwYWdlKzF9KSIgJHtwYWdlPT09cGFnZXM/J2Rpc2FibGVkJzonJ30+4oC6PC9idXR0b24+YDsKICBodG1sICs9IGA8YnV0dG9uIGNsYXNzPSJwYWdlLWJ0biIgb25jbGljaz0iZ29QYWdlKCcke3N9Jywke3BhZ2VzfSkiICR7cGFnZT09PXBhZ2VzPydkaXNhYmxlZCc6Jyd9PsK7PC9idXR0b24+YDsKICBodG1sICs9ICc8L2Rpdj4nOwogIGVsLmlubmVySFRNTCA9IGh0bWw7Cn0KCmZ1bmN0aW9uIGdvUGFnZShzLCBwKSB7CiAgc3RhdGVbc10ucGFnZSA9IHA7CiAgcmVuZGVyU2VjdGlvbihzKTsKICBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgnc2VjLScrcykuc2Nyb2xsSW50b1ZpZXcoe2JlaGF2aW9yOidzbW9vdGgnLGJsb2NrOidzdGFydCd9KTsKfQoKLy8g4pSA4pSAIFNlY3Rpb24gdGFicyDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAKZnVuY3Rpb24gZmlsdGVyU2VjdGlvbihzKSB7CiAgZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbCgnLnN0YXQnKS5mb3JFYWNoKGVsID0+IGVsLmNsYXNzTGlzdC50b2dnbGUoJ2FjdGl2ZScsIGVsLmRhdGFzZXQuc2VjdGlvbj09PXMpKTsKICBkb2N1bWVudC5xdWVyeVNlbGVjdG9yQWxsKCcuc2VjdGlvbicpLmZvckVhY2goZWwgPT4gewogICAgZWwuY2xhc3NMaXN0LnRvZ2dsZSgndmlzaWJsZScsIHM9PT0nYWxsJyA/IEFDVElWRS5pbmNsdWRlcyhlbC5kYXRhc2V0LnNlY3Rpb24pIDogZWwuZGF0YXNldC5zZWN0aW9uPT09cyk7CiAgfSk7Cn0KCi8vIOKUgOKUgCBTZWFyY2gg4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSACmxldCBfc3Q7CmRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdnbG9iYWxTZWFyY2gnKS5hZGRFdmVudExpc3RlbmVyKCdpbnB1dCcsIGZ1bmN0aW9uKCkgewogIGNsZWFyVGltZW91dChfc3QpOwogIF9zdCA9IHNldFRpbWVvdXQoKCkgPT4gewogICAgY29uc3QgcSA9IHRoaXMudmFsdWUudHJpbSgpOwogICAgbGV0IHRvdGFsID0gMDsKICAgIEFDVElWRS5mb3JFYWNoKHMgPT4geyBzdGF0ZVtzXS5xdWVyeSA9IHE7IGFwcGx5RmlsdGVyKHMpOyB0b3RhbCArPSBzdGF0ZVtzXS5maWx0ZXJlZC5sZW5ndGg7IH0pOwogICAgQUNUSVZFLmZvckVhY2gocmVuZGVyU2VjdGlvbik7CiAgICBjb25zdCBtYyA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdtYXRjaENvdW50Jyk7CiAgICBtYy50ZXh0Q29udGVudCA9IHEgPyBgJHt0b3RhbH0gcmVzdWx0JHt0b3RhbCE9PTE/J3MnOicnfWAgOiAnJzsKICB9LCAyMDApOwp9KTsKCi8vIOKUgOKUgCBQYWdlIHNpemUg4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSACmRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdwYWdlU2l6ZScpLmFkZEV2ZW50TGlzdGVuZXIoJ2NoYW5nZScsIGZ1bmN0aW9uKCkgewogIGNvbnN0IHBzID0gcGFyc2VJbnQodGhpcy52YWx1ZSk7CiAgQUNUSVZFLmZvckVhY2gocyA9PiB7IHN0YXRlW3NdLnBhZ2VTaXplID0gcHM7IHN0YXRlW3NdLnBhZ2UgPSAxOyByZW5kZXJTZWN0aW9uKHMpOyB9KTsKfSk7CgovLyDilIDilIAgU29ydCDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAKZnVuY3Rpb24gc29ydFRhYmxlKHMsIGNvbCkgewogIGlmIChzdGF0ZVtzXS5zb3J0Q29sID09PSBjb2wpIHsgc3RhdGVbc10uc29ydERpciAqPSAtMTsgfQogIGVsc2UgeyBzdGF0ZVtzXS5zb3J0Q29sID0gY29sOyBzdGF0ZVtzXS5zb3J0RGlyID0gMTsgfQogIGNvbnN0IHRocyA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3JBbGwoJyN0YmwtJyArIHMgKyAnIHRoZWFkIHRoJyk7CiAgdGhzLmZvckVhY2goKHRoLCBpKSA9PiB7CiAgICB0aC5jbGFzc0xpc3QudG9nZ2xlKCdzb3J0ZWQnLCBpPT09Y29sKTsKICAgIGNvbnN0IGljID0gdGgucXVlcnlTZWxlY3RvcignLnNvcnQtaWNvbicpOwogICAgaWYgKGljKSBpYy50ZXh0Q29udGVudCA9IGk9PT1jb2wgPyAoc3RhdGVbc10uc29ydERpcj09PTE/J1x1MjE5MSc6J1x1MjE5MycpIDogJ1x1MjFjNSc7CiAgfSk7CiAgYXBwbHlGaWx0ZXIocyk7IHJlbmRlclNlY3Rpb24ocyk7Cn0KCi8vIOKUgOKUgCBDb3B5ICYgRXhwb3J0IOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgApmdW5jdGlvbiBzaG93VG9hc3QobXNnLCBvaykgewogIGlmIChvaz09PXVuZGVmaW5lZCkgb2s9dHJ1ZTsKICBjb25zdCB0ID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ3RvYXN0Jyk7CiAgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ3RvYXN0LW1zZycpLnRleHRDb250ZW50ID0gbXNnOwogIHQuY2xhc3NMaXN0LnRvZ2dsZSgnc3VjY2VzcycsIG9rKTsKICB0LmNsYXNzTGlzdC5hZGQoJ3Nob3cnKTsKICBzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7IHQuY2xhc3NMaXN0LnJlbW92ZSgnc2hvdycpOyB9LCAyNTAwKTsKfQpmdW5jdGlvbiBjb3B5Q29sdW1uKHMsIGNvbCkgewogIGNvbnN0IHJvd3MgPSBzdGF0ZVtzXS5maWx0ZXJlZDsKICBpZiAoIXJvd3MubGVuZ3RoKSB7IHNob3dUb2FzdCgnTm90aGluZyB0byBjb3B5JywgZmFsc2UpOyByZXR1cm47IH0KICBjb25zdCBzZWVuID0ge30sIGxpbmVzID0gW107CiAgcm93cy5mb3JFYWNoKGZ1bmN0aW9uKHIpeyBjb25zdCB2PXJbY29sXXx8Jyc7IGlmKHYgJiYgIXNlZW5bdl0peyBzZWVuW3ZdPTE7IGxpbmVzLnB1c2godik7IH0gfSk7CiAgbmF2aWdhdG9yLmNsaXBib2FyZC53cml0ZVRleHQobGluZXMuam9pbignXG4nKSkudGhlbihmdW5jdGlvbigpIHsKICAgIGNvbnN0IGJ0biA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdjb3B5LWlwLScrcyk7CiAgICBpZiAoYnRuKSB7IGJ0bi5jbGFzc0xpc3QuYWRkKCdjb3BpZWQnKTsgc2V0VGltZW91dChmdW5jdGlvbigpeyBidG4uY2xhc3NMaXN0LnJlbW92ZSgnY29waWVkJyk7IH0sMTgwMCk7IH0KICAgIHNob3dUb2FzdCgnQ29waWVkICcgKyBsaW5lcy5sZW5ndGggKyAnIElQJyArIChsaW5lcy5sZW5ndGghPT0xPydzJzonJykgKyAnIHRvIGNsaXBib2FyZCcpOwogIH0pOwp9CmZ1bmN0aW9uIGNvcHlBbGwocykgewogIGNvbnN0IHJvd3MgPSBzdGF0ZVtzXS5maWx0ZXJlZDsKICBpZiAoIXJvd3MubGVuZ3RoKSB7IHNob3dUb2FzdCgnTm90aGluZyB0byBjb3B5JywgZmFsc2UpOyByZXR1cm47IH0KICBjb25zdCBoZWFkZXJzID0gT2JqZWN0LmtleXMocm93c1swXSkuam9pbignXHQnKTsKICBjb25zdCBsaW5lcyAgID0gcm93cy5tYXAoZnVuY3Rpb24ocil7IHJldHVybiBPYmplY3QudmFsdWVzKHIpLmpvaW4oJ1x0Jyk7IH0pOwogIG5hdmlnYXRvci5jbGlwYm9hcmQud3JpdGVUZXh0KFtoZWFkZXJzXS5jb25jYXQobGluZXMpLmpvaW4oJ1xuJykpLnRoZW4oZnVuY3Rpb24oKSB7CiAgICBjb25zdCBidG4gPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgnY29weS1hbGwtJytzKTsKICAgIGlmIChidG4pIHsgYnRuLmNsYXNzTGlzdC5hZGQoJ2NvcGllZCcpOyBzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7IGJ0bi5jbGFzc0xpc3QucmVtb3ZlKCdjb3BpZWQnKTsgfSwxODAwKTsgfQogICAgc2hvd1RvYXN0KCdDb3BpZWQgJyArIHJvd3MubGVuZ3RoICsgJyByb3dzIHRvIGNsaXBib2FyZCcpOwogIH0pOwp9CmZ1bmN0aW9uIGV4cG9ydFNlY3Rpb24ocykgewogIGNvbnN0IHJvd3MgPSBzdGF0ZVtzXS5maWx0ZXJlZDsKICBpZiAoIXJvd3MubGVuZ3RoKSB7IHNob3dUb2FzdCgnTm90aGluZyB0byBleHBvcnQnLCBmYWxzZSk7IHJldHVybjsgfQogIGNvbnN0IGhlYWRlcnMgPSBPYmplY3Qua2V5cyhyb3dzWzBdKS5qb2luKCcsJyk7CiAgY29uc3QgbGluZXMgICA9IHJvd3MubWFwKGZ1bmN0aW9uKHIpewogICAgcmV0dXJuIE9iamVjdC52YWx1ZXMocikubWFwKGZ1bmN0aW9uKHYpeyByZXR1cm4gJyInK1N0cmluZyh2KS5yZXBsYWNlKC8iL2csJyIiJykrJyInOyB9KS5qb2luKCcsJyk7CiAgfSk7CiAgY29uc3QgY3N2ICA9IFtoZWFkZXJzXS5jb25jYXQobGluZXMpLmpvaW4oJ1xuJyk7CiAgY29uc3QgYmxvYiA9IG5ldyBCbG9iKFtjc3ZdLHt0eXBlOid0ZXh0L2Nzdid9KTsKICBjb25zdCB1cmwgID0gVVJMLmNyZWF0ZU9iamVjdFVSTChibG9iKTsKICBjb25zdCBhICAgID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnYScpOwogIGEuaHJlZiA9IHVybDsKICBhLmRvd25sb2FkID0gJ25ldHNjb3V0XycgKyBzICsgJ18nICsgRGF0ZS5ub3coKSArICcuY3N2JzsKICBhLmNsaWNrKCk7CiAgVVJMLnJldm9rZU9iamVjdFVSTCh1cmwpOwogIHNob3dUb2FzdCgnRXhwb3J0ZWQgJyArIHJvd3MubGVuZ3RoICsgJyByb3dzIGFzIENTVicpOwp9CgovLyDilIDilIAgVGhlbWUg4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSACmZ1bmN0aW9uIHRvZ2dsZVRoZW1lKCkgewogIHZhciBpc0xpZ2h0ID0gZG9jdW1lbnQuYm9keS5jbGFzc0xpc3QudG9nZ2xlKCdsaWdodCcpOwogIGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCd0aGVtZUljb24nKS50ZXh0Q29udGVudCAgPSBpc0xpZ2h0ID8gJ1x1ZDgzY1x1ZGYxOScgOiAnXHUyNjAwXHVmZTBmJzsKICBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgndGhlbWVMYWJlbCcpLnRleHRDb250ZW50ID0gaXNMaWdodCA/ICdEYXJrJyA6ICdMaWdodCc7CiAgdHJ5IHsgbG9jYWxTdG9yYWdlLnNldEl0ZW0oJ25zX3RoZW1lJywgaXNMaWdodCA/ICdsaWdodCcgOiAnZGFyaycpOyB9IGNhdGNoKGUpIHt9Cn0KKGZ1bmN0aW9uKCl7CiAgdHJ5IHsKICAgIGlmIChsb2NhbFN0b3JhZ2UuZ2V0SXRlbSgnbnNfdGhlbWUnKSA9PT0gJ2xpZ2h0JykgewogICAgICBkb2N1bWVudC5ib2R5LmNsYXNzTGlzdC5hZGQoJ2xpZ2h0Jyk7CiAgICAgIGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCd0aGVtZUljb24nKS50ZXh0Q29udGVudCAgPSAnXHVkODNjXHVkZjE5JzsKICAgICAgZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ3RoZW1lTGFiZWwnKS50ZXh0Q29udGVudCA9ICdEYXJrJzsKICAgIH0KICB9IGNhdGNoKGUpIHt9Cn0pKCk7CgovLyDilIDilIAgSW5pdCDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAKQUNUSVZFLmZvckVhY2goZnVuY3Rpb24ocyl7IGFwcGx5RmlsdGVyKHMpOyByZW5kZXJTZWN0aW9uKHMpOyB9KTsKZmlsdGVyU2VjdGlvbignYWxsJyk7CmRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoJy5zdGF0W2RhdGEtc2VjdGlvbj0iYWxsIl0nKS5jbGFzc0xpc3QuYWRkKCdhY3RpdmUnKTsK
B64JSEOF
  printf '</script>\n</body>\n</html>\n' >> "$htmlfile"

    log_ok "HTML report saved → ${CYAN}$htmlfile${RESET}"
}


# ─── Argument Parsing ────────────────────────────────────────────────
OPT_IP="" OPT_RANGE="" OPT_FILE="" OPT_OUTPUT="" OPT_CSV=""
TIMEOUT=2 THREADS=50 VERBOSE=0 NO_PING=0
DO_WEB=0 DO_FTP=0 DO_TELNET=0 DO_SMB=0 DO_RDP=0 DO_SSH=0 DO_DB=0 MODE_SET=0
START_TS=$(date +%s)

[[ $# -eq 0 ]] && { print_help; exit 0; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)    print_help; exit 0 ;;
    --version)    echo "NetScout v${VERSION}"; exit 0 ;;
    --all)        DO_WEB=1;DO_FTP=1;DO_TELNET=1;DO_SMB=1;DO_RDP=1;DO_SSH=1;DO_DB=1;MODE_SET=1 ;;
    --web)        DO_WEB=1;    MODE_SET=1 ;;
    --ftp)        DO_FTP=1;    MODE_SET=1 ;;
    --telnet)     DO_TELNET=1; MODE_SET=1 ;;
    --smb)        DO_SMB=1;    MODE_SET=1 ;;
    --rdp)        DO_RDP=1;    MODE_SET=1 ;;
    --ssh)        DO_SSH=1;    MODE_SET=1 ;;
    --db)         DO_DB=1;     MODE_SET=1 ;;
    -i|--ip)
      if [[ "$2" == *"/"* ]]; then
        log_error "-i / --ip expects a single IP address, not a CIDR range."
        echo -e "  ${YELLOW}  Got      :${RESET} ${RED}$2${RESET}"
        echo -e "  ${YELLOW}  Use this :${RESET}  ${CYAN}netscout --web -r $2${RESET}"; echo ""; exit 1
      elif [[ ! "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "-i / --ip expects a valid IPv4 address."
        echo -e "  ${YELLOW}  Got      :${RESET} ${RED}$2${RESET}"
        echo -e "  ${YELLOW}  Example  :${RESET}  ${CYAN}netscout --web -i 192.168.1.10${RESET}"; echo ""; exit 1
      fi
      OPT_IP="$2"; shift ;;
    -r|--range)   OPT_RANGE="$2";  shift ;;
    -f|--file)    OPT_FILE="$2";   shift ;;
    -o|--output)  OPT_OUTPUT="$2"; shift ;;
    --csv)        OPT_CSV="$2";    shift ;;
    -t|--timeout) TIMEOUT="$2";    shift ;;
    -T|--threads) THREADS="$2";    shift ;;
    --no-ping)    NO_PING=1 ;;
    -v|--verbose) VERBOSE=1 ;;
    *) log_error "Unknown argument: $1"; echo ""; print_help; exit 1 ;;
  esac
  shift
done

[[ "$MODE_SET" -eq 0 ]] && { DO_WEB=1;DO_FTP=1;DO_TELNET=1;DO_SMB=1;DO_RDP=1;DO_SSH=1;DO_DB=1; }

if [[ -z "$OPT_IP" && -z "$OPT_RANGE" && -z "$OPT_FILE" ]]; then
  print_banner
  log_error "No target specified. Use -i, -r, or -f."
  echo -e "  ${DIM}Run ${CYAN}netscout --help${RESET}${DIM} for usage.${RESET}"; echo ""; exit 1
fi

if [[ -n "$OPT_FILE" && ! -f "$OPT_FILE" ]]; then
  print_banner; log_error "File not found: $OPT_FILE"; exit 1
fi

# ─── Init temp files ─────────────────────────────────────────────────
WEB_OUT=$(mktemp); FTP_OUT=$(mktemp); TEL_OUT=$(mktemp)
SMB_OUT=$(mktemp); RDP_OUT=$(mktemp); SSH_OUT=$(mktemp); DB_OUT=$(mktemp)

cleanup() { rm -f "$WEB_OUT" "$FTP_OUT" "$TEL_OUT" "$SMB_OUT" "$RDP_OUT" "$SSH_OUT" "$DB_OUT" "$TMP_IPS"; }
trap cleanup EXIT

# ─── Run ─────────────────────────────────────────────────────────────
print_banner
check_requirements

log_section "🎯  Scan Configuration"
[[ -n "$OPT_IP"    ]] && log_info "Target IP    : ${CYAN}$OPT_IP${RESET}"
[[ -n "$OPT_RANGE" ]] && log_info "Target Range : ${CYAN}$OPT_RANGE${RESET}"
[[ -n "$OPT_FILE"  ]] && log_info "Target File  : ${CYAN}$OPT_FILE${RESET}"
MODES=""
[[ "$DO_WEB"    == "1" ]] && MODES+="${BLUE}WEB${RESET} "
[[ "$DO_FTP"    == "1" ]] && MODES+="${ORANGE}FTP${RESET} "
[[ "$DO_TELNET" == "1" ]] && MODES+="${RED}TELNET${RESET} "
[[ "$DO_SMB"    == "1" ]] && MODES+="${PURPLE}SMB${RESET} "
[[ "$DO_RDP"    == "1" ]] && MODES+="${PINK}RDP${RESET} "
[[ "$DO_SSH"    == "1" ]] && MODES+="${YELLOW}SSH${RESET} "
[[ "$DO_DB"     == "1" ]] && MODES+="${GREEN}DB${RESET} "
log_info "Modes        : $MODES"
log_info "Timeout      : ${YELLOW}${TIMEOUT}s${RESET}   Threads: ${YELLOW}${THREADS}${RESET}   Ping sweep: ${YELLOW}$([[ $NO_PING -eq 1 ]] && echo "OFF" || echo "ON")${RESET}"
[[ -n "$OPT_OUTPUT" ]] && log_info "HTML Report  : ${CYAN}$OPT_OUTPUT${RESET}"
[[ -n "$OPT_CSV"    ]] && log_info "CSV Export   : ${CYAN}$OPT_CSV${RESET}"

log_section "🔍  Building Target List"
build_ip_list
log_ok "${CYAN}${TOTAL_IPS}${RESET} host(s) loaded"

# Ping sweep
if [[ "$NO_PING" -eq 0 && "$TOTAL_IPS" -gt 1 ]]; then
  ping_sweep "$TMP_IPS"
  [[ "$TOTAL_IPS" -eq 0 ]] && { log_warn "No live hosts found. Use --no-ping to force scan."; exit 0; }
fi

log_section "🚀  Scanning"
echo ""
run_scan "$TMP_IPS"
log_ok "Scan finished"

# Print tables
[[ "$DO_WEB"    == "1" ]] && print_web_table
[[ "$DO_WEB"    == "1" ]] && print_web_ssl_table
[[ "$DO_FTP"    == "1" ]] && print_ftp_table
[[ "$DO_TELNET" == "1" ]] && print_telnet_table
[[ "$DO_SMB"    == "1" ]] && print_smb_table
[[ "$DO_RDP"    == "1" ]] && print_rdp_table
[[ "$DO_SSH"    == "1" ]] && print_ssh_table
[[ "$DO_DB"     == "1" ]] && print_db_table

print_summary

[[ -n "$OPT_OUTPUT" ]] && generate_html "$OPT_OUTPUT"
[[ -n "$OPT_CSV"    ]] && export_csv    "$OPT_CSV"

echo -e "  ${DIM}${GRAY}NetScout v${VERSION} — pentester.ma${RESET}"
echo ""
