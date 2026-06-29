# A Uniform Local Density Gap for the Perfect Cuboid Problem

## Abstract

We establish a uniform local density gap for the perfect cuboid problem. Defining the *survivor count* survivorCount(p) as the number of triples (a,b,c) ∈ (ℤ/pℤ)³ satisfying all four quadratic residue conditions required by a perfect cuboid, we prove that for every odd prime p, the survivor density satisfies survivorCount(p)/p³ ≤ 7/10. The bound δ = 3/10 is a uniform entropy gap: each prime eliminates at least 30% of candidate residue classes.

The proof combines computational verification at primes p ≤ 43 with a structural projection bound for p ≥ 47. The structural component rests on an elementary proof that the number of Pythagorean triples (a,b,c) with a² + b² ≡ c² (mod p) is exactly p², obtained via a linear change of variables reducing the equation to uv = -y². All results have been formally verified using computer-checked proofs.

**Keywords:** perfect cuboid, Euler product sieve, local-global obstruction, quadratic residues, finite-field counting, certified computation

---

## 1. Introduction

### 1.1 The Perfect Cuboid Problem

A *perfect cuboid* (or perfect Euler brick) is a rectangular parallelepiped with integer edges a, b, c such that all three face diagonals √(a²+b²), √(a²+c²), √(b²+c²) and the space diagonal √(a²+b²+c²) are also integers. Despite extensive computational searches [1, 2] and numerous partial results, the existence or nonexistence of perfect cuboids remains open.

### 1.2 Local-Global Approach

The local-global philosophy, originating with Hasse and Minkowski, suggests studying a Diophantine equation by first understanding its solutions modulo each prime. For the perfect cuboid system, this means studying the survivor count:

**Definition.** For n ≥ 1, define
$$\text{survivorCount}(n) = \#\{(a,b,c) \in (\mathbb{Z}/n\mathbb{Z})^3 : \text{all four sums are QRs}\}$$

where the conditions are: a²+b², a²+c², b²+c², and a²+b²+c² are each quadratic residues (including 0) modulo n.

If a perfect cuboid (x,y,z) exists, then (x mod n, y mod n, z mod n) is a survivor for every n (the *bridge theorem*). Therefore, any upper bound on survivorCount(n)/n³ constrains the existence of perfect cuboids.

### 1.3 Main Results

**Theorem 1 (Uniform Density Gap).** For every odd prime p:
$$\text{survivorCount}(p) \leq \frac{7}{10} \cdot p^3$$

Equivalently, there exists δ = 3/10 > 0 such that the survivor density is at most 1 − δ at every odd prime.

**Theorem 2 (Pythagorean Count).** For every odd prime p:
$$\#\{(a,b,c) \in (\mathbb{Z}/p\mathbb{Z})^3 : a^2 + b^2 = c^2\} = p^2$$

**Theorem 3 (Quartic Fiber Factorization).** Over any commutative ring R:
$$r^2 s^4 + (r^4+1)s^2 + r^2 = (r^2 s^2 + 1)(s^2 + r^2)$$

**Theorem 4 (Bridge Theorem).** If (x,y,z) ∈ ℤ³ satisfies all four perfect cuboid conditions, then (x mod n, y mod n, z mod n) is a cuboid survivor for every n ≥ 1.

**Theorem 5 (Certified Prime Counts).** The exact values survivorCount(p) for p = 3, 5, 7, 11, 13, 17, 19, 23, 29, 31 are 7, 37, 55, 151, 349, 817, 487, 1079, 3277, 2431 respectively.

---

## 2. Definitions and Notation

Let p denote an odd prime throughout. We write 𝔽_p = ℤ/pℤ for the field with p elements.

**Definition 2.1 (Cuboid Survivor).** A triple (a,b,c) ∈ 𝔽_p³ is a *cuboid survivor* if:
1. a² + b² ∈ (𝔽_p)² ∪ {0}  (i.e., IsSquare in 𝔽_p)
2. a² + c² ∈ (𝔽_p)² ∪ {0}
3. b² + c² ∈ (𝔽_p)² ∪ {0}
4. a² + b² + c² ∈ (𝔽_p)² ∪ {0}

