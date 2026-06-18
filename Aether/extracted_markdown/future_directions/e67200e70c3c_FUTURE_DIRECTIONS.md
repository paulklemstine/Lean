# Future Directions — Rank of Apparition of Fibonacci Numbers

## Synthesis

This cycle totalised the Fibonacci entry-point theory. The catalog file
`Catalog/Shared/FibonacciLTE.lean` already carried a *per-prime predicate*
`IsFibEntry p z` (least positive `z` with `p ∣ F z`) together with the
strong-divisibility backbone `fib_gcd_eq` (`gcd(F m, F n) = F (gcd m n)`) and a
lifting-the-exponent valuation theorem. What was missing was a single **total
function** of the modulus and the clean divisibility law it should obey. We
built `Catalog/Shared/FibRankApparition.lean`, defining `fibRank m = sInf {k | 0
< k ∧ m ∣ F k}` and proving, `sorry`-free, the central characterisation
`m ∣ F k ↔ fibRank m ∣ k` for every positive `m` — not merely for primes.

The decisive structural insight is that primality was never the engine. The only
nontrivial inputs are (i) existence of *some* positive `k` with `m ∣ F k`, which
holds for all `m` by a pigeonhole on consecutive residue pairs
(`exists_pos_fib_dvd`, a generalisation of the catalog's prime-only
`prime_dvd_some_pos_fib`), and (ii) the gcd identity `fib_gcd_eq`. Together they
make `F` a strong divisibility sequence, and the entry-point law is a formal
consequence. Once `fib_dvd_iff_fibRank_dvd` is in hand, three corollaries fall
out almost mechanically: the bridge `IsFibEntry m z ↔ fibRank m = z` reconciling
the new function with the old predicate; **multiplicativity on coprime factors**
`fibRank (a*b) = lcm (fibRank a) (fibRank b)`, which reduces all computation of
`fibRank` to prime powers; and monotonicity `m ∣ n → fibRank m ∣ fibRank n`.

Nothing was disproved this cycle; the surprises were all simplifications. In
particular the coprime multiplicativity, which classically reads as a CRT
argument, becomes a two-line "both sides divide exactly the same `k`" antisymmetry
once the divisibility law is available. The boundary that resisted is `m = 0`,
where the apparition set is empty and `fibRank 0 = 0`; every theorem therefore
carries an explicit `0 < m` hypothesis, which is genuinely necessary rather than
cosmetic.

## Results Summary

- `exists_pos_fib_dvd`: proved — every positive `m` divides some positive
  Fibonacci number (pigeonhole), generalising the catalog's prime-only version.
- `fibRank` (def): the rank of apparition as a total function `ℕ → ℕ`.
- `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_le`, `not_dvd_fib_of_lt_fibRank`:
  proved — the basic specification (positivity, membership, minimality).
- `fib_dvd_iff_fibRank_dvd`: proved — **central theorem**: for `m > 0`,
  `m ∣ F k ↔ fibRank m ∣ k`; the complete answer to *when* `m` divides a
  Fibonacci number.
- `isFibEntry_iff_fibRank_eq`: proved — bridge `IsFibEntry m z ↔ fibRank m = z`,
  reconciling the new total function with the catalog predicate.
- `fibRank_mul_coprime`: proved — multiplicativity:
  `fibRank (a*b) = lcm (fibRank a) (fibRank b)` for positive coprime `a, b`;
  reduces `fibRank` to the prime-power case.
- `fibRank_dvd_of_dvd`: proved — monotonicity under divisibility of the modulus.
- `fibRank_five = 5`, `fibRank_thirteen = 7`: proved — sample values via the
  bridge; the latter exhibits a prime whose rank lies strictly below it.

## Research Directions

### Direction 1: The Lucas–Legendre bound on prime entry points
**Hypothesis**: For a prime `p ∉ {2,5}`, `fibRank p ∣ (p - legendreSym p 5)`,
hence `fibRank p ≤ p + 1`; and `fibRank 2 = 3`, `fibRank 5 = 5`.
**Test**: Prove `p ∣ F(p - (5|p))` from the catalog's quadratic-residue
machinery for `5 mod p`, then feed that single divisibility into
`fib_dvd_iff_fibRank_dvd` to obtain `fibRank p ∣ p - (5|p)`. Falsified by any
prime with `fibRank p > p + 1` (checkable instantly over the first 10⁴ primes).
**Why now**: `fib_dvd_iff_fibRank_dvd` is exactly the device that converts a
divisibility `p ∣ F N` into a *bound* on `fibRank p`; before it there was no
handle on the minimal index at all. The residue input `F(p)² ≡ 1 (mod p)`
(`fib_sq_mod_prime` in the catalog) is the shadow of the stronger congruence.
**If true**: every prime entry point is pinned into `[1, p+1]`, turning `fibRank`
on primes into a finite search and connecting it to the law of quadratic
reciprocity.
**If false**: a counterexample would expose a gap between the residue-square
identity and the true vanishing index — a genuinely new arithmetic phenomenon.

