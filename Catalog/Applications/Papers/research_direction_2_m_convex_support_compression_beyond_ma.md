# M-Convex Support Shadow Compression: Exchange Geometry Beyond Matroids

## Abstract

We develop a theory of degree shadows for M-convex support families, extending support compression results from matroid basis generating polynomials to the broader universe of Murota's discrete convex analysis. We define the degree-k shadow of a homogeneous support family — the set of degree-k exponent vectors dominated coordinatewise by some family element — and establish its fundamental properties. Our main positive result proves that for multiaffine M-convex supports (corresponding to matroid bases), the shadow cardinality is bounded by the binomial coefficient C(ω, k), where ω is the active coordinate count. We also prove tropical exchange stability: M-convex exchanges within equal-weight coordinate classes preserve the tropical face structure. Critically, we demonstrate by explicit counterexample that the binomial bound fails for general (non-multiaffine) M-convex sets, identifying multiaffinity as the essential structural hypothesis. All results are formalized and machine-verified.

**Keywords:** discrete convex analysis, M-convexity, symmetric exchange, Newton polytope, support compression, shadow bound, tropical initial form, Lorentzian polynomial, matroid basis, generalized permutohedron

---

## 1. Introduction

### 1.1 Background and Motivation

The study of Newton supports — the set of exponent vectors with nonzero coefficients in a multivariate polynomial — lies at the intersection of algebraic geometry, combinatorics, and optimization. A foundational result in Lorentzian polynomial theory (Brändén–Huh, 2020) establishes that the Newton support of a Lorentzian polynomial satisfies M-convex exchange, connecting Murota's discrete convex analysis (Murota, 2003) with combinatorial Hodge theory.

In the context of Lorentzian polynomial recognition, one encounters the problem of counting *surviving derivative branches*: when a homogeneous polynomial of degree d is differentiated d−k times, which degree-k monomials remain nonzero? This set — the degree-k shadow of the Newton support — controls the complexity of recursive recognition algorithms and Hessian analysis.

For matroid basis generating polynomials (multiaffine, positive coefficients), a compression theorem establishes that the number of surviving quadratic leaves is at most C(ω, d−2), where ω is the number of active variables. The natural question is whether this bound extends to all M-convex supports, not just matroid bases.

### 1.2 Contributions

1. **Definitions.** We formalize degree shadows, active coordinates, quadratic leaf sets, tropical weight functionals, and shadow hereditary exchange for arbitrary finitely-supported exponent families.

2. **Shadow containment and finiteness.** We prove that shadow elements use only active coordinates (Theorem 1) and that shadows are finite (Theorem 3).

3. **Multiaffine shadow bound.** We prove |shadow_k(S)| ≤ C(ω, k) when S is multiaffine (Theorem 4), via an injection argument into subsets of active coordinates.

4. **Counterexample.** We demonstrate that the binomial bound fails for non-multiaffine M-convex sets: the full degree-4 simplex on 3 variables gives 6 shadow elements versus C(3,2) = 3 (Section 5).

5. **Tropical stability.** We prove that M-convex exchanges within equal-weight coordinate classes preserve tropical weight (Theorem 5), providing a bridge to tropical geometry.

6. **Machine verification.** All positive results are formalized in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

- **Brändén–Huh (2020):** Lorentzian polynomials, M-convexity of supports, connection to log-concavity.
- **Murota (2003):** Discrete convex analysis; M-convex sets, valuated matroids, exchange axioms.
- **Adiprasito–Huh–Katz (2018):** Hodge theory for matroids; log-concavity of characteristic polynomial coefficients.
- **Schrijver (2003):** Matroid theory and combinatorial optimization; exchange axioms.

---

## 2. Definitions and Notation

### 2.1 Exponent Vectors and Total Degree

Let σ be a type of coordinate labels. An **exponent vector** is a finitely-supported function m : σ →₀ ℕ. The **total degree** is:

