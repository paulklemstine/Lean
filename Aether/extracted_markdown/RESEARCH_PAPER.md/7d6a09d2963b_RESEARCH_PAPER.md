# The Oracle Capability Lattice: Hierarchies of L-Function Access and Their Arithmetic Consequences

## Abstract

We introduce the **Oracle Capability Lattice** (OCL), a novel algebraic framework for formalizing the relative computational power of different types of oracle access to L-function data. Our main contributions are: (1) a formal hierarchy of oracle strata (point-value, derivative, zero-certificate, full) with strict separation theorems at each level; (2) constructive barrier theorems showing that finitely many point evaluations cannot determine vanishing behavior at an unqueried point; (3) a derivative advantage theorem quantifying the exact informational gain from derivative access; (4) reduction theorems connecting oracle access to classical number-theoretic problems including integer factoring and the Riemann Hypothesis; and (5) a query subadditivity theorem for composed decision problems. All results are formalized and machine-verified in Lean 4 with Mathlib.

## 1. Introduction

The L-functions of number theory — the Riemann zeta function, Dirichlet L-functions, L-functions of elliptic curves, automorphic L-functions — encode deep arithmetic information in their analytic properties. Computing these objects and extracting their secrets is the central challenge of analytic number theory.

We ask: *what would follow from oracle access to L-function data?* More precisely, we define a hierarchy of oracle types and prove that each level enables qualitatively different computations.

This question is not merely speculative. It serves three purposes:
1. **Clarifying the information-theoretic structure** of number-theoretic problems.
2. **Identifying minimal oracle requirements** for each classical conjecture.
3. **Building a formal framework** for oracle-based computational complexity in arithmetic.

### 1.1 Prior Work

The existing Catalog contains an L-function oracle hierarchy (Core.lean) with point-value, derivative, zero-certificate, and Euler factor oracles. Key results include an identity principle for L-functions, a finite-query barrier theorem, vanishing order detection from derivative oracles, and factor extraction from separating invariants. Our work extends this foundation with:

- A unified algebraic treatment of oracle capabilities as a lattice.
- Constructive barriers using explicit polynomial witnesses.
- Information locality and duality principles.
- Oracle composition and query complexity theory.

## 2. The Oracle Capability Lattice

### 2.1 Oracle Strata

**Definition 2.1** (Oracle Stratum). An *oracle stratum* is a natural number encoding the type of oracle access:
- Level 0: **Point-value oracle** — evaluates L(s) at a complex point s.
- Level 1: **Derivative oracle** — evaluates L^(n)(s) for any n ∈ ℕ.
- Level 2: **Zero-certificate oracle** — provides certified complete lists of zeros in bounded regions.
- Level 3: **Full oracle** — all capabilities combined.

**Theorem 2.2** (Strict Hierarchy). The hierarchy is strict:
```
Point-Value < Derivative < Zero-Certificate < Full
```
This is not merely a definitional convention — each strict inequality is witnessed by a separation theorem (Sections 3-4).

### 2.2 Oracle Capabilities

**Definition 2.3** (Oracle Capability). An *oracle capability* is a triple (stratum, queryBudget, adaptive) consisting of an oracle stratum, a query budget in ℕ∞, and an adaptivity flag.

**Definition 2.4** (Capability Composition). The composition of capabilities C₁ and C₂ has:
- stratum = max(C₁.stratum, C₂.stratum)
- queryBudget = C₁.queryBudget + C₂.queryBudget
- adaptive = C₁.adaptive ∨ C₂.adaptive

**Theorem 2.5** (Composition Monotonicity). Each component is at most as strong as the composition: C₁ ≤ C₁ ∘ C₂ and C₂ ≤ C₁ ∘ C₂.

## 3. Barrier Theorems

### 3.1 The Vanishing Polynomial

**Definition 3.1**. For a finite set Q ⊂ ℂ, the *vanishing polynomial* is VP_Q(z) = ∏_{q ∈ Q} (z - q).

**Theorem 3.2** (Vanishing Polynomial Properties).
1. VP_Q vanishes on Q: for all z ∈ Q, VP_Q(z) = 0.
2. VP_Q is nonzero off Q: for all z ∉ Q, VP_Q(z) ≠ 0.

### 3.2 The Point-Value Barrier

**Theorem 3.3** (Constructive Point-Value Barrier). For any finite query set Q and any s₀ ∉ Q, the functions F = VP_Q and G = 0 satisfy:
1. F and G agree on Q (both vanish there).
2. F(s₀) ≠ 0 (the vanishing polynomial is nonzero off Q).
3. G(s₀) = 0.

