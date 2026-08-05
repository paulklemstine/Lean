/-
# Counting the subspaces of a finite-dimensional vector space over a finite field

This file proves the classical Gaussian (`q`-binomial) count of subspaces of a finite vector
space, in the form needed for the elementary abelian case of the Hilbert class field descent
picture of `Catalog/NumberTheory/HilbertClassFieldDescent.lean`.

Let `K` be a finite field with `q` elements and `V` a finite `K`-vector space of dimension `n`.

* `gaussBinom q n k` : the Gaussian binomial coefficient
  `∏_{i<k}(q^n - q^i) / ∏_{i<k}(q^k - q^i)`;
* `card_linearIndependent_eq_mul` : linearly independent `k`-tuples of `V` are fibred over the
  `k`-dimensional subspaces, each fibre being the set of bases of that subspace;
* `card_submodule_finrank_mul` : `#{W : dim W = k} * ∏_{i<k}(q^k - q^i) = ∏_{i<k}(q^n - q^i)`;
* `card_submodule_finrank_eq_gaussBinom` : `#{W : dim W = k} = gaussBinom q n k`;
* `card_submodule_eq_sum_gaussBinom` : `#(subspaces of V) = ∑_{k≤n} gaussBinom q n k`;
* `gaussBinom_symm` : `gaussBinom q n k = gaussBinom q n (n - k)` for `k ≤ n`, proved through the
  duality bijection between `k`- and `(n-k)`-dimensional subspaces;
* the specialisations to `V = (ZMod p)^r` used by the class field application.
-/

import Mathlib

open Module Finset

namespace SubspaceCounting

/-- The Gaussian (`q`-)binomial coefficient `binom(n,k)_q`, defined as the exact quotient
`∏_{i<k}(q^n - q^i) / ∏_{i<k}(q^k - q^i)`. -/
def gaussBinom (q n k : ℕ) : ℕ :=
  (∏ i ∈ Finset.range k, (q ^ n - q ^ i)) / (∏ i ∈ Finset.range k, (q ^ k - q ^ i))

@[simp] theorem gaussBinom_zero (q n : ℕ) : gaussBinom q n 0 = 1 := by
  simp [gaussBinom]

theorem gaussBinom_one (q n : ℕ) : gaussBinom q n 1 = (q ^ n - 1) / (q - 1) := by
  simp [gaussBinom]

/-- The denominator in the Gaussian binomial coefficient is positive. -/
theorem prod_pos_of_one_lt {q k : ℕ} (hq : 1 < q) :
    0 < ∏ i ∈ Finset.range k, (q ^ k - q ^ i) := by
  refine Finset.prod_pos fun i hi => ?_
  have : q ^ i < q ^ k := Nat.pow_lt_pow_right hq (Finset.mem_range.mp hi)
  omega

section Field

variable (K V : Type*) [Field K] [Fintype K] [AddCommGroup V] [Module K V] [Finite V]

instance finite_submodule : Finite (Submodule K V) :=
  Finite.of_injective (fun W : Submodule K V => (W : Set V)) SetLike.coe_injective