$$\text{totalDeg}(m) = \sum_{i \in \text{supp}(m)} m(i)$$

### 2.2 Active Coordinates

For a finite family S ⊆ (σ →₀ ℕ), the **active coordinate set** is:

$$\text{activeCoords}(S) = \bigcup_{m \in S} \text{supp}(m) = \{i \in \sigma \mid \exists m \in S,\, m(i) \neq 0\}$$

The **active width** is ω = |activeCoords(S)|.

### 2.3 M-Convex Exchange

A finite family S of exponent vectors satisfies the **M-convex symmetric exchange property** if:

$$\forall \alpha, \beta \in S,\, \forall i : \alpha(i) > \beta(i) \implies \exists j : \alpha(j) < \beta(j) \wedge (\alpha - e_i + e_j) \in S$$

When all elements are multiaffine (values in {0,1}), this reduces to the matroid basis exchange axiom.

### 2.4 Degree Shadow

The **degree-k shadow** of S is:

$$\text{shadow}_k(S) = \{u : \text{totalDeg}(u) = k \wedge \exists m \in S,\, u \leq m\}$$

where u ≤ m means u(i) ≤ m(i) for all i. The **quadratic leaf set** is shadow_{d−2}(S).

### 2.5 Tropical Weight and Initial Support

For a weight vector w : σ → ℤ, the **tropical dot product** is:

$$\text{tropDot}(w, m) = \sum_{i \in \text{supp}(m)} w(i) \cdot m(i)$$

The **initial support** is the set of weight-minimizers:

$$\text{init}_w(S) = \{m \in S \mid \text{tropDot}(w, m) = \min_{m' \in S} \text{tropDot}(w, m')\}$$

---

## 3. Main Results

### Theorem 1: Shadow Support Containment

**Statement.** For any u ∈ shadow_k(S), we have supp(u) ⊆ activeCoords(S) and totalDeg(u) = k.

**Proof sketch.** If u ∈ shadow_k(S), then u ≤ m for some m ∈ S. For any i ∈ supp(u), we have u(i) > 0, hence m(i) ≥ u(i) > 0, so i ∈ supp(m) ⊆ activeCoords(S). The degree condition is by definition.

### Theorem 2: Support Exclusion (Contradiction Proof)

**Statement.** If i ∉ activeCoords(S), then u(i) = 0 for all u ∈ shadow_k(S).

**Proof.** By contradiction. Suppose u(i) > 0 for some u ∈ shadow_k(S). Then i ∈ supp(u) ⊆ activeCoords(S) by Theorem 1, contradicting i ∉ activeCoords(S). □

### Theorem 3: Shadow Finiteness

**Statement.** shadow_k(S) is finite for any finite S.

**Proof sketch.** shadow_k(S) ⊆ ⋃_{m ∈ S} {u | u ≤ m}, and each set {u | u ≤ m} is finite (it is a product of finite intervals [0, m(i)]). A finite union of finite sets is finite. □

### Theorem 4: Multiaffine Shadow Bound

**Statement.** If every m ∈ S is multiaffine (m(i) ≤ 1 for all i), then:

$$|\text{shadow}_k(S)| \leq \binom{\omega}{k}$$

**Proof.** When m is multiaffine and u ≤ m, then u is also multiaffine (u(i) ≤ m(i) ≤ 1). A multiaffine vector of degree k is uniquely determined by its support, a k-element subset of coordinates. By Theorem 1, this support is contained in activeCoords(S), a set of size ω. The map u ↦ supp(u) is an injection from shadow_k(S) into the k-element subsets of activeCoords(S). Hence:

$$|\text{shadow}_k(S)| \leq |\{T \subseteq \text{activeCoords}(S) : |T| = k\}| = \binom{\omega}{k} \qquad \square$$

**Corollary (Quadratic Leaf Bound).** For multiaffine S of degree d:

$$|\text{LeafSet}_2(S)| \leq \binom{\omega}{d-2}$$

