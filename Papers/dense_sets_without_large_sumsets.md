# Computational evidence: dense sets without large sumsets

All numbers below come from small exploratory scripts (Python) and from the
explicit Lean witness `DenseSumsetFree.counting_hypotheses_satisfiable`.  Only
the latter is machine-checked; the tables are exploratory and are labelled as
such.

Notation: `S ⊆ [n] = {0, …, n-1}` *avoids `k`-sumsets* if there are no finite
`A, B ⊆ ℕ` with `|A|, |B| ≥ k` and `A + B ⊆ S` (`AvoidsSumsets S k` in Lean).

---

## 1. Small cases: `k = 2` (exhaustive search, exploratory)

Avoiding `2`-sumsets means exactly that `S` is a **Sidon set** (`B₂` set): a
sumset `{a₁,a₂} + {b₁,b₂} ⊆ S` is precisely a nontrivial additive quadruple.
Exhaustive search over all subsets of `[n]`:

| n  | max &#124;S&#124; avoiding 2-sumsets | extremal witness |
|----|------|------------------|
| 2  | 2 | {0,1} |
| 4  | 3 | {0,1,3} |
| 7  | 4 | {0,1,4,6} |
| 8  | 4 | {0,1,3,7} |
| 12 | 5 | {0,1,4,9,11} |
| 13 | 5 | {0,1,3,7,12} |
| 14 | 5 | {0,1,3,7,12} |

The values `2,2,3,3,3,4,4,4,4,4,5,5,5` for `n = 2,…,14` are the classical
maximal-Sidon-set sizes (Sidon/perfect-difference-set data, cf. OEIS A003022 for
the dual "minimal `n` admitting a Sidon set of size `k`": 1, 3, 6, 11, 17, …,
matching the jumps above at `n = 4, 7, 12`).

**Consequence.** For `k = 2` the maximal density is `Θ(n^{-1/2}) → 0`: a set of
*constant* density can never avoid `2`-sumsets.  So the threshold `k` must grow
with `n`, and the whole question is *how slowly*.

---

## 2. Where the truth lies: random sets (exploratory)

A density-`1/2` random subset of `[n]` contains long arithmetic progressions, and
an AP of length `2k-1` inside `S` immediately produces `A + B ⊆ S` with
`|A| = |B| = k` (this is the Lean theorem `not_avoidsSumsets_of_ap`).  Averages
over 5 random trials:

| n | avg. longest AP | log₂ n | implied lower bound `k ≈ AP/2` |
|---|---|---|---|
| 100 | 9.2 | 6.6 | 4.6 |
| 400 | 12.6 | 8.6 | 6.3 |
| 1600 | 16.2 | 10.6 | 8.1 |
| 6400 | 18.8 | 12.6 | 9.4 |

The longest AP grows like `≈ 1.5 log₂ n`, i.e. **no** construction of this kind
can beat `k = Θ(log n)`; that is exactly the conjectured optimal order in the
statement of the mission.  Our formal theorem gives `k = O((log n)³)`.

---

## 3. The first-moment inequality (machine-checked instance)

The counting theorem `exists_avoidsSumsets_set` needs

```
1 ≤ l,  l² ≤ m ≤ n,  q·m ≤ p·n,  n^(2l) · p^(l²) < q^(l²).
```

For `n = 1024`, `m = 512` (density `1/2`, `p/q = 1/2`), `l = 21`:

* `l² = 441 ≤ 512 = m ≤ 1024 = n`, `2·512 ≤ 1·1024`;
* `n^(2l) = 1024^42 = 2^420 < 2^441 = q^(l²)`.

This is verified inside Lean in `Bridges/DenseSumsetFree/Sharpness.lean`
(`counting_hypotheses_satisfiable`), which therefore *proves* the existence of a
512-element subset of `[1024]` avoiding all `k`-sumsets with `k = 21³ + 21 = 9282`.
(For `n = 1024` the baseline Cauchy–Davenport bound only gives avoidance for
`k ≥ 513`; the counting theorem is worth more only for much larger `n`, see §4.)

---

## 4. Asymptotic parameters of the main theorem (exploratory)

With `δ` fixed, the proof takes `q = ⌈1/(1-δ)⌉+1`, `p = q-1`,
`L = log(q/p)`, `K = 2/L + 2`, `C = 2K³`, `l ≈ 2 log n / L`, `k = l³ + l`.

| δ | p/q | L | C = 2K³ | n | l | k = l³+l | k/n |
|---|-----|---|---------|---|---|----------|-----|
| 0.5 | 2/3 | 0.405 | 666 | 10⁶ | 70 | 3.4·10⁵ | 0.34 |
| 0.5 | 2/3 | 0.405 | 666 | 10⁹ | 104 | 1.1·10⁶ | 1.1·10⁻³ |
| 0.5 | 2/3 | 0.405 | 666 | 10¹² | 138 | 2.6·10⁶ | 2.6·10⁻⁶ |
| 0.9 | 11/12 | 0.087 | 3.1·10⁴ | 10⁹ | 478 | 1.1·10⁸ | 0.11 |
| 0.9 | 11/12 | 0.087 | 3.1·10⁴ | 10¹⁸ | 954 | 8.7·10⁸ | 8.7·10⁻¹⁰ |

