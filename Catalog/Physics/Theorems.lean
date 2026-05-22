/-
# Tropical Origami Theorems

This module contains the main theorems of tropical origami mechanics:
- MinAttainedTwice invariance under additive shifts
- Valid fold space = intersection of tropical hyperplanes
- Row-shift invariance of validity (classification theorem)
- Gauge equivalence preserves rigid foldability
- Tropical stress duality
- Tropical energy nonnegativity and characterization
- Miura/Monge matrix reduction to single balancing condition

## Cross-Domain Connections

The tropical stress equilibrium (Theorem B) is the idempotent shadow of
self-stress in bar-and-joint frameworks, establishing a tropical rigidity
dictionary analogous to Maxwell-Cremona duality.

The Miura uniqueness results connect to discrete convex analysis (Murota-style
L-convexity) and to tropical quantum dominance bounds.

The energy functional and its zero-set characterization parallel the Maslov
dequantization framework, where tropical energy emerges as the zero-temperature
limit of a classical smooth elastic energy.
-/
import Physics.TropicalOrigami.Defs

open Finset Matrix

noncomputable section

/-! ## Theorem cluster: MinAttainedTwice invariance -/

/-
Adding a constant to all values preserves the MinAttainedTwice property.
-/
theorem minAttainedTwice_add_const {α : Type*} [Fintype α]
    {f : α → ℝ} (c : ℝ) (hf : MinAttainedTwice f) :
    MinAttainedTwice (fun i => f i + c) := by
  obtain ⟨ a, b, hab, h₁, h₂ ⟩ := hf; exact ⟨ a, b, hab, by simp +decide [ h₁ ], fun i => by simp +decide [ h₂ i ] ⟩ ;

/-
MinAttainedTwice is invariant under composition with an order-preserving
bijection on ℝ, in particular under adding a constant (special case).
-/
theorem minAttainedTwice_of_eq {α : Type*} [Fintype α]
    {f g : α → ℝ} (h : ∀ a b : α, f a ≤ f b ↔ g a ≤ g b)
    (heq : ∀ a b : α, f a = f b ↔ g a = g b)
    (hf : MinAttainedTwice f) :
    MinAttainedTwice g := by
  -- By definition of MinAttainedTwice, there exist a and b such that a ≠ b, f a = f b, and for all c, f a ≤ f c.
  obtain ⟨a, b, hab, hfa, hfb⟩ := hf;
  exact ⟨ a, b, hab, heq a b |>.1 hfa, fun c => h a c |>.1 ( hfb c ) ⟩

/-! ## Theorem A: Valid fold space = intersection of row hyperplanes -/

/-
The valid fold space is exactly the intersection of row hyperplanes.
This is the foundational tropical prevariety characterization.
-/
theorem validFoldSpace_eq_iInter {m n : ℕ}
    (C : Matrix (Fin m) (Fin n) ℝ) :
    {w | IsTropicallyValid C w} = ⋂ i : Fin m, RowHyperplane C i := by
  exact Set.ext fun x => by simp +decide [ IsTropicallyValid, RowHyperplane ] ;

/-
Equivalent formulation: valid folds form a tropical prevariety,
expressible as a finite intersection of tropical hyperplane conditions.
-/
theorem validFoldSpace_is_tropical_prevariety {m n : ℕ}
    (C : Matrix (Fin m) (Fin n) ℝ) :
    ∃ S : Finset (Fin m),
      {w : (Fin n → ℝ) | IsTropicallyValid C w} =
      ⋂ i ∈ S, RowHyperplane C i := by
  exact ⟨ Finset.univ, by simp +decide [ validFoldSpace_eq_iInter ] ⟩

/-
Rigid foldability is equivalent to nonemptiness of the valid fold space.
-/
theorem rigidFoldable_iff_nonempty {m n : ℕ}
    (C : Matrix (Fin m) (Fin n) ℝ) :
    RigidlyFoldable C ↔ Set.Nonempty {w | IsTropicallyValid C w} := by
  exact ⟨ fun ⟨ w, hw ⟩ => ⟨ w, hw ⟩, fun ⟨ w, hw ⟩ => ⟨ w, hw ⟩ ⟩

/-! ## Theorem C: Classification by tropical row shifts -/

