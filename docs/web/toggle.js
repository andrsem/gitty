const defaultTheme = 'dark';

(function() {
  const savedTheme = localStorage.getItem('theme') || defaultTheme;
  if (document.documentElement) {
    document.documentElement.setAttribute('data-theme', savedTheme);
  }
})();

// Create button after DOM loads
document.addEventListener('DOMContentLoaded', function() {
  const savedTheme = localStorage.getItem('theme') || defaultTheme;
  
  const btn = document.createElement('button');
  btn.className = 'theme-toggle';
  btn.innerHTML = savedTheme === 'dark' ? '☀️' : '🌙';
  btn.title = 'Toggle theme';
  
  const header = document.getElementById('header');
  if (header) {
    header.appendChild(btn);
  } else {
    // Fallback to body if no header found
    document.body.appendChild(btn);
  }  

  btn.onclick = function() {
    const current = document.documentElement.getAttribute('data-theme') || defaultTheme;
    const newTheme = current === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    btn.innerHTML = newTheme === 'dark' ? '☀️' : '🌙';
  };
});

