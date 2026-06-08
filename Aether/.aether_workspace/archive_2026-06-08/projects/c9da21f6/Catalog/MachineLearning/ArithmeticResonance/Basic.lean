/-
# Arithmetic Resonance Theory

A formal theory of **arithmetic resonance** in theorem dependency systems.
We model a theorem library as a finite directed dependency graph, define closure
operators for derivability, and prove that certain arithmetic prerequisite
packages create *superadditive* gains in proof accessibility — a phenomenon
we call **arithmetic-selective resonance**.

## Main Results
- Closure monotonicity, extensivity, and stabilization (Theorem 1)
- Dependency diamond synergy (Theorem 2)
- Selective resonance from arithmetic bottlenecks (Theorem 3)
- Correctness of resonance detection algorithm
-/
import Mathlib

namespace ArithmeticResonance

open Finset

/-! ## Core Definitions -/

/-- A finite resonance system: a dependency structure over a finite type with
distinguished arithmetic support, arithmetic targets, and control targets.
This models a theorem library as a finite directed dependency graph where
nodes are theorems/lemmas and edges encode prerequisite relationships. -/
structure FinResonanceSystem (α : Type*) [Fintype α] [DecidableEq α] where
  /-- Dependencies of each node: `v` is derivable from seed `S` if `deps v ⊆ S`. -/
  deps : α → Finset α
  /-- The arithmetic sublibrary (additive-combinatorial, sieve-theoretic lemmas). -/
  arithmetic : Finset α
  /-- Target theorems in arithmetic domains. -/
  targetArithmetic : Finset α
  /-- Control target theorems in non-arithmetic domains. -/
  targetControl : Finset α

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- One step of the closure operator: add all nodes whose dependencies are
already in `S`. This models one round of forward inference in the library. -/
def stepClosure (R : FinResonanceSystem α) (S : Finset α) : Finset α :=
  S ∪ Finset.univ.filter (fun v => R.deps v ⊆ S)

/-- Iterated closure: apply `stepClosure` `n` times. -/
def closureIter (R : FinResonanceSystem α) : ℕ → Finset α → Finset α
  | 0, S => S
  | n + 1, S => stepClosure R (closureIter R n S)

/-- The full closure: iterate `stepClosure` `Fintype.card α` times,
which suffices for stabilization on any finite type. -/
def resClosure (R : FinResonanceSystem α) (S : Finset α) : Finset α :=
  closureIter R (Fintype.card α) S

/-! ## Bottleneck and Resonance Definitions -/

/-- An arithmetic bottleneck: every target in `T` is not in the closure of `S`
alone, but becomes derivable when `A` is added. -/
def BottleneckFor (R : FinResonanceSystem α) (S A T : Finset α) : Prop :=
  ∀ t ∈ T, t ∉ resClosure R S ∧ t ∈ resClosure R (S ∪ A)

/-- Control targets are avoidable: they're already derivable from `S` alone. -/
def AvoidableFor (R : FinResonanceSystem α) (S T : Finset α) : Prop :=
  ∀ c ∈ T, c ∈ resClosure R S

/-- Each target in `T` requires the *full* package `A`: no single element
of `A` suffices. This captures independent multi-dependency structure. -/
def IndependentBottleneckFamily (R : FinResonanceSystem α)
    (S A T : Finset α) : Prop :=
  (∀ t ∈ T, t ∉ resClosure R S) ∧
  (∀ t ∈ T, t ∈ resClosure R (S ∪ A)) ∧
  (∀ t ∈ T, ∀ a ∈ A, t ∉ resClosure R (S ∪ {a})) ∧
  T.Nonempty

/-- **Arithmetic-Selective Resonance**: an arithmetic package `A` is a bottleneck
for arithmetic targets while control targets are already accessible.
This is the central new concept of the theory. -/
def ArithSelectiveResonance (R : FinResonanceSystem α)
    (S A : Finset α) : Prop :=
  A ⊆ R.arithmetic ∧
  BottleneckFor R S A R.targetArithmetic ∧
  AvoidableFor R S R.targetControl ∧
  R.targetArithmetic.Nonempty

/-! ## Theorem 1: Closure Monotonicity and Stabilization -/

