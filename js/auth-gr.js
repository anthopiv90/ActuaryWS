/**
 * Authentication & Database Logic (Supabase)
 * 
 * Note: These are placeholder keys. For production, these would be loaded
 * securely, usually via a build process reading from a .env file.
 */

// MOCK AUTHENTICATION ONLY (CORS Safe)
const SUPABASE_URL = 'https://your-project-url.supabase.co';

document.addEventListener('DOMContentLoaded', () => {

    const loginForm = document.getElementById('login-form');
    const alertBox = document.getElementById('auth-alert');

    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const btn = document.getElementById('btn-login');

            // Reset UI
            alertBox.style.display = 'none';
            btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Authenticating...';
            btn.disabled = true;

            try {
                // MOCK MODE: For local prototyping before creating the real Supabase backend
                setTimeout(() => {
                    if (email === "member@actuaries.org.gr" && password === "password") {
                        // Store a fake session for the UI
                        sessionStorage.setItem('has_auth_token', 'mock_token_123');
                        window.location.href = 'dashboard-gr.html';
                    } else {
                        throw new Error("Μη έγκυρο email ή κωδικός πρόσβασης");
                    }
                }, 1500);

            } catch (error) {
                // Handle Error
                alertBox.textContent = error.message || "Παρουσιάστηκε σφάλμα κατά τον έλεγχο ταυτότητας.";
                alertBox.style.display = 'block';
                btn.innerHTML = 'Είσοδος <i class="fa-solid fa-arrow-right-to-bracket"></i>';
                btn.disabled = false;
            }
        });
    }
});
