import NumberTheory.PrimeFractalChebyshev
import NumberTheory.PrimeFractalHausdorff

/-!
# The box-counting dimension of the prime fractal is exactly `1`

`NumberTheory.PrimeFractalHausdorff` shows that the Hausdorff dimension of the
prime fractal `{1 / log p : p prime} ⊆ ℝ` is `0`, refuting the mission
conjecture.  Here we prove the *positive* half of the story: the notion that
actually sees the conjectured value is the **box-counting (Minkowski)
dimension**, and for the prime fractal it equals `1` on the nose.

At scale `1/m` we count the boxes `[k/m, (k+1)/m)` that meet the prime fractal,
i.e. the cardinality `boxCount m` of the set of values `⌊m / log p⌋` over primes
`p`.  The two halves are:

* `boxCount_le` : `boxCount m ≤ 2m + 1` — a trivial upper bound valid for any
  subset of an interval, which is what forces the dimension to be `≤ 1`.  In
  particular *no* configuration of primes — twin primes included — can produce
  a dimension `1 + ε` with `ε > 0`.
* `eventually_boxCount_ge` : `boxCount m ≥ m / (16 (log m)^4)`.  This is the
  arithmetic input: it uses the Chebyshev-type lower bound
  `PrimeFractal.le_primeCounting_mul_log` together with the observation that
  `p ↦ ⌊m / log p⌋` is injective on primes `p ≤ Y` as soon as
  `2 Y (log Y)^2 ≤ m` (primes below `Y` are spread more than `1/m` apart in the
  `d`-metric).

Together they give `tendsto_boxCount_log_div`: `log (boxCount m) / log m → 1`,
hence `upperBoxDim = lowerBoxDim = 1` (`upperBoxDim_eq_one`,
`lowerBoxDim_eq_one`), while the Hausdorff dimension is `0`
(`dimH_lt_boxDim`).  The prime fractal is therefore a *dimension-irregular*
set: box and Hausdorff dimensions disagree maximally.
-/

namespace PrimeFractal

open Filter Topology

/-- Index of the box of size `1/m` containing the point `1 / log p`. -/
noncomputable def boxIndex (m p : ℕ) : ℕ := ⌊(m : ℝ) * logInv p⌋₊

/-- The set of boxes of size `1/m` that meet the prime fractal. -/
noncomputable def occupiedBoxes (m : ℕ) : Set ℕ := boxIndex m '' {p : ℕ | p.Prime}

/-- The box-counting function of the prime fractal at scale `1/m`. -/
noncomputable def boxCount (m : ℕ) : ℕ := (occupiedBoxes m).ncard

/-! ### Elementary bounds -/

theorem logInv_le_two {p : ℕ} (hp : 2 ≤ p) : logInv p ≤ 2 := by
  have hp2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hlog : Real.log 2 ≤ Real.log p := Real.log_le_log (by norm_num) hp2
  have h2 : (1 : ℝ) / 2 < Real.log 2 := by
    have := Real.log_two_gt_d9
    linarith
  have hpos : 0 < Real.log p := by linarith
  rw [logInv, div_le_iff₀ hpos]
  linarith

theorem boxIndex_le (m p : ℕ) (hp : 2 ≤ p) : boxIndex m p ≤ 2 * m := by
  have hle : (m : ℝ) * logInv p ≤ ((2 * m : ℕ) : ℝ) := by
    have h2 := logInv_le_two hp
    have hm : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
    push_cast
    nlinarith
  simpa using Nat.floor_le_of_le hle

theorem occupiedBoxes_subset (m : ℕ) : occupiedBoxes m ⊆ ↑(Finset.range (2 * m + 1)) := by
  rintro k ⟨p, hp, rfl⟩
  simp only [Finset.coe_range, Set.mem_Iio]
  exact Nat.lt_succ_of_le (boxIndex_le m p hp.two_le)

theorem occupiedBoxes_finite (m : ℕ) : (occupiedBoxes m).Finite :=
  Set.Finite.subset (Finset.range (2 * m + 1)).finite_toSet (occupiedBoxes_subset m)

/-- The trivial upper bound on the box count: at scale `1/m` the prime fractal, which
lives inside `[0, 2]`, can meet at most `2m + 1` boxes. -/
theorem boxCount_le (m : ℕ) : boxCount m ≤ 2 * m + 1 := by
  have h := Set.ncard_le_ncard (occupiedBoxes_subset m) (Finset.range (2 * m + 1)).finite_toSet
  simpa [boxCount, Set.ncard_coe_finset] using h

