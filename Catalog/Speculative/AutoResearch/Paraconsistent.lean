/-
# Paraconsistent.lean — A verified semantics for Priest's Logic of Paradox (LP)
  and its minimally-inconsistent strengthening (LPm), with a cross-domain bridge
  to idempotent (tropical-style) semiring algebra.

This file builds, from scratch, a machine-checked model theory for the three-valued
**Logic of Paradox** `LP` (Priest 1979).  The three values are

* `ff` — false only,
* `bb` — *both* true and false (a "glut", an impossible object), and
* `tt` — true only,

with designated set `{bb, tt}` (the values that count as "true enough").  We verify the
characteristic paraconsistent behaviour: contradictions are satisfiable and do **not**
explode, the laws of excluded middle and non-contradiction survive as *validities*, while
the *inferences* of explosion and material modus ponens fail.  Glut-free valuations collapse
to classical reasoning.

The centrepiece is the minimally-inconsistent consequence relation `entailsMin` (Priest's
`LPm`), which minimises the set of gluts a model is forced to carry.  We prove it is genuinely
**non-monotone**: the conclusion `q`, derivable from `{p, p → q}`, is *retracted* once the
contradictory premise `¬p` is added.

Finally — the cross-domain payload — we prove that `(LP, disj, conj)` is a commutative
*idempotent* semiring with `disj = max`, `conj = min` on the chain `ff < bb < tt`, exhibiting
the LP truth tables as a genuine two-spaced tropical / min-plus structure, and that the
designated filter `{bb, tt}` is a prime filter for both operations.

All results below are proved with `sorry`-free proofs; the only axioms used are
`propext`, `Classical.choice`, and `Quot.sound`.
-/
import Mathlib

namespace Paraconsistent

/-! ## The three truth values -/

/-- The three truth values of Priest's Logic of Paradox:
`ff` (false only), `bb` (both / a glut), `tt` (true only). -/
inductive LP where
  | ff
  | bb
  | tt
deriving DecidableEq, Repr, Fintype

namespace LP

/-- A value is *designated* (counts as assertible) iff it is not `ff`. -/
def desig : LP → Prop
  | ff => False
  | _  => True

instance (v : LP) : Decidable (desig v) := by cases v <;> (unfold desig) <;> infer_instance

/-- LP negation: it fixes the glut `bb` (an impossible object stays impossible). -/
def neg : LP → LP
  | ff => tt
  | bb => bb
  | tt => ff

/-- LP conjunction = `min` on the chain `ff < bb < tt`. -/
def conj : LP → LP → LP
  | ff, _ => ff
  | _, ff => ff
  | bb, _ => bb
  | _, bb => bb
  | tt, tt => tt

/-- LP disjunction = `max` on the chain `ff < bb < tt`. -/
def disj : LP → LP → LP
  | tt, _ => tt
  | _, tt => tt
  | bb, _ => bb
  | _, bb => bb
  | ff, ff => ff

/-! ### Value-level facts (finite truth-table verification) -/

-- !-- A designated value is exactly a non-`ff` value. -- !--
theorem desig_iff (x : LP) : desig x ↔ x ≠ ff := by cases x <;> decide

-- !-- `ff` is the bottom of `disj` (it is the additive identity / `max`-zero). -- !--
theorem disj_ff_left (x : LP) : disj ff x = x := by cases x <;> rfl

-- !-- The only value that is designated together with its negation is the glut `bb`;
-- this is the algebraic engine behind both `mp_fails` and the forced gluts of `LPm`. -- !--
theorem desig_neg_forces_bb (x : LP) : desig x → desig (neg x) → x = bb := by
  cases x <;> decide

-- !-- A non-glut designated value is `tt`; this drives the classical collapse. -- !--
theorem ne_bb_desig_eq_tt (x : LP) : x ≠ bb → desig x → x = tt := by cases x <;> decide

/-! ## Syntax and evaluation -/

/-- Propositional formulas over `ℕ`-indexed atoms. -/
inductive Form where
  | atom : ℕ → Form
  | neg  : Form → Form
  | conj : Form → Form → Form
  | disj : Form → Form → Form
deriving DecidableEq

