# Future Directions: Generalized Reed–Muller Codes and Finite Field Geometry

## Overview

The formalization of the generalized Reed–Muller minimum distance theorem opens several concrete research directions that bridge coding theory, finite algebraic geometry, and computational complexity. Each direction below includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Full Lower Bound via Hyperplane Restriction Induction

**Status**: The upper bound (extremal polynomial construction) is fully formalized. The lower bound requires additional infrastructure.

**Concrete next step**: Formalize the polynomial factoring lemma for `MvPolynomial`:

```
If f ∈ MvPolynomial(Fin (n+1)) 𝔽 vanishes identically on the hyperplane x₀ = c,
then (X₀ - C c) ∣ f and totalDegree(f / (X₀ - C c)) ≤ totalDegree(f) - 1.
```

**Required infrastructure**:
- Connect `MvPolynomial.finSuccEquiv` with `fiberRestrict` to show that fiber vanishing implies polynomial divisibility
- Formalize the factor theorem for polynomials over integral domains (`Polynomial.dvd_iff_isRoot`)
- Track total degree through the `finSuccEquiv` equivalence
- Prove the numerical optimization: for all valid t, `(q-t) * minWt(n-1, d-t) ≥ (q-b) * q^(n-1-a)`

**Proof strategy**: The fiber restriction infrastructure (`hammingWeight_sum_fibers`, `vanishing_fiber_count_le`, `hammingWeight_ge_of_fiber_bound`) is already formalized. The missing piece is connecting fiber vanishing to degree reduction via polynomial factoring.

**Impact**: Completes the exact minimum distance theorem, making it the first fully formalized proof of this classical result for arbitrary finite fields.

---

## Direction 2: Rigidity / Classification of Minimum-Weight Codewords

**Hypothesis**: Every minimum-weight codeword of RM_q(n,d) is, up to affine equivalence, the canonical extremal polynomial:

```
f(x) = c · ∏_{i<a} ∏_{c'≠αᵢ} (xᵢ - c') · ∏_{j<b} (x_a - βⱼ)
```

**Proof strategy**:
1. Show that any minimum-weight polynomial must have the maximum number of vanishing fibers in some coordinate (exactly q-1)
2. After factoring, the quotient must again achieve minimum weight in fewer variables
3. By induction, the polynomial must have the product structure
4. The affine group acts transitively on the choices of coordinates and field elements

**Formal statement** (target):
```lean
theorem extremizer_rigidity
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0)
    (hdeg : f.totalDegree ≤ d)
    (hmin : hammingWeight f = (card 𝔽 - b) * (card 𝔽) ^ (n - 1 - a)) :
    ∃ (σ : Equiv.Perm (Fin n)) (α : Fin n → 𝔽) (T : Finset 𝔽) (c : 𝔽),
      c ≠ 0 ∧ T.card = b ∧ ...
```

**Cross-domain impact**: This would give the first formal classification of extremal hypersurfaces in finite affine geometry under degree constraints.

---

## Direction 3: Projective Reed–Muller Codes

**Background**: Projective Reed–Muller codes evaluate homogeneous polynomials on projective space P^(n-1)(𝔽_q) instead of affine space.

**Hypothesis**: The minimum distance of the projective Reed–Muller code PRM_q(n,d) is:
```
d_min = q^{n-1-a} - b · q^{n-2-a}  (for appropriate decomposition)
```

**Proof strategy**: Relate projective evaluations to affine evaluations via dehomogenization. The projective code arises as a punctured/shortened version of the affine code.

**Formal target**:
```lean
def projectiveRMMinDistance (q n d : ℕ) : ℕ := ...
theorem projective_rm_exact_distance ... := ...
```

**Impact**: Projective codes have better rate-distance tradeoffs and are used in algebraic geometry codes. Formalizing their parameters would extend the infrastructure significantly.

---

## Direction 4: Gröbner Footprint Bound for Finite Grids

**Background**: The minimum distance can alternatively be proved via the Gröbner footprint (leading monomial shadow) method, which gives a purely combinatorial proof.

**Hypothesis**: For any nonzero reduced polynomial f modulo (X_i^q - X_i), the support of the evaluation vector is at least as large as the "anti-footprint" of the leading monomial.

