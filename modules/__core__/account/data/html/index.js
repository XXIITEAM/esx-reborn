$(function() {

    $('.wallet-container').hide();

    window.addEventListener("message", (event) => {
        let accounts = event.data.data;

        accounts.forEach((element) => {
            $('.' + element.id + '').remove();
        })

        accounts.forEach((element) => {
            $('.wallet-container').append('<div class="' + element.id + '"><p class="' + element.type + '-amount">$' + element.amount + '</p>')
        })

        $(".wallet-container").fadeIn(function() {
            setTimeout(function() {
                $(".wallet-container").fadeOut("fast");
                accounts.forEach((element) => {
                    $('.' + element.id + '').remove();
                    // $('.' + element.id + element.type + '').remove();
                })
            }, 3000);
        });
    })
})
