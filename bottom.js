/*
const rawText = document.title;
const reg = new RegExp(/^\d{4}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/, "g");
// console.log(rawText.match(reg).join(""));
const document_title = rawText.replace(reg, "");
*/
// <p><h3><a href="/">해외선물</a> - 서로 다른 플랫폼간 데이터 전송/공유 도구</h3></p>
const a1 = document.createElement('a');
a1.setAttribute("href", "index.html");
a1.append("해외선물");

const h3 = document.createElement('h3');
h3.appendChild(a1);
h3.append(" - " + document.title);

const p1 = document.createElement('p');
p1.appendChild(h3);

const div1 = document.getElementById('top');
div1.appendChild(p1);

// <p>해외선물과 닌자트레이더에 관한 것들<!-- <a href="https://hits.sh/treasurytrader.github.io/"> --><img alt="Hits" src="https://hits.sh/treasurytrader.github.io.svg?style=flat-square" align="right" /><!-- </a> --></p>
$(document).ready(function(){
    $("#bottom").load("bottom.html");
});
/*
const p2 = document.createElement('p');
p2.append('해외선물과 닌자트레이더에 관한 것들');

const image1 = document.createElement('img');
image1.alt   = 'Hits';
image1.src   = 'https://hits.sh/treasurytrader.github.io.svg?style=flat-square';
image1.align = 'right';

p2.appendChild(image1);
// document.body.append(p2);

// <div style="bottom: 20px; position: fixed; right: 20px;">
// <a href="https://t.me/ssfutures"><img height="50" src="t_logo_2x.png" width="50" /></a>
// </div>

const div = document.createElement('div');
div.style = 'bottom: 20px; position: fixed; right: 20px;';

const link = document.createElement('a');
link.setAttribute("href", "https://t.me/treasurytrader");

const image2  = document.createElement('img');
image2.alt   = 't_logo';
image2.src    = 't_logo_2x.png';
image2.height = '50';
image2.width  = '50';

link.appendChild(image2);
div.appendChild(link);

const div2 = document.getElementById('bottom');
div2.appendChild(p2);
div2.appendChild(div);
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
// Open external links in new tabs and open internal links in current tabs
var links    = document.getElementsByTagName("a");
var thisHref = window.location.hostname;

for(var i = 0; i < links.length; i++) {

   templink = links[i].href;
   a        = getLocation(templink);
 
   if (templink.includes(".pdf") || templink.includes(".jpg") || templink.includes(".png")) {
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
