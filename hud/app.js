// Copyright (c) Jérémie N'gadi
//
// All rights reserved.
//
// Even if 'All rights reserved' is very clear :
//
//   You shall not use any piece of this software in a commercial product / service
//   You shall not resell this software
//   You shall not provide any facility to install this particular software in a commercial product / service
//   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/esx-framework/esx-reborn
//   This copyright should appear in every part of the project code

// IFFE for preventing scope pollution
(() => {

  class ESXRoot {

    constructor() {

      this.debugMode = false
      this.frames = {};
      this.resName = GetParentResourceName();

      window.addEventListener('message', e => {

        // Find which frame sent message and proxy
        for (const name in this.frames) {
          if (this.frames[name].iframe.contentWindow === e.source) {
            return this.postFrameMessage(name, e.data);
          }
        }

        // Not a frame ? Coming from client script
        this.onMessage(e.data);

      });

      this.NUICallback('nui_ready', {}, true).then(isDebugMode => {
        this.debugMode = isDebugMode
      });

    }

    async NUICallback(name, data = {}, asJSON = false) {
      const res = await fetch(`https://${this.resName}/${name}`, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      });

      if (asJSON)
        return res.json();
      else
        return res.text();
    }

    createFrame(name, url, visible = true) {
      this.debugLog(`Creating frame`, {name, url, visible})
      // We create this wrapper div as well for pointer event manipulation
      const frame = document.createElement('div');
      const iframe = document.createElement('iframe');

      frame.appendChild(iframe);

      iframe.src = url;
      this.frames[name] = {frame, iframe};

      // Setup the original proxy event with a context determined handler
      this.frames[name].iframe.addEventListener('message', e => this.onFrameMessage(name, e.data));

      this.frames[name].frame.style.pointerEvents = 'none';

      const frameWrapper = document.querySelector('#frames')

      frameWrapper.appendChild(frame);

      if (!visible) this.hideFrame(name);

      this.frames[name].iframe.contentWindow.addEventListener('DOMContentLoaded', () => {
        this.NUICallback('frame_load', {name});
      });

      return this.frames[name];
    }

    destroyFrame(name) {
      this.debugLog('Destroy Frame', name)
      this.frames[name].iframe.remove();
      this.frames[name].frame.remove();
      delete this.frames[name];
    }

    showFrame(name) {
      this.debugLog('Show Frame', name)
      this.frames[name].frame.style.display = 'block';
    }

    hideFrame(name) {
      this.debugLog('Hide Frame', name)
      this.frames[name].frame.style.display = 'none';
    }

    focusFrame(name) {
      this.debugLog('Focus Frame', name)
      for (const k in this.frames) {
        // We do this to simulate mouse focus input, considering
        // this is legacy code have not investigated if an NUI only solution is possible
        if (k === name)
          this.frames[k].frame.style.pointerEvents = 'all';
        else
          this.frames[k].frame.style.pointerEvents = 'none';
      }

      this.frames[name].iframe.contentWindow.focus();
    }

    // Message handler for child proxying and frame management from game scripts
    onMessage(msg) {
      // Proxy events will always have defined target
      if (msg.target) {
        this.debugLog('Dispatch Child Msg', {target: msg.target, data: msg.data})
        if (this.frames[msg.target])
          this.frames[msg.target].iframe.contentWindow.postMessage(msg.data, "*");
        else
          console.error(`[esx:nui] Cannot find child frame: ${msg.target}`);

      } else {

        switch (msg.action) {

          case 'create_frame':
            this.createFrame(msg.name, msg.url, msg.visible);
            break;

          case 'destroy_frame':
            this.destroyFrame(msg.name);
            break;

          case 'focus_frame':
            this.focusFrame(msg.name);
            break;

          case 'show_frame':
            this.showFrame(msg.name);
            break;

          case 'hide_frame':
            this.hideFrame(msg.name);
            break;

          default:
            console.error(`[esx nui]: frame action ${msg.action} is not a valid action`)
        }

      }
    }

    // Used for proxying from children to parent and game script handlers
    postFrameMessage(name, msg) {
      return this.NUICallback('frame_message', {name, msg})
    }

    debugLog(action, data = 'None') {
      console.group(`[Frame Action] ${action}`)
      console.dir(data)
      console.groupEnd()
    }

  }

  window.__ESXROOT__ = window.__ESXROOT__ || new ESXRoot();

})();
