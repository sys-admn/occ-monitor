# Azure Monitoring Infrastructure

Infrastructure Terraform pour la supervision des ressources Azure avec alertes centralisées et déploiement modulaire.

## Architecture

- **Log Analytics centralisé** : Hub unique pour tous les logs et métriques
- **Action Group unifié** : Notifications centralisées par environnement
- **Modules modulaires** : Déploiement indépendant par type de ressource
- **Pipelines Azure DevOps** : Déploiement automatisé avec compte utilisateur

## Structure

```
├── environments/           # Configuration par environnement
│   ├── dev.tfvars
│   └── prod.tfvars
├── modules/               # Modules de supervision
│   ├── app-services/      # Functions, Static Web Apps, ASP
│   ├── keyvault/         # Key Vault monitoring
│   ├── network/          # VNet, NAT Gateway
│   ├── storage/          # Storage Accounts + Blob Activity Alerts
│   └── vm/               # Virtual Machines
├── action-group.tf       # Action Group centralisé
├── alert-config.tf       # Configuration des alertes
├── backend-dev.tf        # Backend Terraform Dev
├── backend-prod.tf       # Backend Terraform Prod
├── main.tf              # Configuration principale
├── monitoring-dev-pipeline.yml    # Pipeline Dev
├── monitoring-prod-pipeline.yml   # Pipeline Prod
└── TODO-LIST.md         # Work Items déploiement
```

## Ressources surveillées

### Storage Accounts
- **Métriques** : Availability < 99%
- **Activity Logs** : Création/Suppression containers blob
- **Diagnostics** : Transaction metrics vers Log Analytics

### Azure Functions
- **Erreurs** : HTTP 5xx > 5 occurrences
- **Performance** : Response time > 5000ms
- **Logs** : FunctionAppLogs vers Log Analytics

### App Service Plans
- **CPU** : CpuPercentage > 80%
- **Mémoire** : MemoryPercentage > 80%
- **Diagnostics** : AllMetrics vers Log Analytics

### Key Vault
- **Disponibilité** : Availability < 99%
- **Audit** : AuditEvent logs vers Log Analytics

### Virtual Machines
- **CPU** : Percentage CPU > 80%
- **Réseau** : Network In Total < 1 (proxy availability)
- **Diagnostics** : AllMetrics vers Log Analytics

### Network
- **NAT Gateway** : DatapathAvailability < 99%
- **VNet** : VMProtectionAlerts + AllMetrics

## Configuration

### Variables d'environnement

**Dev (`dev.tfvars`)**:
```hcl
environment = "dev"
env_suffix = "d"
alert_email_addresses = [
  "a.sall@groupeonepoint.com",
  "a.sall@orangeconcessions.com"
]
```

**Prod (`prod.tfvars`)**:
```hcl
environment = "prod"
env_suffix = "p"
alert_email_addresses = [
  "a.sall@groupeonepoint.com",
  "a.sall@orangeconcessions.com"
]
```

### Azure DevOps

**Prérequis d'accès**:
- Accès pool "Azure Pipelines" agents
- Permissions "Project administrators" pour créer repository

**Compte utilisateur avec permissions**:
- Monitoring Contributor
- Log Analytics Contributor
- Application Insights Component Contributor
- Storage Account Contributor

**Variable Groups requis**:
- `data-development` : Credentials Dev
- `data-production` : Credentials Prod

**Variables nécessaires**:
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

## Déploiement

**Stratégie** : Déploiement modulaire via Azure DevOps Pipelines

**Pipelines**:
- **Dev** : Trigger sur branche `master` avec pool `Default`
- **Prod** : Trigger manuel avec validation

**Backend Terraform**:
- Dev: `datacfstd` / container `tfstatesmonitor-d`
- Prod: `datacfstp` / container `tfstatesmonitor-p`

**Work Items** : Voir `TODO-LIST.md` pour la séquence de déploiement

## Outputs

- `log_analytics_workspace_id` : ID du workspace central
- `central_action_group_id` : ID de l'action group
- `*_monitoring` : IDs des ressources et alertes par module

## Seuils d'alertes

| Ressource | Métrique | Seuil | Sévérité |
|-----------|----------|-------|----------|
| Storage | Availability | < 99% | Warning |
| Storage | Blob Container Ops | Activity | Info |
| Function | HTTP 5xx | > 5 | Critical |
| Function | Response Time | > 5000ms | Warning |
| ASP | CPU Percentage | > 80% | Warning |
| ASP | Memory Percentage | > 80% | Warning |
| VM | CPU Percentage | > 80% | Warning |
| VM | Network In Total | < 1 | Critical |
| Key Vault | Availability | < 99% | Critical |
| NAT Gateway | Datapath Availability | < 99% | Warning |

## Rétention

- **Métriques Azure Monitor** : 93 jours
- **Log Analytics** : Configurable par environnement
- **Diagnostic Settings** : Envoi automatique vers Log Analytics central