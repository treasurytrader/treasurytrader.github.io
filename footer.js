$(document).ready(function(){
    $("#header").load("header.html");
    $("#footer").load("footer.html");
});

// <p><h3><a href="/">해외선물</a> - 서로 다른 플랫폼간 데이터 전송/공유 도구</h3></p>
/*
(function() {
   const a1 = document.createElement('a');
   a1.setAttribute("href", "index.html");
   a1.append("해외선물");

   const h3 = document.createElement('h3');
   h3.appendChild(a1);
   h3.append(" - " + document.title);

   const p1 = document.createElement('p');
   p1.appendChild(h3);

   const div1 = document.getElementById('header');
   div1.appendChild(p1);
})();
*/

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
