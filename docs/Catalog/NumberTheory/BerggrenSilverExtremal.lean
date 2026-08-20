import Catalog.Novelty.HyperbolicBerggrenSilverGrowth

/-!
# Hyperbolic–Pythagorean Geodesics, cycle X: the exact extremal structure of the Berggren tree

Cycle IX (`Novelty/HyperbolicBerggrenSilverGrowth.lean`) identified the metric growth
exponent of the Berggren tree as `log(1+√2)`, via the silver potential
`Φ(m,n) = m + (√2 − 1) n` and the inequality `Φ ≤ (1+√2)^{k+1}` at depth `k`
(`reaches_pot_le`), which is an equality along the pure-`B₂` (Pell) spine.  It left open
two conjectures, I1 and I2.  This file settles I2 affirmatively and in a *sharper* form
than conjectured, and proves the first half of I3; the companion file
`NumberTheory/BerggrenRateSpectrum.lean` refutes I1.

## Main results

* **Binet formulas for the Pell spine** (`mspine_binet`): the depth-`k` node of the
  pure-`B₂` spine is exactly
  `m_k = (λ^{k+2} − μ^{k+2})/(2√2)`, `n_k = (λ^{k+1} − μ^{k+1})/(2√2)`,
  where `λ = 1+√2` and `μ = 1−√2`.
* **Coordinatewise extremality** (`reaches_le_mspine`): every node at depth `k` satisfies
  `m ≤ m_k` *and* `n ≤ n_k`.  Hence the exact maxima at depth `k` of the first coordinate
  (`reaches_fst_le_mspine`) and of the hypotenuse (`reaches_hypot_le_mspine`) are attained
  on the Pell spine, and the maximiser is **unique**
  (`reaches_fst_eq_mspine`, `reaches_hypot_eq_mspine`).
* **Conjecture I2, proved with a quantitative gap** (`reaches_pot_le_gap`,
  `pot_eq_silver_iff`): a node at depth `k` off the Pell spine has
  `Φ ≤ (1+√2)^{k+1} − √2`; so `max_{depth k} Φ = (1+√2)^{k+1}` with a unique maximiser.
* **Conjecture I2's asymptotic constant is wrong** (`max_fst_ratio_tendsto`,
  `max_fst_constant_ne`): `max_{depth k} m / (1+√2)^{k+1} → (2+√2)/4 = 0.85355…`,
  *not* `1/√2 = 0.70710…` as conjectured.
* **Collisions cost depth** (`collision_depth_sum_ge`), the first half of conjecture I3: two
  nodes sharing a hypotenuse `N` have depth sum at least `log N/log(1+√2) − 2`.
-/

namespace HyperbolicBerggrenGeodesics

open Real Filter Topology

noncomputable section

/-! ## Part A. Exact Binet formulas for the Pell spine -/

/-- The conjugate `μ = 1 − √2` of the silver ratio. -/
def silverBar : ℝ := 1 - Real.sqrt 2

theorem silver_sq_eq : silver ^ 2 = 2 * silver + 1 := by
  simp only [silver]
  nlinarith [sqrt_two_sq]

theorem silverBar_sq_eq : silverBar ^ 2 = 2 * silverBar + 1 := by
  simp only [silverBar]
  nlinarith [sqrt_two_sq]

theorem silverBar_abs_lt_one : |silverBar| < 1 := by
  have h := sqrt_two_bounds
  rw [abs_lt]
  constructor <;> · simp only [silverBar]; linarith [h.1, h.2]

theorem mspine_fst_succ (k : ℕ) : (mspine (k + 1)).1 = 2 * (mspine k).1 + (mspine k).2 := rfl

theorem mspine_snd_succ (k : ℕ) : (mspine (k + 1)).2 = (mspine k).1 := rfl

