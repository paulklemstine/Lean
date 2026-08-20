/-
# Group algebras of abelian `p`-groups are local, and their free Solomon coefficients

The arithmetic applications of the paper concern orders such as `ℤ_p[ℤ/pℤ]`, whose reduction is
the group algebra `𝔽_p[ℤ/pℤ]`.  This file supplies the missing structural input for the local
counting machinery of `Shared.SolomonZeta.LocalOrder` in that setting:

* `SolomonZeta.isLocalRing_of_isMaximal_of_nil` — a commutative ring with a maximal ideal all of
  whose elements are nilpotent is local (no completeness or noetherianity is used);
* `SolomonZeta.pow_prime_pow_eq_augHom` — in `k[G]` with `k` of characteristic `p` and `G` a
  commutative group of exponent dividing `pᵉ`, one has `x^{pᵉ} = ε(x)^{pᵉ}·1`, where `ε` is the
  augmentation.  Hence the augmentation ideal is nil;
* `SolomonZeta.isLocalRing_monoidAlgebra` — consequently `k[G]` is local for `k` a field of
  characteristic `p` and `G` a commutative `p`-group, with maximal ideal the augmentation ideal
  (`SolomonZeta.maximalIdeal_monoidAlgebra`) and residue field `k`
  (`SolomonZeta.residueFieldMonoidAlgebraEquiv`).

Combining this with `SolomonZeta.autCard_mul_quotIsoCount_free_local` yields the Solomon
coefficient formula for free lattices over `𝔽_p[G]`
(`SolomonZeta.autCard_mul_quotIsoCount_groupAlgebra_free`): for every finite `𝔽_p[G]`-module `X`,

  `#Aut(X) · #{N ≤ 𝔽_p[G]ⁿ : 𝔽_p[G]ⁿ/N ≅ X} = (∏_{i<d}(pⁿ - p^i)) · #(𝔪X)ⁿ`,

with `d = dim_{𝔽_p} X/𝔪X` — the same shape as over the maximal order, although `𝔽_p[G]` is very
far from being maximal.
-/
import Catalog.Shared.SolomonZeta.LocalOrder

namespace SolomonZeta

open MonoidAlgebra IsLocalRing Module

/-! ### Locality from a nil maximal ideal -/

/-- If a commutative ring has a maximal ideal all of whose elements are nilpotent, then it is
local (and that ideal is the maximal ideal). -/
theorem isLocalRing_of_isMaximal_of_nil {A : Type*} [CommRing A] (J : Ideal A) (hJ : J.IsMaximal)
    (hnil : ∀ a ∈ J, IsNilpotent a) : IsLocalRing A := by
  haveI : Nontrivial A := by
    rcases subsingleton_or_nontrivial A with h | h
    · exact absurd ((Ideal.eq_top_iff_one J).2
        (by rw [Subsingleton.elim (1 : A) 0]; exact J.zero_mem)) hJ.ne_top
    · exact h
  refine IsLocalRing.of_isUnit_or_isUnit_one_sub_self fun a => ?_
  by_cases ha : a ∈ J
  · exact Or.inr ((hnil a ha).isUnit_one_sub)
  · obtain ⟨y, i, hi, hyi⟩ := hJ.exists_inv ha
    have h1 : y * a = 1 - i := by linear_combination hyi
    have hu : IsUnit (y * a) := by rw [h1]; exact (hnil i hi).isUnit_one_sub
    exact Or.inl (isUnit_of_mul_isUnit_right hu)

/-! ### The augmentation map -/

variable (k G : Type*) [CommRing k] [CommMonoid G]

/-- The augmentation `k[G] → k`, `Σ a_g g ↦ Σ a_g`. -/
noncomputable def augHom : MonoidAlgebra k G →ₐ[k] k := MonoidAlgebra.lift k k G 1

/-- The augmentation ideal of `k[G]`. -/
noncomputable def augIdeal : Ideal (MonoidAlgebra k G) := RingHom.ker (augHom k G).toRingHom

