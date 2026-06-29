// Aether — Image Lightbox
document.addEventListener('DOMContentLoaded', () => {
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightbox-img');
    const lightboxCaption = document.getElementById('lightbox-caption');
    const lightboxClose = document.getElementById('lightbox-close');
    const lightboxPrev = document.getElementById('lightbox-prev');
    const lightboxNext = document.getElementById('lightbox-next');

    window.openLightbox = function(index) {
        if (!window.Aether.currentPackage || !(window.Aether.currentPackage._vizImages || window.Aether.currentPackage.visualizations)) return;
        window.Aether.currentVizIndex = index;
        window.updateLightbox();
        lightbox.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    };

    window.closeLightbox = function() {
        lightbox.classList.add('hidden');
        document.body.style.overflow = '';
    };

    window.updateLightbox = function() {
        const pkg = window.Aether.currentPackage;
        if (!pkg) return;
        // Prefer _vizImages (has actual rendered image data) over visualizations (code definitions)
        const vizList = pkg._vizImages || pkg.visualizations;
        if (!vizList) return;
        const viz = vizList[window.Aether.currentVizIndex];
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

        const multiple = vizList.length > 1;
        lightboxPrev.style.display = multiple ? 'block' : 'none';
        lightboxNext.style.display = multiple ? 'block' : 'none';
    };

    function nextLightbox() {
        if (!window.Aether.currentPackage) return;
        const vizList = window.Aether.currentPackage._vizImages || window.Aether.currentPackage.visualizations;
        if (!vizList) return;
        window.Aether.currentVizIndex = (window.Aether.currentVizIndex + 1) % vizList.length;
        window.updateLightbox();
    }

    function prevLightbox() {
        if (!window.Aether.currentPackage) return;
        const vizList = window.Aether.currentPackage._vizImages || window.Aether.currentPackage.visualizations;
        if (!vizList) return;
        const len = vizList.length;
        window.Aether.currentVizIndex = (window.Aether.currentVizIndex - 1 + len) % len;
        window.updateLightbox();
    }

    lightboxClose.addEventListener('click', window.closeLightbox);
    lightboxPrev.addEventListener('click', prevLightbox);
    lightboxNext.addEventListener('click', nextLightbox);
    lightbox.addEventListener('click', (e) => {
        if (e.target === lightbox) window.closeLightbox();
    });

    document.addEventListener('keydown', (e) => {
        if (!lightbox.classList.contains('hidden')) {
            if (e.key === 'Escape') window.closeLightbox();
            if (e.key === 'ArrowRight') nextLightbox();
            if (e.key === 'ArrowLeft') prevLightbox();
        }
    });
});