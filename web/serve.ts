import { join } from "path";

// ANSI color codes
const colors = {
  reset: "\x1b[0m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  red: "\x1b[31m",
};

const DIST_DIR = join(import.meta.dir, "dist");
const port = process.env.PORT ? parseInt(process.env.PORT) : undefined;
const hostname = process.env.HOST ?? "0.0.0.0";

const server = Bun.serve({
  port: port,
  hostname: hostname,
  async fetch(req) {
    const url = new URL(req.url);
    const startTime = Date.now();
    const timestamp = new Date().toISOString();

    let filePath = join(DIST_DIR, url.pathname);

    if (url.pathname === "/" || !url.pathname.includes(".")) {
      filePath = join(DIST_DIR, "index.html");
    }

    try {
      const file = Bun.file(filePath);
      const exists = await file.exists();

      if (!exists) {
        console.log(
          `${timestamp} ${req.method} ${url.pathname} ${colors.yellow}404${colors.reset} ${Date.now() - startTime}ms`
        );
        return new Response("Not Found", { status: 404 });
      }

      const mimeType = {
        ".html": "text/html",
        ".js": "application/javascript",
        ".css": "text/css",
        ".png": "image/png",
        ".jpg": "image/jpeg",
        ".svg": "image/svg+xml",
      }[filePath.slice(filePath.lastIndexOf("."))] || "application/octet-stream";

      console.log(
        `${timestamp} ${req.method} ${url.pathname} ${colors.green}200${colors.reset} ${Date.now() - startTime}ms`
      );
      return new Response(file, {
        headers: { "Content-Type": mimeType },
      });
    } catch (error) {
      console.log(
        `${timestamp} ${req.method} ${url.pathname} ${colors.red}500${colors.reset} ${Date.now() - startTime}ms`
      );
      return new Response("Internal Server Error", { status: 500 });
    }
  },
});

process.on('SIGINT', () => {
  console.log('Received SIGINT, shutting down...');
  server.stop();
});

process.on('SIGTERM', () => {
  console.log('Received SIGTERM, shutting down...');
  server.stop();
});

console.log(`🚀 Server running at ${server.url}`);
