import Mathlib

/-!
# Independence ratio, colourings, and the fractional chromatic lower bound

This file develops the finite-graph combinatorics underlying the Hadwiger–Nelson /
fractional-chromatic-number circle of problems.  The *independence ratio* of a finite
graph `G` on `n > 0` vertices is `i(G) = α(G) / n`, where `α(G) = G.indepNum` is the
independence number.  The motivating question (Erdős 1987; Matolcsi–Ruzsa–Varga–Zsámboki)
asks whether a finite unit-distance graph in the plane can have `i(G) < 1/4`; a positive
answer forces the *fractional* chromatic number of the plane to exceed `4`.

Here we prove the two structural inequalities that make "`i(G) < 1/4`" a lower bound on
colourings:

* `SimpleGraph.card_le_colors_mul_indepNum` — the integral pigeonhole bound
  `n ≤ k · α(G)` for any proper `k`-colouring (each colour class is independent).
* `SimpleGraph.not_colorable_four_of_indepRatio_lt` and
  `SimpleGraph.four_lt_chromaticNumber_of_indepRatio_lt` — if `i(G) < 1/4` then `G` is
  not `4`-colourable and `χ(G) > 4`.
* `SimpleGraph.FracColoring` — a *fractional* colouring (nonnegative weights on
  independent sets covering every vertex), with
  `SimpleGraph.FracColoring.value_ge_of_indepNum` giving the LP lower bound
  `value ≥ n / α(G)`, and `SimpleGraph.four_lt_fracValue_of_indepRatio_lt` giving the
  fractional analogue: if `i(G) < 1/4` then **every** fractional colouring has value `> 4`,
  i.e. `χ_f(G) > 4`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the reason a small independence ratio forces many colours is
purely the LP-duality inequality `value(fractional colouring) ≥ n/α`; the "1/4" threshold
is just `α/n < 1/4 ⇔ n/α > 4`.  Bold form: the *fractional* bound, not only the integral
one, follows from a one-line double-counting of the covering constraint.
Experiment (Experimenter): for the integral bound, partition the vertex set into colour
classes via `Finset.card_eq_sum_card_fiberwise`, bound each class by `indepNum` through
`IsIndepSet.card_le_indepNum`, and sum.  For the fractional bound, double-count
`∑_v ∑_{s ∋ v} w s = ∑_s w s · |s|`, then use `|s| ≤ α` on the support.
Analysis (Analyst): the integral statement is the special case where the weights are the
indicators of the colour classes; the fractional statement is strictly stronger and is the
one relevant to `χ_f(ℝ²) > 4`.  The threshold `1/4` is sharp in the sense that it is exactly
the reciprocal of the conjectured value `χ_f(ℝ²) = 4`.
Critique (Critic): the covering hypothesis `covers` (each vertex has total weight ≥ 1) and
the support hypothesis (`w s ≠ 0 → IsIndepSet s`) are both load-bearing: dropping `covers`
makes `value = 0` admissible; dropping the support constraint lets a single all-vertex set
carry the weight and destroys the `|s| ≤ α` step.  `n > 0` is needed to divide.
Synthesis (PI): these inequalities are the graph-theoretic engine converting the geometric
construction "a finite planar unit-distance graph with `i(G) < 1/4`" into the analytic
conclusion "`χ_f(ℝ²) > 4`".
-- !-- end Lab Notes -- !--
-/

open Finset

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-
**Pigeonhole / colour-class bound.**  In any proper `k`-colouring the vertex set is
partitioned into `k` independent colour classes, each of size at most `α(G)`, hence
`n ≤ k · α(G)`.
-/
omit [DecidableEq V] [DecidableRel G.Adj] in
theorem card_le_colors_mul_indepNum {k : ℕ} (C : G.Coloring (Fin k)) :
    Fintype.card V ≤ k * G.indepNum := by
  -- By definition of $C$, each color class is an independent set.
  have h_indep_class : ∀ (c : Fin k), ∀ v ∈ Finset.filter (fun v => C v = c) Finset.univ, ∀ w ∈ Finset.filter (fun v => C v = c) Finset.univ, v ≠ w → ¬G.Adj v w := by
    exact fun c v hv w hw hne hadj => by have := C.valid hadj; aesop;
  -- By definition of $C$, each color class is an independent set, so its size is at most $\alpha(G)$.
  have h_card_indep_class : ∀ (c : Fin k), (Finset.filter (fun v => C v = c) Finset.univ).card ≤ G.indepNum := by
    exact fun c => IsIndepSet.card_le_indepNum (h_indep_class c)
  convert Finset.sum_le_sum fun c ( hc : c ∈ Finset.univ ) => h_card_indep_class c;
  · simp +decide only [card_filter];
    rw [ Finset.sum_comm ] ; aesop;
  · simp +decide

/-- The independence ratio `i(G) = α(G) / n` as a rational number. -/
noncomputable def indepRatio : ℚ := (G.indepNum : ℚ) / (Fintype.card V : ℚ)

/-
If the independence ratio is below `1/4`, then `G` is not `4`-colourable.
-/
omit [DecidableEq V] [DecidableRel G.Adj] in
theorem not_colorable_four_of_indepRatio_lt (hpos : 0 < Fintype.card V)
    (h : G.indepRatio < 1 / 4) : ¬ G.Colorable 4 := by
  contrapose! h;
  obtain ⟨C⟩ := h;
  rw [ SimpleGraph.indepRatio, div_le_div_iff₀ ] <;> norm_cast;
  linarith [ card_le_colors_mul_indepNum G C ]

