# The Markov Basis of the Two-Way Independence Model: A Self-Contained Distance-Reduction Proof of Fiber Connectivity

## Abstract

We give a complete, elementary, and constructive proof that the family of basic
`2 × 2` swap moves forms a Markov basis for the two-way independence model on
integer contingency tables. Concretely, we show that any two non-negative integer
`m × n` tables with identical row and column margins are connected by a finite
walk of `2 × 2` swaps that remains non-negative at every step. This is the
independence-model instance of the Fundamental Theorem of Markov Bases of
Diaconis and Sturmfels. Our argument is organized around an integer-valued
potential function — the `ℓ¹` distance between tables — and a three-stage
pigeonhole lemma that, for any non-target table, locates a `2 × 2` configuration
whose swap strictly decreases the potential while preserving non-negativity. We
also establish reversibility of the step relation, so that fibers are precisely
the equivalence classes of the connectivity relation. All results have been
formalized and machine-checked. The development is deliberately minimal in its
dependencies: it uses only finite sums, absolute values, and the
reflexive–transitive closure of a binary relation, making it a clean foundation
for the algebraic-statistics theory of log-linear models and for the design of
provably irreducible Markov chain Monte Carlo samplers on contingency tables.

**Keywords.** Markov basis, algebraic statistics, contingency table, independence
model, Diaconis–Sturmfels theorem, MCMC, toric ideal, fiber connectivity,
potential function, distance reduction.

## 1. Introduction

### 1.1 Motivation

A *two-way contingency table* is a rectangular array of non-negative integer
counts cross-classifying a sample of individuals by two categorical variables.
Testing whether the two variables are independent — the most basic question in
categorical data analysis — leads, via the theory of exact conditional inference,
to the problem of sampling uniformly (or according to a hypergeometric
distribution) from the set of all tables sharing the observed row and column
totals. This set, the *fiber* of the table under the margin map, is generally far
too large to enumerate, so one resorts to Markov chain Monte Carlo: a random walk
that proposes small, margin-preserving perturbations.

For such a walk to yield valid inference it must be *irreducible* on the fiber:
every table must be reachable from every other using only the allowed moves and
without ever leaving the non-negative orthant. The set of moves guaranteeing this
is a *Markov basis*. The foundational theorem of Diaconis and Sturmfels (1998)
identifies Markov bases with generating sets of an associated toric ideal,
opening the field now known as algebraic statistics.

### 1.2 Contribution

This paper isolates the simplest and most important instance — the independence
model — and gives a fully elementary, constructive, and formally verified proof
that the basic `2 × 2` swap moves form a Markov basis. The novelty here is not
the theorem (which is classical) but the *packaging*: a self-contained
distance-reduction argument that

1. depends on no algebraic-geometry machinery (no toric ideals, no Gröbner
   bases) — only finite sums and a potential function;
2. is constructive, yielding an explicit greedy algorithm for connecting two
   tables; and
3. is verified end-to-end, with every lemma machine-checked, providing a
   trustworthy nucleus on which richer log-linear-model theory can be built.

### 1.3 Outline

Section 2 fixes notation and defines tables, margins, the basic move, fibers, the
step relation, and the `ℓ¹` potential. Section 3 proves margin invariance.
Section 4 proves the faithfulness of the potential. Section 5 establishes the
sign-pattern pigeonhole. Section 6 proves the distance-decrease and
single-step-existence lemmas. Section 7 assembles the connectivity theorem by
strong induction. Section 8 proves reversibility and the equivalence-relation
structure of fibers. Section 9 discusses an explicit algorithm and complexity.
Section 10 surveys applications, and Section 11 lists future directions.

## 2. Definitions and Notation

Throughout, fix natural numbers `m, n`. Rows are indexed by `Fin m` and columns
by `Fin n`. We write `∑_i` and `∑_j` for sums over all rows and all columns,
respectively.