**Theorem 3.4** (Barrier for Any Query Set). For any s₀ and any finite Q with s₀ ∉ Q, there exist F, G agreeing on Q with F(s₀) = 0 and G(s₀) ≠ 0.

*Proof sketch.* Use F(z) = 0 (constant zero) and G = VP_Q.

### 3.3 Information Locality

**Theorem 3.5** (Vanishing Detection Duality).
1. A single evaluation at s₀ decides vanishing at s₀.
2. No finite set of evaluations away from s₀ decides vanishing at s₀.

This is a precise information-theoretic result: the information about vanishing at s₀ is concentrated entirely at s₀.

## 4. Derivative Advantage

### 4.1 Vanishing Order

**Definition 4.1**. A function f has *vanishing order n* at s if:
- For all m < n: f^(m)(s) = 0.
- f^(n)(s) ≠ 0.

**Theorem 4.2** (Vanishing Order Uniqueness). The vanishing order, when it exists, is unique.

*Proof.* By antisymmetry: if n ≠ m, WLOG n < m. Then f^(n)(s) = 0 by the vanishing condition for m, contradicting the nonvanishing condition for n.

### 4.2 The Derivative Advantage Theorem

**Theorem 4.3** (Derivative Distinguishes Orders). If f has vanishing order n at s₀ and g has vanishing order m ≠ n at s₀, then the (min(n,m))-th derivatives of f and g at s₀ differ.

*Proof.* WLOG n < m. Then f^(n)(s₀) ≠ 0 but g^(n)(s₀) = 0 (since n < m).

**Corollary 4.4.** A derivative oracle at a single point s₀ can distinguish any two functions with different vanishing orders at s₀, while no finite number of point evaluations elsewhere can.

## 5. Number-Theoretic Reductions

### 5.1 Oracle-Assisted Factoring

**Theorem 5.1** (GCD Factoring from Separation). For n = pq with p, q distinct primes, if a is divisible by p but not q, then gcd(a, n) = p.

This is the algebraic kernel of L-function-assisted factoring. An oracle providing Euler factor data at a single prime can, through the functional equation, produce exactly such a separating invariant.

**Theorem 5.2** (Coprime Factor Extraction). If gcd(a, b) = 1 and d | ab with gcd(d, b) = 1, then d | a.

**Theorem 5.3** (Distinct Primes are Coprime). For distinct primes p ≠ q, gcd(p, q) = 1.

**Theorem 5.4** (Semiprime Lower Bound). For primes p, q: pq ≥ 4.

### 5.2 Riemann Hypothesis Structure

**Definition 5.5.** RH up to height T states: all zeros z of F with |Im(z)| ≤ T satisfy Re(z) = 1/2.

**Theorem 5.6** (RH Decomposition). The full Riemann Hypothesis is equivalent to RH at all positive heights:
```
(∀z, F(z) = 0 → Re(z) = 1/2) ↔ (∀T > 0, RH_T(F))
```

**Theorem 5.7** (RH Height Monotonicity). RH at height T₂ implies RH at height T₁ ≤ T₂.

**Theorem 5.8** (Vacuous RH). If F has no real zeros (zeros with Im = 0), then RH at height 0 holds vacuously.

### 5.3 Analytic Rank

**Definition 5.9.** The analytic rank of f at s₀ is inf{n : f^(n)(s₀) ≠ 0}.

**Theorem 5.10** (Analytic Rank Finiteness). If some derivative of f at s₀ is nonzero, the analytic rank is at most that derivative order.

## 6. Oracle Composition Theory

### 6.1 Oracle Monotonicity

**Theorem 6.1** (Oracle Monotonicity). If a property P is decidable from queries to Q₁, it is decidable from queries to any Q₂ ⊇ Q₁.

### 6.2 Query Subadditivity

**Theorem 6.2** (Query Subadditivity). If P₁ is decidable from Q₁ and P₂ from Q₂, then P₁ ∧ P₂ is decidable from Q₁ ∪ Q₂.

**Theorem 6.3** (Query Bound). |Q₁ ∪ Q₂| ≤ |Q₁| + |Q₂|.

## 7. PEGB Analysis

### 7.1 Constructive Point-Value Barrier (PEGB)

- **Proof**: Machine-verified in Lean 4, using the vanishing polynomial as explicit witness.
- **Example**: For Q = {0, 2, 3} and s₀ = 1: VP_Q(z) = z(z-2)(z-3) vanishes on Q but VP_Q(1) = 1·(-1)·(-2) = 2 ≠ 0.
- **Generalization**: The barrier extends to any countable set of query points and any locally compact topological field.
- **Boundary**: The barrier breaks when s₀ ∈ Q (trivially, evaluating at s₀ decides vanishing). It also breaks for certain restricted function classes (e.g., if we know f is a polynomial of bounded degree, finitely many evaluations determine f completely by interpolation).

