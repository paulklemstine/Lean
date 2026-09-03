# The Polynomial That Refuses to Vanish

## How a two-thousand-year-old fact about polynomials made deep-space photographs, DVDs, and QR codes possible

In September 1977, Voyager 1 left Earth carrying a camera, a golden record, and a problem. By the time it reached Saturn its radio signal arrived at Earth with a power of roughly $10^{-16}$ watts — a whisper against a background of cosmic noise. Bits would flip. Not occasionally: constantly. And there would be no second chance to ask for a retransmission, because a round-trip to Saturn takes hours and the spacecraft would already have moved on.

The solution NASA flew was a family of codes discovered in 1960 by Irving Reed and Gustave Solomon, then at MIT's Lincoln Laboratory. Their idea occupies about one paragraph, and it is exactly optimal — not "good in practice", not "close to optimal", but provably at the theoretical ceiling, with equality. This article explains the idea, states the theorems precisely, and sketches why they are true.

---

## The problem, stated honestly

You want to send $k$ symbols. The channel will corrupt some of them. So you send $n > k$ symbols instead, chosen so that the original $k$ can be recovered even after damage. The $n - k$ extra symbols are the *redundancy*, and the whole design question is: **how much protection can you buy with $n - k$ extra symbols?**

To make the question sharp we need to say what "protection" means. Fix a finite alphabet $F$ — for us, always a *field*: a set where you can add, subtract, multiply, and divide, like the integers modulo a prime $p$, or the 256-element field $\mathbb{F}_{256}$ that underlies every QR code. A **code** $C$ is a set of allowed strings ("codewords") of length $n$ over $F$. The **Hamming distance** $d(x,y)$ between two strings is the number of positions in which they differ, and the **Hamming weight** $\mathrm{wt}(x)$ is the number of nonzero entries of $x$ — the distance from $x$ to the all-zero string.

The single number that governs everything is the **minimum distance**
$$d = \min\{\, d(x,y) : x, y \in C,\ x \neq y \,\}.$$
If the minimum distance is $d$, then no pattern of $d-1$ or fewer errors can turn one codeword into another, so any $d-1$ *erasures* (positions known to be corrupted) can be filled back in, and any $t$ errors with $2t < d$ can be corrected: the true codeword is the unique one within distance $t$ of what you received. Distance is protection. You want it large.

We restrict to **linear** codes, where $C$ is a vector subspace of $F^n$. This is not a serious loss — almost every code used in practice is linear — and it buys a simplification: for a linear code, $d(x,y) = \mathrm{wt}(x-y)$ and $x - y$ is itself a codeword, so the minimum distance is just the smallest weight of a *nonzero* codeword. A linear code of length $n$, dimension $k$ (so with $|F|^k$ codewords), and minimum distance $d$ is called an $[n,k,d]$ code.

## The ceiling: you cannot have everything

Here is the fundamental limitation, and it has a one-line proof.

> **Singleton Bound.** Let $C \subseteq F^n$ be a linear code in which every nonzero codeword has weight at least $d$, with $1 \le d \le n$. Then
> $$\dim C + d \le n + 1.$$

*Why.* Delete $d-1$ coordinates from every codeword — say you keep a set $S$ of $n - d + 1$ positions and throw the rest away. This "puncturing" map is linear. Could two distinct codewords collide? If they did, their difference would be a nonzero codeword vanishing on all of $S$, hence supported on the $d-1$ deleted positions, hence of weight at most $d-1$ — contradicting the assumption. So puncturing is *injective*, and an injective linear map cannot increase dimension:
$$\dim C \le \dim F^S = n - d + 1. \qquad \blacksquare$$

Read the bound as an economic statement: *rate plus distance is capped*. Each unit of minimum distance costs you exactly one dimension of message space. A code that meets the bound with equality — $d = n - k + 1$ — is called **MDS**, for *maximum distance separable*: for its length and dimension, no code on earth has larger minimum distance.

