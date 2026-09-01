import Probability.NET89MultiDomainDichotomy

/-!
# NET-89, cycle 4: the parity slack is generic — a conjecture of cycle 3 refuted

Cycles 1–3 left the doubling law with a one-key slack: `2K - 1 ≤ k*_mix(2n) ≤ 2K`, where
`K` is the pooled knee.  The natural hope — recorded as an open direction after cycle 2 —
was that the slack is *exceptional*: that `k*_mix(2n) = 2K` for all but a negligible set of
gates, making the doubling law exact in practice.  This file settles that question, in the
negative, and replaces the hope by an exact characterisation.

* `kstar_mix_parity` — **the exact parity law.**  The bracket is decided by a single
  comparison: `k*_mix(2n) = 2K - 1` if the odd budget `2K - 1` already clears the gate, and
  `2K` otherwise.  Nothing else can happen.
* `parity_odd_on_low_gates` — **the refutation.**  For *every* pair of positive profiles the
  odd end is taken on the whole gate interval `(0, r₁]`, where `r₁ = retained (mix u v)
  (2n) 1` is the first key's mass fraction, and `retained_mix_one_pos` shows that interval
  has positive length.  So the exceptional set of gates is not negligible: it always
  contains an interval.
* `parity_even_at_top_gate` — and the even end is taken at `τ = 1`, again for every profile
  pair.  Both ends of the bracket are therefore always realised: the bracket of cycle 1 is
  the sharpest possible statement, and no parity-free doubling law exists.
* `parity_both_ends_realised` — the two facts packaged as one theorem.
* `flat_parity_witness` — a fully explicit instance: for the flat profile at `n = 2`, gate
  `1/4` gives the odd knee `1 = 2K - 1` and gate `1/2` gives the even knee `2 = 2K`, with
  the same pooled knee `K = 1`.  So a single experiment can flip parity by moving the gate
  alone, with no change to the data.

-- !-- Lab Notes -- !--
Hypothesizer (round 33, cycle 4): (F1) the parity slack is decided by one comparison;
(F2) [conjectured after cycle 2] the slack is measure-negligible in the gate, so the
doubling law is essentially exact; (F3) if F2 fails, the failure should be uniform over
profiles rather than pathological.

Experimenter: F1 = `kstar_mix_parity`.  F2 is **refuted**: `parity_odd_on_low_gates` plus
`retained_mix_one_pos` produce, for every profile pair, a positive-length interval of gates
on which the odd end is taken.  F3 = `parity_both_ends_realised`: the refutation is
uniform, not pathological — it holds for every positive pair of profiles and every context.

Analyst: this is a "true but weaker than hoped" outcome, and it sharpens the reading of the
experimental table.  Since the knee's parity is decided by where the gate sits relative to a
*single key's* mass, a reported mixed knee of 20 versus a predicted 2·10 carries no
information about cross-domain structure: one key of gate movement flips it.  The honest
invariant is the bracket, and the honest report of the increment is the interval `[5, 11]`
already extracted in cycle 1.

Critic: the refutation is not an artefact of degenerate profiles — no decay, boundedness or
normalisation hypothesis is used beyond positivity, and the explicit flat witness shows both
parities at two gates that differ by a factor of two, well inside the range used by the
programme.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v : ℕ → ℝ} {τ : ℝ} {n : ℕ}

/-! ## 1. The exact parity law -/

/-- **F1 — the parity of the mixed knee is decided by one comparison.**  The knee is the odd
end `2K - 1` exactly when that budget already clears the gate, and the even end `2K`
otherwise. -/
theorem kstar_mix_parity (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1)
    (hK : 1 ≤ kstar (pool 1 1 u v) n τ) :
    kstar (mix u v) (2 * n) τ =
      if τ ≤ retained (mix u v) (2 * n) (2 * kstar (pool 1 1 u v) n τ - 1)
        then 2 * kstar (pool 1 1 u v) n τ - 1
        else 2 * kstar (pool 1 1 u v) n τ := by
  obtain ⟨b1, b2⟩ := kstar_mix_bracket hu hv hn hτ
  by_cases h : τ ≤ retained (mix u v) (2 * n) (2 * kstar (pool 1 1 u v) n τ - 1)
  · rw [if_pos h]
    have := kstar_le_of_pass (w := mix u v) (n := 2 * n) h
    omega
  · rw [if_neg h]
    push_neg at h
    exact kstar_mix_eq_two_mul hu hv hn hτ hK h

