# Combinatorics of the Universal Library: Counting, Diagonalization, and de Bruijn Catalogs

**Author:** Aristotle

**Date:** 2026-06-19

**Domain:** Algebra / Enumerative & Algorithmic Combinatorics

---

## Abstract

Borges' *Library of Babel* is the set of all strings of a fixed length over a finite
alphabet — a finite but astronomically large universal information space. We give a
rigorous combinatorial treatment of three questions about such spaces: (i) *how rare
is a given pattern?*, (ii) *can the space catalog itself?*, and (iii) *can a complete,
addressable catalog be constructed efficiently?* For the first, we prove an exact
fixed-position occurrence count: the number of volumes agreeing with a prescribed
pattern on $m$ designated positions is exactly $b^{L-m}$, giving a per-position match
probability of $b^{-m}$ with **no** length prefactor; the spurious linear factor in
the folklore estimate is identified as the union-bound window count $L-m+1$ of the
distinct "occurs-anywhere" problem, corrected by the string's autocorrelation. For
the second, a pigeonhole/diagonal argument shows no single volume can index all $b^L$
volumes, while a distributed catalog over $N$ volumes can do so **iff** $N \ge b^L/L$
(reference-count model), a threshold that climbs to $N \gtrsim b^L$ under faithful bit
encoding. For the third, we cast catalog construction as the de Bruijn window
bijection: a sequence whose order-$n$ windows enumerate all $b^n$ words must have
length exactly $b^n$, and such sequences exist and are constructible in time linear in
their length via an Eulerian circuit in the de Bruijn graph. We illustrate with the
Borges parameters $(b,L) = (25,\,1{,}312{,}000)$ and a mini-Library $(b,n) = (4,16)$.
All central claims correspond to formally verified statements: `card_agree_on`,
`prob_match`, `distributed_catalog_iff`, `IsDeBruijn`, `window`, and
`isDeBruijn_length`.

---

## 1. Introduction

In *The Library of Babel* (1941), Jorge Luis Borges describes a universe consisting
of all books of a fixed format: 410 pages, 40 lines per page, 80 characters per line,
over an alphabet of 25 orthographic symbols. Every such book exists exactly once. The
Library is therefore the set of all strings of length $L = 1{,}312{,}000$ over an
alphabet of size $b = 25$, a set of cardinality $b^L = 25^{1{,}312{,}000}$.

Although Borges' interest was metaphysical, the object he defined is a clean
mathematical one: a **universal information space**, the free monoid restricted to a
fixed length. Such spaces recur throughout computer science and mathematics — the set
of all files of a given size, all genomes of a given length, all keys of a given
bit-width, all weight vectors of a fixed-architecture network. Three questions are
fundamental to any of them:

1. **Occurrence / rarity.** How many volumes contain a given target pattern, and with
   what probability?
2. **Self-cataloging (diagonalization).** Can a volume — or a bounded family of
   volumes — encode the address of every volume, including itself?
3. **Constructive cataloging.** Can one efficiently build a single object that lists
   every possible short passage exactly once, with computable addresses?

This paper answers all three exactly. The mathematics is elementary in its
ingredients (counting, pigeonhole, Eulerian circuits) but the answers correct several
pieces of folklore, most notably the belief that pattern-match probability carries a
linear length factor.

### 1.1 Notation

Fix an alphabet size $b \ge 1$ and a book length $L \ge 0$. The **Library** is

$$
\mathcal{L}(b,L) \;=\; \{0,1,\dots,b-1\}^{L} \;\cong\; (\mathrm{Fin}\,b)^{\mathrm{Fin}\,L},
$$

the set of functions from $L$ positions to $b$ symbols, with $|\mathcal{L}(b,L)| = b^L$.
A **volume** is an element $v \in \mathcal{L}(b,L)$. A **pattern on a set**
$S \subseteq \{0,\dots,L-1\}$ is a function $p : S \to \{0,\dots,b-1\}$; a **target
word** of length $m$ is a string $T \in \{0,\dots,b-1\}^m$. We write $\log_b$ for the
base-$b$ logarithm and $\log_2$ for base-2.

---

## 2. The counting law

### 2.1 Exact agreement count

The basic object is the set of volumes that match a prescribed pattern on a fixed set
of positions.

