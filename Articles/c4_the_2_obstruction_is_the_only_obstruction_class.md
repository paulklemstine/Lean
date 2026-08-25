# Three Trees Grow from $(3,4,5)$

## A classical shape, and a surprise hiding inside it

Every schoolchild meets $3^2 + 4^2 = 5^2$. Fewer people meet the strange and beautiful fact that *all* primitive Pythagorean triples — all the right triangles with whole-number sides and no common factor, $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(20,21,29)$, and infinitely many more — can be arranged into a single infinite family tree. Each triple has exactly three children. Nothing is repeated, nothing is missed, and the whole population descends from $(3,4,5)$.

This is not folklore; it is a theorem, and it has been known in various forms since the middle of the twentieth century. Two constructions became standard. One, due to Berggren, generates the children of a triple by three integer matrices whose determinants are $\pm 1$. Another, due to Price, uses three different matrices, all with determinant $\pm 2$. Two elegant machines, two different "gears."

The obvious question is whether there are others. Could there be a Pythagorean tree built from matrices with determinant $\pm 3$, or $\pm 7$? Could there be a fourth, fifth, hundredth tree that nobody noticed? The folklore answer — repeated often enough that it hardened into a conjecture — was: **no**. Berggren and Price, and nothing else; the "$\pm 2$ obstruction" was the only obstruction.

The folklore is *half* right. There is a hard obstruction, and it is even sharper than anyone stated: the determinant of any admissible generator is forced to be a **power of two**, never divisible by $3$, $5$, $7$, or any odd prime. But the classification claim is **false**. There is a third tree — a hybrid that mixes a determinant-$1$ branch from Berggren's machine with two determinant-$\pm 2$ branches. And once you know that, you can prove the complete story: **there are exactly three ternary Pythagorean trees, no more.**

This article tells that story.

## Euclid's coordinates

The first move is ancient. Euclid observed that if you take two integers $m > n \ge 1$ and form

$$(x, y, z) = (m^2 - n^2,\; 2mn,\; m^2 + n^2),$$

you get a Pythagorean triple, because $(m^2-n^2)^2 + (2mn)^2 = (m^2+n^2)^2$ identically. The triple is *primitive* — the legs share no common factor — precisely when $\gcd(m,n) = 1$ and $m+n$ is odd (one of $m,n$ even, the other odd). And every primitive triple, with the even leg written second, arises this way from exactly one such pair.

So the sprawling set of Pythagorean triples is really a disguised copy of a very clean set of lattice points, which we will call the **node set**:

$$\mathcal{N} \;=\; \{(m,n) \in \mathbb{Z}^2 \;:\; 1 \le n < m,\ \gcd(m,n) = 1,\ m+n \text{ odd}\}.$$

The first few nodes, ordered by $m$, are $(2,1)$, $(3,2)$, $(4,1)$, $(4,3)$, $(5,2)$, $(5,4)$, $(6,1)$, $(6,5)$, $(7,2)$, $(7,4)$, $(7,6)$, $(8,1)$, .... The node $(2,1)$ corresponds to $(3,4,5)$; it is our root. $(3,2)$ gives $(5,12,13)$; $(4,1)$ gives $(15,8,17)$; $(5,2)$ gives $(21,20,29)$.

Now the question sharpens into something purely about lattice geometry. A candidate "child rule" is an integer $2\times 2$ matrix $M = \begin{pmatrix} a & b \\ c & d\end{pmatrix}$ acting by

$$(m,n) \longmapsto (am + bn,\; cm + dn).$$

A **ternary Pythagorean tree** is a triple of such matrices $\{M_0, M_1, M_2\}$ such that: each $M_i$ maps nodes to nodes; none of them ever lands on the root; together they hit every non-root node; and no node is hit twice (not by two different branches, and not twice by the same branch). That is exactly the statement "$\mathcal{N}$ is the vertex set of a rooted ternary tree with root $(2,1)$, whose edges are the three maps."

The question is: which triples of matrices do this?

## Why odd primes are forbidden

Here is the heart of the obstruction, and it is a small miracle of two-line algebra.

Suppose $\gcd(m,n) = 1$, so there are integers $u,v$ with $um + vn = 1$. Write the image as $X = am+bn$, $Y = cm+dn$. Then a direct computation gives

$$\det M \;=\; (ud - vc)\,X \;+\; (va - ub)\,Y.$$

In words: **any common divisor of the two coordinates of the image must divide the determinant.** This one identity is the whole engine of the theory. If a map is going to send coprime pairs to coprime pairs, its determinant is the only thing standing in the way.

