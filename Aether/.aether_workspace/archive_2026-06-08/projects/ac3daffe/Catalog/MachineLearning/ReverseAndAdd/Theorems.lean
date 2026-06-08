/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reverse-and-Add Dynamics: Main Theorems

This file contains the core structural theorems for reverse-and-add dynamics,
including:

- **Theorem A**: Digit reversal is involutive on numbers not divisible by the base
- **Theorem B**: Palindromicity ↔ fixed point of digit reversal
- **Theorem C** (corrected): `n + rev(n)` is congruent to `2n` mod `b-1`
  (the original claim of base-10 evenness is false: 196 + 691 = 887 is odd)
- **Theorem D/E**: Modular congruence of iterates: `revAddIter b k n ≡ 2^k · n [MOD b-1]`
- **Monotonicity**: `n ≤ revAddStep b n` and `n ≤ revAddIter b k n`
- **Theorem F**: Finite horizon non-palindrome principle
-/

import Mathlib
import Speculative.ReverseAndAdd.Defs

namespace ReverseAndAdd

open Nat

/-! ## Theorem B: Palindrome ↔ Fixed Point of Digit Reversal -/

/-
**Theorem B.** A number is a base-`b` palindrome if and only if it is a
    fixed point of digit reversal. This is the fundamental observation that
    converts "eventually reaches a palindrome" into "eventually reaches a
    fixed point of an involution."
-/
theorem isPalindromeBase_iff_reverseDigits_eq
    (b n : Nat) (hb : 2 ≤ b) :
    isPalindromeBase b n ↔ reverseDigits b n = n := by
  by_cases h_zero : n = 0 <;> simp_all +decide [ ReverseAndAdd.reverseDigits, ReverseAndAdd.isPalindromeBase ];
  constructor <;> intro h;
  · rw [ ← h, Nat.ofDigits_digits ];
  · have h_digits_eq : Nat.digits b (Nat.ofDigits b (Nat.digits b n).reverse) = (Nat.digits b n).reverse := by
      rw [ Nat.digits_ofDigits ];
      · linarith;
      · exact fun l hl => Nat.digits_lt_base hb <| List.mem_reverse.mp hl;
      · rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.div_eq_of_lt ];
        · grobner;
        · intro H; have := Nat.dvd_of_mod_eq_zero H; rcases this with ⟨ k, hk ⟩ ; simp_all +decide [ Nat.ofDigits_append, Nat.ofDigits_singleton ] ;
          rcases b with ( _ | _ | b ) <;> simp_all +decide [ Nat.ofDigits_eq_foldr ];
          have h_foldl_lt : ∀ (L : List ℕ), (∀ d ∈ L, d < b + 2) → List.foldl (fun x y => y + (b + 2) * x) 0 L < (b + 2) ^ L.length := by
            intro L hL; induction' L using List.reverseRecOn with d L ih <;> simp_all +decide [ pow_succ' ] ;
            nlinarith [ hL L ( Or.inr rfl ) ];
          have := h_foldl_lt ( Nat.digits ( b + 2 ) k ) ( fun d hd => Nat.digits_lt_base' hd ) ; simp_all +decide [ Nat.pow_succ' ];
          rw [ Nat.digits_len ] at this <;> try linarith;
          · rw [ Nat.pow_succ ] at this ; nlinarith [ Nat.pow_log_le_self ( b + 2 ) ( by aesop_cat : k ≠ 0 ) ];
          · rintro rfl; linarith;
    grind

/-! ## Reverse preserves digit sum -/

/-
The digit sum is preserved under reversal of the digit list.
-/
theorem digitSum_reverse (b n : Nat) :
    (digitsBase b n).reverse.sum = (digitsBase b n).sum := by
  grind

/-! ## Key modular lemma: n ≡ digit_sum(n) [MOD b-1] -/

/-
For base `b ≥ 2`, a natural number is congruent to the sum of its
    base-`b` digits modulo `b - 1`. This is the generalization of the
    classical "casting out nines" rule.
