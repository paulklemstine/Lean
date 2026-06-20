# The Combinatorial and Probabilistic Structure of the Library of Babel

**Author:** Aristotle

**Domain:** Applications (combinatorics, finite probability, formal language modeling)

---

## Abstract

Borges' *Library of Babel* is the set of all texts of a fixed length over a fixed finite alphabet. We treat this library as a genuine finite probability space and establish its exact combinatorial and probabilistic structure. Modeling a *volume* of length $L$ over an alphabet of $b$ symbols as a function $v : \mathrm{Fin}\,L \to \mathrm{Fin}\,b$, we prove four principal results: (i) the library has cardinality exactly $b^L$; (ii) under the uniform distribution each volume has probability exactly $b^{-L}$; (iii) the expected number of occurrences of a fixed pattern of length $k \le L$ in a uniformly random volume is exactly $(L-k+1)\,b^{-k}$; and (iv) the probability that a random volume contains a fixed pattern *somewhere* is at most $(L-k+1)\,b^{-k}$, via a union bound. The technical core is a counting lemma showing that the number of volumes agreeing with a fixed assignment along an injective family of $k$ positions is exactly $b^{\,L-k}$; the occurrence-count and probability statements are then assembled from this by linearity of expectation and the union bound, respectively. All degenerate regimes ($b=0$, $b=1$, $L=0$, $k=0$, $k=L$) are handled rigorously. The development is fully formalized and machine-checked. We discuss applications to substring statistics, coding theory (Hamming geometry), random-text models, and the interpretation of "finding meaning" in universal information spaces, and we outline directions toward exact multi-window inclusion–exclusion, Hamming-sphere enumeration, and automaton-defined notions of meaning.

---

## 1. Introduction

In *The Library of Babel* (1941), Jorge Luis Borges describes a universe consisting of an enormous collection of books. Each book has $410$ pages, each page $40$ lines, each line $80$ characters, with characters drawn from a fixed alphabet of $25$ orthographic symbols (twenty-two letters, the comma, the period, and the space). The defining property of the Library is *completeness*: it contains every possible book of this format. Consequently it contains every truth, every falsehood, every refutation of every truth, and overwhelmingly more noise than either.

The Library is finite. With $410 \times 40 \times 80 = 1{,}312{,}000$ characters per volume and $25$ symbols, the number of distinct volumes is $25^{1{,}312{,}000}$ — finite, but vastly larger than any quantity of physical relevance. Borges' story dramatizes the paradox of *total information without access*: everything is present, nothing is findable.

This paper takes the Library literally and develops its exact mathematics. We make no approximations and prove no asymptotics; every statement is an exact finite identity or a clean inequality, valid for all parameter values including the degenerate ones. The contributions are:

1. **Exact cardinality** (Theorem 1): the Library has $b^L$ volumes.
2. **Uniform single-volume probability** (Theorem 2): each volume has probability $b^{-L}$.
3. **A general agreement-counting lemma** (Lemma A, Lemma B): the number of volumes agreeing with a fixed pattern along $k$ distinct positions is $b^{L-k}$.
4. **Exact expected substring count** (Theorem 3): the expected number of occurrences of a length-$k$ pattern is $(L-k+1)\,b^{-k}$.
5. **A union-bound containment inequality** (Theorem 4): the probability a random volume contains a length-$k$ pattern is at most $(L-k+1)\,b^{-k}$.

Throughout, $b$ is the alphabet size, $L$ the volume length, and $k$ the pattern length, all natural numbers.

---

## 2. Definitions

We work over the finite types $\mathrm{Fin}\,n = \{0, 1, \dots, n-1\}$.

**Definition 2.1 (Volume).** A *volume* of length $L$ over an alphabet of $b$ symbols is a function
$$v : \mathrm{Fin}\,L \to \mathrm{Fin}\,b.$$
Position $i \in \mathrm{Fin}\,L$ holds the symbol $v(i) \in \mathrm{Fin}\,b$.

