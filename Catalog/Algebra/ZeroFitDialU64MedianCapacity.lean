import Mathlib
import Algebra.ZeroFitDialU72Parity
import Algebra.ZeroFitDialParityCapacity
import Algebra.ZeroFitDialU64Replication

/-!
# Correlated-family capacity and median rigidity for the bitlen-64 replication

## Research context

Second cycle on the `U64B-DIAL-HOLDS-COUNT-PARITY` record (exp 543).  Cycle 1
(`Algebra.ZeroFitDialU64Replication`) established the chord form of Gram positivity and
the *mean/count* rigidity of the six-seed record.  Two questions were left open there.

1. The catalog's capacity law (`Algebra.ZeroFitDialParityCapacity.parity_capacity_ceiling`)
   needs an **orthonormal** family: `k·ρ² ≤ 1`.  The parity ceiling of
   `Algebra.ZeroFitDialU72Parity` needs `k = 2` but allows a mutual correlation `c`:
   `ρ² ≤ (1+c)/2`.  Neither covers the realistic situation of `k` *mildly correlated*
   statistics — exactly the situation of a dial family (trailing zeros, popcount, leading
   zeros, …) read against one response.
2. The record reports a **median** `+0.058` alongside the mean `+0.059`.  Cycle 1 used
   only the mean.  The median is the sharper instrument: it pins the *whole* winning
   group, not just its average.

## Main results

* `correlated_family_capacity` — **the interpolating capacity law**: `k` unit statistics
  with pairwise correlations bounded by `γ`, each reading at least `ρ ≥ 0` against a
  shared response, satisfy `k·ρ² ≤ 1 + (k-1)γ`.  Setting `γ = 0` recovers the orthonormal
  capacity law; setting `k = 2` recovers the parity ceiling `2ρ² ≤ 1 + γ`.  So the two
  previously separate catalog ceilings are the two boundary faces of one law.
* `capacity_forces_pair_correlation` — read contrapositively: any `k` statistics all
  reading `ρ` must contain a pair correlated at least `(kρ² - 1)/(k-1)`.
* `u64b_no_decorrelated_triple`, `u64b_triple_correlation_floor` — applied at the
  replicated reading `0.641`: no three statistics with pairwise correlation `≤ 0.1` can
  all read the dial level, and any three that do must share a pair correlated `≥ 0.116`.
* `capacity_realizable_equidistant`, `capacity_law_tight`, `u64b_triple_realizable` —
  **sharpness**: for every `k ≥ 1` and every `γ ∈ [0,1]` the equidistant family (Gram
  matrix `(1-γ)I + γJ`) read against its normalised sum vector attains the capacity bound
  with equality, so the law has no slack anywhere on the `(k, γ)` sheet; at the recorded
  cell, three statistics with pairwise correlation exactly `0.1163215` all read `0.641`.
* `capacity_extremal_forces_equidistant` — **rigidity of the extremisers**: the equidistant
  families of `capacity_realizable_equidistant` are the *only* extremisers.  If a
  `gamma`-family of `k ≥ 1` unit statistics all reading at least `rho ≥ 0` saturates the
  capacity bound `k·rho² = 1 + (k-1)γ`, then *every* off-diagonal Gram entry is exactly
  `γ`.  Extremality therefore has no free parameters left in the Gram matrix: the
  capacity sheet is realised on a single orbit.
* `median_rigidity` — the general order-statistic law: for a monotone record, if the
  entry just below the median split is at most the bar `τ` and the median is `M`, then
  *every* entry from the split upwards is at least `2M - τ`.
* `six_seed_median_rigidity` — instantiated: median `+0.058` with the third-smallest
  advantage at most the bar `+0.05` forces **every** bar-clearing seed to `≥ +0.066`,
  which is exactly the fresh cell's upper CI endpoint `advHigh`.
* `six_seed_bimodality_gap`, `six_seed_loser_budget`, `six_seed_top_lower_bound` — the
  record must be bimodal: a gap of at least `0.016` separates the third and fourth sorted
  advantages, the losing half carries at most `0.156` in total, and the top seed is at
  least `+0.068`.
* `six_seed_record_consistent` — an explicit labelled six-seed advantage record realising
  *simultaneously* every published summary statistic (six-seed mean `0.059`, fresh-triple
  mean `0.044`, `3/6` and `1/3` bar counts, sorted median `0.058`), together with the
  permutation that sorts it.  The published summary is therefore not self-contradictory,
  and all the rigidity theorems above are non-vacuous.

