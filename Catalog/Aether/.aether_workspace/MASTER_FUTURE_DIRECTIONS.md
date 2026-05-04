# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-04 17:01*

## 1. Congruence-Level Tropical Nullstellensatz

The current formalization establishes the set-theoretic tropical Nullstellensatz:
`tropRadical(I) = idealOfSet(tropZeroSet(I))`. The next step is to lift this to a
**congruence-level** statement. In classical algebra, the Nullstellensatz relates
ideals to varieties; in the tropical/idempotent world, the natural replacement for
ideals is **semiring congruences** (since tropical semirings lack additive inverses
and hence lack proper two-sided ideals in the classical sense).

**Concrete target**: Define a `radicalCongruence` on function semirings generated
by a finite family, and prove it equals the `vanishingCongr` of the common zero set.
The `vanishingCongr` is already defined in the current file; the missing piece is the
notion of *generated congruence* and the proof that the radical congruence is exactly
recovered from geometric data.

## 5. Algorithmic Extraction from Density Proofs

**Statement**: The constructive content of the density proof can be extracted into an explicit approximation algorithm: given f ∈ C(X × Y, ℝ) and ε > 0, compute a max-plus combination of pure tensors within ε of f.

**Approach**: The proof via the lattice Stone–Weierstrass theorem is inherently constructive — it builds approximants via two-point interpolation and finite coverings. Making this extraction explicit requires:
1. Bounding the number of terms in the tropical sum (related to covering numbers of X × Y).
2. Choosing the separating functions optimally (related to tropical rank minimization).
3. Implementing the construction as a certified algorithm in Lean with `#eval` support.

**Significance**: Bridges the gap between existence theorems and practical approximation, enabling verified numerical tropical computation.

## 5. Certified Symbolic Robustness via Vanishing Ideals

In machine learning applications, **robustness** means that small perturbations of
inputs do not change the model's output. For tropical/max-plus models, this can be
formalized algebraically:

- A model is **tropically robust** at a point `x` if `x` is in the interior of a
  decision region (complement of the tropical zero set).
- A **robustness certificate** for a family `G` at point `x` is a proof that
  `x ∉ tropZeroSet(G)`, which by the Nullstellensatz is equivalent to the existence
  of some generator that does not vanish at `x`.

**Concrete target**: Formalize the notion of tropical robustness for max-plus linear
classifiers, prove that robustness is equivalent to non-membership in the zero set,
and implement a certified robustness checker that outputs Lean proofs.

## 3. Algorithmic Tropical Decision Region Extraction

The Nullstellensatz has direct computational consequences. Given an EML model
(e.g., a tropical neural network or max-plus linear map), the generators define a
finite family of tropical functions. The theorem guarantees:

- **Decision regions** are precisely the connected components of complements of
  tropical zero sets.
- **Certificates of invariance**: if a function belongs to the tropical radical,
  it vanishes on the decision boundary — providing a symbolic proof that the
  function is insensitive to inputs in that region.

**Concrete target**: Implement (in Lean + Python) an algorithm that takes a finite
family of max-plus affine functions and outputs the tropical zero set as a polyhedral
complex, together with a Lean proof that the computed complex is correct.

## 2. Spectral/Topological Duality for EML Tropical Function Algebras

When `X` is a compact Hausdorff space and `A ⊆ C(X, S)` is a separating EML
subalgebra, the tropical Nullstellensatz should yield a **Gelfand-type duality**:
the space `X` can be reconstructed (up to homeomorphism) from the algebraic data
of `A`. Concretely:

- Define the **tropical spectrum** `Spec_trop(A)` as the set of maximal congruences
  of `A`, equipped with the hull-kernel topology.
- Prove that the natural map `X → Spec_trop(A)` sending `x` to `ker_x(f,g) ↔ f(x) = g(x)`
  is a homeomorphism when `A` separates points and is closed under tropical operations.

This would be a tropical analogue of the Gelfand–Kolmogorov theorem, providing a
full algebra-geometry dictionary for EML function algebras.

## 4. Min-Plus / Max-Plus Duality for Zero-Set Semantics

The current formalization uses a general `Bot` type, which specializes to both
max-plus (where `⊥ = -∞`) and min-plus (where `⊥ = +∞`) tropical semirings.
An important structural result is that these two semantics are **order-dual**:

- The zero set of a family in the max-plus semiring corresponds to the zero set
  of the "negated" family in the min-plus semiring.
- The Galois connection `(Z, I)` in one setting corresponds to the dual connection
  in the other.

**Concrete target**: Define an `OrderDual` isomorphism between max-plus and min-plus
function semirings, and prove that `tropZeroSet` and `idealOfSet` transform covariantly
under this duality.