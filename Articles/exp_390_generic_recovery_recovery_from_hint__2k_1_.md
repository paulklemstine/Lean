# What a Hint Is Worth

## The oldest question in codebreaking, asked precisely

Imagine you are trying to factor a large number $N = pq$, the product of two secret primes. This is the problem on which a good deal of the world's digital plumbing rests. Now imagine that a whistleblower slips you a note. The note is short — say eight bits, a single byte — and it says something true about $p$.

How much have you gained?

Everyone's instinct says: *some*. A byte is a byte; it should shrink the haystack by a factor of $256$. But instincts have been wrong here before, and spectacularly so. There is a celebrated result, due to Coppersmith, in which leaking *half the bits* of $p$ — not a random half, but the contiguous top half — does not merely shrink the search by $2^{k/2}$; it collapses the problem entirely, from exponential to polynomial time. The haystack does not get smaller. It vanishes.

So the honest question is not "does a hint help?" but "**when can a hint help more than its bit count says it should?**" Is Coppersmith's leak a member of a whole family of hints with magical amplification, waiting to be discovered? Or is it a lonely exception, and is every other hint you can think of worth exactly, boringly, its face value in bits?

This article is about a complete answer to that question, for a precisely defined notion of "worth." The answer is: **the taxonomy is closed.** A $t$-bit hint reduces the search by exactly $2^t$ — never more. Some famous families of hints are worth strictly *less* than $t$ bits, and we can now say exactly how much less, and, more satisfyingly, exactly *why*: every deficit is the order of a symmetry group.

---

## The bookkeeping

Let us make "worth" precise, because everything follows from doing so carefully.

Fix a finite set $S$ of candidates — the $k$-bit primes, say, or all odd residues modulo $2^t$. A **hint** is nothing more than a function $h$ defined on $S$. The adversary is told the *reading* $y = h(p)$ for the true secret $p$, and must then search everything consistent with what they were told. So define the **cost of a reading**
$$\mathrm{cost}(S,h,y) = \#\{a \in S : h(a) = y\},$$
the number of candidates the adversary cannot yet rule out, and the **worst-case recovery cost**
$$\mathrm{worst}(S,h) = \max_{y \in h(S)} \mathrm{cost}(S,h,y).$$

That is the whole model. A hint is a partition of the candidate set into classes; its value is measured by how small it makes the class you land in.

And now the first theorem is almost embarrassingly easy, which is exactly why it is so powerful.

