# The Shadow of a Measurement

## What survives when an infinitely precise instrument reports back to a finite world

Imagine an experimentalist whose apparatus is not merely very good but *infinitely* good — a device whose readings are accurate to within a quantity smaller than $1/2$, smaller than $1/100$, smaller than $1/n$ for **every** whole number $n$, yet not exactly zero. Such quantities are not a fantasy. They are the *infinitesimals* of the hyperreal number system $\mathbb{R}^*$, a rigorous extension of the real line that contains all the ordinary numbers plus new ones: infinitesimals $\varepsilon$ with $0 < \varepsilon < 1/n$ for all $n$, and their reciprocals $\omega = 1/\varepsilon$, which are larger than every integer.

Now imagine the reverse situation: *we* are the finite ones. We can only read off real numbers. When the infinitely precise instrument hands us a number $x$ that is not infinitely large, there is exactly one real number infinitely close to it — its **standard part**, written $\mathrm{st}(x)$. The standard part is the shadow that a hyperreal number casts on the real line. It sees $3 + \varepsilon$ and reports $3$. It sees $\varepsilon$ and reports $0$. Confronted with $\omega$, it has nothing to say at all: no real number is infinitely close to an infinite one.

This article is about a single question, asked in the setting of matrices rather than numbers:

> **Which algebraic structures survive the passage into shadow?**

The specific structure at stake is the one that encodes a measurement.

---

## Measurements as families of projections

In linear algebra and quantum theory, an idealized measurement with finitely many outcomes is a **projection-valued measure**: a family of square matrices $Q_1, \dots, Q_m$ on $\mathbb{R}^n$, one per possible outcome, satisfying three identities:

$$Q_a Q_a = Q_a \quad\text{(each is a projection)},$$
$$Q_a Q_b = 0 \ \text{ for } a \ne b \quad\text{(distinct outcomes are exclusive)},$$
$$Q_1 + \cdots + Q_m = I \quad\text{(some outcome always occurs)}.$$

Geometrically, such a family slices $\mathbb{R}^n$ into complementary pieces: each $Q_a$ projects onto a subspace $V_a$, distinct pieces meet only at the origin, and together they fill the space. Physically, $Q_a$ is the "yes" answer to the question "did outcome $a$ occur?"

Real experiments do not satisfy these identities on the nose. Detectors leak, channels overlap slightly, the total efficiency is $0.9999$ rather than $1$. The idea explored here is to model that slack **exactly** rather than statistically: let the entries of the matrices be hyperreal, and demand the identities only up to infinitesimals. Call a family $P_1, \dots, P_m$ of hyperreal matrices an **approximate projection-valued measure** if

1. no entry of any $P_a$ is infinite,
2. every entry of $P_a P_b$ is infinitesimal for $a \ne b$, and
3. every entry of $P_1 + \cdots + P_m - I$ is infinitesimal.

Condition (1) says the instrument has bounded dynamic range; conditions (2) and (3) say exclusivity and completeness hold within the instrument's resolution — the errors are real, but below the threshold of anything the finite world can see.

The **observation map** takes such a family to its shadow: replace every entry by its standard part. Write $\mathrm{st}(A)$ for the real matrix obtained from a hyperreal matrix $A$ this way.

---

## The Descent Theorem

Here is the central result.

> **Descent Theorem.** Let $P_1, \dots, P_m$ be hyperreal $n \times n$ matrices, none of whose entries is infinite. Then the real matrices $\mathrm{st}(P_1), \dots, \mathrm{st}(P_m)$ form a genuine projection-valued measure **if and only if** $P_a P_b$ is entrywise infinitesimal for all $a \ne b$ and $P_1 + \cdots + P_m$ is entrywise infinitesimally close to the identity.

Both directions matter, and both are somewhat surprising.

The "if" direction says that infinitesimal violations of the measurement axioms are *invisible*. A leaky detector whose cross-talk is below every finite threshold is observed as a perfect detector. Nothing needs to be repaired, renormalized, or idealized; the shadow of the flawed apparatus is flawless.

The "only if" direction says the converse: if the shadow is a perfect measurement, the original *must* have been infinitesimally perfect. There is no way to be visibly wrong and invisibly right. The shadow is a faithful witness.

The engine of the proof is a small but decisive fact: on matrices with no infinite entries, the entrywise standard part is a *ring homomorphism*. It respects sums, and — this is the point — it respects products:

$$\mathrm{st}(AB) = \mathrm{st}(A)\,\mathrm{st}(B).$$

The reason is that each entry of $AB$ is a finite sum of products of finite hyperreals, and the standard part of a sum of finite numbers is the sum of the standard parts, while the standard part of a product of finite numbers is the product of the standard parts. Every polynomial identity in matrix algebra therefore passes through the shadow untouched. Idempotency, orthogonality, and completeness are all polynomial identities. That is the whole of the "if" direction, and running the equivalence backwards — a matrix with finite entries is entrywise infinitesimal exactly when its shadow is zero — gives the "only if" direction.

