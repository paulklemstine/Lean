import Mathlib
import Probability.PPowMultiseedGradedLayers

/-!
# Geometric decay of the graded prime-power layers

Eighth cycle of the PPOW-MULTISEED study (round-46 #2, experiment 506).  Cycle 7
(`PPowMultiseedGradedLayers.lean`) proved that the graded features
`F_j(n) = ∑_p min (v_p n, j) log p` form a finite filtration whose increments —
the *layers* `layerSum k n = ∑_{p^k ∣ n} log p` — obey an exact Dirichlet window
law and are *antitone* in the level `k`.  Antitonicity is only qualitative; this
file makes the decay **quantitative**, which is what turns the graded hierarchy
into a falsifiable prediction about higher-order regression features.

Main results.

* `layerMass_eq_sum_primes` — the level-`k` window mass in prime coordinates:
  `layerMass k N = ∑_{p ≤ N prime} log p · ⌊N / p^k⌋`.
* `layerMass_succ_le_half` — **geometric decay**: `layerMass (k+1) N ≤ layerMass k N / 2`.
  The rate `1/2` is set by the smallest prime.
* `layerMass_add_le_geometric` — iterated form `layerMass (k+j) N ≤ layerMass k N / 2^j`.
* `windowMass_le_two_mul_layerMass_two`, together with
  `layerMass_two_le_windowMass`, sandwiches the whole lift by its first layer:
  `layerMass 2 N ≤ windowMass 1 N ≤ 2 · layerMass 2 N`.
  So the square layer already carries at least half of the total prime-power mass:
  adding a `p³` feature on top of `pp_sum` cannot gain more than the `p²` layer did,
  and in fact the tail above level `k` is at most `2·layerMass k N`.
* `layerMass_eq_zero_of_lt` — the level-`k` mass vanishes as soon as `N < 2^k`,
  so the hierarchy really is finite for every window.
-/

namespace PPowMultiseed

open Finset

/-- The primes in the window `[1, N]`. -/
def windowPrimes (N : ℕ) : Finset ℕ := (Finset.range (N + 1)).filter Nat.Prime

lemma mem_windowPrimes {N p : ℕ} : p ∈ windowPrimes N ↔ p ≤ N ∧ p.Prime := by
  simp [windowPrimes]

/-- The support of the level-`k` weight inside `[1, N]` is exactly the set of `k`-th
powers of primes that fit into the window. -/
lemma filter_Icc_layer {N k : ℕ} (hk : 1 ≤ k) :
    {d ∈ Finset.Icc 1 N | d.minFac ^ k = d ∧ 1 < d}
      = ((windowPrimes N).filter fun p => p ^ k ≤ N).image fun p => p ^ k := by
  ext d
  simp only [Finset.mem_filter, Finset.mem_image, Finset.mem_Icc, mem_windowPrimes]
  constructor
  · rintro ⟨⟨-, hdN⟩, hmf, hd1⟩
    have hp : (d.minFac).Prime := Nat.minFac_prime (by omega)
    refine ⟨d.minFac, ⟨⟨?_, hp⟩, ?_⟩, hmf⟩
    · calc d.minFac ≤ d.minFac ^ k := Nat.le_self_pow (by omega) _
        _ = d := hmf
        _ ≤ N := hdN
    · rw [hmf]; exact hdN
  · rintro ⟨p, ⟨⟨-, hp⟩, hpN⟩, rfl⟩
    have h1 : 1 < p ^ k := Nat.one_lt_pow (by omega) hp.one_lt
    exact ⟨⟨by omega, hpN⟩, by rw [minFac_prime_pow hp hk], h1⟩

/-- **The layer mass in prime coordinates.**  Summing the exact window law over the
support of the level-`k` weight turns it into a sum over primes:
`layerMass k N = ∑_{p ≤ N} log p · ⌊N / p^k⌋`. -/
theorem layerMass_eq_sum_primes {k : ℕ} (hk : 1 ≤ k) (N : ℕ) :
    layerMass k N = ∑ p ∈ windowPrimes N, Real.log p * ((N / p ^ k : ℕ) : ℝ) := by
  classical
  rw [layerMass_eq_sum_layerWeight_mul_div hk]
  have hstep : ∑ d ∈ Finset.Icc 1 N, layerWeight k d * ((N / d : ℕ) : ℝ)
      = ∑ d ∈ Finset.Icc 1 N with (d.minFac ^ k = d ∧ 1 < d),
          Real.log d.minFac * ((N / d : ℕ) : ℝ) := by
    rw [Finset.sum_filter]
    refine Finset.sum_congr rfl fun d _ => ?_
    rw [layerWeight]
    split <;> simp
  rw [hstep, filter_Icc_layer hk, Finset.sum_image]
  · -- rewrite the summand in prime coordinates, then drop the primes with `p ^ k > N`
    have hsummand : ∀ p ∈ (windowPrimes N).filter (fun p => p ^ k ≤ N),
        Real.log ((p ^ k).minFac) * ((N / p ^ k : ℕ) : ℝ)
          = Real.log p * ((N / p ^ k : ℕ) : ℝ) := by
      intro p hp
      have hp' := (mem_windowPrimes.mp (Finset.mem_filter.mp hp).1).2
      rw [minFac_prime_pow hp' hk]
    rw [Finset.sum_congr rfl hsummand]
    refine Finset.sum_subset (Finset.filter_subset (fun p => p ^ k ≤ N) (windowPrimes N)) ?_
    intro p hp hnot
    have hpN : ¬ p ^ k ≤ N := by
      simp only [Finset.mem_filter, hp, true_and] at hnot
      exact hnot
    rw [Nat.div_eq_of_lt (by omega)]
    simp
  · intro p hp q hq hpq
    have hp' := (mem_windowPrimes.mp (Finset.mem_filter.mp hp).1).2
    have hq' := (mem_windowPrimes.mp (Finset.mem_filter.mp hq).1).2
    have h1 : (p ^ k).minFac = p := minFac_prime_pow hp' hk
    have h2 : (q ^ k).minFac = q := minFac_prime_pow hq' hk
    rw [← h1, ← h2, show p ^ k = q ^ k from hpq]

lemma layerMass_nonneg (k N : ℕ) : 0 ≤ layerMass k N :=
  Finset.sum_nonneg fun n _ => layerSum_nonneg k n

/-- Halving step for the quotients: for a prime `p`, `⌊N/p^{k+1}⌋ ≤ ⌊N/p^k⌋ / 2`. -/
lemma two_mul_div_pow_succ_le {N p k : ℕ} (hp : p.Prime) :
    2 * (N / p ^ (k + 1)) ≤ N / p ^ k := by
  have hdiv : N / p ^ (k + 1) = (N / p ^ k) / p := by
    rw [pow_succ, Nat.div_div_eq_div_mul]
  calc 2 * (N / p ^ (k + 1)) = 2 * ((N / p ^ k) / p) := by rw [hdiv]
    _ ≤ p * ((N / p ^ k) / p) := Nat.mul_le_mul_right _ hp.two_le
    _ ≤ N / p ^ k := by rw [Nat.mul_comm]; exact Nat.div_mul_le_self _ _

/-- **Geometric decay of the graded layers.**  Each level carries at most half the
window mass of the level below it; the ratio `1/2` is exactly the reciprocal of the
smallest prime. -/
theorem layerMass_succ_le_half {k : ℕ} (hk : 1 ≤ k) (N : ℕ) :
    layerMass (k + 1) N ≤ layerMass k N / 2 := by
  rw [layerMass_eq_sum_primes hk N, layerMass_eq_sum_primes (by omega : 1 ≤ k + 1) N,
    Finset.sum_div]
  refine Finset.sum_le_sum fun p hp => ?_
  have hp' := (mem_windowPrimes.mp hp).2
  have hlog : 0 ≤ Real.log p := Real.log_nonneg (by exact_mod_cast hp'.one_lt.le)
  have hq : (2 : ℝ) * ((N / p ^ (k + 1) : ℕ) : ℝ) ≤ ((N / p ^ k : ℕ) : ℝ) := by
    exact_mod_cast two_mul_div_pow_succ_le (N := N) (k := k) hp'
  have := mul_le_mul_of_nonneg_left hq hlog
  linarith

/-- Iterated geometric decay: `layerMass (k+j) N ≤ layerMass k N / 2^j`. -/
theorem layerMass_add_le_geometric {k : ℕ} (hk : 1 ≤ k) (j N : ℕ) :
    layerMass (k + j) N ≤ layerMass k N / 2 ^ j := by
  induction j with
  | zero => simp
  | succ t ih =>
    have hstep : layerMass (k + t + 1) N ≤ layerMass (k + t) N / 2 :=
      layerMass_succ_le_half (by omega) N
    have h2 : (0 : ℝ) < 2 ^ t := by positivity
    calc layerMass (k + (t + 1)) N = layerMass (k + t + 1) N := by rw [← Nat.add_assoc]
      _ ≤ layerMass (k + t) N / 2 := hstep
      _ ≤ (layerMass k N / 2 ^ t) / 2 := by linarith
      _ = layerMass k N / 2 ^ (t + 1) := by rw [pow_succ]; ring

/-- The level-`k` mass vanishes below `2^k`: the hierarchy is finite for every window. -/
theorem layerMass_eq_zero_of_lt {k N : ℕ} (h : N < 2 ^ k) : layerMass k N = 0 := by
  refine Finset.sum_eq_zero fun n hn => ?_
  simp only [Finset.mem_Icc] at hn
  by_contra hne
  have hpos : 0 < layerSum k n := lt_of_le_of_ne (layerSum_nonneg k n) (Ne.symm hne)
  have := two_pow_le_of_layerSum_pos (n := n) (k := k) (by omega) hpos
  omega

/-- The first layer is a lower bound for the whole lift over a window. -/
theorem layerMass_two_le_windowMass (N : ℕ) : layerMass 2 N ≤ windowMass 1 N := by
  rw [windowMass_one_eq_sum_Icc, layerMass]
  refine Finset.sum_le_sum fun n hn => ?_
  simp only [Finset.mem_Icc] at hn
  have hn0 : n ≠ 0 := by omega
  have hJ : ∀ p ∈ n.primeFactors, n.factorization p ≤ n := fun p _ =>
    (Nat.factorization_lt p hn0).le
  have hdec := ppExcess_eq_sum_layerSum (n := n) (J := n) hn0 (by omega) hJ
  rw [hdec]
  rcases Nat.lt_or_ge n 2 with h2 | h2
  · interval_cases n
    · simp [layerSum]
    · simp [layerSum]
  · have hmem : (1 : ℕ) ∈ Finset.Ico 1 n := Finset.mem_Ico.mpr ⟨le_refl 1, by omega⟩
    exact Finset.single_le_sum (f := fun j => layerSum (j + 1) n)
      (fun j _ => layerSum_nonneg _ n) hmem

/-- **The square layer carries at least half of the lift.**  Summing the geometric
decay over all levels bounds the total prime-power mass of a window by twice its
level-`2` layer. -/
theorem windowMass_le_two_mul_layerMass_two (N : ℕ) :
    windowMass 1 N ≤ 2 * layerMass 2 N := by
  classical
  set J := max N 1 with hJdef
  have hJ1 : 1 ≤ J := le_max_right _ _
  have hNJ : N ≤ J := le_max_left _ _
  rw [windowMass_eq_sum_layerMass hJ1 hNJ, Finset.sum_Ico_eq_sum_range]
  have hbound : ∀ i ∈ Finset.range (J - 1),
      layerMass (1 + i + 1) N ≤ layerMass 2 N * (1 / 2 : ℝ) ^ i := by
    intro i _
    have h := layerMass_add_le_geometric (k := 2) (by omega) i N
    have : layerMass (1 + i + 1) N = layerMass (2 + i) N := by
      congr 1; omega
    rw [this]
    calc layerMass (2 + i) N ≤ layerMass 2 N / 2 ^ i := h
      _ = layerMass 2 N * (1 / 2 : ℝ) ^ i := by
          rw [div_pow, one_pow]; ring
  calc ∑ i ∈ Finset.range (J - 1), layerMass (1 + i + 1) N
      ≤ ∑ i ∈ Finset.range (J - 1), layerMass 2 N * (1 / 2 : ℝ) ^ i :=
        Finset.sum_le_sum hbound
    _ = layerMass 2 N * ∑ i ∈ Finset.range (J - 1), (1 / 2 : ℝ) ^ i := by
        rw [Finset.mul_sum]
    _ ≤ layerMass 2 N * 2 :=
        mul_le_mul_of_nonneg_left (sum_geometric_two_le _) (layerMass_nonneg 2 N)
    _ = 2 * layerMass 2 N := by ring

/-- **The sandwich.**  The total prime-power lift of a window is captured, up to a
factor `2`, by its level-`2` layer alone: higher-order prime-power features can add at
most as much as the square feature already contributes. -/
theorem layerMass_two_sandwich (N : ℕ) :
    layerMass 2 N ≤ windowMass 1 N ∧ windowMass 1 N ≤ 2 * layerMass 2 N :=
  ⟨layerMass_two_le_windowMass N, windowMass_le_two_mul_layerMass_two N⟩

/-- The tail of the hierarchy above level `k` is controlled by the level-`k` layer:
every higher layer is at most `layerMass k N / 2^j`, so the cumulative gain of all
features of order `> k` is at most `2 · layerMass k N`. -/
theorem sum_tail_layerMass_le {k : ℕ} (hk : 1 ≤ k) (m N : ℕ) :
    ∑ j ∈ Finset.range m, layerMass (k + j) N ≤ 2 * layerMass k N := by
  calc ∑ j ∈ Finset.range m, layerMass (k + j) N
      ≤ ∑ j ∈ Finset.range m, layerMass k N * (1 / 2 : ℝ) ^ j := by
        refine Finset.sum_le_sum fun j _ => ?_
        have h := layerMass_add_le_geometric hk j N
        calc layerMass (k + j) N ≤ layerMass k N / 2 ^ j := h
          _ = layerMass k N * (1 / 2 : ℝ) ^ j := by rw [div_pow, one_pow]; ring
    _ = layerMass k N * ∑ j ∈ Finset.range m, (1 / 2 : ℝ) ^ j := by rw [Finset.mul_sum]
    _ ≤ layerMass k N * 2 :=
        mul_le_mul_of_nonneg_left (sum_geometric_two_le _) (layerMass_nonneg k N)
    _ = 2 * layerMass k N := by ring

end PPowMultiseed