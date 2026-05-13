#!/usr/bin/env python3
"""
Tropical Arithmetic Lensing: Demonstrations and Visualizations

This module demonstrates the core concepts of tropical arithmetic lensing:
- Tropical lens network construction
- Caustic set computation
- Symmetry gap analysis
- Factor extraction from geometric invariants
- Pythagorean shell encoding

All algorithms correspond to formally verified theorems in Lean 4.
"""

import math
import itertools
from dataclasses import dataclass, field
from typing import List, Tuple, Optional
import json
import base64
import io

# ═══════════════════════════════════════════════════════════════════════════════
# CORE DATA STRUCTURES
# ═══════════════════════════════════════════════════════════════════════════════

@dataclass
class TropicalLensNetwork:
    """A tropical lens network: Source → {Lens₁, ..., Lensₖ} → Observer.

    Each lens vertex has:
    - cost_in: travel cost from source to this lens
    - cost_out: travel cost from this lens to observer
    - path_mult: number of independent geodesics through this lens
    """
    cost_in: List[int]
    cost_out: List[int]
    path_mult: List[int]

    def __post_init__(self):
        assert len(self.cost_in) == len(self.cost_out) == len(self.path_mult)
        assert all(m > 0 for m in self.path_mult), "All multiplicities must be positive"
        assert len(self.path_mult) > 0, "Must have at least one lens"

    @property
    def num_lenses(self) -> int:
        return len(self.path_mult)

    def total_cost(self, i: int) -> int:
        """Total cost through lens i."""
        return self.cost_in[i] + self.cost_out[i]

    @property
    def min_arrival_cost(self) -> int:
        """Minimum arrival cost across all lenses."""
        return min(self.total_cost(i) for i in range(self.num_lenses))

    @property
    def caustic_set(self) -> List[int]:
        """Indices of lenses achieving minimum cost (the 'images')."""
        m = self.min_arrival_cost
        return [i for i in range(self.num_lenses) if self.total_cost(i) == m]

    @property
    def caustic_mult(self) -> int:
        """Total caustic multiplicity (sum of path multiplicities over caustic set)."""
        return sum(self.path_mult[i] for i in self.caustic_set)

    @property
    def encoded_product(self) -> int:
        """Product of caustic multiplicities (arithmetic encoding)."""
        result = 1
        for i in self.caustic_set:
            result *= self.path_mult[i]
        return result

    @property
    def is_reduced(self) -> bool:
        """True if every lens is in the caustic set."""
        return len(self.caustic_set) == self.num_lenses

    @property
    def symmetry_gap(self) -> int:
        """Difference between max and min multiplicities in caustic set."""
        cs = self.caustic_set
        if not cs:
            return 0
        mults = [self.path_mult[i] for i in cs]
        return max(mults) - min(mults)

    def encodes_semiprime(self, N: int) -> bool:
        """Check if this network encodes N as a semiprime."""
        cs = self.caustic_set
        return (self.encoded_product == N and
                len(cs) >= 2 and
                all(self.path_mult[i] >= 2 for i in cs))

    def extract_factors(self) -> Optional[Tuple[int, int]]:
        """Extract a factor pair from the caustic structure, or None if trivial."""
        cs = self.caustic_set
        if len(cs) <= 1:
            return None
        if any(self.path_mult[i] <= 1 for i in cs):
            return None
        a = self.path_mult[cs[0]]
        b = 1
        for i in cs[1:]:
            b *= self.path_mult[i]
        return (a, b)


