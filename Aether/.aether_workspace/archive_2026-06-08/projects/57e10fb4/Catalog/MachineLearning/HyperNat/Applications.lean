/-
  # Applications: Classical Arithmetic Theorems in HyperNat

  This file demonstrates the transfer principle by transporting concrete
  number-theoretic identities from ℕ to HyperNat.
-/

import Mathlib
import Speculative.HyperNat.Basic
import Speculative.HyperNat.Transfer

open HyperNat

/-! ## Application 1: Core Polynomial Identity

  n * (n + 1) = n² + n, transported to HyperNat.
-/

theorem nat_identity_1 (n : ℕ) : n * (n + 1) = n * n + n := by ring

theorem hyper_identity_1 (x : HyperNat) : x * (x + ofNat' 1) = x * x + x := by
  induction x using Quotient.ind with
  | _ f =>
    apply Quotient.sound
    exact ⟨0, fun n _ => nat_identity_1 (f n)⟩

/-! ## Application 2: Square of Sum

  (a + b)² = a² + 2ab + b², transported to HyperNat.
-/

theorem nat_square_sum (a b : ℕ) :
    (a + b) * (a + b) = a * a + (a * b + a * b) + b * b := by ring

theorem hyper_square_sum (x y : HyperNat) :
    (x + y) * (x + y) = x * x + (x * y + x * y) + y * y := by
  induction x using Quotient.ind with
  | _ f =>
    induction y using Quotient.ind with
    | _ g =>
      apply Quotient.sound
      exact ⟨0, fun n _ => nat_square_sum (f n) (g n)⟩

/-! ## Application 3: Gauss Triangular Number Formula

  2 * T(n) = n * (n + 1) where T(n) = 0 + 1 + ... + n.
-/

def triangular : ℕ → ℕ
  | 0 => 0
  | n + 1 => triangular n + (n + 1)

theorem gauss_formula (n : ℕ) : 2 * triangular n = n * (n + 1) := by
  induction n with
  | zero => simp [triangular]
  | succ n ih => simp [triangular]; linarith

/-- EventuallyEq respects pointwise application of any function. -/
theorem EventuallyEq_map (F : ℕ → ℕ) {f g : ℕ → ℕ}
    (h : EventuallyEq f g) :
    EventuallyEq (fun n => F (f n)) (fun n => F (g n)) := by
  obtain ⟨N, hN⟩ := h
  exact ⟨N, fun n hn => by simp [hN n hn]⟩

/-- The hypernatural triangular number function. -/
noncomputable def hyperTriangular : HyperNat → HyperNat :=
  Quotient.lift (fun f => (⟦fun n => triangular (f n)⟧ : HyperNat))
    (fun _ _ h => Quotient.sound (EventuallyEq_map triangular h))

theorem hyperTriangular_repr (f : ℕ → ℕ) :
    hyperTriangular ⟦f⟧ = ⟦fun n => triangular (f n)⟧ := rfl

/-- The Gauss formula transfers to HyperNat:
    2 * T(x) = x * (x + 1) for all hypernatural x. -/
theorem hyper_gauss_formula (x : HyperNat) :
    ofNat' 2 * hyperTriangular x = x * (x + ofNat' 1) := by
  induction x using Quotient.ind with
  | _ f =>
    show ⟦fun n => 2 * triangular (f n)⟧ = ⟦fun n => f n * (f n + 1)⟧
    apply Quotient.sound
    exact ⟨0, fun n _ => gauss_formula (f n)⟩

/-! ## Application 4: Expansion Identity -/

theorem nat_expand_sq_sum (a b : ℕ) :
    (a * a + (b * b + b * b)) * (a * a + (b * b + b * b)) =
    a * a * (a * a) + (a * a * (b * b + b * b) + a * a * (b * b + b * b)) +
    (b * b + b * b) * (b * b + b * b) := by ring

theorem hyper_expand_sq_sum (x y : HyperNat) :
    (x * x + (y * y + y * y)) * (x * x + (y * y + y * y)) =
    x * x * (x * x) + (x * x * (y * y + y * y) + x * x * (y * y + y * y)) +
    (y * y + y * y) * (y * y + y * y) := by
  induction x using Quotient.ind with
  | _ f =>
    induction y using Quotient.ind with
    | _ g =>
      apply Quotient.sound
      exact ⟨0, fun n _ => nat_expand_sq_sum (f n) (g n)⟩

/-! ## Application 5: Transfer of Divisibility -/

