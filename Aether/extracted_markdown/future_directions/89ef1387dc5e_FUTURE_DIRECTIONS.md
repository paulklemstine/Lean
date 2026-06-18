# Future Directions — Multiplicativity of the Fibonacci Rank of Apparition

## Synthesis

This cycle attacked the "Close Proofs" target around the Carmichael primitive-divisor
ecosystem (`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Applications/FibonacciEntryPoints.lean`).
The remaining `sorry` in `fib_carmichael_composite` is the **infinite composite tail**
of Carmichael's primitive-divisor theorem (every composite `n > 10000` makes `F_n`
acquire a brand-new prime). That tail is not a one-cycle lemma — it is the genuine
content of Carmichael's 1913 theorem and needs cyclotomic / lifting-the-exponent
machinery far beyond a `native_decide` window. Rather than fake it, we isolated the
*structural backbone* that such a proof must use and pushed it forward.

The catalog already proved the **additive** law of the rank of apparition
`entryPoint`: `p ∣ F_n ↔ entryPoint p ∣ n` (`dvd_fib_iff_entry_dvd`) and the
primitive-divisor characterization `IsPrimitive p n ↔ entryPoint p = n`. What was
missing — and what we supplied, fully `sorry`-free — is the **multiplicative**
theory: how `entryPoint` behaves on products of moduli. The headline result
`entryPoint_mul_coprime` shows the rank of apparition is *lcm-multiplicative on
coprime moduli*: `entryPoint (p*q) = lcm (entryPoint p) (entryPoint q)`. The Critic
then showed this is **sharp**: `entryPoint_mul_not_lcm_noncoprime` exhibits
`entryPoint 4 = 6 ≠ 3 = lcm(entryPoint 2, entryPoint 2)`, so coprimality cannot be
dropped — the failure is precisely a 2-adic "rank jump."

The structural insight that emerged is a clean separation of concerns: the
divisibility footprint of a modulus in the Fibonacci sequence is *exactly a set of
multiples of one number* (its entry point), so all multiplicative questions reduce
to lattice operations (gcd/lcm) on those numbers. This reframes the residual
Carmichael tail as a question about when that single number `entryPoint p` introduces
a *new* prime — i.e. about the prime-power refinement of entry points, which the
counterexample tells us is exactly where the interesting arithmetic lives.

## Results Summary

- `entryPoint_eq_of_iff`: proved — uniqueness of the entry point from its full divisibility footprint (the lemma that converts "for all `m`, `p ∣ F_m ↔ d ∣ m`" into `entryPoint p = d`); the workhorse for all multiplicative computations.
- `entryPoint_eq`: proved — explicit entry point from a primitive index (`p ∣ F_n`, nothing earlier ⇒ `entryPoint p = n`).
- `entryPoint_dvd_of_dvd`: proved — monotonicity: `p ∣ q ⇒ entryPoint p ∣ entryPoint q`; divisibility of moduli becomes divisibility of indices.
- `entryPoint_mul_coprime`: proved — **main result**: `entryPoint (p*q) = lcm (entryPoint p) (entryPoint q)` for coprime `p, q`; the multiplicative law of the rank of apparition.
- `entryPoint_two`, `entryPoint_four`: proved — `entryPoint 2 = 3`, `entryPoint 4 = 6` (concrete witnesses).
- `entryPoint_mul_not_lcm_noncoprime`: proved (disproof of the naive generalization) — coprimality is necessary; `entryPoint 4 = 6 ≠ 3 = lcm(entryPoint 2, entryPoint 2)`.
- `fib_carmichael_composite` (pre-existing, `Catalog/Shared/CarmichaelProof.lean`): conjecture/open — the infinite composite tail `n > 10000` remains a `sorry`; it is Carmichael's full primitive-divisor theorem and is the subject of Direction 3 below.

## Research Directions

### Direction 1: The prime-power rank jump (2-adic / LTE wall)
**Hypothesis**: For a prime `p` and exponent `a` above a threshold `w(p)` (the
`p`-adic "wall"), `entryPoint (p^(a+1)) = p · entryPoint (p^a)`. Concretely for `p = 2`:
`entryPoint 2 = 3`, `entryPoint 4 = 6`, `entryPoint 8 = 6`, `entryPoint 16 = 12`, …,
governed by `v_2(F_{entryPoint})`.
**Test**: Compute `entryPoint (2^a)` for `a ≤ 8` via `entryPoint_eq` + `decide`, fit
the jump pattern, then prove the step using lifting-the-exponent
(`Catalog/Algebra/...LiftingTheExponent...Fibonacci...` already in the catalog).
**Why now**: `entryPoint_mul_not_lcm_noncoprime` shows the lcm law *fails by exactly one
prime factor `p`* in the non-coprime case — that gap is the rank jump, isolated and
ready to be quantified. The key insight is that the only obstruction to full
multiplicativity is the `p`-adic valuation of `F_{entryPoint p}`.
**If true**: combined with `entryPoint_mul_coprime` it yields a *closed formula* for
`entryPoint n` for every `n` (Direction 2). **If false**: there is a deeper, non-LTE
mechanism in Fibonacci valuations worth hunting.

