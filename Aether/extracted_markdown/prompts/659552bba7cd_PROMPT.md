
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

**Title**: This cycle promoted the *Hodge–Betti dimension count* of `HodgeBettiRank.lean` f
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Fourth Cycle

## Synthesis

This cycle promoted the *Hodge–Betti dimension count* of `HodgeBettiRank.lean` from a numerical
equality to two genuinely structural theorems, completing the local-to-global core of the
spectral-depth / full-Hodge-decomposition program at the operator level.

* **`HodgeThreeWayDecomposition.lean` — the strong (three-way) Hodge decomposition
  (Research Direction 2).** For a two-step cochain complex `U --e--> V --d--> W` with the chain
  condition `d ∘ e = 0`, the middle cochain space splits as a triple **orthogonal direct sum**
  `V = range d* ⊕ range e ⊕ ker Δ` (coexact ⊕ exact ⊕ harmonic). The three summands are pairwise
  orthogonal (`range_e_le_orthogonal_range_adjoint_d`, `harmonic_le_orthogonal_range_e`,
  `harmonic_le_orthogonal_range_adjoint_d`), they jointly span `V` (`hodge_three_way_span`), and
  their dimensions add to `dim V` (`hodge_three_way_finrank`). The structural engine is the Hodge
  split of the *closed* space `range e ⊔ ker Δ = ker d` (`closed_eq_exact_sup_harmonic`), built
  from the relative orthogonal complement law and the coexact identity `(ker d)ᗮ = range d*`
  (`orthogonal_ker_d_eq_range_adjoint_d`).

* **`HodgeIsomorphism.lean` — the Hodge isomorphism `harmonic ≅ cohomology`
  (Research Direction 1).** The Hodge–Betti *equidimensionality* `dim (ker Δ) = dim ker d − rank e`
  is upgraded to a canonical **linear isomorphism** `(ker d / range e) ≃ₗ ker Δ`
  (`hodgeCohomologyEquiv`): every cohomology class contains *exactly one* harmonic representative.
  This is split into existence (`harmonic_representative_exists`: every closed cochain is exact plus
  harmonic) and uniqueness (`harmonic_representative_unique`, from `harmonic_inf_exact_eq_bot`:
  harmonic ∩ exact `= 0`). The two combine, inside the ambient module `↥(ker d)`, into the
  complementarity `hodge_isCompl`, which `Submodule.quotientEquivOfIsCompl` turns into the explicit
  equivalence.

The unifying picture is now sharp: message passing is a deformation retraction onto the harmonic
core; the harmonic core *is* the cohomology — not merely equidimensional with it, but canonically
isomorphic — and the cochain space splits orthogonally into exact, coexact, and harmonic channels.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `orthogonal_ker_d_eq_range_adjoint_d` | ThreeWay | `(ker d)ᗮ = range d*` |
| `closed_eq_exact_sup_harmonic` | ThreeWay | `range e ⊔ ker Δ = ker d` |
| `hodge_three_way_span` | ThreeWay | `range d* ⊔ range e ⊔ ker Δ = ⊤` |
| `hodge_three_way_finrank` | ThreeWay | `dim range d* + dim range e + dim ker Δ = dim V` |
| `harmonic_inf_exact_eq_bot` | Isomorphism | `ker Δ ⊓ range e = ⊥` |
| `harmonic_representative_exists` | Isomorphism | every closed cochain `= e u + h`, `h` harmonic |
| `harmonic_representative_unique` | Isomorphism | one harmonic representative per class |
| `hodge_isCompl` | Isomorphism | `range e`, `ker Δ` complementary inside `ker d` |
| `hodgeCohomologyEquiv` | Isomorphism | **Hodge isomorphism** `(ker d / range e) ≃ₗ ker Δ` |

