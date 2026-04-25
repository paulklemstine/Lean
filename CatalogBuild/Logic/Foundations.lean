/-! # CatalogBuild.Logic.Foundations

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 34
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Logic.Foundations
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 34] -/
theorem hammingWeight_le {n : ℕ} (x : BoolFn n) : hammingWeight x ≤ n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )


/-- [Section: # CatalogBuild.Logic.Foundations
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 34] -/
theorem hammingDist_triangle {n : ℕ} (x y z : BoolFn n) :
    hammingDist x z ≤ hammingDist x y + hammingDist y z := by
      -- If x_i ≠ z_i, then either x_i ≠ y_i or y_i ≠ z_i. So the filter set for x,z is contained in the union of filter sets for x,y and y,z. Then use card_union_le.
      have h_filter : Finset.univ.filter (fun i => x i ≠ z i) ⊆ Finset.univ.filter (fun i => x i ≠ y i) ∪ Finset.univ.filter (fun i => y i ≠ z i) := by
        grind;
      exact le_trans ( Finset.card_le_card h_filter ) ( Finset.card_union_le _ _ )


/-- [Section: # CatalogBuild.Logic.Foundations
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 34] -/
theorem hammingDist_eq_zero_iff {n : ℕ} (x y : BoolFn n) :
    hammingDist x y = 0 ↔ x = y := by
      simp +decide [ hammingDist, funext_iff ]


theorem empty_certificate_of_const {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n)
    (hconst : ∀ y, f y = f x) : IsCertificate f x ∅ := by
      exact fun y hy => hconst y


theorem full_certificate {n : ℕ} (f : BoolFn n → Bool) (x : BoolFn n) :
    IsCertificate f x Finset.univ := by
      exact fun y _ => by simp +decide [ show y = x from funext fun i => by simpa using ‹∀ i ∈ Finset.univ, y i = x i› i ( Finset.mem_univ i ) ] ;


/-- Pointwise ordering on Boolean strings -/
def boolLE {n : ℕ} (x y : BoolFn n) : Prop :=
  ∀ i : Fin n, x i = true → y i = true


theorem boolLE_refl {n : ℕ} (x : BoolFn n) : boolLE x x := by
  exact fun i hi => hi


theorem boolLE_trans {n : ℕ} (x y z : BoolFn n) :
    boolLE x y → boolLE y z → boolLE x z := by
      exact fun hxy hyz i hi => hyz i ( hxy i hi )


theorem boolLE_antisymm {n : ℕ} (x y : BoolFn n) :
    boolLE x y → boolLE y x → x = y := by
      intros hxy hyx
      funext i
      by_cases hxi : x i = true;
      · have := hxy i; have := hyx i; aesop;
      · cases h : x i <;> cases h' : y i <;> simp_all +decide [ boolLE ]


theorem influence_const {n : ℕ} (b : Bool) (i : Fin n) :
    influence (fun _ : BoolFn n => b) i = 0 := by
      unfold influence; aesop;


/-- A hypothesis space is a finite type equipped with a partial order
representing "explanatory power" — H₁ ≤ H₂ means H₂ explains
everything H₁ does, and possibly more. -/
structure HypothesisSpace where
  /-- The type of hypotheses -/
  Hyp : Type
  /-- Fintype instance -/
  fin : Fintype Hyp
  /-- DecidableEq instance -/
  deceq : DecidableEq Hyp
  /-- Nonempty — there is at least one hypothesis -/
  nonempty : Nonempty Hyp


/-- A belief state assigns a non-negative weight to each hypothesis.
We represent it as a function from hypotheses to non-negative reals. -/
def BeliefState (n : ℕ) := Fin n → ℝ


/-- A belief state is valid if all weights are non-negative and sum to 1. -/
def BeliefState.IsValid {n : ℕ} (b : BeliefState n) : Prop :=
  (∀ i, 0 ≤ b i) ∧ ∑ i : Fin n, b i = 1


/-- An experiment outcome is a likelihood function: for each hypothesis,
what is the probability of seeing this outcome? -/
def Likelihood (n : ℕ) := Fin n → ℝ


/-- A likelihood is valid if all values are non-negative and at least one is positive. -/
def Likelihood.IsValid {n : ℕ} (l : Likelihood n) : Prop :=
  (∀ i, 0 ≤ l i) ∧ ∃ i, 0 < l i


