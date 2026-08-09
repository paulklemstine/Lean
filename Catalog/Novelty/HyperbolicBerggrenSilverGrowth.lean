import Geometry.HyperbolicBerggrenTreeDepth

/-!
# Hyperbolic–Pythagorean Geodesics, cycle IX: the silver growth rate of the Berggren tree

Cycle VIII introduced the depth function `Reaches p k` and proved the one-sided comparison
`2 d(i, z) ≤ log 32 + k log 9`, i.e. `d ≤ k log 3 + O(1)`, together with the matching
*existence* of a branch (the Pell spine of pure `B₂` moves) along which `d ≥ k log 2`.
Conjecture **H2** of that cycle asserted that along every infinite Berggren path which uses
the parabolic move `B₁` at most a fraction `1 − δ` of the time the ratio `d(i, z_k)/k`
converges to a limit in `[δ log 2, log 3]`, the extreme value `log 3` being attained by the
pure-`B₃` path.

This file settles the depth-versus-distance question completely, and **refutes H2 twice
over**.

## Main results

* `dist_window_log_fst` : for every Euclid seed, `log m ≤ d(i, z(m,n)) ≤ log m + log 2`.
  The hyperbolic distance is the logarithm of the *first seed coordinate* to within
  `log 2` — a cleaner statement than the `½ log c` of cycles I–II, and the exact bridge
  between the metric and the arithmetic growth of the tree.
* `pot_step_le` / `reaches_pot_le` : the **silver potential**
  `Φ(m,n) = m + (√2 − 1) n` satisfies `Φ(B_i v) ≤ (1 + √2) Φ(v)` for all three Berggren
  moves and every seed, with *equality* for `B₂`.  Hence `Φ ≤ (1+√2)^{k+1}` at depth `k`.
* `dist_le_silver_depth` : **the sharp upper envelope**
  `d(i, z) ≤ (k+1) log(1+√2) + log 2` at depth `k`.  This replaces the cycle-VIII constant
  `log 3 = 1.0986…` by `log(1+√2) = 0.8813…`, and the new constant is optimal.
* `mspine_pot_eq`, `mspine_dist_ge_silver` : along the pure-`B₂` spine the potential is
  *exactly* `(1+√2)^{k+1}`, so `d ≥ (k+1) log(1+√2) − ½ log 2`.
* `mspine_rate_tendsto_silver` : consequently `d(i, z_k)/k → log(1+√2)` along the Pell
  spine: the growth exponent of the Berggren tree per unit of depth is exactly the
  logarithm of the **silver ratio**, and `log 3` is attained by no path at all
  (`silver_lt_log_three`, `no_path_attains_log_three`).
* `rspine_rate_tendsto_zero` : along the pure-`B₃` spine — a path that uses `B₁` *never* —
  the ratio `d/k` tends to `0`.  This is the refutation of H2: the conjectured lower bound
  `δ log 2` fails for `δ = 1`, so the parabolic move `B₁` is **not** the only source of the
  depth–distance mismatch.
* `berggren_word_two_sided` : the corrected positive statement.  In terms of the word
  `w ∈ {B₁,B₂,B₃}*` labelling a path, `(#B₂(w) + 1) log 2 ≤ d ≤ (|w| + 1) log(1+√2) + log 2`;
  the exponential rate is driven by the frequency of the *middle* move alone.
-/

namespace HyperbolicBerggrenGeodesics

open Real Filter Topology

noncomputable section

/-! ## Part A. The distance is the logarithm of the first seed coordinate -/

/-- **The distance is `log m` up to `log 2`.**  For every Euclid seed `(m,n)` the hyperbolic
distance from the base point `i` to the node `z(m,n) = (n+i)/m` satisfies
`log m ≤ d ≤ log m + log 2`.  (Only `0 < n < m` is used.)  Both bounds are sharp: the lower
one in the limit `n/m → 0`, the upper one in the limit `n/m → 1`. -/
theorem dist_window_log_fst {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    Real.log m ≤ dist (hpoint m n (lt_trans hn hnm)) UpperHalfPlane.I ∧
      dist (hpoint m n (lt_trans hn hnm)) UpperHalfPlane.I ≤ Real.log m + Real.log 2 := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hmn : (n : ℝ) + 1 ≤ (m : ℝ) := by exact_mod_cast hnm
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : 0 < c := by positivity
  constructor
  · have h1 := dist_ge_half_log_hypotenuse hn hnm
    have h2 : Real.log ((m : ℝ) ^ 2) ≤ Real.log c :=
      Real.log_le_log (by positivity) (by nlinarith)
    rw [Real.log_pow] at h2
    push_cast at h2
    linarith
  · have h1 := dist_le_half_log_two_hypotenuse hn hnm
    have hsq : 2 * (c + 1) ≤ 4 * (m : ℝ) ^ 2 := by nlinarith
    have h2 : Real.log (2 * (c + 1)) ≤ Real.log (4 * (m : ℝ) ^ 2) :=
      Real.log_le_log (by positivity) hsq
    have h3 : Real.log (4 * (m : ℝ) ^ 2) = 2 * Real.log 2 + 2 * Real.log m := by
      rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow,
        show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
      push_cast
      ring
    rw [h3] at h2
    linarith

/-! ## Part B. The silver potential and the sharp upper envelope -/

/-- The silver ratio `1 + √2`, the exact exponential growth rate per Berggren step. -/
def silver : ℝ := 1 + Real.sqrt 2

theorem sqrt_two_sq : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)

