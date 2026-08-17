/-
# The resolution theory of a doubling sweep ladder: the knee as a Galois adjoint, and
# matching upper and lower bounds on amplitude identifiability (NET-46, cycle 3)

`Logic.KneeAmplitudeIdentifiability` shows that the *four* measured rungs of the NET-44 /
NET-46 ladder pin the Zipf amplitude of `Probability.AttentionCostLaw` to `(14, 16]` at
seed 1 and to *nothing at all* at seed 2.  Both statements are instances of a general
question about the experimental design itself:

> how fast does a step-`s` sweep, repeated at doubling context, identify the amplitude of
> a multiplicative knee law — and can it ever identify it exactly?

This file answers with a matched pair of bounds, and exhibits the order-theoretic
structure that makes the analysis possible.

**1.  The knee is a left adjoint.**  For a monotone retained curve `c`, the grid-free knee
`kneeInf c b = sInf {k | b ≤ c k}` satisfies `kneeInf c b ≤ k ↔ b ≤ c k`
(`KneeResolution.kneeInf_le_iff`): a Galois connection between bars and budgets
(`KneeResolution.knee_galoisConnection`).  Every structural fact used in the two-seed
analysis — monotonicity of the knee in the bar, the antitone dependence on the curve, the
fact that a sweep can only certify upper bounds — is a formal consequence.
`KneeResolution.isKnee_iff_rounding` identifies the *grid* knee of
`KneeFluctuation.IsKnee` as the rounding of `kneeInf` up to the sweep grid, which is the
exact sense in which the measured `224` is a quantisation of a real number.

**2.  Upper bound (identifiability).**  Rung `i` confines the amplitude to a window of
width `s/2^i`, so two amplitudes explaining the *same* rung differ by less than `s/2^i`
(`KneeResolution.amplitude_resolution`), and two amplitudes explaining *all* rungs are
equal (`KneeResolution.amplitude_unique_of_all_rungs`).  An unbounded doubling ladder
therefore identifies the amplitude exactly — a genuinely infinite-precision conclusion
from a fixed-step grid.

**3.  Lower bound (indistinguishability).**  The rate above cannot be beaten:
`KneeResolution.exists_indistinguishable_amplitude` produces, for every `N`, an amplitude
`A ≠ 16` with `|A - 16| = 16/2^N` that reproduces **every** reported knee of the product
law on rungs `1, …, N`.  So after `N` doublings the amplitude is known to within
`s/2^N = 32/2^N` and no better than `16/2^N`: the two bounds match to a factor `2`, and
the resolution improves *geometrically, not faster*.

**Consequences for NET-46.**  The seed-1 window `(14, 16]` is exactly the rung-4
resolution `32/2^4 = 2`; the round's `16×` cell could not have done better, and the
`0.5`-wide window that would separate `A = 16` from `A = 15.5` needs `ctx = 8192`.  The
seed-2 conflict, by contrast, is *not* a resolution problem: two windows of the achievable
width are already disjoint (`KneeAmplitude.seed2_no_common_amplitude`), so more context at
one seed cannot repair it — only a third seed can.
-/

import Mathlib
import Logic.KneeFluctuationTwoSeed
import Logic.KneeAmplitudeIdentifiability

namespace KneeResolution

open Finset KneeFluctuation KneeAmplitude

/-! ## 1.  The knee functional as a Galois adjoint -/

/-- The grid-free knee of a curve at a bar: the least budget reaching the bar. -/
noncomputable def kneeInf (c : ℕ → ℝ) (b : ℝ) : ℕ := sInf {k | b ≤ c k}

/-- **The adjunction.**  For a monotone curve whose bar is eventually reached,
`kneeInf c b ≤ k` is equivalent to `b ≤ c k`.  Reading it left to right is "a budget above
the knee passes"; right to left is "a passing budget bounds the knee" — the only kind of
statement a sweep can certify. -/
theorem kneeInf_le_iff {c : ℕ → ℝ} {b : ℝ} (hc : Monotone c) (hne : ∃ k, b ≤ c k)
    (k : ℕ) : kneeInf c b ≤ k ↔ b ≤ c k := by
  constructor
  · intro h
    have hmem : kneeInf c b ∈ {k | b ≤ c k} := Nat.sInf_mem hne
    exact hmem.trans (hc h)
  · intro h
    exact Nat.sInf_le h

