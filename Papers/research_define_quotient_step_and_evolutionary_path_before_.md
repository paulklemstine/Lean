# Quotient Steps and Evolutionary Paths: An Axiomatic Theory of Unique Decomposition

**Author:** Aristotle
**Date:** 2026-09-07

---

## Abstract

We isolate the minimal combinatorial structure underlying unique-decomposition
theorems. A **quotient system** is a labelled step relation on a class of
objects, equipped with a natural-number rank, subject to exactly three axioms:
every step strictly decreases rank (*termination*), the label of a step is
determined by its endpoints (*label determinacy*), and two distinct steps out of
a common source close into a diamond with labels exchanged (*exchange*, an
abstract Zassenhaus/butterfly axiom). A **quotient step** is one such move; an
**evolutionary path** is a finite chain of them, recording the list of labels
used, and is *complete* when it ends at a terminal object admitting no further
step.

Our main theorem — an abstract Jordan–Hölder theorem — states that any two
complete evolutionary paths out of the same object end at the same terminal
object and use the same multiset of labels. This produces a well-defined
multiset-valued invariant $\mathrm{decomp}(x)$ satisfying a one-step law, a
terminality criterion, and a conservation law asserting that the labels of an
arbitrary path equal the multiset difference of the invariants at its endpoints.
As structural corollaries, reachability is an antisymmetric, graded, confluent
preorder, and the invariant is functorial for step-preserving maps.

We show the three axioms are independent: for each, an explicit finite
counterexample satisfying the other two invalidates the corresponding
conclusion. We prove a universality theorem — every quotient system maps to the
system of multisets under deletion — and determine exactly when that
representation is faithful: the naive conjecture fails on a four-element
diamond, but holds under a *separation* hypothesis, via a pull-forward
(commutation) lemma. Adding a *saturation* hypothesis yields a complete
classification: the stages reachable from $x$ are in bijection with the
sub-multisets of $\mathrm{decomp}(x)$, and the label lists of complete paths out
of $x$ are exactly the permutations of $\mathrm{decomp}(x)$.

Two instantiations are developed. In the multiplicative monoid of natural
numbers, with steps dividing out a prime, the abstract theorem specialises to
the fundamental theorem of arithmetic, the invariant is the prime factorisation,
its cardinality is $\Omega$, its label multiplicities are the $p$-adic
valuations, reachability is divisibility, and the classification theorem is the
divisor–sub-multiset correspondence. On finite sets, with steps deleting one
element, the invariant is the underlying multiset; the prime-product map bridges
the two instances and yields squarefreeness and injectivity results without
multiplicative computation. Finally, weighting labels produces *path weights* and
*path actions*, conserved potentials of the flow, and characterises the
completely multiplicative and completely additive arithmetic functions as
exactly the path weights and path actions of their own restrictions to the prime
labels.

**Keywords:** quotient step, evolutionary path, Jordan–Hölder theorem, exchange
axiom, unique factorisation, multiset invariant, confluence, completely additive
functions.

---

## 1. Introduction

### 1.1 The recurring phenomenon

Across mathematics one meets the same statement in different dialects:

- *Fundamental theorem of arithmetic.* Every positive integer factors into
  primes, uniquely up to order.
- *Jordan–Hölder theorem.* Every composition series of a finite group has the
  same length and the same multiset of simple factors.
- *Deletion in finite sets.* Removing the elements of a finite set one at a time
  takes exactly $|S|$ steps and uses each element once.
- *Normal forms in rewriting.* A terminating, confluent rewriting system assigns
  a unique normal form to each term.

Each is proved separately in its own subject, with its own machinery. The
question this paper answers is: *what is the common core?* Specifically, what is
the weakest hypothesis set on an abstract "breaking apart" process under which
the conclusion "the decomposition is independent of every choice" is a theorem?

### 1.2 Method: define the vocabulary before the conjecture

The methodological commitment of this work is to define the two operative
notions — **quotient step** and **evolutionary path** — with full precision
*before* attempting the decomposition conjecture. This is not pedantry. Once the
notion of a step is fixed to the three axioms below, the decomposition
conjecture becomes a decidable question about that axiom set, and — crucially —
the *sharpness* of the answer becomes testable. We can and do ask, for each
axiom, whether it may be dropped.

### 1.3 Summary of contributions

1. **Definitions** (§2): quotient system, quotient step, evolutionary path,
   terminal object, completeness, reachability.
2. **Decomposition theorem** (§3): the abstract Jordan–Hölder theorem and the
   invariant $\mathrm{decomp}$, with its one-step law, terminality criterion,
   conservation law, grading, confluence, and functoriality.
3. **Sharpness** (§4): independence of the three axioms.
4. **Instances** (§5): arithmetic and finite sets, with the fundamental theorem
   of arithmetic derived from the abstract theorem, and a bridge morphism
   between the two instances.
5. **Universality and rigidity** (§6): multiset deletion as the universal
   quotient system; failure of faithfulness in general; the separation
   hypothesis and the pull-forward lemma; faithfulness on futures.
6. **Classification** (§7): the saturation hypothesis; the future of an object
   as the lattice of sub-multisets of its invariant; complete paths as
   permutations of the invariant.
7. **Path integrals** (§8): path weights and path actions; conservation;
   characterisation of completely multiplicative and completely additive
   arithmetic functions.
8. **Discussion and open problems** (§9–§10).

---

## 2. Definitions

Throughout, $\alpha$ denotes a class of *objects* and $\Lambda$ a class of
*labels*.

### 2.1 Quotient systems and quotient steps

**Definition 2.1 (Quotient system).** A *quotient system* $Q$ on $(\alpha,
\Lambda)$ consists of

- a ternary relation $\mathrm{step}_Q \subseteq \alpha \times \Lambda \times
  \alpha$, written $x \xrightarrow{\ell} y$ and read "*$y$ is obtained from $x$
  by a quotient step of type $\ell$*";
- a *rank* function $\mathrm{rank}_Q : \alpha \to \mathbb{N}$;

satisfying:

- **(A1) Termination.** If $x \xrightarrow{\ell} y$ then $\mathrm{rank}_Q(y) <
  \mathrm{rank}_Q(x)$.
