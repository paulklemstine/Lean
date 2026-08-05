/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.AffineParityGap

/-!
# Affine subspace statistics in `𝔽₂ⁿ`: sharpness of the refined parity bound at `d = n`

`Catalog/Geometry/AffineParityGap.lean` proves
`P[|F ∩ A| odd] ≤ (1/2) ∏_{i<d} (1 - 2^{i-n})` for affine `(d+1)`-cubes in `𝔽₂ⁿ` (`d ≤ n`),
together with the exact criterion for equality: every independent direction tuple `w` must
have exactly half of the base points giving an odd count.

Here we exhibit an extremal set for the *top* dimension `d = n - 1`, i.e. for affine cubes
of dimension equal to the ambient dimension: a **single point**.  Indeed, if `w` is
independent, then the cube `(c, w)` is a genuine `d`-flat, so it contains a fixed point `p`
at most once; the base points whose cube contains `p` are exactly the `2^d` points
`p + ∑ yᵢwᵢ`.  This is half of `𝔽₂ⁿ` precisely when `d = n - 1`.

## Main results

* `AffineParitySingleton.oddBase_singleton` : for independent `w`, the odd base points of a
  singleton `{p}` are the `2^d` points of the flat through `p` with directions `w`.
* `AffineParitySingleton.oddProb_singleton_eq` : `P[|F ∩ {p}| odd] = (1/2)∏_{i<n-1}(1-2^{i-n})`
  for affine `n`-cubes in `𝔽₂ⁿ`.
* `AffineParitySingleton.maxOddProb_full_eq` : **the exact value**
  `max_{A ⊆ 𝔽₂ⁿ} P[|F ∩ A| odd] = (1/2) ∏_{i<n-1} (1 - 2^{i-n})` for affine `n`-cubes.
  For `n = 1, 2, 3` the values are `1/2`, `3/8`, `21/64`.
-/

namespace AffineParitySingleton

open Finset AffineStats AffineParityGap

variable {n d : ℕ}

/-- For an independent direction tuple, the cube meets a singleton at most once. -/
lemma cnt_singleton_le_one (p : Vec n) (c : Vec n) {w : Fin d → Vec n} (hw : Indep w) :
    cnt {p} c w ≤ 1 := by
  classical
  rw [cnt]
  refine Finset.card_le_one.2 fun y hy z hz => ?_
  simp only [mem_filter, mem_univ, true_and, Finset.mem_singleton] at hy hz
  exact pt_injective c hw (hy.trans hz.symm)

/-- The base points whose cube (with independent directions `w`) contains `p`. -/
lemma oddBase_singleton (p : Vec n) {w : Fin d → Vec n} (hw : Indep w) :
    oddBase {p} w = Finset.image (fun y : Fin d → ZMod 2 => p + ∑ i, y i • w i) univ := by
  classical
  ext c
  simp only [oddBase, mem_filter, mem_univ, true_and, Finset.mem_image]
  constructor
  · intro hc
    have h1 : cnt {p} c w ≠ 0 := by
      intro h0
      exact hc (h0 ▸ dvd_zero 2)
    obtain ⟨y, hy⟩ := Finset.card_pos.1 (Nat.pos_of_ne_zero h1)
    simp only [mem_filter, mem_univ, true_and, Finset.mem_singleton] at hy
    refine ⟨y, ?_⟩
    rw [← hy, pt, add_assoc, vadd_self, add_zero]
  · rintro ⟨y, rfl⟩
    have hmem : y ∈ univ.filter fun z : Fin d → ZMod 2 =>
        pt (p + ∑ i, y i • w i) w z ∈ ({p} : Finset (Vec n)) := by
      simp only [mem_filter, mem_univ, true_and, Finset.mem_singleton, pt]
      rw [add_assoc, vadd_self, add_zero]
    have h1 : 1 ≤ cnt {p} (p + ∑ i, y i • w i) w :=
      Finset.card_pos.2 ⟨y, hmem⟩
    have h2 := cnt_singleton_le_one p (p + ∑ i, y i • w i) hw
    omega

/-- Hence a singleton has exactly `2^d` odd base points for each independent tuple. -/
lemma card_oddBase_singleton (p : Vec n) {w : Fin d → Vec n} (hw : Indep w) :
    (oddBase {p} w).card = 2 ^ d := by
  classical
  rw [oddBase_singleton p hw, Finset.card_image_of_injective _ ?inj]
  · simp
  case inj =>
    intro y z hyz
    have : pt p w y = pt p w z := by simpa [pt] using hyz
    exact pt_injective p hw this

/-- **A single point is extremal for affine `n`-cubes in `𝔽₂ⁿ`.** -/
theorem oddProb_singleton_eq (d : ℕ) (p : Vec (d + 1)) :
    oddProb (d + 1) (d + 1) ({p} : Finset (Vec (d + 1)))
      = (1 / 2) * ∏ i : Fin d, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ (d + 1)) := by
  have hbal : ∀ w : Fin d → Vec (d + 1), Indep w →
      2 * (oddBase ({p} : Finset (Vec (d + 1))) w).card = 2 ^ (d + 1) := by
    intro w hw
    rw [card_oddBase_singleton p hw, pow_succ]
    ring
  rw [oddProb_eq_of_all_balanced _ hbal, indepRatio_eq_prod (Nat.le_succ d)]

/-- **The exact parity maximum for affine `n`-cubes in `𝔽₂ⁿ`.**
`max_A P[|F ∩ A| odd] = (1/2) ∏_{i<n-1} (1 - 2^{i-n})`; the maximum is attained by every
singleton.  For `n = 1, 2, 3` the value is `1/2`, `3/8`, `21/64`. -/
theorem maxOddProb_full_eq (d : ℕ) :
    maxOddProb (d + 1) (d + 1)
      = (1 / 2) * ∏ i : Fin d, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ (d + 1)) := by
  refine le_antisymm ?_ ?_
  · refine Finset.sup'_le _ _ fun A _ => ?_
    exact oddProb_le_half_mul_prod (n := d + 1) (d := d) A (Nat.le_succ d)
  · rw [← oddProb_singleton_eq d 0]
    exact Finset.le_sup' (fun A => oddProb (d + 1) (d + 1) A) (mem_univ _)

/-- The value at `n = 3`: `21/64`. -/
theorem maxOddProb_three : maxOddProb 3 3 = 21 / 64 := by
  have h := maxOddProb_full_eq 2
  norm_num [Fin.prod_univ_two] at h
  simpa using h

end AffineParitySingleton