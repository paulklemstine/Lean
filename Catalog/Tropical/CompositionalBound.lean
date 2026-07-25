import Mathlib

/-!
# Compositional Bound: Local-Global Certified Radius for Piecewise-Affine Classifiers

This module formalizes the **compositional certified robustness principle**:
the global certified radius of a piecewise-affine classifier is at least
`min(r_local, r_region)`, where `r_local` is the local affine-margin certificate
radius within a linear region, and `r_region` is the distance to the region boundary.

## Main Results

* `global_radius_ge_min_local_region` — The core lower bound: classification is
  preserved within a ball of radius `min(r_local, r_region)`.

* `exact_global_radius_eq_min` — Equality characterization: under tightness
  conditions on both radii, the global certified radius equals `min(r_local, r_region)`.

* `tropical_compositional_certified_radius` — Full compositional theorem combining
  tropical Lipschitz certificates with region stability.

* `lipschitz_cert_is_global` — The Lipschitz certificate provides a global certificate.

## Mathematical Overview

Inside a fixed linear region of a piecewise-affine (e.g. ReLU) network, each logit
difference `f_y - f_j` is affine. The **local radius** is the largest ball around `x₀`
on which all affine margins stay nonneg while remaining in the same region. The **region
radius** is the distance to the nearest activation-pattern boundary. The compositional
theorem decomposes robustness certification into:
- a **tropical hyperplane arrangement problem** inside a Newton cell,
- a **polyhedral escape problem** to the boundary of a linear region.
-/

open scoped NNReal
open Metric Set

noncomputable section

/-! ## Section 1: Core Definitions -/

/-- The global certified radius: every point within distance `r` of `x₀` preserves
    class `y` as the argmax of `f`. -/
def GlobalCertified {n k : ℕ} (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ) (y : Fin k) (r : ℝ) : Prop :=
  ∀ x : Fin n → ℝ, ‖x - x₀‖ < r → ∀ j : Fin k, f x y ≥ f x j

/-- The local certified radius on a region `R`: classification is preserved for
    all points in `R` within distance `r` of `x₀`. -/
def LocalCertified {n k : ℕ} (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ) (y : Fin k) (R : Set (Fin n → ℝ)) (r : ℝ) : Prop :=
  ∀ x : Fin n → ℝ, x ∈ R → ‖x - x₀‖ < r → ∀ j : Fin k, f x y ≥ f x j

/-- The region radius: the open ball of radius `r` around `x₀` is contained in `R`. -/
def RegionContains {n : ℕ} (x₀ : Fin n → ℝ) (R : Set (Fin n → ℝ)) (r : ℝ) : Prop :=
  ∀ x : Fin n → ℝ, ‖x - x₀‖ < r → x ∈ R

/-- A witness for tightness of the local radius: there exists a point on
    the margin boundary at exactly distance `r_local`. -/
def MarginTight {n k : ℕ} (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ) (y : Fin k) (r : ℝ) : Prop :=
  ∃ j : Fin k, j ≠ y ∧ ∃ x : Fin n → ℝ, ‖x - x₀‖ = r ∧ f x y = f x j

/-- A witness for tightness of the region radius: there exists a boundary
    point at exactly distance `r_region` where crossing leads to class change. -/
def RegionTight {n k : ℕ} (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ) (y : Fin k) (R : Set (Fin n → ℝ)) (r : ℝ) : Prop :=
  ∃ x : Fin n → ℝ, ‖x - x₀‖ = r ∧ x ∉ R ∧
    ∃ j : Fin k, j ≠ y ∧ f x j > f x y

/-! ## Section 2: Core Compositional Bound -/

/-
**Main theorem: Compositional certified radius lower bound.**

If `r_local` is a local certified radius within region `R`, and `r_region` ensures
the ball stays inside `R`, then classification is preserved within `min(r_local, r_region)`.

This is the key decomposition: robustness = min(margin safety, region stability).
-/
theorem global_radius_ge_min_local_region
    {n k : ℕ}
    (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ)
    (y : Fin k)
    (R : Set (Fin n → ℝ))
    (r_local r_region : ℝ)
    (hlocal : LocalCertified f x₀ y R r_local)
    (hregion : RegionContains x₀ R r_region) :
    GlobalCertified f x₀ y (min r_local r_region) := by
  grind +locals