---

## The hypothesis that wasn't needed

Look again at the definition of an approximate projection-valued measure. There are three conditions, and the *first* of the three projection axioms, idempotency $P_a^2 \approx P_a$, is conspicuously missing.

It is missing because it is free.

> **Redundancy of Idempotency.** Approximate exclusivity and approximate completeness already force $P_a P_a$ to be infinitesimally close to $P_a$, for every $a$.

The argument, once you see it in the shadow, is two lines. If $Q_1 + \cdots + Q_m = I$ and $Q_a Q_b = 0$ for $a \ne b$, then
$$Q_a = Q_a I = Q_a(Q_1 + \cdots + Q_m) = Q_a Q_a,$$
because every cross term vanishes. Multiplying the completeness relation on the left by $Q_a$ annihilates everything but the diagonal term. This means the hypothesis list in the Descent Theorem is *minimal*: nothing can be dropped, and nothing that could have been assumed was assumed.

---

## Where it breaks: infinite entries

The finiteness condition on the entries — the one that looked like technical hygiene — turns out to be the only thing standing between the theorem and its collapse. Both directions fail without it, and the counterexamples are small enough to check by hand.

**Against "if":** consider the $2 \times 2$ hyperreal matrix

$$P = \begin{pmatrix} 2 & \omega \\ -2/\omega & -1 \end{pmatrix}.$$

Multiply it by itself. The top-left entry becomes $4 + \omega \cdot (-2/\omega) = 4 - 2 = 2$; the other three entries work out identically. So $P^2 = P$ **exactly** — not approximately, exactly. The pair $(P,\ I - P)$ is then an exactly idempotent, exactly orthogonal, exactly complete family: a flawless hyperreal measurement. But its shadow is

$$\mathrm{st}(P) = \begin{pmatrix} 2 & 0 \\ 0 & -1 \end{pmatrix},$$

since $\mathrm{st}(\omega)$ is undefined-as-a-limit and, by the convention that infinite quantities are sent to $0$ by the standard part, is discarded. And this matrix squares to $\mathrm{diag}(4,1)$, not to itself. A perfect measurement casts an imperfect shadow. The single infinite entry $\omega$ conspired with the infinitesimal entry $-2/\omega$ to produce a finite contribution, $-2$, which the shadow map — acting entry by entry — throws away.

**Against "only if":** work with $1 \times 1$ matrices, i.e. numbers, and take the family $(1, \omega)$. Its shadow is $(1, 0)$, which is a perfectly good projection-valued measure on the one-dimensional space. Yet the product of the two members is $1 \cdot \omega = \omega$, about as far from infinitesimal as a number can be.

Together these two examples pin the theorem down exactly. The failure mode is not vagueness or approximation; it is *dynamic range*. The observation map is blind to infinitesimal error and catastrophically discontinuous at infinite magnitude.

---

## Quantization out of nowhere

Now something genuinely striking. Attach to each channel $P_a$ its **observed weight**: the standard part of its trace, the shadow of the sum of its diagonal entries.

> **Dimension Quantization.** For any approximate hyperreal projection-valued measure, each observed weight is a *natural number* — namely the rank of the observed projection $\mathrm{st}(P_a)$ — and the weights sum exactly to $n$, the dimension of the space.

The traces $\mathrm{tr}(P_a)$ themselves are hyperreal and can be anything at all in the halo: $1 + \varepsilon$, $2 - 3\varepsilon^2$, $0 + \varepsilon$. Observation snaps them to integers. The reason is that a real idempotent matrix has trace equal to its rank — the trace of a projection counts the dimension of the subspace it projects onto — and completeness makes those dimensions add up to $n$.

This is quantization in the literal sense: a continuum of possible pre-observation values collapses onto a discrete lattice, and the lattice is forced by nothing more exotic than the fact that dimensions are whole numbers. A non-Archimedean measurement can be as fuzzy as it likes; what a real observer sees is always an honest splitting of $\mathbb{R}^n$ into a direct sum of subspaces, with integer dimensions summing to $n$. Indeed the observed subspaces are independent and span the whole space, so observation delivers an internal direct sum decomposition
$$\mathbb{R}^n = V_1 \oplus V_2 \oplus \cdots \oplus V_m, \qquad \dim V_1 + \cdots + \dim V_m = n.$$

---

## Rigidity: the approximate world is a thin skin on the exact one

Is the hyperreal theory actually richer than the real one, or is it an elaborate re-labelling? Both, in a precise sense.

