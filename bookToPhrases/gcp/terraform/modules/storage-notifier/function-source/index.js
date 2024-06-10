const functions = require('@google-cloud/functions-framework');
const sendgrid = require('@sendgrid/mail');

sendgrid.setApiKey(process.env.SENDGRID_API_KEY || '<your-sendgrid-api-key>');

async function sendMail(bucketName, fileName) {
  await sendgrid.send({
    to: process.env.MAIL_RECEIVER,
    from: process.env.MAIL_SENDER,
    subject: 'Book to Phrases: A new file has been uploaded to the bucket.',
    text: `GOOGLE: A new file, "${fileName}", was just uploaded to the bucket "${bucketName}".`
  });
  console.log(`Mail sent`);
}

// Register a CloudEvent callback with the Functions Framework that will
// be triggered by Cloud Storage.
functions.cloudEvent('helloGCS', async cloudEvent => {
  console.log(`Event ID: ${cloudEvent.id}`);
  console.log(`Event Type: ${cloudEvent.type}`);

  const file = cloudEvent.data;
  console.log(`Bucket: ${file.bucket}`);
  console.log(`File: ${file.name}`);
  console.log(`Metageneration: ${file.metageneration}`);
  console.log(`Created: ${file.timeCreated}`);
  console.log(`Updated: ${file.updated}`);

  await sendMail(file.bucket, file.name);

});