const fs = require('fs');
const proj = 'C:/Users/DELL/.claude/projects/c--Users-DELL-Desktop-knowledge-compiler';
const files = fs.readdirSync(proj).filter(x => x.endsWith('.jsonl'));
files.sort((a, b) => fs.statSync(proj + '/' + a).mtimeMs - fs.statSync(proj + '/' + b).mtimeMs);

for (const f of files) {
  try {
    const lines = fs.readFileSync(proj + '/' + f, 'utf8').trim().split('\n');
    const kr = {};
    let rawR = 0, turns = 0, ts = null;
    for (const line of lines) {
      try {
        const obj = JSON.parse(line);
        if (!ts && obj.timestamp) ts = obj.timestamp.slice(0, 10);
        const msg = obj.message || {};
        if (msg.role === 'assistant') turns++;
        const content = Array.isArray(msg.content) ? msg.content : [];
        for (const b of content) {
          if (b && b.type === 'tool_use' && b.name === 'Read') {
            const raw_fp = String((b.input && b.input.file_path) || '');
            const fp = raw_fp.split('\\').join('/');
            if (fp.indexOf('.knowledge/knowledge/') >= 0) {
              const n = fp.split('/').pop();
              kr[n] = (kr[n] || 0) + 1;
            } else if (fp.indexOf('.knowledge/raw/') >= 0) {
              rawR++;
            }
          }
        }
      } catch(e) {}
    }
    const hasK = Object.keys(kr).length > 0;
    const tag = hasK ? '[KNOWLEDGE READ]' : (rawR > 0 ? '[raw only]' : '[no knowledge]');
    console.log(f.slice(0, 8) + ' | ' + ts + ' | turns=' + turns + ' | raw_reads=' + rawR + ' | compiled_reads=' + JSON.stringify(kr) + ' ' + tag);
  } catch(e) {
    console.log(f.slice(0, 8) + ' ERROR: ' + e.message);
  }
}
