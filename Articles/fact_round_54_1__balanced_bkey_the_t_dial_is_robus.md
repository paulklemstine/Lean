# The Dial That Refused to Break

## How much can a measuring instrument tell you when it can barely tell things apart?

Every experimental science eventually runs into the same quiet problem: the
instrument. You build a knob, you turn it, you watch a number move — and then
someone asks whether the number moved because the world moved, or because the
knob is made of rubber.

This is the story of one such knob, and of what happened when we stopped
arguing about it and computed exactly how much rubber it contains.

The knob in question is deceptively humble. Take a whole number $x$ written in
binary — say a cryptographic key drawn at random from all $b$-bit strings — and
count how many zeros it ends with. The number $88 = 1011000_2$ ends with three
zeros; $7 = 111_2$ ends with none. Number theorists call this count the
**2-adic valuation** $v_2(x)$: the largest power of two dividing $x$. Then cap
it at some ceiling $u$, because in practice you never care past a few zeros:

$$T_u(x) \;=\; \min\bigl(v_2(x),\, u\bigr).$$

That's the dial. Turn $u$ up and the dial resolves finely — it distinguishes
"one trailing zero" from "two" from "three". Turn $u$ down to $1$ and it
collapses to bare parity: odd or even, nothing more.

The empirical claim we set out to explain was a robustness claim. Sweep the
bit length $b$ of the keys and the cap $u$ of the dial across a wide grid, and
at *every single cell* of that grid, the rank correlation between $T_u$ and the
observed response stayed above $0.53$, and the capped dial beat bare parity by
between $0.10$ and $0.15$. No cell where things fell apart. No cliff. The
question is why — and whether "no cliff" is a lucky accident of the particular
grid that got tested, or something structural that no future grid could
violate.

The answer turns out to be the second thing, and the proof of it is prettier
than the claim.

---

## Ties are a tax on correlation

Start with the obstruction. Rank correlation — Spearman's $\rho$ — works by
replacing each observation with its position in the sorted order and then
computing an ordinary correlation between those positions. It is a beautiful
tool precisely because it doesn't care about units or about the shape of the
relationship, only about order.

But our dial has almost no order to offer. Among $2^b$ keys, exactly half are
odd, a quarter end in exactly one zero, an eighth end in exactly two, and so
on. The dial assigns the same value to enormous blocks of keys. When ranks are
tied, statisticians assign every member of a tied block the *average* of the
ranks that block occupies — the midrank. And midranks are less spread out than
true ranks. A variable that is constant on huge blocks simply has less variance
to correlate with anything.

That variance loss can be computed exactly, and it is the single formula
everything in this story rests on. Suppose the dial partitions $n$ observations
into tied blocks of sizes $m_1, m_2, \dots, m_r$. Then the largest squared
Spearman correlation the dial can possibly achieve against *any* response —
even a response that agrees with it perfectly, even a noiseless one — is

$$\rho^2_{\max} \;=\; 1 \;-\; \frac{\sum_i (m_i^3 - m_i)}{n^3 - n}.$$

Call this the **tie ceiling**. It is a hard budget. The instrument cannot read
higher, no matter how strong the underlying signal is. The interesting
scientific question is never "did the dial read $0.53$?" but "how far below its
own ceiling did it read?"

For the capped trailing-zero dial the block sizes are transparent: among the
$2^b$ keys below $2^b$ there are $2^{b-1}$ odd ones, $2^{b-2}$ ending in
exactly one zero, down to $2^{b-u}$ ending in exactly $u-1$ zeros, and finally
a top block of $2^{b-u}$ keys divisible by $2^u$ that the cap refuses to
separate. Two knobs, one profile.

---

## The separation law: the two knobs never talk to each other

Feed that profile into the ceiling formula and the geometric series collapses.
For any bit length $b \ge 1$ and any cap $1 \le u \le b$:

$$\rho^2(b,u) \;=\; \frac{6}{7}\Bigl(1 - 8^{-u}\Bigr)\Bigl(1 + \frac{1}{4^{b}-1}\Bigr).$$

Look at the shape of it. There is a **cap factor** $1 - 8^{-u}$ that depends
only on the resolution of the dial, and a **bitlen factor**
$1 + 1/(4^b - 1)$ that depends only on the size of the key space, and a
universal constant $6/7$. The two experimental knobs enter as independent
multiplicative factors. They do not interact — not approximately, not
asymptotically, but exactly.

