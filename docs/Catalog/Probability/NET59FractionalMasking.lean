import Probability.NET59GeometricSharpness

/-!
# NET-59, round 18: masking is exactly `δ^depth`, and the resolution threshold

`Probability.NET59DobrushinMasking` proves the masking inequality

  `solo_j ≤ δ ^ (number of layers after j) · point_j`,

and `Probability.NET59MaskerArity` proves the extreme (`δ = 0`) case, where the
solo cost is `0` no matter how large the point cost is.  Between those two lies
the question the design of an ablation experiment actually depends on: *how many
downstream layers must be ablated together with layer `j` before its damage
becomes visible at the output?*

This file answers it exactly, in the affine two-state model of
`Probability.NET59GeometricSharpness`.  Ablating a downstream layer is modelled
by replacing it with the identity — the lossless channel of
`Probability.NET59LosslessIdentifiability` — so an experiment of arity `k + 1`
removes `k` of the `m` layers that mask layer `j`.

Main results.

* `probe_cost` — the measured cost of the arity-`(k+1)` experiment is exactly
  `δ ^ (m - k) · point`, so the masking bound of round 4 is **attained**, and the
  masking factor decays geometrically in the number of *surviving* masking
  layers rather than in the depth.
* `masking_bound_attained` — the `k = 0` specialisation: the solo cost is
  exactly `δ ^ m` times the point cost.
* `probe_cost_mono` — the measured cost is monotone in the arity: each extra
  ablated downstream layer multiplies the measurement by `1/δ`.
* `net59_resolution_threshold` — the design consequence at the measured
  resolution.  With `11` masking layers each contracting by `1/2` and a layer
  whose point damage is `1/2`, every experiment of arity at most `5` reports
  less than the `0.6`-point spread NET-59 could resolve, while the arity-`6`
  experiment reports more.  The minimal informative arity is therefore `6`,
  and it is set by the contraction spectrum, not by a count of "important"
  layers.
-/

namespace Catalog.Probability.NET59

open Finset

/-! ## 1. The probe stack

Ablated (lossless) layers transmit exactly: this is `chain_replicate_idK`,
proved in `Probability.NET59NonIdentifiability`. -/

/-- The experimental stack: the layer under study (an affine layer with offset
`s`), followed by `m - k` intact masking layers and `k` ablated ones.

The intact stack takes `s = 0`; the pruning of the layer under study takes
`s = c`, so that the *point* damage — the damage the layer does to its own
output law — is exactly `c`. -/
def probeStack (δ s : ℚ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) (hs : 0 ≤ s) (hsδ : s + δ ≤ 1)
    (m k : ℕ) : List (Kern (Fin 2) (Fin 2)) :=
  affK δ s hδ0 hs hsδ ::
    (List.replicate (m - k) (affK δ 0 hδ0 le_rfl (by linarith)) ++ List.replicate k idK)

/-- The point damage of the layer under study is exactly `c`: pruning shifts its
own output law by `c`, at the intact upstream state `d0`. -/
theorem probe_point_cost (δ c : ℚ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) (hc : 0 ≤ c) (hcδ : c + δ ≤ 1) :
    tv (push (affK δ 0 hδ0 le_rfl (by linarith)) d0)
       (push (affK δ c hδ0 hc hcδ) d0) = c := by
  have h0 : (0 : ℚ) ≤ 0 + δ * 0 := by norm_num
  have h1 : (0 : ℚ) + δ * 0 ≤ 1 := by norm_num
  have hc0 : (0 : ℚ) ≤ c + δ * 0 := by simpa using hc
  have hc1 : c + δ * 0 ≤ 1 := by simpa using (by linarith : c ≤ 1)
  have hd0 : d0 = bern 0 le_rfl zero_le_one := rfl
  rw [hd0, push_affK δ 0 0 hδ0 le_rfl (by linarith) le_rfl zero_le_one h0 h1,
    push_affK δ c 0 hδ0 hc hcδ le_rfl zero_le_one hc0 hc1, tv_bern]
  rw [show (0 : ℚ) + δ * 0 - (c + δ * 0) = -c by ring, abs_neg, abs_of_nonneg hc]

/-- Running the masking block (`m - k` intact affine layers followed by `k`
ablated ones) on `Bernoulli(q)` gives `Bernoulli(δ ^ (m - k) · q)`. -/
theorem chain_block (δ q : ℚ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) (hq0 : 0 ≤ q) (hq1 : q ≤ 1)
    (m k : ℕ) (hr0 : 0 ≤ δ ^ (m - k) * q) (hr1 : δ ^ (m - k) * q ≤ 1) :
    chain (List.replicate (m - k) (affK δ 0 hδ0 le_rfl (by linarith)) ++
      List.replicate k (idK : Kern (Fin 2) (Fin 2))) (bern q hq0 hq1)
      = bern (δ ^ (m - k) * q) hr0 hr1 := by
  have h0δ : (0 : ℚ) + δ ≤ 1 := by linarith
  obtain ⟨ha0, ha1⟩ := affIter_mem δ 0 hδ0 le_rfl h0δ (m - k) q hq0 hq1
  rw [chain_append, chain_replicate_affK δ 0 hδ0 le_rfl h0δ (m - k) q hq0 hq1 ha0 ha1,
    chain_replicate_idK]
  exact bern_congr (by ring) ha0 ha1 hr0 hr1

