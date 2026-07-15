# Joining Symmetry: How Many Small Spheres Build a Larger One

A sphere can hide in a surprisingly small collection of points. The zero-dimensional sphere, written $S^0$, is only a pair of points. Its essential feature is not roundness but opposition: each point is paired with an antipode. Join two such pairs, and a circle appears. Join three, and the boundary of an octahedron appears—a two-dimensional sphere assembled from six vertices. Continue, and the same pattern climbs through every dimension.

This simple construction leads to a precise arithmetic law. Whenever symmetric spaces are joined, their dimensions do not merely add: one extra dimension appears at every join. For the octahedral models of spheres, that law is exact. For much more general spaces with a free twofold symmetry, it gives a constructive lower bound on a quantity called the co-index.

The result is a bridge between geometry and arithmetic. Complicated iterated joins can be understood by adding dimensions and counting join signs. The formula is short, but it packages a structural principle: symmetry certificates can be combined, and each combination produces one new degree of freedom.

## Symmetry without fixed points

A **free twofold symmetric space** is a space $K$ equipped with an involution $x\mapsto -x$ such that $-x\neq x$ for every point $x$. Applying the operation twice returns the original point. The familiar antipodal map on a sphere is the guiding example.

For each nonnegative integer $n$, consider the **octahedral $n$-sphere** $O_n$. It has vertices

$$
\{+e_0,-e_0,+e_1,-e_1,\ldots,+e_n,-e_n\},
$$

with $+e_i$ paired antipodally with $-e_i$. Geometrically, this is the boundary of the $(n+1)$-dimensional cross-polytope. Thus $O_0$ is two points, $O_1$ is a square-shaped circle, and $O_2$ is the boundary of the ordinary octahedron.

An **equivariant map** between free twofold symmetric spaces preserves antipodes: $f(-x)=-f(x)$. Such a map carries the source’s symmetry into the target rather than forgetting it.

The **co-index** of $K$, denoted $\operatorname{coind}(K)$, measures the largest octahedral sphere whose antipodal pattern can be mapped equivariantly into $K$:

$$
\operatorname{coind}(K)=\max\{n\ge 0: \text{there is an equivariant map }O_n\to K\}.
$$

In settings where a maximum requires qualification, the statements below may be read in terms of witnesses: the existence of $O_n\to K$ certifies co-index at least $n$. For the finite octahedral spaces considered here, the maximum is exact. In particular,

$$
\operatorname{coind}(O_n)=n.
$$

The co-index is not just a dimension label. It records how much antipodal structure a space can receive. This makes it useful wherever opposition, sign changes, or binary symmetry constrain a construction.

## The join: geometry’s mixing operation

The **join** $K*L$ blends two spaces by adding a mixing coordinate. A point of the join may be pictured as a weighted expression

$$
(1-t)x+ty,
$$

where $x\in K$, $y\in L$, and $0\le t\le 1$. At $t=0$ only $x$ matters; at $t=1$ only $y$ matters; between them, the point records both ingredients and their mixing weight. If both spaces carry antipodal symmetries, the join inherits one by sending both $x$ and $y$ to their antipodes.

The extra parameter $t$ explains the recurring $+1$ in dimension formulas. The join of an $m$-sphere and an $n$-sphere is an $(m+n+1)$-sphere. For octahedral models, this statement is not merely a resemblance: there is an antipode-preserving bijection of the relevant combinatorial structures,

$$
O_m*O_n\cong O_{m+n+1}.
$$

This is the key structural theorem. Once it is known, a whole family of formulas follows through elementary arithmetic rather than a fresh topological obstruction argument at every stage.

Why is the theorem plausible? The first sphere contributes $m+1$ antipodal coordinate pairs and the second contributes $n+1$. Their join keeps all these pairs, giving $(m+1)+(n+1)=m+n+2$ pairs. An octahedral sphere with that many pairs has dimension $m+n+1$. The antipodal action remains coordinatewise sign reversal, so the identification respects symmetry.

## The many-factor law

Take sphere dimensions $d_0,d_1,\ldots,d_{p-1}$, with $p\ge 1$, and join the corresponding octahedral spheres. Repeated application of the two-factor identification yields the **Finite Multi-Join Theorem**:

$$
O_{d_0}*O_{d_1}*\cdots*O_{d_{p-1}}
\cong
O_{d_0+d_1+\cdots+d_{p-1}+p-1}.
$$

Consequently, the co-index is

$$
\operatorname{coind}(O_{d_0}*\cdots*O_{d_{p-1}})
=
\sum_{i=0}^{p-1}d_i+p-1.
$$

There are $p-1$ join operations, and each contributes one dimension. This is the entire accounting principle.

For example, joining spheres of dimensions $2$, $0$, $3$, and $1$ produces an octahedral sphere of dimension

$$
2+0+3+1+(4-1)=9.
$$

The co-index is therefore $9$.

The formula also proves **permutation invariance**: rearranging the factors changes neither their dimension sum nor their number. Thus every ordering of $O_2$, $O_0$, $O_3$, and $O_1$ has the same co-index. More strongly, each ordering is identified with the same octahedral $9$-sphere. Parentheses may affect the literal presentation of an iterated join, but not this invariant or its octahedral type.