### Theorem 5: Tropical Exchange Stability

**Statement.** Let S satisfy M-convex exchange, let α, β ∈ S with α(i) > β(i), and let γ = α − e_i + e_j ∈ S be an exchange witness. If w(i) = w(j), then:

$$\text{tropDot}(w, \gamma) = \text{tropDot}(w, \alpha)$$

**Proof.** tropDot(w, γ) = tropDot(w, α) − w(i) + w(j) = tropDot(w, α) since w(i) = w(j). □

**Significance.** This means M-convex exchanges within weight-equal coordinate classes preserve the initial support face. It is the algebraic mechanism underlying tropical stability of M-convex structure.

---

## 4. Algorithms

### Algorithm 1: Shadow Computation

```
Input: Finite family S, target degree k
Output: shadow_k(S)

shadow ← ∅
for each m ∈ S:
    for each u with totalDeg(u) = k and u ≤ m:
        shadow ← shadow ∪ {u}
return shadow
```

**Complexity:** O(|S| · C(n+k−1, k)) time, O(|shadow|) space, where n = dim(S).

### Algorithm 2: Shadow Certificate

```
Input: Finite family S, target degree k
Output: For each u ∈ shadow_k(S), a witness m ∈ S with u ≤ m

cert ← ∅
for each u ∈ shadow_k(S):
    find m ∈ S with u ≤ m
    cert[u] ← m
return cert
```

**Complexity:** O(|shadow| · |S| · n) time.

### Algorithm 3: M-Convex Verification

```
Input: Finite family S
Output: True iff S satisfies M-convex exchange

for each α ∈ S:
    for each β ∈ S:
        for each i with α(i) > β(i):
            if no j exists with α(j) < β(j) and α−e_i+e_j ∈ S:
                return False
return True
```

**Complexity:** O(|S|² · n²) time.

### Algorithm 4: Tropical Initial Support

```
Input: Finite family S, weight vector w
Output: init_w(S)

min_val ← min_{m ∈ S} tropDot(w, m)
return {m ∈ S : tropDot(w, m) = min_val}
```

**Complexity:** O(|S| · n) time.

---

## 5. Counterexample: Non-Multiaffine Failure

**Construction.** Let S = {(a,b,c) ∈ ℕ³ : a+b+c = 4} (all degree-4 vectors on 3 coordinates).

- |S| = C(3+4−1, 4) = C(6,4) = 15
- ω = 3 (all coordinates active)
- S is M-convex: every exchange α−e_i+e_j preserves degree and stays in ℕ³
- shadow_2(S) = {(a,b,c) ∈ ℕ³ : a+b+c = 2} has |shadow_2| = C(4,2) = 6
- Bound: C(3,2) = 3

**Violation:** 6 > 3. The bound C(ω, k) fails by a factor of 2.

**Root cause:** Non-multiaffine elements produce shadow vectors with multiplicities > 1 (e.g., (2,0,0)), which cannot arise from 0/1 supports. The injection argument of Theorem 4 fails because multiaffine dominated vectors no longer biject with support subsets.

### Computational Verification

| Family | d | ω | k=d−2 | |shadow_k| | C(ω,k) | Holds? |
|--------|---|---|-------|-----------|---------|--------|
| U_{3,5} | 3 | 5 | 1 | 5 | 5 | ✓ |
| U_{4,6} | 4 | 6 | 2 | 15 | 15 | ✓ |
| Full Δ₃,₃ | 3 | 3 | 1 | 3 | 3 | ✓ |
| Full Δ₃,₄ | 4 | 3 | 2 | 6 | 3 | ✗ |
| Schur s₍₂,₁₎ | 3 | 3 | 1 | 3 | 3 | ✓ |
| Schur s₍₃,₁₎ | 4 | 3 | 2 | 6 | 3 | ✗ |

---

## 6. Tropical Bridge

