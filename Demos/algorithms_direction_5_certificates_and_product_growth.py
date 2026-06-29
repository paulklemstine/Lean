#!/usr/bin/env python3
"""
Algorithms for product-set growth computation in finite groups.

Provides verified algorithms for:
1. Finite field matrix arithmetic (GL(n, F_q))
2. Product set computation and iteration
3. Cayley ball expansion
4. Growth rate estimation and classification

Each algorithm includes complexity analysis and correctness documentation.
"""

from typing import (
    List, Set, Tuple, Dict, Optional, FrozenSet, Callable, TypeVar
)
from collections import deque
import time

# ──────────────────────────────────────────────────────────────────────
# Type aliases
# ──────────────────────────────────────────────────────────────────────
Matrix2 = Tuple[int, int, int, int]  # (a, b, c, d) for [[a,b],[c,d]]


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Finite Field Matrix Arithmetic
# ──────────────────────────────────────────────────────────────────────

class FF:
    """Finite field F_p for prime p.

    All operations are O(log p) via modular exponentiation.

    Complexity:
        - add, sub, mul: O(1) (modular arithmetic)
        - inv: O(log p) (Fermat's little theorem)
    """

    def __init__(self, p: int):
        """Initialize F_p. p must be prime."""
        self.p = p

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        """Multiplicative inverse via Fermat's little theorem.

        Requires a ≠ 0 (mod p). Returns a^{p-2} mod p.
        """
        if a % self.p == 0:
            raise ValueError("Cannot invert zero")
        return pow(a, self.p - 2, self.p)

    def neg(self, a: int) -> int:
        return (-a) % self.p


class GL2:
    """GL(2, F_p): the general linear group of 2x2 invertible matrices.

    Matrices stored as flat tuples (a, b, c, d) representing [[a,b],[c,d]].

    Group order: |GL(2, F_p)| = (p²-1)(p²-p) = p(p-1)²(p+1).

    Complexity:
        - mul: O(1) (8 multiplications, 4 additions mod p)
        - inv: O(log p) (one field inversion + 4 multiplications)
        - enumerate: O(p⁴) time, O(|G|) space
    """

    def __init__(self, p: int):
        self.p = p
        self.ff = FF(p)
        self._identity = (1, 0, 0, 1)

    @property
    def order(self) -> int:
        """Group order = (p²-1)(p²-p)."""
        p = self.p
        return (p * p - 1) * (p * p - p)

    @property
    def identity(self) -> Matrix2:
        return self._identity

    def mul(self, A: Matrix2, B: Matrix2) -> Matrix2:
        """Matrix multiplication mod p."""
        a, b, c, d = A
        e, f, g, h = B
        ff = self.ff
        return (
            ff.add(ff.mul(a, e), ff.mul(b, g)),
            ff.add(ff.mul(a, f), ff.mul(b, h)),
            ff.add(ff.mul(c, e), ff.mul(d, g)),
            ff.add(ff.mul(c, f), ff.mul(d, h)),
        )

    def det(self, A: Matrix2) -> int:
        a, b, c, d = A
        return self.ff.sub(self.ff.mul(a, d), self.ff.mul(b, c))

    def inv(self, A: Matrix2) -> Matrix2:
        """Matrix inverse. Requires det(A) ≠ 0."""
        a, b, c, d = A
        ff = self.ff
        det_val = ff.sub(ff.mul(a, d), ff.mul(b, c))
        di = ff.inv(det_val)
        return (
            ff.mul(d, di), ff.mul(ff.neg(b), di),
            ff.mul(ff.neg(c), di), ff.mul(a, di),
        )

    def enumerate(self) -> List[Matrix2]:
        """Enumerate all elements of GL(2, F_p).

        Time: O(p⁴). Space: O(|G|) = O(p⁴).
        """
        p = self.p
        elements = []
        for a in range(p):
            for b in range(p):
                for c in range(p):
                    for d in range(p):
                        if (a * d - b * c) % p != 0:
                            elements.append((a, b, c, d))
        return elements

    def sym_set(self, g: Matrix2, h: Matrix2) -> Set[Matrix2]:
        """Build symmetric generating set {1, g, g⁻¹, h, h⁻¹}."""
        return {self.identity, g, self.inv(g), h, self.inv(h)}


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Product Set Iteration
# ──────────────────────────────────────────────────────────────────────

def product_set_multiply(
    S: Set[Matrix2],
    A: Set[Matrix2],
    group: GL2,
) -> Set[Matrix2]:
    """Compute S · A = {s * a : s ∈ S, a ∈ A}.

    Time: O(|S| · |A|) multiplications, each O(1).
    Space: O(|S · A|) ≤ O(|G|).

    Pseudocode:
        PRODUCT-SET(S, A):
            result ← ∅
            for s in S:
                for a in A:
                    result ← result ∪ {s * a}
            return result
    """
    result: Set[Matrix2] = set()
    for s in S:
        for a in A:
            result.add(group.mul(s, a))
    return result


