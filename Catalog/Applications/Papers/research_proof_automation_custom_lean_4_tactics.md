# Sound Custom Tactics for Number Theory, Tropical Algebra, and Spectral Estimation

## Abstract

We present three custom proof-automation tactics, together with machine-checked
soundness guarantees, addressing three recurring families of proof obligations:
finite-case number theory, min-plus (tropical) simplification, and eigenvalue
magnitude estimation. The first tactic, `number_theory_decide`, is a disjunction
of individually sound primitive procedures; its soundness is therefore inherited
structurally, and we demonstrate its role as the load-bearing *finite checker*
inside genuine induction and modular-reduction arguments — proving
$n^2 < 2^n$ for $n \ge 5$, the Fermat-style congruences $p \mid n^p - n$ for
$p \in \{5,7\}$, and the composite-modulus fact $6 \mid n^3 - n$. The second
tactic, `tropical_simp`, normalizes min-plus expressions; its correctness rests
on a distributivity (scalar-fold) lemma together with the associativity and
commutativity of the minimum. The third tactic, `spectral_bound`, discharges
eigenvalue magnitude goals; its soundness is a weak Gershgorin row-sum bound that
we prove from first principles via the classical largest-coordinate argument. For
each tactic we delineate precisely which step is mechanizable and which step
encodes irreducible mathematical insight, and we record the honest scope and
limitations of each. The unifying thesis is that a finite or single-inequality
*core* becomes powerful exactly when paired with a *reduction principle* —
induction, quotient to a finite ring, or selection of an extremal coordinate.

**Keywords.** proof automation, custom tactics, soundness, finite-case
decision, Fermat's little theorem, modular reduction, tropical semiring, min-plus
algebra, Gershgorin bound, eigenvalue estimation.

---

## 1. Introduction

Formal proof developments accumulate a long tail of routine obligations:
finite case splits, algebraic normalizations, and standard estimates. Each is
individually trivial yet collectively expensive, and each is a site where manual
proof is error-prone. Encapsulating such patterns into reusable *tactics* is the
standard remedy, but it raises an immediate concern: a tactic that closes a false
goal is worse than no tactic at all, because it silently corrupts the soundness
of everything built on top of it.

This paper studies three tactics under a strict discipline: every tactic must
come with a soundness guarantee, and we must be explicit about which proof steps
the tactic genuinely automates versus which steps it merely *finishes* after a
human-supplied reduction. We argue, through worked theorems, that the value of a
narrow automatic core is realized precisely when it is composed with a reduction
principle that converts an infinite or structurally complex statement into the
core's domain.

The three tactics are:

1. **`number_theory_decide`** — a finite-case checker for number theory,
   built as a disjunction of sound primitives.
2. **`tropical_simp`** — a normalizer for min-plus (tropical) expressions,
   founded on a distributivity lemma.
3. **`spectral_bound`** — an eigenvalue magnitude estimator, founded on a
   Gershgorin-type row-sum certificate.

### 1.1 Two soundness disciplines

We distinguish two routes to a sound tactic.

- **Inherited soundness (compositional).** If a tactic is a combinator over
  sub-tactics each of which is sound, the composite is sound. `number_theory_decide`
  follows this route.
- **Certified soundness (reflective certificate).** If a tactic applies a single
  proved theorem to the goal, it is sound provided that theorem is true and the
  application is type-correct. `spectral_bound` follows this route via the lemma
  `eigenvalue_rowsum_bound`. `tropical_simp` is intermediate: it is a rewrite
  system whose rewrite rules are individually proved equalities.

---

## 2. The `number_theory_decide` tactic

### 2.1 Definition

The tactic is a left-biased disjunction of four sound finishers, tried in order:

```
number_theory_decide :=
  first
    | omega                              -- linear integer/nat arithmetic
    | decide                             -- decidable propositions by evaluation
    | norm_num                           -- numeric (in)equalities, primality
    | (intro x; fin_cases x <;> decide)  -- exhaust a finite type, decide each
```

**Proposition 2.1 (Soundness, inherited).** Each branch is a sound tactic:
`omega` is a complete and sound decision procedure for linear arithmetic over
$\mathbb{Z}$ and $\mathbb{N}$; `decide` reduces a `Decidable` proposition to its
Boolean evaluation, which is sound by the correctness of the `Decidable`
instance; `norm_num` is a verified numeric normalizer; and the
`fin_cases`/`decide` branch reduces a goal over a finite type to finitely many
decidable subgoals. A first-success combinator over sound tactics is sound. ∎

The tactic therefore *cannot* close a false goal. Its limitation is dual to its
soundness: each branch only handles *finite* or *decidable* content. The
mathematical interest lies entirely in the reductions that bring genuine theorems
into that finite domain.