**Definition 2.1 (Table).** An `m × n` *integer contingency table* is a function
`u : Fin m → Fin n → ℤ`. We write `u i j` for the entry in row `i`, column `j`.

**Definition 2.2 (Margins).** The *row margin* of `u` at row `i` and the *column
margin* at column `j` are
```
rowSum u i = ∑_j u i j,     colSum u j = ∑_i u i j.
```

**Definition 2.3 (Same margins).** Tables `u, v` *have the same margins*, written
`SameMargins u v`, iff `rowSum u i = rowSum v i` for all `i` and
`colSum u j = colSum v j` for all `j`.

**Definition 2.4 (Non-negativity).** `u` is *non-negative*, written `Nonneg u`,
iff `0 ≤ u i j` for all `i, j`. A *fiber* of the independence model is a maximal
set of non-negative tables with a common collection of margins.

**Definition 2.5 (Basic `2 × 2` move).** For rows `i, i'` and columns `j, j'`,
the *basic move* `B(i,i',j,j') : Fin m → Fin n → ℤ` is
```
B(i,i',j,j') a b = [a=i ∧ b=j'] + [a=i' ∧ b=j] − [a=i ∧ b=j] − [a=i' ∧ b=j'],
```
where `[·]` is the indicator (`1` if true, `0` otherwise). Equivalently, writing
`e_{a,b}` for the unit table,
```
B(i,i',j,j') = e_{i,j'} + e_{i',j} − e_{i,j} − e_{i',j'}.
```
When `i ≠ i'` and `j ≠ j'` these four cells are distinct, and the move adds `+1`
on one diagonal of the `2 × 2` rectangle and `−1` on the other.

**Definition 2.6 (Legal step).** The *step relation* `Step u v` holds iff `u` and
`v` are both non-negative and there exist `i ≠ i'`, `j ≠ j'` with
`v = u + B(i,i',j,j')`.

**Definition 2.7 (Connectivity).** `Connected u v` is the reflexive–transitive
closure of `Step`: a finite walk of legal steps from `u` to `v`.

**Definition 2.8 (`ℓ¹` potential).** The *distance* between `u` and `v` is
```
D u v = ∑_{(a,b)} |u a b − v a b| ∈ ℕ,
```
the total number of unit cell-discrepancies (using `natAbs`, the natural-number
absolute value).

## 3. Margin Invariance

The defining feature of the basic move is that it lies in the kernel of the
margin map.

**Theorem 3.1 (Margin invariance).** For any table `u`, rows `i ≠ i'`, and columns
`j ≠ j'`,
```
SameMargins u (u + B(i,i',j,j')).
```

*Proof.* By additivity of finite sums, `rowSum (u + B) i = rowSum u i + rowSum B i`,
and likewise for columns; it suffices to show every margin of `B` vanishes.
Fix a row `a`. The only columns where `B a · ` is nonzero are `j` and `j'`. If
`a = i`, the contributions are `B a j' = +1` and `B a j = −1`, summing to `0`. If
`a = i'`, they are `B a j = +1` and `B a j' = −1`, again `0`. If `a ∉ {i, i'}`,
all entries are `0`. Hence `rowSum B a = 0`. Symmetrically (using `i ≠ i'` to keep
the two contributing rows distinct), `colSum B b = 0` for every column `b`. ∎

This single fact is what makes the move *admissible*: applying it never changes
the sufficient statistics held fixed during conditional inference.

## 4. Faithfulness of the Potential

**Theorem 4.1 (Faithfulness).** `D u v = 0` if and only if `u = v`.

*Proof.* `D u v` is a finite sum of natural numbers `|u a b − v a b|`. A sum of
naturals is zero iff every summand is zero, i.e. iff `u a b = v a b` for all
cells, which is exactly `u = v` (by function extensionality). ∎

Because `D` takes values in `ℕ`, it is a *well-founded* potential: any strictly
decreasing sequence of `D`-values terminates. This is the engine of the induction
in Section 7.

