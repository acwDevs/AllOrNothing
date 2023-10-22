let hostMenu = document.getElementById('hostMenu');
let playerManagementButton = document.getElementById('playerManagementButton');
let playerManagementMenu = document.getElementById('playerManagementMenu');
let locationManagementButton = document.getElementById('locationManagementButton');
let weaponManagementButton = document.getElementById('weaponManagementButton');
let hostMenuCloseButton = document.getElementById('hostMenuCloseButton');
let playerMangementBody = document.getElementById('playerMangementBody');
let playerManagementCloseMenuButton = document.getElementById('playerManagementCloseMenuButton');


function resetHostVisibility() {
    hostMenu.style.visibility = 'hidden';
    hostMenu.classList.remove("uk-animation-fade");
}

playerManagementButton.onclick = function() {
// browser-side JS
console.log('Player Management Clicked');
fetch(`https://${GetParentResourceName()}/getPlayerList`, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json; charset=UTF-8',
    },
    body:""
})
.then(resp => {
    return resp.json();
})
.then(resp => {
    resetHostVisibility()
    playerManagementMenu.style.visibility = 'visible';
    playerManagementMenu.classList.add("uk-animation-fade");
    console.log(resp.names,resp.players, resp.players.length);
});

};

locationManagementButton.onclick = function() {
};

weaponManagementButton.onclick = function() {
};

  // 👇️ Change text color on mouseover
  playerManagementCloseMenuButton.addEventListener('mouseover', function handleMouseOver() {
    playerManagementCloseMenuButton.style.backgroundColor = "red";
  });
  
  // 👇️ Change text color back on mouseout
  playerManagementCloseMenuButton.addEventListener('mouseout', function handleMouseOut() {
    playerManagementCloseMenuButton.style.backgroundColor = 'rgb(' + 34 + ',' + 34 + ',' + 34 + ')';
  });

playerManagementCloseMenuButton.onclick = function() {
    playerManagementMenu.style.visibility = 'hidden';
    hostMenu.style.visibility = 'visible';
    hostMenu.classList.add("uk-position-center");
}

// 👇️ Change text color on mouseover
hostMenuCloseButton.addEventListener('mouseover', function handleMouseOver() {
    hostMenuCloseButton.style.backgroundColor = "red";
  });
  
  // 👇️ Change text color back on mouseout
  hostMenuCloseButton.addEventListener('mouseout', function handleMouseOut() {
    hostMenuCloseButton.style.backgroundColor = 'rgb(' + 34 + ',' + 34 + ',' + 34 + ')';
  });

hostMenuCloseButton.onclick = function() {
    resetHostVisibility()
    console.log('Host Menu Close Clicked');
    fetch(`https://${GetParentResourceName()}/setFocus`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body:JSON.stringify({focus:false})
    })
    .then(resp => {})
    .then(resp => {});
};

// Register an event listener for when the NUI is ready
window.addEventListener('message', function(event) {
    console.log('Sent NUI Message');
    if (event.data.type === 'hostMenu') {
        if (event.data.focus === true) {
            // Do something when the NUI is ready
            hostMenu.style.visibility = 'visible';
            hostMenu.classList.add("uk-animation-fade");
        }
        else if (event.data.focus === false) {
            resetHostVisibility()
        }
    }
});

// // Send a message to the server
// function sendMessage(data) {
//     fetch(`https://example.com/sendMessage`, {
//         method: 'POST',
//         headers: {
//             'Content-Type': 'application/json'
//         },
//         body: JSON.stringify(data)
//     })
//     .then(response => response.json())
//     .then(data => {
//         // Do something with the response data
//     })
//     .catch(error => {
//         console.error('Error:', error);
//     });
// }
