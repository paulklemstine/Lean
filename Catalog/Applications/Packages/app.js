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
});
