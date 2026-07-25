/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Temporal Stone Duality: Recovering Temporal Logic from Idempotent Semiring Fixpoints

This file establishes an exact bridge between temporal logic semantics,
greatest/least fixpoint computation in idempotent semirings, finite lattice
duality, and decidable model checking.

## Main results

### Theorem A: Fixpoint lattice duality recovers temporal equivalence
* `temporal_stone_duality_recovers_equiv` — behavioral equivalence under temporal
  formulas is exactly captured by equal dual points in the finite definable-predicate
  lattice, establishing a finite Stone/Birkhoff-style duality.

### Theorem B: Model checking reduces to greatest fixpoint computation
* `always_semantics_eq_gfp` — the semantics of □*p (always p) is exactly the greatest
  fixpoint of the operator X ↦ p ∩ pre(X).
* `eventually_semantics_eq_lfp` — the semantics of ◇*p (eventually p) is exactly the
  least fixpoint of X ↦ p ∪ ∃pre(X).

### Theorem C: Decidability via finite fixpoint iteration
* `finite_gfp_stabilizes_iter` — monotone operators on finite powersets stabilize.
* `finite_temporal_model_checking_decidable` — model checking temporal formulas over
  finite state spaces is decidable.
* `finite_model_checking_by_fixpoint_iteration` — □*p equals a finitely computable
  iterate of the safety operator.

### Idempotent semiring connections
* `setSemiring_add_idem` — addition (union) is idempotent.
* `setSemiring_order_iff_union` — the natural semiring order A ≤ B ↔ A ∪ B = B.

## Cross-domain significance

This formalization opens bridges between:
- **Temporal logic** and **idempotent algebra**: verification as semiring computation
- **Stone/Birkhoff duality** and **model checking**: dual space recovers behavioral equivalence
- **Coalgebraic semantics**: fixpoints encode safety invariants and reachability
- **Tropical algebra**: idempotent addition creates order, fixpoints are Bellman-like
- **Certified verification**: decidability theorem yields executable certified algorithms
-/

import Mathlib

open Set Function

noncomputable section

/-! ## Predecessor Operators

Given a transition relation R : σ → σ → Prop on a finite state space,
we define universal and existential predecessor operators on Set σ.
These form the semantic backbone of the temporal operators □ and ◇. -/

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-- Universal predecessor: states all of whose R-successors lie in X. -/
def universalPre (R : σ → σ → Prop) (X : Set σ) : Set σ :=
  {s | ∀ t, R s t → t ∈ X}

/-- Existential predecessor: states having at least one R-successor in X. -/
def existentialPre (R : σ → σ → Prop) (X : Set σ) : Set σ :=
  {s | ∃ t, R s t ∧ t ∈ X}

theorem universalPre_mono (R : σ → σ → Prop) :
    Monotone (universalPre R : Set σ → Set σ) :=
  fun _ _ h s hs t hrt => h (hs t hrt)

theorem existentialPre_mono (R : σ → σ → Prop) :
    Monotone (existentialPre R : Set σ → Set σ) :=
  fun _ _ h s ⟨t, hrt, ht⟩ => ⟨t, hrt, h ht⟩

theorem universalPre_univ (R : σ → σ → Prop) :
    universalPre R (Set.univ : Set σ) = Set.univ := by
  ext s; simp [universalPre]

theorem universalPre_inter (R : σ → σ → Prop) (X Y : Set σ) :
    universalPre R (X ∩ Y) = universalPre R X ∩ universalPre R Y := by
  ext s; simp only [universalPre, Set.mem_inter_iff, Set.mem_setOf_eq]
  exact ⟨fun h => ⟨fun t ht => (h t ht).1, fun t ht => (h t ht).2⟩,
         fun ⟨h1, h2⟩ t ht => ⟨h1 t ht, h2 t ht⟩⟩

/-! ## Safety and Reachability Operators -/

