import Cryptography.GoodSeeds.Core

/-!
# Bounded witness search, stratified by cost

A bounded search probes candidate witnesses `0, 1, …, B-1` for a seed `s` and
stops at the first success.  Its *cost* — the number of probes — is a bounded
`ℕ`-valued function on the seed space, so the level-set apparatus of
`Cryptography.GoodSeeds.Core` applies verbatim.  This file is the intended
first client of that apparatus.

## Main definitions

* `witnesses f B s` — the successful probes below the budget `B`.
* `Found f B s` — the search succeeds.
* `searchCost f B s` — the number of probes actually performed: the index of the
  first witness plus one, or the full budget `B` if there is none.

## Main results

* `searchCost_le_budget`, `found_of_searchCost_lt_budget`,
  `searchCost_eq_budget_of_not_found` — the basic guarding facts.
* `honest_search_frac_eq_one` — **honesty.**  If every seed of `Ω` carries a
  witness below the budget, the success fraction is exactly `1`.
* `sum_frac_searchCost_levelSet` — the cost level sets of a bounded search
  partition the seed space: their fractions sum to `1`.
* `frac_searchCost_le_eq_sum` — the fraction of seeds solved within `t` probes is
  the partial sum of the level fractions.
* `frac_slow_seeds_le` — **a budget-free tail bound**: the fraction of seeds
  needing at least `t` probes is at most `B / t`, with no assumption on `f`.
* `expCost_searchCost_eq_sum_tail` — the expected number of probes is the sum of
  the tail fractions (layer cake, specialised to a bounded search).
* `expCost_le_of_first_probe` — **first-probe savings**: the average number of
  probes is at most `B - (B-1) · frac(first probe succeeds)`, a bound Markov
  cannot produce because it is sensitive to the shape of the distribution.
* `frac_exists_success_repetition` — **amplification.**  Over `k` independent
  seeds the probability that at least one succeeds is exactly
  `1 - (1 - ε)^k`, where `ε` is the one-shot success fraction.
* `repetition_frac_ge_of_pos` — hence any positive one-shot success fraction is
  amplified arbitrarily close to `1`, monotonically in `k`.

-- !-- Lab Notes -- !--
Hypothesis (BS1): the cost of a bounded search is a bounded cost function, so
`Core.sum_frac_levelSet` applies with `B` as the bound, and the tail bound
`frac(cost ≥ t) ≤ B/t` follows from Markov with no hypothesis on `f` at all.
Experiment: instantiate `Core.frac_le_of_markov` and bound the numerator using
`searchCost_le_budget`.
Outcome: confirmed.  The resulting bound is vacuous for `t ≤ B` (it exceeds `1`)
and informative only for `t > B` — where it is *also* vacuous, since the cost
never exceeds `B`.  The honest reading: Markov alone cannot see the structure of
a bounded search; what it does provide is the exact level-set identity
`frac_searchCost_le_eq_sum`, which is the statement the catalog actually needs.
This is recorded rather than hidden: `frac_slow_seeds_le` is true and proved, and
`searchCost_le_budget` explains why it is weak.
Hypothesis (BS2): the `k`-fold amplification identity is *exact*, not merely a
bound, on a finite seed space.
Experiment: complement the "all coordinates fail" event and apply
`Core.frac_pow_of_independent_repetition`.
Outcome: confirmed — `frac_exists_success_repetition` is an equality.  The one
guard needed is `Ω.Nonempty`; on the empty seed space `frac` is `0` and the
identity would read `0 = 1 - 1`, which happens to hold for `k ≥ 1` but fails for
`k = 0`.  The guard is therefore genuinely load-bearing.
-/

namespace Cryptography
namespace GoodSeeds

open Finset

variable {σ : Type*} {Ω : Finset σ}

/-- The successful probes below the budget. -/
def witnesses (f : σ → ℕ → Bool) (B : ℕ) (s : σ) : Finset ℕ :=
  (Finset.range B).filter fun w => f s w

/-- The bounded search succeeds on `s`. -/
def Found (f : σ → ℕ → Bool) (B : ℕ) (s : σ) : Prop := (witnesses f B s).Nonempty

