import Mathlib
import Collatz.ParityCylinders

/-!
# Affine Iteration Formula and Descent Theory

This file develops the affine structure of Collatz iterates along parity words.
The key insight is that the k-step Collatz iterate along a parity word w is an
affine function of the starting value: D · x_k = A · n + B, where A = 3^(oddCount)
and D = 2^(evenCount).

## Main results

* `v2_mod_preserved_on_odd`: The 2-adic structure of 3n+1 is determined by n mod 2^k.
* `iterate_congr_mod`: The j-th iterate mod 2^(k-j) is determined by n mod 2^k.
* `parityWord_eq_of_residue`: The parity word factors through ℤ/2^kℤ.
* `parityCylinder_partition`: Parity cylinders partition ℕ.
* `countUpTo_partition`: Total count across all cylinders equals N+1.
* `exists_descent_word`: For k ≥ 1, at least one descent word exists.
-/

namespace Collatz

/-
============================================================================
§ 1. The 2-adic structure of 3n+1 is locally determined
============================================================================

For any numbers, 3n+1 mod 2^k depends only on n mod 2^k.
    This is the foundation of 2-adic local analysis for Collatz dynamics.
-/
theorem v2_mod_preserved_on_odd (n m k : ℕ)
    (h : n % 2 ^ k = m % 2 ^ k) :
    (3 * n + 1) % 2 ^ k = (3 * m + 1) % 2 ^ k := by
  exact Nat.ModEq.add ( Nat.ModEq.mul_left _ h ) rfl

/-
============================================================================
§ 2. Iterate congruence — strengthened version
============================================================================

The j-th Collatz iterate mod 2^(k-j) is determined by n mod 2^k.
    This is the quantitative backbone of the parity cylinder theorem.
-/
theorem iterate_congr_mod (k : ℕ) (n m : ℕ) (j : ℕ) (hj : j ≤ k)
    (h : n % 2 ^ k = m % 2 ^ k) :
    step^[j] n % 2 ^ (k - j) = step^[j] m % 2 ^ (k - j) := by
  induction' j with j ih generalizing n m;
  · exact h;
  · have := step_congr_mod ( step^[j] n ) ( step^[j] m ) ( 2 ^ ( k - j - 1 ) ) ?_ ?_ <;> simp_all +decide [ Nat.pow_succ', Nat.mul_mod_mul_left ];
    · erw [ Function.iterate_succ_apply', Function.iterate_succ_apply' ] at * ; aesop;
    · convert ih n m hj.le h using 1;
      · rw [ ← pow_succ', Nat.sub_add_cancel ( Nat.sub_pos_of_lt hj ) ];
      · rw [ ← pow_succ', Nat.sub_add_cancel ( Nat.sub_pos_of_lt hj ) ]

-- ============================================================================
-- § 3. Parity word as a well-defined function on ℤ/2^k ℤ
-- ============================================================================

/-- The parity word map factors through ℤ/2^kℤ: it defines a well-posed
    function on residue classes. -/
def parityWordOfResidue (k : ℕ) (a : Fin (2 ^ k)) : Fin k → Bool :=
  parityWord k a.val

/-
Any natural number's parity word equals that of its residue class representative.
-/
theorem parityWord_eq_of_residue (k : ℕ) (n : ℕ) :
    parityWord k n = parityWordOfResidue k ⟨n % 2 ^ k, Nat.mod_lt _ (by positivity)⟩ := by
  -- By definition of `parityWord`, we know that `parityWord k n` depends only on `n % 2^k`.
  have h_parityWord_mod : ∀ n, parityWord k n = parityWord k (n % 2 ^ k) := by
    exact fun n => parityWord_determined_by_residue k n ( n % 2 ^ k ) ( by simp +decide );
  convert h_parityWord_mod n using 1

-- ============================================================================
-- § 4. Parity cylinders partition ℕ
-- ============================================================================

/-- A parity cylinder is the preimage of a parity word under the parityWord map. -/
def parityCylinder (k : ℕ) (w : Fin k → Bool) : Set ℕ :=
  {n | parityWord k n = w}

instance parityCylinder_decidable (k : ℕ) (w : Fin k → Bool) :
    DecidablePred (· ∈ parityCylinder k w) :=
  fun n => decidable_of_iff (parityWord k n = w) Iff.rfl

/-
The parity cylinders partition ℕ: every natural number belongs to exactly
    one cylinder.
-/
theorem parityCylinder_partition (k : ℕ) (n : ℕ) :
    ∃! w : Fin k → Bool, n ∈ parityCylinder k w := by
  refine' ⟨ parityWord k n, _, _ ⟩ <;> simp +decide [ parityCylinder ]

-- ============================================================================
-- § 5. Density framework
-- ============================================================================

/-- Count of naturals up to N in a decidable set. -/
def countUpTo (N : ℕ) (S : Set ℕ) [DecidablePred (· ∈ S)] : ℕ :=
  ((Finset.range (N + 1)).filter (· ∈ S)).card

/-
The total count across all parity cylinders equals N+1.
    This is the partition-of-unity property for Collatz parity cylinders.
-/
theorem countUpTo_partition (k N : ℕ) :
    ∑ w : Fin k → Bool, countUpTo N (parityCylinder k w) = N + 1 := by
  simp +decide only [countUpTo, parityCylinder];
  convert Finset.card_range ( N + 1 ) using 1;
  rw [ ← Finset.card_biUnion ];
  · congr with x ; aesop;
  · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun z hz₁ hz₂ => hxy <| by aesop;

/-
Each parity cylinder's count is at most N + 1.
-/
theorem countUpTo_cylinder_le (k : ℕ) (w : Fin k → Bool) (N : ℕ) :
    countUpTo N (parityCylinder k w) ≤ N + 1 := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-
============================================================================
§ 6. Descent word existence
============================================================================

For k ≥ 1, at least one descent word exists.
    The all-false word (all even steps) has oddCount = 0 and evenCount = k,
    so 3^0 = 1 < 2^k.
-/
theorem exists_descent_word (k : ℕ) (hk : 1 ≤ k) :
    ∃ w : Fin k → Bool, isDescentWord k w := by
  -- By definition of `isDescentWord`, we need to show that for the word `w` consisting of all false values, `3^(oddCount k w) < 2^(evenCount k w)`.
  unfold isDescentWord;
  use fun _ => false;
  unfold oddCount evenCount; norm_num;
  linarith

end Collatz