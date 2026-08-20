# Reflective Type Theory and the Modal Fixed-Point Language

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

A *reflective* propositional language is one whose propositions may refer to the
availability of their own evidence, by means of a former $\Box A$ read "there is
accessible evidence for $A$", and which additionally admits a fixed-point binder
$\mu X.\,A$. Three claims about such languages are commonly conflated in the
literature and in folklore: that a concrete reflective proposition can be provable
without being provably provable; that the reflective grammar properly extends a
non-reflective type-theoretic core; and that reflective proposition codes are, up to
notation, the formulas of a modal fixed-point calculus. This paper separates the
three, gives each an exact statement, and delimits each with a matching negative
result.

We prove: (i) a **retraction theorem** — a partial decoder is a left inverse to the
inclusion of the non-reflective core, whence the inclusion is injective and the
reflected atom $\Box p$ provably lies outside its image, so the extension is proper;
(ii) a **grammar isomorphism** — explicit mutually inverse translations between
reflective proposition codes and modal fixed-point formulas, constructor for
constructor, commuting with iterated reflection and iterated necessity; (iii) a
**finite reflection witness** — in the three-world non-transitive chain
$2 \to 1 \to 0$, the proposition true only at the middle world satisfies $\Box M$ at
world $2$ but not $\Box\Box M$, so $\Box M \wedge \neg\Box\Box M$ is inhabited in a
model of size three; (iv) a **transitivity obstruction** — on every transitive frame
$\Box P \subseteq \Box\Box P$ for all $P$, hence no reflection witness exists there,
which shows the chain's non-transitivity is not incidental but necessary; and (v) a
**diagonal incompleteness theorem** for an abstract diagonal theory: soundness plus a
diagonal sentence forces a true unprovable sentence.

We also record a refuted conjecture: not every unrestricted fixed-point code carries a
monotone set-theoretic interpretation, because negative occurrences of the bound
variable under function space induce antitone operators, for which Knaster–Tarski
gives no least fixed point. The organising theme is *variance*: transitivity governs
iteration of the proof modality, positivity governs iteration to a least fixed point,
and the syntactic isomorphism requires neither.

**Keywords:** reflective type theory, provability modality, modal $\mu$-calculus,
Kripke frames, transitivity, positivity, diagonal incompleteness, grammar isomorphism.

---

## 1. Introduction

### 1.1 The reflective instinct

Let $A$ be a proposition of some formal language and suppose $A$ is provable. A
persistent intuition holds that "$A$ is provable" must then itself be provable: the
proof is available, so its availability is a checkable fact. In arithmetic, under
suitable formalisation, this intuition is correct and is the content of the second
Hilbert–Bernays–Löb derivability condition, $\Box A \to \Box\Box A$, the modal axiom
**4**. But it is a *condition*, not a theorem of pure logic, and its validity depends
on structural properties of the provability relation. Making that dependence exact,
in a setting small enough to be inspected in full, is the first goal of this paper.

### 1.2 Reflective propositions as types

A second motivation is type-theoretic. Consider a small propositional core with atoms,
$\bot$, $\top$, product (conjunction), and function space (implication). Adding a
former $\Box A$ turns propositions into objects that can speak of their own evidence;
adding a fixed-point binder $\mu X.\,A$ turns them into objects that can be defined by
self-reference. Both additions are natural for languages that reason about programs
that reason about proofs — proof-carrying code, staged systems, reflective tactic
languages, layered trust architectures.

Two questions follow. Is $\Box$ genuinely new, or definable in the core? And what,
exactly, is the resulting grammar? Section 3 answers the first with a retraction and
Section 4 answers the second with an isomorphism onto the modal fixed-point language.

### 1.3 Contributions and non-claims

We are deliberately conservative about what is claimed.

- The properness result is **syntactic**. It states that the reflective grammar is not
  the image of the core grammar under the canonical inclusion. It does *not* claim
  non-conservativity of a full dependent metatheory over its non-reflective fragment.
- The grammar isomorphism is an **isomorphism of formula sets**, established by mutually
  inverse structural translations. It does *not* assert soundness or completeness of any
  proof calculus, nor agreement of provable theorems in the two systems.
