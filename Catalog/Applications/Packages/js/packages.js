// Aether — Package Loading & Rendering
document.addEventListener('DOMContentLoaded', () => {
    const welcomeScreen = document.getElementById('welcome-screen');
    const packageView = document.getElementById('package-view');
    const tabs = document.querySelectorAll('.tab-btn');

    // Package data cache: filename -> data
    if (!window.Aether.packageCache) window.Aether.packageCache = {};

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

    window.loadPackage = async function(filename) {
        // Check cache first
        if (window.Aether.packageCache[filename]) {
            const data = window.Aether.packageCache[filename];
            window.Aether.currentPackage = data; delete data._vizImages;
            renderPackage(data, filename);
            welcomeScreen.classList.add('hidden');
            packageView.classList.remove('hidden');
            renderMathInElement(document.getElementById('package-view'), {
                delimiters: [
                    {left: '$$', right: '$$', display: true},
                    {left: '$', right: '$', display: false},
                    {left: '\\(', right: '\\)', display: false},
                    {left: '\\[', right: '\\]', display: true}
                ],
                throwOnError: false
            });
            return;
        }

        // Show loading state
        welcomeScreen.classList.add('hidden');
        packageView.classList.remove('hidden');
        document.getElementById('pkg-title').textContent = 'Loading...';
        document.getElementById('pkg-domain').textContent = '';
        document.getElementById('pkg-date').textContent = '';
        const timeEl = document.getElementById('pkg-time');
        if (timeEl) timeEl.style.display = 'none';

        try {
            const resp = await fetch(filename);
            if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
            const data = await resp.json();
            window.Aether.packageCache[filename] = data;
            window.Aether.currentPackage = data; delete data._vizImages;
            renderPackage(data, filename);

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
            document.getElementById('pkg-title').textContent = 'Error';
            document.getElementById('content-article').innerHTML = `<p style="color:var(--text-muted)">Failed to load ${filename}: ${err.message}</p>`;
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

        // Interactive HTML demos
        renderInteractiveHTMLDemos('content-interactive-demos', data.interactive_demos);

        // Visualizations (generated images from Python scripts)
        renderVisualizations('content-visualizations', data.visualizations);

        // Algorithms rendered above demos in the Interactive tab
        renderCodeBlocks('content-algorithms', data.algorithms, 'code');
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

    function renderVisualizations(containerId, items) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';

        if (!items || items.length === 0) {
            container.style.display = 'none';
            return;
        }
        container.style.display = '';

        const sectionTitle = document.createElement('h3');
        sectionTitle.className = 'section-title';
        sectionTitle.textContent = 'Visualizations';
        sectionTitle.style.cssText = 'margin-bottom: 16px; color: var(--accent-color, #7c3aed);';
        container.appendChild(sectionTitle);

        const validItems = items.filter(item => {
            if (typeof item === 'string') {
                console.warn('Skipping string visualization entry:', item);
                return false;
            }
            return true;
        });
        if (validItems.length === 0) {
            container.style.display = 'none';
            return;
        }

        // Filter out visualizations with empty or placeholder code
        const renderableItems = validItems.filter(item => {
            const code = item.code || '';
            return code.trim().length > 20;
        });
        if (renderableItems.length === 0) {
            container.style.display = 'none';
            return;
        }

        renderableItems.forEach((item, idx) => {
            const card = document.createElement('div');
            card.className = 'viz-container';

            const header = document.createElement('div');
            header.className = 'code-header';

            const title = document.createElement('span');
            title.className = 'code-title';
            title.textContent = item.name || `Visualization ${idx + 1}`;

            const btnGroup = document.createElement('div');
            btnGroup.style.cssText = 'display: flex; gap: 8px; align-items: center;';

            const toggleBtn = document.createElement('button');
            toggleBtn.className = 'source-toggle';
            toggleBtn.textContent = 'Show Source';
            toggleBtn.addEventListener('click', () => {
                const editor = card.querySelector('.code-editor');
                if (editor.style.display === 'none') {
                    editor.style.display = '';
                    toggleBtn.textContent = 'Hide Source';
                } else {
                    editor.style.display = 'none';
                    toggleBtn.textContent = 'Show Source';
                }
            });

            const genBtn = document.createElement('button');
            genBtn.className = 'run-btn viz-generate-btn';
            if (!window.Aether.pyodideInstance) {
                genBtn.disabled = true;
                genBtn.textContent = 'Loading Engine...';
            } else {
                genBtn.textContent = 'Generate';
            }

            btnGroup.appendChild(toggleBtn);
            btnGroup.appendChild(genBtn);
            header.appendChild(title);
            header.appendChild(btnGroup);

            const desc = document.createElement('p');
            desc.className = 'viz-description';
            desc.textContent = item.description || '';
            desc.style.cssText = 'margin: 4px 0 8px; color: var(--text-muted); font-size: 0.9em;';

            const editor = document.createElement('textarea');
            editor.className = 'code-editor';
            editor.spellcheck = false;
            editor.value = item.code || '';
            editor.style.display = 'none'; // Hidden by default

            const outputContainer = document.createElement('div');
            outputContainer.className = 'gallery-img-container';
            outputContainer.style.cssText = 'min-height: 100px; display: flex; align-items: center; justify-content: center; background: var(--bg-secondary, #1e1e2e); border-radius: 8px; margin-top: 8px;';
            outputContainer.innerHTML = '<div class="viz-placeholder">Click Generate to create visualization</div>';

            genBtn.addEventListener('click', () => {
                if (window.runVisualization) {
                    window.runVisualization(editor.value, outputContainer, genBtn);
                }
            });

            card.appendChild(header);
            card.appendChild(desc);
            card.appendChild(editor);
            card.appendChild(outputContainer);
            container.appendChild(card);
        });
    }

    function renderInteractiveHTMLDemos(containerId, items) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';

        if (!items || items.length === 0) {
            container.style.display = 'none';
            return;
        }
        container.style.display = '';

        const sectionTitle = document.createElement('h3');
        sectionTitle.className = 'section-title';
        sectionTitle.textContent = 'Interactive Demonstrations';
        sectionTitle.style.cssText = 'margin-bottom: 16px; color: var(--accent-color, #7c3aed);';
        container.appendChild(sectionTitle);

        const validItems = items.filter(item => {
            if (typeof item === 'string') {
                console.warn('Skipping string interactive demo entry:', item);
                return false;
            }
            return true;
        });
        if (validItems.length === 0) {
            container.style.display = 'none';
            return;
        }

        validItems.forEach((item, idx) => {
            const card = document.createElement('div');
            card.className = 'code-card';
            card.style.cssText = 'margin-bottom: 12px;';

            const header = document.createElement('div');
            header.className = 'code-header';

            const title = document.createElement('span');
            title.className = 'code-title';
            title.textContent = item.name || `Interactive Demo ${idx + 1}`;

            header.appendChild(title);

            const content = document.createElement('div');
            content.className = 'interactive-demo-inline';
            content.style.cssText = 'width: 100%; border-radius: 12px;';
            content.innerHTML = item.html || '<p>No content</p>';

            // innerHTML does not execute <script> tags — execute them via Blob URLs
            content.querySelectorAll('script').forEach(oldScript => {
                if (oldScript.src) return; // external scripts handled by browser
                const blob = new Blob([oldScript.textContent], { type: 'application/javascript' });
                const url = URL.createObjectURL(blob);
                const newScript = document.createElement('script');
                newScript.src = url;
                newScript.onload = () => URL.revokeObjectURL(url);
                oldScript.parentNode.replaceChild(newScript, oldScript);
            });

            card.appendChild(header);
            card.appendChild(content);
            container.appendChild(card);
        });
    }

    function renderCodeBlocks(containerId, items, codeField) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';

        const validItems = (items || []).filter(item => {
            if (typeof item === 'string') {
                console.warn('Skipping string code entry:', item);
                return false;
            }
            return true;
        });
        if (validItems.length > 0) {
            validItems.forEach(item => {
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

    function renderLineageLinks(container, pkgData) {
        const pkgExpId = pkgData.exp_id || '';
        if (!window.PACKAGE_DB_INDEX || !window.PACKAGE_INDEX) {
            container.innerHTML = '';
            return;
        }

        // Build exp_id -> filename lookup
        const expIdToFilename = {};
        window.PACKAGE_INDEX.forEach(p => {
            if (p.exp_id) expIdToFilename[p.exp_id] = p.filename;
        });

        // Find parents: packages whose exp_id is in this package's source_exp_ids
        const skipIds = new Set(['pi_brainstorm', 'seed', '']);
        const parentIds = (pkgData.source_exp_ids || []).filter(id => !skipIds.has(id));
        const parents = parentIds.map(id => {
            const fn = expIdToFilename[id];
            if (!fn) return null;
            const entry = window.PACKAGE_DB_INDEX[fn];
            return { filename: fn, title: entry ? entry.title : id, exp_id: id };
        }).filter(Boolean);

        // Find children: packages whose source_exp_ids contains this package's exp_id
        const children = [];
        window.PACKAGE_INDEX.forEach(p => {
            if (p.exp_id === pkgExpId) return;
            const entry = window.PACKAGE_DB_INDEX[p.filename];
            if (!entry || !entry.source_exp_ids) return;
            if (entry.source_exp_ids.includes(pkgExpId)) {
                children.push({ filename: p.filename, title: entry.title || p.title, exp_id: p.exp_id });
            }
        });

        if (parents.length === 0 && children.length === 0) {
            container.innerHTML = '';
            return;
        }

        let html = '<div class="lineage-chain">';
        if (parents.length > 0) {
            html += '<div class="lineage-section lineage-parents">';
            html += '<span class="lineage-label">Parent' + (parents.length > 1 ? 's' : '') + ':</span> ';
            html += parents.map(p =>
                `<a href="#" class="lineage-link" data-filename="${p.filename}">${p.title}</a>`
            ).join('<span class="lineage-sep">&rarr;</span> ');
            html += '</div>';
        }
        if (children.length > 0) {
            html += '<div class="lineage-section lineage-children">';
            html += '<span class="lineage-label">Child' + (children.length > 1 ? 'ren' : '') + ':</span> ';
            html += children.map(c =>
                `<a href="#" class="lineage-link" data-filename="${c.filename}">${c.title}</a>`
            ).join('<span class="lineage-sep">|</span> ');
            html += '</div>';
        }
        html += '</div>';
        container.innerHTML = html;

        // Wire up link clicks to loadPackage
        container.querySelectorAll('.lineage-link').forEach(a => {
            a.addEventListener('click', (e) => {
                e.preventDefault();
                if (window.loadPackage) window.loadPackage(a.dataset.filename);
            });
        });
    }

    function renderDirectionsTab(pkgData) {
        // Lineage: parent and child package links
        const lineageDiv = document.getElementById('content-lineage');
        renderLineageLinks(lineageDiv, pkgData);

        // Narrative section: raw markdown from package's future_directions field
        const narrativeDiv = document.getElementById('content-directions-narrative');
        const fd = pkgData.future_directions;
        if (fd && typeof fd === 'string' && fd.length > 50 && !fd.endsWith('.md')) {
            narrativeDiv.innerHTML = marked.parse(fd);
        } else {
            narrativeDiv.innerHTML = '<p style="color:var(--text-muted)">No future directions narrative for this package.</p>';
        }

        // Filtered direction cards from window.FUTURE_DIRECTIONS (lazy-load if needed)
        if (!window.FUTURE_DIRECTIONS && window.loadFutureDirections) {
            window.loadFutureDirections(() => renderDirectionsTab(pkgData));
            return;
        }
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