# Combinatorics of the Universal Library: Population, Meaning-Density, Cataloging Limits, and Optimal Code Tours

## Abstract

The *universal library* over an alphabet of size $A$ and book length $L$
is the set $\mathcal{L}(A,L)$ of all strings of length $L$ over the
alphabet — a finite but astronomically large space that formalizes
Borges' Library of Babel. We establish four exact combinatorial facts
about this space and draw out their consequences for search, information,
and cataloging. First, the population is exactly $A^{L}$. Second, the
fraction of volumes containing a fixed passage of length $m$ is at most
$(L-m+1)A^{-m}$, with the correct polynomial prefactor being the number
of placements $L-m+1$ rather than the passage length. Third, no single
volume can serve as a complete catalog of the library, because the number
of possible catalogs $2^{A^{L}}$ strictly exceeds the number of volumes
$A^{L}$ for all $A\ge 2$, $L\ge 1$; equivalently, the library is
locatable but never self-locating. Fourth, a complete distributed catalog
exists if and only if it has at least $A^{L}$ entries, so the minimum
complete catalog is exactly as large as the library. Finally, we show
that the shortest single volume exhibiting every length-$k$ code exactly
once has length precisely $A^{k}+k-1$, the de Bruijn length, and any
volume of length $\ge A^{k}+k$ must repeat a code. We give algorithms,
numerical demonstrations for a toy library ($A=4$, $L=16$), and discuss
connections to cryptographic key search, diagonalization, and de Bruijn
constructions.

**Keywords:** universal library, combinatorics on words, de Bruijn
sequence, diagonal argument, union bound, distributed catalog,
information density, cryptographic search space.

---

## 1. Introduction

In his 1941 story *The Library of Babel*, Jorge Luis Borges imagined a
library containing every possible book of a fixed format: $410$ pages,
$40$ lines per page, $80$ characters per line, over an alphabet of $25$
orthographic symbols. Every arrangement of characters exists exactly
once. The library is finite — there are about $25^{1{,}312{,}000}$
volumes — yet it contains every truth and every falsehood ever
expressible in its format, drowned in a vastly larger sea of nonsense.

This paper treats the Library as a mathematical object and proves a small
number of exact combinatorial theorems that capture its essential
tensions: totality versus searchability, and organization versus
self-reference. Our contributions are:

1. **Population (Section 3).** The library has exactly $A^{L}$ volumes.
2. **Meaning-density (Section 4).** A fixed passage of length $m$ occupies
   at most a $(L-m+1)A^{-m}$ fraction of volumes; the governing prefactor
   is the placement count, not the passage length.
3. **Self-cataloging impossibility (Section 5).** Since
   $A^{L}<2^{A^{L}}$, no single volume encodes a complete catalog; the
   library is locatable but not self-locating.
4. **Distributed catalog threshold (Section 6).** A complete distributed
   catalog exists iff it has $\ge A^{L}$ entries; the minimum is exactly
   $A^{L}$.
5. **Optimal code tour (Section 7).** The shortest volume exhibiting
   every length-$k$ code exactly once has length $A^{k}+k-1$.

Throughout, $A\ge 2$ is the alphabet size and $L\ge 1$ the book length.
We use $\Sigma$ for the alphabet, $|\Sigma|=A$.

### 1.1 Historical and mathematical context

Borges' fiction has long been read as a metaphor for total knowledge, but
its mathematical content is precise and modern. The universal library is
nothing other than the free monoid $\Sigma^{*}$ restricted to a fixed
length, and the questions we ask about it belong to *combinatorics on
words*, a field concerned with the structure of finite and infinite
sequences over a finite alphabet. The occurrence of a fixed factor
(subword) in a random word, the subword complexity of a word (the number
of distinct factors of each length it contains), and the extremal words
that realize maximal subword complexity are all classical themes; the de
Bruijn sequence is their sharpest incarnation.

The cataloging questions, by contrast, are set-theoretic and
information-theoretic. That a set cannot be put in bijection with its own
power set is Cantor's theorem; our Theorem 5.1 is its finite,
quantitative shadow, $n<2^{n}$. The distributed-catalog threshold is the
counting principle underlying the pigeonhole bound and, ultimately,
Shannon's source-coding theorem: distinguishing $M$ objects requires at
least $M$ codewords, or equivalently $\log_{A} M$ symbols per object when
block codes are used. Placing all of these classical facts inside a
single, vivid object — the library of all books — is the organizing idea
of this paper.

