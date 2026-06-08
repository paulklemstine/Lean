/-
# Transreal Arithmetic: Computing Beyond Plus-Minus Infinity

Formalization of Anderson's transreal number system: ℝ ∪ {+∞, -∞, Φ}
where Φ (nullity) = 0/0 is a new absorbing element.

## Main Results
1. Ring axioms fail: additive cancellation, 0·x = 0, distributivity all break
2. Nullity Φ is absorbing for both addition and multiplication
3. The zero-product property (a*b = 0 → a=0 ∨ b=0) surprisingly HOLDS
4. The wheel identity x + 0·x = x fails for infinite elements
5. Additively idempotent elements = {+∞, -∞, Φ, 0}
6. Negation fixed points = {0, Φ} (one more than in ℝ)
7. The transreal order is not total (Φ is incomparable with reals)
8. Left distributivity fails: nullity "infects" sums
-/

import Mathlib

/-! ## Core Definition -/

/-- The transreal numbers extend ℝ with positive infinity, negative infinity,
    and nullity (Φ = 0/0). -/
inductive Transreal where
  | ofReal : ℝ → Transreal
  | posInf : Transreal
  | negInf : Transreal
  | nullity : Transreal
  deriving Inhabited

namespace Transreal

/-- Sign classification for dispatch in multiplication/division -/
inductive RealSign where
  | pos | neg | zero
  deriving DecidableEq

/-- Classify the sign of a real number -/
noncomputable def realSign (r : ℝ) : RealSign :=
  if r > 0 then RealSign.pos
  else if r < 0 then RealSign.neg
  else RealSign.zero

/-! ## Arithmetic Operations -/

noncomputable def add : Transreal → Transreal → Transreal
  | ofReal a, ofReal b => ofReal (a + b)
  | posInf, posInf => posInf
  | negInf, negInf => negInf
  | posInf, negInf => nullity
  | negInf, posInf => nullity
  | posInf, ofReal _ => posInf
  | ofReal _, posInf => posInf
  | negInf, ofReal _ => negInf
  | ofReal _, negInf => negInf
  | nullity, _ => nullity
  | _, nullity => nullity

noncomputable instance : Add Transreal := ⟨add⟩

noncomputable def neg : Transreal → Transreal
  | ofReal a => ofReal (-a)
  | posInf => negInf
  | negInf => posInf
  | nullity => nullity

noncomputable instance : Neg Transreal := ⟨neg⟩

noncomputable def mul : Transreal → Transreal → Transreal
  | ofReal a, ofReal b => ofReal (a * b)
  | posInf, posInf => posInf
  | negInf, negInf => posInf
  | posInf, negInf => negInf
  | negInf, posInf => negInf
  | posInf, ofReal r =>
    match realSign r with
    | RealSign.pos => posInf
    | RealSign.neg => negInf
    | RealSign.zero => nullity
  | ofReal r, posInf =>
    match realSign r with
    | RealSign.pos => posInf
    | RealSign.neg => negInf
    | RealSign.zero => nullity
  | negInf, ofReal r =>
    match realSign r with
    | RealSign.pos => negInf
    | RealSign.neg => posInf
    | RealSign.zero => nullity
  | ofReal r, negInf =>
    match realSign r with
    | RealSign.pos => negInf
    | RealSign.neg => posInf
    | RealSign.zero => nullity
  | nullity, _ => nullity
  | _, nullity => nullity

noncomputable instance : Mul Transreal := ⟨mul⟩

noncomputable def tinv : Transreal → Transreal
  | ofReal r =>
    match realSign r with
    | RealSign.pos => ofReal (r⁻¹)
    | RealSign.neg => ofReal (r⁻¹)
    | RealSign.zero => posInf
  | posInf => ofReal 0
  | negInf => ofReal 0
  | nullity => nullity

noncomputable instance : Inv Transreal := ⟨tinv⟩
noncomputable instance : Div Transreal := ⟨fun a b => a * b⁻¹⟩
noncomputable instance : Zero Transreal := ⟨ofReal 0⟩
noncomputable instance : One Transreal := ⟨ofReal 1⟩

/-! ## Part I: Nullity Absorption — the defining feature of transreals -/

/-- Nullity absorbs on the left under addition -/
theorem nullity_add_absorb (x : Transreal) : nullity + x = nullity := by
  cases x <;> rfl

