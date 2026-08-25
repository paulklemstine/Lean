import Mathlib
import Algebra.ZeroFitDialU120Certificates

/-!
# Capacity–fade duality and the inverse pooling problem

## Research context (FACT round-72 #4, exp 554, fourth cycle)

Cycles 1–3 settled what the recorded decline *is not* (not a pooling artefact, not seed
imbalance below five-fold) and produced sharp constants for pooling.  This cycle closes
two loops that those cycles opened.

* **The capacity reading of the fade.**  `Algebra.ZeroFitDialU120Kantorovich` observed that
  the capacity law `k·ρ² ≤ 1` allows three decorrelated statistics at the ladder top and
  five at U120, but treated the two ends as isolated numerical facts.  Here the capacity
  is made a function `dialCapacity ρ = ⌊1/ρ²⌋` of the reading, and the equivalence between
  "the ladder has no positive floor" and "the capacity is unbounded" is proved in both
  directions.  A floor is exactly a capacity ceiling.
* **The inverse pooling problem.**  Cycles 1–2 bound the pooled reading from the per-seed
  readings.  An experiment needs the opposite: what do the per-seed readings have to be,
  given the pooled value?  `seed_reading_window` answers this with a two-sided window whose
  width is controlled by the imbalance window alone.

## Main results

* `dialCapacity`, `dialCapacity_antitone` — the capacity of a reading, antitone in the
  reading: a fading dial has a nondecreasing capacity.
* `le_dialCapacity_of_le`, `sq_le_of_le_dialCapacity` — the two conversion lemmas between
  a reading bound and a capacity bound.
* `capacity_unbounded_of_fade` — a persistent multiplicative fade drives the capacity
  above every level.
* `bounded_capacity_gives_floor` — the exact converse: a capacity ceiling `K` is a genuine
  positive floor `ρ² > 1/(K+1)` at every rung.  Together these two are the
  **capacity–fade duality**.
* `dial_capacity_at_top`, `dial_capacity_at_u120`, `capacity_expansion_exact` — the
  recorded ladder moves from capacity `3` to capacity `5`.
* `seed_reading_window` — the **inverse pooling law**: the largest per-seed reading is at
  least the pooled value, and the smallest is at most the pooled value inflated by
  `(α+β)/(2√(αβ))`.
* `u120_seed_window` — at the recorded pooled value with a `±10%` imbalance window, some
  seed reads at least `0.43636` and some seed reads at most `0.43835`.

## Lab notes

```
dialCapacity 0.5739  = ⌊1/0.329361⌋ = ⌊3.0362⌋ = 3
dialCapacity 0.4847  = ⌊1/0.234934⌋ = ⌊4.2565⌋ = 4
dialCapacity 0.43636 = ⌊1/0.190410⌋ = ⌊5.2518⌋ = 5
inverse window at U120 (λ ∈ [1, 1.21]) : [0.43636, 0.43835]
```
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU120Capacity

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialU120Floor
open Catalog.Algebra.ZeroFitDialU120Kantorovich

/-! ## 1. The capacity of a reading -/

/-- The **capacity of a dial reading**: the largest `k` allowed by the capacity law
`k·ρ² ≤ 1`, i.e. the number of mutually decorrelated statistics that can all read at level
`ρ`. -/
noncomputable def dialCapacity (rho : ℝ) : ℕ := ⌊1 / rho ^ 2⌋₊

/-- Capacity is antitone in the reading: a fading dial has a nondecreasing capacity. -/
theorem dialCapacity_antitone {rho sigma : ℝ} (hrho : 0 < rho) (h : rho ≤ sigma) :
    dialCapacity sigma ≤ dialCapacity rho := by
  refine Nat.floor_le_floor ?_
  exact one_div_le_one_div_of_le (by positivity) (by nlinarith)

