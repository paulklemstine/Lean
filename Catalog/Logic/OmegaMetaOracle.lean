import Mathlib

/-! # CatalogBuild.Logic.OmegaMetaOracle

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 20
-/

noncomputable section

/-- The one-point compactification of a locally compact Hausdorff space is compact.
This is the foundational fact enabling the Lift-Solve-Project paradigm. -/
theorem compact_onePoint (X : Type*) [TopologicalSpace X]
    [LocallyCompactSpace X] [T2Space X] :
    CompactSpace (OnePoint X) :=
  OnePoint.instCompactSpace

/-- On a compact space, every continuous real-valued function attains its supremum.
This is the "Solve" step: solutions exist on the compactified space. -/
theorem continuous_achieves_sup_on_compact {X : Type*} [TopologicalSpace X]
    [CompactSpace X] [Nonempty X] (f : X → ℝ) (hf : Continuous f) :
    ∃ x : X, ∀ y : X, f y ≤ f x := by
  obtain ⟨x, _, hx⟩ := IsCompact.exists_isMaxOn isCompact_univ Set.univ_nonempty
    hf.continuousOn
  exact ⟨x, fun y => hx (Set.mem_univ y)⟩

/-- **Lift-Solve-Project Theorem**: If a continuous function on the one-point
compactification attains its maximum at a finite point (not ∞), then that
point is a solution to the original optimization problem. -/
theorem lift_solve_project {X : Type*} [TopologicalSpace X]
    [LocallyCompactSpace X] [T2Space X]
    (f : OnePoint X → ℝ) (_hf : Continuous f)
    (x₀ : X) (hmax : ∀ y : OnePoint X, f y ≤ f (OnePoint.some x₀)) :
    ∀ y : X, f (OnePoint.some y) ≤ f (OnePoint.some x₀) :=
  fun y => hmax (OnePoint.some y)

/-- Points in X are separated from ∞ in the one-point compactification. -/
theorem finite_ne_omega (X : Type*) (x : X) :
    (OnePoint.some x : OnePoint X) ≠ OnePoint.infty :=
  OnePoint.coe_ne_infty x

/-- The embedding X ↪ OnePoint X is an open embedding. -/
theorem onePoint_isOpenEmbedding (X : Type*) [TopologicalSpace X] :
    Topology.IsOpenEmbedding (OnePoint.some : X → OnePoint X) :=
  OnePoint.isOpenEmbedding_coe

/-- A meta-oracle system: a complete metric space with a contractive self-map. -/
structure MetaOracleSystem where
  Space : Type*
  [instMetric : MetricSpace Space]
  [instComplete : CompleteSpace Space]
  [instNonempty : Nonempty Space]
  improve : Space → Space
  k : NNReal
  k_lt_one : k < 1
  contraction : ∀ x y, dist (improve x) (improve y) ≤ k * dist x y

attribute [instance] MetaOracleSystem.instMetric MetaOracleSystem.instComplete
  MetaOracleSystem.instNonempty

/-- A MetaOracleSystem determines a ContractingWith structure. -/
def MetaOracleSystem.contractingWith (S : MetaOracleSystem) :
    ContractingWith S.k S.improve := by
  refine ⟨S.k_lt_one, fun x y => ?_⟩
  calc edist (S.improve x) (S.improve y)
      = ENNReal.ofReal (dist (S.improve x) (S.improve y)) := edist_dist _ _
    _ ≤ ENNReal.ofReal (↑S.k * dist x y) :=
        ENNReal.ofReal_le_ofReal (S.contraction x y)
    _ = S.k * ENNReal.ofReal (dist x y) := by
        rw [ENNReal.ofReal_mul (NNReal.coe_nonneg S.k), ENNReal.ofReal_coe_nnreal]
    _ = S.k * edist x y := by rw [edist_dist]

/-- Every meta-oracle system has a unique fixed point (the "Omega Point" of
the oracle hierarchy). This is the Banach fixed-point theorem. -/
theorem meta_oracle_has_unique_fixed_point (S : MetaOracleSystem) :
    ∃! x : S.Space, S.improve x = x := by
  have hc := S.contractingWith
  refine ⟨ContractingWith.fixedPoint S.improve hc, hc.fixedPoint_isFixedPt, ?_⟩
  intro y hy
  exact hc.fixedPoint_unique hy

/-- The iterates of a contractive meta-oracle converge to the fixed point. -/
theorem meta_oracle_iterates_converge (S : MetaOracleSystem)
    (x₀ : S.Space) :
    ∃ ω : S.Space, S.improve ω = ω ∧
      Tendsto (fun n => S.improve^[n] x₀) atTop (nhds ω) := by
  have hc := S.contractingWith
  exact ⟨_, hc.fixedPoint_isFixedPt, hc.tendsto_iterate_fixedPoint x₀⟩

