import Mathlib

/-!
# Tropical Language Evolution: Min-Plus Phylogenetics and Glottochronology

This module formalizes lexical evolution as min-plus geometry on language profiles,
establishing that tropical divergence is an exact phylogenetic distance recoverable
from tree-structured lexical drift.

## Main Definitions

* `TropLang` — A language over lexical universe `ι`, represented as `ι → ℝ`.
* `tropicalDivergence` — The L¹ coordinatewise divergence between languages.
* `tropicalSegmentCost` — The L∞ (sup-norm) tropical distance.
* `coordMedian3` — Coordinatewise median of three languages.
* `glottoTimeEstimate` — Divergence time estimator via normalized tropical divergence.
* `IsBetween` — Coordinatewise betweenness predicate for language profiles.
* `FourPointCond` — The four-point condition characterizing tree metrics.

## Main Results

### Metric Structure (Section 1)
* `tropicalDivergence_nonneg` — Tropical divergence is nonnegative.
* `tropicalDivergence_self` — Distance to self is zero.
* `tropicalDivergence_symm` — Symmetry of tropical divergence.
* `tropicalDivergence_triangle` — Triangle inequality.
* `tropicalDivergence_eq_zero_iff` — Separating property.

### Path Additivity (Section 2)
* `tropicalDivergence_additive_of_between` — Divergence is additive along
  geodesic paths where intermediates are coordinatewise between endpoints.

### Coordinatewise Median Optimality (Section 3)
* `coordMedian3_minimizes` — The median minimizes total divergence to three points.

### Glottochronology (Section 4)
* `glottochronology_from_tropical_divergence` — Divergence time is recovered
  from normalized tropical path length.

### Four-Point Condition and Tree Metrics (Section 5)
* `ultrametric_implies_fourPoint'` — Ultrametric spaces satisfy the four-point condition.
* `tropicalDivergence_fourPoint_fin1` — Four-point condition for 1D language profiles.
-/

noncomputable section

open Finset BigOperators

/-! ## Core Definitions -/

/-- A language over lexical universe `ι` is a cost profile assigning
a real-valued divergence score to each lexical item. -/
def TropLang (ι : Type*) := ι → ℝ

instance {ι : Type*} : CoeFun (TropLang ι) (fun _ => ι → ℝ) := ⟨id⟩

/-- Tropical divergence: the L¹ distance between language profiles.
Sums the absolute coordinatewise differences. This is the fundamental
phylogenetic distance functional. -/
def tropicalDivergence {ι : Type*} [Fintype ι]
    (L₁ L₂ : TropLang ι) : ℝ :=
  ∑ i : ι, |L₁ i - L₂ i|

/-- Tropical segment cost: the L∞ (sup-norm) distance between language profiles. -/
def tropicalSegmentCost {ι : Type*} [Fintype ι] [Nonempty ι]
    (L₁ L₂ : TropLang ι) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => |L₁ i - L₂ i|)

/-- Tropical lexical cost: the sum of coordinatewise minima. -/
def tropicalLexCost {ι : Type*} [Fintype ι]
    (L₁ L₂ : TropLang ι) : ℝ :=
  ∑ i : ι, min (L₁ i) (L₂ i)

/-- Coordinatewise betweenness: `M` lies between `A` and `B` if for every
coordinate, `M i` is between `A i` and `B i`. -/
def IsBetween {ι : Type*} (A M B : TropLang ι) : Prop :=
  ∀ i, (A i ≤ M i ∧ M i ≤ B i) ∨ (B i ≤ M i ∧ M i ≤ A i)

/-- Coordinatewise median of three language profiles. -/
def coordMedian3 {ι : Type*} (A B C : TropLang ι) : TropLang ι :=
  fun i => max (min (A i) (B i)) (max (min (A i) (C i)) (min (B i) (C i)))