/-! ## 2. Both ends are always realised -/

lemma retained_mix_one (u v : ℕ → ℝ) (hn : 0 < n) :
    retained (mix u v) (2 * n) 1 = headMass u 1 / (headMass u n + headMass v n) := by
  have h1 : min 1 (2 * n) = 1 := by omega
  have h2 : headMass (mix u v) 1 = headMass u 1 := by
    have := headMass_mix_odd u v 0
    simpa [headMass] using this
  rw [retained, h1, h2, headMass_mix_even]

lemma retained_pool_one (u v : ℕ → ℝ) (hn : 0 < n) :
    retained (pool 1 1 u v) n 1
      = (headMass u 1 + headMass v 1) / (headMass u n + headMass v n) := by
  have h1 : min 1 n = 1 := by omega
  rw [retained, h1, headMass_pool, headMass_pool]
  simp

/-- The odd-parity gate window has positive length: it is the first key's mass fraction. -/
lemma retained_mix_one_pos (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) :
    0 < retained (mix u v) (2 * n) 1 := by
  rw [retained_mix_one u v hn]
  have h1 : 0 < headMass u 1 := headMass_pos hu one_pos
  have h2 : 0 < headMass u n + headMass v n :=
    add_pos (headMass_pos hu hn) (headMass_pos hv hn)
  positivity

/-- **F2 refuted.**  On the entire gate interval `(0, r₁]` — of positive length for every
profile pair — the mixed knee sits at the *odd* end of the bracket. -/
theorem parity_odd_on_low_gates (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ0 : 0 < τ) (hτ1 : τ ≤ retained (mix u v) (2 * n) 1) :
    kstar (mix u v) (2 * n) τ = 1 ∧ kstar (pool 1 1 u v) n τ = 1 ∧
      kstar (mix u v) (2 * n) τ = 2 * kstar (pool 1 1 u v) n τ - 1 := by
  have hmp : ∀ i, 0 < mix u v i := mix_pos hu hv
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hle1 : τ ≤ 1 := le_trans hτ1 (retained_le_one hmp _ _ (by omega))
  have hfail0m : retained (mix u v) (2 * n) 0 < τ := by
    simp only [retained, Nat.zero_min, headMass, Finset.range_zero, Finset.sum_empty, zero_div]
    exact hτ0
  have hfail0p : retained (pool 1 1 u v) n 0 < τ := by
    simp only [retained, Nat.zero_min, headMass, Finset.range_zero, Finset.sum_empty, zero_div]
    exact hτ0
  have hM : kstar (mix u v) (2 * n) τ = 1 :=
    kstar_eq_of_fail_pass hmp (by omega) hle1 (m := 0) hfail0m hτ1
  have hpass1 : τ ≤ retained (pool 1 1 u v) n 1 := by
    refine le_trans hτ1 ?_
    rw [retained_mix_one u v hn, retained_pool_one u v hn]
    have hD : 0 < headMass u n + headMass v n :=
      add_pos (headMass_pos hu hn) (headMass_pos hv hn)
    have hnum : headMass u 1 ≤ headMass u 1 + headMass v 1 := by
      have := headMass_pos hv one_pos; linarith
    exact div_le_div_of_nonneg_right hnum hD.le
  have hK : kstar (pool 1 1 u v) n τ = 1 :=
    kstar_eq_of_fail_pass hpp hn hle1 (m := 0) hfail0p hpass1
  exact ⟨hM, hK, by omega⟩

/-- At the top gate the mixed knee sits at the *even* end of the bracket. -/
theorem parity_even_at_top_gate (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) :
    kstar (mix u v) (2 * n) 1 = 2 * n ∧ kstar (pool 1 1 u v) n 1 = n ∧
      kstar (mix u v) (2 * n) 1 = 2 * kstar (pool 1 1 u v) n 1 := by
  have hmp : ∀ i, 0 < mix u v i := mix_pos hu hv
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hM : kstar (mix u v) (2 * n) 1 = 2 * n := by
    have h := kstar_eq_of_fail_pass hmp (n := 2 * n) (τ := 1) (by omega) le_rfl
      (m := 2 * n - 1) (retained_lt_one hmp (by omega))
      (by rw [show 2 * n - 1 + 1 = 2 * n by omega]
          exact le_of_eq (retained_self hmp (by omega)).symm)
    omega
  have hK : kstar (pool 1 1 u v) n 1 = n := by
    have h := kstar_eq_of_fail_pass hpp (n := n) (τ := 1) hn le_rfl
      (m := n - 1) (retained_lt_one hpp (by omega))
      (by rw [show n - 1 + 1 = n by omega]; exact le_of_eq (retained_self hpp hn).symm)
    omega
  exact ⟨hM, hK, by omega⟩

