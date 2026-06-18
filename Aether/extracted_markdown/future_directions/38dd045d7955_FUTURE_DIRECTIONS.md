# Future Directions — Fibonacci Entry-Point Theory

## Synthesis

This cycle closed the one open `sorry` left by the entry-point characterization
work and turned the resulting machinery into a genuine cross-domain bridge. The
deferred research target `fibEntryPt_mul_coprime` — the **lcm law** `α(a·b) =
lcm(α a, α b)` for coprime moduli — is now fully proved. The proof is structurally
clean: coprimality collapses `a·b ∣ F(k)` into `a ∣ F(k) ∧ b ∣ F(k)`, the
characterization theorem `fib_dvd_iff_entryPt_dvd` (which never used primality)
turns each conjunct into an entry-point divisibility, and `α a ∣ k ∧ α b ∣ k ↔
lcm(α a, α b) ∣ k` finishes it; two naturals with identical multiple-sets are
equal by `Nat.dvd_antisymm`. The only subtlety was manufacturing the existence
witness for `a·b`, supplied by the lcm index itself.

The structural insight that emerged is that **the entry point `α` is computable
from the prime-power factorization**: it is multiplicative-to-lcm on coprime
parts. This makes the primitivity of *composite* moduli decidable from prime data.
We exploited this immediately. The characterization file had proved
`fib_twelve_no_primitive` (`F(12) = 144` has no primitive *prime* divisor — the
boundary Carmichael's theorem must exclude). Using the lcm law we computed
`α(6) = lcm(α 2, α 3) = lcm 3 4 = 12`, which by `entryPt_eq_iff_primitive` means
**`6` is a primitive divisor of `F(12)`**. So the `n = 12` obstruction is *exactly*
a statement about primes: `F(12)` has a primitive composite divisor even though it
has no primitive prime one. Nothing failed outright this cycle; the main friction
was that `α` is noncomputable (`Nat.find` on an unbounded predicate), so concrete
values like `α 2 = 3` must be proved via the minimality half of
`entryPt_eq_iff_primitive` rather than by `decide`.

These results tie together: the multiplicative theory of entry points
(`fibEntryPt_mul_coprime`, `fibEntryPt_dvd_index`) feeds back into the additive
question of which `F(n)` admit primitive divisors, suggesting the next cycle should
attack the *existence* of primitive composite divisors in the regime where
primitive prime divisors provably fail.

## Results Summary

- `fibEntryPt_mul_coprime`: proved — the lcm law `α(a·b) = lcm(α a, α b)` for coprime `a,b`; makes `α` reconstructible from the factorization (closes the former `sorry`).
- `fibEntryPt_dvd_index`: proved — `m ∣ F(n)` with `n > 0` forces `α m ∣ n` ("rank divides the index"), the backbone of bridge arguments.
- `fibEntryPt_two`: proved — `α 2 = 3`, base datum.
- `fibEntryPt_three`: proved — `α 3 = 4`, base datum.
- `fibEntryPt_six`: proved — `α 6 = 12`, the lcm law `lcm 3 4 = 12` in action.
- `six_primitive_at_twelve`: proved — `6` is a primitive divisor of `F(12)`, contrasting `fib_twelve_no_primitive`; the prime-only obstruction is genuinely prime-only.

## Research Directions

### Direction 1: General formula for `α` from the factorization
**Hypothesis**: For every `m ≥ 1` admitting an entry point, `α(m) = lcm over
prime powers p^e ∥ m of α(p^e)`, i.e. the lcm law extends from two coprime factors
to the full coprime factorization.
**Test**: Prove `fibEntryPt_prod_coprime` for a finite list/`Finset` of pairwise
coprime moduli by induction (each step is `fibEntryPt_mul_coprime`), then
specialize to `m.factorization`. Disproof would require a composite `m` whose
entry point is strictly below the lcm of its prime-power entry points.
**Why now**: `fibEntryPt_mul_coprime` is the exact two-factor base case, and
`fibEntryPt_dvd_index` gives the divisibility bound needed for the induction's
antisymmetry step.
**If true**: `α` becomes a fully explicit arithmetic function, reducing all
Fibonacci divisibility questions to prime-power entry points.
**If false**: it would expose a "carry" interaction between prime powers,
analogous to Wall–Sun–Sun phenomena.

### Direction 2: Entry point of prime powers (the `α(p^e)` law)
**Hypothesis**: For a prime `p` with `p ∤ F(α p)·something`, `α(p^e) = p^{e-1}·α(p)`
for `e` up to the Wall–Sun–Sun threshold (and equal to `α(p)` below it).
**Test**: Formalize the lifting-the-exponent statement `v_p(F(α(p)·m)) = v_p(F(α p))
+ v_p(m)` for the Fibonacci sequence and read off `α(p^e)`. Computationally screen
small primes for the boundary where the formula changes.
**Why now**: Direction 1 reduces everything to prime powers, so this is the only
missing input to a complete formula for `α`.
**If true**: Combined with Direction 1 it yields a closed form for `α(m)`.
**If false**: a counterexample is a Wall–Sun–Sun prime — a famous open search; even
a near-miss is informative.

### Direction 3: Existence of primitive composite divisors at the prime-exceptional indices
**Hypothesis**: Every index `n` in Carmichael's exceptional set `{1, 2, 6, 12}` for
*primes* nonetheless admits a primitive *composite* divisor `d` with `α(d) = n`.
**Test**: We proved this for `n = 12` (`six_primitive_at_twelve`). Prove it for
`n = 6` (candidate `d = 4`, since `α 4 = 6`) and analyze `n = 1, 2`. Disproof: find
an exceptional index with no `d` whose entry point equals it.
**Why now**: `fibEntryPt_six` and the lcm/`entryPt_eq_iff_primitive` toolkit make
`α(d) = n` checks routine.
**If true**: a clean "primitive divisors always exist if composites are allowed"
theorem, sharpening Carmichael's by isolating exactly what fails (only primality).
**If false**: identifies a truly divisor-free `F(n)`, a stronger obstruction.

### Direction 4: The non-coprime collapse — quantifying the lcm defect
**Hypothesis**: For arbitrary `a, b` (not coprime), `α(a·b) ∣ lcm(α a, α b)` always,
and the defect `lcm(α a, α b) / α(a·b)` is governed by `gcd(a,b)`.
**Test**: Prove the divisibility direction (it follows from `fibEntryPt_dvd_index`
applied to `a·b ∣ F(lcm)`), then search computationally for the defect's
dependence on `gcd(a,b)`. The coprime case (`fibEntryPt_mul_coprime`) is defect 1.
**Why now**: the proof of `fibEntryPt_mul_coprime` shows precisely where
coprimality was used (the `mul_dvd_of_dvd_of_dvd` step), pinpointing where the
equality degrades to a divisibility.
**If true**: extends the lcm law to a clean inequality valid for all moduli.
**If false**: reveals that `α` is not even sub-multiplicative-to-lcm, a surprise.

### Direction 5: Transport the entry-point machinery to general Lucas sequences
**Hypothesis**: For any nondegenerate Lucas sequence `U_n(P,Q)` with `gcd`-
compatibility (`gcd(U_m, U_n) = U_{gcd(m,n)}` up to units), the entry point obeys
the same characterization `p ∣ U_k ↔ α(p) ∣ k` and the same coprime lcm law.
**Test**: Abstract `fib_dvd_iff_entryPt_dvd` and `fibEntryPt_mul_coprime` over a
typeclass capturing "strong divisibility sequence" (`gcd(U_m,U_n) = U_{gcd m n}`),
then instantiate at Fibonacci and at Mersenne-type sequences.
**Why now**: the current proofs depend on the sequence only through `Nat.fib_gcd`
and `Nat.fib_dvd`; isolating those two facts is a mechanical refactor.
**If true**: one proof covers Fibonacci, Pell, and Mersenne entry points at once.
**If false**: the failure pinpoints which sequences lack the strong-divisibility
property, a sharp structural classification.