theorem sqrt_two_bounds : (1.41 : ℝ) < Real.sqrt 2 ∧ Real.sqrt 2 < 1.415 := by
  constructor
  · nlinarith [sqrt_two_sq, Real.sqrt_nonneg 2]
  · nlinarith [sqrt_two_sq, Real.sqrt_nonneg 2]

theorem one_lt_silver : 1 < silver := by
  have := sqrt_two_bounds.1
  unfold silver
  linarith

theorem silver_pos : 0 < silver := lt_trans one_pos one_lt_silver

/-- The **silver potential** of a seed: `Φ(m,n) = m + (√2 − 1) n`. -/
def pot (p : ℕ × ℕ) : ℝ := (p.1 : ℝ) + (Real.sqrt 2 - 1) * (p.2 : ℝ)

theorem pot_root : pot (2, 1) = silver := by
  simp [pot, silver]
  ring

/-- The first coordinate is dominated by the potential. -/
theorem fst_le_pot (p : ℕ × ℕ) : (p.1 : ℝ) ≤ pot p := by
  have h := sqrt_two_bounds.1
  have : (0 : ℝ) ≤ (Real.sqrt 2 - 1) * (p.2 : ℝ) := by
    apply mul_nonneg (by linarith) (Nat.cast_nonneg _)
  simp [pot]
  linarith

/-- Conversely, for a seed the potential is at most `√2 · m`. -/
theorem pot_le_sqrt_two_mul_fst {m n : ℕ} (hnm : n ≤ m) :
    pot (m, n) ≤ Real.sqrt 2 * (m : ℝ) := by
  have h : (n : ℝ) ≤ (m : ℝ) := by exact_mod_cast hnm
  have h2 := sqrt_two_bounds.1
  have : (Real.sqrt 2 - 1) * (n : ℝ) ≤ (Real.sqrt 2 - 1) * (m : ℝ) :=
    mul_le_mul_of_nonneg_left h (by linarith)
  simp only [pot]
  linarith

/-- **The potential contracts under `B₁`.** -/
theorem pot_seedL_le {m n : ℕ} (h : IsSeed m n) : pot (seedL (m, n)) ≤ silver * pot (m, n) := by
  have hnm : (n : ℝ) < (m : ℝ) := by exact_mod_cast h.lt
  have hltnat := h.lt
  have hcast : ((2 * m - n : ℕ) : ℝ) = 2 * (m : ℝ) - (n : ℝ) := by
    have : n ≤ 2 * m := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hs := sqrt_two_sq
  have h2 := sqrt_two_bounds.1
  simp only [pot, seedL, silver, hcast]
  nlinarith [Nat.cast_nonneg (α := ℝ) n]

/-- **The potential is multiplied exactly by the silver ratio under `B₂`.** -/
theorem pot_seedM_eq (m n : ℕ) : pot (seedM (m, n)) = silver * pot (m, n) := by
  have hs := sqrt_two_sq
  simp only [pot, seedM, silver]
  push_cast
  nlinarith [hs]

/-- **The potential contracts under `B₃`** — here the seed inequality `n ≤ m` is what is
used, and it is exactly what makes the constant `1 + √2` work. -/
theorem pot_seedR_le {m n : ℕ} (h : IsSeed m n) : pot (seedR (m, n)) ≤ silver * pot (m, n) := by
  have hnm : (n : ℝ) < (m : ℝ) := by exact_mod_cast h.lt
  have hs := sqrt_two_sq
  have h2 := sqrt_two_bounds.1
  simp only [pot, seedR, silver]
  push_cast
  nlinarith

/-- **The potential bound at depth `k`.**  Every node at depth `k` has silver potential at
most `(1+√2)^{k+1}`, with equality exactly along the pure-`B₂` spine. -/
theorem reaches_pot_le {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) : pot p ≤ silver ^ (k + 1) := by
  induction h with
  | root => simp [pot_root]
  | @stepL p k hp ih =>
      have hs := reaches_isSeed hp
      have h1 : pot (seedL (p.1, p.2)) ≤ silver * pot (p.1, p.2) := pot_seedL_le hs
      have hpp : (p.1, p.2) = p := rfl
      rw [hpp] at h1
      calc pot (seedL p) ≤ silver * pot p := h1
        _ ≤ silver * silver ^ (k + 1) := by
            exact mul_le_mul_of_nonneg_left ih silver_pos.le
        _ = silver ^ (k + 1 + 1) := by ring
  | @stepM p k hp ih =>
      have h1 : pot (seedM (p.1, p.2)) = silver * pot (p.1, p.2) := pot_seedM_eq p.1 p.2
      have hpp : (p.1, p.2) = p := rfl
      rw [hpp] at h1
      calc pot (seedM p) = silver * pot p := h1
        _ ≤ silver * silver ^ (k + 1) := mul_le_mul_of_nonneg_left ih silver_pos.le
        _ = silver ^ (k + 1 + 1) := by ring
  | @stepR p k hp ih =>
      have hs := reaches_isSeed hp
      have h1 : pot (seedR (p.1, p.2)) ≤ silver * pot (p.1, p.2) := pot_seedR_le hs
      have hpp : (p.1, p.2) = p := rfl
      rw [hpp] at h1
      calc pot (seedR p) ≤ silver * pot p := h1
        _ ≤ silver * silver ^ (k + 1) := mul_le_mul_of_nonneg_left ih silver_pos.le
        _ = silver ^ (k + 1 + 1) := by ring

