# Computational evidence

All statements marked **[Lean]** are machine-checked in `Catalog/Algebra/Heisenberg125/`.
Statements marked **[exploratory]** come from ad-hoc scripts run during the
investigation; they are *not* formally verified and are recorded here only as
evidence that guided the formalisation.

Throughout, `H_{p^3} = {(a,b,c) ∈ (Z/p)^3}` with
`(a,b,c)·(a',b',c') = (a+a', b+b', c+c'+ab')`, and
`d(G)` is the small Davenport constant (maximal length of a product-one-free
sequence).

## 1. Exhaustive small cases

An exhaustive depth-first search over multisets in canonical (non-decreasing)
order, pruned by the hereditary property "every subsequence of a
product-one-free sequence is product-one-free", and using a subset-DP over all
orderings of every subsequence:

| group | order | exhaustive `d(G)` | `3p-3` | longest witness found |
|---|---|---|---|---|
| `Heis 2` (order 8, exponent 4) | 8 | **4** | 3 | `y·(xy)^3` |
| `Heis 3` = `H_27` | 27 | **6** | 6 | `x²y²v²` |
| `Heis 5` = `H_125` | 125 | search infeasible | 12 | `x⁴y⁴v⁴` (length 12) |

*(search sizes: `p = 2`: 68 nodes, <0.1 s; `p = 3`: 69 053 nodes, 22 s)* **[exploratory]**

* `d(H_27) = 6 = 3·3-3` reproduces the theorem of Godara and Sarkar.
* `d(Heis 2) = 4 > 3 = 3·2-3`: the formula genuinely fails at the even prime.
  The lower bound half of this, `d(Heis 2) ≥ 4` with the explicit witness
  `y·(xy)^3`, is **[Lean]** (`Heis.four_le_smallDavenport_heis_two`); it is what
  makes the oddness hypothesis in all our theorems visible rather than cosmetic.

## 2. The case `p = 5`

* `x⁴y⁴v⁴` is product-one-free **[Lean]** (`Heis.productOneFree_extremalSeq`,
  general `p`), reconfirmed by direct enumeration **[exploratory]**.
* None of the `125` one-element extensions of `x⁴y⁴v⁴` stays product-one-free
  **[exploratory]**: the extremal sequence is *maximal*, consistent with
  `d(H_125) = 12`.
* Randomised greedy search (370 independent trials, random element orders):
  the longest product-one-free sequence ever produced has length **12**; a
  typical extremal witness found is
  `(1,2,0)⁴ (1,0,0)⁴ (0,0,3)⁴`, again of the shape `g^{p-1} h^{p-1} v^{p-1}`
  with `g, h` of independent directions. **[exploratory]**

No length-13 product-one-free sequence was ever produced; this is consistent
with (but of course does not prove) the paper's `d(H_125) = 12`.

## 3. Direction-class profiles (why our upper bound loses)

Our first proved upper bound decomposes a sequence along the `p+1 = 6`
directions of `P^1(F_5)` and caps each class at `2p-2 = 8`, giving `48`.  The
class-size data below is what motivated the two sharpenings that were
subsequently proved: at most `p-1 = 4` classes can reach size `≥ p = 5`
(giving `40`), and the two-phase extraction of disjoint central blocks
(giving `34`).  For the long
(length ≥ 11) product-one-free sequences produced by random search, the observed
multisets of class sizes are **[exploratory]**

```
(8,4) : 69 samples      (4,4,4) : 10      (5,4,1,1) : 3      (6,4,1) : 1      (4,4,2,1) : 1
```

Two conclusions:

* the per-class bound `2p-2 = 8` **is attained inside globally extremal
  sequences** (profile `(8,4)`), so no improvement of the per-class bound alone
  can close the gap — this matches the **[Lean]** sharpness statement
  `Heis.productOneFree_cosetExtremalSeq` (`x^{p-1}(xv)^{p-1}`, length `2p-2`, in
  one coset of the centre, hence in one direction class);
* the loss is entirely in the *summation over classes*: at most one class ever
  exceeds `p-1 = 4` entries.  This is the phenomenon that the paper's exhaustive
  search resolves, and it is the source of Conjecture 1 in
  `FUTURE_DIRECTIONS.md`.

## 4. Spread of the achievable central values

