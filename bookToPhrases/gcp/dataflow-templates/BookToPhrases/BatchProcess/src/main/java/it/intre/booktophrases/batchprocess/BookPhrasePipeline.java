package it.intre.booktophrases.batchprocess;

import com.google.api.services.bigquery.model.TableRow;
import it.intre.booktophrases.batchprocess.conversions.ToPhrase;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.FileIO;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO.Write;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO.Write.CreateDisposition;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO.Write.WriteDisposition;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubMessage;
import org.apache.beam.sdk.transforms.Create;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.PCollection;
import it.intre.booktophrases.batchprocess.conversions.ToLitePhrase;
import it.intre.booktophrases.batchprocess.io.LogOutput;
import it.intre.booktophrases.batchprocess.model.BookPhrase;
import it.intre.booktophrases.batchprocess.model.CustomOptions;
import org.jetbrains.annotations.NotNull;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class BookPhrasePipeline {

  public static Pipeline Run(CustomOptions options) {

    Logger LOG = LoggerFactory.getLogger(LogOutput.class);
    Pipeline p = Pipeline.create(options);
    //List<String> books = new ArrayList<String>();
    //books.add("gs://apache-beam-samples/shakespeare/kinglear.txt");

    PCollection<PubsubMessage> messages = null;
    LOG.info(String.format("Initializing pipeline reading from gs file \"%s\" and writing to: \"%s:%s.%s\"",
        options.getInputFile(),
        options.getBigQueryProjectId(),
        options.getBigQueryDatasetName(),
        options.getBigQueryTableName()));
    //p.apply(TextIO.read().from("gs://apache-beam-samples/shakespeare/kinglear.txt"))
    p.apply(Create.of(options.getInputFile()))
        .apply("Load file - step 1", FileIO.matchAll())
        .apply("Load file - step 2", FileIO.readMatches())
        .apply("Parse file in lite phrases", ParDo.of(new ToLitePhrase()))
        .apply("Load phrase info", ParDo.of(new ToPhrase()))
        //.apply("LogLines", ParDo.of(new LogOutput("PRINT TEST: ")));
        .apply("Write phrases into BigQuery", writeToBigQuery(options));

    p.run();
    return p;
  }

  @NotNull
  private static Write<BookPhrase> writeToBigQuery(CustomOptions options) {
    return BigQueryIO.<BookPhrase>write()
        .to(String.format("%s:%s.%s",
            options.getBigQueryProjectId(),
            options.getBigQueryDatasetName(),
            options.getBigQueryTableName()))
        .withFormatFunction(
            (BookPhrase x) -> new TableRow()
                .set("book_name", x.getBook())
                .set("phrase", x.getPhrase())
                .set("row_index", x.getRowIndex())
                .set("words_count", x.getWordsCount())
                .set("chars_count", x.getCharsCount())
        )
        //.useBeamSchema()
        .withMethod(Write.Method.STREAMING_INSERTS)
        .withCreateDisposition(CreateDisposition.CREATE_NEVER)
        .withWriteDisposition(WriteDisposition.WRITE_APPEND);
  }

}
