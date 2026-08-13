/-
# Multiverse-Invariant Fragments, Exact Frame Calibration and Branch Preservation

This file continues `Catalog/Logic/Multiverse/BooleanValuedRealization.lean`, whose
Boolean-valued universe and control frame it takes as given, and settles three
further directions of the multiverse programme.

## 1. Exact calibration of the modal strength of the frame (Direction 2)

* `directed_of_dot2` — the schema `.2` (`◇□p → □◇p`), valid for *all* predicates,
  **implies** directedness: `.2` is exactly directedness, so nothing weaker than a
  directed frame can validate it.
* `cacc_euclidean_iff` — the forcing frame is Euclidean (i.e. validates `5`)
  **iff there are no buttons at all**.  One button already destroys `S5`.
* `dot3_fails` — with two *independent* buttons the frame refutes the linearity
  axiom `.3`.  Hence the frame sits strictly between `S4.2` and `S4.3`: it is a
  genuine `S4.2` frame, not accidentally linear.

## 2. The multiverse-invariant fragment theorem (Direction 3)

`buttonFree_invariant` shows that the **button-free fragment** is invariant under
both forcing extensions and grounds; `invariant_iff_buttonFree` proves the sharp
converse: *an assertion is invariant along the button order iff it is equivalent to
a button-free assertion*.  The proof substitutes `⊥` for every button atom
(`subBtnFls`) and uses the substitution lemma `csat_subBtnFls`.  This is a genuine
characterization, and it is falsifiable in the intended sense: a single button atom
already fails invariance (`btn_atom_not_invariant`).

## 3. Calibration of branching by preserved backgrounds (Direction 4)

The exact preservation criterion is Boolean:

* `background_branches_iff` — a background condition `b` survives into **both** a
  `p`-branch and a `¬p`-branch **iff** `b ⊓ ⟦p⟧ ≠ ⊥` and `b ⊓ ⟦p⟧ᶜ ≠ ⊥`.

Applied to the control frame this yields `button_background_branches`: every
*button-definable* background (the abstract stand-in for an indestructible
large-cardinal assertion) is preserved in both CH branches, while
`background_obstruction` exhibits the boundary — a switch-dependent background has
an empty meet with one branch and therefore cannot be preserved.
-/
import Logic.Multiverse.BooleanValuedRealization

namespace MultiverseInvariantFragment

open Multiverse BooleanValuedRealization

/-! ## 1. Exact calibration of the modal strength of the frame -/

section Calibration

variable {W : Type*}

/-- A relation is **Euclidean** when any two successors of a point are related;
this is the frame condition for the modal axiom `5`. -/
def EuclideanRel (R : W → W → Prop) : Prop := ∀ x y z, R x y → R x z → R y z

/-- **`.2` is exactly directedness.**  If the schema `◇□p → □◇p` holds for every
predicate at every world, the frame must be directed.  Together with the soundness
proof `cacc_dot2` this pins the semantic content of the axiom `.2`. -/
theorem directed_of_dot2 (R : W → W → Prop)
    (h : ∀ (P : W → Prop) (w : W), dia R (box R P) w → box R (dia R P) w) :
    ∀ x y z, R x y → R x z → ∃ u, R y u ∧ R z u := by
  intro x y z hxy hxz
  have hdia : dia R (box R (fun t => R y t)) x := ⟨y, hxy, fun _ ht => ht⟩
  obtain ⟨u, hzu, huy⟩ := h (fun t => R y t) x hdia z hxz
  exact ⟨u, huy, hzu⟩

variable {Btn Sw : Type*}

/-- **One button already refutes `S5`.**  The forcing frame is Euclidean — i.e.
validates the axiom `5` — precisely when there is no button to push. -/
theorem cacc_euclidean_iff : EuclideanRel (cacc (Btn := Btn) (Sw := Sw)) ↔ IsEmpty Btn := by
  constructor
  · intro he
    refine ⟨fun b => ?_⟩
    have hbad : cacc (({b} : Finset Btn), (fun _ => false : Sw → Bool))
        ((∅ : Finset Btn), (fun _ => false : Sw → Bool)) :=
      he ((∅ : Finset Btn), fun _ => false) ({b}, fun _ => false) (∅, fun _ => false)
        (Finset.empty_subset _) (Finset.empty_subset _)
    have : b ∈ (∅ : Finset Btn) := hbad (Finset.mem_singleton_self b)
    simp at this
  · intro hemp x y z _ _
    have : y.1 = (∅ : Finset Btn) := Finset.eq_empty_of_isEmpty y.1
    rw [cacc, this]
    exact Finset.empty_subset _

