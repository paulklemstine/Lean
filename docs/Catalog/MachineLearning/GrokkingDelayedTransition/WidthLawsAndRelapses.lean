import Mathlib
import MachineLearning.GrokkingDelayedTransition.VectorMargin
import MachineLearning.GrokkingDelayedTransition.SaddleNodeLocal
import MachineLearning.GrokkingDelayedTransition.NextCycle

/-!
# Width laws, relapse counting and the exponent competition

This file closes the three sub-conjectures **(M1)–(M3)** left open at the end of
`NextCycle.lean` (see `FUTURE_DIRECTIONS.md`).  It builds directly on the
definitions of `VectorMargin.lean` (`net`, `netRamp`, `signal`, `relu`),
`SaddleNodeLocal.lean` (`passageTime`) and `NextCycle.lean`.

* **(M1) Concentration width law.**  `zeroBias_sharp_threshold` of the previous
  cycle turned the grokking delay of a zero-bias network into the *deterministic
  functional* `|c| / S_m`, where `S_m = Σ_{j<m} a_j g_j` is the total signal.
  Here `unitDelay_width_law` shows that any Cesàro convergence
  `S_m / m → L > 0` forces the exact width law `m · τ_m → |c| / L`, and
  `iid_width_law_ae` combines this with Mathlib's strong law of large numbers:
  for i.i.d. hidden units with positive mean signal the delay obeys
  `m · τ_m → |c| / E[a g]` almost surely.  `iidNet_sharp_threshold` checks that
  `τ_m` really is the sharp threshold of an honest width-`m` ReLU network.

* **(M2) Counting relapses.**  The width-three "hat" network of `NextCycle.lean`
  groks once and un-groks once.  Here the construction is iterated: `combNet k`
  is an explicit width-`3k` two-layer ReLU network with signed output weights
  (`combNet_eq_netRamp`) whose failure set has **at least `k+1` connected
  components** (`combNet_components_injective`,
  `combNet_failure_components_card`).  So the number of relapses grows linearly
  in the width — the qualitative content of (M2), and a strong converse to the
  tropical rigidity theorem `failure_set_convex`.

* **(M3) Exponent competition.**  `sqrt_mul_log_inv_tendsto_zero` and
  `log_delay_lt_bottleneck_delay` show that near criticality the logarithmic
  relaxation delay is *eventually dominated* by the inverse-square-root
  saddle-node bottleneck delay `passageTime (√μ) A`: the bottleneck mechanism
  always wins the competition close enough to the bifurcation.

Everything is `sorry`-free.
-/

namespace GrokkingWidthLaws

open Filter Topology MeasureTheory ProbabilityTheory
open GrokkingVector GrokkingBifurcation GrokkingNextCycle

/-! ### (M1) From concentration of the total signal to the `1/m` width law -/

/-- The delay of a zero-bias width-`m` network with negative output bias `c`
whose hidden units have unit signals `u 0, …, u (m-1)`: by
`zeroBias_sharp_threshold` this is the sharp grokking threshold. -/
noncomputable def unitDelay (c : ℝ) (u : ℕ → ℝ) (m : ℕ) : ℝ := -c / ∑ j ∈ Finset.range m, u j

/-- The width-`m` network with one-dimensional input, hidden weights `g j`,
vanishing hidden biases, output weights `a j` and output bias `c`, probed along
the ramp `t ↦ t`. -/
noncomputable def iidNet (m : ℕ) (g a : ℕ → ℝ) (c : ℝ) : ℝ → ℝ :=
  netRamp (fun j : Fin m => fun _ : Fin 1 => g j) (fun _ => 0) (fun j : Fin m => a j) c
    (fun _ : Fin 1 => 1)

theorem iidNet_signal (m : ℕ) (g : ℕ → ℝ) (j : Fin m) :
    signal (fun j : Fin m => fun _ : Fin 1 => g j) (fun _ : Fin 1 => (1 : ℝ)) j = g j := by
  simp [signal]