### Direction 2: A closed formula `entryPoint n = lcm over prime powers`
**Hypothesis**: For every `n ≥ 1`, `entryPoint n = lcm_{p^a ∥ n} entryPoint (p^a)`,
the lcm over the exact prime-power factors of `n`.
**Test**: Iterate `entryPoint_mul_coprime` along the coprime factorization
`n = ∏ p^a` (Mathlib `Nat.factorization` / `Nat.Coprime` of prime-power blocks);
the only remaining inputs are the prime-power values from Direction 1.
**Why now**: `entryPoint_mul_coprime` *is* the inductive step; the recursion is already
proved. The key insight is that multiplicativity on coprime blocks reduces the global
entry point to a finite lcm of local (prime-power) entry points.
**If true**: a fully computable, `sorry`-free `entryPoint` for all `n`, and a decision
procedure for `n ∣ F_m`. **If false**: coprime factorization interacts with the rank
jump in an unexpected way, pinpointing a subtle valuation phenomenon.

### Direction 3: Closing the Carmichael composite tail
**Hypothesis**: Every composite `n > 10000` has a primitive prime divisor of `F_n`
(the `sorry` in `fib_carmichael_composite`).
**Test**: Replace the brute-force `native_decide` window with a structural proof:
show `Φ_n(φ, ψ)` (the `n`-th Fibonacci cyclotomic factor) exceeds its "intrinsic"
bound for `n > 10000`, so some prime divisor is not absorbed by any `F_d`, `d ∣ n`,
`d < n`. The entry-point machinery (`dvd_fib_iff_entry_dvd`, `entryPoint_dvd_of_dvd`)
reduces "primitive divisor of `F_n`" to "a prime with `entryPoint p = n`."
**Why now**: this cycle reframed primitivity entirely in terms of `entryPoint p = n`
and gave the monotonicity `entryPoint p ∣ entryPoint q`. The key insight is that a
primitive divisor is exactly a prime whose rank of apparition *equals* `n`, turning a
counting problem into a statement about the fibers of `entryPoint`.
**If true**: removes the last `sorry` from the Carmichael file and yields Carmichael's
theorem in Lean. **If false** (it is a theorem, so failure would be a formalization
gap): the obstruction localizes to the cyclotomic lower bound, telling us which
analytic estimate Mathlib still lacks.

### Direction 4: Fibers of `entryPoint` and a Zsygmondy-style classification
**Hypothesis**: For each `n ∉ {1, 2, 6, 12}` the fiber `{p prime : entryPoint p = n}`
is nonempty (existence of a primitive divisor), and `entryPoint` is "almost surjective"
onto `ℕ`.
**Test**: For small `n`, enumerate primitive prime divisors via `entryPoint_eq`; for the
exceptions reuse `fib_twelve_no_primitive` (catalog) and prove the `n ∈ {1,2,6}` cases
analogously; then connect to Direction 3 for the general statement.
**Why now**: `primitive_iff_entry_eq` (catalog) + our `entryPoint_eq` make membership in
a fiber a `decide`-able predicate for fixed `n`. The key insight is that the entire
exceptional set of Carmichael's theorem is exactly the set of empty `entryPoint` fibers.
**If true**: a clean Lean statement of Carmichael/Zsygmondy as surjectivity-up-to-
exceptions. **If false**: a new Fibonacci index with no primitive divisor — which
would contradict Carmichael, so failure would be a proof bug to hunt.

### Direction 5: Transplanting the rank of apparition to Lucas sequences
**Hypothesis**: The lcm-multiplicativity `entryPoint_mul_coprime` holds verbatim for any
nondegenerate Lucas sequence `U_n(P,Q)` with the strong divisibility property
`gcd(U_m, U_n) = U_{gcd(m,n)}`.
**Test**: Abstract our proofs over a hypothesis `H_gcd : U (gcd m n) = gcd (U m) (U n)`
and `U_dvd : m ∣ n → U m ∣ U n`; re-run the §1–§3 proofs unchanged; instantiate at
`U = fib` to recover this file.
**Why now**: every lemma here uses *only* `Nat.fib_gcd` and `Nat.fib_dvd`; nothing is
Fibonacci-specific. The key insight is that the rank-of-apparition theory is a theorem
about *strong divisibility sequences*, not about Fibonacci numbers per se.
**If true**: a reusable Mathlib-ready module covering Mersenne-type and general Lucas
sequences in one stroke. **If false**: identifies the precise extra hypothesis (e.g.
nondegeneracy) that Fibonacci silently supplies.
