import Mathlib

/-!
# Tropical Compression Duality

This file provides the flagship concrete instance of the closure-compression
duality framework: **tropical normalization** on finite real-valued vectors.

The tropical normalization map subtracts the minimum coordinate from every
entry, producing a canonical representative with minimum coordinate zero.
This map is idempotent, and its fixed points are exactly the vectors that
are already normalized — the "tropically incompressible" vectors.

## Main Results

- `tropClosure_idempotent`: Tropical normalization is idempotent.
- `tropClosure_min_zero`: After normalization, the minimum coordinate is 0.
- `tropClosure_nonneg`: Normalized coordinates are nonneg.
- `tropClosure_fixed_iff_min_zero`: Fixed points ↔ min coordinate is 0.
- `tropClosure_constant_on_translation_class`: Translation-equivalent vectors
  have the same normalization.
- `tropClosure_eq_iff_translation_equiv`: Same normalization ↔ translation equivalent.
- `tropClosure_sum_eq`: Sum after normalization = sum - n * min.

## Mathematical Significance

Tropical normalization realizes the abstract closure-compression duality
in a vivid, computable setting:
- **Closure classes** = translation equivalence classes in ℝⁿ
- **Canonical representative** = unique vector with min coordinate 0
- **Incompressible objects** = already-normalized vectors
- **Compression** = one-step idempotent projection

This connects compression theory to **tropical/min-plus geometry**.
-/

open Finset

noncomputable section

namespace TropicalCompression

variable {n : ℕ}

/-- **Tropical normalization (closure).** Subtract the infimum coordinate
from every entry. -/
def tropClosure (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => x i - ⨅ j : Fin n, x j

/-
Tropical normalization is **idempotent**: normalizing a normalized
vector does nothing. This is the one-step stabilization property.
-/
theorem tropClosure_idempotent (hn : 0 < n) (x : Fin n → ℝ) :
    tropClosure (tropClosure x) = tropClosure x := by
  -- By definition of $tropClosure$, we know that $tropClosure (tropClosure x) j = tropClosure x j - ⨅ j : Fin n, tropClosure x j$.
  funext j; simp [tropClosure];
  -- Since the infimum of a set is the greatest lower bound, and we're subtracting the same value from each element, the infimum of the resulting set is zero.
  have h_inf_zero : ∀ (y : ℝ), ⨅ j, x j - y = (⨅ j, x j) - y := by
    intro y;
    rcases n with ( _ | _ | n ) <;> norm_num at *;
    · simp +decide [ Fin.eq_zero ];
    · rw [ @ciInf_sub ];
      exact Set.finite_range x |> Set.Finite.bddBelow;
  rw [ h_inf_zero, sub_self ]

/-
After normalization, the infimum coordinate is zero.
-/
theorem tropClosure_min_zero (hn : 0 < n) (x : Fin n → ℝ) :
    (⨅ j : Fin n, tropClosure x j) = 0 := by
  -- By definition of `tropClosure`, we know that `⨅ j, tropClosure x j = ⨅ j, (x j - ⨅ j, x j)`.
  simp [tropClosure];
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  · simp +decide [ Fin.eq_zero ];
  · -- Since $x$ is a function from a finite set to $\mathbb{R}$, it must attain its infimum.
    obtain ⟨j, hj⟩ : ∃ j : Fin (n + 2), x j = ⨅ j : Fin (n + 2), x j := by
      exact ( IsCompact.sInf_mem ( isCompact_range <| show Continuous x from by continuity ) <| Set.nonempty_of_mem <| Set.mem_range_self <| 0 );
    exact le_antisymm ( ciInf_le ( Finite.bddBelow_range fun j => x j - ⨅ j, x j ) j |> le_trans <| by norm_num [ hj ] ) ( by exact le_ciInf fun i => sub_nonneg_of_le <| by exact ciInf_le ( Finite.bddBelow_range x ) i )

/-
Every coordinate of the normalized vector is nonneg.
-/
theorem tropClosure_nonneg (_hn : 0 < n) (x : Fin n → ℝ) :
    ∀ j : Fin n, 0 ≤ tropClosure x j := by
  exact fun j => sub_nonneg_of_le <| ciInf_le ( Finite.bddBelow_range x ) j

/-
A vector is a fixed point of tropical normalization iff its infimum
coordinate is already zero.
-/
theorem tropClosure_fixed_iff_min_zero (hn : 0 < n) (x : Fin n → ℝ) :
    tropClosure x = x ↔ (⨅ j : Fin n, x j) = 0 := by
  constructor <;> intro h;
  · convert tropClosure_min_zero hn x using 1; aesop;
  · exact funext fun i => by simp +decide [ tropClosure, h ] ;

/-! ## Translation equivalence and uniqueness -/

/-- Two vectors are **translation equivalent** if they differ by a constant. -/
def TranslationEquiv (x y : Fin n → ℝ) : Prop :=
  ∃ c : ℝ, ∀ i, y i = x i + c

/-
Tropical normalization maps translation-equivalent vectors to the same
canonical representative.
-/
theorem tropClosure_constant_on_translation_class (x y : Fin n → ℝ)
    (h : TranslationEquiv x y) :
    tropClosure x = tropClosure y := by
  -- By definition of translation equivalence, there exists a constant $c$ such that $y_i = x_i + c$ for all $i$.
  obtain ⟨c, hc⟩ := h;
  unfold tropClosure;
  cases n <;> simp_all +decide [ sub_eq_add_neg, add_assoc ];
  · exact Subsingleton.elim _ _;
  · rw [ show ( ⨅ j : Fin ( _ + 1 ), x j + c ) = ( ⨅ j : Fin ( _ + 1 ), x j ) + c from ?_ ];
    · exact funext fun i => by ring;
    · rw [ @ciInf_add ];
      exact Set.finite_range x |> Set.Finite.bddBelow

/-
Two vectors have the same tropical closure iff they are translation
equivalent.
-/
theorem tropClosure_eq_iff_translation_equiv (_hn : 0 < n) (x y : Fin n → ℝ) :
    tropClosure x = tropClosure y ↔ TranslationEquiv x y := by
  constructor;
  · exact fun h => ⟨ ( ⨅ j, y j ) - ⨅ j, x j, fun i => by have := congr_fun h i; norm_num [ tropClosure ] at *; linarith ⟩;
  · exact fun a => tropClosure_constant_on_translation_class x y a

/-! ## Complexity surrogate: sum of coordinates -/

/-- Sum of coordinates as a complexity surrogate. -/
def coordSum (x : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, x i

/-
Normalization reduces the sum by `n * min`.
-/
theorem tropClosure_sum_eq (x : Fin n → ℝ) :
    coordSum (tropClosure x) = coordSum x - ↑n * (⨅ j : Fin n, x j) := by
  unfold coordSum tropClosure; simp +decide [ Finset.sum_sub_distrib, mul_comm ] ;

/-
When all coordinates are nonneg, normalization does not increase the sum.
-/
theorem tropClosure_sum_le_of_nonneg (_hn : 0 < n) (x : Fin n → ℝ)
    (hx : ∀ i, 0 ≤ x i) :
    coordSum (tropClosure x) ≤ coordSum x := by
  convert tropClosure_sum_eq x |> fun h => h.le.trans ( sub_le_self _ <| mul_nonneg ( Nat.cast_nonneg _ ) <| ?_ );
  exact Real.iInf_nonneg hx

end TropicalCompression

end