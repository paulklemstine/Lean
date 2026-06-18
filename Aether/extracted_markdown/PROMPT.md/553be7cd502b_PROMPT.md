
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: This cycle pushed the discrete Hodge program from its *geometric/decomposition* 
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Sixth Cycle

## Synthesis

This cycle pushed the discrete Hodge program from its *geometric/decomposition* layer into its
**operator-algebra and spectral layer**, realizing the two most tractable open directions of the
fifth-cycle program (Spectral positivity, Direction 3; and the full three-way idempotent splitting,
Direction 1) as sorry-free Lean.

First, a repair: the Hodge stack depends on `import Speculative.AutoResearch.*` while the sources
live under `Catalog/`, and the package was missing its `srcDir`, so nothing elaborated. Setting
`srcDir = "Catalog"` in `lakefile.toml` re-established the build.

Two new files were then added, both building directly on the existing foundation
(`HodgeBettiRank.hodgeLap`, `HodgeThreeWayDecomposition`, `HodgeHarmonicProjector`,
`HodgeIsomorphism`):

* **`HodgeSpectralPositivity.lean` (Direction 3).** The Rayleigh quadratic form of the Hodge
  Laplacian is an explicit **sum of squares** `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²`
  (`hodgeLap_quadratic_form`). From this single identity flow: positive semidefiniteness
  `0 ≤ ⟪Δ x, x⟫` (`hodgeLap_nonneg`); the equality-case description that the vanishing locus of the
  form *is* the harmonic space, `⟪Δ x, x⟫ = 0 ↔ x ∈ ker Δ` (`hodgeLap_quadratic_eq_zero_iff`);
  symmetry `Δ.IsSymmetric` (`hodgeLap_isSymmetric`), the precise input the finite-dimensional
  spectral theorem demands; and nonnegativity of every eigenvalue `Δ x = μ x, x ≠ 0 ⟹ 0 ≤ μ`
  (`hodgeLap_eigenvalue_nonneg`). This is the abstract-operator counterpart of the matrix-level
  `HodgeFullDecomposition.fullHodge_psd`, lifted to arbitrary finite-dimensional inner product
  cochain spaces.

* **`HodgeResolutionIdentity.lean` (Direction 1).** The static orthogonal direct sum
  `V = range d* ⊕ range e ⊕ ker Δ` is upgraded to the **resolution of the identity**
  `id = P_coexact + P_exact + P_harmonic` (`hodge_resolution_identity`), where each `P_•` is the
  corresponding `Submodule.starProjection`. The three projectors **pairwise annihilate**
  (`P_i ∘ P_j = 0` for `i ≠ j`: `harmonicProjection_comp_exactProjection_eq_zero`,
  `harmonicProjection_comp_coexactProjection_eq_zero`,
  `exactProjection_comp_coexactProjection_eq_zero`), and each one **extracts its own summand** from
  a three-way decomposition (`coexactProjection_of_threeway`, `exactProjection_of_threeway`,
  `harmonicProjection_of_threeway`). Together with `HodgeHarmonicProjector.harmonicProjection_*`
  this exhibits the Hodge decomposition as a complete system of mutually orthogonal spectral
  idempotents summing to `1`.