### 2.2 Reduction by induction: exponential dominance

**Theorem 2.2 (`two_pow_gt_sq`).** For every natural number $n \ge 5$,
$$n^2 < 2^n.$$

*Proof sketch.* Induct on $n$.

- *Base interval.* For $n < 5$ the hypothesis $5 \le n$ is contradictory, and the
  case $n = 5$ gives $25 < 32$; both are finite facts discharged by
  `number_theory_decide` (via `interval_cases`).
- *Inductive step.* Assume $k^2 < 2^k$ with $k \ge 5$. Then
  $$(k+1)^2 \le k^2 + k^2 < 2^k + 2^k = 2^{k+1},$$
  where $(k+1)^2 \le 2k^2$ holds for $k \ge 5$ (indeed for $k \ge 3$) by a
  quadratic inequality `nlinarith` closes, and the strict middle inequality is
  the induction hypothesis added to itself. The final equality is `ring`.

The inductive step is *not* a finite check and is the load-bearing mathematical
content; `number_theory_decide` is confined to the base interval. ∎

This theorem demonstrates the canonical pairing **induction + finite base**: the
reduction (induction) tames the universally quantified $n$, and the automatic
core handles only the finitely many starting values.

### 2.3 Reduction by quotient: Fermat-style congruences

The second reduction passes from divisibility over $\mathbb{Z}$ to vanishing in
the finite ring $\mathbb{Z}/m\mathbb{Z}$ (written `ZMod m`). The bridge is the
standard equivalence
$$(a : \mathbb{Z}/m\mathbb{Z}) = 0 \iff m \mid a \qquad
(\texttt{ZMod.intCast\_zmod\_eq\_zero\_iff\_dvd}).$$

**Theorem 2.3 (`fermat_little_five`).** For every integer $n$,
$$5 \mid n^5 - n.$$

*Proof sketch.* It suffices to show $(n^5 - n : \mathbb{Z}/5\mathbb{Z}) = 0$. By
the ring-homomorphism property of the cast (`push_cast`), this equals
$\bar n^5 - \bar n$ where $\bar n$ is the image of $n$. The finite identity
$$\forall x \in \mathbb{Z}/5\mathbb{Z},\quad x^5 - x = 0$$
is checked by `number_theory_decide` exhausting the five residues. Transporting
back through `ZMod.intCast_zmod_eq_zero_iff_dvd` yields the divisibility. ∎

**Theorem 2.4 (`fermat_little_seven`).** For every integer $n$, $7 \mid n^7 - n$.
*Proof sketch.* Identical to Theorem 2.3 with modulus $7$; the finite check
$\forall x \in \mathbb{Z}/7\mathbb{Z},\ x^7 - x = 0$ exhausts seven residues. ∎

**Theorem 2.5 (`cube_sub_self_six`).** For every integer $n$, $6 \mid n^3 - n$.

*Proof sketch.* The modulus need not be prime. Reduce to
$\forall x \in \mathbb{Z}/6\mathbb{Z},\ x^3 - x = 0$, a six-case finite check.
(Conceptually, $n^3 - n = (n-1)n(n+1)$ is a product of three consecutive
integers, hence divisible by $2$ and $3$, hence by $6$; the finite check
certifies this without the factorization.) ∎

The reusable chain is identical across $p = 5, 7$ and $m = 6$:
$$\texttt{ZMod.intCast\_zmod\_eq\_zero\_iff\_dvd} \ \to\ \texttt{push\_cast}
\ \to\ \texttt{decide (finite residues)}.$$
Only the literal modulus changes — strong evidence that the boilerplate is
mechanizable by a future reflective tactic (Section 7).

### 2.4 Soundness sanity checks

Two finite facts confirm the tactic discharges *true* goals only: `Nat.Prime 97`
(closed by the `norm_num` branch) and $n^2 \le 9$ for $n < 4$ (closed by
`interval_cases` then the finite branch). No false instance can be closed, by
Proposition 2.1.

---

## 3. The `tropical_simp` tactic

### 3.1 The min-plus setting

The tropical (min-plus) semiring replaces addition by $\min$ and multiplication
by $+$. Tropical "polynomials" are thus finite expressions built from variables
and constants using $\min$ and $+$; they model shortest-path costs, scheduling
optima, and piecewise-linear (e.g. ReLU-network) value functions. `tropical_simp`
normalizes such expressions.

### 3.2 The distributivity (scalar-fold) lemma

The single substantive correctness fact is that tropical multiplication (ordinary
$+$) distributes over tropical addition ($\min$):
$$c + \min(a, b) = \min(c + a,\; c + b).$$

