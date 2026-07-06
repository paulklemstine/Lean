import Mathlib

/-!
# Rogers–Ramanujan / Schur polynomials via Gaussian binomial coefficients

This file develops the **finite (polynomial) core** of the Rogers–Ramanujan
identities.  The full Rogers–Ramanujan identities equate an infinite `q`-series
`∑_{k≥0} q^{k²}/(q;q)_k` with the infinite product
`∏_{j≥0} 1/((1−q^{5j+1})(1−q^{5j+4}))`.  Their combinatorial heart is a *finite*
polynomial identity due to **I. Schur** (see Andrews, *The Theory of Partitions*,
1976; Gasper–Rahman, *Basic Hypergeometric Series*, 1990): the Rogers–Ramanujan
polynomials satisfy a Fibonacci-type recurrence and admit a closed form as a
sum of Gaussian binomial coefficients weighted by `q^{k²}`.

We work with polynomials in `ℤ[q]` (`q := Polynomial.X`).

* `gauss n k` : the Gaussian binomial coefficient `[n choose k]_q`, defined by the
  `q`-Pascal recurrence.
* `gauss_pascalII` : the *second* `q`-Pascal rule (a nontrivial consequence of the
  defining one).
* `gauss_eval_one` : specializing `q = 1` turns `[n choose k]_q` into the ordinary
  binomial coefficient `C(n,k)`.
* `rrPoly n` : the Rogers–Ramanujan (Schur) polynomial `D_n`, defined by
  `D_0 = D_1 = 1`, `D_{n+2} = D_{n+1} + q^{n+1} D_n`.
* `gauss_finitization` : **the finite Rogers–Ramanujan identity**
  `D_n = ∑_{k} q^{k²} [n-k choose k]_q`.
* `rrPoly_eval_one` : at `q = 1` the Rogers–Ramanujan polynomial equals a
  Fibonacci number, `D_n(1) = F_{n+1}`.
* `rr_diagonal_fib` : the `q = 1` shadow of the finite identity — the classical
  diagonal-of-Pascal identity `∑_k C(n-k, k) = F_{n+1}`, bridging to the
  catalog's Fibonacci results.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The infinite Rogers–Ramanujan identities are not
  finitely checkable, but their combinatorial engine is a finite polynomial
  identity: the Schur/Rogers–Ramanujan polynomials `D_n` (a `q`-Fibonacci
  recurrence) should equal `∑_k q^{k²} [n-k,k]_q`.  We further conjectured that
  the `q → 1` specialization collapses to Fibonacci numbers, linking `q`-series
  to the catalog's Fibonacci circle of identities.
Experiment (Experimenter): We built a computable integer model `gaussV`, `rrV`
  and verified `rrV q n = ∑_k q^{k²} gaussV (n-k) k` for `q ∈ {-3,-2,-1,0,2,3,5,7}`
  and `n ≤ 13` (0 discrepancies), and confirmed `∑_k C(n-k,k) = F_{n+1}` for
  `n ≤ 12`.  See `ComputationalEvidence.md`.
Analysis (Analyst): see the closing note.
Critique (Critic): see the closing note.
Synthesis (PI): see the closing note.
-/

open Polynomial
open scoped Polynomial

namespace RogersRamanujanGauss

/-- Gaussian binomial coefficient `[n choose k]_q` in `ℤ[q]`, via the `q`-Pascal
recurrence `[n+1,k+1] = [n,k] + q^{k+1} [n,k+1]`. -/
noncomputable def gauss : ℕ → ℕ → Polynomial ℤ
  | _, 0 => 1
  | 0, (_ + 1) => 0
  | (n + 1), (k + 1) => gauss n k + (X : Polynomial ℤ) ^ (k + 1) * gauss n (k + 1)

@[simp] lemma gauss_zero_right (n : ℕ) : gauss n 0 = 1 := by cases n <;> rfl

@[simp] lemma gauss_zero_succ (k : ℕ) : gauss 0 (k + 1) = 0 := rfl

lemma gauss_succ_succ (n k : ℕ) :
    gauss (n + 1) (k + 1) = gauss n k + (X : Polynomial ℤ) ^ (k + 1) * gauss n (k + 1) := rfl

