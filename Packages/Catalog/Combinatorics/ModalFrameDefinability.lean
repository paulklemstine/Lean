/-
# Cycle 5, Part I: Frame Definability for the `KFrame` / `sat` Apparatus

Cycle 1 (`Logic.ProvabilityLogic.TangledSoundness`) introduced general Kripke frames
`KFrame` together with satisfaction `sat`, and Cycle 4
(`Logic.ProvabilityLogic.SelfSoundSystems`) introduced abstract proof systems
`ModalSystem` with two concrete witnesses (`glValiditySystem`, `tangledSystem`) and the
joint-inconsistency theorem.  What was missing — and what this file supplies — is the
**frame-definability** layer: the systematic correspondence between modal axioms and
first-order (indeed, *combinatorial*) conditions on the accessibility relation.

## Main definitions

* `FrameDefinability.Valid F α φ` — `φ` is valid on the frame `F` (true at every world
  under every valuation).
* `FrameDefinability.Defines α Γ C` — the set of formulas `Γ` **defines** the class of
  frames `C`: a frame validates every member of `Γ` exactly when it lies in `C`.

## Main results (correspondence theory)

* `defines_reflexive`, `defines_transitive`, `defines_serial`, `defines_symmetric`,
  `defines_euclidean` — the schemas `T`, `4`, `D`, `B`, `5` (each with a *single*
  propositional variable) define reflexivity, transitivity, seriality, symmetry and
  the euclidean property.
* `valid_loeb_iff` / `defines_GL` — **the deep case.**  A single Löb instance
  `□(□p → p) → □p` is valid on `F` **iff** `F.R` is transitive and converse
  well-founded.  Neither direction is formal: transitivity needs the valuation
  `x ↦ R w x ∧ (∀ y, R x y → R w y)`, and converse well-foundedness is obtained
  through `WellFounded.wellFounded_iff_has_min` with the valuation "not in the
  successor-closed set", entirely avoiding dependent choice.
* `valid_loeb_iff_finite` — **the combinatorial shadow.**  On a *finite* frame the Löb
  axiom is valid iff `R` is a strict partial order (transitive and irreflexive), so the
  Löb-frames on `Fin n` are exactly the labelled strict posets on `n` points.
* `defines_isEmpty` — `⊥` defines the empty frames, and `valid_of_isEmpty` shows every
  definable class contains the empty frame (hence non-emptiness is never definable).

## Relationship to the catalog
Uses `TangledSoundness.KFrame`, `TangledSoundness.sat`, `TangledSoundness.reflection`,
`TangledSoundness.loebInst` and `TangledSoundness.sat_con_iff` from Cycles 1–3, and
`GLPLogic.MFormula` from `Logic.ProvabilityLogic.GLPFrames`.  Part II
(`Combinatorics.ModalFrameDefinabilityLimits`) applies this layer to `ModalSystem`.
-/

import Mathlib
import Logic.ProvabilityLogic.SelfConsistentSemantics

namespace FrameDefinability

open GLPLogic TangledSoundness

universe u v

variable {α : Type v}

/-! ## Part A — Validity on a frame and the definability relation -/

/-- `φ` is **valid on the frame `F`**: it holds at every world under every valuation.
This is frame validity, as opposed to model truth: the valuation is universally
quantified, which is what makes validity a property of the *relation* alone. -/
def Valid (F : KFrame.{u}) (α : Type v) (φ : MFormula α) : Prop :=
  ∀ (V : α → F.W → Prop) (w : F.W), sat F V w φ

/-- A set of formulas `Γ` **defines** a class `C` of frames when a frame validates all
of `Γ` exactly when it belongs to `C`. -/
def Defines (α : Type v) (Γ : Set (MFormula α)) (C : KFrame.{u} → Prop) : Prop :=
  ∀ F : KFrame.{u}, (∀ φ ∈ Γ, Valid F α φ) ↔ C F

/-- Definability by a single axiom. -/
theorem defines_singleton_iff (φ : MFormula α) (C : KFrame.{u} → Prop) :
    Defines α {φ} C ↔ ∀ F : KFrame.{u}, Valid F α φ ↔ C F := by
  constructor
  · intro h F
    refine ⟨fun hv => (h F).mp (by rintro ψ rfl; exact hv), fun hC => ?_⟩
    exact (h F).mpr hC φ rfl
  · intro h F
    refine ⟨fun hv => (h F).mp (hv φ rfl), fun hC ψ hψ => ?_⟩
    rw [Set.mem_singleton_iff] at hψ
    subst hψ
    exact (h F).mpr hC