**Required infrastructure**:
- Reduction modulo the vanishing ideal (X_i^q - X_i)
- Monomial orders for `MvPolynomial`
- Leading monomial extraction
- Footprint/staircase counting

**Proof strategy**:
1. Show every function on 𝔽^n has a unique reduced representative with exponents < q
2. The leading monomial X_1^{e_1}...X_n^{e_n} determines a "footprint" region
3. The number of nonzeros is at least the complement of the footprint: ∏(q - e_i) ≥ (q-b)q^{n-1-a}

**Impact**: This connects the minimum distance theorem to Gröbner basis theory, opening a formal bridge to computational commutative algebra. It would also provide an independent proof of the minimum distance formula.

---

## Direction 5: Exact Soundness Theorems for Low-Degree Tests

**Background**: Low-degree tests are fundamental primitives in PCP constructions and interactive proofs. The Schwartz-Zippel lemma provides soundness bounds, but the generalized Reed–Muller theorem gives EXACT worst-case soundness.

**Concrete target**:
```lean
theorem low_degree_test_exact_soundness
    (q n d : ℕ) (hq : 1 < q) (f : (Fin n → 𝔽) → 𝔽)
    (hf : f ≠ 0) (hdeg : isDegreeAtMost d f) :
    (card {x : Fin n → 𝔽 | f x ≠ 0} : ℚ) / (card 𝔽) ^ n ≥
      (q - b) * q^(n-1-a) / q^n
```

**Applications**:
- Optimal soundness for sum-check protocol variants
- Tight analysis of algebraic proximity testing
- Improved PCP constructions using exact distance information

**Cross-domain connection**: This bridges coding theory and computational complexity, providing formal infrastructure for verified PCP constructions.

---

## Direction 6: Generalized Hamming Weights and Weight Hierarchies

**Background**: The r-th generalized Hamming weight of a linear code is the minimum support size of any r-dimensional subcode. For Reed–Muller codes, these are known but not formalized.

**Hypothesis**: The r-th generalized Hamming weight of RM_q(n,d) has an explicit formula involving a multi-parameter generalization of the (a,b) decomposition.

**Proof strategy**: Extend the extremal polynomial construction to r-dimensional subcodes. The extremizers should be "product" subcodes concentrated on a few coordinates.

**Impact**: Generalized Hamming weights determine the wire-tap channel capacity and the security of secret sharing schemes based on Reed–Muller codes.

---

## Direction 7: Finite Schwartz–Zippel with Optimal Constants

**Target**: Formalize the sharp version of the Schwartz-Zippel lemma as a standalone theorem in finite algebraic geometry:

```lean
theorem sharp_schwartz_zippel
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d) :
    card {x : Fin n → 𝔽 | f x = 0} ≤ q^n - (q-b) * q^(n-1-a)
```

This is equivalent to the minimum distance theorem but phrased as a zero-count bound, making it directly applicable in:
- Probabilistic method arguments in combinatorics
- Derandomization constructions
- Algebraic circuit complexity lower bounds

---

## Implementation Roadmap

### Phase 1 (Near-term): Complete the Lower Bound
- Formalize `MvPolynomial` factoring via `finSuccEquiv`
- Prove degree tracking through factoring
- Complete the inductive lower bound proof
- **Estimated effort**: 1-2 weeks

### Phase 2 (Medium-term): Rigidity and Applications  
- Prove extremizer classification
- Formalize low-degree test soundness
- Add projective Reed–Muller parameters
- **Estimated effort**: 1-2 months

### Phase 3 (Long-term): Algebraic Geometry Bridge
- Gröbner footprint bound formalization
- Generalized Hamming weights
- Connection to algebraic geometry codes (Goppa codes, AG codes)
- **Estimated effort**: 3-6 months

---

## Keywords

generalized Reed–Muller code, minimum distance, finite-field hypersurface, sharp zero-count theorem, affine fiber decomposition, tensor-product vanishing, low-degree testing, algebraic PCP, finite Nullstellensatz, Gröbner footprint bound, extremal support, finite affine geometry, weight hierarchy, projective Reed–Muller code, polynomial identity testing
