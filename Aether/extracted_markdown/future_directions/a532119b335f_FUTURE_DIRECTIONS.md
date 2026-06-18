# Future Directions: Lattice structure of strong divisibility sequences

## Synthesis

This cycle attacked the dual/coprime side of the strong-divisibility-sequence theory that the
catalog had already developed on the meet (gcd) side. The catalog file
`Catalog/Applications/StrongDivisibilitySequences.lean` (namespace `StrongDivSeq`) established the
*meet law* `u (gcd m n) = gcd (u m) (u n)` and its divisor/apparition consequences, together with
the instances `fib_isStrongDivSeq` and `mersenne_isStrongDivSeq`. We added a new self-contained file
`Catalog/Algebra/StrongDivSeqLattice.lean` that asks what the meet law forces at *coprime indices*
and whether it *dualizes* to a join (lcm) law.

The central structural insight that emerged is that **the multiplicative defect of a strong
divisibility sequence is exactly its base value `u 1`.** Concretely: at coprime indices the gcd of
two values collapses to `u 1` (`gcd_coprime_eq_base`), and consequently the product of two values at
coprime indices divides `u (m*n)` up to a single factor of `u 1` (`mul_dvd_base_mul`). When the
sequence is normalized (`u 1 = 1`, as for Fibonacci and `aⁿ−1`) this becomes genuine multiplicative
divisibility `u m * u n ∣ u (m*n)`. The Critic's contribution was decisive: the obvious dual "join
law" `u (lcm m n) = lcm (u m) (u n)` is **false** (`lcm_join_law_fails`, Fibonacci at `m=2, n=3`:
`F₆ = 8 ≠ 2 = lcm(F₂, F₃)`). The failure analysis explains why only a defect-divisibility — and not
an equality — is available in §3: strong divisibility sequences are meet-homomorphisms but not
join-homomorphisms on the index lattice. The linear instances `id` and `n ↦ c·n` *do* satisfy the
join law, which is precisely why a nonlinear witness (Fibonacci) is needed to refute it.

What failed/limited the cycle: the catalog's `Applications` and `Novelty` folders are not registered
Lean libraries in the build, so cross-file `import` of `StrongDivSeq` was not available; we therefore
restated the one-line definition `IsStrongDivSeq` and built a parallel, self-contained development in
the registered `Algebra` library. Unifying these namespaces (or registering `Applications` as a lib)
is the obvious housekeeping target for the next cycle.

## Results Summary

- `dvd_of_dvd`: proved — divisibility law `m ∣ n → u m ∣ u n`, the engine behind all downstream facts.
- `base_dvd`: proved — the base value `u 1` divides every term (it is the bottom of the image lattice).
- `gcd_coprime_eq_base`: proved — at coprime indices the shared part collapses to `u 1`.
- `coprime_of_coprime_index`: proved — normalized sequences lift index-coprimality to value-coprimality.
- `mul_dvd_base_mul`: proved — weak multiplicativity `Coprime m n → u m * u n ∣ u 1 * u (m*n)` for *any* strong divisibility sequence.
- `mul_dvd_of_coprime_index`: proved — its `u 1 = 1` specialization `u m * u n ∣ u (m*n)`.
- `fib_isStrongDivSeq`, `linear_isStrongDivSeq`, `id_isStrongDivSeq`: proved — concrete instances spanning number-theoretic and linear families.
- `lcm_join_law_fails`: disproved (counterexample) — the dual join law is false; Fibonacci `m=2, n=3` witnesses `F₆ = 8 ≠ 2 = lcm(F₂, F₃)`.

## Research Directions

### Direction 1: Sharpness of the base-value defect
**Hypothesis**: The factor `u 1` in `mul_dvd_base_mul` is sharp: there is a strong divisibility
sequence `u` and coprime `m, n` with `u m * u n = u 1 * u (m*n)` (the divisibility is an equality),
and also one where the quotient `u 1 * u (m*n) / (u m * u n)` is arbitrarily large.
**Test**: Exhibit `u = id` (gives equality, since `lcm(m,n) = m*n` for coprime `m,n` and `u 1 = 1`)
and compute the Fibonacci quotient `F₁ · F_{mn} / (F_m F_n)` for several coprime pairs to show it is
unbounded; formalize one equality witness and one strict-inequality witness.
**Why now**: `mul_dvd_base_mul` isolates `u 1` as the exact defect, so sharpness is a finite
computation plus the already-proven `id` and `fib` instances.
**If true**: confirms `u 1` is the canonical "multiplicativity obstruction" and motivates a defect
invariant `δ(u,m,n) = u 1 * u(mn) / (u m u n)`.
**If false**: there is a hidden universal cancellation, suggesting a stronger multiplicative law.

