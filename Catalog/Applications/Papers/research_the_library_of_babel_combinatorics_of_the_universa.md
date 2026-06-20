# The Combinatorics and Probability of the Library of Babel

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Novelty / Combinatorics / Discrete Probability

## Abstract

Borges' *Library of Babel* is the set of all strings of a fixed length over a
fixed finite alphabet. We give a self-contained, rigorous treatment of its exact
combinatorial and probabilistic structure. Modelling a volume of length $L$ over
a $b$-symbol alphabet as a function $\mathrm{Fin}\,L \to \mathrm{Fin}\,b$, we
prove that the library contains exactly $b^{L}$ volumes; that under the uniform
counting measure every individual volume has probability $b^{-L}$; that the
expected number of occurrences of a fixed length-$k$ pattern in a uniformly
random volume is exactly $(L-k+1)\,b^{-k}$ whenever $k \le L$ and $b > 0$; and
that the probability a random volume contains the pattern anywhere is at most
$(L-k+1)\,b^{-k}$. The technical core is a single counting identity: the number
of volumes that agree with a prescribed pattern along $k$ fixed positions is
$b^{\,L-k}$. All results hold for every alphabet size and length, including the
degenerate cases $b \in \{0,1\}$ and $k \in \{0, L\}$. The development has been
formalized and machine-checked; this paper presents the definitions, statements,
and proof sketches in standard mathematical language.

## 1. Introduction

In Jorge Luis Borges' 1941 story *The Library of Babel*, the universe is a
library of identically formatted books containing every possible arrangement of a
small set of symbols. The mathematical idealization is immediate and clean: fix
an alphabet size $b$ and a length $L$, and consider the set of *all* strings of
length $L$ over $b$ symbols. This set is finite, and almost every quantitative
question one can ask about it has an exact closed-form answer.

This paper isolates four such questions and answers them precisely:

1. **How large is the library?** (Cardinality.)
2. **How likely is one specific book?** (Singleton probability.)
3. **How often does a fixed fragment appear on average?** (Expected occurrence
   count.)
4. **How likely is a fixed fragment to appear at all?** (Containment bound.)

The answers are, respectively, $b^L$; $b^{-L}$; $(L-k+1)\,b^{-k}$; and at most
$(L-k+1)\,b^{-k}$. The unifying engine is a counting lemma stating that
constraining $k$ positions of a volume while leaving the rest free yields exactly
$b^{L-k}$ volumes. We develop the theory abstractly in $b$ and $L$, then
specialize to Borges' canonical constants $b = 25$, $L = 1{,}312{,}000$.

## 2. Definitions

Throughout, $\mathrm{Fin}\,n = \{0, 1, \dots, n-1\}$ denotes the standard
$n$-element index set, and for finite sets we write $|\cdot|$ for cardinality.

**Definition 1 (Volume).** Fix natural numbers $b$ (alphabet size) and $L$
(length). A *volume* is a function
$$
v : \mathrm{Fin}\,L \to \mathrm{Fin}\,b,
$$
i.e. an assignment of one of $b$ symbols to each of the $L$ positions. We write
$\mathrm{Volume}(b,L)$ for the (finite) type of all such functions.

**Definition 2 (Library).** The *library* $\mathrm{Library}(b,L)$ is the finite
set of *all* volumes, i.e. the full ambient finite set $\mathrm{Volume}(b,L)$
viewed as a finite collection.

**Definition 3 (Uniform counting probability).** For a finite ambient set $s$
and an event $A \subseteq s$, the *uniform counting probability* is
$$
\Pr_s(A) = \frac{|\{x \in s : x \in A\}|}{|s|} \in \mathbb{R}.
$$
We apply this with $s = \mathrm{Library}(b,L)$; this is exactly the uniform
probability measure on the library.

**Definition 4 (Reading, occurrence, containment).** For a volume $v$ and an
index $n \in \mathbb{N}$, define the *read*
$$
\mathrm{read}(v, n) = \begin{cases} v(n) & n < L,\\ \bot & n \ge L,\end{cases}
$$
where $\bot$ denotes "out of range." Given a *pattern* $p : \mathrm{Fin}\,k \to
\mathrm{Fin}\,b$ of length $k$, we say $p$ *occurs at position $i$* in $v$,
written $\mathrm{OccursAt}(p, v, i)$, if
$$
\mathrm{read}(v, i + j) = p(j) \quad\text{for all } j \in \mathrm{Fin}\,k.
$$
The volume $v$ *contains* $p$, written $\mathrm{Contains}(p, v)$, if
$\mathrm{OccursAt}(p, v, i)$ holds for some $i \in \mathbb{N}$.

