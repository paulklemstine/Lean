# The Markov Basis of the Two-Way Independence Model: A Self-Contained Proof of the Fundamental Theorem of Markov Bases

## Abstract

We give a complete, elementary, and fully formalized proof that the set of basic
2×2 swap moves forms a **Markov basis** for the two-way independence model on
integer contingency tables. Concretely, we prove that any two non-negative
integer `m × n` tables with identical row and column margins are connected by a
finite walk of basic moves that remains non-negative at every step. This is the
foundational instance of the Diaconis–Sturmfels Fundamental Theorem of Markov
Bases (1998), which underlies Markov chain Monte Carlo approaches to Fisher-style
exact conditional inference. Our proof avoids commutative-algebra machinery
(Gröbner bases, toric ideals) and instead uses a direct *distance-reduction*
(potential-function) argument: a three-stage pigeonhole on the sign pattern of the
difference table locates a 2×2 frame whose basic move strictly decreases the ℓ¹
distance to the target while preserving non-negativity, and induction on the
distance closes the argument. We additionally prove that the step relation is
symmetric, so that fiber connectivity is an equivalence relation whose classes are
exactly the fibers of the model — precisely the irreducibility and symmetry
guarantees required for a correct MCMC sampler. All results are stated inline with
full mathematical content and proof sketches.

**Keywords:** algebraic statistics, Markov basis, contingency table, exact test,
Diaconis–Sturmfels theorem, independence model, Markov chain Monte Carlo,
distance reduction, pigeonhole principle, lattice walks.

---

## 1. Introduction

### 1.1 Motivation: exact conditional inference

A two-way **contingency table** records the joint counts of two categorical
variables. With *m* categories for the first variable and *n* for the second, a
table is an integer array `u(i,j)` for `i ∈ {1,…,m}`, `j ∈ {1,…,n}`. The two
families of one-dimensional margins are the row totals `rowSum(u,i) = Σⱼ u(i,j)`
and the column totals `colSum(u,j) = Σᵢ u(i,j)`.

The **independence model** asks whether the row variable and column variable are
statistically independent. The classical exact test (a generalization of Fisher's
exact test) conditions on the sufficient statistics of the model — which for
independence are precisely the row and column margins — and evaluates a test
statistic against its conditional distribution. That conditional distribution is
supported on the **fiber**: the set of all non-negative integer tables sharing the
observed margins,

```
F(r,c) = { u : Fin m → Fin n → ℤ | u ≥ 0,  rowSum u = r,  colSum u = c }.
```

The fiber is the set of lattice points of a transportation polytope and is
typically far too large to enumerate.

### 1.2 The MCMC escape and the role of a Markov basis

When direct enumeration is infeasible, one samples from the conditional
distribution via a Markov chain on the fiber. Such a chain needs a set of
*moves*: integer perturbations that preserve the margins (keeping the walk inside
the fiber) and can be applied while preserving non-negativity (keeping counts
valid). A finite set of moves whose induced walk is irreducible on **every** fiber
is called a **Markov basis** for the model. Diaconis and Sturmfels (1998)
established the general existence of Markov bases via the algebra of toric ideals,
and identified, for the two-way independence model, the explicit basis of **basic
2×2 swap moves**.

### 1.3 Contribution

This paper presents a self-contained proof of the Fundamental Theorem of Markov
Bases for the two-way independence model — that the basic 2×2 moves connect every
fiber — without invoking toric ideals or Gröbner-basis theory. The proof is a
purely combinatorial distance-reduction argument and has been fully formalized and
machine-verified. The supporting lemmas (margin preservation, faithfulness of the
ℓ¹ distance, the sign-pattern pigeonhole, strict distance decrease, single-step
existence) are also of independent pedagogical value, and the symmetry of the step
relation upgrades connectivity to an equivalence relation, matching the structural
requirements of a symmetric, irreducible MCMC sampler.

---

## 2. Definitions

Throughout, fix `m, n : ℕ`. We work over the integers ℤ.

**Definition 2.1 (Table).** An `m × n` integer contingency table is a function
`u : Fin m → Fin n → ℤ`. We write `Table m n` for this type.

**Definition 2.2 (Margins).** For a table `u`:

- the *i*-th **row sum** is `rowSum(u, i) = Σ_{j ∈ Fin n} u(i,j)`;
- the *j*-th **column sum** is `colSum(u, j) = Σ_{i ∈ Fin m} u(i,j)`.

