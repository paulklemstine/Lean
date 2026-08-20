import Catalog.NumberTheory.PrimeFractalBoxDimension

/-!
# The logarithmic lens cannot see primality

The same construction applied to *all* integers `≥ 2` produces the "integer
fractal" `{1 / log n : n ≥ 2}`.  We show it has

* Hausdorff dimension `0` (it is countable), and
* box-counting dimension `1` (`tendsto_intBoxCount_log_div`),

exactly like the prime fractal.  The proof of the lower bound is the same
separation estimate `boxIndex_lt`, but with no arithmetic input at all: for
integers one may simply count `Y - 1` of them below `Y`, where the primes needed
Chebyshev's theorem.

**Conclusion.** Both dimensions agree for the primes and for all integers, so
neither can detect primality: the mission's programme of reading off arithmetic
information (twin primes) from `dim (P, d)` is structurally impossible.  The
difference between the two sets is only visible in the second-order term (the
number of occupied boxes; see `NumberTheory.PrimeFractalRefined`).
-/

namespace PrimeFractal

open Filter Topology

/-- The integer fractal: all integers `≥ 2` through the logarithmic lens. -/
noncomputable def intFractal : Set ℝ := logInv '' {n : ℕ | 2 ≤ n}

/-- Boxes of size `1/m` occupied by the integer fractal. -/
noncomputable def intBoxCount (m : ℕ) : ℕ := (boxIndex m '' {n : ℕ | 2 ≤ n}).ncard

theorem dimH_intFractal : dimH intFractal = 0 :=
  ((Set.to_countable _).image _).dimH_zero

theorem intBoxCount_le (m : ℕ) : intBoxCount m ≤ 2 * m + 1 := by
  have hsub : boxIndex m '' {n : ℕ | 2 ≤ n} ⊆ ↑(Finset.range (2 * m + 1)) := by
    rintro k ⟨p, hp, rfl⟩
    simp only [Finset.coe_range, Set.mem_Iio]
    exact Nat.lt_succ_of_le (boxIndex_le m p hp)
  have h := Set.ncard_le_ncard hsub (Finset.range (2 * m + 1)).finite_toSet
  simpa [intBoxCount, Set.ncard_coe_finset] using h

theorem one_le_intBoxCount (m : ℕ) : 1 ≤ intBoxCount m := by
  have hfin : (boxIndex m '' {n : ℕ | 2 ≤ n}).Finite := by
    refine Set.Finite.subset (Finset.range (2 * m + 1)).finite_toSet ?_
    rintro k ⟨p, hp, rfl⟩
    simp only [Finset.coe_range, Set.mem_Iio]
    exact Nat.lt_succ_of_le (boxIndex_le m p hp)
  exact (Set.ncard_pos hfin).mpr ⟨boxIndex m 2, ⟨2, le_refl 2, rfl⟩⟩

theorem boxIndex_injOn_int {m Y : ℕ} (hm : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ m) :
    Set.InjOn (boxIndex m) {n : ℕ | 2 ≤ n ∧ n ≤ Y} := by
  rintro p ⟨hp, hpY⟩ q ⟨hq, hqY⟩ hpq
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · have hlt := boxIndex_lt hp hq hpY hqY h hm
    rw [hpq] at hlt
    exact lt_irrefl _ hlt
  · have hlt := boxIndex_lt hq hp hqY hpY h hm
    rw [hpq] at hlt
    exact lt_irrefl _ hlt

theorem ncard_int_interval (Y : ℕ) : {n : ℕ | 2 ≤ n ∧ n ≤ Y}.ncard = Y - 1 := by
  have hset : {n : ℕ | 2 ≤ n ∧ n ≤ Y} = ↑(Finset.Icc 2 Y) := by
    ext n
    simp
  rw [hset, Set.ncard_coe_finset, Nat.card_Icc]
  omega

