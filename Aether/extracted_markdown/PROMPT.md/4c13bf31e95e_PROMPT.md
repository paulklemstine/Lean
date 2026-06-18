
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
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: Close Proofs: Stereographic Capacity Theory: Packing Bounds on Spheres via Plane Geo
**Domain**: Applications
**Mathematical framing**: Cycle 720cb173 (Q=0.438) proved 910 theorems in Geometry but left 4 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Sphere packing on S^n (how many non-overlapping caps of radius r fit?) is a fundamental geometric problem with applications to error-correcting codes and signal processing. Use stereographic projectio
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/StereographicCapacity/Theorems.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Stereographic Capacity Theory: Main Theorems

This file extends the definitions of `Geometry.StereographicCapacity.Defs`
(`stereoFactor`, `stereoExclusionRadius`, `StereoSeparated`, `sphereArea`,
`sphericalCapArea`, `SphericalPackingBound`, `stereoBoundS2`,
`stereoBoundS2Closed`) with proven theorems on sphere packing.

The headline results:

1. **Conformal factor bounds** (`stereoFactor_pos`, `stereoFactor_le_two`,
   `stereoFactor_eq_two_iff`): the stereographic scale factor is a strictly
   positive quantity, bounded above by `2`, attaining `2` exactly at the origin.

2. **Exclusion-radius closed form** (`stereoExclusionRadius_eq`): the weighted
   Euclidean exclusion radius is `tan r · (1 + ‖x‖²)/2`.

3. **Closed form of the S² distortion bound** (`stereoBoundS2_eq_closed`):
   `stereoBoundS2 r = 8 / (cos²r · (1 - cos r))`.

4. **Trivial packing bound** (`spherePacking_card_le_one`,
   `sphericalPackingBound_one_of_one_lt`): a geodesic radius `r > 1` forces
   any `2r`-separated set on `Sⁿ` to be a singleton, since the sphere has
   diameter `2`. Plus monotonicity (`sphericalPackingBound_mono`).
-/
import Mathlib
import Geometry.StereographicCapacity.Defs

open Real Finset

namespace StereographicCapacity

/-! ## Conformal factor bounds -/

