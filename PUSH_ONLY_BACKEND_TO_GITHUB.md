# Put ONLY the backend on seedfit-habittracker (fix full-app push)

Your repo should have **only the backend** (server.js, package.json, etc.), not the full Flutter app. Follow these steps to replace the repo content with just the backend.

---

## Option 1: New folder, push only backend (recommended)

Do this in a **new empty folder** (not inside your Seedfit app).

### 1. Create a folder and copy backend

Example (change path if you like):

```bash
mkdir C:\seedfit-backend-only
xcopy "d:\jagmohan flutter\Seedfit app v1 23-01-26\Seedfit app\backend\*" "C:\seedfit-backend-only\" /E /H /I
```

Or manually: create `C:\seedfit-backend-only`, then copy **all contents** of the `backend` folder (server.js, package.json, .gitignore, README.md, etc.) into it. **Do not copy** the `.env` file (keep it secret).

### 2. Turn it into a Git repo and push

```bash
cd C:\seedfit-backend-only
git init
git remote add origin https://github.com/jagmohan0908/seedfit-habittracker.git
git add .
git commit -m "Seedfit backend only (Node.js API)"
git branch -M main
git push -u origin main --force
```

`--force` overwrites the repo so it only has the backend. Your full app stays only on your PC.

---

## Option 2: From your current project (replace repo with backend only)

Run from your **project root** (the folder that contains `backend` and `lib`).

```bash
cd "d:\jagmohan flutter\Seedfit app v1 23-01-26\Seedfit app"

# Create a temp branch and keep only backend
git checkout --orphan backend-only
git reset --hard
git rm -rf . 2>nul || true
git clean -fdx -e backend
xcopy "backend\*" "." /E /H /I /Y
rmdir /S /Q backend 2>nul || true
git add .
git commit -m "Seedfit backend only (Node.js API)"
git branch -M main
git push origin main --force
```

(On PowerShell you might use `Copy-Item`, `Remove-Item` instead of `xcopy`/`rmdir`. Simplest is Option 1.)

---

## After this

- **https://github.com/jagmohan0908/seedfit-habittracker** will show only backend files (server.js, package.json, README.md, seedfit_postgres.sql, etc.).
- Your **full Seedfit app** (Flutter + backend) stays only on your PC unless you create a **different** repo for it later.
