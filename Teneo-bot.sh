#!/bin/bash

# 定义颜色
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# 显示标题
echo "${YELLOW}${BOLD}====================================="
echo "Teneo robot自动化安装脚本 "
echo "by deny"
echo "=====================================${RESET}"

# 保存初始目录
START_DIR=$(pwd)

# 导入配置文件
node -e "console.log(JSON.stringify(require('./config.js')));" > config.json
CONFIG_PAIRS=$(cat config.json)

# 菜单函数
show_menu() {
  echo ""
  echo "${BLUE}${BOLD}请选择操作:${RESET}"
  echo "${GREEN}1)${RESET} 安装依赖"
  echo "${GREEN}2)${RESET} 编辑账户和代理配置"
  echo "${GREEN}3)${RESET} 启动 Teneo 节点机器人"
  echo "${GREEN}4)${RESET} 退出"
  echo ""
}

# 克隆仓库并安装依赖
clone_and_install_dependencies() {
  if [ -d "teneo-node-bot" ]; then
    echo "${YELLOW}teneo-node-bot 目录已存在，跳过克隆。${RESET}"
  else
    echo "${BLUE}正在克隆仓库...${RESET}"
    git clone https://github.com/ziqing888/teneo-node-bot.git || { echo "${RED}克隆仓库失败${RESET}"; exit 1; }
  fi

  echo "${BLUE}进入 teneo-node-bot 目录并安装依赖...${RESET}"
  cd teneo-node-bot || { echo "${RED}无法进入 teneo-node-bot 目录${RESET}"; exit 1; }
  npm install && npm run setup || { echo "${RED}依赖安装失败${RESET}"; exit 1; }
  cd "$START_DIR"
  echo "${GREEN}依赖安装完成！${RESET}"
}

# 编辑账户和代理配置
edit_config() {
  echo "${BLUE}打开配置文件 (config.js) 进行编辑...${RESET}"
  nano config.js
}

# 启动项目
start_project() {
  echo "${BLUE}启动 Teneo 节点机器人...${RESET}"

  for pair in $(echo "${CONFIG_PAIRS}" | jq -c '.[]'); do
    account_email=$(echo "$pair" | jq -r '.account.email')
    account_password=$(echo "$pair" | jq -r '.account.password')
    proxy_host=$(echo "$pair" | jq -r '.proxy.host')
    proxy_port=$(echo "$pair" | jq -r '.proxy.port')
    proxy_username=$(echo "$pair" | jq -r '.proxy.username')
    proxy_password=$(echo "$pair" | jq -r '.proxy.password')

    echo "使用账户: ${account_email} 通过代理: ${proxy_host}:${proxy_port}"

    # 在 teneo-node-bot 目录中启动机器人，并传递账户和代理配置
    cd teneo-node-bot || { echo "${RED}无法进入 teneo-node-bot 目录${RESET}"; exit 1; }

    # 示例：假设 npm start 可以接受环境变量
    ACCOUNT_EMAIL="$account_email" ACCOUNT_PASSWORD="$account_password" \
    PROXY_HOST="$proxy_host" PROXY_PORT="$proxy_port" \
    PROXY_USERNAME="$proxy_username" PROXY_PASSWORD="$proxy_password" \
    npm run start || { echo "${RED}启动失败${RESET}"; exit 1; }

    cd "$START_DIR"
  done
}

# 主逻辑
while true; do
  show_menu
  read -p "请选择一个选项 (1-4): " choice
  case $choice in
    1)
      clone_and_install_dependencies
      ;;
    2)
      edit_config
      ;;
    3)
      start_project
      ;;
    4)
      echo "${YELLOW}退出脚本。${RESET}"
      exit 0
      ;;
    *)
      echo "${RED}无效选项，请重新选择。${RESET}"
      ;;
  esac
done
