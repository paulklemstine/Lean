# Future Directions — The Boltzmann Bridge VII: Euler Characteristic as a Valuation

## Synthesis

This cycle fused two strands of the catalog that had been developing in parallel.
The first is the **Carmichael primitive-divisor program** (`Catalog/Shared/CarmichaelProof.lean`),
whose structural engine is `bridge_lemma` and the "Fib gcd identity" `Nat.fib_gcd`:
a Fibonacci number `fib n` acquires a *primitive* prime divisor — one dividing no
earlier `fib k` — precisely because the sequence is a **strong divisibility sequence**.
The second is the **0-dimensional persistence / Euler-characteristic** thread of the
Boltzmann Bridge sub-catalog, where the count of connected components of a finite
point cloud is a topological invariant.

The new file `Catalog/Physics/BoltzmannBridge/EulerValuation.lean` proves that these
two pictures are the *same* counting law seen from two sides. The 0-dimensional Euler
characteristic `χ₀ = card` is a **valuation** (`eulerChar0_valuation`,
`eulerChar0_inclusion_exclusion_three`, `eulerChar0_disjoint_add`,
`eulerChar0_mono`), and the rank of apparition `a` of a prime `p`
(`fib_dvd_iff_rank_dvd`) collapses the divisibility set into a single arithmetic
progression. The bridge theorem `eulerChar0_fib_divisible_count` then shows that the
Euler characteristic of the "`p`-divisible index" subcomplex of `(0, n]` is the bare
floor `⌊n / a⌋` — a topological count evaluated by a partition-style arithmetic
quantity.

## Results Summary

All results below are proved with `sorry = 0` and use only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

1. `eulerChar0_valuation` — `χ₀(s ∪ t) + χ₀(s ∩ t) = χ₀ s + χ₀ t`.
2. `eulerChar0_inclusion_exclusion_three` — full 3-set inclusion–exclusion.
3. `eulerChar0_mono` — monotonicity of `χ₀` along a filtration `s ⊆ t`.
4. `eulerChar0_disjoint_add` — additivity on disjoint pieces.
5. `fib_dvd_iff_rank_dvd` — `p ∣ fib n ↔ a ∣ n` for the rank of apparition `a`
   (the clean iff distilled from `bridge_lemma` and `Nat.fib_gcd`).
6. `eulerChar0_fib_divisible_count` — the bridge: `χ₀{k ∈ (0,n] : p ∣ fib k} = ⌊n/a⌋`.

Infrastructure fixes: the project `lakefile.toml` was missing `srcDir = "Catalog"`,
so nothing built; this is now corrected. The broken `import Shared.CarmichaelHelper`
in `CarmichaelProof.lean` (referencing an absent file) was removed, making that file
elaborate; every lemma it needs is self-contained over Mathlib.

## Research Directions

### Direction 1 — Close the infinite tail of Carmichael's theorem via a primitive-part lower bound.
`fib_carmichael_composite` is fully proved for `13 ≤ n ≤ 10000` by `native_decide`, but
the composite tail `n > 10000` is still `sorry`. By `primPart_implies_primitive` the
entire claim reduces to the single inequality `1 < primPart n` for every composite
`n ≥ 13`. **The key insight is** that `primPart n = fib n / ∏_{d ⊊ n} (p-power strip)`
is, up to bounded prime "intrinsic" factors, the `n`-th *cyclotomic value*
`Φ_n(φ, ψ)` of the Lucas pair, whose absolute value grows like `φ^{ϕ(n)}` and so
exceeds `1` once `ϕ(n) ≥ 2`. The falsifiable prediction: there is a constant `C` and
an effective bound `B` such that for all composite `n > B`, `primPart n ≥ φ^{ϕ(n)} / C^{ω(n)} > 1`.
**Why now?** The computational scaffold (`primPart`, `stripAllAux`, the coprimality
lemma `stripAllAux_coprime`) already isolates the primitive part exactly; what is
missing is purely the analytic lower bound, which can be attacked through Mathlib's
existing `Nat.fib` asymptotics and the golden-ratio closed form, turning a
research-level theorem into a finite chain of estimates.

