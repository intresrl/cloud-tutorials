const {BigQuery} = require('@google-cloud/bigquery');
const bigquery = new BigQuery();
const express = require('express');
const app = express();
const json2html = require('node-json2html');

app.get('/', async (req, res) => {
    console.log(`Start query..`);
    const rows = await queryBigQuery(process.env.PROJECT_ID, process.env.DATASET_ID, process.env.TABLE_ID, process.env.LOCATION);
    res.send(prettyPrint(rows));
});

// Listen to the App Engine-specified port, or 8080 otherwise
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}...`);
});

async function queryBigQuery(projectId, datasetId, tableId, location) {
    const query = `SELECT *
                   FROM \`${projectId}.${datasetId}.${tableId}\` LIMIT 10`;

    // For all options, see https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query
    const options = {
        query: query,
        // Location must match that of the dataset(s) referenced in the query.
        location: location,
    };

    // Run the query as a job
    const [job] = await bigquery.createQueryJob(options);
    console.log(`Job ${job.id} started.`);

    // Wait for the query to finish
    const [rows] = await job.getQueryResults();

    return rows;

}

function prettyPrint(rows) {

    let body;
    if (rows.length > 0) {
        let template_table_header = {
            "<>": "tr", "html": [
                {"<>": "th", "html": "Book Name"},
                {"<>": "th", "html": "Phrase"},
                {"<>": "th", "html": "Row index"},
                {"<>": "th", "html": "Words count"},
                {"<>": "th", "html": "Chars count"}
            ]
        }

        let template_table_body = {
            "<>": "tr", "html": [
                {"<>": "td", "html": "${book_name}"},
                {"<>": "td", "html": "${phrase}"},
                {"<>": "td", "html": "${row_index}"},
                {"<>": "td", "html": "${words_count}"},
                {"<>": "td", "html": "${chars_count}"}
            ]
        }

        let table_header = json2html.render(rows[0], template_table_header);
        let table_body = json2html.render(rows, template_table_body);

        body = `<!DOCTYPE html>
                    <html lang="en">
                    <head>
                        <title>Intré - Book phrases</title>
                    </head>
                    <h1>Intré - Book phrases (10 rows only)</h1>
                    <br>
                    <table id="table">
                        <thead>${table_header}</thead>
                        <tbody>${table_body}</tbody>
                    </table>`;
    } else {
        body = 'No data found';
    }
    return body;
}