> **Definition 2.1 (agreement set).** For $S \subseteq \{0,\dots,L-1\}$ and a pattern
> $p : S \to \{0,\dots,b-1\}$, let
> $$ \mathrm{Agree}(p) \;=\; \{\,v \in \mathcal{L}(b,L) \;:\; v(i) = p(i)\ \text{for all } i \in S\,\}. $$

> **Theorem 2.2 (`card_agree_on`).** Let $|S| = m$. Then
> $$ |\mathrm{Agree}(p)| \;=\; b^{\,L-m}. $$

**Proof sketch.** A volume in $\mathrm{Agree}(p)$ is determined by its values on the
$L - m$ positions *outside* $S$, those on $S$ being forced to equal $p$. The
restriction map $v \mapsto v|_{\{0,\dots,L-1\}\setminus S}$ is a bijection from
$\mathrm{Agree}(p)$ onto $\{0,\dots,b-1\}^{\,L-m}$: it is injective because $v$ is
determined on $S$ by $p$ and on the complement by its restriction, and surjective
because any choice on the complement extends uniquely. Hence
$|\mathrm{Agree}(p)| = b^{L-m}$. (Formally this is a product/`Finset.card` computation
fixing $m$ coordinates and letting the rest range freely.) $\qquad\blacksquare$

The special case $S = \{j, j+1, \dots, j+m-1\}$ with $p$ the symbols of a target word
$T$ gives the count of volumes carrying $T$ at the fixed position $j$:
$|\{v : v\text{ has } T \text{ at } j\}| = b^{L-m}$ (whenever the window fits, i.e.
$j + m \le L$).

### 2.2 Fixed-position match probability

> **Theorem 2.3 (`prob_match`).** Under the uniform distribution on $\mathcal{L}(b,L)$,
> for any target word $T$ of length $m \le L$ and any fixed admissible position $j$,
> $$ \Pr[\,v \text{ matches } T \text{ at position } j\,] \;=\; \frac{b^{\,L-m}}{b^{L}} \;=\; b^{-m}. $$

**Proof sketch.** Immediate from Theorem 2.2 by dividing the agreement count $b^{L-m}$
by the total count $b^L$. Equivalently, the $m$ positions of the window are
independent uniform symbols, each matching with probability $1/b$. $\qquad\blacksquare$

**Remark 2.4 (no length prefactor).** The conjectural folklore estimate
"$\Pr \approx |T|\cdot b^{-m}$" is *false* as a per-position statement: Theorem 2.3
shows the probability is the pure exponential $b^{-m}$. The linear factor is an
artifact of conflating two different events.

### 2.3 The "occurs anywhere" correction (windowed-occurrence law)

The linear factor *does* appear — for a different question. Let
$\mathrm{Occ}(T) = \{ v : T \text{ occurs as a contiguous substring of } v \text{ at some position}\}$.
There are $W = L - m + 1$ candidate starting windows.

> **Proposition 2.5 (windowed bounds).** For $m \le L$,
> $$ (L-m+1)\,b^{\,L-m} \;-\; \binom{L-m+1}{2}\, b^{\,L-2m+c(T)} \;\le\; |\mathrm{Occ}(T)| \;\le\; (L-m+1)\,b^{\,L-m}, $$
> where the second-order term is governed by the autocorrelation (overlap) structure
> $c(T)$ of $T$.

