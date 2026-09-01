// docs/js/lean_catalog.js

document.addEventListener('DOMContentLoaded', () => {
    const catalogLink = document.getElementById('nav-lean-catalog-link');
    const catalogView = document.getElementById('lean-catalog-view');
    const welcomeScreen = document.getElementById('welcome-screen');
    const packageView = document.getElementById('package-view');
    const directionsView = document.getElementById('directions-view');
    const catalogContent = document.getElementById('lean-catalog-content');
    const domainFilter = document.getElementById('lean-domain-filter');
    const searchInput = document.getElementById('lean-search');

    if (!catalogLink || !catalogView) return;

    let catalogTree = [];       // Array of { path, name, size, decls }
    let theoremIndex = {};      // declName -> fileItem
    let fileContentCache = {};  // path -> string code
    let activeFilePath = null;  // currently selected file path
    let isDataLoaded = false;

    window.hideLeanCatalogView = function() {
        catalogView.classList.add('hidden');
        if (catalogLink) catalogLink.classList.remove('active');
        if (window.resumeGraphAnimation && (!welcomeScreen || !welcomeScreen.classList.contains('hidden'))) {
            window.resumeGraphAnimation();
        }
    };

    async function showLeanCatalog(targetPath = null) {
        if (window.pauseGraphAnimation) window.pauseGraphAnimation();
        if (welcomeScreen) welcomeScreen.classList.add('hidden');
        if (packageView) packageView.classList.add('hidden');
        if (directionsView) directionsView.classList.add('hidden');
        if (window.hideDirectionsView) window.hideDirectionsView();
        
        catalogView.classList.remove('hidden');
        catalogLink.classList.add('active');
        
        // Deselect active package in sidebar if any
        if (window.Aether && window.Aether.currentPackage) {
            window.Aether.currentPackage = null;
            document.querySelectorAll('#package-list li').forEach(li => li.classList.remove('active'));
        }

        if (!isDataLoaded) {
            await buildCatalogData();
        }

        if (targetPath) {
            await loadFileDetail(targetPath, false);
        } else if (!activeFilePath && catalogTree.length > 0) {
            renderCatalog();
        } else {
            renderCatalog();
        }
    }

    window.showLeanCatalog = showLeanCatalog;

    catalogLink.addEventListener('click', (e) => {
        e.preventDefault();
        showLeanCatalog();
    });

    async function buildCatalogData() {
        if (isDataLoaded) return;

        if (catalogContent) {
            catalogContent.innerHTML = '<div style="padding: 40px; text-align: center; color: var(--text-muted);"><div class="spinner" style="margin-bottom: 12px;"></div>Loading Lean 4 Catalog index...</div>';
        }

        try {
            if (window.CATALOG_TREE && Array.isArray(window.CATALOG_TREE)) {
                catalogTree = window.CATALOG_TREE;
            } else {
                const res = await fetch('catalog_tree.json');
                if (res.ok) {
                    catalogTree = await res.json();
                } else {
                    console.error("Failed to fetch catalog_tree.json", res.status);
                }
            }
        } catch (err) {
            console.error("Error loading catalog_tree.json:", err);
        }

        theoremIndex = {};
        const topDirs = new Set();

        catalogTree.forEach(f => {
            const parts = f.path.split('/');
            if (parts.length > 1) {
                topDirs.add(parts[0]);
            }
            if (f.decls && Array.isArray(f.decls)) {
                f.decls.forEach(d => {
                    if (d) theoremIndex[d] = f;
                });
            }
        });

        // Update category/domain filter with top-level directories
        if (domainFilter) {
            domainFilter.innerHTML = '<option value="">All Categories / Folders</option>';
            Array.from(topDirs).sort().forEach(d => {
                const opt = document.createElement('option');
                opt.value = d;
                opt.textContent = d;
                domainFilter.appendChild(opt);
            });
        }

        isDataLoaded = true;
        renderCatalog();
    }

    function escapeHTML(str) {
        if (!str) return '';
        return String(str).replace(/[&<>'"]/g, tag => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            "'": '&#39;',
            '"': '&quot;'
        }[tag] || tag));
    }

    function renderCatalog() {
        if (!catalogContent) return;

        const filterDomain = domainFilter ? domainFilter.value : '';
        const filterText = searchInput ? searchInput.value.toLowerCase().trim() : '';

        let html = `
            <style>
                #lean-catalog-content summary::marker { content: ""; }
                #lean-catalog-content summary::-webkit-details-marker { display: none; }
                #lean-catalog-content details summary .dir-chevron { transition: transform 0.15s ease-out; }
                #lean-catalog-content details[open] > summary .dir-chevron { transform: rotate(90deg); }
                #lean-catalog-content summary:hover { background: rgba(255, 255, 255, 0.05); }
            </style>
        `;
        html += '<div style="display: flex; gap: 20px; height: calc(100vh - 170px);">';

        // Sidebar tree list
        html += '<div style="flex: 0 0 360px; overflow-y: auto; border-right: 1px solid var(--border-color); padding-right: 15px;">';

        let filteredCount = 0;
        const root = { type: 'dir', name: 'Catalog', children: {} };

        catalogTree.forEach((f, idx) => {
            if (filterDomain && !f.path.startsWith(filterDomain + '/')) return;
            if (filterText) {
                const matchName = f.name.toLowerCase().includes(filterText);
                const matchPath = f.path.toLowerCase().includes(filterText);
                const matchDecl = f.decls && f.decls.some(d => d.toLowerCase().includes(filterText));
                if (!matchName && !matchPath && !matchDecl) return;
            }

            filteredCount++;

            const parts = f.path.split('/');
            let current = root;
            for (let i = 0; i < parts.length - 1; i++) {
                const p = parts[i];
                if (!current.children[p]) {
                    current.children[p] = { type: 'dir', name: p, children: {} };
                }
                current = current.children[p];
            }
            const fileName = parts[parts.length - 1];
            current.children[fileName] = { type: 'file', name: fileName, fileObj: f, idx: idx };
        });

        function countChildFiles(node) {
            let count = 0;
            for (const k in node.children) {
                const c = node.children[k];
                if (c.type === 'file') count++;
                else if (c.type === 'dir') count += countChildFiles(c);
            }
            return count;
        }

        function renderTree(node, depth, isRoot = false) {
            let res = '';
            const keys = Object.keys(node.children).sort((a, b) => {
                const aIsFile = node.children[a].type === 'file';
                const bIsFile = node.children[b].type === 'file';
                if (aIsFile && !bIsFile) return 1;
                if (!aIsFile && bIsFile) return -1;
                return a.localeCompare(b);
            });

            for (const key of keys) {
                const child = node.children[key];
                if (child.type === 'dir') {
                    const openAttr = (filterText || filterDomain || depth === 0) ? 'open' : '';
                    const childCount = countChildFiles(child);
                    res += `
                        <details ${openAttr} style="margin-left: ${isRoot ? 0 : 10}px; margin-bottom: 2px;">
                            <summary style="cursor: pointer; font-weight: 500; padding: 4px 6px; color: var(--text-color); font-size: 13px; user-select: none; display: flex; align-items: center; border-radius: 4px; transition: background 0.15s;">
                                <svg class="dir-chevron" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px; flex-shrink: 0; opacity: 0.7;"><polyline points="9 18 15 12 9 6"></polyline></svg>
                                <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px; flex-shrink: 0; color: var(--accent-color);"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                                <span>${escapeHTML(child.name)}</span>
                                <span style="margin-left: auto; font-size: 11px; color: var(--text-muted); opacity: 0.7; padding-left: 8px;">${childCount}</span>
                            </summary>
                            <div style="border-left: 1px solid var(--border-color); padding-left: 4px; margin-top: 2px; margin-left: 6px;">
                                ${renderTree(child, depth + 1)}
                            </div>
                        </details>
                    `;
                } else {
                    const f = child.fileObj;
                    const isActive = (activeFilePath === f.path);
                    const declBadge = (f.decls && f.decls.length > 0) ? `<span style="margin-left: auto; font-size: 11px; color: var(--text-muted); background: var(--bg-tertiary, rgba(255,255,255,0.06)); padding: 1px 6px; border-radius: 10px;">${f.decls.length}</span>` : '';
                    res += `
                        <div class="lean-file-card ${isActive ? 'active' : ''}" data-path="${escapeHTML(f.path)}" style="margin-left: ${isRoot ? 0 : 10}px; padding: 4px 8px; margin-bottom: 2px; cursor: pointer; border-radius: 4px; transition: all 0.15s; opacity: ${isActive ? '1' : '0.85'}; background: ${isActive ? 'rgba(59, 130, 246, 0.15)' : 'transparent'}; color: ${isActive ? 'var(--accent-color)' : 'var(--text-color)'};">
                            <div class="lean-file-card-title" style="font-weight: ${isActive ? '600' : '400'}; font-size: 13px; word-break: break-all; display: flex; align-items: center;">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px; flex-shrink: 0; color: inherit;"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>
                                <span style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 220px;" title="${escapeHTML(f.path)}">${escapeHTML(f.name)}</span>
                                ${declBadge}
                            </div>
                        </div>
                    `;
                }
            }
            return res;
        }

        if (filteredCount === 0) {
            html += '<div style="color: var(--text-muted); font-size: 13px; text-align: center; margin-top: 20px;">No files found matching search criteria.</div>';
        } else {
            html += `
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; padding-bottom: 6px; border-bottom: 1px solid var(--border-color);">
                    <span style="font-size: 12px; color: var(--text-muted); font-weight: 500;">Catalog Directory (${filteredCount} files)</span>
                    <div style="display: flex; gap: 8px; align-items: center;">
                        <button id="toggle-expand-all" style="background: none; border: none; color: var(--accent-color); font-size: 11px; cursor: pointer; padding: 2px 4px; font-weight: 500;" title="Expand all directories">📂 Expand All</button>
                        <span style="color: var(--text-muted); font-size: 10px; opacity: 0.5;">|</span>
                        <button id="toggle-collapse-all" style="background: none; border: none; color: var(--text-muted); font-size: 11px; cursor: pointer; padding: 2px 4px; font-weight: 500;" title="Collapse all directories">📁 Collapse All</button>
                    </div>
                </div>
            `;
            html += renderTree(root, 0, true);
        }

        html += '</div>';

        // Main content detail area
        html += '<div id="lean-catalog-detail" style="flex: 1; min-width: 0; background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: 8px; padding: 24px; overflow-y: auto;">';
        if (activeFilePath && fileContentCache[activeFilePath]) {
            html += generateFileDetailHTML(activeFilePath, fileContentCache[activeFilePath]);
        } else {
            html += '<div style="color: var(--text-muted); text-align: center; margin-top: 120px; font-size: 15px;"><svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom: 16px; opacity: 0.5;"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/></svg><br>Select a Lean 4 file from the directory tree to inspect code & cross-references.</div>';
        }
        html += '</div>';

        html += '</div>';
        catalogContent.innerHTML = html;

        // Attach Expand All / Collapse All event listeners
        const expandBtn = document.getElementById('toggle-expand-all');
        if (expandBtn) {
            expandBtn.addEventListener('click', () => {
                document.querySelectorAll('#lean-catalog-content details').forEach(d => d.open = true);
            });
        }
        const collapseBtn = document.getElementById('toggle-collapse-all');
        if (collapseBtn) {
            collapseBtn.addEventListener('click', () => {
                document.querySelectorAll('#lean-catalog-content details').forEach(d => d.open = false);
            });
        }

        // Attach sidebar event listeners
        document.querySelectorAll('.lean-file-card').forEach(card => {
            card.addEventListener('click', () => {
                const path = card.getAttribute('data-path');
                if (path) loadFileDetail(path, true);
            });
            card.addEventListener('mouseenter', () => {
                if (card.getAttribute('data-path') !== activeFilePath) card.style.opacity = '1';
            });
            card.addEventListener('mouseleave', () => {
                if (card.getAttribute('data-path') !== activeFilePath) card.style.opacity = '0.85';
            });
        });

        if (activeFilePath && fileContentCache[activeFilePath]) {
            attachDetailEventListeners(activeFilePath, fileContentCache[activeFilePath]);
        }
    }

    async function loadFileDetail(filePath, updateUrl = true) {
        if (!filePath) return;
        const normalizedPath = filePath.replace(/^Catalog\//, '').replace(/^\.\//, '');
        activeFilePath = normalizedPath;

        // Highlight active card in sidebar and expand parents
        document.querySelectorAll('.lean-file-card').forEach(c => {
            const p = c.getAttribute('data-path');
            if (p === normalizedPath) {
                c.classList.add('active');
                c.style.background = 'rgba(59, 130, 246, 0.15)';
                c.style.color = 'var(--accent-color)';
                c.style.opacity = '1';
                c.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                let parent = c.parentElement;
                while (parent) {
                    if (parent.tagName === 'DETAILS') parent.open = true;
                    parent = parent.parentElement;
                }
            } else {
                c.classList.remove('active');
                c.style.background = 'transparent';
                c.style.color = 'var(--text-color)';
                c.style.opacity = '0.85';
            }
        });

        if (updateUrl) {
            const newHash = '#catalog/' + normalizedPath;
            if (window.location.hash !== newHash) {
                history.pushState(null, '', newHash);
            }
        }

        const detailContainer = document.getElementById('lean-catalog-detail');
        if (!detailContainer) return;

        if (fileContentCache[normalizedPath]) {
            detailContainer.innerHTML = generateFileDetailHTML(normalizedPath, fileContentCache[normalizedPath]);
            attachDetailEventListeners(normalizedPath, fileContentCache[normalizedPath]);
            return;
        }

        detailContainer.innerHTML = `
            <div style="padding: 60px; text-align: center; color: var(--text-muted);">
                <div style="font-size: 14px; margin-bottom: 8px;">Fetching <code>Catalog/${escapeHTML(normalizedPath)}</code>...</div>
            </div>
        `;

        try {
            const res = await fetch('Catalog/' + normalizedPath);
            if (res.ok) {
                const code = await res.text();
                fileContentCache[normalizedPath] = code;
                detailContainer.innerHTML = generateFileDetailHTML(normalizedPath, code);
                attachDetailEventListeners(normalizedPath, code);
            } else {
                detailContainer.innerHTML = `<div style="padding: 40px; text-align: center; color: #ef4444;">Failed to fetch <code>Catalog/${escapeHTML(normalizedPath)}</code> (${res.status} ${res.statusText})</div>`;
            }
        } catch (err) {
            detailContainer.innerHTML = `<div style="padding: 40px; text-align: center; color: #ef4444;">Error fetching file: ${escapeHTML(err.message)}</div>`;
        }
    }

    function generateFileDetailHTML(filePath, code) {
        const fileItem = catalogTree.find(f => f.path === filePath) || { name: filePath.split('/').pop(), size: code.length, decls: [] };
        const lines = code.split('\n');
        
        const STOP_WORDS = new Set(['of', 'in', 'is', 'to', 'and', 'or', 'if', 'as', 'at', 'by', 'on', 'it', 'be', 'so', 'we', 'do', 'no', 'my', 'an', 'me', 'us', 'up', 'the', 'a', 'val', 'eq', 'map', 'get', 'set']);
        const allThms = Object.keys(theoremIndex)
            .filter(t => t.length > 2 && !STOP_WORDS.has(t.toLowerCase()))
            .sort((a,b) => b.length - a.length);
        
        let highlightedHtml = '';
        lines.forEach((line, idx) => {
            let processed = escapeHTML(line);
            const trimmed = line.trim();
            const isComment = trimmed.startsWith('--') || trimmed.startsWith('/-') || trimmed.startsWith('/*') || trimmed.startsWith('*');
            
            // Highlight keywords
            processed = processed.replace(/\b(import|theorem|lemma|def|example|by|exact|apply|intro|intros|rw|simp|sorry|noncomputable|open|variable|structure|class|instance|inductive)\b/g, '<span style="color: var(--accent-color); font-weight: 600;">$1</span>');
            
            // Hyperlink known theorem references if not a comment line
            if (!isComment) {
                allThms.forEach(thm => {
                    const regex = new RegExp(`\\b${thm}\\b`, 'g');
                    if (regex.test(line)) {
                        const isDecl = trimmed.startsWith("theorem " + thm) || trimmed.startsWith("lemma " + thm) || trimmed.startsWith("def " + thm) || trimmed.startsWith("example " + thm);
                        if (!isDecl) {
                            processed = processed.replace(regex, `<a href="#" class="thm-ref-link" data-thm="${thm}" style="color: #10b981; text-decoration: underline; text-decoration-style: dotted; cursor: pointer;">${thm}</a>`);
                        } else {
                            processed = processed.replace(regex, `<span id="decl-${thm}" style="color: #eab308; font-weight: bold; background: rgba(234, 179, 8, 0.15); padding: 1px 4px; border-radius: 3px;">${thm}</span>`);
                        }
                    }
                });
            }

            highlightedHtml += `<div class="code-line" style="display: flex;"><span class="line-num" style="user-select: none; width: 45px; text-align: right; padding-right: 15px; color: var(--text-muted); opacity: 0.5; flex-shrink: 0;">${idx + 1}</span><span class="line-code" style="flex: 1;">${processed}</span></div>`;
        });

        const formattedSize = fileItem.size > 1024 ? (fileItem.size / 1024).toFixed(1) + ' KB' : fileItem.size + ' B';

        return `
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 16px;">
                <div>
                    <h2 style="margin: 0 0 6px 0; font-family: var(--font-mono); font-size: 20px; color: var(--text-color);">${escapeHTML(fileItem.name)}</h2>
                    <div style="color: var(--text-muted); font-size: 13px; line-height: 1.6;">
                        Path: <code>Catalog/${escapeHTML(filePath)}</code> &middot; Size: ${formattedSize}
                    </div>
                </div>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <button id="copy-catalog-link-btn" class="lean-download-btn" style="font-size: 0.82em; padding: 6px 12px; background: linear-gradient(135deg, #3b82f6, #1d4ed8); color: white; border: none; border-radius: 6px; cursor: pointer; display: flex; align-items: center; gap: 6px;" title="Copy shareable direct URL link to this file">
                        🔗 Copy Link
                    </button>
                    <button id="download-catalog-file-btn" class="lean-download-btn" style="font-size: 0.82em; padding: 6px 12px; background: var(--bg-tertiary, #333); color: var(--text-color); border: 1px solid var(--border-color); border-radius: 6px; cursor: pointer; display: flex; align-items: center; gap: 6px;" title="Download raw .lean source file">
                        ⬇ Download .lean
                    </button>
                </div>
            </div>
            <pre style="background: #1e1e1e; color: #d4d4d4; padding: 16px 12px; border-radius: 8px; overflow-x: auto; font-family: var(--font-mono); font-size: 13px; line-height: 1.6; border: 1px solid #333;"><code class="language-lean">${highlightedHtml}</code></pre>
        `;
    }

    function attachDetailEventListeners(filePath, code) {
        const detailContainer = document.getElementById('lean-catalog-detail');
        if (!detailContainer) return;

        // Copy link button handler
        const copyBtn = document.getElementById('copy-catalog-link-btn');
        if (copyBtn) {
            copyBtn.addEventListener('click', () => {
                const fullUrl = window.location.origin + window.location.pathname + '#catalog/' + filePath;
                navigator.clipboard.writeText(fullUrl).then(() => {
                    const origText = copyBtn.innerHTML;
                    copyBtn.innerHTML = '✓ Link Copied!';
                    copyBtn.style.background = '#10b981';
                    setTimeout(() => {
                        copyBtn.innerHTML = origText;
                        copyBtn.style.background = 'linear-gradient(135deg, #3b82f6, #1d4ed8)';
                    }, 2000);
                }).catch(err => {
                    console.error('Failed to copy link:', err);
                });
            });
        }

        // Download button handler
        const downloadBtn = document.getElementById('download-catalog-file-btn');
        if (downloadBtn) {
            downloadBtn.addEventListener('click', () => {
                const blob = new Blob([code], { type: 'text/plain;charset=utf-8' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = filePath.split('/').pop() || 'File.lean';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            });
        }

        // Theorem reference cross-linking handler
        detailContainer.querySelectorAll('.thm-ref-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const thm = link.getAttribute('data-thm');
                const targetFile = theoremIndex[thm];
                if (targetFile) {
                    loadFileDetail(targetFile.path, true).then(() => {
                        setTimeout(() => {
                            const declSpan = document.getElementById(`decl-${thm}`);
                            if (declSpan) {
                                declSpan.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                declSpan.style.backgroundColor = 'rgba(234, 179, 8, 0.4)';
                                declSpan.style.transition = 'background-color 1s ease-out';
                                setTimeout(() => { declSpan.style.backgroundColor = 'rgba(234, 179, 8, 0.15)'; }, 2000);
                            }
                        }, 150);
                    });
                }
            });
        });
    }

    if (domainFilter) domainFilter.addEventListener('change', renderCatalog);
    if (searchInput) searchInput.addEventListener('input', renderCatalog);

    // Initial Routing Check
    function checkInitialCatalogRoute() {
        const hash = window.location.hash;
        const search = window.location.search;

        let targetPath = null;
        const mHash = hash.match(/^#catalog[\/=\?](.+)$/i);
        if (mHash && mHash[1]) {
            targetPath = decodeURIComponent(mHash[1]).replace(/^file=/, '');
        } else if (hash.toLowerCase() === '#catalog' || hash.toLowerCase() === '#lean-catalog') {
            targetPath = null;
        }

        if (!targetPath && search) {
            const params = new URLSearchParams(search);
            targetPath = params.get('file') || params.get('catalog');
        }

        if (mHash || hash.toLowerCase() === '#catalog' || hash.toLowerCase() === '#lean-catalog' || targetPath) {
            showLeanCatalog(targetPath);
        }
    }

    setTimeout(checkInitialCatalogRoute, 100);
});
