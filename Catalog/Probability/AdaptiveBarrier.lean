/-
# The Adaptive Barrier (Factoring Lab, Phase A v19c — cycle 2)

Closing **Conjecture 5** of `FUTURE_DIRECTIONS.md`: *the structural-orthogonality
barrier is closed under adaptivity.*

The previous cycle proved that no invariant `g ∘ n` computable from the band
label alone predicts the target better than the band mean
(`FactoringLab.bandMean_is_best_predictor`), and that arbitrary *fixed*
nonlinear aggregation `Φ(w₁, …, w_m)` of finitely many free witnesses stays
`N`-only (`FactoringLab.aggregation_no_better_than_bandMean`).

An obvious escape route is *adaptivity*: run an `N`-only test, and depending on
its outcome run a different test, and so on, finally emitting a candidate
factor.  This file formalizes such a strategy as a finite **decision tree**
whose internal tests and whose leaf outputs are band-measurable, and proves:

* `FactoringLab.DTree.bandMeasurable_eval` — the value computed by such a tree
  is itself band-measurable (structural induction on the tree);
* `FactoringLab.factors_through_band` — every band-measurable function factors
  as `g ∘ n` for some `g : κ → ℝ`;
* `FactoringLab.adaptive_structural_orthogonality` — the output of any such
  tree is orthogonal to the residual `Y − E[Y | n]`;
* `FactoringLab.adaptive_barrier` — no such tree beats the band mean, *for any
  depth and any branching*; the excess error is again exactly the squared
  deviation from the band mean (`adaptive_sq_error_decomposition`);
* `FactoringLab.adaptive_cov_eq_cov_bandMean` and
  `FactoringLab.adaptive_nearEqualN_test` — the near-equal-`N` test applies
  verbatim to adaptive strategies: constant band means force covariance `0`.

Boundary (Stage 4, adversarial review).  The band-measurability hypothesis is
not decorative: `FactoringLab.adaptive_barrier_fails_without_bandMeasurable`
exhibits a two-point population and a depth-`0` tree which attains error `0`
while the band mean has error `1/2`.

Finally `FactoringLab.witnessTree_bandMeasurable` shows the hypothesis is met
by the strategies the framework is about: any tree whose tests are threshold
comparisons of free witnesses `w : κ → ℝ` and whose leaves are `N`-only
invariants is band-measurable, so the barrier covers the whole adaptive
free-witness family.
-/
import Mathlib
import Probability.StructuralOrthogonality

open Finset

namespace FactoringLab

variable {ι κ : Type*}

/-! ## 1.  Band-measurable functions -/

/-- A function on the population is *band-measurable* when it is constant on
each band: it can be computed from the band label `n i` alone. -/
def BandMeasurable {α : Type*} (Ω : Finset ι) (n : ι → κ) (f : ι → α) : Prop :=
  ∀ i ∈ Ω, ∀ j ∈ Ω, n i = n j → f i = f j

theorem bandMeasurable_comp {α : Type*} (Ω : Finset ι) (n : ι → κ) (g : κ → α) :
    BandMeasurable Ω n (fun i => g (n i)) := by
  intro i _ j _ h
  simp [h]

theorem BandMeasurable.comp {α β : Type*} {Ω : Finset ι} {n : ι → κ} {f : ι → α}
    (hf : BandMeasurable Ω n f) (F : α → β) : BandMeasurable Ω n (fun i => F (f i)) := by
  intro i hi j hj h
  simp [hf i hi j hj h]

theorem BandMeasurable.pair {α β : Type*} {Ω : Finset ι} {n : ι → κ}
    {f : ι → α} {g : ι → β}
    (hf : BandMeasurable Ω n f) (hg : BandMeasurable Ω n g) :
    BandMeasurable Ω n (fun i => (f i, g i)) := by
  intro i hi j hj h
  show (f i, g i) = (f j, g j)
  rw [hf i hi j hj h, hg i hi j hj h]

