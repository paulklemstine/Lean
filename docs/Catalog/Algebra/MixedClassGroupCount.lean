/-
# Counting the intermediate fields of a Hilbert class field with a mixed class group

This file continues the conditional Hilbert class field thread.  The previous cycles counted the
intermediate fields of a Hilbert class field datum `e : Gal(H/K) ≃* Cl(𝒪_K)` when the class group
is cyclic (`Catalog/NumberTheory/CyclicClassGroupDescent.lean`) or elementary abelian
(`Catalog/NumberTheory/ElementaryAbelianClassField.lean`, the Galois `p`-binomial count), and
proved multiplicativity of the subgroup count over a *binary* coprime product
(`Catalog/Algebra/SubgroupCountFiniteAbelian.lean`).

Here we

* upgrade multiplicativity from two factors to an arbitrary finite family
  (`card_subgroup_pi_of_pairwise_coprime`), which is the group-theoretic shape of the primary
  decomposition;
* identify the subgroup count of an elementary abelian group with the Galois number
  (`card_subgroup_elementaryAbelian` : `#Subgroup (ℤ/p)^r = G_p(r)`), thereby linking the
  `q`-Pascal arithmetic of `Catalog/Algebra/GaussianBinomialPascal.lean` to the subspace count of
  `Catalog/NumberTheory/SubspaceCounting.lean` (`gaussBinom_eq` : the two definitions of the
  Gaussian binomial coefficient in the catalog agree definitionally);
* combine the two into the **mixed count**: if `Cl(𝒪_K) ≃ (ℤ/p)^r × (ℤ/q)^s` for distinct primes
  `p ≠ q`, then the datum has exactly `G_p(r) · G_q(s)` intermediate fields
  (`card_intermediateField_mixed`);
* record the resulting falsifiable contrast at class number `12`
  (`card_intermediateField_klein_times_three` : `10` intermediate fields for
  `Cl ≃ (ℤ/2)² × ℤ/3`, versus `6` for the cyclic group `ℤ/12`, proved in
  `card_subgroup_prod_four_three`), so that already at class number `12` the number of
  intermediate fields separates the two abelian types.
-/

import Mathlib
import Algebra.GaussianBinomialPascal
import Algebra.SubgroupCountFiniteAbelian
import NumberTheory.ElementaryAbelianClassField

open NumberField Module

namespace MixedClassGroup

/-! ## Multiplicativity of the subgroup count over a finite coprime family -/

section Pi

/-- A group with only one element has exactly one subgroup. -/
theorem card_subgroup_of_subsingleton (A : Type*) [Group A] [Subsingleton A] :
    Nat.card (Subgroup A) = 1 := by
  have hsub : Subsingleton (Subgroup A) :=
    ⟨fun S T => by
      ext x
      simp [Subsingleton.elim x (1 : A)]⟩
  exact Nat.card_eq_one_iff_unique.2 ⟨hsub, ⟨⊥⟩⟩

/-- Splitting off the first coordinate of a finite product of groups. -/
def piFinSuccMulEquiv {n : ℕ} (G : Fin (n + 1) → Type*) [∀ i, Group (G i)] :
    (∀ i, G i) ≃* G 0 × (∀ i : Fin n, G i.succ) where
  toFun f := (f 0, fun i => f i.succ)
  invFun g := Fin.cases g.1 g.2
  left_inv f := by
    funext i
    induction i using Fin.cases with
    | zero => simp
    | succ i => simp
  right_inv g := by
    refine Prod.ext ?_ ?_
    · simp
    · funext i; simp
  map_mul' _ _ := rfl

/-- **Multiplicativity of the subgroup count over a finite coprime family.**  If the orders of
the groups `G i` are pairwise coprime, the number of subgroups of `∏ i, G i` is the product of
the numbers of subgroups of the factors.  (No commutativity is assumed.) -/
theorem card_subgroup_pi_of_pairwise_coprime :
    ∀ {n : ℕ} (G : Fin n → Type u) [∀ i, Group (G i)] [∀ i, Finite (G i)],
      (Pairwise fun i j => (Nat.card (G i)).Coprime (Nat.card (G j))) →
      Nat.card (Subgroup (∀ i, G i)) = ∏ i, Nat.card (Subgroup (G i)) := by
  intro n
  induction n with
  | zero =>
    intro G _ _ _
    simp only [Finset.univ_eq_empty, Finset.prod_empty]
    exact card_subgroup_of_subsingleton (∀ i : Fin 0, G i)
  | succ n ih =>
    intro G _ _ hco
    have htail : (Nat.card (G 0)).Coprime (Nat.card (∀ i : Fin n, G i.succ)) := by
      rw [Nat.card_pi]
      exact Nat.Coprime.prod_right fun i _ => hco (Ne.symm (Fin.succ_ne_zero i))
    have hsplit : Nat.card (Subgroup (∀ i, G i))
        = Nat.card (Subgroup (G 0 × ∀ i : Fin n, G i.succ)) :=
      Nat.card_congr (MulEquiv.mapSubgroup (piFinSuccMulEquiv G)).toEquiv
    have hprod := SubgroupCount.card_subgroup_prod_of_coprime htail
    have hrec : Nat.card (Subgroup (∀ i : Fin n, G i.succ))
        = ∏ i : Fin n, Nat.card (Subgroup (G i.succ)) :=
      ih (fun i => G i.succ) fun i j hij => hco (fun h => hij (Fin.succ_injective n h))
    rw [hsplit, hprod, hrec, Fin.prod_univ_succ]

end Pi

/-! ## The subgroup count of an elementary abelian group is the Galois number -/

