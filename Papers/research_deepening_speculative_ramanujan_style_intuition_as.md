# Ramanujan Oracles Cannot Be Computable: A Counting Argument, with Constructive and Accuracy-Theoretic Strengthenings

## Abstract

Many of Ramanujan's identities were announced without proof and only later
verified, suggesting the fantasy of a *Ramanujan oracle*: a device that,
presented with any mathematical statement, returns a verdict — *true*,
*false*, or *unknown* — and is almost always right. We formalize this notion
and prove that no such oracle, if required to be flawless across all possible
worlds, can be computable. The core argument is a cardinality mismatch: the
space of ground truths (arbitrary assignments of truth values to a countable
set of statements) has the cardinality of the continuum $2^{\aleph_0}$,
whereas any enumerable family of oracles is countable. Since a perfect oracle
determines its world uniquely, a countable family of oracles can be perfect for
only countably many worlds, leaving uncountably many worlds uncovered. We give
the argument in four layers of increasing concreteness: (i) the raw
cardinality form, showing uncountably many worlds defeat any countable family;
(ii) an honest recursion-theoretic form, showing the type of computable
oracles is genuinely countable and hence a single ground truth defeats every
computable oracle; (iii) a constructive block-diagonalization producing, for
any enumerable family, one explicit world on which every oracle errs infinitely
often; and (iv) an accuracy-theoretic form, showing no oracle can guarantee any
fixed positive accuracy across all worlds. We discuss the connection to
undecidability, to cryptographic hardness, and to the difference between
world-specific heuristics and universal decision procedures.

**Keywords:** computability, cardinality, diagonalization, decidability,
oracles, Ramanujan, number theory, cryptographic hardness.

## 1. Introduction

In 1913 Ramanujan sent Hardy a letter containing scores of formulas stated
without proof. The episode has become emblematic of mathematical intuition: a
faculty that appears to *know* truths in advance of demonstration. It is
natural to ask whether such a faculty could be mechanized — whether one could
program a device that reliably classifies mathematical statements as true or
false.

We call such a hypothetical device a **Ramanujan oracle**. The original
motivating conjecture was that an oracle achieving high accuracy on
number-theoretic statements cannot be computable. We prove a clean and general
version of this claim by a counting argument, and then strengthen it in three
independent directions. The results are elementary in their tools —
Cantor's theorem and the countability of programs — but the layering into a
constructive form and an accuracy-theoretic form gives the impossibility real
teeth: it is not merely that a computable oracle fails to be perfect, but that
for any enumerable family of oracles there is a *single explicit* world on
which *every* member is wrong infinitely often and has accuracy zero.

### 1.1. Contributions

1. **Cardinality of ground truths (Theorem 3.1).** The space of ground truths
   is uncountable.
2. **Perfect oracles are world-determining (Theorem 3.2).** An oracle is
   perfect for at most one ground truth.
3. **Coverage is countable (Lemma 3.3) and the uncountable miss (Theorem
   3.4).** Any countable family of oracles is perfect for only countably many
   worlds, hence misses uncountably many.
4. **Non-computability, abstract and honest (Theorems 4.1–4.3).** No
   enumerable family of oracles is complete; the type of computable oracles is
   countable; a single ground truth defeats every computable oracle.
5. **Constructive block diagonalization (Theorem 5.2).** For any enumerable
   family there is one explicit world on which every oracle errs infinitely
   often.
6. **Accuracy impossibility (Theorem 6.2).** No oracle can guarantee any fixed
   positive accuracy across all worlds.

## 2. The model

We fix an effective Gödel numbering of mathematical statements, so that
statements are identified with the natural numbers.

**Definition 2.1 (Statement).** A *statement* is a natural number $n \in
\mathbb{N}$, understood as the Gödel code of a syntactic mathematical
assertion.

**Definition 2.2 (Ground truth).** A *ground truth* is a function
$$T : \mathbb{N} \to \{\text{false}, \text{true}\},$$
assigning to each statement its actual truth value. We write $\mathsf{Truth}$
for the set of all ground truths; as a set it is $\{\text{false},
\text{true}\}^{\mathbb{N}}$, the set of infinite binary sequences.

