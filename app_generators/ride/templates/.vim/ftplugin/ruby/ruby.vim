fun! LoadRubyTmp()
  :write! /tmp/ride.temp
  call system("screen -p 1 -X stuff \"load " . '\"/tmp/ride.temp\"' . "\n\"")
  call system("screen -X select 1")
endfun
nmap <F12> :call LoadRubyTmp()<CR>