**Definition 2.2 (Auxiliary Counts).**
- sqPairCount(p) = #{(a,b) ∈ 𝔽_p² : IsSquare(a²+b²)}
- pythagCount(p) = #{(a,b,c) ∈ 𝔽_p³ : a²+b² = c²}
- zeroPairCount(p) = #{(a,b) ∈ 𝔽_p² : a²+b² = 0}

---

## 3. Pythagorean Triple Count

**Theorem 2 (restated).** For every odd prime p, pythagCount(p) = p².

*Proof.* Define the linear map φ : 𝔽_p³ → 𝔽_p³ by φ(x,y,z) = (x+z, x−z, y). Since 2 is invertible in 𝔽_p (as p is odd), φ has inverse φ⁻¹(u,v,w) = ((u+v)/2, w, (u−v)/2) and is a bijection.

The map φ transforms the Pythagorean condition: x² + y² = z² ⟺ x² − z² = −y² ⟺ (x+z)(x−z) = −y² ⟺ uv = −w².

So pythagCount(p) = #{(u,v,w) ∈ 𝔽_p³ : uv = −w²}. We count by cases:

**Case w = 0:** uv = 0, so u = 0 or v = 0. By inclusion-exclusion: |{u=0}| + |{v=0}| − |{u=v=0}| = p + p − 1 = 2p−1.

**Case w ≠ 0:** uv = −w² ≠ 0, so u ≠ 0 and v is determined: v = −w²/u. There are p−1 choices for u ∈ 𝔽_p* and p−1 choices for w ∈ 𝔽_p*. Total: (p−1)².

**Grand total:** (2p−1) + (p−1)² = 2p−1 + p²−2p+1 = p². □

---

## 4. The Projection Bound

### 4.1 Projection Lemma

**Lemma 4.1.** survivorCount(p) ≤ p · sqPairCount(p).

*Proof.* If (a,b,c) is a survivor, then in particular a²+b² is a square. For each surviving pair (a,b) (satisfying condition 1), there are at most p values of c. Summing over such pairs gives the result. □

### 4.2 Square-Pair Count Bound

**Lemma 4.2.** zeroPairCount(p) ≤ 2p − 1.

*Proof.* The equation a² + b² = 0 in 𝔽_p means b² = −a². For a = 0, only b = 0 works (1 solution). For each a ≠ 0, the equation b² = −a² is a quadratic in b with at most 2 roots. So zeroPairCount(p) ≤ 1 + 2(p−1) = 2p−1. □

**Lemma 4.3.** 2 · sqPairCount(p) ≤ p² + 2p − 1.

*Proof.* For each pair (a,b), the number of c with c² = a²+b² is:
- 0 if a²+b² is not a square
- 1 if a²+b² = 0 (only c = 0)
- 2 if a²+b² is a nonzero square (c = ±√(a²+b²), and c ≠ −c since 2 is invertible)

Therefore: pythagCount(p) = 0 · (NQR pairs) + 1 · zeroPairCount(p) + 2 · (sqPairCount(p) − zeroPairCount(p)) = 2·sqPairCount(p) − zeroPairCount(p).

From Theorem 2: p² = 2·sqPairCount(p) − zeroPairCount(p).
So: 2·sqPairCount(p) = p² + zeroPairCount(p) ≤ p² + 2p − 1. □

### 4.3 Combined Bound

**Corollary 4.4.** For p ≥ 5:
$$\text{survivorCount}(p) \leq p \cdot \frac{p^2 + 2p - 1}{2}$$

The ratio survivorCount(p)/p³ ≤ (p²+2p−1)/(2p²) = 1/2 + 1/p − 1/(2p²), which is maximized at p = 5 giving 34/50 = 17/25 = 0.68 < 7/10.

---

## 5. Proof of the Uniform Gap

**Proof of Theorem 1.** We split into two cases.

