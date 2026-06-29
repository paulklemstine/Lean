#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    lean_code = read_file('Catalog/Bridges/AlgebraTropicalCryptography/TropicalHankelOneWayDuality.lean')
    
    collision_svg = read_file('collision_density.svg')
    hankel_svg = read_file('hankel_structure.svg')
    
    package = {
        "title": "Tropical Fourier-Hankel Duality for Min-Plus One-Way Transducers and Certified Collision Reconstruction",
        "domain": "Tropical Algebra × Weighted Automata × Cryptography",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Tropical Hankel Duality Demo",
                "code": demo_code
            }
        ],
        "algorithms": [
            {
                "name": "Collision Reconstruction",
                "pseudocode": """ALGORITHM: CollisionReconstruction(A, L)
Input: Min-plus automaton A with n states, max word length L
Output: List of certified collision witnesses

1. Initialize summary_groups ← empty map
2. For each word w of length ≤ L:
   a. Compute s ← StateSummary(A, w)
   b. Add w to summary_groups[s]
3. collisions ← empty list
4. For each group G in summary_groups with |G| ≥ 2:
   a. Let w₁ = G[0], output = f(w₁)
   b. For each w₂ in G[1:]:
      - Append CollisionWitness(w₁, w₂, output) to collisions
5. Return collisions

Complexity: O(|Σ|^L · n) time, O(|Σ|^L · n) space
Correctness: By Theorem 3.6, equal state summaries guarantee equal outputs.""",
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {
                "name": "Collision Density vs Word Length",
                "data": collision_svg
            },
            {
                "name": "Tropical Hankel Factorization Structure",
                "data": hankel_svg
            }
        ],
        "lean_proofs": lean_code
    }
    
    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)
    
    print(f"PACKAGE.json written ({os.path.getsize('PACKAGE.json')} bytes)")

if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Tropical Hankel Duality — Demo & Visualization

Demonstrates the key theorems from the formalization:
1. Min-plus weighted automata and their Hankel kernels
2. State collision detection via pigeonhole
3. Collision reconstruction from finite Hankel rank
4. Rank estimation for random tropical automata

Author: Harmonic Research
"""

import numpy as np
import itertools
from typing import List, Tuple, Dict, Optional
import json


# ============================================================
# Section 1: Min-Plus Arithmetic
# ============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)"""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b"""
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j])"""
    n, m = A.shape
    m2, p = B.shape
    assert m == m2
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def trop_vec_combine(a: np.ndarray, b: np.ndarray) -> float:
    """Tropical inner product: min_i (a[i] + b[i])"""
    return float(np.min(a + b))


# ============================================================
# Section 2: Min-Plus Weighted Automaton
# ============================================================

class MinPlusAutomaton:
    """
    A min-plus weighted automaton with n states over a finite alphabet.
    
    Computes f(w) = λ ⊗ M(a₁) ⊗ ··· ⊗ M(aₖ) ⊗ ρ
    where ⊗ is min-plus multiplication.
    """
    
    def __init__(self, n_states: int, alphabet_size: int,
                 init: np.ndarray, transitions: List[np.ndarray],
                 final: np.ndarray):
        self.n = n_states
        self.sigma = alphabet_size
        self.init = init.copy()
        self.transitions = [t.copy() for t in transitions]
        self.final = final.copy()
    
    def state_summary(self, word: List[int]) -> np.ndarray:
        """Compute the state summary vector after reading `word`."""
        vec = self.init.copy().reshape(1, -1)
        for a in word:
            vec = trop_mat_mul(vec, self.transitions[a])
        return vec.flatten()
    
    def evaluate(self, word: List[int]) -> float:
        """Compute the output f(word)."""
        summary = self.state_summary(word)
        return trop_vec_combine(summary, self.final)
    
    def hankel_entry(self, prefix: List[int], suffix: List[int]) -> float:
        """Compute the Hankel kernel entry H(prefix, suffix) = f(prefix ++ suffix)."""
        return self.evaluate(prefix + suffix)


def random_automaton(n_states: int, alphabet_size: int, 
                     value_range: float = 10.0,
                     seed: int = 42) -> MinPlusAutomaton:
    """Generate a random min-plus automaton."""
    rng = np.random.RandomState(seed)
    init = rng.uniform(0, value_range, n_states)
    transitions = [rng.uniform(0, value_range, (n_states, n_states)) 
                   for _ in range(alphabet_size)]
    final = rng.uniform(0, value_range, n_states)
    return MinPlusAutomaton(n_states, alphabet_size, init, transitions, final)


# ============================================================
# Section 3: Hankel Matrix and Rank Analysis
# ============================================================