/-- **The frame is not linear.**  With two distinct buttons the linearity axiom
`.3`, `□(□p → q) ∨ □(□q → p)`, fails at the button-free world: pushing the first
button makes `□p` true while `q` stays false, and symmetrically.  So the logic of
the frame is strictly below `S4.3`. -/
theorem dot3_fails (b₁ b₂ : Btn) (hne : b₁ ≠ b₂) (g : Sw → Bool) :
    ¬ (box cacc (fun v => box cacc (pushedP b₁) v → pushedP b₂ v)
          ((∅ : Finset Btn), g)
      ∨ box cacc (fun v => box cacc (pushedP b₂) v → pushedP b₁ v)
          ((∅ : Finset Btn), g)) := by
  rintro (h | h)
  · have hb : box cacc (pushedP b₁) (({b₁} : Finset Btn), g) :=
      fun u hu => hu (Finset.mem_singleton_self b₁)
    have := h ({b₁}, g) (Finset.empty_subset _) hb
    rw [pushedP, Finset.mem_singleton] at this
    exact hne this.symm
  · have hb : box cacc (pushedP b₂) (({b₂} : Finset Btn), g) :=
      fun u hu => hu (Finset.mem_singleton_self b₂)
    have := h ({b₂}, g) (Finset.empty_subset _) hb
    rw [pushedP, Finset.mem_singleton] at this
    exact hne this

end Calibration

/-! ## 2. The multiverse-invariant fragment -/

section Fragment

variable {Btn Sw : Type*}

/-- The **button-free fragment**: assertions built from switch atoms only. -/
inductive ButtonFree : BForm (CAtom Btn Sw) → Prop
  | atom (s : Sw) : ButtonFree (.atom (.sw s))
  | fls : ButtonFree .fls
  | imp {p q} : ButtonFree p → ButtonFree q → ButtonFree (p.imp q)

/-- **Bidirectional invariance of the button-free fragment.**  A button-free
assertion has the same truth value in every world with the same switch setting —
in particular it is preserved by forcing extensions *and* by passing to grounds. -/
theorem buttonFree_invariant {p : BForm (CAtom Btn Sw)} (hp : ButtonFree p)
    (S T : Finset Btn) (g : Gen Sw) : csat (S, g) p ↔ csat (T, g) p := by
  induction hp with
  | atom s => exact Iff.rfl
  | fls => exact Iff.rfl
  | imp _ _ ih1 ih2 =>
      simp only [csat, sat_imp] at *
      rw [ih1, ih2]

/-- **Bidirectionality.**  A button-free assertion is simultaneously a button for
the forcing-extension relation *and* for the ground relation (both restricted to
moves that do not touch the switches).  Extension preservation alone would only
give necessity above a world; bidirectionality is what turns local truth into
multiverse truth. -/
theorem buttonFree_bidirectional {p : BForm (CAtom Btn Sw)} (hp : ButtonFree p) :
    Button (fun w v : CWorld Btn Sw => cacc w v ∧ w.2 = v.2) (fun w => csat w p) ∧
    Button (fun w v : CWorld Btn Sw => cgnd w v ∧ w.2 = v.2) (fun w => csat w p) := by
  constructor <;>
  · rintro ⟨S, g⟩ ⟨T, h⟩ ⟨-, hsw⟩ hw
    cases hsw
    exact (buttonFree_invariant hp S T g).1 hw

/-- Substituting `⊥` for every button atom. -/
def subBtnFls : BForm (CAtom Btn Sw) → BForm (CAtom Btn Sw)
  | .atom (.btn _) => .fls
  | .atom (.sw s) => .atom (.sw s)
  | .fls => .fls
  | .imp p q => .imp (subBtnFls p) (subBtnFls q)

theorem buttonFree_subBtnFls (p : BForm (CAtom Btn Sw)) : ButtonFree (subBtnFls p) := by
  induction p with
  | atom a => cases a with
    | btn b => exact ButtonFree.fls
    | sw s => exact ButtonFree.atom s
  | fls => exact ButtonFree.fls
  | imp p q ih1 ih2 => exact ButtonFree.imp ih1 ih2

