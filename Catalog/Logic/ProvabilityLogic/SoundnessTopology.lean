/-
# Cycle 2: The Geometry of Self-Soundness — Fixed Points, Topology, and the
# Reflection Tower

Cycle 1 (`Logic.ProvabilityLogic.TangledSoundness`) proved that a world validating
its own soundness schema is exactly a self-accessing world, and that soundness and
Löb are jointly unsatisfiable.  This second cycle asks *where* the tangle sits, *what*
structure it destroys, and *how fast* it grows when one tries to escape by
stratification.

## Main results

* `lfp_boxOp_eq_accSet` — **the least fixed point of the provability operator is
  exactly the well-founded part of the frame.**  A sharpening of the fixed-point form
  of Löb's theorem (`lfp_boxOp_eq_univ_iff_wf`): `μX.□X` is the set of converse
  accessible worlds, so the "tangled core" is precisely the complement of a modal
  fixed point.
* `sound_notMem_lfp_boxOp` — a world that internalises its soundness lies outside
  `μX.□X`; internal soundness is invisible to every Löb-style induction.
* `uniformlySound_no_wf_rank`, `uniformlySound_no_ordinal_grading` — the collapse of
  levels is not a ℕ-artefact: a sound world admits **no** rank into any well-founded
  order, ordinals included.
* `boxOp_eq_interior_iff` — **cross-domain bridge (modal logic ↔ topology).**  The box
  operator of a frame is the topological interior operator of its Alexandrov topology
  **iff** every world internalises its own soundness *and* the frame is transitive
  (positive introspection).  So "interior semantics for provability" and "internal
  soundness everywhere" are the same hypothesis, and `glFrame_boxOp_ne_interior` shows
  no nonempty GL frame can have it.
* `iterExt_selfLoop_ncard`, `iterExt_sound_ncard` — **the reflection tower.**  Adding
  a soundness world `n` times produces a frame with exactly `n` self-loops and exactly
  `n` sound worlds: each reflection step costs precisely one strange loop.
* `iterExt_has_unsound_world` — **stratification never converges.**  No finite number
  of reflection steps makes the whole hierarchy internally sound.

## Relationship to catalog
Extends `Logic.ProvabilityLogic.TangledSoundness` (Cycle 1) and, through it,
`Logic.ProvabilityLogic.GLPFrames` and `Logic.TangledHierarchies`.
-/

import Mathlib
import Catalog.Logic.ProvabilityLogic.TangledSoundness

namespace TangledSoundness

open GLPLogic

universe u

variable {α : Type*}

/-! ## Part A — The least fixed point of the box operator is the well-founded part -/

/-- **`μX.□X` is the well-founded part of the frame.**  The least fixed point of the
provability operator consists exactly of the worlds accessible in the converse
relation.  Löb's principle (`lfp = univ`) is therefore the statement that no world is
outside the well-founded part; the tangled core is the complement of this fixed
point. -/
theorem lfp_boxOp_eq_accSet (F : KFrame) :
    OrderHom.lfp (boxHom F) = {w : F.W | Acc (Function.swap F.R) w} := by
  apply le_antisymm
  · exact OrderHom.lfp_le _ (le_of_eq (boxOp_accSet F))
  · intro w hw
    simp only [Set.mem_setOf_eq] at hw
    induction hw with
    | intro x _ ih =>
        have hstep : x ∈ boxOp F (OrderHom.lfp (boxHom F)) := fun v hv => ih v hv
        rw [show boxOp F (OrderHom.lfp (boxHom F)) = OrderHom.lfp (boxHom F) from
          OrderHom.map_lfp (boxHom F)] at hstep
        exact hstep

/-- An accessible point of a relation never relates to itself. -/
theorem acc_not_selfRel {β : Type*} {r : β → β → Prop} {x : β} (h : Acc r x) :
    ¬ r x x := by
  induction h with
  | intro y _ ih => intro hyy; exact ih y hyy hyy

/-- A self-accessing world lies outside `μX.□X`. -/
theorem selfLoop_notMem_lfp_boxOp (F : KFrame) {w : F.W} (h : F.R w w) :
    w ∉ OrderHom.lfp (boxHom F) := by
  rw [lfp_boxOp_eq_accSet]
  intro hacc
  exact acc_not_selfRel hacc h

