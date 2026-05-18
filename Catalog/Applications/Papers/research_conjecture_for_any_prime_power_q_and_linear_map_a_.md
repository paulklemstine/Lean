# Rank–Entropy Laws, Tropical Fiber Entropy, and Reversible Thermodynamics over Finite Fields

## Abstract

We establish a rigorous formal bridge between finite-field linear algebra, Shannon information theory, tropical (max-plus) entropy, and reversible computation. Our main results are: (1) **The Algebraic Landauer Principle** — for any linear map A : V → W over a finite field K with |K| = q, the entropy defect under uniform input is exactly dim(ker A) · log q; (2) **The Shannon–Tropical Equality** — for linear maps over finite fields, the Shannon entropy loss (average-case) and tropical entropy loss (worst-case fiber) coincide exactly, identifying linear algebra as the fixed-point regime of a general inequality; (3) **Garbage Compression Bounds** — the erasure cost of garbage in a reversible implementation is controlled by the compressed range size rather than the raw ancilla space. All results are accompanied by complete machine-checked proofs with no unverified assumptions.

**Keywords:** finite-field entropy, Landauer principle, reversible computing, tropical information theory, rank-nullity thermodynamics, constant-fiber maps

---

## 1. Introduction

### 1.1 Motivation

Landauer's principle (1961) asserts that logically irreversible computation necessarily dissipates energy: erasing one bit costs at least kT ln 2 joules. While the physical principle has been experimentally verified, its mathematical content — the precise relationship between computational irreversibility and information loss — has lacked a fully formalized treatment connecting linear algebra, information theory, and tropical semantics.

### 1.2 Contributions

We make three main contributions:

1. **Theorem A (Algebraic Landauer Principle).** We prove that for a linear map A over a finite field GF(q), the entropy defect — defined as log|V| − log|range(A)| — equals exactly dim(ker A) · log q. This transforms the rank-nullity theorem into a thermodynamic identity.

2. **Theorem B (Shannon–Tropical Bridge).** We define tropical entropy loss as log(max fiber size) and prove:
   - Shannon ≤ Tropical for all finite functions under uniform input (general inequality);
   - Equality holds for constant-fiber maps;
   - Linear maps over finite fields have constant fibers (all fibers are cosets of the kernel).

3. **Theorem C (Garbage Compression).** We prove that if the garbage range admits an injective compression to a type δ, then log|range(g)| ≤ log|δ|, yielding strictly tighter erasure bounds than the naive ancilla size.

### 1.3 Related Work

- **Landauer (1961):** Original statement of irreversibility-dissipation link.
- **Bennett (1973):** Reversible computation via garbage bits.
- **Shannon (1948):** Information entropy and channel capacity.
- **Tropical geometry:** Maclagan & Sturmfels (2015); applications to optimization and algebraic geometry.
- **Formal verification of information theory:** Affeldt et al. (2020), information theory in Coq.

Our work differs from prior formalization efforts by establishing the *exact* algebraic Landauer principle — not an inequality or asymptotic bound, but a precise equality connecting kernel dimension to entropy units — and by introducing tropical entropy as a formal bridge between average-case and worst-case analysis.

---

## 2. Definitions and Notation

### 2.1 Setting

Let K be a finite field with |K| = q (a prime power). Let V, W be finite-dimensional K-vector spaces with dim_K(V) = n. All spaces are equipped with Fintype instances, so |V| = q^n.

### 2.2 Entropy Defect

**Definition.** The *entropy defect* of a function f : α → β between finite types is:

$$\Delta H(f) := \log|\alpha| - \log|\text{range}(f)|$$

This equals the Shannon entropy loss H(X) − H(f(X)) when X is uniformly distributed on α.

### 2.3 Tropical Entropy Loss

**Definition.** The *tropical entropy loss* of f : α → β is:

$$L_{\text{trop}}(f) := \log \max_{y \in \text{range}(f)} |f^{-1}(y)|$$

This is the logarithm of the maximum fiber cardinality.

### 2.4 Constant-Fiber Maps

**Definition.** A function f : α → β has *constant fibers* if all nonempty fibers have equal cardinality:

$$\forall y_1, y_2 \in \text{range}(f), \quad |f^{-1}(y_1)| = |f^{-1}(y_2)|$$

---

## 3. Main Results

### 3.1 Theorem A: The Algebraic Landauer Principle

**Theorem 3.1 (Fiber Cardinality).** Let A : V →_K W be a K-linear map. For any y ∈ range(A):

