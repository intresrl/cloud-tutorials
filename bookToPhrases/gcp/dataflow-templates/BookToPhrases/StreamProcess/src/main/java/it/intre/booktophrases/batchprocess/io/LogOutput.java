package it.intre.booktophrases.batchprocess.io;

import org.apache.beam.sdk.transforms.DoFn;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LogOutput<T> extends DoFn<T, T> {

  private static final Logger LOG = LoggerFactory.getLogger(LogOutput.class);
  private final String prefix;

  public LogOutput(String prefix) {
    this.prefix = prefix;
  }

  @ProcessElement
  public void processElement(ProcessContext c) throws Exception {
    LOG.info(prefix + c.element());
    c.output(c.element());
  }
}

