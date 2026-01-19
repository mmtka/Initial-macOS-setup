Ako to používať do budúcna (2 scenáre)

### A) Nový čistý macOS (tvoj “one-command restore”)

```bash
git clone https://github.com/<tvoj_user>/Initial-macOS-Setup.git
cd "Initial-macOS-Setup"
./bootstrap.sh
```

### B) Keď niečo pridáš/odoberieš cez brew

1. nainštaluješ/odinštaluješ normálne
2. aktualizuješ Brewfile:

```bash
brew bundle dump --describe --force --file Brewfile
```

3. commit + push:

```bash
git add Brewfile
git commit -m "Update Brewfile"
git push
```

---

## 6) Odporúčanie navyše (aby sa ti Brewfile nerozpadal)

Keď budeš chcieť upratať veci mimo Brewfile:

```bash
brew bundle cleanup --file Brewfile
```

---
