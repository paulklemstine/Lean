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

        // Algorithms: use 'code' field (some older packages have 'pseudocode' too)
        const algoField = data.algorithms && data.algorithms.some(a => a.pseudocode && a.pseudocode.trim())
            ? 'pseudocode' : 'code';
        renderCodeBlocks('content-algorithms', data.algorithms, algoField);
        if (window.renderInteractiveDemos) {
            window.renderInteractiveDemos('content-demos', data.demos);
        }

        // Future Directions tab
        renderDirectionsTab(data);

        // Lean — parse into individual file cards
        const leanContainer = document.getElementById('lean-files-container');
        const leanHeader = document.getElementById('lean-header');
        const leanZipBtn = document.getElementById('lean-download-zip');
        leanContainer.innerHTML = '';
        leanHeader.style.display = 'none';

        // Parse lean_proofs into [{name, code}] regardless of format
        const leanFiles = [];
        if (data.lean_proofs) {
            if (typeof data.lean_proofs === 'string') {
                const lp = data.lean_proofs;
                if (lp.length > 50 && !lp.endsWith('.lean')) {
                    // Split by file markers
                    const parts = lp.split(/-- (?:NEW_FILE|DIFF): (.+?)\n/);
                    if (parts.length > 1) {
                        for (let i = 1; i < parts.length; i += 2) {
                            const name = parts[i].trim();
                            const code = (i + 1 < parts.length) ? parts[i + 1].trim() : '';
                            if (code) leanFiles.push({ name, code });
                        }
                    } else {
                        // Single file — derive name from package
                        const slug = (data.title || 'Proof').replace(/[^a-zA-Z0-9]/g, '').slice(0, 30) || 'Proof';
                        leanFiles.push({ name: slug + '.lean', code: lp });
                    }
                }
            } else if (Array.isArray(data.lean_proofs)) {
                for (const entry of data.lean_proofs) {
                    if (typeof entry === 'string') {
                        if (entry.length > 50 && !entry.endsWith('.lean')) {
                            const slug = (data.title || 'Proof').replace(/[^a-zA-Z0-9]/g, '').slice(0, 30) || 'Proof';
                            leanFiles.push({ name: slug + '.lean', code: entry });
                        }
                        // Skip short filename placeholders
                    } else if (typeof entry === 'object' && entry !== null) {
                        // Dict with file, theorems, description, and possibly code
                        const fname = entry.file || entry.name || 'Proof.lean';
                        const basename = fname.split('/').pop();
                        if (entry.code && entry.code.trim()) {
                            leanFiles.push({ name: basename, code: entry.code });
                        } else if (entry.content && entry.content.trim()) {
                            leanFiles.push({ name: basename, code: entry.content });
                        } else {
                            // No code available — skip this file
                            console.warn('Lean file has no embedded code:', fname);
                        }
                    }
                }
            }
        }

        if (leanFiles.length === 0) {
            leanContainer.innerHTML = '<div style="color: var(--text-muted); padding: 16px;">-- No Lean proofs provided.</div>';
        } else {
            leanHeader.style.display = 'flex';
            renderLeanCards();

            function renderLeanCards() {
                leanContainer.innerHTML = '';
                // Filter to files that have code
                const filesWithCode = leanFiles.filter(f => f.code && f.code.trim());

                if (filesWithCode.length === 0) {
                    leanContainer.innerHTML = '<div style="color: var(--text-muted); padding: 16px;">-- No Lean proofs provided.</div>';
                    leanHeader.style.display = 'none';
                    return;
                }

                filesWithCode.forEach((file, idx) => {
                    const card = document.createElement('div');
                    card.className = 'code-container';
                    card.style.cssText = 'margin-bottom: 16px;';

                    const header = document.createElement('div');
                    header.className = 'code-header';
                    header.style.cssText = 'display: flex; justify-content: space-between; align-items: center;';

                    const nameSpan = document.createElement('span');
                    nameSpan.className = 'code-title';
                    nameSpan.textContent = file.name;

                    const meta = document.createElement('span');
                    meta.style.cssText = 'color: var(--text-muted); font-size: 0.85em;';
                    const thmCount = (file.code.match(/\btheorem\b/g) || []).length;
                    const lemmaCount = (file.code.match(/\blemma\b/g) || []).length;
                    const sorryCount = (file.code.match(/\bsorry\b/g) || []).length;
                    const lineCount = file.code.split('\n').length;
                    let metaText = `${lineCount} lines`;
                    if (thmCount + lemmaCount > 0) metaText += ` · ${thmCount + lemmaCount} theorems`;
                    if (sorryCount > 0) metaText += ` · ${sorryCount} sorrys`;
                    meta.textContent = metaText;

                    header.appendChild(nameSpan);
                    header.appendChild(meta);

                    const pre = document.createElement('pre');
                    const codeEl = document.createElement('code');
                    codeEl.className = 'language-lean';
                    codeEl.textContent = file.code;
                    pre.appendChild(codeEl);

                    card.appendChild(header);
                    card.appendChild(pre);
                    leanContainer.appendChild(card);
                });

                // Syntax highlight if Prism is available
                if (window.Prism) {
                    leanContainer.querySelectorAll('code.language-lean').forEach(el => Prism.highlightElement(el));
                }

                // Zip download — includes ALL research package artifacts
                leanZipBtn.onclick = async () => {
                    if (!window.JSZip) {
                        console.warn('JSZip not loaded');
                        return;
                    }
                    const zip = new JSZip();
                    const slug = (data.title || 'research_package').replace(/[^a-zA-Z0-9]+/g, '_').slice(0, 40);

                    // Lean 4 proofs
                    filesWithCode.forEach(f => zip.file(`lean/${f.name}`, f.code));

                    // Article
                    if (data.article && typeof data.article === 'string' && data.article.length > 50 && !data.article.endsWith('.md')) {
                        zip.file('ARTICLE.md', data.article);
                    }

                    // Research paper
                    if (data.research_paper && typeof data.research_paper === 'string' && data.research_paper.length > 50 && !data.research_paper.endsWith('.md')) {
                        zip.file('RESEARCH_PAPER.md', data.research_paper);
                    }

                    // Future directions
                    if (data.future_directions && typeof data.future_directions === 'string' && data.future_directions.length > 50 && !data.future_directions.endsWith('.md')) {
                        zip.file('FUTURE_DIRECTIONS.md', data.future_directions);
                    }

                    // Algorithms
                    if (Array.isArray(data.algorithms)) {
                        data.algorithms.forEach((a, i) => {
                            if (typeof a === 'object' && a.code && a.code.trim()) {
                                const name = (a.name || `algorithm_${i+1}`).replace(/[^a-zA-Z0-9_]/g, '_');
                                zip.file(`algorithms/${name}.py`, a.code);
                            }
                        });
                    }

                    // Demos
                    if (Array.isArray(data.demos)) {
                        data.demos.forEach((d, i) => {
                            if (typeof d === 'object' && d.code && d.code.trim()) {
                                const name = (d.name || `demo_${i+1}`).replace(/[^a-zA-Z0-9_]/g, '_');
                                zip.file(`demos/${name}.py`, d.code);
                            }
                        });
                    }

                    // Interactive HTML demos
                    if (Array.isArray(data.interactive_demos)) {
                        data.interactive_demos.forEach((d, i) => {
                            if (typeof d === 'object' && d.html && d.html.trim()) {
                                const name = (d.name || `interactive_${i+1}`).replace(/[^a-zA-Z0-9_]/g, '_');
                                zip.file(`interactive_demos/${name}.html`, d.html);
                            }
                        });
                    }

                    // Visualizations
                    if (Array.isArray(data.visualizations)) {
                        data.visualizations.forEach((v, i) => {
                            if (typeof v === 'object') {
                                const code = v.code || '';
                                if (code.trim()) {
                                    const name = (v.name || `visualization_${i+1}`).replace(/[^a-zA-Z0-9_]/g, '_');
                                    zip.file(`visualizations/${name}.py`, code);
                                }
                            }
                        });
                    }

                    // Modules (algorithms.py, demo.py)
                    if (data.modules && typeof data.modules === 'object') {
                        for (const [modName, modCode] of Object.entries(data.modules)) {
                            if (typeof modCode === 'string' && modCode.trim()) {
                                zip.file(`modules/${modName}.py`, modCode);
                            }
                        }
                    }

                    const blob = await zip.generateAsync({ type: 'blob' });
                    const a = document.createElement('a');
                    a.href = URL.createObjectURL(blob);
                    a.download = slug + '.zip';
                    a.click();
                    URL.revokeObjectURL(a.href);
                };
            }
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

        const isFilename = (s) => typeof s === 'string' && s.length < 80 && (s.endsWith('.py') || s.startsWith('viz_') || s.startsWith('visualize_'));

        // Resolve viz code from package modules when code field is a filename
        const resolveVizCode = (item) => {
            const code = item.code || '';
            if (code.trim() && !isFilename(code)) return code;

            // code is a filename or empty — resolve from package modules
            const pkg = window.Aether.currentPackage || {};
            const modules = pkg.modules || {};

            // When code is a filename, the actual viz code is in the demo module.
            // The LLM outputs filenames as placeholders; the real Python is in modules.
            for (const modName of ['demo', 'algorithms']) {
                const modCode = modules[modName] || '';
                if (modCode && modCode.trim()) {
                    return modCode;
                }
            }

            // Last resort: try code_file
            if (item.code_file) return null; // will be fetched async
            return '';
        };

        const validItems = items.filter(item => {
            if (typeof item === 'string') {
                console.warn('Skipping string visualization entry:', item);
                return false;
            }
            const resolved = resolveVizCode(item);
            if (resolved === null) return true; // code_file fetch pending
            return resolved && resolved.trim().length > 0;
        });
        if (validItems.length === 0) {
            container.style.display = 'none';
            return;
        }

        validItems.forEach((item, idx) => {
            let resolvedCode = resolveVizCode(item);
            if (resolvedCode === null) resolvedCode = ''; // will be filled by code_file fetch
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
                    autoSizeEditor();
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
            } else if (!resolvedCode && item.code_file) {
                genBtn.disabled = true;
                genBtn.textContent = 'Loading Code...';
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
            editor.value = resolvedCode;
            editor.style.display = 'none'; // Hidden by default
            // Auto-size: set height to fit content when shown
            const autoSizeEditor = () => {
                editor.style.height = 'auto';
                editor.style.height = Math.max(450, editor.scrollHeight) + 'px';
            };

            // Fetch code from code_file if not resolved yet
            if (!resolvedCode && item.code_file) {
                fetch(item.code_file)
                    .then(r => r.ok ? r.text() : Promise.reject(r.statusText))
                    .then(code => {
                        // If fetched code is just a filename (garbage), try modules instead
                        if (isFilename(code)) {
                            const modResolved = resolveVizCode({...item, code: ''});
                            code = modResolved || '';
                        }
                        editor.value = code;
                        resolvedCode = code;
                        genBtn.disabled = !code || !code.trim();
                        genBtn.textContent = code ? 'Generate' : 'Code Unavailable';
                        autoSizeEditor();
                    })
                    .catch(err => {
                        console.warn('Failed to fetch viz code:', item.code_file, err);
                        // Try modules as fallback
                        const modCode = resolveVizCode({...item, code: '', code_file: ''});
                        if (modCode) {
                            editor.value = modCode;
                            resolvedCode = modCode;
                            genBtn.disabled = false;
                            genBtn.textContent = 'Generate';
                            autoSizeEditor();
                        } else {
                            genBtn.disabled = true;
                            genBtn.textContent = 'Code Unavailable';
                        }
                    });
            }

            const outputContainer = document.createElement('div');
            outputContainer.className = 'gallery-img-container';
            outputContainer.style.cssText = 'min-height: 100px; display: flex; align-items: center; justify-content: center; background: var(--bg-secondary, #1e1e2e); border-radius: 8px; margin-top: 8px;';
            outputContainer.innerHTML = '<div class="viz-placeholder">Click Generate to create visualization</div>';

            genBtn.addEventListener('click', () => {
                if (window.runVisualization) {
                    const codeToRun = editor.value;
                    // Guard against filename-only code (not runnable Python)
                    if (!codeToRun || !codeToRun.trim() || isFilename(codeToRun.trim())) {
                        outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted);">Source code not available for this visualization</div>';
                        return;
                    }
                    window.runVisualization(codeToRun, outputContainer, genBtn);
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

            if (item.description) {
                const desc = document.createElement('p');
                desc.style.cssText = 'color: var(--text-muted); font-size: 0.9em; margin: 4px 0 8px;';
                desc.textContent = item.description;
                header.appendChild(desc);
            }

            // Inline embed the HTML snippet inside a card wrapper
            const content = document.createElement('div');
            content.className = 'interactive-demo-content';
            content.style.cssText = 'padding: 16px; background: #fff; color: #222; border-radius: 0 0 12px 12px; overflow: visible;';
            content.innerHTML = item.html || '<p>No content</p>';

            // Execute inline <script> tags (innerHTML doesn't run them).
            // Use a per-demo namespace so const/let declarations don't conflict,
            // but expose handler functions referenced by inline oninput/onclick/etc.
            // attributes so those attributes can find their functions.
            const handlerFns = new Set();
            content.querySelectorAll('[oninput],[onclick],[onchange],[onkeyup],[onkeydown]').forEach(el => {
                for (const attr of ['oninput','onclick','onchange','onkeyup','onkeydown']) {
                    const val = el.getAttribute(attr);
                    if (val) {
                        const m = val.match(/^([a-zA-Z_]\w*)\s*\(/);
                        if (m) handlerFns.add(m[1]);
                    }
                }
            });
            const fnExposes = [...handlerFns].map(fn =>
                `window.${fn} = window.${fn} || ${fn};`
            ).join('\n');

            content.querySelectorAll('script').forEach(oldScript => {
                if (oldScript.src) return;
                const newScript = document.createElement('script');
                newScript.textContent = `(function() {\n${oldScript.textContent}\n${fnExposes}\n})();`;
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