/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certification at every 2-adic scale: the workload of an honest certificate

`CertifiedEvidence.Collatz` certifies `[1,4000]` after examining only the inputs
`n ≡ 3 (mod 4)`.  That sieve was hand-built.  This file shows it is the scale-2
member of a family indexed by the 2-adic scale `k`, and — using the spectral
density theory already in `MachineLearning.CollatzSpectral` — that the family's
workload density tends to **zero**.

## Main results

* `sieve_scale` — **soundness of the scale-`k` sieve**: to certify all of `[1,B]`
  it suffices to certify the inputs that fail to descend within `k` accelerated
  steps, i.e. the finset `nondescending k B` of
  `MachineLearning.CollatzSpectral.NaturalDensity`.  No threshold hypothesis is
  needed: the non-descending set already absorbs the small exceptional inputs.
* `mem_noncontracting_iff` — the real-analytic definition of a non-contracting
  residue class is equivalent to the purely arithmetic `2^k ≤ 3^{s_k(r)}`.
* `noncontracting_two` — at scale `2` the only non-contracting class is `3`:
  the hand-built mod-4 sieve of `CertifiedEvidence.Collatz` *is* the scale-2
  sieve, and `nondescending_two_subset` makes the comparison precise.
* `not_descends_two_of_mod4_three`, `nondescending_two_eq`,
  `card_nondescending_two` — **optimality at scale 2**: the two-step map sends
  `4m+3` to `9m+8`, so no input `≡ 3 (mod 4)` ever descends; the workload of the
  scale-2 sieve on `[1,B]` is exactly `{1,2} ∪ {n ≤ B : n ≡ 3 (mod 4)}`, of size
  `(B+1)/4 + 2`. No residue-based sieve at this scale can do better.
* `sieve_workload_le` — an explicit bound on the number of inputs the scale-`k`
  sieve must actually examine.
* `exists_scale_certification_cost_lt` — **vanishing amortized cost**: for every
  `ε > 0` there is a scale `k` such that, for all large `B`, the scale-`k` sieve
  certifies `[1,B]` from fewer than `ε·B` examined inputs.  Certified
  computation of Collatz evidence is therefore sublinear in a precise,
  fully proved sense — while, by
  `CertifiedEvidence.collatz_evidence_is_not_a_proof`, still never a proof.
-/

import Mathlib
import MachineLearning.CertifiedEvidence.Collatz
import MachineLearning.CollatzSpectral.NaturalDensity

namespace CertifiedEvidence

open CollatzParity Filter

/-! ## §1. Membership in the non-descending set -/

theorem mem_nondescending_iff (k B n : ℕ) :
    n ∈ nondescending k B ↔ 1 ≤ n ∧ n ≤ B ∧ ¬ (T^[k] n < n) := by
  rw [nondescending, Finset.mem_filter, Finset.mem_Icc]
  tauto

/-! ## §2. Soundness of the scale-`k` sieve -/

/-- **The scale-`k` sieve.** Certifying the non-descending inputs of `[1,B]`
certifies the whole interval: every other input drops below itself in `k`
accelerated steps and is handled by the induction. -/
theorem sieve_scale (k B : ℕ) (h : ∀ n ∈ nondescending k B, ReachesOne n) :
    ∀ n, 1 ≤ n → n ≤ B → ReachesOne n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      intro hn hnB
      by_cases hmem : n ∈ nondescending k B
      · exact h n hmem
      · rw [mem_nondescending_iff] at hmem
        push_neg at hmem
        have hdesc : T^[k] n < n := hmem hn hnB
        exact reachesOne_of_iterate
          (ih (T^[k] n) hdesc (one_le_iterate_T k n hn) (le_trans hdesc.le hnB))

/-! ## §3. The arithmetic face of a non-contracting class -/

/-- A residue class is non-contracting exactly when its odd-step count `s`
satisfies `2^k ≤ 3^s` — the real-analytic definition in terms of
`contractionExp` collapses to this integer inequality. -/
theorem mem_noncontracting_iff (k r : ℕ) :
    r ∈ noncontracting k ↔ r < 2 ^ k ∧ 2 ^ k ≤ 3 ^ onesCount k r := by
  rw [noncontracting, Finset.mem_filter, Finset.mem_range]
  constructor
  · rintro ⟨hr, hexp⟩
    exact ⟨hr, not_lt.mp fun hlt => absurd ((contractionExp_pos_iff k _).mpr hlt) (not_lt.mpr hexp)⟩
  · rintro ⟨hr, hle⟩
    refine ⟨hr, not_lt.mp fun hpos => ?_⟩
    exact absurd ((contractionExp_pos_iff k _).mp hpos) (not_lt.mpr hle)

