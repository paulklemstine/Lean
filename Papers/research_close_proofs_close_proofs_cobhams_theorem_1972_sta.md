# A Rank-One Markov Basis for the 2×2×2 No-Three-Way Interaction Model

## Abstract

The no-three-way interaction model is the canonical first example in algebraic
statistics of a log-linear model that is not decomposable, and its `2 × 2 × 2`
instance is the standard pedagogical entry point to Markov-basis theory. We give
a complete, self-contained treatment of this case. We prove three results. First,
the degree-four alternating move `M3(i,j,k) = (-1)^{i+j+k}` lies in the kernel of
the two-way margin map and is therefore a legal model move. Second, the move
lattice is **rank one**: any two tables with identical two-way margins differ by
exactly an integer multiple of `M3`, with the multiplier read off from a single
corner cell. Hence the singleton `{M3}` is a Markov basis. Third — the
Fundamental Theorem of Markov Bases for this model — any two *non-negative*
tables with equal margins are connected by a walk of `±M3` steps that remains
non-negative throughout, so `{M3}` connects every fiber. The connectivity proof
rests on a discrete-convexity lemma: the non-negative locus along the move line is
an integer interval, so a monotone unit-step walk never leaves it. We discuss the
Diaconis–Sturmfels sampling algorithm that these results justify, give numerical
demonstrations, and outline the genuinely harder `2 × 2 × n` generalization,
whose move lattice is no longer rank one.

**Keywords.** algebraic statistics, Markov basis, contingency tables,
no-three-way interaction, log-linear models, lattice kernel, discrete convexity,
Diaconis–Sturmfels algorithm, exact tests.

---

## 1. Introduction

### 1.1 Background

A **contingency table** records counts of jointly classified categorical data.
For three binary attributes the data form a `2 × 2 × 2` array `u(i,j,k)` with
`i, j, k ∈ {0, 1}` and `u(i,j,k) ∈ ℤ_{≥0}`. A **log-linear model** posits that
the expected counts factor through a fixed set of *sufficient statistics*; for the
**no-three-way interaction model** these statistics are exactly the three
families of two-dimensional marginal totals. The model asserts, informally, that
all dependence among the three attributes is captured by their pairwise
relationships, with no irreducible third-order term.

To test goodness-of-fit one performs an **exact conditional test**: condition on
the observed sufficient statistics (the two-way margins) and ask how extreme the
observed table is within the set of all tables sharing those statistics. That
set, the **fiber**, is generally too large to enumerate, so one samples from it
by a random walk. The walk moves between tables by adding integer **moves** that
preserve the sufficient statistics. For the walk to be valid (irreducible) the
move set must connect every fiber; such a connecting set is a **Markov basis**.
The Fundamental Theorem of Markov Bases (Diaconis–Sturmfels, 1998) identifies
Markov bases with generating sets of a certain toric ideal and guarantees their
finiteness.

### 1.2 Contributions

This paper formalizes and proves, for the `2 × 2 × 2` no-three-way model:

1. **Legality of the alternating move** (Theorem 4.1): `M3` preserves all
   two-way margins.
2. **Rank-one structure of the move lattice** (Theorem 5.1): the lattice of
   margin-preserving integer moves is the rank-one lattice `ℤ·M3`; equivalently,
   any two equal-margin tables differ by `(v(0,0,0) - u(0,0,0))·M3`.
3. **Connectivity of fibers** (Theorem 6.3, the Fundamental Theorem for this
   model): any two non-negative equal-margin tables are joined by a
   non-negativity-preserving walk of `±M3` steps.

The technical heart is a discrete-convexity lemma (Theorem 6.2) showing that the
non-negative locus on the move line is an integer interval, which converts the
algebraic statement `v = u + t·M3` into a legal walk.

---

## 2. Notation and Definitions

Throughout, indices `i, j, k` range over `{0, 1}` (the type `Fin 2`).

**Definition 2.1 (Table).** A `2 × 2 × 2` integer contingency table is a function
`u : {0,1}³ → ℤ`. We write `Table3` for the set of all such tables; it is a free
`ℤ`-module of rank 8 under pointwise addition and integer scaling.

**Definition 2.2 (Two-way margins).** For a table `u` define the three families
of two-way margins by summing out one coordinate:

- `m₁₂(u)(i,j) = u(i,j,0) + u(i,j,1)`  (sum over `k`),
- `m₁₃(u)(i,k) = u(i,0,k) + u(i,1,k)`  (sum over `j`),
- `m₂₃(u)(j,k) = u(0,j,k) + u(1,j,k)`  (sum over `i`).

