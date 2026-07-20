# Borges’ Library of Babel: The Geometry of Everything That Can Be Written

Imagine a library containing every possible book of a fixed length. Somewhere in it is an exact account of your life, a version with one letter changed, every unwritten symphony rendered as text, and oceans of meaningless noise. Jorge Luis Borges turned this idea into haunting fiction. Mathematics turns it into a finite space whose size, geometry, and informational limits can be calculated exactly.

The first surprise is that this library is not merely enormous. It has a sharply defined shape. The second is that this shape corrects a tempting misconception: although one can move from any book to any other by changing one symbol at a time, the library is **not connected as a topological space**. Its points are isolated. The third is an information-theoretic inevitability: most books cannot be named by any substantially shorter fixed-length description language.

These conclusions follow from elementary ideas—counting, distance, open sets, and functions—but together they expose a deep tension between continuous geometry and discrete information.

## Turning books into points

Fix an alphabet of $A$ symbols and a book length of $L$ symbol positions. A book is a sequence

$$
b=(b_1,b_2,\ldots,b_L),
$$

where each $b_i$ is one of the $A$ available symbols. Page breaks, spaces, and punctuation need no special treatment: they can all be symbols, and the entire physical format can be encoded into the fixed list of positions.

There are exactly

$$
A^L
$$

books. At each of the $L$ positions there are $A$ independent choices. Even modest values are staggering. A binary library with $L=100$ already contains $2^{100}$ books, about $1.27\times 10^{30}$. A realistic typographic alphabet and a 410-page format produce a number too large to visualize, but its finiteness matters: every argument below is exact.

To give the library a geometry, define the Hamming distance between books $b$ and $c$ by

$$
d_H(b,c)=\#\{i: b_i\ne c_i\}.
$$

Two books are close when they disagree in few positions. The smallest positive distance is $1$: distinct books cannot be closer than a single changed symbol.

This geometry captures proofreading, transmission errors, mutations in digital strings, and nearest-neighbor search. It also distinguishes two notions that ordinary language tends to blur: graph reachability and topological connectedness.

## A path of edits is not a continuous path

Any two books can be joined by a finite chain of single-symbol edits. Change each disagreeing position one at a time; after exactly $d_H(b,c)$ edits, the first book has become the second. In the graph whose edges connect books at Hamming distance $1$, the library is connected.

But topology asks a different question. Around any book $b$, take an open ball of radius less than $1$, for example radius $1/2$. No other book lies in it:

$$
B(b,1/2)=\{b\}.
$$

Thus every singleton set is open. Its complement, being a union of the other open singletons, is open too, so every singleton is also closed. A space in which every singleton is open has the **discrete topology**.

This gives the Topological Structure Theorem: **the fixed-length Hamming library is discrete; its singleton sets form a basis of sets that are both open and closed; consequently it is totally disconnected and has covering dimension zero.** Here “totally disconnected” means that every connected subset contains at most one point. Dimension zero means, in this finite setting, that the topology has a basis of clopen sets—sets simultaneously closed and open.

The word “connected” therefore needs care. The edit graph is connected, but the topological space is disconnected whenever it contains more than one book. If $A\ge 2$ and $L>0$, the all-zero book and a book beginning with symbol $1$ are distinct. The singleton containing either one is a nonempty clopen set, separating it from the rest of the library. Hence the nontrivial library is not topologically connected.

There is no contradiction. Graph paths are finite sequences of jumps. A continuous path is the image of a connected interval, and a discrete target permits no nonconstant continuous motion. The edit graph records which jumps are allowed; the topology records whether motion can occur without jumps.

## Why smooth generators freeze

This distinction has a striking consequence for generative models. Suppose a parameter space $X$ is connected—an interval, a disk, ordinary Euclidean space, or any region that cannot be split into separated open pieces. Suppose also that a decoder

$$
D:X\longrightarrow \mathcal{B}_{A,L}
$$

assigns a book to each parameter value and is continuous in the Hamming topology.

Then $D$ must be constant.

The reason is short and decisive. A continuous image of a connected space is connected. Yet the only connected subsets of the discrete library are singletons. Therefore $D(X)$ contains one book at most.

This is the Continuous Decoder Theorem: **every continuous map from a connected parameter space into a fixed-length Hamming library assigns the same book to every parameter value.** In particular, if $A\ge 2$ and $L>0$, no continuous decoder from a nonempty connected space can cover the whole library.

