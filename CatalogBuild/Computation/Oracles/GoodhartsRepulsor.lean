/-! # CatalogBuild.Computation.Oracles.GoodhartsRepulsor

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/

import Mathlib

noncomputable section

/-- A metric space with a true objective and a proxy objective. -/
structure GoodhartSystem where
  State : Type*
  trueObj : State → ℝ
  proxyObj : State → ℝ
  step : State → State
  proxy_nondecreasing : ∀ s, proxyObj s ≤ proxyObj (step s)


/-- **Goodhart divergence**: If the proxy is not perfectly aligned,
then there exist states where proxy optimization decreases the true objective. -/
theorem goodhart_divergence_exists (G : GoodhartSystem)
    (h_misaligned : ∃ s, G.proxyObj (G.step s) > G.proxyObj s ∧
                         G.trueObj (G.step s) < G.trueObj s) :
    ∃ s, G.trueObj (G.step s) < G.trueObj s := by
  obtain ⟨s, _, h2⟩ := h_misaligned; exact ⟨s, h2⟩


/-- A fixed point is a **repulsor** if nearby perturbations move away from it. -/
def IsRepulsor {X : Type*} [MetricSpace X] (f : X → X) (x0 : X) : Prop :=
  f x0 = x0 ∧ ∃ eps : ℝ, eps > 0 ∧ ∀ x, 0 < dist x x0 → dist x x0 < eps →
    dist (f x) x0 > dist x x0


/-- A fixed point is an **attractor** if nearby points converge to it. -/
def IsAttractor {X : Type*} [MetricSpace X] (f : X → X) (x0 : X) : Prop :=
  f x0 = x0 ∧ ∃ eps : ℝ, eps > 0 ∧ ∀ x, dist x x0 < eps →
    dist (f x) x0 ≤ dist x x0


theorem not_attractor_and_repulsor {X : Type*} [MetricSpace X]
    (f : X → X) (x0 : X)
    (hrep : IsRepulsor f x0) (hatt : IsAttractor f x0)
    (hwitness : ∃ x, 0 < dist x x0 ∧ dist x x0 < min hrep.2.choose hatt.2.choose) :
    False := by
      grind +splitIndPred


/-- An oracle that optimizes its own predictions. -/
structure SelfOptimizingOracle where
  State : Type*
  predict : State → ℝ
  optimize : State → State
  predict_nondecreasing : ∀ s, predict s ≤ predict (optimize s)


theorem self_optimizing_bounded_convergence (O : SelfOptimizingOracle)
    (s0 : O.State) :
    Monotone (fun n => O.predict (O.optimize^[n] s0)) := by
      -- Use induction to show that predict(opt^[n] s0) ≤ predict(opt^[n+1] s0) for all n.
      have h_inductive : ∀ n : ℕ, O.predict (O.optimize^[n] s0) ≤ O.predict (O.optimize^[n+1] s0) := by
        exact fun n => by simpa only [ Function.iterate_succ_apply' ] using O.predict_nondecreasing _;
      exact monotone_nat_of_le_succ h_inductive


/-- The near-optimal set for an objective function. -/
def nearOptimalSet {alpha : Type*} (f : alpha → ℝ) (eps : ℝ) (M : ℝ) : Set alpha :=
  {x | f x ≥ M - eps}


/-- Intersection of near-optimal sets is contained in each individual set. -/
theorem multi_proxy_contained {alpha : Type*} (f g : alpha → ℝ) (eps : ℝ) (Mf Mg : ℝ) :
    nearOptimalSet f eps Mf ∩ nearOptimalSet g eps Mg ⊆ nearOptimalSet f eps Mf :=
  Set.inter_subset_left


/-- Model of alignment decay: over time, the proxy diverges from truth. -/
def alignmentDecay (initialCorrelation decayRate : ℝ) (t : ℕ) : ℝ :=
  initialCorrelation * decayRate ^ t


theorem alignment_monotone_decay (c r : ℝ) (hc : 0 ≤ c) (hr : 0 ≤ r) (hr1 : r ≤ 1) :
    Antitone (fun t => alignmentDecay c r t) := by
      exact fun x y hxy => mul_le_mul_of_nonneg_left ( pow_le_pow_of_le_one hr hr1 hxy ) hc


theorem alignment_tendsto_zero (c r : ℝ) (hc : 0 ≤ c) (hr : 0 ≤ r) (hr1 : r < 1) :
    Filter.Tendsto (fun t => alignmentDecay c r t) Filter.atTop (nhds 0) := by
      simpa [ alignmentDecay, mul_comm ] using tendsto_const_nhds.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one hr hr1 )


end
