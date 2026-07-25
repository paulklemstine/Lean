import Mathlib

/-!
# Dream Logic III: First-Principles Structural Core of Paraconsistent Consequence

This file is a **self-contained, first-principles** development of the *Logic of Paradox*
(`LP`, Priest's three-valued paraconsistent logic) and its structural meta-theory.  It is a
companion to `Logic.DreamLogic.NonMonotone` ("Dream Logic II"), reconstructing the minimal
semantic kernel needed to state and prove a fresh layer of *structural* meta-theorems, with
no external project dependencies (only Mathlib).

The three truth values are `tt` (true only), `ff` (false only) and the glut `bb` (both).
Connectives are the De Morgan lattice operations `min`/`max` in the truth order
`ff < bb < tt`, with the antitone involution `neg` fixing the glut.  A value is *designated*
iff it is `tt` or `bb`.  `entails Γ A` means: every valuation designating all of `Γ`
designates `A`.

## Main results

* `eval_subst` / `lpvalid_subst_closed` — **Structurality (uniform substitution closure).**
  `LP`-validity is preserved by every substitution of formulas for atoms.  This is the
  defining property of a *logic* in the Tarski–Łoś sense and is proved from a clean
  homomorphism lemma `eval_subst`.
* `eval_allbb` / `absolute_glut_models_all` / `contradiction_satisfiable` — **The absolute
  glut.**  The constant valuation `n ↦ bb` is a *single model that satisfies every formula*.
  Hence every contradiction `{A, ¬A}` is jointly satisfiable: paraconsistency in its purest
  model-theoretic form (impossible classically).
* `explosion_fails` — **Ex contradictione non quodlibet.**  `{p, ¬p} ⊭ q`.
* `lem_valid` / `lnc_valid` — **Excluded middle and non-contradiction are `LP`-valid.**  The
  glut adds *no* refutations of these laws even though it satisfies contradictions: the
  hallmark separation of *validity* from *triviality*.
* `entails_imp_entailsMin` — **Recapture is conservative.**  Every `LP`-consequence is also a
  consequence of the non-monotone glut-minimal relation `LPm`: minimizing models only ever
  *adds* inferences.
* `Cn_idempotent` — **The consequence operator is a closure operator.**  `Cn (Cn Γ) = Cn Γ`,
  packaging reflexivity + monotonicity into Tarskian idempotence.

-- !-- Lab Notebook -- !--
Hypothesis: The structural skeleton of LP (substitution-closure, the Tarski closure
  operator, conservativity of glut-minimisation) is fully orthogonal to its paraconsistency,
  and can be erected from a three-line semantic kernel without any of the connective-level
  case analysis that dominates the object-level theory.
Result: Confirmed. `eval_subst` is a one-line structural induction; `lpvalid_subst_closed`,
  `entails_imp_entailsMin` and `Cn_idempotent` then follow with *no* truth-value case
  analysis at all — they are pure quantifier/Set manipulations. Only the *paraconsistent*
  theorems (`absolute_glut_models_all`, `lem_valid`, `lnc_valid`) touch the 3-value table.
Insight: The single valuation `n ↦ bb` is a *terminal* object for satisfaction — it models
  every formula because `bb` is a simultaneous fixpoint of `neg`, `conj` and `disj`. This one
  fact (`eval_allbb`) yields both the satisfiability of every contradiction AND, dually, is
  exactly what the *minimal*-model semantics `LPm` excludes in order to recapture classical
  inference. So glut-fixpoint and recapture are two sides of one coin.
Failure analysis: A first attempt proved `contradiction_satisfiable` by `simp ... ; decide`
  and stalled on the residual `bb.desig` goal because `desig` is a `Prop`-valued match, not a
  `Bool`; the fix was to expose `eval _ (neg A) = bb` explicitly via the fixpoint lemma and
  discharge designation by `trivial`. Defining `desig : LPval → Prop` (rather than `Bool`)
  keeps `Holds` propositional and the structural proofs `decide`-free, at the cost of needing
  the explicit `DecidablePred` instance used by the concrete `explosion_fails` counter-model.
-/

namespace DreamLogicMeta

/-! ### The three-valued algebra of `LP` -/

/-- Truth values of the Logic of Paradox: `tt` (true only), `bb` (the glut, *both*),
`ff` (false only). -/
inductive LPval | tt | bb | ff
deriving DecidableEq, Repr

namespace LPval

/-- Negation: the antitone De Morgan involution fixing the glut. -/
def neg : LPval → LPval | tt => ff | bb => bb | ff => tt

/-- Conjunction: `min` in the truth order `ff < bb < tt`. -/
def conj : LPval → LPval → LPval
  | ff, _ => ff | _, ff => ff | bb, _ => bb | _, bb => bb | tt, tt => tt

/-- Disjunction: `max` in the truth order `ff < bb < tt`. -/
def disj : LPval → LPval → LPval
  | tt, _ => tt | _, tt => tt | bb, _ => bb | _, bb => bb | ff, ff => ff

/-- Designation: a value counts as "asserted" iff it is at least partly true. -/
def desig : LPval → Prop | tt => True | bb => True | ff => False

instance : DecidablePred desig := fun x =>
  match x with
  | tt => .isTrue trivial
  | bb => .isTrue trivial
  | ff => .isFalse id

end LPval

/-! ### Syntax and semantics -/

/-- Propositional formulas over countably many atoms. -/
inductive Form
  | atom : ℕ → Form
  | neg : Form → Form
  | conj : Form → Form → Form
  | disj : Form → Form → Form

/-- Material implication, defined as `¬A ∨ B`. -/
def Form.imp (A B : Form) : Form := Form.disj (Form.neg A) B

/-- A valuation assigns a truth value to each atom. -/
abbrev Valuation := ℕ → LPval

/-- The `LP` truth-value of a formula under a valuation. -/
def eval (v : Valuation) : Form → LPval
  | Form.atom n => v n
  | Form.neg A => (eval v A).neg
  | Form.conj A B => (eval v A).conj (eval v B)
  | Form.disj A B => (eval v A).disj (eval v B)

/-- `A` holds under `v` iff its value is designated. -/
def Holds (v : Valuation) (A : Form) : Prop := (eval v A).desig

/-- **Consequence.** Every valuation designating all of `Γ` designates `A`. -/
def entails (Γ : Set Form) (A : Form) : Prop := ∀ v, (∀ B ∈ Γ, Holds v B) → Holds v A

/-- **Validity.** Designated under every valuation. -/
def LPvalid (A : Form) : Prop := ∀ v, Holds v A

/-! ### Structurality: closure under uniform substitution -/

/-- Uniform substitution of a formula for each atom. -/
def subst (σ : ℕ → Form) : Form → Form
  | Form.atom n => σ n
  | Form.neg A => Form.neg (subst σ A)
  | Form.conj A B => Form.conj (subst σ A) (subst σ B)
  | Form.disj A B => Form.disj (subst σ A) (subst σ B)

-- !-- `eval` is a homomorphism for substitution: evaluating a substituted formula equals
--    evaluating the original under the pre-evaluated valuation. Structural induction. -- !--
/-- **Substitution lemma.** `eval` commutes with substitution. -/
theorem eval_subst (v : Valuation) (σ : ℕ → Form) (A : Form) :
    eval v (subst σ A) = eval (fun n => eval v (σ n)) A := by
  induction A with
  | atom n => rfl
  | neg A ih => simp [eval, subst, ih]
  | conj A B ihA ihB => simp [eval, subst, ihA, ihB]
  | disj A B ihA ihB => simp [eval, subst, ihA, ihB]

-- !-- Validity is a statement about *all* valuations, and `eval_subst` reroutes a
--    substituted valuation to an ordinary one. -- !--
/-- **Structurality.** `LP`-validity is closed under uniform substitution — `LP` is a genuine
logic in the Tarski–Łoś sense. -/
theorem lpvalid_subst_closed {A : Form} (h : LPvalid A) (σ : ℕ → Form) :
    LPvalid (subst σ A) := by
  intro v
  unfold Holds
  rw [eval_subst]
  exact h _

/-! ### The absolute glut: a model of everything -/

-- !-- `bb` is a simultaneous fixpoint of `neg`, `conj`, `disj`, so the constant-`bb`
--    valuation evaluates every formula to `bb`. Structural induction. -- !--
/-- **Glut fixpoint.** Under the constant glut valuation every formula evaluates to `bb`. -/
theorem eval_allbb (A : Form) : eval (fun _ => LPval.bb) A = LPval.bb := by
  induction A with
  | atom n => rfl
  | neg A ih => simp [eval, ih, LPval.neg]
  | conj A B ihA ihB => simp [eval, ihA, ihB, LPval.conj]
  | disj A B ihA ihB => simp [eval, ihA, ihB, LPval.disj]

-- !-- `bb` is designated, so the constant-`bb` valuation designates everything. -- !--
/-- **The absolute glut models everything.** A single valuation satisfies every formula —
impossible classically, and the model-theoretic heart of non-triviality. -/
theorem absolute_glut_models_all (A : Form) : Holds (fun _ => LPval.bb) A := by
  unfold Holds; rw [eval_allbb]; trivial

-- !-- Take the absolute glut: it designates both `A` and `¬A`. -- !--
/-- **Every contradiction is satisfiable.** For any `A`, some valuation designates both `A`
and `¬A`. -/
theorem contradiction_satisfiable (A : Form) :
    ∃ v, Holds v A ∧ Holds v (Form.neg A) := by
  refine ⟨fun _ => LPval.bb, absolute_glut_models_all A, ?_⟩
  have hneg : eval (fun _ => LPval.bb) (Form.neg A) = LPval.bb := by
    simp [eval, eval_allbb, LPval.neg]
  unfold Holds; rw [hneg]; trivial

-- !-- Witness `p ↦ bb, q ↦ ff`: designates `p` and `¬p` but not `q`. -- !--
/-- **Ex contradictione non quodlibet.** Explosion fails: `{p, ¬p} ⊭ q`. -/
theorem explosion_fails :
    ¬ entails {Form.atom 0, Form.neg (Form.atom 0)} (Form.atom 1) := by
  intro h
  have key := h (fun n => if n = 0 then LPval.bb else LPval.ff) (by
    intro B hB
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl <;> (simp only [Holds, eval]; decide))
  exact (by simp only [Holds, eval]; decide :
    ¬ Holds (fun n => if n = 0 then LPval.bb else LPval.ff) (Form.atom 1)) key

/-! ### Excluded middle and non-contradiction remain valid -/

-- !-- Case on `eval v A`: in every case `A ∨ ¬A` is designated. -- !--
/-- **Law of excluded middle is `LP`-valid.** `⊨ A ∨ ¬A`. -/
theorem lem_valid (A : Form) : LPvalid (Form.disj A (Form.neg A)) := by
  intro v
  unfold Holds
  simp only [eval]
  cases h : eval v A <;> simp [LPval.neg, LPval.disj, LPval.desig]

-- !-- Case on `eval v A`: in every case `¬(A ∧ ¬A)` is designated. -- !--
/-- **Law of non-contradiction is `LP`-valid.** `⊨ ¬(A ∧ ¬A)` — valid *despite* every
contradiction being satisfiable: `LP` separates validity from triviality. -/
theorem lnc_valid (A : Form) : LPvalid (Form.neg (Form.conj A (Form.neg A))) := by
  intro v
  unfold Holds
  simp only [eval]
  cases h : eval v A <;> simp [LPval.neg, LPval.conj, LPval.desig]

/-! ### Recapture: minimal-model consequence conservatively extends `LP` -/

/-- `v` models `Γ`. -/
def Models (Γ : Set Form) (v : Valuation) : Prop := ∀ B ∈ Γ, Holds v B

/-- The set of atoms assigned the glut by `v`. -/
def GlutSet (v : Valuation) : Set ℕ := {n | v n = LPval.bb}

/-- A model of `Γ` whose glut set is `⊂`-minimal among all models of `Γ`. -/
def MinimalModel (Γ : Set Form) (v : Valuation) : Prop :=
  Models Γ v ∧ ∀ w, Models Γ w → ¬ GlutSet w ⊂ GlutSet v

/-- **Non-monotone (minimal-model) consequence**, the relation `LPm`. -/
def entailsMin (Γ : Set Form) (A : Form) : Prop := ∀ v, MinimalModel Γ v → Holds v A

-- !-- A minimal model is in particular a model, so any consequence over all models is one
--    over minimal models. -- !--
/-- **Conservativity of recapture.** Every `LP`-consequence is an `LPm`-consequence:
minimizing models only ever *adds* inferences, never retracts them. -/
theorem entails_imp_entailsMin {Γ : Set Form} {A : Form} (h : entails Γ A) :
    entailsMin Γ A := fun v hv => h v hv.1

/-! ### The consequence operator is a Tarskian closure operator -/

/-- The deductive closure of `Γ`. -/
def Cn (Γ : Set Form) : Set Form := {A | entails Γ A}

-- !-- A premise holds in every model of the premise set. -- !--
/-- **Reflexivity.** `Γ ⊆ Cn Γ`. -/
theorem entails_refl {Γ : Set Form} {A : Form} (hA : A ∈ Γ) : entails Γ A :=
  fun _ hv => hv A hA

-- !-- A model of the larger set is a model of the smaller set. -- !--
/-- **Monotonicity.** `Γ ⊆ Δ → Cn Γ ⊆ Cn Δ`. -/
theorem entails_monotone {Γ Δ : Set Form} {A : Form} (hsub : Γ ⊆ Δ) (h : entails Γ A) :
    entails Δ A := fun _ hv => h _ (fun B hB => hv B (hsub hB))

-- !-- ⊇ is reflexivity+monotonicity; ⊆ holds because any model of Γ models all of Cn Γ. -- !--
/-- **Idempotence.** `Cn (Cn Γ) = Cn Γ`: `Cn` is a genuine Tarskian closure operator. -/
theorem Cn_idempotent (Γ : Set Form) : Cn (Cn Γ) = Cn Γ := by
  apply Set.eq_of_subset_of_subset
  · intro A hA
    simp only [Cn, Set.mem_setOf_eq] at hA ⊢
    intro v hv
    exact hA v (fun B hB => hB v hv)
  · intro A hA
    simp only [Cn, Set.mem_setOf_eq] at hA ⊢
    exact entails_monotone (fun B hB => entails_refl hB) hA

end DreamLogicMeta