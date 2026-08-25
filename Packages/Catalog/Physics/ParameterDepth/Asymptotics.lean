import Physics.ParameterDepth.TreeDepth

/-!
# Parameter-derived depth, III: scaling laws for the maximal depth

The closed form `foamDepth B T = Nat.log B ((B-1)T+1) - 1` of
`Physics.ParameterDepth.TreeDepth` is arithmetic.  Here it is converted into the
analytic statements a physicist would quote:

* `pow_foamDepth_le_threshold` / `threshold_lt_pow_foamDepth_add_two` — the maximal
  depth is pinned between two consecutive-ish powers: `B^d ≤ T < B^(d+2)`;
* `foamDepth_le_logb` and `sub_two_lt_foamDepth` — hence
  `log_B T - 2 < d ≤ log_B T`: the supported depth is the base-`B` logarithm of the
  information budget, up to an additive constant `< 2`, uniformly in `B` and `T`;
* `resolution_lower_bound` / `resolution_upper_bound` — the finest resolvable length
  `ℓ B d = ℓ₀ · B^(-d)` obeys `ℓ₀ / T ≤ ℓ ≤ B² · ℓ₀ / T`, i.e. the resolution scales
  like the *inverse* of the information budget with a `B`-dependent constant only;
* `foamDepth_tendsto_atTop` — the depth is unbounded in the budget, so no fixed depth
  is universal;
* `foamDepth_pow_self` — an exact calibration point: at `T = foamCells B N` the maximal
  depth is exactly `N`, showing the two-sided bounds above are attained.

Nothing here is asymptotic hand-waving: every bound is uniform and explicit.
-/

namespace Physics.ParameterDepth

open Filter

variable {B T : ℕ}

/-- The finest level of the maximal cascade fits inside the budget. -/
theorem pow_foamDepth_le_threshold (hB : 2 ≤ B) (hT : 1 ≤ T) :
    B ^ foamDepth B T ≤ T :=
  le_trans (pow_le_foamCells B _) (foamDepth_isGreatest hB hT).1

/-- Two levels deeper is certainly out of budget: `T < B^(d+2)`.  Together with
`pow_foamDepth_le_threshold` this traps the maximal depth within an additive `2`. -/
theorem threshold_lt_pow_foamDepth_add_two (hB : 2 ≤ B) (hT : 1 ≤ T) :
    T < B ^ (foamDepth B T + 2) := by
  have hbreak : ¬ foamCells B (foamDepth B T + 1) ≤ T := not_supported_succ_foamDepth hB hT
  have hgeom : (B - 1) * foamCells B (foamDepth B T + 1) + 1 = B ^ (foamDepth B T + 2) := by
    have := foamCells_geom (by omega : 1 ≤ B) (foamDepth B T + 1)
    simpa [show foamDepth B T + 1 + 1 = foamDepth B T + 2 from rfl] using this
  have hle : foamCells B (foamDepth B T + 1) ≤ (B - 1) * foamCells B (foamDepth B T + 1) :=
    Nat.le_mul_of_pos_left _ (by omega)
  omega

/-- Calibration: with a budget of exactly one full cascade of depth `N`, the maximal
depth is exactly `N`.  In particular the bounds of this file are attained. -/
theorem foamDepth_foamCells (hB : 2 ≤ B) (N : ℕ) :
    foamDepth B (foamCells B N) = N := by
  have hT : 1 ≤ foamCells B N := by
    simpa using (foamCells_strictMono hB).monotone (Nat.zero_le N)
  refine le_antisymm ?_ ((foamCells_le_iff_le_foamDepth hB hT N).1 le_rfl)
  by_contra h
  push_neg at h
  have hfit : foamCells B (N + 1) ≤ foamCells B N :=
    (foamCells_le_iff_le_foamDepth hB hT (N + 1)).2 h
  have hlt : foamCells B N < foamCells B (N + 1) := (foamCells_strictMono hB) (by omega)
  omega

/-- The supported depth is unbounded in the information budget. -/
theorem foamDepth_tendsto_atTop (hB : 2 ≤ B) :
    ∀ N : ℕ, ∃ T : ℕ, 1 ≤ T ∧ N ≤ foamDepth B T := by
  intro N
  refine ⟨foamCells B N, ?_, ?_⟩
  · simpa using (foamCells_strictMono hB).monotone (Nat.zero_le N)
  · rw [foamDepth_foamCells hB N]

/-!
### Logarithmic form
-/