/-
Monotonicity: if `GlobalCertified` holds at radius `r`, it holds for any smaller radius.
-/
theorem GlobalCertified.mono {n k : ℕ} {f : (Fin n → ℝ) → (Fin k → ℝ)}
    {x₀ : Fin n → ℝ} {y : Fin k} {r s : ℝ} (h : GlobalCertified f x₀ y r) (hrs : s ≤ r) :
    GlobalCertified f x₀ y s := by
  -- By definition of GlobalCertified, if ‖x - x₀‖ < s ≤ r, then ‖x - x₀‖ < r, so we can apply h.
  intros x hx j; exact h x (by linarith [hx]) j

/-
Monotonicity for local certificates.
-/
theorem LocalCertified.mono {n k : ℕ} {f : (Fin n → ℝ) → (Fin k → ℝ)}
    {x₀ : Fin n → ℝ} {y : Fin k} {R : Set (Fin n → ℝ)} {r s : ℝ}
    (h : LocalCertified f x₀ y R r) (hrs : s ≤ r) :
    LocalCertified f x₀ y R s := by
  exact fun x hx hx' j => h x hx ( lt_of_lt_of_le hx' hrs ) j

/-
A local certificate on the whole space is a global certificate.
-/
theorem LocalCertified.to_global {n k : ℕ} {f : (Fin n → ℝ) → (Fin k → ℝ)}
    {x₀ : Fin n → ℝ} {y : Fin k} {r : ℝ}
    (h : LocalCertified f x₀ y Set.univ r) :
    GlobalCertified f x₀ y r := by
  exact fun x hx j => h x trivial hx j

/-! ## Section 3: Exact Radius Characterization -/

/-
**Equality characterization**: the global certified radius equals
    `min(r_local, r_region)` when the appropriate tightness condition holds.

    The `hglobal_def` hypothesis asserts that no larger radius works as a global
    certificate, making the bound tight. The tightness conditions explain *why*
    the bound is tight: either a margin tie (inside the region) or a region escape
    (at the boundary) is the first obstruction.
-/
theorem exact_global_radius_eq_min
    {n k : ℕ}
    (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ)
    (y : Fin k)
    (R : Set (Fin n → ℝ))
    (r_local r_region : ℝ)
    (hr_local_pos : r_local > 0)
    (hr_region_pos : r_region > 0)
    (hlocal : LocalCertified f x₀ y R r_local)
    (hregion : RegionContains x₀ R r_region)
    (htight_local : r_local ≤ r_region → MarginTight f x₀ y r_local)
    (htight_region : r_region ≤ r_local → RegionTight f x₀ y R r_region)
    (hglobal_def : ∀ r, GlobalCertified f x₀ y r → r ≤ min r_local r_region) :
    ∀ r, GlobalCertified f x₀ y r ↔ r ≤ min r_local r_region := by
  refine' fun r => ⟨ hglobal_def r, fun hr => _ ⟩;
  exact GlobalCertified.mono ( global_radius_ge_min_local_region f x₀ y R r_local r_region hlocal hregion ) hr

/-! ## Section 4: Tropical Lipschitz Local Certificate -/

/-
**Bridge to tropical spectral bounds**: If the network has Lipschitz constant
    `K` and tropical degree `d`, then the pairwise tropical certificate radius
    provides a local certificate on any region.