**Definition 5 (Occurrence count and expectation).** The *occurrence count* of a
pattern $p$ in a volume $v$ is the number of valid starting offsets at which it
occurs,
$$
N_p(v) = \bigl|\{\, i \in \{0, \dots, L-k\} : \mathrm{OccursAt}(p, v, i) \,\}\bigr|,
$$
(formally, $i$ ranges over $\{0,\dots,L-k\}$, encoded as $\mathrm{range}(L-k+1)$).
The *expected occurrence count* is the average of $N_p$ over the whole library,
$$
\mathbb{E}[N_p] = \frac{1}{|\mathrm{Library}(b,L)|}\sum_{v} N_p(v).
$$

## 3. The cardinality of the library

**Theorem 1 (`card_library`).** For all $b, L \in \mathbb{N}$,
$$
|\mathrm{Library}(b,L)| = b^{L}.
$$

*Proof sketch.* A volume is a function from the $L$-element set
$\mathrm{Fin}\,L$ to the $b$-element set $\mathrm{Fin}\,b$. The number of
functions between finite sets is the cardinality of the codomain raised to the
cardinality of the domain, $|\mathrm{Fin}\,b|^{|\mathrm{Fin}\,L|} = b^{L}$. The
formalization discharges this by the standard cardinality-of-function-space
computation. $\qquad\blacksquare$

For Borges' constants $b = 25$, $L = 1{,}312{,}000$ this gives
$25^{1{,}312{,}000}$, whose base-$10$ logarithm is $1{,}312{,}000 \log_{10} 25
\approx 1.834 \times 10^{6}$; the library has on the order of $10^{1{,}834{,}000}$
volumes.

## 4. The counting backbone

The probabilistic results all reduce to a single combinatorial principle:
fixing some coordinates of a function and freeing the rest multiplies the count
by the codomain size for each free coordinate.

**Lemma 1 (`card_filter_agree`).** Let $\alpha, \beta$ be finite types, let
$p$ be a decidable predicate on $\alpha$, and let $g : \alpha \to \beta$ be a
fixed function. Then the number of functions $v : \alpha \to \beta$ that agree
with $g$ on every point satisfying $p$ is
$$
\bigl|\{\, v : \alpha \to \beta \mid \forall a,\ p(a) \Rightarrow v(a) = g(a)
\,\}\bigr| = |\beta|^{\,|\{a : \neg p(a)\}|}.
$$

*Proof sketch.* The constraint decouples coordinatewise: at each point $a$ with
$p(a)$ the value $v(a)$ is forced to $g(a)$ (one choice), while at each point
with $\neg p(a)$ the value is free ($|\beta|$ choices). The set of admissible
functions is therefore a product of singletons and full sets, a dependent
product (`Fintype.piFinset`) whose cardinality is the product of the per-point
choice counts. Multiplying $1$ over constrained points and $|\beta|$ over free
points yields $|\beta|$ raised to the number of free points. $\qquad\blacksquare$

**Lemma 2 (`card_agree_inj`).** Let $\varphi : \mathrm{Fin}\,k \to
\mathrm{Fin}\,L$ be injective and let $p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$
be a pattern. The number of volumes that agree with $p$ along $\varphi$ is
$$
\bigl|\{\, v \in \mathrm{Volume}(b,L) \mid \forall j,\ v(\varphi(j)) = p(j)
\,\}\bigr| = b^{\,L-k}.
$$

*Proof sketch.* Apply Lemma 1 with $\alpha = \mathrm{Fin}\,L$, $\beta =
\mathrm{Fin}\,b$, predicate "$a$ is in the image of $\varphi$," and target
function determined by $p$ via the inverse of $\varphi$ on its image (well
defined by injectivity). The number of *un*constrained positions is
$L - |\mathrm{image}(\varphi)| = L - k$, the last equality using that an
injective map from a $k$-element set has image of size $k$. The edge case
$b = 0$ (no symbols) is handled separately: then $k$ must be $0$ for a pattern to
exist, and both sides equal $1$. $\qquad\blacksquare$

**Lemma 3 (`card_occursAt`).** For a pattern $p$ of length $k$ and a fixed
position $i$ with $i + k \le L$,
$$
\bigl|\{\, v \in \mathrm{Volume}(b,L) \mid \mathrm{OccursAt}(p, v, i) \,\}\bigr|
= b^{\,L-k}.
$$

