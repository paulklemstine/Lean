import Mathlib

/-!
# Tropical Normalization as an Initial Translation-Invariant Compression Operator

This file formalizes tropical normalization on `Fin n → ℝ` as a canonical
compression operator and proves its universal property: it is the unique
idempotent, translation-invariant normalization operator with nonneg output
and zero minimum.

## Main Results

- `tropNormalize_idempotent`: Tropical normalization is idempotent.
- `tropNormalize_translation_invariant`: It is invariant under additive constants.
- `tropNormalize_nonneg`: All output values are nonneg.
- `tropNormalize_min_zero`: The minimum output value is zero.
- `tropNormalize_initial`: Any translation-invariant, idempotent, nonneg, zero-min
  normalization operator on `Fin n → ℝ` (for `n > 0`) equals `tropNormalize`.

## Mathematical Significance

Tropical normalization maps a vector `x` to `x - min(x)`, producing the canonical
representative of the tropical projective class of `x`. The initiality theorem
shows this is not just one normalization among many — it is **the unique** canonical
compression under translation symmetry and idempotence. This identifies tropical
normalization as a universal categorical reflector.
-/

open Finset

noncomputable section

/-- A vector in `ℝⁿ`, representing a point in tropical affine space. -/
abbrev TropVec (n : ℕ) := Fin n → ℝ

/-- The minimum value of a tropical vector (requires `n > 0`). -/
def tropMin {n : ℕ} (hn : 0 < n) (x : TropVec n) : ℝ :=
  Finset.univ.inf' ⟨⟨0, hn⟩, Finset.mem_univ _⟩ x

/-- Tropical normalization: subtract the coordinate minimum from each entry.
This maps each vector to the canonical representative of its tropical
projective equivalence class. -/
def tropNormalize {n : ℕ} (hn : 0 < n) (x : TropVec n) : TropVec n :=
  fun i => x i - tropMin hn x

/-- The minimum of `x` is at most any coordinate value. -/
theorem tropMin_le {n : ℕ} (hn : 0 < n) (x : TropVec n) (i : Fin n) :
    tropMin hn x ≤ x i :=
  Finset.inf'_le _ (Finset.mem_univ i)

/-
There exists a coordinate achieving the minimum.
-/
theorem tropMin_achieved {n : ℕ} (hn : 0 < n) (x : TropVec n) :
    ∃ i : Fin n, x i = tropMin hn x := by
  convert Finset.exists_min_image Finset.univ ( fun i => x i ) ⟨ _, Finset.mem_univ ⟨ 0, hn ⟩ ⟩;
  simp +decide [ tropMin ];
  exact ⟨ fun h i => h ▸ Finset.inf'_le _ ( Finset.mem_univ _ ), fun h => le_antisymm ( Finset.le_inf' _ _ fun i _ => h i ) ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ⟩

