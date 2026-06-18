# Future Directions — Fibonacci Primitive Divisors and the Cyclotomic Method

## Synthesis

The open `sorry` in `Shared.CarmichaelProof.fib_carmichael_composite` — the *infinite
composite tail* of Carmichael's primitive-divisor theorem for Fibonacci numbers — is now
closed. Carmichael's theorem (every `F_n` with `n ∉ {1,2,6,12}` has a primitive prime
divisor) is therefore complete for the composite case across all `n ≥ 13`: the range
`13 ≤ n ≤ 10000` by `native_decide`, and `n > 10000` by a genuine, axiom-clean proof.

The proof was assembled from two self-contained halves, both proved from scratch (none of
this machinery exists in Mathlib):

* **Size half** (`Shared.CarmichaelTail`): the homogeneous cyclotomic value
  `Φ_n = ∏_{d∣n} F_d^{μ(n/d)}` satisfies `goldenRatio^{φ(n)} ≤ 5·Φ_n`, via Binet's formula
  and a finite-product correction bound `R_n ≥ 1/5`.
* **Structural half** (`Shared.CarmichaelStructure`): `Φ_n` is a positive integer dividing
  `F_n`, and its *imprimitive part* divides `n`. The engine is a Fibonacci
  lifting-the-exponent law (proved via a matrix-binomial identity, with the prime `2`
  handled by an exact 2-adic valuation) together with the integer von Mangoldt identity
  `∑_{d∣m} μ(m/d)·v_p(d) = [m is a power of p]`. Since `Φ_n > n ≥ (imprimitive part)` for
  `n > 10000`, a primitive prime divisor must exist.

These pieces are deliberately general: strong divisibility (`Nat.fib_gcd`), Binet growth,
and the Möbius/valuation calculus are the only structural inputs. That generality is what
the directions below try to exploit.

## Direction 1 — Eliminate the computational range: a uniform proof for all `n`

Conjecture: `fib_carmichael` holds for every `n ∉ {1,2,6,12}` with **no** `native_decide`
step, by lowering the threshold `10000` all the way down through a sharper size analysis of
`Φ_n`. Numerically `Φ_n > n` already fails only at `n ∈ {4,6,8,12}`, and at `n = 4,8` a
primitive divisor still exists because `Φ_n > n` is *sufficient but not necessary*.

The key insight is that the only obstructions are the finitely many `n` where the intrinsic
factor can swallow the whole cyclotomic value, and these can be characterised exactly
(`Φ_n` equals a prime power of the intrinsic prime) rather than enumerated. Why now? We
already possess the exact prime-by-prime description of `Φ_n` (`cyclo_signed_sum_bound`),
so the remaining work is a finite case analysis of the intrinsic prime, not a 10⁴-wide
decision procedure — making the theorem kernel-checkable without `Lean.ofReduceBool`.

## Direction 2 — Zsygmondy for general Lucas sequences

Conjecture: the entire pipeline (entry points → matrix-binomial LTE → von Mangoldt
valuation → Binet size bound) transfers verbatim to a Lucas sequence `U_n(P,Q)` with
`P^2 - 4Q > 0` and `gcd(P,Q)=1`, yielding Carmichael/Zsygmondy primitive-divisor existence
for `U_n` with the classical finite exception set.

The key insight is that nothing in `fib_padicVal_mul_prime` or `moebius_padicVal_sum` uses
`Q = -1`; the companion matrix `!![P, -Q; 1, 0]` satisfies the same `A^N = U_N·A + (-Q)·U_{N-1}·1`
decomposition, and Binet's formula generalises with the two real roots replacing `φ, ψ`.
Why now? Our Fibonacci proof was engineered to avoid `ℤ[√5]` and any sequence-specific
trick, so the abstraction cost is the genuinely new content (handling `Q ≠ -1` in the
2-adic and discriminant-prime cases) rather than a rewrite.

## Direction 3 — Effective and constructive primitive divisors

Conjecture: for composite `n > 10000` the least primitive prime divisor of `F_n` is at most
`Φ_n` itself, and more sharply is found among the prime factors of the computable integer
`cycloA n / cycloB n`; one can extract an explicit, terminating algorithm returning a
primitive prime together with a certificate (its rank of apparition `= n`).

The key insight is that `cycloA` and `cycloB` are *computable* `ℕ`-valued products and our
proof shows their quotient is a positive integer dividing `F_n` whose every prime with
`v_p > v_p(n)`-excess has entry point exactly `n`. Why now? The size/structure dichotomy is
already constructive (no classical choice in the witness), so a `#eval`-able
`primitiveDivisor n` with a proof of correctness is within reach and would connect this
number theory to verified factoring heuristics.

## Direction 4 — A reusable cyclotomic-value API

Conjecture: the trio "`Φ_n` is a positive integer", "`Φ_n ∣ F_n`", and "the entry-point
classification of the primes of `Φ_n`" can be packaged as a standalone theory of the
*cyclotomic value of a strong divisibility sequence*, independent of the size bound, and
reused for divisibility identities such as `F_n = ∏_{d∣n} Φ_d` and `Φ_p = F_p` for prime `p`.

The key insight is that integrality of `Φ_n` is not an extra hypothesis but a *corollary* of
the signed valuation bound `0 ≤ ∑_{d∣n} μ(n/d) v_p(F_d)` already proved in
`cyclo_signed_sum_bound`; the same sum, read with its upper bound, gives the divisibility.
Why now? Both inequalities are in hand for Fibonacci; promoting them to an interface keyed
only on `gcd(a_m, a_n) = a_{gcd(m,n)}` would let downstream files (Lucas, Mersenne, repunits)
inherit the structure for free.

## Direction 5 — Asymptotics of the cyclotomic correction

Conjecture: the Binet correction satisfies `binetCorr n → 1` as `n → ∞` along any sequence
avoiding small divisors, giving the two-sided estimate `Φ_n = goldenRatio^{φ(n)}·(1+o(1))`
and hence precise counts of primitive prime divisors of `F_n` weighted by `v_p`.

The key insight is that `binetCorr n = ∏_{d∣n}(1-(ψ/φ)^d)^{μ(n/d)}` is dominated by its
`d = 1` factor `(1-ψ/φ)^{μ(n)} = √5^{±1}` plus a tail that is uniformly `1 + O(φ^{-2})`, so
the same finite-product control used for the lower bound `R_n ≥ 1/5` upgrades to a genuine
limit. Why now? The lower bound already isolates the dominant factor and a summable tail;
turning the inequality into an asymptotic is a quantitative refinement of an argument we
have, not a new method, and it would open the door to density theorems for Fibonacci
primitive divisors.
