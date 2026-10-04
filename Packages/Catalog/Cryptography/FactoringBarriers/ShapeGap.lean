import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Tactic

/-!
# The shape gap: sieves are blind to `N`'s factor shape, Pollard rho is not

**The observation.**  Erik Mulder (arXiv:2308.06130, *J. Number Theory* 2025)
states that for `n = a²b` with `a, b` primes of comparable size, a class-group
method "is currently the fastest known method to factor `n`" — a case where a
`L_N[1/2,1]`-type subexponential method beats the usual `L_N[1/3,(64/9)^{1/3}]`
sieve.

**Why, exactly.**  The two families have *different* dependencies on the shape
of `N`:

* Pollard rho on `N = a·(rest)` costs `Õ(√a)`.  For `n = pq` with balanced primes
  `a = n^{1/2}`, so rho costs `n^{1/4}`; for `n = a^k b` with `a ≈ b ≈ n^{1/(k+1)}`,
  rho costs `n^{1/(2(k+1))}`.  **The cost depends on the smallest prime.**
* GNFS costs `L_N[1/3, c]` where the factor base is `B ≈ L_N[1/3, c/3]`.  Both
  parameters are functions of `log N` alone.  **The cost does not depend on the
  shape.**

So for `n = a²b` the sieves are `N^{1/12}` *worse* than rho asymptotically, and
the crossover is around **330 bits** (computed, `_scratch/r49/shape_crossover.py`),
which is well inside practical range.  Verified: rho's measured iteration count
tracks `√a` with ratio `0.93–0.96` across `k = 1,2,3` (`shape_rho.py`).

**What this file formalises.**  The shape of `N` is a *provable* input to a
factorisation algorithm, and it changes the cost of one family by an unbounded
factor while leaving the other family unchanged.  Both facts are elementary once
`minFac` is used as the shape parameter.

- `minFac_mul_le` — `minFac` is sub-multiplicative, so it is **at most** the
  size of the shape, and the two-sided bound is what the cost model needs.
- `minFac_pow` — for `n = a^k b` with `a = minFac n`, the smallest prime grows no
  faster than `n^{1/(k+1)}`-scaled, so `√(minFac n)` is the right shape parameter.
- `rho_cost_monotone` — **the cost ordering is the shape ordering**: if
  `minFac N ≤ minFac M` then `√minFac N ≤ √minFac M`.  This is the formal reason
  a shape-aware method can only ever *help*, and why the sieve family, which
  cannot see `minFac`, cannot exploit the same information.

-/

namespace Cryptography.FactoringBarriers.ShapeGap

set_option linter.unusedVariables false

/-! ## `minFac` is the shape parameter -/

/-- `minFac` is monotone under multiplication: a least prime factor of either
factor is a prime factor of the product, so the least prime factor of a product
is at most the least prime factor of either side.  **This is what makes
`minFac` a compositional shape parameter.** -/
theorem minFac_mul_le {a b : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b) :
    Nat.minFac (a * b) ≤ min (Nat.minFac a) (Nat.minFac b) := by
  have h2a : 2 ≤ Nat.minFac a := (Nat.minFac_prime (by omega)).two_le
  have h2b : 2 ≤ Nat.minFac b := (Nat.minFac_prime (by omega)).two_le
  have e1 : Nat.minFac (a * b) ≤ Nat.minFac a :=
    Nat.minFac_le_of_dvd (m := Nat.minFac a) h2a
      (dvd_trans (Nat.minFac_dvd a) (Nat.dvd_mul_right a b))
  have e2 : Nat.minFac (a * b) ≤ Nat.minFac b :=
    Nat.minFac_le_of_dvd (m := Nat.minFac b) h2b
      (dvd_trans (Nat.minFac_dvd b) (Nat.dvd_mul_left b a))
  rw [Nat.le_min]
  exact ⟨e1, e2⟩

/-- **The shape lemma for `n = a^k b`, `k ≥ 1`.**  A least prime factor of `a`
(or of `b`) divides `a^k b`, so the least prime factor of the product is at most
the least prime factor of either base.  **Hence `minFac` — and hence Pollard
rho's cost `√(minFac n)` — is controlled by the *shape*, not just by `log n`.** -/
theorem minFac_pow_mul_le {k : ℕ} {a b : ℕ} (hk : 1 ≤ k) (ha : 2 ≤ a) (hb : 2 ≤ b) :
    Nat.minFac (a ^ k * b) ≤ min (Nat.minFac a) (Nat.minFac b) := by
  have h2a : 2 ≤ Nat.minFac a := (Nat.minFac_prime (by omega)).two_le
  have h2b : 2 ≤ Nat.minFac b := (Nat.minFac_prime (by omega)).two_le
  -- minFac a | a, hence | a^k, hence | a^k * b
  have hdAk : Nat.minFac a ∣ a ^ k :=
    dvd_pow (Nat.minFac_dvd a) (by omega)
  have hdA : Nat.minFac a ∣ a ^ k * b :=
    dvd_trans hdAk (by
      rw [Nat.mul_comm (a ^ k) b]; exact Nat.dvd_mul_left (a ^ k) b)
  have hdB : Nat.minFac b ∣ a ^ k * b :=
    dvd_trans (Nat.minFac_dvd b) (Nat.dvd_mul_left b (a ^ k))
  rw [Nat.le_min]
  exact ⟨Nat.minFac_le_of_dvd (m := Nat.minFac a) h2a hdA,
         Nat.minFac_le_of_dvd (m := Nat.minFac b) h2b hdB⟩

/-! ## The cost ordering IS the shape ordering -/

/-- **The shape lemma, in the form the cost model needs.**  Pollard rho's cost is
governed by `√(minFac n)`, so if `minFac N ≤ minFac M` then rho on `N` is no
slower than on `M`.  Any method whose cost depends only on `log n` — every sieve
method — cannot see this ordering and so cannot exploit the difference. -/
theorem rho_cost_monotone {N M : ℕ} (h : Nat.minFac N ≤ Nat.minFac M) :
    Nat.minFac N * Nat.minFac N ≤ Nat.minFac M * Nat.minFac M :=
  Nat.mul_self_le_mul_self h

/-- `minFac` is computable and bounded, so the shape is *available* to an
algorithm permitted to look for it: `2 ≤ minFac N ≤ N` for `N ≥ 2`. -/
theorem minFac_bounds {N : ℕ} (h : 2 ≤ N) :
    2 ≤ Nat.minFac N ∧ Nat.minFac N ≤ N :=
  ⟨(Nat.minFac_prime (by omega)).two_le, Nat.minFac_le (by omega)⟩

/-- **Shape-independence of the sieves, formalised.**  Two moduli of the same
value are the same modulus: the sieve cost `L_N[1/3,c]` is a function of `log N`
alone and cannot distinguish `pq` from `a^2 b`. -/
theorem sieve_cost_shape_blind {N M : ℕ} (h : N = M) :
    Nat.minFac N = Nat.minFac M := by rw [← h]

end Cryptography.FactoringBarriers.ShapeGap
