# Computational Evidence — "Kneser input for many lines"

**Target statement.** Let `v_1,…,v_k` be pairwise independent directions in `𝔽_p²`
and `S_i ⊆ 𝔽_p` with `0 ∈ S_i`. Write `d_i = p − |S_i|` (the *deficiency*) and
`Reach = Σ_i S_i v_i`. The conjecture under investigation:

> `Σ_i d_i ≤ (k−2)(p−1)  ⟹  Reach = 𝔽_p²`.

All computations below were carried out by brute-force enumeration over
`𝔽_p²` (directions normalised to the projective line `{(1,a) : a ∈ 𝔽_p} ∪ {(0,1)}`,
which is legitimate because rescaling `v_i ↦ c v_i` is absorbed by `S_i ↦ c^{-1}S_i`
and preserves both `0 ∈ S_i` and `|S_i|`).

> Status note: the tables in this file are *exploratory* enumeration, not machine-checked
> statements. Everything that is asserted as a theorem has been formalised separately in
> `Catalog/Computation/KneserManyLines*.lean` and builds with 0 sorries; the tables merely
> record how those statements were found and how far the remaining conjectures were tested.

---

## 1. Minimum deficiency of a failing configuration

For each `(p,k)` we searched for the smallest value of `Σ_i d_i` admitting a
configuration with `Reach ≠ 𝔽_p²`.

| p | k | search | min failing `Σ d_i` | `(k−2)(p−1)` |
|---|---|--------|---------------------|--------------|
| 3 | 4 | exhaustive | **4** | 4 |
| 5 | 4 | exhaustive | **8** | 8 |
| 5 | 5 | randomised | 12 (found) | 12 |
| 5 | 6 | randomised | 16 (found) | 16 |
| 7 | 4 | randomised | 12 (found) | 12 |
| 7 | 5 | randomised | 18 (found) | 18 |

The two exhaustive rows are decisive: **the conjecture is false, and it is false
exactly at the boundary** — no configuration with `Σ_i d_i ≤ (k−2)(p−1) − 1`
fails, while configurations with `Σ_i d_i = (k−2)(p−1)` do.

(For `p ≥ 7` naive uniform random sampling rarely lands on extremal
configurations, so the randomised rows only give upper bounds; the explicit
family of §2 supplies the matching constructions.)

---

## 2. The harmonic family — explicit counterexamples for all `p, k`

Directions (index `0,1,2,3`): `(1,0), (0,1), (1,1), (−1,1)`; remaining indices
`j ≥ 4` get slope `j−2`. Sets: `S_0 = S_1 = 𝔽_p \ {1}`, `S_2 = S_3 = {0,1}`,
`S_j = {0}` for `j ≥ 4`. Missing point: `(1,2)`.

| p | k range tested | `Σ d_i` | `(k−2)(p−1)` | `|Reach|` | `(1,2) ∈ Reach`? |
|---|----------------|---------|--------------|-----------|-------------------|
| 3 | 4              | matches | matches      | `p²−1`    | no |
| 5 | 4 … 6          | matches | matches      | `p²−1`    | no |
| 7 | 4 … 8          | matches | matches      | `p²−1`    | no |
| 11 | 4 … 12        | matches | matches      | `p²−1`    | no |
| 13 | 4 … 14        | matches | matches      | `p²−1`    | no |
| 17 | 4 … 18        | matches | matches      | `p²−1`    | no |

Every instance is pairwise independent, has `Σ_i d_i = (k−2)(p−1)` exactly, and
misses **exactly one** point of `𝔽_p²`. This family is what is formalised as
`KneserLines.counterexample_many_lines` (all `4 ≤ k ≤ p+1`, all primes `p ≥ 3`);
`k ≤ p+1` is not a restriction of the method but the full range in which a
pairwise independent `k`-family exists at all.

---

## 3. Which criterion is actually correct?

The best proved positive criterion is the *triple criterion*
(`KneserLines.reach_eq_univ_of_triple`):

> if **some** three distinct indices satisfy `d_i + d_j + d_l < p`, then `Reach = 𝔽_p²`,

equivalently: the three smallest deficiencies sum to less than `p`. Every member
of the harmonic family has three-smallest-sum exactly `p` (`1 + 1 + (p−2)`), so
the criterion is *exactly* sharp — this is
`KneserLines.triple_criterion_sharp`.

**Is "three smallest `≥ p`" also sufficient for a failure to exist?** No. We
enumerated, for every deficiency profile `(d_1,…,d_4)`, whether *some*
configuration with that profile fails.

*p = 3, k = 4*: prediction and reality agree on all `35` profiles.

*p = 5, k = 4*: three exceptional profiles have three-smallest-sum `≥ 5` but
admit **no** failing configuration:

| profile | `Σ d_i` | three smallest | failing config exists? |
|---------|---------|----------------|------------------------|
| `(0,2,3,3)` | 8 | 5 | **no** (explained by `reach_eq_univ_of_exists_full`, since `Σ d_i = 8 ≤ (k−2)(p−1)`) |
| `(1,2,2,2)` | 7 | 5 | **no** |
| `(2,2,2,2)` | 8 | 6 | **no** |

all other profiles with three-smallest `≥ 5` do admit a failing configuration.

*p = 7, k = 4* (spot checks, exhaustive within the profile after normalising the
first three directions to `(1,0),(0,1),(1,1)`):

| profile | three smallest | max `d_i` | failing config exists? |
|---------|----------------|-----------|------------------------|
| `(1,1,5,5)` | 7 | 5 | yes (harmonic) |
| `(1,3,3,4)` | 7 | 4 | **no** |
| `(3,3,3,3)` | 9 | 3 | yes |
| `(2,4,4,4)` | 10 | 4 | yes |
| `(4,4,4,4)` | 12 | 4 | yes |

The `p = 7` data kills the natural refinement "a failure needs some
`d_i ≥ p−2`" (`(3,3,3,3)` fails with `max d_i = 3 < 5`), and `(1,3,3,4)` shows
that three-smallest `= p` is not enough. **The exact characterisation of the
failing profiles is open** and is the first entry of `FUTURE_DIRECTIONS.md`.

---

## 4. OEIS

No integer sequence naturally attaches to this problem: the quantities involved
(`(k−2)(p−1)`, `p²−1`) are elementary polynomials in `p` and `k`, and the list
of exceptional profiles is a set of tuples rather than a sequence. No OEIS
lookup was performed.