## Suspension as repeated joining with two points

Joining any space with $S^0$ is the suspension operation: it stretches the space between two new poles. Because $S^0=O_0$, the multi-join theorem immediately recovers an entire suspension tower.

The **Suspension Tower Corollary** states that joining $O_n$ with $k$ copies of $O_0$ gives an octahedral sphere of co-index $n+k$:

$$
\operatorname{coind}(O_n*\underbrace{O_0*\cdots*O_0}_{k\text{ copies}})=n+k.
$$

Every new pair of poles raises the co-index by exactly one. Starting with two points, one obtains

$$
S^0*S^0\cong S^1,
$$

then

$$
S^0*S^0*S^0\cong S^2,
$$

and after $p$ copies,

$$
\underbrace{S^0*\cdots*S^0}_{p\text{ copies}}\cong S^{p-1}.
$$

This gives a vivid construction of high-dimensional spheres: a sphere can be built from nothing but repeated binary choices, provided each new choice is joined to all the previous ones.

## A constructive bound beyond spheres

The octahedral identities are exact, but the mechanism applies more broadly. Suppose an arbitrary free twofold symmetric space $K$ admits an equivariant map

$$
O_a\longrightarrow K.
$$

This map is a certificate that $K$ contains at least $a$ levels of octahedral symmetry. Form the $p$-fold self-join

$$
K^{*p}=\underbrace{K*\cdots*K}_{p\text{ factors}}.
$$

Joining $p$ copies of the original map gives an equivariant map from the join of $p$ copies of $O_a$ into $K^{*p}$. The source is itself an octahedral sphere:

$$
\underbrace{O_a*\cdots*O_a}_{p\text{ factors}}
\cong O_{p(a+1)-1}.
$$

This proves the **Constructive Self-Join Lower Bound**:

$$
\operatorname{coind}(K^{*p})\ge p(a+1)-1.
$$

The word “constructive” matters. The result does not infer the bound only from abstract numerical inequalities. It explicitly assembles the new witness by joining copies of the old one. A certificate for one factor becomes a certificate for every iterated self-join.

The growth is best understood after shifting by one:

$$
\operatorname{coind}(K^{*p})+1\ge p(a+1).
$$

The shifted quantity $a+1$ behaves multiplicatively with the number of repeated factors. This is why the formula looks like $p(a+1)-1$ rather than simply $pa$.

## Sharpness on the octahedral tower

When $K=O_a$, the lower bound is exact. The **Sharp Self-Join Theorem** states

$$
\operatorname{coind}(O_a^{*p})=p(a+1)-1.
$$

The proof is structural. Repeated joins identify $O_a^{*p}$ with $O_{p(a+1)-1}$, and an octahedral $q$-sphere has co-index exactly $q$. No gap remains between the constructed lower bound and the true value.

Take $a=2$ and $p=4$. Four copies of the octahedral $2$-sphere join to an octahedral sphere of dimension

$$
4(2+1)-1=11.
$$

Take $a=0$. Then the same theorem becomes

$$
\operatorname{coind}(O_0^{*p})=p-1,
$$

which is precisely the classical construction of $S^{p-1}$ from $p$ copies of $S^0$.

## Why the arithmetic is useful

Join constructions appear in equivariant topology, combinatorics, and topological methods for discrete problems. In these areas, one often turns a combinatorial configuration into a symmetric space and then studies which equivariant maps can exist. The co-index acts as a compact obstruction-bearing summary of that symmetry.

The multi-join law makes such summaries scalable. A large object assembled from known symmetric components no longer requires a dimension analysis from scratch. For octahedral factors, add the dimensions and add one per join. For an arbitrary repeated factor, join its symmetry witness repeatedly to obtain a guaranteed lower bound.

There is also an algorithmic lesson. If the input is a list of dimensions, the exact co-index requires only their sum and the list length. It can be computed in one pass, using constant extra memory. If all factors have the same dimension, the closed formula $p(a+1)-1$ gives the answer immediately. The topology determines the rule; arithmetic carries it out.

The same bookkeeping can help explain why joins occur in applications. A join records not only a choice inside one component or another, but a continuous degree of commitment between them. In configuration problems, this mixing parameter can encode how two families of solutions are blended. In combinatorial topology, disjoint blocks of signed vertices can be assembled without losing their antipodal pairing. The extra dimension is therefore not an arbitrary correction term: it is the geometric trace of the freedom to move between factors.

## One idea, many consequences

The heart of the theory can be said in a sentence: octahedral spheres are closed under joins, with dimensions combining by $m+n+1$. From this one fact flow the finite multi-join formula, invariance under reordering, the suspension tower, the constructive lower bound for arbitrary self-joins, and exactness for repeated octahedral spheres.

What looks at first like a collection of separate sphere identities is really a calculus of reusable symmetry. Every factor contributes its own antipodal coordinate pairs. Every join adds a mixing direction. Once those contributions are counted correctly, a tower of topological constructions resolves into a clean numerical pattern:

$$
\text{total co-index}=\text{sum of factor dimensions}+\text{number of joins}.
$$

That pattern is both geometrically intuitive and mathematically exact—a compact law for building higher symmetry from lower symmetry.