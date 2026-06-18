# Future Directions — The Apparition Ideal of Primitive Fibonacci Divisors

## Synthesis

This cycle did two things. First, it repaired and closed the *prime* half of
Carmichael's primitive-divisor theorem for Fibonacci numbers: the missing file
`Catalog/Shared/CarmichaelHelper.lean` is now supplied and proves
`fib_primitive_divisor_prime` sorry-free — for a **prime** index `n ≥ 13`, *every*
prime factor of `F(n)` is automatically a primitive divisor, because the entry point
of any `p ∣ F(n)` divides the prime `n` and cannot be `1`. Second, it isolated the
genuinely hard residue — the *composite* asymptotic case `n > 10000` in
`Catalog/Shared/CarmichaelProof.lean` — and reframed the whole primitive-divisor
story through a single structural lens in
`Catalog/Speculative/AutoResearch/CarmichaelEntryPointStructure.lean`:

> For a primitive divisor `p` of `F_n`, the apparition set `A p = {m | p ∣ F_m}`
> is *exactly* the principal additive ideal `n·ℕ`.

From that one identification (`apparition_set_eq`) we obtained additive closure
(`apparition_closed_add`), the generator characterization
(`isPrimitive_iff_generates`), and an exact density law (`apparition_count`:
precisely `⌊N/n⌋` of the indices `1..N` are apparition indices). This is a
*localization* picture: primitivity localizes the divisibility relation `p ∣ F_·`
onto one congruence class, collapsing an analytic-looking counting question to an
exact divisor count.

## Results Summary

- `CarmichaelHelper.fib_primitive_divisor_prime` — Carmichael, prime index, sorry-free.
- `CarmichaelHelper.fib_one_lt` — `1 < F(n)` for `n ≥ 3`.
- `CarmichaelEntryPointStructure.dvd_fib_iff_index_dvd` — the pinning law `p ∣ F_m ↔ n ∣ m`.
- `CarmichaelEntryPointStructure.apparition_set_eq` — `A p = n·ℕ`.
- `CarmichaelEntryPointStructure.apparition_closed_add` — `A p` is a sub-monoid of `(ℕ,+)`.
- `CarmichaelEntryPointStructure.isPrimitive_iff_generates` — `n` generates the apparition ideal.
- `CarmichaelEntryPointStructure.apparition_count` — density `= ⌊N/n⌋`.
- `CarmichaelEntryPointStructure.prime_index_has_primitive` — Carmichael bridge in `IsPrimitive` form.
- Build infrastructure repaired: `srcDir = "Catalog"` restored in `lakefile.toml`, and the
  previously-missing `Shared.CarmichaelHelper` import now resolves.

The remaining open `sorry` is the composite tail `n > 10000` of
`fib_carmichael_composite`; it is exactly Carmichael's asymptotic theorem and is not
yet in Mathlib. Directions 1–2 below attack it head-on.

## Research Directions

### 1. Close the composite tail via the primitive part `Φ_n`

Define the primitive (cyclotomic) part `Φ_n = ∏_{d ∣ n} F_d^{μ(n/d)}` and prove it is
a positive integer with `Φ_n ∣ F_n` and `F_n = ∏_{d ∣ n} Φ_d`. The falsifiable claim
is the explicit bound **`Φ_n > n` for every composite `n > 12`**, which would discharge
the open `sorry` because every prime of `Φ_n` other than the single "intrinsic" prime
(`≤` the largest prime factor of `n`, dividing `Φ_n` at most once) is primitive.
The key insight is that the multiplicative structure of `Φ_n` converts the existence
question into a *size* question: once `Φ_n` exceeds its single removable intrinsic
prime, a primitive divisor must survive. Why now? The catalog already contains the
Lifting-the-Exponent machinery (`fib_lte`) and the entry-point characterization needed
to pin the intrinsic prime, and the totient identity `∑_{d∣n} μ(n/d)·d = φ(n)` reduces
the bound to a clean Fibonacci growth estimate `φ^{d-2} ≤ F_d ≤ φ^{d-1}`.

### 2. A valuation-only (LTE) route avoiding real analytic bounds

Instead of bounding `Φ_n` over ℝ, prove the composite case by a purely `p`-adic
counting argument: for each prime `p ∣ F_n` with entry point `d = z(p) < n`, LTE gives
`v_p(F_n) = v_p(F_d) + v_p(n/d)`, so the non-primitive part of `F_n` divides
`n · ∏_{d ∣ n, d<n} F_d^{[z=d-correction]}`. The falsifiable claim is that the
**non-primitive part of `F_n` is bounded by `n · F_{n/q}`** (with `q` the least prime
factor of `n`), which is strictly smaller than `F_n` for `n > 12`. The key insight is
that LTE turns "is there a primitive prime" into an inequality between two explicit
integers, sidestepping `√5` estimates entirely. Why now? `fib_lte` is already proved
in the catalog, and the `removePrimesOf` / `primPart` algorithm in
`CarmichaelProof.lean` is exactly the integer whose lower bound this direction needs.

### 3. The apparition ideal for general Lucas sequences

Generalize `apparition_set_eq` from `Nat.fib` to an arbitrary nondegenerate Lucas
sequence `U_n(P,Q)`, which is again a strong divisibility sequence. The falsifiable
claim is: **for every strong divisibility sequence with `U_1 = 1`, a primitive divisor
of `U_n` has apparition set exactly `n·ℕ`, and the density law `⌊N/n⌋` holds verbatim.**
The key insight is that *none* of this cycle's structural theorems used anything beyond
`gcd(U_m,U_n) = U_{gcd(m,n)}` and `U_1 = 1`; they are theorems about strong divisibility
sequences, not about Fibonacci. Why now? The proofs here are already factored through
the abstract meet law `fib_dvd_gcd_iff`, so the generalization is a matter of replacing
`Nat.fib_gcd` by a `StrongDivisibilitySequence` typeclass hypothesis.

### 4. Entry-point equidistribution from the exact density law

`apparition_count` gives the *exact* count `⌊N/n⌋`; summing over primitive primes turns
this into a statement about how Fibonacci entry points distribute. The falsifiable claim
is: **`∑_{p ≤ x, p prime} 1/z(p)` diverges, and `#{p ≤ x : z(p) = n}` is governed by the
density `1/n` of the apparition class.** The key insight is that the apparition ideal
makes "how often does a fixed prime appear" exact, so the only remaining randomness is in
the *assignment* `p ↦ z(p)`, which is now the sole object of study. Why now? With the
per-prime density nailed down to `⌊N/n⌋`, the aggregate statement becomes a clean
Abel-summation problem rather than an entangled analytic estimate.

### 5. Functoriality: the join law as a lattice homomorphism

Promote `simultaneous_apparition_finset` to the statement that the map
`p ↦ A p = z(p)·ℕ` is a **lattice homomorphism** from the primitive divisors (ordered by
"divides the same Fibonacci numbers") into the lattice of principal ideals of `(ℕ, ∣)`,
sending joint apparition to `lcm` and the meet law `fib_dvd_gcd_iff` to `gcd`. The
falsifiable claim is that this map is an *injective* lattice homomorphism (injectivity is
`isPrimitive_unique`). The key insight is that the gcd/lcm bridges already proved are
precisely the meet/join preservation conditions, so the homomorphism is "already there",
only un-assembled. Why now? This is the homotopy/localization unification the program
calls for: the apparition ideal exhibits the Fibonacci divisibility poset as a
*localization* of `(ℕ, ∣)` at the primitive divisors, and naming the homomorphism makes
that localization statement precise and machine-checkable.
