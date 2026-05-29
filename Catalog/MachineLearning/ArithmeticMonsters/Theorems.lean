/-
# Arithmetic Monsters: Main Theorems

This file contains the main structural theorems about arithmetic monsters:
1. Modular digit-sum obstruction for vampire pairs
2. Ghost impossibility in base 2
3. Length additivity for vampire pairs
4. Infinitude of digit-disjoint pairs in base ≥ 3
-/
import Mathlib
import Speculative.ArithmeticMonsters.Defs

open Finset BigOperators

namespace ArithmeticMonsters

/-! ## Auxiliary lemmas about digits -/

/-- Every element of `Nat.digits b n` is less than `b` when `b ≥ 2`. -/
theorem digits_lt_base {b : ℕ} (hb : 2 ≤ b) {n : ℕ} {d : ℕ} (hd : d ∈ Nat.digits b n) :
    d < b :=
  Nat.digits_lt_base (by omega) hd

/-
The sum of all digit bag entries equals the digit length.
-/
theorem digitBag_sum_eq_digitLen (b : ℕ) (hb : 2 ≤ b) (n : ℕ) :
    ∑ d : Fin b, digitBag b n d = digitLen b n := by
  trans;
  convert Finset.sum_congr rfl fun x _ => ?_;
  exact fun x => List.count x.val ( Nat.digits b n );
  · rfl;
  · have h_sum_count : ∀ (L : List ℕ), (∀ d ∈ L, d < b) → ∑ x : Fin b, List.count (x : ℕ) L = L.length := by
      intro L hL;
      induction' L using List.reverseRecOn with d L ih;
      · simp +decide;
      · simp_all +decide [ Finset.sum_add_distrib, List.count_cons ];
        exact Finset.card_eq_one.mpr ⟨ ⟨ L, hL L ( Or.inr rfl ) ⟩, by aesop ⟩;
    exact h_sum_count _ fun d hd => Nat.digits_lt_base hb hd

/-! ## Theorem 1: Casting out b-1 -/

/-
A number is congruent to its digit sum modulo `b - 1`.
    This is the generalization of "casting out nines" to arbitrary bases.
-/
theorem modEq_digitSum (b n : ℕ) (hb : 2 ≤ b) :
    n % (b - 1) = (Nat.digits b n).sum % (b - 1) := by
  conv_lhs => rw [ ← Nat.ofDigits_digits b n, Nat.ofDigits_mod ];
  rcases b with ( _ | _ | b ) <;> simp_all +decide [ Nat.ofDigits_one ];
  cases b <;> simp_all +decide [ Nat.ofDigits_one ];
  norm_num [ Nat.mod_one ]

/-
The digit sum of a vampire number equals the sum of digit sums of its factors.
-/
theorem vampire_digitSum_add {b v x y : ℕ} (hb : 2 ≤ b) (hV : IsVampire b v x y) :
    (Nat.digits b v).sum = (Nat.digits b x).sum + (Nat.digits b y).sum := by
  obtain ⟨hv, h⟩ := hV;
  have h_digit_sum : ∀ n : ℕ, (Nat.digits b n).sum = ∑ d : Fin b, d.val * (digitBag b n d) := by
    intro n
    have h_sum_digits : ∀ L : List ℕ, (∀ d ∈ L, d < b) → L.sum = ∑ d ∈ Finset.range b, d * (L.count d) := by
      intro L hL;
      induction' L using List.reverseRecOn with d L ih;
      · norm_num;
      · simp_all +decide [ Finset.sum_add_distrib, mul_add, List.count_cons ];
    convert h_sum_digits ( Nat.digits b n ) _ using 1;
    · rw [ Finset.sum_range ];
      rfl;
    · exact fun d hd => Nat.digits_lt_base hb hd;
  simp +decide [ h_digit_sum, h, Finset.sum_add_distrib, mul_add ]

/-
**Theorem 1 (Modular digit-sum obstruction).**
    If `(x, y)` is a vampire pair for `v` in base `b`, then `v ≡ x + y (mod b - 1)`.
-/
theorem IsVampire.modEq_sum {b v x y : ℕ} (hb : 2 ≤ b) (hV : IsVampire b v x y) :
    v % (b - 1) = (x + y) % (b - 1) := by
  -- By modEq_digitSum, v % (b-1) = (digits b v).sum % (b-1) and similarly for x, y.
  have hv : v % (b - 1) = (Nat.digits b v).sum % (b - 1) := modEq_digitSum b v hb
  have hx : x % (b - 1) = (Nat.digits b x).sum % (b - 1) := modEq_digitSum b x hb
  have hy : y % (b - 1) = (Nat.digits b y).sum % (b - 1) := modEq_digitSum b y hb;
  rw [ hv, Nat.add_mod, hx, hy ];
  rw [ ← Nat.add_mod, ← vampire_digitSum_add hb hV ]

/-! ## Theorem 2: Ghost impossibility in base 2 -/

/-
The only digits in base 2 are 0 and 1.
-/
theorem digits_base2_mem {n d : ℕ} (hd : d ∈ Nat.digits 2 n) : d = 0 ∨ d = 1 := by
  exact Classical.or_iff_not_imp_left.2 fun h => by have := Nat.digits_lt_base' hd; interval_cases d <;> trivial;

