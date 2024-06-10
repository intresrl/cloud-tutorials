package it.intre.booktophrases.dataflowrunner;

import com.google.cloud.functions.CloudEventsFunction;
import com.google.dataflow.v1beta3.FlexTemplateRuntimeEnvironment;
import com.google.dataflow.v1beta3.FlexTemplatesServiceClient;
import com.google.dataflow.v1beta3.LaunchFlexTemplateParameter;
import com.google.dataflow.v1beta3.LaunchFlexTemplateRequest;
import com.google.dataflow.v1beta3.LaunchFlexTemplateResponse;
import io.cloudevents.CloudEvent;

import java.util.Map;
import java.util.logging.Logger;

import org.json.JSONObject;


public class DataFlowRunner implements CloudEventsFunction {

    private static final Logger logger = Logger.getLogger(DataFlowRunner.class.getName());

    @Override
    public void accept(CloudEvent cloudEvent) {
        if (cloudEvent.getData() != null) {
            String dataString = new String(cloudEvent.getData().toBytes());
            logger.info("Cloud Event data: " + dataString);

            JSONObject obj = new JSONObject(dataString);
            try {
                syncLaunchFlexTemplate(obj.getString("bucket"), obj.getString("name"));
            } catch (Exception e) {
                logger.warning("Error: " + e.getMessage());
            }
        }
    }

    public static void syncLaunchFlexTemplate(String bucket, String name) {

        var config = Utils.getConfig();
        String jobName = Utils.buildJobName(bucket, name);
        String filePath = "gs://" + bucket + "/" + name;

        logger.info(String.format("Running the job %s for the file %s", jobName, filePath));
        logger.info(String.format("Configuration (%s)", config));

        try {
            try (FlexTemplatesServiceClient flexTemplatesServiceClient =
                         FlexTemplatesServiceClient.create()) {
                LaunchFlexTemplateRequest request = getLaunchFlexTemplateRequest(config,
                        jobName, filePath);

                LaunchFlexTemplateResponse response = flexTemplatesServiceClient.launchFlexTemplate(
                        request);

                logger.info("Job launched: " + response.getJob().getName());
            }
        } catch (Exception e) {
            logger.warning("Error: " + e.getMessage());
        }
    }

    private static LaunchFlexTemplateRequest getLaunchFlexTemplateRequest(Config config, String jobName, String filePath) {
        return LaunchFlexTemplateRequest.newBuilder()
                .setLaunchParameter(LaunchFlexTemplateParameter
                        .newBuilder()
                        .setContainerSpecGcsPath(
                                config.getDataFlowTemplateGcsPath())
                        .setJobName(jobName)
                        .setEnvironment(FlexTemplateRuntimeEnvironment
                                .newBuilder()
                                .setServiceAccountEmail(config.getDataflowServiceAccount())
                                .setStagingLocation(config.getStagingLocation())
                                .setMaxWorkers(1)
                                .build())

                        .putAllParameters(Map.of(
                                "bigQueryProjectId", config.getBigQueryProjectId(),
                                "bigQueryDatasetName", config.getBigQueryDatasetName(),
                                "bigQueryTableName", config.getBigQueryTableName(),
                                "inputFile", filePath
                        ))
                        .build())
                .setLocation(config.getLocation())
                .setProjectId(config.getProjectId())
                //.setValidateOnly(true)

                .build();
    }
}
