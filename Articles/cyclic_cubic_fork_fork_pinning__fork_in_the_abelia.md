# The Prime That Knows Its Own Shape

## Why some polynomials wear their secrets on their sleeve, and others hide them forever

Take a polynomial with integer coefficients — say $x^3 + x^2 - 2x - 1$ — and start feeding it prime numbers. Not as inputs, exactly: reduce the polynomial modulo a prime $p$ and ask how it factors in that finite world. Sometimes it splits into three linear pieces. Sometimes it stays stubbornly irreducible. Sometimes it breaks into a linear factor times a quadratic.

For the cubic above, something spooky happens. Feed it $p = 13$: it splits into three linear factors. Feed it $p = 29$: three factors again, and again at $p = 41$, $43$, $71$. Feed it $p = 11$, $17$, $19$, $23$, $31$: irreducible every time — not even a single root. Now look at those primes modulo $7$:

$$13 \equiv 6, \quad 29 \equiv 1, \quad 41 \equiv 6, \quad 43 \equiv 1, \quad 71 \equiv 1,$$
$$11 \equiv 4, \quad 17 \equiv 3, \quad 19 \equiv 5, \quad 23 \equiv 2, \quad 31 \equiv 3 \pmod 7 .$$

The splitters are exactly the primes congruent to $\pm 1$. Across the first $6541$ primes the rule holds with no exceptions whatsoever:

> $x^3+x^2-2x-1$ splits into three linear factors modulo $p$ **if and only if** $p \equiv \pm 1 \pmod 7$.

Every single prime obeys. A congruence — the crudest, most elementary thing you can say about a number — completely determines a delicate algebraic fact about how a cubic breaks apart.

Now take a different cubic, $x^3 + x + 1$. Ask the same question: when does it split into three linear factors? Search for a congruence rule. Try modulo $31$ (its discriminant). Try modulo $7$, $9$, $283$, anything you like. **There is no rule.** Not an approximate one, not a partial one: no modulus, however enormous, will ever tell you with certainty whether $x^3+x+1$ splits modulo $p$.

Two cubics. One transparent, one opaque. What separates them?

This article is about the answer, which turns out to be exact, provable, and information-theoretically sharp. It has a name: **the fork-pinning criterion**. And it says that the boundary between transparent and opaque polynomials is drawn by a single algebraic object — the *abelianization of the Galois group*.

---

## Forks: the yes/no questions of prime splitting

Fix a monic integer polynomial $f$ of degree $n$. For all but finitely many primes $p$, reducing $f$ mod $p$ yields a product of distinct irreducible factors, and the multiset of their degrees is the **splitting type** of $p$: a partition of $n$. For a cubic the possibilities are $[1,1,1]$ (totally split), $[1,2]$, and $[3]$.

A **fork** is any yes/no question about the splitting type. "Does $f$ split completely?" is a fork. "Does $f$ have at least one root mod $p$?" is a fork. "Is the number of irreducible factors even?" is a fork. Forks are the atoms of splitting behaviour; everything you might want to predict is built from them.

The prediction question is: *how much can a congruence tell you about a fork?* And the way to make "how much" precise is information theory. If $X$ is the residue $p \bmod m$ and $Y$ is the fork's answer, then the **mutual information** $I(X;Y)$ measures, in bits, how much learning $X$ tells you about $Y$. It sits between $0$ and the entropy $H(Y)$ of the fork itself. At the bottom, $I = 0$, the congruence is worthless: the fork is **flat**. At the top, $I = H(Y)$, the congruence settles the matter completely: the fork is **pinned**.

For $x^3+x^2-2x-1$, the fork "splits completely" has probability $1/3$, so its entropy is
$$H(1/3) = \log 3 - \tfrac{2}{3}\log 2 = 0.9183 \text{ bits},$$
and the measured mutual information with $p \bmod 7$ across those $6541$ primes is $0.9182$ bits. That is $100\%$ of the available entropy, to measurement precision. Pinned.