/-- At scale `2` the unique non-contracting class is `3 mod 4`. The mod-4 sieve
of `CertifiedEvidence.Collatz` is therefore exactly the scale-2 sieve. -/
theorem noncontracting_two : noncontracting 2 = {3} := by
  ext r
  rw [mem_noncontracting_iff, Finset.mem_singleton]
  constructor
  · rintro ⟨hr, hle⟩
    have hr4 : r < 4 := by norm_num at hr; exact hr
    interval_cases r <;> revert hle <;> decide
  · rintro rfl
    exact ⟨by norm_num, by decide⟩

/-- Consequently every scale-2 non-descending input either lies in `3 mod 4` or
below the explicit threshold `2^2·4^2 = 64`. -/
theorem nondescending_two_subset (B : ℕ) :
    nondescending 2 B ⊆
      ((Finset.Icc 1 B).filter (fun n => n % 4 = 3)) ∪ Finset.Icc 1 64 := by
  intro n hn
  have h := nondescending_subset 2 B hn
  rcases Finset.mem_union.mp h with hleft | hright
  · refine Finset.mem_union_left _ ?_
    rw [Finset.mem_filter] at hleft ⊢
    refine ⟨hleft.1, ?_⟩
    have := hleft.2
    rw [noncontracting_two, Finset.mem_singleton] at this
    simpa using this
  · exact Finset.mem_union_right _ (by simpa using hright)

/-! ## §4. Optimality of the scale-2 sieve -/

theorem T_two_of_mod4_zero (m : ℕ) : T^[2] (4 * m) = m := by
  have h1 : T (4 * m) = 2 * m := by rw [T, if_pos (by omega)]; omega
  have h2 : T (2 * m) = m := by rw [T, if_pos (by omega)]; omega
  simp [Function.iterate_succ_apply, h1, h2]

theorem T_two_of_mod4_two (m : ℕ) : T^[2] (4 * m + 2) = 3 * m + 2 := by
  have h1 : T (4 * m + 2) = 2 * m + 1 := by rw [T, if_pos (by omega)]; omega
  have h2 : T (2 * m + 1) = 3 * m + 2 := by rw [T, if_neg (by omega)]; omega
  simp [Function.iterate_succ_apply, h1, h2]

theorem T_two_of_mod4_three (m : ℕ) : T^[2] (4 * m + 3) = 9 * m + 8 := by
  have h1 : T (4 * m + 3) = 6 * m + 5 := by rw [T, if_neg (by omega)]; omega
  have h2 : T (6 * m + 5) = 9 * m + 8 := by rw [T, if_neg (by omega)]; omega
  simp [Function.iterate_succ_apply, h1, h2]

/-- **The scale-2 sieve cannot be improved.** No input `≡ 3 (mod 4)` descends in
two accelerated steps — the two-step map sends `4m+3` to `9m+8` — so every such
input genuinely has to be examined. -/
theorem not_descends_two_of_mod4_three {n : ℕ} (h : n % 4 = 3) : ¬ (T^[2] n < n) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = 4 * m + 3 := ⟨n / 4, by omega⟩
  rw [T_two_of_mod4_three m]
  omega

/-- Conversely every input `≥ 3` outside `3 mod 4` does descend in two steps. -/
theorem descends_two_of_ne_mod4_three {n : ℕ} (hn : 3 ≤ n) (h : n % 4 ≠ 3) : T^[2] n < n := by
  rcases (by omega : n % 4 = 0 ∨ n % 4 = 1 ∨ n % 4 = 2) with h0 | h1 | h2
  · obtain ⟨m, rfl⟩ : ∃ m, n = 4 * m := ⟨n / 4, by omega⟩
    rw [T_two_of_mod4_zero m]; omega
  · obtain ⟨m, rfl⟩ : ∃ m, n = 4 * m + 1 := ⟨n / 4, by omega⟩
    have h2 : (T^[2]) (4 * m + 1) = 3 * m + 1 := by
      simp [Function.iterate_succ_apply, T_two_steps_mod4 m]
    rw [h2]; omega
  · obtain ⟨m, rfl⟩ : ∃ m, n = 4 * m + 2 := ⟨n / 4, by omega⟩
    rw [T_two_of_mod4_two m]; omega