def compute_power_sequence(
    A: Set[Matrix2],
    group: GL2,
    max_k: int = 6,
) -> List[int]:
    """Compute [|A|, |A²|, |A³|, ..., |A^max_k|].

    Stops early if A^k = G (saturation).

    Time: O(max_k · |G| · |A|) worst case.
    Space: O(|G|).

    Pseudocode:
        POWER-SEQUENCE(A, max_k):
            current ← A
            sizes ← [|A|]
            for k = 2 to max_k:
                current ← PRODUCT-SET(current, A)
                sizes.append(|current|)
                if |current| = |G|:
                    break
            return sizes
    """
    sizes = [len(A)]
    current = A
    for k in range(2, max_k + 1):
        current = product_set_multiply(current, A, group)
        sizes.append(len(current))
        if len(current) == group.order:
            break
    return sizes


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Cayley Ball Expansion
# ──────────────────────────────────────────────────────────────────────

def cayley_ball_sequence(
    A: Set[Matrix2],
    group: GL2,
    max_radius: int = 10,
) -> List[int]:
    """Compute Cayley ball sizes [|B_0|, |B_1|, ..., |B_max_radius|].

    B_0 = {1}, B_{k+1} = B_k ∪ (B_k · A).

    This corresponds to BFS in the Cayley graph Cay(G, A).

    Time: O(|G| · |A|) total (each group element processed once).
    Space: O(|G|).

    Pseudocode:
        CAYLEY-BALLS(A, max_radius):
            B ← {1}
            sizes ← [1]
            for k = 1 to max_radius:
                B_new ← B ∪ PRODUCT-SET(B, A)
                sizes.append(|B_new|)
                if B_new = B:  // fixed point
                    break
                B ← B_new
            return sizes
    """
    B = {group.identity}
    sizes = [1]
    for k in range(1, max_radius + 1):
        B_new = B | product_set_multiply(B, A, group)
        sizes.append(len(B_new))
        if len(B_new) == len(B):
            # Fixed point; remaining balls are same
            break
        B = B_new
        if len(B) == group.order:
            break
    return sizes


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Generation Test (BFS)
# ──────────────────────────────────────────────────────────────────────

def generates_group(
    generators: Set[Matrix2],
    group: GL2,
) -> bool:
    """Test if generators generate GL(2, F_p) using BFS.

    Time: O(|G| · |generators|).
    Space: O(|G|).

    Pseudocode:
        GENERATES?(S, G):
            visited ← S
            queue ← list(S)
            while queue not empty:
                s ← queue.pop()
                for g in S:
                    product ← s * g
                    if product ∉ visited:
                        visited.add(product)
                        queue.push(product)
                        if |visited| = |G|:
                            return true
            return |visited| = |G|
    """
    visited = set(generators)
    queue = deque(generators)
    target = group.order

    while queue:
        s = queue.popleft()
        for g in generators:
            prod = group.mul(s, g)
            if prod not in visited:
                visited.add(prod)
                queue.append(prod)
                if len(visited) == target:
                    return True
    return len(visited) == target


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Growth Classifier
# ──────────────────────────────────────────────────────────────────────

def classify_growth(
    sizes: List[int],
    group_order: int,
) -> Dict:
    """Classify the growth pattern of a product-set sequence.

    Categories:
    - "rapid_saturation": fills group in ≤ 3 steps
    - "polynomial": growth ratios decrease but remain > 1
    - "exponential": growth ratios stay roughly constant
    - "anomalous": growth ratio < 1.1 at some non-saturated step

    Returns dict with classification and metrics.
    """
    ratios = []
    for i in range(len(sizes) - 1):
        if sizes[i] > 0:
            ratios.append(sizes[i + 1] / sizes[i])
        else:
            ratios.append(float('inf'))

    sat_step = None
    for i, s in enumerate(sizes):
        if s >= group_order:
            sat_step = i + 1  # 1-indexed
            break

    # Check for anomalous slow growth
    anomalous = False
    for i, r in enumerate(ratios):
        if sizes[i] < group_order and r < 1.1:
            anomalous = True
            break

    if sat_step is not None and sat_step <= 3:
        category = "rapid_saturation"
    elif anomalous:
        category = "anomalous"
    elif ratios and all(r > 1.5 for r in ratios if sizes[ratios.index(r)] < group_order):
        category = "exponential"
    else:
        category = "polynomial"

    return {
        'category': category,
        'sizes': sizes,
        'ratios': ratios,
        'saturation_step': sat_step,
        'anomalous': anomalous,
    }


# ──────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("Product Growth Algorithms — Example Usage")
    print("=" * 50)

    for p in [5, 7]:
        G = GL2(p)
        print(f"\nGL(2, F_{p}), order = {G.order}")

        elements = G.enumerate()
        print(f"  Enumerated {len(elements)} elements")

        # Pick a sample pair
        import random
        random.seed(123 + p)
        for _ in range(100):
            g = random.choice(elements)
            h = random.choice(elements)
            A = G.sym_set(g, h)
            if generates_group(A, G):
                break

        print(f"  Generator pair found: g={g}, h={h}")

        # Product power sequence
        sizes = compute_power_sequence(A, G, max_k=6)
        print(f"  Power sizes: {sizes}")

        # Cayley ball sequence
        ball_sizes = cayley_ball_sequence(A, G, max_radius=8)
        print(f"  Cayley ball sizes: {ball_sizes}")

        # Classify
        cls = classify_growth(sizes, G.order)
        print(f"  Growth classification: {cls['category']}")
        print(f"  Growth ratios: {[f'{r:.2f}' for r in cls['ratios']]}")
