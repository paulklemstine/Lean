// Common KaTeX macros for math operators missing in base KaTeX
const KATEX_MACROS = {
    "\\Log": "\\operatorname{Log}",
    "\\Arg": "\\operatorname{Arg}",
    "\\Tr": "\\operatorname{Tr}",
    "\\diag": "\\operatorname{diag}",
    "\\rank": "\\operatorname{rank}",
    "\\erf": "\\operatorname{erf}",
    "\\argmax": "\\operatorname*{argmax}",
    "\\argmin": "\\operatorname*{argmin}",
    "\\spec": "\\operatorname{spec}",
    "\\Spec": "\\operatorname{Spec}",
    "\\supp": "\\operatorname{supp}",
    "\\Re": "\\operatorname{Re}",
    "\\Im": "\\operatorname{Im}"
};

window.renderKaTeXMath = function(element) {
    if (!element || typeof renderMathInElement !== 'function') return;
    renderMathInElement(element, {
        delimiters: [
            { left: "$$", right: "$$", display: true },
            { left: "\\[", right: "\\]", display: true },
            { left: "\\(", right: "\\)", display: false },
            { left: "$", right: "$", display: false }
        ],
        macros: KATEX_MACROS,
        throwOnError: false
    });
};

window.renderMarkdownWithMath = function(markdown) {
    if (!markdown) return '';
    const mathBlocks = [];
    let counter = 0;
    
    let text = markdown;

    // Fix LLM JSON string mangling for common LaTeX commands
    text = text.replace(/\x0crac/g, '\\frac');
    text = text.replace(/\x08eta/g, '\\beta');
    text = text.replace(/\x09heta/g, '\\theta');
    text = text.replace(/\x09au/g, '\\tau');
    text = text.replace(/\x0dho/g, '\\rho');
    text = text.replace(/\x0cog/gi, '\\Log');

    text = text.replace(/\$\$([\s\S]+?)\$\$/g, (match) => {
        const cleanMatch = match.replace(/^([ \t]*>[ \t]?)+/gm, '');
        const id = `MATHBLOCKDISPLAY${counter++}MATHBLOCK`;
        mathBlocks.push({ id, content: cleanMatch });
        return id;
    });

    // Display math: \[ ... \]
    text = text.replace(/\\\[([\s\S]+?)\\\]/g, (match) => {
        const cleanMatch = match.replace(/^([ \t]*>[ \t]?)+/gm, '');
        const id = `MATHBLOCKDISPLAY${counter++}MATHBLOCK`;
        mathBlocks.push({ id, content: cleanMatch });
        return id;
    });

    // Inline math: \( ... \)
    text = text.replace(/\\\(([\s\S]+?)\\\)/g, (match) => {
        const cleanMatch = match.replace(/^([ \t]*>[ \t]?)+/gm, '');
        const id = `MATHBLOCKINLINE${counter++}MATHBLOCK`;
        mathBlocks.push({ id, content: cleanMatch });
        return id;
    });

    // Inline math: $ ... $
    text = text.replace(/\$([^$]+?)\$/g, (match, inner) => {
        if (inner.includes('\n\n')) return match;
        const cleanMatch = match.replace(/^([ \t]*>[ \t]?)+/gm, '');
        const id = `MATHBLOCKINLINE${counter++}MATHBLOCK`;
        mathBlocks.push({ id, content: cleanMatch });
        return id;
    });

    let html = marked.parse(text);

    // Escape HTML inside math blocks to prevent browser truncation
    const escapeHtml = (unsafe) => {
        return unsafe
             .replace(/&/g, "&amp;")
             .replace(/</g, "&lt;")
             .replace(/>/g, "&gt;")
             .replace(/"/g, "&quot;")
             .replace(/'/g, "&#039;");
    };

    // Restore math blocks
    mathBlocks.forEach(block => {
        html = html.replace(block.id, () => escapeHtml(block.content));
    });

    return html;
};

document.addEventListener('DOMContentLoaded', () => {
    const welcomeScreen = document.getElementById('welcome-screen');
    const packageView = document.getElementById('package-view');
    const tabs = document.querySelectorAll('.tab-btn');

    // Package data cache: filename -> data
    if (!window.Aether.packageCache) window.Aether.packageCache = {};

    // Helper: Parse current route from path or hash
    function parseCurrentRoute() {
        const hash = window.location.hash || '';
        const pathname = window.location.pathname || '/';
        const cleanPath = decodeURIComponent(pathname.replace(/^\/+|\/+$/g, ''));

        // 1. Old-style hash: #pkg=filename.json or #pkg=slug
        const hashPkgMatch = hash.match(/^#pkg=(.+)$/i);
        if (hashPkgMatch) {
            let file = decodeURIComponent(hashPkgMatch[1]);
            if (!file.endsWith('.json')) file += '.json';
            return { type: 'package', filename: file };
        }

        // 2. Catalog hash: #catalog...
        const hashCatMatch = hash.match(/^#catalog(?:[\/=\?](.+))?$/i);
        if (hashCatMatch || hash.toLowerCase().startsWith('#catalog') || hash.toLowerCase().startsWith('#lean-catalog')) {
            const relPath = hashCatMatch && hashCatMatch[1] ? decodeURIComponent(hashCatMatch[1]).replace(/^file=/, '') : null;
            return { type: 'catalog', path: relPath };
        }

        // 3. Directions hash: #directions...
        if (hash === '#directions' || hash.startsWith('#directions')) {
            return { type: 'directions' };
        }

        // 4. Clean path routing: /directions, /catalog, or /<package_slug>
        if (cleanPath === 'directions') {
            return { type: 'directions' };
        }
        if (cleanPath === 'catalog' || cleanPath === 'lean-catalog') {
            return { type: 'catalog' };
        }
        if (cleanPath.startsWith('catalog/')) {
            return { type: 'catalog', path: cleanPath.substring(8) };
        }

        if (cleanPath && cleanPath !== 'index.html' && cleanPath !== '404.html') {
            let filename = cleanPath;
            if (!filename.endsWith('.json')) filename += '.json';
            return { type: 'package', filename: filename };
        }

        return { type: 'welcome' };
    }

    function handleRoute() {
        const route = parseCurrentRoute();
        if (route.type === 'package') {
            if (!window.Aether.currentPackage || window.Aether.currentPackageFilename !== route.filename) {
                if (window.loadPackage) window.loadPackage(route.filename, false);
            }
        } else if (route.type === 'catalog') {
            if (window.showLeanCatalog) window.showLeanCatalog(route.path);
        } else if (route.type === 'directions') {
            if (window.showDirectionsView) window.showDirectionsView();
        } else {
            if (window.showWelcome) window.showWelcome(false);
        }
    }

    window.addEventListener('hashchange', handleRoute);
    window.addEventListener('popstate', handleRoute);

    // Initial route handling
    const tryInitialLoad = () => {
        if (window.loadPackage && window.showWelcome) {
            handleRoute();
        } else {
            setTimeout(tryInitialLoad, 50);
        }
    };
    tryInitialLoad();

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

    // Show the welcome screen and update URL
    window.showWelcome = function(updateUrl = true) {
        welcomeScreen.classList.remove('hidden');
        packageView.classList.add('hidden');
        if (window.resumeGraphAnimation) window.resumeGraphAnimation();
        const titleEl = document.getElementById('pkg-title');
        if (titleEl) titleEl.textContent = '';
        window.Aether.currentPackage = null;
        window.Aether.currentPackageFilename = null;
        if (updateUrl !== false) {
            if (window.location.pathname !== '/' && window.location.pathname !== '/index.html') {
                history.pushState(null, '', '/');
            } else if (window.location.hash) {
                history.pushState(null, '', window.location.pathname);
            }
        }
    };

    window.loadPackage = async function(filename, updateUrl = true) {
        if (window.pauseGraphAnimation) window.pauseGraphAnimation();
        const slug = filename.replace(/\.json$/i, '');
        if (updateUrl !== false) {
            const targetPath = '/' + encodeURIComponent(slug);
            if (window.location.pathname !== targetPath) {
                history.pushState(null, '', targetPath);
            }
        }

        // Check cache first
        if (window.Aether.packageCache[filename]) {
            const data = window.Aether.packageCache[filename];
            window.Aether.currentPackage = data; delete data._vizImages;
            window.Aether.currentPackageFilename = filename;
            renderPackage(data, filename);
            welcomeScreen.classList.add('hidden');
            packageView.classList.remove('hidden');
            if (window.renderKaTeXMath) {
                window.renderKaTeXMath(document.getElementById('package-view'));
            }
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
        const zipBtn = document.getElementById('lean-download-zip');
        if (zipBtn) zipBtn.style.display = 'none';
        const copyBtn = document.getElementById('copy-link-btn');
        if (copyBtn) copyBtn.style.display = 'none';

        try {
            const fetchPath = '/' + filename.replace(/^\/+/, '');
            const resp = await fetch(fetchPath + '?v=' + Date.now());
            if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
            const data = await resp.json();
            window.Aether.packageCache[filename] = data;
            window.Aether.currentPackage = data; delete data._vizImages;
            window.Aether.currentPackageFilename = filename;
            renderPackage(data, filename);

            if (window.renderKaTeXMath) {
                window.renderKaTeXMath(document.getElementById('package-view'));
            }
        } catch(err) {
            console.error(err);
            document.getElementById('pkg-title').textContent = 'Error';
            document.getElementById('content-article').innerHTML = `<p style="color:var(--text-muted)">Failed to load ${filename}: ${err.message}</p>`;
        }
    };

    function renderPackage(data, filename) {
        document.getElementById('pkg-title').textContent = data.title || 'Untitled Research';
        document.getElementById('pkg-domain').textContent = data.domain || 'General';

        // Quality tier badge + percentage
        const tierEl = document.getElementById('pkg-quality-tier');
        if (tierEl) {
            const pkgMeta = window.PACKAGE_INDEX ? window.PACKAGE_INDEX.find(p => p.filename === filename) : null;
            const tier = pkgMeta ? pkgMeta.quality_tier : null;
            const score = pkgMeta ? pkgMeta.quality_score : null;
            const tierSymbols = { gold: '\u{1F947}', silver: '\u{1F948}', bronze: '\u{1F949}', unrated: '' };
            const tierColors = { gold: '#FFD700', silver: '#C0C0C0', bronze: '#CD7F32', unrated: '#888' };
            if (tier && tier !== 'unrated') {
                tierEl.innerHTML = `<span style="font-size:1.2em">${tierSymbols[tier] || ''}</span>` +
                    `<span style="color:${tierColors[tier] || '#888'};font-weight:bold;margin-left:4px">` +
                    `${tier.toUpperCase()}</span>` +
                    (score != null ? `<span style="color:var(--text-muted);margin-left:8px">${Math.round(score * 100)}%</span>` : '');
                tierEl.style.display = 'inline';
            } else if (score != null) {
                tierEl.innerHTML = `<span style="color:var(--text-muted)">${Math.round(score * 100)}%</span>`;
                tierEl.style.display = 'inline';
            } else {
                tierEl.style.display = 'none';
            }
        }

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
        // Show the download zip button in the header once package is loaded
        const zipBtn = document.getElementById('lean-download-zip');
        if (zipBtn) zipBtn.style.display = 'inline-flex';

        // Show the copy-link button and wire it up
        const copyLinkBtn = document.getElementById('copy-link-btn');
        if (copyLinkBtn) {
            copyLinkBtn.style.display = 'inline-flex';
            copyLinkBtn.onclick = async () => {
                const url = window.location.href;
                try {
                    await navigator.clipboard.writeText(url);
                    const orig = copyLinkBtn.innerHTML;
                    copyLinkBtn.innerHTML = '✓ Copied!';
                    setTimeout(() => { copyLinkBtn.innerHTML = orig; }, 1500);
                } catch (err) {
                    // Fallback: use a temporary input
                    const tmp = document.createElement('input');
                    tmp.value = url;
                    document.body.appendChild(tmp);
                    tmp.select();
                    try {
                        document.execCommand('copy');
                        copyLinkBtn.innerHTML = '✓ Copied!';
                        setTimeout(() => { copyLinkBtn.innerHTML = '🔗 Copy Link'; }, 1500);
                    } catch (e) {
                        copyLinkBtn.innerHTML = '✗ Failed';
                        setTimeout(() => { copyLinkBtn.innerHTML = '🔗 Copy Link'; }, 1500);
                    }
                    document.body.removeChild(tmp);
                }
            };
        }

        // Article
        const articleDiv = document.getElementById('content-article');
        if (data.article) {
            articleDiv.innerHTML = window.renderMarkdownWithMath(data.article);
        } else {
            articleDiv.innerHTML = '<p style="color:var(--text-muted)">No article provided.</p>';
        }

        // Paper
        const paperDiv = document.getElementById('content-paper');
        if (data.research_paper) {
            paperDiv.innerHTML = window.renderMarkdownWithMath(data.research_paper);
        } else {
            paperDiv.innerHTML = '<p style="color:var(--text-muted)">No research paper provided.</p>';
        }

        // Demos / Interactive Tab
        const demosTab = document.getElementById('tab-demos');
        if (demosTab) {
            if (data.interactive_layout) {
                // Render Jupyter notebook-like custom layout
                demosTab.innerHTML = '';
                
                let layoutHtml = window.renderMarkdownWithMath(data.interactive_layout);
                const placeholderRe = /\{\{\s*(widget|interactive_demo|visualization|algorithm|demo)\s*:\s*(\d+)\s*\}\}/gi;
                const renderTasks = [];
                
                layoutHtml = layoutHtml.replace(placeholderRe, (match, type, indexStr) => {
                    const index = parseInt(indexStr, 10);
                    const typeLower = type.toLowerCase();
                    const containerId = `layout-${typeLower}-${index}-${Math.random().toString(36).substr(2, 9)}`;
                    
                    renderTasks.push({
                        type: typeLower,
                        index: index,
                        containerId: containerId
                    });
                    
                    return `<div id="${containerId}" style="margin: 24px 0;"></div>`;
                });
                
                demosTab.innerHTML = `<div class="markdown-body" style="padding: 16px 0;">${layoutHtml}</div>`;
                
                renderTasks.forEach(task => {
                    const targetContainer = document.getElementById(task.containerId);
                    if (!targetContainer) return;
                    
                    if (task.type === 'widget' || task.type === 'interactive_demo') {
                        const widgets = Array.isArray(data.interactive_demos) ? data.interactive_demos : [];
                        if (widgets[task.index]) {
                            renderInteractiveHTMLDemos(task.containerId, [widgets[task.index]]);
                            const secTitle = targetContainer.querySelector('.section-title');
                            if (secTitle) secTitle.remove();
                        }
                    } else if (task.type === 'visualization') {
                        const visualizations = Array.isArray(data.visualizations) ? data.visualizations : [];
                        if (visualizations[task.index]) {
                            renderVisualizations(task.containerId, [visualizations[task.index]]);
                            const secTitle = targetContainer.querySelector('.section-title');
                            if (secTitle) secTitle.remove();
                        }
                    } else if (task.type === 'algorithm') {
                        const algorithms = Array.isArray(data.algorithms) ? data.algorithms : [];
                        if (algorithms[task.index]) {
                            renderCodeBlocks(task.containerId, [algorithms[task.index]]);
                            const secTitle = targetContainer.querySelector('.section-title');
                            if (secTitle) secTitle.remove();
                        }
                    } else if (task.type === 'demo') {
                        const demos = Array.isArray(data.demos) ? data.demos : [];
                        if (demos[task.index] && window.renderInteractiveDemos) {
                            window.renderInteractiveDemos(task.containerId, [demos[task.index]]);
                            const secTitle = targetContainer.querySelector('.section-title');
                            if (secTitle) secTitle.remove();
                        }
                    }
                });
            } else {
                // Fallback sequential rendering
                demosTab.innerHTML = `
                    <div id="content-interactive-demos"></div>
                    <div id="content-visualizations"></div>
                    <div class="algorithms-list" id="content-algorithms"></div>
                    <div class="demos-list" id="content-demos"></div>
                `;
                
                renderInteractiveHTMLDemos('content-interactive-demos', data.interactive_demos);
                
                const visualizations = Array.isArray(data.visualizations) ? data.visualizations : [];
                renderVisualizations('content-visualizations', visualizations);
                
                const algorithms = Array.isArray(data.algorithms) ? data.algorithms : [];
                renderCodeBlocks('content-algorithms', algorithms);
                
                if (window.renderInteractiveDemos) {
                    const demos = Array.isArray(data.demos) ? data.demos : [];
                    window.renderInteractiveDemos('content-demos', demos);
                }
            }
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
        const seenLeanCode = new Set(); // Dedup by code content
        function parseLeanString(lp, slug) {
            const parsedFiles = [];
            // Matches "-- NEW_FILE: path.lean", "-- DIFF: path.lean", or just "-- path.lean"
            const parts = lp.split(/--\s*(?:NEW_FILE:\s*|DIFF:\s*|)([a-zA-Z0-9_\-\.\/]+\.lean)(?:\r?\n|\\n)/);
            if (parts.length > 1) {
                for (let i = 1; i < parts.length; i += 2) {
                    const name = parts[i].trim();
                    const code = (i + 1 < parts.length) ? parts[i + 1].trim().split('\\n').join('\n') : '';
                    if (code && !seenLeanCode.has(code)) {
                        seenLeanCode.add(code);
                        parsedFiles.push({ name, code });
                    }
                }
            } else {
                const code = lp.split('\\n').join('\n');
                if (code && !seenLeanCode.has(code)) {
                    seenLeanCode.add(code);
                    parsedFiles.push({ name: slug + '.lean', code });
                }
            }
            return parsedFiles;
        }

        if (data.lean_proofs) {
            const slug = (data.title || 'Proof').replace(/[^a-zA-Z0-9]/g, '').slice(0, 30) || 'Proof';
            if (typeof data.lean_proofs === 'string') {
                const lp = data.lean_proofs;
                if (lp.length > 50 && !lp.endsWith('.lean')) {
                    leanFiles.push(...parseLeanString(lp, slug));
                }
            } else if (Array.isArray(data.lean_proofs)) {
                for (let j = 0; j < data.lean_proofs.length; j++) {
                    const entry = data.lean_proofs[j];
                    if (typeof entry === 'string') {
                        if (entry.length > 50 && !entry.endsWith('.lean')) {
                            const entrySlug = data.lean_proofs.length > 1 ? `${slug}_${j+1}` : slug;
                            leanFiles.push(...parseLeanString(entry, entrySlug));
                        }
                    } else if (typeof entry === 'object' && entry !== null) {
                        const fname = entry.file || entry.name || 'Proof.lean';
                        const code = (entry.code && entry.code.trim()) ? entry.code.split('\\n').join('\n')
                                   : (entry.content && entry.content.trim()) ? entry.content.split('\\n').join('\n')
                                   : null;
                        if (code && !seenLeanCode.has(code)) {
                            seenLeanCode.add(code);
                            leanFiles.push({ name: fname, code });
                        } else if (!code) {
                            console.warn('Lean file has no embedded code:', fname);
                        }
                    }
                }
            }
        }

        // Also handle lean_files (file paths) from package JSON
        if (data.lean_files && Array.isArray(data.lean_files)) {
            for (const fpath of data.lean_files) {
                if (!seenLeanCode.has(fpath)) {
                    seenLeanCode.add(fpath);
                    // Try to fetch the actual file content from Catalog
                    const catalogPath = fpath.startsWith('Catalog/') ? fpath : 'Catalog/' + fpath;
                    leanFiles.push({ name: fpath, code: null, path: catalogPath });
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
                // Separate files with code from files that need fetching
                const filesWithCode = leanFiles.filter(f => f.code && f.code.trim());
                const filesToFetch = leanFiles.filter(f => !f.code && f.path);

                if (filesWithCode.length === 0 && filesToFetch.length === 0) {
                    leanContainer.innerHTML = '<div style="color: var(--text-muted); padding: 16px;">-- No Lean proofs provided.</div>';
                    leanHeader.style.display = 'none';
                    return;
                }

                // Fetch content for files that have paths but no code
                filesToFetch.forEach(file => {
                    fetch(file.path)
                        .then(r => r.ok ? r.text() : Promise.reject(r.statusText))
                        .then(text => { file.code = text; renderLeanCards(); })
                        .catch(() => { file.code = `-- Could not load ${file.path}`; renderLeanCards(); });
                });

                filesWithCode.forEach((file, idx) => {
                    const card = document.createElement('div');
                    card.className = 'code-container';
                    card.style.cssText = 'margin-bottom: 16px;';

                    const header = document.createElement('div');
                    header.className = 'code-header';

                    const nameSpan = document.createElement('span');
                    nameSpan.className = 'code-title';
                    nameSpan.textContent = file.name;

                    const headerRight = document.createElement('div');
                    headerRight.className = 'code-header-buttons';

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

                    const toggleBtn = document.createElement('button');
                    toggleBtn.className = 'source-toggle';
                    toggleBtn.textContent = 'Show Code';

                    headerRight.appendChild(meta);
                    headerRight.appendChild(toggleBtn);

                    header.appendChild(nameSpan);
                    header.appendChild(headerRight);

                    const pre = document.createElement('pre');
                    pre.style.display = 'none'; // Collapsed by default
                    const codeEl = document.createElement('code');
                    codeEl.className = 'language-lean';
                    codeEl.textContent = file.code;
                    pre.appendChild(codeEl);

                    toggleBtn.addEventListener('click', () => {
                        if (pre.style.display === 'none') {
                            pre.style.display = '';
                            toggleBtn.textContent = 'Hide Code';
                            // Auto-size: fit height to content
                            pre.style.height = 'auto';
                            pre.style.height = pre.scrollHeight + 'px';
                        } else {
                            pre.style.display = 'none';
                            toggleBtn.textContent = 'Show Code';
                        }
                    });

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
        window.scrollTo({ top: 0, behavior: 'smooth' });
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
        sectionTitle.style.cssText = 'margin-bottom: 16px; color: var(--accent-color, #7c3aed); border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-top: 32px;';
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
            btnGroup.className = 'code-header-buttons';

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
            genBtn.textContent = 'Generate';

            btnGroup.appendChild(toggleBtn);
            btnGroup.appendChild(genBtn);
            header.appendChild(title);
            header.appendChild(btnGroup);

            const editor = document.createElement('textarea');
            editor.className = 'code-editor';
            editor.spellcheck = false;
            editor.cols = 80;
            editor.value = resolvedCode;
            editor.style.display = 'none'; // Hidden by default
            // Auto-size: set height to fit content when shown
            const autoSizeEditor = () => {
                editor.style.height = 'auto';
                editor.style.height = editor.scrollHeight + 'px';
            };

            const outputContainer = document.createElement('div');
            outputContainer.className = 'gallery-img-container viz-output-container';
            outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted); padding: 12px 0;">Loading visualization...</div>';

            const runViz = () => {
                if (!window.Aether.pyodideReady) {
                    outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted); font-style: italic; padding: 12px 0;">Python engine is loading, will generate visualization automatically...</div>';
                    setTimeout(runViz, 1000);
                    return;
                }
                if (window.runVisualization) {
                    const codeToRun = editor.value;
                    if (!codeToRun || !codeToRun.trim() || isFilename(codeToRun.trim())) {
                        outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted); padding: 12px 0;">Source code not available for this visualization</div>';
                        return;
                    }
                    window.runVisualization(codeToRun, outputContainer, genBtn, item.description || '');
                }
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
                        if (!code || !code.trim()) {
                            genBtn.textContent = 'Code Unavailable';
                        }
                        autoSizeEditor();
                        if (code && code.trim()) {
                            runViz();
                        } else {
                            outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted); padding: 12px 0;">Source code not available for this visualization</div>';
                        }
                    })
                    .catch(err => {
                        console.warn('Failed to fetch viz code:', item.code_file, err);
                        // Try modules as fallback
                        const modCode = resolveVizCode({...item, code: '', code_file: ''});
                        if (modCode) {
                            editor.value = modCode;
                            resolvedCode = modCode;
                            genBtn.disabled = false;
                            autoSizeEditor();
                            runViz();
                        } else {
                            genBtn.disabled = true;
                            genBtn.textContent = 'Code Unavailable';
                            outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted); padding: 12px 0;">Source code not available for this visualization</div>';
                        }
                    });
            }

            genBtn.addEventListener('click', runViz);

            card.appendChild(header);
            card.appendChild(editor);
            card.appendChild(outputContainer);
            
            if (item.description) {
                const descDiv = document.createElement('div');
                descDiv.className = 'viz-description';
                descDiv.style.cssText = 'margin-top: 12px; padding: 0 12px; font-size: 0.95em; color: var(--text-muted); text-align: justify; line-height: 1.5;';
                descDiv.innerHTML = window.renderMarkdownWithMath ? window.renderMarkdownWithMath(item.description) : item.description;
                card.appendChild(descDiv);
            }
            
            container.appendChild(card);

            // Auto-run if the code is already resolved
            if (resolvedCode && resolvedCode.trim()) {
                runViz();
            }
        });
    }

    function renderInteractiveHTMLDemos(containerId, items, inline = false) {
        // Register global message listener once to receive height reports
        // from demo iframes (they postMessage their content height from inside)
        if (!window._aetherIframeResizeListener) {
            window._aetherDemoIframes = {};
            window._aetherIframeResizeListener = function(evt) {
                if (evt.data && evt.data.aetherIframeHeight !== undefined) {
                    const iframe = window._aetherDemoIframes[evt.data.aetherIframeHeight];
                    if (iframe) {
                        // Add 20px padding to guarantee that no content is clipped and scrollbars are avoided
                        iframe.style.height = (evt.data.height + 20) + 'px';
                    }
                }
            };
            window.addEventListener('message', window._aetherIframeResizeListener);
        }

        const container = document.getElementById(containerId);
        container.innerHTML = '';

        if (!items || items.length === 0) {
            container.style.display = 'none';
            return;
        }
        container.style.display = '';

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

        if (!inline) {
            const sectionTitle = document.createElement('h3');
            sectionTitle.className = 'section-title';
            sectionTitle.textContent = 'Interactive HTML';
            sectionTitle.style.cssText = 'margin-bottom: 16px; color: var(--accent-color, #7c3aed); border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-top: 32px;';
            container.appendChild(sectionTitle);
        }

        validItems.forEach((item, idx) => {
            // Generate a random unique ID for styling scope or communication
            const uniqueId = 'iframe_' + Math.random().toString(36).substr(2, 9);
            let demoHtml = item.html || '<p>No content</p>';

            if (inline) {
                // Scoping wrapper class to prevent CSS pollution to outer document
                const wrapperClass = `inline-demo-${uniqueId}`;
                
                let cleanedHtml = demoHtml;
                // Replace body or html selectors in CSS tags
                cleanedHtml = cleanedHtml.replace(/<style>([\s\S]*?)<\/style>/gi, (match, css) => {
                    const scopedCss = css.replace(/\b(body|html)\b/gi, `.${wrapperClass}`);
                    return `<style>${scopedCss}</style>`;
                });
                
                const wrapper = document.createElement('div');
                wrapper.className = wrapperClass;
                wrapper.style.cssText = 'width: 100%; position: relative;';
                wrapper.innerHTML = cleanedHtml;
                container.appendChild(wrapper);
                
                // Execute any inline or external script tags inside the injected HTML in order
                const scripts = wrapper.querySelectorAll('script');
                scripts.forEach(oldScript => {
                    const newScript = document.createElement('script');
                    if (oldScript.src) {
                        newScript.src = oldScript.src;
                    } else {
                        newScript.textContent = `(function(){\n${oldScript.textContent}\n})();`;
                    }
                    document.body.appendChild(newScript);
                    oldScript.remove();
                });
            } else {
                // Fallback: Sandbox each demo in its own iframe via srcdoc for legacy sequential tab display
                const isFullDoc = /<!DOCTYPE|<html[\s>]/i.test(demoHtml);
                
                // Inject auto-sizing overrides so the iframe page body collapses naturally to content height
                const overrideStyle = `<style>html,body{height:auto!important;min-height:auto!important;margin:0!important;overflow:hidden!important;}</style>`;
                const autoSizer = overrideStyle + `<script>
(function(){
  var last=0,debounce=null;
  function report(){
    var h=Math.max(
      document.body.scrollHeight,
      document.body.offsetHeight,
      document.body.clientHeight,
      60
    );
    if(Math.abs(h-last)<5)return;
    last=h;
    parent.postMessage({aetherIframeHeight:'${uniqueId}',height:h},'*');
  }
  report();
  setTimeout(report,100);setTimeout(report,500);setTimeout(report,2000);
  new MutationObserver(function(){
    clearTimeout(debounce);
    debounce=setTimeout(report,50);
  }).observe(document.body,{childList:true,subtree:true,attributes:true});
  window.addEventListener('resize',report);
})();
<\/script>`;

                let srcdoc;
                if (isFullDoc) {
                    if (demoHtml.includes('</body>')) {
                        srcdoc = demoHtml.replace('</body>', autoSizer + '</body>');
                    } else {
                        srcdoc = demoHtml.replace('</html>', autoSizer + '</html>');
                    }
                } else {
                    srcdoc = `<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body{margin:0;padding:16px;font-family:system-ui,sans-serif;color:#222}</style></head><body>${demoHtml}${autoSizer}</body></html>`;
                }

                const iframe = document.createElement('iframe');
                iframe.srcdoc = srcdoc;
                iframe.style.cssText = 'width:100%;max-width:800px;margin:0 auto;border:none;min-height:60px;display:block;background:transparent;';
                
                const card = document.createElement('div');
                card.className = 'code-card';
                card.style.cssText = 'margin-bottom: 12px; display: flex; flex-direction: column; align-items: center;';

                iframe.style.borderRadius = '12px';

                const content = document.createElement('div');
                content.className = 'interactive-demo-content';
                content.style.cssText = 'background: transparent; color: #222; overflow: visible; display: flex; justify-content: center; width: 100%;';
                content.style.borderRadius = '12px';

                // Register this iframe so the message listener can resize it
                window._aetherDemoIframes[uniqueId] = iframe;

                content.appendChild(iframe);
                card.appendChild(content);
                
                if (item.description) {
                    const descDiv = document.createElement('div');
                    descDiv.className = 'viz-description';
                    descDiv.style.cssText = 'margin-top: 12px; padding: 0 12px; font-size: 0.95em; color: var(--text-muted); text-align: justify; line-height: 1.5;';
                    descDiv.innerHTML = window.renderMarkdownWithMath ? window.renderMarkdownWithMath(item.description) : item.description;
                    card.appendChild(descDiv);
                }
                
                container.appendChild(card);
            }
        });
    }

    function renderCodeBlocks(containerId, items) {
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
            const sectionTitle = document.createElement('h3');
            sectionTitle.className = 'section-title';
            sectionTitle.textContent = 'Algorithms';
            sectionTitle.style.cssText = 'margin-bottom: 16px; color: var(--accent-color, #7c3aed); border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-top: 32px;';
            container.appendChild(sectionTitle);

            validItems.forEach((item, idx) => {
                const card = document.createElement('div');
                card.className = 'code-card';
                card.style.cssText = 'margin-bottom: 24px; border: 1px solid var(--border-color); border-radius: 8px; overflow: hidden; background: var(--bg-card); display: flex; flex-direction: column;';
                
                // Explanations/Description
                let explanationHtml = '';
                const desc = (item.description || item.explanation || '').replace(/\\n/g, '\n');
                if (desc.trim()) {
                    explanationHtml = `<div class="algo-explanation" style="padding: 16px; border-bottom: 1px solid var(--border-color); color: var(--text-main); font-size: 0.95rem; line-height: 1.6; background: var(--bg-main); white-space: pre-line;">${window.renderMarkdownWithMath(desc)}</div>`;
                }

                // Check what code fields we have
                const pseudocode = (item.pseudocode || '').replace(/\\n/g, '\n');
                const code = (item.code || '').replace(/\\n/g, '\n');

                let tabsHtml = '';
                let blocksHtml = '';

                // Generate a unique ID to avoid index collisions when multiple algorithms are rendered on the same page
                const algoId = 'algo_' + Math.random().toString(36).substr(2, 9);

                if (pseudocode && code) {
                    // Show tabs to switch between Pseudocode and Python Code
                    tabsHtml = `
                        <div class="algo-tabs" style="display: flex; background: var(--bg-elevated); border-bottom: 1px solid var(--border-color); padding: 0 16px;">
                            <button class="algo-tab-btn active" data-target="pseudocode-${algoId}" style="background: none; border: none; padding: 12px 16px; color: var(--text-main); border-bottom: 2px solid var(--primary-color, #7c3aed); font-weight: 600; cursor: pointer; font-size: 0.85rem;">Pseudocode</button>
                            <button class="algo-tab-btn" data-target="python-${algoId}" style="background: none; border: none; padding: 12px 16px; color: var(--text-muted); cursor: pointer; font-size: 0.85rem;">Python Code</button>
                        </div>
                    `;
                    blocksHtml = `
                        <div class="algo-blocks">
                            <div id="pseudocode-${algoId}" class="algo-block-content">
                                <pre style="margin:0; border-radius:0; border:none;"><code class="language-text">${window.escapeHtml(pseudocode)}</code></pre>
                            </div>
                            <div id="python-${algoId}" class="algo-block-content" style="display: none;">
                                <pre style="margin:0; border-radius:0; border:none;"><code class="language-python">${window.escapeHtml(code)}</code></pre>
                            </div>
                        </div>
                    `;
                } else {
                    const content = pseudocode || code || '';
                    const langClass = pseudocode ? 'language-text' : 'language-python';
                    blocksHtml = `
                        <div class="algo-blocks">
                            <pre style="margin:0; border-radius:0; border:none;"><code class="${langClass}">${window.escapeHtml(content)}</code></pre>
                        </div>
                    `;
                }

                card.innerHTML = `
                    <div class="code-header" style="display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; background: var(--bg-elevated); border-bottom: 1px solid var(--border-color);">
                        <span class="code-title" style="font-weight: 600; color: var(--text-main); font-size: 1rem;">${item.name || 'Untitled Algorithm'}</span>
                    </div>
                    ${explanationHtml}
                    ${tabsHtml}
                    ${blocksHtml}
                `;

                // Add tab event listeners if we have tabs
                if (pseudocode && code) {
                    const tabBtns = card.querySelectorAll('.algo-tab-btn');
                    tabBtns.forEach(btn => {
                        btn.addEventListener('click', () => {
                            // Deactivate all tabs in this card
                            tabBtns.forEach(b => {
                                b.classList.remove('active');
                                b.style.color = 'var(--text-muted)';
                                b.style.borderBottom = 'none';
                            });
                            // Activate clicked tab
                            btn.classList.add('active');
                            btn.style.color = 'var(--text-main)';
                            btn.style.borderBottom = '2px solid var(--primary-color, #7c3aed)';

                            // Toggle content block
                            const targetId = btn.getAttribute('data-target');
                            card.querySelectorAll('.algo-block-content').forEach(block => {
                                block.style.display = block.id === targetId ? 'block' : 'none';
                            });
                        });
                    });
                }

                container.appendChild(card);
            });

            // Syntax highlight if Prism is available
            if (window.Prism) {
                container.querySelectorAll('code').forEach(el => Prism.highlightElement(el));
            }
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
            narrativeDiv.innerHTML = window.renderMarkdownWithMath(fd);
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