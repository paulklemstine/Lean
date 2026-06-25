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
                    if (pkg.lean_proofs) {
                        if (typeof pkg.lean_proofs === 'string') {
                            const lp = pkg.lean_proofs;
                            if (lp.length > 50 && !lp.endsWith('.lean')) {
                                const parts = lp.split(/-- (?:NEW_FILE|DIFF): (.+?)\n/);
                                if (parts.length > 1) {
                                    for (let i = 1; i < parts.length; i += 2) {
                                        const name = parts[i].trim();
                                        const code = (i + 1 < parts.length) ? parts[i + 1].trim() : '';
                                        if (code) leanFiles.push({ file: name, name: name.split('/').pop(), code: code });
                                    }
                                } else {
                                    const slug = (pkg.title || 'Proof').replace(/[^a-zA-Z0-9]/g, '').slice(0, 30) || 'Proof';
                                    leanFiles.push({ file: slug + '.lean', name: slug + '.lean', code: lp });
                                }
                            }
                        } else if (Array.isArray(pkg.lean_proofs)) {
                            for (const entry of pkg.lean_proofs) {
                                if (typeof entry === 'string') {
                                    if (entry.length > 50 && !entry.endsWith('.lean')) {
                                        const slug = (pkg.title || 'Proof').replace(/[^a-zA-Z0-9]/g, '').slice(0, 30) || 'Proof';
                                        leanFiles.push({ file: slug + '.lean', name: slug + '.lean', code: entry });
                                    }
                                } else if (typeof entry === 'object' && entry !== null) {
                                    const fname = entry.file || entry.name || 'Proof.lean';
                                    const basename = fname.split('/').pop();
                                    const code = (entry.code && entry.code.trim()) ? entry.code : (entry.content && entry.content.trim()) ? entry.content : null;
                                    if (code) {
                                        leanFiles.push({ file: fname, name: basename, code: code });
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
        
        let html = '<div style="display: flex; gap: 20px; height: calc(100vh - 150px);">';
        
        // Sidebar list
        html += '<div style="flex: 0 0 350px; overflow-y: auto; border-right: 1px solid var(--border-color); padding-right: 15px;">';
        
        let filteredCount = 0;
        allLeanFiles.forEach((f, idx) => {
            if (filterDomain && f.domain !== filterDomain) return;
            if (filterText && !f.name.toLowerCase().includes(filterText) && !f.theorems.some(t => t.toLowerCase().includes(filterText))) return;
            
            filteredCount++;
            html += `
                <div class="lean-file-card" data-idx="${idx}" style="padding: 12px; border: 1px solid var(--border-color); border-radius: 6px; margin-bottom: 12px; cursor: pointer; background: var(--bg-secondary); transition: all 0.2s;">
                    <div style="font-weight: 600; font-family: var(--font-mono); font-size: 14px; word-break: break-all; color: var(--text-color);">${f.name}</div>
                    <div style="font-size: 12px; color: var(--text-muted); margin-top: 6px; display: flex; justify-content: space-between;">
                        <span>${f.domain}</span>
                        <span style="color: #10b981;">${f.theorems.length} theorems</span>
                    </div>
                </div>
            `;
        });
        
        if (filteredCount === 0) {
            html += '<div style="color: var(--text-muted); font-size: 13px; text-align: center; margin-top: 20px;">No files found matching criteria.</div>';
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
                document.querySelectorAll('.lean-file-card').forEach(c => c.style.borderColor = 'var(--border-color)');
                card.style.borderColor = 'var(--accent-color)';
                const idx = parseInt(card.getAttribute('data-idx'));
                renderFileDetail(allLeanFiles[idx]);
            });
            // Hover effect
            card.addEventListener('mouseenter', () => {
                if (card.style.borderColor !== 'var(--accent-color)') {
                    card.style.borderColor = 'var(--text-muted)';
                }
            });
            card.addEventListener('mouseleave', () => {
                if (card.style.borderColor !== 'var(--accent-color)') {
                    card.style.borderColor = 'var(--border-color)';
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
            processedLine = processedLine.replace(/\\b(import|theorem|lemma|def|example|by|exact|apply|intro|intros|rw|simp|sorry|noncomputable|open)\\b/g, '<span style="color: var(--accent-color); font-weight: 600;">$1</span>');
            
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
            
            highlightedHtml += processedLine + '\\n';
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
