# The Tree That Only Whispers Its First Few Letters

## A story about Pythagorean triples, magnifying glasses, and the strange arithmetic of *how much you can see*

### Every right triangle has an address

Start with the oldest theorem in the book: $3^2 + 4^2 = 5^2$. Then $5^2 + 12^2 = 13^2$. Then $8^2 + 15^2 = 17^2$. These are *primitive Pythagorean triples* — whole-number right triangles whose three sides share no common factor.

There are infinitely many of them, and they are not scattered at random. In 1934 the Dutch mathematician B. Berggren discovered something startling: **all of them fit into a single infinite ternary tree**, with $(3,4,5)$ at the root, and each triple having exactly three children. Every primitive triple in existence appears exactly once, at exactly one place, reachable by exactly one path down from $(3,4,5)$.

That means every right triangle with whole-number sides has an *address*: a finite string of letters, say $A$, $B$, $C$, telling you which turn to take at each fork. The triple $(3,4,5)$ has the empty address. Its three children have addresses $A$, $B$, $C$. Their children have addresses of length two, and so on. The tree is a perfect ternary filing cabinet for a piece of ancient number theory.

The cleanest way to see all this is to change coordinates. Every primitive triple can be written as
$$(m^2 - n^2,\; 2mn,\; m^2 + n^2)$$
for a unique pair of whole numbers $m > n > 0$ with no common factor and opposite parity (one even, one odd). Call such a pair **admissible**. In these coordinates the Berggren tree becomes something beautifully simple. The root is $(m,n)=(2,1)$, and the three children of a state $(m,n)$ are
$$A:(m,n)\mapsto(2m-n,\,m),\qquad B:(m,n)\mapsto(2m+n,\,m),\qquad C:(m,n)\mapsto(m+2n,\,n).$$

Going *down* the tree is easy. The interesting direction is *up*. Given a triple, how do you find its address?

### The address is a decimal expansion in disguise

Here is the first surprise. To climb one step toward the root, you don't need to know $m$ and $n$ at all. You only need to know their **ratio** $r = m/n$, and where it sits relative to two numbers, $2$ and $3$:

- if $r < 2$, the last letter was $A$, and the parent has ratio $\dfrac{1}{2-r}$;
- if $2 < r < 3$, the last letter was $B$, and the parent has ratio $\dfrac{1}{r-2}$;
- if $r > 3$, the last letter was $C$, and the parent has ratio $r - 2$.

(The ratio of an admissible pair is never exactly $2$ except at the root, and never exactly $3$, or any odd integer, at all — parity and coprimality forbid it. The boundaries are genuinely never hit.)

Read that list again and you may recognize an old friend. Chop off an integer part; if what's left is small, flip it over and continue. That is exactly the rhythm of a **continued fraction**, or equivalently of the *Gauss map* that generates the digits of a real number's continued-fraction expansion. The address of a Pythagorean triple is nothing other than a digit expansion of the ratio $m/n$ in a slightly exotic base.

This reframing turns a question about triangles into a question about **precision**. Digits of an expansion are exactly the thing that requires increasing accuracy to read: the first digit of $\pi$ needs one decimal place, the fiftieth needs fifty.

### The sensor

Now we can ask the question this article is really about.

Suppose you are handed a huge primitive Pythagorean triple — thousands of digits — and you would like to know its address in the tree without doing the full climb. (Climbing costs about as much work as running the Euclidean algorithm on the numbers, which is exactly the kind of work you were hoping to avoid.) You have a cheap instrument: a **magnitude sensor** with a fixed budget of $W$ binary places. Feed it a state $(m,n)$ and it returns
$$P_W(m,n) \;=\; \left\lfloor 2^{W}\cdot \frac{m}{n} \right\rfloor,$$
the ratio truncated to $W$ bits after the point. A magnifying glass of fixed power. Crucially, $W$ does *not* grow with the size of the input or with how deep in the tree the state sits.

