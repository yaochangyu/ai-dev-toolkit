# 注意事項
- 使用台灣用語的繁體中文進行回覆。
- 不知道的問題請直接回答「抱歉，我無法回答您的問題」。不要亂回答，不要裝 B。
- 回答時請保持簡潔明瞭，避免冗長的說明。
- 實作需求實際上沒有提到的部分，請不要自行添加。
- 實作功能前，列出實作計畫：
    - 每一個步驟以核取方塊形式呈現，並詳細描述為什麼需要這個步驟。
    - 建立計畫檔案，例如：`{功能名稱(英文)}.plan.md`，每一個步驟會有確認方塊
    - 完成每一個步驟，在 `{功能名稱(英文)}.plan.md` 對應的核取方塊打勾。
    - 待我確認後，才能實作程式碼。
    - 每次只實作一個步驟，完成後待我確認，才能進行下一個步驟；若我使用"自動執行"，才不需要等待確認。
    - 若任務中止，下次再開啟時，讀取 `{功能名稱(英文)}.plan.md`，詢問我是否需要從上次中止的地方繼續，
	- 若，`{功能名稱(英文)}.plan.md` 內所有的任務都完成了，則移動到封存資料夾 `.archive`。
- 當發生錯誤時，需要重試，你要記錄失敗的方法、步驟、原因，下次重試前，不要使用已經失敗過的方法，除非我要求你這麼做。
- @tree.md 檔案維護專案的資料夾結構：
    - 每次新增、刪除、移動檔案或資料夾時，都必須更新 @tree.md 檔案。
    - 被排除的檔案不需要紀錄
    - `.gitignore` 裡面定義的資料夾與檔案不需要紀錄
    - 排除資料夾：\bin\, \obj\
- 功能實作後，要確保功能正確運作
    - 一定要 build
    - 詢問我是否需要執行測試，若需要，則執行測試
    
# 開發原則
- 遵守 SOLID 開發原則
- .NET Core 的開發原則參考 `https://github.com/yaochangyu/api.template/blob/main/CLAUDE.md`
- Cucumber 的步驟，使用英文
- 排版參考 `.editorconfig\.net\.editorconfig`

# git
## git commit message 格式
1. 若沒有 ticket id，則詢問我是否需要加上 ticket id?
    - 若有 ticket id 最後一行加上，`Bundle: (ticket id)`
2. Write a concise commit message from 'git diff --staged' output in the format `[EMOJI] [TYPE](file/topic)(ticket id)): [description in {locale}]`. Use GitMoji emojis (e.g., ✨ → feat), present tense, active voice, max 120 characters per line, no code blocks.


注意：
- 回覆時，使用台灣用語的繁體中文
- 訊息不可以包含 Co-authored-by

## git worktree 衝突解決
   1. 開啟 `git rerere`。
   2. 在 其中一個 worktree 執行 git rebase develop 並手動解衝突。
   3. 在 其他 worktree 執行 git rebase develop，git 會自動套用剛才的解法。

# 憑證管理
- 所有環境的憑證集中存放於 `~/.claude/creds/.creds`

# 專案對應
- 工作專案對應表格維護在 `/mnt/d/lab/gitlab-work/project_mapping.csv`

# 基礎建設
- 服務位置 `~/.claude/infa.md`

# LLM Wiki
- Wiki 知識庫路徑：`/mnt/d/lab/llm-wiki/`
- 操作規則參考：`/mnt/d/lab/llm-wiki/CLAUDE.md`
- 專案根目錄：`/mnt/d/lab/`
- 工作專案程式碼路徑：對應表見 `/mnt/d/lab/gitlab-work/project_mapping.csv`）
- Ingest 程式碼時，直接從原始路徑讀取，不需複製到 `sources/`
- `sources/` 只放外部資料（文章、論文、技術文件等沒有 repo 的資料）
- wiki 頁面的 frontmatter `sources` 欄位，程式碼引用使用絕對路徑（如 `/mnt/d/lab/gitlab-work/job/customer-api/src/...`）

# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

# goole workspace
當需要使用 Google Workspace 相關工具（如 Gmail、Google Drive、Google Calendar 等）時，請遵循以下指導原則：
- 使用 googleworkspace cli 參考：`https://github.com/googleworkspace/cli`