(A cautionary note on the hypotheses, which matters more than it looks. If one drops the assumption $d \le n$, the statement is false: the zero code $C = \{0\}$ has *no* nonzero codewords at all, so "every nonzero codeword has weight $\ge d$" holds vacuously for every $d$, including $d = n + 5$, while $\dim C = 0$. The hypothesis $d \le n$ is harmless in practice — it is automatic the moment a nonzero codeword exists — but it must be there.)

MDS codes are the extremal objects of coding theory. Do any exist?

## Reed and Solomon's answer: use polynomials

Here is the construction, in full.

Fix a field $F$, an integer $k \ge 1$, and $n \ge k$ **distinct** points $\alpha_0, \alpha_1, \dots, \alpha_{n-1}$ in $F$. Take as your message space
$$P_{<k} = \{\, p \in F[X] : \deg p < k \,\},$$
the polynomials of degree less than $k$. This is a vector space of dimension exactly $k$, with the obvious basis $1, X, X^2, \dots, X^{k-1}$ — a message is just a list of $k$ coefficients.

The **encoder** is evaluation:
$$E(p) = \bigl(p(\alpha_0),\ p(\alpha_1),\ \dots,\ p(\alpha_{n-1})\bigr) \in F^n .$$
The **Reed–Solomon code** $\mathrm{RS}_k(\alpha)$ is the set of all such evaluation vectors.

That's it. A message is a polynomial; the codeword is a table of its values. Think of it as an over-determined graph: to pin down a line you need two points, but you send ten, and the receiver can still find the line even if three of the ten points are wrong.

The encoder is linear, because $(p+q)(\alpha) = p(\alpha) + q(\alpha)$ and $(cp)(\alpha) = c\, p(\alpha)$. So the code is a subspace, and three theorems follow.

## Theorem 1: the dimension is exactly $k$

> **Dimension.** If the $\alpha_i$ are distinct and $k \le n$, the evaluation map $E$ is injective, so $\dim \mathrm{RS}_k(\alpha) = k$.

*Why.* Suppose $E(p) = 0$, i.e. $p$ vanishes at all $n$ distinct points $\alpha_0, \dots, \alpha_{n-1}$. If $p$ were nonzero, it would have degree at most $k - 1 \le n - 1$, yet $n$ distinct roots. A nonzero polynomial over a field has at most $\deg p$ roots. Contradiction; so $p = 0$. $\blacksquare$

No information is lost: nothing collapses, and the code carries exactly the $k$ symbols you paid for. The rate is $k/n$, as advertised.

## Theorem 2: every nonzero codeword is heavy

> **Root-counting bound.** If the $\alpha_i$ are distinct and $1 \le k \le n$, then every nonzero codeword $c \in \mathrm{RS}_k(\alpha)$ satisfies
> $$\mathrm{wt}(c) \ge n - k + 1 .$$

*Why.* Write $c = E(p)$ with $p \neq 0$ and $\deg p \le k - 1$. The zero coordinates of $c$ are exactly the evaluation points at which $p$ vanishes. Distinct points give distinct roots, and $p$ has at most $k-1$ roots, so at most $k-1$ coordinates of $c$ are zero. Hence at least $n - (k-1) = n - k + 1$ coordinates are nonzero. $\blacksquare$

This is the entire content of the Reed–Solomon miracle, and it is a fact about polynomials that Descartes would have recognized: *a low-degree polynomial cannot vanish very often*. Everything else is bookkeeping.

## Theorem 3: MDS, with equality

Combine the two directions. Theorem 2 says the minimum distance is at least $n-k+1$. The Singleton Bound, applied to a code of dimension $k$ (Theorem 1), says it is at most $n-k+1$. Squeeze:

> **Reed–Solomon codes are MDS.** For distinct $\alpha_i$ and $1 \le k \le n$, the minimum distance of $\mathrm{RS}_k(\alpha)$ is exactly
> $$d = n - k + 1, \qquad\text{equivalently}\qquad \dim \mathrm{RS}_k(\alpha) + d = n + 1 .$$