How many letters of the address can this instrument read?

The honest experimental answer, obtained by measuring how much information the sensor's reading shares with each successive letter of the address, is a striking decay curve. Measured in bits (mutual information), letter by letter:
$$0.184,\; 0.143,\; 0.094,\; 0.078,\; 0.054,\; 0.040,\; 0.032,\; 0.019$$
— roughly a halving every two levels. But raw correlation overstates the case, because the letters are themselves correlated with each other: knowing letters $1$ and $2$ already tells you a lot about letter $3$, so a sensor that reads only the early letters will *appear* to know something about the late ones. Controlling for that — asking what the sensor knows about letter $t$ *given* everything about letters $1$ through $t-1$ — the picture sharpens dramatically. The second letter is read loud and clear. The third is marginal. The fourth is on the edge of noise. **The fifth is indistinguishable from nothing at all.**

So there is a channel, and it dies. The question is *why*, and *exactly where*. And here the answer is not statistical but a matter of theorem.

### What the sensor can see: the first letter, always

The first result is positive and pleasingly cheap. **One bit of precision suffices for the first letter.** Because the two branch boundaries are $2$ and $3$, and because the reading $\lfloor 2m/n\rfloor$ distinguishes $r<2$ (reading $\le 3$) from $2<r<3$ (reading $4$ or $5$) from $r>3$ (reading $\ge 6$), the first letter of the address is an *explicit function of one number*:

> **First-Letter Readability Theorem.** For every admissible pair, the first descent letter is determined by $P_1(m,n)=\lfloor 2m/n\rfloor$: it is $A$ if this is at most $3$, $B$ if it is $4$ or $5$, and $C$ otherwise.

The magnitude channel is real. It exists.

### What the sensor can see: the whole opening run

The second result is much better than one letter — and it explains the shape of the decay curve.

Look again at the three branches. Two of them, $A$ and $B$, *invert* the ratio: $r\mapsto 1/(2-r)$ and $r\mapsto 1/(r-2)$. Inversion near a boundary is violently expanding: a tiny difference in $r$ becomes a large difference after flipping. The third branch, $C$, merely *translates*: $r\mapsto r-2$. Translation is an isometry. It doesn't magnify anything, and it doesn't destroy any precision.

That asymmetry is the whole story. As long as the descent keeps taking $C$-steps, the sensor keeps up effortlessly — each $C$-step just shifts its reading down by exactly $4$ (in the one-bit scale). So:

> **Readable-Prefix Theorem.** For any admissible pair $(m,n)$, the address begins with a run of exactly
> $$L=\left\lfloor \frac{m-n}{2n}\right\rfloor$$
> consecutive $C$'s, followed by a letter that is not $C$. Moreover, *any* other admissible pair with the same one-bit reading $\lfloor 2m/n\rfloor$ has the identical first $L+1$ letters — the entire opening $C$-run **and** the inversion letter that ends it.

So the cheap sensor doesn't just read one letter. It reads the whole leading run — which can be arbitrarily long — plus one more. Depth itself is visible: the length $L$ is a single integer division of the magnitude data. And along the pure-$C$ spine of the tree, the sensor reads *arbitrarily many* letters correctly. For instance, the state $(2L+2,1)$ has an address beginning with $L$ consecutive $C$'s, and the one-bit reading pins every one of them.

This is not free, of course. Reading a run of length $L$ requires the sensor's *output* to be a number of size at least $4L$ — that is, about $\log_2 L$ output bits. Depth is visible, but only logarithmically cheaply.

### What the sensor can never see: anything past the first flip

Then comes the wall. And it is a wall, not a slope.

> **Depth-Null Theorem.** For every precision budget $W$ and every depth $k$, there exist two admissible pairs that
> 1. give the *same* reading $P_W$ — the sensor cannot tell them apart at all;
> 2. have *identical* addresses for the first $k+1$ letters, namely $C^k B$;
> 3. have *different* letters at position $k+2$.
>
> Consequently, for no budget $W$ and no depth $k$ is the letter at position $k+2$ a function of $P_W$. Furthermore, such colliding pairs exist with arbitrarily large denominators, so this is no small-numbers artefact.

