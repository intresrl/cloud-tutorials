/**
 * All headers that start with "x-" will be forwarded to the next service
 * For tracing to work, we need to forward the 'x-request-id' header
 *
 * @param {Request} req
 */
const getHeadersToForward = (req) => {
    const headers = {};
    for (const key in req.headers) {
        if (key.startsWith("x-")) {
            headers[key] = req.headers[key];
        }
    }
    return headers;
}

module.exports = {getHeadersToForward}