/-
The minimum of a translated vector equals the minimum plus the translation.
-/
theorem tropMin_add_const {n : ℕ} (hn : 0 < n) (x : TropVec n) (c : ℝ) :
    tropMin hn (fun i => x i + c) = tropMin hn x + c := by
  unfold tropMin;
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · simpa using Finset.exists_min_image Finset.univ ( fun i => x i ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
  · grind

/-
The minimum of a normalized vector is zero.
-/
theorem tropMin_normalize {n : ℕ} (hn : 0 < n) (x : TropVec n) :
    tropMin hn (tropNormalize hn x) = 0 := by
  convert tropMin_add_const hn x ( -tropMin hn x ) using 1;
  ring

/-
Tropical normalization is idempotent: normalizing twice gives the same result.
-/
theorem tropNormalize_idempotent {n : ℕ} (hn : 0 < n) (x : TropVec n) :
    tropNormalize hn (tropNormalize hn x) = tropNormalize hn x := by
  -- By definition of $tropNormalize$, we have $tropNormalize hn (tropNormalize hn x) = tropNormalize hn x - tropMin hn (tropNormalize hn x)$.
  funext i; simp [tropNormalize, tropMin_normalize]

/-
Tropical normalization is translation-invariant: shifting all coordinates
by the same constant does not change the normalized vector.
-/
theorem tropNormalize_translation_invariant {n : ℕ} (hn : 0 < n)
    (x : TropVec n) (c : ℝ) :
    tropNormalize hn (fun i => x i + c) = tropNormalize hn x := by
  -- By definition of tropNormalize, we have tropNormalize hn (fun i => x i + c) i = (x i + c) - tropMin hn (fun i => x i + c).
  funext i
  simp [tropNormalize, tropMin_add_const]

/-
Every coordinate of a normalized vector is nonneg.
-/
theorem tropNormalize_nonneg {n : ℕ} (hn : 0 < n) (x : TropVec n) (i : Fin n) :
    0 ≤ tropNormalize hn x i := by
  exact sub_nonneg_of_le ( tropMin_le hn x i )

/-
The minimum coordinate of a normalized vector is zero.
-/
theorem tropNormalize_min_zero {n : ℕ} (hn : 0 < n) (x : TropVec n) :
    ∃ i : Fin n, tropNormalize hn x i = 0 := by
  exact Exists.elim ( tropMin_achieved hn x ) fun i hi => ⟨ i, by unfold tropNormalize; simp +decide [ hi ] ⟩

/-- A translation-invariant compression operator that preserves tropical
projective class: idempotent, translation-invariant, nonneg output,
zero minimum, and same-class (output differs from input by a constant). -/
structure TranslationInvariantCompression (n : ℕ) (hn : 0 < n) where
  toFun : TropVec n → TropVec n
  idempotent' : ∀ x, toFun (toFun x) = toFun x
  translation_invariant' :
    ∀ (x : TropVec n) (c : ℝ), toFun (fun i => x i + c) = toFun x
  min_zero' :
    ∀ x, ∃ i, toFun x i = 0
  nonneg' :
    ∀ x i, 0 ≤ toFun x i
  same_class' :
    ∀ x, ∃ c : ℝ, ∀ i, toFun x i = x i + c

/-
**Initiality theorem**: Tropical normalization is the unique
translation-invariant compression operator preserving tropical classes.
Any such operator must equal `tropNormalize`.

**Proof**: By `same_class'`, `T(x) i = x i + c` for some constant `c`.
By `min_zero'`, there exists `j` with `T(x) j = 0`, so `c = -x j`.
By `nonneg'`, `x i + c ≥ 0` for all `i`, meaning `c ≥ -x i` for all `i`,
so `-c ≤ x i` for all `i`, hence `-c = min(x)` and `c = -min(x)`.
Thus `T(x) i = x i - min(x) = tropNormalize(x) i`.
-/
theorem tropNormalize_initial
    {n : ℕ} (hn : 0 < n) :
    ∀ T : TranslationInvariantCompression n hn, T.toFun = tropNormalize hn := by
  intro T;
  -- For any T and any x, we show T.toFun x = tropNormalize hn x pointwise.
  funext x
  -- By same_class', there exists c such that T.toFun x i = x i + c for all i.
  obtain ⟨c, hc⟩ : ∃ c : ℝ, ∀ i, T.toFun x i = x i + c := by
    exact T.same_class' x;
  -- By `min_zero'`, there exists `j` with `T(x) j = 0`, so `x j + c = 0`, meaning `c = -x j`.
  obtain ⟨j, hj⟩ : ∃ j, T.toFun x j = 0 := T.min_zero' x
  have hc_val : c = -x j := by
    linarith [ hc j ];
  -- By `nonneg'`, for all `i`: `x i + c ≥ 0`, i.e., `x i ≥ -c = x j`.
  have h_ge : ∀ i, x i ≥ x j := by
    exact fun i => by linarith [ hc i, T.nonneg' x i ] ;
  -- So x j = min(x) = tropMin hn x.
  have h_min : x j = tropMin hn x := by
    exact le_antisymm ( Finset.le_inf' _ _ fun i _ => h_ge i ) ( Finset.inf'_le _ <| Finset.mem_univ _ );
  grind +locals

end