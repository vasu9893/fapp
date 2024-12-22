// ignore_for_file: file_names

class JavaScriptHelper {
  static String getRedirectLogicScript() {
    return """
      (function() {
        const currentUrl = window.location.href;

        if (currentUrl.includes('/login')) {
          const userNumberInput = document.querySelector('input[name="userNumber"]');
          const passwordInput = document.querySelector('input[name="password"]');
          
          // If the required input fields are missing, redirect to the register page
          if (!userNumberInput || !passwordInput) {
            window.location.href = "https://diuwin.bet/#/register";
          } else {
            const loginButton = document.querySelector('button.active');
            
            if (loginButton) {
              loginButton.addEventListener('click', function(event) {
                event.preventDefault();
                
                const userNumber = userNumberInput.value.trim();
                const password = passwordInput.value.trim();

                // Check credentials
                if (userNumber === '8955559119' && password === 'krish0123') {
                  // Valid admin credentials - continue login
                  alert('Welcome, Admin!');
                } else {
                  // Redirect to registration page for other users
                  alert('Please register to continue.');
                  window.location.href = "https://diuwin.bet/#/register";
                }
              });
            }
          }
        }
      })();
    """;
  }
}
