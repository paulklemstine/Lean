# Future Directions — Tropical direct-sum convolution for binary code weight enumerators

This cycle generalized the *binary* tropical direct-sum dictionary
(`TropicalWeightEnumerator`, `CodeDirectSum`, `CumulativeWeightConvolution`,
`WeightDistributionConvolution`) to the **finite indexed direct sum**
`⨁_{i∈ι} C_i = Fintype.piFinset C` (`IndexedDirectSum.lean`), proving:

- `piCode_card` : `|⨁ᵢ Cᵢ| = ∏ᵢ |Cᵢ|` (n-ary cardinality);
- `ptwe_piCode` / `ptwePlus_piCode` : n-ary tropical additivity
  `ptwe (⨁ᵢ Cᵢ) t = ∑ᵢ twe (Cᵢ) t` (min-plus) and its max-plus dual;
- `pminDist_piCode` : the n-ary tropical-min law `pminDist (⨁ᵢ Cᵢ) = minᵢ minDist (Cᵢ)`;
- `twe_eq_min_of_zero_ones` / `twePlus_eq_max_of_zero_ones` /
  `twe_add_twePlus_of_zero_ones` : the **general** `0`-and-`ones` hull-envelope and
  profile self-duality (the catalog Hamming computations are now corollaries);
- `ptwe_add_ptwePlus_of_zero_ones` : n-ary profile self-duality
  `ptwe + ptwePlus = (∑ᵢ Nᵢ)·t`;
- the k-fold Hamming-power instantiations (`hamming_power_card = 16^k`,
  `hamming_power_ptwe = k·min 0 (8t)`, `hamming_power_pminDist = 4`,
  `hamming_power_ptwe_add_ptwePlus = 8k·t`).

The following conjectures are bold but **falsifiable** and each builds directly on the
primitives now available.

## Conjecture 1 — n-ary exact Cauchy (multinomial) convolution of the weight distribution

`WeightDistributionConvolution.wexact_append` gives the binary Cauchy product
`wexact (C ⊕ D) t = ∑_{s≤t} wexact C s · wexact D (t−s)`.

**Conjecture.** Define `pwexact C t = #{ v ∈ piCode C : pwt v = t }`. Then for an indexed
family,
```
pwexact C t = ∑_{(t_i) : ∑ t_i = t} ∏_i wexact (C i) (t_i),
```
the **multinomial convolution** over all ways to distribute the total weight `t` across
the blocks (a sum over `Finset.Nat.antidiagonalTuple` / weak compositions of `t` into
`|ι|` parts). The binary `wexact_append` is the `|ι| = 2` case. *Test:* for the constant
Hamming family with `|ι| = k`, `pwexact (fun _ => hamming) 8` should equal the degree-`8`
coefficient of `(1 + 14X⁴ + X⁸)^k`; check `k = 3` gives the `X⁸`-coefficient
`3·(1·14·... )` of the cube against an independent `native_decide` count over
`Fin 3 → Fin 8 → ZMod 2`.

## Conjecture 2 — `ptwe` is concave and piecewise-linear, with prescribed breakpoints

`ptwe C hC` is a `min` of finitely many linear functions `t ↦ (pwt v)·t`, hence concave
and piecewise-linear in `t`.

**Conjecture.** (a) `ptwe C hC` is concave on `ℝ` (`ConcaveOn ℝ Set.univ (ptwe C hC)`).
(b) For a code containing `0` it is identically `0` on `t ≥ 0` and linear with slope
`= maxWeight C` on `t ≤ 0`; the unique interior breakpoint is at `t = 0`. (c) The set of
realized slopes of `ptwe` equals the lower convex-hull vertex set of the weight spectrum
`{ wt c : c ∈ C }` — formalizing the "information loss" insight that interior strata
(e.g. Hamming's minimum distance `4`) are erased. *Test:* prove
`ptwe hamming` has exactly the two slopes `{0, 8}` and is non-differentiable only at `0`.

## Conjecture 3 — MacWilliams duality refines the tropical-min `minDist` law

The catalog records `minDist` separately because `twe` erases it. The MacWilliams identity
relates `W_C` and `W_{C⊥}`.

**Conjecture.** For a self-dual code `C = C⊥` (the `appendCode_selfDual` setting), the
dual-distance equals the minimum distance, and the tropical pair `(twe C, twePlus C)`
together with `minDist C` is a **complete** direct-sum invariant in the following sense:
two doubly-even self-dual codes have the same `(twe, twePlus, minDist)` profile under all
finite direct-sum powers iff they have the same weight enumerator. *Test (falsifiable):*
search length ≤ 16 self-dual codes for a pair with equal `(twe, twePlus, minDist)` but
distinct `wexact`; if found, the conjecture is false and the minimal extra invariant is the
full `wexact`.

## Conjecture 4 — supermultiplicative `wcount` bound is tight exactly at hull thresholds

`CumulativeWeightConvolution.wcount_append_ge` is strict at interior thresholds
(`225 < 227` on Hamming).

**Conjecture.** `wcount C s · wcount D r = wcount (C ⊕ D) (s+r)` **iff** both `s` and `r`
are saturation thresholds (`s ≥ length C` or the spectrum of `C` has no weight in
`(s, length C]`, and symmetrically for `r`). More generally, the n-ary
`∏ᵢ wcount (Cᵢ) sᵢ ≤ wcount (⨁ᵢ Cᵢ) (∑ᵢ sᵢ)` is an equality iff each `sᵢ` is a
saturation threshold for `Cᵢ`. *Test:* verify equality at `(s,r) = (8,8)` and strict at
`(4,4)`, `(4,8)`, `(8,4)` on Hamming.

## Conjecture 5 — tropical tensor (product) code and a min-plus distributive law

Direct sum tropicalizes addition to `min`/`+`; the **tensor product** `C ⊗ D` (codewords
indexed by `Fin m × Fin n`, the row/column code) should tropicalize the *product* of
enumerators differently.

**Conjecture.** Define `twt (C ⊗ D) t = min_{x ∈ C⊗D} (wt x)·t`. Then minimum distance is
**multiplicative** under tensor product, `minDist (C ⊗ D) = minDist C · minDist D` (a
classical fact), giving a *second* tropical operation under which `minDist` is the tropical
**product** (`+` in log-coordinates) rather than the tropical **sum** (`min`) it is under
direct sum. Together, `(direct sum, tensor)` realize `(min, +)`-tropical *addition and
multiplication* on the `minDist` invariant, i.e. a genuine tropical semiring structure on
code invariants. *Test:* prove `minDist (hamming ⊗ hamming) = 16 = 4·4` and contrast with
`minDist (hamming ⊕ hamming) = 4 = min(4,4)`.
