import Mathlib

/-!
# Finite Kantorovich optimal transport

We formalize the Kantorovich optimal transport problem in the finite (discrete)
setting, where source masses live on `Fin n` and target masses on `Fin m`.

A *transport plan* (coupling) `π : Fin n → Fin m → ℝ` is a nonnegative matrix whose
row marginals equal the source masses `a` and whose column marginals equal the
target masses `b`.  The *transport cost* w.r.t. a cost matrix `c` is
`∑ i, ∑ j, π i j * c i j`.

The main results are:

* `productPlan_isTransportPlan` — the independent coupling `a ⊗ b` is feasible
  whenever `a`, `b` are probability vectors, so the feasible set is nonempty;
* `isCompact_feasibleSet` — the feasible polytope is compact (closed + bounded in
  a finite-dimensional space);
* `exists_optimal_plan` — **existence of an optimal transport plan**: the
  Kantorovich infimum is attained.  This is the discrete Kantorovich existence
  theorem.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): in the finite setting the Kantorovich problem is a
linear program over a transportation polytope; existence of a minimizer should
follow from compactness of the feasible set and continuity of the linear cost.
Experiment (Experimenter): define plans/cost/feasible set over `ℝ`, prove the
product coupling is feasible (nonemptiness), prove the feasible set is closed and
bounded hence compact, and conclude existence via `IsCompact.exists_isMinOn`.
Analysis (Analyst): the only delicate point is the bound — each entry is squeezed
between `0` and its row sum `a i`, and row sums are nonnegative because they are
sums of nonnegative entries, so the whole polytope sits in a fixed ball.
Critique (Critic): existence does not need `a`, `b` to be probability vectors, only
nonemptiness of the feasible set; we keep `exists_optimal_plan` maximally general
and provide nonemptiness separately for probability vectors.
-- !-- end Lab Notes -- !--
-/

namespace Novelty.OptimalTransport

open scoped BigOperators
open Set

variable {n m : ℕ}

/-- `π` is a transport plan (coupling) between source masses `a` and target masses
`b`: it is entrywise nonnegative, its row marginals equal `a`, and its column
marginals equal `b`. -/
def IsTransportPlan (a : Fin n → ℝ) (b : Fin m → ℝ) (π : Fin n → Fin m → ℝ) : Prop :=
  (∀ i j, 0 ≤ π i j) ∧ (∀ i, ∑ j, π i j = a i) ∧ (∀ j, ∑ i, π i j = b j)

/-- The total Kantorovich transport cost of a plan `π` w.r.t. cost matrix `c`. -/
def transportCost (c : Fin n → Fin m → ℝ) (π : Fin n → Fin m → ℝ) : ℝ :=
  ∑ i, ∑ j, π i j * c i j

/-- The feasible set (transportation polytope) of plans between `a` and `b`. -/
def feasibleSet (a : Fin n → ℝ) (b : Fin m → ℝ) : Set (Fin n → Fin m → ℝ) :=
  {π | IsTransportPlan a b π}

/-- The independent coupling `a ⊗ b`, `π i j = a i * b j`. -/
def productPlan (a : Fin n → ℝ) (b : Fin m → ℝ) : Fin n → Fin m → ℝ :=
  fun i j => a i * b j

/-
The independent coupling of two probability vectors is a transport plan.
-/
theorem productPlan_isTransportPlan (a : Fin n → ℝ) (b : Fin m → ℝ)
    (ha : ∀ i, 0 ≤ a i) (hb : ∀ j, 0 ≤ b j)
    (ha1 : ∑ i, a i = 1) (hb1 : ∑ j, b j = 1) :
    IsTransportPlan a b (productPlan a b) := by
  constructor;
  · exact fun i j => mul_nonneg ( ha i ) ( hb j );
  · unfold productPlan; simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] ;

