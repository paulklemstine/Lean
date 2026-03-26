/* ═══════════════════════════════════════════════════════════════
   PYTHAGOREAN COSMOS — Core JavaScript
   Navigation, search, filtering, animations, data
   ═══════════════════════════════════════════════════════════════ */

// ── Navigation ──
document.addEventListener('DOMContentLoaded', () => {
  // Scroll behavior for nav
  const nav = document.querySelector('.nav');
  if (nav) {
    window.addEventListener('scroll', () => {
      nav.classList.toggle('scrolled', window.scrollY > 50);
    });
  }

  // Mobile nav toggle
  const toggle = document.querySelector('.nav-mobile-toggle');
  const links = document.querySelector('.nav-links');
  if (toggle && links) {
    toggle.addEventListener('click', () => {
      links.classList.toggle('open');
      toggle.textContent = links.classList.contains('open') ? '✕' : '☰';
    });
  }

  // Active nav link
  const currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-links a').forEach(a => {
    const href = a.getAttribute('href');
    if (href && (href.endsWith(currentPage) || (currentPage === 'index.html' && href === './' ))) {
      a.classList.add('active');
    }
  });

  // Scroll animations
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

  document.querySelectorAll('.animate-in').forEach(el => observer.observe(el));

  // Animated counters
  document.querySelectorAll('[data-count]').forEach(el => {
    const target = parseInt(el.dataset.count);
    const duration = 2000;
    const start = performance.now();

    const counterObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animateCounter(el, target, duration);
          counterObserver.unobserve(el);
        }
      });
    }, { threshold: 0.5 });

    counterObserver.observe(el);
  });
});

function animateCounter(el, target, duration) {
  const start = performance.now();
  const format = el.dataset.format;

  function update(now) {
    const elapsed = now - start;
    const progress = Math.min(elapsed / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 4);
    const current = Math.floor(eased * target);

    if (format === 'comma') {
      el.textContent = current.toLocaleString();
    } else {
      el.textContent = current;
    }

    if (progress < 1) {
      requestAnimationFrame(update);
    } else {
      if (format === 'comma') {
        el.textContent = target.toLocaleString();
      } else {
        el.textContent = target;
      }
      if (el.dataset.suffix) {
        el.textContent += el.dataset.suffix;
      }
    }
  }

  requestAnimationFrame(update);
}

// ── Shared Navigation HTML ──
function getNavHTML(activePage) {
  const pages = [
    { href: './index.html', label: 'Home', id: 'index.html' },
    { href: './pages/theorems.html', label: 'Theorems', id: 'theorems.html' },
    { href: './pages/library.html', label: 'Library', id: 'library.html' },
    { href: './pages/deep-dives/berggren-tree.html', label: 'Deep Dives', id: 'deep-dives' },
    { href: './pages/codebase.html', label: 'Codebase', id: 'codebase.html' },
    { href: './pages/about.html', label: 'About', id: 'about.html' },
  ];

  // Fix relative paths based on page depth
  const depth = activePage.includes('deep-dives') ? 2 : (activePage === 'index.html' ? 0 : 1);

  return pages.map(p => {
    let href = p.href;
    if (depth === 1) href = href.replace('./', '../');
    if (depth === 2) href = href.replace('./', '../../');
    const isActive = activePage === p.id || (p.id === 'deep-dives' && activePage.includes('deep-dives'));
    return `<li><a href="${href}" class="${isActive ? 'active' : ''}">${p.label}</a></li>`;
  }).join('');
}

// ── Papers Data ──
const PAPER_CATEGORIES = {
  'Research Paper': { color: 'indigo', icon: '📄' },
  'Scientific American': { color: 'cyan', icon: '🔬' },
  'Lab Notebook': { color: 'emerald', icon: '🔬' },
  'Vision & Foundations': { color: 'violet', icon: '🎯' },
  'Catalog & Report': { color: 'amber', icon: '📊' },
  'Code & Experiments': { color: 'rose', icon: '💻' },
  'Team Notes': { color: 'blue', icon: '👥' },
  'Other': { color: 'emerald', icon: '📎' }
};

function categorizePaper(filename) {
  const lower = filename.toLowerCase();
  if (lower.includes('sciam') || lower.includes('scientific_american') || lower.includes('scientificamerican'))
    return 'Scientific American';
  if (lower.includes('lab_notebook') || lower.includes('labnotebook'))
    return 'Lab Notebook';
  if (lower.includes('team') || lower.includes('teamnotes') || lower.includes('teamresearch'))
    return 'Team Notes';
  if (lower.includes('catalog') || lower.includes('report') || lower.includes('cleanup') || lower.includes('directions'))
    return 'Catalog & Report';
  if (lower.endsWith('.py') || lower.endsWith('.py.txt') || lower.includes('experiment'))
    return 'Code & Experiments';
  if (lower.startsWith('0') || lower.includes('vision') || lower.includes('overview'))
    return 'Vision & Foundations';
  if (lower.includes('research') || lower.includes('paper') || lower.includes('frontier') ||
      lower.includes('moonshot') || lower.includes('comprehensive'))
    return 'Research Paper';
  if (lower.endsWith('.md')) return 'Research Paper';
  return 'Other';
}

