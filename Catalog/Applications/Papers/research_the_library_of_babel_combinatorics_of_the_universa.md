# The Combinatorics of Universal Information Spaces: Counting, Probability, and Cataloging in the Library of Babel

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Applications

## Abstract

We give a self-contained combinatorial analysis of Jorge Luis Borges' *Library of
Babel* and the broader class of *universal information spaces*: the set of all
strings of a fixed length over a fixed finite alphabet. We establish four groups
of results, all verified. First, an **enumeration** layer: the space of length-$L$
volumes over a $b$-symbol alphabet has exactly $b^L$ elements, and admits an
explicit order-isomorphism (the *universal catalog*) with the integers
$\{0,\ldots,b^L-1\}$. Second, a **probabilistic** layer: under the uniform
distribution, a fixed target volume has probability $b^{-L}$, and the probability
that a random volume contains a fixed pattern of length $k$ is bounded by
$(L-k+1)\,b^{-k}$, with the expected occurrence count equal to that quantity
exactly. This is the precise form of the folklore estimate "probability of finding
a passage $\approx |T|\cdot b^{-k}$." Third, a **constructive cataloging** result:
for the mini-library with alphabet size $4$ and address length $2$, a single
volume of optimal length $16$ — an explicit de Bruijn word $B(4,2)$ — catalogs all
$16$ addresses exactly once, formalized as a bijection between cyclic window
positions and the address space. Fourth, an **impossibility/threshold** result:
no single volume can injectively encode all sub-collections of the library (a
Cantor diagonal argument, since $2^{(b^L)} > b^L$), while a distributed catalog
across $N$ volumes can do so **if and only if** $2^{(b^L)} \le (b^L)^N$,
equivalently $N \ge b^L/(L\log_2 b)$. Together these results draw a precise map of
what is and is not catalogable in a universe where every text already exists.

## 1. Introduction

Borges' 1941 story posits a library of all books of a fixed length over a fixed
alphabet. Two questions animate the story: *how vast is the collection?* and *can
one ever find meaning, or a guide to meaning, within it?* These are mathematical
questions, and modern information spaces — the set of all possible files of a
given size — make them concrete and current. We treat the library as the finite
type of all strings of length $L$ over an alphabet of size $b$, and we answer the
counting, probability, and cataloging questions exactly.

The contributions, each corresponding to a verified result, are:

1. **Enumeration** (Thm. 1–2): an exact count $b^L$ and an explicit bijective
   catalog.
2. **Probability** (Thm. 3–3b): the single-target probability $b^{-L}$, the exact
   expected substring count, and the union bound on containment.
3. **Constructive cataloging** (Thm. 6, Cor. 7–9): an explicit single-volume de
   Bruijn catalog for the $(b,n)=(4,2)$ mini-library.
4. **Diagonal impossibility and distributed threshold** (Thm. 10–11, Cor. 12): no
   single volume catalogs all sub-collections, and the sharp distributed
   threshold $2^{(b^L)} \le (b^L)^N$.

The work *bridges* three areas: finite combinatorics (counting and de Bruijn
sequences), probability (uniform string models), and set theory / information
theory (Cantor diagonalization and encoding capacity).

## 2. Definitions

Throughout, $b, L, n, k, N$ denote natural numbers.

**Definition 1 (Alphabet and volume).** The *alphabet* is a finite set of $b$
symbols, modeled as $\mathrm{Fin}\,b = \{0,1,\ldots,b-1\}$. A *volume* (book) of
length $L$ is a function $v : \mathrm{Fin}\,L \to \mathrm{Fin}\,b$, i.e. an
assignment of a symbol to each of the $L$ positions. We write
$\mathrm{Volume}(b,L)$ for the type of such volumes. In Borges' specialization,
$b = 25$ and $L = \mathrm{BabelLength} = 1{,}312{,}000$.

**Definition 2 (Library).** The *library* $\mathrm{Library}(b,L)$ is the (finite)
collection of all volumes of length $L$, i.e. the full finite type
$\mathrm{Volume}(b,L)$.

**Definition 3 (Uniform probability).** For a finite type $\alpha$ and a subset
$S$, the *counting probability* is $\Pr(S) = |S| / |\alpha|$. On the library this
is the uniform distribution over all $b^L$ volumes.