/-- For probability vectors the feasible set is nonempty. -/
theorem feasibleSet_nonempty (a : Fin n → ℝ) (b : Fin m → ℝ)
    (ha : ∀ i, 0 ≤ a i) (hb : ∀ j, 0 ≤ b j)
    (ha1 : ∑ i, a i = 1) (hb1 : ∑ j, b j = 1) :
    (feasibleSet a b).Nonempty :=
  ⟨productPlan a b, productPlan_isTransportPlan a b ha hb ha1 hb1⟩

/-- The transport cost functional is continuous in the plan. -/
theorem continuous_transportCost (c : Fin n → Fin m → ℝ) :
    Continuous (transportCost c) := by
  unfold transportCost
  fun_prop

/-
The feasible set is closed.
-/
theorem isClosed_feasibleSet (a : Fin n → ℝ) (b : Fin m → ℝ) :
    IsClosed (feasibleSet a b) := by
  unfold feasibleSet;
  simp +decide only [IsTransportPlan, setOf_and, setOf_forall];
  refine' IsClosed.inter _ _;
  · exact isClosed_iInter fun i => isClosed_iInter fun j => isClosed_le continuous_const <| continuous_apply _ |> Continuous.comp <| continuous_apply _;
  · refine' IsClosed.inter _ _;
    · exact isClosed_iInter fun i => isClosed_eq ( continuous_finset_sum _ fun j _ => continuous_apply _ |> Continuous.comp <| continuous_apply _ ) continuous_const;
    · exact isClosed_iInter fun i => isClosed_eq ( continuous_finset_sum _ fun _ _ => continuous_apply _ |> Continuous.comp <| continuous_apply _ ) continuous_const

/-
The feasible set is bounded.
-/
theorem isBounded_feasibleSet (a : Fin n → ℝ) (b : Fin m → ℝ) :
    Bornology.IsBounded (feasibleSet a b) := by
  refine' isBounded_iff_forall_norm_le.mpr ⟨ ∑ i, |a i| + ∑ j, |b j| + 1, fun f hf => _ ⟩;
  refine' pi_norm_le_iff_of_nonneg ( by positivity ) |>.2 _;
  intro i; rw [ pi_norm_le_iff_of_nonneg ];
  · intro j; rw [ Real.norm_eq_abs ] ; cases abs_cases ( f i j ) <;> cases abs_cases ( a i ) <;> cases abs_cases ( b j ) <;> linarith [ hf.1 i j, hf.2.1 i, hf.2.2 j, Finset.single_le_sum ( fun i _ => abs_nonneg ( a i ) ) ( Finset.mem_univ i ), Finset.single_le_sum ( fun j _ => abs_nonneg ( b j ) ) ( Finset.mem_univ j ), Finset.single_le_sum ( fun j _ => show 0 ≤ f i j from hf.1 i j ) ( Finset.mem_univ j ) ] ;
  · exact add_nonneg ( add_nonneg ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) ( Finset.sum_nonneg fun _ _ => abs_nonneg _ ) ) zero_le_one

/-- The feasible transportation polytope is compact. -/
theorem isCompact_feasibleSet (a : Fin n → ℝ) (b : Fin m → ℝ) :
    IsCompact (feasibleSet a b) :=
  Metric.isCompact_of_isClosed_isBounded (isClosed_feasibleSet a b) (isBounded_feasibleSet a b)

/-- **Kantorovich existence theorem (finite case).** Whenever the feasible set is
nonempty, the Kantorovich optimal transport problem admits an optimal plan: there
is a feasible plan whose cost is minimal among all feasible plans. -/
theorem exists_optimal_plan (a : Fin n → ℝ) (b : Fin m → ℝ) (c : Fin n → Fin m → ℝ)
    (hne : (feasibleSet a b).Nonempty) :
    ∃ π ∈ feasibleSet a b,
      ∀ π' ∈ feasibleSet a b, transportCost c π ≤ transportCost c π' := by
  convert ( IsCompact.exists_isMinOn ( isCompact_feasibleSet a b ) hne ( continuous_transportCost c |> Continuous.continuousOn ) ) using 1

end Novelty.OptimalTransport