import Mathlib

/-!
# Dream Logic: Paraconsistent Reasoning where Contradictions Coexist

This file formalizes a paraconsistent propositional logic — Priest's *Logic of Paradox*
(`LP`) — and uses it as a model of "dream-like" reasoning, in which impossible objects
(true *and* false at once) can coexist without the system collapsing into triviality.

The truth-value space is the three-element set `{ff, bb, tt}`:

* `tt` — true only,
* `ff` — false only,
* `bb` — *both* true and false (a "glut" / an impossible object that coexists in a dream).

A value is **designated** (assertible, "holds in the dream") iff it is `bb` or `tt`.

## Main results

* `explosion_fails` — from `{p, ¬p}` one cannot derive an arbitrary `q`: contradictions do
  **not** explode (paraconsistency).
* `contradiction_satisfiable` — a contradiction `p ∧ ¬p` can be designated: impossible objects
  coexist.
* `lem_valid` / `lnc_valid` — excluded middle and *non-contradiction* remain logical laws, yet
  explosion still fails. This pins down exactly how `LP` departs from classical logic: it keeps
  the *theorems* of classical logic but rejects the *inference* of explosion.
* `mp_fails` — material modus ponens fails, the price of paraconsistency.
* `classical_no_contradiction` — glut-free dreams reason classically: with no impossible objects
  present, no contradiction is assertible (a bridge back to classical consistency).
* `retraction_nonmonotone` — the *minimal-glut* consequence relation `entailsMin` (Priest's
  `LPm`) is genuinely **non-monotone**: `q` follows from `{p, p → q}` but is **retracted** once
  the contradictory belief `¬p` is added. This is dream logic where adding information can
  withdraw a prior conclusion.
-/

namespace DreamLogic

/-- The three truth values of the Logic of Paradox. `bb` is the "glut": an impossible object
that is true and false simultaneously. -/
inductive LP where
  | ff | bb | tt
deriving DecidableEq, Repr

namespace LP

/-- Negation: swaps `tt`/`ff`, and fixes the glut `bb` (an impossible object stays impossible
under negation). -/
def neg : LP → LP
  | ff => tt
  | bb => bb
  | tt => ff

/-- Conjunction = `min` under the order `ff < bb < tt`. -/
def conj : LP → LP → LP
  | ff, _ => ff
  | _, ff => ff
  | bb, _ => bb
  | _, bb => bb
  | tt, tt => tt

/-- Disjunction = `max` under the order `ff < bb < tt`. -/
def disj : LP → LP → LP
  | tt, _ => tt
  | _, tt => tt
  | bb, _ => bb
  | _, bb => bb
  | ff, ff => ff

/-- A value is *designated* (assertible) iff it carries truth, i.e. it is `bb` or `tt`. -/
def desig : LP → Bool
  | ff => false
  | bb => true
  | tt => true

end LP

/-- Propositional formulas over natural-number atoms. -/
inductive Form where
  | atom : ℕ → Form
  | neg : Form → Form
  | conj : Form → Form → Form
  | disj : Form → Form → Form

/-- Material implication, defined classically as `¬a ∨ b`. -/
def Form.impl (a b : Form) : Form := Form.disj (Form.neg a) b

/-- Evaluation of a formula under a valuation `v` of the atoms. -/
def eval (v : ℕ → LP) : Form → LP
  | Form.atom n => v n
  | Form.neg a => LP.neg (eval v a)
  | Form.conj a b => LP.conj (eval v a) (eval v b)
  | Form.disj a b => LP.disj (eval v a) (eval v b)

/-- `A` *holds* (is assertible) under `v` iff its value is designated. -/
def Holds (v : ℕ → LP) (A : Form) : Prop := LP.desig (eval v A) = true

/-- Semantic (Tarskian) consequence: every valuation making all of `Γ` hold makes `A` hold. -/
def entails (Γ : Set Form) (A : Form) : Prop :=
  ∀ v, (∀ B ∈ Γ, Holds v B) → Holds v A

/-- The set of atoms assigned the glut value `bb` by `v` — the "impossible objects" present. -/
def gluts (v : ℕ → LP) : Set ℕ := {n | v n = LP.bb}

/-- `v` is a model of `Γ` iff every formula of `Γ` holds under `v`. -/
def model (v : ℕ → LP) (Γ : Set Form) : Prop := ∀ B ∈ Γ, Holds v B