For $x^3+x+1$, the same fork has probability $1/6$, entropy $0.6500$ bits, and the measured mutual information with $p \bmod 31$ is $0.1906$ bits. Not zero — but not everything either. Where does the number $0.1906$ come from, and why does it stop there?

---

## The dictionary: primes become group elements

The bridge from primes to algebra is a nineteenth- and twentieth-century achievement, and it is what makes the whole question tractable.

Attach to $f$ its **splitting field** — the smallest field containing all its roots — and let $G$ be the group of symmetries of that field, the Galois group. $G$ acts on the $n$ roots, so it sits inside the permutation group $S_n$. Now the **Chebotarev density theorem** (1922) says: as $p$ ranges over the primes, the associated symmetry (the *Frobenius* element) behaves like a uniformly random element of $G$, and the splitting type of $p$ is precisely the cycle type of that element.

This is a stunning reduction. A question about infinitely many primes becomes a question about a *finite group with the uniform measure*. "What fraction of primes split completely?" becomes "what fraction of $G$ is the identity?" — namely $1/|G|$.

The second half of the dictionary concerns congruences. What is the group-theoretic shadow of "$p \bmod m$"? Class field theory answers: congruence conditions on $p$ see exactly the **abelian** characters of $G$, that is, homomorphisms $G \to A$ into commutative groups. Every such homomorphism kills all commutators $[g,h] = ghg^{-1}h^{-1}$, so all of them factor through the largest commutative quotient
$$G^{\mathrm{ab}} = G / [G,G],$$
the **abelianization**. Congruences are abelian eyes: they can only see the part of the Galois group that has been flattened out commutatively.

Now compare our two cubics.

* $x^3+x^2-2x-1$ is the real subfield of the seventh cyclotomic field. Its Galois group is the cyclic group $C_3$ — already commutative. Abelianizing does nothing: $G^{\mathrm{ab}} = G$. Congruences see *everything*.
* $x^3+x+1$ has Galois group $S_3$, whose commutator subgroup is the three-cycle subgroup $A_3$. So $G^{\mathrm{ab}} = S_3/A_3 = C_2$: congruences see only a single bit, the **sign** of the Frobenius permutation — classically, a Jacobi/Legendre symbol attached to the quadratic subfield $\mathbb{Q}(\sqrt{-31})$.

That is the whole story in one line.

> **The fork-pinning criterion.** A fork is congruence-pinned if and only if it factors through the abelianization of the Galois group; equivalently, if and only if it is invariant under multiplication by commutators.

If the fork can be computed from the abelianized Frobenius, some congruence pins it exactly. If it cannot, then *no* congruence ever pins it — not modulo $7$, not modulo $10^{100}$, not ever. There is no partial credit at the top: either the abelian shadow of the Galois group determines your question, or the question has irreducibly non-abelian content and stays forever undetermined by residues.

---

## Reading off the exact numbers

The criterion is qualitative, but the same framework gives exact values, and they match measurement to three or four decimal places.

**The cyclic cubic ($G = C_3$).** Every fork of an abelian Galois group is pinned, because the abelianization map is the identity. The totally-split fork has probability $1/3$ and
$$I = H = \log 3 - \tfrac23 \log 2 = 0.9183 \text{ bits} .$$
Two further facts sharpen the picture. Pinning survives at the larger modulus $49$, with $42$ residue classes and thousands of primes per class — so this is determinism, not a small-sample artifact. And at the coprime "control" modulus $5$, the measured information is $0.0000$ bits: the pinning lives specifically in the cubic-residue character of conductor $7$, not in congruences generically. The sister field $x^3-3x+1$ of conductor $9$ behaves identically: totally split $\iff p \equiv \pm 1 \pmod 9$, information $0.9181$ bits.

**The $S_3$ cubic.** Here the abelianization is $C_2$, so only one bit is visible, and it is the sign. The exact value of the mutual information between the sign and the totally-split fork is
$$I = \tfrac43\log 2 + \tfrac12 \log 3 - \tfrac56 \log 5 = 0.1909 \text{ bits},$$
against $0.1906$ measured. Better still, there is a clean structural identity: the fork's entropy is $0.6500$ bits, and
$$I = H(\text{fork}) - \tfrac12 H(1/3),$$
so exactly half of a cyclic-cubic's worth of entropy remains unresolved after the sign is known. The residue is not noise; it is the $A_3$ part of the group, permanently invisible to congruences. Restrict attention to the primes with the "right" sign — the quadratic-residue face — and ask the remaining question there, "totally split versus inert": the information is $0.0000$ bits. Perfectly flat, as the criterion demands.