The bound isn't merely approached; it is *hit*. And one can exhibit a codeword achieving it. Pick any $k-1$ of the evaluation points, say indexed by a set $T$, and form
$$p_T(X) = \prod_{i \in T} \bigl(X - \alpha_i\bigr).$$
Its degree is exactly $k - 1 < k$, so it is a legal message, and its evaluation vector vanishes precisely at the $k-1$ points of $T$ and nowhere else. Weight: exactly $n - k + 1$. The extremal codeword is not exotic — it is the most obvious polynomial you could write down.

## What optimality buys: any $k$ coordinates are enough

MDS-ness has a striking reformulation, and the equivalence goes both ways.

> **Information-set characterization.** Let $C \subseteq F^n$ be a linear code of dimension $k$. Then every nonzero codeword of $C$ has weight $\ge n-k+1$ **if and only if** for every set $S$ of $k$ coordinates, the restriction map $C \to F^S$ is a bijection.

*Why, forward.* Restriction to $S$ is injective for the same puncturing reason as before: a codeword vanishing on $S$ is supported on the other $n - k$ coordinates, so has weight $\le n-k$, so is zero. An injective linear map between spaces of equal dimension $k$ is a bijection.

*Why, backward.* Suppose some nonzero codeword $c$ has weight $\le n - k$. Then $c$ vanishes on at least $k$ coordinates; choose $k$ of them as $S$. Restriction to $S$ kills $c \ne 0$, so it is not injective. $\blacksquare$

Every set of $k$ coordinates is an **information set**. This is a remarkable robustness statement: *you may lose any $n-k$ symbols you like, and the message survives*. For Reed–Solomon codes the bijection is nothing but Lagrange interpolation — given values at any $k$ of the $\alpha_i$, there is exactly one polynomial of degree $< k$ hitting them. The classical interpolation theorem and the optimality of the code are the same theorem wearing different clothes.

Two practical corollaries drop out immediately.

- **Erasure correction.** Two Reed–Solomon codewords agreeing on any $k$ coordinates are equal. So a receiver that knows *which* $n-k$ symbols were lost can restore them, always.
- **Unique decoding.** If $2t < n - k + 1$, no received word lies within Hamming distance $t$ of two different codewords. Indeed if $c_1, c_2$ were both within $t$ of $y$, the triangle inequality would give $\mathrm{wt}(c_1 - c_2) = d(c_1,c_2) \le 2t < n-k+1$, contradicting Theorem 2. So up to $t = \lfloor (n-k)/2 \rfloor$ *unknown* errors are uniquely correctable. Errors cost twice as much as erasures — you pay once to locate the damage and once to repair it.

That last sentence is the design rule behind every storage system you have used. A CD's error correction is layered Reed–Solomon; the outer layer is a $[32,28]$ code, and $\lfloor(32-28)/2\rfloor = 2$: two arbitrary bad bytes per block, repaired invisibly. Scale that up with interleaving and a 2 mm scratch becomes a burst of erasures spread thin across many blocks — each block loses only a symbol or two, each block repairs itself.

## The mirror world: duality

Every linear code $C \subseteq F^n$ has a **dual**
$$C^\perp = \Bigl\{\, y \in F^n : \sum_{i} y_i c_i = 0 \ \text{ for all } c \in C \,\Bigr\},$$
the set of linear "checks" that every codeword satisfies. Standard linear algebra gives $\dim C + \dim C^\perp = n$; in coding language, a code of dimension $k$ is cut out by exactly $n-k$ independent parity checks. For Reed–Solomon that means $\dim \mathrm{RS}_k(\alpha)^\perp = n - k$.

What is the *distance* of the dual? For a general code, nothing forces it to be good. For an MDS code, it is forced to be perfect.

> **MDS duality.** If $C$ has dimension $k$ and every nonzero codeword has weight $\ge n-k+1$, then every nonzero $y \in C^\perp$ has weight $\ge k+1$. Consequently, for $1 \le k < n$ the dual Reed–Solomon code is an $[n,\,n-k,\,k+1]$ code — again exactly MDS, since $n - (n-k) + 1 = k+1$.

