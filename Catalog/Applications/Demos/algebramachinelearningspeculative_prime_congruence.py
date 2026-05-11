#!/usr/bin/env python3
"""
Spectral Learning Theory for Neural Operads: Interactive Demo

Demonstrates the core concepts of the observer spectrum duality:
- Observer families and their kernels
- Vanishing sets and joint kernels
- Galois connection verification
- Radical congruences and spectral closure
- Compression certificates

Run: python demo.py
"""

from itertools import combinations
from typing import Dict, List, Set, Tuple, FrozenSet
import json


# ─────────────────────────────────────────────────────────────
# Core Data Structures
# ─────────────────────────────────────────────────────────────

class ObserverFamily:
    """A finite family of observers on a finite set S = {0, ..., n-1}."""

    def __init__(self, observers: Dict[str, List[int]]):
        """
        observers: dict mapping observer name to list of values.
        observers[name][i] = value assigned to element i.
        """
        self.observers = observers
        self.names = list(observers.keys())
        self.n = len(next(iter(observers.values())))  # |S|
        self.m = len(observers)  # number of observers

    def kernel(self, name: str) -> Set[Tuple[int, int]]:
        """The kernel of observer `name`: pairs (x,y) with obs(x) = obs(y)."""
        obs = self.observers[name]
        return {(x, y) for x in range(self.n) for y in range(self.n)
                if obs[x] == obs[y]}

    def joint_kernel(self, names: FrozenSet[str]) -> Set[Tuple[int, int]]:
        """The joint kernel I(C): pairs agreed upon by all observers in C."""
        if not names:
            # Empty set → universal relation
            return {(x, y) for x in range(self.n) for y in range(self.n)}
        result = None
        for name in names:
            k = self.kernel(name)
            result = k if result is None else result & k
        return result

    def vanishing_set(self, relation: Set[Tuple[int, int]]) -> FrozenSet[str]:
        """The vanishing set V(R): observers whose kernel contains R."""
        result = set()
        for name in self.names:
            k = self.kernel(name)
            if relation <= k:  # R ⊆ ker(obs)
                result.add(name)
        return frozenset(result)

    def separates(self) -> bool:
        """Check if the observer family satisfies the separation axiom."""
        for x in range(self.n):
            for y in range(x + 1, self.n):
                separated = False
                for name in self.names:
                    if self.observers[name][x] != self.observers[name][y]:
                        separated = True
                        break
                if not separated:
                    return False
        return True

    def is_radical(self, relation: Set[Tuple[int, int]]) -> bool:
        """Check if R is radical: R = I(V(R))."""
        v = self.vanishing_set(relation)
        iv = self.joint_kernel(v)
        return relation == iv

    def is_spectrally_closed(self, C: FrozenSet[str]) -> bool:
        """Check if C is spectrally closed: C = V(I(C))."""
        ic = self.joint_kernel(C)
        vic = self.vanishing_set(ic)
        return C == vic

    def radicalize(self, relation: Set[Tuple[int, int]]) -> Set[Tuple[int, int]]:
        """Compute rad(R) = I(V(R))."""
        v = self.vanishing_set(relation)
        return self.joint_kernel(v)


def equality_relation(n: int) -> Set[Tuple[int, int]]:
    """The equality relation on {0, ..., n-1}."""
    return {(x, x) for x in range(n)}


def universal_relation(n: int) -> Set[Tuple[int, int]]:
    """The universal relation on {0, ..., n-1}."""
    return {(x, y) for x in range(n) for y in range(n)}


# ─────────────────────────────────────────────────────────────
# Demo 1: Basic Observer Family
# ─────────────────────────────────────────────────────────────

