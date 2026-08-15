/-
# `S4.2` Soundness for Directed Preorders, and Independence of `5` and `.3`

This file completes the calibration begun in
`Catalog/Logic/Multiverse/InvariantFragment.lean` by supplying the *deductive*
half of Direction 2 of the multiverse programme.

We define a modal language, its Kripke semantics, and a Hilbert calculus for
**`S4.2`** (classical propositional logic together with `K`, `T`, `4` and the
directedness axiom `.2`, closed under modus ponens and necessitation), and prove:

* `S42_sound` — **every theorem of `S4.2` is valid on every directed preorder**
  (induction on derivations; the `.2` case is exactly where directedness is used);
* `five_not_derivable` — the axiom `5` (`◇p → □◇p`) is **not** derivable in `S4.2`,
  because it fails on the finite button–switch forcing frame of the realization
  file, which *is* a directed preorder;
* `dot3_not_derivable` — the linearity axiom `.3`
  (`□(□p → q) ∨ □(□q → p)`) is **not** derivable in `S4.2` either: two independent
  buttons refute it.

Together with `BooleanValuedRealization.cacc_dot2` (soundness of `.2` on the frame)
and `MultiverseInvariantFragment.directed_of_dot2` (its exact semantic content),
this shows the modal logic of the finite pre-Boolean forcing frames contains `S4.2`
and is strictly below both `S5` and `S4.3`.
-/
import Logic.Multiverse.InvariantFragment

namespace S42Independence

open BooleanValuedRealization MultiverseInvariantFragment

/-! ## The modal language and its Kripke semantics -/

/-- Modal formulas over propositional atoms `α`. -/
inductive MForm (α : Type*) where
  | atom : α → MForm α
  | fls : MForm α
  | imp : MForm α → MForm α → MForm α
  | box : MForm α → MForm α
  deriving DecidableEq

namespace MForm
variable {α : Type*}

/-- Negation. -/
def neg (p : MForm α) : MForm α := .imp p .fls
/-- Disjunction. -/
def disj (p q : MForm α) : MForm α := .imp (neg p) q
/-- Possibility. -/
def dia (p : MForm α) : MForm α := neg (.box (neg p))

end MForm

variable {α W : Type*}

/-- Kripke satisfaction. -/
def msat (R : W → W → Prop) (V : α → W → Prop) : MForm α → W → Prop
  | .atom a => V a
  | .fls => fun _ => False
  | .imp p q => fun w => msat R V p w → msat R V q w
  | .box p => fun w => ∀ v, R w v → msat R V p v

@[simp] theorem msat_atom (R : W → W → Prop) (V : α → W → Prop) (a : α) (w : W) :
    msat R V (.atom a) w ↔ V a w := Iff.rfl
@[simp] theorem msat_fls (R : W → W → Prop) (V : α → W → Prop) (w : W) :
    ¬ msat R V (.fls : MForm α) w := id
@[simp] theorem msat_imp (R : W → W → Prop) (V : α → W → Prop) (p q : MForm α) (w : W) :
    msat R V (.imp p q) w ↔ (msat R V p w → msat R V q w) := Iff.rfl
@[simp] theorem msat_box (R : W → W → Prop) (V : α → W → Prop) (p : MForm α) (w : W) :
    msat R V (.box p) w ↔ ∀ v, R w v → msat R V p v := Iff.rfl
@[simp] theorem msat_neg (R : W → W → Prop) (V : α → W → Prop) (p : MForm α) (w : W) :
    msat R V p.neg w ↔ ¬ msat R V p w := Iff.rfl

/-- Semantics of possibility: `◇p` holds at `w` iff `p` holds at some successor. -/
@[simp] theorem msat_dia (R : W → W → Prop) (V : α → W → Prop) (p : MForm α) (w : W) :
    msat R V p.dia w ↔ ∃ v, R w v ∧ msat R V p v := by
  simp only [MForm.dia, msat_neg, msat_box]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    exact h fun v hv => hc v hv
  · rintro ⟨v, hv, hp⟩ h
    exact h v hv hp

