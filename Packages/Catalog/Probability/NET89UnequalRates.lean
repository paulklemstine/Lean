import Probability.NET89SpectralEstimator

/-!
# NET-89, cycle 11: unequal mixing rates and the rarest-domain multiplier

Cycle 3 proved that a strict `m`-fold round robin multiplies the context-doubling
increment by exactly `m`.  Real mixtures are not balanced, and the standing conjecture
(direction **D4** of that round, restated as **D1** after cycle 7) was that the multiplier
is set by the *rarest* domain: it should be `1 / min_j p_j`, the reciprocal of the smallest
mixing rate, because the knee has to wait for that domain's keys to arrive.

This cycle proves the conjecture for rational rates with unit-numerator minority, i.e. the
periodic pattern in which `s` keys of the first domain alternate with one key of the
second.  There the rates are `p_u = s/(s+1)`, `p_v = 1/(s+1)`, so `1 / min p = s + 1`, and:

* `mixRate` — the unequal-rate interleaving, with `mixRate 1 = mix` (`mixRate_one`), so
  cycle 1 is the balanced special case.
* `poolUneven` — its pooled partner: each pooled key carries a *block* of `s` keys of the
  frequent domain together with one key of the rare one.
* `headMass_mixRate`, `retained_mixRate_aligned` — the reduction: at budgets aligned to the
  period, the unequal-rate mixture is exactly the uneven pool in period-sized key units.
* `kstar_mixRate_bracket` — hence `(s+1)·Q − s ≤ k*_rate ≤ (s+1)·Q`, one period of slack.
* `mixRate_ctxSens_multiplier` — **the rarest-domain multiplier.**  The context-doubling
  increment of the unequal mixture is `(s+1)` times the pooled increment, up to `s` keys:
  the multiplier is the period `s + 1 = 1 / min_j p_j`, *not* the number of domains, which
  is `2` regardless of `s`.  Cycle 3's multiplier `m` is the balanced case `s = 1`.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 11):
 (H1) An `s : 1` interleaving reduces, at period-aligned budgets, to a pool whose keys
      bundle `s` frequent-domain keys with one rare-domain key.                [BOLD]
 (H2) Hence the increment multiplier is the period `s + 1`, i.e. the reciprocal of the
      rarest rate — refuting "multiplier = number of domains" as the general law. [BOLD]
 (H3) The balanced case `s = 1` recovers cycle 1 exactly.

Experimenter: H1–H3 formalised below, zero sorries.  `mixRate_one` checks H3 definitionally
against cycle 1's `mix`.

Analyst: this settles which of the two candidate explanations of NET-89's "+8 versus +4" is
right.  It is *not* the number of content types (that stays `2` however the rates are
chosen); it is the granularity of the interleaving pattern.  A 90/10 code/prose mixture
should therefore show a *tenfold*, not twofold, increment — the sharpest experimental
prediction produced in this programme so far.

Critic: the theorem covers rational rates whose minority share is `1/(s+1)`; a general
Beatty-type pattern is not covered, and the statement says so by fixing the pattern
explicitly rather than quantifying over rate vectors.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v : ℕ → ℝ} {τ : ℝ} {s n k : ℕ}

/-! ## 1. Unequal-rate interleaving and its pooled partner -/

/-- **Unequal-rate interleaving.**  Each period of `s + 1` keys carries `s` keys of the
first domain followed by one key of the second: rates `s/(s+1)` and `1/(s+1)`. -/
noncomputable def mixRate (s : ℕ) (u v : ℕ → ℝ) : ℕ → ℝ := fun i =>
  if i % (s + 1) < s then u (s * (i / (s + 1)) + i % (s + 1)) else v (i / (s + 1))

/-- The pooled partner of an unequal-rate mixture: one pooled key bundles the `s` keys of
the frequent domain that share a period with a single key of the rare domain. -/
noncomputable def poolUneven (s : ℕ) (u v : ℕ → ℝ) : ℕ → ℝ := fun i =>
  (∑ t ∈ range s, u (s * i + t)) + v i

/-- Consistency with cycle 1: rate `1 : 1` is plain alternation. -/
lemma mixRate_one (u v : ℕ → ℝ) : mixRate 1 u v = mix u v := by
  funext i
  simp only [mixRate, mix]
  by_cases h : i % 2 = 0
  · simp [h]
  · have h1 : i % 2 = 1 := by omega
    simp [h1]

