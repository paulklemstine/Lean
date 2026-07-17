# Phantom Topologies and Consensus Decompositions

**Aristotle**  
**July 17, 2026**

## Abstract

An observer-indexed topological system assigns a topology $\tau_o$ on a fixed set $X$ to each observer $o$. We define its consensus as the intersection $\bigcap_o\tau_o$, so a set is consensus-open exactly when every observer regards it as open. The unrestricted minimum-observer invariant is degenerate: every topology is represented by the singleton family containing itself. We therefore introduce genuine phantom representations, in which every observer topology is strictly finer than the consensus. No genuine singleton representation exists. We then prove that the standard topology on $\mathbb R$ is the consensus of two strict refinements: the lower-limit and upper-limit topologies. The proof gives an explicit local conversion between two one-sided half-open neighborhoods and an ordinary open neighborhood. Finally, we disprove the proposed lower bound of three observers for nonmetrizable spaces. The indiscrete topology on a two-point set is nonmetrizable, yet it is the consensus of the two opposite Sierpiński topologies, both strict refinements. These results identify the correct structural issue as reducibility in the lattice of topologies, rather than second countability or metrizability. We conclude with algorithms for finite consensus calculations and directions for a genuine phantom-number theory.

## 1. Introduction

A topology specifies which subsets of a set are open and thereby determines continuity, convergence, neighborhoods, and separation. Standard usage equips a set with one topology. The observer viewpoint considered here replaces that single choice by a family of choices: each observer sees the same points but may classify different subsets as open. The topology shared by all observers is their consensus.

This construction suggests a measure of how many viewpoints are needed to determine a space. However, direct examination reveals that the naïve invariant contains a universal loophole. One observer can simply be assigned the target topology. Thus every space has an unrestricted one-observer representation, independently of countability, separation, metrizability, or algebraic origin.

The appropriate repair is a nondegeneracy condition. Every observer must see strictly more open sets than are retained by consensus. We call such a representation genuine. The observer topologies are then proper refinements whose extra open sets cancel under intersection.

Two examples determine the scope of this corrected notion. First, the ordinary real line has a natural genuine representation by two directional topologies. One observer uses intervals of the form $[x,b)$, while the other uses intervals of the form $(a,x]$. Agreement restores ordinary open intervals. Second, nonmetrizability does not force an additional observer: the indiscrete two-point space is the intersection of two opposite Sierpiński topologies.

The resulting theory is order-theoretic. For a fixed set $X$, topologies are ordered by inclusion of open-set collections. Genuine two-observer representability of $\tau$ asks for strict refinements $\sigma_1$ and $\sigma_2$ satisfying $\sigma_1\cap\sigma_2=\tau$. The natural invariant therefore concerns meet-reducibility in this inclusion order, or equivalently join-reducibility under the reverse-inclusion convention often used for topological lattices.

## 2. Definitions and basic structure

### 2.1 Topologies and refinement

**Definition 2.1 (Topology).** A topology on a set $X$ is a family $\tau\subseteq\mathcal P(X)$ such that:

1. $\varnothing\in\tau$ and $X\in\tau$;
2. if $U,V\in\tau$, then $U\cap V\in\tau$;
3. if $\mathcal U\subseteq\tau$, then $\bigcup\mathcal U\in\tau$.

The pair $(X,\tau)$ is a topological space. Members of $\tau$ are open sets.

**Definition 2.2 (Refinement).** For two topologies $\tau$ and $\sigma$ on $X$, the topology $\sigma$ is finer than $\tau$ when $\tau\subseteq\sigma$. It is strictly finer when $\tau\subsetneq\sigma$.

Finer topologies contain more open sets and hence make continuity into them harder, while providing more neighborhoods with which to distinguish points.

### 2.2 Observer systems and consensus

**Definition 2.3 (Phantom system).** Let $O$ be a nonempty set of observers and $X$ a set. A phantom system is a family $T=(\tau_o)_{o\in O}$ in which each $\tau_o$ is a topology on $X$.

**Definition 2.4 (Consensus topology).** The consensus of $T$ is

$$
\operatorname{Con}(T)=\bigcap_{o\in O}\tau_o.
$$

Thus a subset $U\subseteq X$ belongs to $\operatorname{Con}(T)$ if and only if $U\in\tau_o$ for every $o\in O$.

**Proposition 2.5 (Consensus is a topology).** For every phantom system $T$, the family $\operatorname{Con}(T)$ is a topology on $X$.

