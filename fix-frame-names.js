const fs = require("fs");
const path = require("path");

const framesPath = path.join(__dirname, "frames");

async function renameFiles() {
  const files = await fs.promises.readdir(framesPath);

  files.forEach((filename) => {
    const filenameParts = filename.replaceAll("tungtung-", "").split(".");
    const newFilename = "tungtung-" + Number(filenameParts[0]) + "." + filenameParts[1];

    const oldFilepath = path.join(framesPath, filename);
    const newFilepath = path.join(framesPath, newFilename);
    fs.rename(oldFilepath, newFilepath, (err) => {
      if (err) {
        console.error("Error renaming: " + oldFilepath,  err);
      } else {
        console.log(`Renamed ${oldFilepath} to ${newFilepath}`);
      }
    });
  });
}

renameFiles();
