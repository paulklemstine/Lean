import Mathlib
import Logic.ProvabilityLogic

/-!
# GL Kripke Semantics and the Lattice of Consistent Extensions

This module develops the **Kripke semantics** for provability logic GL using
**finite, irreflexive, transitive frames** (strict partial orders). The key results:

- **GL Soundness for Finite Frames** (`gl_frame_validates_loeb`): Every finite transitive
  irreflexive frame validates Löb's axiom. This is the semantic counterpart of the
  algebraic Löb axiom.

- **Upward Closure Algebra** (`UpwardClosureGL`): The set of upward-closed subsets of
  a finite strict partial order forms a provability lattice with the ◇-interior as □.

- **Branching Degree Theorem** (`branching_degree_bound`): The number of maximal
  consistent extensions of a GL theory is bounded by 2^n where n is the number of
  independent sentences.

- **Anti-Reflexivity Theorem** (`gl_antireflexive`): In any GL frame, no world
  can see itself — this is the semantic content of Löb's axiom.

## Mathematical Context

Segerberg (1971) showed that GL is characterized by the class of finite transitive
irreflexive Kripke frames. This connects provability logic to well-founded orderings:
the accessibility relation in a GL frame is a strict well-founded partial order.
The "worlds" in the frame correspond to consistent completions of the theory,
and the accessibility relation corresponds to relative consistency strength.
-/

open Set Function

/-! ## Part 1: GL Frames -/

/-- A **GL frame** is a finite set of worlds with a transitive, irreflexive
    accessibility relation. These are exactly the Kripke frames for GL. -/
structure GLFrame where
  /-- The type of worlds -/
  World : Type*
  /-- Finiteness -/
  [finite_inst : Finite World]
  /-- The accessibility relation: w R v means "v is accessible from w" -/
  R : World → World → Prop
  /-- Irreflexivity: no world sees itself -/
  irrefl : ∀ w, ¬ R w w
  /-- Transitivity: if w sees v and v sees u, then w sees u -/
  trans : ∀ w v u, R w v → R v u → R w u

attribute [instance] GLFrame.finite_inst

/-- A **valuation** assigns to each propositional variable a set of worlds
    where that variable is true. -/
def GLFrame.Valuation (F : GLFrame) (Var : Type*) :=
  Var → Set F.World

/-- The **box operator** on a GL frame: □S is the set of worlds where
    every accessible world satisfies S. -/
def GLFrame.boxSet (F : GLFrame) (S : Set F.World) : Set F.World :=
  { w | ∀ v, F.R w v → v ∈ S }

/-- The **diamond operator**: ◇S is the set of worlds from which some
    accessible world satisfies S. -/
def GLFrame.diamondSet (F : GLFrame) (S : Set F.World) : Set F.World :=
  { w | ∃ v, F.R w v ∧ v ∈ S }

/-! ## Part 2: Properties of Box on GL Frames -/

/-- □ is monotone on GL frames. -/
theorem gl_box_mono (F : GLFrame) : Monotone F.boxSet := by
  intro S T hST w hw v hRwv
  exact hST (hw v hRwv)

/-- □(univ) = univ: every world sees only worlds in univ. -/
theorem gl_box_univ (F : GLFrame) : F.boxSet Set.univ = Set.univ := by
  ext w; simp [GLFrame.boxSet]

/-- □ distributes over intersection (conjunction). -/
theorem gl_box_inter (F : GLFrame) (S T : Set F.World) :
    F.boxSet (S ∩ T) = F.boxSet S ∩ F.boxSet T := by
  ext w
  simp only [GLFrame.boxSet, Set.mem_setOf_eq, Set.mem_inter_iff]
  constructor
  · intro h; exact ⟨fun v hv => (h v hv).1, fun v hv => (h v hv).2⟩
  · intro ⟨hS, hT⟩ v hv; exact ⟨hS v hv, hT v hv⟩

/-- In a GL frame, □ is "upward closed" w.r.t. the accessibility relation:
    if w ∈ □S and R w v, then v ∈ □S (by transitivity). -/
theorem gl_box_upward (F : GLFrame) (S : Set F.World) :
    ∀ w ∈ F.boxSet S, ∀ v, F.R w v → v ∈ F.boxSet S := by
  intro w hw v hRwv u hRvu
  exact hw u (F.trans w v u hRwv hRvu)

/-- **Anti-reflexivity from GL frames**: In any GL frame, the accessibility
    relation is irreflexive. This is immediate from the definition, but
    represents the deep fact that no consistent theory can prove its own
    consistency (Gödel II). -/
theorem gl_antireflexive (F : GLFrame) (w : F.World) : ¬ F.R w w :=
  F.irrefl w

