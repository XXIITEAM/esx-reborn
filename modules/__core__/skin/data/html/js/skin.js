const leftMenu = document.getElementById('skn_left');
const rightMenu = document.getElementById('skn_right');
const eyeColors = [
    { "hex": "#008000", "index": 0 }, { "hex": "#50c878", "index": 1 }, { "hex": "#add8e6", "index": 2 }, { "hex": "#006994", "index": 3 },
    { "hex": "#b5651d", "index": 4 }, { "hex": "#654321", "index": 5 }, { "hex": "#8E7618", "index": 6 }, { "hex": "#A9A9A9", "index": 7 },
    { "hex": "#D3D3D3", "index": 8 }, { "hex": "#FFC0CB", "index": 9 }, { "hex": "#FFFF00", "index": 10 }, { "hex": "#6a0dad", "index": 11 },
    { "hex": "#000000", "index": 12 }, { "hex": "#C0C0C0", "index": 13 }, { "hex": "#bd6c5a", "index": 14 }, { "hex": "#66ff00", "index": 15 },
    { "hex": "#EE82EE", "index": 16 }, { "hex": "#FF0000", "index": 17 }, { "hex": "#FFFFFF", "index": 18 }, { "hex": "#FFFAFA", "index": 19 },
    { "hex": "#800000", "index": 20 }, { "hex": "#a7f432", "index": 21 }, { "hex": "#fd753b", "index": 22 }, { "hex": "#9400D3", "index": 23 },
    { "hex": "#dbebe1", "index": 24 }, { "hex": "#808000", "index": 25 }, { "hex": "#191919", "index": 26 }, { "hex": "#8B0000", "index": 27 },
    { "hex": "#28df28", "index": 28 }, { "hex": "#009479", "index": 29 }, { "hex": "#40C837", "index": 30 }, { "hex": "#A5D6A2", "index": 31 }
];
const eyeColorNames = ["Green", "Emerald", "Light blue", "Ocean blue", "Light brown", "Dark brown", "Hazel", "Dark gray", "Light gray", "Pink", "Yellow", "Purple", "Blackout", "Shades of Gray", "Tequila Sunrise", "Atomic", "Warp", "ECola", "Space Ranger", "Ying Yang", "Bullseye", "Lizard", "Dragon", "Extra Terrestrial", "Goat", "Smiley", "Possessed", "Demon", "Infected", "Alien", "Undead", "Zombie"];
const eyeC = document.getElementById("eyeColor");
const eyebrowC = document.getElementById("eyebrowColor");
const blushC = document.getElementById("blushColor");
const hairC = document.getElementById("hairColor");
const hairHighlightC = document.getElementById("hairHighlightColor");
const beardC = document.getElementById("beardColor");
const lipstickC = document.getElementById("lipstickColor");
const chesthairC = document.getElementById("chesthairColor");