**Lemma 3.1 (`scalar_foldr_min`, distributive core).** For a constant $c$, an
initial value $e$, and a finite list $[a_1, \ldots, a_k]$,
$$c + \operatorname{foldr}\min\, e\, [a_1,\ldots,a_k]
  = \operatorname{foldr}\min\,(c + e)\,[c + a_1,\ldots,c + a_k],$$
equivalently
$$c + \min(a_1, \ldots, a_k, e) = \min(c + a_1, \ldots, c + a_k, c + e).$$

*Proof sketch.* Induction on the list. The empty case is the identity
$c + e = c + e$. For the cons case, $c + \min(a_1, t) = \min(c + a_1, c + t)$ by
the binary distributive law above, and $c + t$ is rewritten by the induction
hypothesis. ∎

Lemma 3.1 certifies that the central rewrite of `tropical_simp` — pushing an
additive constant across an entire $\min$-chain — preserves value.

### 3.3 Associative–commutative normalization

Beyond distribution, `tropical_simp` flattens nested minima and canonically
orders operands using the semilattice laws of $\min$:
$$\min(a,b) = \min(b,a) \quad(\text{commutativity}),$$
$$\min(\min(a,b),c) = \min(a,\min(b,c)) \quad(\text{associativity}),$$
$$\min(a,\min(b,c)) = \min(b,\min(a,c)) \quad(\text{left-commutativity, } \texttt{min\_left\_comm}).$$
The left-commutativity law is the crucial addition that allows any operand to be
permuted to the front, so that AC-normalization terminates in a canonical order.

**Proposition 3.2 (Soundness of `tropical_simp`).** Every rewrite rule the
tactic applies is a proved equality (Lemma 3.1 and the three semilattice laws),
so the normalized expression is provably equal to the original; hence the tactic
never changes truth value. ∎

### 3.4 Scope and limitation

`tropical_simp` normalizes the *algebraic* structure (distribution + AC
reordering) but does not resolve the *order* of symbolic operands inside a
$\min$. Thus $\min(x,y)$ with $x,y$ unknown is left as a canonical but unresolved
form. Completing the procedure requires a finite case-split over the possible
total orders of the operands; this is the natural extension to a complete
decision procedure for min-plus polynomial identities (Section 7).

---

## 4. The `spectral_bound` tactic

### 4.1 Definition and certificate

`spectral_bound` discharges goals of the form "the magnitude of an eigenvalue is
at most $B$" by applying a single proved theorem.

**Theorem 4.1 (`eigenvalue_rowsum_bound`, soundness certificate).** Let $M$ be a
real $n \times n$ matrix ($n \ge 1$), let $v \in \mathbb{R}^n$ with $v \ne 0$,
and suppose
$$M v = \lambda v \qquad\text{and}\qquad \forall i,\ \sum_{j} |M_{ij}| \le B.$$
Then
$$|\lambda| \le B.$$

*Proof sketch.* Since the index set is finite and nonempty, choose $i$ maximizing
$|v_i|$ (`Finite.exists_max`). As $v \ne 0$, $|v_i| > 0$ (`abs_pos`). The $i$-th
component of $Mv = \lambda v$ reads
$$\lambda v_i = \sum_j M_{ij} v_j.$$
Taking absolute values and using the triangle inequality and $|v_j| \le |v_i|$:
$$|\lambda|\,|v_i| = \Big|\sum_j M_{ij} v_j\Big|
\le \sum_j |M_{ij}|\,|v_j|
\le \Big(\sum_j |M_{ij}|\Big)\,|v_i|
\le B\,|v_i|.$$
Cancelling the strictly positive factor $|v_i|$ (`le_of_mul_le_mul_right`) gives
$|\lambda| \le B$. ∎

**Proposition 4.2 (Soundness of `spectral_bound`).** The tactic does nothing but
apply Theorem 4.1 to the goal after supplying the eigen-equation, the
nonvanishing of $v$, and a row-sum bound $B$. Soundness is therefore exactly the
truth of Theorem 4.1. ∎

The hypothesis $v \ne 0$ is load-bearing: a zero "eigenvector" would admit any
$\lambda$, and the proof uses $v \ne 0$ precisely at `abs_pos`. Abstracting the
bound to a hypothesis $B$ with $\forall i, \sum_j |M_{ij}| \le B$ (rather than
hard-coding $\max_i \sum_j |M_{ij}|$) avoids `Finset.sup'` bookkeeping while
losing no generality, since the maximum instantiates $B$.

### 4.2 Worked example and corollary

For a concrete $2 \times 2$ matrix, the absolute row sums are immediate, their
maximum instantiates $B$, and `spectral_bound` certifies that both eigenvalue
magnitudes are $\le B$. A spectral-radius/trace-style corollary follows: the
spectral radius $\rho(M) = \max |\lambda|$ is bounded by the maximum absolute row
sum, which in turn controls trace-based quantities.

