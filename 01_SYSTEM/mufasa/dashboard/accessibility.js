(function () {
  "use strict";
  if (window.__mufasaAccessibility) return;
  window.__mufasaAccessibility = true;

  var KEY = "mufasa.accessibility";
  var VLIBRAS = "https://vlibras.gov.br/app";
  var SCALES = [0.9, 1, 1.1, 1.25, 1.4, 1.6];
  var DEFAULT = {
    scale: 1, contrast: false, dark: false, gray: false, readable: false, spacing: false,
    links: false, guide: false, cursor: false, animations: false, voice: false, libras: false
  };
  var doc = document, html = doc.documentElement;
  var pref = read();

  function read() {
    var p = {};
    for (var k in DEFAULT) p[k] = DEFAULT[k];
    try {
      var saved = JSON.parse(localStorage.getItem(KEY) || "{}");
      for (var c in DEFAULT) if (typeof saved[c] === typeof DEFAULT[c]) p[c] = saved[c];
    } catch (e) {  }
    if (!(p.scale >= 0 && p.scale < SCALES.length)) p.scale = 1;
    return p;
  }
  function save() {
    try { localStorage.setItem(KEY, JSON.stringify(pref)); } catch (e) {  }
  }

  var ARROW = "data:image/svg+xml," + encodeURIComponent(
    '<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24">' +
    '<path d="M4 2l16 9.5-7 1.3 4.2 7.6-3 1.6-4.2-7.6L4 19z" fill="#000" stroke="#fff" stroke-width="1.4"/></svg>');
  var css = [

    "#mf-a11y-button{position:fixed;right:18px;bottom:96px;z-index:2147483000;width:52px;height:52px;border-radius:50%;",
    " border:2px solid #FFFFFF;background:#8C6410;color:#FFFFFF;box-shadow:0 4px 14px rgba(61,43,31,.35);cursor:pointer;",
    " display:flex;align-items:center;justify-content:center;padding:0;}",
    "#mf-a11y-button:hover{background:#6E4E0B;}",
    "#mf-a11y-button:focus-visible,#mf-a11y-menu button:focus-visible{outline:3px solid #C99720;outline-offset:3px;}",
    "#mf-a11y-menu{position:fixed;right:18px;bottom:158px;z-index:2147483000;width:min(352px,calc(100vw - 36px));",
    " max-height:calc(100vh - 180px);overflow:auto;background:#FFFFFF;color:#3D2B1F;border:1px solid #E6D5AC;",
    " border-radius:16px;box-shadow:0 12px 32px rgba(61,43,31,.25);padding:16px;font:14px/1.4 Inter,system-ui,sans-serif;",
    " letter-spacing:normal;word-spacing:normal;zoom:1;filter:none;}",
    "#mf-a11y-menu[hidden]{display:none;}",
    "#mf-a11y-menu .header{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;}",
    "#mf-a11y-menu h2{font-size:16px;line-height:22px;font-weight:700;margin:0;color:#3D2B1F;}",
    "#mf-a11y-menu .sub{font-size:12px;color:#6B5432;margin:0 0 12px 0;}",
    "#mf-a11y-menu h3{font-size:12px;font-weight:700;color:#8C6410;margin:14px 0 8px 0;letter-spacing:.02em;}",
    "#mf-a11y-menu .grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;}",
    "#mf-a11y-menu button{font:inherit;color:#3D2B1F;background:#FBF6EA;border:1px solid #E6D5AC;border-radius:10px;",
    " padding:9px 10px;cursor:pointer;text-align:left;font-weight:600;font-size:13px;line-height:18px;}",
    "#mf-a11y-menu button:hover{border-color:#C99720;}",
    "#mf-a11y-menu button[aria-pressed=true]{background:#C99720;border-color:#8C6410;color:#3D2B1F;}",
    "#mf-a11y-menu button[aria-pressed=true]::before{content:'\\2713  ';}",
    "#mf-a11y-menu button:disabled{opacity:.5;cursor:not-allowed;}",
    "#mf-a11y-menu .close{background:transparent;border:none;font-size:20px;line-height:20px;padding:4px 8px;}",
    "#mf-a11y-menu .row{display:flex;gap:8px;align-items:center;}",
    "#mf-a11y-menu .row output{flex:1;text-align:center;font-weight:700;}",
    "#mf-a11y-menu .row button{min-width:56px;text-align:center;}",
    "#mf-a11y-menu .wide{grid-column:1/-1;}",
    "#mf-a11y-menu .notice{background:#FBF6EA;border:1px solid #E6D5AC;border-left:4px solid #C99720;border-radius:10px;",
    " padding:10px 12px;font-size:12.5px;line-height:18px;margin-top:8px;}",
    "#mf-a11y-menu .notice p{margin:0 0 8px 0;}",
    "#mf-a11y-menu .notice .row button{flex:1;text-align:center;}",
    "#mf-a11y-menu .note{font-size:11.5px;color:#6B5432;margin:6px 0 0 0;}",
    "#mf-a11y-menu .footer{margin-top:14px;}",
    "#mf-a11y-menu .footer button{width:100%;text-align:center;background:#FFFFFF;}",
    "#mf-a11y-guide{position:fixed;left:0;right:0;height:40px;margin-top:-20px;pointer-events:none;z-index:2147482999;",
    " background:rgba(201,151,32,.16);border-top:2px solid #8C6410;border-bottom:2px solid #8C6410;display:none;}",
    "html.mf-a-guide #mf-a11y-guide{display:block;}",

    "html.mf-a-scale .stApp{zoom:var(--mf-a-scale);}",

    "html.mf-a-filter .stApp{filter:var(--mf-a-filter);}",
    "html.mf-a-dark .stApp{background:#FFFFFF;}",
    "html.mf-a-dark .stApp img,html.mf-a-dark .stApp video{filter:invert(1) hue-rotate(180deg);}",

    "html.mf-a-contrast .stApp,html.mf-a-contrast .stApp *:not(svg):not(svg *):not(img):not(.mf-badge):not(.mf-badge *)",
    ":not([style*=background]):not([style*=background] *){background-color:#000 !important;",
    " color:#FFF !important;border-color:#FFF !important;box-shadow:none !important;background-image:none !important;}",
    "html.mf-a-contrast .stApp :is(.mf-badge,[style*=background]){outline:1px solid #FFF;}",
    "html.mf-a-contrast .stApp a,html.mf-a-contrast .stApp a *{color:#FFE600 !important;text-decoration:underline !important;}",
    "html.mf-a-contrast .stApp button,html.mf-a-contrast .stApp button *{color:#FFE600 !important;}",
    "html.mf-a-contrast .stApp button{border:2px solid #FFE600 !important;}",
    "html.mf-a-contrast .stApp svg{color:#FFF;}",
    "html.mf-a-contrast .stApp input,html.mf-a-contrast .stApp textarea{caret-color:#FFE600;}",

    "html.mf-a-readable .stApp,html.mf-a-readable .stApp *:not(svg):not(svg *){font-family:Verdana,Tahoma,'Segoe UI',Arial,sans-serif !important;}",

    "html.mf-a-spacing .stApp :is(p,li,label,span,td,th,a,small,b,strong,input,textarea,h1,h2,h3,h4){",
    " line-height:1.7 !important;letter-spacing:.06em !important;word-spacing:.14em !important;}",
    "html.mf-a-spacing .stApp p{margin-bottom:1em !important;}",

    "html.mf-a-links .stApp :is(a,button,[role=button],[role=tab],summary){outline:2px solid #8C6410 !important;",
    " outline-offset:2px !important;text-decoration:underline !important;}",
    "html.mf-a-links.mf-a-contrast .stApp :is(a,button,[role=button],[role=tab],summary){outline-color:#FFE600 !important;}",
    "html.mf-a-links .stApp :focus-visible{outline:4px solid #C99720 !important;outline-offset:3px !important;}",

    "html.mf-a-cursor,html.mf-a-cursor *{cursor:url(\"" + ARROW + "\") 6 3,auto !important;}",

    "html.mf-a-animations *,html.mf-a-animations *::before,html.mf-a-animations *::after{animation-duration:0s !important;",
    " animation-iteration-count:1 !important;transition:none !important;scroll-behavior:auto !important;}",

    "html:not(.mf-a-libras) [vw].enabled{display:none !important;}",
    "@media print{#mf-a11y-button,#mf-a11y-menu,#mf-a11y-guide{display:none !important;}}"
  ].join("\n");
  var style = doc.createElement("style");
  style.id = "mf-a11y-style";
  style.textContent = css;
  doc.head.appendChild(style);

  var ICON = '<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"' +
    ' stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' +
    '<circle cx="12" cy="4.5" r="1.8" fill="currentColor"/><path d="M4.5 8.5c2.4.8 4.9 1.2 7.5 1.2s5.1-.4 7.5-1.2"/>' +
    '<path d="M12 9.7v4.8"/><path d="M12 14.5l-3 6.5"/><path d="M12 14.5l3 6.5"/></svg>';
  var OPTIONS = [
    ["Vision", [["contrast", "High contrast"], ["dark", "Dark mode"], ["gray", "Grayscale"], ["links", "Highlight links and buttons"]]],
    ["Reading", [["readable", "More readable font"], ["spacing", "More space in the text"]]],
    ["Focus and attention", [["guide", "Reading guide"], ["cursor", "Large cursor"], ["animations", "Pause animations"]]]
  ];
  var hasVoice = "speechSynthesis" in window && "SpeechSynthesisUtterance" in window;

  var button = doc.createElement("button");
  button.id = "mf-a11y-button";
  button.type = "button";
  button.setAttribute("aria-label", "Accessibility: open options");
  button.setAttribute("aria-expanded", "false");
  button.setAttribute("aria-controls", "mf-a11y-menu");
  button.title = "Accessibility";
  button.innerHTML = ICON;

  var menu = doc.createElement("div");
  menu.id = "mf-a11y-menu";
  menu.setAttribute("role", "dialog");
  menu.setAttribute("aria-modal", "false");
  menu.setAttribute("aria-labelledby", "mf-a11y-title");
  menu.hidden = true;
  var h = '<div class="header"><h2 id="mf-a11y-title">Accessibility</h2>' +
    '<button type="button" class="close" data-action="close" aria-label="Close accessibility options">×</button></div>' +
    '<p class="sub">Your choices are saved in this browser.</p>' +
    '<h3 id="mf-a11y-size">TEXT SIZE</h3>' +
    '<div class="row" role="group" aria-labelledby="mf-a11y-size">' +
    '<button type="button" data-action="smaller" aria-label="Make the text smaller">A−</button>' +
    '<output id="mf-a11y-scale" aria-live="polite"></output>' +
    '<button type="button" data-action="larger" aria-label="Make the text larger">A+</button></div>';
  OPTIONS.forEach(function (group, i) {
    h += '<h3 id="mf-a11y-g' + i + '">' + group[0].toUpperCase() + '</h3><div class="grid" role="group" aria-labelledby="mf-a11y-g' + i + '">';
    group[1].forEach(function (o) {
      h += '<button type="button" data-option="' + o[0] + '" aria-pressed="false">' + o[1] + "</button>";
    });
    h += "</div>";
  });
  h += '<h3 id="mf-a11y-listen">LISTEN AND LIBRAS</h3><div class="grid" role="group" aria-labelledby="mf-a11y-listen">' +
    '<button type="button" data-option="voice" aria-pressed="false"' + (hasVoice ? "" : " disabled") + '>Read selected text</button>' +
    '<button type="button" data-action="read"' + (hasVoice ? "" : " disabled") + '>Read the page</button>' +
    '<button type="button" data-action="stop" class="wide"' + (hasVoice ? "" : " disabled") + '>Stop reading</button>' +
    '<button type="button" data-option="libras" aria-pressed="false" class="wide">Libras translator (VLibras)</button></div>' +
    '<p class="note">' + (hasVoice ? "Reading uses the browser's own voice and sends nothing outside."
      : "This browser does not have read-aloud.") + "</p>" +
    '<div class="notice" id="mf-a11y-notice-libras" hidden role="region" aria-labelledby="mf-a11y-notice-title">' +
    '<p id="mf-a11y-notice-title"><b>Before turning on VLibras</b></p>' +
    "<p>VLibras is a Brazilian Federal Government service. When you turn it on, the translator is loaded from vlibras.gov.br and the " +
    "text you click to translate is sent to that service. This text may contain personal data that " +
    "appears on the screen, such as names and grades. MUFASA sends nothing on its own.</p>" +
    "<p>You can turn it off whenever you want. More details in the Privacy Policy.</p>" +
    '<div class="row"><button type="button" data-action="libras-yes">Turn on VLibras</button>' +
    '<button type="button" data-action="libras-no">Not now</button></div></div>' +
    '<div class="footer"><button type="button" data-action="restore">Restore the default</button></div>';
  menu.innerHTML = h;

  var guide = doc.createElement("div");
  guide.id = "mf-a11y-guide";
  guide.setAttribute("aria-hidden", "true");

  doc.body.insertBefore(guide, doc.body.firstChild);
  doc.body.insertBefore(menu, doc.body.firstChild);
  doc.body.insertBefore(button, doc.body.firstChild);

  function open(yes) {
    menu.hidden = !yes;
    button.setAttribute("aria-expanded", yes ? "true" : "false");
    button.setAttribute("aria-label", yes ? "Accessibility: close options" : "Accessibility: open options");
    if (yes) menu.querySelector("[data-action=close]").focus();
  }
  button.addEventListener("click", function () { open(menu.hidden); });
  doc.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && !menu.hidden) { open(false); button.focus(); }
  });
  doc.addEventListener("click", function (e) {
    if (!menu.hidden && !menu.contains(e.target) && !button.contains(e.target)) open(false);
  });

  function apply() {
    var scale = SCALES[pref.scale];
    html.style.setProperty("--mf-a-scale", String(scale));
    html.classList.toggle("mf-a-scale", scale !== 1);
    var filters = [];
    if (pref.dark && !pref.contrast) filters.push("invert(.92) hue-rotate(180deg)");
    if (pref.gray) filters.push("grayscale(1)");
    html.style.setProperty("--mf-a-filter", filters.join(" ") || "none");
    html.classList.toggle("mf-a-filter", filters.length > 0);
    ["contrast", "dark", "readable", "spacing", "links", "guide", "cursor", "animations", "libras"].forEach(function (k) {
      html.classList.toggle("mf-a-" + k, !!pref[k]);
    });
    menu.querySelectorAll("[data-option]").forEach(function (b) {
      b.setAttribute("aria-pressed", pref[b.getAttribute("data-option")] ? "true" : "false");
    });
    menu.querySelector("#mf-a11y-scale").textContent = Math.round(scale * 100) + "%";
    menu.querySelector("[data-action=smaller]").disabled = pref.scale === 0;
    menu.querySelector("[data-action=larger]").disabled = pref.scale === SCALES.length - 1;
    if (pref.libras) loadVLibras();
  }

  menu.addEventListener("click", function (e) {
    var target = e.target.closest("button");
    if (!target) return;
    var option = target.getAttribute("data-option"), action = target.getAttribute("data-action");
    var notice = menu.querySelector("#mf-a11y-notice-libras");
    if (option === "libras") {
      if (pref.libras) { pref.libras = false; turnOffVLibras(); }
      else { notice.hidden = false; notice.querySelector("[data-action=libras-yes]").focus(); return; }
    } else if (option) {
      pref[option] = !pref[option];
      if (option === "contrast" && pref.contrast) pref.dark = false;
      if (option === "dark" && pref.dark) pref.contrast = false;
      if (option === "voice" && !pref.voice) stopReading();
    } else if (action === "close") { open(false); button.focus(); return; }
    else if (action === "smaller") pref.scale = Math.max(0, pref.scale - 1);
    else if (action === "larger") pref.scale = Math.min(SCALES.length - 1, pref.scale + 1);
    else if (action === "read") { readPage(); return; }
    else if (action === "stop") { stopReading(); return; }
    else if (action === "libras-yes") { notice.hidden = true; pref.libras = true; }
    else if (action === "libras-no") { notice.hidden = true; menu.querySelector("[data-option=libras]").focus(); return; }
    else if (action === "restore") {
      stopReading();
      if (pref.libras) turnOffVLibras();
      for (var k in DEFAULT) pref[k] = DEFAULT[k];
    }
    save();
    apply();
  });

  doc.addEventListener("mousemove", function (e) {
    if (pref.guide) guide.style.top = e.clientY + "px";
  }, { passive: true });

  function speak(text) {
    if (!hasVoice) return;
    text = (text || "").replace(/\s+/g, " ").trim().slice(0, 6000);
    if (!text) return;
    window.speechSynthesis.cancel();
    var u = new SpeechSynthesisUtterance(text);
    u.lang = "en-US";
    var voice = window.speechSynthesis.getVoices().filter(function (v) { return /^en(-|_)/i.test(v.lang); })[0];
    if (voice) u.voice = voice;
    window.speechSynthesis.speak(u);
  }
  function stopReading() { if (hasVoice) window.speechSynthesis.cancel(); }
  function readPage() {
    var area = doc.querySelector('[data-testid="stMainBlockContainer"]') || doc.querySelector(".stApp");
    speak(area ? area.innerText : "");
  }
  function readSelection(e) {
    if (!pref.voice || menu.contains(e.target)) return;
    var sel = String(window.getSelection ? window.getSelection() : "");
    if (sel.trim().length > 1) speak(sel);
  }
  doc.addEventListener("mouseup", readSelection);
  doc.addEventListener("keyup", function (e) { if (e.shiftKey) readSelection(e); });

  var vlibrasLoaded = false;
  function loadVLibras() {
    var box = doc.querySelector("[vw]");
    if (!box) {
      box = doc.createElement("div");
      box.setAttribute("vw", "");
      box.className = "enabled";
      box.innerHTML = '<div vw-access-button class="active"></div>' +
        '<div vw-plugin-wrapper><div class="vw-plugin-top-wrapper"></div></div>';
      doc.body.appendChild(box);
    }
    if (vlibrasLoaded) return;
    vlibrasLoaded = true;
    var s = doc.createElement("script");
    s.src = VLIBRAS + "/vlibras-plugin.js";
    s.async = true;
    s.referrerPolicy = "no-referrer";
    s.onload = function () {
      if (!window.VLibras) return;
      new window.VLibras.Widget(VLIBRAS);

      window.dispatchEvent(new Event("load"));
    };
    s.onerror = function () {
      vlibrasLoaded = false;
      var note = menu.querySelector(".note");
      if (note) note.textContent = "Could not load VLibras. Check the internet connection.";
    };
    doc.head.appendChild(s);
  }
  function turnOffVLibras() {

    if (window.VLibras && doc.querySelector("[vw-plugin-wrapper].active [vw-plugin-close]")) {
      doc.querySelector("[vw-plugin-close]").click();
    }
  }

  apply();
})();
