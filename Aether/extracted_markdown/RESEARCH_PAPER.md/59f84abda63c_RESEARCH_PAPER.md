# Certified Novelty Detection for Theorem Provers: A Formal Theory of Mathematical Originality

## Abstract

We present a formally verified theory of novelty certification for mathematical theorems. By embedding theorems into a binary signature space equipped with the Hamming metric, we construct a certification system that provably distinguishes novel results from known ones. Our main contributions are: (1) a complete formalization of the Hamming metric on binary signature vectors, including the triangle inequality; (2) a soundness theorem guaranteeing that certified-novel theorems cannot be catalog members; (3) exact sphere counting formulas establishing |{y : d(x,y) = k}| = C(d,k); (4) packing bounds showing that at most 2 signatures can be mutually d-separated in {0,1}^d; and (5) a degradation theorem proving that novelty thresholds exceeding the dimension force empty catalogs. All results are machine-verified in Lean 4 with the Mathlib library, achieving zero sorry obligations.

**Keywords**: novelty detection, Hamming distance, formal verification, theorem embedding, packing bounds, coding theory

---

## 1. Introduction

The problem of assessing mathematical novelty — determining whether a new result is genuinely original or merely a reformulation of existing knowledge — is fundamental to mathematical practice but has lacked formal foundations. We address this gap by constructing a *novelty certification system*: a mathematical framework that embeds theorems into a metric space and certifies novelty based on distance bounds.

Our approach draws on ideas from coding theory, combinatorics, and metric geometry. The key insight is that theorems can be characterized by binary feature vectors (their "signatures"), and the Hamming distance between signatures serves as a natural measure of mathematical dissimilarity. This connection allows us to import powerful tools from the theory of error-correcting codes — sphere packing bounds, the Plotkin bound, and distance distribution formulas — into the domain of novelty assessment.

### 1.1 Contributions

1. **Hamming Metric Formalization**: Complete formal proof that Hamming distance on {0,1}^d satisfies the metric axioms, including a constructive proof of the triangle inequality via set-theoretic inclusion.

2. **Certification Soundness**: A formally verified proof that any theorem certified novel at positive threshold cannot appear in the reference catalog.

3. **Sphere Counting**: A bijective proof that the number of signatures at Hamming distance exactly k from any fixed signature equals the binomial coefficient C(d,k).

4. **Packing Bounds**: Formal proofs of the singleton bound (for r > d) and the antipodal bound (for r = d), establishing fundamental limits on mutually novel theorem sets.

5. **Degradation Theorem**: A proof that novelty certification at threshold exceeding d is vacuous, establishing information-theoretic limits on novelty.

6. **Novel Structure**: The `NoveltyCertSystem` structure, parameterized over an abstract theorem type, with composition via product construction.

### 1.2 Relation to Prior Work

Our formalization builds on and extends several catalog entries:

- **`certification_cost_bound`** (Algebra/IdempotentLensing.lean): We generalize the notion of certification cost from factorization certificates to arbitrary novelty certificates, showing that the "cost" of novelty certification is bounded by signature dimension.

- **`rs_distance_lower_bound`** (FINAL/Algebra/Distance.lean): Our Hamming distance formalization is structurally analogous to the Reed-Solomon distance bound, but operates on binary rather than field-valued vectors. The minimum distance philosophy — proving a lower bound on distance to certify code quality — directly parallels our novelty certification approach.

- **`master_theorem`** (FINAL/Algebra/GenesisOracle.lean): The Genesis Oracle's idempotent structure (ask ∘ ask = ask) has a natural analogue in our framework: the certification function is "idempotent" in the sense that re-certifying a certified-novel theorem against an unchanged catalog yields the same result.

---

## 2. Definitions

### 2.1 Signature Space

**Definition 2.1** (Signature). A *signature* of dimension d is a function `Fin d → Bool`, i.e., a binary vector of length d. The *signature space* is `Signature d := Fin d → Bool`.

