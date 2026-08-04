import Algebra.DerivedFunctors.Resolutions

/-!
# An explicit projective resolution of `ZMod k`

We upgrade the short exact sequence `0 → ℤ --(·k)--> ℤ → ZMod k → 0` of
`Algebra.DerivedFunctors.Resolutions` to a bundled
`CategoryTheory.ProjectiveResolution (ModuleCat.of ℤ (ZMod k))`: the chain complex

`⋯ → 0 → 0 → ℤ --(·k)--> ℤ`

of free (hence projective) `ℤ`-modules, together with the quasi-isomorphism to `ZMod k`
concentrated in degree `0`.

The main results are:

* `Catalog.DerivedFunctors.zmodProjectiveResolution`: the bundled projective resolution
  (for `k ≠ 0`);
* `Catalog.DerivedFunctors.isZero_leftDerived_of_two_le`: consequently, for *every* additive
  functor `F` out of `ℤ`-modules, the left derived functors `Lₙ₊₂F` vanish on `ZMod k`; in
  particular `Torₙ₊₂(G, ZMod k) = 0` for every `ℤ`-module `G`
  (`Catalog.DerivedFunctors.isZero_Tor_two_le_zmod`).
-/

open CategoryTheory Limits ZeroObject HomologicalComplex

namespace Catalog.DerivedFunctors

/-- The underlying objects of the resolution: `ℤ` in degrees `0, 1` and `0` afterwards. -/
noncomputable def resX : ℕ → ModuleCat.{0} ℤ
  | 0 => ModuleCat.of ℤ ℤ
  | 1 => ModuleCat.of ℤ ℤ
  | (_ + 2) => 0

/-- The differentials of the resolution: multiplication by `k` in degree one, zero afterwards. -/
noncomputable def resd (k : ℕ) : ∀ n, resX (n + 1) ⟶ resX n
  | 0 => mulZ k
  | (_ + 1) => 0

/-- The two-term complex of free `ℤ`-modules `⋯ → 0 → ℤ --(·k)--> ℤ`. -/
noncomputable def resComplex (k : ℕ) : ChainComplex (ModuleCat.{0} ℤ) ℕ :=
  ChainComplex.of resX (resd k) (by
    intro n
    cases n with
    | zero => simp [resd]
    | succ m => simp [resd])

lemma resComplex_d_one_zero (k : ℕ) : (resComplex k).d 1 0 = mulZ k :=
  ChainComplex.of_d _ _ _ 0

lemma isZero_resComplex_X (k : ℕ) (n : ℕ) : IsZero ((resComplex k).X (n + 2)) :=
  isZero_zero _

lemma projective_resComplex_X (k : ℕ) (n : ℕ) : Projective ((resComplex k).X n) := by
  match n with
  | 0 => exact inferInstanceAs (Projective (ModuleCat.of ℤ ℤ))
  | 1 => exact inferInstanceAs (Projective (ModuleCat.of ℤ ℤ))
  | (_ + 2) => exact inferInstanceAs (Projective (0 : ModuleCat.{0} ℤ))

/-- The augmentation `⋯ → 0 → ℤ --(·k)--> ℤ` to `ZMod k` placed in degree `0`. -/
noncomputable def resPi (k : ℕ) :
    resComplex k ⟶ (ChainComplex.single₀ (ModuleCat.{0} ℤ)).obj (ModuleCat.of ℤ (ZMod k)) :=
  (ChainComplex.toSingle₀Equiv _ _).symm ⟨redZ k, by
    rw [resComplex_d_one_zero]; exact mulZ_comp_redZ k⟩

lemma resPi_f_zero (k : ℕ) : (resPi k).f 0 = redZ k := by
  simp [resPi]

/-- The augmentation is an isomorphism on opcycles in degree zero: both
`(resComplex k).opcycles 0` and `ZMod k` are cokernels of multiplication by `k`. -/
theorem isIso_opcyclesMap_resPi (k : ℕ) (hk : k ≠ 0) : IsIso (opcyclesMap (resPi k) 0) := by
  haveI : Epi (zmodShortComplex k).g := (zmodShortComplex_shortExact k hk).epi_g
  have hd : (resComplex k).d 1 0 = mulZ k := resComplex_d_one_zero k
  have hcoker := (resComplex k).opcyclesIsCokernel 1 0 (by simp)
  have hcoker2 := (zmodShortComplex_shortExact k hk).exact.gIsCokernel
  have hz : (resComplex k).d 1 0 ≫ redZ k = 0 := by
    rw [hd]; exact mulZ_comp_redZ k
  have hz2 : mulZ k ≫ (resComplex k).pOpcycles 0 = 0 := by
    rw [← hd]; simp
  set γ := hcoker.desc (CokernelCofork.ofπ (redZ k) hz) with hγ
  set δ := hcoker2.desc (CokernelCofork.ofπ ((resComplex k).pOpcycles 0) hz2) with hδ
  have h1 : (resComplex k).pOpcycles 0 ≫ γ = redZ k := Cofork.IsColimit.π_desc hcoker
  have h2 : redZ k ≫ δ = (resComplex k).pOpcycles 0 := Cofork.IsColimit.π_desc hcoker2
  have hγδ : γ ≫ δ = 𝟙 _ := by
    apply Cofork.IsColimit.hom_ext hcoker
    show (resComplex k).pOpcycles 0 ≫ γ ≫ δ = (resComplex k).pOpcycles 0 ≫ 𝟙 _
    rw [← Category.assoc, h1, h2, Category.comp_id]
  have hδγ : δ ≫ γ = 𝟙 _ := by
    apply Cofork.IsColimit.hom_ext hcoker2
    show redZ k ≫ δ ≫ γ = redZ k ≫ 𝟙 _
    rw [← Category.assoc, h2, h1, Category.comp_id]
  haveI : IsIso γ := ⟨δ, hγδ, hδγ⟩
  have hLd : ((ChainComplex.single₀ (ModuleCat.{0} ℤ)).obj (ModuleCat.of ℤ (ZMod k))).d 1 0 = 0 := by
    simp
  set eL := ((ChainComplex.single₀ (ModuleCat.{0} ℤ)).obj
    (ModuleCat.of ℤ (ZMod k))).pOpcyclesIso 1 0 (by simp) hLd with heL
  have key : opcyclesMap (resPi k) 0 = γ ≫ eL.hom := by
    apply Cofork.IsColimit.hom_ext hcoker
    show (resComplex k).pOpcycles 0 ≫ opcyclesMap (resPi k) 0 =
      (resComplex k).pOpcycles 0 ≫ γ ≫ eL.hom
    rw [p_opcyclesMap, resPi_f_zero, ← Category.assoc, h1]
    simp [heL]
  rw [key]
  infer_instance

