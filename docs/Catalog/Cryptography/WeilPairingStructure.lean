import Cryptography.WeilPairingDeterminant

/-!
# Structural consequences of Weil-pairing nondegeneracy

This file extracts the *structural* content of the Weil pairing axioms recorded in
`Cryptography.WeilPairingBLS` and the determinant model of
`Cryptography.WeilPairingDeterminant`.

Main results.

* `AltPairing.pair_eq_one_of_mem_cyclic` : an alternating pairing is **identically
  trivial** on any cyclic subgroup.  This is the algebraic reason why "self-pairings"
  (Type-1 pairings without a distortion map) cannot exist on `⟨P⟩`.
* `WeilPairing.torsion_trivial_of_cyclic` : a curve whose `n`-torsion is cyclic and
  carries a nondegenerate Weil pairing has *trivial* `n`-torsion.  Equivalently: a
  nontrivial nondegenerate Weil pairing forces rank-two torsion.  This is a genuine
  obstruction theorem, proved from the axioms alone.
* `WeilPairing.pair_injective_of_orderOf` and `WeilPairing.mov_reduction` : the
  **MOV embedding**.  If `ζ = e(P,Q)` has order `n` then `a ↦ e(aP, Q)` is injective
  modulo `n`, so the discrete logarithm problem in `⟨P⟩` embeds into the discrete
  logarithm problem in the multiplicative group `μₙ`.
* `alt_pairing_orderOf_eq_of_nondegenerate` : in the determinant model, nondegeneracy
  is *equivalent* to the root of unity having exact order `n`.
-/

open scoped BigOperators

namespace Cryptography.WeilBLS

universe u v

/-! ## Triviality on cyclic subgroups -/

section Cyclic

variable {A : Type u} [AddCommGroup A] {μ : Type v} [CommGroup μ] (E : AltPairing A μ)

/-- An alternating pairing vanishes on any pair of multiples of a single element:
`e(aP, bP) = 1`.  Hence it is identically trivial on the cyclic subgroup `⟨P⟩`. -/
theorem AltPairing.pair_smul_smul_self (a b : ℤ) (x : A) :
    E.pair (a • x) (b • x) = 1 := by
  rw [E.pair_zsmul_left, E.pair_zsmul_right, E.pair_self, one_zpow, one_zpow]

/-- Trivialty on a cyclic subgroup, stated for natural multiples. -/
theorem AltPairing.pair_nsmul_nsmul_self (a b : ℕ) (x : A) :
    E.pair (a • x) (b • x) = 1 := by
  rw [E.pair_nsmul_left, E.pair_nsmul_right, E.pair_self, one_pow, one_pow]

/-- If the whole group is cyclic then an alternating pairing is identically `1`. -/
theorem AltPairing.pair_eq_one_of_cyclic (g : A) (hgen : ∀ x : A, ∃ a : ℤ, x = a • g)
    (x y : A) : E.pair x y = 1 := by
  obtain ⟨a, rfl⟩ := hgen x
  obtain ⟨b, rfl⟩ := hgen y
  exact E.pair_smul_smul_self a b g

end Cyclic

variable {F : Type u} [Field F] [DecidableEq F]

/-! ## Nondegeneracy forbids cyclic torsion -/

/-- **Rank obstruction.**  If the `n`-torsion of `W` is cyclic and carries a
nondegenerate Weil pairing, then the `n`-torsion is trivial.  Contrapositively, a
nontrivial nondegenerate Weil pairing can only live on non-cyclic (rank two) torsion —
this is exactly why pairing-based cryptography needs two independent generators. -/
theorem WeilPairing.torsion_trivial_of_cyclic {W : WeierstrassCurve F} {n : ℕ}
    {μ : Type v} [CommGroup μ] (e : WeilPairing W n μ) (g : torsionPoints W n)
    (hgen : ∀ P : torsionPoints W n, ∃ a : ℤ, P = a • g) :
    ∀ P : torsionPoints W n, P = 0 := by
  have hg : g = 0 := by
    refine e.nondegenerate_left g fun Q => ?_
    have : e.toAltPairing.pair g Q = 1 :=
      e.toAltPairing.pair_eq_one_of_cyclic g hgen g Q
    have h1 : Additive.toMul (e.hom g Q) = 1 := this
    simpa using congrArg Additive.ofMul h1
  intro P
  obtain ⟨a, rfl⟩ := hgen P
  rw [hg, smul_zero]

/-- A convenient reformulation: if some `n`-torsion point is nonzero, the torsion group
is not cyclic. -/
theorem WeilPairing.not_cyclic_of_nontrivial {W : WeierstrassCurve F} {n : ℕ}
    {μ : Type v} [CommGroup μ] (e : WeilPairing W n μ) (P₀ : torsionPoints W n)
    (hP₀ : P₀ ≠ 0) :
    ¬ ∃ g : torsionPoints W n, ∀ P : torsionPoints W n, ∃ a : ℤ, P = a • g := by
  rintro ⟨g, hgen⟩
  exact hP₀ (e.torsion_trivial_of_cyclic g hgen P₀)

