# 쿠버네티스 대시보드 설치

## 실행 방법
> 먼저 Worker node에 dashboard 관련 docker image가 준비되어 있어야 한다.   
`script/download` 디렉토리의 `dashboard-download.sh` 스크립트를 통해서 다운로드 받을 수 있다.

Master node에서 yaml 파일들을 실행한다.

```bash
kubectl apply -f kube-dashboard.yaml
kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f metrics-server.yaml
```

## 설명
### `kube-dashboard.yaml`
> [kubernetes dashboard github](https://github.com/kubernetes/dashboard)에서 yaml파일 참고

kubernetes dashboard를 구성하는 yaml 파일이다.
  
- 변경사항
  - `imagePullPolicy`를 `IfNotPresent`로 명시했다.
  - `kubernetes-dashboard.service`의 타입을 NodePort로 변경하고, Port를 추가했다.

### `dashboard-adminuser.yaml`
> [Creating sample user](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)에서 yaml파일 참고   

dashboard에 접근할 수 있는 권한을 가진 유저를 생성하기 위한 yaml 파일이다.
  
### `metrics-server.yaml`
> [metrics-server github](https://github.com/kubernetes-sigs/metrics-server)에서 yaml파일 참고

kubelet에서 리소스 메트릭을 수집하는 metrics-server를 배포하기 위한 yaml 파일이다.

- 변경사항
  - `spec.template.spec.args`에 `- --kubelet-insecure-tls` 설정을 추가해준다. 

## 참고자료
> [Deploy and Access the Kubernetes Dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)   
[kubernetes dashboard github](https://github.com/kubernetes/dashboard)   
[metrics-server github](https://github.com/kubernetes-sigs/metrics-server)