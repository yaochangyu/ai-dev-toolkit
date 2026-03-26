# AI 助理配置同步腳本

本目錄包含用於同步 AI 助理配置文件的 PowerShell 腳本。

## 腳本說明

### 1. sync-ai-agents.ps1

將 `.github` 目錄內容同步到使用者家目錄的 AI 助理資料夾。

**同步目標資料夾：**
- Windows: `%USERPROFILE%\.copilot`、`%USERPROFILE%\.gemini`、`%USERPROFILE%\.claude`、`%USERPROFILE%\.github`
- WSL (Ubuntu-24.04): `~/.copilot`、`~/.gemini`、`~/.claude`、`~/.github`

**同步內容：**
- `agents/` - Agent 定義檔
- `prompts/` - 提示詞範本
- `skills/` - Skill 定義檔
- `mcp-config.json` - MCP 配置
- `README.md` - 說明文件

**使用方式：**
```powershell
# 使用預設值（當前 Windows 使用者名稱）
.\sync-ai-agents.ps1

# 自訂 WSL 使用者帳號
.\sync-ai-agents.ps1 -WslUser your_wsl_username
```

**同步策略：**
- 優先使用 Symbolic Link（自動同步，建議）
- 若無權限則降級為 Hard Link（檔案）或 Copy（資料夾）
- WSL 環境使用 `ln -sf` 建立軟連結

### 2. link-ai-instructions.ps1

將 `copilot-instructions.md` 連結到各 AI 助理的配置檔案位置。

**連結目標：**
- Windows 使用者家目錄：
  - `%USERPROFILE%\.github\copilot-instructions.md`
  - `%USERPROFILE%\.copilot\copilot-instructions.md`
  - `%USERPROFILE%\.claude\CLAUDE.md`
  - `%USERPROFILE%\.gemini\GEMINI.md`
- WSL (Ubuntu-24.04) 使用者家目錄：
  - `/home/yao/.github/copilot-instructions.md`
  - `/home/yao/.copilot/copilot-instructions.md`
  - `/home/yao/.claude/CLAUDE.md`
  - `/home/yao/.gemini/GEMINI.md`

**使用方式：**
```powershell
# 使用預設值（當前 Windows 使用者名稱）
.\link-ai-instructions.ps1

# 自訂 WSL 使用者帳號
.\link-ai-instructions.ps1 -WslUser your_wsl_username
```

### 3. sync-editorconfig.ps1

將 `.editorconfig` 複製到 Windows 個人資料夾與 WSL 對應位置。

**複製目標：**
- Windows: `%USERPROFILE%\.editorconfig\.net\.editorconfig`
- WSL: `~/.editorconfig/.net/.editorconfig`

**使用方式：**
```powershell
.\sync-editorconfig.ps1
```

## 系統需求

- PowerShell 5.1 或更新版本
- Windows（WSL 為選用）
- 建立 Symbolic Link 需要管理員權限或啟用開發者模式

## 注意事項

- 腳本會先移除既有目標檔案，再建立連結
- WSL 使用者帳號預設使用當前 Windows 使用者名稱，若不同請使用 `-WslUser` 參數指定
- 若使用非 Ubuntu-24.04 的 WSL 發行版，需修改腳本中的 `wsl.exe -d` 參數
- 建立 Symbolic Link 失敗時會自動降級為其他連結方式或複製
- 使用複製方式時，需重新執行腳本才能同步更新
