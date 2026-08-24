# Two Clicks, Then Silence: How Much a Pythagorean Triple Tells You About Its Own Family Tree

Every right triangle with whole-number sides has a pedigree. Not a metaphorical one — an actual, unique, computable ancestry, a path down a branching tree that begins at the $3,4,5$ triangle and reaches every other primitive Pythagorean triple exactly once. The path is a word in three letters, $A$, $B$, and $C$: the triple's genealogical barcode.

This article is about a strange and precise question. Suppose someone hands you only the *odd leg* of a triple — the single number $N$, say $N = 105$ — and asks: what were the last few letters of its pedigree? How much of the family tree can you reconstruct from that one number, and worse, how much can you reconstruct from just the last few binary digits of that number?

The answer turns out to be startlingly sharp. **You get exactly two letters. Then the tree goes silent — and it goes silent not because the problem is hard, but because there is provably nothing there to hear.**

---

## The tree of triangles

A *primitive Pythagorean triple* is a triple of positive integers $(a, b, c)$ with $a^2 + b^2 = c^2$ and no common factor: $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, and so on forever. Euclid knew how to make them all. Pick two coprime integers $m > n > 0$ of opposite parity and set

$$a = m^2 - n^2, \qquad b = 2mn, \qquad c = m^2 + n^2 .$$

Every primitive triple arises this way from exactly one such *Euclid pair* $(m,n)$. So the triples are really the pairs, and $(3,4,5)$ is the pair $(2,1)$.

Now comes the tree. Starting from the root $(2,1)$, define three moves:

$$A : (m,n) \mapsto (m+n,\, 2n), \qquad B : (m,n) \mapsto (2m,\, m-n), \qquad C : (m,n) \mapsto (2m,\, m+n).$$

Apply them in any order, as many times as you like. The remarkable fact — the reason this tree is worth studying — is that **every** Euclid pair is reached from the root by **exactly one** sequence of moves. The tree is a perfect ternary catalogue of all right triangles with integer sides. Each triple therefore carries a unique word over $\{A,B,C\}$: its *address*. The pair $(13,8)$, whose triple is $(105, 208, 233)$, has address $ABAAA$. The pair $(53,52)$, whose triple is $(105, 5512, 5513)$, has address $CACAA$.

Note that those two triangles have the *same odd leg*, $105$. They are cousins in a very specific sense: $105 = 1 \times 105$ and $105 = 5 \times 21$, and each way of splitting $N$ into two coprime factors corresponds to a different node of the tree. The odd leg is $N = m^2 - n^2 = (m-n)(m+n)$, so **choosing a node with odd leg $N$ is exactly the same as choosing a coprime factorisation of $N$.** Hold that thought — it is the whole point.

---

## Reading the address backwards

It is convenient to read an address from the *end*: position $0$ is the last letter, position $1$ the one before it, and so on. Position $t$ tells you which of the three moves was made $t$ generations before the node in question — it is the tree's most recent history first, like reading the youngest generation of a family tree upward.

Here is the first surprise. Take any node deep enough to have three letters, and let $N$ be its odd leg. Then:

> **The letter at position $0$ is $A$ if and only if $N \equiv 1 \pmod 4$.**

That is one clean bit, read straight off $N$ modulo $4$. And there is a second:

> **The letter at position $1$ is $A$ if and only if $N \bmod 8 \in \{1, 3\}$.**

Put them together and you get a perfect dictionary, an honest bijection between the four odd residue classes modulo $8$ and the four possible patterns of "is it an $A$?" at the two youngest positions:

| $N \bmod 8$ | position $0$ | position $1$ |
|---|---|---|
| $1$ | $A$ | $A$ |
| $3$ | not $A$ | $A$ |
| $5$ | $A$ | not $A$ |
| $7$ | not $A$ | not $A$ |

All four combinations really occur — the pairs $(17,16)$, $(27,2)$, $(26,3)$ and $(28,3)$ realise them — so the correspondence is a genuine two-way dictionary. Three bits of $N$ buy you two bits of pedigree.

The obvious next question is: what does $N$ modulo $16$ buy you? Modulo $32$? Modulo $2^{100}$?

**Nothing. Not one further bit. Ever.**

---

## Why the dial has exactly two clicks

To see why, you need the machine underneath. Move from the Euclid coordinates $(m,n)$ to what one might call the *odd-pair coordinates*: $p = m - n$ and $q = m + n$. Both are odd, they are coprime, and the odd leg is simply $N = pq$. Introduce

$$U = p + q = 2m, \qquad V = q - p = 2n .$$

Now watch what a single step *up* the tree — from a node to its parent — does to these two numbers. There are only two behaviours, and they are beautifully rigid:

- An $A$-step **halves $V$**, and it is the move that happened if and only if $U$ is exactly twice an odd number, i.e. $v_2(U) = 1$, where $v_2$ denotes the exponent of $2$.
- A $B$- or $C$-step **halves $U$**, and one of those is what happened if and only if $v_2(U) \geq 2$.

