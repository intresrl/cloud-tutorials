package it.intre.booktophrases.dataflowrunner;

import lombok.Data;

@Data
public class Config {

    /**
     * The project id where the Dataflow job will be executed
     */
    private String projectId;
    /**
     * The location where the Dataflow job will be executed
     */
    private String location;
    /**
     * The GCS path where the Dataflow template is stored
     */
    private String dataFlowTemplateGcsPath;
    /**
     * The project id where the BigQuery table is stored.
     * Could be the same as the Dataflow project id.
     */
    private String bigQueryProjectId;
    /**
     * The BigQuery dataset name
     */
    private String bigQueryDatasetName;
    /**
     * The BigQuery table name
     */
    private String bigQueryTableName;
    /**
     * The service account used by Dataflow job
     */
    private String dataflowServiceAccount;
    /**
     * The GCS path where the Dataflow job will store temporary files
     */
    private String stagingLocation;

}
