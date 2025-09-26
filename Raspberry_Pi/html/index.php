<!doctype html>
<html lang="en" data-bs-theme="dark">
  <head>
    <script src="/assets/js/color-modes.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Split Flap Display</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@docsearch/css@3">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/assets/dist/css/cover.css" rel="stylesheet">

    <!-- 
     adjust the following settings below to change rows and cols:
     CSS: 
     - width: calc(1ch * 16);
     - height: calc(1em * 3 + 2px); 
     HTML: 
     - <textarea ... rows="3" cols="16" maxlength="48" ... ></textarea>
    -->

    <style>
    .text-input {
      font-family: monospace;
      font-size: 2em;
      letter-spacing: 0;
      color: white;
      border: 1px solid white;
      box-sizing: content-box;
      resize: none;
      padding: 0.4em;
      margin: 0;
      text-transform: uppercase;
      width: calc(1ch * 16);
      height: calc(1em * 2 + 2px);
      line-height: 1em;
      white-space: break-spaces;
      word-break: break-all;
    }
    </style>
  </head>

  <body>
    <div class="container">
      <header class="border-bottom lh-1 py-3">
        <div class="row flex-nowrap justify-content-between align-items-center">
            <h1 class="display-4 link-body-emphasis mb-1 text-nowrap text-center">Split Flap Display</h1>
        </div>
      </header>

      <!--
      <div class="nav-scroller py-1 mb-1 border-bottom">
        <nav class="nav nav-underline justify-content-between">
          <a href="#" class="nav-item nav-link link-body-emphasis active">Home</a>
        </nav>
      </div>
      -->
    </div>

    <main class="container d-flex justify-content-center align-items-center" style="min-height: 50vh;">
      <div class="w-100 py-3" style="max-width: 400px;">
        <h2 class="text-center mb-4">Feed Your Text</h2>
    
        <form id="form">
          <div class="mb-3">
            <textarea id="text" name="text" class="text-input form-control mx-auto" rows="2" cols="16" maxlength="32" wrap="soft" autofocus></textarea>
          </div>
    
          <div class="mb-3">
            <label for="dropdown" class="form-label">Timing</label>
            <select class="form-select" id="dropdown" name="animation">
              <option value="start">Start</option>
              <option value="stop">Stop</option>
              <option value="left">-&gt; From left</option>
              <option value="right">&lt;- From right</option>
            </select>
          </div>
    
          <div class="form-check mb-3">
            <input class="form-check-input" type="checkbox" id="same" name="same" value="1">
            <label class="form-check-label" for="same">Skip aligned</label>
          </div> 

          <div class="form-check mb-3">
            <input class="form-check-input" type="checkbox" id="wipe" name="wipe" value="1">
            <label class="form-check-label" for="wipe">Wipe to the end</label>
          </div>

          <div class="text-center">
            <button type="submit" class="btn btn-primary">Display</button>
            <button type="button" class="btn btn-secondary" id="clear">Clear</button>
          </div>
        </form>
    
      </div>
    </main>

    <footer class="py-5 text-center text-body-secondary bg-body-tertiary">
      <!-- Footer-Inhalt -->
      Stefan Frech, Zuerich
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <script>
      $('#form').on('submit', function(event) {
        event.preventDefault();
    
        // Formulardaten serialisieren
        const formData = $(this).serialize();
    
        $.ajax({
          type: 'POST',
          url: '/text.php',
          data: formData,
          success: function(response) {
            console.log('Server-Antwort:', response);
            // document.getElementById('text').select();
            $('#text').focus();
          },
          error: function(xhr, status, error) {
            console.error('Fehler:', error);
          }
        });
      });

      $('#clear').on('click', function() {
        $('#text').val('').focus();
      });
    </script>

  </body>
</html>
