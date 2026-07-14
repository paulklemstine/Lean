# The Kernel/Game Bridge: A Unification of Stable Argumentation Semantics, Digraph Kernels, and Combinatorial Game Solutions

## Abstract

We develop a self-contained bridge connecting three theories usually studied in
isolation: the *stable extension* semantics of abstract argumentation frameworks,
the theory of *kernels* of directed graphs (independent, absorbing vertex sets in
the sense of von Neumann and Morgenstern), and the classification of positions of
a combinatorial game into wins and losses. The central identity is a single
translation:

$$
\textbf{Stable}(R) \;=\; \textbf{Kernel}(\operatorname{flip} R) \;=\;
\textbf{GameSolution}(\operatorname{flip} R),
$$

which holds with no hypotheses whatsoever on the underlying relation — no
finiteness, no well-foundedness. Building on this dictionary we prove three
substantive results. First, a *normal-play* theorem: terminal positions are forced
to lie in every kernel, so the convention "no move implies a loss" is a consequence
of the kernel axioms rather than a stipulation. Second, an *obstruction* theorem:
the directed 3-cycle possesses no kernel, hence the three-argument cyclic framework
has no stable extension and the corresponding game has no consistent win/loss
labelling; this explains why stable extensions can fail to exist. Third, a
*determinacy* theorem: any relation whose reverse is well-founded — equivalently,
any game admitting no infinite play — has a **unique** kernel, computed by the
standard game recursion; consequently a well-founded argumentation framework has a
unique stable extension. The last statement simultaneously instantiates Zermelo's
determinacy theorem for terminating games, a Richardson-style kernel existence
theorem for well-founded digraphs, and a uniqueness theorem for well-founded Dung
semantics. All results are stated for an arbitrary carrier type and an arbitrary
binary relation.

**Keywords:** argumentation framework, stable extension, digraph kernel,
combinatorial game, P-position, well-founded recursion, Zermelo determinacy,
odd-cycle obstruction.

---

## 1. Introduction

Three research communities have, independently, converged on a single
mathematical object.

Abstract argumentation, introduced by Dung, models a debate as a set $A$ of
arguments together with an *attack* relation $R$, where $R\,a\,b$ reads "$a$
attacks $b$." Among the various semantics for "acceptable positions," the *stable*
semantics is the most decisive: a stable extension is a conflict-free set that
attacks every argument outside it.

Directed graph theory, following von Neumann and Morgenstern, studies *kernels*: a
kernel of a digraph $D$ is a vertex set that is simultaneously *independent* (no
internal edge) and *absorbing* (every external vertex has an edge into the set).
Kernels formalize "stable solutions" of a cooperative situation and have deep
connections to perfectness, list colouring, and Nash equilibria of certain games.

Combinatorial game theory classifies the positions of a two-player game with move
relation $M$ into P-positions (a loss for the **P**layer to move) and N-positions
(a win for the player about to move, i.e. the **N**ext player). Under normal play,
the P-positions of a game form a self-consistent labelling.

The purpose of this paper is to make the connection between the three precise,
prove it needs no regularity hypotheses, and then harvest the non-trivial
consequences. We emphasise that the *dictionary* is elementary; the *payoff* is
that structural results — non-existence on odd cycles, and existence-and-uniqueness
under well-foundedness — become tri-lingual, provable once and read three ways.

Throughout, $A$ is an arbitrary type (the arguments, the vertices, or the game
positions) and relations are arbitrary binary relations $A \to A \to \mathrm{Prop}$.
For a relation $R$ we write $\operatorname{flip} R$ for its transpose,
$(\operatorname{flip} R)\,a\,b \iff R\,b\,a$.

---

## 2. Definitions

We give all three theories self-contained definitions over a common carrier.

### 2.1 Argumentation semantics

**Definition 2.1 (Conflict-free).** A set $S \subseteq A$ is *conflict-free* for
the attack relation $R$ if no member attacks another:
$$
\forall a \in S,\ \forall b \in S,\ \neg\, R\,a\,b.
$$

