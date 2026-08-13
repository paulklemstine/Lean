import Mathlib
import Algebra.QubitTrade.Resolution
import Algebra.QubitTrade.SupportCollapse
import Algebra.QubitTrade.SampleFungibility

/-!
# QUBIT-TRADE IV: synthesis — the register size is forced

This file packages the three halves of the experiment into bit-counted statements
and one end-to-end recovery theorem.

* `QubitTrade.register_suffices` — `t ≥ 2 log₂ R + 2` determines the
  continued-fraction target;
* `QubitTrade.register_fails` — `t + 1 ≤ 2 log₂ R` (and `R ≥ 3`) leaves it
  ambiguous;
* `QubitTrade.register_threshold_bits` — the two together: the minimal register
  size obeys `2 log₂ R - 1 ≤ t_min ≤ 2 log₂ R + 2`, i.e. `t_min = 2 log₂ R + O(1)`
  and **not** `log₂ R + O(log log R)`;
* `QubitTrade.recovery_above_threshold` — above the threshold, honest continued
  fraction post-processing of a record whose numerators are jointly coprime to
  the order returns the order *exactly*: qubits above `2 log₂ R` plus samples
  compensating `gcd (k, r) > 1`;
* `QubitTrade.qubit_trade_trichotomy` — the three regimes in a single statement.

Reading it with `r ~ N` (the generic case for a random base modulo a semiprime)
gives `t_min ≈ 2 log₂ N`, which is Shor's full register: the quantum channel
cannot be shrunk by truncation.
-/

namespace QubitTrade

open Nat

/-! ## Bit-counted forms of the threshold -/

/-- A register of `2 log₂ R + 2` bits determines the continued-fraction target
among all fractions of reduced denominator at most `R`. -/
theorem register_suffices {R t : ℕ} (hR : 1 ≤ R) (ht : 2 * Nat.log 2 R + 2 ≤ t)
    {x : ℝ} {q₁ q₂ : ℚ} (h₁ : q₁.den ≤ R) (h₂ : q₂.den ≤ R)
    (c₁ : Compatible t x q₁) (c₂ : Compatible t x q₂) : q₁ = q₂ := by
  refine cf_target_unique ?_ h₁ h₂ c₁ c₂
  have hlt : R < 2 ^ (Nat.log 2 R + 1) := Nat.lt_pow_succ_log_self (by norm_num) R
  have hltR : (R : ℝ) < ((2 ^ (Nat.log 2 R + 1) : ℕ) : ℝ) := by exact_mod_cast hlt
  have hRnn : (0:ℝ) ≤ (R : ℝ) := by positivity
  have hsq : ((R : ℝ)) ^ 2 ≤ ((2:ℝ) ^ (Nat.log 2 R + 1)) ^ 2 := by
    have : (R : ℝ) ≤ (2:ℝ) ^ (Nat.log 2 R + 1) := by
      push_cast at hltR
      linarith
    nlinarith
  calc ((R : ℝ)) ^ 2 ≤ ((2:ℝ) ^ (Nat.log 2 R + 1)) ^ 2 := hsq
    _ = (2:ℝ) ^ (2 * Nat.log 2 R + 2) := by rw [← pow_mul]; ring_nf
    _ ≤ (2:ℝ) ^ t := by
        apply pow_le_pow_right₀ (by norm_num) ht