lemma mixRate_pos (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (s : ℕ) :
    ∀ i, 0 < mixRate s u v i := by
  intro i; simp only [mixRate]; split
  · exact hu _
  · exact hv _

lemma poolUneven_pos (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (s : ℕ) :
    ∀ i, 0 < poolUneven s u v i := by
  intro i
  have h1 : (0 : ℝ) ≤ ∑ t ∈ range s, u (s * i + t) :=
    Finset.sum_nonneg fun t _ => (hu _).le
  have h2 := hv i
  simp only [poolUneven]
  linarith

/-! ## 2. The period-aligned reduction -/

lemma mixRate_frequent (hi : k < s) (q : ℕ) :
    mixRate s u v ((s + 1) * q + k) = u (s * q + k) := by
  have h1 : ((s + 1) * q + k) / (s + 1) = q := by
    rw [Nat.mul_add_div (by omega), Nat.div_eq_of_lt (by omega), Nat.add_zero]
  have h2 : ((s + 1) * q + k) % (s + 1) = k := by
    rw [Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]
  simp [mixRate, h1, h2, hi]

lemma mixRate_rare (q : ℕ) : mixRate s u v ((s + 1) * q + s) = v q := by
  have h1 : ((s + 1) * q + s) / (s + 1) = q := by
    rw [Nat.mul_add_div (by omega), Nat.div_eq_of_lt (by omega), Nat.add_zero]
  have h2 : ((s + 1) * q + s) % (s + 1) = s := by
    rw [Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]
  simp [mixRate, h1, h2]

lemma headMass_poolUneven (s : ℕ) (u v : ℕ → ℝ) (k : ℕ) :
    headMass (poolUneven s u v) k = headMass u (s * k) + headMass v k := by
  induction k with
  | zero => simp [headMass]
  | succ k ih =>
      have e1 : headMass (poolUneven s u v) (k + 1)
          = headMass (poolUneven s u v) k + poolUneven s u v k := by
        simp [headMass, Finset.sum_range_succ]
      have e2 : headMass u (s * (k + 1)) = headMass u (s * k) + ∑ t ∈ range s, u (s * k + t) := by
        have e : s * (k + 1) = s * k + s := by ring
        rw [e]
        simp [headMass, Finset.sum_range_add]
      have e3 : headMass v (k + 1) = headMass v k + v k := by
        simp [headMass, Finset.sum_range_succ]
      rw [e1, ih, e2, e3, poolUneven]
      ring

/-- **The unequal-rate reduction.**  A period-aligned prefix of the mixture contains the
matched prefixes of both domains, in the ratio `s : 1`. -/
lemma headMass_mixRate (s : ℕ) (u v : ℕ → ℝ) (k : ℕ) :
    headMass (mixRate s u v) ((s + 1) * k) = headMass u (s * k) + headMass v k := by
  induction k with
  | zero => simp [headMass]
  | succ k ih =>
      have e1 : (s + 1) * (k + 1) = (s + 1) * k + s + 1 := by ring
      have hfreq : ∀ t ∈ range s, mixRate s u v ((s + 1) * k + t) = u (s * k + t) :=
        fun t ht => mixRate_frequent (mem_range.mp ht) k
      have e2 : headMass (mixRate s u v) ((s + 1) * k + s)
          = headMass (mixRate s u v) ((s + 1) * k) + ∑ t ∈ range s, u (s * k + t) := by
        simp only [headMass, Finset.sum_range_add]
        rw [Finset.sum_congr rfl hfreq]
      have e3 : headMass (mixRate s u v) ((s + 1) * k + s + 1)
          = headMass (mixRate s u v) ((s + 1) * k + s) + mixRate s u v ((s + 1) * k + s) := by
        simp [headMass, Finset.sum_range_succ]
      have e4 : headMass u (s * (k + 1)) = headMass u (s * k) + ∑ t ∈ range s, u (s * k + t) := by
        have e : s * (k + 1) = s * k + s := by ring
        rw [e]
        simp [headMass, Finset.sum_range_add]
      have e5 : headMass v (k + 1) = headMass v k + v k := by
        simp [headMass, Finset.sum_range_succ]
      rw [e1, e3, e2, ih, mixRate_rare, e4, e5]
      ring

lemma retained_mixRate_aligned (s : ℕ) (u v : ℕ → ℝ) (n k : ℕ) :
    retained (mixRate s u v) ((s + 1) * n) ((s + 1) * k) = retained (poolUneven s u v) n k := by
  rw [retained, retained, min_mul_left, headMass_mixRate, headMass_mixRate,
    headMass_poolUneven, headMass_poolUneven]

/-! ## 3. The rarest-domain multiplier -/

/-- **The unequal-rate knee bracket.**  In period-sized key units the unequal mixture's knee
is the uneven pooled knee, up to one period of slack. -/
theorem kstar_mixRate_bracket (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    (s + 1) * kstar (poolUneven s u v) n τ ≤ kstar (mixRate s u v) ((s + 1) * n) τ + s ∧
      kstar (mixRate s u v) ((s + 1) * n) τ ≤ (s + 1) * kstar (poolUneven s u v) n τ := by
  have hpp : ∀ i, 0 < poolUneven s u v i := poolUneven_pos hu hv s
  have hrp : ∀ i, 0 < mixRate s u v i := mixRate_pos hu hv s
  set Q := kstar (poolUneven s u v) n τ with hQ
  set M := kstar (mixRate s u v) ((s + 1) * n) τ with hM
  have hup : M ≤ (s + 1) * Q := by
    apply kstar_le_of_pass
    rw [retained_mixRate_aligned]
    exact gate_le_retained_kstar hpp hn hτ
  refine ⟨?_, hup⟩
  by_contra hcon
  push_neg at hcon
  have hQ1 : 1 ≤ Q := by
    rcases Nat.eq_zero_or_pos Q with h | h
    · rw [h, Nat.mul_zero] at hcon; omega
    · exact h
  have hle : M ≤ (s + 1) * (Q - 1) := by
    have hms : (s + 1) * (Q - 1) = (s + 1) * Q - (s + 1) := by rw [Nat.mul_sub]; omega
    omega
  have hpass : τ ≤ retained (mixRate s u v) ((s + 1) * n) M :=
    gate_le_retained_kstar hrp (Nat.mul_pos (by omega) hn) hτ
  have hpass2 : τ ≤ retained (mixRate s u v) ((s + 1) * n) ((s + 1) * (Q - 1)) :=
    le_trans hpass (retained_mono hrp _ hle)
  rw [retained_mixRate_aligned] at hpass2
  have := kstar_le_of_pass (w := poolUneven s u v) (n := n) (τ := τ) hpass2
  omega

/-- **The rarest-domain multiplier.**  For an `s : 1` interleaving the context-doubling
increment is multiplied by the *period* `s + 1`, which is the reciprocal of the rarest
domain's rate — not by the number of domains, which is `2` for every `s`.  Cycle 1's
doubling law is the balanced case `s = 1`. -/
theorem mixRate_ctxSens_multiplier (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    (s + 1) * ctxSens (poolUneven s u v) τ n
        ≤ ctxSens (mixRate s u v) τ ((s + 1) * n) + s ∧
      ctxSens (mixRate s u v) τ ((s + 1) * n)
        ≤ (s + 1) * ctxSens (poolUneven s u v) τ n + s := by
  have hpp : ∀ i, 0 < poolUneven s u v i := poolUneven_pos hu hv s
  have hrp : ∀ i, 0 < mixRate s u v i := mixRate_pos hu hv s
  obtain ⟨l1, u1⟩ := kstar_mixRate_bracket (s := s) hu hv hn hτ
  obtain ⟨l2, u2⟩ := kstar_mixRate_bracket (s := s) (n := 2 * n) hu hv (by omega) hτ
  have e2 : (s + 1) * (2 * n) = 2 * ((s + 1) * n) := by ring
  rw [e2] at l2 u2
  have hmono1 : kstar (poolUneven s u v) n τ ≤ kstar (poolUneven s u v) (2 * n) τ :=
    kstar_mono_ctx hpp hτ hn (by omega)
  have hmono2 : kstar (mixRate s u v) ((s + 1) * n) τ
      ≤ kstar (mixRate s u v) (2 * ((s + 1) * n)) τ :=
    kstar_mono_ctx hrp hτ (Nat.mul_pos (by omega) hn) (by omega)
  have hmul : (s + 1) * (kstar (poolUneven s u v) (2 * n) τ - kstar (poolUneven s u v) n τ)
      = (s + 1) * kstar (poolUneven s u v) (2 * n) τ
        - (s + 1) * kstar (poolUneven s u v) n τ := Nat.mul_sub (s + 1) _ _
  have hmle : (s + 1) * kstar (poolUneven s u v) n τ
      ≤ (s + 1) * kstar (poolUneven s u v) (2 * n) τ := Nat.mul_le_mul_left _ hmono1
  simp only [ctxSens]
  omega

end Catalog.Probability.NET89MixedDomainKnee