### Direction 2: A Möbius/inclusion–exclusion product formula
**Hypothesis**: For a normalized strong divisibility sequence and squarefree `N = p₁⋯p_k` with
distinct primes, `∏_{i} u(p_i)` divides `u(N)`, and more generally the values `u(d)` for `d ∣ N`
satisfy a clean inclusion–exclusion identity in the divisibility lattice of `N`.
**Test**: Iterate `mul_dvd_of_coprime_index` over the prime factors of a squarefree `N` (induction on
the factorization) to prove the product-divides statement; then probe the exact gcd/lcm lattice of
`{u(d) : d ∣ N}` computationally on Fibonacci.
**Why now**: `mul_dvd_of_coprime_index` is exactly the two-prime base case; the meet law from the
catalog supplies the gcd relations needed for the lattice identity.
**If true**: yields a structure theorem expressing `u(N)` through its "primitive" parts, connecting to
the catalog's apparition/primitive-divisor theory.
**If false**: pinpoints where pairwise coprimality fails to globalize, a genuine obstruction to
multiplicativity.

### Direction 3: Characterizing the join-law sequences
**Hypothesis**: A strong divisibility sequence `u` satisfies the join law `u(lcm m n) = lcm(u m)(u n)`
for all `m, n` **iff** `u` is (essentially) linear, i.e. `u n = c · n` for some constant `c = u 1`.
**Test**: Prove the easy direction (linear ⇒ join law) — already implicit from
`linear_isStrongDivSeq` — and attempt the converse; refute or confirm by testing candidate nonlinear
join-law sequences. The key insight is that join-law sequences are simultaneously meet- and
join-homomorphisms of the divisibility lattice, hence lattice homomorphisms, which should be rigid.
**Why now**: `lcm_join_law_fails` already separates Fibonacci from `id`; the remaining question is the
exact frontier between the two behaviours.
**If true**: gives a complete classification of "doubly multiplicative" divisibility sequences.
**If false**: produces an exotic nonlinear join-preserving sequence — itself a notable object.

### Direction 4: Integer/group-valued strong divisibility sequences
**Hypothesis**: The base-value defect law `u m * u n ∣ u 1 * u(mn)` for coprime `m, n` holds verbatim
when `u` takes values in any GCD monoid (e.g. `ℤ`, `k[x]`, or a Dedekind domain's ideals), with `gcd`
and `lcm` interpreted in that monoid.
**Test**: Re-prove `gcd_coprime_eq_base` and `mul_dvd_base_mul` with `ℕ` replaced by a
`GCDMonoid`, using `gcd_mul_lcm` and `lcm_dvd` from Mathlib's order-theoretic API. The key insight is
that every step used only the lattice identities `gcd a b * lcm a b = a b` and `lcm a b ∣ k`, which
are available in any GCD monoid.
**Why now**: the `ℕ` proofs are short and use exactly the GCD-monoid-portable lemmas, so the
generalization is mostly a typeclass rewrite.
**If true**: a single abstract theorem subsumes Fibonacci, Mersenne, cyclotomic, and
elliptic-divisibility-sequence cases at once.
**If false**: identifies a `ℕ`-specific cancellation (e.g. reliance on positivity) worth isolating.

### Direction 5: Density of joint apparition via the defect law
**Hypothesis**: Combining `mul_dvd_of_coprime_index` with the catalog's `apparition_count`, the set of
indices `k ≤ N` at which `u(k)` is divisible by a *product* `u(a)·u(b)` of values at coprime indices
`a, b` has natural density `1 / lcm(a,b) = 1/(ab)`, matching the prediction of independence.
**Test**: Show the predicate "`u a · u b ∣ u k`" is equivalent (for primitive divisors) to
`lcm(a,b) ∣ k`, then reuse `Nat.card_multiples` exactly as in the catalog's
`simultaneous_apparition_count`. The key insight is that coprime indices make the two apparition
events behave as independent congruence conditions.
**Why now**: the catalog already proved `simultaneous_apparition_count`; the new
`mul_dvd_of_coprime_index` upgrades it from "both divide" to "the product divides", closing the loop
between the multiplicative and the counting pictures.
**If true**: a clean density statement linking algebra (multiplicativity) to analysis (equidistribution).
**If false**: reveals correlation between apparition events, contradicting naive independence.