/-- **Internal soundness escapes every Löb induction.**  A world validating its own
soundness schema is not in the least fixed point of the box operator, so no induction
of Löb type can ever reach it. -/
theorem sound_notMem_lfp_boxOp (F : KFrame) (p : α) (w : F.W)
    (h : UniformlySoundAt F α w) : w ∉ OrderHom.lfp (boxHom F) :=
  selfLoop_notMem_lfp_boxOp F ((uniformlySound_iff_selfLoop F p w).mp h)

/-! ## Part B — No grading at all, not merely no ℕ-grading -/

/-- A relation with a self-loop admits no rank into a well-founded order that strictly
descends along edges. -/
theorem no_wf_rank_of_selfLoop {F : KFrame} {β : Type*} {s : β → β → Prop}
    (hwf : WellFounded s) (rank : F.W → β)
    (hmono : ∀ a b, F.R a b → s (rank b) (rank a)) {w : F.W} (h : F.R w w) : False :=
  hwf.irrefl.irrefl (rank w) (hmono w w h)

/-- **The collapse of levels is absolute.**  A frame with an internally sound world
admits no level assignment into *any* well-founded order. -/
theorem uniformlySound_no_wf_rank (F : KFrame) (p : α) (w : F.W)
    (h : UniformlySoundAt F α w) {β : Type*} {s : β → β → Prop} (hwf : WellFounded s) :
    ¬ ∃ rank : F.W → β, ∀ a b, F.R a b → s (rank b) (rank a) := by
  rintro ⟨rank, hmono⟩
  exact no_wf_rank_of_selfLoop hwf rank hmono ((uniformlySound_iff_selfLoop F p w).mp h)

/-- In particular there is no ordinal-valued hierarchy of metalevels once soundness is
internalised: transfinite stratification fails exactly as finite stratification does. -/
theorem uniformlySound_no_ordinal_grading (F : KFrame) (p : α) (w : F.W)
    (h : UniformlySoundAt F α w) :
    ¬ ∃ rank : F.W → Ordinal, ∀ a b, F.R a b → rank b < rank a :=
  uniformlySound_no_wf_rank F p w h (wellFounded_lt (α := Ordinal))

/-! ## Part C — Cross-domain bridge: box as a topological interior operator

A Kripke frame carries a canonical (Alexandrov) topology whose open sets are the
`R`-closed sets.  The box operator is the interior operator of this topology exactly
when the system internalises its soundness everywhere and is positively
introspective. -/

/-- The **Alexandrov topology** of a frame: open sets are those closed under
accessibility. -/
def frameTopology (F : KFrame) : TopologicalSpace F.W where
  IsOpen X := ∀ w ∈ X, ∀ v, F.R w v → v ∈ X
  isOpen_univ := by intro w _ v _; trivial
  isOpen_inter := by
    intro X Y hX hY w hw v hv
    exact ⟨hX w hw.1 v hv, hY w hw.2 v hv⟩
  isOpen_sUnion := by
    rintro S hS w ⟨X, hXS, hwX⟩ v hv
    exact ⟨X, hXS, hS X hXS w hwX v hv⟩

/-- `boxOp F X` is open when the frame is transitive. -/
theorem isOpen_boxOp (F : KFrame)
    (htrans : ∀ u v w : F.W, F.R u v → F.R v w → F.R u w) (X : Set F.W) :
    (frameTopology F).IsOpen (boxOp F X) := by
  intro w hw v hv u hu
  exact hw u (htrans w v u hv hu)

/-- Reflexivity is forced by `□X ⊆ X`: the semantic soundness schema on subsets. -/
theorem selfLoop_of_boxOp_subset (F : KFrame) (h : ∀ X : Set F.W, boxOp F X ⊆ X)
    (w : F.W) : F.R w w :=
  h {v | F.R w v} (fun _ hv => hv)

/-- Transitivity is forced by idempotence of the box operator: the semantic form of
positive introspection `□X ⊆ □□X`. -/
theorem trans_of_boxOp_idem (F : KFrame)
    (h : ∀ X : Set F.W, boxOp F X ⊆ boxOp F (boxOp F X)) (u v w : F.W)
    (huv : F.R u v) (hvw : F.R v w) : F.R u w :=
  h {x | F.R u x} (fun _ hx => hx) v huv w hvw

/-- With reflexivity and transitivity, the box operator computes topological
interiors. -/
theorem interior_eq_boxOp (F : KFrame) (hrefl : ∀ w : F.W, F.R w w)
    (htrans : ∀ u v w : F.W, F.R u v → F.R v w → F.R u w) (X : Set F.W) :
    @interior F.W (frameTopology F) X = boxOp F X := by
  letI : TopologicalSpace F.W := frameTopology F
  apply le_antisymm
  · intro w hw v hv
    exact interior_subset (isOpen_interior (s := X) w hw v hv)
  · exact interior_maximal (fun w hw => hw w (hrefl w)) (isOpen_boxOp F htrans X)

