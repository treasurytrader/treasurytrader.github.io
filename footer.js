/*
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
*/
(function() {
   const h3 = document.getElementById('title');
   // <head> 안의 <title> 태그 및 텍스트 가져오기
   const titleTag = document.querySelector('head title');
   const titleText = titleTag ? titleTag.textContent.trim() : '';

   // 1. <title> 태그에 내용이 있으면 h3에 먼저 넣기
   if (titleText) {
      h3.innerHTML = titleText;
   }

   // 현재 경로가 '/' 이거나 'index.html'을 포함하고 있는지 확인
   const isMain = window.location.pathname === '/' || window.location.pathname.includes('index.html');

   // 2. <title>이 존재하여 h3를 채웠을 때의 로직 처리
   if (titleText) {
      if (!isMain) {
         // 메인이 아닐 때: h3 내용 앞에 Index 링크를 추가
         const a1 = document.createElement('a');
         a1.href = '/';
         a1.style = 'color:royalblue';
         a1.textContent = 'Index';

         h3.prepend(' - ');
         h3.prepend(a1);
      } else {
         // 메인일 때: 타이틀 내용이 있더라도 메인이면 'Index'로 표시
         h3.innerHTML = 'Index';
      }
   } 
   // 3. 기존 코드: <title> 태그가 없거나 비어있으면 기존 로직 실행
   else {
      if (!isMain) {
         // 메인이 아닐 때: 기존 내용 유지하면서 앞에 Index 링크 추가
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
   }
})();

// '탑 버튼' 자바스크립트 자동화
/*
(function() {
   const btn = document.createElement('div');
   btn.innerHTML = '▲ TOP';
   btn.style = 'position:fixed; bottom:20px; right:20px; background:#333; color:#fff; padding:10px 15px; cursor:pointer; border-radius:5px; font-size:14px; z-index:9999;';
   
   // 클릭하면 최상단으로 부드럽게 이동
   btn.onclick = function() {
      window.scrollTo({ top: 0, behavior: 'smooth' });
   };
   
   document.body.appendChild(btn);
})();
*/
// 기존 자바스크립트 파일 최하단에 추가
(function() {
   // 현재 경로가 '/' 이거나 'index.html'을 포함하고 있는지 확인 (기존 변수 활용 가능)
   const isMain = window.location.pathname === '/' || window.location.pathname.includes('index.html');

   // 메인이 아닐 때만 TOP 버튼 생성 및 추가
   if (!isMain) {
      const btn = document.createElement('div');
      btn.innerHTML = '▲ TOP';
      btn.style = 'position:fixed; bottom:20px; right:20px; background:#333; color:#fff; padding:10px 15px; cursor:pointer; border-radius:5px; font-size:14px; z-index:9999; font-family:sans-serif;';
      
      // 클릭하면 최상단으로 부드럽게 이동
      btn.onclick = function() {
         window.scrollTo({ top: 0, behavior: 'smooth' });
      };
      
      document.body.appendChild(btn);
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