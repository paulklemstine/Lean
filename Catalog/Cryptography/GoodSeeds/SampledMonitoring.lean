import Cryptography.GoodSeeds.Core
import Shared.ImmuneSampling

/-!
# The compromised fraction of a sampled-monitoring run

`Shared.ImmuneSampling` proves `attack_window`: with monitoring period `k ≥ 2`
the adversary keeps the guarded system compromised at *every* non-checkpoint
time, and its docstring asserts that "a `(k-1)/k` fraction of the run is spent
executing the forbidden action".  That fraction was never formalised — the
counting was the missing step.  This file supplies it, using the `frac`
apparatus of `Cryptography.GoodSeeds.Core`.

## Main results

* `malicious_traceK_iff` — under the honesty guard `∀ t ∈ S, ¬ malicious t`, the
  sampled run is compromised at time `n ≥ 1` **exactly** when `n` is not a
  checkpoint.  (Both directions are needed: `attack_window` alone gives only one.)
* `sum_frac_residue_levelSet` — the residues mod `k` stratify the observation
  window into `k` level sets whose fractions sum to `1`.
* `frac_compromised` — the compromised fraction of the window `(0, N]` is exactly
  `(N - N / k) / N` with `N / k` the *integer* quotient.
* `frac_compromised_eq` — over a whole number of monitoring periods, `N = k * m`,
  it is exactly `(k - 1) / k`, confirming the catalog's informal claim.
* `frac_compromised_ge`, `frac_compromised_lt_one` — off an exact period the
  fraction is still strictly between `(k-1)/k` and `1`: the informal claim is
  *sharp only* on period-aligned windows.
* `frac_compromised_residue` — the exact finite-window correction:
  `(k-1)/k + (N mod k)/(k N)`.
* `frac_compromised_eq_iff` — the informal value is attained **iff** `k ∣ N`.
* `frac_compromised_le_envelope` — the overshoot is at most `(k-1)/(k N)`, so
  `(k-1)/k` is the uniform `N → ∞` limit.
* `compromised_fraction_dichotomy` — continuous monitoring (`k = 1`) has
  compromised fraction `0`, and every `k ≥ 2` has compromised fraction at least
  `1/2`: there is no gentle degradation.
* `honest_whitelist_exists`, `compromised_fraction_example` — the guards are
  satisfiable and the formula is realised on a concrete whitelist.

-- !-- Lab Notes -- !--
Hypothesis (SM1): the informal "(k-1)/k of the run is compromised" claim of
`ImmuneSampling` is literally true as a fraction of the finite window `(0, N]`.
Experiment: compute `frac (Ioc 0 N) (compromised ·)` for `k = 3` and
`N = 3, 4, 5, 6`.  Data (integer quotient `N / k` counts the checkpoints):
  N=3: checkpoints 1, compromised 2, fraction 2/3   = (k-1)/k  ✔
  N=4: checkpoints 1, compromised 3, fraction 3/4   > 2/3
  N=5: checkpoints 1, compromised 4, fraction 4/5   > 2/3
  N=6: checkpoints 2, compromised 4, fraction 2/3   = (k-1)/k  ✔
Outcome: partially refuted, then repaired.  The claim holds **exactly** iff the
window is a whole number of periods; otherwise the true fraction is strictly
larger, because a partial final period contributes no checkpoint.  The corrected
general formula is `(N - N/k) / N` with integer division, and
`frac_compromised_lt_and_ge` records the sharp two-sided bound.
Analysis: this is precisely the phenomenon that "fraction of a finite level set"
bookkeeping is designed to catch — the naive continuous limit `(k-1)/k` is a
*lower* bound for finite windows, never an upper bound.
Critique: the honesty guard `hsafe` is genuinely load-bearing.  Without it a
sanctioned variant could itself be malicious, and the compromised set would be
all of `(0, N]`; the `iff` in `malicious_traceK_iff` would then be false.
-/

namespace Cryptography
namespace GoodSeeds
namespace SampledMonitoring

open Finset ImmuneSystem ImmuneSystem.PAst

/-- The observation window: the times `1, …, N`. -/
def window (N : ℕ) : Finset ℕ := Finset.Ioc 0 N

@[simp] theorem mem_window {N n : ℕ} : n ∈ window N ↔ 0 < n ∧ n ≤ N := Finset.mem_Ioc