The construction is disarmingly explicit. Pick a scale $q$ (a multiple of $6$, larger than $2^W$) and form the two states
$$s^{+}=\big((7+6k)q+1,\;3q\big),\qquad s^{-}=\big((7+6k)q-1,\;3q\big).$$
Their ratios are $\tfrac73 + 2k \pm \tfrac{1}{3q}$: they sit on either side of the number $\tfrac73+2k$, a hair's breadth apart. Since $2^W < q$, the gap between them is smaller than the sensor's resolution — and because $7/3$ is **not a dyadic rational** (it is not $a/2^b$ for any integers), no binary truncation ever falls between them. The sensor returns the identical value for both.

Now watch what happens as you climb. Both states take $k$ translation steps ($C$, $C$, …, $C$), which move the two ratios in lockstep, keeping their infinitesimal separation infinitesimal. Then both take the inversion step $B$. And inversion, applied to two numbers straddling $7/3$, blows the hairline gap wide open: the images land on *opposite sides of the cut point $3$*. One continues with $B$, the other with $C$. The information the sensor would have needed is a *fine* digit of the ratio — exactly what a fixed-precision instrument does not have.

Put the two theorems together and the reach of the magnitude channel is pinned exactly: **the entire opening $C$-run and the inversion letter that terminates it, and not one letter more.** In particular the threshold is sharp: the very first letter is always readable from a single bit, and the very second letter is already null for every conceivable budget.

Notice also what this says about the shape of the decay. It is not that *depth* defeats the sensor — the $C$-spine result shows arbitrary depth is fine. It is that *inversions* defeat it. Depth decay is really **inversion decay**: since a typical address contains inversions early, the observed channel dies at around depth $4$–$5$.

### "Just use a better ruler" — no

The natural objection: the culprit was $7/3$, which is invisible in base $2$ but obvious in base $3$. Surely a ternary sensor sees further?

It does not, and the reason is prettier than the original argument.

> **Universal Null Theorem.** Let $a,b$ be any positive integers, and consider the rescaled sensor $G_{a/b}(m,n)=\big\lfloor \tfrac{a}{b}\cdot\tfrac{m}{n}\big\rfloor$ — *any* monotone rational rescaling of the magnitude followed by truncation. For every such sensor and every depth $k$, there are two admissible pairs with the same reading, the same first $k+1$ letters, and different letters at position $k+2$.

The trick is to use a boundary that is *attained*. Consider the state $\big(4k+5,\,2\big)$, whose ratio is exactly $\tfrac52 + 2k$; after $k$ translations and one inversion it lands precisely on the root $(2,1)$. Next to it, place the state $\big((4k+5)u+1,\,2u\big)$ for a large even $u$: its ratio is a whisker *above* the boundary, and after the same $k$ translations and one inversion it slips below $2$ — its next letter is $A$, while the boundary state's is $B$.

Because the floor function is right-continuous, *any* truncation sensor gives a boundary point and its immediate right neighbours the same reading. There is no scale, no base, no rational magnification that separates a number from the numbers just above it. Refining the ruler is structurally the wrong move.

### The counting argument: capacity, not adversarial bad luck

One might still suspect the counterexamples are contrived — carefully engineered pathologies you'd never meet in the wild. A third, entirely independent argument closes that door: the obstruction is a matter of **capacity**.

Every finite word in $\{A,B,C\}$ is realized by some admissible state. Build it directly: start at $(2,1)$ and apply the three child maps in reverse order of the desired address. The descent then reads the word back letter by letter, exactly. So depth $k$ genuinely carries $3^k$ distinct behaviours — the tree is not secretly thin.

