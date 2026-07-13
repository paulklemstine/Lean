/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# A Hirzebruch–Riemann–Roch (P^K = Hilb) identity for the Boolean matroid

This file develops, in a fully self-contained and computable way, the
`P^K = Hilb` identity of the research mission specialised to the **Boolean
matroid** `B_n` (the free matroid on `n` elements) with its maximal
Feichtner–Yuzvinsky building set.

## Geometric background (informal)

For the Boolean matroid `B_n`, the wonderful compactification with the maximal
building set is the **permutohedral toric variety** `X_n` of dimension `n - 1`.
The Chow ring `A*(B_n)` is its cohomology ring, a graded Poincaré-duality
algebra of top degree `n - 1`.  Its graded Betti numbers (the Hilbert function
of the Chow ring) are the **Eulerian numbers** `⟨n, k⟩`: they form the `h`-vector
of the permutohedron.  Hence the Hilbert series of the Chow ring is the
**Eulerian polynomial**

  `Hilb(A*(B_n), t) = ∑_{k=0}^{n-1} ⟨n, k⟩ tᵏ`.

The K-theory side (Theorem A, property 2 of the mission) asserts that the
K-polynomial of the *integral tangent class* `T^Z` equals this Hilbert series.
On the permutohedral variety the K-polynomial coefficients are given by the
classical **inclusion–exclusion / Euler-characteristic formula** for Eulerian
numbers,

  `⟨n, k⟩ = ∑_{j=0}^{k} (-1)ʲ · C(n+1, j) · (k+1-j)ⁿ`,

an *alternating sum* (a genuine Euler characteristic) rather than a manifest
dimension count.  The equality of this alternating K-theoretic expression with
the Hilbert-series (dimension) coefficient is exactly the `P^K = Hilb` identity
in this case, and it is proved here as `tangentKPoly_eq_hilbChow`.

## Main results

* `eulerian` — the Eulerian numbers, defined by the triangle recurrence.
* `eulerian_symm` — **Poincaré duality**: `⟨n,k⟩ = ⟨n, n-1-k⟩` (palindromicity
  of the Hilbert series of the Chow ring).
* `eulerian_row_sum` — the value of the Hilbert series at `t = 1` equals `n !`,
  i.e. `dim_ℚ A*(B_n) = n !` (number of maximal cones of the permutohedral fan).
* `worpitzky` — **Worpitzky's identity** `mⁿ = ∑_k ⟨n,k⟩ · C(m+k, n)`, the
  Riemann–Roch generating-function bridge between lattice-point / Euler
  characteristic counts and the Hilbert data.
* `eulerian_explicit` — the alternating Euler-characteristic formula for the
  Eulerian numbers.
* `tangentKPoly_eq_hilbChow` — **the `P^K = Hilb` identity**: the K-polynomial
  of the integral tangent class equals the Hilbert series of the Chow ring, as
  polynomials in `ℤ[t]`.
* `hilbChow_eval_one`, `hilbChow_palindrome` — Poincaré-duality consequences at
  the level of the Hilbert polynomial.
-/

namespace HRRMatroidBoolean

-- Several of the binomial/finite-difference identities below use heavy `nlinarith`/`grind`
-- normalisation; allow them extra elaboration budget.
set_option maxHeartbeats 1600000

open Finset

/-! ## The Eulerian numbers (graded Betti numbers of the Chow ring) -/

/-- The Eulerian number `⟨n, k⟩`, the number of permutations of `{1,…,n}` with
exactly `k` descents.  Geometrically this is `dim A^k(B_n)`, the `k`-th graded
Betti number of the Chow ring of the Boolean matroid `B_n` (equivalently the
`k`-th entry of the `h`-vector of the permutohedron). -/
def eulerian : ℕ → ℕ → ℕ
  | 0, 0 => 1
  | 0, (_ + 1) => 0
  | (_ + 1), 0 => 1
  | (n + 1), (k + 1) => (k + 2) * eulerian n (k + 1) + (n - k) * eulerian n k

@[simp] theorem eulerian_zero_zero : eulerian 0 0 = 1 := rfl

@[simp] theorem eulerian_zero_succ (k : ℕ) : eulerian 0 (k + 1) = 0 := rfl

@[simp] theorem eulerian_succ_zero (n : ℕ) : eulerian (n + 1) 0 = 1 := rfl

theorem eulerian_succ_succ (n k : ℕ) :
    eulerian (n + 1) (k + 1) = (k + 2) * eulerian n (k + 1) + (n - k) * eulerian n k := rfl

