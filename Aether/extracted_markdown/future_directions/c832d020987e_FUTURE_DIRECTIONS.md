# FUTURE_DIRECTIONS — Strong Divisibility Index Reconstruction (Novelty cycle)

## Synthesis

This cycle deepened the catalog's Fibonacci entry-point / strong-divisibility theory.
The catalog already proved the *primitivity* half of the entry-point story
(`StrongDivSeq.primitive_divisor_inj`, `fib_primitive_divisor_inj`,
`mersenne_primitive_divisor_inj`): a fixed modulus is a primitive divisor of at most one
term. We asked the sharper question: how much of the index structure is recoverable from
the terms? The answer is *all of it*. For a strong divisibility sequence
(`gcd (u m) (u n) = u (gcd m n)`) that is monotone and strictly increasing on `[2,∞)`,
divisibility of terms is **equivalent** to divisibility of indices once `m ≥ 3`
(`strongDiv_dvd_iff_index`). Both directions collapse onto the single gcd law: `u m ∣ u n`
iff `gcd(u m)(u n) = u m` iff `u(gcd m n) = u m`, and the order hypotheses invert `u` to
force `gcd m n = m`. From this we extracted a clean "self-apparition" statement
(`isLeast_index_self`): every term `u m` first divides a positive-index term exactly at its
own index, i.e. the rank of apparition of the *number* `u m` is its index `m`.

The most instructive failure was the temptation to assume `StrictMono u` globally. That is
false for Fibonacci, where `fib 1 = fib 2 = 1`. The correct hypothesis pair —
`Monotone u` plus `StrictMonoOn u (Set.Ici 2)` — is exactly what both Fibonacci and the
base-`a` Mersenne/repunit sequences satisfy, and it exposed the sharp threshold `m ≥ 3`:
the equivalence genuinely breaks at `m = 2` (`fib_index_boundary`), since `fib 2 = 1`
divides everything. The structural insight is that strong divisibility sequences are
"divisibility order-embeddings of `(ℕ, ∣)` above a short degenerate prefix", and that the
entire apparition theory is a corollary of one gcd identity plus a monotonicity envelope.

The same abstract theorem instantiates verbatim to Fibonacci (`fib_dvd_iff_index`, whose
forward direction is *not* in Mathlib — Mathlib supplies only the converse `Nat.fib_dvd`)
and to every base-`a` Mersenne sequence `a^n - 1` (`mersenne_dvd_iff_index`). This
cross-domain transfer is the main lever for the directions below.

## Results Summary

- `StrongDivIndex.lt_of_lt_index`: proved — monotone + eventually-strict sequences separate `u m` from all earlier terms for `m ≥ 3`; the order envelope that powers everything else.
- `StrongDivIndex.strongDiv_dvd_iff_index`: proved — **main theorem**: `u m ∣ u n ↔ m ∣ n` for `m ≥ 3` in any monotone strong divisibility sequence strictly increasing on `[2,∞)`.
- `StrongDivIndex.isLeast_index_self`: proved — self-apparition: `m` is the least positive `k` with `u m ∣ u k`; the rank of apparition of the term equals its index.
- `fib_dvd_iff_index`: proved — Fibonacci instance; forward direction is new relative to Mathlib's `Nat.fib_dvd`.
- `fib_index_boundary`: proved (disproof of the boundary) — the `m ≥ 3` threshold is sharp; the equivalence fails at `m = 2` because `fib 2 = 1`.
- `mersenne_dvd_iff_index`: proved — base-`a` Mersenne/repunit instance `a^m - 1 ∣ a^n - 1 ↔ m ∣ n`, same theorem, different domain.

## Research Directions

### Direction 1: Carmichael's primitive-divisor theorem, the infinite composite tail
**Hypothesis**: For every composite `n > 10000`, `Nat.fib n` has a primitive prime divisor
(closing the lone `sorry` at `Catalog/Shared/CarmichaelProof.lean:129`, the only open hole
in the Fibonacci Carmichael development).
**Test**: Replace the computational `native_decide` range by an analytic argument: bound the
homogeneous "cyclotomic" factor `Φ_n(φ, ψ)` of `F n` from below by `n + 1` for large `n`,
and show any non-primitive prime factor must equal the largest prime factor of `n` and
occur to first power only (the Carmichael/Zsygmondy estimate).
**Why now**: `strongDiv_dvd_iff_index` and `isLeast_index_self` give the exact index
bookkeeping (a prime is primitive for `F n` iff its rank of apparition equals `n`) that the
tail argument needs; the index side is now fully formal, so only the size estimate remains.
**If true**: Completes Carmichael's theorem for Fibonacci in Lean with `sorry = 0`.
**If false**: A counterexample would contradict a century-old theorem, so failure most
likely localizes the missing analytic lemma rather than refuting the statement.

