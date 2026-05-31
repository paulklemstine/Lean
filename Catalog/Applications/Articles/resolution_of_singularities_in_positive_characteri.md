# The Last Frontier of Smoothing: Why Algebraic Geometry's Biggest Open Problem Haunts Mathematicians

## A 60-Year Quest to Iron Out the Wrinkles in Higher-Dimensional Shapes

Imagine you have a crumpled piece of paper. You know, intuitively, that it could be smoothed flat. Now imagine the same problem in four dimensions — and in a universe where the very concept of "derivative" occasionally stops working. Welcome to one of the deepest unsolved problems in modern mathematics.

In 1964, the Japanese mathematician Heisuke Hironaka proved something extraordinary: any algebraic variety — a shape defined by polynomial equations — over a field of characteristic zero (essentially, over the ordinary number systems mathematicians are familiar with) can be "resolved." That is, its singularities — the kinks, cusps, and self-intersections that make it misbehave — can be systematically blown up and smoothed away, leaving behind a pristine, non-singular variety that retains all the essential geometric information of the original. For this achievement, Hironaka won the Fields Medal in 1970.

But there was a catch. Hironaka's proof only works in characteristic zero — where the rules of arithmetic are the ones we learn in school. In characteristic *p*, where arithmetic wraps around modulo a prime number *p*, everything falls apart. And the question of whether singularities can always be resolved in this strange but fundamental setting has remained stubbornly open for over sixty years.

## The Characteristic *p* Wilderness

What makes characteristic *p* so different? The answer lies in a deceptively simple map called the **Frobenius endomorphism**: the operation that raises every element to its *p*-th power.

In ordinary calculus, if you have a function *f(x) = x^n*, its derivative is *nx^(n−1)*. This derivative vanishes only when you set it to zero deliberately. But in characteristic *p*, something uncanny happens: the derivative of *x^p* is *px^(p−1) = 0*, because *p* itself is zero in this arithmetic. The derivative — the fundamental tool for detecting singularities — goes blind.

This isn't just a technicality. The Frobenius map creates what mathematicians call **inseparable** polynomials: equations whose roots stick together in ways that no amount of algebraic manipulation can pull apart. When you try to detect a singularity using the Jacobian criterion (checking where all partial derivatives vanish simultaneously), inseparable polynomials create phantom smooth points that are actually singular. The standard machinery of resolution — blowing up a point and checking whether the singularity improves — runs into walls it never encounters in characteristic zero.

## Blowing Up: The Art of Controlled Explosion

The central technique in resolution of singularities is the **blowup**. Think of it as replacing a singular point with an entire projective space, like zooming in with an infinitely powerful microscope until the singularity "spreads out" and becomes visible.

Mathematically, a blowup at an ideal *I* replaces the ring *R* with the **Rees algebra** *R[It] = ⊕ I^n t^n*, a graded construction that encodes all powers of the ideal simultaneously. The key invariant tracked through this process is the **multiplicity** — a number measuring how badly the variety is pinched at the singular point.

In characteristic zero, each blowup is guaranteed to reduce the multiplicity. Since multiplicity is a natural number, it can only decrease finitely many times before reaching 1 (smooth) or 0 (resolved). This descent argument is the engine of Hironaka's proof.

In characteristic *p*, this descent can stall. The Frobenius map can create situations where the multiplicity stubbornly refuses to drop, because the "directions" along which the variety is singular are invisible to the derivative-based tools that guide the choice of blowup center.

## The State of the Art: Dimensions 1, 2, and 3

Despite the difficulties, mathematicians have chipped away at the problem dimension by dimension.

**Curves (dimension 1)** are the easiest case. Here, resolution of singularities is equivalent to **normalization** — a purely algebraic operation that works in every characteristic. Take the integral closure of the coordinate ring in its fraction field, and you get a smooth curve. This was known classically and holds over any field.

**Surfaces (dimension 2)** were conquered by Shreeram Abhyankar in 1956, a decade before Hironaka's work. Abhyankar's proof required entirely different techniques from Hironaka's characteristic-zero approach, relying on a delicate analysis of valuations and the structure of two-dimensional local rings. The inseparability obstruction is present but manageable in two dimensions because the combinatorics of the exceptional divisor remain tractable.