- **(A2) Label determinacy.** If $x \xrightarrow{\ell_1} y$ and $x
  \xrightarrow{\ell_2} y$ then $\ell_1 = \ell_2$.
- **(A3) Exchange.** If $x \xrightarrow{\ell_1} y_1$ and $x \xrightarrow{\ell_2}
  y_2$ with $y_1 \neq y_2$, then there is $z$ with $y_1 \xrightarrow{\ell_2} z$
  and $y_2 \xrightarrow{\ell_1} z$.

**Definition 2.2 (Quotient step).** A *quotient step* is an instance of the
relation $\mathrm{step}_Q$: a triple $(x, \ell, y)$ with $x \xrightarrow{\ell}
y$. It is the atomic move of the theory: one labelled, rank-decreasing,
exchange-closed reduction.

Remarks on the axioms. (A1) is termination in the sense of rewriting theory: it
forbids infinite evolution and supplies the induction measure for every proof
below. (A2) says the "isomorphism type of the quotient" is well defined —
knowing where you started and where you landed determines what you divided out.
(A3) is the abstract form of the Zassenhaus butterfly lemma, and simultaneously a
labelled local-confluence condition: distinct one-step futures can be
reconciled in one further step *each*, with the labels transposed. Note that
(A3) is silent when $y_1 = y_2$, which is exactly the case handled by (A2).

Nothing else is assumed. In particular, a given source $x$ and label $\ell$ may
admit several targets; §6 studies the systems where it does not.

### 2.2 Evolutionary paths

**Definition 2.3 (Evolutionary path).** For $x, t \in \alpha$ and a list $L =
[\ell_1, \ldots, \ell_k]$ of labels, an *evolutionary path* from $x$ to $t$ with
label list $L$ is a finite chain
$$x = x_0 \xrightarrow{\ell_1} x_1 \xrightarrow{\ell_2} \cdots
\xrightarrow{\ell_k} x_k = t .$$
Formally the relation is generated by the empty path from $x$ to $x$ with label
list $[\,]$, and by prefixing a quotient step $x \xrightarrow{\ell} y$ to a path
from $y$ to $t$.

**Definition 2.4 (Terminal, complete).** An object $t$ is *terminal* if no
quotient step leaves it: $\neg\, (t \xrightarrow{\ell} y)$ for all $\ell, y$. An
evolutionary path is *complete* if its endpoint is terminal.