We emphasize that every result below is *exact*: no asymptotics are
hidden in the main theorems (only Remark 4.3 and Conjecture 9.1 concern
limiting sharpness). This exactness is what lets the toy library
($A=4$, $L=16$) serve as a faithful, fully computable microcosm of
Borges' unfathomable original.

---

## 2. Definitions

**Definition 2.1 (Universal library).** Fix a finite alphabet $\Sigma$
with $|\Sigma| = A \ge 2$ and a length $L \ge 1$. The *universal library*
is
$$\mathcal{L}(A,L) = \Sigma^{L} = \{\, v : \{1,\dots,L\}\to\Sigma \,\},$$
the set of all functions (equivalently, strings) assigning a symbol to
each of the $L$ positions. Its elements are *volumes*.

**Definition 2.2 (Occurrence and placement).** Let $w\in\Sigma^{m}$ with
$1\le m\le L$ be a *passage*. A *placement* of $w$ in a volume of length
$L$ is a starting index $i\in\{1,\dots,L-m+1\}$. A volume $v$ *contains*
$w$ at placement $i$ if $v_{i+j-1}=w_{j}$ for all $j\in\{1,\dots,m\}$. We
say $v$ *contains* $w$ if it contains $w$ at some placement.

**Definition 2.3 (Catalog).** A *catalog* of the library is a rule that
identifies volumes. We distinguish two forms:

- A *single-volume catalog* is an injection $c:\mathcal{L}(A,L)\to\Sigma^{L}$
  encoding each volume by one volume-sized code. (It is impossible; see
  Section 5.)
- A *distributed catalog with $N$ entries* is a function
  $g:\{1,\dots,N\}\to\mathcal{L}(A,L)$; it is *complete* if $g$ is
  surjective, i.e., every volume receives at least one entry.

**Definition 2.4 (Length-$k$ code and code tour).** A *length-$k$ code*
is any string in $\Sigma^{k}$. A volume $v$ of length $\ell$ *exhibits* a
code $u\in\Sigma^{k}$ if $u$ occurs in $v$. A *complete code tour* of
order $k$ is a volume exhibiting every code in $\Sigma^{k}$.

**Definition 2.5 (de Bruijn sequence).** A *de Bruijn sequence* of order
$k$ over $\Sigma$ is a cyclic string of length $A^{k}$ in which every
length-$k$ code appears exactly once as a consecutive (cyclic) block.
Its linear expansion (repeating the first $k-1$ symbols at the end) has
length $A^{k}+k-1$.

For concreteness we frequently use the *toy library* $A=4$, $L=16$ (and
$k=2$ for tours), where $|\mathcal{L}| = 4^{16} = 4{,}294{,}967{,}296$.

---

## 3. Population of the library

**Theorem 3.1 (Population count).** $|\mathcal{L}(A,L)| = A^{L}$.

*Proof.* A volume is a function from an $L$-element index set to an
$A$-element alphabet. The number of such functions is $A^{L}$ by the
multiplication principle: each of the $L$ positions is filled
independently with one of $A$ symbols. $\square$

**Corollary 3.2.** For Borges' parameters $A=25$, $L=1{,}312{,}000$, the
population is $25^{1312000}$, a number with $\lfloor 1312000\log_{10}25
\rfloor + 1 = 1{,}834{,}098$ decimal digits. For the toy library,
$|\mathcal{L}(4,16)| = 4{,}294{,}967{,}296 = 2^{32}$.

This elementary count is the denominator of every probability below and
the target size of every cataloging bound.

---

## 4. Meaning-density: how often a passage appears

We now bound the fraction of volumes containing a fixed passage. This is
the mathematical form of "how rare is a given piece of meaning?"

**Theorem 4.1 (Meaning-density upper bound).** Let $w\in\Sigma^{m}$ with
$1\le m\le L$. Let $P(w)$ be the fraction of volumes in $\mathcal{L}(A,L)$
that contain $w$. Then
$$P(w) \;\le\; (L-m+1)\,A^{-m}.$$

*Proof.* For each placement $i\in\{1,\dots,L-m+1\}$ let $E_i$ be the event
(subset of volumes) "$v$ contains $w$ at placement $i$." Fixing the $m$
symbols at positions $i,\dots,i+m-1$ and leaving the remaining $L-m$
positions free, we count $|E_i| = A^{L-m}$ volumes, so
$\Pr[E_i] = A^{L-m}/A^{L} = A^{-m}$. The event "$v$ contains $w$" is
$\bigcup_{i} E_i$. By the union bound,
$$P(w) = \Pr\!\Big[\bigcup_{i=1}^{L-m+1} E_i\Big] \;\le\;
\sum_{i=1}^{L-m+1}\Pr[E_i] = (L-m+1)\,A^{-m}. \qquad\square$$

