// Aether — Shared State & Utilities
window.Aether = {
    packages: [],
    currentPackage: null,
    directionsVisible: false,
    pyodideInstance: null,
    isPyodideLoading: false,
    currentVizIndex: 0,
};

window.escapeHtml = function(unsafe) {
    return unsafe
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
};