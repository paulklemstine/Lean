/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# From dyadic density to natural density

`DescentTheorem.lean` proves that, at each 2-adic scale `k`, the *residue
classes* mod `2^k` on which the `k`-step accelerated Collatz map descends have
density at least `1 − 1/(4δ²k)`.

This file converts that into a statement about honest integers counted by size:
for every `ε > 0` there is a scale `k` such that, for all large `N`, the
proportion of `n ≤ N` failing `T^[k] n < n` is below `ε`.

The counting is elementary but must be done carefully: each residue class mod
`2^k` meets `[1,N]` in at most `N/2^k + 1` points, and the finitely many `n`
below the descent threshold `2^k·4^k` contribute `O_k(1)`.

## Main results

* `card_residue_class_le` — a residue class mod `2^k` meets `[1,N]` at most
  `N/2^k + 1` times.
* `card_nondescending_le` — the master counting bound.
* `nondescending_density_bound` — real-valued density bound at scale `k`.
* `exists_scale_nondescending_density_lt` — for every `ε > 0` some scale `k`
  makes the natural density of non-descending integers eventually `< ε`.
-/

import Mathlib
import MachineLearning.CollatzSpectral.DescentTheorem

open Finset Filter

namespace CollatzParity

/-- Integers in `[1,N]` that do **not** descend after `k` accelerated steps. -/
def nondescending (k N : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun n => ¬ (T^[k] n < n))

/-! ## §1. Counting a residue class -/

