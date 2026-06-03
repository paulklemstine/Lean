/-
  Transreal Arithmetic: Ring Failure and Wheel Structure

  Main results:
  1. Ring axioms fail for transreals (additive inverse, distributivity)
  2. Nullity absorption — Φ is an annihilator for both + and ×
  3. Commutativity and associativity hold globally for +
  4. Transreal division is total but breaks cancellation
  5. Negation is a global additive homomorphism
  6. Multiplication associativity holds globally
-/
import Tropical.TransrealDefs

set_option maxHeartbeats 800000

namespace Transreal

-- ============================================================
-- SECTION 1: Ring Axioms Fail
-- ============================================================

/-- **Theorem (No Additive Inverse for +∞)**: There is no transreal x such that
    +∞ + x = 0. This is the fundamental obstruction to a ring structure. -/
theorem no_additive_inverse_posInf : ¬ ∃ x : Transreal, posInf + x = 0 := by
  rintro ⟨ x, hx ⟩
  rcases x with ( _ | _ | _ | _ ) <;> cases hx

/-- **Theorem (No Additive Inverse for Nullity)**: Φ has no additive inverse. -/
theorem no_additive_inverse_nullity : ¬ ∃ x : Transreal, nullity + x = 0 := by
  exact fun ⟨ x, hx ⟩ => by cases x <;> cases hx

/-- **Theorem (Distributivity Fails)**: posInf * (1 + negInf) ≠ posInf*1 + posInf*negInf.
    LHS = posInf * negInf = negInf. RHS = posInf + negInf = nullity. -/
theorem distributivity_fails :
    ∃ a b c : Transreal, a * (b + c) ≠ a * b + a * c := by
  use posInf, ofReal 1, negInf
  have h1 : posInf * ofReal 1 = posInf := if_pos (by norm_num)
  have h2 : posInf * negInf = negInf := rfl
  simp +decide [h1, h2, posInf_add_negInf]

-- ============================================================
-- SECTION 2: Nullity Absorption (Wheel Annihilator)
-- ============================================================

/-- **Theorem (Nullity is Two-Sided Additive Annihilator)** -/
theorem nullity_absorbs_add (x : Transreal) :
    nullity + x = nullity ∧ x + nullity = nullity :=
  ⟨nullity_add_def x, add_nullity_def x⟩

/-- **Theorem (Nullity is Two-Sided Multiplicative Annihilator)** -/
theorem nullity_absorbs_mul (x : Transreal) :
    nullity * x = nullity ∧ x * nullity = nullity := by
  exact ⟨nullity_mul_def x, mul_nullity_def x⟩

/-- **Theorem (Nullity Division Absorption)** -/
theorem nullity_absorbs_div (x : Transreal) :
    nullity / x = nullity ∧ x / nullity = nullity :=
  ⟨nullity_div_def x, div_nullity_def x⟩

-- ============================================================
-- SECTION 3: Commutativity and Associativity
-- ============================================================

/-- Addition is commutative on ALL transreals. -/
theorem add_comm_transreal (a b : Transreal) : a + b = b + a := by
  rcases a with ( _ | _ | _ | _ ) <;> rcases b with ( _ | _ | _ | _ ) <;> norm_cast
  exact congr_arg _ (add_comm _ _)

/-- Multiplication is commutative on ALL transreals. -/
theorem mul_comm_transreal (a b : Transreal) : a * b = b * a := by
  rcases a with ( _ | _ | _ | _ ) <;> rcases b with ( _ | _ | _ | _ ) <;> norm_cast
  exact congr_arg ofReal (mul_comm _ _)

/-- Zero is an additive identity for finite transreals. -/
theorem zero_add_ofReal (r : ℝ) : (0 : Transreal) + ofReal r = ofReal r := by
  convert Transreal.ofReal_add 0 r using 1; norm_num

/-- One is a multiplicative identity for finite transreals. -/
theorem one_mul_ofReal (r : ℝ) : (1 : Transreal) * ofReal r = ofReal r := by
  convert ofReal_mul 1 r using 1; norm_num

/-- Addition is associative on finite transreals. -/
theorem add_assoc_ofReal (a b c : ℝ) :
    (ofReal a + ofReal b) + ofReal c = ofReal a + (ofReal b + ofReal c) := by
  convert congr_arg _ (add_assoc a b c) using 1

/-- **Theorem (Global Additive Associativity)**: Addition is associative
    on ALL transreals — a surprising result given distributivity fails. -/
theorem add_assoc_transreal (a b c : Transreal) :
    (a + b) + c = a + (b + c) := by
  by_contra! h_assoc
  cases a <;> cases b <;> cases c <;> simp_all +decide
  exact h_assoc (add_assoc _ _ _)

-- ============================================================
-- SECTION 4: Total Division Properties
-- ============================================================

/-- **Theorem (0/0 = Φ)**: The defining equation of transreal arithmetic. -/
theorem zero_div_zero : (0 : Transreal) / 0 = nullity := by
  exact dif_pos rfl |> fun h => h.trans (by simp +decide)

/-- **Theorem (Positive / 0 = +∞)** -/
theorem pos_div_zero (r : ℝ) (hr : r > 0) : ofReal r / (0 : Transreal) = posInf := by
  show tdiv (ofReal r) (ofReal 0) = posInf
  simp [tdiv, hr]

