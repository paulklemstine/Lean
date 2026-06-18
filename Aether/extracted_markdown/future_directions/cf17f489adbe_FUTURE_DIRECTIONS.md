# Future Directions — Strong divisibility sequences, primitive divisors, and apparition density

## Synthesis

This cycle executed **Direction 3** ("Abstract strong divisibility sequences") and
**Direction 5** ("Counting simultaneous apparitions / density") of the previous Fibonacci
cycle, and showed that the entire primitivity/apparition layer of Fibonacci divisibility
theory depends on *one* algebraic axiom, not on Fibonacci at all. We isolated the property
`IsStrongDivSeq u : u (gcd m n) = gcd (u m) (u n)` and re-derived, verbatim and for an
arbitrary `u : ℕ → ℕ`, the whole structural backbone of
`Catalog/Applications/FibonacciPrimitiveDivisors.lean`: the weak divisibility law
(`IsStrongDivSeq.dvd_of_dvd`, a *free corollary* of the strong law that recovers Mathlib's
`Nat.fib_dvd`), the sharp meet law (`IsStrongDivSeq.dvd_gcd_index_iff`), rigidity of
primitive divisors (`isPrimitive_unique`), the pinning law
(`dvd_iff_index_dvd_of_primitive`), and the join laws
(`simultaneous_apparition`, `simultaneous_apparition_finset`). The new file is
`Catalog/Applications/StrongDivisibilitySequences.lean`.

The structural insight is sharper than expected: the *only* place Fibonacci-specific input
ever enters is the two-line instance `fib_isStrongDivSeq` (from `Nat.fib_gcd`). Swapping it
for `mersenne_isStrongDivSeq` (from `Nat.pow_sub_one_gcd_pow_sub_one`) instantly transports
every theorem to the `aⁿ − 1` family — a genuine cross-domain consolidation that subsumes
Fibonacci and Mersenne apparition theory under a single signature. A subtle boundary
emerged at index `0`: `isPrimitive_zero_everything` now requires an explicit `u 0 = 0`
hypothesis, because the abstract setting cannot assume the Fibonacci coincidence `F₀ = 0`.
This pins down precisely the extra fact the original Fibonacci proofs silently used.

Beyond Direction 3 we also realized Direction 5 quantitatively: `apparition_count` proves
that exactly `N / n` of the first `N` positive indices are apparition indices of a primitive
divisor of index `n`, and `simultaneous_apparition_count` gives `N / lcm a b` for the joint
case — both by converting the divisibility predicate to a multiples-count via
`Nat.card_multiples`. This turns the qualitative iff `lcm a b ∣ n` into an exact lattice-point
count, the natural bridge from the apparition lattice to analytic density. What remains
untouched is still the deep analytic core: the *existence* of primitive divisors (the
Carmichael tail) is a size estimate, not a divisibility fact, and none of the abstract
machinery here produces it.

## Results Summary

- `IsStrongDivSeq` (def): proved/defined — the single axiom `u (gcd m n) = gcd (u m) (u n)` from which all results below flow.
- `IsStrongDivSeq.dvd_of_dvd`: proved — `m ∣ n → u m ∣ u n`; the weak divisibility law is a free corollary of the strong one.
- `IsStrongDivSeq.dvd_gcd_index_iff`: proved — the sharp meet law `d ∣ u (gcd m n) ↔ d ∣ u m ∧ d ∣ u n` for arbitrary divisor `d`.
- `isPrimitive_zero_everything`: proved — index-`0` boundary case, requiring exactly `u 0 = 0` and explaining why positivity is needed elsewhere.
- `isPrimitive_unique`: proved — a value is a primitive divisor of at most one positive index (needs no strong-divisibility hypothesis).
- `dvd_iff_index_dvd_of_primitive`: proved — a primitive divisor of index `n` divides `u m` exactly when `n ∣ m`.
- `simultaneous_apparition`: proved — the join law `(p ∣ u n ∧ q ∣ u n) ↔ lcm a b ∣ n`.
- `simultaneous_apparition_finset`: proved — finite-family generalization of the join law.
- `apparition_count`: proved — exactly `N / n` of the first `N` indices are apparition indices (density `1/n`).
- `simultaneous_apparition_count`: proved — exactly `N / lcm a b` joint apparition indices among the first `N`.
- `fib_isStrongDivSeq`: proved — `Nat.fib` is a strong divisibility sequence (recovers the whole Fibonacci file).
- `mersenne_isStrongDivSeq`: proved — `n ↦ aⁿ − 1` is a strong divisibility sequence (transports the theory to Mersenne numbers).

## Research Directions

