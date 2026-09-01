import Probability.NET89MixingRatioBlocks

/-!
# NET-89, cycle 3: `m` domains at once, and the fair-comparison dichotomy

Cycles 1–2 handled two domains.  Real workloads interleave more than two content types,
and the report's headline comparison ("mixed rises faster than either pure domain") is made
at *equal total context*, where each domain supplies only half the content.  This file
closes both gaps.

## `m`-fold round robin

* `roundRobin m U` — a context whose keys cycle through `m` domains, and `poolFam m U` —
  their pooled profile.  `roundRobin_two` checks the definition against cycle 1:
  `roundRobin 2 = mix`.
* `headMass_roundRobin` — the `m`-fold halving reduction: an aligned prefix of length
  `m·k` contains exactly the matched prefixes of all `m` domains.
* `kstar_roundRobin_bracket` — hence `m·Q - (m-1) ≤ k*_rr(m·n) ≤ m·Q` where `Q` is the
  pooled knee: the knee is the pooled knee in `m`-fold key units, up to one cycle.
* `roundRobin_ctxSens_multiplier` — **the increment multiplier is exactly the number of
  domains**: `|Δ_rr - m·Δ_pool| ≤ m - 1`.  The doubling of cycle 1 is the case `m = 2`,
  and a three-domain mixture must show a *tripled* increment.  This is a sharp, cheap
  prediction: measure a code/prose/markup mixture and the increment must be `3Δ ± 2`.

## The fair-comparison dichotomy

* `mixed_and_pure_budgets_bounded_of_geometric_decay` — if the component profiles have a
  spectral gap, the mixed budget *and* the pure budget are both bounded by one constant at
  every context: the "mixed is harder" effect cannot exist for gapped models.
* `mixed_minus_pure_unbounded_for_flat` — for the gapless (flat) profile the same
  comparison diverges: `k*_mix(2n) - k*_pure(n)` exceeds every bound.
* `fair_comparison_dichotomy` — putting the two together: the reported excess of the mixed
  budget over the pure one is a *diagnostic for gaplessness* of the attention profile, not
  a property of mixing.  Both sides are realised by explicit profiles, so neither is
  vacuous.

-- !-- Lab Notes -- !--
Hypothesizer (round 33, cycle 3, three conjectures):
 (E1) The halving reduction is really an `m`-fold reduction, and the increment multiplier
      equals the number of interleaved domains, with slack `m-1`.                 [BOLD]
 (E2) With a spectral gap, mixed and pure budgets are simultaneously bounded, so the
      reported mixed-versus-pure excess must vanish for gapped models.            [BOLD]
 (E3) Without a gap the same excess diverges, giving a two-sided dichotomy.

Experimenter: E1 = `headMass_roundRobin`, `kstar_roundRobin_bracket`,
`roundRobin_ctxSens_multiplier`, cross-checked against cycle 1 by `roundRobin_two`;
E2 = `mixed_and_pure_budgets_bounded_of_geometric_decay`; E3 =
`mixed_minus_pure_unbounded_for_flat`.  Zero sorries.

Analyst: the multiplier theorem explains the whole NET-89 "+8 vs +4" table without any
cross-domain interaction: mixing `m` content types multiplies the key unit by `m`, hence
the increment by `m`.  The dichotomy then says where to look for a genuine effect: only a
gapless attention profile can produce a mixed-versus-pure excess that grows with context,
so the reported growth is evidence about the *model's* spectrum, not about the corpus.

Critic: the multiplier statement uses truncated natural subtraction throughout, so the
`m-1` slack is stated in the additive form `m·Δ_pool ≤ Δ_rr + (m-1)` that cannot hide an
underflow.  The bounded side of the dichotomy is stated for *both* budgets at once, so it
is not the trivial statement that one of them is bounded; and the unbounded side is a
difference of two genuinely different contexts (`2n` versus `n`), which is exactly the
comparison the report makes.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {m n : ℕ} {τ : ℝ} {U : ℕ → ℕ → ℝ} {u v : ℕ → ℝ}

