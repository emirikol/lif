import consumer from "./consumer"

export default consumer.subscriptions.create("DeltaChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if(window.admin) console.info(data);
    data.actions.forEach((d) => {
      if(d.hasOwnProperty('crystal')) $(`#${d.id}`).removeClass('live lit dead').addClass(d.crystal);
      if(d.token_id) $(`.token[data-token-id=${d.token_id}]`).appendTo($(`#${d.id}`)).css({left: 'auto', top: 'auto'});
      if(d == 'clear') $('.cell').removeClass('live lit dead');
    })
    // Called when there's incoming data on the websocket for this channel
  }
});

