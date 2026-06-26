# Central Gaussian Coefficients and the Maximal Binary 2-Binomial Class

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Probability / Enumerative Combinatorics

## Abstract

We study the sizes of the *2-binomial equivalence classes* of binary words and
their identification, via MacMahon's theorem, with the coefficients of the
Gaussian (q-)binomial coefficients. Two binary words are 2-binomially equivalent
(in the sense of Rigo and Salimov) when they contain the same number of scattered
occurrences of every factor of length at most two; for the binary alphabet this is
equivalent to sharing the same length $n$, the same number of ones $k$, and the
same inversion number $i$ (the number of scattered occurrences of the factor
$10$). Indexing a class by the triple $(n,k,i)$, its cardinality
$\mathrm{classSize}(n,k,i)$ equals the coefficient of $q^i$ in
$\genfrac{[}{]}{0pt}{}{n}{k}_q$. We model a length-$n$ word with $k$ ones by the
$k$-element set of positions carrying a one. Within this model we establish: an
exact ceiling $\mathrm{inv} \le k(n-k)$ for the inversion statistic; vanishing of
classes beyond that ceiling; the row-sum identity
$\sum_i \mathrm{classSize}(n,k,i) = \binom{n}{k}$; and the palindromic symmetry
$\mathrm{classSize}(n,k,i) = \mathrm{classSize}(n,k,k(n-k)-i)$, proved by a
word-reversal bijection that interchanges inversions and co-inversions. The
symmetry yields immediately that the mean inversion number of a uniformly random
word is the central index $k(n-k)/2$. Finally we address the headline statement —
that the central coefficient is the global maximum, i.e. full unimodality of the
Gaussian binomials. As this is a deep classical theorem (Sylvester 1878; first
elementary proof O'Hara 1990), we verify it as fully certified results for all
$n \le 8$ by exhaustive kernel computation and record the general statement, the
$q$-Pascal recurrence, the partition-in-a-box bijection, log-concavity, and a
variance formula as precisely stated conjectures for further work.

## 1. Introduction

### 1.1 Binomial equivalence of words

Let $A$ be a finite alphabet and $A^\ast$ the set of finite words over $A$. For
words $u, w \in A^\ast$, the *binomial coefficient* $\binom{w}{u}$ counts the
number of occurrences of $u$ as a **scattered subword** (subsequence) of $w$. Two
words $w, w'$ are *$m$-binomially equivalent*, written $w \sim_m w'$, when
$\binom{w}{u} = \binom{w'}{u}$ for every word $u$ of length at most $m$. This
equivalence, introduced by Rigo and Salimov, interpolates between the trivial
relation and full equality: as $m \to \infty$ the classes shrink to single words,
while for small $m$ they capture coarse statistical features of a word.

For the binary alphabet $A = \{0,1\}$ and $m = 2$, the relevant statistics are:
$\binom{w}{1} = k$ (the number of ones), $\binom{w}{0} = n-k$ (the number of
zeros, where $n = |w|$), and the four length-two counts $\binom{w}{11}$,
$\binom{w}{00}$, $\binom{w}{10}$, $\binom{w}{01}$. The first two are determined by
$k$ via $\binom{w}{11} = \binom{k}{2}$ and $\binom{w}{00} = \binom{n-k}{2}$, and
the last two satisfy $\binom{w}{10} + \binom{w}{01} = k(n-k)$. Hence a binary
2-binomial class is determined by the triple
$$ (n,\ k,\ i), \qquad i := \binom{w}{10} = \#\{(a,b) : a<b,\ w_a = 1,\ w_b = 0\}, $$
the **inversion number** of $w$ (scattered occurrences of $10$).

### 1.2 The Gaussian connection

The *Gaussian binomial coefficient* (or $q$-binomial coefficient) is the
polynomial
$$ \genfrac{[}{]}{0pt}{}{n}{k}_q \;=\; \prod_{j=1}^{k} \frac{1 - q^{\,n-k+j}}{1 - q^{\,j}} \;=\; \frac{[n]_q!}{[k]_q!\,[n-k]_q!}, \qquad [m]_q! := \prod_{r=1}^{m}\frac{1-q^r}{1-q}, $$
a polynomial in $q$ of degree $k(n-k)$ with nonnegative integer coefficients. A
theorem of MacMahon identifies these coefficients combinatorially:
$$ \genfrac{[}{]}{0pt}{}{n}{k}_q \;=\; \sum_{i \ge 0} \mathrm{classSize}(n,k,i)\, q^{\,i}, $$
where $\mathrm{classSize}(n,k,i)$ is the number of binary words of length $n$ with
$k$ ones and inversion number $i$. Thus the enumerative question "how large is the
2-binomial class $(n,k,i)$?" is identical to the algebraic question "what is the
$q^i$-coefficient of $\genfrac{[}{]}{0pt}{}{n}{k}_q$?".

This paper formalizes the elementary structural theory of $\mathrm{classSize}$ and
isolates the deep unimodality statement, verifying the latter computationally for
small parameters.

### 1.3 Notation and model

We work with $\mathrm{Fin}\,n = \{0,1,\dots,n-1\}$ as the set of positions. A
binary word of length $n$ with $k$ ones is encoded by the set
$S \subseteq \mathrm{Fin}\,n$ of positions carrying a one, with $|S| = k$. This
representation makes the total count immediate: the set of such words is the
collection of $k$-element subsets, of cardinality $\binom{n}{k}$.

## 2. Definitions

We give the formal definitions used throughout; they match the formalized
development verbatim in meaning.

**Definition 2.1 (Inversion number).** For $S \subseteq \mathrm{Fin}\,n$,
$$ \mathrm{invF}(S) \;:=\; \#\bigl\{(p_1,p_2) \in \mathrm{Fin}\,n \times \mathrm{Fin}\,n : p_1 < p_2,\ p_1 \in S,\ p_2 \notin S\bigr\}. $$
This counts ordered position pairs realizing a scattered $10$: a one to the left of
a zero.

**Definition 2.2 (Co-inversion number).** Dually,
$$ \mathrm{coinvF}(S) \;:=\; \#\bigl\{(p_1,p_2) : p_1 < p_2,\ p_1 \notin S,\ p_2 \in S\bigr\}, $$
counting scattered occurrences of $01$.

**Definition 2.3 (Words).** $\mathrm{words}(n,k) := \{\,S \subseteq \mathrm{Fin}\,n : |S| = k\,\}$,
the $k$-element subsets of $\mathrm{Fin}\,n$, i.e. the binary words of length $n$
with $k$ ones.

**Definition 2.4 (Class size).**
$$ \mathrm{classSize}(n,k,i) \;:=\; \#\{\,S \in \mathrm{words}(n,k) : \mathrm{invF}(S) = i\,\}. $$
By MacMahon's theorem this equals the coefficient of $q^i$ in
$\genfrac{[}{]}{0pt}{}{n}{k}_q$.

**Definition 2.5 (Central index).** $\mathrm{centralIndex}(n,k) := \lfloor k(n-k)/2 \rfloor$,
the integer midpoint of the support $\{0,1,\dots,k(n-k)\}$.

## 3. Main Results

### 3.1 The inversion ceiling

**Theorem 3.1 (`invF_le`).** *For every $S \subseteq \mathrm{Fin}\,n$ with
$|S| = k$,*
$$ \mathrm{invF}(S) \;\le\; k\,(n-k). $$

*Proof sketch.* Every counted pair $(p_1, p_2)$ has $p_1 \in S$ and
$p_2 \in \mathrm{Fin}\,n \setminus S$, so the set of inversions injects into the
product $S \times (\mathrm{Fin}\,n \setminus S)$. Hence its cardinality is at most
$|S| \cdot |\mathrm{Fin}\,n \setminus S| = k(n-k)$. (The condition $p_1 < p_2$ only
removes pairs, so dropping it gives the upper bound.) $\square$

**Corollary 3.2 (`classSize_eq_zero_of_gt`).** *If $k(n-k) < i$ then
$\mathrm{classSize}(n,k,i) = 0$.*

*Proof sketch.* By Theorem 3.1 no word of the right shape attains inversion number
exceeding $k(n-k)$, so the defining filter is empty and the cardinality is zero.
$\square$

### 3.2 The row-sum identity

**Theorem 3.3 (`total_eq_choose`).** *For all $n, k$,*
$$ \sum_{i=0}^{k(n-k)} \mathrm{classSize}(n,k,i) \;=\; \binom{n}{k}. $$

*Proof sketch.* The classes
$\{\,S \in \mathrm{words}(n,k) : \mathrm{invF}(S) = i\,\}$ partition
$\mathrm{words}(n,k)$ as $i$ ranges over $\{0,\dots,k(n-k)\}$ — every word has a
well-defined inversion number, which by Theorem 3.1 lies in this range. Summing the
fiber cardinalities over a partition recovers the cardinality of the whole set
(the fiberwise cardinality identity), and $|\mathrm{words}(n,k)| = \binom{n}{k}$
since $\mathrm{words}(n,k)$ is the set of $k$-element subsets of an $n$-element
set. $\square$

This identity is the specialization $q = 1$ of MacMahon's theorem:
$\genfrac{[}{]}{0pt}{}{n}{k}_1 = \binom{n}{k}$.

### 3.3 Inversions and co-inversions partition the mixed pairs

**Lemma 3.4 (`invF_image_rev`).** *Let $\mathrm{rev}: \mathrm{Fin}\,n \to \mathrm{Fin}\,n$
be the order-reversing involution $\mathrm{rev}(p) = n-1-p$. Then*
$$ \mathrm{invF}\bigl(\mathrm{rev}(S)\bigr) \;=\; \mathrm{coinvF}(S). $$

*Proof sketch.* The map $(p_1, p_2) \mapsto (\mathrm{rev}(p_2), \mathrm{rev}(p_1))$
is a bijection from the co-inversions of $S$ to the inversions of $\mathrm{rev}(S)$:
it reverses the order relation ($p_1 < p_2 \iff \mathrm{rev}(p_2) < \mathrm{rev}(p_1)$)
and exchanges the membership conditions ($p_1 \notin S$, $p_2 \in S$ become
$\mathrm{rev}(p_1) \notin \mathrm{rev}(S)$, $\mathrm{rev}(p_2) \in \mathrm{rev}(S)$),
which is exactly the inversion condition for $\mathrm{rev}(S)$. A cardinality-preserving
bijection gives the equality. $\square$

**Lemma 3.5 (`invF_add_coinvF`).** *For $|S| = k$,*
$$ \mathrm{invF}(S) + \mathrm{coinvF}(S) \;=\; k\,(n-k). $$

*Proof sketch.* A pair $(p_1, p_2)$ with $p_1 < p_2$ is counted by exactly one of
$\mathrm{invF}$ or $\mathrm{coinvF}$ precisely when its two positions have opposite
membership in $S$ (one in, one out). The inversions and co-inversions are disjoint
and their union is the set of "mixed" ordered pairs $p_1 < p_2$ with exactly one of
$p_1, p_2$ in $S$. Each unordered mixed pair $\{a,b\}$ with $a \in S$, $b \notin S$
contributes exactly one ordered pair with smaller-first, so the union has
cardinality $|S \times (\mathrm{Fin}\,n \setminus S)| = k(n-k)$. Adding the two
disjoint counts gives the claim. $\square$

### 3.4 Palindromic symmetry

**Theorem 3.6 (`classSize_symm`).** *For all $n, k$ and all $i \le k(n-k)$,*
$$ \mathrm{classSize}(n,k,i) \;=\; \mathrm{classSize}\bigl(n,k,\ k(n-k) - i\bigr). $$

*Proof sketch.* The map $S \mapsto \mathrm{rev}(S)$ (image under the order-reversing
involution) is a bijection of $\mathrm{words}(n,k)$ to itself: it preserves
cardinality, since $\mathrm{rev}$ is injective, and is its own inverse. By Lemma 3.4
and Lemma 3.5, if $\mathrm{invF}(S) = i$ then
$$ \mathrm{invF}(\mathrm{rev}(S)) = \mathrm{coinvF}(S) = k(n-k) - \mathrm{invF}(S) = k(n-k) - i. $$
Thus $\mathrm{rev}$ restricts to a bijection between the class at inversion number
$i$ and the class at inversion number $k(n-k)-i$, so the two classes have equal
size. $\square$

**Corollary 3.7 (Mean inversion number, `inv_weighted_sum`).** *Under the uniform
distribution on $\mathrm{words}(n,k)$, the expected inversion number is the central
index:*
$$ \mathbb{E}[\mathrm{invF}] \;=\; \frac{1}{\binom{n}{k}}\sum_{i=0}^{k(n-k)} i\cdot \mathrm{classSize}(n,k,i) \;=\; \frac{k(n-k)}{2}. $$

*Proof sketch.* Pair each term $i$ with its mirror $k(n-k)-i$; by Theorem 3.6 they
carry equal weight, and their average index is $k(n-k)/2$. Summing the paired
averages and dividing by the total $\binom{n}{k}$ (Theorem 3.3) gives the mean.
Equivalently, $\mathrm{invF}(S) + \mathrm{invF}(\mathrm{rev}(S)) = k(n-k)$ for the
reversal involution, so averaging $\mathrm{invF}$ over the involution-invariant
uniform measure yields half of $k(n-k)$. $\square$

### 3.5 Central maximality (the headline)

**Theorem 3.8 (`central_max_*`, verified for $n \le 8$).** *For every $n \le 8$,
every $0 \le k \le n$, and every $i$,*
$$ \mathrm{classSize}(n,k,i) \;\le\; \mathrm{classSize}\bigl(n,k,\ \lfloor k(n-k)/2 \rfloor\bigr). $$

*Status and method.* This is the assertion that the central coefficient of
$\genfrac{[}{]}{0pt}{}{n}{k}_q$ is the global maximum, a special case of the
**unimodality of Gaussian binomial coefficients**. Unimodality in general is a
celebrated deep theorem: it was first established by Sylvester (1878) using the
invariant theory of binary forms; it admits a representation-theoretic proof via
the action of $\mathfrak{sl}_2$ (equivalently the hard Lefschetz theorem on the
cohomology of a Grassmannian); and the first elementary, purely combinatorial
proof is due to O'Hara (1990). We do **not** prove the general statement. Instead,
for each fixed $n \le 8$ the inequality is a finite assertion over the finite set
$\mathrm{words}(n,k)$, which is decided by exhaustive kernel/native computation —
a complete, certified check rather than numerical sampling. The general inequality
is recorded as Conjecture C1 below.

## 4. Algorithms

### 4.1 Direct class-size computation

The most transparent algorithm enumerates the $\binom{n}{k}$ subsets and tabulates
inversion numbers. Computing $\mathrm{invF}(S)$ by examining all ordered pairs
costs $O(n^2)$ per word; a linear-scan variant maintains a running count of ones
seen so far and adds it whenever a zero is encountered, costing $O(n)$ per word.
The full row $\genfrac{[}{]}{0pt}{}{n}{k}_q$ thus costs $O\!\left(n\binom{n}{k}\right)$.

### 4.2 The $q$-Pascal recurrence (conjectural inductive engine)

Conditioning on the last letter of a word gives the recurrence (Conjecture C2):
appending a $1$ adds $0$ inversions, while appending a $0$ adds $k$ inversions
(one for each of the $k$ ones now to its left). This yields a dynamic program
computing the entire triangle of $\mathrm{classSize}(n,k,i)$ in
$O\!\left(\sum_{n,k} k(n-k)\right)$ arithmetic operations, far cheaper than
enumeration, and is the natural substrate for an inductive proof of unimodality.

### 4.3 Partition-in-a-box enumeration (conjectural)

By Conjecture C3, $\mathrm{classSize}(n,k,i)$ equals the number of integer
partitions of $i$ into at most $k$ parts each at most $n-k$. Enumerating such
partitions provides an independent algorithm and links the development to the
theory of partitions inside a bounding box.

## 5. Applications

**Statistical mechanics.** Interpreting a binary word as a configuration of two
species on a one-dimensional lattice with energy equal to the inversion number,
$\genfrac{[}{]}{0pt}{}{n}{k}_q$ is the canonical partition function with
$q = e^{-\beta\epsilon}$ a Boltzmann weight, and $\mathrm{classSize}(n,k,i)$ is the
degeneracy of energy level $i$. Central maximality says the modal energy is the
mean energy $k(n-k)/2$.

**Concentration of measure.** The inversion statistic of a uniform random word has
mean $k(n-k)/2$ (Corollary 3.7) and, conjecturally, variance $k(n-k)(n+1)/12$
(Conjecture C5). Palindromic symmetry plus unimodality make the distribution a
sharply peaked, symmetric discrete law — a combinatorial analogue of Gaussian
concentration.

**$q$-analogues and finite geometry.** Over the finite field $\mathbb{F}_q$,
$\genfrac{[}{]}{0pt}{}{n}{k}_q$ counts $k$-dimensional subspaces of
$\mathbb{F}_q^n$; the same coefficients thus enumerate flags and subspace lattices,
linking the word statistics to finite projective geometry and to the combinatorics
of quantum groups.

## 6. Discussion

The development illustrates a deliberate epistemic separation. The structural
results — the ceiling (Theorem 3.1), vanishing (Corollary 3.2), the row sum
(Theorem 3.3), the inversion/co-inversion decomposition (Lemmas 3.4–3.5), and
palindromic symmetry (Theorem 3.6) with its probabilistic corollary (Corollary
3.7) — are elementary, general, and proved in full. The reversal bijection is the
workhorse: it simultaneously yields symmetry and the mean. By contrast, central
maximality is a manifestation of a genuinely deep phenomenon; rather than overstate
what is proved, the development certifies it exhaustively for small parameters and
states the general case as a conjecture. The choice of the positions-of-ones model
($\mathrm{Finset}(\mathrm{Fin}\,n)$) is what makes the row sum immediate, via the
cardinality of the collection of $k$-subsets — a small modeling decision with
outsized payoff, replacing an awkward count over $\mathrm{Fin}\,n \to \mathrm{Bool}$.

## 7. Future Directions

We restate the principal open problems; each is falsifiable on small parameters.

**C1 (Full unimodality).** For all $n,k,i$,
$\mathrm{classSize}(n,k,i) \le \mathrm{classSize}(n,k,\lfloor k(n-k)/2\rfloor)$,
and moreover $i \mapsto \mathrm{classSize}(n,k,i)$ is unimodal (nondecreasing up to
the central index, nonincreasing after). This is the general unimodality of
Gaussian binomials (Sylvester; O'Hara). Suggested route: the $q$-Pascal recurrence
(C2) together with an O'Hara-style partition injection.

**C2 ($q$-Pascal recurrence).** For $0 < k \le n$ and $k \le i$,
$\mathrm{classSize}(n+1,k,i) = \mathrm{classSize}(n,k-1,i) + \mathrm{classSize}(n,k,i-k)$,
with boundary $\mathrm{classSize}(n+1,k,i) = \mathrm{classSize}(n,k-1,i)$ when
$i < k$. Obtained by conditioning on whether the last letter is $1$ (adds $0$
inversions) or $0$ (adds $k$).

**C3 (Partition-in-a-box bijection).** $\mathrm{classSize}(n,k,i)$ equals the
number of partitions of $i$ into at most $k$ parts, each at most $n-k$. Connects to
the theory of partitions inside a box and is the natural substrate for an
O'Hara-type proof of C1.

**C4 (Strict unimodality and log-concavity).** For $0 < k < n$, the sequence is
strictly increasing on $0 \le i \le k(n-k)/2$ (the central class strictly dominates
every non-central class), and the coefficients are log-concave:
$\mathrm{classSize}(n,k,i)^2 \ge \mathrm{classSize}(n,k,i-1)\,\mathrm{classSize}(n,k,i+1)$.
(Log-concavity of Gaussian coefficients is open in general.)

**C5 (Variance / concentration).** Under the uniform distribution, beyond the mean
$k(n-k)/2$, the variance of the inversion statistic is $k(n-k)(n+1)/12$;
denominator-free, $12\sum_i (i - \mu)^2\,\mathrm{classSize}(n,k,i) = k(n-k)(n+1)\binom{n}{k}$
with $\mu = k(n-k)/2$. Provable from a second application of the reflection
symmetry together with a second-moment computation.

## 8. Conclusion

For binary words, the 2-binomial class indexed by $(n,k,i)$ has size equal to the
$q^i$-coefficient of the Gaussian binomial $\genfrac{[}{]}{0pt}{}{n}{k}_q$. We
proved the elementary structural laws governing these sizes — boundedness,
vanishing, summation to $\binom{n}{k}$, and palindromic symmetry — with a single
reversal bijection at the technical core, and we derived that the mean inversion
number of a random word is exactly the central index $k(n-k)/2$. The statement that
the central class is the largest is the deep unimodality of Gaussian binomials; we
certified it exhaustively for all $n \le 8$ and laid out a concrete program —
$q$-Pascal recurrence, box-partition bijection, log-concavity, and a variance
identity — toward the general result.

## References (classical, for context)

- P. A. MacMahon, *Combinatory Analysis*, treating the generating function of the
  inversion statistic.
- J. J. Sylvester, *Proof of the hitherto undemonstrated fundamental theorem of
  invariants* (1878), establishing unimodality of Gaussian coefficients.
- K. M. O'Hara, *Unimodality of Gaussian coefficients: a constructive proof*
  (1990).
- M. Rigo and P. Salimov, work introducing $m$-binomial equivalence of words.