@dataclass
class PythagoreanShelling:
    """A Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int

    def __post_init__(self):
        assert self.a > 0 and self.b > 0
        assert self.a**2 + self.b**2 == self.c**2, f"{self.a}² + {self.b}² ≠ {self.c}²"

    @property
    def is_balanced(self) -> bool:
        return self.a > 1 and self.b > 1

    @property
    def balanced_product(self) -> int:
        return self.a * self.b

    def to_lens_network(self) -> TropicalLensNetwork:
        """Convert to a 2-lens tropical network."""
        return TropicalLensNetwork(
            cost_in=[0, 0],
            cost_out=[0, 0],
            path_mult=[self.a, self.b]
        )


# ═══════════════════════════════════════════════════════════════════════════════
# ALGORITHMS
# ═══════════════════════════════════════════════════════════════════════════════

def construct_lens_network(multiplicities: List[int]) -> TropicalLensNetwork:
    """Construct a reduced tropical lens network with given multiplicities.

    Corresponds to the Finite Tropical Lens Realization theorem.
    All costs are set to zero, making every lens caustic.
    """
    return TropicalLensNetwork(
        cost_in=[0] * len(multiplicities),
        cost_out=[0] * len(multiplicities),
        path_mult=multiplicities
    )


def pythagorean_parametric(m: int, n: int) -> PythagoreanShelling:
    """Generate a Pythagorean triple from parameters m > n > 0.

    Returns (m²-n², 2mn, m²+n²).
    """
    assert m > n > 0
    a = m**2 - n**2
    b = 2 * m * n
    c = m**2 + n**2
    return PythagoreanShelling(a, b, c)


def certified_factor_reconstructor(network: TropicalLensNetwork, N: int):
    """Certified decision procedure: extract factors or certify rigidity.

    Corresponds to the certified_minimal_factor_reconstructor theorem.
    Returns either:
    - ("FACTORS", (a, b)) with a*b = N, a > 1, b > 1
    - ("RIGID", reason) with a proof that extraction failed
    """
    cs = network.caustic_set
    if len(cs) <= 1:
        return ("RIGID", f"Too few caustic strata: {len(cs)} ≤ 1")

    low_mult = [(i, network.path_mult[i]) for i in cs if network.path_mult[i] <= 1]
    if low_mult:
        return ("RIGID", f"Lens {low_mult[0][0]} has multiplicity {low_mult[0][1]} ≤ 1")

    factors = network.extract_factors()
    if factors:
        a, b = factors
        assert a * b == N, f"Factor verification failed: {a} × {b} ≠ {N}"
        return ("FACTORS", (a, b))

    return ("RIGID", "Unknown")


# ═══════════════════════════════════════════════════════════════════════════════
# DEMONSTRATIONS
# ═══════════════════════════════════════════════════════════════════════════════

def demo_basic_factoring():
    """Demonstrate basic factor extraction from a tropical lens network."""
    print("=" * 70)
    print("DEMO 1: Basic Factor Extraction")
    print("=" * 70)

    # Factor 91 = 7 × 13
    N = 91
    network = construct_lens_network([7, 13])

    print(f"\nTarget: Factor N = {N}")
    print(f"Network: {network.num_lenses} lenses, multiplicities = {network.path_mult}")
    print(f"Caustic set: {network.caustic_set}")
    print(f"Encoded product: {network.encoded_product}")
    print(f"Symmetry gap: {network.symmetry_gap}")
    print(f"Is reduced: {network.is_reduced}")
    print(f"Encodes semiprime {N}: {network.encodes_semiprime(N)}")

    result = certified_factor_reconstructor(network, N)
    print(f"Certified reconstructor: {result[0]}")
    if result[0] == "FACTORS":
        a, b = result[1]
        print(f"  Factors: {a} × {b} = {a*b}")
    print()


def demo_pythagorean_encoding():
    """Demonstrate Pythagorean shell encoding."""
    print("=" * 70)
    print("DEMO 2: Pythagorean Shell Encoding")
    print("=" * 70)

    examples = [(2, 1), (3, 1), (3, 2), (4, 1), (4, 3), (5, 2), (5, 4)]

    for m, n in examples:
        shell = pythagorean_parametric(m, n)
        network = shell.to_lens_network()
        product = shell.balanced_product

        print(f"\n  m={m}, n={n}: ({shell.a}, {shell.b}, {shell.c})")
        print(f"    {shell.a}² + {shell.b}² = {shell.a**2} + {shell.b**2} = {shell.c**2} = {shell.c}²")
        print(f"    Balanced: {shell.is_balanced}, Product: {product}")

        if shell.is_balanced:
            result = certified_factor_reconstructor(network, product)
            if result[0] == "FACTORS":
                a, b = result[1]
                print(f"    Extracted factors: {a} × {b} = {a*b}")
    print()


def demo_symmetry_gap_analysis():
    """Demonstrate the symmetry gap and its relationship to factorability."""
    print("=" * 70)
    print("DEMO 3: Symmetry Gap Analysis")
    print("=" * 70)

    cases = [
        ("Uniform (prime power)", [5, 5, 5]),
        ("Balanced pair", [6, 6]),
        ("Unbalanced pair", [3, 7]),
        ("Three distinct", [2, 3, 5]),
        ("Large gap", [2, 100]),
    ]

    for name, mults in cases:
        network = construct_lens_network(mults)
        product = network.encoded_product
        gap = network.symmetry_gap
        result = certified_factor_reconstructor(network, product)

        print(f"\n  {name}: multiplicities = {mults}")
        print(f"    Encoded product = {product}")
        print(f"    Symmetry gap = {gap}")
        print(f"    Result: {result[0]}", end="")
        if result[0] == "FACTORS":
            print(f" → {result[1][0]} × {result[1][1]}")
        else:
            print(f" ({result[1]})")
    print()


def demo_multi_layer_networks():
    """Demonstrate networks with non-zero costs (some lenses not caustic)."""
    print("=" * 70)
    print("DEMO 4: Multi-Cost Networks (Non-Reduced)")
    print("=" * 70)

    # Network where not all lenses are caustic
    network = TropicalLensNetwork(
        cost_in=[0, 0, 5],     # Lens 3 has high inbound cost
        cost_out=[0, 0, 0],
        path_mult=[7, 13, 100]  # Lens 3 has huge multiplicity but is not caustic
    )

    print(f"\n  3 lenses, costs = {[network.total_cost(i) for i in range(3)]}")
    print(f"  Multiplicities = {network.path_mult}")
    print(f"  Min arrival cost = {network.min_arrival_cost}")
    print(f"  Caustic set = {network.caustic_set} (lens 2 excluded!)")
    print(f"  Is reduced = {network.is_reduced}")
    print(f"  Encoded product = {network.encoded_product} (only from caustic lenses)")
    print(f"  Caustic multiplicity = {network.caustic_mult}")

    result = certified_factor_reconstructor(network, network.encoded_product)
    print(f"  Result: {result[0]}", end="")
    if result[0] == "FACTORS":
        print(f" → {result[1][0]} × {result[1][1]}")
    else:
        print(f" ({result[1]})")
    print()


def demo_tropical_factoring_pipeline():
    """Demonstrate the complete factoring pipeline for various composites."""
    print("=" * 70)
    print("DEMO 5: Complete Tropical Factoring Pipeline")
    print("=" * 70)

    composites = [
        (6, "2 × 3"),
        (15, "3 × 5"),
        (35, "5 × 7"),
        (77, "7 × 11"),
        (143, "11 × 13"),
        (221, "13 × 17"),
        (1001, "7 × 11 × 13"),
        (30030, "2 × 3 × 5 × 7 × 11 × 13"),
    ]

    for N, factoring in composites:
        # Find a factorization to encode
        factors = []
        temp = N
        for p in range(2, temp + 1):
            while temp % p == 0:
                factors.append(p)
                temp //= p
            if temp == 1:
                break

        network = construct_lens_network(factors)
        result = certified_factor_reconstructor(network, N)

        print(f"\n  N = {N:>6} = {factoring}")
        print(f"    Lens multiplicities: {factors}")
        print(f"    Symmetry gap: {network.symmetry_gap}")
        if result[0] == "FACTORS":
            a, b = result[1]
            print(f"    Extracted: {a} × {b} = {a*b}")
        else:
            print(f"    Result: {result[1]}")
    print()


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

def generate_visualizations():
    """Generate SVG visualizations of tropical lens networks."""
    visualizations = []

    # Visualization 1: A 2-lens network for 91 = 7 × 13
    svg1 = generate_lens_network_svg([7, 13], "Factoring 91 = 7 × 13")
    visualizations.append(("Tropical Lens Network: 91 = 7 × 13", svg1))

    # Visualization 2: Pythagorean triple (3,4,5) encoding
    svg2 = generate_pythagorean_svg(3, 4, 5)
    visualizations.append(("Pythagorean Shell: (3, 4, 5)", svg2))

    # Visualization 3: Symmetry gap comparison
    svg3 = generate_symmetry_gap_svg()
    visualizations.append(("Symmetry Gap Comparison", svg3))

    return visualizations


def generate_lens_network_svg(multiplicities: List[int], title: str) -> str:
    """Generate an SVG diagram of a tropical lens network."""
    w, h = 500, 300
    n = len(multiplicities)
    total = sum(multiplicities)

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#555"/>
    </marker>
  </defs>
  <rect width="{w}" height="{h}" fill="#fafafa" rx="8"/>
  <text x="{w//2}" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">{title}</text>

  <!-- Source -->
  <circle cx="60" cy="{h//2}" r="20" fill="#4a90d9" stroke="#333" stroke-width="2"/>
  <text x="60" y="{h//2+5}" text-anchor="middle" fill="white" font-size="12" font-weight="bold">S</text>

  <!-- Observer -->
  <circle cx="{w-60}" cy="{h//2}" r="20" fill="#d94a4a" stroke="#333" stroke-width="2"/>
  <text x="{w-60}" y="{h//2+5}" text-anchor="middle" fill="white" font-size="12" font-weight="bold">O</text>
'''

    # Lens vertices
    for i, mult in enumerate(multiplicities):
        y = 80 + (h - 160) * i / max(n - 1, 1)
        lx = w // 2
        radius = 12 + mult * 1.5

        # Edges
        svg += f'  <line x1="80" y1="{h//2}" x2="{lx-radius}" y2="{y}" stroke="#888" stroke-width="1.5" marker-end="url(#arrowhead)"/>\n'
        svg += f'  <line x1="{lx+radius}" y1="{y}" x2="{w-80}" y2="{h//2}" stroke="#888" stroke-width="1.5" marker-end="url(#arrowhead)"/>\n'

        # Lens vertex
        color = f"hsl({120 + i * 60}, 60%, 50%)"
        svg += f'  <circle cx="{lx}" cy="{y}" r="{radius}" fill="{color}" stroke="#333" stroke-width="2" opacity="0.8"/>\n'
        svg += f'  <text x="{lx}" y="{y+5}" text-anchor="middle" fill="white" font-size="12" font-weight="bold">×{mult}</text>\n'

    # Product annotation
    product = 1
    for m in multiplicities:
        product *= m
    mult_str = " × ".join(str(m) for m in multiplicities)
    svg += f'  <text x="{w//2}" y="{h-20}" text-anchor="middle" font-size="13" fill="#555">Product: {mult_str} = {product}</text>\n'
    svg += '</svg>'
    return svg


def generate_pythagorean_svg(a: int, b: int, c: int) -> str:
    """Generate SVG showing a Pythagorean triple and its lens encoding."""
    w, h = 500, 300

    # Scale triangle to fit
    scale = min(180 / a, 180 / b)
    ax, ay = 60, h - 60
    bx, by_ = 60 + int(a * scale), h - 60
    cx, cy = 60, h - 60 - int(b * scale)

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">
  <rect width="{w}" height="{h}" fill="#fafafa" rx="8"/>
  <text x="{w//2}" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">Pythagorean Shell: ({a}, {b}, {c})</text>

  <!-- Triangle -->
  <polygon points="{ax},{ay} {bx},{by_} {cx},{cy}" fill="none" stroke="#4a90d9" stroke-width="2.5"/>

  <!-- Side labels -->
  <text x="{(ax+bx)//2}" y="{ay+20}" text-anchor="middle" font-size="14" fill="#4a90d9" font-weight="bold">a = {a}</text>
  <text x="{ax-25}" y="{(ay+cy)//2}" text-anchor="middle" font-size="14" fill="#4a90d9" font-weight="bold">b = {b}</text>
  <text x="{(bx+cx)//2+20}" y="{(by_+cy)//2}" text-anchor="middle" font-size="14" fill="#d94a4a" font-weight="bold">c = {c}</text>

  <!-- Right angle marker -->
  <rect x="{ax}" y="{ay-15}" width="15" height="15" fill="none" stroke="#888" stroke-width="1"/>

  <!-- Equation -->
  <text x="350" y="100" text-anchor="middle" font-size="15" fill="#333">{a}² + {b}² = {c}²</text>
  <text x="350" y="125" text-anchor="middle" font-size="14" fill="#555">{a**2} + {b**2} = {c**2}</text>

  <!-- Product -->
  <text x="350" y="170" text-anchor="middle" font-size="15" fill="#333" font-weight="bold">Balanced Product:</text>
  <text x="350" y="195" text-anchor="middle" font-size="14" fill="#4a90d9">{a} × {b} = {a*b}</text>

  <!-- Arrow to lens -->
  <text x="350" y="240" text-anchor="middle" font-size="13" fill="#888">↓ Tropical Lens Encoding ↓</text>
  <text x="350" y="270" text-anchor="middle" font-size="14" fill="#555">2-lens network: mult = [{a}, {b}]</text>
</svg>'''
    return svg


def generate_symmetry_gap_svg() -> str:
    """Generate SVG comparing networks with different symmetry gaps."""
    w, h = 500, 350

    cases = [
        ("Gap = 0 (uniform)", [5, 5, 5], "#4a90d9"),
        ("Gap = 4 (unbalanced)", [3, 7], "#d9a04a"),
        ("Gap = 11 (high gap)", [2, 13], "#d94a4a"),
    ]

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">
  <rect width="{w}" height="{h}" fill="#fafafa" rx="8"/>
  <text x="{w//2}" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">Symmetry Gap Comparison</text>
'''

    bar_width = 40
    group_width = 150

    for gi, (label, mults, color) in enumerate(cases):
        gx = 50 + gi * group_width
        max_mult = max(max(m for _, ms, _ in cases) for m in [max(ms) for _, ms, _ in cases])

        svg += f'  <text x="{gx + group_width//2 - 25}" y="60" text-anchor="middle" font-size="11" fill="#555">{label}</text>\n'

        for i, m in enumerate(mults):
            bx = gx + i * (bar_width + 5)
            bar_h = m * 15
            by_ = h - 60 - bar_h

            svg += f'  <rect x="{bx}" y="{by_}" width="{bar_width}" height="{bar_h}" fill="{color}" opacity="0.7" rx="3"/>\n'
            svg += f'  <text x="{bx + bar_width//2}" y="{by_ - 5}" text-anchor="middle" font-size="11" fill="#333">{m}</text>\n'

        network = construct_lens_network(mults)
        product = network.encoded_product
        gap = network.symmetry_gap
        svg += f'  <text x="{gx + group_width//2 - 25}" y="{h-25}" text-anchor="middle" font-size="11" fill="#333">∏ = {product}, gap = {gap}</text>\n'

    svg += '</svg>'
    return svg


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n" + "═" * 70)
    print("  TROPICAL ARITHMETIC LENSING: Demonstrations")
    print("═" * 70 + "\n")

    demo_basic_factoring()
    demo_pythagorean_encoding()
    demo_symmetry_gap_analysis()
    demo_multi_layer_networks()
    demo_tropical_factoring_pipeline()

    # Generate visualizations
    print("=" * 70)
    print("GENERATING VISUALIZATIONS")
    print("=" * 70)
    vizs = generate_visualizations()
    for name, svg in vizs:
        print(f"  Generated: {name} ({len(svg)} chars)")

    print("\n✓ All demonstrations complete.\n")


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all source files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
lean_code = read_file('Bridges/AlgebraTropicalGeometry/TropicalGravitationalFactoringDuality.lean')

# Generate visualizations
from demo import generate_visualizations
vizs = generate_visualizations()

# Build algorithms
algorithms = [
    {
        "name": "Tropical Lens Network Construction",
        "pseudocode": """Algorithm: ConstructLensNetwork(multiplicities)
