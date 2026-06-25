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

    let catalogTree = null;

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

        if (!catalogTree) {
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
        if (catalogContent) {
            catalogContent.innerHTML = '<div style="padding: 24px; text-align: center; color: var(--text-muted);">Loading Lean proof catalog tree...</div>';
        }

        try {
            const res = await fetch('catalog_tree.json');
            catalogTree = await res.json();
        } catch (err) {
            console.error("Error loading catalog_tree.json", err);
            catalogContent.innerHTML = '<div style="padding: 24px; text-align: center; color: #ef4444;">Failed to load catalog tree. Please run update_index.py.</div>';
            return;
        }

        renderCatalog();
    }

    function renderTree(node, filterText) {
        if (node.type === 'file') {
            if (filterText && !node.name.toLowerCase().includes(filterText)) return '';
            return `
                <div class="lean-file-item" data-path="${node.path}" data-name="${node.name}" style="padding: 4px 8px; cursor: pointer; color: var(--text-color); border-radius: 4px; font-family: var(--font-mono); font-size: 13px; margin-bottom: 2px; transition: background 0.1s;">
                    <svg style="vertical-align: middle; margin-right: 6px; color: #10b981;" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/></svg>
                    ${node.name}
                </div>
            `;
        }

        if (node.type === 'directory') {
            let childrenHtml = '';
            let hasVisibleChildren = false;
            
            if (node.children) {
                node.children.forEach(child => {
                    const childHtml = renderTree(child, filterText);
                    if (childHtml) {
                        childrenHtml += childHtml;
                        hasVisibleChildren = true;
                    }
                });
            }

            if (!hasVisibleChildren && filterText) return '';

            // Open directories by default if there's a search filter, otherwise closed
            const isOpen = filterText ? 'open' : '';
            // For the top level "Catalog" directory, open it by default
            const openAttr = (node.name === 'Catalog' || isOpen) ? 'open' : '';

            return `
                <details ${openAttr} style="margin-bottom: 6px;">
                    <summary class="lean-folder-item" style="cursor: pointer; font-weight: 600; color: var(--text-color); padding: 6px 8px; user-select: none; font-size: 14px; border-radius: 4px; transition: background 0.2s; background: rgba(0, 0, 0, 0.1); border: 1px solid transparent;">
                        <svg style="vertical-align: middle; margin-right: 8px; color: var(--accent-color);" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                        ${node.name}
                    </summary>
                    <div style="margin-left: 12px; margin-top: 4px; border-left: 2px solid rgba(255, 255, 255, 0.05); padding-left: 8px;">
                        ${childrenHtml}
                    </div>
                </details>
            `;
        }
        return '';
    }

    function renderCatalog() {
        if (!catalogContent || !catalogTree) return;
        
        const filterText = searchInput ? searchInput.value.toLowerCase() : '';
        
        let html = '<div style="display: flex; gap: 20px; height: calc(100vh - 150px);">';
        
        // Sidebar list (File Explorer)
        html += '<div style="flex: 0 0 350px; overflow-y: auto; border-right: 1px solid var(--border-color); padding-right: 15px;">';
        
        const treeHtml = renderTree(catalogTree, filterText);
        
        if (!treeHtml) {
            html += '<div style="color: var(--text-muted); font-size: 13px; text-align: center; margin-top: 20px;">No files found matching criteria.</div>';
        } else {
            html += treeHtml;
        }
        
        html += '</div>';
        
        // Main content area
        html += '<div id="lean-catalog-detail" style="flex: 1; min-width: 0; background: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: 8px; padding: 24px; overflow-y: auto;">';
        html += '<div style="color: var(--text-muted); text-align: center; margin-top: 100px; font-size: 16px;">Select a Lean 4 file from the file explorer to view its source code.</div>';
        html += '</div>';
        
        html += '</div>';
        catalogContent.innerHTML = html;
        
        // Attach click events to file items
        document.querySelectorAll('.lean-file-item').forEach(item => {
            item.addEventListener('click', async () => {
                // Highlight active item
                document.querySelectorAll('.lean-file-item').forEach(i => {
                    i.style.background = 'transparent';
                });
                item.style.background = 'rgba(59, 130, 246, 0.1)';
                
                const path = item.getAttribute('data-path');
                const name = item.getAttribute('data-name');
                await loadAndRenderFile(path, name);
            });

            // Hover effect
            item.addEventListener('mouseenter', () => {
                if (item.style.background !== 'rgba(59, 130, 246, 0.1)') {
                    item.style.background = 'var(--bg-hover)';
                }
            });
            item.addEventListener('mouseleave', () => {
                if (item.style.background !== 'rgba(59, 130, 246, 0.1)') {
                    item.style.background = 'transparent';
                }
            });
        });

        // Hover effects for folders
        document.querySelectorAll('summary').forEach(summary => {
            summary.addEventListener('mouseenter', () => {
                summary.style.background = 'var(--bg-hover)';
            });
            summary.addEventListener('mouseleave', () => {
                summary.style.background = 'transparent';
            });
        });
    }

    async function loadAndRenderFile(path, name) {
        const detailContainer = document.getElementById('lean-catalog-detail');
        if (!detailContainer) return;

        detailContainer.innerHTML = '<div style="color: var(--text-muted); text-align: center; margin-top: 100px; font-size: 16px;">Fetching source code from GitHub...</div>';

        try {
            const rawUrl = 'https://raw.githubusercontent.com/paulklemstine/Lean/master/' + path;
            const res = await fetch(rawUrl);
            if (!res.ok) throw new Error("Failed to fetch");
            const code = await res.text();

            renderFileDetail(name, path, code, rawUrl);
        } catch (err) {
            console.error(err);
            detailContainer.innerHTML = '<div style="color: #ef4444; text-align: center; margin-top: 100px; font-size: 16px;">Failed to load file. It might be missing from the repository.</div>';
        }
    }

    function renderFileDetail(name, path, code, rawUrl) {
        const detailContainer = document.getElementById('lean-catalog-detail');
        if (!detailContainer) return;
        
        // Fix any potential literal \\n
        const codeStr = code.replace(/\\\\n/g, '\\n');
        const lines = codeStr.split('\\n');
        let highlightedHtml = '';
        
        lines.forEach(line => {
            let processedLine = line
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;");
                
            // Naive keyword highlighting
            processedLine = processedLine.replace(/\\b(import|theorem|lemma|def|example|by|exact|apply|intro|intros|rw|simp|sorry|noncomputable|open|namespace|end|class|instance|structure|axiom|inductive|match|with|have|let)\\b/g, '<span style="color: var(--accent-color); font-weight: 600;">$1</span>');
            
            highlightedHtml += processedLine + '\\n';
        });

        detailContainer.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; border-bottom: 1px solid var(--border-color); padding-bottom: 20px;">
                <div>
                    <h2 style="margin: 0 0 8px 0; font-family: var(--font-mono); font-size: 20px; color: var(--text-color);">${name}</h2>
                    <div style="color: var(--text-muted); font-size: 14px; line-height: 1.6;">
                        Path: <code>${path}</code>
                    </div>
                </div>
                <div style="text-align: right;">
                    <a href="${rawUrl}" target="_blank" style="color: var(--accent-color); text-decoration: none; font-size: 14px; border: 1px solid var(--accent-color); padding: 4px 12px; border-radius: 4px; transition: background 0.2s;">View Raw on GitHub</a>
                </div>
            </div>
            <pre style="background: #1e1e1e; color: #d4d4d4; padding: 20px; border-radius: 8px; overflow-x: auto; font-family: var(--font-mono); font-size: 14px; line-height: 1.6; border: 1px solid #333;"><code class="language-lean">${highlightedHtml}</code></pre>
        `;
    }

    if (domainFilter) {
        domainFilter.style.display = 'none';
    }
    if (searchInput) {
        searchInput.addEventListener('input', renderCatalog);
    }
});