theorem one_le_boxCount (m : ℕ) : 1 ≤ boxCount m := by
  have hmem : boxIndex m 2 ∈ occupiedBoxes m := ⟨2, Nat.prime_two, rfl⟩
  have hne : (occupiedBoxes m).Nonempty := ⟨_, hmem⟩
  exact (Set.ncard_pos (occupiedBoxes_finite m)).mpr hne

/-! ### Separation of primes in the `d`-metric -/

/-- Consecutive integers `≥ 2` have logarithms at distance at least `1/(2p)`. -/
theorem log_sub_log_ge {p q : ℕ} (hp : 2 ≤ p) (hpq : p < q) :
    1 / (2 * (p : ℝ)) ≤ Real.log q - Real.log p := by
  have hP : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hQ : (p : ℝ) + 1 ≤ (q : ℝ) := by exact_mod_cast hpq
  set P : ℝ := (p : ℝ)
  set u : ℝ := 1 / (2 * P) with hu
  have hP0 : 0 < P := by linarith
  have hu0 : 0 < u := by positivity
  have hu1 : u ≤ 1 / 4 := by
    rw [hu]
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    linarith
  -- `exp u ≤ 1 / (1 - u)`
  have hexp : (1 - u) * Real.exp u ≤ 1 := by
    have h := Real.add_one_le_exp (-u)
    rw [Real.exp_neg] at h
    have hpos : 0 < Real.exp u := Real.exp_pos u
    have h' : (1 - u) ≤ (Real.exp u)⁻¹ := by linarith
    calc (1 - u) * Real.exp u ≤ (Real.exp u)⁻¹ * Real.exp u := by nlinarith
      _ = 1 := inv_mul_cancel₀ (ne_of_gt hpos)
  -- hence `P * exp u ≤ Q`
  have hkey : P * Real.exp u ≤ (q : ℝ) := by
    have h1u : 0 < 1 - u := by linarith
    have hPQ : P ≤ (q : ℝ) * (1 - u) := by
      have hexpand : (q : ℝ) * (1 - u) = (q : ℝ) - (q : ℝ) * (1 / (2 * P)) := by
        rw [hu]; ring
      have hqu : (q : ℝ) * (1 / (2 * P)) ≤ (q : ℝ) - P := by
        rw [mul_one_div, div_le_iff₀ (by positivity)]
        nlinarith [hQ, hP0]
      rw [hexpand]
      linarith
    nlinarith [Real.exp_pos u, hexp, hPQ, h1u]
  have hlog : Real.log (P * Real.exp u) ≤ Real.log q :=
    Real.log_le_log (by positivity) hkey
  rw [Real.log_mul (by positivity) (Real.exp_ne_zero u), Real.log_exp] at hlog
  linarith