/-- The two Gaussian binomial coefficients of the catalog — the one of
`Catalog/NumberTheory/SubspaceCounting.lean` and the one of
`Catalog/Algebra/GaussianBinomialPascal.lean` — are the same function. -/
theorem gaussBinom_eq (q n k : ℕ) :
    SubspaceCounting.gaussBinom q n k = GaussPascal.gaussBinom q n k := rfl

/-- The number of subgroups of the elementary abelian group `(ℤ/p)^r` is the Galois number
`G_p(r) = ∑_{k ≤ r} binom(r,k)_p`. -/
theorem card_subgroup_elementaryAbelian (p r : ℕ) [Fact p.Prime] :
    Nat.card (Subgroup (Multiplicative (Fin r → ZMod p))) = GaussPascal.galoisNumber p r := by
  rw [Nat.card_congr (ElementaryAbelianClassField.subgroupSubmoduleOrderIso p r).toEquiv,
    SubspaceCounting.card_submodule_zmod]
  rfl

/-- The order of the elementary abelian group `(ℤ/p)^r`. -/
theorem card_elementaryAbelian (p r : ℕ) [Fact p.Prime] :
    Nat.card (Multiplicative (Fin r → ZMod p)) = p ^ r := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  simp [Nat.card_eq_fintype_card, ZMod.card]

/-- **The mixed count, group-theoretic form.**  For distinct primes `p ≠ q` the elementary
abelian group `(ℤ/p)^r × (ℤ/q)^s` has exactly `G_p(r) · G_q(s)` subgroups. -/
theorem card_subgroup_mixed {p q : ℕ} (r s : ℕ) [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    Nat.card (Subgroup (Multiplicative (Fin r → ZMod p) × Multiplicative (Fin s → ZMod q)))
      = GaussPascal.galoisNumber p r * GaussPascal.galoisNumber q s := by
  have hco : (Nat.card (Multiplicative (Fin r → ZMod p))).Coprime
      (Nat.card (Multiplicative (Fin s → ZMod q))) := by
    rw [card_elementaryAbelian, card_elementaryAbelian]
    exact Nat.Coprime.pow r s ((Nat.coprime_primes (Fact.out) (Fact.out)).2 hpq)
  rw [SubgroupCount.card_subgroup_prod_of_coprime hco, card_subgroup_elementaryAbelian,
    card_subgroup_elementaryAbelian]

/-! ## The class field consequence -/

section ClassField

variable (K : Type*) [Field K] [NumberField K]
  (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
  (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))

include e in
/-- **Mixed elementary abelian class group.**  If the ideal class group of `K` is isomorphic to
`(ℤ/p)^r × (ℤ/q)^s` for distinct primes `p ≠ q`, then a Hilbert class field datum for `K` has
exactly `G_p(r) · G_q(s)` intermediate fields, `G` the Galois number. -/
theorem card_intermediateField_mixed {p q : ℕ} (r s : ℕ) [Fact p.Prime] [Fact q.Prime]
    (hpq : p ≠ q)
    (E : ClassGroup (RingOfIntegers K)
      ≃* Multiplicative (Fin r → ZMod p) × Multiplicative (Fin s → ZMod q)) :
    Nat.card (IntermediateField K H) = GaussPascal.galoisNumber p r * GaussPascal.galoisNumber q s := by
  rw [HilbertClassFieldDescent.card_intermediateField_eq_card_subgroup K H e,
    Nat.card_congr (MulEquiv.mapSubgroup E).toEquiv, card_subgroup_mixed r s hpq]

include e in
/-- **Ten intermediate fields at class number twelve.**  If `Cl(𝒪_K) ≃ (ℤ/2)² × ℤ/3` — a group of
order `12` — then the datum has exactly `10` intermediate fields.  Contrast
`SubgroupCount.card_subgroup_prod_four_three`: a *cyclic* class group of order `12` gives only
`6`.  So the number of intermediate fields separates the two abelian types of order `12`. -/
theorem card_intermediateField_klein_times_three
    (E : ClassGroup (RingOfIntegers K)
      ≃* Multiplicative (Fin 2 → ZMod 2) × Multiplicative (Fin 1 → ZMod 3)) :
    Nat.card (IntermediateField K H) = 10 := by
  have h := card_intermediateField_mixed (K := K) (H := H) (e := e) (p := 2) (q := 3)
    (r := 2) (s := 1) (by norm_num) E
  have h2 : GaussPascal.galoisNumber 2 2 = 5 := by decide
  have h3 : GaussPascal.galoisNumber 3 1 = 2 := GaussPascal.galoisNumber_one (by norm_num)
  rw [h, h2, h3]

end ClassField

/-- The two counts at order `12` differ: `10` for `(ℤ/2)² × ℤ/3`, `6` for the cyclic group
`ℤ/12 ≃ ℤ/4 × ℤ/3`.  Hence the class number alone does not determine the number of intermediate
fields of the Hilbert class field, even for abelian class groups of squarefree-free order. -/
theorem card_subgroup_order_twelve_ne :
    Nat.card (Subgroup (Multiplicative (Fin 2 → ZMod 2) × Multiplicative (Fin 1 → ZMod 3)))
      ≠ Nat.card (Subgroup (Multiplicative (ZMod 4) × Multiplicative (ZMod 3))) := by
  have h1 : Nat.card (Subgroup (Multiplicative (Fin 2 → ZMod 2)
      × Multiplicative (Fin 1 → ZMod 3))) = 10 := by
    have h := card_subgroup_mixed (p := 2) (q := 3) 2 1 (by norm_num)
    have h2 : GaussPascal.galoisNumber 2 2 = 5 := by decide
    have h3 : GaussPascal.galoisNumber 3 1 = 2 := GaussPascal.galoisNumber_one (by norm_num)
    rw [h, h2, h3]
  rw [h1, SubgroupCount.card_subgroup_prod_four_three]
  omega

end MixedClassGroup