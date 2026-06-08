/-
  # P-adic Orbital Period Valuation — Arithmetic Skeletons of Keplerian Dynamics

  This file establishes the p-adic valuation theory of Kepler orbital periods.
  When the semi-major axis `a` and gravitational parameter `μ` are positive
  rationals, Kepler's third law `T² · μ = a³` becomes a Diophantine constraint.
  The p-adic valuations of the period ratio form an arithmetic fingerprint
  of the orbit.

  ## Main Results

  1. **Square Root Valuation Lemma** (`padicValRat_sq_eq_two_mul`):
     `v_p(r²) = 2 · v_p(r)` for positive rationals.

  2. **Kepler Period Valuation Formula** (`kepler_period_padic_valuation`):
     If `q² · μ = a³` with positive rationals, then
     `2 · v_p(q) = 3 · v_p(a) - v_p(μ)`.

  3. **Rationality Criterion** (`kepler_period_rational_iff_valuation_even`):
     A Kepler orbit has rational period ratio iff `3·v_p(a) - v_p(μ)` is even
     for all primes `p`.

  4. **PadicOrbitalInvariant**: A structure encoding the arithmetic fingerprint
     of a Kepler orbit as a function from primes to ℤ.
-/
import Mathlib

open scoped Classical

/-! ## Section 1: Square Root Valuation Lemma -/

/-
The p-adic valuation of a square is twice the valuation of the base.
    This follows directly from `padicValRat.pow`.
-/
theorem padicValRat_sq_eq_two_mul (p : ℕ) [Fact p.Prime] (r : ℚ) (hr : 0 < r) :
    padicValRat p (r ^ 2) = 2 * padicValRat p r := by
  rw [ padicValRat.pow ] <;> aesop

