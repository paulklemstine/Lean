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

        // Visualizations
        const vizDiv = document.getElementById('content-visualizations');
        vizDiv.innerHTML = '';
        if (data.visualizations && data.visualizations.length > 0) {
            data.visualizations.forEach((viz, index) => {
                const card = document.createElement('div');
                card.className = 'gallery-card';
                card.style.cursor = 'pointer';
                card.addEventListener('click', () => window.openLightbox(index));

                let imgContent = '';
                if (viz.file) {
                    imgContent = `<img src="${viz.file}" alt="${viz.name || 'Visualization'}">`;
                } else if (viz.data && viz.data.startsWith('<svg')) {
                    const svgUri = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(viz.data);
                    imgContent = `<img src="${svgUri}" alt="${viz.name || 'Visualization'}">`;
                } else if (viz.data && viz.data.startsWith('data:image')) {
                    imgContent = `<img src="${viz.data}" alt="${viz.name || 'Visualization'}">`;
                } else {
                    imgContent = '<p style="color:#666">Invalid image data</p>';
                }

                card.innerHTML = `
                    <div class="gallery-img-container">
                        ${imgContent}
                    </div>
                    <div class="gallery-info">
                        <div class="gallery-title">${viz.name || 'Visualization'}</div>
                        ${viz.description ? `<p style="color:var(--text-muted);font-size:0.9rem">${viz.description}</p>` : ''}
                    </div>
                `;
                vizDiv.appendChild(card);
            });
        } else {
            vizDiv.innerHTML = '<p style="color:var(--text-muted)">No visualizations generated.</p>';
        }

        // Algorithms & Demos
        renderCodeBlocks('content-algorithms', data.algorithms, 'pseudocode');
        if (window.renderInteractiveDemos) {
            window.renderInteractiveDemos('content-demos', data.demos);
        }

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
});