$$|A^{-1}(y)| = |\ker(A)|$$

*Proof sketch.* Fix x₀ with A(x₀) = y. The map φ : A^{-1}(y) → ker(A) defined by φ(x) = x − x₀ is a bijection, with inverse ψ(k) = x₀ + k. Bijectivity follows from linearity: A(x) = y iff A(x − x₀) = 0 iff x − x₀ ∈ ker(A). □

**Theorem 3.2 (Cardinality Rank-Nullity).** For any K-linear map A : V → W:

$$|\text{range}(A)| \cdot |\ker(A)| = |V|$$

*Proof sketch.* By the First Isomorphism Theorem, V/ker(A) ≅ range(A) as K-vector spaces, so |V/ker(A)| = |range(A)|. By Lagrange's theorem for additive groups, |V| = |V/ker(A)| · |ker(A)|. □

**Theorem 3.3 (Algebraic Landauer Principle).** For a K-linear map A : V → W between finite-dimensional K-vector spaces:

$$\Delta H(A) = \dim_K(\ker A) \cdot \log|K|$$

*Proof sketch.* Compute:

$$\Delta H(A) = \log|V| - \log|\text{range}(A)|$$
$$= \log\frac{|V|}{|\text{range}(A)|}$$
$$= \log|\ker(A)| \quad \text{(by Theorem 3.2)}$$
$$= \log(q^{\dim(\ker A)}) \quad \text{(since } |\ker(A)| = q^{\dim(\ker A)}\text{)}$$
$$= \dim_K(\ker A) \cdot \log q \quad \square$$

**Theorem 3.4 (Rank-Nullity Entropy Form).** Equivalently:

$$\Delta H(A) = (\dim_K(V) - \dim_K(\text{range } A)) \cdot \log|K|$$

This follows immediately from Theorem 3.3 and the rank-nullity theorem dim(ker A) + dim(range A) = dim(V).

### 3.2 Theorem B: The Shannon–Tropical Bridge

**Theorem 3.5 (Shannon ≤ Tropical).** For any f : α → β with α nonempty:

$$\Delta H(f) \leq L_{\text{trop}}(f)$$

*Proof sketch.* We have ΔH(f) = log(|α|/|range(f)|) = log(average fiber size). Since the average of a set of positive numbers is at most the maximum, average fiber size ≤ max fiber size = exp(L_trop(f)). Applying log (which is monotone) gives the result. □

**Theorem 3.6 (Equality for Constant-Fiber Maps).** If f has constant fibers, then:

$$\Delta H(f) = L_{\text{trop}}(f)$$

*Proof sketch.* If all fibers have size c, then |α| = |range(f)| · c, so ΔH(f) = log(c). Also max fiber = c, so L_trop(f) = log(c). □

**Theorem 3.7 (Linear Maps Have Constant Fibers).** Every K-linear map A : V → W has constant fibers.

*Proof.* Immediate from Theorem 3.1: every nonempty fiber has cardinality |ker(A)|. □

**Corollary 3.8 (Shannon–Tropical Equality for Linear Maps).** For K-linear maps:

$$\Delta H(A) = L_{\text{trop}}(A) = \dim_K(\ker A) \cdot \log|K|$$

### 3.3 Theorem C: Garbage Compression

**Theorem 3.9 (Erasure Cost Compression).** If g : α → γ has range admitting an injection C : range(g) ↪ δ, then:

$$\log|\text{range}(g)| \leq \log|δ|$$

*Proof.* By injectivity, |range(g)| ≤ |δ|. Apply monotonicity of log. □

**Theorem 3.10 (Strict Improvement).** If additionally |δ| < |γ| and δ is nonempty:

$$\log|δ| < \log|γ|$$

This shows that compression strictly reduces the erasure cost bound.

**Theorem 3.11 (Parity Entropy Defect).** The parity function on n ≥ 1 bits has:

$$\Delta H(\text{parity}_n) = (n-1) \cdot \log 2$$

*Proof.* The domain has 2^n elements, the range has exactly 2 elements (both parities are achieved for n ≥ 1), so ΔH = log(2^n) − log(2) = (n−1)·log 2. □

---

## 4. Algorithms

### 4.1 Algorithm: Entropy Defect via Rank Computation

For a linear map given by an m × n matrix A over GF(q):

