import Mathlib

/-! # CatalogBuild.Speculative.Wieferich

Unified from WieferichExtended and WieferichTheory.
Wieferich primes, Fermat quotients, and FLT connection.
-/}

/-- A prime p is Wieferich iff 2^(p-1) % p² = 1. -/
def IsWieferich (p : ℕ) : Prop :=
  Nat.Prime p ∧ p ≥ 3 ∧ 2 ^ (p - 1) % (p ^ 2) = 1

/-- Characterization via the modular condition. -/
theorem wieferich_iff_mod (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 ≤ p) :
    IsWieferich p ↔ 2 ^ (p - 1) % (p ^ 2) = 1 := by
  constructor
  · rintro ⟨_, _, h⟩; exact h
  · intro h; exact ⟨hp, hp3, h⟩

/-- The two known Wieferich primes. -/
theorem wieferich_1093_verified : IsWieferich 1093 := by
  refine ⟨by native_decide, by omega, ?_⟩
  native_decide

theorem wieferich_3511_verified : IsWieferich 3511 := by
  refine ⟨by native_decide, by omega, ?_⟩
  native_decide

-- ---------------------------------------------------------------------------
-- Non-Wieferich primes (verified computationally)
-- ---------------------------------------------------------------------------

theorem non_wieferich_3  : ¬ IsWieferich 3  := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_5  : ¬ IsWieferich 5  := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_7  : ¬ IsWieferich 7  := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_11 : ¬ IsWieferich 11 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_13 : ¬ IsWieferich 13 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_17 : ¬ IsWieferich 17 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_19 : ¬ IsWieferich 19 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_23 : ¬ IsWieferich 23 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_29 : ¬ IsWieferich 29 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_31 : ¬ IsWieferich 31 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_37 : ¬ IsWieferich 37 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_41 : ¬ IsWieferich 41 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_43 : ¬ IsWieferich 43 := by intro ⟨_, _, h⟩; revert h; native_decide
theorem non_wieferich_47 : ¬ IsWieferich 47 := by intro ⟨_, _, h⟩; revert h; native_decide
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

-- ---------------------------------------------------------------------------
-- Fermat quotient characterization
-- ---------------------------------------------------------------------------

/-- The Fermat quotient q_p(a) = (a^(p-1) - 1) / p. -/
def fermatQuotient (a p : ℕ) : ℤ :=
  ((a : ℤ) ^ (p - 1) - 1) / p

/-- Wieferich primes are exactly those whose Fermat quotient is divisible by p. -/
theorem wieferich_iff_p_dvd_quotient (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 ≤ p) :
    IsWieferich p ↔ (p : ℤ) ∣ fermatQuotient 2 p := by
  constructor <;> intro h
  · obtain ⟨k, hk⟩ := h
    exact Int.dvd_div_of_mul_dvd
      (by simpa [← Int.natCast_dvd_natCast] using ⟨2 ^ (p - 1) / p ^ 2,
        by linarith [Nat.mod_add_div (2 ^ (p - 1)) (p ^ 2)]⟩)
  · refine' ⟨hp, hp3, _⟩
    have h_div : (p : ℤ) ^ 2 ∣ (2 ^ (p - 1) - 1) := by
      have h_div : (p : ℤ) ∣ ((2 ^ (p - 1) - 1) / p : ℤ) := by convert h using 1
      convert mul_dvd_mul_left (p : ℤ) h_div using 1
      · ring
      · rw [Int.mul_ediv_cancel']
        · have := Nat.totient_prime hp
          erw [← this]
          simpa [← Int.natCast_dvd_natCast] using Nat.ModEq.dvd
            (Nat.ModEq.pow_totient (Nat.coprime_comm.mp
              <| hp.coprime_iff_not_dvd.mpr
              <| Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two <| by linarith)
            |> Nat.ModEq.symm)
    zify
    obtain ⟨k, hk⟩ := h_div
    norm_num [sub_eq_iff_eq_add'.mp hk]
    rw [Int.emod_eq_of_lt] <;> nlinarith

/-- Historical Wieferich–FLT connection (Wieferich 1909). -/
def WieferichFLTConnection : Prop :=
  ∀ p : ℕ, Nat.Prime p → p ≥ 3 →
    (∃ x y z : ℤ, x ^ p + y ^ p = z ^ p ∧ ¬ (p : ℤ) ∣ x * y * z) →
    IsWieferich p