/-! ## The MOV embedding of the elliptic-curve discrete logarithm -/

section MOV

variable {A : Type u} [AddCommGroup A] {μ : Type v} [CommGroup μ] (E : AltPairing A μ)

/-- Pairing with a fixed point turns scalar multiplication into exponentiation: this is
the homomorphism underlying the MOV/Frey–Rück reduction. -/
theorem AltPairing.pair_nsmul_eq_pow (P Q : A) (a : ℕ) :
    E.pair (a • P) Q = (E.pair P Q) ^ a := E.pair_nsmul_left a P Q

/-- **MOV injectivity.**  If `ζ = e(P,Q)` has order `n`, then the discrete-logarithm map
`a ↦ e(aP,Q)` is injective on `{0,…,n-1}`, so a discrete logarithm in the finite field
group `μ` yields the discrete logarithm on the curve. -/
theorem AltPairing.dlog_injective_of_orderOf {P Q : A} {n : ℕ}
    (hord : orderOf (E.pair P Q) = n) {a b : ℕ} (ha : a < n) (hb : b < n)
    (h : E.pair (a • P) Q = E.pair (b • P) Q) : a = b := by
  rw [E.pair_nsmul_eq_pow, E.pair_nsmul_eq_pow] at h
  have := pow_injOn_Iio_orderOf (x := E.pair P Q)
  exact this (by simpa [hord] using ha) (by simpa [hord] using hb) h

/-- **MOV reduction.**  Solving the discrete logarithm problem in the pairing target
group solves it on the curve: if a candidate exponent `b` reproduces the paired value of
the challenge `aP`, then `b` is the curve discrete logarithm. -/
theorem AltPairing.mov_reduction {P Q : A} {n : ℕ}
    (hord : orderOf (E.pair P Q) = n) {a b : ℕ} (ha : a < n) (hb : b < n)
    (h : (E.pair P Q) ^ b = E.pair (a • P) Q) : b • P = a • P := by
  have : a = b := E.dlog_injective_of_orderOf hord ha hb (by
    rw [E.pair_nsmul_eq_pow P Q b, h])
  rw [this]

end MOV

/-! ## Nondegeneracy ⇔ exact order of the root of unity -/

/-- **Nondegeneracy pins the root of unity.**  In the determinant model `(ZMod n)²`, if
an alternating pairing is nondegenerate then its value `ζ` on the standard basis has
exact order `n`; combined with `AltPairing.pair_coords` this classifies nondegenerate
alternating pairings as the primitive powers of the determinant pairing. -/
theorem alt_pairing_orderOf_eq_of_nondegenerate {n : ℕ} [NeZero n] {μ : Type v}
    [CommGroup μ] (E : AltPairing (ZMod n × ZMod n) μ)
    (htor : E.pair ((1 : ZMod n), (0 : ZMod n)) ((0 : ZMod n), (1 : ZMod n)) ^ n = 1)
    (hnd : ∀ v, (∀ w, E.pair v w = 1) → v = 0) :
    orderOf (E.pair ((1 : ZMod n), (0 : ZMod n)) ((0 : ZMod n), (1 : ZMod n))) = n := by
  set e₁ : ZMod n × ZMod n := ((1 : ZMod n), (0 : ZMod n)) with he₁
  set e₂ : ZMod n × ZMod n := ((0 : ZMod n), (1 : ZMod n)) with he₂
  set ζ : μ := E.pair e₁ e₂ with hζ
  set k : ℕ := orderOf ζ with hk
  have hkn : k ∣ n := orderOf_dvd_of_pow_eq_one htor
  -- the point `k • e₁` pairs trivially with everything, hence vanishes
  have hv : ((k : ZMod n), (0 : ZMod n)) = (k : ℤ) • e₁ + (0 : ℤ) • e₂ := by
    ext <;> simp [he₁, he₂, zsmul_eq_mul]
  have hzero : ((k : ZMod n), (0 : ZMod n)) = 0 := by
    refine hnd _ fun w => ?_
    rw [hv, ← zmod_prod_coords w, E.pair_coords]
    have : ζ ^ ((k : ℤ) * (w.2.val : ℤ) - 0 * (w.1.val : ℤ)) = (ζ ^ k) ^ (w.2.val : ℤ) := by
      rw [zero_mul, sub_zero, zpow_mul]
      norm_cast
    rw [this, pow_orderOf_eq_one, one_zpow]
  have hnk : n ∣ k := by
    have : ((k : ZMod n)) = 0 := congrArg Prod.fst hzero
    exact (ZMod.natCast_eq_zero_iff k n).mp this
  exact Nat.dvd_antisymm hkn hnk

end Cryptography.WeilBLS