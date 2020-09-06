const navLinks = document.querySelectorAll("a.link");

for (const link of navLinks) {
  link.addEventListener("mouseover", () => {
    link.classList.add("link_hovered");
    link.classList.remove("link_unhovered");
  });
  link.addEventListener("mouseout", () => {
    link.classList.add("link_unhovered");
    link.classList.remove("link_hovered");
  });
}

const queryResult = document.querySelector("textarea");
const clearQueryResultBtn = queryResult.nextElementSibling;

if (clearQueryResultBtn) {
  clearQueryResultBtn.addEventListener("click", () => {
    queryResult.innerHTML = "";
  });
}
