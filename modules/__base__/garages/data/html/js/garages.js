const leftMenu = document.getElementById('garage_left');
const rightMenu = document.getElementById('garage_right');
const categories = ["sedans", "compact", "muscle", "sports", "sportsclassics", "super", "suvs", "offroad", "motorcycles"];

let mouseDown = false;
let offsetX = null;
let offsetY = null;
let leftMouseDown = false;
let rightMouseDown = false;
let currentLeftSubmenu = "sedans";
let hidden = "false";
let activeTab = "none";
let vehData = {}

document.addEventListener("DOMContentLoaded", function() {
    document.addEventListener("mousewheel", e => {
        if (e.deltaY === -100) {
            window.parent.postMessage({ action: 'mouse.wheel', data: 0.5 }, '*');
        } else {
            window.parent.postMessage({ action: 'mouse.wheel', data: -0.5 }, '*');
        }
    });

    document.addEventListener("mousemove", e => {
        window.parent.postMessage({ action: 'mouse.move', data: { x: e.screenX, y: e.screenY, leftMouseDown: leftMouseDown, rightMouseDown: rightMouseDown } }, '*');
    });

    document.addEventListener('mousedown', e => {
        if (e.which == 1) {
            leftMouseDown = true;
        } else if (e.which == 3) {
            rightMouseDown = true;
        }
    });

    document.addEventListener('mouseup', e => {
        if (e.which == 1) {
            leftMouseDown = false;
        } else if (e.which == 3) {
            rightMouseDown = false;
        }
    });

    leftMenu.addEventListener('mouseenter', e => {
        window.parent.postMessage({ action: 'mouse.in' }, '*');
    });

    leftMenu.addEventListener('mouseleave', e => {
        window.parent.postMessage({ action: 'mouse.out' }, '*');
    });

    rightMenu.addEventListener('mouseenter', e => {
        window.parent.postMessage({ action: 'mouse.in' }, '*');
    });

    rightMenu.addEventListener('mouseleave', e => {
        window.parent.postMessage({ action: 'mouse.out' }, '*');
    });
});

window.addEventListener('message', function(event) {
    let eventData = event.data;

    if (eventData["type"] === "open") {
        document.body.style.display = 'block';
    } else if (eventData["type"] === "initData") {
        initData(eventData);
    } else if (eventData["type"] === "selectVehicle") {
        clearAll();
        selectVehicle(eventData);
    } else if (eventData["type"] === "removeVehicle") {
        clearAll();
    } else if (eventData["type"] === "close") {
        clearAll();
        document.body.style.display = 'none';
    }
});

$('.range input[type="range"]').on('change', function() {
    let event = $(this).attr("data-type");
    let setting = $(this).attr("id");
    setting = setting;

    setter(event, setting, this.value);
});

$('.range2 input[type="range"]').on('change', function() {
    let event = $(this).attr("data-type");
    let setting = $(this).attr("id");
    setting = setting;

    setter(event, setting, this.value);
});

$('.range3 input[type="range"]').on('change', function() {
    let event = $(this).attr("data-type");
    let setting = $(this).attr("id");
    setting = setting;

    setter(event, setting, this.value);
});

$('.range4 input[type="range"]').on('change', function() {
    let event = $(this).attr("data-type");
    let setting = $(this).attr("id");
    setting = setting;

    setter(event, setting, this.value);
});

$('body').on('click', '#garage_take', function() {
    window.parent.postMessage({ action: "garages.takeVehicle", data: 0 }, '*');
});

$('body').on('click', '#garage_exit', function() {
    window.parent.postMessage({ action: "garages.exit", data: 0 }, '*');
});

$('body').on('click', '#hidetoggle', function() {
    if (hidden == "false") {
        $("#right_content").hide();
        $("#garage_right").css("height", '8.3vh');
        $("#garage_bottom_take").css("top", '8.8vh');
        $("#garage_bottom_exit").css("top", '13.3vh');
        hidden = "true";
    } else {
        $("#garage_right").css("height", '40.5vh');
        $("#right_content").show();
        $("#garage_bottom_take").css("top", '41vh');
        $("#garage_bottom_exit").css("top", '45.5vh');
        hidden = "false";
    }
});

