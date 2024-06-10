package it.intre.booktophrases.batchprocess;


import org.apache.beam.sdk.options.PipelineOptionsFactory;
import it.intre.booktophrases.batchprocess.model.CustomOptions;

public class Main {

  public static void main(String[] args) {

    PipelineOptionsFactory.register(CustomOptions.class);
    CustomOptions customOptions =
        PipelineOptionsFactory.fromArgs(args)
            .withValidation()
            .as(CustomOptions.class);

    //customOptions.setInputTopic("projects/skilled-keyword-414314/topics/my_integration_notifs3");
    //customOptions.setBigQueryProjectId("skilled-keyword-414314");
    //customOptions.setBigQueryDatasetName("gilda");
    //customOptions.setBigQueryTableName("phrases");

    BookPhrasePipeline.Run(customOptions);

  }
}
