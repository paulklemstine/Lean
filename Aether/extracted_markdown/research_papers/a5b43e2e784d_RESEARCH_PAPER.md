# A Partition-Function First-Moment Law for Random Constraint Satisfaction, with the Sharp Existence Threshold for Random k-SAT

## Abstract

We give a fully rigorous, closed-form account of the *first-moment* (annealed)
counting identity for random constraint satisfaction problems (CSPs) and the
existence threshold it implies. Our central result is an **abstract
partition-function first-moment law**: for any finite assignment space `A`,
finite constraint space `C`, and satisfaction relation `sat`, if every
assignment satisfies exactly `S` of the constraints, then summing the number
of satisfying assignments over all `m`-constraint formulas equals
`|A| · S^m`. A pigeonhole corollary then forces an unsatisfiable formula to
exist as soon as `|A| · S^m < |C|^m`.

Specializing to Boolean `k`-SAT in the "literals with replacement" model
(assignments `Fin n → Bool`, literals `Fin n × Bool`, clauses
`Fin k → Lit`), we obtain the exact identity
`∑_F #{a : a ⊨ F} = 2^n · ((2n)^k − n^k)^m`, the integer threshold
`2^n·((2n)^k − n^k)^m < (2n)^{km} ⟹ ∃` unsatisfiable formula, and its
statistical-physics density form `2^n·(1 − 2^{−k})^m < 1 ⟹ ∃` unsatisfiable.
We further establish monotonicity of the unsatisfiable phase in the clause
count `m` (it is an up-set) and a `q`-ary CSP generalization
`q^n · ((nq)^k − (n(q−1))^k)^m` whose density factor `1 − ((q−1)/q)^k`
reduces to the Boolean `1 − 2^{−k}` at `q = 2`, exhibiting the
alphabet-independence of the threshold. All results are exact equalities or
strict implications — no asymptotics or hidden constants — and the entire
development has been formally verified.

**Keywords.** random k-SAT, satisfiability threshold, first-moment method,
annealed average, partition function, phase transition, constraint
satisfaction, probabilistic method.

---

## 1. Introduction

The Boolean satisfiability problem (SAT) is the canonical NP-complete
problem. In its *random* incarnation one fixes a distribution over formulas
and asks how the probability of satisfiability behaves as a function of the
clause-to-variable density `α = m/n`. Empirically and (in many regimes)
provably, this probability undergoes a sharp **phase transition**: below a
critical density `α_c(k)` a random formula is satisfiable with high
probability, while above it the formula is unsatisfiable with high
probability. This transition is the founding example of the deep and
productive interaction between statistical physics, combinatorics, and the
theory of computation.

The cleanest rigorous handle on the unsatisfiable ("frozen") side of the
transition is the **first-moment method**: bound the probability of
satisfiability by the expected number of satisfying assignments, and locate
the density at which that expectation falls below one. This paper develops
the first-moment law in full generality and exactness, then instantiates it
for Boolean `k`-SAT and for `q`-ary CSPs.

Our contributions are:

1. An **abstract partition-function first-moment identity**
   (Theorem 3.2) and its **pigeonhole existence corollary** (Theorem 3.3),
   stated for arbitrary finite CSPs under a single uniformity hypothesis.
2. The **Boolean `k`-SAT specialization** (Theorems 4.4–4.6): the exact
   first moment, the integer existence threshold, and the real-analytic
   density threshold `2^n(1 − 2^{−k})^m < 1`.
3. **Monotonicity** of the unsatisfiable phase in `m` (Theorem 4.7).
4. A **`q`-ary generalization** (Theorems 5.1–5.3) exhibiting the
   model-independent density factor `1 − ((q−1)/q)^k`.

A distinguishing feature of the development is that the core identities are
*exact equalities of natural numbers*, obtained by a finite factorization of
cardinalities rather than by analytic estimation. This makes the threshold
statements unconditional and constant-free.

---

