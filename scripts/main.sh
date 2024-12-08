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
git stage data.csv
export GIT_AUTHOR_NAME="robot"
export GIT_AUTHOR_EMAIL="robot"
git commit --amend -m "Automated commit"

#
# Force push
#
git push origin ${TARGET_BRANCH} --force

#
# 戻る
#
git switch -