/-- **The parity slack is generic.**  For every pair of positive profiles and every context,
both ends of the mixed-knee bracket are realised: the odd end on a gate interval of positive
length, the even end at the top gate.  Hence no sharpening of `kstar_mix_bracket` to a
parity-free identity is possible. -/
theorem parity_both_ends_realised (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) :
    0 < retained (mix u v) (2 * n) 1 ∧
      (∀ τ : ℝ, 0 < τ → τ ≤ retained (mix u v) (2 * n) 1 →
        kstar (mix u v) (2 * n) τ = 2 * kstar (pool 1 1 u v) n τ - 1 ∧
          kstar (mix u v) (2 * n) τ ≠ 2 * kstar (pool 1 1 u v) n τ) ∧
      kstar (mix u v) (2 * n) 1 = 2 * kstar (pool 1 1 u v) n 1 := by
  refine ⟨retained_mix_one_pos hu hv hn, fun τ hτ0 hτ1 => ?_,
    (parity_even_at_top_gate hu hv hn).2.2⟩
  obtain ⟨hM, hK, hodd⟩ := parity_odd_on_low_gates hu hv hn hτ0 hτ1
  exact ⟨hodd, by omega⟩

/-! ## 3. An explicit gate-flip witness -/

/-- The flat profile, used as both domains. -/
noncomputable def flat : ℕ → ℝ := fun _ => 1

lemma flat_pos : ∀ i, 0 < flat i := fun _ => one_pos

lemma pool_flat : pool 1 1 flat flat = fun _ => (2 : ℝ) := by
  funext i; simp [pool, flat]; norm_num

lemma kstar_pool_flat_quarter : kstar (pool 1 1 flat flat) 2 (1 / 4) = 1 := by
  rw [pool_flat]
  apply kstar_eq_of_fail_pass (w := fun _ => (2 : ℝ)) (fun _ => by norm_num) (by norm_num)
    (by norm_num) (m := 0)
  · norm_num [retained, headMass]
  · norm_num [retained, headMass, Finset.sum_range_succ]

lemma kstar_pool_flat_half : kstar (pool 1 1 flat flat) 2 (1 / 2) = 1 := by
  rw [pool_flat]
  apply kstar_eq_of_fail_pass (w := fun _ => (2 : ℝ)) (fun _ => by norm_num) (by norm_num)
    (by norm_num) (m := 0)
  · norm_num [retained, headMass]
  · norm_num [retained, headMass, Finset.sum_range_succ]

lemma kstar_mix_flat_quarter : kstar (mix flat flat) 4 (1 / 4) = 1 := by
  rw [show mix flat flat = flat from mix_flat]
  apply kstar_eq_of_fail_pass flat_pos (by norm_num) (by norm_num) (m := 0)
  · norm_num [retained, headMass, flat]
  · norm_num [retained, headMass, flat, Finset.sum_range_succ]

lemma kstar_mix_flat_half : kstar (mix flat flat) 4 (1 / 2) = 2 := by
  rw [show mix flat flat = flat from mix_flat]
  apply kstar_eq_of_fail_pass flat_pos (by norm_num) (by norm_num) (m := 1)
  · norm_num [retained, headMass, flat, Finset.sum_range_succ]
  · norm_num [retained, headMass, flat, Finset.sum_range_succ]

/-- **Gate flip.**  One profile pair, one context, two gates: at `τ = 1/4` the mixed knee is
the odd end `1 = 2K - 1`, at `τ = 1/2` it is the even end `2 = 2K`, and the pooled knee is
`K = 1` in both cases.  Parity carries no information about the data. -/
theorem flat_parity_witness :
    kstar (pool 1 1 flat flat) 2 (1 / 4) = 1 ∧ kstar (mix flat flat) 4 (1 / 4) = 1 ∧
      kstar (pool 1 1 flat flat) 2 (1 / 2) = 1 ∧ kstar (mix flat flat) 4 (1 / 2) = 2 :=
  ⟨kstar_pool_flat_quarter, kstar_mix_flat_quarter, kstar_pool_flat_half, kstar_mix_flat_half⟩

end Catalog.Probability.NET89MixedDomainKnee