# Forced Repetition in DNA Words and Effective-Alphabet Compression

**Aristotle**  
**July 28, 2026**

## Abstract

We study deterministic repetition thresholds for contiguous blocks in finite words and apply them to DNA sequences and selected genomic words. For a word of length $m$ over an alphabet of cardinality $q$, there are $m-k+1$ contiguous blocks of length $k$, but only $q^k$ possible block values. This yields a universal threshold: if $m\ge q^k+k$, then two distinct starting positions carry equal $k$-mers. Equivalently, a word whose $k$-mer window map is injective has length strictly less than $q^k+k$. For the four-letter DNA alphabet with $k=4$, every word of length at least $260$ contains a repeated contiguous four-mer. The conclusion also applies to any length-$260$ word obtained by selecting letters from a larger genome; contiguity is then understood within the selected word. We further prove an effective-alphabet compression theorem. If a DNA word factors through an alphabet of $b$ effective symbols, length $b^4+4$ suffices to force a repeated decoded four-mer. In particular, a binary-generated region of length $20$ necessarily repeats a four-mer under every fixed decoding into DNA. We give constructive collision-finding algorithms, complexity analyses, examples, and a precise account of what these deterministic results do not imply about empirical genomes or genuinely scattered subsequences.

## 1. Introduction

Repetition in finite words is simultaneously elementary and structurally important. Short repeated blocks underlie indexing, compression, sequence assembly, motif analysis, and the detection of low-complexity regions. In DNA, the ambient alphabet

$$
\Sigma_{\mathrm{DNA}}=\{\mathrm{A},\mathrm{C},\mathrm{G},\mathrm{T}\}
$$

has four symbols. Consequently, there are only $4^k$ possible DNA words of length $k$. A sufficiently long sequence presents more length-$k$ windows than this finite repertoire can accommodate without collision.

The philosophical theme resembles Ramsey theory: regularity becomes unavoidable once a finite structure is large enough. The mechanism developed here is more specific. It is a sliding-window pigeonhole argument. This distinction matters because it identifies exactly which notion of repetition is controlled: equality of two contiguous blocks in a finite word, including a word formed by selecting letters from a larger sequence.

The central general result is the following. Let $\Sigma$ be a finite alphabet of size $q$, let $w$ be a word of length $m$, and let $k\le m$. If

$$
m\ge q^k+k,
$$

then two distinct length-$k$ windows of $w$ are equal. The proof counts $m-k+1\ge q^k+1$ windows and only $q^k$ possible values.

The DNA specialization gives $4^4+4=260$. A second specialization captures low-complexity structure. Suppose a visible DNA word is obtained by decoding a word over only $b$ effective symbols. Equal encoded blocks remain equal after coordinatewise decoding, so the threshold is $b^4+4$. The binary value is $2^4+4=20$.

These are worst-case, deterministic guarantees. They require no distribution on words and make no empirical assertion about a particular genome. In particular, numerical comparisons between biological and random genomes require a dataset, a random model, and an exact statistic. Our role here is to establish the combinatorial baseline against which such comparisons may eventually be made.

The paper is organized as follows. Section 2 defines words, windows, selection, repeat-freeness, and effective alphabets. Section 3 proves the general threshold and its repeat-free converse. Section 4 gives the DNA and selection consequences. Section 5 develops effective-alphabet compression. Section 6 presents algorithms. Sections 7 and 8 discuss examples, applications, and interpretive limits. The final sections address extensions and future work.

## 2. Definitions and problem formulation

### 2.1 Finite words

Let $\Sigma$ be a finite nonempty alphabet with cardinality

$$
|\Sigma|=q.
$$

A **word of length $m$ over $\Sigma$** is a sequence

$$
w=(w_0,w_1,\ldots,w_{m-1}), \qquad w_r\in\Sigma.
$$

Positions are numbered from $0$ through $m-1$. The zero-based convention simplifies formulas; replacing every position by one more gives the usual one-based convention.

### 2.2 Selected $k$-mers and the window map

Fix an integer $k$ satisfying $0\le k\le m$. For every starting position

$$
i\in\{0,1,\ldots,m-k\},
$$

the **selected $k$-mer beginning at $i$** is the function, or equivalently ordered tuple,

$$
W_{w,k}(i)=(w_i,w_{i+1},\ldots,w_{i+k-1})\in\Sigma^k.
$$

The map

$$
W_{w,k}:\{0,1,\ldots,m-k\}\longrightarrow\Sigma^k
$$