The consequence writes itself. Every non-$A$ step burns exactly one factor of two out of $U$. So if you start at a node with $v_2(U) = u_0 \geq 2$, you are forced through exactly $u_0 - 1$ non-$A$ letters before the valuation drops to $1$ and an $A$ becomes possible. This is the **first-$A$ law**:

> **If $n$ is odd, the address (read from the leaf) begins with exactly $v_2(m)$ letters that are not $A$, and the letter at position $v_2(m) = v_2(U) - 1$ is $A$.**

Its mirror image is the **$A$-run law**:

> **If $n$ is even, the address begins with exactly $v_2(n)$ letters $A$, and the letter at position $v_2(n)$ is not $A$.**

Since a valid Euclid pair has $m$ and $n$ of opposite parity, exactly one of the two laws applies to each node, and together they determine the entire leading run of the address from a single 2-adic valuation. Here, for the node $(41,14)$ with address $ABBABA$, is the countdown in action, read from the leaf upward:

| letter | $v_2(U)$ | $v_2(V)$ |
|---|---|---|
| $A$ | $1$ | $2$ |
| $B$ | $2$ | $1$ |
| $A$ | $1$ | $2$ |
| $B$ | $3$ | $1$ |
| $B$ | $2$ | $1$ |
| $A$ | $1$ | $2$ |

Every $B$ knocks $v_2(U)$ down by one; the $A$s appear precisely when the countdown hits $1$.

So the address, near the leaf, is governed by the quantity $u_0 = v_2(U)$. And now the crucial obstruction: **the residues of $N$ modulo powers of two can only see $u_0$ through the coarse trichotomy $u_0 = 1$, $u_0 = 2$, $u_0 \geq 3$.** Beyond that, the reconstruction of $N$ from the descent data is *nonlinear* — $N$ is a product, $N = pq$, and forming that product scrambles the higher bits irreversibly. Two clicks of the dial, and then the mechanism disconnects.

That is the heuristic. What makes this a theorem rather than a feeling is that the disconnection can be exhibited by hand.

---

## The twins that break every classifier

Consider, for a parameter $y$ not divisible by $3$, the two nodes

$$X(y) = (3y+5,\; 3y+4), \qquad Y(y) = (y+3,\; y).$$

Both are legitimate Euclid pairs. Compute their odd legs: $(3y+5)^2 - (3y+4)^2 = 6y+9$, and $(y+3)^2 - y^2 = 6y+9$. **Identical.** They are the two coprime factorisations $N = 1 \cdot N$ and $N = 3 \cdot \tfrac{N}{3}$ of the same odd number $N = 6y + 9$.

Since they share an odd leg, the mod-$8$ dictionary forces their letters at positions $0$ and $1$ to agree — no surprise there. What is decisive is that their letters at position $2$ **always disagree** in $A$-ness. Always. For every admissible $y$. The smallest instance is $N = 33$, split between the node $(7,4)$ with address $BAA$ and the node $(17,16)$ with address $AAAA$: same odd leg, matching youngest two letters, opposite third letters.

This single family kills every conceivable classifier at once:

> **No function of the odd leg — not of $N$ modulo anything, but of the entire integer $N$ — determines whether the letter at position $2$ is $A$.**

And because the numbers $6y+9$ sweep out *every* odd residue class modulo *every* power of two (the reason is simply that $3$ is invertible modulo $2^k$), the failure is uniform across the whole 2-adic filtration:

> **Every 2-adic cell $\{N \equiv r \bmod 2^k\}$, for every $k$ and every odd $r$, contains two nodes with the same odd leg, the same letters at positions $0$ and $1$, and opposite letters at position $2$.**

In statistical language: conditioning on the residue of $N$ to arbitrary 2-adic depth *never* makes the third letter deterministic. The conditional distribution never collapses. Death at position $2$ is not an artefact of a coarse statistic; it is structural.

---

## Sealed at every position, forever

Position $2$ is only the first casualty. The same idea, tuned, kills all the rest. For each target position $t = s+2$, put $W = 10 \cdot 2^{s} - 3$ (an odd number) and consider

$$X_s = \big(2^{t} W + 1,\; 2^{t} W\big), \qquad Y_s = \big(12 \cdot 2^{s} - 1,\; 2^{t+1}\big).$$

Both are valid nodes; both have odd leg $N = 80 \cdot 4^{s} - 24 \cdot 2^{s} + 1$, giving the sequence $57, 273, 1185, 4929, 20097, 81153, \ldots$. The second coordinate of $X_s$ has 2-adic valuation exactly $t$; that of $Y_s$ has valuation $t+1$. By the $A$-run law, both addresses are all-$A$ below position $t$ — and at position $t$, $X_s$ has left its $A$-run while $Y_s$ has not. Same number, agreeing prefixes, opposite letters at exactly the target position. Hence:

> **For every $t \geq 2$, no function of the odd leg computes the $A$-ness of the letter at position $t$; a fortiori, no residue $N \bmod 2^k$ does, at any depth $k$.**

Combined with the two visible clicks, this is the law in its exact form: the 2-adic reading of a Price address has **exactly two clicks and no more.**

