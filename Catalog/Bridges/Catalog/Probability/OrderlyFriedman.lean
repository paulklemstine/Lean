/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Orderly Friedman numbers (OEIS A080035)

A *Friedman number* is a positive integer that can be written, in a nontrivial
way, as an expression using its own digits (each digit used exactly once, in any
order) together with the operations `+`, `*`, exponentiation, unary minus and
parentheses.  An *orderly* Friedman number (OEIS A080035) is a Friedman number
admitting such an expression in which the digits appear in their natural reading
order (most-significant first).

This file formalizes orderly Friedman numbers.  We model digit expressions by an
inductive type `FExpr` over a small set of binary operations `FOp`
(`add`, `mul`, `pow`), with unary negation and single-digit literals.  We define
`eval` (the integer value of an expression), `digitSeq` (the left-to-right
sequence of digit literals) and `numLits` (the number of digit literals).

The predicate `IsOrderlyFriedman n` asks for an expression with at least two
digit literals whose digit sequence equals the digits of `n` in reading order
(`(Nat.digits 10 n).reverse`) and which evaluates to `n`.  The predicate
`IsFriedman n` only requires the digit sequence to be a permutation of the digits
of `n`.

Main results:
* five explicit witnesses (`127`, `343`, `736`, `1285`, `2592`);
* `numLits_eq_length`: `numLits e = (digitSeq e).length`;
* `orderlyFriedman_ge_ten`: orderly Friedman numbers have at least two digits;
* `no_two_digit_orderlyFriedman`: there are no two-digit orderly Friedman numbers;
* `orderly_imp_friedman`: every orderly Friedman number is a Friedman number;
* `digits_in_order`: the defining expression has its digits in reading order.
-/
import Mathlib

namespace OrderlyFriedman

/-- The binary operations allowed in digit expressions. -/
inductive FOp
  | add
  | mul
  | pow
  deriving DecidableEq, Repr

/-- Digit expressions: single-digit literals, unary negation and binary
operations. -/
inductive FExpr
  | lit (d : Nat)
  | neg (e : FExpr)
  | bin (op : FOp) (l r : FExpr)
  deriving Repr

/-- Apply a binary operation to two integers.  Exponentiation uses the
natural-number truncation of the exponent. -/
def FOp.apply : FOp → Int → Int → Int
  | FOp.add, a, b => a + b
  | FOp.mul, a, b => a * b
  | FOp.pow, a, b => a ^ b.toNat

/-- The integer value of a digit expression. -/
def eval : FExpr → Int
  | FExpr.lit d => (d : Int)
  | FExpr.neg e => - eval e
  | FExpr.bin op l r => op.apply (eval l) (eval r)

/-- The left-to-right sequence of digit literals occurring in an expression. -/
def digitSeq : FExpr → List Nat
  | FExpr.lit d => [d]
  | FExpr.neg e => digitSeq e
  | FExpr.bin _ l r => digitSeq l ++ digitSeq r

/-- The number of digit literals in an expression. -/
def numLits : FExpr → Nat
  | FExpr.lit _ => 1
  | FExpr.neg e => numLits e
  | FExpr.bin _ l r => numLits l + numLits r

/-- `n` is an *orderly Friedman number*: it can be written using its own digits,
in reading order, with at least two digit literals. -/
def IsOrderlyFriedman (n : Nat) : Prop :=
  ∃ e : FExpr, numLits e ≥ 2 ∧ digitSeq e = (Nat.digits 10 n).reverse ∧ eval e = (n : Int)

/-- `n` is a *Friedman number*: it can be written using its own digits, in any
order, with at least two digit literals. -/
def IsFriedman (n : Nat) : Prop :=
  ∃ e : FExpr, numLits e ≥ 2 ∧ (digitSeq e).Perm (Nat.digits 10 n) ∧ eval e = (n : Int)

/-! ## Explicit witnesses -/