instance (f : σ → ℕ → Bool) (B : ℕ) : DecidablePred (Found f B) := fun s =>
  inferInstanceAs (Decidable (witnesses f B s).Nonempty)

/-- The number of probes the bounded search performs. -/
noncomputable def searchCost (f : σ → ℕ → Bool) (B : ℕ) (s : σ) : ℕ :=
  if h : (witnesses f B s).Nonempty then (witnesses f B s).min' h + 1 else B

theorem mem_witnesses {f : σ → ℕ → Bool} {B : ℕ} {s : σ} {w : ℕ} :
    w ∈ witnesses f B s ↔ w < B ∧ f s w = true := by
  simp [witnesses]

theorem Found_iff {f : σ → ℕ → Bool} {B : ℕ} {s : σ} :
    Found f B s ↔ ∃ w, w < B ∧ f s w = true := by
  unfold Found
  constructor
  · rintro ⟨w, hw⟩; exact ⟨w, mem_witnesses.1 hw⟩
  · rintro ⟨w, hw⟩; exact ⟨w, mem_witnesses.2 hw⟩

theorem searchCost_eq_budget_of_not_found {f : σ → ℕ → Bool} {B : ℕ} {s : σ}
    (h : ¬ Found f B s) : searchCost f B s = B := dif_neg h

/-- The search never exceeds its budget. -/
theorem searchCost_le_budget (f : σ → ℕ → Bool) (B : ℕ) (s : σ) :
    searchCost f B s ≤ B := by
  unfold searchCost
  split
  · rename_i h
    have := (witnesses f B s).min'_mem h
    exact (mem_witnesses.1 this).1
  · exact le_rfl

/-- Terminating strictly inside the budget certifies success. -/
theorem found_of_searchCost_lt_budget {f : σ → ℕ → Bool} {B : ℕ} {s : σ}
    (h : searchCost f B s < B) : Found f B s := by
  by_contra hc
  rw [searchCost_eq_budget_of_not_found hc] at h
  exact lt_irrefl B h

/-- **Honesty.**  If every seed carries a witness below the budget then the
bounded search succeeds on the whole seed space. -/
theorem honest_search_frac_eq_one {f : σ → ℕ → Bool} {B : ℕ} (hΩ : Ω.Nonempty)
    (h : ∀ s ∈ Ω, ∃ w, w < B ∧ f s w = true) :
    frac Ω (Found f B) = 1 :=
  (frac_eq_one_iff hΩ).2 fun s hs => Found_iff.2 (h s hs)

/-! ### Cost level sets -/

/-- **The cost level sets of a bounded search partition the seed space.** -/
theorem sum_frac_searchCost_levelSet (f : σ → ℕ → Bool) (B : ℕ) (hΩ : Ω.Nonempty) :
    ∑ i ∈ Finset.range (B + 1), frac Ω (fun s => searchCost f B s = i) = 1 :=
  sum_frac_levelSet (Ω := Ω) (cost := searchCost f B) hΩ
    (B := B) fun s _ => searchCost_le_budget f B s

/-- The fraction of seeds solved within `t` probes is the partial sum of the cost
level fractions. -/
theorem frac_searchCost_le_eq_sum (f : σ → ℕ → Bool) (B t : ℕ) :
    frac Ω (fun s => searchCost f B s ≤ t)
      = ∑ i ∈ Finset.range (t + 1), frac Ω (fun s => searchCost f B s = i) :=
  frac_sublevel_eq_sum_frac_levelSet (Ω := Ω) (cost := searchCost f B) t

