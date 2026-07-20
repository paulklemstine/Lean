# Borges’ Library of Babel: The Combinatorics of Everything

*By Aristotle — July 20, 2026*

Imagine a library containing every possible book of a fixed length. Somewhere in it is an accurate history of your life. Nearby is the same history with one letter changed, then another with every letter scrambled, then oceans of books containing nothing but typographical static. Jorge Luis Borges made this vision famous as a labyrinth of hexagonal rooms. Mathematics turns the labyrinth into a finite space that can be counted, measured, and explored.

The result is both simpler and stranger than the fiction. The library is unimaginably large, but topologically it is dust: every book is an isolated point. It is totally disconnected and has the standard signature of dimension zero. Yet a different structure—the graph obtained by joining books that differ in one position—is connected. The apparent paradox is a lesson in asking what “nearby” and “connected” mean.

The same counting that sizes the library also explains why almost every book resists compression. There are simply too few short descriptions to name all long books. This is not a claim that random-looking prose is profound. It is a precise shortage-of-names theorem.

## Building the library

Fix an alphabet with $A$ symbols and a book length of $L$ symbol positions. A book is a sequence

$$
b=(b_1,b_2,\ldots,b_L),
$$

where each $b_i$ is one of the $A$ symbols. If pages, lines, spaces, and punctuation are prescribed, they merely determine $L$; all the combinatorics then occurs at the symbol level.

At each of the $L$ positions there are $A$ independent choices. The multiplication principle gives the first theorem.

**Counting Theorem.** The fixed-length library over an alphabet of $A$ symbols contains exactly

$$
A^L
$$

books.

For a concrete scale, take an alphabet of $25$ symbols, as in Borges’s story, and suppose a page contains $40$ lines of $80$ positions. A $410$-page book then has

$$
L=410\cdot40\cdot80=1{,}312{,}000
$$

positions and the library has $25^{1{,}312{,}000}$ books. Its decimal digit count is

$$
\left\lfloor 1{,}312{,}000\log_{10}25\right\rfloor+1,
$$

which is about $1.83$ million digits. The number is finite, but writing the number itself would fill many books.

## Distance by disagreement

To give the library geometry, count disagreements. The **Hamming distance** between books $x$ and $y$ is

$$
d_H(x,y)=\#\{i: x_i\ne y_i\}.
$$

Two identical books have distance $0$; books differing in one symbol have distance $1$; and no pair is farther apart than $L$.

This integer-valued metric has an immediate consequence. The open ball of radius $1/2$ around a book $x$ contains only $x$, because every different book is at least distance $1$ away. Thus every singleton set $\{x\}$ is open. Its complement is a union of other open singletons, so $\{x\}$ is also closed. Such a set is called **clopen**.

**Discrete Topology Theorem.** The Hamming topology on a finite fixed-length library is discrete: every subset is open, and every subset is closed.

Indeed, any subset is a union of singleton books. This theorem determines the library’s topological character.

A space is **totally disconnected** when its only connected subsets are singletons. If a subset contains two books $x$ and $y$, the clopen singleton $\{x\}$ separates $x$ from the rest of the subset. Therefore:

**Total Disconnection Theorem.** Every fixed-length Hamming library is totally disconnected.

Moreover, singleton books form a basis made entirely of clopen sets. For finite metrizable spaces this is the standard certificate of **covering dimension zero**: every point can be resolved without overlap into arbitrarily fine clopen neighborhoods.

**Dimension-Zero Theorem.** A finite fixed-length Hamming library has covering dimension $0$.

Dimension zero does not mean that the library has no points, nor that its combinatorics is trivial. It means its topology has no continuous threads, sheets, or higher-dimensional pieces. It is a colossal cloud of isolated grains.

## The connectedness trap

One might hear that the Library of Babel is connected because any book can be changed into any other one symbol at a time. That statement is correct—but it concerns a graph, not the metric topology.

Construct the **Hamming graph** by making each book a vertex and joining two vertices when their Hamming distance is $1$. Given any books $x$ and $y$, change the coordinates on which they differ one after another. This produces a path of length $d_H(x,y)$ from $x$ to $y$. So, when the library is nonempty, its Hamming graph is connected.

Topological connectedness asks a different question: can the space be divided into two disjoint nonempty open pieces? In every genuine library, yes. If $A\ge2$ and $L>0$, choose two different symbols $a$ and $b$. The constant books

$$
(a,a,\ldots,a)\qquad\text{and}\qquad(b,b,\ldots,b)
$$

are distinct. Since each singleton is clopen, one book and its complement disconnect the space.

**Nonconnectedness Theorem.** If $A\ge2$ and $L>0$, the fixed-length Hamming library is not topologically connected.

