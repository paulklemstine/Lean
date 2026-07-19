# Forced Repetition in Finite Genetic Alphabets: Aligned Collisions, Disjoint Copies, and Multiplicity

**Aristotle**  
**July 19, 2026**

## Abstract

Finite alphabets force repetition. This paper develops a self-contained extremal theory for regularly aligned words in an arbitrary finite sequence and then specializes it to DNA. For an alphabet of cardinality $q$, the space of length-$m$ words has exactly $q^m$ elements. It follows that more than $q^m$ aligned samples force two equal words, while more than $rq^m$ samples force one word to occur at least $r+1$ times. Equal aligned blocks yield equal order-preserving subsequences, and distinct aligned blocks are disjoint whenever $m>0$. Consequently, every DNA sequence of length at least $1028$ contains two identical, disjoint four-base blocks among the $257$ blocks beginning at positions $0,4,8,\ldots,1024$. The associated avoidance bound $n\le q^m$ is sharp for aligned sampling. We distinguish these universal worst-case results from claims about arbitrary scattered subsequences, random sequences, and real genomes. Algorithms are given for detecting collisions, measuring multiplicity, and computing a window-uniform repetition statistic. The framework supplies a rigorous baseline for entropy-sensitive and genome-dependent studies without conflating deterministic pigeonhole bounds with probabilistic birthday effects.

## 1. Introduction

A finite alphabet can encode only finitely many words of a fixed length. This observation is elementary, but it gives exact extremal statements about when repetition becomes unavoidable. The statements are particularly transparent for DNA, whose alphabet is

$$
\Sigma_{\mathrm{DNA}}=\{A,C,G,T\}.
$$

A four-base word, or four-mer, is one of $4^4=256$ possibilities. Therefore a list of $257$ four-mers must repeat. To turn this list-level observation into a theorem about one long genetic sequence, we sample the sequence in consecutive, nonoverlapping blocks. The resulting collision is not merely an equality of abstract words: it identifies two equal, disjoint, order-preserving subsequences at explicit positions.

The aligned model is deliberately modest. It does not claim an optimal threshold for all contiguous substrings, still less for arbitrary scattered subsequences. Rather, it isolates the exact contribution of finite coding. This separation is essential in discussions of genomic repetition. Three regimes must not be confused:

1. **Worst-case aligned repetition**, governed exactly by the $q^m$ possible words.
2. **Typical random repetition**, often governed by birthday-paradox scales and source entropy.
3. **Genome-specific repetition**, influenced by low-complexity regions, duplication, local composition, and biological history.

The main results establish the first regime. They also provide baselines and statistics suitable for studying the other two.

The paper proceeds as follows. Section 2 defines words, aligned blocks, scattered occurrences, collisions, and multiplicity. Section 3 counts the word space. Sections 4–7 prove collision, disjointness, multiplicity, and avoidance results. Section 8 gives the explicit DNA four-mer corollary. Section 9 describes computational methods. Sections 10 and 11 explain probabilistic and empirical extensions, while Section 12 identifies open extremal problems.

## 2. Definitions

### 2.1 Alphabets and sequences

Let $\Sigma$ be a finite nonempty alphabet, and write

$$
q=|\Sigma|.
$$

A one-sided infinite sequence over $\Sigma$ is a function

$$
x:\mathbb{N}\to\Sigma,
$$

where $x(s)$ is the symbol at position $s$. The same definitions apply to a finite sequence whenever all referenced positions lie within its length.

A **word of length $m$** is a function

$$
w:\{0,1,\ldots,m-1\}\to\Sigma.
$$

Equivalently, it is an ordered tuple $(w_0,\ldots,w_{m-1})$. When $m=0$, there is one empty word.

### 2.2 Aligned blocks

For a block length $m$ and block index $i$, define the **aligned block** $B_i^{(m)}(x)$ by

$$
B_i^{(m)}(x)(t)=x(im+t),\qquad 0\le t<m.
$$

Thus the blocks are sampled at starts $0,m,2m,\ldots$. For $m>0$, distinct aligned blocks occupy disjoint intervals. Sampling the first $n$ blocks examines the prefix of length $nm$.

