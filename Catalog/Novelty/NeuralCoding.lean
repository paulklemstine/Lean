import Mathlib

/-!
# Brain–Computer Interface Mathematics: Neural Coding Theorems

This file develops, from first principles, a small but interconnected theory of
**neural coding** — how a population of neurons can represent information.  The
development is a "builder" chain: each result is proved completely and later
results are stated and proved *using* the earlier ones.

## Model

A **neural code** on `N` neurons is a binary activity pattern, i.e. an element of
`Fin N → Bool` (`true` = the neuron is spiking / active, `false` = silent).  We
write `NeuralCode N` for this type.  The **support** of a code is the set of
active neurons and its **weight** (= metabolic **energy**, one unit per spike)
is the number of active neurons.

## Results (the chain)

1. `card_neuralCode` — there are exactly `2 ^ N` distinct codes: the *coding
   capacity* of `N` binary neurons is `2 ^ N`.
2. `concept_capacity_bound` — any injective encoding of a set of concepts into
   codes can distinguish at most `2 ^ N` concepts (uses 1).
3. `capacity_tight` — and `2 ^ N` concepts *can* be encoded: there is a bijection
   `Fin (2 ^ N) ≃ NeuralCode N` (uses 1).
4. `card_neuralCode_succ` — adding one neuron doubles the capacity (uses 1).
5. `weight_le` — a code activates at most `N` neurons.
6. `card_active_coord` — a fixed neuron is active in exactly half (`2 ^ (N-1)`)
   of all codes.
7. `total_weight` / `average_weight` — the *average* weight of a dense code is
   `N / 2` (uses 6): dense coding spends `N / 2` spikes per concept.
8. `card_sparse` — there are exactly `N.choose k` codes of weight `k`
   (the *sparse* codes), and in particular `card_grandmother` gives `N`
   one‑hot ("grandmother cell") codes (uses 8).
9. Population coding: `popPrecision_eq`, `popPrecision_quarter`,
   `popPrecision_antitone` — averaging `N` noisy neurons gives error `∝ 1/√N`,
   so precision improves like `√N` and quadrupling the population halves the
   error.
10. Sparse energy efficiency: `denseRate_eq`, `sparseRate_eq`,
    `sparse_more_efficient`, `sparse_rate_tendsto_atTop` — one‑hot sparse coding
    delivers `log₂ N` bits per spike versus `2` bits per spike for dense coding,
    an unbounded (`Θ(log N)`) energy‑efficiency advantage (uses 7 and 8).
11. Neural manifold hypothesis: `neural_manifold_dim_le_dof` — if population
    activity is driven linearly by `d` behavioural degrees of freedom, the
    neural manifold (the span of reachable activity) has dimension at most `d`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the information a neural population can carry is
governed by simple combinatorics of binary patterns; sparsity trades raw
capacity for energy efficiency, and the geometry of behaviour caps the geometry
of neural activity.

Experiment (Experimenter): we modelled a code as `Fin N → Bool`, counted states
exactly (`2 ^ N`), counted weight-`k` states (`N.choose k`) via a bijection with
`powersetCard`, and computed the mean weight (`N / 2`) by double counting.  The
population-coding law is the algebraic core of the variance-of-the-mean
computation, and the manifold bound is the rank–nullity bound for the linear
behaviour→activity map.

Analysis (Analyst): the binary model is deliberately lossy (no weights, no
timing) yet already yields capacity, the sparse-coding efficiency gain, and the
dimensional cap; richer models only refine these.
-/

namespace NeuralCoding

open Finset

/-- A **neural code** on `N` neurons: a binary activity pattern, `true` meaning
the neuron is active/spiking. -/
abbrev NeuralCode (N : ℕ) : Type := Fin N → Bool

/-- The set of **active** neurons of a code (its support). -/
def active {N : ℕ} (c : NeuralCode N) : Finset (Fin N) :=
  Finset.univ.filter (fun i => c i = true)

