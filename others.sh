#rm -rf admin.conf controller-manager.conf kubelet.conf scheduler.conf
kubeadm completion bash > /etc/bash_completion.d/kubeadm.sh
source /etc/bash_completion.d/kubeadm.sh
cd /etc/kubernetes/
mv /etc/kubernetes/kubelet.conf  /etc/kubernetes/kubelet.conf.org
kubeadm init phase kubeconfig kubelet
#kubeadm init phase kubeconfig all

#master
#在master上生成worker所需要的kubelet.conf临时放在/tmp下
#mkdir -p /tmp/worker
 
#生成node1所需要的kubelet.conf文件。注意更改成自己的信息
kubectl get nodes -owide --no-headers | grep -v control-plane | awk '{ print "kubeadm init --kubernetes-version=" $5 " phase kubeconfig kubelet --node-name " $1 " --kubeconfig-dir /tmp/  && scp /tmp/kubelet.conf root@" $6 ":/etc/kubernetes/ && rm -rf /tmp/kubelet.conf"}' | xargs -I{} sh -c '{}'

kubectl get nodes -owide --no-headers | grep -v control-plane | awk '{ print $6}' | xargs -I{} ssh {} 'systemctl restart kubelet'

kubeadm init --kubernetes-version=$(k8s-version) phase kubeconfig kubelet --node-name vms32.rhce.cc --kubeconfig-dir /tmp/worker/ && scp /tmp/worker/kubelet.conf root@vms32.rhce.cc:/etc/kubernetes/
rm -rf /tmp/worker/kubelet.conf
kubeadm init --kubernetes-version=v1.25.2 phase kubeconfig kubelet --node-name vms33.rhce.cc --kubeconfig-dir /tmp/worker/
scp /tmp/worker/kubelet.conf root@vms33.rhce.cc:/etc/kubernetes/

#kubeadm init phase kubeconfig kubelet --node-name test1 --kubeconfig-dir /tmp/ --apiserver-advertise-address 192.168.180.45
#[kubeconfig] Writing “kubelet.conf” kubeconfig file
 
#node1(192.168.0.191)上的/etc/kubernetes/目录里覆盖原来的kubelet.conf。先备份原先node1的kubelet.conf文件：
mv /etc/kubernetes/kubelet.conf /etc/kubernetes/kubeletconf.bak
 
scp /tmp/worker/kubelet.conf root@192.168.0.191:/etc/kubernetes/


#node


openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -text | grep Not


kubectl get csr
 
kubectl certificate approve csr-vg9bd

#查看kubelet当前所使用的证书
[root@master kubernetes]# ll -a /var/lib/kubelet/pki/
 
 
#通过kubeadm certs renew all更新的 k8s 证数，是不会更新 kubelet.conf 的证书的。
#所以此处的证书重启kubelet cho重新生成。
#因为前面已经重新生成了kubelet.conf，现在重启kubelet。
[root@master kubernetes]# systemctl restart kubelet
 
 
[root@master kubernetes]# ll -a /var/lib/kubelet/pki/
source <(kubeadm completion bash) > /etc/bash_completion.d/kubeadm.sh