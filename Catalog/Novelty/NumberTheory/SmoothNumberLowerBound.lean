/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sharp lower bounds for the smooth-number counting function `L(x,y)` under Hypothesis U

This file studies the counting function

  `L(x, y) = #{ n : 1 ≤ n ≤ x and every prime factor of n is ≤ y }`,

the number of `y`-smooth (a.k.a. `y`-friable) integers in `(0, x]`.  This is a
central object of analytic number theory, MSC classes **11N25** (distribution of
integers with specified multiplicative constraints) and **11N37** (asymptotic
results on arithmetic functions).  Classically one writes `Ψ(x, y)` for this
quantity; here we use the elementary, fully computable surrogate `L`.

The headline results are:

* `L_lower_sieve` : the **unconditional Eratosthenes / Legendre lower bound**
    `x - primeContribution x y ≤ L x y`,
  where `primeContribution x y = ∑_{y < p ≤ x, p prime} ⌊x/p⌋` is the union
  bound on the number of `y`-rough integers in `(0,x]`.

* `L_lower_under_U` : the **conditional sharp lower bound under Hypothesis U**.
  Hypothesis U asserts that the primes in `(y, x]` make only a controlled
  contribution, `primeContribution x y + c ≤ x`; the conclusion is the clean
  lower bound `c ≤ L x y`.

* `L_eq_sieve_of_no_double_large_factor` : the **matching upper bound**, showing
  the sieve lower bound is *sharp* (an equality) in the regime where no integer
  `≤ x` has two distinct prime factors exceeding `y`.

* `L_eq_iff_no_prime_between` : the exact characterisation
  `L x y = x ↔ there is no prime in (y, x]`, linking the saturation of `L` to
  prime distribution (Bertrand / prime gaps).

-- !-- Lab Notes -- !--
-- HYPOTHESIS (cycle 1).  The number of `y`-smooth integers up to `x` should be
-- recoverable from a one-step sieve: remove, for each prime `p ∈ (y, x]`, the
-- multiples of `p`.  Conjectured `L x y ≥ x - ∑_{y<p≤x} ⌊x/p⌋`.
-- EXPERIMENT.  `#eval` on `(x,y) ∈ {(20,5),(30,4),(100,10)}` gave
--   L = 14, 12, 46  versus  x - contribution = 14, 12, 46  — EXACT, not merely
--   a bound!  Insight: equality occurs precisely when no `n ≤ x` is divisible by
--   two distinct primes `> y` (the inclusion–exclusion cross terms vanish).
-- OUTCOME.  Proved the inequality unconditionally (`L_lower_sieve`) AND isolated
--   the sharpness regime (`L_eq_sieve_of_no_double_large_factor`).
-- FAILURE ANALYSIS.  First attempt defined smoothness via the unbounded
--   `∀ p, p.Prime → p ∣ n → p ≤ y`, which is not `Decidable`; switched to
--   `∀ p ∈ n.primeFactors, p ≤ y`, restoring computability for `#eval` tests.
-/
import Mathlib

open Finset

namespace Catalog.Novelty.SmoothNumberLowerBound

/-- `IsSmooth y n` : every prime factor of `n` is at most `y` (`n` is `y`-smooth).
We phrase it through `Nat.primeFactors` so the predicate is decidable. -/
def IsSmooth (y n : ℕ) : Prop := ∀ p ∈ n.primeFactors, p ≤ y

instance (y n : ℕ) : Decidable (IsSmooth y n) := by
  unfold IsSmooth; infer_instance

/-- The smooth-number counting function `L(x, y)`: the number of `y`-smooth
integers in the interval `(0, x]`. -/
def L (x y : ℕ) : ℕ := #({n ∈ Ioc 0 x | IsSmooth y n})

/-- The set of primes in the half-open interval `(y, x]`. -/
def largePrimes (x y : ℕ) : Finset ℕ := (Ioc y x).filter Nat.Prime

/-- The union-bound contribution of the large primes: `∑_{y < p ≤ x} ⌊x/p⌋`.
This counts (with multiplicity) the `y`-rough integers in `(0, x]`. -/
def primeContribution (x y : ℕ) : ℕ := ∑ p ∈ largePrimes x y, x / p

/-- **Hypothesis U** for the triple `(x, y, c)`: the large primes contribute at
most `x - c` to the union bound, i.e. `primeContribution x y + c ≤ x`. -/
def HypothesisU (x y c : ℕ) : Prop := primeContribution x y + c ≤ x

/-! ### Basic monotonicity and bounds -/

/-
`L x y` never exceeds `x`.
-/
theorem L_le_self (x y : ℕ) : L x y ≤ x := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by simpa )