/-- **Bridge theorem.**  The provability operator of a frame is the interior operator
of its Alexandrov topology **iff** every world internalises its own soundness and the
frame is transitive.  Modal soundness-internalisation and topological interior
semantics are literally the same hypothesis. -/
theorem boxOp_eq_interior_iff (F : KFrame) (p : α) :
    (∀ X : Set F.W, @interior F.W (frameTopology F) X = boxOp F X) ↔
      ((∀ w : F.W, UniformlySoundAt F α w) ∧
        ∀ u v w : F.W, F.R u v → F.R v w → F.R u w) := by
  letI : TopologicalSpace F.W := frameTopology F
  constructor
  · intro h
    have hsub : ∀ X : Set F.W, boxOp F X ⊆ X := by
      intro X
      rw [← h X]
      exact interior_subset
    have hidem : ∀ X : Set F.W, boxOp F X ⊆ boxOp F (boxOp F X) := by
      intro X
      rw [← h X, ← h (interior X)]
      exact interior_maximal (fun _ hw => hw) isOpen_interior
    refine ⟨fun w => ?_, trans_of_boxOp_idem F hidem⟩
    exact (uniformlySound_iff_selfLoop F p w).mpr (selfLoop_of_boxOp_subset F hsub w)
  · rintro ⟨hsound, htrans⟩
    intro X
    exact interior_eq_boxOp F
      (fun w => (uniformlySound_iff_selfLoop F p w).mp (hsound w)) htrans X

/-- **No interior semantics for provability.**  On a nonempty GL frame the box
operator is never the topological interior operator: the very well-foundedness that
makes Löb's theorem true forbids the S4/Alexandrov picture. -/
theorem glFrame_boxOp_ne_interior (M : GLFrame) (w : M.W) :
    ¬ (∀ X : Set (M.toKFrame).W,
        @interior (M.toKFrame).W (frameTopology M.toKFrame) X = boxOp M.toKFrame X) := by
  intro h
  have hsub : ∀ X : Set (M.toKFrame).W, boxOp M.toKFrame X ⊆ X := by
    intro X
    rw [← h X]
    exact @interior_subset _ (frameTopology M.toKFrame) X
  exact M.irrefl w (selfLoop_of_boxOp_subset M.toKFrame hsub w)

/-! ## Part D — The reflection tower: one loop per stage -/

/-- The **reflection tower**: iterate the soundness extension `n` times.  Stage `n + 1`
is a system that reasons about — and validates the soundness of — stage `n`. -/
def iterExt (F : KFrame) : ℕ → KFrame
  | 0 => F
  | n + 1 => (iterExt F n).soundnessExt

@[simp] theorem iterExt_zero (F : KFrame) : iterExt F 0 = F := rfl

@[simp] theorem iterExt_succ (F : KFrame) (n : ℕ) :
    iterExt F (n + 1) = (iterExt F n).soundnessExt := rfl

/-- Every stage past the bottom has a sound world at the top. -/
theorem iterExt_sound_top (F : KFrame) (n : ℕ) :
    UniformlySoundAt (iterExt F (n + 1)) α none :=
  soundnessExt_sound_none _

/-- The self-loops of a soundness extension: the new top, plus the old loops. -/
theorem soundnessExt_selfLoop_set (G : KFrame) :
    {x : (G.soundnessExt).W | (G.soundnessExt).R x x}
      = insert none (some '' {x : G.W | G.R x x}) := by
  ext x
  cases x with
  | none => simp
  | some v =>
      simp only [Set.mem_setOf_eq, soundnessExt_R_some_some, Set.mem_insert_iff,
        Set.mem_image, reduceCtorEq, false_or]
      constructor
      · intro h; exact ⟨v, h, rfl⟩
      · rintro ⟨u, hu, huv⟩
        cases huv
        exact hu

