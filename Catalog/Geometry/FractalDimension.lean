/-
  Set-local distortion of Hausdorff dimension
  ===========================================

  Mathlib knows that Hausdorff dimension is preserved by *global* isometries and
  by continuous linear equivalences, and that *global* (anti)Lipschitz maps give
  one-sided bounds (`LipschitzWith.dimH_image_le`, `AntilipschitzWith.le_dimH_image`).
  What is missing is the **set-local** theory: a map that is only well behaved on a
  subset `s` (which is the realistic situation for fractals, IFS attractors and
  quasi-symmetric maps, where good control only holds on the relevant piece).

  This file develops that theory from scratch:

  * `le_dimH_image_of_lipschitzOn_leftInverse` — a left inverse that is Lipschitz on
    the image forces a *lower* dimension bound on the image.
  * `dimH_image_eq_of_lipschitzOn_lipschitzOn_inverse` — set-local bi-Lipschitz
    invariance of Hausdorff dimension.
  * `dimH_image_bounds_of_holderOn_holderOn_inverse` — the quasi-symmetric flavoured
    *two-sided* Hölder distortion estimate
      `dimH (f '' s) ≤ dimH s / rf`  and  `dimH s ≤ dimH (f '' s) / rg`,
    interpolating between the Lipschitz (`r = 1`) and general Hölder regimes.
  * `AntilipschitzOnWith` — a new set-local antilipschitz predicate, with
    `AntilipschitzOnWith.le_dimH_image` and the bi-Lipschitz invariance corollary
    `dimH_image_eq_of_lipschitzOn_antilipschitzOn`.

  These are the foundational tools called for in the fractal-topology research
  programme (the `AntilipschitzOnWith` infrastructure and Hölder/antilipschitz
  distortion bounds).
-/
import Mathlib

open Set Function
open scoped ENNReal NNReal

namespace FractalDimension

variable {X Y : Type*}

/-! ### Lower dimension bounds from a Lipschitz left inverse -/

-- !-- If `g` is Lipschitz on `f '' s` and undoes `f` on `s`, then `g '' (f '' s) = s`,
-- !-- and since Lipschitz maps do not increase Hausdorff dimension we get `dimH s ≤ dimH (f '' s)`. -- !--
/-- If `g` is a left inverse of `f` on `s` that is Lipschitz on the image `f '' s`,
then the image cannot have smaller Hausdorff dimension than `s`. -/
theorem le_dimH_image_of_lipschitzOn_leftInverse
    [EMetricSpace X] [EMetricSpace Y]
    {f : X → Y} {g : Y → X} {s : Set X} {K : ℝ≥0}
    (hg : LipschitzOnWith K g (f '' s)) (hgf : ∀ x ∈ s, g (f x) = x) :
    dimH s ≤ dimH (f '' s) := by
  have hgimg : g '' (f '' s) = s := by
    apply Set.Subset.antisymm
    · rintro _ ⟨_, ⟨x, hx, rfl⟩, rfl⟩
      rw [hgf x hx]; exact hx
    · intro x hx
      exact ⟨f x, ⟨x, hx, rfl⟩, hgf x hx⟩
  calc dimH s = dimH (g '' (f '' s)) := by rw [hgimg]
    _ ≤ dimH (f '' s) := hg.dimH_image_le

/-! ### Set-local bi-Lipschitz invariance -/

-- !-- Combine the Lipschitz upper bound `dimH (f '' s) ≤ dimH s` with the lower bound coming
-- !-- from the Lipschitz left inverse to get equality. -- !--
/-- **Set-local bi-Lipschitz invariance of Hausdorff dimension.** If `f` is Lipschitz on `s`
and admits a left inverse `g` that is Lipschitz on `f '' s`, then `dimH (f '' s) = dimH s`. -/
theorem dimH_image_eq_of_lipschitzOn_lipschitzOn_inverse
    [EMetricSpace X] [EMetricSpace Y]
    {f : X → Y} {g : Y → X} {s : Set X} {Kf Kg : ℝ≥0}
    (hf : LipschitzOnWith Kf f s) (hg : LipschitzOnWith Kg g (f '' s))
    (hgf : ∀ x ∈ s, g (f x) = x) :
    dimH (f '' s) = dimH s :=
  le_antisymm hf.dimH_image_le (le_dimH_image_of_lipschitzOn_leftInverse hg hgf)

/-! ### Two-sided Hölder distortion (quasi-symmetric flavour) -/

