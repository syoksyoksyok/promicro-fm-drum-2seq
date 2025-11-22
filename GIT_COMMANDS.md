# Git コマンドリファレンス

**プロジェクトパス:** `C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq`
**ブランチ:** `claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H`

---

## 📥 最新版を取得（更新があった場合）

### 基本コマンド

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git pull origin claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
```

### 取得後、すぐにビルド＆書き込み

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git pull origin claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H && build.bat && upload.bat COM3
```

---

## 📊 状態確認

### 現在のブランチと変更状態を確認

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git status
```

**出力例:**
```
On branch claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
Your branch is up to date with 'origin/claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H'.

nothing to commit, working tree clean
```

### 現在のブランチ名のみ確認

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git branch
```

### 最新のコミット履歴を確認（直近10件）

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git log --oneline -10
```

---

## 🔍 変更内容の確認

### ファイルの変更箇所を確認

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git diff
```

### 特定のファイルの変更箇所を確認

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git diff src/main.cpp
```

### 変更されたファイル名のみ確認

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git status --short
```

---

## 🔄 リモートの更新確認（pullせずに確認のみ）

### Step 1: リモートの情報を取得

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git fetch origin
```

### Step 2: リモートとの差分を確認

```cmd
git log HEAD..origin/claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H --oneline
```

**出力がある場合:** リモートに新しいコミットがあります → `git pull` してください
**出力がない場合:** すでに最新版です

### ワンライナー（まとめて実行）

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq && git fetch origin && git log HEAD..origin/claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H --oneline
```

---

## 🔙 ローカルの変更を元に戻す

### ⚠️ 全ての変更を破棄してリモートの最新版に戻す

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git reset --hard origin/claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
git clean -fd
```

**警告:** このコマンドは、ローカルの変更を完全に削除します。実行前に必ず確認してください。

### 特定のファイルのみ元に戻す

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git checkout origin/claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H -- src/main.cpp
```

---

## 🌐 リモート情報の確認

### リモートURLの確認

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git remote -v
```

**出力例:**
```
origin  https://github.com/syoksyoksyok/promicro-fm-drum-2seq.git (fetch)
origin  https://github.com/syoksyoksyok/promicro-fm-drum-2seq.git (push)
```

### リモートブランチ一覧

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git branch -r
```

---

## 🚀 シチュエーション別コマンド

### 新しい変更があるか確認したい

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git fetch origin
git status
```

**出力に "Your branch is behind" が含まれる場合:**
```cmd
git pull origin claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
```

### 誤ってファイルを変更してしまった

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git status
git checkout -- ファイル名
```

または全ファイルを元に戻す:
```cmd
git reset --hard HEAD
```

### コンフリクト（競合）が発生した

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq

REM ローカルの変更を破棄して、リモートの最新版を優先する場合
git reset --hard origin/claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H

REM または、ローカルの変更を保存してから最新版を取得
git stash
git pull origin claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
git stash pop
```

---

## 📝 PowerShellエイリアス（便利な設定）

PowerShellプロファイルに追加:

```powershell
# プロファイルを開く
notepad $PROFILE

# 以下を追加
$FmDrumPath = "C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq"
$FmDrumBranch = "claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H"

function fmdrum-pull {
    cd $FmDrumPath
    git pull origin $FmDrumBranch
}

function fmdrum-status {
    cd $FmDrumPath
    git status
}

function fmdrum-fetch {
    cd $FmDrumPath
    git fetch origin
    git log HEAD..origin/$FmDrumBranch --oneline
}

function fmdrum-reset {
    cd $FmDrumPath
    Write-Host "WARNING: This will discard all local changes!" -ForegroundColor Red
    $confirm = Read-Host "Continue? (yes/no)"
    if ($confirm -eq "yes") {
        git reset --hard origin/$FmDrumBranch
        git clean -fd
        Write-Host "Reset complete!" -ForegroundColor Green
    }
}

function fmdrum-update {
    cd $FmDrumPath
    git pull origin $FmDrumBranch
    .\build.bat
}
```

保存後、PowerShellを再起動して使用:

```powershell
fmdrum-pull      # 最新版を取得
fmdrum-status    # 状態確認
fmdrum-fetch     # リモートの更新確認（pullしない）
fmdrum-reset     # ローカルの変更を破棄
fmdrum-update    # 最新版を取得してビルド
```

---

## 📋 Git用語集

| 用語 | 意味 |
|------|------|
| **pull** | リモートの最新版を取得してローカルに反映 |
| **fetch** | リモートの情報を取得（ローカルには反映しない） |
| **status** | 現在の変更状態を確認 |
| **diff** | 変更内容の詳細を確認 |
| **reset** | ローカルの変更を破棄 |
| **clean** | 未追跡ファイルを削除 |
| **branch** | ブランチの一覧や現在のブランチを確認 |
| **log** | コミット履歴を確認 |
| **origin** | リモートリポジトリの別名 |

---

## ❓ FAQ

### Q: git pull したらエラーが出た

**エラー例:**
```
error: Your local changes to the following files would be overwritten by merge:
    src/main.cpp
Please commit your changes or stash them before you merge.
```

**解決策:**

ローカルの変更を破棄する場合:
```cmd
git reset --hard HEAD
git pull origin claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
```

ローカルの変更を一時保存する場合:
```cmd
git stash
git pull origin claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
git stash pop
```

### Q: どのブランチにいるか分からなくなった

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git branch
```

`*` がついているブランチが現在のブランチです。

### Q: 間違ったブランチにいる場合の切り替え方

```cmd
cd C:\Users\Administrator\Documents\Arduino\Pro_Micro\promicro-fm-drum-2seq
git checkout claude/fm-drum-machine-01LVP5yJBvNCkW1WTujcN51H
```

---

## 🆘 トラブルシューティング

### git コマンドが使えない

**原因:** Gitがインストールされていない

**解決策:**

1. https://git-scm.com/download/win からGit for Windowsをダウンロード
2. インストール
3. コマンドプロンプトを再起動

### "Please tell me who you are" エラー

```cmd
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### SSL証明書エラー

```cmd
git config --global http.sslVerify false
```

**注意:** セキュリティリスクがあるため、信頼できる環境でのみ使用してください。

---

**Gitコマンドで常に最新版を取得して、快適な開発を！**