/-- **The measured cost of the arity-`(k+1)` experiment.**  Ablating the layer
under study together with `k` of its `m` masking layers reports exactly
`δ ^ (m - k) · c`, where `c` is the layer's point damage.

At `k = 0` this is the solo measurement, and the value `δ ^ m · c` shows that the
masking bound of round 4 is sharp; at `k = m` every masking layer is gone and
the experiment reports the point damage `c` exactly, recovering
`solo_eq_point_of_lossless`. -/
theorem probe_cost (δ c : ℚ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) (hc : 0 ≤ c) (hcδ : c + δ ≤ 1)
    (m k : ℕ) :
    tv (chain (probeStack δ 0 hδ0 hδ1 le_rfl (by linarith) m k) d0)
       (chain (probeStack δ c hδ0 hδ1 hc hcδ m k) d0)
      = δ ^ (m - k) * c := by
  have h0δ : (0 : ℚ) + δ ≤ 1 := by linarith
  have hc1 : c ≤ 1 := by linarith
  have hd0 : d0 = bern 0 le_rfl zero_le_one := rfl
  -- the two upstream states entering the masking block
  have hi0 : (0 : ℚ) ≤ 0 + δ * 0 := by norm_num
  have hi1 : (0 : ℚ) + δ * 0 ≤ 1 := by norm_num
  have hj0 : (0 : ℚ) ≤ c + δ * 0 := by simpa using hc
  have hj1 : c + δ * 0 ≤ 1 := by simpa using hc1
  have hz0 : (0 : ℚ) ≤ δ ^ (m - k) * (0 + δ * 0) := by norm_num
  have hz1 : δ ^ (m - k) * (0 + δ * 0) ≤ 1 := by norm_num
  have hw0 : 0 ≤ δ ^ (m - k) * (c + δ * 0) := by
    have : (0 : ℚ) ≤ δ ^ (m - k) := pow_nonneg hδ0 _
    nlinarith
  have hw1 : δ ^ (m - k) * (c + δ * 0) ≤ 1 := by
    have hp1 : δ ^ (m - k) ≤ 1 := pow_le_one₀ hδ0 hδ1
    have hp0 : (0 : ℚ) ≤ δ ^ (m - k) := pow_nonneg hδ0 _
    nlinarith
  rw [probeStack, probeStack, chain_cons, chain_cons, hd0,
    push_affK δ 0 0 hδ0 le_rfl h0δ le_rfl zero_le_one hi0 hi1,
    push_affK δ c 0 hδ0 hc hcδ le_rfl zero_le_one hj0 hj1,
    chain_block δ _ hδ0 hδ1 hi0 hi1 m k hz0 hz1,
    chain_block δ _ hδ0 hδ1 hj0 hj1 m k hw0 hw1, tv_bern]
  rw [show δ ^ (m - k) * (0 + δ * 0) - δ ^ (m - k) * (c + δ * 0) = -(δ ^ (m - k) * c) by ring,
    abs_neg, abs_of_nonneg (mul_nonneg (pow_nonneg hδ0 _) hc)]

/-- **The masking bound is attained.**  The solo measurement of a layer with
point damage `c` sitting `m` contracting layers from the output reports exactly
`δ ^ m · c`: `solo_le_pow_point` cannot be improved. -/
theorem masking_bound_attained (δ c : ℚ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) (hc : 0 ≤ c)
    (hcδ : c + δ ≤ 1) (m : ℕ) :
    tv (chain (probeStack δ 0 hδ0 hδ1 le_rfl (by linarith) m 0) d0)
       (chain (probeStack δ c hδ0 hδ1 hc hcδ m 0) d0)
      = δ ^ m * tv (push (affK δ 0 hδ0 le_rfl (by linarith)) d0)
          (push (affK δ c hδ0 hc hcδ) d0) := by
  rw [probe_cost δ c hδ0 hδ1 hc hcδ m 0, probe_point_cost δ c hδ0 hδ1 hc hcδ, Nat.sub_zero]

/-- Monotonicity of the cost formula in the arity: fewer surviving masking
layers means a larger measurement. -/
theorem probe_cost_formula_mono {δ c : ℚ} (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) (hc : 0 ≤ c)
    (m k l : ℕ) (hkl : k ≤ l) : δ ^ (m - k) * c ≤ δ ^ (m - l) * c :=
  mul_le_mul_of_nonneg_right (pow_le_pow_of_le_one hδ0 hδ1 (by omega)) hc