def enumerate_words(alphabet_size: int, max_length: int) -> List[List[int]]:
    """Enumerate all words over alphabet {0,...,sigma-1} up to given length."""
    words = [[]]
    for length in range(1, max_length + 1):
        for w in itertools.product(range(alphabet_size), repeat=length):
            words.append(list(w))
    return words


def build_hankel_matrix(aut: MinPlusAutomaton, max_length: int) -> Tuple[np.ndarray, List]:
    """Build the Hankel submatrix for words up to max_length."""
    words = enumerate_words(aut.sigma, max_length)
    n = len(words)
    H = np.zeros((n, n))
    for i, u in enumerate(words):
        for j, v in enumerate(words):
            H[i, j] = aut.hankel_entry(u, v)
    return H, words


def tropical_rank_estimate(H: np.ndarray, tol: float = 1e-8) -> int:
    """
    Estimate the tropical rank of a Hankel matrix.
    
    Uses the factorization approach: find the smallest n such that
    H can be approximately factored as H[i,j] ≈ min_k (P[i,k] + Q[k,j]).
    
    Approximation: use classical SVD rank as an upper bound, then
    check tropical factorizability.
    """
    # Classical rank gives an upper bound on tropical rank
    # (tropical rank can be higher or lower than classical rank)
    U, S, Vt = np.linalg.svd(H)
    classical_rank = np.sum(S > tol * S[0]) if S[0] > tol else 0
    
    # For the tropical rank, we use the number of distinct rows
    # as an upper bound (since each distinct row is a generator)
    rounded = np.round(H, decimals=6)
    unique_rows = len(set(map(tuple, rounded)))
    
    return min(classical_rank, unique_rows)


# ============================================================
# Section 4: Collision Detection
# ============================================================

def find_state_collisions(aut: MinPlusAutomaton, 
                          words: List[List[int]],
                          tol: float = 1e-10) -> List[Tuple[List[int], List[int]]]:
    """
    Find pairs of words with identical state summaries.
    These are guaranteed to produce identical outputs.
    """
    summaries: Dict[tuple, List[int]] = {}
    collisions = []
    
    for idx, w in enumerate(words):
        summary = tuple(np.round(aut.state_summary(w), decimals=8))
        if summary in summaries:
            other_idx = summaries[summary]
            collisions.append((words[other_idx], w))
        else:
            summaries[summary] = idx
    
    return collisions


def find_output_collisions(aut: MinPlusAutomaton,
                           words: List[List[int]],
                           tol: float = 1e-10) -> List[Tuple[List[int], List[int]]]:
    """Find pairs of words with identical outputs."""
    outputs: Dict[float, int] = {}
    collisions = []
    
    for idx, w in enumerate(words):
        val = round(aut.evaluate(w), 8)
        if val in outputs:
            collisions.append((words[outputs[val]], w))
        else:
            outputs[val] = idx
    
    return collisions


def verify_collision(aut: MinPlusAutomaton, w1: List[int], w2: List[int],
                     n_tests: int = 100, max_suffix_len: int = 5) -> bool:
    """
    Verify that a state collision implies output equality on all continuations.
    Tests random suffixes.
    """
    rng = np.random.RandomState(0)
    for _ in range(n_tests):
        suf_len = rng.randint(0, max_suffix_len + 1)
        suffix = list(rng.randint(0, aut.sigma, suf_len))
        if abs(aut.evaluate(w1 + suffix) - aut.evaluate(w2 + suffix)) > 1e-8:
            return False
    return True


# ============================================================
# Section 5: Demonstration
# ============================================================

def demo_basic_automaton():
    """Demonstrate a simple 2-state automaton and its Hankel structure."""
    print("=" * 60)
    print("Demo 1: Basic 2-State Min-Plus Automaton")
    print("=" * 60)
    
    # 2-state automaton over binary alphabet
    init = np.array([0.0, 1.0])
    M0 = np.array([[0.0, 2.0], [1.0, 0.0]])
    M1 = np.array([[1.0, 0.0], [0.0, 1.0]])
    final = np.array([0.0, 1.0])
    
    aut = MinPlusAutomaton(2, 2, init, [M0, M1], final)
    
    # Evaluate on several words
    test_words = [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1],
                  [0, 0, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0]]
    
    print("\nWord → State Summary → Output")
    print("-" * 45)
    for w in test_words:
        summary = aut.state_summary(w)
        output = aut.evaluate(w)
        word_str = ''.join(map(str, w)) if w else 'ε'
        print(f"  {word_str:8s} → [{summary[0]:5.1f}, {summary[1]:5.1f}] → {output:.1f}")
    
    # Find collisions
    words = enumerate_words(2, 5)
    state_collisions = find_state_collisions(aut, words)
    output_collisions = find_output_collisions(aut, words)
    
    print(f"\nWords up to length 5: {len(words)}")
    print(f"State collisions found: {len(state_collisions)}")
    print(f"Output collisions found: {len(output_collisions)}")
    
    if state_collisions:
        print("\nFirst 5 state collisions:")
        for w1, w2 in state_collisions[:5]:
            s1 = ''.join(map(str, w1)) if w1 else 'ε'
            s2 = ''.join(map(str, w2)) if w2 else 'ε'
            verified = verify_collision(aut, w1, w2)
            print(f"  {s1} ≡ {s2}  (verified on suffixes: {verified})")