is called the **$k$-mer window map**. Its domain has cardinality $m-k+1$, while its codomain has cardinality $q^k$.

Two occurrences are considered distinct when their starting positions differ. They are allowed to overlap. Thus the word AAAAA has equal four-mers beginning at positions $0$ and $1$.

### 2.3 Repeat-free words

A word $w$ is **contiguous-$k$-mer repeat-free** if its window map $W_{w,k}$ is injective. Explicitly, for all admissible starting positions $i$ and $j$,

$$
W_{w,k}(i)=W_{w,k}(j)\quad\Longrightarrow\quad i=j.
$$

This notion concerns contiguous blocks of the word under examination. It does not require the blocks to be disjoint.

### 2.4 Selected words and subsequences

Let

$$
g=(g_0,g_1,\ldots,g_{n-1})
$$

be a genome word and let

$$
p:\{0,1,\ldots,m-1\}\longrightarrow\{0,1,\ldots,n-1\}
$$

be any position-selection map. The **selected word** is

$$
s_r=g_{p(r)} \qquad (0\le r<m).
$$

If $p$ is strictly increasing, then $s$ is a subsequence in the conventional order-preserving sense. If $p$ is arbitrary, it is still a well-defined selected word, possibly with repeated or reordered source positions. A contiguous block of $s$ consists of consecutive selected entries; it need not be contiguous in $g$.

This paper's selection theorem is deliberately stated for the selected word. It should not be confused with a theorem about every possible pair of independently scattered embeddings in the source genome.

### 2.5 Effective alphabets and decoding

Let $B$ be an alphabet of $b$ **effective symbols**, and let

$$
d:B\longrightarrow\Sigma_{\mathrm{DNA}}
$$

be a fixed decoding map. Given an encoded word

$$
e=(e_0,e_1,\ldots,e_{m-1})\in B^m,
$$

the decoded DNA word is

$$
w_r=d(e_r).
$$

We say that $w$ **factors through an effective alphabet of size $b$** when it admits such a representation. Injectivity of $d$ is not required. Indeed, a noninjective decoder can only identify additional patterns; it cannot separate equal encoded patterns.

The factorization model is deterministic. It is one precise way to express reduced local freedom, though it is not the only possible measure of sequence complexity.

## 3. The universal sliding-window threshold

### Theorem 1 (Universal repeated-$k$-mer threshold)

Let $\Sigma$ be a finite alphabet of size $q$. Let $w$ be a word of length $m$ over $\Sigma$, and let $k$ be a nonnegative integer. If

$$
q^k+k\le m,
$$

then there exist distinct starting positions $i,j\in\{0,1,\ldots,m-k\}$ such that

$$
W_{w,k}(i)=W_{w,k}(j).
$$

In words, every word of length at least $q^k+k$ contains two equal contiguous $k$-mers.

#### Proof sketch

The hypothesis implies $k\le m$, so all windows are defined. There are

$$
m-k+1
$$

starting positions. Since $m\ge q^k+k$,

$$
m-k+1\ge q^k+1>q^k.
$$

The set $\Sigma^k$ of possible $k$-mers has cardinality exactly $q^k$. Therefore the window map $W_{w,k}$ sends more than $q^k$ starting positions into a set of size $q^k$. By the pigeonhole principle it is not injective. Hence two distinct positions $i$ and $j$ have equal images. $\square$

The theorem is indifferent to overlap. The collision is between starting positions, not necessarily disjoint intervals. It also includes $k=0$: every window is the unique empty word, and the stated length condition gives enough starting positions to produce a collision.

### Theorem 2 (Length bound for a repeat-free word)

Let $\Sigma$ be a finite alphabet of size $q$, let $w$ have length $m$, and suppose $k\le m$. If the $k$-mer window map $W_{w,k}$ is injective, then

$$
m<q^k+k.
$$

#### Proof sketch

Assume instead that $m\ge q^k+k$. Theorem 1 then supplies distinct $i$ and $j$ with $W_{w,k}(i)=W_{w,k}(j)$. This contradicts injectivity. Therefore $m<q^k+k$. $\square$

Theorem 2 is the contrapositive form of Theorem 1, but it is useful as an extremal statement: no contiguous-$k$-mer repeat-free word reaches the universal threshold.

### Remark 1 (Threshold interpretation)