## Scientific payload

The median is a much stronger constraint than the mean: the mean only forces *some* seed
to `+0.086`, whereas the median forces *all three* winners to `+0.066` or better.  Both
bounds place at least one seed strictly outside the fresh cell's confidence interval, so
the "count parity" verdict is not a story about a uniformly weak advantage — it is a
story about a *bimodal* advantage distribution, half the seeds at or below the bar and
half well clear of it.  Under the capacity law that bimodality is exactly what a family
of mildly correlated statistics must look like once the dial drops below `1/√2`.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU64MedianCapacity

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialParityCapacity
open Catalog.Algebra.ZeroFitDialU64Replication

variable {n k : ℕ}

/-! ## 1. The interpolating capacity law -/

/-- A family of unit statistics whose pairwise correlations are bounded by `gamma`. -/
def IsGammaFamily (u : Fin k → (Fin n → ℝ)) (gamma : ℝ) : Prop :=
  (∀ i, dot (u i) (u i) = 1) ∧ ∀ i j, i ≠ j → dot (u i) (u j) ≤ gamma

/-- The square norm of the sum of a family expands as the total of its Gram matrix. -/
lemma dot_sum_self_eq (u : Fin k → (Fin n → ℝ)) :
    dot (fun x => ∑ i, (1 : ℝ) * u i x) (fun x => ∑ i, (1 : ℝ) * u i x)
      = ∑ i, ∑ j, dot (u i) (u j) := by
  rw [dot_sum_left]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [one_mul, dot_comm, dot_sum_left]
  exact Finset.sum_congr rfl fun j _ => by rw [one_mul, dot_comm]

/-- In `Fin k`, deleting one index from `univ` leaves `k - 1` indices. -/
lemma erase_univ_card (i : Fin k) :
    (((univ.erase i).card : ℝ)) = (k : ℝ) - 1 := by
  classical
  rw [Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin]
  have hk : 1 ≤ k := Nat.one_le_iff_ne_zero.mpr (by rintro rfl; exact i.elim0)
  push_cast [hk]
  ring

/-- Each Gram row of a `gamma`-family totals at most `1 + (k-1)γ`. -/
lemma gamma_family_row_le {u : Fin k → (Fin n → ℝ)} {gamma : ℝ}
    (hu : IsGammaFamily u gamma) (i : Fin k) :
    ∑ j, dot (u i) (u j) ≤ 1 + ((k : ℝ) - 1) * gamma := by
  classical
  have hsplit : ∑ j, dot (u i) (u j)
      = dot (u i) (u i) + ∑ j ∈ univ.erase i, dot (u i) (u j) := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
  have hoff : ∑ j ∈ univ.erase i, dot (u i) (u j)
      ≤ ((univ.erase i).card : ℝ) * gamma := by
    simpa using Finset.sum_le_card_nsmul (univ.erase i) (fun j => dot (u i) (u j)) gamma
      (fun j hj => hu.2 i j (Ne.symm (Finset.ne_of_mem_erase hj)))
  rw [erase_univ_card i] at hoff
  rw [hsplit, hu.1 i]
  linarith

