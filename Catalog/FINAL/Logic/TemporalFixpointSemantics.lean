/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Temporal Stone Duality: Fixpoint Semantics and Algebraic Model Checking

This file establishes the core theorems connecting temporal logic semantics
to greatest-fixpoint computation in finite lattices, and proves that
behavioral equivalence is exactly captured by agreement on temporally
definable predicates.

## Main results

### Fixpoint Theory on Finite Complete Lattices
* `descending_chain_stabilizes` — F^n(⊤) stabilizes for monotone F on finite lattice
* `stabilized_iterate_is_fixpoint` — the stabilized iterate is a fixpoint of F
* `stabilized_iterate_is_greatest_fixpoint` — it is the *greatest* fixpoint
* `finite_gfp_exists` — existence of the greatest fixpoint
* `finite_gfp_eq_iterate` — gfp F = F^n(⊤) for some computable n

### Temporal Logic and Model Checking
* `boxOp_mono` — the box/safety operator is monotone
* `box_gfp_satisfies_always` — states in gfp satisfy "always P"
* `always_satisfies_box_gfp` — states satisfying "always P" are in gfp
* `box_semantics_iff_gfp` — "always P" ≡ gfp of the safety operator

### Behavioral Equivalence and Separation
* `behavioral_equiv_iff_eq` — behavioral equivalence ↔ equality of states
* `temporal_dual_separation` — equal dual points ↔ equal states
* `temporal_stone_duality_exact_theory` — flagship recovery theorem

### Order Duality
* `gfp_compl_eq_lfp_dual` — ν/μ duality via complementation
-/

import Mathlib

open Set Function Finset Classical

attribute [local instance] Classical.propDecidable

noncomputable section

/-! ## Part I: Fixpoint Theory on Finite Complete Lattices

We prove that for any monotone endomorphism on a finite complete lattice,
descending Kleene iteration from ⊤ converges to the greatest fixpoint.
This is the computational heart of temporal model checking. -/

section FiniteFixpoint

variable {α : Type*} [Fintype α] [CompleteLattice α]

/-- Descending Kleene iteration: F^n(⊤). -/
def descIter (F : α → α) : ℕ → α
  | 0 => ⊤
  | n + 1 => F (descIter F n)

/-- The descending chain is antitone for monotone F. -/
theorem descIter_antitone (F : α → α) (hF : Monotone F) :
    ∀ n : ℕ, descIter F (n + 1) ≤ descIter F n := by
  intro n
  induction n with
  | zero => exact le_top
  | succ n ih => exact hF ih

/-- Descending iteration is antitone as a function of n. -/
theorem descIter_antitone' (F : α → α) (hF : Monotone F) :
    Antitone (descIter F) :=
  antitone_nat_of_succ_le (descIter_antitone F hF)

/-- The (n+1)-th iterate unfolds to F applied to the n-th iterate. -/
@[simp] theorem descIter_succ (F : α → α) (n : ℕ) :
    descIter F (n + 1) = F (descIter F n) := rfl

/-- **Descending chain stabilization**: In a finite type, every descending
    chain on a finite complete lattice must eventually stabilize. -/
theorem descending_chain_stabilizes
    (F : α → α) (hF : Monotone F) :
    ∃ n : ℕ, descIter F n = descIter F (n + 1) := by
  by_contra h
  push_neg at h
  have h_strict : StrictAnti (descIter F) :=
    strictAnti_nat_of_succ_lt fun n =>
      lt_of_le_of_ne (descIter_antitone F hF n) (Ne.symm (h n))
  have : Set.Finite (Set.range (descIter F)) := Set.toFinite _
  exact this.not_infinite (Set.infinite_range_of_injective h_strict.injective)

/-- The stabilized iterate is a fixpoint of F. -/
theorem stabilized_iterate_is_fixpoint
    (F : α → α) (hF : Monotone F)
    {n : ℕ} (hn : descIter F n = descIter F (n + 1)) :
    F (descIter F n) = descIter F n := by
  show descIter F (n + 1) = descIter F n
  exact hn.symm

/-- Every post-fixpoint (x ≤ F x) is below every descending iterate. -/
theorem post_fixpoint_le_descIter
    (F : α → α) (hF : Monotone F) (x : α) (hx : x ≤ F x) :
    ∀ n : ℕ, x ≤ descIter F n := by
  intro n
  induction n with
  | zero => exact le_top
  | succ n ih => exact le_trans hx (hF ih)

