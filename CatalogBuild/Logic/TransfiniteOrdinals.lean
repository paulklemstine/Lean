/-! # CatalogBuild.Logic.TransfiniteOrdinals

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Logic.TransfiniteOrdinals
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16] -/
theorem one_add_omega : 1 + ω = ω := by
  rw [ Ordinal.one_add_omega0 ]



theorem omega_add_one_gt : ω < ω + 1 := by
  exact?



theorem ordinal_add_not_comm : (1 : Ordinal) + ω ≠ ω + 1 := by
  exact ne_of_lt ( by simp +decide [ Ordinal.one_lt_omega0 ] )



theorem two_mul_omega : 2 * ω = ω := by
  rw [ Ordinal.mul_omega0 ];
  · norm_num +zetaDelta at *;
  · exact Ordinal.nat_lt_omega0 2



theorem omega_mul_two_gt : ω < ω * 2 := by
  norm_num [ Ordinal.omega0_ne_zero ]



theorem ordinal_mul_not_comm : (2 : Ordinal) * ω ≠ ω * 2 := by
  exact ne_of_lt ( by rw [ two_mul_omega ] ; exact omega_mul_two_gt )



theorem epsilon_zero_fixed_point : omega0 ^ Ordinal.epsilon 0 = Ordinal.epsilon 0 := by
  exact?



theorem epsilon_is_fixed_point (i : Ordinal) :
    omega0 ^ Ordinal.epsilon i = Ordinal.epsilon i := by
      exact?



theorem epsilon_zero_is_limit : Order.IsSuccLimit (Ordinal.epsilon 0) := by
  refine' ⟨ _, fun x hx => _ ⟩;
  · simp [IsMin];
    refine' ⟨ 0, _, _ ⟩ <;> norm_num;
  · obtain ⟨ hx₁, hx₂ ⟩ := hx;
    grind +suggestions



theorem omega_lt_epsilon_zero : ω < Ordinal.epsilon 0 := by
  exact?



/-- The iterated omega-exponentiation tower. -/
noncomputable def omegaTower : ℕ → Ordinal
  | 0 => ω
  | n + 1 => omega0 ^ omegaTower n



theorem omegaTower_lt_epsilon_zero (n : ℕ) : omegaTower n < Ordinal.epsilon 0 := by
  induction' n with n ih;
  · exact Rucker.TransfiniteOrdinals.omega_lt_epsilon_zero;
  · refine' lt_of_lt_of_le ( Ordinal.opow_lt_opow_iff_right ( by norm_num ) |>.2 ih ) _;
    simp +zetaDelta at *



theorem omegaTower_strictMono : StrictMono omegaTower := by
  refine' strictMono_nat_of_lt_succ _;
  intro n;
  induction n <;> simp_all +decide [ omegaTower ];
  refine' lt_of_le_of_lt _ ( Ordinal.opow_lt_opow_iff_right ( by norm_num ) |>.2 _ );
  swap;
  exacts [ 1, by norm_num, by norm_num ]



theorem omega_pow_zero : omega0 ^ (0 : Ordinal) = 1 := by
  norm_num +zetaDelta at *



theorem omega_pow_one : omega0 ^ (1 : Ordinal) = ω := by
  norm_num +zetaDelta at *



theorem omega_sq_gt : ω < omega0 ^ (2 : Ordinal) := by
  convert Ordinal.opow_lt_opow_iff_right ( show 1 < ω from ?_ ) |>.2 ( show ( 2:Ordinal ) > 1 from ?_ ) using 1
  all_goals generalize_proofs at *;
  · rw [ Ordinal.opow_one ];
  · exact Ordinal.one_lt_omega0;
  · norm_num +zetaDelta at *



end
