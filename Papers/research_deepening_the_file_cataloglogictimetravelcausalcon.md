# Recurrence, Symmetry, and Coordinate Invariance in Finite Causal Loops

**Aristotle**  
**15 July 2026**

## Abstract

A deterministic causal loop can be modeled by a state space $S$ and a loop map $f:S\to S$, with a self-consistent history identified as a fixed point of $f$. This paper develops four structural principles beyond the bare fixed-point formulation. First, self-consistency is invariant under bijective changes of coordinates. Second, independently evolving systems are jointly self-consistent exactly when their components are. Third, every bijective loop on a nonempty finite phase space has a positive iterate that fixes every state simultaneously; in particular, each state is recurrent. Fourth, if the loop is involutive, then its number of fixed points has the same parity as the cardinality of the phase space, so every involution on an odd finite set has a fixed point. We also place these discrete conclusions beside the fixed-point theorem for a continuous self-map of an arbitrary compact real interval. Algorithms based on cycle decomposition compute fixed points, individual periods, and a minimal universal return time. A two-state switching model shows how a one-traversal paradox may coexist with universal consistency after two traversals. The resulting framework distinguishes one-step consistency from recurrence and reveals which conclusions arise from relabeling symmetry, product structure, finite permutation theory, parity, and topology.

## 1. Introduction

The logical core of a closed causal process is a feedback condition. A complete world-state enters a loop, undergoes the net evolution associated with one traversal, and must agree with the state that originally entered. If $S$ is the space of possible states and $f:S\to S$ is the net evolution, the consistency equation is simply $f(s)=s$. This fixed-point formulation is often associated with the Novikov self-consistency principle: globally admissible histories are those compatible with their own consequences.

The formulation is minimal enough to support several kinds of phase spaces. The set $S$ may be finite, an interval of real numbers, a product of subsystem spaces, or a space presented in alternative coordinates. It also makes possible a precise separation between two questions:

1. Does one traversal preserve some state?
2. Does some positive number of traversals preserve a state, or even every state?

These are not equivalent. A map can be fixed-point-free while its square is the identity. The elementary bit flip on $\{0,1\}$ already has this behavior. Accordingly, a theory confined to fixed points of $f$ misses recurrence under the iterates $f^n$.

This paper establishes a collection of exact results organizing that distinction. Section 2 gives the basic definitions. Section 3 proves that consistency is intrinsic under a bijective relabeling. Section 4 proves a product decomposition theorem. Section 5 derives exact universal recurrence for finite invertible loops. Section 6 proves a parity law for involutions. Section 7 gives the compact-interval fixed-point guarantee. Sections 8 and 9 present computational methods and examples, and the final sections discuss assumptions, applications, and open directions.

## 2. Definitions and basic distinctions

### Definition 2.1 (Causal loop)

A **causal loop** on a state space $S$ is a function $f:S\to S$. The value $f(s)$ is the world-state produced by one complete traversal beginning from $s$.

### Definition 2.2 (Self-consistent state and self-consistent loop)

A state $s\in S$ is **self-consistent** if $f(s)=s$. The loop is self-consistent if at least one self-consistent state exists, equivalently if

$$
\operatorname{Fix}(f)=\{s\in S:f(s)=s\}
$$

is nonempty.

### Definition 2.3 (Paradoxical loop)

A loop is **paradoxical** if it has no self-consistent state, that is, if $f(s)\ne s$ for every $s\in S$.

### Definition 2.4 (Iterated loop and recurrence)

For $n\ge0$, define $f^0=\operatorname{id}_S$ and $f^{n+1}=f\circ f^n$. A state $s$ is **recurrent** if $f^k(s)=s$ for some integer $k>0$. A positive integer $N$ is a **universal return time** if $f^N=\operatorname{id}_S$.

A fixed point is recurrent with return time $1$, but recurrence need not imply fixedness. If $f$ exchanges two states, each returns after two iterations although neither is fixed.

### Definition 2.5 (Invertibility and involutivity)

A loop is **invertible** if $f$ is bijective. It is **involutive** if

$$
f(f(s))=s
$$

for every $s\in S$. Every involution is invertible, with $f^{-1}=f$.

These definitions isolate three levels of structure. An arbitrary function provides deterministic evolution. A bijection adds reversibility and prevents information loss. An involution adds a time-reversal symmetry in which two traversals undo one another.

## 3. Coordinate invariance

A mathematical description may label the same physical states in different ways. The consistency property should not depend on those labels.

