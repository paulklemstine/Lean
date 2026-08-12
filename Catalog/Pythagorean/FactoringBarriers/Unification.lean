import Pythagorean.FactoringBarriers.PolynomialBarrier
import Pythagorean.FactoringBarriers.SymmetryBarrier
import Pythagorean.FactoringBarriers.HolomorphicRigidity

/-!
# Synthesis: how the three factoring barriers interact

Barrier I (algebraic), Barrier II (group-theoretic) and Barrier III (analytic) are
proved in the three companion files.  Here we prove the *bridges* between them and
establish that they are genuinely different obstructions.

* `FactoringBarriers.prime_root_mem_revealedPrimes` and
  `FactoringBarriers.device_size_lower_bound` bridge **III → I**: an analytic device
  which is an integer polynomial and vanishes at a prime factor `p` must have `p`
  dividing its constant term, so the device's constant term is at least as large as
  the secret prime.  "Encoding the zero" costs as much as knowing the factor.

* `FactoringBarriers.polyWitness_computableFromProduct` bridges **I → II**: every
  gcd-witness is a function of `N` alone, hence a symmetric function of `(p, q)`, so
  Barrier I methods are automatically subject to Barrier II.

* `FactoringBarriers.polyWitness_ne_min` proves **II ↛ I**: the smallest prime factor
  passes Barrier II (it is symmetric, hence an abstract function of `N`), yet no
  polynomial gcd-witness computes it.  The two barriers therefore cut along different
  lines, and Barrier II alone is not a hardness statement.

* `FactoringBarriers.three_barriers` packages the three conclusions for a single
  modulus.
-/

namespace FactoringBarriers

open Polynomial Complex MeasureTheory

/-! ### Bridge III → I : an integral analytic device pays for its zeros -/

/-- If an integer polynomial vanishes at a prime `p`, then `p` divides its constant
term, i.e. `p` is one of the finitely many primes the invariant already "knows". -/
theorem prime_root_mem_revealedPrimes {f : ℤ[X]} {p : ℕ} (hp : p.Prime)
    (hf : f.eval 0 ≠ 0) (hroot : f.eval (p : ℤ) = 0) : p ∈ revealedPrimes f := by
  refine mem_revealedPrimes_of_splits_prime (N := p) hf hp dvd_rfl ?_
  rw [hroot]
  exact dvd_zero _

/-- **The device is at least as big as the secret.**  An integer polynomial whose
complex zero set contains a prime factor `p` has constant term of absolute value at
least `p`.  Hence writing down an analytic factoring device with the prime factors as
zeros already requires objects of the size of the factors themselves: the
"evaluation circularity" of Barrier III, in quantitative arithmetic form. -/
theorem device_size_lower_bound {f : ℤ[X]} {p : ℕ} (hp : p.Prime) (hf : f.eval 0 ≠ 0)
    (hroot : f.eval (p : ℤ) = 0) : p ≤ (f.eval 0).natAbs := by
  have hmem : p ∈ revealedPrimes f := prime_root_mem_revealedPrimes hp hf hroot
  have hdvd : p ∣ (f.eval 0).natAbs := (Nat.mem_primeFactors.mp hmem).2.1
  have hpos : 0 < (f.eval 0).natAbs := by
    simpa [Int.natAbs_pos] using hf
  exact Nat.le_of_dvd hpos hdvd

/-- A fixed integer polynomial can have at most `log₂ |f(0)|` primes among its roots:
the analytic "zero-set" strategy has a hard information budget. -/
theorem card_prime_roots_le_log {f : ℤ[X]} (hf : f.eval 0 ≠ 0) {S : Finset ℕ}
    (hS : ∀ p ∈ S, p.Prime ∧ f.eval (p : ℤ) = 0) :
    S.card ≤ Nat.log 2 (f.eval 0).natAbs := by
  have hsub : S ⊆ revealedPrimes f := by
    intro p hpS
    obtain ⟨hp, hroot⟩ := hS p hpS
    exact prime_root_mem_revealedPrimes hp hf hroot
  exact le_trans (Finset.card_le_card hsub) (card_revealedPrimes_le_log f hf)