def demo_basic():
    """Demonstrate the observer family on Fin 4 from the formalization."""
    print("=" * 60)
    print("DEMO 1: Observer Family on {0, 1, 2, 3}")
    print("=" * 60)

    # The example from the formalization
    obs = ObserverFamily({
        "φ₀": [0, 0, 1, 1],  # splits {0,1} from {2,3}
        "φ₁": [0, 1, 0, 1],  # splits {0,2} from {1,3}
    })

    print(f"\nCarrier: {{0, 1, 2, 3}}")
    print(f"Number of observers: {obs.m}")
    print(f"\nObserver values:")
    for name in obs.names:
        vals = obs.observers[name]
        print(f"  {name}: {' '.join(str(v) for v in vals)}")

    # Check separation
    print(f"\nSeparation axiom: {obs.separates()}")

    # Show kernels
    print(f"\nKernels:")
    for name in obs.names:
        k = obs.kernel(name)
        pairs = [(x, y) for x, y in sorted(k) if x < y]
        print(f"  ker({name}): identified pairs = {pairs}")

    # Show joint kernel of all observers
    jk_all = obs.joint_kernel(frozenset(obs.names))
    print(f"\nJoint kernel I({{φ₀, φ₁}}): {sorted(jk_all)}")
    print(f"  = equality? {jk_all == equality_relation(4)}")

    # Vanishing set of equality
    v_eq = obs.vanishing_set(equality_relation(4))
    print(f"\nVanishing set V(Eq): {set(v_eq)}")
    print(f"  = full set? {v_eq == frozenset(obs.names)}")

    # Check radicality of equality
    print(f"\nEquality is radical: {obs.is_radical(equality_relation(4))}")


# ─────────────────────────────────────────────────────────────
# Demo 2: Galois Connection Verification
# ─────────────────────────────────────────────────────────────

def demo_galois():
    """Verify all Galois connection properties on a concrete example."""
    print("\n" + "=" * 60)
    print("DEMO 2: Galois Connection Verification")
    print("=" * 60)

    obs = ObserverFamily({
        "φ₀": [0, 0, 1, 1],
        "φ₁": [0, 1, 0, 1],
    })

    # Generate some relations to test
    eq = equality_relation(4)
    univ = universal_relation(4)
    # Kernel of φ₀
    k0 = obs.kernel("φ₀")

    relations = {"Eq": eq, "Universal": univ, "ker(φ₀)": k0}
    subsets = {
        "∅": frozenset(),
        "{φ₀}": frozenset(["φ₀"]),
        "{φ₁}": frozenset(["φ₁"]),
        "{φ₀, φ₁}": frozenset(["φ₀", "φ₁"]),
    }

    print("\n--- Property 1: R ⊆ I(V(R)) (closure from below) ---")
    for name, R in relations.items():
        V_R = obs.vanishing_set(R)
        IV_R = obs.joint_kernel(V_R)
        holds = R <= IV_R
        print(f"  {name}: R ⊆ I(V(R))? {holds}")

    print("\n--- Property 2: C ⊆ V(I(C)) (closure from above) ---")
    for name, C in subsets.items():
        I_C = obs.joint_kernel(C)
        VI_C = obs.vanishing_set(I_C)
        holds = C <= VI_C
        print(f"  {name}: C ⊆ V(I(C))? {holds}")

    print("\n--- Property 3: V(I(V(R))) = V(R) (first idempotence) ---")
    for name, R in relations.items():
        V_R = obs.vanishing_set(R)
        IV_R = obs.joint_kernel(V_R)
        VIV_R = obs.vanishing_set(IV_R)
        holds = VIV_R == V_R
        print(f"  {name}: V(I(V(R))) = V(R)? {holds}")

    print("\n--- Property 4: I(V(I(C))) = I(C) (second idempotence) ---")
    for name, C in subsets.items():
        I_C = obs.joint_kernel(C)
        VI_C = obs.vanishing_set(I_C)
        IVI_C = obs.joint_kernel(VI_C)
        holds = IVI_C == I_C
        print(f"  {name}: I(V(I(C))) = I(C)? {holds}")


# ─────────────────────────────────────────────────────────────
# Demo 3: Radical and Spectrally Closed Classification
# ─────────────────────────────────────────────────────────────