### Theorem 3.1 (Coordinate Invariance of Self-Consistency)

Let $e:S\to T$ be a bijection and let $f:S\to S$. Define the conjugate loop $g:T\to T$ by

$$
g=e\circ f\circ e^{-1}.
$$

Then $f$ has a fixed point if and only if $g$ has a fixed point. More precisely, $e$ restricts to a bijection

$$
e:\operatorname{Fix}(f)\longrightarrow\operatorname{Fix}(g).
$$

#### Proof sketch

If $s\in\operatorname{Fix}(f)$, then

$$
g(e(s))=e(f(e^{-1}(e(s))))=e(f(s))=e(s),
$$

so $e(s)$ is fixed by $g$. Conversely, if $t$ is fixed by $g$, apply $e^{-1}$ to $g(t)=t$ and use the definition of $g$ to obtain $f(e^{-1}(t))=e^{-1}(t)$. The two constructions are inverse because $e$ is bijective. $\square$

### Corollary 3.2 (Invariance of paradoxicality and fixed-point count)

Under the assumptions of Theorem 3.1, $f$ is paradoxical if and only if $g$ is paradoxical. If $S$ and $T$ are finite, then

$$
|\operatorname{Fix}(f)|=|\operatorname{Fix}(g)|.
$$

The theorem is stronger than an existence statement: it identifies corresponding consistent histories. Thus a change of coordinates cannot create, destroy, or change the number of fixed points.

## 4. Product compositionality

Suppose two subsystems evolve independently. Their combined phase space is a Cartesian product, and their joint evolution is componentwise.

### Theorem 4.1 (Product Consistency Theorem)

Let $f:S\to S$ and $g:T\to T$, and define $F:S\times T\to S\times T$ by

$$
F(s,t)=(f(s),g(t)).
$$

Then $F$ has a fixed point if and only if both $f$ and $g$ have fixed points. In fact,

$$
\operatorname{Fix}(F)=\operatorname{Fix}(f)\times\operatorname{Fix}(g).
$$

#### Proof sketch

The equality $F(s,t)=(s,t)$ is an equality of ordered pairs. It holds exactly when $f(s)=s$ and $g(t)=t$. Therefore every fixed pair consists of fixed components, and every pair of fixed components is fixed by $F$. $\square$

### Corollary 4.2 (Finite fixed-point multiplication)

If $S$ and $T$ are finite, then

$$
|\operatorname{Fix}(F)|=|\operatorname{Fix}(f)|\,|\operatorname{Fix}(g)|.
$$

### Corollary 4.3 (Persistence of a paradoxical component)

If either $f$ or $g$ is paradoxical, then $F$ is paradoxical.

The product theorem is expressly about decoupled systems. If the first component depends on the second, or conversely, fixed points can arise through coupling even when isolated component descriptions do not have them. Independence is encoded in the form $F(s,t)=(f(s),g(t))$.

## 5. Exact recurrence on finite phase spaces

Finite invertible dynamics is permutation dynamics. Its orbit structure provides an exact recurrence theorem.

### Lemma 5.1 (Cycle decomposition)

Let $S$ be finite and $f:S\to S$ bijective. Then $S$ is a disjoint union of cycles. For each $s\in S$, there is a least positive integer $p(s)$ such that $f^{p(s)}(s)=s$, and the orbit of $s$ has exactly $p(s)$ elements.

#### Proof sketch

The sequence $s,f(s),f^2(s),\ldots$ takes values in a finite set, so two terms coincide. If $f^i(s)=f^j(s)$ with $i<j$, injectivity allows cancellation of $f^i$, yielding $s=f^{j-i}(s)$. Hence a positive return time exists. Choose the least one. The states before the first return are distinct, and bijectivity ensures that no external state can feed irreversibly into the cycle. Repeating this argument on states not yet assigned yields disjoint cycles covering $S$. $\square$

### Theorem 5.2 (Universal Recurrence Theorem)

Let $S$ be a nonempty finite set and let $f:S\to S$ be bijective. Then there exists an integer $N>0$ such that

$$
f^N(s)=s
$$

for every $s\in S$. Equivalently, a positive iterate of the loop is the identity on the entire phase space.

#### Proof sketch by cycles

Write the cycle lengths as $\ell_1,\ldots,\ell_m$. Set

$$
N=\operatorname{lcm}(\ell_1,\ldots,\ell_m).
$$

The number $N$ is positive because $S$ is nonempty, so at least one cycle exists. On a cycle of length $\ell_i$, iteration by any multiple of $\ell_i$ fixes every state. Since each $\ell_i$ divides $N$, $f^N$ fixes all cycles and therefore all of $S$. $\square$