/-- `127 = -1 + 2^7`. -/
theorem orderlyFriedman_127 : IsOrderlyFriedman 127 :=
  ⟨FExpr.bin FOp.add (FExpr.neg (FExpr.lit 1))
      (FExpr.bin FOp.pow (FExpr.lit 2) (FExpr.lit 7)), by native_decide⟩

/-- `343 = (3 + 4)^3`. -/
theorem orderlyFriedman_343 : IsOrderlyFriedman 343 :=
  ⟨FExpr.bin FOp.pow (FExpr.bin FOp.add (FExpr.lit 3) (FExpr.lit 4))
      (FExpr.lit 3), by native_decide⟩

/-- `736 = 7 + 3^6`. -/
theorem orderlyFriedman_736 : IsOrderlyFriedman 736 :=
  ⟨FExpr.bin FOp.add (FExpr.lit 7)
      (FExpr.bin FOp.pow (FExpr.lit 3) (FExpr.lit 6)), by native_decide⟩

/-- `1285 = (1 + 2^8) * 5`.

(The informal description `1 * 2^8 + 5` does not evaluate to `1285`; the correct
reading-order expression is `(1 + 2^8) * 5 = 257 * 5 = 1285`.) -/
theorem orderlyFriedman_1285 : IsOrderlyFriedman 1285 :=
  ⟨FExpr.bin FOp.mul
      (FExpr.bin FOp.add (FExpr.lit 1) (FExpr.bin FOp.pow (FExpr.lit 2) (FExpr.lit 8)))
      (FExpr.lit 5), by native_decide⟩

/-- `2592 = 2^5 * 9^2`. -/
theorem orderlyFriedman_2592 : IsOrderlyFriedman 2592 :=
  ⟨FExpr.bin FOp.mul (FExpr.bin FOp.pow (FExpr.lit 2) (FExpr.lit 5))
      (FExpr.bin FOp.pow (FExpr.lit 9) (FExpr.lit 2)), by native_decide⟩

/-! ## Structural lemmas -/

/-- The number of digit literals equals the length of the digit sequence. -/
theorem numLits_eq_length (e : FExpr) : numLits e = (digitSeq e).length := by
  induction e with
  | lit d => rfl
  | neg e ih => simpa [numLits, digitSeq] using ih
  | bin op l r ihl ihr => simp [numLits, digitSeq, ihl, ihr]

/-- Every expression has at least one digit literal. -/
theorem numLits_pos (e : FExpr) : 1 ≤ numLits e := by
  induction e with
  | lit d => simp [numLits]
  | neg e ih => simpa [numLits] using ih
  | bin op l r ihl ihr => simp [numLits]; omega

/-- An expression with a single digit literal evaluates to plus or minus that
digit. -/
theorem single_leaf (e : FExpr) (h1 : numLits e = 1) :
    ∃ d : Nat, digitSeq e = [d] ∧ (eval e = (d : Int) ∨ eval e = -(d : Int)) := by
  induction e with
  | lit d => exact ⟨d, rfl, Or.inl rfl⟩
  | neg e ih =>
      obtain ⟨d, hd, hv⟩ := ih (by simpa [numLits] using h1)
      refine ⟨d, by simpa [digitSeq] using hd, ?_⟩
      rcases hv with hv | hv
      · exact Or.inr (by simp [eval, hv])
      · exact Or.inl (by simp [eval, hv])
  | bin op l r ihl ihr =>
      exfalso
      have hl := numLits_pos l
      have hr := numLits_pos r
      simp [numLits] at h1
      omega

/-- A value `v` is *reachable* from two digits `a`, `b` (in this order) if it can
be obtained by combining `±a` and `±b` with one operation and an outer sign. -/
def reachable2 (a b : Nat) (v : Int) : Prop :=
  ∃ s0 s1 s2 : Bool,
      v = (if s0 then -1 else 1) *
            ((if s1 then -(a : Int) else (a : Int)) + (if s2 then -(b : Int) else (b : Int)))
    ∨ v = (if s0 then -1 else 1) *
            ((if s1 then -(a : Int) else (a : Int)) * (if s2 then -(b : Int) else (b : Int)))
    ∨ v = (if s0 then -1 else 1) *
            ((if s1 then -(a : Int) else (a : Int)) ^ (if s2 then -(b : Int) else (b : Int)).toNat)

