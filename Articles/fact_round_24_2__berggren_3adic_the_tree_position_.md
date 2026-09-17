# The Sealed Address: What a Pythagorean Tree Refuses to Tell You About a Number

## A number with a secret

Take two large prime numbers, multiply them together, and publish the product. That single act — trivial to perform, apparently impossible to undo — is the engine underneath a great deal of modern cryptography. The product $N = pq$ is public; the factors $p$ and $q$ are the secret. Everyone has known for four centuries that $N$ *determines* $p$ and $q$ uniquely. Nobody knows how to get them back quickly.

So people look for side doors. If you cannot compute the factors directly, perhaps you can compute something *about* them: a bit here, a parity there, a hint about whether $p$ and $q$ are close together or wildly far apart. Enough hints, and the search collapses.

This article is about one such side door, and about the proof that it is bricked shut.

The door in question is beautiful. It comes from Pythagoras.

## Every odd number is a difference of squares

Start with a piece of school algebra that Fermat turned into a factoring method. If $N = pq$ with $p$ and $q$ both odd, set

$$m = \frac{q+p}{2}, \qquad n = \frac{q-p}{2}.$$

Both are whole numbers, because $p$ and $q$ are odd, and

$$m^2 - n^2 = (m-n)(m+n) = p \cdot q = N.$$

The pair $(m,n)$ — call it the **Fermat pair** of $N$ — is just the factorisation of $N$ written in a different coordinate system. Knowing $(m,n)$ is exactly as good as knowing $p$ and $q$: you recover them as $p = m-n$ and $q = m+n$. Fermat's own factoring method is the brute-force search for this pair, and it is fast only when $p$ and $q$ happen to be close together.

Now the beautiful part. When $p$ and $q$ are coprime and odd, the pair $(m,n)$ satisfies three conditions: $0 < n < m$, the two are coprime, and exactly one of them is even. Those three conditions are precisely the classical recipe for **primitive Pythagorean triples**: from such an $(m,n)$ you build the right triangle with legs $m^2 - n^2$ and $2mn$ and hypotenuse $m^2 + n^2$, and every primitive triple arises this way exactly once. The leg $m^2 - n^2$ is our $N$.

So every odd semiprime $N$ is a leg of a unique primitive Pythagorean triple, and the factorisation of $N$ is encoded in which triple that is.

## The tree of all right triangles

Primitive Pythagorean triples have a structure that is a small miracle of number theory, discovered in modern form by B. Berggren in 1934: **they form a perfect ternary tree.** There is a root, $(m,n) = (2,1)$, giving the triangle $3$–$4$–$5$. Every node has exactly three children, produced by three fixed rules:

$$A:(m,n) \mapsto (2m-n,\; m), \qquad B:(m,n) \mapsto (2m+n,\; m), \qquad C:(m,n)\mapsto (m+2n,\; n).$$

Apply these rules in all possible ways, and you generate every primitive Pythagorean triple exactly once — no repeats, no omissions. Each triple therefore carries a unique **address**: a finite word in the three letters $A$, $B$, $C$, read off from the path down from the root. The triple $3$–$4$–$5$ has the empty address; its children are $5$–$12$–$13$, $21$–$20$–$29$, $15$–$8$–$17$.

Put the two observations side by side and something tantalising appears. Your secret semiprime $N$ sits at a definite, unique address in this tree. The address exists. It is a finite string of letters. And if you could read it, you would have factored $N$ — because walking the path tells you the pair $(m,n)$, and $(m,n)$ hands over $p = m-n$ and $q = m+n$.

The question is whether anything about that address leaks out of $N$ itself.

## What leaks: the skeleton

Something does leak. Here is the cleanest statement, and it is exact.

> **The Skeleton Theorem.** Let $(m,n)$ be any coprime pair and $N = m^2 - n^2$. Then
> $$N \equiv 1 \pmod 3 \iff 3 \mid n, \qquad N \equiv 2 \pmod 3 \iff 3 \mid m, \qquad N \equiv 0 \pmod 3 \iff 3 \nmid m \text{ and } 3 \nmid n.$$

The proof is a single line of reasoning: squares modulo $3$ take only the values $0$ and $1$, so $m^2 - n^2$ modulo $3$ is determined by which of $m, n$ is a multiple of $3$ — and coprimality forbids both at once, so the three cases above are exhaustive and mutually exclusive.

This is a genuine channel. Look at $N$ modulo $3$ — a single cheap division — and you learn something structural about the coordinates of a node you have never visited. Call it the **$3$-adic skeleton** of the node: the pattern of divisibility by $3$ in its coordinates.

But now read the theorem in the other direction. The three cases are exhaustive and exclusive, which means the implications run both ways: the skeleton determines $N \bmod 3$, and $N \bmod 3$ determines the skeleton. The two are *the same piece of information wearing different clothes*. The channel is a mirror, not a window.

And we can say what it is a mirror of. Translate the skeleton flag $3 \mid n$ back into the language of the factors. Since $n = (q-p)/2$,

