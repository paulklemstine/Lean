# Future Directions

## 1. Degree-Growth Rigidity for Tame Keller Maps

**Conjecture:** For every tame Keller map `F : k^n → k^n` (i.e., one that can be decomposed as a composition of affine and elementary maps), the inverse map `F⁻¹` has degree bounded by `deg(F)^{n-1}`.

**Test:** Formalize the class of tame automorphisms using the `elementaryMap` and `polyMapComp_isPolyAuto` infrastructure. Generate random compositions of 5-10 elementary maps in dimensions n = 2, 3, 4. For each, compute the inverse (by reversing the composition) and measure degree. Search for examples where inverse degree exceeds the conjectured bound.

**Impact:** If true, this gives an effective degree bound for inverse computation in the tame case, which is critical for algorithmic applications. If false, the counterexample would reveal new phenomena in automorphism degree growth. The formalization of `triangular_isPolyAuto` already establishes the base case.

## 2. Computational Nilpotence Detection for Cubic Jacobians

**Conjecture:** For a cubic homogeneous map F = I + H over a characteristic-zero field of dimension n ≤ 10, the Keller condition `det(I + JH) = 1` is computationally equivalent to `(JH)^n = 0` (nilpotence of the Jacobian of H). Moreover, nilpotence at level ⌈n/2⌉ + 1 suffices.

**Test:** Implement symbolic computation of `(JH)^k` for random cubic homogeneous H in dimensions 2-6 satisfying the Keller condition. Check whether nilpotence always holds and determine the minimal nilpotence index. Use the formalized `jacobianMatrix_H_homogeneous` to ensure degree tracking is correct.

**Impact:** If the sharper nilpotence bound holds, it dramatically reduces the complexity of verifying the Keller condition for cubic maps, potentially enabling computer-assisted proofs in low dimensions. The existing `jacobianMatrix_cubic_homogeneous` theorem provides the structural foundation.

## 3. Stable-Equivalence Complexity Collapse

**Conjecture:** Every cubic homogeneous Keller map in dimension n is stably equivalent (via `stableLift` and affine conjugation) to a Drużkowski map in dimension ≤ 2n.

**Test:** For dimensions n = 2, 3, implement the explicit reduction from general cubic homogeneous maps to Drużkowski form. Count the number of new variables introduced. Verify that the bound 2n holds in all tested cases. Use `druzkowskiMap_isCubicHomogeneous` and `isPolyAuto_stableLift_iff` as the formal scaffolding.

**Impact:** If true, this sharpens the Bass-Connell-Wright reduction by providing an explicit dimension bound, converting the Jacobian Conjecture into a finite (though enormous) checking problem in each dimension. If false, it would reveal that the reduction to Drużkowski form requires superlinear blowup, which would be a new structural insight.

## 4. Triangularization Detection for Low-Depth Keller Maps

**Conjecture:** In dimension n ≤ 4, every Keller map that can be expressed as a composition of at most 3 elementary maps is affine-conjugate to a triangular map.

**Test:** Enumerate all compositions of 1, 2, and 3 elementary maps in dimensions 2, 3, 4 (over Q, with small coefficient bounds). For each, check the Keller condition. For those satisfying it, attempt to find an affine conjugation to triangular form using Gröbner basis methods. Use `affine_isPolyAuto` and `triangular_isPolyAuto` to verify any discovered conjugations.

**Impact:** If true, this would show that "simple" Keller maps are always tame, supporting the broader conjecture that wild automorphisms cannot satisfy the Keller condition. The formalized composition and elementary map infrastructure directly enables this investigation.

## 5. Dimension-2 Cubic Homogeneous Classification

**Conjecture:** Every 2-dimensional cubic homogeneous Keller map is polynomial-automorphism-equivalent to one of exactly 3 normal forms (up to affine conjugation): (a) the identity, (b) a rank-1 map F(x,y) = (x + (αx + βy)³, y - (αx + βy)³), or (c) a Drużkowski map with nilpotent 2×2 matrix.

**Test:** Parameterize all 2D cubic homogeneous maps with undetermined coefficients. Impose the Keller condition and solve the resulting polynomial system. Classify the solution set up to GL₂ conjugation. For each normal form, construct the explicit polynomial inverse using the existing `jacobian_conjecture_dim2_quadratic_homogeneous` as a template (extended from degree 2 to degree 3).

**Impact:** A complete classification would provide the first machine-verified proof of the Jacobian Conjecture for all 2D cubic homogeneous maps, extending the existing dimension-2 quadratic result. It would also serve as a testbed for the general cubic reduction pipeline.

---

## Infrastructure Gaps Identified

The following Mathlib/infrastructure gaps were encountered during this formalization cycle:

1. **Weyl algebra**: Not available in Mathlib. Needed for the Dixmier bridge. A minimal formalization of generators, relations, and filtrations would unlock significant new theory.

2. **Polynomial map degree bounds**: No existing infrastructure for tracking degree of `bind₁` compositions. Needed for effective inverse degree bounds.

3. **Nilpotence of matrix polynomials**: Limited infrastructure for matrices over polynomial rings. The nilpotence criterion (Cayley-Hamilton for parametric matrices) would accelerate Jacobian conjecture work.

4. **Affine algebraic geometry**: No formal notion of polynomial automorphism groups, tame vs. wild classification, or the Abhyankar-Moh theorem.

## Available Infrastructure

The following infrastructure is now available for the next cycle:

- `PolyMap`, `polyMapComp`, `polyMapId` — polynomial map algebra
- `jacobianMatrix`, `jacobianDet` — Jacobian computation
- `isPolyAuto`, `isKellerMap` — automorphism and Keller predicates
- `affinePolyMap`, `affine_isPolyAuto` — complete affine theory
- `IsTriangularMap`, `triangular_isPolyAuto`, `jacobianDet_triangular` — complete triangular theory
- `elementaryMap`, `elementary_isPolyAuto` — elementary map automorphisms
- `stableLift`, `isPolyAuto_stableLift_iff` — stable reduction (both directions)
- `polyMapComp_isPolyAuto`, `polyMapComp_assoc` — composition algebra
- `druzkowskiMap`, `druzkowskiMap_isCubicHomogeneous` — Drużkowski theory
- `jacobianMatrix_cubic_homogeneous` — cubic Jacobian structure
- `JacobianConjectureHolds`, `CubicHomogeneousKellerHolds`, `DixmierConjectureHolds` — conjecture schemas
- `jacobian_iff_dixmier` — formal bridge statement
