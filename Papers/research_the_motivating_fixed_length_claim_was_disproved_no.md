# Finite Truth Tables and the Boundary of Diagonal Arguments

## Abstract

We give a precise account of when an all-answering oracle for a language of
statements exists and when it provably cannot. Fixing a finite alphabet and a
length bound yields a finite space of statements; for any assignment of truth
values to that space there is an oracle that answers every statement correctly,
and hence clears any fixed accuracy benchmark such as $95\%$. This *pointwise*
existence result is elementary and is a consequence of finiteness alone. We
then show that three natural strengthenings each fail or change character in an
instructive way. First, no single oracle can be $95\%$ accurate against *every*
semantics on a nonempty finite domain: an adversary who defines truth in
response to the oracle drives its accuracy to zero, exposing a quantifier
reversal. Second, on an infinite (natural-number-indexed) family of Boolean
sequences, a diagonal-complement sequence escapes the family entirely, so no
countable enumeration is surjective onto the space of Boolean sequences. Third,
the finite analogue of the diagonal argument on an $n \times n$ table is a pure
counting statement — $n$ rows cannot realize all $2^n$ patterns — and carries
none of the noncomputable force of its infinite counterpart. Together these
results form a single, sharply delimited hierarchy that separates *finite
tabulation*, *uniform robustness*, and *diagonal escape*. We are careful to
distinguish existence from feasibility, semantic truth from provability,
pointwise from uniform accuracy, and counting from diagonalization. The
motivating claim that a fixed-length prediction oracle must be noncomputable is
thereby **disproved**; what survives is an exact finite counterexample, a
uniform adversarial impossibility, explicit cardinality formulas, and an
elementary Cantor-style diagonal theorem.

**Keywords.** finite truth table, diagonalization, Cantor's theorem, oracle,
quantifier order, three-valued logic, abstention, bounded language,
computability boundary.

## 1. Introduction

A recurring and seductive claim holds that human mathematical intuition, or a
sufficiently powerful prediction machine, must transcend computation — that
answering arbitrary questions correctly is a noncomputable feat. The claim is
often illustrated with a fixed-length setup: statements are strings of bounded
length over a finite alphabet, and a machine is asked to judge each one true or
false with high accuracy.

The purpose of this paper is to isolate exactly what is and is not true in such
a setup, with all claims stated so precisely that each is either a theorem or a
refuted conjecture. Our central observation is deflationary: **on a bounded
language the perfect oracle always exists**, because the domain is finite and
an exact answer table can be written down. The motivating noncomputability
claim, taken literally for a fixed length bound, is therefore false.

Deflation is not the end of the story. The same finiteness that makes the
pointwise oracle trivial makes the *uniform* oracle impossible, and the
genuinely infinitary content of Cantor's diagonal argument survives untouched.
The contribution of this paper is to lay these facts side by side as a single
hierarchy and to name, at each step, the exact modelling distinction that
governs the outcome.

The distinctions we insist upon are:

1. **Finite domain versus practical feasibility.** A truth table can be
   astronomically large yet computable; complexity, storage, learnability, and
   computability are distinct notions.
2. **Semantic truth versus provability.** For bounded strings a fixed external
   truth assignment has a finite table; for all arithmetic sentences, truth and
   theoremhood lead to genuinely unbounded questions.
3. **Pointwise versus uniform accuracy.** A good oracle for one fixed semantics
   is compatible with the nonexistence of one predictor that works for every
   semantics.
4. **Scoring of abstention.** We count "unknown" as incorrect; alternative
   scoring rules must be stated explicitly and may change finite accuracy
   bounds, though not the finite-table counterexample.
5. **Counting versus diagonalization.** Counting finite functions yields only
   exponential cardinalities; noncomputability requires an unbounded effective
   presentation together with a diagonal or reduction argument.

## 2. The bounded language of statements

We model statements as fixed-length words over a finite alphabet, following the
familiar "Library of Babel" picture in which all strings of a bounded length
are collected into a single finite space.

**Definition 2.1 (Statement space).** Fix natural numbers $a$ (the *alphabet
size*) and $\ell$ (the *length*). A **statement** is a word of length $\ell$
over an alphabet of $a$ symbols. Write $\mathcal{S}_{a,\ell}$ for the set of all
such statements.

**Proposition 2.2 (Cardinality of the statement space).** The statement space is
finite, with
$$\lvert \mathcal{S}_{a,\ell} \rvert = a^{\ell}.$$