One might still hope for a lucky escape: maybe a classifier fails only on sporadic conspiracies and is right for all large $N$? No. A two-parameter refinement of the same construction produces, for each position $t$, *infinitely many* distinct odd legs each carrying a splitting pair, so no classifier can be correct even eventually.

Or one might hope that a little extra side information cracks it. The most natural extra datum is the node's **depth** — how far it sits from the root — which genuinely is not a function of $N$. Does knowing $(N, \text{depth})$ unlock the address? Again no, and the proof is a small piece of magic: instead of specifying the two nodes by their coordinates, specify them *by their addresses*, choosing words of equal length so the depths match by construction. The words

$$A^{\,t-1} B A^{\,t} \qquad\text{and}\qquad C A^{\,t-3} C A^{\,t+1}$$

both have length $2t$. Evaluating them from the root gives the nodes $\big(2^{t+1}+1,\, 2^{t}\big)$ and $(M+1, M)$ with $M = 2^{t+1}(3 \cdot 2^{t-2}+1)$, and these turn out to have the *same* odd leg $3 \cdot 2^{2t} + 2^{t+2} + 1$ — while their second coordinates have valuations exactly $t$ and $t+1$, so they split at position $t$. Same odd leg, same depth, opposite letters:

> **No function of the pair (odd leg, depth) computes the $A$-ness of the letter at any position $t \geq 2$.**

The smallest members of this family are charming: at $t = 3$, the odd leg $225$ carries two nodes both at depth $6$; at $t=4$, the odd leg $833$ carries $(33,16)$ and $(417,416)$, both at depth $8$.

---

## The one thing the residue cannot be told

Why should anyone care that a residue dial has exactly two clicks?

Because of what the address *is*. Recall: a node with odd leg $N$ is precisely a coprime factorisation $N = pq$. If the last few letters of the address were computable from cheap arithmetic data about $N$ — its low-order bits, say — then that cheap data would be telling you something about *which factorisation you are looking at*, and by extension about the multiplicative structure of $N$. Long strings of address letters, cheaply obtained, would amount to an "ascent route" from additive residue information to multiplicative information.

The law says the route is closed at the second step. And notice exactly *where* the wall stands. The rule separating $B$ from $C$ is not a congruence at all: in the odd-pair coordinates,

> **A node's letter is $B$ precisely when $N \equiv 3 \pmod 4$ and $q < 3p$** —

one congruence bit, plus a pure *size comparison* between the two factors. A size comparison is invisible to any residue: rescaling which factor is larger does not change $N$ modulo anything. So the $B$-versus-$C$ decision is, by its very form, factor-blind to arithmetic-progression data. (It also explains a small empirical puzzle, the relative rarity of $B$ in certain samples: $B$ requires both the congruence and the inequality, so its probability is the probability of $q < 3p$ cut in half by the congruence.)

There is a satisfying information-theoretic epilogue. Take all $19{,}683$ nodes at distance $9$ from the root and measure, in bits, how much the residue $N \bmod 2^k$ tells you about the pair of youngest letters:

| modulus | $2$ | $4$ | $8$ | $16$ | $32$ | $64$ | $128$ |
|---|---|---|---|---|---|---|---|
| bits | $0.000$ | $0.918$ | $1.837$ | $1.837$ | $1.837$ | $1.837$ | $1.837$ |

The dial rises for two clicks and then flatlines *exactly* at modulus $8$ — and it flatlines at the same value even if you ask about the first *three* letters, because the third letter contributes nothing that the residue can see. The saturation value, $2\log_2 3 - \tfrac{4}{3} \approx 1.837$ bits, is simply twice the entropy of a $1/3$-biased bit: the two visible letters, and nothing else.

---

## A map with two sealed continents

This result completes a small map. There is an older, more famous ternary tree of Pythagorean triples, Berggren's tree, and the analogous question there is about $3$-adic rather than $2$-adic information. For that tree the answer is even more brutal: it is sealed from position $0$ — the very first letter is already invisible to congruence data, and to every magnitude probe tried alongside it.

So the two classical trees of right triangles now stand characterised in the same language. Berggren's tree: zero clicks. Price's tree: exactly two clicks, then structurally sealed at every subsequent position, against the odd leg itself, against every 2-adic residue, and against the depth thrown in for free.

Both trees, in other words, have cheap descriptions that are *factor-blind residue dials*: little windows that show you a fixed, tiny number of bits and then close. The pleasure of the result is that "and then close" has been made into a theorem rather than a report of failed attempts. We do not merely lack a method for reading position $2$; we know that no method exists, because for every candidate rule there is a pair of triangles that share a number, share a history, share a depth, and disagree precisely where the rule must decide.

Somewhere out there, $(33, 16)$ and $(417, 416)$ — two right triangles with the same odd leg $833$, born eight generations from $(3,4,5)$, indistinguishable to every arithmetic probe of their shared number — are quietly, permanently, disagreeing about their fourth-to-last ancestor. That disagreement is the whole theorem.
