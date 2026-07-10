import Mathlib

/-!
# Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

This file develops a self-contained Kripke-semantic account of **self-referential
soundness** in Gödel–Löb provability logic, and shows why the soundness/consistency
predicate of a sufficiently expressive proof system cannot live *inside* the system it
validates without collapse — the **tangled hierarchy** phenomenon.

The setting is the semantics of the provability modality `□`.  A *proof system* is
modelled by a Kripke frame whose worlds are theories and whose accessibility relation
`R` links a theory to the theories it can "see as provable".  The frame condition for
Gödel–Löb logic `GL` is that `R` is **transitive** and **converse well-founded**
(no infinite ascending `R`-chain): exactly the conditions under which Löb's axiom
`□(□φ → φ) → □φ` is valid.

## Main results

* `GLFrame.semantic_loeb` — the **semantic Löb theorem**: on any transitive,
  converse-well-founded frame, `□(□A → A) ⊆ □A`.  Proved by converse-well-founded
  induction on the accessibility relation.

* `GLFrame.godel_second` — **Gödel's second incompleteness theorem**, the instance
  `A = ∅` of Löb: `□Con ⊆ □⊥`.  A world that proves its own consistency proves
  everything.

* `GLFrame.consistency_not_internally_provable` — the **tangled hierarchy theorem**:
  no consistent world can internally prove its own consistency
  (`(∃ v, R w v) → w ∉ □Con`).  The soundness/consistency predicate is unavoidably
  external.

* `GLFrame.soundness_forces_consistency` — a **reflective** (self-sound) world is
  automatically consistent: if `□A → A` holds locally for the false proposition then
  the world has a successor.

* `lawvere_fixed_point` / `cantor_no_truth_predicate` — the **diagonal / fixed-point
  core** behind self-reference: any point-surjective map yields a fixed point for
  every endomap, so no system can carry a surjective self-encoding onto its own
  `Bool`-valued predicates (Tarski undefinability, Cantor).

-- !-- Lab Notes -- !--
-- Hypothesis: The soundness predicate of a proof system is a genuine fixed point of
--   the provability modality; expressibility of self-consistency forces a tangled
--   (self-referential) hierarchy that must break by Löb's theorem.
-- Experiment: Modelled `GL` proof systems as transitive converse-well-founded Kripke
--   frames; proved semantic Löb by converse-well-founded induction; derived Gödel II
--   and the "consistency is not internally provable" collapse as corollaries; grounded
--   the self-reference in Lawvere's fixed-point theorem and Cantor/Tarski.
-- Analysis: Survived — semantic Löb, Gödel II, tangled-hierarchy collapse, Lawvere,
--   Cantor. The crucial structural fact is that converse well-foundedness is *exactly*
--   what turns the self-referential reflection `□(□A→A)` into the flat `□A`.
-- Critique: None of the theorems is vacuous — the frame carries a genuine infinite
--   witness (`natFrame`), the collapse theorem is guarded by an explicit successor
--   hypothesis, and Lawvere/Cantor are proved by an honest diagonal argument.
-- Synthesis: Tangled hierarchies are unavoidable: the reflection instance for `⊥`
--   *is* consistency, and Löb makes internal consistency proofs collapse the system.
-- !-- End Lab Notes -- !--
-/

open Set Function

namespace TangledHierarchies

/-- A **Gödel–Löb frame**: a Kripke frame whose accessibility relation is transitive
and converse well-founded.  Worlds are theories; `R w v` means "`w` regards `v` as an
accessible (provable) continuation". -/
structure GLFrame where
  /-- The type of worlds (theories). -/
  World : Type
  /-- The accessibility (provability) relation. -/
  R : World → World → Prop
  /-- Accessibility is transitive (positive introspection / `4`). -/
  trans' : ∀ {a b c}, R a b → R b c → R a c
  /-- Accessibility is converse well-founded (no infinite ascending chain). -/
  wf : WellFounded (fun a b => R b a)

namespace GLFrame

variable (F : GLFrame)

/-- The **box** (provability) modality on propositions-as-sets: `w ⊩ □A` iff every
world accessible from `w` satisfies `A`. -/
def boxSet (A : Set F.World) : Set F.World := {w | ∀ v, F.R w v → v ∈ A}

/-- The **diamond** (consistency) modality: `w ⊩ ◇A` iff some accessible world
satisfies `A`. -/
def diamondSet (A : Set F.World) : Set F.World := {w | ∃ v, F.R w v ∧ v ∈ A}

/-- The **consistency** proposition `Con = ◇⊤`: a world is consistent iff it has an
accessible successor (does not vacuously prove everything). -/
def Con : Set F.World := {w | ∃ v, F.R w v}

/-
Box is monotone in its argument.
-/
theorem boxSet_mono {A B : Set F.World} (h : A ⊆ B) : F.boxSet A ⊆ F.boxSet B := by
  exact fun w hw v hv => h ( hw v hv )