/--
Outside the valid range the Gaussian binomial vanishes.
-/
lemma gauss_eq_zero {n k : ℕ} (h : n < k) : gauss n k = 0 := by
  induction' n using Nat.case_strong_induction_on with n ih generalizing k;
  · cases k <;> aesop;
  · cases k <;> simp_all +arith +decide;
    grind +suggestions

/--
The **second `q`-Pascal rule**:
`[n+1, k+1] = [n, k+1] + q^{n-k} [n, k]`.  This is not the defining recurrence;
it is proved by induction and is the key ingredient in the finite
Rogers–Ramanujan identity.
-/
lemma gauss_pascalII (n k : ℕ) :
    gauss (n + 1) (k + 1) = gauss n (k + 1) + (X : Polynomial ℤ) ^ (n - k) * gauss n k := by
  induction' n with n ih generalizing k;
  · cases k <;> simp +decide [ gauss ];
  · cases k <;> simp_all +decide [ pow_succ ];
    · grind +locals;
    · rw [ gauss_succ_succ, ih, ih ];
      by_cases h : n ≤ ‹_› <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ];
      · rw [ gauss_eq_zero ( by linarith ), gauss_eq_zero ( by linarith ) ] ; ring;
      · grind +suggestions

/-- Rogers–Ramanujan (Schur) polynomial `D_n`. -/
noncomputable def rrPoly : ℕ → Polynomial ℤ
  | 0 => 1
  | 1 => 1
  | (n + 2) => rrPoly (n + 1) + (X : Polynomial ℤ) ^ (n + 1) * rrPoly n

lemma rrPoly_succ_succ (n : ℕ) :
    rrPoly (n + 2) = rrPoly (n + 1) + (X : Polynomial ℤ) ^ (n + 1) * rrPoly n := rfl

/-- The Rogers–Ramanujan sum side `∑_{k} q^{k²} [n-k choose k]_q`. -/
noncomputable def rrSum (n : ℕ) : Polynomial ℤ :=
  ∑ k ∈ Finset.range (n + 1), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n - k) k

/--
The sum side satisfies the Rogers–Ramanujan/Schur recurrence.
-/
lemma rrSum_succ_succ (n : ℕ) :
    rrSum (n + 2) = rrSum (n + 1) + (X : Polynomial ℤ) ^ (n + 1) * rrSum n := by
  have h_split : ∑ k ∈ Finset.range (n + 3), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n + 2 - k) k = ∑ k ∈ Finset.Ico 1 (n + 3), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n + 2 - k) k + 1 := by
    rw [ Finset.sum_Ico_eq_sub _ ] <;> norm_num;
  -- Apply `gauss_pascalII` to rewrite the sum.
  have h_rewrite : ∑ k ∈ Finset.Ico 1 (n + 3), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n + 2 - k) k = ∑ k ∈ Finset.Ico 1 (n + 3), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n + 1 - k) k + ∑ k ∈ Finset.Ico 1 (n + 3), (X : Polynomial ℤ) ^ (k ^ 2 + (n + 1 - k - (k - 1))) * gauss (n + 1 - k) (k - 1) := by
    rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl ];
    intro k hk; rcases k with ( _ | k ) <;> simp_all +decide ;
    have := gauss_pascalII ( n - k ) k;
    grind +suggestions;
  -- Simplify the second sum using the properties of exponents and Gaussian binomial coefficients.
  have h_simplify : ∑ k ∈ Finset.Ico 1 (n + 3), (X : Polynomial ℤ) ^ (k ^ 2 + (n + 1 - k - (k - 1))) * gauss (n + 1 - k) (k - 1) = X ^ (n + 1) * ∑ k ∈ Finset.range (n + 2), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n - k) k := by
    rw [ Finset.sum_Ico_eq_sum_range ];
    rw [ Finset.mul_sum _ _ _ ] ; refine' Finset.sum_congr rfl fun i hi => _ ; rcases i with ( _ | i ) <;> simp_all +decide [ add_comm, add_left_comm ] ; ring;
    by_cases h : n - ( 1 + i ) ≥ 1 + i <;> simp_all +decide [ Nat.sub_sub, add_comm 1 i ] ; ring;
    · rw [ show n = ( 2 + i * 2 ) + ( n - ( 2 + i * 2 ) ) by rw [ Nat.add_sub_cancel' ( by omega ) ] ] ; ring_nf ; aesop;
    · exact Or.inr ( gauss_eq_zero ( by omega ) );
  -- Combine the previous results to conclude the proof.
  have h_final : ∑ k ∈ Finset.range (n + 3), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n + 2 - k) k = ∑ k ∈ Finset.range (n + 2), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n + 1 - k) k + X ^ (n + 1) * ∑ k ∈ Finset.range (n + 2), (X : Polynomial ℤ) ^ (k ^ 2) * gauss (n - k) k := by
    rw [ h_split, h_rewrite, h_simplify, Finset.sum_Ico_eq_sub _ ] <;> norm_num [ Finset.sum_range_succ ];
    ring;
  convert h_final using 1;
  unfold rrSum; simp +decide [ Finset.sum_range_succ ] ;

