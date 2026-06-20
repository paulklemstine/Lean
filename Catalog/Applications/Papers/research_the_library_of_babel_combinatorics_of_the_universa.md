# The Combinatorics of the Universal Library: Exact Counting and Occurrence Probabilities in the Library of Babel

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Novelty / Combinatorics of universal information spaces

---

## Abstract

Borges's *Library of Babel* is the set of all texts of a fixed length over a fixed
finite alphabet. We treat this object as a precise probability space and establish
its exact combinatorial structure. Modeling a **volume** as a function from
$L$ positions to a $b$-symbol alphabet, we prove that the library contains exactly
$b^{L}$ volumes, that under the uniform distribution each volume has probability
$b^{-L}$, and — our central results — that the **expected number of occurrences** of
a fixed length-$k$ pattern in a uniformly random volume is exactly $(L-k+1)\,b^{-k}$,
from which a union bound gives that the **probability a random volume contains the
pattern** is at most $(L-k+1)\,b^{-k}$. The engine is a counting lemma: the number of
volumes displaying a fixed pattern at $k$ prescribed positions is $b^{L-k}$. Applied
to Borges's parameters ($b=25$, $L=1\,312\,000$) the results quantify exactly the
sense in which the library is *complete* (every text is present) yet *practically
unsearchable* (any text is exponentially rare). We discuss the impossibility of a
single self-catalog by a counting (diagonal) argument, the distributed-catalog
threshold $N > b^{L}/(L\log_2 b)$, and the de Bruijn construction of compact pattern
catalogs for a tractable mini-library. All principal results have been formally
verified in the Lean 4 proof assistant.

---

## 1. Introduction

In *La biblioteca de Babel* (1941), Jorge Luis Borges describes a library whose
shelves hold every book of a fixed format: $410$ pages, $40$ lines per page, $80$
characters per line, drawn from an alphabet of $25$ orthographic symbols. The
library is thus the set of all strings of length $L = 410\cdot 40\cdot 80 =
1\,312\,000$ over a $25$-symbol alphabet. It is finite, and it contains every text
that can be written in the format — including every truth, every falsehood, and
every truth corrupted by a single typographical error.

The literary force of the parable is the tension between *completeness* and
*inaccessibility*. Mathematically, this tension is quantitative, and the goal of
this paper is to quantify it exactly. We ask three questions:

1. **Size.** How many volumes does the library contain, and what is the probability
   of any single volume?
2. **Occurrence.** Given a target pattern (a sentence, a proof) of length $k$, what
   is the expected number of times it occurs in a random volume, and the probability
   that it occurs at all?
3. **Cataloging.** Can a single volume index the entire library? If not, how many
   volumes are needed, and can compact catalogs of *patterns* be constructed
   efficiently?

We answer (1) and (2) with exact, formally verified theorems, and we treat (3)
analytically (impossibility by counting, the distributed threshold, and an explicit
de Bruijn construction for a mini-library).

### 1.1 Contributions

- A clean formal model of the library as the function space $\mathrm{Volume}\,b\,L =
  (\mathrm{Fin}\,L \to \mathrm{Fin}\,b)$ with the uniform counting measure.
- An exact size theorem `card_library`: $\#(\text{library}) = b^L$.
- A single-volume probability theorem `prob_singleton`: $\Pr[\{v\}] = b^{-L}$.
- A general counting lemma `card_filter_agree` and its specializations
  `card_agree_inj` and `card_occursAt`: the number of volumes agreeing with a fixed
  pattern on $k$ injectively-placed positions is $b^{L-k}$.
