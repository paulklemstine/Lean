import Mathlib

/-!
# Prismatic F-crystals: the Frobenius-module model and a purity skeleton

This file develops a fully formal, linear-algebraic model of *prismatic `F`-crystals*
over a bounded prism `(A, I)` with `R := A/I`, together with the categorical core of a
**purity** statement: restriction to a dense open is *faithful*, and is an *equivalence*
on `Hom`-sets as soon as the geometric extension ("Hartogs") input is available.

The geometric statement we are shadowing is:

> For a bounded prism `(A, I)` with `A/I` a regular local ring of dimension `d`, the
> restriction functor from prismatic `F`-crystals on `Spec(A/I)` to those on the
> punctured spectrum `Spec(A/I) \ {𝔪}` is an equivalence of categories.

A prismatic `F`-crystal, on the affine chart, is modelled by an `R`-module `M` together
with a `φ`-semilinear endomorphism `F` (`φ` the Frobenius lift on the prism base). This
is precisely a Mathlib semilinear map `M →ₛₗ[φ] M`. Morphisms are `R`-linear maps
commuting with the Frobenii. The honest, provable content here is:

* `restriction_faithful` — if the restriction map on the *target* crystal is injective
  (the depth `≥ 1` / torsion-freeness input that a regular ring supplies), then two
  morphisms agreeing after restriction are equal: the restriction functor is **faithful**.
* `purityHomEquiv` — packaging faithfulness with a *Hartogs extension operator*
  (the genuinely deep depth `≥ 2` input, supplied here as a hypothesis), restriction
  becomes a **bijection on `Hom`-sets**. This is the precise sense in which "purity
  reduces to extension".
* a concrete, non-vacuous instance over `ℤ ⊆ ℚ` (`trivZ_faithful`).

-- !-- Lab Notes -- !--
-- **Hypothesis (Hypothesizer).** Purity for prismatic `F`-crystals should, like
--   classical purity for vector bundles / reflexive sheaves, factor into two layers:
--   (a) faithfulness, controlled by torsion-freeness of `Hom`-modules (depth ≥ 1), and
--   (b) essential surjectivity + fullness, controlled by Hartogs extension across a
--   codimension ≥ 2 locus (depth ≥ 2, which regularity guarantees).
-- **Experiment (Experimenter).** We modelled an `F`-crystal as `M →ₛₗ[φ] M` and the
--   restriction-to-a-dense-open as an `F`-compatible `R`-linear map of underlying
--   modules. Layer (a) became `restriction_faithful`; layer (b), once abstracted as an
--   extension operator with a section property, became the `Equiv` `purityHomEquiv`.
-- **Analysis (Analyst).** Layer (a) is *true and short*: it is a pure injectivity
--   argument and needs no regularity beyond the injectivity hypothesis. Layer (b) is
--   *true but hard*: the section property is exactly the deep extension theorem, so we
--   keep it as a hypothesis rather than fake a proof. The split cleanly isolates the
--   one nontrivial geometric input.
-- **Critique (Critic).** `restriction_faithful` is non-vacuous: `trivZ_faithful`
--   instantiates it over `ℤ ⊆ ℚ` with a genuinely injective restriction. No theorem is
--   `True`/`rfl`/`native_decide`; each uses `ext` + injectivity, and `purityHomEquiv`
--   re-uses `restriction_faithful` to discharge `left_inv`.
-- **Synthesis (PI).** The dimension-one (= normality) shadow of the extension input is
--   discharged completely in `DimensionOnePurity.lean`.
-/

namespace PrismaticPurity

universe u

variable {R : Type u} [CommRing R] {φ : R →+* R}

/-- A **Frobenius module** (affine model of a prismatic `F`-crystal) over the prism base
`(R, φ)`: an `R`-module `M` with a `φ`-semilinear endomorphism `F`. -/
structure FMod (R : Type u) [CommRing R] (φ : R →+* R) where
  /-- underlying module -/
  M : Type u
  [acg : AddCommGroup M]
  [mod : Module R M]
  /-- the (`φ`-semilinear) Frobenius -/
  F : M →ₛₗ[φ] M

attribute [instance] FMod.acg FMod.mod

