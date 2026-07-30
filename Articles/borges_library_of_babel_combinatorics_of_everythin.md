# The Library That Contains Every Book—and Almost No Short Explanations

Imagine a library so complete that it contains every possible book of a fixed length. It holds histories of civilizations that never existed, accurate biographies of every reader, flawless proofs, catastrophic nonsense, and this article—surrounded by oceans of pages differing from it in only one character. This is the mathematical engine behind Jorge Luis Borges’ “Library of Babel.” Once the romance is translated into combinatorics, the library becomes finite, exact, and almost unimaginably large.

Take an alphabet of $A$ symbols and reserve $L$ positions for each book. A book is simply a function assigning one symbol to each position. There are $A$ choices at the first position, $A$ at the second, and so on, so the multiplication principle gives

$$
|\mathcal B_{A,L}|=A^L.
$$

For the conventional Babel parameters—$25$ symbols and $1{,}312{,}000$ character positions—the library contains exactly

$$
25^{1{,}312{,}000}
$$

books. This is not infinity. It is stranger in a way: it is a perfectly definite integer that overwhelms any physical scheme for storing its contents. Its decimal expansion has $1{,}834{,}098$ digits, because $1{,}312{,}000\log_{10}(25)\approx1{,}834{,}097.3$ and the digit count is one more than the integer part of this logarithm.

Yet cardinality is only the first surprise. The library also has a geometry.

## Shelving by difference

Given two books $b$ and $b'$, define their Hamming distance by counting the positions at which they disagree:

$$
d_H(b,b')=\bigl|\{i: b(i)\ne b'(i)\}\bigr|.
$$

Two books have distance $1$ when one character has been changed, distance $2$ when two characters have been changed, and at most $L$ when every position differs. This geometry is central to error-correcting codes, DNA sequence comparison, data transmission, and approximate search. A corrupted message is a nearby “book”; decoding means identifying which intended message lies closest to it.

Topologically, however, the finite Hamming library is not a continuous labyrinth. It is dust.

Every two distinct books are at least distance $1$ apart. Therefore the open ball of radius $1/2$ around a book contains only that book. Every singleton set is open. Its complement, being a union of other singletons, is open too, so every singleton is both open and closed—“clopen” in the standard shorthand. Thus the Hamming topology is discrete.

This simple observation settles three structural questions at once.

**Discrete Library Theorem.** For every finite alphabet and every finite book length, the Hamming topology on the set of books is discrete.

**Zero-Dimensionality Theorem.** The singleton sets form a basis consisting entirely of clopen sets. Consequently the library is zero-dimensional in the usual covering-dimension sense for finite metrizable spaces.

**Total Disconnection Theorem.** Every connected subset of the library contains at most one book.

The last statement deserves emphasis. A space is totally disconnected when its only connected pieces are single points. Any subset containing two books can be separated: put one book in its own clopen singleton and all remaining books on the other side. No continuous path can move through distinct books, because there are no intermediate points between one finite word and the next.

This corrects a tempting but impossible description of Babel as both connected and totally disconnected. A nontrivial connected space cannot also have every connected component reduced to one point. If $A\ge2$ and $L\ge1$, there are at least two books—for instance, the book filled with one symbol and the book filled with another. The library is then not connected. Only degenerate cases, where at most one book exists, can be connected.

## Why a continuous dial cannot generate the library

Suppose an engineer tries to build a “book dial.” A point $x$ in some connected control space $X$ is fed into a decoder $D$, which outputs a book. If the decoder is continuous, turning the dial by a small amount should not cause a topological jump.

But the target library is totally disconnected. The continuous image of a connected space is connected, and the only connected subsets of the library are singletons. Hence the image of $D$ contains just one book.

**Continuous Decoder Theorem.** If $X$ is preconnected and $D:X\to\mathcal B_{A,L}$ is continuous, then $D(x)=D(y)$ for every $x,y\in X$.

Here “preconnected” means that $X$ cannot be split into two disjoint nonempty open pieces; the term also handles the empty space cleanly. If $X$ is nonempty and the library is genuine, with $A\ge2$ and $L\ge1$, no continuous decoder from $X$ can be onto the whole library.

This does not say computers cannot enumerate books. They can. It says that an enumeration uses a discrete state change somewhere. A digital counter, a branching decision, or a discontinuous threshold must break the connected motion into separate outputs. The theorem is a miniature version of a broad engineering truth: a continuous control signal cannot continuously cover a discrete collection of more than one state.