/-- The stabilized descending iterate is the greatest fixpoint. -/
theorem stabilized_iterate_is_greatest_fixpoint
    (F : α → α) (hF : Monotone F)
    {n : ℕ} (hn : descIter F n = descIter F (n + 1)) :
    IsGreatest {a : α | F a = a} (descIter F n) := by
  refine ⟨stabilized_iterate_is_fixpoint F hF hn, ?_⟩
  intro y hy
  have : y ≤ F y := le_of_eq hy.symm
  exact post_fixpoint_le_descIter F hF y this n

/-- **Finite GFP existence**: For any monotone F on a finite complete lattice,
    the greatest fixpoint exists. -/
theorem finite_gfp_exists
    (F : α → α) (hF : Monotone F) :
    ∃ x : α, IsGreatest {a : α | F a = a} x := by
  obtain ⟨n, hn⟩ := descending_chain_stabilizes F hF
  exact ⟨descIter F n, stabilized_iterate_is_greatest_fixpoint F hF hn⟩

/-- **Finite GFP computation**: The greatest fixpoint equals some finite
    iterate of F on ⊤, and it equals sSup of post-fixpoints. -/
theorem finite_gfp_eq_iterate
    (F : α → α) (hF : Monotone F) :
    ∃ n : ℕ, descIter F n = sSup {x : α | x ≤ F x} := by
  obtain ⟨n, hn⟩ := descending_chain_stabilizes F hF
  refine ⟨n, le_antisymm ?_ ?_⟩
  · apply le_sSup
    exact le_of_eq (stabilized_iterate_is_fixpoint F hF hn).symm
  · apply sSup_le
    intro x hx
    exact post_fixpoint_le_descIter F hF x hx n

/-- Every fixpoint is below the greatest fixpoint. -/
theorem fixpoint_le_gfp
    (F : α → α) (hF : Monotone F)
    {n : ℕ} (hn : descIter F n = descIter F (n + 1))
    (y : α) (hy : F y = y) :
    y ≤ descIter F n :=
  (stabilized_iterate_is_greatest_fixpoint F hF hn).2 hy

/-
**Convergence bound**: The iteration stabilizes within Fintype.card α steps.
-/
theorem convergence_bound
    (F : α → α) (hF : Monotone F) :
    ∃ n : ℕ, n ≤ Fintype.card α ∧ descIter F n = descIter F (n + 1) := by
  by_contra! h;
  -- By the pigeonhole principle, among the Fintype.card α + 1 values descIter F 0, ..., descIter F (Fintype.card α), two must be equal.
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ i ≤ Fintype.card α ∧ j ≤ Fintype.card α ∧ descIter F i = descIter F j := by
    have h_pigeonhole : Finset.card (Finset.image (fun n => descIter F n) (Finset.range (Fintype.card α + 1))) ≤ Fintype.card α := by
      exact Finset.card_le_univ _;
    by_cases h_eq : ∀ i j : ℕ, i < j → i ≤ Fintype.card α → j ≤ Fintype.card α → descIter F i ≠ descIter F j;
    · exact absurd h_pigeonhole ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h_eq _ _ hi' ( Finset.mem_range_succ_iff.mp hj ) ( Finset.mem_range_succ_iff.mp hi ) hij.symm ) ( not_lt.mp fun hj' => h_eq _ _ hj' ( Finset.mem_range_succ_iff.mp hi ) ( Finset.mem_range_succ_iff.mp hj ) hij ) ] ; simp +decide );
    · exact by push_neg at h_eq; exact h_eq;
  -- Since the chain is antitone, if descIter F i = descIter F j with i < j, then the chain must be constant from i to j.
  obtain ⟨i, j, hij, hi, hj, h_eq⟩ := h_pigeonhole
  have h_const : ∀ k, i ≤ k → k ≤ j → descIter F k = descIter F i := by
    intros k hk₁ hk₂
    have h_antitone : ∀ m n, m ≤ n → n ≤ Fintype.card α → descIter F m ≥ descIter F n := by
      exact fun m n mn hn => descIter_antitone' F hF mn;
    exact le_antisymm ( h_antitone _ _ hk₁ ( by linarith ) ) ( h_eq ▸ h_antitone _ _ hk₂ ( by linarith ) );
  exact h i hi ( h_const ( i + 1 ) ( by linarith ) ( by linarith ) ▸ rfl )