/-- A **morphism of Frobenius modules**: an `R`-linear map commuting with the Frobenii. -/
structure FHom (E E' : FMod R φ) where
  /-- underlying `R`-linear map -/
  hom : E.M →ₗ[R] E'.M
  /-- `F`-equivariance -/
  comm : ∀ x, hom (E.F x) = E'.F (hom x)

@[ext] theorem FHom.ext {E E' : FMod R φ} {a b : FHom E E'}
    (h : a.hom = b.hom) : a = b := by
  cases a; cases b; cases h; rfl

/-- The identity morphism of an `F`-crystal. -/
def FHom.idMor (E : FMod R φ) : FHom E E :=
  ⟨LinearMap.id, by intro x; simp⟩

/-- Composition of `F`-crystal morphisms. -/
def FHom.comp {E E' E'' : FMod R φ} (g : FHom E' E'') (f : FHom E E') : FHom E E'' :=
  ⟨g.hom.comp f.hom, by intro x; simp [f.comm, g.comm]⟩

theorem FHom.id_comp {E E' : FMod R φ} (f : FHom E E') :
    (FHom.idMor E').comp f = f := by ext x; rfl

theorem FHom.comp_id {E E' : FMod R φ} (f : FHom E E') :
    f.comp (FHom.idMor E) = f := by ext x; rfl

theorem FHom.comp_assoc {E E' E'' E''' : FMod R φ}
    (h : FHom E'' E''') (g : FHom E' E'') (f : FHom E E') :
    (h.comp g).comp f = h.comp (g.comp f) := by ext x; rfl

/-- The **trivial (unit) `F`-crystal** `(R, φ)`: the base equipped with its own Frobenius.
This shows the category of `F`-crystals is never empty. -/
def triv (R : Type u) [CommRing R] (φ : R →+* R) : FMod R φ where
  M := R
  F :=
  { toFun := φ
    map_add' := map_add φ
    map_smul' := by intro m x; simp [smul_eq_mul, map_mul] }

/-- **Purity, layer (a): faithfulness of restriction.**

Given crystals `E, F` on the whole spectrum and their restrictions `EU, FU` to a dense
open, with restriction morphisms `ρE : E → EU` and `ρF : F → FU`: if `ρF` is injective on
underlying modules (the torsion-freeness / depth `≥ 1` input that regularity provides),
then two morphisms `a, b : E → F` whose restrictions agree are themselves equal. -/
theorem restriction_faithful
    {E F EU FU : FMod R φ} (ρE : FHom E EU) (ρF : FHom F FU)
    (hρF : Function.Injective ρF.hom) (a b : FHom E F) (aU bU : FHom EU FU)
    (sqa : ∀ x, ρF.hom (a.hom x) = aU.hom (ρE.hom x))
    (sqb : ∀ x, ρF.hom (b.hom x) = bU.hom (ρE.hom x)) (h : aU = bU) : a = b := by
  ext x
  apply hρF
  rw [sqa, sqb, h]

/-- **Purity, layer (b): restriction is a bijection on `Hom`-sets.**

We package faithfulness (layer (a)) with the *Hartogs extension input*: a function
`extend` producing, from a morphism on the dense open, a morphism on the whole spectrum
whose restriction recovers it (`hsec`). Under injectivity of the target restriction `ρF`,
the restriction map `restr` is then an `Equiv` with inverse `extend`. This is the precise
formal sense in which **purity reduces to the existence of compatible extensions**. -/
noncomputable def purityHomEquiv
    {E F EU FU : FMod R φ} (ρE : FHom E EU) (ρF : FHom F FU)
    (hρF : Function.Injective ρF.hom) (restr : FHom E F → FHom EU FU)
    (sq : ∀ (a : FHom E F) x, ρF.hom (a.hom x) = (restr a).hom (ρE.hom x))
    (extend : FHom EU FU → FHom E F) (hsec : ∀ g, restr (extend g) = g) :
    FHom E F ≃ FHom EU FU where
  toFun := restr
  invFun := extend
  left_inv := by
    intro a
    refine restriction_faithful ρE ρF hρF (extend (restr a)) a
      (restr (extend (restr a))) (restr a) (sq _) (sq _) ?_
    rw [hsec]
  right_inv := hsec

/-! ### A concrete, non-vacuous instance: `ℤ ⊆ ℚ`

The trivial `ℤ`-crystal restricted to the generic point (= localisation at `(0)`, the
universal dense open) gives an injective restriction map, so faithfulness genuinely
applies. -/

/-- The trivial `ℤ`-crystal. -/
def cZ : FMod ℤ (RingHom.id ℤ) := { M := ℤ, F := LinearMap.id }

/-- The trivial crystal on the generic point `Spec ℚ`. -/
def cQ : FMod ℤ (RingHom.id ℤ) := { M := ℚ, F := LinearMap.id }

/-- The restriction morphism `ℤ → ℚ` of crystals. -/
def rhoZQ : FHom cZ cQ := { hom := Algebra.linearMap ℤ ℚ, comm := fun _ => rfl }

theorem rhoZQ_injective : Function.Injective rhoZQ.hom := by
  intro a b h
  simpa [rhoZQ, cZ, cQ, Algebra.linearMap] using h

/-- **Concrete purity (faithfulness) over `ℤ`.** A morphism of trivial `ℤ`-crystals is
determined by its restriction to the generic point `Spec ℚ`. -/
theorem trivZ_faithful (a b : FHom cZ cZ) (aU bU : FHom cQ cQ)
    (sqa : ∀ x, rhoZQ.hom (a.hom x) = aU.hom (rhoZQ.hom x))
    (sqb : ∀ x, rhoZQ.hom (b.hom x) = bU.hom (rhoZQ.hom x)) (h : aU = bU) : a = b :=
  restriction_faithful rhoZQ rhoZQ rhoZQ_injective a b aU bU sqa sqb h

end PrismaticPurity