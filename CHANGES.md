# B9CodeCopilot 基于 kilo-code 的修改记录

本文档汇总记录了对 kilo-code 项目的修改内容。对已有文件的修改会用下面的方式标记：

```c
// ⬇️ b9_change
// ⬆️ b9_change
```

## 移除 JetBrains 插件相关代码

```diff
- jetbrains/                                          # JetBrains 插件目录（Kotlin 插件 + Node.js host）
- src/i18n/locales/*/jetbrains.json                   # 各语言 JetBrains 专用 i18n 命名空间
- src/services/autocomplete/__tests__/AutocompleteJetbrainsBridge.spec.ts
- src/services/autocomplete/AutocompleteJetbrainsBridge.ts  # JetBrains 自动补全桥接层
- src/services/commit-message/adapters/JetBrainsCommitMessageAdapter.ts  # JetBrains commit message 适配器
- src/services/commit-message/types/jetbrains.ts      # JetBrains 专用请求类型
- src/utils/fowardingLogger.ts                        # JetBrains MainThreadConsole RPC 日志转发工具
M .gitattributes                                      # 移除 jetbrains/plugin/platform.zip LFS 规则
M .github/ISSUE_TEMPLATE/bug_report.yml               # 移除 JetBrains Plugin 选项
M .github/workflows/code-qa.yml                       # 移除 test-jetbrains job
M .github/workflows/marketplace-publish.yml           # 移除 publish-jetbrains job
M .vscode/settings.json                               # 移除 jetbrains/host/deps/** 文件监视排除规则
M AGENTS.md                                           # 移除 jetbrains/ 目录说明及相关条目
M package.json                                        # 移除 jetbrains:* / jetbrains-host:* 脚本命令
M packages/types/src/vscode.ts                        # 移除 handleExternalUri command ID
M pnpm-workspace.yaml                                 # 移除 jetbrains/host、jetbrains/plugin 工作区
M src/activate/registerCommands.ts                    # 移除 handleExternalUri 命令（供 JetBrains 转发 auth token）
M src/api/providers/kilocode-openrouter.ts            # 移除 jetbrains-extension feature 分支
M src/core/kilocode/wrapper.ts                        # 移除 kiloCodeWrapperJetbrains 字段及 JETBRAIN_PRODUCTS 使用
M src/extension.ts                                    # 移除 registerMainThreadForwardingLogger 调用及其 import
M src/services/autocomplete/index.ts                  # 移除 registerAutocompleteJetbrainsBridge 调用
M src/services/commit-message/CommitMessageProvider.ts  # 移除 JetBrains adapter 及 handleJetBrainsCommand
M src/shared/kilocode/wrapper.ts                      # 移除 JETBRAIN_PRODUCTS 常量、kiloCodeWrapperJetbrains 接口字段
M turbo.json                                          # 移除 jetbrains:* / jetbrains-host:* turbo 任务
M webview-ui/src/components/kilocode/helpers.ts       # 移除 getJetbrainsUrlScheme，简化 getKiloCodeSource
```

## 忽略 pnpm-lock.yaml

修改稳定前不追踪 lock 文件变化，减少无意义工作量。

```diff
M .gitignore
- pnpm-lock.yaml
```

## 提交历史精简

新增通过原仓库 tag 重建提交分支的脚本，添加 GitHub Actions 自动同步工作流。
手动移除了部分文档中的视频、图片文件。

```diff
- scripts/kilocode/build-release-history.sh
- .github/workflows/sync-release-history.yml
```
