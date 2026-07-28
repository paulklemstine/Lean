# When DNA Must Repeat

## A combinatorial law hidden in every long genetic word

DNA is often described as a book written with four letters: A, C, G, and T. The metaphor is useful, but it can also be misleading. A book has words separated by spaces; DNA does not. To find a short motif, one slides a window along the sequence. A window of width four exposes a **four-mer**, a block such as ACGT or TTAA. Move the window one position and a new four-mer appears.

This simple motion raises a question with the flavor of Ramsey theory: how long can a DNA word be before repetition becomes unavoidable? No assumptions about evolution, randomness, mutation, or biological function are allowed. We seek a guarantee that applies to every possible arrangement of the four letters.

The answer for four-mers is strikingly small: **every DNA word of length at least $260$ contains two equal contiguous four-mers beginning at different positions.** The two occurrences may overlap. For example, AAAAA contains the four-mer AAAA at its first and second positions. The theorem says not that typical DNA repeats by length $260$, but that avoiding such a repeat beyond that point is mathematically impossible.

The same argument reveals a broader principle. If an alphabet has $q$ symbols and we inspect blocks of length $k$, then every word of length at least

$$
q^k+k
$$

contains a repeated contiguous $k$-mer. Conversely, any word whose starting positions all produce distinct $k$-mers must have length strictly less than $q^k+k$.

These statements come from one of combinatorics' most powerful habits: count the available patterns, then count how many places demand a pattern.

## The sliding-window pigeonhole

Suppose a word has length $m$. A block of length $k$ can begin at positions $1,2,\ldots,m-k+1$, so there are

$$
m-k+1
$$

windows. Over an alphabet of $q$ symbols, exactly $q^k$ possible $k$-mers exist: each of the $k$ slots has $q$ choices.

If every window were different, the number of windows could not exceed the number of possible patterns. Thus repeat-freeness would require

$$
m-k+1\le q^k.
$$

Whenever $m\ge q^k+k$, however,

$$
m-k+1\ge q^k+1,
$$

so more windows exist than possible $k$-mers. Two windows must receive the same pattern. This is the pigeonhole principle in motion: the windows are pigeons and the possible words are holes.

The boundary is exact for this counting argument. At $m=q^k+k-1$, there are exactly $q^k$ windows, so counting alone does not force two patterns to coincide; all patterns might occur once. At $m=q^k+k$, there are $q^k+1$ windows, and collision is unavoidable. Additional restrictions on the word can force repetition much earlier.

For DNA four-mers, $q=4$ and $k=4$. There are

$$
4^4=256
$$

possible four-letter patterns. A word of length $260$ has

$$
260-4+1=257
$$

four-mer windows. Two of those $257$ windows must match. That is the entire engine of the theorem.

## Selection does not defeat the law

A genome need not be read at every position. Imagine choosing $m$ positions from a larger genome and writing down the chosen letters in the order selected—or even in any prescribed order. The result is a new word of length $m$. Its adjacent blocks are contiguous in the **selected word**, though their letters need not have been adjacent in the original genome.

This distinction matters. A selected four-mer is formed from four consecutive entries of the selected list. It is therefore a scattered pattern in the surrounding genome only when the selection itself follows genomic order. The theorem does not claim that arbitrary scattered occurrences have been fully classified. It says something precise and useful: **any selection of at least $260$ DNA letters, viewed as a word, contains two equal adjacent four-blocks within that selected word.**

No monotonicity condition is needed for the counting argument. If the selection does preserve genomic order, the conclusion immediately becomes a statement about a subsequence: among the chosen letters are two equal four-letter blocks occupying consecutive places of the subsequence.

This is a robust form of inevitability. Sampling, thinning, or rearranging the input cannot create more than $256$ possible four-mers. Once the selected word offers $257$ windows, repetition returns.

## Complexity compression

Real genomes are not uniform four-letter soups. They contain runs, tandem repeats, biased regions, and stretches in which only a small part of the alphabet is effectively active. The counting principle quantifies why such regions repeat sooner.

Suppose a length-$m$ DNA word is produced in two stages. First, each position receives one of $b$ effective symbols. Second, a decoding map sends those effective symbols to A, C, G, or T. Although the visible output is DNA, its combinatorial freedom is controlled by $b$, not by four.

The **effective-alphabet theorem** says: if

$$
m\ge b^4+4,
$$

then two distinct windows in the decoded DNA word are equal four-mers.

Why? Before decoding, only $b^4$ effective four-blocks are possible. At length $b^4+4$, there are $b^4+1$ windows, so two encoded windows agree. Applying the same decoder letter by letter preserves their equality.