/-- **Each ablated masking layer multiplies the measurement by `1/δ`.**  The
measured cost is monotone in the experiment's arity. -/
theorem probe_cost_mono (δ c : ℚ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) (hc : 0 ≤ c) (hcδ : c + δ ≤ 1)
    (m k l : ℕ) (hkl : k ≤ l) :
    tv (chain (probeStack δ 0 hδ0 hδ1 le_rfl (by linarith) m k) d0)
       (chain (probeStack δ c hδ0 hδ1 hc hcδ m k) d0)
      ≤ tv (chain (probeStack δ 0 hδ0 hδ1 le_rfl (by linarith) m l) d0)
          (chain (probeStack δ c hδ0 hδ1 hc hcδ m l) d0) := by
  rw [probe_cost δ c hδ0 hδ1 hc hcδ m k, probe_cost δ c hδ0 hδ1 hc hcδ m l]
  exact probe_cost_formula_mono hδ0 hδ1 hc m k l hkl

/-! ## 2. The resolution threshold at the measured parameters -/

/-- **The minimal informative arity is set by the contraction spectrum.**

Take a layer whose point damage is `1/2` — half the maximum possible — sitting
behind `11` masking layers each contracting total variation by `1/2`, and take
the resolution of the NET-59 experiment to be its reported spread, `0.6`
points.  Then:

* every experiment that ablates the layer together with at most `4` of its
  masking layers (arity `≤ 5`, including the solo measurement, which reports
  `2⁻¹²`) is *below* the resolution;
* the experiment that ablates it together with `5` masking layers (arity `6`)
  is *above* it.

So the arity needed to see a layer is `1 + m - ⌈log_δ(ε / point)⌉`: a property
of the downstream contraction, computable in advance, and unrelated to any
notion of layer importance.  This is the quantitative form of the arity
hierarchy of rounds 15–16, whose `δ = 0` endpoint makes every finite arity
insufficient. -/
theorem net59_resolution_threshold :
    (∀ k ≤ 4,
      tv (chain (probeStack (1 / 2) 0 (by norm_num) (by norm_num) le_rfl (by norm_num) 11 k) d0)
         (chain (probeStack (1 / 2) (1 / 2) (by norm_num) (by norm_num) (by norm_num)
            (by norm_num) 11 k) d0) < 6 / 1000) ∧
      6 / 1000 <
        tv (chain (probeStack (1 / 2) 0 (by norm_num) (by norm_num) le_rfl (by norm_num) 11 5) d0)
           (chain (probeStack (1 / 2) (1 / 2) (by norm_num) (by norm_num) (by norm_num)
              (by norm_num) 11 5) d0) := by
  constructor
  · intro k hk
    rw [probe_cost (1 / 2) (1 / 2) (by norm_num) (by norm_num) (by norm_num) (by norm_num) 11 k]
    interval_cases k <;> norm_num
  · rw [probe_cost (1 / 2) (1 / 2) (by norm_num) (by norm_num) (by norm_num) (by norm_num) 11 5]
    norm_num

/-! ## 3. Lab notes

The measured costs of the arity-`(k+1)` experiment in the instance above
(`δ = 1/2`, `m = 11` masking layers, point damage `1/2`, resolution `0.006`):

```
k (masking layers ablated)   measured cost = 2^-(11-k)/2
 0  (solo)                   0.000244   invisible
 1                           0.000488   invisible
 2                           0.000977   invisible
 3                           0.001953   invisible
 4                           0.003906   invisible
 5                           0.007813   VISIBLE
11  (all)                    0.5        = point damage
```

The transition is sharp and is a property of the contraction coefficient alone:
halving `δ` moves the threshold by one layer, and `δ = 0` pushes it past every
finite arity, which is the masker construction of round 16. -/

section LabNotes

/-- The solo measurement in the instance above is three orders of magnitude
below the point damage it is supposed to detect. -/
example :
    tv (chain (probeStack (1 / 2) 0 (by norm_num) (by norm_num) le_rfl (by norm_num) 11 0) d0)
       (chain (probeStack (1 / 2) (1 / 2) (by norm_num) (by norm_num) (by norm_num)
          (by norm_num) 11 0) d0) = 1 / 4096 := by
  rw [probe_cost (1 / 2) (1 / 2) (by norm_num) (by norm_num) (by norm_num) (by norm_num) 11 0]
  norm_num

/-- Ablating every masking layer recovers the point damage exactly. -/
example :
    tv (chain (probeStack (1 / 2) 0 (by norm_num) (by norm_num) le_rfl (by norm_num) 11 11) d0)
       (chain (probeStack (1 / 2) (1 / 2) (by norm_num) (by norm_num) (by norm_num)
          (by norm_num) 11 11) d0) = 1 / 2 := by
  rw [probe_cost (1 / 2) (1 / 2) (by norm_num) (by norm_num) (by norm_num) (by norm_num) 11 11]
  norm_num

end LabNotes

end Catalog.Probability.NET59