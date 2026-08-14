# Computational Evidence — De-Quantization Assessed (Shor's QFT)

All numbers below were produced by `#eval` inside Lean 4 (Mathlib v4.28.0) before
the corresponding theorems were formalized.  They are *exploratory* evidence:
the load-bearing claims are the machine-checked theorems in
`Catalog/Novelty/Shor*.lean`, which carry no `sorry`.

---

## 1. Small-case Schmidt data of the periodic comb

The comb `c_x = [x ≡ x₀ mod r]` cut into a low half of size `B` and a high half
of size `C` (`x = b + B·c`) is a fibre-matching state, so its Schmidt rank is
`#(image u ∩ image v)` with `u b = b mod r`, `v c = x₀ − B·c mod r`
(`ShorIrreducible.schmidtRank_matchMatrix`).  Evaluating that cardinality:

| r | B | C | Schmidt rank | r / gcd(r,B) |
|---|---|---|--------------|--------------|
| 5 | 8 | 8 | 5 | 5 |
| 5 | 8 | 4 | 4 | 5 |
| 6 | 8 | 8 | 3 | 3 |
| 8 | 8 | 8 | 1 | 1 |
| 9 | 16| 16| 9 | 9 |
| 12| 16| 16| 3 | 3 |
| 15| 16| 16| 15| 15 |
| 16| 16| 16| 1 | 1 |
| 7 | 32| 32| 7 | 7 |
| 12| 18| 12| 2 | 2 |

The data suggested the sharp formula `rank = min C (r / gcd(r, B))` for `r ≤ B`,
which is now the theorem `ShorIrreducible.schmidtRank_combCut_sharp`.

**Counterexample hunt.** A sweep over
`r ∈ {1,…,20}`, `B ∈ {1,…,32}`, `C ∈ {1,…,32}`, `x₀ ∈ {0,1,2,5,7}`
restricted to `r ≤ B` tested **6050 configurations** and found
**0 counterexamples** to `min C (r / gcd(r,B))`.

A first, naive guess — `min B (min C (r/gcd(r,B)))` without the hypothesis
`r ≤ B` — failed in 236 of the same configurations (e.g. `r = 12, B = 8,
C = 16`: true rank `2`, guess `3`), which is why the sharp theorem carries the
hypothesis `r ≤ B`.

---

## 2. Orders and the classical post-processing

Orders `r = ord_N(a)` computed by search:

| a | N | r | gcd(a^{r/2} − 1, N) | gcd(a^{r/2} + 1, N) |
|---|---|---|---------------------|---------------------|
| 7 | 15 | 4 | 3 | 5 |
| 2 | 21 | 6 | 7 | 3 |
| 2 | 35 | 12 | 7 | 5 |
| 7 | 143 | 60 | 11 | 13 |

Every listed case has `r` even and `a^{r/2} ≢ −1`, and `gcd(a^{r/2} − 1, N)` is a
nontrivial divisor — the hypothesis pattern of
`ShorIrreducible.exists_factor_of_orderOf_even`.  The reduction is also witnessed
non-vacuously inside Lean by a `decide`-checked example (`4² ≡ 1 mod 15`,
`4 ≠ ±1`, `gcd(3,15) = 3`).

Note the entanglement consequence: for `N = 143`, `a = 7` the order is `r = 60`,
so the Shor state has Schmidt rank exactly `60` and entanglement entropy
`log 60 ≈ 4.09` nats across the register cut — already above what a
bond-dimension-`32` MPS can carry, at `N` with 8 bits.

---

## 3. Structure of the QFT output

For `Q = r·m` the Fourier transform of the comb is supported exactly on the
multiples of `m`, of which there are `r` in `[0, Q)`; each surviving amplitude
has modulus `m`.  This was checked symbolically rather than numerically (complex
exponentials are not `#eval`-able) and is now the theorem
`ShorIrreducible.combDFT_eq` together with `ShorIrreducible.norm_combDFT`; the
counting statement `#{y < r·m : m ∣ y} = r` is
`ShorIrreducible.card_multiples_range`.

---

## 4. OEIS

No new integer sequence arises: the quantities that appear
(`r/gcd(r,B)`, `φ(r)`, the number of multiples of `m` below `r·m`) are standard
arithmetic functions, so no OEIS lookup is reported.

---

## 5. Truncation fidelity: `D/r`, not `(D/r)²`

Take the flat rank-`r` state `M = r^{-1/2} · Iᵣ` (the Schmidt-basis picture of the
comb and of the full Shor state, both proved flat here) and the best
bond-dimension-`D` approximant `A = D^{-1/2} · diag(1,…,1,0,…,0)` with `D` ones.
Then

| `r` | `D` | `⟪M,A⟫` | fidelity `|⟪M,A⟫|²` | paper's `(D/r)²` |
|----|----|--------|--------------------|------------------|
| 8  | 1  | `0.3536` | `0.1250` | `0.0156` |
| 8  | 2  | `0.5000` | `0.2500` | `0.0625` |
| 8  | 4  | `0.7071` | `0.5000` | `0.2500` |
| 60 | 8  | `0.3651` | `0.1333` | `0.0178` |

`⟪M,A⟫ = D/(√r·√D) = √(D/r)`, hence fidelity `= D/r` exactly.  The measured
values match `D/r` and not `(D/r)²`; the discrepancy is the reason the formal
statement `fidelity_flat_le` (with matching case `fidelity_flat_truncation_eq`)
uses `D/r`.  The conclusion of the source paper is unaffected: at polynomial `D`
and exponential `r` the fidelity is still exponentially small.

---

## 6. Aligned cuts: an exhaustive rank scan

Ranks were computed exactly over `ℚ` by Gaussian elimination for the `0/1`
support matrices `M_{b,c} = [b + B·c ≡ x₀ (mod r)]` (QFT input) and
`[m ∣ b + B·c]` (QFT output; the phases are unimodular diagonal factors and do
not change the rank).

* Sharp formula scan: all `r ≤ 12`, `r ≤ B ≤ 16`, `1 ≤ C ≤ 16`, `0 ≤ x₀ < r`
  — **10816 configurations, 0 mismatches** with `min(C, r/gcd(r,B))`
  (`schmidtRank_combCut_sharp`).
* Aligned cut: `r = m = 6`, `B = C = 6` gives input rank `1` **and** output rank
  `1`.  This is the counterexample formalized as `not_complementary_ranks`.
* Power-of-two cuts of odd orders: `(r,B) ∈ {(3,4),(3,8),(3,16),(5,8),(5,16),
  (7,8),(7,16),(9,16),(15,16)}` with `C = 16` all attain the full rank
  `min(C,r) = r` — matching `schmidtRank_combCut_pow_two_of_odd`, so the
  collapse above is unreachable for odd orders.
