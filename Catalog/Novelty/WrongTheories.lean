/-
# The Unreasonable Effectiveness of Wrong Theories

A meta-theorem about *theory-space*, formalized via perturbation theory on a real
inner-product space.

## Setup

We model the space of physical **theories** as a real inner-product space `E`.
A distinguished point `truth : E` is the exact description of nature.  A *theory*
`T : E` is any point; its **wrongness** is its distance to the truth,
`wrongness truth T = ‖T - truth‖`.

A **phenomenon** is a measurement direction `u : E`.  The *prediction* a theory
makes for phenomenon `u` is the inner product `⟪T, u⟫`, and the **error** the
theory makes on that phenomenon is `predErr truth T u = |⟪T - truth, u⟫|`.

## Results

Metric / perturbative layer (needs only a normed space, so stated there):

* `wrongness_eq_zero_iff` — a theory is exactly true iff its wrongness is `0`.
* `wrongness_correction_bound` — updating a theory by a correction `c` changes its
  wrongness by at most `‖c‖` (Lipschitz stability of wrongness).
* `perturbation_tendsto_truth` — **the wrongness of a perturbatively-corrected
  theory forms a series converging to the truth**: if the corrections `c n` sum
  (`HasSum`) to `truth - T₀`, then the partial theories
  `Tₙ = T₀ + ∑_{i<n} cᵢ` have wrongness tending to `0`.
* `perturbation_tail_bound` — the *quantitative* convergence: the residual
  wrongness after `n` correction terms is bounded by the tail
  `∑_{i} ‖c (i+n)‖` of the norm series.
* `perturbation_tail_tendsto_zero` — that tail bound itself tends to `0`.
* `perturbation_geometric_rate` — an explicit *exponential* rate: geometrically
  decaying corrections `‖cᵢ‖ ≤ M rⁱ` (`0 ≤ r < 1`) give residual wrongness
  bounded by `M rⁿ / (1 − r)` after `n` terms.

Phenomenological layer (needs the inner product):

* `theory_exact_iff_all_phenomena` — a theory equals the truth iff it predicts
  every phenomenon perfectly (non-degeneracy of the inner product).
* `exact_on_orthogonal_phenomena` — a wrong theory `T` predicts **perfectly** on
  the entire hyperplane of phenomena orthogonal to its error vector `T - truth`.
* `wrong_theory_beats_rival` — **the main meta-theorem.**  For a theory `A` whose
  error is not parallel to the error of a rival ("known correct") theory `B`,
  there is a phenomenon `u` on which `A` is *exactly right* while `B` is wrong;
  hence `A` strictly out-predicts `B` there — even though both are wrong.

Every result is proved from scratch over an arbitrary real inner-product space.
-/
import Mathlib

open scoped RealInnerProductSpace Topology

namespace WrongTheories

/-! ## Metric / perturbative layer

These results only use the normed-space structure of theory-space. -/

section Metric

variable {E : Type*} [NormedAddCommGroup E]

/-- The **wrongness** of a theory `T` relative to `truth`: its distance in
theory-space. -/
def wrongness (truth T : E) : ℝ := ‖T - truth‖

@[simp] theorem wrongness_self (truth : E) : wrongness truth truth = 0 := by
  simp [wrongness]

theorem wrongness_nonneg (truth T : E) : 0 ≤ wrongness truth T :=
  norm_nonneg _

/-- A theory is exactly true precisely when its wrongness vanishes. -/
theorem wrongness_eq_zero_iff (truth T : E) :
    wrongness truth T = 0 ↔ T = truth := by
  rw [wrongness, norm_eq_zero, sub_eq_zero]

/-- **Lipschitz stability of wrongness.**  Correcting a theory `T` by `c` changes
its wrongness by at most `‖c‖`. -/
theorem wrongness_correction_bound (truth T c : E) :
    |wrongness truth (T + c) - wrongness truth T| ≤ ‖c‖ := by
  rw [wrongness, wrongness]
  have hle := abs_norm_sub_norm_le (T + c - truth) (T - truth)
  have heq : (T + c - truth) - (T - truth) = c := by abel
  rwa [heq] at hle

