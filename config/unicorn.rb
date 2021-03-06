  $worker  = 2
  $timeout = 30
  $app_dir = "/var/www/rails/My_Gourmet"
  $listen  = File.expand_path 'tmp/sockets/unicorn.sock', $app_dir
  $pid     = File.expand_path 'tmp/pids/unicorn.pid', $app_dir
  $std_log = File.expand_path 'log/unicorn.log', $app_dir
  
  # アプリケーションサーバの性能
  worker_processes  $worker
  # アプリケーションが設置されているディレクトリを指定
  working_directory $app_dir
  # エラーのログを記録するファイルを指定
  stderr_path $std_log
  # 通常のログを記録するファイルを指定
  stdout_path $std_log
  # タイムアウト時間を設定
  timeout $timeout
  # ソケットファイルを指定
  listen  $listen
  # プロセスIDの保存先を指定
  pid $pid
  
  # loading booster
  preload_app true
  # before starting processes
  before_fork do |server, worker|
    defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
    old_pid = "#{server.config[:pid]}.oldbin"
    if old_pid != server.pid
      begin
        Process.kill "QUIT", File.read(old_pid).to_i
      rescue Errno::ENOENT, Errno::ESRCH
      end
    end
  end
  # after finishing processes
  after_fork do |server, worker|
    defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
  end