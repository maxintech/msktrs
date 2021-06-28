// ready to go!
$(document)
  .ready(function() {
    $("#header_version").text(codeVersion);
    addVersionLogEntries();
    
    // init tooltips
    $('[data-toggle="tooltip"]').tooltip(); 

    $("#info_button").click(function() {
      $("#versionlog_modal").modal('show');
      $("#info_button").tooltip('hide');
    });

  });