/-- Material implication is defined, as usual in LP, by `p → q := ¬p ∨ q`. -/
def Form.impl (p q : Form) : Form := Form.disj (Form.neg p) q

/-- Three-valued evaluation of a formula under a valuation of the atoms. -/
def eval (v : ℕ → LP) : Form → LP
  | Form.atom n   => v n
  | Form.neg p    => neg (eval v p)
  | Form.conj p q => conj (eval v p) (eval v q)
  | Form.disj p q => disj (eval v p) (eval v q)

@[simp] theorem eval_atom (v : ℕ → LP) (n : ℕ) : eval v (Form.atom n) = v n := rfl
@[simp] theorem eval_neg (v : ℕ → LP) (p : Form) : eval v (Form.neg p) = neg (eval v p) := rfl
@[simp] theorem eval_conj (v : ℕ → LP) (p q : Form) :
    eval v (Form.conj p q) = conj (eval v p) (eval v q) := rfl
@[simp] theorem eval_disj (v : ℕ → LP) (p q : Form) :
    eval v (Form.disj p q) = disj (eval v p) (eval v q) := rfl
@[simp] theorem eval_impl (v : ℕ → LP) (p q : Form) :
    eval v (Form.impl p q) = disj (neg (eval v p)) (eval v q) := rfl

/-! ## Core LP phenomena -/

-- !-- Excluded middle survives as a *validity*: `p ∨ ¬p` is designated everywhere, by
-- a three-way case split on the value of `p`. -- !--
/-- **Law of Excluded Middle is LP-valid.** -/
theorem lem_valid (v : ℕ → LP) (p : Form) : desig (eval v (Form.disj p (Form.neg p))) := by
  simp only [eval_disj, eval_neg]
  cases eval v p <;> decide

-- !-- Non-contradiction survives as a *validity*: `¬(p ∧ ¬p)` is designated everywhere. -- !--
/-- **Law of Non-Contradiction is LP-valid** (yet contradictions are still satisfiable). -/
theorem lnc_valid (v : ℕ → LP) (p : Form) :
    desig (eval v (Form.neg (Form.conj p (Form.neg p)))) := by
  simp only [eval_neg, eval_conj]
  cases eval v p <;> decide

-- !-- A contradiction `p ∧ ¬p` is satisfiable: at a glut valuation it takes the
-- designated value `bb`. -- !--
/-- **Contradictions are satisfiable.** -/
theorem contradiction_satisfiable :
    ∃ (v : ℕ → LP) (p : Form), desig (eval v (Form.conj p (Form.neg p))) :=
  ⟨fun _ => bb, Form.atom 0, by decide⟩

-- !-- Explosion fails: at the valuation `atom 0 ↦ bb, atom 1 ↦ ff` both `p` and `¬p`
-- are designated while `q` is not, so `p, ¬p ⊬ q`. -- !--
/-- **Ex contradictione quodlibet fails** (LP is paraconsistent). -/
theorem explosion_fails :
    ∃ (v : ℕ → LP) (p q : Form),
      desig (eval v p) ∧ desig (eval v (Form.neg p)) ∧ ¬ desig (eval v q) :=
  ⟨fun n => if n = 0 then bb else ff, Form.atom 0, Form.atom 1, by decide, by decide, by decide⟩

-- !-- Material modus ponens fails: with `p ↦ bb, q ↦ ff` both `p` and `p → q` are
-- designated but `q` is not. -- !--
/-- **Material modus ponens fails** in LP. -/
theorem mp_fails :
    ∃ (v : ℕ → LP) (p q : Form),
      desig (eval v p) ∧ desig (eval v (Form.impl p q)) ∧ ¬ desig (eval v q) :=
  ⟨fun n => if n = 0 then bb else ff, Form.atom 0, Form.atom 1, by decide, by decide, by decide⟩

/-! ### Glut-free valuations are classical -/