/-- A model is *minimal* iff no other model has a strictly smaller set of gluts. This is the
"minimally inconsistent" semantics: tolerate only as many impossible objects as forced. -/
def minimal (v : ℕ → LP) (Γ : Set Form) : Prop :=
  model v Γ ∧ ∀ v', model v' Γ → ¬ (gluts v' ⊂ gluts v)

/-- Minimal-glut consequence (`LPm`): `A` holds in every *minimal* model of `Γ`. This relation
is non-monotone — see `retraction_nonmonotone`. -/
def entailsMin (Γ : Set Form) (A : Form) : Prop :=
  ∀ v, minimal v Γ → Holds v A

/-
!-- Witness the glut valuation `0 ↦ bb, 1 ↦ ff`: both `p` and `¬p` are designated while `q`
is not, so `{p, ¬p} ⊭ q`; contradictions do not explode. -- !--
-/
theorem explosion_fails : ¬ entails {Form.atom 0, Form.neg (Form.atom 0)} (Form.atom 1) := by
  simp +decide [ entails ];
  exists fun n => if n = 0 then LP.bb else LP.ff;
  simp +decide [ Holds ]

/-
!-- Assign the glut `bb` to atom `0`; then `p ∧ ¬p` evaluates to `bb`, which is designated:
an impossible object coexists. -- !--
-/
theorem contradiction_satisfiable :
    ∃ v, Holds v (Form.conj (Form.atom 0) (Form.neg (Form.atom 0))) := by
  exists fun _ => LP.bb

/-
!-- Case-split on the value of `A`: in each of `ff, bb, tt` the disjunction `A ∨ ¬A` is
designated, so excluded middle is a law. -- !--
-/
theorem lem_valid (A : Form) (v : ℕ → LP) : Holds v (Form.disj A (Form.neg A)) := by
  -- By definition of disjunction in LP, we consider the following cases:
  have h_cases : ∀ (a : LP), LP.desig (LP.disj a (LP.neg a)) = true := by
    rintro ( _ | _ | _ ) <;> trivial;
  exact h_cases (eval v A)

/-
!-- Case-split on the value of `A`: `¬(A ∧ ¬A)` is designated in every case, so
non-contradiction is a law — even though explosion still fails. -- !--
-/
theorem lnc_valid (A : Form) (v : ℕ → LP) : Holds v (Form.neg (Form.conj A (Form.neg A))) := by
  -- Case-split on the value of `eval v A`: in each of `ff, bb, tt`, the result is designated.
  have h_cases : ∀ (x : LP), LP.desig (LP.neg (LP.conj x (LP.neg x))) = true := by
    exact fun x => by cases x <;> rfl;
  convert h_cases ( eval v A ) using 1

/-
!-- `LP.neg` is an involution on the three values, so double negation is value-preserving. -- !--
-/
theorem double_negation (v : ℕ → LP) (A : Form) :
    eval v (Form.neg (Form.neg A)) = eval v A := by
  -- By definition of `eval`, we have `eval v (Form.neg (Form.neg A)) = LP.neg (LP.neg (eval v A))`.
  have h_eval_neg_neg : eval v (Form.neg (Form.neg A)) = LP.neg (LP.neg (eval v A)) := by
    rfl;
  cases h : eval v A <;> aesop

/-
!-- Glut valuation `0 ↦ bb, 1 ↦ ff`: `p` and `p → q = ¬p ∨ q` are designated but `q` is not,
so material modus ponens fails. -- !--
-/
theorem mp_fails :
    ¬ entails {Form.atom 0, Form.impl (Form.atom 0) (Form.atom 1)} (Form.atom 1) := by
  -- Use the definition of `entails`.
  unfold entails;
  -- Unfold the definition of `Holds` for the given valuation.
  simp +decide [Holds];
  exists fun n => if n = 0 then LP.bb else LP.ff

/-
!-- If `v` assigns only classical values then `eval v A ∈ {tt, ff}` (induction on `A`), and a
value and its negation cannot both be designated; so glut-free dreams stay consistent. -- !--
-/
theorem classical_no_contradiction (v : ℕ → LP) (A : Form)
    (hc : ∀ n, v n = LP.tt ∨ v n = LP.ff) : ¬ (Holds v A ∧ Holds v (Form.neg A)) := by
  -- By induction on A, we can show that if v is classical, then eval v A is either tt or ff.
  have h_eval_cases : ∀ A : Form, (∀ n, v n = LP.tt ∨ v n = LP.ff) → (eval v A = LP.tt ∨ eval v A = LP.ff) := by
    intro A hA; induction A <;> simp_all +decide ;
    · exact hA _;
    · cases ‹eval v _ = LP.tt ∨ eval v _ = LP.ff› <;> simp_all +decide [ eval ];
    · rename_i A B hA hB;
      cases hA <;> cases hB <;> simp +decide [ *, eval ];
    · rename_i A B hA hB;
      cases hA <;> cases hB <;> simp +decide [ *, eval ];
  cases h_eval_cases A hc <;> simp +decide [ *, Holds ];
  rw [ show eval v A.neg = LP.neg ( eval v A ) from rfl ] ; simp +decide [ *, LP.neg ]

/-
!-- Non-monotonicity / belief retraction. For `entailsMin` (minimal-glut `LPm`): the all-`tt`
valuation is a glut-free model of `{p, p→q}`, so every minimal model is glut-free hence
classical, forcing `q`. But every model of `{p, ¬p, p→q}` must set `p = bb`, so the minimal
model `0 ↦ bb, 1 ↦ ff` (gluts `{0}`, minimal since `0` is forced) makes `q` false: adding the
contradictory `¬p` retracts the conclusion `q`. -- !--
-/
theorem retraction_nonmonotone :
    entailsMin {Form.atom 0, Form.impl (Form.atom 0) (Form.atom 1)} (Form.atom 1) ∧
    ¬ entailsMin {Form.atom 0, Form.neg (Form.atom 0), Form.impl (Form.atom 0) (Form.atom 1)}
        (Form.atom 1) := by
  constructor;
  · intro v hv;
    obtain ⟨ hv₁, hv₂ ⟩ := hv;
    contrapose! hv₂;
    use fun _ => LP.tt; simp_all +decide [ model, gluts ] ;
    unfold Holds at *; simp_all +decide [ Form.impl ] ;
    cases h : v 0 <;> cases h' : v 1 <;> simp_all +decide [ eval ];
    exact ⟨ 0, h ⟩;
  · unfold entailsMin; simp +decide ;
    use fun n => if n = 0 then LP.bb else LP.ff; simp +decide [ minimal, Holds ] ;
    unfold model gluts; simp +decide [ Set.ssubset_def ] ;
    unfold Holds; simp +decide [ Form.impl ] ;
    intro v' hv'₁ hv'₂ hv'₃ hv'₄; rcases h : v' 0 with ( _ | _ | _ ) <;> simp_all +decide [ eval ] ;

/-- Explosion fails: a worked instance. -/
example : ¬ entails {Form.atom 0, Form.neg (Form.atom 0)} (Form.atom 1) := explosion_fails

end DreamLogic