#### Alternative group-theoretic proof sketch

The bijection $f$ is an element of the finite symmetric group $\operatorname{Sym}(S)$. Every element of a finite group has finite positive order. Taking $N$ to be the order of $f$ gives $f^N=\operatorname{id}_S$. $\square$

### Corollary 5.3 (Statewise Discrete Recurrence)

Under the assumptions of Theorem 5.2, for every $s\in S$ there exists $k>0$ such that $f^k(s)=s$.

### Corollary 5.4 (Consistency of a positive iterate)

Under the same assumptions, some positive iterate is self-consistent. In fact, the iterate at a universal return time fixes every state.

### Proposition 5.5 (Minimal universal return time)

For a finite permutation whose cycle lengths are $\ell_1,\ldots,\ell_m$, the least positive universal return time is

$$
N_{\min}=\operatorname{lcm}(\ell_1,\ldots,\ell_m).
$$

#### Proof sketch

The least common multiple is a universal return time by Theorem 5.2. Conversely, if $M$ is any universal return time, then on each cycle a shift by $M$ positions must be trivial. Thus every $\ell_i$ divides $M$, so their least common multiple divides $M$. $\square$

The universal theorem is stronger than eventual repetition of one trajectory. It synchronizes all trajectories. It is also exact: the state returns, not merely to a nearby configuration but to itself.

### Necessity of the hypotheses

Finiteness cannot simply be discarded. The translation $f(n)=n+1$ is a bijection of the integers, but no positive iterate fixes any integer. Invertibility is also essential for universal recurrence. On $S=\{0,1\}$, the constant map $f(0)=f(1)=0$ is not bijective; state $1$ never returns after any positive number of steps. A noninvertible finite map may have recurrent states, but it need not make every state recurrent.

## 6. A parity law for involutive loops

Involutions have only one-cycles and two-cycles. This elementary orbit restriction yields a global fixed-point index modulo $2$.

### Theorem 6.1 (Parity Law for Involutive Loops)

Let $S$ be finite and let $f:S\to S$ satisfy $f^2=\operatorname{id}_S$. Then

$$
|\operatorname{Fix}(f)|\equiv |S|\pmod 2.
$$

#### Proof sketch

Partition $S$ into fixed points and nonfixed points. If $s$ is nonfixed, then $f(s)\ne s$ and involutivity gives $f(f(s))=s$. Thus nonfixed states occur in disjoint pairs $\{s,f(s)\}$. If there are $q$ fixed points and $r$ such pairs, then

$$
|S|=q+2r.
$$

Reduction modulo $2$ gives $|S|\equiv q\pmod2$. $\square$

### Corollary 6.2 (Odd-Cardinality Fixed-Point Guarantee)

Every involution on a finite set of odd cardinality has at least one fixed point. More precisely, it has an odd number of fixed points.

### Corollary 6.3 (Characterization of fixed-point-free involutions)

A fixed-point-free involution can exist only on an even set. Conversely, every finite set of even cardinality admits a fixed-point-free involution, obtained by partitioning the set into pairs and exchanging the members of each pair.

The parity law resembles a mod-$2$ fixed-point index. It determines no exact fixed-point count beyond parity: an involution on a set of size $7$ may have $1$, $3$, $5$, or $7$ fixed points. Nevertheless, it provides an existence theorem for odd spaces without requiring any search for a fixed state.

## 7. Continuous loops on compact intervals

Finite recurrence comes from cycle decomposition. A different mechanism forces one-step consistency on continuous interval dynamics.

### Theorem 7.1 (Compact-Interval Self-Consistency Theorem)

Let $a,b\in\mathbb{R}$ with $a\le b$, and let $f:[a,b]\to[a,b]$ be continuous. Then there exists $x\in[a,b]$ such that $f(x)=x$.

#### Proof sketch

Define $h(x)=f(x)-x$. Because $f(a)\in[a,b]$, one has $f(a)\ge a$, hence $h(a)\ge0$. Likewise $f(b)\le b$, hence $h(b)\le0$. The function $h$ is continuous. If either endpoint value is zero, that endpoint is fixed. Otherwise, the intermediate value theorem supplies $x\in(a,b)$ with $h(x)=0$, which is equivalent to $f(x)=x$. $\square$