**Proof sketch (upper bound, established; lower bound, conjectural refinement C1).**
The upper bound is a union bound: $\mathrm{Occ}(T) = \bigcup_{j} A_j$ where $A_j$ is the
event "$T$ at position $j$," $|A_j| = b^{L-m}$ by Theorem 2.2, and there are $L-m+1$
windows. The first inclusion–exclusion correction subtracts the pairwise
intersections $|A_j \cap A_{j'}|$; when two windows overlap, the joint constraint
involves the **Guibas–Odlyzko correlation polynomial** of $T$, which records for each
shift whether $T$ can overlap a copy of itself. Non-self-overlapping targets (e.g.
*abcd*) have trivial correlation and the bound is tightest. Dividing by $b^L$ gives
$\Pr[\mathrm{Occ}(T)] \le (L-m+1)b^{-m}$, recovering the linear-in-window-count factor.
$\qquad\blacksquare$

**Interpretation.** "Meaning density" in the Library is not a single scalar; it is a
string-autocorrelation invariant. The clean per-position rate is $b^{-m}$; the
anywhere-rate is at most $(L-m+1)b^{-m}$ with autocorrelation corrections.

### 2.4 Scale of the Borges Library

With $b = 25$, $L = 1{,}312{,}000$:

- $|\mathcal{L}| = 25^{1{,}312{,}000}$ has $\lfloor L\log_{10} b\rfloor + 1 = 1{,}834{,}098$
  decimal digits.
- A fixed 100-symbol passage occurs at a fixed position in a fraction
  $25^{-100} \approx 10^{-140}$ of volumes.
- One volume holds $L\log_2 b \approx 6.09 \times 10^{6}$ bits of information.

---

## 3. Diagonalization: can the Library catalog itself?

A **catalog** must provide, for each of the $b^L$ volumes, a decodable *reference*
(address) locating it. Modeling a catalog as a family of volumes, each supplying its
$L$ symbol-positions as reference slots, we ask how many volumes are needed.

### 3.1 Single-volume impossibility

> **Theorem 3.1 (no total book).** If $b^L > L$, no single volume can store a distinct
> reference for every volume; equivalently, there is no injection
> $\mathcal{L}(b,L) \hookrightarrow \{0,\dots,L-1\}$.

**Proof sketch.** A single volume has $L$ positions, hence can hold at most $L$
distinct one-symbol references. An injection from a set of size $b^L$ into a set of
size $L$ requires $b^L \le L$ (pigeonhole). For all Borges-scale parameters
$b^L \gg L$, so no such injection exists. This is the diagonal/cardinality obstruction:
the universe is strictly larger than any of its members' addressing capacity.
$\qquad\blacksquare$

This is the rigorous form of Borges' "total book": the catalog of all books cannot be
one of the books.

### 3.2 Distributed catalogs: an exact threshold

Spread the catalog over $N$ volumes. Together they offer $N \cdot L$ reference slots.

> **Theorem 3.2 (`distributed_catalog_iff`).** A distributed catalog of $N$ volumes can
> assign every volume a distinct reference slot **iff**
> $$ N \cdot L \;\ge\; b^{L}, \qquad\text{equivalently}\qquad N \;\ge\; \frac{b^{L}}{L}. $$

**Proof sketch.** ($\Leftarrow$) If $N L \ge b^L$, the $b^L$ volumes inject into the
$N L$ available slots — concretely, enumerate volumes and assign slot $\lfloor \cdot \rfloor$
addresses by Euclidean division into (volume index, position index); injectivity is
the uniqueness of division with remainder. ($\Rightarrow$) If $N L < b^L$, pigeonhole
forbids an injection of $b^L$ items into $N L$ slots, so some volume is unlisted. The
threshold $N \ge \lceil b^L / L\rceil$ is therefore exact. $\qquad\blacksquare$

**Corollary 3.3 (catalog ≈ Library).** The minimal distributed catalog has
$\lceil b^L/L\rceil$ volumes; for $(b,L)=(25,1312000)$ this number has about
$1{,}834{,}098 - 6 = 1{,}834{,}092$ decimal digits — only six digits shy of the Library
itself. *The map is nearly the size of the territory.*

### 3.3 Bit-faithful encoding (entropy refinement C2)

Theorem 3.2 charges one slot per reference. Faithful encoding charges
$\lceil \log_2 b^L\rceil = \lceil L\log_2 b\rceil$ **bits** per reference, since a
reference must single out one of $b^L$ volumes.

> **Conjecture 3.4 (entropy lower bound).** Under bit-faithful encoding, a distributed
> catalog requires total storage $\ge b^L \cdot \lceil L\log_2 b\rceil$ bits, i.e.
> $N \gtrsim b^L$ volumes — a factor $L\log_2 b$ larger than the reference-count
> threshold of Theorem 3.2.

**Discussion.** This is a Kraft-inequality statement: $b^L$ distinct prefix-free
codewords over a binary channel require codeword lengths summing under
$\sum 2^{-\ell_i} \le 1$, forcing average length $\ge \log_2 b^L$. The reference-count
model "cheats" by treating an address as a single symbol; the honest model multiplies
the threshold back up to the full Library size. Both extremes are informative: the
*combinatorial* cost is $b^L/L$, the *informational* cost is $b^L$.

---

## 4. Constructive catalogs via de Bruijn sequences

We now turn from existence to construction. A catalog of all length-$n$ passages
should list each exactly once with a computable address. The optimal such object is a
**de Bruijn sequence**.

### 4.1 The window map

> **Definition 4.1 (`window`).** Let $s : \mathrm{Fin}\,N \to \{0,\dots,b-1\}$ be a
> cyclic sequence of length $N$. Its order-$n$ **window map** is
> $$ \mathrm{window}_s : \mathrm{Fin}\,N \to \{0,\dots,b-1\}^{n}, \qquad \mathrm{window}_s(i) = \big(s(i), s(i+1), \dots, s(i+n-1)\big), $$
> indices taken modulo $N$. It reads off the length-$n$ block beginning at position $i$.

> **Definition 4.2 (`IsDeBruijn`).** The sequence $s$ is a **de Bruijn sequence of
> order $n$ over $b$ symbols**, written $\mathrm{IsDeBruijn}(b,n,s)$, iff
> $\mathrm{window}_s$ is a **bijection** onto $\{0,\dots,b-1\}^{n}$ — i.e. every one of
> the $b^n$ possible length-$n$ blocks occurs exactly once as a window.

The bijection *is* the catalog: to find a target block $w$, return the unique address
$\mathrm{window}_s^{-1}(w)$.

### 4.2 Forced length

> **Theorem 4.3 (`isDeBruijn_length`).** If $\mathrm{IsDeBruijn}(b,n,s)$ for
> $s : \mathrm{Fin}\,N \to \{0,\dots,b-1\}$, then
> $$ N \;=\; b^{n}. $$

**Proof sketch.** A bijection equates the cardinalities of its domain and codomain.
The domain is $\mathrm{Fin}\,N$ with $|{\cdot}| = N$; the codomain is
$\{0,\dots,b-1\}^n$ with $|{\cdot}| = b^n$. Hence $N = b^n$. $\qquad\blacksquare$

This is the *necessity* direction: a de Bruijn catalog has no slack — its length is
pinned exactly to the number of words it must enumerate.

### 4.3 Existence and construction (realizability C3)

> **Theorem 4.4 (existence).** For all $b \ge 1$, $n \ge 1$, a de Bruijn sequence of
> order $n$ over $b$ symbols exists, and can be constructed in time $O(b^n)$ — linear in
> its length.

**Proof sketch.** Form the **de Bruijn graph** $G_{b,n}$: vertices are the $b^{n-1}$
words of length $n-1$; for each length-$n$ word $w = w_1\cdots w_n$ draw a directed edge
from $w_1\cdots w_{n-1}$ to $w_2\cdots w_n$ labeled $w$. Every vertex has in-degree and
out-degree exactly $b$ (append/prepend any symbol), so the graph is **balanced**, and it
is strongly **connected**. By Euler's theorem, $G_{b,n}$ admits an **Eulerian circuit**
traversing every edge exactly once. The sequence of edge labels along the circuit
(reading one new symbol per step around the cycle) is a cyclic string of length
$b^n$ whose order-$n$ windows are exactly the $b^n$ edges — each once — so it is de
Bruijn. **Hierholzer's algorithm** computes the Eulerian circuit in time linear in the
edge count $b^n$. $\qquad\blacksquare$

Together, Theorems 4.3 and 4.4 say: de Bruijn catalogs exist at every order, have
length exactly $b^n$ (no shorter complete catalog is possible), and are buildable about
as fast as they can be written.

### 4.4 The mini-Library $B(4,16)$

For alphabet size $b = 4$ and window length $n = 16$, the construction yields a single
cyclic sequence of length

$$
4^{16} \;=\; 2^{32} \;=\; 4{,}294{,}967{,}296,
$$

inside which each of the $4^{16}$ possible 16-symbol blocks appears exactly once, at the
address given by $\mathrm{window}^{-1}$. This is a complete, navigable index of a small
universal text space, constructible in one linear pass.

---

## 4bis. Worked numerical examples

We record several exact computations that anchor the theory and that the
accompanying software reproduces.

**Agreement count, brute force vs. formula.** Take $b = 3$, $L = 6$, and the
target word $T = (1,0,2)$ fixed at position $j = 2$. Direct enumeration over all
$3^6 = 729$ volumes finds exactly $27$ that carry $T$ in slots $2,3,4$. Theorem 2.2
predicts $b^{L-m} = 3^{3} = 27$, and Theorem 2.3 gives match probability
$27/729 = 1/27 = b^{-m}$. The occurs-anywhere upper bound is
$(L-m+1)\,b^{-m} = 4/27$, exhibiting the legitimate linear window factor that is
*absent* from the per-position rate.

**Borges scale.** For $b = 25$, $L = 1{,}312{,}000$: the Library has
$\lfloor L\log_{10}25\rfloor + 1 = 1{,}834{,}098$ decimal digits; a single volume
carries $L\log_2 25 \approx 6{,}092{,}739$ bits; and a fixed $100$-symbol passage
appears at a fixed position in a fraction $25^{-100} \approx 10^{-139.8}$ of all
volumes. For perspective, the observable universe holds $\approx 10^{80}$ atoms — a
$81$-digit number — so the Library dwarfs every physical inventory by more than a
million orders of magnitude in digit count.

**Distributed catalog threshold.** For the toy Library $b = 5$, $L = 4$ we have
$b^L = 625$. A single volume cannot index it ($625 \not\le 4$). The minimal
distributed catalog has $N = \lceil 625/4\rceil = 157$ volumes: $156$ volumes give
$156\cdot 4 = 624 < 625$ slots (one volume unindexed), while $157\cdot 4 = 628 \ge
625$ suffices — confirming the sharp threshold of Theorem 3.2.

**de Bruijn realizability.** The construction yields $B(2,3) =
00010111$ (length $2^3 = 8$), $B(4,3)$ of length $4^3 = 64$, and $B(4,4)$ of length
$4^4 = 256$; in each case every length-$n$ block occurs exactly once, verifying
Definition 4.2 and the length identity of Theorem 4.3. The address of a block is
recovered as the unique window position equal to it.

**Autocorrelation.** The correlation bits of $T$ distinguish overlap classes:
$(0,1,2,3)$ has profile $[1,0,0,0]$ (non-self-overlapping, tightest windowed
bound); $(0,1,0,1)$ has $[1,0,1,0]$; $(0,0,0,0)$ has $[1,1,1,1]$ (maximal
self-overlap). These weights are exactly the second-order corrections of
Proposition 2.5.

## 4ter. Related context

The three pillars connect to classical bodies of mathematics. The counting law is
the enumerative backbone of analytic combinatorics on words; the autocorrelation
correction is the Guibas–Odlyzko theory underpinning expected waiting times for
patterns and the Conway leading-number formula for penney-style games. The
single-volume impossibility is the finitary shadow of Cantor's diagonal theorem and
a sibling of Kolmogorov-complexity incompressibility: most volumes have no shorter
description than themselves, so no compact universal index exists. The de Bruijn
material sits inside the theory of Eulerian circuits (Euler, 1736; Hierholzer,
1873) and the shift dynamics of full one-sided shifts, where order-$n$ windows are
the cylinder sets generating the topology. What is new here is the *uniform,
formally verified* treatment that ties occurrence counting, self-cataloging limits,
and constructive catalogs to one concrete object — the universal library — with all
six headline statements machine-checked.

## 5. Algorithms

### 5.1 Fixed-position occurrence count (`card_agree_on`)

Given $b, L, m$ with $m \le L$: return $b^{L-m}$ (volumes matching a fixed pattern on
$m$ positions) and $b^{-m}$ (probability). $O(1)$ arithmetic on big integers /
rationals; output magnitude $\Theta(L\log b)$ digits.

### 5.2 Distributed-catalog threshold (`distributed_catalog_iff`)

Given $b, L$: return $N_{\min} = \lceil b^L / L\rceil$ (reference-count model) and the
bit-faithful estimate $N \approx b^L$. $O(1)$ big-integer operations.

### 5.3 de Bruijn construction (Hierholzer on $G_{b,n}$)

Build the balanced, connected de Bruijn graph and extract an Eulerian circuit; emit the
order-$n$ de Bruijn sequence of length $b^n$. Time and space $O(b^n)$. Verification:
slide the order-$n$ window and check all $b^n$ blocks occur exactly once (i.e.
$\mathrm{window}$ is a bijection), confirming Theorem 4.3's length and Definition 4.2.

---

## 6. Applications

- **Search and rarity bounds.** Theorem 2.3 quantifies why brute-force discovery of
  meaningful content in universal spaces (random files, genomes, keys) is infeasible:
  per-position match probability decays as $b^{-m}$.
- **Self-description limits.** Theorem 3.1 is a combinatorial sibling of Cantor/Gödel
  diagonalization and of compression lower bounds: no object indexes its own universe.
- **Positional encoding.** de Bruijn sequences (Definitions 4.1–4.2, Theorem 4.4) are
  used in rotary/linear position encoders, where a short local readout uniquely
  determines absolute position via $\mathrm{window}^{-1}$.
- **Genome assembly.** de Bruijn graphs (proof of Theorem 4.4) underpin modern
  short-read assemblers; the order-$n$ window is the $k$-mer abstraction.
- **Coding and crypto.** Maximal-length / de Bruijn sequences seed pseudorandom
  generators and error-correcting constructions.

---

## 7. Discussion

The three results form a triptych. **Counting** (§2) measures the rarity of structure:
meaning is exponentially expensive, and the only "cheap" geometry is the linear window
budget of the occurs-anywhere problem, itself tamed by autocorrelation. **Diagonalization**
(§3) measures the cost of self-reference: a universe cannot be indexed from within a
single member, but a distributed index exists at a sharp threshold that — under honest
bit accounting — rises to the size of the universe itself. **Construction** (§4)
measures the cost of completeness: a perfect catalog of all short passages exists, is
length-optimal at $b^n$, and is efficiently realizable.

A unifying theme is *the map versus the territory*. The naive hope is a small map of a
large space. Each result pushes back: the per-symbol cost of pinning content is fixed,
the self-catalog is nearly the whole Library, and even the most efficient complete
catalog of $n$-grams is exactly $b^n$ long. Borges' Library resists summary not by
accident but by theorem.

---

## 8. Future directions

**C1 — Windowed-occurrence law (sharpening `prob_match`).** Prove the two-sided
inclusion–exclusion bound of Proposition 2.5 with the second-order term expressed via
the Guibas–Odlyzko correlation polynomial of $T$; the building block `card_agree_on`
already gives the exact per-window count $b^{L-m}$, leaving the window-sum
inclusion–exclusion.

**C2 — Strictly super-linear catalog (entropy lower bound).** Promote Theorem 3.2 to
the bit-faithful Kraft statement of Conjecture 3.4: each reference costs $L\log_2 b$
bits, raising the threshold from $b^L/L$ to $\sim b^L$.

**C3 — de Bruijn existence at every order.** Formalize Theorem 4.4 as an Eulerian-circuit
existence result in the balanced, connected de Bruijn graph, complementing the necessity
theorem `isDeBruijn_length`; this realizes $B(4,16)$ constructively in time polynomial in
its length.

**C4 — Phase transition in "probability of a valid proof."** Fix a proof system and study
the probability that a random Borges volume encodes a syntactically valid proof of a
target theorem, conjecturing a sharp threshold as a function of proof complexity.

---

## 9. Summary of formalized results

| Name | Statement |
|---|---|
| `card_agree_on` | Volumes matching a fixed pattern on $m$ positions number exactly $b^{L-m}$. |
| `prob_match` | Fixed-position match probability of a length-$m$ target is exactly $b^{-m}$. |
| `distributed_catalog_iff` | A catalog over $N$ volumes indexes the Library iff $N \ge b^L/L$. |
| `window` | Order-$n$ window map of a cyclic sequence reading length-$n$ blocks. |
| `IsDeBruijn` | A sequence is de Bruijn iff its window map is a bijection onto all $b^n$ words. |
| `isDeBruijn_length` | A de Bruijn sequence of order $n$ over $b$ symbols has length exactly $b^n$. |
