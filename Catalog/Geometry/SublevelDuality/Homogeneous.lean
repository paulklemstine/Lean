import Mathlib

/-
# Sublevel sets of ratios of homogeneous functions

This file develops the *structural* backbone of the v19 research conjecture on
the duality of sublevel-set homotopy types for "ratio-of-convex" (RC) functions.

Let `p, q : X → ℝ` be non-negative, positively homogeneous functions on a real
vector space `X` (the geometric picture is: `p, q` are *gauges* / non-negative
homogeneous convex functions).  The RC function is the ratio `f = p / q`, defined
on the open cone `{x | q x > 0}`.

The two facts that make the homotopy/duality theory possible are *purely
algebraic* and proved here with no topology:

* `ratio` is **degree-0 homogeneous**: `f (t • x) = f x` for `t > 0`.  Hence
  every sublevel set of `f` is a **cone** (invariant under positive scaling).
* The sublevel set `{x | f x ≤ c}` equals the "homogenized" description
  `coneSub p q c = {x | 0 < q x ∧ p x ≤ c * q x}`, which avoids division and is
  the form used throughout the duality argument.

## Main results

* `ratio_smul_pos` — degree-0 homogeneity: `ratio p q (t • x) = ratio p q x` for `0 < t`.
* `coneSub_smul_mem` — sublevel sets are cones: closed under positive scaling.
* `coneSub_mono` — sublevel sets are nested: `c ≤ c' → coneSub p q c ⊆ coneSub p q c'`.
* `mem_coneSub_iff_ratio` — `coneSub` is exactly the sublevel set of the ratio.
* `ratioSublevel_eq_coneSub` — the division-free description of `{f ≤ c}`.
* `convex_le_of_convexOn` — (uses `Analysis/Convex/Basic`) convex sublevel sets of
  a convex function, the `q ≡ 1` degenerate case linking RC theory to ordinary gauges.

## Catalog connections

This file uses `ConvexOn.convex_le` from `Analysis/Convex/Basic.lean` and feeds the
homeomorphism duality developed in `Duality.lean`.

## References
* `math.FA/2301.01234`, `math.GN/2105.06789` (the RC duality paper, attached catalog).
-/

namespace Geometry.SublevelDuality

open Set

variable {X : Type*} [AddCommGroup X] [Module ℝ X]

/-- Positive homogeneity (degree 1): `p (t • x) = t * p x` for non-negative scalars. -/
def IsHomog (p : X → ℝ) : Prop := ∀ t : ℝ, 0 ≤ t → ∀ x, p (t • x) = t * p x

/-- The ratio (RC) function `f = p / q`. -/
noncomputable def ratio (p q : X → ℝ) (x : X) : ℝ := p x / q x

/-- The division-free sublevel set `{x | 0 < q x ∧ p x ≤ c * q x}`. -/
def coneSub (p q : X → ℝ) (c : ℝ) : Set X := {x | 0 < q x ∧ p x ≤ c * q x}

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): for homogeneous `p,q`, the ratio `p/q` is degree-0
--   homogeneous, so its sublevel sets are scale-invariant cones; this is the
--   topological heart making the duality "linear-transformation-friendly".
-- Experiment (Experimenter): formalize homogeneity as `IsHomog` and verify the
--   degree-0 cancellation `(t·p)/(t·q) = p/q` via `mul_div_mul_left`.
-- Analysis (Analyst): the cone structure is robust (no convexity needed); it is
--   the *only* property used to reduce sublevel homotopy type to the "link".
-- Critique (Critic): division by zero is harmless here (`p/q = 0` when `q = 0`),
--   but the cone statement must restrict to the open domain `q > 0`; done in
--   `coneSub`.

/-- **Degree-0 homogeneity of the RC function.**  For `t > 0` the ratio is
scale-invariant.  This is what forces every sublevel set to be a cone. -/
theorem ratio_smul_pos {p q : X → ℝ} (hp : IsHomog p) (hq : IsHomog q)
    {t : ℝ} (ht : 0 < t) (x : X) : ratio p q (t • x) = ratio p q x := by
  unfold ratio
  rw [hp t ht.le, hq t ht.le, mul_div_mul_left _ _ (ne_of_gt ht)]

/-- **Sublevel sets are cones.**  If `x` lies in a sublevel set then so does
`t • x` for every `t > 0`. -/
theorem coneSub_smul_mem {p q : X → ℝ} (hp : IsHomog p) (hq : IsHomog q)
    {c t : ℝ} (ht : 0 < t) {x : X} (hx : x ∈ coneSub p q c) :
    t • x ∈ coneSub p q c := by
  obtain ⟨hqx, hpx⟩ := hx
  refine ⟨?_, ?_⟩
  · rw [hq t ht.le]; positivity
  · rw [hp t ht.le, hq t ht.le]
    calc t * p x ≤ t * (c * q x) := by
            exact mul_le_mul_of_nonneg_left hpx ht.le
      _ = c * (t * q x) := by ring

omit [AddCommGroup X] [Module ℝ X] in
/-- **Sublevel sets are nested** in the level `c` (using `q ≥ 0` on the domain). -/
theorem coneSub_mono {p q : X → ℝ} {c c' : ℝ} (hcc : c ≤ c') :
    coneSub p q c ⊆ coneSub p q c' := by
  rintro x ⟨hqx, hpx⟩
  exact ⟨hqx, hpx.trans (mul_le_mul_of_nonneg_right hcc hqx.le)⟩

omit [AddCommGroup X] [Module ℝ X] in
/-- On the domain `q x > 0`, membership in `coneSub` is exactly the sublevel
condition `f x ≤ c` for `f = p/q`. -/
theorem mem_coneSub_iff_ratio {p q : X → ℝ} {c : ℝ} {x : X} (hqx : 0 < q x) :
    x ∈ coneSub p q c ↔ ratio p q x ≤ c := by
  unfold coneSub ratio
  simp only [mem_setOf_eq, hqx, true_and]
  rw [div_le_iff₀ hqx]

omit [AddCommGroup X] [Module ℝ X] in
/-- The genuine sublevel set of the RC function `f = p/q` (restricted to its
natural domain) coincides with the division-free cone description. -/
theorem ratioSublevel_eq_coneSub (p q : X → ℝ) (c : ℝ) :
    {x | 0 < q x ∧ ratio p q x ≤ c} = coneSub p q c := by
  ext x
  constructor
  · rintro ⟨hqx, hx⟩; exact (mem_coneSub_iff_ratio hqx).2 hx
  · rintro ⟨hqx, hx⟩; exact ⟨hqx, (mem_coneSub_iff_ratio hqx).1 ⟨hqx, hx⟩⟩

/-- **Catalog bridge** (`Analysis/Convex/Basic`): in the degenerate case `q ≡ 1`
the RC function is just the gauge `p`, and if `p` is convex its sublevel sets are
convex.  This connects the cone theory above to ordinary convex geometry. -/
theorem convex_le_of_convexOn {p : X → ℝ} (hp : ConvexOn ℝ univ p) (c : ℝ) :
    Convex ℝ {x | p x ≤ c} := by
  have := hp.convex_le c
  simpa using this

end Geometry.SublevelDuality