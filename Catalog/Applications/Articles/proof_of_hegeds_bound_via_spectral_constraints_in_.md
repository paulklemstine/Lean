# When Geometry Counts: How a Single Eigenvalue Tames Infinite Families of Sets

## A puzzle about overlaps

Imagine you are designing a tournament, a code, or a network, and you have a fixed pool of $n$ resources — call them the numbers $1, 2, \dots, n$. You want to build a large collection of *teams*, where each team is a subset of those $n$ resources. There is one rule: every team must be the same size $k$, and every two distinct teams must share **exactly** the same number of common members, say $\lambda$.

This is the world of *balanced designs*. It shows up everywhere: in the schedules of round-robin tournaments, in the structure of error-correcting codes, in statistical experiments where you want every pair of treatments to be compared equally often, and in the combinatorics of finite geometries.

The natural question is: **how many teams can you possibly build?**

You might guess that with enough cleverness you could pack in an enormous number — surely the answer grows quickly with $n$, perhaps exponentially? After all, there are $\binom{n}{k}$ possible teams of size $k$, an astronomically large number.

The surprising answer is no. If $\lambda < k$ — that is, if two teams never overlap *completely* — then you can build **at most $n$ teams**. Not $n^2$, not $2^n$, just $n$. The number of teams can never exceed the number of resources you started with.

This is a version of a classical gem of combinatorics known as the **Fisher inequality**, with deep cousins in the work of Frankl, Wilson, and Hegedűs. What is remarkable is not just the bound itself, but *why* it is true. The reason has nothing to do with cleverly counting subsets. It comes from an entirely different part of mathematics: **the geometry of vectors and the eigenvalues of a matrix.**

This article tells the story of that bridge — how a question about overlapping sets becomes a question about whether a certain matrix is "positive definite," and how a single eigenvalue inequality slams the door on any family larger than $n$.

## From sets to vectors: the dictionary

The first move is to stop thinking of a team as a list of members and start thinking of it as a **point in space**.

Suppose our ground set is $\{1, 2, \dots, n\}$. To each team $A$ we attach a vector $v_A$ living in $n$-dimensional space $\mathbb{R}^n$. The recipe is simple: the $t$-th coordinate of $v_A$ is $1$ if resource $t$ belongs to team $A$, and $0$ otherwise. This is the **incidence vector** (or indicator vector) of the set:

$$v_A(t) = \begin{cases} 1 & t \in A \\ 0 & t \notin A. \end{cases}$$

For example, with $n = 4$, the team $\{1, 3\}$ becomes the vector $(1, 0, 1, 0)$.

Now comes the magic. In geometry, the most important operation between two vectors is the **dot product** (or inner product), which multiplies matching coordinates and adds them up. What is the dot product of two incidence vectors $v_A$ and $v_B$? A coordinate contributes $1 \times 1 = 1$ exactly when resource $t$ is in **both** $A$ and $B$, and contributes nothing otherwise. So the dot product simply *counts the shared members*:

$$\langle v_A, v_B \rangle = |A \cap B|.$$

This is the heart of the whole story — the single sentence that translates combinatorics into geometry. In the formal development this fact is captured by a theorem named `incidence_inner`, which proves that the inner product of two incidence vectors equals the size of the intersection of the underlying sets. Its special case for a set with itself, `incidence_inner_self`, says

$$\langle v_A, v_A \rangle = |A|,$$

because a set shares all of its own members with itself. The length-squared of a team's vector is just its size.

With this dictionary in hand, our combinatorial rules become geometric statements:

- "Every team has size $k$" becomes "every vector $v_A$ has squared length $k$."
- "Every two distinct teams share $\lambda$ members" becomes "every two distinct vectors have dot product $\lambda$."

We have turned a family of sets into a configuration of vectors, all of the same length, all making the same angle with each other. The family is, geometrically, a kind of perfectly symmetric crystal of arrows.

## The Gram matrix: a portrait of the whole family

To analyze all these vectors at once, mathematicians assemble their pairwise dot products into a grid called the **Gram matrix**. If we have $m$ teams $A_1, \dots, A_m$, the Gram matrix $G$ is the $m \times m$ table whose entry in row $i$, column $j$ is $\langle v_{A_i}, v_{A_j}\rangle$.

