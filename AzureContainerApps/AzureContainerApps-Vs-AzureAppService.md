# Azure App Service vs Azure Container Apps - which to use?


## Scenario
La nostra azienda sta progettando di sviluppare un'applicazione web multitenant. Avremo diversi moduli, dove ogni modulo è composto da frontend e backend (come applicazioni separate).  
Quindi non si tratta di un monolite, ma nemmeno di un'architettura a microservizi. Questi moduli saranno condivisi tra più tenant, ma ci può essere un caso d'uso in cui un tenant specifico  
ha bisogno di una versione specifica di qualche modulo (ad esempio per avere qualche funzionalità aggiuntiva). 

Come decidere quale servizio di Azure sia più adatto in questo scenario? Usare Azure App Service o Azure Container Apps?

## Azure App Service
Azure App Service è una piattaforma completamente gestita che fornisce hosting per applicazioni web, compresi siti web e API web.  
È ottimizzato per le applicazioni web e offre una serie di funzionalità come lo scaling automatico, il bilanciamento del carico e l'integrazione con altri servizi Azure.  
Azure App Service è una buona scelta se volete concentrarvi sullo sviluppo della vostra applicazione e non preoccuparvi dell'infrastruttura sottostante.  
Offre inoltre un supporto integrato per i linguaggi di programmazione e i framework più diffusi.

## Azure Container Apps
Azure Container Apps è una piattaforma completamente gestita che fornisce hosting per applicazioni containerizzate.  
Offre una maggiore flessibilità rispetto ad Azure App Service, in quanto è possibile utilizzare qualsiasi immagine di container per eseguire l'applicazione.  
Offre inoltre funzionalità quali lo scaling automatico, il bilanciamento del carico e l'integrazione con altri servizi Azure.  
Azure Container Apps è una buona scelta se desiderate avere un maggiore controllo sull'infrastruttura sottostante e volete utilizzare i container per eseguire la vostra applicazione.

## Fattori di Scelta
Ecco alcuni fattori da considerare per decidere tra Azure App Service e Azure Container Apps:

**Flessibilità**: Se volete utilizzare qualsiasi immagine di container per eseguire la vostra applicazione, Azure Container Apps è la scelta migliore.  
Se invece volete utilizzare un linguaggio di programmazione o un framework specifico, Azure App Service è la scelta migliore.

**Controllo**: Se si desidera un maggiore controllo sull'infrastruttura sottostante, Azure Container Apps è la scelta migliore.  
Se volete concentrarvi sullo sviluppo della vostra applicazione e non preoccuparvi dell'infrastruttura sottostante, Azure App Service è la scelta migliore.

**Prezzi**: Azure Container Apps può essere più conveniente di Azure App Service se avete un gran numero di applicazioni da ospitare.  
Tuttavia, se il numero di applicazioni da ospitare è ridotto, Azure App Service può essere più conveniente.

**Scalabilità**: Sia Azure App Service che Azure Container Apps offrono una scalabilità automatica.  
Tuttavia, Azure Container Apps offre un controllo più granulare sulla scalabilità, in quanto è possibile scalare i singoli container.

## Guardiamo Avanti
Nell'ottica di vedere la nostra applicazione crescere, optiano per Azure Container Apps, proprio per garantire più controllo alla scalabilità.  
Quali sono i passi da seguire?  
Innanzitutto abbiamo bisogno di una sottoscrizione Azure. [Qui](https://azure.microsoft.com/en-us/free/search/?ef_id=_k_CjwKCAjwr7ayBhAPEiwA6EIGxLf0pLvReT-7F8Ifnwl2gR6WoUwhpeM1cFxo4w78U6X-W79pjBkIeBoCbTsQAvD_BwE_k_&OCID=AIDcmmy6frl1tq_SEM__k_CjwKCAjwr7ayBhAPEiwA6EIGxLf0pLvReT-7F8Ifnwl2gR6WoUwhpeM1cFxo4w78U6X-W79pjBkIeBoCbTsQAvD_BwE_k_&gad_source=1&gclid=CjwKCAjwr7ayBhAPEiwA6EIGxLf0pLvReT-7F8Ifnwl2gR6WoUwhpeM1cFxo4w78U6X-W79pjBkIeBoCbTsQAvD_BwE) trovate la documentazione per crearne una gratuita.  
Una volta creata la sottoscrizione possiamo procedere in due modi diversi.  
Possiamo creare il tutto direttamente dal [portale](https://portal.azure.com/#home), ma durante la Gilda abbiamo trovato qualche limitazione.  
Come alternativa possiamo usare la CLI e fare tutte le operazioni da linea di comando. In questo caso possiamo optare per attivare la Cloud Shell direttamente dal portale, tramite apposita icona in alto a destra,  
oppure possiamo aprire una shell sul nostro PC.  
Se optiamo per la prima scelta, saremo già connessi alla nostra sottoscrizione, in caso contrario sarà necessario eseguire prima il login  
il comando "az login"  
aprirà il nostro browser predefinito per chiederci di inserire le nostre credenziali.

## Creazione Risorse dalla CLI
Prima di poter pubblicare la nostra applicazione, dobbiamo preparare l'ambiente.  
MS Azure raggruppa tutte le risorse sotto un [Resource Group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal), perciò ne dobbiamo creare uno.  
Prima di tutto, eseguiamo il login, e aggiorniamo la CLI all'ultima versione  
```
az login
az upgrade
```

Installiamo, o aggiorniamo, l'estensione per gestire le Azire Container Apps  
```
az extension add --name container app --upgrade
```
A questo punto abbiamo bisogno di registrare due namespace, il primo dovuto alla migrazione di Azure Container Apps da Microsoft.Web a Microsoft.App. [Doc](https://github.com/microsoft/azure-container-apps/issues/109)
```
az provider register --namespace Microsoft.App
```
Il secondo per attivare il monitoring della nostra applicazione
```
az provider register --namespace Microsoft.OperationalInsights
```
Abbiamo così terminato la configurazione della CLI di Azure, e possiamo cominciare a settare la nostra applicazione.  
Definiamo le variabili d'ambiente  
```
export RESOURCE_GROUP="brewupapi"
export LOCATION="weteurope"
export ENVIRONMENT="brewup-env-containerapps"
export API_NAME="brewupapi"
```