/-- Everything is valid on an empty frame; so every definable class contains the empty
frames, and no definable class can express non-emptiness. -/
theorem valid_of_isEmpty (F : KFrame.{u}) (hF : IsEmpty F.W) (φ : MFormula α) :
    Valid F α φ := fun _ w => hF.elim w

/-- `⊥` defines exactly the empty frames. -/
theorem defines_isEmpty : Defines α {MFormula.bot} (fun F : KFrame.{u} => IsEmpty F.W) := by
  rw [defines_singleton_iff]
  intro F
  constructor
  · intro h
    exact ⟨fun w => h (fun _ _ => False) w⟩
  · intro h
    exact valid_of_isEmpty F h _

/-- **Non-emptiness is not modally definable**: any candidate axiom set is validated by
the empty frame. -/
theorem nonempty_not_definable (Γ : Set (MFormula α)) :
    ¬ Defines α Γ (fun F : KFrame.{u} => Nonempty F.W) := by
  intro h
  have hempty : (⟨PEmpty, fun _ _ => False⟩ : KFrame.{u}).W → False := fun w => w.elim
  have := (h ⟨PEmpty, fun _ _ => False⟩).mp
    (fun φ _ => valid_of_isEmpty _ ⟨hempty⟩ φ)
  exact hempty this.some

/-! ## Part B — The classical correspondences `T`, `4`, `D`, `B`, `5` -/

/-- The transitivity axiom `4 : □p → □□p`. -/
def axiom4 (p : α) : MFormula α := .imp (.box (.var p)) (.box (.box (.var p)))

/-- The symmetry axiom `B : p → □◇p`. -/
def axiomB (p : α) : MFormula α := .imp (.var p) (.box (MFormula.dia (.var p)))

/-- The euclidean axiom `5 : ◇p → □◇p`. -/
def axiom5 (p : α) : MFormula α :=
  .imp (MFormula.dia (.var p)) (.box (MFormula.dia (.var p)))

theorem sat_dia_iff (F : KFrame.{u}) (V : α → F.W → Prop) (w : F.W) (φ : MFormula α) :
    sat F V w (MFormula.dia φ) ↔ ∃ v, F.R w v ∧ sat F V v φ := by
  simp only [MFormula.dia, MFormula.neg, sat_imp, sat_box, sat_bot]
  constructor
  · intro h
    by_contra hno
    push_neg at hno
    exact h (fun v hv hsat => hno v hv hsat)
  · rintro ⟨v, hv, hsat⟩ hbox
    exact hbox v hv hsat

/-- **`T` defines reflexivity.**  A single reflection instance over one variable is
already enough: the witnessing valuation is `x ↦ R w x`. -/
theorem defines_reflexive (p : α) :
    Defines α {reflection (MFormula.var p)} (fun F : KFrame.{u} => ∀ w, F.R w w) := by
  rw [defines_singleton_iff]
  intro F
  constructor
  · intro h w
    exact h (fun _ x => F.R w x) w (fun _ hv => hv)
  · intro h V w hbox
    exact hbox w (h w)

/-- **`4` defines transitivity.**  Valuation: `x ↦ R w x`. -/
theorem defines_transitive (p : α) :
    Defines α {axiom4 p} (fun F : KFrame.{u} => Transitive F.R) := by
  rw [defines_singleton_iff]
  intro F
  constructor
  · intro h w v u hwv hvu
    exact h (fun _ x => F.R w x) w (fun _ hx => hx) v hwv u hvu
  · intro htr V w hbox v hwv u hvu
    exact hbox u (htr hwv hvu)

/-- **`D` (the consistency formula `¬□⊥`) defines seriality.**  This connects the
frame-definability layer to Cycle 3's `sat_con_iff` and to Cycle 4's
`ModalSystem.serial_of_provesCon`. -/
theorem defines_serial :
    Defines α {MFormula.con} (fun F : KFrame.{u} => ∀ w, ∃ v, F.R w v) := by
  rw [defines_singleton_iff]
  intro F
  constructor
  · intro h w
    exact (sat_con_iff F (α := α) (fun _ _ => False) w).mp (h (fun _ _ => False) w)
  · intro h V w
    exact (sat_con_iff F V w).mpr (h w)

