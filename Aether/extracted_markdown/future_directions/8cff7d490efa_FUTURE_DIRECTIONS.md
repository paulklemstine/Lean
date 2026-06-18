# Future Directions — Fourier Analysis as a Functor

## Synthesis

This cycle reduced the analytic edifice of Fourier duality to its load-bearing
*categorical* skeleton, parametrized by an abstract dualizing object `T` (read
`T = ℝ/ℤ`). On the category `AddCommGrpCat` of abelian groups we built:

- a contravariant **dual functor** `DualFunctor T : AddCommGrpᵒᵖ ⥤ AddCommGrp`,
  `A ↦ (A →+ T)`, whose functoriality (`dualMap_id`, `dualMap_comp`) is exactly
  the statement that `Hom(-, ℝ/ℤ)` is contravariant — the structural shadow of
  the uncertainty principle;
- a **double-dual functor** `DDFunctor T` and the **Pontryagin unit**
  `PontryaginUnit T : 𝟭 ⟶ DDFunctor T`, the naturality of which (`eval_natural`)
  makes the Fourier transform a genuine natural transformation;
- a constructive computation `dualOfInt : (ℤ →+ T) ≃+ T` — the dual of `ℤ` is
  the circle — exhibiting an explicit witness `t ↦ (n ↦ n • t)`.

## Results Summary

| Result | Statement | Status |
|---|---|---|
| `dualMap_id` | `(id)^* = id` | proved, axioms standard |
| `dualMap_comp` | `(g∘f)^* = f^* ∘ g^*` (contravariance) | proved |
| `eval_natural` | double-dual evaluation is natural | proved |
| `DualFunctor` | duality as a functor `Cᵒᵖ ⥤ C` | proved (laws) |
| `PontryaginUnit` | duality unit as a `NatTrans 𝟭 ⟶ DD` | proved (naturality) |
| `dualOfInt` | `(ℤ →+ T) ≃+ T`, constructive | proved |

Everything is `sorry`-free and depends only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. The unit is a natural *isomorphism* on finite abelian groups

For finite abelian `A` and `T = ℝ/ℤ` (or `T = ℂˣ` roots of unity), the
evaluation `eval A : A → A^^` is bijective, so `PontryaginUnit` restricts to a
natural isomorphism — finite Pontryagin duality as an honest equivalence of
categories `FinAbGrpᵒᵖ ≌ FinAbGrp`. The key insight is that, once `eval` is
already a *natural transformation* (this cycle), upgrading duality to an
equivalence is purely the pointwise bijectivity statement: there is no further
coherence to check, because naturality is free. **Why now?** We have the unit in
hand and Mathlib has the structure theorem for finite abelian groups
(`AddCommGroup.equiv_directSum_zmod_of_finite`); the remaining content is
character-separation for cyclic groups, which is concrete and decidable.

### 2. Self-duality of `ZMod n` is computable and `decide`-able

Mirroring `dualOfInt`, the dual of `ZMod n` valued in `ZMod n` should be
`ZMod n` itself, with the pairing `(a, b) ↦ a * b` giving an explicit, *finitely
enumerable* iso `(ZMod n →+ ZMod n) ≃+ ZMod n`. The key insight is that for
finite cyclic groups the character pairing is a finite table, so duality becomes
a `decide`-checkable fact rather than an analytic theorem. **Why now?** This
cycle's `dualOfInt` already isolates the `t ↦ (n ↦ n • t)` witness pattern;
swapping `ℤ` for `ZMod n` turns it into a computational object suitable for
`#eval`-based verification, matching the engine's constructive mandate.

### 3. Functoriality of the double dual factors the unit through a comparison square

The double-dual functor should arise *canonically* as the composite of the dual
functor with its own opposite, `DDFunctor T ≅ DualFunctor T ∘ (DualFunctor T)ᵒᵖ`,
and the Pontryagin unit should be the mate of the identity under this
factorization. The key insight is that contravariance composed with itself is
covariance, so the double dual is forced to be covariant — explaining structurally
why `eval` (not some twisted variant) is the natural map. **Why now?** Both
functors are formalized here as separate definitions; proving them isomorphic is
a finishing `NatIso` argument that would consolidate the two into one derived
object and is well within reach of the current API.

### 4. A categorical uncertainty principle via support functors

Introduce a "support" endofunctor measuring localization (e.g. via the
annihilator subgroup of a finite-support character set) and prove a contravariant
inequality: refining support upstairs coarsens it downstairs. The key insight is
that the uncertainty principle is not an inequality between two numbers but a
contravariant *monotonicity* of support along `DualFunctor`, i.e. an order-reversing
natural transformation. **Why now?** `dualMap_comp` already encodes the order
reversal at the level of morphisms; lifting it to a lattice of subgroups is the
natural next abstraction, and Mathlib's `AddSubgroup` lattice supplies the target.

### 5. Plancherel as an adjunction unit/counit triangle identity

Conjecture that, for the right choice of `T` and a measure, the Fourier transform
and its inverse form an adjoint pair whose unit is `PontryaginUnit` and whose
triangle identities encode the Plancherel/inversion theorem. The key insight is
that Fourier inversion is *exactly* a triangle identity `(εD)∘(Dη) = id` for the
duality (co)unit, recasting an analytic theorem as a categorical coherence. **Why
now?** With the unit `𝟭 ⟶ DD` already constructed and natural, the only missing
ingredient is the counit; assembling the two into an adjunction is a standard
`CategoryTheory.Adjunction.mkOfUnitCounit` exercise once the counit is built.