/-
Step closure is extensive: `S ⊆ stepClosure R S`.
-/
theorem stepClosure_extensive (R : FinResonanceSystem α) (S : Finset α) :
    S ⊆ stepClosure R S := by
  exact Finset.subset_union_left

/-
Step closure is monotone: larger seeds yield larger closures.
-/
theorem stepClosure_mono (R : FinResonanceSystem α) {S T : Finset α} (h : S ⊆ T) :
    stepClosure R S ⊆ stepClosure R T := by
  exact Finset.union_subset_union h ( fun v hv => by exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Finset.Subset.trans ( Finset.mem_filter.mp hv |>.2 ) h ⟩ )

/-
Iterated closure is monotone in the seed set.
-/
theorem closureIter_mono (R : FinResonanceSystem α) {n : ℕ} {S T : Finset α} (h : S ⊆ T) :
    closureIter R n S ⊆ closureIter R n T := by
  induction' n with n ih
  · exact h
  · exact stepClosure_mono _ ih

/-
Each closure step grows (or preserves) the set.
-/
theorem closureIter_extensive (R : FinResonanceSystem α) (n : ℕ) (S : Finset α) :
    closureIter R n S ⊆ closureIter R (n + 1) S := by
  exact stepClosure_extensive R _

/-
If closure doesn't grow in one step, it's stable forever.
-/
theorem closureIter_stable_of_eq (R : FinResonanceSystem α) (n : ℕ) (S : Finset α)
    (h : closureIter R (n + 1) S = closureIter R n S) :
    ∀ k, closureIter R (n + k) S = closureIter R n S := by
  intro k;
  induction k <;> simp_all +decide [← add_assoc];
  grind +locals

/-
Closure stabilizes by step `Fintype.card α`: there exists a step `n ≤ card α`
where the closure stops growing. This uses the pigeonhole principle on
cardinalities of an ascending chain of finite sets.
-/
theorem closureIter_stabilizes (R : FinResonanceSystem α) (S : Finset α) :
    ∃ n, n ≤ Fintype.card α ∧ closureIter R (n + 1) S = closureIter R n S := by
  by_contra h_contra;
  -- If for all $n \leq \text{card} \, \alpha$, $\text{closureIter} \, R \, (n + 1) \, S \neq \text{closureIter} \, R \, n \, S$, then $\text{card} \, (\text{closureIter} \, R \, n \, S)$ must strictly increase for each $n$.
  have h_card_inc : ∀ n ≤ Fintype.card α, (closureIter R (n + 1) S).card > (closureIter R n S).card := by
    exact fun n hn => Finset.card_lt_card ( lt_of_le_of_ne ( closureIter_extensive R n S ) fun h => h_contra ⟨ n, hn, h.symm ⟩ );
  -- Applying the strict increase of cardinality repeatedly, we get that the cardinality of the closure after $n$ steps is at least $n$.
  have h_card_ge_n : ∀ n ≤ Fintype.card α, (closureIter R n S).card ≥ n := by
    intro n hn; induction' n with n ih <;> norm_num at *;
    grind;
  specialize h_card_ge_n ( Fintype.card α ) le_rfl ; specialize h_card_inc ( Fintype.card α ) le_rfl ; linarith [ h_card_ge_n, h_card_inc, Finset.card_le_univ ( closureIter R ( Fintype.card α + 1 ) S ), Finset.card_le_univ ( closureIter R ( Fintype.card α ) S ) ] ;

