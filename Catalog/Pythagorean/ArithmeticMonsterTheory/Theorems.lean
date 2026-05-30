/-
# Arithmetic Monster Theory: Main Theorems

This file proves the core theorems of the arithmetic monster theory,
extending the four foundational results from the catalog with new structural
theorems about digit interactions, carry-free arithmetic, and connections
to Pythagorean number theory.

## Main Results

1. **Digit bag sum equals digit length** — structural invariant
2. **Casting out (b-1)** — digit sum ≡ number mod (b-1)
3. **Vampire modular obstruction** — v ≡ x + y mod (b-1) for vampire pairs
4. **Vampire digit length additivity** — digit lengths add for vampire pairs
5. **Carry-free digit bag additivity** — carry-free addition preserves digit bags
6. **Ghost impossibility in base 2** — positive numbers can't be digit-disjoint in binary
7. **Digit-disjoint infinitude** — infinitely many digit-disjoint pairs in base ≥ 3
8. **Pythagorean digit sum obstruction** — mod 9 constraints on Pythagorean triples
9. **Digit signature conservation** — preserved + created = digitLen of product
10. **Conjecture**: Digit complexity bound for vampire numbers
-/
import Mathlib
import Pythagorean.ArithmeticMonsterTheory.Defs

open Finset BigOperators

namespace ArithMonster

/-! ## Theorem 1: Digit bag sum equals digit length -/

/-
The sum of all digit bag entries equals the digit length.
-/
theorem digitBag_sum_eq_digitLen (b : ℕ) (hb : 2 ≤ b) (n : ℕ) :
    ∑ d : Fin b, digitBag b n d = digitLen b n := by
      -- The sum of the counts of all digits in the list of digits of `n` is equal to the length of that list.
      have h_sum_counts : ∀ {L : List ℕ}, (∀ d ∈ L, d < b) → ∑ d : Fin b, List.count (d : ℕ) L = List.length L := by
        intros L hL; induction' L with d L ih <;> simp_all +decide [ Finset.sum_add_distrib ] ;
        simp_all +decide [ Finset.sum_add_distrib, List.count_cons ];
        exact Finset.card_eq_one.mpr ⟨ ⟨ d, hL.1 ⟩, by aesop ⟩;
      exact h_sum_counts fun d hd => Nat.digits_lt_base hb hd

/-! ## Theorem 2: Casting out (b-1) -/

/-
A number is congruent to its digit sum modulo `b - 1`.
    This is the generalization of "casting out nines" to arbitrary bases.
-/
theorem modEq_digitSum (b n : ℕ) (hb : 2 ≤ b) :
    n % (b - 1) = (digitSum b n) % (b - 1) := by
      conv_lhs => rw [ ← Nat.ofDigits_digits b n, Nat.ofDigits_mod ];
      rcases b with ( _ | _ | _ | b ) <;> simp_all +decide [ Nat.succ_eq_add_one, Nat.mod_eq_of_lt ];
      · norm_num [ Nat.mod_one ];
      · unfold digitSum; simp +decide [ Nat.ofDigits_one ] ;

/-! ## Theorem 3: Vampire digit sum additivity -/