## 5. The Sign-Pattern Pigeonhole

The combinatorial core of the theorem is the existence, for any two distinct
equal-margin tables, of a `2 × 2` rectangle aligned with the sign pattern of
their difference.

**Theorem 5.1 (Sign-pattern pigeonhole).** If `SameMargins u v` and `u ≠ v`, then
there exist `i ≠ i'` and `j ≠ j'` such that
```
v i j  < u i j,     u i j' < v i j',     v i' j' < u i' j'.
```

*Proof.* Consider the difference `d a b = u a b − v a b`. Equal margins give
`∑_b d a b = 0` for every row `a` and `∑_a d a b = 0` for every column `b`; in
particular the grand total `∑_{a,b} d a b = 0`.

*Stage 1.* Since `u ≠ v`, some entry of `d` is nonzero. If every entry were `≤ 0`,
the grand total being `0` would force all entries to be `0` (a sum of non-positive
terms is zero only if each is zero), contradicting `u ≠ v`. Hence some cell `(i,j)`
has `d i j > 0`, i.e. `v i j < u i j`.

*Stage 2.* Row `i` satisfies `∑_b d i b = 0` and contains the positive term
`d i j > 0`. If every other entry of row `i` were `≥ 0`, the row sum would be
strictly positive, a contradiction. Hence some column `j'` has `d i j' < 0`, i.e.
`u i j' < v i j'`. Since a single cell cannot be simultaneously positive and
negative, `j' ≠ j`.

*Stage 3.* Column `j'` satisfies `∑_a d a j' = 0` and contains the negative term
`d i j' < 0`. By the same argument some row `i'` has `d i' j' > 0`, i.e.
`v i' j' < u i' j'`, and `i' ≠ i`.

The quadruple `(i, i', j, j')` has the asserted distinctness and sign pattern. ∎

Notably, distinctness `i ≠ i'` and `j ≠ j'` is *derived*, not assumed: a positive
cell and a negative cell cannot share a coordinate pair.

## 6. Distance Decrease and Single-Step Existence

**Theorem 6.1 (Distance decrease).** Suppose `i ≠ i'`, `j ≠ j'`, and the sign
pattern of Theorem 5.1 holds:
```
v i j < u i j,    u i j' < v i j',    v i' j' < u i' j'.
```
Then `D (u + B(i,i',j,j')) v < D u v`.

*Proof.* The move `B = B(i,i',j,j')` is supported on the four distinct cells
`(i,j), (i,j'), (i',j), (i',j')`. Off this frame, `u + B = u`, so those cells
contribute equally to both distances and cancel. It remains to compare the four
frame cells.

- At `(i,j)`: `B = −1` and `v i j < u i j`, so `|u i j − 1 − v i j| = |u i j − v i j| − 1`.
- At `(i,j')`: `B = +1` and `u i j' < v i j'`, so `|u i j' + 1 − v i j'| = |u i j' − v i j'| − 1`.
- At `(i',j')`: `B = −1` and `v i' j' < u i' j'`, so the discrepancy drops by `1`.
- At `(i',j)`: `B = +1`; the discrepancy changes by at most `+1`.

Summing, the total distance changes by at most `−1 − 1 − 1 + 1 = −2 < 0`. Hence
`D (u + B) v < D u v`. ∎

**Theorem 6.2 (Single legal step exists).** If `Nonneg u`, `Nonneg v`,
`SameMargins u v`, and `u ≠ v`, then there is a table `u'` with `Step u u'` and
`D u' v < D u v`.

*Proof.* Apply Theorem 5.1 to obtain `i ≠ i'`, `j ≠ j'` with the stated sign
pattern, and set `u' = u + B(i,i',j,j')`. Theorem 6.1 gives `D u' v < D u v`. It
remains to verify `Nonneg u'`, which by Definition 2.6 also certifies
`Step u u'`. The move alters only the four frame cells:

- At the three decremented/affected overshoot cells `(i,j)` and `(i',j')`, we have
  `u > v ≥ 0`, so subtracting `1` leaves a value `≥ v ≥ 0`.
- At `(i,j')` the value increases, preserving non-negativity.
- At `(i',j)` the value increases by `1`, preserving non-negativity.

All entries of `u'` are non-negative, so `Step u u'` holds. ∎

## 7. The Connectivity Theorem

**Theorem 7.1 (Bounded connectivity).** For every `N ∈ ℕ` and all tables `u, v`:
if `D u v ≤ N`, `Nonneg u`, `Nonneg v`, and `SameMargins u v`, then
`Connected u v`.

*Proof.* By strong induction on `N` (equivalently, well-founded induction on the
value `D u v`). If `u = v`, then `Connected u v` by reflexivity. Otherwise apply
Theorem 6.2 to get `u' = u + B(i,i',j,j')` with `Step u u'` and `D u' v < D u v`.
By Theorem 3.1, `SameMargins u' v` (margins of `u'` equal those of `u`, hence of
`v`), and `u'` is non-negative. Since `D u' v < D u v ≤ N`, the induction
hypothesis gives `Connected u' v`. Prepending the single step `Step u u'` yields
`Connected u v`. ∎

**Theorem 7.2 (Fundamental Theorem of Markov Bases, independence model).** For all
tables `u, v` with `Nonneg u`, `Nonneg v`, and `SameMargins u v`, we have
`Connected u v`. Equivalently, the family of basic `2 × 2` swaps connects every
fiber of the two-way independence model; it is a Markov basis.

*Proof.* Instantiate Theorem 7.1 with `N = D u v`, for which `D u v ≤ N` holds by
reflexivity. ∎

## 8. Reversibility and the Fiber Equivalence

For MCMC one needs the move set to define an undirected graph on each fiber.

**Theorem 8.1 (Step symmetry).** If `Step u v` then `Step v u`.

*Proof.* Suppose `v = u + B(i,i',j,j')` with both endpoints non-negative. Swapping
the two rows negates the move: `B(i',i,j,j') = − B(i,i',j,j')`, because the roles
of the `+1` and `−1` diagonals interchange. Hence
`u = v + B(i',i,j,j')` with `i' ≠ i` and `j ≠ j'`. The non-negativity
certificates for `u` and `v` are exactly those required, so `Step v u` holds. ∎

**Theorem 8.2 (Fibers are equivalence classes).** `Connected` is an equivalence
relation; its classes are exactly the fibers of the independence model.

*Proof.* `Connected` is the reflexive–transitive closure of `Step`, hence
reflexive and transitive by construction. For symmetry, induct along a walk
`u = w_0, w_1, …, w_k = v`: each step `Step w_t w_{t+1}` reverses to
`Step w_{t+1} w_t` by Theorem 8.1, and folding these reversed steps in opposite
order yields `Connected v u`. Thus `Connected` is an equivalence relation. By
Theorems 3.1 and 7.2, two non-negative tables are `Connected` iff they share all
margins, so the classes are precisely the fibers. ∎

## 9. Algorithm and Complexity

The proofs are constructive and translate directly into a greedy connection
algorithm.

**Algorithm (Greedy fiber walk).** *Input:* non-negative tables `u, v` of the same
shape with equal margins. *Output:* a sequence of basic `2 × 2` moves transforming
`u` into `v` through non-negative tables.

```
GreedyConnect(u, v):
    path ← [u]
    while u ≠ v:
        d ← u − v
        (i, j)   ← any cell with d[i][j] > 0          # Stage 1 pigeonhole
        (i, j')  ← any column with d[i][j'] < 0        # Stage 2 pigeonhole
        (i', j') ← any row with d[i'][j'] > 0          # Stage 3 pigeonhole
        u ← u + B(i, i', j, j')                        # apply the swap
        append u to path
    return path
```