/-- Glottochronological time estimate: tropical divergence normalized by rate. -/
def glottoTimeEstimate {ι : Type*} [Fintype ι]
    (ρ : ℝ) (L₁ L₂ : TropLang ι) : ℝ :=
  tropicalDivergence L₁ L₂ / ρ

/-- The four-point condition for a distance function, characterizing tree metrics. -/
def FourPointCond {V : Type*} (d : V → V → ℝ) : Prop :=
  ∀ a b c e,
    d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)

/-- Steiner cost of a tree: total tropical divergence across all edges. -/
def steinerTreeCost {ι : Type*} [Fintype ι]
    {V : Type*} [DecidableEq V]
    (edges : Finset (V × V)) (lang : V → TropLang ι) : ℝ :=
  ∑ e ∈ edges, tropicalDivergence (lang e.1) (lang e.2)

/-! ## Section 1: Tropical Divergence is a Metric -/

/-
Tropical divergence is nonnegative.
-/
theorem tropicalDivergence_nonneg {ι : Type*} [Fintype ι]
    (L₁ L₂ : TropLang ι) :
    0 ≤ tropicalDivergence L₁ L₂ := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
Tropical divergence of a language with itself is zero.
-/
theorem tropicalDivergence_self {ι : Type*} [Fintype ι]
    (L : TropLang ι) :
    tropicalDivergence L L = 0 := by
  exact Finset.sum_eq_zero fun i _ => abs_eq_zero.mpr ( sub_self _ )

/-
Tropical divergence is symmetric.
-/
theorem tropicalDivergence_symm {ι : Type*} [Fintype ι]
    (L₁ L₂ : TropLang ι) :
    tropicalDivergence L₁ L₂ = tropicalDivergence L₂ L₁ := by
  exact Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _

/-
Triangle inequality for tropical divergence.
-/
theorem tropicalDivergence_triangle {ι : Type*} [Fintype ι]
    (L₁ L₂ L₃ : TropLang ι) :
    tropicalDivergence L₁ L₃ ≤ tropicalDivergence L₁ L₂ + tropicalDivergence L₂ L₃ := by
  have h_triangle : ∀ i, |L₁ i - L₃ i| ≤ |L₁ i - L₂ i| + |L₂ i - L₃ i| := by
    exact fun i => abs_sub_le _ _ _;
  convert Finset.sum_le_sum fun i _ => h_triangle i using 1 ; simp +decide [ tropicalDivergence ] ; ring!;
  rw [ Finset.sum_add_distrib ]

/-
Tropical divergence separates points.
-/
theorem tropicalDivergence_eq_zero_iff {ι : Type*} [Fintype ι]
    (L₁ L₂ : TropLang ι) :
    tropicalDivergence L₁ L₂ = 0 ↔ L₁ = L₂ := by
  constructor <;> intro h;
  · exact funext fun i => sub_eq_zero.mp ( abs_eq_zero.mp ( by rw [ tropicalDivergence ] at h; exact Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => abs_nonneg _ ) |>.mp h i ( Finset.mem_univ i ) ) );
  · exact h ▸ tropicalDivergence_self L₁

/-! ## Section 2: Path Additivity and Tree Distances -/

/-
Absolute value is additive when the intermediate point is between endpoints.
-/
theorem abs_sub_additive_of_between (a m b : ℝ)
    (h : (a ≤ m ∧ m ≤ b) ∨ (b ≤ m ∧ m ≤ a)) :
    |a - b| = |a - m| + |m - b| := by
  cases h <;> cases abs_cases ( a - b ) <;> cases abs_cases ( a - m ) <;> cases abs_cases ( m - b ) <;> linarith

/-
**Theorem A (two-step path additivity).** If `M` is coordinatewise between
`A` and `B`, then tropical divergence is additive. This is the fundamental
path-additivity theorem: divergence along tree paths decomposes exactly
when intermediates represent ancestral languages.
-/
theorem tropicalDivergence_additive_of_between {ι : Type*} [Fintype ι]
    (A M B : TropLang ι) (h : IsBetween A M B) :
    tropicalDivergence A B = tropicalDivergence A M + tropicalDivergence M B := by
  unfold tropicalDivergence;
  rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl ];
  exact fun i _ => abs_sub_additive_of_between _ _ _ ( h i )

