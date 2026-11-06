# ProxyGo — статический сайт

Готовый к публикации набор файлов для GitHub Pages:

```
proxygo-site/
  index.html          — сам сайт (HTML + CSS + JS, без сборки)
  favicon.svg
  public.json         — данные из TG Proxy Hub (копия data/public.json)
  .nojekyll           — отключает обработку Jekyll на GitHub Pages
  serve.ps1           — локальный запуск
  update-public.ps1   — обновление public.json (+ commit/push)
```

Сайт полностью статический: никакого бэкенда, API и прямого подключения
к машине с TG Proxy Hub. `index.html` сам делает `fetch("./public.json")`.
Данные обновляются только копированием нового `public.json` в эту папку.

---

## 1. Запуск локально

Из папки `C:\Projects\proxygo-site`:

```powershell
.\serve.ps1
```

Открыть <http://127.0.0.1:8080/>.

Без скрипта (любой Python):

```powershell
python -m http.server 8080
```

> Важно: открывать именно через HTTP-сервер, а не двойным кликом по
> `index.html`. При `file://` браузер блокирует `fetch("./public.json")`.

Остановка — `Ctrl+C`.

---

## 2. Обновление данных

После очередного прогона TG Proxy Hub:

```powershell
# только скопировать свежий public.json в папку сайта
.\update-public.ps1

# скопировать и сразу закоммитить + запушить на GitHub
.\update-public.ps1 -Push
```

Источник по умолчанию: `C:\Projects\TG-Proxy-Hub\data\public.json`.
Другой путь: `.\update-public.ps1 -Source "D:\path\public.json"`.

Если `public.json` не изменился, коммит не создаётся.

---

## 3. Публикация на GitHub Pages

`gh` CLI в системе не установлен, поэтому — через веб-интерфейс GitHub.

### 3.1. Создать репозиторий

1. На <https://github.com/new> создать **public** репозиторий,
   например `proxygo`. Без README/лицензии (папка уже готова).
2. В папке `C:\Projects\proxygo-site` выполнить:

```powershell
git init
git add .
git commit -m "ProxyGo static site"
git branch -M main
git remote add origin https://github.com/<USER>/proxygo.git
git push -u origin main
```

### 3.2. Включить Pages

В репозитории: **Settings → Pages**

- Source: **Deploy from a branch**
- Branch: **main**, папка: **/ (root)**
- Save.

Через 1–2 минуты сайт будет доступен по адресу:

```
https://<USER>.github.io/proxygo/
```

`public.json` лежит рядом с `index.html`, поэтому относительный путь
`./public.json` работает без CORS.

### 3.3. Обновление сайта

```powershell
.\update-public.ps1 -Push
```

GitHub Pages пересоберёт сайт автоматически после пуша в `main`.

---

## 4. Альтернативы хостинга

| Вариант | Плюсы | Минусы |
|---|---|---|
| **GitHub Pages** (этот) | бесплатно, HTTPS, свой домен | публичный репозиторий (для приватного Pages нужен платный план) |
| **Cloudflare Pages** | бесплатно, приватный репозиторий, быстрый CDN | нужен аккаунт Cloudflare, отдельная настройка |
| **Netlify / Vercel** | drag-and-drop папки, бесплатный HTTPS | лимиты трафика, аккаунт |
| **Свой сервер / VPS** | полный контроль | платно, нужно администрирование |

Для всех вариантов набор файлов один и тот же: `index.html`,
`favicon.svg`, `public.json`, `.nojekyll`.

---

## 5. Безопасность

`public.json` содержит реальные `link` вида `tg://proxy?...` с секретами
публичных прокси. Это **публичные** прокси, их секреты не являются
приватными данными, но помните: файл будет доступен всем, у кого есть
ссылка на сайт (и в публичном репозитории GitHub — тоже).

---

## 6. Ограничения

- Обновление данных — только ручной запуск `update-public.ps1`.
  Автоматической синхронизации с TG Proxy Hub нет: он работает локально.
  При желании можно добавить GitHub Action, который забирает `public.json`
  из другого публичного репозитория/URL.
- Мобильная подпись `PING` перед значением latency задана в CSS и
  показывается для всех типов, включая WEB (см. `index.html`).
