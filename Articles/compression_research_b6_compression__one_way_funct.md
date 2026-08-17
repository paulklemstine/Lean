# The Shortest Description You'll Never Find

## Why compression, randomness and cryptography are the same story

Every time you zip a folder, stream a film, or send a photograph across a network, you are betting on a quiet mathematical fact: most of the data we care about is *redundant*. Text repeats. Images have smooth patches. Sound is periodic. A good compressor finds that redundancy and writes a shorter description of the same object.

Push the idea to its logical extreme and you get one of the great questions of theoretical computer science. Fix a way of turning descriptions into objects — call it a *decompressor* — and ask: for a given object, what is the **shortest** description that produces it? That number is the object's *complexity*. Finding the shortest description is the ultimate compression problem.

This article is about three walls that stand between us and that ideal, and about the surprising fact that the third wall is made of the same material as modern cryptography. The punchline, stated up front:

> **Randomness helps compression by exactly the number of random bits you are allowed to use — not one bit more. Beyond that, the only thing standing between a compressor and the shortest description is the existence of one-way functions. Finding shortest programs and breaking cryptography are the same task.**

Let us build that claim carefully.

---

## Wall 1: the pigeonhole ceiling

Fix a decompressor: a map $D$ that takes a finite bit string $p$ (the *program*, or *description*) and returns an object $D(p)$. Say that $y$ is *describable* if $D(p) = y$ for some $p$, and define the complexity
$$K_D(y) \;=\; \min\{\,|p| \;:\; D(p) = y\,\},$$
the length of the shortest program for $y$. There is no cleverness in $D$ that we are forbidding: $D$ may be any function whatsoever, arbitrarily slow, arbitrarily large, tailored to whatever data you like.

Even so, counting stops you cold.

> **The Pigeonhole Ceiling.** For every decompressor $D$, every budget $s$, and every finite set $T$ of objects, if every element of $T$ has a $D$-program of length at most $s$, then
> $$|T| \;\le\; 2^{s+1} - 1 .$$

The reason is that there are exactly $2^{s+1}-1$ bit strings of length at most $s$ (one empty string, two of length one, four of length two, and so on), and distinct objects need distinct programs. A tidy way to see the count is to read a bit string as a binary numeral with an invisible leading $1$: the empty string becomes $1$, the string $b_1\ldots b_m$ becomes a number strictly below $2^{m+1}$. This encoding is injective, so programs of length $\le s$ inject into $\{1, 2, \dots, 2^{s+1}-1\}$.

Two immediate consequences make the ceiling bite.

> **Incompressible Strings Exist.** For every decompressor $D$ and every $s$, some bit string of length $s+1$ has no $D$-program of length $\le s$.

There are $2^{s+1}$ strings of length $s+1$ but only $2^{s+1}-1$ short programs, so one string must be left out. No matter what compression format you invent — no matter how much you know about the data, the physics, or the future — some file of any given size gets no smaller.

> **Density of Incompressibility.** For every decompressor $D$ and every $1 \le c \le n$, the fraction of strings of length $n$ that can be compressed to $n-c$ bits is at most $2^{-(c-1)}$.

So the failure isn't a corner case: saving even ten bits is impossible for all but about a thousandth of your inputs. Compression works in practice only because real data lives in a vanishingly thin, highly structured sliver of the space of all possible files.

This first wall is unconditional. It has nothing to do with speed, and nothing to do with knowledge. It is arithmetic.

---

## Wall 2: does randomness help? Exactly by the seed length

Randomized algorithms are magic in many corners of computing: they factor polynomials, test primality, route packets, and estimate volumes far better than any deterministic method we know. So it is natural to hope that a randomized compressor — one that flips coins, or shares a random seed with the decompressor — could slip under the pigeonhole ceiling.

Model this honestly. A *seeded* decompression system is a family $\{D_r\}_{r \in R}$ of decompressors indexed by a finite seed space $R$; compression succeeds for $y$ at budget $s$ if **some** seed $r$ gives $y$ a $D_r$-program of length at most $s$. The seed is free: you don't pay for it in the program length.

> **Seed-Budget Theorem.** If every element of a finite set $T$ is compressible to $s$ bits under some seed, then
> $$|T| \;\le\; |R| \cdot \bigl(2^{s+1} - 1\bigr).$$

The proof is the pigeonhole argument again, run in the product space: pair each object with the (seed, program) that handles it, and count. Since $|R| = 2^k$ corresponds to $k$ random bits, randomness buys you at most $k + 1$ bits of compression.

Is that bound reachable, or merely an upper limit? It is reachable, essentially exactly:

> **The Prefix Construction.** Let $R$ be all seeds of length $k$ and let $D_r(p) = r \frown p$ (concatenation). Then every string $y$ of length $k+s$ is compressed to $s$ bits: choose $r$ to be the first $k$ bits of $y$, and let the program be the remaining $s$ bits.

