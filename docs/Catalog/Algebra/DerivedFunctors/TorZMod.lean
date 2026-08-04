import Algebra.DerivedFunctors.UCTTwoTerm

/-!
# `Tor₁(G, ℤ/k)` is the `k`-torsion of `G`

Using the explicit projective resolution `resComplex k` of `ZMod k`
(see `Algebra.DerivedFunctors.ZModResolution`) we compute the first `Tor`-group of an arbitrary
`ℤ`-module `G` against a cyclic group:

`Tor₁(G, ℤ/k) ≅ ker(k · : G → G) = G[k]`.

The computation goes through the complex `G ⊗ C` (`tensorResComplex`): its differential in
degree `2` vanishes, so `H₁(G ⊗ C)` is the kernel of `1_G ⊗ (·k)`, and the unitor
`G ⊗ ℤ ≅ G` identifies this kernel with the `k`-torsion of `G`.

The main results are:

* `Catalog.DerivedFunctors.torOneZModIso`: the isomorphism `Tor₁(G, ℤ/k) ≅ G[k]`;
* `Catalog.DerivedFunctors.tensorZModIso`: the degree-zero counterpart
  `Tor₀(G, ℤ/k) = G ⊗ ℤ/k ≅ G/kG`;
* `Catalog.DerivedFunctors.torOneZMod_self_ne_zero`: consequently `Tor₁(ℤ/k, ℤ/k) ≠ 0`
  for `k ≥ 2`, i.e. the correction term of the universal coefficient theorem is really there.
-/

open CategoryTheory Limits MonoidalCategory HomologicalComplex
open scoped TensorProduct

set_option synthInstance.maxHeartbeats 400000
set_option maxHeartbeats 1000000

namespace Catalog.DerivedFunctors

variable (k : ℕ) (G : ModuleCat.{0} ℤ)

/-- Multiplication by `k` on a `ℤ`-module `G`, as a morphism of `ℤ`-modules.  Its kernel is the
`k`-torsion `G[k]`. -/
noncomputable def mulBy : G ⟶ G :=
  ModuleCat.ofHom ((k : ℤ) • (LinearMap.id : G →ₗ[ℤ] G))

@[simp] lemma mulBy_apply (g : G) : (ModuleCat.Hom.hom (mulBy k G)) g = (k : ℤ) • g := rfl

/-- The two-term free complex `⋯ → 0 → ℤ --(·k)--> ℤ` tensored with `G`. -/
noncomputable abbrev tensorResComplex : ChainComplex (ModuleCat.{0} ℤ) ℕ :=
  ((tensorLeft G).mapHomologicalComplex (ComplexShape.down ℕ)).obj (resComplex k)

lemma tensorResComplex_sc'_f : ((tensorResComplex k G).sc' 2 1 0).f = 0 := by
  show (tensorLeft G).map ((resComplex k).d 2 1) = 0
  have h : (resComplex k).d 2 1 = 0 := by
    have := ChainComplex.of_d resX (resd k)
      (by intro n; cases n with | zero => simp [resd] | succ m => simp [resd]) 1
    simpa [resComplex, resd] using this
  rw [h, Functor.map_zero]