/-- A register of fewer than `2 log₂ R` bits does **not**: two distinct reduced
fractions with denominators `≤ R` — realised by the two orders `R` and `R-1` —
remain compatible with a single phase. -/
theorem register_fails {R t : ℕ} (hR : 3 ≤ R) (ht : t + 1 ≤ 2 * Nat.log 2 R) :
    ∃ (x : ℝ) (q₁ q₂ : ℚ), q₁ ≠ q₂ ∧ q₁.den ≤ R ∧ q₂.den ≤ R ∧
      Compatible t x q₁ ∧ Compatible t x q₂ := by
  have hRpos : (0:ℝ) < R := by
    have : (0:ℕ) < R := by omega
    exact_mod_cast this
  have hR3 : (3:ℝ) ≤ (R : ℝ) := by exact_mod_cast hR
  have hlog : ((2 ^ Nat.log 2 R : ℕ) : ℝ) ≤ (R : ℝ) := by
    have := Nat.pow_log_le_self 2 (x := R) (by omega : R ≠ 0)
    exact_mod_cast this
  have hlogpow : ((2:ℝ)) ^ Nat.log 2 R ≤ (R : ℝ) := by push_cast at hlog; exact hlog
  have hstep : ((2:ℝ)) ^ (t + 1) ≤ (R : ℝ) ^ 2 := by
    calc ((2:ℝ)) ^ (t + 1) ≤ (2:ℝ) ^ (2 * Nat.log 2 R) := by
          apply pow_le_pow_right₀ (by norm_num) ht
      _ = ((2:ℝ) ^ Nat.log 2 R) ^ 2 := by rw [← pow_mul, mul_comm]
      _ ≤ (R : ℝ) ^ 2 := by nlinarith [pow_pos (show (0:ℝ) < 2 by norm_num) (Nat.log 2 R)]
  have hkey : ((2:ℝ)) ^ t < (R : ℝ) * ((R : ℝ) - 1) := by
    have h2 : ((2:ℝ)) ^ (t + 1) = 2 * (2:ℝ) ^ t := by rw [pow_succ]; ring
    nlinarith
  obtain ⟨x, hne, hd₁, hd₂, c₁, c₂⟩ := cf_target_ambiguous (by omega : 2 ≤ R) hkey
  exact ⟨x, orderFrac 1 R, orderFrac 1 (R - 1), hne, by omega, by omega, c₁, c₂⟩

/-- **The register threshold in bits.**  For every order bound `R ≥ 3` the minimal
number of retained bits `t_min` satisfies

  `2 log₂ R - 1 ≤ t_min ≤ 2 log₂ R + 2`,

so `t_min = 2 log₂ R + O(1)`.  Truncating to `log₂ R + O(log log R)` bits is
impossible. -/
theorem register_threshold_bits {R : ℕ} (hR : 3 ≤ R) :
    (∀ t : ℕ, 2 * Nat.log 2 R + 2 ≤ t → ∀ (x : ℝ) (q₁ q₂ : ℚ), q₁.den ≤ R → q₂.den ≤ R →
        Compatible t x q₁ → Compatible t x q₂ → q₁ = q₂) ∧
    (∀ t : ℕ, t + 1 ≤ 2 * Nat.log 2 R →
        ∃ (x : ℝ) (q₁ q₂ : ℚ), q₁ ≠ q₂ ∧ q₁.den ≤ R ∧ q₂.den ≤ R ∧
          Compatible t x q₁ ∧ Compatible t x q₂) :=
  ⟨fun t ht x q₁ q₂ h₁ h₂ c₁ c₂ => register_suffices (by omega) ht h₁ h₂ c₁ c₂,
   fun t ht => register_fails hR ht⟩

/-! ## End-to-end recovery above the threshold -/

/-- **Honest post-processing recovers the order above the threshold.**

Assume the register satisfies `R^2 ≤ 2^t`, the true order `r ≤ R`, and that for
every sample `k` of the record the post-processor returns *some* fraction `q k` of
reduced denominator `≤ R` compatible with the same observed phase as the true
fraction `k/r`.  If the sampled numerators are jointly coprime to `r`, then the
least common multiple of the returned denominators is exactly `r`. -/
theorem recovery_above_threshold {R t r : ℕ} (hRt : ((R : ℝ)) ^ 2 ≤ 2 ^ t)
    (hr : 0 < r) (hrR : r ≤ R) {ks : List ℕ} (hgcd : Nat.gcd (recordGcd ks) r = 1)
    (q : ℕ → ℚ)
    (hq : ∀ k ∈ ks, (q k).den ≤ R ∧
      ∃ x : ℝ, Compatible t x (orderFrac k r) ∧ Compatible t x (q k)) :
    (ks.map (fun k => (q k).den)).foldr Nat.lcm 1 = r := by
  have hden : ∀ k ∈ ks, (q k).den = recovered k r := by
    intro k hk
    obtain ⟨hb, x, hx₁, hx₂⟩ := hq k hk
    have htrue : (orderFrac k r).den ≤ R := by
      rw [orderFrac_den k r hr]
      exact le_trans (Nat.div_le_self _ _) hrR
    have := cf_target_unique hRt htrue hb hx₁ hx₂
    rw [← this]
    rfl
  have hmap : ks.map (fun k => (q k).den) = ks.map (fun k => recovered k r) :=
    List.map_congr_left hden
  rw [hmap]
  exact samples_recover hr hgcd