The argument proves a sufficient threshold by strict cardinality comparison. At length $m=q^k+k$, the word has $q^k+1$ windows. Since only $q^k$ labels exist, repetition is unavoidable. At length $q^k+k-1$, there are exactly $q^k$ windows, and counting alone no longer forces a collision. Thus the one-symbol transition between these lengths is the natural boundary of this argument.

### Corollary 1 (Collision count at the threshold)

Under the hypotheses of Theorem 1, at least one $k$-mer has two distinct occurrences.

#### Proof sketch

This is precisely the noninjectivity conclusion of the window map. The theorem does not assert that only one motif repeats, nor does it lower-bound the number of repeated pairs beyond existence. $\square$

## 4. DNA four-mers and selected genomic words

We now take

$$
\Sigma_{\mathrm{DNA}}=\{\mathrm{A},\mathrm{C},\mathrm{G},\mathrm{T}\},
$$

so $q=4$, and study $k=4$.

### Theorem 3 (DNA four-mer threshold)

Every DNA word of length at least $260$ contains two equal contiguous four-mers beginning at distinct positions.

#### Proof sketch

There are

$$
4^4=256
$$

possible DNA four-mers. A word of length $260$ has

$$
260-4+1=257
$$

four-mer starting positions. Longer words have at least as many. Since $257>256$, the pigeonhole principle forces two windows to agree. Equivalently, apply Theorem 1 with $q=4$ and $k=4$, observing that $4^4+4=260$. $\square$

### Example 1 (Overlap is permitted)

The DNA word AAAAA has length $5$ and contains AAAA at positions $0$ and $1$. This example lies far below the universal threshold because the threshold is a guarantee for every possible DNA word, not a prediction of the first collision in each individual word.

### Theorem 4 (Repeated four-mer in any long DNA selection)

Let $g$ be a DNA word of any finite length $n$, and choose $m$ letters from it using any map $p$ from selected positions to genomic positions. Form the selected word $s_r=g_{p(r)}$. If $m\ge260$, then there are distinct indices

$$
i,j\in\{0,1,\ldots,m-4\}
$$

such that

$$
(s_i,s_{i+1},s_{i+2},s_{i+3})
=
(s_j,s_{j+1},s_{j+2},s_{j+3}).
$$

#### Proof sketch

The selected sequence $s$ is itself a word of length $m$ over the four-letter DNA alphabet, regardless of how it was obtained. Theorem 3 therefore applies directly to $s$. $\square$

### Corollary 2 (Order-preserving subsequence form)

If the selection map in Theorem 4 is strictly increasing, then every DNA subsequence of selected length at least $260$ contains two equal four-letter blocks occupying consecutive positions within that subsequence.

#### Proof sketch

Strict increase identifies the selected word with an order-preserving subsequence of the genome. The repeated blocks supplied by Theorem 4 are contiguous in the selected indexing, which is exactly the asserted property. $\square$

### Remark 2 (A necessary distinction)

Theorem 4 does not solve the broader scattered-repeat problem in which each copy of a word may be chosen by its own order embedding and additional conditions such as disjointness are imposed. It addresses contiguous windows after one selection has produced a word. This distinction prevents an ordinary window collision from being mistaken for a complete Ramsey theorem for scattered words.

## 5. Effective-alphabet compression

The four-letter threshold treats every DNA position as if all four bases were independently available. Low-complexity regions often have fewer effective choices. We now quantify the resulting compression.

### Theorem 5 (Effective-alphabet four-mer theorem)

Let $B$ be an alphabet of size $b$. Let $e=(e_0,\ldots,e_{m-1})$ be a word over $B$, and let $d:B\to\Sigma_{\mathrm{DNA}}$ be any decoding map. Define the DNA word $w$ by $w_r=d(e_r)$. If

$$
b^4+4\le m,
$$

then there exist distinct starting positions $i,j\in\{0,1,\ldots,m-4\}$ such that the decoded four-mers agree:

$$
(w_i,w_{i+1},w_{i+2},w_{i+3})
=
(w_j,w_{j+1},w_{j+2},w_{j+3}).
$$

#### Proof sketch

Apply Theorem 1 to the encoded word $e$ over the $b$-symbol alphabet with $k=4$. The length assumption yields distinct $i$ and $j$ such that

$$
(e_i,e_{i+1},e_{i+2},e_{i+3})
=
(e_j,e_{j+1},e_{j+2},e_{j+3}).
$$

Apply $d$ coordinatewise to the two equal tuples. Equality is preserved by every function, so the corresponding decoded DNA four-mers are equal. $\square$