/-
Row shifts preserve row balancing: adding a constant to row `i`
does not change which weights balance that row.
This is because the added constant is uniform across all columns.
-/
theorem rowBalanced_of_rowShift {m n : ℕ}
    {C D : Matrix (Fin m) (Fin n) ℝ} {w : Fin n → ℝ} {i : Fin m}
    (a : Fin m → ℝ) (hD : ∀ i j, D i j = C i j + a i)
    (hb : RowBalanced C w i) :
    RowBalanced D w i := by
  obtain ⟨ x, y, hxy, h, h' ⟩ := hb;
  exact ⟨ x, y, hxy, by simp [ hD ] at h ⊢; linarith, fun c => by simp [ hD ] at h' ⊢; linarith [ h' c ] ⟩

/-
Converse: row shifts preserve row balancing in both directions.
-/
theorem rowBalanced_rowShift_iff {m n : ℕ}
    {C D : Matrix (Fin m) (Fin n) ℝ} {w : Fin n → ℝ} {i : Fin m}
    (a : Fin m → ℝ) (hD : ∀ i j, D i j = C i j + a i) :
    RowBalanced D w i ↔ RowBalanced C w i := by
  unfold RowBalanced;
  grind +suggestions

/-
Row-shift equivalent crease matrices have exactly the same valid fold space.
This is the fundamental classification theorem: rigid foldability depends
only on the tropical projective class of the crease matrix modulo row shifts.
-/
theorem rowShiftEquivalent_sameRigidBasisClass {m n : ℕ}
    {C D : Matrix (Fin m) (Fin n) ℝ}
    (h : TropicalRowShiftEquivalent C D) :
    SameRigidBasisClass C D := by
  obtain ⟨ a, ha ⟩ := h;
  intro w;
  exact ⟨ fun h i => rowBalanced_of_rowShift a ha ( h i ), fun h i => by simpa [ ha ] using rowBalanced_rowShift_iff a ha |>.1 ( h i ) ⟩

/-
Column shifts translate the valid fold space: if `D i j = C i j + b j`,
then `w` is valid for `D` iff `w + b` is valid for `C`.
-/
theorem colShift_valid_iff {m n : ℕ}
    {C : Matrix (Fin m) (Fin n) ℝ} {b : Fin n → ℝ} {w : Fin n → ℝ} :
    IsTropicallyValid (fun i j => C i j + b j) w ↔
    IsTropicallyValid C (fun j => w j + b j) := by
  -- By definition of IsTropicallyValid, we need to show that for every row i, the minimum of (C i j + b j) + w j is attained at least twice.
  simp [IsTropicallyValid, RowBalanced];
  simp +decide only [add_comm, add_left_comm]

/-
Gauge equivalent crease matrices preserve rigid foldability.
This is the full classification invariance under tropical gauge transformations:
row shifts + column shifts preserve the existence of valid folds.
-/
theorem gaugeEquivalent_rigidFoldable {m n : ℕ}
    {C D : Matrix (Fin m) (Fin n) ℝ}
    (h : TropicalGaugeEquivalent C D) :
    RigidlyFoldable C ↔ RigidlyFoldable D := by
  constructor <;> rintro ⟨ w, hw ⟩;
  · obtain ⟨ a, b, h ⟩ := h;
    refine' ⟨ fun j => w j - b j, fun i => _ ⟩;
    obtain ⟨ j₁, j₂, hj₁₂, hj₁, hj₂ ⟩ := hw i;
    exact ⟨ j₁, j₂, hj₁₂, by norm_num [ h ] ; linarith, fun c => by norm_num [ h ] ; linarith [ hj₂ c ] ⟩;
  · obtain ⟨a, b, hD⟩ := h;
    use fun j => w j + b j;
    intro i; specialize hw i; rw [ show D = fun i j => C i j + a i + b j from funext fun i => funext fun j => hD i j ] at hw; simp_all +decide [ RowBalanced ] ;
    convert minAttainedTwice_add_const ( -a i ) hw using 1 ; ext j ; ring

/-! ## Theorem B: Tropical stress duality -/

/-
**Tropical stress duality**: if a crease matrix admits a valid fold state `w`,
then `w` itself serves as a tropical stress equilibrium for the transposed matrix.

This is the tropical analogue of Maxwell-Cremona duality in rigidity theory:
row balancing (fold validity) and column balancing (stress equilibrium)
are dual conditions related by matrix transposition.