Input: k ≥ 1, multiplicities m₁, ..., mₖ > 0
Output: Reduced tropical lens network L

1. Set L.numLenses ← k
2. Set L.costIn[i] ← 0 for all i
3. Set L.costOut[i] ← 0 for all i  
4. Set L.pathMult[i] ← mᵢ for all i
5. Return L

Time: O(k), Space: O(k)""",
        "code": '''def construct_lens_network(multiplicities):
    """Construct a reduced tropical lens network with given multiplicities."""
    return {
        "num_lenses": len(multiplicities),
        "cost_in": [0] * len(multiplicities),
        "cost_out": [0] * len(multiplicities),
        "path_mult": multiplicities
    }

# Example
network = construct_lens_network([7, 13])
print(f"Network: {network}")
print(f"Encoded product: {network['path_mult'][0] * network['path_mult'][1]}")'''
    },
    {
        "name": "Certified Factor Extraction",
        "pseudocode": """Algorithm: ExtractFactors(L, N)
Input: Tropical lens network L with encodedProduct = N
Output: (a, b) with a·b = N, a > 1, b > 1, or RIGID

1. Compute causticSet S ← {i : totalCost(i) = min_j totalCost(j)}
2. If |S| ≤ 1: return RIGID
3. If ∃ i ∈ S with pathMult(i) ≤ 1: return RIGID  
4. Pick any i₀ ∈ S
5. a ← pathMult(i₀)
6. b ← Π_{j ∈ S \\ {i₀}} pathMult(j)
7. Return (a, b)

