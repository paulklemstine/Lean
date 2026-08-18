/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.NearMissSupport

/-!
# Universality of power-sum near misses: test functions, finite differences, polynomials

Cycle 4 of the near-miss research thread (`Shared/PowerSumSharpness.lean`,
`Applications/NearMissSupport.lean`).

The structure theorem `near_miss_structure` says that a near miss at level `N` is a scaled
binomial pair plus common padding.  This file extracts three consequences that push the
statement out of combinatorics into analysis and algebra.

## Main results

* `near_miss_test_function` — **universality**.  For a near-miss pair `(s, t)` at level `N`
  and an *arbitrary* test function `f : ℕ → ℤ`,
  `∑_{x∈s} f x - ∑_{x∈t} f x = lam · ∑_{j≤N} (-1)^j C(N,j) f j`,
  where `lam = mult_s(0) - mult_t(0)` is a *single* integer independent of `f`.  So a near
  miss is invisible not just to the power sums `x ↦ x^k` (`k < N`) but to every functional
  that annihilates the alternating binomial vector; the whole discrepancy is one number.
* `fwdDiff_at_zero_alternating`, `near_miss_eq_fwdDiff` — **analytic reading**.  That
  alternating sum is exactly `(-1)^N Δ^N f (0)`, the `N`-th forward difference at the
  origin.  Hence *near misses are precisely the discrete `N`-th derivative*: a near-miss
  pair separates `f` iff `Δ^N f (0) ≠ 0`.  In particular a near miss cannot be detected by
  any polynomial test function of degree `< N` (`near_miss_blind_to_low_degree`).
* `charPoly_add`, `charPoly_nsmul`, `charPoly_near_miss_factorisation` — **algebraic
  reading**.  In `ℤ[X]`, the monic split polynomials of a near-miss pair satisfy
  `charPoly s · (charPoly (oddPart N))^lam = charPoly t · (charPoly (evenPart N))^lam`,
  i.e. the *ratio* `charPoly s / charPoly t` is the fixed rational function
  `(∏_{even j} (X-j)^{C(N,j)}) / (∏_{odd j} (X-j)^{C(N,j)})` raised to the power `lam`.
* `near_miss_generating_function` — **generating-function reading**.  In `ℤ[q]`,
  `∑_{x∈s} q^x - ∑_{x∈t} q^x = lam · (1-q)^N` for every near miss: the entire discrepancy is
  a constant multiple of `(1-q)^N`, so "agreeing on the first `N` power sums" is literally
  "the discrepancy has a zero of order `N` at `q = 1`".
* `near_miss_exists_high_multiplicity` — **concentration**.  A near miss at level `N ≥ 1`
  must repeat some single value at least `2^N / (2(N+1))` times: its multiplicity vector
  cannot be spread out, because it dominates a binomial profile on few points.

All of the above hold for *every* near miss, not just the extremal binomial one.
-/

open Finset

namespace PowerSumSharpness

/-! ### Weighted sums over a bounded multiset -/

/-- `wsum s f = ∑_{x ∈ s} f x`, the value of the test functional `f` on the multiset `s`. -/
def wsum (s : Multiset ℕ) (f : ℕ → ℤ) : ℤ := (s.map f).sum

@[simp] lemma wsum_zero (f : ℕ → ℤ) : wsum 0 f = 0 := rfl

@[simp] lemma wsum_add (s t : Multiset ℕ) (f : ℕ → ℤ) :
    wsum (s + t) f = wsum s f + wsum t f := by
  simp [wsum]

@[simp] lemma wsum_replicate (n j : ℕ) (f : ℕ → ℤ) :
    wsum (Multiset.replicate n j) f = (n : ℤ) * f j := by
  simp [wsum, Multiset.map_replicate, Multiset.sum_replicate]

lemma wsum_finsetSum {ι : Type*} (u : Finset ι) (g : ι → Multiset ℕ) (f : ℕ → ℤ) :
    wsum (∑ i ∈ u, g i) f = ∑ i ∈ u, wsum (g i) f := by
  classical
  induction u using Finset.induction with
  | empty => simp
  | insert a u ha ih => simp [Finset.sum_insert ha, ih]

/-- `powerSum` is the special case of `wsum` at the test function `x ↦ x ^ k`. -/
lemma wsum_pow (s : Multiset ℕ) (k : ℕ) : wsum s (fun x => (x : ℤ) ^ k) = powerSum s k := by
  simp [wsum, powerSum]

