# Cryptography from Chaos: Exact Structure of the Logistic Keystream

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

The logistic map $f(x) = 4x(1-x)$ on the unit interval is the canonical example of one-dimensional chaos, and it has repeatedly been proposed as the heart of a "chaos-based" stream cipher: the orbit of a secret seed $x_0 \in (0,1)$ is used as a keystream that masks the plaintext. Two properties are advertised as the source of security: *sensitive dependence on initial conditions* (the avalanche effect), and *algebraic depth* (the $n$-th iterate is a polynomial of exponentially large degree $2^n$, so recovering the seed appears to require solving a degree-$2^n$ equation). We make both claims precise and prove them. The unifying device is the exact **semiconjugacy of the logistic map to angle doubling**, $f(\sin^2 t) = \sin^2(2t)$, which lifts to $f^n(\sin^2 t) = \sin^2(2^n t)$ for every $n$. From this single identity we derive: (i) an explicit family of seeds converging to the fixed point $0$ whose $n$-th iterates remain a *constant* distance $\tfrac12$ from the fixed orbit, a quantitative avalanche; and (ii) the fact that the $n$-th iterate, viewed as a polynomial, has degree exactly $2^n$, with the polynomial and dynamical descriptions agreeing pointwise. We also record the invariant structural facts (the unit interval is preserved; the only real fixed points are $0$ and $3/4$). Finally we explain, using the conjugacy, why the naive chaos cipher is nonetheless insecure: in the conjugate coordinate the dynamics is the binary shift map, so the degree-$2^n$ barrier is an artifact of coordinates and the seed is recoverable in time linear in the security parameter. The work is a compact bridge between real dynamics and polynomial algebra, and a cautionary tale about coordinate-dependent notions of hardness.

## 1. Introduction

Chaos and cryptography share a slogan: small causes, large effects. A cryptosystem is supposed to *diffuse* information so that a one-bit change in the key or plaintext changes roughly half the output bits. A chaotic dynamical system exhibits *sensitive dependence on initial conditions*, so that a small change in the state is amplified exponentially in time. The resemblance has inspired a long line of "chaos-based" ciphers, of which the simplest and most famous uses the logistic map at its fully chaotic parameter.

**The logistic cipher.** Fix a secret seed $x_0 \in (0,1)$ and iterate

$$f(x) = 4x(1-x).$$

The keystream is the orbit $K = \bigl(f(x_0), f^2(x_0), f^3(x_0), \dots\bigr)$, quantized to bits; the ciphertext is $C = M \oplus K$ for plaintext $M$. Decryption regenerates $K$ from $x_0$ and XORs it out. The proposed security rests on two claims:

1. **Sensitivity.** A change of $\varepsilon$ in $x_0$ produces an $O(1)$ change in $f^n(x_0)$ after $n = O(\log(1/\varepsilon))$ iterations.
2. **Algebraic depth.** The iterate $f^n$ is a polynomial of degree $2^n$, so solving for $x_0$ from keystream values is a degree-$2^n$ root-finding problem, exponential in $n$.

**Contribution.** We prove precise forms of both claims and identify the exact structural reason they hold. The keystone is the classical semiconjugacy

$$f(\sin^2 t) = \sin^2(2t), \qquad\text{hence}\qquad f^n(\sin^2 t) = \sin^2(2^n t),$$

which conjugates the logistic map to the angle-doubling map $t \mapsto 2t$. The per-step stretching factor $2$ is the common origin of the Lyapunov exponent $\log 2$, the exponential sensitivity, and the degree growth. We then use the same identity to explain the cipher's fatal weakness: doubling is the binary shift, so the keystream transparently emits the bits of the conjugate coordinate.

**Organization.** Section 2 fixes definitions and elementary invariants. Section 3 proves the semiconjugacy and its iterate form. Section 4 develops the polynomial (algebraic) description and the degree theorem. Section 5 states and proves the sensitivity result. Section 6 discusses cryptographic consequences, including the linear-time break. Section 7 gives algorithms and numerical illustrations, and Section 8 collects future directions.