/-- **`B` defines symmetry.**  Valuation: `x ↦ x = w`. -/
theorem defines_symmetric (p : α) :
    Defines α {axiomB p} (fun F : KFrame.{u} => ∀ w v, F.R w v → F.R v w) := by
  rw [defines_singleton_iff]
  intro F
  constructor
  · intro h w v hwv
    have := h (fun _ x => x = w) w rfl v hwv
    rw [sat_dia_iff] at this
    obtain ⟨u, hvu, hu⟩ := this
    have hu' : u = w := hu
    exact hu' ▸ hvu
  · intro hsymm V w hw v hwv
    rw [sat_dia_iff]
    exact ⟨w, hsymm w v hwv, hw⟩

/-- **`5` defines the euclidean property.**  Valuation: `x ↦ x = u`. -/
theorem defines_euclidean (p : α) :
    Defines α {axiom5 p} (fun F : KFrame.{u} => ∀ w v u, F.R w v → F.R w u → F.R v u) := by
  rw [defines_singleton_iff]
  intro F
  constructor
  · intro h w v u hwv hwu
    have hdia : sat F (fun _ x => x = u) w (MFormula.dia (MFormula.var p)) := by
      rw [sat_dia_iff]; exact ⟨u, hwu, rfl⟩
    have := h (fun _ x => x = u) w hdia v hwv
    rw [sat_dia_iff] at this
    obtain ⟨z, hvz, hz⟩ := this
    have hz' : z = u := hz
    exact hz' ▸ hvz
  · intro heuc V w hdia v hwv
    rw [sat_dia_iff] at hdia ⊢
    obtain ⟨u, hwu, hu⟩ := hdia
    exact ⟨u, heuc w v u hwv hwu, hu⟩

/-! ## Part C — The Löb axiom defines the GL frames

This is the substantial correspondence.  Both directions require genuinely chosen
valuations, and the converse-well-foundedness half is obtained through the
"has a minimal element" characterisation of well-foundedness, so that no infinite
descending sequence (and hence no dependent choice) is ever constructed. -/

/-- Validity of the Löb axiom on a transitive, converse well-founded frame: the
semantic Löb theorem, proved by well-founded induction along `R`. -/
theorem valid_loebInst_of_gl (F : KFrame.{u}) (htr : Transitive F.R)
    (hwf : WellFounded (Function.swap F.R)) (φ : MFormula α) :
    Valid F α (loebInst φ) := by
  intro V w hbox v hwv
  induction v using hwf.induction with
  | _ v ih =>
      exact hbox v hwv (fun t hvt => ih t hvt (htr hwv hvt))

/-- From validity of one Löb instance: transitivity.  The valuation used is
`x ↦ R w x ∧ (∀ y, R x y → R w y)`, i.e. "`x` is a successor of `w` all of whose
successors are successors of `w`". -/
theorem transitive_of_valid_loebInst (F : KFrame.{u}) (p : α)
    (h : Valid F α (loebInst (MFormula.var p))) : Transitive F.R := by
  intro w v u hwv hvu
  set V : α → F.W → Prop := fun _ x => F.R w x ∧ ∀ y, F.R x y → F.R w y with hV
  have hpremise : sat F V w (.box (reflection (MFormula.var p))) := by
    intro z hwz hz
    refine ⟨hwz, fun y hzy => ?_⟩
    exact (hz y hzy).1
  exact (h V w hpremise v hwv).2 u hvu

/-- From validity of one Löb instance: converse well-foundedness.  If some nonempty set
`s` had no `R`-maximal element, the valuation "not in `s`" would make the Löb premise
true and the conclusion false at any point of `s`. -/
theorem converse_wf_of_valid_loebInst (F : KFrame.{u}) (p : α)
    (h : Valid F α (loebInst (MFormula.var p))) : WellFounded (Function.swap F.R) := by
  rw [WellFounded.wellFounded_iff_has_min]
  intro s hs
  by_contra hno
  push_neg at hno
  -- every element of `s` has an `R`-successor inside `s`
  have hstep : ∀ a ∈ s, ∃ b ∈ s, F.R a b := by
    intro a ha
    obtain ⟨b, hb, hab⟩ := hno a ha
    exact ⟨b, hb, hab⟩
  obtain ⟨w, hw⟩ := hs
  set V : α → F.W → Prop := fun _ x => x ∉ s with hV
  have hpremise : sat F V w (.box (reflection (MFormula.var p))) := by
    intro z _ hz hzs
    obtain ⟨b, hb, hzb⟩ := hstep z hzs
    exact hz b hzb hb
  have hconc : ∀ v, F.R w v → v ∉ s := h V w hpremise
  obtain ⟨b, hb, hwb⟩ := hstep w hw
  exact hconc b hwb hb

