/-
# From the `E₄² = E₈` identity to elementary divisor-sum congruences

A *connector* result.  On the modular-forms side, the ring of level-one modular
forms is so rigid that in weight `8` there is a unique normalized form, forcing
the Eisenstein identity `E₄² = E₈`.  Comparing `q`-expansions of

  `E₄ = 1 + 240 ∑ σ₃(n) qⁿ`,   `E₈ = 1 + 480 ∑ σ₇(n) qⁿ`

yields, after dividing by `480`, the exact convolution law

  `σ₇(n) = σ₃(n) + 120 · ∑_{i=1}^{n-1} σ₃(i) σ₃(n−i)`,

and in particular the congruence `σ₇(n) ≡ σ₃(n) (mod 120)`.

This file proves the *arithmetic shadow* of that transcendental identity by purely
elementary means, and shows that the whole phenomenon is governed by a single
reusable bridge:

* `pow_pow_dvd_of_zmod` / `pow7_sub_pow3_dvd`, `pow5_sub_pow3_dvd` — the pointwise
  power-residue laws `120 ∣ d⁷ − d³` and `24 ∣ d⁵ − d³`, proved by finite
  computation in `ZMod`.
* `sigma_sub_dvd_of_pow` — **the connector**: any pointwise power congruence
  `m ∣ aʲ − aᵏ` transfers verbatim to the divisor sums,
  `m ∣ σⱼ(n) − σₖ(n)`, because a divisor sum is a sum of powers.
* `sigma7_sub_sigma3_dvd`, `sigma5_sub_sigma3_dvd` — the resulting divisor-sum
  congruences `σ₇(n) ≡ σ₃(n) (mod 120)` and `σ₅(n) ≡ σ₃(n) (mod 24)`.
* `pow7_modulus_isGreatest`, `sigma7_modulus_isGreatest` — **sharpness**: `120`
  is the *largest* modulus for which either congruence holds for all inputs
  (witnessed at `a = 2`, resp. `n = 2`).
* `pow5_modulus_isGreatest`, `sigma5_modulus_isGreatest` — the weight-`6`
  sharpness analogue: `24` is the largest modulus for `d⁵ ≡ d³` / `σ₅ ≡ σ₃`.
* `E8_normalized_congruence` — scaling by the `E₈` vector-count normalization
  `240` gives `28800 ∣ 240·σ₇(n) − 240·σ₃(n)`, the modulus against which the
  rank-`16` even unimodular genus (`E₈ ⊕ E₈` vs `D₁₆⁺`) is compared.
* `convolution_law_two`, … `convolution_law_five` — concrete instances of the
  exact convolution law confirming the arithmetic reproduces the `q`-expansion
  coefficients term by term.

Everything below is elementary and self-contained; the modular-forms input is used
only as motivation.
-/
import Mathlib

open Finset

namespace EisensteinPowerCongruence

set_option maxRecDepth 4000

/-- The integer-valued divisor power sum `σ_k(n) = ∑_{d ∣ n} d^k`. -/
def sigmaZ (k n : ℕ) : ℤ := ∑ d ∈ n.divisors, (d : ℤ) ^ k

@[simp] lemma sigmaZ_def (k n : ℕ) : sigmaZ k n = ∑ d ∈ n.divisors, (d : ℤ) ^ k := rfl

/-! ## Pointwise power-residue laws -/

/-- Generic bridge from a `ZMod` identity to an integer divisibility. -/
theorem pow_pow_dvd_of_zmod (m j k : ℕ)
    (h : ∀ x : ZMod m, x ^ j = x ^ k) (a : ℤ) :
    (m : ℤ) ∣ a ^ j - a ^ k := by
  have hz : ((a ^ j - a ^ k : ℤ) : ZMod m) = 0 := by
    push_cast
    rw [h]
    ring
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ m).mp hz

/-- `120 ∣ d⁷ − d³` for every integer `d`.  This is the pointwise residue of the
`E₄² = E₈` identity. -/
theorem pow7_sub_pow3_dvd (a : ℤ) : (120 : ℤ) ∣ a ^ 7 - a ^ 3 := by
  have h : ∀ x : ZMod 120, x ^ 7 = x ^ 3 := by decide
  simpa using pow_pow_dvd_of_zmod 120 7 3 h a

