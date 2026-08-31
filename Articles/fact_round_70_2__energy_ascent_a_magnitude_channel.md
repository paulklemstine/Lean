# The Shape of a Number: How a Ruler Reads a Tree

## A tree with no dead ends

Everyone meets $3^2 + 4^2 = 5^2$ as a child and then forgets it. The forgetting is a shame, because the set of all such triples — pairs of whole numbers whose squares add to a third square, with no common factor to divide away — has one of the most beautiful structures in elementary mathematics. There are infinitely many of them: $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(20,21,29)$, $(7,24,25)$, and on forever. And they are not scattered. They form a **tree**.

Precisely one triple sits at the root: $(3,4,5)$. Every other primitive Pythagorean triple has exactly one parent, and every triple has exactly three children. The three children are produced by three fixed linear recipes. Writing a triple as a column vector $(a,b,c)$, the three recipes are the matrices

$$
A_1=\begin{pmatrix}1&-2&2\\ 2&-1&2\\ 2&-2&3\end{pmatrix},\qquad
A_2=\begin{pmatrix}1&2&2\\ 2&1&2\\ 2&2&3\end{pmatrix},\qquad
A_3=\begin{pmatrix}-1&2&2\\ -2&1&2\\ -2&2&3\end{pmatrix}.
$$

Apply $A_2$ to $(3,4,5)$ and you get $(21,20,29)$; apply $A_1$ and you get $(5,12,13)$; apply $A_3$ and you get $(15,8,17)$. Keep going and you sweep out, exactly once each, every primitive Pythagorean triple in existence. This is the classical **Barning–Hall tree**, rediscovered and popularised by Berggren.

Because the tree is infinite, ternary, and complete, each triple carries an address: the finite word over the alphabet $\{1,2,3\}$ that spells out the sequence of matrices you applied to reach it from the root. The triple $(119,120,169)$ has address $22$; the triple $(7,24,25)$ has address $11$. The **branch letter** of a triple is the last letter of its address — the identity of the very last matrix that produced it.

Here is the question this article is about. You are handed a large primitive triple, say
$$(752604,\ 1004653,\ 1255285),$$
with no address attached. Can you tell which matrix made it? And what kind of information about the triple do you need in order to tell?

## Two kinds of information

There are, broadly, two things you can know about a whole number.

You can know its **arithmetic**: its residues. What is it modulo $3$? Modulo $16$? Modulo $10^9+7$? This is the language of number theory proper — congruences, quadratic reciprocity, the entire modular machine.

Or you can know its **position**: its size, its ratio to other numbers, where it sits on the real line. This is the language of analysis and of measurement — logarithms, approximations, inequalities.

Most facts about integers mix the two. Some are purely arithmetic: whether $n$ is even is a residue fact and nothing else. Some are purely positional: whether $n$ exceeds $10^6$ is a magnitude fact and nothing else.

The branch letter of a Pythagorean triple looks, on first sight, arithmetic. It is defined by matrix algebra over the integers; the natural guess is that it depends on some congruence, and that with enough effort one could compute it from residues. The main discovery reported here is that this guess is exactly, completely, provably backwards.

**The branch letter is invisible to arithmetic and transparent to position.**

## The letter is a ratio band

Look at the legs of a triple and form their ratio $a/b$. That is a positional quantity: it doesn't care about divisibility, only about relative size. Now compare it to two thresholds, $3/4$ and $4/3$.

> **Theorem (Band = Letter).** Let $(a,b,c)$ be a primitive Pythagorean triple with positive entries other than the root. Then the last matrix applied to produce it is determined by which of three bands the ratio $a/b$ lies in:
> - if $4a < 3b$, i.e. $a/b < 3/4$, the last matrix was $A_1$;
> - if $3b \le 4a$ and $3a \le 4b$, i.e. $3/4 < a/b < 4/3$, the last matrix was $A_2$;
> - if $4b < 3a$, i.e. $a/b > 4/3$, the last matrix was $A_3$.
>
> Conversely, applying $A_i$ to any Pythagorean triple with positive entries always produces a child whose ratio lies in band $i$. No exceptions, at any depth.