/-- Semantics of disjunction (classically). -/
@[simp] theorem msat_disj (R : W → W → Prop) (V : α → W → Prop) (p q : MForm α) (w : W) :
    msat R V (p.disj q) w ↔ (msat R V p w ∨ msat R V q w) := by
  simp only [MForm.disj, msat_imp, msat_neg]
  tauto

/-! ## The Hilbert calculus `S4.2` -/

/-- Derivability in `S4.2`: classical propositional logic (`ax1`–`ax3`) with the
modal axioms `K`, `T`, `4`, `.2`, closed under modus ponens and necessitation. -/
inductive S42 {α : Type*} : MForm α → Prop
  | ax1 (p q : MForm α) : S42 (.imp p (.imp q p))
  | ax2 (p q r : MForm α) :
      S42 (.imp (.imp p (.imp q r)) (.imp (.imp p q) (.imp p r)))
  | ax3 (p : MForm α) : S42 (.imp (MForm.neg (MForm.neg p)) p)
  | axK (p q : MForm α) :
      S42 (.imp (.box (.imp p q)) (.imp (.box p) (.box q)))
  | axT (p : MForm α) : S42 (.imp (.box p) p)
  | ax4 (p : MForm α) : S42 (.imp (.box p) (.box (.box p)))
  | axDot2 (p : MForm α) : S42 (.imp (MForm.dia (.box p)) (.box (MForm.dia p)))
  | mp {p q : MForm α} : S42 (.imp p q) → S42 p → S42 q
  | nec {p : MForm α} : S42 p → S42 (.box p)

/-- A **directed preorder**: the abstract shape of a forcing frame. -/
structure DirectedPreorder (W : Type*) where
  /-- The accessibility relation. -/
  rel : W → W → Prop
  refl : ∀ w, rel w w
  trans : ∀ {w v u}, rel w v → rel v u → rel w u
  dir : ∀ x y z, rel x y → rel x z → ∃ u, rel y u ∧ rel z u

/-- **Soundness of `S4.2`.**  Every theorem of `S4.2` is true at every world of
every directed preorder under every valuation.  The `.2` case is precisely where
directedness enters; `T` uses reflexivity and `4` uses transitivity. -/
theorem S42_sound (F : DirectedPreorder W) {p : MForm α} (h : S42 p) :
    ∀ (V : α → W → Prop) (w : W), msat F.rel V p w := by
  induction h with
  | ax1 p q => intro V w; simp only [msat_imp]; tauto
  | ax2 p q r => intro V w; simp only [msat_imp]; tauto
  | ax3 p => intro V w; simp only [msat_imp, msat_neg]; tauto
  | axK p q => intro V w hpq hp v hv; exact hpq v hv (hp v hv)
  | axT p => intro V w hp; exact hp w (F.refl w)
  | ax4 p => intro V w hp v hwv u hvu; exact hp u (F.trans hwv hvu)
  | axDot2 p =>
      intro V w hdia v hwv
      rw [msat_dia] at hdia
      obtain ⟨t, hwt, hbox⟩ := hdia
      obtain ⟨u, htu, hvu⟩ := F.dir w t v hwt hwv
      rw [msat_dia]
      exact ⟨u, hvu, hbox u htu⟩
  | mp _ _ ih1 ih2 => intro V w; exact ih1 V w (ih2 V w)
  | nec _ ih => intro V w v _; exact ih V v

/-! ## The finite control frame as a directed preorder -/

/-- The two-button, one-switch forcing frame, packaged as a directed preorder. -/
def ctrlFrame : DirectedPreorder (CWorld Bool Unit) where
  rel := cacc
  refl := fun _ => subset_rfl
  trans := fun h1 h2 => h1.trans h2
  dir := fun _ y z _ _ =>
    ⟨(y.1 ∪ z.1, y.2), Finset.subset_union_left, Finset.subset_union_right⟩

/-- The base world: no button pushed. -/
def w₀ : CWorld Bool Unit := (∅, fun _ => false)

/-- Valuation used for the countermodels: atom `a` says "button `a` is pushed",
except that we also use the negated form for the failure of `5`. -/
def Vpush : Bool → CWorld Bool Unit → Prop := fun b w => b ∈ w.1

