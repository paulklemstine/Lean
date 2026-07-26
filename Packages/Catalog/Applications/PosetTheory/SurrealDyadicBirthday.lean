/-
# The Arithmetic of Games: Dyadic Surreal Numbers and Finite Birthdays

Conway's surreal numbers `No` form a proper class containing the reals, the ordinals
and the infinitesimals.  A guiding conjecture (Conway) is that the surreal numbers
*born on finite days*, i.e. those with finite birthday, are *exactly* the dyadic
rationals `ℤ[1/2]`.

This file develops the arithmetic backbone of that picture inside Mathlib's surreal
API.  The centrepiece is a proof that the additive-monoid morphism

    `Surreal.dyadicMap : ℤ[1/2] →+ Surreal`

is **injective** — i.e. the dyadic rationals embed as a genuine copy inside the
surreals.  This resolves a `TODO` left open in
`Mathlib/SetTheory/Surreal/Dyadic.lean` ("show that the map from dyadic rationals to
surreals is injective").  From injectivity we derive that the dyadic surreals form an
additive subgroup isomorphic (as an additive group) to `ℤ[1/2]`.

Alongside we prove the exact birthday of the surreal powers of one half,

    `(powHalf n).birthday = n + 1`,

and deduce that every power of one half is born strictly before day `ω`, giving a
concrete family of "finite birthday" surreals realising the dyadic values `2^{-n}`.

All results are stated over Mathlib's `Surreal` / `PGame` and are self contained.
-/
import Mathlib.SetTheory.Surreal.Dyadic
import Mathlib.Algebra.Group.Subgroup.Ker
import Mathlib.Algebra.Ring.Subring.Basic
import Mathlib.Algebra.Ring.Equiv

open SetTheory PGame

namespace SurrealDyadic

/-! ## Birthdays of the powers of one half -/

/-
The birthday of the surreal power of one half `powHalf n` is exactly `n + 1`.

`powHalf 0 = 1` has birthday `1`, and each `powHalf (n+1) = {0 | powHalf n}` adds one
more day to the previous birthday.  This generalises the Mathlib lemma
`SetTheory.PGame.birthday_half` (the case `n = 1`).
-/
theorem birthday_powHalf (n : ℕ) : (powHalf n).birthday = n + 1 := by
  induction n <;> simp_all +decide [ powHalf ];
  convert PGame.birthday_def _ using 1;
  simp +decide [ *, PGame.moveLeft, PGame.moveRight ];
  exact Order.one_le_iff_pos.mpr ( Ordinal.succ_pos _ )

/-- Every power of one half is born strictly before day `ω`: it is a "finite birthday"
surreal, hence a member of `No_ω`. -/
theorem birthday_powHalf_lt_omega0 (n : ℕ) : (powHalf n).birthday < Ordinal.omega0 := by
  rw [birthday_powHalf]
  exact_mod_cast Ordinal.nat_lt_omega0 (n + 1)

/-! ## Positivity of the surreal powers of one half -/

/-- Each surreal power of one half is strictly positive. -/
theorem powHalf_pos (n : ℕ) : (0 : Surreal) < Surreal.powHalf n := by
  rw [Surreal.powHalf]
  exact_mod_cast PGame.powHalf_pos n

/-- Each surreal power of one half is nonzero. -/
theorem powHalf_ne_zero (n : ℕ) : Surreal.powHalf n ≠ 0 :=
  (powHalf_pos n).ne'

/-- The surreal powers of one half are strictly decreasing: `powHalf (n+1) < powHalf n`. -/
theorem powHalf_succ_lt (n : ℕ) : Surreal.powHalf (n + 1) < Surreal.powHalf n := by
  rw [Surreal.powHalf, Surreal.powHalf]
  exact_mod_cast PGame.powHalf_succ_lt_powHalf n

/-- The sequence of surreal powers of one half is strictly antitone. -/
theorem powHalf_strictAnti : StrictAnti Surreal.powHalf :=
  strictAnti_nat_of_succ_lt powHalf_succ_lt

/-- The surreal powers of one half are pairwise distinct: `n ↦ powHalf n` is injective.
Combined with `birthday_powHalf`, this realises infinitely many distinct dyadic values
`2^{-n}`, each with its own finite birthday `n + 1`. -/
theorem powHalf_injective : Function.Injective Surreal.powHalf :=
  powHalf_strictAnti.injective

/-- `2^n` scales `powHalf n` back to `1`, exhibiting `powHalf n` as the surreal value
`2^{-n}`. -/
theorem two_pow_mul_powHalf (n : ℕ) : (2 : Surreal) ^ n * Surreal.powHalf n = 1 :=
  Surreal.nsmul_pow_two_powHalf n

/-! ## The dyadic embedding is injective

`Surreal.dyadicMap : Localization.Away (2 : ℤ) →+ Surreal` sends the dyadic rational
`m / 2^n` to `m • powHalf n`.  We show it is injective; combined with the fact that
`Localization.Away 2 ≃ ℤ[1/2]`, this says the dyadic rationals embed as a copy inside
the surreals.  (This is the `TODO` from `Mathlib/SetTheory/Surreal/Dyadic.lean`.) -/

/-- **The dyadic rationals embed injectively into the surreal numbers.**

Since `dyadicMap` is an additive-group morphism, injectivity reduces to a trivial
kernel: if `dyadicMap (m / 2^n) = m • powHalf n = 0`, then, as `powHalf n > 0` and the
surreals form an integral domain, `m = 0`, so the input is `0`. -/
theorem dyadicMap_injective : Function.Injective Surreal.dyadicMap := by
  rw [injective_iff_map_eq_zero]
  intro x hx
  induction x using Localization.induction_on with
  | H y =>
    obtain ⟨m, s⟩ := y
    have hval : Surreal.dyadicMap (Localization.mk m s)
        = (m : Surreal) * Surreal.powHalf (Submonoid.log s) := rfl
    rw [hval] at hx
    have hpos : (0 : Surreal) < Surreal.powHalf (Submonoid.log s) :=
      powHalf_pos _
    have hm : (m : Surreal) = 0 := by
      rcases mul_eq_zero.mp hx with h | h
      · exact h
      · exact absurd h (ne_of_gt hpos)
    have hm0 : m = 0 := by exact_mod_cast hm
    rw [hm0, Localization.mk_zero]

/-- The dyadic surreals `Surreal.dyadic` (the range of `dyadicMap`), as an additive
subgroup of the surreals. -/
noncomputable def dyadicSubgroup : AddSubgroup Surreal := Surreal.dyadicMap.range

theorem mem_dyadicSubgroup {x : Surreal} :
    x ∈ dyadicSubgroup ↔ ∃ q, Surreal.dyadicMap q = x := AddMonoidHom.mem_range

/-- The dyadic surreals, as a set, coincide with `Surreal.dyadic`. -/
theorem dyadicSubgroup_coe : (dyadicSubgroup : Set Surreal) = Surreal.dyadic := by
  ext x
  simp only [dyadicSubgroup, SetLike.mem_coe, AddMonoidHom.mem_range, Surreal.dyadic,
    Set.mem_range]

/-- Every power of one half is a dyadic surreal. -/
theorem powHalf_mem_dyadic (n : ℕ) : Surreal.powHalf n ∈ dyadicSubgroup := by
  rw [mem_dyadicSubgroup]
  refine ⟨IsLocalization.mk' (Localization (Submonoid.powers 2)) (1 : ℤ) (Submonoid.pow 2 n), ?_⟩
  rw [Surreal.dyadicMap_apply_pow, one_smul]

/-- **The dyadic rationals are group-isomorphic to their surreal image.**

Packaging injectivity: `dyadicMap` gives an additive-group isomorphism from
`ℤ[1/2] = Localization.Away 2` onto the additive subgroup of dyadic surreals. -/
noncomputable def dyadicEquiv : Localization.Away (2 : ℤ) ≃+ dyadicSubgroup :=
  AddMonoidHom.ofInjective dyadicMap_injective

/-! ## Multiplicativity: the dyadic embedding is a ring homomorphism

We now upgrade the additive embedding to a *ring* embedding, resolving the Mathlib
`TODO` "show the maps from the dyadic rationals and from the reals into the surreals are
multiplicative".  The arithmetic heart is `powHalf_mul_powHalf`. -/

/-
**The surreal powers of one half multiply by adding exponents:**
`2^{-m} · 2^{-n} = 2^{-(m+n)}`.

Proof: multiply both sides by the nonzero scalar `2^{m+n}` and use
`two_pow_mul_powHalf` (`2^k · 2^{-k} = 1`); since `Surreal` is a field we may cancel.
-/
theorem powHalf_mul_powHalf (m n : ℕ) :
    Surreal.powHalf m * Surreal.powHalf n = Surreal.powHalf (m + n) := by
  apply_fun ( fun x => ( 2 : Surreal ) ^ ( m + n ) * x );
  · simp +decide;
    convert congr_arg₂ ( · * · ) ( two_pow_mul_powHalf m ) ( two_pow_mul_powHalf n ) using 1 <;> ring;
  · exact mul_right_injective₀ ( pow_ne_zero _ two_ne_zero )

/-
`dyadicMap` sends the localization unit `1` to the surreal `1`.
-/
theorem dyadicMap_one : Surreal.dyadicMap 1 = 1 := by
  convert powHalf_mul_powHalf 0 0 using 1;
  convert Surreal.dyadicMap_apply 1;
  convert Iff.rfl;
  constructor <;> intro h;
  convert h ⟨ 1, 0, rfl ⟩;
  · exact Eq.symm ( IsLocalization.mk'_self _ _ );
  · norm_num;
  · aesop

/-
**`dyadicMap` is multiplicative.**  Together with `dyadicMap_one` and the additive
structure this exhibits `dyadicMap` as a ring homomorphism.
-/
theorem dyadicMap_mul (x y : Localization.Away (2 : ℤ)) :
    Surreal.dyadicMap (x * y) = Surreal.dyadicMap x * Surreal.dyadicMap y := by
  -- By definition of `dyadicMap`, we can write
  unfold Surreal.dyadicMap;
  induction x using Localization.induction_on ; induction y using Localization.induction_on ; simp_all +decide [ Localization.mk_mul ];
  erw [ Localization.liftOn_mk, Localization.liftOn_mk, Localization.liftOn_mk ];
  rw [ Submonoid.log_mul ];
  · simp +decide [ mul_assoc, mul_left_comm, powHalf_mul_powHalf ];
  · exact fun m n h => by simpa using h;

/-- **The dyadic rationals embed into the surreals as a ring homomorphism.** -/
noncomputable def dyadicRingHom : Localization.Away (2 : ℤ) →+* Surreal where
  toFun := Surreal.dyadicMap
  map_one' := dyadicMap_one
  map_mul' := dyadicMap_mul
  map_zero' := Surreal.dyadicMap.map_zero
  map_add' := Surreal.dyadicMap.map_add

/-- The ring homomorphism `dyadicRingHom` is injective: `ℤ[1/2]` embeds as a subring of
the surreals. -/
theorem dyadicRingHom_injective : Function.Injective dyadicRingHom :=
  dyadicMap_injective

/-- The dyadic surreals as a *subring* of the surreals (the range of `dyadicRingHom`). -/
noncomputable def dyadicSubring : Subring Surreal := dyadicRingHom.range

/-- **The dyadic rationals are ring-isomorphic to their surreal image.**
`ℤ[1/2] ≃+* dyadicSubring`. -/
noncomputable def dyadicRingEquiv : Localization.Away (2 : ℤ) ≃+* dyadicSubring :=
  RingEquiv.ofBijective dyadicRingHom.rangeRestrict
    ⟨fun _ _ h => dyadicRingHom_injective (Subtype.ext_iff.mp h),
      dyadicRingHom.rangeRestrict_surjective⟩

end SurrealDyadic