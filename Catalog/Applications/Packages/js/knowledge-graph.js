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
        const graphNodes = (graphData.nodes || []).map(n => ({
            ...n,
            x: 0, y: 0, vx: 0, vy: 0,
            targetX: 0, targetY: 0,
            mass: 1.0 + (n.priority_score || 0.5) * 2.0,  // heavier = more priority
            radius: 18 + (n.priority_score || 0.5) * 12,    // bigger = more priority
            phase: Math.random() * Math.PI * 2,
            rotSpeed: 0.3 + Math.random() * 0.5,
            rotAngle: Math.random() * Math.PI * 2
        }));
        // Only provenance edges (no heuristic edges)
        let graphEdges = (graphData.edges || []).filter(e => e.type === 'provenance').map(e => ({
            ...e,
            edgeType: e.type,
        }));
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
                return function() {
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
                graphNodes.push({
                    id: slug, title: pkg.title || slug, domain: pkg.domain || 'Bridges',
                    primary_domain: 'Bridges', shape: DOMAIN_SHAPES[pkg.domain] || 'icosahedron',
                    date: pkg.date || '', hue: (rng() % 360),
                    x: 0, y: 0, vx: 0, vy: 0, targetX: 0, targetY: 0, radius: 18,
                    phase: rng() / 4294967296 * Math.PI * 2,
                    rotSpeed: 0.3 + (rng() / 4294967296) * 0.5,
                    rotAngle: rng() / 4294967296 * Math.PI * 2
                });
            });
        }

        if (graphNodes.length === 0) return;

        // Expose to sidebar hover handlers
        window._graphNodes = graphNodes;
        window._setHoveredNode = function(node) { hoveredNode = node; };
        window._getHoveredNode = function() { return hoveredNode; };

        // ─── Colors by domain ───
        const DOMAIN_COLORS = {
            'Algebra':        { h: 0,   s: 80, l: 55 },
            'Tropical':       { h: 30,  s: 75, l: 55 },
            'MachineLearning': { h: 60,  s: 80, l: 50 },
            'Cryptography':   { h: 90,  s: 70, l: 50 },
            'Geometry':       { h: 120, s: 60, l: 50 },
            'EML':            { h: 150, s: 70, l: 50 },
            'Computation':    { h: 180, s: 70, l: 50 },
            'Physics':        { h: 210, s: 80, l: 55 },
            'Speculative':    { h: 240, s: 70, l: 60 },
            'Bridges':        { h: 270, s: 70, l: 60 },
            'Logic':          { h: 300, s: 70, l: 60 },
            'Pythagorean':    { h: 330, s: 70, l: 55 }
        };
        function nodeColor(node) {
            const d = node.primary_domain || 'Bridges';
            const c = DOMAIN_COLORS[d] || DOMAIN_COLORS['Bridges'];
            return c;
        }

        // ─── Canvas state ───
        let W, H;
        let animating = false;
        let camera = { x: 0, y: 0, zoom: 1 };
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

        // ─── Stars (background) ───
        const stars = [];
        for (let i = 0; i < 250; i++) {
            stars.push({
                x: Math.random() * 8000 - 4000,
                y: Math.random() * 8000 - 4000,
                r: 0.3 + Math.random() * 1.2,
                brightness: 0.3 + Math.random() * 0.7,
                twinkleSpeed: 0.5 + Math.random() * 2,
                twinklePhase: Math.random() * Math.PI * 2
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

        // ─── Layout constants (gravitational solar-system feel) ───
        const CLUSTER_RADIUS = 280;      // Distance of cluster centroids from center
        const NODE_SPACING = 65;          // Spacing between nodes within a cluster
        const K_SPRING = 0;              // No continuous spring — edges are lazy
        const REST_LENGTH = 180;          // Rest length for provenance springs
        const G_INTRA = 0.25;            // Intra-cluster attraction (same domain nodes pull together)
        const G_INTER = 0.08;            // Inter-cluster repulsion (different domains push apart)
        const SOFTENING = 120;            // Softening distance (larger = gentler at close range)
        const MIN_REPULSION_DIST = 60;    // Bumper collision radius
        const DAMPING = 0.992;            // Very low friction — floaty
        const NODE_RADIUS = 22;
        const GALAXY_ROTATION = 0.00012;  // Slow overall galaxy spin
        const EDGE_PULSE_INTERVAL = 5.0;  // Seconds between edge contraction pulses
        const EDGE_PULSE_STRENGTH = 0.5;  // Max impulse per pulse
        const EDGE_PULSE_DECAY = 2.0;     // Seconds for pulse to fade out
        const ORBITAL_SPEED = 0.15;       // Initial tangential velocity factor
        const MAX_VELOCITY = 1.5;         // Cap speed to prevent ejections

        // ─── Domain-clustered layout ───
        const DOMAIN_ORDER = ['Algebra','Tropical','Geometry','Cryptography','Physics',
            'EML','Computation','MachineLearning','Logic','Pythagorean','Speculative','Bridges'];
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
            // Tangential velocity for orbital motion around cluster center
            const cluster = clusterData.centroids[n.clusterDomain];
            if (cluster) {
                const dx = n.x - cluster.x;
                const dy = n.y - cluster.y;
                const dist = Math.sqrt(dx * dx + dy * dy) || 1;
                // Orbital speed: faster for closer nodes, all prograde
                const speed = ORBITAL_SPEED * Math.sqrt(Math.max(dist, 30) / 100);
                n.vx = -dy / dist * speed + (Math.random() - 0.5) * 0.05;
                n.vy = dx / dist * speed + (Math.random() - 0.5) * 0.05;
            } else {
                n.vx = (Math.random() - 0.5) * 0.1;
                n.vy = (Math.random() - 0.5) * 0.1;
            }
        });

        // Track last pulse time for periodic edge contraction
        let lastEdgePulse = -EDGE_PULSE_INTERVAL;  // fire immediately on first frame
        let edgePulseDomain = null;  // which domain is currently pulsing
        let edgePulseIndex = 0;     // cycle index through domains with edges
        // Pre-compute which domains have edges
        const domainsWithEdges = (() => {
            const set = new Set();
            graphEdges.forEach(e => {
                const a = nodeMap[e.source], b = nodeMap[e.target];
                if (a && b) {
                    set.add(a.clusterDomain || a.primary_domain || 'Bridges');
                    set.add(b.clusterDomain || b.primary_domain || 'Bridges');
                }
            });
            return [...set];
        })();
        // Per-edge randomized contraction targets for current pulse
        let edgePulseTargets = new Map();  // edge key → { strength, restLength }

        function simulate() {
            // ─── Edge contraction pulse: cycle through clusters one at a time ───
            const pulseAge = time - lastEdgePulse;
            if (pulseAge >= EDGE_PULSE_INTERVAL) {
                // Advance to next domain with edges
                if (domainsWithEdges.length > 0) {
                    edgePulseIndex = (edgePulseIndex + 1) % domainsWithEdges.length;
                    edgePulseDomain = domainsWithEdges[edgePulseIndex];
                }
                lastEdgePulse = time;
                edgePulseTargets.clear();
                // Randomize per-edge contraction for edges touching this domain
                graphEdges.forEach(e => {
                    const a = nodeMap[e.source], b = nodeMap[e.target];
                    if (!a || !b) return;
                    const aDomain = a.clusterDomain || a.primary_domain || 'Bridges';
                    const bDomain = b.clusterDomain || b.primary_domain || 'Bridges';
                    if (aDomain !== edgePulseDomain && bDomain !== edgePulseDomain) return;
                    const key = e.source + '→' + e.target;
                    edgePulseTargets.set(key, {
                        strength: (0.2 + Math.random() * 0.8) * EDGE_PULSE_STRENGTH,
                        restLength: REST_LENGTH * (0.3 + Math.random() * 0.5),
                    });
                });
            }
            // Apply decaying pulse force to provenance edges in current domain
            const pulseStrength = pulseAge < EDGE_PULSE_DECAY
                ? (1 - pulseAge / EDGE_PULSE_DECAY)  // linear fade 1→0
                : 0;
            if (pulseStrength > 0) {
                graphEdges.forEach(e => {
                    const a = nodeMap[e.source], b = nodeMap[e.target];
                    if (!a || !b) return;
                    const key = e.source + '→' + e.target;
                    const target = edgePulseTargets.get(key);
                    if (!target) return;
                    const dx = b.x - a.x, dy = b.y - a.y;
                    const d = Math.sqrt(dx * dx + dy * dy) || 1;
                    const f = target.strength * (d - target.restLength) / d;
                    const fx = dx * f * pulseStrength;
                    const fy = dy * f * pulseStrength;
                    a.vx += fx; a.vy += fy;
                    b.vx -= fx; b.vy -= fy;
                });
            }

            // ─── Galaxy rotation: slowly rotate entire scene ───
            const cosG = Math.cos(GALAXY_ROTATION), sinG = Math.sin(GALAXY_ROTATION);
            graphNodes.forEach(n => {
                if (n === dragNode) return;
                if (dragCluster && (n.clusterDomain || n.primary_domain || 'Bridges') === dragCluster) return;
                const nx = n.x * cosG - n.y * sinG;
                const ny = n.x * sinG + n.y * cosG;
                n.x = nx; n.y = ny;
                // Also rotate velocity to maintain orbital direction
                const nvx = n.vx * cosG - n.vy * sinG;
                const nvy = n.vx * sinG + n.vy * cosG;
                n.vx = nvx; n.vy = nvy;
            });
            // Rotate cluster centroids along with the galaxy (for labels)
            Object.values(clusterData.centroids).forEach(c => {
                const cx = c.x * cosG - c.y * sinG;
                const cy = c.x * sinG + c.y * cosG;
                c.x = cx; c.y = cy;
            });

            // ─── N-body: intra-cluster attraction, inter-cluster repulsion ───
            for (let i = 0; i < graphNodes.length; i++) {
                const a = graphNodes[i];
                if (a === dragNode) continue;
                const aDomain = a.clusterDomain || a.primary_domain || 'Bridges';
                if (dragCluster && aDomain === dragCluster) continue;
                for (let j = i + 1; j < graphNodes.length; j++) {
                    const b = graphNodes[j];
                    if (b === dragNode) continue;
                    const bDomain = b.clusterDomain || b.primary_domain || 'Bridges';
                    if (dragCluster && bDomain === dragCluster) continue;

                    const dx = b.x - a.x, dy = b.y - a.y;
                    const d2 = dx * dx + dy * dy;
                    const d = Math.sqrt(d2) || 1;

                    if (aDomain === bDomain) {
                        // ── Same cluster: gravitational attraction ──
                        const force = G_INTRA * a.mass * b.mass / (d2 + SOFTENING * SOFTENING);
                        const fx = (dx / d) * force;
                        const fy = (dy / d) * force;
                        a.vx += fx; a.vy += fy;
                        b.vx -= fx; b.vy -= fy;
                    } else {
                        // ── Different clusters: repulsion ──
                        // Soft repulsion that falls off with distance
                        const force = G_INTER * a.mass * b.mass / (d2 + SOFTENING * SOFTENING);
                        const fx = (dx / d) * force;
                        const fy = (dy / d) * force;
                        a.vx -= fx; a.vy -= fy;
                        b.vx += fx; b.vy += fy;
                    }

                    // Pinball bumper collision: bounce with extra energy
                    if (d < MIN_REPULSION_DIST) {
                        const nx = dx / d, ny = dy / d;
                        const relVx = a.vx - b.vx, relVy = a.vy - b.vy;
                        const relVn = relVx * nx + relVy * ny;
                        if (relVn > 0) {
                            const BOUNCE = 1.6;
                            const totalMass = a.mass + b.mass;
                            const impulseA = (1 + BOUNCE) * relVn * b.mass / totalMass;
                            const impulseB = (1 + BOUNCE) * relVn * a.mass / totalMass;
                            a.vx -= impulseA * nx;
                            a.vy -= impulseA * ny;
                            b.vx += impulseB * nx;
                            b.vy += impulseB * ny;
                        }
                        const overlap = MIN_REPULSION_DIST - d;
                        if (overlap > 0) {
                            const pushForce = overlap * 0.5;
                            a.x -= nx * pushForce;
                            a.y -= ny * pushForce;
                            b.x += nx * pushForce;
                            b.y += ny * pushForce;
                        }
                    }
                }
            }

            // ─── Gentle organic drift for liveliness ───
            graphNodes.forEach(n => {
                if (n === dragNode) return;
                if (dragCluster && (n.clusterDomain || n.primary_domain || 'Bridges') === dragCluster) return;
                n.vx += Math.sin(time * 0.3 + n.phase) * 0.005;
                n.vy += Math.cos(time * 0.4 + n.phase * 1.3) * 0.005;
            });

            // ─── Damping + velocity cap + integrate ───
            graphNodes.forEach(n => {
                if (n === dragNode) return;
                if (dragCluster && (n.clusterDomain || n.primary_domain || 'Bridges') === dragCluster) return;
                n.vx *= DAMPING;
                n.vy *= DAMPING;
                // Cap velocity to prevent ejections
                const speed = Math.sqrt(n.vx * n.vx + n.vy * n.vy);
                if (speed > MAX_VELOCITY) {
                    n.vx = (n.vx / speed) * MAX_VELOCITY;
                    n.vy = (n.vy / speed) * MAX_VELOCITY;
                }
                n.x += n.vx;
                n.y += n.vy;
            });
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
                    const v = [[1,1,1],[1,-1,-1],[-1,1,-1],[-1,-1,1]];
                    edges3d = [[0,1],[0,2],[0,3],[1,2],[1,3],[2,3]];
                    const p = project3D(v.map(c => c.map(c2 => c2 * S)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edges3d.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'cube': {
                    const v = [];
                    for (let sx = -1; sx <= 1; sx += 2) for (let sy = -1; sy <= 1; sy += 2) for (let sz = -1; sz <= 1; sz += 2) v.push([sx, sy, sz]);
                    const edgePairs = [[0,1],[0,2],[0,4],[1,3],[1,5],[2,3],[2,6],[3,7],[4,5],[4,6],[5,7],[6,7]];
                    const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.7)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edgePairs.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'octahedron': {
                    const v = [[1,0,0],[-1,0,0],[0,1,0],[0,-1,0],[0,0,1],[0,0,-1]];
                    const edgePairs = [[0,2],[0,3],[0,4],[0,5],[1,2],[1,3],[1,4],[1,5],[2,4],[2,5],[3,4],[3,5]];
                    const p = project3D(v.map(c => c.map(c2 => c2 * S)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edgePairs.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
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
                        if (Math.abs(Math.sqrt(dx*dx+dy*dy+dz*dz) - 2/phi) < 0.01) edgePairs.push([i, j]);
                    }
                    const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.55)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.2;
                    edgePairs.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'icosahedron': {
                    const phi = (1 + Math.sqrt(5)) / 2;
                    const v = [[0,1,phi],[0,1,-phi],[0,-1,phi],[0,-1,-phi],[1,phi,0],[1,-phi,0],[-1,phi,0],[-1,-phi,0],[phi,0,1],[phi,0,-1],[-phi,0,1],[-phi,0,-1]];
                    const edgePairs = [[0,2],[0,4],[0,6],[0,8],[0,10],[1,3],[1,4],[1,6],[1,9],[1,11],[2,5],[2,7],[2,8],[2,10],[3,5],[3,7],[3,9],[3,11],[4,6],[4,8],[4,9],[5,7],[5,8],[5,9],[6,10],[6,11],[7,10],[7,11],[8,9],[10,11]];
                    const p = project3D(v.map(c => c.map(c2 => c2 * S * 0.5)), rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edgePairs.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
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
                    starGlow.addColorStop(0, `hsla(${h}, ${s}%, ${Math.min(l+30,95)}%, 0.5)`);
                    starGlow.addColorStop(1, `hsla(${h}, ${s}%, ${l}%, 0.0)`);
                    ctx.fillStyle = starGlow; ctx.fill();
                    break;
                }
                case 'hexagonal_prism': {
                    const v = [], edgeP = [];
                    for (let i = 0; i < 6; i++) {
                        const a = Math.PI / 3 * i;
                        v.push([Math.cos(a)*S, S*0.6, Math.sin(a)*S]);
                        v.push([Math.cos(a)*S, -S*0.6, Math.sin(a)*S]);
                    }
                    for (let i = 0; i < 6; i++) { edgeP.push([i*2, i*2+1]); edgeP.push([i*2, ((i+1)%6)*2]); edgeP.push([i*2+1, ((i+1)%6)*2+1]); }
                    const p = project3D(v, rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                    edgeP.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
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
                        ringPts.push(project3D([[Math.cos(a)*S*1.1, 0, Math.sin(a)*S*1.1]], rotX*1.3, rotY*0.7)[0]);
                    }
                    ctx.beginPath();
                    ringPts.forEach((p2, i) => i === 0 ? ctx.moveTo(p2[0], p2[1]) : ctx.lineTo(p2[0], p2[1]));
                    ctx.strokeStyle = `hsla(${h}, ${s}%, ${Math.min(l+20,90)}%, 0.6)`;
                    ctx.lineWidth = 1; ctx.stroke();
                    break;
                }
                case 'diamond': {
                    // Elongated octahedron (top/bottom points)
                    const v = [[0,1.3*S,0],[S*0.7,0,0],[0,0,S*0.7],[-S*0.7,0,0],[0,0,-S*0.7],[0,-1.3*S,0]];
                    const edgeP = [[0,1],[0,2],[0,3],[0,4],[1,2],[2,3],[3,4],[4,1],[1,5],[2,5],[3,5],[4,5]];
                    const p = project3D(v, rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.5;
                    edgeP.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'triangular_prism': {
                    const v = [];
                    for (let i = 0; i < 3; i++) {
                        const a = (i / 3) * Math.PI * 2 - Math.PI / 2;
                        v.push([Math.cos(a)*S, S*0.6, Math.sin(a)*S]);
                        v.push([Math.cos(a)*S, -S*0.6, Math.sin(a)*S]);
                    }
                    const edgeP = [[0,1],[2,3],[4,5],[0,2],[2,4],[0,4],[1,3],[3,5],[1,5]];
                    const p = project3D(v, rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                    edgeP.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
                    break;
                }
                case 'pentagonal_prism': {
                    const v = [], edgeP = [];
                    for (let i = 0; i < 5; i++) {
                        const a = (i / 5) * Math.PI * 2 - Math.PI / 2;
                        v.push([Math.cos(a)*S, S*0.6, Math.sin(a)*S]);
                        v.push([Math.cos(a)*S, -S*0.6, Math.sin(a)*S]);
                    }
                    for (let i = 0; i < 5; i++) { edgeP.push([i*2, i*2+1]); edgeP.push([i*2, ((i+1)%5)*2]); edgeP.push([i*2+1, ((i+1)%5)*2+1]); }
                    const p = project3D(v, rotX, rotY);
                    ctx.strokeStyle = strokeColor; ctx.lineWidth = 1.3;
                    edgeP.forEach(([a,b]) => { ctx.beginPath(); ctx.moveTo(p[a][0], p[a][1]); ctx.lineTo(p[b][0], p[b][1]); ctx.stroke(); });
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
                    sdGlow.addColorStop(0, `hsla(${h}, ${s}%, ${Math.min(l+30,95)}%, 0.4)`);
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
                ctx.strokeStyle = `hsla(${h}, ${s}%, ${Math.min(l+20,90)}%, 0.4)`;
                ctx.lineWidth = 2;
                ctx.stroke();
            }

            ctx.restore();
        }

        // ─── Render ───
        function resize() {
            W = canvas.width = canvas.offsetWidth;
            H = canvas.height = canvas.offsetHeight;
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
            if (!animating) return;
            time += 0.016;

            simulate();

            ctx.clearRect(0, 0, W, H);

            // Background: dark navy with subtle nebula
            const bgGrad = ctx.createRadialGradient(W * 0.3, H * 0.4, 0, W * 0.5, H * 0.5, Math.max(W, H) * 0.8);
            bgGrad.addColorStop(0, '#0d0d2b');
            bgGrad.addColorStop(0.5, '#0a0a1a');
            bgGrad.addColorStop(1, '#050510');
            ctx.fillStyle = bgGrad;
            ctx.fillRect(0, 0, W, H);

            // Second nebula glow
            const neb2 = ctx.createRadialGradient(W * 0.7, H * 0.6, 0, W * 0.7, H * 0.6, Math.max(W, H) * 0.5);
            neb2.addColorStop(0, 'rgba(60, 20, 80, 0.15)');
            neb2.addColorStop(1, 'rgba(10, 10, 26, 0.0)');
            ctx.fillStyle = neb2;
            ctx.fillRect(0, 0, W, H);

            // Stars
            stars.forEach(s => {
                const sp = worldToScreen(s.x, s.y);
                if (sp.x < -5 || sp.x > W + 5 || sp.y < -5 || sp.y > H + 5) return;
                const twinkle = 0.5 + 0.5 * Math.sin(time * s.twinkleSpeed + s.twinklePhase);
                const alpha = s.brightness * twinkle;
                ctx.beginPath();
                ctx.arc(sp.x, sp.y, s.r * camera.zoom, 0, Math.PI * 2);
                ctx.fillStyle = `rgba(200, 200, 255, ${alpha})`;
                ctx.fill();
            });

            // ─── Domain cluster boundaries and labels (dynamic centroids) ───
            const centroids = clusterData.centroids;
            // Recompute cluster centroids from actual node positions
            const liveClusters = {};
            graphNodes.forEach(n => {
                const domain = n.clusterDomain || n.primary_domain || 'Bridges';
                if (!liveClusters[domain]) liveClusters[domain] = { xs: [], ys: [] };
                liveClusters[domain].xs.push(n.x);
                liveClusters[domain].ys.push(n.y);
            });
            Object.keys(liveClusters).forEach(domain => {
                const lc = liveClusters[domain];
                const c = centroids[domain];
                if (!c) return;
                // Update centroid to actual center of mass of member nodes
                c.x = lc.xs.reduce((a, b) => a + b, 0) / lc.xs.length;
                c.y = lc.ys.reduce((a, b) => a + b, 0) / lc.ys.length;
            });
            Object.values(centroids).forEach(c => {
                const domain = c.domain;
                if (!liveClusters[domain]) return;
                const sp = worldToScreen(c.x, c.y);
                const col = DOMAIN_COLORS[domain] || DOMAIN_COLORS['Bridges'];

                // Compute cluster radius from member nodes
                const members = graphNodes.filter(n => (n.clusterDomain || n.primary_domain || 'Bridges') === domain);
                if (members.length === 0) return;
                let maxDist = 0;
                members.forEach(n => {
                    const dx = n.x - c.x, dy = n.y - c.y;
                    const d = Math.sqrt(dx * dx + dy * dy);
                    if (d > maxDist) maxDist = d;
                });
                const clusterR = (maxDist + 40) * camera.zoom;

                // Filled circle with domain color
                const isClusterActive = (domain === hoveredCluster) || (domain === dragCluster);
                ctx.beginPath();
                ctx.arc(sp.x, sp.y, clusterR, 0, Math.PI * 2);
                ctx.fillStyle = `hsla(${col.h}, ${col.s}%, ${col.l}%, ${isClusterActive ? 0.08 : 0.04})`;
                ctx.fill();
                // Border circle
                ctx.strokeStyle = `hsla(${col.h}, ${col.s}%, ${col.l}%, ${isClusterActive ? 0.35 : 0.12})`;
                ctx.lineWidth = isClusterActive ? 2 : 1;
                ctx.stroke();

                // Domain label
                ctx.fillStyle = `hsla(${col.h}, ${col.s}%, ${Math.min(col.l + 20, 85)}%, ${isClusterActive ? 0.8 : 0.35})`;
                ctx.font = `${isClusterActive ? 'bold ' : ''}${Math.max(11, (isClusterActive ? 14 : 13) * camera.zoom)}px 'Segoe UI', system-ui, sans-serif`;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText(domain, sp.x, sp.y - clusterR + 14 * camera.zoom);
            });

            // ─── Domain bridges (subtle arcs between cluster centroids) ───
            domainBridges.forEach(bridge => {
                const cA = centroids[bridge.domain_a];
                const cB = centroids[bridge.domain_b];
                if (!cA || !cB) return;
                const spA = worldToScreen(cA.x, cA.y);
                const spB = worldToScreen(cB.x, cB.y);
                const colA = DOMAIN_COLORS[bridge.domain_a] || DOMAIN_COLORS['Bridges'];
                const colB = DOMAIN_COLORS[bridge.domain_b] || DOMAIN_COLORS['Bridges'];
                const strength = bridge.strength || 0.3;
                const alpha = 0.06 + strength * 0.12;

                // Draw curved arc between cluster centroids
                const mx = (spA.x + spB.x) / 2;
                const my = (spA.y + spB.y) / 2;
                // Curve outward from center
                const dx = spB.x - spA.x, dy = spB.y - spA.y;
                const curveOffset = -dy * 0.15; // perpendicular offset
                const cpx = mx + dx * 0 + curveOffset;
                const cpy = my + dy * 0 + Math.abs(dx) * 0.15;

                ctx.beginPath();
                ctx.moveTo(spA.x, spA.y);
                ctx.quadraticCurveTo(cpx, cpy, spB.x, spB.y);
                ctx.strokeStyle = `hsla(${(colA.h + colB.h) / 2}, 50%, 65%, ${alpha})`;
                ctx.lineWidth = 1 + strength * 1.5;
                ctx.setLineDash([4 * camera.zoom, 6 * camera.zoom]);
                ctx.stroke();
                ctx.setLineDash([]);
            });

            // ─── Provenance edges (visible only for currently pulsing cluster) ───
            const edgePulseAge = time - lastEdgePulse;
            const edgeFadeAlpha = edgePulseAge < EDGE_PULSE_DECAY
                ? 1 - edgePulseAge / EDGE_PULSE_DECAY
                : 0;
            if (edgeFadeAlpha > 0 && edgePulseDomain) {
                graphEdges.forEach(e => {
                    const a = nodeMap[e.source], b = nodeMap[e.target];
                    if (!a || !b) return;
                    const aDomain = a.clusterDomain || a.primary_domain || 'Bridges';
                    const bDomain = b.clusterDomain || b.primary_domain || 'Bridges';
                    if (aDomain !== edgePulseDomain && bDomain !== edgePulseDomain) return;
                    if (!isInView(a.x, a.y, 50) && !isInView(b.x, b.y, 50)) return;

                    const sa = worldToScreen(a.x, a.y), sb = worldToScreen(b.x, b.y);
                    const colA = nodeColor(a), colB = nodeColor(b);
                    const blendH = (colA.h + colB.h) / 2;
                    const strength = e.strength || 1.0;
                    const lineW = 1.5 + strength * 2.5;
                    const glowAlpha = (0.25 + 0.3 * strength) * edgeFadeAlpha;
                    const coreAlpha = (0.7 + 0.3 * strength) * edgeFadeAlpha;

                    // Glow line
                    ctx.beginPath();
                    ctx.moveTo(sa.x, sa.y);
                    ctx.lineTo(sb.x, sb.y);
                    ctx.strokeStyle = `hsla(${blendH}, 70%, 70%, ${glowAlpha})`;
                    ctx.lineWidth = lineW * 5;
                    ctx.stroke();

                    // Core line
                    ctx.beginPath();
                    ctx.moveTo(sa.x, sa.y);
                    ctx.lineTo(sb.x, sb.y);
                    const edgeGrad = ctx.createLinearGradient(sa.x, sa.y, sb.x, sb.y);
                    edgeGrad.addColorStop(0, `hsla(${colA.h}, ${colA.s}%, ${Math.min(colA.l + 20, 90)}%, ${coreAlpha})`);
                    edgeGrad.addColorStop(1, `hsla(${colB.h}, ${colB.s}%, ${Math.min(colB.l + 20, 90)}%, ${coreAlpha})`);
                    ctx.strokeStyle = edgeGrad;
                    ctx.lineWidth = lineW;
                    ctx.stroke();
                });
            }

            // Edge particles (only for visible edges)
            if (edgeFadeAlpha > 0 && edgePulseDomain) {
                edgeParticles.forEach(p => {
                    p.t += p.speed;
                    if (p.t > 1) p.t -= 1;
                    const a = nodeMap[p.edge.source], b = nodeMap[p.edge.target];
                    if (!a || !b) return;
                    const aDomain = a.clusterDomain || a.primary_domain || 'Bridges';
                    const bDomain = b.clusterDomain || b.primary_domain || 'Bridges';
                    if (aDomain !== edgePulseDomain && bDomain !== edgePulseDomain) return;
                    if (!isInView(a.x, a.y, 50) && !isInView(b.x, b.y, 50)) return;

                    const wx = a.x + (b.x - a.x) * p.t;
                    const wy = a.y + (b.y - a.y) * p.t;
                    const sp = worldToScreen(wx, wy);
                    const colA = nodeColor(a), colB = nodeColor(b);
                    const blendH = (colA.h + colB.h) / 2;
                    const alpha = (0.6 + 0.4 * Math.sin(p.t * Math.PI)) * edgeFadeAlpha;
                    const pSize = p.size * 1.4;

                    ctx.beginPath();
                    ctx.arc(sp.x, sp.y, pSize * camera.zoom, 0, Math.PI * 2);
                    ctx.fillStyle = `hsla(${blendH}, 80%, 80%, ${alpha})`;
                    ctx.fill();
                });
            }

            // Nodes
            graphNodes.forEach(node => {
                if (!isInView(node.x, node.y, 60)) return;

                const sp = worldToScreen(node.x, node.y);
                const col = nodeColor(node);
                const isHovered = node === hoveredNode;
                const pulse = 1 + 0.04 * Math.sin(time * 1.5 + node.phase);
                const massScale = 0.7 + (node.mass || 1) * 0.3;  // bigger mass = bigger visual
                const r = (node.radius || 22) * pulse * massScale * camera.zoom;

                // Pulsing brightness — brighter for higher mass (suns vs planets)
                const brightPulse = 0.8 + 0.2 * Math.sin(time * 2 + node.phase);
                const massBright = Math.min(1, (node.mass || 1) * 0.4);
                const adjustedL = Math.min(col.l * brightPulse + 15 + massBright * 10, 95);
                const adjColor = { h: col.h, s: col.s, l: adjustedL };

                // Outer glow halo — brighter for massive nodes
                const glowSize = r * (1.8 + massBright * 1.2);
                const outerGlow = ctx.createRadialGradient(sp.x, sp.y, r * 0.5, sp.x, sp.y, glowSize);
                outerGlow.addColorStop(0, `hsla(${col.h}, ${col.s}%, ${Math.min(col.l + 20, 90)}%, ${0.15 + massBright * 0.15})`);
                outerGlow.addColorStop(0.5, `hsla(${col.h}, ${col.s}%, ${col.l}%, ${0.05 + massBright * 0.05})`);
                outerGlow.addColorStop(1, `hsla(${col.h}, ${col.s}%, ${col.l}%, 0)`);
                ctx.beginPath();
                ctx.arc(sp.x, sp.y, glowSize, 0, Math.PI * 2);
                ctx.fillStyle = outerGlow;
                ctx.fill();

                node.rotAngle += node.rotSpeed * 0.016;

                drawShape(ctx, sp.x, sp.y, r, node.shape, node.rotAngle, adjColor, isHovered);

                // Highlight ring for hovered node (from sidebar hover or graph hover)
                if (isHovered) {
                    ctx.beginPath();
                    ctx.arc(sp.x, sp.y, r + 6 * camera.zoom, 0, Math.PI * 2);
                    ctx.strokeStyle = `hsla(${col.h}, 100%, 75%, ${0.5 + 0.3 * Math.sin(time * 4)})`;
                    ctx.lineWidth = 2.5 * camera.zoom;
                    ctx.stroke();
                }
            });

            requestAnimationFrame(render);
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

        // ─── Interaction ───
        function findNodeAt(sx, sy) {
            const w = screenToWorld(sx, sy);
            let closest = null, closestDist = Infinity;
            graphNodes.forEach(n => {
                const dx = w.x - n.x, dy = w.y - n.y;
                const d = Math.sqrt(dx * dx + dy * dy);
                if (d < n.radius * 1.5 && d < closestDist) {
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

                // Graph node hover → highlight sidebar item
                document.querySelectorAll('.nav-item.graph-highlight').forEach(el => el.classList.remove('graph-highlight'));
                if (node) {
                    const sidebarItem = document.querySelector(`.nav-item[data-slug="${node.id}"]`);
                    if (sidebarItem) {
                        sidebarItem.classList.add('graph-highlight');
                        sidebarItem.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                    }
                }

                if (tooltip) {
                    if (node) {
                        tooltip.classList.remove('tooltip-hidden');
                        tooltip.querySelector('.tooltip-title').textContent = node.title || node.id;
                        tooltip.querySelector('.tooltip-domain').textContent = node.primary_domain || node.domain || '';
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
                if (window.PACKAGE_DB && window.PACKAGE_DB[filename]) {
                    loadPackage(filename);
                }
            }
        });

        canvas.addEventListener('wheel', e => {
            e.preventDefault();
            fadeWelcome();
            const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
            const newZoom = Math.max(0.2, Math.min(5, camera.zoom * zoomFactor));

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
                    camera.zoom = Math.max(0.2, Math.min(5, camera.zoom * (dist / lastTouchDist)));
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
                    if (window.PACKAGE_DB && window.PACKAGE_DB[filename]) {
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
        window.addGraphEdges = function(newEdges) {
            if (!Array.isArray(newEdges)) return;
            newEdges.forEach(e => {
                // Avoid duplicates
                if (graphEdges.some(ge => ge.source === e.source && ge.target === e.target)) return;
                e.edgeType = e.type || 'provenance';
                graphEdges.push(e);
                // Spawn particles for the new edge
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
        };

        window.addGraphNode = function(nodeData) {
            if (!nodeData || !nodeData.id) return;
            if (graphNodes.some(n => n.id === nodeData.id)) return;
            const domain = nodeData.primary_domain || nodeData.domain || 'Bridges';
            const centroid = clusterData.centroids[domain] || clusterData.centroids[Object.keys(clusterData.centroids)[0]];
            const px = nodeData.priority_score || 0.5;
            const node = {
                ...nodeData,
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
                rotAngle: Math.random() * Math.PI * 2
            };
            // Give orbital velocity around cluster center
            if (centroid) {
                const dx = node.x - centroid.x;
                const dy = node.y - centroid.y;
                const dist = Math.sqrt(dx * dx + dy * dy) || 1;
                const speed = ORBITAL_SPEED * Math.sqrt(Math.max(dist, 30) / 100);
                node.vx = -dy / dist * speed + (Math.random() - 0.5) * 0.05;
                node.vy = dx / dist * speed + (Math.random() - 0.5) * 0.05;
            }
            graphNodes.push(node);
            nodeMap[node.id] = node;
        };

        // Resize handler
        window.addEventListener('resize', resize);

        // MutationObserver to pause/resume animation
        const observer = new MutationObserver(() => {
            if (welcomeScreen.classList.contains('hidden')) {
                animating = false;
            } else {
                resize();
                animating = true;
                requestAnimationFrame(render);
            }
        });
        observer.observe(welcomeScreen, { attributes: true, attributeFilter: ['class'] });

        if (!welcomeScreen.classList.contains('hidden')) {
            resize();
            animating = true;
            requestAnimationFrame(render);
        }
    })();
