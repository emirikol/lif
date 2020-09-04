// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import Delta from 'channels/delta_channel'

$( function() {
  $( ".token" ).draggable({cursor: "move", revert: "invalid",
  start: function(e,ui) {
    $(this).data('origin', $(this).parent())
   }});
  $('.cell').droppable({
    drop: function(e,ui){ Delta.perform('move', {token_id: ui.draggable.data('tokenId'), cell_id: $(this).attr('id')} )},
    over: function(e,ui){
      const origin = ui.draggable.data('origin');
      let distance = ['x', 'y'].map((axis)=>{return Math.abs(origin.data()[axis] - $(this).data()[axis])}).sort((a,b)=>b-a)[0];
      $('#output').text(`${distance * 5}ft`);
    }
  }).click(function(e){
    if (e.ctrlKey || e.metaKey) { 
      Delta.perform('light', {id: $(this).attr('id')} )
    } else if (window.admin) {
      Delta.perform('build', {id: $(this).attr('id')} )
    }
  });

  $('[data-action=move]').click((e)=>{
    let round = $('[name=round]');
    round.val( parseInt(round.val()) + $(e.target).data('delta') ).trigger('change')
  })
  if($('[name=round]').length > 0 ){
    let rounds = new Promise((resolve)=>{
      $.get(`/replays/${$('.grid').data('id')}.json`).then(d => resolve(d))
    });
    rounds.then(()=>$('.loading').hide());
    $('[name=round]').change((e)=>{
      let round = parseInt($(e.target).val());
      rounds.then((h) => {
        if(!h[round]) return;
        $('.cell').removeClass('live lit dead');
        h[round].forEach(d => $(`#${d.cell_id}`).addClass(d.state))
        $('#score').text(`${$('.live').length} live crystals`)
      });
    }).trigger('change')
    $(document).on('xhrProgress', (e,d)=>$('.progress').text(d.loaded))    
  }

});

(()=>{
  let originalXhr = $.ajaxSettings.xhr;
  $.ajaxSetup({
    xhr: ()=>{
      let req = originalXhr();
      if(req && req.addEventListener){
        req.addEventListener("progress",(e)=>{ $(document).trigger('xhrProgress', e) },false);
      }
      return req
    }
  }); 
})();



// console.info(Delta);
window.Delta = Delta;