- The finite witness is a statement about a **specific frame**. It coexists with, and is
  sharply delimited by, the transitive impossibility theorem.
- The refuted monotonicity conjecture is stated as a refutation, not a repair; we
  indicate the standard positivity guard that restores the intended semantics.

---

## 2. A non-reflective core and its reflective extension

### 2.1 Syntax

Fix a set $\mathrm{At}$ of atoms.

**Definition 2.1 (Core propositions).** The set $\mathcal{M}$ of *core* (non-reflective)
propositions is generated by
$$A ::= p \ (p \in \mathrm{At}) \;\mid\; \bot \;\mid\; \top \;\mid\; A \wedge A \;\mid\; A \to A .$$

**Definition 2.2 (Reflective propositions).** The set $\mathcal{R}$ of *reflective*
propositions is generated by
$$A ::= p \;\mid\; X_n \ (n \in \mathbb{N}) \;\mid\; \bot \;\mid\; \top \;\mid\; A \wedge A \;\mid\; A \to A \;\mid\; \Box A \;\mid\; \mu.\,A ,$$
where $X_n$ are de Bruijn indices for fixed-point variables and $\mu.\,A$ binds the
next available index. We write $\mu X.\,A$ informally for readability. Both $\mathcal{M}$
and $\mathcal{R}$ have decidable equality, being free term algebras over $\mathrm{At}$.

The reflective grammar adds exactly three constructors: bound variables, the
reflection former $\Box$, and the fixed-point binder $\mu$. Reading $\Box A$ as
"there is accessible evidence for $A$" makes $\mathcal{R}$ the language in which a
system can state facts about its own proof-availability, and $\mu$ the device by which
such statements may be recursive.

### 2.2 Inclusion and partial decoding

**Definition 2.3 (Inclusion).** $\iota : \mathcal{M} \to \mathcal{R}$ is defined by
structural recursion: $\iota(p) = p$, $\iota(\bot) = \bot$, $\iota(\top) = \top$,
$\iota(A \wedge B) = \iota A \wedge \iota B$, $\iota(A \to B) = \iota A \to \iota B$.

**Definition 2.4 (Partial decoder).** $\delta : \mathcal{R} \to \mathcal{M} \cup \{\uparrow\}$
(where $\uparrow$ denotes failure) is defined by
$$
\delta(p) = p,\quad \delta(\bot) = \bot, \quad \delta(\top) = \top,
$$
$$
\delta(A \wedge B) = \delta A \wedge \delta B \text{ if both succeed, else } \uparrow, \qquad
\delta(A \to B) = \delta A \to \delta B \text{ if both succeed, else } \uparrow,
$$
$$
\delta(X_n) = \uparrow, \qquad \delta(\Box A) = \uparrow, \qquad \delta(\mu.\,A) = \uparrow .
$$

The decoder is total on the core-shaped part of the grammar and fails exactly on the
three new constructors *at the head*. It is a syntactic invariant, computed in time
linear in the size of the input.

---

## 3. Reflection is a proper extension

**Theorem 3.1 (Retraction).** For every core proposition $A \in \mathcal{M}$,
$$\delta(\iota(A)) = A .$$

*Proof sketch.* Structural induction on $A$. The atomic and constant cases are
immediate from the defining equations. For $A \wedge B$: by definition
$\iota(A \wedge B) = \iota A \wedge \iota B$, and $\delta$ on a conjunction succeeds
precisely when both components decode; the induction hypotheses give $\delta(\iota A) = A$
and $\delta(\iota B) = B$, so the result is $A \wedge B$. The arrow case is identical.
$\square$

**Corollary 3.2 (Injectivity of the inclusion).** $\iota$ is injective.

*Proof sketch.* If $\iota(A) = \iota(B)$, apply $\delta$ to both sides and use
Theorem 3.1 twice to get $A = B$. $\square$

Injectivity alone does not show that the extension is proper; a bijection onto the
whole of $\mathcal{R}$ would also be injective. Properness needs a witness *outside*
the image, and the retraction supplies the invariant that certifies one.

**Theorem 3.3 (Properness of reflection).** For every atom $p$, there is no core
proposition $A$ with $\iota(A) = \Box p$.

