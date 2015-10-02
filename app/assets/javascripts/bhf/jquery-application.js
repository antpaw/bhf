var $j = jQuery.noConflict();

$j(document).ready(function(){
  // picture preview handler on input
  $j('.file-input').change(function(event) {
    var output = document.getElementById('file-preview');
    output.src = URL.createObjectURL(event.target.files[0]);
  });

  // picture preview handler on hover
  $j('.preview_image').on({
    mousemove: function(e) {
      $j(this).next('img').css({
        top: e.pageY - 260,
        left: e.pageX + 10
      });
    },
    mouseenter: function() {
      var big = $j('<img />', {'class': 'popped_image', src: this.src});
      $j(this).after(big);
    },
    mouseleave: function() {
      $j('.popped_image').remove();
    }
  });
});
