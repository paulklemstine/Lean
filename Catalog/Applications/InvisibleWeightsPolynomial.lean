/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightVectors
import Applications.NearMissUniversality

/-!
# The generating-polynomial bridge: invisibility is divisibility by `(X - 1)^K`

`Applications/InvisibleWeightVectors.lean` determined the weight vectors that are invisible
to a truncated power-sum window: they are exactly the combinations of the shifted binomial
vectors `binWeight K i`.  This file identifies that description with a purely algebraic one.

To a weight vector `e` on the nodes `{0,…,N}` attach its generating polynomial
`weightPoly N e = ∑_{j ≤ N} e j X^j`.  Then

* `coeff_Xpow_mul_X_sub_one_pow` — the shifted binomial vector `binWeight K i` *is* the
  coefficient vector of `X^i (X-1)^K`;
* `invisible_iff_dvd` — **`e` is invisible to the window `k < K` if and only if
  `(X - 1)^K ∣ weightPoly N e`.**  So the linear-algebra kernel of the truncated moment map is
  the degree-filtered piece of the ideal `((X-1)^K)`; vanishing of `K` moments is a
  `K`-fold root at `1`.
* `nearMiss_iff_dvd` — the multiset version: two multisets bounded by `N` have identical
  power sums throughout the window `k < K` exactly when the difference of their generating
  polynomials `∑_{x ∈ s} X^x - ∑_{x ∈ t} X^x` is divisible by `(X - 1)^K`.
* `nearMiss_two_pow_dvd_alternating` — an arithmetic consequence not visible from the
  moment description: for a near miss at window `K`, the alternating value sums satisfy
  `2^K ∣ (∑_{x∈s} (-1)^x - ∑_{x∈t} (-1)^x)`, obtained by evaluating the factorisation at
  `X = -1`.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  Moments and coefficients are two coordinate systems on the same
space; the moment functionals `e ↦ ∑ e j j^k` for `k < K` should cut out exactly the
polynomials with a `K`-fold root at `X = 1`, because `∑_j e_j j^k` is the `k`-th
"theta-derivative" `(X d/dX)^k` of the generating polynomial evaluated at `X = 1`.