**Definition 4 (de Bruijn catalog volume).** For the mini-library $b=4$, the
*catalog volume* is the length-$16$ word over $\mathrm{Fin}\,4$
$$\mathrm{cat} = (0,0,1,0,2,0,3,1,1,2,1,3,2,2,3,3),$$
viewed as a function $\mathrm{cat} : \mathrm{Fin}\,16 \to \mathrm{Fin}\,4$.

**Definition 5 (Window map).** The *window* at cyclic position $i \in
\mathrm{Fin}\,16$ is the length-$2$ address
$$\mathrm{window}(i) = \big(\mathrm{cat}(i),\ \mathrm{cat}(i+1)\big) \in
\mathrm{Fin}\,4 \times \mathrm{Fin}\,4,$$
with the index $i+1$ taken modulo $16$ (cyclic reading).

**Definition 6 (Pattern occurrence).** A *pattern* of length $k$ is a function
$p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$. It *occurs at position $i$* in a volume
$v$ of length $L$ if $v(i+j) = p(j)$ for all $j < k$ (with $i + k \le L$). The
volume *contains* $p$ if $p$ occurs at some position. The *occurrence count* is the
number of positions at which $p$ occurs.

## 3. Enumeration

**Theorem 1 (Cardinality of the library).** *For all $b, L$,*
$$\big|\mathrm{Volume}(b,L)\big| = b^L.$$
*In particular $|\mathrm{Volume}(25,1312000)| = 25^{1312000}$.*

*Proof sketch.* A volume is a function from the $L$-element index type into the
$b$-element alphabet; the number of functions from an $L$-set to a $b$-set is
$b^L$. Formally this is the cardinality of a function type between finite types.
$\square$

**Theorem 2 (Universal catalog).** *There is an explicit bijection
$\mathrm{universalCatalog} : \mathrm{Volume}(b,L) \;\leftrightarrow\;
\mathrm{Fin}(b^L)$, with verified encode/decode correctness: decoding an encoded
volume returns the volume, and encoding a decoded address returns the address.*

*Proof sketch.* Read a volume as a base-$b$ numeral: position $i$ contributes
$v(i)\cdot b^i$. This is the standard mixed-radix bijection between
$\mathrm{Fin}\,b^L$ and tuples in $(\mathrm{Fin}\,b)^L$, packaged as an explicit
equivalence whose two round-trip identities hold definitionally / by the
digit-recovery lemmas. $\square$

The library is thus finite and *totally indexed*: every volume has a unique
integer address and vice versa.

## 4. Probability

We equip the library with the uniform distribution (Def. 3).

**Theorem 3 (Single-target probability).** *For any fixed volume $v \in
\mathrm{Volume}(b,L)$,*
$$\Pr\big(\{v\}\big) = b^{-L}.$$

*Proof sketch.* The singleton has cardinality $1$ and the library has cardinality
$b^L$ by Theorem 1; the counting probability is their ratio. $\square$

For Borges' parameters this is $25^{-1312000}$ — the chance of drawing one
predetermined book.

