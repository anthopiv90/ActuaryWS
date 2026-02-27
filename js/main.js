// Main JavaScript file for interactivity

document.addEventListener('DOMContentLoaded', () => {

    // Mobile Navigation Toggle
    const menuToggle = document.querySelector('.mobile-menu-toggle');
    const navLinks = document.querySelector('.nav-links');

    if (menuToggle && navLinks) {
        menuToggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');

            // Animate hamburger to X (optional enhancement)
            const spans = menuToggle.querySelectorAll('span');
            if (navLinks.classList.contains('active')) {
                spans[0].style.transform = 'translateY(8px) rotate(45deg)';
                spans[1].style.opacity = '0';
                spans[2].style.transform = 'translateY(-8px) rotate(-45deg)';
            } else {
                spans[0].style.transform = 'translateY(0) rotate(0)';
                spans[1].style.opacity = '1';
                spans[2].style.transform = 'translateY(0) rotate(0)';
            }
        });
    }

    // Mobile Mega Menu Accordion Toggle
    const dropdownToggles = document.querySelectorAll('.has-dropdown > a');
    dropdownToggles.forEach(toggle => {
        toggle.addEventListener('click', (e) => {
            if (window.innerWidth <= 768) {
                e.preventDefault();
                const megaMenu = toggle.nextElementSibling;
                if (megaMenu) {
                    megaMenu.classList.toggle('active');
                    const icon = toggle.querySelector('.fa-chevron-down');
                    if (icon) {
                        icon.style.transform = megaMenu.classList.contains('active') ? 'rotate(180deg)' : 'rotate(0)';
                        icon.style.transition = 'transform 0.3s';
                        icon.style.display = 'inline-block';
                    }
                }
            }
        });
    });

    // Header Scroll Effect
    const mainNav = document.querySelector('.main-nav');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 10) {
            mainNav.style.boxShadow = 'var(--shadow-md)';
        } else {
            mainNav.style.boxShadow = 'var(--shadow-sm)';
        }
    });
});
