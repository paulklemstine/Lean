import Mathlib.SetTheory.Surreal.Dyadic

/-!
# Dyadic rationals embed in the surreal numbers

This file closes the injectivity gap left in the dyadic-surreal construction. It proves that
`Surreal.dyadicMap`, from the localization `ℤ[1/2]` to surreal numbers, is injective. Consequently
its range is additively equivalent to the dyadic rationals, and equality of two standard dyadic
fractions is characterized by cross multiplication.
-/

open SetTheory

namespace SetTheory.PGame

/-
The canonical game tree for `2⁻ⁿ` has birthday exactly `n + 1`. Thus every canonical dyadic
unit is born before day omega, while their birthdays are unbounded among the finite ordinals.
-/
@[simp] theorem birthday_powHalf (n : ℕ) : birthday (powHalf n) = n + 1 := by
  induction n <;> simp_all +decide [ powHalf ];
  simp +decide [ *, PGame.birthday ];
  exact Order.one_le_iff_pos.mpr ( Ordinal.succ_pos _ )

end SetTheory.PGame

namespace Surreal

/-
Every explicitly constructed inverse power of two is strictly positive as a surreal number.
-/
theorem powHalf_pos (n : ℕ) : 0 < powHalf n := by
  convert SetTheory.PGame.powHalf_pos n using 1

/-
An integer multiple of an inverse power of two vanishes only when the integer vanishes.
-/
theorem zsmul_powHalf_eq_zero_iff (m : ℤ) (n : ℕ) :
    m • powHalf n = 0 ↔ m = 0 := by
  simp +zetaDelta at *
  exact fun h => absurd h (powHalf_pos n |> ne_of_gt)

/-
The canonical inverse powers of two form a strictly decreasing sequence.
-/
theorem powHalf_strictAnti : StrictAnti powHalf := by
  refine' strictAnti_nat_of_succ_lt _;
  convert PGame.powHalf_succ_lt_powHalf using 1

/-
Two canonical inverse powers of two are equal precisely when their exponents agree.
-/
@[simp] theorem powHalf_injective_eq (m n : ℕ) : powHalf m = powHalf n ↔ m = n := by
  exact ⟨ fun h => StrictAnti.injective powHalf_strictAnti h, fun h => h ▸ rfl ⟩

/-
The canonical additive map from dyadic rationals `ℤ[1/2]` into the surreals is injective.
-/
theorem dyadicMap_injective : Function.Injective dyadicMap := by
  intro x y hxy;
  by_contra hxy';
  obtain ⟨m, n, hm⟩ : ∃ m n : ℤ, ∃ k : ℕ, x = IsLocalization.mk' (Localization.Away 2) m (Submonoid.pow 2 k) ∧ y = IsLocalization.mk' (Localization.Away 2) n (Submonoid.pow 2 k) := by
    obtain ⟨ m, s, hm ⟩ := IsLocalization.mk'_surjective ( Submonoid.powers ( 2 : ℤ ) ) x
    obtain ⟨ n, t, hn ⟩ := IsLocalization.mk'_surjective ( Submonoid.powers ( 2 : ℤ ) ) y;
    obtain ⟨ k₁, hk₁ ⟩ := m.2.2
    obtain ⟨ k₂, hk₂ ⟩ := n.2.2
    use m.1 * 2 ^ k₂, n.1 * 2 ^ k₁, k₁ + k₂;
    constructor <;> rw [ IsLocalization.eq ];
    · simp +decide [← hk₁, pow_add, mul_comm, mul_left_comm];
    · simp_all +decide [pow_add, mul_comm, mul_left_comm];
  obtain ⟨ k, rfl, rfl ⟩ := hm; simp_all +decide;
  exact absurd ( hxy.resolve_left ( by aesop ) ) ( ne_of_gt ( powHalf_pos k ) )

/-- The dyadic rationals are equivalent to the dyadic surreal numbers. The equivalence is
canonical: it is induced by `dyadicMap`. -/
noncomputable def dyadicEquiv : Localization.Away (2 : ℤ) ≃ dyadic :=
  Equiv.ofInjective dyadicMap dyadicMap_injective

@[simp]
theorem dyadicEquiv_apply (x : Localization.Away (2 : ℤ)) :
    (dyadicEquiv x : Surreal) = dyadicMap x := by
  rfl

