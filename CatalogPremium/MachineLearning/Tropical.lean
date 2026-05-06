import Mathlib
import MachineLearning.TopKRobustness.Defs
import MachineLearning.TopKRobustness.Stability

/-!
# Tropical / Compositional Closure Lemmas

Lipschitz closure lemmas for operations used in tropical / piecewise-linear
architectures: `max`, `ReLU`, finite max-pooling (`Finset.sup'`).
Then a certified-radius corollary for tropical networks.

## Main results

* `lipschitz_max_two` — `max(g,h)` is `K`-Lipschitz when `g` and `h` are.
* `lipschitz_relu` — `ReLU` is `1`-Lipschitz.
* `lipschitz_finset_sup'` — `Finset.sup'` of Lipschitz functions is Lipschitz.
* `topk_certified_radius_of_coordinate_lipschitz` — Certified radius corollary.
-/

open Finset
open scoped NNReal

noncomputable section

variable {α : Type*} [PseudoMetricSpace α]
variable {n : ℕ}

/-! ### Lipschitz closure for max -/

/-
**Lipschitz closure for binary max.** If `g` and `h` are both `K`-Lipschitz,
then `fun x => max (g x) (h x)` is `K`-Lipschitz.
-/
theorem lipschitz_max_two
    {g h : α → ℝ} {K : ℝ≥0}
    (hg : LipschitzWith K g) (hh : LipschitzWith K h) :
    LipschitzWith K (fun x => max (g x) (h x)) := by
  rw [ lipschitzWith_iff_dist_le_mul ] at hg hh ⊢;
  intro x y;
  rw [ Real.dist_eq, abs_le ];
  constructor <;> cases max_cases ( g x ) ( h x ) <;> cases max_cases ( g y ) ( h y ) <;> linarith [ abs_le.mp ( hg x y ), abs_le.mp ( hh x y ) ]

/-
**ReLU is 1-Lipschitz.** `ReLU(z) = max(z, 0)` is 1-Lipschitz.
-/
theorem lipschitz_relu :
    LipschitzWith 1 (fun z : ℝ => max z 0) := by
  exact MeasureTheory.Lp.lipschitzWith_pos_part

/-! ### Lipschitz closure for finite max-pooling -/

/-
**Lipschitz closure for `Finset.sup'`.** If every `g b` is `K`-Lipschitz,
then the supremum over a nonempty finset is `K`-Lipschitz.
-/
theorem lipschitz_finset_sup'
    {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    {g : ι → α → ℝ} {K : ℝ≥0}
    (hg : ∀ b ∈ s, LipschitzWith K (g b)) :
    LipschitzWith K (fun x => s.sup' hs (fun b => g b x)) := by
  induction' hs using Finset.Nonempty.cons_induction with a s ha hs ih;
  · simpa using hg a ( Finset.mem_singleton_self a );
  · convert lipschitz_max_two ( hg s ( mem_cons_self _ _ ) ) ( ‹ ( ∀ b ∈ ha, LipschitzWith K ( g b ) ) → LipschitzWith K fun x => ha.sup' ih fun b => g b x › fun b hb => hg b ( Finset.mem_cons_of_mem hb ) ) using 1;
    ext x; simp +decide [*];

/-! ### Certified radius corollary for tropical networks -/

/-
**Certified radius for coordinate-Lipschitz networks.** If `r ≥ 0` and
`r < margin / (2K)`, then `S` is a strict top-k set at every point within
distance `r` of `x`.
-/
theorem topk_certified_radius_of_coordinate_lipschitz
    {f : α → Fin n → ℝ} {x : α} {S : Finset (Fin n)} {K : ℝ}
    (hK : 0 ≤ K)
    (hLip : ∀ i, LipschitzWith ⟨K, hK⟩ fun x => f x i)
    (hS : S.Nonempty)
    (hSc : (finCompl S).Nonempty) :
    ∀ {r : ℝ}, 0 ≤ r →
      r < topkMargin' f x S hS hSc / (2 * K) →
      ∀ ⦃y : α⦄, dist x y ≤ r → StrictTopKSet f y S := by
  by_cases hK' : K = 0 <;> simp_all +decide [ mul_comm ];
  exact fun _ hr y hy => topk_stable_of_margin hK hLip hS hSc ( by rw [ lt_div_iff₀ ( by positivity ) ] at hr; linarith ) hy

end