# One Antichain at a Time: How Forbidding a Bigger Cube Always Buys You More Sets

## A game played on the power set

Take a finite ground set, say $[n] = \{1, 2, \dots, n\}$, and consider all $2^n$ of its subsets. Order them by inclusion. The picture you get — the *Boolean lattice* $2^{[n]}$ — is the most fundamental object in extremal set theory: a diamond-shaped cascade of layers, the $k$-th layer holding the $\binom{n}{k}$ sets of size $k$, each set joined by an edge to the sets one element larger.

Now play the following game. You are handed a shape — a small partially ordered set $P$ — and told: *build the largest family $\mathcal{F}$ of subsets of $[n]$ that does not contain a copy of $P$.* The maximum size of such a family is written $\mathrm{La}(n, P)$, and computing it, even approximately, is the central problem of an entire branch of combinatorics.

The oldest instance is a hundred years old. Take $P$ to be a two-element chain $\emptyset \subsetneq \{*\}$: forbidding a copy of it means no set in your family may contain another, i.e. your family is an *antichain*. Sperner's theorem, from 1928, says the answer is exactly the size of the biggest layer:
$$\mathrm{La}(n, \text{2-chain}) = \binom{n}{\lfloor n/2 \rfloor}.$$
Take the widest slab of the cube and you cannot do better.

This article is about what happens when the forbidden shape is itself a cube. Write $B_d$ for the Boolean lattice on $d$ atoms: $2^d$ elements, ordered by inclusion, a $d$-dimensional cube of subsets. So $B_1$ is the two-element chain, $B_2$ is a diamond, $B_3$ is the eight-vertex cube. Forbidding $B_d$ inside $2^{[n]}$ — that is the problem, and the case $d = 3$ is a famous open one.

## Two ways to be a copy

Before going further we need to be precise about "contains a copy", because there are two reasonable readings, and both matter.

A family $\mathcal{F}$ of subsets of $[n]$ contains a **weak copy** of a poset $P$ if there is an injective map $\iota$ from $P$ into $\mathcal{F}$ such that whenever $p < q$ in $P$, we have $\iota(p) \subsetneq \iota(q)$. Relations must be preserved; non-relations are unconstrained, so two incomparable elements of $P$ may perfectly well be sent to nested sets.

It contains a **strong copy** (also called an induced copy) if in addition the converse holds: $\iota(p) \subsetneq \iota(q)$ *only if* $p < q$. Incomparable elements must go to incomparable sets; the copy sits inside the cube exactly as $P$ looks from the outside.

A family with no weak copy of $P$ is called weak $P$-free, and $\mathrm{La}(n,P)$ is the largest size of such a family; the strong analogue is written $\mathrm{La}^*(n,P)$. Every strong copy is a weak copy, so being weak $P$-free is the stronger condition and $\mathrm{La}(n,P) \le \mathrm{La}^*(n,P)$.

## What was known, and the wall

For the cube posets $B_d$, the natural construction is to take $d$ consecutive layers of $2^{[n]}$, chosen as close to the middle as possible. Such a family contains no chain of $d+1$ sets, and $B_d$ has chains of length $d+1$ (from the empty set up to the full set), so no weak copy of $B_d$ can fit. That gives
$$\mathrm{La}(n, B_d) \ \ge \ \binom{n}{k} + \binom{n}{k+1} + \dots + \binom{n}{k+d-1}$$
for the best central choice of $k$: roughly $d \binom{n}{\lfloor n/2\rfloor}$ sets. In the other direction a chain-partition argument gives $\mathrm{La}(n, B_d) \le (2^d - 1)\binom{n}{\lfloor n/2\rfloor}$. For $d = 3$ this brackets the truth between roughly $3$ and $7$ central binomial coefficients, and the celebrated question is whether the constant $3$ can be beaten by a fixed amount $\varepsilon > 0$ for all large $n$.

Beating it is hard for a structural reason. If you try to improve the layer construction by *adding* a set of some other size, you instantly create a copy of $B_3$ — the layer families are maximal. If you try to improve it by taking a cleverer union of whole layers, you cannot: among all families defined purely by a set of allowed sizes, the $d$ central layers are exactly optimal. The same holds for any family invariant under permutations of the ground set. Any improvement must therefore break the symmetry of the cube — it must treat some elements of $[n]$ differently from others.

