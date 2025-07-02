(function() {
    const my_js  = document.createElement('script');
    my_js.type   = 'text/javascript';
    my_js.async  = true;
    my_js.src    = 'https://code.jquery.com/jquery-3.7.1.min.js';
    // my_js.onload = function () {if(typeof my_example_init == "function"){my_example_init();} };
    my_js.onload = function () {};
    document.getElementsByTagName('head')[0].appendChild(my_js);
})();

var meta = document.createElement('meta');
meta.name = "description";
meta.content = "해외선물과 닌자트레이더에 관한 것들";
document.getElementsByTagName('head')[0].appendChild(meta);

//현재 파일명+확장자 얻기        
var thisfilefullname = document.URL.substring(document.URL.lastIndexOf('/') + 1, document.URL.length);
//현재 파일명 얻기        
var thisfilename = thisfilefullname.substring(thisfilefullname.lastIndexOf('.'), 0);
document.title = decodeURI(thisfilename);
/*
URL 인코딩(encodeURI) / 디코딩(decodeURI)

endcodeURIComponent()
var encodeStr = encodeURI("http://www.mywebpage.com/한글.jsp");

console.log(encodeStr);
// "http%3A%2F%2Fwww.mywebpage.com%2F%ED%95%9C%EA%B8%80.jsp"
 
decodeURIComponent()
var decodeStr = decodeURI(encodeStr);

console.log(decodeStr);
// "http://www.mywebpage.com/한글.jsp"
*/