Under our rules, this matrix has an exquisitely simple shape. Every diagonal entry (a team with itself) equals $k$. Every off-diagonal entry (two different teams) equals $\lambda$. In symbols,

$$G = (k - \lambda)\, I + \lambda\, J,$$

where $I$ is the identity matrix (ones on the diagonal, zeros elsewhere) and $J$ is the all-ones matrix (every entry equal to $1$). This is the **constant-pattern matrix**: a uniform background of $\lambda$ everywhere, with an extra boost of $k - \lambda$ along the diagonal.

Now we can state the crucial geometric fact, the engine of the entire argument. It concerns a property of matrices called **positive definiteness**. A symmetric matrix is *positive definite* if, intuitively, it represents a genuine, non-degenerate notion of distance and angle — equivalently, if all of its eigenvalues are strictly positive. The Gram matrix above has exactly this property whenever $0 \le \lambda < k$:

> **The constant-pattern positive-definiteness theorem.** For real numbers with $0 \le \lambda < k$, the matrix $(k-\lambda) I + \lambda J$ is positive definite.

Why is this true, and why does it matter? The all-ones matrix $J$ is *positive semidefinite* — it never contributes anything negative, because for any vector $x$, the quantity $x^{\top} J x = \left(\sum_i x_i\right)^2$ is a square and hence $\ge 0$. Meanwhile, the term $(k - \lambda) I$ is strictly positive definite as long as $k - \lambda > 0$, i.e. as long as $\lambda < k$. The sum of a strictly positive part and a never-negative part is strictly positive. No diagonalization, no eigenvector gymnastics — just the observation that *positive plus non-negative stays positive*. This is the elegant "additive split" at the core of the proof.

## Why positive definiteness forces the bound

Here is the punchline, the step where geometry pays off. A foundational theorem of linear algebra says:

> **A Gram matrix is positive definite if and only if the vectors it came from are linearly independent.**

*Linearly independent* means no vector in the collection can be written as a combination of the others; they all point in genuinely different directions. And there is a hard ceiling on how many linearly independent vectors can coexist in $n$-dimensional space: **at most $n$ of them.** You cannot fit five independent directions into a three-dimensional room.

Chain these facts together and the theorem falls out:

1. Our family of teams gives vectors whose Gram matrix is $(k - \lambda) I + \lambda J$.
2. Because $\lambda < k$, that matrix is positive definite.
3. Positive definiteness means the vectors are linearly independent.
4. Independent vectors in $\mathbb{R}^n$ number at most $n$.
5. Therefore the number of teams $m$ is at most $n$.

This is exactly the content of the formal theorem `indexed_fisher_card_le`: an indexed family of $m$ subsets of an $n$-element ground set, each of size $k$, with all pairwise distinct intersections of size $\lambda < k$, must satisfy $m \le n$. A companion result, `isUniform_fisher_card_le`, states the same conclusion for an *unindexed* collection of sets — a `Finset` family — by quietly enumerating its members and feeding them into the indexed version. The bound holds whether you think of your designs as a numbered list or as an abstract set of sets.

What is striking is how the entire combinatorial difficulty evaporates. Once you spot the dictionary $\langle v_A, v_B\rangle = |A \cap B|$, every counting question becomes a single line of linear algebra. The "spectral method" — using eigenvalues to bound combinatorial quantities — is one of the most powerful and beautiful techniques in modern discrete mathematics, and this is one of its cleanest demonstrations.

## A bound you can touch: the singleton crystal

A theorem that merely says "at most $n$" would be far less satisfying if no family ever reached $n$. Is the bound *sharp* — can it actually be attained?

Yes, and the example is the simplest one imaginable. Take the $n$ **singleton** teams: $\{1\}, \{2\}, \dots, \{n\}$. Each has size $k = 1$. Any two distinct singletons share no members at all, so $\lambda = 0$. And indeed $\lambda = 0 < 1 = k$, so the hypotheses are satisfied. There are exactly $n$ of them — the bound $m \le n$ is met with equality.

Geometrically, the singletons correspond to the standard coordinate axes of $\mathbb{R}^n$: the vectors $(1,0,\dots,0)$, $(0,1,0,\dots,0)$, and so on. These are the most independent vectors possible — they are perpendicular, pointing along the $n$ axes of space. You truly cannot add an $(n+1)$-th. This tight, verified instance is captured by the result `singletonFamily_fisher`, which confirms that the singleton family meets every hypothesis with $k = 1$, $\lambda = 0$, and achieves $m = n$.

