import Mathlib

/-!
# Explicit 2-adic valuation of the shifted Perrin sequence `Rₘ − 1`

The Perrin numbers `R` satisfy `R₀ = 3, R₁ = 0, R₂ = 2` and `Rₙ₊₃ = Rₙ₊₁ + Rₙ`
(OEIS A001608). We give an explicit description of the 2-adic valuation
`ν₂(Rₘ − 1) = padicValInt 2 (Rₘ − 1)`, driven by the fact that `R mod 2ᵏ`
is periodic with period `7·2ᵏ⁻¹`.

Main results:
* `perrin_val_zero_iff` — parity classification (period 7):
  `ν₂(Rₘ − 1) = 0 ⇔ m mod 7 ∈ {1,2,4}`.
* `perrin_val_mod28` — explicit closed-form valuation (period 28) for the 25 of 28
  residue classes that are *not* exceptional; the value is `perrinNu (m % 28) ∈ {0,1,2}`.
* `perrin_refine_mod56` — the self-similar refinement (period 56): the exceptional
  residues `m mod 28 ∈ {10,19,26}` all satisfy `8 ∣ Rₘ − 1`, and each splits at the
  next level into an exact `ν₂ = 3` class and a persisting `ν₂ ≥ 4` class.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): ν₂(Rₘ−1) is governed by a finite set of congruences
  mod powers of 2 and mod 7, analogous to the Padovan "TV1" theorem.
Experiment (Experimenter): computed Rₘ mod 2ᵏ; period is 7·2ᵏ⁻¹; tabulated ν₂ by
  residue mod 7, 28, 56 (see ComputationalEvidence.md).
Analysis (Analyst): exactly 3 residues mod 28 (namely 10,19,26) resist a mod-28
  closed form; these are precisely `Rₘ ≡ 1 (mod 8)` and carry the unbounded/fractal
  part of the valuation. The remaining 25 classes give ν₂ ∈ {0,1,2} explicitly.
Critique (Critic): all main theorems produce genuine numeric valuations (not True),
  use periodicity + case analysis, and depend on nontrivial recurrence lemmas.
Synthesis (PI): the valuation is (i) 0/1/2 explicitly on 25 residues mod 28,
  (ii) ≥3 on 3 residues, refining self-similarly (period doubling) at each 2-power.
-/

namespace PerrinShiftedValuation

instance : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩

/-- The Perrin sequence: `R₀=3, R₁=0, R₂=2`, `Rₙ₊₃ = Rₙ₊₁ + Rₙ`. -/
def R : ℕ → ℤ
  | 0 => 3
  | 1 => 0
  | 2 => 2
  | (n + 3) => R (n + 1) + R n

@[simp] lemma R_rec (n : ℕ) : R (n + 3) = R (n + 1) + R n := rfl

/-! ## `padicValInt` helper -/

/-
If `2ᵏ ∣ x` but `2ᵏ⁺¹ ∤ x` then the 2-adic valuation of `x` is exactly `k`.
-/
lemma pv_eq {x : ℤ} {k : ℕ} (h1 : (2 : ℤ) ^ k ∣ x) (h2 : ¬ (2 : ℤ) ^ (k + 1) ∣ x) :
    padicValInt 2 x = k := by
  obtain ⟨ c, rfl ⟩ := h1;
  rw [ padicValInt.mul ] <;> simp_all +decide [ pow_add ];
  · norm_num [ padicValInt ];
    exact Or.inr ( Nat.mod_two_ne_zero.mp fun h => h2 <| mul_dvd_mul_left _ <| Int.natCast_dvd.mpr <| Nat.dvd_of_mod_eq_zero h );
  · aesop

/-
Valuation `0`: from `x` odd (equivalently `x` even ⇒ `x-1` odd).
-/
lemma pv_zero_of_even {x : ℤ} (h : (2 : ℤ) ∣ x) : padicValInt 2 (x - 1) = 0 := by
  exact padicValInt.eq_zero_of_not_dvd ( by obtain ⟨ k, rfl ⟩ := h; omega )

/-
Valuation `1`: from `x ≡ 3 (mod 4)`.
-/
lemma pv_one_of_mod4 {x : ℤ} (h : x ≡ 3 [ZMOD 4]) : padicValInt 2 (x - 1) = 1 := by
  convert pv_eq _ _ using 1;
  · exact Int.dvd_of_emod_eq_zero ( by rw [ Int.ModEq ] at h; omega );
  · rw [ Int.dvd_iff_emod_eq_zero ] ; rw [ Int.ModEq ] at h; omega;

/-
Valuation `2`: from `x ≡ 5 (mod 8)`.
-/
lemma pv_two_of_mod8 {x : ℤ} (h : x ≡ 5 [ZMOD 8]) : padicValInt 2 (x - 1) = 2 := by
  obtain ⟨ k, hk ⟩ := h.symm.dvd;
  rw [ show x - 1 = 4 * ( 2 * k + 1 ) by linarith ] ; rw [ padicValInt.mul ] <;> norm_num;
  · rw [ show ( 4 : ℤ ) = 2 ^ 2 by norm_num, padicValInt ] ; norm_num;
    rw [ show ( 4 : ℕ ) = 2 ^ 2 by norm_num, padicValNat.pow ] <;> norm_num;
  · omega

