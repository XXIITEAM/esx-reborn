$('.container').hide();
window.addEventListener('message', (event) => {
  let msg = event.data

  if (msg.method === 'sendCredentials') {
    document.getElementById('player-name').innerHTML = `Welcome, ${msg.data.playerName}`
    document.getElementById('player-balance').innerHTML = `Balance: $${msg.data.balance}`
  }

  if (msg.method === 'setVisibility') {
    if (msg.data) {
      $('.container').show();
    } else if (!msg.data) {
      $('.container').hide();
    }
  }

  // more checks will be done
  if (msg.method === 'setMessage') {
    if (msg.type === 'deposit') {
      switch (msg.variant) {
        case 'success': 
          $('#action-feedback').html('Your deposit was successful')
          $('#action-feedback').fadeOut(2000)
          break;
        case 'error':
          $('#action-feedback').html('Your deposit failed. Maybe you are poor?')
          $('#action-feedback').fadeOut(2000)
          break;
      }
    } else if (msg.type === 'withdraw') {
      switch (msg.variant) {
        case 'success': 
          $('#action-feedback').html('Your withdraw was successful')
          $('#action-feedback').fadeOut(2000)
          break;
        case 'error':
          $('#action-feedback').html('Your withdraw failed. Maybe you are poor?')
          $('#action-feedback').fadeOut(2000)
          break;
      }
    } else if (msg.type === 'transfer') {
      switch (msg.variant) {
        case 'success': 
          $('#action-feedback').html('Your transfer was successful')
          $('#action-feedback').fadeOut(2000)
          break;
        case 'error':
          $('#action-feedback').html('Your transfer failed. Maybe you are poor?')
          $('#action-feedback').fadeOut(2000)
          break;
      }
    }
  }
})

const depositMoney = () => {
  const inputAmount = $('#input-amount').val();
  $.post("http://esx-reborn/esx:atm:deposit", JSON.stringify({
    amount: inputAmount
  }))
}

const withdrawMoney = () => {
  const inputAmount = $('#input-amount').val();
  $.post("http://esx-reborn/esx:atm:withdraw", JSON.stringify({
    amount: inputAmount
  }))
  console.log(inputAmount)
}


let transferAmount;

const transferMoney = () => {
  // should send both the ID and the amount
  const amount = $('#input-amount').val();
  $('.transfer-modal').css('visibility', 'visible')
  transferAmount = amount
}

const confirmTransfer = () => {
  const playerId = $('#playerid').val()
  $.post("http://esx-reborn/esx:atm:transfer", JSON.stringify({
    playerId: playerId,
    amount: transferAmount
  }))
  $('.transfer-modal').css('visibility', 'hidden')
}

const cancelTransfer = () => {
  $('.transfer-modal').css('visibility', 'hidden')
}

document.onkeyup = (data) => {
  if (data.which === 27) {
    // will close the atm when ESC is pressed
    $('.container').hide();
    $.post("http://esx-reborn/esx:atm:close", JSON.stringify({}))

  }
}



setTimeout(() => {
  window.dispatchEvent(
    new MessageEvent("message", {
      data: {
        method: 'sendCredentials',
        data: {
          playerName: 'John Doe',
          balance: 400
        }
      },
    })
  );
}, 1000);

setTimeout(() => {
  window.dispatchEvent(
    new MessageEvent("message", {
      data: {
        method: 'setVisibility',
        data: true
      },
    })
  );
}, 1000);

setTimeout(() => {
  window.dispatchEvent(
    new MessageEvent("message", {
      data: {
        method: 'setMessage',
        type: 'withdraw',
        variant: 'error'
      },
    })
  );
}, 1000);
