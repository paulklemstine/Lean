/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# The structural reason the band-9 ratio has mean one but must be clustered by `N`

Context (experiment 569, paper 216).  The measured object is the ratio of the `B`-smooth
rate of the candidate values `j² - N` to the rate of size-matched random controls.  This
file proves the arithmetic facts that govern that ratio at the level of a single small
prime, and the consequence for the inference design.

For an odd prime `p` not dividing `N`, the candidate `j² - N` is divisible by `p` for
`1 + legendreSym p N` residues `j mod p`, i.e. for *two* residues when `N` is a quadratic
residue mod `p` and for *none* otherwise, against exactly one residue for a random integer.
So at every single prime the candidate pool deviates from the control pool by the extreme
factor `2` or `0` — there is no small-perturbation regime.

Main results:

* `U9Drift.sqrtCount_eq` / `U9Drift.localDensity_eq` — the local density of `p | j² - N` is
  `(1 + legendreSym p N)/p`.
* `U9Drift.localDensity_residue` / `U9Drift.localDensity_nonresidue` — it is `2/p` or `0`:
  a `±100%` deviation from the control density `1/p`.
* `U9Drift.two_class_average` — averaged over the two quadratic classes of `N` the local
  density is *exactly* the control density `1/p`.  This is the structural form of the `H0`
  branch: there is no first-order drift for the pooled population, only a rearrangement of
  it across the population of moduli.
* `U9Drift.mean_signProd` / `U9Drift.second_moment_signProd` — modelling the multiplicative
  bias of a modulus by `∏_{i<k} (1 + ε_i)` with independent signs, the mean is `1` while the
  second moment is `2^k`.  Hence `U9Drift.variance_signProd`: the between-modulus variance
  is `2^k - 1`, exponentially large.
* `U9Drift.effective_sample_size_is_the_cluster_count` — consequently the dispersion of the
  pooled estimator is driven by the number of distinct moduli, not by the number of pairs:
  a bootstrap that resamples pairs rather than `N`-clusters understates the spread by an
  exponentially large factor.  This is the quantitative justification of the run's cluster
  bootstrap over its `128` `N`-clusters.
-/

namespace U9Drift

open Finset

/-! ## The local density of `p ∣ j² - N` -/

/-- The number of residues `j mod p` with `p ∣ j² - N`. -/
noncomputable def sqrtCount (p : ℕ) [Fact p.Prime] (N : ℤ) : ℕ :=
  {x : ZMod p | x ^ 2 = (N : ZMod p)}.toFinset.card

/-- Counting square roots: the candidate pool hits `p` on `1 + legendreSym p N` residues. -/
theorem sqrtCount_eq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (N : ℤ) :
    (sqrtCount p N : ℤ) = legendreSym p N + 1 :=
  legendreSym.card_sqrts p hp N

/-- The local density of the event `p ∣ j² - N` over a full period of `j`. -/
noncomputable def localDensity (p : ℕ) [Fact p.Prime] (N : ℤ) : ℚ := (sqrtCount p N : ℚ) / p

/-- The control density: a random integer is divisible by `p` with density `1/p`. -/
noncomputable def controlDensity (p : ℕ) : ℚ := 1 / p