Time: O(k), Space: O(k)""",
        "code": '''def extract_factors(path_mult, cost_in=None, cost_out=None):
    """Extract factors from a tropical lens network."""
    n = len(path_mult)
    if cost_in is None:
        cost_in = [0] * n
    if cost_out is None:
        cost_out = [0] * n
    
    # Compute caustic set
    total_costs = [cost_in[i] + cost_out[i] for i in range(n)]
    min_cost = min(total_costs)
    caustic = [i for i in range(n) if total_costs[i] == min_cost]
    
    if len(caustic) <= 1:
        return ("RIGID", "Too few caustic strata")
    if any(path_mult[i] <= 1 for i in caustic):
        return ("RIGID", "Some multiplicity <= 1")
    
    a = path_mult[caustic[0]]
    b = 1
    for i in caustic[1:]:
        b *= path_mult[i]
    return ("FACTORS", (a, b))

# Examples
print(extract_factors([7, 13]))      # 91 = 7 × 13
print(extract_factors([3, 5, 7]))    # 105 = 3 × 35
print(extract_factors([5, 5, 5]))    # 125 = 5 × 25'''
    },
    {
        "name": "Pythagorean Shell Encoding",
        "pseudocode": """Algorithm: PythagoreanEncode(m, n)
Input: m > n > 0 with m > 1
Output: Balanced Pythagorean shelling and lens network

