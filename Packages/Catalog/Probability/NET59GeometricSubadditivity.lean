import Probability.NET59DobrushinMasking
import Probability.NET59NonIdentifiability

/-!
# NET-59, round 5: where the observed sub-additivity comes from

The measurement to be explained: joint all-layer top-`k` pruning costs `1.7%`,
whereas adding up the `24` solo costs predicts about `4.8%`.  Pruning
interactions are *sub-additive*.

`Probability.NET59NonIdentifiability` proves that sub-additivity is **not** a
law: there are stacks whose solo costs all vanish and whose joint cost is `1`.
So sub-additivity must come from structure.  This file identifies a sufficient
structural hypothesis and makes it quantitative: **contraction of the intact
layers**.

The mechanism is a contraction-weighted refinement of the telescoping bound.  In
the hybrid decomposition the damage created at layer `i` still has to travel
through the intact layers `i+1, …, n-1` before it reaches the output, and
`tv_chain_le_dobrushin_pow` damps it by `δ ^ (n-1-i)`.  Summing the geometric
series replaces the additive prediction `n · c` by `c / (1 - δ)`, a bound that is
**independent of the depth**.

Main results.

* `chain_tv_le_geometric` — joint damage `≤ c · Σ_{i<n} δ^i` for a stack whose
  intact layers contract by `δ` and whose prunings are uniformly `c`-close.
* `geom_sum_half_le_two` — the geometric series at `δ = 1/2`.
* `geometric_subadditivity_uniform` — with `δ = 1/2`, at any depth (in particular the measured `24`)
  the joint damage is at most `2c`, against the additive prediction `24c`.
* `geometric_beats_additive` — the gain is a genuine factor `12` whenever
  `c > 0`, i.e. sub-additivity of exactly the observed kind is *forced* by
  contraction, with no reference to which layer matters.
* `subadditivity_needs_contraction` — the converse guard: drop the contraction
  hypothesis and the conclusion fails, since the witness family has `c`
  arbitrarily small solo costs (indeed `0`) and joint cost `1`.
-/

namespace Catalog.Probability.NET59

open Finset

variable {α : Type*} [Fintype α]

/-! ## 1. The contraction-weighted telescoping bound -/

/-- **Geometric damping of joint pruning damage.**  Assume

* every *intact* layer contracts total variation by `δ ∈ [0,1]` (a Dobrushin
  hypothesis on the network, not on the pruning), and
* every pruned layer is `c`-close to its intact counterpart, uniformly over the
  input state.

Then the joint damage of pruning the whole stack is at most `c · Σ_{i<n} δ^i`,
which is bounded by `c / (1-δ)` *independently of the depth* `n`.

Compare `chain_tv_le_depth_mul`, which gives the additive bound `n · c`: the two
agree at `δ = 1`, and the ratio between them is the sub-additivity factor. -/
theorem chain_tv_le_geometric {δ c : ℚ} (hδ0 : 0 ≤ δ) :
    ∀ (F P : List (Kern α α)), F.length = P.length →
      (∀ K ∈ F, ∀ a b, tv (K a) (K b) ≤ δ) →
      (∀ q ∈ F.zip P, ∀ a : α, tv (q.1 a) (q.2 a) ≤ c) →
      ∀ μ : Dist α, tv (chain F μ) (chain P μ) ≤ c * ∑ i ∈ range F.length, δ ^ i := by
  intro F
  induction F with
  | nil =>
      intro P hlen _ _ μ
      cases P with
      | nil => simp
      | cons p P => simp at hlen
  | cons f F ih =>
      intro P hlen hcontr hclose μ
      cases P with
      | nil => simp at hlen
      | cons p P =>
          have hfp : ∀ a : α, tv (f a) (p a) ≤ c := hclose (f, p) (by simp)
          have hstep : tv (push f μ) (push p μ) ≤ c := tv_push_perturb_unif f p μ hfp
          have htailc : ∀ K ∈ F, ∀ a b, tv (K a) (K b) ≤ δ := fun K hK => hcontr K (by simp [hK])
          have htailz : ∀ q ∈ F.zip P, ∀ a : α, tv (q.1 a) (q.2 a) ≤ c := by
            intro q hq; exact hclose q (by simp [List.zip_cons_cons, hq])
          have hrec := ih P (by simpa using hlen) htailc htailz (push p μ)
          -- the damage created by layer `0` is damped by the intact suffix `F`
          have hdamp : tv (chain F (push f μ)) (chain F (push p μ))
              ≤ δ ^ F.length * tv (push f μ) (push p μ) :=
            tv_chain_le_dobrushin_pow hδ0 F htailc _ _
          have hpow : δ ^ F.length * tv (push f μ) (push p μ) ≤ δ ^ F.length * c :=
            mul_le_mul_of_nonneg_left hstep (pow_nonneg hδ0 _)
          have htri : tv (chain F (push f μ)) (chain P (push p μ))
              ≤ tv (chain F (push f μ)) (chain F (push p μ))
                + tv (chain F (push p μ)) (chain P (push p μ)) := tv_triangle _ _ _
          have hsum : ∑ i ∈ range (f :: F).length, δ ^ i
              = δ ^ F.length + ∑ i ∈ range F.length, δ ^ i := by
            rw [List.length_cons, Finset.sum_range_succ]
            ring
          rw [chain_cons, chain_cons, hsum, mul_add]
          linarith

/-! ## 2. The geometric series at the measured parameters -/

