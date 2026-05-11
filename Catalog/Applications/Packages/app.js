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
        if (viz.data && viz.data.startsWith('<svg')) {
            // Wrap SVG in an img via data URI so it sizes like a raster image
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
                
                // Determine if it's base64 or inline svg
                let imgContent = '';
                if (viz.data && viz.data.startsWith('<svg')) {
                    // Wrap SVG in an img via data URI so it sizes properly
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

    function buildAlgorithmStubs(code, pkgData) {
        // Build Python stub definitions for imports from the 'algorithms' module.
        // Aristotle generates demos that import from a companion 'algorithms' module,
        // but Pyodide only runs the demo code. This function:
        // 1. Extracts all names imported from 'algorithms'
        // 2. Creates stub functions/classes that return plausible default values
        // 3. Optionally converts pseudocode from the package's algorithms section
        // Collect imported names from "from algorithms import X, Y, Z"
        const fromImportRe = /^from\s+algorithms\s+import\s+(.+?)$/gm;
        // Also handle "import algorithms" and "import algorithms as alg"
        const bareImportRe = /^\s*import\s+algorithms\b/m;

        const importedNames = new Set();
        let match;
        while ((match = fromImportRe.exec(code)) !== null) {
            match[1].split(',').forEach(name => {
                // Handle "X as Y" and strip whitespace
                const clean = name.trim().replace(/\s+as\s+\w+$/, '').trim();
                if (clean) importedNames.add(clean);
            });
        }

        let stubs = '# --- Auto-generated algorithm stubs ---\n';

        if (importedNames.size === 0 && bareImportRe.test(code)) {
            // Bare "import algorithms" — create a module object
            stubs += 'import types\nalgorithms = types.ModuleType("algorithms")\n';
            stubs += 'import sys\nsys.modules["algorithms"] = algorithms\n';
            return stubs;
        }

        if (importedNames.size === 0) return '';

        // Try to build real implementations from pseudocode
        const pseudocodeMap = {};
        if (pkgData && pkgData.algorithms) {
            pkgData.algorithms.forEach(algo => {
                const name = algo.name ? algo.name.replace(/[^a-zA-Z0-9_]/g, '_') : '';
                if (name && algo.pseudocode) {
                    pseudocodeMap[name] = algo.pseudocode;
                }
            });
        }

        // Generate stubs for each imported name
        for (const name of importedNames) {
            // Check if it starts with uppercase (likely a class)
            const isClass = /^[A-Z]/.test(name);

            if (isClass) {
                stubs += `class ${name}:\n`;
                stubs += `    def __init__(self, *args, **kwargs):\n`;
                stubs += `        print(f"[stub] ${name} created")\n`;
                stubs += `    def __getattr__(self, attr):\n`;
                stubs += `        return lambda *a, **kw: print(f"[stub] ${name}.{attr} called")\n`;
            } else {
                // Check if pseudocode is available and parseable as Python
                const pcode = pseudocodeMap[name];
                if (pcode) {
                    // Try to use pseudocode directly — wrap in a function
                    // Remove "function", "procedure" etc. and normalize
                    let pyCode = pcode
                        .replace(/^(function|procedure|def)\s+/i, '')
                        .replace(/^return\s+/gm, 'return ')
                        .trim();
                    stubs += `def ${name}(*args, **kwargs):\n`;
                    stubs += `    # Algorithm: ${name}\n`;
                    // Indent pseudocode as function body
                    const lines = pyCode.split('\n');
                    for (const line of lines) {
                        const trimmed = line.trim();
                        if (trimmed) {
                            stubs += `    ${trimmed}\n`;
                        }
                    }
                    stubs += `    pass  # fallback\n\n`;
                } else {
                    // Generic stub that returns a sensible default
                    stubs += `def ${name}(*args, **kwargs):\n`;
                    stubs += `    # [auto-stub] ${name} - see Algorithms tab for details\n`;
                    stubs += `    import math, random\n`;
                    stubs += `    if args:\n`;
                    stubs += `        if isinstance(args[0], (list, tuple)) and len(args) >= 2:\n`;
                    stubs += `            # Likely a two-argument function returning a number\n`;
                    stubs += `            return random.randint(1, 100)\n`;
                    stubs += `        if isinstance(args[0], int):\n`;
                    stubs += `            return random.randint(1, 100)\n`;
                    stubs += `    return []\n\n`;
                }
            }
        }

        // Create the algorithms module and inject stubs
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

                        // If the demo imports 'algorithms', inject stub definitions
                        // so it runs standalone. Aristotle often generates demos
                        // that import from a companion algorithms module, but
                        // Pyodide only sees the demo code.
                        if (/^(from|import)\s+algorithms\b/m.test(codeToRun)) {
                            const stubs = buildAlgorithmStubs(codeToRun, currentPackage);
                            // Remove the original 'from algorithms import ...' lines
                            // since the stubs module is already in sys.modules
                            codeToRun = codeToRun.replace(/^(from\s+algorithms\s+import\s+.+?|import\s+algorithms\b.*)$/gm, '');
                            codeToRun = stubs + '\n' + codeToRun;
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