def demo_radical_closed():
    """Classify all relations/subsets as radical/closed and verify anti-iso."""
    print("\n" + "=" * 60)
    print("DEMO 3: Radical Congruences ↔ Spectrally Closed Sets")
    print("=" * 60)

    obs = ObserverFamily({
        "φ₀": [0, 0, 1, 1],
        "φ₁": [0, 1, 0, 1],
    })

    # Enumerate all radical congruences
    print("\n--- Radical congruences (fixed points of I∘V) ---")
    radical_relations = {}
    # Check equality, universal, and all observer kernels
    test_relations = {
        "Eq": equality_relation(4),
        "Universal": universal_relation(4),
        "ker(φ₀)": obs.kernel("φ₀"),
        "ker(φ₁)": obs.kernel("φ₁"),
    }
    # Also check radicalization of partial relations
    partial = {(0, 1), (1, 0), (0, 0), (1, 1)}  # 0 ~ 1 only
    test_relations["0~1"] = partial

    for name, R in test_relations.items():
        rad = obs.radicalize(R)
        is_rad = R == rad
        print(f"  {name}: radical? {is_rad}")
        if is_rad:
            radical_relations[name] = R
        if not is_rad:
            # Show what the radicalization is
            extra_pairs = [(x, y) for x, y in sorted(rad - R) if x <= y]
            print(f"    rad({name}) adds pairs: {extra_pairs}")

    # Enumerate all spectrally closed subsets
    print("\n--- Spectrally closed subsets (fixed points of V∘I) ---")
    for r in range(obs.m + 1):
        for combo in combinations(obs.names, r):
            C = frozenset(combo)
            is_closed = obs.is_spectrally_closed(C)
            if is_closed:
                print(f"  {set(C)}: spectrally closed ✓")

    # Show the anti-isomorphism
    print("\n--- Anti-isomorphism: V maps radical → closed ---")
    for name, R in radical_relations.items():
        V_R = obs.vanishing_set(R)
        is_closed = obs.is_spectrally_closed(V_R)
        print(f"  V({name}) = {set(V_R)}, spectrally closed? {is_closed}")


# ─────────────────────────────────────────────────────────────
# Demo 4: Compression Certificates
# ─────────────────────────────────────────────────────────────

def demo_compression():
    """Demonstrate compression certificates from spectral structure."""
    print("\n" + "=" * 60)
    print("DEMO 4: Compression Certificates")
    print("=" * 60)

    # Larger example: 3 observers on 8 elements
    obs = ObserverFamily({
        "φ₀": [0, 0, 0, 0, 1, 1, 1, 1],  # high/low bit
        "φ₁": [0, 0, 1, 1, 0, 0, 1, 1],  # middle bit
        "φ₂": [0, 1, 0, 1, 0, 1, 0, 1],  # low bit
    })

    print(f"\nCarrier: {{0, 1, ..., 7}}")
    print(f"Observers: 3 (binary encoding)")
    print(f"Separation: {obs.separates()}")

    # A labeling task: classify even vs odd
    labels = {i: i % 2 for i in range(8)}
    print(f"\nLabeling task: even=0, odd=1")
    print(f"Labels: {labels}")

    # Find which observer realizes this labeling
    for name in obs.names:
        vals = obs.observers[name]
        matches = all(vals[i] == labels[i] for i in range(8))
        if matches:
            print(f"\nObserver {name} realizes this labeling!")
            print(f"  Compression certificate: use {name} directly")
            print(f"  Certificate size: 1 observer")

    # Show minimum separating subfamily
    print(f"\n--- Minimum separating subfamily ---")
    for r in range(1, obs.m + 1):
        for combo in combinations(obs.names, r):
            C = frozenset(combo)
            # Check if C separates all elements
            jk = obs.joint_kernel(C)
            if jk == equality_relation(8):
                print(f"  {set(C)} separates all elements (size {r})")
                break
        else:
            continue
        break

    # Spectral dimension
    min_sep = None
    for r in range(1, obs.m + 1):
        for combo in combinations(obs.names, r):
            C = frozenset(combo)
            jk = obs.joint_kernel(C)
            if jk == equality_relation(8):
                min_sep = r
                break
        if min_sep is not None:
            break
    print(f"\nSpectral dimension (min separating subfamily): {min_sep}")