- The exact expectation `expected_substring_count`:
  $\mathbb{E}[\#\text{occurrences}] = (L-k+1)\,b^{-k}$.
- The occurrence probability bound `prob_contains_substring_bound`:
  $\Pr[\text{contains pattern}] \le (L-k+1)\,b^{-k}$.

All edge cases ($b=0$, $b=1$, $L=0$, $k=0$) are handled in the formalization.

---

## 2. The model

### 2.1 Volumes and the library

Fix natural numbers $b$ (alphabet size) and $L$ (volume length). We identify the
alphabet with $\mathrm{Fin}\,b = \{0,1,\dots,b-1\}$ and the set of positions with
$\mathrm{Fin}\,L = \{0,1,\dots,L-1\}$.

> **Definition 2.1 (Volume).** A *volume* of length $L$ over a $b$-symbol alphabet is
> a function
> $$v : \mathrm{Fin}\,L \to \mathrm{Fin}\,b,$$
> assigning a symbol $v(i)$ to each position $i$. We write $\mathrm{Volume}\,b\,L$ for
> the type of all such functions.

> **Definition 2.2 (Library).** The *library* is the finite set of all volumes,
> $\mathrm{Library}\,b\,L = \{\, v : \mathrm{Fin}\,L \to \mathrm{Fin}\,b \,\}$, i.e.
> the full (finite) universe of $\mathrm{Volume}\,b\,L$.

### 2.2 The uniform measure

Because $\mathrm{Volume}\,b\,L$ is finite, we use the uniform counting measure. For a
finite ground set $s$ and an event $A$,

> **Definition 2.3 (Uniform probability).**
> $$\Pr\nolimits_s[A] \;=\; \frac{\#\{\, x \in s : x \in A \,\}}{\#\,s}.$$
> Taking $s = \mathrm{Library}\,b\,L$ yields the uniform probability measure on the
> library. (When $\#s = 0$ the ratio is $0$ by convention.)

### 2.3 Patterns and occurrences

> **Definition 2.4 (Pattern).** A *pattern* of length $k$ is a function
> $p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$.

To talk about a pattern appearing inside a volume we read symbols by index. Define
$\mathrm{readAt}(v, n) = v(n)$ when $n < L$ and $\bot$ (undefined) otherwise.

> **Definition 2.5 (Occurrence at a position).** A pattern $p$ of length $k$ *occurs
> in* $v$ *at position* $i$, written $\mathrm{OccursAt}(p, v, i)$, if
> $$\mathrm{readAt}(v,\, i + j) = p(j) \quad\text{for all } j \in \mathrm{Fin}\,k.$$
> Equivalently, all $k$ reads are in range and the windowed substring equals $p$.

> **Definition 2.6 (Occurrence count and containment).**
> The *occurrence count* of $p$ in $v$ is
> $$\mathrm{occ}(p, v) = \#\{\, i \in \{0,\dots,L-k\} : \mathrm{OccursAt}(p,v,i)\,\},$$
> the number of valid starting positions at which $p$ appears. The volume *contains*
> $p$ if $\mathrm{occ}(p,v) > 0$, i.e. $\exists\, i.\ \mathrm{OccursAt}(p,v,i)$.

> **Definition 2.7 (Expected occurrences).** The expected occurrence count of $p$ in
> a uniformly random volume of length $L$ is
> $$\mathbb{E}[\mathrm{occ}(p, \cdot)] \;=\;
>   \frac{\sum_{v \in \mathrm{Volume}\,b\,L} \mathrm{occ}(p, v)}{\#\,\mathrm{Library}\,b\,L}.$$

---

## 3. Main results

### 3.1 Size of the library

> **Theorem 3.1 (`card_library`).** For all $b, L$,
> $$\#\,\mathrm{Library}\,b\,L \;=\; b^{L}.$$

*Proof sketch.* The library is the full function space $\mathrm{Fin}\,L \to
\mathrm{Fin}\,b$. The cardinality of a function type between finite types is
$(\#\mathrm{codomain})^{\#\mathrm{domain}} = b^{L}$. $\qquad\blacksquare$

For Borges's parameters $b=25$, $L=1\,312\,000$ this is $25^{1\,312\,000}$, a number
with roughly $1.83 \times 10^{6}$ decimal digits.

### 3.2 Probability of a single volume

> **Theorem 3.2 (`prob_singleton`).** For every volume $v$,
> $$\Pr\nolimits_{\mathrm{Library}\,b\,L}[\{v\}] \;=\; b^{-L}.$$

*Proof sketch.* The event $\{v\}$ contains exactly one library point, so the filtered
count is $1$, and by Theorem 3.1 the denominator is $b^{L}$. Hence the ratio is
$1/b^{L} = b^{-L}$ (as a real/zpow expression). $\qquad\blacksquare$

### 3.3 The counting lemma

The technical core is counting volumes constrained on a set of positions.

> **Lemma 3.3 (`card_filter_agree`).** Let $\alpha, \beta$ be finite types, $p$ a
> decidable predicate on $\alpha$, and $g : \alpha \to \beta$ a fixed function. Then
> the number of functions $v : \alpha \to \beta$ that agree with $g$ on every point
> satisfying $p$ equals
> $$\#\{\, v : \alpha \to \beta : \forall a,\ p(a) \Rightarrow v(a) = g(a)\,\}
>   \;=\; (\#\beta)^{\#\{a : \neg p(a)\}}.$$

*Proof sketch.* The constrained set is a dependent product
$\prod_{a} S_a$, where $S_a = \{g(a)\}$ if $p(a)$ holds (one choice) and $S_a = \beta$
otherwise ($\#\beta$ choices). By the product rule for $\Pi$-finsets,
$\#\prod_a S_a = \prod_a \#S_a = \prod_{a:\,p(a)} 1 \cdot \prod_{a:\,\neg p(a)} \#\beta
= (\#\beta)^{\#\{a : \neg p(a)\}}$. $\qquad\blacksquare$

> **Lemma 3.4 (`card_agree_inj`).** Let $\varphi : \mathrm{Fin}\,k \to \mathrm{Fin}\,L$
> be injective and $p$ a pattern of length $k$. Then the number of volumes agreeing
> with $p$ along $\varphi$ is
> $$\#\{\, v : \forall j,\ v(\varphi(j)) = p(j)\,\} \;=\; b^{\,L-k}.$$

*Proof sketch.* Apply Lemma 3.3 with $\alpha = \mathrm{Fin}\,L$, $\beta =
\mathrm{Fin}\,b$, and predicate "lies in the image of $\varphi$." Injectivity makes
the image have exactly $k$ points, so the unconstrained positions number $L-k$,
giving $b^{L-k}$. (The degenerate case $b=0$ is handled separately: an empty alphabet
admits no pattern symbols unless $k=0$.) $\qquad\blacksquare$

> **Lemma 3.5 (`card_occursAt`).** For a pattern $p$ of length $k$ and a valid start
> $i$ with $i + k \le L$,
> $$\#\{\, v : \mathrm{OccursAt}(p, v, i)\,\} \;=\; b^{\,L-k}.$$

*Proof sketch.* The window positions $j \mapsto i+j$ form an injective map
$\mathrm{Fin}\,k \to \mathrm{Fin}\,L$ (valid because $i+k \le L$), and
$\mathrm{OccursAt}$ is exactly agreement with $p$ along this map. Apply Lemma 3.4.
$\qquad\blacksquare$

Lemma 3.5 has a transparent probabilistic reading: the fraction of volumes matching
$p$ at one fixed position is $b^{L-k}/b^{L} = b^{-k}$ — the chance that $k$ independent
uniform symbols spell $p$.

### 3.4 Expected number of occurrences

> **Theorem 3.6 (`expected_substring_count`).** Let $k \le L$ and $b > 0$. For any
> pattern $p$ of length $k$, the expected number of occurrences in a uniformly random
> volume of length $L$ is exactly
> $$\mathbb{E}[\mathrm{occ}(p, \cdot)] \;=\; (L - k + 1)\,\cdot\, b^{-k}.$$

*Proof sketch.* By linearity, write $\mathrm{occ}(p,v) = \sum_{i=0}^{L-k}
\mathbf{1}[\mathrm{OccursAt}(p,v,i)]$ and exchange the sum over volumes with the sum
over positions (Fubini for finite sums):
$$\sum_{v} \mathrm{occ}(p,v) = \sum_{i=0}^{L-k} \#\{v : \mathrm{OccursAt}(p,v,i)\}
= \sum_{i=0}^{L-k} b^{L-k} = (L-k+1)\,b^{L-k},$$
using Lemma 3.5 for each of the $L-k+1$ valid positions. Dividing by
$\#\mathrm{Library} = b^{L}$ (Theorem 3.1) gives
$(L-k+1)\,b^{L-k}/b^{L} = (L-k+1)\,b^{-k}$. The hypothesis $b>0$ guarantees a nonempty
sample space so the division is meaningful. $\qquad\blacksquare$

### 3.5 Probability of containment

> **Theorem 3.7 (`prob_contains_substring_bound`).** Let $k \le L$. For any pattern
> $p$ of length $k$,
> $$\Pr\nolimits_{\mathrm{Library}\,b\,L}\big[\,v \text{ contains } p\,\big]
>   \;\le\; (L-k+1)\,\cdot\, b^{-k}.$$

*Proof sketch.* The containment event is the union over starting positions
$\{v : \exists i,\ \mathrm{OccursAt}(p,v,i)\} = \bigcup_{i=0}^{L-k}
\{v : \mathrm{OccursAt}(p,v,i)\}$ (any occurrence forces the last window index
$i \le L-k$, ruling out out-of-range starts). By subadditivity of cardinality over a
union and Lemma 3.5,
$$\#\{v : \text{contains}\} \le \sum_{i=0}^{L-k} \#\{v : \mathrm{OccursAt}(p,v,i)\}
= (L-k+1)\,b^{L-k}.$$
Dividing by $b^{L}$ yields the bound. Degenerate cases ($b=0$, or $k=0$ where every
volume trivially contains the empty pattern) are checked directly. $\qquad\blacksquare$

This is Markov's inequality made tight: $\Pr[\mathrm{occ}\ge 1] \le
\mathbb{E}[\mathrm{occ}]$, with the expectation supplied exactly by Theorem 3.6. The
gap between the two is the expected number of *repeated* occurrences in a single
volume, which is negligible whenever $(L-k+1)b^{-k} \ll 1$.

---

## 4. Quantitative consequences

### 4.1 Borges's library

With $b = 25$ and $L = 1\,312\,000$:

- **Total volumes:** $25^{1\,312\,000}$ (about $1.83 \times 10^{6}$ digits).
- **Single-volume probability:** $25^{-1\,312\,000}$.
- **A length-$k$ proof appears with probability** at most $(1\,312\,001-k)\cdot
  25^{-k}$. For $k = 200$ this is about $1.3\times10^{6}\cdot 10^{-279.6}\approx
  10^{-273}$.

The factor $L-k+1 \approx 1.3\times 10^{6}$ is the library's only weapon against the
geometric decay $b^{-k}$; it buys roughly $\log_{10}(L)\approx 6.1$ orders of
magnitude, negligible against hundreds of orders lost to $b^{-k}$. **Completeness
without searchability** is thus exact: the pattern is present (positive probability)
but the expected number of random draws to find it is the reciprocal,
$\approx 10^{273}$.

### 4.2 The "two-sided band"

Combining Lemma 3.5 and Theorems 3.6–3.7, for $0 < (L-k+1)b^{-k}$ the containment
probability is sandwiched:
$$b^{-k} \;\le\; \Pr[\text{contains}] \;\le\; (L-k+1)\,b^{-k},$$
the lower bound being the single-position chance (any one fixed window) and the upper
bound the union bound. The ratio of the two endpoints is $L-k+1$, the number of
windows.

---

## 5. Cataloging the library

### 5.1 No single self-catalog (counting/diagonal argument)

> **Proposition 5.1 (Impossibility of a total catalog).** For $b\ge 2$ and large $L$,
> no single volume can encode the addresses of all $b^{L}$ volumes.

*Argument.* An address scheme distinguishing all $b^{L}$ volumes requires
$\log_2(b^{L}) = L\log_2 b$ bits *per address* and $b^{L}$ addresses, hence on the
order of $b^{L}\cdot L\log_2 b$ bits to list them all. A single volume stores only
$L\log_2 b$ bits. Since $b^{L} \gg 1$, one volume's capacity is short by a factor of
$b^{L}$. Equivalently, a self-referential "total book" would have to inject the set of
$b^L$ volumes into its own $L$ symbols, impossible by cardinality. This is the
information-theoretic shadow of Cantor's diagonal argument. $\qquad\blacksquare$

### 5.2 The distributed-catalog threshold

> **Proposition 5.2 (Distributed catalog).** A catalog spread across $N$ volumes can,
> by capacity, address the entire library once
> $$N \;>\; \frac{b^{L}}{L\,\log_2 b}.$$

*Argument.* $N$ volumes carry $N\cdot L\log_2 b$ bits; addressing the whole library
needs at least $\log_2$ of the number of distinguishable index-states, of order
$b^{L}\log_2 b^{L}$ bits when each of the $b^L$ entries is named. Solving for $N$
gives the stated threshold; the minimal integer count is $\lceil b^L/(L\log_2 b)\rceil$.
$\qquad\blacksquare$

This upgrades the impossibility into a recipe: meaning that cannot fit in one
container fits across enough of them — the principle behind every distributed index.

### 5.3 Compact pattern catalogs via de Bruijn sequences

For the *full* library no explicit catalog is feasible, but compact catalogs of all
short *patterns* are. Consider a **mini-library** with $b = 4$, $L = 16$, and target
pattern length $k = 2$.

> **Definition 5.3 (de Bruijn sequence).** A *de Bruijn sequence* $B(b,k)$ is a cyclic
> string over a $b$-symbol alphabet of length $b^{k}$ in which every length-$k$ string
> appears exactly once as a contiguous (cyclic) window.

> **Proposition 5.4 (Existence and construction).** For all $b\ge 1$, $k\ge 1$ a de
> Bruijn sequence $B(b,k)$ exists and is computable in time linear in its length
> $b^{k}$. A linear (non-cyclic) string containing all length-$k$ patterns can be
> taken of length $b^{k}+k-1$, and this is optimal.

*Construction.* Form the de Bruijn graph $G(b,k-1)$ with vertices the length-$(k-1)$
words and a directed edge $w \to w'$ for each length-$k$ word whose first $k-1$
symbols are $w$ and last $k-1$ are $w'$. Every vertex has in-degree and out-degree
$b$, so $G$ is balanced and connected; by Euler's theorem it has an Eulerian circuit.
Reading the edge-labels along the circuit emits each length-$k$ pattern exactly once,
yielding a cyclic string of length $b^{k}$. Cutting the cycle and repeating the first
$k-1$ symbols gives a linear witness of length $b^{k}+k-1$. $\qquad\blacksquare$

For $b=4,k=2$: length $b^k = 16$ cyclic (or $17$ linear) suffices to display all $16$
two-symbol patterns — a perfect, waste-free catalog of "everything of length two,"
exactly matching the mini-library's book length $L=16$.

---

## 6. Algorithms

**(A) Exact occurrence-probability bound.** Given $b, L, k$ and a pattern, compute the
exact rational $(L-k+1)\cdot b^{-k}$ and the exact single-position lower bound
$b^{-k}$, using arbitrary-precision integer arithmetic (the numbers are exact
fractions, not floats). Complexity: $O(\mathrm{polylog})$ arithmetic on big integers.

**(B) de Bruijn catalog construction.** Build $G(b,k-1)$, find an Eulerian circuit by
Hierholzer's algorithm, and emit the catalog string. Complexity: $O(b^{k})$ time and
space — linear in the output.

**(C) Distributed-catalog sizing.** Given $b, L$, return the minimal number of catalog
volumes $\lceil b^{L}/(L\log_2 b)\rceil$ and verify the capacity inequality with exact
big-integer arithmetic.

Pseudocode and reference implementations accompany the package (`demo.py` and the
`algorithms` entries of `PACKAGE.json`).

---

## 7. Applications

- **Universal information spaces.** The model is the prototype of any fixed-format
  message space (DNA $k$-mers, fixed-width records, hash preimages). The occurrence
  formula $(L-k+1)b^{-k}$ is the universal "expected hits of a motif" estimate.
- **Random text and the infinite monkey theorem.** Theorem 3.7 gives the exact
  finite-length version: the chance a length-$L$ random text contains a target of
  length $k$, bounded by $(L-k+1)b^{-k}$, with the matching expectation in 3.6.
- **Search lower bounds.** The reciprocal of the containment probability is the
  expected number of blind draws to find a target, formalizing why brute-force search
  over universal spaces is hopeless and a guide is mandatory.
- **Covering codes / sequencing.** De Bruijn catalogs (Section 5.3) underlie minimal
  covering sequences used in genome assembly, PIN brute-forcing analysis, and
  combinatorial testing.

---

## 8. Discussion and future work

The proven core is the exact pair $\mathbb{E}[\mathrm{occ}] = (L-k+1)b^{-k}$ and
$\Pr[\text{contains}]\le (L-k+1)b^{-k}$, supported by the cardinality identity
$b^{L-k}$ for volumes pinned to a pattern. These pin down the *mean* and a tight upper
tail. Several directions remain open and are stated so they can be attacked formally:

1. **Constructive distributed catalog.** Upgrade the cardinality threshold $b^L\le
   N\cdot L$ to an *explicit, polynomial-time* injection $\mathrm{Volume}\,b\,L
   \hookrightarrow \mathrm{Fin}(\lceil b^L/L\rceil)\times\mathrm{Fin}\,L$ via
   mixed-radix base-$b$ numbering chopped into $L$-cell blocks, replacing the abstract
   embedding with an algorithm.
2. **Universal de Bruijn tightness.** Prove the lower bound $b^k+k-1$ is achieved with
   equality for *every* $(b,k)$ (not just $(4,2)$) by formalizing Eulerian-circuit
   existence in de Bruijn graphs.
3. **Poisson concentration.** Show the occurrence count, scaled by its mean
   $(L-k+1)b^{-k}$, converges to a Poisson law as $L\to\infty$ with $k$ fixed, so that
   $\Pr[\text{contains}] = 1-\exp(-Lb^{-k})+o(1)$ once $Lb^{-k}\to\lambda$; the
   established two-sided band pins the mean, and bounded ($k$-range) window dependence
   enables a Chen–Stein approximation. The next concrete rung is a second-moment
   (variance) bound, a finite-combinatorics computation.

---

## 9. Conclusion

The Library of Babel, read mathematically, is a finite uniform probability space of
size $b^{L}$ in which every text is present yet exponentially rare. We have given its
exact size, single-volume probability, expected pattern-occurrence count
$(L-k+1)b^{-k}$, and containment bound $(L-k+1)b^{-k}$, with the supporting count
$b^{L-k}$ of pattern-constrained volumes — all formally verified. The cataloging
analysis explains why no single volume can index the whole (a counting/diagonal
obstruction), why a distributed index of $\gtrsim b^L/(L\log_2 b)$ volumes can, and how
de Bruijn sequences give optimal compact catalogs of short patterns. Borges's fable
becomes a precise account of completeness without searchability — and of the guides
that make universal spaces navigable.