The singleton crystal does double duty. It proves the bound cannot be improved, and it demonstrates that the eigenvalue hypothesis is *satisfiable* — that we are not theorizing about an empty world. The bound is real, it bites, and it is achieved.

## Why the condition $\lambda < k$ cannot be dropped

Every sharp theorem has a fault line — a place where its hypotheses become essential. Here the fault line is the strict inequality $\lambda < k$.

What happens if we allow $\lambda = k$? Then two distinct teams of size $k$ would share all $k$ of their members — meaning they are *the same team*. The condition collapses. On the matrix side, the Gram matrix becomes $0 \cdot I + k \cdot J = k J$, a pure multiple of the all-ones matrix. That matrix is **not** positive definite: it has a huge null space (any vector whose coordinates sum to zero is annihilated), so its smallest eigenvalue is zero. Positive definiteness fails, linear independence fails, and the bound $m \le n$ evaporates. You could have arbitrarily many identical "teams" with no ceiling at all.

This is the spectral signature of failure: as $\lambda$ climbs to $k$, the protective gap $k - \lambda$ that kept the diagonal dominant shrinks to nothing, and the matrix slumps from positive definite to merely semidefinite. The eigenvalue condition is not a technicality bolted onto the theorem; it *is* the theorem. The boundary between "bounded family" and "unbounded chaos" is precisely the line where an eigenvalue touches zero.

## The bigger picture: a bridge between two worlds

What makes this result worth celebrating is less the bound itself — versions of Fisher's inequality have been known for the better part of a century — and more the *shape* of the argument. It is a perfect specimen of a **cross-domain bridge**.

On one side lies combinatorics: families of finite sets, sizes, intersections, the discrete bookkeeping of who-overlaps-whom. On the other side lies linear algebra: vectors, inner products, matrices, eigenvalues, the continuous geometry of $n$-dimensional space. These feel like different universes, governed by different intuitions. The incidence-vector dictionary welds them together. A combinatorial constraint ("constant intersection") becomes an algebraic structure (a constant-pattern matrix), which becomes a spectral fact (positive eigenvalues), which becomes a counting bound (at most $n$).

This template generalizes far beyond uniform designs. The same skeleton — *encode objects as vectors, identify the Gram matrix, prove it is positive definite, conclude linear independence, read off a dimension bound* — drives some of the most celebrated results in extremal combinatorics:

- **Non-uniform Fisher inequalities**, where teams may have different sizes but still share a constant number of members. The same additive split works, replacing the uniform diagonal $k - \lambda$ with a positive *diagonal matrix* of varying entries.
- **Modular versions** à la Frankl and Wilson, where sizes and intersections are controlled modulo a prime $p$. Here "positive definite over the real numbers" is replaced by "nonsingular over the field $\mathbb{F}_p$," and the eigenvalue condition becomes a non-vanishing determinant.
- **Equiangular lines**, the famous problem of packing lines through the origin so that every pair makes the same angle. The Gram matrix becomes $I + \alpha S$ for a $\pm 1$ matrix $S$, and the bound flows from controlling the smallest eigenvalue of $S$ — a Perron–Frobenius estimate.

Each of these is a turn of the same crank. Master the bridge once, on the cleanest possible example, and a whole landscape of extremal problems opens up.

## Conclusion

We began with an innocent question about teams sharing members and ended at the eigenvalues of a matrix. The journey illustrates a principle that runs through all of mathematics: the hardest problems often yield not to brute force but to a **change of language**. By translating sets into vectors, we exchanged a thorny counting problem for a transparent geometric one, where the answer — *at most $n$* — is visible the moment you realize that $n$-dimensional space has room for only $n$ independent directions.

The constant-pattern matrix $(k - \lambda) I + \lambda J$ is positive definite exactly when $0 \le \lambda < k$, and that single eigenvalue fact is the whole theorem. The singleton family shows the bound is sharp; the degenerate case $\lambda = k$ shows why the hypothesis cannot be relaxed. Geometry, it turns out, knows how to count — and sometimes it counts better than counting does.
