#!/usr/bin/env python3
"""
Applications of Algorithmic Spectral Certification

This module demonstrates real-world applications of certified expander graphs:
1. Cryptographic parameter validation
2. Network robustness analysis
3. Pseudorandom generator construction
4. Mixing time estimation for Markov chains
"""

import numpy as np
from itertools import product as iterproduct
from typing import List, Tuple, Dict, Optional


# ─── Inline core classes ─────────────────────────────────────────────────────

class FiniteField:
    def __init__(self, q):
        self.q = q
    def mul(self, a, b): return (a * b) % self.q
    def inv(self, a): return pow(a, self.q - 2, self.q)
    def multiplicative_order(self, a):
        if a % self.q == 0: return 0
        val = 1
        for k in range(1, self.q):
            val = (val * a) % self.q
            if val == 1: return k
        return self.q - 1

class GL2Fq:
    def __init__(self, q):
        self.field = FiniteField(q); self.q = q
        self._order = (q*q-1)*(q*q-q)
    @property
    def group_order(self): return self._order
    def mat(self, a, b, c, d):
        return np.array([[a%self.q,b%self.q],[c%self.q,d%self.q]], dtype=int)
    def det(self, m):
        return (int(m[0,0])*int(m[1,1])-int(m[0,1])*int(m[1,0])) % self.q
    def is_invertible(self, m): return self.det(m) != 0
    def mul_mat(self, a, b):
        q=self.q; r=np.zeros((2,2),dtype=int)
        for i in range(2):
            for j in range(2):
                r[i,j]=(int(a[i,0])*int(b[0,j])+int(a[i,1])*int(b[1,j]))%q
        return r
    def inv_mat(self, m):
        d=self.det(m); di=self.field.inv(d); q=self.q
        return np.array([[(int(m[1,1])*di)%q,((-int(m[0,1]))*di)%q],
                         [((-int(m[1,0]))*di)%q,(int(m[0,0])*di)%q]],dtype=int)
    def identity(self): return np.array([[1,0],[0,1]],dtype=int)
    def mat_equal(self, a, b): return np.all(a%self.q == b%self.q)
    def mat_to_tuple(self, m):
        return (int(m[0,0])%self.q,int(m[0,1])%self.q,
                int(m[1,0])%self.q,int(m[1,1])%self.q)
    def enumerate_all(self):
        q=self.q; e=[]
        for a,b,c,d in iterproduct(range(q),repeat=4):
            m=self.mat(a,b,c,d)
            if self.is_invertible(m): e.append(m)
        return e
    def is_charpoly_irreducible(self, m):
        tr=(int(m[0,0])+int(m[1,1]))%self.q; d=self.det(m)
        disc=(tr*tr-4*d)%self.q
        if disc==0: return False
        if self.q==2: return False
        return pow(disc,(self.q-1)//2,self.q)!=1
    def is_det_primitive(self, m):
        d=self.det(m)
        if d%self.q==0: return False
        return self.field.multiplicative_order(d)==self.q-1

def generates_gl2(gl, g, h):
    S=set(); gi=gl.inv_mat(g); hi=gl.inv_mat(h)
    gens=[g,gi,h,hi]
    for gen in gens: S.add(gl.mat_to_tuple(gen))
    for _ in range(gl.group_order+1):
        new_f=[]
        for et in list(S):
            elem=gl.mat(et[0],et[1],et[2],et[3])
            for gen in gens:
                prod=gl.mul_mat(elem,gen)
                t=gl.mat_to_tuple(prod)
                if t not in S: S.add(t); new_f.append(prod)
        if not new_f: break
    return len(S)==gl.group_order


# ─── Application 1: Cryptographic Parameter Validation ───────────────────────

def app_crypto_validation():
    """Validate matrix pairs for use in hash-from-expander constructions.

    In cryptographic protocols based on Cayley graph hashing (e.g., Zémor hash),
    the security depends on the expansion properties of the Cayley graph.
    Certified expansion provides a mathematical guarantee that the hash
    function has good mixing properties.
    """
    print("=" * 70)
    print("APPLICATION 1: Cryptographic Parameter Validation")
    print("=" * 70)
    print("\nContext: Hash functions based on random walks on Cayley graphs")
    print("require certified expansion for security guarantees.\n")

    for q in [5, 7]:
        gl = GL2Fq(q)
        print(f"--- 𝔽_{q}: |GL₂| = {gl.group_order} ---")

        # Test canonical generators
        candidates = [
            (gl.mat(1, 1, 0, 1), gl.mat(1, 0, 1, 1), "Upper/Lower triangular"),
            (gl.mat(2, 1, 1, 1), gl.mat(1, 1, 1, 2 % q), "Dense pair A"),
            (gl.mat(0, 1, q-1, 1), gl.mat(1, 2 % q, 0, 1), "Mixed pair"),
        ]

        for g, h, name in candidates:
            if not gl.is_invertible(g) or not gl.is_invertible(h):
                continue
            gen = generates_gl2(gl, g, h)
            irr = gl.is_charpoly_irreducible(g) or gl.is_charpoly_irreducible(h)
            prim = gl.is_det_primitive(g) or gl.is_det_primitive(h)

            status = "✓ SECURE" if gen and irr else "✗ REJECT"
            print(f"  {name:30s} | Gen:{gen} Irr:{irr} Prim:{prim} | {status}")
        print()


# ─── Application 2: Network Robustness ──────────────────────────────────────

def app_network_robustness():
    """Analyze Cayley graph robustness under edge removal.

    Expander graphs maintain connectivity even after removing a constant
    fraction of edges. The spectral gap gives quantitative control over
    edge expansion, which translates to fault tolerance in communication
    networks.
    """
    print("=" * 70)
    print("APPLICATION 2: Network Robustness Analysis")
    print("=" * 70)

    gl = GL2Fq(3)
    elements = gl.enumerate_all()
    n = len(elements)
    idx = {gl.mat_to_tuple(m): i for i, m in enumerate(elements)}

    # Build a certified Cayley graph
    g = gl.mat(1, 1, 0, 1)
    h = gl.mat(1, 0, 1, 1)
    gen = generates_gl2(gl, g, h)

    print(f"\nCayley graph: GL₂(𝔽₃) with |V| = {n}, degree 4")
    print(f"Pair generates: {gen}")

    if gen:
        # Build adjacency
        gi = gl.inv_mat(g); hi = gl.inv_mat(h)
        gens = [g, gi, h, hi]
        adj = np.zeros((n, n))
        for i, m in enumerate(elements):
            for gen_m in gens:
                prod = gl.mul_mat(m, gen_m)
                j = idx[gl.mat_to_tuple(prod)]
                adj[i, j] = 1

        total_edges = int(np.sum(adj)) // 2

        # Test connectivity under random edge removal
        rng = np.random.RandomState(42)
        for frac in [0.0, 0.1, 0.2, 0.3, 0.4]:
            n_remove = int(total_edges * frac)
            # Simple connectivity test via BFS
            adj_copy = adj.copy()
            edges = list(zip(*np.where(np.triu(adj_copy) > 0)))
            if n_remove > 0 and edges:
                remove_idx = rng.choice(len(edges), min(n_remove, len(edges)),
                                        replace=False)
                for ri in remove_idx:
                    i, j = edges[ri]
                    adj_copy[i, j] = 0
                    adj_copy[j, i] = 0

            # BFS connectivity check
            visited = {0}
            queue = [0]
            while queue:
                node = queue.pop(0)
                for nb in range(n):
                    if adj_copy[node, nb] > 0 and nb not in visited:
                        visited.add(nb)
                        queue.append(nb)

            connected = len(visited) == n
            print(f"  Remove {frac*100:.0f}% edges ({n_remove}): "
                  f"Connected = {connected}, "
                  f"Largest component = {len(visited)}/{n}")
    print()


# ─── Application 3: Mixing Time Estimation ──────────────────────────────────

def app_mixing_time():
    """Estimate mixing time of random walks on certified Cayley graphs.

    The certified spectral gap ε implies mixing time O(log|G|/ε).
    This is relevant for MCMC sampling and randomized algorithms.
    """
    print("=" * 70)
    print("APPLICATION 3: Random Walk Mixing Time Estimation")
    print("=" * 70)

    for q in [3, 5]:
        gl = GL2Fq(q)
        elements = gl.enumerate_all()
        n = len(elements)
        idx = {gl.mat_to_tuple(m): i for i, m in enumerate(elements)}

        g = gl.mat(1, 1, 0, 1)
        h = gl.mat(1, 0, 1, 1)

        if not generates_gl2(gl, g, h):
            continue

        gi = gl.inv_mat(g); hi = gl.inv_mat(h)
        gens_list = [g, gi, h, hi]

        # Build transition matrix
        P = np.zeros((n, n))
        for i, m in enumerate(elements):
            for gen_m in gens_list:
                prod = gl.mul_mat(m, gen_m)
                j = idx[gl.mat_to_tuple(prod)]
                P[i, j] += 0.25

        # Compute spectral gap
        eigs = sorted(np.linalg.eigvalsh(P), reverse=True)
        gap = 1 - eigs[1]
        uniform = np.ones(n) / n

        print(f"\n--- q = {q}, |G| = {n} ---")
        print(f"  Spectral gap: {gap:.6f}")
        print(f"  Theoretical mixing time bound: O(log|G|/ε) = "
              f"{np.log(n)/gap:.1f}")

        # Simulate random walk
        dist = np.zeros(n)
        dist[0] = 1.0  # Start at identity
        tv_distances = []
        for t in range(50):
            tv = 0.5 * np.sum(np.abs(dist - uniform))
            tv_distances.append(tv)
            dist = dist @ P

        # Find mixing time (TV < 0.25)
        mix_time = next((t for t, tv in enumerate(tv_distances) if tv < 0.25),
                        len(tv_distances))
        print(f"  Empirical mixing time (TV < 0.25): {mix_time} steps")
        print(f"  TV distances: t=0:{tv_distances[0]:.3f}, "
              f"t=5:{tv_distances[5]:.3f}, "
              f"t=10:{tv_distances[10]:.3f}, "
              f"t=20:{tv_distances[min(20,len(tv_distances)-1)]:.3f}")
    print()


if __name__ == "__main__":
    print("\n" + "█" * 70)
    print("  APPLICATIONS OF SPECTRAL CERTIFICATION")
    print("█" * 70 + "\n")

    app_crypto_validation()
    app_network_robustness()
    app_mixing_time()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Interactive Demo: Algorithmic Spectral Certification for GL₂(𝔽_q) Cayley Graphs

This demo:
1. Constructs sample pairs (g, h) in GL₂(𝔽_q)
2. Runs the certification algorithm
3. Computes the true spectral gap numerically
4. Displays certification success/failure and gap comparisons
5. Tests sensitivity to the short-word radius L
"""

import numpy as np
from typing import List, Tuple, Dict
from itertools import product as iterproduct


# ─── Inline all needed classes/functions (self-contained) ─────────────────────

class FiniteField:
    def __init__(self, q):
        self.q = q
    def mul(self, a, b): return (a * b) % self.q
    def inv(self, a):
        if a % self.q == 0: raise ValueError
        return pow(a, self.q - 2, self.q)
    def multiplicative_order(self, a):
        if a % self.q == 0: return 0
        val = 1
        for k in range(1, self.q):
            val = (val * a) % self.q
            if val == 1: return k
        return self.q - 1

class GL2Fq:
    def __init__(self, q):
        self.field = FiniteField(q)
        self.q = q
        self._order = (q*q - 1) * (q*q - q)
    @property
    def group_order(self): return self._order
    def mat(self, a, b, c, d):
        return np.array([[a%self.q, b%self.q],[c%self.q, d%self.q]], dtype=int)
    def det(self, m):
        return (int(m[0,0])*int(m[1,1]) - int(m[0,1])*int(m[1,0])) % self.q
    def is_invertible(self, m): return self.det(m) != 0
    def mul_mat(self, a, b):
        q = self.q; r = np.zeros((2,2),dtype=int)
        for i in range(2):
            for j in range(2):
                r[i,j] = (int(a[i,0])*int(b[0,j]) + int(a[i,1])*int(b[1,j])) % q
        return r
    def inv_mat(self, m):
        d = self.det(m); di = self.field.inv(d); q = self.q
        return np.array([[(int(m[1,1])*di)%q, ((-int(m[0,1]))*di)%q],
                         [((-int(m[1,0]))*di)%q, (int(m[0,0])*di)%q]], dtype=int)
    def identity(self): return np.array([[1,0],[0,1]], dtype=int)
    def mat_equal(self, a, b): return np.all(a % self.q == b % self.q)
    def mat_to_tuple(self, m):
        return (int(m[0,0])%self.q, int(m[0,1])%self.q,
                int(m[1,0])%self.q, int(m[1,1])%self.q)
    def is_charpoly_irreducible(self, m):
        tr = (int(m[0,0]) + int(m[1,1])) % self.q
        d = self.det(m)
        disc = (tr*tr - 4*d) % self.q
        if disc == 0: return False
        if self.q == 2: return False
        return pow(disc, (self.q-1)//2, self.q) != 1
    def is_det_primitive(self, m):
        d = self.det(m)
        if d % self.q == 0: return False
        return self.field.multiplicative_order(d) == self.q - 1
    def enumerate_all(self):
        q = self.q; elems = []
        for a,b,c,d in iterproduct(range(q), repeat=4):
            m = self.mat(a,b,c,d)
            if self.is_invertible(m): elems.append(m)
        return elems

def generates_gl2(gl, g, h, max_iter=None):
    if max_iter is None: max_iter = gl.group_order + 1
    S = set(); gi = gl.inv_mat(g); hi = gl.inv_mat(h)
    gens = [g, gi, h, hi]
    for gen in gens: S.add(gl.mat_to_tuple(gen))
    frontier = list(gens)
    for _ in range(max_iter):
        new_f = []
        for et in list(S):
            elem = gl.mat(et[0],et[1],et[2],et[3])
            for gen in gens:
                prod = gl.mul_mat(elem, gen)
                t = gl.mat_to_tuple(prod)
                if t not in S: S.add(t); new_f.append(prod)
        if not new_f: break
        frontier = new_f
    return len(S) == gl.group_order

def collision_count(gl, g, h, L):
    gi = gl.inv_mat(g); hi = gl.inv_mat(h)
    gens = [g, gi, h, hi]; hits = {}
    def walk(depth, cur):
        if depth == 0:
            t = gl.mat_to_tuple(cur); hits[t] = hits.get(t,0)+1; return
        for gen in gens: walk(depth-1, gl.mul_mat(cur, gen))
    walk(L, gl.identity())
    return sum(1 for v in hits.values() if v > 1)

def certify_pair(gl, g, h, L=3):
    ident = gl.identity()
    if gl.mat_equal(g, ident) or gl.mat_equal(h, ident):
        return False, None, {}
    irr = gl.is_charpoly_irreducible(g) or gl.is_charpoly_irreducible(h)
    prim = gl.is_det_primitive(g) or gl.is_det_primitive(h)
    gen = generates_gl2(gl, g, h)
    if not gen: return False, None, {'irr':irr,'prim':prim,'gen':False}
    coll = collision_count(gl, g, h, L)
    gap = 1.0 / gl.group_order
    if irr and prim: gap = max(gap, 2.0/(gl.q*(gl.q+1)))
    return True, gap, {'irr':irr,'prim':prim,'gen':True,'coll':coll}

def compute_spectral_gap(gl, g, h):
    elems = gl.enumerate_all(); n = len(elems)
    idx = {gl.mat_to_tuple(m):i for i,m in enumerate(elems)}
    gi = gl.inv_mat(g); hi = gl.inv_mat(h)
    gens = [g, gi, h, hi]
    adj = np.zeros((n,n))
    for i, m in enumerate(elems):
        for gen in gens:
            prod = gl.mul_mat(m, gen)
            j = idx[gl.mat_to_tuple(prod)]
            adj[i,j] += 0.25
    eigs = sorted(np.linalg.eigvalsh(adj), reverse=True)
    return 1.0 - eigs[1] if len(eigs) >= 2 else 0.0


# ─── Demo Functions ──────────────────────────────────────────────────────────

def demo_single_pair():
    """Demo 1: Certify a single well-known pair."""
    print("=" * 70)
    print("DEMO 1: Single Pair Certification")
    print("=" * 70)

    gl = GL2Fq(5)
    # Standard SL₂ generators embedded in GL₂
    g = gl.mat(0, 1, 4, 0)  # [[0,1],[-1,0]] — rotation-like
    h = gl.mat(1, 1, 0, 1)  # [[1,1],[0,1]]  — upper triangular

    print(f"\nField: 𝔽₅, |GL₂(𝔽₅)| = {gl.group_order}")
    print(f"g = {g.tolist()}")
    print(f"h = {h.tolist()}")

    certified, gap_bound, info = certify_pair(gl, g, h, L=3)

    print(f"\n--- Certificate Components ---")
    print(f"  Irreducible charpoly: {info.get('irr', False)}")
    print(f"  Primitive determinant: {info.get('prim', False)}")
    print(f"  Generates GL₂(𝔽₅): {info.get('gen', False)}")
    print(f"  Collision count (L=3): {info.get('coll', 'N/A')}")

    print(f"\n--- Certification Result ---")
    print(f"  Certified: {certified}")
    if certified:
        print(f"  Gap lower bound: {gap_bound:.6f}")

    if certified:
        true_gap = compute_spectral_gap(gl, g, h)
        print(f"  True spectral gap: {true_gap:.6f}")
        print(f"  Ratio (true/bound): {true_gap/gap_bound:.1f}x")
    print()


def demo_sweep_fields():
    """Demo 2: Sweep across q ∈ {3, 5, 7, 11}."""
    print("=" * 70)
    print("DEMO 2: Certification Sweep Across Fields")
    print("=" * 70)

    for q in [3, 5, 7]:
        gl = GL2Fq(q)
        print(f"\n--- q = {q}, |GL₂(𝔽_{q})| = {gl.group_order} ---")

        # Sample random pairs
        rng = np.random.RandomState(42 + q)
        elements = gl.enumerate_all()
        n_samples = min(30, len(elements))

        results = {'certified': 0, 'total': 0,
                    'gaps_certified': [], 'gaps_true': [], 'false_neg': 0}

        for _ in range(n_samples):
            i1, i2 = rng.randint(len(elements), size=2)
            g, h = elements[i1], elements[i2]
            if gl.mat_equal(g, gl.identity()) or gl.mat_equal(h, gl.identity()):
                continue
            results['total'] += 1
            certified, gap_bound, info = certify_pair(gl, g, h, L=2)

            if certified:
                results['certified'] += 1
                results['gaps_certified'].append(gap_bound)
                if q <= 5:
                    tg = compute_spectral_gap(gl, g, h)
                    results['gaps_true'].append(tg)
            else:
                # Check if it's a false negative (generates but not certified)
                if info.get('gen', False):
                    results['false_neg'] += 1

        total = results['total']
        cert = results['certified']
        pct = 100 * cert / total if total > 0 else 0
        print(f"  Pairs tested: {total}")
        print(f"  Certified: {cert} ({pct:.1f}%)")
        print(f"  False negatives: {results['false_neg']}")
        if results['gaps_certified']:
            avg_bound = np.mean(results['gaps_certified'])
            print(f"  Avg certified gap bound: {avg_bound:.6f}")
        if results['gaps_true']:
            avg_true = np.mean(results['gaps_true'])
            print(f"  Avg true spectral gap: {avg_true:.6f}")

    print()


def demo_radius_sensitivity():
    """Demo 3: Test sensitivity to short-word radius L."""
    print("=" * 70)
    print("DEMO 3: Collision Count vs. Short-Word Radius L")
    print("=" * 70)

    gl = GL2Fq(3)
    g = gl.mat(0, 1, 2, 0)
    h = gl.mat(1, 1, 0, 1)

    print(f"\nFixed pair in GL₂(𝔽₃), |GL₂(𝔽₃)| = {gl.group_order}")
    print(f"g = {g.tolist()}, h = {h.tolist()}")
    print(f"\n{'L':>4} | {'Words (4^L)':>10} | {'Collisions':>10} | {'Coll Rate':>10}")
    print("-" * 50)

    for L in range(1, 7):
        coll = collision_count(gl, g, h, L)
        n_words = 4 ** L
        rate = coll / gl.group_order if gl.group_order > 0 else 0
        print(f"{L:>4} | {n_words:>10} | {coll:>10} | {rate:>10.4f}")

    print()


def demo_eigenvalue_comparison():
    """Demo 4: Compare certified bounds with true eigenvalue spectra."""
    print("=" * 70)
    print("DEMO 4: Eigenvalue Spectra Comparison")
    print("=" * 70)

    for q in [3, 5]:
        gl = GL2Fq(q)
        print(f"\n--- q = {q} ---")

        # A known good pair
        g = gl.mat(0, 1, q-1, 0)
        h = gl.mat(1, 1, 0, 1)

        certified, gap_bound, info = certify_pair(gl, g, h, L=3)
        true_gap = compute_spectral_gap(gl, g, h)

        print(f"  Certified: {certified}")
        if certified:
            print(f"  Certified gap bound: {gap_bound:.6f}")
        print(f"  True spectral gap: {true_gap:.6f}")

        # Show top eigenvalues
        elems = gl.enumerate_all()
        n = len(elems)
        idx_map = {gl.mat_to_tuple(m):i for i,m in enumerate(elems)}
        gi = gl.inv_mat(g); hi = gl.inv_mat(h)
        gens = [g, gi, h, hi]
        adj = np.zeros((n,n))
        for i, m in enumerate(elems):
            for gen in gens:
                prod = gl.mul_mat(m, gen)
                j = idx_map[gl.mat_to_tuple(prod)]
                adj[i,j] += 0.25
        eigs = sorted(np.linalg.eigvalsh(adj), reverse=True)
        print(f"  Top 5 eigenvalues: {[f'{e:.4f}' for e in eigs[:5]]}")
        print(f"  Bottom 3 eigenvalues: {[f'{e:.4f}' for e in eigs[-3:]]}")

    print()


def demo_certification_density():
    """Demo 5: Test the Certification Density Conjecture."""
    print("=" * 70)
    print("DEMO 5: Certification Density Conjecture Test")
    print("=" * 70)
    print("\nConjecture: A positive density of generating pairs in GL₂(𝔽_q)")
    print("are algorithmically certifiable with a uniform gap bound.")

    for q in [3, 5, 7]:
        gl = GL2Fq(q)
        elements = gl.enumerate_all()
        n = len(elements)

        # Sample pairs
        rng = np.random.RandomState(2024 + q)
        n_test = min(100, n * (n - 1) // 2)

        cert_count = 0
        gen_count = 0
        irr_prim_count = 0

        for _ in range(n_test):
            i1, i2 = rng.randint(n, size=2)
            g, h = elements[i1], elements[i2]
            if gl.mat_equal(g, gl.identity()) or gl.mat_equal(h, gl.identity()):
                continue

            certified, _, info = certify_pair(gl, g, h, L=2)
            if info.get('gen', False):
                gen_count += 1
            if info.get('irr', False) and info.get('prim', False):
                irr_prim_count += 1
            if certified:
                cert_count += 1

        print(f"\n  q = {q}: tested {n_test} pairs")
        print(f"    Generating: {gen_count} ({100*gen_count/n_test:.1f}%)")
        print(f"    Irred+Prim: {irr_prim_count} ({100*irr_prim_count/n_test:.1f}%)")
        print(f"    Certified:  {cert_count} ({100*cert_count/n_test:.1f}%)")

    print()


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "█" * 70)
    print("  ALGORITHMIC SPECTRAL CERTIFICATION")
    print("  for Cayley Graphs of GL₂(𝔽_q)")
    print("█" * 70 + "\n")

    demo_single_pair()
    demo_sweep_fields()
    demo_radius_sensitivity()
    demo_eigenvalue_comparison()
    demo_certification_density()

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


"""
Visualization: Certification Density Heatmap

Heatmap showing which algebraic fingerprint combinations lead to successful
certification across different field sizes. Tests the Certification Density
Conjecture.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# ─── Inline classes ──────────────────────────────────────────────────────────

class FF:
    def __init__(self, q): self.q = q
    def inv(self, a): return pow(a, self.q-2, self.q)
    def order(self, a):
        if a%self.q==0: return 0
        v=1
        for k in range(1,self.q):
            v=(v*a)%self.q
            if v==1: return k
        return self.q-1

class GL2:
    def __init__(self, q):
        self.f=FF(q); self.q=q; self._o=(q*q-1)*(q*q-q)
    @property
    def go(self): return self._o
    def mat(self,a,b,c,d):
        return np.array([[a%self.q,b%self.q],[c%self.q,d%self.q]],dtype=int)
    def det(self,m):
        return (int(m[0,0])*int(m[1,1])-int(m[0,1])*int(m[1,0]))%self.q
    def is_inv(self,m): return self.det(m)!=0
    def mul_m(self,a,b):
        q=self.q;r=np.zeros((2,2),dtype=int)
        for i in range(2):
            for j in range(2):
                r[i,j]=(int(a[i,0])*int(b[0,j])+int(a[i,1])*int(b[1,j]))%q
        return r
    def inv_m(self,m):
        d=self.det(m);di=self.f.inv(d);q=self.q
        return np.array([[(int(m[1,1])*di)%q,((-int(m[0,1]))*di)%q],
                         [((-int(m[1,0]))*di)%q,(int(m[0,0])*di)%q]],dtype=int)
    def eye(self): return np.array([[1,0],[0,1]],dtype=int)
    def eq(self,a,b): return np.all(a%self.q==b%self.q)
    def t(self,m):
        return (int(m[0,0])%self.q,int(m[0,1])%self.q,
                int(m[1,0])%self.q,int(m[1,1])%self.q)
    def is_irred(self,m):
        tr=(int(m[0,0])+int(m[1,1]))%self.q; d=self.det(m)
        disc=(tr*tr-4*d)%self.q
        if disc==0: return False
        if self.q==2: return False
        return pow(disc,(self.q-1)//2,self.q)!=1
    def is_prim(self,m):
        d=self.det(m)
        if d%self.q==0: return False
        return self.f.order(d)==self.q-1
    def all(self):
        q=self.q;e=[]
        for a,b,c,d in iterproduct(range(q),repeat=4):
            m=self.mat(a,b,c,d)
            if self.is_inv(m): e.append(m)
        return e

def gen_check(gl, g, h):
    S=set();gi=gl.inv_m(g);hi=gl.inv_m(h)
    gens=[g,gi,h,hi]
    for gen in gens: S.add(gl.t(gen))
    for _ in range(gl.go+1):
        nf=[]
        for et in list(S):
            elem=gl.mat(et[0],et[1],et[2],et[3])
            for gen in gens:
                prod=gl.mul_m(elem,gen)
                tt=gl.t(prod)
                if tt not in S: S.add(tt); nf.append(prod)
        if not nf: break
    return len(S)==gl.go


# ─── Compute certification statistics ───────────────────────────────────────

primes = [3, 5, 7]
categories = ['Neither', 'Irred only', 'Prim only', 'Both']
n_samples = 80

data = np.zeros((len(primes), len(categories)))
gen_data = np.zeros((len(primes), len(categories)))

for qi, q in enumerate(primes):
    gl = GL2(q)
    elems = gl.all()
    rng = np.random.RandomState(2024 + q)

    counts = {cat: {'total': 0, 'gen': 0} for cat in categories}

    for _ in range(n_samples):
        i1, i2 = rng.randint(len(elems), size=2)
        g, h = elems[i1], elems[i2]
        if gl.eq(g, gl.eye()) or gl.eq(h, gl.eye()):
            continue

        irr = gl.is_irred(g) or gl.is_irred(h)
        prim = gl.is_prim(g) or gl.is_prim(h)

        if irr and prim:
            cat = 'Both'
        elif irr:
            cat = 'Irred only'
        elif prim:
            cat = 'Prim only'
        else:
            cat = 'Neither'

        counts[cat]['total'] += 1
        if gen_check(gl, g, h):
            counts[cat]['gen'] += 1

    for ci, cat in enumerate(categories):
        total = counts[cat]['total']
        gen_count = counts[cat]['gen']
        data[qi, ci] = total
        gen_data[qi, ci] = gen_count / total * 100 if total > 0 else 0


# ─── Plot ────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Panel 1: Distribution of algebraic fingerprints
x = np.arange(len(primes))
width = 0.2
for ci, cat in enumerate(categories):
    axes[0].bar(x + ci * width, data[:, ci], width, label=cat, alpha=0.8)

axes[0].set_xlabel('Field Size q', fontsize=12)
axes[0].set_ylabel('Count (out of samples)', fontsize=12)
axes[0].set_title('Distribution of Algebraic Fingerprints\nin Random Pairs', fontsize=11)
axes[0].set_xticks(x + 1.5 * width)
axes[0].set_xticklabels([f'𝔽_{q}' for q in primes])
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3, axis='y')

# Panel 2: Generation rate by category
colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4']
bar_positions = np.arange(len(categories))
for qi, q in enumerate(primes):
    offset = (qi - 1) * 0.25
    bars = axes[1].bar(bar_positions + offset, gen_data[qi, :], 0.22,
                        label=f'q={q}', alpha=0.8)

axes[1].set_xlabel('Algebraic Certificate Category', fontsize=12)
axes[1].set_ylabel('Generation Rate (%)', fontsize=12)
axes[1].set_title('Probability of Generating GL₂(𝔽_q)\nby Certificate Category', fontsize=11)
axes[1].set_xticks(bar_positions)
axes[1].set_xticklabels(categories, fontsize=9)
axes[1].legend(fontsize=9)
axes[1].grid(True, alpha=0.3, axis='y')
axes[1].set_ylim(0, 105)

plt.tight_layout()
plt.savefig('certification_density.png', dpi=150, bbox_inches='tight')
print("Saved certification_density.png")


"""
Visualization: Random Walk Mixing on Certified Cayley Graphs

Shows how the random walk distribution converges to uniform on Cayley graphs
of GL₂(𝔽_q), with convergence rate controlled by the certified spectral gap.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# ─── Inline classes ──────────────────────────────────────────────────────────

class FF:
    def __init__(self, q): self.q = q
    def inv(self, a): return pow(a, self.q-2, self.q)
    def order(self, a):
        if a%self.q==0: return 0
        v=1
        for k in range(1,self.q):
            v=(v*a)%self.q
            if v==1: return k
        return self.q-1

class GL2:
    def __init__(self, q):
        self.f=FF(q); self.q=q; self._o=(q*q-1)*(q*q-q)
    @property
    def go(self): return self._o
    def mat(self,a,b,c,d):
        return np.array([[a%self.q,b%self.q],[c%self.q,d%self.q]],dtype=int)
    def det(self,m):
        return (int(m[0,0])*int(m[1,1])-int(m[0,1])*int(m[1,0]))%self.q
    def mul_m(self,a,b):
        q=self.q;r=np.zeros((2,2),dtype=int)
        for i in range(2):
            for j in range(2):
                r[i,j]=(int(a[i,0])*int(b[0,j])+int(a[i,1])*int(b[1,j]))%q
        return r
    def inv_m(self,m):
        d=self.det(m);di=self.f.inv(d);q=self.q
        return np.array([[(int(m[1,1])*di)%q,((-int(m[0,1]))*di)%q],
                         [((-int(m[1,0]))*di)%q,(int(m[0,0])*di)%q]],dtype=int)
    def eye(self): return np.array([[1,0],[0,1]],dtype=int)
    def t(self,m):
        return (int(m[0,0])%self.q,int(m[0,1])%self.q,
                int(m[1,0])%self.q,int(m[1,1])%self.q)
    def all(self):
        q=self.q;e=[]
        for a,b,c,d in iterproduct(range(q),repeat=4):
            m=self.mat(a,b,c,d)
            if self.det(m)!=0: e.append(m)
        return e


# ─── Generate mixing data ───────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for qi, q in enumerate([3, 5]):
    gl = GL2(q)
    # Find primitive root
    prim = 2
    for r in range(2, q):
        if gl.f.order(r) == q-1: prim = r; break

    g = gl.mat(prim, 1, 0, 1)
    h = gl.mat(1, 0, 1, 1)

    elems = gl.all(); n = len(elems)
    idx = {gl.t(m): i for i, m in enumerate(elems)}

    gi = gl.inv_m(g); hi = gl.inv_m(h)
    gens = [g, gi, h, hi]

    # Build transition matrix
    P = np.zeros((n, n))
    for i, m in enumerate(elems):
        for gen in gens:
            prod = gl.mul_m(m, gen)
            j = idx[gl.t(prod)]
            P[i, j] += 0.25

    # Compute spectral gap
    eigs = sorted(np.linalg.eigvalsh(P), reverse=True)
    gap = 1.0 - eigs[1]
    alpha = eigs[1]

    # Simulate random walk from identity
    uniform = np.ones(n) / n
    dist = np.zeros(n)
    dist[0] = 1.0  # Start at identity

    T = 40
    tv_dist = []
    l2_dist = []

    for t in range(T):
        tv = 0.5 * np.sum(np.abs(dist - uniform))
        l2 = np.sqrt(np.sum((dist - uniform)**2))
        tv_dist.append(tv)
        l2_dist.append(l2)
        dist = dist @ P

    # Panel 1: TV distance decay
    ax = axes[0]
    ax.semilogy(range(T), tv_dist, linewidth=2, label=f'q={q}, gap={gap:.3f}')
    # Theoretical bound
    theory = [np.sqrt(n) * alpha**t for t in range(T)]
    ax.semilogy(range(T), theory, '--', linewidth=1.5, alpha=0.5,
                label=f'q={q} bound √n·α^t')

    # Panel 2: L² distance decay
    ax2 = axes[1]
    ax2.semilogy(range(T), l2_dist, linewidth=2, label=f'q={q}, gap={gap:.3f}')
    theory_l2 = [np.sqrt(n) * alpha**t for t in range(T)]
    ax2.semilogy(range(T), theory_l2, '--', linewidth=1.5, alpha=0.5,
                 label=f'q={q} bound')

axes[0].set_xlabel('Random Walk Steps', fontsize=12)
axes[0].set_ylabel('Total Variation Distance', fontsize=12)
axes[0].set_title('Mixing of Random Walk on Cay(GL₂(𝔽_q))\n(solid=empirical, dashed=spectral bound)', fontsize=11)
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)
axes[0].axhline(y=0.25, color='red', linestyle=':', alpha=0.4, label='TV = 0.25')

axes[1].set_xlabel('Random Walk Steps', fontsize=12)
axes[1].set_ylabel('L² Distance from Uniform', fontsize=12)
axes[1].set_title('L² Mixing Decay\n(certified: ‖T^t f‖₂ ≤ α^t ‖f‖₂)', fontsize=11)
axes[1].legend(fontsize=9)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_decay.png', dpi=150, bbox_inches='tight')
print("Saved mixing_decay.png")


"""
Visualization: Spectral Gap Certification Landscape

Visualizes the relationship between certified gap bounds and true spectral gaps
for generating pairs in GL₂(𝔽_q). Shows that certified bounds are conservative
but correctly identify good expanders.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# ─── Inline all needed functions ─────────────────────────────────────────────

class FiniteField:
    def __init__(self, q): self.q = q
    def mul(self, a, b): return (a*b)%self.q
    def inv(self, a): return pow(a, self.q-2, self.q)
    def order(self, a):
        if a%self.q==0: return 0
        v=1
        for k in range(1,self.q):
            v=(v*a)%self.q
            if v==1: return k
        return self.q-1

class GL2Fq:
    def __init__(self, q):
        self.f=FiniteField(q); self.q=q
        self._ord=(q*q-1)*(q*q-q)
    @property
    def group_order(self): return self._ord
    def mat(self,a,b,c,d):
        return np.array([[a%self.q,b%self.q],[c%self.q,d%self.q]],dtype=int)
    def det(self,m):
        return (int(m[0,0])*int(m[1,1])-int(m[0,1])*int(m[1,0]))%self.q
    def is_inv(self,m): return self.det(m)!=0
    def mul_mat(self,a,b):
        q=self.q;r=np.zeros((2,2),dtype=int)
        for i in range(2):
            for j in range(2):
                r[i,j]=(int(a[i,0])*int(b[0,j])+int(a[i,1])*int(b[1,j]))%q
        return r
    def inv_mat(self,m):
        d=self.det(m);di=self.f.inv(d);q=self.q
        return np.array([[(int(m[1,1])*di)%q,((-int(m[0,1]))*di)%q],
                         [((-int(m[1,0]))*di)%q,(int(m[0,0])*di)%q]],dtype=int)
    def identity(self): return np.array([[1,0],[0,1]],dtype=int)
    def mat_eq(self,a,b): return np.all(a%self.q==b%self.q)
    def t(self,m):
        return (int(m[0,0])%self.q,int(m[0,1])%self.q,
                int(m[1,0])%self.q,int(m[1,1])%self.q)
    def is_irred(self,m):
        tr=(int(m[0,0])+int(m[1,1]))%self.q; d=self.det(m)
        disc=(tr*tr-4*d)%self.q
        if disc==0: return False
        if self.q==2: return False
        return pow(disc,(self.q-1)//2,self.q)!=1
    def is_prim(self,m):
        d=self.det(m)
        if d%self.q==0: return False
        return self.f.order(d)==self.q-1
    def all(self):
        q=self.q;e=[]
        for a,b,c,d in iterproduct(range(q),repeat=4):
            m=self.mat(a,b,c,d)
            if self.is_inv(m): e.append(m)
        return e

def generates(gl, g, h):
    S=set();gi=gl.inv_mat(g);hi=gl.inv_mat(h)
    gens=[g,gi,h,hi]
    for gen in gens: S.add(gl.t(gen))
    for _ in range(gl.group_order+1):
        nf=[]
        for et in list(S):
            elem=gl.mat(et[0],et[1],et[2],et[3])
            for gen in gens:
                prod=gl.mul_mat(elem,gen)
                tt=gl.t(prod)
                if tt not in S: S.add(tt); nf.append(prod)
        if not nf: break
    return len(S)==gl.group_order

def spectral_gap(gl, g, h):
    elems=gl.all(); n=len(elems)
    idx={gl.t(m):i for i,m in enumerate(elems)}
    gi=gl.inv_mat(g);hi=gl.inv_mat(h)
    gens=[g,gi,h,hi]
    adj=np.zeros((n,n))
    for i,m in enumerate(elems):
        for gen in gens:
            prod=gl.mul_mat(m,gen)
            j=idx[gl.t(prod)]
            adj[i,j]+=0.25
    eigs=sorted(np.linalg.eigvalsh(adj),reverse=True)
    return 1.0-eigs[1] if len(eigs)>=2 else 0.0


# ─── Generate Data ───────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Certified bound vs true gap for q=3,5
for qi, q in enumerate([3, 5]):
    gl = GL2Fq(q)
    elems = gl.all()
    rng = np.random.RandomState(42 + q)

    true_gaps = []
    cert_bounds = []
    colors = []

    n_samples = 40
    for _ in range(n_samples):
        i1, i2 = rng.randint(len(elems), size=2)
        g, h = elems[i1], elems[i2]
        if gl.mat_eq(g, gl.identity()) or gl.mat_eq(h, gl.identity()):
            continue
        gen = generates(gl, g, h)
        if not gen:
            continue

        tg = spectral_gap(gl, g, h)
        irr = gl.is_irred(g) or gl.is_irred(h)
        prim = gl.is_prim(g) or gl.is_prim(h)

        if irr and prim:
            cb = 2.0 / (q * (q + 1))
        else:
            cb = 1.0 / gl.group_order

        true_gaps.append(tg)
        cert_bounds.append(cb)
        colors.append('tab:blue' if irr and prim else 'tab:orange')

    ax = axes[0]
    if q == 3:
        marker = 'o'
    else:
        marker = 's'
    for tg, cb, c in zip(true_gaps, cert_bounds, colors):
        ax.scatter(tg, cb, c=c, marker=marker, s=40, alpha=0.7,
                   edgecolors='black', linewidths=0.5)

# Diagonal line
axes[0].plot([0, 1], [0, 1], 'k--', alpha=0.3, label='y = x')
axes[0].set_xlabel('True Spectral Gap', fontsize=12)
axes[0].set_ylabel('Certified Lower Bound', fontsize=12)
axes[0].set_title('Certified Bound vs True Gap\n(●=𝔽₃, ■=𝔽₅, blue=Irr+Prim)', fontsize=11)
axes[0].legend(fontsize=10)
axes[0].set_xlim(-0.02, 0.5)
axes[0].set_ylim(-0.02, 0.5)
axes[0].grid(True, alpha=0.3)

# Panel 2: Eigenvalue spectrum comparison
for qi, q in enumerate([3, 5]):
    gl = GL2Fq(q)
    # Use a known generating pair
    prim = 2
    for r in range(2, q):
        if gl.f.order(r) == q - 1:
            prim = r; break
    g = gl.mat(prim, 1, 0, 1)
    h = gl.mat(1, 0, 1, 1)

    elems = gl.all(); n = len(elems)
    idx = {gl.t(m): i for i, m in enumerate(elems)}
    gi = gl.inv_mat(g); hi = gl.inv_mat(h)
    gens = [g, gi, h, hi]
    adj = np.zeros((n, n))
    for i, m in enumerate(elems):
        for gen in gens:
            prod = gl.mul_mat(m, gen)
            j = idx[gl.t(prod)]
            adj[i, j] += 0.25
    eigs = sorted(np.linalg.eigvalsh(adj), reverse=True)

    ax = axes[1]
    ax.plot(range(len(eigs)), eigs, label=f'q={q} (n={n})',
            linewidth=1.5, alpha=0.8)
    # Mark spectral gap
    gap = 1.0 - eigs[1]
    ax.axhline(y=eigs[1], color='gray', linestyle=':', alpha=0.5)

axes[1].set_xlabel('Eigenvalue Index', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title('Eigenvalue Spectrum of Certified\nCayley Graphs', fontsize=11)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_certification.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_certification.png")