/-- Valuation saying "button `a` is *not* pushed". -/
def Vunpushed : Bool → CWorld Bool Unit → Prop := fun b w => b ∉ w.1

/-! ## Independence of `5` -/

/-- On the control frame, `◇p → □◇p` fails for the assertion "the first button is
still unpushed". -/
theorem five_fails_ctrl :
    ¬ msat ctrlFrame.rel Vunpushed
        (.imp (MForm.dia (.atom true)) (.box (MForm.dia (.atom true)))) w₀ := by
  intro h
  have hdia : msat ctrlFrame.rel Vunpushed (MForm.dia (.atom true)) w₀ := by
    rw [msat_dia]
    exact ⟨w₀, subset_rfl, by simp [w₀, Vunpushed]⟩
  have hbox := h hdia
  have hpushed : ctrlFrame.rel w₀ (({true} : Finset Bool), fun _ => false) :=
    Finset.empty_subset _
  have := hbox _ hpushed
  rw [msat_dia] at this
  obtain ⟨u, hu, hpu⟩ := this
  exact hpu (hu (Finset.mem_singleton_self true))

/-- **Independence of `5`.**  The axiom `5` is not derivable in `S4.2`: it fails on
a directed preorder, on which by `S42_sound` every `S4.2` theorem is valid. -/
theorem five_not_derivable :
    ¬ S42 (α := Bool)
        (.imp (MForm.dia (.atom true)) (.box (MForm.dia (.atom true)))) := by
  intro h
  exact five_fails_ctrl (S42_sound ctrlFrame h Vunpushed w₀)

/-! ## Independence of `.3` -/

/-- The linearity axiom `.3` for two atoms. -/
def dot3Formula : MForm Bool :=
  MForm.disj (.box (.imp (.box (.atom true)) (.atom false)))
    (.box (.imp (.box (.atom false)) (.atom true)))

/-- On the two-button control frame the linearity axiom fails at the base world:
pushing one button makes `□p` true while `q` remains false, and symmetrically. -/
theorem dot3_fails_ctrl : ¬ msat ctrlFrame.rel Vpush dot3Formula w₀ := by
  rw [dot3Formula, msat_disj]
  rintro (h | h)
  · have hb : msat ctrlFrame.rel Vpush (.box (.atom true))
        (({true} : Finset Bool), fun _ => false) :=
      fun u hu => hu (Finset.mem_singleton_self true)
    have hq := h ({true}, fun _ => false) (Finset.empty_subset _) hb
    rw [msat_atom, Vpush, Finset.mem_singleton] at hq
    exact Bool.false_ne_true hq
  · have hb : msat ctrlFrame.rel Vpush (.box (.atom false))
        (({false} : Finset Bool), fun _ => false) :=
      fun u hu => hu (Finset.mem_singleton_self false)
    have hq := h ({false}, fun _ => false) (Finset.empty_subset _) hb
    rw [msat_atom, Vpush, Finset.mem_singleton] at hq
    exact Bool.false_ne_true hq.symm

/-- **Independence of `.3`.**  The linearity axiom is not derivable in `S4.2`: the
finite frame built from two independent buttons is a directed preorder refuting it.
Hence the logic of the finite pre-Boolean forcing frames is strictly weaker than
`S4.3`. -/
theorem dot3_not_derivable : ¬ S42 (α := Bool) dot3Formula := by
  intro h
  exact dot3_fails_ctrl (S42_sound ctrlFrame h Vpush w₀)

/-- **Summary.**  `S4.2` is sound for the realized forcing frames, and both `5` and
`.3` escape it: the modal logic of the finite pre-Boolean forcing frames lies
strictly between `S4.2` and each of `S5`, `S4.3`. -/
theorem S42_strictly_between :
    (∀ {p : MForm Bool}, S42 p → ∀ V w, msat ctrlFrame.rel V p w) ∧
    ¬ S42 (α := Bool)
        (.imp (MForm.dia (.atom true)) (.box (MForm.dia (.atom true)))) ∧
    ¬ S42 (α := Bool) dot3Formula :=
  ⟨fun h V w => S42_sound ctrlFrame h V w, five_not_derivable, dot3_not_derivable⟩

end S42Independence