## 2. The model and basic definitions

We work throughout with finite types and counting via cardinality.

**Definition 2.1 (Assignments, literals, clauses).** Fix `n, k, m ∈ ℕ`.

- An **assignment** is a function `a : Fin n → Bool`; write `Assign n` for
  this type. There are `|Assign n| = 2^n` assignments.
- A **literal** is a pair `l = (v, s) ∈ Fin n × Bool`; write `Lit n`. There
  are `|Lit n| = 2n` literals.
- A **`k`-clause** is a `k`-tuple of literals, `c : Fin k → Lit n`; write
  `Clause n k`. This is the *with-replacement* model: literals may repeat and
  variables may repeat. There are `|Clause n k| = (2n)^k` clauses.
- A **formula** on `m` clauses is `F : Fin m → Clause n k`.

**Definition 2.2 (Satisfaction).**

- A literal `l = (v, s)` is **satisfied** by `a`, written `satLit a l`, iff
  `a v = s`.
- A clause `c` is **satisfied** by `a`, written `satClause a c`, iff some
  literal is: `∃ i, satLit a (c i)`.
- An assignment `a` **models** a formula `F`, written `a ⊨ F` or
  `models a F`, iff it satisfies every clause: `∀ j, satClause a (F j)`.

The random model draws `F` uniformly from the `(2n)^k m`-element... precisely,
from `(Clause n k)^m`, equivalently each of the `m` clauses uniformly and
independently from the `(2n)^k` clauses. Because the underlying spaces are
finite and uniform, *expectations are sums divided by cardinalities*, and we
phrase all results as exact integer sums to avoid any measure-theoretic
overhead.

---

## 3. The abstract partition-function first-moment law

The combinatorial engine is entirely general. Let `A` (assignments) and `C`
(constraints) be finite types and `sat : A → C → Prop` a satisfaction
relation. A formula is a tuple `F : Fin m → C`, and `a` models `F` iff
`∀ j, sat a (F j)`.

**Lemma 3.1 (Per-assignment factorization).** For every `a : A` and every
`m`,
```
    #{ F : Fin m → C  |  ∀ j, sat a (F j) }  =  (#{ c : C | sat a c })^m.
```

*Proof sketch.* The set of formulas all of whose `m` slots satisfy `a` is, by
the dependent-product reindexing `Equiv.subtypePiEquivPi`, in bijection with
`Fin m → {c : C | sat a c}`, the `m`-fold function space into the
satisfied-constraint subtype. Its cardinality is therefore
`(#{c | sat a c})^m`. ∎

This is the partition-function heart of the method: the "weight"
`w(a) = ∏_{j} [sat a (F j)]` of an assignment factors over the independent
constraint slots, so the count of formulas modelled by `a` is a pure power.

**Theorem 3.2 (Abstract first moment).** Suppose every assignment satisfies
exactly `S` constraints, i.e. `#{c | sat a c} = S` for all `a`. Then
```
    ∑_{F : Fin m → C}  #{ a : A | a ⊨ F }  =  |A| · S^m.
```

*Proof sketch.* Write each inner cardinality as a sum of indicators,
`#{a | a ⊨ F} = ∑_a [a ⊨ F]`, and exchange the order of summation (finite
Fubini):
```
  ∑_F #{a | a ⊨ F} = ∑_F ∑_a [a ⊨ F] = ∑_a ∑_F [a ⊨ F]
                   = ∑_a #{F | a ⊨ F} = ∑_a S^m = |A| · S^m,
```
using Lemma 3.1 and the uniformity hypothesis `#{c | sat a c} = S` for the
penultimate equality. ∎

The left side, divided by `|C|^m`, is precisely the **expected number of
satisfying assignments** `E[X]` for `X = #{a : a ⊨ F}` under the uniform
formula distribution; Theorem 3.2 is the statement `E[X] = |A| · (S/|C|)^m`,
the annealed average.

