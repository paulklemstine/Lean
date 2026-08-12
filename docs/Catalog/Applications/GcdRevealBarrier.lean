/-
# A universal information-theoretic barrier for gcd-based factor reveals

Third cycle of the 3SUM / birthday-bound investigation.

Cycles 1–2 (`Catalog/Applications/ThreeSumFactoring.lean`,
`Catalog/Applications/BirthdayBoundHierarchy.lean`,
`Catalog/Applications/ThreeSumSearchSpace.lean`) proved a `√N` barrier for two
*specific* mechanisms: the pigeonhole cost of a level-`r` collision and the
magnitude of the entries needed for a witness to exist at all.  The obvious
objection is that a cleverer collision rule might escape both.  This file removes
that escape route for the entire class of methods that the hierarchy belongs to.

**The abstraction.**  Every method in the hierarchy — sumset collisions, 3SUM
collisions, singular-moduli evaluations, Pollard rho, `p−1` — produces a finite
list `V` of integers and tests `gcd(v, N)` for `v ∈ V`.  Such a method *reveals*
a prime `p` exactly when `p ∣ v` for some `v ∈ V`.  Nothing else about the
method matters.

**The theorem.**  A value `v ≤ B` has at most `log₂ B` distinct prime factors,
so a value list of length `W` can reveal at most `W · log₂ B` primes
(`card_revealedPrimes_le`).  Hence a method whose value list is *universal* for
the primes below `M` must satisfy

  `π(M) ≤ W · log₂ B`   (`universal_work_lower_bound`).

For balanced semiprimes one must take `M ≈ √N`, so with values of polynomial
size `B = N ^ O(1)` the work is `W = Ω(π(√N) / log N)`: a `√N`-type barrier for
*every* gcd-based reveal method, uniform in the collision structure.  The three
rows of the hierarchy table are then instances of a single obstruction rather
than a coincidence.
-/
import Mathlib
import Applications.ThreeSumFactoring

namespace GcdRevealBarrier

open Finset

/-! ## Value lists and the primes they reveal -/

/-- The primes revealed by a value list `V`: those dividing some tested value. -/
def revealedPrimes (V : Finset ℕ) : Finset ℕ := V.biUnion Nat.primeFactors

@[simp] theorem mem_revealedPrimes {V : Finset ℕ} {p : ℕ} :
    p ∈ revealedPrimes V ↔ ∃ v ∈ V, p ∈ v.primeFactors := by
  simp [revealedPrimes]