Try it. $(5,12,13)$: ratio $5/12 \approx 0.42 < 3/4$, band one, and indeed $A_1(3,4,5) = (5,12,13)$. $(21,20,29)$: ratio $1.05$, squarely between $3/4$ and $4/3$, band two, and indeed $A_2(3,4,5) = (21,20,29)$. $(15,8,17)$: ratio $1.875 > 4/3$, band three, and indeed $A_3(3,4,5) = (15,8,17)$.

The proof is a small piece of algebra, and it is worth seeing because it explains *why* two thresholds as odd-looking as $3/4$ and $4/3$ appear. Undoing $A_2$ means applying its inverse, and the three components of the resulting parent are $a+2b-2c$, $2a+b-2c$ and $-2a-2b+3c$. A triple is a legitimate parent exactly when all three of these are positive. So the condition "the parent under $A_2$ is legitimate" is the pair of inequalities $2c < a+2b$ and $2c < 2a+b$. These look like they involve the hypotenuse. But they don't, really: given $a^2+b^2=c^2$ with all entries positive, one can square away the $c$. From $2c < a+2b$ and $4c^2 = 4a^2+4b^2$ one gets $4a^2+4b^2 < (a+2b)^2 = a^2+4ab+4b^2$, i.e. $3a^2 < 4ab$, i.e. $3a<4b$. And the implication runs the other way too, because $a+2b$ and $2c$ are both positive so squaring is reversible. The hypotenuse cancels out completely. Two apparently three-variable conditions collapse into two two-variable ratio comparisons, and the constants $3/4$ and $4/3$ are simply what $\sqrt{4}$ and $\sqrt{9}$ leave behind.

One immediate corollary makes the positional character unmistakable: the letter depends *only* on the ratio. If two pairs of legs are proportional — $ab' = a'b$ — they carry the same letter, whatever their sizes. The letter is a function on the projective line, not on the integers.

And the whole address, not just the last letter, is positional. Read the band of your triple, apply the corresponding inverse matrix, read the band of the result, apply the corresponding inverse, and repeat. This decoder uses nothing but three linear comparisons per step.

> **Theorem (Full Word Decoding).** For every word $w$ over $\{1,2,3\}$ and every Pythagorean triple $T$ with positive entries, reading $|w|$ letters off the triple obtained by applying $w$ to $T$ — by iterating the band-selected descent — returns exactly $w$.

So the address of a triple is not merely detectable from ratios; it *is* a ratio computation, all the way down.

## Arithmetic is blind

Now the negative half, which is where the surprise lives. One might hope that even if ratios work, residues work too — that there is some clever modulus $M$ and some function $f$ with
$$\text{letter}(a,b,c) = f(a \bmod M,\ b \bmod M,\ c \bmod M).$$
There is not, for any $M$ whatsoever.

> **Theorem (Residue Seal).** For every modulus $M \ge 1$ there exist two primitive Pythagorean triples with positive entries, congruent to each other componentwise modulo $M$, whose branch letters differ. Consequently the branch letter is not a function of the residues of the entries modulo $M$, for any $M$.

The witness is disarmingly simple. The root is $(3,4,5)$, whose ratio $3/4$ lies on the closed middle band (neither $4a<3b$ nor $4b<3a$ holds, since $4\cdot 3 = 3\cdot 4$), so the band rule assigns it the middle letter. Take the classical family
$$(m^2-1,\ 2m,\ m^2+1),$$
which is Pythagorean for every $m$ and primitive whenever $m$ is even — a fact certified by the one-line identity $k\cdot(2m) - (m^2-1) = 1$ when $m = 2k$. Choose $m = 2 + 2M$. Then modulo $M$ we have $m \equiv 2$, so
$$m^2 - 1 \equiv 3, \qquad 2m \equiv 4, \qquad m^2+1 \equiv 5 \pmod M.$$
The triple is congruent to $(3,4,5)$ in every coordinate. But its ratio is $(m^2-1)/(2m)$, which for $m\ge 4$ is comfortably larger than $4/3$: letter $3$, not letter $2$.

