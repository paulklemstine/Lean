/-! # CatalogBuild.Computation.Oracles.MetaOracleCore

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 18
-/

import Mathlib

noncomputable section

/-- An `OracleSystem` bundles a type of oracles with a quality measure.
The quality function `q` assigns a real-valued score to each oracle,
where higher is better. -/
structure OracleSystem where
  Oracle : Type*
  q : Oracle → ℝ  -- quality measure


/-- A meta-oracle is strictly improving if it increases quality for
any non-optimal oracle. -/
def MetaOracle.StrictlyImproving {S : OracleSystem} (M : MetaOracle S)
    (optimal : S.Oracle → Prop) : Prop :=
  ∀ f, ¬optimal f → S.q f < S.q (M.improve f)


/-- The composition of two meta-oracles is again a meta-oracle. -/
def MetaOracle.comp {S : OracleSystem} (M₁ M₂ : MetaOracle S) : MetaOracle S where
  improve := M₁.improve ∘ M₂.improve
  improving := fun f => le_trans (M₂.improving f) (M₁.improving (M₂.improve f))


/-- Iterated application of a meta-oracle n times. -/
def MetaOracle.iterate {S : OracleSystem} (M : MetaOracle S) : ℕ → S.Oracle → S.Oracle
  | 0 => id
  | n + 1 => M.improve ∘ M.iterate n


/-- Quality is monotonically non-decreasing under iteration. -/
theorem MetaOracle.quality_mono {S : OracleSystem} (M : MetaOracle S)
    (f : S.Oracle) (n : ℕ) :
    S.q f ≤ S.q (M.iterate n f) := by
  induction n with
  | zero => simp [MetaOracle.iterate]
  | succ n ih =>
    simp [MetaOracle.iterate, Function.comp]
    exact le_trans ih (M.improving _)


/-- A `MetricOracleSpace` equips oracles with a metric structure and a
distinguished optimal oracle. The quality is measured as negative
distance to the optimum (closer = better). -/
structure MetricOracleSpace where
  Oracle : Type*
  [instMetric : MetricSpace Oracle]
  optimal : Oracle
  q : Oracle → ℝ := fun f => -(dist f optimal)

attribute [instance] MetricOracleSpace.instMetric


/-- A contraction meta-oracle on a metric oracle space. -/
structure ContractionMetaOracle (S : MetricOracleSpace) where
  improve : S.Oracle → S.Oracle
  k : ℝ
  k_pos : 0 < k
  k_lt_one : k < 1
  contraction : ∀ f g, dist (improve f) (improve g) ≤ k * dist f g


/-- The distance to optimum decreases geometrically under a contraction meta-oracle
that fixes the optimal point. -/
theorem contraction_geometric_decrease
    (S : MetricOracleSpace) (M : ContractionMetaOracle S)
    (h_fix : M.improve S.optimal = S.optimal)
    (f : S.Oracle) (n : ℕ) :
    dist (M.improve^[n] f) S.optimal ≤ M.k ^ n * dist f S.optimal := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ', Function.comp_apply]
    calc dist (M.improve (M.improve^[n] f)) S.optimal
        = dist (M.improve (M.improve^[n] f)) (M.improve S.optimal) := by rw [h_fix]
      _ ≤ M.k * dist (M.improve^[n] f) S.optimal := M.contraction _ _
      _ ≤ M.k * (M.k ^ n * dist f S.optimal) := by
          apply mul_le_mul_of_nonneg_left ih (le_of_lt M.k_pos)
      _ = M.k ^ (n + 1) * dist f S.optimal := by ring


/-- The contraction ratio k^n converges to 0, so the oracle converges to optimal. -/
theorem contraction_ratio_tendsto_zero
    (k : ℝ) (hk_pos : 0 < k) (hk_lt : k < 1) :
    Filter.Tendsto (fun n => k ^ n) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one (le_of_lt hk_pos) hk_lt


