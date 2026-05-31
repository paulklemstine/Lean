window.AetherNotifications = (() => {
    const STORAGE_KEY = 'aether_seen_packages';
    const PERMISSION_PROMPT_KEY = 'aether_notification_prompted';

    function getSeen() {
        try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); }
        catch { return []; }
    }

    function setSeen(filenames) {
        try { localStorage.setItem(STORAGE_KEY, JSON.stringify(filenames)); }
        catch { /* quota exceeded, ignore */ }
    }

    function markSeen(filenames) {
        const seen = new Set(getSeen());
        filenames.forEach(f => seen.add(f));
        setSeen([...seen]);
    }

    function findNew(filenames) {
        const seen = new Set(getSeen());
        return filenames.filter(f => !seen.has(f));
    }

    function requestPermission() {
        if (!('Notification' in window)) return;
        if (Notification.permission === 'granted') return;
        if (Notification.permission === 'denied') return;
        // Only ask once per session
        if (sessionStorage.getItem(PERMISSION_PROMPT_KEY)) return;
        sessionStorage.setItem(PERMISSION_PROMPT_KEY, '1');
        Notification.requestPermission();
    }

    function notify(newPackages) {
        if (!newPackages.length) return;
        const count = newPackages.length;
        const title = count === 1
            ? 'New Research Package'
            : `${count} New Research Packages`;
        const body = count === 1
            ? newPackages[0].title || newPackages[0].filename
            : newPackages.slice(0, 3).map(p => p.title || p.filename).join('\n')
              + (count > 3 ? `\n...and ${count - 3} more` : '');

        console.log('[Aether] Showing notification:', title, body.replace(/\n/g, ' | '));

        // Browser notification
        if ('Notification' in window && Notification.permission === 'granted') {
            try {
                const n = new Notification(title, { body, icon: 'favicon.svg', tag: 'aether-new-packages' });
                n.onclick = () => { window.focus(); n.close(); };
            } catch (e) { console.warn('[Aether] Browser notification failed:', e); }
        } else {
            console.log('[Aether] Browser notification not available (permission:', Notification.permission, ')');
        }

        // In-app toast (always shown)
        showToast(title, body, newPackages);
    }

    function showToast(title, body, newPackages) {
        const existing = document.getElementById('aether-toast');
        if (existing) existing.remove();

        const toast = document.createElement('div');
        toast.id = 'aether-toast';
        toast.innerHTML = `
            <div class="toast-title">${title}</div>
            <div class="toast-body">${body}</div>
        `;
        toast.addEventListener('click', () => {
            // Navigate to the first new package
            if (newPackages.length && window.loadPackage) {
                window.loadPackage(newPackages[0].filename);
            }
            toast.remove();
        });
        document.body.appendChild(toast);

        // Animate in
        requestAnimationFrame(() => toast.classList.add('toast-visible'));

        // Auto-dismiss after 8s
        setTimeout(() => {
            toast.classList.remove('toast-visible');
            setTimeout(() => toast.remove(), 400);
        }, 8000);
    }

    // Initialize: mark all current packages as seen, request permission
    function init(packages) {
        const filenames = (packages || []).map(p => p.filename);
        const hadSeenBefore = getSeen().length > 0;

        if (!hadSeenBefore) {
            // First visit: mark everything as seen so we don't spam
            markSeen(filenames);
        }

        console.log('[Aether] Notifications initialized. Packages:', filenames.length, 'Seen before:', hadSeenBefore, 'Notification permission:', 'Notification' in window ? Notification.permission : 'N/A');
        requestPermission();
    }

    // Called when the poll detects new packages
    function onNewPackages(allPackages, newFilenames) {
        const newPkgs = allPackages.filter(p => newFilenames.includes(p.filename));
        console.log('[Aether] onNewPackages called. Total:', allPackages.length, 'New filenames:', newFilenames.length, 'Matched packages:', newPkgs.length);
        if (!newPkgs.length) return;

        markSeen(newFilenames);
        notify(newPkgs);
    }

    // Manual check: trigger a notification test with current unseen packages
    function checkNow() {
        const currentIndex = window.PACKAGE_INDEX || [];
        const seen = new Set(getSeen());
        const unseen = currentIndex.filter(p => !seen.has(p.filename));
        console.log('[Aether] Manual check. Total packages:', currentIndex.length, 'Seen:', seen.size, 'Unseen:', unseen.length);
        if (unseen.length > 0) {
            const filenames = unseen.map(p => p.filename);
            markSeen(filenames);
            notify(unseen);
        } else {
            showToast('Up to Date', 'No new packages found. Total: ' + currentIndex.length, []);
        }
    }

    return { init, onNewPackages, findNew, markSeen, checkNow };
})();