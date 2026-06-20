import Mathlib

/-!
# Dream Logic I — Belnap's Four-Valued Paraconsistent Logic (FDE)

This file formalizes Belnap's four-valued logic `FOUR`, the canonical algebraic
home of *paraconsistent* and *paracomplete* reasoning.  The four values are

* `true`    — established to hold,
* `false`   — established to fail,
* `both`    — a **glut**: information says it holds *and* fails (a dialetheia),
* `neither` — a **gap**: no information either way (belief retracted / suspended).

Conjunction and disjunction are the meet and join in the *truth order*
(`false < both, neither < true`, with `both` and `neither` incomparable — the
"diamond" lattice).  Negation fixes the two "impossible objects" `both` and
`neither` and swaps `true`/`false`.  A value is *designated* (= asserted /
believed) when it is `true` or `both`.

## Main results

* `Belnap.lnc_can_fail` — the Law of Non-Contradiction can fail: there is a
  value whose conjunction with its own negation is designated (a *coexisting
  contradiction*, i.e. an impossible object that is nevertheless accepted).
* `Belnap.explosion_fails` — *ex contradictione quodlibet* fails: an accepted
  contradiction does **not** entail every proposition.  This is the defining
  feature of a paraconsistent logic.
* `Belnap.lem_can_fail` — the Law of Excluded Middle can fail (belief gaps /
  retraction), via the `neither` value.
* `Belnap.glut_iff` / `Belnap.gap_iff` — exact characterizations: `both` is the
  *only* glut value and `neither` is the *only* gap value.
* `Belnap.classical_no_glut` / `Belnap.classical_explosion` — the contrasting
  classical (Boolean) facts, certifying that the failure of explosion is a
  genuine feature of `FOUR`, not of Lean's logic.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): "A finite truth-value algebra can host accepted
  contradictions without trivializing (explosion)."  Counter-intuitive sub-claim:
  the *same* algebra simultaneously breaks Excluded Middle.
Experiment (Stage 2): Built `FOUR` as an `inductive`, defined meet/join/neg by
  the diamond truth order, proved explosion fails by exhibiting the witness pair
  `(both, false)`.  Excluded middle fails via `neither`.
Analysis (Stage 3): Survived. The dual failure (LNC fails AND LEM fails) is
  *exactly* what distinguishes `both` (glut) from `neither` (gap); `glut_iff`
  and `gap_iff` make this precise — each "impossible" value is uniquely
  responsible for one law's failure.
Critique (Stage 4): To rule out the proof being a Lean artifact we add the
  classical contrast lemmas; `Bool` has no glut and *does* explode, so the
  paraconsistency is a property of `FOUR`'s designation, not of the metatheory.
Synthesis (Stage 5): The De Morgan / lattice lemmas show `FOUR` is a De Morgan
  algebra, the bridge to the topological model in the Geometry domain.
-/

namespace DreamLogic

/-- Belnap's four truth values (FDE / `FOUR`). -/
inductive Belnap
  | true
  | false
  | both
  | neither
  deriving DecidableEq, Repr

namespace Belnap

/-- Paraconsistent negation: swaps `true`/`false`, fixes the impossible objects. -/
def neg : Belnap → Belnap
  | true => false
  | false => true
  | both => both
  | neither => neither

/-- Conjunction = meet in the truth order `false < {both, neither} < true`. -/
def conj : Belnap → Belnap → Belnap
  | false, _ => false
  | _, false => false
  | true, y => y
  | x, true => x
  | both, both => both
  | neither, neither => neither
  | both, neither => false
  | neither, both => false

/-- Disjunction = join in the truth order. -/
def disj : Belnap → Belnap → Belnap
  | true, _ => true
  | _, true => true
  | false, y => y
  | x, false => x
  | both, both => both
  | neither, neither => neither
  | both, neither => true
  | neither, both => true

/-- A value is *designated* (asserted / believed) when it is `true` or `both`. -/
def designated : Belnap → Prop
  | true => True
  | both => True
  | _ => False