-- !-- The numerator `2 > 0` and denominator `1 + ‖x‖² ≥ 1 > 0`, so the quotient is positive. -- !--
theorem stereoFactor_pos {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    0 < stereoFactor x :=
  div_pos zero_lt_two (by positivity)

-- !-- Since `1 + ‖x‖² ≥ 1`, dividing `2` by it can only shrink it: `2/(1+‖x‖²) ≤ 2`. -- !--
theorem stereoFactor_le_two {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    stereoFactor x ≤ 2 :=
  div_le_self zero_le_two (by nlinarith [sq_nonneg ‖x‖])

-- !-- `2/(1+‖x‖²) = 2` forces `‖x‖² = 0`, hence `‖x‖ = 0`, hence `x = 0`; conversely trivial. -- !--
theorem stereoFactor_eq_two_iff {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    stereoFactor x = 2 ↔ x = 0 := by
  unfold stereoFactor
  norm_num [div_eq_iff, add_eq_zero_iff_of_nonneg, sq_nonneg]

/-! ## Exclusion radius closed form -/

-- !-- Dividing `tan r` by the conformal factor `2/(1+‖x‖²)` multiplies by its reciprocal. -- !--
theorem stereoExclusionRadius_eq {n : ℕ} (r : ℝ) (x : EuclideanSpace ℝ (Fin n)) :
    stereoExclusionRadius r x = Real.tan r * (1 + ‖x‖ ^ 2) / 2 := by
  have h : (1 + ‖x‖ ^ 2) ≠ 0 := by positivity
  unfold stereoExclusionRadius stereoFactor
  field_simp

/-! ## Closed form of the S² distortion bound -/

-- !-- Substitute `sphereArea 2 = 4π`, `sphericalCapArea r = 2π(1-cos r)`, then clear denominators
-- with `π ≠ 0`, `cos r ≠ 0`, `1 - cos r ≠ 0`. -- !--
theorem stereoBoundS2_eq_closed (r : ℝ) (hcos : Real.cos r ≠ 0)
    (hcos1 : Real.cos r ≠ 1) :
    stereoBoundS2 r = stereoBoundS2Closed r := by
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  have h1 : 1 - Real.cos r ≠ 0 := sub_ne_zero.mpr (Ne.symm hcos1)
  unfold stereoBoundS2 stereoBoundS2Closed sphereArea sphericalCapArea
  field_simp
  ring

/-! ## Trivial packing bound for large radius -/

-- !-- Two distinct points on the unit sphere have distance `≤ ‖x‖ + ‖y‖ = 2`, contradicting
-- `2r ≤ dist` when `r > 1`; hence the separated set has at most one point. -- !--
theorem spherePacking_card_le_one {n : ℕ} {r : ℝ} (hr : 1 < r)
    (s : Finset (Metric.sphere (0 : EuclideanSpace ℝ (Fin (n + 1))) 1))
    (hsep : ∀ ⦃x y⦄, x ∈ s → y ∈ s →
      (x : EuclideanSpace ℝ (Fin (n + 1))) ≠ y →
      2 * r ≤ dist (x : EuclideanSpace ℝ (Fin (n + 1)))
        (y : EuclideanSpace ℝ (Fin (n + 1)))) :
    s.card ≤ 1 := by
  apply Finset.card_le_one.mpr
  intro a ha b hb
  by_contra hab
  have hcoe : (a : EuclideanSpace ℝ (Fin (n + 1))) ≠ b := fun h => hab (Subtype.ext h)
  have hkey : 2 * r ≤ dist (a : EuclideanSpace ℝ (Fin (n + 1))) b := hsep ha hb hcoe
  have hna : ‖(a : EuclideanSpace ℝ (Fin (n + 1)))‖ = 1 := by simp
  have hnb : ‖(b : EuclideanSpace ℝ (Fin (n + 1)))‖ = 1 := by simp
  rw [dist_eq_norm] at hkey
  have hle : ‖(a : EuclideanSpace ℝ (Fin (n + 1))) - b‖ ≤ 2 := by
    calc ‖(a : EuclideanSpace ℝ (Fin (n + 1))) - b‖
        ≤ ‖(a : EuclideanSpace ℝ (Fin (n + 1)))‖ + ‖(b : EuclideanSpace ℝ (Fin (n + 1)))‖ :=
          norm_sub_le _ _
      _ = 2 := by rw [hna, hnb]; norm_num
  linarith

-- !-- Immediate from `spherePacking_card_le_one` since `⌈(1:ℝ)⌉₊ = 1`. -- !--
theorem sphericalPackingBound_one_of_one_lt (n : ℕ) {r : ℝ} (hr : 1 < r) :
    SphericalPackingBound n r 1 := by
  intro s hs
  exact le_trans (spherePacking_card_le_one hr s hs) (by norm_num)

-- !-- Larger budgets give weaker (larger) ceilings, so the bound is preserved upward. -- !--
theorem sphericalPackingBound_mono (n : ℕ) (r : ℝ) {B B' : ℝ} (hB : B ≤ B')
    (h : SphericalPackingBound n r B) : SphericalPackingBound n r B' :=
  fun s hs => le_trans (h s hs) (Nat.ceil_mono hB)

end StereographicCapacity



-- NEW_FILE: Catalog/MachineLearning/Other/UnityIsomorphism.lean
import Mathlib

/-! # CatalogBuild.Speculative.Other.UnityIsomorphism

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15
-/

noncomputable section

/-- In any category, terminal objects are isomorphic.
This is the formal backbone of "1 ≅ Universe" — both are terminal objects
in their respective categories, and terminal objects are unique. -/
theorem terminal_objects_isomorphic {C : Type*} [Category C]
    (T₁ T₂ : C) (hT₁ : IsTerminal T₁) (hT₂ : IsTerminal T₂) :
    Nonempty (T₁ ≅ T₂) :=
  ⟨hT₁.uniqueUpToIso hT₂⟩

/-- The number 1 is the multiplicative identity: 1 * x = x for all x.
This is the algebraic face of the unity isomorphism. -/
theorem one_mul_identity (R : Type*) [Monoid R] (x : R) : 1 * x = x :=
  one_mul x

/-- The number 1 is also a right identity: x * 1 = x for all x. -/
theorem mul_one_identity (R : Type*) [Monoid R] (x : R) : x * 1 = x :=
  mul_one x

/-- In a monoid, the identity element is unique. Just as the universe
is the unique "context" for physical law, 1 is the unique identity. -/
theorem identity_unique (M : Type*) [Monoid M] (e : M)
    (h_left : ∀ x, e * x = x) : e = 1 := by
  have := h_left 1
  rw [mul_one] at this
  exact this

/-- log(1) = 0: The number 1 carries zero information.
Just as a universe with no alternatives carries zero entropy. -/
theorem log_unity_zero : Real.log 1 = 0 := Real.log_one

/-- For any base b, log_b(1) = 0. Unity is zero-information
regardless of how you measure it. -/
theorem logb_unity_zero (b : ℝ) : Real.logb b 1 = 0 :=
  Real.logb_one

/-- Any map to PUnit is unique — the terminal property in Top. -/
theorem map_to_unit_unique {α : Type*} (f g : α → PUnit) : f = g := by
  funext x; exact Subsingleton.elim _ _

/-- A mathematical prediction framework.
A prediction is a mathematical structure M together with
a physical interpretation function that maps M to observable predictions. -/
structure MathPrediction where
  /-- The mathematical structure (e.g., a symmetry group) -/
  math_structure : Type*
  /-- The set of physical observables it predicts -/
  predictions : Type*
  /-- The interpretation map: math → physics -/
  interpret : math_structure → predictions
  /-- Surjectivity: every prediction comes from the math -/
  surjective : Function.Surjective interpret

/-- Noether's theorem schema: every continuous symmetry implies a conservation law.
This is the archetype of mathematical prediction. -/
structure NoetherCorrespondence where
  /-- The symmetry group -/
  Symmetry : Type*
  /-- The space of conserved quantities -/
  ConservedQuantity : Type*
  /-- The correspondence: symmetry ↔ conservation -/
  correspondence : Symmetry ≃ ConservedQuantity

/-- Example: Time translation symmetry ↔ Energy conservation.
Both are ℝ (continuous, one-parameter). -/
def time_energy_noether : NoetherCorrespondence where
  Symmetry := ℝ
  ConservedQuantity := ℝ
  correspondence := Equiv.refl ℝ

/-- The predi
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Stereographic Capacity Theory

This cycle established the algebraic and geometric backbone of *stereographic
capacity theory* — the program of converting spherical cap-packing questions on
`Sⁿ` into weighted Euclidean separation problems on `ℝⁿ` via stereographic
projection. The proven results (`Geometry/StereographicCapacity/Theorems.lean`)
are:

- the conformal factor `λ(x) = 2/(1+‖x‖²)` is strictly positive, bounded by `2`,
  and attains `2` exactly at the origin (`stereoFactor_pos`,
  `stereoFactor_le_two`, `stereoFactor_eq_two_iff`);
- the weighted exclusion radius has the closed form
  `tan r · (1+‖x‖²)/2` (`stereoExclusionRadius_eq`);
- the `S²` distortion bound collapses to `8/(cos²r·(1−cos r))`
  (`stereoBoundS2_eq_closed`);
- a sharp degenerate packing bound: for geodesic radius `r > 1` every
  `2r`-separated subset of `Sⁿ` is a singleton (`spherePacking_card_le_one`,
  `sphericalPackingBound_one_of_one_lt`), together with monotonicity of the
  bound predicate in its budget (`sphericalPackingBound_mono`).

These connect to the catalog's broader stereographic toolkit — in particular the
inner-product transport formula of `StereographicPersistence` (`inner_stereoInvFun`,
`stereoDist_eq`) and the bi-Lipschitz comparison `stereoDist_biLipschitz_on_bounded`,
which is precisely the analytic bridge needed to make the conjectures below
rigorous. The directions below are stated to be testable and falsifiable: each can
be refuted by a single explicit configuration or numerical counterexample.

## Direction 1: The separation transport theorem

**Conjecture.** There is a constant regime in which `StereoSeparated r s`
(Euclidean weighted separation of the projected points) is *equivalent* to genuine
`2r`-geodesic separation on `Sⁿ` of their inverse stereographic images, with the
equivalence becoming exact as `r → 0`.

The key insight is that `stereoExclusionRadius_eq` writes the exclusion radius as
`tan r · (1+‖x‖²)/2 = tan r / λ(x)`, i.e. the *Euclidean* radius is exactly the
spherical radius rescaled by the local conformal factor — so a first-order
matching of `tan r` against geodesic chord length should turn the predicate
`StereoSeparated` into a faithful proxy for cap disjointness.

Why now? The catalog already contains `stereoDist_eq` (geodesic distance as
`arccos` of a closed-form inner product) and `stereoDist_biLipschitz_on_bounded`;
chaining `stereoExclusionRadius_eq` with these two gives an explicit two-sided
estimate, so the conjecture is reachable without building new transcendental
machinery.

## Direction 2: A genuine quantitative cap-packing upper bound on S²

**Conjecture.** For every `r` with `0 < r < π/2`, `SphericalPackingBound 2 r B`
holds with `B = stereoBoundS2Closed r = 8/(cos²r·(1−cos r))`; moreover this is the
best bound obtainable by the pure area/conformal-distortion method, off the true
packing number by at most a bounded multiplicative constant.

The key insight is that the volume (area) argument — t
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