**The quartic $x^4 - x - 1$ ($G = S_4$, discriminant $-283$).** Root counts for a uniformly random element of $S_4$ are $4, 2, 1, 0$ fixed points with probabilities $1/24, 6/24, 8/24, 9/24$ — a fact one can verify by direct enumeration and which the primes reproduce faithfully. The "has a root mod $p$" fork therefore has probability $15/24 = 5/8$ and entropy $0.9545$ bits. The sign character extracts
$$I = \tfrac32\log 2 - \tfrac58\log 5 = 0.0488 \text{ bits},$$
measured $0.0483$. Everything beyond that is flat: within the even face ($[1,1,1,1]$ vs $[2,2]$ vs $[1,3]$) and within the odd face ($[1,1,2]$ vs $[4]$), each fork's measured information equals its null-model mean to within a fraction of a standard deviation. **The sign is the only congruence structure in the whole $S_4$ splitting.** And there is a theorem behind that: on the commutator subgroup, every abelian character is constant, so its information with *any* fork is exactly zero.

Push this to its extreme and you get a striking phenomenon. A **perfect** group is one that equals its own commutator subgroup — $A_5$ is the smallest example. For such a Galois group the abelianization is trivial, every abelian character is constant, and *every* fork is flat. A degree-five polynomial with Galois group $A_5$ is completely congruence-blind: not one bit of its splitting behaviour is predictable from any residue class, ever.

---

## The moral of a failed experiment

A neat illustration of the criterion's force is a control experiment that went wrong. The natural "positive control" for this kind of study seemed to be $x^3 - 2$, the cubic defining $\mathbb{Q}(\sqrt[3]{2})$ — a field with class number $1$, unlike its cousins. Its fork came out flat, and for a while that looked like evidence against pinning.

But the splitting field of $x^3-2$ is $\mathbb{Q}(\sqrt[3]{2}, \sqrt{-3})$, with Galois group $S_3$, hence abelianization $C_2$. Its totally-split fork is not $C_2$-measurable, so it is flat *by construction* — the criterion predicted the failure in advance. Flatness is not about class numbers. Flatness is about the fork falling outside the abelianization. The correct positive control is any cyclic cubic, where the Galois group is already abelian, and there the fork pins at $100\%$.

---

## How much can a yes/no question ever be worth?

Once you have the criterion, a natural optimization question appears: what is the *most* a congruence can ever tell you about a binary fork? The answer is a hard ceiling of exactly one bit, and it is attained in a precisely characterizable way.

Two ingredients. First, a strict maximum-entropy statement: a two-valued statistic has entropy $\log 2$ if and only if it is perfectly balanced, and strictly less otherwise. Second, the general fact that mutual information never exceeds the entropy of either side. Combining:

> **The capacity theorem.** For any observable $X$ and any binary fork $Y$, $I(X;Y) \le \log 2$, with equality **if and only if** $X$ determines $Y$ *and* $Y$ is balanced.

For the symmetric group this becomes beautifully rigid. Among all binary forks of $S_n$ ($n \ge 2$), the sign character attains the one-bit capacity — and *only two forks do*: the sign itself and its negation. That is the exact formal counterpart of the empirical verdict on the $S_4$ quartic. The sign is not merely the best congruence-visible statistic; it is the unique one (up to swapping the labels) that saturates the channel.