*Proof sketch.* Suppose $\iota(A) = \Box p$. Applying $\delta$ to the left side gives
$A$ by Theorem 3.1; applying it to the right side gives $\uparrow$, since $\delta$
fails on any proposition whose head constructor is $\Box$. A defined value cannot equal
failure, contradiction. $\square$

**Proposition (The decoder is a complete invariant).** For all $A \in \mathcal{R}$ and
$B \in \mathcal{M}$,
$$\delta(A) = B \iff \iota(B) = A .$$
Thus decoding succeeds *exactly* on the image of the inclusion, and the image is a
decidable subset of the reflective grammar.

*Proof sketch.* Right to left is Theorem 3.1. Left to right is an induction on $A$: the
leaf cases are immediate, the two compound cases follow by analysing the two recursive
calls (both must succeed for the whole to succeed) and applying the induction hypotheses,
and the three cases $X_n$, $\Box A$, $\mu.\,A$ are vacuous because $\delta$ fails there.
$\square$

**Remark 3.4.** The same argument, with the same decoder, shows that $\Box B$ for an
arbitrary argument $B$, that $\mu X.\,A$, and that any
proposition with a free fixed-point variable at the head lie outside the image. Note the
methodological point: properness is established by an explicit *retraction plus a failing
head case*, not by counting constructors, and not by an appeal to "obviously a new
symbol". The invariant survives any renaming or re-encoding of the core language that
factors through $\iota$.

**Remark 3.5 (Scope).** Theorem 3.3 is a statement about proposition *codes*. It is
compatible with a semantics in which $\Box p$ happens to be extensionally equal to some
core proposition in a particular model; what it excludes is a syntactic definition of
$\Box$ inside the core grammar.

---

## 4. Exact correspondence with a modal fixed-point grammar

### 4.1 The modal fixed-point language

**Definition 4.1 (Modal fixed-point formulas).** Over the same atoms, the set
$\mathcal{L}_\mu$ of modal fixed-point formulas is generated by
$$\varphi ::= p \;\mid\; Z_n \;\mid\; \mathbf{f} \;\mid\; \mathbf{t} \;\mid\; \varphi \wedge \varphi \;\mid\; \varphi \Rightarrow \varphi \;\mid\; \Box\varphi \;\mid\; \mu.\,\varphi ,$$
with $Z_n$ de Bruijn fixed-point variables, $\mathbf f$ falsum, $\mathbf t$ verum,
$\Box$ necessity, and $\mu$ the least-fixed-point binder. This is the (implication-based
presentation of the) modal $\mu$-calculus, the standard specification language for
reactive and concurrent systems.

### 4.2 Translations

**Definition 4.2.** Define $\tau : \mathcal{R} \to \mathcal{L}_\mu$ by
$$\tau(p) = p,\ \ \tau(X_n) = Z_n,\ \ \tau(\bot) = \mathbf f,\ \ \tau(\top) = \mathbf t,$$
$$\tau(A \wedge B) = \tau A \wedge \tau B,\ \ \tau(A \to B) = \tau A \Rightarrow \tau B,\ \ \tau(\Box A) = \Box \tau A,\ \ \tau(\mu.\,A) = \mu.\,\tau A ,$$
and $\sigma : \mathcal{L}_\mu \to \mathcal{R}$ by the same table read in reverse.

**Theorem 4.3 (Left inverse).** $\sigma(\tau(A)) = A$ for all $A \in \mathcal{R}$.

**Theorem 4.4 (Right inverse).** $\tau(\sigma(\varphi)) = \varphi$ for all
$\varphi \in \mathcal{L}_\mu$.

*Proof sketch (both).* Structural induction. Every leaf case ($p$, $X_n$/$Z_n$,
$\bot$/$\mathbf f$, $\top$/$\mathbf t$) holds by definitional unfolding. Each of the four
compound cases (conjunction, implication, modality, binder) is closed by rewriting with
the induction hypotheses, because the translations are defined constructor-wise with no
side conditions and no case analysis on subterms. $\square$

**Corollary 4.5 (Grammar isomorphism).** $\tau$ and $\sigma$ constitute a bijection
$$\mathcal{R} \;\cong\; \mathcal{L}_\mu$$
which maps each constructor to its counterpart. Reflective proposition codes and modal
fixed-point formulas are the same objects presented in different notation.