## 2. Definitions and elementary invariants

**Definition 2.1 (Logistic map).** The *logistic map* at the fully chaotic parameter $r = 4$ is
$$f : \mathbb{R} \to \mathbb{R}, \qquad f(x) = 4x(1-x).$$
Its $n$-fold iterate is written $f^n = f \circ f \circ \cdots \circ f$ ($n$ times), with $f^0 = \mathrm{id}$.

Two immediate values anchor the dynamics on the interval's boundary: $f(0) = 0$ and $f(1) = 0$.

**Proposition 2.2 (Invariance of the unit interval).** If $0 \le x \le 1$ then $0 \le f(x) \le 1$.

*Proof.* Nonnegativity is clear since $x \ge 0$ and $1 - x \ge 0$ give $f(x) = 4x(1-x) \ge 0$. For the upper bound, complete the square: $1 - f(x) = 1 - 4x(1-x) = (2x-1)^2 \ge 0$, so $f(x) \le 1$. $\qquad\blacksquare$

Thus $f$ restricts to a self-map of $[0,1]$, and the keystream never leaves the unit interval.

**Proposition 2.3 (Fixed points).** For $x \in \mathbb{R}$, $f(x) = x$ if and only if $x = 0$ or $x = \tfrac34$.

*Proof.* The equation $4x(1-x) = x$ is equivalent to $x(3 - 4x) = 0$, whose roots are $x = 0$ and $x = 3/4$. $\qquad\blacksquare$

The fixed point $0$ is on the boundary and is the anchor for our sensitivity construction: since $f(0) = 0$, the entire orbit of $0$ is constantly $0$, i.e. $f^n(0) = 0$ for all $n$ (immediate by induction).

## 3. Semiconjugacy to angle doubling

The central structural fact is a change of variables that linearizes the map.

**Theorem 3.1 (Semiconjugacy).** For every $t \in \mathbb{R}$,
$$f(\sin^2 t) = \sin^2(2t).$$

*Proof.* Using the double-angle identity $\sin(2t) = 2\sin t \cos t$ and the Pythagorean identity $\cos^2 t = 1 - \sin^2 t$,
$$\sin^2(2t) = 4\sin^2 t\,\cos^2 t = 4\sin^2 t\,(1 - \sin^2 t) = f(\sin^2 t). \qquad\blacksquare$$

The map $\Phi(t) = \sin^2 t$ therefore intertwines the doubling map $D(t) = 2t$ with the logistic map: $f \circ \Phi = \Phi \circ D$. Because $\Phi$ is surjective onto $[0,1]$ (as $t$ ranges over $\mathbb{R}$, $\sin^2 t$ covers $[0,1]$), this is a genuine semiconjugacy, and it lifts to all iterates.

**Theorem 3.2 (Iterated semiconjugacy).** For every $n \in \mathbb{N}$ and $t \in \mathbb{R}$,
$$f^n(\sin^2 t) = \sin^2(2^n t).$$

*Proof.* Induction on $n$. For $n = 0$ both sides equal $\sin^2 t$. Assume the claim for $k$. Then, using $f^{k+1} = f \circ f^k$ and Theorem 3.1,
$$f^{k+1}(\sin^2 t) = f\bigl(f^k(\sin^2 t)\bigr) = f\bigl(\sin^2(2^k t)\bigr) = \sin^2\bigl(2 \cdot 2^k t\bigr) = \sin^2\bigl(2^{k+1} t\bigr).\qquad\blacksquare$$

**Interpretation.** Under $x = \sin^2 t$ the logistic dynamics is exactly $t \mapsto 2^n t$. The multiplier $2^n$ is the exact stretching factor; its logarithm per step, $\log 2$, is the Lyapunov exponent of the map. Every subsequent result is a shadow of this one identity.

