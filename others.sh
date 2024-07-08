#rm -rf admin.conf controller-manager.conf kubelet.conf scheduler.conf
kubeadm completion bash > /etc/bash_completion.d/kubeadm.sh
source /etc/bash_completion.d/kubeadm.sh
cd /etc/kubernetes/
mv /etc/kubernetes/kubelet.conf  /etc/kubernetes/kubelet.conf.org
kubeadm init phase kubeconfig kubelet
#kubeadm init phase kubeconfig all

#master
#��master������worker����Ҫ��kubelet.conf��ʱ����/tmp��
#mkdir -p /tmp/worker
 
#����node1����Ҫ��kubelet.conf�ļ���ע����ĳ��Լ�����Ϣ
kubectl get nodes -owide --no-headers | grep -v control-plane | awk '{ print "kubeadm init --kubernetes-version=" $5 " phase kubeconfig kubelet --node-name " $1 " --kubeconfig-dir /tmp/  && scp /tmp/kubelet.conf root@" $6 ":/etc/kubernetes/ && rm -rf /tmp/kubelet.conf"}' | xargs -I{} sh -c '{}'

kubectl get nodes -owide --no-headers | grep -v control-plane | awk '{ print $6}' | xargs -I{} ssh {} 'systemctl restart kubelet'

kubeadm init --kubernetes-version=$(k8s-version) phase kubeconfig kubelet --node-name vms32.rhce.cc --kubeconfig-dir /tmp/worker/ && scp /tmp/worker/kubelet.conf root@vms32.rhce.cc:/etc/kubernetes/
rm -rf /tmp/worker/kubelet.conf
kubeadm init --kubernetes-version=v1.25.2 phase kubeconfig kubelet --node-name vms33.rhce.cc --kubeconfig-dir /tmp/worker/
scp /tmp/worker/kubelet.conf root@vms33.rhce.cc:/etc/kubernetes/

#kubeadm init phase kubeconfig kubelet --node-name test1 --kubeconfig-dir /tmp/ --apiserver-advertise-address 192.168.180.45
#[kubeconfig] Writing ��kubelet.conf�� kubeconfig file
 
#node1(192.168.0.191)�ϵ�/etc/kubernetes/Ŀ¼�︲��ԭ����kubelet.conf���ȱ���ԭ��node1��kubelet.conf�ļ���
mv /etc/kubernetes/kubelet.conf /etc/kubernetes/kubeletconf.bak
 
scp /tmp/worker/kubelet.conf root@192.168.0.191:/etc/kubernetes/


#node


openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -text | grep Not


kubectl get csr
 
kubectl certificate approve csr-vg9bd

#�鿴kubelet��ǰ��ʹ�õ�֤��
[root@master kubernetes]# ll -a /var/lib/kubelet/pki/
 
 
#ͨ��kubeadm certs renew all���µ� k8s ֤�����ǲ������ kubelet.conf ��֤��ġ�
#���Դ˴���֤������kubelet cho�������ɡ�
#��Ϊǰ���Ѿ�����������kubelet.conf����������kubelet��
[root@master kubernetes]# systemctl restart kubelet
 
 
[root@master kubernetes]# ll -a /var/lib/kubelet/pki/
source <(kubeadm completion bash) > /etc/bash_completion.d/kubeadm.sh