# Forced Structure in Symbolic Sequences: Pigeonhole and Ramsey Thresholds for Genetic Codes

## Abstract

We study two complementary "forcing" phenomena for finite sequences over a
finite alphabet, motivated by the combinatorics of genetic codes over the
four-letter nucleotide alphabet $\{A, C, G, T\}$. The first is a *linear*
threshold: sliding a length-$m$ window along a sequence over a $q$-symbol
alphabet, once strictly more than $q^m$ window positions are examined, two must
carry the same contiguous block ($m$-mer). We prove this pigeonhole threshold,
its extremal converse (a repeat-free sequence exposes at most $q^m$ windows), a
sharp non-injectivity statement, and a count of the number of distinct $m$-mers.
We specialize to DNA ($q = 4$), obtaining the exact constants: any $257$
consecutive windows contain a repeated tetramer, any $4097$ contain a repeated
hexamer (equivalently $L \geq 4102$ raw bases), and a tetramer-repeat-free block
spans at most $259$ bases. The second phenomenon is *relational*: we prove the
classical Ramsey bound $R(3,3) \leq 6$ — every symmetric two-coloring of the
complete graph on six vertices contains a monochromatic triangle — via a
two-level pigeonhole argument, and read it as forced consistency under pairwise
comparison of genetic loci. Together these results give a two-sided,
constant-explicit account of unavoidable structure in symbolic sequences.

**Keywords.** Pigeonhole principle, Ramsey theory, de Bruijn sequences,
$k$-mers, genetic codes, extremal combinatorics, monochromatic triangle.

## 1. Introduction

A genome is a finite word over the alphabet $\Sigma = \{A, C, G, T\}$ of the four
nucleotides. Repetition of short subwords is ubiquitous in genomes, and a
central question in genomic combinatorics is how much of that repetition is
*biologically authored* and how much is *combinatorially forced*: a consequence
of the finiteness of the space of possible blocks rather than of any biological
process.

This paper isolates the forced component with exact constants. We work in the
setting of Ramsey theory, whose organizing principle is that sufficiently large
combinatorial structures necessarily contain highly ordered substructures. Two
instances are developed:

1. **Block-repetition thresholds (linear forcing).** Over a $q$-letter alphabet
   there are only $q^m$ distinct length-$m$ blocks, so a sliding window cannot
   keep producing fresh blocks indefinitely. We make the threshold precise and
   prove it is sharp, recovering the extremal content of de Bruijn sequences.

2. **The Ramsey threshold $R(3,3) \leq 6$ (relational forcing).** Any binary
   symmetric relation on six objects, viewed as a two-coloring of pair
   comparisons, contains a monochromatic triangle.

We give full statements and proof sketches for all results, DNA specializations
with exact numeric constants, and a discussion connecting the thresholds to the
distinction between forced and authored repetition in real genomes.

## 2. Definitions

Throughout, an *alphabet of size $q$* is modeled by the set
$\{0, 1, \dots, q-1\}$, and a (bi-infinite, one-sided) *sequence* is a function
$w : \mathbb{N} \to \{0, \dots, q-1\}$ assigning to each position a symbol. For
DNA we take $q = 4$ with the identification $A = 0$, $C = 1$, $G = 2$, $T = 3$.

**Definition 2.1 (m-mer / window).** For a sequence $w$ and integers
$m, i \geq 0$, the *length-$m$ block* (or *$m$-mer*, or *window*) starting at
position $i$ is the tuple
$$\mathrm{mer}(w, m, i) = \big(w(i),\, w(i+1),\, \dots,\, w(i+m-1)\big),$$
an element of the set $\Sigma^m$ of functions from $\{0, \dots, m-1\}$ to the
alphabet. The set $\Sigma^m$ has exactly $q^m$ elements.

**Definition 2.2 (repeat-free / injective windows).** A sequence $w$ is
*$m$-repeat-free on the first $N$ windows* if the map
$$i \mapsto \mathrm{mer}(w, m, i), \qquad i \in \{0, 1, \dots, N-1\},$$
is injective; equivalently, the $m$-mers at positions $0, \dots, N-1$ are
pairwise distinct.

## 3. Linear forcing: the block-repetition threshold