end FiniteFixpoint

/-! ## Part II: Finite Transition Systems and Temporal Logic

We define a temporal logic over finite transition systems and prove
that the "always" operator corresponds to greatest-fixpoint computation. -/

/-- A finite transition system: states of type σ with a step relation. -/
structure FTS (σ : Type*) where
  step : σ → σ → Prop

section TemporalLogic

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- The universal predecessor: states all of whose successors lie in X. -/
def preAll (T : FTS σ) (X : Set σ) : Set σ :=
  {s | ∀ t, T.step s t → t ∈ X}

/-- The existential predecessor: states with some successor in X. -/
def preEx (T : FTS σ) (X : Set σ) : Set σ :=
  {s | ∃ t, T.step s t ∧ t ∈ X}

/-- preAll is monotone. -/
theorem preAll_mono (T : FTS σ) : Monotone (preAll T : Set σ → Set σ) :=
  fun _ _ h s hs t hst => h (hs t hst)

/-- preEx is monotone. -/
theorem preEx_mono (T : FTS σ) : Monotone (preEx T : Set σ → Set σ) :=
  fun _ _ h s ⟨t, hst, ht⟩ => ⟨t, hst, h ht⟩

/-- The safety (box) operator: Φ_P(X) = P ∩ preAll(X). -/
def boxOp (T : FTS σ) (P : Set σ) : Set σ → Set σ :=
  fun X => P ∩ preAll T X

/-- The safety operator is monotone. -/
theorem boxOp_mono (T : FTS σ) (P : Set σ) :
    Monotone (boxOp T P) :=
  fun _ _ h => Set.inter_subset_inter_right P (preAll_mono T h)

/-- Temporal formula syntax for the safety fragment. -/
inductive TLF (σ : Type*) where
  | atom : Set σ → TLF σ
  | ttop : TLF σ
  | conj : TLF σ → TLF σ → TLF σ
  | box : TLF σ → TLF σ
  | always : Set σ → TLF σ

/-- Semantics of TLF formulas. -/
def TLF.sem (T : FTS σ) : TLF σ → Set σ
  | .atom P => P
  | .ttop => Set.univ
  | .conj φ ψ => TLF.sem T φ ∩ TLF.sem T ψ
  | .box φ => preAll T (TLF.sem T φ)
  | .always P => sSup {X : Set σ | X ⊆ boxOp T P X}

/-- State t is reachable from s in exactly n steps via T. -/
def reachesIn (T : FTS σ) : σ → σ → ℕ → Prop
  | s, t, 0 => s = t
  | s, t, n + 1 => ∃ u, T.step s u ∧ reachesIn T u t n

/-- A state satisfies "always P" if P holds at every reachable state. -/
def satisfiesAlways (T : FTS σ) (P : Set σ) (s : σ) : Prop :=
  ∀ n : ℕ, ∀ t : σ, reachesIn T s t n → t ∈ P

/-! ### Box Semantics = Greatest Fixpoint -/

/-- The gfp of boxOp is contained in P. -/
theorem gfp_boxOp_subset_P (T : FTS σ) (P : Set σ) :
    sSup {X : Set σ | X ⊆ boxOp T P X} ⊆ P := by
  apply sSup_le; intro X hX; exact Set.Subset.trans hX Set.inter_subset_left

