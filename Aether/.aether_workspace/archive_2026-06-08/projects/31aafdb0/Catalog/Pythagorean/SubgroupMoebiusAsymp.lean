/-
# Asymptotic Analysis of Generating Pair Probability

Building on the exact Möbius inversion formula from `SubgroupMoebius.lean`,
this file develops structural bounds and asymptotic analysis.

## Main results

* `generatingPairCount_le_card_sq` : |genPairs| ≤ |G|²
* `generatingPairProbability_le_one` : P ≤ 1
* `generatingPairProbability_nonneg` : P ≥ 0
* `factorial_div_factorial_pred` : n!/((n-1)!) = n (stabilizer index)
* `moebius_sum_eq_zero_at_bot` : μ-sum at ⊥ equals 0 for nontrivial groups
* `moebius_top_self` : μ(⊤, ⊤) = 1
* `generatingPairCount_moebius_decomposition` : Decomposition into top + proper sum
* `general_moebius_inversion_principle` : Abstract Möbius inversion on finite posets

## References

* Dixon, J.D. (1969). The probability of generating the symmetric group.
-/

import Mathlib
import Pythagorean.SubgroupMoebius

open scoped BigOperators Classical
open Finset Fintype

noncomputable section

/-! ## Generating pair count bounds -/

/-- The generating pair count is at most |G|². -/
theorem generatingPairCount_le_card_sq (G : Type*) [Group G] [Fintype G] :
    generatingPairCount G ≤ (Fintype.card G) ^ 2 := by
  unfold generatingPairCount
  have : Fintype.card { p : G × G // IsGeneratingPair G p } ≤ Fintype.card (G × G) :=
    Fintype.card_subtype_le _
  simp [Fintype.card_prod, sq] at this ⊢
  exact this

/-- The generating pair probability is at most 1. -/
theorem generatingPairProbability_le_one (G : Type*) [Group G] [Fintype G]
    (_hG : 0 < Fintype.card G) :
    generatingPairProbability G ≤ 1 := by
  unfold generatingPairProbability
  rw [div_le_one (by positivity)]
  exact_mod_cast generatingPairCount_le_card_sq G

/-- The generating pair probability is nonnegative. -/
theorem generatingPairProbability_nonneg (G : Type*) [Group G] [Fintype G] :
    0 ≤ generatingPairProbability G := by
  unfold generatingPairProbability
  positivity

/-! ## Point stabilizer index -/

/-- The cardinality of S_n is n!. -/
theorem card_perm_fin (n : ℕ) :
    Fintype.card (Equiv.Perm (Fin n)) = n.factorial := by
  simp [Fintype.card_perm]

/-- For n ≥ 1, n! / (n-1)! = n, giving index [S_n : S_{n-1}] = n.
    This is the source of the dominant 1/n term in nongeneration probability. -/
theorem factorial_div_factorial_pred (n : ℕ) (hn : 1 ≤ n) :
    n.factorial / (n - 1).factorial = n := by
  cases n with
  | zero => omega
  | succ n =>
    simp [Nat.factorial_succ]
    exact Nat.mul_div_cancel _ (Nat.factorial_pos n)

/-! ## Möbius function at key subgroups -/

/-- μ(⊤, ⊤) = 1 in the subgroup lattice. -/
theorem moebius_top_self (G : Type*) [Group G] [Fintype G] :
    subgroupMoebiusFn G ⊤ = 1 :=
  subgroupMoebiusFn_top G

/-- The Möbius sum at ⊥ equals 0 for any nontrivial group.
    This reflects the fact that the trivial subgroup cannot generate the group. -/
theorem moebius_sum_eq_zero_at_bot (G : Type*) [Group G] [Fintype G]
    (hG : (⊥ : Subgroup G) ≠ ⊤) :
    ∑ K : Subgroup G, (if ⊥ ≤ K then subgroupMoebiusFn G K else 0 : ℤ) = 0 := by
  rw [subgroupMoebiusFn_convolution]
  simp [hG]

/-! ## Decomposition of the generating pair count -/

/-
The generating pair count decomposes into the |G|² contribution from ⊤
    plus a correction from proper subgroups. This is the structural form that
    enables asymptotic analysis.
-/
theorem generatingPairCount_moebius_decomposition
    (G : Type*) [Group G] [Fintype G] :
    (generatingPairCount G : ℤ) =
      (Fintype.card G : ℤ) ^ 2 +
      ∑ H : Subgroup G,
        if H = ⊤ then 0
        else subgroupMoebiusFn G H * (Fintype.card H : ℤ) ^ 2 := by
  rw [ Finset.sum_ite ] ; simp +decide [ Finset.filter_ne', Finset.filter_eq' ] ; ring;
  convert generatingPairCount_eq_moebius_sum G using 1

/-- The Möbius sum over all subgroups equals the generating pair count.
    This is a restatement of the main theorem. -/
theorem moebius_weighted_sum_eq_genPairCount
    (G : Type*) [Group G] [Fintype G] :
    ∑ H : Subgroup G, subgroupMoebiusFn G H * (Fintype.card H : ℤ) ^ 2 =
      (generatingPairCount G : ℤ) :=
  (generatingPairCount_eq_moebius_sum G).symm

/-! ## Monotonicity of factorial ratios -/

/-- For n ≥ 1, ((n-1)!/n!)² = 1/n², which bounds the point-stabilizer
    contribution to the Möbius sum. -/
theorem factorial_ratio_sq (n : ℕ) (hn : 1 ≤ n) :
    ((n - 1).factorial : ℚ) ^ 2 / (n.factorial : ℚ) ^ 2 = 1 / (n : ℚ) ^ 2 := by
  cases n with
  | zero => omega
  | succ n =>
    rw [Nat.succ_sub_one, Nat.factorial_succ]
    have hfact : (n.factorial : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero n)
    have hn1 : (n + 1 : ℚ) ≠ 0 := Nat.cast_add_one_ne_zero n
    field_simp
    push_cast
    ring

/-! ## The Möbius inversion principle (general finite posets) -/

/-- **General Möbius inversion principle**: For any finite poset with bottom,
    if g = ζ * f (i.e., g(x) = Σ_{y ≤ x} f(y)), then f = μ * g
    (i.e., f(x) = Σ_{y ≤ x} μ(y,x) g(y)).

    This is the abstract principle instantiated by `generatingPairCount_eq_moebius_sum`.
    The subgroup lattice version shows that group generation is an incidence-algebra
    observable: it is the Möbius transform of the pair-counting function. -/
theorem general_moebius_inversion_principle
    {α : Type*} [PartialOrder α] [OrderBot α] [LocallyFiniteOrder α]
    [DecidableEq α] [Fintype α]
    (f g : α → ℤ) (h : ∀ x, g x = ∑ y ∈ Finset.Iic x, f y) (x : α) :
    f x = ∑ y ∈ Finset.Iic x, IncidenceAlgebra.mu ℤ y x * g y :=
  IncidenceAlgebra.moebius_inversion_bot f g h x

/-! ## Conjectures -/

/-- **Conjecture (Stabilizer dominance)**:
    For sufficiently large n, the dominant term in the nongeneration probability
    for S_n comes from the n conjugates of S_{n-1}, each contributing
    approximately ((n-1)!/n!)² to the Möbius sum. The total contribution
    is approximately n · 1/n² = 1/n.

    **Computational test**: For n ≤ 9, compute the exact generating-pair count
    and verify that |P_n - (1 - 1/n)| = O(1/n²). -/
theorem stabilizer_dominance_explanation :
    True := trivial

end