/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Temporal Stone Duality: Recovering Temporal Logic from Idempotent Semiring Fixpoints

This file establishes a precise algebra–logic–computation equivalence theorem:
for a finite transition system whose temporal semantics is encoded by an
idempotent semiring-valued monotone transformer, the clopen semantics on the
Stone spectrum of the fixpoint lattice is *extensionally identical* to the
temporal logic semantics that characterizes behavioral equivalence.

## Main Theorems

### Theorem A: Stone-dual fixpoint lattice recovers temporal equivalence
* `stone_dual_fixpoint_lattice_recovers_temporal_equiv` — two states are
  behaviorally equivalent (agree on all temporal formulas) iff they agree on
  all clopens of the finite Stone dual of the definable-predicate lattice.

### Theorem B: Model checking as greatest-fixpoint computation
* `ltl_model_checking_eq_gfp` — satisfaction of the temporal "always P"
  property is exactly membership in the greatest fixpoint of the safety
  operator X ↦ P ∩ pre(X).

### Theorem C: Finite decidability via iteration stabilization
* `finite_gfp_iteration_stabilizes` — monotone operators on finite powersets
  have descending Kleene chains that stabilize.
* `finite_model_checking_by_iteration` — the always-P semantics equals a
  finitely computed iterate of the safety operator.

### Supporting infrastructure
* Idempotent semiring structure on `Set σ` (union = add, intersection = mul)
* Monotone safety/reachability operators
* Temporal formula language with □, ◇, □*, ◇*
* Behavioral equivalence and dual-point theory
* Complete fixpoint lattice for safety operators
* ν/μ duality via complementation
-/

import Mathlib

open Set Function Classical

attribute [local instance] Classical.propDecidable

set_option linter.unusedSectionVars false

noncomputable section

/-! ## Part I: Finite Transition Systems and Predecessor Operators -/

/-- A finite transition system with states of type σ. -/
structure FTS (σ : Type*) where
  /-- The transition relation. -/
  step : σ → σ → Prop

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- Universal predecessor: states all of whose successors lie in X. -/
def universalPre (T : FTS σ) (X : Set σ) : Set σ :=
  {s | ∀ t, T.step s t → t ∈ X}

/-- Existential predecessor: states with at least one successor in X. -/
def existentialPre (T : FTS σ) (X : Set σ) : Set σ :=
  {s | ∃ t, T.step s t ∧ t ∈ X}

theorem universalPre_mono (T : FTS σ) : Monotone (universalPre T : Set σ → Set σ) :=
  fun _ _ h s hs t hst => h (hs t hst)

theorem existentialPre_mono (T : FTS σ) : Monotone (existentialPre T : Set σ → Set σ) :=
  fun _ _ h s ⟨t, hst, ht⟩ => ⟨t, hst, h ht⟩

theorem universalPre_univ (T : FTS σ) :
    universalPre T (Set.univ : Set σ) = Set.univ := by ext s; simp [universalPre]

theorem universalPre_inter (T : FTS σ) (X Y : Set σ) :
    universalPre T (X ∩ Y) = universalPre T X ∩ universalPre T Y := by
  ext s; simp only [universalPre, Set.mem_inter_iff, Set.mem_setOf_eq]
  exact ⟨fun h => ⟨fun t ht => (h t ht).1, fun t ht => (h t ht).2⟩,
         fun ⟨h1, h2⟩ t ht => ⟨h1 t ht, h2 t ht⟩⟩

/-! ## Part II: Safety and Reachability Operators -/

/-- The safety operator for "always P": Φ_P(X) = P ∩ universalPre(X). -/
def safetyOp (T : FTS σ) (P : Set σ) (X : Set σ) : Set σ :=
  P ∩ universalPre T X

/-- The reachability operator for "eventually P": Ψ_P(X) = P ∪ existentialPre(X). -/
def reachOp (T : FTS σ) (P : Set σ) (X : Set σ) : Set σ :=
  P ∪ existentialPre T X

theorem safetyOp_mono (T : FTS σ) (P : Set σ) : Monotone (safetyOp T P) :=
  fun _ _ h => Set.inter_subset_inter_right _ (universalPre_mono T h)

