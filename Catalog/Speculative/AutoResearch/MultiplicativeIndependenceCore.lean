/-
# The Arithmetic Core of Cobham's Theorem: The Multiplicative Independence Barrier

Cobham's theorem (1972) states that a set of natural numbers that is simultaneously
recognizable in two *multiplicatively independent* bases `k` and `l` is eventually
periodic. The single arithmetic hypothesis that powers the whole edifice is the notion
of **multiplicative (in)dependence** of the bases: `k` and `l` are multiplicatively
dependent iff some positive powers coincide, `k ^ a = l ^ b`.

This file isolates and formalizes that arithmetic core. We:

* define `MultDep k l` (existence of a common positive power),
* prove it is an **equivalence relation** on `ℕ` (the algebraic skeleton of the theory),
* give the **common-base** sufficient condition,
* prove the **coprimality barrier**: coprime bases `≥ 2` are always independent,
  recovering the classical fact that `2` and `3` are multiplicatively independent,
* and establish the **transcendence bridge**: for bases `≥ 2`, multiplicative
  dependence is *equivalent* to rationality of `log k / log l`. This is precisely the
  real-analytic reformulation that connects Cobham's hypothesis to Diophantine
  approximation and Baker-style transcendence theory.

-- !-- Lab Notebook -- !--
Hypothesis: The hypothesis "multiplicatively independent bases" in Cobham's theorem can
  be captured by a single elementary predicate `MultDep` whose structure (an equivalence
  relation) and whose real-analytic shadow (rationality of `log k / log l`) are fully
  formalizable in Lean 4 over Mathlib.
Result: All five target theorems proved with `sorry = 0`. `MultDep` is an equivalence
  relation; coprime bases are independent; `2,3` independent; `2,4` dependent; and the
  log-ratio rationality characterization holds for bases `≥ 2`.
Insight: Transitivity of `MultDep` is the crisp algebraic heart — from `k^a = l^b` and
  `l^c = m^d` one passes to `k^(a c) = m^(b d)` by interleaving the exponents. The
  log-ratio bridge then re-expresses everything as `a · log k = b · log l`, turning a
  combinatorial statement into a statement about a single real ratio.
Failure analysis: The naive attempt to characterize dependence via "same prime support"
  fails (e.g. `6` and `12` share support `{2,3}` but `6^a = 12^b` forces `a = b = 0`);
  the correct invariant is the *projective ratio of exponent vectors*, captured here
  cleanly through `log k / log l`.
-- !-- Lab Notebook -- !--
-/

import Mathlib

set_option maxHeartbeats 1000000

namespace CobhamCore

/-- **Multiplicative dependence**: bases `k` and `l` admit a common positive power. -/
def MultDep (k l : ℕ) : Prop := ∃ a b : ℕ, 0 < a ∧ 0 < b ∧ k ^ a = l ^ b

-- !-- `MultDep k k` via the witness `a = b = 1`. -- !--
theorem multDep_refl (k : ℕ) : MultDep k k := by
  exact ⟨ 1, 1, by norm_num ⟩

-- !-- Swap the two witnesses `a` and `b`. -- !--
theorem multDep_symm {k l : ℕ} (h : MultDep k l) : MultDep l k := by
  -- By definition of MultDep, if there exist a and b such that k^a = l^b, then we can swap a and b to get l^a = k^b.
  obtain ⟨a, b, ha, hb, h_eq⟩ := h;
  use b, a;
  aesop;

-- !-- From `k^a = l^b` and `l^c = m^d`, interleave exponents: `k^(a*c) = (l^b)^c =
--     (l^c)^b = m^(d*b)`, witnesses `a*c, d*b > 0`. -- !--
theorem multDep_trans {k l m : ℕ} (h1 : MultDep k l) (h2 : MultDep l m) :
    MultDep k m := by
      obtain ⟨ a, b, ha, hb, hab ⟩ := h1
      obtain ⟨ c, d, hc, hd, hcd ⟩ := h2
      use a * c, b * d
      simp [pow_mul];
      exact ⟨ ⟨ ha, hc ⟩, ⟨ hb, hd ⟩, by rw [ hab, pow_right_comm, hcd, pow_right_comm ] ⟩

/-- **`MultDep` is an equivalence relation on `ℕ`** — the algebraic skeleton of the
multiplicative-independence theory underlying Cobham's theorem. -/
theorem multDep_equivalence : Equivalence MultDep :=
  ⟨multDep_refl, multDep_symm, multDep_trans⟩

-- !-- Common-base sufficiency: if `k = n^s`, `l = n^t`, then `k^t = n^(s*t) = l^s`. -- !--
theorem multDep_of_common_base {n s t : ℕ} (hs : 0 < s) (ht : 0 < t) :
    MultDep (n ^ s) (n ^ t) := by
      exact ⟨ t, s, ht, hs, by ring ⟩