### 4.3 Scope and limitation

This is the *weak* Gershgorin bound — a single disc centered at the origin
containing the entire spectrum — not the full per-row union of discs. The full
statement,
$$\operatorname{spec}(M) \subseteq \bigcup_i \Big\{ z : |z - M_{ii}| \le
\sum_{j \ne i} |M_{ij}| \Big\},$$
follows from the *same* largest-coordinate argument by moving the diagonal term
$M_{ii} v_i$ to the other side before bounding (Section 7).

---

## 5. Algorithms

### 5.1 Finite modular-reduction checker

Underlying Theorems 2.3–2.5 is the algorithm: to decide $m \mid f(n)$ for all
$n \in \mathbb{Z}$ where $f$ is an integer polynomial, evaluate $f$ over all $m$
residues modulo $m$ and confirm each result is $0 \bmod m$. Complexity is
$O(m \cdot \deg f)$ modular operations — independent of $n$.

### 5.2 Tropical normalization

Given a min-plus expression tree, repeatedly (i) distribute additive constants
over $\min$ via Lemma 3.1, (ii) flatten nested $\min$ nodes by associativity,
(iii) sort operands by a fixed total order on subterms using commutativity and
left-commutativity. The result is a canonical $\min$ of $+$-terms. Each rewrite
strictly decreases a termination measure (constant-depth then operand
disorder).

### 5.3 Row-sum spectral bound

Given $M$, compute $r_i = \sum_j |M_{ij}|$ for each row and return
$B = \max_i r_i$. By Theorem 4.1 every eigenvalue satisfies $|\lambda| \le B$.
Complexity $O(n^2)$, with no eigen-decomposition required.

---

## 6. Applications

- **Competition and elementary number theory.** The modular-reduction pattern
  certifies a wide family of "for all $n$, $m \mid f(n)$" statements (Fermat-type
  congruences, periodicity mod $m$, polynomial congruences) with a uniform,
  trusted finite check.
- **Optimization and piecewise-linear models.** `tropical_simp` canonicalizes
  shortest-path and scheduling cost expressions, and the value functions of
  min-plus / ReLU-style networks, enabling identity checking and simplification.
- **Numerical stability and dynamics.** `spectral_bound` provides cheap a priori
  eigenvalue bounds for convergence of iterative methods, stability of linear
  dynamical systems, and conditioning estimates — all in $O(n^2)$ without
  computing eigenvalues.

---

## 7. Discussion and future work

The three tactics share a structural moral: a **narrow automatic core** (finite
check, value-preserving rewrite, single inequality) becomes broadly useful only
when paired with a **reduction principle** (induction, quotient to a finite ring,
selection of an extremal coordinate). The reduction is the mathematical insight;
the core is the mechanizable residue. Honest scoping is part of the contribution:
each tactic's limitation is stated, and in each case the limitation points at a
concrete, tractable upgrade.

1. **Complete decision for min-plus identities.** Extend `tropical_simp` with a
   case-split over the finitely many total orders of operands inside each $\min$,
   turning value-preserving normalization into a complete decision procedure for
   min-plus polynomial identities over $\mathbb{R}$.

2. **Per-disc Gershgorin upgrade.** Strengthen `eigenvalue_rowsum_bound` to the
   full Gershgorin union of discs by regrouping the diagonal term in the existing
   largest-coordinate argument — a one-line algebraic change to the certificate.

3. **Reflective `ZMod`-reduction tactic.** Package the identical chain
   `ZMod.intCast_zmod_eq_zero_iff_dvd → push_cast → decide` as a single
   reflective tactic parameterized by modulus $m$ and polynomial $f$, eliminating
   the per-instance boilerplate observed across $p = 5, 7$ and $m = 6$.

4. **Catalog integration.** Generalize the finite-residue checker to certify
   entry-point congruences $n \mid \mathrm{Fib}(\mathrm{rank}(n))$ underlying
   Carmichael/Fibonacci results, replacing range-based `native_decide` with a
   trusted `decide`-over-`ZMod` argument per prime power.

---

## 8. Conclusion

We have presented three sound, reusable proof-automation tactics together with
explicit soundness arguments and worked theorems. `number_theory_decide`
inherits soundness compositionally and serves as the finite checker inside
induction (`two_pow_gt_sq`) and modular reduction (`fermat_little_five`,
`fermat_little_seven`, `cube_sub_self_six`). `tropical_simp` is a value-preserving
normalizer certified by the distributive scalar-fold lemma plus semilattice laws.
`spectral_bound` is certified by the weak Gershgorin row-sum bound
`eigenvalue_rowsum_bound`. In every case we separated the mechanizable core from
the human-supplied reduction and recorded honest limitations alongside their
upgrade paths.
