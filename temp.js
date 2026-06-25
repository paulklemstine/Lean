const fs = require('fs');
const d = JSON.parse(fs.readFileSync('./Catalog/Applications/Packages/extremal_graph_theory_turn_and_szemerdi.json', 'utf8'));
const m = d.article.match(/\$\$[\s\S]*?\$\$/g);
console.log(m.map(x => JSON.stringify(x)).join('\n'));