$$3 \mid n \iff p \equiv q \pmod 3,$$

and correspondingly $N = pq \equiv 1 \pmod 3$ exactly when $p \equiv q \pmod 3$ with neither divisible by $3$. That congruence $p \equiv q \pmod 3$ is what one calls the **trace** of the factorisation modulo $3$: the most elementary thing anyone can compute about $p$ and $q$ from $N$, available the instant you divide $N$ by $3$ and look at the remainder. The skeleton restates it and adds nothing.

An experiment on $40{,}000$ random semiprimes, with $p$ and $q$ uniform primes in the range $[2^{16}, 2^{24})$, confirmed both equivalences on every single instance — $40000/40000$, no exceptions, as the theorem demands.

So: the visible part of the tree position is exactly the part you already had.

## What does not leak: the letters

Everything else about the address is *metric* rather than skeletal — which branch you take, how deep you go, in what order. And here the picture is entirely different.

First, we need to know how the address is actually determined, and this turns out to be startlingly simple.

> **The Parent-Interval Law.** Let $(m,n)$ be a node other than the root. Its parent in the tree, and the letter connecting them, are determined by the *ratio* $m/n$ alone:
> $$1 < m/n < 2 \;\Rightarrow\; \text{letter } A, \text{ parent } (n,\,2n-m);$$
> $$2 < m/n < 3 \;\Rightarrow\; \text{letter } B, \text{ parent } (n,\,m-2n);$$
> $$m/n > 3 \;\Rightarrow\; \text{letter } C, \text{ parent } (m-2n,\,n).$$
> These are the *only* possible parent and letter: no other node and generator produce $(m,n)$.

(The boundaries $m = 2n$ and $m = 3n$ never occur except at the root, since they would force $n$ to divide $m$ and coprimality then makes $n = 1$, $m \in \{2,3\}$; parity rules out $m=3$.)

Each step of the descent strictly decreases $m+n$, so the process terminates, and it terminates at the root. That gives the exact statement the experiment could only sample: **every** Fermat pair — every node — is the value of one and only one word in $A,B,C$. The empirical "$40000/40000$ descents reached the root" becomes a theorem with no step cap and no exceptions, and the tree is *precisely* the set of Fermat pairs.

Notice what the Parent-Interval Law says about our problem. The letters are read off from the ratio $m/n$ — that is, from

$$\frac{m}{n} = \frac{q+p}{q-p},$$

which is a function of how *balanced* the factorisation is. Spelling that out gives the sharpest single sentence in this whole story.

> **The Letter Is the Balance Band.** For $N = pq$ with $0 < p < q$ odd, the first letter of the address of $N$ is
> $$A \iff q > 3p, \qquad B \iff 2p < q \le 3p, \qquad C \iff q \le 2p.$$

One letter. Three cases. Read it, and you learn whether your semiprime's factors are nearly equal, moderately spread, or wildly lopsided — and that is exactly the information that tells an attacker whether Fermat's method will succeed in seconds or in geological time. It is a genuinely valuable bit and a half.

You cannot have it.

## The seal

Here is the obstruction, and it is as concrete as obstructions get: an explicit family of counterexamples that works for every modulus at once.

> **The Letter Seal.** Let $M \ge 3$ be any odd modulus. Consider the three nodes
> $$(M+1,\,M), \qquad (3M-1,\,M), \qquad (3M+1,\,M).$$
> All three are legitimate tree nodes. Their $N$-values are $2M+1$, $8M^2-6M+1$ and $8M^2+6M+1$ — all three congruent to $1$ modulo $M$. Their first letters are $A$, $B$ and $C$ respectively.

Three nodes, identical residue, three different letters. Therefore **no function of $N \bmod M$ can compute the first letter**: any such function would have to return the same answer on all three, and it would be wrong at least twice. Taking $M = 3^k$ gives the $3$-adic form: the letter is invisible at every $3$-adic level, for every $k \ge 1$.

This is stronger than the experiment's verdict in kind, not just in degree. The experiment measured mutual information between $N \bmod 3^k$ and the letters at depths up to $10$, for $k$ up to $6$, against a $300$-shuffle permutation null; across roughly $150$ such tests the largest deviation was $z = +2.51$, comfortably inside noise even before correcting for multiple comparisons. That is a statement that no signal was *detected*. The theorem above says no signal *exists* — at any modulus, odd or even, forever.

Three refinements sharpen the seal until there is nothing left to hope for.

**First, nontrivial factorisations.** A sceptic may object that the $A$-witness $(M+1,M)$ has $m-n = 1$, so its "factorisation" is the trivial $N = 1 \cdot N$; perhaps the seal is an artefact of degenerate nodes. Replace the family by

$$(4M-1,\,2M), \qquad (4M+1,\,2M), \qquad (6M+1,\,2M),$$

