import Mathlib
import Logic.Defs

/-!
# Top-K Stability Theorems

Main stability theorems for top-`k` sets under Lipschitz perturbation.
The key idea: if every class in `S` has a score gap over every class outside `S`
that exceeds the potential perturbation bound, then `S` remains a strict top-k set.

## Main results

* `pairwise_gap_perturbation` — Key lemma: score gap changes by at most `2K·dist(x,y)`.
* `topk_stable_of_coordinate_lipschitz` — Pointwise stability under coordinate Lipschitz.
* `topk_stable_on_ball_of_coordinate_lipschitz` — Ball version of stability.
* `topk_stable_of_margin` — Margin-packaged version using `topkMargin'`.
* `topk_stable_of_pairwise_lipschitz` — Sharper version using pairwise Lipschitz constants.
* `topk_stable_of_pairwise_lipschitz_max` — Uniform pairwise version on a ball.
* `subset_of_topk_preserved` — Partial preservation for a target subset.
* `topk_cardinal_stability` — Order-statistic corollary for sets of cardinality `k`.
-/

open Finset

noncomputable section

variable {α : Type*} [PseudoMetricSpace α]
variable {n : ℕ}

/-! ### Key perturbation lemma -/

/-
**Pairwise gap perturbation bound.** If each coordinate `f_i` is `K`-Lipschitz,
then the score gap `f(y,i) - f(y,j)` differs from `f(x,i) - f(x,j)` by at most
`2K · dist(x,y)`. This is the fundamental inequality behind all stability results.
-/
theorem pairwise_gap_perturbation
    {f : α → Fin n → ℝ} {K : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith ⟨K, hK⟩ fun x => f x i)
    (x y : α) (i j : Fin n) :
    (f x i - f x j) - 2 * K * dist x y ≤ f y i - f y j := by
  have := hLip i; have := hLip j; simp_all +decide [ lipschitzWith_iff_dist_le_mul ] ; ring_nf at *;
  linarith [ abs_le.mp ( hLip i x y ), abs_le.mp ( hLip j x y ) ]

/-! ### Main Theorem 1: Coordinate-Lipschitz stability -/

/-
**Top-k stability under coordinate Lipschitz.** If each coordinate of `f` is
`K`-Lipschitz and every `(i,j)` gap at `x` exceeds `2K · dist(x,y)`, then `S`
remains a strict top-k set at `y`.
-/
theorem topk_stable_of_coordinate_lipschitz
    {f : α → Fin n → ℝ} {K : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith ⟨K, hK⟩ fun x => f x i)
    {x y : α} {S : Finset (Fin n)}
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S →
      2 * K * dist x y < f x i - f x j) :
    StrictTopKSet f y S := by
  intro i j hi hj; linarith [ hstrict hi hj, pairwise_gap_perturbation hK hLip x y i j ] ;

/-
**Ball version:** stability on `Metric.ball x r`.
-/
theorem topk_stable_on_ball_of_coordinate_lipschitz
    {f : α → Fin n → ℝ} {K r : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith ⟨K, hK⟩ fun x => f x i)
    {x : α} {S : Finset (Fin n)}
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → 2 * K * r < f x i - f x j) :
    ∀ ⦃y : α⦄, dist x y ≤ r → StrictTopKSet f y S := by
  intro y hy;
  apply topk_stable_of_coordinate_lipschitz hK hLip;
  exact fun i j hi hj => lt_of_le_of_lt ( mul_le_mul_of_nonneg_left hy ( mul_nonneg zero_le_two hK ) ) ( hstrict hi hj )

