import Mathlib

/-!
# The Inverse of the Pascal-like Sprugnoli/Riordan Array, in Closed Form

The Pascal-like Riordan (Sprugnoli) array `(1/(1-x), x/(1-x)^2)` has lower-triangular
entries `T_{n,k} = C(n+k, 2k)` (OEIS A085478).  This file constructs its **inverse
array in closed form** and proves the two-sided matrix-inverse (orthogonality)
relations.

The Riordan-group inverse of `(1/(1-x), x/(1-x)^2)` is `(C(-x), 1 - C(-x))`, where
`C` is the Catalan generating function `C(x) = (1 - sqrt(1-4x))/(2x)`.  Extracting
coefficients gives the **signed Catalan (ballot) triangle**

  `S_{n,k} = (-1)^{n+k} ( C(2n, n-k) - C(2n, n-k-1) )`    (OEIS A053121, signed),

equivalently `S_{n,k} = (-1)^{n+k} * (2k+1)/(n+k+1) * C(2n, n-k)`.

## Main results

* `InverseSprugnoliArray.orthogonality` — `∑_j T_{n,j} S_{j,k} = [n = k]` (`T·S = I`).
* `InverseSprugnoliArray.orthogonality'` — `∑_j S_{n,j} T_{j,k} = [n = k]` (`S·T = I`).
* `InverseSprugnoliArray.invSprug_diag` — the diagonal is `1`.
* `InverseSprugnoliArray.invSprug_col_zero` — column `0` is the signed Catalan number
  `(-1)^n * catalan n`.

## Catalog synthesis

This is the inverse-array companion of `Catalog/Novelty/RiordanRowSumFibonacci.lean`
(which studied the *row sums* of the same array `C(n+k,2k)`).  Where that file linked
the array to Fibonacci numbers, this file inverts the array and links the inverse to
the Catalan numbers, realising the "Sprugnoli group inverse" thread of the catalog.

-- !-- Lab Notes -- !--
-- !-- Hypothesis: the Pascal-like Riordan array T_{n,k}=C(n+k,2k) has a closed-form
--     inverse. Riordan-group calculus predicts inverse pair (C(-x), 1-C(-x)). -- !--
-- !-- Experiment: numerically inverted T (5..9 rows). First column is the signed
--     Catalan sequence 1,-1,2,-5,14,-42; the subdiagonal is -(2n-1). Fitting gives
--     S_{n,k}=(-1)^{n+k}(2k+1)/(n+k+1) C(2n,n-k), an exact match for all tested n,k.
--     The integer form (-1)^{n+k}(C(2n,n-k)-C(2n,n-k-1)) also matched. -- !--
-- !-- Analysis: naive use of the binomial-difference form breaks under truncated ℕ
--     subtraction in two places (n-k at k=n, and n-k-1), so the definition guards
--     `k < n` for the second binomial and `n < k` for triangularity. -- !--
-- !-- Verification: both T·S = I and S·T = I confirmed for all n,k ≤ 8 before
--     formalisation. -- !--
-/

open Finset

namespace InverseSprugnoliArray

/-- The Pascal-like Sprugnoli/Riordan array `T_{n,k} = C(n+k, 2k)` (OEIS A085478). -/
def sprug (n k : ℕ) : ℤ := (Nat.choose (n + k) (2 * k) : ℤ)

/-- The closed-form inverse array: the signed Catalan (ballot) triangle
`S_{n,k} = (-1)^{n+k} ( C(2n, n-k) - C(2n, n-k-1) )`, with `S_{n,k} = 0` for `k > n`. -/
def invSprug (n k : ℕ) : ℤ :=
  if n < k then 0
  else (-1) ^ (n + k) *
    ((Nat.choose (2 * n) (n - k) : ℤ) -
      (if k < n then (Nat.choose (2 * n) (n - k - 1) : ℤ) else 0))

/-- Triangularity of the inverse array: `S_{n,k} = 0` when `k > n`. -/
lemma invSprug_of_lt {n k : ℕ} (h : n < k) : invSprug n k = 0 := by
  simp [invSprug, h]