*Proof sketch.* The map $j \mapsto i + j$ is an injection $\mathrm{Fin}\,k \to
\mathrm{Fin}\,L$ (valid because $i + k \le L$), and $\mathrm{OccursAt}(p,v,i)$ is
exactly the statement that $v$ agrees with $p$ along this injection. Apply
Lemma 2. $\qquad\blacksquare$

## 5. Probability of a single volume

**Theorem 2 (`prob_singleton`).** For all $b, L$ and every volume $v$,
$$
\Pr_{\mathrm{Library}(b,L)}\bigl(\{v\}\bigr) = b^{-L}.
$$

*Proof sketch.* By Definition 3 the probability is $|\{w : w = v\}| / |
\mathrm{Library}(b,L)|$. The numerator is $1$ (the singleton), and the
denominator is $b^{L}$ by Theorem 1. Hence the value is $1/b^{L} = b^{-L}$,
written as the integer power $(b:\mathbb{R})^{-(L:\mathbb{Z})}$. The case $b = 0$,
$L > 0$ is consistent: the library is empty, the singleton event is empty, and
both the convention $0^{-L}$ and the ratio $0/0$ are handled so the identity
still holds as stated by the formalization's conventions. $\qquad\blacksquare$

Specializing to Borges, the probability of drawing a prescribed book uniformly at
random is $25^{-1{,}312{,}000} \approx 10^{-1{,}834{,}000}$.

## 6. Expected number of pattern occurrences

**Theorem 3 (`expected_substring_count`).** Let $k \le L$ and $b > 0$, and let
$p$ be a pattern of length $k$. Then
$$
\mathbb{E}[N_p] = (L - k + 1)\, b^{-k}.
$$

*Proof sketch.* Write $N_p(v) = \sum_{i = 0}^{L-k} \mathbf{1}[\mathrm{OccursAt}
(p,v,i)]$ and sum over all volumes. Exchanging the order of summation (Fubini for
finite sums),
$$
\sum_{v} N_p(v) = \sum_{i=0}^{L-k} \bigl|\{ v : \mathrm{OccursAt}(p,v,i)\}\bigr|.
$$
Every position $i$ in the range $\{0, \dots, L-k\}$ satisfies $i + k \le L$, so
Lemma 3 gives each inner cardinality as $b^{L-k}$. There are $L - k + 1$ such
positions, hence $\sum_v N_p(v) = (L-k+1)\,b^{L-k}$. Dividing by
$|\mathrm{Library}(b,L)| = b^{L}$ (Theorem 1) and using $b^{L-k}/b^{L} = b^{-k}$
(valid since $b > 0$ and $k \le L$) yields $(L-k+1)\,b^{-k}$. The hypothesis
$b > 0$ guarantees a nonempty sample space so the expectation is well defined;
$k \le L$ guarantees $L - k$ is a genuine subtraction and the range is correct.
$\qquad\blacksquare$

This identity is the quantitative heart of the theory. Two limiting readings are
worth recording. First, expectation grows *linearly* in book length $L$ and
decays *geometrically* in pattern length $k$. Second, setting $\mathbb{E}[N_p] =
1$ and solving gives the critical length $L^\star \approx b^{k}$ at which a fixed
length-$k$ pattern is expected to appear once.

## 7. Probability that a pattern appears at all

**Theorem 4 (`prob_contains_substring_bound`).** Let $k \le L$ and let $p$ be a
pattern of length $k$. Then
$$
\Pr_{\mathrm{Library}(b,L)}\bigl(\{ v : \mathrm{Contains}(p,v) \}\bigr) \le (L -
k + 1)\, b^{-k}.
$$

*Proof sketch.* The containment event is the union over starting positions of the
occurrence events:
$$
\{ v : \mathrm{Contains}(p,v) \} \subseteq \bigcup_{i=0}^{L-k} \{ v :
\mathrm{OccursAt}(p,v,i) \}.
$$
(One checks that any genuine occurrence forces $i + k \le L$, because reading
position $i + (k-1)$ must succeed, so out-of-range starting positions contribute
nothing.) Counting, the cardinality of the union is at most the sum of the
cardinalities (union bound / subadditivity of counting), and each summand is
$b^{L-k}$ by Lemma 3, giving at most $(L-k+1)\,b^{L-k}$ matching volumes.
Dividing by $b^{L}$ yields the stated bound. All degenerate cases ($b = 0$,
$k = 0$) are checked directly: for $k = 0$ the empty pattern occurs everywhere
and both sides are handled consistently. $\qquad\blacksquare$