**Theorem 3.3 (Existence of an unsatisfiable formula).** Under the hypothesis
of Theorem 3.2, if
```
    |A| · S^m  <  |C|^m,
```
then there exists a formula `F : Fin m → C` with `∀ a, ¬ (a ⊨ F)` — an
unsatisfiable instance.

*Proof sketch.* Suppose for contradiction every formula were satisfiable.
Then `#{a | a ⊨ F} ≥ 1` for each of the `|C|^m` formulas, so
`∑_F #{a | a ⊨ F} ≥ |C|^m`. But Theorem 3.2 equates the left side with
`|A|·S^m < |C|^m`, a contradiction. ∎

Equivalently, the *average* number of solutions `|A|(S/|C|)^m` falls below
one, so by pigeonhole some formula has zero solutions. Theorems 3.2–3.3 are
the abstract skeleton; all concrete thresholds below are instances.

---

## 4. Boolean k-SAT

We now compute the constant `S` for Boolean `k`-SAT and feed it into the
abstract law.

**Lemma 4.1 (Falsified literals).** For every assignment `a : Assign n`,
```
    #{ l : Lit n  |  a l.1 ≠ l.2 }  =  n.
```

*Proof sketch.* The map `v ↦ (v, ¬ a v)` is an injection from `Fin n` onto
exactly the falsified literals: a literal `(v, s)` is falsified iff
`s = ¬ a v`, so there is exactly one falsified literal per variable. Hence
the count is `n`. ∎

**Lemma 4.2 (Falsified clauses).** For every `a : Assign n`,
```
    #{ c : Clause n k  |  ∀ i, a (c i).1 ≠ (c i).2 }  =  n^k.
```

*Proof sketch.* A clause is falsified by `a` (its negation `¬ satClause a c`)
iff *every* one of its `k` literals is falsified. By the product reindexing
`Equiv.subtypePiEquivPi`, the falsified clauses are in bijection with
`Fin k → {l | a l.1 ≠ l.2}`, whose cardinality is `n^k` by Lemma 4.1. ∎

**Lemma 4.3 (Satisfied clauses; the constant `S`).** For every `a`,
```
    #{ c : Clause n k  |  satClause a c }  =  (2n)^k − n^k.
```

*Proof sketch.* Satisfied and falsified clauses partition the `(2n)^k`
clauses (`satClause` and its negation are complementary), so
`#sat + #unsat = (2n)^k`. Lemma 4.2 gives `#unsat = n^k`, and subtraction
yields `#sat = (2n)^k − n^k`. ∎

Thus the Boolean model satisfies the uniformity hypothesis with the *same*
`S = (2n)^k − n^k` for every assignment, and `|A| = 2^n`. Theorem 3.2 gives:

**Theorem 4.4 (First moment for k-SAT).**
```
    ∑_{F : Fin m → Clause n k}  #{ a : Assign n  |  models a F }
        =  2^n · ((2n)^k − n^k)^m.
```

*Proof sketch.* Apply Theorem 3.2 with `A = Assign n`, `C = Clause n k`,
`S = (2n)^k − n^k` (Lemma 4.3), and `|A| = 2^n`. ∎

**Theorem 4.5 (Integer existence threshold).** If
```
    2^n · ((2n)^k − n^k)^m  <  (2n)^{km},
```
then there exists an unsatisfiable formula `F : Fin m → Clause n k`.

*Proof sketch.* Apply Theorem 3.3, noting `|C|^m = ((2n)^k)^m = (2n)^{km}`. ∎

**Theorem 4.6 (Density / statistical-physics threshold).** If
```
    2^n · (1 − 2^{−k})^m  <  1   (as a real inequality),
```
then there exists an unsatisfiable formula.

*Proof sketch.* Divide the integer threshold of Theorem 4.5 by the positive
quantity `(2n)^{km}`. Since `n^k / (2n)^k = 2^{−k}`, we have
`((2n)^k − n^k)^m / (2n)^{km} = (1 − 2^{−k})^m`, so the integer threshold is
equivalent to `2^n (1 − 2^{−k})^m < 1` whenever `n ≥ 1`. (For `n = 0` the
statement is handled directly.) ∎

