# FUTURE DIRECTIONS — Tropical p-adic Valuation Profile of Fibonacci Numbers

Cycle output: `Catalog/Speculative/AutoResearch/FibonacciValuationProfile.lean`
(self-contained, 0 sorries, axioms ⊆ {propext, Classical.choice, Quot.sound,
Lean.ofReduceBool, Lean.trustCompiler}).

This cycle established that the Fibonacci p-adic valuation profile
`n ↦ v_p(F_n)` is a **tropical (min-plus) homomorphism for `gcd`**
(`padicValNat_fib_gcd_min`), is monotone along divisibility, satisfies a one-sided
`lcm` bound, but is **not** a homomorphism for `lcm`
(`padicValNat_fib_lcm_max_not_general`), and that its support is exactly the set of
multiples of the rank of apparition (`fibRank_dvd_iff`, `padicValNat_fib_support`).

Below are bold, testable conjectures for follow-up cycles.

## FD-1. Affine valuation profile (exact LTE form)
For an odd prime `p` with rank of apparition `r = fibRank p`, the profile is **affine**
on its support:
```
∀ n, r ∣ n → padicValNat p (Nat.fib n) = padicValNat p (Nat.fib r) + padicValNat p (n / r).
```
*Testability:* directly checkable numerically; the catalog already contains a coprime-case
LTE lemma (`fib_lte` in the `Tropical_p_adic_..._Fibonacci_Primitive_Divisors` file). The
conjecture is the full (non-coprime) statement. The `p = 2` case needs a separate correction
term and is part of the conjecture (state and verify the 2-adic variant separately).

## FD-2. Closed form for the `lcm` defect
The failure of the `max` identity (`padicValNat_fib_lcm_max_not_general`) is governed by LTE.
Conjecture: for an odd prime `p` with `r = fibRank p` dividing `lcm m n`,
```
padicValNat p (Nat.fib (Nat.lcm m n))
  = padicValNat p (Nat.fib r) + max (padicValNat p (m / r')) (padicValNat p (n / r'))   ?
```
More cleanly: the defect `v_p(F_lcm(m,n)) − max(v_p F_m, v_p F_n)` is a nonnegative function
of `v_p(lcm m n) − max(v_p m, v_p n)` only. *Testability:* enumerate `(p,m,n)` and fit; then
formalize. Witness `p=2,m=3,n=4` gives defect `4 − 1 = 3` and must be reproduced by the formula.

## FD-3. Tropical convolution / valuation–skeleton duality
Package the profile across all primes as `n ↦ (Nat.fib n).factorization`. The proven identity
`(F_{gcd(m,n)}).factorization = (F_m).factorization ⊓ (F_n).factorization` says this map sends
`gcd` to the tropical (pointwise-`min`) meet. Conjecture: it is a **lattice homomorphism**
`(ℕ_{≥1}, gcd, lcm)` → `(Finsupp ℕ ℕ, ⊓, ⊔)` for `gcd`/`⊓` but only a `⊔`-**sub**homomorphism
for `lcm`, with the obstruction class living in the valuation-skeleton duality framework of
`Bridges/ValuationSkeletonDuality`. *Testability:* the `⊓` half is proved; the `⊔` direction
fails (FD-2) and the obstruction should be a well-defined cocycle — compute it on small cases.

## FD-4. Carmichael's composite tail via a primitive-part size bound
The open `n > 10000` tail of `fib_carmichael_composite` (a `sorry` in
`Shared/CarmichaelProof.lean`) should reduce, via the support characterization
`fibRank_eq_of_primitive`, to a single growth inequality: `F_n` has a primitive prime divisor
iff the *primitive part* `Φ_n := F_n / ∏_{d∣n, d<n} (imprimitive contribution)` exceeds the
bounded imprimitive contribution. Conjecture: for composite `n ≥ 13`,
```
Φ_n  >  (largest prime factor of n) ,
```
which combined with `fibRank_eq_of_primitive` yields a primitive divisor. *Testability:* the
inequality is finite-checkable for a long initial range and then provable from
`fib_exponential_lower_bound` (already in the catalog) since `Φ_n ≥ α^{φ(n)}/n` grows
super-polynomially while the largest prime factor of `n` is `≤ n`.

## FD-5. Strong-divisibility universality
Every result here used only: (i) strong divisibility `gcd(F_m,F_n)=F_{gcd(m,n)}`, and
(ii) `m ∣ n → F_m ∣ F_n`. Conjecture: the gcd↦min tropical identity, monotonicity, the
one-sided lcm bound, and the support/rank characterization hold **verbatim** for *every*
strong divisibility sequence — in particular all Lucas sequences `U_n(P,Q)` with
`gcd(P,Q)=1`, and the catalog's `Bridges/StrongDivisibilitySequences`. *Testability:* abstract
the proofs over a typeclass `StrongDivisibilitySequence` and re-derive
`padicValNat_*_gcd_min`, `*_dvd_mono`, `fibRank_dvd_iff`; then instantiate at Fibonacci,
Lucas, and `a^n - b^n`. Characterize exactly which sequences also fail the `lcm`↦`max` identity.
