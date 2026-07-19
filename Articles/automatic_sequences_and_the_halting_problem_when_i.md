# Finite Memory, Infinite Sequences: How Automata Make “Does Zero Ever Appear?” Decidable

A sequence can be infinitely long and still have very little memory.

Consider the Thue–Morse sequence,

$$
0,1,1,0,1,0,0,1,\ldots
$$

Its terms never settle into an ordinary repeating cycle. Yet the rule behind it is astonishingly small: write an index in binary and count the $1$ digits. The term is $0$ when that count is even and $1$ when it is odd. A machine with only two states—“even so far” and “odd so far”—can generate every term.

This is the world of **automatic sequences**. Their apparent complexity unfolds from a deterministic finite automaton, a machine with a finite set of states that reads one symbol at a time. Such machines appear throughout computer science: lexical analysis, pattern matching, protocol design, digital circuits, and model checking. In sequence theory they offer something especially valuable: global questions about infinitely many terms can sometimes be reduced to a finite search.

The central question here sounds like a miniature halting problem:

> Given a finite-state generator, does its output ever equal zero?

For unrestricted programs, questions of this flavor can be undecidable. For finite automata, the answer is different. Not only is the question decidable; any positive answer has a short certificate. If an automaton has $N$ states and ever outputs zero, then some input word of length less than $N$ already produces zero.

That one bound turns an infinite search into a finite one.

## From sequences to paths through a finite machine

A deterministic finite automaton with output consists of four ingredients:

1. a finite input alphabet $\Sigma$;
2. a finite state set $Q$;
3. a transition rule $\delta:Q\times\Sigma\to Q$;
4. an output map $\tau:Q\to B$, where $B$ is the set of possible sequence values.

There is also a designated starting state $q_0$. For an input word $w=a_1a_2\cdots a_m$, the machine follows the transitions dictated by the letters and ends in a state denoted $\delta^*(q_0,w)$. Its output is

$$
A(w)=\tau\bigl(\delta^*(q_0,w)\bigr).
$$

This is a word-indexed sequence. Ordinary $k$-automatic sequences arise by feeding a machine the base-$k$ digits of an integer. There is a small but important modeling choice here: integer representations must be made canonical, or leading zeros must be handled consistently. The clean theorem below concerns all words. Passing to ordinary integer indices requires incorporating the chosen numeral convention; canonical base-$k$ words themselves form a regular language, so the same finite-state reachability philosophy still applies.

To detect a zero output, color every state $q$ for which $\tau(q)=0$ as accepting. The original question is now exactly this:

> Is any accepting state reachable from the start?

This translation is the conceptual heart of the result. The values may form an infinite sequence, and the set of input words is infinite, but the machine’s memory is finite.

## The short-witness theorem

The key fact is a reachability bound.

**Short-Witness Theorem.** Let a deterministic finite automaton have $N$ states. Its accepted language is nonempty if and only if it accepts some word $w$ with

$$
|w|<N.
$$

Why? Suppose the automaton accepts at least one word, and choose a shortest accepted word. If that word had length at least $N$, then while reading it the machine would visit at least $N+1$ state occurrences, counting the starting point. Since only $N$ states exist, two occurrences would be the same. The segment of input between those repeated states forms a loop. Removing the loop would leave the machine in exactly the same state before it reads the remaining suffix, producing a shorter accepted word. That contradicts minimality.

The theorem gives an immediate algorithm: enumerate all words of lengths $0,1,\ldots,N-1$, run the automaton on each, and stop if one reaches a zero-output state. If none does, zero never appears in the word-indexed sequence.

A direct enumeration over an alphabet of size $k$ examines

$$
1+k+k^2+\cdots+k^{N-1}
$$

words. This is finite, but breadth-first search on the state graph is more efficient: it visits at most $N$ states and at most $kN$ labeled transitions. Either way, finiteness is what matters for decidability, while graph search gives the practical implementation.

The theorem also provides a certificate. A “yes” answer can be accompanied by a word shorter than $N$. A “no” answer can be justified by listing all states reachable from $q_0$ and observing that none has output zero.

## Nonempty does not mean infinite

A tempting slogan says that if a finite automaton accepts one word, then it must accept infinitely many. That slogan is false.

Imagine a two-state machine that accepts the empty word but moves permanently to a rejecting state as soon as it reads any symbol. Its language is the singleton set

$$
\{\varepsilon\},
$$

where $\varepsilon$ denotes the empty word. The language is nonempty and finite.

The correct statement needs a long accepted word.

**Long-Witness Pumping Theorem.** If an automaton with $N$ states accepts a word $w$ satisfying

$$
|w|\ge N,
$$

then it accepts infinitely many words.

