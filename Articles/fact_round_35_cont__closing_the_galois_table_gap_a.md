# The Biggest Quotient Whispers the Least

*How a group of 56 symmetries of an eight-element field overturned a natural guess about how much information leaks through prime numbers — and the one-line law that explains why.*

---

## A game of partial information

Imagine that every prime number carries a hidden label and a visible badge.

The **hidden label** is a residue: something like "what is $p$ modulo $7$?" It is the kind of quantity a cryptanalyst would love to know about the secret prime factors of a large number.

The **visible badge** is coarser. It records *how a fixed polynomial factors* when you reduce its coefficients modulo $p$: perhaps it splits into eight linear pieces, perhaps into four quadratics, perhaps into a linear factor times an irreducible of degree seven. Number theorists call this the **splitting type** of $p$.

The question is simple to ask: *how much does the badge tell you about the label?* Measured in bits — Claude Shannon's unit of information — the answer is a single number, the **mutual information** between the two. And because both badge and label are shadows of one deeper object, the answer turns out to be pure group theory.

This article tells the story of what happens when you push that question to a group bigger than anyone had looked at before, and find the opposite of what intuition predicts.

## Where the badge and the label come from

Every polynomial with integer coefficients has a **Galois group** $G$: the group of symmetries of its roots that respect all algebraic relations among them. For each prime $p$ (apart from finitely many exceptional ones) there is a distinguished symmetry, the **Frobenius element** of $p$, defined only up to conjugation in $G$.

Two facts make the game precise.

1. **The badge is the cycle type.** If you think of $G$ as permuting the roots, the splitting type of the polynomial modulo $p$ is exactly the cycle type of the Frobenius element. A Frobenius that fixes one root and cycles the other seven corresponds to "one linear factor times one irreducible septic." Cycle type is a *class function*: it does not change under conjugation, so it is well defined even though the Frobenius is only known up to conjugacy.

2. **The label is the abelian shadow.** Every group has a largest commutative quotient, its **abelianization** $G^{ab} = G/[G,G]$, obtained by collapsing all commutators $xyx^{-1}y^{-1}$ to the identity. Its elements are the cosets of the derived subgroup $[G,G]$. By class field theory, the image of Frobenius in $G^{ab}$ is governed by congruence conditions on $p$ — it is literally a residue of $p$. Better still, it is *multiplicative*: the coset attached to a product $N = pq$ is the product of the cosets of $p$ and $q$.

Finally, Chebotarev's density theorem says Frobenius elements are equidistributed: in the long run, every group element is equally likely. So the idealised game is: **pick a uniformly random element $g$ of $G$; reveal its cycle type $T(g)$; how many bits does that reveal about its coset in $G^{ab}$?**

We write

$$I_1 = I\big(\text{coset}(g);\, T(g)\big)$$

for this **prime channel**, and

$$I_2 = I\big(\text{coset}(xy);\, \{T(x), T(y)\}\big)$$

for the **semiprime channel**: two independent random elements $x, y$ (the Frobenius elements of two secret primes), where you see only the *unordered* pair of their cycle types and want to learn the coset of the product — the residue of $N$.

## The ceiling, and a tempting guess

There is an obvious ceiling. A uniformly random coset of a group with $n = |G^{ab}|$ elements carries exactly $\log_2 n$ bits, so no badge can ever reveal more:

$$0 \le I_2 \le I_1 \le \log_2 |G^{ab}|.$$

Call $\log_2 |G^{ab}|$ the **cap**.

The tempting guess is that a bigger cap means a bigger leak. And earlier explorations had already dented one version of this guess: the symmetric group $S_4$, with $24$ elements, leaks exactly $1$ bit through its prime channel, while the dihedral group $D_4$ of the square, with only $8$ elements, leaks about $1.66$ bits. So the leak is **not monotone in the size of the group**. The natural fallback was that it is the *size of the abelianization* that matters — and indeed $D_4$ has $|G^{ab}| = 4$ while $S_4$ has only $2$.

The trouble was that every group examined so far had $|G^{ab}| \le 4$, so every cap was at most $2$ bits. The interesting territory above two bits had never been tested.

## Enter $\mathrm{AGL}(1,8)$

The first group with a larger abelianization is a beautiful one. Take the field with eight elements, $\mathbb{F}_8 = \mathbb{F}_2[x]/(x^3 + x + 1)$, and consider all **affine maps**

$$t \longmapsto a\,t + b, \qquad a \in \mathbb{F}_8^{\times},\ b \in \mathbb{F}_8.$$

There are $7$ choices for the multiplier $a$ and $8$ for the shift $b$, giving a group $\mathrm{AGL}(1,8)$ of order $56$ acting on the eight points of the field.

Its anatomy is clean:

- The **derived subgroup** is exactly the group of pure translations $t \mapsto t + b$, a copy of $(\mathbb{Z}/2)^3$ of order $8$.
- The **abelianization** is therefore the multiplicative group $\mathbb{F}_8^\times$, cyclic of order $7$. The coset of an affine map is just its multiplier $a$. The cap is $\log_2 7 \approx 2.807$ bits — the largest of any group examined.

