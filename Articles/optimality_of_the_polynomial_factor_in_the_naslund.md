# The Sunflower That Refused to Bloom

## A puzzle about collections of sets

Imagine you are handing out committees. There are $n$ people, numbered $1$ through $n$, and each committee is just a subset of these people. You want to assemble a huge collection of committees — but with one rule designed to avoid a particular kind of favoritism.

The forbidden pattern is called a **sunflower**. Three distinct committees $A$, $B$, and $C$ form a sunflower if all three of their pairwise overlaps are identical:
$$A \cap B \;=\; A \cap C \;=\; B \cap C.$$
That common overlap is the *core* of the sunflower, and the three leftover pieces $A\setminus\text{core}$, $B\setminus\text{core}$, $C\setminus\text{core}$ are the *petals* — pairwise disjoint, splaying out from a shared center like the petals of a flower. A collection of committees is **sunflower-free** if it contains no such triple.

Here is the question that has fascinated combinatorialists since Erdős and Szemerédi raised it in the 1970s:

> **How large can a sunflower-free collection of subsets of an $n$-element set be?**

There are $2^n$ subsets in total. The trivial worry is that a sunflower-free collection might have to contain almost all of them — that avoiding sunflowers costs you almost nothing. Erdős and Szemerédi conjectured the opposite: that you must throw away an *exponential* fraction, so that the largest sunflower-free collection has size at most $c^n$ for some constant $c$ strictly smaller than $2$.

For four decades this remained open. Then, in a burst of activity following the 2016 resolution of the cap-set problem, Eric Naslund and Will Sawin cracked it with a startlingly short argument. The magic constant they found is
$$\frac{3}{2^{2/3}} \;\approx\; 1.8899,$$
comfortably below $2$. This article tells the story of how three unrelated-looking ideas — a notion of "rank" for three-dimensional arrays, a clever polynomial over arithmetic modulo $3$, and a counting estimate about the middle of Pascal's triangle — snap together to prove it, and where the last mystery still lies.

## Idea one: how "complicated" is a three-dimensional array?

We are used to the rank of a matrix: the smallest number of rank-one pieces $g(x)\,h(y)$ whose sum reconstructs the matrix. Rank is powerful because it is *rigid*: a matrix that is nonzero only on its diagonal has rank exactly equal to the number of nonzero diagonal entries — you cannot fake a diagonal cheaply.

Now go up one dimension. Consider a three-dimensional array, a **tensor** $T(x,y,z)$. What is its "rank"? The naive analogue would count pieces of the form $g(x)\,h(y)\,k(z)$, but that notion behaves badly. The fix, crystallized by Terence Tao in 2016, is the **slice rank**. A *slice* is a tensor that is simple in *one* of its three directions:
$$g(x)\,h(y,z), \qquad g(y)\,h(x,z), \qquad \text{or}\qquad g(z)\,h(x,y).$$
Each slice is "flat" along one axis and arbitrary in the plane spanned by the other two. The **slice rank** of $T$ is the least number of slices that sum to $T$.

The one fact we need is the exact analogue of the matrix diagonal fact, and it is the linchpin of the whole method:

> **The Slice Rank Lemma (Tao).** A *diagonal tensor* — one that equals some value $c_x$ when $x=y=z$ and is zero otherwise — has slice rank exactly equal to the number of nonzero diagonal entries.

In other words, a diagonal tensor supported on a set $S$ cannot be written as fewer than $|S|$ slices. This is the three-dimensional rigidity that will let us *count* committees, once we manage to encode our collection as a diagonal tensor.

## Idea two: a polynomial that detects sunflowers

Here is the inspired move. We work over the arithmetic of the integers modulo $3$, the three-element field $\{0,1,2\}$ where $3=0$. For a committee $A$ and a person $i$, write $a_i = 1$ if $i \in A$ and $a_i = 0$ otherwise — the membership indicator. Given three committees $A,B,C$, look at a single person $i$ and form the little expression
$$1 - \bigl(a_i b_i + b_i c_i + c_i a_i\bigr).$$
Because each of $a_i, b_i, c_i$ is $0$ or $1$, the sum $a_ib_i+b_ic_i+c_ia_i$ simply *counts the number of pairs among $A,B,C$ that all contain $i$*. Run through the cases:

- Person $i$ is in **none or exactly one** of the committees: no pair contains $i$, the count is $0$, and the expression is $1-0 = 1$.
- Person $i$ is in **exactly two** committees: exactly one pair contains $i$, the count is $1$, and the expression is $1-1 = 0$.
- Person $i$ is in **all three** committees: all three pairs contain $i$, the count is $3$, and — this is the punchline — $3 = 0$ modulo $3$, so the expression is again $1-0 = 1$.

So this per-person factor is $0$ **exactly when person $i$ belongs to precisely two of the three committees**, and $1$ in every other case. Multiply the factors over all $n$ people to get a single number attached to the triple:
$$T(A,B,C) \;=\; \prod_{i=1}^{n}\Bigl(1 - (a_i b_i + b_i c_i + c_i a_i)\Bigr).$$
This product is $1$ precisely when **no** person lies in exactly two of the committees, and $0$ as soon as even one person does.

Now recall what a sunflower is. Three distinct committees $A,B,C$ form a sunflower exactly when every person is in none, one, or all three of them — never in *exactly two*. (A person in exactly two would sit in one pairwise overlap but not another, wrecking the equal-overlaps condition.) Therefore:

$$T(A,B,C) = 1 \iff \{A,B,C\}\text{ has no element in exactly two of them.}$$

