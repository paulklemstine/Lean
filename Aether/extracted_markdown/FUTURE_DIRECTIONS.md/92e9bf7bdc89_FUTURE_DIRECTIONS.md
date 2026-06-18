# Future Directions: Multiplicative Structure of the Fibonacci Rank of Apparition

This cycle upgraded the single-modulus *law of apparition* from the catalog
(`FibonacciApparition.fib_dvd_iff_fibEntry_dvd`: `m ∣ F k ↔ fibEntry m ∣ k`) to a statement
about how the rank of apparition `fibEntry` interacts with the multiplicative structure of the
modulus. The headline theorem, `fibEntry_mul_coprime`, shows that `fibEntry` is an
**lcm-homomorphism on the coprime-modulus monoid**: for coprime `m, n > 0`,
`fibEntry (m * n) = lcm (fibEntry m) (fibEntry n)`. The complementary disproof,
`fibEntry_mul_coprime_fails`, shows coprimality is essential — already at `m = n = 2` the formula
breaks (`fibEntry 4 = 6` vs `lcm 3 3 = 3`). Two pieces of infrastructure made this possible:
`fibEntry_dvd_of_dvd` (divisibility-monotonicity, making `fibEntry` a monotone map of divisibility
lattices) and `fibEntry_eq_of` (an evaluation principle pinning the noncomputable `fibEntry` to
honest numeric values). The corollaries `fibEntry_gcd_dvd` and `lcm_dvd_fibEntry_lcm` already
record the lattice-morphism inequalities, and `fibEntry_dvd_prime_pow` gives the base case of the
prime-power divisibility tower. The structure theory now cleanly splits into a fully-understood
coprime (CRT) part and a hard prime-power (Wall) part. The directions below push on that split.

## Direction 1: CRT reconstruction of the full entry point

For any `m > 0` with prime factorization `m = ∏ pᵢ^eᵢ`, conjecture
`fibEntry m = lcm_i (fibEntry (pᵢ^eᵢ))`, i.e. the entry point is the `Finset.lcm` over the
prime-power factors. The proof should induct on the number of distinct prime factors, applying
`fibEntry_mul_coprime` at each step (the inductive step is coprime because `pᵉ` is coprime to the
remaining cofactor), formalized via `Nat.factorization` and `Finset.lcm`.

The key insight is that `fibEntry_mul_coprime` is exactly the two-factor base case of a
`Finset`-indexed lcm identity, so only the multiplicative bookkeeping over `m.factorization` is
left to do. **Why now?** With the coprime two-factor case proved and axiom-clean, the remaining
content is purely combinatorial assembly of local data — no new number theory is required. If
true, entry-point computation becomes fully local and Carmichael/primitive-divisor counting can
proceed one prime power at a time; if false, the failure would expose a non-coprime interaction
the two-factor case hides (very unlikely given the CRT proof, but informative).

## Direction 2: The prime-power tower and Wall's phenomenon

For every prime `p` and `k ≥ 1`, conjecture the dichotomy `fibEntry (p^(k+1)) = fibEntry (p^k)`
or `fibEntry (p^(k+1)) = p · fibEntry (p^k)`, with the first alternative at `k = 1` occurring iff
`p` is a Wall–Sun–Sun prime (none known below `2^64`). The divisibility half is already in hand as
`fibEntry_dvd_prime_pow`; the missing content is the exact ratio, which should come from
lifting-the-exponent applied to `F(fibEntry p · p^j)`, connecting to the catalog file
`Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors`.

The key insight is that the entire prime-power "defect" measured by `fibEntry_mul_coprime_fails`
is governed by a single `p`-adic valuation jump, so the ratio is forced into the two-element set
`{1, p}` by an LTE valuation count. **Why now?** `fibEntry_dvd_prime_pow` supplies the
divisibility skeleton and the LTE catalog entry supplies the valuation control, so the two halves
can finally be joined. If true, combined with Direction 1 this completes the structure theory of
`fibEntry`; if false, the counterexample *is* a Wall–Sun–Sun prime — a famous open target.

