(function() {
   const h3 = document.getElementById('title');
   // 현재 경로가 '/' 이거나 'index.html'을 포함하고 있는지 확인
   const isMain = window.location.pathname === '/' || window.location.pathname.includes('index.html');

   if (!isMain) {
      // 메인이 아닐 때: 링크 생성 및 추가
      const a1 = document.createElement('a');
      a1.href = '../index.html';
      a1.style = 'color:royalblue';
      a1.textContent = 'Index';

      h3.prepend(' - ');
      h3.prepend(a1);
   } else {
      // 메인일 때: 내용 초기화 후 Index 텍스트만 삽입
      h3.innerHTML = 'Index';
   }
})();

// Open external links in new tabs and open internal links in current tabs
var links    = document.getElementsByTagName("a");
var thisHref = window.location.hostname;

for(var i = 0; i < links.length; i++) {

   templink = links[i].href;
   a        = getLocation(templink);
 
   if (templink.includes(".pdf") || templink.includes(".jpg") || templink.includes(".png") || templink.includes(".webp")) {
      links[i].target='_blank';
   }
   else if (a.hostname == thisHref) { // if the link is same with current page URL
      links[i].removeAttribute("target");
   }
   else {
      links[i].target='_blank'; // if the link is same with current page URL
   }
}

function getLocation(href) {

   var location      = document.createElement("a");
       location.href = href;

   if (location.host == "") {
      location.href = location.href;
   }
   return location;
};

/*
// 오른쪽 클릭 방지
document.oncontextmenu = function() {
    return false;
}

// 드래그 방지
var omitformtags = ["input", "textarea", "select"]
omitformtags = omitformtags.join("|")

function disableselect(e) {
    if (omitformtags.indexOf(e.target.tagName.toLowerCase()) == -1)
        return false
}

function reEnable() {
    return true
}

if (typeof document.onselectstart != "undefined")
    document.onselectstart = new Function("return false")
else {
    document.onmousedown = disableselect
    document.onmouseup = reEnable
}
*/
/*
$(document).ready(function(){
    $("#header").load("header.html");
    $("#footer").load("footer.html");
});
*/