/-
`resClosure` is a fixed point of `stepClosure`. This is the key theorem
establishing that our closure process terminates correctly.
-/
theorem resClosure_fixpoint (R : FinResonanceSystem α) (S : Finset α) :
    stepClosure R (resClosure R S) = resClosure R S := by
  -- By closureIter_stabilizes, there exists n ≤ card α such that closureIter (n+1) S = closureIter n S.
  obtain ⟨n, hn⟩ : ∃ n, n ≤ Fintype.card α ∧ closureIter R (n + 1) S = closureIter R n S :=
    closureIter_stabilizes R S
  have h_closure_stable : closureIter R (Fintype.card α) S = closureIter R n S := by
    convert closureIter_stable_of_eq R n S hn.2 ( Fintype.card α - n ) using 1 ; rw [ Nat.add_sub_cancel' hn.1 ];
  unfold resClosure; aesop;

/-
The full closure is monotone in the seed.
-/
theorem resClosure_mono (R : FinResonanceSystem α) {S T : Finset α} (h : S ⊆ T) :
    resClosure R S ⊆ resClosure R T := by
  -- Apply the monotonicity lemma to n = card α.
  apply closureIter_mono R h

/-
Seeds are contained in their closure.
-/
theorem subset_resClosure (R : FinResonanceSystem α) (S : Finset α) :
    S ⊆ resClosure R S := by
  -- By repeatedly applying `closureIter_extensive`, we get that `S ⊆ closureIter R n S` for any `n`.
  have h_closureIter_extensive : ∀ n, S ⊆ closureIter R n S := by
    intro n;
    induction' n with n ih;
    · rfl;
    · exact Set.Subset.trans ih ( closureIter_extensive _ _ _ );
  exact h_closureIter_extensive _

/-! ## Theorem 2: Dependency Diamond Synergy -/

/-
When a node enters the closure at step `n+1` but not at step `n`,
its dependencies must have been in the step-`n` closure. This is the
fundamental derivation lemma for the closure operator.
-/
theorem derivation_requires_deps (R : FinResonanceSystem α) (S : Finset α)
    (t : α) (n : ℕ) (hn : t ∈ closureIter R (n + 1) S)
    (hn' : t ∉ closureIter R n S) :
    R.deps t ⊆ closureIter R n S := by
  grind +locals

/-
Key lemma: if `t ∉ S'` and `t` enters the closure of `S'` at some step,
then all deps of `t` are in the closure of `S'`. Combined with the fact
that `b ∉ resClosure R S'`, this shows `t` can't enter if `b ∈ deps t`.
-/
theorem not_in_closure_if_dep_missing (R : FinResonanceSystem α) (S' : Finset α)
    (t : α) (b : α) (ht_notin : t ∉ S') (hb_dep : b ∈ R.deps t)
    (hb_not_reach : b ∉ resClosure R S') :
    t ∉ resClosure R S' := by
  -- By induction on $n$, we show that $t \notin closureIter R n S'$ for all $n$.
  have h_ind : ∀ n, t ∉ closureIter R n S' := by
    intro n
    induction' n with n ih;
    · exact ht_notin;
    · contrapose! hb_not_reach;
      -- By definition of `closureIter`, we know that `closureIter R (n + 1) S'` is the union of `closureIter R n S'` and the set of nodes whose dependencies are in `closureIter R n S'`.
      have h_closureIter_succ : closureIter R (n + 1) S' = closureIter R n S' ∪ Finset.univ.filter (fun v => R.deps v ⊆ closureIter R n S') := by
        rfl;
      simp_all +decide [ Finset.subset_iff ];
      exact Finset.mem_of_subset ( show closureIter R n S' ⊆ resClosure R S' from by exact Finset.Subset.trans ( Finset.Subset.refl _ ) ( show closureIter R n S' ⊆ closureIter R ( Fintype.card α ) S' from by exact Nat.le_induction ( by rfl ) ( fun k hk ih => by exact Finset.Subset.trans ih ( closureIter_extensive R k S' ) ) _ ( show n ≤ Fintype.card α from le_trans ( show n ≤ Fintype.card α from by
                                                                                                                                                                                                                                                                                                                                                                                    have h_closureIter_eq : ∀ m ≥ Fintype.card α, closureIter R m S' = closureIter R (Fintype.card α) S' := by
                                                                                                                                                                                                                                                                                                                                                                                      intro m hm
                                                                                                                                                                                                                                                                                                                                                                                      induction' hm with m hm ih;
                                                                                                                                                                                                                                                                                                                                                                                      · rfl;
                                                                                                                                                                                                                                                                                                                                                                                      · rw [ show closureIter R ( m + 1 ) S' = stepClosure R ( closureIter R m S' ) from rfl, ih, show stepClosure R ( closureIter R ( Fintype.card α ) S' ) = closureIter R ( Fintype.card α ) S' from resClosure_fixpoint R S' ];
                                                                                                                                                                                                                                                                                                                                                                                    grind ) ( by simp +decide ) ) ) ) ( hb_not_reach hb_dep );
  exact h_ind _

/-
**Dependency Diamond Synergy** (Theorem 2): If theorem `t` depends on exactly
`{a, b}`, and neither `a` can be derived with `b` added nor `b` with `a` added,
and `t` is not in `S`, then `t` is reachable from `S ∪ {a, b}` but not from
either singleton addition.
This is the atomic model of arithmetic emergence through multi-dependency structure.
-/
theorem dependency_diamond_synergy
    (R : FinResonanceSystem α)
    (S : Finset α) (a b t : α)
    (hab : a ≠ b)
    (hdeps : R.deps t = {a, b})
    (htS : t ∉ S)
    (hat : t ≠ a) (hbt : t ≠ b)
    (ha_indep : a ∉ resClosure R (S ∪ {b}))
    (hb_indep : b ∉ resClosure R (S ∪ {a})) :
    t ∉ resClosure R (S ∪ {a}) ∧
    t ∉ resClosure R (S ∪ {b}) ∧
    t ∈ resClosure R (S ∪ {a, b}) := by
  -- By definition of `resClosure`, we know that if `t ∈ resClosure R (S ∪ {a, b})`, then `t` is reachable from `S ∪ {a, b}`.
  have h_reachable_ab : t ∈ stepClosure R (resClosure R (S ∪ {a, b})) := by
    simp +decide [ stepClosure, hdeps ];
    exact Or.inr ( by intro x hx; exact subset_resClosure R _ ( by aesop ) );
  grind +suggestions

/-! ## Theorem 3: Selective Resonance from Arithmetic Bottlenecks -/

/-
**Selective Resonance** (Theorem 3): When `A` is a bottleneck for arithmetic
targets and controls are already derivable, adding `A` creates a strict
asymmetry: arithmetic targets become newly reachable while controls
were already reachable. This is the core domain-selectivity result.
-/
theorem arithmetic_bottleneck_selective
    (R : FinResonanceSystem α)
    (S A : Finset α)
    (hbot : BottleneckFor R S A R.targetArithmetic)
    (havoid : AvoidableFor R S R.targetControl) :
    (∀ t ∈ R.targetArithmetic, t ∉ resClosure R S ∧ t ∈ resClosure R (S ∪ A)) ∧
    (∀ c ∈ R.targetControl, c ∈ resClosure R S) := by
  exact ⟨ hbot, havoid ⟩

/-! ## Verified Resonance Detection Algorithm -/

/-- Compute whether there exists bottleneck resonance: the arithmetic package
unlocks arithmetic targets that are not reachable without it, while
control targets are already reachable. -/
def detectBottleneckResonance (R : FinResonanceSystem α) (S A : Finset α) : Bool :=
  decide (
    (∃ t ∈ R.targetArithmetic, t ∉ resClosure R S ∧ t ∈ resClosure R (S ∪ A)) ∧
    (∀ c ∈ R.targetControl, c ∈ resClosure R S))

/-
Correctness of the resonance detector: when it returns `true`,
selective resonance genuinely holds.
-/
theorem detectBottleneckResonance_correct
    (R : FinResonanceSystem α) (S A : Finset α)
    (h : detectBottleneckResonance R S A = true) :
    (∃ t ∈ R.targetArithmetic, t ∉ resClosure R S ∧ t ∈ resClosure R (S ∪ A)) ∧
    (∀ c ∈ R.targetControl, c ∈ resClosure R S) := by
  unfold detectBottleneckResonance at h; aesop;

/-
Completeness: if selective resonance holds, the detector returns `true`.
-/
theorem detectBottleneckResonance_complete
    (R : FinResonanceSystem α) (S A : Finset α)
    (h1 : ∃ t ∈ R.targetArithmetic, t ∉ resClosure R S ∧ t ∈ resClosure R (S ∪ A))
    (h2 : ∀ c ∈ R.targetControl, c ∈ resClosure R S) :
    detectBottleneckResonance R S A = true := by
  convert decide_eq_true ?_ance; aesop;

/-! ## Library Energy (Statistical Physics Analogy) -/

/-- The number of targets reachable from seed `S`. -/
def reachableCount (R : FinResonanceSystem α) (S T : Finset α) : ℕ :=
  (T.filter (fun t => t ∈ resClosure R S)).card

/-
Adding lemmas never decreases the number of reachable targets.
-/
theorem reachableCount_mono (R : FinResonanceSystem α) (S A T : Finset α) :
    reachableCount R S T ≤ reachableCount R (S ∪ A) T := by
  exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, resClosure_mono R ( Finset.subset_union_left ) ( Finset.mem_filter.mp hx |>.2 ) ⟩

/-- The resonance score: how many additional targets become reachable. -/
def resonanceScore (R : FinResonanceSystem α) (S A T : Finset α) : ℕ :=
  reachableCount R (S ∪ A) T - reachableCount R S T

/-- The synergy score: combined resonance minus sum of individual resonances. -/
def synergyScore (R : FinResonanceSystem α) (S A T : Finset α) : ℤ :=
  (resonanceScore R S A T : ℤ) -
  A.sum (fun a => (resonanceScore R S {a} T : ℤ))

/-- Positive synergy: the combined package unlocks more than the sum of parts. -/
def HasPositiveSynergy (R : FinResonanceSystem α) (S A T : Finset α) : Prop :=
  synergyScore R S A T > 0

/-! ## Theorem 4: Positive Synergy from Independent Bottlenecks -/

/-
Under independent bottleneck conditions, each singleton addition
unlocks zero new targets (resonance score is 0 for each individual).
-/
theorem singleton_resonance_zero_of_indep
    (R : FinResonanceSystem α) (S A T : Finset α)
    (_hfam : IndependentBottleneckFamily R S A T)
    (_hT_sub : T ⊆ resClosure R (S ∪ A))
    (a : α) (_ha : a ∈ A) (hTfilt : ∀ t ∈ T, t ∉ resClosure R (S ∪ {a})) :
    resonanceScore R S {a} T = 0 := by
  unfold resonanceScore
  unfold reachableCount; simp +decide [*]
  rw [Finset.card_eq_zero.mpr]; aesop
  grind

/-
**Positive Synergy** (Theorem 4): When targets form an independent bottleneck
family, the combined package has positive resonance while individual elements
contribute nothing. Hence the synergy score is strictly positive.
-/
theorem synergy_of_independent_bottlenecks
    (R : FinResonanceSystem α) (S A T : Finset α)
    (hfam : IndependentBottleneckFamily R S A T)
    (_hT_sub : T ⊆ R.targetArithmetic) :
    HasPositiveSynergy R S A T := by
  -- From hfam, we know that for each t ∈ T, t ∉ resClosure R S and t ∈ resClosure R (S ∪ A) and t ∉ resClosure R (S ∪ {a}) for all a ∈ A.
  have h_resonanceScore : resonanceScore R S A T = T.card := by
    refine' tsub_eq_of_eq_add _;
    rw [ show reachableCount R S T = 0 from ?_, add_zero ];
    · exact congr_arg Finset.card ( Finset.filter_true_of_mem fun t ht => hfam.2.1 t ht );
    · exact Finset.card_eq_zero.mpr ( Finset.filter_eq_empty_iff.mpr fun t ht => hfam.1 t ht );
  -- From hfam, we know that for each t ∈ T, t ∉ resClosure R S and t ∈ resClosure R (S ∪ A) and t ∉ resClosure R (S ∪ {a}) for all a ∈ A. Hence, resonanceScore R S {a} T = 0 for each a ∈ A.
  have h_resonanceScore_singleton : ∀ a ∈ A, resonanceScore R S {a} T = 0 := by
    exact fun a ha => singleton_resonance_zero_of_indep _ _ _ _ hfam ( fun t ht => hfam.2.1 t ht ) a ha ( fun t ht => hfam.2.2.1 t ht a ha );
  exact Int.sub_pos_of_lt ( by rw [ show A.sum ( fun a => ( resonanceScore R S { a } T : ℤ ) ) = 0 by exact Finset.sum_eq_zero fun x hx => by aesop ] ; linarith [ Finset.card_pos.2 hfam.2.2.2 ] )

end ArithmeticResonance