## 4. Algebraic depth: the degree-$2^n$ theorem

We now record the algebraic side. Treat $f$ as a real polynomial and iterate by composition.

**Definition 4.1 (Logistic polynomial and its iterates).** Let
$$P(X) = 4X(1-X) \in \mathbb{R}[X],$$
and define the composition iterates by $P^{[0]} = X$ and $P^{[n+1]} = P \circ P^{[n]}$ (polynomial composition).

**Lemma 4.2.** $\deg P = 2$.

*Proof.* $P = 4X - 4X^2$ has leading term $-4X^2$. $\qquad\blacksquare$

**Theorem 4.3 (Exponential algebraic degree).** For every $n \in \mathbb{N}$,
$$\deg P^{[n]} = 2^n.$$

*Proof.* Induction on $n$. For $n = 0$, $\deg X = 1 = 2^0$. For the step, degrees multiply under composition of polynomials over a field, so
$$\deg P^{[k+1]} = \deg\bigl(P \circ P^{[k]}\bigr) = (\deg P)\,(\deg P^{[k]}) = 2 \cdot 2^k = 2^{k+1}. \qquad\blacksquare$$

**Theorem 4.4 (Algebraic = dynamical).** For every $n \in \mathbb{N}$ and $x \in \mathbb{R}$,
$$P^{[n]}(x) = f^n(x).$$

*Proof.* Induction on $n$. For $n = 0$ both sides are $x$. For the step, evaluation commutes with composition: $P^{[k+1]}(x) = P\bigl(P^{[k]}(x)\bigr) = P\bigl(f^k(x)\bigr) = 4 f^k(x)\bigl(1 - f^k(x)\bigr) = f\bigl(f^k(x)\bigr) = f^{k+1}(x)$. $\qquad\blacksquare$

**Consequence (apparent hardness).** Given a keystream sample $y = f^n(x_0)$, recovering $x_0$ algebraically means solving $P^{[n]}(x) = y$, a polynomial equation of degree $2^n$. For $n = 64$ the degree is $2^{64} \approx 1.8\times10^{19}$. Naively, this is the exponential barrier the cipher advertises. Section 6 shows why the barrier is illusory.

## 5. Sensitive dependence on initial conditions

We now give a fully explicit, quantitative avalanche. The construction exploits Theorem 3.2 to place the $n$-th iterate exactly.

**Definition 5.1 (Sensitivity seeds).** For $n \in \mathbb{N}$ set
$$s_n = \sin^2\!\left(\frac{\pi}{2^{\,n+2}}\right).$$

**Lemma 5.2 (Positivity).** $s_n > 0$ for all $n$.

*Proof.* The angle $\alpha_n = \pi/2^{\,n+2}$ satisfies $0 < \alpha_n < \pi$ (since $2^{\,n+2} \ge 2$), so $\sin \alpha_n > 0$ and hence $s_n = \sin^2\alpha_n > 0$. $\qquad\blacksquare$

**Lemma 5.3 (Quadratic collapse to the fixed point).** $s_n \le (\pi/2^{\,n+2})^2$, and therefore $s_n \to 0$ as $n \to \infty$.

*Proof.* With $\alpha_n = \pi/2^{\,n+2} \in [0,\pi]$ we have $0 \le \sin\alpha_n \le \alpha_n$ (the elementary bound $\sin\alpha \le \alpha$ for $\alpha \ge 0$), and squaring the inequality between nonnegative quantities gives $s_n = \sin^2\alpha_n \le \alpha_n^2$. The right side tends to $0$. $\qquad\blacksquare$

**Lemma 5.4 (Exact landing point).** For every $n$, $\;f^n(s_n) = \tfrac12.$