**Definition 2.2 (Stable extension).** A set $S \subseteq A$ is a *stable
extension* of $R$ if it is conflict-free and attacks every outsider:
$$
\text{Stable}(R,S)\ :\iff\ \text{ConflictFree}(R,S)\ \wedge\
\big(\forall a \notin S,\ \exists b \in S,\ R\,b\,a\big).
$$

Intuitively, a stable extension partitions $A$: everything is either accepted
(in $S$) or explicitly defeated by an accepted argument.

### 2.2 Digraph kernels

**Definition 2.3 (Independent set).** $S \subseteq A$ is *independent* in the
digraph $D$ if no edge joins two of its members:
$\forall a \in S,\ \forall b \in S,\ \neg\, D\,a\,b.$

**Definition 2.4 (Absorbing set).** $S \subseteq A$ is *absorbing* (dominating) in
$D$ if every outside vertex has an edge *into* $S$:
$\forall a \notin S,\ \exists b \in S,\ D\,a\,b.$

**Definition 2.5 (Kernel).** $S$ is a *kernel* of $D$ if it is both independent
and absorbing.

### 2.3 Combinatorial games

We identify a game with its move relation $M$, where $M\,p\,q$ means "from
position $p$ a legal move reaches $q$."

**Definition 2.6 (Game solution).** A set $P \subseteq A$ is a *solution* (the
set of P-positions) of the game $M$ if $P$ is a kernel of the move digraph $M$.
Explicitly: (i) no move from a P-position reaches a P-position (independence), and
(ii) from every non-P-position some move reaches a P-position (absorption). These
are exactly the two consistency rules for a normal-play win/loss labelling.

---

## 3. The dictionary

The three notions coincide after a single relational transpose.

**Theorem 3.1 (Argumentation–Graph Bridge).** For every relation $R$ and every set
$S$,
$$
\text{Stable}(R,S) \iff \text{Kernel}(\operatorname{flip} R,\, S).
$$
*No hypotheses on $A$ or $R$ are required.*

*Proof.* Unfold both sides. Conflict-freeness of $S$ for $R$ says
$\forall a,b \in S,\ \neg R\,a\,b$; independence of $S$ for $\operatorname{flip} R$
says $\forall a,b\in S,\ \neg R\,b\,a$. These are the same statement after
swapping the two bound variables. The decisiveness clause of stability,
$\forall a \notin S,\ \exists b \in S,\ R\,b\,a$, is *verbatim* the absorbing
clause $\forall a \notin S,\ \exists b\in S,\ (\operatorname{flip} R)\,a\,b$. Hence
each conjunct matches its counterpart, and the biconditional holds. $\qquad\blacksquare$

**Theorem 3.2 (Argumentation–Game Bridge).** For every $R$ and $S$,
$$
\text{Stable}(R,S) \iff \text{GameSolution}(\operatorname{flip} R,\, S).
$$
*Proof.* Immediate from Theorem 3.1 and Definition 2.6, since a game solution is by
definition a kernel of the move relation. $\qquad\blacksquare$

Combining, we obtain the master identity
$$
\text{Stable}(R,\cdot) \;=\; \text{Kernel}(\operatorname{flip} R,\cdot) \;=\;
\text{GameSolution}(\operatorname{flip} R,\cdot),
$$
valid for arbitrary $R$. A theorem in any one of the three theories is now a
theorem in the other two.

### 3.1 Normal play is forced

A position with no legal move is *terminal*. In game theory one *conventionally*
declares terminal positions to be losses. Under the dictionary this convention is
not needed; it is a theorem.

**Theorem 3.3 (Terminal positions are losing).** Let $P$ be any kernel of a move
relation $M$, and let $a$ be terminal, i.e. $\forall b,\ \neg\, M\,a\,b$. Then
$a \in P$.

*Proof.* Suppose $a \notin P$. By the absorbing property there is $b \in P$ with
$M\,a\,b$, contradicting terminality. Hence $a \in P$. $\qquad\blacksquare$

