// Aether — Future Directions View

// Reusable direction card renderer — used by both the global directions view
// and the per-package Future Directions tab.
window.renderDirectionCards = function(container, directions, detailIdPrefix) {
    if (typeof detailIdPrefix === 'undefined') detailIdPrefix = 'details-';

    function escapeHTML(str) {
        if (!str) return '';
        return String(str).replace(/[&<>'"]/g, 
            tag => ({
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                "'": '&#39;',
                '"': '&quot;'
            }[tag] || tag)
        );
    }

    const statusColors = {
        available: '#4caf50',
        in_progress_A: '#1e88e5',
        in_progress_B: '#8e24aa',
        in_progress: '#1e88e5'
    };
    const statusLabels = { available: 'Available', in_progress: 'In Progress' };

    container.innerHTML = directions.map(d => {
        const priorityPct = Math.round(d.priority_score * 100);
        const priorityColor = d.priority_score >= 0.9 ? '#f44336' : d.priority_score >= 0.8 ? '#ff9800' : '#ffc107';
        
        let statusKey = d.status;
        let phaseTag = 'Phase A';
        if (d.status === 'in_progress') {
            const rawPhase = d.phase ? String(d.phase).toUpperCase() : 'A';
            if (rawPhase.includes('B')) {
                statusKey = 'in_progress_B';
                phaseTag = 'Phase B';
            } else {
                statusKey = 'in_progress_A';
                phaseTag = 'Phase A';
            }
        }

        const statusColor = statusColors[statusKey] || statusColors[d.status] || '#9e9e9e';
        let statusLabel = statusLabels[d.status] || d.status;
        if (d.status === 'in_progress') {
            statusLabel = `In Progress (${phaseTag})`;
        }
        const domainTags = (d.domains || []).map(dm =>
            `<span class="direction-domain-tag">${escapeHTML(dm)}</span>`
        ).join('');
        const shortDesc = d.description.length > 200
            ? d.description.substring(0, 200) + '...' : d.description;

        return `
            <div class="direction-card" data-id="${d.id}" style="border-left: 4px solid ${statusColor}">
                <div class="direction-card-header">
                    <h3 class="direction-card-title">${escapeHTML(d.title)}</h3>
                    <div class="direction-card-badges">
                        <span class="direction-priority-badge" style="background:${priorityColor}">${priorityPct}%</span>
                        <span class="direction-status-badge" style="background:${statusColor}">${statusLabel}</span>
                    </div>
                </div>
                <div class="direction-card-domains">${domainTags}</div>
                <p class="direction-card-desc">${escapeHTML(shortDesc)}</p>
                <div class="direction-card-details hidden" id="${detailIdPrefix}${d.id}">
                    <p class="direction-card-full-desc">${escapeHTML(d.description)}</p>
                    ${d.status === 'in_progress' ? `<div class="direction-detail-row"><strong>Phase:</strong> ${escapeHTML(d.phase ? (String(d.phase).startsWith('Phase') ? d.phase : 'Phase ' + d.phase) : 'Phase A')}</div>` : ''}
                    ${d.research_mode ? `<div class="direction-detail-row"><strong>Mode:</strong> ${escapeHTML(d.research_mode)}</div>` : ''}
                    ${d.consumed_by_exp_id ? `<div class="direction-detail-row"><strong>Active Experiment:</strong> ${escapeHTML(d.consumed_by_exp_id)}</div>` : ''}
                    <div class="direction-detail-row"><strong>Source:</strong> ${escapeHTML(d.source_exp_id)}</div>
                </div>
                <button class="direction-card-expand" data-id="${d.id}">Show Details</button>
            </div>
        `;
    }).join('');

    container.querySelectorAll('.direction-card-expand').forEach(btn => {
        btn.addEventListener('click', () => {
            const id = btn.dataset.id;
            const card = btn.closest('.direction-card');
            const details = container.querySelector('#' + detailIdPrefix + id);
            const desc = card ? card.querySelector('.direction-card-desc') : null;
            if (details.classList.contains('hidden')) {
                details.classList.remove('hidden');
                if (desc) desc.classList.add('hidden');
                btn.textContent = 'Hide Details';
            } else {
                details.classList.add('hidden');
                if (desc) desc.classList.remove('hidden');
                btn.textContent = 'Show Details';
            }
        });
    });
};

document.addEventListener('DOMContentLoaded', () => {
    const directionsView = document.getElementById('directions-view');
    const directionsGrid = document.getElementById('directions-grid');
    const directionsLink = document.getElementById('nav-directions-link');
    const directionsStatusFilter = document.getElementById('directions-status-filter');
    const directionsDomainFilter = document.getElementById('directions-domain-filter');
    const directionsSearch = document.getElementById('directions-search');
    const welcomeScreen = document.getElementById('welcome-screen');
    const packageView = document.getElementById('package-view');

    window.showDirectionsView = function() {
        if (window.pauseGraphAnimation) window.pauseGraphAnimation();
        window.Aether.directionsVisible = true;
        welcomeScreen.classList.add('hidden');
        packageView.classList.add('hidden');
        directionsView.classList.remove('hidden');
        document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
        directionsLink.classList.add('active');
        // Lazy-load future directions if not yet loaded
        if (!window.FUTURE_DIRECTIONS && window.loadFutureDirections) {
            window.loadFutureDirections(() => window.renderDirectionsView());
        } else {
            window.renderDirectionsView();
        }
        if (window.innerWidth <= 768 && window.closeSidebar) window.closeSidebar();
    };

    window.hideDirectionsView = function() {
        window.Aether.directionsVisible = false;
        directionsView.classList.add('hidden');
        directionsLink.classList.remove('active');
        if (window.resumeGraphAnimation && (!welcomeScreen || !welcomeScreen.classList.contains('hidden'))) {
            window.resumeGraphAnimation();
        }
    };

    window.populateDomainFilter = function() {
        if (!window.FUTURE_DIRECTIONS) return;
        const domains = new Set();
        window.FUTURE_DIRECTIONS.forEach(d => (d.domains || []).forEach(dm => domains.add(dm)));
        directionsDomainFilter.innerHTML = '<option value="">All Domains</option>';
        Array.from(domains).sort().forEach(dm => {
            const opt = document.createElement('option');
            opt.value = dm;
            opt.textContent = dm;
            directionsDomainFilter.appendChild(opt);
        });
    };

    function getFilteredDirections() {
        if (!window.FUTURE_DIRECTIONS) return [];
        const statusFilter = directionsStatusFilter.value;
        const domainFilter = directionsDomainFilter.value;
        const searchTerm = directionsSearch.value.toLowerCase();
        return window.FUTURE_DIRECTIONS.filter(d => {
            if (statusFilter && d.status !== statusFilter) return false;
            if (domainFilter && !(d.domains || []).includes(domainFilter)) return false;
            if (searchTerm) {
                const text = (d.title + ' ' + d.description).toLowerCase();
                if (!text.includes(searchTerm)) return false;
            }
            return true;
        });
    }

    window.renderDirectionsView = function() {
        if (!directionsGrid) return;
        const directions = getFilteredDirections();
        if (directions.length === 0) {
            directionsGrid.innerHTML = '<div class="directions-empty">No research directions match your filters.</div>';
            return;
        }
        window.renderDirectionCards(directionsGrid, directions, 'details-');
    };

    // Nav link click handler
    directionsLink.addEventListener('click', (e) => {
        e.preventDefault();
        window.showDirectionsView();
    });

    // Welcome screen directions link
    const welcomeDirectionsLink = document.getElementById('welcome-directions-link');
    if (welcomeDirectionsLink) {
        welcomeDirectionsLink.addEventListener('click', (e) => {
            e.preventDefault();
            window.showDirectionsView();
        });
    }

    // Filter change handlers
    directionsStatusFilter.addEventListener('change', window.renderDirectionsView);
    directionsDomainFilter.addEventListener('change', window.renderDirectionsView);
    directionsSearch.addEventListener('input', window.renderDirectionsView);

    // Initial population
    if (window.PACKAGE_INDEX) {
        window.populateDomainFilter();
    }
});