let eyebrowColors = [];
let blushColors = [];
let hairColors = [];
let hairHighlightColors = [];
let lipstickColors = [];
let mouseDown = false;
let offsetX = null;
let offsetY = null;
let leftMouseDown = false;
let rightMouseDown = false;
let currentLeftSubmenu = null;
let currentRightSubmenu = null;
let charData = {
    gender: 0,
    humanPed: 0,
    animalPed: 0,
    shapeFirstID: 0,
    shapeSecondID: 0,
    shapeThirdID: 0,
    skinFirstID: 0,
    skinSecondID: 0,
    skinThirdID: 0,
    shapeMix: 0,
    skinMix: 0,
    thirdMix: 0,
    eyeState: 0,
    eyeColor: 0,
    eyebrow: 0,
    eyebrowOpacity: 0,
    eyebrowColor: 0,
    eyebrowWidth: 0,
    eyebrowShape: 0,
    noseWidth: 0,
    noseHeight: 0,
    noseLength: 0,
    noseBridge: 0,
    noseTip: 0,
    noseShift: 0,
    chinLength: 0,
    chinPosition: 0,
    chinWidth: 0,
    chinHeight: 0,
    jawWidth: 0,
    jawHeight: 0,
    cheekboneLength: 0,
    cheekboneWidth: 0,
    cheeksWidth: 0,
    lipsWidth: 0,
    neckThickness: 0,
    blemishes: 0,
    blemishesOpacity: 0,
    freckles: 0,
    frecklesOpacity: 0,
    complexion: 0,
    complexionOpacity: 0,
    blush: 0,
    blushOpacity: 0,
    blushColor: 0,
    hair: 0,
    hairColor: 0,
    hairHighlightColor: 0,
    beard: 0,
    beardColor: 0,
    beardOpacity: 0,
    makeup: 0,
    lipstick: 0,
    lipstickColor: 0,
    makeupOpacity: 0,
    lipstickOpacity: 0,
    aging: 0,
    agingOpacity: 0,
    chesthair: 0,
    chesthairColor: 0,
    chesthairOpacity: 0,
    sunDamage: 0,
    sunDamageOpacity: 0,
    bodyBlemishes: 0,
    bodyBlemishesOpacity: 0,
    moreBodyBlemishes: 0,
    moreBodyBlemishesOpacity: 0
}

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
    if (event.data.type === "open") {
        document.body.style.display = 'block';
    } else if (event.data.type === "initData") {
        hairColors = event.data.hairColors;
        lipstickColors = event.data.lipstickColors;
        blushColors = event.data.blushColors;
        $("#changeHumanPed").attr("max", event.data.humanPeds).val(0);
        $("#changeAnimalPed").attr("max", event.data.animalPeds).val(0);
        let eyeData = eyeColors;
        let eyebrowData = hairColors;
        let blushData = blushColors;
        let hairData = hairColors;
        let hairHighlightData = hairColors;
        let beardData = hairColors;
        let lipstickData = lipstickColors;
        let chesthairData = hairColors;

        $(eyeC).empty();
        $(blushC).empty();
        $(hairC).empty();
        $(hairHighlightC).empty();
        $(beardC).empty();
        $(lipstickC).empty();
        $(chesthairC).empty();

        let eyeID = $(eyeC).attr('id')
        for (const color of eyeData) {
            let eye = color.index + 1;
            let inputTag = '<input type="radio" id="' + color.index + 'color' + '" name="' + eyeID + '"value="' + color.index + '" />';
            let newElement = $('<div class="radiocolor" data-type="eyeColor">' + inputTag + '<label + for="' + color.index + 'color' + '"></label></div>').data("colorIndex", color.index);
            newElement.find('input[type="radio"] + label').css('background-image', 'url(./images/eye' + eye + '.png)');
            $(eyeC).append(newElement);
        }

        let eyebrowID = $(eyebrowC).attr('id')
        for (const color of eyebrowData) {
            let inputTag = '<input type="radio" id="' + color.index + 'color' + '" name="' + eyebrowID + '"value="' + color.index + '" />';
            let newElement = $('<div class="radiocolor" data-type="eyebrowColor">' + inputTag + '<label + for="' + color.index + 'color' + '"></label></div>').data("colorIndex", color.index);
            newElement.find('input[type="radio"] + label').css('background-color', color.hex);
            $(eyebrowC).append(newElement);
        }

        let blushID = $(blushC).attr('id')
        for (const color of blushData) {
            let inputTag = '<input type="radio" id="' + color.index + 'color' + '" name="' + blushID + '"value="' + color.index + '" />';
            let newElement = $('<div class="radiocolor" data-type="blushColor">' + inputTag + '<label + for="' + color.index + 'color' + '"></label></div>').data("colorIndex", color.index);
            newElement.find('input[type="radio"] + label').css('background-color', color.hex);
            $(blushC).append(newElement);
        }

        let hairID = $(hairC).attr('id')
        for (const color of hairData) {
            let inputTag = '<input type="radio" id="' + color.index + 'color' + '" name="' + hairID + '"value="' + color.index + '" />';
            let newElement = $('<div class="radiocolor" data-type="hairColor">' + inputTag + '<label + for="' + color.index + 'color' + '"></label></div>').data("colorIndex", color.index);
            newElement.find('input[type="radio"] + label').css('background-color', color.hex);
            $(hairC).append(newElement);
        }

        let hairHighlightID = $(hairHighlightC).attr('id')
        for (const color of hairHighlightData) {
            let inputTag = '<input type="radio" id="' + color.index + 'color' + '" name="' + hairHighlightID + '"value="' + color.index + '" />';
            let newElement = $('<div class="radiocolor" data-type="hairHighlightColor">' + inputTag + '<label + for="' + color.index + 'color' + '"></label></div>').data("colorIndex", color.index);
            newElement.find('input[type="radio"] + label').css('background-color', color.hex);
            $(hairHighlightC).append(newElement);
        }

        let beardID = $(beardC).attr('id')
        for (const color of beardData) {
            let inputTag = '<input type="radio" id="' + color.index + 'color' + '" name="' + beardID + '"value="' + color.index + '" />';
            let newElement = $('<div class="radiocolor" data-type="beardColor">' + inputTag + '<label + for="' + color.index + 'color' + '"></label></div>').data("colorIndex", color.index);
            newElement.find('input[type="radio"] + label').css('background-color', color.hex);
            $(beardC).append(newElement);
        }

        let lipstickID = $(lipstickC).attr('id')
        for (const color of lipstickData) {
            let inputTag = '<input type="radio" id="' + color.index + 'color' + '" name="' + lipstickID + '"value="' + color.index + '" />';
            let newElement = $('<div class="radiocolor" data-type="lipstickColor">' + inputTag + '<label + for="' + color.index + 'color' + '"></label></div>').data("colorIndex", color.index);
            newElement.find('input[type="radio"] + label').css('background-color', color.hex);
            $(lipstickC).append(newElement);
        }

        let chesthairID = $(chesthairC).attr('id')
        for (const color of chesthairData) {
            let inputTag = '<input type="radio" id="' + color.index + 'color' + '" name="' + chesthairID + '"value="' + color.index + '" />';
            let newElement = $('<div class="radiocolor" data-type="chesthairColor">' + inputTag + '<label + for="' + color.index + 'color' + '"></label></div>').data("colorIndex", color.index);
            newElement.find('input[type="radio"] + label').css('background-color', color.hex);
            $(chesthairC).append(newElement);
        }
    } else if (event.data.type === "close") {
        document.body.style.display = 'none';
    }
});