/-! ## The three regimes -/

/-- **The qubit ↔ sample trade, in one statement.**  Fix an order bound `R ≥ 3`.

1. *Collapse* (`t ≤ log₂ r`): if two distinct orders both exceed `2^t`, no
   estimator using **any** number of truncated samples can be correct for both.
2. *Single-shot ambiguity* (`t < 2 log₂ R`): the continued-fraction target itself
   is not determined by a `t`-bit phase.
3. *Recovery* (`t ≥ 2 log₂ R + 2`): the target is determined, and a record of
   samples jointly coprime to the order returns the order exactly.

Samples are fungible with qubits only in regime 3, where they repair
`gcd (k, r) > 1`; in regimes 1–2 they buy nothing. -/
theorem qubit_trade_trichotomy {R : ℕ} (hR : 3 ≤ R) :
    (∀ (t r r' : ℕ), 2 ^ t ≤ r → 2 ^ t ≤ r' → r ≠ r' → ∀ A : List ℕ → ℕ,
        ¬ ((∀ L : List ℕ, (∀ m ∈ L, m ∈ outcomes t r) → A L = r) ∧
           (∀ L : List ℕ, (∀ m ∈ L, m ∈ outcomes t r') → A L = r'))) ∧
    (∀ t : ℕ, t + 1 ≤ 2 * Nat.log 2 R →
        ∃ (x : ℝ) (q₁ q₂ : ℚ), q₁ ≠ q₂ ∧ q₁.den ≤ R ∧ q₂.den ≤ R ∧
          Compatible t x q₁ ∧ Compatible t x q₂) ∧
    (∀ (t r : ℕ), 2 * Nat.log 2 R + 2 ≤ t → 0 < r → r ≤ R → ∀ ks : List ℕ,
        Nat.gcd (recordGcd ks) r = 1 → ∀ q : ℕ → ℚ,
        (∀ k ∈ ks, (q k).den ≤ R ∧
          ∃ x : ℝ, Compatible t x (orderFrac k r) ∧ Compatible t x (q k)) →
        (ks.map (fun k => (q k).den)).foldr Nat.lcm 1 = r) := by
  refine ⟨fun t r r' h h' hne A => samples_do_not_help h h' hne A,
          fun t ht => register_fails hR ht, fun t r ht hr hrR ks hgcd q hq => ?_⟩
  refine recovery_above_threshold ?_ hr hrR hgcd q hq
  -- the bit hypothesis implies the arithmetic one
  have hlt : R < 2 ^ (Nat.log 2 R + 1) := Nat.lt_pow_succ_log_self (by norm_num) R
  have hltR : (R : ℝ) ≤ (2:ℝ) ^ (Nat.log 2 R + 1) := by
    have : (R : ℝ) < ((2 ^ (Nat.log 2 R + 1) : ℕ) : ℝ) := by exact_mod_cast hlt
    push_cast at this
    linarith
  have hRnn : (0:ℝ) ≤ (R : ℝ) := by positivity
  calc ((R : ℝ)) ^ 2 ≤ ((2:ℝ) ^ (Nat.log 2 R + 1)) ^ 2 := by nlinarith
    _ = (2:ℝ) ^ (2 * Nat.log 2 R + 2) := by rw [← pow_mul]; ring_nf
    _ ≤ (2:ℝ) ^ t := pow_le_pow_right₀ (by norm_num) ht

end QubitTrade