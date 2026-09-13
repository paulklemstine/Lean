import Tropical.DependentFibers.Corners

/-!
# The generic tropical polynomial: `n` simple corners, and sharpness of both bounds

`Core.multiplicity_sum_le` bounds the total multiplicity excess by the degree `n`, and
`Corners.cornerSet_ncard_le` bounds the *number* of corners by `n`.  The degenerate
polynomial of `Core.multiplicity_sum_eq_deg` saturates the first bound with a single
corner of multiplicity `n + 1`; this file saturates **both** bounds simultaneously at
the opposite extreme, with the *generic* (strictly convex, unit-slope-increment)
polynomial

`rampCoeff i = i(i−1)/2`,  i.e. the min-plus polynomial `min_i (i(i−1)/2 + i·x)`.

Its Newton polygon is the staircase with all `n` unit edges, so it has exactly `n`
corners, each of multiplicity `2`, located at the integers `0, −1, …, −(n−1)`.  The
key computation is the exact difference formula

`v_j(−m) − v_m(−m) = (j − m)(j − m − 1)/2`,

nonnegative for integers and zero exactly at `j = m, m+1`
(`ramp_value_diff`, `fiber_rampCoeff`).

Consequences proved here:

* `cornerSet_rampCoeff_ncard` — exactly `n` corners: `cornerSet_ncard_le` is sharp;
* `multiplicity_sum_rampCoeff` — the total multiplicity excess equals `n`: the degree
  bound is sharp in the generic case too, and every corner is *simple*;
* `rampCoeff_fibers_unequal` — the fibre cardinalities `2` and `1` both occur, so the
  generic family is also genuinely dependent.
-/

namespace TropicalDependentFibers

open Finset

/-! ## Integer positivity of `t(t−1)` -/

theorem int_mul_pred_nonneg (t : ℤ) : 0 ≤ t * (t - 1) := by
  rcases le_or_gt t 0 with h | h
  · nlinarith
  · have h1 : 1 ≤ t := h
    nlinarith

theorem int_eq_zero_or_one_of_mul_pred_nonpos {t : ℤ} (h : t * (t - 1) ≤ 0) :
    t = 0 ∨ t = 1 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h0, h1⟩ := hcon
  rcases lt_or_gt_of_ne h0 with hneg | hpos
  · have : t ≤ -1 := by omega
    nlinarith
  · have : 2 ≤ t := by omega
    nlinarith

/-! ## The generic (staircase) tropical polynomial -/

/-- The **ramp coefficients** `c i = i(i−1)/2`: the strictly convex coefficient vector
whose successive slope increments are `0, 1, 2, …`.  This is the generic tropical
polynomial of degree `n`. -/
def rampCoeff : ℕ → ℚ := fun i => (i : ℚ) * ((i : ℚ) - 1) / 2

/-- The exact monomial-difference formula at the integer point `x = −m`. -/
theorem ramp_value_diff (m j : ℕ) :
    (rampCoeff j + (j : ℚ) * (-(m : ℚ))) - (rampCoeff m + (m : ℚ) * (-(m : ℚ)))
      = ((((j : ℤ) - (m : ℤ)) : ℤ) : ℚ) * (((((j : ℤ) - (m : ℤ)) : ℤ) : ℚ) - 1) / 2 := by
  simp only [rampCoeff]
  push_cast
  ring