It *is* richer. Take the two-channel family
$$P_1 = \begin{pmatrix} 1 & \varepsilon \\ 0 & 0\end{pmatrix}, \qquad P_2 = \begin{pmatrix} 0 & 0 \\ 0 & 1 \end{pmatrix}.$$
Then $P_1 P_2 = \begin{pmatrix} 0 & \varepsilon \\ 0 & 0\end{pmatrix} \ne 0$ and $P_1 + P_2 = \begin{pmatrix} 1 & \varepsilon \\ 0 & 1\end{pmatrix} \ne I$. This is a bona fide approximate measurement that is not an exact one, so the approximate class is strictly larger.

And yet it is a *thin* enlargement:

> **Rigidity Theorem.** Every approximate hyperreal projection-valued measure with finite entries lies entrywise infinitesimally close to an **exact** hyperreal projection-valued measure — one satisfying all three identities on the nose.

The exact model is not obtained by any clever perturbation argument. It is simply the shadow, lifted back up: observe the family, then re-read the resulting real matrices as hyperreal ones. Because the shadow map is multiplicative, the lifted family inherits the exact identities, and because lifting inverts observing, it sits in the same infinitesimal halo. If the original family is approximately symmetric, the exact model can be taken symmetric too, giving an exact *orthogonal* resolution of the identity. And the model is unique among lifted families: two real families whose lifts are infinitesimally close are equal.

So the picture is complete. Observation is onto — every real projection-valued measure is the shadow of a hyperreal one. Its fibres are exactly the infinitesimal halos — two families are observed identically precisely when they are infinitesimally close. And every halo containing an approximate measurement also contains an exact one. The approximate theory is the exact theory wearing an infinitesimally thin coat.

---

## Merging channels, and the price in entropy

Real detectors coarse-grain: two adjacent bins get lumped into one. Formally, given a map $f$ from the fine index set to a coarse one, the merged channels are $Q'_k = \sum_{f(a) = k} Q_a$. Merging preserves the measurement axioms — the coarse family is again a projection-valued measure — and it is compatible with observation, so a hyperreal approximate measurement can be coarse-grained before or after observing, with the same result.

This has a spectral consequence. If a hyperreal operator decomposes as $\sum_a \lambda_a P_a$ with finite eigenvalues $\lambda_a$, its shadow is $\sum_a \mathrm{st}(\lambda_a)\,\mathrm{st}(P_a)$, and eigenvalues that differ only infinitesimally are merged into a *single* observed spectral line, with the corresponding projections summed. **Infinitesimally split spectral lines are unresolvable in principle**, and what the finite observer sees is automatically the coarse-grained decomposition.

Merging costs information, and the cost is exactly quantifiable. Given a real unit vector $v$, the **Born weight** of channel $a$ is $p_a = v^\top Q_a v$; these are nonnegative when the projections are symmetric and sum to $1$, so they form a genuine probability distribution over outcomes. Its Shannon entropy $H = \sum_a -p_a \log p_a$ then obeys:

> **Entropy Monotonicity.** Coarse-graining never increases the observed entropy: $H(\text{merged}) \le H(\text{fine})$. The inequality is *strict* as soon as two distinct channels of positive weight are merged, and equality holds **exactly** when no two distinct channels of nonzero weight are merged.

The engine is a pointwise estimate rather than any deep convexity: if $0 \le p \le S$ then $-p \log p \ge -p \log S$, because $\log$ is increasing; summing this over a fibre and comparing with $-S \log S$ gives the result, with strictness whenever some $p$ in the fibre is strictly less than $S$ and positive.

---

## What is observable?

Step back and the answer to the opening question is sharp.

An infinitely precise instrument reporting into a finite world transmits exactly one thing: **an integral orthogonal decomposition of the real space, together with a probability distribution on its pieces.** Infinitesimal violations of the measurement axioms — leaky channels, sub-threshold cross-talk, an efficiency that misses $1$ by an unmeasurable amount — are perfectly invisible; the shadow repairs them for free, and it does so *only* if they were infinitesimal to begin with. Infinitesimally separated eigenvalues are fused into a single line. Continuous spectral weights are snapped to integers.

What is *not* invisible is infinite magnitude. A single entry of unbounded size can smuggle a finite quantity through a product and break the correspondence entirely — in either direction. Boundedness of the instrument, not exactness of its calibration, is the real hypothesis.

There is a temperament here worth naming. Non-standard analysis is often sold as a way to make limits look like algebra. What happens in this circle of results is closer to the opposite: an *algebraic* structure — three polynomial identities among matrices — is subjected to a map that is emphatically not algebraic, the collapsing of an entire halo of hyperreal numbers to a single real one, and one asks what makes it through. The answer, cleanly, is: everything polynomial, provided nothing is infinite. That is a small theorem with a large moral. The identities defining a measurement are robust in the strongest possible sense, and the only thing that can break them is a quantity too large for the observer to hold.