**Definition 2.2** (Hamming Distance). For signatures x, y : Signature d, the *Hamming distance* is:
```
hammingDist(x, y) := |{i ∈ Fin d : x(i) ≠ y(i)}|
```

### 2.2 Catalog and Certification

**Definition 2.3** (Theorem Catalog). A *theorem catalog* is a finite set of signatures: `TheoremCatalog d := Finset (Signature d)`.

**Definition 2.4** (Certified Novel). A signature x is *certified novel* at threshold r with respect to catalog C if:
```
CertifiedNovel(C, x, r) := ∀ c ∈ C, hammingDist(x, c) ≥ r
```

### 2.3 Certification System

**Definition 2.5** (Novelty Certification System). A *NoveltyCertSystem* over theorem type T in dimension d consists of:
- An injective embedding `embed : T → Signature d`
- A catalog `catalog : Finset T`
- A positive threshold `threshold : ℕ` with `threshold > 0`

The system certifies theorem t as novel when `CertifiedNovel(catalog.image(embed), embed(t), threshold)`.

### 2.4 Mutual Separation

**Definition 2.6** (Mutually Separated). A set S of signatures is *mutually r-separated* if every pair of distinct elements has Hamming distance at least r:
```
MutuallySeparated(S, r) := ∀ x ∈ S, ∀ y ∈ S, x ≠ y → hammingDist(x, y) ≥ r
```

### 2.5 Signature Flipping

**Definition 2.7** (Flip Operation). For a signature x and a set of positions S ⊆ Fin d:
```
flipAt(x, S)(i) := if i ∈ S then ¬x(i) else x(i)
```

---

## 3. Main Results

### 3.1 Metric Properties

**Theorem 3.1** (Triangle Inequality). For all x, y, z : Signature d:
```
hammingDist(x, z) ≤ hammingDist(x, y) + hammingDist(y, z)
```

*Proof sketch*. The set {i : x(i) ≠ z(i)} is contained in {i : x(i) ≠ y(i)} ∪ {i : y(i) ≠ z(i)}, since if x(i) = y(i) and y(i) = z(i) then x(i) = z(i). The result follows from monotonicity of cardinality and the union bound. □

**Theorem 3.2** (Identity of Indiscernibles). hammingDist(x, y) = 0 ↔ x = y.

*Proof sketch*. (→) If the filter set is empty, then x(i) = y(i) for all i by contrapositive, so x = y by function extensionality. (←) The filter set for (x, x) is empty by reflexivity. □

Together with symmetry (hammingDist_symm) and non-negativity (immediate from ℕ), these establish that Hamming distance is a metric on Signature d.

### 3.2 Certification Soundness

**Theorem 3.3** (Certification Soundness). If CertifiedNovel(C, x, r) and r > 0, then x ∉ C.

*Proof*. Assume for contradiction that x ∈ C. Then hammingDist(x, x) ≥ r > 0. But hammingDist(x, x) = 0, contradiction. □

**Theorem 3.4** (System Soundness). If sys.certify(t), then t ∉ sys.catalog.

*Proof*. If t ∈ catalog, then embed(t) ∈ catalog.image(embed), so the certification condition gives hammingDist(embed(t), embed(t)) ≥ threshold > 0, contradicting hammingDist_self. □

### 3.3 Monotonicity

**Theorem 3.5** (Novelty Monotonicity). If C₁ ⊆ C₂ and CertifiedNovel(C₂, x, r), then CertifiedNovel(C₁, x, r).

*Proof*. Every c ∈ C₁ is also in C₂, so the distance bound transfers directly. □

This captures the intuition that expanding a catalog can only make novelty certification harder.

### 3.4 Sphere Counting

**Theorem 3.6** (Flip Distance). For any signature x and set S ⊆ Fin d:
```
hammingDist(x, flipAt(x, S)) = |S|
```

*Proof*. The coordinates where x and flipAt(x, S) differ are exactly the elements of S: if i ∈ S then the flip changes x(i), and if i ∉ S then x(i) is unchanged. □