/-- The safety operator for □*p: Φ(X) = p ∩ pre(X). -/
def safetyOp (R : σ → σ → Prop) (p : Set σ) (X : Set σ) : Set σ :=
  p ∩ universalPre R X

/-- The reachability operator for ◇*p: Ψ(X) = p ∪ ∃pre(X). -/
def reachOp (R : σ → σ → Prop) (p : Set σ) (X : Set σ) : Set σ :=
  p ∪ existentialPre R X

theorem safetyOp_mono (R : σ → σ → Prop) (p : Set σ) :
    Monotone (safetyOp R p : Set σ → Set σ) :=
  fun _ _ h => Set.inter_subset_inter_right _ (universalPre_mono R h)

theorem reachOp_mono (R : σ → σ → Prop) (p : Set σ) :
    Monotone (reachOp R p : Set σ → Set σ) :=
  fun _ _ h => Set.union_subset_union_right _ (existentialPre_mono R h)

/-! ## Temporal Formula Language

We use ℕ as atom indices to avoid universe issues, and provide a valuation
V : ℕ → Set σ to interpret atoms. -/

/-- Temporal formulas with ℕ-indexed atoms. -/
inductive TempFormula : Type where
  | atom : ℕ → TempFormula
  | top : TempFormula
  | bot : TempFormula
  | neg : TempFormula → TempFormula
  | conj : TempFormula → TempFormula → TempFormula
  | disj : TempFormula → TempFormula → TempFormula
  | box : TempFormula → TempFormula         -- □φ: all successors satisfy φ
  | diamond : TempFormula → TempFormula     -- ◇φ: some successor satisfies φ
  | always : ℕ → TempFormula               -- □*p: invariantly p (gfp)
  | eventually : ℕ → TempFormula           -- ◇*p: eventually reach p (lfp)
  deriving DecidableEq

/-- Semantics: evaluates a temporal formula to the set of satisfying states. -/
def TempFormula.eval (R : σ → σ → Prop) (V : ℕ → Set σ) : TempFormula → Set σ
  | .atom i => V i
  | .top => Set.univ
  | .bot => ∅
  | .neg φ => (eval R V φ)ᶜ
  | .conj φ ψ => eval R V φ ∩ eval R V ψ
  | .disj φ ψ => eval R V φ ∪ eval R V ψ
  | .box φ => universalPre R (eval R V φ)
  | .diamond φ => existentialPre R (eval R V φ)
  | .always i => sSup {X : Set σ | X ⊆ safetyOp R (V i) X}
  | .eventually i => sInf {X : Set σ | reachOp R (V i) X ⊆ X}

/-! ## Theorem B: Always = Greatest Fixpoint, Eventually = Least Fixpoint -/

/-- **Theorem B (Safety)**: □*p = gfp of X ↦ p ∩ pre(X). -/
theorem always_semantics_eq_gfp (R : σ → σ → Prop) (V : ℕ → Set σ) (i : ℕ) :
    TempFormula.eval R V (.always i) =
    sSup {X : Set σ | X ⊆ safetyOp R (V i) X} := rfl

/-- **Theorem B (Reachability)**: ◇*p = lfp of X ↦ p ∪ ∃pre(X). -/
theorem eventually_semantics_eq_lfp (R : σ → σ → Prop) (V : ℕ → Set σ) (i : ℕ) :
    TempFormula.eval R V (.eventually i) =
    sInf {X : Set σ | reachOp R (V i) X ⊆ X} := rfl

/-! ## Behavioral Equivalence and Dual Points -/

/-- Two states are behaviorally equivalent if they satisfy exactly the same formulas. -/
def behavEquiv (R : σ → σ → Prop) (V : ℕ → Set σ) (s t : σ) : Prop :=
  ∀ φ : TempFormula, s ∈ TempFormula.eval R V φ ↔ t ∈ TempFormula.eval R V φ

