Work Items Azure DevOps - Déploiement Modulaire OC-Monitor
## WI0 - Setup Initial
 WI0.3 - Configurer compte utilisateur avec permissions : - Monitoring Contributor - Log Analytics Contributor
- Application Insights Component Contributor - Storage Account Contributor
## WI1 - Configuration Environnements
 WI1.1 - Créer Variable Groups avec compte utilisateur - oc-monitor-dev (ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID) - oc-monitor-prod
 WI1.2 - Créer Service Connections Azure (User Account)
 WI1.3 - Valider accès Storage Accounts backend Terraform
## WI2 - Module Core (Action Group)
 WI2.1 - Pipeline déploiement Action Group DEV
 WI2.2 - Test notifications email
 WI2.3 - Pipeline déploiement Action Group PROD
 WI2.4 - Validation cross-environnement
## WI3 - Module Storage
 WI3.1 - Déployer supervision Storage Accounts DEV
 WI3.2 - Test alertes disponibilité < 99%
 WI3.3 - Test Activity Log Alerts (création/suppression containers)
 WI3.4 - Déploiement PROD + validation
## WI4 - Module Network
 WI4.1 - Déployer supervision NAT Gateway DEV
 WI4.2 - Test alerte DatapathAvailability < 99%
 WI4.3 - Validation diagnostics VNet
 WI4.4 - Déploiement PROD + tests
## WI5 - Module Key Vault
 WI5.1 - Déployer supervision Key Vault DEV
 WI5.2 - Test alerte disponibilité < 99%
 WI5.3 - Validation logs AuditEvent
 WI5.4 - Déploiement PROD + validation
## WI6 - Module Virtual Machines
 WI6.1 - Déployer supervision VM DEV
 WI6.2 - Test alerte CPU > 80%
 WI6.3 - Test alerte disponibilité réseau
 WI6.4 - Déploiement PROD + tests
## WI7 - Module App Services
 WI7.1 - Déployer supervision Function Apps DEV
 WI7.2 - Test alertes HTTP 5xx > 5 et Response Time > 5000ms
 WI7.3 - Test alertes App Service Plan (CPU/Memory > 80%)
 WI7.4 - Déploiement PROD + validation complète
## WI8 -Installer l'application Microsoft Fabric Capacity Metrics
## WI9 - 
## WI9 - Tests d'Intégration
 WI8.1 - Test end-to-end toutes alertes DEV
 WI8.2 - Validation notifications email fonctionnelles
## WI10 - Go-Live Production
 WI9.1 - Déploiement séquentiel tous modules PROD
 WI9.2 - Validation post-déploiement
 WI9.3 -  Documentation opérationnelle