### 3.1 The pigeonhole threshold

**Theorem 3.1 (Pigeonhole threshold for repeated blocks).** *Let $w$ be a
sequence over an alphabet of size $q$, and let $m, N$ be integers with
$q^m < N$. Then there exist distinct positions $i \neq j$ in $\{0, \dots, N-1\}$
with $\mathrm{mer}(w, m, i) = \mathrm{mer}(w, m, j)$.*

*Proof sketch.* Consider the map $\Phi : \{0, \dots, N-1\} \to \Sigma^m$ defined
by $\Phi(i) = \mathrm{mer}(w, m, i)$. The domain has $N$ elements and the
codomain has $|\Sigma^m| = q^m$ elements. Since $q^m < N$, the codomain is
strictly smaller than the domain, so $\Phi$ cannot be injective. Hence there
exist $i \neq j$ with $\Phi(i) = \Phi(j)$, which is the claimed repeated
$m$-mer. $\qquad\blacksquare$

### 3.2 The extremal converse and sharpness

**Theorem 3.2 (Extremal converse).** *If $w$ is $m$-repeat-free on the first $N$
windows, then $N \leq q^m$.*

*Proof sketch.* Repeat-freeness means $\Phi : \{0, \dots, N-1\} \to \Sigma^m$ is
injective. An injection cannot have a domain larger than its codomain, so
$N = |\{0, \dots, N-1\}| \leq |\Sigma^m| = q^m$. $\qquad\blacksquare$

Theorems 3.1 and 3.2 are logically dual and together pin the threshold exactly:
$q^m$ windows can be repeat-free, but $q^m + 1$ cannot. We record the
contrapositive packaging explicitly.

**Corollary 3.3 (Sharp non-injectivity).** *If $q^m < N$, then $w$ is not
$m$-repeat-free on the first $N$ windows.*

*Proof sketch.* If it were repeat-free, Theorem 3.2 would give $N \leq q^m$,
contradicting $q^m < N$. $\qquad\blacksquare$

That the bound $N \leq q^m$ is attained (not merely an upper estimate) is the
content of de Bruijn sequences: for every $q$ and $m$ there is a cyclic word of
length $q^m$ in which every one of the $q^m$ blocks occurs exactly once, so all
$q^m$ windows are distinct. Thus $q^m$ is the exact maximum number of repeat-free
windows.

### 3.3 Counting distinct blocks

**Theorem 3.4 (Distinct-block count).** *For any sequence $w$ and any $m, N$, the
number of distinct $m$-mers occurring among the first $N$ window positions is at
most $\min(N,\, q^m)$.*

*Proof sketch.* The set of distinct $m$-mers observed is the image of $\Phi$
restricted to $\{0, \dots, N-1\}$. The image of a map has cardinality at most the
size of its domain, giving the bound $\leq N$; and it is a subset of $\Sigma^m$,
giving the bound $\leq q^m$. The number of distinct blocks is therefore at most
the smaller of the two, $\min(N, q^m)$. $\qquad\blacksquare$

### 3.4 DNA specializations ($q = 4$)

Evaluating the above at $q = 4$ yields exact constants for nucleotide sequences,
using $4^4 = 256$ and $4^6 = 4096$.

**Theorem 3.5 (Repeated tetramer).** *Any $257$ consecutive window positions of a
nucleotide sequence contain a repeated $4$-mer.*

*Proof sketch.* Apply Theorem 3.1 with $q = 4$, $m = 4$, $N = 257$; the
hypothesis is $4^4 = 256 < 257$. $\qquad\blacksquare$

**Theorem 3.6 (Repeated hexamer, corrected constant).** *Any $4097$ consecutive
window positions of a nucleotide sequence contain a repeated $6$-mer.*

*Proof sketch.* Apply Theorem 3.1 with $q = 4$, $m = 6$, $N = 4097$; the
hypothesis is $4^6 = 4096 < 4097$. $\qquad\blacksquare$

**Remark 3.7 (The window-count correction).** A raw sequence of length $L$
contains only $L - m + 1$ full length-$m$ windows. Consequently the constant in
Theorem 3.6 corresponds to a raw-length requirement of $L - 6 + 1 \geq 4097$,
i.e. $L \geq 4102$ bases, not the frequently quoted "$4097$ nucleotides." The
naive slogan omits the $m - 1$ boundary positions that cannot start a full
window.