Now restrict to addresses made only of $A$'s and $B$'s. Every such state has ratio strictly between $1$ and $3$, so its $W$-bit reading lies in a window of only $2\cdot 2^{W}$ possible values. But there are $2^{k}$ such addresses of length $k$. As soon as
$$2\cdot 2^{W} < 2^{k},$$
i.e. as soon as the depth exceeds the budget by two bits, the pigeonhole principle forces two states with *different* addresses somewhere in the first $k$ letters to produce *identical* readings.

> **Capacity Theorem.** If $2\cdot 2^{W} < 2^{k}$, then the $W$-bit magnitude sensor confuses two admissible states whose addresses already differ at some position below $k$.

This is an information-theoretic bound with no adversary in it: a bounded-output channel cannot carry unbounded entropy. It matches the experimental decay curve in the only way a theorem can match an experiment — by explaining why the curve had to fall.

### Why anyone should care: factoring, and the price of a shortcut

The reason this question was asked at all is cryptographic. There is a long tradition of hoping that some geometric or combinatorial structure — the Pythagorean tree among them — gives a shortcut to **integer factorization**, the problem whose difficulty underwrites much of public-key cryptography. A number $N$ can be attached to a state in the tree, and the state's address encodes, in Gauss-map digits, information about the arithmetic of $N$. If the address were cheap to read, structure would leak.

The three results above, taken together, close that hope in the only satisfying way — quantitatively, in three independent registers.

1. **The channel exists.** A fixed-precision, $N$-computable sensor really does read the first letters of the address. This is not nothing, and it deserved to be measured rather than dismissed.
2. **The channel is priced above breakeven.** Reading the opening $C$-run of length $L$ costs about $\log_2 L$ output bits, and the resulting saving does not pay for itself against a direct search.
3. **The channel is depth-limited.** It dies immediately past the first inversion — at depth $4$ or $5$ in practice, and provably nowhere later, for every fixed budget and every rational rescaling.

The moral, stated in one sentence: **a cheap window sensor reads the coarse digits of a ratio, and the first two or three letters of a Pythagorean address *are* those coarse digits; every deeper letter is a finer digit, and no fixed-budget window ever sees a finer digit.** The full address costs what it always cost — a full Euclidean climb. The tree stays sealed.

### What survives, and what to try next

Two structural patterns emerged, and they suggest exactly where to push.

The first is a **dyadic criterion**. A letter is readable by some fixed-precision truncation sensor precisely when the boundary separating its two alternatives is a dyadic rational. The top-level boundary $2$ is dyadic — hence always resolvable, hence the first letter is always free. Every *deeper* boundary is a Möbius pullback of $\{2,3\}$ along the earlier letters, producing rationals like $7/3$ and $5/2$, which are not dyadic. Along the $C$-spine the pullbacks stay dyadic (translation by $2$ preserves dyadicity), which is exactly why that one direction remains transparent forever. Making this criterion a general theorem — computing the pullback boundaries at every depth — is the clean next step.

The second is about **what kind of sensor could ever work**. The universal null shows that finer *scaling* is useless: the failure mode is an attained boundary, and truncation is right-continuous, so no rescaling helps. But notice what the failing sensor is missing. Truncation reports $\lfloor m/n \rfloor$ and throws away the remainder. A sensor that reports the *pair* $\big(\lfloor m/n\rfloor,\; m \bmod n\big)$ — one full step of the Euclidean algorithm — resolves attained boundaries by construction and reads strictly more letters. The sharp conjecture is a clean hierarchy: **$t$ Euclidean steps buy $\Theta(t)$ letters of the address, and nothing buys them more cheaply.** If that is right, the tree's secret is not hidden behind precision at all; it is hidden behind the Euclidean algorithm itself, which is to say behind exactly the work you were trying to skip.

That is a satisfying place for a negative result to land. The Pythagorean tree hands out its first few letters for free, like a stranger telling you the first digits of their phone number. The rest costs the call.