**Remark 4.2 (The prefactor is the placement count).** The polynomial
factor is $L-m+1$, the number of placements $w$ may occupy, *not* the
passage length $m$ as a superficial reading of the folklore estimate
"$|w|\cdot A^{-|w|}$" might suggest. The exponential factor $A^{-m}$
depends only on the passage length, so lengthening the *book* helps only
linearly while lengthening the *target* hurts exponentially.

**Remark 4.3 (Sharpness).** The union bound overcounts volumes containing
$w$ at more than one placement. Because distinct placements overlap only
in a controlled way, the over-count is a lower-order term: as $L\to\infty$
with $m$ fixed, one expects
$P(w) = (L-m+1)A^{-m}\big(1+O(m\,A^{-m})\big)$, so the bound is
asymptotically tight. A matching lower bound follows from
inclusion–exclusion on overlapping windows; we record this refinement as
a conjecture in Section 9.

**Example 4.4.** In the toy library ($A=4$, $L=16$), a fixed passage of
length $m=4$ satisfies $P(w)\le (16-4+1)\cdot 4^{-4} = 13/256\approx
0.0508$. Direct enumeration of all $4^{16}$ volumes (Section 8) confirms
the true value is slightly below this, as predicted by Remark 4.3. For
Borges' library, a fixed $50$-character sentence has
$P(w)\le 1{,}311{,}951\cdot 25^{-50}\approx 1.8\times 10^{-64}$.

---

## 5. The library cannot catalog itself

**Theorem 5.1 (No self-cataloging single volume).** For all $A\ge 2$ and
$L\ge 1$, the number of possible catalogs strictly exceeds the number of
volumes:
$$A^{L} \;<\; 2^{A^{L}}.$$
Consequently there is no injection from the set of all *catalogs*
(sub-collections of the library) into the set of volumes, and in
particular no single volume can encode a complete list of the library.

*Proof.* A *catalog* in the broadest sense is a choice of which volumes to
mark, i.e., a subset of $\mathcal{L}(A,L)$; there are $2^{|\mathcal{L}|} =
2^{A^{L}}$ of these. The volumes themselves number $A^{L}$. For every
natural number $n\ge 1$ we have $n < 2^{n}$ (immediate by induction:
$1<2$, and $n<2^{n}\Rightarrow n+1\le 2n\le 2^{n+1}$). Taking
$n = A^{L}\ge 1$ gives $A^{L} < 2^{A^{L}}$. Hence no injection from
catalogs to volumes exists (an injection would force $2^{A^{L}}\le
A^{L}$), so no scheme assigns a distinct volume-code to every possible
catalog; in particular the specific catalog "the complete list of all
volumes" cannot be faithfully carried by one volume, whose $A^{L}$
possible contents cannot distinguish the $2^{A^{L}}$ catalogs it would
need to represent. $\square$

**Interpretation 5.2 (Locatable but not self-locating).** The library
admits a location scheme — one can, in principle, address any volume — but
no member of the library can hold the scheme for all members. This is a
finite, quantitative sibling of Cantor's theorem $|S| < |2^{S}|$ and the
combinatorial kernel behind self-reference obstructions such as Gödel
incompleteness and the undecidability of halting: a system cannot fully
encode its own totality.

---

## 6. Distributed catalogs: the exact threshold

If no single volume suffices, spread the catalog across many entries.

**Theorem 6.1 (Distributed catalog threshold).** A complete distributed
catalog of $\mathcal{L}(A,L)$ with $N$ entries exists if and only if
$N \ge A^{L}$. The minimum number of entries in a complete distributed
catalog is exactly $A^{L}$.

*Proof.* A complete distributed catalog is a surjection
$g:\{1,\dots,N\}\to\mathcal{L}(A,L)$. A surjection from an $N$-element set
onto an $M$-element set exists if and only if $N\ge M$ (necessity: the
image has at most $N$ elements, so $M\le N$; sufficiency: enumerate the
$M$ targets by the first $M$ indices and send the remaining $N-M$ indices
anywhere). With $M=A^{L}$ this gives existence iff $N\ge A^{L}$, and the
least such $N$ is $A^{L}$. $\square$

