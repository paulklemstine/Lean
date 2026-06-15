# Future Directions — Primitive Divisors of Strong Divisibility Sequences

This cycle delivered `Catalog/Applications/StrongDivPrimitiveCertificate.lean`, which
abstracts the Fibonacci-only Carmichael primitive-divisor certificate (GCD "strip the
imprimitive part" algorithm) to **arbitrary strong divisibility sequences** `u : ℕ → ℕ`.
The soundness theorem `StrongDivSeq.primPart_sound` reduces *existence of a primitive prime
divisor of `u n`* to the single computable check `1 < primPart u n`, valid for every strong
divisibility sequence at once. It was instantiated to:

* `fib_has_primitive_divisor` — Carmichael's theorem on `13 ≤ n ≤ 2000` (one uniform
  application, no prime/composite split, since `primPart Nat.fib n > 1` throughout);
* `mersenne_two_has_primitive_divisor` — a **bounded Zsygmondy theorem for `2ⁿ − 1`** on
  `2 ≤ n ≤ 120`, `n ≠ 6`, plus the sharpness witness `mersenne_two_six_no_primitive`.

All results are `sorry`-free; the only nonstandard axioms are the `native_decide` ones
(`Lean.ofReduceBool`, `Lean.trustCompiler`) used in the bounded reflection checks.

Below are bold, testable conjectures for follow-up cycles.

## Direction 1 — Unbounded Zsygmondy for `2ⁿ − 1` via order/cyclotomic LTE
**Conjecture.** For every `n ∉ {1, 6}`, `2ⁿ − 1` has a primitive prime divisor.
**Plan.** Replace the bounded `mersenne_two_primPart_check` by an asymptotic argument:
the primitive part of `2ⁿ − 1` is governed by the cyclotomic value `Φ_n(2)`, and
`Φ_n(2) > n` for `n` large. The arithmetic core is the Lifting-the-Exponent lemma for
`aⁿ − 1` (`multiplicity`/`padicValNat` of `2ⁿ − 1` at a prime `p` with multiplicative order
`d | n` equals `v_p(2^d − 1) + v_p(n/d)`). Mathlib has `multiplicity` and
`Nat.sub_one_pow_totient`-style cyclotomic facts; the gap is `Φ_n(2) > n` for `n > N₀` plus
a finite check below `N₀`. **Falsifiable:** any `n ∉ {1,6}` with no primitive divisor refutes it.

## Direction 2 — Unbounded Carmichael (the catalog's open `sorry`)
**Conjecture.** `Catalog/Shared/CarmichaelProof.lean : fib_carmichael_composite` holds for all
`n > 10000` (the deliberately-sorried tail), completing Carmichael's 1913 theorem.
**Plan.** This is the Fibonacci instance of Direction 1's LTE program: the primitive part
`Φ_n^{F}` of `F(n)` satisfies `Φ_n^{F} ≈ φ^{ϕ(n)}` (golden ratio `φ`, Euler totient `ϕ`),
which exceeds `n` for `n` large. Bridge `primPart_sound` (now sequence-agnostic) to a *growth*
lower bound `n < primPart Nat.fib n` for `n > N₀`, eliminating the `native_decide` ceiling.
**Falsifiable:** a Fibonacci index `> 10000` with `primPart Nat.fib n = 1` refutes it.

## Direction 3 — A general Zsygmondy certificate for Lucas sequences `U_n(P,Q)`
**Conjecture.** For a nondegenerate Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1`, the abstract
certificate applies: `1 < primPart U n` certifies a primitive divisor, and the exceptional set
is finite and explicitly computable (Bilu–Hanrot–Voutier).
**Plan.** Prove `IsStrongDivSeq (U · (P,Q))` from the resultant/`gcd(U_m, U_n) = U_{gcd m n}`
identity (generalizing `Nat.fib_gcd` and `Nat.pow_sub_one_gcd_pow_sub_one`, already in the
catalog as `fib_isStrongDivSeq` / `mersenne_isStrongDivSeq`). Then `primPart_sound` fires
verbatim. **Falsifiable:** a nondegenerate `U` failing strong divisibility, or a counterexample
to a bounded `primPart U` check, refutes it.

## Direction 4 — Density and the rank lattice of primitive divisors
**Conjecture.** For a strong divisibility sequence with infinitely many primitive divisors, the
set of indices `n ≤ N` admitting a primitive divisor has natural density `1` as `N → ∞`.
**Plan.** Combine `primPart_sound` with `StrongDivisibilitySequences.apparition_count`
(`#{e < N : p ∣ u(e+1)} = N/n`, density `1/n`) and inclusion–exclusion over proper divisors to
bound the count of indices *without* a primitive divisor. **Falsifiable:** a strong divisibility
sequence whose primitive-divisor index set has density `< 1` refutes it.

## Direction 5 — Sharp exceptional sets by reflection-certified search
**Conjecture.** For each fixed base `a ≥ 2`, the Zsygmondy exceptional set of `aⁿ − 1`
(indices with no primitive divisor) is exactly `{1}` if `a + 1` is not a power of `2`, and
`{1, 6}` when `a = 2`; analogous finite tables hold for `aⁿ + 1`.
**Plan.** Generalize `mersenne_two_primPart_check` to a parametric `primPart (fun k => a^k - 1)`
checker, prove the bounded existence for several bases, and pair each with a `decide`-based
sharpness lemma in the style of `mersenne_two_six_no_primitive`. **Falsifiable:** any base/index
pair contradicting the predicted exceptional set refutes the table.