instance (a b : Nat) (v : Int) : Decidable (reachable2 a b v) := by
  unfold reachable2
  infer_instance

/-- Combining `x = ±a` and `y = ±b` with any operation yields a reachable value. -/
theorem reachable2_of (a b : Nat) (x y : Int) (op : FOp)
    (hx : x = (a : Int) ∨ x = -(a : Int)) (hy : y = (b : Int) ∨ y = -(b : Int)) :
    reachable2 a b (op.apply x y) := by
  obtain ⟨s1, hx⟩ : ∃ s1 : Bool, x = if s1 then -(a : Int) else (a : Int) := by
    rcases hx with h | h
    · exact ⟨false, by simp [h]⟩
    · exact ⟨true, by simp [h]⟩
  obtain ⟨s2, hy⟩ : ∃ s2 : Bool, y = if s2 then -(b : Int) else (b : Int) := by
    rcases hy with h | h
    · exact ⟨false, by simp [h]⟩
    · exact ⟨true, by simp [h]⟩
  refine ⟨false, s1, s2, ?_⟩
  subst hx; subst hy
  cases op
  · exact Or.inl (by simp [FOp.apply])
  · exact Or.inr (Or.inl (by simp [FOp.apply]))
  · exact Or.inr (Or.inr (by simp [FOp.apply]))

/-- Reachable values are closed under negation. -/
theorem reachable2_neg (a b : Nat) (v : Int) (h : reachable2 a b v) :
    reachable2 a b (-v) := by
  obtain ⟨s0, s1, s2, h⟩ := h
  refine ⟨!s0, s1, s2, ?_⟩
  have hsgn : (if !s0 then (-1 : Int) else 1) = -(if s0 then (-1 : Int) else 1) := by
    cases s0 <;> rfl
  rcases h with h | h | h
  · exact Or.inl (by rw [h, hsgn]; ring)
  · exact Or.inr (Or.inl (by rw [h, hsgn]; ring))
  · exact Or.inr (Or.inr (by rw [h, hsgn]; ring))

/-- The value of any expression with exactly two digit literals `[a, b]` is
reachable from `a` and `b`. -/
theorem eval_numLits_two (e : FExpr) (a b : Nat) (h2 : numLits e = 2)
    (hd : digitSeq e = [a, b]) : reachable2 a b (eval e) := by
  induction e with
  | lit d => simp [numLits] at h2
  | neg e ih =>
      have h2' : numLits e = 2 := by simpa [numLits] using h2
      have hd' : digitSeq e = [a, b] := by simpa [digitSeq] using hd
      have hrec := ih h2' hd'
      have hev : eval (FExpr.neg e) = - eval e := rfl
      rw [hev]
      exact reachable2_neg a b (eval e) hrec
  | bin op l r ihl ihr =>
      -- both sides are single leaves
      have hl1 : numLits l = 1 := by
        have := numLits_pos l; have := numLits_pos r
        simp [numLits] at h2; omega
      have hr1 : numLits r = 1 := by
        have := numLits_pos l; have := numLits_pos r
        simp [numLits] at h2; omega
      obtain ⟨da, hda, hva⟩ := single_leaf l hl1
      obtain ⟨db, hdb, hvb⟩ := single_leaf r hr1
      have hsplit : [da, db] = [a, b] := by
        have : digitSeq (FExpr.bin op l r) = [da, db] := by simp [digitSeq, hda, hdb]
        rw [this] at hd; exact hd
      have hda' : da = a := by simpa using congrArg (·.headI) hsplit
      have hdb' : db = b := by
        have := congrArg (·.tail) hsplit
        simpa using this
      have hev : eval (FExpr.bin op l r) = op.apply (eval l) (eval r) := rfl
      rw [hev, ← hda', ← hdb']
      exact reachable2_of da db (eval l) (eval r) op hva hvb

