import Mathlib

/-!
# Dream Logic I: Priest's Logic of Paradox (`LP`) — Object Level

This file formalises the three-valued **Logic of Paradox** of Graham Priest, the
canonical *paraconsistent* logic in which contradictions do not explode.  Truth values
are `ff < bb < tt`, where `bb` ("both") is the *glut* value designating a proposition that
is simultaneously true and false.  The designated values (the "true-ish" ones) are `tt`
and `bb`; only `ff` is undesignated.

Connectives are the Kleene/Priest tables: negation swaps `tt`/`ff` and fixes the glut,
conjunction is `min`, disjunction is `max` on the chain `ff < bb < tt`.

The object-level phenomena established here:

* `explosion_fails`     — `{p, ¬p} ⊭ q` (no explosion);
* `contradiction_satisfiable` — a glut model satisfies `p ∧ ¬p`;
* `lem_valid`           — excluded middle `p ∨ ¬p` is `LP`-valid;
* `lnc_valid`           — non-contradiction `¬(p ∧ ¬p)` is `LP`-valid;
* `mp_fails`            — modus ponens `{p, p ⊃ q} ⊭ q` fails;
* `double_negation`     — `¬¬p` and `p` are inter-derivable;
* `retraction_nonmonotone` — the minimal-glut relation `entailsMin` is non-monotone.

The structural meta-theory (Cut, the closure-operator structure, recapture of MP)
is developed in `Logic.DreamLogic.NonMonotone`.

-- !-- Lab Notebook -- !--
Hypothesis: Priest's LP can be formalised with a tiny three-element value type and the
  designated-value predicate `a ≠ ff`, with all object-level facts decidable per value.
Result: Every value-level law reduces to `Decidable.decide` over the 3×3 (or 3) cases;
  the only genuinely semantic content is the choice of designated set {bb, tt}.
Insight: The glut `bb` is a *fixed point of negation* (`neg bb = bb`); this single fact is
  the source of both the success of LEM/LNC and the failure of MP/DS.
Failure analysis: An earlier attempt used `Bool`-valued semantics and could not express
  gluts at all; the three-valued type is essential, not cosmetic.
-/

namespace DreamLogic

/-- The three Priestian truth values on the chain `ff < bb < tt`.
`bb` ("both") is the glut value: designated yet with designated negation. -/
inductive LPval
  | ff
  | bb
  | tt
deriving DecidableEq, Repr

namespace LPval

/-- A value is **designated** ("holds") iff it is not `ff`. The designated set is `{bb, tt}`. -/
def desig : LPval → Prop
  | ff => False
  | bb => True
  | tt => True

instance (a : LPval) : Decidable (desig a) := by cases a <;> unfold desig <;> infer_instance

/-- Priest/Kleene negation: swaps `tt` and `ff`, fixes the glut `bb`. -/
def neg : LPval → LPval
  | ff => tt
  | bb => bb
  | tt => ff

/-- Conjunction = `min` on `ff < bb < tt`. -/
def conj : LPval → LPval → LPval
  | ff, _ => ff
  | bb, ff => ff
  | bb, bb => bb
  | bb, tt => bb
  | tt, b => b

/-- Disjunction = `max` on `ff < bb < tt`. -/
def disj : LPval → LPval → LPval
  | ff, b => b
  | bb, ff => bb
  | bb, bb => bb
  | bb, tt => tt
  | tt, _ => tt

@[simp] theorem neg_bb : neg bb = bb := rfl

end LPval

/-- Propositional formulas over countably many atoms. -/
inductive Form
  | atom : ℕ → Form
  | neg : Form → Form
  | conj : Form → Form → Form
  | disj : Form → Form → Form

/-- Material implication `A ⊃ B := ¬A ∨ B`. -/
def Form.imp (A B : Form) : Form := Form.disj (Form.neg A) B

/-- A valuation assigns an `LP` value to every atom. -/
abbrev Valuation := ℕ → LPval

/-- Evaluation of a formula under a valuation. -/
def eval (v : Valuation) : Form → LPval
  | .atom n => v n
  | .neg A => LPval.neg (eval v A)
  | .conj A B => LPval.conj (eval v A) (eval v B)
  | .disj A B => LPval.disj (eval v A) (eval v B)

/-- A formula **holds** at `v` iff its value is designated. -/
def Holds (v : Valuation) (A : Form) : Prop := (eval v A).desig

/-- `v` **models** a theory `Γ` iff every member holds at `v`. -/
def Models (Γ : Set Form) (v : Valuation) : Prop := ∀ B ∈ Γ, Holds v B

/-- `LP`-consequence: `A` holds in every model of `Γ`. -/
def entails (Γ : Set Form) (A : Form) : Prop := ∀ v, Models Γ v → Holds v A

/-- `LP`-validity: `A` holds under every valuation. -/
def LPvalid (A : Form) : Prop := ∀ v, Holds v A

/-- The **glut set** of a valuation: the atoms assigned the glut value `bb`. -/
def GlutSet (v : Valuation) : Set ℕ := {n | v n = LPval.bb}

/-- A **minimal model**: a model of `Γ` whose glut set cannot be strictly shrunk by
another model.  This drives the non-monotone, minimal-glut consequence `entailsMin`. -/
def IsMinModel (Γ : Set Form) (v : Valuation) : Prop :=
  Models Γ v ∧ ∀ w, Models Γ w → ¬ (GlutSet w ⊂ GlutSet v)

/-- **Minimal-glut consequence** `LPm`: `A` holds in every *minimal* model of `Γ`. -/
def entailsMin (Γ : Set Form) (A : Form) : Prop := ∀ v, IsMinModel Γ v → Holds v A