/-- **Binet formulas for the Pell spine.**  The pure-`B₂` node at depth `k` is
`(m_k, n_k)` with `m_k = (λ^{k+2} − μ^{k+2})/(2√2)` and `n_k = (λ^{k+1} − μ^{k+1})/(2√2)`,
`λ = 1+√2`, `μ = 1−√2`.  (First coordinates `2, 5, 12, 29, 70, …` — the even-index Pell
numbers.) -/
theorem mspine_binet (k : ℕ) :
    ((mspine k).1 : ℝ) = (silver ^ (k + 2) - silverBar ^ (k + 2)) / (2 * Real.sqrt 2) ∧
      ((mspine k).2 : ℝ) = (silver ^ (k + 1) - silverBar ^ (k + 1)) / (2 * Real.sqrt 2) := by
  have hsq := sqrt_two_sq
  have hpos : (0 : ℝ) < Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
  induction k with
  | zero =>
      have h1 : ((mspine 0).1 : ℝ) = 2 := by norm_num [mspine]
      have h2 : ((mspine 0).2 : ℝ) = 1 := by norm_num [mspine]
      rw [h1, h2]
      constructor
      · rw [eq_div_iff (by positivity)]
        simp only [silver, silverBar]
        ring
      · rw [eq_div_iff (by positivity)]
        simp only [silver, silverBar]
        ring
  | succ k ih =>
      have hs : silver ^ (k + 3) = 2 * silver ^ (k + 2) + silver ^ (k + 1) := by
        have h1 : silver ^ (k + 3) = silver ^ (k + 1) * silver ^ 2 := by ring
        rw [h1, silver_sq_eq]; ring
      have hb : silverBar ^ (k + 3) = 2 * silverBar ^ (k + 2) + silverBar ^ (k + 1) := by
        have h1 : silverBar ^ (k + 3) = silverBar ^ (k + 1) * silverBar ^ 2 := by ring
        rw [h1, silverBar_sq_eq]; ring
      constructor
      · have hstep : ((mspine (k + 1)).1 : ℝ) = 2 * ((mspine k).1 : ℝ) + ((mspine k).2 : ℝ) := by
          rw [mspine_fst_succ]; push_cast; ring
        rw [hstep, ih.1, ih.2]
        rw [show k + 1 + 2 = k + 3 from rfl, hs, hb]
        field_simp
        ring
      · have hstep : ((mspine (k + 1)).2 : ℝ) = ((mspine k).1 : ℝ) := by
          rw [mspine_snd_succ]
        rw [hstep, ih.1]

/-! ## Part B. Coordinatewise extremality of the Pell spine -/