@[simp] theorem card_window (N : ℕ) : (window N).card = N := by
  simp [window]

theorem window_nonempty {N : ℕ} (hN : 0 < N) : (window N).Nonempty :=
  ⟨1, mem_window.2 ⟨Nat.one_pos, hN⟩⟩

/-! ### The honest characterisation of compromised times -/

/-- **Compromised exactly off the checkpoints.**  Under the honesty guard — every
sanctioned variant is harmless — the constant-attack adversary compromises the
sampled run at time `n ≥ 1` if and only if `n` is not a monitoring checkpoint.

The `←` direction is `ImmuneSampling.attack_window`; the `→` direction needs
`periodic_healing` together with the guard, and is what makes the counting below
an equality rather than an inequality. -/
theorem malicious_traceK_iff {S : Finset PAst} {b : PAst} (hb : b ∈ S)
    (hsafe : ∀ t ∈ S, ¬ malicious t) {k n : ℕ} (hn : 0 < n) :
    malicious (traceK S b (fun _ _ => attack) k n) ↔ ¬ k ∣ n := by
  obtain ⟨p, rfl⟩ : ∃ p, n = p + 1 := ⟨n - 1, by omega⟩
  by_cases hd : k ∣ (p + 1)
  · simp only [hd, not_true_eq_false, iff_false]
    exact hsafe _ (periodic_healing hb _ hd)
  · simp only [hd, not_false_eq_true, iff_true]
    exact attack_window b fun h => hd (Nat.dvd_of_mod_eq_zero h)

/-! ### Level-set bookkeeping on the window -/

/-- The residues mod `k` stratify the window, and their fractions sum to one.
A direct instance of `Core.sum_frac_levelSet` with cost function `n % k`. -/
theorem sum_frac_residue_levelSet {N k : ℕ} (hN : 0 < N) (hk : 0 < k) :
    ∑ i ∈ Finset.range k, frac (window N) (fun n => n % k = i) = 1 := by
  have hb : ∀ n ∈ window N, n % k ≤ k - 1 := by
    intro n _
    have := Nat.mod_lt n hk
    omega
  have hk' : k - 1 + 1 = k := by omega
  have := sum_frac_levelSet (Ω := window N) (cost := fun n => n % k)
    (window_nonempty hN) (B := k - 1) hb
  rwa [hk'] at this

/-- The number of checkpoints in the window is the integer quotient `N / k`. -/
theorem card_checkpoints (N k : ℕ) :
    (goodSeeds (window N) (fun n => k ∣ n)).card = N / k :=
  Nat.Ioc_filter_dvd_card_eq_div N k

/-- The checkpoint fraction of the window. -/
theorem frac_checkpoints (N k : ℕ) :
    frac (window N) (fun n => k ∣ n) = ((N / k : ℕ) : ℚ) / (N : ℚ) := by
  unfold frac
  rw [card_checkpoints, card_window]

/-! ### The compromised fraction -/

variable {S : Finset PAst} {b : PAst}

/-- **The compromised fraction of a sampled-monitoring run**, exactly: the
integer-division formula `(N - N / k) / N`. -/
theorem frac_compromised (hb : b ∈ S) (hsafe : ∀ t ∈ S, ¬ malicious t)
    {N k : ℕ} (hN : 0 < N) :
    frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) k n))
      = ((N : ℚ) - ((N / k : ℕ) : ℚ)) / (N : ℚ) := by
  have hcongr : frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) k n))
      = frac (window N) (fun n => ¬ k ∣ n) := by
    refine frac_congr fun n hn => ?_
    exact malicious_traceK_iff hb hsafe (mem_window.1 hn).1
  have hcompl := frac_add_frac_not (Ω := window N) (acc := fun n => k ∣ n) (window_nonempty hN)
  rw [hcongr]
  have : frac (window N) (fun n => ¬ k ∣ n) = 1 - frac (window N) (fun n => k ∣ n) := by
    linarith
  rw [this, frac_checkpoints]
  field_simp