### Direction 2: Index reconstruction for general Lucas sequences
**Hypothesis**: For a nondegenerate Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1` and `P,Q`
chosen so that `|U_n|` is monotone and strictly increasing on `[2,∞)`, the same equivalence
`U_m ∣ U_n ↔ m ∣ n` holds for `m ≥ 3`.
**Test**: Instantiate `strongDiv_dvd_iff_index` with `u = fun n => (U_n).natAbs`, supplying
the strong divisibility law for Lucas sequences and the monotonicity envelope; identify the
exact `(P,Q)` region where strictness on `[2,∞)` holds.
**Why now**: The abstract theorem is already parametric in `u`; Fibonacci `(1,-1)` and
Mersenne-like `(a+1, a)` are two points of a continuum, so generalization is a matter of
verifying two hypotheses, not re-proving the core.
**If true**: One Lean theorem subsumes Fibonacci, Pell, and Mersenne index reconstruction.
**If false**: The failing `(P,Q)` pinpoints where strong divisibility or monotonicity breaks
(e.g. sign oscillation), refining the hypothesis envelope.

### Direction 3: The law of repetition for ranks of apparition
**Hypothesis**: If `p^e ∥ u(α)` where `α` is the rank of apparition of prime `p`, then the
rank of apparition of `p^{e+j}` is exactly `p^j · α` (for monotone strong divisibility
sequences, away from finitely many "Wall–Sun–Sun" exceptional primes).
**Test**: Combine `isLeast_index_self` with a `p`-adic valuation lemma
`v_p(u(α·p^j)) = v_p(u(α)) + j`; the catalog's tropical/p-adic Fibonacci valuation file is a
candidate source for the valuation step.
**Why now**: `isLeast_index_self` formalizes "rank of apparition = least index" abstractly,
giving the base case `j = 0` for free; only the inductive valuation increment is missing.
**If true**: Reduces all entry-point computation to the prime case plus a valuation, the
classical "law of repetition".
**If false**: The first exceptional prime where it fails is a Wall–Sun–Sun-type anomaly — a
computationally searchable, high-value counterexample.

### Direction 4: Lattice morphism upgrade of the index map
**Hypothesis**: On indices `≥ 3`, the map `m ↦ u m` is a full lattice embedding of `(ℕ, ∣)`:
not only `m ∣ n ↔ u m ∣ u n`, but `gcd(u m)(u n) = u(gcd m n)` (given) **and**
`lcm(u m)(u n) = u(lcm m n)` whenever `m, n` are coprime, mirroring the catalog's
`fibEntry_mul_coprime`.
**Test**: Prove the coprime `lcm` identity from `strongDiv_dvd_iff_index` plus
`coprime_mul_dvd_iff` (already in the catalog), then characterize exactly when the
non-coprime `lcm` identity fails.
**Why now**: With `↔` for divisibility now in hand, the lattice statements become
divisibility-equivalence arguments (`Nat.eq_of_dvd_iff`), the technique already used for
`fibEntry_mul_coprime`.
**If true**: Establishes `u` restricted to `[3,∞)` as a genuine `(ℕ, ∣)`-lattice embedding,
unifying gcd and lcm sides of the entry-point theory.
**If false**: The minimal non-coprime pair where `lcm(u m)(u n) ≠ u(lcm m n)` quantifies the
obstruction and likely involves shared primitive divisors.

### Direction 5: Strict-threshold classification across sequences
**Hypothesis**: The sharp threshold for `u m ∣ u n ↔ m ∣ n` is `m ≥ m₀` where
`m₀ = 1 + (length of the maximal flat/degenerate prefix of u)`; for Fibonacci `m₀ = 3`, for
strictly increasing-from-1 sequences (e.g. `a^n - 1`, `a ≥ 3`) `m₀ = 2`.
**Test**: Generalize `lt_of_lt_index` to take the prefix length as a parameter, re-derive
the iff with threshold `m₀`, and confirm `fib_index_boundary` is the `m₀ = 3` witness while
`a^n - 1` with `a ≥ 3` admits `m = 2`.
**Why now**: This cycle isolated `Monotone u` + `StrictMonoOn u (Ici 2)` as the precise
hypotheses and proved the threshold sharp for Fibonacci; parameterizing the prefix is the
natural next abstraction.
**If true**: A single threshold formula governs index reconstruction for the whole family of
strong divisibility sequences.
**If false**: A sequence whose threshold exceeds `1 + prefix length` reveals a subtler
interaction between the gcd law and monotonicity than the prefix alone explains.
