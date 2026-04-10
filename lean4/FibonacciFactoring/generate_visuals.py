#!/usr/bin/env python3
"""
generate_visuals.py — Generate SVG diagrams illustrating Fibonacci-base factoring.
"""

from fibonacci_base import *
import os

OUT_DIR = os.path.join(os.path.dirname(__file__), "visuals")
os.makedirs(OUT_DIR, exist_ok=True)


def svg_header(width, height, title=""):
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
  <defs>
    <style>
      .title {{ font: bold 22px 'Helvetica Neue', Arial, sans-serif; fill: #1a1a2e; }}
      .subtitle {{ font: 16px 'Helvetica Neue', Arial, sans-serif; fill: #4a4a6a; }}
      .label {{ font: 13px 'Courier New', monospace; fill: #2d2d2d; }}
      .label-sm {{ font: 11px 'Courier New', monospace; fill: #555; }}
      .bit-1 {{ fill: #e63946; stroke: #c1121f; stroke-width: 1.5; }}
      .bit-0 {{ fill: #f1faee; stroke: #a8dadc; stroke-width: 1.5; }}
      .bit-text {{ font: bold 16px 'Courier New', monospace; fill: white; text-anchor: middle; dominant-baseline: central; }}
      .bit-text-dark {{ font: bold 16px 'Courier New', monospace; fill: #333; text-anchor: middle; dominant-baseline: central; }}
      .carry-up {{ stroke: #2a9d8f; stroke-width: 2; fill: none; marker-end: url(#arrowGreen); }}
      .carry-down {{ stroke: #e76f51; stroke-width: 2; fill: none; marker-end: url(#arrowOrange); stroke-dasharray: 6,3; }}
      .partial {{ fill: #457b9d; stroke: #1d3557; stroke-width: 1; }}
      .partial-text {{ font: bold 14px 'Courier New', monospace; fill: white; text-anchor: middle; dominant-baseline: central; }}
      .accent {{ fill: #f4a261; stroke: #e76f51; stroke-width: 1.5; }}
      .fib-box {{ fill: #264653; stroke: #2a9d8f; stroke-width: 1.5; rx: 4; }}
      .fib-text {{ font: bold 12px 'Helvetica Neue', Arial, sans-serif; fill: white; text-anchor: middle; dominant-baseline: central; }}
      .connector {{ stroke: #ccc; stroke-width: 1; fill: none; }}
      .bracket {{ font: 14px 'Helvetica Neue', Arial, sans-serif; fill: #666; }}
    </style>
    <marker id="arrowGreen" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#2a9d8f" />
    </marker>
    <marker id="arrowOrange" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#e76f51" />
    </marker>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#fefefe;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#f0f4f8;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="{width}" height="{height}" fill="url(#bgGrad)" rx="8"/>
'''


def draw_zeckendorf_row(bits_msb, x, y, cell_size=32, label="", highlight_positions=None):
    """Draw a row of Zeckendorf digits (MSB-first string or list)."""
    if isinstance(bits_msb, str):
        bits_msb = list(bits_msb)
    svg = ""
    if label:
        svg += f'  <text x="{x - 10}" y="{y + cell_size//2}" class="label" text-anchor="end">{label}</text>\n'
    for i, b in enumerate(bits_msb):
        bx = x + i * cell_size
        cls = "bit-1" if str(b) == "1" else "bit-0"
        tcls = "bit-text" if str(b) == "1" else "bit-text-dark"
        if highlight_positions and i in highlight_positions:
            cls = "accent"
            tcls = "bit-text"
        svg += f'  <rect x="{bx}" y="{y}" width="{cell_size-2}" height="{cell_size-2}" class="{cls}" rx="4"/>\n'
        svg += f'  <text x="{bx + cell_size//2 - 1}" y="{y + cell_size//2 - 1}" class="{tcls}">{b}</text>\n'
    return svg


# ─── Visual 1: Zeckendorf Representation Overview ───────────────────────────

def visual_zeckendorf_overview():
    W, H = 900, 620
    svg = svg_header(W, H)
    svg += '  <text x="450" y="38" class="title" text-anchor="middle">Zeckendorf (Fibonacci Base) Representation</text>\n'
    svg += '  <text x="450" y="62" class="subtitle" text-anchor="middle">Every positive integer = unique sum of non-consecutive Fibonacci numbers</text>\n'

    fibs = fibonacci_list(200)
    # Show Fibonacci sequence
    y = 90
    svg += f'  <text x="50" y="{y}" class="label">Fibonacci numbers:</text>\n'
    for i in range(12):
        bx = 220 + i * 52
        svg += f'  <rect x="{bx}" y="{y-18}" width="48" height="28" class="fib-box"/>\n'
        svg += f'  <text x="{bx+24}" y="{y-4}" class="fib-text">F({i+2})={fibs[i]}</text>\n'

    # Show examples
    examples = [7, 11, 13, 42, 77, 143, 100]
    y = 150
    svg += f'  <text x="50" y="{y}" class="label">Examples (MSB → LSB):</text>\n'

    for idx, n in enumerate(examples):
        yy = y + 20 + idx * 52
        z_str = zeckendorf_str(n)
        z_bits = to_zeckendorf(n)
        num_digits = len(z_bits)

        svg += f'  <text x="50" y="{yy+16}" class="label">{n:4d} =</text>\n'

        # Draw digit boxes, MSB first
        for i, ch in enumerate(z_str):
            bx = 120 + i * 36
            cls = "bit-1" if ch == "1" else "bit-0"
            tcls = "bit-text" if ch == "1" else "bit-text-dark"
            svg += f'  <rect x="{bx}" y="{yy}" width="34" height="30" class="{cls}" rx="4"/>\n'
            svg += f'  <text x="{bx+17}" y="{yy+15}" class="{tcls}">{ch}</text>\n'

        # Show as sum
        terms = [str(fibs[i]) for i, b in enumerate(z_bits) if b]
        sum_str = " + ".join(reversed(terms))
        svg += f'  <text x="{120 + len(z_str)*36 + 15}" y="{yy+16}" class="label-sm">= {sum_str}</text>\n'

    # Footer: non-adjacency rule
    y = 530
    svg += f'  <rect x="40" y="{y}" width="820" height="60" fill="#264653" rx="6" opacity="0.9"/>\n'
    svg += f'  <text x="450" y="{y+22}" class="fib-text" font-size="14" text-anchor="middle">KEY RULE: No two consecutive digits may both be 1</text>\n'
    svg += f'  <text x="450" y="{y+44}" class="fib-text" font-size="12" text-anchor="middle" opacity="0.8">This constraint (Zeckendorf\'s theorem) ensures uniqueness — and provides structural information for factoring</text>\n'

    svg += "</svg>"
    with open(os.path.join(OUT_DIR, "01_zeckendorf_overview.svg"), "w") as f:
        f.write(svg)
    print("Generated 01_zeckendorf_overview.svg")


# ─── Visual 2: Binary vs Fibonacci Multiplication ───────────────────────────

def visual_binary_vs_fibonacci():
    W, H = 1000, 750
    svg = svg_header(W, H)
    svg += '  <text x="500" y="38" class="title" text-anchor="middle">Binary vs. Fibonacci Multiplication</text>\n'

    p, q = 11, 13
    N = p * q  # 143

    # LEFT SIDE: Binary
    svg += '  <text x="250" y="72" class="subtitle" text-anchor="middle">Binary (base 2)</text>\n'
    svg += '  <rect x="30" y="80" width="440" height="620" fill="none" stroke="#ddd" stroke-width="1" rx="6"/>\n'

    pb = bin(p)[2:]
    qb = bin(q)[2:]
    nb = bin(N)[2:]

    y = 110
    svg += draw_zeckendorf_row(pb.rjust(8, '·'), 80, y, 36, f"p={p}")
    y += 45
    svg += draw_zeckendorf_row(qb.rjust(8, '·'), 80, y, 36, f"q={q}")
    svg += f'  <line x1="80" y1="{y+35}" x2="{80+8*36}" y2="{y+35}" stroke="#333" stroke-width="2"/>\n'
    svg += f'  <text x="{80+8*36+10}" y="{y+10}" class="label">×</text>\n'

    # Partial products (binary)
    y += 50
    svg += f'  <text x="50" y="{y}" class="label-sm">Partial products:</text>\n'
    y += 10
    for j, bit in enumerate(reversed(qb)):
        if bit == '1':
            shifted = pb + '0' * j
            shifted = shifted.rjust(12, '·')
            svg += draw_zeckendorf_row(shifted, 80, y, 36, f"bit {j}")
            y += 38

    svg += f'  <line x1="80" y1="{y+5}" x2="{80+12*36}" y2="{y+5}" stroke="#333" stroke-width="2"/>\n'
    y += 20
    svg += draw_zeckendorf_row(nb.rjust(12, '·'), 80, y, 36, f"N={N}")

    y += 55
    svg += f'  <text x="250" y="{y}" class="label-sm" text-anchor="middle">Carries: UNIDIRECTIONAL (↑ only)</text>\n'
    y += 22
    svg += f'  <text x="250" y="{y}" class="label-sm" text-anchor="middle">Each partial product: SINGLE SHIFT</text>\n'

    # RIGHT SIDE: Fibonacci
    svg += '  <text x="740" y="72" class="subtitle" text-anchor="middle">Fibonacci (Zeckendorf)</text>\n'
    svg += '  <rect x="530" y="80" width="440" height="620" fill="none" stroke="#ddd" stroke-width="1" rx="6"/>\n'

    pf = zeckendorf_str(p)
    qf = zeckendorf_str(q)
    nf = zeckendorf_str(N)
    info = analyze_carry_structure(p, q)

    y = 110
    svg += draw_zeckendorf_row(pf.rjust(12, '·'), 570, y, 32, f"p={p}")
    y += 42
    svg += draw_zeckendorf_row(qf.rjust(12, '·'), 570, y, 32, f"q={q}")
    svg += f'  <line x1="570" y1="{y+33}" x2="{570+12*32}" y2="{y+33}" stroke="#333" stroke-width="2"/>\n'
    svg += f'  <text x="{570+12*32+10}" y="{y+10}" class="label">×</text>\n'

    y += 48
    svg += f'  <text x="550" y="{y}" class="label-sm">Partial products (spread!):</text>\n'
    y += 10
    for j, pb_bits in info['partials']:
        fibs = fibonacci_list(q + 10)
        fval = fibs[j]
        pstr = ''.join(str(b) for b in reversed(pb_bits)).rjust(12, '·')
        svg += draw_zeckendorf_row(pstr, 570, y, 32, f"×F({j+2})={fval}")
        y += 36

    # Pre-normalization
    y += 10
    svg += f'  <text x="550" y="{y}" class="label-sm">Column sums (before normalization):</text>\n'
    y += 10
    pre = info['pre_normalization']
    pre_str = ''.join(str(x) for x in reversed(pre)).rjust(12, '·')
    svg += draw_zeckendorf_row(pre_str, 570, y, 32, "Σ")

    svg += f'  <line x1="570" y1="{y+33}" x2="{570+12*32}" y2="{y+33}" stroke="#333" stroke-width="2"/>\n'
    y += 48
    svg += draw_zeckendorf_row(nf.rjust(12, '·'), 570, y, 32, f"N={N}")

    y += 55
    svg += f'  <text x="740" y="{y}" class="label-sm" text-anchor="middle">Carries: BIDIRECTIONAL (↑ and ↓)</text>\n'
    y += 22
    svg += f'  <text x="740" y="{y}" class="label-sm" text-anchor="middle">Each partial product: MULTI-POSITION SPREAD</text>\n'

    svg += "</svg>"
    with open(os.path.join(OUT_DIR, "02_binary_vs_fibonacci.svg"), "w") as f:
        f.write(svg)
    print("Generated 02_binary_vs_fibonacci.svg")


# ─── Visual 3: Carry Propagation Diagram ────────────────────────────────────

def visual_carry_propagation():
    W, H = 900, 500
    svg = svg_header(W, H)
    svg += '  <text x="450" y="38" class="title" text-anchor="middle">Fibonacci Carry Propagation: Bidirectional Flow</text>\n'
    svg += '  <text x="450" y="62" class="subtitle" text-anchor="middle">2·F(n) = F(n+1) + F(n-2) — carries go UP and DOWN</text>\n'

    # Draw digit positions
    num_pos = 12
    cx_start = 100
    cell_w = 60
    cy = 200

    fibs = fibonacci_list(1000)

    for i in range(num_pos):
        x = cx_start + i * cell_w
        svg += f'  <rect x="{x}" y="{cy}" width="{cell_w-4}" height="40" class="fib-box" rx="4"/>\n'
        svg += f'  <text x="{x + cell_w//2 - 2}" y="{cy+15}" class="fib-text">pos {num_pos-1-i}</text>\n'
        svg += f'  <text x="{x + cell_w//2 - 2}" y="{cy+32}" class="fib-text" font-size="10">F({num_pos-1-i+2})={fibs[num_pos-1-i]}</text>\n'

    # Show carry from position 6 (in the middle)
    src = 6
    src_x = cx_start + (num_pos - 1 - src) * cell_w + cell_w // 2

    # Upward carry to src+1
    dst_up = src + 1
    dst_up_x = cx_start + (num_pos - 1 - dst_up) * cell_w + cell_w // 2
    svg += f'  <path d="M {src_x},{cy} Q {(src_x+dst_up_x)//2},{cy-60} {dst_up_x},{cy}" class="carry-up"/>\n'
    svg += f'  <text x="{(src_x+dst_up_x)//2}" y="{cy-65}" class="label-sm" fill="#2a9d8f" text-anchor="middle">+1 (upward carry)</text>\n'

    # Downward carry to src-2
    dst_down = src - 2
    dst_down_x = cx_start + (num_pos - 1 - dst_down) * cell_w + cell_w // 2
    svg += f'  <path d="M {src_x},{cy+40} Q {(src_x+dst_down_x)//2},{cy+120} {dst_down_x},{cy+40}" class="carry-down"/>\n'
    svg += f'  <text x="{(src_x+dst_down_x)//2}" y="{cy+135}" class="label-sm" fill="#e76f51" text-anchor="middle">+1 (DOWNWARD carry!)</text>\n'

    # Highlight source
    svg += f'  <rect x="{cx_start + (num_pos-1-src)*cell_w}" y="{cy}" width="{cell_w-4}" height="40" fill="#e63946" stroke="#c1121f" stroke-width="2" rx="4" opacity="0.7"/>\n'
    svg += f'  <text x="{src_x-2}" y="{cy-10}" class="label" fill="#e63946" text-anchor="middle">≥ 2 here</text>\n'

    # Comparison box at bottom
    y = 350
    svg += f'  <rect x="60" y="{y}" width="370" height="110" fill="#f1faee" stroke="#a8dadc" stroke-width="2" rx="6"/>\n'
    svg += f'  <text x="245" y="{y+25}" class="label" text-anchor="middle" font-size="14" fill="#1d3557">Binary Carry (base 2)</text>\n'
    svg += f'  <text x="245" y="{y+50}" class="label-sm" text-anchor="middle">2·(2^n) = 2^(n+1)</text>\n'
    svg += f'  <text x="245" y="{y+70}" class="label-sm" text-anchor="middle">Direction: ↑ only (unidirectional)</text>\n'
    svg += f'  <text x="245" y="{y+90}" class="label-sm" text-anchor="middle">Range: 1 position forward</text>\n'

    svg += f'  <rect x="470" y="{y}" width="370" height="110" fill="#264653" stroke="#2a9d8f" stroke-width="2" rx="6"/>\n'
    svg += f'  <text x="655" y="{y+25}" class="fib-text" font-size="14">Fibonacci Carry (Zeckendorf)</text>\n'
    svg += f'  <text x="655" y="{y+50}" class="fib-text" font-size="11">2·F(n) = F(n+1) + F(n-2)</text>\n'
    svg += f'  <text x="655" y="{y+70}" class="fib-text" font-size="11">Direction: ↑ AND ↓ (bidirectional!)</text>\n'
    svg += f'  <text x="655" y="{y+90}" class="fib-text" font-size="11">Range: +1 forward, -2 backward</text>\n'

    svg += "</svg>"
    with open(os.path.join(OUT_DIR, "03_carry_propagation.svg"), "w") as f:
        f.write(svg)
    print("Generated 03_carry_propagation.svg")


# ─── Visual 4: Product Spread Heatmap ───────────────────────────────────────

def visual_product_spread():
    W, H = 850, 850
    svg = svg_header(W, H)
    svg += '  <text x="425" y="38" class="title" text-anchor="middle">F(i)·F(j) Product Digit Spread</text>\n'
    svg += '  <text x="425" y="60" class="subtitle" text-anchor="middle">Number of set bits in Zeckendorf representation of each product</text>\n'

    fibs = fibonacci_list(10000)
    n = 10
    cell = 65
    ox, oy = 120, 100

    # Column/row headers
    for i in range(n):
        svg += f'  <text x="{ox + i*cell + cell//2}" y="{oy - 10}" class="label-sm" text-anchor="middle">F({i+2})={fibs[i]}</text>\n'
        svg += f'  <text x="{ox - 10}" y="{oy + i*cell + cell//2}" class="label-sm" text-anchor="end">F({i+2})={fibs[i]}</text>\n'

    # Cells
    colors = {1: "#a8dadc", 2: "#457b9d", 3: "#1d3557", 4: "#e63946", 5: "#9d0208"}
    for i in range(n):
        for j in range(n):
            prod = fibs[i] * fibs[j]
            z = to_zeckendorf(prod)
            num_set = sum(z)
            color = colors.get(num_set, "#6d0a18")
            x = ox + j * cell
            y = oy + i * cell

            svg += f'  <rect x="{x+1}" y="{y+1}" width="{cell-2}" height="{cell-2}" fill="{color}" rx="4" opacity="0.85"/>\n'
            svg += f'  <text x="{x+cell//2}" y="{y+cell//2-6}" class="fib-text" font-size="14">{prod}</text>\n'
            svg += f'  <text x="{x+cell//2}" y="{y+cell//2+10}" class="fib-text" font-size="10">{num_set} bits</text>\n'

    # Legend
    ly = oy + n * cell + 30
    svg += f'  <text x="120" y="{ly}" class="label">Set bits in product:</text>\n'
    for num, color in sorted(colors.items()):
        lx = 300 + (num - 1) * 90
        svg += f'  <rect x="{lx}" y="{ly-14}" width="20" height="20" fill="{color}" rx="3"/>\n'
        svg += f'  <text x="{lx+26}" y="{ly+2}" class="label-sm">{num} bit{"s" if num>1 else ""}</text>\n'

    svg += "</svg>"
    with open(os.path.join(OUT_DIR, "04_product_spread.svg"), "w") as f:
        f.write(svg)
    print("Generated 04_product_spread.svg")


# ─── Visual 5: Semiprime Factoring Example ──────────────────────────────────

def visual_factoring_example():
    W, H = 950, 680
    svg = svg_header(W, H)

    p, q = 17, 19
    N = p * q  # 323
    svg += f'  <text x="475" y="38" class="title" text-anchor="middle">Fibonacci-Base Factoring: {p} × {q} = {N}</text>\n'

    pf = zeckendorf_str(p)
    qf = zeckendorf_str(q)
    nf = zeckendorf_str(N)
    info = analyze_carry_structure(p, q)

    max_width = max(len(nf), 14)
    cell = 34

    # Factor representations
    y = 80
    svg += f'  <text x="50" y="{y}" class="subtitle">Factor representations:</text>\n'
    y += 30
    svg += draw_zeckendorf_row(pf.rjust(max_width, ' '), 160, y, cell, f"p = {p}")
    y += 42
    svg += draw_zeckendorf_row(qf.rjust(max_width, ' '), 160, y, cell, f"q = {q}")

    # Partial products
    y += 55
    svg += f'  <text x="50" y="{y}" class="subtitle">Partial products (p × each Fibonacci component of q):</text>\n'
    y += 25

    for j, pb_bits in info['partials']:
        fibs = fibonacci_list(q + 10)
        fval = fibs[j]
        pstr = ''.join(str(b) for b in reversed(pb_bits)).rjust(max_width, ' ')
        svg += draw_zeckendorf_row(pstr, 160, y, cell, f"p×F({j+2})={fval}")
        y += 38

    # Pre-normalization
    y += 15
    svg += f'  <line x1="160" y1="{y}" x2="{160+max_width*cell}" y2="{y}" stroke="#333" stroke-width="2"/>\n'
    svg += f'  <text x="{160+max_width*cell+10}" y="{y+5}" class="label">+</text>\n'
    y += 15
    pre = info['pre_normalization']
    pre_str = ''.join(str(x) for x in reversed(pre)).rjust(max_width, ' ')
    # Color cells with value > 1 differently
    svg += f'  <text x="80" y="{y+16}" class="label" text-anchor="end">Column sums</text>\n'
    for i, ch in enumerate(pre_str):
        bx = 160 + i * cell
        if ch.strip() and int(ch) > 1:
            svg += f'  <rect x="{bx}" y="{y}" width="{cell-2}" height="{cell-2}" class="accent" rx="4"/>\n'
            svg += f'  <text x="{bx+cell//2-1}" y="{y+cell//2-1}" class="bit-text">{ch}</text>\n'
        elif ch.strip() and int(ch) == 1:
            svg += f'  <rect x="{bx}" y="{y}" width="{cell-2}" height="{cell-2}" class="bit-1" rx="4"/>\n'
            svg += f'  <text x="{bx+cell//2-1}" y="{y+cell//2-1}" class="bit-text">{ch}</text>\n'
        elif ch.strip():
            svg += f'  <rect x="{bx}" y="{y}" width="{cell-2}" height="{cell-2}" class="bit-0" rx="4"/>\n'
            svg += f'  <text x="{bx+cell//2-1}" y="{y+cell//2-1}" class="bit-text-dark">{ch}</text>\n'

    # Normalization arrow
    y += 50
    svg += f'  <text x="350" y="{y}" class="label" fill="#e76f51">↓ Normalize (bidirectional carries) ↓</text>\n'

    # Final result
    y += 25
    svg += draw_zeckendorf_row(nf.rjust(max_width, ' '), 160, y, cell, f"N = {N}")

    # Annotation box
    y += 60
    svg += f'  <rect x="50" y="{y}" width="850" height="80" fill="#264653" rx="6" opacity="0.92"/>\n'
    svg += f'  <text x="475" y="{y+20}" class="fib-text" font-size="13" text-anchor="middle">INSIGHT: Column values ≥ 2 (shown in orange) trigger bidirectional carry propagation.</text>\n'
    svg += f'  <text x="475" y="{y+42}" class="fib-text" font-size="13" text-anchor="middle">Each carry sends +1 upward to position i+1 AND +1 downward to position i−2.</text>\n'
    svg += f'  <text x="475" y="{y+64}" class="fib-text" font-size="13" text-anchor="middle">This creates non-local constraints that couple distant digit positions of the factors.</text>\n'

    svg += "</svg>"
    with open(os.path.join(OUT_DIR, "05_factoring_example.svg"), "w") as f:
        f.write(svg)
    print("Generated 05_factoring_example.svg")


# ─── Visual 6: Constraint Entanglement Web ──────────────────────────────────

def visual_constraint_web():
    W, H = 900, 550
    svg = svg_header(W, H)
    svg += '  <text x="450" y="38" class="title" text-anchor="middle">Fibonacci Carry: Constraint Entanglement Web</text>\n'
    svg += '  <text x="450" y="60" class="subtitle" text-anchor="middle">How a single carry cascades through digit positions</text>\n'

    num_pos = 14
    cx_start = 60
    cell_w = 55
    cy = 140

    fibs = fibonacci_list(1000)

    # Draw positions
    for i in range(num_pos):
        x = cx_start + i * cell_w
        idx = num_pos - 1 - i
        svg += f'  <rect x="{x}" y="{cy}" width="{cell_w-3}" height="36" class="fib-box" rx="3"/>\n'
        svg += f'  <text x="{x+cell_w//2-1}" y="{cy+22}" class="fib-text" font-size="10">{idx}</text>\n'

    # Simulate carry cascade starting from position 8
    # Step 1: pos 8 overflows → +1 to 9, +1 to 6
    # Step 2: if 6 overflows → +1 to 7, +1 to 4
    # Step 3: if 4 overflows → +1 to 5, +1 to 2
    # Step 4: if 9 causes adjacency with 10 → +1 to 10
    cascades = [
        (8, 9, 6, "#e63946", "Step 1", 180),
        (6, 7, 4, "#f4a261", "Step 2", 260),
        (4, 5, 2, "#2a9d8f", "Step 3", 340),
    ]

    for src, up, down, color, label, label_y in cascades:
        src_x = cx_start + (num_pos - 1 - src) * cell_w + cell_w // 2
        up_x = cx_start + (num_pos - 1 - up) * cell_w + cell_w // 2
        down_x = cx_start + (num_pos - 1 - down) * cell_w + cell_w // 2

        # Upward
        mid_y = cy - (label_y - 140) // 2 - 10
        svg += f'  <path d="M {src_x},{cy} Q {(src_x+up_x)//2},{mid_y} {up_x},{cy}" stroke="{color}" stroke-width="2.5" fill="none" marker-end="url(#arrowGreen)"/>\n'
        # Downward
        mid_y2 = cy + 36 + (label_y - 140) // 2 + 10
        svg += f'  <path d="M {src_x},{cy+36} Q {(src_x+down_x)//2},{mid_y2} {down_x},{cy+36}" stroke="{color}" stroke-width="2.5" fill="none" stroke-dasharray="5,3" marker-end="url(#arrowOrange)"/>\n'

        # Highlight source
        svg += f'  <rect x="{cx_start + (num_pos-1-src)*cell_w}" y="{cy}" width="{cell_w-3}" height="36" fill="{color}" rx="3" opacity="0.3"/>\n'

        svg += f'  <text x="30" y="{label_y}" class="label-sm" fill="{color}">{label}: pos {src} → ↑{up}, ↓{down}</text>\n'

    # Summary
    y = 420
    svg += f'  <rect x="80" y="{y}" width="740" height="90" fill="#f1faee" stroke="#a8dadc" stroke-width="2" rx="6"/>\n'
    svg += f'  <text x="450" y="{y+25}" class="label" text-anchor="middle" fill="#1d3557">A single overflow at position 8 cascades to positions 9, 7, 6, 5, 4, 2</text>\n'
    svg += f'  <text x="450" y="{y+48}" class="label" text-anchor="middle" fill="#1d3557">touching 6 of 14 digit positions — creating a WEB of constraints</text>\n'
    svg += f'  <text x="450" y="{y+72}" class="label-sm" text-anchor="middle" fill="#666">In binary, the same overflow would affect only 1-2 adjacent positions</text>\n'

    svg += "</svg>"
    with open(os.path.join(OUT_DIR, "06_constraint_web.svg"), "w") as f:
        f.write(svg)
    print("Generated 06_constraint_web.svg")


# ─── Visual 7: Modular Periodicity (Pisano) ─────────────────────────────────

def visual_pisano():
    W, H = 900, 520
    svg = svg_header(W, H)
    svg += '  <text x="450" y="38" class="title" text-anchor="middle">Pisano Periodicity of Fibonacci Numbers</text>\n'
    svg += '  <text x="450" y="60" class="subtitle" text-anchor="middle">F(n) mod m is periodic — providing modular constraints on factor digits</text>\n'

    fibs = fibonacci_list(10000)
    mods = [2, 3, 5, 7]
    periods = {2: 3, 3: 8, 5: 5, 7: 16}  # Pisano periods

    cell = 36
    ox = 100
    oy = 95

    for mi, m in enumerate(mods):
        y = oy + mi * 100
        svg += f'  <text x="30" y="{y+cell//2}" class="label" dominant-baseline="central">mod {m}:</text>\n'
        svg += f'  <text x="30" y="{y+cell//2+18}" class="label-sm" dominant-baseline="central">(π={periods[m]})</text>\n'

        period = periods[m]
        num_show = min(20, period * 2)

        for i in range(num_show):
            x = ox + i * cell
            val = fibs[i] % m
            # Color by value
            if val == 0:
                color = "#e63946"
            elif val == 1:
                color = "#457b9d"
            else:
                colors_mod = ["#2a9d8f", "#f4a261", "#e76f51", "#264653", "#a8dadc"]
                color = colors_mod[(val - 2) % len(colors_mod)]

            svg += f'  <rect x="{x}" y="{y}" width="{cell-2}" height="{cell-2}" fill="{color}" rx="3" opacity="0.85"/>\n'
            svg += f'  <text x="{x+cell//2-1}" y="{y+cell//2-1}" class="fib-text" font-size="13">{val}</text>\n'

            # Period separator
            if (i + 1) % period == 0 and i + 1 < num_show:
                svg += f'  <line x1="{x+cell-1}" y1="{y-3}" x2="{x+cell-1}" y2="{y+cell+1}" stroke="#333" stroke-width="2" stroke-dasharray="3,2"/>\n'

    # Column headers
    for i in range(20):
        svg += f'  <text x="{ox + i*cell + cell//2 - 1}" y="{oy-8}" class="label-sm" text-anchor="middle">{i}</text>\n'

    y = oy + 4 * 100 + 20
    svg += f'  <rect x="40" y="{y}" width="820" height="55" fill="#264653" rx="6" opacity="0.92"/>\n'
    svg += f'  <text x="450" y="{y+20}" class="fib-text" font-size="12" text-anchor="middle">FACTORING APPLICATION: If N ≡ r (mod m), then the Fibonacci digit positions of p and q</text>\n'
    svg += f'  <text x="450" y="{y+40}" class="fib-text" font-size="12" text-anchor="middle">must combine (through the carry structure) to produce residue r. Pisano periodicity constrains which positions are compatible.</text>\n'

    svg += "</svg>"
    with open(os.path.join(OUT_DIR, "07_pisano_periodicity.svg"), "w") as f:
        f.write(svg)
    print("Generated 07_pisano_periodicity.svg")


if __name__ == "__main__":
    visual_zeckendorf_overview()
    visual_binary_vs_fibonacci()
    visual_carry_propagation()
    visual_product_spread()
    visual_factoring_example()
    visual_constraint_web()
    visual_pisano()
    print(f"\nAll SVGs generated in {OUT_DIR}/")