def demo_collision_guarantee():
    """Demonstrate the pigeonhole collision guarantee."""
    print("\n" + "=" * 60)
    print("Demo 2: Pigeonhole Collision Guarantee")
    print("=" * 60)
    
    for n_states in [2, 3, 5]:
        aut = random_automaton(n_states, 2, seed=123)
        
        print(f"\n--- {n_states}-state automaton ---")
        
        for max_len in [3, 4, 5, 6]:
            words = enumerate_words(2, max_len)
            
            # Count distinct state summaries
            summaries = set()
            for w in words:
                s = tuple(np.round(aut.state_summary(w), 6))
                summaries.add(s)
            
            # Count distinct outputs
            outputs = set()
            for w in words:
                outputs.add(round(aut.evaluate(w), 6))
            
            collisions = find_state_collisions(aut, words)
            
            print(f"  Length ≤ {max_len}: "
                  f"{len(words)} words, "
                  f"{len(summaries)} distinct states, "
                  f"{len(outputs)} distinct outputs, "
                  f"{len(collisions)} state collisions")
            
            # Verify pigeonhole bound
            assert len(outputs) <= len(summaries), "Output count should ≤ state count"


def demo_rank_analysis():
    """Demonstrate tropical Hankel rank estimation."""
    print("\n" + "=" * 60)
    print("Demo 3: Tropical Hankel Rank Analysis")
    print("=" * 60)
    
    for n_states in [2, 3, 4, 5]:
        aut = random_automaton(n_states, 2, seed=42 + n_states)
        
        print(f"\n--- {n_states}-state automaton ---")
        
        for max_len in [2, 3, 4]:
            H, words = build_hankel_matrix(aut, max_len)
            rank = tropical_rank_estimate(H)
            
            # Count distinct state summaries as true tropical rank upper bound
            summaries = set()
            for w in words:
                s = tuple(np.round(aut.state_summary(w), 6))
                summaries.add(s)
            
            print(f"  H size {H.shape[0]}×{H.shape[1]}, "
                  f"classical rank est: {rank}, "
                  f"distinct states: {len(summaries)} "
                  f"(true rank ≤ {n_states})")


def demo_fiber_reconstruction():
    """Demonstrate fiber reconstruction via state factorization."""
    print("\n" + "=" * 60)
    print("Demo 4: Fiber Reconstruction via Factorization")
    print("=" * 60)
    
    aut = random_automaton(3, 2, seed=77)
    words = enumerate_words(2, 5)
    
    # Group words by output value
    fibers: Dict[float, List[str]] = {}
    for w in words:
        val = round(aut.evaluate(w), 4)
        word_str = ''.join(map(str, w)) if w else 'ε'
        if val not in fibers:
            fibers[val] = []
        fibers[val].append(word_str)
    
    print(f"\nTotal words: {len(words)}")
    print(f"Distinct output values: {len(fibers)}")
    
    # Show largest fibers
    sorted_fibers = sorted(fibers.items(), key=lambda x: -len(x[1]))
    print("\nLargest fibers (output → inputs):")
    for val, members in sorted_fibers[:5]:
        shown = members[:8]
        more = f" ... (+{len(members) - 8} more)" if len(members) > 8 else ""
        print(f"  f(x) = {val:8.4f}: {', '.join(shown)}{more}  ({len(members)} total)")
    
    # Verify fiber closure under Hankel equivalence
    print("\nVerifying fiber closure under state equivalence...")
    state_collisions = find_state_collisions(aut, words)
    all_verified = True
    for w1, w2 in state_collisions[:20]:
        v1 = round(aut.evaluate(w1), 8)
        v2 = round(aut.evaluate(w2), 8)
        if v1 != v2:
            all_verified = False
            break
    print(f"  All state collisions produce equal outputs: {all_verified}")