/-- **The Löb axiom defines the GL frames.**  One instance over one propositional
variable is valid on `F` exactly when `F.R` is transitive and converse well-founded —
the frame condition of provability logic. -/
theorem valid_loeb_iff (F : KFrame.{u}) (p : α) :
    Valid F α (loebInst (MFormula.var p)) ↔
      (Transitive F.R ∧ WellFounded (Function.swap F.R)) := by
  constructor
  · intro h
    exact ⟨transitive_of_valid_loebInst F p h, converse_wf_of_valid_loebInst F p h⟩
  · rintro ⟨htr, hwf⟩
    exact valid_loebInst_of_gl F htr hwf _

/-- The definability statement: `{Löb}` defines the class of GL frames. -/
theorem defines_GL (p : α) :
    Defines α {loebInst (MFormula.var p)}
      (fun F : KFrame.{u} => Transitive F.R ∧ WellFounded (Function.swap F.R)) := by
  rw [defines_singleton_iff]
  intro F
  exact valid_loeb_iff F p

/-- A frame validating the Löb axiom is irreflexive: the semantic reason a Löbian
system cannot host a tangle (Cycle 1's `loebAt_irrefl`, now in frame form). -/
theorem irreflexive_of_valid_loebInst (F : KFrame.{u}) (p : α)
    (h : Valid F α (loebInst (MFormula.var p))) : ∀ w, ¬ F.R w w := by
  intro w hw
  have hwf := converse_wf_of_valid_loebInst F p h
  exact (hwf.irrefl).irrefl w hw

/-- **Löb and reflection have no common frames but the empty ones.**  Combining
`defines_reflexive` with `irreflexive_of_valid_loebInst`: the semantic counterpart of
Cycle 4's joint-inconsistency theorem, at the level of frame classes. -/
theorem isEmpty_of_valid_loeb_and_reflection (F : KFrame.{u}) (p : α)
    (hL : Valid F α (loebInst (MFormula.var p)))
    (hT : Valid F α (reflection (MFormula.var p))) : IsEmpty F.W := by
  refine ⟨fun w => ?_⟩
  have hrefl : F.R w w := hT (fun _ x => F.R w x) w (fun _ hv => hv)
  exact irreflexive_of_valid_loebInst F p hL w hrefl

/-! ## Part D — The combinatorial shadow: finite Löb frames are strict posets -/

/-- **On finite frames, Löb validity is exactly strict-partial-orderhood.**  Converse
well-foundedness is a genuinely infinitary condition, but over a finite carrier it
collapses to irreflexivity in the presence of transitivity.  Consequently the finite
GL frames form a purely combinatorial class: the labelled strict posets. -/
theorem valid_loeb_iff_finite (F : KFrame.{u}) [Finite F.W] (p : α) :
    Valid F α (loebInst (MFormula.var p)) ↔
      (Transitive F.R ∧ ∀ w, ¬ F.R w w) := by
  constructor
  · intro h
    exact ⟨transitive_of_valid_loebInst F p h, irreflexive_of_valid_loebInst F p h⟩
  · rintro ⟨htr, hirr⟩
    have hwf : WellFounded (Function.swap F.R) := by
      haveI : IsTrans F.W (Function.swap F.R) :=
        ⟨fun a b c hab hbc => htr hbc hab⟩
      haveI : Std.Irrefl (Function.swap F.R) := ⟨fun a ha => hirr a ha⟩
      exact Finite.wellFounded_of_trans_of_irrefl _
    exact valid_loebInst_of_gl F htr hwf _

/-! ## Part E — The soundness spectrum of a definable class

Cycle 2 measured internal soundness by *degree*: `IterSoundAt F α n w` says that `w`
validates every instance of `□ⁿφ → φ`, and `iterSound_iff_cycle` identifies this with
lying on an `n`-cycle.  Frame definability now determines the whole spectrum of a frame
from a single axiom. -/

/-- **A Löb frame has no cycles at all**, of any length. -/
theorem no_cycle_of_valid_loebInst (F : KFrame.{u}) (p : α)
    (h : Valid F α (loebInst (MFormula.var p))) {n : ℕ} (hn : 0 < n) (w : F.W) :
    ¬ iterR F n w w := by
  intro hcyc
  obtain ⟨htr, -⟩ := (valid_loeb_iff F p).mp h
  have hww : F.R w w :=
    iterR_imp_R_of_trans F (fun _ _ _ h₁ h₂ => htr h₁ h₂) n hn hcyc
  exact irreflexive_of_valid_loebInst F p h w hww

/-- **The soundness spectrum of a Löb frame is empty**: no world of a frame validating
the Löb axiom has internal soundness of any positive degree.  This strengthens Cycle 2,
where the statement was available only for the built-in `GLFrame`s. -/
theorem not_iterSound_of_valid_loebInst (F : KFrame.{u}) (p : α)
    (h : Valid F α (loebInst (MFormula.var p))) {n : ℕ} (hn : 0 < n) (w : F.W) :
    ¬ IterSoundAt F α n w :=
  fun hs => no_cycle_of_valid_loebInst F p h hn w ((iterSound_iff_cycle F p n w).mp hs)

/-- On a frame whose accessibility is equality, every world lies on a cycle of every
length. -/
theorem iterR_self_of_eq_rel (F : KFrame.{u}) (heq : ∀ w v : F.W, F.R w v ↔ v = w)
    (w : F.W) : ∀ n : ℕ, iterR F n w w
  | 0 => rfl
  | n + 1 => ⟨w, (heq w w).mpr rfl, iterR_self_of_eq_rel F heq w n⟩

/-- **The soundness spectrum of an equality frame is everything.** -/
theorem iterSound_of_eq_rel (F : KFrame.{u}) (p : α)
    (heq : ∀ w v : F.W, F.R w v ↔ v = w) (n : ℕ) (w : F.W) : IterSoundAt F α n w :=
  (iterSound_iff_cycle F p n w).mpr (iterR_self_of_eq_rel F heq w n)

/-- **Spectrum dichotomy.**  A single axiom decides the entire soundness spectrum of a
frame: Löb frames have the empty spectrum, equality frames (the frames of the
self-sound system, see Part II) have the full spectrum `ℕ`. -/
theorem soundness_spectrum_dichotomy (F G : KFrame.{u}) (p : α)
    (hF : Valid F α (loebInst (MFormula.var p)))
    (hG : ∀ w v : G.W, G.R w v ↔ v = w) :
    (∀ n : ℕ, 0 < n → ∀ w : F.W, ¬ IterSoundAt F α n w) ∧
      (∀ n : ℕ, ∀ w : G.W, IterSoundAt G α n w) :=
  ⟨fun _ hn w => not_iterSound_of_valid_loebInst F p hF hn w,
    fun n w => iterSound_of_eq_rel G p hG n w⟩

end FrameDefinability

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H16. Every schema of Cycle 1–4 (`reflection`, `loebInst`, `MFormula.con`) is
--        frame-definable over `KFrame`/`sat` by a *single* instance over one
--        propositional variable — richness of the language is never needed.
--   H17. (Bold) The Löb axiom's frame condition can be extracted without any use of
--        dependent choice: the "no infinite ascending chain" reading can be replaced
--        by the "every nonempty set has a maximal element" reading, and the witnessing
--        valuation is the complement of the offending set.
--   H18. (Bold) Over finite carriers, the GL frame condition degenerates to a purely
--        combinatorial one (strict partial orders), so counting GL frames on `Fin n` is
--        counting labelled posets.
--
-- Experiment (Experimenter):
--   H16: confirmed for T, 4, D, B, 5 and Löb (`defines_reflexive`, ...,`defines_GL`);
--        the witnessing valuations are respectively `x ↦ R w x` (T, 4), `x ↦ x = w`
--        (B), `x ↦ x = u` (5) and the two valuations of Part C for Löb.  `D` needs no
--        variable at all, matching `sat_con_iff`.
--   H17: confirmed.  `converse_wf_of_valid_loebInst` runs through
--        `WellFounded.wellFounded_iff_has_min`; the valuation `x ↦ x ∉ s` makes
--        `□(□p → p)` true at any `w ∈ s` precisely because failure of maximality says
--        each point of `s` has a successor in `s`.
--   H18: confirmed as `valid_loeb_iff_finite`, via
--        `Finite.wellFounded_of_trans_of_irrefl`.  The counting consequences are
--        developed in `Combinatorics.ModalFrameCounting`.
--
-- Analysis (Analyst):
--   The pattern is uniform: an axiom is definable when the "hardest" valuation making
--   its antecedent true is definable from the accessibility relation itself
--   (`x ↦ R w x`, `x ↦ x ∉ s`).  This is exactly the Sahlqvist minimal-valuation
--   phenomenon, here instantiated concretely rather than proved in general.
--
-- Critique (Critic):
--   No theorem here is `rfl` or `decide`: each correspondence needs a chosen valuation,
--   and the Löb case needs well-founded induction in one direction and a classical
--   minimality argument in the other.  `nonempty_not_definable` is the one cheap
--   result, and it is kept only because it is the boundary fact used later
--   (definable classes always contain the empty frame).