/-- Orderly Friedman numbers have at least two digits. -/
theorem orderlyFriedman_ge_ten {n : Nat} (h : IsOrderlyFriedman n) : n ≥ 10 := by
  obtain ⟨e, hlits, hdig, _⟩ := h
  have hlen : 2 ≤ (digitSeq e).length := by
    rw [← numLits_eq_length]; exact hlits
  rw [hdig, List.length_reverse] at hlen
  by_contra hlt
  push_neg at hlt
  interval_cases n <;> simp_all

/-- For valid two-digit data `a, b` (with `1 ≤ a ≤ 9`, `b ≤ 9`), the number
`10*a + b` is not reachable from `a` and `b`. -/
theorem not_reachable2 (a b : Nat) (ha : 1 ≤ a) (ha9 : a ≤ 9) (hb : b ≤ 9) :
    ¬ reachable2 a b (10 * a + b) := by
  interval_cases a <;> interval_cases b <;> decide

/-- There are no two-digit orderly Friedman numbers. -/
theorem no_two_digit_orderlyFriedman {n : Nat} (hlo : 10 ≤ n) (hhi : n < 100) :
    ¬ IsOrderlyFriedman n := by
  rintro ⟨e, hlits, hdig, heval⟩
  -- digits of a two-digit number
  have hdigits : Nat.digits 10 n = [n % 10, n / 10] := by
    have e1 : Nat.digits 10 n = n % 10 :: Nat.digits 10 (n / 10) :=
      Nat.digits_def' (by norm_num) (by omega)
    have e2 : Nat.digits 10 (n / 10) = (n / 10) % 10 :: Nat.digits 10 (n / 10 / 10) :=
      Nat.digits_def' (by norm_num) (by omega)
    have h0 : n / 10 / 10 = 0 := by omega
    have hmod : (n / 10) % 10 = n / 10 := Nat.mod_eq_of_lt (by omega)
    rw [e1, e2, h0, hmod]
    simp
  have hd : digitSeq e = [n / 10, n % 10] := by
    rw [hdig, hdigits]; rfl
  have h2 : numLits e = 2 := by
    rw [numLits_eq_length, hd]; rfl
  have hr : reachable2 (n / 10) (n % 10) (eval e) :=
    eval_numLits_two e (n / 10) (n % 10) h2 hd
  rw [heval] at hr
  have hn : (n : Int) = 10 * (n / 10 : Nat) + (n % 10 : Nat) := by
    have := Nat.div_add_mod n 10
    push_cast
    omega
  rw [hn] at hr
  exact not_reachable2 (n / 10) (n % 10) (by omega) (by omega) (by omega) hr

/-- Every orderly Friedman number is a Friedman number. -/
theorem orderly_imp_friedman {n : Nat} (h : IsOrderlyFriedman n) : IsFriedman n := by
  obtain ⟨e, hlits, hdig, heval⟩ := h
  refine ⟨e, hlits, ?_, heval⟩
  rw [hdig]
  exact List.reverse_perm _

/-- The defining property of an orderly Friedman number, made explicit: there is
an expression whose digit sequence is exactly the digits of `n` in natural
reading order (most-significant first), with at least two digit literals,
evaluating to `n`. -/
theorem digits_in_order {n : Nat} (h : IsOrderlyFriedman n) :
    ∃ e : FExpr, digitSeq e = (Nat.digits 10 n).reverse ∧ eval e = (n : Int) ∧
      numLits e ≥ 2 := by
  obtain ⟨e, hlits, hdig, heval⟩ := h
  exact ⟨e, hdig, heval, hlits⟩

end OrderlyFriedman