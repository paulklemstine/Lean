#!/usr/bin/env python3
"""
Tropical Homomorphic Encryption — Core Algorithms

Implements the complete algorithmic framework for encrypted computation
over tropical (min-plus) semirings.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable
import random
from enum import Enum


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class TropCipher:
    """Tropical ciphertext: a pair (left, right) of integers.

    Invariant: For a ciphertext encrypted under key k with message m
    and randomness r, left = r and right = m + r + k.
    """
    left: int
    right: int

    def __eq__(self, other: 'TropCipher') -> bool:
        return self.left == other.left and self.right == other.right

    def __repr__(self) -> str:
        return f"⟨{self.left}, {self.right}⟩"


class ExprType(Enum):
    VAR = "var"
    CONST = "const"
    TMIN = "tmin"
    TADD = "tadd"


@dataclass
class TropExpr:
    """Tropical expression tree.

    Represents expressions built from variables, constants,
    tropical addition (min), and tropical multiplication (+).
    """
    typ: ExprType
    var_idx: Optional[int] = None
    const_val: Optional[int] = None
    left: Optional['TropExpr'] = None
    right: Optional['TropExpr'] = None

    @staticmethod
    def var(i: int) -> 'TropExpr':
        return TropExpr(ExprType.VAR, var_idx=i)

    @staticmethod
    def const(c: int) -> 'TropExpr':
        return TropExpr(ExprType.CONST, const_val=c)

    @staticmethod
    def tmin(e1: 'TropExpr', e2: 'TropExpr') -> 'TropExpr':
        return TropExpr(ExprType.TMIN, left=e1, right=e2)

    @staticmethod
    def tadd(e1: 'TropExpr', e2: 'TropExpr') -> 'TropExpr':
        return TropExpr(ExprType.TADD, left=e1, right=e2)

    def is_tmin_free(self) -> bool:
        """Check if expression contains no tmin nodes."""
        if self.typ == ExprType.VAR or self.typ == ExprType.CONST:
            return True
        if self.typ == ExprType.TMIN:
            return False
        return self.left.is_tmin_free() and self.right.is_tmin_free()

    def __repr__(self) -> str:
        if self.typ == ExprType.VAR:
            return f"x{self.var_idx}"
        if self.typ == ExprType.CONST:
            return str(self.const_val)
        if self.typ == ExprType.TMIN:
            return f"min({self.left}, {self.right})"
        return f"({self.left} + {self.right})"


# ============================================================
# Algorithm 1: Tropical Encryption / Decryption
# ============================================================

def trop_enc(k: int, m: int, r: int) -> TropCipher:
    """Encrypt message m under key k with randomness r.

    Algorithm:
        Enc_k(m; r) = (r, m + r + k)

    Time: O(1)
    Space: O(1)
    """
    return TropCipher(left=r, right=m + r + k)


def trop_dec(k: int, c: TropCipher) -> int:
    """Decrypt ciphertext c under key k.

    Algorithm:
        Dec_k(a, b) = b - a - k

    Time: O(1)
    Space: O(1)
    """
    return c.right - c.left - k


# ============================================================
# Algorithm 2: Homomorphic Operations
# ============================================================

def trop_cmul(c1: TropCipher, c2: TropCipher) -> TropCipher:
    """Homomorphic tropical multiplication (= plaintext addition).

    Algorithm:
        cMul(c1, c2) = (c1.left + c2.left, c1.right + c2.right)

    Key evolution: effective key doubles from k to 2k.

    Time: O(1)
    Space: O(1)
    """
    return TropCipher(c1.left + c2.left, c1.right + c2.right)


def trop_cmin(c1: TropCipher, c2: TropCipher) -> TropCipher:
    """Homomorphic tropical addition (= plaintext min).

    Algorithm:
        cMin(c1, c2) = c1 if c1.right ≤ c2.right else c2

    Correctness: requires same randomness in both ciphertexts.

    Time: O(1)
    Space: O(1)
    """
    return c1 if c1.right <= c2.right else c2


def trop_refresh(k: int, K: int, c: TropCipher) -> TropCipher:
    """Re-key ciphertext from effective key K to base key k.

    Algorithm:
        refresh(k, K, c) = (c.left, c.right - K + k)

    Preserves plaintext: Dec_k(refresh(k, K, c)) = Dec_K(c).

    Time: O(1)
    Space: O(1)
    """
    return TropCipher(c.left, c.right - K + k)


# ============================================================
# Algorithm 3: Key Weight Computation
# ============================================================

def key_weight(expr: TropExpr) -> int:
    """Compute the key weight of a tropical expression.

    Algorithm:
        keyWeight(var)     = 1
        keyWeight(const)   = 0
        keyWeight(tmin(e1,e2)) = max(keyWeight(e1), keyWeight(e2))
        keyWeight(tadd(e1,e2)) = keyWeight(e1) + keyWeight(e2)

    Key insight: min gates contribute max (not sum!) to key weight.
    This means chains of min operations do NOT compound the key.

    Time: O(|expr|) where |expr| is the number of nodes
    Space: O(depth(expr)) for recursion stack
    """
    if expr.typ == ExprType.VAR:
        return 1
    if expr.typ == ExprType.CONST:
        return 0
    if expr.typ == ExprType.TMIN:
        return max(key_weight(expr.left), key_weight(expr.right))
    # TADD
    return key_weight(expr.left) + key_weight(expr.right)


# ============================================================
# Algorithm 4: Expression Evaluation (Plaintext and Ciphertext)
# ============================================================

def eval_plain(rho: List[int], expr: TropExpr) -> int:
    """Evaluate tropical expression on plaintext inputs.

    Time: O(|expr|)
    Space: O(depth(expr))
    """
    if expr.typ == ExprType.VAR:
        return rho[expr.var_idx]
    if expr.typ == ExprType.CONST:
        return expr.const_val
    if expr.typ == ExprType.TMIN:
        return min(eval_plain(rho, expr.left), eval_plain(rho, expr.right))
    # TADD
    return eval_plain(rho, expr.left) + eval_plain(rho, expr.right)


def eval_cipher(env: List[TropCipher], expr: TropExpr) -> TropCipher:
    """Evaluate tropical expression on encrypted inputs.

    For tmin-free expressions, the result decrypts correctly under
    key = keyWeight(expr) * k.

    Time: O(|expr|)
    Space: O(depth(expr))
    """
    if expr.typ == ExprType.VAR:
        return env[expr.var_idx]
    if expr.typ == ExprType.CONST:
        return TropCipher(0, expr.const_val)
    if expr.typ == ExprType.TMIN:
        c1 = eval_cipher(env, expr.left)
        c2 = eval_cipher(env, expr.right)
        return c1 if c1.right <= c2.right else c2
    # TADD
    c1 = eval_cipher(env, expr.left)
    c2 = eval_cipher(env, expr.right)
    return trop_cmul(c1, c2)


# ============================================================
# Algorithm 5: Encrypted Bellman-Ford
# ============================================================

def encrypted_bellman_step(
    dist: List[TropCipher],
    edges: List[Tuple[int, int, TropCipher]],
    k: int,
    shared_r: int
) -> List[TropCipher]:
    """One step of encrypted Bellman-Ford relaxation.

    Args:
        dist: Current encrypted distance estimates
        edges: List of (u, v, encrypted_weight) triples
        k: Current effective key for distances
        shared_r: Shared randomness for min-correctness

    Returns:
        Updated encrypted distance estimates

    Time: O(|E|) per step
    Space: O(|V|)

    Note: For full correctness, requires careful key management
    and shared randomness for the min operations.
    """
    new_dist = list(dist)  # copy

    for u, v, c_weight in edges:
        # Path extension: dist[u] ⊗ weight = dist[u] + weight
        c_new = trop_cmul(dist[u], c_weight)
        # Refresh to base key
        c_new_refreshed = trop_refresh(k, 2 * k, c_new)
        # Relaxation: min(dist[v], new_path)
        new_dist[v] = trop_cmin(new_dist[v], c_new_refreshed)

    return new_dist


def encrypted_bellman_ford(
    n: int,
    edges: List[Tuple[int, int, int]],
    source: int,
    k: int
) -> List[int]:
    """Complete encrypted Bellman-Ford shortest path algorithm.

    Args:
        n: Number of vertices
        edges: List of (u, v, weight) triples
        source: Source vertex
        k: Encryption key

    Returns:
        Decrypted shortest path distances from source

    Time: O(|V| · |E|)
    Space: O(|V| + |E|)
    """
    INF = 10**9
    r = 0  # shared randomness for min-correctness

    # Initialize distances
    dist = []
    for i in range(n):
        d = 0 if i == source else INF
        dist.append(trop_enc(k, d, r))

    # Encrypt edge weights
    enc_edges = [(u, v, trop_enc(k, w, r)) for u, v, w in edges]

    # Relax n-1 times
    for _ in range(n - 1):
        dist = encrypted_bellman_step(dist, enc_edges, k, r)

    # Decrypt results
    return [trop_dec(k, c) for c in dist]


# ============================================================
# Algorithm 6: Deterministic Impossibility Checker
# ============================================================

def check_det_impossibility(enc: Callable[[int], int], n: int = 100) -> bool:
    """Verify that a deterministic encryption is injective on [0, n).

    If injective, the scheme is DetCPAInsecure (adversary can
    distinguish ciphertexts by equality testing).

    Time: O(n²)
    Space: O(n)
    """
    ciphertexts = {}
    for m in range(n):
        c = enc(m)
        if c in ciphertexts:
            return False  # Not injective (impossible for correct scheme)
        ciphertexts[c] = m
    return True  # Injective → insecure


# ============================================================
# Self-Test
# ============================================================

if __name__ == "__main__":
    print("Running algorithm self-tests...")

    # Test 1: Encryption/Decryption
    for _ in range(100):
        k = random.randint(-1000, 1000)
        m = random.randint(-1000, 1000)
        r = random.randint(-1000, 1000)
        assert trop_dec(k, trop_enc(k, m, r)) == m, f"Decryption failed: k={k}, m={m}, r={r}"

    # Test 2: Homomorphic multiplication
    for _ in range(100):
        k = random.randint(-100, 100)
        m1 = random.randint(-100, 100)
        m2 = random.randint(-100, 100)
        r1 = random.randint(-100, 100)
        r2 = random.randint(-100, 100)
        c = trop_cmul(trop_enc(k, m1, r1), trop_enc(k, m2, r2))
        assert trop_dec(2 * k, c) == m1 + m2

    # Test 3: Same-randomness min
    for _ in range(100):
        k = random.randint(-100, 100)
        m1 = random.randint(-100, 100)
        m2 = random.randint(-100, 100)
        r = random.randint(-100, 100)
        c = trop_cmin(trop_enc(k, m1, r), trop_enc(k, m2, r))
        assert trop_dec(k, c) == min(m1, m2)

    # Test 4: Refresh
    for _ in range(100):
        k = random.randint(-100, 100)
        m = random.randint(-100, 100)
        r = random.randint(-100, 100)
        K = random.randint(-100, 100)
        c = TropCipher(r, m + r + K)
        assert trop_dec(k, trop_refresh(k, K, c)) == trop_dec(K, c)

    # Test 5: Key weight
    e = TropExpr.tadd(
        TropExpr.tadd(TropExpr.var(0), TropExpr.var(1)),
        TropExpr.var(2)
    )
    assert key_weight(e) == 3

    e_min = TropExpr.tmin(TropExpr.var(0), TropExpr.var(1))
    assert key_weight(e_min) == 1  # max(1,1) = 1, NOT 2

    # Test 6: Expression evaluation
    k = 5
    rho = [3, 7, 2]
    rs = [10, 20, 30]
    env = [trop_enc(k, rho[i], rs[i]) for i in range(3)]

    # tadd-only expression: x0 + x1 + x2
    expr = TropExpr.tadd(TropExpr.tadd(TropExpr.var(0), TropExpr.var(1)), TropExpr.var(2))
    c_result = eval_cipher(env, expr)
    kw = key_weight(expr)
    assert trop_dec(kw * k, c_result) == eval_plain(rho, expr)

    # Test 7: Bellman-Ford
    #   0 →(3) 1 →(2) 2
    #   0 →(10) 2
    edges = [(0, 1, 3), (1, 2, 2), (0, 2, 10)]
    result = encrypted_bellman_ford(3, edges, 0, k=7)
    assert result[0] == 0
    assert result[1] == 3
    assert result[2] == 5  # via 0→1→2, not direct 0→2

    print("All self-tests passed! ✓")