-/
theorem ofDigits_mod_base_pred (b : Nat) (hb : 2 ≤ b) (l : List Nat) :
    Nat.ofDigits b l % (b - 1) = l.sum % (b - 1) := by
  induction l <;> simp +decide [ *, Nat.ofDigits ];
  cases b <;> simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ]

/-
A number equals `ofDigits` applied to its digits.
-/
theorem n_eq_ofDigits (b n : Nat) :
    n = Nat.ofDigits b (Nat.digits b n) := by
  exact Eq.symm ( Nat.ofDigits_digits b n )

/-
Digit reversal preserves congruence mod `b - 1`.
-/
theorem reverseDigits_congr_mod_base_pred
    (b n : Nat) (hb : 2 ≤ b) :
    reverseDigits b n ≡ n [MOD (b - 1)] := by
  have h_congr : n % (b - 1) = (digitsBase b n).sum % (b - 1) := by
    convert ofDigits_mod_base_pred b hb ( Nat.digits b n ) using 1;
    rw [ Nat.ofDigits_digits ];
  exact Nat.ModEq.trans ( ofDigits_mod_base_pred _ hb _ ) ( digitSum_reverse _ _ ▸ h_congr.symm )

/-! ## Theorem D: revAddStep ≡ 2n [MOD b-1] -/

/-
**Theorem D.** One step of reverse-and-add doubles the residue modulo `b - 1`.
    Since digit reversal preserves congruence mod `b - 1`, we get
    `n + rev(n) ≡ n + n = 2n [MOD b-1]`.
-/
theorem revAddStep_congr_mod_base_pred
    (b n : Nat) (hb : 2 ≤ b) :
    revAddStep b n ≡ 2 * n [MOD (b - 1)] := by
  convert Nat.ModEq.add ( Nat.ModEq.refl n ) ( reverseDigits_congr_mod_base_pred b n hb ) using 1 ; ring

/-! ## Theorem E: Iterate congruence law -/

/-
**Theorem E.** After `k` iterations of reverse-and-add, the result is
    congruent to `2^k · n` modulo `b - 1`. This converts the nonlinear
    digit algorithm into a linear congruence dynamic — the first major
    bridge theorem between arithmetic dynamics and algebra.
-/
theorem revAddIter_congr_mod_base_pred
    (b n k : Nat) (hb : 2 ≤ b) :
    revAddIter b k n ≡ (2^k * n) [MOD (b - 1)] := by
  induction' k with k ih;
  · simp +decide [ revAddIter ];
    rfl;
  · convert Nat.ModEq.trans ( revAddStep_congr_mod_base_pred b ( revAddIter b k n ) hb ) ( ih.mul_left 2 ) using 1 ; ring;
    · exact Function.iterate_succ_apply' ( revAddStep b ) k n ▸ by ac_rfl;
    · ring

/-! ## Monotonicity -/

/-
Every reverse-and-add step is non-decreasing.
-/
theorem n_le_revAddStep (b n : Nat) :
    n ≤ revAddStep b n := by
  exact le.intro rfl

/-
Iterates of reverse-and-add are non-decreasing.
-/
theorem n_le_revAddIter (b k n : Nat) :
    n ≤ revAddIter b k n := by
  exact Nat.recOn k ( by rfl ) fun k ih => by rw [ revAddIter_succ ] ; exact le_trans ih ( n_le_revAddStep _ _ ) ;

/-! ## Theorem A: Involutivity with normalization -/

/-
**Theorem A.** Digit reversal is involutive on numbers whose least significant
    digit is nonzero (equivalently, numbers not divisible by the base, plus zero).
    This identifies reverse-and-add as a genuine dynamical system.
-/
theorem reverseDigits_involutive_of_not_dvd
    (b n : Nat) (hb : 2 ≤ b) (hnd : n % b ≠ 0 ∨ n = 0) :
    reverseDigits b (reverseDigits b n) = n := by
  cases n <;> simp_all +decide [ reverseDigits ];
  rw [ Nat.digits_ofDigits ] <;> norm_num;
  · simp +arith +decide [ ofDigits, Nat.mod_add_div ];
    rw [ Nat.ofDigits_digits, Nat.mod_add_div ];
  · linarith;
  · rintro l ( hl | rfl ) <;> [ exact Nat.digits_lt_base hb hl; exact Nat.mod_lt _ ( by positivity ) ];
  · assumption

