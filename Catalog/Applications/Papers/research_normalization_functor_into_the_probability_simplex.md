# Exact Combinatorial and Probabilistic Structure of the Library of Babel

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Algebra (combinatorial probability)

## Abstract

We give a complete, exact treatment of the combinatorial and probabilistic
structure of Borges' *Library of Babel*, modeled as the set of all functions
from a finite position set to a finite alphabet. Fixing an alphabet of $b$
symbols and a volume length $L$, the library is the function space
$\{1,\dots,L\} \to \{1,\dots,b\}$, equipped with the uniform counting
probability. We prove four principal facts and the counting lemmas that support
them. First, the library has cardinality exactly $b^L$. Second, under the
uniform measure every individual volume has probability exactly $b^{-L}$. Third
— the main theorem — the expected number of occurrences of a fixed pattern of
length $k \le L$ in a uniformly random volume equals $(L-k+1)\,b^{-k}$ exactly,
provided $b > 0$. Fourth, the probability that a random volume contains the
pattern at least once is at most $(L-k+1)\,b^{-k}$, by a union bound. The
expected-occurrence theorem is driven by a position-fixing count: the number of
volumes exhibiting a fixed pattern at a fixed admissible position is exactly
$b^{L-k}$, which we derive from a general lemma on the cardinality of function
spaces constrained to agree with a template on a designated subdomain. All
results, including every edge case ($b=0$, $b=1$, $L=0$, $k=0$), are established
constructively. The development is elementary but the exactness is the point:
each quantity is an equality (or a sharp inequality), not an asymptotic estimate.

## 1. Introduction

Borges' "La biblioteca de Babel" (1941) describes a library containing every
book of a fixed length over a fixed alphabet. The image is a literary device for
the vertigo of combinatorial explosion, but the underlying object is a perfectly
precise mathematical structure: a finite function space under the uniform
measure. The purpose of this paper is to record its exact combinatorial and
probabilistic invariants.

Two competing exponentials govern the library. Its size $b^L$ grows
exponentially in the volume length; the probability $b^{-k}$ of matching a fixed
$k$-symbol pattern at a fixed position decays exponentially in the pattern
length. The interplay of the two is captured cleanly by the expected-occurrence
formula $(L-k+1)\,b^{-k}$, which we identify as the central quantitative content
of the model. The formula is the discrete analogue of the renewal-theoretic
expected count of pattern occurrences in an i.i.d. symbol stream, here proved as
an exact identity over the finite library rather than as a limiting statement.

We work entirely within finite combinatorics. The probabilistic statements are
phrased through a single primitive, the uniform counting ratio, so that the
probability of an event is literally the fraction of volumes realizing it.

## 2. Definitions

Throughout, $b$ (alphabet size) and $L$ (volume length) are natural numbers, and
$k$ (pattern length) is a natural number with $k \le L$ where indicated.

**Definition 1 (Volume).** A *volume* of length $L$ over an alphabet of $b$
symbols is a function $v : \{0,\dots,L-1\} \to \{0,\dots,b-1\}$. We write
$\mathrm{Volume}(b,L)$ for the type of such functions. (In the formalization,
positions and symbols are the finite types $\mathrm{Fin}\,L$ and
$\mathrm{Fin}\,b$.)

**Definition 2 (Library).** The *library* $\mathcal{L}(b,L)$ is the finite set
of all volumes of length $L$ over $b$ symbols, i.e. the entire function space
$\mathrm{Volume}(b,L)$.

**Definition 3 (Uniform counting probability).** For a finite sample space $s$
and an event $A$, define
$$\Pr_s(A) \;=\; \frac{\bigl|\{x \in s : x \in A\}\bigr|}{|s|}.$$
Applied to $s = \mathcal{L}(b,L)$ this is the uniform probability measure on the
library. (When $|s| = 0$ the ratio is $0$ by convention; meaningful
probabilistic statements assume $b > 0$ so that $|s| = b^L > 0$.)

