# The Dials Are Independent: How Two Cubic Equations Keep Their Secrets From Each Other

*When two polynomials are reduced modulo the same prime, does one of them ever whisper to the other? The answer is exact: either not at all, or precisely one bit.*

---

## A machine with a dial

Pick a cubic polynomial with integer coefficients, say

$$f(x) = x^3 + x + 1 .$$

Now pick a prime number $p$ and ask a very simple question: *how many solutions does $f(x) \equiv 0 \pmod p$ have among the numbers $0, 1, \dots, p-1$?*

Try it for a few primes. Modulo $p = 5$, none of $0,1,2,3,4$ is a root, so $f$ has no roots. Modulo $p = 11$, $x = 2$ is the only root. Keep going, and a pattern that is not really a pattern emerges: sometimes you find three roots, sometimes exactly one, sometimes none. (Two roots is impossible: if a cubic has two roots modulo $p$, the third comes for free.)

These three outcomes have names. When $f$ breaks into three linear factors modulo $p$ we say its *splitting type* is $111$. When it breaks into a linear factor times an irreducible quadratic, the type is $12$. When it stays irreducible, the type is $3$.

So a cubic polynomial is like a machine with a dial. Feed it a prime, and the dial clicks to one of three positions: $111$, $12$ or $3$. Feed it the next prime, and the dial clicks again, apparently at random.

It is not really random, of course: everything is determined by arithmetic. But one of the great theorems of number theory, the **Chebotarev density theorem**, says that in the long run the dial behaves *exactly* like a fair random device with known odds. For a "generic" cubic like $x^3+x+1$ — one whose symmetry group is the full group $S_3$ of all six permutations of its three roots — the odds are

$$\Pr[111] = \tfrac16, \qquad \Pr[12] = \tfrac12, \qquad \Pr[3] = \tfrac13 .$$

Where do these numbers come from? For each prime there is a hidden permutation of the three roots, called the *Frobenius element*. The dial simply reports the cycle shape of this permutation: the identity ($1$ out of $6$ permutations) gives $111$; the three swaps give $12$; the two rotations give $3$. Chebotarev says that the hidden permutation is, statistically, a uniformly random element of the group $S_3$.

Checking this against reality is easy with a computer. Among the $3241$ primes $5 \le p < 30000$ that do not divide the relevant discriminants, $x^3+x+1$ shows type $111$ for $525$ primes, type $12$ for $1632$ primes and type $3$ for $1084$ primes: about $16.2\%$, $50.4\%$ and $33.4\%$. The dial is fair.

## Two machines, one prime

Now take *two* such machines — two cubics, say

$$f(x) = x^3 + x + 1 \quad\text{and}\quad g(x) = x^3 - x - 1,$$

and feed them the *same* prime at the same time. Both dials click. Here is the question at the heart of this story:

> **If you see where the first dial landed, do you learn anything about where the second dial landed?**

This is a question about *cross-talk*. The two polynomials have nothing obvious to do with each other, but they are being read at the same prime, and primes carry a lot of structure. Could the hidden permutation for $f$ and the hidden permutation for $g$ be secretly correlated?

To make the question quantitative we need a way to measure "how much you learn." That is exactly what Claude Shannon's **mutual information** does.

## Measuring a whisper in bits

Shannon's *entropy* measures the uncertainty in a random outcome, in bits. A fair coin has entropy $1$ bit; a fair die has $\log_2 6 \approx 2.585$ bits. For our cubic dial with odds $\tfrac16, \tfrac12, \tfrac13$ the entropy is

$$H(T) = \tfrac16 \log_2 6 + \tfrac12 \log_2 2 + \tfrac13 \log_2 3 = \tfrac23 + \tfrac12 \log_2 3 \approx 1.459 \text{ bits}.$$

The *mutual information* between two dials $T_1$ and $T_2$ is how much the uncertainty about $T_1$ drops once you have seen $T_2$:

$$I(T_1 ; T_2) = H(T_1) - H(T_1 \mid T_2).$$

If the dials are completely unrelated, seeing one tells you nothing about the other, and $I = 0$. If they always show the same thing, seeing one tells you everything, and $I = H(T_1)$. Mutual information is never negative: on average, information can't make you more confused.

## The experiment

In the experiments that prompted this work, the two dials were read at thousands of primes and the mutual information was estimated from the observed frequencies. For primes, the estimate was $0.000437$ bits, and a statistical test comparing it with shuffled data gave a $z$-score of $-0.81$ — completely unremarkable. For *semiprimes* $N = pq$, where each dial reports a *pair* of positions (one for $p$, one for $q$), the estimate was $0.001424$ bits.

