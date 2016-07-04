'use strict';

$(function () {

  /**
   * Hides selected elements when an element with id ending in one or
   * more digits followed by '_delete' triggers a 'change' event
   */

  $.fn.multiples = function () {

    return this.each(function () {
      var $this = $(this);

      // Hide checkbox - if no JS then we would want to
      // show some sort of visual indication that the
      // multiple is marked for deletion.
      $this.find('input[name$="[_delete]"]').hide();

      // Hide multiple from when 'delete' radio state changes
      $this.on('change', function (e) {
        var changed_element_id = $(e.target).attr('id');
        if (/_attributes_\d+__delete/.test(changed_element_id)) {
          $this.hide();
        }
      })
    })
  };

  $('.optional-section').multiples();

});