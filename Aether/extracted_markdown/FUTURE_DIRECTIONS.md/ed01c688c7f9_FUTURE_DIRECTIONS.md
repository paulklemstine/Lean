# Future Directions: Falsifiable Hypotheses in Quantitative Jacobian Reduction Theory

This document presents five specific, testable scientific hypotheses emerging from our formal results on nilpotence detection, degree bounds, and complexity measures for polynomial maps. Each hypothesis is falsifiable: it can be confirmed, refuted, or bounded by explicit computation or formal proof.

---

## Hypothesis 1: Sharpness of the Tame Inverse Degree Bound

**Conjecture:** For every n ≥ 2, there exists a tame polynomial automorphism F : k^n → k^n with deg(F) = d ≥ 2 such that deg(F⁻¹) = d^(n-1).

**Precise statement:** Over a field k of characteristic zero, for each n ≥ 2 and d ≥ 2, there exists a composition F = E₁ ∘ ... ∘ Eₘ of elementary automorphisms with polyMapDegree(F) = d and polyMapDegree(F⁻¹) = d^(n-1).

**Lean objects involved:**
- `JacobianConjecture.polyMapDegree`
- `JacobianConjecture.totalDegree_bind₁_le`
- Elementary map constructions from `Catalog/Algebra/Jacobian/Triangular.lean`

**Computational test:** 
1. For n = 2, d = 2: construct F(x,y) = (x + y², y), verify deg(F) = 2, deg(F⁻¹) = 2 = 2^1. (Achieved.)
2. For n = 3, d = 2: search for compositions of 2 elementary maps in 3 variables achieving deg(F⁻¹) = 4 = 2². Test candidates like F = E₁ ∘ E₂ where E₁(x,y,z) = (x + y², y, z) and E₂(x,y,z) = (x, y + z², z).
3. For n = 4, d = 2: search systematically among compositions of elementary maps.

**Refutation criterion:** If for some n ≥ 2, one can prove that deg(F⁻¹) < d^(n-1) for ALL tame automorphisms F of degree d, the hypothesis is refuted. Specifically, exhibit a universal upper bound strictly less than d^(n-1).

**Impact if true:** Confirms that the degree bound is optimal, meaning no improvement is possible for the general tame case. This would establish d^(n-1) as the precise complexity of tame inversion.

---

## Hypothesis 2: Nilpotence Index Compression for Cubic Keller Maps

**Conjecture:** For every cubic homogeneous polynomial map H : k^n → k^n over a characteristic-zero field with det(I + JH) = 1, the Jacobian matrix JH satisfies (JH)^⌈n/2⌉+1 = 0 (not just (JH)^n = 0).

**Precise statement:** If H is cubic homogeneous and det(I + t · JH) = 1 for all t (which implies JH is nilpotent by `isNilpotent_of_det_one_add_smul`), then the nilpotence index of JH is at most ⌈n/2⌉ + 1 rather than n.

**Lean objects involved:**
- `isNilpotent_of_det_one_add_smul`
- `JacobianConjecture.nilpotent_pow_card_eq_zero`
- `JacobianConjecture.jacobianMatrix` applied to cubic homogeneous maps

**Computational test:**
1. For n = 2: generate random 2×2 nilpotent matrices with entries that are degree-2 polynomials (modeling JH for cubic H). Check if (JH)² = 0 always holds (prediction: yes, since ⌈2/2⌉ + 1 = 2).
2. For n = 3: construct cubic homogeneous Keller maps in 3 variables. Compute nilpotence indices of their Jacobians. Check if index ≤ 3 (= ⌈3/2⌉ + 1). Specifically, test Drużkowski maps F = I + (Ax)^[3] for random 3×3 matrices A with A² = 0.
3. For n = 4, 5, 6: systematic search over random cubic homogeneous Keller maps.

**Refutation criterion:** Find a cubic homogeneous Keller map in dimension n whose Jacobian matrix JH has nilpotence index strictly greater than ⌈n/2⌉ + 1. Even one example suffices.

**Impact if true:** Halves the computational cost of nilpotence verification for cubic Keller maps and provides evidence for deep structural constraints on Jacobians of Keller maps beyond bare nilpotence.

---

## Hypothesis 3: Stable Reduction Optimality

**Conjecture:** There exist cubic homogeneous Keller maps in dimension n that require ambient dimension strictly greater than ⌈3n/2⌉ for Drużkowski reduction.

**Precise statement:** For some n ≥ 3, there exists a cubic homogeneous map H : k^n → k^n with det(I + JH) = 1 such that H is not stably equivalent (via affine conjugation and identity coordinate adjunction) to any Drużkowski map in dimension m < ⌈3n/2⌉.

**Lean objects involved:**
- `JacobianConjecture.druzkowskiMap`
- `JacobianConjecture.stableLift`
- `JacobianConjecture.stablyEquivalent`

