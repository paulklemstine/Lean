# Future Directions — The Entry Point as the Master Invariant of Fibonacci Divisibility

## Synthesis

This cycle isolated a single structural object — the **Fibonacci entry point**
`z(p)` (the least `k > 0` with `p ∣ F(k)`, the "rank of apparition") — and showed
that it controls the *entire* divisibility behaviour of the Fibonacci sequence that the
Carmichael cluster of this catalogue had only been able to approach computationally.

The new file `Catalog/Pythagorean/FibonacciEntryPoint.lean` proves, with **zero
`sorry`** and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

* **Existence** (`exists_pos_dvd_fib`): every `p > 0` divides some positive-index
  Fibonacci number. Proved by pigeonhole on consecutive pairs `(F k, F (k+1))` in
  `ZMod p`, run backwards through the invertible recurrence so the repeated pair returns
  to `(F 0, F 1) = (0, 1)`.
* **Lattice collapse** (`dvd_fib_iff_entryPt_dvd`): `p ∣ F k ↔ z(p) ∣ k`. The set of
  indices killed by `p` is *exactly* the multiples of `z(p)` — i.e. it is the principal
  ideal `(z(p)) ⊆ ℕ`. This is the conceptual origin of strong divisibility.
* **Primitivity = equality** (`primitive_iff_entryPt_eq`): `p` is a primitive divisor of
  `F n` (it divides `F n` but no earlier `F k`) **iff** `z(p) = n`.

The payoff is a clean reformulation of the catalogue's primitive-divisor machinery. The
existing files `Catalog/Shared/CarmichaelProof.lean` (`bridge_lemma`) and
`Catalog/Speculative/AutoResearch/FibPrimitive.lean` (`fib_primitive_iff_divisors`,
`prime_dvd_fib_gcd`) only *reduce* primitivity to a check over proper divisors. With
`primitive_iff_entryPt_eq`, "`F n` has a primitive prime divisor" becomes the crisp
arithmetic statement "**there exists a prime `p` with `z(p) = n`**" — i.e. `n` is in the
image of the rank-of-apparition map.

## Results Summary

| Result | File | Status |
|---|---|---|
| `exists_pos_dvd_fib` | `FibonacciEntryPoint.lean` | proved |
| `dvd_fib_iff_entryPt_dvd` | `FibonacciEntryPoint.lean` | proved |
| `entryPt_dvd_of_dvd_fib`, `entryPt_le_of_pos` | `FibonacciEntryPoint.lean` | proved |
| `primitive_iff_entryPt_eq` | `FibonacciEntryPoint.lean` | proved |
| `fib_carmichael_composite` (tail `n > 10000`) | `CarmichaelProof.lean` | **still open** (1 `sorry`) |

The infinite tail of Carmichael's theorem remains the single genuine gap in the cluster.
The finite range `13 ≤ n ≤ 10000` is discharged by `native_decide`; the tail is exactly
the surjectivity-type statement above and is genuinely a research-level theorem
(Carmichael 1913; the general `n` case is Bilu–Hanrot–Voutier 2001). It was attempted
this cycle and not closed; the directions below lay out the realistic route.

---

## Direction 1 — Fibonacci Lifting-the-Exponent (the keystone lemma)

**Conjecture.** For an odd prime `p` with entry point `z(p) = m` and `m ∣ n`,
`padicValNat p (F n) = padicValNat p (F m) + padicValNat p (n / m)`.

The key insight is that the entry point already proved here turns this into a purely
2-adic/`p`-adic statement about the companion matrix `M = !![1,1;1,0]`: in
`ZMod (p^j)`, `M^m ≡ I + p^{v} N` for a nilpotent-mod-`p` perturbation `N`, and
`(I + p^v N)^k` expands binomially, so the `p`-valuation increases by exactly
`padicValNat p k`. Mathlib already has the generic LTE (`multiplicity.Nat.pow_sub_pow`
/ `padicValNat` lemmas); the work is transporting it across the matrix eigenbasis in
`ℤ_p[√5]`.

**Falsifiable test.** `#eval` the identity for `p ∈ {3,7,11,13}`, `m = z(p)`, and
`n = m·k` for `k ≤ 30`; any failure refutes the statement of the lemma as phrased.

**Why now?** With `dvd_fib_iff_entryPt_dvd` the hypothesis `m ∣ n` is no longer an
ad-hoc assumption but the *characterisation* of when `p ∣ F n`, so the LTE lemma can be
stated and used without re-deriving entry-point divisibility each time.

## Direction 2 — Closing the Carmichael tail via the primitive-part lower bound

