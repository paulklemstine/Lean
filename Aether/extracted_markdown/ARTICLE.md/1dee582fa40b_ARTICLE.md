# The Last Magic Number

## Why 163 is the climax of a deep theorem in algebraic number theory

---

In 1975, Martin Gardner published his famous April Fools' column in *Scientific American*, claiming that the Indian mathematician Srinivasa Ramanujan had shown that e raised to the power of π times the square root of 163 is exactly an integer. Gardner was joking — but barely. The number e^(π√163) equals 262,537,412,640,768,743.99999999999925..., missing a whole number by less than a trillionth. This is not a coincidence, not a trick, and not an approximation that happens to work. It is the shadow of one of the most beautiful theorems in mathematics.

## A Polynomial That Shouldn't Work

The story begins in 1772, when Leonhard Euler noticed something peculiar about the formula x² + x + 41. Plug in x = 0 and you get 41 — a prime. Try x = 1: you get 43, also prime. In fact, Euler checked every value from 0 to 39, and every single output was prime. Forty consecutive primes from a single quadratic formula. Nothing else in mathematics comes close.

Why does this work? The answer lies in a number that appears nowhere in the formula itself: 163. Compute the discriminant of x² + x + 41 — the quantity b² − 4ac that governs the behavior of any quadratic — and you get 1 − 164 = −163. The polynomial's prime-generating power is secretly controlled by the number 163.

But this raises a deeper question: what is special about 163?

## The Nine Lucky Numbers

In the early nineteenth century, Carl Friedrich Gauss was developing the theory of binary quadratic forms — expressions like ax² + bxy + cy² — as part of his monumental *Disquisitiones Arithmeticae*. He discovered that for each negative discriminant D, the quadratic forms of that discriminant naturally group into equivalence classes. The number of classes, called the *class number* h(D), measures the complexity of the arithmetic in the corresponding number system.

When the class number is 1, the arithmetic is as simple as it can be: every number factors uniquely into primes, just like the ordinary integers. Gauss conjectured that only finitely many negative discriminants have class number 1, and he found nine candidates: D = −3, −4, −7, −8, −11, −19, −43, −67, and −163.

These correspond to nine positive integers — 1, 2, 3, 7, 11, 19, 43, 67, and 163 — known today as the *Heegner numbers*, after the German mathematician Kurt Heegner, who published a proof in 1952 that Gauss's list was complete. (His proof was initially rejected as incomplete; it was later vindicated by Harold Stark and others.)

The Heegner numbers are the nine integers d for which the imaginary quadratic field Q(√(−d)) has class number 1. They are the last outposts of arithmetic simplicity in the landscape of algebraic number fields. And 163, the largest, is the final one.

## The Rabinowitz Criterion

The connection between Heegner numbers and prime-generating polynomials is not accidental — it is a theorem. In 1913, Georg Rabinowitz proved that the polynomial x² + x + p produces prime values for x = 0, 1, ..., p−2 if and only if the discriminant 1 − 4p has class number 1. Since 1 − 4·41 = −163 and 163 is a Heegner number, Euler's polynomial generates 40 consecutive primes.

But the criterion works for every Heegner number congruent to 3 modulo 4. For d = 7, the polynomial x² + x + 2 gives primes at x = 0 (which yields 2, prime!). For d = 11, x² + x + 3 gives primes for x = 0, 1. For d = 19, x² + x + 5 gives primes for x = 0, 1, 2, 3. Each Heegner number yields a longer run of primes, and 163 — the largest — gives the longest run of all.

At x = p − 1, the magic always ends in the same way: f(p−1) = (p−1)² + (p−1) + p = p², a perfect square. The Rabinowitz boundary is sharp and elegant.

## The j-Invariant and Ramanujan's Near-Miss

The connection to Ramanujan's constant requires a deeper piece of mathematics: the j-invariant, a function from the theory of modular forms that assigns to each point τ in the upper half of the complex plane a complex number j(τ). The j-invariant is a kind of master function for elliptic curves — it classifies their algebraic structure.

When τ = (1 + √(−d))/2 for a Heegner number d ≡ 3 (mod 4), the j-invariant takes a remarkable value: an algebraic integer. For d = 163, the value is j = −640320³ = −262,537,412,640,768,000. The Fourier expansion of the j-function begins j(τ) = e^(−2πiτ) + 744 + ..., and when you evaluate this at our special τ, you get:

e^(π√163) ≈ 640320³ + 744 = 262,537,412,640,768,744

The error is approximately 7.5 × 10⁻¹³ — less than a trillionth. The near-integer phenomenon is the shadow of the algebraic integer property of the j-invariant.

The number 640320 itself has a beautiful factorization: 640320 = 2⁶ × 3 × 5 × 23 × 29. These are not random primes — they are connected to the structure of the Monster group, the largest sporadic simple group in mathematics, through what John Conway and Simon Norton called "monstrous moonshine."

## A Hierarchy of Near-Misses

The near-integer property works for every Heegner number, not just 163. For d = 67, e^(π√67) misses an integer by about 10⁻⁶. For d = 43, the miss is about 10⁻⁴. As d increases, the approximation gets exponentially better, because the error term in the j-function expansion decreases as e^(−π√d).

This creates a beautiful hierarchy: the Rabinowitz constant p = (d+1)/4 measures both the length of the prime-generating run and the quality of the near-integer approximation. For d = 163, p = 41 — the largest value — and both phenomena are at their most spectacular.

## The End of the Line

Perhaps the most remarkable thing about 163 is that it is the *last* Heegner number. The Stark-Heegner theorem, completed definitively by Harold Stark in 1967, proves that no integer greater than 163 has the class number 1 property. There is no d = 164 or d = 1000 waiting to be discovered that would give an even more spectacular near-integer or an even longer prime-generating run.

The sequence 1, 2, 3, 7, 11, 19, 43, 67, 163 is complete. It is a finite window into arithmetic perfection — nine numbers for which the algebra is as clean as possible — and 163 is its magnificent conclusion.

The sum of all nine Heegner numbers is 316. The product is 1, 2, 3, 7, 11, 19, 43, 67, 163 multiplied together. But these numerical curiosities pale beside the structural truth: 163 is not a number that happens to be interesting. It is a number that *must* be interesting, because it sits at the intersection of prime generation, modular forms, elliptic curves, and the deep architecture of algebraic number theory.

## What 163 Teaches Us

The story of 163 is a story about why mathematics is unreasonably effective at surprising us. A polynomial from the eighteenth century, a transcendental number from the nineteenth, and a theorem from the twentieth all converge on the same nine numbers — and the same final number, 163.

It is not magic. It is something better: it is inevitable.

---

*The Heegner numbers are named after Kurt Heegner (1893–1965), a German mathematician and radio engineer who published his proof of Gauss's conjecture in 1952. His work was underappreciated during his lifetime but has since been recognized as fundamentally correct. Harold Stark independently proved the result in 1967, and the combined result is known as the Stark-Heegner theorem.*