/-- **Key separation estimate.** If `2 Y (log Y)^2 ≤ m` then distinct primes `p < q ≤ Y`
land in distinct boxes of size `1/m`. -/
theorem boxIndex_lt {m Y p q : ℕ} (hp : 2 ≤ p) (hq : 2 ≤ q) (hpY : p ≤ Y) (hqY : q ≤ Y)
    (hlt : p < q) (hm : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ m) :
    boxIndex m q < boxIndex m p := by
  have hP2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hQ2 : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
  have hpq' : (p : ℝ) < (q : ℝ) := by exact_mod_cast hlt
  set a : ℝ := Real.log p with ha
  set b : ℝ := Real.log q with hb
  set L : ℝ := Real.log Y with hL
  have ha0 : 0 < a := Real.log_pos (by linarith)
  have hab : a < b := Real.log_lt_log (by linarith) hpq'
  have hb0 : 0 < b := lt_trans ha0 hab
  have hbL : b ≤ L := Real.log_le_log (by linarith) (by exact_mod_cast hqY)
  have haL : a ≤ L := le_of_lt (lt_of_lt_of_le hab hbL)
  have hL0 : 0 < L := lt_of_lt_of_le ha0 haL
  have hsep : 1 / (2 * (p : ℝ)) ≤ b - a := log_sub_log_ge hp hlt
  have hPY : (p : ℝ) ≤ (Y : ℝ) := by exact_mod_cast hpY
  have habL : a * b ≤ L ^ 2 := by nlinarith
  have hmP : 2 * (p : ℝ) * (a * b) ≤ (m : ℝ) := by nlinarith
  -- `m * (1/a - 1/b) ≥ 1`
  have hstep : 1 ≤ (m : ℝ) * (1 / a - 1 / b) := by
    have hdiff : 1 / a - 1 / b = (b - a) / (a * b) := by
      field_simp
    rw [hdiff, ← mul_div_assoc, le_div_iff₀ (by positivity)]
    have hP0 : (0 : ℝ) < (p : ℝ) := by linarith
    have h1 : 2 * (p : ℝ) * (b - a) ≥ 1 := by
      rw [ge_iff_le, ← div_le_iff₀' (by positivity)]
      simpa [one_div] using hsep
    nlinarith [hmP, h1, mul_pos ha0 hb0]
  have hqnn : 0 ≤ (m : ℝ) * logInv q := by
    have : 0 ≤ logInv q := le_of_lt (by
      have : 0 < Real.log q := hb0
      simpa [logInv] using one_div_pos.mpr this)
    positivity
  have hge : (m : ℝ) * logInv q + 1 ≤ (m : ℝ) * logInv p := by
    simp only [logInv]
    nlinarith [hstep]
  have hfl := Nat.floor_le_floor hge
  rw [Nat.floor_add_one hqnn] at hfl
  simp only [boxIndex]
  exact Nat.lt_of_succ_le hfl

theorem boxIndex_injOn {m Y : ℕ} (hm : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ m) :
    Set.InjOn (boxIndex m) {p : ℕ | p.Prime ∧ p ≤ Y} := by
  rintro p ⟨hp, hpY⟩ q ⟨hq, hqY⟩ hpq
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · have hlt := boxIndex_lt hp.two_le hq.two_le hpY hqY h hm
    rw [hpq] at hlt
    exact lt_irrefl _ hlt
  · have hlt := boxIndex_lt hq.two_le hp.two_le hqY hpY h hm
    rw [hpq] at hlt
    exact lt_irrefl _ hlt

/-! ### From Chebyshev to a lower bound on the box count -/

theorem primeCounting_eq_ncard (Y : ℕ) :
    {p : ℕ | p.Prime ∧ p ≤ Y}.ncard = Nat.primeCounting Y := by
  have hset : {p : ℕ | p.Prime ∧ p ≤ Y} = ↑(Nat.primesBelow (Y + 1)) := by
    ext p
    simp only [Set.mem_setOf_eq, Finset.mem_coe, Nat.mem_primesBelow, Nat.lt_succ_iff]
    exact ⟨fun h => ⟨h.2, h.1⟩, fun h => ⟨h.2, h.1⟩⟩
  rw [hset, Set.ncard_coe_finset, Nat.primesBelow_card_eq_primeCounting']
  simpa using (Nat.primeCounting_sub_one (Y + 1)).symm

/-- Every prime `≤ Y` occupies its own box, provided `2 Y (log Y)^2 ≤ m`. -/
theorem primeCounting_le_boxCount {m Y : ℕ} (hm : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ m) :
    Nat.primeCounting Y ≤ boxCount m := by
  have hsub : boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ Y} ⊆ occupiedBoxes m := by
    rintro k ⟨p, hp, rfl⟩
    exact ⟨p, hp.1, rfl⟩
  have h1 : (boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ Y}).ncard = Nat.primeCounting Y := by
    rw [Set.InjOn.ncard_image (boxIndex_injOn hm), primeCounting_eq_ncard]
  calc Nat.primeCounting Y = (boxIndex m '' {p : ℕ | p.Prime ∧ p ≤ Y}).ncard := h1.symm
    _ ≤ (occupiedBoxes m).ncard := Set.ncard_le_ncard hsub (occupiedBoxes_finite m)
    _ = boxCount m := rfl

/-! ### Asymptotics -/

/-- Powers of `log` are eventually dominated by the identity, in the form we need. -/
theorem eventually_log_pow_le {C : ℝ} (hC : 0 < C) (k : ℕ) :
    ∀ᶠ m : ℕ in atTop, C * (Real.log m) ^ k ≤ (m : ℝ) := by
  have hreal : ∀ᶠ x : ℝ in atTop, C * (Real.log x) ^ k ≤ x := by
    have h := (Real.isLittleO_pow_log_id_atTop (n := k)).def (c := 1 / C) (by positivity)
    filter_upwards [h, eventually_ge_atTop (1 : ℝ)] with x hx hx1
    have hlog : 0 ≤ Real.log x := Real.log_nonneg hx1
    have hidx : (0 : ℝ) ≤ id x := by simpa using (by linarith : (0 : ℝ) ≤ x)
    rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_nonneg (by positivity),
      abs_of_nonneg hidx] at hx
    have : C * (Real.log x ^ k) ≤ C * ((1 / C) * x) := by
      exact mul_le_mul_of_nonneg_left hx (le_of_lt hC)
    calc C * Real.log x ^ k ≤ C * ((1 / C) * x) := this
      _ = x := by field_simp
  exact (tendsto_natCast_atTop_atTop (R := ℝ)).eventually hreal

