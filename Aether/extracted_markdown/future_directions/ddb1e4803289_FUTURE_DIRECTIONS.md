# Future Directions: Pisano Periods, Entry Points, and the Modular Dynamics of Fibonacci

## Synthesis

This cycle added the *modular-dynamics* face to the catalog's Fibonacci entry-point theory.
Where `Catalog/Applications/FibonacciEntryPoints.lean` studies the **additive/divisibility**
invariant `entryPoint p` (the least `k > 0` with `p ∣ F_k`) through the law of apparition, and
`Catalog/Applications/FibonacciMatrix.lean` studies the **multiplicative/identity** invariants
(Cassini, Vajda, Catalan via the `Q`-matrix), the new file
`Catalog/Applications/FibonacciPisanoPeriod.lean` introduces the **Pisano period** `π(m)` — the
least period of `F mod m` — and proves it is well-behaved and *compatible* with the entry point.

The central structural idea is that the pair-shift `step m : (a,b) ↦ (b, a+b)` is a
**permutation of the finite set `ZMod m × ZMod m`**. Periodicity is then immediate from the
finiteness of the order of a group element (`pow_orderOf_eq_one`), bypassing any ad-hoc
pigeonhole argument. The proved results are: existence of a period (`exists_fib_period`),
that `π(m)` is a genuine period (`pisanoPeriod_spec`) and minimal (`pisanoPeriod_min`), the
"minimality as divisibility" law that every period is a multiple of `π(m)` (`fib_period_dvd`),
and the cross-face bridge `entryPoint_dvd_pisanoPeriod : entryPoint p ∣ π(p)`.

## Results Summary

- `fibState_eq` — `step^[n] (0,1) = (F_n, F_{n+1})` over `ZMod m` (the permutation drives the sequence).
- `exists_fib_period` — for `m > 0`, `∃ π > 0, ∀ n, F_{n+π} ≡ F_n (mod m)`.
- `pisanoPeriod_pos`, `pisanoPeriod_spec`, `pisanoPeriod_min` — `π(m)` is the least positive period.
- `fib_period_dvd` — the set of periods is exactly the set of multiples of `π(m)`.
- `entryPoint_dvd_pisanoPeriod` — the entry point always divides the Pisano period.