/-
The digit sum of a vampire number equals the sum of digit sums of its factors.
-/
theorem vampire_digitSum_add {b v x y : ℕ} (hb : 2 ≤ b) (hV : IsVampire b v x y) :
    digitSum b v = digitSum b x + digitSum b y := by
      -- By definition of digit sum, we can express it as the sum of � the� digits multiplied by their respective powers of b.
      have h_digit_sum_def : ∀ n, digitSum b n = ∑ d : Fin b, d.val * (digitBag b n d) := by
        intro n;
        -- By definition of `digitSum`, we can express it as the sum of the products of each digit and its count in the list.
        have h_sum_digits : ∀ (l : List ℕ), (∀ d ∈ l, d < b) → List.sum l = ∑ d ∈ Finset.range b, d * (List.count d l) := by
          intro l hl; induction l <;> simp_all +decide [ Finset.sum_range_succ' ] ;
          simp +decide [ List.count_cons, Finset.sum_add_distrib, mul_add, add_comm, add_left_comm, Finset.sum_range_succ', hl.1 ];
        convert h_sum_digits ( Nat.digits b n ) _ using 1;
        · simp +decide [ digitBag, Finset.sum_range, Fin.cast_val_eq_self ];
        · exact fun d hd => Nat.digits_lt_base hb hd;
      simp_all +decide [ IsVampire ];
      simp +decide only [← hV.1, hV.2, mul_add, sum_add_distrib]

/-! ## Theorem 4: Modular obstruction for vampire pairs -/

/-
**Modular digit-sum obstruction**: If `(x, y)` is a vampire pair for `v` in base `b`,
    then `v ≡ x + y (mod b - 1)`. This is the "casting out" sieve for vampire numbers.
-/
theorem vampire_modEq_sum {b v x y : ℕ} (hb : 2 ≤ b) (hV : IsVampire b v x y) :
    v % (b - 1) = (x + y) % (b - 1) := by
      rw [ modEq_digitSum, vampire_digitSum_add ];
      rw [ Nat.add_mod, modEq_digitSum, modEq_digitSum ];
      any_goals assumption;
      rw [ ← modEq_digitSum, ← modEq_digitSum, ← modEq_digitSum ];
      · simp +decide [ Nat.add_mod, modEq_digitSum b y hb ];
      · linarith;
      · linarith;
      · linarith

/-! ## Theorem 5: Vampire digit length additivity -/

/-
For vampire pairs, digit lengths are additive.
-/
theorem vampire_digitLen_add {b v x y : ℕ} (hb : 2 ≤ b) (hV : IsVampire b v x y) :
    digitLen b v = digitLen b x + digitLen b y := by
      obtain ⟨h₁, h₂⟩ := hV;
      rw [ ← digitBag_sum_eq_digitLen b hb v, ← digitBag_sum_eq_digitLen b hb x, ← digitBag_sum_eq_digitLen b hb y ];
      rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun _ _ => h₂ _ ]

/-! ## Theorem 6: Carry-free digit bag additivity -/

/-
Helper: carry-free means the sum of digits at each position doesn't exceed base.
-/
theorem carryFree_mod_add {bs a b : ℕ} (hbs : 2 ≤ bs)
    (h : a % bs + b % bs < bs) :
    (a + b) % bs = a % bs + b % bs := by
      rw [ Nat.add_mod, Nat.mod_eq_of_lt h ]

/-
Helper: carry-free means division propagates additively.
-/
theorem carryFree_div_add {bs a b : ℕ} (hbs : 2 ≤ bs)
    (h : a % bs + b % bs < bs) :
    (a + b) / bs = a / bs + b / bs := by
      exact Nat.le_antisymm ( Nat.le_of_lt_succ <| Nat.div_lt_of_lt_mul <| by linarith [ Nat.mod_add_div a bs, Nat.mod_add_div b bs, Nat.mod_lt a ( zero_lt_two.trans_le hbs ) ] ) ( Nat.le_div_iff_mul_le ( by positivity ) |>.2 ( by linarith [ Nat.mod_add_div a bs, Nat.mod_add_div b bs, Nat.zero_le ( a % bs ), Nat.zero_le ( b % bs ) ] ) )

/-
**Carry-free digit sum theorem**: When addition of `a` and `b` in base `bs` produces
    no carries, the digit sum of `a + b` equals the sum of digit sums.
    This is because carries are the sole mechanism by which digit sums change.
-/
theorem carryFree_digitSum_add {bs a b : ℕ} (hbs : 2 ≤ bs)
    (hcf : CarryFree bs a b) :
    digitSum bs (a + b) = digitSum bs a + digitSum bs b := by
      induction' a using Nat.strong_induction_on with a ih generalizing b;
      rcases bs with ( _ | _ | bs ) <;> simp_all +decide [ digitSum ];
      have := hcf 0; simp_all +decide [ Nat.mod_eq_of_lt ] ;
      rcases a with ( _ | a ) <;> rcases b with ( _ | b ) <;> simp_all +decide [ Nat.div_eq_of_lt ];
      rw [ show ( a + 1 + ( b + 1 ) ) / ( bs + 1 + 1 ) = ( a + 1 ) / ( bs + 1 + 1 ) + ( b + 1 ) / ( bs + 1 + 1 ) from ?_ ];
      · rw [ Nat.add_mod, ih _ _ ];
        · rw [ Nat.mod_eq_of_lt ( by linarith : ( a + 1 ) % ( bs + 1 + 1 ) + ( b + 1 ) % ( bs + 1 + 1 ) < bs + 1 + 1 ) ] ; ring;
        · intro i; specialize hcf ( i + 1 ) ; simp_all +decide [ Nat.div_eq_of_lt ] ;
        · exact Nat.le_of_lt_succ ( Nat.div_lt_of_lt_mul <| by nlinarith );
      · rw [ Nat.add_div ] <;> norm_num;
        linarith

/-
**Carry-free digit length theorem**: When addition is carry-free,
    the digit length of the sum is the max of the digit lengths.
-/
theorem carryFree_digitLen_max {bs a b : ℕ} (hbs : 2 ≤ bs)
    (hcf : CarryFree bs a b) (ha : 0 < a) (hb : 0 < b) :
    digitLen bs (a + b) = max (digitLen bs a) (digitLen bs b) := by
      induction' a using Nat.strong_induction_on with a ih generalizing b;
      -- Apply the induction hypothesis to a/bs and b/bs.
      have h_ind : digitLen bs (a / bs + b / bs) = max (digitLen bs (a / bs)) (digitLen bs (b / bs)) := by
        by_cases ha' : 0 < a / bs <;> by_cases hb' : 0 < b / bs <;> simp_all +decide [ Nat.div_eq_of_lt ];
        · apply ih (a / bs) (Nat.div_lt_self ha (by linarith)) (fun i => by
            convert hcf ( i + 1 ) using 1 ; simp +decide [ Nat.div_eq_of_lt, * ]) (Nat.div_pos (by linarith) (by linarith)) (Nat.div_pos (by linarith) (by linarith));
        · unfold digitLen; aesop;
        · unfold digitLen; aesop;
        · simp_all +decide [ Nat.div_eq_of_lt ( ha' ( by linarith ) ), Nat.div_eq_of_lt ( hb' ( by linarith ) ) ];
      unfold digitLen at *;
      rcases bs with ( _ | _ | bs ) <;> simp_all +decide;
      convert h_ind using 2;
      rw [ Nat.add_div ] <;> norm_num;
      have := hcf 0; aesop;

/-! ## Theorem 7: Ghost impossibility in base 2 -/

/-
Every positive number has digit 1 in its binary representation.
-/
theorem binary_has_one (n : ℕ) (hn : 0 < n) : 1 ∈ Nat.digits 2 n := by
  induction' n using Nat.strong_induction_on with n ih;
  grind +suggestions

/-
In base 2, no two positive numbers can be digit-disjoint.
-/
theorem not_digitDisjoint_base2 {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    ¬DigitDisjoint 2 m n := by
      unfold DigitDisjoint;
      simp +decide [ digitOverlap ];
      unfold digitBag; simp +decide [ Nat.digits_add ] ;
      intro h; have := binary_has_one m hm; have := binary_has_one n hn; simp_all +decide [ List.count_eq_zero ] ;

/-! ## Theorem 8: Digit-disjoint infinitude in base ≥ 3 -/

/-
For `b ≥ 3` and any `N`, there exist digit-disjoint positive pairs above `N`.
-/
theorem exists_digitDisjoint_pair_ge {b : ℕ} (hb : 3 ≤ b) (N : ℕ) :
    ∃ m n, N ≤ m ∧ N ≤ n ∧ 0 < m ∧ 0 < n ∧ DigitDisjoint b m n := by
      -- Choose `m` and `n �`� as `b^k` and `b^(k+1) - 1` for a sufficiently large `k`.
      obtain ⟨k, hk⟩ : ∃ k : ℕ, b^k > N := by
        exact pow_unbounded_of_one_lt _ <| by linarith;
      use b^k, b^(k+1) - 1;
      refine ⟨ hk.le, Nat.le_sub_one_of_lt <| hk.trans <| pow_lt_pow_right₀ ( by linarith ) <| Nat.lt_succ_self _, pow_pos ( by linarith ) _, Nat.sub_pos_of_lt <| one_lt_pow₀ ( by linarith ) <| by linarith, ?_ ⟩;
      -- In base `b`, `b^k` has digits `[0, 0, ..., 0, 1]` (k zeros followed by 1), and `b^(k+1) - 1` has digits `[b-1, b-1, ..., b-1]` (k+1 copies of `b-1`).
      have h_digits : Nat.digits b (b^k) = List.replicate k 0 ++ [1] ∧ Nat.digits b (b^(k+1) - 1) = List.replicate (k+1) (b-1) := by
        constructor;
        · refine Nat.recOn k ?_ fun n hn => ?_ <;> simp_all +decide [ Nat.pow_succ' ];
          · rcases b with ( _ | _ | b ) <;> simp_all +decide [ Nat.div_eq_of_lt ];
          · rcases b with ( _ | _ | b ) <;> simp_all +decide [ Nat.pow_succ' ];
            simp +arith +decide [ List.replicate ];
        · have h_digits_b_pow : Nat.ofDigits b (List.replicate (k + 1) (b - 1)) = b ^ (k + 1) - 1 := by
            rw [ Nat.ofDigits_eq_foldr ];
            exact Eq.symm ( Nat.sub_eq_of_eq_add <| by induction' k + 1 with k ih <;> simp +decide [ Nat.pow_succ', List.replicate ] at * ; nlinarith [ Nat.sub_add_cancel ( by linarith : 1 ≤ b ) ] );
          rw [ ← h_digits_b_pow, Nat.digits_ofDigits ];
          · grind;
          · intro l hl; rw [ List.eq_of_mem_replicate hl ] ; exact Nat.pred_lt ( ne_bot_of_gt hb ) ;
          · grind;
      unfold DigitDisjoint; simp_all +decide [ digitOverlap ] ;
      unfold digitBag; simp_all +decide [ List.count ] ;
      grind

/-! ## Theorem 9: Pythagorean Digit Sum Obstruction (Cross-Domain) -/

/-
**Pythagorean-digit connection**: For any Pythagorean triple `a² + b² = c²`,
    the digit sums satisfy `digitSum(a)² + digitSum(b)² ≡ digitSum(c)² (mod b-1)`.
    This connects the additive structure of digit sums to the multiplicative
    structure of Pythagorean equations. In base 10, this gives mod-9 constraints.
-/
theorem pythagorean_digitSum_mod {base a b c : ℕ} (hbase : 2 ≤ base)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    (digitSum base a ^ 2 + digitSum base b ^ 2) % (base - 1) =
    (digitSum base c ^ 2) % (base - 1) := by
      -- By modEq_digitSum, a� � digit�Sum(a) mod (base-1), so a^2 digit �Sum�(a)^2 mod (base-1). Similarly for b and c.
      have h_mod : a ^ 2 % (base - 1) = digitSum base a ^ 2 % (base - 1) ∧ b ^ 2 % (base - 1) = digitSum base b ^ 2 % (base - 1) ∧ c ^ 2 % (base - 1) = digitSum base c ^ 2 % (base - 1) := by
        exact ⟨ Nat.ModEq.pow _ ( modEq_digitSum base a hbase ), Nat.ModEq.pow _ ( modEq_digitSum base b hbase ), Nat.ModEq.pow _ ( modEq_digitSum base c hbase ) ⟩;
      simp +decide [ ← h_mod, ← hpyth, Nat.add_mod ]

/-! ## Theorem 10: Digit Signature Conservation Law -/

/-
**Digit signature conservation**: The number of preserved + created digits in
    a multiplication equals the digit length of the product. This is a conservation
    law for the digit interaction signature.
-/
theorem digitSignature_conservation {b v x y : ℕ} (hb : 2 ≤ b) (hv : v = x * y) :
    (digitSignature b v x y).preserved + (digitSignature b v x y).created =
    digitLen b v := by
      convert digitBag_sum_eq_digitLen b hb v using 1;
      unfold digitSignature; simp +decide [ Finset.sum_add_distrib ] ;
      rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl ] ; intros ; rw [ min_def ] ; split_ifs <;> omega;

/-! ## Theorem 11: Vampire implies digit-preserving -/

/-
A vampire pair has a trivial digit signature: all digits preserved,
    none created or destroyed.
-/
theorem vampire_implies_digitPreserving {b v x y : ℕ} (hb : 2 ≤ b)
    (hV : IsVampire b v x y) :
    IsDigitPreserving b v x y := by
      obtain ⟨hv, h⟩ := hV;
      constructor <;> simp +decide [ IsDigitPreserving, digitSignature, h ]

/-! ## Conjecture: Digit complexity bound -/

/-
**Conjecture (Digit Complexity Bound)**: For any vampire number v = x * y in base b,
    the digit complexity of v is at most the sum of digit complexities of x and y.

    **Testable prediction**: Compute all vampire numbers below 10^6 in base 10 and
    verify that `digitComplexity 10 v ≤ digitComplexity 10 x + digitComplexity 10 y`
    for each vampire pair. A single counterexample would disprove this.

    This is a strengthening of digit-bag additivity: not only are total counts
    preserved, but the number of *distinct* digit types never increases.
-/
theorem digit_complexity_vampire_bound {b v x y : ℕ} (hb : 2 ≤ b)
    (hV : IsVampire b v x y) :
    digitComplexity b v ≤ digitComplexity b x + digitComplexity b y := by
      obtain ⟨hv_eq, hv_digit⟩ := hV;
      -- From IsVampire, digitBag b v d = digitBag b x d + digitBag b y d for all d : Fin b.
      have h_digitBag : ∀ d : ℕ, d < b → (Nat.digits b v).count d > 0 → (Nat.digits b x).count d > 0 ∨ (Nat.digits b y).count d > 0 := by
        unfold digitBag at hv_digit;
        intro d hd hd'; specialize hv_digit ⟨ d, hd ⟩ ; aesop;
      refine' le_trans _ ( Finset.card_union_le _ _ );
      refine Finset.card_mono ?_;
      intro d hd; specialize h_digitBag d; simp_all +decide [ List.count_eq_zero ] ;
      exact h_digitBag ( Nat.digits_lt_base hb hd )

end ArithMonster