This theorem applies to every compact real interval, not merely $[0,1]$. It does not require injectivity or surjectivity. Conversely, continuity and the interval constraint matter: a discontinuous self-map can avoid fixed points, as can a continuous map on a noncompact space such as $x\mapsto x+1$ on $\mathbb{R}$.

Coordinate invariance and the interval theorem interact naturally. If an interval is reparameterized by a homeomorphism, conjugating the loop preserves fixed points by Theorem 3.1, while continuity is preserved by composition with the homeomorphism and its inverse.

## 8. Algorithms

For a finite state space represented as $\{0,\ldots,n-1\}$, the map $f$ can be stored as an array with entry $f[i]$. The following methods expose the structural results computationally.

### Algorithm 8.1 (Fixed-point enumeration)

Scan every state and retain $i$ exactly when $f[i]=i$. This takes $O(n)$ time. Apart from the output list, it requires $O(1)$ auxiliary space. For an involution, comparing the resulting count with $n$ modulo $2$ tests the parity identity.

### Algorithm 8.2 (Cycle decomposition and minimal universal period)

First verify that the array is a permutation: every image lies in range and appears exactly once. Maintain a Boolean visited array. For each unvisited state, follow successive images until returning to the starting state, recording the cycle and its length. Update an accumulator by

$$
L\leftarrow\operatorname{lcm}(L,\ell)
$$

for each discovered cycle length $\ell$. At termination, $L$ is the minimal universal return time by Proposition 5.5. Each state is visited once, so cycle discovery takes $O(n)$ time and $O(n)$ space. Arithmetic on an unbounded integer adds a cost depending on the bit length of the growing least common multiple.

### Algorithm 8.3 (Conjugation under a relabeling)

Represent a bijection $e$ and its inverse by arrays. For each new label $t$, compute

$$
g(t)=e(f(e^{-1}(t))).
$$

The construction takes $O(n)$ time and $O(n)$ output space. Mapping the fixed points of $f$ through $e$ produces exactly the fixed points of $g$.

### Algorithm 8.4 (Independent product loop)

Given maps on sets of sizes $m$ and $n$, the product map has $mn$ states. It can be evaluated lazily in constant time per pair as $(s,t)\mapsto(f(s),g(t))$, without materializing all $mn$ transitions. Its fixed-point set is the Cartesian product of the two component fixed-point sets. Enumerating all fixed pairs therefore costs $O(m+n+ab)$, where $a$ and $b$ are the respective numbers of fixed points; this can be preferable to scanning all $mn$ pairs.

## 9. Examples

### Example 9.1 (The two-state switch)

Let $S=\{0,1\}$ and define $f(0)=1$, $f(1)=0$. Then $f$ has no fixed point:

$$
\operatorname{Fix}(f)=\varnothing.
$$

The loop is paradoxical after one traversal. However, $f^2=\operatorname{id}_S$, so both states return after two traversals. The cycle decomposition consists of one cycle of length $2$, and the minimal universal return time is $2$. Since $|S|=2$ and the fixed-point count is $0$, the parity theorem reads $0\equiv2\pmod2$.

### Example 9.2 (A mixed permutation)

On $S=\{0,1,2,3,4,5,6\}$, consider

$$
f=(0\ 1\ 2)(3\ 4)(5)(6),
$$

in cycle notation. The cycle lengths are $3,2,1,1$, so the minimal universal return time is

$$
\operatorname{lcm}(3,2,1,1)=6.
$$

States $5$ and $6$ are self-consistent after one traversal. States $3$ and $4$ return after two, while $0$, $1$, and $2$ return after three. All seven states return simultaneously after six.

### Example 9.3 (An odd involution)

Let $S=\{0,1,2,3,4\}$ and let $f$ exchange $0$ with $1$, exchange $2$ with $3$, and fix $4$. This is an involution with exactly one fixed point. The parity law gives

$$
1\equiv5\pmod2.
$$

No involution on five states can eliminate every fixed point, because nonfixed states must be consumed in pairs.

### Example 9.4 (Product consistency)

Let $f$ be the odd involution from Example 9.3, and let $g$ fix two states and exchange two others on a four-state space. Then $f$ has one fixed point and $g$ has two. The product loop has exactly $1\cdot2=2$ fixed points. If $g$ is replaced by the two-state switch, which has no fixed point, the product has none.

### Example 9.5 (A continuous interval loop)

On $[0,2]$, define

$$
f(x)=\frac{x+1}{2}.
$$

The map is continuous and maps $[0,2]$ into $[1/2,3/2]\subseteq[0,2]$. Solving $f(x)=x$ gives $x=1$. The interval theorem guarantees existence before the equation is explicitly solved.

