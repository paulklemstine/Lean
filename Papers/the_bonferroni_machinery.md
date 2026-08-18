# Computational evidence — the Bonferroni machinery and its marginals

All numbers below were computed inside Lean (`#eval` in
`Catalog/MachineLearning/BonferroniMarginals/LabNotes.lean`) and every claim
that is used mathematically has been re-checked as a machine-verified
`example`/`theorem` in the same directory.  Nothing here is an unchecked
scratch computation.

## 1. Small-case calculations

Notation: `d(x) = mult I A x` is the coverage multiplicity, `N = |cover|`,
`S = ∑ᵢ|Aᵢ|`, `P₂ = ∑_{(i,j) ∈ offDiag}|Aᵢ ∩ Aⱼ|`,
`D = doubleCollision`, `gap = N·∑ₓd(x)² − S²`.

### Three 2-element sets in a 4-point space

| family    | `S` | `P₂` | `N` | `d`-profile | `2|D|` | Bonferroni defect `∑(d−1)²` | sharp defect `∑(d−1)(d−2)` | `gap` |
|-----------|-----|------|-----|-------------|--------|------------------------------|-----------------------------|-------|
| triangle `{01},{12},{20}`   | 6 | 6 | 3 | (2,2,2)   | 6 | 3 | 0 | 0  |
| sunflower `{01},{02},{03}`  | 6 | 6 | 4 | (3,1,1,1) | 2 | 4 | 2 | 12 |

Both families have **identical** first marginals (`2,2,2`) and **identical**
second marginals (`1` off the diagonal), but different unions (`3` vs `4`).
This is the measurement behind `union_not_determined_by_second_order_marginals`
and `no_second_order_formula`.

Checks performed on this data:

* second Bonferroni `S ≤ N + P₂`: `6 ≤ 3+6` and `6 ≤ 4+6`;
* sharp Bonferroni `2S ≤ 2N + P₂`: `12 = 12` (tight, triangle) and `12 ≤ 14`
  (slack `2`, sunflower);
* double collision `2|D| ≤ P₂`: `6 = 6` (tight) and `2 ≤ 6` (slack `4`);
* Corrádi with `(k,m,t) = (3,2,1)`: `k·m² = 12 ≤ N·(m+(k−1)t)`, i.e. `12 = 12`
  (triangle, tight) and `12 < 16` (sunflower);
* Cauchy–Schwarz gap `0` vs `12`, matching `cauchySchwarz_tight_iff_regular`
  (the triangle is a regular cover of multiplicity `2`, the sunflower is not).

### A four-set family `quad ⊆ Fin 8`

`quad = {0,1,2}, {2,3,4}, {4,5,0}, {0,2,4}`; measured `d`-profile `(3,1,3,1,3,1)`,
`N = 6`, `S = 12`, `P₂ = 18`, `2|D| = 6`, `gap = 36`, Bonferroni defect `12`,
sharp defect `6`.  All identities of `Rigidity.lean` and `SharpBonferroni.lean`
were re-verified on this instance by `decide`.

### The parity construction (`plainFam k` vs `parityFam k`)

| `k` | `|cover plain|` | `|cover parity|` | top-order marginal (plain / parity) |
|-----|-----------------|------------------|--------------------------------------|
| 1   | 1               | 2                | 1 / 2                                |
| 2   | 3               | 2                | 1 / 2                                |
| 3   | 7               | 8                | 1 / 2                                |

For `k = 2` all marginals of order `< 2` were checked equal by `decide`
(`T = ∅, {0}, {1}`), while the unions differ (`3 ≠ 2`).  The general statement
is `marginal_order_lt_insufficient`.

## 2. Sequence search

The measured union sizes of the parity construction are
`|cover plain k| = 2^k − 1` (1, 3, 7, 15, …, the Mersenne numbers, OEIS A000225)
and `|cover parity k| = 2^k − 2·[k even]` (2, 2, 8, 14, …).  The proof does not
use the second closed form: only the parity of the two numbers is needed
(`card_cover_ne`), which is why no sequence identification is required.

## 3. Counterexample hunt

The universal claim tested was:

> *the first- and second-order marginals of a finite family determine the size
> of its union.*

Exhaustively searching families of three `2`-element subsets of a `4`-element
set immediately produces the triangle/sunflower pair as a counterexample; it is
minimal in the sense that for two sets the marginals `|A₁|, |A₂|, |A₁∩A₂|` do
determine `|A₁ ∪ A₂|`.  The counterexample was then generalised: for every
`k ≥ 1` the pair `plainFam k` / `parityFam k` refutes the analogous claim for
marginals of every order `< k`.

## 4. What the data suggested, and what was then proved

* triangle gap `0`, sunflower gap `12` ⇒ conjecture "gap `= 0` iff regular
  cover", proved as `cauchySchwarz_tight_iff_regular` and quantified as
  `sq_spread_le_gap`;
* the sharp-Bonferroni and double-collision slacks vanish together on the
  triangle and are both positive on the sunflower and on `quad` ⇒ conjecture
  "same extremal class", proved as
  `sharp_bonferroni_and_doubleCollision_same_extremals`;
* the parity of `|cover plain k|` and `|cover parity k|` always differed in the
  measured range ⇒ proved in general via `card_cover_ne`.