**Computational test:**
1. For n = 3: enumerate cubic homogeneous Keller maps (parametrized by symmetric trilinear forms with nilpotent Jacobian). For each, attempt Drużkowski reduction and record the minimal ambient dimension achieved.
2. Compare minimal dimensions against the bound ⌈3n/2⌉ = 5 for n = 3.
3. The reduction proceeds by expressing the cubic part as a sum of cubes of linear forms; the number of summands equals the number of auxiliary variables needed. Compute the symmetric tensor rank.

**Refutation criterion:** Prove that EVERY cubic homogeneous Keller map in dimension n reduces to Drużkowski form in dimension ≤ ⌈3n/2⌉. This would show the bound is not tight.

**Impact if true:** Demonstrates that stable reduction has nontrivial dimensional cost, establishing lower bounds on the search space for Jacobian Conjecture verification.

---

## Hypothesis 4: Tame Degree Profile as Wildness Detector

**Conjecture:** Every polynomial automorphism F : k^n → k^n with deg(F⁻¹) > deg(F)^(n-1) is wild (not tame).

**Precise statement:** If F is a polynomial automorphism and deg(F⁻¹) > deg(F)^(n-1), then F cannot be expressed as a composition of affine and elementary automorphisms.

**Lean objects involved:**
- `JacobianConjecture.polyMapDegree`
- `JacobianConjecture.totalDegree_bind₁_le`
- Tame automorphism decomposition theory

**Computational test:**
1. For n = 2: the Jung-van der Kulk theorem states all polynomial automorphisms are tame. Verify that deg(F⁻¹) ≤ deg(F) for all known examples.
2. For n = 3: test the Nagata automorphism N(x,y,z) = (x - 2(xz+y²)y - (xz+y²)²z, y + (xz+y²)z, z). Compute deg(N) = 5, deg(N⁻¹). If deg(N⁻¹) > 5² = 25, this provides evidence for the conjecture and confirms wildness via degree theory.
3. Systematically test all known candidate wild automorphisms in dimensions 3 and 4.

**Refutation criterion:** Find a tame automorphism F with deg(F⁻¹) > deg(F)^(n-1). This would show the degree criterion is not a reliable wildness detector (even though our formal bound for specific decompositions holds).

**Impact if true:** Provides a computationally verifiable certificate of wildness, connecting the abstract tame/wild dichotomy to a concrete numerical invariant. This would be a major tool for the study of polynomial automorphism groups.

---

## Hypothesis 5: Universality of Trace-Based Nilpotence Detection

**Conjecture:** Over a characteristic-zero field, an n×n matrix A is nilpotent if and only if tr(A^k) = 0 for all k = 1, ..., n.

**Precise statement:** For K a field with char(K) = 0 and A ∈ M_n(K):
- (→) If A is nilpotent, then tr(A^k) = 0 for all k ≥ 1. [Proved: `trace_pow_eq_zero_of_det_one_add_smul`]
- (←) If tr(A^k) = 0 for k = 1, ..., n, then A is nilpotent. [To be proved]

The reverse direction follows from Newton's identities: the elementary symmetric polynomials e₁, ..., eₙ in the eigenvalues of A are determined by the power sums p₁ = tr(A), ..., pₙ = tr(A^n) via Newton's identities. If all pₖ = 0, then all eₖ = 0 (in characteristic zero), so charpoly(A) = X^n, and A is nilpotent by Cayley-Hamilton.

**Lean objects involved:**
- `trace_pow_eq_zero_of_det_one_add_smul` (forward direction, proved)
- `isNilpotent_of_det_one_add_smul` (alternative criterion, proved)
- Newton identity formalization (to be built)

**Computational test:**
1. Generate random n×n matrices for n = 2, ..., 10. For each, compute tr(A), tr(A²), ..., tr(A^n). Check if all vanish, and if so verify nilpotence.
2. Search for non-nilpotent matrices with vanishing traces (should not exist in characteristic zero).
3. Test in characteristic p > 0 (where the conjecture should fail — find counterexamples).

**Refutation criterion:** Find a non-nilpotent matrix over a characteristic-zero field with tr(A^k) = 0 for k = 1, ..., n. (Mathematically, this is impossible by Newton's identities, so this hypothesis tests whether the formalization pipeline can capture this classical result.)

**Impact if true:** Establishes trace computation as a complete nilpotence test, reducing the cost of Keller condition verification from O(n³) determinant computation to n independent O(n³) trace computations (which are individually simpler and more numerically stable).

---

## Execution Plan

### Immediate (next cycle):
- **Hypothesis 5:** Formalize Newton's identities and prove the reverse direction of the trace criterion. This is the most tractable and would immediately strengthen the nilpotence toolkit.
- **Hypothesis 1 (n=3):** Construct explicit tame automorphisms in 3 variables and compute their inverse degrees computationally.

### Medium-term:
- **Hypothesis 2:** Formalize cubic homogeneous maps and their Jacobian structure. Test the compressed nilpotence index in dimensions 3-6.
- **Hypothesis 4:** Formalize tame decomposition theory and prove the degree bound for tame decompositions.

### Long-term:
- **Hypothesis 3:** Formalize stable equivalence with dimension accounting and tensor rank bounds.
