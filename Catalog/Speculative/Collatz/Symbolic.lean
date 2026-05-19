import Mathlib
import Speculative.Collatz.Accelerated

/-!
# Valuation Pattern Realizability for Collatz Dynamics

This file proves structural results about the Collatz valuation coding map.

## Main results

1. **Single-step realizability**: For every `a ≥ 1`, there exists an odd positive `n`
   with `v₂(3n+1) = a`.

2. **Valuation-residue characterization**: The condition `v₂(3n+1) = a` for odd `n`
   is equivalent to a pair of divisibility conditions.

3. **Three is invertible mod 2^m**: Fundamental modular arithmetic fact.

4. **Orbit determination by residue class**: `(3n₁+1) mod 2^m = (3n₂+1) mod 2^m`
   whenever `n₁ ≡ n₂ mod 2^m`.

5. **Multi-step realizability**: Stated as a conjecture; the infrastructure for
   a backward congruence proof is laid out.

## Mathematical significance

These results establish the single-step Collatz valuation map as surjective:
every valuation `a ≥ 1` is achieved. The multi-step generalization
(finite-prefix surjectivity of the Collatz coding map) would complete the
identification of Collatz dynamics with a full symbolic shift.
-/

namespace Collatz

/-! ### Modular arithmetic infrastructure -/

/-- 3 is coprime to any power of 2. -/
theorem three_coprime_two_pow (m : ℕ) : Nat.Coprime 3 (2 ^ m) := by
  exact Nat.Coprime.pow_right _ (by decide)