The reason is again repeated state visitation. A sufficiently long accepting computation contains a nonempty loop. This time, instead of deleting the loop, repeat it $0,1,2,\ldots$ times. The resulting words all reach the same state after the loop and therefore follow the same accepting suffix. Their lengths grow strictly, so they are distinct.

This theorem has a converse over a finite alphabet. There are only finitely many words shorter than $N$. Therefore, if the accepted language is infinite, at least one accepted word must have length at least $N$.

So we obtain an exact criterion:

**Infinitude Criterion.** For a deterministic finite automaton with $N$ states over a finite alphabet, the accepted language is infinite if and only if it contains an accepted word of length at least $N$.

At first glance, that still asks us to search through arbitrarily long words. A second shortening argument removes the infinity.

**Bounded Infinitude Criterion.** The language is infinite if and only if it accepts some word $w$ whose length lies in the finite window

$$
N\le |w|<2N.
$$

Starting from any accepted word of length at least $2N$, one can delete a loop among the first $N$ transitions. The deleted block has positive length and length at most $N$, so the new word remains at least $N$ symbols long. Repeating this operation eventually lands inside the window from $N$ through $2N-1$.

Thus two distinct infinite questions become finite:

- **Does zero ever occur?** Search below length $N$.
- **Does zero occur on infinitely many input words?** Search from length $N$ up to length $2N-1$.

These are different questions, and the singleton-language example shows why they must not be conflated.

## Thue–Morse as a two-state universe

The Thue–Morse sequence is the ideal example because its automaton has only two states. Let $t(n)$ be the parity of the sum of the binary digits of $n$, regarded as a value in $\mathbb{Z}/2\mathbb{Z}$. Then

$$
t(0)=0.
$$

Appending a binary $0$ does not change digit-sum parity, while appending a binary $1$ flips it. Numerically, these operations replace $n$ by $2n$ and $2n+1$. Hence

$$
t(2n)=t(n)
$$

and

$$
t(2n+1)=t(n)+1 \pmod 2.
$$

It follows immediately that neighboring members of each binary pair differ:

$$
t(2n)\ne t(2n+1).
$$

This pair of recurrences explains the self-similar blocks in

$$
0110100110010110\cdots.
$$

Every block is generated from an earlier block by copying and complementing. The sequence is not periodic, but it is governed by finite memory.

For the parity automaton, a one-symbol word containing $1$ reaches the odd state, so output $1$ occurs. A two-symbol accepted word is already long enough to meet the two-state pumping threshold, proving that the odd-parity language is infinite. Symmetrically, even parity—and therefore output $0$—also occurs infinitely often.

## A family of one hundred checks

The decision principle scales beyond a single celebrated sequence. Consider $100$ machines, each with state set

$$
Q=\{0,1,\ldots,99\}.
$$

For each chosen index $i\in Q$, build a machine in which reading the symbol $1$ jumps to state $i$, and only state $i$ has output zero. The one-letter word $1$ is therefore a zero witness for the $i$th machine. Different choices of $i$ produce different output maps, so the family contains $100$ distinct generators.

Every machine in this test family returns a positive answer to the zero-occurrence question, and each answer comes with the same concise form of certificate: a one-letter word. The example is deliberately transparent. Its purpose is not to simulate difficult data but to illustrate uniformity: one theorem and one algorithm cover every finite alphabet, every finite state set, and every decidable output comparison.

## Where the boundary really lies

The deepest lesson is not that “all sequence halting problems are easy.” It is that representation matters.

Finite automata cannot store an unbounded counter or stack. Once two input prefixes reach the same state, the machine has forgotten how those prefixes differed. That loss of memory creates loops, and loops create bounded witnesses. This is why reachability, emptiness, and infinitude admit finite certificates.

More general sequence generators may carry richer structure. Morphic sequences, for example, are produced by repeatedly substituting words for symbols and then applying a coding. Their occurrence questions should be phrased carefully: for ordinary morphic words over a finite alphabet, whether a symbol occurs may reduce to reachability in a finite dependency graph of letters, while subtler index-sensitive or zero-set questions can be substantially harder. The useful boundary is therefore not captured by a slogan alone; it depends on exactly what is generated and exactly what is being asked.

There are also important algebraic boundaries. Christol’s theorem connects automatic sequences and algebraic power series over finite fields. It does not directly turn integer-valued automatic sequences into a bounded-degree polynomial-recurrence class. Changing the coefficient domain changes the mathematics.

Still, the finite-state result is crisp and complete. An output automaton with $N$ states cannot hide its first zero beyond every finite horizon. If zero appears at all, it appears before length $N$. If it appears on infinitely many words, that fact is witnessed between lengths $N$ and $2N-1$.

An infinite sequence may stretch forever. But when its generator has finite memory, infinity leaves fingerprints in a finite place.