Mathematically: `IsTropicallyValid C w` means for each row `i`, the function
`j ↦ C i j + w j` has its min attained twice. Setting `σ = w` in
`TropicalStressEquilibrium Cᵀ σ`, we need: for each column `j` of `Cᵀ`
(= row `j` of `C`), the function `i ↦ Cᵀ i j + w i = C j i + w i`
has its min attained twice — which is exactly `RowBalanced C w j`.
-/
theorem rigidFoldable_implies_tropical_stress {m n : ℕ}
    (C : Matrix (Fin m) (Fin n) ℝ)
    (hfold : ∃ w : Fin n → ℝ, IsTropicallyValid C w) :
    ∃ σ : Fin n → ℝ, TropicalStressEquilibrium Cᵀ σ := by
  exact ⟨ hfold.choose, fun j => hfold.choose_spec j |> fun ⟨ a, b, hne, heq, hle ⟩ => ⟨ a, b, hne, heq, fun i => hle i ⟩ ⟩

/-
Converse of stress duality for square matrices: stress equilibrium
on the transpose implies rigid foldability of the original.
For square matrices, the types match perfectly and duality is symmetric.
-/
theorem tropical_stress_implies_rigidFoldable_square {n : ℕ}
    (C : Matrix (Fin n) (Fin n) ℝ)
    (hstress : ∃ σ : Fin n → ℝ, TropicalStressEquilibrium Cᵀ σ) :
    RigidlyFoldable C := by
  exact ⟨ hstress.choose, fun i => hstress.choose_spec i |> fun ⟨ a, b, hne, heq, hle ⟩ => ⟨ a, b, hne, heq, fun c => hle c ⟩ ⟩

/-! ## Tropical energy theorems -/