/-- The **weight** of a code: the number of active neurons.  This is also the
metabolic **energy** it costs (one unit per spike). -/
def weight {N : ℕ} (c : NeuralCode N) : ℕ := (active c).card

/-- The energy cost of a code equals its weight (one unit of energy per spike). -/
def energy {N : ℕ} (c : NeuralCode N) : ℕ := weight c

/-! ## 1–4. Coding capacity of `N` binary neurons -/

/-- **Coding capacity.** There are exactly `2 ^ N` distinct neural codes on `N`
neurons: `N` binary neurons can represent at most `2 ^ N` distinct concepts. -/
theorem card_neuralCode (N : ℕ) : Fintype.card (NeuralCode N) = 2 ^ N := by
  simp

/-- **Capacity is an upper bound.** Any injective encoding of a (finite) set of
concepts `α` into neural codes on `N` neurons can distinguish at most `2 ^ N`
concepts. -/
theorem concept_capacity_bound {N : ℕ} {α : Type*} [Fintype α]
    (enc : α → NeuralCode N) (hInj : Function.Injective enc) :
    Fintype.card α ≤ 2 ^ N := by
  have h := Fintype.card_le_of_injective enc hInj
  rwa [card_neuralCode] at h

/-- **Capacity is achieved.** There is a bijection between `Fin (2 ^ N)` and the
neural codes on `N` neurons, so exactly `2 ^ N` concepts can be encoded. -/
theorem capacity_tight (N : ℕ) : Nonempty (Fin (2 ^ N) ≃ NeuralCode N) := by
  apply Fintype.card_eq.mp
  rw [card_neuralCode]
  simp

/-- **One extra neuron doubles capacity.** -/
theorem card_neuralCode_succ (N : ℕ) :
    Fintype.card (NeuralCode (N + 1)) = 2 * Fintype.card (NeuralCode N) := by
  rw [card_neuralCode, card_neuralCode, pow_succ]; ring

/-! ## 5–7. Weight, symmetry and the average (dense) energy cost -/

/-- A code activates at most `N` neurons. -/
theorem weight_le {N : ℕ} (c : NeuralCode N) : weight c ≤ N := by
  unfold weight active
  calc (Finset.univ.filter (fun i => c i = true)).card
      ≤ (Finset.univ : Finset (Fin N)).card := Finset.card_filter_le _ _
    _ = N := by simp

/-- **Coordinate symmetry.** A fixed neuron `i` is active in exactly half of all
codes: `2 ^ (N - 1)` of the `2 ^ N` codes. -/
theorem card_active_coord {N : ℕ} (hN : 1 ≤ N) (i : Fin N) :
    (Finset.univ.filter (fun c : NeuralCode N => c i = true)).card = 2 ^ (N - 1) := by
  -- flipping neuron `i` to `false` matches active-codes with silent-codes
  have hbij : (Finset.univ.filter (fun c : NeuralCode N => c i = true)).card
      = (Finset.univ.filter (fun c : NeuralCode N => c i = false)).card := by
    apply Finset.card_bij (fun c _ => Function.update c i false)
    · intro c hc; simp only [mem_filter, mem_univ, true_and] at *; simp
    · intro a ha b hb hab
      simp only [mem_filter, mem_univ, true_and] at ha hb
      funext j
      by_cases hj : j = i
      · subst hj; rw [ha, hb]
      · have := congrFun hab j; simpa [Function.update_of_ne hj] using this
    · intro c hc; simp only [mem_filter, mem_univ, true_and] at hc
      refine ⟨Function.update c i true, ?_, ?_⟩
      · simp
      · funext j; by_cases hj : j = i
        · subst hj; simp [hc]
        · simp [Function.update_of_ne hj]
  have hfn : (Finset.univ.filter (fun c : NeuralCode N => ¬ (c i = true)))
      = (Finset.univ.filter (fun c : NeuralCode N => c i = false)) := by
    apply Finset.filter_congr; intro c _; simp [Bool.not_eq_true]
  have key := Finset.card_filter_add_card_filter_not
      (s := (Finset.univ : Finset (NeuralCode N))) (fun c => c i = true)
  rw [hfn, Finset.card_univ] at key
  have hcard : Fintype.card (NeuralCode N) = 2 ^ N := card_neuralCode N
  rw [hcard, ← hbij] at key
  have h2 : 2 ^ N = 2 * 2 ^ (N - 1) := by
    conv_lhs => rw [show N = (N - 1) + 1 by omega]
    rw [pow_succ]; ring
  omega

