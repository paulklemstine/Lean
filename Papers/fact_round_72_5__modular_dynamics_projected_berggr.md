# Computational evidence (exp 555 formalisation)

All numbers below were produced by `#eval` inside the project's Lean environment
(`lake env lean`), using the *same* definitions that the theorems are stated
about (`Cryptography.BerggrenModular.hypNat`, `Dive.revealSet`, `Dive.hitSet`,
`Dive.rhoHitSet`).  They are exploratory checks, not proofs; the corresponding
proofs are in the `.lean` files listed at the end.

## 1. Berggren hypotenuses are `1 (mod 4)`-smooth

First two levels of the tree (word, hypotenuse, prime factorisation):

| word | `c` | factors |
|---|---|---|
| `[]` | 5 | 5 |
| `B₁` | 13 | 13 |
| `B₂` | 29 | 29 |
| `B₃` | 17 | 17 |
| `B₁B₁` | 25 | 5·5 |
| `B₂B₁` | 73 | 73 |
| `B₃B₁` | 53 | 53 |
| `B₁B₂` | 89 | 89 |
| `B₂B₂` | 169 | 13·13 |
| `B₃B₂` | 85 | 5·17 |
| `B₁B₃` | 65 | 5·13 |
| `B₂B₃` | 97 | 97 |
| `B₃B₃` | 37 | 37 |

Every listed prime is `≡ 1 (mod 4)`.  Exhaustive check over all control words of
length `≤ 6` (4096 enumerated words):

```
all prime factors ≡ 1 (mod 4)  →  true
```

Proved as `prime_dvd_hyp_mod_four` / `hypNat_prime_factors_one_mod_four`.

## 2. Blum-integer blindness

`gcd(c, N) = 1` for **every** node of depth `≤ 6` and every tested Blum modulus
`N ∈ {21 = 3·7, 77 = 7·11, 33 = 3·11, 209 = 11·19}`:

```
[true, true, true, true]
```

Control (non-Blum, `N = 65 = 5·13`, both factors `≡ 1 (mod 4)`): the dive splits
`N` already inside depth 3, e.g. `c = 425 → gcd = 5`, `c = 481 → gcd = 13`,
`c = 169 → gcd = 13`.  So the null is specific to `3 (mod 4)` factors, not an
artefact of the search.  Proved as `berggren_dive_blind_on_blum`.

## 3. Hit density of a gcd dive is `p + q − 2`

| `N = p·q` | `#revealSet N` | `p + q − 2` |
|---|---|---|
| 15 | 6 | 6 |
| 21 | 8 | 8 |
| 35 | 10 | 10 |
| 55 | 14 | 14 |
| 91 | 18 | 18 |

Proved as `Dive.card_revealSet_semiprime`.  The per-node success probability is
`(p+q−2)/pq ≍ 1/p_min`, i.e. `α = 1`, not `α = 1/2`.

## 4. Structural under-sampling by the orbit

Revealing residues reachable by a stream that never hits a multiple of `p`
(which is the case for the Berggren hypotenuse whenever `p ≡ 3 (mod 4)`), against
the total:

| `p·q` | reachable | total |
|---|---|---|
| 3·5 | 2 | 6 |
| 3·13 | 2 | 14 |
| 7·13 | 6 | 18 |
| 11·17 | 10 | 26 |

reachable `= p − 1` in every case.  Proved as `Dive.card_reachableReveal`.

## 5. The guidance null, directly observed

`N = 15`, `t = 4` nodes, every possible 2-node inspection schedule
`S ⊆ {0,1,2,3}`:

```
[32400, 32400, 32400, 32400, 32400, 32400]
```

All six schedules succeed on exactly the same number of streams — the success
count depends on `|S|` only.  Proved as `Dive.hitSet_card_eq_of_card_eq` and,
sharply, `Dive.hitSet_card_eq_scaled`.

## 6. Pair test versus value test

`N = 15`, `t = 4`: `#rhoHit = 45060`, `#hit (full schedule) = 44064`, out of
`15^4 = 50625`.  At this toy size (`p = 3`) the two are comparable, as expected —
the separation is asymptotic in `p`.  The proved statement
(`Dive.rho_dominates_dive`) is the asymptotic one: at a budget `t ≍ 2√p` the pair
test succeeds on `≥ 30 %` of streams while every value schedule stays below
`50 %`, and the value test only reaches `50 %` at `t ≥ p/4`.

## 7. OEIS

The hypotenuse sequence along the all-`B₂` spine, `5, 29, 169, 985, 5741, 33461,
…` satisfies `c_{t+2} = 6c_{t+1} − c_t` (this is the NSW/Pell-adjacent hypotenuse
sequence, already formalised in `BerggrenModular/SilverOrbit.lean` as
`pellC_recurrence`).  No new sequence is introduced by this cycle.

## Files

* `Catalog/Cryptography/BerggrenModular/BlumImmunity.lean`
* `Catalog/Cryptography/BerggrenModular/TrialDivisionEquivalence.lean`
* `Catalog/Cryptography/BerggrenModular/RhoSeparation.lean`