The same statement, read in argumentation, says: an argument nobody's outside-move
can dominate — an *unattacked* argument, in the transposed reading — must belong to
every stable extension.

---

## 4. The odd-cycle obstruction

The dictionary is unconditional, but *existence* of the common object is not
automatic. The minimal obstruction is the directed triangle.

**Definition 4.1 (Directed 3-cycle).** On the three-element carrier
$\{0,1,2\}$ define $\text{cyc}_3\,a\,b :\iff b = a+1$ (indices mod $3$), i.e.
$0 \to 1 \to 2 \to 0$.

**Theorem 4.2 (No kernel).** The digraph $\text{cyc}_3$ has no kernel:
$\neg\, \exists S,\ \text{Kernel}(\text{cyc}_3, S).$

*Proof.* There are only eight candidate subsets; we rule out each by the two
kernel axioms. The empty set is not absorbing (e.g. vertex $0$ has no in-neighbour
inside $\varnothing$). Any singleton $\{v\}$ fails absorption: the vertex $v-1$
(the unique in-neighbour of $v$) lies outside $\{v\}$ and its only out-edge goes to
$v$, but $v-1$ has no *in*-edge from $\{v\}$ because $v$'s out-edge goes to $v+1
\neq v-1$; so the vertex two steps back is undominated. Any two-element set
contains an edge (every vertex points to its successor, and among any two of the
three vertices one is the successor of the other), so it is not independent. The
full set is likewise not independent. Hence no subset is a kernel.
$\qquad\blacksquare$

**Theorem 4.3 (No stable extension).** The three-argument framework
$(\{0,1,2\}, \text{cyc}_3)$ has no stable extension.

*Proof.* By Theorem 3.1, a stable extension of $\text{cyc}_3$ would be a kernel of
$\operatorname{flip}(\text{cyc}_3)$, which is again a directed 3-cycle (the
reversed triangle $0 \leftarrow 1 \leftarrow 2 \leftarrow 0$). By Theorem 4.2 no
such kernel exists. $\qquad\blacksquare$

Theorems 4.2–4.3 are a single fact in three languages: (i) a debate with no
fully-decisive verdict, (ii) a digraph with no von Neumann–Morgenstern solution,
and (iii) a game with no consistent win/loss labelling. They are the qualitative
reason a regularity hypothesis is unavoidable for existence: an odd directed cycle
supports an infinite, never-resolving chase. This contrasts sharply with the
*maximal* (preferred) argumentation semantics, which is guaranteed to exist for
every framework; stability is strictly more demanding.

---

## 5. Well-founded existence, uniqueness, and determinacy

The triangle fails because play can continue forever. Forbidding this — imposing
*well-foundedness* — restores existence and, remarkably, forces uniqueness.

We say the game $M$ is *well-founded* when $\operatorname{flip} M$ is a
well-founded relation: there is no infinite forward play
$a_0 \to a_1 \to a_2 \to \cdots$, because such a play would be an infinite
descending $\operatorname{flip} M$-chain.

### 5.1 The P-position recursion

**Definition 5.1 (Losing positions).** For a well-founded game $M$ define the
predicate $\text{isLoss}$ by well-founded recursion along $\operatorname{flip} M$:
$$
\text{isLoss}(a) \ :\iff\ \forall b,\ M\,a\,b \Rightarrow \neg\,\text{isLoss}(b).
$$
Well-foundedness makes this a legitimate definition: the truth value at $a$
depends only on values at positions $b$ strictly earlier in the
$\operatorname{flip} M$ order.

**Lemma 5.2 (Fixed-point equation).** For every $a$,
$$
\text{isLoss}(a) \iff \big(\forall b,\ M\,a\,b \Rightarrow \neg\,\text{isLoss}(b)\big).
$$
*Proof.* This is the unfolding equation of the well-founded recursion defining
$\text{isLoss}$. $\qquad\blacksquare$