theorem quasiIsoAt_resPi_zero (k : ℕ) (hk : k ≠ 0) : QuasiIsoAt (resPi k) 0 := by
  haveI := isIso_opcyclesMap_resPi k hk
  rw [quasiIsoAt_iff_isIso_homologyMap]
  have hnat := ChainComplex.isoHomologyι₀_inv_naturality (resPi k)
  have key : homologyMap (resPi k) 0 = (resComplex k).isoHomologyι₀.hom ≫
      opcyclesMap (resPi k) 0 ≫
      ((ChainComplex.single₀ (ModuleCat.{0} ℤ)).obj (ModuleCat.of ℤ (ZMod k))).isoHomologyι₀.inv := by
    rw [← hnat, ← Category.assoc, Iso.hom_inv_id, Category.id_comp]
  rw [key]
  infer_instance

theorem quasiIsoAt_resPi_succ (k : ℕ) (hk : k ≠ 0) (n : ℕ) : QuasiIsoAt (resPi k) (n + 1) := by
  rw [quasiIsoAt_iff_exactAt' (resPi k) (n + 1) (ChainComplex.exactAt_succ_single_obj _ n)]
  match n with
  | 0 =>
    rw [HomologicalComplex.exactAt_iff' _ 2 1 0 (by simp) (by simp)]
    rw [ShortComplex.moduleCat_exact_iff]
    intro x hx
    refine ⟨0, ?_⟩
    have hx' : (ModuleCat.Hom.hom (mulZ k)) (show ℤ from x) = 0 := by
      simpa [resComplex_d_one_zero] using hx
    have hx0 : (show ℤ from x) = 0 := by
      have hinj := mulZ_injective k hk
      have h0 : (ModuleCat.Hom.hom (mulZ k)) (0 : ℤ) = 0 := by simp
      exact hinj (hx'.trans h0.symm)
    simpa using hx0.symm
  | (m + 1) =>
    rw [HomologicalComplex.exactAt_iff]
    exact ShortComplex.exact_of_isZero_X₂ _ (isZero_resComplex_X k m)

instance quasiIso_resPi (k : ℕ) (hk : k ≠ 0) : QuasiIso (resPi k) where
  quasiIsoAt n := by
    match n with
    | 0 => exact quasiIsoAt_resPi_zero k hk
    | (m + 1) => exact quasiIsoAt_resPi_succ k hk m

/-- **The standard free resolution of `ZMod k`** as a bundled projective resolution. -/
noncomputable def zmodProjectiveResolution (k : ℕ) (hk : k ≠ 0) :
    ProjectiveResolution (ModuleCat.of ℤ (ZMod k)) where
  complex := resComplex k
  projective := projective_resComplex_X k
  π := resPi k
  quasiIso := quasiIso_resPi k hk

/-- Since the resolution has length one, all left derived functors of an additive functor `F`
vanish on `ZMod k` in degrees `≥ 2`. -/
theorem isZero_leftDerived_of_two_le {D : Type*} [Category D] [Abelian D]
    (F : ModuleCat.{0} ℤ ⥤ D) [F.Additive] (k : ℕ) (hk : k ≠ 0) (n : ℕ) :
    IsZero ((F.leftDerived (n + 2)).obj (ModuleCat.of ℤ (ZMod k))) := by
  have h := (zmodProjectiveResolution k hk).isoLeftDerivedObj F (n + 2)
  refine IsZero.of_iso ?_ h
  have hzero : IsZero (F.obj ((resComplex k).X (n + 2))) :=
    Functor.map_isZero F (isZero_resComplex_X k n)
  have : IsZero (((F.mapHomologicalComplex (ComplexShape.down ℕ)).obj
      (resComplex k)).X (n + 2)) := hzero
  exact (HomologicalComplex.exactAt_iff_isZero_homology _ _).1
    (ShortComplex.exact_of_isZero_X₂ _ this)

/-- All higher `Tor` groups against `ZMod k` vanish from degree two on. -/
theorem isZero_Tor_two_le_zmod (G : ModuleCat.{0} ℤ) (k : ℕ) (hk : k ≠ 0) (n : ℕ) :
    IsZero (((Tor (ModuleCat.{0} ℤ) (n + 2)).obj G).obj (ModuleCat.of ℤ (ZMod k))) :=
  isZero_leftDerived_of_two_le
    ((MonoidalCategory.tensoringLeft (ModuleCat.{0} ℤ)).obj G) k hk n

end Catalog.DerivedFunctors