/-- The total signal of the width-`m` network is the partial sum of the unit
signals `a j * g j`. -/
theorem iidNet_totalSignal (m : ℕ) (g a : ℕ → ℝ) :
    ∑ j : Fin m, (fun j : Fin m => a j) j *
        signal (fun j : Fin m => fun _ : Fin 1 => g j) (fun _ : Fin 1 => (1 : ℝ)) j
      = ∑ j ∈ Finset.range m, a j * g j := by
  rw [← Fin.sum_univ_eq_sum_range (fun j => a j * g j) m]
  exact Finset.sum_congr rfl fun j _ => by rw [iidNet_signal]

/-- **The delay of the width-`m` network is exactly `unitDelay`.**  A restatement
of `zeroBias_sharp_threshold` for the sequence-indexed network: the ramped output
is nonpositive up to `|c| / Σ_{j<m} a_j g_j` and strictly positive afterwards. -/
theorem iidNet_sharp_threshold (m : ℕ) (g a : ℕ → ℝ) (c : ℝ) (hg : ∀ j, 0 ≤ g j) (hc : c < 0)
    (hS : 0 < ∑ j ∈ Finset.range m, a j * g j) :
    (∀ t ≤ unitDelay c (fun j => a j * g j) m, iidNet m g a c t ≤ 0) ∧
      (∀ t, unitDelay c (fun j => a j * g j) m < t → 0 < iidNet m g a c t) := by
  have hsig : ∀ j : Fin m,
      0 ≤ signal (fun j : Fin m => fun _ : Fin 1 => g j) (fun _ : Fin 1 => (1 : ℝ)) j := by
    intro j; rw [iidNet_signal]; exact hg j
  have hsum := iidNet_totalSignal m g a
  have hSfin : 0 < ∑ j : Fin m, (fun j : Fin m => a j) j *
      signal (fun j : Fin m => fun _ : Fin 1 => g j) (fun _ : Fin 1 => (1 : ℝ)) j := by
    rw [hsum]; exact hS
  have h := zeroBias_sharp_threshold (fun j : Fin m => fun _ : Fin 1 => g j)
    (fun j : Fin m => a j) c (fun _ : Fin 1 => 1) hsig hc hSfin
  rw [hsum] at h
  exact h

/-- **(M1), deterministic core.**  If the average unit signal converges to a
positive limit `L`, then the delay obeys the exact width law
`m · τ_m → |c| / L`; in particular `τ_m = Θ(1/m)`. -/
theorem unitDelay_width_law (u : ℕ → ℝ) (c L : ℝ) (hL : 0 < L)
    (hces : Tendsto (fun m : ℕ => (m : ℝ)⁻¹ * ∑ j ∈ Finset.range m, u j) atTop (𝓝 L)) :
    Tendsto (fun m : ℕ => (m : ℝ) * unitDelay c u m) atTop (𝓝 (-c / L)) := by
  have hdiv : Tendsto (fun m : ℕ => -c / ((m : ℝ)⁻¹ * ∑ j ∈ Finset.range m, u j))
      atTop (𝓝 (-c / L)) := tendsto_const_nhds.div hces (ne_of_gt hL)
  refine hdiv.congr' ?_
  have hpos : ∀ᶠ m : ℕ in atTop, 0 < (m : ℝ)⁻¹ * ∑ j ∈ Finset.range m, u j := by
    have := hces.eventually (eventually_gt_nhds (show L / 2 < L by linarith))
    filter_upwards [this] with m hm
    linarith
  filter_upwards [hpos, eventually_gt_atTop 0] with m hm hm0
  have hmpos : (0 : ℝ) < m := by exact_mod_cast hm0
  have hS : (∑ j ∈ Finset.range m, u j) ≠ 0 := by
    intro h
    rw [h, mul_zero] at hm
    exact lt_irrefl 0 hm
  simp only [unitDelay]
  field_simp

