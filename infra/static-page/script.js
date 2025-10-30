// #!/usr/bin/env node

// const http = require('http');
// const https = require('https');
// const { URL, URLSearchParams } = require('url');

// // This constant is just a mapping of environment variables to their respective
// // values.
// const CONFIG = {
//   instanceUrl: process.env.INSTANCE_URL,
//   dashboardId: process.env.DASHBOARD_ID,
//   servicePrincipalId: process.env.SERVICE_PRINCIPAL_ID,
//   servicePrincipalSecret: process.env.SERVICE_PRINCIPAL_SECRET,
//   externalViewerId: process.env.EXTERNAL_VIEWER_ID,
//   externalValue: process.env.EXTERNAL_VALUE,
//   workspaceId: process.env.WORKSPACE_ID,
//   port: process.env.PORT || 3000,
// };

// const basicAuth = Buffer.from(`${CONFIG.servicePrincipalId}:${CONFIG.servicePrincipalSecret}`).toString('base64');

// // ------------------------------------------------------------------------------------------------
// // Main
// // ------------------------------------------------------------------------------------------------

// function startServer() {
//   const missing = Object.keys(CONFIG).filter((key) => !CONFIG[key]);
//   if (missing.length > 0) throw new Error(`Missing: ${missing.join(', ')}`);

//   const server = http.createServer(async (req, res) => {
//     // This is a demo server, we only support GET requests to the root URL.
//     if (req.method !== 'GET' || req.url !== '/') {
//       res.writeHead(404, { 'Content-Type': 'text/plain' });
//       res.end('Not Found');
//       return;
//     }

//     let html = '';
//     let status = 200;

//     try {
//       const token = await getScopedToken();
//       html = generateHTML(token);
//     } catch (error) {
//       html = `<h1>Error</h1><p>${error.message}</p>`;
//       status = 500;
//     } finally {
//       res.writeHead(status, { 'Content-Type': 'text/html' });
//       res.end(html);
//     }
//   });

//   server.listen(CONFIG.port, () => {
//     console.log(`🚀 Server running on http://localhost:${CONFIG.port}`);
//   });

//   process.on('SIGINT', () => process.exit(0));
//   process.on('SIGTERM', () => process.exit(0));
// }

// async function getScopedToken() {
//   // 1. Get all-api token. This will allow you to access the /tokeninfo
//   // endpoint, which contains the information required to generate a scoped token
//   const {
//     data: { access_token: oidcToken },
//   } = await httpRequest(`${CONFIG.instanceUrl}/oidc/v1/token`, {
//     method: 'POST',
//     headers: {
//       'Content-Type': 'application/x-www-form-urlencoded',
//       Authorization: `Basic ${basicAuth}`,
//     },
//     body: new URLSearchParams({
//       grant_type: 'client_credentials',
//       scope: 'all-apis',
//     }),
//   });

//   // 2. Get token info. This information is **required** for generating a token that is correctly downscoped.
//   // A correctly downscoped token will only have access to a handful of APIs, and within those APIs, only
//   // a the specific resources required to render the dashboard.
//   //
//   // This is essential to prevent leaking a privileged token.
//   //
//   // At the time of writing, OAuth tokens in Databricks are valid for 1 hour.
//   const tokenInfoUrl = new URL(
//     `${CONFIG.instanceUrl}/api/2.0/lakeview/dashboards/${CONFIG.dashboardId}/published/tokeninfo`,
//   );
//   tokenInfoUrl.searchParams.set('external_viewer_id', CONFIG.externalViewerId);
//   tokenInfoUrl.searchParams.set('external_value', CONFIG.externalValue);

//   const { data: tokenInfo } = await httpRequest(tokenInfoUrl.toString(), {
//     headers: { Authorization: `Bearer ${oidcToken}` },
//   });

//   // 3. Generate scoped token. This call is very similar to what was issued before, but now we are providing the scoping to make the generated token
//   // safe to pass to a browser.
//   const { authorization_details, ...params } = tokenInfo;
//   const {
//     data: { access_token },
//   } = await httpRequest(`${CONFIG.instanceUrl}/oidc/v1/token`, {
//     method: 'POST',
//     headers: {
//       'Content-Type': 'application/x-www-form-urlencoded',
//       Authorization: `Basic ${basicAuth}`,
//     },
//     body: new URLSearchParams({
//       grant_type: 'client_credentials',
//       ...params,
//       authorization_details: JSON.stringify(authorization_details),
//     }),
//   });

//   return access_token;
// }

// startServer();

// // ------------------------------------------------------------------------------------------------
// // Helper functions
// // ------------------------------------------------------------------------------------------------

// /**
//  * Helper function to create HTTP requests.
//  * @param {string} url - The URL to make the request to.
//  * @param {Object} options - The options for the request.
//  * @param {string} options.method - The HTTP method to use.
//  * @param {Object} options.headers - The headers to include in the request.
//  * @param {Object} options.body - The body to include in the request.
//  * @returns {Promise<Object>} A promise that resolves to the response data.
//  */
// function httpRequest(url, { method = 'GET', headers = {}, body } = {}) {
//   return new Promise((resolve, reject) => {
//     const isHttps = url.startsWith('https://');
//     const lib = isHttps ? https : http;
//     const options = new URL(url);
//     options.method = method;
//     options.headers = headers;

//     const req = lib.request(options, (res) => {
//       let data = '';
//       res.on('data', (chunk) => (data += chunk));
//       res.on('end', () => {
//         if (res.statusCode >= 200 && res.statusCode < 300) {
//           try {
//             resolve({ data: JSON.parse(data) });
//           } catch {
//             resolve({ data });
//           }
//         } else {
//           reject(new Error(`HTTP ${res.statusCode}: ${data}`));
//         }
//       });
//     });

//     req.on('error', reject);

//     if (body) {
//       if (typeof body === 'string' || Buffer.isBuffer(body)) {
//         req.write(body);
//       } else if (body instanceof URLSearchParams) {
//         req.write(body.toString());
//       } else {
//         req.write(JSON.stringify(body));
//       }
//     }
//     req.end();
//   });
// }

// function generateHTML(token) {
//   return `<!DOCTYPE html>
// <html>
// <head>
//     <meta charset="UTF-8">
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <title>Dashboard Demo</title>
//     <style>
//         body { font-family: system-ui; margin: 0; padding: 20px; background: #f5f5f5; }
//         .container { max-width: 1200px; margin: 0 auto; height:calc(100vh - 40px) }
//     </style>
// </head>
// <body>
//     <div id="dashboard-content" class="container"></div>
//     <script type="module">
//         /**
//          * We recommend bundling the dependency instead of using a CDN. However, for demonstration purposes,
//          * we are just using a CDN.
//          * 
//          * We do not recommend one CDN over another and encourage decoupling the dependency from third-party code.
//          */
//         import { DatabricksDashboard } from "https://cdn.jsdelivr.net/npm/@databricks/aibi-client@0.0.0-alpha.7/+esm";
    
//         const dashboard = new DatabricksDashboard({
//             instanceUrl: "${CONFIG.instanceUrl}",
//             workspaceId: "${CONFIG.workspaceId}",
//             dashboardId: "${CONFIG.dashboardId}",
//             token: "${token}",
//             container: document.getElementById("dashboard-content")
//         });
        
//         dashboard.initialize();
//     </script>
// </body>
// </html>`;
// }