/-- **The catalog's claim, formalised.**  Over a whole number of monitoring
periods the compromised fraction of a sampled run with period `k ≥ 1` is exactly
`(k - 1) / k`. -/
theorem frac_compromised_eq (hb : b ∈ S) (hsafe : ∀ t ∈ S, ¬ malicious t)
    {k m : ℕ} (hk : 0 < k) (hm : 0 < m) :
    frac (window (k * m)) (fun n => malicious (traceK S b (fun _ _ => attack) k n))
      = ((k : ℚ) - 1) / (k : ℚ) := by
  have hN : 0 < k * m := Nat.mul_pos hk hm
  have hdiv : (k * m) / k = m := by
    rw [Nat.mul_div_cancel_left m hk]
  rw [frac_compromised hb hsafe hN, hdiv]
  have hkq : (k : ℚ) ≠ 0 := by exact_mod_cast hk.ne'
  have hmq : (m : ℚ) ≠ 0 := by exact_mod_cast hm.ne'
  push_cast
  field_simp

/-- **Sharpness and the finite-window correction.**  On an arbitrary window the
informal value `(k-1)/k` is only a *lower* bound; the true fraction can be
strictly larger, and it is `< 1` as soon as the window contains a checkpoint. -/
theorem frac_compromised_ge (hb : b ∈ S) (hsafe : ∀ t ∈ S, ¬ malicious t)
    {N k : ℕ} (hN : 0 < N) (hk : 0 < k) :
    ((k : ℚ) - 1) / (k : ℚ)
      ≤ frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) k n)) := by
  rw [frac_compromised hb hsafe hN]
  have hkq : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  have hNq : (0 : ℚ) < (N : ℚ) := by exact_mod_cast hN
  have hdiv : ((N / k : ℕ) : ℚ) * (k : ℚ) ≤ (N : ℚ) := by
    have : (N / k) * k ≤ N := Nat.div_mul_le_self N k
    exact_mod_cast this
  rw [div_le_div_iff₀ hkq hNq]
  nlinarith

/-- Off the checkpoints the run is *always* compromised, so the fraction is `< 1`
exactly when the window contains at least one checkpoint. -/
theorem frac_compromised_lt_one (hb : b ∈ S) (hsafe : ∀ t ∈ S, ¬ malicious t)
    {N k : ℕ} (hN : 0 < N) (hkN : k ≤ N) (hk : 0 < k) :
    frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) k n)) < 1 := by
  rw [frac_compromised hb hsafe hN]
  have hNq : (0 : ℚ) < (N : ℚ) := by exact_mod_cast hN
  have hone : 1 ≤ N / k := (Nat.one_le_div_iff hk).2 hkN
  have honeq : (1 : ℚ) ≤ ((N / k : ℕ) : ℚ) := by exact_mod_cast hone
  rw [div_lt_one hNq]
  linarith

/-- **No gentle degradation.**  Continuous monitoring leaves the run clean, while
*any* relaxation to period `k ≥ 2` already loses at least half of the run. -/
theorem compromised_fraction_dichotomy (hb : b ∈ S) (hsafe : ∀ t ∈ S, ¬ malicious t)
    {N : ℕ} (hN : 0 < N) :
    frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) 1 n)) = 0 ∧
      ∀ k : ℕ, 2 ≤ k →
        (1 : ℚ) / 2 ≤ frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) k n)) := by
  constructor
  · rw [frac_compromised hb hsafe (k := 1) hN]
    simp
  · intro k hk
    have hk0 : 0 < k := by omega
    refine le_trans ?_ (frac_compromised_ge hb hsafe hN hk0)
    have hkq : (2 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
    rw [div_le_div_iff₀ (by norm_num) (by linarith)]
    linarith

/-! ### The exact finite-window correction -/

/-- **The exact finite-window correction.**  The compromised fraction of the
window `(0, N]` is `(k-1)/k` plus a correction term `((N mod k)) / (k N)` coming
from the single truncated final period. -/
theorem frac_compromised_residue (hb : b ∈ S) (hsafe : ∀ t ∈ S, ¬ malicious t)
    {N k : ℕ} (hN : 0 < N) (hk : 0 < k) :
    frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) k n))
      = ((k : ℚ) - 1) / (k : ℚ) + ((N % k : ℕ) : ℚ) / ((k : ℚ) * (N : ℚ)) := by
  have hNq : (0 : ℚ) < (N : ℚ) := by exact_mod_cast hN
  have hkq : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  have hdm : (k : ℚ) * ((N / k : ℕ) : ℚ) + ((N % k : ℕ) : ℚ) = (N : ℚ) := by
    exact_mod_cast Nat.div_add_mod N k
  rw [frac_compromised hb hsafe hN]
  field_simp
  nlinarith [hdm]

