import Cryptography.WeilPairingStructure

/-!
# Cryptanalytic consequences of the Weil pairing

Two classical facts about pairings are proved here from the catalog axioms:

* **Isogeny/endomorphism equivariance.**  In the determinant model, an endomorphism of
  the torsion group given by a `2 × 2` matrix scales the pairing by its determinant
  (`detForm_linMap`, `detPairing_linMap`).  Specialising to multiplication by `m` this
  gives the classical degree law `e(mP, mQ) = e(P,Q)^{m²}`
  (`AltPairing.pair_nsmul_both`), which we also prove for an arbitrary alternating
  pairing.
* **The pairing destroys DDH.**  If `ζ = e(P,Q)` has order `n`, then the decisional
  Diffie–Hellman relation `c ≡ ab` is *equivalent* to an equality of two pairing values
  that a solver can compute from the group elements `aP`, `bQ`, `cQ` alone
  (`AltPairing.ddh_iff`, `AltPairing.ddh_solvable`).  Consequently no security proof in a
  pairing group may rest on DDH, which is exactly why BLS is reduced to CDH in
  `Cryptography.WeilPairingBLS`; `AltPairing.cdh_not_decided_by_pairing` records the
  complementary fact that the same test says nothing about a CDH *witness* on the curve
  when the pairing is alternating on a single cyclic subgroup.
-/

open scoped BigOperators

namespace Cryptography.WeilBLS

universe u v

section Endomorphism

variable {A : Type u} [AddCommGroup A] {μ : Type v} [CommGroup μ] (E : AltPairing A μ)

/-- **Degree law for multiplication by `m`.**  Follows from bilinearity and holds for
every alternating pairing: `e(mP, mQ) = e(P,Q)^{m²}`. -/
theorem AltPairing.pair_nsmul_both (m : ℕ) (x y : A) :
    E.pair (m • x) (m • y) = E.pair x y ^ (m ^ 2) := by
  rw [E.pair_nsmul_left, E.pair_nsmul_right, ← pow_mul, sq]

/-- The integer version of the degree law. -/
theorem AltPairing.pair_zsmul_both (m : ℤ) (x y : A) :
    E.pair (m • x) (m • y) = E.pair x y ^ (m ^ 2) := by
  rw [E.pair_zsmul_left, E.pair_zsmul_right, ← zpow_mul, sq]

end Endomorphism

/-! ## Endomorphisms of the determinant model -/

/-- The endomorphism of `(ZMod n)²` given by the matrix `!![a, b; c, d]`. -/
def linMap (n : ℕ) (a b c d : ZMod n) : (ZMod n × ZMod n) →+ (ZMod n × ZMod n) where
  toFun v := (a * v.1 + b * v.2, c * v.1 + d * v.2)
  map_zero' := by simp
  map_add' v w := by
    ext <;> simp only [Prod.fst_add, Prod.snd_add] <;> ring

@[simp] theorem linMap_apply (n : ℕ) (a b c d : ZMod n) (v : ZMod n × ZMod n) :
    linMap n a b c d v = (a * v.1 + b * v.2, c * v.1 + d * v.2) := rfl

/-- **The determinant form is equivariant with determinant factor.**  This is the
algebraic shadow of `e(φP, φQ) = e(P,Q)^{deg φ}` for an isogeny `φ`. -/
theorem detForm_linMap (n : ℕ) (a b c d : ZMod n) (v w : ZMod n × ZMod n) :
    detForm n (linMap n a b c d v) (linMap n a b c d w)
      = (a * d - b * c) * detForm n v w := by
  simp only [linMap_apply, detForm]
  ring

/-- Pairing version of `detForm_linMap`. -/
theorem detPairing_linMap (n : ℕ) (a b c d : ZMod n) (v w : ZMod n × ZMod n) :
    (detPairing n).pair (linMap n a b c d v) (linMap n a b c d w)
      = Multiplicative.ofAdd ((a * d - b * c) * detForm n v w) := by
  rw [detPairing_apply, detForm_linMap]

/-- Consistency check: for the scalar matrix `m • I` the determinant factor `m²` agrees
with the abstract degree law `AltPairing.pair_nsmul_both`. -/
theorem detPairing_scalar_endomorphism (n : ℕ) (m : ℕ) (v w : ZMod n × ZMod n) :
    (detPairing n).pair (linMap n (m : ZMod n) 0 0 (m : ZMod n) v)
        (linMap n (m : ZMod n) 0 0 (m : ZMod n) w)
      = (detPairing n).pair v w ^ (m ^ 2) := by
  have hv : linMap n (m : ZMod n) 0 0 (m : ZMod n) v = m • v := by
    ext <;> simp [nsmul_eq_mul]
  have hw : linMap n (m : ZMod n) 0 0 (m : ZMod n) w = m • w := by
    ext <;> simp [nsmul_eq_mul]
  rw [hv, hw, (detPairing n).pair_nsmul_both]

/-! ## The pairing solves the decisional Diffie–Hellman problem -/

section DDH

variable {A : Type u} [AddCommGroup A] {μ : Type v} [CommGroup μ] (E : AltPairing A μ)

/-- **DDH is easy in a pairing group.**  With `ζ = e(P,Q)` of order `n`, the tuple
`(aP, bQ, cQ)` is a Diffie–Hellman tuple exactly when the two pairing values
`e(aP, bQ)` and `e(P, cQ)` agree.  Both values are computable from the group elements
alone, without knowing `a`, `b` or `c`. -/
theorem AltPairing.ddh_iff {P Q : A} {n : ℕ} (hord : orderOf (E.pair P Q) = n)
    (a b c : ℕ) :
    E.pair (a • P) (b • Q) = E.pair P (c • Q) ↔ a * b ≡ c [MOD n] := by
  rw [E.pair_nsmul_left, E.pair_nsmul_right, ← pow_mul, E.pair_nsmul_right,
    pow_eq_pow_iff_modEq, hord, Nat.mul_comm]

/-- The decision procedure of `ddh_iff`, packaged: a predicate on the *group elements*
that decides the Diffie–Hellman relation on the hidden exponents. -/
theorem AltPairing.ddh_solvable {P Q : A} {n : ℕ} (hord : orderOf (E.pair P Q) = n) :
    ∃ test : A → A → A → Prop,
      (∀ a b c : ℕ, test (a • P) (b • Q) (c • Q) ↔ a * b ≡ c [MOD n]) := by
  refine ⟨fun X Y Z => E.pair X Y = E.pair P Z, fun a b c => ?_⟩
  exact E.ddh_iff hord a b c

/-- **The pairing test is blind on a single cyclic subgroup.**  If both arguments are
taken from `⟨P⟩` the pairing is identically trivial, so it gives *no* information: this
is the precise sense in which the MOV/DDH attack needs two independent torsion
directions, and the reason a nondegenerate pairing forces rank-two torsion
(`WeilPairing.torsion_trivial_of_cyclic`). -/
theorem AltPairing.cdh_not_decided_by_pairing (P : A) (a b c : ℕ) :
    E.pair (a • P) (b • P) = E.pair P (c • P) := by
  rw [E.pair_nsmul_nsmul_self, E.pair_nsmul_right, E.pair_self, one_pow]

end DDH

end Cryptography.WeilBLS