/-- `24 ∣ d⁵ − d³` for every integer `d`: the weight-`6` analogue. -/
theorem pow5_sub_pow3_dvd (a : ℤ) : (24 : ℤ) ∣ a ^ 5 - a ^ 3 := by
  have h : ∀ x : ZMod 24, x ^ 5 = x ^ 3 := by decide
  simpa using pow_pow_dvd_of_zmod 24 5 3 h a

/-! ## The connector: pointwise congruences transfer to divisor sums -/

/-- **Connector lemma.**  A pointwise power congruence `m ∣ aʲ − aᵏ` (valid for all
integers `a`) transfers to the divisor power sums: `m ∣ σⱼ(n) − σₖ(n)`.  This is the
mechanism that turns an elementary residue law into an Eisenstein-coefficient
congruence. -/
theorem sigma_sub_dvd_of_pow (m : ℤ) (j k : ℕ)
    (h : ∀ a : ℤ, m ∣ a ^ j - a ^ k) (n : ℕ) :
    m ∣ sigmaZ j n - sigmaZ k n := by
  rw [sigmaZ_def, sigmaZ_def, ← Finset.sum_sub_distrib]
  exact Finset.dvd_sum (fun d _ => h d)

/-- `σ₇(n) ≡ σ₃(n) (mod 120)` for every `n` — the arithmetic residue of `E₄² = E₈`. -/
theorem sigma7_sub_sigma3_dvd (n : ℕ) : (120 : ℤ) ∣ sigmaZ 7 n - sigmaZ 3 n :=
  sigma_sub_dvd_of_pow 120 7 3 pow7_sub_pow3_dvd n

/-- `σ₅(n) ≡ σ₃(n) (mod 24)` for every `n` — the weight-`6` congruence. -/
theorem sigma5_sub_sigma3_dvd (n : ℕ) : (24 : ℤ) ∣ sigmaZ 5 n - sigmaZ 3 n :=
  sigma_sub_dvd_of_pow 24 5 3 pow5_sub_pow3_dvd n

/-! ## Sharpness of the modulus `120` -/

/-- `120` is the *greatest* modulus `m` with `m ∣ d⁷ − d³` for all integers `d`.
The upper bound is witnessed by `d = 2`, where `2⁷ − 2³ = 120`. -/
theorem pow7_modulus_isGreatest :
    IsGreatest {m : ℕ | 0 < m ∧ ∀ a : ℤ, (m : ℤ) ∣ a ^ 7 - a ^ 3} 120 := by
  constructor
  · exact ⟨by norm_num, pow7_sub_pow3_dvd⟩
  · rintro m ⟨hm, hdvd⟩
    have h2 := hdvd 2
    norm_num at h2
    -- `(m : ℤ) ∣ 120` gives `m ∣ 120` in ℕ, hence `m ≤ 120`
    have : m ∣ 120 := by
      have : (m : ℤ) ∣ (120 : ℕ) := by exact_mod_cast h2
      exact_mod_cast this
    exact Nat.le_of_dvd (by norm_num) this

/-- `120` is the *greatest* modulus `m` with `σ₇(n) ≡ σ₃(n) (mod m)` for all `n`.
The upper bound is witnessed by `n = 2`, where `σ₇(2) − σ₃(2) = 129 − 9 = 120`. -/
theorem sigma7_modulus_isGreatest :
    IsGreatest {m : ℕ | 0 < m ∧ ∀ n : ℕ, (m : ℤ) ∣ sigmaZ 7 n - sigmaZ 3 n} 120 := by
  constructor
  · exact ⟨by norm_num, sigma7_sub_sigma3_dvd⟩
  · rintro m ⟨hm, hdvd⟩
    have h2 := hdvd 2
    have hval : sigmaZ 7 2 - sigmaZ 3 2 = 120 := by decide
    rw [hval] at h2
    have : m ∣ 120 := by
      have : (m : ℤ) ∣ (120 : ℕ) := by exact_mod_cast h2
      exact_mod_cast this
    exact Nat.le_of_dvd (by norm_num) this