All proofs depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. The Hodge isomorphism is an isometry for the quotient norm
`hodgeCohomologyEquiv` is currently a *linear* equivalence `(ker d / range e) ≃ₗ ker Δ`. Conjecture:
it is in fact an **isometry**, i.e. the harmonic representative is the unique minimal-norm element of
its cohomology class, and `‖[x]‖ = ‖P x‖` where `P` is the orthogonal projection onto `ker Δ`.
Falsifiable: any closed cochain whose harmonic part has strictly larger norm than some other class
representative would refute it. **The key insight is** that `harmonic_representative_exists` writes
`x = e u + h` with `h ⊥ e u` (because `harmonic_le_orthogonal_range_e` gives `h ⊥ range e`), so
Pythagoras yields `‖x‖² = ‖e u‖² + ‖h‖² ≥ ‖h‖²` with equality iff `e u = 0`; hence the harmonic
representative is the norm-minimizer and the class norm equals `‖h‖`. **Why now?** Both halves are
theorems already: `harmonic_inf_exact_eq_bot` for uniqueness of the minimizer and
`harmonic_le_orthogonal_range_e` for the orthogonality that powers Pythagoras, so only the quotient
`Submodule.norm_mk`/`norm_quotient` comparison remains.

### 2. The harmonic projector as an idempotent on the cochain space
The three-way split `hodge_three_way_span` + `hodge_three_way_finrank` makes `ker Δ` an orthogonal
direct summand of `V`. Conjecture: the orthogonal projection `P : V →ₗ V` onto `ker Δ` satisfies
`P ∘ P = P`, `range P = ker Δ`, `ker P = range d* ⊔ range e`, and `P` commutes with `Δ`
(`P ∘ Δ = Δ ∘ P = 0`). Falsifiable by exhibiting a cochain `x` with `P (P x) ≠ P x` or
`P (Δ x) ≠ 0`. **The key insight is** that `closed_eq_exact_sup_harmonic` together with
`harmonic_le_orthogonal_range_e` identifies `ker Δ` as the orthogonal complement of
`range d* ⊔ range e` inside `V`, so `P = Submodule.orthogonalProjection (ker Δ)` and the idempotency
plus kernel description follow from `Submodule.orthogonalProjection` API on the proven decomposition.
**Why now?** `hodge_three_way_span` gives the spanning and `harmonic_le_orthogonal_range_adjoint_d`
/ `harmonic_le_orthogonal_range_e` give that the complement is exactly the other two summands, so the
projector is pinned down with no new geometry.

### 3. Euler characteristic as a telescoping alternating sum of harmonic dimensions
For a finite cochain complex `0 → V₀ → V₁ → … → Vₙ → 0`, conjecture the discrete **Hodge–Euler
theorem**: `Σ (−1)ᵏ dim(ker Δₖ) = Σ (−1)ᵏ dim Vₖ`, identifying the analytic Euler characteristic
(alternating sum of Betti numbers) with the combinatorial one. Falsifiable by any finite complex whose
harmonic Euler sum differs from its space Euler sum. **The key insight is** that the per-degree
identity `dim(ker Δₖ) = dim ker dₖ − rank eₖ` (a direct corollary of `hodge_betti`) combined with
rank–nullity `rank dₖ + dim ker dₖ = dim Vₖ` makes the consecutive `rank` terms cancel in pairs once
summed with alternating signs (the boundary identification `eₖ = dₖ₊₁` shares each rank between two
degrees). **Why now?** `hodge_betti` supplies every per-degree input, so the global statement is a
finite alternating-sum induction over `Finset.range n` using only `Module.finrank` arithmetic already
in Mathlib — no further analysis.