/-- **Exact description of the scale-2 workload.** The inputs the scale-2 sieve
must examine in `[1,B]` are precisely `1`, `2`, and the residue class `3 mod 4`:
the hand-built mod-4 sieve of `CertifiedEvidence.Collatz` is optimal, and the
generic threshold `2^k·4^k = 64` used by the general theory is far from tight
at this scale. -/
theorem nondescending_two_eq (B : ℕ) (hB : 2 ≤ B) :
    nondescending 2 B = {1, 2} ∪ ((Finset.Icc 1 B).filter (fun n => n % 4 = 3)) := by
  ext n
  rw [mem_nondescending_iff, Finset.mem_union, Finset.mem_insert, Finset.mem_singleton,
    Finset.mem_filter, Finset.mem_Icc]
  constructor
  · rintro ⟨h1, h2, h3⟩
    by_cases hmod : n % 4 = 3
    · exact Or.inr ⟨⟨h1, h2⟩, hmod⟩
    · rcases (by omega : n ≤ 2 ∨ 3 ≤ n) with hsmall | hbig
      · exact Or.inl (by omega)
      · exact absurd (descends_two_of_ne_mod4_three hbig hmod) h3
  · rintro (hsmall | ⟨⟨h1, h2⟩, hmod⟩)
    · rcases hsmall with rfl | rfl
      · exact ⟨le_rfl, by omega, by decide⟩
      · exact ⟨by omega, hB, by decide⟩
    · exact ⟨h1, h2, not_descends_two_of_mod4_three hmod⟩

/-- The exact workload at scale `2`: `(B+1)/4 + 2` inputs. -/
theorem card_nondescending_two (B : ℕ) (hB : 2 ≤ B) :
    (nondescending 2 B).card = (B + 1) / 4 + 2 := by
  have hdisj : Disjoint ({1, 2} : Finset ℕ)
      ((Finset.Icc 1 B).filter (fun n => n % 4 = 3)) := by
    rw [Finset.disjoint_left]
    intro a ha hb
    rw [Finset.mem_insert, Finset.mem_singleton] at ha
    rw [Finset.mem_filter] at hb
    rcases ha with rfl | rfl <;> omega
  rw [nondescending_two_eq B hB, Finset.card_union_of_disjoint hdisj, sieveDensity B]
  simp [Finset.card_insert_of_notMem]
  omega

/-! ## §5. The workload of the scale-`k` sieve -/

/-- How many inputs the scale-`k` sieve actually examines: at most the
non-contracting classes times the number of blocks, plus the exceptional
window below `2^k·4^k`. -/
theorem sieve_workload_le (k B : ℕ) :
    (nondescending k B).card ≤ (noncontracting k).card * (B / 2 ^ k + 1) + 2 ^ k * 4 ^ k :=
  card_nondescending_le k B

/-- **Vanishing amortized certification cost.** For every `ε > 0` there is a
2-adic scale `k` such that, for all large `B`, the scale-`k` sieve is sound for
`[1,B]` and examines fewer than `ε·B` inputs. Certification cost per certified
input tends to zero — yet, by `collatz_evidence_is_not_a_proof`, no member of
the family proves the conjecture. -/
theorem exists_scale_certification_cost_lt (ε : ℝ) (hε : 0 < ε) :
    ∃ k : ℕ, 0 < k ∧ ∀ᶠ B : ℕ in atTop,
      ((nondescending k B).card : ℝ) < ε * B ∧
        ((∀ n ∈ nondescending k B, ReachesOne n) → ∀ n, 1 ≤ n → n ≤ B → ReachesOne n) := by
  obtain ⟨k, hk0, hk⟩ := exists_scale_nondescending_density_lt ε hε
  refine ⟨k, hk0, ?_⟩
  filter_upwards [hk, eventually_gt_atTop 0] with B hB hB0
  have hBR : (0 : ℝ) < B := by exact_mod_cast hB0
  rw [div_lt_iff₀ hBR] at hB
  exact ⟨hB, fun h => sieve_scale k B h⟩

/-- **The cycle-2 summary.** The certified conclusion for `[1,4000]` obtained in
`CertifiedEvidence.Collatz`, the sieve that produced it, and the impossibility of
turning any such certificate into a proof, in one statement. -/
theorem certified_evidence_summary :
    (∀ n, 1 ≤ n → n ≤ 4000 → CollatzReachesOne n) ∧
      (∀ k B : ℕ, (∀ n ∈ nondescending k B, ReachesOne n) →
        ∀ n, 1 ≤ n → n ≤ B → ReachesOne n) ∧
      (∀ fuel B : ℕ, ∃ q : ℕ → Bool,
        checkRange q 1 B = checkRange (collatzChecker fuel) 1 B ∧ q (B + 1) = false) :=
  ⟨collatz_upTo_4000, fun k B h => sieve_scale k B h, fun fuel B => by
    obtain ⟨q, -, h2, h3⟩ := collatz_evidence_is_not_a_proof fuel B
    exact ⟨q, h2, h3⟩⟩

end CertifiedEvidence