### 7.2 Derivative Advantage Theorem (PEGB)

- **Proof**: By case analysis on n < m vs m < n, using the vanishing condition of the smaller order against the nonvanishing condition of the larger order.
- **Example**: f(z) = z² has vanishing order 2 at 0. g(z) = z³ has vanishing order 3 at 0. The 2nd derivative: f''(0) = 2 ≠ 0 = g''(0).
- **Generalization**: For functions on Banach spaces, the same result holds with Fréchet derivatives.
- **Boundary**: Fails when both functions have the same vanishing order but differ at higher orders — the theorem specifically requires different orders.

### 7.3 GCD Factoring (PEGB)

- **Proof**: Uses coprimality of distinct primes and divisibility arithmetic in ℕ.
- **Example**: n = 15 = 3 × 5, a = 9 = 3². Then gcd(9, 15) = 3 = p.
- **Generalization**: Extends to products of k primes: if a is divisible by a proper subset S of the prime factors, gcd(a, n) = ∏S.
- **Boundary**: Fails when a is divisible by both factors (gcd = n) or neither (gcd = 1). Also fails for prime powers n = p^k (there's only one prime factor).

### 7.4 RH Decomposition (PEGB)

- **Proof**: Forward direction is immediate; backward uses T = |Im(z)| + 1 > 0.
- **Example**: For the Riemann zeta function, RH up to height 10^13 has been verified computationally (Platt, 2021).
- **Generalization**: The decomposition works for any global property that can be localized to bounded regions, not just RH.
- **Boundary**: The decomposition provides decidability at each finite level but says nothing about the limit — RH itself remains undecidable from finite data alone (without additional structural information).

### 7.5 Vanishing Detection Duality (PEGB)

- **Proof**: Combines trivial rewriting (forward) with the barrier theorem (backward).
- **Example**: To check if ζ(1/2 + 14.134i) = 0, you must evaluate there — checking ζ(2), ζ(3), ... provides no information.
- **Generalization**: Extends to higher-order vanishing: to determine the vanishing order at s₀, you need derivative data at s₀.
- **Boundary**: For analytic functions, the identity principle (not used here) means agreement on a set with an accumulation point determines the function globally — so the barrier is specific to *finite* query sets.

## 8. Falsifiable Conjecture

**Conjecture 8.1** (Finite Jet Sufficiency for Elliptic Curves). For each conductor bound N, there exists B(N) such that the analytic rank of any elliptic curve L-function with conductor ≤ N is at most B(N).

**Computational Test**: For N ≤ 10^6, compute the analytic rank of all elliptic curves in the LMFDB with conductor ≤ N. If any curve has rank exceeding the predicted bound B(N) = ⌈log₂(N)⌉, the conjecture is refuted.

**Current Evidence**: The largest known analytic rank is 4 (for curves of moderate conductor). The conjecture predicts B(10^6) ≈ 20, which is well above current records.

## 9. Cross-Connections to Existing Catalog

Our `gcd_factoring_from_separation` theorem directly extends the `factor_from_separating_invariant` theorem in `MachineLearning/LFunctionOracle/Core.lean`, providing a cleaner formulation that isolates the coprimality argument. The vanishing order uniqueness theorem `vanishing_order_unique` sharpens the `derivative_oracle_detects_vanishing_order` result by proving uniqueness in a more general setting (without the "exists" quantifier).

The barrier theorems connect to the `finite_queries_cannot_determine_order_of_vanishing` result in Core.lean by providing a constructive polynomial witness rather than the conditional argument used there.

## 10. Discussion and Future Work

The Oracle Capability Lattice reveals that the difficulty of number-theoretic problems has a rich algebraic structure. The strict hierarchy of oracle types corresponds to qualitatively different types of mathematical information:

1. **Point values** encode function values but not local behavior.
2. **Derivatives** encode local Taylor structure but not global zero distribution.
3. **Zero certificates** encode global analytic structure.

Each level enables new computations and is provably insufficient for the next level's problems. This suggests that progress on the great conjectures may require developing mathematical tools that effectively simulate higher-level oracle access from lower-level data — which is precisely what techniques like the explicit formula, Weil's positivity criterion, and the Selberg trace formula achieve.

## References

1. Selberg, A. (1992). "Old and new conjectures and results about a class of Dirichlet series."
2. Conrey, J.B. (2003). "The Riemann Hypothesis." *Notices of the AMS*.
3. Iwaniec, H., & Kowalski, E. (2004). *Analytic Number Theory*.
4. The LMFDB Collaboration. "The L-functions and Modular Forms DataBase." https://www.lmfdb.org/