The unifying picture is now fully operator-theoretic and *dual*: the cochain space is represented
by the commuting/orthogonal algebra of Hodge projectors, the Laplacian is represented by its
sum-of-squares quadratic form, and the spectral facts (PSD, `spec Δ ⊆ [0,∞)`, `0`-eigenspace
`= ker Δ`, resolution of `1`) are read off the geometry of that representation with no further
construction.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `hodgeLap_quadratic_form` | HodgeSpectralPositivity | `⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²` |
| `hodgeLap_nonneg` | HodgeSpectralPositivity | `0 ≤ ⟪Δ x, x⟫` (Δ is PSD) |
| `hodgeLap_quadratic_eq_zero_iff` | HodgeSpectralPositivity | `⟪Δ x, x⟫ = 0 ↔ x ∈ ker Δ` |
| `hodgeLap_isSymmetric` | HodgeSpectralPositivity | `Δ.IsSymmetric` |
| `hodgeLap_eigenvalue_nonneg` | HodgeSpectralPositivity | `Δ x = μ x, x ≠ 0 ⟹ 0 ≤ μ` |
| `coexactProjection_of_threeway` | HodgeResolutionIdentity | `P_coexact (c+a+h) = c` |
| `exactProjection_of_threeway` | HodgeResolutionIdentity | `P_exact (c+a+h) = a` |
| `harmonicProjection_of_threeway` | HodgeResolutionIdentity | `P_harmonic (c+a+h) = h` |
| `harmonicProjection_comp_exactProjection_eq_zero` | HodgeResolutionIdentity | `P_harm ∘ P_exact = 0` |
| `harmonicProjection_comp_coexactProjection_eq_zero` | HodgeResolutionIdentity | `P_harm ∘ P_coexact = 0` |
| `exactProjection_comp_coexactProjection_eq_zero` | HodgeResolutionIdentity | `P_exact ∘ P_coexact = 0` |
| `hodge_resolution_identity` | HodgeResolutionIdentity | `P_coexact x + P_exact x + P_harmonic x = x` |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Green's operator inverts `Δ` off the harmonic space
With the resolution of identity `id = P_coexact + P_exact + P_harmonic` and PSD now in hand, conjecture
there is a **Green's operator** `G : V →ₗ V` (the Moore–Penrose pseudoinverse of `Δ`) with
`Δ ∘ G = G ∘ Δ = id − P_harmonic` and `G ∘ P_harmonic = 0`, so `G` inverts `Δ` exactly on the
orthogonal complement of the harmonic space `(ker Δ)ᗮ = range d* ⊕ range e`. Falsifiable by any
operator claimed to be `G` for which `Δ (G x) ≠ x − P_harmonic x` on some coexact-or-exact `x`.
**The key insight is** that `hodge_resolution_identity` already splits `V` into the harmonic block
(where `Δ = 0`, by `hodgeLap_quadratic_eq_zero_iff`) and the complementary block `range d* ⊕ range e`
on which `Δ` is *injective* — because `hodgeLap_quadratic_eq_zero_iff` makes `ker Δ` exactly the
zero-form locus, so `Δ` restricted to `(ker Δ)ᗮ` has trivial kernel and is therefore invertible in
finite dimensions; `G` is that inverse extended by `0` on `ker Δ`. **Why now?** The two ingredients
of a pseudoinverse — a complemented kernel (the resolution of identity) and injectivity on the
complement (the strict positivity equality case) — are both theorems this cycle, so `G` is assembled
by `Submodule.starProjection` + `LinearMap.inverse` rather than any new analysis.

### 2. The Hodge isomorphism is a quotient isometry via the harmonic projector
`HodgeIsomorphism.hodgeCohomologyEquiv : (ker d / range e) ≃ₗ ker Δ` is still only linear. Conjecture
it is an **isometry** for the quotient norm: the quotient norm of a cohomology class equals the norm
of its harmonic representative, `‖[x]‖ = ‖P_harmonic x‖` for closed `x`. Falsifiable by a class whose
quotient norm differs from its harmonic representative's norm. **The key insight is** that
`HodgeHarmonicProjector.harmonic_representative_norm_minimal` already proves `‖h‖ ≤ ‖x − e u‖` for
every competitor in the class, and `harmonicProjection_closed`/`exactProjection_of_threeway` now show
the harmonic representative *is* `P_harmonic x`, so the infimum defining the quotient norm is attained
exactly at the harmonic projection. **Why now?** The minimization half and the projector identity are
theorems; only the identification of Mathlib's `Submodule.Quotient.norm_mk` infimum with this attained
minimum remains, upgrading the `LinearEquiv` to a `LinearIsometryEquiv`.