**Theorem 4.6 (Compatibility with iteration).** For all $n \in \mathbb{N}$ and
$A \in \mathcal{R}$,
$$\tau\big(\Box^n A\big) = \Box^n\,\tau(A),$$
where $\Box^n$ denotes $n$-fold application of the respective modality on each side.

*Proof sketch.* Induction on $n$, generalising over $A$. The base case is trivial. For
the step, write $\Box^{n+1} A = \Box^{n}(\Box A)$ using the "apply once first" form of
iteration and invoke the induction hypothesis at $\Box A$; the constructor clause
$\tau(\Box B) = \Box \tau(B)$ does the rest. $\square$

**Discussion 4.7.** Corollary 4.5 is what licenses transport of tools. For instance,
under $\sigma$ the modal formula $\mu Z.\,\Box Z$ — a canonical well-foundedness
assertion, true exactly at states from which every path of accessibility terminates —
corresponds to the reflective proposition $\mu X.\,\Box X$, the recursive proposition
of "provable all the way down". Model-checking algorithms, automata-theoretic
translations, and complexity bounds for the modal fixed-point language are therefore
statements about reflective proposition codes verbatim. What is *not* transported for
free is a proof calculus: the isomorphism is on formulas, not on derivations, and
completeness of any particular reflective proof system remains a separate question.

---

## 5. Kripke semantics of reflective provability

### 5.1 Frames and the modality

**Definition 5.1 (Frame).** A *frame* $F$ consists of a set $W$ of proof states
(worlds) and a binary accessibility relation $\to\;\subseteq W \times W$, where
$w \to v$ reads "$v$ is reachable from $w$ by one step of reasoning".

**Definition 5.2 (Propositions and the box operator).** A proposition over $F$ is a
subset $P \subseteq W$. Define
$$\Box P \;=\; \{\, w \in W : \forall v,\ w \to v \implies v \in P \,\}.$$

Thus $w \in \Box P$ says: every state one step of reasoning away from $w$ satisfies $P$.
Note the boundary case: if $w$ is *terminal* (has no successors), then $w \in \Box P$
vacuously for every $P$. Terminal worlds make reflection trivially true, and any attempt
to exhibit failure of iteration must avoid them.

**Definition 5.3 (Reflection witness).** For a frame $F$, a proposition $P$ and a world
$w$, say $w$ is a *reflection witness* for $P$ if
$$w \in \Box P \quad\text{and}\quad w \notin \Box\Box P,$$
i.e. $P$ is provable at $w$ but not provably provable at $w$. Semantically this is
inhabitation of the reflective proposition $\Box P \wedge \neg\Box\Box P$ at $w$.

### 5.2 The transitivity obstruction

**Theorem 5.4 (Transitivity validates axiom 4).** Let $F$ be a frame whose accessibility
relation is transitive: $a \to b$ and $b \to c$ imply $a \to c$. Then for every
proposition $P$,
$$\Box P \;\subseteq\; \Box\Box P .$$

*Proof sketch.* Let $w \in \Box P$. To show $w \in \Box\Box P$, fix $v$ with $w \to v$
and $u$ with $v \to u$; we must show $u \in P$. Transitivity gives $w \to u$, and
$w \in \Box P$ applied to this edge yields $u \in P$. $\square$

**Corollary 5.5 (Transitive impossibility).** On a transitive frame, no world is a
reflection witness for any proposition. Equivalently, $\Box P \wedge \neg\Box\Box P$
is uninhabited on every transitive frame.

*Proof sketch.* A reflection witness $w$ for $P$ would give $w \in \Box P$ and
$w \notin \Box\Box P$, contradicting the inclusion of Theorem 5.4. $\square$

Corollary 5.5 is the precise sense in which the reflective instinct of Section 1.1 is
*correct*: it is correct exactly under the hypothesis that reasoning composes.

### 5.3 The finite witness

**Definition 5.6 (The chain frame).** Let $C$ be the frame with $W = \{0,1,2\}$ and
accessibility relation given by exactly the two edges
$$2 \to 1, \qquad 1 \to 0 ,$$
and no others. Let $M = \{1\}$, the *middle proposition*.