/-- **(M1), probabilistic form: the concentration width law.**  For i.i.d.
integrable hidden-unit signals `Y j` with positive mean, the grokking delay of
the zero-bias width-`m` network satisfies, almost surely,
`m · τ_m → |c| / E[Y]`. -/
theorem iid_width_law_ae {Omega : Type*} [MeasurableSpace Omega] (P : Measure Omega)
    (Y : ℕ → Omega → ℝ) (hint : Integrable (Y 0) P)
    (hindep : Pairwise (Function.onFun (fun f h => IndepFun f h P) Y))
    (hident : ∀ i, IdentDistrib (Y i) (Y 0) P P) (c : ℝ)
    (hmean : 0 < ∫ x, Y 0 x ∂P) :
    ∀ᵐ w ∂P, Tendsto (fun m : ℕ => (m : ℝ) * unitDelay c (fun j => Y j w) m)
      atTop (𝓝 (-c / ∫ x, Y 0 x ∂P)) := by
  filter_upwards [ProbabilityTheory.strong_law_ae Y hint hindep hident] with w hw
  refine unitDelay_width_law _ c _ hmean ?_
  simpa [smul_eq_mul] using hw

/-! ### (M2) A comb of hat units: linearly many relapses

The width-three hat unit of `NextCycle.lean` is repeated `k` times along the
ramp axis.  Each copy is a triangular bump supported on `[2i, 2i+2]` with peak
`1` at `2i+1`; the output bias is `-1/2`, so the network fails at every even
integer and succeeds at every odd integer below `2k`. -/

/-- The `i`-th hat unit: a triangular bump of height `1` supported on
`[2i, 2i+2]`, written as a signed combination of three ReLU units. -/
noncomputable def bump (i : ℕ) (t : ℝ) : ℝ :=
  relu (t - 2 * i) - 2 * relu (t - (2 * i + 1)) + relu (t - (2 * i + 2))

theorem relu_of_nonneg {x : ℝ} (hx : 0 ≤ x) : relu x = x := max_eq_left hx

theorem bump_of_le_left {i : ℕ} {t : ℝ} (ht : t ≤ 2 * i) : bump i t = 0 := by
  have h1 : t - 2 * (i : ℝ) ≤ 0 := by linarith
  have h2 : t - (2 * (i : ℝ) + 1) ≤ 0 := by linarith
  have h3 : t - (2 * (i : ℝ) + 2) ≤ 0 := by linarith
  simp [bump, relu_of_nonpos h1, relu_of_nonpos h2, relu_of_nonpos h3]

theorem bump_of_ge_right {i : ℕ} {t : ℝ} (ht : 2 * (i : ℝ) + 2 ≤ t) : bump i t = 0 := by
  have h1 : 0 ≤ t - 2 * (i : ℝ) := by linarith
  have h2 : 0 ≤ t - (2 * (i : ℝ) + 1) := by linarith
  have h3 : 0 ≤ t - (2 * (i : ℝ) + 2) := by linarith
  simp only [bump, relu_of_nonneg h1, relu_of_nonneg h2, relu_of_nonneg h3]
  ring

theorem bump_peak (i : ℕ) : bump i (2 * i + 1) = 1 := by
  have h1 : 0 ≤ (2 * (i : ℝ) + 1) - 2 * (i : ℝ) := by linarith
  have h3 : (2 * (i : ℝ) + 1) - (2 * (i : ℝ) + 2) ≤ 0 := by linarith
  have h2 : relu ((2 * (i : ℝ) + 1) - (2 * (i : ℝ) + 1)) = 0 := by
    rw [show (2 * (i : ℝ) + 1) - (2 * (i : ℝ) + 1) = 0 by ring]
    simp [relu]
  simp only [bump, relu_of_nonneg h1, h2, relu_of_nonpos h3]
  ring

