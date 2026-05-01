(function() {
   const h3 = document.getElementById('title');
   // 현재 경로가 '/' 이거나 'index.html'을 포함하고 있는지 확인
   const isMain = window.location.pathname === '/' || window.location.pathname.includes('index.html');

   if (!isMain) {
      // 메인이 아닐 때: 링크 생성 및 추가
      const a1 = document.createElement('a');
      a1.href = '/';
      a1.style = 'color:royalblue';
      a1.textContent = 'Index';

      h3.prepend(' - ');
      h3.prepend(a1);
   } else {
      // 메인일 때: 내용 초기화 후 Index 텍스트만 삽입
      h3.innerHTML = 'Index';
   }
})();

// 1. 설정 및 변수 선언 (const 활용)
const links = document.querySelectorAll("a"); // 최신 방식인 querySelectorAll 사용
const currentHostname = window.location.hostname;
const fileExtensions = [".pdf", ".jpg", ".png", ".webp"];

// 2. 링크 처리
links.forEach(link => {
    const href = link.href.toLowerCase();
    
    try {
        const linkUrl = new URL(link.href); // 내장 URL 객체로 호스트 추출 (getLocation 대체)
        const isFile = fileExtensions.some(ext => href.includes(ext));
        const isExternal = linkUrl.hostname !== currentHostname;

        // 파일이거나 외부 링크인 경우 새 탭으로
        if (isFile || isExternal) {
            link.target = '_blank';
            // 보안 및 성능을 위해 rel 속성 추가 권장
            link.rel = 'noopener noreferrer';
        } 
        // 내부 링크인 경우 target 제거
        else {
            link.removeAttribute("target");
        }
    } catch (e) {
        // 유효하지 않은 href(ex: javascript:void(0)) 처리 방지
    }
});

/*
$(document).ready(function(){
    $("#header").load("header.html");
    $("#footer").load("footer.html");
});
*/