/-! ## Periodicity of `R mod 2ᵏ` -/

/-
Period 7 modulo 2.
-/
lemma R_period2 : ∀ n, R (n + 7) ≡ R n [ZMOD 2] := by
  grind +suggestions

/-
Period 28 modulo 8.
-/
lemma R_period8 : ∀ n, R (n + 28) ≡ R n [ZMOD 8] := by
  intro n;
  exact Int.emod_eq_emod_iff_emod_sub_eq_zero.mpr ( by induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | _ | n ) <;> simp_all +decide ; omega )

/-
Period 56 modulo 16.
-/
lemma R_period16 : ∀ n, R (n + 56) ≡ R n [ZMOD 16] := by
  -- We use induction on $n$ to prove the periodicity.
  suffices h_ind : ∀ n, (R (n + 56)) % 16 = (R n) % 16 ∧ (R (n + 57)) % 16 = (R (n + 1)) % 16 ∧ (R (n + 58)) % 16 = (R (n + 2)) % 16 by
    exact fun n => h_ind n |>.1;
  intro n
  induction' n with n ih;
  · decide +kernel;
  · grind +suggestions

/-
Reduction: `Rₘ ≡ R (m mod 7) (mod 2)`.
-/
lemma R_reduce2 (m : ℕ) : R m ≡ R (m % 7) [ZMOD 2] := by
  induction' m using Nat.strongRecOn with m ih;
  rcases m with ( _ | _ | _ | _ | _ | _ | _ | m ) <;> simp_all +arith +decide

/-
Reduction: `Rₘ ≡ R (m mod 28) (mod 8)`.
-/
lemma R_reduce8 (m : ℕ) : R m ≡ R (m % 28) [ZMOD 8] := by
  induction' m using Nat.strongRecOn with m ih;
  by_cases hm : m < 28;
  · interval_cases m <;> trivial;
  · convert Int.ModEq.trans ( R_period8 ( m - 28 ) ) ( ih ( m - 28 ) ( Nat.sub_lt ( by linarith ) ( by linarith ) ) ) using 1;
    · rw [ Nat.sub_add_cancel ( le_of_not_gt hm ) ];
    · rw [ show m % 28 = ( m - 28 ) % 28 by omega ]

/-
Reduction: `Rₘ ≡ R (m mod 56) (mod 16)`.
-/
lemma R_reduce16 (m : ℕ) : R m ≡ R (m % 56) [ZMOD 16] := by
  induction' m using Nat.strongRecOn with m ih;
  by_cases hm : m < 56;
  · interval_cases m <;> trivial;
  · convert Int.ModEq.trans ( R_period16 ( m - 56 ) ) ( ih ( m - 56 ) ( Nat.sub_lt ( by linarith ) ( by linarith ) ) ) using 1;
    · rw [ Nat.sub_add_cancel ( le_of_not_gt hm ) ];
    · rw [ show m % 56 = ( m - 56 ) % 56 by omega ]

/-! ## Main theorem 1 — parity classification (period 7) -/

/-
`ν₂(Rₘ − 1) = 0` exactly on the residues `m mod 7 ∈ {1,2,4}` (where `Rₘ` is even).
-/
theorem perrin_val_zero_iff (m : ℕ) :
    ¬ (2 : ℤ) ∣ (R m - 1) ↔ (m % 7 = 1 ∨ m % 7 = 2 ∨ m % 7 = 4) := by
  convert R_reduce2 m using 1 ; norm_num [ Int.modEq_iff_dvd, ← even_iff_two_dvd, parity_simps ];
  have := Nat.mod_lt m ( by decide : 7 > 0 ) ; interval_cases m % 7 <;> simp +decide [ * ] ;

/-! ## Main theorem 2 — explicit valuation on the 25 regular residues (period 28) -/

/-- The explicit constant valuation attached to a residue mod 28 (0 on the three
exceptional residues 10,19,26, which are excluded from `perrin_val_mod28`). -/
def perrinNu (m : ℕ) : ℕ :=
  match m % 28 with
  | 0 => 1 | 3 => 1 | 7 => 1 | 13 => 1 | 14 => 1 | 17 => 1 | 21 => 1 | 27 => 1
  | 5 => 2 | 6 => 2 | 12 => 2 | 20 => 2 | 24 => 2
  | _ => 0

