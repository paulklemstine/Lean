# Computational Evidence — Erdős–Graham / exact Egyptian coverings

All numerical exploration below was carried out with exact rational arithmetic before
formalisation.  Every claim that ended up in the Lean files is proved there; the numbers
in this note are exploratory data, not verified statements, unless the corresponding Lean
theorem is named.

## 1. Small cases: cardinality spectrum

Exact coverings `1 = ∑_{n ∈ S} 1/n` with distinct `n ≥ 2`:

| `|S|` | exists? | example |
|---|---|---|
| 1 | no  | `1/n = 1` forces `n = 1` |
| 2 | no  | best possible is `1/2 + 1/3 = 5/6 < 1` |
| 3 | yes, unique | `{2, 3, 6}` |
| 4 | yes | `{2, 4, 6, 12}`, `{2, 3, 10, 15}`, `{2, 3, 8, 24}`, `{2, 4, 5, 20}`, `{3, 4, 5, 6}`… |
| 5 | yes | `{2, 4, 6, 12}` split at the maximum: `{2, 4, 6, 13, 156}` |
| ≥3 | yes | splitting operator `1/m = 1/(m+1) + 1/(m(m+1))` |

Formalised as `ErdosGraham.egyptian_card_spectrum` (spectrum = `{k ≥ 3}`) and
`ErdosGraham.egyptian_card_three_unique` (uniqueness of `{2,3,6}`).

## 2. Egyptian-free sets: counterexample hunt for "divergence suffices"

Conjecture tested: *a set of integers `≥ 2` with divergent reciprocal sum contains a
finite subset of reciprocal sum `1`.*

Counterexample found immediately: the **primes**.  If `p₁ < … < p_k` are primes with
`∑ 1/p_i = 1`, clearing denominators gives `p₁ ∣ p₂⋯p_k`, impossible.  Numerically, greedy
and exhaustive searches over the primes below `10^4` find no subset summing to `1`
(consistent with the proof).  The same holds for **prime powers**.
Formalised as `ErdosGraham.divergence_not_sufficient`.

## 3. Egyptian coverings avoiding all prime powers

Search over the non-prime-powers: no covering exists with `≤ 12` terms and denominators
`< 200` (exhaustive depth-first search with reciprocal-mass pruning); the reciprocal mass
of the non-prime-powers below `40` is only `≈ 0.83`, so at least `14` terms are needed.

Restricting to the divisors of highly composite numbers and minimising the number of terms
by 0/1-knapsack over the complementary divisors gives:

| `N` | minimal number of non-prime-power divisors of `N` summing to `N` |
|---|---|
| 2520 | 26 |
| 5040 | 24 |
| 27720 | 21 |
| 55440 | 21 |

The `27720` solution
`{6,10,12,14,15,18,20,21,22,24,28,30,33,36,40,42,44,45,55,60,63}`
has reciprocal sum exactly `1`; this is the witness formalised in
`ErdosGraham.egyptian_avoiding_primePowers` (21 terms; not claimed to be minimal).

## 3b. Egyptian coverings with large minimum

Minimising the number of terms among divisors `≥ K` of a smooth `N` (0/1 knapsack on the
complementary divisors):

| `K` | `N` | terms | witness |
|---|---|---|---|
| 10 | 55440 | 23 | `{10,11,12,14,15,16,18,20,21,22,24,28,30,33,36,40,42,45,48,55,60,63,66}` |
| 16 | 110880 | 88 | (see script output) |
| 20 | 720720 | 82 | (see script output) |

The `K = 10` witness is formalised as `ErdosGraham.exists_egyptian_min_ge_ten`.  The
pattern suggests (but does not prove) that coverings exist with arbitrarily large minimum;
see conjecture C1 in `FUTURE_DIRECTIONS.md`.

## 4. Two obstructions, and neither is complete

* Local (`p`-adic): if the maximal power of a prime `p` among the denominators is attained
  once, no exact covering exists (`egyptianFree_of_padicSeparated`).
* Global (mass): a deficient number has an Egyptian-free divisor set
  (`egyptianFree_divisors_of_deficient`).

Scanning `N ≤ 200`, the divisor sets which are Egyptian-free but *not* explained by the
local criterion are exactly the divisor sets of the deficient numbers together with
`N = 70` (and its analogues `836`, …) — the **weird** numbers, abundant yet not
pseudoperfect.  `70` is therefore the smallest witness that the local criterion is not
necessary; formalised as `ErdosGraham.padicSeparated_not_necessary`, using Mathlib's
verified `Nat.weird_seventy`.

## 5. Divisor-sum shadow (OEIS pointers)

Under the duality `d ↦ N/d` (`pseudoperfect_iff_exists_egyptian_dvd`), Egyptian coverings
inside the divisor lattice of `N` correspond to pseudoperfect representations of `N`.
The relevant classical sequences are the pseudoperfect/semiperfect numbers
(OEIS **A005835**: 6, 12, 18, 20, 24, 28, 30, …), the weird numbers
(OEIS **A006037**: 70, 836, 4030, …), and the deficient numbers (OEIS **A005100**).
The first terms were re-derived by direct computation and agree with these listings.