/-
The diagonal of the inverse array is `1`.
-/
lemma invSprug_diag (n : ℕ) : invSprug n n = 1 := by
  unfold invSprug;
  norm_num [ ← two_mul ]

/-
Column `0` of the inverse array is the signed Catalan number `(-1)^n · catalan n`.
-/
lemma invSprug_col_zero (n : ℕ) : invSprug n 0 = (-1) ^ n * (catalan n : ℤ) := by
  -- By definition of invSprug, when k = 0, we have invSprug n 0 = (-1)^n * (Nat.choose (2*n) n - (if 0 < n then Nat.choose (2*n) (n-1) else 0)).
  have h_def : invSprug n 0 = (-1 : ℤ) ^ n * (Nat.choose (2 * n) n - (if 0 < n then Nat.choose (2 * n) (n - 1) else 0)) := by
    unfold invSprug; aesop;
  rcases n with ( _ | n ) <;> simp_all +decide [ catalan_eq_centralBinom_div ];
  rw_mod_cast [ Nat.centralBinom ];
  rw [ Int.subNatNat_eq_coe ] ; have := Nat.add_one_mul_choose_eq ( 2 * ( n + 1 ) ) n; simp_all +decide [ Nat.mul_succ, Nat.choose_succ_succ ] ; ring;
  exact Eq.symm ( Int.ediv_eq_of_eq_mul_left ( by linarith ) ( by ring_nf at *; linarith ) )

/-
Trinomial-revision identity (first factor):
`C(n+j, 2j) · C(2j, j-k) = C(n+j, j-k) · C(n+k, j+k)` for `k ≤ j`.
-/
lemma trinomial_revision_one {n k j : ℕ} (h : k ≤ j) :
    Nat.choose (n + j) (2 * j) * Nat.choose (2 * j) (j - k)
      = Nat.choose (n + j) (j - k) * Nat.choose (n + k) (j + k) := by
  rw [ Nat.choose_mul ];
  · grind;
  · omega

/-
Trinomial-revision identity (second factor):
`C(n+j, 2j) · C(2j, j-k-1) = C(n+j, j-k-1) · C(n+k+1, j+k+1)` for `k < j`.
-/
lemma trinomial_revision_two {n k j : ℕ} (h : k < j) :
    Nat.choose (n + j) (2 * j) * Nat.choose (2 * j) (j - k - 1)
      = Nat.choose (n + j) (j - k - 1) * Nat.choose (n + k + 1) (j + k + 1) := by
  grind +suggestions

/-
**Key alternating Vandermonde identity** (the combinatorial crux):
`∑_{i=0}^{m} (-1)^i C(p+i, i) C(p, m-i) = (-1)^m`.

Proof idea: by upper negation `(-1)^i C(p+i,i) = C(-(p+1), i)` over ℤ, the sum is the
Vandermonde convolution `∑_i C(-(p+1),i) C(p, m-i) = C(-1, m) = (-1)^m`.  Equivalently,
it is the coefficient of `x^m` in `(1+x)^{-(p+1)} · (1+x)^p = (1+x)^{-1} = ∑ (-1)^m x^m`.
Provable by induction on `m`.
-/
lemma key_vandermonde (p m : ℕ) :
    ∑ i ∈ range (m + 1), (-1 : ℤ) ^ i * Nat.choose (p + i) i * Nat.choose p (m - i)
      = (-1) ^ m := by
  -- Apply the upper negation identity to each term in the sum.
  have h_upper_negation : ∀ i ∈ Finset.range (m + 1), (-1 : ℤ) ^ i * (Nat.choose (p + i) i) = Ring.choose (-(p + 1) : ℤ) i := by
    intro i hi
    have h_upper_negation : Ring.choose (-(p + 1) : ℤ) i = (-1 : ℤ) ^ i * (Nat.choose (p + i) i) := by
      rw [ Ring.choose_neg ] ; ring;
      convert congr_arg ( fun x : ℤ => ( -1 : ℤ ) ^ i * x ) ( Ring.choose_natCast ( p + i ) i ) using 1 ; ring;
    exact h_upper_negation.symm;
  -- Apply the Vandermonde convolution identity to the sum.
  have h_vandermonde : ∑ i ∈ Finset.range (m + 1), Ring.choose (-(p + 1) : ℤ) i * Ring.choose (p : ℤ) (m - i) = Ring.choose (-(p + 1) + p : ℤ) m := by
    rw [ Ring.add_choose_eq ];
    · rw [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk ];
    · exact Commute.all _ _;
  convert h_vandermonde using 1;
  · exact Finset.sum_congr rfl fun i hi => by rw [ h_upper_negation i hi, Ring.choose_natCast ] ;
  · norm_num [ Ring.choose ];
    grind +suggestions