/-- A single residue class mod `2^k` meets `[1,N]` in at most `N/2^k + 1`
points. -/
theorem card_residue_class_le (k N r : ℕ) :
    ((Finset.Icc 1 N).filter (fun n => n % 2 ^ k = r)).card ≤ N / 2 ^ k + 1 := by
  have hpow : 0 < 2 ^ k := by positivity
  have : ((Finset.Icc 1 N).filter (fun n => n % 2 ^ k = r)).card
      ≤ (Finset.range (N / 2 ^ k + 1)).card := by
    apply Finset.card_le_card_of_injOn (fun n => n / 2 ^ k)
    · intro n hn
      simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_Icc] at hn
      have hdiv := Nat.div_le_div_right (c := 2 ^ k) hn.1.2
      simp only [Finset.coe_range, Set.mem_Iio]
      omega
    · intro a ha b hb hab
      simp only [Finset.mem_coe, Finset.mem_filter] at ha hb
      have hab' : a / 2 ^ k = b / 2 ^ k := hab
      have h1 : a % 2 ^ k + 2 ^ k * (a / 2 ^ k) = a := Nat.mod_add_div a (2 ^ k)
      have h2 : b % 2 ^ k + 2 ^ k * (b / 2 ^ k) = b := Nat.mod_add_div b (2 ^ k)
      rw [ha.2] at h1
      rw [hb.2] at h2
      rw [hab'] at h1
      omega
  simpa using this

/-- The integers in `[1,N]` whose residue lies in a given finset `S` of residues
number at most `S.card · (N/2^k + 1)`. -/
theorem card_residues_in_le (k N : ℕ) (S : Finset ℕ) :
    ((Finset.Icc 1 N).filter (fun n => n % 2 ^ k ∈ S)).card ≤ S.card * (N / 2 ^ k + 1) := by
  have hEq : (Finset.Icc 1 N).filter (fun n => n % 2 ^ k ∈ S)
      = S.biUnion (fun r => (Finset.Icc 1 N).filter (fun n => n % 2 ^ k = r)) := by
    ext n
    simp only [Finset.mem_filter, Finset.mem_biUnion]
    constructor
    · rintro ⟨hn, hmem⟩
      exact ⟨n % 2 ^ k, hmem, hn, rfl⟩
    · rintro ⟨r, hr, hn, hnr⟩
      exact ⟨hn, hnr ▸ hr⟩
  rw [hEq]
  calc (S.biUnion (fun r => (Finset.Icc 1 N).filter (fun n => n % 2 ^ k = r))).card
      ≤ ∑ r ∈ S, ((Finset.Icc 1 N).filter (fun n => n % 2 ^ k = r)).card :=
        Finset.card_biUnion_le
    _ ≤ ∑ _r ∈ S, (N / 2 ^ k + 1) :=
        Finset.sum_le_sum (fun r _ => card_residue_class_le k N r)
    _ = S.card * (N / 2 ^ k + 1) := by rw [Finset.sum_const, smul_eq_mul]

/-! ## §2. The master counting bound -/

/-- Every non-descending integer either lies in a non-contracting residue class
or lies below the explicit threshold `2^k·4^k`. -/
theorem nondescending_subset (k N : ℕ) :
    nondescending k N ⊆
      ((Finset.Icc 1 N).filter (fun n => n % 2 ^ k ∈ noncontracting k))
        ∪ Finset.Icc 1 (2 ^ k * 4 ^ k) := by
  intro n hn
  rw [nondescending, Finset.mem_filter, Finset.mem_Icc] at hn
  obtain ⟨⟨hn1, hnN⟩, hnd⟩ := hn
  by_cases hmem : n % 2 ^ k ∈ noncontracting k
  · exact Finset.mem_union_left _ (Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨hn1, hnN⟩, hmem⟩)
  · refine Finset.mem_union_right _ (Finset.mem_Icc.mpr ⟨hn1, ?_⟩)
    by_contra hlarge
    push_neg at hlarge
    have hpow : 0 < 2 ^ k := by positivity
    have hmemd : n % 2 ^ k ∈ descending k := by
      rw [descending, Finset.mem_sdiff]
      exact ⟨Finset.mem_range.mpr (Nat.mod_lt _ hpow), hmem⟩
    exact hnd (mem_descending_descent k (n % 2 ^ k) hmemd n rfl (le_of_lt hlarge))

/-- **Master counting bound.** -/
theorem card_nondescending_le (k N : ℕ) :
    (nondescending k N).card
      ≤ (noncontracting k).card * (N / 2 ^ k + 1) + 2 ^ k * 4 ^ k := by
  calc (nondescending k N).card
      ≤ (((Finset.Icc 1 N).filter (fun n => n % 2 ^ k ∈ noncontracting k))
          ∪ Finset.Icc 1 (2 ^ k * 4 ^ k)).card :=
        Finset.card_le_card (nondescending_subset k N)
    _ ≤ ((Finset.Icc 1 N).filter (fun n => n % 2 ^ k ∈ noncontracting k)).card
          + (Finset.Icc 1 (2 ^ k * 4 ^ k)).card := Finset.card_union_le _ _
    _ ≤ (noncontracting k).card * (N / 2 ^ k + 1) + 2 ^ k * 4 ^ k := by
        have h1 := card_residues_in_le k N (noncontracting k)
        have h2 : (Finset.Icc 1 (2 ^ k * 4 ^ k)).card ≤ 2 ^ k * 4 ^ k := by
          rw [Nat.card_Icc]; omega
        omega

/-! ## §3. Density form -/

/-- **General density bound at scale `k`.** For `N ≥ 1`, the proportion of
`n ≤ N` failing to descend in `k` accelerated steps is at most the dyadic
non-contracting density plus an `O_k(1/N)` boundary term. -/
theorem nondescending_density_bound_general (k N : ℕ) (hN : 0 < N) :
    ((nondescending k N).card : ℝ) / N
      ≤ ((noncontracting k).card : ℝ) / 2 ^ k
        + (((noncontracting k).card : ℝ) + 2 ^ k * 4 ^ k) / N := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have hcard := card_nondescending_le k N
  have hcardR : ((nondescending k N).card : ℝ)
      ≤ ((noncontracting k).card : ℝ) * ((N : ℝ) / 2 ^ k + 1) + 2 ^ k * 4 ^ k := by
    have h1 : (((nondescending k N).card : ℕ) : ℝ)
        ≤ (((noncontracting k).card * (N / 2 ^ k + 1) + 2 ^ k * 4 ^ k : ℕ) : ℝ) := by
      exact_mod_cast hcard
    have h2 : (((N / 2 ^ k : ℕ)) : ℝ) ≤ (N : ℝ) / 2 ^ k := by
      have := Nat.cast_div_le (α := ℝ) (m := N) (n := 2 ^ k)
      simpa using this
    push_cast at h1
    nlinarith [Nat.cast_nonneg (α := ℝ) (noncontracting k).card]
  rw [div_le_iff₀ hNR]
  have hexpand : (((noncontracting k).card : ℝ) / 2 ^ k
      + (((noncontracting k).card : ℝ) + 2 ^ k * 4 ^ k) / N) * N
      = ((noncontracting k).card : ℝ) * ((N : ℝ) / 2 ^ k + 1) + 2 ^ k * 4 ^ k := by
    field_simp
    ring
  rw [hexpand]
  exact hcardR

/-- **Density bound at scale `k` via Chebyshev.** For `N ≥ 1`, the proportion of
`n ≤ N` that fail to descend in `k` accelerated steps is at most
`1/(4δ²k) + ((noncontracting k).card + 8^k)/N`. -/
theorem nondescending_density_bound (k N : ℕ) (hk : 0 < k) (hN : 0 < N) :
    ((nondescending k N).card : ℝ) / N
      ≤ 1 / (4 * spectralMargin ^ 2 * k) + (((noncontracting k).card : ℝ) + 2 ^ k * 4 ^ k) / N := by
  have h := nondescending_density_bound_general k N hN
  have hdens := noncontracting_density_le k hk
  linarith

/-- **Natural density of non-descending integers is arbitrarily small.**
For every `ε > 0` there is a 2-adic scale `k` such that, for all sufficiently
large `N`, fewer than an `ε`-fraction of the integers `n ≤ N` fail to decrease
after `k` accelerated Collatz steps.

This is the integer-counting form of the spectral density theorem: the exact
Fourier cancellation on `ℤ/2^k` propagates all the way to natural density. -/
theorem exists_scale_nondescending_density_lt (ε : ℝ) (hε : 0 < ε) :
    ∃ k : ℕ, 0 < k ∧ ∀ᶠ N in atTop, ((nondescending k N).card : ℝ) / N < ε := by
  have hd : (0 : ℝ) < spectralMargin := spectralMargin_pos
  obtain ⟨k, hk0, hk⟩ : ∃ k : ℕ, 0 < k ∧ 1 / (4 * spectralMargin ^ 2 * k) < ε / 2 := by
    obtain ⟨k, hk⟩ := exists_nat_gt (1 / (4 * spectralMargin ^ 2 * (ε / 2)))
    refine ⟨k + 1, Nat.succ_pos k, ?_⟩
    have hkpos : (0 : ℝ) < ((k : ℝ) + 1) := by positivity
    have hkgt : 1 / (4 * spectralMargin ^ 2 * (ε / 2)) < (k : ℝ) + 1 := by linarith
    rw [div_lt_iff₀ (by positivity)]
    rw [div_lt_iff₀ (by positivity)] at hkgt
    push_cast
    nlinarith [hkgt, hε, sq_nonneg spectralMargin]
  refine ⟨k, hk0, ?_⟩
  set C : ℝ := ((noncontracting k).card : ℝ) + 2 ^ k * 4 ^ k with hC
  have hCpos : 0 < C := by
    have : (0 : ℝ) ≤ ((noncontracting k).card : ℝ) := Nat.cast_nonneg _
    have h2 : (0 : ℝ) < 2 ^ k * 4 ^ k := by positivity
    linarith
  obtain ⟨N₀, hN₀⟩ := exists_nat_gt (C / (ε / 2))
  filter_upwards [eventually_ge_atTop (max N₀ 1)] with N hN
  have hN1 : 0 < N := lt_of_lt_of_le Nat.one_pos (le_trans (le_max_right N₀ 1) hN)
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN1
  have hNbig : C / (ε / 2) < (N : ℝ) := by
    have : (N₀ : ℝ) ≤ (N : ℝ) := by
      exact_mod_cast le_trans (le_max_left N₀ 1) hN
    linarith
  have hCN : C / N < ε / 2 := by
    rw [div_lt_iff₀ hNR]
    rw [div_lt_iff₀ (by positivity)] at hNbig
    linarith
  have := nondescending_density_bound k N hk0 hN1
  rw [← hC] at this
  linarith

end CollatzParity