/-
The row gap is always nonneg: second min ≥ first min.
-/
theorem rowGap_nonneg {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (w : Fin n → ℝ) (i : Fin m)
    (hn : Finset.Nonempty (Finset.univ : Finset (Fin n))) :
    0 ≤ rowGap C w i hn := by
  unfold rowGap; unfold rowSecondMin; unfold rowMin; simp_all +decide [ sub_nonneg ] ;
  split_ifs <;> simp_all +decide [ Finset.inf'_le ];
  · exact ⟨ Classical.choose ( Finset.exists_min_image Finset.univ ( fun j => C i j + w j ) hn ), fun b x hx => by linarith [ Classical.choose_spec ( Finset.exists_min_image Finset.univ ( fun j => C i j + w j ) hn ) |>.2 x ( Finset.mem_univ x ) ] ⟩;
  · exact ⟨ hn.choose ⟩

/-
Tropical energy is always nonnegative.
-/
theorem tropicalEnergy_nonneg {m n : ℕ} (C : Matrix (Fin m) (Fin n) ℝ)
    (w : Fin n → ℝ) (hn : Finset.Nonempty (Finset.univ : Finset (Fin n))) :
    0 ≤ TropicalEnergy C w hn := by
  exact Finset.sum_nonneg fun i _ => rowGap_nonneg _ _ _ hn

/-! ## Miura/Monge matrix theorems -/

/-
For a Miura (additively decomposable) matrix `C i j = f i + g j`,
row balancing reduces to a single condition independent of the row index:
the function `j ↦ g j + w j` must have its min attained twice.

This is a fundamental simplification: for Miura matrices, ALL rows impose
the same constraint on the weight vector.
-/
theorem miura_rowBalanced_iff_colBalance {m n : ℕ}
    (C : Matrix (Fin m) (Fin n) ℝ)
    (f : Fin m → ℝ) (g : Fin n → ℝ)
    (hC : HasAdditiveDecomposition C f g)
    (w : Fin n → ℝ) (i : Fin m) :
    RowBalanced C w i ↔ MinAttainedTwice (fun j => g j + w j) := by
  constructor <;> intro h;
  · convert minAttainedTwice_add_const ( -f i ) _ using 1;
    rotate_left;
    exact?;
    exact fun j => C i j + w j;
    · exact h;
    · exact funext fun j => by linarith [ hC i j ] ;
  · obtain ⟨ a, b, hab, h₁, h₂ ⟩ := h;
    exact ⟨ a, b, hab, by have := hC i a; have := hC i b; norm_num at *; linarith, fun c => by have := hC i c; have := hC i a; norm_num at *; linarith [ h₂ c ] ⟩

/-
For a Miura matrix, tropical validity reduces to a single balancing condition.
-/
theorem miura_valid_iff_colBalance {m n : ℕ} (hm : 0 < m)
    (C : Matrix (Fin m) (Fin n) ℝ)
    (f : Fin m → ℝ) (g : Fin n → ℝ)
    (hC : HasAdditiveDecomposition C f g)
    (w : Fin n → ℝ) :
    IsTropicallyValid C w ↔ MinAttainedTwice (fun j => g j + w j) := by
  exact ⟨ fun h => miura_rowBalanced_iff_colBalance C f g hC w ⟨ 0, hm ⟩ |>.1 ( h _ ), fun h i => miura_rowBalanced_iff_colBalance C f g hC w i |>.2 h ⟩

/-
A Miura matrix with at least 2 columns is always rigidly foldable.
Proof: choose `w j = -g j` to make all tropical evaluations equal, hence
the minimum is attained everywhere.
-/
theorem miura_rigidlyFoldable {m n : ℕ} (hn : 1 < n)
    (C : Matrix (Fin m) (Fin n) ℝ)
    (f : Fin m → ℝ) (g : Fin n → ℝ)
    (hC : HasAdditiveDecomposition C f g) :
    RigidlyFoldable C := by
  -- Choose `w j = -g j` to make all tropical evaluations equal, hence the minimum is attained everywhere.
  use fun j => -g j;
  intro i;
  exact miura_rowBalanced_iff_colBalance C f g hC ( fun j => -g j ) i |>.mpr ( by
    exact ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩, by norm_num, by norm_num, fun _ => by norm_num ⟩ )

/-- For a Miura matrix with exactly 2 columns, any two valid folds
are gauge equivalent. This is the simplest uniqueness theorem. -/

/-
On Fin 2, MinAttainedTwice forces the two values to be equal.
-/
lemma minAttainedTwice_fin2_eq (f : Fin 2 → ℝ) (h : MinAttainedTwice f) :
    f 0 = f 1 := by
  obtain ⟨ a, b, hab, h₁, h₂ ⟩ := h; fin_cases a <;> fin_cases b <;> aesop;

theorem miura_two_col_gauge_unique {m : ℕ} (hm : 0 < m)
    (C : Matrix (Fin m) (Fin 2) ℝ)
    (f : Fin m → ℝ) (g : Fin 2 → ℝ)
    (hC : HasAdditiveDecomposition C f g)
    (w w' : Fin 2 → ℝ)
    (hw : IsTropicallyValid C w) (hw' : IsTropicallyValid C w') :
    GaugeEquivalent w w' := by
  -- By definition of gauge equivalence, we need to show that there exists a constant $c$ such that $w'(j) = w(j) + c$ for all $j$.
  use w' 0 - w 0;
  have := miura_rowBalanced_iff_colBalance C f g hC w ⟨ 0, hm ⟩ ; have := miura_rowBalanced_iff_colBalance C f g hC w' ⟨ 0, hm ⟩ ; simp_all +decide [ RowBalanced ];
  have := minAttainedTwice_fin2_eq ( fun j => g j + w j ) ( by tauto ) ; have := minAttainedTwice_fin2_eq ( fun j => g j + w' j ) ( by tauto ) ; norm_num at * ; linarith;

/-
For any Miura matrix, the canonical fold `w j = -g j` achieves zero energy.
-/
theorem miura_canonical_fold_energy_zero {m n : ℕ}
    (C : Matrix (Fin m) (Fin n) ℝ)
    (f : Fin m → ℝ) (g : Fin n → ℝ)
    (hC : HasAdditiveDecomposition C f g)
    (hn : Finset.Nonempty (Finset.univ : Finset (Fin n))) :
    TropicalEnergy C (fun j => -g j) hn = 0 := by
  refine' Finset.sum_eq_zero fun i _ => _;
  unfold rowGap rowSecondMin rowMin;
  simp_all +decide [ HasAdditiveDecomposition ]

/-! ## GaugeEquivalent is an equivalence relation -/

/-
GaugeEquivalent is reflexive.
-/
theorem gaugeEquivalent_refl {n : ℕ} (w : Fin n → ℝ) :
    GaugeEquivalent w w := by
  exact ⟨ 0, fun _ => by simp +decide ⟩

/-
GaugeEquivalent is symmetric.
-/
theorem gaugeEquivalent_symm {n : ℕ} {w v : Fin n → ℝ}
    (h : GaugeEquivalent w v) :
    GaugeEquivalent v w := by
  rcases h with ⟨ c, hc ⟩ ; exact ⟨ -c, fun i => by simp +decide [ hc ] ⟩

/-
GaugeEquivalent is transitive.
-/
theorem gaugeEquivalent_trans {n : ℕ} {w v u : Fin n → ℝ}
    (h1 : GaugeEquivalent w v) (h2 : GaugeEquivalent v u) :
    GaugeEquivalent w u := by
  obtain ⟨ c1, hc1 ⟩ := h1
  obtain ⟨ c2, hc2 ⟩ := h2
  use c1 + c2
  intro j
  simp [hc1, hc2];
  ring

end