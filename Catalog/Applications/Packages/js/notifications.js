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

        // Browser notification
        if ('Notification' in window && Notification.permission === 'granted') {
            try {
                const n = new Notification(title, { body, icon: 'visualizations/favicon.svg', tag: 'aether-new-packages' });
                n.onclick = () => { window.focus(); n.close(); };
            } catch { /* Notification constructor can fail in some contexts */ }
        }

        // In-app toast
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

        requestPermission();
    }

    // Called when the poll detects new packages
    function onNewPackages(allPackages, newFilenames) {
        const newPkgs = allPackages.filter(p => newFilenames.includes(p.filename));
        if (!newPkgs.length) return;

        markSeen(newFilenames);
        notify(newPkgs);
    }

    return { init, onNewPackages, findNew, markSeen };
})();