/-- The evidence (marginal likelihood) for a belief-likelihood pair. -/
def evidence {n : ℕ} (b : BeliefState n) (l : Likelihood n) : ℝ :=
  ∑ i : Fin n, b i * l i


/-- Bayesian update: posterior ∝ prior × likelihood.
When evidence is zero, we return the prior unchanged. -/
def bayesianUpdate {n : ℕ} (b : BeliefState n) (l : Likelihood n) : BeliefState n :=
  let e := evidence b l
  if e = 0 then b
  else fun i => (b i * l i) / e


theorem posterior_nonneg {n : ℕ} (b : BeliefState n) (l : Likelihood n)
    (hb : ∀ i, 0 ≤ b i) (hl : ∀ i, 0 ≤ l i) :
    ∀ i, 0 ≤ bayesianUpdate b l i := by
  exact fun i => by unfold bayesianUpdate; split_ifs <;> [ exact hb _; exact div_nonneg ( mul_nonneg ( hb _ ) ( hl _ ) ) ( Finset.sum_nonneg fun _ _ => mul_nonneg ( hb _ ) ( hl _ ) ) ] ;


theorem posterior_normalized {n : ℕ} (b : BeliefState n) (l : Likelihood n)
    (hb : BeliefState.IsValid b) (hl : Likelihood.IsValid l)
    (he : 0 < evidence b l) :
    ∑ i : Fin n, bayesianUpdate b l i = 1 := by
  unfold bayesianUpdate;
  simp +decide [ ← Finset.sum_div, he.ne' ];
  exact div_self he.ne'


theorem bayesian_update_valid {n : ℕ} (b : BeliefState n) (l : Likelihood n)
    (hb : BeliefState.IsValid b) (hl : Likelihood.IsValid l)
    (he : 0 < evidence b l) :
    BeliefState.IsValid (bayesianUpdate b l) := by
  exact ⟨ fun i => posterior_nonneg b l hb.1 hl.1 i, posterior_normalized b l hb hl he ⟩


/-- The scientific iteration: apply Bayesian update repeatedly. -/
def scientificIteration {n : ℕ} (b₀ : BeliefState n)
    (experiments : ℕ → Likelihood n) : ℕ → BeliefState n
  | 0 => b₀
  | k + 1 => bayesianUpdate (scientificIteration b₀ experiments k) (experiments k)


/-- A hypothesis h* is the "true" hypothesis if every experiment's likelihood
is maximized at h*. -/
def IsTrueHypothesis {n : ℕ} (hstar : Fin n) (experiments : ℕ → Likelihood n) : Prop :=
  ∀ k i, experiments k i ≤ experiments k hstar


theorem true_hypothesis_weight_increases {n : ℕ} (b : BeliefState n)
    (l : Likelihood n) (hstar : Fin n)
    (hb : BeliefState.IsValid b) (hl : Likelihood.IsValid l)
    (he : 0 < evidence b l)
    (hpos : 0 < b hstar)
    (hdom : ∀ i, i ≠ hstar → l i < l hstar) :
    b hstar ≤ bayesianUpdate b l hstar := by
  -- Since $e = \sum_{i} b_i l_i$ and $l_i < l_{hstar}$ for all $i \neq hstar$, we have $e \leq l_{hstar} \sum_{i} b_i = l_{hstar}$.
  have he_le : evidence b l ≤ l hstar := by
    convert Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( show l i ≤ l hstar from ?_ ) ( hb.1 i ) using 1;
    · rw [ ← Finset.sum_mul _ _ _, hb.2, one_mul ];
    · exact if hi : i = hstar then hi.symm ▸ le_rfl else le_of_lt ( hdom i hi );
  unfold bayesianUpdate;
  split_ifs <;> simp_all +decide [ ne_of_gt ];
  rw [ le_div_iff₀ he ] ; nlinarith [ hb.1 hstar, hl.1 hstar ]


/-- A belief state is a fixed point of Bayesian updating with likelihood l
if updating doesn't change it. -/
def IsFixedPoint {n : ℕ} (b : BeliefState n) (l : Likelihood n) : Prop :=
  bayesianUpdate b l = b


/-- A pure belief state concentrates all mass on one hypothesis. -/
def pureBelief {n : ℕ} (i : Fin n) : BeliefState n :=
  fun j => if j = i then 1 else 0


theorem pure_belief_is_fixed_point {n : ℕ} (i : Fin n)
    (l : Likelihood n) (hl : 0 < l i) :
    IsFixedPoint (pureBelief i) l := by
  refine' funext fun j => _;
  unfold bayesianUpdate pureBelief;
  unfold evidence; aesop;


theorem fixed_point_is_pure {n : ℕ} (hn : 1 < n) (b : BeliefState n)
    (hb : BeliefState.IsValid b)
    (hfixed : ∀ l : Likelihood n, Likelihood.IsValid l →
      0 < evidence b l → bayesianUpdate b l = b) :
    ∃ i, b = pureBelief i := by
  -- Assume there exist $i \ne j$ such that $b_i > 0$ and $b_j > 0$.
  by_contra h
  obtain ⟨i, j, hij, hi, hj⟩ : ∃ i j : Fin n, i ≠ j ∧ 0 < b i ∧ 0 < b j := by
    obtain ⟨i, hi⟩ : ∃ i : Fin n, 0 < b i := by
      exact not_forall_not.mp fun contra => by have := hb.2; exact absurd this ( by rw [ Finset.sum_eq_zero fun i _ => le_antisymm ( le_of_not_gt fun hi => contra i hi ) ( hb.1 i ) ] ; norm_num ) ;
    obtain ⟨j, hj⟩ : ∃ j : Fin n, j ≠ i ∧ 0 < b j := by
      by_cases h_eq : ∀ j : Fin n, j ≠ i → b j = 0;
      · refine' False.elim ( h ⟨ i, funext fun j => _ ⟩ ) ; by_cases hj : j = i <;> simp_all +decide [ pureBelief ] ;
        have := hb.2; rw [ Finset.sum_eq_single i ] at this <;> aesop;
      · exact by push_neg at h_eq; obtain ⟨ j, hj₁, hj₂ ⟩ := h_eq; exact ⟨ j, hj₁, lt_of_le_of_ne ( hb.1 j ) ( Ne.symm hj₂ ) ⟩ ;
    use i, j
    aesop;
  -- Construct a likelihood $l$ that distinguishes between $i$ and $j$: $l(i) = 1$ and $l(j) = 0$.
  set l : Likelihood n := fun k => if k = i then 1 else if k = j then 0 else 0;
  specialize hfixed l ; simp_all +decide [ bayesianUpdate ];
  simp +zetaDelta at *;
  unfold evidence at hfixed; simp_all +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ] ;
  specialize hfixed ⟨ fun k => by positivity, i, by aesop ⟩ hi.ne' ; have := congr_fun hfixed j ; aesop;