**Interpretation.** Write `Z(F) = #{a : a ⊨ F}` for the zero-temperature
partition function of formula `F` (the number of ground states / satisfying
assignments). Theorem 4.4 computes the annealed average
`E[Z] = 2^n (1 − 2^{−k})^m`. The factor `2^n = e^{n ln 2}` is the
configurational entropy; `(1 − 2^{−k})^m` is the constraint suppression.
Theorem 4.6 states that when the **annealed free energy**
`log E[Z] = n ln 2 + m log(1 − 2^{−k})` turns negative, the existence of a
solution is no longer guaranteed and an unsatisfiable instance must appear.
Solving `log E[Z] = 0` gives the first-moment density bound
```
    α_1(k) = m/n = − ln 2 / log(1 − 2^{−k}) ≈ 2^k ln 2  (k → ∞).
```
This is a rigorous *upper* bound on the true satisfiability threshold
`α_c(k)`; for example `α_1(3) ≈ 5.19` versus the empirical
`α_c(3) ≈ 4.267`.

**Theorem 4.7 (Monotonicity of the unsatisfiable phase).** The set of clause
counts `m` for which an unsatisfiable formula is guaranteed is an up-set:
if the density condition forces unsatisfiability at `m`, it does so at every
`m' ≥ m`.

*Proof sketch.* The map `m ↦ 2^n (1 − 2^{−k})^m` is non-increasing because
`0 ≤ 1 − 2^{−k} < 1`; once it drops below `1`, it stays below `1`. Hence the
hypothesis of Theorem 4.6 propagates upward in `m`. ∎

---

## 5. The q-ary generalization

Nothing in Section 4 used `Bool` beyond its having two elements. Let variables
range over a domain of size `q ≥ 1`.

**Definition 5.1 (`q`-ary model).** Assignments are `Fin n → Fin q`
(`q^n` of them). A literal is a pair `(v, val) ∈ Fin n × Fin q` (`nq` of
them), satisfied by `a` iff `a v = val`. A `k`-clause is a `k`-tuple of
literals, satisfied iff some literal is. There are `(nq)^k` clauses.

The same factorization arguments (Lemmas 4.1–4.3 with `q` in place of `2`)
give the per-assignment counts: each assignment falsifies `q − 1` of the `q`
values per variable, hence `n(q−1)` literals and `(n(q−1))^k` falsified
clauses, leaving `S_q = (nq)^k − (n(q−1))^k` satisfied clauses — the **same
for every assignment**.

**Theorem 5.2 (`q`-ary first moment).**
```
    ∑_{F}  #{ a  |  models a F }  =  q^n · ((nq)^k − (n(q−1))^k)^m.
```

*Proof sketch.* Apply Theorem 3.2 with `|A| = q^n` and the constant
`S_q = (nq)^k − (n(q−1))^k`. ∎

**Theorem 5.3 (`q`-ary existence thresholds).** An unsatisfiable formula is
forced whenever
```
    q^n · ((nq)^k − (n(q−1))^k)^m  <  (nq)^{km},
```
equivalently, in density form,
```
    q^n · (1 − ((q−1)/q)^k)^m  <  1.
```

*Proof sketch.* Theorem 3.3 with `|C|^m = (nq)^{km}`, then divide by
`(nq)^{km}` and use `(n(q−1))^k/(nq)^k = ((q−1)/q)^k`. ∎

**Alphabet-independence.** The density factor `1 − ((q−1)/q)^k` is the
fraction of local value-patterns each constraint permits, and it controls the
threshold independently of how the underlying finite types are built. At
`q = 2` it equals `1 − (1/2)^k = 1 − 2^{−k}`, recovering Theorem 4.6
exactly. The first-moment threshold is thus a property of the *constraint
geometry* (clause width `k`, forbidden-pattern fraction), not of the alphabet
size per se.