Now look at the badges. There are only **three** cycle types among the 56 elements:

| element | how many | cycle type on 8 points | coset |
|---|---|---|---|
| identity | 1 | eight fixed points, $[1^8]$ | trivial |
| translation $t \mapsto t+b$, $b \neq 0$ | 7 | four 2-cycles, $[2^4]$ | trivial |
| $t \mapsto at + b$, $a \neq 1$ | 48 | one fixed point and a 7-cycle, $[1,7]$ | the six nontrivial cosets, 8 each |

The last row is the whole story. When $a \neq 1$, the map has exactly one fixed point, $t = b/(1-a)$, and since every nontrivial element of $\mathbb{F}_8^\times$ has order $7$ (because $7$ is prime), the remaining seven points form a single cycle. **All six nontrivial cosets wear exactly the same badge.**

So the badge answers just one yes-or-no question: *is the multiplier trivial?* The answer is "yes" with probability $1/7$.

## The numbers

Computing the information exactly over all $56$ elements gives

$$I_1 = \log_2 7 - \tfrac{6}{7}\log_2 6 \approx 0.5917 \text{ bits},$$

only about $21.1\%$ of the cap. Computing the semiprime channel exactly over all $56^2 = 3136$ ordered pairs gives

$$I_2 = \log_2 7 - \tfrac{78}{49}\log_2 6 + \tfrac{30}{49}\log_2 5 \approx 0.1141 \text{ bits},$$

a mere **$4.1\%$ of the cap**. Pairing destroys more than four-fifths of the already small prime channel ($5 I_2 < I_1$), and — a small curiosity — knowing *which* prime has which badge does not help at all: the ordered pair $(T(x), T(y))$ carries exactly the same $0.1141$ bits as the unordered one.

Here is the table that results:

| group | order | $\lvert G^{ab}\rvert$ | cap (bits) | prime leak $I_1$ | semiprime leak $I_2$ | $I_2$ as % of cap |
|---|---|---|---|---|---|---|
| $S_4$ | 24 | 2 | 1.000 | 1.000 | 1.000 | 100% |
| $D_4$ | 8 | 4 | 2.000 | 1.656 | 1.430 | 71.5% |
| $V_4$ | 4 | 4 | 2.000 | 0.811 | 0.295 | 14.7% |
| $A_4$ | 12 | 3 | 1.585 | 0.918 | 0.474 | 29.9% |
| $\mathbf{AGL(1,8)}$ | **56** | **7** | **2.807** | **0.592** | **0.114** | **4.1%** |

The group with the **largest** abelianization has the **smallest** leak of all — at the prime level and at the semiprime level, and as a fraction of its cap. The fallback guess fails as badly as it possibly could. The leak is monotone neither in the size of the group nor in the size of its abelian quotient.

## The law behind the reversal

A table of numbers is a symptom. The cure is a theorem, and it is short enough to state in one breath.

Call a badge $T$ a **trivial-coset detector** if one particular badge value appears *exactly* on the elements outside the derived subgroup. In words: every element with a nontrivial coset looks the same, and whatever variety the badge shows lives entirely inside the trivial coset.

> **The Detector Law.** If $T$ is a trivial-coset detector on a finite group with $n = |G^{ab}| \ge 2$, then
> $$I\big(\text{coset};\,T\big) \;=\; \log_2 n - \frac{n-1}{n}\log_2(n-1) \;=\; h\!\left(\frac1n\right),$$
> where $h(p) = -p\log_2 p - (1-p)\log_2(1-p)$ is the binary entropy function. This holds *regardless of anything else $T$ does* inside the trivial coset.

The reason is almost a riddle. The badge tells you one of two things. Either "you are in the trivial coset" (probability $1/n$) — and then you know the coset completely, so no uncertainty remains; or "you are somewhere else" (probability $(n-1)/n$) — and then all $n-1$ remaining cosets are equally likely, leaving $\log_2(n-1)$ bits of uncertainty. Subtract the average remaining uncertainty from the initial $\log_2 n$ bits, and the law falls out. Whatever finer distinctions the badge draws inside the trivial coset — identity versus translation, say — tell you nothing new about the coset, because there was nothing left to learn there.

Three consequences make the reversal not just explicable but inevitable:

