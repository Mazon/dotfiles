const rootLock = require('/home/mazon/.pi/agent/npm/package-lock.json');
const fs = require('fs');
const path = require('path');

const extensions = [
  { name: '@heyhuynhgiabuu/pi-pretty', dir: '/home/mazon/.pi/agent/extensions/@heyhuynhgiabuu/pi-pretty' },
  { name: '@heyhuynhgiabuu/pi-diff', dir: '/home/mazon/.pi/agent/extensions/@heyhuynhgiabuu/pi-diff' },
  { name: '@tifan/pi-fixed-editor', dir: '/home/mazon/.pi/agent/extensions/@tifan/pi-fixed-editor' },
  { name: 'pi-llama-cpp', dir: '/home/mazon/.pi/agent/extensions/pi-llama-cpp' },
];

// Collect all dependency keys for each package by walking the dependency graph
function collectDeps(pkgName, packages) {
  const needed = new Set();
  const queue = [pkgName];
  while (queue.length > 0) {
    const current = queue.shift();
    const key = 'node_modules/' + current;
    const entry = packages[key];
    if (entry === undefined) continue;
    needed.add(key);
    // Add runtime dependencies
    for (const dep of Object.keys(entry.dependencies || {})) {
      if (!needed.has('node_modules/' + dep)) {
        queue.push(dep);
      }
    }
    // Also add optionalDependencies
    for (const dep of Object.keys(entry.optionalDependencies || {})) {
      if (!needed.has('node_modules/' + dep)) {
        queue.push(dep);
      }
    }
  }
  return needed;
}

for (const ext of extensions) {
  const pkg = JSON.parse(fs.readFileSync(path.join(ext.dir, 'package.json'), 'utf8'));
  const needed = collectDeps(pkg.name, rootLock.packages);

  const newLock = {
    name: pkg.name,
    version: pkg.version,
    lockfileVersion: 3,
    requires: true,
    packages: {
      '': {
        name: pkg.name,
        version: pkg.version,
      }
    }
  };

  // Add runtime deps to root entry
  if (pkg.dependencies) {
    newLock.packages[''].dependencies = pkg.dependencies;
  }
  if (pkg.peerDependencies) {
    newLock.packages[''].peerDependencies = pkg.peerDependencies;
  }

  // Add all needed packages
  for (const key of needed) {
    newLock.packages[key] = rootLock.packages[key];
  }

  const outPath = path.join(ext.dir, 'package-lock.json');
  fs.writeFileSync(outPath, JSON.stringify(newLock, null, 2) + '\n');
  console.log('Created', outPath, '- packages:', Object.keys(newLock.packages).length);
}