The binary case is especially vivid. If a region is generated from just two effective symbols, then

$$
2^4+4=20.
$$

Thus **every binary-generated DNA region of length at least $20$ has a repeated four-mer after any fixed decoding into the four DNA letters.** Compare $20$ with the general four-letter threshold $260$. Restricting four possible symbols to two shrinks the guaranteed threshold by a factor of thirteen.

This is a deterministic meaning of “low complexity.” It does not depend on a statistical model. A region with fewer effective symbols simply has fewer possible local blocks, so collisions arrive earlier.

## An algorithm that finds the collision

The proof is also an algorithm. Slide a window of width $k$ from left to right. Store the first position at which each $k$-mer appears. When a window already in the table appears again, return its old position and the current one.

For a word of length $m$, the scan examines $m-k+1$ windows. With direct string slicing, forming each window costs $O(k)$ time, giving $O((m-k+1)k)$ time and at most $O(\min\{m-k+1,q^k\}k)$ stored symbols. For short fixed motifs such as four-mers, this is effectively linear in sequence length. Encoding each DNA letter by two bits can reduce each four-mer to an eight-bit integer, making lookup particularly simple.

A second algorithm tests complexity compression. Given an encoded word over $b$ symbols and a decoder into DNA, it first decodes the sequence and then runs the same collision finder. More efficiently, it can find a repeated encoded block directly; equal encoded blocks are guaranteed to remain equal after decoding.

These procedures do more than illustrate a theorem. They return witnesses: two distinct starting positions and the repeated motif itself. That makes the mathematical guarantee inspectable on concrete data.

## What the theorem does—and does not—say about genomes

It is tempting to jump from a universal theorem to a claim about the human genome. One might expect low-complexity biological regions to force repeats much earlier than a random model would. That is a reasonable empirical hypothesis, but it is not established by counting alone.

A meaningful comparison requires choices: Which genome assembly? Are windows consecutive in the genome or selected subsequences? How are ambiguous symbols such as N handled? Are overlapping occurrences allowed? What random model preserves base frequencies or local correlations? Which statistic is called $L(k)$? Without those decisions, numerical claims such as a factor-of-five compression are not mathematical consequences of the theorem.

The proven results supply a baseline. They say that $260$ selected DNA letters always suffice for a repeated four-mer, and that a binary-generated region needs only $20$. Actual genomic data may collide far earlier. Measuring how much earlier—and attributing the gap to biological structure—belongs to reproducible computational biology.

## Ramsey flavor without overstatement

Ramsey theory studies the emergence of order in sufficiently large structures. Its famous triangle theorem says that every red-blue coloring of the edges of a complete graph on six vertices contains a monochromatic triangle. The DNA result has the same philosophical flavor: a large enough object cannot avoid a prescribed regularity.

Technically, however, the mechanism here is the pigeonhole principle rather than the full machinery of Ramsey's theorem. There is no graph coloring hidden in the proof. There are simply more windows than possible labels. Calling this “Ramsey-like” captures the inevitability, but the exact theorem is a finite word-counting statement.

That precision is a strength. It cleanly separates three layers:

1. **Universal combinatorics:** over $q$ symbols, length $q^k+k$ forces a repeated contiguous $k$-mer.
2. **Selection:** the same guarantee applies to any chosen word, including an order-preserving subsequence of a larger sequence.
3. **Structural compression:** if only $b$ effective symbols generate the visible letters, the four-mer threshold falls to $b^4+4$.

Each layer has a short proof, and each supports concrete computation.

## The next frontier: truly scattered repeats

Contiguous blocks in a selected word are only one notion of subsequential repetition. A more ambitious question asks for two equal scattered words chosen through two order-preserving embeddings, perhaps with disjoint positions. Then overlap, interleaving, and positional constraints matter. The simple sliding-window count no longer captures the whole problem.

Several directions follow naturally. One can seek the sharp maximum length of a four-letter word avoiding two disjoint equal scattered four-mers. One can compare deterministic thresholds with probabilities for random words. One can replace effective alphabet size by richer local descriptors: the number of distinct subwords, run structure, or entropy-like measures. Finally, carefully specified genome datasets can test how these parameters behave in nature.

The central lesson will survive those refinements. Repetition is not merely a nuisance of long sequences. It is a mathematical consequence of finite expressive capacity. DNA has four letters; a four-letter window has only $256$ possible faces. Once a sequence presents more windows than that, two faces must be the same. In low-complexity regions, the repertoire contracts, and inevitability arrives even sooner.