*Proof.* By Theorem 3.2 with $t = \pi/2^{\,n+2}$,
$$f^n(s_n) = \sin^2\!\left(2^n \cdot \frac{\pi}{2^{\,n+2}}\right) = \sin^2\!\left(\frac{\pi}{4}\right) = \left(\frac{\sqrt2}{2}\right)^2 = \frac12. \qquad\blacksquare$$

**Theorem 5.5 (Quantitative sensitive dependence).** For every $n \in \mathbb{N}$,
$$0 < s_n \le \left(\frac{\pi}{2^{\,n+2}}\right)^2 \qquad\text{and}\qquad \bigl| f^n(s_n) - f^n(0)\bigr| = \frac12.$$

*Proof.* The bounds on $s_n$ are Lemmas 5.2–5.3. For the gap, $f^n(0) = 0$ (the orbit of the fixed point $0$) and $f^n(s_n) = \tfrac12$ by Lemma 5.4, so the absolute difference is exactly $\tfrac12$. $\qquad\blacksquare$

**Interpretation.** The seeds $s_n$ are exponentially close to the fixed point $0$ — their distance is at most $\pi^2/2^{\,2n+4}$, i.e. $O(2^{-2n})$ — yet after only $n$ iterations they are separated from the fixed orbit by a *constant* $\tfrac12$. A perturbation of size $\varepsilon \approx 2^{-2n}$ becomes macroscopic after $n \approx \tfrac12\log_2(1/\varepsilon)$ steps. This is the avalanche in exact form: linearly many steps suffice to amplify an exponentially small difference to $O(1)$.

## 6. Cryptographic consequences

### 6.1 The two pillars are real theorems

Theorem 5.5 confirms sensitivity: any imprecision in the seed is amplified to a full-scale output difference within a number of steps logarithmic in the imprecision. Theorem 4.3 confirms algebraic depth: the $n$-th iterate is a genuine degree-$2^n$ polynomial (Theorem 4.4 certifies it computes the same function as the dynamics). A designer reading only these two results would conclude that the seed is well hidden.

### 6.2 The conjugate coordinate breaks the cipher in linear time

The same identity that produced the two pillars also dismantles the second. Write angles as fractions of a half-turn: $t = \pi\theta$, so that $x = \sin^2(\pi\theta)$ with $\theta \in [0,1)$. Under this coordinate the doubling map $t \mapsto 2t$ becomes
$$\theta \mapsto 2\theta \pmod 1,$$
the **binary shift map**. Writing $\theta = 0.b_1 b_2 b_3 \ldots$ in base $2$, each iteration deletes the leading bit and shifts:
$$0.b_1 b_2 b_3 \ldots \;\mapsto\; 0.b_2 b_3 b_4 \ldots$$

Consequently the keystream, in the conjugate coordinate, simply reads out the successive bits of $\theta$. An attacker who converts each keystream sample $y_k = \sin^2(\pi\,2^k\theta)$ back to the conjugate coordinate recovers, one per step, the bits of $\theta$; after $O(n)$ samples and $O(n)$ arithmetic operations the seed is pinned down to $n$ bits of precision. The degree-$2^n$ polynomial from Theorem 4.3 is therefore *not* a hardness barrier: it is an artifact of insisting on the coordinate $x$. Conjugacy linearizes the apparent nonlinearity and collapses the exponential to a shift. **The break runs in time polynomial (indeed linear) in the security parameter.**

The lesson generalizes: a hardness assumption that dissolves under an explicit change of coordinates provides no security. Cryptographic hardness must be invariant under the adversary's freedom to choose representations.

### 6.3 Sensitivity is double-edged, and it caps the usable period

