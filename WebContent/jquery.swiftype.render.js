$(document).ready(function() {
  var customResultRenderFunction = function(ctx, data) {
    var withSections = [],
      noSections = [];
    $.each(data, function(docType, results) {
      $.each(results, function(idx, result) {
        if (result.sections && result.sections.length > 15) {
          withSections.push(result);
        } else {
          noSections.push(result);
        }
      });
    });
    var withSectionsList = $('<ul class="with_sections"></ul>'),
      noSectionsList = $('<ul class="no_sections"></ul>');
    $.each(withSections, function(idx, item) {
      ctx.registerResult($('<li class="result"><p><a href="'+item['url']+'">' + item['title'] + '</a></p></li>').appendTo(withSectionsList), item);
    });
    $.each(noSections, function(idx, item) {
      ctx.registerResult($('<li class="result"><p><a href="'+item['url']+'">' + item['title'] + '</a></p></li>').appendTo(noSectionsList), item);
    });
    if (withSections.length > 0) {
      withSectionsList.appendTo(ctx.list);
    }
    if (noSections.length > 0) {
      noSectionsList.appendTo(ctx.list);
    }
  };

  $('#st-search-input').swiftype({
    engineKey: 'Hsz2p1ip3Y7yd5KrsPxd',
    resultRenderFunction: customResultRenderFunction,
    suggestionListType: 'div',
    resultListSelector: '.result',
    fetchFields: {page: ['url', 'title']}
  });

  $('#searchIcon').click(function(){
      if($.trim($('#st-search-input').val()) != "" && $('#st-search-input').val() != "Search by keyword") {
        window.location.href = "search-result.html#stq="+$.trim($('#st-search-input').val())+"&stp=1";
        return false;
      }
  });

  $('#st-search-input').click(function(){    
    $('.result').removeClass('active');
  });

  $(document).on('click', '.result a', function(e){
      e.preventDefault();
      var url = $(this).attr('href');
      window.open(url, '_blank');
  });

  $('#st-search-input').keyup(function(e){
    if(e.keyCode == 13) {
      $(this).val($.trim($(this).val()));
    }
  });

});