```
ALGORITHM: LinearEntropyDefect(A, q)
INPUT: m × n matrix A over GF(q), field size q
OUTPUT: entropy defect ΔH(A) in nats

1. Compute r = rank(A) via Gaussian elimination over GF(q)
2. Set d = n − r                          // kernel dimension
3. Return d × ln(q)                       // entropy defect

TIME: O(min(m,n) · m · n)     // Gaussian elimination
SPACE: O(m · n)
```

This is exponentially faster than the naive approach of enumerating all q^n inputs.

### 4.2 Algorithm: Tropical Entropy Loss

```
ALGORITHM: TropicalEntropyLoss(f, domain)
INPUT: Function f, enumerated domain
OUTPUT: tropical entropy loss L_trop(f)

1. Initialize fiber_counts = empty dictionary
2. For each x in domain:
     y = f(x)
     fiber_counts[y] += 1
3. Return ln(max(fiber_counts.values()))

TIME: O(|domain| · T_f)
SPACE: O(|range(f)|)
```

### 4.3 Algorithm: Garbage Compression Analysis

```
ALGORITHM: GarbageCompressionBound(g, domain)
INPUT: Garbage function g, enumerated domain
OUTPUT: compressed erasure cost bound

1. Compute R = {g(x) : x ∈ domain}       // range of garbage
2. compressed_size = |R|                   // optimal compression
3. Return ln(compressed_size)              // compressed cost

TIME: O(|domain| · T_g)
SPACE: O(|R|)
```

---

## 5. Applications

### 5.1 Coding Theory

A linear code C over GF(q) with parity-check matrix H has syndrome map s(x) = Hx. By Theorem 3.3, the entropy cost of syndrome extraction is:

$$\Delta H(s) = \dim(\ker H) \cdot \log q = k \cdot \log q$$

where k is the code dimension. For the [7,4,3] binary Hamming code, this equals 4 · log 2 ≈ 2.77 nats.

### 5.2 Boolean Circuit Design

Standard Boolean gates analyzed over GF(2):

| Gate | Inputs | Outputs | Rank | ker dim | Entropy Loss (bits) |
|------|--------|---------|------|---------|---------------------|
| XOR  | 2      | 1       | 1    | 1       | 1.0                 |
| AND  | 2      | 1       | —    | —       | 1.0 (nonlinear)     |
| OR   | 2      | 1       | —    | —       | 1.0 (nonlinear)     |
| NOT  | 1      | 1       | 1    | 0       | 0.0 (bijective)     |

Note: AND and OR are *not* linear over GF(2), so Theorem 3.3 does not apply directly, but their entropy losses happen to match because they also have constant fibers.

### 5.3 Network Coding

For a linear network code with transfer matrix A over GF(q), the information delivered to sinks equals rank(A) · log q, and the information lost in transit equals dim(ker A) · log q. This gives network engineers an exact formula for information flow efficiency.

---

## 6. Computational Experiments

### 6.1 Exhaustive GF(2) Matrix Survey

We verified the algebraic Landauer principle for all 64 binary 2×3 matrices:

| Rank | ker dim | Entropy Defect | Formula | Match | Count |
|------|---------|---------------|---------|-------|-------|
| 0    | 3       | 2.0794        | 2.0794  | ✓     | 1     |
| 1    | 2       | 1.3863        | 1.3863  | ✓     | 21    |
| 2    | 1       | 0.6931        | 0.6931  | ✓     | 42    |

All 64 matrices satisfy ΔH = dim(ker) · log 2 exactly. All have constant fibers. Shannon equals tropical for all.

### 6.2 Parity Function

| n | Domain | Range | Entropy Defect | (n−1)·log 2 | Match |
|---|--------|-------|---------------|-------------|-------|
| 1 | 2      | 2     | 0.0000        | 0.0000      | ✓     |
| 2 | 4      | 2     | 0.6931        | 0.6931      | ✓     |
| 3 | 8      | 2     | 1.3863        | 1.3863      | ✓     |
| 4 | 16     | 2     | 2.0794        | 2.0794      | ✓     |
| 5 | 32     | 2     | 2.7726        | 2.7726      | ✓     |

### 6.3 Nonlinear Comparison

For the AND function f(a,b) = (a ∧ b) on {0,1}²:
- Fibers: f⁻¹(0) = {(0,0), (0,1), (1,0)}, f⁻¹(1) = {(1,1)}
- Shannon loss = log(4) − log(2) = log(2) ≈ 0.693
- Tropical loss = log(3) ≈ 1.099
- Gap = 0.406 > 0 (strict inequality, as expected for non-constant fibers)

---

## 7. Discussion

### 7.1 Interpretation