**Definition 2.3 (Oracle).** An *oracle* is a function
$$O : \mathbb{N} \to \{\text{true}, \text{false}, \text{unknown}\},$$
which we realize as $O : \mathbb{N} \to \mathsf{Option}(\{\text{false},
\text{true}\})$, with $\mathsf{unknown}$ modeled by the absent value. We write
$\mathsf{Oracle}$ for the set of all oracles.

**Definition 2.4 (Correctness).** An oracle $O$ is *correct* on statement $n$
with respect to ground truth $T$ if it commits to the true verdict:
$$O(n) = \mathsf{some}\,(T(n)).$$
An $\mathsf{unknown}$ answer is never correct.

**Definition 2.5 (Perfection).** An oracle $O$ is *perfect* for ground truth
$T$, written $\mathrm{Perfect}(O, T)$, if it is correct on every statement:
$$\forall n \in \mathbb{N}, \quad O(n) = \mathsf{some}\,(T(n)).$$

The modeling choice deserves comment. We allow oracles a third answer,
$\mathsf{unknown}$, precisely to be *generous* to the oracle-builder: the
device is never forced into a wrong commitment and may hedge freely. The
impossibility results hold despite this generosity, because hedging never
counts as correct and therefore never helps an oracle be perfect.

## 3. The counting argument

**Proposition 3.0 (Non-vacuity).** *For every ground truth $T$ there is an
oracle perfect for $T$.*

*Proof.* Take the echo oracle $O(n) := \mathsf{some}\,(T(n))$. Then $O(n) =
\mathsf{some}\,(T(n))$ for all $n$, so $O$ is perfect for $T$. $\qquad\blacksquare$

Proposition 3.0 shows the notion of perfection is non-vacuous. Perfection for a
*fixed* world is trivial; the difficulty is uniformity across worlds.

**Theorem 3.1 (Uncountability of ground truths).** *The set $\mathsf{Truth}$ is
uncountable; indeed $|\mathsf{Truth}| = 2^{\aleph_0} > \aleph_0$.*

*Proof.* As a set, $\mathsf{Truth} = \{\text{false},
\text{true}\}^{\mathbb{N}}$, whose cardinality is $2^{\aleph_0}$. By Cantor's
theorem $2^{\aleph_0} > \aleph_0$, so $\mathsf{Truth}$ cannot be put in
bijection with, or injected into, $\mathbb{N}$; it is uncountable. Concretely,
given any sequence $(T_k)_{k\in\mathbb{N}}$ of ground truths, the *diagonal*
truth $D(n) := \lnot\, T_n(n)$ differs from $T_k$ at statement $k$ for every
$k$, so no sequence enumerates all of $\mathsf{Truth}$. $\qquad\blacksquare$

**Theorem 3.2 (Perfect oracles are world-determining).** *If $O$ is perfect for
$T$ and also perfect for $T'$, then $T = T'$. Hence each oracle is perfect for
at most one ground truth.*

