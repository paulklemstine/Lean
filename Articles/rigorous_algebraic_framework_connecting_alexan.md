# The Hidden Mathematics of Knotted Light

## How Torus Knots Encode the Deep Structure of Numbers

In a small laboratory at the intersection of optics and pure mathematics, something extraordinary is happening. Beams of light, twisted into intricate knot patterns, are revealing connections to some of the oldest objects in number theory — connections that mathematicians have only recently begun to understand.

The story begins with a deceptively simple question: what happens when you tie light into a knot?

## Twisted Photons and Ancient Polynomials

Since the 1990s, physicists have known that photons can carry orbital angular momentum (OAM) — a kind of corkscrew twist that makes a laser beam spiral as it propagates. Each twist pattern defines a distinct channel, and engineers have exploited this to send multiple data streams through a single fiber by encoding information in different OAM modes. The question is: how many independent channels does a given knot pattern support?

The answer turns out to involve a polynomial that James Waddell Alexander II introduced in 1928 to distinguish knots. The **Alexander polynomial** of a knot is a mathematical fingerprint — different knots typically have different polynomials, making them invaluable for classifying the tangled curves that arise in everything from DNA folding to quantum field theory.

For the simplest family of knots — the **torus knots** T(2,n), which wrap twice around a torus while winding n times — the Alexander polynomial takes a strikingly elegant form:

$$A_n(X) = 1 - X + X^2 - X^3 + \cdots + X^{n-1}$$

This alternating sum of powers, familiar to any calculus student as a partial geometric series, turns out to encode profound number-theoretic information.

## The Fundamental Identity

The key discovery is a single algebraic equation that connects the Alexander polynomial to the arithmetic of powers:

$$(X + 1) \cdot A_n(X) = X^n + 1$$

This identity, valid for any odd n, says that multiplying the Alexander polynomial by the simplest possible factor — just X plus 1 — produces the sum of two perfect powers. The proof uses nothing more than the geometric series formula, yet its consequences ripple across mathematics.

Why does this matter? Because the expression X^n + 1 is one of the most studied objects in number theory. Its factorization over the integers is completely controlled by **cyclotomic polynomials** — the minimal polynomials of roots of unity, those special complex numbers that return to 1 when raised to an integer power.

## The Cyclotomic Bridge

Here is where the story becomes remarkable. For any odd prime p, the 2p-th cyclotomic polynomial Φ_{2p}(X) — the polynomial whose roots are the primitive 2p-th roots of unity — satisfies exactly the same equation:

$$(X + 1) \cdot \Phi_{2p}(X) = X^p + 1$$

Since integer polynomials form an algebraic structure where you can cancel common factors (technically, an integral domain), the only conclusion is:

$$A_p(X) = \Phi_{2p}(X)$$

The Alexander polynomial of the torus knot T(2,p) **is** the cyclotomic polynomial Φ_{2p}. Not analogous to it, not related to it — it is literally the same mathematical object. A topological invariant of knotted curves equals an arithmetic invariant of roots of unity.

This is the cyclotomic bridge: knot theory and number theory, two seemingly unrelated branches of mathematics, meet at this precise polynomial identity.

## Counting Channels with Euler's Totient

The bridge has immediate practical consequences. The number of primitive n-th roots of unity is counted by Euler's totient function φ(n), one of the most fundamental functions in number theory. A beautiful identity states that for any odd n:

$$\varphi(2n) = \varphi(n)$$

The proof is elementary: since n is odd, 2 and n share no common factors, so φ(2n) = φ(2) · φ(n) = 1 · φ(n) = φ(n). But the interpretation is profound: the number of OAM channels available in a 2n-fold symmetric configuration equals the number available in an n-fold one. Doubling the geometric symmetry of your knotted light beam adds no new independent channels.

For engineers designing OAM-multiplexed communication systems, this is a concrete constraint: the information capacity of a knotted beam is determined by the odd part of its winding number, and no amount of even-fold symmetry enhancement can increase it.

## The Spectral Dichotomy

The palindromic structure of Alexander polynomials — the fact that their coefficients read the same forwards and backwards — leads to a remarkable classification. Any palindromic quadratic polynomial X² - bX + 1 falls into exactly one of two categories:

- **Crystalline**: when b² < 4, both roots lie on the unit circle, dancing among the roots of unity. The polynomial behaves like a piece of cyclotomic machinery, rigid and periodic.

- **Metallic**: when b² ≥ 4, the roots break free from the unit circle and become real numbers. The golden ratio φ = (1 + √5)/2 is the most famous example, arising from X² - X - 1 (or equivalently, X² - 3X + 1 after normalization).

This dichotomy — crystalline versus metallic — is controlled by a single integer invariant: the discriminant b² - 4. There is no gradual transition, no intermediate phase. The polynomial either lives on the unit circle or it doesn't, and the boundary is razor-sharp.

For torus knots, the small cases (p = 3, 5, 7) are all crystalline — their Alexander polynomials are cyclotomic, and every root is a root of unity. The spectral question for larger composite knot parameters remains an active area of investigation.

## Palindromes and Mirrors

One of the most elegant results is that the Alexander polynomial of T(2,n) is palindromic for all odd n. The coefficient of X^i equals the coefficient of X^{n-1-i}. In concrete terms:

$$1 - X + X^2 - X^3 + \cdots - X^{n-2} + X^{n-1}$$

reads the same from either end (up to the overall sign pattern). This mirror symmetry reflects the topological fact that the torus knot T(2,n) looks the same from either side of the torus — a symmetry of the knot becomes a symmetry of its polynomial invariant.

The proof is a gem of parity arithmetic: since n is odd, n-1 is even, and the signs (-1)^i and (-1)^{n-1-i} differ by the factor (-1)^{n-1} = 1. The mirror symmetry of the polynomial is a direct consequence of the oddness of the knot parameter.

## Evaluating at the Edge

A striking computational fact: evaluating the Alexander polynomial at X = -1 always gives n, the winding number of the knot:

$$A_n(-1) = n$$

Each term (-(-1))^i = 1^i = 1 contributes exactly 1 to the sum, and there are n terms. This evaluation is a knot invariant — it detects the winding number directly from the polynomial, providing a bridge between algebraic and geometric descriptions of the knot.

## What It All Means

The cyclotomic knot spectrum framework reveals that torus knots are not merely topological curiosities — they are physical manifestations of deep number-theoretic structure. The Alexander polynomial of T(2,p) being identical to the cyclotomic polynomial Φ_{2p} means that the topology of a knotted curve in three-dimensional space is completely determined by the arithmetic of roots of unity in the complex plane.

This connection suggests that other knot invariants — the Jones polynomial, the HOMFLY polynomial, the colored Jones polynomials — might similarly encode hidden arithmetic. If the Alexander polynomial is cyclotomic, what number-theoretic objects might the Jones polynomial conceal?

The answer to that question may reshape our understanding of both knot theory and number theory, revealing that the mathematical structures governing tangled curves and the mathematical structures governing the distribution of prime numbers are, at some deep level, the same.

---

*The mathematics described in this article builds on classical results in algebraic knot theory and cyclotomic number theory, synthesized through a framework that reveals their precise algebraic connection.*