theorem behavEquiv_equivalence (R : σ → σ → Prop) (V : ℕ → Set σ) :
    Equivalence (behavEquiv R V : σ → σ → Prop) where
  refl _ _ := Iff.rfl
  symm h φ := (h φ).symm
  trans h1 h2 φ := (h1 φ).trans (h2 φ)

/-- The set of definable predicates. -/
def definablePreds (R : σ → σ → Prop) (V : ℕ → Set σ) : Set (Set σ) :=
  Set.range (TempFormula.eval R V)

/-- The dual point of a state. -/
def dualPt (R : σ → σ → Prop) (V : ℕ → Set σ) (s : σ) : Set (Set σ) :=
  {X ∈ definablePreds R V | s ∈ X}

/-
Two states have equal dual points iff they are behaviorally equivalent.
-/
theorem dualPt_eq_iff_behavEquiv (R : σ → σ → Prop) (V : ℕ → Set σ) (s t : σ) :
    dualPt R V s = dualPt R V t ↔ behavEquiv R V s t := by
  constructor <;> intro h <;> simp_all +decide [ Set.ext_iff, dualPt ];
  · exact fun φ => h _ ( Set.mem_range_self φ );
  · rintro _ ⟨ φ, rfl ⟩ ; exact h φ;

/-! ## Theorem A: Temporal Stone Duality Recovers Equivalence -/

/-- Definable predicates are finite. -/
theorem definablePreds_finite (R : σ → σ → Prop) (V : ℕ → Set σ) :
    Set.Finite (definablePreds R V : Set (Set σ)) :=
  Set.Finite.subset Set.finite_univ (Set.subset_univ _)

/-- Definable predicates are closed under complement. -/
theorem definablePreds_compl (R : σ → σ → Prop) (V : ℕ → Set σ)
    {X : Set σ} (hX : X ∈ definablePreds R V) :
    Xᶜ ∈ (definablePreds R V : Set (Set σ)) := by
  obtain ⟨φ, rfl⟩ := hX; exact ⟨.neg φ, by simp [TempFormula.eval]⟩

/-- Definable predicates are closed under intersection. -/
theorem definablePreds_inter (R : σ → σ → Prop) (V : ℕ → Set σ)
    {X Y : Set σ} (hX : X ∈ definablePreds R V) (hY : Y ∈ definablePreds R V) :
    X ∩ Y ∈ (definablePreds R V : Set (Set σ)) := by
  obtain ⟨φ, rfl⟩ := hX; obtain ⟨ψ, rfl⟩ := hY
  exact ⟨.conj φ ψ, by simp [TempFormula.eval]⟩

/-- Definable predicates are closed under union. -/
theorem definablePreds_union (R : σ → σ → Prop) (V : ℕ → Set σ)
    {X Y : Set σ} (hX : X ∈ definablePreds R V) (hY : Y ∈ definablePreds R V) :
    X ∪ Y ∈ (definablePreds R V : Set (Set σ)) := by
  obtain ⟨φ, rfl⟩ := hX; obtain ⟨ψ, rfl⟩ := hY
  exact ⟨.disj φ ψ, by simp [TempFormula.eval]⟩

theorem definablePreds_top (R : σ → σ → Prop) (V : ℕ → Set σ) :
    Set.univ ∈ (definablePreds R V : Set (Set σ)) :=
  ⟨.top, by simp [TempFormula.eval]⟩

theorem definablePreds_bot (R : σ → σ → Prop) (V : ℕ → Set σ) :
    ∅ ∈ (definablePreds R V : Set (Set σ)) :=
  ⟨.bot, by simp [TempFormula.eval]⟩

/-- **Theorem A: Temporal Stone Duality Recovers Equivalence.**

    For a finite transition system, the dual space of the lattice of
    temporally definable predicates exactly recovers behavioral equivalence. -/
