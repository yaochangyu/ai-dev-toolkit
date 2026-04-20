# 修正 sync-ai-agents.ps1 同步策略計畫

本計畫旨在將 `.github/sync-ai-agents.ps1` 的同步機制從預設的 **Symbolic Link** 改為 **Copy (複製)**，以提高穩定性並避免跨環境的路徑問題。同時提供解除連結的腳本。

## 實作步驟

- [x] 1. 建立計畫檔案
- [x] 2. 清理現有 Symlink (已手動執行 WSL 部分)
- [x] 3. 建立 `.github/unlink-ai-agents.ps1`：提供自動化清理功能。
- [ ] 4. 修改 `.github/sync-ai-agents.ps1`：
    - [ ] 新增 `[switch]$UseSymlink` 參數。
    - [ ] 預設邏輯改為 `Copy-Item -Recurse -Force`。
    - [ ] 調整 WSL 同步邏輯，根據參數決定使用 `cp -r` 或 `ln -sf`。
- [ ] 5. 測試驗證：
    - [ ] 驗證 Windows 環境下的複製功能。
    - [ ] 驗證 WSL 環境下的複製功能。
    - [ ] 驗證 `-UseSymlink` 參數是否正常運作。
