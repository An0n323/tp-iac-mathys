# terraform-v1

Infrastructure as Code — provisionnement Terraform et configuration Ansible.

## Prérequis

- Terraform >= 1.7
- Ansible >= 2.16
- tflint, trivy, gitleaks installés localement
- Accès configuré au fournisseur cloud (variables d'environnement ou profil)

## Démarrage

\`\`\`bash
make help        # liste toutes les cibles disponibles
make tf.init      # initialise Terraform
make tf.pipe      # valide, planifie et scanne la configuration
make tf.apply     # applique le plan (--auto-approve)
\`\`\`