/-! ### Bridge I → II : polynomial witnesses are symmetric -/

/-- Every polynomial gcd-witness is a function of the modulus alone, hence a symmetric
function of the two prime factors.  Barrier I methods are thus a special case of the
symmetric world isolated by Barrier II. -/
theorem polyWitness_computableFromProduct (f : ℤ[X]) :
    ComputableFromProduct (fun p q : ℕ => polyWitness f (p * q)) :=
  ⟨fun N => polyWitness f N, fun _ _ _ _ => rfl⟩

/-! ### Independence: Barrier II does not imply Barrier I -/

/-- **The symmetric world is strictly larger than the polynomial world.**  The
smaller prime factor `min p q` is symmetric, so by the Barrier II dichotomy it *is* an
abstract function of `N`; nevertheless no polynomial gcd-witness computes it.  This
shows the two barriers are independent, and that Barrier II by itself is a
well-definedness constraint rather than a hardness theorem. -/
theorem polyWitness_ne_min (f : ℤ[X]) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p ≠ q → polyWitness f (p * q) = min p q := by
  intro h
  refine no_universal_polynomial_witness f ?_
  rintro N ⟨p, q, hp, hq, hne, rfl⟩
  have hval := h p q hp hq hne
  have hp2 : 2 ≤ p := hp.two_le
  have hq2 : 2 ≤ q := hq.two_le
  have hmin_lt : min p q < p * q := by
    have h1 : min p q ≤ p := Nat.min_le_left p q
    have h2 : p * 2 ≤ p * q := Nat.mul_le_mul_left p hq2
    omega
  have hmin_gt : 1 < min p q := by
    have := Nat.le_min.mpr ⟨hp2, hq2⟩
    omega
  exact ⟨by rw [hval]; exact hmin_gt, by rw [hval]; exact hmin_lt⟩

/-- The abstract (symmetric) recovery of the smaller factor does exist, in contrast:
Barrier II is passed by `min`. -/
theorem min_passes_symmetry_barrier :
    ComputableFromProduct (fun p q : ℕ => min p q) := min_computable_from_product

/-! ### The combined statement -/

/-- **The three barriers, together.**  For any semiprime `N = p q` with distinct
primes:

1. *(algebraic)* every polynomial invariant collapses: `gcd(f(N), N) = gcd(f(0), N)`,
   and no finite family of such invariants splits every semiprime;
2. *(group-theoretic)* the antisymmetric part of the factor data — here the gap
   `p - q` — is not a function of `N`;
3. *(analytic)* an entire device with zero set exactly `{p, q}` exists but is forced
   to be the factor polynomial times an entire function, and its zero set is
   Lebesgue-null, so it can neither be built without the factors nor found by
   search. -/
theorem three_barriers {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (f : ℤ[X]) :
    IsDistinctSemiprime (p * q) ∧
    (polyWitness f (p * q) = Int.gcd (f.eval 0) ((p * q : ℕ) : ℤ)) ∧
    (¬ ∀ N : ℕ, IsDistinctSemiprime N → Splits f N) ∧
    (¬ ComputableFromProduct (fun a b : ℕ => (a : ℤ) - (b : ℤ))) ∧
    (∃ F : ℂ → ℂ, Differentiable ℂ F ∧ F ≠ 0 ∧
      {z : ℂ | F z = 0} = {(p : ℂ), (q : ℂ)} ∧
      volume {z : ℂ | F z = 0} = 0 ∧
      ∃ G : ℂ → ℂ, Differentiable ℂ G ∧ ∀ z, F z = (z - p) * (z - q) * G z) := by
  refine ⟨⟨p, q, hp, hq, hpq, rfl⟩, polyWitness_eq_gcd_const f (p * q),
    no_universal_polynomial_witness f,
    prime_gap_not_computable, ?_⟩
  obtain ⟨F, hFdiff, hFne, hFzero⟩ := exists_entire_with_prescribed_prime_zeros p q
  obtain ⟨hvol, G, hG, hfac⟩ := holomorphic_rigidity_barrier hFdiff hpq hFzero
  exact ⟨F, hFdiff, hFne, hFzero, hvol, G, hG, hfac⟩

end FactoringBarriers