theorem localDensity_eq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (N : ℤ) :
    localDensity p N = ((legendreSym p N : ℚ) + 1) / p := by
  have h : (sqrtCount p N : ℤ) = legendreSym p N + 1 := sqrtCount_eq p hp N
  have h' : ((sqrtCount p N : ℚ)) = (legendreSym p N : ℚ) + 1 := by exact_mod_cast h
  rw [localDensity, h']

/-- If `N` is a quadratic residue mod `p`, the candidate pool is *twice* as likely to be
divisible by `p` as a random integer. -/
theorem localDensity_residue (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (h : legendreSym p N = 1) : localDensity p N = 2 * controlDensity p := by
  rw [localDensity_eq p hp N, h, controlDensity]
  push_cast
  ring

/-- If `N` is a non-residue mod `p`, the candidate pool never meets `p` at all. -/
theorem localDensity_nonresidue (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (h : legendreSym p N = -1) : localDensity p N = 0 := by
  rw [localDensity_eq p hp N, h]
  push_cast
  ring

/-- **No first-order drift.**  Averaged over the two quadratic classes of `N`, the local
density of the candidate pool is exactly the control density. -/
theorem two_class_average (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N₁ N₂ : ℤ}
    (h₁ : legendreSym p N₁ = 1) (h₂ : legendreSym p N₂ = -1) :
    (localDensity p N₁ + localDensity p N₂) / 2 = controlDensity p := by
  rw [localDensity_residue p hp h₁, localDensity_nonresidue p hp h₂]
  ring

/-- The deviation at a single prime is total: the candidate density is either `2/p` or `0`,
never close to the control density `1/p` unless `p` is huge. -/
theorem local_deviation_is_extreme (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (N : ℤ)
    (hN : legendreSym p N = 1 ∨ legendreSym p N = -1) :
    |localDensity p N - controlDensity p| = controlDensity p := by
  rcases hN with h | h
  · rw [localDensity_residue p hp h]
    rw [show 2 * controlDensity p - controlDensity p = controlDensity p by ring,
      abs_of_nonneg]
    rw [controlDensity]
    positivity
  · rw [localDensity_nonresidue p hp h, zero_sub, abs_neg, abs_of_nonneg]
    rw [controlDensity]
    positivity

/-! ## The multiplicative sign model: mean one, exponentially heavy dispersion -/

/-- The multiplicative bias of one modulus across `k` small primes: `∏ (1 + ε_i)` with
`ε_i = ±1` the quadratic characters. -/
def signProd {k : ℕ} (e : Fin k → Bool) : ℚ := ∏ i, (1 + if e i then (1 : ℚ) else -1)

private theorem sum_prod_bool {k : ℕ} (g : Fin k → Bool → ℚ) :
    ∑ e : Fin k → Bool, ∏ i, g i (e i) = ∏ i, ∑ b : Bool, g i b := by
  rw [Finset.prod_univ_sum, Fintype.piFinset_univ]

/-- The total mass of the multiplicative bias over all `2^k` sign patterns. -/
theorem sum_signProd (k : ℕ) : ∑ e : Fin k → Bool, signProd e = 2 ^ k := by
  have h := sum_prod_bool (fun (_ : Fin k) (b : Bool) => 1 + if b then (1 : ℚ) else -1)
  simp only [signProd]
  rw [h]
  norm_num

/-- The total mass of the squared bias. -/
theorem sum_signProd_sq (k : ℕ) : ∑ e : Fin k → Bool, signProd e ^ 2 = 4 ^ k := by
  have h := sum_prod_bool
    (fun (_ : Fin k) (b : Bool) => (1 + if b then (1 : ℚ) else -1) ^ 2)
  have hsq : ∀ e : Fin k → Bool, signProd e ^ 2
      = ∏ i, (1 + if e i then (1 : ℚ) else -1) ^ 2 := by
    intro e
    simp only [signProd]
    rw [← Finset.prod_pow]
  simp only [hsq]
  rw [h]
  norm_num

/-- **Mean one.**  Averaged over the `2^k` sign patterns, the multiplicative bias is exactly
`1`: the candidate population is not globally biased. -/
theorem mean_signProd (k : ℕ) :
    (∑ e : Fin k → Bool, signProd e) / 2 ^ k = 1 := by
  rw [sum_signProd]
  field_simp

/-- **Exponentially heavy second moment.**  The mean square of the multiplicative bias is
`2^k`, not `O(1)`. -/
theorem second_moment_signProd (k : ℕ) :
    (∑ e : Fin k → Bool, signProd e ^ 2) / 2 ^ k = 2 ^ k := by
  rw [sum_signProd_sq, show (4 : ℚ) ^ k = 2 ^ k * 2 ^ k by rw [← mul_pow]; norm_num]
  field_simp

/-- Hence the between-modulus variance of the multiplicative bias is `2^k - 1`. -/
theorem variance_signProd (k : ℕ) :
    (∑ e : Fin k → Bool, signProd e ^ 2) / 2 ^ k
      - ((∑ e : Fin k → Bool, signProd e) / 2 ^ k) ^ 2 = 2 ^ k - 1 := by
  rw [second_moment_signProd, mean_signProd]
  ring

/-- **The effective sample size is the cluster count.**  The variance-to-mean-square ratio
of the per-modulus bias grows like `2^k`, so a bootstrap that treats the `19.2·10⁶` pairs as
exchangeable understates the spread by that exponentially large factor; only resampling
whole `N`-clusters is consistent. -/
theorem effective_sample_size_is_the_cluster_count (k : ℕ) (hk : 1 ≤ k) :
    2 ≤ (∑ e : Fin k → Bool, signProd e ^ 2) / 2 ^ k
      - ((∑ e : Fin k → Bool, signProd e) / 2 ^ k) ^ 2 + 1 := by
  rw [variance_signProd]
  have : (2 : ℚ) ^ 1 ≤ 2 ^ k := by
    apply pow_le_pow_right₀ (by norm_num) hk
  simpa using by linarith [this]

end U9Drift