theorem sub_one_le_intBoxCount {m Y : ℕ} (hm : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ m) :
    Y - 1 ≤ intBoxCount m := by
  have hsub : boxIndex m '' {n : ℕ | 2 ≤ n ∧ n ≤ Y} ⊆ boxIndex m '' {n : ℕ | 2 ≤ n} := by
    rintro k ⟨p, hp, rfl⟩
    exact ⟨p, hp.1, rfl⟩
  have hfin : (boxIndex m '' {n : ℕ | 2 ≤ n}).Finite := by
    refine Set.Finite.subset (Finset.range (2 * m + 1)).finite_toSet ?_
    rintro k ⟨p, hp, rfl⟩
    simp only [Finset.coe_range, Set.mem_Iio]
    exact Nat.lt_succ_of_le (boxIndex_le m p hp)
  calc Y - 1 = {n : ℕ | 2 ≤ n ∧ n ≤ Y}.ncard := (ncard_int_interval Y).symm
    _ = (boxIndex m '' {n : ℕ | 2 ≤ n ∧ n ≤ Y}).ncard :=
        (Set.InjOn.ncard_image (boxIndex_injOn_int hm)).symm
    _ ≤ (boxIndex m '' {n : ℕ | 2 ≤ n}).ncard := Set.ncard_le_ncard hsub hfin
    _ = intBoxCount m := rfl