**Definition 4 (Reading).** For a volume $v$ and an index $n \in \mathbb{N}$,
$$\mathrm{readAt}(v,n) \;=\;
\begin{cases} v(n) & \text{if } n < L,\\ \bot & \text{otherwise,}\end{cases}$$
valued in $\mathrm{Option}(\mathrm{Fin}\,b)$, returning $\bot$ ("none") out of
range.

**Definition 5 (Occurrence at a position).** A *pattern* of length $k$ is a
function $p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$. The pattern $p$ *occurs at
position $i \in \mathbb{N}$* in $v$, written $\mathrm{OccursAt}(p,v,i)$, iff
$$\forall j \in \mathrm{Fin}\,k,\quad \mathrm{readAt}(v,\,i+j) = p(j).$$
In particular, occurrence requires every probed index $i+j$ to be in range.

**Definition 6 (Occurrence count).** The number of starting positions at which
$p$ occurs in $v$ is
$$\mathrm{occurrenceCount}(p,v) \;=\;
\bigl|\{\, i \in \{0,\dots,L-k\} : \mathrm{OccursAt}(p,v,i)\,\}\bigr|,$$
the count taken over the $L-k+1$ admissible starting positions
$\{0,\dots,L-k\}$ (the range of length $L-k+1$).

**Definition 7 (Containment).** $v$ *contains* $p$, written
$\mathrm{Contains}(p,v)$, iff $\exists i,\ \mathrm{OccursAt}(p,v,i)$.

**Definition 8 (Expected occurrences).** The expected number of occurrences of
$p$ in a uniformly random volume is
$$\mathrm{expectedOccurrences}(p,L) \;=\;
\frac{\sum_{v \in \mathcal{L}(b,L)} \mathrm{occurrenceCount}(p,v)}{|\mathcal{L}(b,L)|}.$$

## 3. Counting the library

**Theorem 1 (`card_library`).** For all $b, L \in \mathbb{N}$,
$$|\mathcal{L}(b,L)| = b^{L}.$$