# ─────────────────────────────────────────────────────────────
# Demo 5: Architecture Complexity
# ─────────────────────────────────────────────────────────────

def demo_architecture():
    """Show how architecture parameters bound spectral dimension."""
    print("\n" + "=" * 60)
    print("DEMO 5: Architecture Complexity Bounds")
    print("=" * 60)

    architectures = [
        {"name": "Shallow-Narrow", "depth": 1, "generators": 2, "width": 2},
        {"name": "Deep-Narrow",    "depth": 4, "generators": 2, "width": 2},
        {"name": "Shallow-Wide",   "depth": 1, "generators": 8, "width": 8},
        {"name": "Deep-Wide",      "depth": 4, "generators": 4, "width": 4},
    ]

    print(f"\n{'Architecture':<18} {'Depth':>6} {'Gens':>6} {'Width':>6} {'Complexity':>12}")
    print("-" * 54)
    for arch in architectures:
        complexity = arch["depth"] * arch["generators"] * arch["width"]
        print(f"{arch['name']:<18} {arch['depth']:>6} {arch['generators']:>6} "
              f"{arch['width']:>6} {complexity:>12}")

    print(f"\nTheorem: spectral dimension ≤ complexity")
    print(f"This bounds the number of independent observational tests")
    print(f"the architecture supports, controlling generalization.")


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════╗")
    print("║  Spectral Learning Theory for Neural Operads: Demo    ║")
    print("║  Prime Congruence Generalization Duality               ║")
    print("╚════════════════════════════════════════════════════════╝")

    demo_basic()
    demo_galois()
    demo_radical_closed()
    demo_compression()
    demo_architecture()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json by reading all deliverables."""
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
lean_code = read_file('Catalog/Bridges/AlgebraMachineLearningSpeculative/PrimeCongruenceGeneralizationDuality.lean')

# Generate an SVG diagram of the Galois connection
svg_diagram = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 400" width="600" height="400">
  <style>
    text { font-family: serif; font-size: 14px; }
    .title { font-size: 18px; font-weight: bold; }
    .label { font-size: 13px; fill: #333; }
    .arrow { stroke: #444; stroke-width: 2; fill: none; marker-end: url(#arrowhead); }
    .box { fill: #f0f4ff; stroke: #3366cc; stroke-width: 2; rx: 8; }
    .box2 { fill: #fff0f0; stroke: #cc3333; stroke-width: 2; rx: 8; }
  </style>
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#444"/>
    </marker>
  </defs>

  <text x="300" y="30" text-anchor="middle" class="title">Observer Spectrum Duality</text>

  <!-- Left side: Congruences -->
  <rect x="30" y="60" width="220" height="280" class="box"/>
  <text x="140" y="85" text-anchor="middle" font-weight="bold">Congruences on S</text>

  <text x="140" y="120" text-anchor="middle" class="label">Universal (⊤)</text>
  <text x="140" y="160" text-anchor="middle" class="label">ker(φ₀): {0,1}~{2,3}</text>
  <text x="140" y="200" text-anchor="middle" class="label">ker(φ₁): {0,2}~{1,3}</text>
  <text x="140" y="260" text-anchor="middle" class="label">Equality (⊥)</text>

  <!-- Ordering lines -->
  <line x1="140" y1="130" x2="110" y2="150" stroke="#999" stroke-width="1"/>
  <line x1="140" y1="130" x2="170" y2="150" stroke="#999" stroke-width="1"/>
  <line x1="110" y1="170" x2="140" y2="245" stroke="#999" stroke-width="1"/>
  <line x1="170" y1="210" x2="140" y2="245" stroke="#999" stroke-width="1"/>

  <!-- Right side: Observer Sets -->
  <rect x="350" y="60" width="220" height="280" class="box2"/>
  <text x="460" y="85" text-anchor="middle" font-weight="bold">Observer Subsets</text>

  <text x="460" y="120" text-anchor="middle" class="label">{φ₀, φ₁} (⊤)</text>
  <text x="460" y="160" text-anchor="middle" class="label">{φ₁}</text>
  <text x="460" y="200" text-anchor="middle" class="label">{φ₀}</text>
  <text x="460" y="260" text-anchor="middle" class="label">∅ (⊥)</text>

  <!-- Ordering lines -->
  <line x1="460" y1="130" x2="430" y2="150" stroke="#999" stroke-width="1"/>
  <line x1="460" y1="130" x2="490" y2="150" stroke="#999" stroke-width="1"/>
  <line x1="430" y1="170" x2="460" y2="245" stroke="#999" stroke-width="1"/>
  <line x1="490" y1="210" x2="460" y2="245" stroke="#999" stroke-width="1"/>

  <!-- V arrows (left to right) -->
  <path d="M 255 118 C 300 108, 330 108, 345 118" class="arrow"/>
  <text x="300" y="105" text-anchor="middle" fill="#3366cc" font-size="12">V</text>

  <path d="M 255 158 C 300 148, 330 198, 345 198" class="arrow"/>
  <path d="M 255 198 C 300 208, 330 158, 345 158" class="arrow"/>

  <path d="M 255 258 C 300 268, 330 268, 345 258" class="arrow"/>

  <!-- I arrows (right to left) -->
  <path d="M 345 128 C 330 138, 300 138, 255 128" class="arrow"/>
  <text x="300" y="145" text-anchor="middle" fill="#cc3333" font-size="12">I</text>

  <!-- Legend -->
  <text x="300" y="380" text-anchor="middle" font-size="12" fill="#666">
    V and I reverse the order: finer congruences ↔ larger observer sets
  </text>
</svg>'''

package = {
    "title": "Spectral Learning Theory for Neural Operads: Prime Congruence Generalization Duality",
    "domain": "Bridges (Algebraic Geometry × Machine Learning × Proof Theory)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Observer Spectrum Duality Demo",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Vanishing Set Computation",
            "pseudocode": """Algorithm: VSet(obs, R)
