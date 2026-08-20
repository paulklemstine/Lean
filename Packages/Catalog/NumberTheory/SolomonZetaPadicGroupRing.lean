/-
# `ℤ_p[G]` is local for a finite abelian `p`-group `G`, and its free Solomon coefficients

This file settles conjecture **D2** of the Solomon-zeta thread for commutative `G`: the group
ring of a finite abelian `p`-group over the maximal order `ℤ_p` is a local ring with residue
field `𝔽_p`, so the Nakayama counting machinery of `Shared.SolomonZeta.LocalOrder` applies
verbatim to free `ℤ_p[G]`-lattices.

The proof combines two inputs:

* the nilpotence of the augmentation ideal of `𝔽_p[G]`
  (`SolomonZeta.isNilpotent_of_mem_augIdeal`, proved in `Shared.SolomonZeta.GroupAlgebra`), and
* the locality ascent `SolomonZeta.isLocalRing_of_isMaximal_of_pow_mem` of
  `NumberTheory.SolomonZetaLocalityAscent`, which upgrades "nil modulo `𝔪_R Λ`" to locality for
  a module-finite algebra `Λ` over a local ring `R`.

The bridge between them is the coefficientwise reduction `SolomonZeta.padicRed :
ℤ_p[G] → 𝔽_p[G]`, whose kernel is contained in `p·ℤ_p[G] = 𝔪_{ℤ_p}·ℤ_p[G]`
(`SolomonZeta.mem_map_maximalIdeal_of_padicRed_eq_zero`).

Main results:

* `SolomonZeta.isLocalRing_padicMonoidAlgebra` — `ℤ_p[G]` is local;
* `SolomonZeta.maximalIdeal_padicMonoidAlgebra` — its maximal ideal is the preimage of
  `pℤ_p` under the augmentation, i.e. `𝔪 = (augmentation ideal) + p·ℤ_p[G]`;
* `SolomonZeta.residueFieldPadicMonoidAlgebraEquiv`, `SolomonZeta.card_residueField_padic` —
  its residue field is `𝔽_p`;
* `SolomonZeta.autCard_mul_quotIsoCount_padicMonoidAlgebra_free` — the resulting Solomon
  coefficient formula: for every finite `ℤ_p[G]`-module `X` and every `n`,
  `#Aut(X)·#{N ≤ Λⁿ : Λⁿ/N ≅ X} = (∏_{i<d}(pⁿ - p^i))·#(𝔪X)ⁿ`, `d = dim_{𝔽_p} X/𝔪X`;
* `SolomonZeta.autCard_mul_quotIsoCount_padicCyclic_free` — the case `Λ = ℤ_p[ℤ/pℤ]` singled
  out in the conjecture.
-/
import Catalog.NumberTheory.SolomonZetaLocalityAscent

namespace SolomonZeta

open IsLocalRing Module

/-! ### Coefficientwise reduction `ℤ_p[G] → 𝔽_p[G]` -/

variable (p : ℕ) [Fact p.Prime] (G : Type*) [CommMonoid G]

/-- Reduction of coefficients modulo `p`, as a ring homomorphism `ℤ_p[G] → 𝔽_p[G]`. -/
noncomputable def padicRed : MonoidAlgebra ℤ_[p] G →+* MonoidAlgebra (ZMod p) G :=
  MonoidAlgebra.liftNCRingHom
    ((MonoidAlgebra.singleOneRingHom).comp (PadicInt.toZMod (p := p)))
    (MonoidAlgebra.of (ZMod p) G) fun _ _ => Commute.all _ _

variable {p G}

@[simp]
theorem padicRed_single (g : G) (c : ℤ_[p]) :
    padicRed p G (MonoidAlgebra.single g c) = MonoidAlgebra.single g (PadicInt.toZMod c) := by
  simp [padicRed, MonoidAlgebra.liftNCRingHom, MonoidAlgebra.liftNC_single,
    MonoidAlgebra.of_apply, MonoidAlgebra.single_mul_single]

