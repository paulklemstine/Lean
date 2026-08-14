# Computational evidence — gcd moments of a modulus

All computations below were run before formalisation, to fix the statements; every claim that
is *asserted* in this project is additionally proved in Lean (see the three files in
`Catalog/Novelty/GCDMoment*.lean`).  Items marked **(exploratory)** were only computed, and are
recorded here as evidence, not as verified results.

Notation: `M_k(n) = Σ_{x<n} gcd(n,x)^k`, `N = pq` a semiprime, `s = p+q` the trace,
`P_j = p^j + q^j`.

## 1. Small-case calculations

| `n` | `M_1(n)` | `M_2(n)` | `M_3(n)` |
|-----|----------|----------|----------|
| 6 (=2·3)  | 15  | 55   | 261 |
| 10 (=2·5) | 27  | 145  | 1161 |
| 15 (=3·5) | 45  | 319  | 3741 |
| 21 (=3·7) | 65  | 605  | 10121 |
| 35 (=5·7) | 117 | 1595 | 45021 |

Cross-checks against the closed form `M_k = N^k + N·P_{k−1} − P_k + N − s + 1`:
`M_1(6) = 4·6 − 2·5 + 1 = 15`; `M_2(6) = 36 + 18 + 1 + 5·5 − 25 = 55`;
`M_2(15) = 225 + 45 + 1 + 14·8 − 64 = 319`; `M_1(15) = 60 − 16 + 1 = 45`. The first two of these are checked inside the Lean file by
`decide`.

**Full enumeration.** For all 55 semiprimes `pq ≤ 1200` with `p,q ∈ {2,…,31}` distinct and for
`k = 1,…,6` (330 instances) the closed form matched the brute-force sum exactly: 330/330,
no exceptions.  (Formal proof: `GCDMoment.gcdMoment_eq_momentPoly`.)

## 2. The inversion problem: does the observed moment pin down the factorisation?

For each modulus `N ≤ 4000` we enumerated all factorisations `N = a·b` with `2 ≤ a ≤ b`, computed
the predicted moment `Φ_k(a,b) = a^k(b−1) + b^k(a−1) + (a−1)(b−1)` (the `(ab)^k` term is common),
and looked for collisions between distinct factorisations of the same `N`:

| `k` | collisions for `N ≤ 4000` | witnesses |
|-----|---------------------------|-----------|
| 2 | 2 | `28 = 2·14 = 4·7`, `36 = 2·18 = 3·12` |
| 3 | 0 | — |
| 4 | 0 | — |
| 5 | 0 | — |

Both `k = 2` witnesses satisfy `(a+b) + (c+d) = N − 1` (`16+11 = 27`, `20+15 = 35`), exactly the
`s ↦ N−1−s` symmetry of the second moment polynomial.  This suggested — and Lean now proves —
the exact collision law `pairMoment_two_collision_iff`, and the collision-freeness at `k ≥ 3`
(`pairMoment_three_injective`, `pairMoment_injective_of_three_le`).

## 3. Counterexample hunt on the key inequalities

* Identity `a³·Δ₃ = (c−a)(d−a)·BR₃` with `BR₃ = acd(a+c)(a+d) − (a²+ac+c²)(a²+ad+d²) − a²`:
  tested on 3000 random rational triples `(a,c,d)` with `b = cd/a` — 0 failures.
  (Formal proof: `pairMoment_three_identity`.)
* `BR₃ > 0` for `2 ≤ a < c ≤ d`: scanned `a ≤ 80`, `c ≤ 120`, `d ≤ 400` — 0 failures.  At `a = 1`
  it *fails* (e.g. `a=1, c=d=2` gives `−14`), which is why the hypothesis `2 ≤ a` (the
  factorisation must be nontrivial) is genuinely needed.  (Formal proof: `bracket_pos`.)
* The general-`k` bracket inequality in the form
  `N·[c^k(a−1) − a^k(c−1)] > (ac)^k[N(c^{k−1}−a^{k−1}) − (c^k−a^k)] + (ac)^{k−1}(c−a)(N−ac)`
  was scanned for `k = 3,4,5,6`, `a ≤ 40`, `c ≤ 60`, `N` in a window above `c²` — 0 failures.
* **(exploratory)** The side condition `a+b+c+d < N` used in the general-`k` theorem fails only
  for `N ≤ 30`: the failing quadruples are `N ∈ {12,16,18,20,24,30}`.  At `k = 3` these are
  covered anyway by the unconditional third-moment theorem.