/-
Equality of dyadic surreal values is exactly equality of the corresponding cross products.
-/
theorem zsmul_powHalf_eq_iff_cross_mul (m₁ m₂ : ℤ) (n₁ n₂ : ℕ) :
    m₁ • powHalf n₁ = m₂ • powHalf n₂ ↔
      m₁ * (2 : ℤ) ^ n₂ = m₂ * (2 : ℤ) ^ n₁ := by
  convert dyadicMap_injective.eq_iff using 1;
  rotate_left;
  rotate_left;
  exact Localization.mk m₁ ( Submonoid.pow 2 n₁ );
  exact Localization.mk m₂ ( Submonoid.pow 2 n₂ );
  simp +decide [ dyadicMap ];
  congr! 1;
  · erw [ Localization.liftOn_mk ] ; aesop;
  · erw [ Localization.liftOn_mk ] ; aesop;
  · rw [ Localization.mk_eq_mk_iff ];
    simp +decide [ Localization.r_iff_exists, Submonoid.pow ];
    exact ⟨ fun h => ⟨ 2 ^ n₂, ⟨ n₂, rfl ⟩, Or.inl <| by linarith ⟩, fun ⟨ a, ha, ha' ⟩ => by cases ha' <;> simp_all +decide [ mul_comm, Submonoid.mem_powers_iff ] ⟩

/-
The canonical surreal representatives `m / 2^n` are unique up to the usual
cross-multiplication relation.
-/
theorem dyadicMap_mk'_eq_iff (m₁ m₂ : ℤ) (n₁ n₂ : ℕ) :
    dyadicMap (IsLocalization.mk' (Localization.Away (2 : ℤ)) m₁ (Submonoid.pow 2 n₁)) =
      dyadicMap (IsLocalization.mk' (Localization.Away (2 : ℤ)) m₂ (Submonoid.pow 2 n₂)) ↔
        m₁ * (2 : ℤ) ^ n₂ = m₂ * (2 : ℤ) ^ n₁ := by
  convert zsmul_powHalf_eq_iff_cross_mul m₁ m₂ n₁ n₂ using 1;
  simp +decide only [dyadicMap_apply_pow];
  convert Iff.rfl

end Surreal

namespace DyadicLocalization

/-
The localization `ℤ[1/2]` is not a field: three has no multiplicative inverse. This pinpoints a
basic obstruction in calling the finite-birthday surreals a *subfield*: the finite-birthday
surreals are dyadic, but division by `3` leaves that class.
-/
theorem three_has_no_inverse :
    ¬ ∃ x : Localization.Away (2 : ℤ), (3 : Localization.Away (2 : ℤ)) * x = 1 := by
  by_contra h_contra;
  obtain ⟨ x, hx ⟩ := h_contra
  have h_eq : 3 * (3 * x) = 3 := by
    rw [ hx, mul_one ];
  obtain ⟨ y, hy ⟩ := IsLocalization.mk'_surjective ( Submonoid.powers 2 : Submonoid ℤ ) x;
  simp_all +decide [mul_comm];
  have h_eq : y.1 * 3 = y.2.val := by
    have h_eq : IsLocalization.mk' (Localization.Away (2 : ℤ)) (y.1 * 3) y.2 = 1 := by
      convert hx using 1;
      rw [ ← hy, mul_comm ];
      rw [ mul_comm, IsLocalization.mk'_eq_iff_eq_mul ];
      rw [ mul_right_comm, IsLocalization.mk'_spec ];
      norm_num [ Algebra.smul_def ];
    rw [ IsLocalization.mk'_eq_iff_eq_mul ] at h_eq;
    erw [ one_mul ] at h_eq;
    erw [ IsLocalization.eq_iff_exists ( Submonoid.powers ( 2 : ℤ ) ) ] at h_eq;
    exact mul_left_cancel₀ ( show ( h_eq.choose : ℤ ) ≠ 0 from by obtain ⟨ k, hk ⟩ := h_eq.choose.2; aesop ) h_eq.choose_spec;
  rcases y with ⟨ y₁, y₂ ⟩;
  obtain ⟨ k, hk ⟩ := y₂.2;
  replace hk := congr_arg ( · % 3 ) hk ; norm_num [ ← h_eq, Int.mul_emod ] at hk;
  norm_cast at hk ; rcases Nat.even_or_odd' k with ⟨ k, rfl | rfl ⟩ <;> norm_num [ Nat.pow_add, Nat.pow_mul, Nat.mul_mod, Nat.pow_mod ] at hk;
  · bv_omega;
  · replace h_eq := congr_arg ( · % 3 ) h_eq ; norm_num [ Int.mul_emod, hk.symm ] at h_eq

end DyadicLocalization