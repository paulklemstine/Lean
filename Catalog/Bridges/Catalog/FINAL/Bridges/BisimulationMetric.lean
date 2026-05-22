import Mathlib

/-!
# Functorial Bisimulation Pseudometric for Reversible Temporal Circuits

This file develops a quantitative semantics layer for circuit-like state machines
using Lawvere-enriched pseudometrics over `ℝ≥0∞`. The main result is that the
**least prefixed point** of the one-step behavioral lifting operator, among all
Lawvere pseudometrics, exists and can be computed by monotone iteration from below.

## Main definitions

* `MetricPred α` — candidate distance functions `α → α → ℝ≥0∞`
* `LawverePseudoMetric α` — bundled pseudometric with reflexivity and triangle inequality
* `stepLift` — the one-step behavioral lifting operator for deterministic systems
* `iterStep` — iterative computation of the bisimulation pseudometric
* `botMetric` — the zero (bottom) metric

## Main results

* `stepLift_monotone` — the lifting operator is monotone on candidate distances
* `stepLift_refl` — the lifting preserves reflexivity
* `stepLift_triangle` — the lifting preserves the triangle inequality
* `iterStep_monotone` — iterates form a monotone ascending chain
* `iterStep_refl` — all iterates satisfy reflexivity
* `exists_least_bisimulation_metric_finite` — existence of the least prefixed
  bisimulation pseudometric
* `least_metric_eq_iSup_iter` — the least metric equals the supremum of iterates
* `seq_nonexpansive` — sequential composition is nonexpansive
* `prod_nonexpansive_sup` — parallel composition is nonexpansive under sup-product metric

## References

The construction is inspired by:
- Lawvere's enriched category perspective on metric spaces
- Bisimulation metrics from coalgebraic semantics (de Alfaro, Majumdar, et al.)
- Traced monoidal categories and feedback semantics
-/

noncomputable section

open ENNReal

/-! ## Candidate distance functions -/

/-- A candidate distance function on a type `α`, valued in `ℝ≥0∞`. -/
def MetricPred (α : Type*) := α → α → ℝ≥0∞

instance {α : Type*} : LE (MetricPred α) :=
  ⟨fun d e => ∀ x y, d x y ≤ e x y⟩

instance {α : Type*} : Preorder (MetricPred α) where
  le := fun d e => ∀ x y, d x y ≤ e x y
  le_refl := fun d x y => le_refl _
  le_trans := fun d e f hde hef x y => le_trans (hde x y) (hef x y)

/-- The zero (bottom) metric: all distances are 0. -/
def botMetric (σ : Type*) : MetricPred σ := fun _ _ => 0

/-- The top metric: all distances are ⊤. -/
def topMetric (σ : Type*) : MetricPred σ := fun _ _ => ⊤

theorem botMetric_le {σ : Type*} (d : MetricPred σ) : botMetric σ ≤ d :=
  fun _ _ => zero_le _

/-! ## Lawvere pseudometric structure -/

/-- A Lawvere pseudometric: reflexive and satisfying the triangle inequality,
    but not necessarily symmetric. Valued in `ℝ≥0∞` (the Lawvere quantale). -/
structure LawverePseudoMetric (α : Type*) where
  /-- The distance function -/
  dist : MetricPred α
  /-- Reflexivity: distance from a point to itself is zero -/
  refl : ∀ x, dist x x = 0
  /-- Triangle inequality -/
  triangle : ∀ x y z, dist x z ≤ dist x y + dist y z

/-- Predicate for symmetry of a candidate distance. -/
def IsSymmetricLawvere {α : Type*} (d : α → α → ℝ≥0∞) : Prop :=
  ∀ x y, d x y = d y x

/-! ## One-step behavioral lifting operator -/

/-- The one-step behavioral lifting operator for a deterministic system.
    Given an observation distance `obsDist`, an output function `out`,
    and a transition function `next`, lifts a candidate distance `d` to
    the max of the observation distance and the recursive distance. -/
def stepLift
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ)
    (d : MetricPred σ) : MetricPred σ :=
  fun s t => obsDist (out s) (out t) ⊔ d (next s) (next t)