-- !-- Concrete dependence: `2^2 = 4^1`. -- !--
theorem multDep_two_four : MultDep 2 4 := by
  exact ⟨ 2, 1, by decide, by decide, by decide ⟩

/-- **The coprimality barrier**: coprime bases `≥ 2` are multiplicatively independent.
A prime `p ∣ k` would divide `k^a = l^b`, hence divide `l`, contradicting coprimality. -/
theorem not_multDep_of_coprime {k l : ℕ} (hk : 2 ≤ k) (h : Nat.Coprime k l) :
    ¬ MultDep k l := by
      rintro ⟨ a, b, ha, hb, hab ⟩;
      obtain ⟨ p, hp₁, hp₂ ⟩ := Nat.exists_prime_and_dvd ( by linarith : k ≠ 1 );
      exact hp₁.not_dvd_one <| h.gcd_eq_one ▸ Nat.dvd_gcd hp₂ ( hp₁.dvd_of_dvd_pow <| hab ▸ dvd_pow hp₂ ha.ne' )

/-- **Multiplicative independence of `2` and `3`** — the textbook instance of Cobham's
arithmetic hypothesis, recovered from the coprimality barrier. -/
theorem not_multDep_two_three : ¬ MultDep 2 3 := by
  exact not_multDep_of_coprime ( by decide ) ( by decide )

/-- **The transcendence bridge**: for bases `≥ 2`, multiplicative dependence is
equivalent to rationality of `log k / log l`.

Forward: `k^a = l^b` gives `a·log k = b·log l`, so `log k / log l = b/a ∈ ℚ`.
Reverse: writing `q = b/a > 0` in lowest terms, `a·log k = b·log l` exponentiates to
`(k:ℝ)^a = (l:ℝ)^b`, hence `k^a = l^b`.

This is the real-analytic reformulation of Cobham's hypothesis: bases are
multiplicatively *independent* exactly when `log k / log l` is *irrational*. -/
theorem multDep_iff_log_ratio_rational {k l : ℕ} (hk : 2 ≤ k) (hl : 2 ≤ l) :
    MultDep k l ↔ ∃ q : ℚ, Real.log k / Real.log l = (q : ℝ) := by
      -- Forward implication: if `MultDep k l`, then `log k / log l` is rational.
      apply Iff.intro
      intro h
      obtain ⟨a, b, ha, hb, h_eq⟩ := h
      use (b / a : ℚ)
      field_simp [h_eq];
      · rw [ div_eq_iff ] <;> norm_num;
        · rw [ div_mul_eq_mul_div, eq_div_iff ] <;> first | positivity | have := congr_arg Real.log ( show ( k : ℝ ) ^ a = l ^ b by exact_mod_cast h_eq ) ; norm_num at this ; linarith;
        · exact ⟨ by linarith, by linarith, by linarith ⟩;
      · intro hq
        obtain ⟨q, hq_eq⟩ := hq
        have h_pos : 0 < q := by
          exact_mod_cast hq_eq ▸ div_pos ( Real.log_pos ( by norm_cast ) ) ( Real.log_pos ( by norm_cast ) );
        -- Write $q = \frac{b}{a}$ with $a, b \in \mathbb{N}$ and $\gcd(a, b) = 1$.
        obtain ⟨a, b, ha_pos, hb_pos, hab_coprime, rfl⟩ : ∃ a b : ℕ, a > 0 ∧ b > 0 ∧ Nat.gcd a b = 1 ∧ q = b / a := by
          exact ⟨ q.den, q.num.natAbs, mod_cast q.pos, mod_cast Nat.pos_of_ne_zero ( by aesop ), q.reduced.symm, by simp [ abs_of_pos, h_pos, Rat.num_div_den ] ⟩;
        -- Then $a \cdot \log k = b \cdot \log l$, which implies $k^a = l^b$.
        have h_exp : (k : ℝ) ^ a = (l : ℝ) ^ b := by
          rw [ div_eq_iff ] at hq_eq <;> norm_num at *;
          · rw [ ← Real.exp_log ( by positivity : 0 < ( k : ℝ ) ), ← Real.exp_log ( by positivity : 0 < ( l : ℝ ) ), hq_eq, mul_comm ] ; norm_num [ ← Real.exp_nat_mul, ha_pos.ne', hb_pos.ne' ];
            rw [ mul_left_comm, mul_div_cancel₀ _ ( by positivity ), mul_comm ];
          · exact ⟨ by linarith, by linarith, by linarith ⟩;
        exact ⟨ a, b, ha_pos, hb_pos, mod_cast h_exp ⟩

end CobhamCore