Now suppose some odd prime $p$ divides $\det M$. Can we build a node whose image is divisible by $p$ in *both* coordinates? If so, that image is not coprime, and $M$ is disqualified. It turns out we always can, and the construction depends only on which entries $p$ divides.

- If $p$ divides both $a$ and $c$ (the whole first column), take the node $(p+1, p)$ — consecutive integers, coprime, with odd sum $2p+1$. Its image is $\big(a(p+1) + bp,\ c(p+1) + dp\big)$, and every term is a multiple of $p$. Disqualified.
- Otherwise, say $p \nmid c$. Because $p$ is odd, we may choose an **even** $m \ge 2$ with $cm + d \equiv 0 \pmod p$ (solve the congruence, then slide by multiples of $2p$ to make the solution even and large). Take the node $(m,1)$, legitimate because $m$ is even and coprime to $1$. Its second coordinate is divisible by $p$ by construction, and from $c(am+b) = a(cm+d) - \det M$ we get $p \mid c(am+b)$; since $p \nmid c$, also $p \mid am + b$. Both coordinates divisible. Disqualified.
- The case $p \nmid a$ is symmetric.

Since $0$ is divisible by $3$, this argument also rules out $\det M = 0$. So:

> **The Power-of-Two Theorem.** If an integer linear map sends the Pythagorean node set into itself, then no odd prime divides its determinant. Consequently $\det M \neq 0$ and $|\det M|$ is a power of two: $1, 2, 4, 8, \ldots$

That is the "$\pm 2$ obstruction" in its true form — not a bound of $2$, but a $2$-adic constraint. Determinant $\pm 3$ generators do not exist, not because someone failed to find them, but because the coprimality of Pythagorean legs forbids them outright.

## Everything else is geometry and parity

The determinant condition is not quite the whole story, but the rest is elementary. A map must also respect the *shape* of $\mathcal{N}$:

- **Parity.** Feeding in the nodes $(2,1)$ and $(3,2)$ and demanding that the image coordinate sum be odd forces $a+c$ and $b+d$ both odd. Conversely, this parity guarantees $X+Y$ odd for every node, which incidentally rules out $2$ as a common divisor of the image.
- **Cone conditions.** The node set lives in the wedge $0 < n < m$. Demanding $Y \ge 1$ on all nodes forces $c \ge 0$, $c + d \ge 0$, $(c,d) \ne (0,0)$; demanding $Y < X$ applies the same three conditions to the difference row $(a-c,\ b-d)$. These are exactly the conditions for the linear form to be positive on the open wedge, and testing them on two families of nodes — the "even spike" $(m,1)$ with $m$ even and the "spine" $(m, m-1)$ — shows they are necessary as well as sufficient.

Putting the three ingredients together gives a complete and finitely checkable answer to "which matrices act on the Pythagorean node set":

> **Characterisation Theorem.** The map $(m,n) \mapsto (am+bn,\ cm+dn)$ sends the node set into itself if and only if $a+c$ and $b+d$ are odd, no odd prime divides $ad - bc$, and both rows $(c,d)$ and $(a-c,\, b-d)$ satisfy: first entry $\ge 0$, sum of entries $\ge 0$, and not both entries zero.

Sweeping through matrices with all entries at most $R$ in absolute value, this criterion returns $1, 8, 18, 39, 67, 93, 138, 197$ admissible maps for $R = 1,\dots,8$ — and the multiset of determinant magnitudes that appears is always a subset of $\{1,2,4,8,16,32,64\}$: only powers of two, exactly as predicted.

## Growth, and the child that is always there

Admissibility is a local condition on one matrix. Being a *tree* is a global condition on three. The bridge between them is a rigidity phenomenon: every admissible map is forced to expand.

Because $c \ge 0$ and $a \ge c$, and because the determinant cannot vanish, one shows $a \ge 1$; a slightly longer argument on the spine nodes gives $a + b \ge 1$. Together these mean the linear form $am+bn$ is minimised over the whole node set at the root: $am + bn \ge 2a + b$. And if the map is one of three branches of a tree, it cannot be the identity-like map with first row $(1,0)$ — that map is forced to be the identity itself, which would hit the root. Hence:

> **Growth Theorem.** Every branch of a ternary Pythagorean tree strictly increases $m$. So the tree is graded by the Euclid parameter $m$: children always sit deeper.

