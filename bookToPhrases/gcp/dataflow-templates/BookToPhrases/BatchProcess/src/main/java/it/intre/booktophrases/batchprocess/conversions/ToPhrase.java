package it.intre.booktophrases.batchprocess.conversions;

import com.google.api.client.util.Strings;
import java.io.IOException;
import java.util.Arrays;
import org.apache.beam.sdk.transforms.DoFn;
import it.intre.booktophrases.batchprocess.model.BookPhrase;
import it.intre.booktophrases.batchprocess.model.BookPhraseLite;

public class ToPhrase extends DoFn<BookPhraseLite, BookPhrase> {

  private static final String[] COUNT_INVALID_CHARS = new String[]{" ", ",", ".", "!", "?", ":",
      ";"};

  @ProcessElement
  public void processElement(ProcessContext c) throws IOException {
    BookPhraseLite lite = c.element();
    c.output(toBookPhrase(lite));

  }

  private static BookPhrase toBookPhrase(BookPhraseLite lite) {
    int wordsCount = lite.getPhrase().split(" ").length;
    int charsCount = (int) Arrays.stream(lite.getPhrase().split(""))
        .filter(c -> !Arrays.stream(COUNT_INVALID_CHARS).anyMatch(c::equals)).count();

    return new BookPhrase(lite, wordsCount, charsCount);
  }


  private static boolean isValidPhrase(String sRaw) {
    return !Strings.isNullOrEmpty(sRaw);
  }

}
