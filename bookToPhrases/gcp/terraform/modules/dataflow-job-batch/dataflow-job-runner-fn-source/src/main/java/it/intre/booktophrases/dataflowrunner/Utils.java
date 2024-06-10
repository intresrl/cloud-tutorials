package it.intre.booktophrases.dataflowrunner;

public class Utils {
    public static Config getConfig() {
        return new Config() {
            {
                setProjectId(System.getenv("PROJECT_ID"));
                setLocation(System.getenv("LOCATION"));
                setDataFlowTemplateGcsPath(System.getenv("DATAFLOW_TEMPLATE_GCS_PATH"));
                setBigQueryProjectId(System.getenv("BIGQUERY_PROJECT_ID"));
                setBigQueryDatasetName(System.getenv("BIGQUERY_DATASET_NAME"));
                setBigQueryTableName(System.getenv("BIGQUERY_TABLE_NAME"));
                setStagingLocation(System.getenv("STAGING_LOCATION"));
                setDataflowServiceAccount(System.getenv("DATAFLOW_SERVICE_ACCOUNT"));
            }
        };
    }

    public static String buildJobName(String bucket, String name) {
        return String.format("booktophrase-%s-%s", fixString(bucket), fixString(name));
    }

    public static String fixString(String value) {
        String regex = "[^a-z0-9]";
        return value.toLowerCase().replaceAll(regex, "-").replaceAll("--", "-");
    }
}