## 4. Variance / sampling cost

Empirically `Var(gcd(U,N)^k) ≍ N^{2k−1}` (the single probe with `gcd = N` dominates the second
moment).  E.g. for `N = 3·5 = 15`: `Var(gcd) = M_2/N − (M_1/N)² = 21.27 − 9 = 12.27`, below the
proved ceiling `4N = 60`, while `Var(gcd²) = M_4/N − (M_2/N)² ≈ 3.03·10³ ≈ 0.9·N³`.  This matches the proved bounds
`Var_k ≥ N^{2k−1} − 16N^{2k−2}` and `Var_1 ≤ 4N`.

## 5. OEIS

`M_1(n) = Σ_{d|n} d·φ(n/d)` is Pillai's arithmetical function, **A018804** (1, 3, 5, 8, 9, 15,
13, 20, 21, 27, …).  The higher moments `Σ_{d|n} d^k φ(n/d)` are the Jordan-totient style
generalisations; the semiprime specialisation is what the closed form above computes.

## 6. Second cycle: exceptional quadruples and the multiplicative structure

**(a) The seven exceptional quadruples.**  An exhaustive search over `2 ≤ a < c ≤ d < b`,
`ab = cd`, `a ≤ 60`, `b ≤ 2000` for the failure of the side condition `a+b+c+d < ab` returns
exactly seven quadruples, all with `a = 2`:

| `N` | `(a,b,c,d)` | `tail₃(c,d) = c³(d−1)+d³(c−1)+(c−1)(d−1)` | `b³` |
|-----|-------------|------------------------------------------|------|
| 12 | (2,6,3,4)   | 215  | 216  |
| 16 | (2,8,4,4)   | 393  | 512  |
| 18 | (2,9,3,6)   | 577  | 729  |
| 20 | (2,10,4,5)  | 643  | 1000 |
| 24 | (2,12,3,8)  | 1227 | 1728 |
| 24 | (2,12,4,6)  | 983  | 1728 |
| 30 | (2,15,3,10) | 2261 | 3375 |

In every row `tail₃ < b³`, the tightest margin being `215 < 216`.  This is the base case of the
induction `tail_{k+1} ≤ d · tail_k` used in `tailMoment_lt_pow`, and the whole list is what the
Lean theorem `exceptional_quadruple_classification` certifies.

**(b) Multiplicativity.**  Brute-force check `M_k(mn) = M_k(m)·M_k(n)` for all coprime `m, n`
with `mn < 300` and `k = 1,…,4`: 0 failures.

**(c) Euler product on squarefree moduli.**  `M_k(n) = ∏_{p ∣ n} (p^k + p − 1)` checked for all
squarefree `n < 400` and `k = 1,…,5`: **1210/1210 agreements**.  Example: `M_2(6) = 55 = 5·11`,
`M_3(30) = 33669 = 9·29·129`.

**(d) Prime-power local factor.**  `M_k(p^e) = Σ_{i≤e} p^{ik} φ(p^{e−i})` checked for
`p ∈ {2,3,5,7,11}`, `e ≤ 4`, `k ≤ 4`: **76/76 agreements**.

**(e) `k = 2` on genuine semiprimes.**  The only two second-moment collisions over all moduli
are at `N = 28 = 2·14 = 4·7` and `N = 36 = 2·18 = 3·12`.  Neither `28` nor `36` is a product of
two distinct primes, so no distinct-prime semiprime admits a second-moment collision — the
observation behind `factorization_from_second_moment`.

## 7. Third cycle: the refinement order and the upper envelope

All numbers in this section come from a brute-force scan (exploratory, outside Lean); the
statements they suggested are proved in `Catalog/Novelty/GCDMomentRefinementOrder.lean`, and the
individual values quoted below are re-checked inside Lean by `decide` at the end of that file.

**(a) The upper envelope `Π_k(n) = ∏_{p^e ‖ n} (p^k+p−1)^e`.**  For all `1 ≤ k ≤ 4` and all
`n ≤ 400` (1600 pairs): `M_k(n) ≤ Π_k(n)` with **0 violations**; equality occurred in 972 cases
and strict inequality in 628, and in **every** case equality held exactly when `n` is squarefree.
This is `gcdMoment_le_primeProd` together with `gcdMoment_eq_primeProd_iff_squarefree`.