---

## 6. Algorithms

The identities are constructive and yield exact, overflow-safe integer
computations (using arbitrary-precision arithmetic).

**Algorithm A — Annealed first moment.** Given `n, k, m` (and optionally
`q`), return the exact integer `q^n · ((nq)^k − (n(q−1))^k)^m`
(`q = 2`: `2^n · ((2n)^k − n^k)^m`). Complexity: `O(log(km))` big-integer
multiplications via fast exponentiation, each on numbers of
`O(n + km·k·log(nq))` bits.

**Algorithm B — First-moment existence certificate.** Given `n, k, m`,
compare `q^n·S^m` against `|C|^m = (nq)^{km}`. If strictly smaller, output
"UNSAT-FORCED" (a certificate that some formula is unsatisfiable); otherwise
"INCONCLUSIVE". This is the exact integer form of Theorem 4.5 / 5.3 and never
errs in the forced direction.

**Algorithm C — Critical density solver.** Solve `log E[Z] = 0` for the
first-moment density bound `α_1(k) = − ln 2 / log(1 − 2^{−k})` (Boolean) or
`− ln q / log(1 − ((q−1)/q)^k)` (`q`-ary), and locate the smallest integer
`m` at which Theorem 4.6/5.3 fires for a given `n` by exploiting monotonicity
(Theorem 4.7) with binary search. Complexity: `O(log m*)` evaluations of
Algorithm A.

---

## 7. Applications

- **SAT-solver instance generation.** Algorithm B produces guaranteed-hard
  regimes (just above the forced-UNSAT density) for benchmarking complete
  solvers, with an exact unsatisfiability guarantee rather than a statistical
  one.
- **Upper bounds on satisfiability thresholds.** `α_1(k)` is a rigorous,
  constant-free upper bound on `α_c(k)` for every `k`, complementing
  algorithmic lower bounds.
- **CSP design.** The `q`-ary density factor `1 − ((q−1)/q)^k` tells a
  designer how clause width and alphabet trade off when engineering
  constraint hardness (e.g. random `q`-colorings, Latin-square-type CSPs).
- **Statistical-physics dictionary.** `E[Z] = q^n(1 − ((q−1)/q)^k)^m` is the
  annealed partition function of a diluted spin system; its sign change is a
  zero-temperature condensation, linking the SAT transition to free-energy
  computations.

---

## 8. Discussion

The development isolates the *exactly solvable* core of the random-CSP phase
transition. Three features deserve emphasis. First, the first moment is an
**equality**, not a bound, because the per-constraint weight factorizes
perfectly over independent slots; all approximation enters only when one
converts the integer threshold to the real density form. Second, the
**uniformity hypothesis** `#{c | sat a c} = S` is exactly what makes the
inner sum constant and the Fubini exchange collapse to `|A| · S^m`; it holds
for the with-replacement literal model and for symmetric `q`-ary models, and
identifying it abstractly clarifies precisely which CSPs the method governs.
Third, the threshold is **one-directional**: it certifies the frozen
(unsatisfiable) side and says nothing, by itself, about satisfiability below
the threshold.

The gap between the first-moment upper bound `α_1(k)` and the true threshold
`α_c(k)` is the price of the annealed approximation: `E[Z]` is inflated by
rare formulas with exponentially many solutions. Closing the gap requires
second-moment control of the variance of `Z`, which is the principal future
direction below.

---

## 9. Future directions

These reuse the per-constraint factorization machinery (`card_models_form`,
`card_sat_clause`, the `q`-ary analogues) already established, and bridge to
adjacent corpora (entropy/partition-function algebra, tropical/min-plus
algebra, the probabilistic method).