**Proof sketch.** Every topology $\tau_o$ contains $\varnothing$ and $X$, so both belong to their intersection. If $U$ and $V$ lie in every $\tau_o$, then $U\cap V$ lies in every $\tau_o$. If each member of a family $\mathcal U$ lies in every $\tau_o$, then $\bigcup\mathcal U$ lies in every $\tau_o$. These are exactly the topology axioms. $\square$

**Corollary 2.6 (Observers refine consensus).** For every observer $o$,

$$
\operatorname{Con}(T)\subseteq\tau_o.
$$

This follows immediately from the definition of intersection.

### 2.3 Degeneracy and genuine representations

**Theorem 2.7 (Universal singleton representation).** Every topology $\tau$ on every set $X$ is the consensus of a one-observer phantom system.

**Proof sketch.** Take $O$ to be a singleton and assign its unique observer the topology $\tau$. Then $\operatorname{Con}(T)=\bigcap_{o\in O}\tau_o=\tau$. $\square$

The theorem applies without hypotheses such as second countability or metrizability. It also applies to any Zariski topology. Therefore the unrestricted least number of observers is not a useful complexity invariant: under the convention that observer sets are nonempty, it is always one.

**Definition 2.8 (Genuine phantom representation).** A phantom system $T=(\tau_o)_{o\in O}$ is genuine when

$$
\operatorname{Con}(T)\subsetneq\tau_o
$$

for every $o\in O$.

Each observer must possess at least one open set that consensus rejects.

**Theorem 2.9 (No genuine singleton).** No phantom system with exactly one observer is genuine.

**Proof sketch.** If $O=\{o\}$, then $\operatorname{Con}(T)=\tau_o$. Genuine strictness would require $\tau_o\subsetneq\tau_o$, which is impossible. $\square$

This theorem establishes the universal lower bound of two for every genuine representation that exists.

## 3. Directional topologies on the real line

### 3.1 Lower- and upper-limit openness

**Definition 3.1 (Lower-limit topology).** A subset $U\subseteq\mathbb R$ is lower-limit open if for every $x\in U$ there exists $b>x$ such that

$$
[x,b)\subseteq U.
$$

The collection of all such sets is denoted $\tau_\ell$.

**Definition 3.2 (Upper-limit topology).** A subset $U\subseteq\mathbb R$ is upper-limit open if for every $x\in U$ there exists $a<x$ such that

$$
(a,x]\subseteq U.
$$

The collection of all such sets is denoted $\tau_u$.

**Proposition 3.3 (Directional rules define topologies).** Both $\tau_\ell$ and $\tau_u$ are topologies on $\mathbb R$.

**Proof sketch.** We treat $\tau_\ell$; the upper case is symmetric. The empty-set condition is vacuous. For $\mathbb R$, choose $b=x+1$ at each $x$. If $x\in U\cap V$, choose witnesses $b_U>x$ and $b_V>x$ and put $b=\min\{b_U,b_V\}$. Then $[x,b)\subseteq U\cap V$. If $x\in\bigcup\mathcal U$, select some $U\in\mathcal U$ containing $x$ and use its witness. Thus arbitrary unions and finite intersections preserve lower-limit openness. $\square$

Let $\tau_E$ denote the standard Euclidean topology on $\mathbb R$.

**Lemma 3.4 (Euclidean openness implies directional openness).** If $U\in\tau_E$, then $U\in\tau_\ell\cap\tau_u$.

**Proof sketch.** Given $x\in U$, choose $\varepsilon>0$ with $(x-\varepsilon,x+\varepsilon)\subseteq U$. Then

$$
[x,x+\varepsilon)\subseteq U
\quad\text{and}\quad
(x-\varepsilon,x]\subseteq U.
$$

These are the required lower- and upper-limit witnesses. $\square$

### 3.2 Agreement recovers Euclidean topology

**Lemma 3.5 (Two one-sided witnesses produce a Euclidean neighborhood).** Suppose $x\in U$, $[x,b)\subseteq U$ for some $b>x$, and $(a,x]\subseteq U$ for some $a<x$. Then $(a,b)$ is an ordinary open neighborhood of $x$ contained in $U$.

**Proof sketch.** Every $y\in(a,b)$ satisfies either $y\le x$, in which case $y\in(a,x]$, or $x\le y$, in which case $y\in[x,b)$. Therefore $(a,b)\subseteq U$. $\square$

