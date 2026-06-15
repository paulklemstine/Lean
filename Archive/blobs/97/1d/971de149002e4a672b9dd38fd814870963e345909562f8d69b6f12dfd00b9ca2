# Future Directions — The Local-to-Global Obstruction for Fibonacci Primitive Divisors

## Synthesis

This cycle attacked the lone surviving `sorry` in the catalog's Carmichael
development — the composite-tail case `fib_carmichael_composite` (composite
`n > 10000`) of Carmichael's primitive-divisor theorem for Fibonacci numbers — and,
finding it to be the genuinely deep cyclotomic core of the theorem, reorganized the
surrounding theory into a *sharp, decidable obstruction* that isolates exactly what
the tail still needs.

Three structural facts were established, all `sorry`-free:

* **The prime-index case is purely order-theoretic** (`Shared.CarmichaelHelper.fib_primitive_divisor_prime`).
  When the index is prime, the divisor poset is the two-element chain `{1, p}`, so
  *every* prime factor of `F p` is automatically primitive: its Fibonacci entry
  point divides `p`, cannot be `1` (that would force it to divide `F 1 = 1`), hence
  equals `p`. No size estimate is involved.

* **The computable primitive part detects primitivity *exactly*** — the new headline,
  `Shared.CarmichaelObstruction.one_lt_primPart_iff_hasPrimitive`:
  > `1 < primPart n  ↔  F n has a primitive prime divisor`   (for `n ≥ 3`).
  The catalog (`Shared.CarmichaelProof.primPart_implies_primitive`,
  `Speculative.AutoResearch.CarmichaelComposite.primitive_of_fibCoprimePart_pos`)
  had only the *sufficiency* direction `1 < primPart n → …`. The converse proved here
  shows the obstruction is *faithful*: a primitive prime `p` (entry point exactly `n`)
  is coprime to every `F d` with `d ∣ n`, `d < n`, and the repeated-gcd "strip"
  operation `stripAllAux` is `p`-adically inert away from the stripped modulus
  (`stripAllAux_keeps_coprime_factor`), so `p` survives into `primPart n`.

* **The whole Carmichael problem collapses to a single arithmetic inequality.**
  By the biconditional, Carmichael's theorem for composite `n` is *equivalent* to
  `primPart n > 1`, i.e. to the claim that the "obstruction class" never trivializes.
  The `native_decide` census (`n ≤ 10000` in `Shared.CarmichaelProof`, `n ≤ 50000`
  in `Speculative.AutoResearch.FibPrimitive`) is therefore not merely *sufficient*
  but *characteristic*: it certifies the obstruction is nontrivial throughout its
  range, and the only thing standing between the catalog and a complete proof is a
  *lower bound on `primPart n` valid for all large composite `n`*.

The local-to-global reading: the proper divisors `d ∣ n` are the open cover, the
"primes already seen by index `d`" are the local sections, `primPart n` is the
obstruction to gluing a *new* prime at the global index `n`, and the biconditional
says this obstruction is exact.

## Results Summary

| Result | File | Status |
| --- | --- | --- |
| `fib_primitive_divisor_prime` (prime-index Carmichael) | `Catalog/Shared/CarmichaelHelper.lean` | proved, `sorry = 0` |
| `stripAllAux_keeps_coprime_factor` | `Catalog/Shared/CarmichaelObstruction.lean` | proved, `sorry = 0` |
| `primPart_keeps_primitive` | `Catalog/Shared/CarmichaelObstruction.lean` | proved, `sorry = 0` |
| `hasPrimitive_imp_one_lt_primPart` (converse obstruction) | `Catalog/Shared/CarmichaelObstruction.lean` | proved, `sorry = 0` |
| `one_lt_primPart_iff_hasPrimitive` (**complete biconditional**) | `Catalog/Shared/CarmichaelObstruction.lean` | proved, `sorry = 0` |

Build hygiene also restored: the package `srcDir = "Catalog"` was added to
`lakefile.toml` (without it no module path resolves); the missing modules
`Shared.CarmichaelHelper` and `Shared.CarmichaelComposite` were supplied (the latter
as a re-export shim) so the historical Carmichael import chain
(`Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelComposite`,
`Speculative.AutoResearch.FibPrimitive`, `Speculative.CarmichaelPrimitiveDivisor`)
elaborates again; and a malformed (un-opened) header comment in
`Speculative.AutoResearch.FibPrimitive` was closed. After this, the entire chain
builds with exactly **one** remaining `sorry`: the cyclotomic tail
`Shared.CarmichaelProof.fib_carmichael_composite`.

## Research Directions

