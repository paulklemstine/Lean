# The Ramsey Theory of DNA

## Why repetition is unavoidable—and what it does not tell us

A DNA molecule looks, at first glance, like an immense text written in a tiny alphabet. Its letters are adenine, cytosine, guanine, and thymine: $A$, $C$, $G$, and $T$. The human genome contains billions of these letters, but there are only four choices at each position. That mismatch—vast length, tiny alphabet—makes repetition inevitable.

The surprise is not merely that repeats occur. It is that one can give an absolute deadline by which a repeat must occur, regardless of how cleverly the letters are arranged. For four-letter motifs, that deadline is especially concrete: **within any stretch of $1028$ DNA bases, two disjoint, regularly aligned four-base blocks must be identical.** No assumptions about evolution, randomness, mutation, or genomic composition are needed.

This is a Ramsey-style phenomenon. Ramsey theory studies the principle that sufficiently large structures cannot remain completely disordered: a pattern is eventually forced. Here the engine is the pigeonhole principle, but the biological interpretation—and the distinction between different kinds of repeated patterns—deserves care.

## Turning DNA into boxes and pigeons

Fix an alphabet containing $q$ symbols and choose a motif length $m$. A word of length $m$ is an ordered list of $m$ alphabet symbols. There are exactly

$$
q^m
$$

possible words, because each of the $m$ positions independently admits $q$ choices.

Now divide a sequence into consecutive, nonoverlapping blocks of length $m$. Call these **aligned blocks**. Block $0$ uses positions $0$ through $m-1$, block $1$ uses positions $m$ through $2m-1$, and, in general, block $i$ begins at position $im$.

Each sampled block is a pigeon, and each possible length-$m$ word is a pigeonhole. If we inspect more than $q^m$ aligned blocks, some two must land in the same hole. This gives the **Aligned-Block Collision Theorem**:

> For every sequence over an alphabet of size $q$, if $n>q^m$ aligned blocks of length $m$ are sampled, then two of those blocks are equal.

The proof is one sentence: a map from more than $q^m$ sampled blocks into a set of only $q^m$ possible words cannot be one-to-one.

This principle belongs to the same broad family as classical Ramsey results, though its mechanism is simpler. Classical Ramsey theory colors relationships among objects and forces a homogeneous configuration. The present argument assigns each sampled location a finite label and forces two labels to coincide. In both cases, scale defeats avoidance: beyond a calculable size, arrangement can delay a pattern but cannot eliminate it.

Although elementary, the statement is strong. It is deterministic and adversarial: it remains true even if the sequence is designed specifically to postpone repetition.

## Why the repeated copies are genuinely separate

Repeated patterns can overlap. In the string $AAAAA$, for example, the four-letter word $AAAA$ begins at two adjacent positions, but those copies share three letters. Depending on the application, counting such overlaps as two occurrences may be misleading.

Aligned sampling removes this ambiguity. If $i<j$, then the length-$m$ block beginning at $im$ ends before the block beginning at $jm$. For $m>0$,

$$
im+m\le jm.
$$

Thus an aligned collision produces two disjoint copies. It also produces two equal order-preserving subsequences: for every offset $t$ with $0\le t<m$,

$$
x_{im+t}=x_{jm+t}.
$$

This is the **Disjoint-Subsequence Consequence**:

> If two distinct aligned length-$m$ blocks agree, then their corresponding letters form equal, order-preserving subsequences; when $m>0$, the two occurrences are disjoint.

Every aligned block is a contiguous subsequence, and every contiguous subsequence is also a scattered subsequence. The reverse implications fail. This hierarchy matters. A theorem about aligned blocks automatically supplies a theorem about a particular class of subsequences, but it does not determine the best possible threshold when arbitrary scattered positions are allowed.

## The four-letter, four-base deadline

For DNA, $q=4$. For four-base motifs, $m=4$. The number of possible four-mers is

$$
4^4=256.
$$

Therefore $257$ aligned blocks force a collision. Those blocks occupy

$$
257\cdot 4=1028
$$

bases. We obtain the **DNA Four-Mer Collision Theorem**:

> In every DNA sequence of at least $1028$ bases, among the $257$ aligned four-base blocks beginning at positions $0,4,8,\ldots,1024$, two are identical. The two copies are disjoint, and every position used lies among the first $1028$ bases.

Imagine reading a kilobase of DNA with a ruler marked every four bases. However the bases were chosen, one of the $256$ possible four-letter labels must appear on two of the ruler’s intervals.