**Definition 2.3 (Same margins).** Two tables `u, v` have the *same margins*,
written `SameMargins u v`, iff `rowSum(u,i) = rowSum(v,i)` for all `i` and
`colSum(u,j) = colSum(v,j)` for all `j`.

**Definition 2.4 (Basic move).** For rows `i, i' : Fin m` and columns
`j, j' : Fin n`, the **basic move** is the table

```
B(i,i',j,j')(a,b) = [a=i ∧ b=j'] + [a=i' ∧ b=j] − [a=i ∧ b=j] − [a=i' ∧ b=j'],
```

where `[P]` is 1 if `P` holds and 0 otherwise. Equivalently, with `e(a,b)` the
indicator table at cell `(a,b)`,
`B(i,i',j,j') = e(i,j') + e(i',j) − e(i,j) − e(i',j')`.

**Definition 2.5 (Non-negativity).** A table `u` is *non-negative*, `Nonneg u`,
iff `u(i,j) ≥ 0` for all `i, j`.

**Definition 2.6 (Legal step).** `Step u v` holds iff `u` and `v` are both
non-negative and there exist `i ≠ i'`, `j ≠ j'` with `v = u + B(i,i',j,j')`.

**Definition 2.7 (Connectivity).** `Connected u v` is the reflexive–transitive
closure of `Step`: a finite walk `u = t₀, t₁, …, t_N = v` with `Step tₖ tₖ₊₁` for
each `k` (the empty walk gives `Connected u u`).

**Definition 2.8 (ℓ¹ distance).** The distance between tables is the natural number

```
D(u, v) = Σ_{(i,j) ∈ Fin m × Fin n} |u(i,j) − v(i,j)|,
```

where `|·|` denotes the integer absolute value cast to ℕ (`Int.natAbs`).

---

## 3. Main results

We state the principal theorems; Section 4 gives proof sketches.

**Theorem 3.1 (Margin preservation).** For any table `u`, distinct rows `i ≠ i'`,
and distinct columns `j ≠ j'`,

```
SameMargins u (u + B(i,i',j,j')).
```

Equivalently, every basic move lies in the kernel of the margin map: each row of
`B(i,i',j,j')` sums to 0 and each column sums to 0.

**Theorem 3.2 (Faithfulness of the distance).** For all tables `u, v`,

```
D(u, v) = 0  ⟺  u = v.
```

**Theorem 3.3 (Sign-pattern pigeonhole).** If `SameMargins u v` and `u ≠ v`, then
there exist rows `i ≠ i'` and columns `j ≠ j'` with the sign pattern

```
v(i,j)   < u(i,j),      u(i,j')  < v(i,j'),      v(i',j') < u(i',j').
```

**Theorem 3.4 (Strict distance decrease).** If `i ≠ i'`, `j ≠ j'`, and the sign
pattern `v(i,j) < u(i,j)`, `u(i,j') < v(i,j')`, `v(i',j') < u(i',j')` holds, then

```
D(u + B(i,i',j,j'), v) < D(u, v).
```

**Theorem 3.5 (Existence of a good step).** If `u` and `v` are non-negative with
`SameMargins u v` and `u ≠ v`, then there is a table `u'` with `Step u u'` and
`D(u', v) < D(u, v)`.

**Theorem 3.6 (Fundamental Theorem of Markov Bases, two-way independence model).**
For any non-negative tables `u, v` with `SameMargins u v`,

```
Connected u v.
```

That is, the basic 2×2 swap moves form a Markov basis: they connect every fiber of
the independence model via non-negative walks.

**Theorem 3.7 (Symmetry; fibers are equivalence classes).** `Step` is symmetric:
`Step u v ⟹ Step v u`, because `B(i',i,j,j') = −B(i,i',j,j')`. Consequently
`Connected` is symmetric, and being a reflexive–transitive closure it is also
reflexive and transitive; hence `Connected` is an equivalence relation whose
classes are exactly the fibers.

---

## 4. Proof sketches

### 4.1 Theorem 3.1 (Margin preservation)

Row sums and column sums are additive over `u + B`, so it suffices to show every
row sum and column sum of `B(i,i',j,j')` is zero. Fix a row index `k`. The only
columns where row `k` of `B` is nonzero are among `{j, j'}`, and they occur only
when `k ∈ {i, i'}`. A case split on `k = i`, `k = i'` shows:

- if `k = i`: row `k` of `B` is `+1` at `j'` and `−1` at `j`, summing to 0
  (here `j ≠ j'` guarantees these are distinct columns, so no cancellation is
  lost);
- if `k = i'`: row `k` is `+1` at `j` and `−1` at `j'`, summing to 0;
- otherwise row `k` is identically 0.

The column-sum claim is symmetric, using `i ≠ i'`. Adding the zero perturbation
leaves all margins unchanged. ∎

### 4.2 Theorem 3.2 (Faithfulness)

`D(u,v)` is a finite sum of non-negative integers `|u(i,j) − v(i,j)|`. A sum of
non-negative terms is zero iff every term is zero, and `|u(i,j) − v(i,j)| = 0` iff
`u(i,j) = v(i,j)`. Hence `D(u,v) = 0` iff `u` and `v` agree in every cell, i.e.
`u = v`. ∎

### 4.3 Theorem 3.3 (Sign-pattern pigeonhole)

Consider the difference table `d = u − v`. Because `u` and `v` share all margins,
*every* row sum and *every* column sum of `d` is zero; in particular the grand
total `Σ_{i,j} d(i,j) = 0`. The proof proceeds in three stages.

1. **A strictly positive cell exists.** Since `u ≠ v`, the table `d` is not
   identically zero. Suppose, for contradiction, `d(i,j) ≤ 0` everywhere. Using a
   row margin `rowSum(d, i) = 0` together with a strict inequality at the
   disagreeing cell forces a strict decrease of a sum that should be zero — a
   contradiction. Hence some cell `(i,j)` has `d(i,j) > 0`, i.e. `v(i,j) < u(i,j)`.

2. **A strictly negative cell in the same row.** Row `i` of `d` sums to zero but
   has the strictly positive entry at `j`. If all other entries of row `i` were
   `≥ 0`, the row sum would be strictly positive, contradicting
   `rowSum(d,i) = 0`. So there is a column `j'` with `d(i,j') < 0`, i.e.
   `u(i,j') < v(i,j')`. Since `d(i,j) > 0` and `d(i,j') < 0` have opposite signs,
   `j ≠ j'`.

3. **A strictly positive cell in that column.** Column `j'` of `d` sums to zero
   but has the strictly negative entry at row `i`. By the same argument there is a
   row `i'` with `d(i',j') > 0`, i.e. `v(i',j') < u(i',j')`. Opposite signs again
   force `i ≠ i'`.

This yields the required 2×2 frame `(i,i',j,j')` with `i ≠ i'`, `j ≠ j'` and the
stated sign pattern. ∎

### 4.4 Theorem 3.4 (Strict distance decrease)

Adding `B(i,i',j,j')` changes `u` only at the four corner cells `(i,j)`, `(i,j')`,
`(i',j)`, `(i',j')`; everywhere else `u + B = u`, so those cells contribute
identically to `D(·,v)` and cancel. It therefore suffices to track the four
corners. By the sign hypotheses:

- at `(i,j)`: `u(i,j) > v(i,j)` and `B` subtracts 1, moving the value one step
  toward `v(i,j)`, decreasing `|·|` by 1;
- at `(i,j')`: `u(i,j') < v(i,j')` and `B` adds 1, moving toward `v(i,j')`,
  decreasing `|·|` by 1;
- at `(i',j')`: `u(i',j') > v(i',j')` and `B` subtracts 1, decreasing `|·|` by 1;
- at `(i',j)`: `B` adds 1; in the worst case this moves away from `v(i',j)`,
  increasing `|·|` by at most 1.

The net change in `D` is at most `−1 − 1 − 1 + 1 = −2 < 0`, so
`D(u + B, v) < D(u, v)`. Localizing the universe sum to the four-element frame and
the complementary cells makes this a finite, exact computation. ∎

### 4.5 Theorem 3.5 (Existence of a good step)

By Theorem 3.3 obtain the sign-aligned frame `(i,i',j,j')`. Set
`u' = u + B(i,i',j,j')`. Theorem 3.4 gives `D(u',v) < D(u,v)`. It remains to check
`u'` is non-negative, which makes `Step u u'` hold. The three decremented corners
satisfied `u(i,j) > v(i,j) ≥ 0`, `u(i',j') > v(i',j') ≥ 0`, so after subtracting 1
they remain `≥ 0`; the two incremented corners only increase and `u` was already
non-negative; all other cells are unchanged. Hence `Nonneg u'`, and the legal step
`Step u u'` exists with strictly smaller distance. ∎