### 1. Close the tail with a cyclotomic lower bound on the primitive part.
The remaining `sorry` is equivalent (by `one_lt_primPart_iff_hasPrimitive`) to:
`primPart n > 1` for every composite `n > 10000`. The classical route is the
homogeneous-cyclotomic factorization `F_n = ∏_{d ∣ n} Φ_d(φ, ψ)` of the Fibonacci
Binet form, where `Φ_n(φ, ψ) = ∏_{d ∣ n} F_d^{μ(n/d)}` is an integer whose only
possible *intrinsic* (non-primitive) prime factor is the largest prime factor of `n`,
to the first power. **The key insight is** that `|Φ_n(φ, ψ)| ≥ (φ - 1)^{φ(n)}` grows
super-polynomially in `n` while the intrinsic factor is bounded by `n`, so for `n`
beyond a small explicit threshold `Φ_n` *must* shed a primitive prime — and this
exact gap is what `primPart n > 1` records. **Why now?** Mathlib already carries
`Polynomial.cyclotomic`, golden-ratio Binet machinery, and `Nat.fib` valuation
lemmas; the catalog's own
`Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean` supplies a
Fibonacci Lifting-the-Exponent lemma (`fib_lte`) and an exponential lower bound
(`fib_exponential_lower_bound`). The pieces to assemble `Φ_n` as a Möbius product and
bound it below are, for the first time, all present in the environment.

### 2. Lift the biconditional from Fibonacci to arbitrary nondegenerate Lucas sequences.
`one_lt_primPart_iff_hasPrimitive` never used any Fibonacci-specific identity beyond
the strong-divisibility law `gcd(F_m, F_n) = F_{gcd(m,n)}`. **The key insight is**
that the entire obstruction calculus — entry points, `stripAllAux`'s `p`-adic
inertness, and the local-to-global faithfulness — depends only on the sequence being
a *strong divisibility sequence*, so the biconditional should hold verbatim for any
Lucas sequence `U_n(P, Q)` with `gcd(P, Q) = 1`. **Why now?** The catalog already
abstracts strong divisibility (`Applications.StrongDivisibilitySequences`,
`Bridges.StrongDivisibilitySequences`); re-stating `primPart`/`stripAllAux` against
that interface would immediately generalize the result and quarantine the *only*
sequence-dependent input (the size estimate of Direction 1) — a clean falsifiable
refactor: either every proof goes through against the abstract `IsStrongDivSeq`
interface, or a concrete identity is silently load-bearing.

### 3. Prove an effective quantitative obstruction `primPart n ≥ φ^{φ(n)/2}`.
Beyond mere positivity, conjecture the *explicit* bound `primPart n ≥ φ^{φ(n)/2}` for
all `n ≥ 13`, where `φ` is the golden ratio and `φ(n)` Euler's totient. **The key
insight is** that the primitive part is essentially `|Φ_n(φ, ψ)|` divided by at most
one intrinsic prime `≤ n`, and `|Φ_n| ≈ φ^{φ(n)}`, so half the exponent is a safe,
checkable margin. **Why now?** This is *immediately falsifiable by computation* — the
existing `native_decide` harness can be re-pointed to test `primPart n ≥ φ^{φ(n)/2}`
(in rationals/`Nat` with a Fibonacci surrogate for `φ^{φ(n)/2}`) across `[13, 50000]`
before any proof effort is spent; a single counterexample kills it, and survival
across that range is strong evidence for the exponent constant.

### 4. Formalize entry-point assignment as a presheaf with a cohomological obstruction.
Make the local-to-global language literal: on the divisor poset of `n` (a finite
lattice), the assignment `d ↦ { primes p : entry point of p divides d }` is a
*presheaf of prime-sets* under restriction, and primitivity at `n` is the failure of
the global section to be covered by proper-divisor sections. **The key insight is**
that `primPart n` is precisely a representative of the resulting degree-one
obstruction class — the cokernel of the restriction map from `n` to its maximal
proper divisors — so Carmichael's theorem becomes "this `H^1`-style class is nonzero".
**Why now?** Mathlib's order/lattice and `Finset` infrastructure makes the divisor
poset and its restriction maps directly definable, and the present biconditional
already gives the computable cocycle; phrasing it cohomologically would let
inclusion-exclusion (`Nat.ArithmeticFunction.moebius`) compute the class, testably
matching `primPart` on small `n`.

### 5. Conjecture and test multiplicativity of the obstruction on coprime indices.
Conjecture that for coprime `m, n > 1`, the primitive parts interact multiplicatively
up to intrinsic primes: `rad(primPart (m*n))` equals `rad(primPart m · primPart n)`
away from primes dividing `m*n`. **The key insight is** that entry points are
"multiplicative coordinates" — `p` has entry point `mn` iff its local data splits as
entry-point-`m` and entry-point-`n` pieces under CRT on the index — so the global
obstruction should factor through the coprime decomposition of the index. **Why now?**
The catalog's `Novelty.FibCarmichaelStructure` already proves
`fibEntry_coprime_mul` and `fibEntry_prod_coprime` (multiplicativity of entry points
across coprime moduli); combined with `one_lt_primPart_iff_hasPrimitive`, this gives
both the precise statement and an immediate `native_decide`-style falsification test
over coprime pairs in a bounded range.