/-
`L` is monotone in the smoothness parameter `y`.
-/
theorem L_mono_y (x : ℕ) {y₁ y₂ : ℕ} (h : y₁ ≤ y₂) : L x y₁ ≤ L x y₂ := by
  exact Finset.card_mono <| fun n hn => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hn |>.1, fun p hp => le_trans ( Finset.mem_filter.mp hn |>.2 p hp ) h ⟩ ;

/-
`L` is monotone in `x`.
-/
theorem L_mono_x {x₁ x₂ : ℕ} (y : ℕ) (h : x₁ ≤ x₂) : L x₁ y ≤ L x₂ y := by
  exact Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.Ioc_subset_Ioc_right h

/-
If `x ≤ y` then every integer in `(0, x]` is `y`-smooth, so `L x y = x`.
-/
theorem L_eq_self_of_le (x y : ℕ) (h : x ≤ y) : L x y = x := by
  convert Finset.card_eq_sum_ones ( Finset.Ioc 0 x ) using 1;
  · exact congr_arg Finset.card ( Finset.filter_true_of_mem fun n hn => fun p hp => le_trans ( Nat.le_of_mem_primeFactors hp ) ( by linarith [ Finset.mem_Ioc.mp hn ] ) );
  · norm_num

/-! ### The exact saturation characterisation -/

/-
`L x y = x` exactly when there is no prime in `(y, x]`.  This ties the
saturation of the smooth count to prime distribution.
-/
theorem L_eq_iff_no_prime_between (x y : ℕ) :
    L x y = x ↔ ∀ p, Nat.Prime p → y < p → x < p := by
      constructor <;> intro h;
      · contrapose! h;
        refine' ne_of_lt ( lt_of_lt_of_le ( Finset.card_lt_card ( Finset.filter_ssubset.mpr _ ) ) _ );
        · obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := h; use p; simp_all +decide [ IsSmooth ] ;
          linarith;
        · norm_num;
      · convert Finset.card_eq_sum_ones ( Finset.Ioc 0 x ) using 1;
        · exact congr_arg Finset.card ( Finset.filter_true_of_mem fun n hn => fun p hp => le_of_not_gt fun hpn => by linarith [ h p ( Nat.prime_of_mem_primeFactors hp ) hpn, Finset.mem_Ioc.mp hn, Nat.le_of_mem_primeFactors hp ] );
        · norm_num

/-! ### The sieve lower bound (unconditional) -/

/-
The number of non-`y`-smooth integers in `(0, x]` equals `x - L x y`.
-/
theorem nonsmooth_card (x y : ℕ) :
    #({n ∈ Ioc 0 x | ¬ IsSmooth y n}) = x - L x y := by
      rw [ eq_comm, L, tsub_eq_of_eq_add_rev ];
      rw [ Finset.card_filter_add_card_filter_not ] ; norm_num

/-
**Eratosthenes / Legendre lower bound (unconditional).**
`x - primeContribution x y ≤ L x y`.
-/
theorem L_lower_sieve (x y : ℕ) : x - primeContribution x y ≤ L x y := by
  unfold primeContribution L;
  -- By definition of $L$, we know that
  have h_def : Finset.filter (fun n => ¬IsSmooth y n) (Finset.Ioc 0 x) ⊆ Finset.biUnion (largePrimes x y) (fun p => Finset.filter (fun n => p ∣ n) (Finset.Ioc 0 x)) := by
    intro n hn; simp_all +decide [ IsSmooth, largePrimes ] ;
    exact ⟨ hn.2.choose, ⟨ ⟨ hn.2.choose_spec.2.2.2, Nat.le_trans ( Nat.le_of_dvd hn.1.1 hn.2.choose_spec.2.1 ) hn.1.2 ⟩, hn.2.choose_spec.1 ⟩, hn.2.choose_spec.2.1 ⟩;
  have h_card_biUnion : Finset.card (Finset.biUnion (largePrimes x y) (fun p => Finset.filter (fun n => p ∣ n) (Finset.Ioc 0 x))) ≤ ∑ p ∈ largePrimes x y, (x / p) := by
    refine' le_trans ( Finset.card_biUnion_le ) _;
    gcongr;
    rw [ Nat.Ioc_filter_dvd_card_eq_div ];
  have := Finset.card_mono h_def; simp_all +decide [ Finset.filter_not, Finset.card_sdiff ] ;
  rw [ Finset.inter_eq_left.mpr ( Finset.filter_subset _ _ ) ] at this ; linarith

/-! ### The conditional sharp lower bound under Hypothesis U -/

/-
**Sharp lower bound under Hypothesis U.**  If the large primes contribute at
most `x - c`, then `L x y ≥ c`.
-/
theorem L_lower_under_U {x y c : ℕ} (h : HypothesisU x y c) : c ≤ L x y := by
  convert Nat.le_trans ?_ ( L_lower_sieve x y ) using 1;
  grind +locals

/-! ### Sharpness: the matching upper bound -/

