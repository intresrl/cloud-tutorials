const { app } = require('@azure/functions');
const sendgrid = require('@sendgrid/mail');

sendgrid.setApiKey(process.env.SENDGRID_API_KEY || '<your-sendgrid-api-key>');

async function sendMail(fileName, uri) {
    await sendgrid.send({
      to: process.env.MAIL_RECEIVER,
      from: process.env.MAIL_SENDER,
      subject: 'New file on the bucket',
     text: `Azure[1]: The new  file "${fileName}" was uploaded to the bucket (Uri: "${uri}") just now`,
    });
    console.log(`Mail sent`);
  }

app.storageBlob('notifier', {
    path: 'landarea/{name}',
    connection: 'landarea_STORAGE',
    handler: async (blob, context) => {
        context.log(`[landarea_STORAGE]: Storage blob function processed blob "${context.triggerMetadata.name}" with size ${blob.length} bytes`);
        await sendMail(context.triggerMetadata.name, context.triggerMetadata.uri);
    }
});