/-- **Every band-measurable function factors through the band label.**  This is
the exact sense in which "computable from the band alone" is a *structural*,
not merely numerical, property. -/
theorem factors_through_band {α : Type*} [Inhabited α] (Ω : Finset ι) (n : ι → κ)
    (f : ι → α) (hf : BandMeasurable Ω n f) :
    ∃ g : κ → α, ∀ i ∈ Ω, f i = g (n i) := by
  classical
  refine ⟨fun k => if h : ∃ i, i ∈ Ω ∧ n i = k then f h.choose else default, ?_⟩
  intro i hi
  have hex : ∃ j, j ∈ Ω ∧ n j = n i := ⟨i, hi, rfl⟩
  show f i = if h : ∃ j, j ∈ Ω ∧ n j = n i then f h.choose else default
  rw [dif_pos hex]
  obtain ⟨hmem, hlab⟩ := hex.choose_spec
  exact (hf _ hmem _ hi hlab).symm

/-! ## 2.  Adaptive strategies as decision trees -/

/-- A finite adaptive strategy: a binary decision tree whose internal nodes
carry a test on the population and whose leaves carry a real-valued output
(the candidate factor). -/
inductive DTree (ι : Type*) where
  | leaf (v : ι → ℝ) : DTree ι
  | node (test : ι → Bool) (l r : DTree ι) : DTree ι

namespace DTree

/-- Running the strategy on a member of the population. -/
def eval : DTree ι → ι → ℝ
  | leaf v, i => v i
  | node t l r, i => if t i then eval l i else eval r i

/-- The number of internal tests: the size of the strategy.  The barrier below
holds uniformly in this quantity — adaptivity of any depth does not help. -/
def size : DTree ι → ℕ
  | leaf _ => 0
  | node _ l r => l.size + r.size + 1

/-- A strategy is `N`-only when every test and every leaf is band-measurable. -/
def BandOnly (Ω : Finset ι) (n : ι → κ) : DTree ι → Prop
  | leaf v => BandMeasurable Ω n v
  | node t l r => BandMeasurable Ω n t ∧ BandOnly Ω n l ∧ BandOnly Ω n r