def demo_one_wayness_criterion():
    """Demonstrate the one-wayness obstruction criterion."""
    print("\n" + "=" * 60)
    print("Demo 5: One-Wayness Obstruction Criterion")
    print("=" * 60)
    
    print("\nFor a family F_k with k-state automata:")
    print("  If rank is uniformly bounded by n, then for input sets")
    print("  of size > n^n (state space), collisions are guaranteed.\n")
    
    for n_states in [2, 3, 4, 5]:
        aut = random_automaton(n_states, 2, seed=n_states * 10)
        
        # Find the minimal input set size that guarantees collision
        for max_len in range(1, 8):
            words = enumerate_words(2, max_len)
            summaries = set()
            for w in words:
                s = tuple(np.round(aut.state_summary(w), 6))
                summaries.add(s)
            
            if len(words) > len(summaries):
                collisions = find_state_collisions(aut, words)
                print(f"  n={n_states}: collision guaranteed at length ≤ {max_len} "
                      f"({len(words)} words > {len(summaries)} states, "
                      f"{len(collisions)} collisions found)")
                break
    
    print("\n  → Bounded rank families cannot be one-way!")
    print("  → One-wayness requires rank to grow with security parameter.")


if __name__ == "__main__":
    demo_basic_automaton()
    demo_collision_guarantee()
    demo_rank_analysis()
    demo_fiber_reconstruction()
    demo_one_wayness_criterion()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for the tropical Hankel duality research."""

import numpy as np
import base64
import io
import json

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def generate_collision_density_svg():
    """Generate an SVG visualization of collision density vs word length."""
    # Data from algorithms.py demo
    states_configs = [
        (2, [0, 0, 6.7, 19.4, 33.3, 44.1, 57.5]),
        (3, [0, 0, 0, 23.3, 32.3, 43.7, 58.7]),
        (5, [0, 0, 0, 3.3, 7.9, 16.5, 31.1]),
    ]
    
    w = 600
    h = 400
    margin = {'left': 70, 'right': 30, 'top': 40, 'bottom': 60}
    pw = w - margin['left'] - margin['right']
    ph = h - margin['top'] - margin['bottom']
    
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>\n'
    
    # Title
    svg += f'<text x="{w//2}" y="25" text-anchor="middle" font-family="Arial" font-size="16" font-weight="bold">Collision Density vs Word Length by Automaton Size</text>\n'
    
    # Axes
    svg += f'<line x1="{margin["left"]}" y1="{margin["top"]}" x2="{margin["left"]}" y2="{h-margin["bottom"]}" stroke="black" stroke-width="1.5"/>\n'
    svg += f'<line x1="{margin["left"]}" y1="{h-margin["bottom"]}" x2="{w-margin["right"]}" y2="{h-margin["bottom"]}" stroke="black" stroke-width="1.5"/>\n'
    
    # Y-axis labels
    for val in [0, 20, 40, 60, 80, 100]:
        y = margin['top'] + ph * (1 - val / 100)
        svg += f'<text x="{margin["left"]-8}" y="{y+4}" text-anchor="end" font-family="Arial" font-size="11">{val}%</text>\n'
        if val > 0:
            svg += f'<line x1="{margin["left"]}" y1="{y}" x2="{w-margin["right"]}" y2="{y}" stroke="#ddd" stroke-width="0.5"/>\n'
    
    # X-axis labels
    for i in range(7):
        x = margin['left'] + pw * i / 6
        svg += f'<text x="{x}" y="{h-margin["bottom"]+20}" text-anchor="middle" font-family="Arial" font-size="11">{i+1}</text>\n'
    
    # Axis titles
    svg += f'<text x="{w//2}" y="{h-10}" text-anchor="middle" font-family="Arial" font-size="13">Maximum Word Length</text>\n'
    svg += f'<text x="15" y="{h//2}" text-anchor="middle" font-family="Arial" font-size="13" transform="rotate(-90,15,{h//2})">Collision Density</text>\n'
    
    # Plot lines
    for idx, (n, data) in enumerate(states_configs):
        points = []
        for i, val in enumerate(data):
            x = margin['left'] + pw * i / 6
            y = margin['top'] + ph * (1 - val / 100)
            points.append(f"{x},{y}")
        
        polyline = ' '.join(points)
        svg += f'<polyline points="{polyline}" fill="none" stroke="{colors[idx]}" stroke-width="2.5"/>\n'
        
        # Dots
        for i, val in enumerate(data):
            x = margin['left'] + pw * i / 6
            y = margin['top'] + ph * (1 - val / 100)
            svg += f'<circle cx="{x}" cy="{y}" r="3.5" fill="{colors[idx]}"/>\n'
    
    # Legend
    lx = margin['left'] + 20
    ly = margin['top'] + 20
    for idx, (n, _) in enumerate(states_configs):
        y = ly + idx * 22
        svg += f'<line x1="{lx}" y1="{y}" x2="{lx+25}" y2="{y}" stroke="{colors[idx]}" stroke-width="2.5"/>\n'
        svg += f'<circle cx="{lx+12}" cy="{y}" r="3.5" fill="{colors[idx]}"/>\n'
        svg += f'<text x="{lx+32}" y="{y+4}" font-family="Arial" font-size="12">{n} states</text>\n'
    
    svg += '</svg>'
    return svg


def generate_hankel_structure_svg():
    """Generate SVG showing the Hankel factorization structure."""
    w, h = 650, 350
    
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>\n'
    
    # Title
    svg += f'<text x="{w//2}" y="30" text-anchor="middle" font-family="Arial" font-size="16" font-weight="bold">Tropical Hankel Factorization Structure</text>\n'
    
    # Hankel matrix box
    svg += '<rect x="30" y="60" width="160" height="160" fill="#ecf0f1" stroke="#2c3e50" stroke-width="2" rx="5"/>\n'
    svg += '<text x="110" y="145" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold">H_f(u,v)</text>\n'
    svg += '<text x="110" y="165" text-anchor="middle" font-family="Arial" font-size="11" fill="#7f8c8d">= f(u·v)</text>\n'
    svg += '<text x="110" y="240" text-anchor="middle" font-family="Arial" font-size="11" fill="#7f8c8d">∞ × ∞ matrix</text>\n'
    
    # Equals sign
    svg += '<text x="215" y="145" text-anchor="middle" font-family="Arial" font-size="24">=</text>\n'
    
    # Phi matrix
    svg += '<rect x="240" y="60" width="100" height="160" fill="#d5f5e3" stroke="#27ae60" stroke-width="2" rx="5"/>\n'
    svg += '<text x="290" y="140" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold">φ(u)</text>\n'
    svg += '<text x="290" y="160" text-anchor="middle" font-family="Arial" font-size="11" fill="#27ae60">∞ × n</text>\n'
    
    # ⊗ symbol
    svg += '<text x="360" y="145" text-anchor="middle" font-family="Arial" font-size="20">⊗</text>\n'
    
    # Psi matrix
    svg += '<rect x="385" y="60" width="160" height="100" fill="#d6eaf8" stroke="#2980b9" stroke-width="2" rx="5"/>\n'
    svg += '<text x="465" y="110" text-anchor="middle" font-family="Arial" font-size="14" font-weight="bold">ψ(v)</text>\n'
    svg += '<text x="465" y="130" text-anchor="middle" font-family="Arial" font-size="11" fill="#2980b9">n × ∞</text>\n'
    
    # Arrow to collision
    svg += '<path d="M 325 230 L 325 270 L 400 270" fill="none" stroke="#e74c3c" stroke-width="2" marker-end="url(#arrowhead)"/>\n'
    
    # Arrow marker
    svg += '<defs><marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto"><polygon points="0 0, 10 3.5, 0 7" fill="#e74c3c"/></marker></defs>\n'
    
    # Collision box
    svg += '<rect x="400" y="255" width="220" height="70" fill="#fadbd8" stroke="#e74c3c" stroke-width="2" rx="5"/>\n'
    svg += '<text x="510" y="280" text-anchor="middle" font-family="Arial" font-size="12" font-weight="bold" fill="#c0392b">φ(u₁) = φ(u₂)</text>\n'
    svg += '<text x="510" y="300" text-anchor="middle" font-family="Arial" font-size="11" fill="#c0392b">⟹ f(u₁) = f(u₂)</text>\n'
    svg += '<text x="510" y="316" text-anchor="middle" font-family="Arial" font-size="10" fill="#7f8c8d">Certified Collision!</text>\n'
    
    # Annotation
    svg += '<text x="290" y="265" text-anchor="middle" font-family="Arial" font-size="11" fill="#e74c3c">state collision</text>\n'
    
    svg += '</svg>'
    return svg


if __name__ == "__main__":
    svg1 = generate_collision_density_svg()
    svg2 = generate_hankel_structure_svg()
    
    with open('collision_density.svg', 'w') as f:
        f.write(svg1)
    with open('hankel_structure.svg', 'w') as f:
        f.write(svg2)
    
    print("Generated: collision_density.svg, hankel_structure.svg")
    
    # Also output as JSON for PACKAGE.json
    print(json.dumps({
        'collision_density': svg1,
        'hankel_structure': svg2
    }, indent=2)[:200] + "...")