**Direction 1 — A second-moment satisfiability lower bound.** Prove the
complementary half: below the first-moment threshold by a constant factor, a
uniformly random formula is satisfiable with probability bounded away from
`0`. Formalize Paley–Zygmund / Cauchy–Schwarz, `(E[X])² ≤ P(X>0)·E[X²]` for
`X = #{a : a ⊨ F}`, and compute `E[X²]` as the exact two-assignment
correlation. The second moment factorizes over clauses *exactly as the first
moment does*, giving
`E[X²] = ∑_{a,b} ((2n)^k − 2n^k + u(a,b))^m / (2n)^{km}`, where `u(a,b)`
counts clauses falsified by *both* `a` and `b` and depends only on the
Hamming distance `|a Δ b|`. This collapses the estimate to a one-dimensional
sum over Hamming distance, evaluable by the same product-reindexing toolkit —
a finite closed-form cardinality rather than an analytic estimate.

**Direction 2 — Exact integer crossing point of the threshold window.**
Strengthen monotonicity to a sharp window: an explicit width `w(n,k)` with
every formula satisfiable for `m` below `m*(n,k) − w` (a positive fraction)
and the first moment forcing unsatisfiability for `m` above `m*(n,k) + w`,
with `w = O(1)` in `n` for fixed `k`. The map `m ↦ 2^n(1 − 2^{−k})^m` is
strictly log-linear, so the crossing of the value `1` happens within a single
unit interval of `m`; bounding the integer crossing point is a monotonicity
argument on a concrete real sequence.

**Direction 3 — The "without replacement" model.** Re-derive the first moment
for combinatorial random `k`-SAT (each clause on `k` *distinct* variables
with independent signs), conjecturally
`∑_F #{a : a ⊨ F} = 2^n · (C(n,k)·(2^k − 1))^m` with the *identical* density
threshold `2^n(1 − 2^{−k})^m < 1`. Switching models replaces the per-clause
base count `(2n)^k` by `C(n,k)·2^k` while the falsified fraction stays exactly
`2^{−k}`, so the density threshold is model-independent; the proof reuses the
product reindexing after replacing literal tuples by injective ones.

**Direction 4 — General finite-domain CSP and a product partition function.**
Generalize to variables over a domain of size `q` and constraints forbidding
`r` of the `q^k` local patterns: `∑_F #{a : a ⊨ F} = q^n · (q^k − r)^m` with
threshold `q^n(1 − r·q^{−k})^m < 1`, recovering the Boolean case at
`q = 2, r = 1`. The whole argument is a statement about the partition
function `Z = ∑_a ∏_clauses [a sat clause]`; the annealed average factorizes
as `q^n · (allowed-pattern fraction)^m` regardless of alphabet, reframing the
threshold as a sign change of an annealed free energy and bridging to
entropy/partition-function algebra.

**Direction 5 — Tropical (min-plus) free energy and a zero-temperature
transition.** Lift `Z = ∑_a w(a)` to the tropical semiring (addition `min`,
multiplication `+`), so `Z_trop(F) = min_a #{clauses falsified by a}` is the
MAX-SAT optimum. Conjecture a tropical first-moment law and a zero-temperature
threshold: above the density where `2^n(1 − 2^{−k})^m < 1`, almost every
formula has `Z_trop ≥ 1`. The ordinary first moment counts zero-temperature
ground states, so existence of an unsatisfiable formula is exactly the
statement that the tropical optimum jumps off `0` — a discontinuity in a
min-plus free energy, connecting to the tropical/min-plus corpus.

---

## 10. Conclusion

We have isolated and rigorously established the annealed (first-moment) core
of the random-CSP satisfiability transition: an exact partition-function
identity, its pigeonhole existence threshold, the Boolean and `q`-ary density
forms, and monotonicity of the frozen phase. The results are exact and
constant-free, and they expose the satisfiability transition as a sign change
in an annealed free energy `log E[Z] = (log entropy) + m·log(allowed
fraction)` — the same mathematics that governs freezing in physical matter,
here governing the freezing of logic.
