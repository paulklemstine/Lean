# A Combinatorial Framework for the Selberg Class Census

## Abstract

We develop a formal combinatorial framework for cataloging L-functions in the Selberg class via their invariant data. The invariant data of an L-function — its degree, conductor, and spectral parameters — form a countable set equipped with a well-founded factorization partial order and two additive spectral invariants: spectral complexity (a monoid homomorphism) and spectral entropy (a subadditive function). We prove that the counting function N_d(Q, B), which enumerates data with degree d, conductor ≤ Q, and spectral shifts bounded by B, satisfies the exact formula N_d(Q, B) = Q · (2(2B+1))^d and admits a multiplicative factorization identity reflecting the graded monoid structure. All results are formalized and machine-verified in Lean 4 with the Mathlib library.

**Keywords**: Selberg class, L-functions, combinatorial enumeration, graded monoids, spectral invariants, formal verification

---

## 1. Introduction

The Selberg class, introduced by Selberg (1992), provides an axiomatic framework for the study of L-functions arising in analytic number theory and automorphic representation theory. An element F of the Selberg class S is a Dirichlet series F(s) = Σ_{n≥1} a(n)n^{-s} satisfying:

1. **Ramanujan hypothesis**: a(n) ≪ n^ε for all ε > 0
2. **Analytic continuation**: (s-1)^m F(s) extends to an entire function of finite order for some non-negative integer m
3. **Functional equation**: there exist Q > 0, α_j > 0, Re(μ_j) ≥ 0, and |ω| = 1 such that Φ(s) = ω Φ̄(1-s), where Φ(s) = Q^s ∏_{j=1}^d Γ(α_j s + μ_j) F(s)
4. **Euler product**: log F(s) = Σ_p Σ_{k≥1} b(p^k) p^{-ks} with b(p^k) ≪ p^{kθ} for some θ < 1/2

The integer d = 2Σ α_j is the degree of F. For the "standard normalization" where all α_j = 1/2, the degree equals the number of gamma factors.

While the analytic theory of the Selberg class has been extensively developed (see Kaczorowski-Perelli 1999, 2002, 2011), the *combinatorial* structure of the class — how its members are organized by their invariant data — has received less systematic attention. This paper initiates such a study.

### 1.1 Main Contributions

1. We define the **Selberg datum** (d, q, μ₁...μ_d) as the combinatorial fingerprint of an L-function and establish its algebraic structure (§2).

2. We prove that the set of data forms a **graded commutative monoid** under the product operation, with degree as grading (§3).

3. We identify two natural invariants — **spectral complexity** (additive, §3.1) and **spectral entropy** (subadditive, §3.2) — and prove their structural properties.

4. We establish **exact counting formulas** and **monotonicity properties** for the conductor counting function (§4).

5. We prove a **multiplicative factorization identity** for the counting function that reflects the monoid structure (§4.1).

6. We define the **factorization partial order** and prove its basic properties including well-foundedness of the degree component (§5).

7. All results are **formally verified** in Lean 4 with the Mathlib library (§6).

---

## 2. Definitions

### 2.1 Spectral Parameters

**Definition 2.1** (Spectral Parameter). A *spectral parameter* is a pair (μ, ε) where μ ∈ ℤ is the shift and ε ∈ {0, 1} is the parity. The absolute shift is |μ|.

*Remark*: We work with integer shifts for computability. In the full Selberg class, the shifts μ_j have non-negative real part; restricting to integers corresponds to the important subclass of "algebraic" L-functions arising from automorphic representations with integral infinitesimal character.

### 2.2 Selberg Data

**Definition 2.2** (Selberg Datum). A *Selberg datum* is a triple D = (d, q, μ₁...μ_d) where:
- d ∈ ℕ is the degree
- q ∈ ℕ⁺ is the conductor
- (μ₁, ε₁), ..., (μ_d, ε_d) are spectral parameters

The constraint is that the parameter list has length exactly d.

**Definition 2.3** (Trivial Datum). The trivial datum is D₀ = (0, 1, ∅), corresponding to the constant L-function L(s) = 1.

### 2.3 Product Operation

**Definition 2.4** (Product). The product of D₁ = (d₁, q₁, P₁) and D₂ = (d₂, q₂, P₂) is

D₁ · D₂ = (d₁ + d₂, q₁q₂, P₁ ++ P₂)

where ++ denotes list concatenation.

This corresponds to the Rankin-Selberg convolution or tensor product of automorphic representations.

---

## 3. Spectral Invariants

### 3.1 Spectral Complexity

**Definition 3.1**. The *spectral complexity* of D = (d, q, μ₁...μ_d) is

χ(D) = Σ_{j=1}^d |μ_j|

