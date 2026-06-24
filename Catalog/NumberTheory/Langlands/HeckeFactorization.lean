/-
# Local–global factorization of Hecke (Dirichlet) characters

On the automorphic side of the GL(1) correspondence, the idèle class character group factors
as a restricted product over places.  In the finite-order / cyclotomic incarnation this is the
**multiplicativity of Dirichlet characters in the modulus**: for coprime `m` and `k`,
$$\widehat{(\mathbb Z/mk)^\times}\;\cong\;\widehat{(\mathbb Z/m)^\times}\times\widehat{(\mathbb Z/k)^\times},$$
i.e. a Hecke character of conductor dividing `mk` splits canonically into its `m`-part and its
`k`-part.  This is the GL(1) shadow of the adelic product structure, driven by the Chinese
Remainder Theorem.

Main results:

* `HeckeFactorization.unitsCRT` — the CRT isomorphism `(ZMod (m*k))ˣ ≃* (ZMod m)ˣ × (ZMod k)ˣ`.
* `HeckeFactorization.heckeFactorization` — the group isomorphism
  `DirichletCharacter ℂ (m*k) ≃* DirichletCharacter ℂ m × DirichletCharacter ℂ k`.
* `HeckeFactorization.card_dirichlet_mul` — the resulting count
  `φ(m*k) = φ(m) * φ(k)` obtained *structurally* from the isomorphism.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the "restricted product over places" defining the idèle class
character group must, in the cyclotomic GL(1) case, become a finite product isomorphism of
Dirichlet character groups indexed by coprime moduli.

Experiment (Experimenter): the engine is `ZMod.chineseRemainder` (a ring iso), promoted to a
unit-group iso via `Units.mapEquiv` and `MulEquiv.prodUnits`.  The character-group side needs
`Hom(A × B, M) ≃* Hom(A,M) × Hom(B,M)` (the universal property `homProdEquiv`), and the
identification `MulChar (ZMod n) ℂ ≃* ((ZMod n)ˣ →* ℂˣ)` via `MulChar.mulEquivToUnitHom`.

Analysis (Analyst): the four-step composite is an honest group isomorphism, not just a set
bijection.  Taking cardinalities recovers `φ(mk) = φ(m)φ(k)` for coprime `m,k` *as a
corollary of the structural decomposition* rather than from `Nat.totient_mul` directly — the
isomorphism is the primary object.  Failure mode that did NOT occur: one might fear that
`homProdEquiv` needs `M` finite; it does not, only commutativity, since `coprod` exists for
any commutative target.

Critique (Critic): is `card_dirichlet_mul` trivial?  No — its proof transports cardinality
through a genuine isomorphism (`Nat.card_congr`, `Nat.card_prod`) and then identifies each
factor with `φ`.  The decomposition isomorphism `heckeFactorization` is the real content and
contains no `sorry`.  Corner case: `m = 0` or `k = 0` — handled because `unitsCRT` only needs
`Coprime`, and the cardinality statement is stated for the totient which is correct at `0,1`.

Synthesis (PI): the GL(1) local–global factorization is formalized as an explicit group
isomorphism of Hecke character groups, with its arithmetic shadow the multiplicativity of `φ`.
-/
import Mathlib

open scoped Classical

namespace HeckeFactorization

/-- The universal property of products: `Hom(A × B, M) ≃* Hom(A, M) × Hom(B, M)` for a
commutative target `M`. -/
noncomputable def homProdEquiv (A B M : Type*) [CommGroup A] [CommGroup B] [CommGroup M] :
    ((A × B) →* M) ≃* (A →* M) × (B →* M) where
  toFun f := (f.comp (MonoidHom.inl A B), f.comp (MonoidHom.inr A B))
  invFun p := p.1.coprod p.2
  left_inv f := by
    ext x
    simp only [MonoidHom.coprod_apply, MonoidHom.comp_apply, MonoidHom.inl_apply,
      MonoidHom.inr_apply, ← f.map_mul, Prod.mk_mul_mk, mul_one, one_mul]
  right_inv p := by ext x <;> simp
  map_mul' f g := by ext <;> simp

/-- Precomposition with a group isomorphism `e : G ≃* H` as an isomorphism of character
groups `(H →* M) ≃* (G →* M)`. -/
noncomputable def precompMulEquiv {G H M : Type*} [Group G] [Group H] [CommGroup M]
    (e : G ≃* H) : (H →* M) ≃* (G →* M) where
  toFun φ := φ.comp e.toMonoidHom
  invFun ψ := ψ.comp e.symm.toMonoidHom
  left_inv φ := by ext x; simp
  right_inv ψ := by ext x; simp
  map_mul' a b := by ext x; simp

/-- **Chinese Remainder Theorem on units.**  For coprime `m, k`,
`(ZMod (m*k))ˣ ≃* (ZMod m)ˣ × (ZMod k)ˣ`. -/
noncomputable def unitsCRT (m k : ℕ) (h : m.Coprime k) :
    (ZMod (m * k))ˣ ≃* (ZMod m)ˣ × (ZMod k)ˣ :=
  (Units.mapEquiv (ZMod.chineseRemainder h).toMulEquiv).trans MulEquiv.prodUnits

/-- **Local–global factorization of Hecke characters.**  For coprime `m` and `k`, the group of
Dirichlet characters mod `m*k` is canonically isomorphic to the product of the groups of
Dirichlet characters mod `m` and mod `k`.  This is the GL(1) shadow of the idèlic product
structure. -/
noncomputable def heckeFactorization (m k : ℕ) (h : m.Coprime k) :
    DirichletCharacter ℂ (m * k) ≃* DirichletCharacter ℂ m × DirichletCharacter ℂ k :=
  MulChar.mulEquivToUnitHom.trans <|
    (precompMulEquiv (unitsCRT m k h).symm).trans <|
      (homProdEquiv _ _ _).trans
        (MulEquiv.prodCongr MulChar.mulEquivToUnitHom.symm MulChar.mulEquivToUnitHom.symm)

/-- The number of Dirichlet characters mod `n` valued in `ℂ` equals `φ(n)`. -/
theorem card_dirichlet_eq_totient (n : ℕ) [NeZero n] :
    Nat.card (DirichletCharacter ℂ n) = Nat.totient n := by
  rw [MulChar.card_eq_card_units_of_hasEnoughRootsOfUnity (ZMod n) ℂ,
      Nat.card_eq_fintype_card, ZMod.card_units_eq_totient]

/-- **Multiplicativity of `φ`, obtained structurally.**  For coprime `m, k` with both nonzero,
the count of Hecke characters multiplies: `φ(m*k) = φ(m) * φ(k)`.  Proved by transporting
cardinality across the factorization isomorphism. -/
theorem card_dirichlet_mul (m k : ℕ) [NeZero m] [NeZero k] (h : m.Coprime k) :
    Nat.totient (m * k) = Nat.totient m * Nat.totient k := by
  haveI : NeZero (m * k) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne k)⟩
  have hcard : Nat.card (DirichletCharacter ℂ (m * k))
      = Nat.card (DirichletCharacter ℂ m) * Nat.card (DirichletCharacter ℂ k) := by
    rw [Nat.card_congr (heckeFactorization m k h).toEquiv, Nat.card_prod]
  rw [card_dirichlet_eq_totient, card_dirichlet_eq_totient, card_dirichlet_eq_totient] at hcard
  exact hcard

end HeckeFactorization