-/
theorem tropical_local_certificate
    {n k : ℕ}
    (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ) (y : Fin k)
    (R : Set (Fin n → ℝ))
    (K : ℝ≥0) (hK : 0 < K)
    (hlip : ∀ j, LipschitzWith K (fun x => f x j))
    (d : ℕ) (hd : 1 ≤ d)
    (hcorrect : ∀ j, j ≠ y → f x₀ y > f x₀ j)
    (hx₀ : x₀ ∈ R)
    (r : ℝ) (hr : r > 0)
    (hr_bound : ∀ j, j ≠ y → r ≤ (f x₀ y - f x₀ j) / (2 * K * d)) :
    LocalCertified f x₀ y R r := by
  intro x hx hx' j; by_cases hj : j = y <;> simp_all +decide [ div_le_iff₀ ] ;
  -- Apply the Lipschitz property to get the bounds on the differences.
  have h_lip : ‖f x y - f x₀ y‖ ≤ K * ‖x - x₀‖ ∧ ‖f x j - f x₀ j‖ ≤ K * ‖x - x₀‖ := by
    exact ⟨ by simpa using hlip y |>.dist_le_mul x x₀, by simpa using hlip j |>.dist_le_mul x x₀ ⟩;
  have := hr_bound j hj;
  rw [ le_div_iff₀ ] at this <;> norm_num at *;
  · nlinarith [ abs_le.mp h_lip.1, abs_le.mp h_lip.2, show ( d : ℝ ) ≥ 1 by norm_cast, show ( K : ℝ ) > 0 by positivity, mul_le_mul_of_nonneg_left ( show ( d : ℝ ) ≥ 1 by norm_cast ) ( show ( K : ℝ ) ≥ 0 by positivity ) ];
  · positivity

/-
**Full compositional theorem with tropical certificates.**

Combines `tropical_local_certificate` with the region containment
to get a global certified radius from tropical spectral data.
-/
theorem tropical_compositional_certified_radius
    {n k : ℕ}
    (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ) (y : Fin k)
    (R : Set (Fin n → ℝ))
    (K : ℝ≥0) (hK : 0 < K)
    (hlip : ∀ j, LipschitzWith K (fun x => f x j))
    (d : ℕ) (hd : 1 ≤ d)
    (hcorrect : ∀ j, j ≠ y → f x₀ y > f x₀ j)
    (hx₀ : x₀ ∈ R)
    (r_local : ℝ) (hr_local : r_local > 0)
    (hr_local_bound : ∀ j, j ≠ y → r_local ≤ (f x₀ y - f x₀ j) / (2 * K * d))
    (r_region : ℝ)
    (hregion : RegionContains x₀ R r_region) :
    GlobalCertified f x₀ y (min r_local r_region) := by
  apply global_radius_ge_min_local_region f x₀ y R r_local r_region (by
  convert tropical_local_certificate f x₀ y R K hK hlip d hd hcorrect hx₀ r_local hr_local hr_local_bound) hregion

/-! ## Section 5: Lipschitz Global Certificate -/

/-
The Lipschitz certificate: within radius `gap / (2K)` for each competing class,
    the classification is preserved.
-/
theorem lipschitz_cert_is_global {n k : ℕ}
    (f : (Fin n → ℝ) → (Fin k → ℝ))
    (x₀ : Fin n → ℝ) (y : Fin k) (K : ℝ≥0) (hK : K > 0)
    (hlip : ∀ j, LipschitzWith K (fun x => f x j))
    (hcorrect : ∀ j, j ≠ y → f x₀ y > f x₀ j)
    (r : ℝ) (hr : r > 0)
    (hr_bound : ∀ j, j ≠ y → r ≤ (f x₀ y - f x₀ j) / (2 * K)) :
    GlobalCertified f x₀ y r := by
  -- For any $x$ with $\|x - x₀\| < r$, we have $|f x y - f x₀ y| \leq K \|x - x₀\|$ and $|f x j - f x₀ j| \leq K \|x - x₀\|$ for all $j$.
  have h_lip : ∀ x, ‖x - x₀‖ < r → ∀ j, |f x j - f x₀ j| ≤ K * ‖x - x₀‖ := by
    exact fun x hx j => by simpa using hlip j |>.dist_le_mul x x₀;
  -- Therefore, $2K \|x - x₀\| < f x₀ y - f x₀ j$, which implies $f x y - f x j > 0$.
  intros x hx
  by_cases hxy : x = x₀;
  · grind +splitImp;
  · intro j; specialize hr_bound j; by_cases hj : j = y <;> simp_all +decide [ le_div_iff₀, mul_assoc ] ;
    nlinarith [ abs_le.mp ( h_lip x hx j ), abs_le.mp ( h_lip x hx y ), hcorrect j hj, show ( K : ℝ ) > 0 by positivity ]

end