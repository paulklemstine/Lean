# Future Directions — Fibonacci Entry-Point (Rank of Apparition) Theory

## Synthesis

This cycle closed two open `sorry` placeholders flagged by the priority list and
extended the catalog's Fibonacci entry-point theory into a small, self-contained
algebraic toolkit. The first closure was the **lcm law**
`fibEntryPt_mul_coprime` (`α(a·b) = lcm(α a, α b)` for coprime `a, b`) in
`Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`, previously a
research target. The structural lesson is that the entry-point characterization
`p ∣ F(k) ↔ α(p) ∣ k` never used primality of `p`, so it applies verbatim to
arbitrary moduli `a`, `b`, and `a·b` simultaneously; coprimality only enters to
turn `ab ∣ F(k)` into the conjunction `a ∣ F(k) ∧ b ∣ F(k)`, after which
`Nat.lcm_dvd_iff` collapses two principal ideals of `ℕ` into one. The entry point
is, in effect, a *homomorphism from the divisibility lattice of moduli to the
divisibility lattice of indices*.

The new file `Speculative/AutoResearch/FibonacciEntryPointReconstruction.lean`
makes that slogan precise. It proves **monotonicity** (`a ∣ b ⟹ α(a) ∣ α(b)`,
unconditionally), the **fixed-point law** `α(F n) = n` for `n ≥ 3` (so `α` is a
left inverse of `F` and is surjective onto `[3, ∞)`), and the **unconditional
lower bound** `lcm(α a, α b) ∣ α(a·b)`. The Critic's contribution is the sharp
boundary: an explicit disproof `α(2·2) = α(4) = 6 ≠ 3 = lcm(α 2, α 2)`. This both
shows coprimality is *necessary* in the lcm law and **corrects** a heuristic in
the parent file, which claimed the non-coprime defect makes `α(a·b)` "strictly
smaller" than the lcm: in fact the lower bound forces `α(a·b)` to be a strict
*multiple* — strictly **larger**.

What failed / what is still open: the genuinely hard `sorry` in
`Shared/CarmichaelProof.lean` — the infinite tail of Carmichael's primitive-divisor
theorem for composite `n > 10000` — was left untouched because it requires the full
Zsygmondy/primitive-divisor machinery for Lucas sequences, which is not in Mathlib.
The fixed-point law `α(F n) = n` is suggestive here: it shows every index `n ≥ 3`
*is* an apparition index of *some* modulus (namely `F n`), so Carmichael is exactly
the statement that `n` is the apparition index of some *prime*. That reframing is
the seed for Direction 3 below.

## Results Summary

- `FibEntryChar.fibEntryPt_mul_coprime`: **proved** — for coprime `a, b` each with an
  entry point, `α(a·b) = lcm(α a, α b)`; lets `α` be reconstructed from a coprime
  factorization. (Closed a prior `sorry`.)
- `FibEntryRecon.fibEntryPt_dvd_of_dvd`: **proved** — `a ∣ b ⟹ α(a) ∣ α(b)`; entry
  point is monotone for the divisibility order, with no coprimality needed.
- `FibEntryRecon.fibEntryPt_fib`: **proved** — `α(F n) = n` for `n ≥ 3`; `α` left-inverts
  `F`, hence is surjective onto `{n | 3 ≤ n}`.
- `FibEntryRecon.fibEntryPt_lcm_dvd`: **proved** — `lcm(α a, α b) ∣ α(a·b)`
  unconditionally; the always-valid half of the lcm law.
- `FibEntryRecon.fibEntryPt_two` / `fibEntryPt_four`: **proved** — `α(2) = 3`, `α(4) = 6`;
  explicit apparition indices.
- `FibEntryRecon.fibEntryPt_lcm_strict`: **disproved (counterexample)** — `α(2·2) ≠
  lcm(α 2, α 2)`; coprimality is necessary and the defect is always a strict
  multiple (larger), not smaller.
- `Shared.fib_carmichael_composite` (infinite tail, `n > 10000`): **still open
  (`sorry`)** — requires Zsygmondy-type primitive-divisor theory not yet in Mathlib.

## Research Directions

### Direction 1: Full factorization reconstruction of `α`
**Hypothesis**: For every `m ≥ 1` admitting an entry point,
`α(m) = lcm over prime powers p^e ∥ m of α(p^e)`, i.e. `α(m)` is determined by the
entry points of the maximal prime powers dividing `m`.
**Test**: Prove by strong induction on the number of distinct prime factors of `m`,
peeling off one coprime prime power at a time and applying
`fibEntryPt_mul_coprime`; the base case is a single prime power. Falsified if any
concrete `m` (e.g. `m = 12, 60`) violates the lcm formula under `#eval`.
**Why now**: This cycle proved the two-factor coprime lcm law and the monotonicity
that controls the inductive step, so the only remaining work is the bookkeeping of
`Nat.factorization`. The key insight is that `fibEntryPt_mul_coprime` is already
the full inductive engine — coprimality of `p^e` with the remaining cofactor is
automatic.
**If true**: `α` becomes fully computable from a factorization, reducing all
apparition questions to the prime-power case.
**If false**: there is a hidden interaction between prime powers in `F`, which would
be a surprising failure of multiplicativity worth isolating.

