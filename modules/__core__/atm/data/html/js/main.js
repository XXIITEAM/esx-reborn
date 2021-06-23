// Copyright (c) Jérémie N'gadi

// All rights reserved.

// Even if 'All rights reserved' is very clear :

//  You shall not use any piece of this software in a commercial product / service
//  You shall not resell this software
//  You shall not provide any facility to install this particular software in a commercial product / service
//  If you redistribute this software, you must link to ORIGINAL repository at https://github.com/esx-framework/esx-reborn
//  This copyright should appear in every part of the project code

const mainContainer = document.querySelector('.container');
const choosePage = mainContainer.querySelector('.choose-page');
const mainPage = mainContainer.querySelector('.account-page');
const modalContainer = mainContainer.querySelector('.modal');
const loading = mainContainer.querySelector('.loading');
const balance = mainPage.querySelector('.balance');

/* Choose Page Listeners */

choosePage.querySelector('.close').addEventListener("click", () => {
  mainContainer.style.display = "none";
  choosePage.style.display = "none";
  mainPage.style.display = "none";

  window.parent.postMessage({ action: 'close' }, '*');
})

choosePage.querySelectorAll(".buttonAccount").forEach( button => {
  button.addEventListener("click", () => {

    const accountName = mainPage.querySelector('.account-info .account');
    const balance = mainPage.querySelector('.balance-info .balance');

    accountName.innerText = button.dataset.account;
    balance.innerText = `$ ${numberWithCommas(button.dataset.balance)}`;
    balance.dataset.balance = button.dataset.balance;
    mainPage.dataset.account = button.dataset.account;

    if (button.dataset.account === 'fleeca') {
      modalContainer.querySelector('#selectFleeca').setAttribute('selected', 'selected');
      modalContainer.querySelector('#selectMaze').removeAttribute('selected');
    } else if (button.dataset.account === 'maze') {
      modalContainer.querySelector('#selectMaze').setAttribute('selected', 'selected');
      modalContainer.querySelector('#selectFleeca').removeAttribute('selected');
    }

    choosePage.style.display = "none";
    mainPage.style.display = "block";



  });
});

/* Main Page Listeners */

mainPage.querySelector('.cancel').addEventListener("click", () => {

  choosePage.style.display = "block";
  mainPage.style.display = "none";

});

mainPage.querySelectorAll(".buttonAction").forEach( button => {
  button.addEventListener("click", () => {

    const action = button.dataset.action

    const modalTitle = modalContainer.querySelector('.modal-title');
    const quantityDiv = modalContainer.querySelector('.quantity');
    const quantityInput = quantityDiv.querySelector('#quantityInput');
    const idDiv = modalContainer.querySelector('.id');
    const idInput = idDiv.querySelector('#idInput');
    const accountDiv = modalContainer.querySelector('.account');
    const confirmButton = modalContainer.querySelector('#confirm');

    const quantityError = modalContainer.querySelector('#quantityError');
    const idError = modalContainer.querySelector('#idError');
    quantityError.innerText = "";
    idError.innerText = "";

    if (action === "withdraw") {
      modalTitle.innerText = "Withdraw money";
      quantityDiv.style.display = "block";
      quantityInput.value = "";
      idDiv.style.display = "none";
      accountDiv.style.display = "none";
      confirmButton.dataset.action = action;
    } else if (action === "deposit") {
      modalTitle.innerText = "Deposit money";
      quantityDiv.style.display = "block";
      quantityInput.value = "";
      idDiv.style.display = "none";
      accountDiv.style.display = "none";
      confirmButton.dataset.action = action;
    } else if (action === "transfer") {
      modalTitle.innerText = "Transfer money";
      quantityDiv.style.display = "block";
      quantityInput.value = "";
      idDiv.style.display = "block";
      idInput.value = "";
      accountDiv.style.display = "block";
      confirmButton.dataset.action = action;
    }

    modal.style.display = "block";

    quantityInput.focus();



  });
});

/* Modal Listeners */

const closeModal = modalContainer.querySelector("#closeModal");
const cancelButton = modalContainer.querySelector('#cancel');

closeModal.onclick = () => {
  modal.style.display = "none";
}

cancelButton.onclick = () => {
  modal.style.display = "none";
}

/* Message event listener */

