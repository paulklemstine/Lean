# Future Directions: Fibonacci Entry Points and the Carmichael Phase Transition

## Synthesis

This cycle closed the conceptual gap between the *one-directional* entry-point
lemmas scattered across the catalog (`fibEntryPt_dvd_of_fib_dvd` and
`primitive_of_entryPt_eq` in `Speculative/AutoResearch/CarmichaelComposite.lean`,
`bridge_lemma` in `Shared/CarmichaelProof.lean`) and the *full ideal-theoretic
picture* they were circling. The central discovery is that for any modulus `p`
that divides *some* positive-index Fibonacci number, the divisibility relation
`p ∣ F(k)` is completely controlled by a single number, the entry point
`α(p)`: the index set `{k | p ∣ F(k)}` is **exactly** the principal ideal
`(α(p)) ⊆ ℕ` (`fib_dvd_iff_entryPt_dvd`, `fib_dvd_setOf_eq_multiples`). The
forward direction is a `gcd`-minimality argument powered by `Nat.fib_gcd`; the
backward direction is pure `Nat.fib_dvd`. Notably the proof never touches
primality of `p`, so the characterization is automatically general.

From this single theorem the notion of a **primitive prime divisor** — the object
at the heart of Carmichael's theorem — becomes a clean equation:
`p` is a primitive divisor of `F(n)` iff `α(p) = n` (`entryPt_eq_iff_primitive`).
This reframes Carmichael's theorem as the surjectivity statement "every large `n`
is in the range of `α`", which is a sharper and more tractable formulation than
the coprime-part computations the catalog currently uses.

The cycle also isolated *why* the theorem must have exceptions. We proved
`fib_twelve_no_primitive`: `F(12) = 144 = 2^4·3^2` has no primitive prime divisor
because its only prime support is `{2, 3}` with `α(2) = 3` and `α(3) = 4`, both
strictly below `12`. This is the structural obstruction the catalog's
`primPart_check` (range `13 ≤ n ≤ 10000`) silently steps past, and it is exactly
the `n = 12` exclusion in Carmichael's hypothesis. What *failed* this cycle was
the infinite tail of `fib_carmichael_composite` (`n > 10000`), still a `sorry` in
`Shared/CarmichaelProof.lean`: closing it needs a growth/lifting-the-exponent
bound that the entry-point characterization alone does not supply. The
characterization is the algebraic skeleton; the tail needs analytic flesh.

## Results Summary

- `fib_dvd_gcd_of_dvd`: proved — `p ∣ F(n)` and `p ∣ F(k)` imply `p ∣ F(gcd n k)`; the `gcd`-compatibility backbone.
- `fibEntryPt_pos`: proved — entry point is positive whenever it exists.
- `fib_dvd_fibEntryPt`: proved — `p ∣ F(α(p))` (the entry point really is an apparition index).
- `fibEntryPt_min`: proved — no smaller positive index works (minimality).
- `fib_dvd_iff_entryPt_dvd`: proved — **main theorem**: `p ∣ F(k) ↔ α(p) ∣ k` for all `k`; the index set is the principal ideal `(α(p))`.
- `fib_dvd_setOf_eq_multiples`: proved — set-level restatement `{k | p ∣ F(k)} = {k | α(p) ∣ k}`.
- `entryPt_eq_iff_primitive`: proved — `p` is a primitive divisor of `F(n)` iff `α(p) = n`; recasts Carmichael's theorem as surjectivity of `α`.
- `fib_twelve_no_primitive`: proved — **boundary counterexample**: `F(12)` has no primitive prime divisor, the exact `n = 12` exception.
- `fibEntryPt_mul_coprime`: conjecture (`sorry`) — lcm law `α(a·b) = lcm(α(a), α(b))` for coprime `a, b`.

## Research Directions

### Direction 1: The lcm law for entry points
**Hypothesis**: For coprime `a, b` each admitting a positive index of apparition,
`α(a·b) = lcm(α(a), α(b))` (the stated conjecture `fibEntryPt_mul_coprime`).
**Test**: Prove it from `fib_dvd_iff_entryPt_dvd`: `a·b ∣ F(k)` iff (by coprimality)
`a ∣ F(k) ∧ b ∣ F(k)` iff `α(a) ∣ k ∧ α(b) ∣ k` iff `lcm(α(a), α(b)) ∣ k`; then both
sides are the generator of the same ideal. The one missing lemma is
`Nat.Coprime a b → (a*b ∣ m ↔ a ∣ m ∧ b ∣ m)`.
**Why now**: The ideal characterization proved this cycle makes "smallest `k` with
property P" manipulable as "generator of an ideal", which is precisely what an lcm
law needs.
**If true**: `α(m)` is computable from the prime-power factorization of `m`,
reducing all entry-point questions to the prime-power case.
**If false**: The coprimality hypothesis is essential and shared prime factors
genuinely collapse the entry point — a sharper obstruction than expected.

