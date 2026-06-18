# Future Directions — Fibonacci Entry-Point Closure

## Synthesis

This cycle isolated the *purely algebraic* core that underlies the catalog's
Fibonacci primitive-divisor program (`Speculative.AutoResearch.CarmichaelComposite`,
`Shared.CarmichaelProof`).  The new file `Catalog/Novelty/FibonacciEntryPointClosure.lean`
proves, with **zero `sorry`**, the complete theory of the *rank of apparition*
(Fibonacci entry point) `α(m) = min { k > 0 : m ∣ F(k) }`:

* the reoriented gcd identity `gcd(F m, F n) = F(gcd m n)` and the corollary that
  coprime indices give coprime Fibonacci values;
* the three structural facts about `α` (positivity, it is itself an apparition,
  minimality);
* the **apparition law** `m ∣ F(n) ↔ α(m) ∣ n`;
* the **main equivalence** `IsPrimitiveDivisor m n ↔ α(m) = n`.

Crucially, all of this is proved for an *arbitrary modulus* `m`, strictly
generalizing the "prime `p`" statements the catalog uses.  This cleanly separates
the two halves of Carmichael's theorem: the *characterization* of primitivity
(algebraic, done here, reusable) versus the *existence* of primitive divisors
(analytic, the genuinely hard tail still open in the catalog).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_gcd_identity` | `gcd(F m, F n) = F(gcd m n)` | proved |
| `coprime_fib_of_coprime_index` | `Coprime m n → Coprime (F m) (F n)` | proved |
| `fibEntry_pos / dvd_fib_fibEntry / fibEntry_min` | structure of `α` | proved |
| `fibEntry_dvd_index` | `m ∣ F n → α(m) ∣ n` | proved |
| `fib_dvd_iff_fibEntry_dvd` | apparition law (both directions) | proved |
| `primitive_divisor_iff_fibEntry_eq` | primitivity ⇔ `α(m) = n` | proved |

The two analytic catalog sorries (`fib_carmichael_composite` for `n > 10000`, and
the Miller–Rabin `1/4` liar bound) remain open; this cycle also repaired the
project's build (`srcDir`, two broken `import` lines, a missing-file import, and a
missing `Novelty` library entry) so those modules now elaborate.

## Research Directions

### 1. Close the Carmichael tail via an effective primitive-part lower bound
The remaining `fib_carmichael_composite` sorry needs only `1 < primPart n` for
composite `n > 10000`, which `primitive_divisor_iff_fibEntry_eq` then converts to
an entry-point statement.  **The key insight is** that the primitive part of
`F(n)` equals, up to a single "intrinsic" prime factor of size `≤ n`, the
homogenized cyclotomic value `Φ_n(φ, ψ)` whose modulus is `φ^{deg Φ_n}`; once
`φ^{deg Φ_n} > n` the primitive part must exceed `1`.  Falsifiable: exhibit a
composite `n > 10000` with `primPart n = 1`, or prove the displayed inequality
`φ^{Nat.totient n} > n` for all such `n` (it fails only for finitely many small
`n`, all `≤ 10000`, already covered by `native_decide`).  **Why now?** The
algebraic reduction `primitive ⇔ α = n` is now formal, so the only missing
ingredient is the one-line growth bound — a self-contained real-analysis lemma.

### 2. A Monier–Rabin subgroup bound for Miller–Rabin witnesses
`exists_miller_rabin_witness` does **not** follow from `|liars| ≤ (n-1)/4` plus
`φ(n) > (n-1)/4`: the latter is *false* for primorial `n = 3·5·7·⋯` where
`∏(1-1/p) < 1/4`.  **The key insight is** that the strong-liar set is contained in
a *proper subgroup* of `(ℤ/nℤ)ˣ`, so `|liars| ≤ φ(n)/2 < φ(n)`, which already
yields a witness without any density estimate.  Falsifiable: find an odd composite
`n` for which every unit is a strong liar (an "absolute strong pseudoprime") — none
exists, and a Lean proof of the proper-subgroup containment would settle it.
**Why now?** This decouples witness *existence* (subgroup) from the much harder
`1/4` *density* bound, giving a provable intermediate milestone.

### 3. Entry points as a multiplicative-order analogue
`fibEntry m` behaves like a multiplicative order: `α(p)` divides `p - (5|p)` for
primes `p` (the Fibonacci analogue of Fermat's little theorem).  **The key insight
is** that `α(p)` is exactly the order of the golden ratio in `(ℤ/pℤ[√5])ˣ /` its
norm-1 subgroup, so the apparition law proved here is literally a statement about
cyclic-group orders.  Falsifiable: test `α(p) ∣ p - (5|p)` over primes and prove it
from the order interpretation; a counterexample would refute the embedding.
**Why now?** With the apparition law `m ∣ F n ↔ α(m) ∣ n` formal, transporting it
across the `ℤ[√5]` embedding is a direct next step.

### 4. Lifting the closure to Lucas sequences `U_n(P,Q)`
Fibonacci is the case `P=1, Q=-1` of the Lucas sequence `U_n(P,Q)`.  **The key
insight is** that the gcd identity `gcd(U_m, U_n) = U_{gcd m n}` holds whenever
`gcd(P,Q)=1`, so every theorem in `FibonacciEntryPointClosure` generalizes
verbatim with `Nat.fib` replaced by `U`.  Falsifiable: the generalization breaks
exactly when `gcd(P,Q) > 1`; exhibit such `P,Q` where the gcd identity fails.
**Why now?** The current proofs use only the gcd identity and `U_m ∣ U_n` for
`m ∣ n`, both of which have Lucas-sequence analogues — a near-mechanical port.

### 5. Bridge to Miller–Rabin via "rank of apparition" of bases
Both the Fibonacci entry point and the Miller–Rabin liar analysis are about the
order of an element in `(ℤ/nℤ)ˣ` (resp. in the companion-matrix group of `x²-x-1`).
**The key insight is** that a single `OrderInUnits` abstraction would let the
apparition law and the Monier–Rabin subgroup bound be instances of one lemma about
orders in finite abelian groups.  Falsifiable: if no common generalization exists,
the two order notions disagree on a small modulus — checkable by enumeration.
**Why now?** This cycle made the Fibonacci side fully formal; unifying it with the
primality-testing side is the natural cross-domain synthesis the catalog is missing.
