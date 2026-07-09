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

    let allLeanFiles = [];
    let theoremIndex = {}; // theoremName -> { file, pkg }

    window.hideLeanCatalogView = function() {
        catalogView.classList.add('hidden');
        if (catalogLink) catalogLink.classList.remove('active');
    };

    async function showLeanCatalog() {
        if (welcomeScreen) welcomeScreen.classList.add('hidden');
        if (packageView) packageView.classList.add('hidden');
        if (directionsView) directionsView.classList.add('hidden');
        if (window.hideDirectionsView) window.hideDirectionsView();
        
        catalogView.classList.remove('hidden');
        catalogLink.classList.add('active');
        
        // Deselect active package if any
        if (window.Aether && window.Aether.currentPackage) {
            window.Aether.currentPackage = null;
            document.querySelectorAll('#package-list li').forEach(li => li.classList.remove('active'));
        }

        if (allLeanFiles.length === 0) {
            await buildCatalogData();
        } else {
            renderCatalog();
        }
    }

    catalogLink.addEventListener('click', (e) => {
        e.preventDefault();
        showLeanCatalog();
    });

    async function buildCatalogData() {
        if (!window.PACKAGE_INDEX) return;
        
        allLeanFiles = [];
        theoremIndex = {};
        const domains = new Set();
        
        if (catalogContent) {
            catalogContent.innerHTML = '<div style="padding: 24px; text-align: center; color: var(--text-muted);">Loading Lean proof catalog...</div>';
        }

        const promises = window.PACKAGE_INDEX.map(pkgMeta => {
            if (pkgMeta.domain) domains.add(pkgMeta.domain);
            
            const filename = pkgMeta.filename || (pkgMeta.exp_id + '.package.json');
            return fetch(`${filename}`)
                .then(res => res.json())
                .then(pkg => {
                    let leanFiles = [];
                    
                    function parseLeanString(lp, slug) {
                        const parsedFiles = [];
                        // Matches "-- NEW_FILE: path.lean", "-- DIFF: path.lean", or just "-- path.lean"
                        const parts = lp.split(/--\s*(?:NEW_FILE:\s*|DIFF:\s*|)([a-zA-Z0-9_\-\.\/]+\.lean)(?:\r?\n|\\n)/);
                        if (parts.length > 1) {
                            for (let i = 1; i < parts.length; i += 2) {
                                const name = parts[i].trim();
                                const code = (i + 1 < parts.length) ? parts[i + 1].trim().split('\\n').join('\n') : '';
                                if (code) parsedFiles.push({ file: name, name: name.split('/').pop(), code: code });
                            }
                        } else {
                            parsedFiles.push({ file: slug + '.lean', name: slug + '.lean', code: lp.split('\\n').join('\n') });
                        }
                        return parsedFiles;
                    }
                    
                    if (pkg.lean_proofs) {
                        const slug = (pkg.title || 'Proof').replace(/[^a-zA-Z0-9]/g, '').slice(0, 30) || 'Proof';
                        if (typeof pkg.lean_proofs === 'string') {
                            const lp = pkg.lean_proofs;
                            if (lp.length > 50 && !lp.endsWith('.lean')) {
                                leanFiles.push(...parseLeanString(lp, slug));
                            }
                        } else if (Array.isArray(pkg.lean_proofs)) {
                            for (let j = 0; j < pkg.lean_proofs.length; j++) {
                                const entry = pkg.lean_proofs[j];
                                if (typeof entry === 'string') {
                                    if (entry.length > 50 && !entry.endsWith('.lean')) {
                                        // For multiple string entries without names, append an index to the slug
                                        const entrySlug = pkg.lean_proofs.length > 1 ? `${slug}_${j+1}` : slug;
                                        leanFiles.push(...parseLeanString(entry, entrySlug));
                                    }
                                } else if (typeof entry === 'object' && entry !== null) {
                                    const fname = entry.file || entry.name || 'Proof.lean';
                                    const basename = fname.split('/').pop();
                                    let rawCode = (entry.code && entry.code.trim()) ? entry.code : (entry.content && entry.content.trim()) ? entry.content : null;
                                    if (rawCode) {
                                        leanFiles.push({ file: fname, name: basename, code: rawCode.split('\\n').join('\n') });
                                    }
                                }
                            }
                        }
                    }

                    if (leanFiles.length > 0) {
                        leanFiles.forEach(proof => {
                            const fileObj = {
                                pkg: pkgMeta,
                                file: proof.file,
                                name: proof.name,
                                code: proof.code,
                                domain: pkgMeta.domain,
                                theorems: []
                            };
                            
                            // Extract theorem names from code for hyperlinking
                            const lines = proof.code.split('\n');
                            const declRegex = /^(?:theorem|lemma|def|example)\s+([a-zA-Z0-9_]+)/;
                            lines.forEach(line => {
                                const match = line.match(declRegex);
                                if (match && match[1]) {
                                    const thmName = match[1];
                                    fileObj.theorems.push(thmName);
                                    theoremIndex[thmName] = fileObj;
                                }
                            });
                            
                            allLeanFiles.push(fileObj);
                        });
                    }
                })
                .catch(err => console.error("Error loading package", pkgMeta.exp_id, err));
        });

        await Promise.all(promises);

        // Update domain filter
        if (domainFilter && domainFilter.options.length <= 1) {
            Array.from(domains).sort().forEach(d => {
                const opt = document.createElement('option');
                opt.value = d;
                opt.textContent = d;
                domainFilter.appendChild(opt);
            });
        }
        
        renderCatalog();
    }
        


    function renderCatalog() {
        if (!catalogContent) return;
        
        const filterDomain = domainFilter ? domainFilter.value : '';
        const filterText = searchInput ? searchInput.value.toLowerCase() : '';
        
        let html = '<style>#lean-catalog-content summary::marker { content: ""; } #lean-catalog-content summary::-webkit-details-marker { display: none; }</style>';
        html += '<div style="display: flex; gap: 20px; height: calc(100vh - 150px);">';
        
        // Sidebar list
        html += '<div style="flex: 0 0 350px; overflow-y: auto; border-right: 1px solid var(--border-color); padding-right: 15px;">';
        
        let filteredCount = 0;
        
        // Build Tree
        const root = { type: 'dir', name: 'Root', children: {} };
        
        allLeanFiles.forEach((f, idx) => {
            if (filterDomain && f.domain !== filterDomain) return;
            if (filterText && !f.name.toLowerCase().includes(filterText) && !f.theorems.some(t => t.toLowerCase().includes(filterText))) return;
            
            filteredCount++;
            
            const parts = f.file.split('/');
            if (parts[0] === 'Catalog') parts.shift();
            
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
        
        // Recursive render function
        function renderTree(node, depth, isRoot = false) {
            let res = '';
            
            // Sort children: directories first, then files, then alphabetically
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
                    // Open details automatically if there is a search filter, or if it's the root level
                    const openAttr = (filterText || filterDomain || depth === 0) ? 'open' : '';
                    res += `
                        <details ${openAttr} style="margin-left: ${isRoot ? 0 : 12}px; margin-bottom: 2px;">
                            <summary style="cursor: pointer; font-weight: 500; padding: 4px 0; color: var(--text-color); font-size: 14px; user-select: none; display: flex; align-items: center;">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px; flex-shrink: 0; color: var(--accent-color);"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                                <span>${child.name}</span>
                            </summary>
                            <div style="border-left: 1px solid var(--border-color); padding-left: 6px; margin-top: 2px; margin-left: 7px;">
                                ${renderTree(child, depth + 1)}
                            </div>
                        </details>
                    `;
                } else {
                    const f = child.fileObj;
                    const idx = child.idx;
                    res += `
                        <div class="lean-file-card" data-idx="${idx}" style="margin-left: ${isRoot ? 0 : 12}px; padding: 4px 0; margin-bottom: 2px; cursor: pointer; transition: opacity 0.2s; opacity: 0.85;">
                            <div class="lean-file-card-title" style="font-weight: 400; font-size: 14px; word-break: break-all; color: var(--text-color); display: flex; align-items: center; transition: color 0.2s;">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px; flex-shrink: 0; color: inherit;"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>
                                <span>${f.name}</span>
                            </div>
                        </div>
                    `;
                }
            }
            return res;
        }
        
        if (filteredCount === 0) {
            html += '<div style="color: var(--text-muted); font-size: 13px; text-align: center; margin-top: 20px;">No files found matching criteria.</div>';
        } else {
            html += renderTree(root, 0, true);
        }
        
        html += '</div>';
        
        // Main content area
        html += '<div id="lean-catalog-detail" style="flex: 1; min-width: 0; background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: 8px; padding: 24px; overflow-y: auto;">';
        html += '<div style="color: var(--text-muted); text-align: center; margin-top: 100px; font-size: 16px;">Select a Lean 4 file from the list to view its code and cross-references.</div>';
        html += '</div>';
        
        html += '</div>';
        catalogContent.innerHTML = html;
        
        // Attach events
        document.querySelectorAll('.lean-file-card').forEach(card => {
            card.addEventListener('click', () => {
                document.querySelectorAll('.lean-file-card').forEach(c => {
                    c.style.opacity = '0.8';
                    const title = c.querySelector('.lean-file-card-title');
                    if (title) title.style.color = 'var(--text-color)';
                });
                card.style.opacity = '1';
                const title = card.querySelector('.lean-file-card-title');
                if (title) title.style.color = 'var(--accent-color)';
                const idx = parseInt(card.getAttribute('data-idx'));
                renderFileDetail(allLeanFiles[idx]);
            });
            // Hover effect
            card.addEventListener('mouseenter', () => {
                card.style.opacity = '1';
            });
            card.addEventListener('mouseleave', () => {
                const title = card.querySelector('.lean-file-card-title');
                if (!title || title.style.color !== 'var(--accent-color)') {
                    card.style.opacity = '0.8';
                }
            });
        });
    }

    function renderFileDetail(fileObj) {
        const detailContainer = document.getElementById('lean-catalog-detail');
        if (!detailContainer) return;
        
        // Highlight logic with cross-referencing
        const lines = fileObj.code.split('\n');
        let highlightedHtml = '';
        
        // Extract all known theorem names for fast matching
        const allThms = Object.keys(theoremIndex).sort((a,b) => b.length - a.length); // match longer names first
        
        lines.forEach(line => {
            let processedLine = line
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;");
                
            // Very naive keyword highlighting
            processedLine = processedLine.replace(/\b(import|theorem|lemma|def|example|by|exact|apply|intro|intros|rw|simp|sorry|noncomputable|open)\b/g, '<span style="color: var(--accent-color); font-weight: 600;">$1</span>');
            
            // Hyperlink known theorems (excluding standard keywords)
            allThms.forEach(thm => {
                // Ensure whole word match to avoid partial replacements
                const regex = new RegExp(`\\b${thm}\\b`, 'g');
                if (regex.test(line)) {
                    const targetFile = theoremIndex[thm];
                    // Don't hyperlink if it's the declaration itself
                    const isDecl = line.trim().startsWith("theorem " + thm) || line.trim().startsWith("lemma " + thm) || line.trim().startsWith("def " + thm);
                    if (!isDecl) {
                        processedLine = processedLine.replace(regex, `<a href="#" class="thm-ref-link" data-thm="${thm}" style="color: #10b981; text-decoration: underline; text-decoration-style: dotted; cursor: pointer;">${thm}</a>`);
                    } else {
                        processedLine = processedLine.replace(regex, `<span id="decl-${thm}" style="color: #eab308; font-weight: bold;">${thm}</span>`);
                    }
                }
            });
            
            highlightedHtml += processedLine + '\n';
        });

        detailContainer.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; border-bottom: 1px solid var(--border-color); padding-bottom: 20px;">
                <div>
                    <h2 style="margin: 0 0 8px 0; font-family: var(--font-mono); font-size: 20px; color: var(--text-color);">${fileObj.name}</h2>
                    <div style="color: var(--text-muted); font-size: 14px; line-height: 1.6;">
                        Path: <code>${fileObj.file}</code><br>
                        Package: <a href="#" class="pkg-link" data-pkg-id="${fileObj.pkg.exp_id}" style="color: var(--accent-color); text-decoration: none;">${fileObj.pkg.title}</a>
                    </div>
                </div>
                <div style="text-align: right; display: flex; flex-direction: column; gap: 8px;">
                    <span class="tag domain-tag" style="align-self: flex-end;">${fileObj.domain}</span>
                    <span class="tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.2); align-self: flex-end;">${fileObj.theorems.length} declarations</span>
                </div>
            </div>
            <pre style="background: #1e1e1e; color: #d4d4d4; padding: 20px; border-radius: 8px; overflow-x: auto; font-family: var(--font-mono); font-size: 14px; line-height: 1.6; border: 1px solid #333;"><code class="language-lean">${highlightedHtml}</code></pre>
        `;
        
        // Attach click events for theorem references
        detailContainer.querySelectorAll('.thm-ref-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const thm = link.getAttribute('data-thm');
                const targetFile = theoremIndex[thm];
                if (targetFile) {
                    const targetIdx = allLeanFiles.indexOf(targetFile);
                    if (targetIdx !== -1) {
                        // Highlight the sidebar item
                        document.querySelectorAll('.lean-file-card').forEach(c => c.style.borderColor = 'var(--border-color)');
                        const targetCard = document.querySelector(`.lean-file-card[data-idx="${targetIdx}"]`);
                        if (targetCard) {
                            targetCard.style.borderColor = 'var(--accent-color)';
                            targetCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                        }
                        
                        // Render target file and scroll to declaration
                        renderFileDetail(targetFile);
                        setTimeout(() => {
                            const declSpan = document.getElementById(`decl-${thm}`);
                            if (declSpan) {
                                declSpan.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                declSpan.parentElement.style.backgroundColor = 'rgba(234, 179, 8, 0.2)';
                                declSpan.parentElement.style.transition = 'background-color 1s ease-out';
                                setTimeout(() => { declSpan.parentElement.style.backgroundColor = 'transparent'; }, 2000);
                            }
                        }, 100);
                    }
                }
            });
        });
        
        // Attach click event to go to package
        const pkgLink = detailContainer.querySelector('.pkg-link');
        if (pkgLink) {
            pkgLink.addEventListener('click', (e) => {
                e.preventDefault();
                const expId = pkgLink.getAttribute('data-pkg-id');
                const pkg = window.PACKAGE_INDEX.find(p => p.exp_id === expId);
                if (pkg && window.loadPackage) {
                    // Hide Lean Catalog and show package view
                    window.hideLeanCatalogView();
                    const packageView = document.getElementById('package-view');
                    if (packageView) packageView.classList.remove('hidden');
                    window.loadPackage(pkg.filename || (expId + '.package.json'));
                }
            });
        }
    }

    if (domainFilter) {
        domainFilter.addEventListener('change', renderCatalog);
    }
    if (searchInput) {
        searchInput.addEventListener('input', renderCatalog);
    }
});