**Theorem 5.7 (Finite reflection witness).** In the chain frame $C$, the world $2$ is a
reflection witness for $M$:
$$2 \in \Box M \qquad\text{and}\qquad 2 \notin \Box\Box M .$$

*Proof sketch.* For the first claim, let $v$ satisfy $2 \to v$. By definition of the
edge set the only possibility is $v = 1$, and $1 \in M$; hence $2 \in \Box M$. For the
second, suppose $2 \in \Box\Box M$. Since $2 \to 1$, this gives $1 \in \Box M$. Since
$1 \to 0$, that in turn gives $0 \in M$, i.e. $0 = 1$, which is false. Hence
$2 \notin \Box\Box M$. $\square$

**Theorem 5.8 (The witness frame is non-transitive).** The accessibility relation of
$C$ is not transitive.

*Proof sketch.* Transitivity applied to $2 \to 1$ and $1 \to 0$ would produce the edge
$2 \to 0$, which is not in the edge set. $\square$

**Corollary (The whole ladder climbs).** On a transitive frame,
$\Box^{k} P \subseteq \Box^{k+1} P$ for every proposition $P$ and every $k \geq 1$.

*Proof sketch.* Apply Theorem 5.4 to the proposition $\Box^{k-1} P$, or equivalently induct
on $k$, at each stage using that $\Box$ is monotone: $P \subseteq Q$ implies
$\Box P \subseteq \Box Q$ directly from Definition 5.2. $\square$

**Corollary 5.9 (Exact boundary).** Failure of iterated provability is possible, and is
possible in a model with three worlds and two edges; and by Corollary 5.5 it is possible
*only* on non-transitive frames. Non-transitivity is therefore necessary and (in the
presence of the chain shape) sufficient.

**Remark 5.10 (Minimal shape of a witness).** Every reflection witness contains a
two-edge path. If $w$ is a witness for $P$, then $w \notin \Box\Box P$ forces some $v$
with $w \to v$ and $v \notin \Box P$, which in turn forces some $u$ with $v \to u$ and
$u \notin P$; while $w \in \Box P$ forces $v \in P$, hence $u \neq v$. So a witness
requires two edges $w \to v \to u$ with $v$ non-terminal, and in particular no witness
exists on a frame in which every successor is terminal. The worlds $w$ and $u$ may
however coincide: on the two-world cycle $0 \to 1 \to 0$ with $P = \{1\}$, the world $0$
is a reflection witness. Two edges is therefore the exact minimum, realisable with two
worlds when loops are allowed; the chain $C$ is the smallest loop-free realisation, in
which the two-edge path visits three distinct worlds. An exhaustive search over all
$2^{n^2}$ frames confirms that no witness exists for $n = 1$ and that witnesses exist for
$n = 2$ only on non-transitive cyclic frames.

**Remark 5.11 (Generality).** Nothing in Theorems 5.4–5.8 uses finiteness of $W$, and
the arguments go through verbatim for an indexed family of modalities $\Box_i$ with
accessibility relations $\to_i$, giving mixed principles $\Box_i P \subseteq \Box_i\Box_j P$
under the corresponding mixed transitivity $\to_i \circ \to_j \;\subseteq\; \to_i$.

---

## 6. Diagonal reflection and the incompleteness boundary

The frame results concern *self-transparency* of provability. A complementary limitation
concerns its *reach*. We isolate it abstractly, with no arithmetic and no coding.

**Definition 6.1 (Diagonal theory).** A *diagonal theory* $T$ consists of:
a set $S$ of sentences; a predicate $\mathrm{Prov} \subseteq S$; a predicate
$\mathrm{True} \subseteq S$; a **soundness** assumption
$$\forall s \in S,\ \mathrm{Prov}(s) \implies \mathrm{True}(s);$$
a distinguished sentence $D \in S$; and the **diagonal specification**
$$\mathrm{True}(D) \iff \neg\,\mathrm{Prov}(D) .$$

The diagonal specification is the entire content of "$D$ asserts its own unprovability";
in a concrete theory it is obtained from a fixed-point (self-reference) lemma, but here
it is taken as data.

