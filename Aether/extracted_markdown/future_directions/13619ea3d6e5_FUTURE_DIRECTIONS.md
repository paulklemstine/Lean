# Future Directions — Fibonacci Entry Points & Primitive Divisors

Research cycle output. Each conjecture below is **precise and testable** (statable as a
Lean theorem) and builds on results proved this cycle in
`Catalog/Speculative/AutoResearch/FibEntryPointCongruence.lean`,
`Catalog/Shared/CarmichaelHelper.lean`, and the existing
`Catalog/Algebra/Tropical_p_adic_..._Divisors.lean`.

## Results established this cycle (0-sorry, verified axioms)
- `fibEntryPoint_dvd_sq_sub_one` : for odd prime `p ≠ 5`, the rank of apparition
  `z(p) ∣ p² − 1`.
- `primitive_divisor_dvd_sq_sub_one` : a primitive prime divisor `p` of `F_n` (`n ≥ 6`)
  satisfies `n ∣ p² − 1`.
- `primitive_divisor_sq_ge` : such a `p` satisfies `n + 1 ≤ p²`.
- `fib_carmichael_iff_le_10000` : **Carmichael's theorem, fully verified on `[1,10000]`** —
  `F_n` has a primitive prime divisor iff `n ∉ {1, 2, 6, 12}`.
- `fib_primitive_divisor_prime` : the prime-index case of Carmichael (unconditional).

## Conjecture 1 — Close the infinite composite tail (priority)
**Statement.** `fib_carmichael_composite` holds for *all* composite `n ≥ 14`, removing the
last `sorry` in `Catalog/Shared/CarmichaelProof.lean`.
**Plan.** Develop the cyclotomic–Fibonacci factorization `F_n = ∏_{d∣n} Φ_d` (with `Φ_d ∈ ℤ`),
prove the size bound `Φ_n > n` for `n > 12`, and the LTE multiplicity bound: at most the
largest prime factor of `n` divides `Φ_n` non-primitively, to exponent ≤ 1. Then `Φ_n` exhibits
a primitive prime. The catalog already has `fib_lte`, `fib_exponential_lower_bound`, and the
entry-point characterization to seed this.

## Conjecture 2 — Sharp ±1 congruence for primitive divisors
**Statement.** For `n ≥ 7`, every primitive prime divisor `p` of `F_n` satisfies
`p ≡ 1 (mod n)` **or** `p ≡ −1 (mod n)` (i.e. `n ∣ p − 1 ∨ n ∣ p + 1`), strictly sharpening
this cycle's `n ∣ p² − 1`.
**Evidence.** Verified computationally for `7 ≤ n ≤ 24`: in every case the residue `p mod n`
is `1` or `n − 1`. The split is governed by the Legendre symbol `(5 ∣ p)` / parity of `z(p)`.

## Conjecture 3 — Sharp law of apparition
**Statement.** For a prime `p ≠ 5`, `z(p) ∣ p − leg(5, p)` where `leg(5, p)` is the Legendre
symbol of 5 mod p (so `z(p) ∣ p − 1` when `p ≡ ±1 mod 5`, and `z(p) ∣ p + 1` when `p ≡ ±2 mod 5`).
This refines `z(p) ∣ p² − 1` to a divisor of `p ∓ 1`.
**Evidence.** Consistent with measured entry points: `z(11)=10∣10`, `z(19)=18∣18`,
`z(13)=7∣14`, `z(7)=8∣8`, `z(23)=24∣24`.

## Conjecture 4 — Primitive divisors are large
**Statement.** For `n ≥ 7`, every primitive prime divisor `p` of `F_n` satisfies `p ≥ n − 1`.
**Plan.** Immediate corollary of Conjecture 2 (`p ≡ ±1 mod n`, `p` prime `> 1`); independently
provable, strengthening this cycle's `p² ≥ n + 1`.

## Conjecture 5 — Lucas-number analogue
**Statement.** The Lucas numbers `L_n` have a primitive prime divisor for all `n ∉ {1, 6}`,
with the same entry-point machinery (`p ∣ L_n ↔ z(p) ∣ n ∧ n/z(p)` odd).
**Plan.** Port `fibEntryPoint`, the gcd identity, and the `primPart`/`native_decide` certificate
to `L_n`; combine the prime-index argument with a finite computational range, mirroring this
cycle's `fib_carmichael_iff_le_10000`. This is the first step toward the general
Bilu–Hanrot–Voutier primitive-divisor theorem for Lucas sequences `U_n(P,Q)`.
