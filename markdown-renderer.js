// markdown-renderer.js
const renderMarkdown = () => {
  const contentArea = document.getElementById('guide-content');

  if (contentArea && typeof marked !== 'undefined') {
    const rawMarkdown = contentArea.textContent.trim();

    marked.setOptions({
      gfm: true,
      breaks: true
    });

    contentArea.innerHTML = marked.parse(rawMarkdown);

    // 이미지를 figure로 감싸고 alt 텍스트를 하단 캡션으로 자동 생성
    contentArea.querySelectorAll('img').forEach(img => {
      if (img.alt && img.alt.trim() !== '') {
        const figure = document.createElement('figure');
        figure.className = 'img-figure';

        const caption = document.createElement('figcaption');
        caption.className = 'img-caption';
        caption.textContent = img.alt;

        // 기존 img 위치에 figure를 넣고, 그 안에 img와 caption 배치
        img.parentNode.insertBefore(figure, img);
        figure.appendChild(img);
        figure.appendChild(caption);
      }
    });
  }
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', renderMarkdown);
} else {
  renderMarkdown();
}

/*
  // HTML에서 <div id="guide-content"> 대신 <div class="page-markdown">을 사용하면, 한 페이지에 마크다운 박스를 2개, 3개 나누어 작성해도 자바스크립트가 한 번에 모두 찾아서 알아서 변환해 줍니다.

document.addEventListener("DOMContentLoaded", function() {
  // page-markdown 이라는 클래스를 가진 모든 요소를 선택합니다.
  const markdownAreas = document.querySelectorAll('.page-markdown');

// 요소가 1개 이상 존재할 때만 루프를 돌며 변환합니다.
  if (markdownAreas.length > 0) {
    // Marked 옵션은 루프 밖에서 한 번만 설정하는 것이 효율적입니다.
    marked.setOptions({
    gfm: true,
    breaks: true
    });

    markdownAreas.forEach(function(area) {
      const rawMarkdown = area.textContent.trim();
      area.innerHTML = marked.parse(rawMarkdown);
      });
    }
});
*/