**Theorem 3.6 (Real-line consensus theorem).** For every $U\subseteq\mathbb R$,

$$
U\in\tau_E
\quad\Longleftrightarrow\quad
U\in\tau_\ell\text{ and }U\in\tau_u.
$$

Equivalently,

$$
\tau_E=\tau_\ell\cap\tau_u.
$$

**Proof sketch.** The forward implication is Lemma 3.4. Conversely, suppose $U$ is open in both directional topologies. For each $x\in U$, lower-limit openness supplies $b>x$ with $[x,b)\subseteq U$, while upper-limit openness supplies $a<x$ with $(a,x]\subseteq U$. Lemma 3.5 gives the Euclidean neighborhood $(a,b)\subseteq U$. Since every point of $U$ has an ordinary open neighborhood contained in $U$, the set $U$ is Euclidean-open. $\square$

The same proof can be phrased in metric language. The number

$$
r=\min\{x-a,b-x\}
$$

is positive, and the open ball $(x-r,x+r)$ lies in $U$.

### 3.3 Strictness of the two observers

**Lemma 3.7 (A lower-only open set).** The interval $[0,1)$ belongs to $\tau_\ell$ but not to $\tau_E$.

**Proof sketch.** If $x\in[0,1)$, then $[x,1)\subseteq[0,1)$, proving lower-limit openness. If $[0,1)$ were Euclidean-open, some $\varepsilon>0$ would satisfy $(-\varepsilon,\varepsilon)\subseteq[0,1)$. But $-\varepsilon/2$ lies in the former interval and not the latter. $\square$

**Lemma 3.8 (An upper-only open set).** The interval $(0,1]$ belongs to $\tau_u$ but not to $\tau_E$.

**Proof sketch.** If $x\in(0,1]$, then $(0,x]\subseteq(0,1]$. Euclidean openness at $1$ would force $1+\varepsilon/2$ into $(0,1]$ for some $\varepsilon>0$, a contradiction. $\square$

**Theorem 3.9 (Genuine two-observer representation of the real line).** The family $(\tau_\ell,\tau_u)$ is a genuine phantom representation of $(\mathbb R,\tau_E)$.

**Proof sketch.** Theorem 3.6 identifies the consensus with $\tau_E$. Lemma 3.4 shows $\tau_E\subseteq\tau_\ell$ and $\tau_E\subseteq\tau_u$. Lemmas 3.7 and 3.8 show both inclusions are strict. $\square$

Combining Theorems 2.9 and 3.9, the genuine phantom number of the standard real line, if defined as the least finite size, is exactly two.

## 4. A nonmetrizable two-observer counterexample

### 4.1 Three topologies on two points

Let $B=\{F,T\}$ be a two-element set.

**Definition 4.1 (Indiscrete topology).** The indiscrete topology on $B$ is

$$
\tau_I=\{\varnothing,B\}.
$$

**Definition 4.2 (Opposite Sierpiński topologies).** Define

$$
\tau_T=\{\varnothing,\{T\},B\}
$$

and

$$
\tau_F=\{\varnothing,\{F\},B\}.
$$

Each displayed family is a topology: unions and finite intersections of its three members remain among those members.

**Proposition 4.3 (Sierpiński consensus).** The consensus of $\tau_T$ and $\tau_F$ is the indiscrete topology:

$$
\tau_T\cap\tau_F=\tau_I.
$$

**Proof sketch.** Both topologies contain $\varnothing$ and $B$. Their only other open sets are different singletons, so there are no additional common members. $\square$

Both refinements are strict because $\{T\}\in\tau_T\setminus\tau_I$ and $\{F\}\in\tau_F\setminus\tau_I$.

### 4.2 Why the consensus is not metrizable

**Lemma 4.4 (Metric spaces separate distinct points).** If a topology is induced by a metric $d$ and $x\ne y$, then there is an open set containing $x$ but not $y$.

**Proof sketch.** Since $d(x,y)>0$, the ball of radius $d(x,y)/2$ centered at $x$ contains $x$ and excludes $y$. $\square$

**Theorem 4.5 (The two-point indiscrete space is nonmetrizable).** No metric on $B$ induces $\tau_I$.

**Proof sketch.** If such a metric existed, Lemma 4.4 would provide an open set containing $F$ but not $T$. The only nonempty $\tau_I$-open set is $B$, which contains both points. This is a contradiction. $\square$

