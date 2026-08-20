import Catalog.NumberTheory.PrimeFractalBoxDimension

/-!
# Refined box-counting: a universal ceiling and a logarithmic defect

Two refinements of `NumberTheory.PrimeFractalBoxDimension`.

## 1. A universal ceiling: no subset of `ℝ` can have box dimension `> 1`

`boxCountSet S m` counts the boxes of size `1/m` meeting a set `S ⊆ ℝ`.  For any
`S` contained in a bounded interval, `boxCountSet_le` gives
`boxCountSet S m ≤ ⌊c m⌋ + 1`, whence `boxDim_le_one_of_bounded`:

  for every `ε > 0`, eventually `log (boxCountSet S m) / log m ≤ 1 + ε`.

This settles the mission's `1 + ε` conjecture *structurally*: whatever the
twin primes do, a subset of the line has box dimension at most `1`.  The value
`ε = 0` is not an accident of the primes; it is forced by the ambient
dimension.  (The Hausdorff dimension is likewise `≤ 1`, and for the primes it
is in fact `0`.)

## 2. A logarithmic defect: `boxCount m = Θ(m / log m)`, not `Θ(m)`

Chebyshev's *upper* bound (from Mathlib) plus a splitting of the primes at `m`
gives `eventually_boxCount_le`: `boxCount m ≤ 5 m / log m`.  Hence
`tendsto_boxCount_div_self`: `boxCount m / m → 0`.  So although the box
dimension is exactly `1`, the prime fractal has *zero one-dimensional Minkowski
content*: it is a dimension-`1` set that occupies a vanishing fraction of the
boxes a genuine interval would occupy.  This is the precise sense in which the
primes "fill out a line" — only up to a logarithmic factor, and they carry no
length at all.
-/

namespace PrimeFractal

open Filter Topology

/-! ### 1. The universal ceiling -/

/-- The number of boxes of size `1/m` meeting a set `S ⊆ ℝ` (for `S` in `[0, ∞)`). -/
noncomputable def boxCountSet (S : Set ℝ) (m : ℕ) : ℕ :=
  ((fun x => ⌊(m : ℝ) * x⌋₊) '' S).ncard

theorem boxCount_eq_boxCountSet (m : ℕ) : boxCount m = boxCountSet primeFractal m := by
  have : (fun x => ⌊(m : ℝ) * x⌋₊) '' (logInv '' {p : ℕ | p.Prime})
      = boxIndex m '' {p : ℕ | p.Prime} := by
    rw [← Set.image_comp]
    rfl
  rw [boxCountSet, primeFractal, this, boxCount, occupiedBoxes]

theorem primeFractal_subset_Icc : primeFractal ⊆ Set.Icc 0 2 := by
  rintro x ⟨p, hp, rfl⟩
  exact ⟨le_of_lt (logInv_pos hp), logInv_le_two hp.two_le⟩

/-- A set inside `[0, c]` meets at most `⌊c m⌋ + 1` boxes of size `1/m`. -/
theorem boxCountSet_le {S : Set ℝ} {c : ℝ} (hS : S ⊆ Set.Icc 0 c) (m : ℕ) :
    boxCountSet S m ≤ ⌊c * (m : ℝ)⌋₊ + 1 := by
  have hsub : (fun x => ⌊(m : ℝ) * x⌋₊) '' S ⊆ ↑(Finset.range (⌊c * (m : ℝ)⌋₊ + 1)) := by
    rintro k ⟨x, hx, rfl⟩
    obtain ⟨hx0, hxc⟩ := hS hx
    simp only [Finset.coe_range, Set.mem_Iio]
    refine Nat.lt_succ_of_le ?_
    have hle : (m : ℝ) * x ≤ c * (m : ℝ) := by
      have : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
      nlinarith
    exact Nat.floor_le_floor hle
  have h := Set.ncard_le_ncard hsub (Finset.range (⌊c * (m : ℝ)⌋₊ + 1)).finite_toSet
  simpa [boxCountSet, Set.ncard_coe_finset] using h