**Theorem 3.8 (de Bruijn length bound for tetramers).** *If a nucleotide
sequence is $4$-repeat-free on the first $N$ windows, then $N \leq 256$; hence the
underlying block spans at most $256 + 3 = 259$ bases.*

*Proof sketch.* Apply Theorem 3.2 with $q = 4$, $m = 4$, giving $N \leq 4^4 =
256$. The $+3$ converts a window count to a raw-base span via the $m - 1 = 3$
boundary positions. $\qquad\blacksquare$

## 4. Relational forcing: the Ramsey threshold $R(3,3) \leq 6$

We now turn from a single sequence to pairwise comparisons among a family of
objects. Model six objects as vertices $\{0, 1, 2, 3, 4, 5\}$ and a binary
symmetric comparison as a coloring $c$ assigning to each unordered pair
$\{i, j\}$ a Boolean color, with $c(i,j) = c(j,i)$ (symmetry). We interpret the
two colors as "same similarity class" and "different similarity class."

**Lemma 4.1 (Local pigeonhole).** *Among any five Boolean-colored items, at least
three share a color: for any $f : \{0, 1, 2, 3, 4\} \to \{\text{true},
\text{false}\}$ there is a color $x$ and three distinct indices $a, b, d$ with
$f(a) = f(b) = f(d) = x$.*

*Proof sketch.* Five items are split into two color classes; if both classes had
at most two items, they would total at most four, contradicting five. Hence some
class contains at least three items. (This is a finite statement over
$2^5 = 32$ colorings and can be verified by exhaustive case check.)
$\qquad\blacksquare$

**Theorem 4.2 (Ramsey $R(3,3) \leq 6$).** *For any symmetric two-coloring $c$ of
the pairs among six vertices, there exist three distinct vertices $a, b, d$ whose
three mutual comparisons all share one color:
$c(a,b) = c(a,d) = c(b,d)$.*

*Proof sketch.* Fix the vertex $0$. Its five incident edges $c(0, k)$ for
$k \in \{1, \dots, 5\}$ are colored by two colors, so by Lemma 4.1 three of them,
to vertices $a, b, d$, share a color $x$; thus $c(0,a) = c(0,b) = c(0,d) = x$.
Now inspect the three edges among $a, b, d$:

- If any one of $c(a,b), c(a,d), c(b,d)$ equals $x$, that edge together with the
  two $x$-colored edges from $0$ forms a monochromatic triangle of color $x$
  (using $0$ and the two relevant vertices).
- Otherwise all three edges $c(a,b), c(a,d), c(b,d)$ carry the color opposite to
  $x$, and then $\{a, b, d\}$ is itself a monochromatic triangle.

In every case a monochromatic triangle exists. $\qquad\blacksquare$

**Remark 4.3 (A genuine universal statement).** Theorem 4.2 quantifies over all
symmetric colorings — a space of size $2^{\binom{6}{2}} = 2^{15} = 32768$ — and
the argument is structural (two nested pigeonhole steps plus the Boolean
dichotomy on the inner triangle), not brute enumeration. It is the exact
combinatorial core of the classical identity $R(3,3) = 6$; the matching lower
bound $R(3,3) > 5$ is witnessed by the well-known triangle-free two-coloring of
the pairs among five vertices (the pentagon/pentagram coloring).

**Genetic reading.** If six loci are compared pairwise under a binary similarity
relation, three of them are forced to be mutually consistent — a *forced motif*
no arrangement can avoid. This is the relational analogue of the linear
block-repetition forcing of Section 3.

## 5. Algorithms

The proofs are constructive and translate directly into algorithms.

**Algorithm A (First repeated $m$-mer).** Slide a width-$m$ window along the
sequence, hashing each block into a dictionary that maps blocks to their first
seen starting position. On the first collision, return the two positions. By
Theorem 3.1 a collision must occur within the first $q^m + 1$ windows, so the
loop terminates after at most $q^m + 1$ iterations; each iteration is $O(m)$ to
form the block (or $O(1)$ with a rolling hash), for total time $O(m \cdot q^m)$
in the worst case and $O(1)$ additional space per stored block.

