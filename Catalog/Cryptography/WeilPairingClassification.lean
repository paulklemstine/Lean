import Cryptography.WeilPairingStructure

/-!
# Complete classification of alternating pairings on `n`-torsion

`Cryptography.WeilPairingDeterminant` constructs *one* Weil pairing on `(ZMod n)²`.
Here we prove that it is essentially the only one.

Main results.

* `altPairing_zmod_eq_smul_det` : **every** alternating pairing
  `E : AltPairing ((ZMod n)²) (Multiplicative (ZMod n))` is `u · det` for the single
  scalar `u = toAdd (E.pair e₁ e₂)`.
* `altPairing_nondegenerate_iff_isUnit` : `E` is nondegenerate **iff** `u` is a unit of
  `ZMod n`.  So the nondegenerate alternating pairings are in bijection with
  `(ZMod n)ˣ`, and for prime `n` there are exactly `n - 1` of them.
* `altPairing_symplectic_normal_form` : a nondegenerate alternating pairing is the
  pullback of the determinant pairing along an automorphism of the torsion group —
  the symplectic normal form / uniqueness statement for the Weil pairing.
-/

open scoped BigOperators

namespace Cryptography.WeilBLS

universe v

section Classification

variable {n : ℕ} [NeZero n]
  (E : AltPairing (ZMod n × ZMod n) (Multiplicative (ZMod n)))

/-- The root of unity of a pairing on the determinant model, as a scalar. -/
def altRoot : ZMod n :=
  Multiplicative.toAdd (E.pair ((1 : ZMod n), (0 : ZMod n)) ((0 : ZMod n), (1 : ZMod n)))

/-- **Complete classification.**  Every alternating pairing on `(ZMod n)²` with values in
`μₙ = Multiplicative (ZMod n)` is a scalar multiple of the determinant form. -/
theorem altPairing_zmod_eq_smul_det (v w : ZMod n × ZMod n) :
    E.pair v w = Multiplicative.ofAdd (altRoot E * detForm n v w) := by
  have hcoord := E.pair_coords ((1 : ZMod n), (0 : ZMod n)) ((0 : ZMod n), (1 : ZMod n))
    (v.1.val : ℤ) (v.2.val : ℤ) (w.1.val : ℤ) (w.2.val : ℤ)
  rw [zmod_prod_coords v, zmod_prod_coords w] at hcoord
  rw [hcoord]
  have hz : E.pair ((1 : ZMod n), (0 : ZMod n)) ((0 : ZMod n), (1 : ZMod n))
      = Multiplicative.ofAdd (altRoot E) := rfl
  rw [hz, ← ofAdd_zsmul, zsmul_eq_mul]
  congr 1
  have h1 : (((v.1.val : ℤ) * (w.2.val : ℤ) - (v.2.val : ℤ) * (w.1.val : ℤ) : ℤ) : ZMod n)
      = detForm n v w := by
    push_cast [detForm]
    simp [ZMod.natCast_val, ZMod.cast_id]
  rw [h1, mul_comm]

/-- Multiplication by a unit is an automorphism of the torsion group. -/
def unitSmulEquiv (u : (ZMod n)ˣ) : (ZMod n × ZMod n) ≃+ (ZMod n × ZMod n) where
  toFun v := ((u : ZMod n) * v.1, (u : ZMod n) * v.2)
  invFun v := (((u⁻¹ : (ZMod n)ˣ) : ZMod n) * v.1, ((u⁻¹ : (ZMod n)ˣ) : ZMod n) * v.2)
  left_inv v := by
    ext <;> simp [← mul_assoc]
  right_inv v := by
    ext <;> simp [← mul_assoc]
  map_add' v w := by
    ext <;> simp [mul_add]

omit [NeZero n] in
@[simp] theorem unitSmulEquiv_apply (u : (ZMod n)ˣ) (v : ZMod n × ZMod n) :
    unitSmulEquiv u v = ((u : ZMod n) * v.1, (u : ZMod n) * v.2) := rfl

/-- If the scalar is a unit the pairing is nondegenerate. -/
theorem altPairing_nondegenerate_of_isUnit (hu : IsUnit (altRoot E))
    (v : ZMod n × ZMod n) (h : ∀ w, E.pair v w = 1) : v = 0 := by
  obtain ⟨u, hu⟩ := hu
  refine detPairing_nondegenerate_left v fun w => ?_
  have hw := h w
  rw [altPairing_zmod_eq_smul_det E v w, ofAdd_eq_one] at hw
  have : detForm n v w = 0 := by
    have := congrArg (fun x => ((u⁻¹ : (ZMod n)ˣ) : ZMod n) * x) hw
    simpa [← mul_assoc, ← hu] using this
  rw [detPairing_apply, this]
  rfl

