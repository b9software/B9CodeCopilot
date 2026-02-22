#!/usr/bin/env bash
# build-release-history.sh
#
# 依据 org 远端的 v* tag，在本地创建/更新 release-history 分支。
# 分支上每个 commit 对应一个 tag 的完整代码快照，按 tag commit 时间排序。
#
# 用法:
#   ./scripts/kilocode/build-release-history.sh
#
# 重复执行时会自动检测新 tag 并追加 commit，不重建已有历史。

set -euo pipefail

BRANCH="release-history"
ORG_REMOTE="org"
TAG_PATTERN="v[0-9]*"

# ── 颜色输出 ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()   { echo -e "${GREEN}[OK]${NC}    $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()  { echo -e "${RED}[ERR]${NC}   $*" >&2; }

# ── 1. 从 org 拉取最新 tag ────────────────────────────────────────────────────
log "Fetching tags from '$ORG_REMOTE'..."
git fetch "$ORG_REMOTE" --tags --quiet
ok "Fetch done."

# ── 2. 获取所有 v* tag，按对应 commit 的时间戳升序排列 ────────────────────────
log "Sorting tags by commit date..."

# 收集: "<unix_timestamp> <tag>"，然后按时间排序
SORTED_TAGS=$(
  git tag -l "$TAG_PATTERN" | while IFS= read -r tag; do
    ts=$(git log -1 --format="%ct" "${tag}^{commit}" 2>/dev/null) || continue
    printf '%s\t%s\n' "$ts" "$tag"
  done | sort -k1,1n | cut -f2
)

if [[ -z "$SORTED_TAGS" ]]; then
  err "No tags found matching '$TAG_PATTERN'. Aborting."
  exit 1
fi

TOTAL=$(printf '%s\n' "$SORTED_TAGS" | wc -l | tr -d ' ')
ok "Found $TOTAL tags."

# ── 3. 确定需要新增的 tag ──────────────────────────────────────────────────────
PARENT_COMMIT=""
TAGS_TO_ADD=()

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  log "Branch '$BRANCH' already exists, checking for new tags..."

  # 已处理的 tag 从 commit message（格式: "release: <tag>"）中读取
  EXISTING_TAGS=$(git log "$BRANCH" --format="%s" | grep "^release: " | sed 's/^release: //')

  while IFS= read -r tag; do
    if ! printf '%s\n' "$EXISTING_TAGS" | grep -qx "$tag"; then
      TAGS_TO_ADD+=("$tag")
    fi
  done <<< "$SORTED_TAGS"

  if [[ ${#TAGS_TO_ADD[@]} -eq 0 ]]; then
    ok "No new tags. Branch '$BRANCH' is up to date."
    exit 0
  fi

  PARENT_COMMIT=$(git rev-parse "$BRANCH")
  log "${#TAGS_TO_ADD[@]} new tag(s) to append: ${TAGS_TO_ADD[*]}"
else
  log "Branch '$BRANCH' does not exist, will create from scratch."
  while IFS= read -r tag; do
    TAGS_TO_ADD+=("$tag")
  done <<< "$SORTED_TAGS"
fi

# ── 4. 用 git plumbing 依次创建 commit（不改动工作目录）─────────────────────
DONE=0
for tag in "${TAGS_TO_ADD[@]}"; do
  # 解析 tag 指向的 tree
  TREE=$(git rev-parse "${tag}^{tree}" 2>/dev/null) || {
    warn "Cannot resolve tree for '$tag', skipping."
    continue
  }

  # 使用 tag 对应 commit 的时间作为 commit 时间
  COMMIT_DATE=$(git log -1 --format="%aI" "${tag}^{commit}" 2>/dev/null) || COMMIT_DATE=$(date --iso-8601=seconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")

  # 构建 commit（第一个 commit 无父节点，后续 commit 有 -p）
  if [[ -n "$PARENT_COMMIT" ]]; then
    NEW_COMMIT=$(
      GIT_AUTHOR_NAME="github-actions[bot]" \
      GIT_AUTHOR_EMAIL="github-actions[bot]@users.noreply.github.com" \
      GIT_AUTHOR_DATE="$COMMIT_DATE" \
      GIT_COMMITTER_NAME="github-actions[bot]" \
      GIT_COMMITTER_EMAIL="github-actions[bot]@users.noreply.github.com" \
      GIT_COMMITTER_DATE="$COMMIT_DATE" \
      git commit-tree "$TREE" -p "$PARENT_COMMIT" -m "release: $tag"
    )
  else
    NEW_COMMIT=$(
      GIT_AUTHOR_NAME="github-actions[bot]" \
      GIT_AUTHOR_EMAIL="github-actions[bot]@users.noreply.github.com" \
      GIT_AUTHOR_DATE="$COMMIT_DATE" \
      GIT_COMMITTER_NAME="github-actions[bot]" \
      GIT_COMMITTER_EMAIL="github-actions[bot]@users.noreply.github.com" \
      GIT_COMMITTER_DATE="$COMMIT_DATE" \
      git commit-tree "$TREE" -m "release: $tag"
    )
  fi

  PARENT_COMMIT="$NEW_COMMIT"
  DONE=$((DONE + 1))

  # 每 10 个打印一次进度
  if (( DONE % 10 == 0 )); then
    log "  Progress: $DONE / ${#TAGS_TO_ADD[@]}"
  fi
done

if [[ -z "$PARENT_COMMIT" ]]; then
  err "No commits were created. Aborting."
  exit 1
fi

# ── 5. 更新分支指针 ────────────────────────────────────────────────────────────
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git branch -f "$BRANCH" "$PARENT_COMMIT"
  ok "Updated branch '$BRANCH' → $PARENT_COMMIT"
else
  git branch "$BRANCH" "$PARENT_COMMIT"
  ok "Created branch '$BRANCH' → $PARENT_COMMIT"
fi

ok "Done! Added $DONE commit(s) to '$BRANCH' (total tags processed: $TOTAL)."
echo ""
echo "  Push to origin:  git push origin $BRANCH"
echo "  Push (force):    git push -f origin $BRANCH"