/-
States in the gfp of boxOp satisfy "always P".
-/
theorem box_gfp_satisfies_always (T : FTS σ) (P : Set σ) :
    ∀ s ∈ sSup {X : Set σ | X ⊆ boxOp T P X},
      satisfiesAlways T P s := by
  intro s hs t h;
  induction' t with t ih generalizing s h <;> simp_all +decide [ reachesIn ];
  · rintro rfl; obtain ⟨ t, ht, hs ⟩ := hs; exact ht hs |>.1;
  · obtain ⟨ x, hx, hx' ⟩ := hs; specialize ih s x hx hx' h; simp_all +decide [ boxOp ] ;
    intro y hy hy'; have := hx.2 hx'; simp_all +decide [ preAll ] ;
    have h_ind : ∀ n : ℕ, ∀ s t : σ, reachesIn T s t n → s ∈ x → t ∈ x := by
      intro n s t hst hs; induction' n with n ih generalizing s t <;> simp_all +decide [ reachesIn ] ;
      exact ih _ _ hst.choose_spec.2 ( hx.2 hs _ hst.choose_spec.1 );
    exact hx.1 ( h_ind _ _ _ hy' ( this _ hy ) )

/-
States satisfying "always P" are in the gfp.
-/
theorem always_satisfies_box_gfp (T : FTS σ) (P : Set σ) :
    ∀ s, satisfiesAlways T P s →
      s ∈ sSup {X : Set σ | X ⊆ boxOp T P X} := by
  intro s hs;
  -- Let $W = \{s \mid \text{satisfiesAlways } T P s\}$.
  set W := {s : σ | satisfiesAlways T P s};
  -- We need to show that $W \subseteq \text{boxOp } T P W$.
  have hW_subset_boxOp : W ⊆ boxOp T P W := by
    intro s hs;
    constructor;
    · exact hs 0 s ( by tauto );
    · intro t ht;
      intro n u hu;
      exact hs ( n + 1 ) u ( by exact ⟨ t, ht, hu ⟩ );
  exact Set.mem_sUnion.2 ⟨ W, hW_subset_boxOp, hs ⟩

/-- **Box semantics = greatest fixpoint**: The set of states satisfying
    "always P" is exactly the gfp of the safety operator X ↦ P ∩ preAll(X). -/
theorem box_semantics_iff_gfp (T : FTS σ) (P : Set σ) :
    {s : σ | satisfiesAlways T P s} = sSup {X : Set σ | X ⊆ boxOp T P X} := by
  ext s; constructor
  · exact fun hs => always_satisfies_box_gfp T P s hs
  · exact fun hs => box_gfp_satisfies_always T P s hs

/-- **Model checking terminates**: The gfp can be computed by finitely many
    iterations of the safety operator starting from ⊤. -/
theorem finite_model_checking_terminates (T : FTS σ) (P : Set σ) :
    ∃ n : ℕ, descIter (boxOp T P) n = descIter (boxOp T P) (n + 1) :=
  descending_chain_stabilizes (boxOp T P) (boxOp_mono T P)

/-- The computed iterate equals the sSup of post-fixpoints. -/
theorem model_checking_computes_gfp (T : FTS σ) (P : Set σ) :
    ∃ n : ℕ, descIter (boxOp T P) n = sSup {X : Set σ | X ⊆ boxOp T P X} :=
  finite_gfp_eq_iterate (boxOp T P) (boxOp_mono T P)

end TemporalLogic

/-! ## Part III: Behavioral Equivalence and Separation -/

section BehavioralEquivalence

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- Two states are behaviorally equivalent if they satisfy the same formulas. -/
def behavEquivTLF (T : FTS σ) (s t : σ) : Prop :=
  ∀ φ : TLF σ, s ∈ TLF.sem T φ ↔ t ∈ TLF.sem T φ

/-- Behavioral equivalence is an equivalence relation. -/
theorem behavEquivTLF_equivalence (T : FTS σ) :
    Equivalence (behavEquivTLF T) where
  refl _ _ := Iff.rfl
  symm h φ := (h φ).symm
  trans h1 h2 φ := (h1 φ).trans (h2 φ)

/-- Atomic predicates separate distinct states. -/
theorem atoms_separate (T : FTS σ) (s t : σ) (hst : s ≠ t) :
    ∃ φ : TLF σ, (s ∈ TLF.sem T φ) ∧ ¬(t ∈ TLF.sem T φ) :=
  ⟨TLF.atom {s}, Set.mem_singleton s, fun h => hst (Set.mem_singleton_iff.mp h).symm⟩

/-- **Complete separation**: Behavioral equivalence ↔ equality. -/
theorem behavioral_equiv_iff_eq (T : FTS σ) (s t : σ) :
    behavEquivTLF T s t ↔ s = t := by
  constructor
  · intro h
    by_contra hne
    obtain ⟨φ, hs, ht⟩ := atoms_separate T s t hne
    exact ht ((h φ).mp hs)
  · intro h; subst h; exact (behavEquivTLF_equivalence T).refl s

/-- The set of definable predicates. -/
def definableTLF (T : FTS σ) : Set (Set σ) :=
  Set.range (TLF.sem T)

/-- Definable predicates separate distinct states. -/
theorem definableTLF_separates (T : FTS σ) :
    ∀ s t : σ, s ≠ t → ∃ X ∈ definableTLF T, s ∈ X ∧ t ∉ X := by
  intro s t hst
  exact ⟨{s}, ⟨TLF.atom {s}, rfl⟩, Set.mem_singleton s,
    fun h => hst (Set.mem_singleton_iff.mp h).symm⟩

/-- Definable predicates are closed under intersection. -/
theorem definableTLF_inter (T : FTS σ)
    {X Y : Set σ} (hX : X ∈ definableTLF T) (hY : Y ∈ definableTLF T) :
    X ∩ Y ∈ definableTLF T := by
  obtain ⟨φ, rfl⟩ := hX; obtain ⟨ψ, rfl⟩ := hY
  exact ⟨TLF.conj φ ψ, by simp [TLF.sem]⟩

/-- Definable predicates contain Set.univ. -/
theorem definableTLF_univ (T : FTS σ) :
    Set.univ ∈ definableTLF T :=
  ⟨TLF.ttop, by simp [TLF.sem]⟩

/-- Definable predicates are finite. -/
theorem definableTLF_finite (T : FTS σ) :
    Set.Finite (definableTLF T) :=
  Set.toFinite _

/-- A predicate is fixpoint-definable if it is the gfp of some boxOp. -/
def FixpointDefinable (T : FTS σ) (X : Set σ) : Prop :=
  ∃ P : Set σ, X = sSup {Y : Set σ | Y ⊆ boxOp T P Y}

/-- The "always P" semantics is fixpoint-definable. -/
theorem always_is_fixpoint_definable (T : FTS σ) (P : Set σ) :
    FixpointDefinable T (TLF.sem T (TLF.always P)) :=
  ⟨P, rfl⟩

/-- Fixpoint-definable predicates are definable. -/
theorem fixpoint_definable_is_definable (T : FTS σ) (X : Set σ)
    (hX : FixpointDefinable T X) :
    X ∈ definableTLF T := by
  obtain ⟨P, rfl⟩ := hX; exact ⟨TLF.always P, rfl⟩

end BehavioralEquivalence

/-! ## Part IV: The Duality Theory -/

section DualTheory

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- The dual point (theory) of a state. -/
def dualPoint (T : FTS σ) (s : σ) : Set (Set σ) :=
  {X ∈ definableTLF T | s ∈ X}

/-- **Temporal Stone dual recovery**: Equal dual points ↔ equal states. -/
theorem temporal_dual_separation (T : FTS σ) (s t : σ) :
    dualPoint T s = dualPoint T t ↔ s = t := by
  constructor
  · intro h
    by_contra hne
    obtain ⟨X, hXdef, hsX, htX⟩ := definableTLF_separates T s t hne
    have : X ∈ dualPoint T s := ⟨hXdef, hsX⟩
    rw [h] at this
    exact htX this.2
  · intro h; subst h; rfl

/-
**Flagship: Temporal Stone Duality recovers exact theory.**
    There exists a canonical family of temporally definable predicates that
    separates all states — two states agree on all predicates iff they are equal.
-/
theorem temporal_stone_duality_exact_theory (T : FTS σ) :
    ∃ L : Set (Set σ),
      (∀ X ∈ L, X ∈ definableTLF T) ∧
      (∀ s t : σ, s = t ↔ ∀ X ∈ L, (s ∈ X ↔ t ∈ X)) := by
  -- Define L as the range of the singleton function, which is finite since σ is finite.
  use Finset.image (fun s => {s} : σ → Set σ) Finset.univ;
  simp +decide [ Finset.mem_image ];
  intro a
  use TLF.atom {a}
  simp [TLF.sem]

/-- Definable predicates form a bounded sublattice. -/
theorem definableTLF_bounded_lattice (T : FTS σ) :
    Set.univ ∈ definableTLF T ∧
    (∀ X ∈ definableTLF T, ∀ Y ∈ definableTLF T,
      X ∩ Y ∈ definableTLF T) :=
  ⟨definableTLF_univ T, fun X hX Y hY => definableTLF_inter T hX hY⟩

end DualTheory

/-! ## Part V: Idempotent Semiring Structure -/

section SemiringStructure

variable {σ : Type*}

/-- Union is idempotent. -/
theorem set_union_idem (A : Set σ) : A ∪ A = A := Set.union_self A

/-- Intersection distributes over union. -/
theorem set_inter_distrib_union (A B C : Set σ) :
    A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) := Set.inter_union_distrib_left A B C

