/-
# Subgroup Lattice Möbius Inversion for Generating Pairs

This file formalizes the exact Möbius inversion formula for counting
generating pairs in finite groups. The central identity is:

  #{(x,y) ∈ G² : ⟨x,y⟩ = G} = Σ_{H ≤ G} μ(H,G) · |H|²

where μ is the Möbius function on the subgroup lattice of G.

This connects finite group generation to incidence algebras and opens
a formal interface between probabilistic group theory and analytic
combinatorics.

## Main results

- `IsGeneratingPair`: predicate for a pair generating the full group
- `generatingPairCount`: count of generating pairs in a finite group
- `generatingPairCountWithin`: count of pairs generating exactly a subgroup H
- `pairCountInSubgroup_eq_card_sq`: |H|² counts pairs in H × H
- `subgroupMoebiusFn`: Möbius function μ(H,⊤) on the subgroup lattice
- `subgroupMoebiusFn_top`: μ(⊤,⊤) = 1
- `subgroupMoebiusFn_convolution`: the Möbius convolution identity
- `pairCount_eq_sum_generatingPairCountWithin`: the partition identity
- `generatingPairCount_eq_moebius_sum`: the exact Möbius inversion formula
- `numberTheoretic_moebius_convolution`: number-theoretic Möbius cancellation
- `moebius_bridge_parallel_structure`: bridge between subgroup and arithmetic Möbius

## References

- J.D. Dixon, "The probability of generating the symmetric group" (1969)
- P. Hall, "The Eulerian functions of a group" (1936)
-/
import Mathlib

open scoped BigOperators Classical
open Finset

noncomputable section

/-! ## Core definitions -/

/-- A pair `(g, h)` generates the full group `G` if the subgroup closure
    of `{g, h}` equals `⊤`. -/
def IsGeneratingPair (G : Type*) [Group G] (p : G × G) : Prop :=
  Subgroup.closure ({p.1, p.2} : Set G) = ⊤

