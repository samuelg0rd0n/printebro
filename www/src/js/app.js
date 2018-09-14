$(function() {

	$('.hero__arrow').on('click', function(e) {
		e.preventDefault();
		$('html,body').animate({
			scrollTop: $(window).height()
		});
	});

	lightGallery(document.querySelector('.lightgallery'), {
		selector: '.img-thumbnail',
		download: false,
	});

});

$(window).on('load', function () {
	$('.hero-animation').addClass('hero-animation--start');
});