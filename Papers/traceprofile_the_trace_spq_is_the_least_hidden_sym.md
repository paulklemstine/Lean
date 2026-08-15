# Computational evidence — TRACEPROFILE (Paper 50 / Experiment 385)

All numbers below were produced by evaluation inside Lean (`#eval` on `Finset`
computations over ℕ residues), before the corresponding theorems were formalised.
Everything reported here is *exploratory*; the statements that are actually
verified are the theorems in `Catalog/Novelty/TraceProfile*.lean`.

Notation: `S_m(N) = {x + y mod m : x y ≡ N (mod m)}` is the **trace set**,
`T_m(N) = {x + y + z mod m : x y z ≡ N (mod m)}` its three-factor analogue.

## 1. Exact trace-set size over a prime field

`2 |S_p(N)|` for `p` odd prime and `N = 1, …, p-1`:

| p | `2|S_p(N)|` for N = 1 … p-1 |
|---|---|
| 3 | 4, 2 |
| 5 | 6, 4, 4, 6 |
| 7 | 8, 8, 6, 8, 6, 6 |
| 11 | 12, 10, 12, 12, 12, 10, 10, 10, 12, 10 |
| 13 | 14, 12, 14, 14, 12, 12, 12, 12, 14, 14, 12, 14 |
| 23 | 24, 24, 24, 24, 22, 24, 22, … |

Every value is `p + 1` or `p - 1`, and it is `p + 1` exactly on the quadratic
residues (e.g. at `p = 7` the value `8` occurs at `N = 1, 2, 4` — the QRs mod 7).
This is the *refinement* of the experimental reading `(m+1)/2`: the exact law is
`|S_p(N)| = (p + χ_p(N))/2`.

Formalised as `card_traceSet_prime` and
`two_mul_card_traceSet_eq_add_legendreSym`.

## 2. CRT multiplicativity and the "one bit per prime" density

`(|S_15(N)|, |S_3(N)|·|S_5(N)|)` over all `N` coprime to `15`:
`(6,6) (2,2) (6,6) (4,4) (2,2) (3,3) (4,4) (3,3)` — equal in every case.

Primorial moduli at `N = 1`:

| M | ω(M) | \|S_M(1)\| | 2^ω·\|S_M\| | M |
|---|---|---|---|---|
| 15 | 2 | 6 | 24 | 15 |
| 105 | 3 | 24 | 192 | 105 |
| 1155 | 4 | 144 | 2304 | 1155 |

`2^ω |S_M|` sits between `∏(p-1)` and `∏(p+1)` in every case (here `N = 1` is a
square modulo every `p`, so the upper bound `∏(p+1)` is attained exactly:
`24 = 4·6`, `192 = 4·6·8`, `2304 = 4·6·8·12`).  Averaged over `N` the density is
`2^{-ω}`, matching the measured `0.5011, 0.2509, 0.1260`.

Formalised as `card_traceSet_zmod_mul`, `traceNat_primorial`,
`traceNat_one_bit_per_prime`.

## 3. The exact low-bit law (counterexample hunt)

`(p + q + p*q) % 4` over all odd `p, q < 40` (400 pairs): the set of values
observed is `{3}` — no counterexample.  Equivalent to `s₁ = 1 - N₁`.

At the next bit the law fails: among the 16 odd residue pairs mod 8, bit 2 of `s`
differs from bit 2 of `N` in exactly 12 cases (`3/4 = 0.75`, the experiment reports
`0.754`), and `(3,3)` versus `(5,13)` give the same `N mod 8` with different
`s mod 8`.

Formalised as `odd_mul_add_mod_four`, `trace_bit_two_disagrees_three_quarters`,
`trace_mod_eight_not_determined`, and generalised to `k` factors in
`odd_list_sum_prod_mod_four`.

## 4. Arity 3: where the constraint disappears

`T_p(N) = 𝔽_p` for all `N ≠ 0`?

| p | 3 | 5 | 7 | 11 | 13 | 17 | 19 |
|---|---|---|---|---|---|----|----|
| full? | no | no | no | **yes** | yes | yes | yes |

At `p = 5` exactly one residue is missing for each `N ≠ 0`, namely `2 N^{-1}`
(`N=1 ↦ 2`, `N=2 ↦ 1`, `N=3 ↦ 4`, `N=4 ↦ 3`).  So the two-factor constraint is not a
generic "symmetric function" phenomenon: it is the quadratic discriminant, and it
dies at arity 3 once `p ≥ 11`.

Formalised (for `p = 11`, `p = 5`) as `tripleSumSet_full_eleven`,
`tripleSumSet_not_full_five`, `arity_dichotomy_eleven`.

## 5. Is the trace set a complete invariant of `N`?

`N ↦ S_p(N)` injective on `𝔽_p`:  verified `true` for
`p = 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41`.

Formalised for `p = 13` (`traceSet_injective_thirteen`); the general statement is
Conjecture C1 of `FUTURE_DIRECTIONS.md`.

## 6. OEIS

The sequence of trace-set sizes at `N = 1`, `|S_p(1)| = (p+1)/2` for odd primes
`p = 3, 5, 7, 11, 13, …` gives `2, 3, 4, 6, 7, 9, 10, 12, …`, which is the sequence
of `(p+1)/2` for odd primes (A006254-adjacent / A005097 shifted: `(p-1)/2` is
A005097).  No new sequence arises; the interesting object here is the ±1
character correction, not the size itself.
