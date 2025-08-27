Local `Ollama` Provider BUT on Remote Server 
===
Extended from the original local [ollama deployment](../../../helm/README.md), but instead of deploying `Ollama` on the same server within a K8S cluster, here we use a remote server to host the LLM service.

# Preparison

1. Remote server running `Ollama`.  
    The LLM service is exposed with a IP:Port pair.
2. The rest is similar to the original case.

# Setup environment

1. Generate Chart.yaml for every case.  
    For some reason, you need to prepare your own Chart.yaml.
    While you can simply follow the template and do copy-and-paste, you still need to do a bit tweak, including setting your `${VERSION}` in each configuration file.
    As a result, I recommend you run this to save you lots of effort.
    ```console
    ~/git/kagent/contrib/tools/remote-ollama$ chmod +x prepare_helm_charts.sh
    ~/git/kagent$ ./contrib/tools/remote-ollama/prepare_helm_charts.sh ./helm
    ```
    This script would do all thing mentioned here.
2. Proceed to the normal route
    ```console
    ~/git/kagent$ helm install kagent-crds ./helm/kagent-crds/  --namespace kagent
    ~/git/kagent$ helm install kagent ./helm/kagent/ --namespace kagent --set providers.default=ollama
    ```
    (Might need to first install dependency before the install, need to check the logs here)
3. Redirect the LLM to your remote Ollama instance
   Remember to at least update the last line of `ollama-config.yaml` fitting to your testbed setting.
   Also check the `model` if it matching your LLM model used.
   ```console
   ~/git/kagent$ kubectl apply -f ./contrib/tools/remote-ollama/ollama-config.yaml
   ```
4. Some health check
   ```console
   ~/git/kagent$ kubectl -n kagent get agents
   ~/git/kagent$ kubectl get services --namespace kagent
   ```
   You should not see any *crash* or *not ready* kind of faulty status report.
5. Send out first request
   > I am using remote SSH thus I prefer teminal input.  
   First run port forwarding on one terminal
   ```console
   ~/git/kagent$ kubectl port-forward service/kagent-controller -n kagent [PORT]:[PORT]
   ```
   Modify the `PORT` matching your `kagent-controller` using `kubectl get services --namespace kagent`

   Then on the another terminal do
   ```console
   $ curl -X POST   http://localhost:8083/api/a2a/kagent/helm-agent/invoke   -H 'Content-Type: application/json'   -d '{"jsonrpc": "2.0", "id": "1", "method": "message/send", "params": {"message": {"role": "user", "parts": [{"kind": "text", "data": "What is the result of 2 + 2 ?"}]}}}'
   ```
   Replace the [PROMPT] with your prompt