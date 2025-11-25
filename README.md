# Shadowsocks GUI (Qt 6)

A **cross‑platform**, actively‑maintained graphical client for the [Shadowsocks](https://shadowsocks.org) proxy.
Originally forked from `shadowsocks-qt5`, this project now targets **Qt 6**, C++17 (soon C++20), and brings numerous UX, security and build‑system improvements.

---

## ✨ Key features

* Native Qt 6 UI (Wayland & X11, Windows, macOS tested)
* Multiple server profiles with tags & search
* One‑click connect / disconnect & smart auto‑connect 
* Built‑in QR scanner / screenshot recogniser
* Latency tester, traffic stats & data‑cap reset reminders
* SOCKS5 **and** HTTP proxy modes
* System‑tray indicator with dark‑/light‑theme icons
* Import / export:

  * `ss://` & `ssd://` URIs
  * Clash‑/Surge‑style `gui-config.json`
* Auto‑start on login (optional)
* i18n with **gettext / Qt Linguist** – contributions welcome!

На чистой Debian-машине эти шаги можно автоматизировать с помощью `scripts/bootstrap-debian.sh`,
который подтянет системные зависимости, соберёт QtShadowsocks и выполнит сборку проекта:

```bash
$ ./scripts/bootstrap-debian.sh
```

---

## 🛠️ Build instructions

\### Prerequisites

| Dependency    | Minimum version | Notes                                    |
| ------------- | --------------- | ---------------------------------------- |
| CMake         |  3.16           | Use ‑‑preset or classic workflow         |
| Qt            |  6.5            | 6.6 recommended (Widgets, Network, DBus) |
| QtShadowsocks |  ≥ 2.0.0        | Provides core controller library         |
| libqrencode   | any             | QR code generation                       |
| zbar          | any             | QR code scanning                         |

```bash
# Clone
$ git clone https://github.com/juriyivanov/shadowsocks-gui.git
$ cd shadowsocks-gui

# Configure + build + install (Release)
$ cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
$ cmake --build build -j$(nproc)
$ sudo cmake --install build
```

> **Tip:** on Windows, use MSVC 2022 with the Qt online installer; on macOS, run `brew install qt6 zbar qrencode` first.

---

## 📦 Binary packages

| Platform | Status                                | Notes                         |
| -------- | ------------------------------------- | ----------------------------- |
| Linux    | AppImage & Flatpak (work‑in‑progress) | Built via GH Actions CI       |
| Windows  | Portable ZIP & Installer (EXE)        | Signed with GitHub CI secrets |
| macOS    | `dmg` bundle                          | Notarised build planned       |

---

## 🔐 Security notes

* **Default cipher:** `aes-256-gcm` (changeable per profile).
  Legacy algorithms such as RC4‑MD5 are still loadable for compatibility but **strongly discouraged**.
* Config files are stored in *plain text*; consider full‑disk encryption if this is a concern.

---

## 🗺️ Roadmap (2025‑Q3)

* [ ] Move to C++20 modules & `cmake_presets.json`
* [ ] Publish Flatpak & Homebrew recipes
* [ ] Integrate automatic update checker
* [ ] Finish dark‑theme polish and selectable icon packs

---

## 🤝 Contributing

1. Fork & create feature branch (`git checkout -b feat/my‑feature`).
2. Run `clang-format` on changed files (`.clang-format` provided).
3. Ensure **all** CI jobs pass (Ubuntu 22.04, Windows, macOS workflows).
4. Open a pull request – one of the maintainers will review ASAP.

Translations live in `translations/`.
Add or update `<lang>.ts`, then run `lupdate` / `lrelease`.

---

## 📝 License

This project is distributed under the **LGPL v3.0**.
See the [LICENSE](LICENSE) file for full text.