There are $2^{k+s}$ strings of length $k+s$ and only $2^{s+1}-1$ short programs, so a deterministic decompressor cannot do this — the seeded one does. Combining the two statements:

> **Randomness Gain Theorem.** With $2^k$ seeds, all $2^{k}\cdot 2^{s}$ strings of length $k+s$ compress to $s$ bits, which is a gain of exactly $k$ bits over the deterministic ceiling; and no seeded family with seed space $R$ ever compresses more than $|R| \cdot (2^{s+1}-1)$ objects to $s$ bits.

Randomness, then, is not magic here. It is bookkeeping. Every bit of shared randomness buys exactly one bit of compression, because the seed *is* part of the description — you have simply moved it off the ledger.

That reading is confirmed from the other side. Suppose you insist on determinism. Take a seeded family and build a single decompressor that reads its program as "the seed, self-delimited, followed by the real program". Writing $|r|$ in unary, then a separator, then $r$ and then $p$, costs $2|r|+1$ extra bits, and yields:

> **Derandomization Cost.** For every seeded family $\{D_r\}$ there is one deterministic decompressor $U$ with
> $$K_U(y) \;\le\; 2|r| + 1 + K_{D_r}(y) \quad \text{for every seed } r \text{ describing } y.$$

Upper bound and construction agree to within a constant factor on the seed length. Randomness helps by the seed length, and no computational assumption of any kind can change this. The question "can random number generators help us compress?" has a complete, quantitative answer: *yes, by exactly the number of random bits, and never more.*

---

## Wall 3: the shortest description exists — but can you find it?

Here the story turns.

The first two walls concern *existence*: how many short descriptions there can possibly be. The third concerns *discovery*. Suppose a short description of your file exists. Can an efficient algorithm find it?

Call an algorithm $A$ a **shortest-program finder** for the decompressor $D$ if, for every describable $y$, the output $A(y)$ is a genuine program ($D(A(y)) = y$) of optimal length ($|A(y)| = K_D(y)$). This is the compression problem in its purest form.

Now recall the central object of modern cryptography. A **one-way function** is a function $f$ that is easy to evaluate but hard to invert: given $y$ in the range of $f$, no efficient algorithm can produce any $x$ with $f(x) = y$. Their existence is the minimal assumption on which essentially all of private-key cryptography rests — pseudorandom generators, digital signatures, commitment schemes. Nobody has proved one-way functions exist, but the whole digital economy behaves as though they do.

The two notions look unrelated. They are not. The bridge is a one-line observation followed by a genuinely clever reduction.

**The easy direction.** A decompressor is just a function from programs to objects; inverting it means finding *some* program for a given object. A shortest-program finder produces the *best* program, so in particular it produces one. Hence:

> **Compression Search Is At Least As Hard As Inversion.** Every shortest-program finder for $D$ is an inverter for $D$.

If you can compress optimally, you can break every one-way function — treat the function as a decompressor and read off the preimage.

**The hard direction** is the interesting one: if you can invert, can you compress optimally? Producing *some* preimage is a weaker skill than producing the *shortest* one; a general-purpose inverter gives you no control over the length of what it returns. The trick is to force the issue by asking the inverter a *guarded* question.

For a function $f$ and a length bound $l$, define the **length-guarded** version
$$f_l(p) \;=\; \begin{cases} \texttt{1} \frown f(p) & \text{if } |p| \le l,\\ \texttt{0} \frown p & \text{otherwise.}\end{cases}$$
The tag bit is a receipt. An inverter for $f_l$, asked about $\texttt{1}\frown y$, must return a program of length at most $l$ for $y$ under $f$ — if it returned anything longer, the guard would fire and the output would carry the wrong tag. So an inverter for $f_l$ is not just an inverter: it is a *length-bounded* inverter, exactly what we could not get before.

Now run a bounded linear search on $l = 0, 1, 2, \dots$, asking each guarded inverter in turn, and take the first $l$ that succeeds. That first success is at $l = K_f(y)$, and the program returned has length exactly $K_f(y)$.

> **Inversion Solves Compression Search.** If every guarded function $f_l$ can be inverted, then the assembled search algorithm outputs, for every describable $y$ whose complexity lies within the search budget, a *shortest* $f$-program for $y$.

To make the reduction a statement about *efficient* algorithms rather than arbitrary ones, we work relative to any class $\mathcal{C}$ of algorithms that is closed under the two operations the reduction uses — length guarding and bounded search over the guard — with a notion of admissible resource bounds containing the constants and the identity and closed under maximum. (Think: polynomial time.) One more hypothesis is needed, and it is the natural one: a function is *honest* for the class if every value in its range has a preimage of admissible length; real candidate one-way functions are honest. With that:

> **Main Equivalence.** For any such class, the following are equivalent: (i) every honest function of the class can be inverted within the class; (ii) every honest decompressor of the class admits a shortest-program finder within the class.
>
> **Cryptographic Form.** One-way functions exist for the class **if and only if** the compression-search problem is hard for the class.