**Interpretation 6.2 (No lossless compression of totality).** The
smallest complete guide is exactly as large as the library itself: one
catalog entry per volume, no fewer. There is no lossless directory of the
space smaller than the space. This is the combinatorial face of the
pigeonhole/counting bound underlying lossless source coding: a code that
distinguishes all $A^{L}$ objects needs $A^{L}$ codewords.

---

## 7. The optimal single-volume code tour

We turn to the one place where dramatic economy *is* possible: packing
every short code into one volume.

**Theorem 7.1 (Subword-complexity ceiling).** A volume of length $\ell$
contains at most $\ell - k + 1$ distinct length-$k$ codes. Hence a
complete code tour of order $k$ has length $\ell \ge A^{k}+k-1$.

*Proof.* A length-$\ell$ volume has exactly $\ell-k+1$ windows of width
$k$, so it exhibits at most $\ell-k+1$ distinct codes. To exhibit all
$A^{k}$ codes we need $\ell-k+1\ge A^{k}$, i.e. $\ell\ge A^{k}+k-1$.
$\square$

**Theorem 7.2 (de Bruijn attainment).** For every $A\ge 2$ and $k\ge 1$
there exists a volume of length exactly $A^{k}+k-1$ that exhibits every
length-$k$ code exactly once. This is the linear expansion of a de Bruijn
sequence of order $k$.

*Proof sketch.* Form the de Bruijn graph $B(A,k)$ whose vertices are the
$A^{k-1}$ codes of length $k-1$ and whose edges are the $A^{k}$ codes of
length $k$, each edge $u\to v$ connecting the length-$(k-1)$ prefix of a
$k$-code to its length-$(k-1)$ suffix. Every vertex has in-degree and
out-degree $A$, so the graph is connected and Eulerian. An Eulerian
circuit traverses each edge (each $k$-code) exactly once; reading off the
symbols along the circuit and appending the first $k-1$ symbols yields a
linear string of length $A^{k}+k-1$ containing every $k$-code exactly
once. $\square$

**Theorem 7.3 (Pigeonhole collision threshold).** Any volume of length
$\ell \ge A^{k}+k$ contains a repeated length-$k$ code.

*Proof.* Such a volume has $\ell-k+1\ge A^{k}+1$ windows of width $k$ but
only $A^{k}$ possible codes; by the pigeonhole principle two windows carry
the same code. $\square$

**Corollary 7.4 (Extremal characterization).** The de Bruijn length
$A^{k}+k-1$ is simultaneously the *minimum* length of a complete code tour
(Theorem 7.1) and one below the *threshold* forcing a repeat (Theorem
7.3). The subword-complexity ceiling and the pigeonhole floor meet at the
same extremal object.

**Example 7.5.** For the toy alphabet $A=4$, order $k=2$: there are
$4^{2}=16$ codes, and a de Bruijn volume of length $4^{2}+2-1 = 17$
exhibits all $16$ ordered pairs exactly once. One such linear string is
`0 0 1 0 2 0 3 1 1 2 1 3 2 2 3 3 0` (symbols in $\{0,1,2,3\}$), whose $16$
consecutive pairs are all distinct and cover every pair including the
wrap-around `3 0` and `0 0`.

---

## 8. Algorithms

We describe three algorithms; full type-hinted implementations accompany
this paper.

**Algorithm A — Meaning-density estimator.** Given $A$, $L$, and a target
passage $w$ of length $m$, return the exact bound $(L-m+1)A^{-m}$ and,
for small parameters, the true fraction by enumeration. The bound is
$O(1)$ arithmetic on big integers; the exact enumeration is
$O(A^{L}\cdot L)$ and is used only to validate the bound on the toy
library.

**Algorithm B — de Bruijn tour constructor.** Given $A$ and $k$, build the
de Bruijn graph on $(k-1)$-codes, compute an Eulerian circuit by
Hierholzer's algorithm in $O(A^{k})$ time, and expand it to a linear
volume of length $A^{k}+k-1$. Verify optimality by checking that all
$A^{k}$ codes occur exactly once.

**Algorithm C — Catalog threshold reporter.** Given $A$ and $L$, report
the population $A^{L}$, the catalog surplus $2^{A^{L}}/A^{L}$ (as an exact
big-integer ratio for small parameters, or its logarithm for large), and
the minimum distributed-catalog size $A^{L}$, confirming the strict
inequality $A^{L}<2^{A^{L}}$.

---

## 9. Conjectures and future directions

**Conjecture 9.1 (Tight meaning-density).** For fixed $m$ as $L\to\infty$,
$$P(w) = (L-m+1)A^{-m}\big(1+O(m\,A^{-m})\big),$$
so the union bound of Theorem 4.1 is asymptotically tight. The proof
requires a matching lower bound via inclusion–exclusion over overlapping
placement windows, now a finite computation rather than a heuristic.