/-- **Adaptivity preserves band-measurability.**  Structural induction on the
tree: at a node the test picks the same branch for two members of the same
band, and the chosen branch is band-measurable by induction. -/
theorem bandMeasurable_eval (Ω : Finset ι) (n : ι → κ) :
    ∀ t : DTree ι, BandOnly Ω n t → BandMeasurable Ω n t.eval
  | leaf v, hv => hv
  | node test l r, ⟨htest, hl, hr⟩ => by
      intro i hi j hj hij
      have hT : test i = test j := htest i hi j hj hij
      by_cases h : test i = true
      · have hj' : test j = true := by rw [← hT]; exact h
        simp only [eval, h, hj', if_true]
        exact bandMeasurable_eval Ω n l hl i hi j hj hij
      · have h' : test i = false := by simpa using h
        have hj' : test j = false := by rw [← hT]; exact h'
        simp only [eval, h', hj']
        exact bandMeasurable_eval Ω n r hr i hi j hj hij

end DTree

/-- The output of an `N`-only adaptive strategy is a fixed `N`-only invariant:
adaptivity buys no new functions. -/
theorem adaptive_is_N_only (Ω : Finset ι) (n : ι → κ) (t : DTree ι)
    (ht : t.BandOnly Ω n) : ∃ g : κ → ℝ, ∀ i ∈ Ω, t.eval i = g (n i) :=
  factors_through_band Ω n t.eval (DTree.bandMeasurable_eval Ω n t ht)

/-! ## 3.  The adaptive barrier -/

/-- **Adaptive structural orthogonality.**  The output of any `N`-only adaptive
strategy is orthogonal to the residual `Y − E[Y | n]`. -/
theorem adaptive_structural_orthogonality [DecidableEq κ]
    (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (t : DTree ι) (ht : t.BandOnly Ω n) :
    ∑ i ∈ Ω, t.eval i * (Y i - bandMean Ω n Y i) = 0 := by
  obtain ⟨g, hg⟩ := adaptive_is_N_only Ω n t ht
  rw [Finset.sum_congr rfl (fun i hi => by rw [hg i hi] :
    ∀ i ∈ Ω, t.eval i * (Y i - bandMean Ω n Y i)
      = g (n i) * (Y i - bandMean Ω n Y i))]
  exact structural_orthogonality Ω n Y g

/-- **Exact error decomposition for adaptive strategies.**  The squared error of
an `N`-only adaptive strategy splits into the irreducible band-conditional
error plus the strategy's squared deviation from the band mean. -/
theorem adaptive_sq_error_decomposition [DecidableEq κ]
    (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (t : DTree ι) (ht : t.BandOnly Ω n) :
    ∑ i ∈ Ω, (t.eval i - Y i) ^ 2
      = ∑ i ∈ Ω, (t.eval i - bandMean Ω n Y i) ^ 2
        + ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 := by
  obtain ⟨g, hg⟩ := adaptive_is_N_only Ω n t ht
  have h1 : ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 = ∑ i ∈ Ω, (g (n i) - Y i) ^ 2 :=
    Finset.sum_congr rfl fun i hi => by rw [hg i hi]
  have h2 : ∑ i ∈ Ω, (t.eval i - bandMean Ω n Y i) ^ 2
      = ∑ i ∈ Ω, (g (n i) - bandMean Ω n Y i) ^ 2 :=
    Finset.sum_congr rfl fun i hi => by rw [hg i hi]
  rw [h1, h2, sq_error_decomposition Ω n Y g]

/-- **The adaptive barrier.**  No adaptive strategy built from `N`-only tests
and `N`-only outputs predicts the hidden target better than the band mean,
whatever its depth or branching structure. -/
theorem adaptive_barrier [DecidableEq κ] (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (t : DTree ι) (ht : t.BandOnly Ω n) :
    ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 ≤ ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 := by
  rw [adaptive_sq_error_decomposition Ω n Y t ht]
  have : 0 ≤ ∑ i ∈ Ω, (t.eval i - bandMean Ω n Y i) ^ 2 :=
    Finset.sum_nonneg fun i _ => sq_nonneg _
  linarith

/-- The barrier is uniform in the size of the strategy: the bound above does
not involve `t.size` in any way.  Stated explicitly: for every bound `m` on the
number of tests, all strategies of size `≤ m` are stuck at the same error. -/
theorem adaptive_barrier_uniform_in_size [DecidableEq κ]
    (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (m : ℕ) :
    ∀ t : DTree ι, t.size ≤ m → t.BandOnly Ω n →
      ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 ≤ ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 :=
  fun t _ ht => adaptive_barrier Ω n Y t ht

/-- **Adaptive covariance identity.**  The covariance of an adaptive `N`-only
strategy with the target equals its covariance with the band means. -/
theorem adaptive_cov_eq_cov_bandMean [DecidableEq κ]
    (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (t : DTree ι) (ht : t.BandOnly Ω n) :
    cov Ω t.eval Y = cov Ω t.eval (bandMean Ω n Y) := by
  obtain ⟨g, hg⟩ := adaptive_is_N_only Ω n t ht
  have hL : cov Ω t.eval Y = cov Ω (fun i => g (n i)) Y := by
    unfold cov expect
    rw [Finset.sum_congr rfl (fun i hi => by rw [hg i hi] :
        ∀ i ∈ Ω, t.eval i * Y i = g (n i) * Y i),
      Finset.sum_congr rfl (fun i hi => hg i hi : ∀ i ∈ Ω, t.eval i = g (n i))]
  have hR : cov Ω t.eval (bandMean Ω n Y) = cov Ω (fun i => g (n i)) (bandMean Ω n Y) := by
    unfold cov expect
    rw [Finset.sum_congr rfl (fun i hi => by rw [hg i hi] :
        ∀ i ∈ Ω, t.eval i * bandMean Ω n Y i = g (n i) * bandMean Ω n Y i),
      Finset.sum_congr rfl (fun i hi => hg i hi : ∀ i ∈ Ω, t.eval i = g (n i))]
  rw [hL, hR, cov_eq_cov_bandMean Ω n Y g]

/-- **The near-equal-`N` test for adaptive strategies.**  If the band means are
constant across the population — the situation the near-equal-`N` experiment
engineers — then every adaptive `N`-only strategy has exactly zero covariance
with the target. -/
theorem adaptive_nearEqualN_test [DecidableEq κ]
    (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (c : ℝ)
    (hconst : ∀ i ∈ Ω, bandMean Ω n Y i = c) (t : DTree ι) (ht : t.BandOnly Ω n) :
    cov Ω t.eval Y = 0 := by
  obtain ⟨g, hg⟩ := adaptive_is_N_only Ω n t ht
  have hL : cov Ω t.eval Y = cov Ω (fun i => g (n i)) Y := by
    unfold cov expect
    rw [Finset.sum_congr rfl (fun i hi => by rw [hg i hi] :
        ∀ i ∈ Ω, t.eval i * Y i = g (n i) * Y i),
      Finset.sum_congr rfl (fun i hi => hg i hi : ∀ i ∈ Ω, t.eval i = g (n i))]
  rw [hL]
  exact nearEqualN_test Ω n Y c hconst g

/-! ## 4.  The hypothesis is met by adaptive free-witness strategies -/

/-- Pull a strategy expressed in terms of the band label back to the
population. -/
def mapTree (n : ι → κ) : DTree κ → DTree ι
  | DTree.leaf v => DTree.leaf (fun i => v (n i))
  | DTree.node test l r => DTree.node (fun i => test (n i)) (mapTree n l) (mapTree n r)

/-- Threshold tests on free witnesses are band-measurable. -/
theorem thresholdTest_bandMeasurable (Ω : Finset ι) (n : ι → κ) (w : κ → ℝ) (θ : ℝ) :
    BandMeasurable Ω n (fun i => decide (w (n i) ≤ θ)) := by
  intro i _ j _ h
  simp [h]

/-- **Adaptive free-witness strategies are covered.**  A tree all of whose tests
are threshold comparisons `w_j(n i) ≤ θ_j` on free witnesses and all of whose
leaves are `N`-only invariants `g(n i)` satisfies the hypothesis of
`adaptive_barrier`; hence no such adaptive aggregation of free witnesses beats
the band mean. -/
theorem witnessTree_bandMeasurable (Ω : Finset ι) (n : ι → κ) :
    ∀ t : DTree κ, DTree.BandOnly Ω n (mapTree n t)
  | DTree.leaf v => bandMeasurable_comp Ω n v
  | DTree.node test l r =>
      ⟨bandMeasurable_comp Ω n test, witnessTree_bandMeasurable Ω n l,
        witnessTree_bandMeasurable Ω n r⟩

/-! ## 5.  Boundary: band-measurability cannot be dropped -/

/-- **Sharpness of the adaptive barrier.**  Without band-measurability the
statement is false, and fails already at depth `0`: on a two-point population
inside a single band, the strategy that simply outputs the target has error `0`,
while the band mean has error `1/2`.  So the barrier is a statement about
*`N`-only* strategies, not about adaptivity as such. -/
theorem adaptive_barrier_fails_without_bandMeasurable :
    ∃ (Ω : Finset (Fin 2)) (n : Fin 2 → Unit) (Y : Fin 2 → ℝ) (t : DTree (Fin 2)),
      ∑ i ∈ Ω, (t.eval i - Y i) ^ 2 < ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 := by
  classical
  refine ⟨Finset.univ, fun _ => (), fun i => if i = 0 then 0 else 1,
    DTree.leaf (fun i => if i = 0 then 0 else 1), ?_⟩
  have hband : ∀ i : Fin 2, bandMean (Finset.univ : Finset (Fin 2)) (fun _ => ())
      (fun i => if i = 0 then (0 : ℝ) else 1) i = 1 / 2 := by
    intro i
    simp [bandMean, band, Fin.sum_univ_two]
  rw [Fin.sum_univ_two, Fin.sum_univ_two, hband 0, hband 1]
  norm_num [DTree.eval]

end FactoringLab