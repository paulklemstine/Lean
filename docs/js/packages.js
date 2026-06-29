// Aether — Package Loading & Rendering

window.renderMarkdownWithMath = function(markdown) {
    if (!markdown) return '';
    const mathBlocks = [];
    let counter = 0;
    
    let text = markdown;

    // Display math: $$ ... $$
    text = text.replace(/\$\$([\s\S]+?)\$\$/g, (match) => {
        const id = `MATHBLOCKDISPLAY${counter++}MATHBLOCK`;
        mathBlocks.push({ id, content: match });
        return id;
    });

    // Display math: \[ ... \]
    text = text.replace(/\\\[([\s\S]+?)\\\]/g, (match) => {
        const id = `MATHBLOCKDISPLAY${counter++}MATHBLOCK`;
        mathBlocks.push({ id, content: match });
        return id;
    });

    // Inline math: \( ... \)
    text = text.replace(/\\\(([\s\S]+?)\\\)/g, (match) => {
        const id = `MATHBLOCKINLINE${counter++}MATHBLOCK`;
        mathBlocks.push({ id, content: match });
        return id;
    });

    // Inline math: $ ... $
    text = text.replace(/\$([^$]+?)\$/g, (match, inner) => {
        if (inner.includes('\n\n')) return match;
        const id = `MATHBLOCKINLINE${counter++}MATHBLOCK`;
        mathBlocks.push({ id, content: match });
        return id;
    });

    let html = marked.parse(text);

    // Restore math blocks
    mathBlocks.forEach(block => {
        html = html.replace(block.id, () => block.content);
    });

    return html;
};