variable {k G}

theorem augHom_apply (x : MonoidAlgebra k G) : augHom k G x = ∑ g ∈ x.support, x g := by
  simp [augHom, MonoidAlgebra.lift_apply, Finsupp.sum]

theorem augHom_surjective : Function.Surjective (augHom k G) := fun c =>
  ⟨MonoidAlgebra.single 1 c, by simp [augHom]⟩

theorem mem_augIdeal_iff {x : MonoidAlgebra k G} : x ∈ augIdeal k G ↔ augHom k G x = 0 :=
  Iff.rfl

/-- **Freshman's dream in a group algebra.**  If `k` has characteristic `p` and every element of
the commutative group `G` satisfies `g^{pᵉ} = 1`, then `x^{pᵉ} = ε(x)^{pᵉ}·1` in `k[G]`. -/
theorem pow_prime_pow_eq_augHom {p : ℕ} [hp : Fact p.Prime] [CharP k p] {e : ℕ}
    (hG : ∀ g : G, g ^ p ^ e = 1) (x : MonoidAlgebra k G) :
    x ^ p ^ e = algebraMap k (MonoidAlgebra k G) (augHom k G x ^ p ^ e) := by
  haveI : CharP (MonoidAlgebra k G) p :=
    charP_of_injective_algebraMap (FaithfulSMul.algebraMap_injective k (MonoidAlgebra k G)) p
  haveI : ExpChar (MonoidAlgebra k G) p := ExpChar.prime hp.out
  haveI : ExpChar k p := ExpChar.prime hp.out
  conv_lhs => rw [← Finsupp.sum_single x]
  rw [Finsupp.sum, sum_pow_char_pow]
  have hterm : ∀ g ∈ x.support, (MonoidAlgebra.single g (x g) : MonoidAlgebra k G) ^ p ^ e
      = MonoidAlgebra.single (1 : G) ((x g) ^ p ^ e) := by
    intro g _
    rw [MonoidAlgebra.single_pow, hG g]
  rw [Finset.sum_congr rfl hterm, ← Finsupp.single_finset_sum, augHom_apply, sum_pow_char_pow]
  simp only [Algebra.algebraMap_eq_smul_one, MonoidAlgebra.one_def, MonoidAlgebra.smul_single,
    smul_eq_mul, mul_one]