/-- `24` is the *greatest* modulus `m` with `m ∣ d⁵ − d³` for all integers `d`.
The upper bound is witnessed by `d = 2`, where `2⁵ − 2³ = 24`. -/
theorem pow5_modulus_isGreatest :
    IsGreatest {m : ℕ | 0 < m ∧ ∀ a : ℤ, (m : ℤ) ∣ a ^ 5 - a ^ 3} 24 := by
  constructor
  · exact ⟨by norm_num, pow5_sub_pow3_dvd⟩
  · rintro m ⟨hm, hdvd⟩
    have h2 := hdvd 2
    norm_num at h2
    have : m ∣ 24 := by
      have : (m : ℤ) ∣ (24 : ℕ) := by exact_mod_cast h2
      exact_mod_cast this
    exact Nat.le_of_dvd (by norm_num) this

/-- `24` is the *greatest* modulus `m` with `σ₅(n) ≡ σ₃(n) (mod m)` for all `n`.
The upper bound is witnessed by `n = 2`, where `σ₅(2) − σ₃(2) = 33 − 9 = 24`. -/
theorem sigma5_modulus_isGreatest :
    IsGreatest {m : ℕ | 0 < m ∧ ∀ n : ℕ, (m : ℤ) ∣ sigmaZ 5 n - sigmaZ 3 n} 24 := by
  constructor
  · exact ⟨by norm_num, sigma5_sub_sigma3_dvd⟩
  · rintro m ⟨hm, hdvd⟩
    have h2 := hdvd 2
    have hval : sigmaZ 5 2 - sigmaZ 3 2 = 24 := by decide
    rw [hval] at h2
    have : m ∣ 24 := by
      have : (m : ℤ) ∣ (24 : ℕ) := by exact_mod_cast h2
      exact_mod_cast this
    exact Nat.le_of_dvd (by norm_num) this

/-! ## Cross-domain corollary: the rank-16 even unimodular genus modulus -/

/-- Scaling the weight-`8` congruence by the `E₈` vector-count normalization `240`
produces the modulus `28800 = 240 · 120` against which the two rank-`16` even
unimodular lattices (`E₈ ⊕ E₈` and `D₁₆⁺`) are compared: their theta coefficients
`240·σ₇` and `240·σ₃` are congruent mod `28800`. -/
theorem E8_normalized_congruence (n : ℕ) :
    (28800 : ℤ) ∣ 240 * sigmaZ 7 n - 240 * sigmaZ 3 n := by
  have h := sigma7_sub_sigma3_dvd n
  obtain ⟨c, hc⟩ := h
  refine ⟨c, ?_⟩
  have : 240 * sigmaZ 7 n - 240 * sigmaZ 3 n = 240 * (sigmaZ 7 n - sigmaZ 3 n) := by ring
  rw [this, hc]; ring

/-! ## Concrete instances of the exact convolution law (Direction 1)

The self-convolution `(σ₃ ⋆ σ₃)(n) = ∑_{i=1}^{n-1} σ₃(i) σ₃(n−i)`. -/

/-- The Dirichlet-style self-convolution of `σ₃` over the range `1 ≤ i ≤ n−1`. -/
def conv3 (n : ℕ) : ℤ := ∑ i ∈ Finset.Ico 1 n, sigmaZ 3 i * sigmaZ 3 (n - i)

/-- Exact convolution law at `n = 2`: `σ₇(2) = σ₃(2) + 120·(σ₃⋆σ₃)(2)`. -/
theorem convolution_law_two : sigmaZ 7 2 = sigmaZ 3 2 + 120 * conv3 2 := by decide

/-- Exact convolution law at `n = 3`. -/
theorem convolution_law_three : sigmaZ 7 3 = sigmaZ 3 3 + 120 * conv3 3 := by decide

/-- Exact convolution law at `n = 4`. -/
theorem convolution_law_four : sigmaZ 7 4 = sigmaZ 3 4 + 120 * conv3 4 := by decide

/-- Exact convolution law at `n = 5`. -/
theorem convolution_law_five : sigmaZ 7 5 = sigmaZ 3 5 + 120 * conv3 5 := by decide

end EisensteinPowerCongruence