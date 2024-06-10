package it.intre.booktophrases.batchprocess.conversions;

import java.io.UnsupportedEncodingException;
import org.apache.beam.sdk.transforms.DoFn;
import org.json.JSONObject;

public class PubSubToCloudStorageUrl extends DoFn<String, String> {
  @ProcessElement
  public void processElement(ProcessContext c) throws UnsupportedEncodingException {
    String dataJson = c.element();
    JSONObject obj = new JSONObject(dataJson);
    String bucketName = obj.getString("bucket");
    String fileName = obj.getString("name");
    String fullUrl = String.format("gs://%s/%s", bucketName, fileName);
    c.output(fullUrl);
  }
}