/-! ## Monotonicity of the lifting operator -/

/-
The step lifting operator is monotone: if `d ≤ e` pointwise, then
    `stepLift ... d ≤ stepLift ... e` pointwise.
-/
theorem stepLift_monotone
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ) :
    Monotone (stepLift obsDist out next) := by
  exact fun d e hde x y => sup_le_sup le_rfl ( hde _ _ )

/-! ## Preservation of pseudometric axioms -/

/-
The step lifting preserves reflexivity.
-/
theorem stepLift_refl
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (hout_refl : ∀ w, obsDist w w = 0)
    (out : σ → ω)
    (next : σ → σ)
    (d : MetricPred σ)
    (hd_refl : ∀ s, d s s = 0) :
    ∀ s, stepLift obsDist out next d s s = 0 := by
  unfold stepLift; aesop;

/-
The step lifting preserves the triangle inequality.
-/
theorem stepLift_triangle
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (hout_tri : ∀ a b c, obsDist a c ≤ obsDist a b + obsDist b c)
    (out : σ → ω)
    (next : σ → σ)
    (d : MetricPred σ)
    (hd_tri : ∀ s t u, d s u ≤ d s t + d t u) :
    ∀ s t u,
      stepLift obsDist out next d s u
        ≤ stepLift obsDist out next d s t + stepLift obsDist out next d t u := by
  intro s t u; unfold stepLift;
  exact max_le ( le_trans ( hout_tri _ _ _ ) ( add_le_add ( le_max_left _ _ ) ( le_max_left _ _ ) ) ) ( le_trans ( hd_tri _ _ _ ) ( add_le_add ( le_max_right _ _ ) ( le_max_right _ _ ) ) )

/-
The step lifting preserves symmetry.
-/
theorem stepLift_symmetric
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (hobs_sym : IsSymmetricLawvere obsDist)
    (out : σ → ω)
    (next : σ → σ)
    (d : MetricPred σ)
    (hd_sym : IsSymmetricLawvere d) :
    IsSymmetricLawvere (stepLift obsDist out next d) := by
  exact fun x y => by unfold stepLift; rw [ hobs_sym, hd_sym ] ;

/-! ## Iterative computation -/

/-- Iterative computation of the bisimulation pseudometric: apply `stepLift` `n` times
    starting from the zero metric. -/
def iterStep
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ) : ℕ → MetricPred σ
  | 0 => botMetric σ
  | n + 1 => stepLift obsDist out next (iterStep obsDist out next n)

/-
The iterates form a monotonically ascending chain.
-/
theorem iterStep_monotone
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ) :
    ∀ n s t, iterStep obsDist out next n s t ≤ iterStep obsDist out next (n + 1) s t := by
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · exact fun s t => botMetric_le _ s t;
  · apply_rules [ stepLift_monotone ]

/-
All iterates satisfy reflexivity.
-/
theorem iterStep_refl
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (hout_refl : ∀ w, obsDist w w = 0)
    (out : σ → ω)
    (next : σ → σ) :
    ∀ n s, iterStep obsDist out next n s s = 0 := by
  -- By induction on $n$, we can show that the reflexive property holds for all iterates.
  intro n
  induction' n with n ih
  · -- Base case: $n = 0$
    intro s
    simp [iterStep, botMetric]
  · -- Inductive step: Assume for $n$, prove for $n + 1$
    intro s
    simp [iterStep, stepLift, ih, hout_refl]

/-! ## Least bisimulation pseudometric -/

/-- The supremum of all iterates, which gives the least bisimulation pseudometric. -/
def supIterMetric
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ) : MetricPred σ :=
  fun s t => ⨆ n, iterStep obsDist out next n s t

/-
The supremum of iterates is reflexive.
-/
theorem supIterMetric_refl
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (hout_refl : ∀ w, obsDist w w = 0)
    (out : σ → ω)
    (next : σ → σ) :
    ∀ s, supIterMetric obsDist out next s s = 0 := by
  intro s
  unfold supIterMetric
  simp [iterStep_refl obsDist hout_refl out next]