-- !-- No connective can manufacture a glut from glut-free inputs, so by structural
-- induction a glut-free valuation never evaluates any formula to `bb`. -- !--
/-- Over a glut-free valuation, evaluation never produces the glut `bb`. -/
theorem eval_ne_bb {v : ℕ → LP} (hv : ∀ n, v n ≠ bb) : ∀ A : Form, eval v A ≠ bb := by
  intro A
  induction A with
  | atom n => exact hv n
  | neg p ih =>
      simp only [eval_neg]
      revert ih; cases eval v p <;> decide
  | conj p q ihp ihq =>
      simp only [eval_conj]
      revert ihp ihq; cases eval v p <;> cases eval v q <;> decide
  | disj p q ihp ihq =>
      simp only [eval_disj]
      revert ihp ihq; cases eval v p <;> cases eval v q <;> decide

-- !-- Consequently, over a glut-free ("non-dreaming") valuation no formula and its
-- negation are simultaneously designated: classical consistency is restored. -- !--
/-- **Glut-free valuations reason classically:** no formula is a contradiction. -/
theorem classical_no_contradiction {v : ℕ → LP} (hv : ∀ n, v n ≠ bb) (A : Form) :
    ¬ (desig (eval v A) ∧ desig (eval v (Form.neg A))) := by
  have h := eval_ne_bb hv A
  simp only [eval_neg]
  revert h; cases eval v A <;> decide

/-! ## Consequence relations: classical-style `entails` and minimal `entailsMin` (LPm) -/

/-- A valuation is a *model* of a premise set if it designates every premise. -/
def isModel (Γ : Set Form) (v : ℕ → LP) : Prop := ∀ B ∈ Γ, desig (eval v B)

/-- The *glut set* of a valuation: the atoms it sends to the impossible value `bb`. -/
def gluts (v : ℕ → LP) : Set ℕ := {n | v n = bb}

/-- **LP consequence** (designation-preservation over all models). -/
def entails (Γ : Set Form) (A : Form) : Prop :=
  ∀ v : ℕ → LP, isModel Γ v → desig (eval v A)

/-- A model is *minimally inconsistent* if no model carries a strictly smaller glut set. -/
def minimalModel (Γ : Set Form) (v : ℕ → LP) : Prop :=
  isModel Γ v ∧ ∀ w, isModel Γ w → ¬ (gluts w ⊂ gluts v)