/-
Value of the `FirstSum` after trinomial revision, via `key_vandermonde`:
`∑_{j=k}^{n} (-1)^{j+k} C(n+j,j-k) C(n+k,j+k) = (-1)^{n-k}`.
-/
lemma firstSum_value {n k : ℕ} (h : k ≤ n) :
    ∑ j ∈ Finset.Icc k n,
        (-1 : ℤ) ^ (j + k) * Nat.choose (n + j) (j - k) * Nat.choose (n + k) (j + k)
      = (-1) ^ (n - k) := by
  -- By changing the index of summation, let $i = j - k$.
  suffices h_sum : (∑ i ∈ Finset.range (n - k + 1), (-1 : ℤ) ^ (k + i + k) * (Nat.choose (n + k + i) i : ℤ) * (Nat.choose (n + k) (2 * k + i) : ℤ)) = (-1 : ℤ) ^ (n - k) by
    erw [ Finset.sum_Ico_eq_sum_range ] ; convert h_sum using 2 ; ring;
    · rw [ Nat.add_sub_assoc h ];
    · grind;
  convert key_vandermonde ( n + k ) ( n - k ) using 1;
  refine' Finset.sum_congr rfl fun i hi => _;
  rw [ show 2 * k + i = n + k - ( n - k - i ) by { norm_num at *; omega } ] ; rw [ Nat.choose_symm ( by { norm_num at *; omega } ) ] ; ring;
  norm_num [ pow_mul' ]

/-
Value of the `SecondSum` after trinomial revision, via `key_vandermonde`:
`∑_{j=k+1}^{n} (-1)^{j+k} C(n+j,j-k-1) C(n+k+1,j+k+1) = (-1)^{n-k}` (for `k < n`).
-/
lemma secondSum_value {n k : ℕ} (h : k < n) :
    ∑ j ∈ Finset.Icc (k + 1) n,
        (-1 : ℤ) ^ (j + k) * Nat.choose (n + j) (j - k - 1) * Nat.choose (n + k + 1) (j + k + 1)
      = (-1) ^ (n - k) := by
  -- Reindex the sum with $j = (k+1) + i$ where $i$ ranges over $[0, n-k-1]$.
  have h_reindex : ∑ j ∈ Finset.Icc (k + 1) n, (-1 : ℤ) ^ (j + k) * Nat.choose (n + j) (j - k - 1) * Nat.choose (n + k + 1) (j + k + 1) =
    ∑ i ∈ Finset.range (n - k), (-1 : ℤ) ^ ((k + 1 + i) + k) * Nat.choose (n + (k + 1 + i)) ((k + 1 + i) - k - 1) * Nat.choose (n + k + 1) ((k + 1 + i) + k + 1) := by
      erw [ Finset.sum_Ico_eq_sum_range ];
      rw [ Nat.add_sub_add_right ];
  simp_all +decide [ Nat.sub_sub, add_assoc ];
  convert congr_arg Neg.neg ( key_vandermonde ( n + k + 1 ) ( n - k - 1 ) ) using 1 ; ring;
  · rw [ show 1 + ( n - k - 1 ) = n - k by omega ] ; rw [ ← Finset.sum_neg_distrib ] ; refine' Finset.sum_congr rfl fun x hx => _ ; ring;
    rw [ show 2 + k * 2 + x = ( 1 + k + n ) - ( n - k - 1 - x ) from ?_ ] ; rw [ Nat.choose_symm_of_eq_add ] ; ring;
    any_goals exact 1 + k + n;
    · simp +decide [ Nat.choose_symm ( show n - k - 1 - x ≤ 1 + k + n from by omega ) ];
    · ring;
    · grind;
  · rw [ ← Nat.sub_add_cancel ( Nat.sub_pos_of_lt h ), pow_add ] ; norm_num

/-
**First orthogonality relation** (`T · S = I`):
`∑_{j} C(n+j, 2j) · S_{j,k} = [n = k]`.
-/
theorem orthogonality (n k : ℕ) :
    ∑ j ∈ range (n + 1), sprug n j * invSprug j k = if n = k then 1 else 0 := by
  by_cases h : n < k;
  · simp +decide [ h.ne ];
    exact Finset.sum_eq_zero fun x hx => by rw [ invSprug_of_lt ( by linarith [ Finset.mem_range.mp hx ] ) ] ; ring;
  · by_cases h' : k < n <;> simp_all +decide [ sprug, invSprug ];
    · -- For $k < n$, split the sum into two parts: one where $j = k$ and the other where $j > k$.
      have h_split : ∑ j ∈ Finset.range (n + 1), (if j < k then 0 else (-1 : ℤ) ^ (j + k) * (Nat.choose (n + j) (2 * j) * Nat.choose (2 * j) (j - k) - (if k < j then Nat.choose (n + j) (2 * j) * Nat.choose (2 * j) (j - k - 1) else 0))) = ∑ j ∈ Finset.Icc k n, (-1 : ℤ) ^ (j + k) * (Nat.choose (n + j) (j - k) * Nat.choose (n + k) (j + k) - (if k < j then Nat.choose (n + j) (j - k - 1) * Nat.choose (n + k + 1) (j + k + 1) else 0)) := by
        erw [ Finset.sum_ite ] ; norm_num;
        refine' Finset.sum_congr _ _;
        · grind;
        · intro x hx; split_ifs <;> simp_all +decide [ mul_comm ] ;
          · grind +suggestions;
          · grind;
      -- Apply the results of the trinomial revisions and the key vandermonde identity.
      have h_sum : ∑ j ∈ Finset.Icc k n, (-1 : ℤ) ^ (j + k) * (Nat.choose (n + j) (j - k) * Nat.choose (n + k) (j + k) - (if k < j then Nat.choose (n + j) (j - k - 1) * Nat.choose (n + k + 1) (j + k + 1) else 0)) = (-1 : ℤ) ^ (n - k) - (-1 : ℤ) ^ (n - k) := by
        convert congr_arg₂ ( · - · ) ( firstSum_value h ) ( secondSum_value h' ) using 1;
        rw [ show ( Finset.Icc k n : Finset ℕ ) = Finset.Icc ( k + 1 ) n ∪ { k } from ?_, Finset.sum_union ] <;> norm_num [ mul_assoc ];
        · rw [ add_comm, Finset.sum_congr rfl fun x hx => by rw [ if_pos ( by linarith [ Finset.mem_Icc.mp hx ] ) ] ] ; norm_num [ mul_sub ] ; ring;
        · grind;
      convert h_split.trans h_sum using 1;
      · exact Finset.sum_congr rfl fun x hx => by split_ifs <;> simp +decide [ *, mul_sub, mul_comm, mul_left_comm ] ;
      · grind;
    · obtain rfl : n = k := le_antisymm h' h
      rw [if_pos rfl, Finset.sum_range_succ,
        Finset.sum_eq_zero (fun x hx => if_pos (Finset.mem_range.mp hx))]
      simp [two_mul, Nat.choose_self]

/-
**Second orthogonality relation** (`S · T = I`):
`∑_{j} S_{n,j} · C(j+k, 2k) = [n = k]`.
-/
theorem orthogonality' (n k : ℕ) :
    ∑ j ∈ range (n + 1), invSprug n j * sprug j k = if n = k then 1 else 0 := by
  by_cases h : k > n;
  · rw [ if_neg ( ne_of_lt h ) ];
    exact Finset.sum_eq_zero fun i hi => by rw [ sprug, Nat.choose_eq_zero_of_lt ( by linarith [ Finset.mem_range.mp hi ] ) ] ; ring;
  · -- Set up the square matrices A and B with the appropriate entries.
    set A : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ := fun i j => sprug i.val j.val
    set B : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ := fun i j => invSprug i.val j.val;
    -- By definition of $A$ and $B$, we know that $A * B = 1$.
    have hAB : A * B = 1 := by
      ext i j;
      convert orthogonality i.val j.val using 1;
      · rw [ Matrix.mul_apply, Finset.sum_fin_eq_sum_range ];
        rw [ Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ i.is_le ) ) ];
        · exact Finset.sum_congr rfl fun x hx => by aesop;
        · simp +contextual [ sprug, invSprug ];
          exact fun x hx₁ hx₂ hx₃ => Or.inl <| Nat.choose_eq_zero_of_lt <| by omega;
      · simp +decide [ Matrix.one_apply, Fin.ext_iff ];
    -- By definition of $A$ and $B$, we know that $B * A = 1$.
    have hBA : B * A = 1 := by
      rw [ ← mul_eq_one_comm, hAB ];
    replace hBA := congr_fun ( congr_fun hBA ⟨ n, by linarith ⟩ ) ⟨ k, by linarith ⟩ ; simp_all +decide [ Matrix.mul_apply, Finset.sum_range ] ;
    simp_all +decide [ Matrix.one_apply ];
    convert hBA using 1