/-- The square norm of the sum of a `gamma`-family is at most `k + k(k-1)γ`. -/
lemma dot_sum_sum_le {u : Fin k → (Fin n → ℝ)} {gamma : ℝ}
    (hu : IsGammaFamily u gamma) :
    dot (fun x => ∑ i, (1 : ℝ) * u i x) (fun x => ∑ i, (1 : ℝ) * u i x)
      ≤ (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma := by
  rw [dot_sum_self_eq]
  calc ∑ i, ∑ j, dot (u i) (u j) ≤ ∑ _i : Fin k, (1 + ((k : ℝ) - 1) * gamma) :=
        Finset.sum_le_sum fun i _ => gamma_family_row_le hu i
    _ = (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]; ring

/-- **The interpolating capacity law.**  If `k` unit statistics have pairwise correlations
at most `gamma` and each reads at least `rho ≥ 0` against a shared unit response, then
`k·rho² ≤ 1 + (k-1)·gamma`.  At `gamma = 0` this is the orthonormal capacity law
`k·rho² ≤ 1`; at `k = 2` it is the parity ceiling `2·rho² ≤ 1 + gamma`. -/
theorem correlated_family_capacity {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ} {gamma rho : ℝ}
    (hu : IsGammaFamily u gamma) (hw : dot w w = 1) (hrho : 0 ≤ rho) (hk : 1 ≤ k)
    (hread : ∀ i, rho ≤ dot (u i) w) :
    (k : ℝ) * rho ^ 2 ≤ 1 + ((k : ℝ) - 1) * gamma := by
  classical
  set S : Fin n → ℝ := fun x => ∑ i, (1 : ℝ) * u i x with hS
  have hSw : dot S w = ∑ i, dot (u i) w := by
    rw [hS, dot_sum_left]
    exact Finset.sum_congr rfl fun i _ => one_mul _
  have hlow : (k : ℝ) * rho ≤ dot S w := by
    rw [hSw]
    calc (k : ℝ) * rho = ∑ _i : Fin k, rho := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      _ ≤ ∑ i, dot (u i) w := Finset.sum_le_sum fun i _ => hread i
  have hcs : dot S w ^ 2 ≤ dot S S * dot w w := dot_sq_le S w
  have hSS : dot S S ≤ (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma := dot_sum_sum_le hu
  rw [hw, mul_one] at hcs
  have hkR : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hsq : ((k : ℝ) * rho) ^ 2 ≤ dot S w ^ 2 := by
    nlinarith [hlow, mul_nonneg hkR hrho]
  have hkey : ((k : ℝ) * rho) ^ 2 ≤ (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma := by
    linarith
  have hkpos' : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  nlinarith [hkey, hkpos']

/-- Orthonormal families are `0`-families, so the capacity law of
`Algebra.ZeroFitDialParityCapacity` is the `gamma = 0` face of `correlated_family_capacity`. -/
theorem capacity_law_recovers_orthonormal {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ}
    {rho : ℝ} (hu : IsOrthonormal u) (hw : dot w w = 1) (hrho : 0 ≤ rho) (hk : 1 ≤ k)
    (hread : ∀ i, rho ≤ dot (u i) w) :
    (k : ℝ) * rho ^ 2 ≤ 1 := by
  have hg : IsGammaFamily u 0 := ⟨hu.1, fun i j hij => le_of_eq (hu.2 i j hij)⟩
  have := correlated_family_capacity hg hw hrho hk hread
  linarith

/-- The `k = 2` face is the parity ceiling `2ρ² ≤ 1 + γ`. -/
theorem capacity_law_recovers_parity {u : Fin 2 → (Fin n → ℝ)} {w : Fin n → ℝ}
    {gamma rho : ℝ} (hu : IsGammaFamily u gamma) (hw : dot w w = 1) (hrho : 0 ≤ rho)
    (hread : ∀ i, rho ≤ dot (u i) w) :
    2 * rho ^ 2 ≤ 1 + gamma := by
  have := correlated_family_capacity hu hw hrho (by norm_num) hread
  norm_num at this
  linarith

/-- **Contrapositive form.**  Any `k ≥ 2` statistics all reading `rho` against a shared
response must contain a pair correlated at least `(k·rho² - 1)/(k-1)`. -/
theorem capacity_forces_pair_correlation {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ}
    {gamma rho : ℝ} (hu : IsGammaFamily u gamma) (hw : dot w w = 1) (hrho : 0 ≤ rho)
    (hk : 2 ≤ k) (hread : ∀ i, rho ≤ dot (u i) w) :
    ((k : ℝ) * rho ^ 2 - 1) / ((k : ℝ) - 1) ≤ gamma := by
  have hcap := correlated_family_capacity hu hw hrho (by omega) hread
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hpos : (0 : ℝ) < (k : ℝ) - 1 := by linarith
  rw [div_le_iff₀ hpos]
  linarith

/-- At the replicated dial level `0.641` no three statistics with pairwise correlation at
most `0.1` can all read the dial: the bitlen-64 cell has capacity two. -/
theorem u64b_no_decorrelated_triple {u : Fin 3 → (Fin n → ℝ)} {w : Fin n → ℝ}
    (hu : IsGammaFamily u (1 / 10)) (hw : dot w w = 1)
    (hread : ∀ i, (641 : ℝ) / 1000 ≤ dot (u i) w) : False := by
  have hcap := correlated_family_capacity hu hw (by norm_num) (by norm_num) hread
  norm_num at hcap

/-- Three statistics all reading the replicated dial level must share a pair correlated at
least `0.116`. -/
theorem u64b_triple_correlation_floor {u : Fin 3 → (Fin n → ℝ)} {w : Fin n → ℝ}
    {gamma : ℝ} (hu : IsGammaFamily u gamma) (hw : dot w w = 1)
    (hread : ∀ i, (641 : ℝ) / 1000 ≤ dot (u i) w) :
    (116 : ℝ) / 1000 ≤ gamma := by
  have h := capacity_forces_pair_correlation hu hw (by norm_num) (by norm_num) hread
  norm_num at h
  linarith

/-! ### Sharpness of the interpolating capacity law

The bound `k·ρ² ≤ 1 + (k-1)γ` is attained on the whole `(k, γ)` sheet, not merely at the
two faces `γ = 0` and `k = 2`.  The realiser is the *equidistant* family with Gram matrix
`(1-γ)I + γJ`, read against its own normalised sum vector. -/

/-- **Sharpness of the capacity law.**  For every `k ≥ 1` and every `gamma ∈ [0,1]` there
is an explicit family of `k` unit statistics in dimension `k+1` with *all* pairwise
correlations equal to `gamma`, and a unit response against which every reading equals
`rho = √((1+(k-1)γ)/k)` — the exact value making `correlated_family_capacity` an
equality. -/
theorem capacity_realizable_equidistant {gamma : ℝ} (hg0 : 0 ≤ gamma) (hg1 : gamma ≤ 1)
    (hk : 1 ≤ k) :
    ∃ (u : Fin k → (Fin (k + 1) → ℝ)) (w : Fin (k + 1) → ℝ),
      (∀ i, dot (u i) (u i) = 1) ∧ (∀ i j, i ≠ j → dot (u i) (u j) = gamma) ∧
        dot w w = 1 ∧
        (∀ i, dot (u i) w = Real.sqrt ((1 + ((k : ℝ) - 1) * gamma) / k)) ∧
        (k : ℝ) * Real.sqrt ((1 + ((k : ℝ) - 1) * gamma) / k) ^ 2
          = 1 + ((k : ℝ) - 1) * gamma := by
  classical
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  have hnumpos : (0 : ℝ) < 1 + ((k : ℝ) - 1) * gamma := by nlinarith
  set rho : ℝ := Real.sqrt ((1 + ((k : ℝ) - 1) * gamma) / k) with hrhodef
  have hrho2 : rho ^ 2 = (1 + ((k : ℝ) - 1) * gamma) / k :=
    Real.sq_sqrt (by positivity)
  have hrhopos : 0 < rho := Real.sqrt_pos.mpr (by positivity)
  set a : ℝ := Real.sqrt (1 - gamma) with hadef
  set b : ℝ := Real.sqrt gamma with hbdef
  have ha2 : a ^ 2 = 1 - gamma := Real.sq_sqrt (by linarith)
  have hb2 : b ^ 2 = gamma := Real.sq_sqrt hg0
  set uv : Fin k → (Fin (k + 1) → ℝ) :=
    fun i x => if x = i.castSucc then a else if x = Fin.last k then b else 0 with huvdef
  set wv : Fin (k + 1) → ℝ :=
    fun x => if x = Fin.last k then b / rho else a / ((k : ℝ) * rho) with hwvdef
  have hcast : ∀ x : Fin k, (x.castSucc : Fin (k + 1)) ≠ Fin.last k :=
    fun x => (Fin.castSucc_lt_last x).ne
  have hu_cast : ∀ i x : Fin k, uv i x.castSucc = if x = i then a else 0 := by
    intro i x
    by_cases h : x = i
    · subst h; simp [huvdef]
    · have hne : (x.castSucc : Fin (k + 1)) ≠ i.castSucc := fun hh =>
        h (Fin.castSucc_injective _ hh)
      simp [huvdef, hne, hcast x, h]
  have hu_last : ∀ i : Fin k, uv i (Fin.last k) = b := by
    intro i
    simp [huvdef, Ne.symm (hcast i)]
  have hw_cast : ∀ x : Fin k, wv x.castSucc = a / ((k : ℝ) * rho) := by
    intro x; simp [hwvdef, hcast x]
  have hw_last : wv (Fin.last k) = b / rho := by simp [hwvdef]
  have hdot_uu : ∀ i, dot (uv i) (uv i) = 1 := by
    intro i
    rw [dot, Fin.sum_univ_castSucc]
    have h1 : ∀ x : Fin k, uv i x.castSucc * uv i x.castSucc = if x = i then a * a else 0 := by
      intro x; rw [hu_cast]; by_cases h : x = i <;> simp [h]
    rw [Finset.sum_congr rfl fun x _ => h1 x, Finset.sum_ite_eq' univ i fun _ => a * a,
      hu_last i]
    simp only [Finset.mem_univ, if_true]
    nlinarith [ha2, hb2]
  have hdot_uv : ∀ i j : Fin k, i ≠ j → dot (uv i) (uv j) = gamma := by
    intro i j hij
    rw [dot, Fin.sum_univ_castSucc]
    have h1 : ∀ x : Fin k, uv i x.castSucc * uv j x.castSucc = 0 := by
      intro x
      rw [hu_cast, hu_cast]
      by_cases h : x = i
      · subst h; simp [hij]
      · simp [h]
    rw [Finset.sum_congr rfl fun x _ => h1 x, hu_last i, hu_last j]
    simp [← pow_two, hb2]
  have hkey : a ^ 2 + (k : ℝ) * b ^ 2 = (k : ℝ) * rho ^ 2 := by
    rw [ha2, hb2, hrho2]; field_simp; ring
  have hdot_ww : dot wv wv = 1 := by
    rw [dot, Fin.sum_univ_castSucc]
    have h1 : ∀ x : Fin k, wv x.castSucc * wv x.castSucc
        = a / ((k : ℝ) * rho) * (a / ((k : ℝ) * rho)) := by
      intro x; rw [hw_cast]
    rw [Finset.sum_congr rfl fun x _ => h1 x, hw_last, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    field_simp
    linarith [hkey]
  have hdot_uw : ∀ i, dot (uv i) wv = rho := by
    intro i
    rw [dot, Fin.sum_univ_castSucc]
    have h1 : ∀ x : Fin k, uv i x.castSucc * wv x.castSucc
        = if x = i then a * (a / ((k : ℝ) * rho)) else 0 := by
      intro x; rw [hu_cast, hw_cast]; by_cases h : x = i <;> simp [h]
    rw [Finset.sum_congr rfl fun x _ => h1 x,
      Finset.sum_ite_eq' univ i fun _ => a * (a / ((k : ℝ) * rho)), hu_last i, hw_last]
    simp only [Finset.mem_univ, if_true]
    field_simp
    linarith [hkey]
  refine ⟨uv, wv, hdot_uu, hdot_uv, hdot_ww, fun i => hdot_uw i, ?_⟩
  rw [hrho2]
  field_simp

/-- The equidistant realiser turns `correlated_family_capacity` into an equality, so the
law has no slack anywhere on the `(k, gamma)` sheet. -/
theorem capacity_law_tight {gamma : ℝ} (hg0 : 0 ≤ gamma) (hg1 : gamma ≤ 1) (hk : 1 ≤ k) :
    ∃ (u : Fin k → (Fin (k + 1) → ℝ)) (w : Fin (k + 1) → ℝ) (rho : ℝ),
      IsGammaFamily u gamma ∧ dot w w = 1 ∧ 0 ≤ rho ∧ (∀ i, rho ≤ dot (u i) w) ∧
        (k : ℝ) * rho ^ 2 = 1 + ((k : ℝ) - 1) * gamma := by
  obtain ⟨u, w, h1, h2, h3, h4, h5⟩ := capacity_realizable_equidistant hg0 hg1 hk
  exact ⟨u, w, Real.sqrt ((1 + ((k : ℝ) - 1) * gamma) / k),
    ⟨h1, fun i j hij => le_of_eq (h2 i j hij)⟩, h3, Real.sqrt_nonneg _,
    fun i => le_of_eq (h4 i).symm, h5⟩

/-- **Capacity three at bitlen 64 is exactly realisable.**  Three statistics with pairwise
correlation exactly `0.1163215` all read the replicated dial value `0.641`, matching the
floor of `u64b_triple_correlation_floor`: that floor is attained, not merely a bound. -/
theorem u64b_triple_realizable :
    ∃ (u : Fin 3 → (Fin 4 → ℝ)) (w : Fin 4 → ℝ),
      (∀ i, dot (u i) (u i) = 1) ∧
        (∀ i j, i ≠ j → dot (u i) (u j) = 232643 / 2000000) ∧
        dot w w = 1 ∧ (∀ i, dot (u i) w = (641 : ℝ) / 1000) := by
  obtain ⟨u, w, h1, h2, h3, h4, -⟩ :=
    capacity_realizable_equidistant (k := 3) (gamma := 232643 / 2000000) (by norm_num)
      (by norm_num) (by norm_num)
  refine ⟨u, w, h1, h2, h3, fun i => ?_⟩
  have h := h4 i
  rw [show (1 + (((3 : ℕ) : ℝ) - 1) * (232643 / 2000000)) / ((3 : ℕ) : ℝ)
      = ((641 : ℝ) / 1000) ^ 2 by norm_num, Real.sqrt_sq (by norm_num)] at h
  exact h

/-! ### Rigidity of the extremisers

The realiser above is essentially the *only* configuration attaining the capacity bound. -/

/-- If every term of a finite sum is at most `c` and the total equals `card · c`, every
term equals `c`. -/
lemma eq_of_sum_saturates {ι : Type*} (s : Finset ι) (f : ι → ℝ) (c : ℝ)
    (hle : ∀ i ∈ s, f i ≤ c) (hsum : ∑ i ∈ s, f i = (s.card : ℝ) * c) :
    ∀ i ∈ s, f i = c := by
  classical
  intro i hi
  by_contra hne
  have hlt : f i < c := lt_of_le_of_ne (hle i hi) hne
  have hstrict : ∑ j ∈ s, f j < ∑ _j ∈ s, c :=
    Finset.sum_lt_sum hle ⟨i, hi, hlt⟩
  rw [Finset.sum_const, nsmul_eq_mul, hsum] at hstrict
  exact lt_irrefl _ hstrict

/-- **Extremal families are equidistant.**  If `k` unit statistics with pairwise
correlations at most `gamma` all read at least `rho ≥ 0` against a unit response and the
capacity bound is *saturated* (`k·rho² = 1 + (k-1)gamma`), then every pairwise correlation
is exactly `gamma`: the equidistant realiser of `capacity_realizable_equidistant` is the
only Gram configuration compatible with equality. -/
theorem capacity_extremal_forces_equidistant {u : Fin k → (Fin n → ℝ)} {w : Fin n → ℝ}
    {gamma rho : ℝ} (hu : IsGammaFamily u gamma) (hw : dot w w = 1) (hrho : 0 ≤ rho)
    (hk : 1 ≤ k) (hread : ∀ i, rho ≤ dot (u i) w)
    (hextremal : (k : ℝ) * rho ^ 2 = 1 + ((k : ℝ) - 1) * gamma) :
    ∀ i j, i ≠ j → dot (u i) (u j) = gamma := by
  classical
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  set S : Fin n → ℝ := fun x => ∑ i, (1 : ℝ) * u i x with hS
  have hSw : dot S w = ∑ i, dot (u i) w := by
    rw [hS, dot_sum_left]
    exact Finset.sum_congr rfl fun i _ => one_mul _
  have hlow : (k : ℝ) * rho ≤ dot S w := by
    rw [hSw]
    calc (k : ℝ) * rho = ∑ _i : Fin k, rho := by
          rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      _ ≤ ∑ i, dot (u i) w := Finset.sum_le_sum fun i _ => hread i
  have hcs : dot S w ^ 2 ≤ dot S S * dot w w := dot_sq_le S w
  rw [hw, mul_one] at hcs
  have hSS_le : dot S S ≤ (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma := dot_sum_sum_le hu
  have hsq : ((k : ℝ) * rho) ^ 2 ≤ dot S w ^ 2 := by
    nlinarith [hlow, mul_nonneg (le_of_lt hkpos) hrho]
  have hbig : ((k : ℝ) * rho) ^ 2 = (k : ℝ) * ((k : ℝ) * rho ^ 2) := by ring
  have hSS_ge : (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma ≤ dot S S := by
    have h1 : ((k : ℝ) * rho) ^ 2 = (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma := by
      rw [hbig, hextremal]; ring
    linarith [hsq, hcs, h1]
  have hSS : dot S S = (k : ℝ) + (k : ℝ) * ((k : ℝ) - 1) * gamma := le_antisymm hSS_le hSS_ge
  -- the row totals must all saturate
  have hrows : ∑ i, (∑ j, dot (u i) (u j)) = ((univ : Finset (Fin k)).card : ℝ)
      * (1 + ((k : ℝ) - 1) * gamma) := by
    rw [Finset.card_univ, Fintype.card_fin, ← dot_sum_self_eq u, ← hS, hSS]; ring
  have hrow_eq : ∀ i ∈ (univ : Finset (Fin k)),
      (∑ j, dot (u i) (u j)) = 1 + ((k : ℝ) - 1) * gamma :=
    eq_of_sum_saturates univ (fun i => ∑ j, dot (u i) (u j)) (1 + ((k : ℝ) - 1) * gamma)
      (fun i _ => gamma_family_row_le hu i) hrows
  -- inside a saturated row, every off-diagonal entry saturates
  intro i j hij
  have hsplit : ∑ j', dot (u i) (u j')
      = dot (u i) (u i) + ∑ j' ∈ univ.erase i, dot (u i) (u j') := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
  have hoffsum : ∑ j' ∈ univ.erase i, dot (u i) (u j')
      = (((univ.erase i).card : ℝ)) * gamma := by
    rw [erase_univ_card i]
    have := hrow_eq i (Finset.mem_univ i)
    rw [hsplit, hu.1 i] at this
    linarith
  have := eq_of_sum_saturates (univ.erase i) (fun j' => dot (u i) (u j')) gamma
    (fun j' hj' => hu.2 i j' (Ne.symm (Finset.ne_of_mem_erase hj'))) hoffsum
  exact this j (Finset.mem_erase.mpr ⟨Ne.symm hij, Finset.mem_univ j⟩)

/-! ## 2. Median rigidity -/

/-- **The median rigidity law.**  In a monotone record, if the entry `a p` immediately
below the median split is at most the bar `tau` and the median of the two central entries
is `med`, then every entry from the split upwards is at least `2·med - tau`. -/
theorem median_rigidity {m : ℕ} (a : Fin m → ℚ) (hmono : Monotone a) (p q : Fin m)
    (tau med : ℚ) (hlow : a p ≤ tau) (hmed : (a p + a q) / 2 = med) :
    ∀ i, q ≤ i → 2 * med - tau ≤ a i := by
  intro i hi
  have hq : 2 * med - tau ≤ a q := by
    have : a q = 2 * med - a p := by linarith [hmed]
    rw [this]; linarith
  exact le_trans hq (hmono hi)

/-- **Six-seed median rigidity.**  The reported median `+0.058`, together with the third
smallest advantage sitting at or below the `+0.05` bar (which is what `3/6 above` means),
forces *every* bar-clearing seed to an advantage of at least `+0.066` — precisely the
fresh cell's upper CI endpoint.  The mean alone (cycle 1) only constrained one seed. -/
theorem six_seed_median_rigidity (a : Fin 6 → ℚ) (hmono : Monotone a)
    (hthird : a 2 ≤ bar) (hmed : (a 2 + a 3) / 2 = advMedian6) :
    ∀ i : Fin 6, (3 : Fin 6) ≤ i → advHigh ≤ a i := by
  intro i hi
  have h := median_rigidity a hmono 2 3 bar advMedian6 hthird hmed i hi
  have hval : 2 * advMedian6 - bar = advHigh := by
    norm_num [advMedian6, bar, advHigh]
  linarith [hval ▸ h]

/-- The three bar-clearing seeds together carry at least `3·0.066 = 0.198` of advantage,
so the three losing seeds carry at most `0.156` in total. -/
theorem six_seed_loser_budget (a : Fin 6 → ℚ) (hmono : Monotone a)
    (hthird : a 2 ≤ bar) (hmed : (a 2 + a 3) / 2 = advMedian6)
    (hsum : ∑ i, a i = 6 * advMean6) :
    a 0 + a 1 + a 2 ≤ 156 / 1000 := by
  have h3 := six_seed_median_rigidity a hmono hthird hmed 3 (by decide)
  have h4 := six_seed_median_rigidity a hmono hthird hmed 4 (by decide)
  have h5 := six_seed_median_rigidity a hmono hthird hmed 5 (by decide)
  have hexp : ∑ i, a i = a 0 + a 1 + a 2 + a 3 + a 4 + a 5 := by
    simp [Fin.sum_univ_six]
  rw [hexp, advMean6] at hsum
  rw [advHigh] at h3 h4 h5
  linarith

/-- **Quantified bimodality.**  Median rigidity opens a gap of at least `0.016` between
the third and fourth sorted advantages: the count-parity record cannot be flat, it must
split into a losing half at or below the bar and a winning half at or above `0.066`. -/
theorem six_seed_bimodality_gap (a : Fin 6 → ℚ) (hmono : Monotone a)
    (hthird : a 2 ≤ bar) (hmed : (a 2 + a 3) / 2 = advMedian6) :
    16 / 1000 ≤ a 3 - a 2 := by
  have h3 := six_seed_median_rigidity a hmono hthird hmed 3 (by decide)
  rw [advHigh] at h3
  rw [bar] at hthird
  linarith

/-- Together with the mean, the sorted record's top seed is at least `+0.068`. -/
theorem six_seed_top_lower_bound (a : Fin 6 → ℚ) (hmono : Monotone a)
    (hsum : ∑ i, a i = 6 * advMean6) (hbelow : ∀ i : Fin 6, i ≤ 2 → a i ≤ bar) :
    68 / 1000 ≤ a 5 := by
  have h35 : a 3 ≤ a 5 := hmono (by decide)
  have h45 : a 4 ≤ a 5 := hmono (by decide)
  have hb0 := hbelow 0 (by decide)
  have hb1 := hbelow 1 (by decide)
  have hb2 := hbelow 2 (by decide)
  have hexp : ∑ i, a i = a 0 + a 1 + a 2 + a 3 + a 4 + a 5 := by
    simp [Fin.sum_univ_six]
  rw [hexp, advMean6] at hsum
  rw [bar] at hb0 hb1 hb2
  linarith

/-! ## 3. Consistency of the published summary

Every rigidity theorem above is conditional on the published summary statistics.  A
Critic-stage obligation is to check that those statistics can all hold at once. -/

/-- The explicit six-seed advantage record used as the consistency witness, in the
published seed order (legacy seeds `0,1,2`, fresh seeds `3,4,5`). -/
def witness : Fin 6 → ℚ := ![16 / 1000, 100 / 1000, 106 / 1000, 16 / 1000, 50 / 1000,
  66 / 1000]

/-- The permutation sorting `witness` into monotone order. -/
def sortPerm : Equiv.Perm (Fin 6) where
  toFun := ![0, 3, 4, 5, 1, 2]
  invFun := ![0, 4, 5, 1, 2, 3]
  left_inv := by decide
  right_inv := by decide

/-- **The published summary is consistent.**  The witness record simultaneously realises
the six-seed mean `+0.059`, the fresh-triple mean `+0.044`, the `3/6` and `1/3` bar counts
and (after sorting) the median `+0.058`; and it satisfies the cycle-1 conclusion that some
legacy seed carries at least `+0.086`. -/
theorem six_seed_record_consistent :
    (∑ i, witness i = 6 * advMean6) ∧
    (∑ i ∈ fresh, witness i = 3 * adv64b) ∧
    ((univ.filter (fun i => bar < witness i)).card = 3) ∧
    ((fresh.filter (fun i => bar < witness i)).card = 1) ∧
    Monotone (witness ∘ sortPerm) ∧
    ((witness (sortPerm 2) + witness (sortPerm 3)) / 2 = advMedian6) ∧
    (∃ i ∈ legacy, (86 : ℚ) / 1000 ≤ witness i) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [witness, Fin.sum_univ_six, advMean6]; norm_num
  · simp [witness, fresh, adv64b]; norm_num
  · have h : (univ.filter (fun i => bar < witness i)) = ({1, 2, 5} : Finset (Fin 6)) := by
      ext i; fin_cases i <;> simp [bar, witness] <;> norm_num
    rw [h]; decide
  · have h : (fresh.filter (fun i => bar < witness i)) = ({5} : Finset (Fin 6)) := by
      ext i; fin_cases i <;> simp [bar, fresh, witness] <;> norm_num
    rw [h]; decide
  · rw [Fin.monotone_iff_le_succ]
    intro i
    fin_cases i <;> simp [witness, sortPerm] <;> norm_num
  · simp [witness, sortPerm, advMedian6]; norm_num
  · refine ⟨2, by decide, ?_⟩
    show (86 : ℚ) / 1000 ≤ 106 / 1000
    norm_num

/-- The witness also satisfies median rigidity: its three bar-clearing seeds all sit at
`+0.066` or better, confirming `six_seed_median_rigidity` is not vacuous. -/
theorem witness_winners_above_fresh_ci :
    ∀ i : Fin 6, bar < witness i → advHigh ≤ witness i := by
  intro i hi
  fin_cases i <;> revert hi <;> simp [witness, bar, advHigh] <;> norm_num

end Catalog.Algebra.ZeroFitDialU64MedianCapacity