/-- Nullity absorbs on the right under addition -/
theorem add_nullity_absorb (x : Transreal) : x + nullity = nullity := by
  cases x <;> rfl

/-- Nullity absorbs on the left under multiplication -/
theorem nullity_mul_absorb (x : Transreal) : nullity * x = nullity := by
  cases x <;> rfl

/-- Nullity absorbs on the right under multiplication -/
theorem mul_nullity_absorb (x : Transreal) : x * nullity = nullity := by
  cases x <;> rfl

/-! ## Part II: Ring Axioms Fail -/

/-- **The transreals do not form an additive group.**
    Proof: nullity + (-nullity) = nullity + nullity = nullity ≠ 0. -/
theorem transreal_not_additive_group :
    ¬ (∀ x : Transreal, x + (-x) = 0) := by
  intro h
  have := h nullity
  change add nullity (neg nullity) = ofReal 0 at this
  simp [add] at this

/-- ∞ + (-∞) = Φ, not 0 -/
theorem posInf_add_negInf : (posInf : Transreal) + negInf = nullity := rfl

/-- **Additive cancellation fails.**
    ofReal 1 + posInf = posInf + posInf = posInf, but ofReal 1 ≠ posInf. -/
theorem additive_cancellation_fails :
    ¬ (∀ a b c : Transreal, a + c = b + c → a = b) := by
  intro h
  have := h (ofReal 1) posInf posInf
    (show add (ofReal 1) posInf = add posInf posInf from rfl)
  exact Transreal.noConfusion this

/-- **0 × ∞ = Φ, not 0.** The ring axiom 0·x = 0 fails. -/
theorem zero_mul_posInf_eq_nullity :
    (0 : Transreal) * posInf = nullity := by
  show mul (ofReal 0) posInf = nullity
  simp [mul, realSign]

/-- Helper: any product equal to ofReal 0 must come from real factors -/
private lemma mul_eq_ofReal_zero (a b : Transreal) (hab : mul a b = ofReal 0) :
    ∃ ra rb : ℝ, a = ofReal ra ∧ b = ofReal rb := by
  rcases a with (ra | _ | _ | _) <;> rcases b with (rb | _ | _ | _)
  · exact ⟨ra, rb, rfl, rfl⟩
  all_goals simp only [mul] at hab
  all_goals (try exact absurd hab Transreal.noConfusion)
  all_goals (split at hab <;> exact absurd hab Transreal.noConfusion)

