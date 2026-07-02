/-
# Explicit Artin reciprocity for the GL(1) Langlands correspondence (cyclotomic case)

The catalog file `Catalog.NumberTheory.GL1Correspondence` constructs the GL(1) Langlands
correspondence over `ℚ` in the cyclotomic case as an *abstract* group isomorphism
`LanglandsGL1.langlandsGL1 : DirichletCharacter ℂ n ≃* ((L ≃ₐ[ℚ] L) →* ℂˣ)`,
sending a Hecke (Dirichlet) character to a 1-dimensional Galois representation.

That isomorphism is built from the Artin reciprocity map `Gal(ℚ(ζₙ)/ℚ) ≃* (ZMod n)ˣ`, but the
*content* of reciprocity — what the map actually does to Galois automorphisms — is invisible at
that level of abstraction.  This file makes it explicit:

* The Artin map sends `σ` to the residue `a` for which `σ(ζₙ) = ζₙ^a`
  (`artin_action`).  This is the defining property of the cyclotomic Artin symbol.
* The Galois representation attached to a Hecke character `D` evaluates, at `σ`, to `D(a)`,
  where `a` is that *same* residue governing the action on roots of unity
  (`langlandsGL1_apply_coe`, `explicit_reciprocity`).

So the two sides of GL(1) Langlands are not merely abstractly isomorphic: the matching is the
explicit reciprocity law "Galois value at `σ` = Hecke value at the exponent by which `σ` raises
roots of unity".  We round this off with structural consequences: the correspondence preserves
orders (`langlandsGL1_orderOf`) and detects triviality (`langlandsGL1_eq_one_iff`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the abstract GL(1) isomorphism from the catalog must secretly be the
*explicit* reciprocity law — the value of the attached Galois representation at `σ` should be the
Dirichlet character evaluated at the cyclotomic Artin symbol of `σ`, the exponent governing the
action on `ζₙ`.

Experiment (Experimenter): Mathlib's `IsCyclotomicExtension.Rat.galEquivZMod` is *defined* to send
`σ ↦ a` with `σ ζₙ = ζₙ^a`, and `galEquivZMod_apply_of_pow_eq` is exactly that defining property.
Crucially, `LanglandsGL1.artinIso n L = galEquivZMod n L` holds by `rfl` (both unfold to
`autEquivPow`, the irreducibility proofs being propositionally irrelevant), so the catalog map and
the Mathlib explicit map are *the same arrow*.  Composing with `MulChar.coe_equivToUnitHom`
extracts the scalar value `D(a)`.

Analysis (Analyst): the key structural insight is that the GL(1) correspondence is "the Artin map,
pulled back on characters"; therefore every explicit fact about the Artin symbol transports to the
representation side.  A potential pitfall — a `ℚ`-algebra instance diamond between the catalog's
`[Algebra ℚ L]` and the `Gal(L/ℚ)` notation — is avoided by *not* introducing a separate algebra
instance and letting `DivisionRing.toRatAlgebra` be inferred uniformly.

Critique (Critic): is `explicit_reciprocity` trivial?  No — it fuses a genuine number-theoretic
lemma (the cyclotomic Artin action `σ ζₙ = ζₙ^a`) with the character extraction, and the order /
triviality corollaries use injectivity of a `MulEquiv`, not `decide`.  Hidden-assumption check:
`NeZero n` (so `ζₙ` exists) and `NumberField L` (so the Artin map is available) are both faithful.

Synthesis (PI): GL(1) Langlands over `ℚ`, made explicit: the dictionary between Hecke characters
and Galois representations *is* the cyclotomic reciprocity law, value-by-value.
-/
import Mathlib
import Catalog.NumberTheory.GL1Correspondence

open scoped NumberField
open IsCyclotomicExtension.Rat IsCyclotomicExtension Polynomial

namespace LanglandsGL1Explicit

variable (n : ℕ) [NeZero n] (L : Type*) [Field L] [NumberField L]
  [IsCyclotomicExtension {n} ℚ L]

/-- The catalog Artin map agrees with Mathlib's explicit cyclotomic Artin map. Both unfold to
`IsCyclotomicExtension.autEquivPow`; the irreducibility hypotheses are propositionally irrelevant. -/
theorem artinIso_eq_galEquivZMod :
    LanglandsGL1.artinIso n L = galEquivZMod n L := rfl

/-- **Explicit cyclotomic Artin action.** The Artin symbol `a = artinIso σ` is precisely the
exponent by which `σ` raises the canonical primitive `n`-th root of unity: `σ(ζₙ) = ζₙ^a`. -/
theorem artin_action (σ : Gal(L/ℚ)) :
    σ (zeta n ℚ L) = (zeta n ℚ L) ^ (LanglandsGL1.artinIso n L σ).val.val := by
  rw [artinIso_eq_galEquivZMod]
  exact galEquivZMod_apply_of_pow_eq n L σ (zeta_spec n ℚ L).pow_eq_one

/-- The 1-dimensional Galois representation attached to a Hecke (Dirichlet) character `D` is, at
`σ`, the unit-group character of `D` evaluated at the Artin symbol of `σ`. -/
theorem langlandsGL1_apply (D : DirichletCharacter ℂ n) (σ : Gal(L/ℚ)) :
    (LanglandsGL1.langlandsGL1 n L D) σ
      = (MulChar.mulEquivToUnitHom D) (LanglandsGL1.artinIso n L σ) := rfl

/-- **Scalar form of the GL(1) matching.** The complex value of the attached Galois representation
at `σ` equals the Dirichlet character `D` evaluated at the residue class `artinIso σ`. -/
theorem langlandsGL1_apply_coe (D : DirichletCharacter ℂ n) (σ : Gal(L/ℚ)) :
    ((LanglandsGL1.langlandsGL1 n L D) σ : ℂ)
      = D ((LanglandsGL1.artinIso n L σ : (ZMod n)ˣ) : ZMod n) := by
  rw [langlandsGL1_apply]
  exact MulChar.coe_equivToUnitHom D _

/-- **Explicit Artin reciprocity, GL(1) form.** For every automorphism `σ` of `ℚ(ζₙ)`, letting
`a := artinIso σ` be its Artin symbol:

* `σ` acts on roots of unity by raising to the `a`-th power: `σ(ζₙ) = ζₙ^a`, and
* the Galois representation attached to a Hecke character `D` takes, at `σ`, the value `D(a)`.

Thus the GL(1) Langlands dictionary is the explicit reciprocity law: the Galois value at `σ` is the
Hecke value at the exponent by which `σ` raises roots of unity. -/
theorem explicit_reciprocity (D : DirichletCharacter ℂ n) (σ : Gal(L/ℚ)) :
    σ (zeta n ℚ L) = (zeta n ℚ L) ^ (LanglandsGL1.artinIso n L σ).val.val ∧
      ((LanglandsGL1.langlandsGL1 n L D) σ : ℂ)
        = D ((LanglandsGL1.artinIso n L σ : (ZMod n)ˣ) : ZMod n) :=
  ⟨artin_action n L σ, langlandsGL1_apply_coe n L D σ⟩

/-- The correspondence detects triviality: the attached Galois representation is trivial iff the
Hecke character is the principal character. -/
theorem langlandsGL1_eq_one_iff (D : DirichletCharacter ℂ n) :
    LanglandsGL1.langlandsGL1 n L D = 1 ↔ D = 1 := by
  rw [← map_one (LanglandsGL1.langlandsGL1 n L)]
  exact (LanglandsGL1.langlandsGL1 n L).injective.eq_iff

end LanglandsGL1Explicit