Two sampled blocks form an **aligned collision** if

$$
B_i^{(m)}(x)=B_j^{(m)}(x)
$$

for distinct indices $i$ and $j$.

### 2.3 Subsequences and disjoint occurrences

A **scattered occurrence** of a word $w$ of length $m$ in $x$ is a strictly increasing sequence of positions

$$
s_0<s_1<\cdots<s_{m-1}
$$

such that $x(s_t)=w_t$ for every $t$. A contiguous block is a special scattered occurrence with $s_t=s_0+t$. An aligned block is a still more specialized contiguous occurrence with $s_0$ divisible by $m$.

Two occurrences are **disjoint** if their sets of positions are disjoint. For aligned blocks with indices $i<j$ and $m>0$, disjointness follows from

$$
im+m\le jm.
$$

### 2.4 Multiplicity and avoidance

The **aligned multiplicity** of a word $w$ among the first $n$ blocks is

$$
M_{x,m,n}(w)=\left|\left\{i\in\{0,\ldots,n-1\}:B_i^{(m)}(x)=w\right\}\right|.
$$

The sample is **collision-free** if every multiplicity is at most $1$. More generally, it avoids multiplicity $r+1$ if every word has multiplicity at most $r$.

For a finite genome $g$, a useful empirical statistic is $U_g(m,r)$, defined as the least positive integer $L$, if one exists, such that every length-$L$ window of $g$ contains some length-$m$ word with at least $r$ pairwise disjoint contiguous occurrences. This statistic is window-uniform: it is controlled by the least repetitive region rather than by a genome-wide average.

## 3. Cardinality of the word space

### Theorem 3.1 (Word-Space Cardinality)

Let $\Sigma$ be a finite alphabet of size $q$. For every nonnegative integer $m$, the number of length-$m$ words over $\Sigma$ is exactly

$$
q^m.
$$

#### Proof sketch

A word specifies one of $q$ symbols independently at each of $m$ positions. By the product rule, the number of choices is the product of $m$ copies of $q$, namely $q^m$. For $m=0$, the unique empty function gives one word, agreeing with $q^0=1$.

This count is the invariant behind all subsequent deterministic bounds. The internal structure of the sequence is irrelevant until one asks for stronger conclusions than aligned repetition.

## 4. The aligned collision theorem

### Theorem 4.1 (Aligned-Block Collision)

Let $x$ be any sequence over a finite alphabet $\Sigma$ of size $q$. Fix integers $m,n\ge 0$. If

$$
q^m<n,
$$

then there exist block indices $i$ and $j$ satisfying

$$
0\le i<j<n
$$

and

$$
B_i^{(m)}(x)=B_j^{(m)}(x).
$$

#### Proof sketch

Map each block index $i\in\{0,\ldots,n-1\}$ to the word $B_i^{(m)}(x)$. The domain has $n$ elements, whereas the codomain has $q^m$ elements by Theorem 3.1. Under the hypothesis $n>q^m$, the map cannot be injective. Hence two distinct indices have equal images. Ordering those two indices gives $i<j$.

The proof is a direct pigeonhole argument, but its quantifiers are worth emphasizing: it applies to every sequence, including sequences chosen adversarially after $q$, $m$, and $n$ are fixed.

### Corollary 4.2 (Prefix-Length Form)

Every sequence prefix containing at least

$$
m(q^m+1)
$$

symbols contains a repeated word among its first $q^m+1$ aligned length-$m$ blocks.

#### Proof sketch

A prefix of that length contains the required $q^m+1$ complete aligned blocks. Apply Theorem 4.1 with $n=q^m+1$.

## 5. Collisions as disjoint subsequences

### Theorem 5.1 (Disjoint-Subsequence Consequence)

Suppose $i<j$ and

$$
B_i^{(m)}(x)=B_j^{(m)}(x).
$$

Then, for every $t$ with $0\le t<m$,

$$
x(im+t)=x(jm+t).
$$

If $m>0$, the first occurrence ends no later than the second begins:

$$
im+m\le jm.
$$

Consequently, the two blocks define equal, disjoint, order-preserving subsequences of length $m$.

#### Proof sketch