### 4. Message passing converges to the harmonic projector at the spectral-gap rate
Conjecture: for an admissible step `0 < α < 2/λ_max` the iterate `(id − αΔ)^[k]` converges to the
projector `P` of Direction 2, with `‖(id − αΔ)^[k] x − P x‖ ≤ ρᵏ ‖x − P x‖` for
`ρ = max|1 − αλ|` over nonzero Hodge eigenvalues `λ`. Falsifiable by a complex with an eigenvalue
outside `(0, 2/α)` that fails to contract. **The key insight is** that the three-way decomposition
(Direction 2) makes `ker Δ` and its complement simultaneously `Δ`-invariant; on the harmonic block
`Δ = 0` so the iterate is fixed, while on the complement the self-adjoint `Δ` (it is symmetric by the
`hodgeLap_quadform` energy split) has strictly positive eigenvalues, giving geometric contraction
with the stated `ρ`. **Why now?** With `P` available from Direction 2 and the finite-dimensional
spectral theorem for the symmetric `Δ`, the limit assembles from `id = P + (id − P)`, and the tight
logarithmic clock `hodgeDepth_tight` (previous cycle) already pins the exact rate.

### 5. Functoriality: chain maps induce maps on harmonic spaces
Conjecture: a morphism of two-step complexes (a commuting ladder of linear maps between
`U --e--> V --d--> W` and `U' --e'--> V' --d'--> W'`) induces a well-defined linear map on harmonic
spaces `ker Δ → ker Δ'` that agrees, under `hodgeCohomologyEquiv`, with the induced map on cohomology.
Falsifiable by a chain map whose harmonic-space map fails to commute with the cohomology map through
the isomorphism. **The key insight is** that `hodgeCohomologyEquiv` is *canonical* (built from
orthogonal complementation, not a choice of basis), so naturality reduces to checking that the middle
map sends closed cochains to closed cochains and exact to exact — exactly the two squares of the
ladder — after which `Submodule.mapQ` provides the induced cohomology map and the equivalence
transports it. **Why now?** The isomorphism is now a concrete `LinearEquiv` rather than a dimension
count, so `LinearMap.mapQ`/`Submodule.mapQ` can be composed with it directly, making functoriality a
diagram chase over already-proven complementarity rather than a fresh construction.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/MirrorSymmetry/CalabiYauFourfold.lean
/-
  Calabi–Yau fourfold Hodge diamonds and the mirror involution.

  This file EXTENDS the combinatorial mirror-symmetry skeleton of
  `Geometry.MirrorSymmetry.ArithmeticMirror` (the `eulerChar` / `mirror`
  machinery and the threefold relation `χ(mirror Y) = -χ(X)`) from threefolds
  to **fourfolds** (complex dimension `n = 4`), realizing research direction #5
  ("Higher-Dimensional Hodge Diamond Classification") of the arithmetic
  mirror-symmetry program.

  A smooth Calabi–Yau fourfold `X` has a Hodge diamond fully determined, after
  the symmetries

    * Hodge symmetry        `h^{p,q} = h^{q,p}`,
    * Serre duality         `h^{p,q} = h^{n-p,n-q}`,
    * Calabi–Yau vanishing  `h^{p,0} = 0` for `0 < p < n`, `h^{0,0} = h^{n,0} = 1`,

  by the **four** independent Hodge numbers `h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}`.
  We package these into `CY4`, build the full `ℕ → ℕ → ℤ` diamond, and prove:

    * `CY4.eulerChar_eq` — the topological Euler characteristic of the diamond is
      the explicit linear form `χ = 4 + 2 h¹¹ + 2 h³¹ + h²² − 4 h²¹`
      (this is unconditional combinatorics, *not* the Chern relation);
    * `CY4.mirror_diamond_eq` — the catalog mirror reflection `p ↦ n − p`
      (`ArithmeticMirror.mirror 4`) agrees on the support `p, q ≤ 4` with the
      diamond of the `CY4` whose `h¹¹` and `h³¹` are *swapped*: mirror symmetry
      exchanges `h^{1,1} ↔ h^{3,1}` while fixing `h^{2,1}` and `h^{2,2}`;
    * `CY4.swap_involutive` — that exchange is an involution (a `ℤ/2`-action);
    * `CY4.eulerChar_swap_invariant` / `CY4.eulerChar_mirror_invariant` — for the
      *even* dimension `4`, `χ(mirror X) = χ(X)` (contrast the threefold sign flip
      `ArithmeticMirror.eulerChar_mirror_threefold`), recovered as the `(-1)^4 = 1`
      shadow of the catalog theorem `ArithmeticMirror.eulerChar_mirror`;
    * `CY4.eulerChar_KLRY` — under the Klemm–Lian–Roan–Yau Chern-class relation
      `h²² = 2(22 + 2h¹¹ + 2h³¹ − h²¹)` the Euler characteristic collapses to the
      celebrated F-theory formula `χ = 6(8 + h¹¹ + h³¹ − h²¹)`.

  Everything is exact integer combinatorics over the catalog `eulerChar`.