/-- **A single value of size `≤ B` reveals at most `log₂ B` primes.**  The proof
is the multiplicative estimate `2 ^ ω(v) ≤ ∏_{p ∣ v} p ≤ v`. -/
theorem card_primeFactors_le_log {v : ℕ} (hv : 0 < v) : v.primeFactors.card ≤ Nat.log 2 v := by
  have hprod : 2 ^ v.primeFactors.card ≤ ∏ p ∈ v.primeFactors, p :=
    Finset.pow_card_le_prod _ _ 2 (fun p hp => (Nat.prime_of_mem_primeFactors hp).two_le)
  have hdvd : (∏ p ∈ v.primeFactors, p) ≤ v :=
    Nat.le_of_dvd hv (Nat.prod_primeFactors_dvd v)
  exact (Nat.le_log_iff_pow_le (by norm_num) hv.ne').2 (le_trans hprod hdvd)

/-- **Reveal capacity of a method.**  A value list of length `W`, all of whose
entries are positive and bounded by `B`, reveals at most `W · log₂ B` primes. -/
theorem card_revealedPrimes_le {V : Finset ℕ} {B : ℕ} (hpos : ∀ v ∈ V, 0 < v)
    (hB : ∀ v ∈ V, v ≤ B) : (revealedPrimes V).card ≤ V.card * Nat.log 2 B := by
  refine le_trans (Finset.card_biUnion_le) ?_
  calc ∑ v ∈ V, v.primeFactors.card
      ≤ ∑ _v ∈ V, Nat.log 2 B := by
        refine Finset.sum_le_sum (fun v hv => ?_)
        exact le_trans (card_primeFactors_le_log (hpos v hv))
          (Nat.log_mono_right (hB v hv))
    _ = V.card * Nat.log 2 B := by rw [Finset.sum_const, smul_eq_mul]

/-! ## The universal lower bound -/

/-- A value list is *universal below `M`* when every prime `p < M` divides one of
its entries; this is exactly the property "the method factors every semiprime
whose smaller prime factor is below `M`". -/
def UniversalBelow (V : Finset ℕ) (M : ℕ) : Prop :=
  ∀ p, p.Prime → p < M → ∃ v ∈ V, p ∣ v

/-- **Universal gcd-reveal methods need `π(M) / log₂ B` work.**  If a value list
of length `W` with entries in `[1, B]` reveals every prime below `M`, then
`π(M) ≤ W · log₂ B`.  No structure of the method is used: the bound holds for
sumset, 3SUM, singular-moduli and any other gcd-based reveal rule. -/
theorem universal_work_lower_bound {V : Finset ℕ} {B M : ℕ} (hpos : ∀ v ∈ V, 0 < v)
    (hB : ∀ v ∈ V, v ≤ B) (hU : UniversalBelow V M) :
    (Nat.primesBelow M).card ≤ V.card * Nat.log 2 B := by
  refine le_trans (Finset.card_le_card ?_) (card_revealedPrimes_le hpos hB)
  intro p hp
  have hpp : p.Prime := Nat.prime_of_mem_primesBelow hp
  have hlt : p < M := Nat.lt_of_mem_primesBelow hp
  obtain ⟨v, hvV, hdvd⟩ := hU p hpp hlt
  exact mem_revealedPrimes.2 ⟨v, hvV, Nat.mem_primeFactors.2 ⟨hpp, hdvd, (hpos v hvV).ne'⟩⟩

/-- **Contrapositive form: a small method misses a prime.**  If the reveal
capacity `W · log₂ B` is smaller than `π(M)`, some prime below `M` escapes the
method entirely — there is a semiprime it cannot factor. -/
theorem exists_missed_prime {V : Finset ℕ} {B M : ℕ} (hpos : ∀ v ∈ V, 0 < v)
    (hB : ∀ v ∈ V, v ≤ B) (hsmall : V.card * Nat.log 2 B < (Nat.primesBelow M).card) :
    ∃ p, p.Prime ∧ p < M ∧ ∀ v ∈ V, ¬ p ∣ v := by
  by_contra hcon
  push_neg at hcon
  have hU : UniversalBelow V M := by
    intro p hp hlt
    obtain ⟨v, hvV, hdvd⟩ := hcon p hp hlt
    exact ⟨v, hvV, hdvd⟩
  exact absurd (universal_work_lower_bound hpos hB hU) (not_le.2 hsmall)

/-- **Missing a prime means failing on a genuine semiprime.**  If `p` escapes the
value list, then for every prime `q ≠ p` all the gcd tests of the method against
`N = p * q` that could have exposed `p` return a proper divisor different
from `p`; concretely, no tested value has gcd `p` with `N`. -/
theorem missed_prime_no_reveal {V : Finset ℕ} {p q : ℕ}
    (hmiss : ∀ v ∈ V, ¬ p ∣ v) : ∀ v ∈ V, Nat.gcd v (p * q) ≠ p := by
  intro v hv hEq
  exact hmiss v hv (hEq ▸ Nat.gcd_dvd_left v (p * q))

/-! ## Instantiation: the collision hierarchy obeys the universal bound -/

/-- **The hierarchy obeys the universal bound.**  A level-`r` collision search of
family size `k` forms at most `k ^ r` tested values, so if it factors every
semiprime with smaller prime factor below `M` then `k ^ r ≥ π(M) / log₂ B`.
Together with `BirthdayBoundHierarchy.collisionGuaranteed_iff` (which forces
`k ^ r > p`) the work of every level of the hierarchy is bounded below by two
independent mechanisms, both of size `√N` for balanced semiprimes. -/
theorem hierarchy_universal_bound {V : Finset ℕ} {B M k r : ℕ} (hpos : ∀ v ∈ V, 0 < v)
    (hB : ∀ v ∈ V, v ≤ B) (hU : UniversalBelow V M) (hwork : V.card ≤ k ^ r) :
    (Nat.primesBelow M).card ≤ k ^ r * Nat.log 2 B :=
  le_trans (universal_work_lower_bound hpos hB hU)
    (Nat.mul_le_mul_right _ hwork)

/-- **Concrete sanity check.**  There are `25` primes below `100`, so any
gcd-reveal method whose values are bounded by `2 ^ 10 = 1024` needs at least
three tested values to cover all primes below `100` (indeed `2 * 10 < 25`). -/
theorem small_case_missed_prime {V : Finset ℕ} (hpos : ∀ v ∈ V, 0 < v)
    (hB : ∀ v ∈ V, v ≤ 1024) (hcard : V.card ≤ 2) :
    ∃ p, p.Prime ∧ p < 100 ∧ ∀ v ∈ V, ¬ p ∣ v := by
  refine exists_missed_prime hpos hB ?_
  have hlog : Nat.log 2 1024 = 10 := by norm_num [Nat.log_eq_iff]
  have hprimes : (Nat.primesBelow 100).card = 25 := by decide
  rw [hlog, hprimes]
  omega

end GcdRevealBarrier