/-- The number of ordered pairs `(g, h) ∈ G × G` that generate `G`. -/
def generatingPairCount (G : Type*) [Group G] [Fintype G] : ℕ :=
  Fintype.card { p : G × G // IsGeneratingPair G p }

/-- A pair generates exactly the subgroup `H` if `⟨p.1, p.2⟩ = H`. -/
def IsGeneratingPairOf (G : Type*) [Group G] (H : Subgroup G) (p : G × G) : Prop :=
  Subgroup.closure ({p.1, p.2} : Set G) = H

/-- The number of ordered pairs in `G × G` that generate exactly `H`. -/
def generatingPairCountWithin (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) : ℕ :=
  Fintype.card { p : G × G // IsGeneratingPairOf G H p }

/-- `pairCountInSubgroup G H` is `|H|²`, the number of pairs `(g,h)` with both in `H`. -/
def pairCountInSubgroup (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) : ℕ :=
  Fintype.card { p : G × G // p.1 ∈ H ∧ p.2 ∈ H }

/-! ## The generating pair count at ⊤ equals the group generating pair count -/

/-- Generating pairs for the top subgroup are exactly generating pairs for G. -/
theorem generatingPairCountWithin_top (G : Type*) [Group G] [Fintype G] :
    generatingPairCountWithin G ⊤ = generatingPairCount G := by
  unfold generatingPairCountWithin generatingPairCount IsGeneratingPairOf IsGeneratingPair
  rfl

/-! ## Pair count equals |H|² -/

/-
The pair count in a subgroup `H` equals `(Fintype.card H)^2`.
-/
theorem pairCountInSubgroup_eq_card_sq (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) :
    pairCountInSubgroup G H = (Fintype.card H) ^ 2 := by
  convert Fintype.card_prod H H using 1;
  · refine' Fintype.card_congr _;
    exact ⟨ fun p => ⟨ ⟨ p.val.1, p.prop.1 ⟩, ⟨ p.val.2, p.prop.2 ⟩ ⟩, fun p => ⟨ ⟨ p.1.val, p.2.val ⟩, p.1.prop, p.2.prop ⟩, fun p => rfl, fun p => rfl ⟩;
  · ring

/-! ## The Partition Identity

Every pair (g,h) ∈ G × G generates a unique subgroup ⟨g,h⟩.
Therefore pairs partition by their generated subgroup. -/

/-
Every pair `(g,h)` in a subgroup `H` generates a subgroup contained in `H`.
-/
theorem closure_pair_le_of_mem {G : Type*} [Group G] {H : Subgroup G}
    {g h : G} (hg : g ∈ H) (hh : h ∈ H) :
    Subgroup.closure ({g, h} : Set G) ≤ H := by
  simp +decide [ *, Subgroup.closure_le, Set.insert_subset_iff ]

/-
If a pair generates subgroup K and K ≤ H, then both elements are in H.
-/
theorem mem_of_generatingPairOf_le {G : Type*} [Group G]
    {H K : Subgroup G} {p : G × G}
    (hgen : IsGeneratingPairOf G K p) (hle : K ≤ H) :
    p.1 ∈ H ∧ p.2 ∈ H := by
  exact ⟨ hle ( hgen ▸ Subgroup.subset_closure ( Set.mem_insert _ _ ) ), hle ( hgen ▸ Subgroup.subset_closure ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) ) ⟩

/-
**The partition identity**: for any subgroup `H` of a finite group `G`,
    `|H|² = Σ_{K ≤ H} generatingPairCountWithin(K)`.

    This is the key combinatorial fact: every pair `(g,h) ∈ H × H`
    generates a unique subgroup `⟨g,h⟩ ≤ H`, and this partitions `H × H`.
-/
theorem pairCount_eq_sum_generatingPairCountWithin
    (G : Type*) [Group G] [Fintype G] (H : Subgroup G) :
    pairCountInSubgroup G H =
      ∑ K : Subgroup G, if K ≤ H then generatingPairCountWithin G K else 0 := by
  simp +decide [ pairCountInSubgroup, generatingPairCountWithin ];
  simp +decide only [Fintype.card_subtype];
  simp +decide only [card_filter];
  rw [ ← Finset.sum_filter ];
  rw [ ← Finset.sum_filter ];
  rw [ ← Finset.sum_product' ];
  rw [ ← Finset.sum_filter ];
  refine' Finset.sum_bij ( fun x hx => ( Subgroup.closure { x.1, x.2 }, x ) ) _ _ _ _ <;> simp +decide [ IsGeneratingPairOf ];
  · exact fun a b ha hb => Set.insert_subset_iff.mpr ⟨ ha, Set.singleton_subset_iff.mpr hb ⟩;
  · exact fun a x y ha hx => ⟨ ⟨ ha ( hx ▸ Subgroup.subset_closure ( Set.mem_insert _ _ ) ), ha ( hx ▸ Subgroup.subset_closure ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) ) ⟩, hx ⟩

/-! ## Möbius function on the subgroup lattice -/

/-
Strict inequality of subgroups implies strict inequality of Fintype.card.
-/
theorem Subgroup.fintype_card_lt_of_lt {G : Type*} [Group G] [Fintype G]
    {H K : Subgroup G} (h : H < K) :
    Fintype.card H < Fintype.card K := by
  exact Set.card_lt_card h

/-- The Möbius function `μ(H, ⊤)` on the subgroup lattice of a finite group `G`.
    This is defined recursively:
    - `μ(⊤, ⊤) = 1`
    - `μ(H, ⊤) = -Σ_{K > H} μ(K, ⊤)` for `H < ⊤` -/
def subgroupMoebiusFn (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) : ℤ :=
  if H = ⊤ then 1
  else - ∑ K : { K : Subgroup G // H < K },
    subgroupMoebiusFn G K.1
termination_by Fintype.card G - Fintype.card H
decreasing_by
  simp only [Fintype.card_eq_nat_card]
  have hlt : H.carrier ⊂ K.1.carrier := SetLike.coe_ssubset_coe.mpr K.2
  have hK : Nat.card H < Nat.card K.1 := Set.Finite.card_lt_card (Set.toFinite _) hlt
  have hKG : Nat.card K.1 ≤ Nat.card G := Nat.card_le_card_of_injective
    Subtype.val Subtype.val_injective
  omega

/-- The Möbius function at `⊤` equals 1. -/
@[simp]
theorem subgroupMoebiusFn_top (G : Type*) [Group G] [Fintype G] :
    subgroupMoebiusFn G ⊤ = 1 := by
  simp [subgroupMoebiusFn]

/-
The convolution identity: `Σ_{K ≥ H} μ(K, ⊤) = [H = ⊤]`.
    This is the defining property of the Möbius function on a finite poset.
-/
theorem subgroupMoebiusFn_convolution
    (G : Type*) [Group G] [Fintype G] (H : Subgroup G) :
    ∑ K : Subgroup G, (if H ≤ K then subgroupMoebiusFn G K else 0 : ℤ) =
      if H = ⊤ then 1 else 0 := by
  -- By induction on the "distance to top" (i.e., Fintype.card G - Fintype.card H), or equivalently by strong induction on Fintype.card H (decreasing).
  have h_ind : ∀ H : Subgroup G, (∑ K : Subgroup G, if H ≤ K then subgroupMoebiusFn G K else 0) = if H = ⊤ then 1 else 0 := by
    intro H
    exact (by
    by_cases hH : H = ⊤;
    · simp +decide [ hH, subgroupMoebiusFn_top ];
    · -- By definition of subgroupMoebiusFn, we have subgroupMoebiusFn G H = -∑ K : { K : Subgroup G // H < K }, subgroupMoebiusFn G K.1.
      have h_def : subgroupMoebiusFn G H = -∑ K : { K : Subgroup G // H < K }, subgroupMoebiusFn G K.1 := by
        grind +locals;
      simp +decide [ Finset.sum_ite, hH ];
      rw [ show ( Finset.filter ( fun x => H ≤ x ) Finset.univ : Finset ( Subgroup G ) ) = Finset.image ( fun x : { K : Subgroup G // H < K } => x.val ) Finset.univ ∪ { H } from ?_, Finset.sum_union ] <;> norm_num [ h_def ];
      ext K; simp [Finset.mem_insert, Finset.mem_image];
      exact ⟨ fun h => or_iff_not_imp_left.mpr fun h' => lt_of_le_of_ne h ( Ne.symm h' ), fun h => h.elim ( fun h => h.symm ▸ le_rfl ) fun h => h.le ⟩);
  exact h_ind H

/-! ## The Exact Möbius Inversion Formula -/

/-
**The exact Möbius inversion formula for generating pairs.**

    For any finite group `G`:
    `#{(x,y) ∈ G² : ⟨x,y⟩ = G} = Σ_{H ≤ G} μ(H,G) · |H|²`

    This is the central theorem connecting group generation to the
    incidence algebra of the subgroup lattice.
-/
theorem generatingPairCount_eq_moebius_sum
    (G : Type*) [Group G] [Fintype G] :
    (generatingPairCount G : ℤ) =
      ∑ H : Subgroup G, subgroupMoebiusFn G H * (Fintype.card H : ℤ) ^ 2 := by
  -- By definition of `generatingPairCount`, we have `generatingPairCount G = ∑ K, if K = ⊤ then generatingPairCountWithin G K else 0`.
  have h_def : (generatingPairCount G : ℤ) = ∑ K : Subgroup G, (if K = ⊤ then (generatingPairCountWithin G K : ℤ) else 0) := by
    simp +decide [ ← generatingPairCountWithin_top ];
  -- Using the partition identity, we rewrite the sum.
  have h_partition : (∑ H : Subgroup G, (subgroupMoebiusFn G H : ℤ) * (Fintype.card H) ^ 2) = (∑ H : Subgroup G, (subgroupMoebiusFn G H : ℤ) * (∑ K : Subgroup G, if K ≤ H then (generatingPairCountWithin G K : ℤ) else 0)) := by
    refine' Finset.sum_congr rfl fun H _ => congr_arg _ _;
    exact mod_cast pairCountInSubgroup_eq_card_sq G H ▸ mod_cast pairCount_eq_sum_generatingPairCountWithin G H;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : (∑ H : Subgroup G, (subgroupMoebiusFn G H : ℤ) * (∑ K : Subgroup G, if K ≤ H then (generatingPairCountWithin G K : ℤ) else 0)) = (∑ K : Subgroup G, (generatingPairCountWithin G K : ℤ) * (∑ H : Subgroup G, if K ≤ H then (subgroupMoebiusFn G H : ℤ) else 0)) := by
    simp +decide only [Finset.mul_sum _ _ _];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by split_ifs <;> ring );
  simp_all +decide [ Finset.sum_ite ];
  rw [ Finset.sum_eq_single ⊤ ] <;> simp_all +decide [ subgroupMoebiusFn_convolution ];
  · simp +decide [ Finset.sum_filter, subgroupMoebiusFn_top ];
  · intro H hH; have := subgroupMoebiusFn_convolution G H; simp_all +decide [ Finset.sum_ite ] ;

/-! ## Probability formulation -/

/-- The generating pair probability: the fraction of pairs that generate G. -/
def generatingPairProbability (G : Type*) [Group G] [Fintype G] : ℚ :=
  (generatingPairCount G : ℚ) / (Fintype.card G : ℚ) ^ 2

/-
The generating pair probability expressed as one plus a proper subgroup correction.
    This decomposes the probability as:
    P(generate G) = 1 + Σ_{H < G} μ(H,G) · (|H|/|G|)²
-/
theorem generatingPairProbability_eq_one_plus_proper
    (G : Type*) [Group G] [Fintype G] (hG : (Fintype.card G : ℚ) ≠ 0) :
    generatingPairProbability G =
      1 + ∑ H : Subgroup G,
        if H = ⊤ then 0
        else (subgroupMoebiusFn G H : ℚ) *
          ((Fintype.card H : ℚ) / (Fintype.card G : ℚ)) ^ 2 := by
  -- Applying the exact Möbius inversion formula for generating pairs.
  have h_exact : (generatingPairCount G : ℚ) = ∑ H : Subgroup G, (subgroupMoebiusFn G H : ℚ) * (Fintype.card H : ℚ) ^ 2 := by
    exact_mod_cast generatingPairCount_eq_moebius_sum G;
  convert congr_arg ( fun x : ℚ => x / ( Fintype.card G : ℚ ) ^ 2 ) ( h_exact ) using 1;
  simp +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', div_pow, Finset.sum_div _ _ _, add_div, hG ];
  exact Finset.sum_congr rfl fun _ _ => by ring;

/-! ## Bridge to number-theoretic Möbius function -/

/-
The number-theoretic Möbius function satisfies convolution cancellation
    on the divisor lattice: for any n > 0, `Σ_{d | n} μ(d) = [n = 1]`.
    This is the arithmetic analogue of `subgroupMoebiusFn_convolution`.
-/
theorem numberTheoretic_moebius_convolution (n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, ArithmeticFunction.moebius d = if n = 1 then 1 else 0 := by
  -- By definition of Möbius function, we know that $\sum_{d \mid n} \mu(d) = 0$ for $n > 1$.
  have h_sum_zero : ∀ n > 1, ∑ d ∈ Nat.divisors n, (ArithmeticFunction.moebius d) = 0 := by
    intro n hn;
    -- By definition of Möbius function, we know that $\sum_{d \mid n} \mu(d) = 0$ for $n > 1$. This follows from the fact that the Möbius function is the multiplicative inverse of the constant function 1 in the Dirichlet convolution.
    have h_moebius_sum : ∑ d ∈ Nat.divisors n, (ArithmeticFunction.moebius d) = (ArithmeticFunction.moebius * ArithmeticFunction.zeta) n := by
      simp +decide [ ArithmeticFunction.moebius, ArithmeticFunction.zeta ];
      rw [ Nat.sum_divisorsAntidiagonal fun x y => if y = 0 then 0 else if Squarefree x then ( -1 : ℤ ) ^ ArithmeticFunction.cardFactors x else 0 ];
      exact Finset.sum_congr rfl fun x hx => by rw [ if_neg ( Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd hn.le ( Nat.dvd_of_mem_divisors hx ) ) ( Nat.pos_of_mem_divisors hx ) ) ) ] ;
    simp_all +decide [ ArithmeticFunction.moebius_mul_coe_zeta ];
    exact if_neg hn.ne';
  rcases n with ( _ | _ | n ) <;> simp_all +decide

/-- **Bridge theorem**: Both the subgroup Möbius function and the number-theoretic
    Möbius function satisfy the same cancellation property, exhibiting group
    generation and arithmetic as parallel instances of finite-poset Möbius inversion.

    - Number-theoretic: `Σ_{d|n} μ(d) = [n=1]`
    - Subgroup lattice: `Σ_{K ≥ H} μ(K,⊤) = [H=⊤]` -/
theorem moebius_bridge_parallel_structure :
    -- Number-theoretic side
    (∀ n : ℕ, 0 < n →
      ∑ d ∈ n.divisors, ArithmeticFunction.moebius d = if n = 1 then 1 else 0) ∧
    -- Subgroup lattice side
    (∀ (G : Type*) [Group G] [Fintype G] (H : Subgroup G),
      ∑ K : Subgroup G, (if H ≤ K then subgroupMoebiusFn G K else 0 : ℤ) =
        if H = ⊤ then 1 else 0) := by
  exact ⟨numberTheoretic_moebius_convolution, fun G _ _ H => subgroupMoebiusFn_convolution G H⟩

end