-/
import Mathlib
import Geometry.MirrorSymmetry.ArithmeticMirror

open Finset

namespace CY4Fold

-- !-- Lab Notebook -- !--
-- Hypothesis: the n=4 Calabi–Yau Hodge diamond, after Hodge symmetry + Serre
-- duality + CY vanishing, has exactly 4 free numbers (h11,h21,h31,h22), its
-- Euler characteristic is a fixed linear form in them, and the catalog mirror
-- reflection p ↦ 4−p realizes the F-theory exchange h11 ↔ h31.
-- Result: all six facts proved (`eulerChar_eq`, `mirror_diamond_eq`,
-- `swap_involutive`, `eulerChar_swap_invariant`, `eulerChar_mirror_invariant`,
-- `eulerChar_KLRY`).
-- Insight: the *parity of the dimension* is the whole story — n=4 is even so the
-- catalog sign (-1)^n is +1, flipping the threefold χ ↦ −χ into χ ↦ χ; and the
-- KLRY Chern relation is precisely the affine substitution turning the bare
-- combinatorial form 4+2h11+2h31+h22−4h21 into 6(8+h11+h31−h21).
-- Failure analysis: defining the diamond by a `match` means the reflection
-- `mirror 4` only matches the swapped diamond on the support p,q ≤ 4 (outside,
-- ℕ-truncation of 4−p makes them disagree), so the exchange is stated pointwise
-- on the support, exactly as in the catalog `mirror_mirror_h`.

/-- The four independent Hodge numbers of a Calabi–Yau fourfold:
`h^{1,1}` (Kähler moduli), `h^{2,1}`, `h^{3,1}` (complex-structure moduli) and the
middle number `h^{2,2}`. -/
structure CY4 where
  /-- `h^{1,1}`: the Kähler / divisor moduli. -/
  h11 : ℤ
  /-- `h^{2,1}`. -/
  h21 : ℤ
  /-- `h^{3,1}`: the complex-structure moduli. -/
  h31 : ℤ
  /-- `h^{2,2}`: the middle Hodge number. -/
  h22 : ℤ

/-- The full Hodge diamond `h^{p,q}` of a Calabi–Yau fourfold, as a function on
`ℕ × ℕ`, built from the four free numbers via Hodge symmetry, Serre duality and
the Calabi–Yau vanishing conditions. Only the values with `p, q ≤ 4` are
meaningful; the rest are padding `0`. -/
def CY4.diamond (X : CY4) : ℕ → ℕ → ℤ := fun p q =>
  match p, q with
  | 0, 0 => 1
  | 4, 4 => 1
  | 0, 4 => 1
  | 4, 0 => 1
  | 1, 1 => X.h11
  | 3, 3 => X.h11
  | 3, 1 => X.h31
  | 1, 3 => X.h31
  | 2, 2 => X.h22
  | 2, 1 => X.h21
  | 1, 2 => X.h21
  | 2, 3 => X.h21
  | 3, 2 => X.h21
  | _, _ => 0

/-- The **mirror exchange** on free Hodge data: swap `h^{1,1} ↔ h^{3,1}`, fixing
`h^{2,1}` and `h^{2,2}`. This is the F-theory mirror map at the level of the four
moduli numbers. -/
def CY4.swap (X : CY4) : CY4 where
  h11 := X.h31
  h21 := X.h21
  h31 := X.h11
  h22 := X.h22

