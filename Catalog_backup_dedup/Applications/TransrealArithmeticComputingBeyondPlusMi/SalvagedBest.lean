theorem no_additive_inverse_posInf : ¬ ∃ y : Transreal, posInf + y = 0 := by
  rintro ⟨ y, hy ⟩;
  rcases y with ( _ | _ | _ | _ ) <;> simp +decide at hy

example : (posInf : Transreal) + negInf ≠ 0 := by
  simp [HAdd.hAdd, Add.add, add, zero_eq]

/-
!-- Theorem 5: Distributivity fails. Take a = posInf, b = ofReal 1, c = negInf.
LHS: ofReal 1 + negInf = negInf, posInf * negInf = negInf.
RHS: posInf * ofReal 1 = posInf (since 1 > 0), posInf * negInf = negInf,
posInf + negInf = nullity. So LHS = negInf ≠ nullity = RHS. -- !--

**Theorem 5 (PEGB)**: Distributivity fails in the transreals.
    *Example*: posInf * (1 + negInf) = negInf, but posInf * 1 + posInf * negInf = nullity.
    *Generalization*: Fails whenever an infinite element multiplies a sum
    that "changes character" (finite + infinite).
    *Boundary*: Distributivity DOES hold on the real sub-semiring.
-/

theorem distrib_counterexample :
    posInf * (ofReal 1 + negInf) ≠ posInf * ofReal 1 + posInf * negInf := by
      -- By definition of multiplication in the transreals, we have:
      have h1 : posInf * ofReal 1 = posInf := by
        exact if_pos zero_lt_one
      have h2 : posInf * negInf = negInf := by
        rfl
      have h3 : posInf + negInf = nullity := by
        rfl
      rw [h1, h2, h3];
      rw [ add_comm ] ; aesop;

/-
!-- Theorem 6: Additive cancellation fails. Take a = ofReal 1, b = ofReal 2,
c = posInf. Then a + c = posInf = b + c, but ofReal 1 ≠ ofReal 2. -- !--

**Theorem 6 (PEGB)**: Additive cancellation fails for infinite elements.
    *Example*: ofReal 1 + posInf = posInf = ofReal 2 + posInf, but ofReal 1 ≠ ofReal 2.
    *Generalization*: Cancellation fails whenever the "dominant" summand is infinite.
    *Boundary*: Cancellation DOES hold when restricted to real-valued elements.
-/

theorem cancel_fails :
    ∃ a b c : Transreal, a + c = b + c ∧ a ≠ b := by
      exact ⟨ ofReal 1, ofReal 2, posInf, by aesop, by simp +decide ⟩

/-
!-- Theorem 7: Negation is an involution. By cases: ofReal uses neg_neg for ℝ;
posInf ↦ negInf ↦ posInf; negInf ↦ posInf ↦ negInf; nullity ↦ nullity ↦ nullity. -- !--

**Theorem 7 (PEGB)**: Negation is an involution on all transreals.
    *Example*: --posInf = -negInf = posInf. --nullity = -nullity = nullity.
    *Generalization*: This survives from ℝ to the full transreal system.
    *Boundary*: Despite being an involution, negation does NOT provide
    additive inverses for non-real elements.
-/