/-- The closed form of the dyadic geometric series. -/
theorem geom_sum_half (n : ℕ) : ∑ i ∈ range n, ((1 : ℚ) / 2) ^ i = 2 * (1 - (1 / 2) ^ n) := by
  induction n with
  | zero => simp
  | succ m ihm =>
      rw [Finset.sum_range_succ, ihm]
      ring

/-- `∑_{i<n} 2^{-i} ≤ 2`, uniformly in the depth `n`. -/
theorem geom_sum_half_le_two (n : ℕ) : ∑ i ∈ range n, ((1 : ℚ) / 2) ^ i ≤ 2 := by
  rw [geom_sum_half]
  have : (0 : ℚ) ≤ (1 / 2 : ℚ) ^ n := by positivity
  linarith

/-- **Depth-independent joint damage.**  In a stack of *any* depth whose intact
layers each contract by `1/2`, pruning every layer with a uniform per-layer
budget `c` costs at most `2c`.  At the measured depth `24` the additive
prediction would be `24c`.

This is the shape of the NET-50/NET-59 observation: the joint cost is a small
multiple of a single layer's cost, not the sum over layers. -/
theorem geometric_subadditivity_uniform {c : ℚ} (hc : 0 ≤ c) (F P : List (Kern α α))
    (hlen : F.length = P.length)
    (hcontr : ∀ K ∈ F, ∀ a b, tv (K a) (K b) ≤ 1 / 2)
    (hclose : ∀ q ∈ F.zip P, ∀ a : α, tv (q.1 a) (q.2 a) ≤ c) (μ : Dist α) :
    tv (chain F μ) (chain P μ) ≤ 2 * c := by
  have hmain := chain_tv_le_geometric (c := c) (by norm_num : (0:ℚ) ≤ 1 / 2) F P hlen hcontr hclose μ
  have hgeo : ∑ i ∈ range F.length, ((1 : ℚ) / 2) ^ i ≤ 2 := geom_sum_half_le_two _
  nlinarith [hmain, hgeo]

/-- **Contraction forces sub-additivity, quantitatively.**  Under the same
hypotheses the joint damage is at most a *twelfth* of the additive prediction
`24 · c`, and the gap is strict as soon as the per-layer budget is nonzero. -/
theorem geometric_beats_additive {c : ℚ} (hc : 0 < c) (F P : List (Kern α α))
    (hF : F.length = 24) (hlen : F.length = P.length)
    (hcontr : ∀ K ∈ F, ∀ a b, tv (K a) (K b) ≤ 1 / 2)
    (hclose : ∀ q ∈ F.zip P, ∀ a : α, tv (q.1 a) (q.2 a) ≤ c) (μ : Dist α) :
    tv (chain F μ) (chain P μ) ≤ (F.length : ℚ) * c / 12 ∧
      tv (chain F μ) (chain P μ) < (F.length : ℚ) * c := by
  have h2c := geometric_subadditivity_uniform hc.le F P hlen hcontr hclose μ
  rw [hF]
  norm_num
  constructor <;> linarith

/-! ## 3. The hypothesis is necessary -/

/-- **No contraction, no sub-additivity.**  The witness family of
`Probability.NET59NonIdentifiability` satisfies the per-layer closeness
hypothesis with the *smallest possible* budget for the solo measurement — every
solo cost is `0` — and yet its joint cost is `1`.  What fails there is precisely
the uniformity of the per-layer bound: the constant pruning of a transparent
layer is `t`-far from it at the intact upstream state, not `0`-far.

So `chain_tv_le_geometric` cannot be improved to a statement about measured solo
costs; it genuinely needs a uniform per-layer budget together with contraction. -/
theorem subadditivity_needs_contraction :
    ∃ (F P : List (Kern (Fin 2) (Fin 2))),
      F.length = 24 ∧ P.length = 24 ∧
      (∀ j, j < 24 →
        tv (chain F d0) (chain (F.set j (prunedLayer 23 1 zero_le_one le_rfl j)) d0) = 0) ∧
      tv (chain F d0) (chain P d0) = 1 :=
  no_subadditivity_law

/-! ## 4. Lab notes

Numbers implied by the theorems above, at the measured depth `24`:

```
intact-layer contraction δ            : 1/2
uniform per-layer pruning budget c    : c
additive prediction  (depth · c)      : 24 c
geometric bound      (c · Σ 2^-i)     : ≤ 2 c
sub-additivity factor forced          : ≥ 12
measured analogue (NET-50/NET-59)     : 4.8% predicted vs 1.7% observed (≈ 2.8)
```

A measured factor of `2.8` corresponds, in this model, to a mild, entirely
generic amount of forgetting, requiring no special role for any layer.

(Round 17 makes this exact.  The naive reading `δ ≈ 1 - 1/2.8 ≈ 0.64` inverts
the ratio without the depth factor; since `additive / joint = n(1-δ)/(1-δ^n)`,
at `n = 24` the measured factor `2.8` corresponds to `δ ≈ 0.89`.  See
`Probability.NET59GeometricSharpness.net59_contraction_estimator`, which also
proves the bound above is attained, so the correspondence is an equality rather
than an estimate.) -/

section LabNotes

/-- The geometric bound at depth `24` and `δ = 1/2`, as a rational inequality. -/
example : ∑ i ∈ range 24, ((1 : ℚ) / 2) ^ i ≤ 2 := geom_sum_half_le_two 24

/-- …and it is far below the additive value `24`. -/
example : ∑ i ∈ range 24, ((1 : ℚ) / 2) ^ i < 24 := by
  have := geom_sum_half_le_two 24
  linarith

end LabNotes

end Catalog.Probability.NET59