/-
The supremum of iterates is a prefixed point of `stepLift`.
-/
theorem supIterMetric_prefixed
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ) :
    ∀ s t, stepLift obsDist out next (supIterMetric obsDist out next) s t
      ≤ supIterMetric obsDist out next s t := by
  refine' fun s t => sup_le _ _;
  · refine' le_trans _ ( le_iSup _ 1 );
    exact le_sup_left;
  · refine' iSup_le fun n => _;
    refine' le_trans _ ( le_iSup _ ( n + 1 ) );
    exact le_sup_right

/-
The supremum of iterates is below any prefixed point.
-/
theorem supIterMetric_least
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ)
    (d : MetricPred σ)
    (hpre : ∀ s t, stepLift obsDist out next d s t ≤ d s t) :
    ∀ s t, supIterMetric obsDist out next s t ≤ d s t := by
  -- By definition of `supIterMetric`, we know that for any `s` and `t`, `supIterMetric obsDist out next s t` is the supremum of the iterates `iterStep obsDist out next n s t`.
  intro s t
  apply iSup_le;
  intro n;
  induction' n with n ih generalizing s t;
  · exact botMetric_le _ _ _;
  · exact le_trans ( stepLift_monotone obsDist out next ih s t ) ( hpre s t )

/-
**Main theorem**: Existence of the least bisimulation pseudometric as a prefixed
    point of the step lifting operator, among all Lawvere pseudometrics.
