/*
(function() {
   const meta = document.createElement('meta');
   meta.name = "robots";
   meta.content = "noindex,nofollow";
   document.getElementsByTagName('head')[0].appendChild(meta);
})();

(function() {
   const meta = document.createElement('meta');
   meta.name = "description";
   meta.content = "해외선물과 닌자트레이더에 관한 것들";
   document.getElementsByTagName('head')[0].appendChild(meta);
})();
*/
/*
(function() {
   // 현재 파일명+확장자 얻기
   const thisfilefullname = document.URL.substring(document.URL.lastIndexOf('/') + 1, document.URL.length);
   // 현재 파일명 얻기
   const thisfilename = thisfilefullname.substring(thisfilefullname.lastIndexOf('.'), 0);

   document.title = decodeURI(thisfilename);
})();
*/
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
