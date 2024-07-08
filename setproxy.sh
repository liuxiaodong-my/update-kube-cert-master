#!/bin/bash
ns_list=(elasticsearch)

for ns in ${ns_list[@]};do
  echo -e " 开始设置 $ns 命名空间下的deployment代理  开始时间：$(date "+%Y%m%d %T") \n" >> /var/log/setproxy_$(date +%F).log
  kubectl set env deployment --all http_proxy=http://10.130.42.173:3128 -n $ns >> /var/log/setproxy_$(date +%F).log
  kubectl set env deployment --all https_proxy=http://10.130.42.173:3128 -n $ns >> /var/log/setproxy_$(date +%F).log
  kubectl set env deployment --all no_proxy=localhost,127.0.0.1,10.0.0.0/8,.svc.cluster.local,.cluster.local,.picc-inv.com -n $ns >> /var/log/setproxy_$(date +%F).log
  echo -e " 设置 $ns 命名空间下的deployment代理结束 结束时间：$(date "+%Y%m%d %T")\n" >> /var/log/setproxy_$(date +%F).log
done
