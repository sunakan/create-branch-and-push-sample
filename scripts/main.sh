#!/usr/bin/env bash
set -eu -o pipefail
# set -x
# -e: エラーが発生した時点でスクリプトを終了
# -u: 未定義の変数を使用した場合にエラーを発生
# -x: スクリプトの実行内容を表示(debugで利用)
# -o pipefail: パイプライン内のコマンドが失敗した場合にパイプライン全体を失敗として扱う

readonly TARGET_BRANCH='storage'
readonly DATA_FILE='data.csv'

#
# ${DATA_FILE}を持ってくる
#
git fetch origin ${TARGET_BRANCH}
git branch -D ${TARGET_BRANCH} || echo ''
git branch ${TARGET_BRANCH} origin/${TARGET_BRANCH}
git restore --source ${TARGET_BRANCH} -- ${DATA_FILE}

#
# 処理 & dataを退避
#
echo "a,b,c,$(date)" >> ${DATA_FILE}
cat ${DATA_FILE} | tail -n 3 > tmp/${DATA_FILE}
rm data.csv

#
# dataを持ってくる
#
git switch ${TARGET_BRANCH}
mv tmp/data.csv ./

#
# Auto commit
#
# 自動でcommitする時のuserとemail指定の参考
# https://github.com/orgs/community/discussions/26560
#
git stage data.csv
readonly DEFAULT_USER_NAME='github-actions[bot]'
readonly DEFAULT_USER_EMAIL='41898282+github-actions[bot]@users.noreply.github.com'
readonly USER_NAME=$(git config user.name)
readonly USER_EMAIL=$(git config user.email)
git commit --amend --author="${USER_NAME:-${DEFAULT_USER_NAME}} <${USER_EMAIL:-${DEFAULT_USER_EMAIL}}>" -m "Automated commit"

#
# Force push
#
git push origin ${TARGET_BRANCH} --force

#
# 戻る
#
git switch -
