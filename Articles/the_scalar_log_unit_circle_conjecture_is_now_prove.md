# The One Point on a Vertical Line

## How a single transcendental number ties the complex logarithm to the geometry of quantum gates

### A line, a logarithm, and a circle

Start with something you can draw on a napkin. In the complex plane, mark the point $1$, and then draw the vertical line through it: the set of all numbers of the form
$$1 + t\,i, \qquad t \in \mathbb{R}.$$

Now apply the complex logarithm to every point of that line. The logarithm bends the line into a curve — a graceful arc that passes through the origin when $t = 0$ and spirals outward in both directions. The natural question, once you have drawn the picture, is: **where does that curve cross the unit circle?**

Written out, the question is disarmingly concrete. The principal logarithm of $1 + ti$ splits into a real part and an imaginary part,
$$\log(1 + ti) \;=\; \tfrac{1}{2}\log\!\left(1 + t^{2}\right) \;+\; i\,\arctan t,$$
so the crossing condition $|\log(1+ti)| = 1$ becomes the equation
$$\left(\frac{\log(1+t^{2})}{2}\right)^{2} + \arctan(t)^{2} \;=\; 1.$$

Two of the most familiar transcendental functions in mathematics, the logarithm and the arctangent, are here asked to conspire to produce exactly $1$. There is no algebraic manipulation that will hand you the answer. And yet the answer exists, it is unique among positive numbers, and — this is the main news — it can now be pinned inside an interval so narrow that you could not draw the difference:
$$t^{\star} \in \left[\tfrac{6}{5},\ \tfrac{5}{4}\right] = [1.2,\ 1.25].$$

Numerically, $t^{\star} = 1.22903756\ldots$. But numerics is not proof, and the point of this story is that everything below is proved, with explicit rational certificates, from first principles.

### Why anyone should care: the shape of a quantum gate

The vertical line $1 + ti$ is not an arbitrary curiosity. It is the trace of a very natural operation. In quantum information, the states of a system live in a complex vector space, and the operations you are allowed to perform — the *gates* — are **unitary**: they preserve lengths and angles, exactly as rotations do in ordinary space. Every quantum circuit is a product of unitaries.

Now here is the connection. A unitary transformation of a single complex dimension is just multiplication by a complex number of modulus one, $e^{i\alpha}$. A number sitting exactly on the unit circle. So the question "when does $\log(1 + ti)$ land on the unit circle?" is, in disguise, the question: *for which parameter $t$ is the logarithm of the shifted point $1 + ti$ itself a legitimate one-dimensional quantum phase?*

The shift by $1$ is the fingerprint of an activation-style nonlinearity — the same "add one, then take a logarithm" motif that appears whenever a multiplicative signal is converted into an additive one. What we are asking is when that conversion produces something a quantum machine can use as a gate. The answer, we now know: **exactly once for positive parameters, at $t^{\star} \approx 1.229$, and by symmetry exactly once for negative ones, at $-t^{\star}$.**

### The mechanics of the argument

Let us write
$$R(t) \;=\; \bigl|\log(1 + ti)\bigr|$$
for the *scalar logarithmic radius*. The whole analysis lives in one clean identity, which is the first result of this work.

> **Closed form.** For every real $t$,
> $$R(t)^{2} \;=\; \left(\frac{\log(1+t^{2})}{2}\right)^{2} + \arctan(t)^{2}.$$

This follows because the modulus of $1 + ti$ is $\sqrt{1+t^{2}}$ and its argument is $\arctan t$; the principal logarithm converts modulus into real part (via a logarithm) and argument into imaginary part directly.

Once you see the closed form, the qualitative picture becomes transparent. On $t \geq 0$ both summands are nonnegative and both are *strictly increasing*: $\log(1+t^{2})$ increases because $t^{2}$ does, and $\arctan t$ increases because it is the inverse of the tangent on a rising branch. A sum of two nonnegative strictly increasing functions is strictly increasing, and taking a square root preserves that. Hence:

> **Strict monotonicity.** The radius map $R$ is strictly increasing on $[0,\infty)$.

Strict monotonicity is the whole ballgame for uniqueness. A strictly increasing function is injective, so it can take the value $1$ at most once on $[0,\infty)$. Combine that with the fact that $R$ is continuous, $R(0) = 0 < 1$, and $R$ grows without bound, and the intermediate value theorem supplies existence. Together:

> **Existence and uniqueness.** There is exactly one $t > 0$ with $|\log(1+ti)| = 1$.

Upgrading "there is a solution" to "there is exactly one solution" may sound like bookkeeping, but it changes the character of the object. Before, $t^{\star}$ was *a* number with a property; now it is *the* number with that property — a well-defined constant, like $\pi$ or the Euler–Mascheroni constant, that one is entitled to name and to compute to arbitrary precision.

### Squeezing the constant between two fractions

The genuinely delicate part is the interval. Getting $t^{\star} \in [1/2, 3]$ is easy: crude bounds suffice. Getting $t^{\star} \in [6/5, 5/4]$ — an interval thirty times narrower — requires bounding $\log$ and $\arctan$ at specific rational points with enough precision that the totals land on the right side of $1$ with room to spare. At $t = 6/5$ the total must come out below $1$; at $t = 5/4$, above. The true values are $0.9664$ and $1.0243$, so the margins are only a few percent. Every inequality used has to be sharp to about three decimal places.

The trick that makes this possible with purely elementary tools is a pair of **exact addition identities for the arctangent**:
$$\arctan\frac{6}{5} = \frac{\pi}{4} + \arctan\frac{1}{11}, \qquad \arctan\frac{5}{4} = \frac{\pi}{4} + \arctan\frac{1}{9}.$$
These come straight from the tangent addition formula: $\tan(\pi/4 + x) = (1+\tan x)/(1 - \tan x)$, and plugging $\tan x = 1/11$ gives $12/10 = 6/5$, while $\tan x = 1/9$ gives $10/8 = 5/4$. (They are cousins of Machin's celebrated formula $\pi/4 = 4\arctan\frac15 - \arctan\frac{1}{239}$, the identity that let eighteenth-century computers grind out a hundred digits of $\pi$ by hand.)

Why does this help? Because it moves all the difficulty into $\pi/4$ — a constant whose decimal expansion is known to whatever accuracy one wants — plus an arctangent of a *tiny* argument, where the crudest possible bounds are already excellent. Specifically, for $y \geq 0$,
$$\frac{y}{1+y^{2}} \;\le\; \arctan y \;\le\; y.$$
The upper bound is the classical inequality $x \le \tan x$ read backwards. The lower bound comes from a lovely one-line manipulation: writing $x = \arctan y$, one has $\sin x \cos x = y/(1+y^{2})$, and $\sin x \cos x = \tfrac12 \sin 2x \le x$ because $\sin u \le u$. At $y = 1/9$ these two bounds differ by less than $0.0014$ — plenty.

For the logarithm the corresponding elementary tool is the two-sided bound
$$1 - \frac{1}{x} \;\le\; \log x \;\le\; x - 1,$$
which is just the statement that the logarithm lies below its tangent line at $1$ and above the tangent line of its reciprocal. Applied directly at $x = 1 + t^{2}$ these bounds are far too weak — at $x = 2.44$ they say only $0.59 \le \log x \le 1.44$. The fix is to **split off a power of two**: write $1 + (6/5)^{2} = 61/25 = 2\cdot\frac{61}{50}$ and $1 + (5/4)^{2} = 41/16 = 2 \cdot \frac{41}{32}$. Now $\log 2$ is a known constant, and the residual arguments $61/50 = 1.22$ and $41/32 = 1.28$ are close enough to $1$ that the tangent-line bounds are tight to within $0.03$. The two totals then come out as
$$R(6/5)^{2} \le 0.9803 < 1 < 1.0094 \le R(5/4)^{2},$$
and monotonicity forces the crossing to happen strictly in between.

### Every circle, exactly once

There is nothing special about the unit circle in this story, and saying so precisely gives a much stronger theorem. The radius map $R$ is continuous, strictly increasing on $[0,\infty)$, starts at $R(0) = 0$, and grows without bound — the last point follows from the crisp explicit estimate
$$R(e^{r}) \;\ge\; r \quad \text{for all } r,$$
which one gets by discarding the $\arctan$ term entirely and noting $\tfrac12\log(1 + e^{2r}) \ge \tfrac12 \log e^{2r} = r$. So:

> **The radius map is a bijection.** For every $r \ge 0$ there is exactly one $t \ge 0$ with $|\log(1 + ti)| = r$.

The logarithmic image of the vertical line sweeps out every radius exactly once. The unit-circle theorem is simply the slice at $r = 1$.

### From a scalar to a gate

The last movement of the piece returns to quantum mechanics and asks what the scalar constant actually buys you.

A complex number $z$ of modulus one, multiplied against the identity operator, gives a unitary operator — a *global phase* gate. This is elementary but it is exactly the bridge: the certified root $t^{\star}$ produces a scalar $\log(1 + t^{\star}i)$ of modulus one, so $\log(1 + t^{\star} i) \cdot I$ is a genuine unitary in *any* algebra with a compatible conjugation, including every algebra of $n \times n$ complex matrices. And there is a version that does not even require the root: for *every* nonzero $t$ the **polar normalization**
$$\frac{\log(1+ti)}{\left|\log(1+ti)\right|}$$
is by construction of modulus one, hence always yields a unitary. The certified root is precisely the parameter at which this normalization is invisible — where the logarithm is already unitary on the nose.

Can one reach beyond global phases to genuine quantum gates? Yes, and the mechanism is a classical structure theorem which this work also establishes in the required generality:

> **Exponential surjectivity.** In a unital algebra of operators closed under adjoints, every unitary with finite spectrum is $\exp(i x)$ for some self-adjoint $x$. In particular, every unitary matrix $U$ can be written $U = \exp(iH)$ with $H$ Hermitian.

The proof is a rotation trick worth savouring. The standard route to a logarithm of a unitary requires the principal branch, and that branch fails exactly at $-1$: it needs $-1$ to be outside the spectrum. But the spectrum here is finite, and a finite set cannot contain the whole unit circle (an easy but essential counting fact: the circle is uncountable, or more simply, $\theta \mapsto e^{i\theta}$ is injective on $[0,2\pi)$, so its image is infinite). Choose an angle $\theta$ with $-e^{i\theta}$ outside the spectrum; multiplying $U$ by the phase $e^{-i\theta}$ rotates the spectrum clear of the bad point, the branch now works, and the extra phase is absorbed back at the end because $e^{i\theta}I$ commutes with everything and is itself an exponential. This is the missing rung on the ladder toward describing all of $U(2)$ — the group of all one-qubit gates — through Hermitian generators.

Two further pieces complete the structural picture. First, **every unitary matrix is a unimodular scalar times a matrix of determinant one**: taking $z$ to be an $n$-th root of $\det U$ on the unit circle, $V = z^{-1}U$ is unitary with $\det V = 1$. So $U(n)$ is $U(1)$ times $SU(n)$, and the phase and the "real content" of a gate separate cleanly.

Second — and this is the pleasing sting in the tail — the scalar factor can *never* supply the $SU$ part. For $2 \times 2$ matrices, $\det(zI) = z^{2}$, so $zI \in SU(2)$ demands $z = \pm 1$, a real number. But $\log(1+ti)$ has imaginary part $\arctan t$, which vanishes only at $t = 0$. Hence:

> **Obstruction.** For every $t \neq 0$, the scalar logarithmic factor $\log(1+ti)\,I$ is unitary but never special unitary in dimension $2$.

That is not a failure; it is a precise statement about where the interesting structure has to live. Global phase is genuinely global: it is invisible to any measurement and carries no computational content. The theorem says, cleanly, that the scalar logarithm delivers exactly the phase and nothing more, and that anything more must come from the determinant-one factor.

### The constant, and what remains

We are left with a new named constant: $t^{\star} = 1.2290375625\ldots$, the unique positive solution of
$$\left(\frac{\log(1+t^{2})}{2}\right)^{2} + \arctan(t)^{2} = 1,$$
certified to lie in $[6/5, 5/4]$ by nothing more than tangent-line bounds for $\log$, the two-sided bound $y/(1+y^2) \le \arctan y \le y$, and two exact arctangent addition identities.

It is very likely transcendental — it is a root of an equation mixing $\log$ and $\arctan$, and it would be astonishing if it were algebraic — but proving that is a serious problem in transcendence theory, well beyond the elementary tools used here. The same is true of tightening the interval much further: each additional decimal place demands correspondingly sharper certified bounds on $\log 2$, $\pi$, and the residual arctangents. That is a matter of effort rather than of new ideas, which is exactly the position one wants to be in.

The larger arc is clearer. A question about where a logarithm meets a circle turned out to have a unique answer; the answer turned out to be a phase; and the phase turned out to be exactly the part of a quantum gate that carries no information. Sometimes the most satisfying theorem is the one that tells you precisely how much you have — and precisely how much you still have to build.
