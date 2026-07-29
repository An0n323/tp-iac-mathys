# TP1 — Rapport

## 1. Pourquoi `--no-verify` fonctionne-t-il, et quelle est la seule parade réellement efficace ?

Les hooks `pre-commit` s'exécutent en local, sur ma machine : Git permet de les sauter volontairement avec `--no-verify`, sans aucune restriction. Je l'ai vérifié directement : `gitleaks` a bloqué mon commit contenant une fausse clé AWS, mais `git commit --no-verify` a suffi à le créer quand même.

**Parade efficace** : déplacer le contrôle côté serveur (CI/CD) + protection de branche. Je l'ai constaté en Partie D : même en tant que propriétaire du dépôt, mon push direct sur `master` a été refusé (`GH006: Protected branch update failed`). Un hook local ne peut jamais offrir cette garantie ; c'est un filet de confort, pas un contrôle de sécurité.

## 2. Le secret purgé était-il présent sur le remote ? Que faire en premier s'il avait été réel ?

Non : j'ai purgé le secret avec `git filter-repo` **avant** de pousser quoi que ce soit vers GitHub, il n'a donc jamais quitté ma machine.

Si le secret avait été réel et déjà poussé, l'ordre aurait dû être :
1. **Révoquer immédiatement** la clé chez l'émetteur (console AWS IAM) — ça neutralise la fuite en quelques secondes.
2. Générer un nouveau secret, le stocker dans un coffre.
3. Vérifier les journaux d'usage (CloudTrail) pour voir s'il a déjà servi.
4. Réécrire l'historique en dernier.

Réécrire avant de révoquer donne un faux sentiment de sécurité : le secret reste valide tant qu'il n'est pas révoqué, purge ou pas.

## 3. En quoi la mutabilité des tags explique-t-elle l'incident tj-actions/changed-files ?

Un tag est un pointeur nommé qu'on peut réécrire (`git tag -f` + `push --force --tags`) sans que son nom change, contrairement à une empreinte de commit (SHA), qui est immuable. L'attaquant a réécrit tous les tags de `tj-actions/changed-files` pour pointer vers un commit malveillant : les dépôts qui référençaient l'action par tag (`@v45`) ont exécuté le code malveillant sans qu'aucune de leurs propres configs ne change. Seul un épinglage par SHA complet aurait bloqué l'attaque.

Principe retenu : **un nom lisible est mutable, une empreinte de contenu est une identité.**

## 4. Trois éléments de ce dépôt relevant de la gestion de configuration ITIL

1. **Les fichiers Terraform** (`main.tf`, `variables.tf`, `outputs.tf`) : décrivent l'état souhaité de l'infrastructure — le dépôt Git fait office de CMDB exécutable.
2. **`.terraform.lock.hcl`** : fige les versions/empreintes des providers — c'est une baseline au sens ITIL, un état de référence approuvé.
3. **Les règles de protection de la branche `master`** (revue obligatoire, signatures vérifiées, interdiction du force push) : elles définissent qui peut modifier la CMDB et dans quelles conditions — au cœur de la gestion de configuration ITIL.
