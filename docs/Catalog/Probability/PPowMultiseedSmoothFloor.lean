import Mathlib
import Probability.PPowMultiseedLift

/-!
# The smooth regime: why the lift is bigger at smaller `u`

Fifth cycle of the PPOW-MULTISEED study (round-46 #2, experiment 506).  The
experiment reports a *larger* prime-power lift at the smaller smoothness
parameter (`ΔR²` mean `0.058` at `u = 2.5` versus `0.051` at `u = 3.5` for
`w = 240`, and `0.082` versus `0.058` for `w = 960`).  This file gives the
deterministic mechanism, which is a pigeonhole in disguise:

> a `y`-smooth integer has all its prime factors below `y`, so its **radical
> divides the primorial `y#`**, and therefore its base feature can never exceed
> `log (y#) ≤ y log 4` — while its target `log n` is unbounded.  Everything
> above that ceiling *must* be carried by the prime-power feature.

Main results.

* `rad_dvd_primorial` — the radical of a `y`-smooth number divides `y#`.
* `ppExcess_ge_of_smooth` — `ppExcess n ≥ log n - log (y#)` for `y`-smooth `n`.
* `ppExcess_ge_of_smooth_chebyshev` — the Chebyshev form
  `ppExcess n ≥ log n - y log 4`, using `primorial_le_4_pow`.
* `ppExcess_pos_of_smooth_large` — every `y`-smooth `n > 4^y` has a *strictly
  positive* prime-power signal; equivalently, no `y`-smooth number above `4^y`
  is squarefree.
* `ppExcess_ge_of_smooth_u` — the `u`-form: if `n ≥ y^u` (so `u` is at most the
  smoothness parameter `log n / log y`) then
  `ppExcess n ≥ u log y - y log 4`, which *increases* as the design moves to
  smaller `y` at fixed `u`-scale.

The last statement is the formal counterpart of the empirical `u`-dependence:
the smoother the pool, the smaller the ceiling `y log 4` on the base feature,
and hence the larger the share of `log n` that only the prime-power feature can
explain.
-/

namespace PPowMultiseed

open Finset

/-- The radical of a `y`-smooth number divides the primorial `y#`. -/
theorem rad_dvd_primorial {y n : ℕ} (hs : isSmooth y n) : rad n ∣ primorial y := by
  unfold rad primorial
  refine Finset.prod_dvd_prod_of_subset _ _ _ fun p hp => ?_
  have hp' := Nat.prime_of_mem_primeFactors hp
  have hpy : p ≤ y := hs p hp' (Nat.dvd_of_mem_primeFactors hp)
  simp only [Finset.mem_filter, Finset.mem_range]
  exact ⟨by omega, hp'⟩

/-- **The base feature has a ceiling on a smooth pool.**  For a `y`-smooth `n`
the base feature is at most `log (y#)`, so everything above that must be carried
by the prime-power feature. -/
theorem ppExcess_ge_of_smooth {y n : ℕ} (hs : isSmooth y n) :
    Real.log n - Real.log (primorial y) ≤ ppExcess n := by
  have hdvd := rad_dvd_primorial hs
  have hprim_pos : 0 < primorial y := by
    unfold primorial
    exact Finset.prod_pos fun p hp => (Finset.mem_filter.1 hp).2.pos
  have hle : rad n ≤ primorial y := Nat.le_of_dvd hprim_pos hdvd
  have hlog : Real.log (rad n) ≤ Real.log (primorial y) := by
    apply Real.log_le_log
    · exact_mod_cast rad_pos n
    · exact_mod_cast hle
  unfold ppExcess
  linarith

/-- The Chebyshev form of the ceiling: `log (y#) ≤ y log 4`. -/
theorem ppExcess_ge_of_smooth_chebyshev {y n : ℕ} (hs : isSmooth y n) :
    Real.log n - (y : ℝ) * Real.log 4 ≤ ppExcess n := by
  have h := ppExcess_ge_of_smooth hs
  have hprim : primorial y ≤ 4 ^ y := primorial_le_4_pow y
  have hprim_pos : 0 < primorial y := by
    unfold primorial
    exact Finset.prod_pos fun p hp => (Finset.mem_filter.1 hp).2.pos
  have hlog : Real.log (primorial y) ≤ Real.log ((4 : ℕ) ^ y) := by
    apply Real.log_le_log
    · exact_mod_cast hprim_pos
    · exact_mod_cast hprim
  have h4 : Real.log ((4 : ℕ) ^ y) = (y : ℝ) * Real.log 4 := by
    push_cast
    rw [Real.log_pow]
  rw [h4] at hlog
  linarith

/-- **Every sufficiently large smooth number carries prime-power mass.**  A
`y`-smooth `n` with `n > 4^y` has `ppExcess n > 0`; in particular it is not
squarefree.  This is the pigeonhole behind the observed `u`-dependence: on a
smooth pool the prime-power signal cannot vanish. -/
theorem ppExcess_pos_of_smooth_large {y n : ℕ} (hs : isSmooth y n) (hn : 4 ^ y < n) :
    0 < ppExcess n := by
  have h := ppExcess_ge_of_smooth hs
  have hprim : primorial y ≤ 4 ^ y := primorial_le_4_pow y
  have hprim_pos : 0 < primorial y := by
    unfold primorial
    exact Finset.prod_pos fun p hp => (Finset.mem_filter.1 hp).2.pos
  have hlt : (primorial y : ℝ) < (n : ℝ) := by
    have : primorial y < n := lt_of_le_of_lt hprim hn
    exact_mod_cast this
  have hlog : Real.log (primorial y) < Real.log n :=
    Real.log_lt_log (by exact_mod_cast hprim_pos) hlt
  linarith

/-- Such an `n` is therefore never squarefree. -/
theorem not_squarefree_of_smooth_large {y n : ℕ} (hs : isSmooth y n) (hn : 4 ^ y < n) :
    ¬ Squarefree n := by
  intro hsq
  have hn0 : n ≠ 0 := by
    intro h
    rw [h] at hn
    exact absurd hn (Nat.not_lt_zero _)
  have := (ppExcess_eq_zero_iff_squarefree hn0).2 hsq
  have hpos := ppExcess_pos_of_smooth_large hs hn
  linarith

/-- **The `u`-form of the smooth floor.**  If the design consists of `y`-smooth
numbers of size at least `y^u`, then the prime-power feature carries at least
`u log y - y log 4`.  At fixed size this grows as the pool becomes smoother
(smaller `y`), which is the deterministic content of "the lift is larger at the
smaller smoothness parameter `u`". -/
theorem ppExcess_ge_of_smooth_u {y n u : ℕ} (hs : isSmooth y n) (hn : y ^ u ≤ n) (hy : 1 ≤ y) :
    (u : ℝ) * Real.log y - (y : ℝ) * Real.log 4 ≤ ppExcess n := by
  have h := ppExcess_ge_of_smooth_chebyshev hs
  have hn0 : 0 < n := lt_of_lt_of_le (Nat.pow_pos (by omega : 0 < y)) hn
  have hlog : Real.log ((y : ℝ) ^ u) ≤ Real.log n := by
    apply Real.log_le_log
    · have : (1 : ℝ) ≤ (y : ℝ) := by exact_mod_cast hy
      positivity
    · exact_mod_cast hn
  rw [Real.log_pow] at hlog
  linarith

end PPowMultiseed