/-- If the pairing is nondegenerate the scalar must be a unit. -/
theorem altPairing_isUnit_of_nondegenerate
    (hnd : ∀ v, (∀ w, E.pair v w = 1) → v = 0) : IsUnit (altRoot E) := by
  set u : ZMod n := altRoot E with hu
  by_contra hcon
  have hcop : ¬ Nat.Coprime u.val n := by
    intro hco
    exact hcon (by
      have : ((u.val : ℕ) : ZMod n) = u := by simp [ZMod.natCast_val, ZMod.cast_id]
      rw [← this]
      exact (ZMod.isUnit_iff_coprime u.val n).mpr hco)
  set g : ℕ := Nat.gcd u.val n with hg
  have hgn : g ∣ n := Nat.gcd_dvd_right _ _
  have hgu : g ∣ u.val := Nat.gcd_dvd_left _ _
  have hn0 : 0 < n := Nat.pos_of_ne_zero (NeZero.ne n)
  have hgpos : 0 < g := Nat.gcd_pos_of_pos_right _ hn0
  have hg1 : 1 < g := by
    rcases Nat.lt_or_ge 1 g with h | h
    · exact h
    · exact absurd (le_antisymm h hgpos) hcop
  set k : ℕ := n / g with hkdef
  have hkpos : 0 < k := Nat.div_pos (Nat.le_of_dvd hn0 hgn) (by omega)
  have hklt : k < n := Nat.div_lt_self hn0 hg1
  have hkzero : ((k : ZMod n)) ≠ 0 := by
    intro h
    have := (ZMod.natCast_eq_zero_iff k n).mp h
    have := Nat.le_of_dvd hkpos this
    omega
  have hmul : (k : ZMod n) * u = 0 := by
    have hval : ((u.val : ℕ) : ZMod n) = u := by simp [ZMod.natCast_val, ZMod.cast_id]
    rw [← hval, ← Nat.cast_mul]
    refine (ZMod.natCast_eq_zero_iff _ _).mpr ?_
    obtain ⟨t, ht⟩ := hgu
    refine ⟨t, ?_⟩
    rw [ht, hkdef]
    calc n / g * (g * t) = (n / g * g) * t := by ring
      _ = n * t := by rw [Nat.div_mul_cancel hgn]
  have hvzero : ((k : ZMod n), (0 : ZMod n)) = 0 := by
    refine hnd _ fun w => ?_
    rw [altPairing_zmod_eq_smul_det E, ofAdd_eq_one, detForm]
    simp only [zero_mul, sub_zero]
    calc u * ((k : ZMod n) * w.2) = ((k : ZMod n) * u) * w.2 := by ring
      _ = 0 := by rw [hmul, zero_mul]
  exact hkzero (congrArg Prod.fst hvzero)

/-- **Nondegenerate alternating pairings on `(ZMod n)²` are exactly the unit multiples of
the determinant pairing.**  For prime `n` there are therefore exactly `n - 1` of them. -/
theorem altPairing_nondegenerate_iff_isUnit :
    (∀ v, (∀ w, E.pair v w = 1) → v = 0) ↔ IsUnit (altRoot E) :=
  ⟨altPairing_isUnit_of_nondegenerate E, fun hu => altPairing_nondegenerate_of_isUnit E hu⟩

/-- **Symplectic normal form.**  Every nondegenerate alternating pairing on the torsion
group is the pullback of the determinant (Weil) pairing along an automorphism.  Two
nondegenerate pairings therefore differ only by a change of basis: the Weil pairing is
unique up to symplectic isomorphism. -/
theorem altPairing_symplectic_normal_form (hnd : ∀ v, (∀ w, E.pair v w = 1) → v = 0) :
    ∃ ψ : (ZMod n × ZMod n) ≃+ (ZMod n × ZMod n),
      ∀ v w, E.pair v w = (detPairing n).pair (ψ v) w := by
  obtain ⟨u, hu⟩ := altPairing_isUnit_of_nondegenerate E hnd
  refine ⟨unitSmulEquiv u, fun v w => ?_⟩
  rw [altPairing_zmod_eq_smul_det E, detPairing_apply]
  congr 1
  simp only [unitSmulEquiv_apply, detForm, hu]
  ring

end Classification

end Cryptography.WeilBLS