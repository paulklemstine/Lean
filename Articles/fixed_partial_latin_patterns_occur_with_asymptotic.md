# The Hidden Order of Random Grids: How Often Does a Pattern Appear?

Imagine you are handed a giant $n \times n$ grid and asked to fill every cell with one of $n$ symbols, subject to a single rule that every schoolchild who has played Sudoku already knows by heart: each symbol must appear exactly once in every row and exactly once in every column. The finished object is called a **Latin square**, and it is one of the oldest and most beguiling structures in combinatorics. Leonhard Euler studied them in the eighteenth century; today they underpin error-correcting codes, the design of scientific experiments, and the scheduling of tournaments.

Now suppose you do not get to choose the square. Instead, a machine picks one **uniformly at random** from the astronomically large pool of all valid Latin squares of order $n$. (For $n = 11$ there are already more than $10^{47}$ of them.) You then ask a deceptively simple question:

> If I have written down a small fixed pattern of entries in advance — say, "the cell in row 2, column 5 should hold the symbol 7" — what is the probability that the random square agrees with my pattern?

This article is about a precise and surprisingly clean answer to that question for an important family of patterns, together with the subtle reasons why the obvious guess is *almost* right but not quite.

## Patterns, and the rule they must obey

A **partial Latin square pattern** is just a finite list of filled-in cells. Formally, it is a set of triples $(r, c, s)$ — read "row $r$, column $c$, holds symbol $s$." For a list of cells to have any chance of appearing inside a genuine Latin square, it must itself obey a weakened version of the Latin rule. We require that no two distinct entries of the pattern collide:

- they may not share the same row **and** column (you cannot put two symbols in one cell),
- they may not share the same row **and** symbol (a symbol cannot repeat in a row),
- they may not share the same column **and** symbol (a symbol cannot repeat in a column).

A pattern satisfying these three conditions is called a **partial Latin square**. If a pattern has $k$ entries, we call $k$ its size.

The central object of study is the event

$$ \{\, L \text{ contains } P \,\}, $$

meaning that the randomly chosen Latin square $L$ of order $n$ agrees with the pattern $P$ on every one of its $k$ specified cells. We want to understand

$$ \Pr[L \text{ contains } P] $$

as the order $n$ grows large.

## The seductive guess: $n^{-k}$

Here is the intuition that almost everyone reaches first. Each individual entry $(r, c, s)$ is a constraint of the form "cell $(r,c)$ holds symbol $s$." In a single cell of a random square, there are $n$ possible symbols, and by symmetry each is equally likely, so a single entry "should" hold with probability $1/n$. If the $k$ entries behaved like $k$ independent coin flips, the probability of all of them holding at once would be

$$ \left(\frac{1}{n}\right)^k = n^{-k}. $$

This leads to the clean conjecture that lit up this project:

> **Conjecture.** For any fixed partial Latin pattern $P$ with $k$ entries,
> $$ \Pr[L \text{ contains } P]\cdot n^{k} \;\longrightarrow\; 1 \qquad \text{as } n \to \infty. $$

In words: the probability decays like $n^{-k}$, and the leading constant is exactly $1$.

The trouble is that the entries are emphatically **not** independent. The whole personality of a Latin square comes from the way its cells constrain one another. So the conjecture, however natural, demands proof — and as we will see, in full generality it is actually *false*, with the failures themselves telling a beautiful story.

## A single cell: probability exactly $1/n$

The simplest case is a pattern with one entry, $P = \{(r, c, s)\}$. The claim is that the probability is not merely close to $1/n$ but **exactly** $1/n$, for every $n$, with no error term at all.

Why is it exact? The key is a hidden symmetry. Take any Latin square $L$ and any permutation $\sigma$ of the symbol alphabet $\{0, 1, \dots, n-1\}$. Relabel every entry of $L$ by $\sigma$: wherever $L$ held symbol $a$, the new square holds $\sigma(a)$. The result is still a Latin square — relabeling cannot create a repeat in any row or column. This gives a perfectly reversible shuffling (a *group action*) of the set of all Latin squares onto itself.

Fix the cell $(r, c)$ and ask which symbol sits there. The relabeling $\sigma$ sends the symbol in cell $(r,c)$ from $a$ to $\sigma(a)$. Since the permutations of the alphabet can send any symbol to any other symbol, and they shuffle the entire collection of Latin squares without changing its size, the symbol in a fixed cell must be **uniformly distributed** over all $n$ possibilities. Hence

$$ \Pr[L(r,c) = s] = \frac{1}{n}, $$

and multiplying by $n$ gives exactly $1$. In the formal development these are the results named `prob_single_cell` and `prob_single_cell_mul`.

## A whole row: the descending factorial appears

The single-cell argument is so clean that one is tempted to push it as far as it will go. It turns out to extend, perfectly and exactly, to any pattern that lives entirely **within one row**.

Consider a pattern all of whose entries share the same row $r$. Because it is a partial Latin square, its $k$ cells occupy $k$ distinct columns and carry $k$ distinct symbols. The pattern is therefore a partial matching between columns and symbols — a partial injection — restricted to row $r$.

The remarkable fact is that a single row of a uniformly random Latin square is itself a **uniformly random permutation** of the $n$ symbols across the $n$ columns. Again this follows from the alphabet-relabeling symmetry: the symbol-permutation group acts transitively on the possible contents of a fixed row, so every one of the $n!$ possible bijections (column $\mapsto$ symbol) is equally likely, each with probability $1/n!$.

