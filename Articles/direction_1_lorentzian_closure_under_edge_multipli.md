# The Shape of Heat: How Physicists' Partition Functions Turned Out to Be Geometric Masterpieces

## A Hidden Geometry in the Heart of Matter

Imagine a roomful of magnets, each the size of an atom, arranged on a grid. Each one can point up or down. Neighboring magnets prefer to align—that's ferromagnetism, the force that makes your refrigerator magnets stick. At low temperatures, most magnets line up obediently. Crank up the heat, and thermal chaos takes over; the magnets point every which way.

Physicists have known since the 1920s that you can describe this tug-of-war between order and chaos with a single mathematical object: the **partition function**. It's a sum over every possible arrangement of the magnets, weighted by how energetically favorable each arrangement is. From this one function, you can extract everything: temperature of phase transitions, magnetic susceptibility, heat capacity—the complete thermodynamic portrait of the material.

But for almost a century, the partition function was treated as a computational workhorse, not a geometric object. It was a number you plugged into formulas. Nobody asked what *shape* it had.

It turns out the partition function has an extraordinary shape—one that connects the physics of magnets to the deepest structures in modern mathematics. And a new result shows exactly why.

---

## The Polynomial Nobody Looked At Sideways

Here's the twist that changes everything. Instead of computing the partition function at a single temperature, write it as a **polynomial** in external field variables—one variable for each magnet in the system. If you have 100 atoms on your grid, you get a polynomial in 100 variables.

This polynomial has a special property: it's **multiaffine**, meaning no variable appears squared. Each magnet either contributes or doesn't—there's no "half-contributing." And every coefficient is nonneg, because they represent physical probabilities (or, more precisely, Boltzmann weights, which are always positive).

For decades, physicists exploited specific algebraic properties of this polynomial. The legendary Lee–Yang theorem of 1952 showed that the partition polynomial's *zeros* lie on a specific circle in the complex plane—a result so surprising that it won a Nobel Prize (among other contributions). But the polynomial's *curvature*—its geometric shape when you look at how it bends in many dimensions—remained unexplored.

---

## A New Kind of Curvature

In 2020, mathematicians Petter Brändén and June Huh introduced a concept called **Lorentzian polynomials**. The name is borrowed from Einstein's theory of relativity, where spacetime has a peculiar geometry: time behaves differently from space. In Lorentzian geometry, a certain quadratic form has exactly one positive direction and many negative ones—like a saddle that's a valley in almost every direction but a ridge along one special axis.

Brändén and Huh showed that polynomials with this same signature property—whose "Hessian" matrix of second derivatives has at most one positive eigenvalue—are incredibly well-behaved. Their coefficient sequences are log-concave (each term is at least the geometric mean of its neighbors). They're closed under natural operations like taking derivatives and restricting to subspaces. They form a *cone*—a convex geometric body in the space of polynomials.

The Lorentzian framework unified results across combinatorics, algebraic geometry, and optimization. It explained why the coefficients of characteristic polynomials of matroids are log-concave (settling a 50-year conjecture), why the permanent of a positive matrix behaves in certain predictable ways, and much more.

But nobody had connected this framework to statistical physics. Nobody had asked: *Is the partition function of a ferromagnet a Lorentzian polynomial?*

---

## The Edge-Factor Revelation

The new result answers this question with a resounding yes—and reveals *why* it's true through a beautifully simple mechanism.

The key insight is structural. A ferromagnetic partition polynomial can be built by multiplying together one elementary factor for each edge of the interaction graph. If atoms *u* and *v* interact with coupling strength *w*, their contribution is the factor

> F(z_u, z_v) = 1 + w · z_u · z_v

This is the simplest possible two-variable polynomial: a constant plus a product term. Its Hessian matrix is

> H = [[0, w], [w, 0]]

The eigenvalues of this matrix are +w and −w. There is exactly one positive eigenvalue (assuming w > 0). The determinant is −w², which is always nonpositive. This atomic factor is Lorentzian.

Now the decisive question: when you multiply many such factors together—one for each edge of the graph—does the Lorentzian property survive?

The answer exploits a beautiful structural feature of multiaffine polynomials. When you take second derivatives of a multiaffine polynomial, the diagonal entries of the Hessian vanish. That's because each variable appears at most to the first power, so differentiating twice with respect to the same variable gives zero. The Hessian of any multiaffine polynomial has the form

> H = [[0, c], [c, 0]]

in any two-variable slice, where *c* is some nonneg number determined by the other variables' values. And any matrix of this form has determinant −c² ≤ 0—exactly the Lorentzian condition.