/-
The condition `v₂(3n+1) = a` is equivalent to `2^a ∣ 3n+1` and `¬ 2^(a+1) ∣ 3n+1`.
-/
theorem v2_eq_iff_mod {n a : ℕ} (hn : 0 < n) (hodd : n % 2 = 1) (ha : 1 ≤ a) :
    v2Nat (3 * n + 1) = a ↔
    (2 ^ a ∣ 3 * n + 1 ∧ ¬ 2 ^ (a + 1) ∣ 3 * n + 1) := by
  constructor <;> intro h;
  · unfold v2Nat at h; simp_all +decide [ Nat.Prime.pow_dvd_iff_le_factorization ] ;
    rw [ ← h, Nat.factorization_def ];
    · rw [ padicValNat_def' ];
      · grind;
      · norm_num;
      · positivity;
    · norm_num;
  · unfold v2Nat;
    rw [ multiplicity_eq_of_dvd_of_not_dvd ] <;> tauto

/-! ### Single-step realizability -/

/-
**Single-step realizability**: For any `a ≥ 1`, there exists an odd positive `n`
    with `v₂(3n+1) = a`. This is the single-step version of valuation pattern
    realizability and already shows that every admissible valuation value occurs.
-/
theorem single_step_realizability (a : ℕ) (ha : 1 ≤ a) :
    ∃ n : ℕ, 0 < n ∧ n % 2 = 1 ∧ v2Nat (3 * n + 1) = a := by
  -- By the Chinese Remainder Theorem, there exists an odd positive integer `n` satisfying `3n + 1 ≡ 2^a [MOD 2^(a+1)]`.
  obtain ⟨n, hn_pos, hn_odd, hn_mod⟩ : ∃ n : ℕ, 0 < n ∧ n % 2 = 1 ∧ (3 * n + 1) % 2 ^ (a + 1) = 2 ^ a := by
    -- We can find such an `n` by solving the congruence `3n + 1 ≡ 2^a [MOD 2^(a+1)]`.
    have h_cong : ∃ n : ℕ, 3 * n + 1 ≡ 2 ^ a [MOD 2 ^ (a + 1)] ∧ n % 2 = 1 := by
      -- We can solve the congruence $3n + 1 ≡ 2^a [MOD 2^{a+1}]$ for $n$ using the fact that $3$ is invertible modulo $2^{a+1}$.
      obtain ⟨n, hn⟩ : ∃ n : ℕ, 3 * n ≡ 2 ^ a - 1 [MOD 2 ^ (a + 1)] := by
        -- Since $3$ is coprime with $2^{a+1}$, there exists an $n$ such that $3n \equiv 1 \pmod{2^{a+1}}$.
        have h_coprime : Nat.gcd 3 (2 ^ (a + 1)) = 1 := by
          exact Nat.Coprime.pow_right _ ( by decide );
        have := Nat.exists_mul_mod_eq_one_of_coprime h_coprime;
        exact Exists.elim ( this ( one_lt_pow₀ one_lt_two ( by linarith ) ) ) fun m hm => ⟨ m * ( 2 ^ a - 1 ), by rw [ ← mul_assoc, Nat.ModEq, Nat.mul_mod, hm.2 ] ; norm_num ⟩;
      refine' ⟨ n, _, _ ⟩;
      · convert hn.add_right 1 using 1 ; rw [ Nat.sub_add_cancel ( Nat.one_le_pow _ _ ( by decide ) ) ];
      · replace hn := congr_arg ( · % 2 ) hn ; rcases a with ( _ | _ | a ) <;> norm_num [ Nat.ModEq, Nat.pow_succ', Nat.mul_mod, Nat.add_mod ] at *;
        · assumption;
        · grind;
    obtain ⟨ n, hn₁, hn₂ ⟩ := h_cong;
    refine' ⟨ n, Nat.pos_of_ne_zero _, hn₂, hn₁.symm ▸ Nat.mod_eq_of_lt ( pow_lt_pow_right₀ ( by decide ) ( Nat.lt_succ_self _ ) ) ⟩ ; aesop;
  refine' ⟨ n, hn_pos, hn_odd, v2_eq_iff_mod hn_pos hn_odd ha |>.2 ⟨ _, _ ⟩ ⟩;
  · exact Nat.dvd_of_mod_eq_zero ( by rw [ ← Nat.mod_mod_of_dvd _ ( pow_dvd_pow _ ( Nat.le_succ _ ) ), hn_mod ] ; norm_num );
  · rw [ Nat.dvd_iff_mod_eq_zero, hn_mod ] ; norm_num [ pow_add ]

/-! ### Backward inverse step (conditional) -/

/-
**Conditional backward step**: Given odd positive `m` with `¬ 3 ∣ (2^a * m - 1)` ruled
    out (i.e., `2^a * m ≡ 1 mod 3`), we can find odd positive `n` with
    `3n + 1 = 2^a * m`, hence `v₂(3n+1) = a` and `accelCollatzOdd n = m`.

    NOTE: Without the mod-3 compatibility condition, the backward step is impossible
    (e.g., m = 1, a = 1 gives n = 1/3).
-/
theorem backward_inverse_step_conditional (m : ℕ) (hm_pos : 0 < m) (hm_odd : m % 2 = 1)
    (a : ℕ) (ha : 1 ≤ a) (hmod3 : (2 ^ a * m) % 3 = 1) :
    ∃ n : ℕ, 0 < n ∧ n % 2 = 1 ∧
      v2Nat (3 * n + 1) = a ∧ accelCollatzOdd n = m := by
  -- Define $n = \frac{2^a * m - 1}{3}$.
  use (2 ^ a * m - 1) / 3;
  -- Verify that $3 * ((2 ^ a * m - 1) / 3) + 1 = 2 ^ a * m$.
  have h_eq : 3 * ((2 ^ a * m - 1) / 3) + 1 = 2 ^ a * m := by
    omega;
  -- Verify that $v₂(3 * ((2 ^ a * m - 1) / 3) + 1) = a$.
  have h_v2 : v2Nat (3 * ((2 ^ a * m - 1) / 3) + 1) = a := by
    unfold v2Nat; rw [ h_eq ] ;
    rw [ multiplicity_mul ];
    · rw [ multiplicity_pow_self ] <;> norm_num [ hm_pos.ne', hm_odd ];
      exact multiplicity_eq_zero.mpr ( by omega );
    · norm_num [ ← Nat.prime_iff ];
    · exact Nat.finiteMultiplicity_iff.mpr ⟨ by norm_num, by positivity ⟩;
  refine' ⟨ Nat.div_pos _ ( by decide ), _, h_v2, _ ⟩;
  · grind;
  · grind;
  · unfold accelCollatzOdd;
    unfold oddPart; aesop;

/-! ### Orbit determination by residue class -/

/-- The linear part of `3n+1` is determined modulo `2^m` by `n` modulo `2^m`. -/
theorem accelCollatzOdd_mod_determined (m : ℕ) (n₁ n₂ : ℕ)
    (hn₁ : 0 < n₁) (hn₂ : 0 < n₂)
    (hodd₁ : n₁ % 2 = 1) (hodd₂ : n₂ % 2 = 1)
    (hmod : n₁ % 2 ^ m = n₂ % 2 ^ m) :
    (3 * n₁ + 1) % 2 ^ m = (3 * n₂ + 1) % 2 ^ m := by
  exact Nat.ModEq.add (Nat.ModEq.mul_left _ hmod) rfl

/-! ### Multi-step realizability (conjecture) -/

/-- **Valuation pattern realizability (conjecture)**:
    For any finite sequence `a : Fin k → ℕ` with each `aᵢ ≥ 1`,
    there exists an odd positive `n` such that the first `k` steps of the accelerated
    orbit realize exactly those valuations.

    This is the finite-prefix surjectivity of the Collatz valuation coding map.

    **Proof status**: The single-step case is proved. The full multi-step version
    requires a backward congruence construction that composes mod-3 compatibility
    conditions across steps; this is left as a formally stated conjecture.

    **Proof strategy**: Work backwards from step `k-1` to step `0`. At each step,
    use the CRT to combine the congruence `n ≡ rᵢ mod 2^(aᵢ+1)` with accumulated
    constraints from later steps. The key ingredient is that 3 is invertible mod `2^m`. -/
theorem collatz_valuation_pattern_realizable
    (k : ℕ) (a : Fin k → ℕ)
    (ha : ∀ i, 1 ≤ a i) :
    ∃ n : ℕ,
      0 < n ∧ n % 2 = 1 ∧
      ∀ i : Fin k,
        v2Nat (3 * accelSeq n i.1 + 1) = a i := by
  sorry

end Collatz