theorem hyper_dvd_mul_right (x y : HyperNat) : HyperNat.hdvd x (x * y) := by
  induction x using Quotient.ind with
  | _ f =>
    induction y using Quotient.ind with
    | _ g =>
      exact ⟨0, fun n _ => Dvd.intro (g n) rfl⟩

/-! ## Application 6: The Fundamental Correspondence

  Eventual equality of sequences ↔ equality of their HyperNat classes.
-/

theorem eventual_eq_iff_hyper_eq (f g : ℕ → ℕ) :
    (∃ N, ∀ n, N ≤ n → f n = g n) ↔ (mk f = mk g) :=
  ⟨fun h => Quotient.sound h, fun h => Quotient.exact h⟩

/-! ## Application 7: Eventual Divisibility Correspondence -/

theorem eventual_dvd_iff_hyper_dvd (f g : ℕ → ℕ) :
    (∃ N, ∀ n, N ≤ n → f n ∣ g n) ↔ HyperNat.hdvd (mk f) (mk g) :=
  Iff.rfl

/-! ## Application 8: omega² strictly dominates omega -/

theorem omega_lt_omega_sq : le omega (omega * omega) ∧ ¬ le (omega * omega) omega := by
  constructor
  · exact ⟨1, fun n hn => Nat.le_mul_of_pos_left n hn⟩
  · intro ⟨N, hN⟩
    have := hN (N + 2) (by omega)
    simp [id] at this

/-! ## Application 9: Sum of Squares Formula

  6 * (1² + 2² + ... + n²) = n(n+1)(2n+1)
-/

def sumSquares : ℕ → ℕ
  | 0 => 0
  | n + 1 => sumSquares n + (n + 1) * (n + 1)

theorem sum_squares_formula (n : ℕ) :
    6 * sumSquares n = n * (n + 1) * (2 * n + 1) := by
  induction n with
  | zero => simp [sumSquares]
  | succ n ih => simp [sumSquares]; nlinarith

noncomputable def hyperSumSquares : HyperNat → HyperNat :=
  Quotient.lift (fun f => (⟦fun n => sumSquares (f n)⟧ : HyperNat))
    (fun _ _ h => Quotient.sound (EventuallyEq_map sumSquares h))

/-- The sum of squares formula transfers to HyperNat:
    6 * S(x) = x * (x + 1) * (2x + 1) for all hypernatural x. -/
theorem hyper_sum_squares_formula (x : HyperNat) :
    ofNat' 6 * hyperSumSquares x =
    x * (x + ofNat' 1) * (ofNat' 2 * x + ofNat' 1) := by
  induction x using Quotient.ind with
  | _ f =>
    show ⟦fun n => 6 * sumSquares (f n)⟧ =
      ⟦fun n => f n * (f n + 1) * (2 * f n + 1)⟧
    apply Quotient.sound
    exact ⟨0, fun n _ => sum_squares_formula (f n)⟩

/-! ## Application 10: Eventual Domination (Big-O) Transfer -/

theorem eventual_le_transfer {f g : ℕ → ℕ} {c : ℕ}
    (h : ∃ N, ∀ n, N ≤ n → f n ≤ c * g n) :
    le (mk f) (ofNat' c * mk g) := by
  obtain ⟨N, hN⟩ := h
  exact ⟨N, fun n hn => hN n hn⟩

/-! ## Application 11: Using the ArithTerm Transfer Engine

  Demonstrate the syntactic transfer: x * (x + 1) * (x + 2) is the
  same in ℕ and HyperNat, proved purely by the transfer theorem.
-/

/-- The polynomial x(x+1)(x+2) = x³ + 3x² + 2x, as an ArithTerm. -/
private def t_lhs : ArithTerm :=
  .mul (.mul .var (.add .var (.const 1))) (.add .var (.const 2))

private def t_rhs : ArithTerm :=
  .add (.add (.mul (.mul .var .var) .var) (.mul (.const 3) (.mul .var .var)))
       (.mul (.const 2) .var)

/-- The identity x(x+1)(x+2) = x³ + 3x² + 2x holds over ℕ. -/
theorem nat_triple_product (n : ℕ) :
    t_lhs.evalNat n = t_rhs.evalNat n := by
  simp [t_lhs, t_rhs, ArithTerm.evalNat]; ring

/-- The same identity holds over HyperNat, by the transfer theorem. -/
theorem hyper_triple_product :
    ∀ x : HyperNat, t_lhs.evalHyper x = t_rhs.evalHyper x :=
  ArithTerm.transfer_arith_eq t_lhs t_rhs nat_triple_product