/-- **One loop per reflection step.**  Over an irreflexive base frame, stage `n` of the
reflection tower has exactly `n` self-accessing worlds — and the set of them is
finite, no matter how large the base frame is. -/
theorem iterExt_selfLoop_ncard (F : KFrame) (hirr : ∀ w : F.W, ¬ F.R w w) (n : ℕ) :
    {x : (iterExt F n).W | (iterExt F n).R x x}.Finite ∧
      {x : (iterExt F n).W | (iterExt F n).R x x}.ncard = n := by
  induction n with
  | zero =>
      have h0 : {x : (iterExt F 0).W | (iterExt F 0).R x x} = ∅ := by
        ext x
        simpa [iterExt] using hirr x
      rw [h0]
      exact ⟨Set.finite_empty, Set.ncard_empty _⟩
  | succ n ih =>
      obtain ⟨hfin, hcard⟩ := ih
      rw [iterExt_succ, soundnessExt_selfLoop_set]
      have hinj : Function.Injective (some : (iterExt F n).W → Option (iterExt F n).W) :=
        Option.some_injective _
      have himfin : (some '' {x : (iterExt F n).W | (iterExt F n).R x x}).Finite :=
        hfin.image _
      have hnotmem : (none : Option (iterExt F n).W)
          ∉ some '' {x : (iterExt F n).W | (iterExt F n).R x x} := by
        simp
      refine ⟨himfin.insert _, ?_⟩
      rw [Set.ncard_insert_of_notMem hnotmem himfin,
        Set.ncard_image_of_injective _ hinj, hcard]

/-- **Exactly `n` internally sound worlds at stage `n`.**  Combining the loop count
with `uniformlySound_iff_selfLoop`: the reflection tower buys internal soundness at a
rate of exactly one sound world per stage. -/
theorem iterExt_sound_ncard (F : KFrame) (p : α) (hirr : ∀ w : F.W, ¬ F.R w w) (n : ℕ) :
    {x : (iterExt F n).W | UniformlySoundAt (iterExt F n) α x}.ncard = n := by
  have hset : {x : (iterExt F n).W | UniformlySoundAt (iterExt F n) α x}
      = {x : (iterExt F n).W | (iterExt F n).R x x} := by
    ext x
    exact uniformlySound_iff_selfLoop (iterExt F n) p x
  rw [hset]
  exact (iterExt_selfLoop_ncard F hirr n).2

/-- Every stage of the tower over a nonempty irreflexive base still contains an
irreflexive world. -/
theorem iterExt_has_irrefl_world (F : KFrame) (hirr : ∀ w : F.W, ¬ F.R w w)
    (w₀ : F.W) (n : ℕ) : ∃ x : (iterExt F n).W, ¬ (iterExt F n).R x x := by
  induction n with
  | zero => exact ⟨w₀, hirr w₀⟩
  | succ n ih =>
      obtain ⟨x, hx⟩ := ih
      exact ⟨some x, hx⟩

/-- **Stratification never converges.**  No finite number of reflection steps makes a
hierarchy internally sound everywhere: at every stage of the tower some world still
fails to validate its own soundness schema.  Full self-soundness is unreachable from
below — the tangle can be added, but never completed. -/
theorem iterExt_has_unsound_world (F : KFrame) (p : α) (hirr : ∀ w : F.W, ¬ F.R w w)
    (w₀ : F.W) (n : ℕ) : ∃ x : (iterExt F n).W, ¬ UniformlySoundAt (iterExt F n) α x := by
  obtain ⟨x, hx⟩ := iterExt_has_irrefl_world F hirr w₀ n
  exact ⟨x, fun h => hx ((uniformlySound_iff_selfLoop (iterExt F n) p x).mp h)⟩

/-- **Cycle-2 synthesis.**  For a nonempty GL frame `M` and any `n`: the `n`-th
reflection stage over `M` has exactly `n` internally sound worlds, still contains an
unsound world, has no ordinal grading, and its sound worlds all sit outside the least
fixed point of the box operator. -/
theorem reflection_tower_report (M : GLFrame) (p : α) (w₀ : M.W) (n : ℕ) :
    {x : (iterExt M.toKFrame n).W | UniformlySoundAt (iterExt M.toKFrame n) α x}.ncard = n
      ∧ (∃ x : (iterExt M.toKFrame n).W,
          ¬ UniformlySoundAt (iterExt M.toKFrame n) α x)
      ∧ (∀ x : (iterExt M.toKFrame (n + 1)).W,
          UniformlySoundAt (iterExt M.toKFrame (n + 1)) α x →
            x ∉ OrderHom.lfp (boxHom (iterExt M.toKFrame (n + 1)))
            ∧ ¬ ∃ rank : (iterExt M.toKFrame (n + 1)).W → Ordinal,
                ∀ a b, (iterExt M.toKFrame (n + 1)).R a b → rank b < rank a) := by
  have hirr : ∀ w : (M.toKFrame).W, ¬ (M.toKFrame).R w w := fun w => M.irrefl w
  refine ⟨iterExt_sound_ncard _ p hirr n, iterExt_has_unsound_world _ p hirr w₀ n,
    fun x hx => ⟨sound_notMem_lfp_boxOp _ p x hx,
      uniformlySound_no_ordinal_grading _ p x hx⟩⟩