*Why.* Suppose a dual codeword $y \ne 0$ had weight at most $k$. Enlarge its support to a set $T$ of exactly $k$ coordinates, and pick a coordinate $j$ with $y_j \neq 0$. By the information-set theorem, restriction of $C$ to $T$ is *surjective*, so there is a codeword $c \in C$ whose restriction to $T$ is the indicator vector of $j$: it equals $1$ at $j$ and $0$ at the other coordinates of $T$. Now compute the pairing. Since $y$ vanishes outside $T$,
$$0 = \sum_{i} y_i c_i = \sum_{i \in T} y_i c_i = y_j \cdot 1 = y_j \ne 0,$$
a contradiction. $\blacksquare$

The whole tower is visible in this proof: duality rests on information sets, which rest on the weight bound and the dimension count, which rest on "a degree-$(k-1)$ polynomial has at most $k-1$ roots."

## A code you can hold in your hand

Take $F = \mathbb{Z}/5\mathbb{Z}$, the integers mod 5, evaluation points $0,1,2,3,4$, and $k = 3$. Messages are quadratics $a_0 + a_1X + a_2X^2$; there are $5^3 = 125$ of them, encoded as their value tables of length 5. The theorems predict a $[5,3,3]$ code with a $[5,2,4]$ dual, and that is exactly what it is: dimension $3$, minimum distance $3$ (so one arbitrary error is correctable, or two erasures), dual dimension $2$, dual distance $4$.

Concretely, $p(X) = X^2 + 1$ encodes to $(1,2,0,0,2)$ — weight $3$, minimum weight, and indeed $X^2 + 1 = (X-2)(X-3)$ mod $5$, a product of two linear factors exactly as the extremal-codeword recipe predicts with $k-1 = 2$.

## The shape of the argument

Step back and the whole theory is a two-sided squeeze, an argument pattern that recurs throughout mathematics whenever something turns out to be exactly optimal.

- One side is an **upper bound on all codes** — the Singleton bound — proved by deleting coordinates and counting dimensions. Pure linear algebra; no polynomials, no field structure beyond a field.
- The other side is a **lower bound on one construction** — root counting — proved by the fundamental fact that a nonzero polynomial of degree $m$ has at most $m$ roots. Pure algebra; no coding theory.

Neither side knows about the other. They meet, and the meeting is exact. The construction did not have to be optimal; it is, and the reason is that the two counting problems — "how many coordinates can I delete?" and "how many roots can a polynomial have?" — are secretly the same problem, both governed by the number $k$.

## Where this shows up

Reed–Solomon codes are, plausibly, the single most-deployed piece of abstract algebra in history. They are in CDs, DVDs, and Blu-ray discs; in QR codes (which come in four redundancy levels, letting a logo cover a corner of the code without harming it); in RAID-6 disk arrays and in the erasure coding of essentially every large cloud storage system, where files are split into $k$ shards and stored as $n$, tolerating any $n-k$ dead drives; in DSL and digital television; in DNA data storage; and in the deep-space missions that started the story.

They are also having a second life in cryptography. The information-set property is exactly Shamir's secret sharing: distribute the values $p(\alpha_i)$ of a random degree-$(k-1)$ polynomial with secret constant term, and any $k$ shareholders can interpolate the secret while any $k-1$ learn literally nothing, since their values are consistent with every possible secret. And modern succinct proof systems — the machinery behind verifiable computation and blockchain rollups — rest on "low-degree testing": the observation, which is precisely Theorem 2 read backwards, that two distinct low-degree polynomials must disagree at almost every point, so a handful of random spot checks certifies a polynomial identity.

Sixty-five years after Reed and Solomon's four-page paper, the reason all of this works remains a single sentence: **a polynomial of degree less than $k$ that isn't zero cannot be zero more than $k-1$ times.** Everything else — the optimality, the duality, the decoding radius, the photographs of Saturn — is a consequence.