/-- The augmentation ideal of `k[G]` is nil when `k` has characteristic `p` and `G` is a
commutative group of exponent dividing `pᵉ`. -/
theorem isNilpotent_of_mem_augIdeal {p : ℕ} [hp : Fact p.Prime] [CharP k p] {e : ℕ}
    (hG : ∀ g : G, g ^ p ^ e = 1) (x : MonoidAlgebra k G) (hx : x ∈ augIdeal k G) :
    IsNilpotent x := by
  refine ⟨p ^ e, ?_⟩
  have h0 : augHom k G x = 0 := mem_augIdeal_iff.1 hx
  rw [pow_prime_pow_eq_augHom hG x, h0, zero_pow (pow_ne_zero e hp.out.pos.ne'), map_zero]

/-! ### `k[G]` is local -/

section Field

variable (k G : Type*) [Field k] [CommMonoid G]

/-- The augmentation ideal of `k[G]` over a field `k` is maximal. -/
theorem isMaximal_augIdeal : (augIdeal k G).IsMaximal :=
  RingHom.ker_isMaximal_of_surjective _ augHom_surjective

variable {k G}

/-- **The group algebra of a commutative `p`-group over a field of characteristic `p` is
local.** -/
theorem isLocalRing_monoidAlgebra {p : ℕ} [Fact p.Prime] [CharP k p] {e : ℕ}
    (hG : ∀ g : G, g ^ p ^ e = 1) : IsLocalRing (MonoidAlgebra k G) :=
  isLocalRing_of_isMaximal_of_nil _ (isMaximal_augIdeal k G) (isNilpotent_of_mem_augIdeal hG)

/-- Its maximal ideal is the augmentation ideal. -/
theorem maximalIdeal_monoidAlgebra {p : ℕ} [Fact p.Prime] [CharP k p] {e : ℕ}
    (hG : ∀ g : G, g ^ p ^ e = 1) :
    letI := isLocalRing_monoidAlgebra (k := k) (G := G) hG
    maximalIdeal (MonoidAlgebra k G) = augIdeal k G := by
  letI := isLocalRing_monoidAlgebra (k := k) (G := G) hG
  exact (IsLocalRing.eq_maximalIdeal (isMaximal_augIdeal k G)).symm

/-- Its residue field is `k`. -/
noncomputable def residueFieldMonoidAlgebraEquiv {p : ℕ} [Fact p.Prime] [CharP k p]
    {e : ℕ} (hG : ∀ g : G, g ^ p ^ e = 1) :
    letI := isLocalRing_monoidAlgebra (k := k) (G := G) hG
    ResidueField (MonoidAlgebra k G) ≃+* k := by
  letI := isLocalRing_monoidAlgebra (k := k) (G := G) hG
  exact (Ideal.quotEquivOfEq (maximalIdeal_monoidAlgebra hG)).trans
    (RingHom.quotientKerEquivOfSurjective
      (f := (augHom k G).toRingHom) augHom_surjective)

end Field

/-! ### Solomon coefficients of free lattices over `𝔽_p[G]` -/

/-- **The Solomon coefficients of a free lattice over the group algebra of a commutative
`p`-group.**  Let `p` be a prime, `G` a commutative group of exponent dividing `pᵉ`, and
`Λ = 𝔽_p[G]`.  For every finite `Λ`-module `X`,

  `#Aut(X) · #{N ≤ Λⁿ : Λⁿ/N ≅ X} = (∏_{i<d}(pⁿ - p^i)) · #(𝔪X)ⁿ`,   `d = dim_{𝔽_p} X/𝔪X`,

where `𝔪` is the augmentation ideal.  The right-hand side has exactly the shape of the formula
over the maximal order, with the residue field cardinality `p`. -/
theorem autCard_mul_quotIsoCount_groupAlgebra_free {p : ℕ} [Fact p.Prime] {e : ℕ}
    (hG : ∀ g : G, g ^ p ^ e = 1)
    (X : Type*) [AddCommGroup X] [Module (MonoidAlgebra (ZMod p) G) X] [Finite X]
    [Module.Finite (MonoidAlgebra (ZMod p) G) X] (n : ℕ) :
    letI := isLocalRing_monoidAlgebra (k := ZMod p) (G := G) hG
    autCard (MonoidAlgebra (ZMod p) G) X
        * quotIsoCount (MonoidAlgebra (ZMod p) G) (Fin n → MonoidAlgebra (ZMod p) G) X
      = (∏ i : Fin (finrank (ResidueField (MonoidAlgebra (ZMod p) G))
            (ResQuot (MonoidAlgebra (ZMod p) G) X)), (p ^ n - p ^ (i : ℕ)))
        * Nat.card ↥((maximalIdeal (MonoidAlgebra (ZMod p) G))
            • (⊤ : Submodule (MonoidAlgebra (ZMod p) G) X)) ^ n := by
  letI := isLocalRing_monoidAlgebra (k := ZMod p) (G := G) hG
  letI eq := residueFieldMonoidAlgebraEquiv (k := ZMod p) (G := G) hG
  letI : Fintype (ResidueField (MonoidAlgebra (ZMod p) G)) :=
    Fintype.ofEquiv (ZMod p) eq.toEquiv.symm
  have hcard : Fintype.card (ResidueField (MonoidAlgebra (ZMod p) G)) = p := by
    rw [Fintype.card_congr eq.toEquiv, ZMod.card]
  rw [autCard_mul_quotIsoCount_free_local (R := MonoidAlgebra (ZMod p) G) (X := X) n, hcard]

end SolomonZeta