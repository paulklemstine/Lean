/-! # CatalogBuild.Algebra.IntegerEnergy.StrangeLoops

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 8
-/

import Mathlib

/-- A hierarchical system with levels -/
structure HierarchicalSystem where
  Level : Type
  levelOrder : LinearOrder Level
  Content : Level → Type
  upward : ∀ {l₁ l₂ : Level}, @LT.lt Level levelOrder.toLT l₁ l₂ → Content l₁ → Content l₂





/-- A tangled hierarchy: a hierarchical system with a strange loop -/
structure TangledHierarchy extends HierarchicalSystem where
  loop : StrangeLoop toHierarchicalSystem





/-- A self-model: a system that contains a representation of itself -/
structure SelfModel where
  System : Type
  Model : Type
  embed : Model → System
  project : System → Model
  reflects : ∀ m : Model, project (embed m) = m





/-- [Section: # CatalogBuild.MachineLearning.Consciousness.StrangeLoops
Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 8] -/
theorem self_model_is_strange_loop (S : SelfModel) :
    Function.LeftInverse S.project S.embed := by
  exact S.reflects





/-- The "I" as a fixed point -/
structure SelfAsFixedPoint where
  SelfConcept : Type
  reflect : SelfConcept → SelfConcept
  stableSelf : SelfConcept
  is_fixed : reflect stableSelf = stableSelf





/-- [Section: # CatalogBuild.MachineLearning.Consciousness.StrangeLoops
Auto-generated from theorem catalog database.
Domain: MachineLearning/Consciousness
Declarations: 8] -/
theorem unique_self_from_contraction
    (X : Type) [MetricSpace X] [CompleteSpace X] [Nonempty X]
    (f : X → X) (k : ℝ) (hk : k < 1) (hk0 : 0 ≤ k)
    (hf : ∀ x y, dist (f x) (f y) ≤ k * dist x y) :
    ∃! x : X, f x = x := by
  obtain ⟨x, hx⟩ : ∃ x : X, f x = x := by
    -- By the properties of the contraction mapping, the sequence $x_n = f^n(x_0)$ converges to a fixed point.
    have h_seq_converges : ∀ x₀ : X, ∃ x : X, Filter.Tendsto (fun n => f^[n] x₀) Filter.atTop (nhds x) := by
      intro x₀
      have h_seq_cauchy : CauchySeq (fun n => f^[n] x₀) := by
        -- We'll use induction to show that the distance between consecutive terms of the sequence is bounded by $k^n$ times the distance between $x₀$ and $f(x₀)$.
        have h_dist : ∀ n, dist (f^[n] x₀) (f^[n+1] x₀) ≤ k^n * dist x₀ (f x₀) := by
          intro n; induction n <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] ; exact le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ‹_› hk0 ) ;
        fapply cauchySeq_of_le_geometric;
        exacts [ k, dist x₀ ( f x₀ ), hk, fun n => by simpa only [ mul_comm ] using h_dist n ]
      exact (by
      exact cauchySeq_tendsto_of_complete h_seq_cauchy)

    -- Since $f$ is continuous, the limit of $f^n(x₀)$ as $n$ approaches infinity is also a fixed point.
    have h_cont : Continuous f := by
      rw [ Metric.continuous_iff ];
      exact fun x ε ε_pos => ⟨ ε, ε_pos, fun y hy => lt_of_le_of_lt ( hf _ _ ) ( by nlinarith ) ⟩;
    obtain ⟨ x, hx ⟩ := h_seq_converges ( Classical.arbitrary X ) ; exact ⟨ x, tendsto_nhds_unique ( by erw [ ← Filter.tendsto_add_atTop_iff_nat 1 ] ; simpa only [ Function.iterate_succ_apply' ] using h_cont.continuousAt.tendsto.comp hx ) hx ⟩ ;
  exact ⟨ x, hx, fun y hy => by_contra fun h => absurd ( hf y x ) ( by aesop ) ⟩





/-- A Gödel-style strange loop -/
structure GoedelLoop where
  Sentence : Type
  provable : Sentence → Prop
  goedelSentence : Sentence
  goedel_property : provable goedelSentence ↔ ¬ provable goedelSentence → True





/-- Isomorphism between strange loops -/
def StrangeLoopIso (H : HierarchicalSystem) (l₁ l₂ : StrangeLoop H) : Prop :=
  ∃ (f : H.Content l₁.start → H.Content l₂.start)
    (g : H.Content l₂.start → H.Content l₁.start),
    Function.LeftInverse g f ∧ Function.RightInverse g f




