# Random used to generate a unique name for the resources
resource "random_integer" "rnd" {
  min = 1
  max = 99999
}

locals {
  table_name = "phrases"
  dataset_id = "books_${random_integer.rnd.result}"
}

# Create a dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = local.dataset_id
  friendly_name               = "books"
  description                 = "This is books dataset."
  location                    = var.location

}

# Create phrases table with schema
resource "google_bigquery_table" "phrases_tbl" {
  dataset_id               = google_bigquery_dataset.dataset.dataset_id
  table_id                 = local.table_name
  deletion_protection      = false
  require_partition_filter = false
  labels = {
    project = "gilda"
  }
  schema = <<EOF
[
  {
    "name": "book_name",
    "mode": "NULLABLE",
    "type": "STRING",
    "description": "Book name"
  },
  {
    "name": "phrase",
    "mode": "NULLABLE",
    "type": "STRING",
    "description": "Phrase of the book"
  },
  {
    "name": "row_index",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "Index of the phrase in the book"
  },
  {
    "name": "words_count",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "Number of words in the phrase"
  },
  {
    "name": "chars_count",
    "mode": "NULLABLE",
    "type": "INTEGER",
    "description": "Number of characters in the phrase"
  }
]
EOF
}