/-- **LPm consequence** (Priest's minimally-inconsistent logic): designation-preservation
over *minimal* models only. -/
def entailsMin (Γ : Set Form) (A : Form) : Prop :=
  ∀ v : ℕ → LP, minimalModel Γ v → desig (eval v A)

/-! ### The retraction example: `p = atom 0`, `q = atom 1`. -/

/-- The premise atom. -/
def p : Form := Form.atom 0
/-- The conclusion atom. -/
def q : Form := Form.atom 1

/-- `Γ₁ = {p, p → q}`. -/
def Γ₁ : Set Form := {p, p.impl q}
/-- `Γ₂ = {p, p → q, ¬p}` extends `Γ₁` with the contradictory belief `¬p`. -/
def Γ₂ : Set Form := {p, p.impl q, p.neg}

theorem isModel_Γ₁ (v : ℕ → LP) :
    isModel Γ₁ v ↔ desig (eval v p) ∧ desig (eval v (p.impl q)) := by
  constructor
  · intro h; exact ⟨h p (by simp [Γ₁]), h _ (by simp [Γ₁])⟩
  · rintro ⟨h1, h2⟩ B hB
    simp only [Γ₁, Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl
    · exact h1
    · exact h2

theorem isModel_Γ₂ (v : ℕ → LP) :
    isModel Γ₂ v ↔
      desig (eval v p) ∧ desig (eval v (p.impl q)) ∧ desig (eval v p.neg) := by
  constructor
  · intro h; exact ⟨h p (by simp [Γ₂]), h _ (by simp [Γ₂]), h _ (by simp [Γ₂])⟩
  · rintro ⟨h1, h2, h3⟩ B hB
    simp only [Γ₂, Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl | rfl
    · exact h1
    · exact h2
    · exact h3

/-- The all-`tt` valuation is a glut-free model of `Γ₁`. -/
theorem isModel_top_Γ₁ : isModel Γ₁ (fun _ => tt) := by
  rw [isModel_Γ₁]; constructor <;> simp [p, q, Form.impl] <;> decide

theorem gluts_top : gluts (fun _ : ℕ => tt) = ∅ := by
  ext n; simp [gluts]

-- !-- A minimal model of `Γ₁` must be glut-free: the all-`tt` model has empty glut set,
-- which would strictly undercut any nonempty glut set. -- !--
theorem minimal_Γ₁_glutfree {w : ℕ → LP} (hw : minimalModel Γ₁ w) :
    ∀ n, w n ≠ bb := by
  have hempty : gluts w = ∅ := by
    by_contra h
    have hne : (gluts w).Nonempty := Set.nonempty_iff_ne_empty.mpr h
    have hss : gluts (fun _ : ℕ => tt) ⊂ gluts w := by
      rw [gluts_top]; exact Set.empty_ssubset.mpr hne
    exact hw.2 _ isModel_top_Γ₁ hss
  intro n hn
  have : n ∈ gluts w := hn
  rw [hempty] at this
  exact this

-- !-- From a glut-free model of `Γ₁`: `p` designated and non-glut forces `p = tt`, which
-- makes the implication collapse to `q`, forcing `q = tt`; hence `q` is designated. -- !--
/-- **`LPm` derives `q` from `{p, p → q}`.** -/
theorem entailsMin_Γ₁_q : entailsMin Γ₁ q := by
  intro w hw
  have hfree := minimal_Γ₁_glutfree hw
  obtain ⟨h0, himpl⟩ := (isModel_Γ₁ w).mp hw.1
  simp only [p, eval_atom] at h0
  simp only [p, q, Form.impl, eval_disj, eval_neg, eval_atom] at himpl
  have hw0 : w 0 = tt := ne_bb_desig_eq_tt _ (hfree 0) h0
  rw [hw0] at himpl
  simp only [neg, disj_ff_left] at himpl
  have hw1 : w 1 = tt := ne_bb_desig_eq_tt _ (hfree 1) himpl
  simp only [q, eval_atom, hw1]
  decide

-- !-- Every model of `Γ₂` is *forced* to set `p = bb`: `p` and `¬p` both designated can
-- only happen at the glut. -- !--
theorem model_Γ₂_forces_bb {v : ℕ → LP} (hv : isModel Γ₂ v) : v 0 = bb := by
  rw [isModel_Γ₂] at hv
  obtain ⟨h0, _, hnp⟩ := hv
  simp only [p, eval_atom] at h0
  simp only [p, eval_neg, eval_atom] at hnp
  exact desig_neg_forces_bb _ h0 hnp

/-- The witness model of `Γ₂`: `0 ↦ bb`, `1 ↦ ff`, everything else `tt`. -/
def wstar : ℕ → LP := fun n => if n = 0 then bb else if n = 1 then ff else tt

theorem isModel_Γ₂_wstar : isModel Γ₂ wstar := by
  rw [isModel_Γ₂]
  refine ⟨?_, ?_, ?_⟩ <;>
    simp only [p, q, Form.impl, wstar, eval_disj, eval_neg, eval_atom] <;> decide

theorem gluts_wstar_subset : gluts wstar ⊆ {0} := by
  intro x hx
  simp only [gluts, Set.mem_setOf_eq, wstar] at hx
  simp only [Set.mem_singleton_iff]
  by_contra hx0
  rw [if_neg hx0] at hx
  by_cases hx1 : x = 1
  · rw [if_pos hx1] at hx; exact absurd hx (by decide)
  · rw [if_neg hx1] at hx; exact absurd hx (by decide)

theorem zero_mem_gluts_of_model_Γ₂ {v : ℕ → LP} (hv : isModel Γ₂ v) : (0 : ℕ) ∈ gluts v := by
  show v 0 = bb
  exact model_Γ₂_forces_bb hv

-- !-- The witness `wstar` is a *minimal* model of `Γ₂` because its only glut, `0`, is
-- forced in every model — so no model can have a strictly smaller glut set. -- !--
theorem minimalModel_Γ₂_wstar : minimalModel Γ₂ wstar := by
  refine ⟨isModel_Γ₂_wstar, ?_⟩
  intro w' hw' hss
  have h0 : (0 : ℕ) ∈ gluts w' := zero_mem_gluts_of_model_Γ₂ hw'
  have hsub : gluts wstar ⊆ gluts w' := by
    intro x hx
    have hx0 : x = 0 := gluts_wstar_subset hx
    rw [hx0]; exact h0
  exact (Set.ssubset_def.mp hss).2 hsub

-- !-- Adding `¬p` retracts `q`: `wstar` is a minimal model of `Γ₂` at which `q` evaluates
-- to `ff`, so `q` is no longer a minimal consequence. -- !--
/-- **`LPm` retracts `q` once `¬p` is added** — minimal consequence is non-monotone. -/
theorem not_entailsMin_Γ₂_q : ¬ entailsMin Γ₂ q := by
  intro hcon
  have hd : desig (eval wstar q) := hcon wstar minimalModel_Γ₂_wstar
  simp only [q, eval_atom, wstar] at hd
  exact absurd hd (by decide)

/-- **Non-monotonicity of `LPm` (the centrepiece).**  The conclusion `q` is a minimal
consequence of `{p, p → q}` but is *retracted* when the contradictory belief `¬p` is added,
even though `Γ₁ ⊆ Γ₂`. -/
theorem retraction_nonmonotone :
    Γ₁ ⊆ Γ₂ ∧ entailsMin Γ₁ q ∧ ¬ entailsMin Γ₂ q := by
  refine ⟨?_, entailsMin_Γ₁_q, not_entailsMin_Γ₂_q⟩
  intro x hx
  simp only [Γ₁, Γ₂, Set.mem_insert_iff, Set.mem_singleton_iff] at hx ⊢
  tauto

/-! ## Cross-domain bridge: LP as an idempotent (tropical-style) semiring

`conj = min`, `disj = max` on the chain `ff < bb < tt`.  We give `LP` its bounded
distributive-lattice / commutative idempotent semiring structure, with `disj` as `+`
(identity `ff = ⊥`) and `conj` as `*` (identity `tt = ⊤`).  This realises the LP truth
tables as a literal two-spaced tropical / min-plus structure, and shows the designated
filter `{bb, tt}` is prime for both operations. -/

instance : Zero LP := ⟨ff⟩
instance : One LP := ⟨tt⟩
instance : Add LP := ⟨disj⟩
instance : Mul LP := ⟨conj⟩

-- !-- All semiring axioms are finite identities over three values, discharged by
-- exhaustive truth-table checking; `disj`/`conj` are `max`/`min` on a chain. -- !--
/-- **LP is a commutative semiring** under `(disj, conj)` with units `(ff, tt)`. -/
instance commSemiring : CommSemiring LP where
  nsmul := nsmulRec
  npow := npowRec
  add_assoc := by decide
  zero_add := by decide
  add_zero := by decide
  add_comm := by decide
  mul_assoc := by decide
  one_mul := by decide
  mul_one := by decide
  left_distrib := by decide
  right_distrib := by decide
  zero_mul := by decide
  mul_zero := by decide
  mul_comm := by decide

-- !-- Both operations are idempotent (`max`/`min` of a value with itself), the defining
-- feature distinguishing tropical-style semirings from ordinary ones. -- !--
/-- **Additive idempotence:** `a + a = a` (the semiring is idempotent / tropical-style). -/
theorem add_idem (a : LP) : a + a = a := by cases a <;> rfl

/-- **Multiplicative idempotence:** `a * a = a`. -/
theorem mul_idem (a : LP) : a * a = a := by cases a <;> rfl

-- !-- The designated set is a prime filter for both lattice operations: a meet is
-- designated iff both factors are, a join iff at least one is. -- !--
/-- **`{bb, tt}` is closed under `conj`/`min` and is a prime filter**: a meet is
designated iff both meetands are. -/
theorem desig_mul (a b : LP) : desig (a * b) ↔ desig a ∧ desig b := by
  revert a b; decide

/-- **`{bb, tt}` is a prime filter for `disj`/`max`**: a join is designated iff at least
one disjunct is. -/
theorem desig_add (a b : LP) : desig (a + b) ↔ desig a ∨ desig b := by
  revert a b; decide

/-- **Bridge identities:** the semiring operations are exactly the LP connectives. -/
theorem add_eq_disj (a b : LP) : a + b = disj a b := rfl
/-- The multiplicative operation is exactly LP conjunction. -/
theorem mul_eq_conj (a b : LP) : a * b = conj a b := rfl

end LP

end Paraconsistent