/-- The maximal depth never exceeds the base-`B` logarithm of the budget. -/
theorem foamDepth_le_logb (hB : 2 ≤ B) (hT : 1 ≤ T) :
    (foamDepth B T : ℝ) ≤ Real.logb B T := by
  have hB1 : (1 : ℝ) < B := by exact_mod_cast hB
  have hpow : (B : ℝ) ^ foamDepth B T ≤ (T : ℝ) := by
    exact_mod_cast pow_foamDepth_le_threshold hB hT
  have hTpos : (0 : ℝ) < T := by exact_mod_cast hT
  have h : Real.logb B ((B : ℝ) ^ foamDepth B T) ≤ Real.logb B T :=
    (Real.logb_le_logb hB1 (by positivity) hTpos).2 hpow
  rwa [Real.logb_pow, Real.logb_self_eq_one hB1, mul_one] at h

/-- …and it falls short of that logarithm by strictly less than `2`. -/
theorem sub_two_lt_foamDepth (hB : 2 ≤ B) (hT : 1 ≤ T) :
    Real.logb B T - 2 < (foamDepth B T : ℝ) := by
  have hB1 : (1 : ℝ) < B := by exact_mod_cast hB
  have hTpos : (0 : ℝ) < T := by exact_mod_cast hT
  have hpow : (T : ℝ) < (B : ℝ) ^ (foamDepth B T + 2) := by
    exact_mod_cast threshold_lt_pow_foamDepth_add_two hB hT
  have h : Real.logb B T < Real.logb B ((B : ℝ) ^ (foamDepth B T + 2)) :=
    (Real.strictMonoOn_logb hB1) (Set.mem_Ioi.2 hTpos) (Set.mem_Ioi.2 (by positivity)) hpow
  rw [Real.logb_pow, Real.logb_self_eq_one hB1, mul_one] at h
  push_cast at h
  linarith

/-- **Depth is the logarithm of the budget.**  The two-sided uniform estimate. -/
theorem foamDepth_logb_bounds (hB : 2 ≤ B) (hT : 1 ≤ T) :
    Real.logb B T - 2 < (foamDepth B T : ℝ) ∧ (foamDepth B T : ℝ) ≤ Real.logb B T :=
  ⟨sub_two_lt_foamDepth hB hT, foamDepth_le_logb hB hT⟩

/-!
### Resolution scaling

If the coarsest cell has size `ℓ₀`, the finest cell of the maximal cascade has size
`ℓ₀ / B^d`.  The next two theorems say this resolution is `Θ(ℓ₀ / T)`: refining a
holographic budget `T` buys linear, not logarithmic, resolution.
-/

/-- Resolution is at least `ℓ₀ / T`. -/
theorem resolution_lower_bound (hB : 2 ≤ B) (hT : 1 ≤ T) {l : ℝ} (hl : 0 < l) :
    l / T ≤ l / (B : ℝ) ^ foamDepth B T := by
  have hTpos : (0 : ℝ) < T := by exact_mod_cast hT
  have hppos : (0 : ℝ) < (B : ℝ) ^ foamDepth B T := by positivity
  have hpow : (B : ℝ) ^ foamDepth B T ≤ (T : ℝ) := by
    exact_mod_cast pow_foamDepth_le_threshold hB hT
  exact div_le_div_of_nonneg_left hl.le hppos hpow

/-- Resolution is at most `B² · ℓ₀ / T`: the constant depends on the branching number
only, never on the budget. -/
theorem resolution_upper_bound (hB : 2 ≤ B) (hT : 1 ≤ T) {l : ℝ} (hl : 0 < l) :
    l / (B : ℝ) ^ foamDepth B T < (B : ℝ) ^ 2 * l / T := by
  have hTpos : (0 : ℝ) < T := by exact_mod_cast hT
  have hBpos : (0 : ℝ) < B := by positivity
  have hppos : (0 : ℝ) < (B : ℝ) ^ foamDepth B T := by positivity
  have hpow : (T : ℝ) < (B : ℝ) ^ (foamDepth B T + 2) := by
    exact_mod_cast threshold_lt_pow_foamDepth_add_two hB hT
  rw [div_lt_div_iff₀ hppos hTpos]
  have hsplit : (B : ℝ) ^ (foamDepth B T + 2) = (B : ℝ) ^ foamDepth B T * (B : ℝ) ^ 2 := by
    rw [pow_add]
  nlinarith [hpow, hppos, hl]

end Physics.ParameterDepth