The algebraic Landauer principle reinterprets rank-nullity as a thermodynamic conservation law. In this view:
- The **domain** V is the set of microstates
- The **range** of A is the set of macrostates
- **Kernel cosets** are equivalence classes of indistinguishable microstates
- **Entropy defect** = log(number of microstates per macrostate) = Boltzmann entropy of each macrostate

This is a finite, exact version of the Boltzmann entropy formula S = k log W.

### 7.2 The Tropical Fixed Point

The equality of Shannon and tropical entropy for linear maps identifies a *fixed point* in the space of entropy functionals. Most deformation from Shannon toward tropical semantics changes the numerical value. But for linear maps, the geometry is so rigid — every fiber exactly equal — that no deformation occurs.

This suggests that linear maps play a role in tropical information theory analogous to Gaussian distributions in classical information theory: they are the fixed points around which the theory organizes.

### 7.3 Limitations

- Our results are limited to finite fields and finite-dimensional spaces. Extensions to infinite fields or continuous spaces would require measure-theoretic entropy.
- The garbage compression theorem gives bounds on erasure cost but does not construct optimal erasure protocols.
- Tropical entropy loss is defined for deterministic functions; extending to noisy channels requires further work.

---

## 8. Future Work

1. **Tropical data processing inequality:** Does L_trop(g ∘ f) ≤ L_trop(f) hold for all f, g? This would be a tropical analogue of the data processing inequality.

2. **Characterization of Shannon–tropical equality:** Determine exactly which functions satisfy ΔH(f) = L_trop(f). We conjecture this holds iff f has constant fibers.

3. **Compositional entropy laws:** For composed linear maps A ∘ B, prove ΔH(A ∘ B) ≤ ΔH(A) + ΔH(B) and characterize equality.

4. **Quantum extension:** Replace fibers with stabilizer groups in quantum error-correcting codes. The entropy of a stabilizer code should equal the number of stabilizer generators times log q.

5. **Optimal garbage compression:** Given a reversible implementation with garbage g, find the minimum-cardinality type δ with range(g) ↪ δ and prove it achieves the information-theoretic lower bound.

---

## 9. References

1. R. Landauer, "Irreversibility and heat generation in the computing process," *IBM Journal of Research and Development*, vol. 5, no. 3, pp. 183–191, 1961.

2. C. H. Bennett, "Logical reversibility of computation," *IBM Journal of Research and Development*, vol. 17, no. 6, pp. 525–532, 1973.

3. C. E. Shannon, "A mathematical theory of communication," *Bell System Technical Journal*, vol. 27, pp. 379–423, 1948.

4. D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, American Mathematical Society, 2015.

5. The Mathlib Community, "Mathlib: A unified library of mathematics formalized in Lean 4," 2024.

6. R. Affeldt, M. Hagiwara, and J. Sénizergues, "Formalization of Shannon's theorems," *Journal of Formalized Reasoning*, vol. 7, no. 1, 2014.

---

## Appendix A: Formal Verification Summary

All theorems in this paper have been verified with complete machine-checked proofs using the Lean 4 theorem prover with the Mathlib library. The proofs use only the standard axioms (propext, Classical.choice, Quot.sound) and no unverified assumptions (sorry-free).

| Theorem | File | Status |
|---------|------|--------|
| Fiber cardinality (3.1) | `RankEntropy.lean` | ✓ Verified |
| Cardinality rank-nullity (3.2) | `RankEntropy.lean` | ✓ Verified |
| Algebraic Landauer (3.3) | `RankEntropy.lean` | ✓ Verified |
| Rank-nullity entropy form (3.4) | `RankEntropy.lean` | ✓ Verified |
| Constant fiber property (3.7) | `RankEntropy.lean` | ✓ Verified |
| Shannon ≤ Tropical (3.5) | `TropicalEntropy.lean` | ✓ Verified |
| Constant-fiber equality (3.6) | `TropicalEntropy.lean` | ✓ Verified |
| Linear constant fibers (3.7) | `TropicalEntropy.lean` | ✓ Verified |
| Shannon–Tropical linear (3.8) | `TropicalEntropy.lean` | ✓ Verified |
| Tropical linear = ker·log q (—) | `TropicalEntropy.lean` | ✓ Verified |
| Erasure compression (3.9) | `ReversibleComputing.lean` | ✓ Verified |
| Strict improvement (3.10) | `ReversibleComputing.lean` | ✓ Verified |
| Parity entropy (3.11) | `ReversibleComputing.lean` | ✓ Verified |
