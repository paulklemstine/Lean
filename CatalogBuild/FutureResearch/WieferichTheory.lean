/-! # CatalogBuild.FutureResearch.WieferichTheory

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 19
-/

import Mathlib

theorem wieferich_iff_mod (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 ≤ p) :
    IsWieferich p ↔ 2 ^ (p - 1) % (p ^ 2) = 1 := by
  constructor
  · rintro ⟨_, _, h⟩; exact h
  · intro h; exact ⟨hp, hp3, h⟩

/-! ### Known Wieferich Primes -/


theorem wieferich_1093_verified : IsWieferich 1093 := by
  refine ⟨by native_decide, by omega, ?_⟩
  native_decide


theorem wieferich_3511_verified : IsWieferich 3511 := by
  refine ⟨by native_decide, by omega, ?_⟩
  native_decide

/-! ### Non-Wieferich Primes -/


theorem non_wieferich_3 : ¬ IsWieferich 3 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_5 : ¬ IsWieferich 5 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_7 : ¬ IsWieferich 7 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_11 : ¬ IsWieferich 11 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_13 : ¬ IsWieferich 13 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_17 : ¬ IsWieferich 17 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_19 : ¬ IsWieferich 19 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_23 : ¬ IsWieferich 23 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_29 : ¬ IsWieferich 29 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_31 : ¬ IsWieferich 31 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_37 : ¬ IsWieferich 37 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_41 : ¬ IsWieferich 41 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_43 : ¬ IsWieferich 43 := by
  intro ⟨_, _, h⟩; revert h; native_decide


theorem non_wieferich_47 : ¬ IsWieferich 47 := by
  intro ⟨_, _, h⟩; revert h; native_decide

/-! ### Fermat Quotient -/

/-- The Fermat quotient q_p(a) = (a^(p-1) - 1) / p, defined over ℤ. -/

theorem wieferich_iff_p_dvd_quotient (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 ≤ p) :
    IsWieferich p ↔ (p : ℤ) ∣ fermatQuotient 2 p := by
  constructor <;> intro h;
  · obtain ⟨ k, hk ⟩ := h;
    exact Int.dvd_div_of_mul_dvd ( by simpa [ ← Int.natCast_dvd_natCast ] using ⟨ ( 2 ^ ( p - 1 ) / p ^ 2 ), by linarith [ Nat.mod_add_div ( 2 ^ ( p - 1 ) ) ( p ^ 2 ) ] ⟩ );
  · refine' ⟨ hp, hp3, _ ⟩;
    -- By definition of Fermat quotient, we have $p \mid (2^{p-1} - 1) / p$, which implies $p^2 \mid 2^{p-1} - 1$.
    have h_div : (p : ℤ) ^ 2 ∣ (2 ^ (p - 1) - 1) := by
      have h_div : (p : ℤ) ∣ ((2 ^ (p - 1) - 1) / p : ℤ) := by
        convert h using 1;
      convert mul_dvd_mul_left ( p : ℤ ) h_div using 1 ; ring;
      rw [ Int.mul_ediv_cancel' ];
      have := Nat.totient_prime hp; erw [ ← this ] ; simpa [ ← Int.natCast_dvd_natCast ] using Nat.ModEq.dvd ( Nat.ModEq.pow_totient ( Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr <| Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two <| by linarith ) |> Nat.ModEq.symm ) ;
    zify;
    obtain ⟨ k, hk ⟩ := h_div; norm_num [ sub_eq_iff_eq_add'.mp hk ] ;
    rw [ Int.emod_eq_of_lt ] <;> nlinarith

/-! ### Wieferich-FLT Connection -/

/-- Historical connection: If p is an odd prime not dividing xyz and
    x^p + y^p = z^p, then p must be Wieferich (Wieferich 1909).
    We state this as a formal proposition. -/

def WieferichFLTConnection : Prop :=
  ∀ p : ℕ, Nat.Prime p → p ≥ 3 →
    (∃ x y z : ℤ, x ^ p + y ^ p = z ^ p ∧ ¬ (p : ℤ) ∣ x * y * z) →
    IsWieferich p