### Direction 2 — Graded Euler characteristic as an alternating valuation.
Generalize `eulerChar0` to a graded invariant `χ(K) = Σ_i (-1)^i (#i-cells)` on finite
abstract simplicial complexes and prove it is a valuation on the lattice of
subcomplexes: `χ(K ∪ L) + χ(K ∩ L) = χ K + χ L`. **The key insight is** that the
0-dimensional valuation law proved here is the bottom row of the Mayer–Vietoris long
exact sequence, and the alternating sum kills the connecting maps, so the valuation
identity lifts verbatim to every dimension. The falsifiable prediction: `χ` defined
cell-wise satisfies the two-set valuation law for *all* finite complexes, with no
acyclicity hypothesis. **Why now?** The cardinality-valuation backbone
(`Finset.card_union_add_card_inter`) used in `eulerChar0_valuation` extends directly to
graded `Finset`-indexed sums, so the higher-dimensional statement is within reach of
the same `linarith`-after-inclusion–exclusion technique.

### Direction 3 — Multiplicativity of the apparition-count across coprime moduli.
For coprime primes `p, q` with ranks `a, b`, predict that the Euler characteristic of
the set `{k ∈ (0,n] : p ∣ fib k ∧ q ∣ fib k}` equals `⌊n / lcm(a,b)⌋`. **The key
insight is** that `fib_dvd_iff_rank_dvd` turns simultaneous divisibility into the
single condition `lcm(a,b) ∣ k`, so the bridge theorem `eulerChar0_fib_divisible_count`
applies with `a` replaced by `lcm(a,b)`. The falsifiable prediction is the exact
equality with `lcm`, not `a·b`, capturing the failure of naive independence. **Why
now?** `eulerChar0_fib_divisible_count` already reduces such counts to floor divisions;
only an `lcm`-divisibility merge lemma (`a ∣ k ∧ b ∣ k ↔ lcm a b ∣ k`, already in
Mathlib) is needed.

### Direction 4 — A Boltzmann partition function from the apparition spectrum.
Define `Z(β, n) = Σ_{k ∈ (0,n]} exp(-β · v_p(fib k))` where `v_p` is the `p`-adic
valuation, and conjecture that `lim_{n→∞} (1/n) log-derivative of Z` is governed by the
rank `a` and the `p`-adic valuation growth `v_p(fib (a·m)) = v_p(fib a) + v_p(m)`
(lifting-the-exponent). **The key insight is** that the apparition structure makes the
energy levels `v_p(fib k)` an *arithmetic* spectrum: nonzero only on multiples of `a`,
and there growing logarithmically, so the partition function factorizes like a free
gas with a single mode at energy gap controlled by `a`. The falsifiable prediction:
`Z(β,n) - (n - ⌊n/a⌋)` decays geometrically in `β`. **Why now?** The component-count
`⌊n/a⌋` from `eulerChar0_fib_divisible_count` is exactly the degeneracy of the ground
(zero-energy) level, giving the leading term of `Z` for free; Mathlib's
lifting-the-exponent lemmas supply the excited-level energies.

### Direction 5 — Inclusion–exclusion sieve for primitive divisors.
Combine Directions 2–3 into a sieve: count indices `k ≤ n` such that `fib k` has *no*
primitive prime divisor among a finite prime set `S`, via the alternating valuation
over the intersection lattice indexed by ranks `{a_p : p ∈ S}`. **The key insight is**
that `eulerChar0_inclusion_exclusion_three` is the `|S| = 3` instance of a general
Möbius/valuation sieve whose terms are all floors `⌊n / lcm_{p∈T} a_p⌋`, so the entire
sieve is a closed-form alternating sum of floor divisions. The falsifiable prediction:
the density of `k` avoiding all primitive divisors in `S` is `∏_{p∈S}(1 - 1/a_p)` in the
limit, exactly the independent-events heuristic corrected by `lcm` interactions. **Why
now?** The valuation already proved for two and three sets is the engine of any
inclusion–exclusion sieve; generalizing it to `n`-fold unions (Direction 2's graded
form, restricted to degree 0) immediately yields the sieve identity.