**Algorithm B (Distinct-block growth curve).** Maintain a running set of blocks
seen and, at each window position $N$, record the current number of distinct
$m$-mers. By Theorem 3.4 this curve is bounded above by $\min(N, q^m)$ and (for
sufficiently structured input) plateaus at the saturation value; the plateau
onset localizes the transition from novelty to forced repetition.

**Algorithm C (Monochromatic triangle finder).** Given the symmetric color
matrix on six vertices, fix vertex $0$, bucket its five neighbors by edge color,
select a color with at least three neighbors $\{a, b, d\}$ (guaranteed by Lemma
4.1), and test the three edges among them; return either the triangle through
vertex $0$ or the triangle $\{a, b, d\}$ per the case analysis of Theorem 4.2.
This runs in $O(1)$ time on six vertices and $O(n^2)$ on $n$ vertices via the
same fixed-vertex reduction.

## 6. Applications

- **Baselines for genomic repeat analysis.** Theorem 3.1 gives the exact window
  count beyond which repetition is unavoidable. Repeats appearing earlier than
  $q^m$ windows are candidates for biological structure (microsatellites, mobile
  elements) rather than combinatorial inevitability.

- **Repeat-free code design.** Theorem 3.2 and the de Bruijn attainability
  bound quantify the maximum length of a synthetic sequence whose $m$-mers are
  all distinct — relevant to designing unique molecular barcodes and primer sets.

- **Consistency motifs in comparison data.** Theorem 4.2 guarantees a consistent
  triple in any binary pairwise-similarity dataset on six items, a structural
  fact usable as a sanity invariant in clustering and phylogenetic pre-processing.

## 7. Discussion

The two thresholds are two costumes for one idea. Linear repetition is forced by
a single pigeonhole on the window-to-block map; relational consistency is forced
by pigeonhole applied twice from the vantage of a single object. In both cases
there is a precise, computable threshold beyond which the ordered substructure is
not merely possible but certain.

A random four-letter sequence saturates the block space slowly, staying near the
de Bruijn extremal limit and requiring on the order of $q^m$ windows before
tetramer repeats accumulate. Real genomes, dense with low-complexity regions,
saturate substantially earlier — empirically several times faster — indicating
that a large share of genomic repetition is authored by biology rather than
dictated by counting. The thresholds proved here make this comparison
quantitative by supplying the exact combinatorial baseline.

## 8. Future Directions

- **Sharpness via de Bruijn saturation.** The extremal converse $N \leq q^m$ is
  an upper bound; matching it constructively requires an Eulerian circuit in the
  de Bruijn graph on $(m-1)$-mers, turning the extremal question into a
  graph-connectivity statement and yielding certified maximal repeat-free codes.

- **Counting monochromatic triangles.** Beyond existence, every symmetric
  two-coloring on six vertices plausibly contains at least two monochromatic
  triangles, with the count growing linearly as vertices are added — a
  Goodman-type refinement reachable by the same fixed-vertex method.

- **Subsequence (non-contiguous) thresholds.** For repeats among all ordered
  subsequences, the correct tool is a Dilworth / Erdős–Szekeres decomposition
  layered on the contiguous pigeonhole; the order of growth should remain
  exponential in $m$ but larger than the contiguous threshold by a polynomial
  factor.

- **Larger palettes.** For $r$ similarity classes, pairwise comparison of
  $R(3; r)$ loci should force a monochromatic triangle, with the fixed-vertex
  pigeonhole proof generalizing by replacing the Boolean dichotomy with an
  $r$-way pigeonhole in the inner step.

## 9. Conclusion

We have established, with exact constants, two forms of unavoidable structure in
symbolic sequences: a sharp linear threshold $q^m$ forcing repeated contiguous
blocks (with DNA constants $257$, $4097$/$4102$, and $259$), and the relational
Ramsey threshold $R(3,3) \leq 6$ forcing a monochromatic triangle under pairwise
comparison. Together they delineate precisely where the freedom of a genetic code
ends and the necessity of finite-alphabet arithmetic begins.