/-- **Total (dense) weight.** Summing the weights over *all* `2 ^ N` codes gives
`N · 2 ^ (N-1)`.  Equivalently the average weight of a dense code is `N / 2`:
dense coding spends about `N / 2` spikes per concept. -/
theorem total_weight (N : ℕ) :
    ∑ c : NeuralCode N, weight c = N * 2 ^ (N - 1) := by
  rcases Nat.eq_zero_or_pos N with hN | hN
  · subst hN; simp [weight, active]
  · unfold weight active
    simp only [Finset.card_filter]
    rw [Finset.sum_comm]
    have hcoord : ∀ i : Fin N, ∑ c : NeuralCode N, (if c i = true then 1 else 0)
        = 2 ^ (N - 1) := by
      intro i; rw [← Finset.card_filter]; exact card_active_coord hN i
    rw [Finset.sum_congr rfl (fun i _ => hcoord i)]
    simp [Finset.sum_const]

/-- **Average dense energy.** The mean weight (mean energy per concept) of a
dense code, as a real number, is `N / 2`. -/
theorem average_weight (N : ℕ) (hN : 1 ≤ N) :
    (∑ c : NeuralCode N, (weight c : ℝ)) / (2 ^ N : ℝ) = N / 2 := by
  have hsum : ∑ c : NeuralCode N, (weight c : ℝ) = (N : ℝ) * 2 ^ (N - 1) := by
    have h := total_weight N
    calc ∑ c : NeuralCode N, (weight c : ℝ)
          = ((∑ c : NeuralCode N, weight c : ℕ) : ℝ) := by push_cast; rfl
      _ = ((N * 2 ^ (N - 1) : ℕ) : ℝ) := by rw [h]
      _ = (N : ℝ) * 2 ^ (N - 1) := by push_cast; ring
  rw [hsum]
  have h2 : (2 : ℝ) ^ N = 2 * 2 ^ (N - 1) := by
    conv_lhs => rw [show N = (N - 1) + 1 by omega]
    rw [pow_succ]; ring
  rw [h2]
  have hpos : (2 : ℝ) ^ (N - 1) ≠ 0 := by positivity
  field_simp

/-! ## 8. Sparse codes: counting weight-`k` patterns -/

/-- **Sparse code count.** There are exactly `N.choose k` neural codes of weight
`k`.  These are the *sparse* codes: only `k` of the `N` neurons are active. -/
theorem card_sparse (N k : ℕ) :
    (Finset.univ.filter (fun c : NeuralCode N => weight c = k)).card = N.choose k := by
  unfold weight active
  have hpc : ((Finset.univ : Finset (Fin N)).powersetCard k).card = N.choose k := by
    rw [Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin]
  rw [← hpc]
  apply Finset.card_bij (fun c _ => Finset.univ.filter (fun i => c i = true))
  · intro c hc
    simp only [mem_filter, mem_univ, true_and] at hc
    simp only [mem_powersetCard]
    exact ⟨Finset.filter_subset _ _, hc⟩
  · intro a ha b hb hab
    simp only [mem_filter] at ha hb
    funext i
    have hiff : (i ∈ Finset.univ.filter (fun i => a i = true))
        ↔ (i ∈ Finset.univ.filter (fun i => b i = true)) := by rw [hab]
    simp only [mem_filter, mem_univ, true_and] at hiff
    cases hai : a i <;> cases hbi : b i <;> simp_all
  · intro s hs
    simp only [mem_powersetCard] at hs
    refine ⟨fun i => decide (i ∈ s), ?_, ?_⟩
    · simp only [mem_filter, mem_univ, true_and]
      convert hs.2 using 2
      ext i; simp
    · ext i; simp