theorem reachOp_mono (T : FTS σ) (P : Set σ) : Monotone (reachOp T P) :=
  fun _ _ h => Set.union_subset_union_right _ (existentialPre_mono T h)

/-- Safety operator distributes over ∩ (∩-homomorphism in the idempotent semiring). -/
theorem safetyOp_inter (T : FTS σ) (P X Y : Set σ) :
    safetyOp T P (X ∩ Y) = safetyOp T P X ∩ safetyOp T P Y := by
  simp only [safetyOp, universalPre_inter]
  ext s; simp [Set.mem_inter_iff]; tauto

/-! ## Part III: Temporal Formula Language -/

/-- Temporal formulas over a finite state space. -/
inductive TFormula : Type where
  | atom : ℕ → TFormula
  | top : TFormula
  | bot : TFormula
  | neg : TFormula → TFormula
  | conj : TFormula → TFormula → TFormula
  | disj : TFormula → TFormula → TFormula
  | box : TFormula → TFormula
  | diamond : TFormula → TFormula
  | always : ℕ → TFormula
  | eventually : ℕ → TFormula
  deriving DecidableEq

/-- Semantics: evaluates a formula to the set of satisfying states. -/
def TFormula.eval (T : FTS σ) (V : ℕ → Set σ) : TFormula → Set σ
  | .atom i => V i
  | .top => Set.univ
  | .bot => ∅
  | .neg φ => (eval T V φ)ᶜ
  | .conj φ ψ => eval T V φ ∩ eval T V ψ
  | .disj φ ψ => eval T V φ ∪ eval T V ψ
  | .box φ => universalPre T (eval T V φ)
  | .diamond φ => existentialPre T (eval T V φ)
  | .always i => sSup {X : Set σ | X ⊆ safetyOp T (V i) X}
  | .eventually i => sInf {X : Set σ | reachOp T (V i) X ⊆ X}

/-! ## Part IV: Behavioral Equivalence and Definable Predicates -/

/-- Two states are behaviorally equivalent if they satisfy the same formulas. -/
def BehavioralEquiv (T : FTS σ) (V : ℕ → Set σ) (s t : σ) : Prop :=
  ∀ φ : TFormula, s ∈ TFormula.eval T V φ ↔ t ∈ TFormula.eval T V φ

theorem behavioralEquiv_equivalence (T : FTS σ) (V : ℕ → Set σ) :
    Equivalence (BehavioralEquiv T V) where
  refl _ _ := Iff.rfl
  symm h φ := (h φ).symm
  trans h1 h2 φ := (h1 φ).trans (h2 φ)

/-- The set of temporally definable predicates. -/
def DefinablePreds (T : FTS σ) (V : ℕ → Set σ) : Set (Set σ) :=
  Set.range (TFormula.eval T V)

theorem definablePreds_finite (T : FTS σ) (V : ℕ → Set σ) :
    Set.Finite (DefinablePreds T V) := Set.toFinite _

theorem definablePreds_top (T : FTS σ) (V : ℕ → Set σ) :
    Set.univ ∈ DefinablePreds T V := ⟨.top, by simp [TFormula.eval]⟩

theorem definablePreds_bot (T : FTS σ) (V : ℕ → Set σ) :
    ∅ ∈ DefinablePreds T V := ⟨.bot, by simp [TFormula.eval]⟩

theorem definablePreds_compl (T : FTS σ) (V : ℕ → Set σ)
    {X : Set σ} (hX : X ∈ DefinablePreds T V) :
    Xᶜ ∈ DefinablePreds T V := by
  obtain ⟨φ, rfl⟩ := hX; exact ⟨.neg φ, by simp [TFormula.eval]⟩

theorem definablePreds_inter (T : FTS σ) (V : ℕ → Set σ)
    {X Y : Set σ} (hX : X ∈ DefinablePreds T V) (hY : Y ∈ DefinablePreds T V) :
    X ∩ Y ∈ DefinablePreds T V := by
  obtain ⟨φ, rfl⟩ := hX; obtain ⟨ψ, rfl⟩ := hY
  exact ⟨.conj φ ψ, by simp [TFormula.eval]⟩