/--
**The finite Rogers–Ramanujan identity** (Schur):
`D_n = ∑_{k} q^{k²} [n-k choose k]_q`.
-/
theorem gauss_finitization (n : ℕ) : rrPoly n = rrSum n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ rrPoly_succ_succ, rrSum_succ_succ ];
  · unfold rrPoly rrSum; norm_num;
  · unfold rrPoly rrSum;
    norm_num [ Finset.sum_range_succ ]

/--
Specializing `q = 1` turns the Gaussian binomial into the ordinary binomial.
-/
theorem gauss_eval_one (n k : ℕ) : (gauss n k).eval 1 = (n.choose k : ℤ) := by
  induction' n with n ih generalizing k <;> induction' k with k ihk <;> simp_all +decide [ Nat.choose ];
  rw [ gauss_succ_succ, Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_pow, Polynomial.eval_X ] ; aesop

/--
At `q = 1`, the Rogers–Ramanujan polynomial is a Fibonacci number:
`D_n(1) = F_{n+1}`.
-/
theorem rrPoly_eval_one (n : ℕ) : (rrPoly n).eval 1 = (Nat.fib (n + 1) : ℤ) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ rrPoly_succ_succ ];
  · exact Polynomial.eval_one;
  · finiteness;
  · simp +arith +decide [ Nat.fib_add_two ]

/--
The `q = 1` shadow of the finite Rogers–Ramanujan identity: the classical
diagonal-of-Pascal Fibonacci identity `∑_k C(n-k, k) = F_{n+1}`.
-/
theorem rr_diagonal_fib (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), (n - k).choose k = Nat.fib (n + 1) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n );
  · rfl;
  · decide +revert;
  · rw [ Finset.sum_range_succ' ];
    simp_all +arith +decide [ Nat.fib_add_two, Finset.sum_range_succ ];
    have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; simp_all +arith +decide [ Nat.choose_succ_succ, Finset.sum_range_succ' ];
    rw [ Finset.sum_congr rfl fun x hx => by rw [ Nat.succ_sub ( Finset.mem_range_le hx ), Nat.choose_succ_succ ] ];
    simp_all +arith +decide [ Finset.sum_add_distrib, Nat.fib_add_two ]

/-!
-- !-- Lab Notes (continued) -- !--
Analysis (Analyst): The polynomial identity `gauss_finitization` is the crux.
  What made it work was isolating the *second* `q`-Pascal rule `gauss_pascalII`
  (with the `q^{n-k}` weight) — the defining recurrence alone does not telescope
  the sum.  The truncated natural subtraction `n - k` is harmless precisely
  because `gauss (n-k) k = 0` whenever `k > n-k`, which `gauss_eq_zero` supplies.
  The Fibonacci specializations are "true and easy once the algebra is set up":
  they are two-step / Pascal inductions.
Critique (Critic): None of the main theorems is vacuous or definitional.
  `gauss_finitization` equates two genuinely different constructions (a two-term
  recurrence vs. a weighted binomial sum) and its proof requires an auxiliary
  induction (`gauss_pascalII`) plus a delicate sum reindexing.  `gauss_eval_one`
  and `rr_diagonal_fib` each require real inductions and are not closed by
  `decide`/`simp` alone.
Synthesis (PI): The finite Rogers–Ramanujan machinery lives happily in `ℤ[q]`;
  the bridge `q → 1` connects it to Fibonacci numbers, tying the `q`-series world
  to the catalog's Fibonacci identities.
-/

end RogersRamanujanGauss