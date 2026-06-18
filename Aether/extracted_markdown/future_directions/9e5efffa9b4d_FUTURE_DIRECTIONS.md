# Future Directions — Fibonacci Entry-Point Theory

## Synthesis

This cycle deepened the *entry-point* (rank-of-apparition) theory of Fibonacci
numbers that underlies Carmichael's primitive-divisor theorem. Working entirely
inside `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`,
we closed the last open `sorry` of that file (the multiplicative **lcm law**) and
then extracted the *conceptual* skeleton of the whole theory: the apparition
index set of any modulus is a **principal additive submonoid** of `ℕ`, and the
entry-point map `α` is a **divisibility-monotone** map whose fibres are exactly
the primitive indices.

The unifying viewpoint is that `α : (ℕ, ∣) → (ℕ, ∣)` is a monotone map of
divisibility posets such that

* `{k | m ∣ F k}` is the principal additive submonoid `(α m)` of `ℕ`
  (`fibIndexSubmonoid`, `fibIndexSubmonoid_eq_multiples`);
* `α(a·b) = lcm(α a, α b)` for coprime `a, b` (`fibEntryPt_mul_coprime`),
  so `α` is reconstructible from prime-power data;
* `a ∣ b ⟹ α a ∣ α b` (`fibEntryPt_dvd_of_dvd`), `α 1 = 1` (`fibEntryPt_one`);
* Carmichael's theorem is precisely the *surjectivity* of `α` (restricted to
  primes) onto each admissible index `n` (`exists_primitive_iff_exists_entryPt`).

## Results Summary

All results below are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

| Theorem | Statement |
|---|---|
| `fibEntryPt_mul_coprime` | `α(a·b) = lcm(α a, α b)` for coprime `a,b` (was the open `sorry`) |
| `fib_dvd_zero` / `fib_dvd_add` | the index set contains `0` and is `+`-closed |
| `fibIndexSubmonoid` (+ `_eq_multiples`) | the index set is the principal `AddSubmonoid (α m)` |
| `entryPt_exists_of_dvd` | divisors of a modulus with an entry point also have one |
| `fibEntryPt_dvd_of_dvd` | `α` is monotone for divisibility |
| `fibEntryPt_one` | `α 1 = 1` |
| `exists_primitive_iff_exists_entryPt` | Carmichael ⇔ surjectivity of `α` on primes |

The one deliberately-untouched target is the infinite tail of
`Shared/CarmichaelProof.lean`'s `fib_carmichael_composite` (composite `n > 10000`),
which is the genuine analytic content of Carmichael's theorem and is out of reach
of the elementary entry-point algebra developed here.

## Bold, Falsifiable Research Directions

### 1. The Law of Apparition: `α(p) ∣ p − (5/p)` for primes `p ≠ 5`
For an odd prime `p ≠ 5`, the entry point divides `p − 1` if `5` is a quadratic
residue mod `p` and divides `p + 1` otherwise — i.e. `α(p) ∣ p − legendre(5,p)`.
**The key insight is** that the entry point is the order of the companion matrix
`[[1,1],[1,0]]` in `GL₂(𝔽_p)`, whose eigenvalues live in `𝔽_p` exactly when `5`
is a QR, so Lagrange's theorem on the multiplicative group forces the divisibility.
**Why now?** We already have `fibEntryPt` and its divisibility characterization;
the missing ingredient is a clean bridge to `Matrix.GeneralLinearGroup` order,
and Mathlib's `ZMod`, `legendreSym`, and `orderOf` APIs are now mature enough to
state and discharge it. Falsifiable: a single prime with `α(p) ∤ p ∓ 1` kills it.

### 2. Prime-power reconstruction: `α(m) = lcm over prime powers p^e ‖ m of α(p^e)`
The coprime lcm law extends by induction to the full factorization of any `m`
admitting an entry point: `α(m) = lcm_{p^e ‖ m} α(p^e)`.
**The key insight is** that `fibEntryPt_mul_coprime` is the base case of a
`Nat.factorization`/`Finset.prod` induction, since distinct prime powers are
pairwise coprime, so the lcm law lifts verbatim to arbitrary finite coprime
products. **Why now?** `fibEntryPt_mul_coprime` is proved this cycle and
Mathlib's `Nat.factorizationEquiv` / `Finsupp.prod` give a ready induction
skeleton; the only new work is a `Finset`-indexed lcm law. Falsifiable by any
`m` whose entry point differs from the lcm of its prime-power entry points.

### 3. The Pisano connection: `α(m) ∣ π(m)` and `α(m) ∣ m·(something)`
The Pisano period `π(m)` (the period of `F mod m`) is always a multiple of the
entry point `α(m)`, with quotient `1`, `2`, or `4`.
**The key insight is** that the index set `{k | m ∣ F k}` being the submonoid
`(α m)` (proved this cycle) means `α(m)` is the additive *order* of the residue
streak, while `π(m)` is the order of the full state `(F k, F k+1)`; the state map
factors through the value map, forcing `α(m) ∣ π(m)`. **Why now?** The submonoid
description `fibIndexSubmonoid_eq_multiples` is exactly the structural fact needed
to relate the two periods without re-deriving Fibonacci recurrences. Falsifiable:
any `m` with `α(m) ∤ π(m)`, or a quotient outside `{1,2,4}`.

### 4. Surjectivity of `α` onto all `n ∉ {1,2,6,12}` (full Carmichael, indexed form)
Recast via `exists_primitive_iff_exists_entryPt`, Carmichael's theorem says the
prime-restricted entry-point map `α` hits every `n ≥ 1` except `n ∈ {1,2,6,12}`.
**The key insight is** that closing the infinite tail of `fib_carmichael_composite`
is *equivalent* to proving `α` is eventually surjective on primes — a statement
about the image of `α` rather than about Fibonacci growth — which isolates the
single hard inequality (`F n` has a prime factor not dividing any earlier `F k`)
behind a clean surjectivity wrapper. **Why now?** The iff bridge is proved this
cycle, converting an unbounded computational `sorry` into a focused image
question that cyclotomic/Zsygmondy machinery can attack. Falsifiable by any
`n ∉ {1,2,6,12}` with empty `α`-preimage among primes.

### 5. Functoriality across linear recurrences (Lucas, Pell, …)
The entire entry-point package depends only on the *strong divisibility*
property `gcd(F m, F n) = F(gcd m n)`. Any strong divisibility sequence (Lucas
sequences `U_n(P,Q)` with the right parameters, e.g. Pell) therefore has its own
`α`, lcm law, monotonicity, and submonoid description.
**The key insight is** that none of the proofs in this file use the Fibonacci
recurrence directly — they use only `Nat.fib_gcd` and `Nat.fib_dvd`, so abstracting
to a typeclass `StrongDivisibilitySeq` makes every theorem here a *corollary* of a
single generic development. **Why now?** Mathlib has Lucas/Pell sequences and the
`gcd`-divisibility lemmas for several of them; generalizing now turns ~10 Fibonacci
lemmas into one reusable functor. Falsifiable: exhibit a strong divisibility
sequence violating the lcm law for `α`.
