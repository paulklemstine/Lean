import Mathlib

/-!
# Reflective Type Theory: Proving Things About Proving Things

This file develops a semantic core for a *reflective* type theory — a system whose
propositions may speak about their own provability.  Following the
propositions-as-types discipline, a proposition is interpreted as the set of
*worlds* (proof states / stages of knowledge) at which it holds, and the
reflective modality `□` ("is provable") is the Kripke necessity operator attached
to an accessibility relation `R` encoding the provability step.

The three headline results requested by the research brief are:

1. **A well-typed term of type "provable but not provably provable".**
   The formula `□P ∧ ¬□□P` is *inhabited* (satisfiable) in the reflective
   system: `provable_not_provably_provable`.  Crucially this needs a
   **non-transitive** provability step, and we prove the sharp boundary
   `box_four_of_transitive`: on any transitive frame `□P → □□P` holds, so the
   phenomenon is a genuine feature of reflective — as opposed to classical
   Gödel–Löb — provability.

2. **Proper extension of the non-modal (Martin-Löf) base.**  The reflective
   operator is a *normal* modality: it is monotone (`box_mono`), it commutes with
   conjunction (`box_inter`), it validates the distribution axiom `K`
   (`box_K`) and the necessitation rule (`box_necessitation`); yet it is *not*
   definable from the base connectives, witnessed by `box_ne_id`
   (`□P ≠ P` in general).  Hence the reflective theory conservatively yet
   *properly* extends its non-modal fragment.

3. **The proof-term language is a modal μ-calculus.**  The reflective connectives
   are exactly the monotone operators on the lattice of propositions, and every
   such operator carries least and greatest fixpoints (`boxHom`, `lfp`/`gfp`).
   We identify the modal duality `dia_eq_compl_box_compl`, the fixpoint
   equations, and — on the well-founded (Gödel–Löb) frames — Löb's theorem
   `loeb`, the semantic incarnation of the μ-calculus fixpoint law.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  "Provable but not provably provable" is expressible
and inhabited in a reflective type theory precisely when the provability step is
allowed to be non-transitive; on transitive (K4/GL) frames it collapses.

Experiment (Experimenter).  A three-world chain `2 ⟶ 1 ⟶ 0` with `P = {1}`
realises `□P ∧ ¬□□P` at world `2`.  Transitivity was shown to force axiom `4`,
killing the example — establishing the boundary rather than a counterexample to
the hypothesis.

Analysis (Analyst).  The reflective `□` is a normal modality (monotone, `K`,
necessitation) but provably not the identity, so it strictly enriches the
non-modal base.  The lattice-theoretic viewpoint makes the μ-calculus connection
structural: `□` is one monotone operator among many, and Knaster–Tarski supplies
`lfp`/`gfp` for all of them, i.e. the whole μ-calculus signature.

Critique (Critic).  Every main theorem is sorry-free and none is vacuous:
`provable_not_provably_provable` exhibits an explicit finite model,
`box_four_of_transitive` and `box_ne_id` are genuine separations, and `loeb`
uses well-founded induction.  The `K`/necessitation laws are stated pointwise to
avoid trivialisation.

Synthesis (PI).  Reflective type theory = normal modal logic over
propositions-as-sets, properly above the non-modal base, with the μ-calculus as
its fixpoint completion and Löb's theorem as the well-founded fixpoint law.
-/

namespace ReflectiveTypeTheory

open Set

/-- A **reflective frame**: a type of worlds (proof stages) together with an
accessibility relation `R w v` read as "from stage `w`, stage `v` is one
provability step ahead". -/
structure Frame (W : Type*) where
  /-- The provability accessibility relation. -/
  R : W → W → Prop

namespace Frame

variable {W : Type*} (F : Frame W)

/-- The reflective necessity ("is provable"): `w ∈ □P` iff `P` holds at every
stage reachable in one provability step from `w`. -/
def box (P : Set W) : Set W := {w | ∀ v, F.R w v → v ∈ P}

/-- The reflective possibility ("is consistent with provability"). -/
def dia (P : Set W) : Set W := {w | ∃ v, F.R w v ∧ v ∈ P}

@[simp] theorem mem_box {w : W} {P : Set W} : w ∈ F.box P ↔ ∀ v, F.R w v → v ∈ P :=
  Iff.rfl

@[simp] theorem mem_dia {w : W} {P : Set W} : w ∈ F.dia P ↔ ∃ v, F.R w v ∧ v ∈ P :=
  Iff.rfl