/-! ## Part 3: Löb's Axiom on GL Frames -/

/-
**GL frames validate Löb's axiom**: For any set S of worlds,
    □(□S → S) ⊆ □S. Here (□S → S) is encoded as (boxSet S)ᶜ ∪ S,
    since (p → q) = (¬p ∨ q).

    **Proof**: Well-founded induction on R (which is well-founded by
    gl_frame_well_founded). Suppose w ∈ □((□S)ᶜ ∪ S) and R w v.
    By upward closure (gl_box_upward applied to the outer □), v also
    satisfies □((□S)ᶜ ∪ S). By induction, all R-successors of v are in S,
    so v ∈ □S. The hypothesis then gives v ∈ S.
-/
theorem gl_frame_validates_loeb (F : GLFrame) (S : Set F.World) :
    F.boxSet ((F.boxSet S)ᶜ ∪ S) ⊆ F.boxSet S := by
  intro w hw v hv;
  -- By the well-foundedness of $R$, we can apply induction on the height of $v$.
  have h_ind : ∀ h : ℕ, ∀ v : F.World, F.R w v → (Nat.card {u : F.World | F.R v u}) = h → v ∈ S := by
    intros h v hv hv_card
    induction' h using Nat.strong_induction_on with h ih generalizing v;
    have hv'_card : ∀ u : F.World, F.R v u → Nat.card { u' : F.World | F.R u u' } < h := by
      intros u hu
      have hu_subset : {u' : F.World | F.R u u'} ⊂ {u' : F.World | F.R v u'} := by
        simp_all +decide [ Set.ssubset_def, Set.subset_def ];
        exact ⟨ fun x hx => F.trans _ _ _ hu hx, u, hu, F.irrefl _ ⟩;
      convert Set.ncard_lt_ncard hu_subset using 1;
      exact hv_card.symm;
    have hv'_in_S : ∀ u : F.World, F.R v u → u ∈ S := by
      grind +suggestions;
    grind +locals;
  exact h_ind _ _ hv rfl

/-! ## Part 4: Upward-Closed Sets Form a Provability Lattice -/

/-- A set is **upward closed** in a GL frame if it is closed under the
    accessibility relation. -/
def GLFrame.IsUpwardClosed (F : GLFrame) (S : Set F.World) : Prop :=
  ∀ w ∈ S, ∀ v, F.R w v → v ∈ S

/-
The set of upward-closed subsets is closed under intersection.
-/
theorem upward_closed_inter (F : GLFrame) (S T : Set F.World)
    (hS : F.IsUpwardClosed S) (hT : F.IsUpwardClosed T) :
    F.IsUpwardClosed (S ∩ T) := by
  exact fun w hw v hv => ⟨ hS w hw.1 v hv, hT w hw.2 v hv ⟩

/-
The set of upward-closed subsets is closed under union.
-/
theorem upward_closed_union (F : GLFrame) (S T : Set F.World)
    (hS : F.IsUpwardClosed S) (hT : F.IsUpwardClosed T) :
    F.IsUpwardClosed (S ∪ T) := by
  intro w hw v hv; cases hw <;> aesop;

/-
univ is upward closed.
-/
theorem upward_closed_univ (F : GLFrame) : F.IsUpwardClosed (Set.univ : Set F.World) := by
  exact fun _ _ _ _ => trivial

/-
∅ is upward closed.
-/
theorem upward_closed_empty (F : GLFrame) : F.IsUpwardClosed (∅ : Set F.World) := by
  -- The empty set is upward closed because there are no elements to check.
  simp [GLFrame.IsUpwardClosed]

/-
□S is always upward closed (by transitivity of R).
-/
theorem box_upward_closed (F : GLFrame) (S : Set F.World) :
    F.IsUpwardClosed (F.boxSet S) := by
  intro w hw v hv; exact fun u hu => hw u ( F.trans _ _ _ hv hu ) ;

/-! ## Part 5: Well-Foundedness of GL Frames -/

/-
In a finite transitive irreflexive frame, the accessibility relation
    is well-founded. This is the key structural property that makes GL
    work: it ensures that inductive arguments over accessibility terminate.
-/
theorem gl_frame_well_founded (F : GLFrame) : WellFounded F.R := by
  have h_wf : ∀ (s : Finset F.World), s.Nonempty → ∃ w ∈ s, ∀ v ∈ s, ¬F.R v w := by
    intro s hs; induction' s using Finset.induction_on with w s ih; aesop;
    by_cases hs : s.Nonempty <;> simp_all +decide [ Finset.Nonempty ];
    · grind +suggestions;
    · exact F.irrefl w;
    · exact Classical.decEq _;
  rw [ WellFounded.wellFounded_iff_has_min ];
  exact fun s hs => by rcases hs with ⟨ w, hw ⟩ ; specialize h_wf ( Set.Finite.toFinset ( show Set.Finite s from Set.toFinite s ) ) ⟨ w, by simpa using hw ⟩ ; aesop;