/-- Oracle entropy measures the per-step improvement rate.
For a contraction meta-oracle with ratio k, the entropy is -log(k).
Higher entropy = faster convergence. -/
def oracleEntropy (k : ℝ) (_hk_pos : 0 < k) (_hk_lt : k < 1) : ℝ :=
  -Real.log k


/-- Oracle entropy is positive for genuine contractions. -/
theorem oracleEntropy_pos (k : ℝ) (hk_pos : 0 < k) (hk_lt : k < 1) :
    0 < oracleEntropy k hk_pos hk_lt := by
  unfold oracleEntropy
  simp
  exact Real.log_neg hk_pos hk_lt


/-- Composing two contractions multiplies their ratios,
and the oracle entropy of the composition is the sum of entropies. -/
theorem oracleEntropy_additive (k₁ k₂ : ℝ)
    (hk₁_pos : 0 < k₁) (hk₁_lt : k₁ < 1)
    (hk₂_pos : 0 < k₂) (hk₂_lt : k₂ < 1)
    (hprod_pos : 0 < k₁ * k₂) (hprod_lt : k₁ * k₂ < 1) :
    oracleEntropy (k₁ * k₂) hprod_pos hprod_lt =
    oracleEntropy k₁ hk₁_pos hk₁_lt + oracleEntropy k₂ hk₂_pos hk₂_lt := by
  unfold oracleEntropy
  rw [Real.log_mul (ne_of_gt hk₁_pos) (ne_of_gt hk₂_pos)]
  ring


/-- A task is a pair of an oracle space and a quality measure on it. -/
structure OracleTask where
  Oracle : Type*
  q : Oracle → ℝ
  best : ℝ


/-- [Section: ## Part 5: Bounded Improvement (No-Free-Lunch for Meta-Oracles)] -/
theorem no_free_lunch_avg {n : ℕ} (hn : 0 < n)
    (σ : Fin n → Fin n) (hσ : Function.Bijective σ)
    (q : Fin n → ℝ) :
    ∑ i, (q (σ i) - q i) = 0 := by
  rw [ Finset.sum_sub_distrib, sub_eq_zero ];
  exact Equiv.sum_comp ( Equiv.ofBijective σ hσ ) q


/-- An adaptive meta-oracle maintains a parameter that controls its behavior.
The adaptation rule updates the parameter based on observed improvement. -/
structure AdaptiveMetaOracle (S : OracleSystem) (P : Type*) where
  improve : P → S.Oracle → S.Oracle
  adapt : P → S.Oracle → S.Oracle → P  -- old param → old oracle → new oracle → new param
  improving : ∀ p f, S.q f ≤ S.q (improve p f)


/-- One step of the adaptive meta-oracle: improve the oracle and adapt the parameter. -/
def AdaptiveMetaOracle.step {S : OracleSystem} {P : Type*}
    (M : AdaptiveMetaOracle S P) (state : P × S.Oracle) : P × S.Oracle :=
  let new_oracle := M.improve state.1 state.2
  let new_param := M.adapt state.1 state.2 new_oracle
  (new_param, new_oracle)


/-- Iterated adaptive improvement. -/
def AdaptiveMetaOracle.iterateAdaptive {S : OracleSystem} {P : Type*}
    (M : AdaptiveMetaOracle S P) : ℕ → P × S.Oracle → P × S.Oracle
  | 0 => id
  | n + 1 => M.step ∘ M.iterateAdaptive n


/-- Quality is non-decreasing under adaptive iteration. -/
theorem AdaptiveMetaOracle.quality_mono_adaptive {S : OracleSystem} {P : Type*}
    (M : AdaptiveMetaOracle S P) (p₀ : P) (f₀ : S.Oracle) (n : ℕ) :
    S.q f₀ ≤ S.q (M.iterateAdaptive n (p₀, f₀)).2 := by
  induction n with
  | zero => simp [AdaptiveMetaOracle.iterateAdaptive]
  | succ n ih =>
    simp [AdaptiveMetaOracle.iterateAdaptive, Function.comp,
          AdaptiveMetaOracle.step]
    exact le_trans ih (M.improving _ _)


end