### Direction 2: The prime-power law and Wall–Sun–Sun primes
**Hypothesis**: For an odd prime `p` with entry point `α(p)`,
`α(p^{e}) = p^{e-1} · α(p)` for all `e ≥ 1`, *unless* `p` is a Wall–Sun–Sun prime,
in which case `α(p^2) = α(p)`.
**Test**: Computationally verify `α(p^2) = p · α(p)` for all primes `p < 10^4`
(none of which are known Wall–Sun–Sun), via the `entryPt_eq_iff_primitive` route
used for `fibEntryPt_four`; then attempt the general `e` step by induction using
`fibEntryPt_dvd_of_dvd` (which already gives `α(p^e) ∣ α(p^{e+1})`).
**Why now**: `fibEntryPt_dvd_of_dvd` supplies the divisibility skeleton
`α(p^e) ∣ α(p^{e+1})`, so only the *exact multiplier* `p` is missing. The key
insight is that the lifting-the-exponent behaviour of `p` in `F` is exactly what
distinguishes ordinary primes from Wall–Sun–Sun primes, turning a deep open
problem into a sharply stated divisibility identity.
**If true**: combined with Direction 1 this gives a closed-form `α(m)`.
**If false**: the counterexample *is* a Wall–Sun–Sun prime — a celebrated open
search — so even a disproof is a major event.

### Direction 3: Carmichael's tail via apparition surjectivity onto primes
**Hypothesis**: For composite `n > 12`, `F(n)` has a prime divisor `p` with
`α(p) = n` (a primitive prime divisor), closing the `sorry` in
`Shared/CarmichaelProof.lean`.
**Test**: Formalize the primitive part `Φ_n = ∏_{α(p)=n} p^{...}` and show it
exceeds `1` by bounding `F(n)` against the product of `F(d)` over proper divisors
`d ∣ n`, i.e. a Zsygmondy-style cyclotomic argument for the Lucas sequence `F`.
Falsified by any composite `n` whose every prime divisor of `F(n)` already divides
an earlier `F(k)`.
**Why now**: `fibEntryPt_fib` proves `α(F n) = n`, so *every* `n ≥ 3` is the
apparition index of the explicit modulus `F n`; Carmichael is precisely the
strengthening "…of a *prime* modulus." The key insight is that the entry-point
characterization reduces "primitive divisor" to "a prime with `α(p) = n`," turning
the analytic theorem into a counting statement about the fibers of `α`.
**If true**: closes the headline catalog `sorry` and yields a fully formal
Carmichael theorem.
**If false**: pinpoints exactly which composite indices break the cyclotomic
size bound.

### Direction 4: When does equality hold without coprimality?
**Hypothesis**: `α(a·b) = lcm(α a, α b)` holds **iff** `gcd(a,b)` shares no prime
`p` for which `p ∣ gcd(F(α a), F(α b))` "with multiplicity," and otherwise
`α(a·b) = c · lcm(α a, α b)` for an integer `c > 1` divisible only by primes
dividing `a·b`.
**Test**: Tabulate `α(a·b) / lcm(α a, α b)` for all `a, b ≤ 50` (it is always a
positive integer by `fibEntryPt_lcm_dvd`) and fit the multiplier `c` to the shared
prime structure; then prove the characterization.
**Why now**: `fibEntryPt_lcm_dvd` established that the quotient is always a genuine
positive integer, and `fibEntryPt_lcm_strict` exhibited the first `c = 2` case
(`a = b = 2`). The key insight is that the defect from the lcm law is *quantized*
by divisibility, never fractional, so the question is a clean multiplier-classification
rather than an inequality.
**If true**: completes the entry-point lattice homomorphism into an exact formula on
all pairs.
**If false**: reveals that the multiplier `c` depends on more than the shared prime
support — e.g. on apparition indices themselves — which reshapes Direction 1.

### Direction 5: Entry points for general strong divisibility sequences
**Hypothesis**: The entire toolkit (`α` well-defined, `s ∣ S(k) ↔ α(s) ∣ k`,
monotonicity, the coprime lcm law, and the fixed-point law `α(S n) = n`) transfers
verbatim to *any* strong divisibility sequence `S` with `gcd(S(m), S(n)) =
S(gcd(m,n))` and `S` eventually strictly increasing.
**Test**: Abstract the proofs over a hypothesis `hgcd : ∀ m n, gcd (S m) (S n) =
S (gcd m n)` (the only Fibonacci-specific fact used was `Nat.fib_gcd`), then
instantiate at Lucas sequences and at `S(n) = a^n - 1`. Falsified if any step
secretly used a Fibonacci identity beyond `fib_gcd` and monotonicity.
**Why now**: Every proof in this cycle used `Nat.fib` only through `Nat.fib_gcd`,
`Nat.fib_dvd`, and monotonicity, and the catalog's
`EntryPointMultiplicativity.lean` already studies apparition in strong divisibility
sequences. The key insight is that `Nat.fib_gcd` is the *sole* engine, so the theory
is really about strong divisibility sequences, not about Fibonacci.
**If true**: a single general file subsumes the Fibonacci, Lucas, and `a^n - 1`
apparition theories and connects directly to `EntryPointMultiplicativity.lean`.
**If false**: identifies the precise extra hypothesis (beyond strong divisibility)
that Fibonacci silently provides.