theorem eventually_two_le_log : ∀ᶠ m : ℕ in atTop, (2 : ℝ) ≤ Real.log m :=
  (tendsto_natCast_atTop_atTop (R := ℝ)).eventually
    (Real.tendsto_log_atTop.eventually_ge_atTop 2)

/-- **The arithmetic heart.** At scale `1/m` the primes occupy at least
`m / (16 (log m)^4)` boxes. -/
theorem eventually_boxCount_ge :
    ∀ᶠ m : ℕ in atTop, (m : ℝ) / (16 * (Real.log m) ^ 4) ≤ (boxCount m : ℝ) := by
  filter_upwards [eventually_log_pow_le (C := 16) (by norm_num) 3, eventually_two_le_log]
    with m h16 hL2
  set L : ℝ := Real.log m with hLdef
  have hL0 : 0 < L := by linarith
  have hL8 : (8 : ℝ) ≤ L ^ 3 := by
    nlinarith [hL2, sq_nonneg (L - 2), sq_nonneg (L + 2)]
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
  have hY8 : 8 ≤ Y := by exact_mod_cast le_trans (by norm_num : (8 : ℝ) ≤ 15) hY15
  have hYm : (Y : ℝ) ≤ (m : ℝ) := by nlinarith [hYle, hL8, hY0]
  have hlogY0 : 0 ≤ Real.log Y := Real.log_nonneg (by linarith)
  have hlogYL : Real.log Y ≤ L := by
    rw [hLdef]
    exact Real.log_le_log (by linarith) hYm
  -- the separation hypothesis `2 Y (log Y)^2 ≤ m`
  have hsep : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ (m : ℝ) := by
    have h1 : (Real.log Y) ^ 2 ≤ L ^ 2 := by nlinarith
    have h2 : 2 * (Y : ℝ) * (Real.log Y) ^ 2 ≤ 2 * (Y : ℝ) * L ^ 2 := by nlinarith
    have h3 : 2 * (Y : ℝ) * L ^ 2 ≤ (Y : ℝ) * L ^ 3 := by nlinarith [sq_nonneg L, hY0, hL2]
    linarith
  -- Chebyshev's lower bound applied at `Y`
  have hcheb := le_primeCounting_mul_log Y hY8
  have hpi : (Nat.primeCounting Y : ℝ) ≤ (boxCount m : ℝ) := by
    exact_mod_cast primeCounting_le_boxCount hsep
  have hpi0 : (0 : ℝ) ≤ (Nat.primeCounting Y : ℝ) := Nat.cast_nonneg _
  have hchebL : (Y : ℝ) ≤ 8 * (Nat.primeCounting Y : ℝ) * L := by
    nlinarith [hcheb, hlogYL, hpi0]
  -- `m ≤ 2 Y L^3 ≤ 16 π(Y) L^4 ≤ 16 boxCount m L^4`
  have hm2Y : (m : ℝ) ≤ 2 * (Y : ℝ) * L ^ 3 := by nlinarith [hYgt, hY15, hL3]
  have hmfin : (m : ℝ) ≤ 16 * (Nat.primeCounting Y : ℝ) * L ^ 4 := by
    nlinarith [hchebL, hL3, hm2Y]
  rw [div_le_iff₀ (by positivity)]
  have hL4 : (0 : ℝ) < L ^ 4 := by positivity
  have hmul : (Nat.primeCounting Y : ℝ) * L ^ 4 ≤ (boxCount m : ℝ) * L ^ 4 := by
    nlinarith [hpi, hL4]
  linarith [hmfin, hmul]

theorem tendsto_log_log_div_log : Tendsto (fun m : ℕ => Real.log (Real.log m) / Real.log m)
    atTop (𝓝 0) := by
  have h : Tendsto (fun x : ℝ => Real.log x / x) atTop (𝓝 0) :=
    Real.isLittleO_log_id_atTop.tendsto_div_nhds_zero
  have hlog : Tendsto (fun m : ℕ => Real.log m) atTop atTop :=
    Real.tendsto_log_atTop.comp (tendsto_natCast_atTop_atTop (R := ℝ))
  exact h.comp hlog

theorem tendsto_inv_log : Tendsto (fun m : ℕ => 1 / Real.log m) atTop (𝓝 0) := by
  have hlog : Tendsto (fun m : ℕ => Real.log m) atTop atTop :=
    Real.tendsto_log_atTop.comp (tendsto_natCast_atTop_atTop (R := ℝ))
  simpa [one_div] using hlog.inv_tendsto_atTop

