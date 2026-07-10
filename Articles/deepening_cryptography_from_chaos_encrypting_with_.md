# Cryptography from Chaos: The Parabola That Was Secretly a Pair of Straight Lines

## A tale of two maps

Take a number between $0$ and $1$. Multiply it by four, then multiply by one minus itself. Repeat. That is the whole recipe for the **logistic map**,

$$f(x) = 4x(1-x),$$

and it is one of the most famous engines of chaos in all of mathematics. Feed it almost any starting value and its trajectory dances unpredictably across the interval $[0,1]$ forever, never settling into a pattern. Change the starting value by a millionth, and within a few dozen steps the two trajectories are as unrelated as two strangers. This exquisite sensitivity — the "butterfly effect" in its purest one-dimensional form — is exactly the property that tempts engineers to build ciphers out of it: hide a secret starting number, run the map, and use the resulting jittery sequence as a mask for your message.

Now consider a humbler creature, the **tent map**:

$$T(t) = 1 - |2t - 1|.$$

Its graph is not a graceful parabola but two straight ramps: climb steeply from $(0,0)$ up to the peak at $(1/2, 1)$, then descend symmetrically back down to $(1,0)$. It looks like a child's drawing of a mountain. It, too, is chaotic — but transparently so. Because it is built from straight lines, everything about it can be computed by hand.

At first glance these two maps have nothing in common. One is smooth and curved; the other is angular and piecewise linear. One feels deep and analytic; the other feels almost trivial. The surprise at the heart of this article is that **they are the same dynamical system wearing different clothes.**

## The disguise

The clothing is a single, elegant change of coordinates. Define

$$h(t) = \sin^2\!\left(\frac{\pi t}{2}\right).$$

As $t$ runs from $0$ to $1$, the angle $\pi t/2$ runs from $0$ to $\pi/2$, so $\sin$ climbs from $0$ to $1$ and $h$ climbs smoothly and strictly from $h(0) = 0$ to $h(1) = 1$. In other words, $h$ is a **homeomorphism of the unit interval**: a continuous, strictly increasing bijection that stretches and squeezes $[0,1]$ onto itself without ever folding or tearing. It has a continuous inverse. Whatever $h$ does can be perfectly undone.

The central theorem says that this reparametrization **intertwines** the two maps exactly:

$$f\big(h(t)\big) = h\big(T(t)\big) \qquad \text{for every real } t.$$

Read it out loud: applying the smooth logistic map *after* the change of coordinates gives precisely the same result as applying the humble tent map *first* and then changing coordinates. The diagram commutes. The two maps are **topologically conjugate**.

Why is it true? The computation is almost a magic trick. Start with the double-angle identity for sine, $\sin(2\theta) = 2\sin\theta\cos\theta$, together with $\cos^2\theta = 1 - \sin^2\theta$. Then

$$f\big(h(t)\big) = 4\sin^2\!\tfrac{\pi t}{2}\left(1 - \sin^2\!\tfrac{\pi t}{2}\right) = 4\sin^2\!\tfrac{\pi t}{2}\cos^2\!\tfrac{\pi t}{2} = \sin^2(\pi t).$$

So the logistic map, viewed through $h$, simply **doubles the angle**. Meanwhile $h(T(t)) = \sin^2\!\big(\tfrac{\pi}{2}T(t)\big)$, and the tent map's job is to fold the doubled angle back into range. On the near branch, where $t \le 1/2$, we have $T(t) = 2t$ and $h(T(t)) = \sin^2(\pi t)$ immediately. On the far branch, where $t > 1/2$, we have $T(t) = 2 - 2t$, and

$$h(T(t)) = \sin^2\!\big(\pi - \pi t\big) = \sin^2(\pi t),$$

because sine is symmetric about $\pi$. Both branches agree with $f(h(t)) = \sin^2(\pi t)$. The fold of the tent, at $t = 1/2$, is exactly the fold of the parabola, at its peak $x = 1$. That shared fold is the true structural cause of chaos in both systems.

## Why one identity changes everything

A conjugacy is far more than a curiosity, because it transports *every* dynamical property from one system to the other, verbatim. Iterating the intertwining identity gives

$$f^{\,n}\big(h(t)\big) = h\big(T^{\,n}(t)\big) \qquad \text{for every } n,$$

