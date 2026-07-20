# The Fractal Dimension of Mathematical Truth

## A small universe where truth has a shape

Imagine receiving an endless sequence of yes-or-no answers. Each answer might settle a proposition, flip a switch, record whether an event occurred, or mark whether a claim belongs to a theory. Written as zeros and ones, the sequence begins

$$
0,1,0,0,1,0,\ldots
$$

The collection of all such infinite sequences is called **Cantor space**. It is an enormous binary tree: at every step, each finite history can branch to either $0$ or $1$. Two sequences are considered close when they agree for a long initial stretch. Thus distance is not geographical but informational. If the first disagreement occurs late, the sequences are near; if it occurs immediately, they are far apart.

This setting lets us ask a geometric question about a language of permitted truth patterns. Suppose that a positive answer must always be followed by a negative one. In binary notation, the block $11$ is forbidden. The sequences

$$
010010100\ldots \qquad\text{and}\qquad 101010000\ldots
$$

are allowed, while any sequence containing two consecutive ones is not. This simple rule defines the **golden-mean truth language**. It is not a model of all mathematical truth. It is a precise surrogate: a controlled world in which local consistency restricts possible truth-value streams, and in which the size and geometry of the surviving set can be determined exactly.

The result is a clean form of fractality. The allowed set is far smaller than the full binary universe, but it does not collapse to a finite or thin collection. Its dimension is

$$
\frac{\log \varphi}{\log 2},
\qquad
\varphi=\frac{1+\sqrt5}{2},
$$

which lies strictly between $0$ and $1$. The golden ratio appears because admissible histories grow according to the Fibonacci sequence.

## Counting the branches that survive

Let $W_n$ be the set of binary words of length $n$ containing no occurrence of $11$. These finite words are the visible prefixes, or **cylinders**, of the infinite allowed streams. At depth $n$, the full binary tree has $2^n$ cylinders. How many remain after the local rule is imposed?

There are two ways an admissible word can begin. It may begin with $0$, followed by any admissible word of length $n-1$. Or it may begin with $10$, followed by any admissible word of length $n-2$. The two cases cannot overlap because their first symbols differ. Consequently,

$$
|W_n|=|W_{n-1}|+|W_{n-2}|.
$$

The initial counts are $|W_0|=1$ and $|W_1|=2$. These are precisely the initial conditions that shift the Fibonacci sequence by two places. If $F_0=0$, $F_1=1$, and $F_{m+2}=F_{m+1}+F_m$, then the **Exact Cylinder Count Theorem** states

$$
|W_n|=F_{n+2}
$$

for every $n\ge 0$.

The first few levels contain

$$
1,2,3,5,8,13,21,34,\ldots
$$

admissible words. At length $4$, for example, the eight survivors are

$$
0000,\ 0001,\ 0010,\ 0100,\ 0101,\ 1000,\ 1001,\ 1010.
$$

This is more than a numerical coincidence. It identifies the branching mechanism. The golden ratio is the exponential growth rate of Fibonacci numbers, so it becomes the scale factor governing the geometry of this constrained binary world.

## Every finite glimpse belongs to a complete world

A finite pattern would be less meaningful if it could pass the local test but fail to extend indefinitely. Here that never happens. The **Extension Theorem** says that every word in $W_n$ is the initial segment of an infinite binary stream with no consecutive ones.

The reason is constructive. Once an admissible finite word has been chosen, append zeros forever. No new pair $11$ can arise inside the original word, at its boundary with the tail, or within the all-zero tail. Thus every counted cylinder is genuinely inhabited. The Fibonacci count is therefore not counting dead ends; it counts actual neighborhoods in the infinite space.

Prefix agreement supplies those neighborhoods. Say that two streams agree to depth $n$ when their first $n$ entries match. Agreement to depth $n$ is reflexive, symmetric, and transitive. It is also nested: agreement to a deeper level implies agreement at every shallower level. These elementary facts are the combinatorial skeleton of the usual Cantor ultrametric, where a common prefix of length $n$ corresponds to a scale comparable to $2^{-n}$.

## Sparse, but not negligible

The full binary tree offers $2^n$ words at depth $n$. Because the block $11$ is forbidden, the admissible language is genuinely smaller. For every $n\ge2$, the **Strict Sparsity Theorem** gives

$$
|W_n|<2^n.
$$

Yet the language remains exponentially rich. The **Exponential Lower Bound Theorem** states

$$
2^{\lfloor n/2\rfloor}\le |W_n|.
$$

One way to see the lower bound is to divide positions into pairs and independently choose each pair to be either $00$ or $10$. Every resulting word avoids $11$, producing at least $2^{\lfloor n/2\rfloor}$ possibilities, with a harmless extra zero when the length is odd.