### Direction 1: Existence of primitive divisors (the Carmichael tail)
**Hypothesis**: For every `n ≥ 13`, `Nat.fib n` has a primitive prime divisor (equivalently the
`sorry` for composite `n > 10000` in `Catalog/Shared/CarmichaelProof.lean` is true), and more
generally `aⁿ − 1` has a primitive prime divisor for all `n > 6` (Bang–Zsygmondy).
**Test**: Bound the primitive part `Φ_n` from below via the cyclotomic factorization
`uₙ = ∏_{d ∣ n} Φ_d`, showing intrinsic (non-primitive) prime factors are bounded so `Φ_n > 1`;
a disproof is a single `n` with `Φ_n = 1`.
**Why now**: `dvd_iff_index_dvd_of_primitive` and `isPrimitive_unique` already reduce "primitive
divisor of `uₙ`" to "prime with index exactly `n`", and `mersenne_isStrongDivSeq` means a single
existence proof would cover both Fibonacci and Mersenne at once — only the size estimate is missing.
**If true**: closes the headline open `sorry` in the catalog and yields Carmichael/Zsygmondy in full.
**If false**: would contradict known mathematics, so any "counterexample" instead pinpoints a
modelling error in the formal statement.

### Direction 2: Lucas sequences as strong divisibility sequences
**Hypothesis**: Every nondegenerate Lucas sequence of the first kind `Uₙ(P,Q)` with
`gcd(P,Q)=1` satisfies `IsStrongDivSeq`, hence inherits all theorems of
`StrongDivisibilitySequences` verbatim (Fibonacci is `U(1,−1)`, Mersenne-like `(aⁿ−1)/(a−1)` is `U(a+1,a)`).
**Test**: Define `U : ℕ → ℤ` by the recurrence and prove `gcd (U m) (U n) = U (gcd m n)` (up to
sign) from the addition formula `U_{m+n} = U_m U_{n+1} − Q U_{m−1} U_n`; instantiate `IsStrongDivSeq`
after transporting to ℕ via absolute value.
**Why now**: the abstract file already consumes a strong-divisibility hypothesis as its *only* input,
so this is a single new instance lemma — the downstream apparition theory is done.
**If true**: one reusable module governs Fibonacci, Mersenne, Pell, and general Lucas apparition.
**If false** (degenerate `P,Q`): identifies exactly the coprimality/nondegeneracy axiom the gcd law needs.

### Direction 3: From exact count to natural density
**Hypothesis**: For a primitive divisor `p` of `uₙ`, the natural density of apparition indices is
`1/n`: `(apparition_count … N : ℝ) / N → 1/n` as `N → ∞`, and for a finite family the density is
`1 / Finset.lcm`.
**Test**: Combine `apparition_count` (`card = N / n`) with `Nat.cast_div`-style bounds
`|N/n − N/n_real| ≤ 1` to sandwich the ratio, then `tendsto` to `1/n`; lift `simultaneous_apparition_count`
the same way.
**Why now**: this cycle proved the *exact* lattice-point count `N / n`; turning a floor-count into a
density limit is a packaging step with `Filter.Tendsto` and squeeze, with no new number theory.
**If true**: gives rigorous densities for (joint) Fibonacci/Mersenne divisibility, linking the
apparition lattice to analytic number theory.
**If false**: a discrepancy would expose an off-by-one in the `+1` index-shift convention.

### Direction 4: The apparition map is a lattice morphism on active moduli
**Hypothesis**: For a fixed strong divisibility sequence, the map sending a modulus `a` (that divides
some `u k`) to its rank of apparition is injective and a *join* homomorphism (`lcm`) but only a lax
*meet* morphism (`gcd`), with image exactly `{n : uₙ has a primitive divisor of that rank}`.
**Test**: Combine the catalog's `fibEntry_lcm` and `fibEntry_gcd_not_exact`
(`FibonacciApparitionLattice.lean`) with the new abstract `isPrimitive_unique` (injectivity) and
`simultaneous_apparition` (the join law); the boundary case `a=4, b=6` already witnesses meet-failure.
**Why now**: the join law and uniqueness are now available *abstractly*, so the lattice statement can
be phrased for any `IsStrongDivSeq`, not just Fibonacci, unifying the catalog's two apparition files.
**If true**: a clean categorical description of the rank of apparition as a lattice map for all SDSs.
**If false**: the failure locates a second exceptional index beyond Fibonacci's `12`.

### Direction 5: Index of a primitive divisor and the prime-index special case
**Hypothesis**: If `n` is prime and `p` is any prime divisor of `uₙ` not dividing `u₁`, then `p` is
primitive for `uₙ` (its index is forced to be exactly `n`); consequently for prime `n` the set of
non-primitive prime factors of `uₙ` is contained in the factors of `u₁`.
**Test**: From `p ∣ uₙ` and `dvd_iff_index_dvd_of_primitive` the index `e` of `p` divides `n`; primality
of `n` forces `e ∈ {1, n}`, and `e = 1` means `p ∣ u₁`. Formalize "index" as the least positive `k`
with `p ∣ uₖ` (mirror `entryPoint`) and prove the dichotomy.
**Why now**: `dvd_iff_index_dvd_of_primitive` is exactly the converter "`p ∣ uₖ` ⟺ index ∣ k"; the
prime-index case collapses to `Nat.Prime`'s divisor dichotomy with no further machinery.
**If true**: gives a fast structural criterion for primitivity at prime indices, the easy half of Carmichael.
**If false**: reveals an unstated coprimality hypothesis between `u₁` and the higher terms.