so the $n$-step behavior of the logistic map is nothing but the $n$-step behavior of the tent map, read in different coordinates. Since $h$ is a bijection, nothing is lost in translation. Fixed points map to fixed points, cycles map to cycles of the same length, dense orbits map to dense orbits.

Consider fixed points. The tent map's fixed points — the values it leaves unmoved — are exactly $t = 0$ and $t = 2/3$, found by solving the two straight-line equations $2t = t$ and $2 - 2t = t$. Push them through the change of coordinates. Obviously $h(0) = 0$. And beautifully,

$$h\!\left(\tfrac{2}{3}\right) = \sin^2\!\left(\tfrac{\pi}{3}\right) = \left(\tfrac{\sqrt3}{2}\right)^{\!2} = \tfrac{3}{4}.$$

So the logistic map must fix $0$ and $3/4$ — and indeed $f(3/4) = 4\cdot\tfrac34\cdot\tfrac14 = \tfrac34$. We discovered the smooth map's fixed point $3/4$ without ever solving a quadratic; the tent map handed it to us.

The same trick manufactures periodic orbits. The tent map sends $2/5 \mapsto 4/5 \mapsto 2/5$, a genuine cycle of period two (check: $T(2/5) = 1 - |4/5 - 1| = 4/5$, and $T(4/5) = 1 - |8/5 - 1| = 2/5$). Transporting through $h$ produces a point $h(2/5) = \sin^2(\pi/5) \approx 0.345$ that returns to itself after exactly two steps of the logistic map but is *not* a fixed point. Because $h$ is injective, the two points of the tent cycle stay distinct after the change of coordinates, so the logistic cycle is truly period two — not a fixed point in disguise. This is the very first rung of the celebrated period-doubling ladder that climbs into chaos.

## The sting in the tail: chaos ciphers are only as strong as a sawtooth

Here is where geometry meets cryptography, and delivers a warning. A "chaos cipher" hides a secret seed $x_0$ and releases the sequence $x_0, f(x_0), f^2(x_0), \dots$ as a keystream to mask a message. The designer's hope is that the logistic map's smooth, transcendental complexity makes the keystream inscrutable. And indeed the $n$-th iterate $f^n$, written out as a polynomial, has degree $2^n$ — an intimidating algebraic monster.

But the conjugacy exposes this complexity as a costume. In the $h$-coordinate, the same keystream is *just the tent map iterated* — and the tent map's $n$-th iterate is only a sawtooth with $2^n$ straight ramps. Better still, the tent map is essentially the **binary shift**: writing $t$ in binary, the tent map (up to a reflection) chops off one bit at a time. An attacker who applies the inverse coordinate change $h^{-1}(x) = \tfrac{2}{\pi}\arcsin\sqrt{x}$ turns the fearsome logistic keystream into a transparent, piecewise-linear bit shift. Any statistical weakness — bias, autocorrelation, the ease of running the map backward to recover the seed — has an exact tent-map counterpart. **The smooth cipher offers no security beyond its angular shadow.** The lesson is sharp: apparent analytic complexity is not cryptographic strength when a single monotone change of variable strips it away.

## The deeper moral

There is a recurring theme in mathematics: two objects that look utterly different turn out to be the same once you find the right way to look. Here the right way is a one-line reparametrization of the interval, $h(t) = \sin^2(\pi t/2)$, which welds the smooth world of parabolas to the combinatorial world of folding straight lines. The chaos of the logistic map — its sensitive dependence, its dense periodic points, its statistical mixing — is not born of its curvature at all. It is born of a single fold, the same fold the tent map wears on its sleeve.

The invariant statistics tell the same story. Iterated a long time, the logistic map does not visit the interval uniformly; it lingers near the endpoints $0$ and $1$ according to the **arcsine law**, with density $1/\big(\pi\sqrt{x(1-x)}\big)$. That mysterious weighting is nothing but the flat, uniform density of the tent map pushed through $h$: the Jacobian of the change of variables produces the arcsine curve automatically. Even the map's long-run "personality" is inherited from its piecewise-linear twin.

So the next time you meet the logistic map billed as an icon of smooth chaos, remember what lives underneath: a child's drawing of a mountain, two straight ramps folded at the middle, doubling angles and shifting bits. Geometry saw through the disguise.