**Theorem 3.2** (Additivity). For any data D₁, D₂:

χ(D₁ · D₂) = χ(D₁) + χ(D₂)

*Proof sketch*: The product concatenates spectral parameter lists, and the sum of absolute shifts distributes over concatenation.

**Corollary 3.3**. χ(D₀) = 0 and χ is a monoid homomorphism from (Data, ·, D₀) to (ℕ, +, 0).

### 3.2 Spectral Entropy

**Definition 3.4**. The *spectral entropy* of D = (d, q, μ₁...μ_d) is

H(D) = |{|μ_j| : 1 ≤ j ≤ d}|

the number of distinct absolute shift values.

**Theorem 3.5** (Subadditivity). For any data D₁, D₂:

H(D₁ · D₂) ≤ H(D₁) + H(D₂)

*Proof sketch*: The distinct values in the union of two sets is at most the sum of the distinct values in each set. The proof uses the fact that |A ∪ B| ≤ |A| + |B| for finite sets, together with the observation that mergeSort preserves the set of elements.

*Remark*: Equality holds when the spectral parameters of D₁ and D₂ have disjoint sets of absolute values. Strict inequality occurs when they share values — this "spectral overlap" is significant in the theory of L-function families.

### 3.3 Spectral Types

**Definition 3.6** (Spectral Type). The *spectral type* of D is the pair (d, π) where π is the sorted multiset of absolute shifts. Two data have the same spectral type if and only if they have the same degree and the same collection of absolute shifts (ignoring conductor and sign information).

**Theorem 3.7**. The set of spectral types forms a commutative monoid under the product operation (d₁, π₁) · (d₂, π₂) = (d₁ + d₂, merge(π₁, π₂)), with unit (0, ∅). Both complexity and entropy factor through this monoid.

---

## 4. Counting Functions

### 4.1 The Conductor Counting Function

**Definition 4.1**. The *conductor counting function* is

N_d(Q, B) = |{D = (d, q, P) : q ≤ Q, |μ_j| ≤ B for all j}|

**Theorem 4.2** (Exact Formula).

N_d(Q, B) = Q · (2(2B+1))^d

*Proof*: The conductor q ranges over {1, ..., Q} (Q choices). For each of the d spectral parameters, the shift ranges over {-B, ..., B} (2B+1 choices) and the parity is in {0, 1} (2 choices). The total is Q · (2(2B+1))^d.

### 4.2 Monotonicity

**Theorem 4.3** (Monotonicity in Q). For B fixed, N_d(Q₁, B) ≤ N_d(Q₂, B) whenever Q₁ ≤ Q₂.

**Theorem 4.4** (Monotonicity in B). For Q fixed, N_d(Q, B₁) ≤ N_d(Q, B₂) whenever B₁ ≤ B₂.

**Theorem 4.5** (Monotonicity in d). For Q ≥ 1, N_{d₁}(Q, B) ≤ N_{d₂}(Q, B) whenever d₁ ≤ d₂.

### 4.3 Factorization Identity

**Theorem 4.6** (Product Factorization).

N_{d₁+d₂}(Q, B) = N_{d₁}(1, B) · N_{d₂}(Q, B)

*Proof*: Direct calculation:

N_{d₁}(1,B) · N_{d₂}(Q,B) = 1 · (2(2B+1))^{d₁} · Q · (2(2B+1))^{d₂}
= Q · (2(2B+1))^{d₁+d₂} = N_{d₁+d₂}(Q,B)

This identity has a combinatorial interpretation: a datum of degree d₁+d₂ can be constructed by choosing a "spectral shape" of degree d₁ (with conductor 1) and a datum of degree d₂ (with arbitrary conductor).

### 4.4 Degree-1 Specialization

**Theorem 4.7**. N_1(Q, B) = Q · 2(2B+1).

For Q = 100, B = 5, this gives N_1(100, 5) = 100 · 22 = 2200.

---

## 5. The Factorization Order

### 5.1 Degree-Conductor Pairs

**Definition 5.1**. A *degree-conductor pair* is (d, q) ∈ ℕ × ℕ⁺. The *factorization order* is:

(d₁, q₁) ≤ (d₂, q₂) ⟺ d₁ ≤ d₂ and q₁ | q₂

**Theorem 5.2**. The factorization order is a partial order (reflexive, transitive, antisymmetric on degree).

**Theorem 5.3**. The unit (0, 1) is the bottom element.

**Theorem 5.4**. The product operation satisfies (d₁, q₁) · (d₂, q₂) = (d₁+d₂, q₁q₂).

### 5.2 Well-Foundedness