**Case p ≤ 43:** For each prime p ∈ {3,5,7,11,13,17,19,23,29,31,37,41,43}, the inequality 10 · survivorCount(p) ≤ 7 · p³ is verified by certified computation using kernel-level reduction (native_decide in the proof assistant). In fact, the stronger bound 10 · survivorCount(p) ≤ 3 · p³ holds for all these primes.

**Case p ≥ 47:** By the projection bound and Lemma 4.3:
$$10 \cdot \text{survivorCount}(p) \leq 10p \cdot \text{sqPairCount}(p) \leq 5p(p^2 + 2p - 1)$$

We need 5p(p²+2p−1) ≤ 7p³, equivalently 5(p²+2p−1) ≤ 7p², i.e., 2p² − 10p + 5 ≥ 0.

For p ≥ 5: 2p² − 10p + 5 = 2(p−5/2)² − 15/2 + 5 = 2(p−5/2)² − 5/2. At p = 5: 50−50+5 = 5 > 0, and the expression is increasing for p ≥ 3. □

---

## 6. The Quartic Fiber Factorization

**Theorem 3 (restated).** For any commutative ring R and r, s ∈ R:
$$r^2 s^4 + (r^4+1)s^2 + r^2 = (r^2 s^2 + 1)(s^2 + r^2)$$

*Proof.* Direct expansion of the right side and comparison of coefficients. □

This identity arises from the Pythagorean parametrization of the cuboid face diagonals. Setting u = (r²+1)/(2r) and v = (s²+1)/(2s), the surface equation w² = u²+v²−1 transforms into W² = r²s⁴+(r⁴+1)s²+r² where W = 2rsw. The factorization reveals that the cuboid condition reduces to requiring the product (r²s²+1)(s²+r²) to be a perfect square — a coupled quadratic-character condition.

---

## 7. Computational Experiments

### 7.1 Certified Survivor Counts

| p | survivorCount(p) | p³ | Density | Gap |
|--:|--:|--:|--:|--:|
| 3 | 7 | 27 | 0.2593 | 0.7407 |
| 5 | 37 | 125 | 0.2960 | 0.7040 |
| 7 | 55 | 343 | 0.1603 | 0.8397 |
| 11 | 151 | 1,331 | 0.1134 | 0.8866 |
| 13 | 349 | 2,197 | 0.1589 | 0.8411 |
| 17 | 817 | 4,913 | 0.1663 | 0.8337 |
| 19 | 487 | 6,859 | 0.0710 | 0.9290 |
| 23 | 1,079 | 12,167 | 0.0887 | 0.9113 |
| 29 | 3,277 | 24,389 | 0.1344 | 0.8656 |
| 31 | 2,431 | 29,791 | 0.0816 | 0.9184 |

### 7.2 Congruence Class Analysis

The density shows a clear dependence on p mod 4:
- **p ≡ 1 (mod 4):** Higher densities (5: 0.296, 13: 0.159, 17: 0.166, 29: 0.134, 37: 0.133, 41: 0.139). Average ≈ 0.171.
- **p ≡ 3 (mod 4):** Lower densities (3: 0.259, 7: 0.160, 11: 0.113, 19: 0.071, 23: 0.089, 31: 0.082, 43: 0.073). Average ≈ 0.121.

This splitting is explained by the zero-pair count: N₀ = 2p−1 when −1 is a QR (p ≡ 1 mod 4) vs. N₀ = 1 when −1 is a NQR (p ≡ 3 mod 4). The larger N₀ inflates the square-pair count and hence the survivor density.

### 7.3 Euler Product Decay

Computing the cumulative product of local densities:

| Primes | Primorial | Product density |
|--------|----------:|----------------:|
| {3} | 3 | 2.593 × 10⁻¹ |
| {3,5} | 15 | 7.674 × 10⁻² |
| {3,5,7} | 105 | 1.230 × 10⁻² |
| {3,5,7,11} | 1,155 | 1.396 × 10⁻³ |
| {3,5,7,11,13} | 15,015 | 2.218 × 10⁻⁴ |