This is the precise mathematical content of "no cliff", and it deserves a
sharper statement. A table of numbers $M_{bu}$ whose entries factor as
$f(b)g(u)$ is a **rank-one** matrix, and rank-one matrices are characterised by
the vanishing of every $2 \times 2$ determinant. So for any two bit lengths and
any two caps,

$$\rho^2(b,u)\,\rho^2(b',u') \;=\; \rho^2(b,u')\,\rho^2(b',u).$$

Every row of the ceiling table is a rescaling of every other row; every column
is a rescaling of every other column. There is literally no interaction term
in which a cliff could hide. If some cell of the grid had collapsed, it could
not have been the instrument's fault — because instrument capacity has no
cell-specific structure at all.

The numbers make the point viscerally. As $u \to \infty$ the cap factor
saturates and the ceiling tends to $\sqrt{6/7} = 0.925820\ldots$; at $u=1$,
bare parity, it is $\sqrt{3/4} = 0.866025\ldots$. Between $b = 8$ and $b = 64$
the entire ceiling moves by less than $10^{-5}$ — in general, changing the bit
length shifts the ceiling by less than $2 \cdot 4^{-b}$, uniformly in the cap.
For $64$-bit keys that is a movement of order $10^{-38}$. The bitlen axis of
the experiment is, from the instrument's point of view, not an axis at all.

---

## The floor is not about binary at all

So the ceiling is high everywhere. But a high ceiling doesn't by itself explain
a high *reading*; and one might still worry that the recorded floor of $0.53$
is somehow propped up by the special dyadic arithmetic of the halving blocks.

It isn't. Here is the surprise, and it is where the mathematics stops being
about binary numbers.

**Mass-fraction floor law.** Let a statistic partition $n \ge 2$ observations
into tied blocks, and suppose no single block holds more than a fraction $a<1$
of the sample. Then its tie ceiling satisfies

$$\rho^2 \;>\; 1 - a^2.$$

The proof is two lines. If every block has $m_i \le an$, then
$\sum_i m_i^3 \le (an)^2 \sum_i m_i = a^2 n^3$, so the tie penalty is at most
$(a^2n^3 - n)/(n^3-n)$, which is strictly less than $a^2$. Nothing else about
the statistic is used: not the number of blocks, not the arithmetic that
produced them, not the law the data were drawn from.

Specialise to $a = 1/2$ — call a statistic **balanced** if no single value
carries more than half the sample — and you get a completely distribution-free
guarantee:

$$\rho^2 > \tfrac34, \qquad\text{i.e.}\qquad \rho > 0.866.$$

The capped trailing-zero dial is balanced at every cell of the grid, for the
trivial reason that its biggest block is the odd keys, which are exactly half.
So the recorded floor of $0.53$ is not merely cleared — it is cleared by a
margin of $0.33$, and cleared for a reason that has nothing to do with powers
of two. Change the key distribution, change the arithmetic, change the
statistic entirely; as long as no value hogs a majority, the instrument's
capacity never falls below $0.866$.

How much majority does it take to break it? The floor law says a modal class of
size $a$ still leaves $\sqrt{1-a^2}$, which stays above $0.53$ as long as
$a \le 0.847$. And the failure really does happen: the two-block profile
$[15,1]$ — one value carrying $93.75\%$ of the sample — has tie ceiling
$\rho^2 = 3/17$, that is $\rho \approx 0.420$, well below the recorded floor;
and already the profile $[8955, 1045]$, at $89.55\%$ modal mass, reads
$\rho^2 = 0.28074 < 0.53^2$. The cliff exists; it is just sitting far away, in
the window of modal mass between roughly $84.8\%$ and $89.6\%$, where no cell of
the experiment goes — every cell has modal mass exactly one half.

---

## Why finer beats coarser — and how much that can possibly be worth

The second recorded fact was that the capped dial beats bare parity by
$0.10$–$0.15$. Half of that has a clean structural explanation and half of it
does not, and the discrepancy is the most interesting thing in the whole study.