### 5.2 The recursion yields a kernel

**Theorem 5.3 (P-positions form a kernel).** For a well-founded game $M$, the set
$L := \{\, a \mid \text{isLoss}(a)\,\}$ is a kernel of $M$.

*Proof.* *Independence.* If $a, b \in L$ and $M\,a\,b$, then by Lemma 5.2 applied
to $a$ we get $\neg\,\text{isLoss}(b)$, contradicting $b \in L$. So no move joins
two P-positions.

*Absorption.* Let $a \notin L$, i.e. $\neg\,\text{isLoss}(a)$. By Lemma 5.2 the
negation of the defining clause gives some $b$ with $M\,a\,b$ and
$\text{isLoss}(b)$, i.e. a move to a P-position $b \in L$. Hence $L$ absorbs $a$.
$\qquad\blacksquare$

### 5.3 Uniqueness

**Theorem 5.4 (Kernel uniqueness).** If $M$ is well-founded and $S$ is any kernel
of $M$, then $S = L$.

*Proof.* We show $a \in S \iff \text{isLoss}(a)$ by well-founded induction on $a$
along $\operatorname{flip} M$; assume the equivalence for all $b$ with $M\,a\,b$.

($\Rightarrow$) Suppose $a \in S$. To show $\text{isLoss}(a)$ it suffices, by
Lemma 5.2, to show every move $M\,a\,b$ lands in a non-loss. If $M\,a\,b$ and
$\text{isLoss}(b)$, the induction hypothesis gives $b \in S$; but then
$a, b \in S$ with an edge $M\,a\,b$ contradicts independence of $S$. So each such
$b$ has $\neg\,\text{isLoss}(b)$, whence $\text{isLoss}(a)$.

($\Leftarrow$) Suppose $\text{isLoss}(a)$; we show $a \in S$. If not, absorption of
$S$ yields $b \in S$ with $M\,a\,b$; the induction hypothesis gives
$\text{isLoss}(b)$, contradicting the defining clause of $\text{isLoss}(a)$ (which
forbids a move to a loss). Hence $a \in S$. $\qquad\blacksquare$

### 5.4 The main theorems

**Theorem 5.5 (Unique kernel).** Every well-founded digraph $M$ has a unique
kernel, namely $L$.
*Proof.* Existence is Theorem 5.3; uniqueness is Theorem 5.4. $\qquad\blacksquare$

**Theorem 5.6 (Zermelo determinacy).** Every well-founded game has a unique
solution: the set of P-positions is uniquely determined.
*Proof.* A game solution is a kernel (Definition 2.6), so this is Theorem 5.5.
$\qquad\blacksquare$

**Theorem 5.7 (Unique stable extension).** If the attack relation $R$ is
well-founded, then the argumentation framework $(A,R)$ has a unique stable
extension.
*Proof.* Well-foundedness of $R$ is well-foundedness of $\operatorname{flip}
(\operatorname{flip} R)$, so $\operatorname{flip} R$ has a unique kernel $S$ by
Theorem 5.5. By Theorem 3.1, $S$ is the unique stable extension of $R$.
$\qquad\blacksquare$

Theorem 5.7 is the exact converse phenomenon to Section 4: well-foundedness *both*
restores the existence that the 3-cycle destroyed *and* collapses all ambiguity to
a single verdict. The three faces of Theorem 5.5 — determinacy of terminating
games (Zermelo), kernel existence for well-founded digraphs (in the spirit of
Richardson), and uniqueness of well-founded stable semantics — are literally the
same theorem read through the dictionary.

---

## 6. Algorithms

The recursion of Definition 5.1 is directly computable on finite, well-founded
games by a bottom-up sweep in reverse-topological order.

**Algorithm A (Kernel by game recursion).** Compute $L = \{a \mid \text{isLoss}(a)\}$
for a finite acyclic move relation $M$:

1. Topologically sort the positions so that every move points to an
   already-processed successor.
