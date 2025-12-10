const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const xyDir = "/home/container/xy";
const keysFile = path.join(xyDir, "keys.json");
if (!fs.existsSync(keysFile)) {
  console.error("[ERROR] Xray keys not found! Please run install.sh first to generate keys.");
  process.exit(1);
}

// ----------------- Binary definitions -----------------
const apps = [
  {
    name: "xy",
    binaryPath: "/home/container/xy/xy",
    args: ["-c", "/home/container/xy/config.json"]
  },
  {
    name: "h2",
    binaryPath: "/home/container/h2/h2",
    args: ["server", "-c", "/home/container/h2/config.yaml"]
  }
];

function runProcess(app) {
  const child = spawn(app.binaryPath, app.args, { stdio: "inherit" });

  child.on("exit", (code) => {
    if (code === 0) {
      console.log(`[EXIT] ${app.name} exited normally.`);
    } else {
      console.warn(`[EXIT] ${app.name} exited with code: ${code}. Restarting in 3s...`);
      setTimeout(() => runProcess(app), 3000);
    }
  });

  child.on("error", (err) => {
    console.error(`[ERROR] Failed to start ${app.name}:`, err);
  });
}

function main() {
  apps.forEach(runProcess);
}

main();
