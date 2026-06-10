# The Hidden Arithmetic of Planetary Orbits

*How a centuries-old law of celestial mechanics reveals a secret code written in prime numbers*

---

In 1619, Johannes Kepler published what he considered the crowning achievement of his life's work: a mathematical law connecting the size of a planet's orbit to the time it takes to complete one revolution around the Sun. Mercury, hugging close to the Sun, races through its orbit in just 88 days. Neptune, drifting in the frigid outer reaches, takes 165 years. Kepler discovered that these vastly different periods are locked to their orbital sizes by an exact mathematical relationship — the period squared is proportional to the orbital radius cubed.

For four centuries, this law has been understood as a statement about continuous quantities: distances measured in kilometers, times measured in seconds, calculations carried out with the familiar arithmetic of real numbers. But what if there is another way to read Kepler's law — a way that reveals hidden structure invisible to ordinary calculation?

A new mathematical framework does exactly this, and the results are startling. By viewing orbital mechanics through the lens of *prime number arithmetic*, researchers have uncovered a conserved quantity — a kind of orbital charge — that transforms Kepler's scaling law into something resembling the conservation laws of fundamental physics. The technique draws on a branch of mathematics called *tropical geometry*, which replaces the usual operations of addition and multiplication with simpler combinatorial operations, and connects it to a number-theoretic tool called the *p-adic valuation*, which measures how divisible a number is by a given prime.

The upshot: every planetary orbit carries an arithmetic fingerprint written in the language of prime numbers, and this fingerprint obeys its own conservation law.

## The Trick of the Squared Period

The key insight begins with a simple algebraic maneuver. Kepler's third law says that the orbital period *T* satisfies

$$T = 2\pi \sqrt{a^3 / \mu}$$

where *a* is the semimajor axis (roughly, the average orbital radius) and *μ* is the gravitational parameter of the central body. The square root is the stumbling block — it pulls us out of the world of rational numbers into the realm of irrationals, where prime-number arithmetic loses its grip.

But if we square the period and strip away the factor of 2π, something beautiful happens. The quantity Θ = *a*³/*μ* is a perfectly rational number whenever the orbital parameters are rational. And rational numbers have a rich prime-number structure that real numbers do not.

This quantity Θ — the *rationalized period invariant* — becomes the protagonist of the new theory.

## Counting by Primes

To understand what comes next, we need a tool from number theory: the *p-adic valuation*. For any prime number *p*, the *p*-adic valuation of a rational number *q* counts how many factors of *p* appear in *q*. For example, the 2-adic valuation of 24 is 3 (since 24 = 2³ × 3), and the 3-adic valuation of 24 is 1.

This might sound like a trivial counting exercise, but *p*-adic valuations have extraordinary properties. They convert multiplication into addition: the valuation of a product is the sum of the valuations. And they convert division into subtraction. These properties make them the perfect bridge between multiplicative and additive worlds.

Now apply this tool to the rationalized period invariant Θ = *a*³/*μ*. The *p*-adic valuation of Θ is:

$$v_p(\Theta) = 3 \cdot v_p(a) - v_p(\mu)$$

Three times the prime divisibility of the orbital radius, minus the prime divisibility of the gravitational parameter. This is the **cubic valuation law** — Kepler's third law rewritten as a statement about prime numbers.

## A Conserved Charge

What makes this formula profound, rather than merely clever, is what happens when you combine orbital systems.

Consider two orbits with parameters (*a*₁, *μ*₁) and (*a*₂, *μ*₂). Define the *Kepler valuation charge* as Q_p = 3·v_p(*a*) − v_p(*μ*). Then for the composite system with parameters (*a*₁*a*₂, *μ*₁*μ*₂):

$$Q_p(a_1 a_2, \mu_1 \mu_2) = Q_p(a_1, \mu_1) + Q_p(a_2, \mu_2)$$

The charge is *additive*. Just as energy is conserved when you combine physical systems, the valuation charge is conserved when you compose orbital data. This is not a coincidence or an approximation — it is an exact algebraic identity that holds for every prime *p* and every pair of rational orbital parameters.

In physics, additive conserved quantities are the hallmarks of fundamental symmetries. The valuation charge Q_p is the arithmetic shadow of Kepler's scaling symmetry, translated from the language of continuous geometry into the discrete language of prime factorization.

## The Tropical Shadow

There is a deeper geometric story behind these algebraic identities. *Tropical geometry* is a branch of mathematics that systematically replaces multiplication with addition and addition with taking the minimum. This "tropicalization" operation converts curved algebraic shapes into piecewise-linear ones — think of replacing a smooth hill with a pyramid made of flat planes meeting at sharp ridges.

The *p*-adic valuation is precisely the tropicalization map for prime *p*. When we compute v_p(Θ), we are projecting the orbital period from the curved world of continuous mechanics onto a flat, combinatorial shadow world.

The remarkable discovery is that this shadow is *lossless* for the arithmetic content. Define the *orbital depth profile* as the pair of values (v_p(*a*), v_p(*μ*)) — the tropicalized coordinates of the orbital datum. The cubic valuation law says that the depth profile completely determines the valuation of the period invariant:

$$v_p(\Theta) = 3 \cdot \text{depth}(a) - \text{depth}(\mu)$$

No additional arithmetic data is needed. The tropical shadow contains everything.

## Scaling Symmetry

The theory reveals how orbital arithmetic transforms under physical changes. If you scale the semimajor axis by a rational factor λ — say, you move a satellite to a higher orbit — the valuation of the period invariant shifts by exactly three times the valuation of the scaling factor:

$$v_p(\Theta(\lambda a, \mu)) = v_p(\Theta(a, \mu)) + 3 \cdot v_p(\lambda)$$

This is the valuation-theoretic analogue of Kepler's scaling symmetry. In classical mechanics, doubling the orbital radius multiplies the period by 2√2. In the arithmetic world, doubling the orbital radius adds 3 to the 2-adic valuation charge (since v₂(2) = 1).

## When Square Roots Behave

There is a subtlety we glossed over: the actual period *T* involves a square root of *a*³/*μ*, and square roots of rational numbers are generally irrational. Can we recover the period's prime structure, not just its square's?

The answer is yes, but only when the arithmetic permits it. If both v_p(*a*) and v_p(*μ*) are even numbers, then the expression 3·v_p(*a*) − v_p(*μ*) is also even, and we can define the *orbital half-valuation* as exactly half of this quantity. This half-valuation represents what v_p(*T*/2π) would be if the square root could be taken within the rational or *p*-adic world.