$('body').on('click', '.changeGender', function(event) {
    if (charData['gender'] !== $(this).attr("data-value")) {
        charData['gender'] = $(this).attr("data-value");
        $(this).removeClass('isnotset');

        $(".changeGender").each(function() {
            if ($(this).attr("data-value") != charData['gender']) $(this).addClass('isnotset');
        });

        $("#hair").attr("max", 36 + parseInt(charData['gender'])).val(0);
        window.parent.postMessage({ action: "changeGender", data: $(this).attr("data-value") }, '*');
    }
});

$('body').on('click', '.radiocolor', function(e) {
    e.preventDefault()

    charData[$(this).attr("data-type")] = $(this).data('colorIndex');
    window.parent.postMessage({ action: "changeComponent", data: { name: $(this).attr("data-type"), value: $(this).data('colorIndex') } }, '*');
})

$('.range input[type="range"]').on('change', function() {
    let event = $(this).attr("data-type");
    let setting = $(this).attr("id");
    setting = setting;

    setter(event, setting, this.value);
});

function setter(event, setting, send_value) {
    let array = [];

    switch (event) {
        case 'model':
            if (send_value.indexOf('.') != -1) {
                charData[setting] = parseFloat(send_value);
            } else {
                charData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "changeModel", data: { value: send_value } }, '*');
            break;
        case 'component':
            if (send_value.indexOf('.') != -1) {
                charData[setting] = parseFloat(send_value);
            } else {
                charData[setting] = parseInt(send_value);
            }

            window.parent.postMessage({ action: "changeComponent", data: { name: setting, value: send_value } }, '*');
            break;
        default:
            throw new Error('Incorrect Event Type Passed to "Setter"');
    }
}

$('body').on('click', '#skn_confirm', function() {
    document.body.style.display = 'none';
    window.parent.postMessage({ action: "skin.confirm", data: 0 }, '*');
});

$('body').on('click', '.left_menu', function(event) {
    if (currentLeftSubmenu !== $(this).attr("data-menu")) {
        $(".left_menu").each(function() { $(this).removeClass('active'); });
        $(".left_submenu").each(function() { $(this).stop().fadeOut(250); });
        let menu = $(this).attr("data-menu");
        currentLeftSubmenu = $(this).attr("data-menu");
        $(this).addClass('active');

        setTimeout(function() {
            $("#" + menu).stop().fadeIn(250);
        }, 250);
    }
});

$('body').on('click', '.right_menu', function(event) {
    if (currentRightSubmenu !== $(this).attr("data-menu")) {
        $(".right_menu").each(function() { $(this).removeClass('active'); });
        $(".right_submenu").each(function() { $(this).stop().fadeOut(250); });
        let menu = $(this).attr("data-menu");
        currentRightSubmenu = $(this).attr("data-menu");
        $(this).addClass('active');

        setTimeout(function() {
            $("#" + menu).stop().fadeIn(250);
        }, 250);
    }
});