*Proof.* For every $n$ we have $\mathsf{some}\,(T(n)) = O(n) =
\mathsf{some}\,(T'(n))$, and injectivity of $\mathsf{some}$ gives $T(n) =
T'(n)$. As this holds for all $n$, $T = T'$. $\qquad\blacksquare$

This is the engine of the whole paper: a perfect oracle *is* a complete
encoding of its world, so distinct worlds require distinct oracles.

**Lemma 3.3 (Countable coverage).** *Let $\iota$ be a countable index set and
$F : \iota \to \mathsf{Oracle}$ a family of oracles. Then the set of worlds
covered by the family,*
$$\mathrm{Cov}(F) := \{\, T \in \mathsf{Truth} \mid \exists i,\; \mathrm{Perfect}(F(i), T)\,\},$$
*is countable.*

*Proof.* Define a map $g : \mathrm{Cov}(F) \to \iota$ by sending each covered
world $T$ to some index $i$ with $\mathrm{Perfect}(F(i), T)$ (choosing one such
$i$). If $g(T) = g(T') = i$, then both $T$ and $T'$ are covered by the same
oracle $F(i)$, so by Theorem 3.2 $T = T'$. Thus $g$ is injective. An injection
from $\mathrm{Cov}(F)$ into the countable set $\iota$ makes $\mathrm{Cov}(F)$
countable. $\qquad\blacksquare$

**Theorem 3.4 (Uncountable miss).** *For any countable family of oracles $F :
\iota \to \mathsf{Oracle}$, the set of worlds that defeat the entire family,*
$$\mathrm{Miss}(F) := \{\, T \in \mathsf{Truth} \mid \forall i,\; \lnot\,\mathrm{Perfect}(F(i), T)\,\},$$
*is uncountable.*

*Proof.* Observe $\mathrm{Miss}(F) = \mathrm{Cov}(F)^{\complement}$. If
$\mathrm{Miss}(F)$ were countable, then $\mathsf{Truth} = \mathrm{Cov}(F) \cup
\mathrm{Miss}(F)$ would be a union of two countable sets and hence countable,
contradicting Theorem 3.1. $\qquad\blacksquare$

**Corollary 3.5 (Incompleteness of countable families).** *For any countable
family of oracles there is a ground truth $T$ such that no oracle in the family
is perfect for $T$.* In particular $\mathrm{Miss}(F)$ is nonempty, being
uncountable.

## 4. Non-computability

**Theorem 4.1 (No computable oracle scheme is complete).** *Let $F : \mathbb{N}
\to \mathsf{Oracle}$ enumerate oracles produced by programs. There exists a
ground truth $T$ with $\lnot\,\mathrm{Perfect}(F(i), T)$ for all $i$.*

*Proof.* Immediate from Corollary 3.5, since $\mathbb{N}$ is countable.
$\qquad\blacksquare$

**Theorem 4.2 (No universal oracle).** *There is no oracle $O$ that is perfect
for every ground truth.*

*Proof.* Apply Corollary 3.5 to the one-element family constantly equal to
$O$; the resulting world $T$ satisfies $\lnot\,\mathrm{Perfect}(O, T)$.
$\qquad\blacksquare$

We now replace "enumerable family" by genuine computability. Fix a standard
theory of computation in which every computable function is computed by a code
(a natural number), and a code determines the function it computes.

**Theorem 4.3 (Only countably many computable oracles).** *The type
$\{\,O \in \mathsf{Oracle} \mid O \text{ is computable}\,\}$ is countable.*

*Proof.* Each computable oracle $O$ (as a total function $\mathbb{N} \to
\mathsf{Option}(\mathsf{Bool})$) induces a computable partial function and
hence is realized by some code $c$ with $c$ computing $n \mapsto
\mathrm{encode}(O(n))$. Choose such a code $c(O)$ for each computable $O$. If
$c(O) = c(O')$ then the codes compute the same function, so
$\mathrm{encode}(O(n)) = \mathrm{encode}(O'(n))$ for all $n$; injectivity of
the encoding gives $O(n) = O'(n)$, i.e. $O = O'$. Thus $O \mapsto c(O)$ is an
injection into the countable set of codes, and the computable oracles are
countable. $\qquad\blacksquare$

**Theorem 4.4 (Honest impossibility).** *There exists a single ground truth $T$
that defeats every computable oracle: for every computable oracle $O$,
$\lnot\,\mathrm{Perfect}(O, T)$.*

*Proof.* By Theorem 4.3 the computable oracles form a countable family; apply
Corollary 3.5 to this family. $\qquad\blacksquare$

Theorem 4.4 is the rigorous denial of the Ramanujan-oracle dream: no program
whatsoever can be flawless across all possible worlds, and the obstruction is a
mismatch of infinities rather than any limitation of resources or architecture.

## 5. Constructive strengthening: infinitely many errors

The cardinality argument is nonconstructive on the truth side. We now exhibit
adversarial worlds explicitly.

**Definition 5.1 (Adversary).** For an oracle $O$, the *adversarial world*
$\mathrm{adv}(O) : \mathbb{N} \to \mathsf{Bool}$ is
$$\mathrm{adv}(O)(n) := \begin{cases} \lnot b & \text{if } O(n) = \mathsf{some}\,b, \\ \text{true} & \text{if } O(n) = \mathsf{unknown}. \end{cases}$$

**Lemma 5.1a.** *$O$ is incorrect on every statement in the world
$\mathrm{adv}(O)$: for all $n$, $\lnot\,\mathrm{Correct}(O, \mathrm{adv}(O),
n)$.*

*Proof.* If $O(n) = \mathsf{some}\,b$ then $\mathrm{adv}(O)(n) = \lnot b \ne
b$, so $O(n) = \mathsf{some}\,b \ne \mathsf{some}\,(\lnot b)$. If $O(n) =
\mathsf{unknown}$ then $O(n) \ne \mathsf{some}(\cdot)$, so it is not correct.
$\qquad\blacksquare$

To defeat an entire enumerable family simultaneously, partition $\mathbb{N}$
into blocks using a computable pairing bijection $\langle\cdot,\cdot\rangle :
\mathbb{N}^2 \to \mathbb{N}$ with inverse $n \mapsto (\pi_1 n, \pi_2 n)$.

**Definition 5.1b (Block-diagonal world).** For a family $F : \mathbb{N} \to
\mathsf{Oracle}$, set
$$\mathrm{block}(F)(n) := \mathrm{adv}\big(F(\pi_1 n)\big)(n).$$
On the block $\{ n : \pi_1 n = i \}$ the world plays the adversary against
$F(i)$.

**Theorem 5.2 (Block diagonalization).** *For any family $F : \mathbb{N} \to
\mathsf{Oracle}$ there is a single ground truth $T$ — namely
$\mathrm{block}(F)$ — such that for every $i$, the oracle $F(i)$ is incorrect
at infinitely many statements:*
$$\forall i,\quad \{\, n \mid \lnot\,\mathrm{Correct}(F(i), T, n)\,\} \text{ is infinite.}$$

*Proof.* Fix $i$. For $n$ with $\pi_1 n = i$ we have $\mathrm{block}(F)(n) =
\mathrm{adv}(F(i))(n)$, so by Lemma 5.1a $F(i)$ is incorrect at $n$. Hence
$\{ n : \pi_1 n = i\} \subseteq \{ n : \lnot\,\mathrm{Correct}(F(i), T, n)\}$.
The left set is infinite: $j \mapsto \langle i, j\rangle$ is an injection whose
image lies in it. A superset of an infinite set is infinite. $\qquad\blacksquare$

Thus no oracle in the family is even *eventually* correct on the world
$\mathrm{block}(F)$.

## 6. Accuracy: no guaranteed accuracy across all worlds

We quantify how badly the adversary hurts an oracle.

**Definition 6.1 (Running hits).** For an oracle $O$, world $T$, and threshold
$N$, let
$$\mathrm{hits}(O, T, N) := \big| \{\, n < N \mid O(n) = \mathsf{some}\,(T(n))\,\} \big|,$$
the number of correct commitments among the first $N$ statements.

**Lemma 6.1a (Zero hits against the adversary).** *For any oracle $O$ and every
$N$, $\mathrm{hits}(O, \mathrm{adv}(O), N) = 0$.*

*Proof.* By Lemma 5.1a, $O(n) \ne \mathsf{some}\,(\mathrm{adv}(O)(n))$ for
every $n$, so the filtered set is empty and its cardinality is $0$.
$\qquad\blacksquare$

**Theorem 6.2 (No guaranteed accuracy).** *There is no oracle $O$ that
achieves accuracy at least $19/20 = 95\%$ in every world; more precisely, there
is no $O$ with*
$$\forall T\ \forall N \ge 1, \quad 20 \cdot \mathrm{hits}(O, T, N) \ge 19 \cdot N.$$
*(The inequality expresses $\mathrm{hits}/N \ge 0.95$ without division.)*

*Proof.* Suppose such $O$ existed. Apply the hypothesis in the world
$\mathrm{adv}(O)$ at $N = 1$: it demands $20 \cdot \mathrm{hits}(O,
\mathrm{adv}(O), 1) \ge 19$. But by Lemma 6.1a the left side is $0$, and $0 \ge
19$ is false. $\qquad\blacksquare$

The constant $95\%$ plays no special role: the same proof refutes any fixed
positive accuracy threshold, since the adversarial world drives running
accuracy identically to zero.

## 7. Algorithms

Although the theorems are impossibility results, their proofs are effective in
the oracle and yield concrete constructions. We record two.

**Algorithm A (Adversarial world).** Given (black-box) access to an oracle $O$,
compute the world in which $O$ is wrong everywhere: on input $n$, query $O(n)$;
if it is $\mathsf{some}\,b$, output $\lnot b$; if it is $\mathsf{unknown}$,
output $\mathsf{true}$. This realizes Definition 5.1 and, by Lemma 5.1a,
guarantees zero correctness for $O$.

**Algorithm B (Block-diagonal world against a family).** Given an enumeration
$F$ of oracles, compute the single world defeating them all: on input $n$,
decode $(i, j) = (\pi_1 n, \pi_2 n)$, query $F(i)(n)$, and output the adversary
of that verdict. This realizes Definition 5.1b; by Theorem 5.2 every $F(i)$
errs infinitely often on the resulting world.

Both algorithms are total and run in time dominated by a single oracle query
plus the cost of the pairing decode, which is polynomial in the bit-length of
$n$.

## 8. Discussion

**Where the impossibility bites — and where it does not.** The theorems
forbid a *program* that is perfect *simultaneously across all worlds*. They say
nothing against an oracle tailored to *our* world — the single fixed answer key
of actual mathematics — for which a perfect oracle certainly exists as an
abstract object (Proposition 3.0). The content is precisely that no *uniform,
enumerable* rule captures the correct answer key, because that answer key lives
in an uncountable space while rules live in a countable one.

**Relation to undecidability.** The counting argument is orthogonal to, and
weaker in flavor than, the classical undecidability of arithmetic truth. Our
result shows non-existence of a universal oracle across all worlds; the
classical result shows that even the *single* true arithmetic is undecidable.
The two combine naturally: one can encode the halting problem into the ground
truth of our world and recover undecidability for that fixed world, a direction
we leave to future work.

**Relation to cryptography.** The gap exploited here — countably many programs
against uncountably many possibilities — mirrors the logic of cryptographic
hardness, where security rests on the chasm between the instances an adversary
can enumerate and the space it cannot. An oracle guaranteed correct across all
worlds would be, in effect, a universal distinguisher; its non-existence is a
qualitative cousin of the assumptions underpinning modern cryptographic
security.

**On the bounded-length framing.** The original conjecture restricted to
statements of length at most $100$. That is a *finite* set and hence trivially
decidable by table lookup, so the impossibility must be phrased over an
unbounded supply of statements, as we do. A faithful quantitative refinement
replaces the fixed bound by a growing family $S_k$ of statements of length at
most $k$ and studies the rate at which computable accuracy must degrade.

## 9. Future directions

1. **Genuine recursion-theoretic computability.** *(Realized here.)* The
   abstract "countable family" model is replaced by genuine computability: each
   computable oracle is computed by a code, distinct oracles require distinct
   codes, and codes are countable, so the counting argument applies to the
   honest notion of computability (Theorems 4.3–4.4). A remaining refinement is
   to phrase the same result directly in terms of decidable predicates and
   oracle Turing machines with relativized queries.

2. **Undecidability, not just non-computability.** Connect to the
   undecidability of arithmetic truth: encode the halting problem into the
   ground truth and show that even a many-worlds-free single true arithmetic is
   not decidable.

3. **Quantitative accuracy over density.** Strengthen the accuracy result from
   "accuracy $0$ on the adversarial world" to a density statement: for any
   countable family, there is a world on which each oracle has upper density of
   errors bounded below by a positive constant, using a weighted block
   construction.

4. **Bounded-length statements.** Replace "length $\le 100$" by a growing
   family $S_k$ of statements of length $\le k$ and study the growth rate at
   which computable accuracy must degrade.

5. **Probabilistic oracles.** Model an oracle as a distribution over verdicts
   and ask whether a computable randomized oracle can achieve high expected
   accuracy across all worlds.

## 10. Conclusion

A Ramanujan oracle that is guaranteed flawless across all possible mathematical
worlds cannot be computable. The proof is a counting argument: perfect oracles
determine their worlds, so a countable supply of oracles pins down only
countably many of the uncountably many possible worlds. We upgraded this to the
honest notion of computability, made the adversarial worlds explicit through
block diagonalization, and showed that no fixed positive accuracy can be
guaranteed across all worlds. Ramanujan's intuition, on this reading, was not a
universal oracle but a superb world-specific heuristic — and the counting
argument explains why that is the only kind of oracle that can exist.
