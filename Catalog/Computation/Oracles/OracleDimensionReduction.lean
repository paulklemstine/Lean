/-! # CatalogBuild.Computation.Oracles.OracleDimensionReduction

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 46
-/

import Mathlib

noncomputable section

/-- A constant function is always idempotent (an oracle). -/
theorem constant_is_oracle {X : Type*} (c : X) :
    ∀ x : X, (fun _ : X => c) ((fun _ : X => c) x) = (fun _ : X => c) x :=
  fun _ => rfl




/-- The constant oracle has exactly one fixed point: the constant itself. -/
theorem constant_oracle_fixedPoints {X : Type*} [DecidableEq X] (c : X) :
    fixedPoints (fun _ : X => c) = {c} := by
  ext x; simp [fixedPoints, Function.IsFixedPt]




/-- The range of a constant function is a singleton. -/
theorem constant_range_singleton {X : Type*} [Nonempty X] (c : X) :
    range (fun _ : X => c) = {c} := by
  ext x; simp




/-- On Fin (n+1), the constant oracle compresses to exactly 1 element in its image. -/
theorem constant_oracle_card {n : ℕ} (c : Fin (n + 1)) :
    (Finset.image (fun _ : Fin (n + 1) => c) Finset.univ).card = 1 := by
  simp [Finset.image_const, Finset.univ_nonempty]