**Definition 2.2 (Library).** The *Library* $\mathcal{L}(b, L)$ is the (finite) set of all volumes of length $L$ over $b$ symbols:
$$\mathcal{L}(b, L) = \{\, v : \mathrm{Fin}\,L \to \mathrm{Fin}\,b \,\}.$$
As a finite set it is the full universe of the function type $\mathrm{Fin}\,L \to \mathrm{Fin}\,b$.

**Definition 2.3 (Uniform probability).** For a finite sample space $S$ (a finite set) and an event $A \subseteq S$, the *uniform probability* of $A$ within $S$ is the counting ratio
$$\mathrm{prob}(S, A) = \frac{|\{x \in S : x \in A\}|}{|S|} \in \mathbb{R}.$$
Taking $S = \mathcal{L}(b,L)$ realizes the uniform measure on the Library. (When $|S| = 0$ the ratio is $0/0 = 0$ by convention; the meaningful probability statements below carry hypotheses that exclude an empty sample space.)

**Definition 2.4 (Reading a position).** For a volume $v$ and a natural number $n$, define
$$\mathrm{read}(v, n) = \begin{cases} \mathrm{some}\;v(n) & n < L, \\ \mathrm{none} & n \ge L. \end{cases}$$
This makes reading total over all of $\mathbb{N}$ while signaling out-of-range access, which is convenient for windows that might overflow the right edge.

**Definition 2.5 (Occurrence at a position).** A pattern $p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$ *occurs in* $v$ *at position* $i \in \mathbb{N}$, written $\mathrm{OccursAt}(p, v, i)$, iff
$$\forall\, j \in \mathrm{Fin}\,k,\quad \mathrm{read}(v,\, i + j) = \mathrm{some}\;p(j).$$
That is, the $k$-symbol window of $v$ beginning at $i$ exists in range and equals $p$ symbol by symbol. This predicate is decidable.

**Definition 2.6 (Occurrence count).** The number of starting positions at which $p$ occurs in $v$ is
$$\mathrm{occ}(p, v) = \bigl|\{\, i \in \{0, 1, \dots, L-k\} : \mathrm{OccursAt}(p, v, i) \,\}\bigr|,$$
the count over the index range $\{0, \dots, (L-k+1)-1\}$ of valid window starts. (In truncated natural-number arithmetic, $L - k + 1$ correctly degenerates when $k > L$.)

**Definition 2.7 (Containment).** A pattern $p$ is *contained* in $v$, written $\mathrm{Contains}(p, v)$, iff there exists $i \in \mathbb{N}$ with $\mathrm{OccursAt}(p, v, i)$.

**Definition 2.8 (Expected occurrences).** The *expected number of occurrences* of a pattern $p$ of length $k$ in a uniformly random volume of length $L$ is the average of $\mathrm{occ}(p, v)$ over the Library:
$$\mathbb{E}[\mathrm{occ}] = \frac{1}{|\mathcal{L}(b,L)|}\sum_{v \in \mathcal{L}(b,L)} \mathrm{occ}(p, v).$$

---

## 3. Cardinality and single-volume probability

**Theorem 1 (Cardinality of the Library; `card_library`).** For all $b, L \in \mathbb{N}$,
$$|\mathcal{L}(b, L)| = b^L.$$

*Proof sketch.* The Library is the full set of functions $\mathrm{Fin}\,L \to \mathrm{Fin}\,b$. The cardinality of a function type between finite types is $|\text{codomain}|^{|\text{domain}|} = b^L$. Formally this is the standard count $|\,A \to B\,| = |B|^{|A|}$ specialized to $A = \mathrm{Fin}\,L$, $B = \mathrm{Fin}\,b$. $\;\square$

For Borges' constants, $|\mathcal{L}(25, 1312000)| = 25^{1312000}$, recovering the headline number of the story as an exact identity.

**Theorem 2 (Single-volume probability; `prob_singleton`).** For all $b, L \in \mathbb{N}$ and every volume $v \in \mathcal{L}(b,L)$,
$$\mathrm{prob}\bigl(\mathcal{L}(b,L),\, \{v\}\bigr) = b^{-L}.$$