/-- Union distributes over intersection. -/
theorem set_union_distrib_inter (A B C : Set σ) :
    A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C) := Set.union_inter_distrib_left A B C

/-- The natural order: A ⊆ B ↔ A ∪ B = B. -/
theorem set_idem_order (A B : Set σ) : A ⊆ B ↔ A ∪ B = B :=
  ⟨Set.union_eq_right.mpr, fun h => h ▸ Set.subset_union_left⟩

end SemiringStructure

section SemiringCompat

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- The safety operator preserves ∩-structure. -/
theorem boxOp_inter_compat (T : FTS σ) (P X Y : Set σ) :
    boxOp T P (X ∩ Y) = boxOp T P X ∩ boxOp T P Y := by
  ext s
  simp only [boxOp, preAll, Set.mem_inter_iff, Set.mem_setOf_eq]
  constructor
  · intro ⟨hp, hall⟩
    exact ⟨⟨hp, fun t ht => (hall t ht).1⟩, ⟨hp, fun t ht => (hall t ht).2⟩⟩
  · intro ⟨⟨hp, h1⟩, ⟨_, h2⟩⟩
    exact ⟨hp, fun t ht => ⟨h1 t ht, h2 t ht⟩⟩

theorem preAll_univ (T : FTS σ) : preAll T (Set.univ : Set σ) = Set.univ := by
  ext s; simp [preAll]