Two primitive triples, identical to every residue test modulo $M$, different letters. And this is not a small-number accident: taking $m = 2 + 2Mt$ instead, one gets such a witness with hypotenuse as large as desired. The seal holds at every modulus and at every height in the tree.

So we have a clean dichotomy. The letter is a function of position; it is a function of no residue datum at all. Two of the most natural ways of looking at an integer, and one sees everything while the other sees nothing.

## A sensor built out of Fermat's method

The dichotomy suggests something practical. If the letter is positional, then *any* instrument that measures position should be able to read it. Here is one, borrowed from an old factoring idea.

Fermat's method of factorisation looks for a way of writing $N = pq$ as a difference of squares. It scans upward from $\lceil \sqrt N\rceil$, testing whether $x^2 - N$ is a perfect square. It succeeds at
$$x = \frac{p+q}{2},$$
so the practical question is: how far above $\sqrt{N}$ is that? Define the **Fermat offset**
$$s(p,q) = \frac{p+q}{2} - \sqrt{pq}.$$
By the arithmetic–geometric mean inequality it is never negative. How large is it? The identity
$$\left(\frac{p+q}{2} - \sqrt{pq}\right)\left(\frac{p+q}{2}+\sqrt{pq}\right) = \left(\frac{q-p}{2}\right)^2$$
pins it between two explicit expressions:

> **Theorem (Offset bounds).** For $p,q>0$,
> $$\frac{(q-p)^2}{4(p+q)} \ \le\ s(p,q) \ \le\ \frac{(q-p)^2}{8\sqrt{pq}}.$$

Both bounds say the same thing to within a constant: the offset is the *squared imbalance* divided by the *scale*. A balanced factorisation is found almost immediately; a lopsided one is far away.

Two further facts make this a genuine positional instrument. First, $s$ is homogeneous of degree one: $s(\lambda p, \lambda q) = \lambda\, s(p,q)$. So the *relative* offset $s(p,q)/\sqrt{pq}$ depends only on the ratio $q/p$ and on nothing else — the offset does not know what $p$ and $q$ are, only how out of balance they are. Second, if you scan a fixed window of width $W$ above $\sqrt N$, you get a bit: **hit** if $s(p,q)\le W$, **miss** otherwise. That bit is a coarse, noisy, entirely magnitude-based measurement of the ratio.

Now fuse the two halves. The bit measures the ratio; the ratio is the letter; therefore the bit sees the letter.

> **Theorem (Mechanism).** Let $0 < p \le q$ be integers with $q \ge 112\,W$. If $s(p,q)\le W$, then $3q \le 4p$ and $3p \le 4q$ — the pair sits in the middle band.
>
> **Corollary (The channel).** Let $(a,b,c)$ be a primitive Pythagorean triple with $0 < a \le b$ and $b \ge 112\,W$. If the leg pair $(a,b)$ is a window hit, then its branch letter is the middle one, and its parent in the tree is obtained by inverting $A_2$.

The proof is three lines of inequality chasing. A hit means $s\le W$; the lower offset bound turns this into $(q-p)^2 \le 4W(p+q)$. If the pair were *outside* the middle band, say $4p<3q$, then the gap $q-p$ would exceed $q/4$ and the sum $p+q$ would be at most $7q/4$, giving $q^2/16 < 7Wq$, i.e. $q < 112 W$ — contradicting the scale assumption. That is all. The constant $112$ falls straight out of $16\times 7$.

And it is essentially the best constant: the primitive triple $(752604, 1004653, 1255285)$ with window $W = 9133$ is a bona fide hit (its offset is about $9085$), sits at scale $q/W = 110.0$, and its letter is $1$, not the middle one. So no threshold at or below $110\,W$ can work, and the true optimum is trapped between $110$ and $112$.

This is the punchline. A crude yes/no measurement — "did a fixed-width scan starting at $\sqrt{N}$ find the factorisation?" — provably determines a combinatorial coordinate on an infinite tree of number-theoretic objects. The sensor never touches a residue. It cannot: residues are sealed.

## How much is the channel worth?

Not everything. Honesty here is essential, and the mathematics is precise about the limits.