-- !-- comment -- !--
-- Expand the 5×5 alternating double sum (`Finset.sum_range_succ`), reduce each
-- literal `diamond p q` by the `match`, and collect terms with `ring`.
-- !-- comment -- !--
/-- **Euler characteristic of a CY fourfold diamond.** The topological Euler
characteristic (the catalog `ArithmeticMirror.eulerChar` at `n = 4`) is the
explicit linear form `χ = 4 + 2 h¹¹ + 2 h³¹ + h²² − 4 h²¹`. This is pure
combinatorics of the diamond — no Chern-class input. -/
theorem CY4.eulerChar_eq (X : CY4) :
    ArithmeticMirror.eulerChar 4 X.diamond
      = 4 + 2 * X.h11 + 2 * X.h31 + X.h22 - 4 * X.h21 := by
  unfold ArithmeticMirror.eulerChar CY4.diamond
  norm_num [Finset.sum_range_succ]
  ring

-- !-- comment -- !--
-- Both sides are 0 off the support and, for each of the ≤25 index pairs with
-- p,q ≤ 4, `mirror 4 X.diamond p q = X.diamond (4-p) q` reduces by the `match`
-- to the corresponding entry of the swapped diamond.
-- !-- comment -- !--
/-- **Mirror exchanges `h^{1,1}` and `h^{3,1}`.** On the support `p, q ≤ 4` the
catalog mirror reflection `ArithmeticMirror.mirror 4` of the diamond coincides
with the diamond of the swapped data `X.swap`. This is the F-theory mirror map
`h^{1,1} ↔ h^{3,1}` (with `h^{2,1}, h^{2,2}` fixed). -/
theorem CY4.mirror_diamond_eq (X : CY4) {p q : ℕ} (hp : p ≤ 4) (hq : q ≤ 4) :
    ArithmeticMirror.mirror 4 X.diamond p q = X.swap.diamond p q := by
  interval_cases p <;> interval_cases q <;> rfl

-- !-- comment -- !--
-- Swapping h11 and h31 twice returns the original; the other two fields are
-- untouched: `cases X` then `rfl`.
-- !-- comment -- !--
/-- **The mirror exchange is an involution** (a `ℤ/2`-action on CY-fourfold
Hodge data). -/
theorem CY4.swap_involutive (X : CY4) : X.swap.swap = X := by
  cases X; rfl

-- !-- comment -- !--
-- `eulerChar_eq` is symmetric in h11 and h31, and `swap` exchanges exactly those
-- two, so the Euler characteristic is unchanged.
-- !-- comment -- !--
/-- **Euler characteristic is mirror-invariant for fourfolds.** Because `4` is
even, the catalog sign `(-1)^4 = 1`, so unlike the threefold case
(`ArithmeticMirror.eulerChar_mirror_threefold`, `χ ↦ -χ`) the mirror preserves
the Euler characteristic. Equivalently, `eulerChar_eq` is symmetric under the
`h^{1,1} ↔ h^{3,1}` swap. -/
theorem CY4.eulerChar_swap_invariant (X : CY4) :
    ArithmeticMirror.eulerChar 4 X.swap.diamond
      = ArithmeticMirror.eulerChar 4 X.diamond := by
  rw [CY4.eulerChar_eq, CY4.eulerChar_eq]
  simp only [CY4.swap]
  ring

-- !-- comment -- !--
-- Direct corollary of the catalog `eulerChar_mirror` at n = 4: the prefactor is
-- (-1)^4 = 1.
-- !-- comment -- !--
/-- **Catalog form of fourfold mirror invariance.** Specializing
`ArithmeticMirror.eulerChar_mirror` to `n = 4`: reflecting the first Hodge index
fixes the Euler characteristic, since `(-1)^4 = 1`. -/
theorem CY4.eulerChar_mirror_invariant (h : ℕ → ℕ → ℤ) :
    ArithmeticMirror.eulerChar 4 (ArithmeticMirror.mirror 4 h)
      = ArithmeticMirror.eulerChar 4 h := by
  rw [ArithmeticMirror.eulerChar_mirror]
  norm_num