- **Anti-monotonicity.** Since $h$ increases on $[0, \tfrac12]$ and $1/n$ shrinks as $n$ grows, a detector with a *strictly larger* abelianization has a *strictly smaller* channel. Among detectors, bigger caps mean smaller leaks — always.
- **Vanishing.** As $n \to \infty$ the channel tends to $0$, with the explicit bound $h(1/n) \le (\log_2 n + 3)/n$, even though the cap $\log_2 n$ grows without limit. The fraction of the cap that is realised tends to zero.
- **Instances.** $\mathrm{AGL}(1,8)$ is a detector with $n=7$, and the law reproduces $h(1/7) \approx 0.5917$. The alternating group $A_4$ is secretly $\mathrm{AGL}(1,4)$, a detector with $n = 3$, and the law gives $h(1/3) = \log_2 3 - \tfrac23 \approx 0.918$. The Klein four-group $V_4$, acting on itself, is a detector with $n=4$ and gives $h(1/4) \approx 0.811$. So $\mathrm{AGL}(1,8)$ *must* leak less than $A_4$ — no numerics needed, just $7 > 3$.

More generally, every affine group $\mathrm{AGL}(1,2^k)$ for which $2^k - 1$ is a Mersenne prime is a detector, for the same reason as $\mathbb{F}_8$: all nontrivial multipliers share the same prime order. Along that ladder — $n = 3, 7, 31, 127, 8191, \dots$ — the leak marches to zero: $0.918,\ 0.592,\ 0.206,\ 0.066,\ 0.0018, \dots$ bits.

## The real lesson: resolution, not size

The general identity behind all of this is the one every information theorist knows:

$$I(\text{coset}; T) \;=\; \log_2 |G^{ab}| \;-\; H(\text{coset} \mid T).$$

The first term is the cap. The second — the **deficit**, the uncertainty that survives after seeing the badge — is what varies wildly from group to group. For $D_4$ the badge distinguishes the cosets well, and the deficit is small: about $83\%$ of the cap gets through at the prime level. For $\mathrm{AGL}(1,8)$ the badge lumps six of seven cosets together, and the deficit $\tfrac67 \log_2 6 \approx 2.22$ bits swallows almost everything.

So the right slogan is not "bigger group, bigger leak," nor "bigger abelianization, bigger leak," but:

> **What leaks is how much of the abelian quotient the badge *resolves*.**

A large quotient seen through a coarse class function is a worse channel than a small quotient seen through a faithful one.

## What happens with two primes?

For the semiprime channel the same mechanism seems to operate. Seeing the unordered pair of badges reveals only *how many* of the two hidden Frobenius elements lie in the trivial coset — two, one, or none. If both do, the product coset is trivial. If exactly one does, the product coset is uniform over the $n-1$ nontrivial values. If neither does, the product coset is the sum of two independent uniform nonzero residues, which is $0$ with probability $1/(n-1)$ and otherwise uniform. This predicts a **pair-detector formula**

$$\delta_2(n) = \log_2 n - \frac{2(n-1)}{n^2}\log_2(n-1) - \Big(\frac{n-1}{n}\Big)^2 H_n,$$

$$H_n = \frac{1}{n-1}\log_2(n-1) + \frac{n-2}{n-1}\log_2\frac{(n-1)^2}{n-2}.$$

Exact enumeration confirms it at $n = 3$ ($A_4$: $\log_2 3 - \tfrac{10}{9} \approx 0.474$) and at $n = 7$ ($\mathrm{AGL}(1,8)$: $0.1141$), and it also matches $V_4$ at $n=4$ ($0.295$) and $\mathrm{AGL}(1,32)$ at $n=31$ ($0.0081$, from all $992^2$ pairs). It predicts that along the Mersenne ladder the semiprime leak decays like $(\log n)/n^2$ — one extra factor of $1/n$ for the chance that a factor's badge is informative at all.

## Does this break cryptography?

No — and it is worth being clear about why. Everything here concerns a *fixed* polynomial, hence a fixed group. The leak about the residue of $N$ is a bounded number of bits, independent of how large $N$ is, whereas locating a prime factor of an $N$ with hundreds of digits requires a number of bits proportional to $\log N$. Worse for the would-be attacker, the quantity that leaks is a residue of the *product* $N$, which anyone holding $N$ already knows. The channel is a real mechanism — but it measures the wrong quantity for factoring. If anything, the Detector Law points the other way: the groups with the most room to leak are, among detectors, precisely the ones that leak least.

## Coda

There is something satisfying about a reversal that, once understood, could not have gone any other way. $\mathrm{AGL}(1,8)$ has more abelian room than any group that came before it, and yet its badges speak only one sentence: "trivial or not." The Detector Law turns that sentence into a number, $h(1/n)$, and the number shrinks as the room grows.

The broader conjecture now on the table is that this is a special case of a single principle: *the channel equals the entropy of whatever function of the coset the badge actually determines.* For the affine groups $\mathrm{AGL}(1,q)$ that function is the multiplicative order of the multiplier, and the conjecture becomes an explicit formula,

$$I_1 = \log_2(q-1) - \sum_{d \mid q-1} \frac{\varphi(d)}{q-1}\log_2 \varphi(d),$$

with $\varphi$ Euler's totient — already confirmed for $q = 5, 7, 8$, and numerically for every prime power $q$ up to $32$. The badge, it seems, always tells you exactly as much as it can see — and not a bit more.