/-- Without any arithmetic input, the integers occupy at least `m / (2 (log m)^3)` boxes. -/
theorem eventually_intBoxCount_ge :
    ∀ᶠ m : ℕ in atTop, (m : ℝ) / (4 * (Real.log m) ^ 3) ≤ (intBoxCount m : ℝ) := by
  filter_upwards [eventually_log_pow_le (C := 16) (by norm_num) 3, eventually_two_le_log]
    with m h16 hL2
  set L : ℝ := Real.log m with hLdef
  have hL0 : 0 < L := by linarith
  have hL8 : (8 : ℝ) ≤ L ^ 3 := by nlinarith [hL2, sq_nonneg (L - 2), sq_nonneg (L + 2)]
  have hL3 : (0 : ℝ) < L ^ 3 := by linarith
  have hm0 : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  set Y : ℕ := ⌊(m : ℝ) / L ^ 3⌋₊ with hYdef
  have hY0 : (0 : ℝ) ≤ (Y : ℝ) := Nat.cast_nonneg Y
  have hYle : (Y : ℝ) * L ^ 3 ≤ (m : ℝ) := by
    have h := Nat.floor_le (show (0 : ℝ) ≤ (m : ℝ) / L ^ 3 by positivity)
    rw [← hYdef] at h
    rw [← le_div_iff₀ hL3]
    exact h
  have hYgt : (m : ℝ) < ((Y : ℝ) + 1) * L ^ 3 := by
    have h := Nat.lt_floor_add_one ((m : ℝ) / L ^ 3)
    rw [← hYdef] at h
    rw [← div_lt_iff₀ hL3]
    exact h
  have hmL16 : (16 : ℝ) * L ^ 3 ≤ (m : ℝ) := by linarith
  have hY15 : (15 : ℝ) ≤ (Y : ℝ) := by nlinarith [hYgt, hmL16, hL3]
  have hYm : (Y : ℝ) ≤ (m : ℝ) := by nlinarith [hYle, hL8, hY0]
  have hlogY0 : 0 ≤ Real.log Y := Real.log_nonneg (by linarith)
  have hlogYL : Real.log Y ≤ L := by
    rw [hLdef]
    exact Real.log_le_log (by linarith) hYm
  have hsep : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ (m : ℝ) := by
    have h1 : (Real.log Y) ^ 2 ≤ L ^ 2 := by nlinarith
    have h2 : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ 2 * (Y : ℝ) * L ^ 2 := by nlinarith
    have h3 : 2 * (Y : ℝ) * L ^ 2 ≤ (Y : ℝ) * L ^ 3 := by nlinarith [sq_nonneg L, hY0, hL2]
    linarith
  have hcount : (Y - 1 : ℕ) ≤ intBoxCount m := sub_one_le_intBoxCount hsep
  have hcount' : (Y : ℝ) - 1 ≤ (intBoxCount m : ℝ) := by
    have hY1 : 1 ≤ Y := by exact_mod_cast le_trans (by norm_num : (1 : ℝ) ≤ 15) hY15
    have : ((Y - 1 : ℕ) : ℝ) ≤ (intBoxCount m : ℝ) := by exact_mod_cast hcount
    rwa [Nat.cast_sub hY1, Nat.cast_one] at this
  -- `m / (4 L^3) ≤ Y - 1`
  have hm2Y : (m : ℝ) ≤ 2 * (Y : ℝ) * L ^ 3 := by nlinarith [hYgt, hY15, hL3]
  rw [div_le_iff₀ (by positivity)]
  nlinarith [hcount', hm2Y, hL3, hY15]

/-- **The integer fractal also has box dimension `1`.** -/
theorem tendsto_intBoxCount_log_div :
    Tendsto (fun m : ℕ => Real.log (intBoxCount m) / Real.log m) atTop (𝓝 1) := by
  have hupper : ∀ᶠ m : ℕ in atTop,
      Real.log (intBoxCount m) / Real.log m ≤ 1 + Real.log 3 * (1 / Real.log m) := by
    filter_upwards [eventually_two_le_log, eventually_ge_atTop 1] with m hL2 hm1
    have hL0 : 0 < Real.log m := by linarith
    have hm0 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm1
    have hb : (intBoxCount m : ℝ) ≤ 3 * (m : ℝ) := by
      have h := intBoxCount_le m
      have h' : ((intBoxCount m : ℕ) : ℝ) ≤ ((2 * m + 1 : ℕ) : ℝ) := by exact_mod_cast h
      push_cast at h'
      linarith
    have hb0 : (0 : ℝ) < (intBoxCount m : ℝ) := by
      have := one_le_intBoxCount m
      exact_mod_cast lt_of_lt_of_le zero_lt_one (by exact_mod_cast this)
    have hlog : Real.log (intBoxCount m) ≤ Real.log 3 + Real.log m := by
      have := Real.log_le_log hb0 hb
      rwa [Real.log_mul (by norm_num) (by linarith)] at this
    rw [div_le_iff₀ hL0]
    field_simp
    linarith
  have hlower : ∀ᶠ m : ℕ in atTop,
      1 - (Real.log 4 * (1 / Real.log m) + 3 * (Real.log (Real.log m) / Real.log m))
        ≤ Real.log (intBoxCount m) / Real.log m := by
    filter_upwards [eventually_intBoxCount_ge, eventually_two_le_log, eventually_ge_atTop 1]
      with m hge hL2 hm1
    have hL0 : 0 < Real.log m := by linarith
    have hm0 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm1
    have hpos : (0 : ℝ) < (m : ℝ) / (4 * (Real.log m) ^ 3) := by positivity
    have hlog := Real.log_le_log hpos hge
    have hexp : Real.log ((m : ℝ) / (4 * (Real.log m) ^ 3))
        = Real.log m - Real.log 4 - 3 * Real.log (Real.log m) := by
      rw [Real.log_div (ne_of_gt hm0) (by positivity),
        Real.log_mul (by norm_num) (by positivity), Real.log_pow]
      push_cast
      ring
    rw [hexp] at hlog
    rw [le_div_iff₀ hL0]
    field_simp
    linarith
  have h1 : Tendsto (fun m : ℕ => 1 + Real.log 3 * (1 / Real.log m)) atTop (𝓝 1) := by
    have := tendsto_inv_log.const_mul (Real.log 3)
    simpa using tendsto_const_nhds.add this
  have h2 : Tendsto (fun m : ℕ =>
      1 - (Real.log 4 * (1 / Real.log m) + 3 * (Real.log (Real.log m) / Real.log m)))
      atTop (𝓝 1) := by
    have ha := tendsto_inv_log.const_mul (Real.log 4)
    have hb := tendsto_log_log_div_log.const_mul (3 : ℝ)
    have := tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ)) |>.sub (ha.add hb)
    simpa using this
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' h2 h1 hlower hupper

/-- **Dimension blindness.** The prime fractal and the integer fractal have the same
Hausdorff dimension (`0`) and the same box-counting dimension (`1`): no dimension of
the logarithmic embedding can distinguish the primes from all integers, hence none can
encode the twin prime conjecture. -/
theorem dimensions_do_not_see_primality :
    dimH primeFractal = dimH intFractal ∧
      Tendsto (fun m : ℕ => Real.log (boxCount m) / Real.log m) atTop (𝓝 1) ∧
      Tendsto (fun m : ℕ => Real.log (intBoxCount m) / Real.log m) atTop (𝓝 1) :=
  ⟨by rw [dimH_primeFractal, dimH_intFractal], tendsto_boxCount_log_div,
    tendsto_intBoxCount_log_div⟩

end PrimeFractal