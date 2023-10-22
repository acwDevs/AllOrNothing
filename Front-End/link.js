let hostMenu = document.getElementById('hostMenu');
let playerManagementButton = document.getElementById('playerManagementButton');
let playerManagementMenu = document.getElementById('playerManagementMenu');
let locationManagementButton = document.getElementById('locationManagementButton');
let weaponManagementButton = document.getElementById('weaponManagementButton');
let hostMenuCloseButton = document.getElementById('hostMenuCloseButton');
let playerManagementBody = document.getElementById('playerManagementBody');
let playerManagementCloseMenuButton = document.getElementById('playerManagementCloseMenuButton');
let confirmKickPlayerMenu = document.getElementById('confirmKickPlayerMenu');
let confirmKickPlayerButton = document.getElementById('confirmKickPlayerButton');
let teamOnePlayerList = document.getElementById('teamOnePlayerList');
let teamTwoPlayerList = document.getElementById('teamTwoPlayerList');
let teamPlayersDisplay = document.getElementById('teamPlayersDisplay');

function resetHostVisibility() {
    hostMenu.style.visibility = 'hidden';
    hostMenu.classList.remove("uk-animation-fade");
}
function resetKickPlayerVisibility() {
    confirmKickPlayerMenu.style.visibility = 'hidden';
    confirmKickPlayerMenu.classList.remove("uk-animation-fade");
}
function resetPlayerManagementVisibility() {
    playerManagementMenu.style.visibility = 'hidden';
    playerManagementMenu.classList.remove("uk-animation-fade");
}

function resetLocationManagementVisibility() {
    LocationManagementMenu.style.visibility = 'hidden';
    LocationManagementMenu.classList.remove("uk-animation-fade");
}

function resetWeaponManagementVisibility() {
    weaponManagementMenu.style.visibility = 'hidden';
    weaponManagementMenu.classList.remove("uk-animation-fade");
}

function kickPlayer(id) {
    resetPlayerManagementVisibility()
    fetch(`https://${GetParentResourceName()}/kickPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body:JSON.stringify({id:id})
    })
    .then(resp => {
        return resp.json();
    })
    .then(resp => {
        console.log(resp);
    });
}

function promptForKick(id) {
    console.log(id)
    confirmKickPlayerMenu.style.visibility = 'visible';
    confirmKickPlayerMenu.classList.add("uk-animation-fade");
    confirmKickPlayerButton.onclick = function() {
        kickPlayer(id);
        resetKickPlayerVisibility();
        fetch(`https://${GetParentResourceName()}/setFocus`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body:JSON.stringify({focus:false})
        })
        .then(resp => {})
        .then(resp => {});
    }
}

function confirmMaps() {
    resetLocationManagementVisibility()
    hostMenu.style.visibility = 'visible';
    hostMenu.classList.add("uk-animation-fade");
}

function confirmGuns() {
    resetWeaponManagementVisibility()
    hostMenu.style.visibility = 'visible';
    hostMenu.classList.add("uk-animation-fade");
}

function startGame() {
    //Send checked status to server
    fetch(`https://${GetParentResourceName()}/startGame`, {
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
        console.log(resp);
    });
}

function setWeapon(checkbox, weaponName) {
    //Send checked status to server
    //console.log(checkbox.checked, weaponName);
    fetch(`https://${GetParentResourceName()}/setWeapon`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body:JSON.stringify({weaponName:weaponName,checked:checkbox.checked})
    })
    .then(resp => {
        return resp.json();
    })
    .then(resp => {
        console.log(resp);
    });
}

function setLocation(checkbox, locationName) {
    //Send checked status to server
    //console.log(checkbox.checked, locationName);
    fetch(`https://${GetParentResourceName()}/setLocation`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body:JSON.stringify({locationName:locationName,checked:checkbox.checked})
    })
    .then(resp => {
        return resp.json();
    })
    .then(resp => {
        console.log(resp);
    });
}