/-
Path additivity extends to three-step paths: if M₁ is between A and M₂,
and M₂ is between M₁ and B, and M₁ is between A and B, then divergence
decomposes across the full path.
-/
theorem tropicalDivergence_three_step {ι : Type*} [Fintype ι]
    (A M₁ M₂ B : TropLang ι)
    (h1 : IsBetween A M₁ B) (h2 : IsBetween A M₂ B)
    (h3 : IsBetween M₁ M₂ B) :
    tropicalDivergence A B =
      tropicalDivergence A M₁ + tropicalDivergence M₁ M₂ + tropicalDivergence M₂ B := by
  rw [ tropicalDivergence_additive_of_between A M₁ B h1, tropicalDivergence_additive_of_between M₁ M₂ B h3, add_assoc ]

/-! ## Section 3: Coordinatewise Median -/

/-
The median of three real numbers: max(min(a,b), max(min(a,c), min(b,c))).
-/
theorem real_median_eq (a b c : ℝ) :
    max (min a b) (max (min a c) (min b c)) =
      if a ≤ b then (if a ≤ c then min b c else a)
      else (if b ≤ c then min a c else b) := by
  grind

/-
The coordinatewise median lies between A and B for each coordinate.
-/
theorem coordMedian3_between_AB {ι : Type*}
    (A B C : TropLang ι) :
    IsBetween A (coordMedian3 A B C) B := by
  intro i;
  unfold coordMedian3;
  grind

/-
**Median optimality theorem.** The coordinatewise median of three
languages minimizes the total tropical divergence to all three.
This is the ancestral reconstruction principle: the optimal common
ancestor is the coordinatewise median.
-/
theorem coordMedian3_minimizes {ι : Type*} [Fintype ι]
    (A B C X : TropLang ι) :
    tropicalDivergence A (coordMedian3 A B C) +
      tropicalDivergence B (coordMedian3 A B C) +
      tropicalDivergence C (coordMedian3 A B C) ≤
    tropicalDivergence A X +
      tropicalDivergence B X +
      tropicalDivergence C X := by
  unfold tropicalDivergence coordMedian3;
  rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ];
  refine' Finset.sum_le_sum fun i _ => _;
  grind

/-! ## Section 4: Glottochronology -/

/-
**Theorem B: Glottochronology from tropical divergence.**
If tropical divergence scales linearly with tree path distance
at rate `ρ`, the divergence time is recovered by normalizing.
-/
theorem glottochronology_from_tropical_divergence
    {ι V : Type*} [Fintype ι] [Fintype V]
    (pathDist : V → V → ℝ)
    (lang : V → TropLang ι)
    (ρ : ℝ)
    (hρ : 0 < ρ)
    (h_clock : ∀ a b : V,
      tropicalDivergence (lang a) (lang b) = ρ * pathDist a b) :
    ∀ a b : V,
      glottoTimeEstimate ρ (lang a) (lang b) = pathDist a b := by
  exact fun a b => mul_div_cancel_left₀ _ hρ.ne' |> Eq.trans ( h_clock a b ▸ rfl )

/-! ## Section 5: Four-Point Condition -/

/-- An ultrametric distance: satisfies `d(a,c) ≤ max(d(a,b), d(b,c))`. -/
structure UltrametricDist {V : Type*} (d : V → V → ℝ) : Prop where
  dist_self : ∀ a, d a a = 0
  dist_symm : ∀ a b, d a b = d b a
  dist_nonneg : ∀ a b, 0 ≤ d a b
  ultra : ∀ a b c, d a c ≤ max (d a b) (d b c)