*Proof sketch.* A word of length $\ell$ is a function from an $\ell$-element
index set to an $a$-element alphabet; the number of such functions is
$a^{\ell}$. In particular the space is finite for all $a, \ell$. $\square$

The finiteness in Proposition 2.2 is the load-bearing hypothesis of the entire
development. Everything in Section 3 flows from it; everything in Sections 4–5
concerns what happens when it is dropped or when a *universal* quantifier is
placed outside it.

**Definition 2.3 (Answers).** An **answer** is one of three values:
$\mathsf{yes}$, $\mathsf{no}$, or $\mathsf{unknown}$. The map from Booleans to
definite answers sends $\mathsf{true} \mapsto \mathsf{yes}$ and
$\mathsf{false} \mapsto \mathsf{no}$; write $\beta$ for this map.

**Definition 2.4 (Semantics and oracle).** A **semantics** on a set $X$ is a
function $\tau : X \to \{\mathsf{true}, \mathsf{false}\}$ assigning a Boolean
truth value to each element. An **oracle** on $X$ is a function
$\omega : X \to \{\mathsf{yes}, \mathsf{no}, \mathsf{unknown}\}$.

**Definition 2.5 (Correctness and accuracy).** An oracle $\omega$ is
**correct** on $x$ under semantics $\tau$ if
$$\omega(x) = \beta(\tau(x)).$$
Abstention is never correct: if $\omega(x) = \mathsf{unknown}$ then $\omega$ is
incorrect on $x$ under every semantics. For a finite domain $X$, the
**correct count** is
$$C(\tau, \omega) = \bigl\lvert \{ x \in X : \omega(x) = \beta(\tau(x)) \} \bigr\rvert.$$
An oracle **meets the $95\%$ benchmark** under $\tau$ when
$$95 \cdot \lvert X \rvert \le 100 \cdot C(\tau, \omega).$$

We use the integer form $95\lvert X\rvert \le 100\,C$ rather than a rational
inequality to keep the accuracy condition purely arithmetical; it is equivalent
to $C/\lvert X\rvert \ge 0.95$.

## 3. Pointwise existence: the perfect finite oracle

**Definition 3.1 (Exact oracle).** Given a semantics $\tau$, the **exact
oracle** is $\varepsilon_\tau(x) = \beta(\tau(x))$.

**Lemma 3.2 (Pointwise exactness).** For every semantics $\tau$ and every $x$,
the exact oracle $\varepsilon_\tau$ is correct on $x$.

*Proof sketch.* By definition $\varepsilon_\tau(x) = \beta(\tau(x))$, which is
exactly the correctness condition. $\square$

**Lemma 3.3 (Total correctness on a finite domain).** For a finite domain $X$
and any semantics $\tau$,
$$C(\tau, \varepsilon_\tau) = \lvert X \rvert.$$

*Proof sketch.* By Lemma 3.2 the correctness predicate holds for every
$x \in X$, so the filtered subset is all of $X$, and its cardinality is
$\lvert X \rvert$. $\square$

**Theorem 3.4 (Perfect Finite Oracle).** For any finite bounded language
$\mathcal{S}_{a,\ell}$ and any semantics $\tau$ on it, there exists an oracle
meeting the $95\%$ benchmark. In fact the exact oracle is correct on every
statement, so
$$95 \cdot a^{\ell} \le 100 \cdot C(\tau, \varepsilon_\tau).$$

*Proof sketch.* Take $\omega = \varepsilon_\tau$. By Lemma 3.3,
$C(\tau, \varepsilon_\tau) = \lvert \mathcal{S}_{a,\ell}\rvert = a^{\ell}$, so
the benchmark reads $95 a^{\ell} \le 100 a^{\ell}$, which holds. $\square$

Theorem 3.4 refutes, for a fixed length bound, the claim that a highly accurate
truth oracle cannot exist. The oracle not only meets the benchmark but is
perfectly accurate; the benchmark $95\%$ is arbitrary and could be $100\%$.

Existence should not be mistaken for feasibility. The next result makes the
oracle's structure explicit — it is a finite lookup table — and simultaneously
underscores why existence is cheap while construction may be prohibitive.

**Theorem 3.5 (Finite tabulation).** Every oracle $\omega$ on a finite bounded
language is completely described by a finite list of $(\text{statement},
\text{answer})$ pairs; that is, there is a finite table $T$ such that for every
statement $x$ the pair $(x, \omega(x))$ occurs in $T$.