*Proof sketch.* The library is the full function space
$\mathrm{Fin}\,L \to \mathrm{Fin}\,b$, whose cardinality is
$(\#\mathrm{Fin}\,b)^{\#\mathrm{Fin}\,L} = b^{L}$ by the standard count of
functions between finite types: a function is determined by independent choices
of one of $b$ values at each of $L$ inputs, and the choices multiply. The
identity is total — it holds for all $b, L \in \mathbb{N}$, including $b = 0$
(where $0^L$ is $1$ if $L = 0$ and $0$ otherwise) and $L = 0$ (where $b^0 = 1$,
the single empty volume). $\square$

**Theorem 2 (`prob_singleton`).** For all $b, L$ and every volume
$v \in \mathcal{L}(b,L)$,
$$\Pr_{\mathcal{L}(b,L)}\bigl(\{v\}\bigr) = b^{-L}.$$

*Proof sketch.* The filtered set $\{x \in \mathcal{L} : x \in \{v\}\}$ is the
singleton $\{v\}$, of cardinality $1$. Dividing by $|\mathcal{L}| = b^L$
(Theorem 1) gives $1/b^L = b^{-L}$, the equality holding in $\mathbb{R}$ with the
integer exponent $-L$. The degenerate case $b=0$ has no volumes, so the
statement is vacuous there. $\square$

## 4. Counting constrained volumes

The main theorem reduces to counting, for each admissible position, how many
volumes display the pattern there. We isolate the count as two reusable lemmas.

**Lemma 1 (`card_filter_agree`).** Let $\alpha$ be a finite type with decidable
equality and $\beta$ a finite type. Let $p$ be a decidable predicate on $\alpha$
and $g : \alpha \to \beta$ a fixed template. Then
$$\bigl|\{\, v : \alpha \to \beta \ \mid\ \forall a,\ p(a) \Rightarrow v(a) = g(a)\,\}\bigr|
\;=\; (\#\beta)^{\,\#\{a : \neg p(a)\}}.$$

*Proof sketch.* The constrained set is in bijection with the dependent product
$\prod_{a \in \alpha} S_a$, where $S_a = \{g(a)\}$ if $p(a)$ and $S_a = \beta$
otherwise. By the product rule for finite dependent function spaces its
cardinality is $\prod_a |S_a|$. Each constrained coordinate contributes a factor
$1$ and each free coordinate a factor $\#\beta$, so the product equals
$(\#\beta)^{m}$ with $m$ the number of free coordinates, i.e.
$m = \#\{a : \neg p(a)\}$. Converting the resulting sum-of-ones exponent to a
cardinality via $\sum_a [\neg p(a)] = \#\{a:\neg p(a)\}$ closes the argument.
$\square$

**Lemma 2 (`card_agree_inj`).** Let $\varphi : \mathrm{Fin}\,k \to
\mathrm{Fin}\,L$ be injective and $p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$ a
pattern. Then
$$\bigl|\{\, v \in \mathcal{L}(b,L) \ \mid\ \forall j,\ v(\varphi(j)) = p(j)\,\}\bigr|
\;=\; b^{\,L-k}.$$

*Proof sketch.* Specialize Lemma 1 with $\alpha = \mathrm{Fin}\,L$,
$\beta = \mathrm{Fin}\,b$, predicate "lies in the image of $\varphi$", and a
template that on $\varphi(j)$ returns $p(j)$ (well-defined by injectivity of
$\varphi$) and is arbitrary elsewhere. The constrained positions are exactly the
$k$ image points $\mathrm{range}(\varphi)$, so the number of free positions is
$L - \#\mathrm{range}(\varphi) = L - k$, the last equality because $\varphi$ is
injective. Hence the count is $b^{L-k}$. The boundary case $b = 0$ is handled
separately: if $k > 0$ no pattern exists (so the statement is vacuously fine),
and if $k = 0$ both sides equal the appropriate power. $\square$

**Lemma 3 (`card_occursAt`).** For a pattern $p$ of length $k$ and a position
$i$ with $i + k \le L$,
$$\bigl|\{\, v \in \mathcal{L}(b,L) \ \mid\ \mathrm{OccursAt}(p,v,i)\,\}\bigr|
\;=\; b^{\,L-k}.$$

*Proof sketch.* The admissibility $i+k\le L$ makes the map
$\varphi(j) = i + j$ a well-defined injection $\mathrm{Fin}\,k \to
\mathrm{Fin}\,L$ (injective because $j \mapsto i+j$ is). Under this $\varphi$,
the predicate $\mathrm{OccursAt}(p,v,i)$ — i.e.
$\mathrm{readAt}(v,i+j) = p(j)$ for all $j$ — is, using $i+j < L$, equivalent to
$v(\varphi(j)) = p(j)$ for all $j$. Lemma 2 then yields $b^{L-k}$. $\square$

## 5. The main theorem

**Theorem 4 (`expected_substring_count`, main result).** Let $k \le L$ and
$b > 0$, and let $p$ be a pattern of length $k$. Then
$$\mathrm{expectedOccurrences}(p,L) \;=\; (L - k + 1)\cdot b^{-k}.$$

*Proof sketch.* Compute the numerator
$N = \sum_{v} \mathrm{occurrenceCount}(p,v)$ first. Expanding the definition and
exchanging the order of summation (Fubini for finite sums),
$$N = \sum_{v}\ \sum_{i=0}^{L-k} [\mathrm{OccursAt}(p,v,i)]
   = \sum_{i=0}^{L-k}\ \sum_{v} [\mathrm{OccursAt}(p,v,i)]
   = \sum_{i=0}^{L-k} \bigl|\{v : \mathrm{OccursAt}(p,v,i)\}\bigr|.$$
Each admissible $i \in \{0,\dots,L-k\}$ satisfies $i + k \le L$, so by Lemma 3
the inner cardinality is $b^{L-k}$, independent of $i$. There are $L-k+1$ terms,
hence
$$N = (L-k+1)\,b^{\,L-k}.$$
Dividing by $|\mathcal{L}(b,L)| = b^L$ (Theorem 1) and using
$b^{L-k}/b^{L} = b^{-k}$ (valid since $b>0$ and $k \le L$, so $L-k+k=L$) gives
$$\mathrm{expectedOccurrences}(p,L) = \frac{(L-k+1)\,b^{L-k}}{b^{L}}
   = (L-k+1)\,b^{-k}. \qquad\square$$

This is an exact identity. The hypothesis $b>0$ guarantees a nonempty library
(so the expectation is defined); the hypothesis $k \le L$ guarantees the pattern
fits and the position range $\{0,\dots,L-k\}$ has the stated $L-k+1$ elements.

**Interpretation (the indicator decomposition).** Linearity of expectation is
doing the structural work. Write the occurrence count as a sum of indicator
random variables
$$\mathrm{occurrenceCount}(p,\cdot) = \sum_{i=0}^{L-k} X_i,\qquad
X_i = [\mathrm{OccursAt}(p,\cdot,i)].$$
Each $X_i$ is a Bernoulli variable whose mean is the per-position match
probability $\mathbb{E}[X_i] = \Pr[\mathrm{OccursAt}(p,\cdot,i)] = b^{L-k}/b^{L} =
b^{-k}$ (Lemma 3 and Theorem 1). Crucially, the identity
$\mathbb{E}[\sum_i X_i] = \sum_i \mathbb{E}[X_i]$ requires no independence: the
$X_i$ are in fact strongly dependent, because overlapping windows share symbols
(for a self-overlapping pattern such as $000$, knowing $X_i = 1$ shifts the law
of $X_{i+1}$). Linearity is indifferent to this dependence, which is exactly why
the expected count is a clean product while the *distribution* of the count is
not. The total $(L-k+1)\,b^{-k}$ trades the linear growth in $L$ (more windows)
against the exponential decay in $k$ (each extra symbol divides the
per-window probability by $b$). The same dependence is what forces Theorem 5 to
be an inequality rather than an equality: the union bound
$\Pr[\bigcup_i \{X_i = 1\}] \le \sum_i \Pr[X_i = 1]$ overcounts precisely the
joint events $\{X_i = X_j = 1\}$, and equality would hold only if the occurrence
events were pairwise disjoint — which they are not whenever a pattern can recur.
This places the result squarely in the first-moment method: the expectation
pins the average, and the union bound converts it into a tail statement.

The model is the finite, exact counterpart of a classical limit. For an
infinite i.i.d.\ stream of symbols, renewal theory gives an asymptotic
occurrence rate of $b^{-k}$ per position; Theorem 4 is the corresponding
identity over the finite library, with the boundary correction $L-k+1$ (rather
than $L$) accounting exactly for the windows that fall off the end of a finite
volume.

## 6. Containment probability

**Theorem 5 (`prob_contains_substring_bound`).** For $k \le L$ and a pattern $p$
of length $k$,
$$\Pr_{\mathcal{L}(b,L)}\bigl(\{\, v : \mathrm{Contains}(p,v)\,\}\bigr)
   \;\le\; (L - k + 1)\cdot b^{-k}.$$

*Proof sketch.* Containment is the union over admissible positions of the
occurrence events: $\{v : \mathrm{Contains}(p,v)\} = \bigcup_{i=0}^{L-k}
\{v : \mathrm{OccursAt}(p,v,i)\}$ (occurrence at an inadmissible position is
impossible, since some probed index would be out of range). By monotonicity and
finite subadditivity of the uniform measure (the union bound),
$$\Pr\Bigl(\bigcup_i E_i\Bigr) \le \sum_{i=0}^{L-k} \Pr(E_i)
   = \sum_{i=0}^{L-k} \frac{b^{L-k}}{b^{L}} = (L-k+1)\,b^{-k},$$
using Lemma 3 and Theorem 1 for each term. $\square$

The bound is sharp in the small-probability regime (where overlap corrections
are negligible) and becomes vacuous, as it should, once $(L-k+1)\,b^{-k} \ge 1$,
i.e. when short patterns in long volumes are almost surely present.

## 7. Edge cases

The development is total: every result holds for all natural-number parameters
in its stated range, with degenerate cases treated explicitly.

- **$b = 0$ (empty alphabet).** The library is empty unless $L = 0$. Theorem 1
  gives $0^L$ (which is $1$ if $L=0$, else $0$). The counting Lemma 2 is proved
  by a separate branch for $b=0$. Probabilistic statements presuppose $b>0$.
- **$b = 1$ (unary alphabet).** Exactly one volume exists ($1^L = 1$); every
  pattern occurs at every admissible position, and $(L-k+1)\cdot 1^{-k} = L-k+1$,
  matching the deterministic count.
- **$L = 0$ (empty volumes).** The only volume is the empty function; the only
  admissible pattern length is $k=0$.
- **$k = 0$ (empty pattern).** The empty pattern occurs at every position;
  expected count $(L+1)\,b^{0} = L+1$, and the containment bound is $\ge 1$
  (vacuous), consistent with the empty pattern always being present.

## 8. Worked examples

We record several fully explicit evaluations, all of which can be checked by
exhaustive enumeration over the relevant finite library and which therefore
serve as concrete certificates for the closed forms.

**Example 1 (binary, the canonical case).** Take $b = 2$, $L = 10$, and the
pattern $p = (0,1)$ of length $k = 2$. The library has $2^{10} = 1024$ volumes
(Theorem 1), each of probability $2^{-10} = 1/1024$ (Theorem 2). There are
$L - k + 1 = 9$ admissible starting positions, and at each one exactly
$2^{10-2} = 256$ volumes display the pattern (Lemma 3). Hence the summed
occurrence count is $9 \cdot 256 = 2304$, and the expected count is
$$\mathrm{expectedOccurrences}(p,10) = \frac{2304}{1024} = \frac{9}{4} = 2.25,$$
in exact agreement with $(L-k+1)\,b^{-k} = 9 \cdot 2^{-2} = 9/4$ (Theorem 4).
An independent brute-force average over all $1024$ strings returns the same
$9/4$, with no rounding.

**Example 2 (ternary sweep).** With $b = 3$ one finds, for instance,
$\mathrm{expectedOccurrences}((0,0),4) = (4-2+1)\cdot 3^{-2} = 3/9 = 1/3$;
$\mathrm{expectedOccurrences}((2,0,1),5) = (5-3+1)\cdot 3^{-3} = 3/27 = 1/9$;
and the boundary case $k = L$, e.g.
$\mathrm{expectedOccurrences}((0,1,2,0),4) = (4-4+1)\cdot 3^{-4} = 1/81$, where the
single admissible position contributes the probability $3^{-4}$ of an exact full
match. Each equals its brute-force value exactly.

**Example 3 (unary degeneracy).** With $b = 1$ there is exactly one volume
(the constant function), and every pattern of length $k \le L$ occurs at every
one of the $L-k+1$ positions; the formula returns $(L-k+1)\cdot 1^{-k} = L-k+1$,
the deterministic count, and the containment probability is exactly $1$ while the
bound $(L-k+1)\cdot 1^{-k} \ge 1$ is (correctly) non-restrictive.

**Example 4 (containment vs. bound).** For $b = 2$, $L = 8$, $p = (0,0,0)$
($k=3$), exhaustive enumeration gives
$\Pr[\mathrm{Contains}] = 0.41797\ldots$, comfortably below the union bound
$(8-3+1)\cdot 2^{-3} = 6/8 = 0.75$ (Theorem 5). The gap is exactly the
inclusion–exclusion correction for overlapping occurrences of $000$, which the
union bound deliberately discards.

**Example 5 (Borges' parameters).** With $b = 25$ and $L = 1{,}312{,}000$,
Theorem 1 gives a library of $25^{1{,}312{,}000}$ volumes (about $1.8$ million
decimal digits). A specific phrase of $k = 50$ characters has expected count
$(1{,}312{,}000 - 49)\cdot 25^{-50} \approx 1.66 \times 10^{-64}$ (Theorem 4):
the phrase exists in the library, but is expected once per $\sim 10^{64}$ volumes.
Here only the closed form is usable; enumeration is physically impossible.

## 9. Algorithms

Two procedures accompany the theory; both are exact finite computations.

**Algorithm A (Exhaustive expected-occurrence verifier).** Enumerate all $b^L$
volumes, count pattern occurrences in each, and average. This computes
$\mathrm{expectedOccurrences}(p,L)$ directly from Definition 8 and must equal
$(L-k+1)\,b^{-k}$ (Theorem 4). Complexity $\Theta(b^L \cdot (L-k+1)\cdot k)$ —
feasible only for small $b,L$, but decisive as a check on the closed form.

**Algorithm B (Closed-form evaluator).** Evaluate $(L-k+1)\,b^{-k}$ and the
containment bound directly in $O(1)$ arithmetic operations (plus the cost of
big-integer/rational exponentiation). This is the production formula for any
$b,L,k$, including Borges' astronomical parameters where Algorithm A is
infeasible.

The pairing — a brute-force checker valid in the small regime and a closed form
valid everywhere — is the practical content of the exactness theorems.

## 10. Applications

The model is a faithful abstraction of several real settings, in each of which
the expected-occurrence identity is the standard chance-baseline calculation.

- **Genomics.** With $b=4$ (DNA bases), a volume is a genome and a pattern is a
  sequence motif; $(L-k+1)\,4^{-k}$ is the expected number of chance occurrences
  used to flag statistically over-represented motifs.
- **Information security and forensics.** With $b=256$ (bytes), the formula
  estimates expected chance collisions of a fixed signature in a file of length
  $L$, and the union bound caps the probability of any chance hit.
- **Coding theory.** With $b=2$, the results are exact statements about
  substring statistics in uniformly random bit-strings.
- **Theoretical computer science.** Theorem 5 is a concrete instance of the
  union-bound (first-moment) method used pervasively to show rare events stay
  rare; the same template bounds the chance that any of many low-probability bad
  configurations occurs.
- **Search and indexing.** The expected count calibrates how many spurious
  matches a fixed query of length $k$ produces in a corpus modeled as random
  text of length $L$, informing index granularity and minimum useful query
  length: once $(L-k+1)\,b^{-k} \ll 1$, a single hit is overwhelmingly likely to
  be meaningful rather than coincidental.

In every case the two regimes delimited by Theorem 5 — the small-probability
regime where the union bound is tight and the saturated regime where it is
vacuous because the pattern is almost surely present — carry the operational
meaning: they separate “finding the pattern is evidence” from “finding the
pattern is inevitable.”

## 11. Discussion

The value of the development is its exactness and totality. Each headline
quantity is an equality — $b^L$, $b^{-L}$, $(L-k+1)\,b^{-k}$ — or a sharp
inequality, proved for all parameters with degenerate cases discharged rather
than excluded. The mathematics is elementary (function-space cardinality,
Fubini for finite sums, linearity of expectation, the union bound), but the
contribution is the precise bookkeeping that turns Borges' image of the infinite
into closed-form invariants. The crux is the position-fixing count $b^{L-k}$
(Lemma 3), abstracted from the general agreement-count Lemma 1; once that is in
hand, the main theorem is pure linearity of expectation.

## 12. Future work

A natural next step is an *exact* containment probability via
inclusion–exclusion over overlapping occurrences, replacing the union bound of
Theorem 5; this connects to the correlation-polynomial / Guibas–Odlyzko theory
of overlapping patterns and to the autocorrelation structure of the pattern. One
can also compute the full distribution and the variance of
$\mathrm{occurrenceCount}$ (a second-moment analysis), study patterns drawn at
random or with wildcards, and treat multiple patterns simultaneously. Each of
these refines the first-moment results proved here while staying within the same
finite, exact framework.

The broader program from which this work descends concerns functorial bridges
between tropical, probabilistic, and Diophantine structures; the present
combinatorial-probability layer supplies a fully exact, edge-case-complete
template for the uniform-measure computations those bridges require.