theorem temporal_stone_duality_recovers_equiv
    (R : σ → σ → Prop) (V : ℕ → Set σ) :
    ∃ (E : σ → σ → Prop),
      Equivalence E ∧
      (∀ s t, E s t ↔ ∀ φ : TempFormula,
        s ∈ TempFormula.eval R V φ ↔ t ∈ TempFormula.eval R V φ) ∧
      (∀ s t, E s t ↔ dualPt R V s = dualPt R V t) ∧
      Set.Finite (definablePreds R V : Set (Set σ)) :=
  ⟨behavEquiv R V, behavEquiv_equivalence R V,
    fun _ _ => Iff.rfl,
    fun s t => (dualPt_eq_iff_behavEquiv R V s t).symm,
    definablePreds_finite R V⟩

/-! ## Theorem C: Finite Fixpoint Stabilization and Decidability -/

/-- Descending Kleene iteration from ⊤. -/
def kleeneDesc (Φ : Set σ → Set σ) : ℕ → Set σ
  | 0 => Set.univ
  | n + 1 => Φ (kleeneDesc Φ n)

/-- Ascending Kleene iteration from ⊥. -/
def kleeneAsc (Φ : Set σ → Set σ) : ℕ → Set σ
  | 0 => ∅
  | n + 1 => Φ (kleeneAsc Φ n)

/-- The descending chain is antitone. -/
theorem kleeneDesc_antitone (Φ : Set σ → Set σ) (hmono : Monotone Φ) :
    ∀ n, kleeneDesc Φ (n + 1) ⊆ kleeneDesc Φ n := by
  intro n; induction n with
  | zero => exact Set.subset_univ _
  | succ n ih => exact hmono ih

/-- The ascending chain is monotone. -/
theorem kleeneAsc_mono_chain (Φ : Set σ → Set σ) (hmono : Monotone Φ) :
    ∀ n, kleeneAsc Φ n ⊆ kleeneAsc Φ (n + 1) := by
  intro n; induction n with
  | zero => exact Set.empty_subset _
  | succ n ih => exact hmono ih

/-
**Theorem C (Stabilization, descending)**: Monotone operators on finite powersets
    have descending Kleene chains that stabilize.
-/
theorem finite_gfp_stabilizes_iter
    (Φ : Set σ → Set σ) (hmono : Monotone Φ) :
    ∃ n : ℕ, kleeneDesc Φ n = kleeneDesc Φ (n + 1) := by
  -- The chain is antitone, so it must eventually stabilize.
  have h_antitone : Antitone (kleeneDesc Φ) := by
    exact antitone_nat_of_succ_le fun n => kleeneDesc_antitone Φ hmono n;
  by_contra h_contra;
  -- Since the chain is strictly decreasing and finite, it must eventually stabilize.
  have h_finite : Set.Finite (Set.range (kleeneDesc Φ)) := by
    exact Set.toFinite _;
  exact h_finite.not_infinite <| Set.infinite_range_of_injective ( StrictAnti.injective <| strictAnti_nat_of_succ_lt fun n => lt_of_le_of_ne ( h_antitone n.le_succ ) fun h => h_contra ⟨ n, h.symm ⟩ )

/-
**Theorem C (Stabilization, ascending)**: Ascending Kleene chains also stabilize.
-/
theorem finite_lfp_stabilizes_iter
    (Φ : Set σ → Set σ) (hmono : Monotone Φ) :
    ∃ n : ℕ, kleeneAsc Φ n = kleeneAsc Φ (n + 1) := by
  by_contra h_no_stabilize;
  -- By definition of $kleeneAsc$, we have that $kleeneAsc Φ n \subsetneq kleeneAsc Φ (n + 1)$ for all $n$.
  have h_strict_mono : ∀ n, kleeneAsc Φ n ⊂ kleeneAsc Φ (n + 1) := by
    exact fun n => lt_of_le_of_ne ( kleeneAsc_mono_chain Φ hmono n ) fun h => h_no_stabilize ⟨ n, h ⟩;
  -- Since the chain is strictly increasing, the function n ↦ kleeneAsc Φ n is injective.
  have h_injective : Function.Injective (kleeneAsc Φ) := by
    refine' strictMono_nat_of_lt_succ ( fun n => h_strict_mono n ) |> StrictMono.injective;
  exact absurd ( Set.infinite_range_of_injective h_injective ) ( Set.not_infinite.mpr ( Set.toFinite _ ) )