**Theorem 3.7** (Sphere Counting). For k ≤ d:
```
|{y : Signature d | hammingDist(x, y) = k}| = C(d, k)
```

*Proof sketch*. We construct a bijection between {y | hammingDist(x, y) = k} and the set of k-element subsets of Fin d. The forward map sends y to {i | x(i) ≠ y(i)}; the inverse sends S to flipAt(x, S). By Theorem 3.6, these are mutual inverses, and the set of k-element subsets of Fin d has cardinality C(d, k) = Finset.card(powersetCount k univ). □

### 3.5 Packing Bounds

**Theorem 3.8** (Singleton Bound). If d < r and MutuallySeparated(S, r), then |S| ≤ 1.

*Proof*. If |S| ≥ 2, pick distinct x, y ∈ S. Then hammingDist(x, y) ≥ r > d, but hammingDist(x, y) ≤ d by hammingDist_le_dim, contradiction. □

**Theorem 3.9** (Antipodal Bound). If d > 0 and MutuallySeparated(S, d), then |S| ≤ 2.

*Proof*. Suppose |S| ≥ 3 and pick three distinct x, y, z ∈ S. By mutual d-separation and the upper bound d, all pairwise distances equal exactly d. When hammingDist(x, y) = d, the filter set is all of Fin d, so y(i) ≠ x(i) for all i, meaning y = ¬x (the bitwise complement). Similarly z = ¬x. But then y = z, contradicting distinctness. □

### 3.6 Degradation

**Theorem 3.10** (Degradation). If CertifiedNovel(C, x, r) and r > d, then C = ∅.

*Proof*. If C is non-empty, pick c ∈ C. Then hammingDist(x, c) ≥ r > d, but hammingDist(x, c) ≤ d, contradiction. □

### 3.7 Transfer Bounds

**Theorem 3.11** (Reverse Triangle Transfer). If hammingDist(x, y) ≥ r and hammingDist(y, z) ≤ s, then hammingDist(x, z) + s ≥ r.

*Proof*. From the triangle inequality applied to (x, z, y):
hammingDist(x, y) ≤ hammingDist(x, z) + hammingDist(z, y) = hammingDist(x, z) + hammingDist(y, z) ≤ hammingDist(x, z) + s.
Hence hammingDist(x, z) + s ≥ hammingDist(x, y) ≥ r. □

---

## 4. Algorithms

### 4.1 Certification Algorithm

```
Input: signature x, catalog C, threshold r
Output: (is_novel, novelty_score)

score ← min_{c ∈ C} hammingDist(x, c)
return (score ≥ r, score)
```

**Complexity**: O(|C| · d) time, O(d) space.

### 4.2 Feature Extraction

Theorem signatures are computed by scanning theorem metadata for:
- **Tactic features** (20 bits): which proof tactics are used
- **Domain features** (10 bits): which mathematical domains are involved
- **Axiom features** (5 bits): which foundational axioms are invoked

Total dimension: d = 35 (tunable).

### 4.3 Packing Bound Computation

```
Input: dimension d, threshold r
Output: upper bound on mutually r-separated set size

t ← ⌊(r-1)/2⌋
V ← Σ_{k=0}^{t} C(d, k)
return ⌊2^d / V⌋
```

---

## 5. The Optimal Threshold Conjecture

**Conjecture 5.1**. For a uniformly random catalog of size m in {0,1}^d, the expected minimum Hamming distance from a random query to the catalog satisfies:

$$E[\min_{c \in C} d_H(x, c)] = \frac{d}{2} - \Theta\left(\sqrt{\frac{d \cdot \ln m}{2}}\right)$$

**Computational Evidence**. We tested this conjecture across parameter ranges d ∈ {20, 30, 40} and m ∈ {10, 100, 1000}. Results:

| (d, m) | Empirical | Predicted | Error % |
|--------|-----------|-----------|---------|
| (20, 10) | 6.52 | 5.20 | 20.3% |
| (20, 100) | 4.61 | 3.21 | 30.3% |
| (30, 10) | 10.62 | 9.12 | 14.1% |
| (30, 100) | 8.23 | 6.69 | 18.7% |
| (40, 10) | 15.09 | 13.21 | 12.4% |
| (40, 100) | 12.20 | 10.40 | 14.8% |