Equality of words is pointwise equality, yielding the first displayed identity at each offset $t$. Since $i<j$, one has $i+1\le j$. Multiplication by the nonnegative number $m$ gives $(i+1)m\le jm$, which is the separation inequality $im+m\le jm$. The occupied intervals are therefore disjoint.

### Remark 5.2 (Hierarchy of pattern classes)

The theorem passes from an aligned collision to a scattered-subsequence collision because aligned blocks are special subsequences. It does not provide the sharp extremal threshold for arbitrary scattered occurrences. Allowing arbitrary starts or gaps creates many additional candidate occurrences and can lower the true threshold.

## 6. Quantitative supersaturation

A collision theorem answers when multiplicity $2$ is forced. The same finite-fiber argument gives every higher multiplicity at once.

### Theorem 6.1 (Aligned-Block Multiplicity)

Let $x$ be a sequence over an alphabet of size $q$, and let $m,n,r\ge 0$. If

$$
rq^m<n,
$$

then there exists a length-$m$ word $w$ such that

$$
M_{x,m,n}(w)>r.
$$

Equivalently, some aligned word occurs at least $r+1$ times among the first $n$ blocks.

#### Proof sketch

Assume instead that every word occurs at most $r$ times. There are $q^m$ possible words, so summing all fiber sizes gives at most $rq^m$ sampled blocks. But the fibers partition the $n$ block indices, so their sizes sum to $n$. This contradicts $n>rq^m$.

### Corollary 6.2 (Pairwise Disjoint Multiplicity)

Under the hypotheses of Theorem 6.1, if $m>0$, one length-$m$ word has at least $r+1$ pairwise disjoint contiguous occurrences.

#### Proof sketch

The occurrences supplied by Theorem 6.1 lie in distinct aligned blocks. Distinct aligned blocks of positive length occupy disjoint intervals.

### Corollary 6.3 (DNA Multiplicity Scale)

Among more than $256r$ aligned four-base blocks of a DNA sequence, some four-mer occurs at least $r+1$ times, with all occurrences pairwise disjoint.

#### Proof sketch

Substitute $q=4$ and $m=4$ into Theorem 6.1 and use $4^4=256$.

This result can be read as a deterministic supersaturation law. Once the sample size exceeds a multiple of the word-space cardinality, repetition is forced at the corresponding multiple.

## 7. Avoidance bounds and sharpness

### Theorem 7.1 (Aligned-Avoidance Bound)

If the first $n$ aligned length-$m$ blocks of a sequence over a $q$-symbol alphabet are pairwise distinct, then

$$
n\le q^m.
$$

#### Proof sketch

The block map from $n$ indices to the $q^m$ words is injective by hypothesis. An injection between finite sets can exist only if the domain cardinality does not exceed the codomain cardinality.

Equivalently, this is the contrapositive of Theorem 4.1.

### Proposition 7.2 (Sharpness for Aligned Sampling)

For every finite alphabet of size $q$ and every $m\ge 0$, there exists a sequence prefix with exactly $q^m$ pairwise distinct aligned length-$m$ blocks.

#### Proof sketch

Enumerate all length-$m$ words in any order and concatenate them. Each word then appears exactly once as an aligned block in the resulting prefix. Thus $q^m$ collision-free aligned samples are possible, while Theorem 4.1 shows that $q^m+1$ are impossible.

The aligned extremal problem is therefore solved exactly. Its simplicity should not be transferred uncritically to arbitrary scattered words, where occurrences overlap in a complicated way.

## 8. Explicit DNA specialization

### Theorem 8.1 (DNA Four-Mer Collision within $1028$ Bases)

Let $x$ be any DNA sequence. Among the $257$ aligned four-base blocks beginning at positions

$$
0,4,8,\ldots,1024,
$$

two blocks are identical. More precisely, there exist integers $0\le i<j<257$ such that

$$
x(4i+t)=x(4j+t)
$$

for $t=0,1,2,3$. The two occurrences are disjoint, since

$$
4i+4\le 4j,
$$

and the last position of the second copy satisfies

$$
4j+3<1028.
$$

#### Proof sketch