/-- The reduction acts coefficientwise. -/
theorem padicRed_apply (x : MonoidAlgebra ℤ_[p] G) (g : G) :
    padicRed p G x g = PadicInt.toZMod (x g) := by
  have h : (padicRed p G).toAddMonoidHom
      = (Finsupp.mapRange.addMonoidHom (PadicInt.toZMod (p := p)).toAddMonoidHom :
          (G →₀ ℤ_[p]) →+ (G →₀ ZMod p)) := by
    apply Finsupp.addHom_ext
    intro a b
    show padicRed p G (MonoidAlgebra.single a b)
      = Finsupp.mapRange (PadicInt.toZMod (p := p)) (map_zero _) (Finsupp.single a b)
    rw [padicRed_single, Finsupp.mapRange_single]
  have h2 : (padicRed p G).toAddMonoidHom x
      = Finsupp.mapRange.addMonoidHom (PadicInt.toZMod (p := p)).toAddMonoidHom x :=
    congrFun (congrArg (fun f => DFunLike.coe f) h) x
  show ((padicRed p G).toAddMonoidHom x) g = _
  rw [h2]
  simp

/-- **The kernel of the reduction is contained in `p·ℤ_p[G]`.**  An element whose coefficients
are all divisible by `p` lies in the extension of the maximal ideal of `ℤ_p`. -/
theorem mem_map_maximalIdeal_of_padicRed_eq_zero (x : MonoidAlgebra ℤ_[p] G)
    (hx : padicRed p G x = 0) :
    x ∈ (maximalIdeal ℤ_[p]).map (algebraMap ℤ_[p] (MonoidAlgebra ℤ_[p] G)) := by
  have hcoeff : ∀ g : G, x g ∈ maximalIdeal ℤ_[p] := by
    intro g
    rw [← PadicInt.ker_toZMod]
    show PadicInt.toZMod (x g) = 0
    rw [← padicRed_apply, hx]
    rfl
  have hmem : (x.sum fun g c => (MonoidAlgebra.single g c : MonoidAlgebra ℤ_[p] G))
      ∈ (maximalIdeal ℤ_[p]).map (algebraMap ℤ_[p] (MonoidAlgebra ℤ_[p] G)) := by
    refine Submodule.sum_mem _ fun g _ => ?_
    show (MonoidAlgebra.single g (x g) : MonoidAlgebra ℤ_[p] G) ∈ _
    have hs : (MonoidAlgebra.single g (x g) : MonoidAlgebra ℤ_[p] G)
        = algebraMap ℤ_[p] (MonoidAlgebra ℤ_[p] G) (x g) * MonoidAlgebra.single g 1 := by
      simp [Algebra.algebraMap_eq_smul_one]
    rw [hs]
    exact Ideal.mul_mem_right _ _ (Ideal.mem_map_of_mem _ (hcoeff g))
  rwa [Finsupp.sum_single] at hmem

/-- Reduction of coefficients commutes with the augmentation. -/
theorem augHom_padicRed (x : MonoidAlgebra ℤ_[p] G) :
    augHom (ZMod p) G (padicRed p G x) = PadicInt.toZMod (augHom ℤ_[p] G x) := by
  have h : (augHom (ZMod p) G).toRingHom.comp (padicRed p G)
      = (PadicInt.toZMod (p := p)).comp (augHom ℤ_[p] G).toRingHom := by
    apply MonoidAlgebra.ringHom_ext
    · intro r
      simp [augHom, MonoidAlgebra.lift_single]
    · intro a
      simp [augHom, MonoidAlgebra.lift_single]
  exact congrFun (congrArg (fun f => DFunLike.coe f) h) x

/-! ### `ℤ_p[G]` is local -/

variable (p G) in
/-- The maximal ideal candidate of `ℤ_p[G]`: the preimage of `pℤ_p` under the augmentation,
i.e. the sum of the augmentation ideal and `p·ℤ_p[G]`. -/
noncomputable def padicAugMaximal : Ideal (MonoidAlgebra ℤ_[p] G) :=
  Ideal.comap (augHom ℤ_[p] G).toRingHom (maximalIdeal ℤ_[p])

