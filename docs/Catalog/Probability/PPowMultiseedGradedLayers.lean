import Mathlib
import Probability.PPowMultiseedVonMangoldt

/-!
# The graded prime-power hierarchy: a finite filtration of the lift

Fifth cycle of the PPOW-MULTISEED study (round-46 #2, experiment 506).  The
regression compares the base feature `log (rad n) = ∑_{p ∣ n} log p` with the
prime-power feature `log n = ∑_p v_p(n) log p`.  Between them sits the whole
*graded* family

`layerFeature j n = ∑_p min (v_p n, j) · log p`,

which interpolates from the base feature (`j = 1`) to the full feature
(`j` large).  This file proves that the interpolation is a genuine filtration:
its increments are the "`p^k` divides `n`" indicators, they are pointwise
antitone in the level, they vanish below `2^k`, and each of them satisfies an
exact Dirichlet window law of the same shape as the total one.

Main results.

* `layerFeature_one` — level `1` *is* the base feature `log (rad n)`.
* `layerFeature_eq_log_of_forall_le`, `layerFeature_self` — the filtration
  saturates at the full feature `log n`.
* `layerFeature_succ_sub` — the increment of the filtration is
  `layerSum (j+1) n = ∑_{p : p^{j+1} ∣ n} log p`.
* `ppExcess_eq_sum_layerSum` — hence the *graded decomposition of the lift*:
  `ppExcess n = ∑_{j=1}^{J-1} layerSum (j+1) n` for any saturating `J`,
  a finite filtration of Chebyshev's identity.
* `layerSum_antitone`, `two_pow_le_of_layerSum_pos` — the layers decrease with
  the level and the level-`k` layer is supported on multiples of `p^k`, hence
  vanishes on all `n < 2^k`: the hierarchy has at most `log₂ n` non-zero levels.
* `layerSum_eq_sum_divisors` and `layerMass_eq_sum_layerWeight_mul_div` — the
  exact window law for each level:
  `∑_{n ≤ N} layerSum k n = ∑_{d ≤ N} layerWeight k d · ⌊N/d⌋`, where
  `layerWeight k` is supported on the exact `k`-th powers of primes.
* `layerMass_antitone` — window masses are decreasing in the level: adding a
  `p^{k+1}` feature on top of a `p^k` feature can only give a smaller gain.
  This is the predicted *diminishing return* of higher-order prime-power
  features.
-/

namespace PPowMultiseed

open Finset

/-! ## The graded features and their increments -/

/-- The level-`j` truncated prime-power feature `∑_p min (v_p n, j) log p`.  Level `1`
is the base feature `log (rad n)`; large levels give the full feature `log n`. -/
noncomputable def layerFeature (j n : ℕ) : ℝ :=
  ∑ p ∈ n.primeFactors, ((min (n.factorization p) j : ℕ) : ℝ) * Real.log p

/-- The level-`k` layer: the mass of the primes whose `k`-th power divides `n`. -/
noncomputable def layerSum (k n : ℕ) : ℝ :=
  ∑ p ∈ n.primeFactors with p ^ k ∣ n, Real.log p

/-- The arithmetic weight of the level-`k` layer: supported exactly on the `k`-th powers
of primes, where it takes the von Mangoldt value `log p`. -/
noncomputable def layerWeight (k d : ℕ) : ℝ :=
  if d.minFac ^ k = d ∧ 1 < d then Real.log d.minFac else 0

lemma log_nonneg_of_mem_primeFactors {n p : ℕ} (hp : p ∈ n.primeFactors) : 0 ≤ Real.log p :=
  Real.log_nonneg (by exact_mod_cast (Nat.prime_of_mem_primeFactors hp).one_lt.le)

lemma one_le_factorization_of_mem {n p : ℕ} (hp : p ∈ n.primeFactors) :
    1 ≤ n.factorization p := by
  rw [← Nat.support_factorization] at hp
  exact Nat.one_le_iff_ne_zero.mpr (Finsupp.mem_support_iff.mp hp)

/-- **Level one is the base feature.** -/
theorem layerFeature_one (n : ℕ) : layerFeature 1 n = Real.log (rad n) := by
  rw [layerFeature, log_rad]
  refine Finset.sum_congr rfl fun p hp => ?_
  rw [min_eq_right (by exact_mod_cast one_le_factorization_of_mem hp)]
  norm_num

/-- **The filtration saturates**: once the level exceeds every exponent, the graded
feature is the full feature `log n`. -/
theorem layerFeature_eq_log_of_forall_le {n j : ℕ} (hn : n ≠ 0)
    (h : ∀ p ∈ n.primeFactors, n.factorization p ≤ j) :
    layerFeature j n = Real.log n := by
  rw [layerFeature, log_eq_sum_factorization hn]
  refine Finset.sum_congr rfl fun p hp => ?_
  rw [min_eq_left (h p hp)]

/-- A concrete saturating level: every exponent of `n` is `< n`. -/
theorem layerFeature_self {n : ℕ} (hn : n ≠ 0) : layerFeature n n = Real.log n :=
  layerFeature_eq_log_of_forall_le hn fun p _ => (Nat.factorization_lt p hn).le

/-- **The increments of the filtration are the prime-power layers.** -/
theorem layerFeature_succ_sub {n j : ℕ} (hn : n ≠ 0) :
    layerFeature (j + 1) n - layerFeature j n = layerSum (j + 1) n := by
  rw [layerFeature, layerFeature, ← Finset.sum_sub_distrib, layerSum, Finset.sum_filter]
  refine Finset.sum_congr rfl fun p hp => ?_
  have hprime := Nat.prime_of_mem_primeFactors hp
  by_cases hdvd : p ^ (j + 1) ∣ n
  · have hle : j + 1 ≤ n.factorization p :=
      (Nat.Prime.pow_dvd_iff_le_factorization hprime hn).mp hdvd
    rw [if_pos hdvd, min_eq_right hle, min_eq_right (by omega : j ≤ n.factorization p)]
    push_cast
    ring
  · have hlt : n.factorization p < j + 1 := by
      by_contra hcon
      exact hdvd ((Nat.Prime.pow_dvd_iff_le_factorization hprime hn).mpr (by omega))
    rw [if_neg hdvd, min_eq_left (by omega : n.factorization p ≤ j + 1),
      min_eq_left (by omega : n.factorization p ≤ j)]
    ring

/-- **The graded decomposition of the lift.**  For any saturating level `J ≥ 1`, the
prime-power excess is the sum of the layers of level `2, …, J`. -/
theorem ppExcess_eq_sum_layerSum {n J : ℕ} (hn : n ≠ 0) (hJ : 1 ≤ J)
    (h : ∀ p ∈ n.primeFactors, n.factorization p ≤ J) :
    ppExcess n = ∑ j ∈ Finset.Ico 1 J, layerSum (j + 1) n := by
  have tele : ∀ m : ℕ, 1 ≤ m →
      ∑ j ∈ Finset.Ico 1 m, layerSum (j + 1) n = layerFeature m n - layerFeature 1 n := by
    intro m hm
    induction m with
    | zero => omega
    | succ t ih =>
      rcases Nat.eq_or_lt_of_le hm with h1 | h1
      · simp [← h1]
      · have ht : 1 ≤ t := by omega
        have hstep := layerFeature_succ_sub (n := n) (j := t) hn
        rw [Finset.sum_Ico_succ_top ht, ih ht]
        linarith
  rw [tele J hJ, layerFeature_one, layerFeature_eq_log_of_forall_le hn h, ppExcess]

/-! ## Structure of the layers -/

theorem layerSum_nonneg (k n : ℕ) : 0 ≤ layerSum k n :=
  Finset.sum_nonneg fun _ hp => log_nonneg_of_mem_primeFactors (Finset.mem_filter.mp hp).1

/-- **The layers decrease with the level.** -/
theorem layerSum_antitone {k l : ℕ} (n : ℕ) (hkl : k ≤ l) : layerSum l n ≤ layerSum k n := by
  refine Finset.sum_le_sum_of_subset_of_nonneg ?_ ?_
  · intro p hp
    obtain ⟨hmem, hdvd⟩ := Finset.mem_filter.mp hp
    refine Finset.mem_filter.mpr ⟨hmem, dvd_trans (pow_dvd_pow p hkl) hdvd⟩
  · intro p hp _
    exact log_nonneg_of_mem_primeFactors (Finset.mem_filter.mp hp).1

/-- **The level-`k` layer lives above `2^k`**: only integers divisible by a `k`-th power
of a prime contribute, so the hierarchy has at most `log₂ n` non-trivial levels. -/
theorem two_pow_le_of_layerSum_pos {k n : ℕ} (hn : n ≠ 0) (h : 0 < layerSum k n) :
    2 ^ k ≤ n := by
  by_contra hcon
  push_neg at hcon
  have hzero : layerSum k n = 0 := by
    refine Finset.sum_eq_zero fun p hp => ?_
    obtain ⟨hmem, hdvd⟩ := Finset.mem_filter.mp hp
    exfalso
    have hprime := Nat.prime_of_mem_primeFactors hmem
    have h2 : 2 ^ k ≤ p ^ k := Nat.pow_le_pow_left hprime.two_le k
    have hle : p ^ k ≤ n := Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hdvd
    omega
  linarith

/-! ## The exact window law, level by level -/

lemma minFac_prime_pow {p k : ℕ} (hp : p.Prime) (hk : 1 ≤ k) : (p ^ k).minFac = p := by
  have h1 : 1 < p ^ k := Nat.one_lt_pow (by omega) hp.one_lt
  have hq : ((p ^ k).minFac).Prime := Nat.minFac_prime (by omega)
  exact (Nat.prime_dvd_prime_iff_eq hq hp).mp (hq.dvd_of_dvd_pow (Nat.minFac_dvd _))

lemma layerWeight_prime_pow {p k : ℕ} (hp : p.Prime) (hk : 1 ≤ k) :
    layerWeight k (p ^ k) = Real.log p := by
  have hmf := minFac_prime_pow hp hk
  have h1 : 1 < p ^ k := Nat.one_lt_pow (by omega) hp.one_lt
  rw [layerWeight, if_pos ⟨by rw [hmf], h1⟩, hmf]

/-- The divisors of `n` that are exact `k`-th powers of primes are exactly the `p^k` for
`p` a prime factor of `n` with `p^k ∣ n`. -/
lemma filter_divisors_layer {n k : ℕ} (hn : n ≠ 0) (hk : 1 ≤ k) :
    {d ∈ n.divisors | d.minFac ^ k = d ∧ 1 < d}
      = (n.primeFactors.filter fun p => p ^ k ∣ n).image fun p => p ^ k := by
  ext d
  simp only [Finset.mem_filter, Finset.mem_image, Nat.mem_divisors]
  constructor
  · rintro ⟨⟨hdvd, -⟩, hmf, hd1⟩
    refine ⟨d.minFac, ⟨?_, ?_⟩, hmf⟩
    · exact Nat.mem_primeFactors.mpr ⟨Nat.minFac_prime (by omega),
        dvd_trans (Nat.minFac_dvd d) hdvd, hn⟩
    · rw [hmf]; exact hdvd
  · rintro ⟨p, ⟨hp, hpk⟩, rfl⟩
    have hprime := Nat.prime_of_mem_primeFactors hp
    have h1 : 1 < p ^ k := Nat.one_lt_pow (by omega) hprime.one_lt
    exact ⟨⟨hpk, hn⟩, by rw [minFac_prime_pow hprime hk], h1⟩

/-- **The layer is a divisor sum.**  The level-`k` layer of `n` is the divisor sum of the
level-`k` weight, exactly as `ppExcess` is the divisor sum of `ppWeight`. -/
theorem layerSum_eq_sum_divisors {n k : ℕ} (hn : n ≠ 0) (hk : 1 ≤ k) :
    layerSum k n = ∑ d ∈ n.divisors, layerWeight k d := by
  classical
  have hsplit : ∑ d ∈ n.divisors, layerWeight k d
      = ∑ d ∈ n.divisors with (d.minFac ^ k = d ∧ 1 < d), Real.log d.minFac := by
    rw [Finset.sum_filter]
    exact Finset.sum_congr rfl fun d _ => by rw [layerWeight]
  rw [hsplit, filter_divisors_layer hn hk]
  rw [Finset.sum_image]
  · refine Finset.sum_congr rfl fun p hp => ?_
    exact (minFac_prime_pow (Nat.prime_of_mem_primeFactors (Finset.mem_filter.mp hp).1) hk).symm ▸
      rfl
  · intro p hp q hq hpq
    have hpp := Nat.prime_of_mem_primeFactors (Finset.mem_filter.mp hp).1
    have hqq := Nat.prime_of_mem_primeFactors (Finset.mem_filter.mp hq).1
    have h1 : (p ^ k).minFac = p := minFac_prime_pow hpp hk
    have h2 : (q ^ k).minFac = q := minFac_prime_pow hqq hk
    have hpq' : p ^ k = q ^ k := hpq
    rw [← h1, ← h2, hpq']

/-- The total level-`k` mass of the window `[1, N]`. -/
noncomputable def layerMass (k N : ℕ) : ℝ := ∑ n ∈ Finset.Icc 1 N, layerSum k n

/-- **The exact window law at each level.**  Every layer obeys a Dirichlet law of the
same shape as the total prime-power law `ppMass_eq_sum_ppWeight_mul_div`. -/
theorem layerMass_eq_sum_layerWeight_mul_div {k : ℕ} (hk : 1 ≤ k) (N : ℕ) :
    layerMass k N = ∑ d ∈ Finset.Icc 1 N, layerWeight k d * ((N / d : ℕ) : ℝ) := by
  rw [layerMass, ← sum_divisorSum_eq_sum_mul_div]
  refine Finset.sum_congr rfl fun n hn => ?_
  have hn0 : n ≠ 0 := by
    simp only [Finset.mem_Icc] at hn
    omega
  exact layerSum_eq_sum_divisors hn0 hk

/-- **Diminishing returns.**  The window mass of the layers is decreasing in the level:
a `p^{k+1}` feature can only add less than the `p^k` feature it sits on top of. -/
theorem layerMass_antitone {k l : ℕ} (N : ℕ) (hkl : k ≤ l) : layerMass l N ≤ layerMass k N :=
  Finset.sum_le_sum fun n _ => layerSum_antitone n hkl

/-- The whole hierarchy above level `1` reassembles the lift over a window:
`∑_{n ≤ N} ppExcess n = ∑_{k ≥ 2} layerMass k N`, in the finite form where the sum
stops at any level that saturates the window. -/
theorem windowMass_eq_sum_layerMass {N J : ℕ} (hJ : 1 ≤ J) (hN : N ≤ J) :
    windowMass 1 N = ∑ j ∈ Finset.Ico 1 J, layerMass (j + 1) N := by
  rw [windowMass_one_eq_sum_Icc,
    show (∑ j ∈ Finset.Ico 1 J, layerMass (j + 1) N)
        = ∑ n ∈ Finset.Icc 1 N, ∑ j ∈ Finset.Ico 1 J, layerSum (j + 1) n by
      unfold layerMass; rw [Finset.sum_comm]]
  refine Finset.sum_congr rfl fun n hn => ?_
  simp only [Finset.mem_Icc] at hn
  have hn0 : n ≠ 0 := by omega
  refine ppExcess_eq_sum_layerSum hn0 hJ fun p _ => ?_
  have := Nat.factorization_lt (n := n) p hn0
  omega

end PPowMultiseed