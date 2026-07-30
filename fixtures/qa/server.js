// FIXTURE — seeded QA target: an unauthenticated /admin (auth gap) and
// an uncaught cast on ?limit= (crash). Run: node server.js  (port 8799)
// Kill stale servers FIRST — see README.md in this directory.
const http = require("http");
const items = ["a", "b", "c", "d"];
http
  .createServer((req, res) => {
    const url = new URL(req.url, "http://localhost");
    if (url.pathname === "/health") return res.end("ok");
    if (url.pathname === "/admin")
      return res.end(JSON.stringify({ users: 3 })); // no auth — seeded gap
    if (url.pathname === "/items") {
      const limit = JSON.parse(url.searchParams.get("limit") || "2"); // "abc" throws — seeded crash
      return res.end(JSON.stringify(items.slice(0, limit)));
    }
    res.statusCode = 404;
    res.end("not found");
  })
  .listen(8799);