-- !-- The forward map being Hölder with exponent `rf` gives `dimH (f '' s) ≤ dimH s / rf`;
-- !-- the inverse being Hölder with exponent `rg` on the image gives, via `g '' (f '' s) = s`,
-- !-- the dual bound `dimH s ≤ dimH (f '' s) / rg`. -- !--
/-- **Two-sided Hölder distortion of Hausdorff dimension.** If `f` is Hölder on `s` with
exponent `rf > 0` and admits a left inverse `g` that is Hölder on `f '' s` with exponent
`rg > 0`, then the Hausdorff dimension is squeezed on both sides:
`dimH (f '' s) ≤ dimH s / rf` and `dimH s ≤ dimH (f '' s) / rg`. This is the dimension
analogue of the quasi-symmetric distortion estimate, interpolating between Lipschitz
(`r = 1`, giving exact invariance) and general Hölder maps. -/
theorem dimH_image_bounds_of_holderOn_holderOn_inverse
    [EMetricSpace X] [EMetricSpace Y]
    {f : X → Y} {g : Y → X} {s : Set X} {Cf Cg rf rg : ℝ≥0}
    (hf : HolderOnWith Cf rf f s) (hrf : 0 < rf)
    (hg : HolderOnWith Cg rg g (f '' s)) (hrg : 0 < rg)
    (hgf : ∀ x ∈ s, g (f x) = x) :
    dimH (f '' s) ≤ dimH s / rf ∧ dimH s ≤ dimH (f '' s) / rg := by
  have hgimg : g '' (f '' s) = s := by
    apply Set.Subset.antisymm
    · rintro _ ⟨_, ⟨x, hx, rfl⟩, rfl⟩
      rw [hgf x hx]; exact hx
    · intro x hx
      exact ⟨f x, ⟨x, hx, rfl⟩, hgf x hx⟩
  refine ⟨hf.dimH_image_le hrf, ?_⟩
  calc dimH s = dimH (g '' (f '' s)) := by rw [hgimg]
    _ ≤ dimH (f '' s) / rg := hg.dimH_image_le hrg

/-! ### A set-local antilipschitz predicate -/

/-- `AntilipschitzOnWith K f s` means that on the set `s`, the map `f` does not contract
distances by more than a factor `K`: `edist x y ≤ K * edist (f x) (f y)` for `x, y ∈ s`.
This is the set-local analogue of Mathlib's global `AntilipschitzWith`. -/
def AntilipschitzOnWith [EMetricSpace X] [EMetricSpace Y]
    (K : ℝ≥0) (f : X → Y) (s : Set X) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → edist x y ≤ K * edist (f x) (f y)

-- !-- If `f x = f y` then the antilipschitz bound forces `edist x y ≤ K * 0 = 0`, hence `x = y`. -- !--
/-- A set-local antilipschitz map is injective on the set. -/
theorem AntilipschitzOnWith.injOn [EMetricSpace X] [EMetricSpace Y]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    InjOn f s := by
  intro x hx y hy hxy
  have h := hf hx hy
  rw [hxy, edist_self, mul_zero] at h
  simpa using h

-- !-- Rewrite the canonical left inverse `invFunOn f s` via injectivity, reducing the Lipschitz
-- !-- bound for the inverse on `f '' s` to the antilipschitz hypothesis on `s`. -- !--
/-- The canonical left inverse of a set-local antilipschitz map is Lipschitz on the image. -/
theorem AntilipschitzOnWith.lipschitzOnWith_invFunOn
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    LipschitzOnWith K (invFunOn f s) (f '' s) := by
  rintro _ ⟨x, hx, rfl⟩ _ ⟨y, hy, rfl⟩
  rw [hf.injOn.leftInvOn_invFunOn hx, hf.injOn.leftInvOn_invFunOn hy]
  exact hf hx hy

-- !-- Apply `le_dimH_image_of_lipschitzOn_leftInverse` to the canonical Lipschitz left inverse. -- !--
/-- **Set-local antilipschitz lower bound.** A map that is antilipschitz on `s` cannot send `s`
to an image of strictly smaller Hausdorff dimension: `dimH s ≤ dimH (f '' s)`. This is the
set-local analogue of Mathlib's `AntilipschitzWith.le_dimH_image`. -/
theorem AntilipschitzOnWith.le_dimH_image
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    dimH s ≤ dimH (f '' s) :=
  le_dimH_image_of_lipschitzOn_leftInverse hf.lipschitzOnWith_invFunOn
    (fun _ hx => hf.injOn.leftInvOn_invFunOn hx)

-- !-- Lipschitz gives the upper bound, antilipschitz gives the lower bound; combine. -- !--
/-- **Set-local bi-Lipschitz invariance, intrinsic form.** A map that is simultaneously
Lipschitz and antilipschitz on `s` preserves Hausdorff dimension: `dimH (f '' s) = dimH s`. -/
theorem dimH_image_eq_of_lipschitzOn_antilipschitzOn
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {Kf Kf' : ℝ≥0} {f : X → Y} {s : Set X}
    (hf : LipschitzOnWith Kf f s) (hf' : AntilipschitzOnWith Kf' f s) :
    dimH (f '' s) = dimH s :=
  le_antisymm hf.dimH_image_le hf'.le_dimH_image

/-! ### Sanity examples -/

/-- The bi-Lipschitz invariance recovers the trivial identity case. -/
example [EMetricSpace X] [Nonempty X] (s : Set X) :
    dimH ((id : X → X) '' s) = dimH s :=
  dimH_image_eq_of_lipschitzOn_antilipschitzOn
    (Kf := 1) (Kf' := 1) (LipschitzWith.id.lipschitzOnWith)
    (fun x _ y _ => by simp)

end FractalDimension