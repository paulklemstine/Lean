// Aether — Future Directions View

// Reusable direction card renderer — used by both the global directions view
// and the per-package Future Directions tab.
window.renderDirectionCards = function(container, directions, detailIdPrefix) {
    if (typeof detailIdPrefix === 'undefined') detailIdPrefix = 'details-';

    const statusColors = { available: '#4caf50', in_progress: '#2196f3' };
    const statusLabels = { available: 'Available', in_progress: 'In Progress' };

    container.innerHTML = directions.map(d => {
        const priorityPct = Math.round(d.priority_score * 100);
        const priorityColor = d.priority_score >= 0.9 ? '#f44336' : d.priority_score >= 0.8 ? '#ff9800' : '#ffc107';
        const statusColor = statusColors[d.status] || '#9e9e9e';
        const statusLabel = statusLabels[d.status] || d.status;
        const domainTags = (d.domains || []).map(dm =>
            `<span class="direction-domain-tag">${dm}</span>`
        ).join('');
        const shortDesc = d.description.length > 200
            ? d.description.substring(0, 200) + '...' : d.description;

        return `
            <div class="direction-card" data-id="${d.id}" style="border-left: 4px solid ${statusColor}">
                <div class="direction-card-header">
                    <h3 class="direction-card-title">${d.title}</h3>
                    <div class="direction-card-badges">
                        <span class="direction-priority-badge" style="background:${priorityColor}">${priorityPct}%</span>
                        <span class="direction-status-badge" style="background:${statusColor}">${statusLabel}</span>
                    </div>
                </div>
                <div class="direction-card-domains">${domainTags}</div>
                <p class="direction-card-desc">${shortDesc}</p>
                <div class="direction-card-details hidden" id="${detailIdPrefix}${d.id}">
                    <p class="direction-card-full-desc">${d.description}</p>
                    ${d.research_mode ? `<div class="direction-detail-row"><strong>Mode:</strong> ${d.research_mode}</div>` : ''}
                    ${d.consumed_by_exp_id ? `<div class="direction-detail-row"><strong>Active Experiment:</strong> ${d.consumed_by_exp_id}</div>` : ''}
                    <div class="direction-detail-row"><strong>Source:</strong> ${d.source_exp_id}</div>
                </div>
                <button class="direction-card-expand" data-id="${d.id}">Show Details</button>
            </div>
        `;
    }).join('');

    container.querySelectorAll('.direction-card-expand').forEach(btn => {
        btn.addEventListener('click', () => {
            const id = btn.dataset.id;
            const details = container.querySelector('#' + detailIdPrefix + id);
            if (details.classList.contains('hidden')) {
                details.classList.remove('hidden');
                btn.textContent = 'Hide Details';
            } else {
                details.classList.add('hidden');
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