/-- A small enough reading forces a large capacity. -/
theorem le_dialCapacity_of_le {rho : ℝ} {K : ℕ} (hrho : 0 < rho)
    (h : rho ≤ 1 / ((K : ℝ) + 1)) :
    K ≤ dialCapacity rho := by
  have hK : (0:ℝ) < (K : ℝ) + 1 := by positivity
  have hmul : rho * ((K : ℝ) + 1) ≤ 1 := by
    rw [le_div_iff₀ hK] at h
    linarith
  have hle : (K : ℝ) ≤ 1 / rho ^ 2 := by
    rw [le_div_iff₀ (by positivity)]
    nlinarith [hrho.le, Nat.cast_nonneg (α := ℝ) K]
  exact Nat.le_floor hle

/-- Conversely a large capacity forces a small reading. -/
theorem sq_le_of_le_dialCapacity {rho : ℝ} {K : ℕ} (hK : 1 ≤ K) (hrho : 0 < rho)
    (h : K ≤ dialCapacity rho) :
    rho ^ 2 ≤ 1 / (K : ℝ) := by
  have hKR : (0:ℝ) < (K : ℝ) := by exact_mod_cast hK
  have hfl : (K : ℝ) ≤ 1 / rho ^ 2 := by
    rw [dialCapacity, Nat.le_floor_iff (by positivity)] at h
    exact h
  rw [le_div_iff₀ (by positivity)] at hfl
  rw [le_div_iff₀ hKR]
  linarith

/-! ## 2. Capacity–fade duality -/

/-- A persistent multiplicative fade drives the capacity above every level. -/
theorem capacity_unbounded_of_fade {rho : ℕ → ℝ} {q : ℝ} (hq : 0 ≤ q) (hq1 : q < 1)
    (hpos : ∀ k, 0 < rho k) (hstep : ∀ k, rho (k + 1) ≤ q * rho k) (K : ℕ) :
    ∃ N, K ≤ dialCapacity (rho N) := by
  obtain ⟨N, hN⟩ := fade_below_any_floor hq hq1 (fun k => (hpos k).le) hstep
    (show (0:ℝ) < 1 / ((K : ℝ) + 1) by positivity)
  exact ⟨N, le_dialCapacity_of_le (hpos N) (hN N le_rfl).le⟩

/-- The exact converse: a capacity ceiling is a positive floor.  A ladder whose capacity
never exceeds `K` satisfies `ρ² > 1/(K+1)` at every rung. -/
theorem bounded_capacity_gives_floor {rho : ℕ → ℝ} {K : ℕ} (hpos : ∀ k, 0 < rho k)
    (hcap : ∀ N, dialCapacity (rho N) ≤ K) (N : ℕ) :
    1 / ((K : ℝ) + 1) < rho N ^ 2 := by
  have hlt : 1 / rho N ^ 2 < (K : ℝ) + 1 := by
    have h1 : 1 / rho N ^ 2 < (⌊1 / rho N ^ 2⌋₊ : ℝ) + 1 :=
      Nat.lt_floor_add_one _
    have h2 : ((dialCapacity (rho N) : ℝ)) ≤ (K : ℝ) := by exact_mod_cast hcap N
    rw [dialCapacity] at h2
    linarith
  have hr : (0:ℝ) < rho N ^ 2 := pow_pos (hpos N) 2
  rw [div_lt_iff₀ hr] at hlt
  rw [div_lt_iff₀ (by positivity)]
  linarith

/-! ## 3. The recorded ladder in capacity terms -/

theorem dial_capacity_at_top : dialCapacity 0.5739 = 3 := by
  rw [dialCapacity, Nat.floor_eq_iff (by norm_num)]
  constructor <;> norm_num

theorem dial_capacity_at_u120 : dialCapacity 0.43636 = 5 := by
  rw [dialCapacity, Nat.floor_eq_iff (by norm_num)]
  constructor <;> norm_num

/-- The recorded fade is a strict capacity expansion. -/
theorem capacity_expansion_exact : dialCapacity 0.5739 < dialCapacity 0.43636 := by
  rw [dial_capacity_at_top, dial_capacity_at_u120]
  norm_num

/-! ## 4. The inverse pooling problem -/

variable {m n : ℕ}