For a subsequence `T` whose image in `F_5^2` sums to zero, the product over a
reordering is always central, and the *achievable set* is
`S(T) = { Σ c_i + Σ_{i<j} a_{σ(i)} b_{σ(j)} : σ }` ⊆ `F_5`; `T` is product-one
iff `0 ∈ S(T)`.  Sampling random zero-image multisets **[exploratory]**:

| `|T|` | min `|S(T)|` | max `|S(T)|` | mean | samples |
|---|---|---|---|---|---|
| 2 | 1 | 1 | 1.00 | 15 |
| 3 | 1 | 2 | 1.71 | 7 |
| 4 | 1 | 5 | 3.64 | 14 |
| 5 | 1 | 5 | 4.25 | 12 |
| 6 | 5 | 5 | 5.00 | 12 |
| 7 | 5 | 5 | 5.00 | 8 |

So the "spread" `|S(T)|` saturates at `p` once `|T| ≳ 6 = p+1` in the sampled
range, which is exactly the mechanism the paper isolates as a finite
"spread bound on quotient multisets".  Note the persistent small cases: even at
`|T| = 5` some multisets have `|S(T)| = 1`, i.e. the reordering freedom can be
completely trivial — these are the configurations that make the upper bound
hard.

## 5. OEIS

The conjectural sequence `d(H_{p^3}) = 3p-3` over primes `p = 3, 5, 7, …`
gives `6, 12, 18, …`, i.e. multiples of `6`; no dedicated OEIS entry for the
small Davenport constants of the Heisenberg groups was located, and we make no
claim about one.

## 6. Reach of zero-sum multisets over `F_5²` (exploratory)

For a multiset `T` of *non-zero* vectors in `F_5²` with `Σ T = 0`, define its
**reach** as the set of cross-sums `Σ_{i<j} a_{σ(i)} b_{σ(j)}` obtained from all
orderings `σ`.  By the product formula `Heis.prod_eq`, if the reach is all of
`F_5` then *any* lift of `T` to `Heis 5` (i.e. any choice of central
coordinates) has a product-one ordering.  Exhaustive enumeration over all
zero-sum multisets spanning two dimensions **[exploratory]**:

| size | configurations examined | full reach | exceptions |
|---|---|---|---|
| 6 | 18 900 | 18 900 | 0 |
| 7 | 81 048 | 81 048 | 0 |
| 8 | 312 951 | 312 951 | 0 |

At size `≤ 5` exceptions do occur; all the exceptional shapes we recorded are
degenerate, of the form `(w,w,w,x,y)`.  This dichotomy is the mechanism behind
the formalised criterion `Heis.isProductOne_of_parallel_spread`, which proves
the *special case* where the multiset contains `p-1 = 4` parallel entries and a
transversal pivot.

Greedy and randomised searches for the longest multiset containing **no**
full-reach zero-sum sub-multiset produced lengths around `21`; restricted to the
provable "`p-1` parallel entries + transversal pivot" criterion the searches
reach about `20`.  Hence the criterion alone cannot reach the paper's value
`12`, which is consistent with our search-free upper bound stalling at `28`.
**[exploratory]**

## 7. The counting optimum behind the bound `28`

The final bound `d(H_{p^3}) ≤ p²+2p-7` is the optimum of a small integer
program over the class-size profile `(n_d)_{d ∈ P^1(F_p)}` and the number `c` of
central entries, under the machine-checked constraints

* `n_d ≤ 2p-2` (per-class Erdős–Ginzburg–Ziv) and `c ≤ p-1`;
* at most three classes have `n_d ≥ p-1`, and if exactly three do then all other
  classes are empty (four-class exclusion);
* `n_d = 2p-2` forces `n_e ≤ p-1` for `e ≠ d` (heavy pair), and additionally all
  remaining classes empty as soon as some `n_e ≥ p-1` (heavy triple);
* `#{d : n_d ≥ p} + c ≤ p-1` (block count).