> **The Master Bound.** For any candidate set $S$ and any hint $h$,
> $$\#S \le \#h(S) \cdot \mathrm{worst}(S,h).$$
> Consequently, if the hint takes at most $2^t$ distinct values — that is, if it costs $t$ bits to transmit — then
> $$\mathrm{worst}(S,h) \ge \frac{\#S}{2^t}.$$

The proof is a sentence: the classes partition $S$, there are at most $2^t$ of them, so at least one has at least the average size. **No $t$-bit hint of any kind ever cuts the search by more than a factor of $2^t$.** No cleverness in choosing $h$, no number-theoretic magic, no oracle. The counting simply does not permit it.

This immediately reframes Coppersmith. His method does *not* violate the master bound — nothing can. Knowing the top $k/2$ bits of $p$ leaves exactly $2^{k/2}$ candidate values of $p$, exactly as the bound says. What Coppersmith supplies is an *algorithm* — lattice reduction — that searches that surviving set in polynomial time instead of scanning it one by one. The amplification is not in the information. It is in the geometry of where the leaked bits sit.

We can make that last statement into a theorem too.

> **Position-Freeness.** For a secret represented as a $k$-bit vector, let $A$ be any set of bit positions and let the hint be "read the bits of $p$ in the positions $A$." Then the number of surviving candidates is exactly $2^{k - \#A}$, regardless of *which* positions $A$ contains. Two position sets of the same size give hints of identical class sizes.

Contiguous top half, scattered, alternating, bottom half — counting cannot tell them apart. So the Coppersmith advantage is provably invisible to any counting argument. It is about *position*, not about the amount of information leaked. That is the single most important structural fact in this story, and it tells you exactly where to look for further amplification: in algorithms exploiting algebraic structure, never in the accountancy of bits.

---

## Hints that are worth exactly their bits

Is the master bound tight, or is it a soft inequality that no real hint attains?

It is tight, and there is a one-line hint that attains it. Take the candidate set $\{0, 1, \dots, q2^t - 1\}$ and the **block hint** $p \mapsto \lfloor p/q \rfloor$. Then the hint realises all $2^t$ possible readings, *every single fibre has exactly $q$ elements*, and the worst-case recovery cost is exactly $q = \#S/2^t$. Perfect equality with the master bound.

More interestingly, the same exactness holds for the hints one actually meets in the wild. Suppose the hint is *linear*: take $t$ random $\mathrm{GF}(2)$ linear forms in the bits of $p$ and report their values. Because a linear hint is a group homomorphism, every one of its nonempty classes is a coset of the kernel, and cosets all have the same size.

> **Information-Exactness of Linear Hints.** If a hint is a surjective homomorphism of finite abelian groups, all its fibres have the same size. In particular a surjective $\mathrm{GF}(2)$-linear hint from $k$ bits onto $t$ bits leaves exactly $2^{k-t}$ candidates for every reading.

This is the "no anomalous class" phenomenon, and it is *precisely* what the numerical experiments see. On the exact set of $16$-bit primes, of which there are $3030$, random linear bit-hints at $t = 1, 2, 4, 6, 8$ produce measured average class sizes
$$1515,\quad 759,\quad 190,\quad 48.6,\quad 12.8$$
against theoretical values
$$1515,\quad 757.5,\quad 189.4,\quad 47.3,\quad 11.8.$$
The agreement is to within the noise of a sparse set. And crucially, no reading of the hint is ever anomalously informative: there is no lucky class, no super-resolution. The measured median number of search steps equals the class size, on the nose.

That last point deserves a theorem of its own, because "the worst class is big" is a weaker claim than "the *typical* class is big." Could a hint be usually razor-sharp and only occasionally blunt, so that its average performance beats the master bound? No.

> **Average-Case Master Bound.** For a hint with at most $2^t$ readings,
> $$(\#S)^2 \le 2^t \sum_{y} \mathrm{cost}(S,h,y)^2 .$$

Since $\sum_y \mathrm{cost}(y)^2 / \#S$ is exactly the expected class size when the secret is drawn uniformly from $S$, this says the *expected* number of candidates to scan is at least $\#S/2^t$ as well. A single application of Cauchy–Schwarz kills the "typically sharp, rarely blunt" escape route.

---

## Hints that are worth less: the parity tax

Now the surprises begin, and they all go in the *pessimistic* direction.

Consider two hints you would think are as good as a bit-vector: the multiplicative hash $p \mapsto cp \bmod 2^t$ for a fixed odd multiplier $c$, and the XOR-mask hash $p \mapsto (p \oplus m) \bmod 2^t$. Both output a $t$-bit word. Both look uniform. Both are wasting a bit.

The reason is trivial once said: $p$ is prime, hence odd, and $c$ is odd, so $cp$ is odd. The output's lowest bit is *always* $1$. It never varies, so it carries no information. The hint can realise at most $2^{t-1}$ values out of the $2^t$ it costs to transmit, and therefore

> **Value Hints Lose a Bit.** For odd candidates and odd $c$,
> $$\mathrm{worst}(S,\ p \mapsto cp \bmod 2^t) \ \ge\ \frac{\#S}{2^{t-1}},$$
> and the same for the XOR-mask hint (whose low bit is determined by the mask alone).

Measured: on $16$-bit primes with $t=4$, value-hint classes have $378.9$ candidates against $189.4$ for a genuine bit-vector hint. Exactly a factor of two. **Bit-vector forms are the only full-$2^t$ generic hints.** If a protocol designer says "I leak a $t$-bit hash of the prime," the honest accounting is $t-1$.

---

## The trace hint, and the theorem behind a stubborn constant

The most interesting family is the **trace hint**. In factoring, the natural quantity to leak is not $p$ but the trace $s = p + q$, since $N = pq$ is already public. Suppose you learn $s \bmod 2^t$.

Complete the square. Since $p$ and $q$ are the roots of $x^2 - sx + N$, we have
$$(2p - s)^2 = s^2 - 4N .$$
So the adversary does not learn $p$ modulo $2^t$; they learn a *square* modulo a power of two, and $p$ is pinned only up to the square roots of that square. How many are there? Experimentally, the number saturates at $4$ to $8$, and the recovery cost is inflated by a stubborn constant: measured $399$ candidates against a predicted $47.3$ at $k=16$, $t=6$, and $354$ against $42.0$ at $k=18$, $t=8$. Roughly $4.5$–$5\times$ worse than a clean bit hint, i.e. about $3$ bits of the budget silently evaporating.

Three bits. Where do they go?

The first bit goes to parity, as before. The other two are a genuinely 2-adic phenomenon, and the key lemma is a small gem:

> **The 2-adic square map halves resolution.** For odd integers $x$ and $u$,
> $$2^{\,n+2} \mid x^2 - u^2 \iff 2^{\,n+1} \mid x - u \ \text{ or } \ 2^{\,n+1} \mid x + u .$$

From this one deduces the exact count.

> **Exactly Four Square Roots.** For $t \ge 3$ and $u$ odd, the congruence $x^2 \equiv u^2 \pmod{2^t}$ has exactly four solutions modulo $2^t$, namely
> $$x \equiv \pm u, \quad x \equiv \pm u\bigl(1 + 2^{\,t-1}\bigr) \pmod{2^t}.$$

And therefore the value of a trace hint is not $t$ bits, and not $t-1$; it is exactly $t-3$.

> **The Trace Hint Carries Exactly $t-3$ Bits.** On the $2^{t-1}$ odd residues modulo $2^t$, the squaring hint has *every* class of size exactly $4$, and therefore realises exactly $2^{\,t-3}$ distinct readings. Its worst-case recovery cost is exactly $4$.

One bit to parity, two to the square-root ambiguity: the measured $\log_2 C_t \approx 3$ deficit is now a theorem rather than a table entry.

---

## Why deficits exist at all: it is always a symmetry

At this point the taxonomy contains three families losing $0$, $1$, and $3$ bits respectively, and you might reasonably ask whether those are three unrelated accidents. They are not. They are one phenomenon.

Here is the mechanism, in complete generality. Suppose that around every candidate $a \in S$ you can produce $g$ distinct candidates in $S$ that all give the *same* reading as $a$. Then every class has at least $g$ elements, and a counting argument gives
$$g \cdot \#\{\text{readings}\} \le \#S .$$
The hint's nominal budget is cut by $\log_2 g$ bits. **The deficit is the order of the group of candidate symmetries that the hint cannot see.**

For value hints, that group has order $2$: the hint is blind to a fixed parity constraint. For the trace hint, the group is beautifully explicit. Modulo $2^t$ with $t \ge 3$, the square roots of unity form a **Klein four-group**
$$\{\,1,\ -1,\ 1 + 2^{\,t-1},\ -(1 + 2^{\,t-1})\,\},$$
and multiplying a candidate by any of these does not change its square, hence does not change the trace reading. On any candidate set of units closed under this group — the sparse sets of actual primes in the experiments are close enough — every class has at least four elements and there are at most $\#S/4$ readings. The measured factor of four is the order of a group, computed structurally rather than by table lookup.

This unification also explains why the taxonomy is *closed*. To find a family of hints that beats its bit count you would have to beat the master bound, which is impossible. To find a family that merely matches the bit count you need a hint with no invariance group — and bit-vector linear forms are exactly that. Everything in between is measured by a single group-theoretic invariant.

---

## What survives the audit

Two more legs complete the picture, both negative and both worth stating.

> **Data Processing.** Post-processing never amplifies: for any $g$, $\mathrm{worst}(S,h) \le \mathrm{worst}(S, g \circ h)$. And bits add rather than multiply: two hints of $t_1$ and $t_2$ bits, used jointly, leave at least $\#S/2^{t_1+t_2}$ candidates.

> **Public Hints Are Sealed.** If a hint can be recomputed from data the adversary already holds — anything checkable against $N$ alone — then it has a single class, and its worst-case recovery cost is the entire candidate set. Zero information, no matter how many bits it is allowed to output.

That second one is the practical punchline. A "hint" that is a function of $N$ tells you nothing you did not already know; it is a very expensive way of writing down zero. Hints must be *genuinely external* to be worth anything at all.

Finally, the whole programme meets an older one. A *residue-dial system* — a family of congruence conditions that an adversary tunes to filter candidates — is, from this vantage point, just a hint whose number of readings is bounded by $M^*/\gcd(M^*, m)$, where $M^*$ is the conditional lcm of the dial moduli. The master bound therefore applies verbatim, and the dials leave at least $\#\Omega \cdot \gcd(M^*,m)/M^*$ candidates. Two independent negative results turn out to be one theorem seen from two sides.

---

## The verdict

Put the pieces together and you get a closed taxonomy of what an external $t$-bit hint about a secret prime can do.

- **Never more than $2^t$.** The master bound is universal, holds in the average case as well as the worst case, and cannot be evaded by post-processing or by combining hints.
- **Exactly $2^t$, attained.** Block hints and surjective linear bit-hints hit the bound with every class the same size. Hints are worth their bits at face value — no more, and if they are linear, no less.
- **Exactly $2^{t-1}$ for value hashes.** Multiplicative and XOR-mask hints on odd secrets burn one bit on a constant.
- **Exactly $2^{t-3}$ for trace hints.** One bit to parity, two to the Klein four-group of square roots of unity mod $2^t$.
- **Zero for public hints.** Anything recomputable from $N$ is worthless.
- **Every deficit is a group order.** The wasted bits of a hint family are $\log_2$ of the order of its invariance group — a single invariant, not a list of accidents.

And Coppersmith? He is still there, still exceptional, and now visibly so for the right reason. His method does not extract more information than the bits contain; the counting forbids that. It exploits the *position* of those bits — their contiguity at the top of $p$ — in a lattice, which is an algorithmic fact that no counting argument can see or produce. The one and only known amplification in the entire landscape is about geometry, not about information.

Which is, in the end, a reassuring thing for a cryptographer to know. If you leak $t$ bits of a secret prime, you have leaked $t$ bits. Unless you have leaked the *right* $t$ bits, in the right places, and then you may have leaked everything.