/-- **Grandmother cells.** There are exactly `N` one‑hot ("grandmother cell")
codes, i.e. codes of weight `1`.  Special case of `card_sparse`. -/
theorem card_grandmother (N : ℕ) :
    (Finset.univ.filter (fun c : NeuralCode N => weight c = 1)).card = N := by
  rw [card_sparse]; exact Nat.choose_one_right N

/-! ## 9. Population coding: precision `∝ √N`

Model: `N` neurons each give an unbiased estimate of a continuous stimulus with
variance `v`.  Averaging `N` independent such estimates yields the *population
estimate*, whose variance is `v / N` (variance of a sum of `N` independent
copies is `N · v`; dividing the sum by `N` scales the variance by `1 / N²`).  The
achievable **precision** is the standard deviation of the population estimate. -/

/-- Variance of the population (averaged) estimate from `N` neurons, each of
variance `v`.  Written as `(N·v)/N²` to expose the variance-of-the-mean
computation; it equals `v / N` (see `popVariance_eq`). -/
noncomputable def popVariance (v : ℝ) (N : ℕ) : ℝ := (N * v) / (N : ℝ) ^ 2

/-- The variance of the population estimate is `v / N`. -/
theorem popVariance_eq (v : ℝ) (N : ℕ) (hN : 1 ≤ N) :
    popVariance v N = v / N := by
  unfold popVariance
  have hNpos : (N : ℝ) ≠ 0 := by exact_mod_cast (by omega : N ≠ 0)
  rw [sq]
  field_simp

/-- **Precision** of a population code: the standard deviation of the population
estimate. -/
noncomputable def popPrecision (v : ℝ) (N : ℕ) : ℝ := Real.sqrt (popVariance v N)

/-- **Precision `∝ 1/√N`.** The population precision equals `√v / √N`: the error
scales like `1 / √N` in the number of neurons. -/
theorem popPrecision_eq (v : ℝ) (N : ℕ) (hv : 0 ≤ v) (hN : 1 ≤ N) :
    popPrecision v N = Real.sqrt v / Real.sqrt N := by
  unfold popPrecision
  rw [popVariance_eq v N hN, Real.sqrt_div hv]

/-- **Quadrupling the population halves the error.** A direct expression of the
`√N` law: to double precision you need four times as many neurons. -/
theorem popPrecision_quarter (v : ℝ) (N : ℕ) (hv : 0 ≤ v) (hN : 1 ≤ N) :
    popPrecision v (4 * N) = popPrecision v N / 2 := by
  rw [popPrecision_eq v (4 * N) hv (by omega), popPrecision_eq v N hv hN]
  have h4 : Real.sqrt (↑(4 * N)) = 2 * Real.sqrt N := by
    have : ((4 * N : ℕ) : ℝ) = (2 : ℝ) ^ 2 * N := by push_cast; ring
    rw [this, Real.sqrt_mul (by positivity), Real.sqrt_sq (by norm_num)]
  rw [h4]
  ring

/-- **More neurons never hurt precision.** For a positive per-neuron variance,
precision (the error) is antitone in the number of neurons. -/
theorem popPrecision_antitone (v : ℝ) (hv : 0 < v) {M N : ℕ}
    (hM : 1 ≤ M) (hMN : M ≤ N) :
    popPrecision v N ≤ popPrecision v M := by
  have hN : 1 ≤ N := le_trans hM hMN
  rw [popPrecision_eq v N hv.le hN, popPrecision_eq v M hv.le hM]
  apply div_le_div_of_nonneg_left (Real.sqrt_nonneg _)
  · exact Real.sqrt_pos.mpr (by exact_mod_cast hM)
  · exact Real.sqrt_le_sqrt (by exact_mod_cast hMN)