That is the backdrop. The results described below do not settle the $\varepsilon$ question; they answer a different and, in a sense, more basic one, and the mechanism they use is delightfully simple.

## The question: does forbidding more always buy you more?

Fix $n$ and let $d$ grow. Forbidding $B_{d+1}$ is a weaker restriction than forbidding $B_d$ — a weak copy of $B_{d+1}$ contains a weak copy of $B_d$, so anything $B_d$-free is $B_{d+1}$-free. Therefore
$$\mathrm{La}(n, B_1) \le \mathrm{La}(n, B_2) \le \mathrm{La}(n, B_3) \le \cdots$$
Monotone, certainly. But is it *strictly* increasing? Does relaxing the ban from $B_d$ to $B_{d+1}$ always let you keep at least one more set?

That sounds like it should be easy — and yet the naive attempts all fail. The obvious move is to take an extremal $B_d$-free family $\mathcal{F}$, throw in one extra set $A$, and argue that the result is $B_{d+1}$-free. But why should it be? A single new set can be the missing corner of dozens of would-be cubes, and the resulting copy of $B_{d+1}$ has $2^{d+1}$ vertices, of which $A$ is only one; deleting $A$ from that copy leaves a mutilated cube, not a copy of $B_d$. There is no obvious way to recover a $B_d$ inside $\mathcal{F}$ itself, which is what you would need for a contradiction. Until recently strictness was known only in the single boundary case $n = d + 1$, where both extremal numbers can be computed exactly.

The resolution turns on a small piece of geometry inside the cube $B_{d+1}$.

## The lifting trick

Here is the key question, stripped of set-theoretic clothing:

> Inside the cube $B_{d+1}$, is there always a copy of the cube $B_d$ that avoids a prescribed antichain?

An antichain in $B_{d+1}$ is a collection $A$ of its vertices, no one below another — a "flat" obstacle, like a layer. The claim is that no such obstacle can block every $d$-dimensional subcube-like copy of $B_d$ inside $B_{d+1}$.

Why is it true? Label the atoms of $B_{d+1}$ as $1, \dots, d, \star$, so that $B_d$ sits inside $B_{d+1}$ as the vertices avoiding the last atom $\star$. The naive copy of $B_d$ — the "bottom face" $\{X : \star \notin X\}$ — may well hit the obstacle $A$. But there is a whole family of other copies, one for every *up-set* $U$ of $B_d$ (an up-set being a collection of vertices closed under going upward). Define
$$\lambda_U(X) \;=\; \begin{cases} X \cup \{\star\}, & X \in U,\\[2pt] X, & X \notin U.\end{cases}$$
This says: take the bottom face and push the part of it lying in $U$ up to the top face. Because $U$ is an up-set, this map is an *order embedding*: $X \subsetneq Y$ if and only if $\lambda_U(X) \subsetneq \lambda_U(Y)$. (The one case worth checking: if $X \subsetneq Y$ with $X \in U$ and $Y \notin U$, we would need $X \cup \{\star\} \subsetneq Y$, which fails — but this case cannot arise, precisely because $U$ is upward closed.) So $\lambda_U$ carves a genuine copy of $B_d$ out of $B_{d+1}$, one that lives partly on the bottom face and partly on the top face, with a staircase between them determined by $U$.

Now choose the staircase to dodge the obstacle. Let
$$U \;=\; \{X \in B_d : \text{some } Z \subseteq X \text{ has its bottom-face copy in } A\},$$
the up-set generated by the vertices whose bottom-face copies lie in $A$. Two cases. If $X \notin U$, then $\lambda_U(X) = X$ is not in $A$, by the very definition of $U$. If $X \in U$, then $\lambda_U(X) = X \cup \{\star\}$ *strictly contains* some element $Z$ of $A$; since $A$ is an antichain, nothing strictly above a member of $A$ can itself be in $A$. Either way the image misses $A$ entirely.

That is the whole argument. It is three lines, and it is the engine for everything that follows.

## Adding an antichain costs one dimension

Translate the lifting trick back into families of sets and you get:

> **Antichain Augmentation Theorem.** If $\mathcal{F}$ is a family of subsets of $[n]$ containing no weak copy of $B_d$, and $\mathcal{L}$ is any antichain of subsets of $[n]$, then $\mathcal{F} \cup \mathcal{L}$ contains no weak copy of $B_{d+1}$. The same holds verbatim with "weak" replaced by "strong" throughout.

The proof is exactly the lifting trick. Suppose $\mathcal{F} \cup \mathcal{L}$ contained a copy $\iota$ of $B_{d+1}$. The vertices of $B_{d+1}$ that $\iota$ sends into the antichain $\mathcal{L}$ pull back an antichain-like obstacle inside $B_{d+1}$; feed it to the lifting construction to get a copy $\lambda_U$ of $B_d$ inside $B_{d+1}$ whose image under $\iota$ avoids $\mathcal{L}$ entirely. Composing, $\iota \circ \lambda_U$ is a copy of $B_d$ lying wholly inside $\mathcal{F}$ — contradiction.

You give the adversary an entire antichain — up to $\binom{n}{\lfloor n/2 \rfloor}$ new sets, an exponentially large addition — and the forbidden dimension goes up by only one.

## Three consequences

**Strict growth, always.** Suppose $n \ge d$. Then $2^{[n]}$ itself contains a copy of $B_d$ (just use the subsets of a fixed $d$-element subset), so an extremal weak $B_d$-free family $\mathcal{F}$ of size $\mathrm{La}(n, B_d)$ misses at least one subset $A$. A single set is an antichain. By the Antichain Augmentation Theorem, $\mathcal{F} \cup \{A\}$ is weak $B_{d+1}$-free, and it has one more member. Hence
$$\mathrm{La}(n, B_d) < \mathrm{La}(n, B_{d+1}) \qquad \text{whenever } d \le n,$$
and identically for the strong extremal numbers $\mathrm{La}^*$. The condition is not merely sufficient but necessary: if $d > n$ the cube $B_d$ has more vertices than $2^{[n]}$ has sets, both extremal numbers equal $2^n$, and the inequality fails. Iterating, $\mathrm{La}(n, B_d) + k \le \mathrm{La}(n, B_{d+k})$ as long as $d + k \le n+1$.

**A quantitative version.** One set is a feeble antichain; use a fat one. Given an extremal weak $B_d$-free family $\mathcal{F}$, its complement has $2^n - |\mathcal{F}|$ members spread over $n+1$ size classes, so some class contains at least $(2^n - |\mathcal{F}|)/(n+1)$ of them — and a single size class is an antichain. Adjoining it yields
$$2^n + n \cdot \mathrm{La}(n, B_d) \;\le\; (n+1)\cdot \mathrm{La}(n, B_{d+1}),$$
valid for every $n$ and every $d$. Equivalently, the gain $\mathrm{La}(n, B_{d+1}) - \mathrm{La}(n, B_d)$ is at least $(2^n - \mathrm{La}(n, B_d))/(n+1)$. For fixed $d$ and large $n$, the extremal number is only about $d\binom{n}{\lfloor n/2\rfloor} = o(2^n)$, so the gain is at least about $2^n/(n+1)$ — which is a constant times $\binom{n}{\lfloor n/2 \rfloor}/\sqrt{n}$. The natural guess is that the true gain is a full central binomial coefficient; the pigeonhole argument gets you to within a factor of $\sqrt{n}$ of that, unconditionally, with no case analysis at all.

**Height is enough.** The augmentation theorem also gives a clean, general sufficient condition for freeness. Define the *height* of a family to be the length of the longest chain $A_1 \subsetneq A_2 \subsetneq \cdots \subsetneq A_h$ inside it. Peel a family of height $h$ from the top: its maximal members form an antichain; removing them leaves a family of height $h-1$; repeat. Starting from the empty family (which is $B_0$-free) and adding one antichain at each of the $h$ steps, the augmentation theorem says the whole family is weak $B_h$-free. Hence:

> **Height Criterion.** A family with no chain of $d+1$ sets is weak (hence strong) $B_d$-free.