/-- **Substitution lemma.**  Erasing the buttons computes the truth value of an
assertion at the button-free stage. -/
theorem csat_subBtnFls (S : Finset Btn) (g : Gen Sw) (p : BForm (CAtom Btn Sw)) :
    csat (S, g) (subBtnFls p) ↔ csat ((∅ : Finset Btn), g) p := by
  induction p with
  | atom a => cases a with
    | btn b => simp [csat, subBtnFls, sat, atomTrue]
    | sw s => exact Iff.rfl
  | fls => exact Iff.rfl
  | imp p q ih1 ih2 =>
      simp only [subBtnFls, csat, sat_imp] at *
      rw [ih1, ih2]

/-- **Invariant fragment theorem.**  An assertion is invariant along the button
order — i.e. its truth value at a world depends only on the switch setting, so it
is preserved by *both* forcing extensions and grounds — **iff** it is equivalent to
a button-free assertion.  The button-free fragment is therefore *exactly* the
multiverse-invariant fragment of the language. -/
theorem invariant_iff_buttonFree (p : BForm (CAtom Btn Sw)) :
    (∀ (S T : Finset Btn) (g : Gen Sw), csat (S, g) p ↔ csat (T, g) p) ↔
      ∃ q, ButtonFree q ∧ ∀ (S : Finset Btn) (g : Gen Sw), (csat (S, g) p ↔ csat (S, g) q) := by
  constructor
  · intro hinv
    refine ⟨subBtnFls p, buttonFree_subBtnFls p, fun S g => ?_⟩
    rw [csat_subBtnFls]
    exact hinv S ∅ g
  · rintro ⟨q, hq, hpq⟩ S T g
    rw [hpq S g, hpq T g]
    exact buttonFree_invariant hq S T g

/-- **Sharpness / falsifiability.**  A button atom is *not* invariant: it changes
truth value along a forcing extension.  So the characterization above is not
vacuous, and no fragment containing a button atom is multiverse-invariant. -/
theorem btn_atom_not_invariant (b : Btn) (g : Gen Sw) :
    ¬ (∀ (S T : Finset Btn) (g : Gen Sw),
        csat (S, g) (.atom (.btn b)) ↔ csat (T, g) (.atom (.btn b))) := by
  intro h
  have : csat (({b} : Finset Btn), g) (.atom (.btn b)) ↔
      csat ((∅ : Finset Btn), g) (.atom (.btn b)) := h _ _ g
  have hb : csat (({b} : Finset Btn), g) (.atom (.btn b)) := by
    simp [csat, sat, atomTrue]
  have := this.1 hb
  simp [csat, sat, atomTrue] at this

/-- **Multiverse truth from local truth.**  If a button-free assertion holds in one
world, it holds throughout the whole switch fibre of the multiverse — every world
reachable by any zigzag of forcing extensions and grounds that does not move the
switches. -/
theorem buttonFree_multiverse_true {p : BForm (CAtom Btn Sw)} (hp : ButtonFree p)
    {S : Finset Btn} {g : Gen Sw} (h : csat (S, g) p) (T : Finset Btn) :
    csat (T, g) p :=
  (buttonFree_invariant hp S T g).1 h

end Fragment

/-! ## 3. Calibration of branching by preserved backgrounds -/

section Background

variable {α : Type*} {B : Type*} [BooleanAlgebra B]

/-- **Exact preservation criterion.**  A background condition `b` (the abstract
stand-in for "the fixed hierarchy of large-cardinal assertions still holds") is
preserved into both a `p`-branch and a `¬p`-branch of the multiverse **iff** `b`
meets both `⟦p⟧` and its complement.  This is the weakest possible preservation
hypothesis: it is not merely sufficient but necessary. -/
theorem background_branches_iff (hR : Rich B) (v : α → B) (b : B) (p : BForm α) :
    ((∃ U : Generic B, U.mem b ∧ sat (quot v U) p) ∧
      (∃ U : Generic B, U.mem b ∧ ¬ sat (quot v U) p)) ↔
      (b ⊓ bval v p ≠ ⊥ ∧ b ⊓ (bval v p)ᶜ ≠ ⊥) := by
  constructor
  · rintro ⟨⟨U, hUb, hUp⟩, ⟨V, hVb, hVp⟩⟩
    constructor
    · intro hbot
      exact U.bot_notMem (hbot ▸ U.inf_mem hUb ((sat_quot_iff v U p).1 hUp))
    · intro hbot
      have hc : V.mem (bval v p)ᶜ := (V.compl_mem_iff _).2 (fun hm =>
        hVp ((sat_quot_iff v V p).2 hm))
      exact V.bot_notMem (hbot ▸ V.inf_mem hVb hc)
  · rintro ⟨h1, h2⟩
    obtain ⟨U, hU⟩ := hR _ h1
    obtain ⟨V, hV⟩ := hR _ h2
    refine ⟨⟨U, U.up hU inf_le_left, (sat_quot_iff v U p).2 (U.up hU inf_le_right)⟩,
      ⟨V, V.up hV inf_le_left, ?_⟩⟩
    rw [sat_quot_iff]
    exact (V.compl_mem_iff _).1 (V.up hV inf_le_right)