Two consequences follow immediately. First, since $(3,2)$ is the *only* node with $m = 3$, and its parent must have a strictly smaller $m$ — hence be the root — **$(3,2)$ is a child of the root in every ternary Pythagorean tree, via exactly one branch.** In the language of triangles: whatever machine you build, $(5,12,13)$ is always a child of $(3,4,5)$.

Second, running the argument downward gives a **Generation Theorem**: in any ternary Pythagorean tree, every node — and hence every primitive Pythagorean triple — is reached from $(3,4,5)$ by a finite word in the three branches. Descend by parents; $m$ strictly decreases; you must stop, and the only place to stop is the root.

## Pinning down the three trees

Now the classification becomes a forcing argument, and the finiteness comes from the fact that the small nodes are so few: the nodes with $m \le 5$ are exactly $(2,1), (3,2), (4,1), (4,3), (5,2), (5,4)$.

Start with the branch that produces $(3,2)$. Its matrix satisfies $2a+b = 3$, $2c+d = 2$. The cone conditions bound $0 \le c \le 2$; parity ties $a$ to $c+1$; and the determinant conditions kill the last case. Exactly two matrices survive:

$$A = \begin{pmatrix} 2 & -1 \\ 1 & 0\end{pmatrix} \quad (\det = 1), \qquad P_0 = \begin{pmatrix} 1 & 1 \\ 0 & 2\end{pmatrix} \quad (\det = 2).$$

$A$ sends $(m,n) \mapsto (2m-n, m)$: the first branch of Berggren's tree. $P_0$ sends $(m,n)\mapsto(m+n, 2n)$: the first branch of Price's tree. **Every ternary Pythagorean tree contains one of these two.**

From there, each branch's image is an explicit region, and the regions have to tile:

| matrix | rule | image region |
|---|---|---|
| $A = \begin{pmatrix}2&-1\\1&0\end{pmatrix}$ | $(2m-n,\,m)$ | $m < 2n$ |
| $B = \begin{pmatrix}2&1\\1&0\end{pmatrix}$ | $(2m+n,\,m)$ | $2n < m < 3n$ |
| $C = \begin{pmatrix}1&2\\0&1\end{pmatrix}$ | $(m+2n,\,n)$ | $3n < m$ |
| $P_0 = \begin{pmatrix}1&1\\0&2\end{pmatrix}$ | $(m+n,\,2n)$ | $n$ even |
| $P_1 = \begin{pmatrix}2&0\\1&-1\end{pmatrix}$ | $(2m,\,m-n)$ | $m$ even, $2n<m$ |
| $P_2 = \begin{pmatrix}2&0\\1&1\end{pmatrix}$ | $(2m,\,m+n)$ | $m$ even, $m<2n$ |
| $F_0 = \begin{pmatrix}1&3\\0&2\end{pmatrix}$ | $(m+3n,\,2n)$ | $n$ even, $2n<m$ |

If your tree contains $A$, the other two branches are confined to $m > 2n$ (the ray $m = 2n$ contains only the root). The node $(4,1)$ has to be covered by one of them, and growth pins its root-image to $(4,1)$ itself, giving $C$ or $P_1$. Choose $C$, and the last branch is squeezed into $2n < m < 3n$; the node $(5,2)$ forces its root-image, leaving three candidates, of which two always produce an even second coordinate and so can never reach $(8,3)$ — leaving $B$. That is **Berggren's tree**. Choose $P_1$ instead, and the last branch must always produce odd first coordinates; then $(5,2)$ and $(9,4)$ eliminate everything but $F_0$. That is the **mixed tree**.

If instead your tree contains $P_0$, its image is all nodes with $n$ even, so the other two branches only produce odd $n$. That immediately kills $C$ (which sends $(3,2)$ to $(7,2)$), forcing $P_1$; then $(4,3)$ pins the last branch, and an exotic candidate $\begin{pmatrix}3&-2\\2&-1\end{pmatrix}$ is killed because it sends $(3,2)$ to $(5,4)$, which has $n$ even. What is left is $P_2$: **Price's tree**.

> **Classification Theorem.** Up to relabelling the branches, there are exactly three ternary Pythagorean trees:
> - **Berggren:** $\{A, B, C\}$, determinants $1, -1, 1$;
> - **Price:** $\{P_0, P_1, P_2\}$, determinants $2, -2, 2$;
> - **Mixed:** $\{F_0, A, P_1\}$, determinants $2, 1, -2$.
>
> In particular every branch of every such tree has $|\det| \le 2$: **no branch of determinant $3$ or more exists.**