*Proof sketch.* The event $\{v\}$ contains exactly one point of the Library, so the filtered count in the numerator of Definition 2.3 is $1$. The denominator is $|\mathcal{L}(b,L)| = b^L$ by Theorem 1. The ratio is $1/b^L = b^{-L}$, interpreted as a real (integer) power; the negative-exponent form $b^{-L}$ is the same value over the reals. $\;\square$

Theorem 2 formalizes the "democracy of the Library": no volume is favored; coherent masterpieces and pure noise share the identical probability $b^{-L}$.

---

## 4. The agreement-counting core

The substantive combinatorial content of the theory is a single lemma about counting functions constrained on part of their domain. We state it first in full generality and then specialize.

**Lemma A (Counting agreements under a predicate; `card_filter_agree`).** Let $A$ and $B$ be finite types with decidable equality, let $p$ be a decidable predicate on $A$, and fix a reference function $g : A \to B$. Then the number of functions $v : A \to B$ that agree with $g$ at every point where $p$ holds is
$$\bigl|\{\, v : A \to B : \forall a,\ p(a) \Rightarrow v(a) = g(a) \,\}\bigr| = |B|^{\,|\{a : \neg p(a)\}|}.$$

*Proof sketch.* The constrained set is in bijection with the dependent product $\prod_{a \in A} S_a$, where $S_a = \{g(a)\}$ if $p(a)$ and $S_a = B$ otherwise: a function satisfies the constraint exactly when its value at each $a$ lies in $S_a$. The cardinality of a dependent product over a finite index is $\prod_a |S_a|$. Each constrained coordinate contributes a factor $1$ and each free coordinate a factor $|B|$, so the product equals $|B|$ raised to the number of free coordinates, i.e. the number of $a$ with $\neg p(a)$. Rewriting the product of equal powers as a power of a sum (a count) gives the claimed exponent. $\;\square$

**Lemma B (Agreement along injective positions; `card_agree_inj`).** Let $\varphi : \mathrm{Fin}\,k \to \mathrm{Fin}\,L$ be injective and let $p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$ be any pattern. Then the number of volumes agreeing with $p$ along the positions $\varphi$ is
$$\bigl|\{\, v \in \mathcal{L}(b,L) : \forall j,\ v(\varphi(j)) = p(j) \,\}\bigr| = b^{\,L-k}.$$

*Proof sketch.* Apply Lemma A with $A = \mathrm{Fin}\,L$, $B = \mathrm{Fin}\,b$, predicate "lies in the image of $\varphi$," and reference function sending each constrained position $\varphi(j)$ to $p(j)$. Because $\varphi$ is injective, its image has exactly $k$ elements, so the number of *unconstrained* positions is $L - k$, and Lemma A yields $|B|^{L-k} = b^{L-k}$. The degenerate alphabet $b = 0$ is handled separately: if $k = 0$ the empty constraint leaves $b^L$ volumes (here $0^0 = 1$ when $L = 0$, else $0$), and if $k > 0$ the pattern $p$ would force a symbol into the empty alphabet $\mathrm{Fin}\,0$, which is impossible, so both sides vanish consistently. $\;\square$

**Lemma C (Volumes with an occurrence at a fixed position; `card_occursAt`).** For a pattern $p$ of length $k$ and a position $i$ with $i + k \le L$,
$$\bigl|\{\, v \in \mathcal{L}(b,L) : \mathrm{OccursAt}(p, v, i) \,\}\bigr| = b^{\,L-k}.$$

*Proof sketch.* The window-start injection $\varphi(j) = i + j$ (valid since $i + k \le L$) is injective, and $\mathrm{OccursAt}(p, v, i)$ is, after unfolding $\mathrm{read}$, exactly the agreement condition $\forall j,\ v(\varphi(j)) = p(j)$. Apply Lemma B. $\;\square$

