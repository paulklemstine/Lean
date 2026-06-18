# Future Directions: Certified Polynomial Method Infrastructure

## Overview

The formalization presented here — Schwartz–Zippel, affine line restriction, and Dvir's Kakeya theorem — is the first layer of a much larger "polynomial method stack" for verified mathematics. This document outlines five breakthrough-level research directions that build directly on this foundation.

---

## Direction 1: Quantitative Kakeya Lower Bounds via Dimension Counting

### Goal
Formalize the full quantitative consequence of Dvir's theorem:

```
theorem finite_field_kakeya_lower_bound
    {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    {n : ℕ} (hn : 0 < n)
    (E : Finset (Fin n → K))
    (hE : IsKakeyaSet (↑E : Set (Fin n → K))) :
    Nat.choose (Fintype.card K + n - 1) n ≤ E.card
```

### Approach
1. **Formalize the dimension of bounded-degree polynomial spaces.** The space of polynomials of total degree < d in n variables over K has dimension C(d+n-1, n). This is a combinatorial identity about the number of monomials, requiring careful formalization of `Finsupp.antidiagonal` or explicit bijection with weak compositions.

2. **Linear algebra over finite fields.** If |E| < dim(polynomials of degree < q), then the evaluation map has a nonzero kernel — giving a polynomial vanishing on E. This requires formalizing the rank-nullity theorem for finite-dimensional vector spaces over K applied to the evaluation map.

3. **Bridge to Dvir.** Apply `no_low_degree_polynomial_vanishing_on_kakeya` to get the contradiction, yielding the cardinality lower bound.

### Impact
This makes the Kakeya bound *quantitative* and *explicit*, enabling computational lower bounds in randomness extraction and data structures.

### Hypotheses to Validate
- The dimension formula C(d+n-1, n) for degree < d polynomials in n variables should be derivable from Mathlib's finsupp combinatorics.
- The evaluation map `MvPolynomial (Fin n) K →ₗ[K] (E → K)` should be constructible using MvPolynomial.leval or eval as a linear map.

---

## Direction 2: Finite-Field Nikodym Theorem

### Goal
Prove the Nikodym analogue of Dvir's theorem:

**Definition.** A *Nikodym set* E ⊆ K^n is a set such that for every point x ∈ K^n, there exists a line through x that lies entirely in E ∪ {x}.

**Theorem.** Any Nikodym set in GF(q)^n has size ≥ C(q+n-1, n).

### Approach
The proof is structurally similar to Dvir's: if f vanishes on E and has degree < q, then for every x, there is a line through x on which f vanishes. The restriction to this line is a univariate polynomial of degree < q with q roots, so it's zero. The leading coefficient vanishes at every direction containing the line — which gives a different algebraic constraint than the Kakeya case.

### Infrastructure Needed
- Modify the Kakeya definition to the Nikodym condition.
- Reuse `restrictAffineLine`, `natDegree_restrictAffineLine_le_totalDegree`, and the multivariate vanishing theorem.
- The new algebraic argument involves showing that the *inhomogeneous* top-degree coefficient also vanishes, not just the homogeneous part.

### Cross-Domain Impact
Nikodym sets are dual to Kakeya sets in incidence geometry. Their formalization would connect to:
- Maximal function estimates in harmonic analysis
- Point-line duality in finite geometry
- Furstenberg-type set problems

---

## Direction 3: Reed–Muller Code Formalization

### Goal
Build a certified interface for Reed–Muller codes using the polynomial infrastructure:

```
def ReedMullerCode (q n d : ℕ) (K : Type*) [Field K] [Fintype K] :
    Submodule K (Fin (q^n) → K) :=
  -- Image of the evaluation map from degree ≤ d polynomials
  LinearMap.range (evalMap K n)

theorem reed_muller_minimum_distance :
    ∀ c ∈ ReedMullerCode q n d K, c ≠ 0 →
      Finset.card (Finset.filter (· ≠ 0) (Finset.univ.image c)) ≥ (q - d) * q^(n-1)
```

### Approach
1. Define the evaluation map as a K-linear map from the polynomial space to function space.
2. The minimum distance lower bound follows directly from the Schwartz–Zippel lemma: a nonzero codeword is the evaluation vector of a nonzero polynomial, which has at most d·q^(n-1) zeros, hence at least q^n - d·q^(n-1) = (q-d)·q^(n-1) nonzero entries.

### Impact
This would provide:
- Verified minimum distance for one of the most important code families
- Infrastructure for local testability results (each codeword can be tested by querying O(d) positions)
- Foundation for list-decoding bounds (Sudan, Guruswami-Sudan)

