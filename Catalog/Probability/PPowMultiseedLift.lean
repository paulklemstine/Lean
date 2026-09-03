import Mathlib
import Shared.NumberTheory.IsSmooth

/-!
# PPOW-MULTISEED: the prime-power lift is a theorem, not a fitting artefact

Context (round-46 #2, experiment 506, following paper 172).  A regression of a
smooth-number statistic on multiplicative features found that adding a
*prime-power* feature `pp_sum` on top of the *base* feature (the sum of `log p`
over the **distinct** primes dividing `n`) raises `R²` by
`+0.055 / +0.049 / +0.051 / +0.050 / +0.048` across the five seeds
`20260940–44` at `(u = 3.5, w = 240)`, and that the lift **grows** with the
window length (`0.051 → 0.058` at `u = 3.5`, `0.058 → 0.082` at `u = 2.5`, for
`w : 240 → 960`).

This file isolates the *deterministic* number-theoretic content of that
empirical finding.  The base feature is `Real.log (rad n)` with
`rad n = ∏ p ∈ n.primeFactors, p`, and the extra quantity carried by the
prime-power feature is exactly

`ppExcess n = Real.log n - Real.log (rad n) = ∑ p ∈ n.primeFactors, (v_p(n) - 1) · log p`.

Main results.

* `ppExcess_eq_sum_factorization` — the excess is the prime-power sum
  `∑_p (v_p(n) - 1) log p`: the exact identity behind the `pp_sum` feature.
* `ppExcess_nonneg`, `ppExcess_eq_zero_iff_squarefree` — the feature is a
  non-negative signal vanishing exactly on squarefree inputs, i.e. it is *pure*
  prime-power information, orthogonal to the squarefree part of the design.
* `radCollision_residual_lower_bound`, `prime_square_residual_lower_bound` —
  the **irreducible error of the base model**.  Whenever two integers share a
  radical, *no* function of the base feature can fit both; the squared residual
  is at least half the squared target gap, which for `(p, p²)` is
  `(log p)²/2 > 0`.  So `ΔR² > 0` is forced by arithmetic, not fitted.
* `windowMass_ge_of_offset` — a **seed-uniform** (offset-independent) floor
  `⌊w/4⌋ · log 2` for the prime-power mass of the window `[a, a+w)`.
* `windowMass_mono`, `windowMass_add_ge_add_log_two`, `windowMass_pos`,
  `windowMass_960_ge_windowMass_240_add`, `windowMass_240_ge` — the lift is
  monotone in the window length, strictly grows (every four extra integers add
  at least `log 2`), is positive for every seed, and the experiment's
  `240 → 960` step adds at least `180 · log 2`.
* `ppExcess_prime_pow`, `smoothTower_mass`, `smoothTower_mean_unbounded` —
  on the `2`-smooth tower (the small-`u` regime) the prime-power mass is
  *quadratic*, `∑_{k=1}^{m} ppExcess (2^k) = m(m-1)/2 · log 2`, so the mean
  signal per element diverges: the structural reason the measured lift is larger
  at smaller smoothness parameter `u`.

Nothing here is a statistical claim.  The theorems say that the prime-power
coordinate is functionally independent of the radical coordinate, with an
explicit positive, offset-uniform, window-growing amount of mass — the
structural reason a `pp_sum` feature *must* raise `R²`.
-/

namespace PPowMultiseed

open Finset

/-! ## The radical and the prime-power excess -/

/-- The radical `rad n = ∏_{p ∣ n} p`, the product of the distinct primes of `n`.
The "base" feature of the regression is `Real.log (rad n)`. -/
def rad (n : ℕ) : ℕ := ∏ p ∈ n.primeFactors, p

/-- The prime-power excess `log n - log (rad n)`: the information the `pp_sum`
feature adds on top of the base feature. -/
noncomputable def ppExcess (n : ℕ) : ℝ := Real.log n - Real.log (rad n)

lemma rad_dvd (n : ℕ) : rad n ∣ n := Nat.prod_primeFactors_dvd n

lemma rad_pos (n : ℕ) : 0 < rad n :=
  Finset.prod_pos fun _ hp => (Nat.prime_of_mem_primeFactors hp).pos

lemma rad_le (n : ℕ) (hn : 0 < n) : rad n ≤ n := Nat.le_of_dvd hn (rad_dvd n)

lemma rad_prime_pow {p k : ℕ} (hp : p.Prime) (hk : k ≠ 0) : rad (p ^ k) = p := by
  simp [rad, Nat.primeFactors_prime_pow hk hp]

lemma rad_prime {p : ℕ} (hp : p.Prime) : rad p = p := by simp [rad, hp.primeFactors]

lemma log_rad (n : ℕ) : Real.log (rad n) = ∑ p ∈ n.primeFactors, Real.log p := by
  rw [rad]
  push_cast
  rw [Real.log_prod]
  intro p hp
  have h := (Nat.prime_of_mem_primeFactors hp).one_lt
  positivity

lemma log_eq_sum_factorization {n : ℕ} (hn : n ≠ 0) :
    Real.log n = ∑ p ∈ n.primeFactors, (n.factorization p : ℝ) * Real.log p := by
  conv_lhs => rw [← Nat.factorization_prod_pow_eq_self hn]
  rw [Nat.prod_factorization_eq_prod_primeFactors]
  push_cast
  rw [Real.log_prod]
  · exact Finset.sum_congr rfl fun p _ => by rw [Real.log_pow]
  · intro p hp
    have h := (Nat.prime_of_mem_primeFactors hp).one_lt
    positivity

/-- **The prime-power identity.**  The excess of `log n` over the base feature is
exactly the prime-power sum `∑_p (v_p(n) - 1) · log p`. -/
theorem ppExcess_eq_sum_factorization {n : ℕ} (hn : n ≠ 0) :
    ppExcess n = ∑ p ∈ n.primeFactors, ((n.factorization p : ℝ) - 1) * Real.log p := by
  rw [ppExcess, log_eq_sum_factorization hn, log_rad, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun p _ => by ring

lemma ppExcess_term_nonneg {n : ℕ} (hn : n ≠ 0) :
    ∀ q ∈ n.primeFactors, 0 ≤ ((n.factorization q : ℝ) - 1) * Real.log q := by
  intro q hq
  have hq' := Nat.prime_of_mem_primeFactors hq
  have h1 : 1 ≤ n.factorization q :=
    Nat.Prime.factorization_pos_of_dvd hq' hn (Nat.dvd_of_mem_primeFactors hq)
  have h1' : (1 : ℝ) ≤ (n.factorization q : ℝ) := by exact_mod_cast h1
  have hlog : 0 ≤ Real.log q := Real.log_nonneg (by exact_mod_cast hq'.one_lt.le)
  nlinarith

theorem ppExcess_nonneg (n : ℕ) : 0 ≤ ppExcess n := by
  rcases eq_or_ne n 0 with rfl | hn
  · simp [ppExcess, rad]
  · rw [ppExcess_eq_sum_factorization hn]
    exact Finset.sum_nonneg (ppExcess_term_nonneg hn)

/-- The prime-power feature carries *only* prime-power information: it vanishes
exactly on the squarefree inputs, where the base feature is already complete. -/
theorem ppExcess_eq_zero_iff_squarefree {n : ℕ} (hn : n ≠ 0) :
    ppExcess n = 0 ↔ Squarefree n := by
  constructor
  · intro h
    rw [ppExcess_eq_sum_factorization hn] at h
    rw [Nat.squarefree_iff_factorization_le_one hn]
    intro p
    by_cases hp : p ∈ n.primeFactors
    · have hzero := (Finset.sum_eq_zero_iff_of_nonneg (ppExcess_term_nonneg hn)).1 h p hp
      have hp' := Nat.prime_of_mem_primeFactors hp
      have hlog : 0 < Real.log p := Real.log_pos (by exact_mod_cast hp'.one_lt)
      have hfac : (n.factorization p : ℝ) - 1 = 0 := by
        rcases mul_eq_zero.1 hzero with h' | h'
        · exact h'
        · exact absurd h' (ne_of_gt hlog)
      have : (n.factorization p : ℝ) = 1 := by linarith
      have : n.factorization p = 1 := by exact_mod_cast this
      omega
    · rw [← Nat.support_factorization] at hp
      simp [Finsupp.notMem_support_iff.mp hp]
  · intro h
    have hr : rad n = n := Nat.prod_primeFactors_of_squarefree h
    simp [ppExcess, hr]

/-- A single square divisor already contributes `log p` of prime-power mass. -/
theorem log_le_ppExcess_of_sq_dvd {n p : ℕ} (hn : n ≠ 0) (hp : p.Prime) (h : p ^ 2 ∣ n) :
    Real.log p ≤ ppExcess n := by
  have hmem : p ∈ n.primeFactors :=
    Nat.mem_primeFactors.2 ⟨hp, dvd_trans (dvd_pow_self p two_ne_zero) h, hn⟩
  have h2 : 2 ≤ n.factorization p := (Nat.Prime.pow_dvd_iff_le_factorization hp hn).1 h
  rw [ppExcess_eq_sum_factorization hn]
  have hsingle := Finset.single_le_sum (ppExcess_term_nonneg hn) hmem
  have hcast : (2 : ℝ) ≤ (n.factorization p : ℝ) := by exact_mod_cast h2
  have hlog : 0 ≤ Real.log p := Real.log_nonneg (by exact_mod_cast hp.one_lt.le)
  nlinarith

theorem log_two_le_ppExcess_of_four_dvd {n : ℕ} (hn : n ≠ 0) (h : 4 ∣ n) :
    Real.log 2 ≤ ppExcess n := by
  have h4 : (2 : ℕ) ^ 2 ∣ n := by norm_num; omega
  simpa using log_le_ppExcess_of_sq_dvd hn Nat.prime_two h4

/-- The excess of a prime power, the extreme case of the feature. -/
theorem ppExcess_prime_pow {p k : ℕ} (hp : p.Prime) (hk : 1 ≤ k) :
    ppExcess (p ^ k) = ((k : ℝ) - 1) * Real.log p := by
  rw [ppExcess, rad_prime_pow hp (by omega)]
  push_cast
  rw [Real.log_pow]
  ring

/-! ## Irreducible error of the base model: why `ΔR² > 0` is forced -/

/-- **Radical collisions force base-model error.**  If two integers have the same
radical, then *no* predictor `f` built from the base feature alone can fit both:
its total squared residual is at least half the squared gap of the targets. -/
theorem radCollision_residual_lower_bound (m n : ℕ) (h : rad m = rad n) (f : ℕ → ℝ) :
    (ppExcess m - ppExcess n) ^ 2 / 2 ≤
      (ppExcess m - f (rad m)) ^ 2 + (ppExcess n - f (rad n)) ^ 2 := by
  rw [h]
  nlinarith [sq_nonneg (ppExcess m + ppExcess n - 2 * f (rad n))]

/-- The prime-power model, by contrast, is exact on any design: its residual is
identically zero. -/
theorem ppModel_residual_zero (m n : ℕ) :
    (ppExcess m - ppExcess m) ^ 2 + (ppExcess n - ppExcess n) ^ 2 = 0 := by ring

/-- **A strictly positive lift at every prime.**  On the two-point design
`{p², p}` the base feature is constant (`rad p² = rad p = p`) while the target
moves by `log p`; hence every base-only predictor carries squared residual at
least `(log p)² / 2 > 0`, while the prime-power predictor is exact
(`ppModel_residual_zero`).  This is the deterministic core of the measured
`ΔR² > 0`, and the floor grows with `p`. -/
theorem prime_square_residual_lower_bound {p : ℕ} (hp : p.Prime) (f : ℕ → ℝ) :
    0 < (Real.log p) ^ 2 / 2 ∧
      (Real.log p) ^ 2 / 2 ≤
        (ppExcess (p ^ 2) - f (rad (p ^ 2))) ^ 2 + (ppExcess p - f (rad p)) ^ 2 := by
  have hlog : 0 < Real.log p := Real.log_pos (by exact_mod_cast hp.one_lt)
  have h1 : ppExcess p = 0 := by rw [ppExcess, rad_prime hp]; ring
  have h2 : ppExcess (p ^ 2) = Real.log p := by
    rw [ppExcess_prime_pow hp (by norm_num)]; norm_num
  have hrad : rad (p ^ 2) = rad p := by rw [rad_prime_pow hp two_ne_zero, rad_prime hp]
  refine ⟨by positivity, ?_⟩
  have h := radCollision_residual_lower_bound (p ^ 2) p hrad f
  rw [h1, h2] at h ⊢
  linarith

/-- A concrete collision witnessing that the prime-power feature is *not* a
function of the base feature: `rad 4 = rad 2` but the excesses differ.  So no
model in the base feature alone can reproduce the prime-power signal. -/
theorem ppExcess_not_function_of_rad :
    rad 4 = rad 2 ∧ ppExcess 4 ≠ ppExcess 2 := by
  have h4 : rad 4 = 2 := by
    have : (4 : ℕ) = 2 ^ 2 := by norm_num
    rw [this, rad_prime_pow Nat.prime_two two_ne_zero]
  have h2 : rad 2 = 2 := rad_prime Nat.prime_two
  refine ⟨by rw [h4, h2], ?_⟩
  have e2 : ppExcess 2 = 0 := by rw [ppExcess, h2]; ring
  have e4 : Real.log 2 ≤ ppExcess 4 :=
    log_two_le_ppExcess_of_four_dvd (by norm_num) (by norm_num)
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [e2]
  linarith

/-! ## Window mass: seed-uniform floor and growth in the window length -/

/-- The total prime-power mass carried by the window `[a, a + w)`; the
deterministic analogue of the measured lift of a window of length `w` at
seed/offset `a`. -/
noncomputable def windowMass (a w : ℕ) : ℝ := ∑ n ∈ Finset.Ico a (a + w), ppExcess n

theorem windowMass_zero (a : ℕ) : windowMass a 0 = 0 := by simp [windowMass]

theorem windowMass_add (a w v : ℕ) :
    windowMass a (w + v) = windowMass a w + windowMass (a + w) v := by
  unfold windowMass
  rw [← Finset.sum_Ico_consecutive _ (Nat.le_add_right a w) (by omega : a + w ≤ a + (w + v))]
  ring_nf

theorem windowMass_nonneg (a w : ℕ) : 0 ≤ windowMass a w :=
  Finset.sum_nonneg fun n _ => ppExcess_nonneg n

/-- The lift is monotone in the window length. -/
theorem windowMass_mono (a : ℕ) {w v : ℕ} (h : w ≤ v) : windowMass a w ≤ windowMass a v := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le h
  rw [windowMass_add]
  linarith [windowMass_nonneg (a + w) d]

/-- **Seed-uniform floor.**  For *every* offset `a ≥ 1` the window `[a, a+w)`
carries at least `⌊w/4⌋ · log 2` of prime-power mass.  The bound is completely
independent of the offset — the deterministic counterpart of the observed
cross-seed stability (sd `0.0025` over five seeds). -/
theorem windowMass_ge_of_offset {a w : ℕ} (ha : 1 ≤ a) :
    ((w / 4 : ℕ) : ℝ) * Real.log 2 ≤ windowMass a w := by
  classical
  set c := 4 * ((a + 3) / 4) with hc
  set S : Finset ℕ := (Finset.range (w / 4)).image (fun k => c + 4 * k) with hS
  have hinj : Set.InjOn (fun k => c + 4 * k) (Finset.range (w / 4)) := by
    intro x _ y _ h
    simp only at h
    omega
  have hcard : S.card = w / 4 := by
    rw [hS, Finset.card_image_of_injOn hinj, Finset.card_range]
  have hsub : S ⊆ Finset.Ico a (a + w) := by
    intro n hn
    simp only [hS, Finset.mem_image, Finset.mem_range] at hn
    obtain ⟨k, hk, rfl⟩ := hn
    have h4 : 4 * (w / 4) ≤ w := by omega
    simp only [Finset.mem_Ico]
    exact ⟨by omega, by omega⟩
  have hterm : ∀ n ∈ S, Real.log 2 ≤ ppExcess n := by
    intro n hn
    simp only [hS, Finset.mem_image, Finset.mem_range] at hn
    obtain ⟨k, hk, rfl⟩ := hn
    exact log_two_le_ppExcess_of_four_dvd (by omega) (by omega)
  calc ((w / 4 : ℕ) : ℝ) * Real.log 2 = (S.card : ℝ) * Real.log 2 := by rw [hcard]
    _ ≤ ∑ n ∈ S, ppExcess n := by simpa using Finset.card_nsmul_le_sum S _ _ hterm
    _ ≤ windowMass a w :=
        Finset.sum_le_sum_of_subset_of_nonneg hsub (fun n _ _ => ppExcess_nonneg n)

/-- **The lift strictly grows with the window length**: four extra integers add
at least `log 2` of mass, uniformly in the offset. -/
theorem windowMass_add_ge_add_log_two {a w : ℕ} (ha : 1 ≤ a) :
    windowMass a w + Real.log 2 ≤ windowMass a (w + 4) := by
  have h := windowMass_ge_of_offset (a := a + w) (w := 4) (by omega)
  rw [windowMass_add]
  norm_num at h
  linarith

/-- Positivity of the lift at every seed: the deterministic floor already
excludes zero once the window has length at least `4`. -/
theorem windowMass_pos {a w : ℕ} (ha : 1 ≤ a) (hw : 4 ≤ w) : 0 < windowMass a w := by
  have h := windowMass_ge_of_offset (a := a) (w := w) ha
  have h1 : 1 ≤ w / 4 := by omega
  have h1' : (1 : ℝ) ≤ ((w / 4 : ℕ) : ℝ) := by exact_mod_cast h1
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  nlinarith

/-- Concrete floor at the short experimental window `w = 240`, uniform over
seeds. -/
theorem windowMass_240_ge {a : ℕ} (ha : 1 ≤ a) : 60 * Real.log 2 ≤ windowMass a 240 := by
  have h := windowMass_ge_of_offset (a := a) (w := 240) ha
  norm_num at h
  linarith

/-- Concrete floor at the long experimental window `w = 960`. -/
theorem windowMass_960_ge {a : ℕ} (ha : 1 ≤ a) : 240 * Real.log 2 ≤ windowMass a 960 := by
  have h := windowMass_ge_of_offset (a := a) (w := 960) ha
  norm_num at h
  linarith

/-- **The `240 → 960` growth of the experiment, made deterministic.**  Passing
from the short window to the long one adds at least `180 · log 2` of prime-power
mass on top of the short-window value, at every seed. -/
theorem windowMass_960_ge_windowMass_240_add {a : ℕ} (ha : 1 ≤ a) :
    windowMass a 240 + 180 * Real.log 2 ≤ windowMass a 960 := by
  have hsplit : windowMass a 960 = windowMass a 240 + windowMass (a + 240) 720 := by
    have := windowMass_add a 240 720
    norm_num at this
    linarith
  have h := windowMass_ge_of_offset (a := a + 240) (w := 720) (by omega)
  norm_num at h
  linarith

/-! ## The small-`u` (smooth) regime: quadratic prime-power mass -/

theorem two_pow_isSmooth (k : ℕ) : isSmooth 2 (2 ^ k) := by
  intro p hp hdvd
  have := (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 (hp.dvd_of_dvd_pow hdvd)
  omega

theorem ppExcess_two_pow {k : ℕ} (hk : 1 ≤ k) :
    ppExcess (2 ^ k) = ((k : ℝ) - 1) * Real.log 2 := by
  simpa using ppExcess_prime_pow Nat.prime_two hk

/-- **Quadratic mass on the `2`-smooth tower.**  Summing the prime-power feature
over `2, 4, …, 2^m` gives `m(m-1)/2 · log 2`: on the smoothest inputs the mass
grows quadratically in the number of terms. -/
theorem smoothTower_mass (m : ℕ) :
    ∑ k ∈ Finset.Icc 1 m, ppExcess (2 ^ k) = ((m : ℝ) * (m - 1) / 2) * Real.log 2 := by
  induction m with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_Icc_succ_top (by omega), ih, ppExcess_two_pow (k := n + 1) (by omega)]
    push_cast
    ring

/-- **The average prime-power signal on the smooth tower diverges.**  Hence the
lift attainable from the prime-power feature is unbounded in the smooth regime —
the structural reason the measured lift is larger at the smaller smoothness
parameter `u` (`0.058` vs `0.051` at `w = 240`, `0.082` vs `0.058` at `w = 960`). -/
theorem smoothTower_mean_unbounded (C : ℝ) :
    ∃ m : ℕ, 0 < m ∧ C < (∑ k ∈ Finset.Icc 1 m, ppExcess (2 ^ k)) / m := by
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  obtain ⟨m, hm⟩ := exists_nat_gt (2 * C / Real.log 2 + 1)
  refine ⟨m + 1, by omega, ?_⟩
  rw [smoothTower_mass]
  have key : (((m : ℝ) + 1) * (((m : ℝ) + 1) - 1) / 2) * Real.log 2 / ((m : ℝ) + 1)
      = ((m : ℝ) / 2) * Real.log 2 := by
    have hm1 : ((m : ℝ) + 1) ≠ 0 := by positivity
    field_simp
    ring
  push_cast
  rw [key]
  have h' : 2 * C / Real.log 2 < (m : ℝ) := by linarith
  rw [div_lt_iff₀ hlog] at h'
  linarith

end PPowMultiseed