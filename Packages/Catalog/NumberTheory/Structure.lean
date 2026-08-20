import Catalog.NumberTheory.DoubleCover

/-!
# Polar decomposition: the multiplicative structure of the Möbius integers

Third research cycle.  The previous cycles showed that the Möbius twist is
invisible additively (`Mobius.MInt.equivZ`) and that addition admits no
orientation-local lift (`Mobius.MInt.no_separable_lift_of_add`).  Here we prove
the positive counterpart: **multiplicatively the orientation splits off as a
direct factor**.

* `Mobius.MInt.polarEquiv`: `Z̃ ∖ {0} ≃* Z̃ˣ × ℕ₊` — every nonzero Möbius
  integer factors uniquely as (orientation) · (radius).
* `Mobius.MInt.orientationSplitting`: consequently
  `Z̃ ∖ {0} ≃* ℤ/2 × ℕ₊`, i.e. the multiplicative monoid of the Möbius integers
  is a *trivial* `ℤ/2`-bundle over the multiplicative monoid of radii.  This is
  the structural pattern behind every finding of the programme: the double cover
  is multiplicatively trivialisable (hence class number one, unique
  factorisation up to orientation, `ζ̃ = 2ζ`), while additively it is not even
  liftable.
* `Mobius.MInt.orientation_surjective`: the orientation character
  `Z̃ ∖ {0} → ℤ/2` is onto, and `Mobius.MInt.orientation_pos` shows the positive
  radii form its kernel section.
-/

namespace Mobius
namespace MInt

open scoped nonZeroDivisors

theorem pos_mul (m n : ℕ) : pos (m * n) = pos m * pos n := by
  apply toZ_injective; simp [pos]

theorem pos_ne_zero {n : ℕ} (hn : n ≠ 0) : pos n ≠ 0 := by
  intro h
  have h2 := congrArg toZ h
  simp [pos] at h2
  omega

@[simp] theorem pos_one : pos 1 = 1 := by apply toZ_injective; simp [pos]

@[simp] theorem norm_unit (u : MIntˣ) : norm (u : MInt) = 1 := by
  rcases units_eq_one_or u with rfl | rfl <;> simp [norm]

/-- The polar map: an orientation and a positive radius determine a nonzero
Möbius integer. -/
def polarHom : MIntˣ × ℕ+ →* MInt⁰ where
  toFun := fun un => ⟨(un.1 : MInt) * pos (un.2 : ℕ),
    mem_nonZeroDivisors_iff_ne_zero.2 (mul_ne_zero (Units.ne_zero _) (pos_ne_zero un.2.ne_zero))⟩
  map_one' := by ext; simp
  map_mul' := by
    rintro ⟨u, m⟩ ⟨v, n⟩
    ext
    show ((u * v : MIntˣ) : MInt) * pos ((m * n : ℕ+) : ℕ) = ((u : MInt) * pos m) * (v * pos n)
    push_cast [pos_mul]
    ring

theorem polarHom_bijective : Function.Bijective polarHom := by
  constructor
  · rintro ⟨u, m⟩ ⟨v, n⟩ h
    have h' : (u : MInt) * pos (m : ℕ) = (v : MInt) * pos (n : ℕ) := congrArg Subtype.val h
    have hmn : (m : ℕ) = (n : ℕ) := by
      have hnorm := congrArg norm h'
      rwa [norm_mul, norm_mul, norm_unit, norm_unit, one_mul, one_mul, norm_pos, norm_pos] at hnorm
    have hm : m = n := PNat.coe_injective hmn
    subst hm
    have hu : (u : MInt) = (v : MInt) := mul_right_cancel₀ (pos_ne_zero m.ne_zero) h'
    simp [Units.ext hu]
  · rintro ⟨x, hx⟩
    have hx0 : x ≠ 0 := mem_nonZeroDivisors_iff_ne_zero.1 hx
    have hn : norm x ≠ 0 := fun h => hx0 ((norm_eq_zero_iff x).1 h)
    rcases Int.natAbs_eq (toZ x) with h | h
    · refine ⟨(1, ⟨norm x, Nat.pos_of_ne_zero hn⟩), ?_⟩
      ext
      show (1 : MInt) * pos (norm x) = x
      apply toZ_injective
      simp only [one_mul, toZ_pos]
      exact h.symm
    · refine ⟨(-1, ⟨norm x, Nat.pos_of_ne_zero hn⟩), ?_⟩
      ext
      show ((-1 : MIntˣ) : MInt) * pos (norm x) = x
      apply toZ_injective
      simp only [Units.val_neg, Units.val_one, neg_mul, one_mul, toZ_neg, toZ_pos]
      exact h.symm

/-- **Polar decomposition.**  Every nonzero Möbius integer is uniquely an
orientation times a radius. -/
noncomputable def polarEquiv : MIntˣ × ℕ+ ≃* MInt⁰ :=
  MulEquiv.ofBijective polarHom polarHom_bijective

/-- **The orientation splits.**  The multiplicative monoid of nonzero Möbius
integers is the *direct product* of the orientation group `ℤ/2` with the
multiplicative monoid of radii: the double cover is multiplicatively trivial. -/
noncomputable def orientationSplitting : Multiplicative (ZMod 2) × ℕ+ ≃* MInt⁰ :=
  (MulEquiv.prodCongr unitsEquivZMod2.symm (MulEquiv.refl ℕ+)).trans polarEquiv

/-- The orientation character of a nonzero Möbius integer. -/
noncomputable def orientationHom : MInt⁰ →* Multiplicative (ZMod 2) :=
  (MonoidHom.fst (Multiplicative (ZMod 2)) ℕ+).comp orientationSplitting.symm.toMonoidHom