$('body').on('click', '.left_menu', function(event) {
    if (currentLeftSubmenu !== $(this).attr("data-menu")) {
        $(".left_menu").each(function() { $(this).removeClass('active'); });
        $(".left_submenu").each(function() { $(this).stop().fadeOut(250); });
        let menu = $(this).attr("data-menu");
        currentLeftSubmenu = $(this).attr("data-menu");
        $(this).addClass('active');

        setTimeout(function() {
            $(`#${menu}`).stop().fadeIn(250);
        }, 250);

        window.parent.postMessage({ action: "garages.changeTab", data: { value: currentLeftSubmenu } }, '*');
        clearAll();
    }
});

initData = function(eventData) {
    if (activeTab !== "none") {
        $(`#${activeTab}` + `Tab`).removeClass('active');
        $(`#${activeTab}`).hide();

        activeTab = "none";
    }

    for (k in categories) {
        let key = categories[k].toString();

        $(`#${key}` + `Tab`).hide();
        $(`#${key}` + `Tab`).removeClass('active');
        $(`#${key}`).hide();

        if (eventData[key]) {
            if (eventData[key] >= 1) {
                if (activeTab === "none") {
                    activeTab = key;
                    $(`#${key}` + `Tab`).addClass('active');
                    $(`#${key}`).show();
                }

                let value = eventData[key];

                $(`#${key}` + `change`).attr("max", value).val(0);
                $(`#${key}` + `Output`).text("0/" + value);
                $(`#${key}` + `Tab`).show();
            }
        }
    }

    currentLeftSubmenu = activeTab;
}

selectVehicle = function(eventData) {
    if (eventData.data.make !== "unknown") {
        $("#modelStat").text(eventData.data.make + " " + eventData.data.name);
    } else {
        $("#modelStat").text(eventData.data.name);
    }

    $("#plateStat").text(eventData.data.plate);
    $("#fuelStat").text(eventData.data.fuelType);

    if (eventData.stats) {
        $("#topSpeedBar").css("width", eventData.stats.topSpeed + '%');
        $("#accelerationBar").css("width", eventData.stats.acceleration + '%');
        $("#gearsBar").css("width", eventData.stats.gears + '%');
        $("#capacityBar").css("width", eventData.stats.capacity + '%');

        if (eventData.labels) {
            $("#topSpeedLabel").text("Top Speed (" + eventData.labels.topSpeedLabel + ")");
            $("#accelerationLabel").text("Acceleration (" + eventData.labels.accelerationLabel + ")");
            $("#gearsLabel").text("Gears (" + eventData.labels.gearsLabel + ")");
            $("#capacityLabel").text("Capacity (" + eventData.labels.capacityLabel + ")");
        }
    } else {
        clearAll();
    }
}

clearAll = function() {
    $("#topSpeedBar").css("width", '0%');
    $("#accelerationBar").css("width", '0%');
    $("#gearsBar").css("width", '0%');
    $("#capacityBar").css("width", '0%');
    $("#modelStat").text("N/A");
    $("#plateStat").text("N/A");
    $("#topSpeedLabel").text("Top Speed");
    $("#accelerationLabel").text("Acceleration");
    $("#gearsLabel").text("Gears");
    $("#capacityLabel").text("Capacity");
    $("#fuelStat").text("N/A");
}

clearStats = function() {
    $("#topSpeedBar").css("width", '0%');
    $("#accelerationBar").css("width", '0%');
    $("#gearsBar").css("width", '0%');
    $("#capacityBar").css("width", '0%');
    $("#topSpeedLabel").text("Top Speed");
    $("#accelerationLabel").text("Acceleration");
    $("#gearsLabel").text("Gears");
    $("#capacityLabel").text("Capacity");
    $("#fuelStat").text("N/A");
}

setter = function(event, setting, send_value) {
    let array = [];

    switch (event) {
        case 'sedanschange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changesedans", data: { value: send_value } }, '*');
            break;
        case 'compactchange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changecompact", data: { value: send_value } }, '*');
            break;
        case 'musclechange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changemuscle", data: { value: send_value } }, '*');
            break;
        case 'sportschange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changesports", data: { value: send_value } }, '*');
            break;
        case 'sportsclassicschange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changesportsclassics", data: { value: send_value } }, '*');
            break;
        case 'superchange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changesuper", data: { value: send_value } }, '*');
            break;
        case 'suvschange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changesuvs", data: { value: send_value } }, '*');
            break;
        case 'offroadchange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changeoffroad", data: { value: send_value } }, '*');
            break;
        case 'motorcycleschange':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "garages.changemotorcycles", data: { value: send_value } }, '*');
            break;
        default:
            throw new Error('Incorrect Event Type Passed to "Setter"');
    }
}