### 3. Diffusion message passing contracts onto `P_harmonic` at the spectral-gap rate
With `Δ` proven symmetric and PSD, and `id = P + (id − P)` a proven decomposition into a fixed
harmonic block and a strictly-positive complementary block, conjecture that for an admissible step
`0 < α < 2/λ_max` the iterate `(id − αΔ)^[k]` converges to `P_harmonic`, with
`‖(id − αΔ)^[k] x − P_harmonic x‖ ≤ ρᵏ ‖x − P_harmonic x‖` where `ρ = max |1 − αλ| < 1` over the
nonzero eigenvalues. Falsifiable by a complex and a step `α` in range for which some iterate fails to
contract. **The key insight is** that `harmonicProjection_idempotent` plus the resolution of identity
make `ker Δ` and `(ker Δ)ᗮ` simultaneously `Δ`-invariant; on the harmonic block `Δ = 0` so the iterate
is *fixed* (`hodgeLap_quadratic_eq_zero_iff`), while on the complement `hodgeLap_eigenvalue_nonneg`
gives strictly positive eigenvalues and hence geometric contraction. **Why now?** The invariant
splitting and the strict positivity on the complement are both theorems, so the convergence is a
one-dimensional geometric-series estimate per eigenvector rather than a fresh dynamical-systems study.

### 4. Spectral resolution: `Δ = Σ λᵢ Pᵢ` with `P₀ = P_harmonic`
Conjecture the full spectral theorem for `Δ`: there is an orthonormal eigenbasis with nonnegative
eigenvalues `0 = λ₀ ≤ λ₁ ≤ …`, the `0`-eigenprojection is exactly `P_harmonic`, and `Δ` resolves as
`Σ λᵢ Pᵢ` with the `Pᵢ` a refinement of the three-way resolution of identity (the harmonic term `P₀`
is `P_harmonic`; the positive eigenspaces refine `P_coexact + P_exact`). Falsifiable by an eigenvalue
that is negative, or a `0`-eigenvector that is not harmonic. **The key insight is** that
`hodgeLap_isSymmetric` feeds Mathlib's `LinearMap.IsSymmetric.orthonormalBasis_eigenvectors` /
`spectral_theorem` directly, `hodgeLap_eigenvalue_nonneg` pins every eigenvalue to `[0,∞)`, and
`hodgeLap_quadratic_eq_zero_iff` identifies the `0`-eigenspace with `ker Δ = ker P_harmonicᶜ`.
**Why now?** All three hypotheses of the finite-dimensional spectral theorem (symmetry, real
eigenvalue signs, kernel description) are now theorems, so the eigendecomposition is an application,
and matching `P₀` to `P_harmonic` is `hodge_resolution_identity` bookkeeping.

### 5. Functoriality of the projector resolution under chain maps
Conjecture: a morphism of two-step complexes (a commuting ladder `U→V→W ⟶ U'→V'→W'`) induces a map
`ker Δ → ker Δ'` that intertwines the harmonic projectors, `P'_harmonic ∘ φ = P'_harmonic ∘ φ ∘
P_harmonic` on closed cochains, and agrees with the induced cohomology map through
`hodgeCohomologyEquiv`; moreover the *whole* resolution of identity is natural, `φ` carrying each
spectral idempotent `Pᵢ` to `P'ᵢ` up to the ladder squares. Falsifiable by a chain map whose
harmonic-block map fails to commute with the cohomology map. **The key insight is** that
`exactProjection_of_threeway`/`harmonicProjection_of_threeway` characterize each `Pᵢ` purely by
"extract the i-th summand of a decomposition," so naturality reduces to the two ladder squares
(closed↦closed, exact↦exact) plus the now-proven resolution `Σ Pᵢ = id`. **Why now?** With every
projector a concrete idempotent and the resolution of identity a theorem, functoriality is a diagram
chase over established complementarity rather than a new construction.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/HodgeEPolynomial.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Hodge–Deligne E-polynomial as a Bridge to Arithmetic

This file introduces the two-variable **Hodge–Deligne E-polynomial**
`E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`
on an abstract `HodgeDiamond` structure and proves two genuine *functional equations*:

* `epoly_serre_functional_equation` — the Serre/Poincaré duality equation
  `E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)` (under Serre duality of `X`);
* `epoly_mirror_functional_equation` — the mirror equation
  `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)` (unconditionally).

Specialising at `u = v = 1` recovers `eulerChar_mirror_sign`, the statement that the
topological Euler characteristic of the mirror diamond is `(-1)ⁿ` times the original.
We also record `totalDim_mirror` (the total Hodge dimension is mirror-invariant) and
upgrade the mirror involution to Calabi–Yau data (`CalabiYauData.mirror`).