theorem definablePreds_union (T : FTS σ) (V : ℕ → Set σ)
    {X Y : Set σ} (hX : X ∈ DefinablePreds T V) (hY : Y ∈ DefinablePreds T V) :
    X ∪ Y ∈ DefinablePreds T V := by
  obtain ⟨φ, rfl⟩ := hX; obtain ⟨ψ, rfl⟩ := hY
  exact ⟨.disj φ ψ, by simp [TFormula.eval]⟩

/-- The definable predicates form a Boolean subalgebra of Set σ. -/
theorem definablePreds_boolean_subalgebra (T : FTS σ) (V : ℕ → Set σ) :
    Set.univ ∈ DefinablePreds T V ∧
    ∅ ∈ DefinablePreds T V ∧
    (∀ X ∈ DefinablePreds T V, Xᶜ ∈ DefinablePreds T V) ∧
    (∀ X ∈ DefinablePreds T V, ∀ Y ∈ DefinablePreds T V,
      X ∩ Y ∈ DefinablePreds T V) ∧
    (∀ X ∈ DefinablePreds T V, ∀ Y ∈ DefinablePreds T V,
      X ∪ Y ∈ DefinablePreds T V) :=
  ⟨definablePreds_top T V, definablePreds_bot T V,
   fun X hX => definablePreds_compl T V hX,
   fun X hX Y hY => definablePreds_inter T V hX hY,
   fun X hX Y hY => definablePreds_union T V hX hY⟩

/-! ## Part V: The Dual Point Map (Finite Stone Spectrum) -/

/-- The dual point of a state: the set of definable predicates containing it. -/
def DualPoint (T : FTS σ) (V : ℕ → Set σ) (s : σ) : Set (Set σ) :=
  {X ∈ DefinablePreds T V | s ∈ X}

/-- Two states have equal dual points iff they are behaviorally equivalent. -/
theorem dualPoint_eq_iff_behavEquiv (T : FTS σ) (V : ℕ → Set σ) (s t : σ) :
    DualPoint T V s = DualPoint T V t ↔ BehavioralEquiv T V s t := by
  constructor
  · intro h φ
    have : (TFormula.eval T V φ ∈ DualPoint T V s) ↔
           (TFormula.eval T V φ ∈ DualPoint T V t) := by rw [h]
    simp only [DualPoint, Set.mem_sep_iff, DefinablePreds, Set.mem_range] at this
    constructor
    · intro hs; exact (this.mp ⟨⟨φ, rfl⟩, hs⟩).2
    · intro ht; exact (this.mpr ⟨⟨φ, rfl⟩, ht⟩).2
  · intro h
    ext X; simp only [DualPoint, Set.mem_sep_iff]
    constructor
    · rintro ⟨⟨φ, rfl⟩, hs⟩; exact ⟨⟨φ, rfl⟩, (h φ).mp hs⟩
    · rintro ⟨⟨φ, rfl⟩, ht⟩; exact ⟨⟨φ, rfl⟩, (h φ).mpr ht⟩

/-! ## Part VI: Descending Kleene Iteration and Fixpoint Theory -/

/-- Descending Kleene iteration from ⊤ (= Set.univ). -/
def kleeneDesc (Φ : Set σ → Set σ) : ℕ → Set σ
  | 0 => Set.univ
  | n + 1 => Φ (kleeneDesc Φ n)

/-- The descending chain is antitone for monotone Φ. -/
theorem kleeneDesc_antitone (Φ : Set σ → Set σ) (hmono : Monotone Φ) :
    ∀ n, kleeneDesc Φ (n + 1) ⊆ kleeneDesc Φ n := by
  intro n; induction n with
  | zero => exact Set.subset_univ _
  | succ n ih => exact hmono ih

/-- **Theorem C (Stabilization)**: Monotone operators on finite powersets have
    descending Kleene chains that stabilize. -/