*Proof sketch.* Enumerate the finitely many statements and map each to the pair
$(x, \omega(x))$. The resulting finite list contains $(x, \omega(x))$ for every
$x$ by construction. $\square$

**Remark 3.6 (Existence is not feasibility).** Theorem 3.5 says the oracle *is*
a finite object, but its size is $a^{\ell}$ rows. For $a = 26$, $\ell = 100$
this exceeds $10^{141}$, far beyond any physical storage. Computability of a
finite function is automatic; tractability is a separate question that
finiteness does not address. This is distinction (1) of the introduction.

## 4. Uniform impossibility: the adversarial semantics

Theorem 3.4 fixes the semantics first and then produces an oracle. Reversing
the quantifiers — asking for one oracle that works against *every* semantics —
changes the truth value of the statement.

**Definition 4.1 (Adversarial semantics).** Given an oracle $\omega$ on a set
$X$, the **adversarial semantics** $\alpha_\omega$ is defined by responding to
each of the oracle's answers so as to falsify it:
$$
\alpha_\omega(x) =
\begin{cases}
\mathsf{false} & \text{if } \omega(x) = \mathsf{yes},\\
\mathsf{true} & \text{if } \omega(x) = \mathsf{no},\\
\mathsf{true} & \text{if } \omega(x) = \mathsf{unknown}.
\end{cases}
$$

**Lemma 4.2 (Pointwise adversarial failure).** For every oracle $\omega$ and
every $x$, the oracle is incorrect on $x$ under $\alpha_\omega$.

*Proof sketch.* Case on $\omega(x)$. If $\omega(x) = \mathsf{yes}$ then
$\alpha_\omega(x) = \mathsf{false}$, whose definite answer is $\mathsf{no}
\ne \mathsf{yes}$. If $\omega(x) = \mathsf{no}$ then $\alpha_\omega(x) =
\mathsf{true}$, whose definite answer is $\mathsf{yes} \ne \mathsf{no}$. If
$\omega(x) = \mathsf{unknown}$ then $\omega(x)$ is never a definite answer, so it
cannot equal $\beta(\alpha_\omega(x))$. In every case correctness fails.
$\square$

**Theorem 4.3 (No Universal Oracle).** Let $X$ be a nonempty finite set. Then
there is no oracle $\omega$ on $X$ that meets the $95\%$ benchmark against every
semantics; formally, there is no $\omega$ with
$$95 \cdot \lvert X \rvert \le 100 \cdot C(\tau, \omega) \quad \text{for all } \tau.$$

*Proof sketch.* Suppose such an $\omega$ existed. Apply the hypothesis with
$\tau = \alpha_\omega$. By Lemma 4.2 the oracle is incorrect on every $x$, so
$C(\alpha_\omega, \omega) = 0$. The benchmark then requires
$95 \lvert X \rvert \le 0$, contradicting $\lvert X \rvert > 0$ (which holds
because $X$ is nonempty finite). $\square$

**Remark 4.4 (Quantifier order).** Theorems 3.4 and 4.3 are compatible: "for
each $\tau$ there is a good $\omega$" is true, while "there is a $\omega$ good
for every $\tau$" is false. The two statements differ only in the order of the
quantifiers $\forall\tau$ and $\exists\omega$. This is distinction (3): pointwise
accuracy does not entail uniform accuracy. It also shows the essential role of
distinction (4): because abstention is scored as incorrect, even the constant
$\mathsf{unknown}$ oracle scores zero against $\alpha_\omega$, so no amount of
hedging rescues uniformity.

## 5. Diagonalization: finite echo and infinite force

The final layer concerns whether the space of truth-behaviours can be
enumerated. Here Cantor's diagonal argument enters, and here the distinction
between counting and diagonalization (distinction (5)) becomes visible.

### 5.1 The finite diagonal is counting

**Definition 5.1 (Finite diagonal).** For an $n \times n$ Boolean table
$R : \{0,\dots,n-1\}^2 \to \{\mathsf{true},\mathsf{false}\}$, viewed as $n$ rows
$R_i = R(i, \cdot)$, the **finite diagonal** is the length-$n$ sequence
$$D(i) = \lnot R(i, i).$$

**Theorem 5.2 (Finite diagonal escape).** For any $n \times n$ Boolean table
$R$ and any row index $i$, the finite diagonal differs from row $R_i$; formally
$D \ne R_i$. Consequently the $n$ rows cannot realize all $2^n$ Boolean patterns
on an $n$-element domain: no assignment of rows to patterns is surjective.