Input: Observer family obs : ι → S → ℕ, relation R ⊆ S × S
Output: Finset of observer indices whose kernel contains R

1. Initialize result ← ∅
2. For each i ∈ ι:
   a. Set contains ← true
   b. For each (x, y) ∈ R:
      - If obs(i, x) ≠ obs(i, y): set contains ← false; break
   c. If contains: add i to result
3. Return result

Time complexity: O(|ι| × |R|)
Space complexity: O(|ι|)"""
        },
        {
            "name": "Joint Kernel Computation",
            "pseudocode": """Algorithm: JointKer(obs, C)
Input: Observer family obs : ι → S → ℕ, finset C ⊆ ι
Output: Set of pairs (x, y) identified by all observers in C

1. Initialize result ← S × S (universal relation)
2. For each i ∈ C:
   a. For each (x, y) ∈ result:
      - If obs(i, x) ≠ obs(i, y): remove (x, y) from result
3. Return result

Time complexity: O(|C| × |S|²)
Space complexity: O(|S|²)"""
        },
        {
            "name": "Radicalization",
            "pseudocode": """Algorithm: Radicalize(obs, R)
Input: Observer family obs, relation R
Output: rad(R) = I(V(R))

1. Compute V ← VSet(obs, R)
2. Compute rad ← JointKer(obs, V)
3. Return rad

Time complexity: O(|ι| × |S|² + |V| × |S|²)
Space complexity: O(|S|²)"""
        },
        {
            "name": "Minimum Separating Subfamily",
            "pseudocode": """Algorithm: MinSeparatingSubfamily(obs)
Input: Observer family obs : ι → S → ℕ
Output: Minimum-size C ⊆ ι such that JointKer(obs, C) = Eq

1. For k = 1, 2, ..., |ι|:
   a. For each C ⊆ ι with |C| = k:
      - If JointKer(obs, C) = Eq: return C
2. Return ι (full family)

Time complexity: O(Σ_k C(|ι|,k) × k × |S|²) ≤ O(2^|ι| × |ι| × |S|²)
Note: Can be improved with greedy selection: O(|ι|² × |S|²)"""
        }
    ],
    "visualizations": [
        {
            "name": "Galois Connection Diagram",
            "data": svg_diagram
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