Lemma C is the *atomic event* of the theory: it gives the exact size of each "cylinder set" $\{v : \text{window } i \text{ equals } p\}$, namely $b^{L-k}$, independent of $i$. Every subsequent probabilistic statement is built from these atoms.

---

## 5. Expected number of occurrences

**Theorem 3 (Exact expected substring count; `expected_substring_count`).** Let $k \le L$ and $b \ge 1$, and let $p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$ be any pattern. Then the expected number of occurrences of $p$ in a uniformly random volume of length $L$ is exactly
$$\mathbb{E}[\mathrm{occ}] = (L - k + 1)\, b^{-k}.$$

*Proof sketch.* Write $\mathrm{occ}(p,v) = \sum_{i=0}^{L-k} \mathbf{1}[\mathrm{OccursAt}(p,v,i)]$ as a sum of indicator variables over the $L-k+1$ window starts. Summing over all volumes and exchanging the two finite sums (Fubini for finite sums),
$$\sum_{v} \mathrm{occ}(p,v) = \sum_{i=0}^{L-k} \bigl|\{v : \mathrm{OccursAt}(p,v,i)\}\bigr| = \sum_{i=0}^{L-k} b^{L-k} = (L-k+1)\,b^{L-k},$$
where the inner cardinality is $b^{L-k}$ by Lemma C (each $i$ in range satisfies $i + k \le L$). Dividing by $|\mathcal{L}(b,L)| = b^L$ (Theorem 1) gives
$$\mathbb{E}[\mathrm{occ}] = \frac{(L-k+1)\,b^{L-k}}{b^L} = (L-k+1)\,b^{-k},$$
using $b^{L-k}/b^L = b^{-k}$, valid since $b \ge 1$ ensures $b^L \ne 0$ and $k \le L$ keeps the exponent arithmetic exact. $\;\square$

This is the central quantitative result. Two structural features deserve emphasis. First, it is an *equality*, not an estimate: linearity of expectation requires no independence among the (heavily overlapping) window events, so the average is exact. Second, the dependence on $k$ is *exponential decay* $b^{-k}$ modulated by the *linear* position count $L - k + 1$: short patterns are abundant, long patterns are exponentially suppressed. This is the precise mathematical statement of the intuition that the Library is rich in fragments and poor in coherent texts.

---

## 6. Probability of containment

**Theorem 4 (Union-bound containment inequality; `prob_contains_substring_bound`).** Let $k \le L$ and let $p : \mathrm{Fin}\,k \to \mathrm{Fin}\,b$ be any pattern. Then
$$\mathrm{prob}\bigl(\mathcal{L}(b,L),\, \{v : \mathrm{Contains}(p, v)\}\bigr) \;\le\; (L - k + 1)\, b^{-k}.$$

*Proof sketch.* The containment event is the union over window starts of the atomic occurrence events:
$$\{v : \mathrm{Contains}(p,v)\} \subseteq \bigcup_{i=0}^{L-k} \{v : \mathrm{OccursAt}(p,v,i)\}.$$
(Any occurrence forces the window to fit, hence $i \le L - k$; in particular when $k > 0$ the last pattern symbol must be in range. The case $k = 0$ is handled directly, the empty pattern occurring at $i = 0$.) By subadditivity of cardinality over a union (the union bound),
$$\bigl|\{v : \mathrm{Contains}(p,v)\}\bigr| \le \sum_{i=0}^{L-k} \bigl|\{v : \mathrm{OccursAt}(p,v,i)\}\bigr| = (L-k+1)\,b^{L-k},$$
again by Lemma C. Dividing by $b^L$ and simplifying $b^{L-k}/b^L = b^{-k}$ yields the bound. For the degenerate alphabet $b = 0$ the statement holds vacuously/trivially (an empty or one-point analysis), which is dispatched separately. $\;\square$

The same expression $(L-k+1)\,b^{-k}$ that gives the *exact* expected count also *caps* the containment probability. This is the expected relationship: by Markov's inequality the probability of at least one occurrence is bounded by the expected number of occurrences, and Theorem 4 makes this concrete and self-contained for the Library. When the right-hand side exceeds $1$ the bound is vacuous, exactly as it must be, since probabilities never exceed $1$.

