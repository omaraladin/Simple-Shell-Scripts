#!/bin/bash
# This Works with Gitlab CI/CD as shell jobs

curl -s -X POST https://api.telegram.org/bot${myBotToken}/sendMessage -d chat_id=$myGroupChatId -d parse_mode="HTML" -d text="""
New code pushed to <b>$CI_COMMIT_BRANCH</b> branch! ✅
<b>Project</b> 🧩: $CI_PROJECT_NAME
<b>Committer</b> 👤: $GITLAB_USER_NAME
<b>Revision ID</b> 📝: $CI_COMMIT_SHORT_SHA
<b>Commit Message</b> 💬:
$CI_COMMIT_MESSAGE

Check code changes at the following commit URL 🔗:
$CI_PROJECT_URL/-/commit/$CI_COMMIT_SHA
"""
