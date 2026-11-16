/*
 * Split-Flap-Eingabe
 * Grösse, Zeichensatz und Starttext kommen aus den data-Attributen von #board.
 * Gesendet wird an die URL im action-Attribut von #form.
 */
(() => {
  "use strict";

  /* Einstellungen */
  const SHOW_POSITION = false;  // Zeile, Spalte und freie Felder unter dem Display
  const SHOW_MESSAGES = false;  // Hinweise und Rückmeldungen, z. B. «Sent to the display.»

  const $ = (id) => document.getElementById(id);
  const board = $("board"), form = $("form");
  if (!board || !form) return;
  const grid = board.querySelector(".split-flap-grid");
  const capture = board.querySelector(".split-flap-capture");

  const COLS = +board.dataset.cols || 16;
  const ROWS = +board.dataset.rows || 3;
  const CHARSET = board.dataset.charset || "0ABCD1EFGH2IJKL3MNOP4QRST5UVWX6YZ+-7?!.,8@:;#9*$/ ";
  const SENTINEL = "​";
  const blank = " ".repeat(COLS);
  const pad = (s) => (s + blank).slice(0, COLS);
  const len = (s) => s.trimEnd().length;
  const idx = (p) => p.r * (COLS + 1) + p.c;

  let rows = Array(ROWS).fill(blank);
  let caret = { r: 0, c: 0 }, anchor = null, insert = true, undo = [], redo = [], busy = false;

  /* Aufbau */
  board.style.setProperty("--sf-cols", COLS);
  const cells = Array.from({ length: COLS * ROWS }, () => {
    const cell = grid.appendChild(document.createElement("div"));
    cell.className = "split-flap-cell";
    return cell;
  });
  const caretEl = document.createElement("span");
  caretEl.className = "split-flap-caret";

  /* Darstellung */
  function sel() {
    if (!anchor || idx(anchor) === idx(caret)) return null;
    return idx(anchor) < idx(caret) ? [anchor, caret] : [caret, anchor];
  }

  function render() {
    const s = sel(), end = caret.c === COLS;
    cells.forEach((cell, i) => {
      const r = Math.floor(i / COLS), c = i % COLS, k = idx({ r, c });
      cell.dataset.ch = rows[r][c];
      cell.classList.toggle("sel", !!s && k >= idx(s[0]) && k < idx(s[1]));
      cell.classList.toggle("over", !s && !insert && r === caret.r && c === caret.c);
    });
    cells[caret.r * COLS + Math.min(caret.c, COLS - 1)].append(caretEl);
    caretEl.classList.toggle("end", end);
    caretEl.classList.toggle("d-none", !!s || (!insert && !end));
    if (SHOW_POSITION) $("status").textContent = `Row ${caret.r + 1}/${ROWS} · Col ${Math.min(caret.c + 1, COLS)}/${COLS} · ${COLS - len(rows[caret.r])} free`;
    $("mode").textContent = "Mode: " + (insert ? "Insert" : "Overwrite");
    // Damit Kopieren zuverlässig funktioniert, muss im Feld etwas markiert sein.
    capture.value = SENTINEL;
    if (s) capture.select(); else capture.setSelectionRange(1, 1);
  }

  const TONES = { info: "text-body-secondary", warning: "text-warning", success: "text-success", danger: "text-danger" };
  function say(text, tone = "info") {
    if (!SHOW_MESSAGES) return;
    const el = $("message");
    el.textContent = text;
    Object.values(TONES).forEach((t) => el.classList.remove(t));
    el.classList.add(TONES[tone]);
  }

  /* Änderungen mit Rückgängig */
  function edit(fn) {
    const before = { rows: [...rows], caret: { ...caret } };
    fn();
    if (rows.join("") !== before.rows.join("")) { undo.push(before); redo = []; }
    anchor = null;
    render();
  }

  function restore(from, to) {
    const state = from.pop();
    if (!state) return;
    to.push({ rows: [...rows], caret: { ...caret } });
    ({ rows, caret } = state);
    anchor = null;
    render();
  }

  function deleteSel() {
    const s = sel();
    if (!s) return false;
    const [a, b] = s;
    for (let r = a.r; r <= b.r; r++) {
      const from = r === a.r ? a.c : 0, to = r === b.r ? b.c : COLS;
      const gap = insert && a.r === b.r ? "" : " ".repeat(to - from);
      rows[r] = pad(rows[r].slice(0, from) + gap + rows[r].slice(to));
    }
    caret = { ...a };
    return true;
  }

  // Liefert false, wenn das Zeichen keinen Platz hat.
  function putChar(ch) {
    if (caret.c === COLS) {
      if (caret.r === ROWS - 1) return false;
      caret = { r: caret.r + 1, c: 0 };
    }
    const { r, c } = caret, row = rows[r];
    if (insert && row[COLS - 1] !== " ") return false;
    rows[r] = pad(row.slice(0, c) + ch + row.slice(insert ? c : c + 1));
    caret = { r, c: c + 1 };
    return true;
  }

  function enter() {
    const { r, c } = caret, rest = rows[r].slice(c);
    if (insert && rest.trim()) {
      if (r === ROWS - 1 || rows[ROWS - 1].trim()) return say("Cannot split the line: no free row left.", "warning");
      rows[r] = pad(rows[r].slice(0, c));
      rows.splice(r + 1, 0, pad(rest));
      rows.pop();
    } else if (r === ROWS - 1) {
      return say(`The display has only ${ROWS} rows.`, "warning");
    }
    caret = { r: r + 1, c: 0 };
  }

  function backspace() {
    const { r, c } = caret;
    if (c > 0) {
      rows[r] = pad(rows[r].slice(0, c - 1) + (insert ? "" : " ") + rows[r].slice(c));
      caret = { r, c: c - 1 };
    } else if (r > 0) {
      const end = len(rows[r - 1]);
      if (insert && end + len(rows[r]) <= COLS) {
        rows[r - 1] = pad(rows[r - 1].slice(0, end) + rows[r]);
        rows.splice(r, 1);
        rows.push(blank);
      }
      caret = { r: r - 1, c: end };
    }
  }

  function del() {
    const { r, c } = caret, row = rows[r];
    if (c === COLS) return;
    if (!insert) rows[r] = pad(row.slice(0, c) + " " + row.slice(c + 1));
    else if (row.slice(c).trim()) rows[r] = pad(row.slice(0, c) + row.slice(c + 1));
    else if (r < ROWS - 1 && c + len(rows[r + 1]) <= COLS) {
      rows[r] = pad(row.slice(0, c) + rows[r + 1]);
      rows.splice(r + 1, 1);
      rows.push(blank);
    }
  }

  function typeText(text) {
    const bad = new Set();
    let full = 0;
    edit(() => {
      deleteSel();
      for (const ch of text.toUpperCase().replace(/\r\n?/g, "\n")) {
        if (ch === "\n") {
          if (caret.r < ROWS - 1) caret = { r: caret.r + 1, c: 0 };
          else full++;
        } else if (!CHARSET.includes(ch)) bad.add(ch);
        else if (!putChar(ch)) full++;
      }
    });
    if (bad.size) say(`Not available on the display: ${[...bad].join(" ")}`, "warning");
    else if (full) say(insert ? "No room left. Press Insert to switch to overwrite mode." : "The display is full.", "warning");
    else say("");
  }

  /* Cursor */
  function moveTo(r, c, extend) {
    if (!extend) anchor = null;
    else if (!anchor) anchor = { ...caret };
    caret = { r, c };
    render();
  }

  function wordLeft({ r, c }) {
    if (c === 0) return r > 0 ? [r - 1, len(rows[r - 1])] : [r, c];
    while (c > 0 && rows[r][c - 1] === " ") c--;
    while (c > 0 && rows[r][c - 1] !== " ") c--;
    return [r, c];
  }

  function wordRight({ r, c }) {
    if (c === COLS) return r < ROWS - 1 ? [r + 1, 0] : [r, c];
    while (c < COLS && rows[r][c] !== " ") c++;
    while (c < COLS && rows[r][c] === " ") c++;
    return [r, c];
  }

  function lastPos() {
    for (let r = ROWS - 1; r >= 0; r--) if (rows[r].trim()) return [r, len(rows[r])];
    return [0, 0];
  }

  function selectedText() {
    const s = sel();
    if (!s) return "";
    const [a, b] = s, lines = [];
    for (let r = a.r; r <= b.r; r++) lines.push(rows[r].slice(r === a.r ? a.c : 0, r === b.r ? b.c : COLS));
    return lines.map((l) => (a.r === b.r ? l : l.trimEnd())).join("\n");
  }

  /* Tastatur */
  capture.addEventListener("keydown", (e) => {
    if (e.isComposing) return;
    const mod = (e.ctrlKey || e.metaKey) && !e.altKey; // AltGr meldet Strg+Alt, z. B. für @ und #
    const word = e.ctrlKey || e.altKey, shift = e.shiftKey;
    const { r, c } = caret, s = sel();
    switch (e.key) {
      case "ArrowLeft":
        if (word) moveTo(...wordLeft(caret), shift);
        else if (s && !shift) moveTo(s[0].r, s[0].c);
        else if (c > 0) moveTo(r, c - 1, shift);
        else moveTo(Math.max(r - 1, 0), r > 0 ? COLS : 0, shift);
        break;
      case "ArrowRight":
        if (word) moveTo(...wordRight(caret), shift);
        else if (s && !shift) moveTo(s[1].r, s[1].c);
        else if (c < COLS) moveTo(r, c + 1, shift);
        else moveTo(Math.min(r + 1, ROWS - 1), r < ROWS - 1 ? 0 : COLS, shift);
        break;
      case "ArrowUp": moveTo(Math.max(r - 1, 0), c, shift); break;
      case "ArrowDown": moveTo(Math.min(r + 1, ROWS - 1), c, shift); break;
      case "Home": mod ? moveTo(0, 0, shift) : moveTo(r, 0, shift); break;
      case "End": mod ? moveTo(...lastPos(), shift) : moveTo(r, c === len(rows[r]) ? COLS : len(rows[r]), shift); break;
      case "Enter": mod ? form.requestSubmit() : (say(""), edit(() => deleteSel() || enter())); break;
      case "Backspace": say(""); edit(() => deleteSel() || backspace()); break;
      case "Delete": say(""); edit(() => deleteSel() || del()); break;
      case "Insert": insert = !insert; render(); break;
      default: {
        const key = e.key.toLowerCase();
        if (mod && key === "a") { anchor = { r: 0, c: 0 }; caret = { r: ROWS - 1, c: COLS }; render(); }
        else if (mod && key === "z" && !shift) restore(undo, redo);
        else if (mod && (key === "y" || key === "z")) restore(redo, undo);
        else if (!mod && e.key.length === 1) typeText(e.key);
        else return; // Strg+C, X, V laufen über die Zwischenablage-Ereignisse
      }
    }
    e.preventDefault();
  });

  // Bildschirmtastaturen und tote Tasten (z. B. ^) kommen über das Feld selbst herein.
  function flush() {
    const value = capture.value, text = value.split(SENTINEL).join("");
    if (text) typeText(text);
    else if (!value.includes(SENTINEL)) edit(() => deleteSel() || backspace());
    else render();
  }
  capture.addEventListener("input", (e) => { if (!e.isComposing) flush(); });
  capture.addEventListener("compositionend", flush);

  capture.addEventListener("copy", (e) => { e.preventDefault(); e.clipboardData.setData("text/plain", selectedText()); });
  capture.addEventListener("cut", (e) => { e.preventDefault(); e.clipboardData.setData("text/plain", selectedText()); edit(deleteSel); });
  capture.addEventListener("paste", (e) => { e.preventDefault(); typeText(e.clipboardData.getData("text/plain")); });

  /* Maus und Touch */
  function pointFrom(e) {
    const box = grid.getBoundingClientRect();
    const x = (e.clientX - box.left) / box.width * COLS;
    const y = (e.clientY - box.top) / box.height * ROWS;
    const r = Math.max(0, Math.min(ROWS - 1, Math.floor(y)));
    const c = Math.max(0, Math.min(COLS, insert ? Math.round(x) : Math.floor(x)));
    return [r, c];
  }
  let dragging = false;
  board.addEventListener("pointerdown", (e) => {
    e.preventDefault();
    capture.focus({ preventScroll: true });
    dragging = true;
    board.setPointerCapture(e.pointerId);
    moveTo(...pointFrom(e), e.shiftKey);
  });
  board.addEventListener("pointermove", (e) => { if (dragging) moveTo(...pointFrom(e), true); });
  // iOS nimmt dem Feld beim Loslassen den Fokus und schliesst die Tastatur. Darum hier erneut fokussieren.
  board.addEventListener("pointerup", () => { dragging = false; capture.focus({ preventScroll: true }); });
  board.addEventListener("click", () => capture.focus({ preventScroll: true }));
  board.addEventListener("pointercancel", () => { dragging = false; });

  /* Senden */
  function setBusy(state) {
    busy = state;
    const button = $("submit");
    button.disabled = state;
    button.querySelector(".spinner-border").classList.toggle("d-none", !state);
  }

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    if (busy) return;

    // Alle Formularfelder mit name (animation, slowdown, same, wipe) plus der Text.
    const data = new URLSearchParams(new FormData(form));
    const text = rows.join("");
    // Ohne Wipe bleiben Module nach dem letzten Zeichen stehen, wie es text.php vorsieht.
    data.set("text", data.has("wipe") ? text : text.trimEnd());
    if (!data.get("text")) return say("Nothing to send. Enable “Wipe to the end” to clear the display.", "warning");

    setBusy(true);
    say("Sending…");
    try {
      const response = await fetch(form.action, { method: "POST", body: data });
      const answer = (await response.text()).trim();
      if (answer) console.log("text.php:", answer);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      say("Sent to the display.", "success");
    } catch (error) {
      console.error("POST failed:", error);
      say(`Sending failed: ${error.message}`, "danger");
    } finally {
      setBusy(false);
      capture.focus({ preventScroll: true });
    }
  });

  /* Bedienung */
  const refocus = () => capture.focus({ preventScroll: true });
  $("mode").addEventListener("click", () => { insert = !insert; render(); refocus(); });
  $("clear").addEventListener("click", () => {
    edit(() => { rows = Array(ROWS).fill(blank); caret = { r: 0, c: 0 }; });
    say("");
    refocus();
  });
  const slowdown = $("slowdown");
  if (slowdown) slowdown.addEventListener("input", () => { $("slowdown-value").textContent = slowdown.value; });

  $("status").hidden = !SHOW_POSITION;
  $("message").hidden = !SHOW_MESSAGES;
  typeText(board.dataset.text || "");
  undo = [];
  refocus();
})();
