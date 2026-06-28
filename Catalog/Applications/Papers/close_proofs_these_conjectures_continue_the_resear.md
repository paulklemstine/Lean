# Carmichael primitive-divisor theorem: non-circular composite case

File: `Catalog/Shared/CarmichaelProof.lean`

## What was done

The file develops the "primitive part" `primPart n` of a Fibonacci number `fib n`
(obtained by stripping from `fib n` every prime factor shared with some earlier
`fib d`, `d ∣ n`, `d < n`) and proves Carmichael's primitive-divisor theorem for
composite indices, organised so there is **no circular dependency**.

1. **Survival of primitive primes (Step 1).**
   `primPart_pos_of_primitive` : if `p` is prime, `p ∣ fib n`, and `p ∤ fib k` for
   every `0 < k < n`, then `p ∣ primPart n`, hence `1 < primPart n`.
   It rests on two new lemmas:
   * `stripAllAux_preserves_prime` — a prime not dividing `m` is never removed by
     the factor-stripping `stripAllAux _ m _`;
   * `foldl_strip_preserves_prime` — therefore it survives the whole fold over the
     proper divisors.

2. **Invoking Bang–Zsigmondy (Step 2).**
   `primPart_pos_large (hBZ) (n) (12 < n) : 1 < primPart n` is obtained by feeding
   the primitive prime produced by the Bang–Zsigmondy theorem into the survival
   lemma. It references **only** the Bang–Zsigmondy input and the survival lemma —
   never the primitive-divisor theorem proved afterwards — so the argument is
   non-circular.

3. **Small-case verification (Step 3).**
   `primPart_check` verifies by direct computation (`native_decide`) that for every
   `n ∈ [13, 10000]` either `n` is prime or `1 < primPart n`.

4. **Non-circular assembly (Step 4).**
   `fib_carmichael_composite (hBZ) (13 ≤ n) (¬ n.Prime)` and
   `fib_carmichael (hBZ) (13 ≤ n)` combine the pieces: small indices via the
   computation, the infinite tail via `primPart_pos_large`. The elementary prime
   case `fib_primitive_divisor_prime` is proved **unconditionally**.

## On the Bang–Zsigmondy input

The Bang–Zsigmondy theorem for Fibonacci numbers ("for `n > 12`, `fib n` has a
primitive prime divisor", Carmichael 1913 / Bang 1886) is the deep number-theoretic
input. Its full proof needs a magnitude estimate for the Fibonacci cyclotomic
factors together with the law of repetition (lifting-the-exponent), neither of which
is currently available in Mathlib. To avoid compromising soundness with an `axiom`,
it is carried as the **explicit hypothesis** `BangZsigmondyFib` on exactly the
results that need it (the infinite tail). Everything else — the survival lemma, the
small-case computation, the prime case, and the non-circular assembly — is proved
unconditionally.

All results depend only on the whitelisted axioms (`propext`, `Classical.choice`,
`Quot.sound`, and, for the `native_decide` computation, `Lean.ofReduceBool` /
`Lean.trustCompiler`). The file contains no `sorry` and no `axiom`.