The threshold concerns a fixed alignment. It does not say that every shorter stretch is repeat-free, nor that $1028$ is the sharp threshold for arbitrary contiguous windows or arbitrary scattered subsequences. Those richer pattern classes can only make repeats easier to find, and may yield substantially smaller thresholds.

## From one repeat to many

Long sequences do not merely force a single collision. They force multiplicity. Suppose we want some motif to occur at least $r+1$ times among aligned blocks. If every possible word appeared at most $r$ times, then the total number of sampled blocks would be at most

$$
rq^m.
$$

Consequently we have the **Aligned-Block Multiplicity Theorem**:

> If $n>rq^m$ aligned length-$m$ blocks are sampled from a sequence over a $q$-letter alphabet, then at least one length-$m$ word occurs in at least $r+1$ of those blocks.

Because aligned blocks are pairwise disjoint, this is also a disjoint-multiplicity result. In DNA with $m=4$, more than $256r$ aligned four-mers force one four-mer to appear at least $r+1$ times.

This theorem describes a staircase of inevitability. Crossing $256$ samples forces a duplicate; crossing $512$ forces a triple occurrence; crossing $768$ forces a fourfold occurrence; and so on. The phenomenon is not probabilistic clustering. It is forced crowding in a finite word space.

## The avoidance limit—and why it is sharp

The collision theorem can be turned around. If all $n$ aligned blocks are distinct, then necessarily

$$
n\le q^m.
$$

This is the **Aligned-Avoidance Bound**:

> A sequence whose first $n$ aligned length-$m$ blocks are pairwise different can contain at most $q^m$ such blocks.

For aligned sampling, the bound is sharp. List all $q^m$ possible words in any order and concatenate them. The resulting sequence has exactly $q^m$ distinct aligned blocks before repetition becomes unavoidable. Thus the counting argument identifies the exact worst-case capacity of the aligned codebook.

The language of coding is useful. Each block is a codeword, and the alphabet and motif length determine a finite code space. Repeat avoidance asks how long one can transmit blocks without reusing a codeword. The answer is exactly the code-space size.

## Worst-case guarantees versus typical genomes

Real genomes are not adversarial lists of all possible motifs. They contain homopolymers, microsatellites, transposable elements, segmental duplications, coding constraints, and regional changes in base composition. These features can make repetition arrive much sooner than the universal deadline.

But alphabet size alone cannot establish a claimed “genomic compression factor.” To say that a real chromosome is five times more repetition-prone than a random surrogate requires three ingredients absent from pure counting: an explicit genome, a precise statistic, and a specified random model.

A natural statistic is $U_g(m,r)$: the least window length such that every window of that length in a finite genome $g$ contains some length-$m$ word with at least $r$ disjoint occurrences. This definition turns the vague phrase “every sufficiently long region repeats” into a reproducible quantity. One can compare $U_g(m,r)$ with values from shuffled sequences or Markov-chain surrogates that preserve nucleotide composition and local transition frequencies.

Likewise, a random sequence obeys birthday-paradox behavior rather than the worst-case deadline. If there are $q^m$ nearly equally likely words, collisions typically emerge after roughly the square root of that number of independent samples, not after exhausting the entire code space. In an entropy-$h$ source, the effective number of typical words is closer to $e^{hm}$, suggesting a typical collision scale near

$$
e^{hm/2}.
$$

That is a probabilistic heuristic, not part of the deterministic theorem. It highlights an important lesson: worst-case Ramsey bounds and typical waiting times answer different questions.

## Beyond the ruler marks

The most intriguing frontier is the move from aligned blocks to arbitrary scattered words. A scattered occurrence chooses positions in increasing order but need not choose adjacent positions. Two scattered occurrences are disjoint if they use no common positions.

There are vastly more ways to embed a scattered word than to place an aligned block, but those embeddings overlap and depend on one another. Ordinary pigeonhole counting no longer captures the full geometry. The central extremal question becomes: how long can a sequence remain free of two disjoint occurrences of the same scattered length-$m$ word?

The aligned theorems provide a rigorous benchmark. They identify what follows from finite word count alone and expose exactly where new combinatorics must enter: in controlling overlaps among embeddings. Empirical genomics adds a second layer, asking how biological sequence structure moves observed thresholds below worst-case limits.

The resulting picture is both simple and rich. Four letters generate only $256$ four-mers. More than $256$ aligned samples force repetition; more than $256r$ force multiplicity; and equal aligned samples give disjoint subsequences automatically. Around those certainties lies a wider landscape of entropy, random collisions, low-complexity regions, and scattered patterns. DNA may be life’s text, but finite alphabets impose a grammar of inevitability: keep writing long enough, and some phrase must return.