/-! ## Theorem F: Finite horizon non-palindrome principle -/

/-
**Theorem F.** If the residue of each iterate modulo `m` differs from the residue
    of `n` at that step, then no iterate in the horizon is a palindrome.
    This is stated in a simplified but still useful form: if the iterate's residue
    mod `m` is different from the iterate itself, the iterate is certainly not a
    palindrome (because a palindrome equals its reverse, hence equals itself mod m).
-/
theorem finite_horizon_nonpalindrome
    (b : Nat) (hb : 2 ≤ b) (n : Nat) (K : Nat)
    (m : Nat) (_hm : 0 < m)
    (hres : ∀ k ≤ K, revAddIter b k n % m ≠ reverseDigits b (revAddIter b k n) % m) :
    ∀ k ≤ K, ¬ isPalindromeBase b (revAddIter b k n) := by
  intro k hk hres; simp_all +decide [ isPalindromeBase_iff_reverseDigits_eq ] ;
  exact ‹∀ k ≤ K, ¬revAddIter b k n % m = reverseDigits b (revAddIter b k n) % m› k hk ( hres.symm ▸ rfl )

/-! ## Carry Automaton Definition and Theorem G -/

/-- Given a list of digit pairs `(aᵢ, bᵢ)` and carry-in `c`, compute the
    resulting number by processing addition with carries from least significant
    to most significant digit. Returns the final number. -/
def carryAdd (b : Nat) : List (Nat × Nat) → Nat → Nat
  | [], c => c
  | (a, d) :: rest, c =>
    let s := a + d + c
    (s % b) + b * carryAdd b rest (s / b)

/-- The carry automaton evaluation: add `n` to its digit-reversal by processing
    digit pairs with carry propagation. -/
def carryAutomatonEval (b : Nat) (digits : List Nat) : Nat :=
  carryAdd b (digits.zip digits.reverse) 0

/-
**Theorem G.** The arithmetic `revAddStep b n` agrees with the carry automaton
    evaluation on the digits of `n`. This is the portal to automata theory
    and symbolic dynamics.
-/
theorem revAddStep_eq_carryAutomaton_eval
    (b n : Nat) (_hb : 2 ≤ b) :
    revAddStep b n = carryAutomatonEval b (digitsBase b n) := by
  -- By definition of `carryAdd`, we have:
  have h_carryAdd : ∀ (l : List (Nat × Nat)) (c : Nat), carryAdd b l c = Nat.ofDigits b (List.map Prod.fst l) + Nat.ofDigits b (List.map Prod.snd l) + c := by
    intro l c;
    induction' l with l_head l_tail ih generalizing c <;> simp +arith +decide [ *, Nat.ofDigits ];
    · rfl;
    · rw [ show carryAdd b ( l_head :: l_tail ) c = ( l_head.1 + l_head.2 + c ) % b + b * carryAdd b l_tail ( ( l_head.1 + l_head.2 + c ) / b ) by rfl, ih ] ; ring;
      linarith [ Nat.mod_add_div ( l_head.1 + l_head.2 + c ) b ];
  convert h_carryAdd ( digitsBase b n |> List.zip <| ( digitsBase b n |> List.reverse ) ) 0 |> Eq.symm using 1;
  unfold revAddStep;
  unfold reverseDigits; simp +decide [ digitsBase ] ;
  rw [ show List.map Prod.fst ( List.zip ( Nat.digits b n ) ( List.reverse ( Nat.digits b n ) ) ) = Nat.digits b n from ?_, show List.map Prod.snd ( List.zip ( Nat.digits b n ) ( List.reverse ( Nat.digits b n ) ) ) = List.reverse ( Nat.digits b n ) from ?_ ];
  · rw [ Nat.ofDigits_digits ];
  · refine' List.ext_get _ _ <;> aesop;
  · refine' List.ext_get _ _ <;> aesop

end ReverseAndAdd