// Aether — Package Loading & Rendering
document.addEventListener('DOMContentLoaded', () => {
    const welcomeScreen = document.getElementById('welcome-screen');
    const packageView = document.getElementById('package-view');
    const tabs = document.querySelectorAll('.tab-btn');

    // Tab switching
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
            tab.classList.add('active');
            const targetId = `tab-${tab.dataset.tab}`;
            document.getElementById(targetId).classList.add('active');
        });
    });

    window.loadPackage = function(filename) {
        if (!window.PACKAGE_DB || !window.PACKAGE_DB[filename]) {
            alert(`Error: ${filename} not found in packages_db.js`);
            return;
        }

        try {
            const data = window.PACKAGE_DB[filename];
            window.Aether.currentPackage = data;
            renderPackage(data, filename);

            welcomeScreen.classList.add('hidden');
            packageView.classList.remove('hidden');

            // Trigger KaTeX render
            renderMathInElement(document.getElementById('package-view'), {
                delimiters: [
                    {left: '$$', right: '$$', display: true},
                    {left: '$', right: '$', display: false},
                    {left: '\\(', right: '\\)', display: false},
                    {left: '\\[', right: '\\]', display: true}
                ],
                throwOnError: false
            });
        } catch(err) {
            console.error(err);
            alert(`Error rendering package data: ${err.message}`);
        }
    };

    function renderPackage(data, filename) {
        document.getElementById('pkg-title').textContent = data.title || 'Untitled Research';
        document.getElementById('pkg-domain').textContent = data.domain || 'General';

        let dateStr = 'Recent';
        let timeStr = '';
        if (window.PACKAGE_INDEX) {
            const pkgMeta = window.PACKAGE_INDEX.find(p => p.filename === filename);
            if (pkgMeta && pkgMeta.date) {
                const d = new Date(pkgMeta.date);
                if (!isNaN(d)) {
                    dateStr = d.toLocaleDateString();
                    timeStr = d.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});
                }
            }
        }
        document.getElementById('pkg-date').textContent = dateStr;
        const timeEl = document.getElementById('pkg-time');
        if (timeEl) {
            timeEl.textContent = timeStr;
            timeEl.style.display = timeStr ? 'block' : 'none';
        }

        // Article
        const articleDiv = document.getElementById('content-article');
        if (data.article) {
            articleDiv.innerHTML = marked.parse(data.article);
        } else {
            articleDiv.innerHTML = '<p style="color:var(--text-muted)">No article provided.</p>';
        }

        // Paper
        const paperDiv = document.getElementById('content-paper');
        if (data.research_paper) {
            paperDiv.innerHTML = marked.parse(data.research_paper);
        } else {
            paperDiv.innerHTML = '<p style="color:var(--text-muted)">No research paper provided.</p>';
        }

        // Visualizations (tab removed — skip rendering)

        // Algorithms (pseudocode) rendered above demos in the Interactive tab
        renderCodeBlocks('content-algorithms', data.algorithms, 'pseudocode');
        if (window.renderInteractiveDemos) {
            window.renderInteractiveDemos('content-demos', data.demos);
        }

        // Future Directions tab
        renderDirectionsTab(data);

        // Lean
        const leanDiv = document.getElementById('content-lean');
        if (data.lean_proofs) {
            leanDiv.textContent = data.lean_proofs;
        } else {
            leanDiv.textContent = '-- No Lean proofs provided.';
        }

        // Reset to first tab
        tabs[0].click();

        // Scroll to top
        document.getElementById('main-content').scrollTop = 0;
    }

    function renderCodeBlocks(containerId, items, codeField) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';

        if (items && items.length > 0) {
            items.forEach(item => {
                const card = document.createElement('div');
                card.className = 'code-card';
                card.innerHTML = `
                    <div class="code-header">
                        <span class="code-title">${item.name || 'Untitled'}</span>
                    </div>
                    <pre><code>${window.escapeHtml(item[codeField] || '')}</code></pre>
                `;
                container.appendChild(card);
            });
        } else {
            container.innerHTML = '<p style="color:var(--text-muted)">No data provided for this section.</p>';
        }
    }

    function renderDirectionsTab(pkgData) {
        // Narrative section: raw markdown from package's future_directions field
        const narrativeDiv = document.getElementById('content-directions-narrative');
        if (pkgData.future_directions) {
            narrativeDiv.innerHTML = marked.parse(pkgData.future_directions);
        } else {
            narrativeDiv.innerHTML = '<p style="color:var(--text-muted)">No future directions narrative for this package.</p>';
        }

        // Filtered direction cards from window.FUTURE_DIRECTIONS
        const cardsDiv = document.getElementById('content-directions-cards');
        const sectionTitle = document.getElementById('directions-section-title');
        const viewAllLink = document.getElementById('view-all-directions-link');

        if (!window.FUTURE_DIRECTIONS || window.FUTURE_DIRECTIONS.length === 0) {
            cardsDiv.innerHTML = '';
            sectionTitle.style.display = 'none';
            viewAllLink.style.display = 'none';
            return;
        }

        const pkgExpId = pkgData.exp_id || '';
        const pkgDomainStr = (pkgData.domain || '').toLowerCase();

        const matched = window.FUTURE_DIRECTIONS.filter(d => {
            if (d.source_exp_id && d.source_exp_id === pkgExpId) return true;
            const dirDomains = (d.domains || []).map(dm => dm.toLowerCase());
            for (const dm of dirDomains) {
                if (pkgDomainStr.includes(dm)) return true;
            }
            return false;
        });

        if (matched.length === 0) {
            cardsDiv.innerHTML = '<p style="color:var(--text-muted)">No directly related directions found.</p>';
            sectionTitle.style.display = 'none';
        } else {
            sectionTitle.style.display = 'block';
            sectionTitle.textContent = `Related Research Directions (${matched.length})`;
            window.renderDirectionCards(cardsDiv, matched, 'pkg-details-');
        }

        viewAllLink.style.display = 'block';
        viewAllLink.onclick = function(e) {
            e.preventDefault();
            if (window.showDirectionsView) window.showDirectionsView();
        };
    }
});