/-- **The generic fibre.**  At `x = −m` exactly the two monomials `m` and `m + 1` tie:
every corner of the ramp polynomial is simple. -/
theorem fiber_rampCoeff {n m : ℕ} (hm : m + 1 ≤ n) :
    fiber n rampCoeff (-(m : ℚ)) = {m, m + 1} := by
  have hmn : m ≤ n := by omega
  -- the value at `m` is a lower bound for all monomials
  have hlower : ∀ j : ℕ, rampCoeff m + (m : ℚ) * (-(m : ℚ)) ≤ rampCoeff j + (j : ℚ) * (-(m : ℚ)) := by
    intro j
    have hd := ramp_value_diff m j
    have hpos : (0 : ℚ) ≤ ((((j : ℤ) - (m : ℤ)) : ℤ) : ℚ) * (((((j : ℤ) - (m : ℤ)) : ℤ) : ℚ) - 1) := by
      have := int_mul_pred_nonneg ((j : ℤ) - (m : ℤ))
      have hq : (0 : ℚ) ≤ ((((j : ℤ) - (m : ℤ)) * (((j : ℤ) - (m : ℤ)) - 1) : ℤ) : ℚ) := by
        exact_mod_cast this
      push_cast at hq ⊢
      linarith
    linarith
  -- the values at `m` and `m + 1` agree
  have hsucc : rampCoeff (m + 1) + ((m + 1 : ℕ) : ℚ) * (-(m : ℚ))
      = rampCoeff m + (m : ℚ) * (-(m : ℚ)) := by
    have hd := ramp_value_diff m (m + 1)
    have hcast : (((((m + 1 : ℕ) : ℤ) - (m : ℤ)) : ℤ) : ℚ) = 1 := by push_cast; ring
    rw [hcast] at hd
    linarith
  ext i
  rw [mem_fiber_iff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hi, hmin⟩
    have h := hmin m hmn
    have hd := ramp_value_diff m i
    have hle : ((((i : ℤ) - (m : ℤ)) : ℤ) : ℚ) * (((((i : ℤ) - (m : ℤ)) : ℤ) : ℚ) - 1) ≤ 0 := by
      linarith
    have hleZ : ((i : ℤ) - (m : ℤ)) * (((i : ℤ) - (m : ℤ)) - 1) ≤ 0 := by
      have : (((((i : ℤ) - (m : ℤ)) * (((i : ℤ) - (m : ℤ)) - 1)) : ℤ) : ℚ) ≤ 0 := by
        push_cast at hle ⊢
        linarith
      exact_mod_cast this
    rcases int_eq_zero_or_one_of_mul_pred_nonpos hleZ with h0 | h1
    · left; omega
    · right; omega
  · rintro (rfl | rfl)
    · exact ⟨hmn, fun j _ => hlower j⟩
    · exact ⟨hm, fun j _ => by rw [hsucc]; exact hlower j⟩

theorem fiber_rampCoeff_card {n m : ℕ} (hm : m + 1 ≤ n) :
    (fiber n rampCoeff (-(m : ℚ))).card = 2 := by
  rw [fiber_rampCoeff hm, Finset.card_insert_of_notMem (by simp), Finset.card_singleton]

/-- Each integer point `−m` with `m < n` is a corner of the ramp polynomial. -/
theorem mem_cornerSet_rampCoeff {n m : ℕ} (hm : m < n) :
    (-(m : ℚ)) ∈ cornerSet n rampCoeff := by
  have : (fiber n rampCoeff (-(m : ℚ))).card = 2 := fiber_rampCoeff_card (by omega)
  simpa [cornerSet] using this.ge

theorem neg_cast_injective : Function.Injective fun m : ℕ => -(m : ℚ) := by
  intro a b hab
  simp only [neg_inj] at hab
  exact_mod_cast hab

/-- **Sharpness of the corner count.**  The generic polynomial of degree `n` has
exactly `n` corners, so `cornerSet_ncard_le` cannot be improved. -/
theorem cornerSet_rampCoeff_ncard (n : ℕ) : (cornerSet n rampCoeff).ncard = n := by
  classical
  have hsub : ((fun m : ℕ => -(m : ℚ)) '' ((range n : Finset ℕ) : Set ℕ)) ⊆
      cornerSet n rampCoeff := by
    rintro _ ⟨m, hm, rfl⟩
    exact mem_cornerSet_rampCoeff (by simpa using hm)
  have himg : ((fun m : ℕ => -(m : ℚ)) '' ((range n : Finset ℕ) : Set ℕ)).ncard = n := by
    rw [Set.ncard_image_of_injective _ neg_cast_injective, Set.ncard_coe_finset,
      Finset.card_range]
  have hfin := cornerSet_finite n rampCoeff
  have hle : n ≤ (cornerSet n rampCoeff).ncard := by
    have h := Set.ncard_le_ncard hsub hfin
    rwa [himg] at h
  have := cornerSet_ncard_le n rampCoeff
  omega

/-- **Sharpness of the degree bound, generically.**  Summed over the `n` simple corners
`0, −1, …, −(n−1)` the multiplicity excess is exactly the degree `n`: the tropical
fundamental theorem is attained with all multiplicities equal to `2`. -/
theorem multiplicity_sum_rampCoeff (n : ℕ) :
    ∑ x ∈ (range n).image (fun m : ℕ => -(m : ℚ)), ((fiber n rampCoeff x).card - 1) = n := by
  classical
  rw [Finset.sum_image (fun a _ b _ h => neg_cast_injective h)]
  have hterm : ∀ m ∈ range n, ((fiber n rampCoeff (-(m : ℚ))).card - 1) = 1 := by
    intro m hm
    have hmn : m < n := mem_range.mp hm
    rw [fiber_rampCoeff_card (by omega)]
  rw [Finset.sum_congr rfl hterm, Finset.sum_const, Finset.card_range, smul_eq_mul, mul_one]

/-- The generic family, too, is genuinely dependent: the fibre cardinalities `2` and
`1` both occur. -/
theorem rampCoeff_fibers_unequal {n : ℕ} (hn : 1 ≤ n) :
    ∃ x y : ℚ, (fiber n rampCoeff x).card = 2 ∧ (fiber n rampCoeff y).card = 1 := by
  obtain ⟨x, hx, hy⟩ := exists_corner hn rampCoeff
  refine ⟨-(0 : ℚ), x + 1, ?_, ?_⟩
  · have h := fiber_rampCoeff_card (n := n) (m := 0) (by omega)
    rw [Nat.cast_zero] at h
    exact h
  · rw [hy, Finset.card_singleton]

/-- Consequently the generic family is not pointwise cardinality-constant, with the
witnessing points computed explicitly rather than abstractly. -/
theorem rampCoeff_not_card_constant {n : ℕ} (hn : 1 ≤ n) :
    ¬ ∃ k : ℕ, ∀ x : ℚ, (fiber n rampCoeff x).card = k := by
  rintro ⟨k, hk⟩
  obtain ⟨x, y, hx, hy⟩ := rampCoeff_fibers_unequal hn
  rw [hk x] at hx
  rw [hk y] at hy
  omega

end TropicalDependentFibers