The proof uses no injectivity or surjectivity assumption on $d$. If several effective symbols decode to the same DNA letter, additional decoded collisions may occur even before the guaranteed encoded collision.

### Corollary 3 (Binary low-complexity threshold)

Let $e$ be a binary word of length $m$, and decode its two symbols into DNA by any fixed map. If $m\ge20$, then the decoded DNA word contains two equal contiguous four-mers at distinct starting positions.

#### Proof sketch

Set $b=2$ in Theorem 5. Since

$$
2^4+4=16+4=20,
$$

the claimed threshold follows. $\square$

### Example 2 (A binary decoding)

Take $B=\{0,1\}$ with $d(0)=\mathrm{A}$ and $d(1)=\mathrm{G}$. Every decoded word then uses only A and G. A length-$20$ word presents $17$ four-mer windows, while only $2^4=16$ A/G four-mers are possible. Hence a repeated four-mer is unavoidable.

### Corollary 4 (Threshold comparison)

The guaranteed four-mer threshold falls from $260$ for an unrestricted four-letter word to $20$ for a binary-generated word.

#### Proof sketch

Compute $4^4+4=260$ and $2^4+4=20$. Both are instances of Theorem 5, with the unrestricted DNA case corresponding to the identity decoding on a four-symbol alphabet. $\square$

The numerical ratio is

$$
\frac{260}{20}=13.
$$

This factor compares deterministic sufficient thresholds. It is not an empirical estimate of genomic compression.

## 6. Constructive algorithms

The existence proofs naturally produce algorithms that locate repeated blocks.

### Algorithm 1: Hash-table window collision search

**Input:** A finite sequence $w$ of length $m$ and an integer $k$ with $0\le k\le m$.

**Output:** Either two distinct starting positions carrying the same $k$-mer, together with that $k$-mer, or a report that all windows are distinct.

**Procedure:**

1. Initialize an empty dictionary $H$ mapping observed $k$-mers to their first starting positions.
2. For $i=0,1,\ldots,m-k$:
   1. Form $x=(w_i,\ldots,w_{i+k-1})$.
   2. If $x$ is already a key in $H$, return $(H[x],i,x)$.
   3. Otherwise set $H[x]=i$.
3. If the loop ends, report that no repeated contiguous $k$-mer exists.

### Proposition 1 (Correctness of collision search)

Algorithm 1 returns a triple $(i,j,x)$ only when $i<j$ and

$$
W_{w,k}(i)=x=W_{w,k}(j).
$$

If it reports no repetition, the window map is injective. Under the assumptions of Theorem 1, it must return a collision before terminating.

#### Proof sketch

A dictionary entry $H[x]=i$ is inserted only after the algorithm computes $W_{w,k}(i)=x$. If the same key is found at a later index $j$, both windows equal $x$ and $i<j$. Conversely, if the scan finishes without a repeated key, every computed window value was new, so all window values are distinct. Theorem 1 rules out this second outcome when $m\ge q^k+k$. $\square$

### Complexity analysis

The algorithm examines $m-k+1$ windows. If materializing a length-$k$ tuple costs $O(k)$ and dictionary operations have expected $O(1)$ cost after hashing, the expected running time is

$$
O((m-k+1)k).
$$

At most $\min\{m-k+1,q^k\}$ distinct windows are stored, requiring

$$
O(\min\{m-k+1,q^k\}k)
$$

symbol storage in a direct tuple representation. For fixed $k=4$, time is $O(m)$ and storage is bounded by a constant multiple of $q^4$.

For DNA, encode A, C, G, and T as $0,1,2,3$. A four-mer can then be represented as an integer from $0$ to $255$ using two bits per letter. An array of $256$ first-occurrence positions replaces the dictionary, giving worst-case constant-time lookup per window for fixed width four.

### Algorithm 2: Encoded collision search with decoded witness

**Input:** An encoded word $e$ over $b$ symbols, a decoder $d$ into DNA, and block width four.

**Output:** Two positions with equal decoded four-mers, or a report that the encoded four-mer windows are all distinct.

**Procedure:**

1. Run Algorithm 1 on $e$ with $k=4$.
2. If it returns $(i,j,x)$, decode $x$ coordinatewise to obtain the DNA four-mer $d(x)$.
3. Return $(i,j,d(x))$.
4. If no encoded repeat exists, report no encoded witness.

### Proposition 2 (Correctness of encoded search)

