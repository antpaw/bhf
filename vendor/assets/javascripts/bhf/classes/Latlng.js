var Latlng = new Class({
	Implements: [Options, Events],
	
	options: {
	},
	
	initialize: function(elem){
		var latElem = elem;
		var lngElem = elem.getNext('.map_data_lng');
		var	setValues = function(lat, lng){
			latElem.value = lat;
			lngElem.value = lng;
		};
		
		var center = new google.maps.LatLng(
			latElem.value ? latElem.value : latElem.get('data-default-lat'),
			lngElem.value ? lngElem.value : latElem.get('data-default-lng')
		);
		
		var map = new google.maps.Map(new Element('div.map_canvas').inject(latElem, 'before'), {
			zoom: 14,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			center: center,
			mapTypeControl: true,
			zoomControl: true,
			zoomControlOptions: {
				style: google.maps.ZoomControlStyle.SMALL
			},
			streetViewControl: false,
			panControl: false,
			scaleControl: false,
			overviewMapControl: false
		});
		
		var marker = new google.maps.Marker({
			title: 'Location',
			draggable: true
		});
		
		if (latElem.value && lngElem.value) {
			marker.position = new google.maps.LatLng(latElem.value, lngElem.value);
			marker.setMap(map);
		}
		else {
			if (navigator) {
				navigator.geolocation.getCurrentPosition(function(e){
					map.setCenter(new google.maps.LatLng(e.coords.latitude, e.coords.longitude));
				});
			}
			google.maps.event.addListener(map, 'click', function(e){
				marker.position = e.latLng;
				marker.setMap(map);
				setValues(marker.getPosition().Ka, marker.getPosition().La);
				google.maps.event.clearListeners(map, 'click');
			});
		}
		
		google.maps.event.addListener(marker, 'dragend', function(){
			var mPos = marker.getPosition();
			map.panTo(mPos);
			setValues(mPos.Sa, mPos.Ta);
		});
	}
});