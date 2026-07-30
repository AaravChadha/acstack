// FIXTURE — unauthenticated admin route. For /secure's auth-gate
// judgment and the wave shakedown; no mechanical control asserts this
// one (route reachability needs a live process or code reading).
app.get("/admin/users", (req, res) => res.json(allUsers));
