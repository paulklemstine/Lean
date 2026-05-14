// Aether — Sidebar & Search
document.addEventListener('DOMContentLoaded', () => {
    const packageList = document.getElementById('package-list');
    const searchInput = document.getElementById('search-input');
    const sidebar = document.getElementById('sidebar');
    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const sidebarOverlay = document.getElementById('sidebar-overlay');
    const mobileToggle = document.getElementById('mobile-toggle');

    function openSidebar() {
        sidebar.classList.add('open');
        if (mobileMenuBtn) mobileMenuBtn.classList.add('active');
        if (sidebarOverlay) sidebarOverlay.classList.add('visible');
        document.body.style.overflow = 'hidden';
    }

    window.closeSidebar = function() {
        sidebar.classList.remove('open');
        if (mobileMenuBtn) mobileMenuBtn.classList.remove('active');
        if (sidebarOverlay) sidebarOverlay.classList.remove('visible');
        document.body.style.overflow = '';
    };

    if (mobileToggle) {
        mobileToggle.addEventListener('click', window.closeSidebar);
    }
    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', () => {
            if (sidebar.classList.contains('open')) {
                window.closeSidebar();
            } else {
                openSidebar();
            }
        });
    }
    if (sidebarOverlay) {
        sidebarOverlay.addEventListener('click', window.closeSidebar);
    }

    // Handle clicks on main content to close sidebar on mobile
    document.getElementById('main-content').addEventListener('click', () => {
        if (window.innerWidth <= 768 && sidebar.classList.contains('open')) {
            window.closeSidebar();
        }
    });

    // Search filter
    searchInput.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        const filtered = window.Aether.packages.filter(p =>
            p.title?.toLowerCase().includes(term) ||
            p.domain?.toLowerCase().includes(term)
        );
        window.renderSidebar(filtered);
    });

    window.renderSidebar = function(pkgArray) {
        packageList.innerHTML = '';
        if (pkgArray.length === 0) {
            packageList.innerHTML = '<li class="nav-item"><div class="nav-item-title" style="color:var(--text-muted)">No packages found.</div></li>';
            return;
        }

        pkgArray.forEach(pkg => {
            const li = document.createElement('li');
            li.className = 'nav-item';
            li.dataset.slug = pkg.filename.replace('.json', '');

            const d = new Date(pkg.date);
            const dateStr = !isNaN(d) ? d.toLocaleDateString() : 'Recent';
            const timeStr = !isNaN(d) ? d.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}) : '';

            li.innerHTML = `
                <div class="nav-item-title">${pkg.title || 'Untitled Research'}</div>
                <div class="nav-item-meta">
                    <span>${pkg.domain || 'General'}</span>
                    <span class="nav-item-datetime">${dateStr}${timeStr ? `<br><span class="nav-item-time">${timeStr}</span>` : ''}</span>
                </div>
            `;

            li.addEventListener('click', () => {
                document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
                li.classList.add('active');
                window.loadPackage(pkg.filename);
                if (window.innerWidth <= 768) window.closeSidebar();
            });

            // Sidebar hover -> highlight graph node
            li.addEventListener('mouseenter', () => {
                document.querySelectorAll('.nav-item.graph-highlight').forEach(el => el.classList.remove('graph-highlight'));
                const node = (window._graphNodes || []).find(n => n.id === li.dataset.slug);
                if (window._setHoveredNode) window._setHoveredNode(node || null);
            });
            li.addEventListener('mouseleave', () => {
                const current = window._getHoveredNode ? window._getHoveredNode() : null;
                if (current && current.id === li.dataset.slug && window._setHoveredNode) {
                    window._setHoveredNode(null);
                }
            });

            packageList.appendChild(li);
        });
    };
});