EXPERIMENT (Experimenter).  Proved as `invisible_iff_dvd`, but *not* through the
theta-derivative: the forward direction uses the explicit basis from the structure theorem
(each basis vector's generating polynomial is literally `X^i (X-1)^K`), and the backward
direction extracts the cofactor's coefficients and re-expands.  This avoids all analytic
machinery and works verbatim over `ℤ` (`invisible_iff_dvd_int`), and the backward direction
holds over an arbitrary integral domain (`invisible_of_dvd`).

ANALYSIS (Analyst).  The bridge explains the two catalog phenomena at once: the alternating
binomial vector is the coefficient vector of `(X-1)^N`, and the "gap `±N!`" at the first
visible moment is the `N`-th theta-derivative of `(X-1)^N` at `1`.  It also predicts the
`2^K` divisibility of the alternating discrepancy of a near miss, proved below by
evaluating at `X = -1`.

CRITIQUE (Critic).  The `iff` carries the hypothesis `K ≤ N + 1`, used only in the
backward direction (`invisible_of_coeffs` needs the shifted vectors to fit inside the
nodes); the forward direction `dvd_weightPoly_of_coeffs` is hypothesis-free.  The corner
case `weightPoly N e = 0` is handled explicitly rather than being swept into a degree
computation, since `natDegree 0 = 0`.
-/

open Finset Polynomial

namespace InvisibleWeights

open PowerSumSharpness

variable {R : Type*} [CommRing R]

/-! ## Generating polynomials of weight vectors -/

/-- `weightPoly N e = ∑_{j ≤ N} e j X^j`, the generating polynomial of a weight vector
supported on the nodes `{0,…,N}`. -/
noncomputable def weightPoly (N : ℕ) (e : ℕ → R) : R[X] := ∑ j ∈ range (N + 1), C (e j) * X ^ j

lemma coeff_weightPoly (N : ℕ) (e : ℕ → R) {j : ℕ} (hj : j ≤ N) : (weightPoly N e).coeff j = e j := by
  rw [weightPoly, finset_sum_coeff]
  rw [Finset.sum_eq_single j]
  · rw [coeff_C_mul, coeff_X_pow, if_pos rfl, mul_one]
  · intro d _ hne
    rw [coeff_C_mul, coeff_X_pow, if_neg (fun hc => hne hc.symm), mul_zero]
  · intro hmem
    exact absurd (mem_range.mpr (by omega)) hmem

lemma natDegree_weightPoly_le (N : ℕ) (e : ℕ → R) : (weightPoly N e).natDegree ≤ N := by
  refine Polynomial.natDegree_sum_le_of_forall_le _ _ fun j hj => ?_
  refine le_trans (Polynomial.natDegree_mul_le) ?_
  have h1 : (C (e j)).natDegree = 0 := Polynomial.natDegree_C _
  have h2 : ((X : R[X]) ^ j).natDegree ≤ j := Polynomial.natDegree_X_pow_le j
  have h3 : j ≤ N := Nat.lt_succ_iff.mp (mem_range.mp hj)
  omega

lemma weightPoly_congr {N : ℕ} {e f : ℕ → R} (h : ∀ j ≤ N, e j = f j) :
    weightPoly N e = weightPoly N f :=
  Finset.sum_congr rfl fun j hj => by rw [h j (Nat.lt_succ_iff.mp (mem_range.mp hj))]

lemma weightPoly_smul (N : ℕ) (a : R) (e : ℕ → R) :
    weightPoly N (fun j => a * e j) = C a * weightPoly N e := by
  rw [weightPoly, weightPoly, Finset.mul_sum]
  exact Finset.sum_congr rfl fun j _ => by rw [map_mul]; ring

lemma weightPoly_sum {ι : Type*} (N : ℕ) (u : Finset ι) (g : ι → ℕ → R) :
    weightPoly N (fun j => ∑ i ∈ u, g i j) = ∑ i ∈ u, weightPoly N (g i) := by
  simp only [weightPoly, map_sum, Finset.sum_mul]
  exact Finset.sum_comm

/-! ## `(X - 1)^K` and the shifted binomial vectors -/

/-- Explicit coefficients of `(X - 1)^K`. -/
lemma coeff_X_sub_one_pow (K j : ℕ) :
    ((X - 1 : R[X]) ^ K).coeff j = if j ≤ K then (-1 : R) ^ (K - j) * (K.choose j : R) else 0 := by
  have h : (X - 1 : R[X]) = X + (-1) := by ring
  have hterm : ∀ d : ℕ, ((X : R[X]) ^ d * (-1 : R[X]) ^ (K - d) * (K.choose d : R[X])).coeff j
      = if d = j then (-1 : R) ^ (K - d) * (K.choose d : R) else 0 := by
    intro d
    have hrw : ((X : R[X]) ^ d * (-1 : R[X]) ^ (K - d) * (K.choose d : R[X]))
        = C ((-1 : R) ^ (K - d) * (K.choose d : R)) * X ^ d := by
      rw [C_mul, C_pow, C_neg, C_1]
      simp
      ring
    rw [hrw, coeff_C_mul, coeff_X_pow]
    by_cases hdj : d = j
    · subst hdj; simp
    · rw [if_neg (fun hc => hdj hc.symm), if_neg hdj, mul_zero]
  rw [h, add_pow]
  simp only [finset_sum_coeff, hterm]
  rw [Finset.sum_ite_eq' (range (K + 1)) j (fun d => (-1 : R) ^ (K - d) * (K.choose d : R))]
  by_cases hj : j ≤ K
  · simp [hj, mem_range.mpr (by omega : j < K + 1)]
  · simp [hj, mem_range, Nat.not_lt.mpr (by omega : K + 1 ≤ j)]

/-- **The shifted binomial vector is a coefficient vector.**  `binWeight K i` is precisely
the coefficient sequence of `X^i (X-1)^K`. -/
theorem coeff_Xpow_mul_X_sub_one_pow (K i j : ℕ) :
    (((X : R[X]) ^ i * (X - 1) ^ K)).coeff j = binWeight K i j := by
  rw [mul_comm, coeff_mul_X_pow']
  by_cases hij : i ≤ j
  · rw [if_pos hij, coeff_X_sub_one_pow]
    by_cases hj : j - i ≤ K
    · rw [if_pos hj, binWeight, if_pos ⟨hij, by omega⟩]
    · rw [if_neg hj, binWeight, if_neg (by omega)]
  · rw [if_neg hij, binWeight, if_neg (by omega)]

/-- The generating polynomial of a shifted binomial vector is `X^i (X-1)^K`. -/
theorem weightPoly_binWeight {N K i : ℕ} (h : i + K ≤ N) :
    weightPoly N (binWeight (R := R) K i) = (X : R[X]) ^ i * (X - 1) ^ K := by
  have hdeg : ((X : R[X]) ^ i * (X - 1) ^ K).natDegree ≤ N := by
    refine le_trans Polynomial.natDegree_mul_le ?_
    have h1 : ((X : R[X]) ^ i).natDegree ≤ i := Polynomial.natDegree_X_pow_le i
    have h2 : ((X - 1 : R[X]) ^ K).natDegree ≤ K := by
      refine le_trans (Polynomial.natDegree_pow_le) ?_
      have : (X - 1 : R[X]).natDegree ≤ 1 := by
        refine le_trans (Polynomial.natDegree_sub_le _ _) ?_
        simp [Polynomial.natDegree_X_le]
      calc K * (X - 1 : R[X]).natDegree ≤ K * 1 := Nat.mul_le_mul_left K this
        _ = K := by ring
    omega
  refine Polynomial.ext fun j => ?_
  by_cases hj : j ≤ N
  · rw [coeff_weightPoly _ _ hj, coeff_Xpow_mul_X_sub_one_pow]
  · have hj' : N < j := by omega
    rw [Polynomial.coeff_eq_zero_of_natDegree_lt (lt_of_le_of_lt (natDegree_weightPoly_le N _) hj'),
      Polynomial.coeff_eq_zero_of_natDegree_lt (lt_of_le_of_lt hdeg hj')]

/-! ## The bridge -/

section Domain

variable [IsDomain R]

/-- If the generating polynomial factors as `(X-1)^K * H`, the weight vector is the
combination of shifted binomial vectors with coefficients the coefficients of `H`. -/
theorem coeffs_of_dvd {N K : ℕ} {e : ℕ → R} (hdvd : (X - 1 : R[X]) ^ K ∣ weightPoly N e) :
    ∃ c : ℕ → R, ∀ j ≤ N, e j = ∑ i ∈ range (N + 1 - K), c i * binWeight K i j := by
  obtain ⟨H, hH⟩ := hdvd
  rcases eq_or_ne (weightPoly N e) 0 with hzero | hzero
  · refine ⟨fun _ => 0, fun j hj => ?_⟩
    have : e j = 0 := by rw [← coeff_weightPoly N e hj, hzero, Polynomial.coeff_zero]
    simp [this]
  · have hHne : H ≠ 0 := by
      intro h; rw [h, mul_zero] at hH; exact hzero hH
    have hmonic : ((X - 1 : R[X]) ^ K) ≠ 0 := pow_ne_zero _ (Polynomial.X_sub_C_ne_zero 1)
    have hdegprod : (weightPoly N e).natDegree = ((X - 1 : R[X]) ^ K).natDegree + H.natDegree := by
      rw [hH, Polynomial.natDegree_mul hmonic hHne]
    have hdegK : ((X - 1 : R[X]) ^ K).natDegree = K := by
      rw [Polynomial.natDegree_pow]
      have : (X - 1 : R[X]).natDegree = 1 := by
        simpa using Polynomial.natDegree_X_sub_C (1 : R)
      rw [this, mul_one]
    have hHdeg : H.natDegree < N + 1 - K := by
      have h1 : (weightPoly N e).natDegree ≤ N := natDegree_weightPoly_le N e
      have hKle : K ≤ N := by omega
      omega
    refine ⟨fun i => H.coeff i, fun j hj => ?_⟩
    have hHexp : H = ∑ i ∈ range (N + 1 - K), C (H.coeff i) * X ^ i := by
      conv_lhs => rw [Polynomial.as_sum_range' H (N + 1 - K) hHdeg]
      exact Finset.sum_congr rfl fun i _ => (Polynomial.C_mul_X_pow_eq_monomial).symm
    have hexpand : weightPoly N e
        = ∑ i ∈ range (N + 1 - K), C (H.coeff i) * (X ^ i * (X - 1) ^ K) := by
      calc weightPoly N e = (X - 1) ^ K * H := hH
        _ = (X - 1) ^ K * ∑ i ∈ range (N + 1 - K), C (H.coeff i) * X ^ i := by
            conv_rhs => rw [← hHexp]
        _ = ∑ i ∈ range (N + 1 - K), C (H.coeff i) * (X ^ i * (X - 1) ^ K) := by
            rw [Finset.mul_sum]
            exact Finset.sum_congr rfl fun i _ => by ring
    calc e j = (weightPoly N e).coeff j := (coeff_weightPoly N e hj).symm
      _ = ∑ i ∈ range (N + 1 - K), H.coeff i * binWeight K i j := by
          rw [hexpand, finset_sum_coeff]
          exact Finset.sum_congr rfl fun i _ => by
            rw [coeff_C_mul, coeff_Xpow_mul_X_sub_one_pow]

/-- Divisibility by `(X-1)^K` makes a weight vector invisible to the window `k < K`, over
any integral domain. -/
theorem invisible_of_dvd {N K : ℕ} (hK : K ≤ N + 1) {e : ℕ → R}
    (hdvd : (X - 1 : R[X]) ^ K ∣ weightPoly N e) : Invisible N K e := by
  intro k hk
  obtain ⟨c, hc⟩ := coeffs_of_dvd hdvd
  have hmom : moment N e k
      = moment N (fun j => ∑ i ∈ range (N + 1 - K), c i * binWeight K i j) k :=
    Finset.sum_congr rfl fun j hj => by
      rw [hc j (Nat.lt_succ_iff.mp (mem_range.mp hj))]
  rw [hmom]
  exact invisible_of_coeffs hK c k hk

end Domain

/-- Conversely, a weight vector that is a combination of the shifted binomial vectors has a
generating polynomial divisible by `(X-1)^K`.  Valid over any commutative ring. -/
theorem dvd_weightPoly_of_coeffs {N K : ℕ} {e : ℕ → R} {c : ℕ → R}
    (hc : ∀ j ≤ N, e j = ∑ i ∈ range (N + 1 - K), c i * binWeight K i j) :
    (X - 1 : R[X]) ^ K ∣ weightPoly N e := by
  refine ⟨∑ i ∈ range (N + 1 - K), C (c i) * X ^ i, ?_⟩
  have hcomb : weightPoly N e
      = weightPoly N (fun j => ∑ i ∈ range (N + 1 - K), c i * binWeight K i j) :=
    weightPoly_congr hc
  rw [hcomb, weightPoly_sum, Finset.mul_sum]
  refine Finset.sum_congr rfl fun i hi => ?_
  have hiN : i + K ≤ N := by have := mem_range.mp hi; omega
  rw [show (fun j => c i * binWeight (R := R) K i j)
      = fun j => c i * (binWeight (R := R) K i) j from rfl,
    weightPoly_smul, weightPoly_binWeight hiN]
  ring

/-- **The bridge.**  A rational weight vector on `{0,…,N}` is invisible to the power-sum
window `k < K` if and only if its generating polynomial has a `K`-fold root at `1`:
the kernel of the truncated moment map is the degree-`≤ N` part of the ideal `((X-1)^K)`. -/
theorem invisible_iff_dvd {N K : ℕ} (hK : K ≤ N + 1) (e : ℕ → ℚ) :
    Invisible N K e ↔ (X - 1 : ℚ[X]) ^ K ∣ weightPoly N e := by
  refine ⟨fun he => ?_, invisible_of_dvd hK⟩
  obtain ⟨c, hc⟩ := exists_coeffs_of_invisible he
  exact dvd_weightPoly_of_coeffs hc

/-- **The bridge over `ℤ`.**  Same statement for integral weight vectors; by the
unimodularity of the shifted binomial basis, no denominators appear. -/
theorem invisible_iff_dvd_int {N K : ℕ} (hK : K ≤ N + 1) (e : ℕ → ℤ) :
    Invisible N K e ↔ (X - 1 : ℤ[X]) ^ K ∣ weightPoly N e := by
  refine ⟨fun he => ?_, invisible_of_dvd hK⟩
  obtain ⟨c, hc⟩ := exists_intCoeffs_of_invisible he
  exact dvd_weightPoly_of_coeffs hc

/-! ## Multiset form: near misses are exactly the `K`-fold roots at `1` -/

/-- The weight-vector generating polynomial of the multiplicity difference of two multisets
is the difference of their multiset generating polynomials. -/
lemma weightPoly_count_sub {N : ℕ} {s t : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N) :
    weightPoly N (fun j => (s.count j : ℤ) - (t.count j : ℤ))
      = PowerSumSharpness.genPoly s - PowerSumSharpness.genPoly t := by
  rw [PowerSumSharpness.genPoly_eq_sum_counts hs, PowerSumSharpness.genPoly_eq_sum_counts ht,
    ← Finset.sum_sub_distrib, weightPoly]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [Polynomial.C_sub, Polynomial.C_eq_natCast, Polynomial.C_eq_natCast]
  ring

/-- **Near misses are exactly the `K`-fold roots at `1`.**  Two multisets bounded by `N`
have identical power sums throughout the window `k < K ≤ N + 1` if and only if the
difference of their generating polynomials is divisible by `(X - 1)^K`.  At `K = N` this
refines to the catalog's exact factorisation `near_miss_generating_function`; for `K < N`
the divisibility statement is the correct general form. -/
theorem nearMiss_iff_dvd {N K : ℕ} (hK : K ≤ N + 1) {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N) :
    (∀ k < K, PowerSumSharpness.powerSum s k = PowerSumSharpness.powerSum t k) ↔
      (X - 1 : ℤ[X]) ^ K ∣ PowerSumSharpness.genPoly s - PowerSumSharpness.genPoly t := by
  rw [← weightPoly_count_sub hs ht, ← invisible_iff_dvd_int hK]
  exact ⟨fun h => invisible_of_nearMiss hs ht h, fun h k hk => by
    have := h k hk
    have hsq : ∀ (u : Multiset ℕ), (∀ x ∈ u, x ≤ N) →
        (PowerSumSharpness.powerSum u k : ℤ)
          = ∑ j ∈ range (N + 1), (u.count j : ℤ) * (j : ℤ) ^ k := by
      intro u hu
      conv_lhs => rw [PowerSumSharpness.eq_ofCounts hu]
      rw [PowerSumSharpness.powerSum_ofCounts]
    have hexp : moment N (fun j => (s.count j : ℤ) - (t.count j : ℤ)) k
        = ∑ j ∈ range (N + 1), (s.count j : ℤ) * (j : ℤ) ^ k
          - ∑ j ∈ range (N + 1), (t.count j : ℤ) * (j : ℤ) ^ k := by
      simp only [moment, sub_mul, Finset.sum_sub_distrib]
    rw [hexp, ← hsq s hs, ← hsq t ht] at this
    linarith⟩

/-- **A `2^K` divisibility law for near misses.**  If two multisets bounded by `N` agree on
all power sums `p_k`, `k < K`, then their alternating value sums differ by a multiple of
`2^K`.  (Evaluate the generating polynomials at `X = -1`, where `(X-1)^K` contributes
`(-2)^K`.)  This is invisible to the moment description and is a genuine consequence of the
polynomial bridge. -/
theorem nearMiss_two_pow_dvd_alternating {N K : ℕ} (hK : K ≤ N + 1) {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < K, PowerSumSharpness.powerSum s k = PowerSumSharpness.powerSum t k) :
    (2 : ℤ) ^ K ∣ (s.map fun x => (-1 : ℤ) ^ x).sum - (t.map fun x => (-1 : ℤ) ^ x).sum := by
  obtain ⟨H, hH⟩ := (nearMiss_iff_dvd hK hs ht).mp h
  have heval : ∀ u : Multiset ℕ,
      (PowerSumSharpness.genPoly u).eval (-1 : ℤ) = (u.map fun x => (-1 : ℤ) ^ x).sum := by
    intro u
    rw [PowerSumSharpness.genPoly,
      show ((u.map fun x : ℕ => (X : ℤ[X]) ^ x).sum).eval (-1 : ℤ)
        = Polynomial.evalRingHom (-1 : ℤ) ((u.map fun x : ℕ => (X : ℤ[X]) ^ x).sum) from rfl,
      map_multiset_sum, Multiset.map_map]
    simp
  have hev := congrArg (fun p : ℤ[X] => p.eval (-1 : ℤ)) hH
  simp only [Polynomial.eval_sub, Polynomial.eval_mul, Polynomial.eval_pow,
    Polynomial.eval_X, Polynomial.eval_one] at hev
  rw [heval s, heval t] at hev
  refine ⟨(-1 : ℤ) ^ K * H.eval (-1), ?_⟩
  rw [hev]
  rw [show ((-1 : ℤ) - 1) = -2 by ring, neg_pow]
  ring

end InvisibleWeights