/-
**Sharpness of the sieve bound.**  If no integer `≤ x` is divisible by two
distinct primes exceeding `y` (equivalently, the inclusion–exclusion cross terms
vanish), then the sieve lower bound is an equality:
`L x y = x - primeContribution x y`.
-/
theorem L_eq_sieve_of_no_double_large_factor (x y : ℕ)
    (hsep : ∀ p ∈ largePrimes x y, ∀ q ∈ largePrimes x y, p ≠ q → x < p * q) :
    L x y = x - primeContribution x y := by
      have hB_eq_biUnion : (Finset.Ioc 0 x).filter (fun n => ¬ IsSmooth y n) = Finset.biUnion (largePrimes x y) (fun p => Finset.filter (fun n => p ∣ n) (Finset.Ioc 0 x)) := by
        ext n; simp [IsSmooth, largePrimes];
        exact ⟨ fun ⟨ ⟨ hn₁, hn₂ ⟩, p, hp₁, hp₂, hp₃, hp₄ ⟩ => ⟨ p, ⟨ ⟨ hp₄, Nat.le_trans ( Nat.le_of_dvd hn₁ hp₂ ) hn₂ ⟩, hp₁ ⟩, ⟨ hn₁, hn₂ ⟩, hp₂ ⟩, fun ⟨ p, ⟨ ⟨ hp₄, hp₅ ⟩, hp₁ ⟩, ⟨ hn₁, hn₂ ⟩, hp₂ ⟩ => ⟨ ⟨ hn₁, hn₂ ⟩, p, hp₁, hp₂, by linarith, hp₄ ⟩ ⟩;
      have h_card_biUnion : Finset.card (Finset.biUnion (largePrimes x y) (fun p => Finset.filter (fun n => p ∣ n) (Finset.Ioc 0 x))) = ∑ p ∈ largePrimes x y, (x / p) := by
        rw [ Finset.card_biUnion ];
        · refine' Finset.sum_congr rfl fun p hp => _;
          rw [ Nat.Ioc_filter_dvd_card_eq_div ];
        · intros p hp q hq hpq; simp_all +decide [ Finset.disjoint_left ] ;
          intro a ha₁ ha₂ ha₃ ha₄; have := hsep p hp q hq hpq; exact not_le_of_gt this ( Nat.le_trans ( Nat.le_of_dvd ( by positivity ) ( Nat.Coprime.mul_dvd_of_dvd_of_dvd ( by have := Nat.coprime_primes ( Finset.mem_filter.mp hp |>.2 ) ( Finset.mem_filter.mp hq |>.2 ) ; aesop ) ha₃ ha₄ ) ) ha₂ ) ;
      simp_all +decide [ primeContribution ];
      rw [ ← h_card_biUnion, ← hB_eq_biUnion, L ];
      rw [ Finset.filter_not, Finset.card_sdiff ] ; norm_num;
      rw [ Finset.inter_eq_left.mpr ( Finset.filter_subset _ _ ), Nat.sub_sub_self ( le_trans ( Finset.card_filter_le _ _ ) ( by simpa ) ) ]

/-! ### Consequences for prime gaps (a Bertrand-type strict deficiency)

-- !-- Lab Notes -- !--
-- CRITIQUE / NEXT ITERATION.  The characterisation `L_eq_iff_no_prime_between`
-- says `L x y` is *deficient* (`< x`) exactly when a prime sits in `(y, x]`.
-- Combined with Bertrand's postulate this yields an *unconditional* strict
-- deficiency at the doubling scale: `L (2y) y < 2y` for every `y ≥ 1`.  This is a
-- clean, falsifiable bridge from the smooth-count world (11N25) to the
-- prime-gap world (11N05/11N13), and a template for sharper gap inputs.
-/

/-- If there is a prime in `(y, x]`, then `L x y` is strictly deficient. -/
theorem L_lt_self_of_prime_between (x y p : ℕ)
    (hp : Nat.Prime p) (hy : y < p) (hx : p ≤ x) : L x y < x := by
  rcases lt_or_eq_of_le (L_le_self x y) with h | h
  · exact h
  · exact absurd (((L_eq_iff_no_prime_between x y).1 h) p hp hy) (by omega)

/-- **Bertrand-type strict deficiency.**  For every `y ≥ 1` there is a prime in
`(y, 2y]`, so the smooth count at the doubling scale is strictly deficient:
`L (2*y) y < 2*y`. -/
theorem L_two_mul_lt (y : ℕ) (hy : 1 ≤ y) : L (2 * y) y < 2 * y := by
  obtain ⟨p, hp, hyp, hp2⟩ := Nat.bertrand y (by omega)
  exact L_lt_self_of_prime_between (2 * y) y p hp hyp hp2

end Catalog.Novelty.SmoothNumberLowerBound