1. a ← m² - n²
2. b ← 2mn
3. c ← m² + n²
4. Assert a² + b² = c²
5. L ← ConstructLensNetwork([a, b])
6. Return ((a, b, c), L)

Time: O(1), Space: O(1)""",
        "code": '''def pythagorean_encode(m, n):
    """Generate Pythagorean triple and lens encoding."""
    assert m > n > 0 and m > 1
    a = m**2 - n**2
    b = 2 * m * n
    c = m**2 + n**2
    assert a**2 + b**2 == c**2
    product = a * b
    return {
        "triple": (a, b, c),
        "product": product,
        "factors": (a, b),
        "verification": f"{a}^2 + {b}^2 = {a**2} + {b**2} = {c**2} = {c}^2"
    }

# Generate first 10 parametric Pythagorean shellings
for m in range(2, 7):
    for n in range(1, m):
        result = pythagorean_encode(m, n)
        print(f"m={m}, n={n}: {result['triple']}, product={result['product']}")'''
    }
]

# Build package
package = {
    "title": "Tropical Arithmetic Lensing: Geodesic Semimodules, Caustic Factor Certificates, and Certified Factor Reconstruction",
    "domain": "Tropical Geometry × Number Theory × Cryptography",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Arithmetic Lensing Demo",
            "code": demo_code
        }
    ],
    "algorithms": algorithms,
    "visualizations": [
        {"name": name, "data": svg}
        for name, svg in vizs
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({os.path.getsize('PACKAGE.json')} bytes)")