On the diagonal — when $A=B=C$ — every person is in all three or none, so $T(A,A,A)=1$ always. And if our collection is sunflower-free and *uniform* (all committees the same size, which forces that no committee contains another), then for any three *distinct* committees the pattern that would give $T=1$ is exactly the forbidden sunflower pattern, so $T=0$ off the diagonal.

The result is breathtakingly clean. Restricted to a uniform, sunflower-free collection $\mathcal F$, the tensor $T$ is **$1$ on the diagonal and $0$ everywhere else** — it is a diagonal tensor whose support is all of $\mathcal F$.

## Idea three: the polynomial is secretly low-rank

We have built a diagonal tensor supported on $\mathcal F$. By the Slice Rank Lemma, its slice rank is exactly $|\mathcal F|$. If we can independently show that this particular tensor cannot have large slice rank, we get an upper bound on $|\mathcal F|$ for free.

This is where the polynomial structure pays off, through an argument of Croot, Lev, and Pach. The tensor $T(A,B,C)$ is a polynomial of modest degree in the membership variables. Each of the $n$ factors contributes total degree $2$, and here is the key pigeonhole: when you expand the product into monomials, each monomial spreads its degree across the three blocks of variables (the $a$'s, the $b$'s, and the $c$'s), and **at least one block must carry only a small share** of the degree. Grouping the monomials according to which block is the "cheap" one lets you rewrite the whole tensor as a sum of slices — one slice for each low-degree monomial in the cheap block. Counting those monomials gives the bound.

Concretely, the slice rank of $T$ is at most $3\,M(n)$, where $M(n)$ is the number of subsets of $\{1,\dots,n\}$ of size at most $n/3$:
$$M(n) \;=\; \sum_{k=0}^{\lfloor n/3\rfloor}\binom{n}{k}.$$

## The constant emerges from Pascal's triangle

Now the two bounds collide. For a uniform sunflower-free collection,
$$|\mathcal F| \;=\; \text{slice rank of } T \;\le\; 3\,M(n).$$
And a general sunflower-free collection splits into $n+1$ uniform layers (one for each possible committee size), each of which is sunflower-free, so
$$|\mathcal F| \;\le\; (n+1)\cdot 3\,M(n).$$

All that remains is to estimate $M(n)$, a sum running up the first third of a row of Pascal's triangle. Here the *binary entropy function* $H(p) = -p\log_2 p - (1-p)\log_2(1-p)$ makes its entrance. A classical estimate says the partial binomial sum up to $\alpha n$ (for $\alpha<\tfrac12$) grows like $2^{nH(\alpha)}$, tempered by a $1/\sqrt{n}$ factor. At $\alpha = 1/3$:
$$M(n) \;=\; \Theta\!\left(\frac{1}{\sqrt n}\,2^{n H(1/3)}\right),\qquad H(1/3) = \log_2 3 - \tfrac{2}{3} \approx 0.9183.$$
And $2^{H(1/3)}$ is precisely our magic constant:
$$2^{H(1/3)} = 2^{\log_2 3 - 2/3} = \frac{3}{2^{2/3}} \approx 1.8899.$$
It has a pleasing algebraic signature too: its cube is exactly $\bigl(3/2^{2/3}\bigr)^3 = 27/4$.

Putting the pieces together, the size of any sunflower-free collection is at most
$$K \cdot \sqrt{n} \cdot \left(\frac{3}{2^{2/3}}\right)^{n}$$
for an absolute constant $K$ — an exponential base safely below $2$, settling the Erdős–Szemerédi conjecture. The whole edifice rests on three short observations: diagonal tensors are rank-rigid, a mod-$3$ polynomial detects the sunflower pattern one person at a time, and the middle third of Pascal's triangle weighs in at entropy $H(1/3)$.

## The last mystery: how big is the polynomial fudge factor?

The exponential base $3/2^{2/3}$ is now understood down to the last decimal — algebraically (its cube is $27/4$) and information-theoretically (it is $2^{H(1/3)}$). But the argument above carries an extra $\sqrt{n}$: it came from bundling together the $n+1$ size-layers, each contributing its own factor. Is that polynomial overhead real, or an artifact of the proof?

The evidence suggests it is far too generous. The sharpest conjecture on the table pins the true polynomial factor much lower:

> **Conjecture (optimality of the polynomial factor).** There is an absolute constant $K>0$ such that every sunflower-free collection of subsets of an $n$-element set has size at most
> $$K \cdot n^{1/6} \cdot \left(\frac{3}{2^{2/3}}\right)^{n}.$$

The exponent $1/6$ is a bold, falsifiable prediction. Why $1/6$ and not $1/2$? The intuition is that an extremal sunflower-free family is nearly a union of *inclusion chains* — nested towers of committees — and each such chain, being automatically sunflower-free, can hold only $n+1$ sets. The real question becomes: how few chains does it take to cover an extremal family? Those covers are cheapest precisely on the middle-third layer, the layer near size $n/3$ where the constant $3/2^{2/3} = 2^{H(1/3)}$ was born. The polynomial gap between the crude count and the true ceiling is, on this view, a single measurable combinatorial parameter — and the conjecture bets it equals $n^{1/6}$.

## Why any of this matters

Sunflowers are not a curiosity. The sunflower lemma — that a large enough family *must* contain a sunflower — is a workhorse across theoretical computer science, from circuit lower bounds to the analysis of data structures and fixed-parameter algorithms. Knowing exactly how large a family can grow *while avoiding* sunflowers calibrates every one of those applications. And the technique — encode a forbidden combinatorial pattern as a diagonal tensor, then squeeze it between the Slice Rank Lemma and a polynomial degree count — has become one of the sharpest instruments in modern combinatorics, the same blade that felled the cap-set problem. The sunflower that refused to bloom turns out to teach us how to count almost anything that hides a hidden diagonal.