For long, rare patterns the bound is essentially tight, because the probability
of two or more simultaneous occurrences is of lower order. Comparing $k$ against
$\log_b L$ pinpoints the threshold: when $k \ll \log_b L$ the bound exceeds $1$
and is vacuous (the pattern is almost surely present), while when $k \gg \log_b
L$ the bound is exponentially small (the pattern is almost surely absent).

## 8. Degenerate cases and the role of the hypotheses

A recurring strength of the development is that the four headline results are
stated and proved with no superfluous side conditions, and every boundary case
is accounted for. It is worth recording explicitly what happens at the edges,
because these are exactly the situations where informal arguments quietly break.

**Empty alphabet $b = 0$.** When there are no symbols, there can be no volumes of
positive length, so the library is empty whenever $L > 0$. Theorem 1 still holds:
$0^{L} = 0$ for $L > 0$ and $0^{0} = 1$ (the unique empty volume of length $0$
exists even with no symbols, since it makes no demands on any position). Theorem 3
*excludes* $b = 0$ via the hypothesis $b > 0$, precisely because an empty sample
space makes the average $0/0$ ill defined; this is the single genuinely necessary
side condition in the entire development. Theorem 4, by contrast, survives $b = 0$
because the containment *probability* is defined by the counting ratio and the
bound is checked directly in this case.

**Trivial alphabet $b = 1$.** With one symbol there is exactly one volume of each
length (all positions equal), so $|\mathrm{Library}(1, L)| = 1^L = 1$. The unique
volume has probability $1^{-L} = 1$, consistent with there being nothing else to
draw. A length-$k$ pattern (necessarily the all-same-symbol string) occurs in the
unique volume at all $L - k + 1$ positions, and indeed $(L-k+1)\cdot 1^{-k} =
L-k+1$ matches the deterministic occurrence count.

**Empty pattern $k = 0$.** The empty pattern occurs at *every* position
vacuously, so it is contained in every volume. Theorem 3 gives $\mathbb{E}[N_p] =
(L + 1)\cdot b^{0} = L + 1$, the number of positions $\{0, \dots, L\}$, which is
correct since the empty string sits in each of the $L+1$ gaps. Theorem 4 gives
the (vacuous but valid) bound $\Pr(\mathrm{Contains}) \le L + 1$.

**Full-length pattern $k = L$.** Here $L - k + 1 = 1$: a length-$L$ pattern can
only start at position $0$, and it occurs there iff the volume *equals* the
pattern. Theorem 3 reduces to $\mathbb{E}[N_p] = b^{-L}$, recovering the singleton
probability of Theorem 2, and Theorem 4 gives the matching bound — a satisfying
internal consistency check linking the substring theory back to the singleton
theory.

The load-bearing hypotheses are therefore exactly two: $k \le L$ (so that the
pattern can fit and natural-number subtraction $L - k$ behaves arithmetically as
expected) appears in Theorems 3 and 4, while $b > 0$ (nonempty sample space)
appears only in the expectation Theorem 3. Both are necessary: dropping $k \le L$
makes $L - k$ truncate to $0$ and the formulas fail; dropping $b > 0$ in
Theorem 3 divides by an empty library.

## 9. Algorithms

The theory is constructive and yields exact computations.

**Algorithm A (Exact library and singleton statistics).** Given $b, L$, compute
$|\mathrm{Library}(b,L)| = b^{L}$ as an exact big integer and the singleton
probability $b^{-L}$ as an exact rational. Complexity: $O(\log L)$ big-integer
multiplications by fast exponentiation; the result has $\Theta(L \log b)$ digits.

**Algorithm B (Expected occurrence count and containment bound).** Given
$b, L, k$ with $k \le L$, return the exact rational $(L-k+1)\,b^{-k}$ for both the
expected occurrence count (Theorem 3) and the containment upper bound
(Theorem 4). Complexity: $O(\log k)$ big-integer operations.

**Algorithm C (Brute-force verification on a mini-library).** For small $b, L$,
enumerate all $b^L$ volumes, directly count occurrences of a pattern in each, and
compare the empirical average and empirical containment frequency against the
closed forms of Theorems 3 and 4. This is the experimental check that the exact
formulas match reality; complexity $O(b^{L}\cdot L)$, feasible for $b^L$ up to a
few million.

## 10. Worked example: a mini-library