When the orbital parameters happen to be perfect squares — say *a* = α² and *μ* = β² for rational α, β — then the period *T*/2π = α³/β is itself rational, and its *p*-adic valuation is exactly the half-valuation. The arithmetic and the analysis agree perfectly.

## Computational Verification

These theorems are not just theoretical constructions — they have been verified computationally over tens of thousands of cases. Testing all primes up to 1000 and thousands of rational orbital parameter pairs, the cubic valuation law, scaling covariance, additive charge law, and half-valuation formula all hold without exception.

The computational search also reveals interesting structure. Orbits with large valuation charges tend to involve powers of small primes. The 2-adic charge can reach values of ±13 or more for orbit parameters involving high powers of 2. These extremal cases are the "loudest" signals in the arithmetic spectrum of the orbit.

## A New Doctrine

What does all this mean for science? At one level, it provides a new invariant for classifying orbits — not by their physical size or period, but by their prime-number fingerprint. Two orbits with the same depth profile at all primes are "arithmetically equivalent," even if their physical parameters differ.

At a deeper level, it suggests a new doctrine: *classical dynamical laws admit tropical-arithmetic shadows that are computable, compositional, and experimentally testable.* The Kepler system is the simplest case, but the mathematical framework extends in principle to any dynamical system whose invariants are rational functions of the parameters.

The additive charge law, in particular, hints at a tropical mechanics of composite systems — a min-plus algebra that mirrors the Hamiltonian structure of classical mechanics but operates in the discrete world of prime factorization. If this program succeeds, it could yield new tools for astrodynamics (classifying orbits by arithmetic type), number theory (using dynamical systems to generate interesting *p*-adic structures), and even theoretical physics (where non-Archimedean methods have found applications in string theory and quantum gravity).

## Looking Back, Looking Forward

Kepler worked with the astronomical tables of Tycho Brahe, painstakingly fitting data to discover his laws. He could not have imagined that the same law connecting orbital size to orbital period would one day be read as a statement about prime numbers. Yet the mathematics was always there, encoded in the multiplicative structure of the rational numbers, waiting for the right lens.

That lens — the tropical-arithmetic viewpoint — transforms a four-century-old law of physics into a living mathematical object with new symmetries, new invariants, and new connections to the vast landscape of modern mathematics. The hidden arithmetic of planetary orbits is no longer hidden. It is computable, provable, and — perhaps most surprisingly — beautiful.

The orbits of the planets carry a message written in the language of primes. We are just beginning to read it.
