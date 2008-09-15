require 'rubygems'
require 'pit'
require 'gena/mail'
require 'stores'
require 'logger'

begin
  logger = Logger.new 'tmcheck.log', 'monthly'
  logger.level = Logger::DEBUG

  config = Pit.get('tmcheck', :require => {
      'name' => 'name',
      'url' => 'url',
      'host' => 'host',
      'port' => 'port',
      'account' => 'your_account',
      'from' => 'your_address',
      'password' => 'your_password',
      'to' => 'to_address'
      })

  old = Stores.new :pre_latest
  now = Stores.new :latest
  #now.get
  #now.save

  diff = now.diff old

  logger.info "added: +#{diff[:added].length}, removed: #{diff[:removed].length}"

  if diff[:added].empty? && diff[:removed].empty?

  else
    report = <<-MAIL
#{config['name']} 登録店舗監視レポート

監視期間: #{old.date.simple_format}
　　　　～#{now.date.simple_format}
追加店舗: #{diff[:added].length} 件
削除店舗: #{diff[:removed].length} 件

    MAIL

    if diff[:added].empty?
    else
      report += "==========================\n"
      report += "以下の店舗が追加されました:\n"
      report += "==========================\n"
      report += diff[:added].join "\n"
      report += "\n"
    end

    if diff[:removed].empty?
    else
      report += "==========================\n"
      report += "以下の店舗が削除れました:\n"
      report += "==========================\n"
      report += diff[:removed].join "\n"
    end


    mail = Gena::Mail.new config
    mail['to'] = config['to']
    mail['from'] = config['from']
    mail['bcc'] = config['from']
    mail << report

    mail['subject'] = "#{config['name']}レポート(+#{diff[:added].length} -#{diff[:removed].length})"

    mail.send

    logger.info "Report mail was sent to #{config['to']} from #{config['from']}"
  end

  puts report

rescue => e
  logger.fatal e.backtrace.join("\n")
end