end TangledSoundness

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H6. `μX.□X` is not merely "everything on GL frames" but *exactly* the well-founded
--       part of an arbitrary frame; hence the tangled core is a fixed-point-theoretic
--       invariant.
--   H7. The failure of levels caused by internal soundness is absolute: no ordinal,
--       indeed no well-founded, rank survives.
--   H8. (Bold, cross-domain) Internal soundness at every world plus positive
--       introspection is *equivalent* to the provability operator being a topological
--       interior operator — modal self-soundness = Alexandrov topology.
--   H9. (Quantitative) Iterating the soundness extension costs exactly one strange
--       loop per stage, and never reaches global self-soundness.
--
-- Experiment (Experimenter):
--   • H6: `lfp_boxOp_eq_accSet`. `≤` is Knaster–Tarski against the fixed point
--     `boxOp (Acc) = Acc` (Cycle 1's `boxOp_accSet`); `≥` is `Acc.rec` plus
--     `OrderHom.map_lfp`.  Corollary `sound_notMem_lfp_boxOp`.
--   • H7: `no_wf_rank_of_selfLoop` — a self-loop yields `s (rank w) (rank w)`, refuted
--     by `WellFounded.irrefl`.  Instantiated at `Ordinal` via `wellFounded_lt`.
--   • H8: `frameTopology` (opens = R-closed sets) is a genuine `TopologicalSpace`;
--     `isOpen_boxOp` needs transitivity, `interior_maximal` needs reflexivity, and the
--     converses are the two one-line valuation tricks `selfLoop_of_boxOp_subset`
--     (`X := R w ·`) and `trans_of_boxOp_idem` (`X := R u ·`).  `boxOp_eq_interior_iff`
--     packages both directions; `glFrame_boxOp_ne_interior` is the GL corner case.
--   • H9: `soundnessExt_selfLoop_set` computes the loop set of an extension as
--     `insert none (some '' old)`; `Set.ncard_insert_of_not_mem` plus
--     `Set.ncard_image_of_injective` give `ncard = n` by induction (finiteness is
--     carried along in the induction, since the base loop set is empty).
--     `iterExt_has_irrefl_world` (induction, transporting a witness along `some`)
--     yields `iterExt_has_unsound_world`.
--
-- Analysis (Analyst):
--   Survived: H6–H9, all sorry-free.  Structural pattern: *every* obstruction found in
--   this domain is the same obstruction seen through a different functor — the
--   self-loop is (i) a failure of accessibility (`lfp_boxOp_eq_accSet`), (ii) a failure
--   of ranking (`no_wf_rank_of_selfLoop`), and (iii) the presence of reflexivity that
--   topology demands (`boxOp_eq_interior_iff`).  The quantitative result H9 explains
--   *why* Tarski-style stratification feels endless: each metalevel adds exactly one
--   sound world and leaves the rest of the tower unsound, so the sound set has ncard
--   `n` while the tower keeps an irreflexive witness at every stage.
--   Needed a different definition: an early attempt to count "sound worlds" via
--   `Fintype.card` failed because the base frame may be infinite; `Set.ncard` of the
--   loop *set* is the right invariant, and it is finite even over infinite bases.
--
-- Critique (Critic):
--   `frameTopology` is not vacuous — its interior really is computed by `boxOp` on
--   reflexive transitive frames — and `boxOp_eq_interior_iff` is a genuine
--   biconditional, not a one-way implication dressed up.  The counting theorems are
--   guarded by the irreflexivity hypothesis on the base frame (satisfied by every GL
--   frame, `GLFrame.irrefl`), without which the count is false — the boundary is
--   stated explicitly rather than hidden.  `reflection_tower_report` combines only
--   previously established results and does not reference itself.
--
-- Synthesis (PI):
--   Internal soundness is a single geometric defect — reflexivity — with three faces:
--   fixed-point (outside `μX.□X`), order-theoretic (no rank), and topological
--   (interior semantics).  Stratifying adds one such defect per level and never
--   finishes.  See `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--