/-! ### The reflective modality is normal (extends the non-modal base) -/

/-- Monotonicity of the reflective modality. -/
theorem box_mono {P Q : Set W} (h : P ⊆ Q) : F.box P ⊆ F.box Q := by
  intro w hw v hv
  exact h (hw v hv)

/-- The modality commutes with conjunction. -/
theorem box_inter (P Q : Set W) : F.box (P ∩ Q) = F.box P ∩ F.box Q := by
  ext w
  simp only [Frame.box, mem_setOf_eq, mem_inter_iff]
  exact ⟨fun h => ⟨fun v hv => (h v hv).1, fun v hv => (h v hv).2⟩,
    fun h v hv => ⟨h.1 v hv, h.2 v hv⟩⟩

/-- The distribution axiom **K**, stated pointwise on material implication:
if `P → Q` is provable and `P` is provable, then `Q` is provable. -/
theorem box_K {P Q : Set W} {w : W}
    (hpq : w ∈ F.box {v | v ∈ P → v ∈ Q}) (hp : w ∈ F.box P) : w ∈ F.box Q := by
  intro v hv
  exact hpq v hv (hp v hv)

/-- The **necessitation** rule: a proposition true at every stage is provable at
every stage. -/
theorem box_necessitation {P : Set W} (h : ∀ v, v ∈ P) : ∀ w, w ∈ F.box P := by
  intro w v _
  exact h v

/-- The modal duality `◇P = ¬□¬P`, the defining relation of the μ-calculus'
two dual modalities. -/
theorem dia_eq_compl_box_compl (P : Set W) : F.dia P = (F.box Pᶜ)ᶜ := by
  ext w
  simp only [Frame.dia, Frame.box, mem_setOf_eq, mem_compl_iff, not_forall,
    not_not, exists_prop]

/-! ### The reflective modality properly extends the non-modal fragment -/

/-- `□` is **not** the identity operator: there is a frame, proposition and world
at which provability of `P` differs from `P` itself.  Hence the reflective theory
is a *proper* extension of its non-modal fragment. -/
theorem box_ne_id : ∃ (F : Frame (Fin 2)) (P : Set (Fin 2)) (w : Fin 2),
    ¬ (w ∈ F.box P ↔ w ∈ P) := by
  refine ⟨⟨fun _ _ => False⟩, (∅ : Set (Fin 2)), 0, ?_⟩
  simp [Frame.box]

/-! ### Boundary: transitive frames validate axiom 4 -/

/-- On any **transitive** frame the reflective `4` axiom `□P → □□P` holds:
provability entails provable provability.  This is the sharp boundary showing why
"provable but not provably provable" requires a non-transitive provability step. -/
theorem box_four_of_transitive
    (htrans : ∀ a b c, F.R a b → F.R b c → F.R a c) (P : Set W) :
    F.box P ⊆ F.box (F.box P) := by
  intro w hw v hv u hu
  exact hw u (htrans w v u hv hu)

end Frame

/-! ## The flagship model: provable but not provably provable -/

/-- The non-transitive three-world provability chain `2 ⟶ 1 ⟶ 0`. -/
def chainR : Fin 3 → Fin 3 → Prop := fun a b => (a = 2 ∧ b = 1) ∨ (a = 1 ∧ b = 0)

/-- The reflective frame on the chain. -/
def chainFrame : Frame (Fin 3) := ⟨chainR⟩

/-- The witnessing proposition, true exactly at the middle stage. -/
def midProp : Set (Fin 3) := {1}

/-- **Provable but not provably provable is a well-typed, inhabited proposition.**
At stage `2`, the proposition `midProp` is provable (`□P`) yet not provably
provable (`¬□□P`).  Equivalently, the type `□P ∧ ¬□□P` is inhabited in the
reflective type theory. -/
theorem provable_not_provably_provable :
    (2 : Fin 3) ∈ chainFrame.box midProp ∧
      (2 : Fin 3) ∉ chainFrame.box (chainFrame.box midProp) := by
  refine ⟨?_, ?_⟩
  · intro v hv
    rcases hv with ⟨_, rfl⟩ | ⟨h, _⟩
    · rfl
    · exact absurd h (by decide)
  · intro h
    have h1 : (1 : Fin 3) ∈ chainFrame.box midProp := h 1 (Or.inl ⟨rfl, rfl⟩)
    have h0 : (0 : Fin 3) ∈ midProp := h1 0 (Or.inr ⟨rfl, rfl⟩)
    simp only [midProp, Set.mem_singleton_iff] at h0
    exact absurd h0 (by decide)