All theorems compile with `0` sorries and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`.

## Direction 1 — The exact Pisano-period formula via the order of `step` in `GL₂`

**Conjecture.** For a prime `p ≠ 5`, `π(p) ∣ p² − 1`; more precisely `π(p) ∣ p − 1` when
`5` is a quadratic residue mod `p` (i.e. `p ≡ ±1 mod 5`) and `π(p) ∣ 2(p+1)` otherwise.

The key insight is that `π(p)` is *exactly the multiplicative order* of the permutation
`step p`, which is the companion matrix of `x² − x − 1`; its order in `GL₂(ZMod p)` is governed
by whether that quadratic splits over `𝔽_p`, i.e. by the Legendre symbol `(5/p)`. The new
`fibState_eq`/`exists_fib_period` already package `step` as the dynamical generator, so the
remaining work is to identify `orderOf (step p)` with the order of an eigenvalue (a root of
`x² − x − 1`) in `𝔽_p` or `𝔽_{p²}`.

Why now? The permutation/`orderOf` engine is already in place and verified, and Mathlib supplies
`ZMod.legendreSym`, quadratic reciprocity, and the theory of `orderOf` in finite fields — the
exact ingredients needed to convert "least period" into a divisibility of `p ± 1`.

## Direction 2 — Carmichael's primitive-divisor theorem through period growth

**Conjecture.** For every `n ≥ 13` there is a prime `p` with `entryPoint p = n` (equivalently,
`F_n` has a primitive prime divisor), and `entryPoint p = n` forces `n ∣ π(p)` with `π(p)/n`
controlled by the multiplicative structure of `(ZMod p)ˣ`.

The key insight is that `entryPoint_dvd_pisanoPeriod` plus `fib_period_dvd` turn primitivity
into a *period-comparison* statement: a primitive divisor of `F_n` is a prime whose Pisano
period first "sees" index `n`, so counting primitive divisors becomes counting primes whose
period chain reaches `n` for the first time. Combined with the catalog's
`FibonacciPrimitiveDivisors.isPrimitive_unique` rigidity, this reduces Carmichael to a covering
argument on the divisors of `n`.

Why now? The catalog already has `primitive_iff_entry_eq` and the simultaneous-apparition join
law; the new bridge supplies the missing link between `entryPoint` and the genuinely dynamical
`π`, so the "coprime part of `F_n`" can be analyzed as a period-first-occurrence set.

## Direction 3 — Zeckendorf representation via the same finite-orbit method

**Conjecture.** Every positive integer has a unique representation as a sum of non-consecutive
Fibonacci numbers, and the greedy algorithm computes it in `O(log n)` steps.

The key insight is that the `step`-orbit viewpoint generalizes from *residues* to *magnitudes*:
the inequality `F_k + F_{k+1} = F_{k+2}` that collapses adjacent terms is precisely the
`toFun` of `step` read in `ℕ` rather than `ZMod m`, so the same one-step recurrence that powers
`fibState_eq` powers the greedy descent. Uniqueness then follows from the Cassini bound
`F_{k+1} > Σ_{j<k, non-consec} F_j` already implicit in `FibonacciMatrix.fib_cassini`.

Why now? `fibState_eq` and the strong-induction discipline used in `fib_period_dvd` provide the
exact recurrence-folding technology, and Mathlib's `Finset` API handles the index set of a
representation; no new Mathlib infrastructure is required.

## Direction 4 — Generalized Pisano/entry-point theory for Lucas sequences `U(P,Q)`

**Conjecture.** For a Lucas sequence `U_n(P,Q)` with `Δ = P² − 4Q ≠ 0` and a prime `p ∤ 2QΔ`,
the entry point `α(p)` divides `p − (Δ/p)`, and the reduced sequence is periodic with period
equal to the order of the companion permutation of `x² − Px + Q`.

The key insight is that *every* proof in the new file used only two abstract facts about `step`:
that it is a bijection of a finite set, and that it implements the linear recurrence. Replacing
`(a,b) ↦ (b, a+b)` by `(a,b) ↦ (b, -Q·a + P·b)` keeps `step` a permutation exactly when `Q` is a
unit mod `m`, so `exists_fib_period`, `fib_period_dvd`, and the bridge transfer verbatim to all
Lucas sequences.

Why now? The architecture is already modular and parameter-free in `P, Q`; the only nontrivial
new ingredient is the gcd identity `gcd(U_m,U_n) = U_{gcd(m,n)}`, for which Mathlib's general
linear-recurrence and divisibility lemmas are a realistic starting point.

## Direction 5 — Lower bounds on `α(p)` and Wall–Sun–Sun phenomena

**Conjecture.** For every `ε > 0` only finitely many primes `p` satisfy `entryPoint p < p^ε`;
unconditionally, `entryPoint p ≥ c · log p` for an explicit constant `c`.

The key insight is that `entryPoint_dvd_pisanoPeriod` together with the period bound from
Direction 1 (`π(p) ∣ p ± 1`) sandwiches the entry point: `entryPoint p ∣ π(p) ≤ p + 1`, so any
*lower* bound on `entryPoint p` becomes a statement about how small the period can be, which is
controlled by the size of `F_{entryPoint p}` (it must be divisible by `p`, forcing
`F_{entryPoint p} ≥ p`, hence `entryPoint p ≳ log_φ p`).

Why now? The growth lemma `F_k ≥ φ^{k-2}` is elementary and available, and the bridge proved
this cycle is exactly the inequality that connects the (small) entry point to the (bounded)
Pisano period — making the explicit logarithmic lower bound an accessible first formalization
target on the road to the Wall–Sun–Sun circle of questions.