**Conjecture.** For all composite `n > 12`, the homogeneous-cyclotomic primitive part
`Φ_n := ∏_{d ∣ n} F(d)^{μ(n/d)}` satisfies `Φ_n > n`, and every prime dividing `Φ_n` to
the full multiplicity is primitive.

The key insight is that `primitive_iff_entryPt_eq` reduces the whole tail to "some prime
has `z(p) = n`", and a prime `p ∣ Φ_n` with `p ∤ n` *must* have `z(p) = n` (the only
non-primitive prime allowed in `Φ_n` is the largest prime factor of `n`, contributing at
most one factor of `n`). So a bound `Φ_n > n` forces a genuine primitive prime. The
bound follows from `F(n) ≥ φ^{n-2}` and `deg Φ_n = φ(n)` with `φ(n) ≥ √n`.

**Falsifiable test.** Compute `Φ_n` and the largest prime factor `P(n)` for all composite
`n ∈ [13, 200]`; the prediction `Φ_n / gcd(Φ_n, n) > 1` must never fail.

**Why now?** The catalogue already verifies the statement computationally to `n ≤ 50000`
(`fib_primitive_le_50000`). The only missing ingredient is the *analytic* tail, and the
entry-point reformulation tells us precisely which prime to extract, removing the need
for the full Bilu–Hanrot–Voutier classification.

## Direction 3 — Periodicity (Pisano) from the entry point

**Conjecture.** The Pisano period `π(p)` is a multiple of `z(p)`, and
`π(p) / z(p) ∈ {1, 2, 4}` for every prime `p`.

The key insight is that the pigeonhole construction inside `exists_pos_dvd_fib` already
produces a return of the pair `(F k, F (k+1))` to `(0,1)` — that return index *is* the
Pisano period, and the entry point is the first time the first coordinate alone hits `0`.
The quotient `π(p)/z(p)` is the multiplicative order of the unit `F(z(p)+1) (mod p)`,
which squares into the group of `±√5`-twists, bounding it by `4`.

**Falsifiable test.** For all primes `p < 2000`, check `z(p) ∣ π(p)` and
`π(p)/z(p) ∈ {1,2,4}`; a single counterexample refutes the quotient claim.

**Why now?** `exists_pos_dvd_fib` already builds the periodic structure as a byproduct;
formalising `π(p)` and re-using that construction is low-marginal-cost and would give
Mathlib its first general Pisano-period existence theorem.

## Direction 4 — Entry points and quadratic reciprocity (`z(p) ∣ p − (5/p)`)

**Conjecture.** For every prime `p ≠ 2, 5`, `z(p) ∣ p − (5 | p)` where `(5 | p)` is the
Legendre symbol; in particular `z(p) ≤ p + 1`.

The key insight is that `dvd_fib_iff_entryPt_dvd` converts the classical congruence
`p ∣ F(p − (5/p))` (a consequence of Fermat in `𝔽_p[√5]`) directly into the divisibility
`z(p) ∣ p − (5/p)` — no separate minimality argument is needed once the lattice-collapse
theorem is in hand.

**Falsifiable test.** For all odd primes `p < 5000` with `p ≠ 5`, verify
`z(p) ∣ (p − legendreSym p 5)`; any failure refutes the divisibility.

**Why now?** Mathlib has `legendreSym`, `ZMod.pow_card`, and Gauss-sum reciprocity; the
entry-point bridge is exactly the missing glue that makes these classical results say
something about the *first* apparition rather than just *an* apparition.

## Direction 5 — The image of `z` and a Fibonacci analogue of Artin's conjecture

**Conjecture.** The set `{ z(p) : p prime }` has natural density `1` in `ℕ` — almost every
integer is the rank of apparition of some prime — and equals
`{ n : F(n) has a primitive prime divisor } ∪ {1, 2}`.

The key insight is `primitive_iff_entryPt_eq`: the image of `z` is *literally* the set of
`n` admitting a primitive divisor, so Carmichael's theorem (Direction 2) is the statement
"every `n ∉ {1,2,6,12}` is in the image of `z`", and density-1 hitting of the *primes*
themselves is a Fibonacci-flavoured Artin primitive-root problem.

**Falsifiable test.** Tabulate `z(p)` for primes `p < 10^5` and check that every
`n ∉ {1,2,6,12}` up to `100` appears; a missing value (other than the four exceptions)
would refute the image characterisation.

**Why now?** The forward inclusion is *already a theorem of this cycle*
(`primitive_iff_entryPt_eq`). Only the surjectivity tail (Direction 2) stands between the
catalogue and a complete, formal description of the image of the rank-of-apparition map.