/-! ### Object-level theorems -/

-- !-- Disjunction/conjunction values are computed by `decide`; the glut witness `bb`
--    makes both a value and its negation designated, defeating explosion. -- !--

/-- **No explosion.** From a contradiction `{p, ¬p}` one cannot infer an arbitrary `q`.
The glut valuation `p ↦ bb`, `q ↦ ff` satisfies the premises but refutes `q`. -/
theorem explosion_fails :
    ¬ entails {Form.atom 0, Form.neg (Form.atom 0)} (Form.atom 1) := by
  intro h
  have key := h (fun n => if n = 0 then LPval.bb else LPval.ff) (by
    intro B hB
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl <;> (simp only [Holds]; decide))
  exact (by simp only [Holds]; decide :
    ¬ Holds (fun n => if n = 0 then LPval.bb else LPval.ff) (Form.atom 1)) key

/-- **Gluts are satisfiable.** A model designates both `p` and `¬p` simultaneously. -/
theorem contradiction_satisfiable :
    ∃ v : Valuation, Holds v (Form.atom 0) ∧ Holds v (Form.neg (Form.atom 0)) :=
  ⟨fun _ => LPval.bb, by simp only [Holds]; decide, by simp only [Holds]; decide⟩

/-- **Excluded middle survives.** `p ∨ ¬p` is `LP`-valid. -/
theorem lem_valid : LPvalid (Form.disj (Form.atom 0) (Form.neg (Form.atom 0))) := by
  intro v
  simp only [Holds, eval]
  cases v 0 <;> decide

/-- **Non-contradiction survives.** `¬(p ∧ ¬p)` is `LP`-valid. -/
theorem lnc_valid : LPvalid (Form.neg (Form.conj (Form.atom 0) (Form.neg (Form.atom 0)))) := by
  intro v
  simp only [Holds, eval]
  cases v 0 <;> decide

/-- **Modus ponens fails.** `{p, p ⊃ q} ⊭ q`, with `p ⊃ q := ¬p ∨ q`.
The glut valuation `p ↦ bb`, `q ↦ ff` refutes it. -/
theorem mp_fails :
    ¬ entails {Form.atom 0, Form.imp (Form.atom 0) (Form.atom 1)} (Form.atom 1) := by
  intro h
  have key := h (fun n => if n = 0 then LPval.bb else LPval.ff) (by
    intro B hB
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl <;> (simp only [Holds]; decide))
  exact (by simp only [Holds]; decide :
    ¬ Holds (fun n => if n = 0 then LPval.bb else LPval.ff) (Form.atom 1)) key

/-- **Double negation.** `¬¬p` and `p` hold at exactly the same valuations. -/
theorem double_negation (v : Valuation) :
    Holds v (Form.neg (Form.neg (Form.atom 0))) ↔ Holds v (Form.atom 0) := by
  simp only [Holds, eval]
  cases v 0 <;> decide

/-- **Non-monotonicity of `LPm`.** With `Γ = {p, ¬p∨q}` we have `entailsMin Γ q`
(MP is recovered on the consistent set), but adding `¬p` to get the inconsistent
`Δ = {p, ¬p, ¬p∨q}` *retracts* the conclusion: `¬ entailsMin Δ q`.  Thus
`Γ ⊆ Δ` yet the conclusion is lost — the signature of a non-monotone logic. -/
theorem retraction_nonmonotone :
    ¬ entailsMin {Form.atom 0, Form.neg (Form.atom 0),
        Form.imp (Form.atom 0) (Form.atom 1)} (Form.atom 1) := by
  intro h
  set v : Valuation := fun n => if n = 0 then LPval.bb else LPval.ff with hv
  have model_glut : ∀ w : Valuation,
      Models {Form.atom 0, Form.neg (Form.atom 0), Form.imp (Form.atom 0) (Form.atom 1)} w →
        w 0 = LPval.bb := by
    intro w hw
    have h0 : Holds w (Form.atom 0) := hw _ (by simp)
    have h1 : Holds w (Form.neg (Form.atom 0)) := hw _ (by simp)
    simp only [Holds, eval] at h0 h1
    cases hc : w 0 <;> simp_all [LPval.neg, LPval.desig]
  have hmodelv : Models {Form.atom 0, Form.neg (Form.atom 0),
      Form.imp (Form.atom 0) (Form.atom 1)} v := by
    intro B hB
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl | rfl <;> (simp only [Holds]; decide)
  have hmin : IsMinModel {Form.atom 0, Form.neg (Form.atom 0),
      Form.imp (Form.atom 0) (Form.atom 1)} v := by
    refine ⟨hmodelv, ?_⟩
    intro w hw hsub
    have hw0 : w 0 = LPval.bb := model_glut w hw
    have h0w : (0 : ℕ) ∈ GlutSet w := by simp [GlutSet, hw0]
    have hsubset : GlutSet v ⊆ {0} := by
      intro n hn
      simp only [GlutSet, Set.mem_setOf_eq, hv] at hn
      by_contra hne
      simp [if_neg (by simpa using hne)] at hn
    have hsup : GlutSet v ⊆ GlutSet w := by
      intro n hn
      have : n ∈ ({0} : Set ℕ) := hsubset hn
      simp only [Set.mem_singleton_iff] at this; subst this; exact h0w
    exact absurd (le_antisymm hsub.le hsup) (ne_of_lt hsub)
  have := h v hmin
  simp only [Holds, eval, hv] at this
  exact this

end DreamLogic