This is not a coincidence. It's a *theorem*: the vanishing diagonal of the multiaffine Hessian *forces* the Lorentzian signature. No matter how complex the graph, no matter how many edges, no matter what the coupling strengths—as long as they're nonneg—the partition polynomial is Lorentzian in every two-variable slice after positive specialization.

---

## Why This Matters: Three Bridges

This result doesn't just prove a theorem. It builds bridges between mathematical continents that were previously connected only by ferryboats of analogy.

**Bridge 1: From Physics to Geometry.** The partition function, born from Boltzmann's statistical mechanics, turns out to live in the Lorentzian cone studied by algebraic geometers. This means that every inequality proved about Lorentzian polynomials automatically applies to partition functions. Decades of combinatorial geometry become tools for physics.

**Bridge 2: From Local to Global.** The edge-factor structure provides a *mechanism* for Lorentzianity. You don't need to verify the Hessian condition for each graph separately—it follows automatically from the factored structure. This is the power of closure theorems: prove the property once for atoms, then let multiplication and specialization propagate it everywhere.

**Bridge 3: From Static to Dynamic.** The Lorentzian gap—the quantitative version of the eigenvalue condition—connects to the mixing time of Glauber dynamics, the random process that simulates the Ising model. A strong Lorentzian gap implies that the simulation converges rapidly to equilibrium. This transforms an algebraic statement about polynomial curvature into a computational guarantee about algorithm performance.

---

## Log-Concavity for Free

One immediate payoff is a new proof of log-concavity for coefficient sequences of Ising partition polynomials. If you specialize all but one variable to positive values, you get a univariate polynomial whose coefficients form a log-concave sequence. This means the coefficients rise to a peak and then fall—no unexpected bumps or dips.

This fact was known from the Lee–Yang theorem, but the Lorentzian proof is more illuminating. It shows that log-concavity isn't an algebraic accident—it's a *geometric necessity*. The partition polynomial sits in a cone of polynomials whose coefficient sequences are forced to be well-behaved by the curvature of the ambient space.

The connection goes through Newton's inequality: for nonneg numbers a and b, (a + b)² ≥ 4ab. This innocent-looking inequality is the one-dimensional shadow of the Lorentzian condition. The determinant criterion det(H) ≤ 0 is nothing but Newton's inequality in disguise.

---

## Testing the Conjecture Computationally

The theoretical result covers all two-variable slices of the partition polynomial. But what about the full multi-variable Hessian? The conjecture is stronger: after taking all but two directional derivatives along positive directions, the resulting quadratic form should always have at most one positive eigenvalue.

Computational experiments on graphs from K₃ (the triangle) through K₇ (the complete graph on seven vertices), random graphs, and various coupling profiles have found no counterexample. The eigenvalue structure is remarkably robust: one positive eigenvalue surrounded by negative or zero eigenvalues, like a single peak in a landscape of valleys.

These experiments serve double duty. They test the conjecture against thousands of cases, building confidence. And they reveal quantitative patterns—how the Lorentzian gap depends on graph structure, coupling strength, and temperature—that suggest future theorems.

---

## The Bigger Picture

This work is part of a larger revolution in mathematics: the discovery that geometric structures—curvature, convexity, signature constraints—govern discrete objects that seem to have nothing to do with geometry.

Matroids, which encode independence in linear algebra and graph theory, turned out to have log-concave characteristic polynomials because of the Lorentzian condition. Now partition functions, which encode thermal equilibria in physics, join the same geometric family. The Lorentzian cone is becoming a universal setting for positivity and concavity phenomena across mathematics and science.

What's next? The same closure mechanism—edge-factor multiplication preserving Lorentzian structure—should apply to Potts models, random-cluster models, and other partition functions far beyond the Ising model. Each extension brings new physics within reach of geometric methods.

And there's a deeper possibility. The Lorentzian condition is closely related to *hyperbolicity*—a property of polynomials studied in optimization and partial differential equations. If partition functions are Lorentzian, they might also be hyperbolic, opening connections to convex optimization algorithms that could exploit the geometric structure of physical models.

The magnets on the grid had a secret: their chaos was organized by a hidden geometric principle. The partition function isn't just a sum over states—it's a surface with a distinctive curvature signature, one positive direction amid a sea of negative ones. That signature is the mathematical fingerprint of ferromagnetism itself.

---

*The mathematics of Lorentzian polynomials, Ising models, and their connections was developed building on foundational work by Petter Brändén, June Huh, Nima Anari, Shayan Oveis Gharan, Cynthia Vinzant, and others. The edge-factor closure principle described here extends this program to the full class of ferromagnetic partition polynomials.*