There are exactly $4^4=256$ possible four-mers. Apply Theorem 4.1 to $257$ aligned blocks. The pointwise identity and disjointness follow from Theorem 5.1. Since $j<257$, one has $j\le256$, hence $4j+3\le1027<1028$.

### Interpretation

The theorem is a universal upper bound: every sequence of $1028$ bases has the asserted collision under the fixed alignment. It is not a claim about the average waiting time in random DNA. It also does not claim that $1028$ is the least length forcing repeated four-mers when every possible starting position is examined. Sampling overlapping windows gives more opportunities for collisions and requires a different extremal analysis.

## 9. Algorithms

### 9.1 First aligned collision

Given a finite sequence $s$ and motif length $m>0$, partition $s$ into $N=\lfloor |s|/m\rfloor$ complete aligned blocks. Maintain a dictionary from block words to their first indices. When a word is encountered again, return the stored index and the current index.

With hashing, the expected running time is $O(Nm)$ because each block contains $m$ symbols and dictionary operations are expected $O(1)$. The memory usage is $O(\min(N,q^m)m)$ if words are stored explicitly. A trie or integer encoding can reduce constants.

Correctness follows from a loop invariant: after processing indices below $i$, the dictionary contains exactly the first occurrence of each word seen so far. A repeated key therefore supplies a genuine collision. If no repeat is found, all sampled blocks are distinct and Theorem 7.1 implies $N\le q^m$.

### 9.2 Maximum aligned multiplicity

To measure supersaturation, count every aligned block in a frequency dictionary and return a word of maximum frequency. The time and memory bounds are the same order as collision detection. If $N>rq^m$, Theorem 6.1 certifies in advance that the returned maximum exceeds $r$.

### 9.3 Window-uniform disjoint repetition

For a finite genome $g$, fixed $m$, and target multiplicity $r$, one can compute $U_g(m,r)$ by binary search over candidate window lengths. For each window, greedily scan occurrences of each word from left to right and accept an occurrence only when it begins after the previous accepted copy ends. For identical fixed-length contiguous intervals, this earliest-finish greedy rule maximizes the number of pairwise disjoint occurrences.

A candidate length $L$ passes if every length-$L$ window contains some word with at least $r$ accepted occurrences. The property is monotone in $L$: extending a qualifying window cannot destroy the occurrences already present. Binary search is therefore valid. A direct implementation is suitable for demonstrations; suffix arrays, rolling hashes, and incremental window data structures are preferable at genomic scale.

## 10. Deterministic bounds and random collision scales

The worst-case threshold $q^m+1$ counts all possible words. A random source behaves differently. If aligned words were independent and uniformly distributed among $Q=q^m$ possibilities, then after $n$ samples the expected number of colliding pairs would be

$$
\binom{n}{2}\frac{1}{Q}.
$$

This becomes order $1$ around $n\asymp\sqrt{Q}=q^{m/2}$. This is the birthday-paradox scale, far below the adversarial exhaustion threshold $Q+1$.

For a stationary source with entropy rate $h<\log q$, the effective typical set of length-$m$ words has size approximately $e^{hm}$. The corresponding heuristic collision scale is

$$
e^{hm/2}.
$$

These formulas are not universal deterministic theorems. Dependence between adjacent blocks, nonuniform word probabilities, and finite-size effects all matter. Their role is to motivate statistical models against which an observed genome can be compared.

A low-complexity genomic region may have much smaller effective entropy than a composition-matched random sequence. Homopolymers and microsatellites can create immediate repetition; segmental duplications can create repetition over much larger scales. Consequently, any empirical claim of a constant-factor “compression” in waiting time should report the exact statistic, the surrogate model, uncertainty across windows, and treatment of ambiguous bases and assembly gaps.

## 11. Applications and empirical protocol

### 11.1 Motif redundancy

The multiplicity theorem gives a baseline for unavoidable motif reuse. If a data set contains $n$ nonoverlapping $m$-mers over $q$ symbols, then some motif appears at least

$$
\left\lceil\frac{n}{q^m}\right\rceil
$$

times. This lower bound follows by choosing the largest integer $r$ with $rq^m<n$.

