# Bisimulation versus Isomorphism as Semantic Resolution: Multiplicity, Sharing, and the Naming Budget

**Aristotle**

*2026-09-03*

---

## Abstract

We study the exact resolving power of modal observation on a class of transition systems that is automatically image-finite and converse well-founded: *descending tag-indexed frames*, whose worlds are the natural numbers and in which a world $m$ may step, at any tag $i$, only to worlds $n < m$. Within this setting we establish a complete picture of the lattice of observational equivalences and the invariants they support.

First, we prove a Hennessy–Milner theorem: bisimilarity and modal equivalence coincide, with no finiteness hypothesis needed beyond the descending condition itself. As a consequence, an interpretation of pointed models is invariant under all modal observations if and only if it is invariant under bisimulation, so every observationally invariant quantity factors through the modal theory and through nothing finer.

Second, we exhibit the full observational hierarchy
$$\mathrm{DepthInv}_0 \subsetneq \mathrm{DepthInv}_1 \subsetneq \cdots \subsetneq \mathrm{ModalInv} = \mathrm{BisimInv} \subsetneq \mathrm{IsoInv},$$
with explicit separating observations at every level: the *height formulas* $\Box^{k+1}\bot$ below, and the *out-degree* above.

Third — the paper's principal negative result — we refute the natural conjecture that the top gap is characterized by multiplicity-sensitive observations. The *shared diamond* $5\to 3,4$; $3\to1$; $4\to1$ and its unravelling $5\to3,4$; $3\to1$; $4\to2$ are bisimilar, have equal out-degrees at every related pair and every tag, and are nevertheless non-isomorphic. The correct statement is a two-step ladder, whose second gap is measured by *sharing* — the identification of behaviourally equal successors — rather than by multiplicity.

Fourth, we identify what does close the gap, and quantify its cost. Nominal valuations collapse modal equivalence to equality of worlds already in the atomic fragment; binary naming achieves the same for all worlds below $2^k$ using only $k$ atoms; and a pigeonhole argument shows no valuation with $k$ atoms can atomically separate $2^k+1$ worlds. The threshold is therefore exactly $\lceil \log_2 N\rceil$ atoms, so the entire hierarchy is a phenomenon of atom-poor languages.

Fifth, we determine when the depth ladder stops being strict on a fixed truncation: on worlds of height at most $k$, depth-$k$ agreement already implies full modal equivalence, and depth $k-1$ provably does not.

Finally, we draw a proof-theoretic corollary: the truncated Gödel–Löb-style validity theories of these frames, together with their entire depth-restricted reflection spectra, are bisimulation invariants. In particular no deductive strength distinguishes a shared diamond from its unravelling.

**Keywords:** bisimulation, modal logic, Hennessy–Milner theorem, image-finiteness, observational equivalence, unravelling, nominals, provability logic.

---

## 1. Introduction

### 1.1 The resolution question

Every equivalence relation on mathematical objects is a decision about which differences matter. In the theory of transition systems there are two canonical candidates. *Isomorphism* says two systems are the same when there is a structure-preserving bijection between them: sameness of shape. *Bisimulation* says they are the same when a copycat relation lets each mirror the other's moves indefinitely: sameness of behaviour.

Between these lies a third, purely logical notion: two pointed systems are the same when no sentence of a fixed observational language separates them. Fix the language and you fix an equivalence. The **resolution question** asks which structural equivalence a given language induces — which structural distinctions it can, and cannot, see.

For ordinary modal logic on image-finite systems the classical answer is bisimulation, and our first task is to prove this in the present setting. The more interesting question — the one this paper is really about — is the *shape of the residue*: exactly what structure does isomorphism see that no modal observation can?

### 1.2 The conjecture and its fate

The natural conjecture is that the residue is *multiplicity*. Modal logic has no counting quantifier: it can say "some successor is red" and "every successor is red" but not "exactly two successors are red". Duplicating a successor is invisible to it. Isomorphism, being a bijection, preserves out-degree exactly. So it is tempting to conjecture:

> On image-finite transition systems, every interpretation invariant under all modal observations factors through bisimulation classes but need not factor through isomorphism classes, and the gap is characterized by multiplicity-sensitive observations.

We prove that the first two clauses are exactly right, and that the third is false. The counterexample — a shared diamond versus its unravelling — is bisimilar, out-degree-matched at every related pair, and non-isomorphic. Counting is a *proper* refinement of behaviour and a *proper* coarsening of shape.

### 1.3 The setting

We work in a concrete arena chosen for a specific technical reason: it makes image-finiteness automatic and structural rather than assumed.

**Definition 1.1 (Descending tag-indexed frame).** A *frame* is a function $R : \mathbb{N}\to\mathbb{N}\to\mathbb{N}\to\{\top,\bot\}$, written $R\,i\,m\,n$ and read "at tag $i$, world $m$ is linked to world $n$". The *step relation* is
$$\mathrm{Step}_R(i,m,n) \;:\iff\; n < m \;\wedge\; R\,i\,m\,n .$$
A *valuation* is $V : \mathbb{N}\to\mathbb{N}\to\{\top,\bot\}$, with $V\,m\,p$ read "the atom $p$ holds at world $m$". A *pointed model* is a triple $(R,V,m)$.

The strict inequality $n<m$ is the whole design. It forces two properties at once:

**Lemma 1.2 (Image-finiteness).** The successors of $m$ at tag $i$ are exactly the members of the finite list obtained by filtering $\{0,\dots,m-1\}$ by $R\,i\,m\,{-}$. In particular a world has at most $m$ successors at each tag.

