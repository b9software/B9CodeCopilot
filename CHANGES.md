# B9CodeCopilot 基于 kilo-code 的修改记录

本文档汇总记录了对 kilo-code 项目的修改内容。对已有文件的修改会用下面的方式标记：

```c
// ⬇️ b9_change
// ⬆️ b9_change
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