whose $N$-values factor as $(2M-1)(6M-1)$, $(2M+1)(6M+1)$ and $(4M+1)(8M+1)$. All are $\equiv 1 \pmod M$; the letters are again $A$, $B$, $C$; and now every factorisation is honestly nontrivial, with the smaller factor at least $2M-1$. Better still, this family needs no parity assumption: it works for **every** modulus $M \ge 2$, even ones included. So no residue channel of any modulus reveals the balance band of a genuine factorisation.

**Second, depth.** Perhaps the letters are hidden but the *length* of the address leaks. It does not. Consider the "spine" of the tree — the path that takes the letter $C$ over and over. A direct induction shows the spine of length $d$ lands on the node $(2+2d,\,1)$, with
$$N = (2+2d)^2 - 1 = (2d+1)(2d+3).$$
For any modulus $M$, the spine nodes of depth $1$ and of depth $1 + jM$ have $N$-values congruent modulo $M$ for every $j$. One residue class thus contains nodes of unboundedly many depths, so no function of $N \bmod M$ computes the depth either.

**Third, position by position.** The deepest objection: maybe a letter is readable once you already know all the *shallower* letters — a sequential channel rather than a one-shot one. It is not. Fix a modulus $M \ge 2$ and a depth $t$, and consider the family

$$\text{node}(M,k,t) = (4tM + 2Mk + 1,\; 2M), \qquad k = 1,2,3.$$

Every one of them has $N \equiv 1 \pmod M$. Descending from any of them, the first $t$ steps all read $C$ — they agree in the entire shallower prefix. And at depth $t$ they read $A$, $B$, $C$ respectively. So even an adversary handed the residue *and* the whole prefix cannot determine the next letter. The seal holds at every position of the address, not merely the first.

## Why the tree cannot be a shortcut

Two further facts explain, in structural terms, why this had to come out the way it did.

The first is a size estimate. Each Berggren step increases $m+n$ by at least $2$, so a node at depth $d$ satisfies

$$2d + 3 \le m + n \le N,$$

and the bound is attained exactly on the $C$-spine. The depth of the $N$-node is therefore linear in $N$ — which is to say **exponential in the number of digits of $N$**. For a $2048$-bit semiprime the address can be astronomically long. Even if the letters were readable one at a time, at zero cost each, merely writing the address down is not a polynomial-size operation. The tree position is not a compact channel; it is an enormous one, most of which is unreachable.

The second is a circularity. The letters are a deterministic function of the ratio band of $m/n$ — that is the positive control of the whole investigation, and it fires perfectly: in the experiment, the mutual information between the ratio band and the first letter was measured at $1.4738$ bits, exactly equal to the entropy of the letter itself, meaning the band determines the letter with no residual uncertainty. But determining the band means knowing $m/n$, and knowing $(m,n)$ means knowing $p = m-n$ and $q = m+n$. Any method that "reads the letters" must first acquire the very thing it was meant to produce. That is not a shortcut; it is a loop.

Control experiments confirm the frame from both sides. The trace channel — the mutual information between $N \bmod 3$ and the factor-sum residue modulo $3$ — measures $1.0000$ bits, exactly saturating: the visible channel is live and fully accounted for. And the depth of the $N$-node anticorrelates with the gap $q - p$, with correlation $-0.141$ between their logarithms: the tree does *feel* the balance of the factorisation, strongly enough to see in data — just not in any way reachable from $N$ alone.

## What it means

Let me put the three findings together, because their combination is the real result.

The address of $N$ in the Pythagorean tree splits cleanly into two layers. The **skeleton** — which coordinate is divisible by $3$ — is fully visible from $N$, and is exactly, provably, no more than the residue $N \bmod 3$ you started with. The **metric layer** — the letters, the depth, the composition of the path — is invisible: not statistically quiet, but provably not a function of $N$ modulo anything, at any position, even with all shallower positions given away.

Earlier work in this line had shown that the Pythagorean coordinates of a semiprime are *orthogonal* to its residues — that individual coordinate-level measurements carry no usable signal. The results here upgrade orthogonality to what one might call **adic strength**: not only are the coordinates uncorrelated with the residue structure, the node's entire *position* is sealed against every modulus simultaneously and at every depth. There is no finer scale at which the seal weakens.

For cryptography, this is a negative result of the healthy kind — the kind that maps the terrain. There is a recurring hope that the rigid, highly structured geometry of Pythagorean triples might be turned against factoring: the triples know the factorisation, after all; surely some of that knowledge escapes. The answer here is precise. Anything the tree tells you about $N$ that you can actually read is a restatement of $N \bmod 3$. Anything else in the tree requires you to already possess the factorisation to read it, or requires you to traverse a structure of size comparable to $N$ itself. A proposed attack through this geometry must land in one of those two pits: circularity, or exponential cost.

Negative results like this one earn their keep by closing doors that would otherwise absorb effort indefinitely. The Pythagorean tree is now closed at three strengths: the embedding of a semiprime into the tree is exact, its coordinates are orthogonal to residue structure, and its position is adically sealed. The geometry is gorgeous. It is also, for this purpose, a mirror — and what you see in it is your own reflection: $N \bmod 3$, which you knew before you looked.