/-! ## 10. Sparse coding is energy efficient (`Θ(log N)` bits per spike)

Information is measured in bits, `information m = log₂ m` bits to index `m`
equiprobable concepts.  The **information rate** is bits per unit energy (per
spike).

* Dense coding uses all `2 ^ N` codes, `N` bits of information, at an average
  cost of `N / 2` spikes (`average_weight`): rate `= 2` bits/spike.
* One‑hot sparse coding uses the `N` grandmother codes (`card_grandmother`),
  `log₂ N` bits, at exactly `1` spike each: rate `= log₂ N` bits/spike.

Hence sparse coding beats dense coding once `N ≥ 5`, and its advantage grows
without bound. -/

/-- Information (in bits) needed to index `m` equiprobable concepts. -/
noncomputable def information (m : ℕ) : ℝ := Real.logb 2 m

/-- **Dense information rate** = 2 bits per spike: `N` bits over an average of
`N / 2` spikes. -/
theorem denseRate_eq (N : ℕ) (hN : 1 ≤ N) :
    information (2 ^ N) / (N / 2 : ℝ) = 2 := by
  unfold information
  have hlog : Real.logb 2 ((2 : ℕ) ^ N : ℕ) = N := by
    push_cast
    rw [Real.logb_pow]; simp [Real.logb_self_eq_one]
  rw [hlog]
  have hNne : (N : ℝ) ≠ 0 := by exact_mod_cast (by omega : N ≠ 0)
  field_simp

/-- **Sparse (one‑hot) information rate** = `log₂ N` bits per spike: `log₂ N`
bits over exactly `1` spike. -/
theorem sparseRate_eq (N : ℕ) :
    information N / (1 : ℝ) = Real.logb 2 N := by
  unfold information; ring

/-- **Sparse coding is more energy efficient.** For `N ≥ 5` neurons the one‑hot
sparse information rate `log₂ N` strictly exceeds the dense rate `2`. -/
theorem sparse_more_efficient (N : ℕ) (h : 5 ≤ N) :
    information (2 ^ N) / (N / 2 : ℝ) < information N / (1 : ℝ) := by
  rw [denseRate_eq N (by omega), sparseRate_eq N]
  have h4 : Real.logb 2 4 = 2 := by
    rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.logb_pow]
    simp [Real.logb_self_eq_one]
  have hlt : Real.logb 2 4 < Real.logb 2 N :=
    Real.logb_lt_logb (by norm_num) (by norm_num)
      (by exact_mod_cast lt_of_lt_of_le (by norm_num) h)
  rw [h4] at hlt; exact hlt

/-- **Unbounded advantage.** The sparse information rate `log₂ N` grows without
bound: sparse coding's energy‑efficiency advantage is `Θ(log N)`. -/
theorem sparse_rate_tendsto_atTop :
    Filter.Tendsto (fun N : ℕ => information N) Filter.atTop Filter.atTop := by
  unfold information
  exact (Real.tendsto_logb_atTop (by norm_num)).comp tendsto_natCast_atTop_atTop

/-! ## 11. Neural manifold hypothesis -/

open Module in
/-- **Neural manifold hypothesis.** If population activity in `ℝ^N` is driven
linearly by `d` behavioural degrees of freedom (a linear map from the behaviour
space `ℝ^d`), then the reachable neural activity — the neural manifold, here its
linear span — has dimension at most `d`.  The manifold dimension is bounded by
the number of behavioural degrees of freedom. -/
theorem neural_manifold_dim_le_dof (d N : ℕ)
    (L : (Fin d → ℝ) →ₗ[ℝ] (Fin N → ℝ)) :
    finrank ℝ (LinearMap.range L) ≤ d := by
  have h := LinearMap.finrank_range_le L
  simpa using h

end NeuralCoding