/-- **The universal ceiling.** Every bounded subset of `ℝ` has upper box dimension `≤ 1`:
for each `ε > 0`, eventually `log (boxCountSet S m) / log m ≤ 1 + ε`. -/
theorem boxDim_le_one_of_bounded {S : Set ℝ} {c : ℝ} (hc : 0 < c) (hS : S ⊆ Set.Icc 0 c)
    {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ m : ℕ in atTop, Real.log (boxCountSet S m) / Real.log m ≤ 1 + ε := by
  have hlim : Tendsto (fun m : ℕ => Real.log (c + 1) * (1 / Real.log m)) atTop (𝓝 0) := by
    simpa using tendsto_inv_log.const_mul (Real.log (c + 1))
  filter_upwards [hlim.eventually (gt_mem_nhds hε), eventually_two_le_log,
    eventually_ge_atTop 1] with m hsmall hL2 hm1
  have hL0 : 0 < Real.log m := by linarith
  have hm0 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm1
  rcases Nat.eq_zero_or_pos (boxCountSet S m) with h0 | hpos
  · rw [h0]
    simp only [Nat.cast_zero, Real.log_zero, zero_div]
    linarith
  · have hb : (boxCountSet S m : ℝ) ≤ (c + 1) * (m : ℝ) := by
      have h := boxCountSet_le hS m
      have h' : ((boxCountSet S m : ℕ) : ℝ) ≤ ((⌊c * (m : ℝ)⌋₊ + 1 : ℕ) : ℝ) := by
        exact_mod_cast h
      have hfloor : ((⌊c * (m : ℝ)⌋₊ : ℕ) : ℝ) ≤ c * (m : ℝ) :=
        Nat.floor_le (by positivity)
      push_cast at h'
      nlinarith
    have hb0 : (0 : ℝ) < (boxCountSet S m : ℝ) := by exact_mod_cast hpos
    have hlog : Real.log (boxCountSet S m) ≤ Real.log (c + 1) + Real.log m := by
      have := Real.log_le_log hb0 hb
      rwa [Real.log_mul (by positivity) (by linarith)] at this
    rw [div_le_iff₀ hL0]
    have hsmall' : Real.log (c + 1) * (1 / Real.log m) < ε := hsmall
    have : Real.log (c + 1) < ε * Real.log m := by
      rw [mul_one_div, div_lt_iff₀ hL0] at hsmall'
      linarith
    nlinarith

/-- Specialisation: the prime fractal cannot have box dimension `1 + ε` with `ε > 0`. -/
theorem primeFractal_boxDim_le_one {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ m : ℕ in atTop, Real.log (boxCount m) / Real.log m ≤ 1 + ε := by
  simpa only [boxCount_eq_boxCountSet] using
    boxDim_le_one_of_bounded (c := 2) (by norm_num) primeFractal_subset_Icc hε

/-! ### 2. The logarithmic defect -/

theorem eventually_primeCounting_le_nat :
    ∀ᶠ m : ℕ in atTop, (Nat.primeCounting m : ℝ) ≤ 2.4 * (m : ℝ) / Real.log m := by
  have h := Chebyshev.eventually_primeCounting_le (ε := 1) one_pos
  have hnat := (tendsto_natCast_atTop_atTop (R := ℝ)).eventually h
  filter_upwards [hnat, eventually_two_le_log] with m hm hL2
  have hL0 : 0 < Real.log m := by linarith
  have hm0 : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  rw [Nat.floor_natCast] at hm
  have hlog4 : Real.log 4 + 1 ≤ 2.4 := by
    have h2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
    have : Real.log 4 = 2 * Real.log 2 := by
      rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
    rw [this]; linarith
  have hstep : (Real.log 4 + 1) * (m : ℝ) / Real.log m ≤ 2.4 * (m : ℝ) / Real.log m := by
    gcongr
  linarith [hm, hstep]

/-- **Chebyshev's upper bound in box form.** At scale `1/m` the primes occupy at most
`5 m / log m` boxes: a logarithmic factor fewer than an interval would. -/
theorem eventually_boxCount_le :
    ∀ᶠ m : ℕ in atTop, (boxCount m : ℝ) ≤ 5 * (m : ℝ) / Real.log m := by
  filter_upwards [eventually_primeCounting_le_nat, eventually_two_le_log,
    eventually_log_pow_le (C := 1) one_pos 1, eventually_ge_atTop 2] with m hpi hL2 hmlog hm2
  set L : ℝ := Real.log m with hLdef
  have hL0 : 0 < L := by linarith
  have hm0 : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  have hmL : 1 ≤ (m : ℝ) / L := by
    rw [le_div_iff₀ hL0]
    simpa using hmlog
  set K : ℕ := ⌊(m : ℝ) / L⌋₊ with hKdef
  -- split the primes at `m`
  have hsplit : occupiedBoxes m ⊆
      boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ m} ∪ ↑(Finset.range (K + 1)) := by
    rintro k ⟨p, hp, rfl⟩
    by_cases hpm : p ≤ m
    · exact Or.inl ⟨p, ⟨hp, hpm⟩, rfl⟩
    · refine Or.inr ?_
      simp only [Finset.coe_range, Set.mem_Iio]
      refine Nat.lt_succ_of_le ?_
      have hpm' : (m : ℝ) ≤ (p : ℝ) := by exact_mod_cast le_of_lt (not_le.mp hpm)
      have hmpos : (0 : ℝ) < (m : ℝ) := by
        have : (2 : ℕ) ≤ m := hm2
        exact_mod_cast lt_of_lt_of_le two_pos this
      have hlogp : L ≤ Real.log p := by
        rw [hLdef]; exact Real.log_le_log hmpos hpm'
      have hle : (m : ℝ) * logInv p ≤ (m : ℝ) / L := by
        rw [logInv, mul_one_div, div_le_div_iff_of_pos_left hmpos (by linarith) hL0]
        exact hlogp
      exact Nat.floor_le_floor hle
  have hfinA : {p : ℕ | p.Prime ∧ p ≤ m}.Finite :=
    Set.Finite.subset (Set.finite_Iic m) (fun p hp => hp.2)
  have hfin : (boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ m} ∪
      ↑(Finset.range (K + 1)) : Set ℕ).Finite :=
    (hfinA.image _).union (Finset.range (K + 1)).finite_toSet
  have hcard : boxCount m ≤ Nat.primeCounting m + (K + 1) := by
    have h1 := Set.ncard_le_ncard hsplit hfin
    have h2 := Set.ncard_union_le (boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ m})
      (↑(Finset.range (K + 1)) : Set ℕ)
    have h3 : (boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ m}).ncard ≤ Nat.primeCounting m := by
      calc (boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ m}).ncard
          ≤ {p : ℕ | p.Prime ∧ p ≤ m}.ncard := Set.ncard_image_le hfinA
        _ = Nat.primeCounting m := primeCounting_eq_ncard m
    have h4 : ((Finset.range (K + 1) : Finset ℕ) : Set ℕ).ncard = K + 1 := by
      simp
    calc boxCount m ≤ (boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ m} ∪
            ↑(Finset.range (K + 1))).ncard := h1
      _ ≤ (boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ m}).ncard +
            ((Finset.range (K + 1) : Finset ℕ) : Set ℕ).ncard := h2
      _ ≤ Nat.primeCounting m + (K + 1) := by rw [h4]; exact Nat.add_le_add_right h3 _
  have hKle : (K : ℝ) ≤ (m : ℝ) / L := Nat.floor_le (by positivity)
  have hcard' : (boxCount m : ℝ) ≤ (Nat.primeCounting m : ℝ) + ((K : ℝ) + 1) := by
    exact_mod_cast hcard
  have : (boxCount m : ℝ) ≤ 2.4 * (m : ℝ) / L + (m : ℝ) / L + 1 := by
    linarith [hpi, hKle]
  have hfive : 2.4 * (m : ℝ) / L + (m : ℝ) / L + 1 ≤ 5 * (m : ℝ) / L := by
    have h1 : 2.4 * (m : ℝ) / L = 2.4 * ((m : ℝ) / L) := by ring
    have h2 : 5 * (m : ℝ) / L = 5 * ((m : ℝ) / L) := by ring
    rw [h1, h2]
    linarith [hmL]
  linarith

