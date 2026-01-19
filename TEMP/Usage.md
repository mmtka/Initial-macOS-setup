# 📄 ČO JE ČO (ľudsky, bez teórie)

## 1️⃣ `bootstrap.sh`  **(HLAVNÝ VSTUP)**

👉 **JEDINÝ skript, ktorý spúšťaš**

Robí **všetko automaticky**:

1. nainštaluje **Rosetta** (len na Apple Silicon)
2. nainštaluje **Xcode Command Line Tools**
3. nainštaluje **Homebrew**
4. nastaví **zsh**:

   * `.zprofile` (brew shellenv)
   * `.zshrc` (PATH dedupe, completion, history, prompt)
5. spustí `brew bundle` z `Brewfile`
6. aplikuje macOS defaults:

   * safe
   * power
7. nastaví **Dock layout**
8. aplikuje zmeny (Finder, Dock, SystemUIServer)

➡️ **Toto je “magic button”.**

---

## 2️⃣ `Brewfile`

👉 **ZOZNAM VŠETKÉHO SOFTVÉRU**

Obsahuje:

* CLI nástroje (`brew`)
* GUI aplikácie (`cask`)
* App Store aplikácie (`mas`)
* VS Code rozšírenia (`vscode`)

Používa sa:

```bash
brew bundle
```

➡️ Reprezentuje **celý tvoj software stack**.

---

## 3️⃣ `defaults/defaults.safe.sh`

👉 **BEZPEČNÉ macOS NASTAVENIA**

Veci typu:

* Finder (hidden files, view, sidebar…)
* klávesnica, trackpad, scroll
* screenshoty
* Dock (size, recents, hot corners)
* Safari dev menu
* Activity Monitor
* Time Machine

➡️ Môžeš pustiť **na každom Macu bez rizika**.

---

## 4️⃣ `defaults/defaults.power.sh`

👉 **AGRESÍVNE / POWER USER NASTAVENIA**

Veci:

* Gatekeeper quarantine OFF
* hibernation OFF
* firewall ON
* timezone fix
* boot sound OFF
* Fn key behavior

➡️ Vieš presne, **čo robí a prečo**
➡️ oddelené, aby si mal kontrolu

---

## 5️⃣ `defaults/apply.sh`

👉 **APLIKÁCIA ZMIEN**

* restart Finder / Dock
* rebuild LaunchServices
* flush preferences

➡️ Bez toho by sa časť zmien neprejavila.

---

## 6️⃣ `dock/layout.sh`

👉 **AUTOMATICKÉ ZLOŽENIE DOCKU**

* vyčistí Dock
* pridá systémové appky
* pridá tvoje appky (ak existujú)
* pridá Downloads stack

➡️ Bez manuálneho kliknutia.

---

# 🚀 AKO TO SPUSTÍŠ NA ČISTOM MACU (JEDEN PRÍKAZ)

### Predpoklad:

* prihlásený do iCloudu
* GitHub prístup (repo je Private)

---

## 🅰️ Odporúčané (SSH)

```bash
git clone git@github.com:TVOJ_GITHUB_USERNAME/Initial-macOS-Setup.git \
&& cd "Initial-macOS-Setup" \
&& ./bootstrap.sh
```

---

## 🅱️ Alternatíva (HTTPS)

```bash
git clone https://github.com/TVOJ_GITHUB_USERNAME/Initial-macOS-Setup.git \
&& cd "Initial-macOS-Setup" \
&& ./bootstrap.sh
```

➡️ zadáš GitHub token
➡️ nič iné nerobíš

---

# 🧠 ČO MUSÍŠ UROBIŤ MANUÁLNE (NEVYHNUTNÉ)

Tieto veci **nejdú automatizovať**:

1. prihlásiť sa do **App Store** (kvôli `mas`)
2. povoliť **Firewall** v UI (ak macOS vypýta)
3. prípadne **logout / reboot** (raz)

---

# 🏁 FINÁLNY VERDIKT

👉 Máš:

* **one-liner setup**
* **reprodukovateľný macOS**
* **verzionované nastavenia**
* **žiadne ručné klikanie**
* **oddelený safe vs power režim**

Toto je **maximum**, čo sa dá na macOS dosiahnuť bez MDM.