/-- The classical recurrence in the standard normalisation
`⟨n+1,k⟩ = (k+1)·⟨n,k⟩ + (n+1-k)·⟨n,k-1⟩`, here stated for the shifted index. -/
theorem eulerian_recurrence (n k : ℕ) :
    eulerian (n + 1) (k + 1) = (k + 2) * eulerian n (k + 1) + (n - k) * eulerian n k :=
  eulerian_succ_succ n k

/-
Above the top degree the Betti numbers vanish: `⟨n, k⟩ = 0` for `k ≥ n ≥ 1`.
-/
theorem eulerian_eq_zero_of_le {n k : ℕ} (hn : 0 < n) (h : n ≤ k) : eulerian n k = 0 := by
  induction' n with n ih generalizing k;
  · contradiction;
  · rcases k with ( _ | _ | k ) <;> simp_all +decide [ eulerian_succ_succ ];
    grind +suggestions

/-! ## Poincaré duality: palindromicity of the Hilbert series -/

/-
**Poincaré duality of the Chow ring.**  The Eulerian numbers are symmetric,
`⟨n, k⟩ = ⟨n, n-1-k⟩` for `k < n`.  Equivalently `dim A^k(B_n) = dim A^{n-1-k}(B_n)`,
the palindromicity of the Hilbert series forced by Poincaré duality on the
`(n-1)`-dimensional permutohedral variety.
-/
theorem eulerian_symm {n k : ℕ} (h : k < n) : eulerian n k = eulerian n (n - 1 - k) := by
  induction' n with n ih generalizing k <;> simp_all +decide [ Nat.sub_sub, add_comm ];
  cases' k with k <;> simp_all +decide [ eulerian_succ_succ ];
  · -- By induction on $n$, we can show that $eulerian (n + 1) n = 1$ for all $n$.
    have h_ind : ∀ n, eulerian (n + 1) n = 1 := by
      intro n; induction' n with n ih <;> simp_all +decide [ eulerian_succ_succ ] ;
      grind +suggestions
    exact Eq.symm (h_ind n);
  · by_cases h₂ : k + 1 < n;
    · rw [ show n - ( k + 1 ) = ( n - ( k + 1 ) - 1 ) + 1 from by omega ];
      grind +suggestions;
    · norm_num [ show n = k + 1 by linarith ] at *;
      exact eulerian_eq_zero_of_le ( Nat.succ_pos _ ) ( by linarith )

/-! ## Total dimension: the value of the Hilbert series at `t = 1` -/

