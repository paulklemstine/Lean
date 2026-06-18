# Future Directions — Carmichael primitive divisors of Fibonacci numbers

This cycle closed the **prime-index** case of Carmichael's theorem
(`fib_primitive_divisor_prime`, in `Shared/CarmichaelHelper.lean`), proved a new
**infinite composite family** `n = 2p` (`fib_primitive_divisor_two_mul_prime`, in
`Shared/FibCarmichaelFamilies.lean`), and unified both
(`fib_primitive_divisor_covered`, in `Shared/FibCarmichaelUnion.lean`). The single
remaining open `sorry` is the arbitrary composite tail `n > 10000` in
`Shared/CarmichaelProof.lean`. The conjectures below are derived from that work.

---

## 1. The companion-number method extends to `n = 4p` and `n = p·q`.
**Conjecture.** For distinct primes `p, q ≥ 5`, `F(pq)` has a primitive prime
divisor obtainable from the "cyclotomic" combination
`Φ_{pq} = F(pq)·F(1) / (F(p)·F(q))`, and similarly `F(4p)` from `F(4p)·F(2)/(F(2p)·F(4))`.
**The key insight is** that an index with only a *bounded number* of proper
divisors keeps the non-primitive part coprime-controlled, exactly as `2p` is
controlled by the single Lucas factor `L(p) = F(2p)/F(p)`.
**Why now?** This cycle showed the `2p` case reduces to one coprimality fact
(`fib_coprime_fibComp_of_prime`); `pq` needs only one more Möbius level, all
expressible with the in-Mathlib identity `Nat.fib_gcd` and `Nat.fib_two_mul`.

## 2. A Lucas-number library is the missing keystone, not analysis.
**Conjecture.** Introducing `L : ℕ → ℕ`, `L n = 2·F(n+1) − F(n)`, with the
identities `F(2n) = F(n)·L(n)`, `gcd(F n, L n) ∣ 2`, and `L(m) ∣ F(n)` iff the
"odd part" condition holds, suffices to mechanise Carmichael for *all* even
indices `n = 2m` with `m` square-free.
**The key insight is** that `fibComp` in this cycle is exactly `L`, and every step
of the `2p` proof used only divisibility/coprimality of `L`, never real-analytic
size bounds.
**Why now?** Mathlib has Fibonacci but *no* Lucas numbers; a small, self-contained
`Lucas` file (≈ the lemmas already proved here, generalised) is independently
useful and unlocks a large composite range.

## 3. The general tail is sharp at the abundancy threshold.
**Conjecture.** The elementary bound `F(n) ≤ n · ∏_{d|n, d<n} F(d)` proves
Carmichael's theorem precisely for *deficient and perfect* `n` (`σ(n) ≤ 2n`), and
fails *only* for abundant `n`, where the cyclotomic factor `Φ_n` is genuinely
required.
**The key insight is** that the loss in the crude product bound equals
`φ^{σ(n) − 2n}`, which is `≤ 1` exactly when `n` is non-abundant.
**Why now?** This cycle's Analysis block already isolated `σ(n)` vs `2n` as the
break point; turning it into a theorem partitions the open tail into a provable
majority and a hard abundant minority.

## 4. `native_decide`-free verification of the finite range.
**Conjecture.** The range `13 ≤ n ≤ 10000` currently closed by `native_decide`
(`primPart_check`) can be re-proved by a kernel-checkable `decide`-free argument
using the entry-point function `z(p)` and the bound `z(p) ∣ p − (5/p)`.
**The key insight is** that primitivity of a prime `q | F(n)` is equivalent to
`z(q) = n`, a decidable predicate on a *finite* set of candidate primes per `n`.
**Why now?** The cycle's `fib_primitive_divisor_prime` already encodes the
`z(q)`-style gcd reasoning; lifting it to a verified finite check removes the only
`native_decide` dependency in the Carmichael chain.

## 5. Carmichael for Lucas sequences `U_n(P, Q)`, not just Fibonacci.
**Conjecture.** The `n = 2p` argument generalises verbatim to any nondegenerate
Lucas sequence `U_n` with companion `V_n`, giving primitive divisors of `U_{2p}`
from prime factors of `V_p`.
**The key insight is** that the only Fibonacci-specific inputs used here were
`U_n(1,−1) = F_n`, the doubling `U_{2n} = U_n V_n`, and `gcd(U_n, V_n) ∣ 2` —
all of which hold for general `(P, Q)`.
**Why now?** It converts a single-sequence result into a template for Zsygmondy's
theorem, the structure the open composite tail ultimately needs.
