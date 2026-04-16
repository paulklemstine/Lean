/-! # CatalogBuild.Computation.Oracles.MetaOracleFiveQuestions

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 15
-/

import Mathlib

noncomputable section

/-- A conjecture refinement system. -/
structure ConjectureSystem where
  Conjecture : Type*
  [instLattice : CompleteLattice Conjecture]
  refine : Conjecture → Conjecture
  mono : Monotone refine

attribute [instance] ConjectureSystem.instLattice



/-- The least pre-fixed point of the refinement map. -/
def ConjectureSystem.leastFixedPoint (S : ConjectureSystem) : S.Conjecture :=
  sInf {x | S.refine x ≤ x}



/-- The least pre-fixed point is a pre-fixed point. -/
theorem ConjectureSystem.refine_le_lfp (S : ConjectureSystem) :
    S.refine S.leastFixedPoint ≤ S.leastFixedPoint := by
  unfold ConjectureSystem.leastFixedPoint
  apply le_sInf
  intro x hx
  exact le_trans (S.mono (sInf_le hx)) hx



/-- The least pre-fixed point is a fixed point. -/
theorem ConjectureSystem.lfp_is_fixed_point (S : ConjectureSystem) :
    S.refine S.leastFixedPoint = S.leastFixedPoint := by
  apply le_antisymm
  · exact S.refine_le_lfp
  · apply sInf_le
    exact S.mono S.refine_le_lfp



/-- **Theorem Discovery**: Every monotone refinement system has a fixed point. -/
theorem theorem_discovery (S : ConjectureSystem) :
    ∃ p : S.Conjecture, S.refine p = p :=
  ⟨S.leastFixedPoint, S.lfp_is_fixed_point⟩



/-- An oracle improvement system with quality measure and capacity bound. -/
structure QualityOracleSystem where
  Oracle : Type*
  quality : Oracle → ℝ
  improve : Oracle → Oracle
  improving : ∀ f, quality f ≤ quality (improve f)
  capacity : ℝ
  capacity_pos : 0 < capacity



/-- Quality is monotonically non-decreasing under iteration. -/
theorem quality_mono_iter (S : QualityOracleSystem) (f : S.Oracle) (n : ℕ) :
    S.quality f ≤ S.quality (S.improve^[n] f) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply']
    exact le_trans ih (S.improving _)



/-- The per-step quality improvement is bounded by capacity. -/
theorem quality_bounded_by_capacity (S : QualityOracleSystem)
    (bound : ∀ f, S.quality (S.improve f) - S.quality f ≤ S.capacity)
    (f : S.Oracle) (n : ℕ) :
    S.quality (S.improve^[n] f) - S.quality f ≤ n * S.capacity := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply']
    have h1 := bound (S.improve^[n] f)
    push_cast
    linarith



/-- A contraction on a metric space. -/
structure ContractionMap (X : Type*) [MetricSpace X] where
  f : X → X
  k : ℝ
  k_nonneg : 0 ≤ k
  k_lt_one : k < 1
  contract : ∀ x y, dist (f x) (f y) ≤ k * dist x y



/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleFiveQuestions
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 15] -/
theorem ContractionMap.iterate_dist_le {X : Type*} [MetricSpace X]
    (C : ContractionMap X) (x y : X) (n : ℕ) :
    dist (C.f^[n] x) (C.f^[n] y) ≤ C.k ^ n * dist x y := by
  induction' n with n ih generalizing x y;
  · simp;
  · simpa only [ Function.iterate_succ_apply', pow_succ', mul_assoc ] using le_trans ( C.contract _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ _ ) C.k_nonneg )



theorem ContractionMap.consecutive_dist {X : Type*} [MetricSpace X]
    (C : ContractionMap X) (x : X) (n : ℕ) :
    dist (C.f^[n + 1] x) (C.f^[n] x) ≤ C.k ^ n * dist (C.f x) x := by
  convert ContractionMap.iterate_dist_le C ( C.f x ) x n using 1



theorem contraction_orbit_cauchy {X : Type*} [MetricSpace X]
    (C : ContractionMap X) (x : X) :
    CauchySeq (fun n => C.f^[n] x) := by
  fapply cauchySeq_of_le_geometric;
  exacts [ C.k, dist ( C.f x ) x, C.k_lt_one, fun n => by simpa [ dist_comm, mul_comm ] using ContractionMap.consecutive_dist C x n ]



theorem epsilon_omega_convergence {X : Type*} [MetricSpace X] [CompleteSpace X]
    (C : ContractionMap X) (x : X) :
    ∃ omega : X, C.f omega = omega ∧ Tendsto (fun n => C.f^[n] x) atTop (nhds omega) := by
  -- By the properties of the contraction mapping, the sequence $x_n = C.f^n(x)$ is Cauchy and thus converges to some limit $\omega$.
  obtain ⟨omega, h_omega⟩ : ∃ omega, Filter.Tendsto (fun n => C.f^[n] x) Filter.atTop (nhds omega) := by
    exact cauchySeq_tendsto_of_complete ( contraction_orbit_cauchy C x );
  refine' ⟨ omega, _, h_omega ⟩;
  have h_cont : Continuous C.f := by
    rw [ Metric.continuous_iff ];
    exact fun y ε εpos => ⟨ ε, εpos, fun z hz => lt_of_le_of_lt ( C.contract z y ) ( by nlinarith [ C.k_nonneg, C.k_lt_one ] ) ⟩;
  exact tendsto_nhds_unique ( h_cont.continuousAt.tendsto.comp h_omega ) ( h_omega.comp ( Filter.tendsto_add_atTop_nat 1 ) |> Filter.Tendsto.congr ( by simp +decide [ Function.iterate_succ_apply' ] ) )



theorem contraction_fixed_point_unique {X : Type*} [MetricSpace X]
    (C : ContractionMap X) (p q : X) (hp : C.f p = p) (hq : C.f q = q) :
    p = q := by
  by_contra h_neq;
  exact absurd ( C.contract p q ) ( by rw [ hp, hq ] ; nlinarith [ dist_pos.2 h_neq, C.k_nonneg, C.k_lt_one ] )



/-- The quadratic speedup ratio: √N < N for N > 1. -/
theorem quadratic_speedup_ratio (N : ℕ) (hN : 1 < N) :
    Nat.sqrt N < N :=
  Nat.sqrt_lt_self hN



end