/-
**Total dimension of the Chow ring.**  The sum of the graded Betti numbers is
`n !`; i.e. `Hilb(A*(B_n), 1) = dim_ℚ A*(B_n) = n !`, the number of maximal cones
of the permutohedral fan.
-/
theorem eulerian_row_sum (n : ℕ) : ∑ k ∈ range (n + 1), eulerian n k = Nat.factorial n := by
  revert n;
  intro n; induction' n with n ih <;> simp_all +decide [ Nat.factorial_succ ];
  rw [ ← ih, Finset.sum_range_succ' ];
  simp +arith +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, eulerian_succ_succ ];
  rw [ Finset.sum_range_succ, Finset.sum_range_succ' ];
  simp +arith +decide [ Finset.sum_range_succ', eulerian_eq_zero_of_le ];
  simp +arith +decide [ ← add_mul, ← Finset.sum_add_distrib, eulerian_eq_zero_of_le ];
  rw [ Finset.sum_congr rfl fun x hx => by rw [ show x + 2 + ( n - ( x + 1 ) ) = n + 1 by linarith [ Nat.sub_add_cancel ( show x + 1 ≤ n from by linarith [ Finset.mem_range.mp hx ] ) ] ] ] ; simp +arith +decide [ eulerian_eq_zero_of_le ] ; ring;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ eulerian_eq_zero_of_le ]

/-! ## Worpitzky's identity: the Riemann–Roch generating-function bridge -/

/-
**Worpitzky's identity.**  `mⁿ = ∑_{k} ⟨n,k⟩ · C(m+k, n)`.  The left-hand side
is the K-theoretic Euler-characteristic / lattice-point count `χ(X_n, Lᵐ)` while
the coefficients on the right are the Hilbert-series (Chow Betti) numbers; the
identity is the Riemann–Roch bridge relating the two.
-/
theorem worpitzky (m n : ℕ) :
    m ^ n = ∑ k ∈ range (n + 1), eulerian n k * (m + k).choose n := by
  induction' n using Nat.case_strong_induction_on with n ih generalizing m;
  · norm_num [ eulerian ];
  · -- Split the sum into two parts: one involving eulerian n k and the other involving eulerian n (k-1).
    have h_split : ∑ k ∈ Finset.range (n + 2), eulerian (n + 1) k * Nat.choose (m + k) (n + 1) = ∑ k ∈ Finset.range (n + 1), eulerian n k * (k + 1) * Nat.choose (m + k) (n + 1) + ∑ k ∈ Finset.range (n + 1), eulerian n k * (n - k) * Nat.choose (m + k + 1) (n + 1) := by
      rw [ Finset.sum_range_succ' ];
      simp +decide [ eulerian_succ_succ, mul_assoc, mul_comm, mul_left_comm, Finset.sum_add_distrib ];
      rw [ Finset.sum_range_succ ] ; simp +decide [ add_assoc, mul_add, mul_comm, mul_left_comm, Finset.sum_add_distrib ] ; ring;
      rw [ add_comm 1 n, Finset.sum_range_succ' ] ; simp +decide [ add_comm, add_left_comm, add_assoc, mul_comm, mul_assoc, mul_left_comm, Finset.sum_add_distrib ] ; ring;
      rw [ add_comm 1 n, Finset.sum_range_succ ] ; simp +decide [ add_comm, add_left_comm, add_assoc, mul_comm, mul_assoc, mul_left_comm, Finset.sum_add_distrib ] ; ring;
      rw [ show eulerian n ( 1 + n ) = 0 from _ ] ; simp +decide [ add_comm 1, mul_assoc, mul_comm, mul_left_comm, Finset.sum_add_distrib ] ; ring;
      · simp +decide [ Finset.sum_mul _ _ _, eulerian_succ_zero ];
        cases n <;> simp +decide [ eulerian_succ_zero ];
      · by_cases hn : 0 < n <;> simp_all +decide [ add_comm, eulerian_eq_zero_of_le ];
    -- Apply the identity $(k+1) \cdot \binom{m+k}{n+1} + (n-k) \cdot \binom{m+k+1}{n+1} = m \cdot \binom{m+k}{n}$ to each term in the sum.
    have h_identity : ∀ k ∈ Finset.range (n + 1), (k + 1) * Nat.choose (m + k) (n + 1) + (n - k) * Nat.choose (m + k + 1) (n + 1) = m * Nat.choose (m + k) n := by
      intro k hk; by_cases h : n ≤ m + k <;> simp_all +decide [ Nat.choose_succ_succ, mul_comm ] ;
      · nlinarith only [ Nat.sub_add_cancel hk, Nat.sub_add_cancel h, Nat.add_one_mul_choose_eq ( m + k ) n, Nat.choose_succ_succ ( m + k ) n ];
      · simp_all +decide [ Nat.choose_eq_zero_of_lt ( by linarith : m + k < n + 1 ), Nat.choose_eq_zero_of_lt ( by linarith : m + k < n ) ];
    simp_all +decide [ ← mul_assoc, ← Finset.sum_add_distrib ];
    convert congr_arg ( fun x : ℕ => m * x ) ( ih n le_rfl m ) using 1;
    · ring;
    · rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun x hx => by nlinarith only [ h_identity x ( Finset.mem_range_succ_iff.mp hx ), eulerian n x ] ;

/-! ## The alternating (Euler characteristic) formula: P^K = Hilb -/

/-- The K-theoretic coefficient of the integral tangent class in degree `k`,
written as the inclusion–exclusion / Euler-characteristic alternating sum
`∑_{j=0}^{k} (-1)ʲ C(n+1, j) (k+1-j)ⁿ`. -/
def tangentKCoeff (n k : ℕ) : ℤ :=
  ∑ j ∈ range (k + 1), (-1) ^ j * (Nat.choose (n + 1) j : ℤ) * ((k + 1 - j : ℕ) : ℤ) ^ n

/-
Base value: the K-theoretic coefficient in degree `0` is `1` (single term).
-/
theorem tangentKCoeff_zero_right (n : ℕ) : tangentKCoeff n 0 = 1 := by
  unfold tangentKCoeff; norm_num

/-
The K-theoretic coefficients satisfy the Eulerian recurrence, as an **integer**
identity valid for all `k` (with the honest integer coefficient `(n : ℤ) - k`).
-/
theorem tangentKCoeff_recurrence (n k : ℕ) :
    tangentKCoeff (n + 1) (k + 1)
      = (k + 2) * tangentKCoeff n (k + 1) + ((n : ℤ) - k) * tangentKCoeff n k := by
  have h_rewrite : ∑ j ∈ Finset.range (k + 2), ((-1 : ℤ) ^ j) * (Nat.choose (n + 2) j) * (k + 2 - j) ^ (n + 1) = ∑ j ∈ Finset.range (k + 2), ((-1 : ℤ) ^ j) * (Nat.choose (n + 1) j) * (k + 2 - j) ^ (n + 1) + ∑ j ∈ Finset.range (k + 1), ((-1 : ℤ) ^ (j + 1)) * (Nat.choose (n + 1) j) * (k + 1 - j) ^ (n + 1) := by
    rw [ Finset.sum_range_succ' ];
    rw [ Finset.sum_range_succ' _ ( k + 1 ) ] ; norm_num [ Nat.choose_succ_succ, pow_succ' ] ; ring;
    norm_num [ Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ; ring;
  have h_split : ∑ j ∈ Finset.range (k + 2), ((-1 : ℤ) ^ j) * (Nat.choose (n + 1) j) * (k + 2 - j) ^ (n + 1) = (k + 2) * ∑ j ∈ Finset.range (k + 2), ((-1 : ℤ) ^ j) * (Nat.choose (n + 1) j) * (k + 2 - j) ^ n - ∑ j ∈ Finset.range (k + 2), ((-1 : ℤ) ^ j) * (Nat.choose (n + 1) j) * j * (k + 2 - j) ^ n := by
    rw [ Finset.mul_sum _ _ _ ];
    rw [ ← Finset.sum_sub_distrib ] ; congr ; ext ; ring;
  have h_split2 : ∑ j ∈ Finset.range (k + 2), ((-1 : ℤ) ^ j) * (Nat.choose (n + 1) j) * j * (k + 2 - j) ^ n = (n + 1) * ∑ j ∈ Finset.range (k + 1), ((-1 : ℤ) ^ (j + 1)) * (Nat.choose n j) * (k + 1 - j) ^ n := by
    have h_split2 : ∀ j ∈ Finset.range (k + 2), ((-1 : ℤ) ^ j) * (Nat.choose (n + 1) j) * j * (k + 2 - j) ^ n = if j = 0 then 0 else (n + 1) * ((-1 : ℤ) ^ j) * (Nat.choose n (j - 1)) * (k + 2 - j) ^ n := by
      intro j hj; rcases j with ( _ | j ) <;> simp_all +decide ; ring;
      rw [ Nat.add_comm 1 n, Nat.add_comm 1 j ] ; have := Nat.add_one_mul_choose_eq n j; simp_all +decide [ Nat.choose_succ_succ, pow_succ' ] ; ring;
      exact Or.inl ( by rw [ show 1 + j = j + 1 by ring ] ; push_cast [ ← @Nat.cast_inj ℤ ] at *; linear_combination' this * ( -1 ) ^ j );
    rw [ Finset.sum_congr rfl h_split2, Finset.sum_range_succ' ] ; norm_num [ Finset.mul_sum _ _ _ ] ; ring;
  convert h_rewrite using 1;
  · exact Finset.sum_congr rfl fun x hx => by rw [ Nat.cast_sub ( by linarith [ Finset.mem_range.mp hx ] ) ] ; push_cast; ring;
  · rw [ h_split, h_split2 ];
    unfold tangentKCoeff;
    rw [ Finset.sum_congr rfl fun x hx => by rw [ Nat.cast_sub ( by linarith [ Finset.mem_range.mp hx ] ) ] ] ; norm_num [ pow_succ, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
    rw [ ← Finset.sum_sub_distrib ] ; refine' congr_arg₂ _ rfl ( Finset.sum_congr rfl fun x hx => _ ) ; rw [ Nat.cast_sub ( by linarith [ Finset.mem_range.mp hx ] ) ] ; push_cast ; ring;
    rw [ show ( 1 + n ).choose x = n.choose x + n.choose ( x - 1 ) * ( if x = 0 then 0 else 1 ) by cases x <;> simp +decide [ Nat.choose_succ_succ, add_comm ] ] ; ring;
    cases x <;> simp +decide [ add_comm ] ; ring;
    have := Nat.choose_succ_right_eq n ‹_›; norm_cast at *; simp_all +decide ; ring;
    rw [ add_comm 1 ] ; rw [ ← @Nat.cast_inj ℤ ] at * ; push_cast at * ; cases le_total n ‹_› <;> simp_all +decide [ Nat.choose_eq_zero_of_lt ] ; ring;
    · cases eq_or_lt_of_le ‹_› <;> simp_all +decide [ Nat.choose_eq_zero_of_lt ] ; ring;
      rw [ Nat.choose_eq_zero_of_lt ( by linarith ) ] ; ring;
    · grind

/-
**The alternating Euler-characteristic formula for the Eulerian numbers.**
The manifestly-alternating K-theoretic coefficient equals the (nonnegative)
Hilbert-series Betti number: `⟨n,k⟩ = ∑_{j} (-1)ʲ C(n+1,j) (k+1-j)ⁿ`.
-/
theorem eulerian_explicit (n k : ℕ) : (eulerian n k : ℤ) = tangentKCoeff n k := by
  induction' n with n ih generalizing k;
  · cases k <;> simp +decide [ *, tangentKCoeff ];
    induction ‹_› <;> simp_all +decide [ Finset.sum_range_succ', pow_succ', Nat.choose_succ_succ ];
  · rcases k with ( _ | k );
    · unfold tangentKCoeff; norm_num [ eulerian_succ_zero ] ;
    · rw [ eulerian_succ_succ, tangentKCoeff_recurrence ];
      by_cases h : k < n;
      · simp +decide [ ← ih, Nat.cast_sub h.le ];
      · simp_all +decide [ Nat.sub_eq_zero_of_le ( le_of_not_gt h ) ];
        by_cases hn : 0 < n;
        · exact Or.inr ( ih k ▸ mod_cast eulerian_eq_zero_of_le hn h );
        · unfold tangentKCoeff; induction k <;> simp_all +decide [ Finset.sum_range_succ', Nat.choose_succ_succ ] ;

/-! ## Polynomial packaging: `P^K = Hilb` in `ℤ[t]` -/

open Polynomial

/-- The **Hilbert series of the Chow ring** `A*(B_n)`, as a polynomial in `ℤ[t]`:
`∑_{k=0}^{n} ⟨n,k⟩ tᵏ` (the top nonzero term is in degree `n-1`). -/
noncomputable def hilbChow (n : ℕ) : Polynomial ℤ :=
  ∑ k ∈ range (n + 1), C (eulerian n k : ℤ) * X ^ k

/-- The **K-polynomial of the integral tangent class** `T^Z`, defined through the
alternating Euler-characteristic coefficients `tangentKCoeff`. -/
noncomputable def tangentKPoly (n : ℕ) : Polynomial ℤ :=
  ∑ k ∈ range (n + 1), C (tangentKCoeff n k) * X ^ k

/-
**The `P^K = Hilb` identity (Boolean matroid).**  The K-polynomial of the
integral tangent class `T^Z_{B_n}` equals the Hilbert series of the Chow ring
`A*(B_n)`, as polynomials in `ℤ[t]`.
-/
theorem tangentKPoly_eq_hilbChow (n : ℕ) : tangentKPoly n = hilbChow n := by
  exact Finset.sum_congr rfl fun x hx => by rw [ eulerian_explicit ] ;

/-
The Hilbert polynomial evaluated at `1` gives the total dimension `n !`.
-/
theorem hilbChow_eval_one (n : ℕ) : (hilbChow n).eval 1 = (Nat.factorial n : ℤ) := by
  convert eulerian_row_sum n using 1;
  rw [ ← @Nat.cast_inj ℤ ] ; norm_num [ Polynomial.eval_finset_sum, hilbChow ]

/-
Coefficient extraction for the Hilbert polynomial.
-/
theorem hilbChow_coeff (n k : ℕ) (hk : k ≤ n) :
    (hilbChow n).coeff k = (eulerian n k : ℤ) := by
  unfold hilbChow;
  simp +zetaDelta at *;
  exact fun h => False.elim <| h.not_ge hk

/-
**Palindromicity of the Hilbert polynomial** (Poincaré duality at the level
of coefficients): `coeff k = coeff (n-1-k)` for `k < n`.
-/
theorem hilbChow_palindrome {n k : ℕ} (h : k < n) :
    (hilbChow n).coeff k = (hilbChow n).coeff (n - 1 - k) := by
  rw [ hilbChow_coeff, hilbChow_coeff, eulerian_symm h ];
  · omega;
  · linarith

end HRRMatroidBoolean