instance : DecidablePred designated := by
  intro x; cases x <;> unfold designated <;> infer_instance

@[simp] theorem designated_true : designated true := trivial
@[simp] theorem designated_both : designated both := trivial
@[simp] theorem not_designated_false : ¬ designated false := id
@[simp] theorem not_designated_neither : ¬ designated neither := id

/-! ### De Morgan / lattice structure -/

theorem neg_neg (x : Belnap) : neg (neg x) = x := by cases x <;> rfl

theorem conj_comm (x y : Belnap) : conj x y = conj y x := by
  cases x <;> cases y <;> rfl

theorem disj_comm (x y : Belnap) : disj x y = disj y x := by
  cases x <;> cases y <;> rfl

theorem conj_assoc (x y z : Belnap) :
    conj (conj x y) z = conj x (conj y z) := by
  cases x <;> cases y <;> cases z <;> rfl

theorem disj_assoc (x y z : Belnap) :
    disj (disj x y) z = disj x (disj y z) := by
  cases x <;> cases y <;> cases z <;> rfl

theorem conj_idem (x : Belnap) : conj x x = x := by cases x <;> rfl
theorem disj_idem (x : Belnap) : disj x x = x := by cases x <;> rfl

theorem absorb_conj (x y : Belnap) : conj x (disj x y) = x := by
  cases x <;> cases y <;> rfl

theorem absorb_disj (x y : Belnap) : disj x (conj x y) = x := by
  cases x <;> cases y <;> rfl

/-- De Morgan law: negation is a lattice anti-isomorphism (conj/disj duality). -/
theorem demorgan_conj (x y : Belnap) :
    neg (conj x y) = disj (neg x) (neg y) := by
  cases x <;> cases y <;> rfl

theorem demorgan_disj (x y : Belnap) :
    neg (disj x y) = conj (neg x) (neg y) := by
  cases x <;> cases y <;> rfl

/-! ### Paraconsistency: contradictions coexist without explosion -/

/-- **Glut characterization.**  The conjunction of a value with its own
negation is designated *iff* the value is `both`: `both` is the unique
"impossible object" — a proposition that genuinely holds *and* fails. -/
theorem glut_iff (x : Belnap) : designated (conj x (neg x)) ↔ x = both := by
  cases x <;> simp [conj, neg, designated]

/-- **Gap characterization.**  The disjunction of a value with its own negation
fails to be designated *iff* the value is `neither`: `neither` is the unique
gap value, modelling a *retracted* belief. -/
theorem gap_iff (x : Belnap) : ¬ designated (disj x (neg x)) ↔ x = neither := by
  cases x <;> simp [disj, neg, designated]

/-- **The Law of Non-Contradiction can fail.**  There is a value whose
contradiction with itself is accepted — contradictions coexist. -/
theorem lnc_can_fail : ∃ x : Belnap, designated (conj x (neg x)) :=
  ⟨both, trivial⟩

/-- **The Law of Excluded Middle can fail.**  There is a value for which neither
it nor its negation is forced — beliefs can be suspended / retracted. -/
theorem lem_can_fail : ∃ x : Belnap, ¬ designated (disj x (neg x)) :=
  ⟨neither, id⟩

/-- **Explosion fails (the heart of paraconsistency).**  It is *not* the case
that an accepted contradiction entails every proposition: the glut `both`
contradicts itself yet does not make the non-designated `false` designated. -/
theorem explosion_fails :
    ¬ ∀ x y : Belnap, designated (conj x (neg x)) → designated y := by
  intro h
  exact h both false trivial

/-! ### Classical contrast — explosion is a feature of `FOUR`, not of Lean -/

/-- In classical (Boolean) logic there are no gluts. -/
theorem classical_no_glut (b : Bool) : ¬ (b && !b) := by cases b <;> simp

/-- In classical logic, a contradiction *does* explode. -/
theorem classical_explosion (b q : Bool) : (b && !b) → q := by
  cases b <;> simp

end Belnap
end DreamLogic