/-
If the independence ratio is below `1/4`, the chromatic number exceeds `4`.
-/
omit [DecidableEq V] [DecidableRel G.Adj] in
theorem four_lt_chromaticNumber_of_indepRatio_lt (hpos : 0 < Fintype.card V)
    (h : G.indepRatio < 1 / 4) : (4 : ℕ∞) < G.chromaticNumber := by
  convert not_colorable_four_of_indepRatio_lt G hpos h using 1;
  rw [ ← SimpleGraph.chromaticNumber_le_iff_colorable ];
  simp +zetaDelta at *

/-! ### Fractional colourings -/

/-- A **fractional colouring** of `G`: nonnegative rational weights on the subsets of `V`,
supported on independent sets, such that the total weight covering each vertex is at least
`1`.  Its `value` is the total weight. -/
structure FracColoring where
  /-- Weight assigned to each subset of vertices. -/
  w : Finset V → ℚ
  /-- Weights are nonnegative. -/
  nonneg : ∀ s, 0 ≤ w s
  /-- Only independent sets may carry positive weight. -/
  supp_indep : ∀ s, w s ≠ 0 → G.IsIndepSet (s : Set V)
  /-- Every vertex is covered with total weight at least `1`. -/
  covers : ∀ v : V, 1 ≤ ∑ s ∈ (Finset.univ : Finset V).powerset, if v ∈ s then w s else 0

/-- The value (total weight) of a fractional colouring. -/
def FracColoring.value (F : G.FracColoring) : ℚ :=
  ∑ s ∈ (Finset.univ : Finset V).powerset, F.w s

/-
**LP lower bound for fractional colourings.**  Any fractional colouring has value at
least `n / α(G)`, obtained by double-counting the covering constraint.
-/
omit [DecidableRel G.Adj] in
theorem FracColoring.value_ge_of_indepNum (F : G.FracColoring) (hα : 0 < G.indepNum) :
    (Fintype.card V : ℚ) / (G.indepNum : ℚ) ≤ F.value := by
  rw [ div_le_iff₀ ( Nat.cast_pos.mpr hα ) ];
  have h_double_count : ∑ v : V, ∑ s ∈ (Finset.univ : Finset V).powerset, (if v ∈ s then F.w s else 0) ≤ ∑ s ∈ (Finset.univ : Finset V).powerset, (G.indepNum : ℚ) * F.w s := by
    rw [ Finset.sum_comm ];
    gcongr;
    by_cases h : F.w ‹_› = 0 <;> simp_all +decide;
    exact mul_le_mul_of_nonneg_right ( mod_cast F.supp_indep _ h |> fun h => h.card_le_indepNum ) ( F.nonneg _ );
  convert h_double_count.trans' _ using 1;
  · rw [ ← Finset.mul_sum _ _ _, mul_comm, value ];
  · exact le_trans ( by simp +decide ) ( Finset.sum_le_sum fun v _ => F.covers v )

/-- Weight function of the trivial (singleton) fractional colouring: weight `1` on every
singleton subset, `0` elsewhere. -/
noncomputable def singletonWeight (_ : SimpleGraph V) (s : Finset V) : ℚ :=
  if s.card = 1 then 1 else 0

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma singletonWeight_nonneg (s : Finset V) : 0 ≤ G.singletonWeight s := by
  unfold singletonWeight; split <;> norm_num

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma singletonWeight_supp_indep (s : Finset V) (hs : G.singletonWeight s ≠ 0) :
    G.IsIndepSet (s : Set V) := by
  unfold singletonWeight at hs;
  obtain ⟨ v, hv ⟩ := Finset.card_eq_one.mp ( by aesop : Finset.card s = 1 ) ; simp_all +decide [ SimpleGraph.isIndepSet_iff ] ;

omit [DecidableRel G.Adj] in
lemma singletonWeight_covers (v : V) :
    1 ≤ ∑ s ∈ (Finset.univ : Finset V).powerset,
      if v ∈ s then G.singletonWeight s else 0 := by
  refine' le_trans _ ( Finset.single_le_sum ( fun s _ => _ ) ( Finset.mem_powerset.mpr ( Finset.singleton_subset_iff.mpr ( Finset.mem_univ v ) ) ) ) <;> simp +decide [ singletonWeight ];
  split_ifs <;> norm_num

/-- The trivial fractional colouring: weight `1` on every singleton.  This shows the type of
fractional colourings is inhabited, so the lower bound is not vacuous. -/
noncomputable def FracColoring.singletons : G.FracColoring where
  w := G.singletonWeight
  nonneg := G.singletonWeight_nonneg
  supp_indep := G.singletonWeight_supp_indep
  covers := G.singletonWeight_covers

/-
**Fractional analogue of the `1/4` threshold.**  If the independence ratio is below
`1/4`, then *every* fractional colouring has value strictly greater than `4`; equivalently
`χ_f(G) > 4`.
-/
omit [DecidableRel G.Adj] in
theorem four_lt_fracValue_of_indepRatio_lt (hpos : 0 < Fintype.card V)
    (hα : 0 < G.indepNum) (h : G.indepRatio < 1 / 4) (F : G.FracColoring) :
    4 < F.value := by
  have h_inv : (G.indepNum : ℚ) / (Fintype.card V : ℚ) < 1 / 4 := by
    convert h using 1;
  rw [ div_lt_iff₀ ] at h_inv <;> norm_cast at *;
  refine' lt_of_lt_of_le _ ( FracColoring.value_ge_of_indepNum G F hα );
  rw [ lt_div_iff₀ ] <;> first | positivity | linarith;

end SimpleGraph