---

## 7. Worked numerics

The formulas are concrete enough to evaluate directly.

- **A four-letter word in a novel.** With $b = 26$, $k = 4$, $L = 1{,}000{,}000$, the expected number of occurrences of any fixed four-letter pattern is $(10^6 - 3)\cdot 26^{-4} = 999997 / 456976 \approx 2.1882$. A random million-character book contains, on average, about two copies of any given four-letter string, and the probability it contains a fixed four-letter string at least once is at most $\approx 1$ (the bound is non-trivial only for rarer patterns).

- **A short phrase.** With $b = 26$, $k = 12$ (a twelve-character phrase), $L = 1{,}000{,}000$, the expected count is $(10^6 - 11)\cdot 26^{-12} \approx 9.99989\times 10^5 / 9.5428\times 10^{16} \approx 1.05 \times 10^{-11}$. The containment probability is at most about $10^{-11}$: such a phrase is essentially never found by chance in a single book.

- **Borges' constants.** With $b = 25$, $L = 1{,}312{,}000$: the Library has $25^{1312000}$ volumes (Theorem 1) and each has probability $25^{-1312000}$ (Theorem 2). A fixed page-length pattern of $k = 3200$ characters has expected count $(1312000 - 3199)\cdot 25^{-3200}$ — a number whose order of magnitude is $\approx 10^{6.1}\cdot 10^{-4472} \approx 10^{-4466}$: present in the Library in vast absolute numbers, yet utterly absent from any single random draw.

These illustrate the qualitative law: occurrence counts decay like $b^{-k}$, so the boundary between "ubiquitous" and "unfindable" is crossed within a handful of additional symbols.

---

## 8. Algorithms

The proofs are constructive and translate directly into exact-arithmetic algorithms.

**Algorithm 1 (Exact expected occurrences).** Given $b, L, k$ with $k \le L$ and $b \ge 1$, return the exact rational $(L-k+1)/b^{k}$. Complexity: one big-integer exponentiation and a division, $O(k \cdot M(\log b))$ bit operations where $M$ is integer-multiplication cost; with fast exponentiation, $O(\log k)$ multiplications of growing integers.

**Algorithm 2 (Containment upper bound).** Given $b, L, k$, return $\min\bigl(1,\ (L-k+1)/b^{k}\bigr)$ as the certified ceiling on containment probability. Same complexity as Algorithm 1.

**Algorithm 3 (Brute-force verification on a mini-Library).** For small $b, L$, enumerate all $b^L$ volumes, compute $\mathrm{occ}(p,v)$ for each by scanning the $L-k+1$ windows, and average. This validates Theorem 3 numerically and is the basis of the regression tests in the accompanying demo. Complexity: $O(b^L \cdot (L-k+1)\cdot k)$ — exponential in $L$, hence restricted to mini-Libraries (e.g. $b=2, L\le 16$).

---

## 9. Applications

**Substring statistics in random text.** Theorems 3 and 4 are the foundational facts of the random-string model used throughout the analysis of string algorithms, $q$-gram indexing, and bioinformatics seed statistics. The exact count $(L-k+1)\,b^{-k}$ is the expected number of spurious $k$-mer hits, calibrating false-positive rates for seed-and-extend search.

**Coding theory and Hamming geometry.** Volumes are precisely codewords of length $L$ over a $b$-ary alphabet. The agreement-counting Lemma B is the combinatorial backbone of sphere-packing bounds: fixing symbols on a coordinate set and counting the free completions is exactly the operation underlying Hamming-ball cardinalities and the Singleton and Gilbert–Varshamov bounds. The present results supply the exact "cylinder" counts those bounds aggregate.

**Universal information spaces.** The Library models any space of fixed-length records over a finite alphabet — DNA of fixed length, fixed-width binary files, fixed-length passwords. Theorem 2 quantifies brute-force search difficulty (each candidate has probability $b^{-L}$); Theorem 4 quantifies the probability that a target pattern lurks in a random record.

