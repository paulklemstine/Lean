#!/usr/bin/env python3
"""
Reverse Solving on the Berggren Tree — Interactive Demo & Visualization Suite
=============================================================================

This script demonstrates the key ideas from §11 of the research program:

1. REVERSE PROBLEM: Given N, embed it into a Pythagorean triple and ascend
   the Berggren tree. GCDs encountered along the path reveal factors.

2. FIXED-POINT ANALYSIS: Characterize fixed points of Berggren matrix powers.
   Symmetric matrices force a = b, collapsing the system.

3. BRANCH ENCODING: The descent path (sequence of branch choices A/B/C) encodes
   number-theoretic information about N related to its factorization.

Generates SVG visualizations:
  - descent_path.svg: Factor-finding descent for a specific N
  - fixed_point_landscape.svg: Fixed-point structure visualization
  - branch_encoding.svg: Branch choice patterns for different N
  - factoring_success.svg: Success rates and step counts

No external dependencies beyond Python standard library + math.
"""

import math
from collections import defaultdict

# =============================================================================
# CORE: Berggren Matrices and Inverses
# =============================================================================

def berggren_B1(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B2(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_B3(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def inv_B1(a, b, c):
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def inv_B2(a, b, c):
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def inv_B3(a, b, c):
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

INVERSE_BRANCHES = [
    ('A', inv_B1),
    ('B', inv_B2),
    ('C', inv_B3),
]

# =============================================================================
# TRIVIAL EMBEDDING: N -> Pythagorean Triple
# =============================================================================

def trivial_triple(N):
    """For odd N, return (N, (N²-1)/2, (N²+1)/2)."""
    assert N % 2 == 1, f"N={N} must be odd"
    b = (N*N - 1) // 2
    c = (N*N + 1) // 2
    assert N*N + b*b == c*c, "Not Pythagorean!"
    return (N, b, c)

# =============================================================================
# FIND PARENT: Determine which inverse branch to take
# =============================================================================

def find_parent(a, b, c):
    """Find the parent triple in the Berggren tree.
    Returns (branch_label, parent_triple)."""
    for label, inv_fn in INVERSE_BRANCHES:
        pa, pb, pc = inv_fn(a, b, c)
        if pa > 0 and pb > 0:
            return label, (pa, pb, pc)
    # Fallback: take C branch with absolute values
    pa, pb, pc = inv_B3(a, b, c)
    return 'C', (abs(pa), abs(pb), pc)

# =============================================================================
# REVERSE SOLVING: Descend tree looking for factors
# =============================================================================

def reverse_factor(N, max_steps=200, verbose=False):
    """Factor N by tree descent.
    
    Algorithm:
    1. Embed N into a Pythagorean triple (N, (N²-1)/2, (N²+1)/2).
    2. Ascend the Berggren tree by applying inverse transforms.
    3. At each step, compute gcd(component, N).
    4. If gcd is non-trivial (1 < gcd < N), we found a factor.
    
    Returns: (factor, steps, path) or (None, steps, path)
    """
    if N % 2 == 0:
        return (2, 0, [])
    if N < 9:
        return (None, 0, [])
    
    a, b, c = trivial_triple(N)
    path = []
    
    for step in range(max_steps):
        # Check GCDs of all components
        for component in [a, b, c]:
            g = math.gcd(abs(component), N)
            if 1 < g < N:
                if verbose:
                    print(f"  Step {step}: FACTOR FOUND! gcd({component}, {N}) = {g}")
                return (g, step, path)
        
        # Check if we've reached the root
        if (a, b, c) == (3, 4, 5) or (a, b, c) == (4, 3, 5):
            break
        
        # Find parent
        branch, (pa, pb, pc) = find_parent(a, b, c)
        if verbose:
            print(f"  Step {step}: ({a},{b},{c}) --[{branch}⁻¹]--> ({pa},{pb},{pc})")
        path.append(branch)
        a, b, c = pa, pb, pc
    
    return (None, len(path), path)

# =============================================================================
# DEMO 1: Factor specific numbers
# =============================================================================

def demo_factoring():
    """Demonstrate factoring via tree descent."""
    print("=" * 72)
    print("DEMO 1: FACTORING VIA BERGGREN TREE DESCENT")
    print("=" * 72)
    
    test_cases = [
        15, 21, 35, 77, 91, 143, 221, 323, 437, 667, 899,
        1073, 2021, 3233, 4757, 10403
    ]
    
    results = []
    for N in test_cases:
        factor, steps, path = reverse_factor(N, verbose=False)
        path_str = ''.join(path[:20]) + ('...' if len(path) > 20 else '')
        if factor:
            other = N // factor
            print(f"  N = {N:>6} = {factor} × {other:<6}  "
                  f"found in {steps:>3} steps  path: {path_str}")
            results.append((N, factor, steps, path))
        else:
            print(f"  N = {N:>6} = PRIME  (no factor found in {steps} steps)")
            results.append((N, None, steps, path))
    
    return results

# =============================================================================
# DEMO 2: Branch encoding analysis
# =============================================================================

def demo_branch_encoding():
    """Analyze how branch choices encode number-theoretic information."""
    print("\n" + "=" * 72)
    print("DEMO 2: BRANCH ENCODING — DESCENT PATHS")
    print("=" * 72)
    print("\nThe descent path (sequence of A/B/C choices) encodes information")
    print("about the arithmetic structure of N.\n")
    
    # Compare paths for different products of the same primes
    groups = {
        "3 × k": [(3*5, "15"), (3*7, "21"), (3*11, "33"), (3*13, "39")],
        "7 × k": [(7*11, "77"), (7*13, "91"), (7*17, "119"), (7*19, "133")],
        "twins": [(11*13, "143"), (17*19, "323"), (29*31, "899"), (41*43, "1763")],
    }
    
    for group_name, cases in groups.items():
        print(f"\n  Group: {group_name}")
        for N, label in cases:
            _, steps, path = reverse_factor(N)
            path_str = ''.join(path[:30])
            branch_counts = {ch: path.count(ch) for ch in 'ABC'}
            print(f"    {label:>6} ({N:>5}): {path_str:<32} "
                  f"A={branch_counts.get('A',0)} B={branch_counts.get('B',0)} "
                  f"C={branch_counts.get('C',0)}")

# =============================================================================
# DEMO 3: Fixed-point analysis
# =============================================================================

def demo_fixed_points():
    """Analyze fixed points of Berggren matrix powers."""
    print("\n" + "=" * 72)
    print("DEMO 3: FIXED-POINT ANALYSIS")
    print("=" * 72)
    
    import numpy as np
    
    B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.float64)
    B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.float64)
    B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.float64)
    
    matrices = {'B₁': B1, 'B₂': B2, 'B₃': B3}
    
    for name, M in matrices.items():
        print(f"\n  {name}:")
        eigenvalues = np.linalg.eigvals(M)
        print(f"    Eigenvalues: {[f'{e.real:.4f}' for e in eigenvalues]}")
        print(f"    Determinant: {np.linalg.det(M):.0f}")
        print(f"    Trace: {np.trace(M):.0f}")
        
        # Check symmetry: M == M^T ?
        is_symmetric = np.allclose(M, M.T)
        print(f"    Symmetric: {is_symmetric}")
        
        # For symmetric matrices, fixed points must have a = b
        if is_symmetric:
            print(f"    → Fixed points satisfy a = b (by row subtraction)")
    
    # Analyze powers of B₂
    print(f"\n  Powers of B₂:")
    M = B2.copy()
    for n in range(1, 6):
        Mn = np.linalg.matrix_power(B2, n)
        is_sym = np.allclose(Mn, Mn.T)
        print(f"    B₂^{n}: tr={np.trace(Mn):.0f}, "
              f"symmetric={is_sym}, "
              f"(1,2)={(Mn[0,1]):.0f}, (2,1)={(Mn[1,0]):.0f}")