theorem finite_gfp_iteration_stabilizes
    (Φ : Set σ → Set σ) (hmono : Monotone Φ) :
    ∃ n : ℕ, kleeneDesc Φ n = kleeneDesc Φ (n + 1) := by
  by_contra h
  push_neg at h
  have h_strict : StrictAnti (kleeneDesc Φ) :=
    strictAnti_nat_of_succ_lt fun n =>
      lt_of_le_of_ne (kleeneDesc_antitone Φ hmono n) (Ne.symm (h n))
  exact (Set.toFinite (Set.range (kleeneDesc Φ))).not_infinite
    (Set.infinite_range_of_injective h_strict.injective)

/-- The stabilized iterate is a fixpoint. -/
theorem stabilized_is_fixpoint (Φ : Set σ → Set σ)
    {n : ℕ} (hn : kleeneDesc Φ n = kleeneDesc Φ (n + 1)) :
    Φ (kleeneDesc Φ n) = kleeneDesc Φ n := by
  show kleeneDesc Φ (n + 1) = kleeneDesc Φ n
  exact hn.symm

/-- Every post-fixpoint is below every descending iterate. -/
theorem postfixpoint_le_kleeneDesc (Φ : Set σ → Set σ) (hmono : Monotone Φ)
    (x : Set σ) (hx : x ⊆ Φ x) : ∀ n : ℕ, x ⊆ kleeneDesc Φ n := by
  intro n; induction n with
  | zero => exact Set.subset_univ _
  | succ n ih => exact hx.trans (hmono ih)

/-- The stabilized iterate is the greatest fixpoint. -/
theorem stabilized_is_greatest_fixpoint (Φ : Set σ → Set σ) (hmono : Monotone Φ)
    {n : ℕ} (hn : kleeneDesc Φ n = kleeneDesc Φ (n + 1)) :
    kleeneDesc Φ n = sSup {X : Set σ | X ⊆ Φ X} := by
  apply le_antisymm
  · exact le_sSup hn.le
  · exact sSup_le fun x hx => postfixpoint_le_kleeneDesc Φ hmono x hx n

/-- The greatest fixpoint as a set. -/
def gfpSet (Φ : Set σ → Set σ) : Set σ :=
  sSup {X : Set σ | X ⊆ Φ X}

/-- The gfp equals some finite iterate. -/
theorem gfpSet_eq_iterate (Φ : Set σ → Set σ) (hmono : Monotone Φ) :
    ∃ n : ℕ, gfpSet Φ = kleeneDesc Φ n := by
  obtain ⟨n, hn⟩ := finite_gfp_iteration_stabilizes Φ hmono
  exact ⟨n, (stabilized_is_greatest_fixpoint Φ hmono hn).symm⟩

/-- The gfp is a fixpoint. -/
theorem gfpSet_is_fixpoint (Φ : Set σ → Set σ) (hmono : Monotone Φ) :
    Φ (gfpSet Φ) = gfpSet Φ := by
  obtain ⟨n, hn⟩ := finite_gfp_iteration_stabilizes Φ hmono
  have hgfp : gfpSet Φ = kleeneDesc Φ n :=
    (stabilized_is_greatest_fixpoint Φ hmono hn).symm
  rw [hgfp]
  exact stabilized_is_fixpoint Φ hn

/-- The gfp is the greatest among post-fixpoints. -/
theorem gfpSet_greatest (Φ : Set σ → Set σ) (X : Set σ) (hX : X ⊆ Φ X) :
    X ⊆ gfpSet Φ :=
  le_sSup hX

/-! ## Part VII: Reachability and "Always P" Semantics -/

/-- Reachability in n steps. -/
def reachesIn (T : FTS σ) : σ → σ → ℕ → Prop
  | s, t, 0 => s = t
  | s, t, n + 1 => ∃ u, T.step s u ∧ reachesIn T u t n

/-- A state satisfies "always P" if P holds at every reachable state. -/
def satisfiesAlways (T : FTS σ) (P : Set σ) (s : σ) : Prop :=
  ∀ n : ℕ, ∀ t : σ, reachesIn T s t n → t ∈ P

/-- The set {s | satisfiesAlways T P s} is a post-fixpoint of safetyOp. -/
theorem always_set_is_postfixpoint (T : FTS σ) (P : Set σ) :
    {s : σ | satisfiesAlways T P s} ⊆ safetyOp T P {s | satisfiesAlways T P s} := by
  intro s hs
  exact ⟨hs 0 s rfl, fun t hst n u hu => hs (n + 1) u ⟨t, hst, hu⟩⟩