**Theorem 6.2 (Diagonal incompleteness).** In any diagonal theory,
$$\mathrm{True}(D) \quad\text{and}\quad \neg\,\mathrm{Prov}(D) .$$

*Proof sketch.* First, $D$ is unprovable. Suppose $\mathrm{Prov}(D)$. Soundness gives
$\mathrm{True}(D)$, and the diagonal specification (left to right) gives
$\neg\mathrm{Prov}(D)$ — contradiction. Hence $\neg\mathrm{Prov}(D)$. Now apply the
diagonal specification right to left to obtain $\mathrm{True}(D)$. $\square$

**Remark 6.3.** The two clauses of Definition 6.1 are exactly the two used, and no more.
No structural property of $S$, no closure of $\mathrm{Prov}$ under modus ponens, and no
derivability condition is required. The theorem is therefore a statement about the *shape*
of self-reference, and it composes with the frame analysis as follows: a reasoning system
may fail to be self-transparent (Section 5) and, independently, fail to be exhaustive
(this section). Both failures are consequences of how the "provable" predicate is allowed
to interact with itself.

---

## 7. A refuted conjecture: unrestricted fixed points lack monotone semantics

The syntax of Section 2 imposes no restriction on where a bound variable may occur under
$\mu$. It is natural to conjecture that every such code nevertheless has the intended
least-fixed-point meaning: given a frame with world set $W$, a code $\mu X.\,A$ should
denote the least $S \subseteq W$ with $\Phi_A(S) = S$, where $\Phi_A$ is the operator
sending a valuation of $X$ to the interpretation of $A$.

**Refutation 7.1.** The conjecture is false. $\Phi_A$ need not be monotone, and without
monotonicity Knaster–Tarski does not apply and a least fixed point need not exist.

