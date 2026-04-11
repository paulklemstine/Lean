"""
generate_research_visuals.py — SVG visualizations for the 5 research questions.
"""

import math

PHI = (1 + math.sqrt(5)) / 2

def svg_header(width, height, title=""):
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
  <defs>
    <style>
      .title {{ font: bold 18px 'Segoe UI', Arial, sans-serif; fill: #1a1a2e; }}
      .subtitle {{ font: 14px 'Segoe UI', Arial, sans-serif; fill: #4a4a6a; }}
      .label {{ font: 12px 'Courier New', monospace; fill: #333; }}
      .label-sm {{ font: 10px 'Courier New', monospace; fill: #555; }}
      .axis {{ font: 11px 'Segoe UI', Arial, sans-serif; fill: #666; }}
      .note {{ font: italic 11px 'Segoe UI', Arial, sans-serif; fill: #888; }}
    </style>
    <linearGradient id="goldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FFD700;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#FFA500;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="blueGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4A90D9;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2C5F8A;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="greenGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2E7D32;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="{width}" height="{height}" fill="#fafaf8" rx="8"/>
'''

def svg_footer():
    return '</svg>\n'


# ─── Visual 8: Search Space Reduction (Q1) ──────────────────────────────────

def generate_search_space_visual():
    w, h = 800, 500
    svg = svg_header(w, h)
    svg += f'  <text x="400" y="35" text-anchor="middle" class="title">Q1: Search Space Reduction — Binary vs Fibonacci</text>\n'

    # Bar chart showing search space at different k values
    k_vals = [4, 8, 12, 16, 20, 24, 28, 32]
    bar_w = 35
    gap = 18
    start_x = 80
    chart_h = 350
    base_y = 420

    svg += f'  <text x="400" y="60" text-anchor="middle" class="subtitle">Valid digit patterns (log₂ scale) for k-digit representations</text>\n'

    # Y-axis
    svg += f'  <line x1="{start_x}" y1="80" x2="{start_x}" y2="{base_y}" stroke="#999" stroke-width="1"/>\n'
    for i in range(0, 35, 5):
        y = base_y - (i / 32) * chart_h
        svg += f'  <line x1="{start_x-5}" y1="{y}" x2="{start_x}" y2="{y}" stroke="#999"/>\n'
        svg += f'  <text x="{start_x-10}" y="{y+4}" text-anchor="end" class="axis">{i}</text>\n'
    svg += f'  <text x="25" y="250" text-anchor="middle" transform="rotate(-90, 25, 250)" class="axis">log₂(search space)</text>\n'

    for idx, k in enumerate(k_vals):
        x = start_x + 30 + idx * (2 * bar_w + gap + 10)

        # Binary: 2^k
        log2_binary = k
        h_binary = (log2_binary / 32) * chart_h
        svg += f'  <rect x="{x}" y="{base_y - h_binary}" width="{bar_w}" height="{h_binary}" fill="url(#blueGrad)" rx="3" opacity="0.85"/>\n'
        svg += f'  <text x="{x + bar_w/2}" y="{base_y - h_binary - 5}" text-anchor="middle" class="label-sm">2^{k}</text>\n'

        # Fibonacci: F(k+2) ≈ φ^k
        log2_fib = k * math.log2(PHI)
        h_fib = (log2_fib / 32) * chart_h
        svg += f'  <rect x="{x + bar_w + 3}" y="{base_y - h_fib}" width="{bar_w}" height="{h_fib}" fill="url(#goldGrad)" rx="3" opacity="0.85"/>\n'
        svg += f'  <text x="{x + bar_w + 3 + bar_w/2}" y="{base_y - h_fib - 5}" text-anchor="middle" class="label-sm">φ^{k}</text>\n'

        # k label
        svg += f'  <text x="{x + bar_w + 1}" y="{base_y + 15}" text-anchor="middle" class="axis">k={k}</text>\n'

        # Reduction arrow
        reduction = k - k * math.log2(PHI)
        if idx >= 2:
            mid_x = x + bar_w + 1
            svg += f'  <text x="{mid_x}" y="{base_y + 30}" text-anchor="middle" class="label-sm" fill="#c00">↓{reduction:.1f}</text>\n'

    # Legend
    svg += f'  <rect x="600" y="80" width="15" height="15" fill="url(#blueGrad)" rx="2"/>\n'
    svg += f'  <text x="620" y="92" class="label">Binary (2^k)</text>\n'
    svg += f'  <rect x="600" y="100" width="15" height="15" fill="url(#goldGrad)" rx="2"/>\n'
    svg += f'  <text x="620" y="112" class="label">Fibonacci (φ^k)</text>\n'

    svg += f'  <text x="400" y="{base_y + 55}" text-anchor="middle" class="note">Per-digit advantage: 2/φ ≈ 1.236×. Cumulative advantage: (2/φ)^k → exponential gap.</text>\n'

    svg += svg_footer()
    return svg


# ─── Visual 9: Hybrid Strategy Overview (Q2) ────────────────────────────────

def generate_hybrid_visual():
    w, h = 850, 550
    svg = svg_header(w, h)
    svg += f'  <text x="425" y="35" text-anchor="middle" class="title">Q2: Three Hybrid Strategies for Fibonacci-Enhanced Factoring</text>\n'

    strategies = [
        ("Quadratic Sieve\n+ Pisano Filter", "#4A90D9",
         ["Sieve for smooth", "values x² - N", "Apply Fibonacci", "parity filter", "→ Smaller matrix"]),
        ("Number Field Sieve\n+ ℤ[φ] Structure", "#E8A838",
         ["Work in ℤ[φ]", "where φ² = φ + 1", "Fibonacci-coord", "sieving", "→ Split primes"]),
        ("ECM + Fibonacci\nParameterization", "#4CAF50",
         ["gcd(F(m),F(n))", "= F(gcd(m,n))", "Fibonacci-smooth", "group orders", "→ Better curves"]),
    ]

    for idx, (title, color, steps) in enumerate(strategies):
        x = 60 + idx * 260
        y = 80

        # Box
        svg += f'  <rect x="{x}" y="{y}" width="230" height="400" fill="white" stroke="{color}" stroke-width="3" rx="12"/>\n'

        # Header
        svg += f'  <rect x="{x}" y="{y}" width="230" height="55" fill="{color}" rx="12"/>\n'
        svg += f'  <rect x="{x}" y="{y+40}" width="230" height="15" fill="{color}"/>\n'
        lines = title.split('\n')
        for i, line in enumerate(lines):
            svg += f'  <text x="{x+115}" y="{y+25+i*18}" text-anchor="middle" font-size="13" font-weight="bold" fill="white">{line}</text>\n'

        # Steps with arrows
        for i, step in enumerate(steps):
            sy = y + 80 + i * 65
            svg += f'  <rect x="{x+15}" y="{sy}" width="200" height="35" fill="{color}" opacity="0.1" rx="6"/>\n'
            svg += f'  <text x="{x+115}" y="{sy+22}" text-anchor="middle" class="label" fill="{color}">{step}</text>\n'
            if i < len(steps) - 1:
                svg += f'  <text x="{x+115}" y="{sy+52}" text-anchor="middle" font-size="16" fill="{color}">↓</text>\n'

    # Bottom note
    svg += f'  <text x="425" y="520" text-anchor="middle" class="note">Each strategy uses Fibonacci structure at a different algorithmic level.</text>\n'
    svg += f'  <text x="425" y="536" text-anchor="middle" class="note">The Pisano filter is simplest to implement; ℤ[φ] integration requires algebraic number theory.</text>\n'

    svg += svg_footer()
    return svg


# ─── Visual 10: Base Comparison (Q3) ────────────────────────────────────────

def generate_base_comparison_visual():
    w, h = 800, 480
    svg = svg_header(w, h)
    svg += f'  <text x="400" y="35" text-anchor="middle" class="title">Q3: Constraint Tightness of Different Numeral Systems</text>\n'

    # Number line of search-per-digit values
    bases = [
        ("Fibonacci", PHI, "#FFD700", "φ ≈ 1.618"),
        ("Tribonacci", 1.839, "#90EE90", "≈ 1.839"),
        ("Binary", 2.0, "#4A90D9", "2.000"),
        ("√2 Ostrowski", 1+math.sqrt(2), "#FF6B6B", "≈ 2.414"),
        ("√3 Ostrowski", 2+math.sqrt(3), "#DDA0DD", "≈ 3.732"),
    ]

    # Horizontal axis
    ax_y = 180
    ax_x1, ax_x2 = 80, 720
    svg += f'  <line x1="{ax_x1}" y1="{ax_y}" x2="{ax_x2}" y2="{ax_y}" stroke="#333" stroke-width="2"/>\n'
    svg += f'  <text x="400" y="{ax_y+50}" text-anchor="middle" class="axis">Search space per digit (lower = tighter constraints)</text>\n'

    # Tick marks
    for val in [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]:
        x = ax_x1 + (val - 1.0) / 3.0 * (ax_x2 - ax_x1)
        svg += f'  <line x1="{x}" y1="{ax_y-5}" x2="{x}" y2="{ax_y+5}" stroke="#333" stroke-width="1"/>\n'
        svg += f'  <text x="{x}" y="{ax_y+20}" text-anchor="middle" class="axis">{val:.1f}</text>\n'

    # Plot each base
    for idx, (name, val, color, label) in enumerate(bases):
        x = ax_x1 + (val - 1.0) / 3.0 * (ax_x2 - ax_x1)
        y_offset = 35 + (idx % 2) * 25
        svg += f'  <circle cx="{x}" cy="{ax_y}" r="10" fill="{color}" stroke="#333" stroke-width="1.5"/>\n'
        svg += f'  <line x1="{x}" y1="{ax_y-10}" x2="{x}" y2="{ax_y - y_offset}" stroke="{color}" stroke-width="1" stroke-dasharray="3,3"/>\n'
        svg += f'  <text x="{x}" y="{ax_y - y_offset - 12}" text-anchor="middle" font-size="12" font-weight="bold" fill="{color}">{name}</text>\n'
        svg += f'  <text x="{x}" y="{ax_y - y_offset}" text-anchor="middle" class="label-sm" fill="{color}">{label}</text>\n'

    # Optimal zone
    svg += f'  <rect x="{ax_x1}" y="{ax_y-3}" width="{(PHI - 1.0) / 3.0 * (ax_x2 - ax_x1)}" height="6" fill="#FFD700" opacity="0.3"/>\n'
    svg += f'  <text x="{ax_x1 + (PHI - 1.0) / 3.0 * (ax_x2 - ax_x1) / 2}" y="{ax_y + 35}" text-anchor="middle" class="label-sm" fill="#B8860B">← Optimal zone</text>\n'

    # Bottom section: N-adapted advantage
    svg += f'  <rect x="50" y="260" width="700" height="180" fill="#f5f5f0" rx="10" stroke="#ddd"/>\n'
    svg += f'  <text x="400" y="290" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">N-Adapted Ostrowski Representations</text>\n'
    svg += f'  <text x="400" y="315" text-anchor="middle" class="label">For specific N = pq, the continued fraction of √N creates a tailored numeral system:</text>\n'

    examples = [
        ("N = 143 = 11×13", "CF(√143) = [11; 1, 22, ...]", "period 2"),
        ("N = 1147 = 31×37", "CF(√1147) = [33; 1, 6, 1, 1, 5, ...]", "period 24"),
        ("N = 10403 = 101×103", "CF(√10403) = [101; 1, 202, ...]", "period 2"),
    ]
    for i, (n, cf, period) in enumerate(examples):
        y = 340 + i * 28
        svg += f'  <text x="120" y="{y}" class="label" fill="#4A90D9">{n}</text>\n'
        svg += f'  <text x="350" y="{y}" class="label">{cf}</text>\n'
        svg += f'  <text x="650" y="{y}" class="label" fill="#888">{period}</text>\n'

    svg += f'  <text x="400" y="430" text-anchor="middle" class="note">Short periods ↔ near-square factors. The CF encodes divisor structure!</text>\n'

    svg += svg_footer()
    return svg


# ─── Visual 11: Quantum Landscape (Q4) ──────────────────────────────────────

def generate_quantum_visual():
    w, h = 800, 500
    svg = svg_header(w, h)
    svg += f'  <text x="400" y="35" text-anchor="middle" class="title">Q4: Quantum Factoring Landscape with Fibonacci Structure</text>\n'

    # Three quantum approaches as columns
    approaches = [
        ("Shor\'s Algorithm", "#E74C3C", "Polynomial time\nO(n³)", "No Fibonacci\nadvantage", "Representation-\nindependent"),
        ("Grover + Fibonacci", "#FFD700", "√(φ^k) steps\nvs √(2^k)", "Search space\n0.809^k smaller", "Constant factor\nimprovement"),
        ("Adiabatic +\nFibonacci CSP", "#4CAF50", "Ising model with\n±1/±2 couplings", "Richer interaction\ngraph topology", "May avoid\nlocal minima"),
    ]

    for idx, (title, color, time, advantage, note) in enumerate(approaches):
        x = 55 + idx * 250
        y = 70

        # Card
        svg += f'  <rect x="{x}" y="{y}" width="225" height="370" fill="white" stroke="{color}" stroke-width="2.5" rx="12"/>\n'

        # Header
        svg += f'  <rect x="{x}" y="{y}" width="225" height="50" fill="{color}" rx="12"/>\n'
        svg += f'  <rect x="{x}" y="{y+38}" width="225" height="12" fill="{color}"/>\n'
        lines = title.split('\n')
        for i, line in enumerate(lines):
            svg += f'  <text x="{x+112}" y="{y+22+i*16}" text-anchor="middle" font-size="13" font-weight="bold" fill="white">{line}</text>\n'

        # Sections
        sections = [("Complexity", time), ("Fibonacci Advantage", advantage), ("Key Insight", note)]
        for i, (label, content) in enumerate(sections):
            sy = y + 70 + i * 100
            svg += f'  <text x="{x+15}" y="{sy}" font-size="11" font-weight="bold" fill="{color}">{label}</text>\n'
            svg += f'  <rect x="{x+10}" y="{sy+5}" width="205" height="50" fill="{color}" opacity="0.08" rx="6"/>\n'
            for j, line in enumerate(content.split('\n')):
                svg += f'  <text x="{x+112}" y="{sy+25+j*16}" text-anchor="middle" class="label">{line}</text>\n'

    # Fibonacci anyon note
    svg += f'  <rect x="50" y="455" width="700" height="30" fill="#f5f0ff" rx="6" stroke="#9B59B6" stroke-width="1"/>\n'
    svg += f'  <text x="400" y="475" text-anchor="middle" font-size="12" fill="#9B59B6">🔗 Fibonacci anyons: fusion rules = Zeckendorf non-adjacency constraint → topological quantum computation link</text>\n'

    svg += svg_footer()
    return svg


# ─── Visual 12: Constraint Graph Comparison (Q5) ────────────────────────────

def generate_constraint_graph_visual():
    w, h = 800, 550
    svg = svg_header(w, h)
    svg += f'  <text x="400" y="35" text-anchor="middle" class="title">Q5: Constraint Graph Structure — Binary vs Fibonacci</text>\n'

    # Binary side
    svg += f'  <text x="200" y="65" text-anchor="middle" class="subtitle">Binary Factoring</text>\n'

    # Draw binary constraint graph (simplified)
    n_nodes = 6
    for i in range(n_nodes):
        x = 80 + i * 45
        # Factor p digits
        svg += f'  <circle cx="{x}" cy="110" r="12" fill="#4A90D9" stroke="#2C5F8A" stroke-width="1.5"/>\n'
        svg += f'  <text x="{x}" y="114" text-anchor="middle" font-size="9" fill="white">p{i}</text>\n'
        # Factor q digits
        svg += f'  <circle cx="{x}" cy="180" r="12" fill="#E8A838" stroke="#C08020" stroke-width="1.5"/>\n'
        svg += f'  <text x="{x}" y="184" text-anchor="middle" font-size="9" fill="white">q{i}</text>\n'

    # Product N digits
    for i in range(2 * n_nodes):
        x = 50 + i * 28
        svg += f'  <circle cx="{x}" cy="270" r="10" fill="#4CAF50" stroke="#2E7D32" stroke-width="1"/>\n'
        svg += f'  <text x="{x}" y="273" text-anchor="middle" font-size="7" fill="white">N{i}</text>\n'

    # Binary connections: each (pi, qj) → N_{i+j} only
    for i in range(min(3, n_nodes)):
        for j in range(min(3, n_nodes)):
            nk = i + j
            px = 80 + i * 45
            qx = 80 + j * 45
            nx = 50 + nk * 28
            svg += f'  <line x1="{px}" y1="122" x2="{nx}" y2="260" stroke="#4A90D9" stroke-width="0.5" opacity="0.3"/>\n'
            svg += f'  <line x1="{qx}" y1="192" x2="{nx}" y2="260" stroke="#E8A838" stroke-width="0.5" opacity="0.3"/>\n'

    # Carry chain (unidirectional)
    for i in range(2 * n_nodes - 1):
        x1 = 50 + i * 28
        x2 = 50 + (i + 1) * 28
        svg += f'  <line x1="{x1+10}" y1="270" x2="{x2-10}" y2="270" stroke="#2E7D32" stroke-width="1.5" marker-end="url(#arrow)"/>\n'

    svg += f'  <text x="200" y="310" text-anchor="middle" class="label-sm" fill="#2E7D32">→ Carries: unidirectional only</text>\n'
    svg += f'  <text x="200" y="325" text-anchor="middle" class="label-sm" fill="#666">Each (pᵢ,qⱼ) → 1 position of N</text>\n'

    # Fibonacci side
    svg += f'  <text x="600" y="65" text-anchor="middle" class="subtitle">Fibonacci Factoring</text>\n'

    # Draw Fibonacci constraint graph
    for i in range(n_nodes):
        x = 480 + i * 45
        svg += f'  <circle cx="{x}" cy="110" r="12" fill="#4A90D9" stroke="#2C5F8A" stroke-width="1.5"/>\n'
        svg += f'  <text x="{x}" y="114" text-anchor="middle" font-size="9" fill="white">p{i}</text>\n'
        svg += f'  <circle cx="{x}" cy="180" r="12" fill="#E8A838" stroke="#C08020" stroke-width="1.5"/>\n'
        svg += f'  <text x="{x}" y="184" text-anchor="middle" font-size="9" fill="white">q{i}</text>\n'

        # Non-adjacency constraint (red dashed lines between consecutive)
        if i < n_nodes - 1:
            svg += f'  <line x1="{x+12}" y1="110" x2="{x+33}" y2="110" stroke="#E74C3C" stroke-width="1.5" stroke-dasharray="4,3"/>\n'
            svg += f'  <line x1="{x+12}" y1="180" x2="{x+33}" y2="180" stroke="#E74C3C" stroke-width="1.5" stroke-dasharray="4,3"/>\n'

    for i in range(2 * n_nodes + 2):
        x = 440 + i * 22
        svg += f'  <circle cx="{x}" cy="270" r="8" fill="#4CAF50" stroke="#2E7D32" stroke-width="1"/>\n'
        svg += f'  <text x="{x}" y="273" text-anchor="middle" font-size="6" fill="white">{i}</text>\n'

    # Fibonacci connections: each (pi, qj) → multiple positions
    for i in range(min(2, n_nodes)):
        for j in range(min(2, n_nodes)):
            for delta in [-1, 0, 1, 2]:
                nk = i + j + delta
                if 0 <= nk < 2 * n_nodes + 2:
                    px = 480 + i * 45
                    qx = 480 + j * 45
                    nx = 440 + nk * 22
                    svg += f'  <line x1="{px}" y1="122" x2="{nx}" y2="262" stroke="#4A90D9" stroke-width="0.4" opacity="0.25"/>\n'
                    svg += f'  <line x1="{qx}" y1="192" x2="{nx}" y2="262" stroke="#E8A838" stroke-width="0.4" opacity="0.25"/>\n'

    # Bidirectional carry
    for i in range(2 * n_nodes + 1):
        x1 = 440 + i * 22
        x2 = 440 + (i + 1) * 22
        svg += f'  <line x1="{x1+8}" y1="268" x2="{x2-8}" y2="268" stroke="#2E7D32" stroke-width="1"/>\n'
        if i >= 2:
            x_back = 440 + (i - 2) * 22
            svg += f'  <line x1="{x1-2}" y1="275" x2="{x_back+10}" y2="275" stroke="#E74C3C" stroke-width="0.8" opacity="0.5"/>\n'

    svg += f'  <text x="600" y="310" text-anchor="middle" class="label-sm" fill="#2E7D32">→ Carries: bidirectional (+1, -2)</text>\n'
    svg += f'  <text x="600" y="325" text-anchor="middle" class="label-sm" fill="#666">Each (pᵢ,qⱼ) → multiple positions of N</text>\n'
    svg += f'  <text x="600" y="340" text-anchor="middle" class="label-sm" fill="#E74C3C">--- Non-adjacency constraints</text>\n'

    # Comparison table
    svg += f'  <rect x="50" y="360" width="700" height="160" fill="white" stroke="#ddd" rx="8"/>\n'
    svg += f'  <text x="400" y="385" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">Constraint Graph Comparison</text>\n'

    headers = ["Property", "Binary", "Fibonacci", "Advantage"]
    rows = [
        ["Carry direction", "Unidirectional ↑", "Bidirectional ↑↓", "Fib: richer coupling"],
        ["Product spread", "1 position", "Ω(min(i,j)) positions", "Fib: denser constraints"],
        ["Treewidth", "≈ k/2", "≈ 2k/3", "Binary: easier solving"],
        ["Propagation/decision", "1 bit", "3 bits (non-adjacency)", "Fib: 3× info/step"],
    ]

    for j, hdr in enumerate(headers):
        x = 100 + j * 175
        svg += f'  <text x="{x}" y="405" font-size="11" font-weight="bold" fill="#333">{hdr}</text>\n'
        svg += f'  <line x1="70" y1="410" x2="730" y2="410" stroke="#ddd"/>\n'

    for i, row in enumerate(rows):
        y = 425 + i * 22
        for j, cell in enumerate(row):
            x = 100 + j * 175
            color = "#4CAF50" if j == 3 else "#333"
            svg += f'  <text x="{x}" y="{y}" font-size="10" fill="{color}">{cell}</text>\n'

    svg += svg_footer()
    return svg


# ─── Visual 13: Technology Application Map ──────────────────────────────────

def generate_application_map():
    w, h = 900, 600
    svg = svg_header(w, h)
    svg += f'  <text x="450" y="35" text-anchor="middle" class="title">Fibonacci-Base Technology: Application Landscape</text>\n'

    # Central node
    cx, cy = 450, 300
    svg += f'  <circle cx="{cx}" cy="{cy}" r="55" fill="url(#goldGrad)" stroke="#B8860B" stroke-width="2"/>\n'
    svg += f'  <text x="{cx}" y="{cy-8}" text-anchor="middle" font-size="11" font-weight="bold" fill="#333">Fibonacci</text>\n'
    svg += f'  <text x="{cx}" y="{cy+8}" text-anchor="middle" font-size="11" font-weight="bold" fill="#333">Base</text>\n'
    svg += f'  <text x="{cx}" y="{cy+22}" text-anchor="middle" font-size="9" fill="#666">Core Technology</text>\n'

    # Application domains
    domains = [
        (150, 120, "#E74C3C", "Cryptography", ["Hash functions", "Proof of work", "Post-quantum"]),
        (450, 80, "#4A90D9", "Factoring", ["QS filter", "NFS hybrid", "ECM params"]),
        (750, 120, "#4CAF50", "Error Correction", ["RLL codes", "LDPC codes", "DNA storage"]),
        (820, 320, "#9B59B6", "Quantum", ["Fibonacci anyons", "Adiabatic QC", "Error correction"]),
        (750, 480, "#FF6B6B", "Hardware", ["Fibonacci ALU", "Low-power bus", "CAM optimization"]),
        (450, 530, "#00BCD4", "Machine Learning", ["Sparse networks", "φ-rate schedules", "Positional encoding"]),
        (150, 480, "#FF9800", "Signal Processing", ["Fibonacci wavelet", "Arithmetic coding", "Compression"]),
        (80, 320, "#795548", "Number Theory", ["Primality certs", "Diophantine eqs", "CF factoring"]),
    ]

    for dx, dy, color, name, apps in domains:
        # Connection line to center
        svg += f'  <line x1="{cx}" y1="{cy}" x2="{dx}" y2="{dy}" stroke="{color}" stroke-width="2" opacity="0.4"/>\n'

        # Domain circle
        svg += f'  <circle cx="{dx}" cy="{dy}" r="38" fill="{color}" opacity="0.15" stroke="{color}" stroke-width="2"/>\n'
        svg += f'  <text x="{dx}" y="{dy-5}" text-anchor="middle" font-size="10" font-weight="bold" fill="{color}">{name}</text>\n'

        # App labels
        for i, app in enumerate(apps):
            # Place app labels around the circle
            angle = -60 + i * 60
            ax = dx + 55 * math.cos(math.radians(angle))
            ay = dy + 55 * math.sin(math.radians(angle))
            svg += f'  <text x="{ax}" y="{ay}" text-anchor="middle" font-size="8" fill="#666">{app}</text>\n'

    # Core properties at center
    props = [
        (cx - 80, cy - 70, "Bidirectional carries"),
        (cx + 80, cy - 70, "Non-adjacency"),
        (cx, cy + 75, "Product spread"),
    ]
    for px, py, label in props:
        svg += f'  <text x="{px}" y="{py}" text-anchor="middle" font-size="9" font-weight="bold" fill="#B8860B">{label}</text>\n'

    svg += svg_footer()
    return svg


# ─── Generate all ────────────────────────────────────────────────────────────

if __name__ == '__main__':
    visuals = [
        ("08_search_space_reduction.svg", generate_search_space_visual),
        ("09_hybrid_strategies.svg", generate_hybrid_visual),
        ("10_base_comparison.svg", generate_base_comparison_visual),
        ("11_quantum_landscape.svg", generate_quantum_visual),
        ("12_constraint_graph_comparison.svg", generate_constraint_graph_visual),
        ("13_application_map.svg", generate_application_map),
    ]

    import os
    os.makedirs("visuals", exist_ok=True)

    for filename, generator in visuals:
        svg_content = generator()
        filepath = os.path.join("visuals", filename)
        with open(filepath, 'w') as f:
            f.write(svg_content)
        print(f"Generated {filename}")

    print(f"\nAll research question SVGs generated in visuals/")