/-- Composition of contractive maps is contractive with product ratio. -/
theorem contraction_comp {X : Type*} [PseudoMetricSpace X]
    {f g : X → X} {kf kg : ℝ}
    (hf : ∀ x y, dist (f x) (f y) ≤ kf * dist x y)
    (hg : ∀ x y, dist (g x) (g y) ≤ kg * dist x y)
    (hkf : 0 ≤ kf) :
    ∀ x y, dist (f (g x)) (f (g y)) ≤ (kf * kg) * dist x y := by
  intro x y
  calc dist (f (g x)) (f (g y))
      ≤ kf * dist (g x) (g y) := hf _ _
    _ ≤ kf * (kg * dist x y) := by apply mul_le_mul_of_nonneg_left (hg x y) hkf
    _ = (kf * kg) * dist x y := by ring

/-- The improvement rate of composed meta-oracles: entropy is additive. -/
theorem meta_oracle_entropy_additive {k₁ k₂ : ℝ}
    (hk₁ : 0 < k₁) (hk₂ : 0 < k₂) :
    -Real.log (k₁ * k₂) = -Real.log k₁ + (-Real.log k₂) := by
  rw [Real.log_mul (ne_of_gt hk₁) (ne_of_gt hk₂)]
  ring

/-- Oracle entropy is positive for genuine contractions. -/
theorem oracle_entropy_pos {k : ℝ} (hk_pos : 0 < k) (hk_lt : k < 1) :
    0 < -Real.log k := by
  simp; exact Real.log_neg hk_pos hk_lt

/-- max is continuous as a function ℝ × ℝ → ℝ -/
theorem max_continuous' : Continuous (fun p : ℝ × ℝ => max p.1 p.2) :=
  continuous_fst.max continuous_snd

/-- **Tropical Soft-Max Bound**: The soft-max (log-sum-exp) is an upper bound for
the true max, connecting smooth optimization to tropical combinatorics. -/
theorem tropical_softmax_bound {n : ℕ} [NeZero n] (x : Fin n → ℝ) (i : Fin n) :
    x i ≤ Real.log (∑ j : Fin n, Real.exp (x j)) := by
  calc x i = Real.log (Real.exp (x i)) := (Real.log_exp _).symm
    _ ≤ Real.log (∑ j : Fin n, Real.exp (x j)) := by
        apply Real.log_le_log (Real.exp_pos _)
        exact Finset.single_le_sum (fun j _ => le_of_lt (Real.exp_pos _))
          (Finset.mem_univ i)

/-- Exponential preserves max (since it's strictly monotone). -/
theorem exp_preserves_max' (x y : ℝ) :
    Real.exp (max x y) = max (Real.exp x) (Real.exp y) := by
  rcases le_total x y with h | h
  · simp [max_eq_right h, max_eq_right (Real.exp_le_exp.mpr h)]
  · simp [max_eq_left h, max_eq_left (Real.exp_le_exp.mpr h)]

/-- Pauli X matrix squares to identity -/
theorem pauli_X_sq :
    !![0, 1; 1, 0] * !![0, 1; 1, 0] = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]

/-- Pauli Z matrix squares to identity -/
theorem pauli_Z_sq :
    !![1, 0; 0, -1] * !![1, 0; 0, -1] = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]

/-- Hadamard-like: H² = 2·I -/
theorem hadamard_sq :
    !![1, 1; 1, -1] * !![1, 1; 1, -1] = (2 : ℤ) • (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]

/-- **The Omega Meta-Oracle Convergence Theorem**:
Given a complete metric space, a contractive map, and any starting point,
the iterates converge to the unique fixed point. -/
theorem omega_meta_oracle_convergence
    {X : Type*} [MetricSpace X] [CompleteSpace X] [Nonempty X]
    {T : X → X} {k : NNReal} (hk1 : k < 1)
    (hT : ∀ x y, dist (T x) (T y) ≤ k * dist x y)
    (x₀ : X) :
    ∃ ω : X, T ω = ω ∧ Tendsto (fun n => T^[n] x₀) atTop (nhds ω) :=
  meta_oracle_iterates_converge ⟨X, T, k, hk1, hT⟩ x₀

/-- **Distance decay**: After n iterations, distance to the fixed point
decays geometrically. -/
theorem meta_oracle_geometric_decay
    {X : Type*} [MetricSpace X]
    {T : X → X} {k : NNReal}
    (hT : ∀ x y, dist (T x) (T y) ≤ k * dist x y)
    (x₀ : X) (n : ℕ) :
    dist (T^[n] x₀) (T^[n + 1] x₀) ≤ k ^ n * dist x₀ (T x₀) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ', Function.iterate_succ', Function.comp_apply,
        Function.comp_apply, pow_succ]
    calc dist (T (T^[n] x₀)) (T (T^[n + 1] x₀))
        ≤ k * dist (T^[n] x₀) (T^[n + 1] x₀) := hT _ _
      _ ≤ k * (k ^ n * dist x₀ (T x₀)) := by
          apply mul_le_mul_of_nonneg_left ih (NNReal.coe_nonneg k)
      _ = ↑k ^ (n + 1) * dist x₀ (T x₀) := by push_cast; ring

end
