#!/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin

#-------------------------------------------------------------
host=$(hostname -I|awk '{print $1}')
keep_time="10"
today=$(date +%Y%m%d)
yesterday=$(date -d"1 day ago" +"%Y%m%d")
base_dir="/data/backup/podpreset"
env="中国人保-生产环境"
webhook_url="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=a45ed839-71f0-4e1a-a42c-3a1bf2faeb23"

change_ns_list=()
change_pod_list=()
#---------------------------------------------------------------


[[ -d ${base_dir}/${today} ]] || mkdir -p ${base_dir}/${today}

podpreset_namespace_list=($(kubectl get podpresets.redhatcop.redhat.io -A --no-headers | awk '{print $1}'))
for (( i=1; i<${#podpreset_namespace_list[@]}; i++ ));do
  kubectl -n ${podpreset_namespace_list[$i]} get podpresets.redhatcop.redhat.io network-proxy -ojson|jq '.spec.env[]' > ${base_dir}/${today}/${podpreset_namespace_list[$i]}.yaml
  # 对比podpreset是否存在差异
  if [[ -d ${base_dir}/${yesterday} ]];then
    diff ${base_dir}/${today}/${podpreset_namespace_list[$i]}.yaml ${base_dir}/${yesterday}/${podpreset_namespace_list[$i]}.yaml >/dev/null 2>&1 || change_ns_list[${i}]=${podpreset_namespace_list[$i]};echo "ns:${podpreset_namespace_list[$i]}"
  else
    change_ns_list[${i}]=${podpreset_namespace_list[$i]}
  fi
  # 对比pod引用podpreset是否异常
  pod_list=$(kubectl -n ${podpreset_namespace_list[$i]} get pods --no-headers|awk '{print $1}')
  for pod in ${pod_list[@]};do
    kubectl -n ${podpreset_namespace_list[$i]} get pods ${pod} -ojson|jq  -r '.spec.containers[0].env[]| select(.name|test(".*proxy.*"))' >${base_dir}/${today}/${pod}.yaml 2>/dev/null
    diff ${base_dir}/${today}/${podpreset_namespace_list[$i]}.yaml  ${base_dir}/${today}/${pod}.yaml >/dev/null 2>&1|| change_pod_list[${#change_pod_list[@]}]=${pod};echo "pod:$pod"
  done
done

if [ ${#change_ns_list[@]} -eq 0 ] || [ ${#change_pod_list[@]} -eq 0 ];then
  status="Success"
  status_col="info"
else
  status="Failed"
  status_col="warning"

fi


contents='{
  "msgtype": "markdown",
  "markdown": {
    "content": "
       # '${env}' podpreset监控 \\n
       >状态: <font color=\"'${status_col}'\">'${status}'</font> \\n
       >主机: <font color=\"comment\">'${host}'</font> \\n
       >发生变化的命名空间: <font color=\"comment\">'${change_ns_list[@]}'</font> \\n
       >发生变化的pod: <font color=\"comment\">'${change_pod_list[@]}'</font> \\n
       >目录: <font color=\"comment\">'${base_dir}/${today}'</font> \\n"
   }
}'


echo -e ${contents} > ${base_dir}/webhook.json

curl -X POST -i -H 'Content-Type: application/json' -d @${base_dir}/webhook.json ${webhook_url}
# 删除之前的文件目录
find ${base_dir} -maxdepth 1 -type d -mtime  +${keep_time} |xargs rm -rf {};