document.addEventListener('DOMContentLoaded', () => {
    const welcomeScreen = document.getElementById('welcome-screen');
    const packageView = document.getElementById('package-view');
    const tabs = document.querySelectorAll('.tab-btn');

    // Package data cache: filename -> data
    if (!window.Aether.packageCache) window.Aether.packageCache = {};

    // URL hash routing: #pkg=filename  →  load that package
    // Listen for back/forward navigation
    window.addEventListener('hashchange', () => {
        const m = window.location.hash.match(/^#pkg=(.+)$/);
        if (m) {
            const filename = decodeURIComponent(m[1]);
            // Only reload if it's a different package
            if (!window.Aether.currentPackage || window.Aether.currentPackageFilename !== filename) {
                if (window.loadPackage) window.loadPackage(filename);
            }
        } else {
            // No hash: return to welcome screen so back/forward works like normal
            // page navigation.
            if (window.showWelcome) window.showWelcome();
        }
    });

    // On page load: if hash contains #pkg=..., load it
    const initialMatch = window.location.hash.match(/^#pkg=(.+)$/);
    if (initialMatch) {
        const filename = decodeURIComponent(initialMatch[1]);
        // Wait for the script to be fully loaded, then load
        const tryLoad = () => {
            if (window.loadPackage) {
                window.loadPackage(filename);
            } else {
                setTimeout(tryLoad, 50);
            }
        };
        tryLoad();
    }

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

    // Show the welcome screen and clear the package hash.
    window.showWelcome = function() {
        welcomeScreen.classList.remove('hidden');
        packageView.classList.add('hidden');
        const titleEl = document.getElementById('pkg-title');
        if (titleEl) titleEl.textContent = '';
        window.Aether.currentPackage = null;
        window.Aether.currentPackageFilename = null;
    };

    window.loadPackage = async function(filename) {
        // Update URL hash via pushState so each package is a real history entry.
        const newHash = '#pkg=' + encodeURIComponent(filename);
        if (window.location.hash !== newHash) {
            history.pushState(null, '', newHash);
        }

        // Check cache first
        if (window.Aether.packageCache[filename]) {
            const data = window.Aether.packageCache[filename];
            window.Aether.currentPackage = data; delete data._vizImages;
            window.Aether.currentPackageFilename = filename;
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
        const zipBtn = document.getElementById('lean-download-zip');
        if (zipBtn) zipBtn.style.display = 'none';
        const copyBtn = document.getElementById('copy-link-btn');
        if (copyBtn) copyBtn.style.display = 'none';

        try {
            const resp = await fetch(filename + '?v=' + Date.now());
            if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
            const data = await resp.json();
            window.Aether.packageCache[filename] = data;
            window.Aether.currentPackage = data; delete data._vizImages;
            window.Aether.currentPackageFilename = filename;
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

        // Interactive HTML demos
        renderInteractiveHTMLDemos('content-interactive-demos', data.interactive_demos);

        // Visualizations (generated images from Python scripts)
        // Guard against string values (e.g. "MISSING" placeholders)
        const visualizations = Array.isArray(data.visualizations) ? data.visualizations : [];
        renderVisualizations('content-visualizations', visualizations);

        // Algorithms: render both pseudocode and Python source implementations
        const algorithms = Array.isArray(data.algorithms) ? data.algorithms : [];
        renderCodeBlocks('content-algorithms', algorithms);
        if (window.renderInteractiveDemos) {
            const demos = Array.isArray(data.demos) ? data.demos : [];
            window.renderInteractiveDemos('content-demos', demos);
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
                        const basename = fname.split('/').pop();
                        const code = (entry.code && entry.code.trim()) ? entry.code.split('\\n').join('\n')
                                   : (entry.content && entry.content.trim()) ? entry.content.split('\\n').join('\n')
                                   : null;
                        if (code && !seenLeanCode.has(code)) {
                            seenLeanCode.add(code);
                            leanFiles.push({ name: basename, code });
                        } else if (!code) {
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

            const desc = document.createElement('p');
            desc.className = 'viz-description';
            desc.textContent = item.description || '';
            desc.style.cssText = 'margin: 4px 0 8px; color: var(--text-muted); font-size: 0.9em;';

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
                        } else {
                            genBtn.disabled = true;
                            genBtn.textContent = 'Code Unavailable';
                        }
                    });
            }

            const outputContainer = document.createElement('div');
            outputContainer.className = 'gallery-img-container viz-output-container';
            outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted); padding: 12px 0;">Click Generate to render the visualization</div>';

            const runViz = () => {
                if (window.runVisualization) {
                    const codeToRun = editor.value;
                    if (!codeToRun || !codeToRun.trim() || isFilename(codeToRun.trim())) {
                        outputContainer.innerHTML = '<div class="viz-placeholder" style="color: var(--text-muted);">Source code not available for this visualization</div>';
                        return;
                    }
                    window.runVisualization(codeToRun, outputContainer, genBtn);
                }
            };

            genBtn.addEventListener('click', runViz);

            card.appendChild(header);
            card.appendChild(desc);
            card.appendChild(editor);
            card.appendChild(outputContainer);
            container.appendChild(card);
        });
    }

    function renderInteractiveHTMLDemos(containerId, items) {
        // Register global message listener once to receive height reports
        // from demo iframes (they postMessage their content height from inside)
        if (!window._aetherIframeResizeListener) {
            window._aetherDemoIframes = {};
            window._aetherIframeResizeListener = function(evt) {
                if (evt.data && evt.data.aetherIframeHeight !== undefined) {
                    const iframe = window._aetherDemoIframes[evt.data.aetherIframeHeight];
                    if (iframe) {
                        iframe.style.height = evt.data.height + 'px';
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

            // Sandbox each demo in its own iframe via srcdoc.  This gives each
            // demo its own document context, script scope, and CSS isolation.
            // Fixes: (1) scripts referencing DOM elements that exist in the demo
            // HTML now find them via getElementById; (2) function declarations
            // are accessible to onclick handlers within the iframe; (3) no
            // cross-demo ID collisions; (4) a bad demo can't crash the parent
            // page or pollute the global scope; (5) no eval hacks needed.
            const content = document.createElement('div');
            content.className = 'interactive-demo-content';
            content.style.cssText = 'background: #fff; color: #222; border-radius: 0 0 12px 12px; overflow: visible;';

            let demoHtml = item.html || '<p>No content</p>';

            // If it's already a full HTML document, inject auto-sizer into it.
            // If it's just a snippet, wrap it in a minimal document.
            const isFullDoc = /<!DOCTYPE|<html[\s>]/i.test(demoHtml);
            // Height-reporting script injected into every iframe so it measures
            // its own content height from inside (much more reliable than
            // measuring scrollHeight from outside) and posts it to the parent.
            const autoSizer = `<script>
(function(){
  var last=0,debounce=null;
  function report(){
    var h=Math.max(document.body.scrollHeight,document.documentElement.scrollHeight,60);
    if(Math.abs(h-last)<5)return;
    last=h;
    parent.postMessage({aetherIframeHeight:${idx},height:h},'*');
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
                // Inject auto-sizer before </body> (or </html> if no </body>)
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
            iframe.style.cssText = 'width:100%;border:none;border-radius:0 0 12px 12px;min-height:60px;display:block;background:#fff;';
            iframe.setAttribute('sandbox', 'allow-scripts allow-same-origin');

            // Register this iframe so the message listener can resize it
            window._aetherDemoIframes[idx] = iframe;

            content.appendChild(iframe);
            card.appendChild(header);
            card.appendChild(content);
            container.appendChild(card);
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

                if (pseudocode && code) {
                    // Show tabs to switch between Pseudocode and Python Code
                    tabsHtml = `
                        <div class="algo-tabs" style="display: flex; background: var(--bg-elevated); border-bottom: 1px solid var(--border-color); padding: 0 16px;">
                            <button class="algo-tab-btn active" data-target="pseudocode-${idx}" style="background: none; border: none; padding: 12px 16px; color: var(--text-main); border-bottom: 2px solid var(--primary-color, #7c3aed); font-weight: 600; cursor: pointer; font-size: 0.85rem;">Pseudocode</button>
                            <button class="algo-tab-btn" data-target="python-${idx}" style="background: none; border: none; padding: 12px 16px; color: var(--text-muted); cursor: pointer; font-size: 0.85rem;">Python Code</button>
                        </div>
                    `;
                    blocksHtml = `
                        <div class="algo-blocks">
                            <div id="pseudocode-${idx}" class="algo-block-content">
                                <pre style="margin:0; border-radius:0; border:none;"><code class="language-text">${window.escapeHtml(pseudocode)}</code></pre>
                            </div>
                            <div id="python-${idx}" class="algo-block-content" style="display: none;">
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