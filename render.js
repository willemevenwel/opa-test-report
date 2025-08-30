const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');

function usageAndExit() {
  console.log('⚠️ - Usage: node render.js <viewer-html> <output-html>');
  process.exit(1);
}

if (process.argv.length < 4) {
  usageAndExit();
}


const targetUrlOrFile = process.argv[2];
const outputHtmlPath = process.argv[3];

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

    console.log("ℹ️  - Launching headless browser: puppeteer...");

    const browser = await puppeteer.launch({
      executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/chromium',
      headless: 'new',
      args: ['--no-sandbox']
    });

    const page = await browser.newPage();
    console.log("✅ - Launched");

    // Listen for console events from the page BEFORE loading it
    page.on('console', msg => {
      // Log each argument from the console message
      for (let i = 0; i < msg.args().length; ++i) {
        msg.args()[i].jsonValue().then(val => console.log("🦜⏳ -", val));
      }
    });

    // If the argument looks like a URL, use it directly; else, treat as file
    const isUrl = /^https?:\/\//.test(targetUrlOrFile);
    const target = isUrl ? targetUrlOrFile : `file://${path.resolve(targetUrlOrFile)}`;

    console.log("ℹ️  - Loading url: ", target);
    await page.goto(target, { waitUntil: 'networkidle0' });
    console.log("✅ - Loaded");

    // Wait for coverage data to be processed (totalPolicies changes from default "10")
    try {
      await page.waitForFunction(() => {
        const totalPolicies = document.getElementById('totalPolicies');
        return totalPolicies && totalPolicies.textContent !== '10x';
      }, { timeout: 8000 });
      console.log("✅ - Coverage data processed");
    } catch (error) {
      console.log("⚠️  - Timeout waiting for data processing, capturing current state...");
    }

    // Wait a bit more for all dynamic scripts to finish
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Check if real data was loaded (not placeholder content)
    const dataStatus = await page.evaluate(() => {
      const coverageRaw = document.querySelector('#coverage-raw pre')?.textContent || '';
      const verboseRaw = document.querySelector('#verbose-raw pre')?.textContent || '';
      
      const hasRealCoverage = coverageRaw.includes('"files"') && coverageRaw.includes('"coverage"');
      const hasRealVerbose = verboseRaw.includes('PASS') || verboseRaw.includes('FAIL');
      
      return { 
        coverage: hasRealCoverage ? '✅ Loaded.' : '❌☠️❌ missing/placeholder',
        verbose: hasRealVerbose ? '✅ Loaded.' : '❌☠️❌ missing/placeholder'
      };
    });
    console.log("📊 - Data status:", `coverage: ${dataStatus.coverage}, verbose: ${dataStatus.verbose}`);

    const staticHTML = await page.evaluate(() => {
      console.log("ℹ️  - Page loaded. Cloning it for manipulation.");
      const clone = document.documentElement.cloneNode(true);
      // Remove all <script> tags except the one with id='policy-controls-js'
      clone.querySelectorAll("script").forEach(s => {
        if (!(s.id && s.id === 'main-js')) {
          s.remove();
        }
      });
      return "<!DOCTYPE html>\n" + clone.outerHTML;
    });

    console.log("ℹ️  - Closing headless browser.");
    await browser.close();
    console.log("✅ - Closed");

    console.log("📦 - Packaged static html report"); 
    // This is for debugging purposes. Takes up too much log space.
    // console.log("-------------------------------------------------");
    // console.log(staticHTML);
    // console.log("-------------------------------------------------");

    console.log(`ℹ️  - Writing static html to: \'${outputHtmlPath}\'`);

    fs.writeFileSync(path.resolve(outputHtmlPath), staticHTML, 'utf8');
    console.log(`ℹ️  - Static report saved to: ${outputHtmlPath}`);

  } catch (err) {
    console.error('❌☠️❌ - Error rendering HTML:', err);
    process.exit(2);
  }
})();
 