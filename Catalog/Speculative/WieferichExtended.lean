
import Mathlib

/-! # CatalogBuild.Speculative.WieferichExtended

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 34
-/

/-- [Section: # CatalogBuild.Speculative.WieferichExtended
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 34] -/
def IsWieferich (p : ℕ) : Prop :=
  Nat.Prime p ∧ p ≥ 3 ∧ 2 ^ (p - 1) % (p ^ 2) = 1

/-- [Section: # CatalogBuild.Speculative.WieferichExtended
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 34] -/
theorem non_wieferich_53 : ¬ IsWieferich 53 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_59 : ¬ IsWieferich 59 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_61 : ¬ IsWieferich 61 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_67 : ¬ IsWieferich 67 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_71 : ¬ IsWieferich 71 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_73 : ¬ IsWieferich 73 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_79 : ¬ IsWieferich 79 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_83 : ¬ IsWieferich 83 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_89 : ¬ IsWieferich 89 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_97 : ¬ IsWieferich 97 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_101 : ¬ IsWieferich 101 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_103 : ¬ IsWieferich 103 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_107 : ¬ IsWieferich 107 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_109 : ¬ IsWieferich 109 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_113 : ¬ IsWieferich 113 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_127 : ¬ IsWieferich 127 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_131 : ¬ IsWieferich 131 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_137 : ¬ IsWieferich 137 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_139 : ¬ IsWieferich 139 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_149 : ¬ IsWieferich 149 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_151 : ¬ IsWieferich 151 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_157 : ¬ IsWieferich 157 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_163 : ¬ IsWieferich 163 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_167 : ¬ IsWieferich 167 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_173 : ¬ IsWieferich 173 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_179 : ¬ IsWieferich 179 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_181 : ¬ IsWieferich 181 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_191 : ¬ IsWieferich 191 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_193 : ¬ IsWieferich 193 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_197 : ¬ IsWieferich 197 := by intro ⟨_, _, h⟩; revert h; native_decide

theorem non_wieferich_199 : ¬ IsWieferich 199 := by intro ⟨_, _, h⟩; revert h; native_decide

/-- The Fermat quotient q_p(a) = (a^(p-1) - 1) / p. -/
def fermatQuotient (a p : ℕ) : ℤ :=
  ((a : ℤ) ^ (p - 1) - 1) / p

theorem wieferich_iff_quotient (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 ≤ p) :
    IsWieferich p ↔ (p : ℤ) ∣ fermatQuotient 2 p := by
  constructor <;> intro h;
  · obtain ⟨ k, hk ⟩ := h;
    exact Int.dvd_div_of_mul_dvd ( by simpa [ ← Int.natCast_dvd_natCast ] using ⟨ ( 2 ^ ( p - 1 ) / p ^ 2 ), by linarith [ Nat.mod_add_div ( 2 ^ ( p - 1 ) ) ( p ^ 2 ) ] ⟩ );
  · refine' ⟨ hp, hp3, _ ⟩;
    rw [ Nat.ModEq.symm ];
    exact Nat.mod_eq_of_lt ( by nlinarith );
    unfold fermatQuotient at h;
    rw [ Nat.modEq_iff_dvd ];
    convert mul_dvd_mul_left ( p : ℤ ) h using 1 ; norm_num ; ring;
    rw [ Int.mul_ediv_cancel' ];
    · bv_omega;
    · have := Nat.totient_prime hp; erw [ ← this ] ; exact by simpa [ ← Int.natCast_dvd_natCast ] using Nat.ModEq.dvd <| Nat.ModEq.pow_totient ( Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr <| Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two <| by linarith ) |> Nat.ModEq.symm;



