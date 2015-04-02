window.Delay = (function(){
	var timer = 0;
	return function(callback, ms){
		clearTimeout (timer);
		timer = setTimeout(callback, ms);
	};
})();

Array.prototype.diff = function(a) {
	return this.filter(function(i) {return a.indexOf(i) < 0;});
};


$.fn.followTo = function (pos) {
	var $this = this,
	$window = $(window);

	$window.scroll(function (e) {
		if (($window.scrollTop() + $(window).height()) > ($(document).height() - pos)) {
			$this.css({
				position: 'absolute',
			});
		} else {
			$this.css({
				position: 'fixed',
			});
		}
	});
};