/-! ## 1. `m` domains: round-robin interleaving -/

/-- The pooled profile of a family of `m` domains sharing one context. -/
noncomputable def poolFam (m : ℕ) (U : ℕ → ℕ → ℝ) : ℕ → ℝ := fun i => ∑ j ∈ range m, U j i

/-- The round-robin interleaving of `m` domains: key `i` comes from domain `i % m`. -/
noncomputable def roundRobin (m : ℕ) (U : ℕ → ℕ → ℝ) : ℕ → ℝ := fun i => U (i % m) (i / m)

/-- Consistency with cycle 1: two domains in round robin is exactly alternation. -/
lemma roundRobin_two (u v : ℕ → ℝ) :
    roundRobin 2 (fun j => if j = 0 then u else v) = mix u v := by
  funext i
  simp only [roundRobin, mix]
  by_cases h : i % 2 = 0
  · simp [h]
  · have h1 : i % 2 = 1 := by omega
    simp [h1]

lemma poolFam_pos (hm : 0 < m) (hU : ∀ j i, 0 < U j i) : ∀ i, 0 < poolFam m U i := fun i =>
  Finset.sum_pos (fun j _ => hU j i) ⟨0, mem_range.mpr hm⟩

lemma roundRobin_pos (hU : ∀ j i, 0 < U j i) : ∀ i, 0 < roundRobin m U i := fun _ => hU _ _

lemma headMass_poolFam (m : ℕ) (U : ℕ → ℕ → ℝ) (k : ℕ) :
    headMass (poolFam m U) k = ∑ j ∈ range m, headMass (U j) k := by
  simp only [headMass, poolFam]
  exact Finset.sum_comm

