// ═══════════════════════════════════════════════
// AETHER — Knowledge Graph Visualization
// ═══════════════════════════════════════════════
(function initKnowledgeGraph() {
    const canvas = document.getElementById('knowledge-graph-canvas') || document.getElementById('backrooms-canvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    const welcomeScreen = document.getElementById('welcome-screen');

    // ─── Data ───
    const graphData = window.PACKAGE_GRAPH || { nodes: [], edges: [], domain_bridges: [] };

    let rawNodes = graphData.nodes || [];
    rawNodes.sort((a, b) => {
        const d1 = a.date ? new Date(a.date).getTime() : 0;
        const d2 = b.date ? new Date(b.date).getTime() : 0;
        return d2 - d1;
    });
    rawNodes = rawNodes.slice(0, 500);
    const validNodeIds = new Set(rawNodes.map(n => n.id));

    const graphNodes = rawNodes.map(n => ({
        ...n,
        x: (Math.random() - 0.5) * 100, y: (Math.random() - 0.5) * 100, vx: 0, vy: 0,
        targetX: 0, targetY: 0,
        mass: 1.0 + (n.priority_score ?? 0.5) * 2.0,  // heavier = more priority
        radius: 16 + ((n.priority_score ?? 0.5) ** 0.7) * 20,    // bigger = more priority
        phase: Math.random() * Math.PI * 2,
        rotSpeed: 0.3 + Math.random() * 0.5,
        rotAngle: Math.random() * Math.PI * 2,
        thrustTime: 0, thrustAngle: 0, thrustStrength: 0,
        trail: [], radarPulse: null
    }));
    // Only provenance edges (no heuristic edges)
    let graphEdges = (graphData.edges || [])
        .filter(e => e.type === 'provenance' && validNodeIds.has(e.source) && validNodeIds.has(e.target))
        .map(e => ({
            ...e,
            edgeType: e.type,
        }));
    // Fast lookup: are two nodes connected by an edge?
    const connectedSet = new Set();
    graphEdges.forEach(e => { connectedSet.add(e.source + '|' + e.target); connectedSet.add(e.target + '|' + e.source); });
    function areConnected(idA, idB) { return connectedSet.has(idA + '|' + idB); }
    // Domain bridges for cluster-level connections
    const domainBridges = graphData.domain_bridges || [];

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
            return function () {
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

            // Initialize with slight offset and orbital velocity
            const angle = (rng() / 4294967296) * Math.PI * 2;
            const r = 200 + (rng() % 1000);
            const px = Math.cos(angle) * r;
            const py = Math.sin(angle) * r;
            const orbitalV = Math.sqrt(12.0 * 80.0 / Math.max(r, 50)) * 2.0;

            graphNodes.push({
                id: slug, title: pkg.title || slug, domain: pkg.domain || 'Bridges',
                primary_domain: 'Bridges', shape: DOMAIN_SHAPES[pkg.domain] || 'icosahedron',
                date: pkg.date || '', hue: (rng() % 360),
                x: px, y: py, vx: -py / r * orbitalV, vy: px / r * orbitalV, targetX: px, targetY: py, radius: 18,
                phase: rng() / 4294967296 * Math.PI * 2,
                rotSpeed: 0.3 + (rng() / 4294967296) * 0.5,
                rotAngle: rng() / 4294967296 * Math.PI * 2,
                thrustTime: 0, thrustAngle: 0, thrustStrength: 0
            });
        });
    }

    if (graphNodes.length === 0) return;

    // Assign package numbers from stable pkg_num in PACKAGE_INDEX
    if (window.PACKAGE_INDEX) {
        const numMap = {};
        window.PACKAGE_INDEX.forEach(pkg => {
            if (pkg.pkg_num) numMap[pkg.filename.replace('.json', '')] = pkg.pkg_num;
        });
        graphNodes.forEach(n => { n.pkgNum = numMap[n.id] || 0; });
    }

    // Expose to sidebar hover handlers
    window._graphNodes = graphNodes;
    window._setHoveredNode = function (node) { hoveredNode = node; };
    window._getHoveredNode = function () { return hoveredNode; };
    window._fadeWelcome = fadeWelcome;
    window._zoomToNodeCircle = function (nodeId) {
        hoverTrackId = nodeId;
        const comps = computeVisibleComponents();
        for (const circle of comps) {
            if (circle.nodeSet.has(nodeId)) {
                const minDim = Math.min(W || 800, H || 600);
                const targetZoom = minDim * 0.6 / (circle.r * 2);
                cameraTarget = { x: circle.cx, y: circle.cy, zoom: Math.min(targetZoom, 5) };
                return;
            }
        }
    };
    window._stopTrackingCircle = function () {
        hoverTrackId = null;
    };
    window._resetCamera = function () {
        camera = { x: 0, y: 0, zoom: 0.024 };
        cameraTarget = null;
        hoverTrackId = null;
    };

    const dynamicDomainColors = new Map();

    function getDomainHue(d) {
        if (dynamicDomainColors.size === 0) {
            const domains = new Set();
            graphNodes.forEach(n => domains.add(n.primary_domain || 'Bridges'));
            const sortedDomains = Array.from(domains).sort();
            const step = 360 / Math.max(1, sortedDomains.length);
            sortedDomains.forEach((domain, i) => {
                dynamicDomainColors.set(domain, i * step);
            });
        }
        return dynamicDomainColors.get(d) || 0;
    }

    function nodeColor(node) {
        const d = node.primary_domain || 'Bridges';
        const hue = getDomainHue(d);
        const score = node.priority_score ?? 0.5;
        const scoreBoost = (score - 0.5) * 30;
        return {
            h: hue,
            s: Math.min(100, Math.max(30, 75 + scoreBoost * 0.3)),
            l: Math.min(85, Math.max(35, 55 + scoreBoost))
        };
    }

    // ─── Canvas state ───
    let W, H;
    let animating = false;
    let rafId = null;
    let camera = { x: 0, y: 0, zoom: 0.024 };
    let cameraTarget = null; // { x, y, zoom } — smooth zoom-to target
    let hoverTrackId = null;  // node ID being tracked by hover zoom
    let dragNode = null;
    let dragCluster = null;   // domain string when dragging a cluster label
    let prevDragWorld = null; // previous frame world position for cluster drag delta
    let isPanning = false;
    let panStart = { x: 0, y: 0 };
    let mouseDownPos = { x: 0, y: 0 };
    let hasDragged = false;
    let welcomeFaded = false;
    let mouseWorld = { x: 0, y: 0 };
    let mouseScreen = { x: 0, y: 0 };
    let hoveredNode = null;
    let hoveredCluster = null;
    let time = 0;
    let timeScale = 1;

    function isReadingPackage() {
        if (welcomeScreen.classList.contains('hidden')) return true;
        const packageView = document.getElementById('package-view');
        if (packageView && !packageView.classList.contains('hidden')) return true;
        return false;
    }

    function startAnimation() {
        if (isReadingPackage()) {
            stopAnimation();
            return;
        }
        if (animating) return;
        animating = true;
        resize();
        if (rafId) {
            cancelAnimationFrame(rafId);
            rafId = null;
        }
        rafId = requestAnimationFrame(render);
    }

    function stopAnimation() {
        animating = false;
        if (rafId) {
            cancelAnimationFrame(rafId);
            rafId = null;
        }
    }



    // ─── Performance Caching ───
    const bgCanvas = document.createElement('canvas');
    const bgCtx = bgCanvas.getContext('2d', { alpha: false });
    let bgNeedsUpdate = true;

    const glowSprites = [];
    (function initGlowSprites() {
        for (let h = 0; h <= 360; h++) {
            const c = document.createElement('canvas');
            c.width = 64; c.height = 64;
            const cctx = c.getContext('2d');
            const grad = cctx.createRadialGradient(32, 32, 4, 32, 32, 32);
            grad.addColorStop(0, `hsla(${h}, 100%, 90%, 0.9)`);
            grad.addColorStop(0.3, `hsla(${h}, 100%, 70%, 0.6)`);
            grad.addColorStop(0.7, `hsla(${h}, 100%, 50%, 0.2)`);
            grad.addColorStop(1, `hsla(${h}, 100%, 20%, 0)`);
            cctx.fillStyle = grad;
            cctx.fillRect(0, 0, 64, 64);
            glowSprites[h] = c;
        }
    })();

    // ─── Stars (deep space backdrop) ───
    const stars = [];
    for (let i = 0; i < 250; i++) {
        stars.push({
            x: Math.random() * 8000 - 4000,
            y: Math.random() * 8000 - 4000,
            r: 0.3 + Math.random() * 1.0,
            brightness: 0.3 + Math.random() * 0.7,
            twinkleSpeed: 0.5 + Math.random() * 2,
            twinklePhase: Math.random() * Math.PI * 2,
            shimmer: Math.random() < 0.03
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

    // ─── Layout constants (space battle / nuclear dynamics) ───
    const CLUSTER_RADIUS = 15000;     // Distance of cluster centroids from center
    const NODE_SPACING = 3000;         // Spacing between nodes within a cluster
    const WORLD_SIZE = 9000000;         // Universe extent — Möbius-Klein bottle
    const WORLD_HALF = WORLD_SIZE / 2;
    const K_SPRING = 0;              // No continuous spring — edges are lazy
    const REST_LENGTH = 9000;          // Rest length for provenance springs
    const EDGE_DRAW_DISTANCE = 4000;  // Max distance to draw/spring edges (reduced from 9000 so they only connect when very close)
    const G_UNIVERSAL = 25.0;       // Universal gravitational constant (all pairs attract)
    const G_CLUSTER_MULT = 2.5;     // Same-cluster pairs attract more strongly
    const G_CORE = 12.0;            // Central galactic attractor pull
    const CORE_MASS = 80.0;         // Mass of the invisible central attractor
    const COULOMB_REPULSION = 500000.0; // Repulsive charge between nodes
    // Static repulsion pushes nodes apart, gravity pulls them together, rocket thrust on collision pushes apart
    const SOFTENING = 200;             // Softening distance (larger = gentler at close range)
    const MIN_REPULSION_DIST = 2400;    // Bumper collision radius
    const DAMPING = 0.85;              // High friction — keep graph elegant and slow
    const NODE_RADIUS = 22;
    const MAX_VELOCITY = 20.0;        // Gentle cap scaled to large universe (increased from 10.0)
    const BOUNCE = 0.0;              // Inelastic — smooth merges, no jittery bounces
    const THRUST_DURATION = 0.0;     // Disable rocket flames to reduce visual noise

    // ─── Domain-clustered layout ───
    const DOMAIN_ORDER = ['Algebra', 'Tropical', 'Geometry', 'Cryptography', 'Physics',
        'EML', 'Computation', 'MachineLearning', 'Logic', 'Pythagorean', 'Speculative', 'Bridges'];
    const domainIndexMap = {};
    DOMAIN_ORDER.forEach((d, i) => { domainIndexMap[d] = i; });

    function computeClusterLayout() {
        // Group nodes by primary_domain
        const clusters = {};
        graphNodes.forEach(n => {
            const domain = n.primary_domain || 'Bridges';
            if (!clusters[domain]) clusters[domain] = [];
            clusters[domain].push(n);
        });

        // Sort domains by DOMAIN_ORDER, unknown domains go last
        const domainList = Object.keys(clusters).sort((a, b) => {
            const ia = domainIndexMap[a] ?? 999;
            const ib = domainIndexMap[b] ?? 999;
            return ia - ib;
        });

        const numClusters = domainList.length;
        const clusterCentroids = {};
        const nodeAssignments = {};

        domainList.forEach((domain, ci) => {
            const angle = (ci / numClusters) * Math.PI * 2 - Math.PI / 2;
            const cx = Math.cos(angle) * CLUSTER_RADIUS;
            const cy = Math.sin(angle) * CLUSTER_RADIUS;
            clusterCentroids[domain] = { x: cx, y: cy, angle, domain };

            const nodes = clusters[domain];
            const innerRadius = Math.sqrt(nodes.length) * NODE_SPACING * 0.6;
            nodes.forEach((node, ni) => {
                const nodeAngle = (ni / nodes.length) * Math.PI * 2 + Math.random() * 0.3;
                const nodeR = innerRadius * (0.4 + Math.random() * 0.5);
                const tx = cx + Math.cos(nodeAngle) * nodeR;
                const ty = cy + Math.sin(nodeAngle) * nodeR;
                node.targetX = tx;
                node.targetY = ty;
                node.clusterDomain = domain;
                nodeAssignments[node.id] = domain;
            });
        });

        return { centroids: clusterCentroids, domainList };
    }

    // Minimum-image delta for Klein bottle topology — finds shortest path between two points
    const _miResult = { dx: 0, dy: 0, d2: 0 };
    const _miResult2 = { dx: 0, dy: 0, d2: 0 };
    function minImageDelta(ax, ay, bx, by, out = _miResult) {
        let bestDx = bx - ax, bestDy = by - ay;
        let bestD2 = bestDx * bestDx + bestDy * bestDy;
        // X-ghost (Y-flipped): Möbius twist on X-axis
        let gx = bx > ax ? bx - WORLD_SIZE : bx + WORLD_SIZE;
        let gy = -by;
        let dx = gx - ax, dy = gy - ay, d2 = dx * dx + dy * dy;
        if (d2 < bestD2) { bestDx = dx; bestDy = dy; bestD2 = d2; }
        // Y-ghost (X-flipped): Klein bottle twist on Y-axis
        gx = -bx; let gy2 = by > ay ? by - WORLD_SIZE : by + WORLD_SIZE;
        dx = gx - ax; dy = gy2 - ay; d2 = dx * dx + dy * dy;
        if (d2 < bestD2) { bestDx = dx; bestDy = dy; bestD2 = d2; }
        out.dx = bestDx;
        out.dy = bestDy;
        out.d2 = bestD2;
        return out;
    }

    // Check if line segment AB crosses segment CD
    function segmentsCross(ax, ay, bx, by, cx, cy, dx, dy) {
        const d1 = (bx - ax) * (cy - ay) - (by - ay) * (cx - ax);
        const d2 = (bx - ax) * (dy - ay) - (by - ay) * (dx - ax);
        const d3 = (dx - cx) * (ay - cy) - (dy - cy) * (ax - cx);
        const d4 = (dx - cx) * (by - cy) - (dy - cy) * (bx - cx);
        return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
            ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
    }

    // Minimum enclosing circle (Welzl's algorithm, Möbius-aware via local frame)
    function enclosingCircle(nodes) {
        if (nodes.length === 0) return { cx: 0, cy: 0, r: 0 };
        if (nodes.length === 1) return { cx: nodes[0].x, cy: nodes[0].y, r: 0 };
        // Project all nodes into local frame anchored to first node
        const anchor = nodes[0];
        const pts = [{ x: 0, y: 0 }];
        for (let i = 1; i < nodes.length; i++) {
            const mi = minImageDelta(anchor.x, anchor.y, nodes[i].x, nodes[i].y);
            pts.push({ x: mi.dx, y: mi.dy });
        }
        function ldist(a, b) { const dx = b.x - a.x, dy = b.y - a.y; return Math.sqrt(dx * dx + dy * dy); }
        function circle1(p) { return { x: p.x, y: p.y, r: 0 }; }
        function circle2(a, b) {
            return { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2, r: ldist(a, b) / 2 };
        }
        function circle3(a, b, c) {
            const d = 2 * (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y));
            if (Math.abs(d) < 1e-10) {
                const d1 = ldist(a, b), d2 = ldist(b, c), d3 = ldist(a, c);
                if (d1 >= d2 && d1 >= d3) return circle2(a, b);
                if (d2 >= d3) return circle2(b, c);
                return circle2(a, c);
            }
            const ux = ((a.x * a.x + a.y * a.y) * (b.y - c.y) + (b.x * b.x + b.y * b.y) * (c.y - a.y) + (c.x * c.x + c.y * c.y) * (a.y - b.y)) / d;
            const uy = ((a.x * a.x + a.y * a.y) * (c.x - b.x) + (b.x * b.x + b.y * b.y) * (a.x - c.x) + (c.x * c.x + c.y * c.y) * (b.x - a.x)) / d;
            return { x: ux, y: uy, r: Math.sqrt((a.x - ux) * (a.x - ux) + (a.y - uy) * (a.y - uy)) };
        }
        // Incremental Welzl
        let c = circle2(pts[0], pts[1]);
        for (let i = 2; i < pts.length; i++) {
            if (ldist(c, pts[i]) > c.r + 1) {
                c = circle2(pts[i], pts[0]);
                for (let j = 1; j < i; j++) {
                    if (ldist(c, pts[j]) > c.r + 1) {
                        c = circle2(pts[i], pts[j]);
                        for (let k = 0; k < j; k++) {
                            if (ldist(c, pts[k]) > c.r + 1) {
                                c = circle3(pts[i], pts[j], pts[k]);
                            }
                        }
                    }
                }
            }
        }
        // Convert back to world coordinates
        let cx = anchor.x + c.x;
        let cy = anchor.y + c.y;
        const r = c.r;
        while (cx > WORLD_HALF) { cx -= WORLD_SIZE; cy = -cy; }
        while (cx < -WORLD_HALF) { cx += WORLD_SIZE; cy = -cy; }
        while (cy > WORLD_HALF) { cy -= WORLD_SIZE; cx = -cx; }
        while (cy < -WORLD_HALF) { cy += WORLD_SIZE; cx = -cx; }
        return { cx, cy, r };
    }

    function computeVisibleComponents() {
        const parent = {};
        function find(x) { return parent[x] === x ? x : (parent[x] = find(parent[x])); }
        function union(x, y) { parent[find(x)] = find(y); }
        graphNodes.forEach(n => { parent[n.id] = n.id; });
        graphEdges.forEach(e => {
            const a = nodeMap[e.source], b = nodeMap[e.target];
            if (!a || !b) return;
            const mi = minImageDelta(a.x, a.y, b.x, b.y);
            if (mi.d2 <= EDGE_DRAW_DISTANCE * EDGE_DRAW_DISTANCE) e.locked = true;
            if (e.locked || mi.d2 <= EDGE_DRAW_DISTANCE * EDGE_DRAW_DISTANCE) union(e.source, e.target);
        });
        const components = new Map();
        graphNodes.forEach(n => {
            const root = find(n.id);
            if (!components.has(root)) components.set(root, []);
            components.get(root).push(n);
        });
        const circles = [];
        components.forEach(nodes => {
            const ec = enclosingCircle(nodes);
            const nodeSet = new Set(nodes.map(n => n.id));
            circles.push({ nodes, cx: ec.cx, cy: ec.cy, r: ec.r, nodeSet });
        });
        return circles;
    }

    function buildNodeMap() {
        const map = {};
        graphNodes.forEach(n => { map[n.id] = n; });
        return map;
    }

    let nodeMap = buildNodeMap();
    const clusterData = computeClusterLayout();

    // Initialize node positions to their target cluster positions
    // Give each node an orbital velocity around its cluster center
    graphNodes.forEach(n => {
        n.x = n.targetX + (Math.random() - 0.5) * 20;
        n.y = n.targetY + (Math.random() - 0.5) * 20;
        // Keplerian orbital velocity: v = sqrt(G*M/r) for circular orbit around galactic core
        const r = Math.sqrt(n.x * n.x + n.y * n.y) || 1;
        const orbitalV = Math.sqrt(G_CORE * CORE_MASS / Math.max(r, 50)) * 2.0;
        // Tangential (prograde) direction perpendicular to radius
        n.vx = -n.y / r * orbitalV + (Math.random() - 0.5) * 0.05;
        n.vy = n.x / r * orbitalV + (Math.random() - 0.5) * 0.05;
    });

    // Track single-edge contraction: cycle through all edges one at a time
    let edgeCycleIndex = 0;                // which edge is currently contracting
    let activePulseEdge = null;            // { source, target, strength, restLength, startTime }
    const EDGE_PULSE_INTERVAL = 2.0;      // Seconds between each edge pulse
    const EDGE_PULSE_STRENGTH = 1.2;      // Gentle contraction scaled to large universe
    const EDGE_PULSE_DECAY = 6.0;         // Slow fade over 6 seconds

    function simulate() {
        // Logarithmic time zoom: time ∝ 1/zoom
        timeScale = 0.096 * Math.pow(camera.zoom, -0.6);
        if (timeScale <= 0) return;

        // ─── Edge contraction pulse: one edge at a time, cycle through all ───
        if (!activePulseEdge || (time - activePulseEdge.startTime) >= EDGE_PULSE_INTERVAL + EDGE_PULSE_DECAY) {
            // Advance to next edge
            if (graphEdges.length > 0) {
                edgeCycleIndex = edgeCycleIndex % graphEdges.length;
                const e = graphEdges[edgeCycleIndex];
                const a = nodeMap[e.source], b = nodeMap[e.target];
                if (a && b) {
                    activePulseEdge = {
                        source: e.source, target: e.target,
                        strength: (0.1 + Math.random() * 0.3) * EDGE_PULSE_STRENGTH,
                        restLength: REST_LENGTH * (0.85 + Math.random() * 0.1),
                        startTime: time,
                    };
                }
                edgeCycleIndex = (edgeCycleIndex + 1) % graphEdges.length;
            }
        }
        // Apply decaying pulse force to the single active edge
        if (activePulseEdge) {
            const pulseAge = time - activePulseEdge.startTime;
            const pulseStrength = pulseAge < EDGE_PULSE_DECAY
                ? (1 - pulseAge / EDGE_PULSE_DECAY)
                : 0;
            if (pulseStrength > 0) {
                const a = nodeMap[activePulseEdge.source], b = nodeMap[activePulseEdge.target];
                if (a && b) {
                    const mi = minImageDelta(a.x, a.y, b.x, b.y);
                    const d = Math.sqrt(mi.d2) || 1;
                    const f = activePulseEdge.strength * (d - activePulseEdge.restLength) / d;
                    const fx = mi.dx * f * pulseStrength;
                    const fy = mi.dy * f * pulseStrength;
                    a.vx += fx; a.vy += fy;
                    b.vx -= fx; b.vy -= fy;
                }
            }
        }

        // ─── Edge springiness: nearby connected nodes attract each other ───
        const EDGE_SPRING_K = 2.0;        // Spring constant — very strong attraction
        const EDGE_SPRING_REST = REST_LENGTH * 0.6;  // Rest length where force is zero (5400)
        const EDGE_DAMPING = 0.20;        // Relative-velocity damping to smooth jitter between connected nodes
        graphEdges.forEach(e => {
            const a = nodeMap[e.source], b = nodeMap[e.target];
            if (!a || !b) return;
            if (a === dragNode || b === dragNode) return;
            const mi = minImageDelta(a.x, a.y, b.x, b.y);
            if (mi.d2 <= EDGE_DRAW_DISTANCE * EDGE_DRAW_DISTANCE) e.locked = true;
            if (!e.locked && mi.d2 > EDGE_DRAW_DISTANCE * EDGE_DRAW_DISTANCE) return; // only when close enough to light up
            const d = Math.sqrt(mi.d2) || 1;
            const f = EDGE_SPRING_K * (d - EDGE_SPRING_REST) / d;
            const fx = mi.dx * f;
            const fy = mi.dy * f;
            // Damp relative velocity along the spring axis to prevent oscillation
            const relVx = a.vx - b.vx, relVy = a.vy - b.vy;
            const relVn = (relVx * mi.dx + relVy * mi.dy) / d;  // relative velocity along edge
            const dampFx = (mi.dx / d) * relVn * EDGE_DAMPING;
            const dampFy = (mi.dy / d) * relVn * EDGE_DAMPING;
            a.vx += fx - dampFx; a.vy += fy - dampFy;
            b.vx -= fx - dampFx; b.vy -= fy - dampFy;
        });

        // ─── Edge crossing avoidance: uncross overlapping edges, keep them uncrossed ───
        const CROSS_UNCROSS_FORCE = 3000;   // Strong push to uncross
        const CROSS_GUARD_FORCE = 600;      // Weaker guard force to prevent re-crossing
        const CROSS_GUARD_DIST = MIN_REPULSION_DIST * 3; // Distance within which guard applies
        for (let i = 0; i < graphEdges.length; i++) {
            const e1 = graphEdges[i];
            const a = nodeMap[e1.source], b = nodeMap[e1.target];
            if (!a || !b) continue;
            for (let j = i + 1; j < graphEdges.length; j++) {
                const e2 = graphEdges[j];
                // Skip edges that share a node — they can't meaningfully cross
                if (e1.source === e2.source || e1.source === e2.target ||
                    e1.target === e2.source || e1.target === e2.target) continue;
                const c = nodeMap[e2.source], d = nodeMap[e2.target];
                if (!c || !d) continue;

                if (segmentsCross(a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y)) {
                    // Edges cross — push opposite node pairs apart to uncross
                    // (A,C), (A,D), (B,C), (B,D) each repel — momentum conserved
                    const pairs = [[a, c], [a, d], [b, c], [b, d]];
                    for (const [n1, n2] of pairs) {
                        if (n1 === dragNode || n2 === dragNode) continue;
                        const pdx = n2.x - n1.x, pdy = n2.y - n1.y;
                        const pd2 = pdx * pdx + pdy * pdy;
                        const pd = Math.sqrt(pd2) || 1;
                        const f = CROSS_UNCROSS_FORCE / (pd2 + 5000);
                        n1.vx -= (pdx / pd) * f;
                        n1.vy -= (pdy / pd) * f;
                        n2.vx += (pdx / pd) * f;
                        n2.vy += (pdy / pd) * f;
                    }
                } else {
                    // Edges don't cross — guard force to prevent future crossing
                    // If the four nodes are close, apply weak repulsion between opposite pairs
                    const midABx = (a.x + b.x) * 0.5, midABy = (a.y + b.y) * 0.5;
                    const midCDx = (c.x + d.x) * 0.5, midCDy = (c.y + d.y) * 0.5;
                    const midDist = Math.sqrt((midABx - midCDx) ** 2 + (midABy - midCDy) ** 2);
                    if (midDist < CROSS_GUARD_DIST) {
                        const pairs = [[a, c], [a, d], [b, c], [b, d]];
                        for (const [n1, n2] of pairs) {
                            if (n1 === dragNode || n2 === dragNode) continue;
                            const pdx = n2.x - n1.x, pdy = n2.y - n1.y;
                            const pd2 = pdx * pdx + pdy * pdy;
                            const pd = Math.sqrt(pd2) || 1;
                            const f = CROSS_GUARD_FORCE / (pd2 + 5000);
                            n1.vx -= (pdx / pd) * f;
                            n1.vy -= (pdy / pd) * f;
                            n2.vx += (pdx / pd) * f;
                            n2.vy += (pdy / pd) * f;
                        }
                    }
                }
            }
        }

        // ─── Cluster centroid tracking (dynamic, not kinematic) ───
        // Update cluster centroids to actual center of mass for label rendering
        const clusterMass = {};
        Object.keys(clusterData.centroids).forEach(d => { clusterMass[d] = { mx: 0, my: 0, m: 0 }; });
        graphNodes.forEach(n => {
            const d = n.clusterDomain || n.primary_domain || 'Bridges';
            if (clusterMass[d]) {
                clusterMass[d].mx += n.x * n.mass;
                clusterMass[d].my += n.y * n.mass;
                clusterMass[d].m += n.mass;
            }
        });
        Object.keys(clusterMass).forEach(d => {
            const cm = clusterMass[d];
            if (cm.m > 0) {
                clusterData.centroids[d].x = cm.mx / cm.m;
                clusterData.centroids[d].y = cm.my / cm.m;
            }
        });

        // ─── Component force field repulsion ───
        const compCircles = computeVisibleComponents();
        // Build node → own circle lookup for containment
        const nodeCircleMap = new Map();
        compCircles.forEach(circle => {
            circle.nodes.forEach(n => { nodeCircleMap.set(n.id, circle); });
        });
        const FIELD_STRENGTH = 4000;    // Repulsive force strength
        const FIELD_MARGIN = 200;      // How far inside the circle before force kicks in
        for (let ci = 0; ci < compCircles.length; ci++) {
            const circle = compCircles[ci];
            for (let ni = 0; ni < graphNodes.length; ni++) {
                const n = graphNodes[ni];
                if (n === dragNode) continue;
                if (circle.nodeSet.has(n.id)) continue; // own component — skip
                const dx = n.x - circle.cx, dy = n.y - circle.cy;
                const dist = Math.sqrt(dx * dx + dy * dy) || 1;
                if (dist < circle.r + FIELD_MARGIN) {
                    // Node is inside or near the force field boundary — push it out
                    const penetration = circle.r + FIELD_MARGIN - dist;
                    const force = FIELD_STRENGTH * penetration / (circle.r + FIELD_MARGIN);
                    n.vx += (dx / dist) * force;
                    n.vy += (dy / dist) * force;
                    // Spawn explosion at boundary if deep penetration
                    if (dist < circle.r) {
                        n.thrustTime = time;
                        n.thrustAngle = Math.atan2(dy, dx);
                        n.thrustStrength = 1.0;
                        n.thrustSpin = Math.random() > 0.5 ? 1 : -1;
                    }

                }
            }
        }
        // Circle-circle repulsion: overlapping component circles push each other apart
        for (let ci = 0; ci < compCircles.length; ci++) {
            for (let cj = ci + 1; cj < compCircles.length; cj++) {
                const A = compCircles[ci], B = compCircles[cj];
                const dx = B.cx - A.cx, dy = B.cy - A.cy;
                const dist = Math.sqrt(dx * dx + dy * dy) || 1;
                const overlap = (A.r + B.r) - dist;
                if (overlap > 0) {
                    // Push all nodes in each component away from the other circle's center
                    const pushDir = { x: dx / dist, y: dy / dist };
                    const pushForce = 2000 * overlap / (A.r + B.r);
                    A.nodes.forEach(n => {
                        if (n === dragNode) return;
                        n.vx -= pushDir.x * pushForce;
                        n.vy -= pushDir.y * pushForce;
                    });
                    B.nodes.forEach(n => {
                        if (n === dragNode) return;
                        n.vx += pushDir.x * pushForce;
                        n.vy += pushDir.y * pushForce;
                    });
                }
            }
        }

        // ─── N-body: universal gravitation + central attractor + short-range repulsion ───
        for (let i = 0; i < graphNodes.length; i++) {
            const a = graphNodes[i];
            if (a === dragNode) continue;
            const aDomain = a.clusterDomain || a.primary_domain || 'Bridges';
            if (dragCluster && aDomain === dragCluster) continue;

            // Central attractor + Dark Energy expansion
            const coreDelta = minImageDelta(a.x, a.y, 0, 0); // uses _miResult
            const coreR2 = coreDelta.d2;
            const coreDx = coreDelta.dx;
            const coreDy = coreDelta.dy;
            const coreR = Math.sqrt(coreR2) || 1;
            const gravity = G_CORE * CORE_MASS * a.mass / (coreR2 + SOFTENING * SOFTENING);
            const coreForce = gravity;
            a.vx += (coreDx / coreR) * coreForce;
            a.vy += (coreDy / coreR) * coreForce;

            for (let j = i + 1; j < graphNodes.length; j++) {
                const b = graphNodes[j];
                if (b === dragNode) continue;
                const bDomain = b.clusterDomain || b.primary_domain || 'Bridges';
                if (dragCluster && bDomain === dragCluster) continue;

                // Minimum-image delta: shortest path through Klein bottle topology
                // Quick bounding box check to save math on distant nodes
                const rawDx = b.x - a.x;
                const rawDy = b.y - a.y;
                if (Math.abs(rawDx) > 5000 || Math.abs(rawDy) > 5000) continue;

                const mi = minImageDelta(a.x, a.y, b.x, b.y); // uses _miResult
                const dx = mi.dx, dy = mi.dy;
                const d2 = mi.d2;
                const d = Math.sqrt(d2) || 1;

                // Universal gravitation — always attractive, cluster affinity boosts strength
                const sameCluster = (aDomain === bDomain);
                const G = sameCluster ? G_UNIVERSAL * G_CLUSTER_MULT : G_UNIVERSAL;
                const force = (G * a.mass * b.mass / (d2 + SOFTENING * SOFTENING)) - (COULOMB_REPULSION / (d2 + SOFTENING * SOFTENING));
                const fx = (dx / d) * force;
                const fy = (dy / d) * force;
                a.vx += fx; a.vy += fy;
                b.vx -= fx; b.vy -= fy;

                // ── Elastic collision: conserves momentum AND kinetic energy ──
                if (d < MIN_REPULSION_DIST) {
                    const nx = dx / d, ny = dy / d;
                    const relVx = a.vx - b.vx, relVy = a.vy - b.vy;
                    const relVn = relVx * nx + relVy * ny;
                    if (relVn > 0) {
                        // Chain reaction detection: visual effects scale with collision cascade
                        const isChain = (a.thrustTime > 0 || b.thrustTime > 0);
                        // Connected nodes get inelastic collisions (absorb energy, no bouncing)
                        const isConnected = areConnected(a.id, b.id);
                        const bounce = BOUNCE;  // Use global smooth bounce
                        const totalMass = a.mass + b.mass;
                        // No pinball bumper force
                        const bumperForce = 0;
                        // Impulse: (1+e) * relVn * m_other / totalMass + bumperForce
                        const impulseA = ((1 + bounce) * relVn + bumperForce) * b.mass / totalMass;
                        const impulseB = ((1 + bounce) * relVn + bumperForce) * a.mass / totalMass;
                        a.vx -= impulseA * nx;
                        a.vy -= impulseA * ny;
                        b.vx += impulseB * nx;
                        b.vy += impulseB * ny;

                        // Visual: activate rocket flame trails on both nodes (subdued for connected)
                        a.thrustTime = time;
                        a.thrustAngle = Math.atan2(-ny, -nx) + (Math.random() - 0.5) * Math.PI * 0.6;
                        a.thrustStrength = isConnected ? 0.05 : Math.min(1, Math.abs(relVn) * 0.5);
                        a.thrustSpin = Math.random() > 0.5 ? 1 : -1;
                        b.thrustTime = time;
                        b.thrustAngle = Math.atan2(ny, nx) + (Math.random() - 0.5) * Math.PI * 0.6;
                        b.thrustStrength = isConnected ? 0.05 : Math.min(1, Math.abs(relVn) * 0.5);
                        b.thrustSpin = Math.random() > 0.5 ? 1 : -1;

                        // No explosions
                    }
                    // Overlap separation: mass-proportional to conserve center of mass
                    const overlap = MIN_REPULSION_DIST - d;
                    if (overlap > 0) {
                        const pushA = overlap * b.mass / (a.mass + b.mass);
                        const pushB = overlap * a.mass / (a.mass + b.mass);
                        a.x -= nx * pushA;
                        a.y -= ny * pushA;
                        b.x += nx * pushB;
                        b.y += ny * pushB;
                    }
                }
            }
        }

        // ─── Integrate + trail ───
        graphNodes.forEach(n => {
            if (n === dragNode) return;
            if (dragCluster && (n.clusterDomain || n.primary_domain || 'Bridges') === dragCluster) return;

            // Rocket thrust: visual-only flame trail after collision (no force — momentum conserved)
            if (n.thrustTime > 0) {
                const thrustAge = time - n.thrustTime;
                if (thrustAge < THRUST_DURATION) {
                    n.thrustSpin = n.thrustSpin || ((Math.random() > 0.5 ? 1 : -1) * (15 + Math.random() * 10));
                    n.thrustAngle += n.thrustSpin * 0.016;




                    // Apply spiral thrust to velocity
                    const thrustForce = 800.0 * n.thrustStrength * (1 - thrustAge / THRUST_DURATION);
                    n.vx += Math.cos(n.thrustAngle) * thrustForce * 0.016;
                    n.vy += Math.sin(n.thrustAngle) * thrustForce * 0.016;
                    const spinDir = n.thrustSpin || 1;
                    n.vx += Math.cos(n.thrustAngle + Math.PI / 2) * thrustForce * spinDir * 0.6 * 0.016;
                    n.vy += Math.sin(n.thrustAngle + Math.PI / 2) * thrustForce * spinDir * 0.6 * 0.016;
                } else {
                    n.thrustTime = 0;
                    n.thrustSpin = 0;
                }
            }

            n.vx *= DAMPING;
            n.vy *= DAMPING;

            // Continuous galactic rotation nudge (flat rotation curve)
            const distFromCenter = Math.sqrt(n.x * n.x + n.y * n.y) || 1;
            const tangX = -n.y / distFromCenter;
            const tangY = n.x / distFromCenter;
            const targetRotV = 200.0; // Flat rotation curve speed
            const currentRotV = n.vx * tangX + n.vy * tangY;
            if (currentRotV < targetRotV) {
                const nudge = (targetRotV - currentRotV) * 0.05; // Gently accelerate to target
                n.vx += tangX * nudge;
                n.vy += tangY * nudge;
            }

            // Cap velocity to prevent ejections, and enforce minimum velocity
            let speed = Math.sqrt(n.vx * n.vx + n.vy * n.vy);
            const MIN_VELOCITY = 0.5; // Very low minimum velocity for elegant floating
            if (speed < MIN_VELOCITY) {
                if (speed === 0) {
                    const angle = Math.random() * Math.PI * 2;
                    n.vx = Math.cos(angle) * MIN_VELOCITY;
                    n.vy = Math.sin(angle) * MIN_VELOCITY;
                } else {
                    n.vx = (n.vx / speed) * MIN_VELOCITY;
                    n.vy = (n.vy / speed) * MIN_VELOCITY;
                }
                speed = MIN_VELOCITY;
            }
            if (speed > MAX_VELOCITY) {
                n.vx = (n.vx / speed) * MAX_VELOCITY;
                n.vy = (n.vy / speed) * MAX_VELOCITY;
            }
            n.x += n.vx * timeScale;
            n.y += n.vy * timeScale;

            // Möbius-Klein bottle wrapping: non-orientable closed universe
            // X-wrap: re-enter opposite side with Y flipped (Möbius twist)
            while (n.x > WORLD_HALF) { n.x -= WORLD_SIZE; n.y = -n.y; n.vy = -n.vy; }
            while (n.x < -WORLD_HALF) { n.x += WORLD_SIZE; n.y = -n.y; n.vy = -n.vy; }
            // Y-wrap: re-enter opposite side with X flipped (Klein bottle second twist)
            while (n.y > WORLD_HALF) { n.y -= WORLD_SIZE; n.x = -n.x; n.vx = -n.vx; }
            while (n.y < -WORLD_HALF) { n.y += WORLD_SIZE; n.x = -n.x; n.vx = -n.vx; }

            // Comet trail: ring buffer of last 20 positions
            const v = Math.sqrt(n.vx * n.vx + n.vy * n.vy);
            if (!n.trail) n.trail = [];
            if (v > 30.0) {
                n.trail.push({ x: n.x, y: n.y });
                if (n.trail.length > 20) n.trail.shift();
            } else if (n.trail.length > 0) {
                n.trail.shift(); // fade out when stationary
            }

            // Radar pulse: emit every ~3 seconds
            if (!n.radarPulse && Math.random() < 0.002) {
                n.radarPulse = { startTime: time, radius: 0 };
            }
            if (n.radarPulse) {
                n.radarPulse.radius += 45;
                if (n.radarPulse.radius > n.radius * 4) {
                    n.radarPulse = null;
                }
            }
        });

        // ─── Hard edge crossing constraint: project nodes apart until no edges cross ───
        for (let uncrossIter = 0; uncrossIter < 1; uncrossIter++) {
            let anyCross = false;
            for (let i = 0; i < graphEdges.length; i++) {
                const e1 = graphEdges[i];
                const a = nodeMap[e1.source], b = nodeMap[e1.target];
                if (!a || !b) continue;
                for (let j = i + 1; j < graphEdges.length; j++) {
                    const e2 = graphEdges[j];
                    if (e1.source === e2.source || e1.source === e2.target ||
                        e1.target === e2.source || e1.target === e2.target) continue;
                    const c = nodeMap[e2.source], d = nodeMap[e2.target];
                    if (!c || !d) continue;
                    // Fast AABB check
                    if (Math.min(a.x, b.x) > Math.max(c.x, d.x) ||
                        Math.max(a.x, b.x) < Math.min(c.x, d.x) ||
                        Math.min(a.y, b.y) > Math.max(c.y, d.y) ||
                        Math.max(a.y, b.y) < Math.min(c.y, d.y)) {
                        continue;
                    }
                    if (segmentsCross(a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y)) {
                        anyCross = true;
                        // Push opposite node pairs apart — equal and opposite (momentum conserved)
                        const pairs = [[a, c], [a, d], [b, c], [b, d]];
                        for (const [n1, n2] of pairs) {
                            const pdx = n2.x - n1.x, pdy = n2.y - n1.y;
                            const pd = Math.sqrt(pdx * pdx + pdy * pdy) || 1;
                            const push = 500 / pd;
                            n1.x -= (pdx / pd) * push;
                            n1.y -= (pdy / pd) * push;
                            n2.x += (pdx / pd) * push;
                            n2.y += (pdy / pd) * push;
                            // Reflect velocities outward too
                            const vOut1 = n1.vx * (pdx / pd) + n1.vy * (pdy / pd);
                            const vOut2 = n2.vx * (-pdx / pd) + n2.vy * (-pdy / pd);
                            if (vOut1 > 0) { n1.vx -= vOut1 * (pdx / pd); n1.vy -= vOut1 * (pdy / pd); }
                            if (vOut2 > 0) { n2.vx += vOut2 * (pdx / pd); n2.vy += vOut2 * (pdy / pd); }
                        }
                    }
                }
            }
            if (!anyCross) break;
        }
    }

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
                const v = [[1, 1, 1], [1, -1, -1], [-1, 1, -1], [-1, -1, 1]];
                edges3d = [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]];
                const p = project3D(v.map(c => c.map(c2 => c2 * S)), rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                edges3d.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                break;
            }
            case 'cube': {
                const v = [];
                for (let sx = -1; sx <= 1; sx += 2) for (let sy = -1; sy <= 1; sy += 2) for (let sz = -1; sz <= 1; sz += 2) v.push([sx, sy, sz]);
                const edgePairs = [[0, 1], [0, 2], [0, 4], [1, 3], [1, 5], [2, 3], [2, 6], [3, 7], [4, 5], [4, 6], [5, 7], [6, 7]];
                const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.7)), rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                edgePairs.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                break;
            }
            case 'octahedron': {
                const v = [[1, 0, 0], [-1, 0, 0], [0, 1, 0], [0, -1, 0], [0, 0, 1], [0, 0, -1]];
                const edgePairs = [[0, 2], [0, 3], [0, 4], [0, 5], [1, 2], [1, 3], [1, 4], [1, 5], [2, 4], [2, 5], [3, 4], [3, 5]];
                const p = project3D(v.map(c => c.map(c2 => c2 * S)), rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                edgePairs.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
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
                    if (Math.abs(Math.sqrt(dx * dx + dy * dy + dz * dz) - 2 / phi) < 0.01) edgePairs.push([i, j]);
                }
                const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.55)), rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.2;
                edgePairs.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                break;
            }
            case 'icosahedron': {
                const phi = (1 + Math.sqrt(5)) / 2;
                const v = [[0, 1, phi], [0, 1, -phi], [0, -1, phi], [0, -1, -phi], [1, phi, 0], [1, -phi, 0], [-1, phi, 0], [-1, -phi, 0], [phi, 0, 1], [phi, 0, -1], [-phi, 0, 1], [-phi, 0, -1]];
                const edgePairs = [[0, 2], [0, 4], [0, 6], [0, 8], [0, 10], [1, 3], [1, 4], [1, 6], [1, 9], [1, 11], [2, 5], [2, 7], [2, 8], [2, 10], [3, 5], [3, 7], [3, 9], [3, 11], [4, 6], [4, 8], [4, 9], [5, 7], [5, 8], [5, 9], [6, 10], [6, 11], [7, 10], [7, 11], [8, 9], [10, 11]];
                const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.5)), rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                edgePairs.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
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
                starGlow.addColorStop(0, `hsla(${h}, ${s}%, ${Math.min(l + 30, 95)}%, 0.5)`);
                starGlow.addColorStop(1, `hsla(${h}, ${s}%, ${l}%, 0.0)`);
                ctx.fillStyle = starGlow; ctx.fill();
                break;
            }
            case 'hexagonal_prism': {
                const v = [], edgeP = [];
                for (let i = 0; i < 6; i++) {
                    const a = Math.PI / 3 * i;
                    v.push([Math.cos(a) * S, S * 0.6, Math.sin(a) * S]);
                    v.push([Math.cos(a) * S, -S * 0.6, Math.sin(a) * S]);
                }
                for (let i = 0; i < 6; i++) { edgeP.push([i * 2, i * 2 + 1]); edgeP.push([i * 2, ((i + 1) % 6) * 2]); edgeP.push([i * 2 + 1, ((i + 1) % 6) * 2 + 1]); }
                const p = project3D(v, rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                edgeP.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
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
                    ringPts.push(project3D([[Math.cos(a) * S * 1.1, 0, Math.sin(a) * S * 1.1]], rotX * 1.3, rotY * 0.7)[0]);
                }
                ctx.beginPath();
                ringPts.forEach((p2, i) => i === 0 ? ctx.moveTo(p2[0], p2[1]) : ctx.lineTo(p2[0], p2[1]));
                ctx.strokeStyle = `hsla(${h}, ${s}%, ${Math.min(l + 20, 90)}%, 0.6)`;
                ctx.lineWidth = 1; ctx.stroke();
                break;
            }
            case 'diamond': {
                // Elongated octahedron (top/bottom points)
                const v = [[0, 1.3 * S, 0], [S * 0.7, 0, 0], [0, 0, S * 0.7], [-S * 0.7, 0, 0], [0, 0, -S * 0.7], [0, -1.3 * S, 0]];
                const edgeP = [[0, 1], [0, 2], [0, 3], [0, 4], [1, 2], [2, 3], [3, 4], [4, 1], [1, 5], [2, 5], [3, 5], [4, 5]];
                const p = project3D(v, rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                edgeP.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                break;
            }
            case 'triangular_prism': {
                const v = [];
                for (let i = 0; i < 3; i++) {
                    const a = (i / 3) * Math.PI * 2 - Math.PI / 2;
                    v.push([Math.cos(a) * S, S * 0.6, Math.sin(a) * S]);
                    v.push([Math.cos(a) * S, -S * 0.6, Math.sin(a) * S]);
                }
                const edgeP = [[0, 1], [2, 3], [4, 5], [0, 2], [2, 4], [0, 4], [1, 3], [3, 5], [1, 5]];
                const p = project3D(v, rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                edgeP.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                break;
            }
            case 'pentagonal_prism': {
                const v = [], edgeP = [];
                for (let i = 0; i < 5; i++) {
                    const a = (i / 5) * Math.PI * 2 - Math.PI / 2;
                    v.push([Math.cos(a) * S, S * 0.6, Math.sin(a) * S]);
                    v.push([Math.cos(a) * S, -S * 0.6, Math.sin(a) * S]);
                }
                for (let i = 0; i < 5; i++) { edgeP.push([i * 2, i * 2 + 1]); edgeP.push([i * 2, ((i + 1) % 5) * 2]); edgeP.push([i * 2 + 1, ((i + 1) % 5) * 2 + 1]); }
                const p = project3D(v, rotX, rotY);
                ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                edgeP.forEach(([a, b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
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
                sdGlow.addColorStop(0, `hsla(${h}, ${s}%, ${Math.min(l + 30, 95)}%, 0.4)`);
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
            ctx.strokeStyle = `hsla(${h}, ${s}%, ${Math.min(l + 20, 90)}%, 0.4)`;
            ctx.lineWidth = 2;
            ctx.stroke();
        }

        ctx.restore();
    }

    // ─── Render ───
    function resize() {
        W = canvas.width = canvas.offsetWidth;
        H = canvas.height = canvas.offsetHeight;
        if (typeof bgCanvas !== 'undefined') {
            bgCanvas.width = W;
            bgCanvas.height = H;
            bgNeedsUpdate = true;
        }
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
        if (!animating || isReadingPackage()) {
            stopAnimation();
            return;
        }
        time += 0.016 * timeScale;

        // Smooth camera animation toward target
        if (cameraTarget) {
            // If tracking a hovered node, update target to current circle position
            if (hoverTrackId) {
                const comps = computeVisibleComponents();
                for (const circle of comps) {
                    if (circle.nodeSet.has(hoverTrackId)) {
                        const minDim = Math.min(W || 800, H || 600);
                        const targetZoom = minDim * 0.6 / (circle.r * 2);
                        cameraTarget = { x: circle.cx, y: circle.cy, zoom: Math.min(targetZoom, 5) };
                        break;
                    }
                }
            }
            const lerp = 0.08;
            camera.x += (cameraTarget.x - camera.x) * lerp;
            camera.y += (cameraTarget.y - camera.y) * lerp;
            camera.zoom += (cameraTarget.zoom - camera.zoom) * lerp;
        }

        simulate();

        ctx.clearRect(0, 0, W, H);
        ctx.globalCompositeOperation = 'lighter';

        // Background: parallax nebula
        const isLightMode = document.body.classList.contains('light-theme');
        const bgGrad = ctx.createLinearGradient(0, 0, 0, H);
        if (isLightMode) {
            bgGrad.addColorStop(0, '#f8f9fa');
            bgGrad.addColorStop(1, '#e9ecef');
        } else {
            bgGrad.addColorStop(0, '#0d0d2b');
            bgGrad.addColorStop(0.5, '#0a0a1a');
            bgGrad.addColorStop(1, '#050510');
        }
        ctx.fillStyle = bgGrad;
        ctx.fillRect(0, 0, W, H);

        // Second nebula glow (Parallax)
        const prlxX1 = (W * 0.7) - (camera.x * 0.02);
        const prlxY1 = (H * 0.6) - (camera.y * 0.02);
        const neb2 = ctx.createRadialGradient(prlxX1, prlxY1, 0, prlxX1, prlxY1, Math.max(W, H) * 0.8);
        if (isLightMode) {
            neb2.addColorStop(0, 'rgba(100, 150, 255, 0.05)');
            neb2.addColorStop(1, 'rgba(255, 255, 255, 0.0)');
        } else {
            neb2.addColorStop(0, 'rgba(60, 20, 80, 0.15)');
            neb2.addColorStop(1, 'rgba(10, 10, 26, 0.0)');
        }
        ctx.fillStyle = neb2;
        ctx.fillRect(0, 0, W, H);

        // Third nebula cloud (Parallax)
        const prlxX2 = (W * 0.2) - (camera.x * 0.04);
        const prlxY2 = (H * 0.8) - (camera.y * 0.04);
        const neb3 = ctx.createRadialGradient(prlxX2, prlxY2, 0, prlxX2, prlxY2, Math.max(W, H) * 0.6);
        if (isLightMode) {
            neb3.addColorStop(0, 'rgba(100, 200, 255, 0.05)');
            neb3.addColorStop(1, 'rgba(255, 255, 255, 0.0)');
        } else {
            neb3.addColorStop(0, 'rgba(20, 40, 80, 0.1)');
            neb3.addColorStop(1, 'rgba(10, 10, 26, 0.0)');
        }
        ctx.fillStyle = neb3;
        ctx.fillRect(0, 0, W, H);

        // Stars with shimmer
        stars.forEach(s => {
            const sp = worldToScreen(s.x, s.y);
            if (sp.x < -5 || sp.x > W + 5 || sp.y < -5 || sp.y > H + 5) return;
            let twinkle = 0.5 + 0.5 * Math.sin(time * s.twinkleSpeed + s.twinklePhase);
            // Shimmer: occasional brightness spike
            if (s.shimmer) {
                const shimmerPhase = Math.sin(time * 0.7 + s.twinklePhase * 3);
                if (shimmerPhase > 0.9) twinkle = 1.0;
            }
            const alpha = s.brightness * twinkle;
            const sr = s.r * camera.zoom;
            ctx.fillStyle = isLightMode ? `rgba(50, 80, 150, ${alpha * 0.3})` : `rgba(200, 200, 255, ${alpha})`;
            ctx.fillRect(sp.x - sr, sp.y - sr, sr * 2, sr * 2);
            // Lens flare for bright large stars
            if (s.r > 1.0 && alpha > 0.6) {
                ctx.fillStyle = isLightMode ? `rgba(50, 80, 150, ${alpha * 0.05})` : `rgba(200, 200, 255, ${alpha * 0.1})`;
                ctx.fillRect(sp.x - sr * 3, sp.y - sr * 3, sr * 6, sr * 6);
            }
        });

        // ─── Connected component circles (visible edges only) ───
        const centroids = clusterData.centroids;
        const compCircles = computeVisibleComponents();
        let compIdx = 0;
        compCircles.forEach(circle => {
            const sr = circle.r * camera.zoom;
            if (sr < 3) { compIdx++; return; }
            const sp = worldToScreen(circle.cx, circle.cy);
            const hue = (compIdx * 47 + 15) % 360;
            const crossesX = Math.abs(circle.cx) + circle.r > WORLD_HALF;
            const crossesY = Math.abs(circle.cy) + circle.r > WORLD_HALF;
            const crossesEdge = crossesX || crossesY;
            // Universe boundary screen coords for clipping
            const edgeL = worldToScreen(-WORLD_HALF, 0).x;
            const edgeR = worldToScreen(WORLD_HALF, 0).x;
            const edgeT = worldToScreen(0, -WORLD_HALF).y;
            const edgeB = worldToScreen(0, WORLD_HALF).y;
            // Draw main circle (clipped to universe if it crosses an edge)
            ctx.save();
            if (crossesEdge) {
                ctx.beginPath();
                ctx.rect(edgeL, edgeT, edgeR - edgeL, edgeB - edgeT);
                ctx.clip();
            }
            ctx.beginPath();
            ctx.arc(sp.x, sp.y, sr, 0, Math.PI * 2);
            ctx.fillStyle = `hsla(${hue}, 80%, 60%, 0.06)`;
            ctx.fill();
            ctx.strokeStyle = `hsla(${hue}, 90%, 70%, 0.2)`;
            ctx.lineWidth = 1;
            ctx.stroke();
            ctx.restore();
            // X-ghost: circle wraps through X boundary, Y flipped (Möbius twist)
            if (crossesX) {
                const gx = circle.cx > 0 ? circle.cx - WORLD_SIZE : circle.cx + WORLD_SIZE;
                const gy = -circle.cy;
                const gsp = worldToScreen(gx, gy);
                if (gsp.x > -sr && gsp.x < W + sr && gsp.y > -sr && gsp.y < H + sr) {
                    ctx.save();
                    ctx.globalAlpha = 0.25;
                    ctx.beginPath();
                    ctx.rect(edgeL, edgeT, edgeR - edgeL, edgeB - edgeT);
                    ctx.clip();
                    ctx.beginPath();
                    ctx.arc(gsp.x, gsp.y, sr, 0, Math.PI * 2);
                    ctx.fillStyle = `hsla(${hue}, 80%, 60%, 0.06)`;
                    ctx.fill();
                    ctx.strokeStyle = `hsla(${hue}, 90%, 70%, 0.2)`;
                    ctx.lineWidth = 1;
                    ctx.stroke();
                    ctx.restore();
                }
            }
            // Y-ghost: circle wraps through Y boundary, X flipped (Klein twist)
            if (crossesY) {
                const gx = -circle.cx;
                const gy = circle.cy > 0 ? circle.cy - WORLD_SIZE : circle.cy + WORLD_SIZE;
                const gsp = worldToScreen(gx, gy);
                if (gsp.x > -sr && gsp.x < W + sr && gsp.y > -sr && gsp.y < H + sr) {
                    ctx.save();
                    ctx.globalAlpha = 0.25;
                    ctx.beginPath();
                    ctx.rect(edgeL, edgeT, edgeR - edgeL, edgeB - edgeT);
                    ctx.clip();
                    ctx.beginPath();
                    ctx.arc(gsp.x, gsp.y, sr, 0, Math.PI * 2);
                    ctx.fillStyle = `hsla(${hue}, 80%, 60%, 0.06)`;
                    ctx.fill();
                    ctx.strokeStyle = `hsla(${hue}, 90%, 70%, 0.2)`;
                    ctx.lineWidth = 1;
                    ctx.stroke();
                    ctx.restore();
                }
            }
            compIdx++;
        });

        // ─── Provenance edges (energy beam style) ───
        // Helper: draw one edge line from (ax,ay) to (bx,by) in screen space
        function drawEdgeBeam(sa, sb, colA, colB, glowAlpha, coreAlpha, lineW) {
            const blendH = (colA.h + colB.h) / 2;
            // Wide glow line
            ctx.beginPath();
            ctx.moveTo(sa.x, sa.y);
            ctx.lineTo(sb.x, sb.y);
            ctx.strokeStyle = `hsla(${blendH}, 70%, 70%, ${glowAlpha})`;
            ctx.lineWidth = lineW * 6;
            ctx.stroke();
            // Core line (gradient)
            ctx.beginPath();
            ctx.moveTo(sa.x, sa.y);
            ctx.lineTo(sb.x, sb.y);
            if (isFinite(sa.x) && isFinite(sa.y) && isFinite(sb.x) && isFinite(sb.y)) {
                ctx.strokeStyle = `hsla(${blendH}, 80%, 80%, ${coreAlpha})`;
                ctx.lineWidth = lineW;
                ctx.stroke();
            }
        }
        // Draw each edge on both sides of the Klein bottle
        graphEdges.forEach(e => {
            const a = nodeMap[e.source], b = nodeMap[e.target];
            if (!a || !b) return;
            const miAB = minImageDelta(a.x, a.y, b.x, b.y, _miResult);
            const miBA = minImageDelta(b.x, b.y, a.x, a.y, _miResult2);
            if (miAB.d2 <= EDGE_DRAW_DISTANCE * EDGE_DRAW_DISTANCE) e.locked = true;
            if (!e.locked && miAB.d2 > EDGE_DRAW_DISTANCE * EDGE_DRAW_DISTANCE) return;

            const colA = nodeColor(a), colB = nodeColor(b);
            const strength = e.strength || 1.0;
            const isLocked = typeof edgeLocks !== 'undefined' && edgeLocks.has(e.source + '→' + e.target);
            const isActiveCluster = typeof activeComponent !== 'undefined' && activeComponent !== null && activeComponent.some(ce => ce.source === e.source && ce.target === e.target);

            let glowAlpha, coreAlpha, lineW;
            if (isActiveCluster) {
                lineW = 2 + strength * 2;
                glowAlpha = 0.3 + 0.15 * Math.sin(time * 4);
                coreAlpha = 0.9;
            } else if (isLocked) {
                lineW = 1.5 + strength;
                glowAlpha = 0.12;
                coreAlpha = 0.5;
            } else {
                lineW = 1;
                glowAlpha = 0.06;
                coreAlpha = 0.25;
            }

            // Side 1: A sees B through shortest path
            const sa1 = worldToScreen(a.x, a.y);
            const sb1 = worldToScreen(a.x + miAB.dx, a.y + miAB.dy);
            if (isInView(a.x, a.y, 50) || isInView(a.x + miAB.dx, a.y + miAB.dy, 50)) {
                drawEdgeBeam(sa1, sb1, colA, colB, glowAlpha, coreAlpha, lineW);
            }
            // Side 2: B sees A through shortest path (the "other side")
            const sa2 = worldToScreen(b.x, b.y);
            const sb2 = worldToScreen(b.x + miBA.dx, b.y + miBA.dy);
            if (isInView(b.x, b.y, 50) || isInView(b.x + miBA.dx, b.y + miBA.dy, 50)) {
                drawEdgeBeam(sa2, sb2, colB, colA, glowAlpha * 0.5, coreAlpha * 0.5, lineW * 0.7);
            }
        });

        // ─── Edge particles (directional laser streaks: source → target) ───
        // Particles flow from source to target showing provenance direction
        edgeParticles.forEach(p => {
            const a = nodeMap[p.edge.source], b = nodeMap[p.edge.target];
            if (!a || !b) return;
            const miAB = minImageDelta(a.x, a.y, b.x, b.y);
            const dist = Math.sqrt(miAB.d2);
            if (dist <= EDGE_DRAW_DISTANCE) p.edge.locked = true;
            if (!p.edge.locked && dist > EDGE_DRAW_DISTANCE) return;

            const isActiveClusterEdge = typeof activeComponent !== 'undefined' && activeComponent !== 'undefined' && activeComponent.some(ce => ce.source === p.edge.source && ce.target === p.edge.target);
            const speedMultiplier = isActiveClusterEdge ? 3.0 : 1.0;
            p.t += p.speed * speedMultiplier;
            if (p.t > 1) p.t -= 1;

            const colA = nodeColor(a), colB = nodeColor(b);
            const blendH = (colA.h + colB.h) / 2;
            const baseAlpha = 0.4 + 0.4 * Math.sin(p.t * Math.PI);
            const activeBoost = isActiveClusterEdge ? 0.3 : 0.0;
            const alpha = Math.min(1.0, baseAlpha + activeBoost);
            const pSize = isActiveClusterEdge ? p.size * 2.0 : p.size * 1.4;

            // Directional laser streak: elongated along source→target
            const tailLen = 0.06; // how far back the tail extends
            const tHead = p.t;
            const tTail = Math.max(0, p.t - tailLen);

            // Side 1: source→target path
            const hx1 = a.x + miAB.dx * tHead;
            const hy1 = a.y + miAB.dy * tHead;
            const tx1 = a.x + miAB.dx * tTail;
            const ty1 = a.y + miAB.dy * tTail;
            const sh1 = worldToScreen(hx1, hy1);
            const st1 = worldToScreen(tx1, ty1);
            if (isInView(hx1, hy1, 50) || isInView(tx1, ty1, 50)) {
                // Laser streak line
                if (isFinite(st1.x) && isFinite(st1.y) && isFinite(sh1.x) && isFinite(sh1.y)) {
                    ctx.beginPath();
                    ctx.moveTo(st1.x, st1.y);
                    ctx.lineTo(sh1.x, sh1.y);
                    ctx.strokeStyle = `hsla(${blendH}, 100%, 90%, ${alpha * 0.6})`;
                    ctx.lineWidth = pSize * camera.zoom * 1.5;
                    ctx.stroke();
                }
                // Bright head dot
                ctx.beginPath();
                ctx.arc(sh1.x, sh1.y, pSize * camera.zoom, 0, Math.PI * 2);
                ctx.fillStyle = `hsla(${blendH}, 100%, 95%, ${alpha})`;
                ctx.fill();
            }
            // Side 2: ghost mirror (source→target on other side)
            const miBA = minImageDelta(b.x, b.y, a.x, a.y, _miResult2);
            const hx2 = b.x + miBA.dx * (1 - tHead);
            const hy2 = b.y + miBA.dy * (1 - tHead);
            const tx2 = b.x + miBA.dx * (1 - tTail);
            const ty2 = b.y + miBA.dy * (1 - tTail);
            const sh2 = worldToScreen(hx2, hy2);
            const st2 = worldToScreen(tx2, ty2);
            if (isInView(hx2, hy2, 50) || isInView(tx2, ty2, 50)) {
                if (isFinite(st2.x) && isFinite(st2.y) && isFinite(sh2.x) && isFinite(sh2.y)) {
                    ctx.beginPath();
                    ctx.moveTo(st2.x, st2.y);
                    ctx.lineTo(sh2.x, sh2.y);
                    ctx.strokeStyle = `hsla(${blendH}, 100%, 90%, ${alpha * 0.3})`;
                    ctx.lineWidth = pSize * camera.zoom;
                    ctx.stroke();
                }
                ctx.beginPath();
                ctx.arc(sh2.x, sh2.y, pSize * camera.zoom * 0.7, 0, Math.PI * 2);
                ctx.fillStyle = `hsla(${blendH}, 100%, 95%, ${alpha * 0.5})`;
                ctx.fill();
            }
        });

        // ─── Comet trails ───
        ctx.globalCompositeOperation = 'lighter';
        graphNodes.forEach(node => {
            if (node.trail.length < 2) return;
            const col = nodeColor(node);
            for (let i = 1; i < node.trail.length; i++) {
                const alpha = (i / node.trail.length) * 0.4;
                const width = (i / node.trail.length) * 3 * camera.zoom;
                const p0 = worldToScreen(node.trail[i - 1].x, node.trail[i - 1].y);
                const p1 = worldToScreen(node.trail[i].x, node.trail[i].y);
                ctx.beginPath();
                ctx.moveTo(p0.x, p0.y);
                ctx.lineTo(p1.x, p1.y);
                ctx.strokeStyle = `hsla(${col.h}, ${col.s}%, ${Math.min(col.l + 20, 90)}%, ${alpha})`;
                ctx.lineWidth = width;
                ctx.stroke();
            }
        });



        // ─── Radar pulses ───
        graphNodes.forEach(node => {
            if (!node.radarPulse) return;
            const age = time - node.radarPulse.startTime;
            const alpha = Math.max(0, 0.15 * (1 - node.radarPulse.radius / (node.radius * 4)));
            if (alpha <= 0) return;
            const col = nodeColor(node);
            const sp = worldToScreen(node.x, node.y);
            const sr = node.radarPulse.radius * camera.zoom;
            ctx.beginPath();
            ctx.arc(sp.x, sp.y, sr, 0, Math.PI * 2);
            ctx.strokeStyle = `hsla(${col.h}, ${col.s}%, ${col.l}%, ${alpha})`;
            ctx.lineWidth = 1.5 * camera.zoom;
            ctx.stroke();
        });

        // ─── Rocket flame trails + flame particles ───
        graphNodes.forEach(node => {
            if (!node.thrustTime || node.thrustTime <= 0) return;
            const thrustAge = time - node.thrustTime;
            if (thrustAge >= THRUST_DURATION) return;
            const decay = 1 - thrustAge / THRUST_DURATION;
            const col = nodeColor(node);
            const sp = worldToScreen(node.x, node.y);
            const r = node.radius * camera.zoom;
            // Flame cone opposite to thrust direction
            const flameLen = r * 2.5 * decay * node.thrustStrength;
            const flameW = r * 0.4 * decay;
            const flameAngle = node.thrustAngle + Math.PI; // flame points opposite to thrust

            // Draw TWO rockets offset by 90 degrees
            for (const offset of [-r * 0.7, r * 0.7]) {
                const rX = sp.x + Math.cos(node.thrustAngle + Math.PI / 2) * offset;
                const rY = sp.y + Math.sin(node.thrustAngle + Math.PI / 2) * offset;

                const tipX = rX + Math.cos(flameAngle) * flameLen;
                const tipY = rY + Math.sin(flameAngle) * flameLen;
                const perpX = Math.cos(flameAngle + Math.PI / 2) * flameW;
                const perpY = Math.sin(flameAngle + Math.PI / 2) * flameW;

                ctx.beginPath();
                ctx.moveTo(rX + perpX, rY + perpY);
                ctx.lineTo(tipX, tipY);
                ctx.lineTo(rX - perpX, rY - perpY);
                ctx.closePath();

                if (isFinite(rX) && isFinite(rY) && isFinite(tipX) && isFinite(tipY)) {
                    ctx.fillStyle = `hsla(30, 100%, 75%, ${0.5 * decay})`;
                    ctx.fill();
                }
            }
        });



        // Nodes
        ctx.globalCompositeOperation = 'source-over';
        graphNodes.forEach(node => {
            if (!isInView(node.x, node.y, 60)) return;

            const sp = worldToScreen(node.x, node.y);
            const col = nodeColor(node);
            const isHovered = node === hoveredNode;
            const hoverPulse = isHovered ? 2.5 + 0.5 * Math.sin(time * 10) : 1;
            const pulse = (1 + 0.04 * Math.sin(time * 1.5 + node.phase)) * hoverPulse;
            const massScale = 0.7 + (node.mass || 1) * 0.3;  // bigger mass = bigger visual
            const r = Math.max(8, Math.min(16, (node.radius || 22) * pulse * massScale * camera.zoom));

            // Pulsing brightness — brighter for higher mass (suns vs planets)
            const brightPulse = 0.8 + 0.2 * Math.sin(time * 2 + node.phase);
            const massBright = Math.min(1, (node.mass || 1) * 0.4);
            let adjustedL = Math.min(col.l * brightPulse + 15 + massBright * 10, 95);
            if (isHovered) adjustedL = 100; // Burning sun core
            const adjColor = { h: col.h, s: isHovered ? 100 : col.s, l: adjustedL };

            // Outer glow halo — brighter for massive nodes
            const glowScale = isHovered ? (5.0 + 1.0 * Math.sin(time * 15)) : (1.8 + massBright * 1.2);
            const glowSize = r * glowScale;
            if (isFinite(sp.x) && isFinite(sp.y) && isFinite(r) && isFinite(glowSize) && r > 0 && glowSize > 0) {
                const hueIndex = Math.max(0, Math.min(360, Math.floor(col.h || 0)));
                const sprite = glowSprites[hueIndex];
                if (sprite) {
                    ctx.globalCompositeOperation = 'lighter';
                    ctx.globalAlpha = isHovered ? 1.0 : (0.2 + massBright * 0.2);
                    ctx.drawImage(sprite, sp.x - glowSize, sp.y - glowSize, glowSize * 2, glowSize * 2);
                    ctx.globalAlpha = 1.0;
                    ctx.globalCompositeOperation = 'source-over';
                }
            }

            node.rotAngle += node.rotSpeed * 0.016;

            drawShape(ctx, sp.x, sp.y, r, node.shape, node.rotAngle, adjColor, isHovered);

            // Package number centered on node
            if (node.pkgNum && r > 8) {
                ctx.save();
                ctx.fillStyle = isLightMode ? `hsla(${adjColor.h}, 20%, 20%, 0.9)` : `hsla(${adjColor.h}, 20%, 95%, 0.9)`;
                const fontSize = Math.max(8, Math.min(r * 0.7, 16));
                ctx.font = `bold ${fontSize}px 'SF Mono', monospace`;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText(node.pkgNum, sp.x, sp.y);
                ctx.restore();
            }

            // Standout gold corona for high-quality packages
            if ((node.priority_score ?? 0) >= 0.65) {
                const standoutPulse = 1 + 0.2 * Math.sin(time * 3 + node.phase);
                const glowR = r * 2.2 * standoutPulse;
                if (isFinite(sp.x) && isFinite(sp.y) && isFinite(r) && isFinite(glowR) && r > 0 && glowR > 0) {
                    const sprite = glowSprites[45];
                    if (sprite) {
                        ctx.globalCompositeOperation = 'lighter';
                        ctx.globalAlpha = 0.25;
                        ctx.drawImage(sprite, sp.x - glowR, sp.y - glowR, glowR * 2, glowR * 2);
                        ctx.globalAlpha = 1.0;
                        ctx.globalCompositeOperation = 'source-over';
                    }
                }
                ctx.beginPath();
                ctx.arc(sp.x, sp.y, r + 4 * camera.zoom, 0, Math.PI * 2);
                ctx.strokeStyle = `hsla(45, 100%, 65%, ${0.4 + 0.3 * Math.sin(time * 3 + node.phase)})`;
                ctx.lineWidth = 2 * camera.zoom;
                ctx.stroke();
            }

            // Highlight ring for hovered node (from sidebar hover or graph hover)
            if (isHovered) {
                // Pulsing bright ring
                ctx.beginPath();
                ctx.arc(sp.x, sp.y, r + 8 * camera.zoom, 0, Math.PI * 2);
                ctx.strokeStyle = `hsla(${col.h}, 100%, 85%, ${0.6 + 0.4 * Math.sin(time * 6)})`;
                ctx.lineWidth = 3 * camera.zoom;
                ctx.stroke();
                // Expanding radar rings
                for (let ring = 0; ring < 3; ring++) {
                    const ringR = r + (time * 80 + ring * 40) % 120 * camera.zoom;
                    const ringAlpha = Math.max(0, 0.4 - (ringR - r) / (120 * camera.zoom) * 0.4);
                    ctx.beginPath();
                    ctx.arc(sp.x, sp.y, ringR, 0, Math.PI * 2);
                    ctx.strokeStyle = `hsla(${col.h}, 100%, 80%, ${ringAlpha})`;
                    ctx.lineWidth = 1.5 * camera.zoom;
                    ctx.stroke();
                }
                // Bright glow burst
                const burstR = r * 3 + r * Math.sin(time * 4) * 0.5;
                if (isFinite(sp.x) && isFinite(sp.y) && isFinite(r) && isFinite(burstR) && r > 0 && burstR > 0) {
                    const burstGlow = ctx.createRadialGradient(sp.x, sp.y, r * 0.5, sp.x, sp.y, burstR);
                    burstGlow.addColorStop(0, `hsla(${col.h}, 100%, 90%, 0.3)`);
                    burstGlow.addColorStop(0.5, `hsla(${col.h}, 100%, 70%, 0.1)`);
                    burstGlow.addColorStop(1, `hsla(${col.h}, 100%, 50%, 0)`);
                    ctx.beginPath();
                    ctx.arc(sp.x, sp.y, burstR, 0, Math.PI * 2);
                    ctx.fillStyle = burstGlow;
                    ctx.globalCompositeOperation = 'lighter';
                    ctx.fill();
                    ctx.globalCompositeOperation = 'source-over';
                }
            }
        });

        // Ghost nodes: render Möbius-Klein mirror copies of nodes near universe edges
        const GHOST_MARGIN = 2400 / camera.zoom;  // screen pixels in world coords
        graphNodes.forEach(node => {
            const col = nodeColor(node);
            const pulse = 1 + 0.04 * Math.sin(time * 1.5 + node.phase);
            const massScale = 0.7 + (node.mass || 1) * 0.3;
            const r = Math.max(8, Math.min(16, (node.radius || 22) * pulse * massScale * camera.zoom));
            const massBright = Math.min(1, (node.mass || 1) * 0.4);
            let adjustedL = Math.min(col.l * 0.8 + 15 + massBright * 10, 95);
            if (isLightMode) {
                adjustedL = Math.max(25, 60 - col.l * 0.5 - massBright * 15);
            }
            const adjColor = { h: col.h, s: col.s, l: adjustedL };
            const ghostAlpha = 0.25;  // ghosts are faint

            // X-ghost: wrap through X boundary, Y flipped (Möbius twist)
            if (Math.abs(node.x) > WORLD_HALF - GHOST_MARGIN) {
                const gx = node.x > 0 ? node.x - WORLD_SIZE : node.x + WORLD_SIZE;
                const gy = -node.y;
                const sp = worldToScreen(gx, gy);
                if (sp.x > -60 && sp.x < W + 60 && sp.y > -60 && sp.y < H + 60) {
                    ctx.globalAlpha = ghostAlpha;
                    drawShape(ctx, sp.x, sp.y, r, node.shape, node.rotAngle, adjColor, false);
                    ctx.globalAlpha = 1;
                }
            }
            // Y-ghost: wrap through Y boundary, X flipped (Klein twist)
            if (Math.abs(node.y) > WORLD_HALF - GHOST_MARGIN) {
                const gx = -node.x;
                const gy = node.y > 0 ? node.y - WORLD_SIZE : node.y + WORLD_SIZE;
                const sp = worldToScreen(gx, gy);
                if (sp.x > -60 && sp.x < W + 60 && sp.y > -60 && sp.y < H + 60) {
                    ctx.globalAlpha = ghostAlpha;
                    drawShape(ctx, sp.x, sp.y, r, node.shape, node.rotAngle, adjColor, false);
                    ctx.globalAlpha = 1;
                }
            }
        });

        if (animating && !isReadingPackage()) {
            rafId = requestAnimationFrame(render);
        } else {
            stopAnimation();
        }
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

    window.unfadeWelcome = function () {
        welcomeFaded = false;
        const overlay = welcomeScreen.querySelector('.welcome-overlay');
        const content = welcomeScreen.querySelector('.welcome-content');
        const footer = welcomeScreen.querySelector('.welcome-footer');
        if (overlay) {
            overlay.style.display = '';
            // force reflow
            void overlay.offsetWidth;
            overlay.style.transition = 'opacity 0.5s ease-in';
            overlay.style.opacity = '1';
        }
        if (content) {
            content.style.display = '';
            void content.offsetWidth;
            content.style.transition = 'opacity 0.5s ease-in';
            content.style.opacity = '1';
        }
        if (footer) {
            footer.style.display = '';
            void footer.offsetWidth;
            footer.style.transition = 'opacity 0.5s ease-in';
            footer.style.opacity = '1';
        }
    };

    // ─── Interaction ───
    function findNodeAt(sx, sy) {
        let closest = null, closestDist = Infinity;
        graphNodes.forEach(n => {
            const sp = worldToScreen(n.x, n.y);
            const dx = sx - sp.x, dy = sy - sp.y;
            const d = Math.sqrt(dx * dx + dy * dy);
            // Fixed 16px screen radius with 1.5x hitbox padding
            if (d < 24 && d < closestDist) {
                closest = n;
                closestDist = d;
            }
        });
        return closest;
    }

    function findClusterAt(sx, sy) {
        // Check if click is near a domain label
        const centroids = clusterData.centroids;
        const domains = Object.keys(centroids);
        for (let i = 0; i < domains.length; i++) {
            const domain = domains[i];
            const c = centroids[domain];
            const members = graphNodes.filter(n => (n.clusterDomain || n.primary_domain || 'Bridges') === domain);
            if (members.length === 0) continue;
            // Label is above the cluster circle
            let maxDist = 0;
            members.forEach(n => {
                const dx = n.x - c.x, dy = n.y - c.y;
                const d = Math.sqrt(dx * dx + dy * dy);
                if (d > maxDist) maxDist = d;
            });
            const labelY = c.y - (maxDist + 40) + 14 / camera.zoom;
            const sp = worldToScreen(c.x, labelY);
            const labelHitRadius = (domain.length * 4 + 20) * camera.zoom;
            const dx = sx - sp.x, dy = sy - sp.y;
            if (Math.sqrt(dx * dx + dy * dy) < Math.max(labelHitRadius, 30)) {
                return domain;
            }
        }
        return null;
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
            const cluster = findClusterAt(e.offsetX, e.offsetY);
            if (cluster) {
                dragCluster = cluster;
                prevDragWorld = screenToWorld(e.offsetX, e.offsetY);
                canvas.style.cursor = 'grabbing';
            } else {
                isPanning = true;
                panStart = { x: e.clientX, y: e.clientY };
                canvas.style.cursor = 'grabbing';
            }
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
        } else if (dragCluster) {
            // Move all nodes in the cluster together using frame-to-frame delta
            if (prevDragWorld) {
                const dx = mouseWorld.x - prevDragWorld.x;
                const dy = mouseWorld.y - prevDragWorld.y;
                graphNodes.forEach(n => {
                    if ((n.clusterDomain || n.primary_domain || 'Bridges') === dragCluster) {
                        n.x += dx;
                        n.y += dy;
                        n.vx = 0;
                        n.vy = 0;
                    }
                });
                const c = clusterData.centroids[dragCluster];
                if (c) { c.x += dx; c.y += dy; }
            }
            prevDragWorld = { x: mouseWorld.x, y: mouseWorld.y };
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
            hoveredCluster = !node ? findClusterAt(e.offsetX, e.offsetY) : null;
            canvas.style.cursor = node ? 'pointer' : (hoveredCluster ? 'grab' : 'grab');

            if (tooltip) {
                if (node) {
                    tooltip.classList.remove('tooltip-hidden');
                    tooltip.querySelector('.tooltip-title').textContent = (node.pkgNum ? node.pkgNum + '. ' : '') + (node.title || node.id);
                    tooltip.querySelector('.tooltip-domain').textContent = node.primary_domain || node.domain || '';
                    const scoreEl = tooltip.querySelector('.tooltip-score');
                    if (scoreEl) {
                        const ps = node.priority_score;
                        if (ps != null) {
                            const pct = Math.round(ps * 100);
                            const ql = node.quality || (ps >= 0.75 ? 'substantial' : ps >= 0.5 ? 'partial' : 'trivial');
                            scoreEl.textContent = `${pct}% ${ql}`;
                            scoreEl.style.display = '';
                        } else {
                            scoreEl.style.display = 'none';
                        }
                    }
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
        dragCluster = null;
        prevDragWorld = null;
        isPanning = false;
        canvas.style.cursor = hoveredNode ? 'pointer' : 'grab';
    });

    canvas.addEventListener('mouseleave', () => {
        dragNode = null;
        dragCluster = null;
        prevDragWorld = null;
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
            if (window.PACKAGE_DB_INDEX && window.PACKAGE_DB_INDEX[filename]) {
                loadPackage(filename);
            }
        }
    });

    canvas.addEventListener('wheel', e => {
        cameraTarget = null; // Cancel any animated zoom on manual scroll
        e.preventDefault();
        fadeWelcome();
        const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
        const newZoom = Math.max(0.0001, Math.min(5, camera.zoom * zoomFactor));

        // Zoom toward mouse position
        const wBefore = screenToWorld(e.offsetX, e.offsetY);
        camera.zoom = newZoom;
        const wAfter = screenToWorld(e.offsetX, e.offsetY);
        camera.x += wBefore.x - wAfter.x;
        camera.y += wBefore.y - wAfter.y;
    }, { passive: false });

    // Touch support
    let lastTouchDist = 0;
    let prevTouchWorld = null;
    canvas.addEventListener('touchstart', e => {
        fadeWelcome();
        if (e.touches.length === 1) {
            const touch = e.touches[0];
            const rect = canvas.getBoundingClientRect();
            const sx = touch.clientX - rect.left;
            const sy = touch.clientY - rect.top;
            const node = findNodeAt(sx, sy);
            if (node) {
                dragNode = node;
            } else {
                const cluster = findClusterAt(sx, sy);
                if (cluster) {
                    dragCluster = cluster;
                } else {
                    isPanning = true;
                    panStart = { x: touch.clientX, y: touch.clientY };
                }
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
            } else if (dragCluster) {
                if (prevTouchWorld) {
                    const dx = mouseWorld.x - prevTouchWorld.x;
                    const dy = mouseWorld.y - prevTouchWorld.y;
                    graphNodes.forEach(n => {
                        if ((n.clusterDomain || n.primary_domain || 'Bridges') === dragCluster) {
                            n.x += dx;
                            n.y += dy;
                            n.vx = 0;
                            n.vy = 0;
                        }
                    });
                    const c = clusterData.centroids[dragCluster];
                    if (c) { c.x += dx; c.y += dy; }
                }
                prevTouchWorld = { x: mouseWorld.x, y: mouseWorld.y };
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
                camera.zoom = Math.max(0.0001, Math.min(5, camera.zoom * (dist / lastTouchDist)));
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
                if (window.PACKAGE_DB_INDEX && window.PACKAGE_DB_INDEX[filename]) {
                    loadPackage(filename);
                }
            }
        }
        dragNode = null;
        dragCluster = null;
        prevDragWorld = null;
        prevTouchWorld = null;
        isPanning = false;
        lastTouchDist = 0;
        hasDragged = false;
    });

    // ─── AETHER integration: add nodes/edges at runtime ───
    window.addGraphEdges = function (newEdges) {
        if (!Array.isArray(newEdges)) return;
        newEdges.forEach(e => {
            // Avoid duplicates
            if (graphEdges.some(ge => ge.source === e.source && ge.target === e.target)) return;
            e.edgeType = e.type || 'provenance';
            graphEdges.push(e);
            // Spawn particles for the new edge
            const count = 1 + Math.floor(Math.random() * 2);
            for (let i = 0; i < count; i++) {
                edgeParticles.push({
                    edge: e,
                    t: Math.random(),
                    speed: 0.002 + Math.random() * 0.004,
                    size: 1 + Math.random() * 1.5
                });
            }
        });
    };

    window.addGraphNode = function (nodeData) {
        if (!nodeData || !nodeData.id) return;
        if (graphNodes.some(n => n.id === nodeData.id)) return;
        const domain = nodeData.primary_domain || nodeData.domain || 'Bridges';
        const centroid = clusterData.centroids[domain] || clusterData.centroids[Object.keys(clusterData.centroids)[0]];
        const px = nodeData.priority_score ?? 0.5;
        // Look up stable package number from PACKAGE_INDEX
        let pkgNum = nodeData.pkg_num || 0;
        if (!pkgNum && window.PACKAGE_INDEX) {
            const match = window.PACKAGE_INDEX.find(p => p.filename.replace('.json', '') === nodeData.id);
            if (match && match.pkg_num) pkgNum = match.pkg_num;
        }
        const node = {
            ...nodeData,
            pkgNum: pkgNum,
            trail: [],
            radarPulse: null,
            x: centroid ? centroid.x + (Math.random() - 0.5) * 60 : (Math.random() - 0.5) * 200,
            y: centroid ? centroid.y + (Math.random() - 0.5) * 60 : (Math.random() - 0.5) * 200,
            targetX: centroid ? centroid.x + (Math.random() - 0.5) * 40 : 0,
            targetY: centroid ? centroid.y + (Math.random() - 0.5) * 40 : 0,
            mass: 1.0 + px * 2.0,
            vx: 0, vy: 0,
            clusterDomain: domain,
            radius: 18 + px * 12,
            phase: Math.random() * Math.PI * 2,
            rotSpeed: 0.3 + Math.random() * 0.5,
            rotAngle: Math.random() * Math.PI * 2,
            thrustTime: 0, thrustAngle: 0, thrustStrength: 0
        };
        // Keplerian orbital velocity around galactic core
        const r = Math.sqrt(node.x * node.x + node.y * node.y) || 1;
        const orbitalV = Math.sqrt(G_CORE * CORE_MASS / Math.max(r, 50)) * 2.0;
        node.vx = -node.y / r * orbitalV + (Math.random() - 0.5) * 0.05;
        node.vy = node.x / r * orbitalV + (Math.random() - 0.5) * 0.05;
        graphNodes.push(node);
        nodeMap[node.id] = node;
    };

    // Expose pause/resume controls globally
    window.pauseGraphAnimation = stopAnimation;
    window.resumeGraphAnimation = startAnimation;
    window._pauseGraph = stopAnimation;
    window._resumeGraph = startAnimation;

    // Resize handler: only resize when welcome screen / graph is active
    window.addEventListener('resize', () => {
        if (!isReadingPackage()) {
            resize();
        }
    });

    // MutationObserver to pause/resume animation when welcome screen is hidden/shown
    const welcomeObserver = new MutationObserver(() => {
        if (welcomeScreen.classList.contains('hidden')) {
            stopAnimation();
        } else {
            startAnimation();
        }
    });
    welcomeObserver.observe(welcomeScreen, { attributes: true, attributeFilter: ['class'] });

    // MutationObserver on packageView to pause animation when reading a research package
    const packageView = document.getElementById('package-view');
    if (packageView) {
        const pkgObserver = new MutationObserver(() => {
            if (!packageView.classList.contains('hidden')) {
                stopAnimation();
            } else if (!welcomeScreen.classList.contains('hidden')) {
                startAnimation();
            }
        });
        pkgObserver.observe(packageView, { attributes: true, attributeFilter: ['class'] });
    }

    // Visibility change handler (pause when tab hidden, resume when tab active on welcome screen)
    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            stopAnimation();
        } else if (!isReadingPackage()) {
            startAnimation();
        }
    });

    // Initial state check
    if (!isReadingPackage()) {
        startAnimation();
    } else {
        stopAnimation();
    }
})();