2. Process positions from sinks (terminal) toward sources. A position $a$ is
   labelled **loss** iff *all* its out-neighbours are already labelled **win**;
   otherwise it is labelled **win**.
3. Return the set of loss-labelled positions.

Complexity: $O(|V| + |E|)$ time and $O(|V|)$ space, one pass after the topological
sort.

**Algorithm B (Stable extension via transpose).** To compute the unique stable
extension of a well-founded framework $(A,R)$: form $\operatorname{flip} R$
(reverse the edges) and run Algorithm A. The returned kernel is the stable
extension, by Theorems 3.1 and 5.5.

**Algorithm C (Kernel search on general digraphs).** For digraphs that may contain
cycles, kernel existence is NP-complete in general; a correct exponential-time
decision procedure enumerates independent sets and tests absorption, and the
odd-cycle obstruction (Section 4) is the smallest certificate of non-existence.

---

## 7. Applications

- **Automated debate resolution.** Given a debate graph with no vicious cycles,
  Theorem 5.7 guarantees a single, computable "final verdict" partitioning claims
  into accepted and defeated; Algorithm B produces it in linear time.
- **Game solving.** Theorem 5.6 is the formal backbone of retrograde analysis: the
  P/N labelling of any terminating game (Nim heaps, subtraction games, and
  endgame tablebases) is well defined and unique, computed by Algorithm A.
- **Diagnosing paradox.** The odd-cycle obstruction is a reusable diagnostic: a
  debate, network, or game that resists resolution must contain an odd cyclic
  chase, and Section 4 exhibits the minimal instance.
- **Cross-domain transfer.** Any future theorem about kernels — e.g. structural
  characterisations of kernel-perfect digraphs — becomes, at no cost, a theorem
  about which debates admit stable verdicts and which games are solvable.

---

## 8. Discussion

The contribution is twofold. Mathematically, the master identity
$\text{Stable}(R) = \text{Kernel}(\operatorname{flip} R) =
\text{GameSolution}(\operatorname{flip} R)$ is established with *no* regularity
hypothesis, isolating the transpose as the sole content of the correspondence.
Structurally, the two poles of the theory — impossibility on the odd cycle,
existence-and-uniqueness under well-foundedness — are shown to be single facts with
three readings each.

We stress the sharp dichotomy the results expose. *Maximal* argumentation
semantics exist unconditionally; *stable* semantics do not, and the triangle is the
reason. Well-foundedness is exactly the hypothesis that repairs the defect, and it
does more than restore existence: it delivers uniqueness and an explicit
linear-time construction. The same hypothesis, in game language, is precisely the
"no infinite play" condition of Zermelo's theorem.

---

## 9. Future directions

- **Even cycles and kernel-perfect digraphs.** Formalise the positive side: even
  directed cycles have kernels, and more generally every digraph with no odd
  directed cycle is kernel-perfect (Richardson's theorem). Only the odd
  obstruction is treated here.
- **Grounded = unique stable in the well-founded case.** Identify the unique stable
  extension of Theorem 5.7 with the grounded extension (the least fixed point of
  the characteristic defence operator), unifying the maximal and stable pictures
  under well-foundedness.
- **Quantitative obstruction theory.** Characterise the family of finite digraphs
  with no kernel in terms of their odd-cycle structure, and give a certificate
  calculus for non-existence.
- **Semi-stable and stage semantics.** Extend the dictionary to weaker Dung
  semantics and their graph-theoretic and game-theoretic counterparts.

---

## 10. Conclusion

Three subjects — the semantics of debate, the structure of directed networks, and
the theory of games — turn out to study one object seen through one transpose. The
dictionary is elementary; its consequences are not. An odd triangle is
simultaneously the smallest debate with no verdict, the smallest digraph with no
kernel, and the smallest game with no solution; and a single well-foundedness
hypothesis simultaneously yields Zermelo determinacy, kernel existence and
uniqueness, and the uniqueness of stable argumentation semantics. Unification, here,
is not decoration — it is what lets each theorem be proved once and understood
three times.