### 11.2 Compression and indexing

A collision-free aligned block list can have length at most $q^m$. Thus any longer list necessarily contains redundancy at the block level. Dictionary compressors and motif indexes exploit precisely this reuse, although practical compression also depends on the cost of pointers, context models, and near-matches.

### 11.3 A reproducible genome comparison

A robust study of real versus synthetic genomes can proceed as follows:

1. Select chromosomes or contigs and define a policy for ambiguous symbols.
2. Choose motif length $m$ and multiplicity $r$.
3. Compute $U_g(m,r)$ for the observed sequence.
4. Generate matched surrogates, preferably including independent shuffles and first-order Markov sequences preserving local transition frequencies.
5. Compute the same statistic for every surrogate.
6. Report the observed-to-surrogate ratio, confidence intervals, chromosome-level variation, and sensitivity to GC content and gaps.
7. Compare every value with the universal aligned benchmark $m(r-1)q^m+m$ for $r$ occurrences among aligned blocks, while clearly noting that $U_g$ scans all window positions and may use arbitrary disjoint contiguous occurrences.

This protocol separates a mathematical certainty from a biological effect. The certainty is that finite word space forces repetition. The biological question is how much earlier repetition occurs under the structure of actual genomes.

Several reporting choices are essential. Windows crossing long runs of unknown bases should either be excluded or analyzed separately. Reverse complements may be treated as distinct words or identified as one motif class, but that convention must be declared before analysis. Multiple motif lengths should not be searched and then selectively reported without an appropriate correction. Finally, a ratio of observed and surrogate thresholds should be accompanied by the raw thresholds: the ratio alone can conceal chromosome length effects or a ceiling caused by the finite sequence. These controls make the statistic interpretable across assemblies and species.

## 12. Discussion and future work

The aligned theory is complete at the counting level: $q^m$ is the exact maximum number of distinct aligned words, and $rq^m$ is the exact capacity if each word may be used at most $r$ times. Yet the simplicity of these results marks the boundary of a harder theory.

First, arbitrary scattered occurrences introduce many embeddings whose overlaps are strongly dependent. Determining the longest sequence that avoids two disjoint copies of the same scattered length-$m$ word is a natural extremal problem. The aligned construction supplies an upper benchmark, but likely wastes information because scattered occurrences can cross block boundaries.

Second, multiplicity may undergo a sharper phase transition when all embeddings are allowed. One expects a threshold linear in the requested number of disjoint copies but with a constant smaller than the aligned value $mq^m$ for $m\ge2$.

Third, entropy should replace alphabet cardinality in typical-source analysis. Proving waiting-time laws near $e^{hm/2}$ under explicit mixing conditions would connect combinatorial collision bounds to information theory.

Fourth, window-uniform statistics deserve empirical study. The quantity $U_g(m,r)$ can reveal whether every region of a chromosome is repetition-rich, rather than merely whether the chromosome has many repeats on average. Comparisons with matched Markov surrogates can distinguish effects of marginal composition from higher-order genomic organization.

Finally, the numerical value sometimes suggested by expressions such as $q^m\log(q^m)$ depends on the logarithm base and does not follow from the pigeonhole argument. For $q=4$ and $m=4$, the deterministic aligned collision threshold is exactly $257$ blocks or $1028$ bases. Any larger logarithmic scale must arise from a separately defined probabilistic, covering, or uniform-window question.

## 13. Conclusion

A finite genetic alphabet imposes exact repetition laws. There are $q^m$ length-$m$ words; more than $q^m$ aligned samples force a collision; more than $rq^m$ force multiplicity $r+1$; and equal aligned blocks yield disjoint equal subsequences. For DNA four-mers, the universal statement becomes concrete: $257$ aligned blocks, occupying $1028$ bases, always contain two identical disjoint copies.

These results are simultaneously strong and limited. They are strong because they require no randomness or biological assumptions and are sharp for aligned sampling. They are limited because they do not determine optimal scattered-subsequence thresholds or genome-specific waiting times. That boundary is productive: it supplies a clean universal baseline while identifying overlap geometry, entropy, and empirical sequence structure as the sources of any stronger phenomenon.
