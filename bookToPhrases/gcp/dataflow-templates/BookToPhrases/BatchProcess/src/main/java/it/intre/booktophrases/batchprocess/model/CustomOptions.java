package it.intre.booktophrases.batchprocess.model;

import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;

public interface CustomOptions extends PipelineOptions {

  @Description("GS file path to load.")
  String getInputFile();
  void setInputFile(String value);

  @Description("The BigQuery's project ID.")
  String getBigQueryProjectId();
  void setBigQueryProjectId(String value);

  @Description("The BigQuery's dataset name.")
  @Default.String("gilda")
  String getBigQueryDatasetName();
  void setBigQueryDatasetName(String value);

  @Description("The BigQuery's table name.")
  @Default.String("phrases")
  String getBigQueryTableName();
  void setBigQueryTableName(String value);
}