Each family has four entries, for twelve margin values in all (subject to obvious
linear dependencies, since each one-way margin is computable two ways).

**Definition 2.3 (Same margins).** Two tables `u, v` have the **same margins**,
written `SameMargins u v`, when all three families agree pointwise:
`m₁₂(u) = m₁₂(v)`, `m₁₃(u) = m₁₃(v)`, and `m₂₃(u) = m₂₃(v)`.

The relation `SameMargins` is an equivalence relation; its classes (intersected
with the non-negative orthant) are the **fibers** of the model.

**Definition 2.4 (The alternating move).** Define `M3 : Table3` by
`M3(i,j,k) = +1` if `i + j + k` is even and `−1` if `i + j + k` is odd. Equivalently
`M3(i,j,k) = (-1)^{i+j+k}`.

**Lemma 2.5 (Values of the move).** For all `i, j, k`, `M3(i,j,k) ∈ {+1, −1}`.
*Proof.* Immediate from the case split on the parity of `i + j + k`. ∎

**Definition 2.6 (Non-negativity).** A table `u` is **non-negative**, `Nonneg u`,
if `u(i,j,k) ≥ 0` for all `i, j, k`.

**Definition 2.7 (Legal step and connectivity).** A **legal step** from `u` to
`v`, written `Step u v`, holds when `u` and `v` are both non-negative and
`v = u + M3` or `v = u − M3`. Tables `u, v` are **connected**, `Connected u v`,
if they are joined by a finite sequence of legal steps — formally, the
reflexive-transitive closure of `Step`.

---

## 3. The margin map and the move lattice

Collect the twelve margin values into a single linear map
`A : Table3 → ℤ^{12}`, `A(u) = (m₁₂(u), m₁₃(u), m₂₃(u))`. This is the integer
**design matrix** of the model. Two tables have the same margins iff their
difference lies in `ker A`. The **move lattice** of the model is precisely
`L := ker A ⊆ Table3`, a sublattice of the rank-8 free module `Table3`.

A Markov basis is, by definition, a finite subset `B ⊆ L` such that for every
fiber, the graph on fiber elements with edges `{w, w ± b : b ∈ B}` is connected.
The Fundamental Theorem of Markov Bases asserts that `B` is a Markov basis iff
the corresponding binomials generate the toric ideal `I_A`. Our results compute
`L` explicitly and verify connectivity directly, bypassing the ideal machinery in
this small case.

---

## 4. The move is legal

**Theorem 4.1 (Margin invariance).** For every table `u` and every integer `t`,
`SameMargins u (u + t·M3)`. Equivalently, `M3 ∈ ker A`, so `A(M3) = 0`.

*Proof sketch.* It suffices to show every two-way margin of `M3` is zero, since
margins are linear and `A(u + t·M3) = A(u) + t·A(M3)`. Fix a margin, say
`m₁₂(M3)(i,j) = M3(i,j,0) + M3(i,j,1)`. As `k` runs over `{0,1}` with `i, j`
fixed, the parity `i + j + k` flips exactly once, so the two summands are `+1`
and `−1` and their sum is `0`. The same argument applies to `m₁₃` (vary `j`) and
`m₂₃` (vary `i`). Concretely, expanding the four entries of each family by case
analysis on the two free indices and evaluating the parity `if` reduces every
margin to `1 + (−1) = 0`. ∎

The structural content is that **each line of the cube** (fix two coordinates,
vary the third) is a `+1, −1` pair under `M3`. The three families of margins are
exactly the three families of cube-lines, so all are annihilated simultaneously.

---

## 5. Rank-one structure of the move lattice

**Theorem 5.1 (Rank-one kernel).** If `SameMargins u v`, then
`v = u + (v(0,0,0) − u(0,0,0))·M3`. Consequently `ker A = ℤ·M3`, a free
`ℤ`-module of rank one, and `{M3}` generates the move lattice.

*Proof sketch.* Let `w = v − u`. Hypothesis `SameMargins u v` gives `A(w) = 0`,
i.e. all twelve margins of `w` vanish. Set `t = w(0,0,0)`. We show `w = t·M3` by
propagating the zero-margin equations cell by cell:

- From `m₁₂(w)(0,0) = w(0,0,0) + w(0,0,1) = 0` we get `w(0,0,1) = −t`.
- From `m₁₃(w)(0,0) = w(0,0,0) + w(0,1,0) = 0` we get `w(0,1,0) = −t`.
- From `m₂₃(w)(0,0) = w(0,0,0) + w(1,0,0) = 0` we get `w(1,0,0) = −t`.
- Continuing, each margin equation forces the next cell. The even-parity cells
  `(0,0,0), (0,1,1), (1,0,1), (1,1,0)` all equal `+t`, and the odd-parity cells
  `(0,0,1), (0,1,0), (1,0,0), (1,1,1)` all equal `−t`.