/-
Generalization: v_p(r^n) = n * v_p(r) for positive rationals.
-/
theorem padicValRat_pow_eq_mul (p : ℕ) [Fact p.Prime] (r : ℚ) (hr : 0 < r) (n : ℕ) :
    padicValRat p (r ^ n) = n * padicValRat p r := by
  induction' n with n ih;
  · simp +decide;
  · convert padicValRat.mul ( pow_ne_zero n hr.ne' ) hr.ne' using 1 ; ring;
    convert rfl;
    · push_cast [ ih ] ; ring;
    · exact ⟨ Fact.out ⟩

/-! ## Section 2: Kepler Period Valuation Formula -/

/-
**Main Result**: The Kepler period valuation formula.
    If `q² · μ = a³` with all parameters positive rationals, then
    `2 · v_p(q) = 3 · v_p(a) - v_p(μ)`.

    This follows from applying the p-adic valuation homomorphism to both sides
    of the Kepler equation: `v_p(q²·μ) = v_p(a³)` gives
    `2·v_p(q) + v_p(μ) = 3·v_p(a)`, which rearranges to the result.
-/
theorem kepler_period_padic_valuation (p : ℕ) [Fact p.Prime]
    (a μ q : ℚ) (ha : 0 < a) (hμ : 0 < μ) (hq : 0 < q)
    (hkepler : q ^ 2 * μ = a ^ 3) :
    2 * padicValRat p q = 3 * padicValRat p a - padicValRat p μ := by
  apply_fun fun x => padicValRat p x at hkepler;
  rw [ padicValRat.mul ( by positivity ) ( by positivity ), padicValRat.pow ( by positivity ), padicValRat.pow ( by positivity ) ] at hkepler ; norm_cast at *;
  linarith

/-! ## Section 3: Rationality Criterion — Forward Direction -/

/-
Forward direction: if a rational period ratio exists, then the valuation
    difference `3·v_p(a) - v_p(μ)` is even at every prime.
-/
theorem kepler_period_rational_implies_valuation_even
    (a μ : ℚ) (ha : 0 < a) (hμ : 0 < μ)
    (hexists : ∃ q : ℚ, 0 < q ∧ q ^ 2 * μ = a ^ 3) :
    ∀ p : ℕ, p.Prime → Even (3 * padicValRat p a - padicValRat p μ) := by
  intro p hp
  obtain ⟨q, hq_pos, hq_eq⟩ := hexists
  have h_period_val : 2 * padicValRat p q = 3 * padicValRat p a - padicValRat p μ := by
    convert kepler_period_padic_valuation p a μ q ha hμ hq_pos hq_eq using 1;
    exact ⟨ hp ⟩;
  exact h_period_val ▸ even_two_mul _

/-! ## Section 4: Rationality Criterion — Backward Direction

The backward direction requires showing that if `3·v_p(a) - v_p(μ)` is even
for all primes, then `a³/μ` is a perfect square in ℚ. This uses the
characterization of rational perfect squares via p-adic valuations. -/

/-
A positive rational is a perfect square iff all its p-adic valuations are even.
-/
theorem rat_sq_iff_all_valuations_even (r : ℚ) (hr : 0 < r) :
    (∃ s : ℚ, 0 < s ∧ s ^ 2 = r) ↔
      (∀ p : ℕ, p.Prime → Even (padicValRat p r)) := by
  constructor <;> intro h;
  · obtain ⟨ s, hs_pos, rfl ⟩ := h; intro p pp; simp_all +decide [ ← sq, padicValRat.pow ] ;
    haveI := Fact.mk pp; simp +decide [ padicValRat.pow, hs_pos.ne' ] ;
  · -- Write r as a fraction in lowest terms: r = num / den.
    obtain ⟨num, den, hnum_pos, hden_pos, hnum_den_coprime, hr_eq⟩ : ∃ num den : ℕ, num > 0 ∧ den > 0 ∧ Nat.gcd num den = 1 ∧ r = num / den := by
      exact ⟨ r.num.natAbs, r.den, by aesop, Nat.cast_pos.mpr r.pos, r.reduced, by simpa [ abs_of_pos ( Rat.num_pos.mpr hr ) ] using r.num_div_den.symm ⟩;
    -- Since $r$ is in lowest terms, for each prime $p$, exactly one of $v_p(\text{num})$ and $v_p(\text{den})$ is nonzero.
    have h_val_even : ∀ p : ℕ, Nat.Prime p → (Even (Nat.factorization num p)) ∧ (Even (Nat.factorization den p)) := by
      intro p pp; specialize h p pp; simp_all +decide [ padicValRat.div, Nat.factorization ] ;
      haveI := Fact.mk pp; simp_all +decide [ padicValRat.div, ne_of_gt ] ;
      by_cases hnum : p ∣ num <;> by_cases hden : p ∣ den <;> simp_all +decide [ padicValNat.eq_zero_of_not_dvd, Nat.Prime.dvd_iff_not_coprime ];
      exact False.elim <| hnum <| pp.coprime_iff_not_dvd.mpr fun h => hden <| pp.coprime_iff_not_dvd.mpr fun h' => pp.not_dvd_one <| hnum_den_coprime ▸ Nat.dvd_gcd h h';
    -- Since $num$ and $den$ are both perfect squares of naturals, say $num = a^2$ and $den = b^2$, then $r = a^2/b^2 = (a/b)^2$.
    obtain ⟨a, ha⟩ : ∃ a : ℕ, num = a^2 := by
      rw [ ← Nat.factorization_prod_pow_eq_self hnum_pos.ne' ];
      exact ⟨ ∏ p ∈ Nat.primeFactors num, p ^ ( num.factorization p / 2 ), by nth_rw 1 [ ← Finset.prod_pow ] ; exact Finset.prod_congr rfl fun p hp ↦ by rw [ ← pow_mul, Nat.div_mul_cancel <| even_iff_two_dvd.mp <| h_val_even p ( Nat.prime_of_mem_primeFactors hp ) |>.1 ] ⟩
    obtain ⟨b, hb⟩ : ∃ b : ℕ, den = b^2 := by
      rw [ ← Nat.factorization_prod_pow_eq_self hden_pos.ne' ];
      exact ⟨ ∏ p ∈ Nat.primeFactors den, p ^ ( den.factorization p / 2 ), by nth_rw 1 [ ← Finset.prod_pow ] ; exact Finset.prod_congr rfl fun p hp => by rw [ ← pow_mul, Nat.div_mul_cancel <| even_iff_two_dvd.mp <| h_val_even p ( Nat.prime_of_mem_primeFactors hp ) |>.2 ] ⟩;
    exact ⟨ a / b, by exact div_pos ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ) ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ), by simp +decide [ *, sq, mul_div_mul_comm ] ⟩

/-
Backward direction: if `3·v_p(a) - v_p(μ)` is even at every prime,
    then a rational period ratio exists.
-/
theorem kepler_period_valuation_even_implies_rational
    (a μ : ℚ) (ha : 0 < a) (hμ : 0 < μ)
    (heven : ∀ p : ℕ, p.Prime → Even (3 * padicValRat p a - padicValRat p μ)) :
    ∃ q : ℚ, 0 < q ∧ q ^ 2 * μ = a ^ 3 := by
  -- By rat_sq_iff_all_valuations_even, it suffices to show all p-adic valuations of `a^3/μ` are even.
  have h_rat_sq : ∃ q : ℚ, 0 < q ∧ q^2 = a^3 / μ := by
    convert rat_sq_iff_all_valuations_even ( a ^ 3 / μ ) ( by positivity ) |>.2 _;
    intro p pp; convert heven p pp using 1; simp +decide [ *, padicValRat.div, ne_of_gt ] ; ring;
    haveI := Fact.mk pp; rw [ padicValRat.pow ] <;> norm_num [ ha.ne', hμ.ne' ] ;
    ring;
  exact h_rat_sq.imp fun q hq => ⟨ hq.1, by rw [ hq.2, div_mul_cancel₀ _ hμ.ne' ] ⟩

/-
**Full Rationality Criterion**: A Kepler orbit `(a, μ)` with positive rational
    parameters has a rational period ratio iff `3·v_p(a) - v_p(μ)` is even
    for all primes p.
-/
theorem kepler_period_rational_iff_valuation_even (a μ : ℚ) (ha : 0 < a) (hμ : 0 < μ) :
    (∃ q : ℚ, 0 < q ∧ q ^ 2 * μ = a ^ 3) ↔
      (∀ p : ℕ, p.Prime → Even (3 * padicValRat p a - padicValRat p μ)) := by
  exact ⟨ fun h => kepler_period_rational_implies_valuation_even a μ ha hμ h, fun h => kepler_period_valuation_even_implies_rational a μ ha hμ h ⟩

/-! ## Section 5: PadicOrbitalInvariant -/

/-- The arithmetic fingerprint of a Kepler orbit: the p-adic valuation profile
    of the period ratio `a^(3/2)/μ^(1/2)` across all primes. -/
structure PadicOrbitalInvariant where
  a : ℚ  -- semi-major axis
  μ : ℚ  -- gravitational parameter
  ha : 0 < a
  hμ : 0 < μ
  hrat : ∃ q : ℚ, 0 < q ∧ q ^ 2 * μ = a ^ 3

namespace PadicOrbitalInvariant

/-- Extract the p-adic valuation at a specific prime.
    Returns `(3·v_p(a) - v_p(μ)) / 2`, stored as the even integer
    `3·v_p(a) - v_p(μ)` before division. -/
noncomputable def valuationAt (ι : PadicOrbitalInvariant) (p : ℕ) [Fact p.Prime] : ℤ :=
  (3 * padicValRat p ι.a - padicValRat p ι.μ) / 2

/-- The raw (undivided) valuation difference. -/
def rawValuation (ι : PadicOrbitalInvariant) (p : ℕ) [Fact p.Prime] : ℤ :=
  3 * padicValRat p ι.a - padicValRat p ι.μ

/-- The raw valuation is always even (by the rationality criterion). -/
theorem rawValuation_even (ι : PadicOrbitalInvariant) (p : ℕ) [hp : Fact p.Prime] :
    Even (ι.rawValuation p) := by
  obtain ⟨q, hq_pos, hq_eq⟩ := ι.hrat
  have := kepler_period_padic_valuation p ι.a ι.μ q ι.ha ι.hμ hq_pos hq_eq
  exact ⟨padicValRat p q, by unfold rawValuation; omega⟩

/-- Two orbits are arithmetically equivalent if they have the same p-adic profile. -/
def arithmeticEquiv (ι₁ ι₂ : PadicOrbitalInvariant) : Prop :=
  ∀ (p : ℕ) [Fact p.Prime], ι₁.valuationAt p = ι₂.valuationAt p

/-- Arithmetic equivalence is an equivalence relation. -/
theorem arithmeticEquiv_refl (ι : PadicOrbitalInvariant) : arithmeticEquiv ι ι :=
  fun _ _ => rfl

theorem arithmeticEquiv_symm {ι₁ ι₂ : PadicOrbitalInvariant}
    (h : arithmeticEquiv ι₁ ι₂) : arithmeticEquiv ι₂ ι₁ :=
  fun p _ => (h p).symm

theorem arithmeticEquiv_trans {ι₁ ι₂ ι₃ : PadicOrbitalInvariant}
    (h₁₂ : arithmeticEquiv ι₁ ι₂) (h₂₃ : arithmeticEquiv ι₂ ι₃) :
    arithmeticEquiv ι₁ ι₃ :=
  fun p _ => (h₁₂ p).trans (h₂₃ p)

end PadicOrbitalInvariant

/-! ## Section 6: Computable Valuation Profile -/

/-- Compute the p-adic valuation of the Kepler period ratio at prime p,
    assuming the period ratio exists. Returns `(3·v_p(a) - v_p(μ)) / 2`. -/
def keplerValuationAt (a μ : ℚ) (p : ℕ) [Fact p.Prime] : ℤ :=
  (3 * padicValRat p a - padicValRat p μ) / 2

/-- The computable valuation agrees with the structural definition. -/
theorem keplerValuationAt_eq_valuationAt (ι : PadicOrbitalInvariant) (p : ℕ) [Fact p.Prime] :
    keplerValuationAt ι.a ι.μ p = ι.valuationAt p := by
  rfl

/-
Correctness: if `q²·μ = a³`, then `keplerValuationAt a μ p = v_p(q)`.
-/
theorem keplerValuationAt_correct (p : ℕ) [Fact p.Prime]
    (a μ q : ℚ) (ha : 0 < a) (hμ : 0 < μ) (hq : 0 < q)
    (hkepler : q ^ 2 * μ = a ^ 3) :
    keplerValuationAt a μ p = padicValRat p q := by
  -- Use kepler_period_padic_valuation to get 2 * v_p(q) = 3 * v_p(a) - v_p(μ).
  have h_val : 2 * padicValRat p q = 3 * padicValRat p a - padicValRat p μ := by
    convert kepler_period_padic_valuation p a μ q ha hμ hq hkepler using 1;
  exact Int.ediv_eq_of_eq_mul_left ( by norm_num ) ( by linarith )

/-! ## Section 7: Concrete Examples -/

/-- Example: For the orbit a = 1, μ = 1, we have q = 1 and all valuations are 0. -/
example : keplerValuationAt 1 1 2 = 0 := by native_decide

/-- Example: For a = 4, μ = 8, we have q² · 8 = 64, so q = 2√2... not rational.
    But a = 4, μ = 1: q² = 64, q = 8, v_2(q) = 3. -/
example : keplerValuationAt 4 1 2 = 3 := by native_decide

/-- Example: a = 9, μ = 1: q² = 729 = 27², so q = 27, v_3(q) = 3. -/
example : keplerValuationAt 9 1 3 = 3 := by native_decide