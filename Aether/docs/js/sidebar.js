// Aether — Sidebar & Search
document.addEventListener('DOMContentLoaded', () => {
    const packageList = document.getElementById('package-list');
    const searchInput = document.getElementById('search-input');
    const sidebar = document.getElementById('sidebar');
    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const sidebarOverlay = document.getElementById('sidebar-overlay');
    const mobileToggle = document.getElementById('mobile-toggle');
    const sortMode = document.getElementById('sort-mode');
    const pageHome = document.getElementById('page-home');
    const pagePrev = document.getElementById('page-prev');
    const pageNext = document.getElementById('page-next');
    const pageIndicator = document.getElementById('page-indicator');

    const PAGE_SIZE = 10;
    let currentPage = 1;
    let currentSort = 'date-desc';
    let filteredPackages = [];

    function scrollSidebarToTop() {
        const listContainer = packageList.closest('.package-list-container');
        if (listContainer) {
            listContainer.scrollTo({ top: 0, behavior: 'smooth' });
        }
    }

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

    function sortPackages(pkgs, mode) {
        const sorted = [...pkgs];
        switch (mode) {
            case 'date-desc':
                sorted.sort((a, b) => (b.date || '').localeCompare(a.date || ''));
                break;
            case 'date-asc':
                sorted.sort((a, b) => (a.date || '').localeCompare(b.date || ''));
                break;
            case 'alpha':
                sorted.sort((a, b) => (a.title || '').localeCompare(b.title || ''));
                break;
            case 'score-desc':
                sorted.sort((a, b) => (b.quality_score ?? -1) - (a.quality_score ?? -1));
                break;
            case 'score-asc':
                sorted.sort((a, b) => (a.quality_score ?? 999) - (b.quality_score ?? 999));
                break;
        }
        return sorted;
    }

    function updatePagination() {
        const totalPages = Math.max(1, Math.ceil(filteredPackages.length / PAGE_SIZE));
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        pageIndicator.textContent = `${currentPage} / ${totalPages}`;
        pagePrev.disabled = currentPage <= 1;
        pageNext.disabled = currentPage >= totalPages;
    }

    // Search filter
    searchInput.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        const base = window.Aether.packages || [];
        const filtered = term
            ? base.filter(p =>
                p.title?.toLowerCase().includes(term) ||
                p.domain?.toLowerCase().includes(term)
              )
            : base;
        currentPage = 1;
        window.renderSidebar(filtered);
    });

    // Sort mode change
    if (sortMode) {
        sortMode.addEventListener('change', (e) => {
            currentSort = e.target.value;
            currentPage = 1;
            window.renderSidebar(filteredPackages);
        });
    }

    // Pagination
    if (pageHome) {
        pageHome.addEventListener('click', () => {
            if (currentPage !== 1) {
                currentPage = 1;
                window.renderSidebar(filteredPackages);
                scrollSidebarToTop();
            }
        });
    }
    if (pagePrev) {
        pagePrev.addEventListener('click', () => {
            if (currentPage > 1) {
                currentPage--;
                window.renderSidebar(filteredPackages);
                scrollSidebarToTop();
            }
        });
    }
    if (pageNext) {
        pageNext.addEventListener('click', () => {
            const totalPages = Math.ceil(filteredPackages.length / PAGE_SIZE);
            if (currentPage < totalPages) {
                currentPage++;
                window.renderSidebar(filteredPackages);
                scrollSidebarToTop();
            }
        });
    }

    window.renderSidebar = function(pkgArray) {
        filteredPackages = pkgArray;
        packageList.innerHTML = '';

        if (pkgArray.length === 0) {
            packageList.innerHTML = '<li class="nav-item"><div class="nav-item-title" style="color:var(--text-muted)">No packages found.</div></li>';
            updatePagination();
            return;
        }

        const sorted = sortPackages(pkgArray, currentSort);
        const totalPages = Math.ceil(sorted.length / PAGE_SIZE);
        if (currentPage > totalPages) currentPage = totalPages;
        const start = (currentPage - 1) * PAGE_SIZE;
        const pageItems = sorted.slice(start, start + PAGE_SIZE);

        pageItems.forEach(pkg => {
            const li = document.createElement('li');
            li.className = 'nav-item';
            li.dataset.slug = pkg.filename.replace('.json', '');

            const d = new Date(pkg.date);
            const dateStr = !isNaN(d) ? d.toLocaleDateString() : 'Recent';
            const timeStr = !isNaN(d) ? d.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}) : '';

            const qs = pkg.quality_score;
            const quality = pkg.quality || 'unrated';
            const tier = pkg.quality_tier || 'unrated';
            const scorePct = qs != null ? Math.round(qs * 100) : null;
            const tierEmojis = { gold: '\u{1F947}', silver: '\u{1F948}', bronze: '\u{1F948}', unrated: '' };
            const tierEmoji = tierEmojis[tier] || '';
            const standout = qs != null && qs >= 0.75;
            if (standout) li.classList.add('standout');

            // Score color based on tier
            let scoreColor = '#6b7280'; // unrated gray
            if (qs != null) {
                if (qs >= 0.75) scoreColor = '#fbbf24';      // gold - standout
                else if (qs >= 0.65) scoreColor = '#8b5cf6';  // violet - strong
                else if (qs >= 0.55) scoreColor = '#06b6d4';  // cyan - good
                else if (qs >= 0.45) scoreColor = '#dc2626';  // red - moderate
                else scoreColor = '#991b1b';                   // dark red - low
            }

            const pkgNum = pkg.pkg_num || '';
            li.innerHTML = `
                <a class="nav-item-link" href="#pkg=${encodeURIComponent(pkg.filename)}" data-filename="${pkg.filename}">
                    <div class="nav-item-title">${pkgNum ? pkgNum + '. ' : ''}${pkg.title || 'Untitled Research'}</div>
                    ${qs != null ? `<div class="nav-item-score" data-quality="${quality}">
                        <div class="score-bar"><div class="score-bar-fill" style="width:${scorePct}%;background:${scoreColor}"></div></div>
                        <span class="score-label" style="color:${scoreColor}">${scorePct}%${tierEmoji ? ' ' + tierEmoji : ''}</span>
                    </div>` : ''}
                    <div class="nav-item-meta">
                        <span>${pkg.domain || 'General'}</span>
                        <span class="nav-item-datetime">${dateStr}${timeStr ? `<br><span class="nav-item-time">${timeStr}</span>` : ''}</span>
                    </div>
                </a>
            `;

            li.addEventListener('click', (e) => {
                document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
                li.classList.add('active');
                // The <a> inside the <li> has href="#pkg=...", so the browser
                // will update the hash automatically. The hashchange listener
                // in packages.js will call loadPackage. We still need to call
                // it directly to handle the case where the hash doesn't change
                // (clicking the same package twice, or after replaceState).
                if (window.loadPackage) window.loadPackage(pkg.filename);
                window.scrollTo({ top: 0, behavior: 'smooth' });
                if (window.innerWidth <= 768) window.closeSidebar();
            });

            // Sidebar hover -> highlight graph node
            li.addEventListener('mouseenter', () => {
                document.querySelectorAll('.nav-item.graph-highlight').forEach(el => el.classList.remove('graph-highlight'));
                const node = (window._graphNodes || []).find(n => n.id === li.dataset.slug);
                if (window._setHoveredNode) window._setHoveredNode(node || null);
                if (window._zoomToNodeCircle) window._zoomToNodeCircle(li.dataset.slug);
                if (window._fadeWelcome) window._fadeWelcome();
            });
            li.addEventListener('mouseleave', () => {
                const current = window._getHoveredNode ? window._getHoveredNode() : null;
                if (current && current.id === li.dataset.slug && window._setHoveredNode) {
                    window._setHoveredNode(null);
                }
                if (window._stopTrackingCircle) window._stopTrackingCircle();
            });

            packageList.appendChild(li);
        });

        updatePagination();
    };

    // Navigate to the page containing a slug and highlight it
    window.highlightSidebarItem = function(slug) {
        if (!slug || !filteredPackages.length) return;
        const sorted = sortPackages(filteredPackages, currentSort);
        const idx = sorted.findIndex(p => p.filename.replace('.json', '') === slug);
        if (idx === -1) return;
        // Navigate to the page containing this item
        const targetPage = Math.floor(idx / PAGE_SIZE) + 1;
        if (targetPage !== currentPage) {
            currentPage = targetPage;
            window.renderSidebar(filteredPackages);
        }
        // Now the item should be in the DOM — highlight and scroll
        const item = document.querySelector(`.nav-item[data-slug="${slug}"]`);
        if (item) {
            item.classList.add('graph-highlight');
            const listContainer = item.closest('.package-list-container');
            if (listContainer) {
                const itemRect = item.getBoundingClientRect();
                const listRect = listContainer.getBoundingClientRect();
                if (itemRect.top < listRect.top || itemRect.bottom > listRect.bottom) {
                    listContainer.scrollTo({
                        top: listContainer.scrollTop + itemRect.top - listRect.top - listRect.height / 3,
                        behavior: 'smooth'
                    });
                }
            }
        }
    };
});
