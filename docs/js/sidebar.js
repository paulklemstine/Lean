// Aether — Sidebar & Search
document.addEventListener('DOMContentLoaded', () => {
    const packageList = document.getElementById('package-list');
    const searchInput = document.getElementById('search-input');
    const sidebar = document.getElementById('sidebar');
    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const sidebarOverlay = document.getElementById('sidebar-overlay');
    const mobileToggle = document.getElementById('mobile-toggle');
    const topSentinel = document.getElementById('package-list-status-top');
    const bottomSentinel = document.getElementById('package-list-status');
    const markerEl = document.getElementById('package-list-marker');
    const pagePrev = document.getElementById('page-prev');
    const pageNext = document.getElementById('page-next');

    const BATCH_SIZE = 20;        // items loaded per lazy-load batch (each direction)
    const SKIP_SIZE = 25;         // packages skipped per Prev/Next
    let filteredPackages = [];    // full (sorted newest-first) dataset
    let startIndex = 0;           // first index currently in the DOM
    let endIndex = 0;             // one past the last index currently in the DOM
    let firstVisibleIndex = 0;    // index of the first visible package (marker position)
    let topObserverArmed = true;  // top sentinel may lazy-load (paused right after a Jump)
    let lastScrollTop = 0;        // last scrollTop seen, to detect scroll-up for re-arming

    const supportsIO = 'IntersectionObserver' in window;
    const scrollContainer = packageList ? packageList.closest('.package-list-container') : null;

    function scrollSidebarToTop() {
        if (scrollContainer) {
            scrollContainer.scrollTo({ top: 0, behavior: 'smooth' });
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
    const mainContent = document.getElementById('main-content');
    if (mainContent) {
        mainContent.addEventListener('click', () => {
            if (window.innerWidth <= 768 && sidebar && sidebar.classList.contains('open')) {
                window.closeSidebar();
            }
        });
    }

    // Build a single package <li>. index is the absolute position within filteredPackages.
    function buildNavItem(pkg, index) {
        const li = document.createElement('li');
        li.className = 'nav-item';
        li.dataset.slug = pkg.filename.replace('.json', '');
        li.dataset.idx = index;

        const d = new Date(pkg.date);
        const dateStr = !isNaN(d) ? d.toLocaleDateString() : 'Recent';
        const timeStr = !isNaN(d) ? d.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}) : '';

        const qs = pkg.quality_score;
        const quality = pkg.quality || 'unrated';
        const tier = pkg.quality_tier || 'unrated';
        const scorePct = qs != null ? Math.round(qs * 100) : null;
        const tierEmojis = { gold: '\u{1F947}', silver: '\u{1F948}', bronze: '\u{1F949}', unrated: '' };
        const tierEmoji = tierEmojis[tier] || '';
        const standout = qs != null && qs >= 0.90;
        if (standout) li.classList.add('standout');

        // Score color based on tier
        let scoreColor = '#6b7280'; // unrated gray
        if (qs != null) {
            if (qs >= 0.90) scoreColor = '#fbbf24';      // gold - standout
            else if (qs >= 0.80) scoreColor = '#8b5cf6';  // violet - strong
            else if (qs >= 0.70) scoreColor = '#06b6d4';  // cyan - good
            else if (qs >= 0.60) scoreColor = '#dc2626';  // red - moderate
            else scoreColor = '#991b1b';                   // dark red - low
        }

        const slug = pkg.filename.replace(/\.json$/i, '');
        const pkgNum = pkg.pkg_num || '';
        li.innerHTML = `
            <a class="nav-item-link" href="/${encodeURIComponent(slug)}" data-filename="${pkg.filename}">
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
            e.preventDefault();
            document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
            li.classList.add('active');
            if (window.loadPackage) window.loadPackage(pkg.filename);
            window.scrollTo({ top: 0, behavior: 'smooth' });
            if (window.innerWidth <= 768 && window.closeSidebar) {
                window.closeSidebar();
            }
        });

        // Sidebar hover -> highlight graph node
        li.addEventListener('mouseenter', () => {
            document.querySelectorAll('.nav-item.graph-highlight').forEach(el => el.classList.remove('graph-highlight'));
            const node = (window._graphNodes || []).find(n => n.id === li.dataset.slug);
            if (window._setHoveredNode) window._setHoveredNode(node || null);
            if (window._fadeWelcome) window._fadeWelcome();
        });
        li.addEventListener('mouseleave', () => {
            const current = window._getHoveredNode ? window._getHoveredNode() : null;
            if (current && current.id === li.dataset.slug && window._setHoveredNode) {
                window._setHoveredNode(null);
            }
        });

        return li;
    }

    // Show/hide the sentinels. Each is hidden once there is nothing left to load
    // in its direction; the bottom one shows an end marker when the whole list
    // (both directions) has been loaded.
    function updateSentinels() {
        const total = filteredPackages.length;
        if (!topSentinel || !bottomSentinel) return;
        if (total === 0) {
            topSentinel.style.display = 'none';
            bottomSentinel.textContent = '';
            bottomSentinel.style.display = 'none';
            return;
        }
        if (startIndex <= 0) {
            topSentinel.style.display = 'none';
        } else {
            topSentinel.style.display = '';
            if (observer && topObserverArmed) observer.observe(topSentinel);
        }
        if (endIndex >= total) {
            bottomSentinel.textContent = (startIndex <= 0 && total > BATCH_SIZE) ? '— end of list —' : '';
            bottomSentinel.style.display = (startIndex <= 0 && total > BATCH_SIZE) ? '' : 'none';
        } else {
            bottomSentinel.textContent = '';
            bottomSentinel.style.display = '';
            if (observer) observer.observe(bottomSentinel);
        }
    }

    // Enable/disable the Prev / Next buttons for the current position. Next
    // also disables when the container is at its maximum scroll — the list
    // physically cannot scroll further, even if the first-visible index is
    // still below total-1 (the last item can't be pushed to the top).
    function updateControls() {
        if (!pagePrev || !pageNext) return;
        const total = filteredPackages.length;
        const atBottom = !!(scrollContainer &&
            scrollContainer.scrollHeight - scrollContainer.scrollTop - scrollContainer.clientHeight <= 1);
        pagePrev.disabled = total === 0 || firstVisibleIndex <= 0;
        pageNext.disabled = total === 0 || firstVisibleIndex >= total - 1 || atBottom;
    }

    // Marker: "position / total" — the first visible package.
    function renderMarker() {
        if (!markerEl) return;
        const total = filteredPackages.length;
        markerEl.textContent = total ? `${firstVisibleIndex + 1} / ${total}` : '';
        updateControls();
    }

    // Index of the first package currently visible in the list (0-based).
    function computeFirstVisible() {
        if (!packageList || !scrollContainer) return null;
        const items = packageList.querySelectorAll('.nav-item');
        if (!items.length) return null;
        const containerTop = scrollContainer.getBoundingClientRect().top;
        for (const it of items) {
            if (it.getBoundingClientRect().bottom >= containerTop) {
                return Number(it.dataset.idx);
            }
        }
        return null;
    }

    // Sync the position marker to the first visible package (render, lazy-load, scroll).
    function updateMarker() {
        if (!markerEl) return;
        const total = filteredPackages.length;
        if (!total) { renderMarker(); return; }
        const fv = computeFirstVisible();
        if (fv != null) firstVisibleIndex = fv;
        renderMarker();
    }

    // Rebuild the whole visible window (initial render, search, refresh, highlight).
    function renderWindow() {
        packageList.innerHTML = '';
        const total = filteredPackages.length;
        if (total === 0) {
            packageList.innerHTML = '<li class="nav-item"><div class="nav-item-title" style="color:var(--text-muted)">No packages found.</div></li>';
            updateSentinels();
            updateMarker();
            return;
        }
        const frag = document.createDocumentFragment();
        for (let i = startIndex; i < endIndex; i++) {
            frag.appendChild(buildNavItem(filteredPackages[i], i));
        }
        packageList.appendChild(frag);
        updateSentinels();
        updateMarker();
    }

    // Append a batch at the bottom (downward scroll).
    function loadMoreBelow() {
        const total = filteredPackages.length;
        if (endIndex >= total) { updateSentinels(); return; }
        const newEnd = Math.min(endIndex + BATCH_SIZE, total);
        const frag = document.createDocumentFragment();
        for (let i = endIndex; i < newEnd; i++) {
            frag.appendChild(buildNavItem(filteredPackages[i], i));
        }
        packageList.appendChild(frag);
        endIndex = newEnd;
        updateSentinels();
        updateMarker();
    }

    // Prepend a batch at the top (upward scroll), pinning the previously visible
    // item so the viewport does not jump when content is inserted above it.
    function loadMoreAbove() {
        if (startIndex <= 0 || !scrollContainer) { updateSentinels(); return; }
        const items = packageList.querySelectorAll('.nav-item');
        const containerTop = scrollContainer.getBoundingClientRect().top;
        let anchorSlug = null;
        let anchorRectTop = null;
        for (const it of items) {
            const r = it.getBoundingClientRect();
            if (r.bottom >= containerTop) { anchorSlug = it.dataset.slug; anchorRectTop = r.top; break; }
        }
        const newStart = Math.max(0, startIndex - BATCH_SIZE);
        const frag = document.createDocumentFragment();
        for (let i = newStart; i < startIndex; i++) {
            frag.appendChild(buildNavItem(filteredPackages[i], i));
        }
        packageList.insertBefore(frag, packageList.firstChild);
        startIndex = newStart;
        if (anchorSlug) {
            const el = packageList.querySelector(`[data-slug="${anchorSlug}"]`);
            if (el) {
                scrollContainer.scrollTop += el.getBoundingClientRect().top - anchorRectTop;
            }
        }
        updateSentinels();
        updateMarker();
    }

    // Lazy-loading via IntersectionObserver on the sentinels; falls back to
    // rendering everything at once in browsers without support.
    let observer = null;
    if (supportsIO && scrollContainer && topSentinel && bottomSentinel) {
        observer = new IntersectionObserver((entries) => {
            for (const entry of entries) {
                if (!entry.isIntersecting) continue;
                if (entry.target === bottomSentinel) loadMoreBelow();
                else if (entry.target === topSentinel) loadMoreAbove();
            }
        }, { root: scrollContainer, rootMargin: '200px 0px' });
        observer.observe(bottomSentinel);
        observer.observe(topSentinel);
    }

    function initWindow() {
        startIndex = 0;
        endIndex = supportsIO ? Math.min(BATCH_SIZE, filteredPackages.length) : filteredPackages.length;
    }

    // Throttled scroll listener keeps the position marker in sync with the viewport.
    let markerRaf = 0;
    if (scrollContainer) {
        scrollContainer.addEventListener('scroll', () => {
            const st = scrollContainer.scrollTop;
            // Re-enable top-side lazy loading once the user genuinely scrolls up.
            if (!topObserverArmed && observer && topSentinel && st < lastScrollTop) {
                observer.observe(topSentinel);
                topObserverArmed = true;
            }
            lastScrollTop = st;
            if (markerRaf) return;
            markerRaf = requestAnimationFrame(() => {
                markerRaf = 0;
                updateMarker();
            });
        }, { passive: true });
    }

    // Make sure the package at `idx` exists in the DOM, extending the loaded
    // window in the needed direction via the normal lazy-load helpers.
    function ensureRendered(idx) {
        if (idx < startIndex) {
            while (startIndex > idx) loadMoreAbove();
        } else if (idx >= endIndex) {
            while (endIndex <= idx) loadMoreBelow();
        }
    }

    // Prev / Next: scroll the list so the package SKIP_SIZE away from the
    // current first-visible package becomes the new first-visible item. Like a
    // Jump, top-side lazy loading is paused until the user scrolls up, so the
    // target stays pinned at the top after landing.
    function pageBy(delta) {
        const total = filteredPackages.length;
        if (!total || !scrollContainer) return;
        const fv = computeFirstVisible();
        const cur = fv != null ? fv : startIndex;
        const target = Math.max(0, Math.min(total - 1, cur + delta));
        if (target === cur) { updateControls(); return; }
        if (observer && topSentinel) observer.unobserve(topSentinel);
        topObserverArmed = false;
        ensureRendered(target);
        const item = packageList.querySelector(`.nav-item[data-idx="${target}"]`);
        if (item) {
            const itemTop = item.getBoundingClientRect().top;
            const contTop = scrollContainer.getBoundingClientRect().top;
            // Instant positioning — a smooth animation races with the
            // lazy-load sentinels and can land the view unpredictably.
            scrollContainer.scrollTop += itemTop - contTop;
        }
        lastScrollTop = scrollContainer ? scrollContainer.scrollTop : 0;
        updateMarker();
    }

    if (pagePrev) {
        pagePrev.addEventListener('click', () => pageBy(-SKIP_SIZE));
    }
    if (pageNext) {
        pageNext.addEventListener('click', () => pageBy(SKIP_SIZE));
    }

    window.renderSidebar = function(pkgArray) {
        // Fixed ordering: newest first
        filteredPackages = [...pkgArray].sort((a, b) => (b.date || '').localeCompare(a.date || ''));

        if (startIndex === 0 && endIndex === 0) {
            // First render (or search reset) — start from the top batch.
            initWindow();
            topObserverArmed = true;
        } else {
            // Data refresh (60s polling): keep the current window, clamped to the new length.
            if (endIndex > filteredPackages.length) endIndex = filteredPackages.length;
            if (startIndex >= filteredPackages.length) startIndex = Math.max(0, filteredPackages.length - BATCH_SIZE);
        }
        renderWindow();
    };

    // Search filter
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            const term = e.target.value.toLowerCase();
            const base = window.Aether.packages || [];
            const filtered = term
                ? base.filter(p =>
                    p.title?.toLowerCase().includes(term) ||
                    p.domain?.toLowerCase().includes(term)
                  )
                : base;
            startIndex = 0;
            endIndex = 0;   // reset to first batch
            window.renderSidebar(filtered);
            scrollSidebarToTop();
        });
    }

    // Navigate to the item for a slug: center the loaded window on it, then highlight.
    // Only a bounded set is rendered, so deep targets stay lazy on both sides.
    window.highlightSidebarItem = function(slug) {
        if (!slug || !filteredPackages.length) return;
        // filteredPackages is already sorted newest-first (set by renderSidebar)
        const idx = filteredPackages.findIndex(p => p.filename.replace('.json', '') === slug);
        if (idx === -1) return;
        let s = Math.max(0, idx - Math.floor(BATCH_SIZE / 2));
        const e = Math.min(filteredPackages.length, Math.max(s + BATCH_SIZE, idx + 1));
        s = Math.max(0, Math.min(s, e - 1));
        startIndex = s;
        endIndex = e;
        renderWindow();
        // Now the item should be in the DOM — highlight and scroll
        const item = packageList.querySelector(`.nav-item[data-slug="${slug}"]`);
        if (item) {
            item.classList.add('graph-highlight');
            if (scrollContainer) {
                const itemRect = item.getBoundingClientRect();
                const listRect = scrollContainer.getBoundingClientRect();
                if (itemRect.top < listRect.top || itemRect.bottom > listRect.bottom) {
                    scrollContainer.scrollTo({
                        top: scrollContainer.scrollTop + itemRect.top - listRect.top - listRect.height / 3,
                        behavior: 'smooth'
                    });
                }
            }
            updateMarker();
        }
    };
});