**Definition 2.5 (Reachability).** Write $x \rightsquigarrow y$ ("$y$ is
reachable from $x$", equivalently "$y$ is a *stage in the future of* $x$") if
there exists an evolutionary path from $x$ to $y$.

Immediate consequences of (A1): along a path, rank is nonincreasing, and the
length of any path out of $x$ is at most $\mathrm{rank}_Q(x)$. Paths concatenate:
a path $x \to y$ with labels $L_1$ and a path $y \to z$ with labels $L_2$ give a
path $x \to z$ with labels $L_1 \mathbin{+\!\!+} L_2$.

**Proposition 2.6 (Termination of evolution).** Every object $x$ admits a
complete evolutionary path.

*Proof.* Strong induction on $\mathrm{rank}_Q(x)$. If $x$ is terminal, the empty
path suffices. Otherwise choose any step $x \xrightarrow{\ell} y$; by (A1),
$\mathrm{rank}_Q(y) < \mathrm{rank}_Q(x)$, so by induction $y$ admits a complete
path, and prefixing the step gives one for $x$. $\square$

---

## 3. The Decomposition Theorem

### 3.1 Statement and proof

**Theorem 3.1 (Abstract Jordan–Hölder / Decomposition Theorem).** Let $Q$ be a
quotient system. Suppose there are complete evolutionary paths out of $x$, one
ending at $t_1$ with label list $L_1$ and one ending at $t_2$ with label list
$L_2$. Then
$$t_1 = t_2 \quad\text{and}\quad \overline{L_1} = \overline{L_2},$$
where $\overline{L}$ denotes the multiset underlying the list $L$.

*Proof.* Strong induction on $n = \mathrm{rank}_Q(x)$.

If either path is empty, its source is terminal, forcing the other to be empty
as well; both endpoints are $x$ and both label multisets empty.

Otherwise write the paths as $x \xrightarrow{\ell_1} y_1 \rightsquigarrow t_1$
with labels $\ell_1 :: L_1'$, and $x \xrightarrow{\ell_2} y_2 \rightsquigarrow
t_2$ with labels $\ell_2 :: L_2'$.

*Case $y_1 = y_2$.* By (A2), $\ell_1 = \ell_2$. By (A1) the common successor has
strictly smaller rank, so the induction hypothesis applied at $y_1$ gives
$t_1 = t_2$ and $\overline{L_1'} = \overline{L_2'}$; prefixing the common label
preserves both conclusions.

*Case $y_1 \neq y_2$.* By (A3) there is $z$ with $y_1 \xrightarrow{\ell_2} z$
and $y_2 \xrightarrow{\ell_1} z$. By Proposition 2.6, $z$ admits a complete path
to some terminal $t$ with labels $L$. Applying the induction hypothesis at $y_1$
(rank strictly smaller by (A1)) to the two complete paths $y_1 \rightsquigarrow
t_1$ (labels $L_1'$) and $y_1 \xrightarrow{\ell_2} z \rightsquigarrow t$ (labels
$\ell_2 :: L$) yields $t_1 = t$ and $\overline{L_1'} = \{\ell_2\} \uplus
\overline{L}$. Symmetrically at $y_2$: $t_2 = t$ and $\overline{L_2'} =
\{\ell_1\} \uplus \overline{L}$. Therefore $t_1 = t = t_2$, and
$$\overline{\ell_1 :: L_1'} = \{\ell_1, \ell_2\} \uplus \overline{L}
= \{\ell_2, \ell_1\} \uplus \overline{L} = \overline{\ell_2 :: L_2'},$$
the middle equality being commutativity of multiset union — the transposition of
two labels. $\square$

**Corollary 3.2 (Equal length).** All complete evolutionary paths out of $x$
have the same length.

### 3.2 The invariant

By Proposition 2.6 and Theorem 3.1, the following are well defined.

**Definition 3.3.** The *normal form* $\mathrm{nf}(x)$ is the unique terminal
object reachable from $x$. The *decomposition invariant* $\mathrm{decomp}(x) \in
\mathrm{Multiset}(\Lambda)$ is the multiset of labels of any complete
evolutionary path out of $x$. The *height* is $\mathrm{ht}(x) =
|\mathrm{decomp}(x)|$.

**Proposition 3.4 (Computation from any complete path).** If there is a complete
path from $x$ to $t$ with labels $L$, then $\mathrm{decomp}(x) = \overline{L}$
and $\mathrm{nf}(x) = t$.

**Theorem 3.5 (One-step law).** If $x \xrightarrow{\ell} y$ then
$$\mathrm{decomp}(x) = \{\ell\} \uplus \mathrm{decomp}(y), \qquad
\mathrm{nf}(x) = \mathrm{nf}(y), \qquad \mathrm{ht}(x) = \mathrm{ht}(y) + 1 .$$

*Proof.* Prefix the step to a complete path out of $y$ and apply Proposition
3.4. $\square$

**Theorem 3.6 (Terminality criterion).** $x$ is terminal if and only if
$\mathrm{decomp}(x) = \varnothing$.

*Proof.* ($\Rightarrow$) The empty path out of a terminal $x$ is complete.
($\Leftarrow$) A step out of $x$ would make $\mathrm{decomp}(x)$ a nonempty
multiset by Theorem 3.5. $\square$

**Theorem 3.7 (Conservation of labels).** If there is an evolutionary path from
$x$ to $y$ with label list $L$ — not necessarily complete — then
$$\mathrm{decomp}(x) = \overline{L} \uplus \mathrm{decomp}(y).$$
Consequently the label multiset of a path depends only on its endpoints: two
paths $x \to y$ carry equal label multisets, and $\overline{L} =
\mathrm{decomp}(x) - \mathrm{decomp}(y)$.

*Proof.* Induction on the path, using Theorem 3.5 at each step. For the
consequence, cancel $\mathrm{decomp}(y)$ in the commutative cancellative monoid
of multisets. $\square$

Theorem 3.7 is the structural heart of the theory: it says $\mathrm{decomp}$ is
a *potential* whose differences are the path labels, so there is no
path-dependence anywhere.

**Corollary 3.8 (Monotonicity and invariance under reachability).** If $x
\rightsquigarrow y$ then $\mathrm{decomp}(y) \le \mathrm{decomp}(x)$ (multiset
containment), $\mathrm{ht}(y) \le \mathrm{ht}(x)$, $\mathrm{rank}_Q(y) \le
\mathrm{rank}_Q(x)$, and $\mathrm{nf}(x) = \mathrm{nf}(y)$.

**Also:** $\mathrm{ht}(x) \le \mathrm{rank}_Q(x)$ — the height is the intrinsic
sharpening of the ad hoc rank supplied with the system.

### 3.3 Structure of the evolutionary order

**Theorem 3.9 (Antisymmetry).** If $x \rightsquigarrow y$ and $y
\rightsquigarrow x$ then $x = y$. Hence $\rightsquigarrow$ is a partial order.

*Proof.* A nonempty path $x \to y$ would give $\mathrm{rank}_Q(y) <
\mathrm{rank}_Q(x)$ by (A1), contradicting $\mathrm{rank}_Q(x) \le
\mathrm{rank}_Q(y)$ from the reverse path. $\square$

**Theorem 3.10 (Splitting and grading).** Every evolutionary path may be split at
any prescribed position into two paths. Consequently, if $x \rightsquigarrow y$
and $\mathrm{ht}(y) \le k \le \mathrm{ht}(x)$, there is an intermediate stage $z$
with $x \rightsquigarrow z \rightsquigarrow y$ and $\mathrm{ht}(z) = k$: the
evolutionary order is *graded* by the height.

**Theorem 3.11 (Confluence).** Any two futures of $x$ have a common future:
if $x \rightsquigarrow y$ and $x \rightsquigarrow z$ then there is $w$ with
$y \rightsquigarrow w$ and $z \rightsquigarrow w$. One may take $w =
\mathrm{nf}(x)$.

*Proof.* By Corollary 3.8, $\mathrm{nf}(y) = \mathrm{nf}(x) = \mathrm{nf}(z)$,
and every object reaches its own normal form. $\square$

### 3.4 Functoriality

**Definition 3.12.** A *morphism of quotient systems* from $Q$ (on $\alpha,
\Lambda$) to $R$ (on $\beta, \Lambda'$) is a pair of maps $f : \alpha \to \beta$,
$g : \Lambda \to \Lambda'$ such that $x \xrightarrow{\ell}_Q y$ implies
$f(x) \xrightarrow{g(\ell)}_R f(y)$, and $f$ carries $Q$-terminal objects to
$R$-terminal objects.

**Theorem 3.13 (Functoriality of the invariant).** For a morphism $(f, g)$,
$$\mathrm{decomp}_R(f(x)) = g_*\!\left(\mathrm{decomp}_Q(x)\right)
\quad\text{and}\quad \mathrm{ht}_R(f(x)) = \mathrm{ht}_Q(x),$$
where $g_*$ is the induced map on multisets.

*Proof.* A complete $Q$-path out of $x$ maps to a $R$-path out of $f(x)$ with
labels $g$-mapped and terminal endpoint; apply Proposition 3.4. $\square$

Theorem 3.13 is what makes the theory usable: computations transport between
instances, as demonstrated in §5.3.

---

## 4. Sharpness: the three axioms are independent

To speak of chains for step relations that are *not* quotient systems, we use
the axiom-free notion of a *chain* — a finite sequence of related moves — and
*stuck* — admitting no move. For a genuine quotient system, chains are exactly
evolutionary paths and stuck is exactly terminal, so the counterexamples below
really are counterexamples about evolutionary decomposition.

**Theorem 4.1 (Exchange is necessary).** There is a labelled step relation on
$\{0,1,2\}$ with a rank function satisfying (A1) and (A2) but not (A3), and two
complete chains out of $0$ whose label lists have *different lengths* and hence
different multisets.

*Construction.* Single label; steps $0 \to 1$, $1 \to 2$, $0 \to 2$; rank $x
\mapsto 2 - x$. Rank strictly decreases and labels are trivially determined. The
pair $0 \to 1$, $0 \to 2$ cannot be completed to a diamond, since $2$ is stuck.
The chains $0 \to 1 \to 2$ (length $2$) and $0 \to 2$ (length $1$) are both
complete. $\square$

So without exchange, not even the *length* of a decomposition is well defined.

**Theorem 4.2 (Label determinacy is necessary).** There is a labelled step
relation on $\{0,1\}$ with a rank function satisfying (A1) and (A3) but not
(A2), and two complete chains out of $0$ with different label multisets.

*Construction.* Labels $\{\mathrm{true}, \mathrm{false}\}$; the single move
$0 \to 1$ is permitted with either label; rank $x \mapsto 1 - x$. (A1) holds;
(A3) holds vacuously, since the only possible target is $1$, so the hypothesis
$y_1 \neq y_2$ never applies. The chains $0 \xrightarrow{\mathrm{true}} 1$ and
$0 \xrightarrow{\mathrm{false}} 1$ are complete with label multisets
$\{\mathrm{true}\}$ and $\{\mathrm{false}\}$. $\square$

Here the *destination* is still unique; it is the labelled invariant that fails.
This isolates precisely what (A2) buys.

**Theorem 4.3 (Termination is necessary).** There is a labelled step relation
satisfying (A2) and (A3) but not (A1) for which no chain ever reaches a stuck
object; hence there is no complete evolutionary path and no invariant to define.

*Construction.* One object with a self-loop; one label. (A2) and (A3) are
trivial. No object is ever stuck. $\square$

**Theorem 4.4 (Positive counterpart).** For a genuine quotient system, any two
complete chains out of the same object agree in endpoint, in label multiset, and
in length.

The three constructions show that Theorem 4.4's hypotheses cannot be weakened
by deleting an axiom.

---

## 5. Instances

### 5.1 The arithmetic quotient system

Take $\alpha = \mathbb{N}$, $\Lambda = \mathbb{N}$, and declare
$$n \xrightarrow{p} m \iff p \text{ is prime},\ m > 0,\ n = pm ,$$
with $\mathrm{rank}(n)$ the number of prime factors of $n$ counted with
multiplicity.

**Proposition 5.1.** This is a quotient system.

*Proof.* (A1): $\mathrm{rank}(pm) = \mathrm{rank}(m) + 1$ for $p$ prime, $m > 0$.
(A2): $p_1 m = p_2 m$ with $m > 0$ gives $p_1 = p_2$ by cancellation. (A3):
suppose $n = p_1 m_1 = p_2 m_2$ with $m_1 \neq m_2$. Then $p_1 \neq p_2$ (else
cancellation would give $m_1 = m_2$). Now $p_2 \mid p_1 m_1$; since $p_2$ is
prime and $p_2 \nmid p_1$ (distinct primes), **Euclid's lemma** gives $p_2 \mid
m_1$, say $m_1 = p_2 z$ with $z > 0$. Then $p_2 m_2 = p_1 p_2 z$, so $m_2 = p_1
z$, and $m_1 \xrightarrow{p_2} z$, $m_2 \xrightarrow{p_1} z$. $\square$

The exchange axiom in this instance is *exactly* Euclid's lemma. This is the
precise sense in which the uniqueness of factorisation is a consequence of
Euclid's lemma plus abstract nonsense.

**Proposition 5.2 (Terminal objects).** $n$ is terminal iff $n \le 1$; the
terminal objects are $0$ and $1$.

**Theorem 5.3 (Fundamental theorem of arithmetic, derived).** If $L$ is a list
of primes then $\mathrm{decomp}(\prod L) = \overline{L}$. Consequently, if $L_1$
and $L_2$ are lists of primes with $\prod L_1 = \prod L_2$, then $\overline{L_1}
= \overline{L_2}$: prime factorisation is unique up to order.

*Proof.* A list of primes $[p_1, \ldots, p_k]$ yields the evolutionary path
$\prod L \xrightarrow{p_1} p_2\cdots p_k \xrightarrow{p_2} \cdots
\xrightarrow{p_k} 1$, which is complete since $1$ is terminal. Proposition 3.4
gives $\mathrm{decomp}(\prod L) = \overline{L}$. Uniqueness is then immediate
from well-definedness of $\mathrm{decomp}$. $\square$

**Proposition 5.4 (Identification of the invariant).** For $n > 0$:
$\mathrm{decomp}(n)$ is the multiset of prime factors of $n$; $\mathrm{ht}(n) =
\Omega(n)$, the number of prime factors with multiplicity; the multiplicity of
the label $p$ in $\mathrm{decomp}(n)$ is $v_p(n)$, the $p$-adic valuation;
and $\mathrm{nf}(n) = 1$.

**Theorem 5.5 (Reachability is divisibility).** For $m, n > 0$: $n
\rightsquigarrow m$ if and only if $m \mid n$.

*Proof.* ($\Rightarrow$) Induction along the path: each step replaces the
current value by a divisor. ($\Leftarrow$) Write $n = mk$ and evolve $mk$ down
to $m$ by dividing out, in order, the primes of $k$. $\square$

### 5.2 The deletion quotient system on finite sets

Take $\alpha$ the finite subsets of a type $\iota$ with decidable equality,
$\Lambda = \iota$, and $S \xrightarrow{a} T$ iff $a \in S$ and $T = S \setminus
\{a\}$, with $\mathrm{rank}(S) = |S|$.

**Proposition 5.6.** This is a quotient system: (A1) is $|S \setminus \{a\}| <
|S|$ for $a \in S$; (A2) holds since $S \setminus \{a\} = S \setminus \{b\}$
with $a, b \in S$ forces $a = b$; (A3) holds because deletions of distinct
elements commute, $(S \setminus \{a\}) \setminus \{b\} = (S \setminus \{b\})
\setminus \{a\}$.

**Theorem 5.7 (Deletion decomposition).** The terminal objects are exactly the
empty sets; $\mathrm{decomp}(S)$ is the underlying multiset of $S$; and
$\mathrm{ht}(S) = |S|$. Hence every complete deletion sequence of $S$ uses each
element exactly once, in some order, and has length $|S|$.

*Proof.* Induction on $S$ using Theorem 3.5: for $a \notin S$, the step
$S \cup \{a\} \xrightarrow{a} S$ gives $\mathrm{decomp}(S \cup \{a\}) = \{a\}
\uplus \mathrm{decomp}(S)$. $\square$

### 5.3 The bridge: sets of primes and squarefree numbers

Let $\mathbb{P}$ denote the primes and, for a finite $S \subseteq \mathbb{P}$,
put $\pi(S) = \prod_{p \in S} p$.

**Proposition 5.8.** $\pi$, together with the inclusion $\mathbb{P}
\hookrightarrow \mathbb{N}$ on labels, is a morphism of quotient systems from the
deletion system on finite sets of primes to the arithmetic system: a deletion
$S \xrightarrow{p} S \setminus \{p\}$ maps to the division $\pi(S)
\xrightarrow{p} \pi(S \setminus \{p\})$, and $\pi(\varnothing) = 1$ is terminal.

**Theorem 5.9 (Bridge theorem).** For every finite set $S$ of primes,
$$\mathrm{decomp}\big(\pi(S)\big) = S,$$
i.e. the prime factorisation of $\prod_{p \in S} p$ is exactly $S$ (with
multiplicity one throughout).

*Proof.* Theorem 3.13 applied to the morphism $\pi$, combined with Theorem 5.7.
$\square$

**Corollary 5.10.** (i) $\prod_{p \in S} p$ is squarefree. (ii) $\pi$ is
injective: distinct finite sets of primes have distinct products.

*Proof.* (i) By Proposition 5.4, $v_q(\pi(S))$ equals the multiplicity of $q$
in $\mathrm{decomp}(\pi(S)) = S$, which is $\le 1$ since $S$ is a set. (ii) If
$\pi(S) = \pi(T)$ then $S = \mathrm{decomp}(\pi(S)) = \mathrm{decomp}(\pi(T)) =
T$. $\square$

Both statements are usually proved by direct multiplicative computation. Here
they are transported, for free, from a trivial combinatorial fact.

---

## 6. Universality and rigidity

### 6.1 The universal quotient system

**Definition 6.1.** The *multiset system* on $\Lambda$ has objects
$\mathrm{Multiset}(\Lambda)$, labels $\Lambda$, step $M \xrightarrow{\ell} N$
iff $M = \{\ell\} \uplus N$, and rank $|M|$.

**Proposition 6.2.** The multiset system is a quotient system; its terminal
object is $\varnothing$; and it computes its own invariant:
$\mathrm{decomp}(M) = M$.

*Proof of (A3).* If $\{\ell_1\} \uplus N_1 = \{\ell_2\} \uplus N_2$ with
$N_1 \neq N_2$, then $\ell_1 \neq \ell_2$ and there is a common part $C$ with
$N_1 = \{\ell_2\} \uplus C$ and $N_2 = \{\ell_1\} \uplus C$. $\square$

**Theorem 6.3 (Universality).** For any quotient system $Q$, the pair
$(\mathrm{decomp}, \mathrm{id}_\Lambda)$ is a morphism from $Q$ to the multiset
system: a step $x \xrightarrow{\ell} y$ maps to the deletion
$\mathrm{decomp}(x) \xrightarrow{\ell} \mathrm{decomp}(y)$, terminal objects map
to $\varnothing$, and every evolutionary path maps to the corresponding deletion
sequence of its label multiset.

Thus multiset deletion is the *universal target* of the theory: every
evolutionary process is a shadow of it.

### 6.2 Failure of faithfulness

Is the shadow faithful? Does $\mathrm{decomp}$ separate distinct stages of the
future of $x$? The bold conjecture is **false**.

**Theorem 6.4 (Diamond counterexample).** There is a quotient system on
$\{0,1,2,3\}$ with a single label — steps $3 \to 1$, $3 \to 2$, $1 \to 0$,
$2 \to 0$ — in which the distinct stages $1$ and $2$ are both reachable from
$3$ and satisfy $\mathrm{decomp}(1) = \mathrm{decomp}(2) = \{\ell\}$.

### 6.3 Separation repairs it

**Definition 6.5.** A quotient system is *separated* if a step is determined by
its source and its label: $x \xrightarrow{\ell} y_1$ and $x \xrightarrow{\ell}
y_2$ imply $y_1 = y_2$.

The diamond of Theorem 6.4 is precisely a failure of separation.

**Lemma 6.6 (Pull-forward / commutation).** Let $Q$ be separated and let $P$ be
an evolutionary path from $x$ to $y$ with label list $L$. If $\ell \in L$ and
$x \xrightarrow{\ell} w$, then there is a path from $w$ to $y$ with label list
$L'$ satisfying $\{\ell\} \uplus \overline{L'} = \overline{L}$.

*Proof.* Induction on $P$, written $x \xrightarrow{\ell_1} x_1
\rightsquigarrow y$ with labels $\ell_1 :: L_1$. If $\ell_1 = \ell$, separation
gives $x_1 = w$ and we take $L' = L_1$. Otherwise $\ell \in L_1$; and
$x_1 \neq w$, since $x_1 = w$ would force $\ell_1 = \ell$ by (A2). Apply (A3) to
$x \xrightarrow{\ell_1} x_1$ and $x \xrightarrow{\ell} w$ to obtain $v$ with
$x_1 \xrightarrow{\ell} v$ and $w \xrightarrow{\ell_1} v$. By induction applied
to the path $x_1 \rightsquigarrow y$ and the step $x_1 \xrightarrow{\ell} v$,
there is a path $v \rightsquigarrow y$ with labels $L''$ and $\{\ell\} \uplus
\overline{L''} = \overline{L_1}$. Prefix $w \xrightarrow{\ell_1} v$ and use
commutativity of multiset union. $\square$

**Theorem 6.7 (Endpoint rigidity).** In a separated quotient system, the
endpoint of an evolutionary path is determined by its source and its *multiset*
of labels: if $x \rightsquigarrow y$ with labels $L_1$, $x \rightsquigarrow z$
with labels $L_2$, and $\overline{L_1} = \overline{L_2}$, then $y = z$.

*Proof.* Strong induction on $|L_1|$. If $L_1$ is empty so is $L_2$, and $y = x
= z$. Otherwise write the first path as $x \xrightarrow{\ell_1} x_1
\rightsquigarrow y$; then $\ell_1 \in L_2$, so Lemma 6.6 rewrites the second
path as a path $x_1 \rightsquigarrow z$ whose labels, after cancelling
$\ell_1$, match those of $x_1 \rightsquigarrow y$. Apply the induction
hypothesis at $x_1$. $\square$

**Theorem 6.8 (Faithfulness on futures).** In a separated system,
$\mathrm{decomp}$ is injective on the stages reachable from any fixed object:
if $x \rightsquigarrow y$, $x \rightsquigarrow z$ and $\mathrm{decomp}(y) =
\mathrm{decomp}(z)$, then $y = z$.

*Proof.* Conservation (Theorem 3.7) gives $\mathrm{decomp}(x) = \overline{L_1}
\uplus \mathrm{decomp}(y) = \overline{L_2} \uplus \mathrm{decomp}(z)$; the
hypothesis and cancellation give $\overline{L_1} = \overline{L_2}$; now apply
Theorem 6.7. $\square$

### 6.4 Arithmetic consequences

The arithmetic system is separated (cancellation: $pm_1 = pm_2 \Rightarrow m_1 =
m_2$), as is the deletion system on finite sets.

**Theorem 6.9 (Complete divisibility invariant).** For $m, n > 0$,
$$m \mid n \iff \mathrm{decomp}(m) \le \mathrm{decomp}(n),$$
and if $\mathrm{decomp}(m) = \mathrm{decomp}(n)$ then $m = n$.

*Proof.* Forward: divisibility is reachability (Theorem 5.5), and
$\mathrm{decomp}$ is monotone (Corollary 3.8). Backward: multiset containment is
$v_p(m) \le v_p(n)$ for all $p$ (Proposition 5.4), which is divisibility. For
the second statement, apply Theorem 6.8 with $x = mn$, from which both $m$ and
$n$ are reachable. $\square$

---

## 7. Classification of futures

Theorem 6.8 says $\mathrm{decomp}$ is injective on futures. Is it *surjective*
onto the sub-multisets of $\mathrm{decomp}(x)$?

### 7.1 Saturation

**Definition 7.1.** A quotient system is *saturated* if a label available one
step later was already available now: whenever $x \xrightarrow{\ell} y$ and
$y \xrightarrow{\ell'} z$, there exists $w$ with $x \xrightarrow{\ell'} w$.

**Theorem 7.2 (Saturation is independent of (A1)–(A3)).** Consider the two-step
chain $2 \xrightarrow{b} 1 \xrightarrow{a} 0$ (labels $b \ne a$, rank $x \mapsto
x$). It is a quotient system — all diamond hypotheses are vacuous — with
$\mathrm{decomp}(2) = \{a, b\}$; yet $a \in \mathrm{decomp}(2)$ while no
$a$-labelled step leaves $2$. Hence the system is not saturated, and
availability of labels does not follow from (A1)–(A3).

**Lemma 7.3 (Immediate availability).** In a saturated system, every label
occurring in $\mathrm{decomp}(x)$ labels some step out of $x$.

*Proof.* Induct along a complete path out of $x$: the first label is available
by construction, and any later label is pulled back one step at a time by
saturation. $\square$

**Theorem 7.4 (Surjectivity on futures).** In a saturated system, every $M \le
\mathrm{decomp}(x)$ equals $\mathrm{decomp}(y)$ for some stage $y$ reachable
from $x$.

*Proof.* Strong induction on $\mathrm{ht}(x)$. If $M = \mathrm{decomp}(x)$, take
$y = x$. Otherwise there is $\ell \in \mathrm{decomp}(x)$ with $M \le
\mathrm{decomp}(x) \setminus \{\ell\}$; by Lemma 7.3 there is a step $x
\xrightarrow{\ell} w$, and by Theorem 3.5 $\mathrm{decomp}(w) =
\mathrm{decomp}(x) \setminus \{\ell\}$ and $\mathrm{ht}(w) < \mathrm{ht}(x)$.
Apply the induction hypothesis at $w$ and prepend the step. $\square$

### 7.2 The classification theorem

**Theorem 7.5 (Classification of futures).** In a separated, saturated quotient
system, for every $M \le \mathrm{decomp}(x)$ there is a *unique* stage $y$ with
$x \rightsquigarrow y$ and $\mathrm{decomp}(y) = M$. Equivalently,
$\mathrm{decomp}$ is a bijection
$$\{\, y : x \rightsquigarrow y \,\} \;\xrightarrow{\ \sim\ }\;
\{\, M : M \le \mathrm{decomp}(x) \,\}.$$

*Proof.* Existence by Theorem 7.4, uniqueness by Theorem 6.8. $\square$

**Theorem 7.6 (Every ordering is realised).** In a saturated system, for every
list $L$ with $\overline{L} = \mathrm{decomp}(x)$ there is a complete
evolutionary path out of $x$ whose label list is exactly $L$. Hence

> **Complete paths are exactly the permutations of the invariant:** a list $L$
> is the label list of a complete evolutionary path out of $x$ if and only if
> $\overline{L} = \mathrm{decomp}(x)$.

*Proof.* Induction on $\mathrm{ht}(x)$. If $L$ is empty then $\mathrm{decomp}(x)
= \varnothing$, so $x$ is terminal (Theorem 3.6) and the empty path works. If
$L = \ell :: L'$ then $\ell \in \mathrm{decomp}(x)$, so Lemma 7.3 provides
$x \xrightarrow{\ell} w$, and $\overline{L'} = \mathrm{decomp}(w)$ by Theorem
3.5 and cancellation; apply the induction hypothesis at $w$. The converse is
Proposition 3.4. $\square$

### 7.3 The two classical instances

Both the arithmetic and the deletion systems are saturated. For arithmetic: if
$n = pm$ and $m = qk$ then $n = q(pk)$, so the label $q$ is available at $n$.
For finite sets: if $b \in S \setminus \{a\}$ then $b \in S$.

**Corollary 7.7 (Divisor classification).** For $n > 0$ and any sub-multiset $M$
of the prime factorisation of $n$, there is a unique divisor $m \mid n$ with
$\mathrm{decomp}(m) = M$. The divisors of $n$ are in bijection with the
sub-multisets of its prime factorisation; in particular, if $n = \prod_i
p_i^{e_i}$ then $n$ has $\prod_i (e_i + 1)$ divisors.

**Corollary 7.8 (Subset classification).** The stages reachable from a finite set
$S$ are exactly its subsets, each occurring once.

**Corollary 7.9 (Factorisation chains).** For $n > 0$, a list $L$ of primes is
the label list of a complete factorisation chain $n \rightsquigarrow 1$ if and
only if $L$ is a permutation of the prime factor list of $n$. For instance,
$n = 60$ admits exactly the $4!/2! = 12$ orderings of $[2,2,3,5]$.

---

## 8. Path integrals: weights, actions and arithmetic functions

Theorem 3.7 says the invariant behaves like a potential. Weighting the labels
makes this literal.

### 8.1 Abstract weights

**Definition 8.1.** Let $M$ be a commutative monoid and $w : \Lambda \to M$. The
*path weight* is
$$W_w(x) = \prod_{\ell \in \mathrm{decomp}(x)} w(\ell),$$
the product taken over the invariant with multiplicity. When $M$ is written
additively, the same construction is the *path action*
$A_w(x) = \sum_{\ell \in \mathrm{decomp}(x)} w(\ell)$.

**Theorem 8.2 (One-step law and conservation).**
- If $x$ is terminal, $W_w(x) = 1$ (resp. $A_w(x) = 0$).
- If $x \xrightarrow{\ell} y$ then $W_w(x) = w(\ell)\, W_w(y)$ (resp. $A_w(x) =
  w(\ell) + A_w(y)$).
- For *any* evolutionary path from $x$ to $y$ with labels $L$,
  $$W_w(x) = \Big(\prod_{\ell \in L} w(\ell)\Big) W_w(y), \qquad
    A_w(x) = \Big(\sum_{\ell \in L} w(\ell)\Big) + A_w(y).$$
  In particular the accumulated weight of a path depends only on its endpoints:
  two paths with the same endpoints accumulate the same weight.

*Proof.* Immediate from Theorems 3.5, 3.6 and 3.7. $\square$

Taking the constant weight $1$ in $(\mathbb{N}, +)$ recovers the height:
$A_{\mathbf{1}}(x) = \mathrm{ht}(x)$.

### 8.2 Characterisation of classical arithmetic function classes

Specialise to the arithmetic quotient system, where the labels are the primes.
First a basic additivity fact.

**Lemma 8.3.** For $m, n > 0$, $\mathrm{decomp}(mn) = \mathrm{decomp}(m) \uplus
\mathrm{decomp}(n)$. Consequently $W_w(mn) = W_w(m) W_w(n)$ and $A_w(mn) =
A_w(m) + A_w(n)$, and $W_w(p) = w(p)$, $A_w(p) = w(p)$ for $p$ prime.

**Theorem 8.4 (Completely multiplicative functions are exactly path weights).**
Let $M$ be a commutative monoid and $g : \mathbb{N} \to M$. Then
$$\big(g(1) = 1 \ \text{ and }\ g(mn) = g(m)g(n)\ \text{ for all } m, n > 0\big)
\iff \big(g(n) = W_g(n)\ \text{ for all } n > 0\big),$$
where on the right $g$ is restricted to the prime labels.

*Proof.* ($\Rightarrow$) Write $n$ as a product of its prime factor list $L$; a
list induction using $g(1) = 1$ and multiplicativity gives $g(n) = \prod_{p \in
L} g(p)$, which is $W_g(n)$ by Lemma 8.3. ($\Leftarrow$) $g(1) = W_g(1) = 1$
since $1$ is terminal, and $g(mn) = W_g(mn) = W_g(m)W_g(n) = g(m)g(n)$ by Lemma
8.3. $\square$

**Theorem 8.5 (Completely additive functions are exactly path actions).** Let
$M$ be an abelian group and $f : \mathbb{N} \to M$. Then
$$\big(f(mn) = f(m) + f(n)\ \text{ for all } m, n > 0\big) \iff
\big(f(n) = A_f(n)\ \text{ for all } n > 0\big).$$
No normalisation hypothesis at $1$ is needed: $f(1) = 0$ is forced by
$f(1) = f(1 \cdot 1) = f(1) + f(1)$.

**Examples 8.6.**
- Constant weight $w \equiv 1$ (in $\mathbb{Z}$): $A_w(n) = \Omega(n)$, the
  number of prime factors with multiplicity. This is the height of the
  arithmetic flow.
- Indicator weight $w(q) = [\,q = p\,]$: $A_w(n) = v_p(n)$, the $p$-adic
  valuation. In particular each $v_p$ is completely additive — a one-line
  consequence of the framework.
- Weight $w(p) = -1$: $W_w(n) = (-1)^{\Omega(n)} = \lambda(n)$, the Liouville
  function, which is therefore completely multiplicative by Theorem 8.4.
- Weight $w(p) = p^{-s}$ in $\mathbb{C}^\times$: $W_w(n) = n^{-s}$, exhibiting
  the Dirichlet-series kernel as a path weight.

Slogan: **completely additive arithmetic functions are precisely the conserved
potentials of the multiplicative evolutionary flow.**

---

## 9. Algorithmic content

The theory is constructive and yields directly implementable algorithms.

**Algorithm A (Normal form and invariant).** Given an object $x$ and an oracle
returning some step out of $x$ when one exists: repeatedly apply a step, pushing
each label onto a list, until reaching a terminal object. Termination is
guaranteed by (A1) after at most $\mathrm{rank}(x)$ iterations. Theorem 3.1
certifies that the result is independent of the oracle's choices. In the
arithmetic instance with the "smallest prime factor" oracle this is trial
division, running in $O(\sqrt{n})$ arithmetic operations per extracted factor.

**Algorithm B (Path enumeration).** In a saturated system, Theorem 7.6 says the
complete paths out of $x$ are enumerated by the distinct permutations of
$\mathrm{decomp}(x)$: repeatedly choose a *distinct* available label, recurse.
The number of complete paths is therefore the multinomial coefficient
$$\frac{|\mathrm{decomp}(x)|!}{\prod_{\ell} m_\ell!},$$
where $m_\ell$ is the multiplicity of $\ell$ — a purely combinatorial count with
no residual dependence on the ambient system. (This equality of counts is the
subject of Open Problem 1 below; the bijective half, that the label lists are
exactly the permutations, is Theorem 7.6.)

**Algorithm C (Future enumeration).** In a separated, saturated system, Theorem
7.5 enumerates the reachable stages by enumerating the sub-multisets of
$\mathrm{decomp}(x)$: choose a multiplicity $0 \le k_\ell \le m_\ell$ for each
distinct label. The count is $\prod_\ell (m_\ell + 1)$ — in arithmetic, the
divisor-counting function $\tau(n)$.

**Algorithm D (Exchange closure / diamond check).** To verify (A3) for a finite
presented system, enumerate all pairs of distinct steps out of a common source
and search for a closing $z$. Cost $O(|{\to}|^2 \cdot |\alpha|)$ in the worst
case; this is what certifies that a candidate relation is a quotient system.

---

## 10. Discussion

### 10.1 What the theory explains

The classical uniqueness theorems are not independent accidents. Each is the
Decomposition Theorem instantiated at a step relation whose exchange axiom is
the subject-specific commutation lemma:

| Instance | Quotient step | Exchange axiom is | Invariant |
|---|---|---|---|
| Positive integers | divide by a prime | Euclid's lemma | prime factorisation |
| Finite sets | delete an element | commutation of deletions | the set itself |
| Multisets | delete an element | multiset cancellation | the multiset itself |
| Finite groups (classically) | quotient by a maximal normal subgroup | Zassenhaus butterfly lemma | multiset of simple factors |

The last row is the historical source of the exchange axiom's shape and the
motivating target of the abstract framework; the first three rows are developed
in full above.

### 10.2 What the sharpness results tell us

The three counterexamples of §4 are more informative than they look. Dropping
exchange destroys even the *length* of decompositions — a shortcut edge in a
poset is enough. Dropping label determinacy leaves destinations unique but
labels ambiguous, showing that (A2) is exactly the axiom responsible for the
labelled refinement of the invariant. Dropping termination leaves the theory
without any complete path to speak about, which is why the rank function, though
non-canonical, cannot be omitted; it is later superseded by the canonical height
$\mathrm{ht} \le \mathrm{rank}$.

### 10.3 The hierarchy of hypotheses

The paper isolates a strict hierarchy:

- **(A1)–(A3)** ⟹ unique terminal object, unique label multiset, conservation,
  grading, confluence, functoriality, universality into multiset deletion.
- **+ separation** ⟹ the universal representation is *faithful* on futures;
  endpoints determined by label multisets.
- **+ saturation** ⟹ the universal representation is *surjective* on futures;
  full classification of futures and of complete paths.

Each added hypothesis is genuinely independent: separation fails in the diamond
(Theorem 6.4), saturation fails in the two-step chain (Theorem 7.2).

### 10.4 Limitations

The theory as developed assumes $\mathbb{N}$-valued rank, hence decompositions of
finite length; transfinite or infinite decompositions (e.g. filtrations of
infinite length) fall outside it. The exchange axiom is a *one-step* closure
condition; systems whose diamonds only close after several steps (weaker forms
of confluence) are not covered, and it would be interesting to know whether the
label multiset invariant survives such a weakening. Finally, the theory is
qualitative: it says nothing about the *cost* of finding a step, which is where
all the difficulty lies in, e.g., integer factorisation.

---

## 11. Open problems

**1. Multinomial path census.** In a separated, saturated quotient system with
$\mathrm{decomp}(x) = M$, is the number of complete evolutionary paths out of
$x$ equal to the multinomial coefficient $|M|! / \prod_\ell m_\ell!$? Theorem
7.6 already identifies the label lists of complete paths with the permutations of
$M$, so the question reduces to a purely combinatorial count of lists with a
prescribed multiset — with no residual dependence on the ambient system. This is
the natural next result.

**2. Butterfly certification of composition series.** Verify that the classical
composition-series setting (finite groups, steps given by maximal normal
subgroups, labels given by isomorphism classes of simple quotients) satisfies
(A1)–(A3), thereby deriving the Jordan–Hölder theorem as an instance rather than
an analogue. The exchange axiom here *is* the Zassenhaus butterfly lemma; the
work lies in the bookkeeping of isomorphism classes as labels.

**3. Weakened exchange.** Does the Decomposition Theorem survive if (A3) is
weakened to "the diamond closes after finitely many steps on each side, with
matching label multisets"? A positive answer would cover rewriting systems that
are confluent but not locally so in one step.

**4. Euler products and Dirichlet series.** Theorems 8.4 and 8.5 characterise
completely multiplicative and completely additive functions as path weights and
actions. The natural successor is to express the Euler product / Dirichlet
series formalism as a generating function over evolutionary paths, i.e. to sum
$W_w$ over the future of an object and recover $\prod_\ell (1 - w(\ell))^{-1}$
in the saturated case.

**5. Quantitative and resource-bounded versions.** Replace the qualitative rank
by a cost model and ask for the *cheapest* complete evolutionary path. Theorem
3.1 says all such paths have the same labels; with costs attached to *steps*
rather than labels, the optimisation becomes nontrivial and connects the theory
to scheduling.

**6. Non-terminating extensions.** Develop a version with ordinal-valued rank,
or with a well-founded relation in place of $\mathbb{N}$, to accommodate
transfinite decompositions.

---

## 12. Conclusion

Defining the vocabulary before attacking the conjecture paid off precisely as
intended. Once "quotient step" is pinned to three axioms — termination, label
determinacy, exchange — the full decomposition conjecture becomes a short
induction whose only real content is that two labels commute inside a multiset;
the sharpness of the axiom set becomes a checkable question with three
three-element answers; and the resulting invariant turns out to be functorial,
universal, and — under two further, independently necessary hypotheses —
a complete classifier of the future of an object.

Instantiating the framework at division-by-a-prime recovers the fundamental
theorem of arithmetic with Euclid's lemma appearing exactly as the exchange
axiom; instantiating at element-deletion recovers the combinatorics of finite
sets; and the morphism between them transports squarefreeness and injectivity of
the prime-product map for free. Weighting the labels turns the invariant into a
conserved potential and characterises the completely multiplicative and
completely additive arithmetic functions as exactly the path weights and path
actions of their own restrictions to the primes.

Unique decomposition, on this account, is not a family of coincidences. It is a
single fact about labelled, terminating, exchange-closed relations, wearing
different clothes.