/-- **Theorem (Negative / 0 = -∞)** -/
theorem neg_div_zero (r : ℝ) (hr : r < 0) : ofReal r / (0 : Transreal) = negInf := by
  show tdiv (ofReal r) (ofReal 0) = negInf
  simp [tdiv, hr, show ¬(r > 0) from not_lt.mpr hr.le]

/-- **Theorem (∞ · 0 = Φ)**: Indeterminate form becomes nullity. -/
theorem posInf_mul_zero : posInf * (0 : Transreal) = nullity := by
  show mul posInf (ofReal 0) = nullity
  simp [mul]

/-- **Theorem (Finite nonzero reciprocal)**: For r ≠ 0, ofReal r * ofReal r⁻¹ = 1. -/
theorem finite_reciprocal (r : ℝ) (hr : r ≠ 0) :
    ofReal r * ofReal r⁻¹ = (1 : Transreal) := by
  simp [show ofReal r * ofReal r⁻¹ = ofReal (r * r⁻¹) from ofReal_mul r r⁻¹,
        mul_inv_cancel₀ hr]

-- ============================================================
-- SECTION 5: Determinate Subalgebra
-- ============================================================

/-- **Theorem (Determinate is NOT closed under addition)** -/
theorem determinate_not_closed_add :
    IsDeterminate posInf ∧ IsDeterminate negInf ∧ ¬IsDeterminate (posInf + negInf) :=
  ⟨trivial, trivial, by simp [IsDeterminate]⟩

/-- **Theorem (Finite elements closed under addition)** -/
theorem finite_closed_add (a b : ℝ) : IsFinite (ofReal a + ofReal b) := trivial

-- ============================================================
-- SECTION 6: The Real Embedding
-- ============================================================

/-- **Theorem (ofReal is injective)**: ℝ embeds faithfully. -/
theorem ofReal_injective : Function.Injective ofReal := by
  intro a b hab; injection hab

/-- **Theorem (ofReal is a multiplicative homomorphism)** -/
theorem ofReal_mul_hom (a b : ℝ) : ofReal (a * b) = ofReal a * ofReal b :=
  (ofReal_mul a b).symm

/-
============================================================
SECTION 7: Negation is a Global Additive Homomorphism
============================================================

**Theorem (Negation distributes over addition globally)**:
    -(a + b) = (-a) + (-b) for ALL transreals, not just finite ones.
    This is remarkable because distributivity of × over + fails.
-/
theorem neg_add_global (a b : Transreal) :
    -(a + b) = (-a) + (-b) := by
  rcases a with ( _ | _ | _ | _ ) <;> rcases b with ( _ | _ | _ | _ ) <;> simp +arith +decide [ * ];
  convert add_comm _ _ using 1

/-
============================================================
SECTION 8: Multiplication Associativity (Global)
============================================================

**Theorem (Global Multiplicative Associativity)**:
    (a * b) * c = a * (b * c) for ALL transreals.
    Despite distributivity failing, multiplication retains full associativity.
    The proof requires careful case analysis on all 64 combinations,
    with the sign-dependent cases for mixed real-infinite products.
-/
theorem mul_assoc_transreal (a b c : Transreal) :
    (a * b) * c = a * (b * c) := by
  obtain a | a | a | a := a <;> obtain b | b | b | b := b <;> obtain c | c | c | c := c <;> norm_cast;
  all_goals show Transreal.mul ( Transreal.mul _ _ ) _ = Transreal.mul _ ( Transreal.mul _ _ ) ;
  all_goals simp +decide [ Transreal.mul ];
  any_goals split_ifs <;> simp +decide [ * ];
  · ring;
  · split_ifs <;> simp_all +decide [ mul_pos_iff, mul_neg_iff ];
    · linarith;
    · grind;
    · grind;
    · grind;
  · split_ifs <;> simp_all +decide [ mul_pos_iff, mul_neg_iff ];
    · linarith;
    · grind;
    · grind;
    · grind;
  · split_ifs <;> simp_all +decide [ mul_pos_iff, mul_neg_iff ];
    grind;
    grind;
    · grind;
    · grind;
    · grobner;
    · grind;
    · grind;
  · split_ifs <;> simp_all +decide [ mul_pos_iff, mul_neg_iff ];
    grind; all_goals grind

-- ============================================================
-- SECTION 9: Structural Properties
-- ============================================================

/-- **Theorem (Nullity is the unique total absorber for addition)** -/
theorem nullity_unique_absorber (e : Transreal) :
    (∀ x : Transreal, e + x = e) → e = nullity := by
  cases e
  · intro h; specialize h posInf; simp at h
  · exact fun h => absurd (h negInf) (by simp +decide)
  · intro h; specialize h posInf; simp_all +decide
  · exact fun _ => rfl

/-- **Theorem (Double Negation)**: --x = x for all transreals. -/
theorem neg_neg_transreal (x : Transreal) : -(-x) = x := by
  rcases x with ( _ | _ | _ | _ ) <;> simp +decide

/-- **Theorem (Negation distributes over addition for finite elements)** -/
theorem neg_add_ofReal (a b : ℝ) :
    -(ofReal a + ofReal b) = -ofReal a + -ofReal b := by
  apply congr_arg ofReal; ring

end Transreal