## Direction 3: `fibEntry` as a lattice morphism up to the prime-power defect

Strengthen the proven inequalities `fibEntry_gcd_dvd` and `lcm_dvd_fibEntry_lcm` to a sharp
characterization: conjecture that `lcm (fibEntry a) (fibEntry b) = fibEntry (lcm a b)` holds
*exactly* when `a, b` are coprime (equality in `lcm_dvd_fibEntry_lcm`), and quantify the index
`fibEntry (lcm a b) / lcm (fibEntry a) (fibEntry b)` in the non-coprime case as a product of
prime-power defects from Direction 2.

The key insight is that `fibEntry_dvd_of_dvd` already makes `fibEntry` a monotone map of
divisibility lattices, so the only obstruction to it being a genuine lattice morphism is precisely
the prime-power Wall delay isolated by `fibEntry_mul_coprime_fails`. **Why now?** Both inequalities
are proved and axiom-clean, and the coprime equality is an immediate specialization of
`fibEntry_mul_coprime`; what remains is to pin the defect, which Direction 2 supplies. If true, it
gives a clean algebraic characterization of `fibEntry` as a lattice morphism modulo a computable
defect; if false, it pinpoints exactly where multiplicativity and the lattice structure diverge.

## Direction 4: Pisano period from the entry point

Conjecture that the Pisano period `π(m)` is always a multiple of `fibEntry m`, with the ratio
`π(m) / fibEntry m ∈ {1, 2, 4}`. The natural route reuses the dynamical system already built in
the catalog `FibonacciApparition` file: `fibPair` and `fibPair_descent` describe the orbit of
`(F n, F (n+1))` in `ZMod m × ZMod m`, whose minimal period is `π(m)`, and the entry point is the
first return to a zero first coordinate. The ratio is then the multiplicative order of
`F(fibEntry m + 1)` in `(ZMod m)ˣ`.

The key insight is that the entry point and the Pisano period are two invariants of the *same*
finite dynamical system — the entry point is the first zero-crossing and the period is the full
return time — so the divisibility `fibEntry m ∣ π(m)` is forced by the orbit structure with no
extra input. **Why now?** The pair-sequence machinery (`fibPair`, `fibPair_descent`) that proves
`exists_pos_dvd_fib` is already in the catalog, so the period is one short order-theoretic step
away from the entry point. If true, this connects the rank of apparition to the Pisano period
quantitatively and opens the door to a reciprocity formula for `π(p)`; if false, the classical
`{1,2,4}` trichotomy would reveal a formalization-level subtlety worth isolating.

## Direction 5: Lucas-sequence generalization

For a Lucas sequence `U_n(P, Q)` with `gcd(P, Q) = 1` and nonzero discriminant, conjecture that
the analogue `lucasEntry` satisfies `lucasEntry (m * n) = lcm (lucasEntry m) (lucasEntry n)` for
coprime `m, n`. The plan is to re-prove `fibEntry_mul_coprime` abstractly from the *only two*
inputs it actually used — divisibility-monotonicity (the analogue of `fibEntry_dvd_of_dvd`) and
the strong divisibility property `gcd(U_m, U_n) = U_{gcd(m,n)}` — then instantiate at `P = Q = 1`
to recover the Fibonacci case.

The key insight is that the present CRT proof never touches anything Fibonacci-specific beyond the
law of apparition and `Nat.Coprime.mul_dvd_of_dvd_of_dvd`, both of which are consequences of the
strong divisibility property shared by every Lucas sequence. **Why now?** The architecture is
already modular: the Fibonacci proof factors through exactly the two abstract hypotheses, so the
generalization is a refactor, not a new theorem. If true, one proof simultaneously covers
Fibonacci, Pell, Mersenne, and general Lucas numbers; if false, it identifies precisely which
Lucas-sequence axiom (the gcd identity versus coprimality of `P, Q`) the CRT structure genuinely
requires.