Together, for every $n\ge2$,

$$
2^{\lfloor n/2\rfloor}\le |W_n|<2^n.
$$

This inequality captures the phrase “sparse but not negligible.” Polynomially many survivors would have dimension zero. Almost all binary words surviving would suggest full dimension one. Instead, the count grows exponentially at a rate strictly between those extremes.

There is also a quantitative contraction law. Let

$$
d_n=\frac{|W_n|}{2^n}
$$

be the fraction of all depth-$n$ words that are admissible. Then the **Two-Step Density Contraction Theorem** implies

$$
d_{n+2}\le \frac34 d_n.
$$

Indeed, its integer form is

$$
2^n|W_{n+2}|\le 3\cdot 2^n|W_n|,
$$

and division by $2^{2n+2}$ yields the density statement. Every two levels remove at least a fixed fraction of the remaining relative mass. Iterating the estimate shows that $d_n$ tends to zero exponentially. The language is large in absolute terms, yet vanishingly rare among all binary strings.

That contrast has familiar real-world analogues. Error-correcting codes retain exponentially many messages while occupying a tiny fraction of all strings. Constrained storage systems forbid patterns that are physically unreliable while preserving a positive information rate. Symbolic models of dynamical systems eliminate impossible trajectories but retain a complicated invariant set. In each case, “rare” and “information-rich” coexist.

## Turning growth into dimension

At depth $n$, a cylinder has scale $2^{-n}$. If a set needs approximately $N_n$ such cylinders for a cover, its box dimension is measured by the ratio

$$
\frac{\log N_n}{\log 2^n}.
$$

Here $N_n=|W_n|=F_{n+2}$. Fibonacci numbers grow like a constant multiple of $\varphi^n$, so

$$
\log F_{n+2}=n\log\varphi+O(1).
$$

Dividing by $n\log2$ gives the dimension parameter

$$
D=\frac{\log\varphi}{\log2}\approx 0.6942419136.
$$

The **Intermediate Dimension Theorem** states

$$
0<D<1.
$$

This follows directly from $1<\varphi<2$ and the strict increase of the logarithm. The dimension is positive because branching never becomes merely polynomial; it is below one because the local prohibition permanently reduces the exponential growth rate.

A dimension near $0.694$ has an intuitive information-theoretic meaning. An unconstrained binary symbol carries one bit per position. In the golden-mean language, the asymptotic information capacity per position is

$$
\log_2\varphi=\frac{\log\varphi}{\log2}.
$$

Geometry and information coincide: the fractal dimension is the number of freely sustainable bits per symbol.

## What this model says—and what it does not

The phrase “dimension of truth” is deliberately evocative, but precision matters. In this model, a statement is represented only by a bit, and consistency means only that two positive answers may not be adjacent. The dimension is computable, and the language is decidable by a simple scan. Nothing here establishes that the totality of mathematical truth has this dimension, nor does the argument imply an uncomputability theorem.

A genuine theory of theoremhood would first require an explicit encoding of formulas, a specified deductive theory, and a decision about how the bits are ordered. A connection with Chaitin’s halting probability would require still more: a prefix-free machine, its halting domain, finite approximations to its probability, and proofs about convergence and algorithmic randomness. Without those choices, claims about uncomputability are not mathematically determined.

The value of the golden-mean model is different. It isolates a transparent mechanism by which local logical-looking restrictions create global fractal geometry. A one-step prohibition produces Fibonacci recurrence; Fibonacci recurrence produces golden-ratio growth; golden-ratio growth produces an intermediate dimension. Every link is visible.

There is also a lesson about scale. Looking only at a few levels can be deceptive: the set still appears crowded, and many branches remain. Dimension asks what persists as the microscope zooms indefinitely. At every new depth, the same local rule acts again. Its small exclusions accumulate into a stable exponential signature. The number $D$ records that signature without reducing the set to a crude label such as finite or infinite. Two infinite sets may differ dramatically in how quickly their distinguishable possibilities multiply, and fractal dimension measures precisely that difference.

The same pipeline extends far beyond the forbidden block $11$. Forbid any finite collection of blocks, record which short suffixes may follow which others, and the system becomes a finite directed graph. Paths in that graph count admissible words. The leading growth rate is governed by the graph’s adjacency matrix, and the expected dimension is the logarithm of its spectral radius divided by $\log2$.

That broader principle is the enduring idea: rules carve geometry out of information. Even the simplest local constraint can turn the featureless binary continuum into a patterned set—thin enough to be rare, rich enough to branch forever, and precise enough for its dimension to be written in the language of the golden ratio.