This is a *duality / representation* bridge: it translates the geometric mirror
involution `(p,q) ↦ (n-p, q)` and Serre duality `(p,q) ↦ (n-p, n-q)` into algebraic
symmetries (functional equations) of a single polynomial invariant.

-- !-- Lab Notebook -- !--
Hypothesis: The numerical mirror sign `χ(mirror X) = (-1)ⁿ χ(X)` is the `u=v=1`
  shadow of a polynomial-level functional equation in the Hodge–Deligne E-polynomial.
Result: Both the Serre/Poincaré and mirror functional equations are formalised over an
  arbitrary field `K`, and the numerical Euler-characteristic sign and total-dimension
  invariance are recovered as corollaries (the former literally by specialising the
  E-polynomial at `u = v = 1`, see `epoly_one_one_eq_eulerChar`).
Insight: Both geometric involutions are *reflections* `j ↦ n - j` on the index range,
  so `Finset.sum_range_reflect` is the single combinatorial engine behind all the
  functional equations; the `(-1)ⁿ` and `(uv)ⁿ` prefactors are exactly the bookkeeping
  of the parity shift `(-1)^{(n-p)+(n-q)} = (-1)^{2n}·(-1)^{p+q}` and the exponent shift
  `uⁿ · u⁻ᵖ = u^{n-p}`.
Failure analysis: Defining `h` on all of `ℕ × ℕ` (rather than `Fin (n+1)²`) means the
  mirror involution `mirror ∘ mirror = id` only holds on the support `p, q ≤ n`; we
  therefore state the involution at the level of the E-polynomial / pointwise on the
  support (`mirror_mirror_h`, `epoly_mirror_mirror`) rather than as a definitional
  equality of structures.
-/

namespace HodgeEPolynomial

open Finset

/-- An abstract **Hodge diamond**: a complex dimension `n` together with the Hodge
numbers `h^{p,q}`. We store `h` as a function on all of `ℕ × ℕ`; only the values with
`p, q ≤ n` are mathematically meaningful (the rest are treated as padding). -/
structure HodgeDiamond where
  /-- The complex dimension. -/
  n : ℕ
  /-- The Hodge numbers `h^{p,q}`. -/
  h : ℕ → ℕ → ℤ

namespace HodgeDiamond

/-- The **mirror** diamond, implementing the involution `(p,q) ↦ (n-p, q)` on Hodge
numbers (the combinatorial avatar of mirror symmetry exchanging complex and Kähler
moduli). -/
def mirror (X : HodgeDiamond) : HodgeDiamond where
  n := X.n
  h := fun p q => X.h (X.n - p) q

@[simp] lemma mirror_n (X : HodgeDiamond) : X.mirror.n = X.n := rfl

@[simp] lemma mirror_h (X : HodgeDiamond) (p q : ℕ) :
    X.mirror.h p q = X.h (X.n - p) q := rfl

/-- **Serre duality** for a Hodge diamond: `h^{p,q} = h^{n-p, n-q}` on the support. -/
def SerreDual (X : HodgeDiamond) : Prop :=
  ∀ p q, p ≤ X.n → q ≤ X.n → X.h p q = X.h (X.n - p) (X.n - q)

variable {K : Type*} [Field K]

/-- The **Hodge–Deligne E-polynomial** `E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`,
evaluated in an arbitrary field `K`. -/
def EPoly (X : HodgeDiamond) (u v : K) : K :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1),
    (-1) ^ (p + q) * (X.h p q : K) * u ^ p * v ^ q

/-- The topological **Euler characteristic** `χ(X) = Σ_{p,q} (-1)^{p+q} h^{p,q}`. -/
def eulerChar (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1), (-1) ^ (p + q) * X.h p q

/-- The **total Hodge dimension** `Σ_{p,q} h^{p,q}` (the total Betti number). -/
def totalDim (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1), X.h p q