At `p = 5` the optimum `28` is attained only by the profile `(7,7,3,3,3,3)`
with `c = 2`.  Adding the *plane* blocks of `SpreadBound.lean` (one nonempty
central block per `2p-1 = 9` remaining entries) to the same program lowers the
optimum to `27`, attained only by `(7,7,3,3,3,3)` with `c = 1`; that refinement
is now formalised as well (`MixedBound.lean`,
`Heisenberg125.smallDavenport_heis_five_le_27`), so the final machine-checked
statement is `12 ≤ d(H_125) ≤ 27`.  In the `27` configuration all `p-1 = 4`
available blocks (two line blocks, one plane block, one central entry) are used,
so a further improvement needs a genuinely new exclusion rather than better
book-keeping.
**[the individual constraints and the resulting bound are [Lean]; the integer
program itself was analysed by hand, and its conclusion is exactly what the
Lean proof of `length_le_27_heis_five` re-derives]**

## 8. The counting optima behind the bounds `23` and `20`

The same integer program was re-run after two further exclusions were proved.
It is convenient to state it in *level form*: for a product-one-free `L` put
`s_k = #{d ∈ P^1(F_5) : |C_d| ≥ k}` and let `c` be the number of central
entries.  The layer-cake identity gives `|L| = c + s_1 + s_2 + ⋯ + s_8`
(each class has at most `2p-2 = 8` entries), the crude constraints are
`s_1 ≤ p+1 = 6`, `s_1 ≥ s_2 ≥ ⋯ ≥ s_8` and `c ≤ p-1 = 4`, and the mixed block
count reads `s_5 + c + ⌊(|L| - 5s_5 - c)/9⌋ ≤ 4`.

**(a) Two auxiliary classes (`Heis.spread_exclusion`, bound `23`).**  The
quantitative criterion `(p-1-n_2)+(p-1-n_3)+1 < min p (n_1-(p-1)+1)` yields at
`p = 5` the exclusions `(5;4,4)`, `(6;4,3)`, `(7;3,3)`, `(7;4,2)`, `(8;3,2)`,
i.e. in level form
`s_5≥1 → s_4≤2`, `s_6≥1 ∧ s_4≥2 → s_3≤2`, `s_7≥1 → s_3≤2`,
`s_7≥1 ∧ s_4≥2 → s_2≤2`, `s_8≥1 ∧ s_3≥2 → s_2≤2`.  A brute-force scan over all
level vectors gives optimum `23`, attained by `s = (6,6,6,1,1,1,0,0)`, `c = 2`
— i.e. one class of `6` and five classes of `3`, plus two central entries.
This is the content of `Heisenberg125.smallDavenport_heis_five_le_23`.
**[the constraints and the bound are [Lean]; the scan is [exploratory] and only
told us which instances to formalise]**

**(b) Three auxiliary classes (`Heis.spread_exclusion4`, bound `20`).**  With
three auxiliary classes the completion of the image has one free parameter, so
the criterion weakens to
`(p-1-n_2)+(p-1-n_3)+(p-1-n_4)+2 < p + min 2 (n_1-(p-1)+1)`.  At `p = 5` the
new instances are `(4;3,3,3)`, `(4;4,3,2)`, `(5;3,3,2)`, `(5;4,2,2)`,
`(5;4,3,1)`, in level form
`s_4≥1 → s_3≤3`, `s_4≥2 ∧ s_3≥3 → s_2≤3`, `s_5≥1 ∧ s_3≥3 → s_2≤3`,
`s_5≥1 ∧ s_4≥2 → s_2≤3`, `s_5≥1 ∧ s_4≥2 ∧ s_3≥3 → s_1≤3`.  The optimum drops
to `20` (`Heisenberg125.smallDavenport_heis_five_le_20`).

**(c) What survives at `20`.**  Scanning class-size profiles rather than level
vectors, exactly five profiles reach `20`:

```
(8,2,2,2,2,2) + 2 central      (7,7,1,1,1,1) + 2      (7,3,2,2,2,2) + 2
(3,3,3,3,3,3) + 2              (3,3,3,3,3,2) + 3
```

**[exploratory]**  The profile `(3,3,3,3,3,3)` is out of reach of the whole
parallel-spread machinery: that criterion needs `p-1 = 4` pairwise commuting
entries, i.e. a class of size `≥ 4`, and here every class has `3`.  This is the
precise point at which a new idea (a genuine additive-combinatorics input such
as a Kneser/DeVos–Goddyn–Mohar bound for sumsets of several lines, or a plane
block count better than `2p-1 = 9` for structured sequences) is required.
