resource "google_storage_bucket_object" "flex_template" {
  name         = "${var.template_folder}/${var.template_name}"
  bucket = var.storage_temp_name

  content_type = "application/json"
  content = jsonencode({
    "defaultEnvironment": {},
    "image": "${var.dataflow_batch_image}",
    "metadata": {
      "description": "An example flex template for Java.",
      "name": "Getting started Java flex template",
      "parameters": [
        {
          "helpText": "GS file path to load.",
          "label": "GS file path to load.",
          "name": "inputFile"
        },
        {
          "helpText": "The BigQuery's project ID.",
          "label": "The BigQuery's project ID.",
          "name": "bigQueryProjectId"
        },
        {
          "helpText": "The BigQuery's dataset name.",
          "label": "The BigQuery's dataset name.",
          "name": "bigQueryDatasetName"
        },
        {
          "helpText": "The BigQuery's table name.",
          "label": "The BigQuery's table name.",
          "name": "bigQueryTableName"
        }
      ]
    },
    "sdkInfo": {
      "language": "JAVA"
    }
  })
}