window.addEventListener('message', (event) => {
  const msg = event.data;
  const data = msg.data;

  switch (msg.method) {
    case 'open':
      mainContainer.style.display = 'block';
      choosePage.style.display = 'block';
      mainPage.style.display = 'none';
      break;
    case 'close':
      mainContainer.style.display = 'none';
      choosePage.style.display = 'none';
      mainPage.style.display = 'none';
      break;
    case 'setData':
      changeTheme(data.theme);
      setBalance(data.accounts);
      break;
    case 'sendResult':
      loading.style.display = 'none';

      if (data.result) {

        balance.classList.add('fadeInStatic');
        setTimeout(() => {
          balance.classList.remove('fadeInStatic');
        }, 1000);

        fadeInElement(balance);
        setBalance(data.newAccounts);

        if (mainPage.dataset.account == 'fleeca') {
          balance.innerText = `$ ${numberWithCommas(data.newAccounts.fleeca)}`;
        } else if (mainPage.dataset.account == 'maze') {
          balance.innerText = `$ ${numberWithCommas(data.newAccounts.maze)}`;
        }

        showToast("confirm", "Success");

      } else {
        showToast("error", data.msgError);
      }
      break;
  }

});

/* Functions */

const setBalance = (accounts) => {
  choosePage.querySelector('#fleeca').dataset.balance = accounts.fleeca;
  choosePage.querySelector('#maze').dataset.balance = accounts.maze;
};

const changeTheme = (theme) => {

  const logo = document.querySelectorAll(".logo-img");

  if (theme === 'atm') {
    logo.forEach((logoimg) => {
      logoimg.src = "assets/atm-light.png"
    });

  } else if (theme === 'fleeca') {
    logo.forEach((logoimg) => {
      logoimg.src = "assets/fleeca_white.png"
    });
  }

};

const confirmModal = (element) => {
  const action = element.dataset.action;
  const quantityInput = parseFloat(modalContainer.querySelector('#quantityInput').value);
  const idInput = parseInt(modalContainer.querySelector('#idInput').value);
  const targetAccountInput = modalContainer.querySelector('#accounts').value;
  const selectedAccount = mainPage.dataset.account;
  const quantityError =  modalContainer.querySelector('#quantityError');
  const idError = modalContainer.querySelector('#idError');

  const data = {
    quantity: quantityInput,
    account: selectedAccount
  }

  if (isNaN(quantityInput)) {
    modalContainer.querySelector('#quantityError').innerText = "Field is required.";
    return;
  }
  quantityError.innerText = "";

  if (action === "withdraw" && !validateBalance(quantityInput)) return;

  if (action === 'transfer') {

    if (!validateBalance(quantityInput)) return;

    if (isNaN(idInput)) {
      idError.innerText = "Field is required.";
      return;
    }

    idError.innerText = "";

    data.targetPlayer = idInput;
    data.targetAccount = targetAccountInput;
  }

  //start loading
  modal.style.display = 'none';
  loading.style.display = 'flex';

  window.parent.postMessage({ action: action, data: data }, '*');
};

const numberWithCommas = (x) => {
  x = parseFloat(x).toFixed(2);
  return x.toString().replace(/\B(?<!\.\d*)(?=(\d{3})+(?!\d))/g, ",");
};

const validateBalance = (amount) => {
  let balance = parseFloat(mainPage.querySelector('.balance-info .balance').dataset.balance);

  if (amount > balance) {
    modalContainer.querySelector('#quantityError').innerText = "Quantity is higher than your balance";
    return false;
  } else {
    return true;
  }
};

const showToast = (type, message) => {

  const toast = mainContainer.querySelector("#snackbar");

  toast.innerText = message;
  toast.style.display = "block";
  toast.classList.add("show");
  toast.classList.add(type);

  setTimeout(function () {
    toast.classList.remove("show");
    toast.classList.remove(type);
    toast.style.display = "none";
    toast.innerText = '';
  }, 3000);
};

const fadeInElement = (element) => {
  element.classList.add('fadeInStatic');
  setTimeout(function () {
    element.classList.remove('fadeInStatic');
  }, 1000);
};


/* Dev mode */

if (!window.invokeNative) {

  setTimeout(() => {
    window.dispatchEvent(
      new MessageEvent("message", {
        data: {
          method: 'setData',
          data: {
              theme: "atm",
              accounts: {
                  fleeca: "5000000000000",
                  maze: "5125"
              }
          }
        },
      })
    );
  }, 500);

  setTimeout(() => {
    window.dispatchEvent(
      new MessageEvent("message", {
        data: {
          method: 'open'
        },
      })
    );
  }, 1000);
}
