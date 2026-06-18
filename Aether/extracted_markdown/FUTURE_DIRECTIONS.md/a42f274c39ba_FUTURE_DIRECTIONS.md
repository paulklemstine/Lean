# Future Directions: Multiplicative Structure of the Fibonacci Rank of Apparition

## Synthesis

This cycle took the *single-modulus* law of apparition from the catalog
(`FibonacciApparition.fib_dvd_iff_fibEntry_dvd`: `m ∣ F k ↔ fibEntry m ∣ k`) and
upgraded it to a statement about how the rank of apparition `fibEntry` interacts with the
**multiplicative structure of the modulus**. The central discovery is that `fibEntry` is an
*lcm-homomorphism on the coprime-modulus monoid*: for coprime `m, n > 0`,
`fibEntry (m * n) = lcm (fibEntry m) (fibEntry n)` (`fibEntry_mul_coprime`). The proof is a
clean local-to-global (CRT) argument: `m*n ∣ F k` splits into `m ∣ F k` and `n ∣ F k` exactly
when `m, n` are coprime, and each of those is the law of apparition for a smaller modulus.

The Critic phase showed coprimality is not cosmetic but essential: at `m = n = 2` the formula
already fails, because `fibEntry 4 = 6` while `lcm (fibEntry 2) (fibEntry 2) = lcm 3 3 = 3`
(`fibEntry_mul_coprime_fails`). The size of this gap — a factor of `2` — is precisely the
prime-power "delay" that the lcm formula cannot see, which is the structural reason the theory
splits into a coprime (CRT) part and a hard prime-power (Wall) part.

The supporting infrastructure that made this possible was (a) `fibEntry_dvd_of_dvd`,
divisibility-monotonicity of the entry point, which is the "functorial" half, and
(b) `fibEntry_eq_of`, an evaluation principle that converts the noncomputable `fibEntry`
(defined via `Nat.find`/`Classical`) into honest numeric values, enabling the counterexample.
Together these say: the coprime structure of `fibEntry` is completely understood; all remaining
depth lives in the prime-power tower `fibEntry p ∣ fibEntry (p²) ∣ ⋯` (`fibEntry_dvd_prime_pow`).

## Results Summary

- `fibEntry_dvd_of_dvd`: proved — divisibility-monotonicity `a ∣ b → fibEntry a ∣ fibEntry b`; the functorial backbone for assembling local data.
- `fibEntry_eq_of`: proved — evaluation principle pinning the noncomputable entry point from a "divides here, nowhere earlier" certificate.
- `fibEntry_two`: proved — `fibEntry 2 = 3`, the smallest concrete value, used as a counterexample ingredient.
- `fibEntry_four`: proved — `fibEntry 4 = 6`, the first prime-power value exhibiting Wall delay.
- `fibEntry_mul_coprime`: proved — the headline result: `fibEntry` is an lcm-homomorphism on coprime moduli (CRT upgrade of the law of apparition).
- `fibEntry_mul_coprime_fails`: proved (disproof of the naive generalization) — coprimality is necessary; `2·2` already breaks the lcm formula.
- `fibEntry_dvd_prime_pow`: proved — base case of the prime-power divisibility tower `fibEntry p ∣ fibEntry (p²)`.

## Research Directions

### Direction 1: CRT reconstruction of the full entry point
**Hypothesis**: For any `m > 0` with prime factorization `m = ∏ pᵢ^eᵢ`,
`fibEntry m = lcm_i (fibEntry (pᵢ^eᵢ))`.
**Test**: Induct on the number of distinct prime factors using `fibEntry_mul_coprime` at each
step (the inductive step is coprime because `p^e` is coprime to the remaining cofactor). Formalize
with `Nat.factorization` / `Finset.lcm` and prove the `Finset`-indexed lcm identity.
**Why now**: `fibEntry_mul_coprime` is exactly the two-factor base case; only the `Finset`
bookkeeping remains. This reduces *all* of entry-point theory to the prime-power case.
**If true**: Entry-point computation becomes fully local; Carmichael/primitive-divisor counting
can be done one prime power at a time.
**If false**: Would reveal a non-coprime interaction the two-factor case hides (very unlikely given the CRT proof, but the failure would be deeply informative).