*Argument.* Interpretation of implication is contravariant in its antecedent:
$$[\![A \to B]\!]_{S} = \big(W \setminus [\![A]\!]_{S}\big) \cup [\![B]\!]_{S}$$
in the classical set reading (and analogously in a Kripke-monotone reading). Hence if
$X$ occurs to the left of an arrow, enlarging the valuation $S$ *shrinks* the
interpretation. Concretely take $A = (X \to \bot)$, so
$\Phi_A(S) = W \setminus S$. Then $\Phi_A$ is antitone: $S \subseteq S'$ implies
$\Phi_A(S') \subseteq \Phi_A(S)$. On $|W| = 1$, $\Phi_A$ has no fixed point at all
($\Phi_A(\emptyset) = W \ne \emptyset$ and $\Phi_A(W) = \emptyset \ne W$), so there is no
least fixed point to designate as the meaning of $\mu X.\,(X \to \bot)$. $\square$

**Definition 7.2 (Positivity guard).** Assign a polarity to each occurrence of a bound
variable: occurrences are positive at the top level, polarity is preserved by
conjunction, by the consequent of an implication, by $\Box$, and by $\mu$, and is
*flipped* by the antecedent of an implication. A code $\mu X.\,A$ is *guarded* if every
free occurrence of $X$ in $A$ is positive.

**Proposition 7.3 (Repair).** If $\mu X.\,A$ is guarded then $\Phi_A$ is monotone on the
powerset lattice of $W$, hence by Knaster–Tarski it possesses a least fixed point, and
the intended semantics is well defined.

*Proof sketch.* Induction on $A$, tracking polarity. Atoms and $\bot,\top$ give constant
operators; conjunction of monotone operators is monotone; $\Box$ is monotone because
$P \subseteq Q$ implies $\Box P \subseteq \Box Q$ directly from Definition 5.2; for
implication, the consequent contributes monotonically while the antecedent — which by the
guard contains no free occurrence of $X$ with the wrong polarity — contributes a constant
or a monotone complemented factor of the correct variance; the binder case follows from
monotonicity of least fixed points in monotone parameters. $\square$

**Remark 7.4 (The variance theme).** Sections 5 and 7 exhibit the same phenomenon at two
levels. Iterating the *modality* is legitimate exactly under transitivity; iterating an
operator to a *fixed point* is legitimate exactly under positivity. Both are side
conditions on how self-reference may be composed. By contrast the isomorphism of
Section 4 needs neither: syntax is blind to variance, and the price is that the
isomorphism transports formulas rather than meanings — a semantic transport statement
must carry the guard along.

---

## 8. Algorithms

The results of Sections 3–5 are effective, and each corresponds to a short algorithm
useful for exploring the theory.

### 8.1 Structural translation and round-trip certification

Given a reflective code $A$, computing $\tau(A)$ is a single bottom-up pass, linear in
the number of nodes; likewise $\sigma$. Corollary 4.5 can be certified on any finite set
of codes by computing $\sigma(\tau(A))$ and comparing with $A$ structurally, which is
again linear. This provides a cheap consistency check on any implementation of the
translation tables and, in exhaustive form (all codes up to a given size), an empirical
confirmation of the isomorphism on a truncation of the language.

### 8.2 Exhaustive code enumeration

Codes of a given size can be enumerated by a standard recursive scheme: for size $1$
emit atoms, variables, $\bot$, $\top$; for size $s + 1$ emit $\Box B$ and $\mu.\,B$ for
each $B$ of size $s$, and $B \wedge C$, $B \to C$ for each split $s = s_1 + s_2$. The
count grows like a Catalan-type recursion; enumeration to depth $4$ over one atom already
produces thousands of codes, which is ample for round-trip testing and for locating
guarded versus unguarded fixed-point codes.

### 8.3 Box evaluation and witness search on finite frames

For a finite frame with $n$ worlds given as an adjacency relation, the operator $\Box$ on
subsets is computed in $O(n^2)$ time by, for each world, checking all successors. A
reflection witness is then located by evaluating $\Box P$ and $\Box\Box P$ and taking the
set difference. Exhaustive search over all frames on $n$ worlds ($2^{n^2}$ relations) and
all propositions ($2^n$ subsets) is feasible for $n \le 3$ and confirms both Theorem 5.7
(the chain witness) and Corollary 5.5 (no transitive frame yields a witness, for any of
the $171$ transitive frames on three worlds).

### 8.4 Polarity analysis

The guard of Definition 7.2 is decided by one traversal carrying a polarity flag,
initialised positive, preserved by conjunction, $\Box$, $\mu$ and the consequent of an
implication, and flipped on the antecedent. A code is guarded iff every bound-variable
occurrence is met with a positive flag. The traversal is linear in code size and is the
practical gatekeeper separating Refutation 7.1 from Proposition 7.3.

---

## 9. Applications

**Verification of reflective systems.** By Corollary 4.5, a specification language whose
assertions mention the availability of their own evidence is, on the nose, a modal
fixed-point specification language. Any model checker, automaton construction, or
complexity bound for the latter applies to the former without translation overhead. This
is the practical yield of the isomorphism: an engineering pipeline exists already.

**Design of proof-carrying and staged systems.** Corollary 5.5 says that a system whose
reasoning relation composes automatically validates $\Box A \to \Box\Box A$. Contrapositively,
if a system deliberately does *not* compose — because of resource bounds, stage separation,
bounded introspection depth, or layered trust between a kernel and its extensions — then
Theorem 5.7 shows how little is needed for the failure to manifest: three states and two
transitions. Designers who rely on iterated reflection should therefore justify
transitivity explicitly rather than assume it.

**Foundations.** Theorem 3.3 tells a language designer that a reflective former is a real
extension of the core grammar, not sugar, and hence needs its own typing and semantic
rules. Refutation 7.1 tells the same designer that admitting an unrestricted fixed-point
former is a semantic commitment that cannot be honoured; the positivity guard is not a
convenience but a necessity.

**Incompleteness pedagogy.** Theorem 6.2 factors the classical incompleteness argument
into its two genuinely load-bearing hypotheses — soundness and a diagonal sentence —
divorced from coding machinery. It is a two-hypothesis, three-line theorem, and it makes
transparent that the phenomenon is about the shape of self-reference rather than about
arithmetic.

---

## 10. Discussion

The three claims separated in this paper interact in an instructive way.

The **properness** result and the **isomorphism** point in opposite directions and are
both true. Reflection is not definable in the non-reflective core (Theorem 3.3), yet the
resulting language is not new either — it coincides with a well-studied modal fixed-point
calculus (Corollary 4.5). Novelty is relative to a baseline: reflective type theory is
new *with respect to* its own non-reflective fragment and old *with respect to* modal
fixed-point logic. Stating which baseline is intended is what keeps the two claims from
appearing to contradict each other.

The **finite witness** and the **transitive impossibility** theorem are similarly
complementary: one exhibits the phenomenon, the other confines it. A witness on its own
invites the objection that the model is pathological; the impossibility theorem answers
that objection by identifying the exact pathology (non-transitivity) and showing it is
unavoidable. This pairing — existence plus a matching non-existence under the natural
hypothesis — is the pattern we have tried to follow throughout.

Finally the **refuted conjecture** disciplines the isomorphism. Because $\tau$ and
$\sigma$ are insensitive to variance, one might hope to transport the least-fixed-point
semantics of the modal calculus to arbitrary reflective codes. Refutation 7.1 blocks
this: the semantics on the modal side is itself defined only for positive formulas, and
the isomorphism faithfully transports that restriction along with everything else. The
correct statement is that guarded reflective codes correspond to positive modal formulas,
and on that subclass the semantic transport is available.

**Limitations.** (a) The core language is propositional; dependent products and sums are
not treated, though the retraction technique extends to them by adding failure cases to
the decoder. (b) The isomorphism is between formula sets; no proof calculus is compared.
(c) The semantics of Section 5 is the standard Kripke semantics for a single modality;
neighbourhood semantics, which would allow non-normal reflection principles, is not
considered. (d) Theorem 6.2 assumes soundness; the Rosser-style refinement replacing
soundness by consistency is not carried out here.

---

## 11. Future work

1. **Dependent extension.** Extend both grammars with sums, dependent products, and
   dependent sums, and re-derive the retraction and the isomorphism. The decoder gains
   failure cases; the translation gains binder-aware clauses. The interesting question is
   whether the isomorphism survives contexts, i.e. whether typing derivations, not merely
   codes, correspond.

2. **Indexed modalities.** Replace $\Box$ by a family $\Box_i$ with separate accessibility
   relations, and characterise which mixed iteration principles
   $\Box_i A \to \Box_j \Box_k A$ hold on which frame classes. The single-modality results
   here are the diagonal case of that programme.

3. **Guarded transport of semantics.** Formulate the subclass of guarded reflective codes,
   prove the monotone interpretation theorem in full (Proposition 7.3), and establish that
   the isomorphism restricts to a semantics-preserving bijection between guarded codes and
   positive modal formulas.

4. **Quantitative minimality.** Remark 5.10 identifies the two-edge path as the minimal
   shape of a witness; a full classification of minimal reflection witnesses (up to frame
   isomorphism), separating the cyclic two-world case from the loop-free three-world case,
   and of the frames on which $\Box A \to \Box\Box A$ fails for *some* rather than *all*
   propositions, would sharpen the boundary further.

5. **Rosser refinement of the diagonal theorem.** Weaken soundness in Definition 6.1 to a
   consistency-style hypothesis and identify the minimal abstract structure under which the
   conclusion of Theorem 6.2 survives.

6. **Proof theory of the reflective calculus.** Design a natural-deduction or sequent
   calculus for reflective propositions, and ask whether it is complete for the Kripke
   semantics of Section 5 — a question the grammar isomorphism explicitly does *not*
   answer.

---

## 12. Conclusion

We have separated and proved three claims about reflective propositional languages. The
reflective grammar properly extends its non-reflective core, certified by a partial
decoder that retracts the canonical inclusion and fails on reflected atoms. It is
isomorphic, constructor for constructor and compatibly with iteration, to the modal
fixed-point language. And its central reflective proposition
$\Box A \wedge \neg\Box\Box A$ is inhabited — in a three-world, two-edge, non-transitive
chain — while being uninhabitable on every transitive frame. A diagonal theory with
soundness produces a true unprovable sentence, and the natural conjecture that
unrestricted fixed-point codes carry monotone semantics is false, repaired by the
positivity guard.

The unifying observation is that two distinct forms of iteration each carry their own
side condition: transitivity for the proof modality, positivity for the fixed point.
Self-reference is safe where it composes; the theorems above say exactly where that is.