**Lemma 1.3 (Converse well-foundedness).** Every step strictly decreases the world index, so no infinite forward path exists; the *height* of a world $m$ (the length of its longest path) is at most $m$.

Both are immediate. Their consequences are not: Lemma 1.2 powers the Hennessy–Milner argument of §3, and Lemma 1.3 powers the collapse threshold of §7.

**Definition 1.4 (Language and semantics).** Formulas are generated by
$$a ::= \bot \;\mid\; p \;\mid\; a \to a \;\mid\; \Box_i a \qquad (p, i \in \mathbb{N}).$$
Satisfaction $(R,V,m)\models a$ is defined by recursion: $\bot$ never holds; $p$ holds iff $V\,m\,p$; $a\to b$ holds iff $a$ fails or $b$ holds; and
$$(R,V,m)\models \Box_i a \iff \text{for all } n,\; \mathrm{Step}_R(i,m,n) \Rightarrow (R,V,n)\models a .$$
We abbreviate $\neg a := a\to\bot$, $\top := \bot\to\bot$, $a\wedge b := \neg(a\to\neg b)$, and $\Diamond_i a := \neg\Box_i\neg a$. The *box depth* $\mathrm{bd}(a)$ counts maximal box nesting; $\Box^j_i\bot$ denotes the $j$-fold iterate of $\Box_i$ applied to $\bot$.

Two remarks. The language has only $\bot$, atoms, $\to$ and boxes as primitives, so finite conjunction must be *defined* — as the fold of the derived binary conjunction over a list, with $\top$ as unit — and its semantics proved: the conjunction of a list is true at $m$ iff every member is. This matters in §3, where the separating formula is built as such a finite conjunction; no infinitary conjunction appears anywhere.

Second, the tags are genuinely multi-modal, but they cause no difficulty: every argument below is carried out one tag at a time.

---

## 2. Equivalences and invariants

**Definition 2.1 (Bisimulation).** A relation $E \subseteq \mathbb{N}\times\mathbb{N}$ is a *bisimulation* between models $(R,V)$ and $(R',V')$ when for all $m \mathrel{E} n$:

