import java.io.*;

BeliefNetwork loadNetwork(String fileName) {
  byte bytes[] = loadBytes(fileName);
  HuginReader reader = new HuginReader(new ByteArrayInputStream(bytes));
  try {
  return reader.beliefNetwork();
  }
  catch (edu.ucla.belief.io.ParseException e){
  }
  return null;
}