*Proof sketch.* If $D = R_i$ then evaluating both sides at coordinate $i$ gives
$\lnot R(i,i) = R(i,i)$, impossible for a Boolean value. Hence $D$ differs from
every row, so the map $i \mapsto R_i$ misses at least one pattern (namely one
extending $D$), and cannot be surjective onto the $2^n$ patterns — including the
degenerate case $n = 0$, where there are no rows and yet one empty pattern to
hit. $\square$

**Remark 5.3 (Only counting).** Theorem 5.2 has no computational content: it
says $n < 2^n$ in disguise, an inequality between finite cardinalities. Nothing
about hardness, undecidability, or noncomputability follows. This is the finite
face of diagonalization.

### 5.2 The infinite diagonal escapes every enumeration

**Definition 5.4 (Diagonal jump).** For a natural-number-indexed table
$R : \mathbb{N} \times \mathbb{N} \to \{\mathsf{true},\mathsf{false}\}$, viewed
as a sequence of rows $R_k = R(k, \cdot)$, the **diagonal jump** is the Boolean
sequence
$$J(k) = \lnot R(k, k).$$

**Theorem 5.5 (Diagonal escape).** For any indexed family $(R_k)_{k \in
\mathbb{N}}$ of Boolean sequences and any $k$, the diagonal jump differs from
$R_k$ at coordinate $k$, hence $J \ne R_k$. Therefore the family is not
surjective onto the space of all Boolean sequences: no countable list of Boolean
sequences contains every Boolean sequence.

*Proof sketch.* If $J = R_k$, evaluate at coordinate $k$ to obtain
$\lnot R(k,k) = R(k,k)$, a contradiction. Thus $J$ differs from every row, so
$J$ is a Boolean sequence outside the enumerated family, refuting surjectivity.
$\square$

**Remark 5.6 (What the jump does and does not capture).** Theorem 5.5 captures
the structural core of jump constructions — a uniformly defined object that
diagonalizes out of any indexed family. It is deliberately *not* a formalization
of the Turing jump: no machine model, halting problem, or relativized
computation is invoked. The gap between "diagonalizes out of every countable
family" and "is not computable from a given oracle" is exactly the gap between
this elementary theorem and computability theory proper, and bridging it
requires an effective presentation of the family plus a reduction (see
Section 7).

## 6. Discussion: a hierarchy of sharply delimited claims

Collecting the results, we obtain a graded picture in which each rung is
governed by a single modelling choice.

- **Rung 1 (Theorem 3.4, 3.5).** *Fix a semantics, bound the length.* A perfect
  oracle exists and is a finite table. Existence is free; feasibility is not
  addressed. Governed by finiteness (distinction 1) and by the choice to fix
  truth first (distinction 2).
- **Rung 2 (Theorem 4.3).** *Demand one oracle for all semantics.* Impossible on
  any nonempty finite domain. Governed by quantifier order (distinction 3) and
  the scoring of abstention (distinction 4).
- **Rung 3 (Theorem 5.2).** *Diagonalize a finite square table.* Escape holds,
  but as a counting fact ($n < 2^n$) with no computational force. Governed by
  distinction 5 on the finite side.
- **Rung 4 (Theorem 5.5).** *Diagonalize an infinite family.* Escape holds with
  full force: no countable enumeration of Boolean sequences is complete.
  Governed by distinction 5 on the infinite side.

The overarching lesson is that the informal claim "a highly accurate universal
truth oracle cannot exist" fragments, under precise statement, into one true
elementary existence theorem, one true uniform impossibility, one true counting
fact, and one true infinitary escape — none of which is the sweeping
noncomputability claim originally advertised.

## 7. Applications

**7.1 Auditing accuracy claims.** Any assertion that a predictor is "$p\%$
accurate" is incomplete without (i) a specified finite benchmark or probability
measure over statements, and (ii) a scoring rule for abstention. Rung 1 shows
$100\%$ is attainable in principle on any fixed finite benchmark; Rung 2 shows
that dropping the fixed benchmark and quantifying over all semantics makes even
$95\%$ unattainable. The framework thus operationalizes the questions one must
ask before accepting an accuracy figure.

**7.2 Robustness and adversarial evaluation.** Definition 4.1 is a template for
worst-case evaluation: to test a fixed predictor, define the label in response
to its answers. Theorem 4.3 shows that against a fully adaptive adversary no
fixed deterministic predictor is robust, motivating restrictions on the
adversary (bounded, distributional, or oblivious) in any meaningful robustness
guarantee.

