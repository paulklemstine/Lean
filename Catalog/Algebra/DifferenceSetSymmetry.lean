import Mathlib

/-!
# Difference Set Symmetry, Translation Invariance, and Diameter Bounds

This file establishes the fundamental structural properties of difference sets
of finite subsets of ℤ:

1. **Negation symmetry**: `z ∈ differenceSet S ↔ -z ∈ differenceSet S`
2. **Translation invariance**: `differenceSet (translateFinset a S) = differenceSet S`
3. **Diameter bound**: `|z| ≤ S.max' hS - S.min' hS` for `z ∈ differenceSet S`
4. **Even cardinality** of the nonzero difference set

These results promote `differenceSet` from a raw combinatorial construction to
a genuine algebraic symmetry object: it is a translation-quotient invariant
carrying a fixed-point-free involution, controlled by norm geometry.

## Mathematical significance

The difference set `{x - y | x, y ∈ S}` of a finite set `S ⊆ ℤ` encodes the
additive structure of `S`. These theorems establish that:

- The difference set is **symmetric under negation** (Theorem A), giving it
  the structure of a finite signed symmetry object with a C₂-action.
- It is **invariant under translation** (Theorem B), making it a quotient
  invariant of finite subsets modulo the translation action.
- It is **controlled by diameter geometry** (Theorem C), connecting additive
  combinatorics to metric/norm estimates.

Together, these form the first bridge from finite additive algebra to
group-action symmetry, lattice/norm geometry, and tropical support functions.
-/

noncomputable section

open Finset

/-! ## Core definitions -/

/-- The difference set of a finite set S: all values x - y for x, y ∈ S. -/
def diffSet (S : Finset ℤ) : Finset ℤ :=
  (S ×ˢ S).image (fun p => p.1 - p.2)

/-- The nonzero difference set — excludes the trivial zero difference. -/
def nonzeroDiffSet (S : Finset ℤ) : Finset ℤ :=
  (diffSet S).filter (· ≠ 0)

/-- Translation of a finite set of integers by a constant. -/
def translateFinset (a : ℤ) (S : Finset ℤ) : Finset ℤ :=
  S.image (fun x => x + a)

/-! ## Theorem A: Negation symmetry -/

/-
**Negation symmetry of the difference set.**
If `z` is a difference of elements of `S`, then so is `-z`,
since if `z = x - y` then `-z = y - x`.
-/
theorem neg_mem_diffSet_iff
    {S : Finset ℤ} {z : ℤ} :
    z ∈ diffSet S ↔ -z ∈ diffSet S := by
  constructor;
  · rintro h;
    unfold diffSet at *;
    simp_all +decide [ Finset.mem_image ];
    rcases h with ⟨ a, b, ⟨ ha, hb ⟩, rfl ⟩ ; exact ⟨ b, a, ⟨ hb, ha ⟩, by ring ⟩ ;
  · intro h;
    obtain ⟨ p, hp, h ⟩ := Finset.mem_image.mp h;
    exact Finset.mem_image.mpr ⟨ ( p.2, p.1 ), by aesop, by linarith ⟩

/-
**Negation symmetry of the nonzero difference set.**
-/
theorem neg_mem_nonzeroDiffSet_iff
    {S : Finset ℤ} {z : ℤ} :
    z ∈ nonzeroDiffSet S ↔ -z ∈ nonzeroDiffSet S := by
  constructor;
  · exact fun h => Finset.mem_filter.mpr ⟨ neg_mem_diffSet_iff.mp ( Finset.mem_filter.mp h |>.1 ), by simp [ neg_eq_zero, show z ≠ 0 from Finset.mem_filter.mp h |>.2 ] ⟩;
  · unfold nonzeroDiffSet;
    simp +zetaDelta at *;
    exact fun h1 h2 => ⟨ by rwa [ neg_mem_diffSet_iff ], h2 ⟩

/-
The nonzero difference set equals its image under negation.
-/
theorem nonzeroDiffSet_eq_image_neg
    {S : Finset ℤ} :
    nonzeroDiffSet S = (nonzeroDiffSet S).image (fun z : ℤ => -z) := by
  -- By definition of image, we have that every element in the image of a set under a function is in the set itself.
  ext z
  simp [nonzeroDiffSet, neg_mem_nonzeroDiffSet_iff];
  exact ⟨ fun h => ⟨ -z, ⟨ by simpa using neg_mem_diffSet_iff.1 h.1, by aesop ⟩, by ring ⟩, by rintro ⟨ a, ⟨ ha₁, ha₂ ⟩, rfl ⟩ ; exact ⟨ by simpa using neg_mem_diffSet_iff.1 ha₁, by aesop ⟩ ⟩