function getTeamsPlayerList() {
    fetch(`https://${GetParentResourceName()}/getTeamsPlayerList`, {
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
        let teamOneHTML = ``;
        let teamTwoHTML = ``;
        for (let i = 0; i < resp.teamOne.length; i++) {
            teamOneHTML += `<button class="playerNameButtons Active-Button uk-button uk-button-primary uk-width-1-1 uk-border-rounded" type="button">${resp.teamOne[i]}</button>`;
        }
        for (let i = 0; i < resp.teamTwo.length; i++) {
            teamTwoHTML += `<button class="playerNameButtons Active-Button uk-button uk-button-primary uk-width-1-1 uk-border-rounded" type="button">${resp.teamTwo[i]}</button>`;
        }
        teamOnePlayerList.innerHTML = teamOneHTML;
        teamTwoPlayerList.innerHTML = teamTwoHTML;
    });
}

weaponManagementButton.onclick = function() {
    resetHostVisibility()
    fetch(`https://${GetParentResourceName()}/getWeaponList`, {
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
        let elementHTML = ``;

        for (let i = 0; i < resp.weapons.length; i++) {
            let temp = `
                <div class="uk-margin">
                    <label>
                        <input 
                            class="uk-checkbox" 
                            type="checkbox" 
                            onclick="setWeapon(this, '${resp.weapons[i]}')"
                         >${resp.weapons[i]}
                        </input>
                    </label>
                </div>
            `;
            elementHTML += temp;
        }
        elementHTML += `<button id = "weaponSubmitButton" onclick = "confirmGuns()"class="Active-Button uk-button uk-button-primary uk-width-1-1 uk-border-rounded" type="button">Confirm</button>`;
        weaponManagementBody.innerHTML = elementHTML;

    })
    weaponManagementMenu.style.visibility = 'visible';
    weaponManagementMenu.classList.add("uk-animation-fade");
}


locationManagementButton.onclick = function() {
    console.log('Location Management Clicked');
    resetHostVisibility()
    // Get the locations list from the server
    fetch(`https://${GetParentResourceName()}/getLocationList`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body:""
    })
    .then(resp => {
        console.log(resp)
        return resp.json();
    })
    .then(resp => {
        console.log(resp)
        let elementHTML = ``;
        for (let i = 0; i < resp.locations.length; i++) {
            let temp =`
                    <div class="uk-margin">
                        <label>
                            <input 
                                class="uk-checkbox" 
                                type="checkbox" 
                                onclick="setLocation(this, '${resp.locations[i]}')"
                            >${resp.locations[i]}
                            </input>
                        </label>
                    </div>
                    `;
                    elementHTML += temp;
        }
        elementHTML += `<button id = "locationSubmitButton" onclick = "confirmMaps()"class="Active-Button uk-button uk-button-primary uk-width-1-1 uk-border-rounded" type="button">Confirm</button>`;
        locationManagementBody.innerHTML = elementHTML;

    })
    LocationManagementMenu.style.visibility = 'visible';
    LocationManagementMenu.classList.add("uk-animation-fade");
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
    let elementHTML = ``;
    for (let i = 0; i < resp.names.length; i++) {
        elementHTML += `
        <tr  class = "uk-border-rounded" general-data-type = "row" data-type = "row${parseInt(resp.players[i])}" >
          <td onclick = "promptForKick(${resp.players[i]})">${resp.names[i]}</td>
          <td onclick = ""> ID:${resp.players[i]}</td>
        </tr>
      `;
        
    } 
    elementHTML += `
    <tr>
    <td class="uk-margin">
        <button id = "playerManagementCloseMenuButton" onclick = "closerPlayerManager()" class="closeMenuButton uk-button uk-button-secondary uk-width-1-1 uk-border-rounded closeButton" type="button">Close Menu</button>
    </td>
    </tr>
    `;
    playerManagementBody.innerHTML = elementHTML;
    playerManagementMenu.style.visibility = 'visible';
    playerManagementMenu.classList.add("uk-animation-fade");
    console.log(resp.names,resp.players, resp.players.length);
});

};



function closerPlayerManager() {
    resetPlayerManagementVisibility()
    hostMenu.style.visibility = 'visible';
    hostMenu.classList.add("uk-position-center");
}

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
    if(event.data.type === 'teamListUpdate') {
        getTeamsPlayerList();
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
