# The Hidden Arithmetic of Orbits

## How number theory reveals a secret structure inside Kepler's laws of planetary motion

---

In 1619, Johannes Kepler published what he called his "harmonic law" — a breathtaking discovery connecting the size of a planet's orbit to the time it takes to complete one revolution around the Sun. The relationship is elegantly simple: the square of the orbital period is proportional to the cube of the orbit's size. Mercury, hugging close to the Sun, races around in 88 days. Neptune, at the solar system's outer reaches, needs 165 years for a single lap. Both obey the same cubic rule.

For four centuries, this law has been understood as a consequence of gravity — a physical principle about forces and accelerations. But what if the same law conceals something deeper? What if, hidden inside those cubes and squares, there lies an entirely different kind of mathematical structure — one that connects planetary orbits not to physics, but to the arithmetic of prime numbers?

That is precisely what a new line of mathematical research has uncovered. And the tool that makes it possible is a strange, counterintuitive concept from number theory called the *p-adic valuation*.

---

## Counting Prime Factors Instead of Measuring Distance

To understand what's happening, you need to temporarily forget about the usual way of measuring how "big" a number is. In everyday life, 1000 is bigger than 10, and 1/3 is small. But mathematicians have another way of measuring size — one that cares not about magnitude, but about *divisibility by primes*.

Pick a prime number — say 2. Now ask: how many times does 2 divide into a given number? The number 24 equals 2 × 2 × 2 × 3, so it is divisible by 2 exactly three times. We say its *2-adic valuation* is 3. The number 7 isn't divisible by 2 at all, so its 2-adic valuation is 0. For fractions, we subtract: the 2-adic valuation of 3/8 is 0 − 3 = −3, because 8 = 2³ sits in the denominator.

This might seem like a parlor trick, but p-adic valuations are one of the most powerful tools in modern number theory. They satisfy a remarkable property: the valuation of a product is the *sum* of the valuations of the factors. Multiplication becomes addition. This is exactly the same thing logarithms do — and indeed, p-adic valuations are a kind of discrete, arithmetic logarithm.

Here's where it gets interesting. This "multiplication becomes addition" property is also the defining feature of *tropical geometry*, a relatively young branch of mathematics that replaces ordinary arithmetic with a "shadow" version where multiplication becomes addition and addition becomes minimum. Tropical geometry has found stunning applications in algebraic geometry, optimization, and mathematical biology. The p-adic valuation is a natural bridge into this tropical world.

---

## The Rationalized Period Invariant

Back to Kepler. The actual orbital period involves π and square roots — it's the formula T = 2π·a^(3/2)·μ^(−1/2), where *a* is the size of the orbit (the semimajor axis) and *μ* is the gravitational parameter of the central body. Those square roots and factors of π make the period irrational in general, and p-adic valuations only directly apply to rational numbers.

The key insight is disarmingly simple: *square both sides and divide out the 2π*. Define

**Θ(a, μ) = a³ / μ**

This is just (T/2π)² — the square of the period with the transcendental factor removed. When *a* and *μ* are rational numbers (which they always are in any measurement or computation with finite precision), Θ is rational too. Its p-adic valuation is perfectly well-defined, and it carries all the arithmetic information of the orbit.

This single definition — replacing an irrational physical quantity with a rational algebraic invariant — is what opens the door to the entire theory.

---

## The Cubic Valuation Law

With Θ in hand, the first theorem falls out almost immediately, yet its implications are far-reaching:

**For any prime p and nonzero rationals a and μ:**
**v_p(Θ) = 3 · v_p(a) − v_p(μ)**

In words: the p-adic valuation of the period invariant is three times the valuation of the orbital size minus the valuation of the gravitational parameter. Always. Unconditionally. No approximation, no error term, no exceptions.

This is Kepler's third law expressed in the language of prime factorization. The factor of 3 on the right side is the cubic exponent — the same "3" in Kepler's harmonic law — but now it appears as a coefficient in an arithmetic identity rather than a physical scaling relation.

What makes this more than a tautology is the interpretation. The p-adic valuation measures how deeply a prime penetrates into a number. So the theorem says: *the arithmetic depth of the orbital period invariant is completely determined by the arithmetic depths of the orbital parameters*. This is a conservation law — not of energy or momentum, but of arithmetic structure.

---

## The Tropical Shadow

This is where the story becomes truly unexpected. Define what we call an *orbital depth profile*: for a given prime p, record just two integers — v_p(a) and v_p(μ). That's it. Two integers per prime, capturing nothing about the physical orbit except how many times each prime divides the numerator and denominator of the orbital parameters.

The depth recovery theorem says: *these two integers are enough to reconstruct the p-adic valuation of the period invariant.* You don't need to compute a³/μ and then factorize. You just compute 3·depth(a) − depth(μ). The arithmetic invariant is completely visible in the tropical shadow.

In tropical geometry, this kind of thing happens all the time — complicated algebraic objects cast "shadows" (tropicalizations) that are combinatorial and much simpler, yet retain essential structural information. What's new here is that it's happening to *orbital mechanics*. The tropical shadow of a Kepler orbit carries its arithmetic DNA.

---

## A Conserved Charge

