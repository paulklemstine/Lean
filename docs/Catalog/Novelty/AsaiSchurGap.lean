/-
# The Schur constant is *not* comparable to the large sieve constant

This file continues the formalisation of the analytic skeleton of the paper
**"On the Second Moment of `L(1/2, As(f) × φ)`"** (`Novelty.AsaiLargeSieve`,
`Novelty.AsaiLargeSieveGram`, `Novelty.AsaiLargeSieveSharp`, …).  It **refutes** conjecture
**C1** of `FUTURE_DIRECTIONS.md` in its general form, and thereby delimits exactly the range
of validity of the positive result `AsaiLargeSieve.schur_row_le_two_mul_largeSieve_of_dominant`.

## The conjecture and its fate

C1 asserted that for every family the Schur constant
`K_Schur = max_{m<N} ∑_{n<N} ‖gram S lam m n‖` and the optimal large sieve constant `C_opt`
satisfy `C_opt ≤ K_Schur ≤ 2 · C_opt`.  The first inequality is
`AsaiLargeSieveGram.largeSieve_of_schur`.  The second is proved in
`AsaiLargeSieveSharp.schur_row_le_two_mul_largeSieve_of_dominant` under diagonal dominance —
the regime in which the paper works — and it is proved here that **it is false in general**,
and not merely with the constant `2`: no constant whatsoever works.

The counterexample is a rank-one family (`rankOneFamily`): a single form with eigenvalue
system `v = (1, ε, ε, …, ε)`, `M` copies of `ε`.  Its Gram matrix is `v vᵀ`, which is
Hermitian positive semidefinite, so no positivity hypothesis is being violated.  For this
family

* the trivial (and here optimal) large sieve constant is `‖v‖₂² = 1 + M ε²`
  (`largeSieve_rankOne`), while
* the Schur row at `m = 0` is `‖v‖_∞ ‖v‖₁ = 1 + M ε` (`schur_row_rankOne`).

Choosing `ε = 1/m` and `M = m³` gives `C = 1 + m` and `K_Schur ≥ 1 + m²`, a ratio `≍ m` which
is unbounded (`schur_row_gap_unbounded`); already `m = 4` (so `N = 65`, `C = 5`,
`K_Schur = 17`) breaks the conjectured constant `2`
(`schur_row_not_le_two_mul_largeSieve`).

## What survives, and the corrected statement (conjecture C8, settled here)

The positive result under diagonal dominance
(`AsaiLargeSieveSharp.schur_row_le_two_mul_largeSieve_of_dominant`) is untouched: the
counterexample is very far from diagonally dominant.  The correct comparison in general turns
out to be `K_Schur ≤ √N · C_opt`, and it is proved here for every family:

* `sum_normSq_gram_row_le` — the `ℓ²`-norm of a Gram row is at most `C`.  The proof tests the
  large sieve inequality against the row itself and uses Cauchy–Schwarz over the family.
* `schur_row_le_sqrt_mul_largeSieve` — hence `K_Schur ≤ √N · C`, improving the earlier
  unconditional `K_Schur ≤ N · C` (`AsaiLargeSieveSharp.schur_row_le_of_largeSieve`) by a full
  square root.
* `schur_row_sqrt_attained` — the exponent `1/2` is optimal up to a factor `2`: the rank-one
  family with `ε = 1/m` and `m²` copies of `ε` has `N = m² + 1`, admits `C = 2` and has Schur
  row `1 + m ≥ √N`.
* `schur_row_le_sqrt_mul_rankOne` — the rank-one case, proved directly.
-/
import Mathlib
import Novelty.AsaiLargeSieve
import Novelty.AsaiLargeSieveGram
import Novelty.AsaiLargeSieveSharp

open Finset Complex

namespace AsaiLargeSieve

/-- The rank-one counterexample family: a single form whose eigenvalue system is
`v = (1, ε, ε, …)`. -/
noncomputable def rankOneFamily (eps : ℝ) : Unit → ℕ → ℂ :=
  fun _ n => if n = 0 then 1 else (eps : ℂ)

