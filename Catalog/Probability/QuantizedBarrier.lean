/-
# The quantized (depth–advantage collapse) barrier
(Factoring Lab, Phase A v19c — cycle 3)

This file closes next-cycle sub-conjecture 1 of `FUTURE_DIRECTIONS.md`: for an
`N`-only adaptive strategy the *only* thing that matters is the set of values it
can output, not the depth or the branching structure of the search that produces
them.

`Catalog/Probability/AdaptiveBarrier.lean` shows that no `N`-only decision tree
beats the band mean.  That bound is uniform but not quantitative: it does not
say how far from the band mean a *small* strategy must be.  Here we sharpen it.
A strategy that can emit only the finitely many values `V` incurs, on top of the
irreducible band-conditional error, the **quantization error** of the band means
against `V`:

`Σ_{i∈Ω} min_{v ∈ V} (v − E[Y | n(i)])²`   (`FactoringLab.quantErr`).

The results are:

* `FactoringLab.quantized_barrier` — every `N`-only predictor with values in `V`
  has squared error at least `quantErr(V) + (band-conditional error)`;
* `FactoringLab.QTree` — adaptive strategies with *constant* leaves, together
  with `FactoringLab.QTree.card_vals_le_size_succ` (`|V| ≤ size + 1`) and
  `FactoringLab.QTree.eval_mem_vals`;
* `FactoringLab.qtree_quantized_barrier` — the barrier for such a strategy,
  and `FactoringLab.depth_advantage_collapse`: among all `N`-only strategies
  emitting values in a fixed set `V`, *every* one is stuck at the same lower
  bound, whatever its size; so growing the tree past the point where its `|V|`
  values are realized buys nothing;
* `FactoringLab.quantErr_pos` — the bound has real content: as soon as one band
  mean is missed by `V`, the quantization error is strictly positive, so a
  `k`-valued strategy is *strictly* worse than the band mean;
* `FactoringLab.QTree.toDTree_eval` and `FactoringLab.QTree.bandOnly_toDTree` —
  constant-leaf strategies are genuine decision trees in the sense of
  `AdaptiveBarrier.lean`, so the two barriers compose.
-/
import Mathlib
import Probability.AdaptiveBarrier

open Finset

namespace FactoringLab

variable {ι κ : Type*}

/-! ### Quantization error of the band means against a finite value set -/