Real systems evade this obstruction by introducing discontinuities. A neural network may produce continuous scores and then choose the largest score; that final choice is discontinuous. A digital interface rounds real values to symbols. A branching program makes discrete decisions. The theorem does not say generation is impossible. It says that exact symbolic variety cannot emerge from a connected latent space through an everywhere-continuous map into a discrete output geometry.

## The arithmetic of incompressibility

Topology explains why continuous variation fails. Counting explains why short descriptions fail.

Let $C$ be a finite set of programs or descriptions, and let

$$
\delta:C\longrightarrow \mathcal{B}_{A,L}
$$

be any decoding rule. Different descriptions may produce the same book. Consequently, the number of books named by the language is at most $|C|$.

This yields the Finite Incompressibility Theorem: **if $|C|<A^L$, at least one book is not produced by any description in $C$. More strongly, at least $A^L-|C|$ books are not produced.**

Nothing about the internal design of the decoder matters. It may be ingenious, highly optimized, or tailored to famous literature. A function from $|C|$ descriptions can hit at most $|C|$ outputs. Compression can favor selected books only by leaving others unnamed.

For a binary library, suppose every allowed program has exactly $k$ bits. There are $2^k$ such programs and $2^L$ books of length $L$. Therefore at least

$$
2^L-2^k
$$

books have no $k$-bit description under the chosen decoder. Under the uniform distribution on books, the proportion not described is at least

$$
1-2^{k-L}.
$$

If $k=L-c$, at least a fraction $1-2^{-c}$ of all books resist compression by $c$ bits in this fixed-length description model. With a ten-bit saving, at least $1023/1024$ of the library remains undescribed.

This is the counting heart of Kolmogorov incompressibility. Fully developed Kolmogorov complexity normally fixes a universal machine and allows programs of varying lengths, with conventions needed to delimit them. The finite theorem isolates the indisputable core: too few short names exist for too many long objects. It does not identify which particular books are complex, and it does not claim that every random-looking book is incompressible. It proves a population statement: regardless of the decoder, scarcity of descriptions forces abundance of unnamed books.

## A 410-page universe

For Borges’ 410-page library, let $L$ be the total number of symbol positions across all pages. The theorems do not depend on the exact typography. Once $A$ and $L$ are fixed, the space has $A^L$ points, minimum positive Hamming distance $1$, and isolated books. Every connected component is a singleton. Its covering dimension is zero. Any continuous image of a connected parameter domain reaches at most one volume. Any finite language with $N$ descriptions misses at least $A^L-N$ volumes.

The geometry and the counting theorem reinforce one another. Topologically, each book sits alone. Informationally, most books also sit beyond the reach of any prescribed collection of short names. Isolation in space is not the same as incompressibility, but both arise from the same finite combinatorial vastness.

There is also a practical lesson. Hamming geometry is central to error-correcting codes: one selects a sparse set of meaningful strings whose mutual distances are large, so corrupted messages can be repaired. Compression takes the opposite viewpoint: one selects a small set of descriptions and asks which strings they can name. Future combinations of these ideas can quantify books that are both far from every structured collection and resistant to short description.

## The infinite shelf beyond

A finite library is discrete because distinct books are separated by at least one symbol. If books become infinite streams, the natural topology changes. Two streams can be considered close when they share a long initial segment, even if they eventually differ. No individual infinite stream is then isolated. Cylinder sets—collections of streams agreeing on a finite prefix—are clopen and form a basis. The space remains totally disconnected and zero-dimensional, but it is no longer discrete. It becomes Cantor-like: full of points, with no continuous arcs between them, yet with arbitrarily close distinct texts.

That limit clarifies what is special about the finite case. Borges’ fixed volumes form a dust of isolated possibilities. Infinite texts form a perfect dust, where every point is approached by others.

The Library of Babel is often invoked as a metaphor for totality: everything is present. Mathematics reveals a subtler portrait. Everything may be present, yet every item is isolated. Every book may have neighbors one typo away, yet no continuous journey reaches them. Every text may exist, yet almost all evade any substantially smaller stock of names. The library is not an undifferentiated infinity. It is a precisely countable universe whose geometry is made of gaps and whose information is dominated by the unnameable.