Thus `w(i,j,k) = (-1)^{i+j+k}·t = t·M3(i,j,k)`, i.e. `w = t·M3` with
`t = w(0,0,0) = v(0,0,0) − u(0,0,0)`. Mechanically, after instantiating all
twelve scalar margin equations one performs a case split over the eight cells;
each cell is then an integer-linear consequence of the equations and closes by
linear arithmetic (`omega`). ∎

**Remark 5.2 (Why this is striking).** The free module `Table3` has rank 8. The
margin map cuts it down by the rank of its image; Theorem 5.1 says the kernel has
rank exactly one. So the twelve (dependent) margin constraints pin the eight
unknowns down to a single line of freedom. This is the smallest non-trivial
Markov basis whose generator is *not* a `2 × 2` swap: the swap moves have degree
2, whereas `M3` has degree 4 (it changes all eight cells, moving total positive
mass 4). The degree jump is exactly the signature of leaving the realm of
decomposable models.

---

## 6. Connectivity: the Fundamental Theorem for this model

Theorem 5.1 is a statement about integer differences; the statistical
application requires walks through **non-negative** tables. We bridge the gap by a
discrete-convexity argument.

**Lemma 6.1 (Pointwise evaluation).** For all `u`, `t`, `i, j, k`,
`(u + t·M3)(i,j,k) = u(i,j,k) + t·M3(i,j,k)`. *Proof.* Pointwise definition of
addition and scaling on `Table3`. ∎

**Theorem 6.2 (Convex walk along the move line).** Let `u` be a table and `t` an
integer. If both `u` and `u + t·M3` are non-negative, then `Connected u (u + t·M3)`.

*Proof sketch.* Induct on `n = |t|` (the natural-number absolute value of `t`).

- *Base `n = 0`.* Then `t = 0` and `u + t·M3 = u`; connectivity is reflexivity.
- *Inductive step.* Suppose the claim holds for exponent `n` and `|t| = n + 1`.
  Split on the sign of `t`.
  - If `t > 0`, take the first step `u → u + M3`. We must check `u + M3` is
    non-negative: for each cell, if `M3(i,j,k) = +1` non-negativity is immediate
    from `u ≥ 0`; if `M3(i,j,k) = −1` then since the far endpoint satisfies
    `u(i,j,k) + t·(−1) ≥ 0` we have `u(i,j,k) ≥ t ≥ 1`, so `u(i,j,k) − 1 ≥ 0`.
    Hence `Step u (u + M3)`. Now `u + M3` and `(u + M3) + (t−1)·M3 = u + t·M3`
    are both non-negative and `|t − 1| = n`, so the inductive hypothesis connects
    them; prepend the first step.
  - If `t < 0`, symmetrically take the first step `u → u − M3` and recurse with
    `t + 1`.

The key inequality — "if a decreasing cell is non-negative at the far endpoint,
it has slack at least `|t|` near `u`" — is exactly the discrete-convexity
statement that the non-negative locus `{ s ∈ ℤ : u + s·M3 ≥ 0 }` is an interval
containing `0` and `t`, hence all integers between them. The unit-step walk stays
inside this interval. ∎

**Theorem 6.3 (Fundamental Theorem of Markov Bases, no-three-way model).** Any
two non-negative tables `u, v` with `SameMargins u v` satisfy `Connected u v`.
Equivalently, the singleton `{M3}` is a Markov basis: it connects every fiber.

*Proof.* By Theorem 5.1 there is an integer `t = v(0,0,0) − u(0,0,0)` with
`v = u + t·M3`. Both `u` and `v = u + t·M3` are non-negative by hypothesis, so
Theorem 6.2 yields `Connected u (u + t·M3) = Connected u v`. ∎

This is the complete justification that a Diaconis–Sturmfels random walk using
the single move `M3` is irreducible on every fiber of the model.

---

## 7. Algorithms

### 7.1 Computing the connecting walk

Given two non-negative equal-margin tables, the constructive content of
Theorems 5.1 and 6.2 yields an explicit walk.

```
Algorithm WALK(u, v):
  # Precondition: u, v ≥ 0 and SameMargins(u, v).
  t ← v(0,0,0) − u(0,0,0)          # the unique move multiplier (Thm 5.1)
  s ← sign(t); step ← s · M3        # +M3 if t>0, −M3 if t<0
  path ← [u]; w ← u
  repeat |t| times:
      w ← w + step                  # one unit move toward v
      path.append(w)                # w ≥ 0 guaranteed by Thm 6.2
  assert w == v
  return path                        # length |t| + 1, all entries ≥ 0
```

