/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The index-two obstruction to generating a finite group by two elements

For a finite group `G`, a natural probabilistic question (going back to work of
Netto, and made precise asymptotically by **Dixon's theorem** for the symmetric and
alternating groups) asks: if we pick two elements `a, b ∈ G` uniformly at random,
how likely is it that `⟨a, b⟩ = G`?

Dixon's theorem is an *asymptotic lower bound*: for `G = Sₙ` (or `Aₙ`) the
probability tends to `1` as `n → ∞`. That deep result is **not** the subject of this
file and is referenced here only as informal motivation.

This file isolates the elementary, exact **upper** obstruction that sits behind the
"`3/4` ceiling". The mechanism is purely group-theoretic:

* If `H ≤ G` is a *proper* subgroup and both chosen elements happen to lie in `H`,
  then the subgroup they generate is contained in `H`, hence is not all of `G`.
  Such pairs can never be generating pairs.
* When `H` has **index two** (`|G| = 2·|H|`), the count of these "both-in-`H`" pairs
  is `|H|² = |G|²/4`, so at least a quarter of all ordered pairs fail to generate.
  Consequently at most `3/4` of all ordered pairs can generate `G`.

The canonical index-two subgroup of `G = Sₙ` is the alternating group `Aₙ`
(the parity / sign obstruction): a pair of *even* permutations generates only even
permutations and so cannot generate `Sₙ`.

## Main results

* `bothInPairs_card`: the number of ordered pairs with both coordinates in `H` is
  `Fintype.card H ^ 2`.
* `genPairs_disjoint_bothInPairs`: for a proper `H`, no "both-in-`H`" pair is a
  generating pair (uses `Subgroup.closure_le`).
* `card_genPairs_le_compl_bothInPairs`: hence at most `|G|² - |H|²` generating pairs.
* `card_genPairs_le_three_quarters_of_card_eq_two_mul`: the clean arithmetic
  statement `4 · #genPairs ≤ 3 · |G|²` for an index-two subgroup `H`.
* `genProb_le_three_quarters`: the rational reformulation `genProb G ≤ 3/4`.
* `card_genPairs_perm_le_three_quarters`: the symmetric-group specialization using
  `H = alternatingGroup α`.

This `3/4` is an *upper* ceiling only; it says nothing about Dixon's asymptotic
*lower* bound, which requires entirely different (and far deeper) machinery.
-/

open scoped Classical

namespace SymmetricGroupGeneration

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The set of ordered pairs `(a, b)` that generate the whole group `G`. -/
noncomputable def genPairs (G : Type*) [Group G] [Fintype G] [DecidableEq G] :
    Finset (G × G) :=
  Finset.univ.filter fun p : G × G => Subgroup.closure ({p.1, p.2} : Set G) = ⊤

/-- The set of ordered pairs `(a, b)` with both coordinates inside a subgroup `H`.
These are the "parity-obstruction" pairs: when `H` is proper they can never
generate `G`. -/
noncomputable def bothInPairs (H : Subgroup G) : Finset (G × G) :=
  Finset.univ.filter fun p : G × G => p.1 ∈ H ∧ p.2 ∈ H

/-- The "both in `H`" pairs are in bijection with `H × H`, so there are exactly
`|H|²` of them. -/
omit [DecidableEq G] in
theorem bothInPairs_card (H : Subgroup G) :
    (bothInPairs H).card = Fintype.card H ^ 2 := by
  convert Fintype.card_prod (H : Set G) (H : Set G) using 1
  · convert Fintype.card_subtype (fun p : G × G => p.1 ∈ H ∧ p.2 ∈ H) using 2
    · rw [Fintype.subtype_card]
      convert rfl
    · simp +decide [Fintype.card_subtype]
      rw [← Finset.card_product]; congr; ext; aesop
  · grind

