# Future Directions — Korselt's Criterion & the Multiplicative-Order Bridge

Derived from the research cycle that produced
`Catalog/Shared/KorseltCriterion.lean` (the full Korselt **iff** and its
arbitrary-exponent generalization) and
`Catalog/Cryptography/KorseltGroupActionBridge.lean` (the order/exponent-collapse
bridge into group actions).

This cycle proved, unconditionally:

* **C1** — Korselt's criterion is an iff: for `n > 1`,
  `IsAbsFermatPsp n ↔ IsKorselt n` (`korselt_iff_absFermatPsp`), with the hard
  squarefree converse `squarefree_of_forall_units_pow_one` via Cauchy on
  `(ℤ/p²ℤ)ˣ`.
* **C2** — Generalized Korselt: for squarefree `n` and *any* exponent `e`,
  `(∀ u : (ℤ/nℤ)ˣ, u ^ e = 1) ↔ ∀ p ∣ n prime, (p − 1) ∣ e`
  (`generalized_korselt`, `generalized_korselt_modEq`).
* **C4/C5** — Order/exponent collapse: `Monoid.exponent (ℤ/nℤ)ˣ ∣ (n − 1)` and
  `≤ n − 1` for Korselt `n` (`korselt_exponent_dvd`, `korselt_exponent_le`); the
  "exponentiate-by-`n−1`" map is the identity on every torsor, with an iff for the
  regular action (`korselt_iff_regular_pow_trivial`).

The analysis below lists the next falsifiable steps.

## D1 — The Carmichael lambda is exactly the per-prime lcm

**Conjecture.** For squarefree `n`,
`Monoid.exponent (ℤ/nℤ)ˣ = Nat.lcm’ {p − 1 : p prime, p ∣ n}` (the Carmichael
function `λ(n)`), and `IsKorselt n ↔ λ(n) ∣ (n − 1)`.

**The key insight is** that `generalized_korselt` already characterizes the set of
*all* exponents `e` killing every unit as exactly `{e : ∀ p ∣ n, (p−1) ∣ e}`; the
monoid exponent is the least positive such `e`, which is by definition the lcm of
the `p − 1`.

**Why now?** Both inequalities are within reach: `forall_units_pow_one_of_korselt`
gives `λ ∣ lcm`, and `prime_sub_one_dvd_of_forall_units_pow_one` applied to
`e := Monoid.exponent` gives `(p−1) ∣ λ`, hence `lcm ∣ λ`.

## D2 — Korselt numbers have at least three prime factors

**Conjecture.** Every Korselt (Carmichael) number is a product of at least three
distinct odd primes; in particular no Korselt number is even and none is a product
of two primes.

**The key insight is** that `korselt_orderOf_dvd` forces `(p − 1) ∣ (n − 1)` for
each prime factor while `p ∣ n` forces `p ∤ (n − 1)`; combining these parity/size
constraints across few prime factors yields a contradiction (the classical
Korselt count argument), now phrased over the order spectrum of `∏ (ℤ/pℤ)ˣ`.

**Why now?** The squarefree converse and `(p − 1) ∣ (n − 1)` are both established,
so the only missing ingredient is a finite case analysis on the number of prime
factors — pure `omega`/`Nat` arithmetic on the proven divisibilities.

## D3 — Order-collapse density and a single-witness Fermat test

**Conjecture.** For a Korselt `n` with `k` distinct prime factors, the fraction of
units `a` with `orderOf a` a *proper* divisor of `n − 1` is at least
`1 − 2^{-(k−1)}`, so one random base detects the collapse with bounded-away-from-0
probability.

**The key insight is** that `korselt_orderOf_dvd` makes *every* order divide
`n − 1`; via the CRT isomorphism `(ℤ/nℤ)ˣ ≃ ∏ (ℤ/pℤ)ˣ` the proportion of bases
realizing the *full* exponent is a product of cyclic-group counting fractions,
each `≤ 1/2` for the 2-adic obstruction.

**Why now?** The order-divisibility fact is now a first-class lemma; turning it
into a density bound needs only `Fintype.card` arithmetic over the CRT product, no
new number theory.

## D4 — Free actions cannot hide a hard GAIP on a Korselt modulus

**Conjecture.** No free `MulAction` of `(ℤ/nℤ)ˣ` on a torsor `X` (with `n`
Korselt) admits a group-action inverse problem harder than `O(√(n−1))`: the
universal relation collapses the effective key space to `λ(n) ∣ (n − 1)`, enabling
baby-step/giant-step.

**The key insight is** that `korselt_action_pow_trivial` plus `free_smul_iff` show
the connector group element is constrained to a subgroup of exponent `λ(n)`, so the
search space has size `λ(n) ≤ n − 1`, and `korselt_exponent_le` makes the
`√` baby-step/giant-step bound explicit.

**Why now?** `korselt_exponent_le` and the geometric-triviality lemmas already live
on the exact `MulAction` interface; quantifying the BSGS cost is the next theorem.

## D5 — Strong-pseudoprime refinement via the 2-adic valuation

**Conjecture.** A Korselt `n` survives the strong (Miller–Rabin) test for base `a`
iff the 2-adic valuation `v₂(orderOf a)` matches a common value across all prime
factors; the density of strong liars is governed by `min_p v₂(p − 1)`.

**The key insight is** that the generalized exponent framework isolates the
contribution of each `p − 1`; splitting `n − 1 = 2^s · t` and tracking
`v₂(p − 1)` per prime turns the strong-pseudoprime condition into a per-factor
2-Sylow alignment, refining the plain order collapse of D3.

**Why now?** `generalized_korselt` already decomposes the exponent condition
prime-by-prime, so restricting attention to the 2-part is a direct specialization
rather than a new decomposition.