/-- **The knee is the left adjoint of the retained curve.**  For a monotone curve that
reaches every bar, `kneeInf c ⊣ c` is a Galois connection between bars (ordered by `≤`)
and budgets (ordered by `≤`). -/
theorem knee_galoisConnection {c : ℕ → ℝ} (hc : Monotone c)
    (hall : ∀ b : ℝ, ∃ k, b ≤ c k) : GaloisConnection (kneeInf c) c :=
  fun b k => kneeInf_le_iff hc (hall b) k

/-- A curve realising the hypotheses of the adjunction, so the statement is not empty. -/
theorem knee_galoisConnection_nonvacuous :
    GaloisConnection (kneeInf (fun k : ℕ => (k : ℝ))) (fun k : ℕ => (k : ℝ)) := by
  refine knee_galoisConnection (fun a b hab => by exact_mod_cast hab) (fun b => ?_)
  exact ⟨⌈b⌉₊, Nat.le_ceil b⟩

/-- Raising the bar cannot lower the knee: monotonicity, free from the adjunction. -/
theorem kneeInf_mono {c : ℕ → ℝ} (hc : Monotone c) (hall : ∀ b : ℝ, ∃ k, b ≤ c k) :
    Monotone (kneeInf c) :=
  (knee_galoisConnection hc hall).monotone_l