/-
Explicit closed form for the 2-adic valuation of `Rₘ − 1` on the 25 residue
classes mod 28 outside the exceptional set `{10,19,26}`: it equals `perrinNu m ∈ {0,1,2}`.
-/
theorem perrin_val_mod28 (m : ℕ)
    (h : m % 28 ≠ 10 ∧ m % 28 ≠ 19 ∧ m % 28 ≠ 26) :
    padicValInt 2 (R m - 1) = perrinNu m := by
  convert pv_eq _ _ using 1;
  · -- By definition of `perrinNu`, we know that `2 ^ perrinNu m` divides `R m - 1`.
    have h_div : (2 ^ perrinNu m : ℤ) ∣ (R (m % 28) - 1) := by
      have := Nat.mod_lt m ( by decide : 0 < 28 ) ; interval_cases _ : m % 28 <;> simp_all +decide only [perrinNu] ;
    have h_cong : R m ≡ R (m % 28) [ZMOD 8] := R_reduce8 m
    convert dvd_add h_div ( dvd_trans ( pow_dvd_pow _ ( show perrinNu m ≤ 3 by
                                                          unfold perrinNu; have := Nat.mod_lt m ( by decide : 0 < 28 ) ; interval_cases m % 28 <;> trivial; ) ) ( h_cong.symm.dvd ) ) using 1 ; ring;
  · rw [ ← Int.modEq_iff_dvd ];
    rw [ Int.ModEq ];
    rw [ show R m % 2 ^ ( perrinNu m + 1 ) = R ( m % 28 ) % 2 ^ ( perrinNu m + 1 ) from ?_ ];
    · unfold perrinNu; have := Nat.mod_lt m ( by decide : 0 < 28 ) ; interval_cases m % 28 <;> trivial;
    · have h_mod : R m ≡ R (m % 28) [ZMOD 2 ^ (perrinNu m + 1)] := by
        have h_mod_8 : R m ≡ R (m % 28) [ZMOD 8] := R_reduce8 m
        have h_mod_4 : perrinNu m + 1 ≤ 3 := by
          unfold perrinNu; have := Nat.mod_lt m ( by decide : 0 < 28 ) ; interval_cases m % 28 <;> trivial;
        exact h_mod_8.of_dvd <| pow_dvd_pow _ h_mod_4;
      exact h_mod

/-! ## Main theorem 3 — self-similar refinement (period 56) -/

/-
The three exceptional residues mod 28 all satisfy `8 ∣ Rₘ − 1`, i.e. `ν₂ ≥ 3`;
moreover at the next level exactly three residues mod 56 give `ν₂ = 3` and exactly
three persist with `16 ∣ Rₘ − 1` (`ν₂ ≥ 4`).
-/
theorem perrin_refine_mod56 (m : ℕ)
    (h : m % 28 = 10 ∨ m % 28 = 19 ∨ m % 28 = 26) :
    (8 : ℤ) ∣ (R m - 1) ∧
    ((m % 56 = 26 ∨ m % 56 = 38 ∨ m % 56 = 47) → padicValInt 2 (R m - 1) = 3) ∧
    ((m % 56 = 10 ∨ m % 56 = 19 ∨ m % 56 = 54) → (16 : ℤ) ∣ (R m - 1)) := by
  refine' ⟨ _, _, _ ⟩;
  · -- By definition of $R$, we know that $R m ≡ R (m % 28) [ZMOD 8]$.
    have h_mod8 : R m ≡ R (m % 28) [ZMOD 8] := R_reduce8 m
    exact Int.dvd_of_emod_eq_zero ( h_mod8.sub_right _ ▸ by rcases h with ( h | h | h ) <;> simp +decide [ h ] );
  · intro h';
    apply pv_eq;
    · -- By definition of $R$, we know that $R m ≡ R (m % 56) [ZMOD 8]$.
      have h_mod8 : R m ≡ R (m % 56) [ZMOD 8] := by
        convert R_reduce16 m |> Int.ModEq.of_dvd ( by decide : ( 8 : ℤ ) ∣ 16 ) using 1;
      rcases h' with ( h' | h' | h' ) <;> rw [ h' ] at h_mod8 <;> exact Int.dvd_of_emod_eq_zero ( h_mod8.sub_right _ );
    · -- By definition of $R$, we know that $R m \equiv R (m % 56) \pmod{16}$.
      have h_mod : R m ≡ R (m % 56) [ZMOD 16] := R_reduce16 m
      rcases h' with ( h' | h' | h' ) <;> rw [ Int.dvd_iff_emod_eq_zero ] <;> rw [ Int.ModEq ] at h_mod <;> norm_num [ h', Int.sub_emod, Int.mul_emod ] at h_mod ⊢;
      · simp +decide [ h_mod ];
      · simp +decide [ h_mod ];
      · simp_all +decide [ R ];
  · intro hm
    have h_mod : R m ≡ R (m % 56) [ZMOD 16] := by
      convert R_reduce16 m using 1;
    rcases hm with ( hm | hm | hm ) <;> rw [ Int.dvd_iff_emod_eq_zero ] <;> rw [ Int.ModEq ] at h_mod <;> simp_all +decide [ Int.sub_emod ]

end PerrinShiftedValuation