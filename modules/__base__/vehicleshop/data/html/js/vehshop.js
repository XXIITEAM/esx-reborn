const leftMenu = document.getElementById('vehshop_left');
const leftColorMenu = document.getElementById('color_left');
const rightMenu = document.getElementById('vehshop_right');

let mouseDown = false;
let offsetX = null;
let offsetY = null;
let leftMouseDown = false;
let rightMouseDown = false;
let currentLeftSubmenu = "sedans";
let currentRightSubmenu = "stats";
let currentColorCategory = "primary";
let currentModSubmenu = "exterior1";
let hue = 0;
let sat = 1;
let val = 0;
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

    leftColorMenu.addEventListener('mouseenter', e => {
        window.parent.postMessage({ action: 'mouse.in' }, '*');
    });

    leftColorMenu.addEventListener('mouseleave', e => {
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

    if (eventData.type === "open") {
        document.body.style.display = 'block';
    } else if (eventData.type === "initData") {
        initData(eventData);
    } else if (eventData.type === "selectVehicle") {
        clearAll();
        selectVehicle(eventData);
    } else if (eventData.type === "removeVehicle") {
        clearAll();
    } else if (eventData.type === "close") {
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

$('body').on('click', '#vehshop_buy', function() {
    window.parent.postMessage({ action: "vehshop.buy", data: 0 }, '*');
});

$('body').on('click', '#vehshop_testdrive', function() {
    window.parent.postMessage({ action: "vehshop.testdrive", data: 0 }, '*');
});

$('body').on('click', '#vehshop_exit', function() {
    window.parent.postMessage({ action: "vehshop.exit", data: 0 }, '*');
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

        window.parent.postMessage({ action: "vehshop.changeTab", data: currentLeftSubmenu }, '*');
        clearAll();
    }
});

$('body').on('click', '.color_menu', function(event) {
    if (currentColorCategory !== $(this).attr("data-menu")) {
        $(".color_menu").each(function() { $(this).removeClass('active'); });
        $(this).addClass('active');
        currentColorCategory = $(this).attr("data-menu");
    }
});

initData = function(eventData) {
    let sedans = eventData.sedans;
    let compact = eventData.compact;
    let muscle = eventData.muscle;
    let sports = eventData.sports;
    let sportsclassics = eventData.sportsclassics;
    let supercars = eventData.super;
    let suvs = eventData.suvs;
    let offroad = eventData.offroad;
    let motorcycles = eventData.motorcycles;

    $("#changeSedan").attr("max", sedans).val(0);
    $("#changeCompact").attr("max", compact).val(0);
    $("#changeMuscle").attr("max", muscle).val(0);
    $("#changeSports").attr("max", sports).val(0);
    $("#changeSportsClassics").attr("max", sportsclassics).val(0);
    $("#changeSuper").attr("max", supercars).val(0);
    $("#changeSUVS").attr("max", suvs).val(0);
    $("#changeOffroad").attr("max", offroad).val(0);
    $("#changeMotorcycle").attr("max", motorcycles).val(0);
}

hsv2rgb = function(h, s, v) {
    let f = (n, k = (n + h / 60) % 6) => v - v * s * Math.max(Math.min(k, 4 - k, 1), 0);
    return {
        r: Math.round(f(5) * 255),
        g: Math.round(f(3) * 255),
        b: Math.round(f(1) * 255)
    };
}

selectVehicle = function(eventData) {
    if (eventData.data.make !== "unknown") {
        $("#modelStat").text(eventData.data.make + " " + eventData.data.name);
    } else {
        $("#modelStat").text(eventData.data.name);
    }

    let formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    });

    let price = formatter.format(eventData.data.price);

    $("#priceStat").text(price);

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
            $("#fueltypeStat").text(eventData.labels.fuelTypeStat);
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
    $("#priceStat").text("$0");
    $("#vehshop_name").text("");
    $("#vehshop_price").text("");
    $("#topSpeedLabel").text("Top Speed");
    $("#accelerationLabel").text("Acceleration");
    $("#gearsLabel").text("Gears");
    $("#capacityLabel").text("Capacity");
    $("#fueltypeStat").text("N/A");

    $("#hue").attr("value", 0);
    $('#hue').trigger('change');
    $("#hueOutput").text("0");
    $("#saturation").attr("value", 255);
    $('#saturation').trigger('change');
    $("#saturationOutput").text("255");
    $("#value").attr("value", 0);
    $('#value').trigger('change');
    $("#valueOutput").text("0");

    hue = 0;
    sat = 1;
    val = 0;
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
    $("#fueltypeStat").text("N/A");
}

setter = function(event, setting, send_value) {
    let array = [];

    let saturation = document.getElementById("saturation");
    let value = document.getElementById("value");
    let rgb = hsv2rgb(hue, sat, val);

    switch (event) {
        case 'changeHue':
            hue = send_value;

            rgb = hsv2rgb(hue, sat, val);

            saturation.style.backgroundImage = "linear-gradient(to right, rgba(255, 255, 255, 0.7), rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ", 0.7)";
            value.style.backgroundImage = "linear-gradient(to right, rgba(0, 0, 0, 0.7), rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ", 0.7))";

            window.parent.postMessage({ action: "vehshop.changeColors", data: { category: currentColorCategory, r: rgb.r, g: rgb.g, b: rgb.b } }, '*');
            break;
        case 'changeSaturation':
            sat = send_value;

            sat = send_value / 255;

            rgb = hsv2rgb(hue, sat, val);

            saturation.style.backgroundImage = "linear-gradient(to right, rgba(255, 255, 255, 0.7), rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ", 0.7)";
            value.style.backgroundImage = "linear-gradient(to right, rgba(0, 0, 0, 0.7), rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ", 0.7))";

            window.parent.postMessage({ action: "vehshop.changeColors", data: { category: currentColorCategory, r: rgb.r, g: rgb.g, b: rgb.b } }, '*');
            break;
        case 'changeValue':
            val = send_value;

            val = send_value / 255;

            rgb = hsv2rgb(hue, sat, val);

            saturation.style.backgroundImage = "linear-gradient(to right, rgba(255, 255, 255, 0.7), rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ", 0.7)";
            value.style.backgroundImage = "linear-gradient(to right, rgba(0, 0, 0, 0.7), rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ", 0.7))";

            window.parent.postMessage({ action: "vehshop.changeColors", data: { category: currentColorCategory, r: rgb.r, g: rgb.g, b: rgb.b } }, '*');
            break;
        case 'changeSedan':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "vehshop.changeSedan", data: { value: send_value } }, '*');
            break;
        case 'changeCompact':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "vehshop.changeCompact", data: { value: send_value } }, '*');
            break;
        case 'changeMuscle':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "vehshop.changeMuscle", data: { value: send_value } }, '*');
            break;
        case 'changeSports':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "vehshop.changeSports", data: { value: send_value } }, '*');
            break;
        case 'changeSportsClassics':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "vehshop.changeSportsClassics", data: { value: send_value } }, '*');
            break;
        case 'changeSuper':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "vehshop.changeSuper", data: { value: send_value } }, '*');
            break;
        case 'changeSUVS':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "vehshop.changeSUVS", data: { value: send_value } }, '*');
            break;
        case 'changeOffroad':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "vehshop.changeOffroad", data: { value: send_value } }, '*');
            break;
        case 'changeMotorcycle':
            if (send_value.indexOf('.') != -1) {
                vehData[setting] = parseFloat(send_value);
            } else {
                vehData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "changeMotorcycle", data: { value: send_value } }, '*');
            break;
        default:
            throw new Error('Incorrect Event Type Passed to "Setter"');
    }
}