lemma tensorResComplex_sc'_g :
    ((tensorResComplex k G).sc' 2 1 0).g = (tensorLeft G).map (mulZ k) := by
  show (tensorLeft G).map ((resComplex k).d 1 0) = _
  rw [resComplex_d_one_zero]

/-- Under the right unitor `G ⊗ ℤ ≅ G` the map `1_G ⊗ (·k)` becomes multiplication by `k`. -/
lemma tensorLeft_mulZ_comp_rightUnitor :
    (tensorLeft G).map (mulZ k) ≫ (ρ_ G).hom = (ρ_ G).hom ≫ mulBy k G := by
  have h1 : mulZ k = (k : ℤ) • 𝟙 (ModuleCat.of ℤ ℤ) := by ext; simp [mulZ]
  have h2 : mulBy k G = (k : ℤ) • 𝟙 G := by ext; simp [mulBy]
  have h3 : (tensorLeft G).map (mulZ k)
      = (k : ℤ) • 𝟙 ((tensorLeft G).obj (ModuleCat.of ℤ ℤ)) := by
    rw [h1, Functor.map_zsmul, CategoryTheory.Functor.map_id]
  rw [h2, h3]
  simp

instance hasKernel_tensorLeft_mulZ : HasKernel ((tensorLeft G).map (mulZ k)) :=
  HasKernels.has_limit _

/-- The kernel of `1_G ⊗ (·k)` on `G ⊗ ℤ` is the `k`-torsion of `G`. -/
noncomputable def kernelTensorLeftMulZIso :
    kernel ((tensorLeft G).map (mulZ k)) ≅ kernel (mulBy k G) :=
  kernel.mapIso _ (mulBy k G) (ρ_ G) (ρ_ G) (tensorLeft_mulZ_comp_rightUnitor k G)

/-- `H₁(G ⊗ C)`, the degree-one homology of the tensored two-term complex, is the `k`-torsion
of `G`. -/
noncomputable def tensorResComplexHomologyOneIso :
    (tensorResComplex k G).homology 1 ≅ kernel (mulBy k G) :=
  (tensorResComplex k G).homologyIsoSc' 2 1 0 (by simp) (by simp) ≪≫
    (((tensorResComplex k G).sc' 2 1 0).asIsoHomologyπ (tensorResComplex_sc'_f k G)).symm ≪≫
      ((tensorResComplex k G).sc' 2 1 0).cyclesIsoKernel ≪≫
        eqToIso (by rw [tensorResComplex_sc'_g]) ≪≫ kernelTensorLeftMulZIso k G

/-- **`Tor₁(G, ℤ/k)` is the `k`-torsion of `G`.** -/
noncomputable def torOneZModIso (hk : k ≠ 0) :
    ((Tor (ModuleCat.{0} ℤ) 1).obj G).obj (ModuleCat.of ℤ (ZMod k)) ≅ kernel (mulBy k G) :=
  (zmodProjectiveResolution k hk).isoLeftDerivedObj
      ((tensoringLeft (ModuleCat.{0} ℤ)).obj G) 1 ≪≫
    tensorResComplexHomologyOneIso k G

/-- Multiplication by `k` is the zero map on `ℤ/k`. -/
lemma mulBy_zmod_eq_zero : mulBy k (ModuleCat.of ℤ (ZMod k)) = 0 := by
  ext x
  show (k : ℤ) • x = 0
  simp [zsmul_eq_mul]

/-- `Tor₁(ℤ/k, ℤ/k) ≅ ℤ/k`. -/
noncomputable def torOneZModSelfIso (hk : k ≠ 0) :
    ((Tor (ModuleCat.{0} ℤ) 1).obj (ModuleCat.of ℤ (ZMod k))).obj (ModuleCat.of ℤ (ZMod k)) ≅
      ModuleCat.of ℤ (ZMod k) :=
  torOneZModIso k (ModuleCat.of ℤ (ZMod k)) hk ≪≫
    eqToIso (by rw [mulBy_zmod_eq_zero]) ≪≫ kernelZeroIsoSource

/-- **The `Tor`-correction term of the universal coefficient theorem is genuinely nonzero**:
`Tor₁(ℤ/k, ℤ/k) ≅ ℤ/k ≠ 0` for `k ≥ 2`. -/
theorem torOneZMod_self_ne_zero (hk : 2 ≤ k) :
    ¬ IsZero (((Tor (ModuleCat.{0} ℤ) 1).obj (ModuleCat.of ℤ (ZMod k))).obj
      (ModuleCat.of ℤ (ZMod k))) := by
  intro h
  have h' : IsZero (ModuleCat.of ℤ (ZMod k)) :=
    IsZero.of_iso h (torOneZModSelfIso k (by omega)).symm
  haveI : Subsingleton (ZMod k) := ModuleCat.isZero_iff_subsingleton.1 h'
  haveI : Fact (1 < k) := ⟨by omega⟩
  exact one_ne_zero (Subsingleton.elim (1 : ZMod k) 0)

section TensorZero

/-- The degree-zero part of the tensored complex: `H₀(G ⊗ C)` is the cokernel of multiplication
by `k`, i.e. `G/kG`. -/
lemma tensorResComplex_sc'_zero_f :
    ((tensorResComplex k G).sc' 1 0 0).f = (tensorLeft G).map (mulZ k) := by
  show (tensorLeft G).map ((resComplex k).d 1 0) = _
  rw [resComplex_d_one_zero]

lemma tensorResComplex_sc'_zero_g : ((tensorResComplex k G).sc' 1 0 0).g = 0 := by
  show (tensorLeft G).map ((resComplex k).d 0 0) = 0
  rw [(resComplex k).shape 0 0 (by simp), Functor.map_zero]

instance hasCokernel_tensorLeft_mulZ : HasCokernel ((tensorLeft G).map (mulZ k)) :=
  HasCokernels.has_colimit _

/-- The cokernel of `1_G ⊗ (·k)` on `G ⊗ ℤ` is `G/kG`. -/
noncomputable def cokernelTensorLeftMulZIso :
    cokernel ((tensorLeft G).map (mulZ k)) ≅ cokernel (mulBy k G) :=
  cokernel.mapIso _ (mulBy k G) (ρ_ G) (ρ_ G) (tensorLeft_mulZ_comp_rightUnitor k G)

/-- `H₀(G ⊗ C) ≅ G/kG`. -/
noncomputable def tensorResComplexHomologyZeroIso :
    (tensorResComplex k G).homology 0 ≅ cokernel (mulBy k G) :=
  (tensorResComplex k G).homologyIsoSc' 1 0 0 (by simp) (by simp) ≪≫
    ((tensorResComplex k G).sc' 1 0 0).asIsoHomologyι (tensorResComplex_sc'_zero_g k G) ≪≫
      ((tensorResComplex k G).sc' 1 0 0).opcyclesIsoCokernel ≪≫
        eqToIso (by rw [tensorResComplex_sc'_zero_f]) ≪≫ cokernelTensorLeftMulZIso k G

/-- **`Tor₀(G, ℤ/k) = G ⊗ ℤ/k` is `G/kG`.**  This is the degree-zero counterpart of
`torOneZModIso`, obtained from the same projective resolution. -/
noncomputable def tensorZModIso (hk : k ≠ 0) :
    (tensorLeft G).obj (ModuleCat.of ℤ (ZMod k)) ≅ cokernel (mulBy k G) :=
  (tensorLeft G).mapIso (resComplexHomologyZeroIso k hk).symm ≪≫
    (uctHomologyZeroIso k G hk).symm ≪≫ tensorResComplexHomologyZeroIso k G

end TensorZero

/-- **The correction term of the universal coefficient sequence is nonzero.**  For the two-term
free complex `C` and coefficients `G = ℤ/k` with `k ≥ 2` the group `Tor₁(G, H₀(C))` does not
vanish. -/
theorem not_isZero_uct_tor_term (hk : 2 ≤ k) :
    ¬ IsZero (((Tor (ModuleCat.{0} ℤ) 1).obj (ModuleCat.of ℤ (ZMod k))).obj
      ((resComplex k).homology 0)) := by
  intro h
  refine torOneZMod_self_ne_zero k hk (IsZero.of_iso h ?_)
  exact ((Tor (ModuleCat.{0} ℤ) 1).obj (ModuleCat.of ℤ (ZMod k))).mapIso
    (resComplexHomologyZeroIso k (by omega)).symm

/-- After tensoring the two-term free complex with the non-flat module `ℤ/k` (`k ≥ 2`) the
resulting complex is no longer exact in degree one: the surviving homology is exactly the
`Tor`-term. -/
theorem not_exactAt_tensor_resComplex (hk : 2 ≤ k) :
    ¬ (tensorResComplex k (ModuleCat.of ℤ (ZMod k))).ExactAt 1 := by
  intro hex
  refine not_isZero_uct_tor_term k hk (IsZero.of_iso ?_
    (uctHomologyOneIso k (ModuleCat.of ℤ (ZMod k)) (by omega)).symm)
  exact (HomologicalComplex.exactAt_iff_isZero_homology _ _).1 hex

end Catalog.DerivedFunctors