The tropical exchange stability theorem (Theorem 5) provides a bridge between discrete convex analysis and tropical geometry. In tropical geometry, an initial form of a polynomial under a weight vector w consists of the terms that minimize w · m. The initial support is the set of exponent vectors achieving this minimum.

Our theorem shows that within coordinate classes of equal weight, M-convex exchange witnesses preserve tropical cost. This has several consequences:

1. **Tropical face structure:** For generic weight vectors (no two coordinates of equal weight), the initial support may not be M-convex. But for weight vectors with symmetries (equal weights on certain coordinates), exchange witnesses within symmetric groups are tropically stable.

2. **Regular subdivisions:** The initial supports under varying weight vectors define the face structure of the Newton polytope's normal fan. Tropical stability implies that M-convex structure interacts coherently with this subdivision.

3. **Tropical degeneration:** When studying limits of polynomial families parameterized by a tropical parameter t, M-convex supports degenerate to initial supports. Our theorem guarantees that exchange structure partially survives this degeneration.

---

## 7. Discussion

### 7.1 The Role of Multiaffinity

Our results sharply delineate the role of multiaffinity in support compression. The exchange property alone ensures shadow containment, finiteness, and tropical stability. But the sharp binomial bound requires multiaffinity. This is not a limitation of our proof technique but a genuine mathematical barrier: the counterexample shows that non-multiaffine M-convex sets can have shadow sizes exceeding C(ω, k).

### 7.2 Connections to Lorentzian Polynomials

Brändén and Huh showed that Lorentzian polynomials have M-convex Newton supports. Our Theorem 4 immediately implies that *multiaffine* Lorentzian polynomials (equivalently, basis generating polynomials of matroids) satisfy the quadratic leaf bound. For non-multiaffine Lorentzian polynomials, the shadow can be larger, but it is still finite and contained in the active coordinate simplex.

### 7.3 Limitations

1. Our multiaffine shadow bound is essentially the matroid theorem in disguise — the injection argument does not use M-convex exchange in any essential way; it uses only multiaffinity and domination. The exchange property is needed for the tropical stability theorem and for ensuring that the family has constant degree.

2. We have not established a tight bound for non-multiaffine M-convex sets between C(ω, k) and C(ω+k−1, k). This is an open problem.

3. The shadow hereditary exchange property is defined but not proved in general. Whether the shadow of an M-convex set is itself M-convex remains an interesting open question.

---

## 8. Future Work

1. **Tight non-multiaffine bounds:** Determine the exact maximum of |shadow_k(S)| over all M-convex S with given ω and d.

2. **Shadow M-convexity:** Prove or disprove that shadow_k(S) is M-convex when S is.

3. **Algorithmic certificates:** Develop sublinear-time certification algorithms for shadow membership using exchange decomposition trees.

4. **Lorentzian extension:** Determine whether Lorentzian polynomials (which have additional positivity constraints beyond M-convex support) satisfy tighter shadow bounds than general M-convex sets.

5. **Tropical face M-convexity:** Characterize when initial supports of M-convex families are themselves M-convex.

---

## References

1. P. Brändén and J. Huh. Lorentzian polynomials. *Annals of Mathematics*, 192(3):821–891, 2020.

2. K. Murota. *Discrete Convex Analysis*. SIAM Monographs on Discrete Mathematics and Applications, 2003.

3. K. Adiprasito, J. Huh, and E. Katz. Hodge theory for combinatorial geometries. *Annals of Mathematics*, 188(2):381–452, 2018.

4. A. Schrijver. *Combinatorial Optimization: Polyhedra and Efficiency*. Springer, 2003.

5. J. Edmonds. Submodular functions, matroids, and certain polyhedra. In *Combinatorial Structures and their Applications*, pages 69–87. Gordon and Breach, 1970.

6. A. Postnikov. Permutohedra, associahedra, and beyond. *International Mathematics Research Notices*, 2009(6):1026–1106, 2009.
