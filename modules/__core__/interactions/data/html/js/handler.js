const info = document.getElementById("info");

window.addEventListener('message', function(event) {
    if (event.data.type === "active") {
        document.body.style.display = 'block';
    } else if (event.data.type === "inactive") {
        document.body.style.display = 'none';
    } else if (event.data.type === "update") {
        $(info).empty();

        if (event.data.interactable === "item") {
            $('#info').append(`<img class="mouse" src="img/mouseclick.png"><span id="span1"> ADD TO CART </span><span id="span2"> ${event.data.name}</span>`)
        } else if (event.data.interactable === "fuel") {
            $('#info').append(`<img class="mouse" src="img/mouseclick.png"><span id="span1"> REFUEL </span><span id="span2"> ${event.data.name}</span>`)
        } else if (event.data.interactable === "door") {
            $('#info').append(`<img class="mouse" src="img/mouseclick.png"><span id="span1"> LOCK/UNLOCK </span><span id="span2"> ${event.data.name}</span>`)
        } else {
            $('#info').append(`<img class="mouse" src="img/mouseclick.png"><span id="span1"> INTERACT </span><span id="span2"> ${event.data.name}</span>`)
        }
    } else if (event.data.type === "clear") {
        $(info).empty();
    }
});