/-- The **quantization error**: the total squared distance from the band means
to the nearest available output value.  This is the price a strategy pays for
being able to emit only finitely many values. -/
noncomputable def quantErr [DecidableEq κ] (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (V : Finset ℝ) (hV : V.Nonempty) : ℝ :=
  ∑ i ∈ Ω, V.inf' hV fun v => (v - bandMean Ω n Y i) ^ 2

theorem quantErr_nonneg [DecidableEq κ] (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (V : Finset ℝ) (hV : V.Nonempty) : 0 ≤ quantErr Ω n Y V hV := by
  exact Finset.sum_nonneg fun i _ => Finset.le_inf' hV _ fun v _ => sq_nonneg _

/-- **The quantized barrier.**  A predictor computable from the band label
alone and restricted to the value set `V` cannot do better than the band mean
*rounded to `V`*: its squared error is at least the quantization error plus the
irreducible band-conditional error. -/
theorem quantized_barrier [DecidableEq κ] (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (V : Finset ℝ) (hV : V.Nonempty) (g : κ → ℝ) (hg : ∀ i ∈ Ω, g (n i) ∈ V) :
    quantErr Ω n Y V hV + ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2
      ≤ ∑ i ∈ Ω, (g (n i) - Y i) ^ 2 := by
  rw [sq_error_decomposition Ω n Y g]
  have hle : quantErr Ω n Y V hV ≤ ∑ i ∈ Ω, (g (n i) - bandMean Ω n Y i) ^ 2 :=
    Finset.sum_le_sum fun i hi => Finset.inf'_le _ (hg i hi)
  linarith

/-- The quantization error is strictly positive as soon as some band mean is not
itself an available output value: a strategy with a fixed finite palette is then
*strictly* worse than the band mean. -/
theorem quantErr_pos [DecidableEq κ] (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (V : Finset ℝ) (hV : V.Nonempty) {i₀ : ι} (hi₀ : i₀ ∈ Ω)
    (hmiss : ∀ v ∈ V, v ≠ bandMean Ω n Y i₀) :
    0 < quantErr Ω n Y V hV := by
  refine Finset.sum_pos' (fun i _ => ?_) ⟨i₀, hi₀, ?_⟩
  · exact Finset.le_inf' hV _ fun v _ => sq_nonneg _
  · obtain ⟨v, hv, hval⟩ := Finset.exists_mem_eq_inf' hV
      (fun v => (v - bandMean Ω n Y i₀) ^ 2)
    rw [hval]
    have : v - bandMean Ω n Y i₀ ≠ 0 := sub_ne_zero.mpr (hmiss v hv)
    exact lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 this))

/-! ### Adaptive strategies with finitely many output values -/

/-- A finite adaptive strategy with *constant* leaves: the outputs form a finite
palette, whose size is what the barrier below charges for. -/
inductive QTree (ι : Type*) where
  | leaf (v : ℝ) : QTree ι
  | node (test : ι → Bool) (l r : QTree ι) : QTree ι

namespace QTree

/-- Running the strategy. -/
def eval : QTree ι → ι → ℝ
  | leaf v, _ => v
  | node t l r, i => if t i then eval l i else eval r i

/-- Number of internal tests. -/
def size : QTree ι → ℕ
  | leaf _ => 0
  | node _ l r => l.size + r.size + 1

/-- The palette: the finite set of values the strategy can emit. -/
noncomputable def vals : QTree ι → Finset ℝ
  | leaf v => {v}
  | node _ l r => l.vals ∪ r.vals

/-- Band-measurability of all the tests (the leaves are constants, hence
automatically band-measurable). -/
def BandOnly (Ω : Finset ι) (n : ι → κ) : QTree ι → Prop
  | leaf _ => True
  | node t l r => BandMeasurable Ω n t ∧ BandOnly Ω n l ∧ BandOnly Ω n r

theorem vals_nonempty : ∀ t : QTree ι, t.vals.Nonempty
  | leaf v => ⟨v, by simp [vals]⟩
  | node _ l r => by
      obtain ⟨v, hv⟩ := vals_nonempty l
      exact ⟨v, by simp [vals, hv]⟩

/-- The strategy only ever emits values from its palette. -/
theorem eval_mem_vals : ∀ (t : QTree ι) (i : ι), t.eval i ∈ t.vals
  | leaf v, i => by simp [eval, vals]
  | node test l r, i => by
      by_cases h : test i = true
      · simp only [eval, h, if_true, vals, Finset.mem_union]
        exact Or.inl (eval_mem_vals l i)
      · have h' : test i = false := by simpa using h
        simp only [eval, h', vals, Finset.mem_union]
        exact Or.inr (eval_mem_vals r i)

/-- A strategy with `s` tests has a palette of at most `s + 1` values: the
palette size is what limits the strategy, and it grows only linearly in the
size of the tree (hence only exponentially in its depth). -/
theorem card_vals_le_size_succ : ∀ t : QTree ι, t.vals.card ≤ t.size + 1
  | leaf v => by simp [vals, size]
  | node test l r => by
      have hl := card_vals_le_size_succ l
      have hr := card_vals_le_size_succ r
      have := Finset.card_union_le l.vals r.vals
      simp only [vals, size]
      omega

/-- Constant-leaf strategies are decision trees in the sense of
`AdaptiveBarrier.lean`. -/
def toDTree : QTree ι → DTree ι
  | leaf v => DTree.leaf (fun _ => v)
  | node t l r => DTree.node t l.toDTree r.toDTree

theorem toDTree_eval : ∀ (t : QTree ι) (i : ι), t.toDTree.eval i = t.eval i
  | leaf v, i => rfl
  | node test l r, i => by
      by_cases h : test i = true
      · simp [toDTree, DTree.eval, eval, h, toDTree_eval l i]
      · have h' : test i = false := by simpa using h
        simp [toDTree, DTree.eval, eval, h', toDTree_eval r i]

theorem bandOnly_toDTree (Ω : Finset ι) (n : ι → κ) :
    ∀ t : QTree ι, t.BandOnly Ω n → t.toDTree.BandOnly Ω n
  | leaf v, _ => by
      intro i _ j _ _
      rfl
  | node test l r, ⟨ht, hl, hr⟩ =>
      ⟨ht, bandOnly_toDTree Ω n l hl, bandOnly_toDTree Ω n r hr⟩

theorem bandMeasurable_eval (Ω : Finset ι) (n : ι → κ) (t : QTree ι)
    (ht : t.BandOnly Ω n) : BandMeasurable Ω n t.eval := by
  intro i hi j hj hij
  have h := DTree.bandMeasurable_eval Ω n t.toDTree (bandOnly_toDTree Ω n t ht) i hi j hj hij
  rwa [toDTree_eval, toDTree_eval] at h

end QTree

/-! ### The depth–advantage collapse -/

/-- **Quantized adaptive barrier.**  An `N`-only adaptive strategy with constant
leaves is charged the quantization error of its own palette on top of the
irreducible band-conditional error. -/
theorem qtree_quantized_barrier [DecidableEq κ] (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (t : QTree ι) (ht : t.BandOnly Ω n) :
    quantErr Ω n Y t.vals t.vals_nonempty + ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2
      ≤ ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 := by
  obtain ⟨g, hg⟩ :=
    factors_through_band Ω n t.eval (QTree.bandMeasurable_eval Ω n t ht)
  have hgv : ∀ i ∈ Ω, g (n i) ∈ t.vals := by
    intro i hi
    rw [← hg i hi]
    exact t.eval_mem_vals i
  have hsum : ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 = ∑ i ∈ Ω, (g (n i) - Y i) ^ 2 :=
    Finset.sum_congr rfl fun i hi => by rw [hg i hi]
  rw [hsum]
  exact quantized_barrier Ω n Y t.vals t.vals_nonempty g hgv

/-- **Depth–advantage collapse.**  Fix a palette `V`.  *Every* `N`-only adaptive
strategy whose outputs lie in `V` — of any size, any depth, any branching
pattern — obeys one and the same lower bound.  Enlarging the tree without
enlarging the palette cannot improve the prediction of the hidden factor. -/
theorem depth_advantage_collapse [DecidableEq κ] (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (V : Finset ℝ) (hV : V.Nonempty) :
    ∀ t : QTree ι, t.BandOnly Ω n → (∀ i ∈ Ω, t.eval i ∈ V) →
      quantErr Ω n Y V hV + ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2
        ≤ ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 := by
  intro t ht hVt
  obtain ⟨g, hg⟩ :=
    factors_through_band Ω n t.eval (QTree.bandMeasurable_eval Ω n t ht)
  have hgv : ∀ i ∈ Ω, g (n i) ∈ V := by
    intro i hi
    rw [← hg i hi]
    exact hVt i hi
  have hsum : ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 = ∑ i ∈ Ω, (g (n i) - Y i) ^ 2 :=
    Finset.sum_congr rfl fun i hi => by rw [hg i hi]
  rw [hsum]
  exact quantized_barrier Ω n Y V hV g hgv

/-- **A `k`-valued strategy is strictly worse than the band mean** whenever some
band mean lies outside its palette.  Combined with
`FactoringLab.card_vals_le_size_succ`, this converts the qualitative adaptive
barrier into a quantitative one: a strategy of size `s` misses every band mean
outside a set of `s + 1` reals, and pays for each miss. -/
theorem qtree_strictly_worse [DecidableEq κ] (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (t : QTree ι) (ht : t.BandOnly Ω n) {i₀ : ι} (hi₀ : i₀ ∈ Ω)
    (hmiss : ∀ v ∈ t.vals, v ≠ bandMean Ω n Y i₀) :
    ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 < ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 := by
  have h1 := qtree_quantized_barrier Ω n Y t ht
  have h2 := quantErr_pos Ω n Y t.vals t.vals_nonempty hi₀ hmiss
  linarith

end FactoringLab