**Termination and length.** Each iteration strictly decreases `D u v` by at least
`2` (Theorem 6.1) and at least `1` in all cases, so the number of moves is at most
`D(u, v) = ∑ |u − v| ≤ (sum of all entries of u and v)`. In particular the walk
has length `O(N)` where `N` is the total count, never exceeding the `ℓ¹`
diameter of the fiber.

**Per-step cost.** The three pigeonhole searches scan the `m × n` difference table
once, so each step costs `O(mn)`. The total running time is `O(mn · D(u,v))`. The
algorithm uses `O(mn)` working memory beyond the optional stored path.

For MCMC one does not run `GreedyConnect`; instead one proposes a *uniformly
random* legal `2 × 2` move at each step (choose two rows and two columns at random,
apply the move in the direction that keeps entries non-negative, with a
Metropolis–Hastings accept/reject to hit the target distribution). Theorem 7.2
guarantees that the resulting chain is irreducible on the fiber, and Theorem 8.1
that it is reversible — exactly the two hypotheses needed for the chain to
converge to its stationary distribution.

## 10. Applications

- **Exact conditional tests of independence.** Fisher's exact test and its
  generalizations require sampling tables with fixed margins; Theorem 7.2 is the
  irreducibility certificate that makes the sampler valid.
- **Disclosure limitation and data privacy.** National statistical agencies
  release marginal totals while protecting individual cells; understanding which
  tables are consistent with released margins (the fiber) is precisely the
  connectivity problem solved here.
- **Goodness-of-fit for log-linear models.** The independence model is the base
  case of a hierarchy of log-linear models; the distance-reduction template
  generalizes (with larger move sets) to richer models.
- **Combinatorics of transportation polytopes.** Fibers are the lattice points of
  transportation polytopes; the 2×2 swap is the lattice analogue of moving along
  an edge, and connectivity is integral flow circulation in disguise.

## 11. Discussion and Future Directions

The proof presented here is intentionally austere: it avoids the toric-ideal and
Gröbner-basis machinery of the general Diaconis–Sturmfels framework, relying
instead on a single integer potential and a pigeonhole. This austerity is a
feature — it makes the result a dependable, reusable nucleus.

**Future directions.**

1. *Quantitative mixing.* Upgrade the qualitative irreducibility of Theorem 7.2 to
   a spectral-gap or path-coupling bound, yielding rigorous mixing-time estimates
   for the 2×2-swap chain on the independence-model fiber.

2. *Beyond two dimensions.* Extend the distance-reduction template to multi-way
   tables and hierarchical log-linear models, where the Markov basis is no longer
   a single transparent family. The challenge is to find the right replacement for
   the three-stage pigeonhole when moves must coordinate across more than two
   slices.

3. *Sharper step bounds.* Theorem 6.1 only records a decrease of at least `2`. A
   refined analysis that chooses the *best* available rectangle at each step could
   yield shorter connecting walks and tighter diameter bounds for fibers.

4. *Toric-ideal bridge.* Connect this elementary proof to the algebraic picture by
   showing directly that the 2×2 moves generate the toric ideal of the
   independence model, turning the combinatorial connectivity statement and the
   algebraic generation statement into two faces of one verified object.

5. *Constrained and bounded fibers.* Incorporate cell upper bounds (capacities) or
   structural zeros, where some moves become illegal; identify when the 2×2 swaps
   still connect the now-restricted fiber, and when supplementary moves are
   required.

## References

- P. Diaconis and B. Sturmfels, *Algebraic algorithms for sampling from
  conditional distributions*, Annals of Statistics 26 (1998), 363–397.
- B. Sturmfels, *Gröbner Bases and Convex Polytopes*, AMS University Lecture
  Series, 1996.
- S. Aoki, H. Hara, and A. Takemura, *Markov Bases in Algebraic Statistics*,
  Springer, 2012.