Take $b = 2$ (binary), $L = 4$, so the library has $2^4 = 16$ volumes (Theorem
1). The singleton probability is $2^{-4} = 1/16$ (Theorem 2). Consider the
pattern $p = (1,0)$ of length $k = 2$. By Theorem 3 the expected number of
occurrences in a random $4$-bit string is
$$
(4 - 2 + 1)\cdot 2^{-2} = 3 \cdot \tfrac14 = \tfrac34.
$$
Direct enumeration confirms this: summing the occurrence counts of `10` across
all $16$ binary strings of length $4$ gives $12$, and $12/16 = 3/4$. The
containment bound of Theorem 4 reads $\Pr(\mathrm{Contains}) \le 3/4$; the true
containment frequency is $8/16 = 1/2 \le 3/4$, with the slack accounted for by
strings such as `1010` that contain the pattern twice.

## 11. Applications and discussion

The Library of Babel is a faithful toy model for any *universal information
space*: the set of all bitstrings of a fixed length, all DNA sequences of a fixed
length, all images at a fixed resolution, or all length-bounded programs. In each
case the cardinality $b^L$, the per-element probability $b^{-L}$, and the
fragment statistics $(L-k+1)\,b^{-k}$ describe the baseline "everything is
possible but nothing specific is findable by chance" regime. The expected-count
formula is precisely the calculation behind back-of-envelope estimates in
genomics (expected occurrences of a $k$-mer in a genome of length $L$) and in
random-string search. The containment union bound is the elementary case of the
first-moment method, ubiquitous in probabilistic combinatorics.

**The first-moment method in miniature.** Theorems 3 and 4 together are the
simplest nontrivial instance of one of the most important techniques in modern
combinatorics, the *first-moment method*: to show that a random object is
unlikely to have a property, exhibit a nonnegative integer-valued statistic
(here, the occurrence count $N_p$) whose expectation is small, and invoke
Markov's inequality $\Pr(N_p \ge 1) \le \mathbb{E}[N_p]$. The union bound of
Theorem 4 is exactly this inequality specialized to a count of events. The
complementary *second-moment method* would estimate $\mathrm{Var}(N_p)$ to show
the pattern is also *likely* to appear when $\mathbb{E}[N_p]$ is large; computing
that variance for overlapping windows (which are positively correlated through
shared positions) is the natural next quantitative step and is sketched in the
future directions.

**Quantitative genomics.** The expected-count formula is, verbatim, the standard
estimate for the number of occurrences of a $k$-mer (a length-$k$ DNA word) in a
genome modelled as a uniform random string over the $b = 4$ nucleotide alphabet:
a genome of length $L$ contains a fixed $k$-mer about $(L-k+1)\,4^{-k}$ times. For
a human-scale genome $L \approx 3 \times 10^{9}$, a fixed $16$-mer is expected
$(3\times 10^9)\cdot 4^{-16} \approx 0.7$ times — the empirical observation that
$16$-mers are roughly at the boundary of uniqueness, which underlies the choice of
seed lengths in sequence-alignment software. Our development makes this folklore
calculation a theorem with explicit hypotheses.

**Compression and addressing.** A philosophical corollary deserves mention.
Borges' librarians sought a single
master catalog. The cardinality result quantifies why no compact catalog can list
every book by content: writing down a complete distinguishing description of all
$b^L$ volumes requires at least $\log_2(b^L) = L \log_2 b$ bits, which is
precisely the information content of one volume — so the "catalog" is no smaller
than the library it indexes. Yet a catalog is unnecessary: each volume *is* its
own index, the base-$b$ numeral for an integer in $\{0, \dots, b^L - 1\}$. The
library is self-indexing; the difficulty is never storage but search, and the
search difficulty is governed exactly by the formulas above.

## 12. Future directions

(See the package's *Future Directions* for the full Phase A list.) The most
immediate extensions are: (i) a decidable *meaningfulness* predicate with a
density bound showing meaningful volumes form a geometrically sparse subset; (ii)
a self-referential catalog argument exhibiting the catalog itself as a volume once
$L$ is large enough; (iii) the Hamming metric on volumes, with exact ball sizes
$\sum_{i} \binom{L}{i}(b-1)^i$ enabling covering/packing statements about the
nearest meaningful neighbor; and (iv) upgrading the counting probability to a
genuine probability-measure formulation.

## 13. Conclusion

We have given exact, fully general answers to the four fundamental quantitative
questions about Borges' Library of Babel: it contains $b^L$ volumes; each has
probability $b^{-L}$; a fixed length-$k$ pattern occurs on average
$(L-k+1)\,b^{-k}$ times; and appears at all with probability at most
$(L-k+1)\,b^{-k}$. All four follow from one counting identity — freeze $k$
positions, free the rest, count $b^{L-k}$ — and all hold across every alphabet
size and length, degenerate cases included. The Library of Babel, infinite in
imagination, is finite, exactly countable, and exactly understood.
