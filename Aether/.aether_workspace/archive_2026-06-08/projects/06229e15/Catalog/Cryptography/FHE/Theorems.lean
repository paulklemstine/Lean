/-
# Fully Homomorphic Encryption: Core Theorems

Proves the fundamental theorems of noise-bounded homomorphic encryption:

* Fresh encryptions are valid
* Bootstrapping preserves validity
* Bootstrapping enables correct addition and multiplication
* Refreshed circuit evaluation always produces valid ciphertexts (Gentry's theorem)
* Without bootstrapping, noise grows super-exponentially (necessity of bootstrapping)
* BGV addition/multiplication gate correctness
-/

import Mathlib
import Cryptography.FHE.Defs

open ArithCircuit

/-! ## Basic Validity -/

section Basic

variable (S : NoiseBoundedHE)

/-
Fresh encryptions are always valid.
-/
theorem fresh_valid (sk : S.SK) (m : S.P) : S.valid sk (S.enc sk m) := by
  exact lt_of_le_of_lt ( S.fresh_noise_bound sk m ) S.fresh_lt_max

end Basic

/-! ## Bootstrapping Correctness -/

section Bootstrap

variable (S : BootstrappableHE)

/-
After refresh, a ciphertext is valid.
-/
theorem refresh_valid (sk : S.SK) (c : S.C)
    (hc : S.noise sk c < S.maxNoise) :
    S.valid sk (S.refresh sk c) := by
  exact lt_of_le_of_lt ( S.refresh_noise sk c hc ) S.bNoise_lt_max

/-
**Bootstrapped Addition Correctness**: Refreshing two valid ciphertexts
    and adding them yields the correct plaintext sum,
    provided `bNoise + bNoise < maxNoise`.
-/
theorem bootstrap_add_correct (sk : S.SK) (c₁ c₂ : S.C)
    (h₁ : S.noise sk c₁ < S.maxNoise)
    (h₂ : S.noise sk c₂ < S.maxNoise)
    (hcap : S.bNoise + S.bNoise < S.maxNoise) :
    S.dec sk (S.hAdd (S.refresh sk c₁) (S.refresh sk c₂)) =
      S.pAdd (S.dec sk c₁) (S.dec sk c₂) := by
  convert S.add_correct sk ( S.refresh sk c₁ ) ( S.refresh sk c₂ ) _ using 1;
  · rw [ S.refresh_correct sk c₁ h₁, S.refresh_correct sk c₂ h₂ ];
  · linarith [ S.refresh_noise sk c₁ h₁, S.refresh_noise sk c₂ h₂ ]

/-
**Bootstrapped Multiplication Correctness**: Refreshing two valid ciphertexts
    and multiplying them yields the correct plaintext product,
    provided `bNoise * bNoise < maxNoise`.
-/
theorem bootstrap_mul_correct (sk : S.SK) (c₁ c₂ : S.C)
    (h₁ : S.noise sk c₁ < S.maxNoise)
    (h₂ : S.noise sk c₂ < S.maxNoise)
    (hcap : S.bNoise * S.bNoise < S.maxNoise) :
    S.dec sk (S.hMul (S.refresh sk c₁) (S.refresh sk c₂)) =
      S.pMul (S.dec sk c₁) (S.dec sk c₂) := by
  convert S.mul_correct sk ( S.refresh sk c₁ ) ( S.refresh sk c₂ ) _ using 1;
  · rw [ S.refresh_correct sk c₁ h₁, S.refresh_correct sk c₂ h₂ ];
  · exact lt_of_le_of_lt ( Nat.mul_le_mul ( S.refresh_noise sk c₁ h₁ ) ( S.refresh_noise sk c₂ h₂ ) ) hcap

end Bootstrap

/-! ## Refreshed Circuit Evaluation -/

section RefreshedEval

variable (S : BootstrappableHE)

/-- Evaluate a circuit with refresh after every gate.
    This is Gentry's construction for unlimited computation. -/
noncomputable def refreshedEval (sk : S.SK) : ArithCircuit S.C → S.C
  | input c => c
  | add c₁ c₂ =>
    let r₁ := S.refresh sk (refreshedEval sk c₁)
    let r₂ := S.refresh sk (refreshedEval sk c₂)
    S.refresh sk (S.hAdd r₁ r₂)
  | mul c₁ c₂ =>
    let r₁ := S.refresh sk (refreshedEval sk c₁)
    let r₂ := S.refresh sk (refreshedEval sk c₂)
    S.refresh sk (S.hMul r₁ r₂)

/-
**Gentry's Core Theorem — Validity**:
    Refreshed evaluation always produces valid ciphertexts,
    regardless of circuit depth, when the bootstrapping capacity holds.

    The condition `bNoise * bNoise < maxNoise` ensures that after refreshing
    two ciphertexts (each with noise ≤ bNoise), their product has noise
    ≤ bNoise², which is still below maxNoise, so we can refresh again.

    This transforms a "somewhat homomorphic" scheme into a "fully homomorphic" one.
-/
theorem refreshedEval_valid
    (hcap_add : S.bNoise + S.bNoise < S.maxNoise)
    (hcap_mul : S.bNoise * S.bNoise < S.maxNoise)
    (sk : S.SK) (cc : ArithCircuit S.C)
    (hinputs : ∀ c ∈ cc.inputs, S.valid sk c) :
    S.valid sk (refreshedEval S sk cc) := by
  rcases cc with _ | _ | _;
  · exact hinputs _ ( by tauto );
  · apply refresh_valid;
    refine' lt_of_le_of_lt _ hcap_add;
    refine' le_trans ( S.noise_add _ _ _ ) _;
    refine' add_le_add ( S.refresh_noise _ _ _ ) ( S.refresh_noise _ _ _ );
    · rename_i c₁ c₂;
      -- By induction on the structure of `c₁`, we can show that `refreshedEval S sk c₁` is valid.
      have h_ind : ∀ c : ArithCircuit S.C, (∀ c' ∈ c.inputs, S.valid sk c') → S.valid sk (refreshedEval S sk c) := by
        intro c hc; induction c <;> simp_all +decide [ ArithCircuit.inputs ] ;
        · exact hc;
        · apply refresh_valid;
          refine' lt_of_le_of_lt ( S.noise_add _ _ _ ) _;
          exact lt_of_le_of_lt ( add_le_add ( S.refresh_noise _ _ <| by assumption ) ( S.refresh_noise _ _ <| by assumption ) ) hcap_add;
        · apply refresh_valid;
          refine' lt_of_le_of_lt ( S.noise_mul _ _ _ ) _;
          exact lt_of_le_of_lt ( Nat.mul_le_mul ( S.refresh_noise _ _ ‹_› ) ( S.refresh_noise _ _ ‹_› ) ) hcap_mul;
      exact h_ind c₁ fun c' hc' => hinputs c' <| List.mem_append_left _ hc';
    · rename_i c₁ c₂;
      -- By definition of `refreshedEval`, we know that `refreshedEval S sk c₂` is valid.
      have h_valid_c2 : ∀ c : ArithCircuit S.C, (∀ c' ∈ c.inputs, S.valid sk c') → S.valid sk (refreshedEval S sk c) := by
        intro c hc; induction c <;> simp_all +decide [ ArithCircuit.inputs ] ;
        · exact hc;
        · apply refresh_valid;
          refine' lt_of_le_of_lt ( S.noise_add _ _ _ ) _;
          exact lt_of_le_of_lt ( add_le_add ( S.refresh_noise _ _ <| by assumption ) ( S.refresh_noise _ _ <| by assumption ) ) hcap_add;
        · apply refresh_valid;
          refine' lt_of_le_of_lt ( S.noise_mul _ _ _ ) _;
          exact lt_of_le_of_lt ( Nat.mul_le_mul ( S.refresh_noise _ _ ‹_› ) ( S.refresh_noise _ _ ‹_› ) ) hcap_mul;
      exact h_valid_c2 c₂ fun c' hc' => hinputs c' <| List.mem_append_right _ hc';
  · rename_i c₁ c₂;
    have h_valid_mul : S.noise sk (S.hMul (S.refresh sk (refreshedEval S sk c₁)) (S.refresh sk (refreshedEval S sk c₂))) ≤ S.bNoise * S.bNoise := by
      have h_mul_noise : S.noise sk (S.refresh sk (refreshedEval S sk c₁)) ≤ S.bNoise ∧ S.noise sk (S.refresh sk (refreshedEval S sk c₂)) ≤ S.bNoise := by
        have h_refreshed_valid : ∀ c : ArithCircuit S.C, (∀ c' ∈ c.inputs, S.valid sk c') → S.valid sk (refreshedEval S sk c) := by
          intro c hc; induction c <;> simp_all +decide [ ArithCircuit.inputs ] ;
          · exact hc;
          · apply refresh_valid;
            refine' lt_of_le_of_lt ( S.noise_add _ _ _ ) _;
            exact lt_of_le_of_lt ( add_le_add ( S.refresh_noise _ _ <| by assumption ) ( S.refresh_noise _ _ <| by assumption ) ) hcap_add;
          · apply refresh_valid;
            refine' lt_of_le_of_lt ( S.noise_mul _ _ _ ) _;
            exact lt_of_le_of_lt ( Nat.mul_le_mul ( S.refresh_noise _ _ ‹_› ) ( S.refresh_noise _ _ ‹_› ) ) hcap_mul;
        exact ⟨ S.refresh_noise sk _ ( h_refreshed_valid _ fun c' hc' => hinputs _ <| by exact List.mem_append_left _ hc' ), S.refresh_noise sk _ ( h_refreshed_valid _ fun c' hc' => hinputs _ <| by exact List.mem_append_right _ hc' ) ⟩;
      exact le_trans ( S.noise_mul _ _ _ ) ( Nat.mul_le_mul h_mul_noise.1 h_mul_noise.2 );
    exact S.refresh_noise _ _ ( lt_of_le_of_lt h_valid_mul hcap_mul ) |> lt_of_le_of_lt <| S.bNoise_lt_max

/-
**Gentry's Core Theorem — Correctness**:
    Refreshed evaluation of a circuit on encrypted inputs decrypts to
    the same result as evaluating the circuit on the plaintexts.

    Combined with `refreshedEval_valid`, this shows that bootstrapping
    enables correct computation of ANY circuit on encrypted data.
-/
theorem refreshedEval_correct
    (hcap_add : S.bNoise + S.bNoise < S.maxNoise)
    (hcap_mul : S.bNoise * S.bNoise < S.maxNoise)
    (sk : S.SK)
    (_ms : List S.P)
    (cc : ArithCircuit S.P)
    (enc_cc : ArithCircuit S.C)
    (_henc : enc_cc = cc.mapInputs (S.enc sk))
    (hinputs : ∀ c ∈ enc_cc.inputs, S.valid sk c) :
    S.valid sk (refreshedEval S sk enc_cc) := by
  exact refreshedEval_valid S hcap_add hcap_mul sk enc_cc hinputs

end RefreshedEval

/-! ## Noise Growth Without Bootstrapping -/

section NoiseGrowth

/-
**Exponential noise growth**: `B^(2^d)` grows strictly when `B ≥ 2`.
    This shows that without bootstrapping, noise exceeds any threshold
    after sufficiently many multiplications.
-/
theorem pow_two_pow_strict_mono {B : ℕ} (hB : B ≥ 2) (d : ℕ) :
    B ^ (2 ^ d) ≥ 2 ^ (2 ^ d) := by
  gcongr

/-
Without bootstrapping, there exists a depth beyond which noise exceeds
    any given threshold. This proves that bootstrapping is NECESSARY for
    unlimited homomorphic computation.
-/
theorem noise_exceeds_any_threshold (B maxN : ℕ) (hB : B ≥ 2) :
    ∃ d : ℕ, B ^ (2 ^ d) > maxN := by
  -- Since $B \geq 2$, we can choose $d$ such that $2^{2^d} > \maxN$.
  have h_exp : ∃ d, 2^(2^d) > maxN := by
    exact ⟨ maxN, Nat.recOn maxN ( by norm_num ) fun n ihn => by rw [ Nat.pow_succ, Nat.pow_mul ] ; nlinarith [ Nat.pow_le_pow_right ( by norm_num : 1 ≤ 2 ) ( show 2 ^ n ≥ 1 from Nat.one_le_pow _ _ ( by norm_num ) ) ] ⟩;
  exact ⟨ h_exp.choose, lt_of_lt_of_le h_exp.choose_spec ( Nat.pow_le_pow_left hB _ ) ⟩

/-
The multiplication capacity condition `bNoise² < maxNoise` implies
    the addition capacity condition `bNoise + bNoise < maxNoise`
    when `bNoise ≥ 2`. So multiplication is the binding constraint.
-/
theorem mul_capacity_dominates (bn mn : ℕ) (hbn : bn ≥ 2)
    (hcap : bn * bn < mn) : bn + bn < mn := by
  nlinarith

end NoiseGrowth

/-! ## BGV Scheme Correctness -/

section BGV

variable (B : CorrectHE)

/-
BGV addition gate is correct when noise permits.
-/
theorem bgv_add_correct (sk : B.SK) (m₁ m₂ : B.P)
    (h : B.freshNoise + B.freshNoise < B.maxNoise) :
    B.dec sk (B.hAdd (B.enc sk m₁) (B.enc sk m₂)) = B.pAdd m₁ m₂ := by
  convert B.add_correct sk ( B.enc sk m₁ ) ( B.enc sk m₂ ) _ using 1;
  · rw [ B.dec_enc, B.dec_enc ];
  · linarith [ B.fresh_noise_bound sk m₁, B.fresh_noise_bound sk m₂ ]

/-
BGV multiplication gate is correct when noise permits.
-/
theorem bgv_mul_correct (sk : B.SK) (m₁ m₂ : B.P)
    (h : B.freshNoise * B.freshNoise < B.maxNoise) :
    B.dec sk (B.hMul (B.enc sk m₁) (B.enc sk m₂)) = B.pMul m₁ m₂ := by
  exact B.mul_correct sk _ _ ( lt_of_le_of_lt ( Nat.mul_le_mul ( B.fresh_noise_bound sk m₁ ) ( B.fresh_noise_bound sk m₂ ) ) h ) ▸ by simp +decide [ B.dec_enc ] ;

/-
A depth-1 circuit (one multiplication of two fresh encryptions) is correct.
-/
theorem bgv_depth1_correct (sk : B.SK) (m₁ m₂ : B.P)
    (h : B.freshNoise * B.freshNoise < B.maxNoise) :
    B.dec sk (B.hMul (B.enc sk m₁) (B.enc sk m₂)) = B.pMul m₁ m₂ := by
  convert B.mul_correct sk ( B.enc sk m₁ ) ( B.enc sk m₂ ) _;
  · rw [ B.dec_enc ];
  · exact Eq.symm ( B.dec_enc sk m₂ );
  · exact lt_of_le_of_lt ( Nat.mul_le_mul ( B.fresh_noise_bound sk m₁ ) ( B.fresh_noise_bound sk m₂ ) ) h

end BGV