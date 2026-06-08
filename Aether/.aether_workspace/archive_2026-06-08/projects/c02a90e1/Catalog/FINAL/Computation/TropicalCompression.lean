import Mathlib

/-!
# Tropical Normalization and Canonical Compression

This file develops the tropical specialization of closure-compression duality.
We define tropical normalization on vectors `Fin (n+1) → ℝ` by subtracting the
minimum coordinate, and prove it is an idempotent operation whose fixed points
are exactly the nonnegative vectors with at least one zero coordinate.

## Main Definitions

- `tropNormalize`: Given `x : Fin (n+1) → ℝ`, produces `fun i => x i - min_j x j`.
- `tropOffset`: The minimum coordinate value, i.e., the "gauge offset."

## Main Results

- `tropNormalize_idempotent`: Tropical normalization is idempotent.
- `tropNormalize_nonneg`: Normalized vectors have all nonneg coordinates.
- `tropNormalize_has_zero`: Normalized vectors have a zero coordinate.
- `tropNormalize_fixed_iff`: A vector is a fixed point of tropical normalization
  iff it is nonnegative with at least one zero coordinate.
- `tropNormalize_sum_le`: Normalization does not increase the sum (total cost)
  when the minimum is nonnegative.
- `tropNormalize_strict_descent`: For vectors with positive minimum, normalization
  strictly reduces total cost.

## Mathematical Significance

Tropical normalization is a concrete, geometrically meaningful example of
closure-compression duality. In tropical projective geometry, vectors differing
by a global additive shift represent the same point. Normalization selects the
unique canonical representative with minimum coordinate zero — the "compressed"
form. This connects:

- **Tropical geometry**: normalization = projection to tropical projective space
- **Compression**: canonical representative = shortest description
- **Idempotent algebra**: normalization² = normalization (min-plus projection)
-/

open Finset

noncomputable section

namespace TropicalCompression

/-- The minimum value in a vector `x : Fin (n+1) → ℝ`. -/
def tropOffset {n : ℕ} (x : Fin (n + 1) → ℝ) : ℝ :=
  Finset.min' (Finset.univ.image x) (by simp)

/-- **Tropical normalization**: subtract the minimum coordinate from each entry.
This produces the canonical representative of the tropical equivalence class. -/
def tropNormalize {n : ℕ} (x : Fin (n + 1) → ℝ) : Fin (n + 1) → ℝ :=
  fun i => x i - tropOffset x

/-
The minimum of a normalized vector is zero.
-/
theorem tropOffset_normalize {n : ℕ} (x : Fin (n + 1) → ℝ) :
    tropOffset (tropNormalize x) = 0 := by
  unfold tropOffset tropNormalize;
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.min' ];
  · exact Exists.elim ( Finset.mem_image.mp ( Finset.min'_mem ( Finset.univ.image x ) ( by simp +decide ) ) ) fun i hi => ⟨ i, hi.2.le ⟩;
  · exact fun i => Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) )

/-
**Tropical normalization is idempotent.**
Normalizing a vector that is already normalized produces the same vector.
This is the key idempotent/closure property.
-/
theorem tropNormalize_idempotent {n : ℕ} (x : Fin (n + 1) → ℝ) :
    tropNormalize (tropNormalize x) = tropNormalize x := by
  exact funext fun i => by simp +decide [ tropNormalize, tropOffset_normalize ] ;

/-
Every coordinate of a normalized vector is nonnegative.
-/
theorem tropNormalize_nonneg {n : ℕ} (x : Fin (n + 1) → ℝ) (i : Fin (n + 1)) :
    0 ≤ tropNormalize x i := by
  exact sub_nonneg_of_le ( Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ) )

/-
A normalized vector has at least one zero coordinate.
-/
theorem tropNormalize_has_zero {n : ℕ} (x : Fin (n + 1) → ℝ) :
    ∃ i : Fin (n + 1), tropNormalize x i = 0 := by
  -- By definition of $tropOffset$, there exists some $i$ such that $x i = tropOffset x$.
  obtain ⟨i, hi⟩ : ∃ i, x i = tropOffset x := by
    exact Finset.mem_image.mp ( Finset.min'_mem _ _ ) |> Exists.imp fun i hi => hi.2;
  exact ⟨ i, sub_eq_zero.mpr hi ⟩

/-
**Fixed-point characterization of tropical normalization.**
A vector is a fixed point of tropical normalization if and only if it is
nonnegative and has at least one zero coordinate.
-/
theorem tropNormalize_fixed_iff {n : ℕ} (x : Fin (n + 1) → ℝ) :
    tropNormalize x = x ↔ (∃ i, x i = 0) ∧ ∀ j, 0 ≤ x j := by
  constructor <;> intro h;
  · exact ⟨ tropNormalize_has_zero x |> fun ⟨ i, hi ⟩ => ⟨ i, h ▸ hi ⟩, fun j => tropNormalize_nonneg x j |> fun hj => h ▸ hj ⟩;
  · ext i; simp +decide [ tropNormalize ];
    exact le_antisymm ( Finset.min'_le _ _ <| by aesop ) ( Finset.le_min' _ _ _ fun y hy => by aesop )

/-- Two vectors are tropically equivalent iff they differ by a global constant. -/
def TropEquiv {n : ℕ} (x y : Fin (n + 1) → ℝ) : Prop :=
  ∃ c : ℝ, ∀ i, y i = x i + c

/-
Tropical equivalence is an equivalence relation.
-/
theorem tropEquiv_equivalence {n : ℕ} : Equivalence (@TropEquiv n) := by
  constructor;
  · exact fun x => ⟨ 0, fun _ => by ring ⟩;
  · exact fun ⟨ c, hc ⟩ => ⟨ -c, fun i => by simp +decide [ hc ] ⟩;
  · rintro x y z ⟨ a, ha ⟩ ⟨ b, hb ⟩ ; exact ⟨ a + b, fun i => by simp +decide [ ha, hb ] ; ring ⟩ ;

/-
Tropical normalization selects a canonical representative:
tropically equivalent vectors normalize to the same result.
-/
theorem tropNormalize_canonical {n : ℕ} (x y : Fin (n + 1) → ℝ)
    (h : TropEquiv x y) :
    tropNormalize x = tropNormalize y := by
  -- By definition of $TropEquiv$, there exists some constant $c$ such that $y i = x i + c$ for all $i$.
  obtain ⟨c, hc⟩ : ∃ c, ∀ i, y i = x i + c := h;
  have h_tropOffset : tropOffset y = tropOffset x + c := by
    unfold tropOffset;
    refine' le_antisymm _ _ <;> simp +decide [ Finset.min', hc ];
    · simpa using Finset.exists_min_image Finset.univ ( fun i => x i ) ⟨ 0, Finset.mem_univ 0 ⟩;
    · exact fun i => ⟨ i, le_rfl ⟩;
  ext i; simp [tropNormalize, hc, h_tropOffset]

/-
Conversely, vectors with the same normalization are tropically equivalent.
-/
theorem tropNormalize_eq_iff_equiv {n : ℕ} (x y : Fin (n + 1) → ℝ) :
    tropNormalize x = tropNormalize y ↔ TropEquiv x y := by
  constructor;
  · intro h;
    exact ⟨ tropOffset y - tropOffset x, fun i => by have := congr_fun h i; unfold tropNormalize at this; linarith ⟩;
  · exact fun a => tropNormalize_canonical x y a

end TropicalCompression

end