/-- A test functional on a multiset bounded by `N` is a linear form in the multiplicities. -/
lemma wsum_eq_sum_counts {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) (f : ℕ → ℤ) :
    wsum s f = ∑ j ∈ Finset.range (N + 1), (s.count j : ℤ) * f j := by
  classical
  conv_lhs => rw [eq_ofCounts hs]
  rw [ofCounts, wsum_finsetSum]
  exact Finset.sum_congr rfl fun j _ => by rw [wsum_replicate]

/-! ### Universality: one integer controls every test function -/

/-- **Universality of near misses.**  For any two multisets bounded by `N` whose power sums
agree below the top index, and for *every* test function `f : ℕ → ℤ`, the discrepancy of `f`
is the same fixed integer `lam` times the alternating binomial functional of `f`.  The whole
one-parameter family of near misses is therefore detected by a single linear functional. -/
theorem near_miss_test_function {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (f : ℕ → ℤ) :
    wsum s f - wsum t f
      = ((s.count 0 : ℤ) - (t.count 0 : ℤ))
        * ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * f j := by
  classical
  have hcounts := count_diff_eq_smul_alternating hs ht h
  rw [wsum_eq_sum_counts hs, wsum_eq_sum_counts ht, ← Finset.sum_sub_distrib,
    Finset.mul_sum]
  refine Finset.sum_congr rfl fun j hj => ?_
  have hjN : j ≤ N := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
  have := hcounts j hjN
  calc (s.count j : ℤ) * f j - (t.count j : ℤ) * f j
      = ((s.count j : ℤ) - (t.count j : ℤ)) * f j := by ring
    _ = ((s.count 0 : ℤ) - (t.count 0 : ℤ)) * ((-1 : ℤ) ^ j * (N.choose j)) * f j := by
        rw [this]
    _ = ((s.count 0 : ℤ) - (t.count 0 : ℤ)) * ((-1 : ℤ) ^ j * (N.choose j) * f j) := by ring

/-! ### The analytic reading: near misses *are* the `N`-th finite difference -/

/-- The `N`-th forward difference of an arbitrary `g : ℤ → ℤ` at `0`, as an alternating sum.
(Generalises `fwdDiff_pow_at_zero`, which is the case `g = (· ^ k)`.) -/
lemma fwdDiff_at_zero_alternating (N : ℕ) (g : ℤ → ℤ) :
    (fwdDiff (1 : ℤ))^[N] g 0
      = (-1 : ℤ) ^ N * ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * g j := by
  rw [fwdDiff_iter_eq_sum_shift, Finset.mul_sum]
  refine Finset.sum_congr rfl fun j hj => ?_
  have hjN : j ≤ N := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
  have h0 : (0 : ℤ) + j • (1 : ℤ) = (j : ℤ) := by simp
  rw [h0, smul_eq_mul, neg_one_pow_sub N j hjN]
  ring

/-- **Near misses are the discrete `N`-th derivative.**  The discrepancy of a near-miss pair
on a test function `g : ℤ → ℤ` is `lam · Δ^N g (0)` up to the sign `(-1)^N`. -/
theorem near_miss_eq_fwdDiff {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (g : ℤ → ℤ) :
    wsum s (fun x => g x) - wsum t (fun x => g x)
      = ((s.count 0 : ℤ) - (t.count 0 : ℤ))
        * ((-1 : ℤ) ^ N * (fwdDiff (1 : ℤ))^[N] g 0) := by
  have hsq : (-1 : ℤ) ^ N * (-1 : ℤ) ^ N = 1 := by
    rw [← pow_add]; exact Even.neg_one_pow ⟨N, rfl⟩
  have key : (-1 : ℤ) ^ N * (fwdDiff (1 : ℤ))^[N] g 0
      = ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * g j := by
    rw [fwdDiff_at_zero_alternating N g, ← mul_assoc, hsq, one_mul]
  rw [near_miss_test_function hs ht h (fun x => g x), key]

/-- **Near misses are blind to low-degree test functions.**  If the `N`-th forward
difference of `g` vanishes at `0` — in particular for every polynomial `g` of degree `< N` —
then no near miss at level `N` can separate `g`. -/
theorem near_miss_blind_to_low_degree {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (g : ℤ → ℤ)
    (hg : (fwdDiff (1 : ℤ))^[N] g 0 = 0) :
    wsum s (fun x => g x) = wsum t (fun x => g x) := by
  have := near_miss_eq_fwdDiff hs ht h g
  rw [hg, mul_zero, mul_zero, sub_eq_zero] at this
  exact this

/-- **Sharpness of universality.**  Conversely, a genuine near miss *does* separate every
test function with `Δ^N g (0) ≠ 0`.  So the kernel of a near miss is exactly the kernel of
the `N`-th finite difference at `0`. -/
theorem near_miss_separates_of_fwdDiff_ne {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) (g : ℤ → ℤ)
    (hg : (fwdDiff (1 : ℤ))^[N] g 0 ≠ 0) :
    wsum s (fun x => g x) ≠ wsum t (fun x => g x) := by
  have hlam : ((s.count 0 : ℤ) - (t.count 0 : ℤ)) ≠ 0 := by
    intro h0
    refine hne (Multiset.ext.mpr fun m => ?_)
    by_cases hm : m ≤ N
    · have hcm := count_diff_eq_smul_alternating hs ht h m hm
      rw [h0, zero_mul, sub_eq_zero] at hcm
      exact_mod_cast hcm
    · rw [Multiset.count_eq_zero.mpr fun hmem => hm (hs m hmem),
        Multiset.count_eq_zero.mpr fun hmem => hm (ht m hmem)]
  intro heq
  have hd := near_miss_eq_fwdDiff hs ht h g
  rw [heq, sub_self] at hd
  rcases mul_eq_zero.mp hd.symm with h1 | h1
  · exact hlam h1
  · rcases mul_eq_zero.mp h1 with h2 | h2
    · exact absurd h2 (pow_ne_zero _ (by norm_num))
    · exact hg h2

/-! ### The algebraic reading: a fixed factorisation in `ℤ[X]` -/

lemma charPoly_add (s t : Multiset ℕ) : charPoly (s + t) = charPoly s * charPoly t := by
  simp [charPoly, Multiset.map_add, Multiset.prod_add]

lemma charPoly_nsmul (n : ℕ) (s : Multiset ℕ) : charPoly (n • s) = charPoly s ^ n := by
  induction n with
  | zero => simp [charPoly]
  | succ n ih => rw [succ_nsmul, charPoly_add, ih, pow_succ]

/-- **Algebraic form of the structure theorem.**  For a near-miss pair the two monic split
polynomials differ by a *fixed* factor: the `lam`-th power of the ratio between the even and
the odd binomial products.  In particular `charPoly s / charPoly t` never depends on the
padding, only on the level `N` and the multiplier `lam`. -/
theorem charPoly_near_miss_factorisation {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    ∃ lam : ℕ, 1 ≤ lam ∧
      (charPoly s * charPoly (oddPart N) ^ lam
          = charPoly t * charPoly (evenPart N) ^ lam ∨
       charPoly s * charPoly (evenPart N) ^ lam
          = charPoly t * charPoly (oddPart N) ^ lam) := by
  obtain ⟨lam, u, hlam, -, hcase⟩ := near_miss_structure hs ht h hne
  refine ⟨lam, hlam, ?_⟩
  rcases hcase with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · left
    rw [h1, h2, charPoly_add, charPoly_add, charPoly_nsmul, charPoly_nsmul]
    ring
  · right
    rw [h1, h2, charPoly_add, charPoly_add, charPoly_nsmul, charPoly_nsmul]
    ring

/-! ### The generating-function reading: the discrepancy is exactly `lam · (1 - q)^N` -/

open Polynomial in
/-- The generating polynomial `∑_{x ∈ s} q^x ∈ ℤ[q]` of a multiset of naturals. -/
noncomputable def genPoly (s : Multiset ℕ) : Polynomial ℤ :=
  (s.map fun x : ℕ => (Polynomial.X : Polynomial ℤ) ^ x).sum

@[simp] lemma genPoly_zero : genPoly 0 = 0 := rfl

@[simp] lemma genPoly_add (s t : Multiset ℕ) : genPoly (s + t) = genPoly s + genPoly t := by
  simp [genPoly]

open Polynomial in
@[simp] lemma genPoly_replicate (n j : ℕ) :
    genPoly (Multiset.replicate n j) = (n : Polynomial ℤ) * X ^ j := by
  simp [genPoly, Multiset.map_replicate, Multiset.sum_replicate, nsmul_eq_mul]

lemma genPoly_finsetSum {ι : Type*} (u : Finset ι) (g : ι → Multiset ℕ) :
    genPoly (∑ i ∈ u, g i) = ∑ i ∈ u, genPoly (g i) := by
  classical
  induction u using Finset.induction with
  | empty => simp
  | insert a u ha ih => simp [Finset.sum_insert ha, ih]

open Polynomial in
lemma genPoly_eq_sum_counts {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) :
    genPoly s = ∑ j ∈ Finset.range (N + 1), (s.count j : Polynomial ℤ) * X ^ j := by
  classical
  conv_lhs => rw [eq_ofCounts hs]
  rw [ofCounts, genPoly_finsetSum]
  exact Finset.sum_congr rfl fun j _ => by rw [genPoly_replicate]

open Polynomial in
/-- The alternating binomial generating polynomial is `(1 - q)^N`. -/
lemma sum_alternating_choose_pow_X (N : ℕ) :
    ∑ j ∈ Finset.range (N + 1),
        ((-1 : Polynomial ℤ) ^ j * (N.choose j : Polynomial ℤ)) * X ^ j
      = (1 - X) ^ N := by
  have hbin := add_pow (-X : Polynomial ℤ) 1 N
  have hone : ((-X : Polynomial ℤ) + 1) = 1 - X := by ring
  rw [hone] at hbin
  rw [hbin]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [neg_pow]
  ring

open Polynomial in
/-- **Generating-function form of the near-miss law.**  For *any* near-miss pair at level
`N` the difference of the two generating polynomials is exactly the constant `lam` times
`(1 - q)^N`.  The vanishing of the first `N` power sums is thus the statement that the
discrepancy has a zero of order `N` at `q = 1`, and the multiplier `lam` is its leading
coefficient there.  (Bridging combinatorics ↔ polynomial algebra.) -/
theorem near_miss_generating_function {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) :
    genPoly s - genPoly t
      = Polynomial.C ((s.count 0 : ℤ) - (t.count 0 : ℤ)) * (1 - X) ^ N := by
  classical
  have hcounts := count_diff_eq_smul_alternating hs ht h
  rw [genPoly_eq_sum_counts hs, genPoly_eq_sum_counts ht, ← Finset.sum_sub_distrib,
    ← sum_alternating_choose_pow_X N, Finset.mul_sum]
  refine Finset.sum_congr rfl fun j hj => ?_
  have hjN : j ≤ N := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
  have hc : ((s.count j : Polynomial ℤ)) - ((t.count j : Polynomial ℤ))
      = Polynomial.C ((s.count 0 : ℤ) - (t.count 0 : ℤ)) *
          ((-1 : Polynomial ℤ) ^ j * (N.choose j : Polynomial ℤ)) := by
    have := congrArg (fun z : ℤ => Polynomial.C z) (hcounts j hjN)
    simpa [Polynomial.C_mul, Polynomial.C_sub, Polynomial.C_pow] using this
  calc (s.count j : Polynomial ℤ) * X ^ j - (t.count j : Polynomial ℤ) * X ^ j
      = ((s.count j : Polynomial ℤ) - (t.count j : Polynomial ℤ)) * X ^ j := by ring
    _ = Polynomial.C ((s.count 0 : ℤ) - (t.count 0 : ℤ)) *
          (((-1 : Polynomial ℤ) ^ j * (N.choose j : Polynomial ℤ)) * X ^ j) := by
        rw [hc]; ring

/-! ### Concentration: a near miss must repeat some value many times -/

/-- **Concentration of multiplicities.**  A near miss at level `N ≥ 1` has at least
`2^(N-1)` elements spread over at most `N + 1` distinct values, so some value occurs at
least `2^N / (2(N+1))` times. -/
theorem near_miss_exists_high_multiplicity {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) (hN : 1 ≤ N) :
    ∃ j ≤ N, 2 ^ N ≤ 2 * ((N + 1) * s.count j) := by
  classical
  have hcard : 2 ^ N ≤ 2 * Multiset.card s :=
    two_pow_le_two_mul_card_of_near_miss hs ht h hne hN
  have hpos : 0 < Multiset.card s := by
    have : (0 : ℕ) < 2 ^ N := pow_pos (by norm_num) N
    omega
  have hne0 : support s ≠ ∅ := by
    intro hemp
    have : s = 0 := by
      rw [support] at hemp
      simpa using Multiset.toFinset_eq_empty.mp hemp
    rw [this] at hpos
    simp at hpos
  obtain ⟨j, hjmem, hjmax⟩ :=
    Finset.exists_max_image (support s) (fun j => s.count j)
      (Finset.nonempty_of_ne_empty hne0)
  refine ⟨j, ?_, ?_⟩
  · rw [support, Multiset.mem_toFinset] at hjmem
    exact hs j hjmem
  · have hsum : ∑ i ∈ support s, s.count i = Multiset.card s := by
      rw [support]; exact Multiset.toFinset_sum_count_eq s
    have hle : ∑ i ∈ support s, s.count i ≤ (support s).card * s.count j :=
      Finset.sum_le_card_nsmul _ _ _ (fun i hi => hjmax i hi)
    have hcs : (support s).card ≤ N + 1 := by
      have := Finset.card_le_card (support_subset_range hs)
      simpa using this
    have h1 : Multiset.card s ≤ (support s).card * s.count j := by rw [← hsum]; exact hle
    have h2 : (support s).card * s.count j ≤ (N + 1) * s.count j :=
      Nat.mul_le_mul_right _ hcs
    omega

end PowerSumSharpness