The density decays roughly exponentially, losing about 3.4 bits per prime on average.

---

## 8. Algorithms

### Algorithm 1: Survivor Count Computation

```
Input: Prime p
Output: survivorCount(p)
1. Compute QR ← {x² mod p : x ∈ {0, ..., p-1}}
2. count ← 0
3. For a ∈ {0, ..., p-1}:
4.   For b ∈ {0, ..., p-1}:
5.     If (a²+b²) mod p ∉ QR: continue
6.     For c ∈ {0, ..., p-1}:
7.       If (a²+c²) mod p ∈ QR and
          (b²+c²) mod p ∈ QR and
          (a²+b²+c²) mod p ∈ QR:
8.         count ← count + 1
9. Return count
```

**Complexity:** Time O(p³), Space O(p). The early exit at step 5 reduces the effective cost by a factor of about 2 (since roughly half of pairs fail the first condition).

### Algorithm 2: Multi-Prime Sieve

```
Input: Bound N, set of primes P = {p₁, ..., pₖ}
Output: Set of candidate triples surviving all local conditions
1. For each p ∈ P:
2.   Compute lookup[p] ← {(a,b,c) ∈ (ℤ/pℤ)³ : survivor}
3. candidates ← {}
4. For (a,b,c) with 1 ≤ a,b,c ≤ N:
5.   If ∀ p ∈ P: (a mod p, b mod p, c mod p) ∈ lookup[p]:
6.     Add (a,b,c) to candidates
7. Return candidates
```

**Complexity:** Preprocessing O(Σ p³), query O(k) per candidate, total O(N³·k + Σ p³).

---

## 9. Discussion

### 9.1 Relation to Prior Work

The idea of studying perfect cuboids through modular conditions dates to classical work on Euler bricks. Our contribution is the *uniform* gap — a single δ that works for all primes — and its formal verification. Previous computational results established bounds at individual primes but not a universal constant.

### 9.2 The Projection Bound and Its Limitations

Our projection bound uses only the first of four conditions (a²+b² is a square). Using all four simultaneously would yield a much tighter bound — the actual density is about 15-30% rather than the 68-70% our projection gives. Formalizing the tighter bound requires either:
1. A fibered counting argument using two conditions simultaneously
2. Character sum estimates (Weil bounds)
3. An algebraic geometry approach via the quartic surface

### 9.3 Toward Full Local-Global Analysis

The uniform gap, combined with CRT multiplicativity, gives exponential decay of the survivor density along squarefree moduli. If the CRT multiplicativity theorem is formalized (it follows from the Chinese Remainder Theorem for rings), the result survivorCount(n)/n³ ≤ (7/10)^{ω(n)} would follow immediately.

---

## 10. Future Work

1. **Tighter gap:** Prove δ = 7/10 using multiple constraints simultaneously.
2. **CRT multiplicativity:** Formalize survivorCount(mn) = survivorCount(m)·survivorCount(n) for gcd(m,n) = 1.
3. **Asymptotic density:** Prove the limit of survivorCount(p)/p³ exists and determine its value using character sum decomposition.
4. **Primorial extinction:** Formally derive that survivorCount(p₁···pₖ)/(p₁···pₖ)³ → 0 as k → ∞.
5. **Character-sum formalization:** Build formal library for quadratic characters over finite fields and prove Weil-type bounds for the error term.

---

## References

[1] R. K. Guy, *Unsolved Problems in Number Theory*, 3rd edition, Springer, 2004. Problem D18.

[2] R. Rathbun, "The Integer Cuboid Table," unpublished tables, searches to 10^12.

[3] J. Leech, "The rational cuboid revisited," *Amer. Math. Monthly* 84 (1977), 518–533.

[4] A. Bremner, "The rational cuboid and a quartic surface," *Rocky Mountain J. Math.* 18 (1988), 105–121.

[5] F. Frink, "Almost perfect cuboids," *Fibonacci Quart.* 37 (1999), 73–83.