**Threefolds (dimension 3)** proved far harder. Vincent Cossart and Olivier Piltant spent over two decades on this problem, finally completing the proof in a series of papers culminating in 2019. Their work required an exhaustive case analysis of the ways inseparable extensions can interact with blowup sequences in three-dimensional local rings. The proof runs to hundreds of pages and pushes the limits of what can be achieved by pure combinatorial analysis.

**Dimension 4 and beyond** remain completely open. No one has even a plausible strategy for the general case.

## The Inseparability Degree: Measuring the Obstruction

Recent work has focused on quantifying the Frobenius obstruction. The **inseparability degree** of a polynomial — the largest *k* such that all exponents in the polynomial are divisible by *p^k* — measures how deeply the polynomial is embedded in the image of the Frobenius map.

A key theorem connects this combinatorial invariant to derivative behavior: if a polynomial has inseparability degree *k ≥ 1*, then its formal derivative necessarily vanishes. This means the Jacobian criterion gives no information about singularities in directions dominated by the Frobenius.

The connection between inseparability degree and resolution complexity suggests a deeper relationship: the number of blowups needed to resolve a singularity in characteristic *p* should grow with the inseparability degree. In characteristic zero, the inseparability degree is always zero, and the resolution algorithm terminates predictably. In characteristic *p*, arbitrarily high inseparability degrees create increasingly complex obstructions.

## A Testable Prediction

Mathematics, like science, advances through falsifiable predictions. Here is one: for any polynomial of degree *d* in four variables over a field of characteristic *p*, a resolution of singularities should be achievable within *d^4* blowup steps. This bound is a conjecture — it could be wrong. But testing it computationally for random polynomials of moderate degree over small finite fields (𝔽₂, 𝔽₃, 𝔽₅) would either build confidence in the conjecture or produce a concrete counterexample that would teach us something profound about the structure of singularities.

## Why It Matters

Resolution of singularities isn't just an abstract curiosity. It lies at the foundation of modern algebraic geometry, number theory, and even string theory. Many of the deepest results in arithmetic geometry — including key steps in the proof of Fermat's Last Theorem — rely on resolution of singularities in characteristic zero. Extending these results to characteristic *p* would unlock new approaches to:

- **The Langlands program**: connecting number theory to representation theory
- **Motivic integration**: generalizing *p*-adic integration to arbitrary varieties  
- **Birational geometry in mixed characteristic**: understanding varieties over rings like the *p*-adic integers
- **Coding theory and cryptography**: algebraic curves and surfaces over finite fields are the backbone of modern error-correcting codes

The resolution problem in characteristic *p* sits at the crossroads of algebra, geometry, and arithmetic. Solving it would not just close a gap in our knowledge — it would open entirely new territories of mathematical exploration.

## The Road Ahead

The gap between dimension 3 (solved) and dimension 4 (unknown) is not merely quantitative. Each dimension introduces qualitatively new phenomena in the interaction between Frobenius and blowup. The combinatorial complexity of tracking inseparability through blowup sequences grows faster than exponentially with dimension, and the techniques that sufficed for Cossart-Piltant's threefold proof do not obviously generalize.

New ideas are needed. Some researchers believe that a conceptual breakthrough — perhaps involving perfectoid spaces, prismatic cohomology, or other recent innovations in *p*-adic geometry — could bypass the combinatorial obstacles entirely. Others argue that the problem may require computational methods: automated search through the space of possible blowup sequences, guided by the multiplicity and inseparability invariants.

Whatever the approach, the resolution of singularities in positive characteristic remains one of the grand challenges of 21st-century mathematics — a problem that is both concrete enough to test and deep enough to transform our understanding of geometry over finite fields. The crumpled paper of characteristic *p* awaits its smoothing.

---

*The mathematical results described in this article formalize key algebraic foundations of resolution theory, including the precise relationship between the Frobenius endomorphism and derivative vanishing, the structure of blowup sequences with multiplicity tracking, and termination bounds for resolution algorithms in settings where multiplicity strictly decreases.*