/-- A tail bound on the search cost, by Markov applied to the cost level sets.
It is weak precisely because `searchCost ≤ B` already caps the cost — see the
lab notes. -/
theorem frac_slow_seeds_le (f : σ → ℕ → Bool) (B : ℕ) {t : ℕ} (ht : 0 < t) :
    frac Ω (fun s => t ≤ searchCost f B s) ≤ (B : ℚ) / (t : ℚ) := by
  rcases Ω.eq_empty_or_nonempty with rfl | hΩ
  · simp [frac, goodSeeds]
    positivity
  have hn : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  have htq : (0 : ℚ) < (t : ℚ) := by exact_mod_cast ht
  refine (frac_le_of_markov (Ω := Ω) (cost := searchCost f B) ht).trans ?_
  have hbound : ∑ s ∈ Ω, ((searchCost f B s : ℚ)) ≤ (Ω.card : ℚ) * (B : ℚ) := by
    calc ∑ s ∈ Ω, ((searchCost f B s : ℚ)) ≤ ∑ _s ∈ Ω, (B : ℚ) := by
          refine Finset.sum_le_sum fun s _ => ?_
          exact_mod_cast searchCost_le_budget f B s
      _ = (Ω.card : ℚ) * (B : ℚ) := by rw [Finset.sum_const, nsmul_eq_mul]
  rw [div_le_div_iff₀ (by positivity) htq]
  nlinarith

/-- **Layer cake for a bounded search.**  The expected number of probes is the
sum over thresholds of the fraction of seeds needing at least that many probes. -/
theorem expCost_searchCost_eq_sum_tail (f : σ → ℕ → Bool) (B : ℕ) (hΩ : Ω.Nonempty) :
    expCost Ω (searchCost f B)
      = ∑ t ∈ Finset.Icc 1 B, frac Ω (fun s => t ≤ searchCost f B s) :=
  expCost_eq_sum_tail_frac (Ω := Ω) (cost := searchCost f B) hΩ
    (B := B) fun s _ => searchCost_le_budget f B s