-/
theorem exists_least_bisimulation_metric_finite
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (hout_refl : ∀ w, obsDist w w = 0)
    (hout_tri : ∀ a b c, obsDist a c ≤ obsDist a b + obsDist b c)
    (out : σ → ω)
    (next : σ → σ) :
    ∃ d : MetricPred σ,
      (∀ s, d s s = 0) ∧
      (∀ s t u, d s u ≤ d s t + d t u) ∧
      (∀ s t, stepLift obsDist out next d s t ≤ d s t) ∧
      (∀ d' : MetricPred σ,
        (∀ s t, stepLift obsDist out next d' s t ≤ d' s t) →
        ∀ s t, d s t ≤ d' s t) := by
  refine' ⟨ _, _, _, _, _ ⟩;
  exact fun s t => ⨆ n, iterStep obsDist out next n s t;
  · intro s;
    convert supIterMetric_refl obsDist hout_refl out next s;
  · intro s t u;
    refine' iSup_le fun n => _;
    refine' le_trans _ ( add_le_add ( le_iSup _ n ) ( le_iSup _ n ) );
    induction' n with n ih generalizing s t u <;> simp_all +decide [ iterStep ];
    · exact le_add_of_nonneg_of_le ( zero_le _ ) ( zero_le _ );
    · exact stepLift_triangle obsDist hout_tri out next _ ih _ _ _;
  · -- By definition of `stepLift`, we have:
    intros s t
    apply supIterMetric_prefixed;
  · -- By definition of `supIterMetric`, we know that it is the least upper bound of the iterates.
    intros d' hd'
    apply supIterMetric_least obsDist out next d' hd'

/-- The least bisimulation pseudometric equals the supremum of iterates. -/
theorem least_metric_eq_iSup_iter
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (_hout_refl : ∀ w, obsDist w w = 0)
    (_hout_tri : ∀ a b c, obsDist a c ≤ obsDist a b + obsDist b c)
    (out : σ → ω)
    (next : σ → σ) :
    ∀ s t, supIterMetric obsDist out next s t =
      ⨆ n, iterStep obsDist out next n s t := by
  intro s t
  rfl

/-! ## Compositional nonexpansiveness -/

/-
Sequential composition is nonexpansive: composing two nonexpansive maps
    yields a nonexpansive map.
-/
theorem seq_nonexpansive
    {α β γ : Type*}
    (dα : MetricPred α) (dβ : MetricPred β) (dγ : MetricPred γ)
    (f : α → β) (g : β → γ)
    (hf : ∀ x y, dβ (f x) (f y) ≤ dα x y)
    (hg : ∀ u v, dγ (g u) (g v) ≤ dβ u v) :
    ∀ x y, dγ (g (f x)) (g (f y)) ≤ dα x y := by
  exact fun x y => le_trans ( hg _ _ ) ( hf _ _ )

/-
Parallel composition is nonexpansive under the sup-product metric.
-/
theorem prod_nonexpansive_sup
    {α β γ δ : Type*}
    (dα : MetricPred α) (dβ : MetricPred β)
    (dγ : MetricPred γ) (dδ : MetricPred δ)
    (f : α → γ) (g : β → δ)
    (hf : ∀ x y, dγ (f x) (f y) ≤ dα x y)
    (hg : ∀ x y, dδ (g x) (g y) ≤ dβ x y) :
    ∀ p q : α × β,
      (dγ (f p.1) (f q.1) ⊔ dδ (g p.2) (g q.2))
        ≤ (dα p.1 q.1 ⊔ dβ p.2 q.2) := by
  exact fun p q => max_le_max ( hf _ _ ) ( hg _ _ )

/-! ## Triangle inequality for the supremum metric -/

/-
The supremum of iterates satisfies the triangle inequality.
-/
theorem supIterMetric_triangle
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (_hout_refl : ∀ w, obsDist w w = 0)
    (hout_tri : ∀ a b c, obsDist a c ≤ obsDist a b + obsDist b c)
    (out : σ → ω)
    (next : σ → σ) :
    ∀ s t u, supIterMetric obsDist out next s u ≤
      supIterMetric obsDist out next s t + supIterMetric obsDist out next t u := by
  intro s t u;
  refine' iSup_le fun n => _;
  -- By definition of `iterStep`, we have:
  have h_iterStep : ∀ n, iterStep obsDist out next n s u ≤ iterStep obsDist out next n s t + iterStep obsDist out next n t u := by
    intro n;
    induction' n with n ih generalizing s t u;
    · exact le_add_of_nonneg_of_le ( by positivity ) ( by rfl );
    · exact stepLift_triangle _ hout_tri _ _ _ ih _ _ _;
  exact le_trans ( h_iterStep n ) ( add_le_add ( le_iSup ( fun n => iterStep obsDist out next n s t ) n ) ( le_iSup ( fun n => iterStep obsDist out next n t u ) n ) )

/-! ## Iterates are below any prefixed point -/

/-
Every iterate is below any prefixed point of `stepLift`.
-/
theorem iterStep_le_prefixed
    {σ ω : Type*}
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ)
    (d : MetricPred σ)
    (hpre : ∀ s t, stepLift obsDist out next d s t ≤ d s t) :
    ∀ n s t, iterStep obsDist out next n s t ≤ d s t := by
  intro n s t;
  induction' n with n ih generalizing s t;
  · exact botMetric_le d s t;
  · exact le_trans ( stepLift_monotone obsDist out next ih s t ) ( hpre s t )

/-! ## Trace compatibility -/

/-- A monotone operator on metrics that is compatible with traced feedback. -/
theorem trace_feedback_monotone
    {σ : Type*}
    (T : MetricPred σ → MetricPred σ)
    (hmono : Monotone T)
    (d₁ d₂ : MetricPred σ)
    (h : d₁ ≤ d₂) :
    T d₁ ≤ T d₂ :=
  hmono h

/-
If a monotone operator preserves reflexivity, its Kleene iterates are all reflexive.
-/
theorem kleene_iter_refl
    {σ : Type*}
    (T : MetricPred σ → MetricPred σ)
    (hT_refl : ∀ d : MetricPred σ, (∀ s, d s s = 0) → ∀ s, T d s s = 0) :
    ∀ n s, (T^[n] (botMetric σ)) s s = 0 := by
  intro n s;
  -- We prove this by induction on $n$.
  induction' n with n ih;
  · rfl;
  · rw [ Function.iterate_succ_apply', hT_refl ];
    exact Nat.recOn n ( by simp +decide [ botMetric ] ) fun n ih => by rw [ Function.iterate_succ_apply' ] ; exact hT_refl _ ih;

end