### Direction 2: Carmichael as surjectivity of α
**Hypothesis**: For every `n ∉ {1, 2, 6, 12}`, there exists a prime `p` with
`α(p) = n` (equivalently, `n` is in the range of the entry-point map).
**Test**: Combine `entryPt_eq_iff_primitive` (proved) with a primitive-divisor
existence theorem; the finite range `13 ≤ n ≤ 10000` is already discharged by
`primPart_check`. The open part is `n > 10000`.
**Why now**: `entryPt_eq_iff_primitive` reduces the entire theorem to a single
surjectivity statement, eliminating the coprime-part bookkeeping.
**If true**: It closes the `sorry` in `fib_carmichael_composite` and gives a
uniform statement of Carmichael's theorem.
**If false (in some range)**: It pinpoints additional exceptional `n`, which would
be a genuine counterexample to the classical theorem (so: a check on our
formalization).

### Direction 3: The growth bound for the infinite tail
**Hypothesis**: For composite `n > 10000`, `F(n)` strictly exceeds the product of
`F(d)` over proper divisors `d | n` raised to their multiplicities, forcing a
primitive prime factor.
**Test**: Establish `F(n) ≥ φ^(n-2)` (golden-ratio lower bound) and an upper bound
`∏_{d | n, d < n} F(d) ≤ φ^(n - something)` via `∑_{d|n, d<n} d ≤ n - 1` for the
right `n`, then compare exponents.
**Why now**: This is the *only* missing ingredient identified this cycle for the
catalog's outstanding `sorry`; the algebraic side (entry points) is now complete.
**If true**: Completes Carmichael's theorem for all `n` and removes the last
`sorry` in `Shared/CarmichaelProof.lean`.
**If false**: The naive exponent count is too weak and lifting-the-exponent
(p-adic valuation of `F(n)`) is genuinely required, redirecting effort to the
`Tropical_p_adic_Valuation...` catalog file.

### Direction 4: Entry points of prime powers (the LTE step)
**Hypothesis**: For a prime `p` with `α(p) = e` and `p^j ∥ F(e)`, the entry point
of `p^(j + i)` is `e · p^i` for all `i ≥ 0` (the lifting-the-exponent / Wall's
theorem pattern).
**Test**: Prove `v_p(F(e·p^i)) = v_p(F(e)) + i` using the p-adic valuation lemmas in
the catalog's tropical valuation file, then read off the entry point via
`fib_dvd_iff_entryPt_dvd`.
**Why now**: With the prime case fully characterized, prime powers are the only
remaining building block needed to compute `α(m)` for all `m` (and they feed
Direction 1 and Direction 3).
**If true**: Yields a complete algorithm for `α(m)` and a clean p-adic handle on
`F(n)`'s factorization.
**If false**: The "Fibonacci-Wieferich" anomalies (primes where the valuation
jumps unexpectedly) appear earlier than believed — itself a notable finding.

### Direction 5: Generalization to Lucas sequences
**Hypothesis**: The entry-point characterization `u ∣ U_k ↔ α(u) ∣ k` holds verbatim
for any nondegenerate Lucas sequence `U_n(P, Q)` with `gcd(P, Q) = 1`, using the
strong-divisibility property `gcd(U_m, U_n) = U_{gcd(m,n)}`.
**Test**: Abstract `fib_dvd_iff_entryPt_dvd` over any sequence satisfying
`U_{gcd(m,n)} = gcd(U_m, U_n)` and `m ∣ n → U_m ∣ U_n`; the current proof uses only
these two facts (`Nat.fib_gcd`, `Nat.fib_dvd`).
**Why now**: The proof this cycle is already "axiomatic" in those two divisibility
properties — it never inspects the Fibonacci recurrence — so the generalization is
a refactor, not a new argument.
**If true**: One theorem covers Fibonacci, Mersenne (`2^n - 1`), and all Lucas
sequences, unifying several catalog threads.
**If false**: Some sequence fails strong divisibility, exposing exactly which
hypothesis the characterization truly needs.