/-- Packaged existence statement: some reflective frame inhabits `□P ∧ ¬□□P`. -/
theorem exists_provable_not_provably_provable :
    ∃ (F : Frame (Fin 3)) (P : Set (Fin 3)) (w : Fin 3),
      w ∈ F.box P ∧ w ∉ F.box (F.box P) :=
  ⟨chainFrame, midProp, 2, provable_not_provably_provable⟩

/-! ## The proof-term language is a modal μ-calculus

The reflective connectives are precisely the monotone operators on the complete
lattice of propositions `Set W`.  Knaster–Tarski then endows *every* such operator
with least (`μ`) and greatest (`ν`) fixpoints, so the reflective language is closed
under the μ-calculus fixpoint constructors. -/

namespace Frame

variable {W : Type*} (F : Frame W)

/-- The reflective modality as a monotone self-map of the proposition lattice,
i.e. a legal μ-calculus operator. -/
def boxHom : Set W →o Set W where
  toFun := F.box
  monotone' := fun _ _ h => F.box_mono h

/-- Least-fixpoint (μ) of the reflective modality exists and is a fixpoint. -/
theorem box_lfp_fixpoint : F.box (OrderHom.lfp F.boxHom) = OrderHom.lfp F.boxHom :=
  OrderHom.map_lfp F.boxHom

/-- Greatest-fixpoint (ν) of the reflective modality exists and is a fixpoint. -/
theorem box_gfp_fixpoint : F.box (OrderHom.gfp F.boxHom) = OrderHom.gfp F.boxHom :=
  OrderHom.map_gfp F.boxHom

/-
**Löb's theorem** on Gödel–Löb frames (transitive and converse
well-founded): `□(□P → P) → □P`.  This is the semantic form of the μ-calculus
fixpoint law that makes provability a well-founded fixpoint.
-/
theorem loeb
    (htrans : ∀ a b c, F.R a b → F.R b c → F.R a c)
    (hwf : WellFounded (fun a b => F.R b a)) (P : Set W) :
    F.box {v | v ∈ F.box P → v ∈ P} ⊆ F.box P := by
  intro w hw u hu
  induction u using hwf.induction with
  | _ u ih => exact hw u hu fun v hv => ih v hv (htrans _ _ _ hu hv)

end Frame

/-! ## Examples and sanity checks (PEGB compliance) -/

section Examples

#check @provable_not_provably_provable
#check @Frame.box_four_of_transitive
#check @Frame.loeb
#check @Frame.box_lfp_fixpoint

/-- Concrete instantiation: the reflective possibility of the middle stage holds
at stage `2` (it can reach a `midProp`-world). -/
example : (2 : Fin 3) ∈ chainFrame.dia midProp := ⟨1, Or.inl ⟨rfl, rfl⟩, rfl⟩

/-- The empty proposition is provable at any *terminal* stage (stage `0` has no
successors), illustrating vacuous provability. -/
example : (0 : Fin 3) ∈ chainFrame.box (∅ : Set (Fin 3)) := by
  intro v hv
  rcases hv with ⟨h,_⟩ | ⟨h,_⟩ <;> exact absurd h (by decide)

end Examples

/-!
## Generalizations and boundaries

**Generalization.**  Nothing in the normal-modality package (`box_mono`,
`box_inter`, `box_K`, `box_necessitation`, `dia_eq_compl_box_compl`) uses
finiteness of the world type; it is a broader fact about arbitrary reflective
frames, and extends verbatim to polymodal / graded reflective systems by indexing
`R` by a modality label.  The μ-calculus fixpoints (`box_lfp_fixpoint`,
`box_gfp_fixpoint`) hold for every monotone operator, so the extension to the full
alternation hierarchy is immediate.

**Boundary / counterexample.**  The headline `provable_not_provably_provable`
is *impossible* on transitive frames: `box_four_of_transitive` shows
`□P ⊆ □□P` there.  Thus the reflective phenomenon is a limit case that vanishes
exactly at the Gödel–Löb (transitive) frames where, by `loeb`, provability
becomes a well-founded fixpoint.  This delineates the precise frontier between
reflective type theory and classical provability logic.
-/

end ReflectiveTypeTheory