variable {Btn Sw : Type*}

/-- **Uniform preparation for button-definable backgrounds.**  A background that
depends only on which buttons are pushed (an indestructible large-cardinal
assertion, in the intended reading) survives into *both* CH branches: nothing about
the background needs to be assumed beyond button-definability. -/
theorem branching_preserves_background (Θ : Finset Btn → Prop) {S : Finset Btn}
    (hΘ : Θ S) (s : Sw) (g : Gen Sw) :
    ∃ v₁ v₂ : CWorld Btn Sw, cacc (S, g) v₁ ∧ cacc (S, g) v₂ ∧ Θ v₁.1 ∧ Θ v₂.1 ∧
      csat v₁ (chAtom s) ∧ ¬ csat v₂ (chAtom s) := by
  refine ⟨(S, fun _ => true), (S, fun _ => false), subset_rfl, subset_rfl, hΘ, hΘ, ?_, ?_⟩
  · exact rfl
  · simp [csat, chAtom, atomTrue]

/-- The Boolean-valued form of the previous theorem: the value of a pushed button
meets both the CH branch and the `¬CH` branch, so by `background_branches_iff` a
button background is preserved in two opposite generic quotients of one and the
same Boolean-valued universe. -/
theorem button_background_branches (S : Finset Btn) (b : Btn) (s : Sw) (hb : b ∈ S) :
    (∃ U : Generic (Set (Gen Sw)), U.mem (cassign S (CAtom.btn b)) ∧
        sat (quot (cassign S) U) (chAtom (Btn := Btn) s)) ∧
    (∃ U : Generic (Set (Gen Sw)), U.mem (cassign S (CAtom.btn b)) ∧
        ¬ sat (quot (cassign S) U) (chAtom (Btn := Btn) s)) := by
  refine (background_branches_iff (rich_set _) (cassign S) _ (chAtom s)).2 ⟨?_, ?_⟩
  · intro hbot
    have hmem : (fun _ => true : Gen Sw) ∈
        cassign S (CAtom.btn b) ⊓ bval (cassign S) (chAtom (Btn := Btn) s) := by
      constructor
      · exact hb
      · simp [chAtom, cassign]
    rw [hbot] at hmem
    exact hmem
  · intro hbot
    have hmem : (fun _ => false : Gen Sw) ∈
        cassign S (CAtom.btn b) ⊓ (bval (cassign S) (chAtom (Btn := Btn) s))ᶜ := by
      constructor
      · exact hb
      · simp [chAtom, cassign]
    rw [hbot] at hmem
    exact hmem

/-- **Preservation obstruction.**  The criterion is sharp: a switch-dependent
background — here the background "CH holds" itself — is nonzero yet has empty meet
with the `¬CH` side, so by `background_branches_iff` no preparation can carry it
into both branches. -/
theorem background_obstruction (S : Finset Btn) (s : Sw) :
    bval (cassign (Btn := Btn) S) (chAtom s) ≠ ⊥ ∧
    bval (cassign (Btn := Btn) S) (chAtom s) ⊓
      (bval (cassign (Btn := Btn) S) (chAtom s))ᶜ = ⊥ := by
  refine ⟨bval_ch_ne_bot S s, inf_compl_self _⟩

/-- Consequently the "CH" background admits **no** pair of opposite branches: the
necessary condition of `background_branches_iff` fails. -/
theorem no_branches_for_ch_background (S : Finset Btn) (s : Sw) :
    ¬ ((∃ U : Generic (Set (Gen Sw)),
          U.mem (bval (cassign (Btn := Btn) S) (chAtom s)) ∧
          sat (quot (cassign S) U) (chAtom (Btn := Btn) s)) ∧
       (∃ U : Generic (Set (Gen Sw)),
          U.mem (bval (cassign (Btn := Btn) S) (chAtom s)) ∧
          ¬ sat (quot (cassign S) U) (chAtom (Btn := Btn) s))) := by
  intro h
  have := (background_branches_iff (rich_set _) (cassign S) _ (chAtom (Btn := Btn) s)).1 h
  exact this.2 (background_obstruction S s).2

end Background

end MultiverseInvariantFragment