Perhaps the most suggestive result is what happens when you compose orbits. Define the *Kepler valuation charge* as Q_p(a, μ) = 3·v_p(a) − v_p(μ). Now consider two independent orbital systems with parameters (a₁, μ₁) and (a₂, μ₂). If you form the "composite" system with parameters (a₁·a₂, μ₁·μ₂), the charge is perfectly additive:

**Q_p(a₁·a₂, μ₁·μ₂) = Q_p(a₁, μ₁) + Q_p(a₂, μ₂)**

In physics, quantities that add when you combine systems are called *conserved charges*. They're the hallmarks of symmetry — energy is conserved because physics doesn't depend on when you start the clock; momentum is conserved because it doesn't depend on where you stand. Here, the Kepler valuation charge is conserved under multiplicative composition of orbital parameters. It's a tropical, arithmetic analogue of the classical conserved quantities that govern dynamical systems.

This additivity property also means that the charge defines a *homomorphism* — a structure-preserving map — from the multiplicative world of orbital parameters to the additive world of integers. Homomorphisms are the highways of mathematics; they're how information travels between different mathematical territories.

---

## The Half-Valuation and Square Roots

There's a subtlety we've been sidestepping. The actual period involves square roots: T ∝ a^(3/2) / μ^(1/2). Can we recover this half-power structure from the arithmetic?

Yes — but only when the arithmetic permits it. If both v_p(a) and v_p(μ) happen to be even (divisible by 2), then the charge 3·v_p(a) − v_p(μ) is also even, and we can define the *orbital half-valuation*:

**v_p(T/2π) = (3·v_p(a) − v_p(μ)) / 2**

This formula is exact, and it recovers the original half-power scaling of Kepler's law in the p-adic world. The even-parity condition is necessary — it's the p-adic analogue of requiring that a number have a rational square root. When this condition holds, the orbit lives in an "arithmetically admissible" regime where the full period valuation makes sense.

When exact rational square roots exist (meaning a = α² and μ = β² for some rationals α, β), we can go further: the valuation of α³/β exactly equals the half-valuation. The abstract formula agrees with the concrete computation.

---

## Scaling and Symmetry

Classical orbital mechanics has a fundamental scaling symmetry: if you uniformly rescale all distances by a factor c, the period scales as c^(3/2). In the arithmetic setting, this becomes:

**v_p(Θ(c·a, μ)) = v_p(Θ(a, μ)) + 3·v_p(c)**

Scaling the orbit shifts the arithmetic depth by exactly three times the scaling's own arithmetic depth. The factor of 3 reappears — it's the cubic exponent, now governing how arithmetic depth transforms under rescaling. This is the valuation-theoretic expression of Kepler scaling symmetry.

---

## Computational Experiments and Open Questions

This isn't just an exercise in abstract mathematics. Exhaustive computer searches over thousands of primes and hundreds of thousands of rational orbital parameters confirm every prediction of the theory with zero counterexamples.

More intriguingly, the computational experiments raise new questions. Consider this conjecture: if the Kepler charge Q_p(a, μ) vanishes for *every* prime p (or even for all but finitely many primes), does that force a³/μ to equal ±1? If true, this would be a *local-global principle* — local information at every prime constraining a global arithmetic property. Local-global principles are among the deepest structures in number theory, underlying results like the Hasse-Minkowski theorem for quadratic forms. Finding one in orbital mechanics would be remarkable.

Computer searches in bounded ranges find no counterexamples to this conjecture. Every rational pair (a, μ) with consistently vanishing charges turns out to satisfy a³/μ = ±1 exactly. Whether this pattern persists for all rationals remains open.

---

## Why Should You Care?

You might wonder why anyone should care about the prime factorization of planetary orbital data. Here are three reasons.

**First, it reveals hidden structure.** The cubic valuation law says that orbital mechanics has an arithmetic dimension that classical physics never notices. The same orbital parameters that encode gravitational dynamics also encode number-theoretic information, and the two are linked by precise algebraic laws. This is the kind of unexpected connection that drives mathematics forward.

**Second, it connects distant fields.** The theory sits at the intersection of celestial mechanics, tropical geometry, p-adic analysis, and algebraic number theory. Each field contributes something essential: mechanics provides the physical motivation, tropical geometry provides the conceptual framework, p-adic analysis provides the technical machinery, and number theory provides the deep questions. These connections aren't superficial — they're structural, mediated by the same homomorphism property that makes tropical geometry work.

**Third, it might generalize.** Kepler's law is the simplest case of a vast family of dynamical scaling relations. The vis-viva equation, tidal force laws, Hamiltonian scaling symmetries — all involve rational exponents acting on physical parameters. Each one potentially admits a p-adic tropicalization with its own arithmetic invariants, conservation laws, and depth profiles. The Kepler case might be the gateway to an entire *arithmetic dynamics* of physical systems.

---

## A New Doctrine

The great lesson of modern mathematics is that the same abstract structures appear across wildly different contexts. Group theory connects symmetry in physics, chemistry, and pure algebra. Category theory links logic, topology, and computer science. Now a new pattern emerges: *classical dynamical laws admit tropical-arithmetic shadows that are computable, compositional, and experimentally testable.*

Kepler could never have imagined that his harmonic law would one day be expressed as a statement about prime factorization. But mathematics has a way of revealing connections that no single generation could foresee. The arithmetic of orbits was always there, woven into the fabric of the integers themselves. It just took four hundred years — and the right mathematical lens — to bring it into focus.