/-- The comb network: `k` hat units and output bias `-1/2`. -/
noncomputable def combNet (k : ℕ) (t : ℝ) : ℝ := -1 / 2 + ∑ i ∈ Finset.range k, bump i t

/-- At every even integer all bumps vanish, so the comb network fails. -/
theorem combNet_even (k i : ℕ) : combNet k (2 * i) = -1 / 2 := by
  have hz : ∑ i' ∈ Finset.range k, bump i' (2 * (i : ℝ)) = 0 := by
    refine Finset.sum_eq_zero fun i' _ => ?_
    rcases Nat.lt_or_ge i' i with h | h
    · refine bump_of_ge_right ?_
      have : (i' : ℝ) + 1 ≤ (i : ℝ) := by exact_mod_cast h
      linarith
    · refine bump_of_le_left ?_
      have : (i : ℝ) ≤ (i' : ℝ) := by exact_mod_cast h
      linarith
  simp [combNet, hz]

/-- At every odd integer below `2k` exactly one bump is at its peak, so the comb
network succeeds. -/
theorem combNet_odd (k i : ℕ) (hik : i < k) : combNet k (2 * i + 1) = 1 / 2 := by
  have hsum : ∑ i' ∈ Finset.range k, bump i' (2 * (i : ℝ) + 1) = 1 := by
    rw [Finset.sum_eq_single i]
    · exact bump_peak i
    · intro i' _ hne
      rcases Nat.lt_or_ge i' i with h | h
      · refine bump_of_ge_right ?_
        have : (i' : ℝ) + 1 ≤ (i : ℝ) := by exact_mod_cast h
        linarith
      · refine bump_of_le_left ?_
        have hsucc : i + 1 ≤ i' := Nat.succ_le_of_lt (lt_of_le_of_ne h fun hh => hne hh.symm)
        have : (i : ℝ) + 1 ≤ (i' : ℝ) := by exact_mod_cast hsucc
        linarith
    · intro h
      exact absurd (Finset.mem_range.mpr hik) h
  simp only [combNet, hsum]
  norm_num

/-! #### The comb really is a width-`3k` ReLU network -/

/-- Output weights of the comb network, in the flattened index `j = 3i + r`. -/
def combA (j : ℕ) : ℝ := if j % 3 = 1 then -2 else 1

/-- Hidden biases of the comb network, in the flattened index `j = 3i + r`. -/
def combB (j : ℕ) : ℝ := -(2 * (j / 3 : ℕ) + (j % 3 : ℕ) : ℝ)

/-- Splitting a sum over `3k` indices into `k` blocks of three. -/
theorem sum_range_three_mul (k : ℕ) (f : ℕ → ℝ) :
    ∑ j ∈ Finset.range (3 * k), f j
      = ∑ i ∈ Finset.range k, (f (3 * i) + f (3 * i + 1) + f (3 * i + 2)) := by
  induction k with
  | zero => simp
  | succ k ih =>
      have h : 3 * (k + 1) = 3 * k + 1 + 1 + 1 := by ring
      rw [h, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, ih,
        Finset.sum_range_succ]
      ring_nf

/-- **The comb network is a genuine width-`3k` two-layer ReLU network** with
one-dimensional input, all hidden weights equal to `1`, hidden biases
`0, -1, -2, -2, -3, -4, …` and *signed* output weights `1, -2, 1, 1, -2, 1, …`. -/
theorem combNet_eq_netRamp (k : ℕ) (t : ℝ) :
    netRamp (fun _ : Fin (3 * k) => fun _ : Fin 1 => (1 : ℝ))
      (fun j : Fin (3 * k) => combB j) (fun j : Fin (3 * k) => combA j) (-1 / 2)
      (fun _ : Fin 1 => 1) t = combNet k t := by
  rw [netRamp_eq]
  have hsig : ∀ j : Fin (3 * k),
      signal (fun _ : Fin (3 * k) => fun _ : Fin 1 => (1 : ℝ)) (fun _ : Fin 1 => (1 : ℝ)) j
        = 1 := by
    intro j; simp [signal]
  have hterm : ∀ j : Fin (3 * k),
      combA j * relu (t * signal (fun _ : Fin (3 * k) => fun _ : Fin 1 => (1 : ℝ))
        (fun _ : Fin 1 => (1 : ℝ)) j + combB j)
        = combA j * relu (t + combB j) := by
    intro j; rw [hsig]; ring_nf
  rw [Finset.sum_congr rfl fun j _ => hterm j,
    Fin.sum_univ_eq_sum_range (fun j => combA j * relu (t + combB j)) (3 * k),
    sum_range_three_mul]
  simp only [combNet]
  congr 1
  refine Finset.sum_congr rfl fun i _ => ?_
  have e0 : (3 * i) % 3 = 0 := by omega
  have e1 : (3 * i + 1) % 3 = 1 := by omega
  have e2 : (3 * i + 2) % 3 = 2 := by omega
  have d0 : (3 * i) / 3 = i := by omega
  have d1 : (3 * i + 1) / 3 = i := by omega
  have d2 : (3 * i + 2) / 3 = i := by omega
  simp only [combA, combB, e0, e1, e2, d0, d1, d2, bump]
  norm_num
  ring_nf

/-! #### The failure set of the comb has at least `k+1` components -/

/-- Two distinct even integers below `2k` lie in different connected components
of the failure set: the odd integer between them is a success. -/
theorem combNet_components_ne {k i j : ℕ} (hij : i < j) (hjk : j ≤ k) :
    connectedComponentIn {t : ℝ | combNet k t ≤ 0} (2 * (i : ℝ))
      ≠ connectedComponentIn {t : ℝ | combNet k t ≤ 0} (2 * (j : ℝ)) := by
  set F : Set ℝ := {t : ℝ | combNet k t ≤ 0} with hF
  have hmem : ∀ n : ℕ, (2 * (n : ℝ)) ∈ F := by
    intro n
    have h := combNet_even k n
    simp only [hF, Set.mem_setOf_eq, h]
    norm_num
  intro hC
  have h1 : (2 * (i : ℝ)) ∈ connectedComponentIn F (2 * (i : ℝ)) :=
    mem_connectedComponentIn (hmem i)
  have h2 : (2 * (j : ℝ)) ∈ connectedComponentIn F (2 * (i : ℝ)) := by
    rw [hC]; exact mem_connectedComponentIn (hmem j)
  have hIcc :=
    (isPreconnected_connectedComponentIn (x := (2 * (i : ℝ))) (F := F)).Icc_subset h1 h2
  have hji : (i : ℝ) + 1 ≤ (j : ℝ) := by exact_mod_cast hij
  have hmid : (2 * (i : ℝ) + 1) ∈ Set.Icc (2 * (i : ℝ)) (2 * (j : ℝ)) :=
    ⟨by linarith, by linarith⟩
  have hin : (2 * (i : ℝ) + 1) ∈ F := connectedComponentIn_subset F _ (hIcc hmid)
  have hpos : combNet k (2 * (i : ℝ) + 1) = 1 / 2 := combNet_odd k i (by omega)
  simp only [hF, Set.mem_setOf_eq, hpos] at hin
  norm_num at hin

/-- **(M2) Linearly many relapses.**  The `k+1` even integers `0, 2, …, 2k` lie
in pairwise distinct connected components of the failure set of the width-`3k`
comb network. -/
theorem combNet_components_injective (k : ℕ) :
    Function.Injective
      (fun i : Fin (k + 1) =>
        connectedComponentIn {t : ℝ | combNet k t ≤ 0} (2 * ((i : ℕ) : ℝ))) := by
  intro i j hij
  rcases lt_trichotomy (i : ℕ) (j : ℕ) with h | h | h
  · exact absurd hij (combNet_components_ne h (by omega))
  · exact Fin.ext h
  · exact absurd hij.symm (combNet_components_ne h (by omega))

/-- The failure set of the width-`3k` comb network has at least `k+1` connected
components: the number of grokking/un-grokking events grows linearly in the
width. -/
theorem combNet_failure_components_card (k : ℕ) :
    k + 1 ≤ Set.ncard (Set.range (fun i : Fin (k + 1) =>
      connectedComponentIn {t : ℝ | combNet k t ≤ 0} (2 * ((i : ℕ) : ℝ)))) := by
  rw [Set.ncard_range_of_injective (combNet_components_injective k)]
  simp

/-- For `k ≥ 1` the failure set is not convex, so the convexity hypothesis of
`failure_set_convex` genuinely fails for signed output weights — the comb
generalizes the width-three hat network of the previous cycle. -/
theorem combNet_failure_not_convex (k : ℕ) (hk : 0 < k) :
    ¬ Convex ℝ {t : ℝ | combNet k t ≤ 0} := by
  intro hconv
  have h0 : (0 : ℝ) ∈ {t : ℝ | combNet k t ≤ 0} := by
    have := combNet_even k 0
    simp only [Nat.cast_zero, mul_zero] at this
    simp only [Set.mem_setOf_eq, this]
    norm_num
  have h2 : (2 * (k : ℝ)) ∈ {t : ℝ | combNet k t ≤ 0} := by
    have := combNet_even k k
    simp only [Set.mem_setOf_eq, this]
    norm_num
  have hk1 : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hmid : (1 : ℝ) ∈ {t : ℝ | combNet k t ≤ 0} := by
    have hsub := (hconv.segment_subset h0 h2)
    have : (1 : ℝ) ∈ segment ℝ (0 : ℝ) (2 * (k : ℝ)) := by
      rw [segment_eq_Icc (by linarith)]
      exact ⟨by norm_num, by linarith⟩
    exact hsub this
  have hval : combNet k (2 * ((0 : ℕ) : ℝ) + 1) = 1 / 2 := combNet_odd k 0 hk
  simp only [Nat.cast_zero, mul_zero, zero_add] at hval
  simp only [Set.mem_setOf_eq, hval] at hmid
  norm_num at hmid

/-! ### (M3) The bottleneck exponent beats the relaxation exponent -/

/-- `√μ · log(1/μ) → 0` as `μ ↓ 0`: the logarithmic divergence is slower than
any inverse power. -/
theorem sqrt_mul_log_inv_tendsto_zero :
    Tendsto (fun mu : ℝ => Real.sqrt mu * Real.log (1 / mu)) (𝓝[>] 0) (𝓝 0) := by
  have h := tendsto_log_mul_rpow_nhdsGT_zero (r := (1 / 2 : ℝ)) (by norm_num)
  have h2 : Tendsto (fun x : ℝ => -(Real.log x * x ^ (1 / 2 : ℝ))) (𝓝[>] 0) (𝓝 0) := by
    simpa using h.neg
  refine h2.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with x hx
  have hx0 : (0 : ℝ) < x := hx
  rw [Real.log_div one_ne_zero (ne_of_gt hx0), Real.log_one, ← Real.sqrt_eq_rpow]
  ring

/-- **(M3) Exponent competition.**  Near the bifurcation every logarithmic delay
`K · log(D/μ)` is eventually smaller than the inverse-square-root bound
`π / (2√μ)`. -/
theorem log_delay_lt_sqrt_bound (K D : ℝ) (hD : 0 < D) :
    ∀ᶠ mu in 𝓝[>] (0 : ℝ), K * Real.log (D / mu) < Real.pi / (2 * Real.sqrt mu) := by
  have hsqrt : Tendsto (fun mu : ℝ => Real.sqrt mu) (𝓝[>] 0) (𝓝 0) := by
    have h : Tendsto (fun mu : ℝ => Real.sqrt mu) (𝓝 0) (𝓝 0) := by
      simpa using (Real.continuous_sqrt.tendsto (0 : ℝ))
    exact h.mono_left nhdsWithin_le_nhds
  have hsum : Tendsto
      (fun mu : ℝ => K * (Real.sqrt mu * Real.log D) + K * (Real.sqrt mu * Real.log (1 / mu)))
      (𝓝[>] 0) (𝓝 0) := by
    have h1 : Tendsto (fun mu : ℝ => K * (Real.sqrt mu * Real.log D)) (𝓝[>] 0) (𝓝 0) := by
      simpa using ((hsqrt.mul_const (Real.log D)).const_mul K)
    have h2 : Tendsto (fun mu : ℝ => K * (Real.sqrt mu * Real.log (1 / mu))) (𝓝[>] 0) (𝓝 0) := by
      simpa using (sqrt_mul_log_inv_tendsto_zero.const_mul K)
    simpa using h1.add h2
  have hev := hsum (Iio_mem_nhds (show (0 : ℝ) < Real.pi / 2 by positivity))
  rw [mem_map] at hev
  filter_upwards [hev, self_mem_nhdsWithin] with mu hmu hmu0
  have hmu0' : (0 : ℝ) < mu := hmu0
  have hs : 0 < Real.sqrt mu := Real.sqrt_pos.mpr hmu0'
  have hlt : Real.sqrt mu * (K * Real.log (D / mu)) < Real.pi / 2 := by
    have hbound :
        K * (Real.sqrt mu * Real.log D) + K * (Real.sqrt mu * Real.log (1 / mu)) < Real.pi / 2 :=
      hmu
    have hlog : Real.log (D / mu) = Real.log D + Real.log (1 / mu) := by
      rw [Real.log_div (ne_of_gt hD) (ne_of_gt hmu0'), Real.log_div one_ne_zero (ne_of_gt hmu0'),
        Real.log_one]
      ring
    rw [hlog]
    nlinarith
  rw [lt_div_iff₀ (by positivity)]
  nlinarith

/-- **The bottleneck delay dominates the relaxation delay.**  For any
observation level `A > 0`, the saddle-node passage time
`passageTime (√μ) A ≥ π/(2√μ)` eventually exceeds every logarithmic delay
`K · log(D/μ)` as the distance `μ` to the bifurcation tends to `0`.  Thus of the
two proved delay laws — logarithmic (`crossTime_lower_bound`) and
inverse-square-root (`bottleneck_delay_inverse_sqrt`) — the second wins close
enough to criticality. -/
theorem log_delay_lt_bottleneck_delay (K D A : ℝ) (hD : 0 < D) (hA : 0 < A) :
    ∀ᶠ mu in 𝓝[>] (0 : ℝ), K * Real.log (D / mu) < passageTime (Real.sqrt mu) A := by
  have hsqrtA : ∀ᶠ mu in 𝓝[>] (0 : ℝ), Real.sqrt mu ≤ A := by
    have hsqrt : Tendsto (fun mu : ℝ => Real.sqrt mu) (𝓝[>] 0) (𝓝 0) := by
      have h : Tendsto (fun mu : ℝ => Real.sqrt mu) (𝓝 0) (𝓝 0) := by
        simpa using (Real.continuous_sqrt.tendsto (0 : ℝ))
      exact h.mono_left nhdsWithin_le_nhds
    filter_upwards [hsqrt.eventually (eventually_lt_nhds hA)] with mu hmu using hmu.le
  filter_upwards [log_delay_lt_sqrt_bound K D hD, hsqrtA, self_mem_nhdsWithin] with
    mu hmu hmuA hmu0
  have hmu0' : (0 : ℝ) < mu := hmu0
  have hs : 0 < Real.sqrt mu := Real.sqrt_pos.mpr hmu0'
  exact lt_of_lt_of_le hmu (passageTime_lower_bound _ A hs hmuA)

end GrokkingWidthLaws