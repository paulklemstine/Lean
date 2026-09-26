# Computational evidence: ETALE-DIAL (the hinted `(N, s)` view of residue pairs)

All numbers below came from exhaustive enumeration with small Lean `#eval` scripts over
unit quadruples `(p, q, p', q')` of `ZMod m`. They are exploration data. The formal
statements they suggested are proved in `Catalog/Bridges/EtaleDial*.lean`.

## 1. Vieta-injective conductors (does `(p+q, pq) mod m` determine `{p, q} mod m`?)

Exhaustive search over `1 ≤ m ≤ 60`:

```
1, 2, 3, 5, 6, 7, 10, 11, 13, 14, 17, 19, 22, 23, 26, 29, 31, 34, 37, 38, 41, 43, 46, 47, 53, 58, 59
```

These are exactly `{1, 2} ∪ {ℓ, 2ℓ : ℓ odd prime}`. The general statement is proved as
`EtaleDial.vietaInjective_zmod_iff` (it also covers `m = 0`, i.e. `ℤ`). We did not look
this set up in OEIS, so no OEIS entry is cited.

## 2. Colliding cells at small conductors

| m | colliding `(s, N)` cells | example |
|---|---|---|
| 8 | 4 | `{1,1}~{5,5}`, `{3,3}~{7,7}`, `{1,3}~{5,7}`, `{1,7}~{3,5}` |
| 15 | 6 (all of CRT-matching type) | `{1,2}~{7,11}`, `{1,14}~{4,11}` |
| 16 | 16 | `{1,1}~{5,13}~{9,9}` |

Mod 8, every fibre is a union of orbits under `u ↦ 5u` (the kernel of reduction to mod 4).
This is `EtaleDial.vieta_fibre_zmod_eight`.

**Counterexample to the round-30 explanation using actual primes:** `17·41 = 697` and
`13·29 = 377` are both `≡ 1 (mod 8)`, and `17+41 = 58`, `13+29 = 42` are both `≡ 2 (mod 8)`.
But `17 ≡ 1` while `13 ≡ 29 ≡ 5 (mod 8)`. So the sum does not determine `p mod 8`
(`EtaleDial.claim_refuted_by_primes`).

## 3. Resolution of the hinted view at prime-power conductors

We looked for the largest `r ∣ m` such that `(p+q, pq) mod m` always determines `{p, q} mod r`:

| m = ℓ^k | 8 = 2³ | 16 = 2⁴ | 32 = 2⁵ | 64 = 2⁶ | 9 = 3² | 27 = 3³ | 25 = 5² |
|---|---|---|---|---|---|---|---|
| max r | 4 | 4 | 8 | 8 | 3 | 9 | 5 |
| ℓ^⌈k/2⌉ | 4 | 4 | 8 | 8 | 3 | 9 | 5 |

The values match `ℓ^⌈k/2⌉` in every case. This is proved as the half-conductor law
(`EtaleDial.half_conductor_law`), with sharpness (`half_conductor_sharp`) and the full
classification of sum-sufficient type maps (`sumSufficient_iff_factors_halfConductor`).

**Discriminant refinement.** For `(ℓ,k) ∈ {(2,3),(2,4),(2,5),(3,2),(3,3),(3,4),(5,2),(5,3)}`,
every colliding pair agrees modulo `ℓ^(k − min(v_ℓ(p−q), ⌊k/2⌋))`. We found no counterexamples.
This is proved as `EtaleDial.refined_conductor_law` / `hensel_form`.

## 4. Triples (a lead for future work)

For triples of units with equal `(e₁, e₂, e₃) mod m`, the largest resolution `r` for which
the multiset mod `r` is always determined was: `m = 9 → 3`, `m = 27 → 3`, `m = 8 → 4`.
At odd `ℓ` this fits `ℓ^⌈k/3⌉`. At `ℓ = 2` there is an anomaly: the resolution is 4 rather than 2.
None of this is formalized. It is recorded as a conjecture in `FUTURE_DIRECTIONS.md`.

## 5. The three quadratic channels at conductor 8

| unit u | 1 | 3 | 5 | 7 | invariant under `u ↦ 5u`? |
|---|---|---|---|---|---|
| χ₄ (Q(i)) | + | − | + | − | yes → sum-sufficient |
| χ₈ (Q(√2)) | + | − | − | + | no |
| χ₈' (Q(√−2)) | + | + | − | − | no |
| split type of x⁴+1 | split | – | – | – | no |

These rows are proved in `EtaleDialConductorEight.lean` (`exactly_one_quadratic_channel`,
`splitType_not_sumSufficient`, `etaleType_not_sumSufficient`).