### 4.6 Theorem 3.6 (Fundamental Theorem)

We prove the strengthened statement by strong induction on a distance bound `N`:
*for all `u, v` with `D(u,v) ≤ N`, both non-negative, and `SameMargins u v`, we
have `Connected u v`.* The theorem is the case `N = D(u,v)`.

- **Base / equal case.** If `u = v`, then `Connected u v` by reflexivity.
- **Inductive step.** If `u ≠ v`, Theorem 3.5 gives a legal step `Step u u'` with
  `D(u', v) < D(u, v) ≤ N`. By Theorem 3.1 (applied to the basic move used) `u'`
  still has the same margins as `v`, and `u'` is non-negative. Since
  `D(u', v) < N`, the strong-induction hypothesis yields `Connected u' v`.
  Prepending the single step `Step u u'` gives `Connected u v`.

The measure `D(·, v)` is a non-negative integer that strictly decreases at each
step, so the recursion terminates. ∎

### 4.7 Theorem 3.7 (Symmetry)

For the step relation, observe `B(i',i,j,j') = −B(i,i',j,j')` (swapping the two
rows negates the move). Hence if `v = u + B(i,i',j,j')` then
`u = v + B(i',i,j,j')`, and the non-negativity certificates for `u` and `v` are
exactly the same two facts; thus `Step v u`. Folding this symmetry through the
reflexive–transitive closure gives `Connected u v ⟹ Connected v u`. Together with
the built-in reflexivity and transitivity of the closure, `Connected` is an
equivalence relation. Its equivalence classes are exactly the fibers `F(r,c)`. ∎

---

## 5. Algorithms

The constructive content of the proof yields a concrete sampler/connector.

### 5.1 Greedy connecting walk

Theorems 3.3–3.6 are constructive: given two equal-margin non-negative tables, one
can *build* an explicit walk between them.

```
Algorithm CONNECT(u, v):           # u, v non-negative, SameMargins u v
  path ← [u]
  while u ≠ v:
    d ← u − v
    (i, j)  ← any cell with d(i,j) > 0          # stage 1 pigeonhole
    (i, j') ← any column with d(i,j') < 0        # stage 2 pigeonhole (same row i)
    (i', j')← any row with d(i',j') > 0          # stage 3 pigeonhole (same column j')
    u ← u + B(i, i', j, j')                       # basic 2×2 swap
    path ← path ++ [u]
  return path
```

**Correctness.** Each iteration strictly decreases `D(u,v)` (Theorem 3.4) and
preserves non-negativity (Theorem 3.5) and margins (Theorem 3.1). Termination
follows since `D` is a non-negative integer strictly decreasing each step.

**Complexity.** The loop runs at most `D(u,v)/2` times (each step removes at least
2 units of distance), and each iteration scans the `m·n` cells three times, giving
`O(m·n·D(u,v))` total work. Since `D(u,v) ≤ Σ|u(i,j)| + Σ|v(i,j)|` is bounded by
twice the table's total count, the walk is polynomial in the data size.

### 5.2 Metropolis sampler on a fiber

For statistical use one instead takes *random* basic moves and accepts/rejects to
realize a target conditional distribution (e.g. the hypergeometric distribution
for exact independence testing).

```
Algorithm SAMPLE(u₀, target π, steps T):
  u ← u₀
  repeat T times:
    pick i ≠ i' uniformly in rows, j ≠ j' uniformly in columns, and a sign s ∈ {+1,−1}
    w ← u + s · B(i, i', j, j')
    if w is non-negative:
      accept w with probability min(1, π(w)/π(u))   # Metropolis ratio
      if accepted: u ← w
  return u
```

The proposal is symmetric (Theorem 3.7), so the Metropolis acceptance ratio is
just `π(w)/π(u)`. Connectivity (Theorem 3.6) guarantees the chain is irreducible
on the fiber, hence converges to `π`.

---

## 6. Applications

