let active = null;
let x = 0;
let y = 0;

document.addEventListener('mousedown', e => {
    if (e.which == 3) {
        x = e.clientX + 10;
        y = e.clientY + 10;

        window.parent.postMessage({ action: 'interactions:raycast' }, '*');
    }
});

document.addEventListener('keydown', e => {
    if (e.keyCode === 9) {
        clearAll();
        window.parent.postMessage({ action: 'interactions:close' }, '*');
    } else if (e.keyCode === 27) {
        clearAll();
    }
});

window.addEventListener('message', function(event) {
    if (event.data.type === "active") {
        document.body.style.display = 'block';
    } else if (event.data.type === "inactive") {
        document.body.style.display = 'none';
    } else if (event.data.type === "open") {
        clearAll();

        if (event.data.interactable === "atm") {
            active = "atm";
        } else if (event.data.interactable === "vehicle") {
            active = "vehicle";
        } else if (event.data.interactable === "door") {
            active = "door";
        } else if (event.data.interactable === "vending") {
            active = "vending"
        } else if (event.data.interactable === "npcvending") {
            active = "npcvending"
        }

        showContext(active);
    } else if (event.data.type === "clear") {
        clearAll();
    }
});

$('body').on('click', '#atm_use', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:atm:use' }, '*');
});

$('body').on('click', '#atm_cancel', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:close' }, '*');
});

$('body').on('click', '#vehicle_in', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:vehicle:in' }, '*');
});

$('body').on('click', '#vehicle_frontleft', function() {
    window.parent.postMessage({ action: 'interactions:vehicle:frontleft' }, '*');
});

$('body').on('click', '#vehicle_frontright', function() {
    window.parent.postMessage({ action: 'interactions:vehicle:frontright' }, '*');
});

$('body').on('click', '#vehicle_backleft', function() {
    window.parent.postMessage({ action: 'interactions:vehicle:backleft' }, '*');
});

$('body').on('click', '#vehicle_backright', function() {
    window.parent.postMessage({ action: 'interactions:vehicle:backright' }, '*');
});

$('body').on('click', '#vehicle_hood', function() {
    window.parent.postMessage({ action: 'interactions:vehicle:hood' }, '*');
});

$('body').on('click', '#vehicle_trunk', function() {
    window.parent.postMessage({ action: 'interactions:vehicle:trunk' }, '*');
});

$('body').on('click', '#vehicle_lockpick', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:vehicle:lockpick' }, '*');
});

$('body').on('click', '#vehicle_cancel', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:close' }, '*');
});

$('body').on('click', '#door_open', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:door:open' }, '*');
});

$('body').on('click', '#door_close', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:door:close' }, '*');
});

$('body').on('click', '#door_lock', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:door:lock' }, '*');
});

$('body').on('click', '#door_unlock', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:door:unlock' }, '*');
});

$('body').on('click', '#door_lockpick', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:door:lockpick' }, '*');
});

$('body').on('click', '#door_cancel', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:close' }, '*');
});

$('body').on('click', '#vending_buy', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:vending:buy' }, '*');
});

$('body').on('click', '#vending_cancel', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:close' }, '*');
});

$('body').on('click', '#npcvending_buy', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:npcvending:buy' }, '*');
});

$('body').on('click', '#npcvending_cancel', function() {
    clearAll();
    window.parent.postMessage({ action: 'interactions:close' }, '*');
});

clearAll = function() {
    if (active) {
        $(`#${active}_context`).removeClass('active');
        active = null;
    }
}

showContext = function(a) {
    if (a) {
        $(`#${a}_context`).css({ top: y + 'px', left: x + 'px' });
        $(`#${a}_context`).addClass('active');
    }
}