**Theorem 3a (Expected substring count).** *Let $k \le L$, $b > 0$, and let $p$ be
a pattern of length $k$. The expected number of occurrences of $p$ in a uniformly
random volume of length $L$ is exactly*
$$\mathbb{E}[\#\text{occurrences}] = (L - k + 1)\, b^{-k}.$$

*Proof sketch.* By linearity of expectation over the $L-k+1$ candidate start
positions. At each fixed position the pattern matches iff the $k$ aligned symbols
agree, which constrains exactly $k$ of the $L$ free symbols; the number of volumes
matching at a fixed position is therefore $b^{L-k}$, giving per-position
probability $b^{-k}$. Summing $b^{-k}$ over $L-k+1$ positions yields the claim.
The matching count $b^{L-k}$ is established by an explicit cardinality lemma for
the set of volumes agreeing with a pattern on an injective set of positions.
$\square$

**Theorem 3b (Containment union bound).** *Under the same hypotheses,*
$$\Pr\big(\{v : v \text{ contains } p\}\big) \;\le\; (L - k + 1)\, b^{-k}.$$

*Proof sketch.* The containment event is the union over start positions of the
per-position match events; bound the cardinality of the union by the sum of the
cardinalities (a finite union/biUnion bound), then divide by $b^L$. Each term is
$b^{L-k}/b^L = b^{-k}$ and there are $L-k+1$ of them. $\square$

**Interpretation (the brief's estimate).** Theorems 3a–3b make precise the
heuristic that the chance of locating a meaningful passage $T$ of complexity $k$
is $\approx |T|\cdot b^{-k}$: the $b^{-k}$ factor is the exponential cost of each
symbol of demanded structure, and the $(L-k+1)\approx L$ factor is the linear gain
from a long book offering many trial positions. Rarity per site, multiplied by a
million sites.

## 5. Constructive Cataloging: the de Bruijn Mini-Catalog

We now realize Borges' "single universal catalog" in the regime where it is
possible: cataloging the *addresses* (short codes) rather than the
*sub-collections*. Take $b = 4$ and address length $n = 2$; there are $4^2 = 16$
addresses, and we exhibit a single optimal-length volume that lists all of them.

**Theorem 6 (Window bijection).** *The window map $\mathrm{window} :
\mathrm{Fin}\,16 \to \mathrm{Fin}\,4 \times \mathrm{Fin}\,4$ of Definition 5 is a
bijection.*

*Proof sketch.* Source and target both have cardinality $16$, so by the
finite-set principle "$f$ is bijective iff $f$ is injective and the cardinalities
match," it suffices to verify injectivity. Injectivity of the explicit $16$-entry
map is a finite, decidable check over all $\binom{16}{2}$ position pairs;
combining it with the cardinality identity $|\mathrm{Fin}\,16| = |\mathrm{Fin}\,4
\times \mathrm{Fin}\,4| = 16$ upgrades injectivity to bijectivity. Note this is
not "brute force only": the structural step is the injectivity-plus-cardinality
upgrade; the downstream corollaries are derived abstractly. $\square$

**Corollary 7 (Every address exactly once).** *For every address $p \in
\mathrm{Fin}\,4\times\mathrm{Fin}\,4$ there is a unique cyclic position $i$ with
$\mathrm{window}(i) = p$.* (From the bijection's unique-preimage property.)

**Corollary 8 (Completeness).** *Every address occurs:* $\forall p,\ \exists i,\
\mathrm{window}(i) = p$ (surjectivity).

**Corollary 9 (Optimality / no repeats).** *Distinct positions read distinct
addresses:* $\mathrm{window}$ is injective. Since the volume has length $16 = 4^2$,
this is the minimum possible length for a single volume listing all $16$
addresses; no shorter volume could be window-complete.

**Remark (the combinatorial bridge).** A single volume listing every length-$n$
address exactly once is precisely a de Bruijn sequence $B(b,n)$, equivalently an
Eulerian circuit in the de Bruijn graph on $b^{n-1}$ nodes whose $b^n$ edges are
the addresses. Cataloging-by-windows, address enumeration, and Eulerian
graph-walking are three views of one object. We give an explicit witness rather
than invoking a general Eulerian-existence theorem.

## 6. Diagonal Impossibility and the Distributed Threshold

We now turn to the *deepest* question of the brief: can the library catalog its own
contents? We sharpen "catalog the whole library" to "injectively encode every
*sub-collection*," the genuine task of a complete index, of which there are
$2^{(b^L)}$.

**Theorem 10 (No single complete catalog).** *For all $b, L$, there is no
injection from the type of sub-collections $\mathrm{Finset}(\mathrm{Volume}(b,L))$
into a single volume $\mathrm{Volume}(b,L)$. Equivalently, $b^L < 2^{(b^L)}$.*

*Proof sketch.* A single volume realizes one of $b^L$ values, whereas the
sub-collections number $2^{(b^L)}$. Since $m < 2^m$ for every natural $m$ (in
particular $m = b^L$), there are strictly more sub-collections than volume values,
so no injection exists by the pigeonhole principle. This is a Cantor diagonal
statement and holds unconditionally, including degenerate $b\in\{0,1\}$. $\square$

**Theorem 11 (Distributed catalog threshold).** *A distributed catalog across $N$
volumes — i.e. an injection $\mathrm{Finset}(\mathrm{Volume}(b,L)) \hookrightarrow
(\mathrm{Fin}\,N \to \mathrm{Volume}(b,L))$ — exists if and only if*
$$2^{(b^L)} \;\le\; (b^L)^N.$$

*Proof sketch.* The codomain $(\mathrm{Fin}\,N \to \mathrm{Volume}(b,L))$ has
cardinality $(b^L)^N$, and the domain has cardinality $2^{(b^L)}$. Between finite
types, an injection exists iff the domain's cardinality does not exceed the
codomain's. Substituting the two cardinalities yields the stated equivalence.
$\square$

**Corollary 12 (Single volume below threshold).** *The $N = 1$ instance of Theorem
11 never holds:* $2^{(b^L)} \le b^L$ is false for all $b, L$, recovering Theorem 10
as the smallest case.

**Threshold in logarithmic form.** Taking $\log_b$ of $(b^L)^N = b^{LN}$ and of
$2^{(b^L)} = b^{(b^L)\log_b 2}$, the condition $2^{(b^L)} \le (b^L)^N$ becomes
$$N \cdot L \;\ge\; b^L \log_b 2, \qquad\text{i.e.}\qquad
N \;\ge\; \frac{b^L}{L \log_b b} \cdot \log_b 2 \cdot \frac{1}{1}
\;=\; \frac{b^L}{L\,\log_2 b}.$$
For Borges' $b=25$, $L=1{,}312{,}000$, a complete sub-collection index requires
$$N \;\ge\; \frac{25^{1{,}312{,}000}}{1{,}312{,}000 \times \log_2 25}$$
volumes — a catalog nearly as large as the library itself. The "single universal
catalog of individual volumes" (Theorem 2) is consistent and real; the
impossibility appears only for *sub-collections*.

## 7. Algorithms

**Algorithm A (de Bruijn catalog construction via Eulerian circuit).** To build a
single-volume catalog $B(b,n)$ of all length-$n$ addresses: form the de Bruijn
graph on the $b^{n-1}$ length-$(n-1)$ nodes with one edge per length-$n$ address;
since every node has equal in- and out-degree $b$, an Eulerian circuit exists;
traverse it, emitting one symbol per edge, to produce the optimal length-$b^n$
catalog. For $(b,n)=(4,2)$ this yields the witness of Definition 4. Complexity:
linear in the output length $b^n$ (Hierholzer's algorithm).

**Algorithm B (distributed catalog feasibility test).** Given $b, L, N$, decide
whether a complete sub-collection catalog fits in $N$ volumes by checking
$2^{(b^L)} \le (b^L)^N$, equivalently the overflow-safe logarithmic test
$b^L \log 2 \le N L \log b$. Complexity: $O(1)$ arithmetic on the logarithms.

**Algorithm C (universal catalog encode/decode).** To convert between an address
$a \in \{0,\ldots,b^L-1\}$ and a volume, write $a$ in base $b$ (decode) or read the
volume's symbols as base-$b$ digits (encode). Complexity: $O(L)$ digit operations.

## 8. Applications and Discussion

The Library is a clean model of any *universal information space*: the set of all
files of a fixed size, all images of a fixed resolution, all genomes of a fixed
length. The results carry over verbatim. Generation is free — every possible
artifact already exists as a string. The scarce resource is the **catalog**, and
our theorems quantify exactly how scarce: addresses are cheaply and optimally
catalogable (de Bruijn, Theorem 6), but *contents* — the power set of artifacts —
are not catalogable in any single artifact (Theorem 10) and cost a near-complete
duplicate library to catalog at all (Theorem 11). The probability layer (Theorem
3b) explains the search experience inside such a space: any specific structured
target is exponentially rare per location, yet a sufficiently long medium offers
linearly many locations, recovering the heuristic $|T|\cdot b^{-k}$.

## 9. Future Work

See the Future Directions for the full program; in brief: (FD-1) a polynomial-time
*constructive* distributed encoder via base-$b$ bit-packing, replacing the
non-constructive embedding of Theorem 11; (FD-2) generality and counting of de
Bruijn catalogs via Euler's theorem and the BEST theorem; (FD-3) strict-majority
incompressibility densities; (FD-4) the catalog-of-catalogs hierarchy and its
iterated-exponential storage growth.

## 10. Conclusion

We have charted the Library of Babel with exact mathematics: it is finite ($b^L$,
Theorem 1), perfectly indexable by address (Theorem 2, Theorem 6), governed by a
sharp meaning-finding probability $(L-k+1)b^{-k}$ (Theorems 3a–3b), and bounded by
a Cantor wall for content-cataloging (Theorem 10) that only a distributed catalog
crossing the exact threshold $2^{(b^L)} \le (b^L)^N$ can scale (Theorem 11). In a
universe where every text exists, the map — not the territory — is the hardest
thing to make.
