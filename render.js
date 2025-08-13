const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

function usageAndExit() {
  console.log('Usage: node render.js <viewer-html> <coverage-json> <output-html>');
  process.exit(1);
}

if (process.argv.length < 5) {
  usageAndExit();
}


const targetUrlOrFile = process.argv[2];
const coverageJsonPath = process.argv[3];
const outputHtmlPath = process.argv[4];

function escapeHTML(str) {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}


(async () => {
  try {
    // Only use Puppeteer to load the given URL or file
    const browser = await puppeteer.launch({
      executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/chromium',
      headless: 'new',
      args: ['--no-sandbox']
    });

    const page = await browser.newPage();
    // If the argument looks like a URL, use it directly; else, treat as file
    const isUrl = /^https?:\/\//.test(targetUrlOrFile);
    const target = isUrl ? targetUrlOrFile : `file://${path.resolve(targetUrlOrFile)}`;
    await page.goto(target, { waitUntil: 'networkidle0' });


    // Wait for the main viewer to be fully rendered (wait for at least one .code-table to exist)
    await page.waitForSelector('.code-table', {timeout: 5000});
    // Optionally, wait a bit more for all dynamic scripts to finish
    await new Promise(resolve => setTimeout(resolve, 500));

    const staticHTML = await page.evaluate(() => {
      const clone = document.documentElement.cloneNode(true);
      clone.querySelectorAll("script").forEach(s => s.remove());
      return "<!DOCTYPE html>\n" + clone.outerHTML;
    });

    await browser.close();

    fs.writeFileSync(path.resolve(outputHtmlPath), staticHTML, 'utf8');
    console.log(`✅ Static report saved to ${outputHtmlPath}`);
  } catch (err) {
    console.error('❌ Error rendering HTML:', err);
    process.exit(2);
  }
})();
 