**Theorem 4.6 (Nonmetrizable genuine two-observer representation).** A nonmetrizable space can have a genuine two-observer representation. Specifically, $(B,\tau_I)$ is nonmetrizable and is the consensus of the strict refinements $\tau_T$ and $\tau_F$.

**Proof sketch.** Nonmetrizability is Theorem 4.5. Consensus is Proposition 4.3, and the singleton opens establish strictness. $\square$

Theorem 4.6 disproves the claim that every nonmetrizable topology requires at least three observers, even under the genuine strictness repair. It also warns against treating observer number as a proxy for geometric regularity.

## 5. Lattice interpretation

Fix a set $X$ and write $\operatorname{Top}(X)$ for the collection of all topologies on $X$, ordered by inclusion. Arbitrary intersections of topologies are topologies, so $\operatorname{Top}(X)$ is a complete lattice. Under inclusion order, consensus is the meet:

$$
\operatorname{Con}(T)=\bigwedge_{o\in O}\tau_o=\bigcap_{o\in O}\tau_o.
$$

Some conventions reverse this order, regarding a topology with fewer open sets as larger. Under that convention the same operation is a join. The mathematics is independent of notation, but inclusion order makes the “common opens” interpretation immediate.

**Proposition 5.1 (Two-observer criterion).** A topology $\tau$ has a genuine two-observer representation if and only if there exist topologies $\sigma_1$ and $\sigma_2$ on $X$ such that

$$
\tau\subsetneq\sigma_1,
\qquad
\tau\subsetneq\sigma_2,
\qquad
\sigma_1\cap\sigma_2=\tau.
$$

**Proof sketch.** Unpack the definitions. A two-observer family consists exactly of two topologies; genuineness gives the two strict inclusions, and consensus gives the intersection equality. Conversely, any pair with these three properties is a genuine two-observer system. $\square$

Thus the central property is meet-reducibility by proper upper elements. The real line is reducible via directional topologies, while the indiscrete two-point topology is reducible via complementary Sierpiński topologies. Neither construction relies on a countable base as the operative mechanism, and one occurs in a metrizable space while the other occurs in a nonmetrizable space.

A prospective **genuine phantom number** should be defined as the least cardinal $\kappa$ for which there is an observer set $O$ of cardinality $\kappa$ and a genuine family with consensus $\tau$. Care is required when no genuine family exists or when only infinite observer sets work. One may therefore use a cardinal-valued partial invariant, or adjoin an infinity symbol.

## 6. Algorithms and numerical illustrations

Although the real-line theorems quantify over infinite families of points, their local mechanism is computational. Given directional witnesses $a<x<b$, define

$$
r=\min\{x-a,b-x\}.
$$

Then $r>0$ and

$$
(x-r,x+r)\subseteq(a,b)\subseteq U.
$$

This yields a **local consensus certificate algorithm**:

1. input $a,x,b$ with $a<x<b$;
2. compute the left margin $x-a$ and right margin $b-x$;
3. output their minimum $r$;
4. certify that the Euclidean ball of radius $r$ around $x$ lies in the union of the two one-sided witnesses.

The arithmetic cost is constant: two subtractions, one comparison, and storage of a constant number of real values.

For a finite set $X$ represented by bit masks, a topology can be stored as a set of masks. Consensus of $m$ observer topologies is ordinary set intersection. If each topology is represented by a Boolean table of length $2^{|X|}$, the calculation takes $O(m2^{|X|})$ time and $O(2^{|X|})$ output space. Verification that a candidate family is genuine additionally checks, for each observer, that its open-set table properly contains the consensus table.

On $B=\{F,T\}$, encode $\varnothing$, $\{F\}$, $\{T\}$, and $B$ by masks $0$, $1$, $2$, and $3$. Then

$$
\tau_T=\{0,2,3\},
\qquad
\tau_F=\{0,1,3\},
$$

and their intersection is $\{0,3\}=\tau_I$. The proper differences are $\{2\}$ and $\{1\}$, which simultaneously compute consensus and certify genuineness.

Sampling can illustrate but not replace the exact real-line argument. A finite grid can test that sampled points of $(a,x]$ and $[x,b)$ cover sampled points in $(a,b)$, while highlighting why $[0,1)$ fails ordinary openness at $0$ and $(0,1]$ fails it at $1$. The theorem itself rests on inequalities and applies to all real points, not merely samples.