So the theorem beats the trivial (Cauchy–Davenport) threshold `k ≈ n/2` from about
`n ≈ 10⁷` on for `δ = 1/2`, and the ratio `k/n` then decays to `0` polylogarithmically.

---

## 5. Counterexample hunt

We searched for counterexamples to the two *statements we prove* rather than to
the conjecture:

* the greedy extraction bound (`|A|, |B| ≥ l³ + l` forces a distinct-sums pair of
  `l`-subsets) was tested on 60 instances (APs, geometric sets and random sets)
  for `l ∈ {2, 3}`; no failure.  APs show the cube cannot be replaced by anything below a
  square: in `A = B = [0, k)` a distinct-sums pair of `l`-sets needs `l² ≤ 2k`.
* the binomial ratio inequality `binom(n-s,m-s)·nˢ ≤ binom(n,m)·mˢ` was checked
  exhaustively for all `s ≤ m ≤ n ≤ 40`; no failure (it is proved in Lean).

No counterexample was found, consistent with the formal proofs.

---

## 6. Three summands (machine-checked instance)

The three-summand counting theorem `exists_avoidsSumsets3_set` needs

```
1 ≤ l,  l³ ≤ m ≤ n,  q·m ≤ p·n,  n^(3l) · p^(l³) < q^(l³).
```

For `n = 1024`, `m = 512` (density `1/2`, `p/q = 1/2`), `l = 6`:

* `l³ = 216 ≤ 512 = m ≤ 1024 = n`, `2·512 ≤ 1·1024`;
* `n^(3l) = 1024^18 = 2^180 < 2^216 = q^(l³)`.

This is verified inside Lean (`triple_counting_hypotheses_satisfiable` in
`Bridges/DenseSumsetFree/Triple.lean`) and proves the existence of a
512-element subset of `[1024]` containing no three-fold sumset `A + B + C`
with `|A|, |B|, |C| ≥ 6⁵ + 6 = 7782`.  The two-summand instance of §3 gives the
weaker threshold `9282` for the same `n` and density, which illustrates the point
of the three-summand analysis: the union bound `n^{3l}` is paid off by a *cubic*
sumset `l³` instead of a quadratic one, so a much smaller `l` suffices.

Asymptotically the three-summand parameters are `l ≈ √(3 log n / L)` and
`k = l⁵ + l`, giving the threshold `Θ((log n)^{5/2})` instead of `Θ((log n)³)`
(exploratory values of the two thresholds, ignoring constants):

| n | (log n)³ | (log n)^{5/2} | ratio |
|---|----------|---------------|-------|
| 10⁶ | 2.6·10³ | 7.1·10² | 0.27 |
| 10⁹ | 8.9·10³ | 1.9·10³ | 0.22 |
| 10¹² | 2.1·10⁴ | 4.0·10³ | 0.19 |

Both thresholds are proved in Lean; the table is only an illustration of the size
of the gain.

## 6. An arbitrary number of summands

For `t` summands and density `1/2` (`p/q = 1/2`, so `log(q/p) = log 2`) the
counting hypotheses of `exists_avoidsSumsetsN_set` read

* `l^t ≤ m ≤ n`, `q·m ≤ p·n` (density), and
* `n^{t l} < 2^{l^t}`, i.e. `t · l · log₂ n < l^t`,

and the resulting threshold is `l^{2t-1} + l`.  At `n = 1024` (`log₂ n = 10`),
`m = 512`, the smallest admissible `l` and the resulting thresholds are:

| t | smallest l with l^{t-1} > t·log₂ n | l^t ≤ 512? | threshold l^{2t-1}+l |
|---|-----------------------------------|------------|----------------------|
| 2 | 21 | yes (441) | 9282 |
| 3 | 6  | yes (216) | 7782 |
| 4 | 4  | yes (256) | 16388 |
| 5 | 3  | yes (243) | 19686 |

So at this small `n` the optimum among the proved instances is `t = 3` (and
`t = 4` is the machine-checked four-summand instance
`general_counting_hypotheses_satisfiable`, threshold `4⁷ + 4 = 16388`).  The
asymptotic picture is the opposite one: the exponent `(2t-1)/(t-1)` of `log n`
decreases in `t` (`3, 5/2, 7/3, 9/4, …`), so for each fixed `t` the larger `t`
eventually wins — but only once `log n` is large compared with `t`, since the
constant `c(t)` grows.  The `n = 1024` row is exactly the regime where the
constants still dominate.

The two rows `t = 3` and `t = 4` are verified inside Lean
(`triple_counting_hypotheses_satisfiable`,
`general_counting_hypotheses_satisfiable`); the rows `t = 2` and `t = 5` and the
"smallest `l`" column are exploratory arithmetic, not machine-checked.