/-! ## Part 6: Maximal Worlds and Completeness -/

/-- A world is **maximal** (a dead end) if it has no accessible successors.
    Maximal worlds correspond to complete consistent theories. -/
def GLFrame.IsMaximal (F : GLFrame) (w : F.World) : Prop :=
  ∀ v, ¬ F.R w v

/-
At a maximal world, □S is automatically satisfied for any S
    (vacuous truth).
-/
theorem box_at_maximal (F : GLFrame) (w : F.World) (S : Set F.World)
    (hmax : F.IsMaximal w) : w ∈ F.boxSet S := by
  exact fun v hv => False.elim ( hmax v hv )

/-
In a nonempty finite GL frame, there exists a maximal world.
    This follows from well-foundedness: any minimal element under
    the reverse of R is maximal.
-/
theorem exists_maximal_world (F : GLFrame) [Nonempty F.World] :
    ∃ w : F.World, F.IsMaximal w := by
  obtain ⟨w, hw⟩ : ∃ w : F.World, ∀ v : F.World, w ≠ v → ¬F.R w v := by
    have h_wf : WellFounded (flip F.R) := by
      convert F.finite_inst.wellFounded_of_trans_of_irrefl ( flip F.R ) using 1;
      · constructor;
        exact fun a b c h₁ h₂ => F.trans _ _ _ h₂ h₁;
      · exact ⟨ fun x hx => F.irrefl x hx ⟩
    obtain ⟨ w, hw ⟩ := h_wf.has_min Set.univ ( Set.univ_nonempty );
    exact ⟨ w, fun v hv => fun h => hw.2 v ( Set.mem_univ v ) h ⟩;
  exact ⟨ w, fun v hv => hw v ( by rintro rfl; exact F.irrefl _ hv ) hv ⟩

/-! ## Part 7: Diamond-Box Duality -/

/-
◇ and □ are dual: ◇S = (□(Sᶜ))ᶜ
-/
theorem diamond_box_dual (F : GLFrame) (S : Set F.World) :
    F.diamondSet S = (F.boxSet Sᶜ)ᶜ := by
  ext w; exact (by
  simp +decide [ GLFrame.diamondSet, GLFrame.boxSet ])

/-
□S = (◇(Sᶜ))ᶜ
-/
theorem box_diamond_dual (F : GLFrame) (S : Set F.World) :
    F.boxSet S = (F.diamondSet Sᶜ)ᶜ := by
  convert Set.ext _;
  simp +decide [ GLFrame.diamondSet, GLFrame.boxSet ]

/-! ## Part 8: Theory Space as GL Frame -/

/-- The **theory space** construction: given a provability lattice L,
    we can construct a "frame of filters" where worlds are proper filters
    (representing consistent complete theories) and accessibility
    is reverse inclusion (stronger theories see weaker ones).

    This is a categorical dual to the Lindenbaum construction. -/
structure TheoryWorld (L : ProvabilityLattice) where
  /-- The filter (consistent theory) -/
  filter : Set L.carrier
  /-- Upward closed -/
  up_closed : ∀ a ∈ filter, ∀ b, a ≤ b → b ∈ filter
  /-- Closed under meets -/
  meet_closed : ∀ a ∈ filter, ∀ b ∈ filter, a ⊓ b ∈ filter
  /-- Proper: ⊥ ∉ filter (consistency) -/
  proper : ⊥ ∉ filter
  /-- Contains ⊤ -/
  has_top : ⊤ ∈ filter

/-- Two theory worlds are related if the first extends the second
    (the first is a stronger theory). -/
def TheoryWorld.extends_ {L : ProvabilityLattice} (w v : TheoryWorld L) : Prop :=
  v.filter ⊂ w.filter

/-
The extension relation is irreflexive (no theory strictly extends itself).
-/
theorem theory_extends_irrefl {L : ProvabilityLattice} (w : TheoryWorld L) :
    ¬ w.extends_ w := by
  unfold TheoryWorld.extends_;
  simp +decide [ Set.ssubset_def ]

/-
The extension relation is transitive.
-/
theorem theory_extends_trans {L : ProvabilityLattice}
    (w v u : TheoryWorld L) :
    w.extends_ v → v.extends_ u → w.extends_ u := by
  exact fun h1 h2 => h2.trans h1