const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve rego-coverage-report.html at the root
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'rego-coverage-report.html'));
});

// Serve all other files in the current directory
app.use(express.static(path.join(__dirname)));

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