Whenever Algorithm 2 returns $(i,j,y)$, the decoded DNA word has four-mer $y$ at both positions. If $m\ge b^4+4$, the algorithm necessarily returns such a witness.

#### Proof sketch

Algorithm 1 guarantees equal encoded four-mers at $i$ and $j$. Coordinatewise decoding preserves equality, proving correctness. Theorem 1 with alphabet size $b$ guarantees that Algorithm 1 finds a collision under the stated length condition. $\square$

A decoder may create a repeated DNA four-mer even when encoded windows differ. Therefore Algorithm 2 is optimized for proving the effective-alphabet theorem, not necessarily for finding the earliest decoded collision. To find the earliest visible collision, decode first and run Algorithm 1 on the DNA word.

### Algorithm 3: Threshold and compression table

**Input:** A list of alphabet sizes $b_1,\ldots,b_r$ and a block width $k$.

**Output:** The universal sufficient thresholds

$$
T(b_t,k)=b_t^k+k
$$

and, relative to a chosen reference size $q$, the ratios

$$
\frac{T(q,k)}{T(b_t,k)}.
$$

**Procedure:** For each $b_t$, compute integer exponentiation $b_t^k$, add $k$, and optionally divide the reference threshold by the result.

The arithmetic cost is negligible for small inputs. Using exponentiation by squaring, each power requires $O(\log k)$ integer multiplications; bit complexity depends on the size of $b_t^k$.

## 7. Numerical demonstrations

A self-contained computational demonstration can exhibit three aspects of the theory.

First, it can generate a deterministic length-$260$ DNA word, scan its $257$ four-mer windows, and return an explicit collision. The theorem guarantees success for every generated word, so the demonstration does not rely on favorable randomness.

Second, it can generate a length-$20$ binary word, decode $0$ and $1$ as two chosen DNA letters, and locate a repeated decoded four-mer. Again, success is unconditional.

Third, it can tabulate $b^4+4$ for effective alphabet sizes $b=1,2,3,4$:

$$
\begin{array}{c|c|c}
b & b^4 & b^4+4\\
\hline
1 & 1 & 5\\
2 & 16 & 20\\
3 & 81 & 85\\
4 & 256 & 260
\end{array}
$$

This table visualizes the fourth-power sensitivity of the threshold. The threshold is not linear in alphabet size because a four-mer independently selects one of $b$ symbols at each of four coordinates.

One may also enumerate all windows and display an occupancy histogram indexed by four-mer. A collision appears as any histogram bar of height at least two. At the universal threshold, the sum of all bar heights is $q^4+1$ while there are only $q^4$ bars; therefore at least one bar has height at least two.

## 8. Applications and interpretation

### 8.1 Sequence indexing

A repeated $k$-mer means that a length-$k$ query cannot identify a unique starting position in the word. Theorem 1 therefore supplies a worst-case obstruction to unique indexing by short contiguous signatures. Once a sequence reaches $q^k+k$, uniqueness of every window is impossible.

### 8.2 Low-complexity detection

The effective-alphabet theorem gives a transparent mechanism for early repetition. If a region is generated using only $b$ effective states, its potential four-mer repertoire has size at most $b^4$. Repeated blocks are forced after $b^4+1$ windows. This supports the use of motif diversity as one indicator of local complexity.

The theorem should not be read backward without care. Observing a repeated four-mer does not prove that the region factors through a small effective alphabet: repetitions occur even in unrestricted sequences. The theorem gives a sufficient structural condition for a low threshold, not a characterization of all low-complexity words.

### 8.3 Sampling and selected sequences

The selection theorem shows that a larger surrounding genome contributes no extra freedom once a selected word has been fixed. A selection of length $m$ is simply a word of length $m$ over four symbols. This observation is useful when an analysis pipeline samples positions and then studies adjacency in the sampled sequence.

The ordering convention must be reported. If selected positions are strictly increasing, adjacency in the selected word corresponds to four successive selected genomic positions, generally with gaps. If the selection reorders or repeats source positions, the result still holds for the selected word, but its biological interpretation changes.

### 8.4 Compression and finite coding

The map from encoded four-mers to decoded DNA four-mers is coordinatewise. Its image has size at most $b^4$, and perhaps less if the decoder is noninjective. Thus the result is an instance of a broader coding principle: deterministic post-processing cannot distinguish inputs that were already equal. Any collision in an upstream representation survives downstream decoding.

## 9. Limits of the conclusions