## The counting argument behind incompressibility

Borges’ deeper unease comes not from the number of books but from their resistance to meaning. Most pages look like noise. Mathematics makes this intuition precise, although it must do so carefully.

A description system consists of a finite set $C$ of codes and a decoder

$$
D:C\to\mathcal B_{A,L}.
$$

Different codes may decode to the same book, so the decoder can name no more than $|C|$ distinct books:

$$
|D(C)|\le |C|.
$$

This is the entire mechanism. It is only the pigeonhole principle, but at Babel’s scale it becomes an incompressibility theorem.

**Finite Incompressibility Theorem.** For any decoder from a finite code set $C$ into the library, at least

$$
A^L-|C|
$$

books are not named by any available code. In particular, if $|C|<A^L$, at least one book has no description in that language.

The theorem is uniform: it does not care how clever the decoder is. Codes may invoke dictionaries, grammars, mathematical formulas, neural networks, or elaborate reconstruction procedures. A set of $N$ codes can still produce at most $N$ distinct outputs.

For binary books of length $L$, a program with exactly $k$ bits has $2^k$ possible bit strings. Whatever decoder is chosen, at least

$$
2^L-2^k
$$

binary books remain unnamed by those programs. If $k=L-c$ and $0\le c\le L$, then at least

$$
2^L-2^{L-c}
$$

books cannot be produced by an exactly-$(L-c)$-bit code. Equivalently, the fraction that can be named is at most

$$
\frac{2^{L-c}}{2^L}=2^{-c},
$$

so the fraction left unnamed is at least $1-2^{-c}$. Save $10$ bits and at most one book in $1024$ can have such a code. Save $100$ bits and the describable fraction is at most $2^{-100}$.

The phrase “almost all books are incompressible” is therefore a counting statement. As the allowed deficit $c$ grows, the describable proportion collapses exponentially.

There is an important qualification. Exact Kolmogorov complexity is defined only after fixing a programming language or universal machine, and its exact values are generally uncomputable. The finite theorem does not pretend to assign an absolute complexity to each book. Instead it proves something stronger in its own direction: for every chosen finite decoder, too few short codes exist to cover more than a tiny fraction of the library. If one counts programs of all lengths below a threshold rather than programs of exactly one length, the code count must be changed accordingly; for ordinary binary strings of lengths below $k$, it is $1+2+\cdots+2^{k-1}=2^k-1$. Prefix-free coding leads to the sharper probabilistic forms familiar from algorithmic information theory.

## A universe where rarity is guaranteed

The same argument explains why compression works brilliantly on human data without contradicting the incompressibility of most strings. Human writing, photographs, music, and scientific measurements occupy highly structured corners of the space of all possible files. Language repeats words; images contain smooth regions; physical measurements obey laws. Compression exploits these regularities.

Uniformly sampled books have no reason to fall into those corners. Under the uniform distribution on binary books, the probability of landing among the outputs of exactly $(L-c)$-bit codes is at most $2^{-c}$. The useful files encountered in life are spectacularly nonuniform. They are selected by biology, culture, and physics long before a compression algorithm sees them.

The Hamming geometry adds another perspective. Meaningful books may form clusters under carefully chosen representations, while the full library remains a discrete finite space. Hamming balls quantify local neighborhoods: a ball of radius $r$ around a book contains

$$
\sum_{j=0}^{r}\binom Lj(A-1)^j
$$

books, because one chooses $j$ changed positions and then one of $A-1$ replacement symbols at each. This formula points toward coding theory, where messages are deliberately spaced far apart so that small corruptions can be corrected.

Borges’ library is thus three mathematical objects at once. Combinatorially, it has $A^L$ points. Geometrically, Hamming distance organizes those points by character substitutions. Topologically, finite resolution isolates every point, producing a zero-dimensional, totally disconnected, and—except in degenerate cases—disconnected space. Algorithmically, counting proves that nearly every point evades every substantially shorter description scheme.

The result is a useful antidote to two illusions. The first is that an enormous finite collection behaves like a continuum. It does not: under Hamming distance, each book stands alone. The second is that every object must possess a much shorter explanation. It need not: explanations are themselves finite objects, and there are simply not enough short ones.

Babel contains every answer, every error, and every possible arrangement of the alphabet. But abundance does not create accessibility. The books are separated by discrete gaps, a continuous dial cannot sweep through them, and almost all of them cannot be singled out by codes substantially shorter than themselves. The library has everything—yet counting tells us why almost none of it can be found by a shortcut.