### Hypotheses
- The evaluation map should be expressible as `MvPolynomial.eval` restricted to bounded-degree subspaces.
- Injectivity of the evaluation map (when d < q) follows from the multivariate vanishing theorem.

---

## Direction 4: Combinatorial Nullstellensatz

### Goal
Formalize Alon's Combinatorial Nullstellensatz (1999):

**Theorem.** Let f ∈ K[X₁,...,Xₙ] and let S₁,...,Sₙ ⊆ K with |Sᵢ| = tᵢ + 1. If f has total degree ∑tᵢ and the coefficient of ∏Xᵢ^{tᵢ} in f is nonzero, then there exists (s₁,...,sₙ) ∈ S₁ × ... × Sₙ with f(s₁,...,sₙ) ≠ 0.

### Approach
1. **Prove the general Schwartz–Zippel over product sets.** Extend our Schwartz–Zippel from K^n to arbitrary products S₁ × ... × Sₙ. This is the non-vanishing backbone.

2. **Coefficient extraction.** The Nullstellensatz is a *coefficient extraction* principle: the nonvanishing of a specific coefficient forces nonvanishing of the polynomial on the product set. This can be proved by induction on n, dividing f by ∏_{s ∈ S₁}(X₁ - s) and using the remainder.

3. **Applications.** The Combinatorial Nullstellensatz immediately yields:
   - Chevalley–Warning theorem
   - Davenport–Halberstam bound
   - Zero-sum theorems (Erdős–Ginzburg–Ziv)
   - Permanent lower bounds
   - Graph coloring bounds

### Infrastructure Needed
- Division of multivariate polynomials by products of linear factors (or reduction modulo ideal)
- Coefficient extraction lemmas for MvPolynomial
- The general product-set Schwartz–Zippel lemma

---

## Direction 5: Cap Set and Slice Rank Methods

### Goal
Build toward a formalization of the Croot–Lev–Pach / Ellenberg–Gijswijt cap set bound:

**Theorem (CLP/EG, 2016–2017).** The maximum size of a subset of GF(3)^n with no three-term arithmetic progression is at most O(2.756^n).

### Approach
This requires developing the *slice rank* method, which is a refined version of the polynomial method:

1. **Formalize the slice rank.** For a tensor T : A × B × C → K, the slice rank is the minimum number of "slices" (rank-1 terms in one variable) needed to decompose T.

2. **Upper bound on slice rank of the diagonal tensor.** The key lemma: the slice rank of the tensor δ(x, y, z) = [x + y + z = 0] over GF(3)^n is bounded above by 3 · C(2n/3, n/3) ≈ 3 · 2.756^n.

3. **Lower bound from cap set size.** If A is a cap set (no three-term AP), then the slice rank of δ restricted to A × A × A is at least |A|.

4. **Combine.** |A| ≤ slice rank ≤ 3 · 2.756^n.

### Infrastructure Needed
- Tensor product spaces and slice rank definition
- Polynomial method for bounding slice rank (the key innovation of CLP)
- Dimension counting for "degree ≤ d" polynomial spaces
- Multilinear algebra over finite fields

### Cross-Domain Impact
The cap set method connects to:
- Sunflower lemma improvements
- Matrix multiplication complexity
- Communication complexity lower bounds
- Quantum information theory (entanglement)

---

## Research Team Structure

Each direction should be pursued by a team combining:
- **Formalization expertise:** Familiarity with Lean 4, Mathlib, and proof automation
- **Mathematical depth:** Understanding of the polynomial method and its applications
- **Cross-domain knowledge:** Connections to coding theory, complexity, or combinatorics

### Recommended Timeline
1. **Months 1–3:** Direction 1 (Quantitative Kakeya) — most incremental, validates the infrastructure.
2. **Months 2–5:** Direction 3 (Reed–Muller) — high practical value, reuses existing lemmas directly.
3. **Months 3–6:** Direction 4 (Nullstellensatz) — opens the widest range of applications.
4. **Months 4–8:** Direction 2 (Nikodym) — deepens the geometric theory.
5. **Months 6–12:** Direction 5 (Cap sets) — the most ambitious, requiring substantial new infrastructure.

### Key Metrics
- Number of sorry-free theorems
- Depth of dependency chains (measuring infrastructure reuse)
- Number of distinct application domains reached
- Compilation time and proof term size

---

## Conclusion

The polynomial method formalization presented here is not an endpoint — it is a launchpad. Each direction above represents a genuine mathematical breakthrough in formal verification, and together they would establish a comprehensive *certified algebraic combinatorics* toolkit unprecedented in the formal mathematics community. The infrastructure is in place; the discoveries await.