/-
**Semantic Löb theorem.** On a transitive, converse-well-founded frame,
`□(□A → A) ⊆ □A`.  If a world proves "provability of `A` entails `A`", then it already
proves `A`.  Proved by converse-well-founded induction on accessibility.
-/
theorem semantic_loeb (A : Set F.World) :
    F.boxSet {w | w ∈ F.boxSet A → w ∈ A} ⊆ F.boxSet A := by
  intro w hw v hv;
  contrapose! hv;
  intro h;
  -- By the well-foundedness of $R$, there exists a minimal element $u$ in the set $\{u \mid F.R w u \land u \notin A\}$.
  obtain ⟨u, hu⟩ : ∃ u, F.R w u ∧ u ∉ A ∧ ∀ v, F.R u v → v ∉ A → False := by
    have := F.wf.has_min { u | F.R w u ∧ u ∉ A } ⟨ v, h, hv ⟩;
    exact ⟨ this.choose, this.choose_spec.1.1, this.choose_spec.1.2, fun v hv₁ hv₂ => this.choose_spec.2 v ⟨ F.trans' this.choose_spec.1.1 hv₁, hv₂ ⟩ hv₁ ⟩;
  exact hu.2.1 ( hw u hu.1 ( by aesop ) )

/-
The "reflection antecedent" `{w | w ∈ □∅ → w ∈ ∅}` is exactly consistency `Con`.
`w` fails to prove `⊥` iff `w` has a successor.
-/
theorem reflection_bot_eq_con :
    {w | w ∈ F.boxSet (∅ : Set F.World) → w ∈ (∅ : Set F.World)} = F.Con := by
  unfold GLFrame.boxSet GLFrame.Con; aesop;

/-
**Gödel's second incompleteness theorem** (semantic form): `□Con ⊆ □⊥`.
A world that proves its own consistency proves falsehood, hence everything.
-/
theorem godel_second : F.boxSet F.Con ⊆ F.boxSet (∅ : Set F.World) := by
  convert semantic_loeb F ∅ using 1;
  exact congr_arg _ ( reflection_bot_eq_con F |> Eq.symm )

/-
**Tangled hierarchy theorem.** No consistent world can internally prove its own
consistency.  The soundness/consistency predicate is unavoidably external to the
system it validates.
-/
theorem consistency_not_internally_provable (w : F.World) (hw : ∃ v, F.R w v) :
    w ∉ F.boxSet F.Con := by
  obtain ⟨ v, hv ⟩ := hw;
  -- By `godel_second`, if `w` were in `F.boxSet F.Con`, then `w` would also be in `F.boxSet ∅`.
  intro h
  apply F.godel_second h v hv

/-
A **self-sound** (reflective) world for the false proposition is automatically
consistent: if `□⊥ → ⊥` holds at `w`, then `w` has a successor.
-/
theorem soundness_forces_consistency (w : F.World)
    (hsound : w ∈ F.boxSet (∅ : Set F.World) → w ∈ (∅ : Set F.World)) :
    w ∈ F.Con := by
  contrapose! hsound; simp_all +decide [ GLFrame.boxSet ] ;
  exact fun v hv => hsound ⟨ v, hv ⟩

end GLFrame

/-! ## The diagonal / fixed-point core of self-reference -/

/-
**Lawvere's fixed-point theorem.** If some map `f : A → (A → B)` is point-surjective
(every `A → B` is `f a` for some `a`), then every endomap `g : B → B` has a fixed point.
This is the categorical engine behind every diagonal/self-reference argument.
-/
theorem lawvere_fixed_point {A B : Type*} (f : A → (A → B))
    (hf : Function.Surjective f) (g : B → B) : ∃ b, g b = b := by
  obtain ⟨ a, ha ⟩ := hf ( fun a => g ( f a a ) );
  exact ⟨ _, congr_fun ha a |> Eq.symm ⟩

/-
**Tarski undefinability / Cantor.** No proof system can carry a surjective
self-encoding onto its own `Bool`-valued predicates: there is no point-surjective
`f : A → (A → Bool)`, because `Bool.not` is a fixed-point-free endomap.
-/
theorem cantor_no_truth_predicate {A : Type*} :
    ¬ ∃ f : A → (A → Bool), Function.Surjective f := by
  by_contra h
  obtain ⟨f, hf⟩ := h;
  exact absurd ( @lawvere_fixed_point A Bool f hf Bool.not ) ( by simp +decide )

/-! ## A concrete infinite Gödel–Löb frame -/

/-
The natural numbers with "accessible = strictly smaller" form a genuine infinite
Gödel–Löb frame: transitive and converse well-founded.
-/
def natFrame : GLFrame where
  World := ℕ
  R := fun a b => b < a
  trans' := fun hab hbc => lt_trans hbc hab
  wf := by
    exact wellFounded_lt

/-
In `natFrame`, world `0` has no successor: it vacuously proves everything (a dead,
inconsistent theory) and is *not* consistent.
-/
theorem natFrame_zero_dead : (0 : ℕ) ∉ natFrame.Con := by
  exact fun h => by obtain ⟨ v, hv ⟩ := h; exact Nat.not_lt_zero v hv;

/-
In `natFrame`, every nonzero world is consistent (has a successor) and therefore,
by the tangled-hierarchy theorem, cannot prove its own consistency.
-/
theorem natFrame_succ_consistent (n : ℕ) (hn : 0 < n) :
    n ∈ natFrame.Con ∧ n ∉ natFrame.boxSet natFrame.Con := by
  constructor;
  · exact ⟨ _, hn ⟩;
  · convert TangledHierarchies.GLFrame.consistency_not_internally_provable natFrame n ⟨ 0, hn ⟩ using 1

/-- Example instantiation of the fixed-point core. -/
example (g : Bool → Bool) (f : ℕ → (ℕ → Bool)) (hf : Function.Surjective f) :
    ∃ b, g b = b := lawvere_fixed_point f hf g

#check @GLFrame.semantic_loeb
#check @GLFrame.godel_second
#check @GLFrame.consistency_not_internally_provable
#check @lawvere_fixed_point

end TangledHierarchies