/-- **The Pell spine dominates every node of the same depth, coordinatewise.** -/
theorem reaches_le_mspine {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    p.1 ≤ (mspine k).1 ∧ p.2 ≤ (mspine k).2 := by
  induction h with
  | root => exact ⟨le_rfl, le_rfl⟩
  | @stepL p k hp ih =>
      have hlt : (mspine k).2 < (mspine k).1 := (mspine_isSeed k).lt
      have hpos : 0 < (mspine k).2 := (mspine_isSeed k).pos
      refine ⟨?_, ?_⟩
      · show 2 * p.1 - p.2 ≤ (mspine (k + 1)).1
        rw [mspine_fst_succ]; omega
      · show p.1 ≤ (mspine (k + 1)).2
        rw [mspine_snd_succ]; omega
  | @stepM p k hp ih =>
      refine ⟨?_, ?_⟩
      · show 2 * p.1 + p.2 ≤ (mspine (k + 1)).1
        rw [mspine_fst_succ]; omega
      · show p.1 ≤ (mspine (k + 1)).2
        rw [mspine_snd_succ]; omega
  | @stepR p k hp ih =>
      have hlt : (mspine k).2 < (mspine k).1 := (mspine_isSeed k).lt
      refine ⟨?_, ?_⟩
      · show p.1 + 2 * p.2 ≤ (mspine (k + 1)).1
        rw [mspine_fst_succ]; omega
      · show p.2 ≤ (mspine (k + 1)).2
        rw [mspine_snd_succ]; omega

/-- **The exact maximum of the first coordinate at depth `k`.** -/
theorem reaches_fst_le_mspine {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) : p.1 ≤ (mspine k).1 :=
  (reaches_le_mspine h).1

/-- **Uniqueness of the maximiser.**  A depth-`k` node whose first coordinate equals the
Pell value `m_k` *is* the Pell node. -/
theorem reaches_fst_eq_mspine {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k)
    (he : p.1 = (mspine k).1) : p = mspine k := by
  cases h with
  | root => rfl
  | @stepL q k hq =>
      exfalso
      have hd := reaches_le_mspine hq
      have hs := reaches_isSeed hq
      have hlt : (mspine k).2 < (mspine k).1 := (mspine_isSeed k).lt
      have hpos : 0 < (mspine k).2 := (mspine_isSeed k).pos
      have hq2 : 0 < q.2 := hs.pos
      have hq3 : q.2 < q.1 := hs.lt
      have h1 : (seedL q).1 = 2 * q.1 - q.2 := rfl
      rw [h1, mspine_fst_succ] at he
      omega
  | @stepM q k hq =>
      have hd := reaches_le_mspine hq
      have h1 : (seedM q).1 = 2 * q.1 + q.2 := rfl
      rw [h1, mspine_fst_succ] at he
      have hq1 : q.1 = (mspine k).1 := by omega
      have hq2 : q.2 = (mspine k).2 := by omega
      have : q = mspine k := Prod.ext hq1 hq2
      rw [this]
      rfl
  | @stepR q k hq =>
      exfalso
      have hd := reaches_le_mspine hq
      have hlt : (mspine k).2 < (mspine k).1 := (mspine_isSeed k).lt
      have h1 : (seedR q).1 = q.1 + 2 * q.2 := rfl
      rw [h1, mspine_fst_succ] at he
      omega

/-- **The exact maximum of the hypotenuse at depth `k`.** -/
theorem reaches_hypot_le_mspine {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    hypot p ≤ hypot (mspine k) := by
  obtain ⟨h1, h2⟩ := reaches_le_mspine h
  have s1 : p.1 ^ 2 ≤ (mspine k).1 ^ 2 := Nat.pow_le_pow_left h1 2
  have s2 : p.2 ^ 2 ≤ (mspine k).2 ^ 2 := Nat.pow_le_pow_left h2 2
  simp only [hypot]
  omega

/-- **Uniqueness of the hypotenuse maximiser at each depth.** -/
theorem reaches_hypot_eq_mspine {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k)
    (he : hypot p = hypot (mspine k)) : p = mspine k := by
  obtain ⟨h1, h2⟩ := reaches_le_mspine h
  have s1 : p.1 ^ 2 ≤ (mspine k).1 ^ 2 := Nat.pow_le_pow_left h1 2
  have s2 : p.2 ^ 2 ≤ (mspine k).2 ^ 2 := Nat.pow_le_pow_left h2 2
  have hsq : p.1 ^ 2 = (mspine k).1 ^ 2 := by
    simp only [hypot] at he; omega
  have : p.1 = (mspine k).1 := by nlinarith [hsq]
  exact reaches_fst_eq_mspine h this

/-! ## Part C. Conjecture I2: the silver bound is exact, with a quantitative gap -/

/-- **Strict contraction of the potential under `B₁`,** with the explicit slack `2n ≥ 2`. -/
theorem pot_seedL_le_gap {m n : ℕ} (h : IsSeed m n) :
    pot (seedL (m, n)) ≤ silver * pot (m, n) - 2 := by
  have hnm : (n : ℝ) < (m : ℝ) := by exact_mod_cast h.lt
  have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast h.pos
  have hltnat := h.lt
  have hcast : ((2 * m - n : ℕ) : ℝ) = 2 * (m : ℝ) - (n : ℝ) := by
    have : n ≤ 2 * m := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hs := sqrt_two_sq
  simp only [pot, seedL, silver, hcast]
  nlinarith [hs, hn1]

/-- **Strict contraction of the potential under `B₃`,** with the explicit slack
`√2 (m − n) ≥ √2`. -/
theorem pot_seedR_le_gap {m n : ℕ} (h : IsSeed m n) :
    pot (seedR (m, n)) ≤ silver * pot (m, n) - Real.sqrt 2 := by
  have hnm : (n : ℝ) + 1 ≤ (m : ℝ) := by exact_mod_cast h.lt
  have hs := sqrt_two_sq
  have h2 := sqrt_two_bounds.1
  simp only [pot, seedR, silver]
  push_cast
  nlinarith

/-- **Conjecture I2, with a gap.**  Every node at depth `k` *other than* the Pell node has
silver potential at most `(1+√2)^{k+1} − √2`.  Together with `mspine_pot_eq` this says
`max_{depth k} Φ = (1+√2)^{k+1}`, attained only on the pure-`B₂` spine. -/
theorem reaches_pot_le_gap {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) (hne : p ≠ mspine k) :
    pot p ≤ silver ^ (k + 1) - Real.sqrt 2 := by
  induction h with
  | root => exact absurd rfl hne
  | @stepL p k hp ih =>
      have hs := reaches_isSeed hp
      have h1 : pot (seedL p) ≤ silver * pot p - 2 := by
        have := pot_seedL_le_gap (m := p.1) (n := p.2) hs
        simpa using this
      have hle := reaches_pot_le hp
      have h2 : (1 : ℝ) ≤ Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
      have h3 : (Real.sqrt 2 : ℝ) ≤ 2 := by linarith [sqrt_two_bounds.2]
      have : silver * pot p ≤ silver ^ (k + 1 + 1) := by
        calc silver * pot p ≤ silver * silver ^ (k + 1) :=
              mul_le_mul_of_nonneg_left hle silver_pos.le
          _ = silver ^ (k + 1 + 1) := by ring
      linarith
  | @stepM p k hp ih =>
      by_cases hp0 : p = mspine k
      · exfalso
        apply hne
        rw [hp0]
        rfl
      · have hih := ih hp0
        have h1 : pot (seedM p) = silver * pot p := by
          have := pot_seedM_eq p.1 p.2
          simpa using this
        have hsil : (1 : ℝ) < silver := one_lt_silver
        have hsq : (0 : ℝ) < Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
        have : silver * pot p ≤ silver * (silver ^ (k + 1) - Real.sqrt 2) :=
          mul_le_mul_of_nonneg_left hih silver_pos.le
        have hexp : silver * (silver ^ (k + 1) - Real.sqrt 2)
            = silver ^ (k + 1 + 1) - silver * Real.sqrt 2 := by ring
        nlinarith
  | @stepR p k hp ih =>
      have hs := reaches_isSeed hp
      have h1 : pot (seedR p) ≤ silver * pot p - Real.sqrt 2 := by
        have := pot_seedR_le_gap (m := p.1) (n := p.2) hs
        simpa using this
      have hle := reaches_pot_le hp
      have : silver * pot p ≤ silver ^ (k + 1 + 1) := by
        calc silver * pot p ≤ silver * silver ^ (k + 1) :=
              mul_le_mul_of_nonneg_left hle silver_pos.le
          _ = silver ^ (k + 1 + 1) := by ring
      linarith

/-- **The silver bound characterises the Pell spine.**  A depth-`k` node attains the bound
`Φ = (1+√2)^{k+1}` if and only if it is the depth-`k` node of the pure-`B₂` spine. -/
theorem pot_eq_silver_iff {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    pot p = silver ^ (k + 1) ↔ p = mspine k := by
  constructor
  · intro heq
    by_contra hne
    have := reaches_pot_le_gap h hne
    have hsq : (0 : ℝ) < Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
    rw [heq] at this
    linarith
  · intro hp
    rw [hp]
    exact mspine_pot_eq k

/-! ## Part D. The true asymptotic constant of the maximal first coordinate -/

/-- The exact ratio: `m_k / λ^{k+1} = λ/(2√2) − μ^{k+2}/(2√2 λ^{k+1})`. -/
theorem mspine_fst_div_silver (k : ℕ) :
    ((mspine k).1 : ℝ) / silver ^ (k + 1)
      = (2 + Real.sqrt 2) / 4 - silverBar ^ 2 / (2 * Real.sqrt 2 * silver) * (silverBar / silver) ^ k := by
  have hsq : (0 : ℝ) < Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
  have hs2 := sqrt_two_sq
  have hsil : (0 : ℝ) < silver := silver_pos
  have hsilne : silver ≠ 0 := ne_of_gt hsil
  have hsk : silver ^ k ≠ 0 := ne_of_gt (pow_pos hsil k)
  have hsqne : Real.sqrt 2 ≠ 0 := ne_of_gt hsq
  have key : ((silver ^ (k + 2) - silverBar ^ (k + 2)) / (2 * Real.sqrt 2)) / silver ^ (k + 1)
      = silver / (2 * Real.sqrt 2)
        - silverBar ^ 2 / (2 * Real.sqrt 2 * silver) * (silverBar / silver) ^ k := by
    rw [div_pow]
    field_simp
    ring
  have hconst : silver / (2 * Real.sqrt 2) = (2 + Real.sqrt 2) / 4 := by
    rw [div_eq_div_iff (by positivity) (by norm_num)]
    simp only [silver]
    nlinarith [hs2]
  rw [(mspine_binet k).1, key, hconst]

/-- **The true asymptotic constant.**  The maximal first coordinate at depth `k` satisfies
`max_{depth k} m / (1+√2)^{k+1} → (2+√2)/4 = 0.853553…`.  Conjecture I2 predicted the
constant `1/√2 = 0.707…`; that prediction is false (`max_fst_constant_ne`). -/
theorem max_fst_ratio_tendsto :
    Tendsto (fun k : ℕ => ((mspine k).1 : ℝ) / silver ^ (k + 1)) atTop
      (𝓝 ((2 + Real.sqrt 2) / 4)) := by
  have hsq : (0 : ℝ) < Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
  have hsil : (1 : ℝ) < silver := one_lt_silver
  have habs : |silverBar / silver| < 1 := by
    rw [abs_div, abs_of_pos (show (0:ℝ) < silver from silver_pos)]
    rw [div_lt_one (show (0:ℝ) < silver from silver_pos)]
    exact lt_trans silverBar_abs_lt_one hsil
  have hpow : Tendsto (fun k : ℕ => (silverBar / silver) ^ k) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one habs
  have hmul : Tendsto
      (fun k : ℕ => silverBar ^ 2 / (2 * Real.sqrt 2 * silver) * (silverBar / silver) ^ k)
      atTop (𝓝 0) := by
    simpa using hpow.const_mul (silverBar ^ 2 / (2 * Real.sqrt 2 * silver))
  have h2 : Tendsto
      (fun k : ℕ => (2 + Real.sqrt 2) / 4
        - silverBar ^ 2 / (2 * Real.sqrt 2 * silver) * (silverBar / silver) ^ k) atTop
      (𝓝 ((2 + Real.sqrt 2) / 4 - 0)) :=
    Tendsto.sub tendsto_const_nhds hmul
  simp only [sub_zero] at h2
  refine h2.congr (fun k => ?_)
  exact (mspine_fst_div_silver k).symm

/-- **Conjecture I2's asymptotic constant is refuted.**  `(2+√2)/4 ≠ 1/√2`; indeed the true
constant is strictly larger. -/
theorem max_fst_constant_ne : (1 : ℝ) / Real.sqrt 2 < (2 + Real.sqrt 2) / 4 := by
  have hsq : (0 : ℝ) < Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
  have h2 := sqrt_two_sq
  rw [div_lt_div_iff₀ hsq (by norm_num)]
  nlinarith [sqrt_two_bounds.1, sqrt_two_bounds.2]

/-! ## Part H. Conjecture I3, first half: a collision costs depth -/

/-- **Collisions cost depth.**  If two Berggren nodes (in particular, the two members of a
hypotenuse collision) both have hypotenuse `N`, then the *sum* of their depths is at least
`log N / log(1+√2) − 2`.  Distinctness of the two nodes is not needed for this bound. -/
theorem collision_depth_sum_ge {p q : ℕ × ℕ} {k l N : ℕ} (hp : Reaches p k) (hq : Reaches q l)
    (hN : 0 < N) (hpN : N ≤ hypot p) (hqN : N ≤ hypot q) :
    (Real.log N - Real.log 2) / Real.log silver - 2 ≤ (k : ℝ) + (l : ℝ) := by
  have h1 := depth_ge_of_hypot hp hN hpN
  have h2 := depth_ge_of_hypot hq hN hqN
  have hlog := log_silver_pos
  have hsplit : (Real.log N - Real.log 2) / Real.log silver
      = 2 * ((Real.log N - Real.log 2) / (2 * Real.log silver)) := by
    field_simp
  rw [hsplit]
  linarith

end

end HyperbolicBerggrenGeodesics