/-- **The `m`-fold reduction.**  An aligned prefix of a round-robin context contains
exactly the matched prefixes of all `m` domains. -/
lemma headMass_roundRobin (hm : 0 < m) (U : ℕ → ℕ → ℝ) (k : ℕ) :
    headMass (roundRobin m U) (m * k) = ∑ j ∈ range m, headMass (U j) k := by
  induction k with
  | zero => simp [headMass]
  | succ k ih =>
      have e1 : m * (k + 1) = m * k + m := by ring
      have hblock : ∀ i ∈ range m, roundRobin m U (m * k + i) = U i k := by
        intro i hi
        have him : i < m := mem_range.mp hi
        have h1 : (m * k + i) % m = i := by rw [Nat.mul_add_mod, Nat.mod_eq_of_lt him]
        have h2 : (m * k + i) / m = k := by
          rw [Nat.mul_add_div hm, Nat.div_eq_of_lt him, Nat.add_zero]
        simp [roundRobin, h1, h2]
      simp only [headMass] at ih ⊢
      rw [e1, Finset.sum_range_add, ih, Finset.sum_congr rfl hblock, ← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl fun j _ => (Finset.sum_range_succ (U j) k).symm

lemma retained_roundRobin_aligned (hm : 0 < m) (U : ℕ → ℕ → ℝ) (n k : ℕ) :
    retained (roundRobin m U) (m * n) (m * k) = retained (poolFam m U) n k := by
  rw [retained, retained, min_mul_left, headMass_roundRobin hm, headMass_roundRobin hm,
    headMass_poolFam, headMass_poolFam]

/-- **E1 — the `m`-fold knee bracket.**  In `m`-fold key units the round-robin knee is the
pooled knee, up to one cycle of slack. -/
theorem kstar_roundRobin_bracket (hm : 0 < m) (hU : ∀ j i, 0 < U j i) (hn : 0 < n) (hτ : τ ≤ 1) :
    m * kstar (poolFam m U) n τ ≤ kstar (roundRobin m U) (m * n) τ + (m - 1) ∧
      kstar (roundRobin m U) (m * n) τ ≤ m * kstar (poolFam m U) n τ := by
  have hpp : ∀ i, 0 < poolFam m U i := poolFam_pos hm hU
  have hrp : ∀ i, 0 < roundRobin m U i := roundRobin_pos hU
  set Q := kstar (poolFam m U) n τ with hQ
  set M := kstar (roundRobin m U) (m * n) τ with hM
  have hup : M ≤ m * Q := by
    apply kstar_le_of_pass
    rw [retained_roundRobin_aligned hm]
    exact gate_le_retained_kstar hpp hn hτ
  refine ⟨?_, hup⟩
  by_contra hcon
  push_neg at hcon
  have hQ1 : 1 ≤ Q := by
    rcases Nat.eq_zero_or_pos Q with h | h
    · rw [h, Nat.mul_zero] at hcon; omega
    · exact h
  have hle : M ≤ m * (Q - 1) := by
    have hms : m * (Q - 1) = m * Q - m := by
      cases m with
      | zero => omega
      | succ m' => rw [Nat.mul_sub]; omega
    omega
  have hpass : τ ≤ retained (roundRobin m U) (m * n) M :=
    gate_le_retained_kstar hrp (Nat.mul_pos hm hn) hτ
  have hpass2 : τ ≤ retained (roundRobin m U) (m * n) (m * (Q - 1)) :=
    le_trans hpass (retained_mono hrp _ hle)
  rw [retained_roundRobin_aligned hm] at hpass2
  have := kstar_le_of_pass (w := poolFam m U) (n := n) (τ := τ) hpass2
  omega

/-- **E1, headline form — the increment multiplier is the number of domains.**  Doubling
the context of an `m`-domain round-robin mixture moves its knee by `m` times the pooled
increment, up to `m - 1` keys.  Cycle 1's doubling law is the case `m = 2`; a three-domain
mixture must show a tripled increment. -/
theorem roundRobin_ctxSens_multiplier (hm : 0 < m) (hU : ∀ j i, 0 < U j i) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    m * ctxSens (poolFam m U) τ n ≤ ctxSens (roundRobin m U) τ (m * n) + (m - 1) ∧
      ctxSens (roundRobin m U) τ (m * n) ≤ m * ctxSens (poolFam m U) τ n + (m - 1) := by
  have hpp : ∀ i, 0 < poolFam m U i := poolFam_pos hm hU
  have hrp : ∀ i, 0 < roundRobin m U i := roundRobin_pos hU
  obtain ⟨l1, u1⟩ := kstar_roundRobin_bracket hm hU hn hτ
  obtain ⟨l2, u2⟩ := kstar_roundRobin_bracket (n := 2 * n) hm hU (by omega) hτ
  have e2 : m * (2 * n) = 2 * (m * n) := by ring
  rw [e2] at l2 u2
  have hmono1 : kstar (poolFam m U) n τ ≤ kstar (poolFam m U) (2 * n) τ :=
    kstar_mono_ctx hpp hτ hn (by omega)
  have hmono2 : kstar (roundRobin m U) (m * n) τ ≤ kstar (roundRobin m U) (2 * (m * n)) τ :=
    kstar_mono_ctx hrp hτ (Nat.mul_pos hm hn) (by omega)
  have hmul : m * (kstar (poolFam m U) (2 * n) τ - kstar (poolFam m U) n τ)
      = m * kstar (poolFam m U) (2 * n) τ - m * kstar (poolFam m U) n τ := Nat.mul_sub m _ _
  have hmle : m * kstar (poolFam m U) n τ ≤ m * kstar (poolFam m U) (2 * n) τ :=
    Nat.mul_le_mul_left _ hmono1
  simp only [ctxSens]
  omega

/-! ## 2. The fair-comparison dichotomy -/

/-- **E2 — a spectral gap kills the effect.**  If both domains decay geometrically, one
constant bounds the mixed budget *and* the pure budget at every context length, so their
difference cannot grow. -/
theorem mixed_and_pure_budgets_bounded_of_geometric_decay
    (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) {r : ℝ} (hr0 : 0 < r) (hr1 : r < 1)
    (hdu : ∀ i, u (i + 1) ≤ r * u i) (hdv : ∀ i, v (i + 1) ≤ r * v i) (hτ : τ < 1) :
    ∃ C : ℕ, ∀ n : ℕ, 1 ≤ n → kstar (mix u v) (2 * n) τ ≤ C ∧ kstar u (2 * n) τ ≤ C := by
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hdp : ∀ i, pool 1 1 u v (i + 1) ≤ r * pool 1 1 u v i := by
    intro i
    have := hdu i; have := hdv i
    simp only [pool, one_mul]
    nlinarith
  obtain ⟨K1, _, hK1⟩ := kstar_uniformly_bounded_of_geometric_decay hpp hr0 hr1 hdp hτ
  obtain ⟨K2, _, hK2⟩ := kstar_uniformly_bounded_of_geometric_decay hu hr0 hr1 hdu hτ
  refine ⟨2 * K1 + K2, fun n hn => ⟨?_, ?_⟩⟩
  · have h1 := (kstar_mix_bracket hu hv (by omega) hτ.le (n := n)).2
    have h2 := hK1 n hn
    omega
  · have := hK2 (2 * n) (by omega)
    omega

lemma mix_flat : mix (fun _ => (1 : ℝ)) (fun _ => (1 : ℝ)) = fun _ => (1 : ℝ) := by
  funext i; simp only [mix]; split <;> rfl

/-- **E3 — without a gap the effect diverges.**  For the flat profile the reported
comparison (mixed at total length `2n` against pure at length `n`) exceeds every bound. -/
theorem mixed_minus_pure_unbounded_for_flat (hτ0 : 0 < τ) (hτ : τ ≤ 1) (K : ℕ) :
    ∃ n : ℕ, 0 < n ∧
      K < kstar (mix (fun _ => (1 : ℝ)) (fun _ => (1 : ℝ))) (2 * n) τ
            - kstar (fun _ => (1 : ℝ)) n τ := by
  obtain ⟨n, hn, hK⟩ := ctxSens_uniform_unbounded hτ0 hτ K
  exact ⟨n, hn, by rwa [mix_flat]⟩

/-- **The dichotomy.**  A mixed-versus-pure budget excess that grows with context is
possible only for gapless attention profiles: with a geometric gap both budgets are
bounded by one constant, while the flat profile makes the excess unbounded.  The NET-89
verdict is therefore a measurement of the model's spectrum, not of the corpus mixture. -/
theorem fair_comparison_dichotomy (hτ0 : 0 < τ) (hτ : τ < 1) :
    (∃ C : ℕ, ∀ n : ℕ, 1 ≤ n →
        kstar (mix (fun i => (1 / 2 : ℝ) ^ i) (fun i => (1 / 2 : ℝ) ^ i)) (2 * n) τ ≤ C ∧
          kstar (fun i => (1 / 2 : ℝ) ^ i) (2 * n) τ ≤ C) ∧
      (∀ K : ℕ, ∃ n : ℕ, 0 < n ∧
        K < kstar (mix (fun _ => (1 : ℝ)) (fun _ => (1 : ℝ))) (2 * n) τ
              - kstar (fun _ => (1 : ℝ)) n τ) := by
  have hdec : ∀ i : ℕ, (1 / 2 : ℝ) ^ (i + 1) ≤ 1 / 2 * (1 / 2 : ℝ) ^ i := by
    intro i; rw [pow_succ]; exact le_of_eq (by ring)
  refine ⟨?_, fun K => mixed_minus_pure_unbounded_for_flat hτ0 hτ.le K⟩
  exact mixed_and_pure_budgets_bounded_of_geometric_decay (fun i => by positivity)
    (fun i => by positivity) (r := 1 / 2) (by norm_num) (by norm_num) hdec hdec hτ

end Catalog.Probability.NET89MixedDomainKnee