/-- The `ℓ²`-mass of the rank-one system on `[0, M+1)`. -/
theorem sum_normSq_rankOne (eps : ℝ) (M : ℕ) :
    ∑ n ∈ Finset.range (M + 1), ‖rankOneFamily eps () n‖ ^ 2 = 1 + M * eps ^ 2 := by
  rw [Finset.sum_range_succ']
  simp [rankOneFamily, Complex.norm_real, Real.norm_eq_abs, sq_abs]
  ring

/-- The `ℓ¹`-mass of the rank-one system on `[0, M+1)`, for `ε ≥ 0`. -/
theorem sum_norm_rankOne {eps : ℝ} (heps : 0 ≤ eps) (M : ℕ) :
    ∑ n ∈ Finset.range (M + 1), ‖rankOneFamily eps () n‖ = 1 + M * eps := by
  rw [Finset.sum_range_succ']
  simp [rankOneFamily, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg heps]
  ring

/-- **The large sieve constant of the rank-one family** is its `ℓ²`-mass. -/
theorem largeSieve_rankOne (eps : ℝ) (M : ℕ) :
    LargeSieve (Finset.univ : Finset Unit) (rankOneFamily eps) (M + 1) (1 + M * eps ^ 2) := by
  have h := largeSieve_trivial (Finset.univ : Finset Unit) (rankOneFamily eps) (M + 1)
  have hsum : ∑ f ∈ (Finset.univ : Finset Unit),
      ∑ n ∈ Finset.range (M + 1), ‖rankOneFamily eps f n‖ ^ 2 = 1 + M * eps ^ 2 := by
    simp only [Finset.univ_unique, Finset.sum_singleton]
    exact sum_normSq_rankOne eps M
  rwa [hsum] at h

/-- **The Schur row of the rank-one family** at `m = 0` is `‖v‖_∞ · ‖v‖₁ = 1 + M ε`. -/
theorem schur_row_rankOne {eps : ℝ} (heps : 0 ≤ eps) (M : ℕ) :
    ∑ n ∈ Finset.range (M + 1),
        ‖gram (Finset.univ : Finset Unit) (rankOneFamily eps) 0 n‖ = 1 + M * eps := by
  have hpt : ∀ n, gram (Finset.univ : Finset Unit) (rankOneFamily eps) 0 n
      = (starRingEnd ℂ) (rankOneFamily eps () n) := by
    intro n
    rw [gram]
    simp [rankOneFamily]
  have : ∀ n, ‖gram (Finset.univ : Finset Unit) (rankOneFamily eps) 0 n‖
      = ‖rankOneFamily eps () n‖ := by
    intro n; rw [hpt n, RCLike.norm_conj]
  rw [Finset.sum_congr rfl fun n _ => this n]
  exact sum_norm_rankOne heps M

/-- **Conjecture C1 is false, with room to spare.**  For every constant `K` there is a family
(with Hermitian positive semidefinite Gram matrix) and an admissible large sieve constant `C`
for it whose Schur row at `m = 0` exceeds `K · C`.  Hence no inequality of the form
`K_Schur ≤ K · C_opt` can hold with an absolute constant `K`. -/
theorem schur_row_gap_unbounded (K : ℝ) :
    ∃ (N : ℕ) (lam : Unit → ℕ → ℂ) (C : ℝ),
      LargeSieve (Finset.univ : Finset Unit) lam N C ∧ 0 < C ∧
        K * C < ∑ n ∈ Finset.range N, ‖gram (Finset.univ : Finset Unit) lam 0 n‖ := by
  obtain ⟨m, hm2, hmK⟩ : ∃ m : ℕ, 2 ≤ m ∧ K + 2 ≤ (m : ℝ) := by
    refine ⟨⌈max K 0⌉₊ + 2, by omega, ?_⟩
    have h1 : K ≤ max K 0 := le_max_left _ _
    have h2 : max K 0 ≤ (⌈max K 0⌉₊ : ℝ) := Nat.le_ceil _
    push_cast
    linarith
  have hmR : (0 : ℝ) < (m : ℝ) := by
    have : (2 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm2
    linarith
  set eps : ℝ := 1 / (m : ℝ) with heps
  have heps0 : 0 ≤ eps := by positivity
  refine ⟨m ^ 3 + 1, rankOneFamily eps, 1 + (m ^ 3 : ℕ) * eps ^ 2,
    largeSieve_rankOne eps (m ^ 3), ?_, ?_⟩
  · have : (0 : ℝ) ≤ ((m ^ 3 : ℕ) : ℝ) * eps ^ 2 := by positivity
    linarith
  · rw [schur_row_rankOne heps0 (m ^ 3)]
    have hC : ((m ^ 3 : ℕ) : ℝ) * eps ^ 2 = (m : ℝ) := by
      rw [heps]
      push_cast
      field_simp
    have hR : ((m ^ 3 : ℕ) : ℝ) * eps = (m : ℝ) ^ 2 := by
      rw [heps]
      push_cast
      field_simp
    rw [hC, hR]
    -- `K · (1 + m) < 1 + m²` because `m ≥ K + 2`
    nlinarith [hmK, hmR]

/-- The case `K = 2`: the specific inequality conjectured in C1 fails. -/
theorem schur_row_not_le_two_mul_largeSieve :
    ∃ (N : ℕ) (lam : Unit → ℕ → ℂ) (C : ℝ),
      LargeSieve (Finset.univ : Finset Unit) lam N C ∧ 0 < C ∧
        2 * C < ∑ n ∈ Finset.range N, ‖gram (Finset.univ : Finset Unit) lam 0 n‖ :=
  schur_row_gap_unbounded 2

/-- **The rank-one case of the corrected comparison**: the Schur row never exceeds `√N` times
the `ℓ²`-mass, which for these families is the optimal large sieve constant.  (The general
case is `schur_row_le_sqrt_mul_largeSieve` below; this direct proof also shows the bound is
nearly attained for a suitable `ε`.) -/
theorem schur_row_le_sqrt_mul_rankOne {eps : ℝ} (heps : 0 ≤ eps) (M : ℕ) :
    ∑ n ∈ Finset.range (M + 1),
        ‖gram (Finset.univ : Finset Unit) (rankOneFamily eps) 0 n‖
      ≤ Real.sqrt ((M : ℝ) + 1) * ∑ n ∈ Finset.range (M + 1),
          ‖rankOneFamily eps () n‖ ^ 2 := by
  rw [schur_row_rankOne heps M, sum_normSq_rankOne eps M]
  have hM : (0 : ℝ) ≤ (M : ℝ) := Nat.cast_nonneg M
  have hs0 : 0 ≤ Real.sqrt ((M : ℝ) + 1) := Real.sqrt_nonneg _
  have hs2 : Real.sqrt ((M : ℝ) + 1) ^ 2 = (M : ℝ) + 1 := Real.sq_sqrt (by linarith)
  have hs1 : 1 ≤ Real.sqrt ((M : ℝ) + 1) := by nlinarith [hs0, hs2]
  have hB1 : (1 : ℝ) ≤ 1 + (M : ℝ) * eps ^ 2 := by nlinarith [sq_nonneg eps]
  have hA0 : (0 : ℝ) ≤ 1 + (M : ℝ) * eps := by positivity
  -- `‖v‖₁² ≤ N · ‖v‖₂²` is Cauchy–Schwarz, here an instance of `M (ε - 1)² ≥ 0`
  have hl1 : (1 + (M : ℝ) * eps) ^ 2 ≤ ((M : ℝ) + 1) * (1 + (M : ℝ) * eps ^ 2) := by
    nlinarith [mul_nonneg hM (sq_nonneg (eps - 1))]
  have hB2 : (1 + (M : ℝ) * eps ^ 2) ≤ (1 + (M : ℝ) * eps ^ 2) ^ 2 := by nlinarith [hB1]
  have hstep : ((M : ℝ) + 1) * (1 + (M : ℝ) * eps ^ 2)
      ≤ ((M : ℝ) + 1) * (1 + (M : ℝ) * eps ^ 2) ^ 2 :=
    mul_le_mul_of_nonneg_left hB2 (by linarith)
  have hsq : (1 + (M : ℝ) * eps) ^ 2
      ≤ (Real.sqrt ((M : ℝ) + 1) * (1 + (M : ℝ) * eps ^ 2)) ^ 2 := by
    have hexp : (Real.sqrt ((M : ℝ) + 1) * (1 + (M : ℝ) * eps ^ 2)) ^ 2
        = ((M : ℝ) + 1) * (1 + (M : ℝ) * eps ^ 2) ^ 2 := by
      rw [mul_pow, hs2]
    rw [hexp]
    linarith
  have hrhs0 : (0 : ℝ) ≤ Real.sqrt ((M : ℝ) + 1) * (1 + (M : ℝ) * eps ^ 2) := by
    have : (0 : ℝ) ≤ 1 + (M : ℝ) * eps ^ 2 := by linarith
    exact mul_nonneg hs0 this
  nlinarith [hsq, hrhs0, hA0]

/-! ## The corrected comparison, in general

The counterexample above rules out `K_Schur ≤ K · C_opt` for an absolute constant `K`.  The
right statement is `K_Schur ≤ √N · C_opt`, and it holds for *every* family: the row `m` of the
Gram matrix has `ℓ²`-norm at most `C` (this is `sum_normSq_gram_row_le`, a self-testing
Cauchy–Schwarz argument — one applies the large sieve inequality to the row itself), and
`ℓ¹ ≤ √N · ℓ²`.  A rank-one family shows the exponent `1/2` is optimal up to a factor `2`. -/

variable {ι : Type*}

/-- **The `ℓ²`-norm of a Gram row is at most the large sieve constant.**  Testing the large
sieve inequality against the row itself, and using Cauchy–Schwarz over the family, gives
`∑_{n<N} ‖G m n‖² ≤ G m m · C ≤ C²`. -/
theorem sum_normSq_gram_row_le (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (h : LargeSieve S lam N C) {m : ℕ} (hm : m < N) :
    ∑ n ∈ Finset.range N, ‖gram S lam m n‖ ^ 2 ≤ C * C := by
  classical
  set a : ℕ → ℂ := fun n => gram S lam m n with ha
  set X : ℝ := ∑ n ∈ Finset.range N, ‖gram S lam m n‖ ^ 2 with hX
  have hX0 : 0 ≤ X := Finset.sum_nonneg fun n _ => by positivity
  have hGmm : ∑ f ∈ S, ‖lam f m‖ ^ 2 ≤ C := diagonal_le_of_largeSieve S lam N C h hm
  have hGmm0 : (0 : ℝ) ≤ ∑ f ∈ S, ‖lam f m‖ ^ 2 := Finset.sum_nonneg fun f _ => by positivity
  have hC0 : 0 ≤ C := le_trans hGmm0 hGmm
  -- the row `ℓ²`-mass, expressed as a correlation between the family and the row polynomial
  have hid : ((X : ℝ) : ℂ) = ∑ f ∈ S, lam f m * (starRingEnd ℂ) (linForm lam N a f) := by
    have hrhs : ∑ f ∈ S, lam f m * (starRingEnd ℂ) (linForm lam N a f)
        = ∑ n ∈ Finset.range N, (starRingEnd ℂ) (a n) * gram S lam m n := by
      simp only [linForm, map_sum, map_mul, Finset.mul_sum, gram]
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun n _ => ?_
      exact Finset.sum_congr rfl fun f _ => by ring
    rw [hrhs, hX]
    push_cast
    refine Finset.sum_congr rfl fun n _ => ?_
    rw [ha]
    rw [sq_ofReal_norm]
    ring
  have hCS := cauchy_schwarz_sq S (fun f => lam f m) (fun f => linForm lam N a f)
  have hlhs : ‖∑ f ∈ S, lam f m * (starRingEnd ℂ) (linForm lam N a f)‖ ^ 2 = X ^ 2 := by
    rw [← hid, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hX0]
  rw [hlhs] at hCS
  have hLS : ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 ≤ C * X := by
    have := h a
    rwa [← hX] at this
  have hstep : X ^ 2 ≤ C * (C * X) := by
    have h1 : (∑ f ∈ S, ‖lam f m‖ ^ 2) * (∑ f ∈ S, ‖linForm lam N a f‖ ^ 2)
        ≤ C * (C * X) := by
      have hnn : (0 : ℝ) ≤ ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 :=
        Finset.sum_nonneg fun f _ => by positivity
      calc (∑ f ∈ S, ‖lam f m‖ ^ 2) * (∑ f ∈ S, ‖linForm lam N a f‖ ^ 2)
          ≤ C * (∑ f ∈ S, ‖linForm lam N a f‖ ^ 2) := mul_le_mul_of_nonneg_right hGmm hnn
        _ ≤ C * (C * X) := mul_le_mul_of_nonneg_left hLS hC0
    linarith [hCS, h1]
  rcases eq_or_lt_of_le hX0 with hX00 | hXpos
  · rw [← hX00]
    positivity
  · exact le_of_mul_le_mul_right (by nlinarith [hstep] : X * X ≤ (C * C) * X) hXpos

/-- **Conjecture C8, upper half, proved in general.**  Every admissible large sieve constant
`C` bounds the Schur rows by `√N · C`; this is the correct replacement for the refuted
constant-factor comparison, and it improves the earlier unconditional bound `N · C` of
`AsaiLargeSieveSharp.schur_row_le_of_largeSieve`. -/
theorem schur_row_le_sqrt_mul_largeSieve (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (h : LargeSieve S lam N C) {m : ℕ} (hm : m < N) :
    ∑ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ Real.sqrt (N : ℝ) * C := by
  have hGmm : ∑ f ∈ S, ‖lam f m‖ ^ 2 ≤ C := diagonal_le_of_largeSieve S lam N C h hm
  have hC0 : 0 ≤ C := le_trans (Finset.sum_nonneg fun f _ => by positivity) hGmm
  have hrow := sum_normSq_gram_row_le S lam N C h hm
  have hl1 := sq_sum_norm_le N (fun n => gram S lam m n)
  have hsN : Real.sqrt (N : ℝ) ^ 2 = (N : ℝ) := Real.sq_sqrt (Nat.cast_nonneg N)
  have hsN0 : 0 ≤ Real.sqrt (N : ℝ) := Real.sqrt_nonneg _
  have hsum0 : (0 : ℝ) ≤ ∑ n ∈ Finset.range N, ‖gram S lam m n‖ :=
    Finset.sum_nonneg fun n _ => norm_nonneg _
  have hsq : (∑ n ∈ Finset.range N, ‖gram S lam m n‖) ^ 2 ≤ (Real.sqrt (N : ℝ) * C) ^ 2 := by
    have hNC : (N : ℝ) * (∑ n ∈ Finset.range N, ‖gram S lam m n‖ ^ 2) ≤ (N : ℝ) * (C * C) :=
      mul_le_mul_of_nonneg_left hrow (Nat.cast_nonneg N)
    have hexp : (Real.sqrt (N : ℝ) * C) ^ 2 = (N : ℝ) * (C * C) := by
      rw [mul_pow, hsN]; ring
    rw [hexp]
    linarith [hl1, hNC]
  nlinarith [hsq, hsum0, mul_nonneg hsN0 hC0]

/-- **The exponent `1/2` of C8 is optimal, up to a factor `2`.**  For every `m ≥ 1` the
rank-one family with `ε = 1/m` and `m²` copies of `ε` has length `N = m² + 1`, admits the
large sieve constant `C = 2`, and has Schur row `1 + m ≥ √N`, i.e. at least `(√N/2) · C`. -/
theorem schur_row_sqrt_attained (m : ℕ) (hm : 1 ≤ m) :
    ∃ (N : ℕ) (lam : Unit → ℕ → ℂ) (C : ℝ),
      LargeSieve (Finset.univ : Finset Unit) lam N C ∧ 0 < C ∧
        Real.sqrt (N : ℝ) / 2 * C
          ≤ ∑ n ∈ Finset.range N, ‖gram (Finset.univ : Finset Unit) lam 0 n‖ := by
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hm0 : (0 : ℝ) < (m : ℝ) := by linarith
  set eps : ℝ := 1 / (m : ℝ) with heps
  have heps0 : 0 ≤ eps := by positivity
  have hC : (1 : ℝ) + ((m ^ 2 : ℕ) : ℝ) * eps ^ 2 = 2 := by
    rw [heps]
    push_cast
    field_simp
    norm_num
  have hR : ((m ^ 2 : ℕ) : ℝ) * eps = (m : ℝ) := by
    rw [heps]
    push_cast
    field_simp
  refine ⟨m ^ 2 + 1, rankOneFamily eps, 2, ?_, by norm_num, ?_⟩
  · have := largeSieve_rankOne eps (m ^ 2)
    rwa [hC] at this
  · rw [schur_row_rankOne heps0 (m ^ 2), hR]
    have hcast : ((m ^ 2 + 1 : ℕ) : ℝ) = (m : ℝ) ^ 2 + 1 := by push_cast; ring
    rw [hcast]
    have hs0 : 0 ≤ Real.sqrt ((m : ℝ) ^ 2 + 1) := Real.sqrt_nonneg _
    have hs2 : Real.sqrt ((m : ℝ) ^ 2 + 1) ^ 2 = (m : ℝ) ^ 2 + 1 :=
      Real.sq_sqrt (by positivity)
    have hle : Real.sqrt ((m : ℝ) ^ 2 + 1) ≤ 1 + (m : ℝ) := by
      nlinarith [hs0, hs2, hm0]
    linarith

end AsaiLargeSieve