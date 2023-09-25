# V2Ray Telegram bot
**A privacy-respecting telegram bot that shows the information and traffic status of x-ui panel clients**

## Easy Install Script

```
bash <(curl -Ls https://raw.githubusercontent.com/m0h4mad/v2ray-tel-bot/dev/easyinstall.sh)
```

## Install Manually
### old installer script
```
bash <(curl -Ls https://raw.githubusercontent.com/m0h4mad/v2ray-tel-bot/dev/install.sh)
```
### configure the settings
1. Enter the bot source folder using the command `cd ~/v2ray-tel-bot/`
2. open the config.yml file and put your Telegram bot token and information related to your panels in it. open with `nano config/config.yml`.
3. If you want to customize the Telegram bot messages, edit the `messages.yml` file using the `nano config/messages.yml` command
4. restart your server using the `reboot` command.