/-- A pair with both coordinates in a proper subgroup `H` cannot generate `G`:
the subgroup it generates is contained in `H` (by `Subgroup.closure_le`) and so is
not `⊤`. Hence `genPairs G` and `bothInPairs H` are disjoint. -/
theorem genPairs_disjoint_bothInPairs (H : Subgroup G) (hproper : H ≠ ⊤) :
    Disjoint (genPairs G) (bothInPairs H) := by
  rw [Finset.disjoint_left]; simp_all +decide [genPairs, bothInPairs]
  contrapose! hproper; simp_all +decide [Subgroup.eq_top_iff']
  obtain ⟨a, b, h, ha, hb⟩ := hproper; intro x
  exact h x |> fun hx =>
    Subgroup.closure_induction (fun y hy => by aesop) (by aesop) (by aesop) (by aesop) hx

/-- For a proper subgroup `H`, the generating pairs avoid the `|H|²` obstruction
pairs, so there are at most `|G|² - |H|²` of them. -/
theorem card_genPairs_le_compl_bothInPairs (H : Subgroup G) (hproper : H ≠ ⊤) :
    (genPairs G).card ≤ Fintype.card G ^ 2 - Fintype.card H ^ 2 := by
  refine le_tsub_of_add_le_right ?_
  rw [← bothInPairs_card]
  rw [← Finset.card_union_of_disjoint (genPairs_disjoint_bothInPairs H hproper)]
  exact le_trans (Finset.card_le_univ _) (by simp +decide [sq])

/-- **The index-two ceiling.** If `H` is a proper subgroup of index two
(`|G| = 2·|H|`), then at most three quarters of all ordered pairs generate `G`:
`4 · #genPairs ≤ 3 · |G|²`. -/
theorem card_genPairs_le_three_quarters_of_card_eq_two_mul
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (H : Subgroup G) (hproper : H ≠ ⊤)
    (hcard : Fintype.card G = 2 * Fintype.card H) :
    4 * (genPairs G).card ≤ 3 * Fintype.card G ^ 2 := by
  nlinarith [card_genPairs_le_compl_bothInPairs H hproper,
    Nat.sub_add_cancel (show Fintype.card G ^ 2 ≥ Fintype.card H ^ 2 by nlinarith)]

/-- The probability that a uniformly random ordered pair generates `G`. -/
noncomputable def genProb (G : Type*) [Group G] [Fintype G] [DecidableEq G] : ℚ :=
  ((genPairs G).card : ℚ) / (Fintype.card G : ℚ) ^ 2

/-- The rational reformulation of the index-two ceiling: `genProb G ≤ 3/4`. -/
theorem genProb_le_three_quarters
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (H : Subgroup G) (hproper : H ≠ ⊤)
    (hcard : Fintype.card G = 2 * Fintype.card H) :
    genProb G ≤ (3 : ℚ) / 4 := by
  convert div_le_div_of_nonneg_right
      (show (genPairs G |> Finset.card : ℚ) ≤ 3 / 4 * (Fintype.card G : ℚ) ^ 2 by
        rw [div_mul_eq_mul_div, le_div_iff₀] <;> norm_cast
        linarith [card_genPairs_le_three_quarters_of_card_eq_two_mul H hproper hcard])
      (sq_nonneg (Fintype.card G : ℚ)) using 1
  rw [mul_div_cancel_right₀ _ (pow_ne_zero 2 (by norm_cast; exact Fintype.card_ne_zero))]

/-!
### Specialization to the symmetric group

For `G = Equiv.Perm α` the canonical index-two subgroup is `alternatingGroup α`,
the kernel of the sign homomorphism. Mathlib provides:

* `alternatingGroup.index_eq_two` : the alternating group has index `2`
  (for `Nontrivial α`), which forces it to be a *proper* subgroup; and
* `two_mul_card_alternatingGroup` : `2 * card (alternatingGroup α) = card (Perm α)`,
  i.e. `|Sₙ| = 2 · |Aₙ|`.

These are exactly the two inputs to the general index-two ceiling, so the `3/4`
upper bound transfers to `Sₙ` with no extra work. The hypothesis `2 ≤ card α`
is needed precisely to make `α` nontrivial; without it `alternatingGroup α = ⊤`
(the symmetric group on `0` or `1` points is trivial) and the bound is false.
-/

/-- **Symmetric-group ceiling (parity obstruction).** For `α` with at least two
elements, at most three quarters of all ordered pairs of permutations generate the
full symmetric group `Equiv.Perm α`. The obstruction is the parity/sign map: a pair
of even permutations generates only even permutations. -/
theorem card_genPairs_perm_le_three_quarters {α : Type*} [Fintype α] [DecidableEq α]
    (hα : 2 ≤ Fintype.card α) :
    4 * (genPairs (Equiv.Perm α)).card ≤ 3 * Fintype.card (Equiv.Perm α) ^ 2 := by
  convert card_genPairs_le_three_quarters_of_card_eq_two_mul (alternatingGroup α) ?_ ?_
  · simp +decide [Subgroup.eq_top_iff']
    obtain ⟨x, y, hxy⟩ := Fintype.one_lt_card_iff.mp hα
    exact ⟨Equiv.swap x y, by simp +decide [hxy]⟩
  · convert two_mul_card_alternatingGroup.symm
    exact Fintype.one_lt_card_iff_nontrivial.mp hα

end SymmetricGroupGeneration