1. **Exact tests of independence.** When a contingency table is too large to
   enumerate its fiber, the sampler of Section 5.2 estimates the exact conditional
   p-value of a test statistic (e.g. Pearson's χ², the likelihood-ratio statistic,
   or a cell-count) by averaging over visited tables. Theorem 3.6 is exactly the
   irreducibility guarantee that makes such estimates consistent.

2. **Goodness-of-fit for log-linear models.** The independence model is the
   simplest log-linear model; the basic-move machinery is the prototype for Markov
   bases of more elaborate log-linear and hierarchical models.

3. **Transportation polytopes and lattice geometry.** A fiber is the set of
   lattice points of a transportation polytope; the basic moves are the primitive
   integer circuits of its underlying matroid. Theorem 3.6 is the statement that
   these primitive moves connect all lattice points of the polytope.

4. **Verified statistical software.** Because the connectivity guarantee is
   machine-checked from first principles, it can serve as a trustworthy
   foundation for certified implementations of exact-test samplers.

---

## 7. Discussion

The proof deliberately avoids the toric-ideal/Gröbner-basis route of the original
Diaconis–Sturmfels argument. That route is powerful and general — it proves the
*existence* of finite Markov bases for arbitrary log-linear models — but for the
two-way independence model it is heavier than necessary. The distance-reduction
argument here is elementary, constructive, and exposes the precise mechanism: the
balance imposed by equal margins (every row and column of the difference sums to
zero) forces a sign-alternating 2×2 frame, and the basic move is exactly the
minimal integer perturbation that exploits such a frame to make progress.

The same template — *(i)* a faithful integer potential, *(ii)* a structural lemma
locating a progress-making generator, *(iii)* a strict-decrease lemma, *(iv)*
induction on the potential — generalizes to other models whenever one can prove a
combinatorial analogue of the sign-pattern pigeonhole. The bottleneck in
generalization is exactly step *(ii)*: for higher-dimensional tables and richer
margin constraints, the set of necessary moves grows and the pigeonhole becomes
more intricate (this is where the toric algebra reasserts its value).

A noteworthy structural payoff is Theorem 3.7. Symmetry of the move set is not
automatic for an arbitrary generating set, yet it holds here transparently because
the inverse of a basic move is a basic move (swap the rows). This gives, for free,
both a *symmetric* MCMC proposal (no Hastings correction needed) and the
recognition that fibers are honest equivalence classes.

---

## 8. Future work

The following directions extend the present foundation; they are stated as precise,
testable conjectures.

- **Higher-dimensional and hierarchical models.** Formalize Markov bases for the
  no-three-way-interaction model on `p × q × r` tables and, more generally,
  hierarchical log-linear models, where the move sets are richer and connectivity
  is subtler.

- **Mixing-time bounds.** Beyond irreducibility, quantify *how fast* the basic-move
  chain mixes. Conjecture polynomial mixing for fixed table dimensions and bounded
  margins, via canonical-path or comparison arguments anchored to the ℓ¹ potential
  used here.

- **Minimality and uniqueness.** Prove the basic 2×2 moves are a *minimal* Markov
  basis for the independence model (no proper subset connects all fibers), and
  characterize the unique minimal basis up to sign.

- **Lattice-geometric formulation.** Identify the basic moves with the primitive
  circuits of the design matrix and connect the present combinatorial proof to the
  toric-ideal picture, recovering the Diaconis–Sturmfels correspondence as a
  corollary.

- **Certified end-to-end exact tests.** Build a verified pipeline from a raw
  contingency table to an exact conditional p-value, with the irreducibility of
  the sampler discharged by Theorem 3.6.

(Phase A additionally recorded a parallel program connecting the discrete Hodge
Laplacian to reversible random walks — kernel/connectivity correspondences,
spectral-gap mixing, the discrete Hodge decomposition, reversibility as
self-adjointness, and effective resistance — which provide a complementary
spectral lens on the same probabilistic objects.)

---

## 9. Conclusion

We have proved, from first principles and with full rigor, the Fundamental Theorem
of Markov Bases for the two-way independence model: the basic 2×2 swap moves
connect every fiber of integer contingency tables with fixed margins, via walks
that stay non-negative throughout. The argument is a transparent distance-reduction
proof powered by a three-stage sign-pattern pigeonhole, and it comes with the
bonus that the connectivity relation is an equivalence relation. These are exactly
the symmetry and irreducibility properties that legitimize Markov chain Monte Carlo
approaches to exact conditional inference on contingency tables.