Thus the simultaneous claim that this same finite Hamming space is connected and totally disconnected is false except in degenerate cases with at most one book. The contradiction disappears once graph paths are separated from topological paths.

There is a useful consequence for generative models. A parameter space such as an interval is preconnected: it cannot be split into separated open pieces. The continuous image of a preconnected space is preconnected. But every preconnected subset of a totally disconnected library contains at most one point.

**Continuous Decoder Theorem.** Every continuous map from a preconnected parameter space into a fixed-length Hamming library is constant. Consequently, no such map can cover a library containing two or more books.

A smoothly turning dial cannot select every book if output books carry the discrete Hamming topology. A practical generator must jump discontinuously, use a disconnected parameter space, or replace exact books with a softer output geometry.

## Why almost every book is incompressible

Now suppose a decoder has a finite set of $N$ programs. Each program produces at most one book. Regardless of how clever the decoder is, its image contains at most $N$ books.

Call a book **described** if some allowed program decodes to it and **incompressible relative to this decoder and program budget** otherwise. Counting images gives the central compression result.

**Finite Incompressibility Theorem.** In a library of $A^L$ books, a decoder with $N$ available programs describes at most $N$ books. Therefore at least

$$
A^L-N
$$

books remain undescribed.

The decoder need not be injective. If several programs print the same book, it describes even fewer distinct books, making the bound stronger.

The binary case makes “almost all” quantitative. There are $2^L$ binary books of length $L$. If only $2^{L-c}$ descriptions are permitted, at least

$$
2^L-2^{L-c}=2^L(1-2^{-c})
$$

books are undescribed. Under the uniform distribution, the incompressible proportion is at least $1-2^{-c}$, while the compressible proportion is at most $2^{-c}$. Saving $10$ bits restricts compressible strings to at most about one in a thousand; saving $20$ bits restricts them to at most about one in a million.

This is a pigeonhole principle on a cosmic scale. Short descriptions are the pigeonholes; books are the pigeons. When there are fewer descriptions than books, most books cannot fit.

A crucial qualification is often lost in popular accounts: complexity depends on the decoder. A custom decoder could assign a one-symbol command to any chosen book. Another decoder might require printing it verbatim. There is therefore no decoder-independent exact complexity for one particular “random book” in this finite framework. What survives every fixed decoder is the counting statement: too few short programs exist to describe more than a small fraction of all books.

Nor does incompressibility imply literary value. A meaningful novel may be highly compressible because language contains patterns, while pure noise is usually incompressible. Compression measures reproducibility from a description, not truth, beauty, or significance.

## Sampling an impossible collection

The theorems suggest simple experiments without constructing the full library. Sample random books, compute pairwise Hamming distances, and count how many outputs a toy decoder reaches. For uniformly random books over $A$ symbols, each coordinate disagrees with probability $1-1/A$, so the expected distance is

$$
L\left(1-\frac1A\right).
$$

Most long books are therefore far apart. The topology already isolates them at radius below $1$, while probability places typical pairs near a large distance proportional to $L$.

A breadth-first walk in the Hamming graph tells another story: local one-symbol edits eventually reach every book. The number exactly $k$ edits away from a fixed book is

$$
\binom{L}{k}(A-1)^k,
$$

because one chooses $k$ positions and changes each to one of $A-1$ alternatives. Summing over $k$ recovers the entire library:

$$
\sum_{k=0}^{L}\binom{L}{k}(A-1)^k=A^L.
$$

So the same set appears as isolated dust under its metric topology and as a richly connected network under adjacency. Neither view is more “real”; each answers a different question.

## Beyond the finite shelves

Several natural extensions sharpen the picture. Prefix-free programming languages replace a fixed list of programs with variable-length codes; Kraft’s inequality then supplies the same shortage-of-descriptions argument. A uniform probability measure turns cardinal bounds directly into probability bounds. Infinite symbol streams produce a more subtle space: with the product topology, they remain totally disconnected but become compact and perfect, with no isolated points—a Cantor-like library rather than a finite dust cloud.

The finite library nevertheless contains the main lesson. Vastness alone does not create continuity. A collection can have more members than imagination can hold and still have topological dimension zero. Local edit paths do not make a discrete topology connected. Randomness is not mystical; much of it follows from counting names.

Borges pictured librarians wandering forever through hexagons, searching for a book that explains the others. Mathematics offers no master volume. It offers something more austere: $A^L$ possible texts, each isolated; a graph joining them by edits; and a proof that nearly all lie beyond every sufficiently short dictionary of descriptions. The library contains everything, but almost everything in it has no shorter way to be said.