/-- The `n`-th perturbatively corrected theory, `T₀ + ∑_{i<n} cᵢ`. -/
def partialTheory (T₀ : E) (c : ℕ → E) (n : ℕ) : E :=
  T₀ + ∑ i ∈ Finset.range n, c i

@[simp] theorem partialTheory_zero (T₀ : E) (c : ℕ → E) :
    partialTheory T₀ c 0 = T₀ := by
  simp [partialTheory]

/-- **The wrongness of a perturbatively corrected theory is a convergent series
toward truth.**  If the corrections `c` sum to the gap `truth - T₀`, then the
sequence of corrected theories has wrongness tending to `0`. -/
theorem perturbation_tendsto_truth (truth T₀ : E) (c : ℕ → E)
    (hc : HasSum c (truth - T₀)) :
    Filter.Tendsto (fun n => wrongness truth (partialTheory T₀ c n))
      Filter.atTop (𝓝 0) := by
  convert Filter.Tendsto.norm
    (hc.tendsto_sum_nat.const_add T₀ |> Filter.Tendsto.sub_const <| truth) using 2
  simp +decide

/-- **Quantitative convergence (perturbative tail bound).**  If the correction
norms are summable and `truth` is the total corrected theory, then the residual
wrongness after `n` terms is bounded by the tail of the norm series. -/
theorem perturbation_tail_bound [CompleteSpace E] (T₀ : E) (c : ℕ → E)
    (hc : Summable (fun n => ‖c n‖)) (n : ℕ) :
    wrongness (T₀ + ∑' i, c i) (partialTheory T₀ c n)
      ≤ ∑' i, ‖c (i + n)‖ := by
  have hcs : Summable c := hc.of_norm
  have hshift : Summable (fun i => ‖c (i + n)‖) := (summable_nat_add_iff n).mpr hc
  have hsum := Summable.sum_add_tsum_nat_add n hcs
  have hkey : (∑ i ∈ Finset.range n, c i) - ∑' i, c i = -(∑' i, c (i + n)) := by
    rw [← hsum]; abel
  unfold wrongness partialTheory
  have hnorm : ‖(T₀ + ∑ i ∈ Finset.range n, c i) - (T₀ + ∑' i, c i)‖
      = ‖∑' i, c (i + n)‖ := by
    rw [show (T₀ + ∑ i ∈ Finset.range n, c i) - (T₀ + ∑' i, c i)
          = (∑ i ∈ Finset.range n, c i) - ∑' i, c i by abel, hkey, norm_neg]
  rw [hnorm]
  exact norm_tsum_le_tsum_norm hshift

/-
**Explicit geometric convergence rate.**  If the correction norms decay
geometrically, `‖c i‖ ≤ M rⁱ` with `0 ≤ r < 1`, then the residual wrongness after
`n` terms decays exponentially: it is bounded by `M rⁿ / (1 − r)`.  This is the
quantitative specialization of `perturbation_tail_bound`.
-/
theorem perturbation_geometric_rate [CompleteSpace E] (T₀ : E) (c : ℕ → E)
    (M r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1) (hbound : ∀ i, ‖c i‖ ≤ M * r ^ i)
    (n : ℕ) :
    wrongness (T₀ + ∑' i, c i) (partialTheory T₀ c n) ≤ M * r ^ n / (1 - r) := by
  refine' le_trans ( WrongTheories.perturbation_tail_bound T₀ c _ n ) _;
  · exact Summable.of_nonneg_of_le ( fun i => norm_nonneg _ ) hbound ( Summable.mul_left _ ( summable_geometric_of_lt_one hr0 hr1 ) );
  · refine' le_trans ( Summable.tsum_le_tsum ( fun i => hbound _ ) _ _ ) _;
    · exact Summable.of_nonneg_of_le ( fun i => norm_nonneg _ ) ( fun i => hbound _ ) ( Summable.mul_left _ ( summable_geometric_of_lt_one hr0 hr1 |> Summable.comp_injective <| add_left_injective n ) );
    · exact Summable.mul_left _ ( summable_geometric_of_lt_one hr0 hr1 |> Summable.comp_injective <| add_left_injective _ );
    · norm_num [ pow_add, div_eq_mul_inv, tsum_mul_left, tsum_geometric_of_lt_one hr0 hr1 ];
      rw [ tsum_mul_right, tsum_geometric_of_lt_one hr0 hr1 ] ; ring_nf ; norm_num

/-- The tail bound governing perturbative convergence itself tends to `0`. -/
theorem perturbation_tail_tendsto_zero (c : ℕ → E) :
    Filter.Tendsto (fun n => ∑' i, ‖c (i + n)‖) Filter.atTop (𝓝 0) :=
  tendsto_sum_nat_add (fun m => ‖c m‖)

end Metric

/-! ## Phenomenological layer

These results use the inner product: phenomena are measurement directions and a
theory's prediction for a phenomenon is an inner product. -/

section Phenomena

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- The **prediction error** a theory `T` makes on the phenomenon (measurement
direction) `u`. -/
noncomputable def predErr (truth T u : E) : ℝ := |⟪T - truth, u⟫|

/-- **Non-degeneracy of theory-space.**  A theory equals the truth iff it makes a
perfect prediction for *every* phenomenon.  In particular, no genuinely wrong
theory can be perfect on all phenomena simultaneously. -/
theorem theory_exact_iff_all_phenomena (truth T : E) :
    T = truth ↔ ∀ u : E, ⟪T - truth, u⟫ = (0 : ℝ) := by
  constructor
  · intro h u
    subst h
    simp
  · intro h
    have h0 : (T - truth : E) = 0 := (inner_self_eq_zero (𝕜 := ℝ)).mp (h (T - truth))
    exact sub_eq_zero.mp h0

/-- **A wrong theory is perfect on the phenomena orthogonal to its error.**  If
the phenomenon `u` is orthogonal to the error vector `T - truth`, then `T`
predicts `u` exactly (its error there is `0`), no matter how wrong `T` is
overall. -/
theorem exact_on_orthogonal_phenomena (truth T u : E)
    (h : ⟪T - truth, u⟫ = (0 : ℝ)) :
    predErr truth T u = 0 := by
  rw [predErr, h, abs_zero]

/-- **The Unreasonable Effectiveness of Wrong Theories (meta-theorem).**

Let `A` be *our* (wrong) theory and `B` a rival "known correct" theory.  Suppose
`A` is genuinely wrong (`A ≠ truth`) and its error vector is *not parallel* to the
error vector of `B` (the two theories fail in different directions).  Then there
is a phenomenon `u` on which `A` predicts *exactly* the truth while `B` does not —
so on that phenomenon the wrong theory `A` strictly out-predicts its rival `B`:
`predErr truth A u = 0 < predErr truth B u`. -/
theorem wrong_theory_beats_rival (truth A B : E) (hA : A ≠ truth)
    (hpar : ∀ r : ℝ, B - truth ≠ r • (A - truth)) :
    ∃ u : E, predErr truth A u = 0 ∧ 0 < predErr truth B u := by
  -- Gram–Schmidt: `u = (B - truth) - t • (A - truth)` with `t = ⟪B-truth,A-truth⟫/⟪A-truth,A-truth⟫`.
  obtain ⟨t, ht⟩ : ∃ t : ℝ,
      ⟪(B - truth), (A - truth)⟫ = t * ⟪(A - truth), (A - truth)⟫ := by
    refine ⟨⟪B - truth, A - truth⟫ / ⟪A - truth, A - truth⟫, ?_⟩
    rw [div_mul_cancel₀ _ (ne_of_gt (by
      rw [real_inner_self_eq_norm_sq]
      exact sq_pos_of_pos (norm_pos_iff.mpr (sub_ne_zero.mpr hA))))]
  refine ⟨(B - truth) - t • (A - truth), ?_, ?_⟩ <;>
    simp_all +decide [predErr, inner_smul_right, inner_sub_right]
  · simp_all +decide [real_inner_comm, inner_sub_left]
    linarith
  · have h_norm_sq : ‖B - truth - t • (A - truth)‖ ^ 2 > 0 :=
      sq_pos_of_pos (norm_pos_iff.mpr (sub_ne_zero.mpr (hpar t)))
    simp_all +decide [norm_sub_sq_real, inner_smul_right]
    simp_all +decide [norm_smul, inner_sub_left, inner_sub_right]
    simp_all +decide [mul_pow, norm_sub_sq_real]
    linarith

end Phenomena

end WrongTheories