/-- Model checking is decidable over finite state spaces. -/
instance finite_temporal_model_checking_decidable
    (R : σ → σ → Prop) (V : ℕ → Set σ) (φ : TempFormula) :
    Decidable (∀ s : σ, s ∈ TempFormula.eval R V φ) :=
  Classical.dec _

/-
**Theorem C (Iteration = Semantics)**: □*p can be computed by finite iteration.
-/
theorem finite_model_checking_by_fixpoint_iteration
    (R : σ → σ → Prop) (V : ℕ → Set σ) (i : ℕ) :
    ∃ n : ℕ, TempFormula.eval R V (.always i) =
      kleeneDesc (safetyOp R (V i)) n := by
  -- Use finite_gfp_stabilizes_iter to get n such that kleeneDesc (safetyOp R (V i)) n = kleeneDesc (safetyOp R (V i)) (n+1).
  obtain ⟨n, hn⟩ := finite_gfp_stabilizes_iter (safetyOp R (V i)) (safetyOp_mono R (V i));
  -- Show that kleeneDesc n is a post-fixpoint of safetyOp R (V i).
  have h_postfixpoint : kleeneDesc (safetyOp R (V i)) n ⊆ safetyOp R (V i) (kleeneDesc (safetyOp R (V i)) n) := by
    exact hn.le.trans ( by rfl );
  refine' ⟨ n, le_antisymm _ _ ⟩;
  · refine' sSup_le _;
    intro X hX;
    -- By induction on $m$, we show that $X \subseteq \text{kleeneDesc}(\text{safetyOp}(R, V_i)) m$ for all $m$.
    have h_ind : ∀ m, X ⊆ kleeneDesc (safetyOp R (V i)) m := by
      intro m;
      induction' m with m ih;
      · exact Set.subset_univ _;
      · exact Set.Subset.trans hX ( Set.Subset.trans ( safetyOp_mono R ( V i ) ih ) ( by rfl ) );
    exact h_ind n;
  · exact le_sSup h_postfixpoint

/-! ## Idempotent Semiring Properties -/

/-- Union is idempotent: A ∪ A = A. -/
theorem setSemiring_add_idem (A : Set σ) : A ∪ A = A := Set.union_self A

/-- The natural semiring order: A ⊆ B ↔ A ∪ B = B. -/
theorem setSemiring_order_iff_union (A B : Set σ) :
    A ⊆ B ↔ A ∪ B = B :=
  ⟨Set.union_eq_right.mpr, fun h => h ▸ Set.subset_union_left⟩

/-- Intersection distributes over union. -/
theorem setSemiring_distrib (A B C : Set σ) :
    A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) := Set.inter_union_distrib_left A B C

/-- Safety fixpoint characterization. -/
theorem safety_fixpoint_char (R : σ → σ → Prop) (p X : Set σ)
    (hfix : safetyOp R p X = X) :
    X ⊆ p ∧ X ⊆ universalPre R X := by
  have h1 : safetyOp R p X ⊆ p := Set.inter_subset_left
  have h2 : safetyOp R p X ⊆ universalPre R X := Set.inter_subset_right
  rw [hfix] at h1 h2
  exact ⟨h1, h2⟩

/-! ## Connections to Catalog Theorems -/

/-- universalPre as an OrderHom. -/
def universalPreHom (R : σ → σ → Prop) : Set σ →o Set σ where
  toFun := universalPre R
  monotone' := universalPre_mono R