/-
**Margin-packaged version:** stability when `2K·r < topkMargin'`.
-/
theorem topk_stable_of_margin
    {f : α → Fin n → ℝ} {K r : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith ⟨K, hK⟩ fun x => f x i)
    {x : α} {S : Finset (Fin n)}
    (hS : S.Nonempty)
    (hSc : (finCompl S).Nonempty)
    (hmargin : 2 * K * r < topkMargin' f x S hS hSc) :
    ∀ ⦃y : α⦄, dist x y ≤ r → StrictTopKSet f y S := by
  apply topk_stable_on_ball_of_coordinate_lipschitz hK hLip;
  exact fun i j hi hj => hmargin.trans_le ( topkMargin'_le_scoreGap hi hj )

/-! ### Main Theorem 2: Pairwise-difference Lipschitz -/

/-
**Pairwise-Lipschitz stability.** The sharper version where each score difference
`f_i - f_j` has its own Lipschitz constant `L i j`, avoiding the factor of 2.
-/
theorem topk_stable_of_pairwise_lipschitz
    {f : α → Fin n → ℝ} {L : Fin n → Fin n → ℝ}
    (hL : ∀ i j, 0 ≤ L i j)
    (hLip : ∀ i j, LipschitzWith ⟨L i j, hL i j⟩ fun x => f x i - f x j)
    {x y : α} {S : Finset (Fin n)}
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S →
      L i j * dist x y < f x i - f x j) :
    StrictTopKSet f y S := by
  intro i j hi hj
  have h_diff : |(f y i - f y j) - (f x i - f x j)| ≤ L i j * dist x y := by
    have := hLip i j;
    convert this.dist_le_mul x y using 1 ; simp +decide [ dist_comm ];
    rw [ dist_eq_norm ] ; ring_nf;
    exact Real.ext_cauchy rfl;
  linarith [ abs_le.mp h_diff, hstrict hi hj ]

/-
**Uniform pairwise-Lipschitz stability on a ball.**
-/
theorem topk_stable_of_pairwise_lipschitz_max
    {f : α → Fin n → ℝ} {Lmax r : ℝ}
    (hLmax : 0 ≤ Lmax)
    (hLip : ∀ i j : Fin n, LipschitzWith ⟨Lmax, hLmax⟩ fun x => f x i - f x j)
    {x : α} {S : Finset (Fin n)}
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → Lmax * r < f x i - f x j) :
    ∀ ⦃y : α⦄, dist x y ≤ r → StrictTopKSet f y S := by
  intro y hy;
  apply_rules [ topk_stable_of_pairwise_lipschitz ];
  exact fun i j hi hj => lt_of_le_of_lt ( mul_le_mul_of_nonneg_left hy hLmax ) ( hstrict hi hj )

/-! ### Main Theorem 3: Subset preservation -/

/-
**Subset preservation.** Even if the entire top-k set may permute internally,
any class in `T ⊆ S` cannot drop below any class that started outside `S`,
provided the corresponding margin budget is positive.
-/
theorem subset_of_topk_preserved
    {f : α → Fin n → ℝ} {K r : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith ⟨K, hK⟩ fun x => f x i)
    {x : α} {S T : Finset (Fin n)}
    (_hTS : T ⊆ S)
    (hsep : ∀ ⦃i j : Fin n⦄, i ∈ T → j ∉ S → 2 * K * r < f x i - f x j) :
    ∀ ⦃y : α⦄, dist x y ≤ r → ∀ ⦃i j : Fin n⦄, i ∈ T → j ∉ S →
      f y j < f y i := by
  intro y hy i j hi hj; specialize hsep hi hj; have := hLip i; have := hLip j; simp_all +decide [ LipschitzWith ] ;
  have := pairwise_gap_perturbation hK hLip x y i j;
  nlinarith [ @dist_nonneg _ _ x y ]

/-! ### Main Theorem 4: Cardinal stability -/

/-
**Top-k cardinal stability.** If `S` has cardinality `k` and all its members
strictly dominate all outsiders by more than `2K·r`, then `S` remains the strict
top-`k` set (with cardinality `k`) at every point within distance `r`.
-/
theorem topk_cardinal_stability
    {f : α → Fin n → ℝ} {K r : ℝ} {k : ℕ}
    (hK : 0 ≤ K)
    (_hkn : k ≤ n)
    (hLip : ∀ i : Fin n, LipschitzWith ⟨K, hK⟩ fun x => f x i)
    {x : α} {S : Finset (Fin n)}
    (hcard : S.card = k)
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → 2 * K * r < f x i - f x j) :
    ∀ ⦃y : α⦄, dist x y ≤ r →
      StrictTopKSet f y S ∧ S.card = k := by
  intro y hy
  apply And.intro;
  · apply topk_stable_on_ball_of_coordinate_lipschitz hK hLip;
    exacts [ hstrict, hy ];
  · exact hcard

end