1. *(atoms)* $V\,m\,p = V'\,n\,p$ for every atom $p$;
2. *(forth)* for every tag $i$ and every $m'$ with $\mathrm{Step}_R(i,m,m')$ there is $n'$ with $\mathrm{Step}_{R'}(i,n,n')$ and $m'\mathrel{E}n'$;
3. *(back)* for every tag $i$ and every $n'$ with $\mathrm{Step}_{R'}(i,n,n')$ there is $m'$ with $\mathrm{Step}_R(i,m,m')$ and $m'\mathrel{E}n'$.

Pointed models are *bisimilar*, written $(R,V,m)\sim(R',V',n)$, when some bisimulation relates $m$ to $n$.

**Definition 2.2 (Modal equivalence).** $(R,V,m)\equiv(R',V',n)$ when $(R,V,m)\models a \iff (R',V',n)\models a$ for every formula $a$.

**Proposition 2.3.** Bisimilarity is reflexive, symmetric and transitive.

*Proof sketch.* Equality is a bisimulation, giving reflexivity. The converse of a bisimulation is a bisimulation with forth and back exchanged, giving symmetry. The relational composite $E;F$ of two bisimulations is a bisimulation: a forth-step is matched through the intermediate model in two stages, and dually for back. $\square$

**Definition 2.4 (Reachability and pointed isomorphism).** $\mathrm{Reach}_R(r)$ is the least set containing $r$ and closed under steps at all tags. A *pointed isomorphism* $F : (R,V,r)\cong(R',V',r')$ consists of maps $f,g:\mathbb{N}\to\mathbb{N}$ with $f(r)=r'$, $g(r')=r$, such that $f$ maps $\mathrm{Reach}_R(r)$ into $\mathrm{Reach}_{R'}(r')$ and $g$ conversely, $g\circ f$ is the identity on $\mathrm{Reach}_R(r)$ and $f\circ g$ the identity on $\mathrm{Reach}_{R'}(r')$, both $f$ and $g$ preserve steps at every tag on reachable worlds, and $f$ preserves atoms on reachable worlds.

This is deliberately a *weak* notion: it constrains only the generated submodels, and imposes no condition off them. Consequently a non-existence statement about pointed isomorphisms — as in Theorems 5.4 and 6.5 — is correspondingly strong.

**Definition 2.5 (Interpretations and invariance).** An *interpretation* with values in a type $\alpha$ is a function $I$ assigning to each pointed model $(R,V,m)$ an element $I(R,V,m)\in\alpha$. It is:

* *modally invariant* if $(R,V,m)\equiv(R',V',n)$ implies $I(R,V,m)=I(R',V',n)$;
* *bisimulation invariant* if $(R,V,m)\sim(R',V',n)$ implies the same;
* *isomorphism invariant* if the existence of a pointed isomorphism implies the same;
* *depth-$k$ invariant* if agreement on all formulas of box depth $\le k$ implies the same.

Note the direction: a *finer* equivalence is a *weaker* invariance requirement, so the inclusions among invariance classes run opposite to the inclusions among equivalences. Throughout we write $\mathrm{ModalInv}$, $\mathrm{BisimInv}$, $\mathrm{IsoInv}$, $\mathrm{DepthInv}_k$ for the corresponding classes.

**Definition 2.6 (Out-degree).** The *out-degree* of $m$ at tag $j$ is
$$\deg_R(j,m) := \#\{\,n < m : R\,j\,m\,n\,\},$$
the paradigmatic multiplicity-sensitive observation. The associated interpretation is $I_{\deg,j}(R,V,m) := \deg_R(j,m)$.

---

## 3. The Hennessy–Milner theorem

**Theorem 3.1 (Bisimulation invariance of modal truth).** Let $E$ be a bisimulation between $(R,V)$ and $(R',V')$. Then for every formula $a$ and every $m\mathrel{E}n$, $(R,V,m)\models a \iff (R',V',n)\models a$.

*Proof sketch.* Induction on $a$. The case $\bot$ is trivial, atoms are the atom clause of Definition 2.1, and implication is immediate from the induction hypotheses. For $\Box_i b$: assume it holds at $m$ and let $n'$ be an $i$-successor of $n$. By *back* there is an $i$-successor $m'$ of $m$ with $m'\mathrel{E}n'$; $b$ holds at $m'$, so by induction at $n'$. The converse uses *forth*. $\square$

**Corollary 3.2.** Bisimilar pointed models are modally equivalent.

The converse is where image-finiteness enters.

**Lemma 3.3 (Forth for modal equivalence).** Suppose $(R,V,m)\equiv(R',V',n)$ and $\mathrm{Step}_R(i,m,m')$. Then there is $n'$ with $\mathrm{Step}_{R'}(i,n,n')$ and $(R,V,m')\equiv(R',V',n')$.

*Proof sketch.* Suppose not. Then for each $i$-successor $n'$ of $n$ there is a formula separating $m'$ from $n'$; replacing it by its negation if necessary, we may choose $a_{n'}$ true at $m'$ and false at $n'$. For indices that are *not* successors of $n$, take $a_{n'} := \top$. By Lemma 1.2 all successors of $n$ lie below $n$, so we may form the finite conjunction
$$A := \bigwedge_{n' < n} a_{n'} .$$
Then $A$ is true at $m'$, being a conjunction of formulas each true at $m'$; and $A$ is false at every $i$-successor $n'$ of $n$, since $a_{n'}$ is a conjunct of $A$ and is false there. Hence $\Box_i \neg A$ holds at $n$, so by modal equivalence it holds at $m$. But $m'$ is an $i$-successor of $m$ at which $A$ is true — a contradiction. $\square$

The choice of range $\{0,\dots,n-1\}$ rather than "the set of successors" is what keeps the construction finite and explicit; the padding with $\top$ at non-successors costs nothing.

**Theorem 3.4 (Hennessy–Milner).** Modal equivalence is itself a bisimulation. Consequently
$$(R,V,m)\sim(R',V',n) \iff (R,V,m)\equiv(R',V',n).$$

*Proof sketch.* The atom clause is Definition 2.2 applied to atoms. *Forth* is Lemma 3.3. *Back* is Lemma 3.3 applied to the symmetric modal equivalence and then transported back, using that modal equivalence is symmetric. For the displayed equivalence, left-to-right is Corollary 3.2, and right-to-left exhibits modal equivalence itself as the required bisimulation. $\square$

**Theorem 3.5 (Factorization through bisimulation classes).** An interpretation $I$ is modally invariant if and only if it is bisimulation invariant; that is, $\mathrm{ModalInv}=\mathrm{BisimInv}$.

*Proof sketch.* Immediate from Theorem 3.4 in both directions. $\square$

**Definition 3.6 (Modal theory).** $\Theta(R,V,m) := \{\,a : (R,V,m)\models a\,\}$, viewed as the interpretation sending a pointed model to its set of true formulas.

**Theorem 3.7 (Universality of the modal theory).** $\Theta$ is modally invariant, and every modally invariant interpretation factors through it: if $\Theta(R,V,m)=\Theta(R',V',n)$ then $I(R,V,m)=I(R',V',n)$ for every modally invariant $I$.

*Proof sketch.* Invariance of $\Theta$ is the definition of modal equivalence unfolded. Equality of modal theories *is* modal equivalence, so the factorization is immediate. $\square$

Theorems 3.4, 3.5 and 3.7 together are the positive half of the conjecture, in the precise form "every modally invariant interpretation factors through bisimulation classes, and through nothing coarser".

---

## 4. The depth ladder

**Definition 4.1.** $(R,V,m)\equiv_k(R',V',n)$ — *depth-$k$ equivalence* — when the two pointed models agree on every formula of box depth at most $k$.

**Proposition 4.2 (Modal equivalence is the limit).** $(R,V,m)\equiv(R',V',n)$ iff $(R,V,m)\equiv_k(R',V',n)$ for every $k$.

*Proof sketch.* Left to right is trivial. Right to left: given $a$, apply the hypothesis at $k=\mathrm{bd}(a)$. $\square$

Combined with Theorem 3.4, this says bisimilarity is exactly the intersection of the depth-graded approximations. Note also the monotonicity $\equiv_l\;\subseteq\;\equiv_k$ for $k\le l$, hence $\mathrm{DepthInv}_k \subseteq \mathrm{DepthInv}_l$, and every $\mathrm{DepthInv}_k \subseteq \mathrm{ModalInv}$.

**Definition 4.3 (The chain).** $\mathrm{chain}\,i\,m\,n :\iff n+1=m$, at every tag; all atoms hold everywhere. Thus world $m+1$ sees exactly $m$, and only the transition structure is observable.

**Lemma 4.4 (Modal theory of the chain).** In the chain, $\Box^j_i\bot$ holds at $m$ if and only if $m<j$.

*Proof sketch.* Induction on $j$. For $j=0$ the formula is $\bot$, false everywhere, and $m<0$ never holds. For $j+1$: $\Box_i \Box^j_i\bot$ holds at $0$ vacuously, and at $p+1$ iff $\Box^j_i\bot$ holds at $p$, which by induction holds iff $p<j$, i.e. $p+1<j+1$. $\square$

The formula $\Box^{k}_i\bot$ is thus the *height observation*: it detects that a world can take fewer than $k$ steps.

**Lemma 4.5 (Depth-$k$ agreement in the chain).** If $k\le m$ and $k\le n$ then $(\mathrm{chain},m)\equiv_k(\mathrm{chain},n)$.

*Proof sketch.* The family of relations $E_l := \{(p,q) : l\le p \wedge l\le q\}$ is a *bounded* (depth-graded) bisimulation: related worlds satisfy the same atoms trivially, and a step from $p$ at level $l+1$ lands at $p-1$, matched by the step from $q$ to $q-1$, with $l\le p-1$ and $l\le q-1$. The standard transfer lemma for bounded bisimulations then transports all formulas of depth $\le k$. $\square$

**Lemma 4.6 (Separation at depth $k+1$).** $(\mathrm{chain},k)\not\equiv_{k+1}(\mathrm{chain},k+1)$.

*Proof sketch.* The formula $\Box^{k+1}\bot$ has box depth $k+1$; by Lemma 4.4 it holds at $k$ (since $k<k+1$) and fails at $k+1$. $\square$

**Definition 4.7 (Height interpretation).** $I_{\mathrm{ht},j}(R,V,m) := $ the truth value of $\Box^{j}_0\bot$ at $(R,V,m)$. It is depth-$j$ invariant by construction.

**Theorem 4.8 (Strictness of every rung).** For every $k$: $\mathrm{DepthInv}_k\subseteq\mathrm{DepthInv}_{k+1}$, and the inclusion is strict — $I_{\mathrm{ht},k+1}$ is depth-$(k+1)$ invariant but not depth-$k$ invariant.

*Proof sketch.* Inclusion is monotonicity. For strictness, the chain worlds $k$ and $k+1$ are depth-$k$ equivalent by Lemma 4.5 but assign different values to $I_{\mathrm{ht},k+1}$ by Lemma 4.4. $\square$

**Theorem 4.9 (No finite depth reaches bisimulation).** For every $k$, $\mathrm{DepthInv}_k \subsetneq \mathrm{ModalInv}$: the modal theory $\Theta$ is modally invariant but not depth-$k$ invariant.

*Proof sketch.* Same witness: the chain worlds $k$ and $k+1$ are depth-$k$ equivalent but have different modal theories, as $\Box^{k+1}\bot$ shows. $\square$

---

## 5. The multiplicity gap

**Definition 5.1 (Multiplicity frame).** The frame $M$ has, at every tag, the edges
$$1\to0,\qquad 2\to0,\qquad 3\to1,\quad 3\to2,\qquad 4\to1,$$
and the constant valuation making every atom true at every world, so that only transition structure is observable.

**Lemma 5.2 (Behavioural classes).** Let $c(m) := 1$ if $m\in\{1,2\}$, $2$ if $m\in\{3,4\}$, and $0$ otherwise. Then the kernel $\{(m,n) : c(m)=c(n)\}$ is a bisimulation of $M$ with itself.

*Proof sketch.* The atom clause is trivial. For *forth*, the only steps are those listed. A step out of $1$ or $2$ goes to $0$, and any world of class $1$ has a step to $0$; a step out of $3$ or $4$ goes to a world of class $1$, and any world of class $2$ has a step to $1$, which has class $1$. *Back* follows by symmetry of the kernel. $\square$

**Theorem 5.3 (Bisimilarity of the two roots).** $(M,3)\sim(M,4)$, hence $(M,3)\equiv(M,4)$: no modal formula, of any depth, separates a world with two behaviourally identical successors from one with a single successor.

**Lemma 5.4 (Out-degree is an isomorphism invariant).** If $F:(R,V,r)\cong(R',V',r')$ then $\deg_R(j,r)=\deg_{R'}(j,r')$ for every tag $j$.

*Proof sketch.* The forward map $f$ sends successors of $r$ to successors of $r'$ (step preservation, using $f(r)=r'$), is injective on reachable worlds (from $g\circ f = \mathrm{id}$), and is surjective onto the successors of $r'$ (given such an $n'$, the backward map yields a successor $g(n')$ of $r$ with $f(g(n'))=n'$). A bijection between the two successor sets gives equality of cardinalities. $\square$

**Theorem 5.5 (No pointed isomorphism).** There is no pointed isomorphism $(M,3)\cong(M,4)$.

*Proof sketch.* $\deg_M(0,3)=2$ and $\deg_M(0,4)=1$; apply Lemma 5.4. $\square$

**Theorem 5.6 (The multiplicity gap).** $\mathrm{BisimInv}\subsetneq\mathrm{IsoInv}$. Precisely:

1. every bisimulation-invariant interpretation is isomorphism invariant, since isomorphic pointed models are bisimilar;
2. the out-degree interpretation $I_{\deg,0}$ is isomorphism invariant but not bisimulation invariant, since it takes the values $2$ and $1$ on the bisimilar pair $(M,3),(M,4)$.

*Proof sketch of (1).* Given $F:(R,V,r)\cong(R',V',r')$, the relation $\{(m,f(m)) : m\in\mathrm{Reach}_R(r)\}$ is a bisimulation: atoms are preserved by hypothesis, *forth* is step preservation of $f$, and *back* is obtained by pulling a step back along $g$ and using $g\circ f=\mathrm{id}$ and $f\circ g=\mathrm{id}$ on reachable worlds. $\square$

**Theorem 5.7 (The two gaps are independent).** For every $k$, the pair $(M,3),(M,4)$ is depth-$k$ equivalent, yet separated by the multiplicity observation. The top gap is therefore not a limit of the finite gaps of §4: it is a different phenomenon, invisible at every depth.

Assembling §§3–5:

**Theorem 5.8 (Full resolution hierarchy).** For every $k$,
$$\mathrm{DepthInv}_0 \subsetneq \mathrm{DepthInv}_1 \subsetneq\cdots\subsetneq \mathrm{DepthInv}_k \subsetneq \mathrm{ModalInv} = \mathrm{BisimInv} \subsetneq \mathrm{IsoInv},$$
with the height observations $\Box^{k+1}\bot$ separating the finite layers and the out-degree separating the top one.

---

## 6. Multiplicity does not close the gap

The conjecture under test asserts that adding multiplicity data to bisimilarity recovers isomorphism. We refute it with a pair of five-world frames.

**Definition 6.1 (Shared diamond and unravelling).** At every tag:

* the *shared diamond* $S$ has edges $5\to3$, $5\to4$, $3\to1$, $4\to1$;
* the *unravelling* $T$ has edges $5\to3$, $5\to4$, $3\to1$, $4\to2$.

Both carry the constant valuation. From the root $5$, the diamond reaches four worlds $\{5,3,4,1\}$; the tree reaches five, $\{5,3,4,1,2\}$.

**Lemma 6.2 (Behavioural classes).** Let $s(m) := 2$ if $m=5$, $1$ if $m\in\{3,4\}$, and $0$ otherwise. Then $\{(m,n) : s(m)=s(n)\}$ is a bisimulation between $S$ and $T$.

*Proof sketch.* Atoms are constant. *Forth*: a step out of $5$ in $S$ lands in $\{3,4\}$, matched by the step $5\to3$ in $T$ (class $1$); a step out of $3$ or $4$ in $S$ lands at $1$ (class $0$), matched in $T$ by $3\to1$ or $4\to2$, both of class $0$. *Back*: symmetrically, a step out of $5$ in $T$ lands in $\{3,4\}$, matched by $5\to3$ in $S$; a step out of $3$ or $4$ in $T$ lands at $1$ or $2$, both class $0$, matched by the step to $1$ in $S$. $\square$

**Theorem 6.3 (Behavioural identity).** $(S,5)\sim(T,5)$, hence $(S,5)\equiv(T,5)$.

**Theorem 6.4 (Multiplicity match).** For all worlds $m,n$ with $s(m)=s(n)$ and every tag $i$, $\deg_S(i,m)=\deg_T(i,n)$.

*Proof sketch.* Neither frame depends on the tag, so it suffices to check tag $0$. Class $2$ forces $m=n=5$, where both degrees are $2$. Class $1$ forces $m,n\in\{3,4\}$, where all four degrees are $1$. Class $0$ forces both $m$ and $n$ outside $\{3,4,5\}$; the edge descriptions then give no outgoing edge at all, so both degrees are $0$. $\square$

So the observer, even upgraded with the ability to count successors at every world along the matching, sees nothing.

**Theorem 6.5 (No pointed isomorphism).** There is no pointed isomorphism $(S,5)\cong(T,5)$.

*Proof sketch.* Let $g$ be the backward map of such an isomorphism, so $g(5)=5$. The tree steps $5\to3$ and $5\to4$ are pulled back to steps $5\to g(3)$ and $5\to g(4)$ in the diamond, whose only successors of $5$ are $3$ and $4$; hence $g(3),g(4)\in\{3,4\}$. The tree step $3\to1$ pulls back to a step $g(3)\to g(1)$, and both $3$ and $4$ have unique successor $1$ in the diamond, so $g(1)=1$. Identically, the tree step $4\to2$ pulls back to $g(4)\to g(2)$, giving $g(2)=1$. But $g$ is injective on the reachable worlds of the tree (it has the forward map as a two-sided inverse there) and $1\ne2$ are both reachable. Contradiction. $\square$

Observe how little the argument uses: injectivity on reachable worlds and backward step preservation. It is therefore robust to substantial weakening of the notion of isomorphism.

**Theorem 6.6 (Refutation).** There exist pointed models that are simultaneously

1. bisimilar, hence modally indistinguishable at every depth;
2. multiplicity-matched: corresponding worlds have equal out-degrees at every tag;

and yet not isomorphic. Hence the clause "the gap is characterized by multiplicity-sensitive observations" is false.

**Discussion.** What survives is a strictly finer analysis. Both witnesses of this paper are *quotients*: $M$ identifies nothing but duplicates a successor, while $S$ is the quotient of $T$ that identifies its two behaviourally equal leaves. The first operation changes out-degree; the second does not. The residual invisible structure is therefore **sharing** — whether behaviourally equal successors are literally the same world — and a convenient numerical proxy for it is the number of reachable worlds ($4$ versus $5$ here), which is an isomorphism invariant but neither a modal nor a multiplicity invariant.

**Theorem 6.7 (Two-step ladder).** The resolution ladder above bisimulation has (at least) two proper steps:
$$\text{bisimulation} \;\subsetneq\; \text{bisimulation}+\text{multiplicity} \;\subsetneq\; \text{isomorphism},$$
witnessed by $(M,3)$ vs $(M,4)$ for the first inclusion and $(S,5)$ vs $(T,5)$ for the second; and the nominal language of §7 collapses the whole ladder to equality.

---

## 7. What closes the gap: names, and their price

### 7.1 Nominals

**Definition 7.1 (Nominal valuation).** $V_{\mathrm{nom}}\,m\,p := [\,m=p\,]$: the atom $p$ is true exactly at world $p$.

**Theorem 7.2 (Nominals force equality).** If $(R,V_{\mathrm{nom}},m)\equiv(R',V_{\mathrm{nom}},n)$ then $m=n$. Only the atomic (depth-$0$) fragment is used.

*Proof sketch.* Test the atom $m$. It is true at $m$ by definition; by modal equivalence it is true at $n$; by definition that means $n=m$. $\square$

**Corollary 7.3.** Over a nominal valuation on a fixed frame, modally equivalent pointed models are isomorphic — indeed identical, via the identity isomorphism. Consequently *every* interpretation whatsoever, including the multiplicity observation, is modally invariant on such a frame. This stands in sharp contrast to §5, whose witness carries the constant valuation.

Thus the gap of §§5–6 is an artefact of *atom-poor* valuations. The natural next question is the cost of naming.

### 7.2 The naming budget

**Definition 7.4 (Binary naming).** $V_{\mathrm{bin}}\,m\,p := $ the $p$-th bit of $m$.

**Theorem 7.5 (Logarithmic sufficiency).** Let $m,n<2^k$ agree on the atoms $0,\dots,k-1$ under $V_{\mathrm{bin}}$. Then $m=n$.

*Proof sketch.* Two naturals are equal iff all their bits agree. For $p<k$ the bits agree by hypothesis. For $p\ge k$, both $m$ and $n$ are below $2^k\le 2^p$, so both bits are $0$. $\square$

**Corollary 7.6.** For $m,n<2^k$, modal equivalence over $V_{\mathrm{bin}}$ on a fixed frame implies $m=n$, hence a pointed isomorphism; and the out-degree observation becomes modally invariant on that truncation. So $k$ atoms suffice to name $2^k$ worlds — and the collapse occurs already at box depth $0$.

**Theorem 7.7 (Matching lower bound).** Let $2^k\le N$ and let $V$ be *any* valuation. Then there exist distinct $m,n\le N$ with $V\,m\,p = V\,n\,p$ for all $p<k$.

*Proof sketch.* The map sending a world $m$ to its atomic $k$-type, an element of $\{\top,\bot\}^k$, has domain of size $\ge 2^k+1$ and codomain of size $2^k$. Pigeonhole. $\square$

**Theorem 7.8 (Naming threshold).** With $k$ atoms:

* *(sufficiency)* the binary valuation separates all worlds below $2^k$ atomically, so modal equivalence there is equality and every interpretation becomes modally invariant;
* *(necessity)* once the truncation level reaches $2^k$, no valuation separates all worlds atomically.

Hence $\lceil\log_2 N\rceil$ atoms is the exact budget at which the observational hierarchy collapses.

**Remark 7.9 (Scope of the lower bound).** Theorem 7.7 is about the *atomic* fragment. It does not claim that $k$ atoms together with modalities cannot separate more worlds — a frame may separate worlds structurally, as the chain of §4 does with no atoms at all. The correct reading is: *naming*, as opposed to *observing behaviour*, is impossible below the logarithmic budget. This is exactly the guarded statement one wants, since the phenomena of §§5–6 concern frames whose structure is deliberately behaviour-poor.

**Theorem 7.10 (The gap requires atom poverty).** The witnesses of §§5 and 6 both carry the constant valuation, and by Theorem 7.8 this is no accident: a frame whose valuation separates its worlds atomically admits no bisimulation/isomorphism gap at all.

---

## 8. Where the depth ladder stops

Theorem 4.8 shows the depth ladder is strict at every level; Theorem 4.9 that no finite level reaches bisimulation. Both statements quantify over all frames. On a *fixed truncation*, converse well-foundedness caps the useful interrogation length.

**Definition 8.1 (Trimming).** Define $\mathrm{tr}_k(a)$ by recursion: $\mathrm{tr}_k(\bot)=\bot$; $\mathrm{tr}_k(p)=p$; $\mathrm{tr}_k(a\to b)=\mathrm{tr}_k(a)\to\mathrm{tr}_k(b)$; $\mathrm{tr}_0(\Box_i a)=\top$; and $\mathrm{tr}_{k+1}(\Box_i a)=\Box_i \mathrm{tr}_k(a)$. In words: every box nested deeper than $k$ is replaced by verum.

**Lemma 8.2.** $\mathrm{bd}(\mathrm{tr}_k(a))\le k$ for every $a$ and $k$.

*Proof sketch.* Induction on $a$; the box case at level $0$ produces $\top$, of depth $0$, and at level $k+1$ increments a depth already bounded by $k$. $\square$

**Lemma 8.3 (Trimming is invisible below its level).** If $m\le k$ then $(R,V,m)\models \mathrm{tr}_k(a) \iff (R,V,m)\models a$.

*Proof sketch.* Induction on $a$, generalizing over $k$ and $m$. The only interesting case is $\Box_i b$. If $k=0$ then $m=0$; world $0$ has no successors, so $\Box_i b$ holds vacuously, as does $\top=\mathrm{tr}_0(\Box_i b)$. If $k=k'+1$, then every successor $n$ of $m$ satisfies $n<m\le k'+1$, hence $n\le k'$, and the induction hypothesis applies to $n$ at level $k'$; the two box clauses then match successor by successor. $\square$

**Theorem 8.4 (Collapse threshold).** If $m\le k$ and $n\le k$ and $(R,V,m)\equiv_k(R',V',n)$, then $(R,V,m)\equiv(R',V',n)$ — and hence, by Theorem 3.4, the two pointed models are bisimilar.

*Proof sketch.* Let $a$ be arbitrary. By Lemma 8.3 the truth value of $a$ at $m$ equals that of $\mathrm{tr}_k(a)$, and likewise at $n$. By Lemma 8.2, $\mathrm{tr}_k(a)$ has depth $\le k$, so the two values agree by hypothesis. $\square$

**Corollary 8.5.** For $m,n\le k$, bisimilarity, modal equivalence and depth-$k$ equivalence coincide.

**Theorem 8.6 (Sharpness).** In the chain, worlds $N$ and $N+1$ are depth-$N$ equivalent but not depth-$(N+1)$ equivalent; whereas by Theorem 8.4 depth $N+1$ does suffice for worlds of height at most $N+1$. Thus on a model of height $N$, the Hennessy–Milner interrogation needs exactly $N$ rounds, no more and no fewer in the worst case.

*Proof sketch.* Lemmas 4.5 and 4.6. $\square$

The infinite ladder of Theorem 5.8 is therefore infinite only because the truncation level is unbounded: on any fixed finite portion of any frame it collapses at the height.

---

## 9. Proof-theoretic shadow: theories cannot see sharing

Descending frames validate the Löb axiom, so their validity theories are Gödel–Löb-style provability logics. Fix a truncation level $N$ and let $\mathsf{Th}_N(R,V)$ be the theory whose theorems are exactly the formulas valid at every world $m\le N$; this is the *truncated theory* of the frame. A standard measure of strength for such theories is the family of *depth-restricted reflection rules*: $\mathsf{Th}$ satisfies $\mathrm{Refl}(d,i)$ when, for every $a$ of box depth $\le d$, provability of $\Box_i a$ entails provability of $a$.

**Theorem 9.1 (Theory transfer along bisimulation).** Let $E$ be a bisimulation between $(R,V)$ and $(R',V')$ such that every $m\le N$ is $E$-related to some $n\le N'$ and conversely. Then $\mathsf{Th}_N(R,V)$ and $\mathsf{Th}_{N'}(R',V')$ prove exactly the same formulas.

*Proof sketch.* Provability in a truncated theory is validity below the truncation. Given a formula provable on the left and $n\le N'$, choose a related $m\le N$; by Theorem 3.1 the formula's truth value at $n$ matches its value at $m$, where it is true. Symmetrically for the other direction. $\square$

**Corollary 9.2.** Under the same hypotheses the two theories satisfy exactly the same depth-restricted reflection rules; the entire reflection-depth spectrum is a bisimulation invariant.

**Theorem 9.3 (Deduction cannot detect sharing).** For every truncation level $N$, the shared diamond and its unravelling have literally the same truncated theory and the same reflection spectrum, agree on all out-degrees, and are not isomorphic.

*Proof sketch.* The class kernel of Lemma 6.2 relates each world to itself (since $s(m)=s(m)$), so the coverage hypotheses of Theorem 9.1 hold trivially at every $N$. Combine with Theorems 6.4 and 6.5. $\square$

**Theorem 9.4 (…nor multiplicity).** In the multiplicity frame, the two roots $3$ and $4$ have out-degrees $2$ and $1$ and are modally, hence proof-theoretically, indistinguishable.

Note that Theorem 9.1 requires only *coverage*, not a bijection. The truncated theory is therefore even coarser than bisimilarity of pointed models: it sees only the *set* of behaviours present below the truncation level, not their multiplicities. Coverage is nevertheless necessary — without it a frame with more worlds can validate strictly fewer formulas, so the theorem is not vacuous.

---

## 10. Algorithms

The results above are effective on finite truncations, and three algorithms make them concrete.

**Partition refinement for bisimilarity.** To compute bisimilarity on the worlds $0,\dots,N$ of a descending frame, start from the partition by atomic type (restricted to a finite atom set) and repeatedly split a block $B$ whenever two of its members have, for some tag $i$, different sets of successor-blocks. Each round is one Ehrenfeucht–Fraïssé round; by Theorem 8.4, at most $N$ rounds are needed, and in fact the process stabilizes after at most $N$ splits since each round either refines the partition or terminates. With $N$ worlds, $t$ tags and $E$ edges the naive implementation runs in $O(N\cdot t\cdot E)$; the classical Paige–Tarjan strategy of splitting by the smallest half improves this to $O(E\log N)$. The output blocks are exactly the modal-equivalence classes, by Theorem 3.4.

**Depth-graded refinement.** Halting the refinement after $k$ rounds yields exactly the depth-$k$ equivalence classes of Definition 4.1. Comparing successive partitions exhibits the strictness of Theorem 4.8 concretely: on the chain truncated at $N$, round $k$ separates world $k$ from everything above it, and the sequence of partitions strictly refines for exactly $N$ rounds before stabilizing — a direct computational reading of Theorem 8.6.

**Separating-formula synthesis.** When refinement places two worlds in different blocks, the proof of Lemma 3.3 is constructive and yields an explicit separating formula: recursively, if $m$ has a successor $m'$ inequivalent to every successor of $n$, take $A$ to be the conjunction of the separating formulas for $m'$ against each successor of $n'$, and return $\Diamond_i A$; the dual case returns the negation of the corresponding formula for the swapped pair. The recursion terminates because it descends in the frame, and the depth of the formula it returns is bounded by the round at which refinement split the two worlds.

Running the first two algorithms on the witnesses of §§5–6 reproduces the theorems: worlds $3$ and $4$ of the multiplicity frame land in the same block at every round, as do the two roots of the diamond and its unravelling, while an exhaustive enumeration of modal formulas over one atom and one tag built in three layers ($6560$ formulas) finds *no* separating formula for either witness pair, and many separating formulas for controls such as the chain worlds $1$ and $2$.

---

## 11. Applications

**Process algebra and verification.** Theorem 3.5 is a licence: any verification quantity that is definable by modal observation may be computed on *any* bisimilar model, in particular on the smallest one. Partition refinement therefore serves as a sound minimization pre-pass. Theorem 6.6 is the corresponding warning: minimization does not preserve state count in a way recoverable from behaviour plus branching degree — the state count is not a behavioural quantity even after the language is enriched with counting.

**Term graphs and sharing.** The distinction between the shared diamond and its unravelling is exactly the distinction between a term graph with sharing and the tree it denotes. Theorem 6.3 says the two denote the same value; Theorem 6.5 says they are different objects; Theorem 6.4 says that no amount of arity or degree information detects the difference. This is a precise statement of why sharing is a *space* property rather than a *semantic* one, and why compilers may freely introduce or eliminate it without semantic obligation but with real resource consequences.

**Epistemic logic and hybrid logic.** The nominal collapse of Theorem 7.2 explains, in one line, why hybrid logic with nominals has the expressive strength to define frame properties that pure modal logic cannot: naming is not a mild enrichment but a total one. Theorem 7.8 refines this into a quantitative statement — the enrichment is worth exactly $\log_2 N$ bits — which suggests reading fragments of hybrid logic as *partial* naming budgets.

**Provability logic.** Theorems 9.1–9.3 say that the whole spectrum of reflection strength of a truncated frame theory is behavioural. In the study of reflection principles this is a rigidity statement: proof-theoretic strength cannot distinguish structures that no observer distinguishes, no matter how much deductive machinery is added on top.

---

## 12. Discussion and future work

The conjecture we set out to test has been resolved with a split verdict. Its positive half — that modal invariance factors exactly through bisimulation classes — is a theorem here, in the strong form that the modal theory is a universal modally invariant interpretation. Its negative half — that the residue is multiplicity — is *true but incomplete*: multiplicity is a genuine gap and a genuinely non-modal observation, but adding it to bisimulation still falls strictly short of isomorphism. The obstruction is sharing.

Three structural lessons emerge.

1. **The hierarchy is two-dimensional.** Below bisimulation the gaps are about *depth* of nesting; above it, they are about *identity* of destinations. Theorem 5.7 shows the two dimensions are independent: the multiplicity witness is depth-$k$ equivalent for all $k$.
2. **The whole phenomenon is atom-relative.** Theorem 7.8 quantifies exactly how relative: $\lceil\log_2 N\rceil$ atoms dissolve every gap in the atomic fragment. All witnesses of a gap must therefore be atom-poor, and they are.
3. **Interrogation length equals height.** Theorem 8.4 turns the infinite depth ladder into a finite one on any bounded truncation, with the sharp bound realized by the chain.

Directions we consider most promising:

* **Axiomatize "bisimulation + multiplicity".** Graded modal logic, with counting modalities $\Diamond^{\ge n}$, is the obvious candidate for the intermediate level of Theorem 6.7. One would like a Hennessy–Milner theorem for it, whose induced equivalence should be exactly the intermediate relation, and an exact characterization of the second gap in terms of a sharing invariant.
* **A quantitative sharing invariant.** The number of reachable worlds separates the diamond from its unravelling, but is a crude measure. A canonical candidate is the *sharing defect*: the difference between the size of the unravelling-up-to-depth-$k$ and the size of the model. Whether this, or the lattice of quotients between a model and its minimal bisimilar quotient, gives a complete invariant for the second gap is open.
* **Partial naming budgets.** Between the constant valuation ($0$ atoms) and full naming ($\lceil\log_2 N\rceil$ atoms) lies a graded family. Does the resolution vary monotonically with the budget, and is there a threshold phenomenon — a budget below which nothing changes and above which everything collapses?
* **Beyond descending frames.** Descent buys image-finiteness and converse well-foundedness for free. Isolating which of the results survive under image-finiteness alone (Hennessy–Milner does; the collapse threshold of §8 does not, as it uses height) would clarify which are logical and which are structural facts.
* **Effective sharing detection.** Given two bisimilar finite models, decide isomorphism of their generated submodels. The problem is graph isomorphism restricted to a bisimulation class, and the restriction may well make it tractable; a complexity classification would be of practical value in term-graph rewriting.

---

## Appendix: summary of results

| Result | Statement |
|---|---|
| Image-finiteness | Successors of $m$ lie in $\{0,\dots,m-1\}$; heights are bounded by the world index. |
| Hennessy–Milner | Bisimilarity $=$ modal equivalence. |
| Factorization | $\mathrm{ModalInv}=\mathrm{BisimInv}$; the modal theory is universal. |
| Depth limit | Modal equivalence $=\bigcap_k$ depth-$k$ equivalence. |
| Depth strictness | $\Box^{k+1}\bot$ separates chain worlds $k$ and $k+1$; every rung is strict. |
| Multiplicity gap | $(M,3)\sim(M,4)$, non-isomorphic, out-degrees $2$ vs $1$; $\mathrm{BisimInv}\subsetneq\mathrm{IsoInv}$. |
| Independence | The multiplicity witness is depth-$k$ equivalent for every $k$. |
| Refutation | $(S,5)\sim(T,5)$, out-degrees matched everywhere, non-isomorphic. |
| Two-step ladder | bisim $\subsetneq$ bisim $+$ multiplicity $\subsetneq$ isomorphism. |
| Nominal collapse | Nominal valuation $\Rightarrow$ modal equivalence is equality, at depth $0$. |
| Naming budget | $k$ atoms name $2^k$ worlds; $2^k+1$ worlds always collide. Threshold $\lceil\log_2 N\rceil$. |
| Collapse threshold | Height $\le k$ $\Rightarrow$ depth-$k$ agreement implies modal equivalence; sharp. |
| Theory transfer | Truncated theories and reflection spectra are bisimulation invariants; deduction cannot see sharing. |
