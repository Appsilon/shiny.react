import Shiny from '@/shiny';

// Shiny initializes some functions after a delay:
// https://github.com/rstudio/shiny/blob/a1ff7652358a14f717b0b9f49f7385b164f762af/srcjs/init_shiny.js#L587
// This file provides a generic workaround.

function waitForInit(target, name, queues) {
  let tries = 10;
  let delay = 1;
  function check() {
    tries -= 1;
    delay *= 2;
    const func = target[name];
    if (func || tries < 0) {
      const { calls } = queues[name];
      delete queues[name]; // eslint-disable-line no-param-reassign
      if (func) calls.forEach((args) => func(...args));
      else throw new Error(`Waited too long for ${name} to initialize`);
    } else {
      setTimeout(check, delay);
    }
  }
  setTimeout(check, delay);
}

const proxy = new Proxy(Shiny, {
  queues: {},
  get(target, name) {
    if (this.queues[name]) return this.queues[name].wait;
    if (target[name]) return target[name];
    const calls = [];
    const wait = (...args) => { calls.push(args); };
    this.queues[name] = { calls, wait };
    waitForInit(target, name, this.queues);
    return this.queues[name].wait;
  },
});

export default proxy;