/-
Ultrametric implies four-point condition.
-/
theorem ultrametric_implies_fourPoint' {V : Type*}
    (d : V → V → ℝ) (h : UltrametricDist d) :
    FourPointCond d := by
  intros a b c e
  have h_ultra : d a c ≤ max (d a b) (d b c) ∧ d c e ≤ max (d c b) (d b e) := by
    exact ⟨ h.ultra a b c, h.ultra c b e ⟩;
  grind +splitIndPred

/-
The four-point condition is preserved under nonneg scaling.
-/
theorem fourPointCond_scale {V : Type*}
    (d : V → V → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hd : FourPointCond d) :
    FourPointCond (fun a b => c * d a b) := by
  intro a b c' d'; simp_all +decide [ mul_add, mul_max_of_nonneg ] ;
  cases max_cases ( d a c' + d b d' ) ( d a d' + d b c' ) <;> first | left; nlinarith [ hd a b c' d' ] | right; nlinarith [ hd a b c' d' ] ;

/-! ## Section 6: Tropical Algebra -/

/-
Addition distributes over min (the min-plus semiring identity).
-/
theorem tropical_plus_distributes_over_min' (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  grind

/-
Right-distributivity of addition over min.
-/
theorem tropical_right_distrib' (a b c : ℝ) :
    min a b + c = min (a + c) (b + c) := by
  grind +suggestions

/-! ## Section 7: Star Tree Four-Point Condition -/

/-
The pointwise four-point condition for real numbers: for any four reals,
`|p-q| + |r-s| ≤ max(|p-r|+|q-s|, |p-s|+|q-r|)`.
-/
theorem abs_four_point (p q r s : ℝ) :
    |p - q| + |r - s| ≤ max (|p - r| + |q - s|) (|p - s| + |q - r|) := by
  grind

/-
Tropical divergence rewrites when languages are center + drift.
-/
theorem tropicalDivergence_of_drift {ι : Type*} [Fintype ι]
    (center δ₁ δ₂ : TropLang ι)
    (L₁ L₂ : TropLang ι)
    (h₁ : ∀ i, L₁ i = center i + δ₁ i)
    (h₂ : ∀ i, L₂ i = center i + δ₂ i) :
    tropicalDivergence L₁ L₂ = ∑ i : ι, |δ₁ i - δ₂ i| := by
  exact Finset.sum_congr rfl fun i _ => by rw [ h₁, h₂ ] ; ring;;

/-
The L¹ tropical divergence satisfies the four-point condition
for one-dimensional language profiles (`ι = Fin 1`), since ℝ
is itself a tree metric space. This is the base case from which
higher-dimensional tree models are built via coordinatewise constraints.
-/
theorem tropicalDivergence_fourPoint_fin1
    (a b d e : TropLang (Fin 1)) :
    tropicalDivergence a b + tropicalDivergence d e ≤
      max (tropicalDivergence a d + tropicalDivergence b e)
          (tropicalDivergence a e + tropicalDivergence b d) := by
  norm_num [ Fin.sum_univ_one, tropicalDivergence ];
  grind

/-! ## Section 8: Tropical Divergence Congr and Additional Properties -/

/-- Tropical divergence is invariant under equal profile substitution. -/
theorem tropicalDivergence_congr {ι : Type*} [Fintype ι]
    (L₁ L₁' L₂ : TropLang ι) (h : L₁ = L₁') :
    tropicalDivergence L₁ L₂ = tropicalDivergence L₁' L₂ := by
  subst h; rfl

/-
Tropical divergence under additive shift: shifting both languages by
the same vector preserves divergence.
-/
theorem tropicalDivergence_shift_invariant {ι : Type*} [Fintype ι]
    (L₁ L₂ : TropLang ι) (c : TropLang ι) :
    tropicalDivergence (fun i => L₁ i + c i) (fun i => L₂ i + c i) =
    tropicalDivergence L₁ L₂ := by
  exact Finset.sum_congr rfl fun i _ => by simp +decide [ add_sub_add_right_eq_sub ] ;

end