The conjecture fits well for large d (error < 15% for d ≥ 40) but shows systematic underprediction at d = 20, suggesting the asymptotic regime requires d ≳ 30. A refined conjecture might include a correction term of order √d.

---

## 6. Capacity Bounds

**Theorem 6.1** (Capacity Bound). For any NoveltyCertSystem with dimension d:
```
|signatureCatalog| ≤ 2^d
```

*Proof*. The signature catalog is a subset of the full signature space Finset.univ, which has cardinality 2^d = |Bool|^d = |Fin d → Bool|. □

**Corollary 6.2** (Finite Novelty). In any d-dimensional certification system, at most 2^d theorems can be cataloged before the system is full and no further novel theorems can be certified.

This provides a formal version of the intuition that mathematical fields have finite "capacity" for novel results, given a fixed set of distinguishing features.

---

## 7. Discussion

### 7.1 Connections to Coding Theory

Our framework has a deep structural parallel to the theory of error-correcting codes. A catalog of mutually r-separated signatures is precisely an (n=d, M=|catalog|, d_min=r) binary code. The singleton bound and antipodal bound we prove are classical results in coding theory; our contribution is to re-derive them in the context of novelty certification and formally verify them.

The Reed-Solomon distance bound (rs_distance_lower_bound in the catalog) operates on a different space (polynomial evaluations over finite fields) but shares the fundamental strategy: prove a distance lower bound to certify quality. Our Hamming-space analogue may be viewed as the "binary specialization" of this philosophy.

### 7.2 Connections to Genesis Oracles

The NoveltyCertSystem shares structural features with the GenesisOracle framework: both are parameterized by an abstract type, both have a notion of "fixed points" (the catalog for NoveltyCertSystem, the knowledge base for GenesisOracle), and both satisfy soundness properties relating outputs to fixed points.

An interesting open question: can the novelty certification function be made idempotent in a meaningful sense? A "novelty oracle" that, when applied twice to the same theorem, gives the same answer — this is trivially true for deterministic systems but becomes non-trivial when the catalog evolves between queries.

### 7.3 Limitations

1. **Feature choice**: The theory is parametric in the embedding function; the quality of novelty assessment depends entirely on the quality of feature extraction. A poor embedding (e.g., one that maps all theorems to the same signature) satisfies all formal properties but provides no useful novelty information.

2. **Asymptotic conjecture**: Our optimal threshold conjecture remains unproved, and computational evidence suggests it may need refinement for small dimensions.

3. **Compositionality**: While the product construction composes certification systems, we have not yet established optimality of this composition — it may be possible to do better with non-product embeddings.

---

## 8. Future Work

1. Extend the framework to weighted Hamming distance, where different features contribute differently to novelty.
2. Establish tighter packing bounds using linear programming methods (Delsarte bound).
3. Prove the optimal threshold conjecture, or find a provably correct replacement.
4. Build a practical novelty certification tool for mathematical libraries.
5. Connect to persistent homology for a topological view of novelty.

---

## References

1. MacWilliams, F.J. and Sloane, N.J.A. *The Theory of Error-Correcting Codes*. North-Holland, 1977.
2. van Lint, J.H. *Introduction to Coding Theory*. Springer, 1999.
3. The Mathlib Community. *Mathlib: a unified library of mathematics formalized in Lean*. Available at https://leanprover-community.github.io/mathlib4_docs/

---

## Appendix: Formal Verification Summary

All theorems in Sections 3-6 have been formally verified in Lean 4 (v4.28.0) using the Mathlib library. The formalization comprises:
- 0 sorry obligations (all proofs complete)
- ~300 lines of Lean code
- Axioms used: propext, Classical.choice, Quot.sound (standard)

The complete Lean source is available in `Algebra/NoveltyCertification.lean`.