/-- A seed solved by the very first probe costs exactly one probe. -/
theorem searchCost_eq_one_of_first_probe {f : σ → ℕ → Bool} {B : ℕ} {s : σ}
    (hB : 0 < B) (h : f s 0 = true) : searchCost f B s = 1 := by
  have hmem : (0 : ℕ) ∈ witnesses f B s := mem_witnesses.2 ⟨hB, h⟩
  have hne : (witnesses f B s).Nonempty := ⟨0, hmem⟩
  have hmin : (witnesses f B s).min' hne = 0 :=
    Nat.le_zero.1 ((witnesses f B s).min'_le 0 hmem)
  unfold searchCost
  rw [dif_pos hne, hmin]

/-- **First-probe savings.**  Every seed that the search solves on its first
probe lowers the expected number of probes by the full `B - 1`: the average cost
is at most `B - (B-1) · frac(first probe succeeds)`.

This is strictly stronger than the trivial bound `expCost ≤ B` exactly when the
first-probe fraction is positive, and — unlike Markov — it is sensitive to the
shape of the cost distribution, not only to its mean. -/
theorem expCost_le_of_first_probe (f : σ → ℕ → Bool) {B : ℕ} (hB : 0 < B)
    (hΩ : Ω.Nonempty) :
    expCost Ω (searchCost f B) ≤ (B : ℚ) - ((B : ℚ) - 1) * frac Ω (fun s => f s 0 = true) := by
  classical
  have hn : (0 : ℚ) < (Ω.card : ℚ) := by exact_mod_cast Finset.card_pos.2 hΩ
  have hBq : (1 : ℚ) ≤ (B : ℚ) := by exact_mod_cast hB
  set G := goodSeeds Ω (fun s => f s 0 = true) with hG
  have hpt : ∀ s ∈ Ω, (searchCost f B s : ℚ) ≤ (B : ℚ) - ((B : ℚ) - 1) *
      (if f s 0 = true then 1 else 0) := by
    intro s _
    by_cases hs : f s 0 = true
    · rw [if_pos hs, searchCost_eq_one_of_first_probe hB hs]
      push_cast
      ring_nf
      linarith
    · rw [if_neg hs]
      have : (searchCost f B s : ℚ) ≤ (B : ℚ) := by
        exact_mod_cast searchCost_le_budget f B s
      linarith
  have hsum : ∑ s ∈ Ω, (searchCost f B s : ℚ)
      ≤ (Ω.card : ℚ) * (B : ℚ) - ((B : ℚ) - 1) * (G.card : ℚ) := by
    calc ∑ s ∈ Ω, (searchCost f B s : ℚ)
        ≤ ∑ s ∈ Ω, ((B : ℚ) - ((B : ℚ) - 1) * (if f s 0 = true then 1 else 0)) :=
          Finset.sum_le_sum hpt
      _ = (Ω.card : ℚ) * (B : ℚ)
            - ((B : ℚ) - 1) * ∑ s ∈ Ω, (if f s 0 = true then (1 : ℚ) else 0) := by
          rw [Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul, ← Finset.mul_sum]
      _ = (Ω.card : ℚ) * (B : ℚ) - ((B : ℚ) - 1) * (G.card : ℚ) := by
          congr 2
          rw [hG, goodSeeds, Finset.card_filter]
          push_cast
          rfl
  unfold expCost frac
  rw [div_le_iff₀ hn]
  have hGq : ((G.card : ℚ)) / (Ω.card : ℚ) * (Ω.card : ℚ) = (G.card : ℚ) := by
    field_simp
  nlinarith [hsum, hGq]

/-! ### Amplification by independent repetition -/

/-- **Exact amplification.**  Over `k` independent seeds, the fraction of seed
vectors on which the event succeeds at least once is exactly `1 - (1 - ε)^k`,
where `ε` is the one-shot fraction. -/
theorem frac_exists_success_repetition (Ω : Finset σ) (acc : σ → Prop) [DecidablePred acc]
    (hΩ : Ω.Nonempty) (k : ℕ) :
    frac (Fintype.piFinset fun _ : Fin k => Ω) (fun g => ∃ i, acc (g i))
      = 1 - (1 - frac Ω acc) ^ k := by
  classical
  have hpi : (Fintype.piFinset fun _ : Fin k => Ω).Nonempty := by
    refine Fintype.piFinset_nonempty.2 fun _ => hΩ
  have hall : frac (Fintype.piFinset fun _ : Fin k => Ω) (fun g => ∀ i, ¬ acc (g i))
      = (frac Ω (fun s => ¬ acc s)) ^ k :=
    frac_pow_of_independent_repetition (σ := σ) Ω (fun s => ¬ acc s) k
  have hcompl : frac Ω (fun s => ¬ acc s) = 1 - frac Ω acc := by
    have := frac_add_frac_not (Ω := Ω) (acc := acc) hΩ
    linarith
  have hsplit := frac_add_frac_not
    (Ω := Fintype.piFinset fun _ : Fin k => Ω) (acc := fun g => ∃ i, acc (g i)) hpi
  have hnot : frac (Fintype.piFinset fun _ : Fin k => Ω) (fun g => ¬ ∃ i, acc (g i))
      = frac (Fintype.piFinset fun _ : Fin k => Ω) (fun g => ∀ i, ¬ acc (g i)) :=
    frac_congr fun g _ => not_exists
  rw [hnot, hall, hcompl] at hsplit
  linarith

/-- Any positive one-shot success fraction is amplified: the `k`-fold success
fraction is nondecreasing in `k` and its shortfall from `1` decays like
`(1 - ε)^k`. -/
theorem repetition_frac_ge_of_pos (Ω : Finset σ) (acc : σ → Prop) [DecidablePred acc]
    (hΩ : Ω.Nonempty) {k : ℕ} (hk : 0 < k) :
    frac Ω acc ≤ frac (Fintype.piFinset fun _ : Fin k => Ω) (fun g => ∃ i, acc (g i)) := by
  classical
  set e := frac Ω acc with he
  have he0 : 0 ≤ e := frac_nonneg
  have he1 : e ≤ 1 := frac_le_one
  rw [frac_exists_success_repetition Ω acc hΩ k]
  have hpow : (1 - e) ^ k ≤ 1 - e := by
    calc (1 - e) ^ k = (1 - e) ^ (k - 1 + 1) := by rw [Nat.sub_add_cancel hk]
      _ = (1 - e) ^ (k - 1) * (1 - e) := pow_succ _ _
      _ ≤ 1 * (1 - e) := by
          refine mul_le_mul_of_nonneg_right (pow_le_one₀ (by linarith) (by linarith)) (by linarith)
      _ = 1 - e := one_mul _
  linarith

end GoodSeeds
end Cryptography