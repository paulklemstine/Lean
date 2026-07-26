import Mathlib

/-!
# Buttons and Switches in the Forcing Multiverse

Direction 2 of the research programme.  On a forcing frame `(W, R)` an *assertion*
is a predicate `P : W → Prop`.  Following Hamkins:

* a **button** is an assertion that, once true, stays necessarily true — i.e. it is
  *monotone* along the accessibility order;
* a **switch** is an assertion such that both it and its negation remain *possible*
  from every world.

We prove:

* `button_iff_box_fixed` — over a **reflexive** frame the buttons are *exactly*
  the fixed points of the necessity operator `□` (`box R P = P`).
* `button_and`, `button_or` — buttons are closed under conjunction and disjunction,
  and (`button_distrib`) satisfy the distributive law, so they form a distributive
  lattice.
* `switch_iff_nonconstant_of_complete` — in the *fully connected* multiverse
  (every world accesses every world, the finite-information equivalence frame) the
  switches are exactly the non-constant assertions: forcing can toggle any
  contingent statement, the Continuum Hypothesis included.
* `switch_not_button` — a genuine switch (which is possibly-false somewhere) is
  never a non-trivial button.
-/

namespace Multiverse

variable {W : Type*} (R : W → W → Prop)

/-- Necessity: `p` holds in every world accessible from `w`. -/
def box (P : W → Prop) (w : W) : Prop := ∀ v, R w v → P v

/-- Possibility: `p` holds in some world accessible from `w`. -/
def dia (P : W → Prop) (w : W) : Prop := ∃ v, R w v ∧ P v

/-- A **button**: monotone along accessibility.  Once `P` becomes true it is true
in every further extension. -/
def Button (P : W → Prop) : Prop := ∀ ⦃w v⦄, R w v → P w → P v

/-- A **switch**: from every world both `P` and `¬P` are still possible. -/
def Switch (P : W → Prop) : Prop := ∀ w, dia R P w ∧ dia R (fun x => ¬ P x) w

/-! ## Buttons are the fixed points of `□` -/

/-- Over a reflexive frame, an assertion is a button iff it is a fixed point of
the necessity operator: `□P = P` pointwise. -/
theorem button_iff_box_fixed (hrefl : Reflexive R) (P : W → Prop) :
    Button R P ↔ ∀ w, box R P w ↔ P w := by
  constructor
  · intro hP w
    exact ⟨fun h => h _ (hrefl _), fun h v hv => hP hv h⟩
  · intro h w v hv hw
    exact (h w).2 hw v hv

/-
Buttons are closed under conjunction.
-/
theorem button_and {P Q : W → Prop} (hP : Button R P) (hQ : Button R Q) :
    Button R (fun w => P w ∧ Q w) := by
  exact fun w v hv h => ⟨ hP hv h.1, hQ hv h.2 ⟩

/-
Buttons are closed under disjunction.
-/
theorem button_or {P Q : W → Prop} (hP : Button R P) (hQ : Button R Q) :
    Button R (fun w => P w ∨ Q w) := by
  exact fun w v h u => by cases u <;> [ left; right ] <;> · solve_by_elim;

/-
The lattice of buttons is distributive (pointwise Boolean distributivity).
-/
theorem button_distrib (P Q S : W → Prop) :
    (fun w => P w ∧ (Q w ∨ S w)) = (fun w => (P w ∧ Q w) ∨ (P w ∧ S w)) := by
  grind

/-! ## Switches in the fully connected multiverse -/

/-- The **complete** accessibility relation: every world accesses every world.
This models the finite-information equivalence frame in which any generic
extension is reachable from any other. -/
def completeRel (W : Type*) : W → W → Prop := fun _ _ => True

/-
In the (nonempty) complete multiverse, an assertion is a switch iff it is
non-constant: there is a world where it holds and a world where it fails.
-/
theorem switch_iff_nonconstant_of_complete [Nonempty W] (P : W → Prop) :
    Switch (completeRel W) P ↔ (∃ w, P w) ∧ (∃ w, ¬ P w) := by
  simp [Switch, dia, completeRel]

/-
A genuine switch is never a non-trivial button: if `P` is both a switch and a
button, then `P` is contradictory (false everywhere), so no contingent assertion
can be both.
-/
theorem switch_not_button (P : W → Prop)
    (hsw : Switch R P) (hbtn : Button R P) : ∀ w, ¬ P w := by
  intro w hw; obtain ⟨ v, hv, hv' ⟩ := hsw w |>.2; exact hv' ( hbtn hv hw ) ;

end Multiverse