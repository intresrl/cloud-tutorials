# Links
- Books: https://www.gutenberg.org/browse/scores/top

# BigQuery

## Table schema

```json
[
  {
    "name": "book_name",
    "mode": "NULLABLE",
    "type": "STRING",
    "description": null,
    "fields": []
  },
  {
    "name": "phrase",
    "mode": "NULLABLE",
    "type": "STRING",
    "description": null,
    "fields": []
  },
  {
    "name": "row_index",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": null,
    "fields": []
  },
  {
    "name": "words_count",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": null,
    "fields": []
  },
  {
    "name": "chars_count",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": null,
    "fields": []
  }
]
```
# Batch job

## Pre-requisites

- Container Registry
```bash
gcloud artifacts repositories create REPOSITORY \
 --repository-format=docker \
 --location=LOCATION
```
- BigQuery dataset/table
- Bucket to upload files to be processed (bucket-source)
- Bucket for template (bucket-template)

Follow the link: https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates


## Create a template
Compile the project
```bash
mvn clean package
```
Build and publish the template to the repository

```bash
export IMAGE_NAME="{location}-docker.pkg.dev/{your project}/{your repo}/batch:latest"
export BUCKET_TEMPLATE_FILE="gs://{your bucket}/booktophrase-batch.json" 

gcloud dataflow flex-template build \
  ${BUCKET_TEMPLATE_FILE} \
--image-gcr-path $IMAGE_NAME \
--sdk-language "JAVA" \
--flex-template-base-image JAVA11 \
--metadata-file "metadata.json" \
--jar "target/BatchProcess-bundled-1.0-SNAPSHOT.jar" \
--env FLEX_TEMPLATE_JAVA_MAIN_CLASS="it.intre.booktophrases.batchprocess.Main"
```
Test the template manually
```bash
export BUCKET_BOOK_FILE="gs://your file on your bucket"
export BUCKET_TEMPLATE_FILE="gs://{your bucket}/booktophrase-batch.json"
export BIGQUERY_PROJECT_ID="your project"
export DATASET_NAME="your dataset name"
export TABLE_NAME="your table name"

gcloud dataflow flex-template run test \
--template-file-gcs-location ${BUCKET_TEMPLATE_FILE} \
--region europe-west8 --additional-user-labels "" \
--parameters "inputFile=${BUCKET_BOOK_FILE},bigQueryProjectId=${BIGQUERY_PROJECT_ID},bigQueryDatasetName=${DATASET_NAME},bigQueryTableName=${TABLE_NAME}"
```

## Create cloud function
- Create a cloud function that will be triggered by a file upload to the bucket-source
- Copy the code from [StorageFunction.java](DataFlowRunner%2Fsrc%2Fmain%2Fjava%2Fit%2Fintre%2Fdataflowrunner%2FStorageFunction.java)

# Stream Job
This job will read from a Pub/Sub topic the notifications of new files uploaded to a bucket, then it
will read and process the file and write the results to BigQuery.
Is a streaming job that will process the messages as they arrive: this means that the job will never
finish, it will keep running until it is stopped therefore it is expensive since the machine will
never scale down.

## Pre-requisites

- BigQuery dataset/table
- Bucket to upload files to be processed (bucket-source)
- Bucket for temp files (bucket-temp)
- Pub/Sub topic

## Pre-requisites procedure

1. Create a BigQuery dataset and table (For table schema use the one above)
2. Create a bucket to upload files to be processed (bucket-source)
3. Create a topic in Pub/Sub (bucket-source-notification) with NO subscriptions
4. Create notification to send bucket-source events(OBJECT_FINALIZE) to the topic
    ```bash
    gcloud storage buckets notifications create gs://{bucket-source} --topic={topic} --event-types=OBJECT_FINALIZE 
    ```
5. Run the CREATE JOB command with the correct parameters

## CREATE JOB

```bash
export TEMP_BUCKET="gs://{your bucket}/temp"
export PROJECT_ID="your project"
export BIGQUERY_PROJECT_ID="your project"
export DATASET_NAME="your dataset name"
export TABLE_NAME="your table name"
export TOPIC_ID="topic id"

mvn -P dataflow-runner compile exec:java \
-D exec.mainClass=it.intre.booktophrases.batchprocess.Main \
-D exec.args="--jobName=gildajob --project=${PROJECT_ID} --bigQueryProjectId=${BIGQUERY_PROJECT_ID} --bigQueryDatasetName=${DATASET_NAME} --bigQueryTableName=${TABLE_NAME} --gcpTempLocation=${TEMP_BUCKET} --runner=DataflowRunner --inputTopic=${TOPIC_ID} --region=europe-west8"
```

## UPDATE JOB

```bash
export TEMP_BUCKET="gs://{your bucket}/temp"
export PROJECT_ID="your project"
export BIGQUERY_PROJECT_ID="your project"
export DATASET_NAME="your dataset name"
export TABLE_NAME="your table name"
export TOPIC_ID="topic id"

mvn -P dataflow-runner compile exec:java \
-D exec.mainClass=it.intre.booktophrases.batchprocess.Main \
-D exec.args="--update --dataflowServiceOptions=graph_validate_only --project=${PROJECT_ID} --bigQueryProjectId=${BIGQUERY_PROJECT_ID} --bigQueryDatasetName=${DATASET_NAME} --bigQueryTableName=${TABLE_NAME} --gcpTempLocation=${TEMP_BUCKET} --runner=DataflowRunner --inputTopic=${TOPIC_ID} --region=europe-west8"
```
