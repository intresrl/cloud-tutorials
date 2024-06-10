package it.intre.booktophrases.batchprocess.conversions;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.testing.PAssert;
import org.apache.beam.sdk.transforms.Create;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.PCollection;
import it.intre.booktophrases.batchprocess.model.BookPhrase;
import it.intre.booktophrases.batchprocess.model.BookPhraseLite;
import org.junit.Test;

public class ToPhraseTest {

  @Test
  public void ToPhraseTest() {
    Pipeline pipeline = Pipeline.create();
    PCollection<BookPhraseLite> data = pipeline.apply(Create.of(
        new BookPhraseLite("book1", "phrase1", 1),
        new BookPhraseLite("book1", "second phrase", 2),
        new BookPhraseLite("book1", "phrase 3", 3)
    ));
    PCollection<BookPhrase> result = data.apply(ParDo.of(new ToPhrase()));

    PAssert.that(result)
        .containsInAnyOrder(new BookPhrase("book1", "phrase1", 1, 1, 7),
            new BookPhrase("book1", "second phrase", 2, 2, 12),
            new BookPhrase("book1", "phrase 3", 3, 2, 7));

    pipeline.run();
  }
}