The results are universal but deliberately narrow. Several statements that might sound nearby are not consequences of the present argument.

### 9.1 No empirical human-genome threshold is established

A claim about every window in a human genome assembly requires the assembly and window convention to be specified and analyzed. Ambiguous bases, chromosome boundaries, reverse complements, masking, and overlapping occurrences all affect the statistic. No abstract pigeonhole calculation establishes a numerical human-versus-random compression factor.

### 9.2 No random-genome expectation is established

The deterministic threshold is not an expected waiting time. In a random word, collisions often occur well before all $q^k$ patterns are exhausted, in the same spirit as the birthday phenomenon. The answer depends on whether letters are independent and uniform, whether base frequencies are biased, and whether dependencies between overlapping windows are modeled. Probabilistic analysis is a separate layer.

### 9.3 Contiguous windows are not arbitrary scattered copies

The equality

$$
W_{w,k}(i)=W_{w,k}(j)
$$

compares two contiguous blocks in $w$. After an order-preserving selection, each is a block of consecutive entries in the selected subsequence, but each block may be scattered in the source genome. The argument does not classify two arbitrary scattered occurrences selected independently, and it does not require disjointness.

### 9.4 The threshold is a guarantee, not an observed first repeat

Many words repeat almost immediately. Constant words do so after shifting one position. The threshold $q^k+k$ says that no word can avoid repetition at or beyond that length. It does not say that typical or biologically meaningful words postpone repetition until near the threshold.

## 10. Discussion

The mathematical structure can be summarized by a commutative counting picture. Starting positions form a set of size $m-k+1$. The window map sends each position to one of $q^k$ blocks. A decoder, when present, sends effective blocks to visible DNA blocks. If the first map has a collision, composition with the decoder retains that collision.

This view explains why the main results require so little machinery. The alphabet need only be finite, equality must be decidable for computation, and windows must have a fixed length. The biological vocabulary adds interpretation but no hidden assumption.

The separation between deterministic and probabilistic statements is particularly valuable. A universal theorem provides a ceiling on avoidance: beyond the threshold, every word repeats. A probabilistic theorem would describe the distribution of the first repeat under a chosen random model. An empirical study would measure the same or a related statistic on specified genomic data. These are complementary questions, but they should not be conflated.

The effective-alphabet result also suggests refinements. Cardinality $b$ is coarse: two regions using the same symbols may have very different transition constraints. A finite-state source may permit far fewer than $b^4$ blocks. If $P_4$ denotes the actual number of allowed four-mers, then the same pigeonhole reasoning would force repetition once the number of windows exceeds $P_4$. This points toward subword complexity as a sharper parameter.

## 11. Future work

The first extension is a rigorous theory of repeated **scattered** words. One should define two order-preserving embeddings of a common pattern into a source word and decide whether the images must be disjoint. That problem is combinatorially richer than repeated windows in one selected sequence.

A second goal is to determine sharp extremal lengths for avoiding two disjoint equal scattered four-mers over a four-letter alphabet. Such a result would more directly realize the Ramsey-theoretic motivation.

Third, probabilistic bounds should be developed for random words. Because adjacent windows overlap, their collision events are dependent; a careful treatment should specify whether the model is independent and identically distributed, Markovian, or frequency constrained.

Fourth, local complexity can be modeled using effective alphabet size, the number of distinct admitted subwords, transition graphs, and run structure. Each parameter may yield a region-dependent collision threshold stronger than the ambient $4^4+4$ bound.

Finally, empirical genome comparisons should begin only after fixing a reproducible dataset, a window convention, an ambiguity-symbol policy, and an exact statistic. Those decisions are prerequisites for assessing any claimed difference between biological and random sequences.

## 12. Conclusion

A finite alphabet imposes a finite repertoire of local patterns. For an alphabet of size $q$, only $q^k$ length-$k$ words exist. Once a length-$m$ word supplies more than $q^k$ windows, two windows must coincide. The inequality $m\ge q^k+k$ guarantees exactly that situation.

For DNA four-mers, the universal threshold is $260$. The same bound applies to any selected DNA word of that length, including every order-preserving subsequence with $260$ selected letters. If the word factors through $b$ effective symbols, the threshold compresses to $b^4+4$; binary-generated DNA therefore repeats a four-mer by length $20$ under every fixed decoding.

These conclusions are deterministic, constructive, and independent of biological assumptions. They establish a clean combinatorial baseline for future extremal, probabilistic, and empirical studies of repetition in genetic sequences.