/-- **The zero-product property holds in transreals.**
    This is surprising: despite all the exotic arithmetic, if a*b = ofReal 0,
    then at least one factor must be ofReal 0. The key insight is that every
    non-real product is non-real (it's ±∞ or Φ). -/
theorem zero_product_property_holds :
    ∀ a b : Transreal, a * b = 0 → a = 0 ∨ b = 0 := by
  intro a b hab
  have ⟨ra, rb, ha, hb⟩ := mul_eq_ofReal_zero a b hab
  subst ha; subst hb
  have h2 : ra * rb = 0 := Transreal.ofReal.inj hab
  rcases mul_eq_zero.mp h2 with h | h
  · left; exact congrArg ofReal h
  · right; exact congrArg ofReal h

/-- **There exist nonzero elements whose product is nullity.**
    The transreal "zero-like" behavior splits: ofReal 0 (real zero)
    vs nullity (indeterminate). The zero-product property holds for the former
    but not the latter. -/
theorem exists_nonzero_product_nullity :
    ∃ a b : Transreal, a ≠ 0 ∧ b ≠ 0 ∧ a * b = nullity :=
  ⟨nullity, nullity, Transreal.noConfusion, Transreal.noConfusion,
    nullity_mul_absorb nullity⟩

/-! ## Part III: Real Embedding Preserves Operations -/

theorem ofReal_add (a b : ℝ) : ofReal a + ofReal b = ofReal (a + b) := rfl
theorem ofReal_mul (a b : ℝ) : ofReal a * ofReal b = ofReal (a * b) := rfl
theorem ofReal_neg (a : ℝ) : -ofReal a = ofReal (-a) := rfl

/-- The reals are closed under transreal addition -/
theorem real_closure_add (a b : ℝ) :
    ∃ c : ℝ, ofReal a + ofReal b = ofReal c := ⟨a + b, rfl⟩

/-- The reals are closed under transreal multiplication -/
theorem real_closure_mul (a b : ℝ) :
    ∃ c : ℝ, ofReal a * ofReal b = ofReal c := ⟨a * b, rfl⟩

/-! ## Part IV: Negation Fixed Points -/

theorem neg_nullity : -(nullity : Transreal) = nullity := rfl
theorem nullity_ne_zero : (nullity : Transreal) ≠ 0 := Transreal.noConfusion

/-- **Negation fixed point classification.**
    In ℝ, only 0 satisfies -x = x. The transreals add exactly one more
    fixed point: nullity. This extra fixed point reflects the self-symmetry
    of indeterminacy. -/
theorem neg_fixed_points (x : Transreal) :
    -x = x ↔ x = ofReal 0 ∨ x = nullity := by
  show neg x = x ↔ _
  constructor
  · intro h; cases x with
    | ofReal r =>
      simp only [neg, ofReal.injEq] at h
      exact Or.inl (by congr; linarith)
    | posInf => simp [neg] at h
    | negInf => simp [neg] at h
    | nullity => exact Or.inr rfl
  · rintro (rfl | rfl)
    · simp [neg]
    · rfl

/-! ## Part V: Commutativity -/

/-- Addition is commutative (non-trivial: the definition is asymmetric) -/
theorem add_comm_transreal (a b : Transreal) : a + b = b + a := by
  show add a b = add b a
  cases a <;> cases b <;> simp [add, _root_.add_comm]

/-- Multiplication is commutative -/
theorem mul_comm_transreal (a b : Transreal) : a * b = b * a := by
  show mul a b = mul b a
  cases a <;> cases b <;> simp [mul, _root_.mul_comm]

/-! ## Part VI: Additively Idempotent Elements -/

theorem posInf_add_self : (posInf : Transreal) + posInf = posInf := rfl
theorem negInf_add_self : (negInf : Transreal) + negInf = negInf := rfl
theorem nullity_add_self : (nullity : Transreal) + nullity = nullity := rfl

/-- **Classification of additively idempotent elements.**
    An element x satisfies x + x = x iff x ∈ {+∞, -∞, Φ, 0}.
    This is the "non-Archimedean skeleton": exactly the elements that
    cannot be reached by repeated self-addition of a finite quantity. -/
theorem additive_idempotent_iff (x : Transreal) :
    x + x = x ↔ x = posInf ∨ x = negInf ∨ x = nullity ∨ x = ofReal 0 := by
  show add x x = x ↔ _
  constructor
  · intro h; cases x with
    | ofReal r =>
      simp only [add, ofReal.injEq] at h
      exact Or.inr (Or.inr (Or.inr (by congr; linarith)))
    | posInf => exact Or.inl rfl
    | negInf => exact Or.inr (Or.inl rfl)
    | nullity => exact Or.inr (Or.inr (Or.inl rfl))
  · rintro (rfl | rfl | rfl | rfl) <;> simp [add]

/-! ## Part VII: Order Incomparability -/

/-- A natural partial order on transreals extending the real ordering.
    Nullity is comparable only to itself. -/
noncomputable def tle : Transreal → Transreal → Prop
  | ofReal a, ofReal b => a ≤ b
  | negInf, negInf => True
  | negInf, ofReal _ => True
  | negInf, posInf => True
  | ofReal _, posInf => True
  | posInf, posInf => True
  | nullity, nullity => True
  | _, _ => False

/-- **The transreal order is not total.**
    Nullity and 0 are incomparable: neither Φ ≤ 0 nor 0 ≤ Φ holds.
    This means transreals cannot be a totally ordered field. -/
theorem order_not_total :
    ¬ (∀ a b : Transreal, tle a b ∨ tle b a) := by
  intro h
  have := h nullity (ofReal 0)
  simp [tle] at this

/-! ## Part VIII: Division by Zero -/

/-- Positive divided by zero gives +∞ -/
theorem pos_div_zero (r : ℝ) (hr : 0 < r) :
    ofReal r / ofReal 0 = posInf := by
  show mul (ofReal r) (tinv (ofReal 0)) = posInf
  simp [tinv, realSign]
  show mul (ofReal r) posInf = posInf
  simp [mul, realSign, hr]

/-- **0/0 = Φ: the defining equation of nullity.** -/
theorem zero_div_zero : (ofReal 0 : Transreal) / ofReal 0 = nullity := by
  show mul (ofReal 0) (tinv (ofReal 0)) = nullity
  simp [tinv, realSign]
  show mul (ofReal 0) posInf = nullity
  simp [mul, realSign]

/-! ## Part IX: Wheel Identity Analysis -/

/-- The wheel identity x + 0·x = x holds for real elements -/
theorem wheel_identity_real (r : ℝ) :
    ofReal r + (0 : Transreal) * ofReal r = ofReal r := by
  show add (ofReal r) (mul (ofReal 0) (ofReal r)) = ofReal r
  simp [mul, add]

/-- **The wheel identity fails for +∞.**
    0 · (+∞) = Φ, and +∞ + Φ = Φ ≠ +∞.
    This means transreals are NOT a wheel in the standard sense:
    the wheel identity needs modification to account for infinity. -/
theorem wheel_identity_fails_posInf :
    posInf + (0 : Transreal) * posInf ≠ posInf := by
  show add posInf (mul (ofReal 0) posInf) ≠ posInf
  simp [mul, realSign, add]

/-! ## Part X: Structural Theorems -/

/-- Addition is associative for real inputs -/
theorem add_assoc_real (a b c : ℝ) :
    ofReal a + ofReal b + ofReal c = ofReal a + (ofReal b + ofReal c) := by
  show add (add (ofReal a) (ofReal b)) (ofReal c) =
       add (ofReal a) (add (ofReal b) (ofReal c))
  simp [add, _root_.add_assoc]

/-- Negation is an involution: -(-x) = x for all transreals -/
theorem neg_neg (x : Transreal) : -(-x) = x := by
  show neg (neg x) = x
  cases x <;> simp [neg]

/-! ## Part XI: Ring Axiom 0·x = 0 Fails -/

/-- **The ring axiom 0·x = 0 fails in transreals.**
    Counterexample: 0 · (+∞) = Φ ≠ 0. -/
theorem zero_mul_ne_zero_sometimes :
    ¬ (∀ x : Transreal, (0 : Transreal) * x = 0) := by
  intro h
  have h1 := h posInf
  have h2 : mul (ofReal 0) posInf = nullity := by simp [mul, realSign]
  rw [show (0 : Transreal) * posInf = mul (ofReal 0) posInf from rfl] at h1
  rw [h2] at h1
  exact Transreal.noConfusion h1

/-- The ring axiom x · 1 = x does hold universally -/
theorem mul_one_transreal (x : Transreal) : x * ofReal 1 = x := by
  show mul x (ofReal 1) = x
  cases x with
  | ofReal r => simp [mul]
  | posInf => simp only [mul]; simp [realSign]
  | negInf => simp only [mul]; simp [realSign]
  | nullity => rfl

/-- Left multiplication by 1 -/
theorem one_mul_transreal (x : Transreal) : ofReal 1 * x = x := by
  rw [show ofReal 1 * x = x * ofReal 1 from mul_comm_transreal _ _]
  exact mul_one_transreal x

/-! ## Part XII: Distributivity Failure -/

/-- **Left distributivity fails in transreals.**
    posInf · (0 + 1) = posInf · 1 = posInf,
    but posInf · 0 + posInf · 1 = Φ + posInf = Φ.
    The nullity from 0 × ∞ "infects" the entire sum. -/
theorem left_distributivity_fails :
    ¬ (∀ a b c : Transreal, a * (b + c) = a * b + a * c) := by
  intro h
  have h1 := h posInf (ofReal 0) (ofReal 1)
  have lhs : mul posInf (add (ofReal 0) (ofReal 1)) = posInf := by
    simp [add, mul, realSign]
  have rhs : add (mul posInf (ofReal 0)) (mul posInf (ofReal 1)) = nullity := by
    simp [mul, realSign, add]
  rw [show posInf * (ofReal 0 + ofReal 1) =
        mul posInf (add (ofReal 0) (ofReal 1)) from rfl,
      show posInf * ofReal 0 + posInf * ofReal 1 =
        add (mul posInf (ofReal 0)) (mul posInf (ofReal 1)) from rfl] at h1
  rw [lhs, rhs] at h1
  exact Transreal.noConfusion h1

end Transreal