/-- The bases of a `k`-dimensional subspace: the number of linearly independent `k`-tuples in a
subspace of dimension `k` is `∏_{i<k}(q^k - q^i)`. -/
theorem card_linearIndependent_of_finrank_eq {k : ℕ} (W : Submodule K V)
    (hW : finrank K W = k) :
    Nat.card {s : Fin k → W // LinearIndependent K s}
      = ∏ i : Fin k, (Fintype.card K ^ k - Fintype.card K ^ (i : ℕ)) := by
  have h := card_linearIndependent (K := K) (V := W) (k := k) (le_of_eq hW.symm)
  rwa [hW] at h

/-- The span of a linearly independent `k`-tuple, as a `k`-dimensional subspace. -/
def spanOfLinearIndependent (k : ℕ) (s : {s : Fin k → V // LinearIndependent K s}) :
    {W : Submodule K V // finrank K W = k} :=
  ⟨Submodule.span K (Set.range s.1), by rw [finrank_span_eq_card s.2, Fintype.card_fin]⟩

/-- The linearly independent `k`-tuples spanning a fixed `k`-dimensional subspace `W` are exactly
the bases of `W`. -/
def spanFiberEquiv {k : ℕ} (W : Submodule K V) (hW : finrank K W = k) :
    {s : Fin k → V // LinearIndependent K s ∧ Submodule.span K (Set.range s) = W} ≃
      {t : Fin k → W // LinearIndependent K t} where
  toFun s :=
    ⟨fun i => ⟨s.1 i, by
        have h := Submodule.subset_span (R := K) (s := Set.range s.1) ⟨i, rfl⟩
        rw [s.2.2] at h; exact h⟩,
      LinearIndependent.of_comp W.subtype (by simpa using s.2.1)⟩
  invFun t :=
    ⟨fun i => (t.1 i : V), t.2.map' W.subtype (Submodule.ker_subtype W), by
      have htop : Submodule.span K (Set.range t.1) = ⊤ :=
        Submodule.eq_top_of_finrank_eq (by rw [finrank_span_eq_card t.2, Fintype.card_fin, hW])
      have hcomp : (fun i => (t.1 i : V)) = W.subtype ∘ t.1 := rfl
      rw [hcomp, Set.range_comp, ← Submodule.map_span, htop, Submodule.map_top,
        Submodule.range_subtype]⟩
  left_inv s := by ext i; rfl
  right_inv t := by ext i; rfl

/-- The fibres of the span map are the sets of bases. -/
theorem card_span_fiber {k : ℕ} (W : {W : Submodule K V // finrank K W = k}) :
    Nat.card {s : {s : Fin k → V // LinearIndependent K s} //
        spanOfLinearIndependent K V k s = W}
      = ∏ i : Fin k, (Fintype.card K ^ k - Fintype.card K ^ (i : ℕ)) := by
  have e₁ : {s : {s : Fin k → V // LinearIndependent K s} //
        spanOfLinearIndependent K V k s = W} ≃
      {s : Fin k → V // LinearIndependent K s ∧ Submodule.span K (Set.range s) = W.1} :=
    (Equiv.subtypeEquivRight (p := fun s : {s : Fin k → V // LinearIndependent K s} =>
        spanOfLinearIndependent K V k s = W)
        (q := fun s => Submodule.span K (Set.range s.1) = W.1)
        (fun _ => Subtype.ext_iff)).trans
      (Equiv.subtypeSubtypeEquivSubtypeInter (fun s : Fin k → V => LinearIndependent K s)
        (fun s => Submodule.span K (Set.range s) = W.1))
  rw [Nat.card_congr (e₁.trans (spanFiberEquiv K V W.1 W.2)),
    card_linearIndependent_of_finrank_eq K V W.1 W.2]

/-- **Fibration count.**  The number of linearly independent `k`-tuples of `V` is the number of
`k`-dimensional subspaces times the number of bases of each. -/
theorem card_linearIndependent_eq_mul (k : ℕ) :
    Nat.card {s : Fin k → V // LinearIndependent K s}
      = Nat.card {W : Submodule K V // finrank K W = k}
        * ∏ i : Fin k, (Fintype.card K ^ k - Fintype.card K ^ (i : ℕ)) := by
  classical
  haveI : Fintype {W : Submodule K V // finrank K W = k} := Fintype.ofFinite _
  rw [← Nat.card_congr (Equiv.sigmaFiberEquiv (spanOfLinearIndependent K V k)), Nat.card_sigma]
  simp only [card_span_fiber K V]
  rw [Finset.sum_const, smul_eq_mul, ← Nat.card_eq_fintype_card]
  simp [Nat.card_eq_fintype_card]

/-- **The subspace count, in product form.** -/
theorem card_submodule_finrank_mul {k : ℕ} (hk : k ≤ finrank K V) :
    Nat.card {W : Submodule K V // finrank K W = k}
        * ∏ i : Fin k, (Fintype.card K ^ k - Fintype.card K ^ (i : ℕ))
      = ∏ i : Fin k, (Fintype.card K ^ finrank K V - Fintype.card K ^ (i : ℕ)) := by
  rw [← card_linearIndependent_eq_mul K V k, card_linearIndependent (K := K) (V := V) hk]

/-- **The subspace count.**  A finite `K`-vector space of dimension `n` has exactly
`gaussBinom q n k` subspaces of dimension `k`, for every `k ≤ n`. -/
theorem card_submodule_finrank_eq_gaussBinom {k : ℕ} (hk : k ≤ finrank K V) :
    Nat.card {W : Submodule K V // finrank K W = k}
      = gaussBinom (Fintype.card K) (finrank K V) k := by
  have h := card_submodule_finrank_mul K V hk
  have hD : 0 < ∏ i ∈ Finset.range k, (Fintype.card K ^ k - Fintype.card K ^ i) :=
    prod_pos_of_one_lt Fintype.one_lt_card
  rw [gaussBinom,
    ← Fin.prod_univ_eq_prod_range (fun i => Fintype.card K ^ finrank K V - Fintype.card K ^ i) k,
    ← Fin.prod_univ_eq_prod_range (fun i => Fintype.card K ^ k - Fintype.card K ^ i) k]
  rw [← Fin.prod_univ_eq_prod_range (fun i => Fintype.card K ^ k - Fintype.card K ^ i) k] at hD
  exact (Nat.div_eq_of_eq_mul_left hD h.symm).symm

/-- **Existence of subspaces of every admissible dimension.**  For `k ≤ n` the number of
`k`-dimensional subspaces is positive. -/
theorem card_submodule_finrank_pos {k : ℕ} (hk : k ≤ finrank K V) :
    0 < Nat.card {W : Submodule K V // finrank K W = k} := by
  have h := card_submodule_finrank_mul K V hk
  have hP : 0 < ∏ i : Fin k, (Fintype.card K ^ finrank K V - Fintype.card K ^ (i : ℕ)) := by
    refine Finset.prod_pos fun i _ => ?_
    have : Fintype.card K ^ (i : ℕ) < Fintype.card K ^ finrank K V :=
      Nat.pow_lt_pow_right Fintype.one_lt_card (lt_of_lt_of_le i.2 hk)
    omega
  by_contra hcon
  push_neg at hcon
  rw [Nat.le_zero.mp hcon, zero_mul] at h
  omega

omit [Fintype K] in
/-- There are no subspaces of dimension exceeding the dimension of the space. -/
theorem card_submodule_finrank_eq_zero {k : ℕ} (hk : finrank K V < k) :
    Nat.card {W : Submodule K V // finrank K W = k} = 0 := by
  haveI : IsEmpty {W : Submodule K V // finrank K W = k} :=
    ⟨fun W => by have := Submodule.finrank_le W.1; omega⟩
  simp

/-- **Total subspace count.**  The number of subspaces of a finite `K`-vector space of dimension
`n` is the Galois number `∑_{k ≤ n} gaussBinom q n k`. -/
theorem card_submodule_eq_sum_gaussBinom :
    Nat.card (Submodule K V)
      = ∑ k ∈ Finset.range (finrank K V + 1), gaussBinom (Fintype.card K) (finrank K V) k := by
  classical
  set n := finrank K V with hn
  let f : Submodule K V → Fin (n + 1) := fun W => ⟨finrank K W, by
    have := Submodule.finrank_le W; omega⟩
  rw [← Nat.card_congr (Equiv.sigmaFiberEquiv f), Nat.card_sigma]
  have hfib : ∀ j : Fin (n + 1),
      Nat.card {W : Submodule K V // f W = j} = gaussBinom (Fintype.card K) n (j : ℕ) := by
    intro j
    have e : {W : Submodule K V // f W = j} ≃ {W : Submodule K V // finrank K W = (j : ℕ)} :=
      Equiv.subtypeEquivRight fun W => by
        constructor
        · intro h; exact congrArg Fin.val h
        · intro h; exact Fin.ext h
    rw [Nat.card_congr e, card_submodule_finrank_eq_gaussBinom K V (by omega : (j : ℕ) ≤ n)]
  rw [Finset.sum_congr rfl fun j _ => hfib j]
  exact Fin.sum_univ_eq_sum_range (fun k => gaussBinom (Fintype.card K) n k) (n + 1)

omit [Fintype K] in
/-- **Duality, one inequality.**  Sending a subspace to (the image under a fixed isomorphism
`V* ≃ V` of) its dual annihilator is injective and lowers the dimension from `k` to `n - k`. -/
theorem card_submodule_finrank_le_sub (k : ℕ) :
    Nat.card {W : Submodule K V // finrank K W = k}
      ≤ Nat.card {W : Submodule K V // finrank K W = finrank K V - k} := by
  classical
  haveI : FiniteDimensional K V := Module.Finite.of_finite
  let b := Module.finBasis K V
  let E : Dual K V ≃ₗ[K] V := (b.toDualEquiv).symm
  have hinj : Function.Injective
      (fun W : {W : Submodule K V // finrank K W = k} =>
        (⟨Submodule.map (E : Dual K V →ₗ[K] V) W.1.dualAnnihilator, by
          rw [LinearEquiv.finrank_map_eq E W.1.dualAnnihilator]
          have h1 := Submodule.finrank_quotient_add_finrank W.1
          have h2 := (Subspace.quotEquivAnnihilator W.1).finrank_eq
          rw [W.2] at h1
          omega⟩ : {W : Submodule K V // finrank K W = finrank K V - k})) := by
    intro W1 W2 h
    simp only [Subtype.mk.injEq] at h
    have hE : Function.Injective (Submodule.map (E : Dual K V →ₗ[K] V)) :=
      Submodule.map_injective_of_injective E.injective
    exact Subtype.ext (Subspace.dualAnnihilator_inj.mp (hE h))
  exact Nat.card_le_card_of_injective _ hinj

omit [Fintype K] in
/-- **Duality.**  There are as many `k`-dimensional subspaces as `(n-k)`-dimensional ones. -/
theorem card_submodule_finrank_eq_card_submodule_finrank_sub {k : ℕ} (hk : k ≤ finrank K V) :
    Nat.card {W : Submodule K V // finrank K W = k}
      = Nat.card {W : Submodule K V // finrank K W = finrank K V - k} := by
  refine le_antisymm (card_submodule_finrank_le_sub K V k) ?_
  have h := card_submodule_finrank_le_sub K V (finrank K V - k)
  rwa [Nat.sub_sub_self hk] at h

end Field

section ZMod

variable (p r : ℕ) [Fact p.Prime]

theorem finrank_pi_zmod : finrank (ZMod p) (Fin r → ZMod p) = r := by
  simp

/-- The number of `k`-dimensional subspaces of `(ZMod p)^r`. -/
theorem card_submodule_finrank_zmod {k : ℕ} (hk : k ≤ r) :
    Nat.card {W : Submodule (ZMod p) (Fin r → ZMod p) // finrank (ZMod p) W = k}
      = gaussBinom p r k := by
  have h := card_submodule_finrank_eq_gaussBinom (ZMod p) (Fin r → ZMod p)
    (k := k) (by rw [finrank_pi_zmod]; exact hk)
  rwa [finrank_pi_zmod, ZMod.card] at h

/-- The number of subspaces of `(ZMod p)^r`. -/
theorem card_submodule_zmod :
    Nat.card (Submodule (ZMod p) (Fin r → ZMod p))
      = ∑ k ∈ Finset.range (r + 1), gaussBinom p r k := by
  have h := card_submodule_eq_sum_gaussBinom (ZMod p) (Fin r → ZMod p)
  rwa [finrank_pi_zmod, ZMod.card] at h

/-- **Symmetry of the Gaussian binomial coefficient**, obtained from the duality bijection. -/
theorem gaussBinom_symm {n k : ℕ} (p : ℕ) [Fact p.Prime] (hk : k ≤ n) :
    gaussBinom p n k = gaussBinom p n (n - k) := by
  have h := card_submodule_finrank_eq_card_submodule_finrank_sub (ZMod p) (Fin n → ZMod p)
    (k := k) (by rw [finrank_pi_zmod]; exact hk)
  rw [finrank_pi_zmod] at h
  rw [← card_submodule_finrank_zmod p n hk,
    ← card_submodule_finrank_zmod p n (Nat.sub_le n k), h]

/-- **Positivity of the Gaussian binomial coefficient at a prime.** -/
theorem gaussBinom_pos {n k : ℕ} (p : ℕ) [Fact p.Prime] (hk : k ≤ n) : 0 < gaussBinom p n k := by
  rw [← card_submodule_finrank_zmod p n hk]
  exact card_submodule_finrank_pos (ZMod p) (Fin n → ZMod p) (by rw [finrank_pi_zmod]; exact hk)

end ZMod

/-! ## Explicit small values -/

theorem gaussBinom_two_two : ∑ k ∈ Finset.range 3, gaussBinom 2 2 k = 5 := by
  decide

theorem gaussBinom_two_three : ∑ k ∈ Finset.range 4, gaussBinom 2 3 k = 16 := by
  decide

theorem gaussBinom_two_three_values :
    gaussBinom 2 3 0 = 1 ∧ gaussBinom 2 3 1 = 7 ∧ gaussBinom 2 3 2 = 7 ∧ gaussBinom 2 3 3 = 1 := by
  refine ⟨by decide, by decide, by decide, by decide⟩

end SubspaceCounting