The conjecture, then, dies and is reborn. Its quantitative half — no big determinants — is true, and in fact upgraded to a $2$-adic statement. Its classification half — Berggren or Price — is false, because of the hybrid.

## Why the hybrid exists: a conservation law

Why should there be *three* and not two? The cleanest explanation is a budget.

For a branch $M$ with top row $(a,b)$, the nodes it produces with first coordinate at most $B$ are the lattice points of the triangle $\{0 < n < m,\ am + bn \le B\}$, whose area is $B^2 / \big(2a(a+b)\big)$. Dividing by the area $B^2/2$ of the full cone slice, the branch occupies a definite fraction of the node population:

$$\rho(M) \;=\; \frac{1}{a(a+b)}.$$

Since the three branches partition all the non-root nodes, their fractions must exactly exhaust the budget. And they do:

$$\text{Berggren: } \tfrac12 + \tfrac16 + \tfrac13 = 1, \qquad \text{Price: } \tfrac12 + \tfrac14 + \tfrac14 = 1, \qquad \text{Mixed: } \tfrac14 + \tfrac12 + \tfrac14 = 1.$$

> **Conservation Law.** For every ternary Pythagorean tree, $\rho(M_0) + \rho(M_1) + \rho(M_2) = 1$.

This is the real invariant. The determinant is *not*: the determinant magnitudes are $\{1,1,1\}$ for Berggren, $\{2,2,2\}$ for Price, and $\{1,2,2\}$ for the hybrid, so the sums are $3$, $6$ and $5$ — three different values, a clean fingerprint distinguishing the three trees, and never more than $6$.

The mixed tree exists precisely because the budget equation $1 = \frac14 + \frac12 + \frac14$ has a second realisation: you can pay the $\frac12$ with Berggren's ratio-splitting branch $A$ instead of Price's halving branch $P_0$, and cover the rest with two determinant-$2$ branches. Berggren's tree splits the cone by *ratio* ($m/n$ below $2$, between $2$ and $3$, above $3$). Price's tree splits it by *parity* (halving $n$, or halving $m$ with two signs). The hybrid does one of each: nodes with $m < 2n$ descend by a ratio rule; nodes with $m > 2n$ descend by a parity rule. Neither classical tree is more natural than the other, and nature does not mind mixing them.

## What it means for triangles

Translate back through Euclid's map and the classification becomes a statement about right triangles. Take the primitive triple $(x,y,z)$ with $y$ even. Then:

- Every primitive Pythagorean triple appears exactly once in each of the three trees, and each tree is rooted at $(3,4,5)$.
- $(5,12,13)$ is always the child of $(3,4,5)$ — in every possible tree, no matter which of the three you build.
- There are exactly three ways to organise all primitive right triangles into a ternary tree by integer linear rules on Euclid's parameters. Not one, not two, and not infinitely many.

Berggren's tree gives $(3,4,5)$ the children $(5,12,13)$, $(21,20,29)$, $(15,8,17)$; Price's tree gives it $(5,12,13)$, $(15,8,17)$, $(7,24,25)$; the mixed tree gives $(5,12,13)$, $(15,8,17)$, $(21,20,29)$. Same root, overlapping first generations, and then they diverge — three genuinely distinct combinatorial architectures on the same infinite set.

## The moral

Two things happened here. First, a folklore bound was replaced by a structural reason: determinants of Pythagorean-tree generators are powers of two, and that follows from a single Bézout identity plus the freedom to choose a well-chosen test node. Second, a folklore classification was found to be one tree short, and the correction turned out to be *provable in full*: exactly three, with a complete forcing argument that never needs an infinite search — the small nodes with $m \le 5$ do all the work.

There is a lesson in the failure too. Everyone assumed the determinant was the tree's invariant, because Berggren's is uniformly $\pm1$ and Price's uniformly $\pm2$. It is not. The real invariants are the $2$-adic constraint on each branch and the density budget that the three branches must exhaust between them. Once you look for solutions of the budget equation rather than for uniform determinants, the third tree is not an anomaly. It is the obvious extra solution that the wrong invariant hid.

And the same reframing points forward. For $k$ branches instead of three, the budget becomes $\sum_i 1/\big(a_i(a_i+b_i)\big) = 1$, a Diophantine equation whose solution count grows with $k$ — while the power-of-two constraint on determinants stays exactly where it is, arity-independent. The trees of $(3,4,5)$ are, in the end, an accounting problem in disguise.