### Direction 2: Wall's prime-power law for entry points
**Hypothesis**: For an odd prime `p` and `e ≥ 1`,
`fibRank (p^e) = p^(e - min e w) * fibRank p`, where `w` is the largest exponent
with `p^w ∣ F(fibRank p)`.
**Test**: Combine `fib_dvd_iff_fibRank_dvd` with the catalog LTE theorem
`padicValNat_fib_lte` to compute `v_p(F k)` and identify the least multiplier of
`fibRank p` supplying `e` factors of `p`. Falsifiable per `(p, e)` by a direct
`padicValNat` computation.
**Why now**: with the divisibility law proved, `fibRank (p^e)` is no longer a
mysterious minimum but `fibRank p` scaled by a valuation deficit; the hard
analytic content is already isolated in `padicValNat_fib_lte`.
**If true**: together with `fibRank_mul_coprime` it yields a *complete*
multiplicative formula for `fibRank m` from its prime-power values.
**If false**: the failure would necessarily occur at a Wall–Sun–Sun prime
(`w ≥ 2`), so a counterexample would be one of the most sought-after objects in
the field — itself a landmark.

### Direction 3: Closing the Carmichael composite tail via the primitive part
**Hypothesis**: For every composite `n > 10000`, `F(n)` has a primitive prime
divisor; equivalently some prime `p` has `fibRank p = n`.
**Test**: Use the bridge `isFibEntry_iff_fibRank_eq` to recast "F(n) primitive"
as "some prime has entry point exactly `n`"; the only obstruction is an
intrinsic prime dividing `n` itself. Combine with a size estimate
`φ^{φ(n)} > n` (forcing a genuinely new prime once `φ(n)` is large) to discharge
the remaining `sorry` in `Catalog/Shared/CarmichaelProof.lean`. Falsifiable
instantly by any composite `n` with `primPart n = 1`.
**Why now**: the finite range `13 ≤ n ≤ 10000` is already settled by
`native_decide`; the entry-point reformulation proved this cycle isolates
*exactly one* possible non-primitive prime, reducing the classical cyclotomic
theory to a single quantitative inequality.
**If true**: completes a fully formal proof of Carmichael's theorem for the
Fibonacci sequence inside the catalog.
**If false**: would refute Carmichael's classical theorem — so any apparent
counterexample is far more likely to reveal a formalisation bug, a valuable
stress test of the catalog's `primPart` machinery.

### Direction 4: The Lucas-number entry point and a Fibonacci–Lucas bridge
**Hypothesis**: Define `lucasRank m` as the least positive `k` with `m ∣ L k`
(Lucas numbers, `L k = F(2k)/F(k)` for `k > 0`). Then `m ∣ L k ↔ lucasRank m ∣ k`
for `m > 0`, and for odd `m`, `fibRank m = lucasRank m` exactly when
`fibRank m ≡ 2 (mod 4)`.
**Test**: Transport the divisibility law via the identity `L k = F(2k)/F(k)`;
the parity criterion is then a statement about the 2-adic structure of
`fibRank m`. Checkable over all odd `m ≤ 1000` before any proof.
**Why now**: the Fibonacci entry-point theory is complete and `sorry`-free, and
Lucas numbers are definable directly from `Nat.fib`, so this transports a finished
theory rather than rebuilding one.
**If true**: yields a uniform "rank of apparition" framework covering both
Lucas sequences of the first and second kind.
**If false**: the precise parity threshold where `fibRank` and `lucasRank`
diverge would itself be the discovery.

### Direction 5: General Lucas sequences — abstracting away from Fibonacci
**Hypothesis**: For any nondegenerate Lucas sequence `U_n(P,Q)` that is a strong
divisibility sequence (`gcd(U_m, U_n) = U_{gcd(m,n)}`), the rank of apparition
`rank m = sInf {k | 0 < k ∧ m ∣ U_k}` satisfies `m ∣ U_k ↔ rank m ∣ k` and is
lcm-multiplicative on coprime moduli.
**Test**: Re-prove `fib_dvd_iff_fibRank_dvd` and `fibRank_mul_coprime` using only
the abstract strong-divisibility hypothesis plus existence of one entry point;
the current Fibonacci proofs already use *only* these two facts.
**Why now**: inspecting this cycle's proofs shows they never touch the Fibonacci
recurrence directly — only `fib_gcd_eq` and `exists_pos_fib_dvd`. The
abstraction is therefore a refactor, not new mathematics.
**If true**: a single reusable `StrongDivisibilitySequence` theory subsumes
Fibonacci, Lucas, Mersenne `2^n - 1`, and `a^n - b^n`, a high-leverage catalog
foundation.
**If false**: the obstruction would pinpoint exactly which Fibonacci-specific
fact (existence? the gcd identity?) fails for a candidate sequence, sharpening
the definition of "strong divisibility sequence" itself.