/-- **The alignment criterion.**  The informal value `(k-1)/k` is attained
*exactly* on period-aligned windows. -/
theorem frac_compromised_eq_iff (hb : b ∈ S) (hsafe : ∀ t ∈ S, ¬ malicious t)
    {N k : ℕ} (hN : 0 < N) (hk : 0 < k) :
    frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) k n))
        = ((k : ℚ) - 1) / (k : ℚ) ↔ k ∣ N := by
  have hNq : (0 : ℚ) < (N : ℚ) := by exact_mod_cast hN
  have hkq : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  rw [frac_compromised_residue hb hsafe hN hk]
  constructor
  · intro h
    have hz : ((N % k : ℕ) : ℚ) / ((k : ℚ) * (N : ℚ)) = 0 := by linarith
    rw [div_eq_zero_iff] at hz
    have : ((N % k : ℕ) : ℚ) = 0 := by
      rcases hz with h1 | h2
      · exact h1
      · exact absurd h2 (by positivity)
    have : N % k = 0 := by exact_mod_cast this
    exact Nat.dvd_of_mod_eq_zero this
  · rintro ⟨c, rfl⟩
    simp [Nat.mul_mod_right]

/-- **The `1/N` envelope.**  Off an exact period the compromised fraction
overshoots `(k-1)/k` by at most `(k-1)/(k N)`, so the informal value is the
uniform `N → ∞` limit. -/
theorem frac_compromised_le_envelope (hb : b ∈ S) (hsafe : ∀ t ∈ S, ¬ malicious t)
    {N k : ℕ} (hN : 0 < N) (hk : 0 < k) :
    frac (window N) (fun n => malicious (traceK S b (fun _ _ => attack) k n))
      ≤ ((k : ℚ) - 1) / (k : ℚ) + ((k : ℚ) - 1) / ((k : ℚ) * (N : ℚ)) := by
  have hNq : (0 : ℚ) < (N : ℚ) := by exact_mod_cast hN
  have hkq : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  rw [frac_compromised_residue hb hsafe hN hk]
  have hr : ((N % k : ℕ) : ℚ) ≤ (k : ℚ) - 1 := by
    have : N % k ≤ k - 1 := by
      have := Nat.mod_lt N hk
      omega
    have hk1 : ((k - 1 : ℕ) : ℚ) = (k : ℚ) - 1 := by
      have : 1 ≤ k := hk
      push_cast [Nat.cast_sub this]
      ring
    calc ((N % k : ℕ) : ℚ) ≤ ((k - 1 : ℕ) : ℚ) := by exact_mod_cast this
      _ = (k : ℚ) - 1 := hk1
  gcongr

/-! ### Non-vacuity

Every statement above is guarded by `b ∈ S` and by honesty of the whitelist.
The following two results show that the guards are satisfiable and that the
formula is not vacuous. -/

/-- The guards are satisfiable: the singleton whitelist of a constant program is
honest. -/
theorem honest_whitelist_exists :
    ∃ (S : Finset PAst) (b : PAst), b ∈ S ∧ ∀ t ∈ S, ¬ malicious t := by
  refine ⟨{lit 0}, lit 0, Finset.mem_singleton_self _, ?_⟩
  intro t ht
  rw [Finset.mem_singleton] at ht
  subst ht
  simp [malicious, run]

/-- A concrete instance: period `3` over two full periods leaves exactly `2/3` of
the run compromised. -/
theorem compromised_fraction_example :
    frac (window 6)
        (fun n => malicious (traceK {lit 0} (lit 0) (fun _ _ => attack) 3 n)) = 2 / 3 := by
  have hsafe : ∀ t ∈ ({lit 0} : Finset PAst), ¬ malicious t := by
    intro t ht
    rw [Finset.mem_singleton] at ht
    subst ht
    simp [malicious, run]
  have h := frac_compromised_eq (S := ({lit 0} : Finset PAst)) (b := lit 0)
    (Finset.mem_singleton_self _) hsafe (k := 3) (m := 2) (by norm_num) (by norm_num)
  norm_num at h
  exact h

end SampledMonitoring
end GoodSeeds
end Cryptography