/-
Every positive number contains the digit 1 in base 2.
-/
theorem binary_has_one (n : ℕ) (hn : 0 < n) :
    1 ∈ Nat.digits 2 n := by
  contrapose! hn;
  have h_digits_zero : ∀ d ∈ Nat.digits 2 n, d = 0 := by
    intro d hd; have := Nat.digits_lt_base' hd; interval_cases d <;> aesop;
  rw [ ← Nat.ofDigits_digits 2 n, List.eq_replicate_of_mem h_digits_zero ] ; norm_num

/-
In base 2, the digit bag at `1` is positive for any positive number.
-/
theorem digitBag_base2_one_pos (n : ℕ) (hn : 0 < n) :
    0 < digitBag 2 n ⟨1, by omega⟩ := by
  -- Since $n$ is positive, its binary representation contains at least one '1'.
  have h_one_exists : 1 ∈ Nat.digits 2 n := by
    exact binary_has_one n hn
  exact List.count_pos_iff.mpr h_one_exists

/-
**Theorem 2.** In base 2, no two positive numbers can be digit-disjoint.
-/
theorem pos_not_digitDisjoint_base2 {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    ¬DigitDisjoint 2 m n := by
  unfold DigitDisjoint;
  unfold digitOverlap; simp +decide [ digitBag ] ;
  intro h; have := binary_has_one m hm; have := binary_has_one n hn; simp_all +decide [ List.count_eq_zero ] ;

/-
Ghost numbers are impossible in base 2 for positive factors.
-/
theorem not_IsGhost_base2 {v x y : ℕ} (hv : 0 < v) (hx : 0 < x) (_hy : 0 < y) :
    ¬IsGhost 2 v x y := by
  exact fun h => pos_not_digitDisjoint_base2 hv hx h.2.1

/-! ## Theorem 3: Length additivity -/

/-
**Theorem 3 (Length additivity).**
    If `(x, y)` is a vampire pair for `v`, then the number of digits of `v`
    equals the sum of the number of digits of `x` and `y`.
-/
theorem IsVampire.digitLen_add {b v x y : ℕ} (hb : 2 ≤ b)
    (hV : IsVampire b v x y) :
    digitLen b v = digitLen b x + digitLen b y := by
  obtain ⟨hv, h⟩ := hV;
  rw [ ← digitBag_sum_eq_digitLen b hb v, ← digitBag_sum_eq_digitLen b hb x, ← digitBag_sum_eq_digitLen b hb y ];
  rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun _ _ => h _ ]

/-! ## Theorem 4: Infinitude of digit-disjoint pairs -/

/-- A repdigit: `k` copies of digit `d` in base `b`. -/
def repdigit (b d k : ℕ) : ℕ := d * ∑ i ∈ range k, b ^ i

/-
For `b ≥ 3` and any `N`, there exist large digit-disjoint positive pairs.
-/
theorem exists_digitDisjoint_pair_ge {b : ℕ} (hb : 3 ≤ b) (N : ℕ) :
    ∃ m n, N ≤ m ∧ N ≤ n ∧ 0 < m ∧ 0 < n ∧ DigitDisjoint b m n := by
  revert N;
  -- For any $N$, we can choose $k$ large enough such that $b^k > N$ and $b^{k+1} > N$.
  intro N
  obtain ⟨k, hk⟩ : ∃ k, b^k > N ∧ b^(k+1) > N := by
    use N;
    induction' N with N ih;
    · grind;
    · exact ⟨ by rw [ pow_succ' ] ; nlinarith, by rw [ pow_succ' ] ; nlinarith [ pow_succ' b N ] ⟩;
  refine' ⟨ b ^ k, b ^ ( k + 1 ) - 1, _, _, _, _, _ ⟩ <;> try linarith;
  · grind;
  · exact Nat.sub_pos_of_lt ( one_lt_pow₀ ( by linarith ) ( by linarith ) );
  · -- Let's calculate the digit bags of $b^k$ and $b^{k+1} - 1$ in base $b$.
    have h_digit_bags : digitBag b (b ^ k) = fun d => if d.val = 0 then k else if d.val = 1 then 1 else 0 := by
      have h_digit_bags : Nat.digits b (b^k) = List.replicate k 0 ++ [1] := by
        refine Nat.recOn k ?_ fun n hn => ?_ <;> simp_all +decide [ Nat.pow_succ' ];
        · exact Nat.digits_of_lt b 1 (by omega) (by omega);
        · rcases b with ( _ | _ | b ) <;> simp_all +decide;
          simp +arith +decide [ List.replicate ];
      ext d; simp [digitBag, h_digit_bags];
      grind
    have h_digit_bags' : digitBag b (b ^ (k + 1) - 1) = fun d => if d.val = b - 1 then k + 1 else 0 := by
      -- Let's calculate the digit bag of $b^{k+1} - 1$ in base $b$.
      have h_digit_bags' : Nat.digits b (b ^ (k + 1) - 1) = List.replicate (k + 1) (b - 1) := by
        have h_digit_bags' : Nat.ofDigits b (List.replicate (k + 1) (b - 1)) = b ^ (k + 1) - 1 := by
          rw [ Nat.ofDigits_eq_foldr ];
          exact Eq.symm ( Nat.sub_eq_of_eq_add <| by exact Nat.recOn ( k + 1 ) ( by norm_num ) fun n ihn => by cases b <;> simp_all +decide [ Nat.pow_succ', List.replicate ] ; linarith );
        rw [ ← h_digit_bags', Nat.digits_ofDigits ] <;> norm_num;
        · linarith;
        · linarith;
        · omega;
      ext d; simp [digitBag, h_digit_bags'];
      grind +locals;
    unfold DigitDisjoint; simp_all +decide [ digitOverlap ] ;
    grind

end ArithmeticMonsters