The structural half is a **coarsening law**. Merging two tied blocks of sizes
$m$ and $m'$ into one block of size $m+m'$ increases the tie penalty, because
$(m+m')^3 > m^3 + m'^3$. So coarsening a statistic can only lower its ceiling.
And lowering the cap by one is *exactly* such a merge: the keys with $u-1$
trailing zeros get amalgamated with the keys that already had $u$ or more. Finer
dials have higher ceilings, and the reason is a cubic inequality, not a
property of binary expansions.

Quantitatively, for any cap $u \ge 2$ the advantage in squared correlation is
at least $3/32 = 0.09375$. That sounds like it matches the recorded band
nicely — until you remember that the recorded band is in $\rho$, not $\rho^2$,
and that these ceilings live near the top of the range where the square root
compresses everything. The largest possible gap in $\rho$ is

$$\sqrt{6/7} - \sqrt{3/4} \;=\; 0.925820\ldots - 0.866025\ldots \;=\; 0.059795\ldots,$$

and we can prove that at every cell of the envelope the tie-resolution
advantage is below $0.07$ in $\rho$, no matter how large the cap.

So tie resolution can buy at most about six hundredths, and the experiment
recorded ten to fifteen. The excess must come from somewhere else. Since the
capped dial cannot read above its own ceiling, arithmetic forces the
conclusion: **the bare-parity reading must sit at least $0.03$ below its own
ceiling.** The advantage of the capped dial is not a granularity artefact of
having more distinct values; parity is genuinely losing information about the
response — information carried by the deeper valuations $v_2 \ge 2$ that parity
throws away.

That is a satisfying inversion of the usual roles. The theory was invoked to
defend an experimental claim, and instead it turned one of the claims into a
structural obligation: an obligation on the *other* statistic, which the theory
now says must be underperforming for substantive reasons.

---

## Balanced keys: changing the law barely moves the dial

One loose end remained. The experiment's name refers to *balanced* keys: keys
drawn not uniformly, but with a fixed Hamming weight $w$ — exactly $w$ ones
among $b$ bits. That changes the tie profile completely. It is no longer
dyadic; it is binomial. Among the weight-$w$ keys, the number whose lowest set
bit sits at position $k$ is $\binom{b-1-k}{w-1}$, and these sum over
$k = 0, \dots, b-w$ to $\binom{b}{w}$ — the hockey-stick identity, wearing a
cryptographic hat.

None of the dyadic closed forms survive. The floor law does, because it never
cared. The mechanism is a clean identity:

$$b \binom{b-1}{w-1} \;=\; w \binom{b}{w},$$

which says that the modal tie class — the odd keys — carries exactly a fraction
$w/b$ of the balanced keys. So *key* balance, $2w \le b$, transfers directly
into *tie* balance, no majority class, and the distribution-free floor applies
verbatim: $\rho > 0.866$ for balanced keys too.

At the exactly balanced weight $w = b/2$ the modal class is exactly half the
sample, and the ceiling gets pinned from both sides at once: above $3/4$ by the
floor law and below $7/8 + 7/(8(n^2-1))$ by the half-mass cap. Squeezed
between these, the balanced ceiling and the uniform ceiling differ by less than
$0.07$ in $\rho$. Swapping the draw law cannot move the instrument by more than
tie granularity allows. Any recorded balanced-versus-uniform difference larger
than that is a fact about the world, not about the ruler.

---

## What robustness actually means

The word "robust" usually functions as a shrug: we tried a bunch of settings
and nothing went wrong. This episode suggests something sharper is available.

Robustness, made precise, is **separability**. The instrument's capacity
factors over the knobs, so the capacity table is rank one, so there is no cell
in which a cell-specific breakdown could live. That is a checkable algebraic
property, not a summary of a finite sweep, and it extends automatically to
every cell you didn't test.

And the guarantee underneath it is **distribution-free**. The floor that keeps
the dial above $0.53$ isn't a property of the dyadic law, or of binary
arithmetic, or of the particular seeds used; it is a property of any statistic
whose modal class holds no majority. That is the kind of statement that
survives a change of application domain.

Finally — and this is the part experimentalists should steal — an exact
capacity calculation lets you audit your own measurements. When a recorded
effect exceeds what the instrument's granularity could possibly manufacture,
you have learned something positive: the effect is real, and its excess is a
number you can now go looking for. The dial refused to break, and in the
process it told us where else to look.