-- !-- comment -- !--
-- Substitute the KLRY value of h22 into `eulerChar_eq` and simplify with `ring`.
-- !-- comment -- !--
/-- **Klemm–Lian–Roan–Yau / F-theory Euler formula.** Under the Chern-class
relation `h²² = 2(22 + 2h¹¹ + 2h³¹ − h²¹)` (the geometric 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Hodge–Laplacian Message Passing, Fifth Cycle

## Synthesis

This cycle did two things. First, it **repaired and re-established the foundation** of the
discrete Hodge program: the file `Speculative/AutoResearch/HodgeBettiRank.lean` — on which both
`HodgeThreeWayDecomposition.lean` and `HodgeIsomorphism.lean` depend — was absent, so the entire
Hodge stack failed to elaborate. It is now reconstructed and proven sorry-free, exporting the four
load-bearing facts of the theory: the Hodge Laplacian `Δ = d* d + e e*` (`hodgeLap`), the
image/cokernel duality `ker f* = (range f)ᗮ` (`ker_adjoint_eq_orthogonal_range`), the harmonic
characterization `ker Δ = ker d ⊓ ker e*` (`hodgeLap_ker`), the chain inclusion
`range e ≤ ker d` (`range_e_le_ker_d`), and the Hodge–Betti dimension count
`dim (ker Δ) + dim (range e) = dim (ker d)` (`hodge_betti`).

Second, building directly on that foundation and on the three-way splitting, it promoted the
*static* harmonic decomposition into the *operator and variational* statements of the fourth-cycle
program (Research Directions 1 and 2) in the new file
`Speculative/AutoResearch/HodgeHarmonicProjector.lean`:

* **Self-adjointness.** `Δ* = Δ` (`hodgeLap_isSelfAdjoint`), the algebraic backbone of the whole
  spectral picture, reduced to `adjoint_comp` + `adjoint_adjoint`.
* **Pythagoras + minimal norm (Direction 1).** A harmonic cochain is orthogonal to every exact
  cochain, so `‖h + e u‖² = ‖h‖² + ‖e u‖²` (`harmonic_exact_norm_add_sq`); consequently the
  harmonic representative is the *shortest* element of its cohomology class — `‖h‖ ≤ ‖y‖` for every
  cohomologous `y` (`harmonic_representative_norm_minimal`). This upgrades the *uniqueness* of the
  harmonic representative (`HodgeIsomorphism.harmonic_representative_unique`) to a genuine
  *variational* minimization.
* **The harmonic projector (Direction 2).** Writing `P = (ker Δ).starProjection`, the projector
  kills exact cochains (`harmonicProjection_exact_eq_zero`), is idempotent
  (`harmonicProjection_idempotent`), and on a *closed* cochain returns precisely the harmonic
  representative: `P (e u + h) = h` (`harmonicProjection_closed`). This is the operator that
  realizes the Hodge isomorphism `ker Δ ≅ ker d / range e`.

The unifying picture is now operator-theoretic: the Hodge Laplacian is self-adjoint, its kernel is
the harmonic core, the orthogonal projector onto that core *is* the cohomology projector, and the
harmonic representative it selects is the unique norm-minimizer of its class.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `ker_adjoint_eq_orthogonal_range` | HodgeBettiRank | `ker f* = (range f)ᗮ` |
| `hodgeLap_ker` | HodgeBettiRank | `ker Δ = ker d ⊓ ker e*` |
| `range_e_le_ker_d` | HodgeBettiRank | `range e ≤ ker d` |
| `hodge_betti` | HodgeBettiRank | `dim (ker Δ) + dim (range e) = dim (ker d)` |
| `hodgeLap_isSelfAdjoint` | HodgeHarmonicProjector | `Δ* = Δ` |
| `harmonic_exact_norm_add_sq` | HodgeHarmonicProj
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