The degree component of the factorization order is well-founded (as a restriction of the natural order on ℕ). The conductor component, ordered by divisibility, is also well-founded on any finite set of divisors. Together, these ensure that the factorization order is well-founded when restricted to data below any fixed bound.

### 5.3 Primitive Data

**Definition 5.5**. A datum D is *primitive* if d ≥ 1 and for any decomposition D = D₁ · D₂ (in terms of degree and conductor), either D₁ or D₂ is trivial.

The classification of primitive data of degree 1 is a theorem of Kaczorowski-Perelli: they are exactly the Riemann zeta function ζ(s) and the shifted Dirichlet L-functions L(s, χ) for primitive characters χ. For degree 2 and higher, the classification is a major open problem connected to the Langlands program.

---

## 6. Formal Verification

All definitions and theorems in §2-5 have been formalized and verified in Lean 4 (version 4.28.0) using the Mathlib library. The formalization consists of two files:

- **Defs.lean** (~130 lines): Core definitions of `SpectralParam`, `SelbergDatum`, `SpectralType`, `DegreeConductor`, and the counting function.
- **Theorems.lean** (~240 lines): Complete proofs of all 19 theorems.

Key proof techniques:
- Spectral complexity additivity uses `List.map_append` and `List.sum_append`
- Counting function results reduce to `Nat.mul_le_mul` and `Nat.pow_le_pow`
- Entropy subadditivity uses `Finset.card_union_le` after converting lists to finsets
- The factorization identity uses `ring` after unfolding definitions

The axiom footprint is minimal: only `propext`, `Quot.sound`, and `Classical.choice` (the last only for entropy results).

---

## 7. Discussion

### 7.1 Connections to Existing Work

The counting function N_d(Q, B) is related to but distinct from the conductor-counting functions studied by Iwaniec-Kowalski and by Kowalski-Michel. Those functions count *actual* L-functions (or automorphic forms) with bounded conductor, whereas ours counts *all possible* invariant data. The ratio

R_d(Q, B) = #{L-functions with data (d, q, P), q ≤ Q, |μ_j| ≤ B} / N_d(Q, B)

measures the "density" of L-functions among all possible data — how much of the combinatorial space is actually realized by analytic objects. Understanding this ratio is a deep problem.

### 7.2 Tropical-Geometric Interpretation

The spectral complexity function χ: Data → ℕ has the flavor of a tropical valuation: it is additive under products and takes values in the non-negative integers under addition. This suggests that the graded monoid of data can be studied using techniques from tropical geometry.

The counting bound N_d(Q, B) = Q · (2(2B+1))^d resembles the volume of a zonotope (Minkowski sum of line segments) in ℝ^d. This connection to convex geometry and lattice point counting deserves further investigation.

### 7.3 Information-Theoretic Interpretation

The spectral entropy H(D) can be interpreted as a measure of the "information content" of the spectral data. Low entropy means the spectral parameters are concentrated at a few values; high entropy means they are spread out. The subadditivity H(D₁ · D₂) ≤ H(D₁) + H(D₂) is the combinatorial analogue of the entropy inequality in information theory.

---

## 8. Conjectures and Future Work

**Conjecture 8.1** (Sharp Degree-1 Density). The density of actual degree-1 L-functions among all degree-1 data satisfies R_1(Q, B) → C₁ as Q → ∞ for a constant C₁ related to the density of primitive Dirichlet characters among all characters.

**Conjecture 8.2** (Spectral Concentration). For "generic" families of L-functions of degree d, the spectral entropy H is concentrated near d^{1/2}, not near d or 1. This would imply a "square-root law" for spectral diversity.

**Conjecture 8.3** (Primitive Counting Asymptotics). The number of primitive data of degree d with conductor ≤ Q grows as Ω(Q^{c_d}) for some constant c_d depending on d, reflecting the growth of primitive automorphic representations.

---

## References

1. A. Selberg, "Old and new conjectures and results about a class of Dirichlet series," *Proceedings of the Amalfi Conference on Analytic Number Theory* (1992), pp. 367–385.

2. J. Kaczorowski and A. Perelli, "On the structure of the Selberg class, I: 0 ≤ d ≤ 1," *Acta Math.* **182** (1999), pp. 207–241.

3. H. Iwaniec and E. Kowalski, *Analytic Number Theory*, AMS Colloquium Publications vol. 53, 2004.

4. E. Kowalski and P. Michel, "The analytic rank of J₀(q) and zeros of automorphic L-functions," *Duke Math. J.* **100** (1999), pp. 503–542.

5. J. B. Conrey and A. Ghosh, "Mean values of the Riemann zeta-function and its derivatives," *Invent. Math.* **107** (1992), pp. 159–174.