**Conjecture 9.2 (Doubly-exponential catalog surplus).** For all $A\ge 2$,
$L\ge 1$ the catalog surplus is $2^{A^{L}}/A^{L}$, no injective
self-cataloging scheme exists, and a surjective distributed catalog exists
for every $N\ge A^{L}$ with minimum $N=A^{L}$. The remaining work is to
establish monotonicity of the surplus in both $A$ and $L$.

**Conjecture 9.3 (de Bruijn optimality).** The shortest single volume
exhibiting every length-$k$ code exactly once has length exactly
$A^{k}+k-1$, and any volume of length $\ge A^{k}+k$ repeats a code — the
subword-complexity ceiling $A^{k}$ and the pigeonhole threshold $A^{k}+k$
are two faces of the same extremal object.

---

## 10. Applications and discussion

**Cryptographic search.** The meaning-density bound is exactly the
difficulty of key search: a secret of $m$ symbols hides in a space of
size $A^{m}$, and Theorem 4.1 shows book-length padding gives only a
linear advantage against an exponential wall. Finding a fixed passage in a
random volume *is* guessing a key.

**Diagonalization and self-reference.** Theorem 5.1 is a finite,
quantitative instance of $|S|<|2^{S}|$. The impossibility of a
self-cataloging volume is the same phenomenon that forbids a program from
deciding its own totality, linking the Library to Gödel and Turing.

**Lossless coding.** Theorem 6.1 is the counting bound behind lossless
compression: no directory that distinguishes all objects can be smaller
than the collection of objects.

**Engineering with de Bruijn tours.** Theorem 7.2's construction is used
in practice: de Bruijn sequences crack combination locks with minimal
input, encode absolute rotary position sensors, design overlapping
oligonucleotide assays, and underlie fast substring-indexing structures.

The Library of Babel thus condenses four pillars of the theory of
information into one image: totality is cheap to define but expensive to
search; self-description is impossible; complete indexing costs the whole
space; and only the humblest task — touring every short code once — admits
a perfectly economical solution.

### 10.1 A worked comparison of the four regimes

It is instructive to line up the four theorems as statements about a
single quantity: the number of symbols one must read, write, or store to
accomplish a task in the library.

- **To name one volume** costs $L$ symbols — the volume is its own name.
- **To find one fixed passage** of length $m$ costs, in expectation,
  on the order of $A^{m}/(L-m+1)$ random volumes examined, by inverting
  Theorem 4.1. The cost is exponential in the passage length and only
  mildly discounted by book length.
- **To catalog the whole library from within** costs *infinitely* many
  volumes in the sense that it is impossible: Theorem 5.1 shows the task
  has no single-volume solution at all.
- **To catalog the whole library as a distributed structure** costs
  exactly $A^{L}$ entries — the full population, by Theorem 6.1.
- **To exhibit every short code once** costs only $A^{k}+k-1$ symbols by
  Theorem 7.2, a saving of a factor of nearly $k$ over the naive
  $k\cdot A^{k}$ concatenation.

The pattern is stark: naming and short-code enumeration are cheap;
searching is exponentially expensive; and total self-cataloging is
impossible while total distributed cataloging is maximally expensive.
The library rewards modesty of goal and punishes ambition of scope.

### 10.2 On randomness and meaning

A philosophical corollary of Theorem 4.1 deserves statement. In a
library that contains every text, the *information* in a volume is not in
its contents — all contents are equally present — but in its *address*.
Locating the one volume you want is exactly as hard as specifying it from
scratch, because the address of a volume containing a target passage of
length $m$ must itself carry roughly $m\log_{2}A$ bits of information to
pin down the passage. This is the precise sense in which the library,
though it contains all meaning, contains no *free* meaning: extracting a
signal costs exactly as much as creating it. It is the same accounting
that makes one-time pads unbreakable and brute-force key search hopeless.

---

## 11. Conclusion

We have given exact combinatorial theorems governing the universal
library: its population $A^{L}$; the meaning-density bound
$(L-m+1)A^{-m}$ with the placement count as prefactor; the strict
inequality $A^{L}<2^{A^{L}}$ forbidding a self-cataloging volume; the
exact distributed-catalog threshold $A^{L}$; and the de Bruijn length
$A^{k}+k-1$ as the optimal complete code tour. Together they turn Borges'
metaphor into a precise account of the limits and possibilities of
universal information spaces.
