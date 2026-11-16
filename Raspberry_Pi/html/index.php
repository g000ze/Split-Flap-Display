<?php
// Grösse und Zeichensatz kommen aus split-flap.php, damit Eingabe und Display immer übereinstimmen.
require (__DIR__ . "/../split-flap.php");
?>
<!doctype html>
<html lang="en" data-bs-theme="dark">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Split Flap Display</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/assets/dist/css/cover.css" rel="stylesheet">
    <link href="/assets/css/split-flap.css" rel="stylesheet">
  </head>

  <body>
    <div class="container">
      <header class="border-bottom lh-1 py-3">
        <h1 class="display-4 link-body-emphasis mb-1 text-center">Split Flap Display</h1>
      </header>
    </div>

    <main class="container py-4">
      <div class="row justify-content-center">
        <div class="col-xl-10">
          <h2 class="text-center mb-4">Feed Your Text</h2>

          <form id="form" action="/text.php" method="post">
            <div id="board" class="split-flap mb-3"
                 data-cols="<?= $cols ?>"
                 data-rows="<?= $rows ?>"
                 data-charset="<?= htmlspecialchars(implode('', $characters)) ?>"
                 data-text="">
              <div class="split-flap-grid"></div>
              <textarea class="split-flap-capture" aria-label="Text for the split flap display" autocapitalize="characters" autocorrect="off" spellcheck="false"></textarea>
            </div>

            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-1">
              <span id="status" class="font-monospace small text-body-secondary"></span>
              <button type="button" class="btn btn-sm btn-outline-secondary ms-auto" id="mode">Mode: Insert</button>
            </div>
            <p id="message" class="split-flap-message small text-body-secondary mb-4" role="status"></p>

            <div class="row g-3 mb-4">
              <div class="col-md-6">
                <label for="animation" class="form-label">Animation</label>
                <select class="form-select" id="animation" name="animation">
                  <option value="start">Start</option>
                  <option value="stop">Stop</option>
                  <option value="left">-&gt; From left</option>
                  <option value="right">&lt;- From right</option>
                  <option value="top">Top</option>
                  <option value="bottom">Bottom</option>
                  <option value="snake1">Snake 1</option>
                  <option value="snake2">Snake 2</option>
                  <option value="snake3">Snake 3</option>
                  <option value="snake4">Snake 4</option>
                  <option value="random">Random</option>
                  <option value="cross">Cross</option>
                  <option value="diagonal">Diagonal</option>
                  <option value="round">Round</option>
                </select>
              </div>

              <div class="w-100 m-0"></div>

              <div class="col-md-6">
                <label for="slowdown" class="form-label">Slowdown <span id="slowdown-value" class="text-body-secondary">1</span></label>
                <input type="range" class="form-range" id="slowdown" name="slowdown" min="1" max="10" value="1">
              </div>

              <div class="col-12">
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="checkbox" id="same" name="same" value="1">
                  <label class="form-check-label" for="same">Skip aligned</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="checkbox" id="wipe" name="wipe" value="1" checked>
                  <label class="form-check-label" for="wipe">Wipe to the end</label>
                </div>
              </div>
            </div>

            <div class="d-flex justify-content-center gap-2">
              <button type="submit" class="btn btn-primary" id="submit">
                <span class="spinner-border spinner-border-sm me-1 d-none" aria-hidden="true"></span>Display
              </button>
              <button type="button" class="btn btn-secondary" id="clear">Clear</button>
            </div>
          </form>

          <details class="mt-5 small">
            <summary class="mb-2">Keyboard shortcuts</summary>
            <dl class="row mb-0">
              <dt class="col-sm-4"><kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd></dt>
              <dd class="col-sm-8">Move the cursor, with <kbd>Ctrl</kbd> word by word</dd>
              <dt class="col-sm-4"><kbd>Home</kbd> <kbd>End</kbd></dt>
              <dd class="col-sm-8">Start or end of the line, with <kbd>Ctrl</kbd> of the whole text</dd>
              <dt class="col-sm-4"><kbd>Enter</kbd></dt>
              <dd class="col-sm-8">Next line, splits the line at the cursor</dd>
              <dt class="col-sm-4"><kbd>Backspace</kbd> <kbd>Del</kbd></dt>
              <dd class="col-sm-8">Delete, joins lines</dd>
              <dt class="col-sm-4"><kbd>Insert</kbd></dt>
              <dd class="col-sm-8">Switch between insert and overwrite</dd>
              <dt class="col-sm-4"><kbd>Shift</kbd> + arrows</dt>
              <dd class="col-sm-8">Select, also with the mouse</dd>
              <dt class="col-sm-4"><kbd>Ctrl</kbd> A C X V Z Y</dt>
              <dd class="col-sm-8">Select all, copy, cut, paste, undo, redo</dd>
              <dt class="col-sm-4"><kbd>Ctrl</kbd> <kbd>Enter</kbd></dt>
              <dd class="col-sm-8">Display</dd>
            </dl>
          </details>
        </div>
      </div>
    </main>

    <footer class="py-5 text-center text-body-secondary bg-body-tertiary">
      Stefan Frech, Zuerich
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/assets/js/split-flap.js"></script>
  </body>
</html>