/-- An oracle is a function answering yes/no queries. -/
def SciOracle := ℕ → Bool


/-- An experiment maps hypotheses to predicted outcomes. -/
structure Experiment (n : ℕ) where
  /-- The outcome observed -/
  outcome : Bool
  /-- Each hypothesis predicts whether this outcome should occur -/
  prediction : Fin n → Bool


/-- Convert an experiment to an oracle: the oracle answers whether
hypothesis i predicts the observed outcome correctly. -/
def Experiment.toOracle {n : ℕ} (e : Experiment n) : Fin n → Bool :=
  fun i => e.prediction i == e.outcome


theorem experiment_oracle_surjective {n : ℕ} (f : Fin n → Bool) :
    ∃ e : Experiment n, e.toOracle = f := by
  constructor;
  swap;
  constructor;
  exact Bool.true;
  exact fun i => if f i then Bool.true else Bool.false;
  ext i; unfold Experiment.toOracle; aesop;


/-- A scientific theory is a triple: hypothesis space, belief state, and
a collection of validated experiments. -/
structure ScientificTheory (n : ℕ) where
  belief : BeliefState n
  experiments : List (Likelihood n)
  valid : BeliefState.IsValid belief


/-- Theory refinement: incorporate a new experiment. -/
def ScientificTheory.refine {n : ℕ} (T : ScientificTheory n)
    (l : Likelihood n) (hl : Likelihood.IsValid l)
    (he : 0 < evidence T.belief l) : ScientificTheory n where
  belief := bayesianUpdate T.belief l
  experiments := l :: T.experiments
  valid := bayesian_update_valid T.belief l T.valid hl he


theorem refinement_increases_experiments {n : ℕ} (T : ScientificTheory n)
    (l : Likelihood n) (hl : Likelihood.IsValid l)
    (he : 0 < evidence T.belief l) :
    T.experiments.length < (T.refine l hl he).experiments.length := by
  exact Nat.lt_succ_self _


end