And the equivalence is robust. Suppose you settle for "good enough" compression: an algorithm that always outputs a valid program whose length exceeds the optimum by at most some slack $\delta(|y|)$ — a hundred bits, or a thousand, or any function of the input length you like.

> **Approximation Does Not Help.** For every slack function $\delta$, solving approximate compression search for all honest decompressors of the class is again equivalent to inverting all honest functions of the class. One-way functions exist if and only if *approximate* compression search is hard.

Nor does relaxing from *finding* to *deciding* help. Suppose you had only an oracle answering yes/no questions of the form: "is there a continuation $p$ of the prefix $w$, of length $n$, with $D(w \frown p) = y$?" Then walk down the binary tree of prefixes: at each step ask whether appending $\texttt{0}$ keeps a solution alive; if yes, append $\texttt{0}$, otherwise append $\texttt{1}$. Each answer is a single bit and each step is forced, so after $n$ questions you hold an actual program of length exactly $n$; a preliminary search for the least feasible $n$ makes it optimal.

> **Search-to-Decision.** A correct decision oracle for the prefix-compressibility predicate of $D$ yields a shortest-program finder for $D$ — and hence an inverter. Under a one-way function, no algorithm of the class can implement that oracle.

So the exact task, the approximate task, and the decision task all sit at precisely the same cryptographic level.

---

## What this means for compression in practice

Turn the equivalence around and read it as a statement about limits.

> **The Description Gap.** If a one-way function exists for a class of algorithms, then for **every** algorithm $A$ of the class there is a string $y$ that has a short description — of length within an admissible bound — which $A$ fails to produce.

Read that slowly. The short description *exists*. It is not ruled out by counting; the pigeonhole ceiling has nothing to say here. It is simply invisible to $A$. Compression in the computational world is bounded not by information, but by search.

One might object: a single bad input is a fluke; hard-wire a lookup table and move on. That objection collapses the moment the collection of algorithms is closed under exactly that repair — that is, whenever overwriting an algorithm on a finite set of inputs keeps you inside the collection.

> **Failure Sets Are Infinite.** Let $\mathcal{A}$ be a collection of algorithms closed under finite patching, and suppose no member of $\mathcal{A}$ inverts $f$. Then **every** member of $\mathcal{A}$ fails on an *infinite* set of inputs.

The proof is a perfect little argument by contradiction: if some $A$ failed only finitely often, hard-wire the correct answers on that finite set. Patch-closure says the repaired algorithm is still in the collection — and it now inverts $f$ everywhere, contradicting hardness. Consequently every candidate compressor fails to output shortest programs on infinitely many inputs, each of which genuinely has a description.

This is not an empty scenario. Consider the algorithms that agree with the "delete the first bit" map only finitely often; this collection is closed under finite patching. It contains the tagging function $y \mapsto \texttt{1}\frown y$, and no member of it inverts that function, because an inverter would have to delete the leading bit on the whole infinite range. So the hypotheses are simultaneously satisfiable and the infinite-failure conclusion has real content.

Finally, one might hope that a *universal* decompressor — a single format that simulates every other, charging only a constant overhead for naming which one — dissolves the problem. It does dissolve the *existence* question elegantly: writing the index $i$ in unary before the program gives
$$K_U(y) \;\le\; K_{D_i}(y) + i + 1,$$
so one format is essentially as good as all of them at once, and descriptions of concatenations are subadditive, $K(xy) \le 2K(x) + 1 + K(y)$. But universality changes nothing about findability:

> **Universality Does Not Close the Gap.** If $f$ is one-way for the class and appears in the family simulated by $U$, then for every algorithm of the class there is a string whose description is short even in the universal format — within $i+1$ bits of its $f$-complexity — and which the algorithm still fails to describe.

---

## The calibration

Put the three walls in one frame, for a fixed budget $s$ and seed length $k$:

1. **Information-theoretically**, no decompressor compresses more than $2^{s+1}-1$ objects to $s$ bits, and some string of length $s+1$ resists entirely.
2. **With randomness**, a seed space $R$ raises the count only to $|R|\cdot(2^{s+1}-1)$, and the gain of $\log_2|R|$ bits is achieved by simply putting the first $\log_2|R|$ bits of the object into the seed.
3. **Computationally**, if one-way functions exist, then there are strings with short descriptions that no efficient algorithm ever finds — and each algorithm misses infinitely many of them.

That is the calibration the whole programme was after. Randomness helps compression exactly up to the seed length. Efficient compression then stops again, at the cryptographic hardness boundary — and it stops there whether you demand exact optimality, approximate optimality, or a mere yes/no answer.

There is a pleasing symmetry in the conclusion. The reason your files cannot get smaller is, in the end, the same reason your passwords are safe. Compression and cryptography are two views of one phenomenon: some structure is there, and cannot be found.