/-
**Even cardinality of the nonzero difference set.**
Negation is a fixed-point-free involution on the nonzero difference set
(since `z = -z` implies `z = 0`), so the set decomposes into pairs.
-/
theorem card_nonzeroDiffSet_even
    {S : Finset ℤ} :
    Even (nonzeroDiffSet S).card := by
  by_contra h;
  -- By definition of even, there exists an integer $k$ such that $(nonzeroDiffSet S).card = 2k + 1$.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, (nonzeroDiffSet S).card = 2 * k + 1 := by
    exact Nat.odd_iff.mpr ( Nat.mod_two_ne_zero.mp fun con => h <| Nat.even_iff.mpr con );
  have h_image : (nonzeroDiffSet S).card = (nonzeroDiffSet S |> Finset.filter (fun z => z < 0)).card + (nonzeroDiffSet S |> Finset.filter (fun z => z > 0)).card := by
    rw [ ← Finset.card_union_of_disjoint, Finset.filter_union_right ];
    · rw [ Finset.filter_true_of_mem ];
      exact fun x hx => lt_or_gt_of_ne <| Finset.mem_filter.mp hx |>.2;
    · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
  have h_image : (nonzeroDiffSet S |> Finset.filter (fun z => z < 0)).card = (nonzeroDiffSet S |> Finset.filter (fun z => z > 0)).card := by
    rw [ Finset.card_filter, Finset.card_filter ];
    apply Finset.sum_bij (fun z hz => -z);
    · exact fun x hx => neg_mem_nonzeroDiffSet_iff.mp hx;
    · aesop;
    · exact fun x hx => ⟨ -x, neg_mem_nonzeroDiffSet_iff.mp hx, by ring ⟩;
    · grind;
  omega

/-
The nonzero difference set decomposes into positive and negative halves
of equal cardinality.
-/
theorem card_nonzeroDiffSet_eq_two_mul_card_pos
    {S : Finset ℤ} :
    (nonzeroDiffSet S).card =
      2 * ((nonzeroDiffSet S).filter (fun z => 0 < z)).card := by
  have h_partition : (nonzeroDiffSet S).card = ({z ∈ nonzeroDiffSet S | 0 < z}).card + ({z ∈ nonzeroDiffSet S | z < 0}).card := by
    rw [ ← Finset.card_union_of_disjoint ];
    · congr with z;
      grind +locals;
    · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
  grind +suggestions

/-! ## Theorem B: Translation invariance -/

/-
**Translation invariance of the difference set.**
Translating `S` by a constant `a` does not change its difference set,
since `(x+a) - (y+a) = x - y`. This identifies the difference set
as a quotient invariant of finite subsets under the translation action.
-/
theorem diffSet_translate
    (a : ℤ) (S : Finset ℤ) :
    diffSet (translateFinset a S) = diffSet S := by
  ext;
  -- By definition of translateFinset, we can rewrite the membership in the difference set in terms of elements from S.
  simp [translateFinset, diffSet];
  exact ⟨ fun ⟨ x, y, h, h' ⟩ => ⟨ x + -a, y + -a, h, by linear_combination h' ⟩, fun ⟨ x, y, h, h' ⟩ => ⟨ x + a, y + a, by aesop ⟩ ⟩

/-
**Translation invariance of the nonzero difference set.**
-/
theorem nonzeroDiffSet_translate
    (a : ℤ) (S : Finset ℤ) :
    nonzeroDiffSet (translateFinset a S) = nonzeroDiffSet S := by
  unfold nonzeroDiffSet;
  rw [ diffSet_translate ]

/-! ## Theorem C: Diameter bounds -/

/-
**Diameter bound on differences.**
Every difference of elements of a nonempty finite set `S ⊆ ℤ` has absolute value
at most `max S - min S`. This connects additive combinatorics to metric geometry:
the difference set is contained in a ball of radius equal to the diameter.
-/
theorem mem_diffSet_abs_le_diam
    {S : Finset ℤ} (hS : S.Nonempty) {z : ℤ}
    (hz : z ∈ diffSet S) :
    |z| ≤ S.max' hS - S.min' hS := by
  obtain ⟨ x, hx, y, hy, rfl ⟩ := Finset.mem_image.mp hz;
  exact abs_le.mpr ⟨ by linarith [ Finset.min'_le _ _ ( Finset.mem_product.mp hx |>.1 ), Finset.le_max' _ _ ( Finset.mem_product.mp hx |>.2 ) ], by linarith [ Finset.min'_le _ _ ( Finset.mem_product.mp hx |>.2 ), Finset.le_max' _ _ ( Finset.mem_product.mp hx |>.1 ) ] ⟩

/-
Zero is always in the difference set of a nonempty set.
-/
theorem zero_mem_diffSet {S : Finset ℤ} (hS : S.Nonempty) :
    (0 : ℤ) ∈ diffSet S := by
  obtain ⟨ x, hx ⟩ := hS; exact Finset.mem_image.mpr ⟨ ( x, x ), Finset.mem_product.mpr ⟨ hx, hx ⟩, sub_self x ⟩ ;

end