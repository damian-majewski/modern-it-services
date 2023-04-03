## Wprowadź następujące kroki, aby zastosować playbook:
 
1. Dostosuj inwentarz Ansible, aby wskazywał na swoje maszyny wirtualne. 
2. Upewnij się, że masz grupy:
- k8s-master dla węzła master Kubernetes 
- k8s-nodes dla pozostałych węzłów roboczych.
3. Uruchom playbook, wykonując polecenie:
`ansible-playbook -i inventory.ini playbook.yml`

Po zastosowaniu tego playbooka, będziesz miał działający klaster Kubernetes na swoich maszynach wirtualnych opartych na KVM lub Hyper-V. Teraz możesz kontynuować migrację swoich małych wewnętrznych usług do kontenerów Kubernetes, tworząc odpowiednie manifesty i korzystając z kubectl do zarządzania nimi.

Pamiętaj, że przed uruchomieniem playbooka, musisz zainstalować Ansible na swoim systemie oraz zainstalować wszystkie wymagane moduły. W przypadku Hyper-V, upewnij się, że masz odpowiednie moduły kernela dla Hyper-V zainstalowane na swoich maszynach.