### Direction 2: The prime-power tower and Wall's phenomenon
**Hypothesis**: For every prime `p` and `k ≥ 1`, either `fibEntry (p^(k+1)) = fibEntry (p^k)`
or `fibEntry (p^(k+1)) = p · fibEntry (p^k)`; the first alternative for `k = 1` happens iff `p`
is a Wall–Sun–Sun prime (none known below `2^64`).
**Test**: Prove the divisibility-and-ratio dichotomy via lifting-the-exponent applied to
`F(fibEntry p · p^j)`; the catalog file `Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors` already houses the LTE machinery to connect to.
**Why now**: `fibEntry_dvd_prime_pow` gives the divisibility half; the missing content is the
exact ratio, and the LTE catalog entry supplies the `p`-adic valuation control.
**If true**: Completes the structure theory of `fibEntry` (combined with Direction 1).
**If false**: A counterexample would *be* a Wall–Sun–Sun prime — a famous open target.

### Direction 3: Entry point of `lcm` and `gcd` of moduli
**Hypothesis**: `fibEntry (gcd a b) ∣ gcd (fibEntry a) (fibEntry b)` and
`lcm (fibEntry a) (fibEntry b) ∣ fibEntry (lcm a b)`, with equality in the second when `a, b`
are coprime.
**Test**: Both directions follow from `fibEntry_dvd_of_dvd` applied to the lattice inequalities
`gcd a b ∣ a`, `a ∣ lcm a b`; the coprime equality specializes `fibEntry_mul_coprime`.
**Why now**: `fibEntry_dvd_of_dvd` makes `fibEntry` a monotone map of divisibility lattices, so
these are immediate lattice-morphism statements.
**If true**: Establishes `fibEntry` as a lattice morphism (up to the prime-power defect), a clean
algebraic characterization.
**If false**: Pinpoints exactly where multiplicativity and the lattice structure diverge.

### Direction 4: Pisano period from the entry point
**Hypothesis**: The Pisano period `π(m)` is a multiple of `fibEntry m`, and `π(m) / fibEntry m ∈
{1, 2, 4}` (the "ratio of the period to the rank of apparition" is one of three values).
**Test**: Use the order of `F(fibEntry m + 1)` in `(ZMod m)ˣ` together with the pair-periodicity
already proved in `FibonacciApparition` (`fibPair`, `fibPair_descent`).
**Why now**: The pair-sequence dynamical system that proves `exists_pos_dvd_fib` is the same
object whose minimal period is `π(m)`; the entry point is the first return to a zero first
coordinate. The relationship is one short order-theoretic step away.
**If true**: Connects the rank of apparition to the Pisano period quantitatively, opening the
quadratic-reciprocity formula for `π(p)`.
**If false**: The `{1,2,4}` trichotomy is classical, so a Lean counterexample would indicate a
formalization-level subtlety worth isolating.

### Direction 5: Lucas-sequence generalization
**Hypothesis**: For a Lucas sequence `U_n(P, Q)` with `gcd(P,Q)=1` and discriminant `Δ ≠ 0`, the
analogue `lucasEntry` satisfies `lucasEntry (m*n) = lcm (lucasEntry m) (lucasEntry n)` for
coprime `m, n`.
**Test**: Reprove `fibEntry_mul_coprime` abstractly from the two inputs it actually used —
divisibility-monotonicity (Direction-style) and the gcd identity `gcd(U_m, U_n) = U_{gcd(m,n)}` —
then instantiate at `P=Q=1`.
**Why now**: The present proof of `fibEntry_mul_coprime` only invokes the law of apparition and
`Nat.Coprime.mul_dvd_of_dvd_of_dvd`; both transfer verbatim once the gcd identity is available
for `U`. The architecture is modular by design.
**If true**: One proof covers Fibonacci, Pell, Mersenne, and Lucas numbers simultaneously.
**If false**: Identifies which Lucas-sequence axiom (the gcd identity vs. coprimality of `P,Q`)
the CRT structure genuinely requires.
