---
layout: null
---
    $(document).ready(function() {
        $('a.blog-button').click(function(e) {
            $(".content-wrapper").html(getContentFromURL("{{ site.baseurl }}"));
            setAnimation();
        })

        $('a.about-button').click(function(e) {
            $(".content-wrapper").html(getContentFromURL("{{ site.baseurl }}about/"));
            setAnimation();
        })

        $('a.speaking-button').click(function(e) {
            $(".content-wrapper").html(getContentFromURL("{{ site.baseurl }}speaking/"));
            setAnimation();
        })

        if (window.location.hash && window.location.hash == '#about') {
            $(".content-wrapper").html(getContentFromURL("{{ site.baseurl}}about/"));
            $('.panel-cover').addClass('panel-cover--collapsed')
        }

        if (window.location.hash && window.location.hash == '#blog') {
            $(".content-wrapper").html(getContentFromURL("{{ site.baseurl}}"));
            $('.panel-cover').addClass('panel-cover--collapsed')
        }

        if (window.location.hash && window.location.hash == '#speaking') {
            $(".content-wrapper").html(getContentFromURL("{{ site.baseurl}}speaking/"));
            $('.panel-cover').addClass('panel-cover--collapsed')
        }

        if (window.location.pathname !== '{{ site.url }}' && window.location.pathname !== '{{ site.url }}/' && window.location.pathname !== '{{ site.url }}/index.html') {
            $('.panel-cover').addClass('panel-cover--collapsed')
        }


        $('.btn-mobile-menu').click(function() {
            $('.navigation-wrapper').toggleClass('visible animated bounceInDown')
            $('.btn-mobile-menu__icon').toggleClass('icon-list icon-x-circle animated fadeIn')
        })

        $('.navigation-wrapper .blog-button').click(function() {
            $('.navigation-wrapper').toggleClass('visible')
            $('.btn-mobile-menu__icon').toggleClass('icon-list icon-x-circle animated fadeIn')
        })

    })

var getContentFromURL = function(url) {
    var result = null;

    $.ajax({
        url: url,
        type: 'get',
        dataType: 'html',
        async: false,
        success: function(data) {
            result = data;
        }
    });

    var elements = $(result);
    var found_content = $(".content-wrapper__inner", elements);

    return found_content;

}

var setAnimation = function() {
    if ($('.panel-cover').hasClass('panel-cover--collapsed')) {
        return

    }
    currentWidth = $('.panel-cover').width()
    if (currentWidth < 960) {
        $('.panel-cover').addClass('panel-cover--collapsed')
        $('.content-wrapper').addClass('animated slideInRight')
    } else {
        $('.panel-cover').addClass('panel-cover--collapsed')
        $('.panel-cover').css('max-width', currentWidth)
        $('.panel-cover').animate({ 'max-width': '530px', 'width': '40%' }, 400, swing = 'swing', function() {})

    }
}