theorem orientation_surjective : Function.Surjective orientationHom := by
  intro g
  refine ⟨orientationSplitting (g, 1), ?_⟩
  simp [orientationHom]

/-- Positively oriented radii are exactly the kernel section of the orientation
character. -/
theorem orientation_pos (n : ℕ+) :
    orientationHom (polarEquiv (1, n)) = 1 := by
  have h : orientationSplitting (1, n) = polarEquiv (1, n) := by
    simp [orientationSplitting, MulEquiv.prodCongr]
  simp [orientationHom, ← h]

/-! ### The oriented divisor function

The polar decomposition has an immediate arithmetic consequence: every divisor
of a nonzero Möbius integer comes in two orientations, so the Möbius divisor
function is twice the classical one. -/

theorem dvd_iff_toZ_dvd (d x : MInt) : d ∣ x ↔ toZ d ∣ toZ x := by
  constructor
  · rintro ⟨c, rfl⟩
    exact ⟨toZ c, by simp⟩
  · rintro ⟨c, hc⟩
    exact ⟨equivZ.symm c, toZ_injective (by simpa using hc)⟩

/-- The divisors of a nonzero integer, counted with sign. -/
theorem int_divisors_ncard {m : ℤ} (hm : m ≠ 0) :
    {n : ℤ | n ∣ m}.ncard = 2 * (m.natAbs.divisors).card := by
  classical
  have hm0 : m.natAbs ≠ 0 := by simpa using hm
  have hset : {n : ℤ | n ∣ m} =
      ↑((m.natAbs.divisors.image (fun k : ℕ => (k : ℤ))) ∪
        (m.natAbs.divisors.image (fun k : ℕ => -(k : ℤ)))) := by
    ext n
    simp only [Set.mem_setOf_eq, Finset.coe_union, Set.mem_union, Finset.coe_image,
      Set.mem_image, Finset.mem_coe, Nat.mem_divisors]
    constructor
    · intro hn
      have hdvd : n.natAbs ∣ m.natAbs := Int.natAbs_dvd_natAbs.2 hn
      rcases Int.natAbs_eq n with h | h
      · exact Or.inl ⟨n.natAbs, ⟨hdvd, hm0⟩, h.symm⟩
      · exact Or.inr ⟨n.natAbs, ⟨hdvd, hm0⟩, h.symm⟩
    · rintro (⟨k, ⟨hk, -⟩, rfl⟩ | ⟨k, ⟨hk, -⟩, rfl⟩)
      · exact Int.dvd_natAbs.1 (Int.natCast_dvd_natCast.2 hk)
      · exact (neg_dvd).2 (Int.dvd_natAbs.1 (Int.natCast_dvd_natCast.2 hk))
  have hdisj : Disjoint (m.natAbs.divisors.image (fun k : ℕ => (k : ℤ)))
      (m.natAbs.divisors.image (fun k : ℕ => -(k : ℤ))) := by
    rw [Finset.disjoint_left]
    rintro a ha hb
    simp only [Finset.mem_image, Nat.mem_divisors] at ha hb
    obtain ⟨k, ⟨-, -⟩, rfl⟩ := ha
    obtain ⟨j, ⟨hj, -⟩, hji⟩ := hb
    have hk0 : (0 : ℤ) < k := by
      rcases Nat.eq_zero_or_pos k with rfl | h
      · exfalso
        have hzero : (0 : ℤ) = -(j : ℤ) := by simpa using hji
        have hj0 : j = 0 := by omega
        exact (Nat.pos_of_mem_divisors (Nat.mem_divisors.2 ⟨hj, hm0⟩)).ne' hj0
      · exact_mod_cast h
    have hj0 : 0 < j := Nat.pos_of_mem_divisors (Nat.mem_divisors.2 ⟨hj, hm0⟩)
    omega
  have hinj1 : Function.Injective (fun k : ℕ => (k : ℤ)) := fun a b h => by
    simp only [Nat.cast_inj] at h; exact h
  have hinj2 : Function.Injective (fun k : ℕ => -(k : ℤ)) := fun a b h => by
    simp only [neg_inj, Nat.cast_inj] at h; exact h
  rw [hset, Set.ncard_coe_finset, Finset.card_union_of_disjoint hdisj,
    Finset.card_image_of_injective _ hinj1, Finset.card_image_of_injective _ hinj2]
  omega

/-- **The Möbius divisor function is twice the classical one**: a nonzero
Möbius integer of radius `n` has exactly `2 τ(n)` divisors, one pair per
classical divisor. -/
theorem divisors_ncard {x : MInt} (hx : x ≠ 0) :
    {d : MInt | d ∣ x}.ncard = 2 * ((norm x).divisors).card := by
  have hz : toZ x ≠ 0 := fun h => hx ((toZ_eq_zero_iff x).1 h)
  have hset : {d : MInt | d ∣ x} = (fun n : ℤ => mk (n, true)) '' {n : ℤ | n ∣ toZ x} := by
    ext d
    simp only [Set.mem_setOf_eq, Set.mem_image]
    constructor
    · intro hd
      exact ⟨toZ d, (dvd_iff_toZ_dvd d x).1 hd, toZ_injective rfl⟩
    · rintro ⟨n, hn, rfl⟩
      exact (dvd_iff_toZ_dvd _ x).2 (by simpa using hn)
  have hinj : Function.Injective (fun n : ℤ => mk (n, true)) := by
    intro m n hmn
    have := congrArg toZ hmn
    simpa using this
  rw [hset, Set.ncard_image_of_injective _ hinj, int_divisors_ncard hz]
  rfl

end MInt
end Mobius