Complexity: `O(|t|)` steps, each `O(1)` work on 8 cells; `|t| = |v(0,0,0) −
u(0,0,0)|` is bounded by the largest cell count.

### 7.2 Exact-test sampling (Diaconis–Sturmfels)

The Markov basis powers a Metropolis–Hastings sampler that explores a fiber
without enumerating it.

```
Algorithm DS-SAMPLE(u0, N):
  # u0 a non-negative table; sample N tables from its fiber.
  u ← u0
  for step in 1..N:
      ε ← uniform({+1, −1})
      w ← u + ε · M3
      if w ≥ 0 (all cells):           # acceptance for uniform target
          accept with prob min(1, π(w)/π(u))   # π: target weights (e.g. hypergeometric)
          if accepted: u ← w
      record u
  return recorded tables
```

Irreducibility of this chain — that it can reach every table in the fiber — is
exactly Theorem 6.3. Aperiodicity follows from the rejection self-loops. Thus the
chain converges to its stationary distribution, validating the exact conditional
test of no three-way interaction.

---

## 8. Applications

- **Exact tests of conditional independence.** The model is the conditional
  independence pattern with no third-order term; the sampler gives a Monte Carlo
  exact `p`-value for `χ²` or likelihood-ratio statistics when asymptotics are
  unreliable (small counts).
- **Biology and genetics.** Testing whether three genetic markers or three
  phenotypes interact only pairwise.
- **Social science and survey analysis.** The motivating coffee/exercise/sleep
  example: deciding whether a three-way effect is real or an artifact of pairwise
  associations.
- **Teaching.** The `2 × 2 × 2` model is the canonical worked example through
  which the entire pipeline — sufficient statistics, fibers, moves, Markov bases,
  toric ideals, MCMC — is introduced.

---

## 9. Discussion

The `2 × 2 × 2` no-three-way model is special: its move lattice is **rank one**,
so a single move suffices and fibers are linear segments. Three transferable
ideas drive the proofs:

1. **Sign propagation.** Vanishing margins force each cell to be `±t`, an
   alternating pattern — the signature of the checkerboard move.
2. **Rank collapse.** Twelve dependent linear constraints reduce eight unknowns
   to one free parameter; the kernel is `ℤ·M3`.
3. **Discrete convexity.** The non-negative locus along a move line is an integer
   interval, converting an algebraic difference into a legal walk.

These are precisely the ingredients that recur, with greater multiplicity, in
larger models.

---

## 10. Future Work

### 10.1 The `2 × 2 × n` model

Extending the third axis to `n` categories gives the `2 × 2 × n` table
`TableN n : {0,1} × {0,1} × {0,…,n−1} → ℤ`. The move lattice is **no longer rank
one**. A Markov basis consists of one alternating `2 × 2 × 2` move for **each
pair of slices** along the long axis: choose two values `k₁ ≠ k₂`, restrict to
those two `2 × 2` faces, and place a checkerboard. There are `C(n,2)` such
generators (subject to dependencies). Connectivity is then a genuine
multi-generator argument — the single-line discrete-convexity walk is replaced by
a web of intersecting walks, and one must show no fiber decomposes into
unreachable components. This is the authentic content of the Fundamental Theorem
and the natural next formalization target.

### 10.2 Beyond binary and beyond three-way

- `r × c × ℓ` models with arbitrary category counts: Markov bases grow in degree
  and number; structural results (e.g. Markov complexity, Graver bases) become
  relevant.
- Higher-interaction hierarchical models on more factors, where the toric-ideal
  viewpoint becomes indispensable and bounds on Markov degree (e.g.
  Sturmfels–type results) are sharp research questions.
- Quantitative mixing: even with connectivity established, the *speed* of the
  Diaconis–Sturmfels walk — its spectral gap on a fiber — is open in most
  multi-way cases and is the practical bottleneck for exact tests.

---

## 11. Conclusion

For the `2 × 2 × 2` no-three-way interaction model we established a complete,
constructive theory: a single explicit alternating move `M3` of degree four is a
legal move (Theorem 4.1), it generates the entire rank-one move lattice
(Theorem 5.1), and it connects every fiber through non-negative tables
(Theorem 6.3). The connectivity rests on a discrete-convexity lemma asserting
that the non-negative tables along a move line form an integer interval. Together
these results give a fully verified foundation for the Diaconis–Sturmfels exact
test in the smallest non-decomposable model, and a clean template for the
richer `2 × 2 × n` and `r × c × ℓ` cases that lie ahead.
