# A Line, a Logarithm, and a Circle

*A guided tour of the scalar logarithmic radius, its unique root, and what that root has to do with quantum gates.*

---

## 1. The picture you can draw on a napkin

In the complex plane, mark the point $1$ and draw the vertical line through it — every number of the form
$$1 + t\,i, \qquad t \in \mathbb{R}.$$

Now apply the [complex logarithm](https://en.wikipedia.org/wiki/Complex_logarithm) to every point of that line. The logarithm bends the straight line into a graceful curve through the origin. One question organises everything that follows:

> **Where does that curve cross the unit circle?**

Play with it. Drag the slider and watch the gold dot — the image $\log(1+ti)$ — travel along the blue curve while the gold spoke shows its distance from the origin. There are exactly **two** places where that distance equals $1$.

{{interactive_demo:0}}

If you dragged all the way from $-3$ to $3$, you will have noticed three things that the rest of this page makes precise: the curve crosses the circle exactly twice; the two crossings are mirror images; and the positive crossing sits stubbornly between $1.2$ and $1.25$.

---

## 2. The one identity that makes it all elementary

The principal logarithm splits a complex number into a modulus and an angle. For our line,
$$|1 + ti| = \sqrt{1+t^{2}}, \qquad \arg(1+ti) = \arctan t,$$
so
$$\log(1+ti) = \tfrac{1}{2}\log(1+t^{2}) \;+\; i \arctan t.$$

Taking the modulus squared gives the closed form that the whole story rests on. Write $R(t) = |\log(1+ti)|$ for the **scalar logarithmic radius**. Then

$$\boxed{\;R(t)^{2} \;=\; \left(\frac{\log(1+t^{2})}{2}\right)^{2} + \arctan(t)^{2}\;}$$

and the crossing condition $R(t)=1$ becomes a purely real equation mixing two of the most familiar transcendental functions in mathematics.

<details>
<summary><b>Click to reveal: why the argument of $1+ti$ is exactly $\arctan t$</b></summary>

The real part of $1+ti$ is $1 > 0$, so the point lies in the open right half-plane and the principal argument is given, without case distinctions, by
$$\arg(a+bi) = \arcsin\!\left(\frac{b}{|a+bi|}\right).$$
With $a=1$, $b=t$ this is $\arcsin\bigl(t/\sqrt{1+t^{2}}\bigr)$. Setting $x = \arctan t$ gives $\sin x = t/\sqrt{1+t^{2}}$ directly from the right triangle with legs $1$ and $t$, so $\arcsin\bigl(t/\sqrt{1+t^{2}}\bigr) = \arctan t$. That the whole line stays in the right half-plane is why the principal branch never causes trouble here: no branch cut is ever crossed.
</details>

---

## 3. Why the crossing is *unique*

Existence is cheap: the curve starts at the origin and runs off to infinity, so it must cross the circle somewhere. Uniqueness is the theorem that gives the crossing point a name.

Look at the closed form again. On $t \ge 0$, **both summands are nonnegative and both are strictly increasing** — $\log(1+t^{2})$ because $t^{2}$ increases, $\arctan t$ because the arctangent is increasing. A sum of two nonnegative strictly increasing functions is strictly increasing, and the square root of a strictly increasing nonnegative function is strictly increasing. Hence:

> **Strict Monotonicity Theorem.** $R$ is strictly increasing on $[0, \infty)$.

A strictly increasing function is injective, so it hits the value $1$ **at most once**. Combining with existence:

> **Uniqueness Theorem.** There is exactly one $t > 0$ with $|\log(1+ti)| = 1$. Call it $t^{\star}$.

And because $R$ is even ($t^{2}$ is even and $\arctan$ is odd, so its square is even), the full solution set is $\{-t^{\star}, t^{\star}\}$ — the two crossings you saw.

The picture below makes both halves of the argument visible at once: on the left the curve and the circle, on the right the strictly rising profile $R(t)$ pierced by the level $R=1$ at a single point.

{{visualization:0}}

<details>
<summary><b>Click to reveal: the stronger statement — every circle is hit exactly once</b></summary>

Nothing in the argument singled out radius $1$. Add one explicit growth estimate,
$$R(e^{r}) \ge r \quad \text{for all } r,$$
which follows by throwing away the arctangent term entirely and noting $\tfrac12\log(1+e^{2r}) \ge \tfrac12\log e^{2r} = r$, and you get:

> **Bijectivity Theorem.** $R : [0,\infty) \to [0,\infty)$ is a strictly increasing continuous bijection — an increasing homeomorphism. For every radius $r \ge 0$ there is exactly one $t \ge 0$ with $|\log(1+ti)| = r$.

The unit-circle theorem is just the slice at $r = 1$. Said geometrically: the logarithmic image of the vertical line sweeps out every circle around the origin exactly once, so the parameter $t$ is a faithful, invertible coordinate for the radius.
</details>

---

## 4. Trapping the constant between two fractions

We now know $t^{\star}$ exists and is unique. Where is it?

Numerically, $t^{\star} = 1.2290375625\ldots$ — but numerics is not proof. The goal is a **certificate**: a chain of verifiable inequalities showing
$$R\!\left(\tfrac{6}{5}\right) < 1 < R\!\left(\tfrac{5}{4}\right),$$
after which monotonicity forces $t^{\star} \in [6/5, 5/4] = [1.2, 1.25]$.

This is delicate. The true values are $R(6/5)^{2} = 0.9664$ and $R(5/4)^{2} = 1.0243$: margins of $3.4\%$ and $2.4\%$. Every estimate must be sharp to about three decimals.

Two families of elementary bounds do the work:
$$1 - \frac{1}{x} \;\le\; \log x \;\le\; x - 1, \qquad \frac{y}{1+y^{2}} \;\le\; \arctan y \;\le\; y \;\; (y \ge 0).$$

Both are excellent **near their distinguished point** ($x=1$ for the logarithm, $y=0$ for the arctangent) and hopeless away from it. The figure below shows exactly how fast they degrade — and then shows the resulting budget at the two endpoints.

{{visualization:1}}

The trick that saves the day is a pair of **reduction identities** that transport the evaluation point back into the good region at the price of a known constant:
$$\log(2u) = \log 2 + \log u, \qquad \arctan\frac{1+y}{1-y} = \frac{\pi}{4} + \arctan y.$$

<details>
<summary><b>Click to reveal: the full certificate, both endpoints</b></summary>

**At $t = 6/5$ (must come out below $1$).** Note $1 + (6/5)^{2} = \frac{61}{25} = 2 \cdot \frac{61}{50}$, so
$$\log\tfrac{61}{25} = \log 2 + \log\tfrac{61}{50} \le 0.6931471808 + \left(\tfrac{61}{50}-1\right) = 0.9131472,$$
giving $\left(\tfrac{L}{2}\right)^{2} \le 0.208465$. For the angle, the addition identity $\arctan\frac65 = \frac{\pi}{4} + \arctan\frac1{11}$ (check: $\tan(\pi/4 + x) = \frac{1+\tan x}{1-\tan x}$, and $\tan x = 1/11$ gives $\frac{12/11}{10/11} = \frac65$) combines with $\arctan y \le y$ and $\pi < 3.15$:
$$\arctan\tfrac65 \le \tfrac{3.15}{4} + \tfrac{1}{11} = 0.87841 \le 0.8785,$$
so $\left(\arctan\frac65\right)^{2} \le 0.771763$. Total: $\;0.980228 < 1$. ✓

**At $t = 5/4$ (must come out above $1$).** Note $1 + (5/4)^{2} = \frac{41}{16} = 2 \cdot \frac{41}{32}$, so
$$\log\tfrac{41}{16} = \log 2 + \log\tfrac{41}{32} \ge 0.6931471803 + \left(1 - \tfrac{32}{41}\right) = 0.9126593,$$
giving $\left(\tfrac{L}{2}\right)^{2} \ge 0.208236$. The identity $\arctan\frac54 = \frac{\pi}{4} + \arctan\frac19$ combines with the *lower* bound $\arctan y \ge \frac{y}{1+y^{2}}$ and $\pi > 3.141592$:
$$\arctan\tfrac54 \ge \tfrac{3.141592}{4} + \tfrac{9}{82} = 0.895154 \ge 0.8951,$$
so $\left(\arctan\frac54\right)^{2} \ge 0.801204$. Total: $\;1.009440 > 1$. ✓

Both arctangent identities are cousins of [Machin's formula](https://en.wikipedia.org/wiki/Machin-like_formula) $\frac{\pi}{4} = 4\arctan\frac15 - \arctan\frac1{239}$, the identity behind hand computations of $\pi$ to a hundred digits in the eighteenth century.
</details>

The certificate is not just a hand argument — it can be executed in exact rational arithmetic, with rigorous enclosures for $\log$ and $\arctan$ built from series with explicit remainder bounds. Run the algorithm below and it will *prove*, with no floating point anywhere, that $t^{\star}$ lies in an interval of width $10^{-20}$.

{{algorithm:0}}

---

## 5. What the constant is *for*: unitaries

Here is where the story turns from analysis to algebra.

In [quantum information](https://en.wikipedia.org/wiki/Quantum_logic_gate), the permitted operations are **unitary**: they preserve lengths and angles. In one complex dimension, a unitary is exactly multiplication by a number of modulus one — a point on the unit circle. So the equation $|\log(1+ti)| = 1$ asks precisely: *for which $t$ is $\log(1+ti)$ itself a legitimate quantum phase?*

> **Scalar Unitarity Theorem.** If $|z| = 1$, then $z \cdot I$ is a unitary element of any complex $*$-algebra — in particular of every algebra of $n\times n$ complex matrices.

The proof is one line: $(zI)^{*}(zI) = \bar z z\, I = |z|^{2} I = I$. So at $t = t^{\star}$, the matrix $\log(1+t^{\star}i)\,I$ is a genuine global-phase gate in every dimension. And there is a version that needs no calibration at all:

> **Polar Normalization Theorem.** For every $t \neq 0$, the normalized factor $\dfrac{\log(1+ti)}{|\log(1+ti)|}$ has modulus one, hence yields a unitary. At $t = t^{\star}$ the normalization is invisible — the logarithm is already unitary on the nose.

The fourth panel of the interactive explorer above tracks all of this live: watch $\bar z z$ approach $1$ exactly as the gold dot touches the red circle.

---

## 6. Beyond global phase: Hermitian generators

Global phases are the *simplest* unitaries. Can we reach all of them? Yes — and the mechanism is worth savouring.

> **Exponential Surjectivity Theorem.** In a unital algebra of operators closed under adjoints, every unitary with finite spectrum equals $\exp(ix)$ for some self-adjoint $x$. In particular, **every unitary matrix $U$ is $\exp(iH)$ for a Hermitian $H$.**

<details>
<summary><b>Click to reveal: the rotation trick, the heart of the proof</b></summary>

The classical route to a logarithm of a unitary uses the principal branch, which is discontinuous at $-1$; the construction therefore demands $-1 \notin \operatorname{sp}(U)$, equivalently $\|U - I\| < 2$. A general unitary can of course have $-1$ as an eigenvalue.

The fix: the spectrum of a unitary matrix is finite, and **a finite set cannot contain the whole unit circle** (the map $\theta \mapsto e^{i\theta}$ is injective on $[0,2\pi)$, so its image is infinite). Choose $\theta$ with $-e^{i\theta}$ outside the spectrum, and set $c = e^{-i\theta}$. Then $cU$ is unitary, its spectrum is $c\cdot\operatorname{sp}(U)$, and $-1 \notin c\cdot\operatorname{sp}(U)$ — because $-1 = cz$ would force $z = -e^{i\theta} \in \operatorname{sp}(U)$. So $\|cU - I\| < 2$, the branch works, and we get a self-adjoint $x_{0}$ with $\exp(ix_{0}) = cU$.

Finally the rotation is absorbed: $\theta I$ is central, so
$$\exp\bigl(i(\theta I + x_{0})\bigr) = \exp(i\theta I)\exp(ix_{0}) = (e^{i\theta}I)(cU) = U,$$
and $\theta I + x_{0}$ is self-adjoint because $\theta$ is real.
</details>

Two further structural facts complete the picture:

> **Determinant Splitting Theorem.** Every unitary matrix factors as $U = zV$ with $|z| = 1$ and $\det V = 1$. (Take $z = e^{i\arg(\det U)/n}$; then $\det(z^{-1}U) = z^{-n}\det U = 1$.)

> **$SU(2)$ Obstruction Theorem.** For every $t \neq 0$, the scalar factor $\log(1+ti)\,I_{2}$ is unitary but **never** special unitary: $\det(zI_{2}) = z^{2}$, which equals $1$ only for $z = \pm 1$, both real, whereas $\operatorname{Im}\log(1+ti) = \arctan t \neq 0$.

That negative result is really a conservation law. Global phase is physically unobservable; the theorem says the scalar logarithm delivers exactly the phase and nothing more, so any nontrivial gate content must come from the determinant-one factor. The algorithm below constructs both pieces explicitly — including for $-I$, the worst case, whose only eigenvalue sits exactly on the branch cut.

{{algorithm:1}}

---

## 7. Everything at once

Finally, a single self-contained script that reproduces every quantitative claim on this page: the closed form, evenness, strict monotonicity, the two endpoint certificates, the root to machine precision, the bijectivity of the radius map, unitarity of the scalar and normalized factors, Hermitian generators for a handful of standard gates, the phase/special-unitary split, and the $SU(2)$ obstruction.

{{demo:0}}

---

## 8. What we know, and what we would like to know

| | |
|---|---|
| **Closed form** | $R(t)^{2} = \left(\tfrac12\log(1+t^{2})\right)^{2} + \arctan(t)^{2}$ |
| **Monotonicity** | $R$ strictly increasing on $[0,\infty)$ |
| **Uniqueness** | exactly one $t>0$ with $R(t)=1$ |
| **Certified interval** | $t^{\star} \in [6/5,\,5/4]$; numerically $1.2290375625\ldots$ |
| **Bijectivity** | every circle is hit exactly once |
| **Scalar unitarity** | $t^{\star}$ makes $\log(1+t^{\star}i)\,I$ a global phase |
| **Exponential surjectivity** | every unitary matrix is $\exp(iH)$, $H$ Hermitian |
| **Obstruction** | the scalar factor is never special unitary |

Open questions worth chasing:

- **Is $t^{\star}$ transcendental?** It is the unique positive root of an equation mixing $\log$ and $\arctan$ — the real and imaginary parts of a single logarithm. Transcendence would presumably need a [Schanuel-type](https://en.wikipedia.org/wiki/Schanuel%27s_conjecture) input; even irrationality appears open.
- **The determinant–trace bridge.** Proving $\det \exp(A) = \exp(\operatorname{tr} A)$ would give the exact characterisation $\exp(iH) \in SU(n) \iff \operatorname{tr} H \in 2\pi\mathbb{Z}$ — the missing congruence class.
- **Operator analogues.** Replace $1+ti$ by $1+tN$ for a normal operator $N$ and ask when $\|\log(1+tN)\| = 1$ in operator norm. The scalar case here is the one-dimensional shadow of that question.

The arc of the story is short and satisfying: a question about where a logarithm meets a circle has a unique answer; the answer is a phase; and the phase turns out to be exactly the part of a quantum gate that carries no information at all.
