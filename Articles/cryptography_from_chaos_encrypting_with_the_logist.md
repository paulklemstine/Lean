# Cryptography from Chaos: Encrypting with the Logistic Map

## A single equation that fascinated a generation

Take a number between $0$ and $1$. Call it $x$. Now apply this deceptively simple rule:

$$f(x) = 4\,x\,(1 - x).$$

Feed the answer back in, again and again. What you get is the *logistic map* at its most extreme setting, and its behavior is the stuff of legend. Start at $x_0 = 0.4$ and the sequence lurches unpredictably around the interval: $0.96$, then $0.15$, then $0.52$, then $0.998$, and on it goes, never settling, never repeating in any pattern the eye can catch. This is **chaos** — deterministic, rule-bound, and yet in practice as unpredictable as a coin toss.

The logistic map became the emblem of chaos theory in the 1970s and 1980s. It appears in population biology (where $x$ is the fraction of a habitat's carrying capacity a species occupies from one year to the next), in electronics, and in countless textbooks. But its most seductive promise came later, when cryptographers noticed something: the very feature that makes chaos *chaotic* is exactly what an encryption scheme wants. If the tiniest change to the starting point produces a wildly different future, then a secret starting point could be the key to a secret code.

This article is about that promise — where it comes from, why it is mathematically real, and why, when you look at the map through the right lens, it also quietly betrays itself.

## The dream: turning chaos into a cipher

Here is the idea in its purest form. To encrypt a message, Alice and Bob agree on a secret seed $x_0 \in (0,1)$. Alice iterates the logistic map to produce a stream of numbers

$$x_0,\ f(x_0),\ f(f(x_0)),\ f^3(x_0),\ \dots$$

She turns this **keystream** into a string of bits and combines it with her message using the exclusive-or operation ($\oplus$), the standard workhorse of stream ciphers:

$$\text{ciphertext} = \text{message} \oplus \text{keystream}.$$

Bob, who knows $x_0$, regenerates the identical keystream and XORs it back out to recover the message. An eavesdropper who sees only the ciphertext faces a keystream that looks like noise — unless they can guess the seed.

Why should this be hard to break? Two reasons are always cited, and both turn out to be genuine theorems.

**Reason one: the avalanche.** Chaos means *sensitive dependence on initial conditions* — the "butterfly effect." Two seeds that agree to a billion decimal places will, after enough steps, produce completely different outputs. If you don't know the seed exactly, your predicted keystream diverges from the real one and becomes useless. A cipher wants precisely this: a small mistake in the key should scramble everything.

**Reason two: algebraic depth.** Suppose an attacker tries to solve for the seed directly. The $n$-th iterate $f^n$ is a polynomial in $x_0$. And its degree explodes: $f$ has degree $2$, $f^2$ has degree $4$, $f^3$ has degree $8$, and in general $f^n$ has degree $2^n$. Recovering the seed from a keystream sample looks like it requires solving a polynomial equation of astronomical degree — exponential in the number of iterations. That smells like a hard problem, the kind cryptography is built on.

Both of these intuitions are correct. What follows is how to make them exact — and the twist that lurks underneath.

## The master key: chaos is just doubling in disguise

The whole story hinges on one beautiful identity. Recall the double-angle formula from trigonometry, $\sin(2t) = 2\sin t\cos t$. Square it and use $\cos^2 t = 1 - \sin^2 t$:

$$\sin^2(2t) = 4\sin^2 t\,\cos^2 t = 4\sin^2 t\,(1 - \sin^2 t).$$

Now stare at the right-hand side. If we write $x = \sin^2 t$, that is exactly $4x(1-x) = f(x)$. So we have proved the **semiconjugacy of the logistic map to angle doubling**:

$$f(\sin^2 t) = \sin^2(2t).$$

In words: the complicated nonlinear logistic map, viewed in the coordinate $x = \sin^2 t$, is nothing more than the childishly simple operation of *doubling the angle* $t \mapsto 2t$.

This is not an approximation. It is exact, and it lifts effortlessly to every iterate. Applying the identity $n$ times gives

$$f^n(\sin^2 t) = \sin^2(2^n\, t).$$

Every mystery of the logistic map is now transparent. Iterating $f$ a hundred times is the same as multiplying an angle by $2^{100}$ and reading off the squared sine. The factor $2^n$ — the doubling — is the engine behind everything.

From here, both cryptographic "reasons" fall out as clean consequences.

**The avalanche, made precise.** Consider the family of seeds

$$s_n = \sin^2\!\left(\frac{\pi}{2^{\,n+2}}\right).$$

As $n$ grows, the angle $\pi/2^{\,n+2}$ collapses toward $0$, and the seed $s_n$ shrinks quadratically toward $0$ — one can show $0 < s_n \le (\pi/2^{\,n+2})^2$. These seeds are getting *exponentially close* to the fixed point $0$ (which satisfies $f(0)=0$, so its whole orbit stays at $0$ forever). Yet watch what happens after exactly $n$ steps. Because

$$2^n \cdot \frac{\pi}{2^{\,n+2}} = \frac{\pi}{4}, \qquad \sin^2\!\left(\frac{\pi}{4}\right) = \frac{1}{2},$$

we get $f^n(s_n) = \tfrac12$ on the nose, while $f^n(0) = 0$. The two orbits, which started an exponentially tiny distance apart, are now separated by a full $\tfrac12$:

$$\bigl|\,f^n(s_n) - f^n(0)\,\bigr| = \frac{1}{2}.$$

This is sensitive dependence with a stopwatch: a perturbation of size roughly $2^{-2n}$ blows up to a macroscopic gap in exactly $n$ steps. That is the avalanche a cipher advertises, exhibited concretely rather than hand-waved.

**Algebraic depth, made precise.** The doubling picture also explains the degree explosion. Since $f$ is a quadratic, composing it with itself squares nothing accidental: each composition multiplies the degree by $2$. Rigorously, the degree of a composition of polynomials multiplies, so if $f$ has degree $2$ then $f^n$ has degree $2 \cdot 2 \cdots 2 = 2^n$. Recovering a seed algebraically means confronting an equation of degree $2^n$ — for $n = 64$, that is a polynomial of degree $2^{64} \approx 1.8 \times 10^{19}$. On its face, an impossible computation.

So both pillars of the "chaos cipher" are real theorems, not folklore. The map genuinely amplifies uncertainty exponentially, and it genuinely hides its seed behind a polynomial of exponential degree.

## The twist: the same lens that reveals also breaks

And yet the logistic cipher, in this naive form, is *not* secure. The reason is the very identity that made everything transparent.

Angle doubling has a second face. Write the angle as a fraction of a half-turn, $t = \pi\theta$ with $\theta \in [0,1)$. Doubling the angle, $t \mapsto 2t$, is the same as doubling $\theta$ modulo $1$:

$$\theta \mapsto 2\theta \pmod 1.$$

Now express $\theta$ in **binary**: $\theta = 0.b_1 b_2 b_3 b_4 \ldots$ Doubling a binary number shifts every digit one place to the left and drops the integer part — it is the *bit shift map*:

$$0.b_1 b_2 b_3 \ldots \ \longmapsto\ 0.b_2 b_3 b_4 \ldots$$

Each iteration simply discards one bit and slides the rest over. So the "chaotic" keystream, read in the conjugate coordinate, is doing nothing more exotic than reading out the binary digits of the secret angle one at a time. The apparent complexity was an illusion of the coordinate system.

This is the sting in the tail. The degree-$2^n$ polynomial that looked like an impregnable wall is an artifact of insisting on the coordinate $x$. Change to the coordinate $\theta$, and the exponential collapses to a shift. An attacker who thinks in $\theta$ can read off the seed's bits directly from the keystream — recovering it to $n$ bits of precision from about $n$ samples, in time *linear* in the security parameter, not exponential. The wrong coordinate hid a hard-looking problem that was never hard at all.

Sensitivity, too, cuts both ways. It scrambles a defender's imprecise guesses — but it equally scrambles the cryptanalyst's, and more to the point, in finite-precision arithmetic it guarantees that a real computer's orbit peels away from the ideal one at the same exponential rate. A machine with $p$ bits of precision loses all fidelity to the true orbit after about $p$ steps. The horizon of unpredictability and the horizon of numerical unreliability are the *same* horizon, read from opposite sides.

## Why this matters

The moral is larger than one cipher. It is a parable about what "hard" means in mathematics and cryptography.

Difficulty is not always an intrinsic property of a problem; sometimes it is a property of the *language* you use to describe it. The logistic map's degree-$2^n$ polynomial is a real object, and solving degree-$2^n$ polynomials is genuinely hard in general. But this particular family of polynomials carries a hidden symmetry — a conjugacy to a linear shift — and that symmetry provides a shortcut that dissolves the difficulty entirely. Good cryptography must resist not just the obvious attack in the obvious coordinates, but *every* change of viewpoint. A hardness that evaporates under a clever substitution was never hardness at all.

There is also a genuinely constructive lesson. The exact identity $f^n(\sin^2 t) = \sin^2(2^n t)$ is a bridge between two worlds that rarely meet so cleanly: the continuous, analytic world of dynamical systems and the discrete, algebraic world of polynomials and their degrees. On one side it delivers a dynamical statement — sensitive dependence, the butterfly effect with an explicit rate. On the other it delivers an algebraic statement — a composition of quadratics of degree exactly $2^n$. That a single trigonometric identity governs both is the kind of unity mathematicians live for.

Chaos really is a form of cryptography: the sensitivity that makes weather unforecastable is a cousin of the diffusion that hides a message. But the logistic map teaches the humbler half of the lesson too. Raw chaos, poured directly into a cipher, is seductive and fragile — a lock that looks formidable from the front and springs open the moment you walk around to the side. The art of cryptography lies precisely in building locks with no side to walk around to.