## 7. Applications and interpretation

The observer formalism models systems in which several descriptions contain viewpoint-specific distinctions while a shared structure is extracted by unanimity.

In distributed sensing, observers may use asymmetric detection windows. One sensor may reliably register events beginning at a threshold, another events ending there. Consensus suppresses directional artifacts. In information systems, each policy may expose extra admissible regions; intersecting policies retains only universally authorized regions. In model comparison, different coordinate conventions can introduce distinct local primitives while their common open structure records invariant continuity.

These are analogies rather than claims that every application literally carries a topology. Their mathematical value is to emphasize what consensus does: it discards every open-set judgment not shared by all observers. Adding observers can only coarsen consensus, because intersections over larger families have no more members. Giving an individual observer more open sets need not alter consensus if those extra sets are rejected elsewhere.

The real-line example is especially instructive because the two biases are complementary. Lower-limit topology treats each point as included at the beginning of a local interval; upper-limit topology includes it at the end. Their agreement erases orientation. The two-point example instead uses complementary distinguishability: each observer isolates a different point, while consensus distinguishes neither.

## 8. Discussion

Three conclusions follow.

First, definitions must prevent an observer from being identical to the target if observer count is intended to measure decomposition. Without strictness, every lower-bound conjecture above one is immediately false.

Second, the repaired theory is nontrivial. The standard real line has an explicit genuine representation and, because genuine singleton systems cannot exist, requires exactly two observers among finite genuine representations.

Third, metrizability does not control this number. The indiscrete two-point counterexample is as small as possible while still having distinct points. Its failure of metrizability is a separation failure, yet complementary refinements recover it with two observers.

The original pointwise phrasing—roughly, that a set accepted by every observer “containing” a point should be a neighborhood—requires refinement. An observer is a topology, not a subset of $X$, so an observer does not itself contain a point. One could instead specify observers whose chosen open neighborhoods contain the point, or require a condition for every observer topology. Any such local formulation should be proved equivalent to consensus equality rather than assumed to be so.

The Zariski case also changes character. Under the unrestricted definition, every Zariski topology has a singleton representation. Under the genuine definition, the meaningful question is whether the given Zariski topology is an intersection of two proper refinements. Answering it requires its algebraic structure; replacing it with a merely cofinite example would not settle the affine-space problem.

## 9. Future work

Several directions emerge naturally.

1. **Define the genuine phantom number rigorously.** The definition must accommodate nonexistence and infinite minima while preserving useful cardinal arithmetic.

2. **Characterize lattice-theoretic existence.** Genuine two-observer representability is exactly proper two-factor meet reducibility in inclusion order. Structural criteria for reducibility could replace ad hoc constructions.

3. **Analyze Zariski topologies under the repaired definition.** The central question is whether affine Zariski topologies are irreducible in the relevant topology lattice or admit proper two-observer decompositions.

4. **Compare finite and infinite observer families.** One may ask when an intersection of arbitrarily many strict refinements reduces to a finite subintersection, a compactness problem in the lattice of topologies.

5. **Develop a precise neighborhood formulation.** The intended local semantics should specify observer-dependent neighborhoods and establish equivalence, when valid, with global intersection.

6. **Prove homeomorphism invariance.** If $f:X\to Y$ is a homeomorphism, each observer topology on $X$ can be transported along $f$. This should preserve consensus, strictness, and observer cardinality.

7. **Classify finite spaces computationally.** Finite topologies can be enumerated, their refinement posets formed, and genuine phantom numbers calculated exactly. Such data may reveal general lattice patterns.

## 10. Conclusion

Consensus topology formalizes a simple idea: a set is open in shared reality precisely when every observer declares it open. The unrestricted observer count collapses because the target topology itself is always a valid singleton observer. Requiring every observer to be a strict refinement produces a meaningful decomposition problem.

Under this correction, the standard real line is recovered from two directional observers. Lower-limit and upper-limit openness jointly provide an ordinary neighborhood at every point, while half-open intervals show that each observer is strictly finer than consensus. Yet two observers are not a signature of metrizability: opposite Sierpiński topologies have the nonmetrizable two-point indiscrete topology as their genuine consensus.

The theory therefore belongs primarily to the order structure of topologies. Its basic question is not how distances describe a space, but how a topology can arise as the stable common core of richer and mutually incompatible refinements.
