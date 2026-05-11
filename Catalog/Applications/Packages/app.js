document.addEventListener('DOMContentLoaded', () => {
    const packageList = document.getElementById('package-list');
    const searchInput = document.getElementById('search-input');
    const welcomeScreen = document.getElementById('welcome-screen');
    const packageView = document.getElementById('package-view');
    const mobileToggle = document.getElementById('mobile-toggle');
    const sidebar = document.getElementById('sidebar');
    const tabs = document.querySelectorAll('.tab-btn');
    
    // Lightbox elements
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightbox-img');
    const lightboxCaption = document.getElementById('lightbox-caption');
    const lightboxClose = document.getElementById('lightbox-close');
    const lightboxPrev = document.getElementById('lightbox-prev');
    const lightboxNext = document.getElementById('lightbox-next');
    
    let packages = [];
    let currentPackage = null;
    let currentVizIndex = 0;
    
    // Pyodide State
    let pyodideInstance = null;
    let isPyodideLoading = false;

    // Set marked.js options for KaTeX compatibility if needed
    marked.setOptions({
        breaks: true,
        gfm: true
    });
    
    // Initialize Pyodide asynchronously
    async function initPyodide() {
        if (pyodideInstance || isPyodideLoading) return;
        isPyodideLoading = true;
        try {
            console.log("Loading Pyodide...");
            pyodideInstance = await loadPyodide();
            console.log("Pyodide loaded!");
            
            // Enable run buttons if they exist
            document.querySelectorAll('.run-btn').forEach(btn => {
                btn.disabled = false;
                btn.textContent = 'Run Code';
            });
        } catch (err) {
            console.error("Failed to load Pyodide:", err);
        }
        isPyodideLoading = false;
    }
    
    // Start loading Pyodide immediately
    initPyodide();

    // Theme Toggle Logic
    const themeToggle = document.getElementById('theme-toggle');
    const sunIcon = document.querySelector('.sun-icon');
    const moonIcon = document.querySelector('.moon-icon');
    
    // Check saved theme or default to dark
    const savedTheme = localStorage.getItem('aether-theme') || 'dark';
    if (savedTheme === 'light') {
        document.body.classList.replace('dark-theme', 'light-theme');
        sunIcon.style.display = 'none';
        moonIcon.style.display = 'block';
    }
    
    themeToggle.addEventListener('click', () => {
        if (document.body.classList.contains('dark-theme')) {
            document.body.classList.replace('dark-theme', 'light-theme');
            localStorage.setItem('aether-theme', 'light');
            sunIcon.style.display = 'none';
            moonIcon.style.display = 'block';
        } else {
            document.body.classList.replace('light-theme', 'dark-theme');
            localStorage.setItem('aether-theme', 'dark');
            sunIcon.style.display = 'block';
            moonIcon.style.display = 'none';
        }
    });

    // Mobile sidebar toggle
    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const sidebarOverlay = document.getElementById('sidebar-overlay');

    function openSidebar() {
        sidebar.classList.add('open');
        if (mobileMenuBtn) mobileMenuBtn.classList.add('active');
        if (sidebarOverlay) sidebarOverlay.classList.add('visible');
        document.body.style.overflow = 'hidden';
    }

    function closeSidebar() {
        sidebar.classList.remove('open');
        if (mobileMenuBtn) mobileMenuBtn.classList.remove('active');
        if (sidebarOverlay) sidebarOverlay.classList.remove('visible');
        document.body.style.overflow = '';
    }

    if (mobileToggle) {
        mobileToggle.addEventListener('click', closeSidebar);
    }
    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', () => {
            if (sidebar.classList.contains('open')) {
                closeSidebar();
            } else {
                openSidebar();
            }
        });
    }
    if (sidebarOverlay) {
        sidebarOverlay.addEventListener('click', closeSidebar);
    }

    // Lightbox Logic
    function openLightbox(index) {
        if (!currentPackage || !currentPackage.visualizations) return;
        currentVizIndex = index;
        updateLightbox();
        lightbox.classList.remove('hidden');
        document.body.style.overflow = 'hidden'; // prevent scrolling
    }

    function closeLightbox() {
        lightbox.classList.add('hidden');
        document.body.style.overflow = '';
    }

    function updateLightbox() {
        const viz = currentPackage.visualizations[currentVizIndex];
        let imgContent = '';
        if (viz.file) {
            const isSvg = viz.file.endsWith('.svg');
            const style = isSvg
                ? 'width:100%;max-height:70vh;object-fit:contain;'
                : 'max-width:100%;max-height:70vh;object-fit:contain;';
            imgContent = `<img src="${viz.file}" alt="${viz.name || 'Visualization'}" style="${style}">`;
        } else if (viz.data && viz.data.startsWith('<svg')) {
            const svgUri = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(viz.data);
            imgContent = `<img src="${svgUri}" alt="${viz.name || 'Visualization'}" style="max-width:100%;max-height:70vh;object-fit:contain;">`;
        } else if (viz.data && viz.data.startsWith('data:image')) {
            imgContent = `<img src="${viz.data}" alt="${viz.name || 'Visualization'}" style="max-width:100%;max-height:70vh;object-fit:contain;">`;
        }
        lightboxImg.innerHTML = imgContent;
        lightboxCaption.textContent = viz.name || 'Visualization';
        
        // Hide arrows if only 1 image
        const multiple = currentPackage.visualizations.length > 1;
        lightboxPrev.style.display = multiple ? 'block' : 'none';
        lightboxNext.style.display = multiple ? 'block' : 'none';
    }

    function nextLightbox() {
        if (!currentPackage || !currentPackage.visualizations) return;
        currentVizIndex = (currentVizIndex + 1) % currentPackage.visualizations.length;
        updateLightbox();
    }

    function prevLightbox() {
        if (!currentPackage || !currentPackage.visualizations) return;
        currentVizIndex = (currentVizIndex - 1 + currentPackage.visualizations.length) % currentPackage.visualizations.length;
        updateLightbox();
    }

    lightboxClose.addEventListener('click', closeLightbox);
    lightboxPrev.addEventListener('click', prevLightbox);
    lightboxNext.addEventListener('click', nextLightbox);
    lightbox.addEventListener('click', (e) => {
        if (e.target === lightbox) closeLightbox();
    });

    document.addEventListener('keydown', (e) => {
        if (!lightbox.classList.contains('hidden')) {
            if (e.key === 'Escape') closeLightbox();
            if (e.key === 'ArrowRight') nextLightbox();
            if (e.key === 'ArrowLeft') prevLightbox();
        }
    });

    // Handle clicks on main content to close sidebar on mobile
    document.getElementById('main-content').addEventListener('click', () => {
        if (window.innerWidth <= 768 && sidebar.classList.contains('open')) {
            closeSidebar();
        }
    });

    // Tab switching
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // Remove active class from all
            tabs.forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
            
            // Add active to clicked
            tab.classList.add('active');
            const targetId = `tab-${tab.dataset.tab}`;
            document.getElementById(targetId).classList.add('active');
        });
    });

    // Load index from bundled JS file
    if (window.PACKAGE_INDEX) {
        packages = window.PACKAGE_INDEX;
        renderSidebar(packages);
    } else {
        packageList.innerHTML = '<li class="nav-item"><div class="nav-item-title text-red">Please run update_index.py to bundle packages</div></li>';
    }

    // Search filter
    searchInput.addEventListener('input', (e) => {
        const term = e.target.value.toLowerCase();
        const filtered = packages.filter(p => 
            p.title?.toLowerCase().includes(term) || 
            p.domain?.toLowerCase().includes(term)
        );
        renderSidebar(filtered);
    });

    function renderSidebar(pkgArray) {
        packageList.innerHTML = '';
        if (pkgArray.length === 0) {
            packageList.innerHTML = '<li class="nav-item"><div class="nav-item-title" style="color:var(--text-muted)">No packages found.</div></li>';
            return;
        }

        pkgArray.forEach(pkg => {
            const li = document.createElement('li');
            li.className = 'nav-item';
            
            // Format date and time nicely
            const d = new Date(pkg.date);
            const dateStr = !isNaN(d) ? d.toLocaleDateString() : 'Recent';
            const timeStr = !isNaN(d) ? d.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'}) : '';

            li.innerHTML = `
                <div class="nav-item-title">${pkg.title || 'Untitled Research'}</div>
                <div class="nav-item-meta">
                    <span>${pkg.domain || 'General'}</span>
                    <span class="nav-item-datetime">${dateStr}${timeStr ? `<br><span class="nav-item-time">${timeStr}</span>` : ''}</span>
                </div>
            `;
            
            li.addEventListener('click', () => {
                document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
                li.classList.add('active');
                loadPackage(pkg.filename);
                if (window.innerWidth <= 768) closeSidebar();
            });
            
            packageList.appendChild(li);
        });
    }

    function loadPackage(filename) {
        if (!window.PACKAGE_DB || !window.PACKAGE_DB[filename]) {
            alert(`Error: ${filename} not found in packages_db.js`);
            return;
        }
        
        try {
            const data = window.PACKAGE_DB[filename];
            currentPackage = data;
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
    }

    function renderPackage(data, filename) {
        // Header
        document.getElementById('pkg-title').textContent = data.title || 'Untitled Research';
        document.getElementById('pkg-domain').textContent = data.domain || 'General';
        
        // Find date and time from index
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
                card.addEventListener('click', () => openLightbox(index));

                // Prefer extracted file over inline data
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
        renderInteractiveDemos('content-demos', data.demos);

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
                    <pre><code>${escapeHtml(item[codeField] || '')}</code></pre>
                `;
                container.appendChild(card);
            });
        } else {
            container.innerHTML = '<p style="color:var(--text-muted)">No data provided for this section.</p>';
        }
    }

    function buildLocalModuleCode(code, pkgData) {
        // Build Python code to register all local modules needed by a demo.
        // Handles 'from algorithms import ...', 'from demo import ...', etc.
        // Priority: pkg.modules > algorithms[].code > pseudocode stubs.
        // Returns the preamble code to prepend before the demo code.

        // Detect local module imports — only 'algorithms' and 'demo' are local modules
        const knownLocalModules = ['algorithms', 'demo'];
        const localModuleRe = /^from\s+(\w+)\s+import\s+/gm;
        const bareImportRe = /^\s*import\s+(\w+)\s*$/gm;
        const neededModules = new Set();
        let match;
        while ((match = localModuleRe.exec(code)) !== null) {
            if (knownLocalModules.includes(match[1])) {
                neededModules.add(match[1]);
            }
        }
        while ((match = bareImportRe.exec(code)) !== null) {
            if (knownLocalModules.includes(match[1])) {
                neededModules.add(match[1]);
            }
        }

        if (neededModules.size === 0) return '';

        let preamble = '';

        // For each needed module, try to find real source code
        for (const modName of neededModules) {
            // 1. Check pkg.modules (preferred: full source from extraction)
            if (pkgData && pkgData.modules && pkgData.modules[modName]) {
                preamble += `# --- ${modName} module (from Aristotle output) ---\n`;
                preamble += pkgData.modules[modName];
                preamble += `\n\n# --- Register ${modName} module ---\n`;
                preamble += 'import types as _types_' + modName + '\n';
                preamble += 'import sys as _sys_' + modName + '\n';
                preamble += `_mod_${modName} = _types_${modName}.ModuleType("${modName}")\n`;
                preamble += `for _n in list(globals().keys()):\n`;
                preamble += `    if not _n.startswith("_") and _n not in ("_types_${modName}", "_sys_${modName}", "_mod_${modName}"):\n`;
                preamble += `        try:\n`;
                preamble += `            setattr(_mod_${modName}, _n, globals()[_n])\n`;
                preamble += `        except Exception:\n`;
                preamble += `            pass\n`;
                preamble += `_sys_${modName}.modules["${modName}"] = _mod_${modName}\n`;
                preamble += `# --- End ${modName} module ---\n\n`;
                continue;
            }

            // 2. For 'algorithms', check algorithms[].code
            if (modName === 'algorithms' && pkgData && pkgData.algorithms) {
                const codeParts = [];
                const seenCode = new Set();
                for (const algo of pkgData.algorithms) {
                    if (algo.code && !seenCode.has(algo.code)) {
                        seenCode.add(algo.code);
                        codeParts.push(algo.code.trim());
                    }
                }
                if (codeParts.length > 0) {
                    preamble += `# --- algorithms module (from code fields) ---\n`;
                    preamble += codeParts.join('\n\n');
                    preamble += `\n\n# --- Register algorithms module ---\n`;
                    preamble += 'import types as _types_algorithms\n';
                    preamble += 'import sys as _sys_algorithms\n';
                    preamble += '_mod_algorithms = _types_algorithms.ModuleType("algorithms")\n';
                    preamble += 'for _n in list(globals().keys()):\n';
                    preamble += '    if not _n.startswith("_") and _n not in ("_types_algorithms", "_sys_algorithms", "_mod_algorithms"):\n';
                    preamble += '        try:\n';
                    preamble += '            setattr(_mod_algorithms, _n, globals()[_n])\n';
                    preamble += '        except Exception:\n';
                    preamble += '            pass\n';
                    preamble += '_sys_algorithms.modules["algorithms"] = _mod_algorithms\n';
                    preamble += '# --- End algorithms module ---\n\n';
                    continue;
                }
            }

            // 3. Fall back to stubs for 'algorithms' only
            if (modName === 'algorithms') {
                preamble += buildAlgorithmStubs(code, pkgData);
                continue;
            }

            // 4. 'demo' module with no source — nothing we can do
            console.warn(`No source code for module '${modName}'`);
        }

        return preamble;
    }

    function buildAlgorithmStubs(code, pkgData) {
        // Fallback: build stub definitions for 'algorithms' module from pseudocode.
        // Only used when no real source code is available.
        const fromImportRe = /^from\s+algorithms\s+import\s+(.+?)$/gm;
        const bareImportRe = /^\s*import\s+algorithms\b/m;

        const importedNames = new Set();
        let match;
        while ((match = fromImportRe.exec(code)) !== null) {
            match[1].split(',').forEach(name => {
                const clean = name.trim().replace(/\s+as\s+\w+$/, '').trim();
                if (clean) importedNames.add(clean);
            });
        }

        let stubs = '# --- Auto-generated algorithm stubs ---\n';

        if (importedNames.size === 0 && bareImportRe.test(code)) {
            stubs += 'import types\nalgorithms = types.ModuleType("algorithms")\n';
            stubs += 'import sys\nsys.modules["algorithms"] = algorithms\n';
            return stubs;
        }

        if (importedNames.size === 0) return '';

        const pseudocodeMap = {};
        if (pkgData && pkgData.algorithms) {
            pkgData.algorithms.forEach(algo => {
                const name = algo.name ? algo.name.replace(/[^a-zA-Z0-9_]/g, '_') : '';
                if (name && algo.pseudocode) {
                    pseudocodeMap[name] = algo.pseudocode;
                }
            });
        }

        for (const name of importedNames) {
            const isClass = /^[A-Z]/.test(name);

            if (isClass) {
                stubs += `class ${name}:\n`;
                stubs += `    def __init__(self, *args, **kwargs):\n`;
                stubs += `        print(f"[stub] ${name} created")\n`;
                stubs += `    def __getattr__(self, attr):\n`;
                stubs += `        return lambda *a, **kw: print(f"[stub] ${name}.{attr} called")\n`;
            } else {
                const pcode = pseudocodeMap[name];
                if (pcode) {
                    let pyCode = pcode
                        .replace(/^(function|procedure|def)\s+/i, '')
                        .replace(/^return\s+/gm, 'return ')
                        .trim();
                    stubs += `def ${name}(*args, **kwargs):\n`;
                    stubs += `    # Algorithm: ${name}\n`;
                    const lines = pyCode.split('\n');
                    for (const line of lines) {
                        const trimmed = line.trim();
                        if (trimmed) {
                            stubs += `    ${trimmed}\n`;
                        }
                    }
                    stubs += `    pass  # fallback\n\n`;
                } else {
                    stubs += `def ${name}(*args, **kwargs):\n`;
                    stubs += `    # [auto-stub] ${name} - see Algorithms tab for details\n`;
                    stubs += `    import math, random\n`;
                    stubs += `    if args:\n`;
                    stubs += `        if isinstance(args[0], (list, tuple)) and len(args) >= 2:\n`;
                    stubs += `            return random.randint(1, 100)\n`;
                    stubs += `        if isinstance(args[0], int):\n`;
                    stubs += `            return random.randint(1, 100)\n`;
                    stubs += `    return []\n\n`;
                }
            }
        }

        stubs += 'import types as _types\n';
        stubs += '_alg_mod = _types.ModuleType("algorithms")\n';
        for (const name of importedNames) {
            stubs += `_alg_mod.${name} = ${name}\n`;
        }
        stubs += 'import sys as _sys\n';
        stubs += '_sys.modules["algorithms"] = _alg_mod\n';
        stubs += '# --- End auto-generated stubs ---\n\n';

        return stubs;
    }

    function renderInteractiveDemos(containerId, items) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';
        
        if (items && items.length > 0) {
            items.forEach(item => {
                const card = document.createElement('div');
                card.className = 'code-card';
                
                const header = document.createElement('div');
                header.className = 'code-header';
                
                const title = document.createElement('span');
                title.className = 'code-title';
                title.textContent = item.name || 'Interactive Python Demo';
                
                const runBtn = document.createElement('button');
                runBtn.className = 'run-btn';
                if (!pyodideInstance) {
                    runBtn.disabled = true;
                    runBtn.textContent = 'Loading Engine...';
                } else {
                    runBtn.textContent = 'Run Code';
                }
                
                header.appendChild(title);
                header.appendChild(runBtn);
                
                const editor = document.createElement('textarea');
                editor.className = 'code-editor';
                editor.spellcheck = false;
                editor.value = item.code || '';
                
                const output = document.createElement('pre');
                output.className = 'code-output hidden';
                
                runBtn.addEventListener('click', async () => {
                    if (!pyodideInstance) return;

                    output.classList.remove('hidden');
                    output.classList.remove('error');
                    output.textContent = 'Preparing environment...';
                    runBtn.disabled = true;

                    let stdout = "";
                    pyodideInstance.setStdout({ batched: (msg) => { stdout += msg + "\n"; } });
                    pyodideInstance.setStderr({ batched: (msg) => { stdout += msg + "\n"; } });

                    try {
                        let codeToRun = editor.value;

                        // If the demo imports local modules (algorithms, demo, etc.),
                        // inject their source code and register them in Pyodide.
                        const localModuleRe = /^(from|import)\s+(algorithms|demo)\b/m;
                        if (localModuleRe.test(codeToRun)) {
                            const moduleCode = buildLocalModuleCode(codeToRun, currentPackage);
                            // Remove ALL local module import statements by processing line-by-line.
                            // This handles single-line, multi-line (parenthesized), and bare imports.
                            const localMods = ['algorithms', 'demo'];
                            const lines = codeToRun.split('\n');
                            const filtered = [];
                            let inLocalImport = false;
                            for (const line of lines) {
                                if (inLocalImport) {
                                    // Still inside a multi-line from X import (...) block
                                    if (line.includes(')')) {
                                        inLocalImport = false;
                                    }
                                    continue;
                                }
                                // Check if this line starts a local module import
                                const trimmed = line.trim();
                                let skip = false;
                                for (const mod of localMods) {
                                    if (trimmed.startsWith('from ' + mod + ' import ') || trimmed.startsWith('import ' + mod)) {
                                        skip = true;
                                        // Check if multi-line (opens paren without closing it)
                                        if (trimmed.includes('(') && !trimmed.includes(')')) {
                                            inLocalImport = true;
                                        }
                                        break;
                                    }
                                }
                                if (!skip) {
                                    filtered.push(line);
                                }
                            }
                            codeToRun = moduleCode + '\n' + filtered.join('\n');
                        }

                        // Automatically load any imports (like numpy, pandas, etc.)
                        await pyodideInstance.loadPackagesFromImports(codeToRun);

                        output.textContent = 'Running...';

                        const result = await pyodideInstance.runPythonAsync(codeToRun);
                        if (result !== undefined && result !== null) {
                            stdout += result + "\n";
                        }
                        output.textContent = stdout || "Done. (No output)";
                    } catch (err) {
                        output.classList.add('error');
                        output.textContent = stdout + "\n" + err.toString();
                    } finally {
                        runBtn.disabled = false;
                    }
                });
                
                card.appendChild(header);
                card.appendChild(editor);
                card.appendChild(output);
                container.appendChild(card);
            });
        } else {
            container.innerHTML = '<p style="color:var(--text-muted)">No interactive demos provided.</p>';
        }
    }

    function escapeHtml(unsafe) {
        return unsafe
             .replace(/&/g, "&amp;")
             .replace(/</g, "&lt;")
             .replace(/>/g, "&gt;")
             .replace(/"/g, "&quot;")
             .replace(/'/g, "&#039;");
    }

    // ═══════════════════════════════════════════════
    // AETHER — Alien Rainbow Crystal City in the Backrooms
    // ═══════════════════════════════════════════════
    (function initBackrooms() {
        const canvas = document.getElementById('backrooms-canvas');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        if (!ctx) return;

        let W, H;
        let animating = false;
        function resize() {
            W = canvas.width = canvas.offsetWidth;
            H = canvas.height = canvas.offsetHeight;
        }
        resize();
        window.addEventListener('resize', resize);

        let _seed = 0xAE7BE11;
        function rand() {
            _seed |= 0; _seed = _seed + 0x6D2B79F5 | 0;
            let t = Math.imul(_seed ^ _seed >>> 15, 1 | _seed);
            t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
            return ((t ^ t >>> 14) >>> 0) / 4294967296;
        }
        function rr(a, b) { return a + rand() * (b - a); }

        // ═══════════════════════════════════════
        // WORLD — grid maze + organic tendril tunnels + spiral rooms
        // ═══════════════════════════════════════
        const CELL = 90;
        const COLS = 36, ROWS = 36;
        const worldW = COLS * CELL, worldH = ROWS * CELL;

        // Base maze: 0=void, 1=room, 2=corridor
        const grid = Array.from({ length: ROWS }, () => Array(COLS).fill(0));
        const vis = Array.from({ length: ROWS }, () => Array(COLS).fill(false));

        // Recursive backtracker
        (function carveMaze(sx, sy) {
            const stack = [[sx, sy]];
            vis[sy][sx] = true; grid[sy][sx] = 1;
            while (stack.length) {
                const [cx, cy] = stack[stack.length - 1];
                const dirs = [[0,-2],[0,2],[-2,0],[2,0]];
                for (let i = dirs.length - 1; i > 0; i--) {
                    const j = Math.floor(rand() * (i + 1));
                    [dirs[i], dirs[j]] = [dirs[j], dirs[i]];
                }
                let ok = false;
                for (const [dx, dy] of dirs) {
                    const nx = cx + dx, ny = cy + dy;
                    if (nx >= 1 && nx < COLS - 1 && ny >= 1 && ny < ROWS - 1 && !vis[ny][nx]) {
                        grid[cy + dy / 2][cx + dx / 2] = 2;
                        grid[ny][nx] = 1; vis[ny][nx] = true;
                        stack.push([nx, ny]); ok = true; break;
                    }
                }
                if (!ok) stack.pop();
            }
        })(1, 1);

        // Widen: merge clusters into big rooms
        for (let y = 2; y < ROWS - 2; y += 3) {
            for (let x = 2; x < COLS - 2; x += 3) {
                if (grid[y][x] === 0 || rand() > 0.4) continue;
                const sz = rand() > 0.5 ? 2 : 1;
                for (let dy = -sz; dy <= sz; dy++)
                    for (let dx = -sz; dx <= sz; dx++)
                        if (y+dy > 0 && y+dy < ROWS-1 && x+dx > 0 && x+dx < COLS-1)
                            grid[y+dy][x+dx] = 1;
            }
        }

        // Remove awkward single-cell walls
        for (let y = 1; y < ROWS - 1; y++)
            for (let x = 1; x < COLS - 1; x++) {
                if (grid[y][x] !== 0) continue;
                let n = 0;
                for (const [dx, dy] of [[0,1],[0,-1],[1,0],[-1,0]])
                    if (grid[y+dy][x+dx] !== 0) n++;
                if (n >= 3 && rand() > 0.3) grid[y][x] = 2;
            }

        // ═══════════════════════════════════════
        // SPIRALS — carved into the grid
        // ═══════════════════════════════════════
        const spirals = [];
        const SPIRAL_COUNT = 4;
        for (let s = 0; s < SPIRAL_COUNT; s++) {
            const scx = Math.floor(rr(4, COLS - 4));
            const scy = Math.floor(rr(4, ROWS - 4));
            const arms = Math.floor(rr(2, 5));
            const maxR = Math.floor(rr(3, 6));
            const turns = rr(1.5, 3);
            const pts = [];
            const steps = 80;
            for (let i = 0; i < steps; i++) {
                const t = i / steps;
                const angle = t * turns * Math.PI * 2;
                const r = t * maxR;
                const gx = Math.round(scx + Math.cos(angle) * r);
                const gy = Math.round(scy + Math.sin(angle) * r);
                if (gx >= 1 && gx < COLS - 1 && gy >= 1 && gy < ROWS - 1) {
                    grid[gy][gx] = 1;
                    pts.push({ x: gx, y: gy });
                }
            }
            spirals.push({ cx: scx, cy: scy, maxR, arms, turns });
        }

        // ═══════════════════════════════════════
        // TENDRIL TUNNELS — organic curves through walls
        // ═══════════════════════════════════════
        const tendrils = [];
        const TENDRIL_COUNT = 8;
        for (let t = 0; t < TENDRIL_COUNT; t++) {
            const sx = Math.floor(rr(3, COLS - 3));
            const sy = Math.floor(rr(3, ROWS - 3));
            const ex = Math.floor(rr(3, COLS - 3));
            const ey = Math.floor(rr(3, ROWS - 3));
            const pts = [];
            const steps = 40;
            let px = sx, py = sy;
            for (let i = 0; i < steps; i++) {
                const tx = sx + (ex - sx) * (i / steps);
                const ty = sy + (ey - sy) * (i / steps);
                px += (tx - px) * 0.3 + (rand() - 0.5) * 2.5;
                py += (ty - py) * 0.3 + (rand() - 0.5) * 2.5;
                const gx = Math.round(Math.max(1, Math.min(COLS - 2, px)));
                const gy = Math.round(Math.max(1, Math.min(ROWS - 2, py)));
                grid[gy][gx] = 2;
                // Widen tendril slightly
                for (const [dx, dy] of [[1,0],[-1,0],[0,1],[0,-1]])
                    if (gy+dy > 0 && gy+dy < ROWS-1 && gx+dx > 0 && gx+dx < COLS-1 && rand() > 0.4)
                        grid[gy+dy][gx+dx] = 2;
                pts.push({ x: gx * CELL + CELL / 2, y: gy * CELL + CELL / 2 });
            }
            tendrils.push(pts);
        }

        // ═══════════════════════════════════════
        // CRYSTALS — rainbow, everywhere
        // ═══════════════════════════════════════
        const HUES = [
            { h: '#ff4466', g: 'rgba(255,68,102,', r: 0 },
            { h: '#ff8844', g: 'rgba(255,136,68,', r: 32 },
            { h: '#ffcc22', g: 'rgba(255,204,34,', r: 51 },
            { h: '#44ff88', g: 'rgba(68,255,136,', r: 136 },
            { h: '#22ccff', g: 'rgba(34,204,255,', r: 195 },
            { h: '#8844ff', g: 'rgba(136,68,255,', r: 270 },
            { h: '#ff44cc', g: 'rgba(255,68,204,', r: 320 },
            { h: '#ffffff', g: 'rgba(255,255,255,', r: -1 }
        ];

        const crystals = [];
        for (let y = 1; y < ROWS - 1; y++) {
            for (let x = 1; x < COLS - 1; x++) {
                if (grid[y][x] === 0) continue;
                const hash = ((x * 73856093) ^ (y * 19349663)) >>> 0;
                if (hash % 5 !== 0) continue; // ~20% of open cells
                const cx = x * CELL + CELL / 2 + rr(-CELL * 0.2, CELL * 0.2);
                const cy = y * CELL + CELL / 2 + rr(-CELL * 0.2, CELL * 0.2);
                const hue = HUES[hash % HUES.length] || HUES[0];
                const size = rr(12, 50);
                crystals.push({
                    x: cx, y: cy, size,
                    hue: hue.h, glowBase: hue.g,
                    facets: Math.floor(rr(4, 8)),
                    rot: rr(0, Math.PI * 2),
                    rayCount: Math.floor(rr(4, 10)),
                    cluster: hash % 3 === 0 // some are clusters
                });
                // Clusters: 2-3 small crystals nearby
                if (hash % 3 === 0) {
                    for (let c = 0; c < Math.floor(rr(2, 4)); c++) {
                        const ch = HUES[(hash + c + 1) % HUES.length] || HUES[0];
                        crystals.push({
                            x: cx + rr(-25, 25), y: cy + rr(-25, 25),
                            size: rr(6, 20), hue: ch.h, glowBase: ch.g,
                            facets: Math.floor(rr(3, 6)),
                            rot: rr(0, Math.PI * 2),
                            rayCount: Math.floor(rr(3, 7)),
                            cluster: false
                        });
                    }
                }
            }
        }

        // ═══════════════════════════════════════
        // LIGHTS — prismatic, reflected, volumetric
        // ═══════════════════════════════════════
        const lightSources = [];
        for (let y = 1; y < ROWS - 1; y++) {
            for (let x = 1; x < COLS - 1; x++) {
                if (grid[y][x] === 0) continue;
                const hash = ((x * 73856093) ^ (y * 19349663)) >>> 0;
                if (hash % 4 !== 0) continue; // ~25%
                const cx = x * CELL + CELL / 2;
                const cy = y * CELL + CELL / 2;
                const hueIdx = ((hash >>> 4) % (HUES.length - 1));
                const hue = HUES[hueIdx] || HUES[0];
                lightSources.push({
                    x: cx, y: cy,
                    hue: hue.h, glowBase: hue.g,
                    horiz: hash % 2 === 0,
                    len: rr(CELL * 0.5, CELL * 0.8)
                });
            }
        }

        // ═══════════════════════════════════════
        // CAMERA
        // ═══════════════════════════════════════
        let camX = worldW / 2, camY = worldH / 2, camZoom = 1.0, time = 0;

        function getCameraState(t) {
            const c = t * 0.022, z = t * 0.011;
            return {
                x: worldW / 2 + Math.sin(c * 0.7) * worldW * 0.35 + Math.sin(c * 1.3) * worldW * 0.12,
                y: worldH / 2 + Math.cos(c * 0.5) * worldH * 0.35 + Math.cos(c * 1.1) * worldH * 0.12,
                zoom: Math.max(0.18, 0.5 + Math.sin(z) * 0.38 + Math.sin(z * 2.1) * 0.14)
            };
        }

        // ═══════════════════════════════════════
        // DRAWING
        // ═══════════════════════════════════════

        // Floor colors per region — shifting rainbow tint on base
        function floorColor(gx, gy, isRoom) {
            const angle = Math.atan2(gy - ROWS / 2, gx - COLS / 2);
            const dist = Math.hypot(gx - COLS / 2, gy - ROWS / 2);
            const hue = ((angle / Math.PI * 180) + 360 + dist * 3) % 360;
            // Desaturated rainbow on dark base
            const s = isRoom ? 0.25 : 0.15;
            const l = isRoom ? 0.18 : 0.12;
            return `hsl(${hue}, ${s * 100}%, ${l * 100}%)`;
        }

        function drawFloor(vl, vr, vt, vb) {
            const minC = Math.max(0, Math.floor(vl / CELL));
            const maxC = Math.min(COLS - 1, Math.ceil(vr / CELL));
            const minR = Math.max(0, Math.floor(vt / CELL));
            const maxR = Math.min(ROWS - 1, Math.ceil(vb / CELL));

            for (let y = minR; y <= maxR; y++) {
                for (let x = minC; x <= maxC; x++) {
                    if (grid[y][x] === 0) continue;
                    const px = x * CELL, py = y * CELL;
                    const isRoom = grid[y][x] === 1;

                    // Rainbow-tinted floor
                    ctx.fillStyle = floorColor(x, y, isRoom);
                    ctx.fillRect(px, py, CELL, CELL);

                    // Grid lines — repeating floorplan
                    const angle = Math.atan2(y - ROWS / 2, x - COLS / 2);
                    const hue = ((angle / Math.PI * 180) + 360) % 360;
                    ctx.strokeStyle = `hsla(${hue}, 30%, 25%, 0.12)`;
                    ctx.lineWidth = 0.5;
                    ctx.strokeRect(px, py, CELL, CELL);
                    ctx.beginPath();
                    ctx.moveTo(px + CELL / 2, py); ctx.lineTo(px + CELL / 2, py + CELL);
                    ctx.moveTo(px, py + CELL / 2); ctx.lineTo(px + CELL, py + CELL / 2);
                    ctx.stroke();
                }
            }
        }

        function drawTendrils() {
            for (const pts of tendrils) {
                if (pts.length < 3) continue;
                // Glowing tendril path
                for (const pass of [{w: 30, a: 0.03}, {w: 14, a: 0.06}, {w: 4, a: 0.15}]) {
                    ctx.strokeStyle = `rgba(180, 120, 255, ${pass.a})`;
                    ctx.lineWidth = pass.w;
                    ctx.lineCap = 'round';
                    ctx.lineJoin = 'round';
                    ctx.beginPath();
                    ctx.moveTo(pts[0].x, pts[0].y);
                    for (let i = 1; i < pts.length; i++) {
                        const prev = pts[i - 1], cur = pts[i];
                        const mx = (prev.x + cur.x) / 2, my = (prev.y + cur.y) / 2;
                        ctx.quadraticCurveTo(prev.x, prev.y, mx, my);
                    }
                    ctx.lineTo(pts[pts.length - 1].x, pts[pts.length - 1].y);
                    ctx.stroke();
                }
            }
        }

        function drawSpirals() {
            for (const sp of spirals) {
                const cx = sp.cx * CELL + CELL / 2;
                const cy = sp.cy * CELL + CELL / 2;
                const maxPx = sp.maxR * CELL;
                // Draw spiral arm lines
                ctx.strokeStyle = 'rgba(120, 200, 255, 0.06)';
                ctx.lineWidth = 2;
                for (let arm = 0; arm < sp.arms; arm++) {
                    const offset = (arm / sp.arms) * Math.PI * 2;
                    ctx.beginPath();
                    for (let i = 0; i <= 60; i++) {
                        const t = i / 60;
                        const angle = t * sp.turns * Math.PI * 2 + offset;
                        const r = t * maxPx;
                        const px = cx + Math.cos(angle) * r;
                        const py = cy + Math.sin(angle) * r;
                        if (i === 0) ctx.moveTo(px, py);
                        else ctx.lineTo(px, py);
                    }
                    ctx.stroke();
                }
                // Center glow
                const grd = ctx.createRadialGradient(cx, cy, 0, cx, cy, maxPx * 0.3);
                grd.addColorStop(0, 'rgba(120, 200, 255, 0.06)');
                grd.addColorStop(1, 'rgba(120, 200, 255, 0)');
                ctx.fillStyle = grd;
                ctx.beginPath();
                ctx.arc(cx, cy, maxPx * 0.3, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        function drawWalls(vl, vr, vt, vb) {
            const minC = Math.max(0, Math.floor(vl / CELL) - 1);
            const maxC = Math.min(COLS - 1, Math.ceil(vr / CELL) + 1);
            const minR = Math.max(0, Math.floor(vt / CELL) - 1);
            const maxR = Math.min(ROWS - 1, Math.ceil(vb / CELL) + 1);
            const segs = [];
            for (let y = minR; y <= maxR; y++)
                for (let x = minC; x <= maxC; x++) {
                    if (grid[y][x] === 0) continue;
                    const px = x * CELL, py = y * CELL;
                    if (y === 0 || grid[y - 1][x] === 0) segs.push([px, py, px + CELL, py, x, y]);
                    if (y === ROWS - 1 || grid[y + 1][x] === 0) segs.push([px, py + CELL, px + CELL, py + CELL, x, y]);
                    if (x === 0 || grid[y][x - 1] === 0) segs.push([px, py, px, py + CELL, x, y]);
                    if (x === COLS - 1 || grid[y][x + 1] === 0) segs.push([px + CELL, py, px + CELL, py + CELL, x, y]);
                }
            // Shadow
            ctx.strokeStyle = 'rgba(5, 3, 15, 0.7)';
            ctx.lineWidth = 14; ctx.lineCap = 'square';
            ctx.beginPath();
            for (const s of segs) { ctx.moveTo(s[0] + 3, s[1] + 3); ctx.lineTo(s[2] + 3, s[3] + 3); }
            ctx.stroke();
            // Wall face — prismatic tint
            for (const s of segs) {
                const angle = Math.atan2(s[3] - s[1], s[2] - s[0]);
                const hue = ((angle / Math.PI * 180) + 360 + s[4] * 5) % 360;
                ctx.strokeStyle = `hsl(${hue}, 20%, 18%)`;
                ctx.lineWidth = 8; ctx.lineCap = 'square';
                ctx.beginPath();
                ctx.moveTo(s[0], s[1]); ctx.lineTo(s[2], s[3]);
                ctx.stroke();
                // Inner highlight
                ctx.strokeStyle = `hsl(${hue}, 35%, 32%)`;
                ctx.lineWidth = 3;
                ctx.beginPath();
                ctx.moveTo(s[0], s[1]); ctx.lineTo(s[2], s[3]);
                ctx.stroke();
            }
        }

        function drawLightSources() {
            for (const l of lightSources) {
                ctx.save();
                ctx.translate(l.x, l.y);
                if (!l.horiz) ctx.rotate(Math.PI / 2);
                // Tube
                ctx.fillStyle = l.hue;
                ctx.globalAlpha = 0.85;
                ctx.fillRect(-l.len / 2, -3, l.len, 6);
                ctx.globalAlpha = 1;
                // Brackets
                ctx.fillStyle = '#444';
                ctx.fillRect(-l.len / 2 - 2, -5, 4, 10);
                ctx.fillRect(l.len / 2 - 2, -5, 4, 10);
                ctx.restore();

                // Volumetric light pool
                const poolR = CELL * 2;
                const grd = ctx.createRadialGradient(l.x, l.y, 8, l.x, l.y, poolR);
                grd.addColorStop(0, l.glowBase + '0.09)');
                grd.addColorStop(0.3, l.glowBase + '0.04)');
                grd.addColorStop(0.7, l.glowBase + '0.01)');
                grd.addColorStop(1, l.glowBase + '0)');
                ctx.fillStyle = grd;
                ctx.beginPath();
                ctx.ellipse(l.x, l.y, poolR, poolR * 0.7, l.horiz ? 0 : Math.PI / 2, 0, Math.PI * 2);
                ctx.fill();

                // Light rays
                ctx.save();
                ctx.translate(l.x, l.y);
                for (let r = 0; r < 6; r++) {
                    const a = r * Math.PI / 3 + (l.horiz ? 0 : Math.PI / 6);
                    const len = CELL * 1.8;
                    ctx.strokeStyle = l.glowBase + '0.018)';
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(Math.cos(a) * len, Math.sin(a) * len);
                    ctx.stroke();
                }
                ctx.restore();
            }
        }

        function drawCrystals() {
            for (const c of crystals) {
                ctx.save();
                ctx.translate(c.x, c.y);
                ctx.rotate(c.rot);

                // Outer glow
                const gr = c.size * 3;
                const grd = ctx.createRadialGradient(0, 0, 0, 0, 0, gr);
                grd.addColorStop(0, c.glowBase + '0.18)');
                grd.addColorStop(0.4, c.glowBase + '0.06)');
                grd.addColorStop(1, c.glowBase + '0)');
                ctx.fillStyle = grd;
                ctx.beginPath();
                ctx.arc(0, 0, gr, 0, Math.PI * 2);
                ctx.fill();

                // Crystal body
                const inner = c.size * 0.35;
                ctx.fillStyle = c.hue;
                ctx.globalAlpha = 0.6;
                ctx.beginPath();
                for (let i = 0; i < c.facets; i++) {
                    const a = (i / c.facets) * Math.PI * 2;
                    const r = i % 2 === 0 ? c.size : inner;
                    if (i === 0) ctx.moveTo(Math.cos(a) * r, Math.sin(a) * r);
                    else ctx.lineTo(Math.cos(a) * r, Math.sin(a) * r);
                }
                ctx.closePath();
                ctx.fill();

                // Specular highlight
                ctx.fillStyle = '#ffffff';
                ctx.globalAlpha = 0.35;
                ctx.beginPath();
                for (let i = 0; i < c.facets; i++) {
                    const a = (i / c.facets) * Math.PI * 2 + 0.3;
                    const r = (i % 2 === 0 ? c.size : inner) * 0.45;
                    if (i === 0) ctx.moveTo(Math.cos(a) * r, Math.sin(a) * r);
                    else ctx.lineTo(Math.cos(a) * r, Math.sin(a) * r);
                }
                ctx.closePath();
                ctx.fill();
                ctx.globalAlpha = 1;

                // Refraction rays — rainbow fan
                for (let r = 0; r < c.rayCount; r++) {
                    const a = c.rot + r * (Math.PI * 2 / c.rayCount);
                    const len = c.size * 4;
                    const rHue = HUES[r % HUES.length];
                    ctx.strokeStyle = rHue.g + '0.04)';
                    ctx.lineWidth = 1.5;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(Math.cos(a) * len, Math.sin(a) * len);
                    ctx.stroke();
                }

                // Reflection: mirror crystal ghost below
                ctx.globalAlpha = 0.08;
                ctx.scale(1, -0.4);
                ctx.fillStyle = c.hue;
                ctx.beginPath();
                for (let i = 0; i < c.facets; i++) {
                    const a = (i / c.facets) * Math.PI * 2;
                    const r = i % 2 === 0 ? c.size * 1.5 : inner * 1.5;
                    if (i === 0) ctx.moveTo(Math.cos(a) * r, Math.sin(a) * r);
                    else ctx.lineTo(Math.cos(a) * r, Math.sin(a) * r);
                }
                ctx.closePath();
                ctx.fill();
                ctx.globalAlpha = 1;

                ctx.restore();
            }
        }

        // === RENDER ===
        function render() {
            if (!animating) return;
            time += 0.016;
            const cam = getCameraState(time);
            camX = cam.x; camY = cam.y; camZoom = cam.zoom;

            ctx.clearRect(0, 0, W, H);
            ctx.fillStyle = '#06040a';
            ctx.fillRect(0, 0, W, H);

            ctx.save();
            ctx.translate(W / 2, H / 2);
            ctx.scale(camZoom, camZoom);
            ctx.translate(-camX, -camY);

            const m = CELL * 3;
            const vl = camX - W / (2 * camZoom) - m;
            const vr = camX + W / (2 * camZoom) + m;
            const vt = camY - H / (2 * camZoom) - m;
            const vb = camY + H / (2 * camZoom) + m;

            drawFloor(vl, vr, vt, vb);
            drawTendrils();
            drawSpirals();
            drawWalls(vl, vr, vt, vb);
            drawLightSources();
            drawCrystals();

            // Atmospheric fog — deep violet-black at edges
            const fogR = Math.max(W, H) * 0.5 / camZoom;
            const fg = ctx.createRadialGradient(camX, camY, 0, camX, camY, fogR);
            fg.addColorStop(0, 'rgba(6, 4, 10, 0)');
            fg.addColorStop(0.4, 'rgba(6, 4, 10, 0)');
            fg.addColorStop(0.7, 'rgba(6, 4, 10, 0.5)');
            fg.addColorStop(1, 'rgba(6, 4, 10, 0.96)');
            ctx.fillStyle = fg;
            ctx.fillRect(vl, vt, vr - vl, vb - vt);

            ctx.restore();

            requestAnimationFrame(render);
        }

        const observer = new MutationObserver(() => {
            if (!welcomeScreen.classList.contains('hidden')) {
                resize(); animating = true; requestAnimationFrame(render);
            } else {
                animating = false;
            }
        });
        observer.observe(welcomeScreen, { attributes: true, attributeFilter: ['class'] });

        if (!welcomeScreen.classList.contains('hidden')) {
            animating = true; requestAnimationFrame(render);
        }
    })();
});