There is a graded version too. Suppose the visible observable is a single balanced bit — an index-two conductor, like a quadratic character — and the fork you care about is rare, occurring with density $d \le 1/2$. Then the information is at most
$$\Phi(d) = h(d) - \tfrac12 h(2d), \qquad h(x) = -x\log x - (1-x)\log(1-x),$$
with equality exactly when the fork's support lies inside one coset of the visible bit. This profile $\Phi$ is strictly increasing on $[0,1/2]$, so rarer forks are strictly harder to pin — and it rises to the full $\log 2$ at $d = 1/2$. As $d \to 0$ the profile behaves like $d \log 2$, so the *absolute* information vanishes linearly, while the *fraction* of the fork's entropy that gets pinned, $\Phi(d)/h(d)$, tends to $0$. Rare events are asymptotically congruence-invisible even when they are entirely contained in one coset.

---

## Why this does not factor your integers

Every result above is about a *single* prime, and it is tempting to imagine a cryptographic payoff. Suppose you have a semiprime $N = pq$ with unknown factors, and a cyclic cubic field whose fork is pinned at $100\%$. You know $N \bmod 7$. What does that tell you?

You know the *product* of the two Frobenius classes, not the classes themselves. The observable becomes the class of $N$; the fork becomes "$p$ splits OR $q$ splits". A short calculation gives the conditional probabilities: for the conductor-$7$ cyclic cubic, $P(\text{OR} \mid N \bmod 7) = 1/3$ on the classes $\{1,6\}$ and $2/3$ on $\{2,3,4,5\}$ — and the information is
$$I(N \bmod 7 ; \text{OR}) = \log 3 - \tfrac59 \log 5 - \tfrac29 \log 2 = 0.0728 \text{ bits},$$
against $0.0718$ measured. A fork pinned at $100\%$ at the prime level collapses to a $0.073$-bit symmetric dial at the semiprime level.

Three theorems explain why this is a wall and not a speed bump.

**The universal dial.** For *any* finite group of order $n$, the semiprime-level information takes one closed form depending on $n$ alone. This is not a special feature of $C_3$; every conceivable Galois group is on the same curve.

**The collapse rate.** That curve decays quadratically: the information is at most $\frac{1}{(2n-1)(n-1)}$, and multiplying by $n^2$ gives a limit,
$$n^2 I(n) \longrightarrow 1 - \log 2 = 0.3069\ldots,$$
with $n^2 I(n) < 1$ for every $n$. So there is a universal budget: no matter how large or exotic the Galois group, the semiprime dial carries less than $1/n^2$ nats.

**The which-factor wall.** Worst of all for the would-be factorizer, the information is *symmetric junk*. For any statistic $F$ whatsoever depending on the first factor alone, the information between the class of $N$ and $F$ is **exactly zero** — not small, zero — because the product of a fixed element with a uniform element is uniform. Knowing $N$'s class tells you literally nothing about which of the two factors did what. And this survives to products of $k$ factors: the class of $p_1 \cdots p_k$ is independent of *any* statistic of the first $k-1$ factors. The measured which-factor information was $0.0001$ bits, consistent with zero.

So the sequence of barriers is complete: a perfect prime-level oracle becomes a $0.07$-bit hint at the semiprime level, that hint decays like $1/n^2$, and it is provably blind to which factor is which. All of the ingredients — cubic reciprocity, cyclotomic fields, Chebotarev, Artin's reciprocity law — are classical, and none of them opens a door.

---

## What the criterion really says

Strip away the number theory and a general principle remains, one that applies wherever a random group element hides behind a commutative measurement.

*Abelian observations see abelian quotients.* Any measurement channel that factors through a commutative group is blind, by construction, to everything inside the commutator subgroup. Whether your question is answerable is not a matter of effort or cleverness or bigger computations: it is a matter of whether the question is a function on the abelianization.

And the abelianization is *optimal* in a precise sense. Every abelian character's information about a fork is bounded by the abelianization map's, because each character factors through it, and post-processing can only destroy information. Moreover, equality for all forks holds exactly when the character's kernel is the commutator subgroup — nothing more, nothing less. The abelianization is not one good observable among many; it is the canonical best one, and any character with a bigger kernel provably loses information on some fork.

Two cubics, then. One whose Galois group had nothing to hide, and one whose secrets lived in a commutator. The primes were telling the truth all along; we just needed to know which eyes could see it.