## 10. Applications and interpretations

### 10.1 Reversible finite computation

A deterministic reversible machine with finitely many configurations evolves by a permutation. The universal recurrence theorem implies that some positive number of machine steps restores every possible configuration. This does not imply that the period is computationally small: the least common multiple of cycle lengths may be large. It does identify the exact algebraic source of repetition.

### 10.2 Finite-state protocols

A reversible update rule for a distributed protocol also decomposes into cycles. Fixed points represent stable configurations; longer cycles represent periodic operation. Product consistency applies when protocol components evolve without coupling, and conjugation invariance guarantees that changing state encodings preserves stability and recurrence.

### 10.3 Symmetric matching and parity

The involution theorem is not limited to temporal language. Whenever objects are either fixed or paired by a self-inverse operation, the unpaired count has the same parity as the population. The familiar principle that an odd collection cannot be perfectly paired is precisely the fixed-point corollary.

### 10.4 Modeling caution

A universal return time for $f$ does not mean that $f$ itself has a fixed point. It means the composite evolution $f^N$ does. Physically, treating $N$ traversals as one effective loop may or may not fit a particular interpretation. Mathematically, the distinction is exact and should not be blurred.

Likewise, finiteness is an idealization. A finite discretization of a continuous system may display exact recurrence even when the underlying infinite system has only approximate recurrence or none. The theorem describes the discrete model, not an automatic property of every continuum limit.

## 11. Discussion

The results expose several logically independent sources of order.

Coordinate invariance is set-theoretic: it depends only on bijective conjugacy. Product consistency is categorical in flavor: fixed points of an independent product are products of fixed points. Universal recurrence is group-theoretic and arithmetic: finiteness and invertibility turn the loop into a finite permutation, and least common multiples synchronize its cycles. The parity law is combinatorial: involutivity partitions all nonfixed states into pairs. Interval consistency is topological: continuity forces a sign change of $f(x)-x$ between the endpoints.

These mechanisms answer different questions. Topology can force a fixed point of a single traversal. Finite permutation theory may fail to force such a point but always forces a universally fixed positive iterate. Parity can force a one-step fixed point for involutions on odd spaces, while permitting fixed-point-free involutions on even spaces. Product structure transfers existence componentwise, and coordinate changes preserve all these conclusions.

The two-state switch is therefore not a counterexample to recurrence but a minimal demonstration of its difference from fixed-point consistency. It is paradoxical at one step, universally recurrent at two steps, compatible with the parity law, and unchanged in these respects under any relabeling of its states.

## 12. Future work

A quantitative recurrence theory should characterize the spectrum of individual minimal periods and the least universal period. Cycle decomposition suggests that the latter is the least common multiple of orbit lengths; further questions concern which divisor patterns are realizable for a prescribed phase-space size and how rapidly the universal period can grow.

The mod-$2$ law for involutions invites finer fixed-point indices for general permutations. Signed orbit counts or algebraic traces may encode information beyond parity while remaining invariant under conjugacy.

The interval result points toward higher-dimensional compact convex phase regions. There, fixed-point existence is governed by higher-dimensional topological principles rather than the intermediate value theorem. Coordinate invariance should then be studied under homeomorphisms, preserving both topology and fixed-point correspondence.

Coupled product systems provide another direction. Once the evolution has the form $F(s,t)=(F_1(s,t),F_2(s,t))$, componentwise consistency no longer suffices. Conditions such as contraction, monotonicity, or weak coupling may replace exact decoupling and yield new existence criteria.

Finally, recurrence under perturbation deserves study. Exact permutations are brittle under information loss, while continuous systems often support approximate rather than exact returns. A unified theory could compare exact finite recurrence, probabilistic return, and topological fixed-point guarantees within one causal-loop framework.

## 13. Conclusion

A causal loop represented by $f:S\to S$ has a self-consistent history exactly when $f$ has a fixed point. From this elementary definition follow several robust structural laws. Bijective relabeling preserves fixed points; independent products are consistent exactly componentwise; finite invertible loops possess a positive iterate that fixes every state; involutions have a fixed-point count congruent to the size of the phase space modulo $2$; and continuous self-maps of compact real intervals possess fixed points.

These statements distinguish intrinsic structure from representation and one-step consistency from eventual return. In a finite reversible world, a loop may contradict every state after one traversal, yet cycle arithmetic guarantees a positive number of traversals after which every state returns exactly. Symmetry and finiteness do not erase paradox, but they sharply delimit its possible forms.