/-- Dominating curves have smaller knees: the seed-2-curve-sits-higher argument, in its
grid-free form. -/
theorem kneeInf_antitone_in_curve {c c' : ℕ → ℝ} {b : ℝ} (hne : ∃ k, b ≤ c k)
    (hdom : ∀ k, c k ≤ c' k) : kneeInf c' b ≤ kneeInf c b := by
  have hmem : b ≤ c (kneeInf c b) := Nat.sInf_mem hne
  exact Nat.sInf_le (hmem.trans (hdom _))

/-- **The grid knee is the rounding of the true knee.**  On a sweep grid `G`, the measured
knee is exactly the least grid point at or above `kneeInf c bar`.  So `IsKnee` carries no
information about the curve beyond `kneeInf`, and every one-grid-step debate is a debate
about a rounding. -/
theorem isKnee_iff_rounding {G : Finset ℕ} {barv : ℝ} {c : ℕ → ℝ} {k : ℕ}
    (hc : Monotone c) (hne : ∃ j, barv ≤ c j) :
    IsKnee G barv c k ↔
      (k ∈ G ∧ kneeInf c barv ≤ k ∧ ∀ j ∈ G, kneeInf c barv ≤ j → k ≤ j) := by
  unfold IsKnee
  rw [kneeInf_le_iff hc hne k]
  constructor
  · rintro ⟨hk, hpass, hmin⟩
    refine ⟨hk, hpass, fun j hj hle => hmin j hj ?_⟩
    exact (kneeInf_le_iff hc hne j).1 hle
  · rintro ⟨hk, hpass, hmin⟩
    refine ⟨hk, hpass, fun j hj hpj => hmin j hj ?_⟩
    exact (kneeInf_le_iff hc hne j).2 hpj

/-! ## 2.  Upper bound: a doubling ladder identifies the amplitude -/

/-- **Rung resolution.**  Two amplitudes explaining the same reported knee at rung `i`
differ by less than `s/2^i`: the window width halves at every doubling. -/
theorem amplitude_resolution {s k A A' : ℝ} {i : ℕ}
    (h : ExplainsRung (k - s) k i A) (h' : ExplainsRung (k - s) k i A') :
    |A - A'| < s / 2 ^ i := by
  have hpos : (0 : ℝ) < 2 ^ i := by positivity
  obtain ⟨h1, h2⟩ := h
  obtain ⟨h1', h2'⟩ := h'
  have k1 : (A - A') * 2 ^ i < s := by nlinarith
  have k2 : (A' - A) * 2 ^ i < s := by nlinarith
  rw [abs_lt]
  refine ⟨?_, (lt_div_iff₀ hpos).2 k1⟩
  have := (lt_div_iff₀ hpos).2 k2
  linarith

/-- The resolution at the NET-46 rung is exactly `2`: the seed-1 amplitude window
`(14, 16]` is as narrow as a step-`32` sweep at `ctx = 2048` can possibly be. -/
theorem net46_rung_resolution : (32 : ℝ) / 2 ^ 4 = 2 := by norm_num

/-- **Exact identifiability in the limit.**  Two amplitudes explaining *every* rung of the
doubling ladder are equal: an unbounded ladder of fixed-step sweeps determines the
amplitude of a multiplicative knee law exactly. -/
theorem amplitude_unique_of_all_rungs {s : ℝ} {K : ℕ → ℝ} {A A' : ℝ}
    (h : ∀ i, ExplainsRung (K i - s) (K i) i A)
    (h' : ∀ i, ExplainsRung (K i - s) (K i) i A') : A = A' := by
  by_contra hne
  have hd : 0 < |A - A'| := abs_pos.mpr (sub_ne_zero.mpr hne)
  obtain ⟨n, hn⟩ : ∃ n : ℕ, s / |A - A'| < 2 ^ n := pow_unbounded_of_one_lt _ (by norm_num)
  have hres := amplitude_resolution (h n) (h' n)
  have hpos : (0 : ℝ) < 2 ^ n := by positivity
  rw [div_lt_iff₀ hd] at hn
  rw [lt_div_iff₀ hpos] at hres
  linarith

/-! ## 3.  Lower bound: the rate cannot be beaten -/

/-- The product law's own reported knee at rung `j + 1` is `32 · 2^j`. -/
theorem gridKnee_productLaw (j : ℕ) :
    gridKnee 32 (16 * 2 ^ (j + 1)) = 32 * 2 ^ j := by
  have hone : 1 ≤ 2 ^ j := Nat.one_le_two_pow
  have hcast : ((2 ^ j - 1 : ℕ) : ℝ) = 2 ^ j - 1 := by
    push_cast [hone]
    ring
  have h := gridKnee_eq_of_mem_Ioc (s := 32) (κ := 16 * 2 ^ (j + 1)) (n := 2 ^ j - 1)
    (by norm_num) ?_ ?_
  · rw [h, hcast]; ring
  · rw [hcast]; ring_nf; nlinarith [pow_pos (by norm_num : (0:ℝ) < 2) j]
  · rw [hcast]; ring_nf; nlinarith [pow_pos (by norm_num : (0:ℝ) < 2) j]

/-- **Indistinguishability after `N` doublings.**  For every `N` there is an amplitude
`A = 16 - 16/2^N`, distinct from the product law's `16` yet reproducing the law's reported
knee at *every* rung `1, …, N` of the step-`32` sweep.  So `N` doublings cannot resolve the
amplitude better than `16/2^N`, matching the upper bound `32/2^N` of
`amplitude_resolution` to a factor `2`. -/
theorem exists_indistinguishable_amplitude (N : ℕ) :
    ∃ A : ℝ, A ≠ 16 ∧ |A - 16| = 16 / 2 ^ N ∧
      ∀ j, j < N → gridKnee 32 (A * 2 ^ (j + 1)) = gridKnee 32 (16 * 2 ^ (j + 1)) := by
  have hNpos : (0 : ℝ) < 2 ^ N := by positivity
  have hpos16 : (0 : ℝ) < 16 / 2 ^ N := by positivity
  have hA : (16 : ℝ) - 16 / 2 ^ N ≠ 16 := by
    intro h
    have hz : (16 : ℝ) / 2 ^ N = 0 := by linarith
    exact absurd hz (ne_of_gt hpos16)
  refine ⟨16 - 16 / 2 ^ N, hA, ?_, ?_⟩
  · rw [show (16 : ℝ) - 16 / 2 ^ N - 16 = -(16 / 2 ^ N) by ring, abs_neg,
      abs_of_nonneg (by positivity)]
  · intro j hj
    have hjpos : (0 : ℝ) < 2 ^ j := by positivity
    have hNne : (2 : ℝ) ^ N ≠ 0 := ne_of_gt hNpos
    have hlt : (2 : ℝ) ^ j < 2 ^ N := pow_lt_pow_right₀ (by norm_num) hj
    have hone : 1 ≤ 2 ^ j := Nat.one_le_two_pow
    have hcast : ((2 ^ j - 1 : ℕ) : ℝ) = 2 ^ j - 1 := by
      push_cast [hone]; ring
    have key : (16 - 16 / (2 : ℝ) ^ N) * 2 ^ (j + 1)
        = 32 * 2 ^ j - 32 * (2 ^ j / 2 ^ N) := by
      have hsplit : (2 : ℝ) ^ (j + 1) = 2 * 2 ^ j := by ring
      rw [hsplit]; field_simp; ring
    have hfrac1 : (2 : ℝ) ^ j / 2 ^ N < 1 := by rw [div_lt_one hNpos]; exact hlt
    have hfrac0 : (0 : ℝ) < 2 ^ j / 2 ^ N := by positivity
    rw [gridKnee_productLaw j]
    have h := gridKnee_eq_of_mem_Ioc (s := 32)
      (κ := (16 - 16 / 2 ^ N) * 2 ^ (j + 1)) (n := 2 ^ j - 1) (by norm_num) ?_ ?_
    · rw [h, hcast]; ring
    · rw [hcast, key]; linarith
    · rw [hcast, key]; linarith

/-- **The matched rate.**  After `N` doublings a step-`32` ladder pins the amplitude to a
window of width `32/2^N` and to no window narrower than `16/2^N`.  Identification is
geometric in the number of doublings and the two constants differ by a factor `2`. -/
theorem resolution_rate_matched (N : ℕ) :
    (16 : ℝ) / 2 ^ N ≤ (32 : ℝ) / 2 ^ N ∧
      (32 : ℝ) / 2 ^ N = 2 * ((16 : ℝ) / 2 ^ N) := by
  have hpos : (0 : ℝ) < 2 ^ N := by positivity
  constructor
  · gcongr
    norm_num
  · ring

/-- **Cost of the next bit of amplitude precision.**  Separating `A = 16` from
`A = 15.5` — the finest distinction the seed-1 data leaves open at the low end of its
window — requires a resolution below `1/2`, hence at least rung `6`, i.e. `ctx = 8192`:
two further doublings beyond NET-46. -/
theorem next_bit_needs_ctx_8192 :
    (∀ i : ℕ, (32 : ℝ) / 2 ^ i < 1 / 2 → 6 ≤ i) ∧ 128 * 2 ^ 6 = 8192 := by
  constructor
  · intro i hi
    by_contra hcon
    push_neg at hcon
    interval_cases i <;> norm_num at hi
  · norm_num

/-- **The seed-2 conflict is not a resolution problem.**  The two seed-2 windows are
disjoint while each has the width the design allows, so no amount of extra context at
either seed can reconcile them: the missing measurement is a *third seed*, not a longer
run.  (Formally: a common amplitude is impossible, yet each rung admits one.) -/
theorem seed2_conflict_irreparable_by_context :
    (¬ ∃ A : ℝ, ExplainsRung 64 96 3 A ∧ ExplainsRung 192 224 4 A) ∧
      (∃ A : ℝ, ExplainsRung 64 96 3 A) ∧ (∃ A : ℝ, ExplainsRung 192 224 4 A) :=
  ⟨seed2_no_common_amplitude, ⟨10, seed2_each_rung_explainable.1⟩,
    ⟨13, seed2_each_rung_explainable.2⟩⟩

end KneeResolution