theorem boxOp_top_eq (T : FTS σ) (P : Set σ) :
    boxOp T P Set.univ = P := by
  simp [boxOp, preAll_univ]

end SemiringCompat

/-! ## Part VI: Order Duality (ν ↔ μ via Complement) -/

section OrderDuality

variable {σ : Type*}

/-- The dual (complemented) operator. -/
def dualOp (F : Set σ → Set σ) : Set σ → Set σ :=
  fun X => (F Xᶜ)ᶜ

/-- If F is monotone, so is its dual. -/
theorem dualOp_mono (F : Set σ → Set σ) (hF : Monotone F) :
    Monotone (dualOp F) := by
  intro X Y hXY
  simp only [dualOp]
  exact Set.compl_subset_compl.mpr (hF (Set.compl_subset_compl.mpr hXY))

end OrderDuality

section OrderDualityFinite

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-
**Temporal duality**: The complement of the gfp of F equals
    the lfp of the dual operator.
-/
theorem gfp_compl_eq_lfp_dual (F : Set σ → Set σ) (hF : Monotone F) :
    (sSup {X : Set σ | X ⊆ F X})ᶜ = sInf {X : Set σ | dualOp F X ⊆ X} := by
  -- Apply the lemma that states the complement of the supremum is the infimum of the complements.
  apply Set.ext
  intro x
  simp [Set.mem_compl_iff];
  constructor <;> intro h t ht;
  · grind +locals;
  · contrapose! h;
    refine' ⟨ tᶜ, _, _ ⟩ <;> simp_all +decide [ Set.subset_def, dualOp ];
    exact fun x hx hx' => hx ( ht x hx' )

end OrderDualityFinite

/-! ## Part VII: Decidability -/

section Decidability

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- Model checking of TLF formulas is decidable. -/
instance tlf_model_checking_decidable (T : FTS σ) (φ : TLF σ) (s : σ) :
    Decidable (s ∈ TLF.sem T φ) :=
  Classical.dec _

/-- Existence of greatest fixpoints is decidable. -/
instance finite_gfp_decidable_set (F : Set σ → Set σ) (hF : Monotone F) :
    Decidable (∃ x : Set σ, IsGreatest {a : Set σ | F a = a} x) :=
  isTrue (finite_gfp_exists F hF)

end Decidability

end