The channel is **not vacuous**. Start at the root and apply the middle matrix over and over: $(3,4,5) \to (21,20,29)\to(119,120,169)\to(697,696,985)\to(4059,4060,5741)\to\cdots$. Every member of this spine has legs differing by exactly $1$ — hence automatically coprime, hence primitive — and the offsets shrink fast: $0.036,\ 0.0061,\ 0.0010,\ 0.00018,\ 0.000031,\dots$. Every one of these is a hit even for the smallest possible window $W=1$, and their hypotenuses grow geometrically. So there are hits at every scale, and each time the channel fires it reads the letter correctly.

The channel is also **strictly one-way**. A hit forces the middle letter; the middle letter does *not* force a hit. Consider
$$(20k^2+4k,\ 21k^2+10k+1,\ 29k^2+10k+1),$$
a Pythagorean family (check: it is the Euclid parametrisation with $m = 5k+1$, $n = 2k$) that is primitive whenever $k$ is even. Its leg ratio tends to $20/21$, so it sits inside the middle band for all $k\ge 1$ — letter $2$ every time. But its leg gap $k^2 + 6k + 1$ grows quadratically, so its offset grows without bound: $0.375,\ 0.590,\ 1.167,\ 2.907,\ 8.728$ for $k = 2,4,8,16,32$. Any fixed window eventually loses sight of this family forever.

Put the two families side by side and you get the exact information content of the channel:

> **Theorem (Strict two-sided noise).** At every scale the middle band contains both a window hit and a window miss. Hence the window bit and the branch letter determine one another in exactly one direction.

That asymmetry has a clean statistical consequence, provable without any probability model at all. Take any finite collection $F$ of primitive triples above the scale threshold, containing at least one hit and at least one triple outside the middle band. Write $\#L$ for the number with the middle letter, $\#H$ for the number of hits, and $\#(H\wedge L)$ for the number that are both. Then
$$\#L \cdot \#H \ <\ \#(H\wedge L)\cdot |F|,$$
which is the division-free way of saying $P(\text{letter}=2\mid \text{hit}) > P(\text{letter}=2)$. Conditioning on a hit strictly raises the letter frequency: the empirical mutual information between the magnitude channel and the tree letter is strictly positive, on every admissible sample, always. And by the noisy family it never reaches the letter's full entropy. Bounded above, bounded below, and both bounds are theorems rather than estimates.

Enumerating the tree confirms the picture numerically. Down to depth twelve — some $797{,}000$ primitive triples — the ratio band names the last generator in every single case. Restricted to the regime $q \ge 112W$, the hit rate by letter reads $0.000$, $0.021$, $0.000$ at $W=1$; $0.000$, $0.058$, $0.000$ at $W=16$; $0.000$, $0.378$, $0.000$ at $W=4096$. The two zeros in every row are the mechanism theorem. The middle entry climbing towards but never reaching $1$ is the ceiling.

## Why it matters

Three things, I think.

**First, a clean example of a structural dichotomy.** We are used to results saying that some object is hard to compute, or easy. Rarer and more informative are results saying *which language* an object speaks. Here the branch letter of a Pythagorean triple is fully determined by a single real-valued comparison and fully undetermined by the entire tower of congruences. That is a sharp statement about where the information lives, and it was not obvious in advance; the natural bet, given that the tree is built from integer matrices, would have gone the other way.

**Second, a bridge.** Fermat's difference-of-squares scan and the Barning–Hall tree are objects from different rooms of number theory. The mechanism theorem connects them with a single inequality and an explicit, near-optimal constant. Bridges of this kind are how one part of mathematics learns to use another's instruments.

**Third, an honest accounting of a weak signal.** A recurring hazard in exploratory mathematics is to detect a correlation, declare a mechanism, and stop. Here the correlation came first, and then the mechanism was isolated exactly: the correlation is not an artifact of scale, or of sampling strata, or of a hidden threshold variable, because the underlying implication holds deterministically for every triple above an explicit scale, and the residual noise has an explicit witness family. When you can name both why a signal exists and why it cannot be improved, you understand it.

There is a slogan for all this, and it is worth keeping: **the tree letters are sealed against arithmetic and open to position.** A ruler can read what a congruence cannot.
