/-
# Structure of `H_{p^3}`: matrix realisation, centre, commutator subgroup, exponent

This file justifies the description of `Heis p` used throughout: it *is* the
group of upper unitriangular `3 × 3` matrices over `ZMod p`, its centre and
commutator subgroup both equal `⟨v⟩ ≅ C_p`, it has order `p ^ 3` (so
`|Heis 5| = 125`) and, for odd primes `p`, exponent exactly `p`.
-/
import Algebra.Heisenberg125.Basic

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

/-! ## Matrix realisation -/

/-- The unitriangular matrix attached to an element of `Heis p`. -/
def toMatrix (g : Heis p) : Matrix (Fin 3) (Fin 3) (ZMod p) :=
  !![1, g.a, g.c; 0, 1, g.b; 0, 0, 1]

/-- `Heis p` is the group of upper unitriangular `3 × 3` matrices over
`ZMod p`: the map `toMatrix` is a multiplicative, injective map. -/
def toMatrixHom : Heis p →* Matrix (Fin 3) (Fin 3) (ZMod p) where
  toFun := toMatrix
  map_one' := by
    ext i j
    fin_cases i <;> fin_cases j <;> simp [toMatrix]
  map_mul' g h := by
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [toMatrix, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

lemma toMatrixHom_injective : Function.Injective (toMatrixHom (p := p)) := by
  intro g h hgh
  have h01 := congrFun (congrFun hgh 0) 1
  have h12 := congrFun (congrFun hgh 1) 2
  have h02 := congrFun (congrFun hgh 0) 2
  simp only [toMatrixHom, toMatrix, MonoidHom.coe_mk, OneHom.coe_mk] at h01 h12 h02
  norm_num at h01 h12 h02
  ext
  · exact h01
  · exact h12
  · exact h02

/-! ## Centre and commutator subgroup -/

/-- An element is central iff its image in `(ZMod p)^2` vanishes, i.e. iff it is
a power of `v`. -/
theorem mem_center_iff {g : Heis p} :
    g ∈ Subgroup.center (Heis p) ↔ g.a = 0 ∧ g.b = 0 := by
  constructor
  · intro hg
    have h1 : g.a * (1 : ZMod p) = 0 * g.b := commute_iff.1 ((Subgroup.mem_center_iff.1 hg) (y p)).symm
    have h2 : g.a * (0 : ZMod p) = 1 * g.b := commute_iff.1 ((Subgroup.mem_center_iff.1 hg) (x p)).symm
    constructor
    · simpa using h1
    · simpa using h2.symm
  · rintro ⟨ha, hb⟩
    rw [Subgroup.mem_center_iff]
    intro h
    have : Commute g h := commute_iff.2 (by simp [ha, hb])
    exact this.symm
/-- The centre of `Heis p` is exactly the set of central elements `(0,0,c)`. -/
theorem center_eq : (Subgroup.center (Heis p) : Set (Heis p)) = {g | g.a = 0 ∧ g.b = 0} := by
  ext g
  exact mem_center_iff

/-- Every commutator is central. -/
theorem commutator_mem_center (g h : Heis p) :
    g * h * g⁻¹ * h⁻¹ ∈ Subgroup.center (Heis p) := by
  rw [mem_center_iff, commutator_eq]
  exact ⟨rfl, rfl⟩

/-- Every central element is a commutator: `(0,0,c) = [x^c, y]`. -/
theorem exists_commutator_eq (c : ZMod p) :
    ∃ g h : Heis p, g * h * g⁻¹ * h⁻¹ = ⟨0, 0, c⟩ := by
  refine ⟨⟨c, 0, 0⟩, y p, ?_⟩
  rw [commutator_eq]
  ext <;> simp [y]

/-- The commutator subgroup of `Heis p` is its centre. -/
theorem commutator_eq_center : commutator (Heis p) = Subgroup.center (Heis p) := by
  refine le_antisymm ?_ ?_
  · rw [commutator_def, Subgroup.commutator_le]
    intro g _ h _
    have := commutator_mem_center g h
    simpa [commutatorElement_def, mul_assoc] using this
  · intro g hg
    obtain ⟨ha, hb⟩ := mem_center_iff.1 hg
    obtain ⟨u, w, huw⟩ := exists_commutator_eq (p := p) g.c
    have hgu : g = u * w * u⁻¹ * w⁻¹ := by
      rw [huw]; ext <;> simp [ha, hb]
    rw [hgu]
    exact Subgroup.commutator_mem_commutator (Subgroup.mem_top u) (Subgroup.mem_top w)

/-! ## Order and exponent -/

/-- The Heisenberg group of the title has order `125`. -/
theorem card_heis_five : Fintype.card (Heis 5) = 125 := by
  rw [card_heis]
  norm_num

/-- `x` has order `p`: no smaller positive power is trivial. -/
lemma x_pow_ne_one {k : ℕ} (hk : 0 < k) (hkp : k < p) : (x p) ^ k ≠ 1 := by
  rw [pow_eq, Ne, eq_one_iff]
  rintro ⟨h1, -, -⟩
  simp only [x, mul_one] at h1
  have : p ∣ k := (ZMod.natCast_eq_zero_iff _ _).1 h1
  have := Nat.le_of_dvd hk this
  omega

/-- For odd primes `p`, the exponent of `Heis p` is exactly `p`: it is the
*exponent-`p`* Heisenberg group. -/
theorem exponent_eq [Fact p.Prime] (hodd : Odd p) : Monoid.exponent (Heis p) = p := by
  have hdvd : Monoid.exponent (Heis p) ∣ p :=
    Monoid.exponent_dvd_of_forall_pow_eq_one (pow_p_eq_one hodd)
  rcases (Nat.Prime.eq_one_or_self_of_dvd (Fact.out : p.Prime) _ hdvd) with h | h
  · exfalso
    have hx : (x p) ^ 1 = 1 := by
      have := Monoid.pow_exponent_eq_one (x p)
      rwa [h] at this
    exact x_pow_ne_one one_pos (Fact.out : p.Prime).one_lt hx
  · exact h

end Heis

end Heisenberg125