/-- **Main theorem: the box-counting dimension of the prime fractal is `1`.** -/
theorem tendsto_boxCount_log_div :
    Tendsto (fun m : ℕ => Real.log (boxCount m) / Real.log m) atTop (𝓝 1) := by
  have hupper : ∀ᶠ m : ℕ in atTop,
      Real.log (boxCount m) / Real.log m ≤ 1 + Real.log 3 * (1 / Real.log m) := by
    filter_upwards [eventually_two_le_log, eventually_ge_atTop 1] with m hL2 hm1
    have hL0 : 0 < Real.log m := by linarith
    have hm0 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm1
    have hb : (boxCount m : ℝ) ≤ 3 * (m : ℝ) := by
      have := boxCount_le m
      have : ((boxCount m : ℕ) : ℝ) ≤ ((2 * m + 1 : ℕ) : ℝ) := by exact_mod_cast this
      push_cast at this
      linarith
    have hb0 : (0 : ℝ) < (boxCount m : ℝ) := by
      have := one_le_boxCount m
      exact_mod_cast lt_of_lt_of_le zero_lt_one (by exact_mod_cast this)
    have hlog : Real.log (boxCount m) ≤ Real.log 3 + Real.log m := by
      have := Real.log_le_log hb0 hb
      rwa [Real.log_mul (by norm_num) (by linarith)] at this
    rw [div_le_iff₀ hL0]
    field_simp
    linarith
  have hlower : ∀ᶠ m : ℕ in atTop,
      1 - (Real.log 16 * (1 / Real.log m) + 4 * (Real.log (Real.log m) / Real.log m))
        ≤ Real.log (boxCount m) / Real.log m := by
    filter_upwards [eventually_boxCount_ge, eventually_two_le_log, eventually_ge_atTop 1]
      with m hge hL2 hm1
    have hL0 : 0 < Real.log m := by linarith
    have hm0 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm1
    have hpos : (0 : ℝ) < (m : ℝ) / (16 * (Real.log m) ^ 4) := by positivity
    have hlog := Real.log_le_log hpos hge
    have hexp : Real.log ((m : ℝ) / (16 * (Real.log m) ^ 4))
        = Real.log m - Real.log 16 - 4 * Real.log (Real.log m) := by
      rw [Real.log_div (ne_of_gt hm0) (by positivity),
        Real.log_mul (by norm_num) (by positivity), Real.log_pow]
      push_cast
      ring
    rw [hexp] at hlog
    rw [le_div_iff₀ hL0]
    field_simp
    linarith
  have h1 : Tendsto (fun m : ℕ => 1 + Real.log 3 * (1 / Real.log m)) atTop (𝓝 1) := by
    have := (tendsto_inv_log.const_mul (Real.log 3))
    simpa using tendsto_const_nhds.add this
  have h2 : Tendsto (fun m : ℕ =>
      1 - (Real.log 16 * (1 / Real.log m) + 4 * (Real.log (Real.log m) / Real.log m)))
      atTop (𝓝 1) := by
    have ha := tendsto_inv_log.const_mul (Real.log 16)
    have hb := tendsto_log_log_div_log.const_mul (4 : ℝ)
    have := tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ)) |>.sub (ha.add hb)
    simpa using this
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' h2 h1 hlower hupper

/-- The upper box-counting (Minkowski) dimension of the prime fractal. -/
noncomputable def upperBoxDim : ℝ := limsup (fun m : ℕ => Real.log (boxCount m) / Real.log m) atTop

/-- The lower box-counting (Minkowski) dimension of the prime fractal. -/
noncomputable def lowerBoxDim : ℝ := liminf (fun m : ℕ => Real.log (boxCount m) / Real.log m) atTop

theorem upperBoxDim_eq_one : upperBoxDim = 1 := tendsto_boxCount_log_div.limsup_eq

theorem lowerBoxDim_eq_one : lowerBoxDim = 1 := tendsto_boxCount_log_div.liminf_eq

/-- **The box dimension is exactly `1`: no `ε` of twin primes.** -/
theorem boxDim_eq_one : upperBoxDim = 1 ∧ lowerBoxDim = 1 :=
  ⟨upperBoxDim_eq_one, lowerBoxDim_eq_one⟩

/-- **Dimension irregularity.** The Hausdorff dimension (`0`) is strictly smaller than the
box-counting dimension (`1`): the prime fractal is not a self-similar/Ahlfors-regular set. -/
theorem dimH_lt_boxDim : (dimH primeFractal).toReal < upperBoxDim := by
  rw [dimH_primeFractal, upperBoxDim_eq_one]
  norm_num

end PrimeFractal