/-- A section of an oracle: a right inverse on the truth set. -/
structure OracleSection {X : Type*} (O : X → X) where
  section_map : {x : X // O x = x} → X
  right_inverse : ∀ fx : {x : X // O x = x}, O (section_map fx) = fx.val




/-- Every oracle has a canonical section: the inclusion of fixed points. -/
def canonical_section {X : Type*} (O : X → X) : OracleSection O where
  section_map := fun fx => fx.val
  right_inverse := fun fx => fx.prop




/-- The canonical section embeds fixed points back into X injectively. -/
theorem canonical_section_embedding {X : Type*} (O : X → X) :
    Function.Injective (canonical_section O).section_map :=
  fun _ _ h => Subtype.ext h




/-- The round-trip through the oracle is the oracle itself. -/
theorem round_trip {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    O ∘ O = O := funext hO




/-- Any type maps to Fin 1 via the unique map. -/
def collapse_to_one (X : Type*) : X → Fin 1 := fun _ => 0




/-- Fin 1 has exactly one element. -/
theorem fin_one_unique : ∀ x : Fin 1, x = 0 := Fin.eq_zero




/-- Any embedding from Fin 1 to Fin (n+1). -/
def embed_from_one {n : ℕ} (target : Fin (n + 1)) : Fin 1 → Fin (n + 1) :=
  fun _ => target




/-- The round trip: collapse then embed gives a constant function (an oracle!). -/
theorem collapse_embed_is_oracle {n : ℕ} (target : Fin (n + 1)) :
    ∀ x : Fin (n + 1),
    let f := embed_from_one target ∘ collapse_to_one (Fin (n + 1))
    f (f x) = f x :=
  fun _ => rfl




/-- The composition embed ∘ collapse is always an oracle (constant function). -/
theorem embed_collapse_oracle {n : ℕ} (target : Fin (n + 1)) :
    let f := embed_from_one target ∘ collapse_to_one (Fin (n + 1))
    f ∘ f = f :=
  funext fun _ => rfl




/-- The projection map from X to range(O). -/
def oracle_projection {X : Type*} (O : X → X) (_hO : ∀ x, O (O x) = O x) :
    X → range O :=
  fun x => ⟨O x, ⟨x, rfl⟩⟩




/-- The projection is surjective. -/
theorem oracle_projection_surjective {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    Surjective (oracle_projection O hO) := by
  intro ⟨y, hy⟩; obtain ⟨x, rfl⟩ := hy; exact ⟨x, rfl⟩




/-- The inclusion from range(O) to X is injective. -/
theorem oracle_inclusion_injective {X : Type*} (O : X → X) :
    Injective (Subtype.val : range O → X) :=
  Subtype.val_injective




/-- An oracle factors as projection followed by inclusion. -/
theorem oracle_factorization {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    ∀ x, (Subtype.val : range O → X) (oracle_projection O hO x) = O x :=
  fun _ => rfl




/-- O₁ refines O₂ if Fix(O₁) ⊆ Fix(O₂). -/
def oracle_refines {X : Type*} (O₁ O₂ : X → X) : Prop :=
  fixedPoints O₁ ⊆ fixedPoints O₂




/-- The identity oracle is refined by every oracle. -/
theorem id_refined_by_all {X : Type*} (O : X → X) (_hO : ∀ x, O (O x) = O x) :
    oracle_refines O id := by
  intro x _hx; simp [fixedPoints, IsFixedPt]




/-- [Section: # CatalogBuild.Computation.Oracles.OracleDimensionReduction
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 46] -/
theorem experiment_fin2_one_fixpoint :
    (Finset.filter (fun O : Fin 2 → Fin 2 =>
      (∀ x, O (O x) = O x) ∧
      (Finset.filter (fun x => O x = x) Finset.univ).card = 1)
    Finset.univ).card = 2 := by decide




/-- [Section: # CatalogBuild.Computation.Oracles.OracleDimensionReduction
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 46] -/
theorem experiment_fin2_two_fixpoints :
    (Finset.filter (fun O : Fin 2 → Fin 2 =>
      (∀ x, O (O x) = O x) ∧
      (Finset.filter (fun x => O x = x) Finset.univ).card = 2)
    Finset.univ).card = 1 := by decide




theorem experiment_fin3_one_fixpoint :
    (Finset.filter (fun O : Fin 3 → Fin 3 =>
      (∀ x, O (O x) = O x) ∧
      (Finset.filter (fun x => O x = x) Finset.univ).card = 1)
    Finset.univ).card = 3 := by decide




theorem experiment_fin3_two_fixpoints :
    (Finset.filter (fun O : Fin 3 → Fin 3 =>
      (∀ x, O (O x) = O x) ∧
      (Finset.filter (fun x => O x = x) Finset.univ).card = 2)
    Finset.univ).card = 6 := by decide




theorem experiment_fin3_three_fixpoints :
    (Finset.filter (fun O : Fin 3 → Fin 3 =>
      (∀ x, O (O x) = O x) ∧
      (Finset.filter (fun x => O x = x) Finset.univ).card = 3)
    Finset.univ).card = 1 := by decide




/-- Verification: 3 + 6 + 1 = 10 total oracles on Fin 3. -/
theorem oracle_count_fin3_sum : 3 + 6 + 1 = 10 := by norm_num




/-- The formula C(n,k) · k^(n-k) verified for small cases. -/
theorem oracle_formula_check_3_1 : Nat.choose 3 1 * 1 ^ (3 - 1) = 3 := by norm_num



theorem oracle_formula_check_3_2 : Nat.choose 3 2 * 2 ^ (3 - 2) = 6 := by norm_num



theorem oracle_formula_check_3_3 : Nat.choose 3 3 * 3 ^ (3 - 3) = 1 := by norm_num




theorem oracle_strict_dimension_reduction {n : ℕ} (O : Fin (n + 2) → Fin (n + 2))
    (hO : ∀ x, O (O x) = O x) (hne : O ≠ id) :
    Fintype.card (range O) < n + 2 := by
  simp +zetaDelta at *;
  -- Since $O$ is not injective, there exist $x \ne y$ such that $O(x) = O(y)$.
  obtain ⟨x, y, hxy⟩ : ∃ x y : Fin (n + 2), x ≠ y ∧ O x = O y := by
    grind;
  refine' lt_of_le_of_lt ( Finset.card_le_card ( show Finset.image ( O ∘ PLift.down ) Finset.univ ⊆ Finset.image O ( Finset.univ.erase x ) from _ ) ) _;
  · grind;
  · exact lt_of_le_of_lt ( Finset.card_image_le ) ( by simp +decide [ Finset.card_erase_of_mem ( Finset.mem_univ x ) ] )




/-- An oracle with 1 fixed point is equivalent to a constant function. -/
theorem one_fixpoint_is_constant {n : ℕ} (O : Fin (n + 1) → Fin (n + 1))
    (hO : ∀ x, O (O x) = O x)
    (h_one : (Finset.filter (fun x => O x = x) Finset.univ).card = 1) :
    ∃ c, ∀ x, O x = c := by
  rw [Finset.card_eq_one] at h_one
  obtain ⟨c, hc⟩ := h_one
  use c
  intro x
  have h_ox_fix : O (O x) = O x := hO x
  have : O x ∈ Finset.filter (fun x => O x = x) Finset.univ := by simp [h_ox_fix]
  rw [hc] at this; simp at this; exact this




/-- The kernel of an oracle partitions the domain into equivalence classes. -/
def oracle_kernel {X : Type*} (O : X → X) : X → X → Prop :=
  fun x y => O x = O y




/-- Each equivalence class contains exactly one fixed point. -/
theorem kernel_class_has_unique_fixpoint {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) : ∃! fp, O fp = fp ∧ O x = fp :=
  ⟨O x, ⟨hO x, rfl⟩, fun y ⟨_, hy₂⟩ => hy₂.symm⟩




theorem kernel_classes_eq_fixpoints {n : ℕ} (O : Fin n → Fin n) (hO : ∀ x, O (O x) = O x) :
    (Finset.image O Finset.univ).card = (Finset.filter (fun x => O x = x) Finset.univ).card := by
  congr 1 with x ; aesop




/-- A lifting of an oracle: the canonical lift sends each truth to itself. -/
def oracle_lift {X : Type*} (O : X → X) (_hO : ∀ x, O (O x) = O x) :
    range O → X :=
  fun ⟨y, _⟩ => y




/-- The canonical lift is a right inverse: O ∘ lift = id on range(O). -/
theorem lift_right_inverse {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    ∀ y : range O, O (oracle_lift O hO y) = y.val := by
  intro ⟨y, hy⟩; obtain ⟨x, rfl⟩ := hy; exact hO x




/-- Going down and back up doesn't recover the original: lift ∘ O = O, not id. -/
theorem lift_compose_oracle {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    ∀ x, oracle_lift O hO ⟨O x, ⟨x, rfl⟩⟩ = O x :=
  fun _ => rfl




/-- The composition of two oracles is an oracle when O₁ outputs are O₂-fixed. -/
theorem compatible_oracle_compose {X : Type*} (O₁ O₂ : X → X)
    (h₁ : ∀ x, O₁ (O₁ x) = O₁ x)
    (_h₂ : ∀ x, O₂ (O₂ x) = O₂ x)
    (h_range₁ : ∀ x, O₂ (O₁ x) = O₁ x) :
    ∀ x, (O₁ ∘ O₂) ((O₁ ∘ O₂) x) = (O₁ ∘ O₂) x := by
  intro x; simp only [comp_apply]; rw [h_range₁, h₁]




/-- The minimal oracle is unique up to the choice of fixed point. -/
theorem minimal_oracle_unique {n : ℕ} (O₁ O₂ : Fin (n + 1) → Fin (n + 1))
    (hc₁ : ∃ c, ∀ x, O₁ x = c)
    (h_same : ∀ c, (∀ x, O₁ x = c) → (∀ x, O₂ x = c)) :
    O₁ = O₂ := by
  obtain ⟨c₁, hc₁⟩ := hc₁
  exact funext fun x => (hc₁ x).trans (h_same c₁ hc₁ x).symm




/-- Oracle count formula verified for n ≤ 3. -/
theorem oracle_count_formula_n0 :
    ∑ k ∈ Finset.range 1, Nat.choose 0 k * k ^ (0 - k) = 1 := by decide



theorem oracle_count_formula_n1 :
    ∑ k ∈ Finset.range 2, Nat.choose 1 k * k ^ (1 - k) = 1 := by decide



theorem oracle_count_formula_n2 :
    ∑ k ∈ Finset.range 3, Nat.choose 2 k * k ^ (2 - k) = 3 := by decide



theorem oracle_count_formula_n3 :
    ∑ k ∈ Finset.range 4, Nat.choose 3 k * k ^ (3 - k) = 10 := by decide




/-- The "dimension spectrum" of an oracle: the size of its image. -/
def oracle_dimension {n : ℕ} (O : Fin n → Fin n) : ℕ :=
  (Finset.image O Finset.univ).card




/-- Dimension is between 1 and n+1 for Fin (n+1). -/
theorem oracle_dimension_bounds {n : ℕ} (O : Fin (n + 1) → Fin (n + 1))
    (_hO : ∀ x, O (O x) = O x) :
    1 ≤ oracle_dimension O ∧ oracle_dimension O ≤ n + 1 := by
  constructor
  · simp only [oracle_dimension]
    rw [Nat.one_le_iff_ne_zero, Finset.card_ne_zero]
    exact ⟨O 0, Finset.mem_image_of_mem _ (Finset.mem_univ _)⟩
  · exact le_trans Finset.card_image_le (by simp)




theorem id_oracle_dimension {n : ℕ} :
    oracle_dimension (id : Fin (n + 1) → Fin (n + 1)) = n + 1 := by
  unfold oracle_dimension; simp +decide ;




/-- A constant oracle has dimension 1. -/
theorem constant_oracle_dimension {n : ℕ} (c : Fin (n + 1)) :
    oracle_dimension (fun _ : Fin (n + 1) => c) = 1 := by
  simp [oracle_dimension, Finset.image_const, Finset.univ_nonempty]




end