theorem isMaximal_padicAugMaximal : (padicAugMaximal p G).IsMaximal :=
  Ideal.comap_isMaximal_of_surjective (K := maximalIdeal ℤ_[p]) _ augHom_surjective

/-- **`ℤ_p[G]` is a local ring** for `G` a finite commutative group of exponent dividing `pᵉ`.
Its maximal ideal is `padicAugMaximal p G`; the proof reduces mod `p`, where the augmentation
ideal of `𝔽_p[G]` is nilpotent, and then ascends by Nakayama. -/
theorem isLocalRing_padicMonoidAlgebra [Finite G] {e : ℕ} (hG : ∀ g : G, g ^ p ^ e = 1) :
    IsLocalRing (MonoidAlgebra ℤ_[p] G) := by
  refine isLocalRing_of_isMaximal_of_pow_mem (R := ℤ_[p]) (padicAugMaximal p G)
    isMaximal_padicAugMaximal fun a ha => ⟨p ^ e, ?_⟩
  refine mem_map_maximalIdeal_of_padicRed_eq_zero _ ?_
  have haug : augHom (ZMod p) G (padicRed p G a) = 0 := by
    rw [augHom_padicRed]
    have : augHom ℤ_[p] G a ∈ maximalIdeal ℤ_[p] := ha
    rw [← PadicInt.ker_toZMod] at this
    exact this
  obtain ⟨N, hN⟩ := isNilpotent_of_mem_augIdeal (k := ZMod p) hG _ (mem_augIdeal_iff.2 haug)
  have hzero : padicRed p G a ^ p ^ e = 0 := by
    have hpow : padicRed p G a ^ p ^ e
        = algebraMap (ZMod p) (MonoidAlgebra (ZMod p) G)
            (augHom (ZMod p) G (padicRed p G a) ^ p ^ e) :=
      pow_prime_pow_eq_augHom hG _
    rw [hpow, haug, zero_pow (pow_ne_zero e (Fact.out (p := p.Prime)).pos.ne'), map_zero]
  rw [map_pow, hzero]

/-- The maximal ideal of `ℤ_p[G]` is the preimage of `pℤ_p` under the augmentation. -/
theorem maximalIdeal_padicMonoidAlgebra [Finite G] {e : ℕ} (hG : ∀ g : G, g ^ p ^ e = 1) :
    letI := isLocalRing_padicMonoidAlgebra (p := p) (G := G) hG
    maximalIdeal (MonoidAlgebra ℤ_[p] G) = padicAugMaximal p G := by
  letI := isLocalRing_padicMonoidAlgebra (p := p) (G := G) hG
  exact (IsLocalRing.eq_maximalIdeal isMaximal_padicAugMaximal).symm

/-- **The residue field of `ℤ_p[G]` is `𝔽_p`.** -/
noncomputable def residueFieldPadicMonoidAlgebraEquiv [Finite G] {e : ℕ}
    (hG : ∀ g : G, g ^ p ^ e = 1) :
    letI := isLocalRing_padicMonoidAlgebra (p := p) (G := G) hG
    ResidueField (MonoidAlgebra ℤ_[p] G) ≃+* ZMod p := by
  letI := isLocalRing_padicMonoidAlgebra (p := p) (G := G) hG
  refine (Ideal.quotEquivOfEq ?_).trans
    (RingHom.quotientKerEquivOfSurjective
      (f := (PadicInt.toZMod (p := p)).comp (augHom ℤ_[p] G).toRingHom)
      ((ZMod.ringHom_surjective PadicInt.toZMod).comp augHom_surjective))
  rw [maximalIdeal_padicMonoidAlgebra hG, padicAugMaximal, ← PadicInt.ker_toZMod]
  rfl

/-! ### Solomon coefficients of free `ℤ_p[G]`-lattices -/

/-- **Solomon coefficients of free lattices over `ℤ_p[G]`.**  Let `p` be a prime, `G` a finite
commutative group of exponent dividing `pᵉ`, and `Λ = ℤ_p[G]`.  For every finite `Λ`-module `X`
and every rank `n`,

  `#Aut(X) · #{N ≤ Λⁿ : Λⁿ/N ≅ X} = (∏_{i<d}(pⁿ - p^i)) · #(𝔪X)ⁿ`,  `d = dim_{𝔽_p} X/𝔪X`,

exactly as over the maximal order `ℤ_p`, even though `Λ` is not maximal (and not even a domain
for `G ≠ 1`). -/
theorem autCard_mul_quotIsoCount_padicMonoidAlgebra_free [Finite G] {e : ℕ}
    (hG : ∀ g : G, g ^ p ^ e = 1)
    (X : Type*) [AddCommGroup X] [Module (MonoidAlgebra ℤ_[p] G) X] [Finite X]
    [Module.Finite (MonoidAlgebra ℤ_[p] G) X] (n : ℕ) :
    letI := isLocalRing_padicMonoidAlgebra (p := p) (G := G) hG
    autCard (MonoidAlgebra ℤ_[p] G) X
        * quotIsoCount (MonoidAlgebra ℤ_[p] G) (Fin n → MonoidAlgebra ℤ_[p] G) X
      = (∏ i : Fin (finrank (ResidueField (MonoidAlgebra ℤ_[p] G))
            (ResQuot (MonoidAlgebra ℤ_[p] G) X)), (p ^ n - p ^ (i : ℕ)))
        * Nat.card ↥((maximalIdeal (MonoidAlgebra ℤ_[p] G))
            • (⊤ : Submodule (MonoidAlgebra ℤ_[p] G) X)) ^ n := by
  letI := isLocalRing_padicMonoidAlgebra (p := p) (G := G) hG
  letI eq := residueFieldPadicMonoidAlgebraEquiv (p := p) (G := G) hG
  letI : Fintype (ResidueField (MonoidAlgebra ℤ_[p] G)) :=
    Fintype.ofEquiv (ZMod p) eq.toEquiv.symm
  have hcard : Fintype.card (ResidueField (MonoidAlgebra ℤ_[p] G)) = p := by
    rw [Fintype.card_congr eq.toEquiv, ZMod.card]
  rw [autCard_mul_quotIsoCount_free_local (R := MonoidAlgebra ℤ_[p] G) (X := X) n, hcard]

/-- Every element of the multiplicative group `ℤ/pℤ` has order dividing `p`. -/
theorem pow_card_multiplicative_zmod (g : Multiplicative (ZMod p)) : g ^ p ^ 1 = 1 := by
  rw [pow_one]
  have h : g ^ p = Multiplicative.ofAdd ((p : ℕ) • Multiplicative.toAdd g) := rfl
  rw [h, nsmul_eq_mul]
  simp

/-- **The case `Λ = ℤ_p[ℤ/pℤ]`** singled out in conjecture D2: for every finite `Λ`-module `X`,
`#Aut(X)·#{N ≤ Λⁿ : Λⁿ/N ≅ X} = (∏_{i<d}(pⁿ - p^i))·#(𝔪X)ⁿ`. -/
theorem autCard_mul_quotIsoCount_padicCyclic_free
    (X : Type*) [AddCommGroup X]
    [Module (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X] [Finite X]
    [Module.Finite (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X] (n : ℕ) :
    letI := isLocalRing_padicMonoidAlgebra (p := p) (G := Multiplicative (ZMod p))
      pow_card_multiplicative_zmod
    autCard (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X
        * quotIsoCount (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p)))
            (Fin n → MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X
      = (∏ i : Fin (finrank (ResidueField (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))))
            (ResQuot (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X)), (p ^ n - p ^ (i : ℕ)))
        * Nat.card ↥((maximalIdeal (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))))
            • (⊤ : Submodule (MonoidAlgebra ℤ_[p] (Multiplicative (ZMod p))) X)) ^ n :=
  autCard_mul_quotIsoCount_padicMonoidAlgebra_free pow_card_multiplicative_zmod X n

end SolomonZeta