/-- The first coordinate at depth `k` is at most `(1+√2)^{k+1}` — a sharpening of the
cycle-VIII bound `m ≤ 2·3^k`. -/
theorem reaches_fst_le_silver {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    (p.1 : ℝ) ≤ silver ^ (k + 1) :=
  le_trans (fst_le_pot p) (reaches_pot_le h)

/-- **The sharp upper envelope.**  A Berggren node at depth `k` lies at hyperbolic distance
at most `(k+1) log(1+√2) + log 2` from the base point `i`.  Cycle VIII gave the weaker
`k log 3 + (5/2) log 2`; the constant `log(1+√2)` proved here is optimal, by
`mspine_dist_ge_silver`. -/
theorem dist_le_silver_depth {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    dist (hpoint p.1 p.2 (lt_trans (reaches_isSeed h).pos (reaches_isSeed h).lt))
      UpperHalfPlane.I ≤ ((k : ℝ) + 1) * Real.log silver + Real.log 2 := by
  have hs := reaches_isSeed h
  have hpos : 0 < p.1 := lt_trans hs.pos hs.lt
  have hupper := (dist_window_log_fst hs.pos hs.lt).2
  have hfst := reaches_fst_le_silver h
  have hlog : Real.log p.1 ≤ Real.log (silver ^ (k + 1)) := by
    apply Real.log_le_log _ hfst
    exact_mod_cast hpos
  rw [Real.log_pow] at hlog
  push_cast at hlog
  linarith

/-! ## Part C. The pure-`B₂` spine attains the silver rate -/

/-- Along the middle spine the potential is *exactly* `(1+√2)^{k+1}`. -/
theorem mspine_pot_eq (k : ℕ) : pot (mspine k) = silver ^ (k + 1) := by
  induction k with
  | zero => simpa [mspine] using pot_root
  | succ k ih =>
      have h1 : mspine (k + 1) = seedM (mspine k) := rfl
      have h2 : pot (seedM ((mspine k).1, (mspine k).2)) = silver * pot ((mspine k).1, (mspine k).2) :=
        pot_seedM_eq _ _
      have hpp : ((mspine k).1, (mspine k).2) = mspine k := rfl
      rw [hpp] at h2
      rw [h1, h2, ih]
      ring

/-- Hence the first coordinate along the middle spine is at least `(1+√2)^{k+1}/√2`. -/
theorem mspine_fst_ge_silver (k : ℕ) :
    silver ^ (k + 1) / Real.sqrt 2 ≤ ((mspine k).1 : ℝ) := by
  have hs := mspine_isSeed k
  have h1 : pot (mspine k) ≤ Real.sqrt 2 * ((mspine k).1 : ℝ) := by
    have := pot_le_sqrt_two_mul_fst (m := (mspine k).1) (n := (mspine k).2) hs.lt.le
    simpa using this
  have h2 := mspine_pot_eq k
  have hsq : (0 : ℝ) < Real.sqrt 2 := by
    have := sqrt_two_bounds.1; linarith
  rw [div_le_iff₀ hsq, mul_comm]
  linarith [h2 ▸ h1]

/-- **The lower envelope along the Pell spine.**  `d(i, z_k) ≥ (k+1) log(1+√2) − ½ log 2`,
matching `dist_le_silver_depth` up to an additive constant. -/
theorem mspine_dist_ge_silver (k : ℕ) :
    ((k : ℝ) + 1) * Real.log silver - (1 / 2) * Real.log 2 ≤
      dist (hpoint (mspine k).1 (mspine k).2
        (lt_trans (mspine_isSeed k).pos (mspine_isSeed k).lt)) UpperHalfPlane.I := by
  have hs := mspine_isSeed k
  have hlow := (dist_window_log_fst hs.pos hs.lt).1
  have hfst := mspine_fst_ge_silver k
  have hsq : (0 : ℝ) < Real.sqrt 2 := by have := sqrt_two_bounds.1; linarith
  have hpos : (0 : ℝ) < silver ^ (k + 1) / Real.sqrt 2 := by
    apply div_pos (pow_pos silver_pos _) hsq
  have hlog : Real.log (silver ^ (k + 1) / Real.sqrt 2) ≤ Real.log (mspine k).1 :=
    Real.log_le_log hpos hfst
  have hsplit : Real.log (silver ^ (k + 1) / Real.sqrt 2)
      = ((k : ℝ) + 1) * Real.log silver - (1 / 2) * Real.log 2 := by
    rw [Real.log_div (ne_of_gt (pow_pos silver_pos _)) (ne_of_gt hsq), Real.log_pow,
      Real.log_sqrt (by norm_num)]
    push_cast
    ring
  rw [hsplit] at hlog
  linarith

/-! ## Part D. The exact growth rate, and the refutation of conjecture H2 -/

/-- The distance from the base point to the depth-`k` node of the pure-`B₂` (Pell) spine. -/
def mdist (k : ℕ) : ℝ :=
  dist (hpoint (mspine k).1 (mspine k).2
    (lt_trans (mspine_isSeed k).pos (mspine_isSeed k).lt)) UpperHalfPlane.I

/-- The distance from the base point to the depth-`k` node `(2k+2, 1)` of the pure-`B₃`
spine. -/
def rdist (k : ℕ) : ℝ :=
  dist (hpoint (2 * k + 2) 1 (by omega)) UpperHalfPlane.I

theorem mdist_bounds (k : ℕ) :
    ((k : ℝ) + 1) * Real.log silver - (1 / 2) * Real.log 2 ≤ mdist k ∧
      mdist k ≤ ((k : ℝ) + 1) * Real.log silver + Real.log 2 := by
  refine ⟨mspine_dist_ge_silver k, ?_⟩
  have h := dist_le_silver_depth (mspine_reaches k)
  exact h

/-- **The silver growth rate.**  Along the Pell spine of pure `B₂` moves the ratio of the
hyperbolic distance to the combinatorial depth converges to `log(1+√2) = 0.88137…`. -/
theorem mspine_rate_tendsto_silver :
    Tendsto (fun k : ℕ => mdist k / k) atTop (𝓝 (Real.log silver)) := by
  have hlow : Tendsto
      (fun k : ℕ => Real.log silver + (Real.log silver - (1 / 2) * Real.log 2) / k)
      atTop (𝓝 (Real.log silver)) := by
    have := tendsto_const_div_atTop_nhds_zero_nat
      (Real.log silver - (1 / 2) * Real.log 2)
    simpa using (tendsto_const_nhds (x := Real.log silver) (f := atTop (α := ℕ))).add this
  have hhigh : Tendsto
      (fun k : ℕ => Real.log silver + (Real.log silver + Real.log 2) / k)
      atTop (𝓝 (Real.log silver)) := by
    have := tendsto_const_div_atTop_nhds_zero_nat (Real.log silver + Real.log 2)
    simpa using (tendsto_const_nhds (x := Real.log silver) (f := atTop (α := ℕ))).add this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [eventually_gt_atTop 0] with k hk
    have hkR : (0 : ℝ) < k := by exact_mod_cast hk
    rw [le_div_iff₀ hkR]
    have h := (mdist_bounds k).1
    have : (Real.log silver + (Real.log silver - (1 / 2) * Real.log 2) / k) * k
        = (k : ℝ) * Real.log silver + (Real.log silver - (1 / 2) * Real.log 2) := by
      field_simp
    rw [this]
    linarith
  · filter_upwards [eventually_gt_atTop 0] with k hk
    have hkR : (0 : ℝ) < k := by exact_mod_cast hk
    rw [div_le_iff₀ hkR]
    have h := (mdist_bounds k).2
    have : (Real.log silver + (Real.log silver + Real.log 2) / k) * k
        = (k : ℝ) * Real.log silver + (Real.log silver + Real.log 2) := by
      field_simp
    rw [this]
    linarith

/-- Elementary limit: `log(a k + b)/k → 0` for `a > 0`, `b ≥ 0`.  This is what makes the
two *non*-expanding pure spines have vanishing rate. -/
theorem log_affine_div_tendsto_zero (a b : ℝ) (ha : 0 < a) (hb : 0 ≤ b) :
    Tendsto (fun k : ℕ => Real.log (a * (k : ℝ) + b) / k) atTop (𝓝 0) := by
  have hlog : Tendsto (fun x : ℝ => Real.log x / x) atTop (𝓝 0) := by
    simpa using Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 one_ne_zero
  have hu : Tendsto (fun k : ℕ => a * (k : ℝ) + b) atTop atTop := by
    apply Filter.tendsto_atTop_add_const_right
    exact tendsto_natCast_atTop_atTop.const_mul_atTop ha
  have h1 : Tendsto (fun k : ℕ => Real.log (a * (k : ℝ) + b) / (a * (k : ℝ) + b))
      atTop (𝓝 0) := hlog.comp hu
  have h2 : Tendsto (fun k : ℕ => (a * (k : ℝ) + b) / k) atTop (𝓝 a) := by
    have hc := tendsto_const_div_atTop_nhds_zero_nat b
    have hab : Tendsto (fun k : ℕ => a + b / (k : ℝ)) atTop (𝓝 a) := by
      simpa using (tendsto_const_nhds (x := a) (f := atTop (α := ℕ))).add hc
    refine hab.congr' ?_
    filter_upwards [eventually_gt_atTop 0] with k hk
    have hkR : (0 : ℝ) < k := by exact_mod_cast hk
    field_simp
  have hprod := h1.mul h2
  rw [zero_mul] at hprod
  refine hprod.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with k hk
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk
  have hpos : (0 : ℝ) < a * (k : ℝ) + b := by positivity
  field_simp

/-- **Refutation of conjecture H2, first form.**  The pure-`B₃` spine never uses the
parabolic move `B₁`, yet the ratio of hyperbolic distance to depth tends to `0`, not to a
limit in `[log 2, log 3]`.  So `B₁` is *not* the only source of the depth-distance
mismatch. -/
theorem rspine_rate_tendsto_zero : Tendsto (fun k : ℕ => rdist k / k) atTop (𝓝 0) := by
  have hupper : Tendsto (fun k : ℕ => (Real.log (2 * (k : ℝ) + 2) + Real.log 2) / k)
      atTop (𝓝 0) := by
    have h1 := log_affine_div_tendsto_zero 2 2 (by norm_num) (by norm_num)
    have h2 := tendsto_const_div_atTop_nhds_zero_nat (Real.log 2)
    have := h1.add h2
    rw [add_zero] at this
    refine this.congr' ?_
    filter_upwards [eventually_gt_atTop 0] with k hk
    have hkR : (0 : ℝ) < k := by exact_mod_cast hk
    field_simp
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards with k
    exact div_nonneg dist_nonneg (Nat.cast_nonneg k)
  · filter_upwards [eventually_gt_atTop 0] with k hk
    have hkR : (0 : ℝ) < k := by exact_mod_cast hk
    have hb := (dist_window_log_fst (m := 2 * k + 2) (n := 1) one_pos (by omega)).2
    have hcast : ((2 * k + 2 : ℕ) : ℝ) = 2 * (k : ℝ) + 2 := by push_cast; ring
    rw [hcast] at hb
    exact (div_le_div_iff_of_pos_right hkR).mpr hb

/-- **Refutation of conjecture H2, existential form.**  For every `δ > 0` there are
arbitrarily deep `B₁`-free Berggren paths whose distance-to-depth ratio is below `δ`. -/
theorem H2_refuted_B1_free (delta : ℝ) (hd : 0 < delta) (K : ℕ) :
    ∃ k : ℕ, K ≤ k ∧ 0 < k ∧ Reaches (2 * k + 2, 1) k ∧ rdist k / k < delta := by
  have h := rspine_rate_tendsto_zero
  have hev : ∀ᶠ k : ℕ in atTop, rdist k / k < delta := by
    have := h.eventually (eventually_lt_nhds (by simpa using hd) (a := (0 : ℝ)))
    simpa using this
  obtain ⟨k, hk⟩ := ((hev.and (eventually_ge_atTop K)).and (eventually_gt_atTop 0)).exists
  exact ⟨k, hk.1.2, hk.2, rspine_reaches k, hk.1.1⟩

/-- The distance from the base point to the depth-`k` node `(k+2, k+1)` of the pure-`B₁`
spine. -/
def ldist (k : ℕ) : ℝ :=
  dist (hpoint (k + 2) (k + 1) (by omega)) UpperHalfPlane.I

/-- The pure-`B₁` (parabolic) spine also has vanishing rate: its nodes `(k+2, k+1)` grow
only linearly, so `d/k → 0`.  This is the metric form of cycle I's
`depth_not_bounded_by_distance`. -/
theorem lspine_rate_tendsto_zero : Tendsto (fun k : ℕ => ldist k / k) atTop (𝓝 0) := by
  have hupper : Tendsto (fun k : ℕ => (Real.log (1 * (k : ℝ) + 2) + Real.log 2) / k)
      atTop (𝓝 0) := by
    have h1 := log_affine_div_tendsto_zero 1 2 (by norm_num) (by norm_num)
    have h2 := tendsto_const_div_atTop_nhds_zero_nat (Real.log 2)
    have h3 := h1.add h2
    rw [add_zero] at h3
    refine h3.congr' ?_
    filter_upwards [eventually_gt_atTop 0] with k hk
    have hkR : (0 : ℝ) < k := by exact_mod_cast hk
    field_simp
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards with k
    exact div_nonneg dist_nonneg (Nat.cast_nonneg k)
  · filter_upwards [eventually_gt_atTop 0] with k hk
    have hkR : (0 : ℝ) < k := by exact_mod_cast hk
    have hb := (dist_window_log_fst (m := k + 2) (n := k + 1) (by omega) (by omega)).2
    have hcast : ((k + 2 : ℕ) : ℝ) = 1 * (k : ℝ) + 2 := by push_cast; ring
    rw [hcast] at hb
    exact (div_le_div_iff_of_pos_right hkR).mpr hb

/-- **The trichotomy of pure spines.**  Of the three one-generator branches of the Berggren
tree, only the middle one has positive metric growth rate: `B₁` and `B₃` give `d/k → 0`,
while `B₂` gives `d/k → log(1+√2)`.  Conjecture H2 predicted rates in `[δ log 2, log 3]`
with the maximum `log 3` at the pure-`B₃` branch; both halves are false. -/
theorem pure_spine_rate_trichotomy :
    Tendsto (fun k : ℕ => ldist k / k) atTop (𝓝 0) ∧
      Tendsto (fun k : ℕ => mdist k / k) atTop (𝓝 (Real.log silver)) ∧
      Tendsto (fun k : ℕ => rdist k / k) atTop (𝓝 0) :=
  ⟨lspine_rate_tendsto_zero, mspine_rate_tendsto_silver, rspine_rate_tendsto_zero⟩

/-- The silver ratio is smaller than `3`. -/
theorem silver_lt_three : silver < 3 := by
  have := sqrt_two_bounds.2
  unfold silver
  linarith

theorem log_silver_lt_log_three : Real.log silver < Real.log 3 :=
  Real.log_lt_log silver_pos silver_lt_three

theorem log_silver_pos : 0 < Real.log silver := Real.log_pos one_lt_silver

/-- **The universal asymptotic rate bound.**  For every `ε > 0` there is a depth threshold
beyond which *every* Berggren node satisfies `d/k ≤ log(1+√2) + ε`. -/
theorem asymptotic_rate_le_silver (eps : ℝ) (heps : 0 < eps) :
    ∃ K : ℕ, 0 < K ∧ ∀ (p : ℕ × ℕ) (k : ℕ) (h : Reaches p k), K ≤ k →
      dist (hpoint p.1 p.2 (lt_trans (reaches_isSeed h).pos (reaches_isSeed h).lt))
        UpperHalfPlane.I / k ≤ Real.log silver + eps := by
  obtain ⟨K, hK⟩ := exists_nat_gt ((Real.log silver + Real.log 2) / eps)
  refine ⟨K + 1, Nat.succ_pos K, ?_⟩
  intro p k h hk
  have hkR : (0 : ℝ) < k := by
    have : 0 < k := lt_of_lt_of_le (Nat.succ_pos K) hk
    exact_mod_cast this
  have hKk : ((K : ℝ)) ≤ k := by
    have : (K : ℕ) ≤ k := le_trans (Nat.le_succ K) hk
    exact_mod_cast this
  have hbound := dist_le_silver_depth h
  rw [div_le_iff₀ hkR]
  have hkey : Real.log silver + Real.log 2 ≤ eps * k := by
    have h1 : (Real.log silver + Real.log 2) / eps < K := hK
    have h2 : (Real.log silver + Real.log 2) / eps ≤ (k : ℝ) := le_trans h1.le hKk
    rw [div_le_iff₀ heps] at h2
    linarith [h2]
  nlinarith [hbound]

/-- **Refutation of conjecture H2, second form.**  The value `log 3` proposed as the extreme
depth-distance rate is attained by *no* Berggren path: beyond an explicit depth threshold
every node satisfies `d/k < log 3`, with a uniform gap. -/
theorem no_path_attains_log_three :
    ∃ K : ℕ, 0 < K ∧ ∀ (p : ℕ × ℕ) (k : ℕ) (h : Reaches p k), K ≤ k →
      dist (hpoint p.1 p.2 (lt_trans (reaches_isSeed h).pos (reaches_isSeed h).lt))
        UpperHalfPlane.I / k < Real.log 3 := by
  obtain ⟨K, hK0, hK⟩ :=
    asymptotic_rate_le_silver ((Real.log 3 - Real.log silver) / 2)
      (by linarith [log_silver_lt_log_three])
  refine ⟨K, hK0, fun p k h hk => ?_⟩
  have := hK p k h hk
  have hgap := log_silver_lt_log_three
  linarith

/-! ## Part E. Words in the three moves: the corrected form of H2 -/

/-- A Berggren move. -/
inductive Move | L | M | R
  deriving DecidableEq

/-- The action of a move on a seed. -/
def stepOf : Move → ℕ × ℕ → ℕ × ℕ
  | Move.L, p => seedL p
  | Move.M, p => seedM p
  | Move.R, p => seedR p

/-- The node reached from the root by a word of moves (read right to left). -/
def run : List Move → ℕ × ℕ
  | [] => (2, 1)
  | a :: w => stepOf a (run w)

/-- The number of middle (`B₂`) moves in a word. -/
def countM (w : List Move) : ℕ := w.count Move.M

theorem run_reaches (w : List Move) : Reaches (run w) w.length := by
  induction w with
  | nil => exact Reaches.root
  | cons a w ih =>
      cases a with
      | L => exact Reaches.stepL ih
      | M => exact Reaches.stepM ih
      | R => exact Reaches.stepR ih

theorem run_isSeed (w : List Move) : IsSeed (run w).1 (run w).2 :=
  reaches_isSeed (run_reaches w)

/-- **The middle move is the only universal expander.**  The first coordinate of the node
reached by a word `w` is at least `2^{#B₂(w) + 1}`: each `B₂` step at least doubles `m`,
while `B₁` and `B₃` never decrease it. -/
theorem run_fst_ge_two_pow (w : List Move) : 2 ^ (countM w + 1) ≤ (run w).1 := by
  induction w with
  | nil => simp [run, countM]
  | cons a w ih =>
      have hs := run_isSeed w
      have hlt : (run w).2 < (run w).1 := hs.lt
      have hpos : 0 < (run w).2 := hs.pos
      cases a with
      | L =>
          have hc : countM (Move.L :: w) = countM w := by
            simp [countM]
          have : (run (Move.L :: w)).1 = 2 * (run w).1 - (run w).2 := rfl
          rw [hc, this]
          omega
      | M =>
          have hc : countM (Move.M :: w) = countM w + 1 := by
            simp [countM]
          have hval : (run (Move.M :: w)).1 = 2 * (run w).1 + (run w).2 := rfl
          rw [hc, hval, pow_succ]
          omega
      | R =>
          have hc : countM (Move.R :: w) = countM w := by
            simp [countM]
          have : (run (Move.R :: w)).1 = (run w).1 + 2 * (run w).2 := rfl
          rw [hc, this]
          omega

/-- Hence a lower bound for the hyperbolic distance in terms of the number of `B₂` moves. -/
theorem dist_ge_countM (w : List Move) :
    ((countM w : ℝ) + 1) * Real.log 2 ≤
      dist (hpoint (run w).1 (run w).2
        (lt_trans (run_isSeed w).pos (run_isSeed w).lt)) UpperHalfPlane.I := by
  have hs := run_isSeed w
  have hlow := (dist_window_log_fst hs.pos hs.lt).1
  have hnat := run_fst_ge_two_pow w
  have hcast : ((2 : ℝ) ^ (countM w + 1)) ≤ ((run w).1 : ℝ) := by
    have : ((2 ^ (countM w + 1) : ℕ) : ℝ) ≤ (((run w).1 : ℕ) : ℝ) := by exact_mod_cast hnat
    simpa using this
  have hlog : Real.log ((2 : ℝ) ^ (countM w + 1)) ≤ Real.log (run w).1 :=
    Real.log_le_log (by positivity) hcast
  rw [Real.log_pow] at hlog
  push_cast at hlog
  linarith

/-- **The corrected form of H2.**  Along the path labelled by a word `w`, the hyperbolic
distance is squeezed between the `B₂`-count and the length:
`(#B₂(w) + 1) log 2 ≤ d ≤ (|w| + 1) log(1+√2) + log 2`.
The exponential rate is therefore controlled from below by the *frequency of the middle
move* alone — not, as conjectured in H2, by the frequency of the non-parabolic moves
(`rspine_rate_tendsto_zero` shows a `B₃`-only path has rate `0`). -/
theorem berggren_word_two_sided (w : List Move) :
    ((countM w : ℝ) + 1) * Real.log 2 ≤
      dist (hpoint (run w).1 (run w).2
        (lt_trans (run_isSeed w).pos (run_isSeed w).lt)) UpperHalfPlane.I ∧
      dist (hpoint (run w).1 (run w).2
        (lt_trans (run_isSeed w).pos (run_isSeed w).lt)) UpperHalfPlane.I ≤
        ((w.length : ℝ) + 1) * Real.log silver + Real.log 2 :=
  ⟨dist_ge_countM w, dist_le_silver_depth (run_reaches w)⟩

/-- **Positive rate from middle-move frequency.**  If a word of positive length uses the
middle move at least a fraction `α` of the time, its distance-to-depth ratio is at least
`α log 2`. -/
theorem rate_ge_of_middle_frequency (w : List Move) (hw : 0 < w.length) (alpha : ℝ)
    (hfreq : alpha * w.length ≤ (countM w : ℝ)) :
    alpha * Real.log 2 ≤
      dist (hpoint (run w).1 (run w).2
        (lt_trans (run_isSeed w).pos (run_isSeed w).lt)) UpperHalfPlane.I / w.length := by
  have hwR : (0 : ℝ) < w.length := by exact_mod_cast hw
  rw [le_div_iff₀ hwR]
  have h1 := dist_ge_countM w
  have h2 : alpha * w.length * Real.log 2 ≤ (countM w : ℝ) * Real.log 2 :=
    mul_le_mul_of_nonneg_right hfreq (Real.log_nonneg (by norm_num))
  nlinarith [Real.log_nonneg (show (1:ℝ) ≤ 2 by norm_num)]

/-! ## Part F. The optimal depth at which a hypotenuse is reached -/

/-- Every node at depth `k` has hypotenuse at most `2 (1+√2)^{2k+2}`. -/
theorem reaches_hypot_le_silver {p : ℕ × ℕ} {k : ℕ} (h : Reaches p k) :
    ((hypot p : ℕ) : ℝ) ≤ 2 * silver ^ (2 * k + 2) := by
  have hs := reaches_isSeed h
  have hfst := reaches_fst_le_silver h
  have hnm : ((p.2 : ℕ) : ℝ) ≤ ((p.1 : ℕ) : ℝ) := by exact_mod_cast hs.lt.le
  have hn0 : (0 : ℝ) ≤ (p.2 : ℝ) := Nat.cast_nonneg _
  have hp0 : (0 : ℝ) ≤ (p.1 : ℝ) := Nat.cast_nonneg _
  have hpow : silver ^ (2 * k + 2) = (silver ^ (k + 1)) ^ 2 := by
    rw [← pow_mul]
    ring_nf
  have hcast : ((hypot p : ℕ) : ℝ) = (p.1 : ℝ) ^ 2 + (p.2 : ℝ) ^ 2 := by
    simp [hypot]
  rw [hcast, hpow]
  nlinarith [pow_pos silver_pos (k + 1)]

/-- Along the Pell spine the hypotenuse is at least `(1+√2)^{2k+2}/2`, matching the previous
bound up to the factor `4`. -/
theorem mspine_hypot_ge_silver (k : ℕ) :
    silver ^ (2 * k + 2) / 2 ≤ ((hypot (mspine k) : ℕ) : ℝ) := by
  have hfst := mspine_fst_ge_silver k
  have hsq : (0 : ℝ) < Real.sqrt 2 := by have := sqrt_two_bounds.1; linarith
  have h2 := sqrt_two_sq
  have hcast : ((hypot (mspine k) : ℕ) : ℝ)
      = ((mspine k).1 : ℝ) ^ 2 + ((mspine k).2 : ℝ) ^ 2 := by
    simp [hypot]
  have hn0 : (0 : ℝ) ≤ ((mspine k).2 : ℝ) := Nat.cast_nonneg _
  have hpow : silver ^ (2 * k + 2) = (silver ^ (k + 1)) ^ 2 := by
    rw [← pow_mul]
    ring_nf
  have hppos : (0 : ℝ) < silver ^ (k + 1) := pow_pos silver_pos _
  rw [hcast, hpow]
  have hdiv : silver ^ (k + 1) / Real.sqrt 2 ≤ ((mspine k).1 : ℝ) := hfst
  have hnn : (0 : ℝ) ≤ silver ^ (k + 1) / Real.sqrt 2 := le_of_lt (div_pos hppos hsq)
  have hA2 : (silver ^ (k + 1) / Real.sqrt 2) ^ 2 = (silver ^ (k + 1)) ^ 2 / 2 := by
    rw [div_pow, h2]
  have hsq2 : (silver ^ (k + 1) / Real.sqrt 2) ^ 2 ≤ ((mspine k).1 : ℝ) ^ 2 := by
    nlinarith
  nlinarith [sq_nonneg ((mspine k).2 : ℝ)]

/-- **The depth lower bound for a given hypotenuse.**  A node of hypotenuse at least `N`
cannot occur before depth `(log N − log 2)/(2 log(1+√2)) − 1`. -/
theorem depth_ge_of_hypot {p : ℕ × ℕ} {k N : ℕ} (h : Reaches p k) (hN : 0 < N)
    (hle : N ≤ hypot p) :
    (Real.log N - Real.log 2) / (2 * Real.log silver) - 1 ≤ (k : ℝ) := by
  have hlog := log_silver_pos
  have hub := reaches_hypot_le_silver h
  have hNR : ((N : ℕ) : ℝ) ≤ ((hypot p : ℕ) : ℝ) := by exact_mod_cast hle
  have hNpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have h1 : (N : ℝ) ≤ 2 * silver ^ (2 * k + 2) := le_trans hNR hub
  have h2 : Real.log N ≤ Real.log (2 * silver ^ (2 * k + 2)) := Real.log_le_log hNpos h1
  rw [Real.log_mul (by norm_num) (ne_of_gt (pow_pos silver_pos _)), Real.log_pow] at h2
  push_cast at h2
  rw [sub_le_iff_le_add, div_le_iff₀ (by linarith)]
  linarith

/-- **The matching upper bound.**  For every `N ≥ 1` the Pell spine reaches hypotenuse at
least `N` at a depth of at most `(log N + log 2)/(2 log(1+√2))`. -/
theorem exists_depth_reach_silver (N : ℕ) (hN : 1 ≤ N) :
    ∃ k : ℕ, N ≤ hypot (mspine k) ∧
      (k : ℝ) ≤ (Real.log N + Real.log 2) / (2 * Real.log silver) := by
  have hlog := log_silver_pos
  have hNpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hNlog : 0 ≤ Real.log N := Real.log_nonneg (by exact_mod_cast hN)
  set X : ℝ := (Real.log N + Real.log 2) / (2 * Real.log silver) - 1 with hX
  refine ⟨⌈X⌉₊, ?_, ?_⟩
  · -- the ceiling is at least `X`, which is exactly the condition `N ≤ λ^{2k+2}/2`
    have hk : X ≤ (⌈X⌉₊ : ℝ) := Nat.le_ceil X
    have hkey : Real.log N + Real.log 2 ≤ (2 * (⌈X⌉₊ : ℝ) + 2) * Real.log silver := by
      rw [hX] at hk
      have := (sub_le_iff_le_add).mp hk
      rw [div_le_iff₀ (by linarith)] at this
      linarith
    have hpow : (N : ℝ) ≤ silver ^ (2 * ⌈X⌉₊ + 2) / 2 := by
      have hlogpow : Real.log ((N : ℝ) * 2) ≤ Real.log (silver ^ (2 * ⌈X⌉₊ + 2)) := by
        rw [Real.log_mul (ne_of_gt hNpos) (by norm_num), Real.log_pow]
        push_cast
        linarith
      have := (Real.log_le_log_iff (mul_pos hNpos two_pos) (pow_pos silver_pos _)).mp hlogpow
      linarith
    have hfinal : ((N : ℕ) : ℝ) ≤ ((hypot (mspine ⌈X⌉₊) : ℕ) : ℝ) :=
      le_trans hpow (mspine_hypot_ge_silver _)
    exact_mod_cast hfinal
  · have hquot : 0 ≤ (Real.log N + Real.log 2) / (2 * Real.log silver) := by
      apply div_nonneg _ (by linarith)
      have := Real.log_nonneg (show (1:ℝ) ≤ 2 by norm_num)
      linarith
    rcases le_total 0 X with hXpos | hXneg
    · have hceil : (⌈X⌉₊ : ℝ) < X + 1 := Nat.ceil_lt_add_one hXpos
      rw [hX] at hceil
      linarith
    · have hz : ⌈X⌉₊ = 0 := Nat.ceil_eq_zero.mpr hXneg
      rw [hz]
      simpa using hquot

/-- **The metric growth exponent of the Berggren tree.**  Packaging Parts C–F: the
hyperbolic distance of a depth-`k` node never exceeds `(k+1) log(1+√2) + log 2`, and the
Pell spine attains the rate `log(1+√2)` in the limit.  Hence
`sup_path lim d(i,z_k)/k = log(1+√2)`, the logarithm of the silver ratio — strictly below
the value `log 3` conjectured in H2, and strictly above `log 2`. -/
theorem berggren_metric_growth_exponent :
    (∀ (p : ℕ × ℕ) (k : ℕ) (h : Reaches p k),
        dist (hpoint p.1 p.2 (lt_trans (reaches_isSeed h).pos (reaches_isSeed h).lt))
          UpperHalfPlane.I ≤ ((k : ℝ) + 1) * Real.log silver + Real.log 2) ∧
      Tendsto (fun k : ℕ => mdist k / k) atTop (𝓝 (Real.log silver)) ∧
      Real.log 2 < Real.log silver ∧ Real.log silver < Real.log 3 := by
  refine ⟨fun p k h => dist_le_silver_depth h, mspine_rate_tendsto_silver, ?_,
    log_silver_lt_log_three⟩
  apply Real.log_lt_log (by norm_num)
  have := sqrt_two_bounds.1
  unfold silver
  linarith

end

end HyperbolicBerggrenGeodesics