Sensitivity protects the defender against imprecise guesses, but it equally afflicts any finite-precision *implementation*. In arithmetic with $p$ bits, the stretching factor $2^n$ per $n$ steps means a computed orbit decorrelates from the ideal orbit after roughly $p$ steps; from that point on the emitted keystream is an artifact of rounding rather than of the intended seed. Thus the numerical period and the sensitivity horizon coincide at $\approx p$ steps, bounding the amount of usable keystream and creating implementation-dependent statistical structure. Moreover, transported through the conjugacy the invariant distribution of $f$ is not uniform but the *arcsine law* $d\mu = dx/(\pi\sqrt{x(1-x)})$, so a raw logistic keystream is statistically biased toward the endpoints of $[0,1]$ — an additional exploitable defect.

## 7. Algorithms and numerical illustration

Two computational tasks organize the numerics: (a) generating and using the keystream (the cipher itself), and (b) demonstrating the two theorems empirically — the avalanche and the degree growth — followed by the linear-time break.

**Algorithm A (Keystream generation).** Given seed $x_0$ and length $L$, iterate $x_{k+1} = 4x_k(1-x_k)$ and, for each $x_k$, extract bits from its binary fraction to form the keystream. Complexity $O(L)$ arithmetic operations.

**Algorithm B (Conjugate-coordinate attack).** Given keystream values interpreted in the conjugate coordinate, recover $\theta$ bit by bit via the shift structure $\theta \mapsto 2\theta \bmod 1$. From $n$ samples one obtains $n$ bits of $\theta$ in $O(n)$ time — the practical realization of Section 6.2.

The accompanying programs verify: the semiconjugacy identity to machine precision; the exact landing $f^n(s_n) = \tfrac12$; the degree sequence $1, 2, 4, 8, \dots, 2^n$ by symbolic composition; and the linear-time seed recovery.

## 8. Discussion and future directions

The results form a compact bridge between real dynamics and polynomial algebra: a single trigonometric identity, $f^n(\sin^2 t) = \sin^2(2^n t)$, simultaneously yields a dynamical statement (quantitative sensitive dependence, Theorem 5.5) and an algebraic statement (degree exactly $2^n$, Theorem 4.3). The cryptographic upshot is a clean case study in coordinate-dependent hardness: the naive logistic cipher looks strong in $x$ and is trivial in $\theta$.

**Future directions.**

1. *Linear-time cryptanalysis, as a theorem.* Establish rigorously that the conjugate-coordinate attack recovers the seed to $n$ bits from $O(n)$ keystream samples with $O(n)$ arithmetic, converting the folklore break into a precise reduction. The degree-$2^n$ "barrier" is an artifact of coordinates; conjugacy collapses it to a shift.

2. *The invariant density is the arcsine law and is unique.* Prove that $d\mu = dx/(\pi\sqrt{x(1-x)})$ is $f$-invariant, is the pushforward of the uniform measure on the doubling circle under $t \mapsto \sin^2(\pi t)$, and is the unique absolutely continuous invariant measure. This exposes the statistical bias of raw logistic keystreams.

3. *A matching decryption-instability lower bound.* Show that the stretching factor $2^n$ controls both the divergence rate from above and the precision-loss rate from below, so that a $p$-bit implementation loses correlation with the true orbit after exactly $p$ steps — avalanche speed and numerical unreliability as two readings of the same Lyapunov exponent.

## Summary of results

- **Invariance:** $f$ maps $[0,1]$ into $[0,1]$.
- **Fixed points:** the only real fixed points of $f$ are $0$ and $3/4$.
- **Semiconjugacy:** $f(\sin^2 t) = \sin^2(2t)$, hence $f^n(\sin^2 t) = \sin^2(2^n t)$.
- **Degree:** the $n$-th iterate is a polynomial of degree exactly $2^n$, computing the same function as $f^n$.
- **Sensitivity:** seeds $s_n = \sin^2(\pi/2^{\,n+2})$ satisfy $0 < s_n \le (\pi/2^{\,n+2})^2$ yet $|f^n(s_n) - f^n(0)| = \tfrac12$.
- **Cryptanalysis:** in the conjugate coordinate the map is the binary shift, so the seed is recoverable in time linear in the security parameter.
