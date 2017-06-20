const net = require('net');
const repl = require('repl');
let connections = 0;

repl.start({
    prompt: 'Node.js via stdin> ',
      input: process.stdin,
        output: process.stdout
});