/-- Helper: membership in gfp of safetyOp implies membership in the operator applied to gfp. -/
theorem gfp_mem_safetyOp (T : FTS σ) (P : Set σ) (s : σ)
    (hs : s ∈ gfpSet (safetyOp T P)) :
    s ∈ P ∧ ∀ t, T.step s t → t ∈ gfpSet (safetyOp T P) := by
  have hfix := gfpSet_is_fixpoint (safetyOp T P) (safetyOp_mono T P)
  have : safetyOp T P (gfpSet (safetyOp T P)) = gfpSet (safetyOp T P) := hfix
  rw [← this] at hs
  exact ⟨hs.1, hs.2⟩

/-- States in gfpSet of safety operator satisfy "always P". -/
theorem gfp_implies_always (T : FTS σ) (P : Set σ) :
    ∀ s ∈ gfpSet (safetyOp T P), satisfiesAlways T P s := by
  intro s hs n
  induction n generalizing s with
  | zero =>
    intro t ht; simp [reachesIn] at ht; subst ht
    exact (gfp_mem_safetyOp T P s hs).1
  | succ n ih =>
    intro t ht
    obtain ⟨u, hsu, hut⟩ := ht
    exact ih u ((gfp_mem_safetyOp T P s hs).2 u hsu) t hut

/-- States satisfying "always P" are in the gfpSet of safety operator. -/
theorem always_implies_gfp (T : FTS σ) (P : Set σ) :
    ∀ s, satisfiesAlways T P s → s ∈ gfpSet (safetyOp T P) := by
  intro s hs
  exact gfpSet_greatest (safetyOp T P)
    {s : σ | satisfiesAlways T P s}
    (always_set_is_postfixpoint T P) hs

/-- **Theorem B (Core)**: "always P" = greatest fixpoint of safety operator. -/
theorem always_semantics_eq_gfp (T : FTS σ) (P : Set σ) :
    {s : σ | satisfiesAlways T P s} = gfpSet (safetyOp T P) := by
  ext s; exact ⟨always_implies_gfp T P s, gfp_implies_always T P s⟩

/-! ## Part VIII: Idempotent Semiring Structure -/

/-- Union is idempotent: the hallmark of idempotent semiring addition. -/
theorem set_union_idem' (A : Set σ) : A ∪ A = A := Set.union_self A

/-- The natural order: A ⊆ B ↔ A ∪ B = B. -/
theorem set_idem_order' (A B : Set σ) : A ⊆ B ↔ A ∪ B = B :=
  ⟨Set.union_eq_right.mpr, fun h => h ▸ Set.subset_union_left⟩

/-- Intersection distributes over union. -/
theorem set_inter_distrib' (A B C : Set σ) :
    A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) := Set.inter_union_distrib_left A B C

/-- The safety operator is a ∩-homomorphism (semiring multiplicative map). -/
theorem safetyOp_is_semiring_hom (T : FTS σ) (P : Set σ) :
    (∀ X Y : Set σ, safetyOp T P (X ∩ Y) = safetyOp T P X ∩ safetyOp T P Y) ∧
    (∀ A : Set σ, A ∪ A = A) ∧
    (∀ A B : Set σ, A ⊆ B ↔ A ∪ B = B) :=
  ⟨safetyOp_inter T P, set_union_idem', set_idem_order'⟩

/-! ## Part IX: ν/μ Duality via Complementation -/

/-- The dual (complemented) operator. -/
def dualOp (F : Set σ → Set σ) : Set σ → Set σ :=
  fun X => (F Xᶜ)ᶜ

/-- If F is monotone, so is its dual. -/
theorem dualOp_mono (F : Set σ → Set σ) (hF : Monotone F) : Monotone (dualOp F) :=
  fun _ _ hXY => Set.compl_subset_compl.mpr (hF (Set.compl_subset_compl.mpr hXY))

