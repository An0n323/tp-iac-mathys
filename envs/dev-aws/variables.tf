variable "region" {
  description = "Région AWS cible."
  type        = string
  default     = "us-east-1"
}

variable "projet" {
  description = "Nom du projet, utilisé pour préfixer les ressources."
  type        = string
  default     = "tp-iac"
}

variable "environnement" {
  description = "Nom de l'environnement."
  type        = string
  default     = "dev"
}

variable "proprietaire" {
  description = "Ton nom, pour l'étiquetage Owner."
  type        = string
}

variable "cidr_admin" {
  description = "Ton adresse IP publique en /32, pour restreindre SSH."
  type        = string
}

variable "nom_cle_ssh" {
  description = "Nom de la paire de clés EC2 existante."
  type        = string
}