/-- Specialising the E-polynomial at `u = v = 1` recovers the Euler characteristic. -/
-- !-- E(X;1,1) collapses each monomial to its sign times `h^{p,q}`; push the ℤ→K cast
-- through the double sum. -- !--
theorem epoly_one_one_eq_eulerChar (X : HodgeDiamond) :
    EPoly X (1 : K) 1 = (X.eulerChar : K) := by
  unfold HodgeDiamond.EPoly HodgeDiamond.eulerChar; simp +decide [ mul_assoc, mul_comm, mul_left_comm, pow_add ] ;

/-- **Mirror functional equation.** `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)`. -/
-- !-- Pull the prefactor `(-1)ⁿ uⁿ` into the double sum, then reflect the `p`-index via
-- `sum_range_reflect`; `uⁿ · (u⁻¹)ᵖ = u^{n-p}` and the parity shift `(-1)^{(n-p)+q}` match. -- !--
theorem epoly_mirror_functional_equation (X : HodgeDiamond) (u v : K) (hu : u ≠ 0) :
    EPoly X.mirror u v = (-1) ^ X.n * u ^ X.n * EPoly X u⁻¹ v := by
  simp +decide only [EPoly];
  simp +decide [ hu, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, mul_pow, Finset.sum_mul ];
  refine' Finset.sum_bij ( fun p hp => X.n - p ) _ _ _ _ <;> simp_all +decide [ Nat.sub_sub_self, Finset.mem_range_succ_iff ];
  · exact fun a₁ ha₁ a₂ ha₂ h => by rw [ tsub_right_inj ] at h <;> linarith;
  · exact fun b hb => ⟨ X.n - b, Nat.sub_le _ _, Nat.sub_sub_self hb ⟩;
  · intro a ha; refine' Finset.sum_congr rfl fun x hx => _; rw [ show u ^ a = u ^ X.n / u ^ ( X.n - a ) by rw [ eq_div_iff ( pow_ne_zero _ hu ), ← pow_add, Nat.add_sub_of_le ha ] ] ; ring;
    rw [ show ( -1 : K ) ^ X.n = ( -1 : K ) ^ ( X.n - a ) * ( -1 : K ) ^ a by rw [ ← pow_add, Nat.sub_add_cancel ha ] ] ; ring;
    norm_num [ pow_mul' ]

/-- **Serre/Poincaré functional equation.** Under Serre duality,
`E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)`. -/
-- !-- Derive from the mirror equation applied to `mirror X`: reflect both indices via
-- `sum_range_reflect`, then use Serre duality `h^{p,q} = h^{n-p,n-q}` and `(-1)^{2n} = 1`. -- !--
theorem epoly_serre_functional_equation (X : HodgeDiamond) (hX : X.SerreDual)
    (u v : K) (hu : u ≠ 0) (hv : v ≠ 0) :
    EPoly X u v = (u * v) ^ X.n * EPoly X u⁻¹ v⁻¹ := by
  convert epoly_mirror_functional_equation ( X.mirror ) u v hu using 1;
  · unfold HodgeDiamond.EPoly;
    congr! 3;
    grind +suggestions;
  · simp +decide [ HodgeDiamond.mirror, pow_add, mul_pow, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, EPoly ];
    refine' Finset.sum_congr rfl fun i hi => _;
    rw [ ← Finset.sum_flip ];
    refine' Finset.sum_congr rfl fun j hj => _;
    have := hX i ( X.n - j ) ( by linarith [ Finset.mem_range.mp hi ] ) ( by linarith [ Finset.mem_range.mp hj, Nat.sub_le X.n j ] ) ; simp_all +decide [ Nat.sub_sub_self ( show j ≤ X.n from by linarith [ Finset.mem_range.mp hj ] ) ] ;
    rw [ show v ^ X.n = v ^ ( X.n - j ) * v ^ j by rw [ ← pow_add, Nat.sub_add_cancel hj ] ] ; ring;
    rw [ show X.n = j + ( X.n - j ) by rw [ Nat.add_sub_of_le hj ] ] ; ring;
    simp +decide [ mul_left_comm ( v ^ ( X.n - j ) ), mul_assoc, hv ]

/-- **Numerical mirror sign.** `χ(mirror X) = (-1)ⁿ χ(X)`. This is the `u = v = 1`
specialisation of `epoly_mirror_functional_equation`. -/
-- !-- Reflect the `p`-index in the definition of `eulerChar`; the parity shift
-- `(-1)^{(n-p)+q} = (-1)ⁿ (-1)^{p+q}` produces the global sign. -- !--
theorem eulerChar_mirror_sign (X : HodgeDiamond) :
    X.mirror.eulerChar = (-1) ^ X.n * X.eulerChar := by
  unfold HodgeDiamond.eulerChar HodgeDiamond.mirror;
  simp +decide only [mul_sum _ _ _];
  refine' Finset.sum_bij ( fun p hp => X.n - p ) _ _ _ _ <;> simp_all +decide;
  · intros; omega;
  · exact fun b hb => ⟨ X.n - b, Nat.sub_le _ _, Nat.sub_sub_self hb ⟩;
  · intro a ha; refine' Finset.sum_congr rfl fun x hx => _; rw [ show ( -1 : ℤ ) ^ X.n = 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Hodge–Laplacian Message Passing, Seventh Cycle

## Synthesis

This cycle carried the discrete Hodge program from its **operator-algebra / spectral** layer
(sixth cycle: `HodgeSpectralPositivity`, `HodgeResolutionIdentity`) into its **analytic and
dynamical** layer: the *invertibility* of the Hodge Laplacian off the harmonic space and the
*dynamics* of Laplacian message passing. Two sorry-free files were added, both building directly
on the existing foundation (`HodgeBettiRank.hodgeLap`, `HodgeSpectralPositivity.hodgeLap_isSymmetric`
and `hodgeLap_quadratic_eq_zero_iff`, `HodgeHarmonicProjector`, `HodgeResolutionIdentity`).

A small infrastructure repair was needed first: the Hodge stack imports `Speculative.AutoResearch.*`
while the sources live under `Catalog/`, and the package declared no `srcDir`, so nothing
elaborated. Setting `srcDir = "Catalog"` in `lakefile.toml` re-established the build.

* **`HodgeDiffusionContraction.lean` (Direction 3, invariant-splitting half).** The explicit-Euler
  diffusion step `S = id − a·Δ` is introduced as the elementary unit of Hodge message passing. The
  self-adjoint range identity `range Δ = (ker Δ)ᗮ` (`hodgeLap_range_eq_orthogonal_ker`) shows every
  diffusion increment `Δ x` is purely non-harmonic. From it: `S` *fixes* the harmonic space
  pointwise and so does every iterate (`diffStep_harmonic_fixed`, `diffStep_pow_harmonic_fixed`),
  identifying `ker Δ` with the fixed-point set of message passing; and the harmonic projection is a
  *conserved quantity* of the dynamics, `P (Sᵏ x) = P x` for all `k`
  (`harmonicProjection_diffStep`, `harmonicProjection_diffStep_pow`). The harmonic component of a
  signal is never created or destroyed by diffusion — only the non-harmonic part evolves.

* **`HodgeGreenOperator.lean` (Direction 1, constructive core).** On the complement of the harmonic
  space `Δ` is *injective* (`hodgeLap_injOn_orthogonal_ker`, from the strict-positivity equality
  case) and *surjective onto* `(ker Δ)ᗮ` (from `hodgeLap_range_eq_orthogonal_ker`), hence invertible
  there. Consequently, for every cochain `x` there is a **unique** coexact-or-exact cochain `z`
  whose Laplacian recovers the non-harmonic part: `∃! z ∈ (ker Δ)ᗮ, Δ z = x − P x`
  (`hodgeLap_green_exists`, `hodgeLap_green_existsUnique`). That unique `z` is the value of the
  Green's operator (Moore–Penrose pseudoinverse) of `Δ`.

The picture is now *analytic*: the cochain space splits into a fixed harmonic block (the conserved
ground state of diffusion, the kernel of the pseudoinverse) and a strictly-positive complementary
block on which `Δ` is invertible and diffusion strictly evolves. Every ingredient — fixed-point
set, conserved projection, complemented kernel, injectivity on the complement, unique Green value —
is now a theorem.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `hodgeLap_apply_mem_orthogonal_ker` | HodgeDiffusionContraction | `Δ x ∈ (ker Δ)ᗮ` |
| `hodgeLap_range_eq_orthog
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
