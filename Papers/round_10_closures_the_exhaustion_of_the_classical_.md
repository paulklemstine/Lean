# Computational evidence — Round-10 Closures (Geometry / factoring-barrier thread)

All computations below were run inside Lean 4 (`#eval`, exact integer arithmetic) before the
corresponding theorems were formalised in `Catalog/Geometry/Round10Closures/`.  They are
evidence, not proof: every claim they support is proved separately and `sorry`-free in the
Lean files.

## 1. The trace lemma, brute-forced

Direct enumeration of `{x ∈ (Z/N)ˣ : x^k = 1}` versus the predicted
`gcd(k, p-1) · gcd(k, q-1)`:

| N        | k = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|----------|-------|---|---|---|---|---|---|---|
| 15 = 3·5 | 1 | 4 | 1 | 8 | 1 | 4 | 1 | 8 |
| 21 = 3·7 | 1 | 4 | 3 | 4 | 1 | 12| 1 | 4 |
| 35 = 5·7 | 1 | 4 | 3 | 8 | 1 | 12| 1 | 8 |

Prediction and enumeration agree in every entry (checked for `k ≤ 12`).
Formalised as `Round10.freeWitness_eq`.

## 2. Squarefree extension: square roots of unity count the prime factors

| N                     | ω(N) | #{x : x² = 1} |
|-----------------------|------|----------------|
| 105 = 3·5·7           | 3    | 8              |
| 1155 = 3·5·7·11       | 4    | 16             |
| 15015 = 3·5·7·11·13   | 5    | 32             |

`2^ω(N)` in each case.  Formalised as `Round10.freeWitness_two_prod`.

## 2b. Non-squarefree odd moduli

Enumeration versus `∏_{p ∣ N} gcd(φ(p^{v_p(N)}), k)`:

| N  | k = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|----|-------|---|---|---|---|---|---|---|
| 9  | 1 | 2 | 3 | 2 | 1 | 6 | 1 | 2 |
| 45 | 1 | 4 | 3 | 8 | 1 | 12| 1 | 8 |

Agreement in every entry (`Round10.freeWitness_odd`).  For `N = 45`: `φ(45) = 24` while the
Carmichael exponent is `lcm(φ(9), φ(5)) = lcm(6,4) = 12`, and `R_12(45) = 24` is the first
complete witness — matching `Round10.least_complete_exponent_odd`.

## 3. Counterexample hunt for the joint-closure claim (experiment 337)

Exponent set `S = {6, 12, 15, 20, 30, 60}`.  Primes `p < 400` whose local profile
`(gcd(p-1,k))_{k ∈ S}` is maximal, i.e. equal to `(6,12,15,20,30,60)`:

```
61, 181, 241
```

(continuing: 421, 541, 601, 661, … — the primes `≡ 1 mod 60`).

Joint profiles of the semiprimes `61·7` and `181·7` over `S`:

```
61·7 : [36, 72, 45, 40, 180, 360]
181·7: [36, 72, 45, 40, 180, 360]
```

Identical — a persistent collision.  No counterexample to joint closure was found;
Dirichlet's theorem then upgrades the search to an infinite family
(`Round10.joint_profile_collisions_infinite`, `Round10.experiment337_collision`).

## 4. The smooth-step walk (experiment 338)

Walk `x ↦ 2x mod 8051` (`8051 = 83 · 97`) from seed `3`:

```
values : 3, 6, 12, 24, 48, 96, 192, 384, 768, 1536, 3072, 6144, …
gcd(·, 8051) : 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
```

Every value is a unit; the gcd channel is empty (`Round10.smoothWalk_no_nontrivialDivisor`,
`Round10.labnote_walk_8051`).

## 5. Cost of completeness (cycle 2)

For `N = 8051 = 83 · 97`: `φ(N) = 82 · 96 = 7872`, `lcm(82, 96) = 3936`, `√φ(N) = 88`.
The complete exponent `3936` indeed satisfies `3936 ≥ 88`, and the general lower bound
`φ(N) ≤ k²` is proved as `Round10.complete_witness_exponent_lower_bound`.

Hint amplification on the same modulus: `p + q = 180`, `√(180² − 4·8051) = 14`,
`(180 − 14)/2 = 83` (`Round10.labnote_hint_8051`).
