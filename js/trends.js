function initTrendTransitions() {
  const reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (reduceMotion) {
    return;
  }

  document.querySelectorAll("a[href$='.html']").forEach((link) => {
    link.addEventListener("click", (event) => {
      const href = link.getAttribute("href");
      if (!href || link.target || href.startsWith("http")) {
        return;
      }

      event.preventDefault();
      document.body.classList.add("page-leaving");
      window.setTimeout(() => {
        window.location.href = href;
      }, 140);
    });
  });
}

function initTrendGame() {
  const avatar = document.getElementById("avatar");
  const arena = document.getElementById("gameArena");
  if (!avatar || !arena) {
    return;
  }

  let x = 45;
  let y = 45;
  const move = (dx, dy) => {
    x = Math.max(3, Math.min(92, x + dx));
    y = Math.max(3, Math.min(88, y + dy));
    avatar.style.left = `${x}%`;
    avatar.style.top = `${y}%`;
  };

  window.addEventListener("keydown", (event) => {
    if (event.key === "ArrowLeft") move(-4, 0);
    if (event.key === "ArrowRight") move(4, 0);
    if (event.key === "ArrowUp") move(0, -4);
    if (event.key === "ArrowDown") move(0, 4);
  });

  arena.querySelectorAll(".portal").forEach((portal) => {
    portal.setAttribute("href", portal.dataset.target || "trends-index.html");
  });
}

document.addEventListener("DOMContentLoaded", () => {
  initTrendTransitions();
  initTrendGame();
});