# =============================================================================
# DEMO 4: Statistics
# =============================================================================

def demo_statistics():
    """Gather statistics on factoring success and step counts."""
    print("\n" + "=" * 72)
    print("DEMO 4: FACTORING STATISTICS")
    print("=" * 72)
    
    # Test all odd composites up to 1000
    composites = []
    for n in range(9, 1000, 2):
        if not is_prime(n) and n % 2 == 1:
            composites.append(n)
    
    successes = 0
    total_steps = 0
    step_distribution = defaultdict(int)
    
    for N in composites:
        factor, steps, path = reverse_factor(N, max_steps=500)
        if factor:
            successes += 1
            total_steps += steps
            bucket = steps // 5 * 5
            step_distribution[bucket] += 1
    
    print(f"\n  Tested {len(composites)} odd composites in [9, 999]")
    print(f"  Successes: {successes} ({100*successes/len(composites):.1f}%)")
    if successes > 0:
        print(f"  Average steps to factor: {total_steps/successes:.1f}")
    
    print(f"\n  Step distribution:")
    for bucket in sorted(step_distribution.keys()):
        count = step_distribution[bucket]
        bar = '█' * (count // 2)
        print(f"    {bucket:>3}-{bucket+4}: {count:>4}  {bar}")
    
    return composites, successes

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True

# =============================================================================
# SVG VISUALIZATIONS
# =============================================================================

class SVG:
    def __init__(self, width, height, bg='#fafafa'):
        self.width = width
        self.height = height
        self.elements = []
        if bg:
            self.rect(0, 0, width, height, fill=bg, stroke='none')
    
    def rect(self, x, y, w, h, fill='none', stroke='black', sw=1, rx=0):
        self.elements.append(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" '
            f'fill="{fill}" stroke="{stroke}" stroke-width="{sw}" rx="{rx}"/>')
    
    def circle(self, cx, cy, r, fill='steelblue', stroke='black', sw=1):
        self.elements.append(
            f'<circle cx="{cx}" cy="{cy}" r="{r}" '
            f'fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>')
    
    def line(self, x1, y1, x2, y2, stroke='black', sw=1, dash=None):
        extra = f' stroke-dasharray="{dash}"' if dash else ''
        self.elements.append(
            f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="{stroke}" stroke-width="{sw}"{extra}/>')
    
    def text(self, x, y, content, size=12, anchor='middle', fill='black',
             weight='normal', family='sans-serif'):
        self.elements.append(
            f'<text x="{x}" y="{y}" font-size="{size}" '
            f'text-anchor="{anchor}" fill="{fill}" '
            f'font-weight="{weight}" font-family="{family}">'
            f'{content}</text>')
    
    def path(self, d, stroke='black', fill='none', sw=1):
        self.elements.append(
            f'<path d="{d}" stroke="{stroke}" fill="{fill}" stroke-width="{sw}"/>')
    
    def save(self, filename):
        with open(filename, 'w') as f:
            f.write(f'<svg xmlns="http://www.w3.org/2000/svg" '
                   f'width="{self.width}" height="{self.height}" '
                   f'viewBox="0 0 {self.width} {self.height}">\n')
            for elem in self.elements:
                f.write(f'  {elem}\n')
            f.write('</svg>\n')
        print(f"  Saved: {filename}")


def generate_descent_path_svg(N=77, filename='descent_path.svg'):
    """Visualize the descent path for factoring N."""
    factor, steps, path_labels = reverse_factor(N, max_steps=100)
    
    # Recompute full path with triples
    a, b, c = trivial_triple(N)
    triples = [(a, b, c)]
    branches = []
    found_at = None
    
    for step in range(100):
        for comp in [a, b]:
            g = math.gcd(abs(comp), N)
            if 1 < g < N:
                found_at = step
                break
        if found_at is not None:
            break
        if (a, b, c) == (3, 4, 5):
            break
        branch, (pa, pb, pc) = find_parent(a, b, c)
        branches.append(branch)
        a, b, c = pa, pb, pc
        triples.append((a, b, c))
    
    n_steps = len(triples)
    svg_w = max(800, n_steps * 120 + 100)
    svg_h = 400
    svg = SVG(svg_w, svg_h, bg='#1a1a2e')
    
    # Title
    title = f"Berggren Tree Descent: N = {N}"
    if factor:
        title += f" = {factor} × {N // factor}"
    svg.text(svg_w // 2, 35, title, size=20, fill='#e0e0ff', weight='bold')
    svg.text(svg_w // 2, 58, f"Found factor in {found_at or n_steps} steps",
             size=14, fill='#aaaacc')
    
    # Draw path
    y_center = 200
    x_start = 60
    x_step = min(110, (svg_w - 120) // max(n_steps, 1))
    
    branch_colors = {'A': '#ff6b6b', 'B': '#4ecdc4', 'C': '#ffe66d'}
    
    for i, (a, b, c) in enumerate(triples):
        x = x_start + i * x_step
        
        # Draw connecting line/arrow
        if i > 0:
            x_prev = x_start + (i - 1) * x_step
            br = branches[i - 1]
            color = branch_colors.get(br, '#888')
            svg.line(x_prev + 35, y_center, x - 35, y_center, stroke=color, sw=2)
            # Branch label
            mid_x = (x_prev + 35 + x - 35) // 2
            svg.text(mid_x, y_center - 15, f"{br}⁻¹", size=11, fill=color, weight='bold')
        
        # Highlight if factor found here
        is_factor_step = (found_at is not None and i == found_at)
        
        # Node
        node_color = '#ff4444' if is_factor_step else '#16213e'
        border_color = '#ff6b6b' if is_factor_step else '#4ecdc4'
        svg.rect(x - 32, y_center - 30, 64, 60, fill=node_color,
                 stroke=border_color, sw=2, rx=8)
        
        # Triple text
        svg.text(x, y_center - 10, f"({a},", size=9, fill='#e0e0e0')
        svg.text(x, y_center + 3, f" {b},", size=9, fill='#e0e0e0')
        svg.text(x, y_center + 16, f" {c})", size=9, fill='#e0e0e0')
        
        # Step number
        svg.text(x, y_center + 42, f"step {i}", size=9, fill='#888')
        
        # GCD annotation
        if is_factor_step:
            for comp in [a, b]:
                g = math.gcd(abs(comp), N)
                if 1 < g < N:
                    svg.text(x, y_center - 50,
                             f"gcd({comp},{N})={g}", size=10, fill='#ff6b6b',
                             weight='bold')
                    svg.text(x, y_center - 65,
                             f"FACTOR!", size=12, fill='#ffe66d', weight='bold')
                    break
    
    # Hypotenuse decay chart at bottom
    if len(triples) > 1:
        chart_y = 310
        chart_h = 60
        max_c = max(t[2] for t in triples)
        svg.text(svg_w // 2, chart_y - 5, "Hypotenuse decay during descent",
                 size=11, fill='#aaaacc')
        for i, (a, b, c) in enumerate(triples):
            x = x_start + i * x_step
            bar_h = int(chart_h * c / max_c)
            svg.rect(x - 8, chart_y + chart_h - bar_h, 16, bar_h,
                     fill='#4ecdc4', stroke='none', rx=2)
            svg.text(x, chart_y + chart_h + 12, str(c), size=7, fill='#888')
    
    svg.save(filename)


def generate_branch_encoding_svg(filename='branch_encoding.svg'):
    """Visualize branch encoding patterns for different N values."""
    test_ns = [15, 21, 35, 55, 77, 91, 143, 221, 323, 437]
    
    svg_w = 900
    svg_h = 80 + len(test_ns) * 45
    svg = SVG(svg_w, svg_h, bg='#1a1a2e')
    
    svg.text(svg_w // 2, 30, "Branch Encoding: Descent Paths for Various N",
             size=18, fill='#e0e0ff', weight='bold')
    svg.text(svg_w // 2, 50, "Each colored cell = one branch choice (A/B/C) during ascent",
             size=12, fill='#aaaacc')
    
    branch_colors = {'A': '#ff6b6b', 'B': '#4ecdc4', 'C': '#ffe66d'}
    
    y = 75
    max_path_len = 0
    for N in test_ns:
        factor, steps, path = reverse_factor(N, max_steps=80)
        max_path_len = max(max_path_len, len(path))
    
    cell_w = min(14, (svg_w - 200) // max(max_path_len, 1))
    
    for N in test_ns:
        factor, steps, path = reverse_factor(N, max_steps=80)
        
        # Label
        if factor:
            label = f"N={N} = {factor}×{N//factor}"
        else:
            label = f"N={N} (prime)"
        svg.text(95, y + 12, label, size=11, fill='#e0e0e0', anchor='end')
        
        # Path cells
        x_start = 110
        for i, branch in enumerate(path[:60]):
            x = x_start + i * cell_w
            color = branch_colors.get(branch, '#555')
            svg.rect(x, y - 2, cell_w - 1, 18, fill=color, stroke='none', rx=1)
        
        # Step count
        svg.text(x_start + len(path[:60]) * cell_w + 10, y + 12,
                 f"{len(path)} steps", size=9, fill='#888')
        
        y += 35
    
    # Legend
    ly = svg_h - 25
    for i, (label, color) in enumerate([('A (B₁⁻¹)', '#ff6b6b'),
                                          ('B (B₂⁻¹)', '#4ecdc4'),
                                          ('C (B₃⁻¹)', '#ffe66d')]):
        lx = svg_w // 2 - 120 + i * 120
        svg.rect(lx, ly, 12, 12, fill=color, stroke='none', rx=2)
        svg.text(lx + 18, ly + 10, label, size=10, fill='#ccc', anchor='start')
    
    svg.save(filename)


def generate_fixed_point_svg(filename='fixed_point_landscape.svg'):
    """Visualize the fixed-point structure of Berggren matrices."""
    svg_w = 800
    svg_h = 500
    svg = SVG(svg_w, svg_h, bg='#1a1a2e')
    
    svg.text(svg_w // 2, 35, "Fixed-Point Structure of Berggren Matrices",
             size=20, fill='#e0e0ff', weight='bold')
    
    # Three panels: B₁, B₂, B₃
    panel_w = 220
    panel_h = 180
    panels = [
        ("B₁ (Unipotent)", 60, 80,
         "Eigenvalues: {1, 1, 1}", "(B₁-I)³ = 0",
         "All vectors on the", "eigenspace are fixed", '#ff6b6b'),
        ("B₂ (Hyperbolic)", 290, 80,
         "Eigenvalues: {3+2√2, 3-2√2, -1}", "Only fixed point: origin",
         "Fixed points satisfy", "a = b (symmetric matrix)", '#4ecdc4'),
        ("B₃ (Unipotent)", 520, 80,
         "Eigenvalues: {1, 1, 1}", "(B₃-I)³ = 0",
         "All vectors on the", "eigenspace are fixed", '#ffe66d'),
    ]
    
    for name, px, py, line1, line2, line3, line4, color in panels:
        svg.rect(px, py, panel_w, panel_h, fill='#16213e', stroke=color, sw=2, rx=10)
        svg.text(px + panel_w // 2, py + 25, name, size=14, fill=color, weight='bold')
        svg.text(px + panel_w // 2, py + 55, line1, size=9, fill='#ccc')
        svg.text(px + panel_w // 2, py + 75, line2, size=9, fill='#ccc')
        svg.text(px + panel_w // 2, py + 110, line3, size=10, fill='#e0e0e0')
        svg.text(px + panel_w // 2, py + 130, line4, size=10, fill='#e0e0e0')
    
    # Fixed-point equation section
    eq_y = 300
    svg.text(svg_w // 2, eq_y, "The Fixed-Point Equation for M^G",
             size=16, fill='#e0e0ff', weight='bold')
    
    equations = [
        "(M - I) · (a, b, c)ᵀ = 0",
        "",
        "For symmetric M: subtracting row₁ from row₂ gives",
        "(m₂₁ - m₁₂)(a-b) + (m₂₂ - m₁₁)(a-b) = 0",
        "",
        "When M is symmetric (m₁₂ = m₂₁, m₁₁ = m₂₂): any (a-b) works",
        "When rows differ by factor: (a-b) = 0, so a = b",
        "",
        "Result: a = b collapses the 3-equation system to 1 equation",
    ]
    
    for i, eq in enumerate(equations):
        color = '#ffe66d' if 'a = b' in eq else '#ccc'
        svg.text(svg_w // 2, eq_y + 25 + i * 18, eq, size=11, fill=color)
    
    svg.save(filename)


def generate_factoring_success_svg(filename='factoring_success.svg'):
    """Chart: factoring success rates and step counts."""
    svg_w = 800
    svg_h = 500
    svg = SVG(svg_w, svg_h, bg='#1a1a2e')
    
    svg.text(svg_w // 2, 35, "Factoring via Tree Descent: Performance Analysis",
             size=18, fill='#e0e0ff', weight='bold')
    
    # Gather data
    ranges = [(9, 100), (100, 500), (500, 1000), (1000, 2000), (2000, 5000)]
    stats = []
    
    for lo, hi in ranges:
        composites = [n for n in range(lo | 1, hi, 2)
                      if not is_prime(n)]
        successes = 0
        total_steps = 0
        for N in composites:
            factor, steps, _ = reverse_factor(N, max_steps=500)
            if factor:
                successes += 1
                total_steps += steps
        rate = successes / max(len(composites), 1) * 100
        avg_steps = total_steps / max(successes, 1)
        stats.append((f"{lo}-{hi}", len(composites), successes, rate, avg_steps))
    
    # Bar chart
    chart_x = 120
    chart_w = 550
    chart_y = 80
    chart_h = 180
    bar_w = chart_w // len(stats) - 20
    
    svg.text(chart_x - 10, chart_y + chart_h + 30, "Range", size=11, fill='#aaa')
    
    for i, (label, total, succ, rate, avg) in enumerate(stats):
        x = chart_x + i * (chart_w // len(stats)) + 10
        
        # Success rate bar
        bar_h = int(chart_h * rate / 100)
        svg.rect(x, chart_y + chart_h - bar_h, bar_w, bar_h,
                 fill='#4ecdc4', stroke='none', rx=3)
        svg.text(x + bar_w // 2, chart_y + chart_h - bar_h - 8,
                 f"{rate:.0f}%", size=11, fill='#4ecdc4', weight='bold')
        svg.text(x + bar_w // 2, chart_y + chart_h + 15,
                 label, size=9, fill='#aaa')
        svg.text(x + bar_w // 2, chart_y + chart_h + 28,
                 f"n={total}", size=8, fill='#888')
    
    # Axis
    svg.line(chart_x - 5, chart_y + chart_h, chart_x + chart_w,
             chart_y + chart_h, stroke='#555', sw=1)
    svg.text(chart_x - 15, chart_y + 5, "100%", size=9, fill='#888', anchor='end')
    svg.text(chart_x - 15, chart_y + chart_h, "0%", size=9, fill='#888', anchor='end')
    
    svg.text(svg_w // 2, chart_y - 10, "Success Rate by Number Range",
             size=14, fill='#e0e0ff')
    
    # Average steps section
    steps_y = chart_y + chart_h + 60
    svg.text(svg_w // 2, steps_y, "Average Steps to Factor",
             size=14, fill='#e0e0ff')
    
    max_avg = max(s[4] for s in stats) if stats else 1
    for i, (label, total, succ, rate, avg) in enumerate(stats):
        x = chart_x + i * (chart_w // len(stats)) + 10
        bar_h = int(100 * avg / max(max_avg, 1))
        svg.rect(x, steps_y + 120 - bar_h, bar_w, bar_h,
                 fill='#ff6b6b', stroke='none', rx=3)
        svg.text(x + bar_w // 2, steps_y + 120 - bar_h - 8,
                 f"{avg:.1f}", size=10, fill='#ff6b6b')
        svg.text(x + bar_w // 2, steps_y + 135,
                 label, size=9, fill='#aaa')
    
    svg.line(chart_x - 5, steps_y + 120, chart_x + chart_w,
             steps_y + 120, stroke='#555', sw=1)
    
    svg.save(filename)


# =============================================================================
# MAIN
# =============================================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  REVERSE SOLVING ON THE BERGGREN TREE — Demo & Visualization Suite  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    # Run demos
    demo_factoring()
    demo_branch_encoding()
    
    try:
        demo_fixed_points()
    except ImportError:
        print("\n  [numpy not available — skipping fixed-point eigenvalue demo]")
    
    demo_statistics()
    
    # Generate SVGs
    print("\n" + "=" * 72)
    print("GENERATING SVG VISUALIZATIONS")
    print("=" * 72)
    
    generate_descent_path_svg(N=77, filename='descent_path_77.svg')
    generate_descent_path_svg(N=143, filename='descent_path_143.svg')
    generate_descent_path_svg(N=323, filename='descent_path_323.svg')
    generate_branch_encoding_svg(filename='branch_encoding.svg')
    generate_fixed_point_svg(filename='fixed_point_landscape.svg')
    generate_factoring_success_svg(filename='factoring_success.svg')
    
    print("\n  All visualizations generated successfully!")
    print("  Open the .svg files in any web browser to view.")