Now count. How many of these $n!$ full-row arrangements extend our fixed partial pattern of $k$ cells? Having pinned down $k$ specific (column, symbol) pairs, the remaining $n - k$ columns may be matched to the remaining $n - k$ symbols in any of $(n-k)!$ ways. Therefore

$$ \Pr[L \text{ contains } P] = \frac{(n-k)!}{n!} = \frac{1}{n(n-1)(n-2)\cdots(n-k+1)}. $$

The denominator is the **descending factorial**, written $(n)_k$ (and named `Nat.descFactorial n k` in the formal library). So for any single-row pattern of size $k$,

$$ \boxed{\;\Pr[L \text{ contains } P] = \frac{1}{(n)_k}\;} $$

— again an exact identity, valid for every $n$ large enough to hold the pattern. These are the results `prob_rowfiber` and `prob_rowfiber_mul`.

## Closing in on the conjecture

We now have an exact formula and can test the conjecture head-on. The descending factorial is a slightly shrunken version of $n^k$:

$$ (n)_k = n(n-1)\cdots(n-k+1) = n^k \left(1 - \frac{1}{n}\right)\left(1 - \frac{2}{n}\right)\cdots\left(1 - \frac{k-1}{n}\right). $$

Dividing,

$$ \frac{n^k}{(n)_k} = \prod_{i=0}^{k-1} \frac{n}{n - i} = \prod_{i=1}^{k-1}\frac{1}{1 - i/n}. $$

As $n \to \infty$ with $k$ fixed, every factor tends to $1$, so the whole product tends to $1$. This is the statement `singleRow_pattern_density`:

$$ \frac{n^k}{(n)_k} \longrightarrow 1. $$

Combining the exact probability with this limit gives, for every single-row pattern,

$$ \Pr[L \text{ contains } P]\cdot n^k = \frac{n^k}{(n)_k} \longrightarrow 1, $$

which is exactly the conjecture. This is `rowpattern_prob_mul_tendsto`. Note what has been achieved: not a single example, but an **entire infinite family** of patterns — one for every size $k$ — for which the $n^{-k}$ law holds with leading constant precisely $1$.

## Where the clean story breaks: intercalates

If the single-row result extended to *all* patterns, the conjecture would be a theorem and the story would end. It does not, and the reason is illuminating.

Consider the smallest genuinely two-dimensional pattern, the **intercalate**:

$$ P = \{(0,0,0),\;(0,1,1),\;(1,0,1),\;(1,1,0)\}. $$

This is a $2 \times 2$ Latin sub-square: rows $0,1$ and columns $0,1$ carrying symbols $0,1$ in the swapped arrangement

$$ \begin{pmatrix} 0 & 1 \\ 1 & 0 \end{pmatrix}. $$

It has $k = 4$ entries, so the naive conjecture predicts probability $\sim n^{-4}$. Yet the true behavior is

$$ \Pr[L \text{ contains } P]\cdot n^{2} \longrightarrow \frac{1}{4}, $$

i.e. the probability is of order $n^{-2}$, **not** $n^{-4}$, and the constant is $1/4$ rather than $1$. This matches the long-known fact that a random Latin square contains, on average, about $n^2/4$ intercalates.

What went wrong with the count of "$k = 4$ independent constraints"? The four entries of an intercalate are wildly redundant. The whole configuration is pinned down by choosing $2$ rows, $2$ columns, and $2$ symbols, together with only **two binary choices** of how to arrange them. The four cell-entries collapse onto far fewer genuine degrees of freedom. The exponent in the decay law counts not the number of entries but the number of **independent** constraints — and here that number is $2$, not $4$.

## The unifying picture

The single-row triumph and the intercalate surprise are two faces of one principle. The alphabet-relabeling symmetry — the permutation group acting on symbols — is powerful enough to act *transitively* on the contents of any single line (a row, and by the same token a column or a symbol class). Transitivity is exactly what forces an **exact** count and the clean constant $1$. But this symmetry cannot independently move two cells that live in different rows *and* different columns. Precisely there, exactness dissolves, redundancies appear, and the leading constant drifts away from $1$.

This suggests the right general statement, which closes the project's narrative as a conjecture for future work:

> For an arbitrary fixed partial Latin pattern $P$, the probability decays like $n^{-e(P)}$, where $e(P)$ is the number of **independent** entries — the size $k$ minus the redundancy hidden in how the pattern's rows, columns, and symbols overlap. The exponent equals $k$ exactly when the pattern is "spread out," such as a partial transversal with all entries in distinct rows, distinct columns, and distinct symbols.

For single lines, $e(P) = k$ and the constant is $1$. For the intercalate, $e(P) = 2$ and the constant is $1/4$. The grand conjecture is recovered exactly in the spread-out case and gracefully corrected everywhere else.

## Why it matters

Latin squares are not an idle curiosity. They are the multiplication tables of finite quasigroups, the templates for randomized experimental designs that let scientists separate signal from confounding noise, the backbone of certain error-correcting codes, and a natural model of "balanced" combinatorial randomness. Understanding which local patterns appear, and how often, is the microscope through which we study the global structure of a typical random square — much as knowing the density of triangles or short cycles illuminates the structure of a random graph.

The story told here is a small, fully resolved chapter of that larger program. From a single transparent symmetry — relabel the symbols — flows an exact probability law $1/(n)_k$ for every single-line pattern, the asymptotic identity $n^k/(n)_k \to 1$, and a clean proof of the $n^{-k}$ conjecture across an infinite family. The same symmetry, by failing to reach across rows and columns at once, predicts exactly where the clean law must bend, and the humble $2 \times 2$ intercalate stands as the smallest honest witness to that bending. Order and its limits, read off from one idea.