**The semantics of "meaning."** Identifying "meaningful" texts with a decidable predicate $P$, the uniform probability of meaning is the exact ratio $|\{v : P(v)\}| / b^L$. The framework reduces the philosophical question "how rare is meaning?" to an exact counting problem; the present paper solves the special case where $P$ is "contains a fixed pattern."

---

## 10. Discussion

The Library of Babel is often invoked as a metaphor for informational futility. The mathematics reframes it as an exactly understood finite object. Three points stand out.

*Exactness without independence.* The expected-occurrence identity (Theorem 3) holds despite the strong dependence among overlapping windows. This is the recurring lesson of linearity of expectation: averages add even when events do not. The autocorrelation structure of a pattern affects its *variance* and the *exact* containment probability, but never the mean count.

*The mean–tail bridge.* Theorem 4 is the union bound, equivalently Markov's inequality applied to the (integer-valued) occurrence count. The fact that the same closed form $(L-k+1)\,b^{-k}$ serves as both the exact mean and the probability ceiling is what makes the Library tractable: one formula governs both abundance and rarity.

*Robust degeneracy.* Empty and unary alphabets, empty patterns, and full-length patterns are not swept under the rug. That the identities survive $b \in \{0,1\}$ and $k \in \{0, L\}$ is what elevates the development from heuristic to theorem.

---

## 11. Future directions

*The following directions were identified during the formal development.*

**1. Exact multi-window inclusion–exclusion.** The atomic cylinder count $b^{L-k}$ for a single fixed window is established. The next step is the count of volumes matching *several* patterns at several fixed (possibly overlapping) offsets simultaneously, and ultimately the count of volumes containing a pattern *somewhere*, exactly rather than as a bound. Overlapping window constraints do not multiply independently; their joint count is governed by the overlap (autocorrelation) structure, so the right tool is inclusion–exclusion over the lattice of position constraints, with incompatible overlaps contributing zero. Because the single-window cylinder equivalence is already explicit, this is now an assembly problem rather than a foundational one.

**2. Hamming sphere and ball enumeration.** The radius-zero sphere has cardinality $1$; the conjectured general sphere formula is $\binom{n}{d}(k-1)^d$ for the number of words at Hamming distance exactly $d$ from a fixed center over a $k$-ary alphabet of length $n$. A volume at distance exactly $d$ is determined by two independent choices — a $d$-element subset of positions to corrupt, and, at each, one of the $k-1$ alternative symbols — giving an explicit bijection with $\{S \subseteq \mathrm{Fin}\,n : |S| = d\} \times (S \to \mathrm{Fin}(k-1))$. Summing over $d$ yields closed Hamming-ball counts, cross-checked by the binomial identity $(1 + (k-1))^n = k^n$.

**3. Finite automata for meaningful-text predicates.** The meaningful-count construction tallies volumes satisfying any decidable predicate but treats it as a black box. Instantiating the predicate as recognition by a finite automaton (a regular language of "well-formed" strings) turns the count into a transfer-matrix path-counting computation: the number of accepted length-$n$ strings is an entry of the $n$-th power of the automaton's transition matrix. This converts the vague "probability of meaning" into an exact, computable spectral quantity, slotting directly into the probability-as-ratio interface already established.

---

## 12. Conclusion

We have given the Library of Babel an exact combinatorial and probabilistic anatomy: $b^L$ volumes (Theorem 1), each of probability $b^{-L}$ (Theorem 2); an agreement-counting lemma giving $b^{L-k}$ completions through $k$ fixed positions (Lemmas A–C); an exact expected substring count $(L-k+1)\,b^{-k}$ (Theorem 3); and a matching containment ceiling $(L-k+1)\,b^{-k}$ (Theorem 4). Every degenerate regime is handled. The Library is finite, regular, and democratic; meaning within it is not absent but exponentially priced, and the price is exactly $(L-k+1)\,b^{-k}$.
