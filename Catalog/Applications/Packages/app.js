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
    let directionsVisible = false;
    const directionsView = document.getElementById('directions-view');
    const directionsGrid = document.getElementById('directions-grid');
    const directionsLink = document.getElementById('nav-directions-link');
    const directionsStatusFilter = document.getElementById('directions-status-filter');
    const directionsDomainFilter = document.getElementById('directions-domain-filter');
    const directionsSearch = document.getElementById('directions-search');
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
    if (window.FUTURE_DIRECTIONS) {
        populateDomainFilter();
    }

    // Periodic refresh: check for new packages every 60 seconds
    setInterval(async () => {
        try {
            const response = await fetch('packages_db.js', { cache: 'no-store' });
            if (!response.ok) return;
            const text = await response.text();
            // Extract PACKAGE_INDEX and PACKAGE_DB via eval in a sandboxed way
            const prevCount = (window.PACKAGE_INDEX || []).length;
            const prevGraphNodes = (window.PACKAGE_GRAPH || {}).nodes?.length || 0;
            // Use Function constructor to eval the new data
            const fn = new Function(text + '; return { INDEX: window.PACKAGE_INDEX, DB: window.PACKAGE_DB, GRAPH: window.PACKAGE_GRAPH, DIRECTIONS: window.FUTURE_DIRECTIONS };');
            const newData = fn();
            if (newData.INDEX && newData.INDEX.length > prevCount) {
                window.PACKAGE_INDEX = newData.INDEX;
                window.PACKAGE_DB = newData.DB;
                packages = newData.INDEX;
                renderSidebar(packages);
                // Add new graph nodes
                if (newData.GRAPH && newData.GRAPH.nodes) {
                    newData.GRAPH.nodes.forEach(n => {
                        if (window.addGraphNode) window.addGraphNode(n);
                    });
                }
            }
            // Always update graph edges (new connections may appear)
            if (newData.GRAPH && newData.GRAPH.edges && newData.GRAPH.edges.length > 0) {
                const newEdges = newData.GRAPH.edges.filter(e =>
                    !(window.PACKAGE_GRAPH?.edges || []).some(oe => oe.source === e.source && oe.target === e.target)
                );
                if (newEdges.length > 0 && window.addGraphEdges) {
                    window.addGraphEdges(newEdges);
                }
                window.PACKAGE_GRAPH = newData.GRAPH;
            }
            // Update future directions if changed
            if (newData.DIRECTIONS && newData.DIRECTIONS.length >= (window.FUTURE_DIRECTIONS || []).length) {
                window.FUTURE_DIRECTIONS = newData.DIRECTIONS;
                populateDomainFilter();
                if (directionsVisible) renderDirectionsView();
            }
        } catch (err) {
            // Silently fail — refresh is best-effort
        }
    }, 60000);

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
            li.dataset.slug = pkg.filename.replace('.json', '');

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

            // Sidebar hover → highlight graph node
            li.addEventListener('mouseenter', () => {
                // Clear any graph-originated sidebar highlights
                document.querySelectorAll('.nav-item.graph-highlight').forEach(el => el.classList.remove('graph-highlight'));
                const node = (window._graphNodes || []).find(n => n.id === li.dataset.slug);
                if (window._setHoveredNode) window._setHoveredNode(node || null);
            });
            li.addEventListener('mouseleave', () => {
                const current = window._getHoveredNode ? window._getHoveredNode() : null;
                if (current && current.id === li.dataset.slug && window._setHoveredNode) {
                    window._setHoveredNode(null);
                }
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
    // AETHER — Knowledge Graph Visualization
    // ═══════════════════════════════════════════════
    (function initKnowledgeGraph() {
        const canvas = document.getElementById('knowledge-graph-canvas') || document.getElementById('backrooms-canvas');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        if (!ctx) return;

        // ─── Data ───
        const graphData = window.PACKAGE_GRAPH || { nodes: [], edges: [] };
        const graphNodes = (graphData.nodes || []).map(n => ({
            ...n,
            x: 0, y: 0, vx: 0, vy: 0,
            radius: 22,
            phase: Math.random() * Math.PI * 2,
            rotSpeed: 0.3 + Math.random() * 0.5,
            rotAngle: Math.random() * Math.PI * 2
        }));
        // Only load provenance edges (factual parent→child from future directions)
        let graphEdges = (graphData.edges || []).filter(e => e.type === 'provenance').map(e => ({
            ...e,
            edgeType: 'provenance'
        }));

        // Fallback: build nodes from PACKAGE_INDEX if no graph data
        if (graphNodes.length === 0 && window.PACKAGE_INDEX) {
            const DOMAIN_SHAPES = {
                'Algebra': 'tetrahedron', 'Bridges': 'icosahedron', 'Computation': 'cube',
                'Cryptography': 'dodecahedron', 'EML': 'octahedron', 'Geometry': 'hexagonal_prism',
                'Logic': 'star_of_david', 'MachineLearning': 'sphere_rings', 'Physics': 'diamond',
                'Pythagorean': 'triangular_prism', 'Speculative': 'pentagonal_prism', 'Tropical': 'star'
            };
            function mulberry32(seed) {
                seed = seed >>> 0;
                return function() {
                    seed = (seed + 0x6D2B79F5) >>> 0;
                    let t = seed ^ (seed >>> 15);
                    t = (t * (t | 1)) >>> 0;
                    t = (t ^ (t + 0x3FB52453)) >>> 0;
                    t = (t ^ (t >>> 13)) >>> 0;
                    return t >>> 0;
                };
            }
            window.PACKAGE_INDEX.forEach(pkg => {
                const slug = pkg.filename.replace('.json', '');
                const rng = mulberry32(slug.split('').reduce((a, c) => a + c.charCodeAt(0), 0));
                graphNodes.push({
                    id: slug, title: pkg.title || slug, domain: pkg.domain || 'Bridges',
                    primary_domain: 'Bridges', shape: DOMAIN_SHAPES[pkg.domain] || 'icosahedron',
                    date: pkg.date || '', hue: (rng() % 360),
                    x: 0, y: 0, vx: 0, vy: 0, radius: 18,
                    phase: rng() / 4294967296 * Math.PI * 2,
                    rotSpeed: 0.3 + (rng() / 4294967296) * 0.5,
                    rotAngle: rng() / 4294967296 * Math.PI * 2
                });
            });
        }

        if (graphNodes.length === 0) return;

        // Expose to sidebar hover handlers
        window._graphNodes = graphNodes;
        window._setHoveredNode = function(node) { hoveredNode = node; };
        window._getHoveredNode = function() { return hoveredNode; };

        // ─── Colors by domain ───
        const DOMAIN_COLORS = {
            'Algebra': { h: 220, s: 80, l: 60 },
            'Bridges': { h: 280, s: 70, l: 65 },
            'Computation': { h: 160, s: 70, l: 50 },
            'Cryptography': { h: 45, s: 80, l: 55 },
            'EML': { h: 190, s: 75, l: 55 },
            'Geometry': { h: 120, s: 60, l: 50 },
            'Logic': { h: 300, s: 70, l: 60 },
            'MachineLearning': { h: 30, s: 80, l: 55 },
            'Physics': { h: 200, s: 80, l: 55 },
            'Pythagorean': { h: 340, s: 70, l: 55 },
            'Speculative': { h: 260, s: 65, l: 60 },
            'Tropical': { h: 10, s: 75, l: 55 }
        };
        function nodeColor(node) {
            const d = node.primary_domain || 'Bridges';
            const c = DOMAIN_COLORS[d] || DOMAIN_COLORS['Bridges'];
            return c;
        }

        // ─── Canvas state ───
        let W, H;
        let animating = false;
        let camera = { x: 0, y: 0, zoom: 1 };
        let dragNode = null;
        let isPanning = false;
        let panStart = { x: 0, y: 0 };
        let mouseDownPos = { x: 0, y: 0 };
        let hasDragged = false;
        let welcomeFaded = false;
        let mouseWorld = { x: 0, y: 0 };
        let mouseScreen = { x: 0, y: 0 };
        let hoveredNode = null;
        let time = 0;

        // ─── Stars (background) ───
        const stars = [];
        for (let i = 0; i < 250; i++) {
            stars.push({
                x: Math.random() * 8000 - 4000,
                y: Math.random() * 8000 - 4000,
                r: 0.3 + Math.random() * 1.2,
                brightness: 0.3 + Math.random() * 0.7,
                twinkleSpeed: 0.5 + Math.random() * 2,
                twinklePhase: Math.random() * Math.PI * 2
            });
        }

        // ─── Edge particles ───
        const edgeParticles = [];
        graphEdges.forEach(e => {
            const count = 2 + Math.floor(Math.random() * 2);
            for (let i = 0; i < count; i++) {
                edgeParticles.push({
                    edge: e,
                    t: Math.random(),
                    speed: 0.002 + Math.random() * 0.004,
                    size: 1 + Math.random() * 1.5
                });
            }
        });

        // ─── Physics ───
        const K_REPEL = 8000;
        const K_SPRING = 0.008;
        const REST_LENGTH = 150;
        const K_GRAVITY = 0.0005;
        const DAMPING = 0.82;
        const NODE_RADIUS = 22;
        const GALAXY_ROTATION = 0.0003;   // Slow overall galaxy spin
        const FLOCK_SEPARATION = 0.4;      // Avoid crowding neighbors
        const FLOCK_ALIGNMENT = 0.02;      // Steer towards average heading
        const FLOCK_COHESION = 0.001;      // Steer towards center of nearby flock
        const FLOCK_RADIUS = 200;          // Perception radius for flocking

        // ─── Cluster detection (connected components via provenance edges) ───
        function findClusters() {
            const clusters = {};
            let clusterId = 0;
            const visited = new Set();
            // Build adjacency from all edges
            const adj = {};
            graphNodes.forEach(n => { adj[n.id] = []; });
            graphEdges.forEach(e => {
                if (adj[e.source]) adj[e.source].push(e.target);
                if (adj[e.target]) adj[e.target].push(e.source);
            });
            // BFS to find connected components
            graphNodes.forEach(n => {
                if (visited.has(n.id)) return;
                const component = [];
                const queue = [n.id];
                while (queue.length) {
                    const cur = queue.shift();
                    if (visited.has(cur)) continue;
                    visited.add(cur);
                    component.push(cur);
                    (adj[cur] || []).forEach(nb => {
                        if (!visited.has(nb)) queue.push(nb);
                    });
                }
                // Each cluster gets a random rotation direction and speed
                const rotation = (Math.random() < 0.5 ? 1 : -1) * (0.0001 + Math.random() * 0.0004);
                component.forEach(id => {
                    clusters[id] = { clusterId, rotation, cx: 0, cy: 0, count: component.length };
                });
                clusterId++;
            });
            // Compute cluster centers
            const clusterSums = {};
            Object.entries(clusters).forEach(([id, c]) => {
                if (!clusterSums[c.clusterId]) clusterSums[c.clusterId] = { sx: 0, sy: 0, n: 0 };
                const node = nodeMap[id];
                if (node) { clusterSums[c.clusterId].sx += node.x; clusterSums[c.clusterId].sy += node.y; clusterSums[c.clusterId].n++; }
            });
            Object.entries(clusters).forEach(([id, c]) => {
                const s = clusterSums[c.clusterId];
                if (s && s.n > 0) { c.cx = s.sx / s.n; c.cy = s.sy / s.n; }
            });
            return clusters;
        }

        function initPositions() {
            const count = graphNodes.length;
            const radius = Math.sqrt(count) * 60;
            graphNodes.forEach((node, i) => {
                const angle = (i / count) * Math.PI * 2 + Math.random() * 0.5;
                const r = radius * (0.5 + Math.random() * 0.5);
                node.x = Math.cos(angle) * r;
                node.y = Math.sin(angle) * r;
                node.vx = 0;
                node.vy = 0;
            });
        }

        function buildNodeMap() {
            const map = {};
            graphNodes.forEach(n => { map[n.id] = n; });
            return map;
        }

        let nodeMap = buildNodeMap();
        let nodeClusters = findClusters();
        let clusterUpdateTimer = 0;

        function simulate() {
            clusterUpdateTimer++;
            // Recompute cluster centers every 60 frames
            if (clusterUpdateTimer % 60 === 0) {
                nodeClusters = findClusters();
            }

            // ─── Galaxy rotation: slowly rotate entire scene ───
            const cosG = Math.cos(GALAXY_ROTATION), sinG = Math.sin(GALAXY_ROTATION);
            graphNodes.forEach(n => {
                if (n === dragNode) return;
                const nx = n.x * cosG - n.y * sinG;
                const ny = n.x * sinG + n.y * cosG;
                n.x = nx; n.y = ny;
                // Also rotate velocity
                const nvx = n.vx * cosG - n.vy * sinG;
                const nvy = n.vx * sinG + n.vy * cosG;
                n.vx = nvx; n.vy = nvy;
            });

            // ─── Cluster rotation: each connected component orbits its center ───
            graphNodes.forEach(n => {
                if (n === dragNode) return;
                const cluster = nodeClusters[n.id];
                if (!cluster || cluster.count < 2) return;
                const cx = cluster.cx, cy = cluster.cy;
                const dx = n.x - cx, dy = n.y - cy;
                const dist = Math.sqrt(dx * dx + dy * dy);
                if (dist < 1) return;
                const cosC = Math.cos(cluster.rotation), sinC = Math.sin(cluster.rotation);
                // Rotate position around cluster center
                const rx = cx + dx * cosC - dy * sinC;
                const ry = cy + dx * sinC + dy * cosC;
                n.x = rx; n.y = ry;
            });

            // ─── Coulomb repulsion ───
            for (let i = 0; i < graphNodes.length; i++) {
                for (let j = i + 1; j < graphNodes.length; j++) {
                    const a = graphNodes[i], b = graphNodes[j];
                    let dx = b.x - a.x, dy = b.y - a.y;
                    let d2 = dx * dx + dy * dy;
                    if (d2 < 1) d2 = 1;
                    const f = K_REPEL / d2;
                    const d = Math.sqrt(d2);
                    const fx = (dx / d) * f, fy = (dy / d) * f;
                    a.vx -= fx; a.vy -= fy;
                    b.vx += fx; b.vy += fy;
                }
            }

            // ─── Spring edges ───
            graphEdges.forEach(e => {
                const a = nodeMap[e.source], b = nodeMap[e.target];
                if (!a || !b) return;
                const dx = b.x - a.x, dy = b.y - a.y;
                const d = Math.sqrt(dx * dx + dy * dy) || 1;
                const f = K_SPRING * (d - REST_LENGTH);
                const fx = (dx / d) * f, fy = (dy / d) * f;
                a.vx += fx; a.vy += fy;
                b.vx -= fx; b.vy -= fy;
            });

            // ─── Center gravity ───
            graphNodes.forEach(n => {
                n.vx -= n.x * K_GRAVITY;
                n.vy -= n.y * K_GRAVITY;
            });

            // ─── Flocking behavior ───
            graphNodes.forEach(n => {
                if (n === dragNode) return;
                let sepX = 0, sepY = 0, sepCount = 0;
                let aliVx = 0, aliVy = 0, aliCount = 0;
                let cohX = 0, cohY = 0, cohCount = 0;
                const flockR2 = FLOCK_RADIUS * FLOCK_RADIUS;

                for (let i = 0; i < graphNodes.length; i++) {
                    const other = graphNodes[i];
                    if (other === n || other === dragNode) continue;
                    const dx = other.x - n.x, dy = other.y - n.y;
                    const d2 = dx * dx + dy * dy;
                    if (d2 > flockR2 || d2 < 0.01) continue;
                    const d = Math.sqrt(d2);
                    // Separation: steer away from very close neighbors
                    if (d < FLOCK_RADIUS * 0.4) {
                        sepX -= dx / d; sepY -= dy / d; sepCount++;
                    }
                    // Alignment: match velocity of nearby nodes
                    aliVx += other.vx; aliVy += other.vy; aliCount++;
                    // Cohesion: steer towards center of nearby flock
                    cohX += other.x; cohY += other.y; cohCount++;
                }
                // Apply separation
                if (sepCount > 0) {
                    n.vx += (sepX / sepCount) * FLOCK_SEPARATION;
                    n.vy += (sepY / sepCount) * FLOCK_SEPARATION;
                }
                // Apply alignment — subtle gentle nudge
                if (aliCount > 0) {
                    n.vx += ((aliVx / aliCount) - n.vx) * FLOCK_ALIGNMENT;
                    n.vy += ((aliVy / aliCount) - n.vy) * FLOCK_ALIGNMENT;
                }
                // Apply cohesion — gentle attraction to center of neighbors
                if (cohCount > 0) {
                    n.vx += ((cohX / cohCount - n.x) * FLOCK_COHESION);
                    n.vy += ((cohY / cohCount - n.y) * FLOCK_COHESION);
                }
            });

            // ─── Damping + integrate ───
            graphNodes.forEach(n => {
                if (n === dragNode) return;
                n.vx *= DAMPING;
                n.vy *= DAMPING;
                n.x += n.vx;
                n.y += n.vy;
            });
        }

        // Warmup: run 300 iterations
        initPositions();
        for (let i = 0; i < 300; i++) simulate();

        // ─── Shape renderers ───
        function project3D(points3d, rotX, rotY) {
            const cosX = Math.cos(rotX), sinX = Math.sin(rotX);
            const cosY = Math.cos(rotY), sinY = Math.sin(rotY);
            return points3d.map(([x, y, z]) => {
                const y1 = y * cosX - z * sinX;
                const z1 = y * sinX + z * cosX;
                const x2 = x * cosY - z1 * sinY;
                const z2 = x * sinY + z1 * cosY;
                return [x2, y1];
            });
        }

        function drawShape(ctx, x, y, r, shape, rot, color, isHovered) {
            ctx.save();
            ctx.translate(x, y);
            const scale = isHovered ? 1.25 : 1.0;
            ctx.scale(scale, scale);

            const h = color.h, s = color.s, l = color.l;
            const strokeColor = `hsl(${h}, ${s}%, ${l}%)`;
            const innerGlow = ctx.createRadialGradient(0, 0, 0, 0, 0, r);
            innerGlow.addColorStop(0, `hsla(${h}, ${s}%, ${Math.min(l + 40, 98)}%, 0.9)`);
            innerGlow.addColorStop(0.4, `hsla(${h}, ${s}%, ${l + 10}%, 0.5)`);
            innerGlow.addColorStop(1, `hsla(${h}, ${s}%, ${l}%, 0.0)`);

            // Inner glow
            ctx.beginPath();
            ctx.arc(0, 0, r * 1.1, 0, Math.PI * 2);
            ctx.fillStyle = innerGlow;
            ctx.fill();

            const rotX = rot * 0.7;
            const rotY = rot;

            // Define 3D vertices for each shape
            let edges3d = [];
            const S = r * 0.75; // shape scale

            switch (shape) {
                case 'tetrahedron': {
                    const v = [[1,1,1],[1,-1,-1],[-1,1,-1],[-1,-1,1]];
                    edges3d = [[0,1],[0,2],[0,3],[1,2],[1,3],[2,3]];
                    const p = project3D(v.map(c => c.map(c2 => c2 * S)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edges3d.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'cube': {
                    const v = [];
                    for (let sx = -1; sx <= 1; sx += 2) for (let sy = -1; sy <= 1; sy += 2) for (let sz = -1; sz <= 1; sz += 2) v.push([sx, sy, sz]);
                    const edgePairs = [[0,1],[0,2],[0,4],[1,3],[1,5],[2,3],[2,6],[3,7],[4,5],[4,6],[5,7],[6,7]];
                    const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.7)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edgePairs.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'octahedron': {
                    const v = [[1,0,0],[-1,0,0],[0,1,0],[0,-1,0],[0,0,1],[0,0,-1]];
                    const edgePairs = [[0,2],[0,3],[0,4],[0,5],[1,2],[1,3],[1,4],[1,5],[2,4],[2,5],[3,4],[3,5]];
                    const p = project3D(v.map(c => c.map(c2 => c2 * S)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edgePairs.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'dodecahedron': {
                    const phi = (1 + Math.sqrt(5)) / 2;
                    const v = [];
                    for (let sx = -1; sx <= 1; sx += 2) for (let sy = -1; sy <= 1; sy += 2) for (let sz = -1; sz <= 1; sz += 2) v.push([sx, sy, sz]);
                    for (let sx = -1; sx <= 1; sx += 2) for (let sy = -1; sy <= 1; sy += 2) { v.push([0, sx / phi, sy * phi]); v.push([sx / phi, sy * phi, 0]); v.push([sy * phi, 0, sx / phi]); }
                    const edgePairs = [];
                    for (let i = 0; i < v.length; i++) for (let j = i + 1; j < v.length; j++) {
                        const dx = v[i][0] - v[j][0], dy = v[i][1] - v[j][1], dz = v[i][2] - v[j][2];
                        if (Math.abs(Math.sqrt(dx*dx+dy*dy+dz*dz) - 2/phi) < 0.01) edgePairs.push([i, j]);
                    }
                    const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.55)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.2;
                    edgePairs.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'icosahedron': {
                    const phi = (1 + Math.sqrt(5)) / 2;
                    const v = [[0,1,phi],[0,1,-phi],[0,-1,phi],[0,-1,-phi],[1,phi,0],[1,-phi,0],[-1,phi,0],[-1,-phi,0],[phi,0,1],[phi,0,-1],[-phi,0,1],[-phi,0,-1]];
                    const edgePairs = [[0,2],[0,4],[0,6],[0,8],[0,10],[1,3],[1,4],[1,6],[1,9],[1,11],[2,5],[2,7],[2,8],[2,10],[3,5],[3,7],[3,9],[3,11],[4,6],[4,8],[4,9],[5,7],[5,8],[5,9],[6,10],[6,11],[7,10],[7,11],[8,9],[10,11]];
                    const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.5)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edgePairs.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'star': {
                    // 5-pointed star
                    const spikes = 5, outerR = S, innerR = S * 0.4;
                    ctx.beginPath();
                    for (let i = 0; i < spikes * 2; i++) {
                        const r2 = i % 2 === 0 ? outerR : innerR;
                        const angle = (i * Math.PI / spikes) - Math.PI / 2 + rot;
                        const sx = Math.cos(angle) * r2, sy = Math.sin(angle) * r2;
                        if (i === 0) ctx.moveTo(sx, sy); else ctx.lineTo(sx, sy);
                    }
                    ctx.closePath();
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.8;
                    ctx.stroke();
                    // Inner glow fill
                    const starGlow = ctx.createRadialGradient(0, 0, 0, 0, 0, innerR);
                    starGlow.addColorStop(0, `hsla(${h}, ${s}%, ${Math.min(l+30,95)}%, 0.5)`);
                    starGlow.addColorStop(1, `hsla(${h}, ${s}%, ${l}%, 0.0)`);
                    ctx.fillStyle = starGlow; ctx.fill();
                    break;
                }
                case 'hexagonal_prism': {
                    const v = [], edgeP = [];
                    for (let i = 0; i < 6; i++) {
                        const a = Math.PI / 3 * i;
                        v.push([Math.cos(a)*S, S*0.6, Math.sin(a)*S]);
                        v.push([Math.cos(a)*S, -S*0.6, Math.sin(a)*S]);
                    }
                    for (let i = 0; i < 6; i++) { edgeP.push([i*2, i*2+1]); edgeP.push([i*2, ((i+1)%6)*2]); edgeP.push([i*2+1, ((i+1)%6)*2+1]); }
                    const p = project3D(v, rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                    edgeP.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'sphere_rings': {
                    // Circle with orbital ring
                    ctx.beginPath(); ctx.arc(0, 0, S * 0.7, 0, Math.PI * 2);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5; ctx.stroke();
                    // Ring (ellipse)
                    const ringPts = [];
                    for (let i = 0; i <= 36; i++) {
                        const a = (i / 36) * Math.PI * 2;
                        ringPts.push(project3D([[Math.cos(a)*S*1.1, 0, Math.sin(a)*S*1.1]], rotX*1.3, rotY*0.7)[0]);
                    }
                    ctx.beginPath();
                    ringPts.forEach((p2, i) => i === 0 ? ctx.moveTo(p2[0], p2[1]) : ctx.lineTo(p2[0], p2[1]));
                    ctx.strokeStyle = `hsla(${h}, ${s}%, ${Math.min(l+20,90)}%, 0.6)`;
                    ctx.lineWidth = 1; ctx.stroke();
                    break;
                }
                case 'diamond': {
                    // Elongated octahedron (top/bottom points)
                    const v = [[0,1.3*S,0],[S*0.7,0,0],[0,0,S*0.7],[-S*0.7,0,0],[0,0,-S*0.7],[0,-1.3*S,0]];
                    const edgeP = [[0,1],[0,2],[0,3],[0,4],[1,2],[2,3],[3,4],[4,1],[1,5],[2,5],[3,5],[4,5]];
                    const p = project3D(v, rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edgeP.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'triangular_prism': {
                    const v = [];
                    for (let i = 0; i < 3; i++) {
                        const a = (i / 3) * Math.PI * 2 - Math.PI / 2;
                        v.push([Math.cos(a)*S, S*0.6, Math.sin(a)*S]);
                        v.push([Math.cos(a)*S, -S*0.6, Math.sin(a)*S]);
                    }
                    const edgeP = [[0,1],[2,3],[4,5],[0,2],[2,4],[0,4],[1,3],[3,5],[1,5]];
                    const p = project3D(v, rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                    edgeP.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'pentagonal_prism': {
                    const v = [], edgeP = [];
                    for (let i = 0; i < 5; i++) {
                        const a = (i / 5) * Math.PI * 2 - Math.PI / 2;
                        v.push([Math.cos(a)*S, S*0.6, Math.sin(a)*S]);
                        v.push([Math.cos(a)*S, -S*0.6, Math.sin(a)*S]);
                    }
                    for (let i = 0; i < 5; i++) { edgeP.push([i*2, i*2+1]); edgeP.push([i*2, ((i+1)%5)*2]); edgeP.push([i*2+1, ((i+1)%5)*2+1]); }
                    const p = project3D(v, rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                    edgeP.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'star_of_david': {
                    // Two overlapping triangles
                    for (let t = 0; t < 2; t++) {
                        ctx.beginPath();
                        for (let i = 0; i < 3; i++) {
                            const a = (i / 3) * Math.PI * 2 + t * Math.PI / 3 + rot;
                            const px = Math.cos(a) * S, py = Math.sin(a) * S;
                            if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
                        }
                        ctx.closePath();
                        ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5; ctx.stroke();
                    }
                    const sdGlow = ctx.createRadialGradient(0, 0, 0, 0, 0, S * 0.5);
                    sdGlow.addColorStop(0, `hsla(${h}, ${s}%, ${Math.min(l+30,95)}%, 0.4)`);
                    sdGlow.addColorStop(1, `hsla(${h}, ${s}%, ${l}%, 0.0)`);
                    ctx.fillStyle = sdGlow; ctx.fill();
                    break;
                }
                default: {
                    // Fallback: circle
                    ctx.beginPath(); ctx.arc(0, 0, S * 0.7, 0, Math.PI * 2);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5; ctx.stroke();
                    break;
                }
            }

            // Outer glow ring
            if (isHovered) {
                ctx.beginPath();
                ctx.arc(0, 0, r * 1.3, 0, Math.PI * 2);
                ctx.strokeStyle = `hsla(${h}, ${s}%, ${Math.min(l+20,90)}%, 0.4)`;
                ctx.lineWidth = 2;
                ctx.stroke();
            }

            ctx.restore();
        }

        // ─── Render ───
        function resize() {
            W = canvas.width = canvas.offsetWidth;
            H = canvas.height = canvas.offsetHeight;
        }

        function worldToScreen(wx, wy) {
            return {
                x: (wx - camera.x) * camera.zoom + W / 2,
                y: (wy - camera.y) * camera.zoom + H / 2
            };
        }

        function screenToWorld(sx, sy) {
            return {
                x: (sx - W / 2) / camera.zoom + camera.x,
                y: (sy - H / 2) / camera.zoom + camera.y
            };
        }

        function isInView(wx, wy, margin) {
            const s = worldToScreen(wx, wy);
            return s.x > -margin && s.x < W + margin && s.y > -margin && s.y < H + margin;
        }

        function render() {
            if (!animating) return;
            time += 0.016;

            simulate();

            ctx.clearRect(0, 0, W, H);

            // Background: dark navy with subtle nebula
            const bgGrad = ctx.createRadialGradient(W * 0.3, H * 0.4, 0, W * 0.5, H * 0.5, Math.max(W, H) * 0.8);
            bgGrad.addColorStop(0, '#0d0d2b');
            bgGrad.addColorStop(0.5, '#0a0a1a');
            bgGrad.addColorStop(1, '#050510');
            ctx.fillStyle = bgGrad;
            ctx.fillRect(0, 0, W, H);

            // Second nebula glow
            const neb2 = ctx.createRadialGradient(W * 0.7, H * 0.6, 0, W * 0.7, H * 0.6, Math.max(W, H) * 0.5);
            neb2.addColorStop(0, 'rgba(60, 20, 80, 0.15)');
            neb2.addColorStop(1, 'rgba(10, 10, 26, 0.0)');
            ctx.fillStyle = neb2;
            ctx.fillRect(0, 0, W, H);

            // Stars
            stars.forEach(s => {
                const sp = worldToScreen(s.x, s.y);
                if (sp.x < -5 || sp.x > W + 5 || sp.y < -5 || sp.y > H + 5) return;
                const twinkle = 0.5 + 0.5 * Math.sin(time * s.twinkleSpeed + s.twinklePhase);
                const alpha = s.brightness * twinkle;
                ctx.beginPath();
                ctx.arc(sp.x, sp.y, s.r * camera.zoom, 0, Math.PI * 2);
                ctx.fillStyle = `rgba(200, 200, 255, ${alpha})`;
                ctx.fill();
            });

            // Edges (glow + line + particles)
            // Provenance edges: solid, bright, thicker
            // Heuristic edges: dashed, subtle, thinner
            graphEdges.forEach(e => {
                const a = nodeMap[e.source], b = nodeMap[e.target];
                if (!a || !b) return;
                if (!isInView(a.x, a.y, 50) && !isInView(b.x, b.y, 50)) return;

                const sa = worldToScreen(a.x, a.y), sb = worldToScreen(b.x, b.y);
                const colA = nodeColor(a), colB = nodeColor(b);
                const blendH = (colA.h + colB.h) / 2;
                const strength = e.strength || 0.5;
                const isProvenance = (e.edgeType || e.type) === 'provenance';
                const lineW = isProvenance ? (1.5 + strength * 2.5) : (0.5 + strength * 1.5);
                const glowAlpha = isProvenance ? (0.25 + 0.3 * strength) : (0.1 + 0.15 * strength);
                const coreAlpha = isProvenance ? (0.7 + 0.3 * strength) : (0.35 + 0.35 * strength);

                // Glow line (thick, semi-transparent)
                ctx.beginPath();
                ctx.moveTo(sa.x, sa.y);
                ctx.lineTo(sb.x, sb.y);
                ctx.strokeStyle = `hsla(${blendH}, 70%, 70%, ${glowAlpha})`;
                ctx.lineWidth = lineW * (isProvenance ? 5 : 4);
                ctx.stroke();

                // Core line
                ctx.beginPath();
                ctx.moveTo(sa.x, sa.y);
                ctx.lineTo(sb.x, sb.y);
                const edgeGrad = ctx.createLinearGradient(sa.x, sa.y, sb.x, sb.y);
                edgeGrad.addColorStop(0, `hsla(${colA.h}, ${colA.s}%, ${Math.min(colA.l + 20, 90)}%, ${coreAlpha})`);
                edgeGrad.addColorStop(1, `hsla(${colB.h}, ${colB.s}%, ${Math.min(colB.l + 20, 90)}%, ${coreAlpha})`);
                ctx.strokeStyle = edgeGrad;
                ctx.lineWidth = lineW;
                if (!isProvenance) {
                    ctx.setLineDash([6 * camera.zoom, 4 * camera.zoom]);
                }
                ctx.stroke();
                ctx.setLineDash([]);
            });

            // Edge particles
            edgeParticles.forEach(p => {
                p.t += p.speed;
                if (p.t > 1) p.t -= 1;
                const a = nodeMap[p.edge.source], b = nodeMap[p.edge.target];
                if (!a || !b) return;
                if (!isInView(a.x, a.y, 50) && !isInView(b.x, b.y, 50)) return;

                const wx = a.x + (b.x - a.x) * p.t;
                const wy = a.y + (b.y - a.y) * p.t;
                const sp = worldToScreen(wx, wy);
                const colA = nodeColor(a), colB = nodeColor(b);
                const blendH = (colA.h + colB.h) / 2;
                const isProv = (p.edge.edgeType || p.edge.type) === 'provenance';
                const alpha = isProv ? (0.6 + 0.4 * Math.sin(p.t * Math.PI)) : (0.3 + 0.3 * Math.sin(p.t * Math.PI));
                const pSize = isProv ? p.size * 1.4 : p.size;

                ctx.beginPath();
                ctx.arc(sp.x, sp.y, pSize * camera.zoom, 0, Math.PI * 2);
                ctx.fillStyle = `hsla(${blendH}, 80%, 80%, ${alpha})`;
                ctx.fill();
            });

            // Nodes
            graphNodes.forEach(node => {
                if (!isInView(node.x, node.y, 60)) return;

                const sp = worldToScreen(node.x, node.y);
                const col = nodeColor(node);
                const isHovered = node === hoveredNode;
                const pulse = 1 + 0.04 * Math.sin(time * 1.5 + node.phase);
                const r = node.radius * pulse * camera.zoom;

                // Pulsing brightness
                const brightPulse = 0.8 + 0.2 * Math.sin(time * 2 + node.phase);
                const adjustedL = Math.min(col.l * brightPulse + 15, 95);
                const adjColor = { h: col.h, s: col.s, l: adjustedL };

                node.rotAngle += node.rotSpeed * 0.016;

                drawShape(ctx, sp.x, sp.y, r, node.shape, node.rotAngle, adjColor, isHovered);

                // Highlight ring for hovered node (from sidebar hover or graph hover)
                if (isHovered) {
                    ctx.beginPath();
                    ctx.arc(sp.x, sp.y, r + 6 * camera.zoom, 0, Math.PI * 2);
                    ctx.strokeStyle = `hsla(${col.h}, 100%, 75%, ${0.5 + 0.3 * Math.sin(time * 4)})`;
                    ctx.lineWidth = 2.5 * camera.zoom;
                    ctx.stroke();
                }
            });

            requestAnimationFrame(render);
        }

        // ─── Welcome text fade-out ───
        function fadeWelcome() {
            if (welcomeFaded) return;
            welcomeFaded = true;
            const overlay = welcomeScreen.querySelector('.welcome-overlay');
            const content = welcomeScreen.querySelector('.welcome-content');
            const footer = welcomeScreen.querySelector('.welcome-footer');
            if (overlay) overlay.style.transition = 'opacity 0.8s ease-out';
            if (overlay) overlay.style.opacity = '0';
            if (content) content.style.transition = 'opacity 0.8s ease-out';
            if (content) content.style.opacity = '0';
            if (footer) footer.style.transition = 'opacity 0.8s ease-out';
            if (footer) footer.style.opacity = '0';
            // Remove them after transition so they don't block canvas clicks
            setTimeout(() => {
                if (overlay) overlay.style.display = 'none';
                if (content) content.style.display = 'none';
                if (footer) footer.style.display = 'none';
            }, 900);
        }

        // ─── Interaction ───
        function findNodeAt(sx, sy) {
            const w = screenToWorld(sx, sy);
            let closest = null, closestDist = Infinity;
            graphNodes.forEach(n => {
                const dx = w.x - n.x, dy = w.y - n.y;
                const d = Math.sqrt(dx * dx + dy * dy);
                if (d < n.radius * 1.5 && d < closestDist) {
                    closest = n;
                    closestDist = d;
                }
            });
            return closest;
        }

        const tooltip = document.getElementById('graph-tooltip');

        canvas.addEventListener('mousedown', e => {
            mouseDownPos = { x: e.offsetX, y: e.offsetY };
            hasDragged = false;
            const node = findNodeAt(e.offsetX, e.offsetY);
            if (node) {
                dragNode = node;
                canvas.style.cursor = 'grabbing';
            } else {
                isPanning = true;
                panStart = { x: e.clientX, y: e.clientY };
                canvas.style.cursor = 'grabbing';
            }
            fadeWelcome();
        });

        canvas.addEventListener('mousemove', e => {
            mouseScreen = { x: e.offsetX, y: e.offsetY };
            mouseWorld = screenToWorld(e.offsetX, e.offsetY);

            // Detect drag (mouse moved more than 4px from mousedown)
            const dx = e.offsetX - mouseDownPos.x;
            const dy = e.offsetY - mouseDownPos.y;
            if (Math.abs(dx) > 4 || Math.abs(dy) > 4) hasDragged = true;

            if (dragNode) {
                dragNode.x = mouseWorld.x;
                dragNode.y = mouseWorld.y;
                dragNode.vx = 0;
                dragNode.vy = 0;
                // Hide tooltip while dragging a node
                if (tooltip) tooltip.classList.add('tooltip-hidden');
            } else if (isPanning) {
                const pdx = e.clientX - panStart.x;
                const pdy = e.clientY - panStart.y;
                camera.x -= pdx / camera.zoom;
                camera.y -= pdy / camera.zoom;
                panStart = { x: e.clientX, y: e.clientY };
            } else {
                const node = findNodeAt(e.offsetX, e.offsetY);
                hoveredNode = node;
                canvas.style.cursor = node ? 'pointer' : 'grab';

                // Graph node hover → highlight sidebar item
                document.querySelectorAll('.nav-item.graph-highlight').forEach(el => el.classList.remove('graph-highlight'));
                if (node) {
                    const sidebarItem = document.querySelector(`.nav-item[data-slug="${node.id}"]`);
                    if (sidebarItem) {
                        sidebarItem.classList.add('graph-highlight');
                        sidebarItem.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                    }
                }

                if (tooltip) {
                    if (node) {
                        tooltip.classList.remove('tooltip-hidden');
                        tooltip.querySelector('.tooltip-title').textContent = node.title || node.id;
                        tooltip.querySelector('.tooltip-domain').textContent = node.primary_domain || node.domain || '';
                        tooltip.querySelector('.tooltip-date').textContent = node.date ? new Date(node.date).toLocaleDateString() : '';
                        tooltip.style.left = (e.offsetX + 15) + 'px';
                        tooltip.style.top = (e.offsetY - 10) + 'px';
                    } else {
                        tooltip.classList.add('tooltip-hidden');
                    }
                }
            }
        });

        canvas.addEventListener('mouseup', e => {
            dragNode = null;
            isPanning = false;
            canvas.style.cursor = hoveredNode ? 'pointer' : 'grab';
        });

        canvas.addEventListener('mouseleave', () => {
            dragNode = null;
            isPanning = false;
            hoveredNode = null;
            if (tooltip) tooltip.classList.add('tooltip-hidden');
            canvas.style.cursor = 'grab';
            document.querySelectorAll('.nav-item.graph-highlight').forEach(el => el.classList.remove('graph-highlight'));
        });

        canvas.addEventListener('click', e => {
            if (hasDragged) return; // Don't navigate after dragging
            const node = findNodeAt(e.offsetX, e.offsetY);
            if (node) {
                const filename = node.id + '.json';
                if (window.PACKAGE_DB && window.PACKAGE_DB[filename]) {
                    loadPackage(filename);
                }
            }
        });

        canvas.addEventListener('wheel', e => {
            e.preventDefault();
            fadeWelcome();
            const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
            const newZoom = Math.max(0.2, Math.min(5, camera.zoom * zoomFactor));

            // Zoom toward mouse position
            const wBefore = screenToWorld(e.offsetX, e.offsetY);
            camera.zoom = newZoom;
            const wAfter = screenToWorld(e.offsetX, e.offsetY);
            camera.x += wBefore.x - wAfter.x;
            camera.y += wBefore.y - wAfter.y;
        }, { passive: false });

        // Touch support
        let lastTouchDist = 0;
        canvas.addEventListener('touchstart', e => {
            fadeWelcome();
            if (e.touches.length === 1) {
                const touch = e.touches[0];
                const rect = canvas.getBoundingClientRect();
                const node = findNodeAt(touch.clientX - rect.left, touch.clientY - rect.top);
                if (node) {
                    dragNode = node;
                } else {
                    isPanning = true;
                    panStart = { x: touch.clientX, y: touch.clientY };
                }
            } else if (e.touches.length === 2) {
                const dx = e.touches[0].clientX - e.touches[1].clientX;
                const dy = e.touches[0].clientY - e.touches[1].clientY;
                lastTouchDist = Math.sqrt(dx * dx + dy * dy);
            }
            e.preventDefault();
        }, { passive: false });

        canvas.addEventListener('touchmove', e => {
            if (e.touches.length === 1) {
                const touch = e.touches[0];
                const rect = canvas.getBoundingClientRect();
                const sx = touch.clientX - rect.left;
                const sy = touch.clientY - rect.top;
                mouseWorld = screenToWorld(sx, sy);

                if (dragNode) {
                    dragNode.x = mouseWorld.x;
                    dragNode.y = mouseWorld.y;
                    dragNode.vx = 0;
                    dragNode.vy = 0;
                } else if (isPanning) {
                    const dx = touch.clientX - panStart.x;
                    const dy = touch.clientY - panStart.y;
                    camera.x -= dx / camera.zoom;
                    camera.y -= dy / camera.zoom;
                    panStart = { x: touch.clientX, y: touch.clientY };
                }
            } else if (e.touches.length === 2) {
                const dx = e.touches[0].clientX - e.touches[1].clientX;
                const dy = e.touches[0].clientY - e.touches[1].clientY;
                const dist = Math.sqrt(dx * dx + dy * dy);
                if (lastTouchDist > 0) {
                    camera.zoom = Math.max(0.2, Math.min(5, camera.zoom * (dist / lastTouchDist)));
                }
                lastTouchDist = dist;
            }
            e.preventDefault();
        }, { passive: false });

        canvas.addEventListener('touchend', e => {
            if (dragNode && e.changedTouches.length === 1 && !hasDragged) {
                const touch = e.changedTouches[0];
                const rect = canvas.getBoundingClientRect();
                const node = findNodeAt(touch.clientX - rect.left, touch.clientY - rect.top);
                if (node) {
                    const filename = node.id + '.json';
                    if (window.PACKAGE_DB && window.PACKAGE_DB[filename]) {
                        loadPackage(filename);
                    }
                }
            }
            dragNode = null;
            isPanning = false;
            lastTouchDist = 0;
            hasDragged = false;
        });

        // ─── AETHER integration: add nodes/edges at runtime ───
        window.addGraphEdges = function(newEdges) {
            if (!Array.isArray(newEdges)) return;
            newEdges.forEach(e => {
                // Avoid duplicates
                if (graphEdges.some(ge => ge.source === e.source && ge.target === e.target)) return;
                // Tag with edgeType for visual distinction
                e.edgeType = e.type || 'heuristic';
                graphEdges.push(e);
                // Spawn particles for the new edge
                const count = 2 + Math.floor(Math.random() * 2);
                for (let i = 0; i < count; i++) {
                    edgeParticles.push({
                        edge: e,
                        t: Math.random(),
                        speed: 0.002 + Math.random() * 0.004,
                        size: 1 + Math.random() * 1.5
                    });
                }
            });
            // Refresh clusters since connectivity changed
            nodeClusters = findClusters();
        };

        window.addGraphNode = function(nodeData) {
            if (!nodeData || !nodeData.id) return;
            if (graphNodes.some(n => n.id === nodeData.id)) return;
            const node = {
                ...nodeData,
                x: (Math.random() - 0.5) * 200,
                y: (Math.random() - 0.5) * 200,
                vx: 0, vy: 0,
                radius: 22,
                phase: Math.random() * Math.PI * 2,
                rotSpeed: 0.3 + Math.random() * 0.5,
                rotAngle: Math.random() * Math.PI * 2
            };
            graphNodes.push(node);
            nodeMap[node.id] = node;
        };

        // Resize handler
        window.addEventListener('resize', resize);

        // MutationObserver to pause/resume animation
        const observer = new MutationObserver(() => {
            if (welcomeScreen.classList.contains('hidden')) {
                animating = false;
            } else {
                resize();
                animating = true;
                requestAnimationFrame(render);
            }
        });
        observer.observe(welcomeScreen, { attributes: true, attributeFilter: ['class'] });

        if (!welcomeScreen.classList.contains('hidden')) {
            resize();
            animating = true;
            requestAnimationFrame(render);
        }
    })();

    // ── Future Directions View ──

    function showDirectionsView() {
        directionsVisible = true;
        welcomeScreen.classList.add('hidden');
        packageView.classList.add('hidden');
        directionsView.classList.remove('hidden');
        // Highlight nav link
        document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
        directionsLink.classList.add('active');
        renderDirectionsView();
        // Close sidebar on mobile
        if (window.innerWidth <= 768) closeSidebar();
    }

    function hideDirectionsView() {
        directionsVisible = false;
        directionsView.classList.add('hidden');
        directionsLink.classList.remove('active');
    }

    function populateDomainFilter() {
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
    }

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

    function renderDirectionsView() {
        if (!directionsGrid) return;
        const directions = getFilteredDirections();
        if (directions.length === 0) {
            directionsGrid.innerHTML = '<div class="directions-empty">No research directions match your filters.</div>';
            return;
        }

        const statusColors = {
            available: '#4caf50',
            in_progress: '#2196f3',
            completed: '#9e9e9e',
            abandoned: '#f44336',
        };
        const statusLabels = {
            available: 'Available',
            in_progress: 'In Progress',
            completed: 'Completed',
            abandoned: 'Abandoned',
        };

        directionsGrid.innerHTML = directions.map(d => {
            const priorityPct = Math.round(d.priority_score * 100);
            const priorityColor = d.priority_score >= 0.9 ? '#f44336' : d.priority_score >= 0.8 ? '#ff9800' : '#ffc107';
            const statusColor = statusColors[d.status] || '#9e9e9e';
            const statusLabel = statusLabels[d.status] || d.status;
            const domainTags = (d.domains || []).map(dm =>
                `<span class="direction-domain-tag">${dm}</span>`
            ).join('');
            const shortDesc = d.description.length > 200
                ? d.description.substring(0, 200) + '...'
                : d.description;

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
                    <div class="direction-card-details hidden" id="details-${d.id}">
                        <p class="direction-card-full-desc">${d.description}</p>
                        ${d.research_mode ? `<div class="direction-detail-row"><strong>Mode:</strong> ${d.research_mode}</div>` : ''}
                        ${d.consumed_by_exp_id ? `<div class="direction-detail-row"><strong>Active Experiment:</strong> ${d.consumed_by_exp_id}</div>` : ''}
                        <div class="direction-detail-row"><strong>Source:</strong> ${d.source_exp_id}</div>
                    </div>
                    <button class="direction-card-expand" data-id="${d.id}">Show Details</button>
                </div>
            `;
        }).join('');

        // Expand/collapse handlers
        directionsGrid.querySelectorAll('.direction-card-expand').forEach(btn => {
            btn.addEventListener('click', () => {
                const id = btn.dataset.id;
                const details = document.getElementById('details-' + id);
                if (details.classList.contains('hidden')) {
                    details.classList.remove('hidden');
                    btn.textContent = 'Hide Details';
                } else {
                    details.classList.add('hidden');
                    btn.textContent = 'Show Details';
                }
            });
        });
    }

    // Nav link click handler
    directionsLink.addEventListener('click', (e) => {
        e.preventDefault();
        showDirectionsView();
    });

    // Welcome screen directions link
    const welcomeDirectionsLink = document.getElementById('welcome-directions-link');
    if (welcomeDirectionsLink) {
        welcomeDirectionsLink.addEventListener('click', (e) => {
            e.preventDefault();
            showDirectionsView();
        });
    }

    // Filter change handlers
    directionsStatusFilter.addEventListener('change', renderDirectionsView);
    directionsDomainFilter.addEventListener('change', renderDirectionsView);
    directionsSearch.addEventListener('input', renderDirectionsView);

    // Initial population of domain filter when data loads
    const origOnload = window.PACKAGE_INDEX ? renderDirectionsView : null;
    if (window.PACKAGE_INDEX) {
        // Data already loaded
        populateDomainFilter();
    }

    // Override loadPackage to hide directions view when switching to a package
    const origLoadPackage = loadPackage;
    loadPackage = function(filename) {
        hideDirectionsView();
        origLoadPackage(filename);
    };

    // When data refreshes, re-populate domain filter and re-render if directions visible
    const _origRenderSidebar = renderSidebar;
    renderSidebar = function(pkgArray) {
        _origRenderSidebar(pkgArray);
        populateDomainFilter();
        if (directionsVisible) renderDirectionsView();
    };
});