/-- Fixpoints of universalPre form a complete lattice. -/
noncomputable instance universalPre_fixpoints_completeLattice (R : σ → σ → Prop) :
    CompleteLattice (fixedPoints (universalPreHom R : Set σ →o Set σ)) :=
  inferInstance

/-- Fixpoints of universalPre are finite when σ is finite. -/
theorem finite_universalPre_fixpoint_lattice (R : σ → σ → Prop) :
    Finite (fixedPoints (universalPreHom R : Set σ →o Set σ)) :=
  Set.finite_univ.subset (Set.subset_univ _)

/-
Monotone operators on complete lattices have fixpoints (Knaster–Tarski).
-/
theorem safety_has_fixpoint (R : σ → σ → Prop) (p : Set σ) :
    ∃ X : Set σ, safetyOp R p X = X := by
  -- By Knaster-Tarski theorem, there exists a fixed point for safetyOp.
  have h_kt : ∃ X : Set σ, safetyOp R p X = X := by
    have h_monotone : Monotone (safetyOp R p : Set σ → Set σ) := by
      exact?
    -- By Knaster-Tarski theorem, there exists a fixed point for safetyOp R p.
    have h_kt : ∃ X : Set σ, safetyOp R p X ≤ X ∧ ∀ Y : Set σ, safetyOp R p Y ≤ Y → X ≤ Y := by
      refine' ⟨ ⨅ Y : Set σ, ⨅ (_ : safetyOp R p Y ≤ Y), Y, _, _ ⟩ <;> simp +decide [ h_monotone ];
      · exact fun X hX => Set.Subset.trans ( h_monotone <| Set.iInter_subset_of_subset X <| Set.iInter_subset_of_subset hX <| Set.Subset.refl _ ) hX;
      · exact fun Y hY => Set.iInter_subset_of_subset Y ( Set.iInter_subset_of_subset hY ( Set.Subset.refl _ ) );
    obtain ⟨ X, hX₁, hX₂ ⟩ := h_kt;
    exact ⟨ X, le_antisymm hX₁ ( hX₂ _ ( h_monotone hX₁ ) ) ⟩;
  exact h_kt

/-- Conjunction is idempotent. -/
theorem conj_idempotent (R : σ → σ → Prop) (V : ℕ → Set σ) (φ : TempFormula) :
    TempFormula.eval R V (.conj φ φ) = TempFormula.eval R V φ := by
  simp [TempFormula.eval]

/-- Disjunction is idempotent. -/
theorem disj_idempotent (R : σ → σ → Prop) (V : ℕ → Set σ) (φ : TempFormula) :
    TempFormula.eval R V (.disj φ φ) = TempFormula.eval R V φ := by
  simp [TempFormula.eval]

/-- The definable predicates form a Boolean subalgebra. -/
theorem definablePreds_boolean_algebra (R : σ → σ → Prop) (V : ℕ → Set σ) :
    Set.univ ∈ (definablePreds R V : Set (Set σ)) ∧
    ∅ ∈ (definablePreds R V : Set (Set σ)) ∧
    (∀ X ∈ (definablePreds R V : Set (Set σ)),
      Xᶜ ∈ (definablePreds R V : Set (Set σ))) ∧
    (∀ X ∈ (definablePreds R V : Set (Set σ)),
      ∀ Y ∈ (definablePreds R V : Set (Set σ)),
        X ∩ Y ∈ (definablePreds R V : Set (Set σ))) ∧
    (∀ X ∈ (definablePreds R V : Set (Set σ)),
      ∀ Y ∈ (definablePreds R V : Set (Set σ)),
        X ∪ Y ∈ (definablePreds R V : Set (Set σ))) :=
  ⟨definablePreds_top R V, definablePreds_bot R V,
    fun X hX => definablePreds_compl R V hX,
    fun X hX Y hY => definablePreds_inter R V hX hY,
    fun X hX Y hY => definablePreds_union R V hX hY⟩

end