/-- **Row sums of the inverse array vanish** (except in row `0`):
`∑_{k} S_{n,k} = [n = 0]`.  This is the column-`0` instance of `orthogonality'`,
since column `0` of `T` is the all-ones vector (`T_{j,0} = C(j,0) = 1`). -/
theorem invSprug_row_sum (n : ℕ) :
    ∑ k ∈ range (n + 1), invSprug n k = if n = 0 then 1 else 0 := by
  have h := orthogonality' n 0
  simpa [sprug] using h

/-
**Alternating row sums of the inverse array** are signed central binomial
coefficients: `∑_{k} (-1)^k S_{n,k} = (-1)^n C(2n, n)`.

-- !-- Lab Notes (cycle 2) -- !--
-- !-- Hypothesis: weighting the inverse array's rows by `(-1)^k` produces a clean
--     sequence. Experiment (#eval, n=0..11): 1,-2,6,-20,70,-252,... = (-1)^n·C(2n,n)
--     (OEIS A000984 with alternating sign). -- !--
-- !-- Analysis: after multiplying `S_{n,k}=(-1)^{n+k}(C(2n,n-k)-[k<n]C(2n,n-k-1))`
--     by `(-1)^k`, the sign collapses to `(-1)^n` and the binomial-difference sum
--     telescopes: ∑_{k=0}^n C(2n,n-k) − ∑_{k=0}^{n-1} C(2n,n-k-1) = C(2n,n). -- !--
-/
theorem invSprug_alternating_row_sum (n : ℕ) :
    ∑ k ∈ range (n + 1), (-1 : ℤ) ^ k * invSprug n k = (-1) ^ n * (Nat.centralBinom n : ℤ) := by
  -- Apply the trinomial revision identities and the Vandermonde identity to simplify the sum.
  have h_sum : ∑ k ∈ Finset.range (n + 1), (-1 : ℤ) ^ k * invSprug n k = (-1 : ℤ) ^ n * ∑ k ∈ Finset.range (n + 1), (Nat.choose (2 * n) (n - k) : ℤ) - (-1 : ℤ) ^ n * ∑ k ∈ Finset.range n, (Nat.choose (2 * n) (n - k - 1) : ℤ) := by
    rw [ Finset.mul_sum _ _ _, Finset.mul_sum _ _ _ ];
    simp +decide [ Finset.sum_range_succ, invSprug ];
    rw [ Finset.sum_congr rfl fun x hx => by rw [ if_neg ( by linarith [ Finset.mem_range.mp hx ] ) ] ] ; ring;
    simp +decide [ Finset.sum_sub_distrib, pow_mul', Finset.sum_range ];
  convert h_sum using 1;
  norm_num [ Finset.sum_range_succ', Nat.centralBinom ];
  norm_num [ Nat.sub_sub, mul_add ]

end InverseSprugnoliArray