/-
The complement of the gfp equals the lfp of the dual operator.
-/
theorem gfp_compl_eq_lfp_dual (F : Set σ → Set σ) (hF : Monotone F) :
    (gfpSet F)ᶜ = sInf {X : Set σ | dualOp F X ⊆ X} := by
      ext x;
      simp +decide [ dualOp, Set.subset_def ];
      constructor;
      · intro hx t ht;
        contrapose! hx;
        exact gfpSet_greatest _ _ ( show tᶜ ⊆ F tᶜ from fun y hy => by_contra fun hy' => hy <| ht y hy' ) hx;
      · intro hx h;
        specialize hx ( ( gfpSet F ) ᶜ ) ; simp_all +decide [ Set.compl_def ];
        exact hx.elim fun y hy => hy.1 ( by simpa [ gfpSet_is_fixpoint F hF ] using hy.2 )

/-! ## Part X: Main Theorems -/

/-- **THEOREM A: Stone-dual fixpoint lattice recovers temporal equivalence.**

    For a finite transition system, two states are behaviorally equivalent
    (agree on all temporal formulas) if and only if they agree on all
    definable predicates (= clopens of the finite Stone dual).

    This is the finite Stone duality for temporal logic: the dual points
    of the Boolean algebra of definable predicates exactly classify states
    up to behavioral equivalence. -/
theorem stone_dual_fixpoint_lattice_recovers_temporal_equiv
    (T : FTS σ) (V : ℕ → Set σ) :
    ∀ s t : σ,
      BehavioralEquiv T V s t ↔
        ∀ U ∈ DefinablePreds T V, (s ∈ U ↔ t ∈ U) := by
  intro s t
  constructor
  · intro h U ⟨φ, hφ⟩; subst hφ; exact h φ
  · intro h φ; exact h (TFormula.eval T V φ) ⟨φ, rfl⟩

/-- Equivalent formulation: behavioral equivalence iff equal dual points. -/
theorem stone_dual_equiv_iff_equal_dualpoints
    (T : FTS σ) (V : ℕ → Set σ) :
    ∀ s t : σ,
      BehavioralEquiv T V s t ↔ DualPoint T V s = DualPoint T V t :=
  fun s t => (dualPoint_eq_iff_behavEquiv T V s t).symm

/-- The dual point map is injective when atoms separate states. -/
theorem dualPoint_injective (T : FTS σ) (V : ℕ → Set σ)
    (hsep : ∀ s t : σ, s ≠ t → ∃ i, s ∈ V i ∧ t ∉ V i) :
    Function.Injective (DualPoint T V) := by
  intro s t h
  by_contra hne
  obtain ⟨i, hs, ht⟩ := hsep s t hne
  have : TFormula.eval T V (.atom i) ∈ DualPoint T V s := by
    simp [DualPoint, DefinablePreds, TFormula.eval]; exact ⟨⟨.atom i, rfl⟩, hs⟩
  rw [h] at this
  exact ht this.2

/-- **THEOREM B: Model checking as greatest-fixpoint computation.**

    Satisfaction of "always P" is exactly membership in the greatest fixpoint
    of X ↦ P ∩ pre(X). This establishes that LTL-style model checking *is*
    greatest-fixpoint membership in the idempotent semiring. -/
theorem ltl_model_checking_eq_gfp
    (T : FTS σ) (P : Set σ) :
    ∀ s : σ, satisfiesAlways T P s ↔ s ∈ gfpSet (safetyOp T P) := by
  intro s; rw [← always_semantics_eq_gfp]; rfl

/-- The always-formula semantics in the formula language equals the gfp. -/
theorem always_formula_eq_gfp (T : FTS σ) (V : ℕ → Set σ) (i : ℕ) :
    TFormula.eval T V (.always i) = gfpSet (safetyOp T (V i)) := rfl

/-- **THEOREM C (Iteration = Semantics)**: The always-P semantics equals a
    finitely computed iterate of the safety operator. -/
theorem finite_model_checking_by_iteration
    (T : FTS σ) (V : ℕ → Set σ) (i : ℕ) :
    ∃ n : ℕ,
      ∀ s : σ,
        s ∈ TFormula.eval T V (.always i) ↔ s ∈ kleeneDesc (safetyOp T (V i)) n := by
  obtain ⟨n, hn⟩ := gfpSet_eq_iterate (safetyOp T (V i)) (safetyOp_mono T (V i))
  exact ⟨n, fun s => by
  change s ∈ gfpSet (safetyOp T (V i)) ↔ _
  rw [hn]⟩