/-- **Zero one-dimensional Minkowski content.** The fraction of boxes occupied by the
prime fractal tends to `0`, even though its box dimension is `1`. -/
theorem tendsto_boxCount_div_self :
    Tendsto (fun m : ℕ => (boxCount m : ℝ) / (m : ℝ)) atTop (𝓝 0) := by
  have hupper : ∀ᶠ m : ℕ in atTop, (boxCount m : ℝ) / (m : ℝ) ≤ 5 * (1 / Real.log m) := by
    filter_upwards [eventually_boxCount_le, eventually_two_le_log, eventually_ge_atTop 1]
      with m hb hL2 hm1
    have hL0 : 0 < Real.log m := by linarith
    have hm0 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm1
    rw [div_le_iff₀ hm0]
    have : 5 * (m : ℝ) / Real.log m = 5 * (1 / Real.log m) * (m : ℝ) := by
      field_simp
    linarith [hb, this.le, this.ge]
  have hlower : ∀ᶠ m : ℕ in atTop, (0 : ℝ) ≤ (boxCount m : ℝ) / (m : ℝ) := by
    filter_upwards [eventually_ge_atTop 1] with m hm1
    positivity
  have h5 : Tendsto (fun m : ℕ => 5 * (1 / Real.log m)) atTop (𝓝 0) := by
    simpa using tendsto_inv_log.const_mul (5 : ℝ)
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds h5 hlower hupper

end PrimeFractal