**7.3 Enumeration and coverage.** Theorem 5.5 is the reason no countable
"knowledge base" of yes/no behaviours can be complete: some behaviour is always
diagonalized out. This bears on claims that a finite or countable corpus
"contains everything," and clarifies that coverage of an uncountable behaviour
space is impossible in principle, independent of resources.

## 8. Algorithms

We record the constructive content of the theorems as algorithms; each is
elementary but pins down the exact objects involved.

**Algorithm A (Exact oracle construction).** *Input:* finite statement space
$\mathcal{S}$, semantics $\tau$. *Output:* an oracle correct on all of
$\mathcal{S}$. For each $x \in \mathcal{S}$, set $\omega(x) = \mathsf{yes}$ if
$\tau(x) = \mathsf{true}$, else $\omega(x) = \mathsf{no}$. Returns a perfect
oracle in $O(\lvert\mathcal{S}\rvert)$ evaluations of $\tau$. Realizes
Theorems 3.4 and 3.5.

**Algorithm B (Adversarial semantics construction).** *Input:* oracle $\omega$,
domain $X$. *Output:* a semantics $\alpha_\omega$ under which $\omega$ is wrong
everywhere. For each $x$, return $\mathsf{false}$ if $\omega(x) = \mathsf{yes}$,
else $\mathsf{true}$. Certifies Theorem 4.3 by yielding correct count $0$.

**Algorithm C (Diagonal jump).** *Input:* indexed Boolean table $R$ (finite
$n\times n$ or infinite), a coordinate range. *Output:* the diagonal-complement
sequence $J(k) = \lnot R(k,k)$. Certifies Theorems 5.2 and 5.5 by construction.

## 9. Future work

Several directions sharpen or extend the boundary mapped here.

1. **Arithmetic truth as an unbounded limit of bounded tables.** For a concrete
   first-order arithmetic with standard-model satisfaction, each length-bounded
   fragment has a finite exact table, yet plausibly no single computable
   procedure produces all of these tables uniformly. Each finite stage is
   harmless; uniformity across stages can encode the full unbounded truth
   problem.
2. **Quantitative advice lower bounds.** For length-$n$ binary statements, any
   family of predictors realizing every semantics exactly should require at
   least $2^n$ bits of worst-case advice; under a $95\%$ Hamming-accuracy
   requirement, optimal advice length should be governed by the volume of
   radius-$0.05$ Hamming balls, connecting the problem to covering codes.
3. **Sound abstention under coverage constraints.** If definite answers must be
   sound and the oracle must answer on at least a fixed positive fraction of a
   rich benchmark, no computable oracle should meet the requirement uniformly
   over all length bounds — making abstention nonvacuous only when paired with a
   coverage lower bound.
4. **A concrete relativized jump.** A partial-recursive oracle-machine model
   should admit a genuine jump operator whose iterates strictly embed the
   naturals into the Turing degrees, upgrading the combinatorial diagonal of
   Theorem 5.5 to reducibility statements via a universal relativized machine.
5. **Distribution-sensitive limits.** Under computably samplable full-support
   distributions on arithmetic sentences of growing length, no computable
   predictor should be uniformly $95\%$ accurate — replacing the ambiguous
   "accuracy" with a measure-theoretic benchmark.

## 10. Limits of the present results

This development does not identify human intuition with a noncomputable
operation, and provides no evidence for that identification. It proves only a
precise finite counterexample (Theorem 3.4), an explicit tabulation (Theorem
3.5), a uniform adversarial impossibility (Theorem 4.3), finite cardinality
formulas (Proposition 2.2), and elementary Cantor-style diagonal theorems
(Theorems 5.2, 5.5). Connecting mathematical discovery to the
computability-theoretic jump would require a defensible formal model of
discovery and a reduction theorem; neither is supplied here. The value of the
work lies in the sharpness of its delimitation: it says precisely how far each
claim reaches and exactly which modelling choice would be needed to reach
further.

## 11. Conclusion

On a bounded language the perfect oracle exists and is a finite table; this
refutes the literal fixed-length noncomputability claim. Yet the same finiteness
that trivializes pointwise existence makes uniform robustness impossible, and
the genuinely infinitary force of diagonalization survives to defeat every
countable enumeration. The boundary between the possible and the impossible is
drawn not by the mathematics of any single object but by the words that frame
the promise: *for a fixed truth* versus *for all truths*, *finite* versus
*infinite*, *exists* versus *can be constructed*. Naming those words precisely
is the whole content of the result.