We re-ran the prime experiment on every good prime below $30000$. Here is how the two dials co-occurred, set against what perfect independence predicts:

| $f \backslash g$ | $111$ | $12$ | $3$ |
|---|---|---|---|
| $111$ | $82$ (pred. $90$) | $263$ (pred. $270$) | $180$ (pred. $180$) |
| $12$ | $275$ (pred. $270$) | $811$ (pred. $810$) | $546$ (pred. $540$) |
| $3$ | $170$ (pred. $180$) | $554$ (pred. $540$) | $360$ (pred. $360$) |

The observed mutual information was $0.000243$ bits.

Tiny, but not zero. Is there a faint whisper after all?

No. Any estimate of mutual information from a finite sample is biased *upward*, because random fluctuations always look like a little bit of structure. For a $3 \times 3$ table built from $n$ samples, the typical size of this phantom signal is about $\frac{4}{2 n \ln 2}$ bits, which for $n \approx 3200$ is about $0.0009$ bits. Every observed value sits inside this noise floor.

But statistics can only ever say "consistent with zero." The real payoff of this work is that the answer is **exactly zero**, and the reason is beautiful.

## Why the dials cannot talk

Each cubic has a *splitting field*: the smallest number system containing all three of its roots. Its symmetry group is $S_3$. Inside that splitting field sits a smaller, very special field, the **quadratic resolvent**, which is $\mathbb{Q}(\sqrt{\Delta})$, where $\Delta$ is the discriminant of the cubic. For $x^3+x+1$, $\Delta = -31$; for $x^3-x-1$, $\Delta = -23$.

Galois theory tells us how the two splitting fields interact. Their overlap must be a field that is "normal" inside both, and inside an $S_3$ splitting field the only such fields are the rationals, the quadratic resolvent, and the whole thing. So there are only two interesting possibilities:

1. **Different quadratic resolvents** (for example, coprime discriminants such as $-31$ and $-23$). Then the two splitting fields overlap only in $\mathbb{Q}$. They are *linearly disjoint*, and the combined symmetry group is the full product $S_3 \times S_3$, with all $36$ pairs of permutations.

2. **The same quadratic resolvent** (for example, $x^3-2$ and $x^3-3$, both of whose resolvents are $\mathbb{Q}(\sqrt{-3})$). Then the combined group is smaller: only the $18$ pairs $(\sigma, \tau)$ with *matching sign* — both even or both odd.

Chebotarev's theorem, applied to the combined field, says that the *pair* of hidden permutations is uniformly distributed over the combined group. So the whole question reduces to counting.

In case 1 the pair $(\sigma, \tau)$ is uniform on $S_3 \times S_3$, which is the same as saying that $\sigma$ and $\tau$ are independent uniform permutations. The joint table of splitting types is therefore *exactly* the product of the two marginal tables: $1 \cdot 1 : 1 \cdot 3 : 1 \cdot 2 : 3 \cdot 1 : \dots$, that is $1:3:2:3:9:6:2:6:4$ out of $36$. And a factoring table carries zero mutual information. This is the headline theorem:

> **Theorem (the dials are independent).** If two cubic polynomials with Galois group $S_3$ have different quadratic resolvents, then the mutual information between their splitting types at a random prime is exactly $0$ bits. Equivalently, knowing one dial leaves the full $\tfrac23 + \tfrac12 \log_2 3 \approx 1.459$ bits of uncertainty about the other, and the two dials together carry exactly twice that, $\tfrac43 + \log_2 3 \approx 2.918$ bits.

The measured $0.000437$ and $0.000243$ bits are nothing but sampling noise around this exact zero.

## When the dials do talk: exactly one bit

Case 2 is where it gets interesting. If both cubics share the quadratic resolvent, the dials are *not* independent. Look at the combined group: a pair of permutations with matching signs. Now remember that the dial reading $12$ happens precisely for the odd permutations (the swaps). So if the first dial reads $12$, the second must read $12$ too; if the first reads $111$ or $3$, the second must read $111$ or $3$.

Counting the $18$ pairs gives a joint table with holes in it:

| first $\backslash$ second | $111$ | $12$ | $3$ |
|---|---|---|---|
| $111$ | $1$ | $0$ | $2$ |
| $12$ | $0$ | $9$ | $0$ |
| $3$ | $2$ | $0$ | $4$ |

Remarkably, each dial *on its own* still has the same odds $\tfrac16, \tfrac12, \tfrac13$: sharing the resolvent changes nothing you can see by looking at one polynomial alone. But together they now share information, and the amount is strikingly clean:

> **Theorem (one shared bit).** If two cubics with Galois group $S_3$ share their quadratic resolvent (but have different splitting fields), the mutual information between their splitting types is **exactly $1$ bit**.

That one bit is the sign: "is the hidden permutation odd or even?" — which, in number-theoretic language, is the Legendre symbol $\left(\frac{\Delta}{p}\right)$ of the shared discriminant. Both dials know it; beyond it, they know nothing about each other. Indeed, once you condition on the sign, the even part of the table ($1,2,2,4$) is itself a perfect product table.

The experiment confirms this with almost eerie precision. For $x^3-2$ versus $x^3-3$ across $3243$ primes, the estimated mutual information was $1.000267$ bits; for $x^3-2$ versus $x^3-5$, $1.000023$ bits. And the forbidden cells, like "one dial reads $12$, the other reads $111$," were empty — not rare, *empty*.

## A general law: sharing a quotient costs at least a bit

The one-bit phenomenon is not a coincidence of $S_3$. Here is a general principle behind it.

Suppose two number fields have symmetry groups $G$ and $H$, and each has a "sign-like" map onto a two-element group whose kernels cut out the *same* quadratic field. Then the combined group is the *fibre product*: pairs $(g, h)$ with equal signs. If each dial is detailed enough to determine its own sign, then

$$I(T_1 ; T_2) \ge 1 \text{ bit}.$$

The reason is the **data processing inequality**, one of the most intuitive facts in information theory: you cannot create information by post-processing. Replacing each dial reading by just its sign can only lose information. But the two signs are always *equal*, and each is a fair coin (exactly half the combined group has each sign), so the two signs share exactly $1$ bit. Hence the full dials share at least $1$ bit. For two $S_3$ cubics this lower bound is achieved exactly: not a hair more.

## Semiprimes: bits add up

What about composite numbers $N = pq$? Now each cubic reports a *pair* of dial readings, one at $p$ and one at $q$ — nine possible outcomes. Since the Frobenius elements at two different primes are independent draws, the sample space is a product of two copies of the combined group, and another basic law of information theory kicks in: **mutual information adds over independent blocks**.

> **Theorem (semiprimes).** For $N = pq$, the pair readings of two cubics share exactly $0$ bits if the resolvents differ and exactly $2$ bits if they share their resolvent. Meanwhile each pair reading carries $\tfrac43 + \log_2 3 \approx 2.918$ bits on its own in either case.

The semiprime measurements are noisier — a $9 \times 9$ table has $64$ degrees of freedom instead of $4$, so the phantom bias is sixteen times larger for the same number of samples — which is why the semiprime $z$-score ($+2.79$) looks larger than the prime one. In our own re-run with $1620$ semiprimes, the observed $0.024$ bits sat below the predicted bias of $0.028$ bits. The exact answer is still zero.

## The dichotomy

Put together, the picture is binary and crisp:

$$I(T_1 ; T_2) = \begin{cases} 0 \text{ bits} & \text{if the quadratic resolvents differ (group } S_3 \times S_3\text{)},\\ 1 \text{ bit} & \text{if they coincide (group } S_3 \times_{C_2} S_3\text{)}.\end{cases}$$

There is no middle ground. There is no "weakly correlated" pair of $S_3$ cubics, no slow leak of information. Either the two splitting fields are strangers, or they share exactly one quadratic secret, and the information-theoretic cross-talk is the entropy of that secret.

## Why this matters

Number theorists have long used families of polynomials as *independent* sources of arithmetic randomness, for example when building heuristics about primes or designing tests that combine several Legendre-type symbols. The result here gives a precise, quantitative license for that practice and a precise warning about when it fails: independence holds exactly when the Galois-theoretic overlap is trivial, and the failure, when it happens, is measured in whole bits equal to the size of the overlap.

It is also a nice example of three great theories working together. **Galois theory** tells you the shape of the combined symmetry group. **Chebotarev's theorem** turns that group into a probability space. **Shannon's information theory** turns the probability space into a single number. And the number turns out to be an integer.

## Where next?

The same reasoning suggests natural generalizations. If two fields share a larger common quotient $Q$ — say two quartic polynomials with the same cubic resolvent — does the cross-talk equal $\log_2 |Q|$ bits, or does coarse reading of the dials lose some of it? For products of $k$ primes, is the cross-talk exactly $k$ times the single-prime value, with a finite-sample bias growing like $(3^k-1)^2 / (2n \ln 2)$? And conversely, does *zero* cross-talk force the two fields to be linearly disjoint? Each of these is a finite counting problem waiting to be solved, and each would sharpen the same striking message: in arithmetic, independence is not approximate. It is exact — and when it breaks, it breaks by whole bits.