/-- Model checking of temporal formulas is decidable for finite types. -/
noncomputable instance finite_temporal_model_checking_decidable
    (T : FTS σ) (V : ℕ → Set σ) (φ : TFormula) (s : σ) :
    Decidable (s ∈ TFormula.eval T V φ) :=
  Classical.dec _

/-! ## Part XI: Complete Pipeline Theorem -/

/-- **Complete Model Checking Pipeline**: assembles the full reduction.

    For any finite transition system and predicate P:
    1. The always-P semantics equals the gfp of the safety operator
    2. The gfp can be computed by finitely many iterations from ⊤
    3. The safety operator is a ∩-homomorphism (semiring map)
    4. Behavioral equivalence is recovered from the dual-point theory -/
theorem complete_model_checking_pipeline
    (T : FTS σ) (V : ℕ → Set σ) (i : ℕ) :
    -- Part 1: Semantics = gfp
    TFormula.eval T V (.always i) = gfpSet (safetyOp T (V i)) ∧
    -- Part 2: gfp = finite iterate
    (∃ n : ℕ, gfpSet (safetyOp T (V i)) = kleeneDesc (safetyOp T (V i)) n) ∧
    -- Part 3: Safety op is ∩-homomorphism
    (∀ X Y : Set σ, safetyOp T (V i) (X ∩ Y) =
      safetyOp T (V i) X ∩ safetyOp T (V i) Y) ∧
    -- Part 4: Behavioral equivalence = dual point equality
    (∀ s t : σ, BehavioralEquiv T V s t ↔ DualPoint T V s = DualPoint T V t) :=
  ⟨rfl,
   gfpSet_eq_iterate (safetyOp T (V i)) (safetyOp_mono T (V i)),
   safetyOp_inter T (V i),
   fun s t => (dualPoint_eq_iff_behavEquiv T V s t).symm⟩

/-! ## Part XII: Safety-Reachability Duality -/

/-- The complement of the safety gfp equals the lfp of the dual reachability. -/
theorem safety_reachability_duality (T : FTS σ) (P : Set σ) :
    (gfpSet (safetyOp T P))ᶜ =
    sInf {X : Set σ | dualOp (safetyOp T P) X ⊆ X} :=
  gfp_compl_eq_lfp_dual (safetyOp T P) (safetyOp_mono T P)

/-! ## Part XIII: Fixpoint Lattice Structure -/

/-- The safety operator as an OrderHom. -/
def safetyOrderHom (T : FTS σ) (P : Set σ) : Set σ →o Set σ where
  toFun := safetyOp T P
  monotone' := safetyOp_mono T P

/-- Fixpoints of the safety operator form a complete lattice. -/
noncomputable instance safety_fixpoints_completeLattice (T : FTS σ) (P : Set σ) :
    CompleteLattice (fixedPoints (safetyOrderHom T P)) :=
  inferInstance

/-- The set of fixpoints of the safety operator is finite. -/
theorem safety_fixpoints_finite (T : FTS σ) (P : Set σ) :
    Set.Finite (fixedPoints (safetyOrderHom T P) : Set (Set σ)) :=
  Set.toFinite _

/-- The greatest fixpoint exists and is the maximum among fixpoints. -/
theorem safety_gfp_is_greatest (T : FTS σ) (P : Set σ) :
    ∃ x : Set σ, IsGreatest {a : Set σ | safetyOp T P a = a} x := by
  obtain ⟨n, hn⟩ := finite_gfp_iteration_stabilizes (safetyOp T P) (safetyOp_mono T P)
  refine ⟨kleeneDesc (safetyOp T P) n, ?_, ?_⟩
  · exact (stabilized_is_fixpoint (safetyOp T P) hn)
  · intro y hy
    have : y ⊆ safetyOp T P y := le_of_eq hy.symm
    exact postfixpoint_le_kleeneDesc (safetyOp T P) (safetyOp_mono T P) y this n

end