| `n` | `M_2(n)` | `Π_2(n)` | squarefree? |
|-----|----------|----------|-------------|
| 4   | 22   | 25   | no  |
| 8   | 92   | 125  | no  |
| 9   | 105  | 121  | no  |
| 12  | 242  | 275  | no  |
| 16  | 376  | 625  | no  |
| 18  | 525  | 605  | no  |
| 25  | 745  | 841  | no  |
| 27  | 963  | 1331 | no  |
| 36  | 2310 | 3025 | no  |

**(b) The exact deficiency at a square.**  `M_k(p²) + (p−1)(p^k−1) = (p^k+p−1)²` checked for all
primes `p < 40` and `1 ≤ k ≤ 5`: **all agree** (e.g. `105 + 2·8 = 121` at `p = 3`, `k = 2`).
Proved as `gcdMoment_prime_sq_deficiency`.

**(c) Counterexample hunt for `r`-factor identifiability (Conjecture 2).**  For every `n < 3000`
we enumerated *all* unordered factorisations into parts `≥ 2` and compared the predicted Euler
products `∏_i (a_i^k + a_i − 1)`:

| `k` | colliding pairs found | first collision |
|-----|----------------------|-----------------|
| 1 | 105 | `234 = 2·9·13 = 3·3·26` |
| 2 | 651 | `28 = 2·14 = 4·7` |
| 3 | 0 | — |
| 4 | 0 | — |
| 5 | 0 | — |

So the `k ≥ 3` identifiability proved for two factors in cycle 2 shows no sign of failing for any
number of factors, while `k = 1, 2` fail abundantly once three or more parts are allowed — note
that the `k = 2` collisions with `r ≥ 3` parts are all inflations of the two two-part collisions
`28` and `36` classified in cycle 2.

## 8. Fourth and fifth cycle: where collisions can live

The two cycles added in this round ask *which moduli* can host a collision of predicted moments,
rather than which `k`.  The scan below is exploratory (a plain enumeration in Python); the
individual values quoted are re-checked inside Lean by `decide` at the end of
`Catalog/Novelty/GCDMomentFactorisationLattice.lean` and
`Catalog/Novelty/GCDMomentOmegaThree.lean`.

**Setup.**  For every `n < 3000` we enumerated *all* unordered factorisations of `n` into parts
`≥ 2`, evaluated `E_k = ∏_i (a_i^k + a_i − 1)`, and bucketed every collision by
`Ω(n)`, the number of prime factors of `n` counted with multiplicity.

| `k` | collisions with `Ω ≤ 2` | `Ω = 3` | `Ω = 4` | `Ω = 5` | `Ω ≥ 6` | smallest collision |
|-----|------------------------|---------|---------|---------|---------|--------------------|
| 1 | 0 | 0  | 1  | 7  | 97  | `234 = 2·9·13 = 3·3·26` (`Ω = 4`) |
| 2 | 0 | 1  | 29 | 93 | 528 | `28 = 2·14 = 4·7` (`Ω = 3`) |
| 3 | 0 | 0  | 0  | 0  | 0   | none |
| 4 | 0 | 0  | 0  | 0  | 0   | none |
| 5 | 0 | 0  | 0  | 0  | 0   | none |

Two exact statements are visible in this table, and both are now theorems:

* the `Ω ≤ 2` column is empty for **every** `k` — this is
  `no_collision_of_cardFactors_le_two` (cycle 4), which in fact holds for all `k ≥ 1` and all
  moduli, and specialises to `no_collision_semiprime` on the semiprime moduli of the factoring
  problem;
* the `Ω ≤ 3` region is empty for `k = 1` and for `k ≥ 3` — this is
  `no_collision_first_moment_of_cardFactors_le_three` and
  `no_collision_of_cardFactors_le_three` (cycle 5).  Both boundaries are attained in the data:
  `k = 2` collides at `Ω = 3` (`N = 28`), and `k = 1` collides at `Ω = 4` (`N = 234`).

**Extremal factorisations.**  In the same scan, no collision ever involved the trivial
factorisation `[n]` or the prime factorisation of `n`; e.g. at `N = 28`, `k = 2` the four
factorisations give `E = 811, 1045, 1045, 1375` for `[28], [2,14], [4,7], [2,2,7]`, the extreme
values being attained exactly once.  This is the content of `collision_of_singleton`,
`local_lt_factorisationEuler`, `collision_of_all_prime` and
`factorisationEuler_eq_primeProd_iff_all_prime` (cycle 4).