This contains the classical layer construction as a special case — $d$ consecutive layers have height $d$ — but applies far more generally, to arbitrary families of bounded height. A companion criterion follows immediately: any family whose members realise at most $d$ distinct sizes has height at most $d$, hence is weak $B_d$-free, with no requirement that it contain *all* sets of those sizes or be symmetric in any way.

Going the other way, a chain of $2^d$ sets already contains a weak copy of $B_d$ (list the $2^d$ vertices of $B_d$ in any order refining its partial order and match them to the chain in that order), so weak $B_d$-freeness forces height at most $2^d - 1$. Weak $B_d$-freeness is thus sandwiched:
$$\text{height} \le d \implies \text{weak } B_d\text{-free} \implies \text{height} \le 2^d - 1,$$
and neither threshold can be improved. On the low side, a family of height $d+1$ can already contain a copy of $B_d$: any single copy of $B_d$ inside $2^{[n]}$, e.g. all subsets of a fixed $d$-set, has height exactly $d+1$. On the high side, a chain of $2^d - 1$ sets is weak $B_d$-free for the crude reason that a copy of $B_d$ needs $2^d$ distinct sets. Between the two thresholds — height between $d+1$ and $2^d-1$ — freeness genuinely depends on the fine structure of the family, and that gap is exactly where the difficulty of the $B_3$ problem lives.

## What the small cases look like

Exhaustive computation on ground sets of size at most $4$ gives the following extremal numbers (weak and strong coincide here):

| $n \backslash d$ | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| 1 | 1 | 2 | 2 | 2 | 2 |
| 2 | 2 | 3 | 4 | 4 | 4 |
| 3 | 3 | 6 | 7 | 8 | 8 |
| 4 | 6 | 10 | 14 | 15 | 16 |

Every prediction is visible. Strictness holds exactly to the left of the diagonal $d = n$ and stops after it: on row $n = 3$, the values $3, 6, 7, 8$ increase strictly up to $d = 4 = n+1$ and then freeze at $2^n = 8$. Sperner's theorem is the first column. The row $n = 4$ shows $6 = \binom{4}{2}$, then $10 = \binom{4}{2} + \binom{4}{1}$ — the two central layers — then $14 = 2^4 - 2$, the exact value $\mathrm{La}(d+1, B_d) = 2^{d+1} - 2$ at the boundary. The pigeonhole inequality is tight-ish where it matters: for $n = 4$, $d = 3$ it reads $72 \le 75$.

## Why this is the right kind of tool

The Antichain Augmentation Theorem is a *structural* statement, not a counting one, and that is what makes it robust. It does not care how the free family was built, whether it is symmetric, whether it lives on a few layers, or how big it is. It converts one very concrete geometric fact — an antichain in a cube cannot block all the sub-cubes one dimension down — into a general principle: *the cost of an antichain is one dimension.*

There is an obvious conjecture waiting at the end of that sentence. If adding a $B_1$-free family (an antichain is exactly a family with no weak copy of $B_1$) costs one dimension, should adding a $B_e$-free family not cost $e$ dimensions? That is, if $\mathcal{F}$ is weak $B_d$-free and $\mathcal{G}$ is weak $B_e$-free, is $\mathcal{F} \cup \mathcal{G}$ always weak $B_{d+e}$-free? The theorem above is the case $e = 1$; exhaustive computation on small ground sets has turned up no counterexample. In poset language the conjecture asks: for every subset $A$ of $B_{d+e}$ containing no weak copy of $B_e$, is there a copy of $B_d$ inside $B_{d+e}$ avoiding $A$? The case $e=1$ is the lifting trick, and one would like a lifting construction of the same simplicity for general $e$.

Meanwhile the headline problem stands. Nobody knows whether $\mathrm{La}(n, B_3)$ exceeds $(3+\varepsilon)\binom{n}{\lfloor n/2\rfloor}$ for a fixed $\varepsilon > 0$ and all large $n$, nor whether the crude upper bound $(2^d-1)\binom{n}{\lfloor n/2\rfloor}$ can be pushed down to something linear in $d$. What we do know now is that the sequence $d \mapsto \mathrm{La}(n, B_d)$ never stalls before it must: every extra dimension of forbidden cube is worth at least one more set — in fact at least a $1/(n+1)$ share of everything not yet used — and the reason is a single antichain, lifted.