function formatPaperTitle(filename) {
  return filename
    .replace(/\.md$/, '')
    .replace(/\.py\.txt$/, '.py')
    .replace(/\.py$/, ' (Python)')
    .replace(/\.tex$/, ' (LaTeX)')
    .replace(/\.pdf$/, ' (PDF)')
    .replace(/_/g, ' ')
    .replace(/ \(\d+\)/, '')
    .replace(/([a-z])([A-Z])/g, '$1 $2');
}

function formatFileSize(bytes) {
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

// ── Theorem Domain Data ──
const THEOREM_DOMAINS = [
  { id: 'pythagorean', name: 'Pythagorean Triples & Berggren Tree', count: 350, icon: '🌲' },
  { id: 'channels', name: 'Four-Channel Signatures', count: 100, icon: '📡' },
  { id: 'compression', name: 'Compression Theory', count: 120, icon: '🗜️' },
  { id: 'quantum', name: 'Quantum Computing & Gates', count: 500, icon: '⚛️' },
  { id: 'stereographic', name: 'Stereographic & Decoder', count: 300, icon: '🔮' },
  { id: 'flt4', name: 'FLT4 & Congruent Numbers', count: 30, icon: '🔢' },
  { id: 'lorentz', name: 'Lorentz & Light Cone', count: 250, icon: '💡' },
  { id: 'algebra', name: 'Algebraic Structures', count: 120, icon: '🔷' },
  { id: 'sl2', name: 'SL(2,ℤ) & Modular', count: 70, icon: '🌀' },
  { id: 'numbertheory', name: 'Number Theory', count: 250, icon: '🔣' },
  { id: 'combinatorics', name: 'Combinatorics & Graphs', count: 80, icon: '🕸️' },
  { id: 'topology', name: 'Topology & Dynamics', count: 100, icon: '🍩' },
  { id: 'category', name: 'Category & Representation', count: 60, icon: '🏗️' },
  { id: 'mobius', name: 'Möbius & Order Classification', count: 80, icon: '♾️' },
  { id: 'crystallizer', name: 'Crystallizer & Neural Arch', count: 250, icon: '💎' },
  { id: 'applied', name: 'Applied Mathematics', count: 250, icon: '⚙️' },
  { id: 'advanced', name: 'Advanced Topics', count: 348, icon: '🚀' },
];

// ── Simple Markdown Renderer ──
function renderMarkdown(text) {
  if (!text) return '';
  let html = text
    // Headers
    .replace(/^#### (.+)$/gm, '<h4>$1</h4>')
    .replace(/^### (.+)$/gm, '<h3>$1</h3>')
    .replace(/^## (.+)$/gm, '<h2>$1</h2>')
    .replace(/^# (.+)$/gm, '<h1>$1</h1>')
    // Bold & italic
    .replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    // Code blocks
    .replace(/```(\w*)\n([\s\S]*?)```/g, '<div class="code-block"><span class="lang-label">$1</span><pre>$2</pre></div>')
    // Inline code
    .replace(/`([^`]+)`/g, '<code style="background:rgba(129,140,248,0.1);padding:2px 6px;border-radius:4px;font-family:var(--font-mono);font-size:0.85em;color:var(--accent-indigo);">$1</code>')
    // Tables
    .replace(/^\|(.+)\|$/gm, (match, content) => {
      const cells = content.split('|').map(c => c.trim());
      if (cells.every(c => /^[-:]+$/.test(c))) return '<!--separator-->';
      return '<tr>' + cells.map(c => `<td>${c}</td>`).join('') + '</tr>';
    })
    // Links
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank">$1</a>')
    // Horizontal rules
    .replace(/^---$/gm, '<hr style="border:none;border-top:1px solid var(--border-subtle);margin:2rem 0;">')
    // Line breaks
    .replace(/\n\n/g, '</p><p>')
    .replace(/\n/g, '<br>');

  // Wrap in paragraphs
  html = '<p>' + html + '</p>';

  // Handle table wrapping
  html = html.replace(/((?:<tr>.*?<\/tr>\s*)+)/g, '<table class="theorem-table">$1</table>');
  html = html.replace(/<!--separator-->/g, '');

  return html;
}