/-- **The inverse pooling law.**  From a pooled reading and an imbalance window one reads
off a two-sided window for the per-seed readings: some seed reads at least the pooled
value, and some seed reads at most the pooled value inflated by `(α+β)/(2√(αβ))`. -/
theorem seed_reading_window {u v : Fin m → (Fin n → ℝ)} {lam : Fin m → ℝ}
    {alpha beta rhomin rhomax : ℝ}
    (halpha : 0 < alpha) (hab : alpha ≤ beta) (hmin : 0 ≤ rhomin) (hmax : 0 ≤ rhomax)
    (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u) (hv : 0 < blockNormSq v)
    (hbal : ∀ k, nrm (v k) = lam k * nrm (u k))
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta)
    (hrmin : ∀ k, rhomin ≤ corr (u k) (v k)) (hrmax : ∀ k, corr (u k) (v k) ≤ rhomax) :
    pooledCorr u v ≤ rhomax ∧
      rhomin ≤ pooledCorr u v * ((alpha + beta) / (2 * Real.sqrt (alpha * beta))) := by
  have hbeta : 0 < beta := lt_of_lt_of_le halpha hab
  have hsqrt : 0 < Real.sqrt (alpha * beta) := Real.sqrt_pos.mpr (by positivity)
  have hsum : 0 < alpha + beta := by linarith
  have hkappa : 0 < 2 * Real.sqrt (alpha * beta) / (alpha + beta) := by positivity
  refine ⟨pooled_le_max_corr hmax hu0 hv0 hu hv hrmax, ?_⟩
  have hk := pooled_kantorovich_bound halpha hab hmin hu0 hv0 hu hbal hlo hhi hrmin
  have hle : rhomin ≤ pooledCorr u v / (2 * Real.sqrt (alpha * beta) / (alpha + beta)) :=
    (le_div_iff₀ hkappa).mpr hk
  have heq : pooledCorr u v / (2 * Real.sqrt (alpha * beta) / (alpha + beta))
      = pooledCorr u v * ((alpha + beta) / (2 * Real.sqrt (alpha * beta))) := by
    have hne1 : (2:ℝ) * Real.sqrt (alpha * beta) ≠ 0 := by positivity
    have hne2 : alpha + beta ≠ 0 := ne_of_gt hsum
    field_simp
  rwa [heq] at hle

/-- At the recorded pooled value, with per-seed norm ratios inside a `±10%` window, some
seed reads at least `0.43636` and some seed reads at most `0.43835`. -/
theorem u120_seed_window {u v : Fin m → (Fin n → ℝ)} {lam : Fin m → ℝ}
    {rhomin rhomax : ℝ} (hmin : 0 ≤ rhomin) (hmax : 0 ≤ rhomax)
    (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u) (hv : 0 < blockNormSq v)
    (hbal : ∀ k, nrm (v k) = lam k * nrm (u k))
    (hlo : ∀ k, (1:ℝ) ≤ lam k) (hhi : ∀ k, lam k ≤ 121 / 100)
    (hrmin : ∀ k, rhomin ≤ corr (u k) (v k)) (hrmax : ∀ k, corr (u k) (v k) ≤ rhomax)
    (hpool : pooledCorr u v = 0.43636) :
    0.43636 ≤ rhomax ∧ rhomin ≤ 0.43835 := by
  have hsqrt : Real.sqrt ((1:ℝ) * (121 / 100)) = 11 / 10 := by
    rw [show (1:ℝ) * (121 / 100) = (11 / 10 : ℝ) ^ 2 by norm_num,
      Real.sqrt_sq (by norm_num)]
  obtain ⟨h1, h2⟩ := seed_reading_window (alpha := 1) (beta := 121 / 100)
    (by norm_num) (by norm_num) hmin hmax hu0 hv0 hu hv hbal hlo hhi hrmin hrmax
  rw [hpool] at h1 h2
  rw [hsqrt] at h2
  refine ⟨by linarith, ?_⟩
  norm_num at h2
  linarith

end Catalog.Algebra.ZeroFitDialU120Capacity