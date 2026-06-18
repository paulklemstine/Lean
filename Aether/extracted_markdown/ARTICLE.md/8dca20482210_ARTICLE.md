# When Geometry Hides Computation: The Surprising Complexity of Shape Positivity

## A mathematical property that seemed tame turns out to encode the hardest problems in computer science

---

In 2020, two mathematicians proved a theorem that sent shockwaves through combinatorics. Petter Brändén and June Huh showed that an enormous class of polynomials — objects that appear everywhere from network reliability to quantum physics — share a hidden geometric property called *Lorentzian positivity*. Their result explained decades of mysterious coincidences: why certain counting sequences always increase and then decrease, why matroid invariants satisfy strange inequalities, why generating functions in statistical physics behave so nicely.

But lurking inside this elegant geometric property was a surprise. A computational time bomb.

## The Innocent-Looking Question

To understand the discovery, imagine you're handed a polynomial — a mathematical expression like *3x²y + 5xy² + 2y³*. This is a "homogeneous" polynomial: every term has the same total degree (here, 3). The coefficients (3, 5, 2) are all positive. So far, so friendly.

Now someone asks: *Is this polynomial Lorentzian?*

The Lorentzian property, named by analogy with the geometry of spacetime in Einstein's relativity, says something specific about how the polynomial curves in high-dimensional space. Think of it this way: if you slice through the polynomial's graph in any direction, the resulting curve should bend in a controlled way — at most one direction of positive curvature, with everything else curving negatively. It's a precise mathematical version of "nicely shaped."

For a polynomial with just two or three variables, checking this is straightforward. You compute a matrix called the Hessian — a grid of second derivatives — and check its eigenvalues. If at most one eigenvalue is positive, you're done. The whole calculation takes milliseconds.

But what if the polynomial has a hundred variables and degree a hundred? Or a thousand?

## The Recursive Trap

The standard algorithm for checking Lorentzianity works recursively. Start with your polynomial of degree *d*. Take every possible combination of partial derivatives that reduces the degree down to 2. Each of these derivative operations produces a quadratic polynomial — and each quadratic needs its own eigenvalue check.

The catch is the number of these "quadratic leaves." For a polynomial of degree *d* in *n* variables, the number of leaves you need to check equals the number of ways to distribute *d − 2* derivative operations among *n* variables. This is a classical counting problem called "stars and bars" — and the answer is the binomial coefficient C(*n* + *d* − 3, *d* − 2).

When the degree is fixed — say, *d* = 5, no matter how many variables you have — this count grows polynomially. Five variables give you a few dozen checks. A hundred variables give you a few million. A computer handles this easily.

But when the degree grows alongside the number of variables — when *d* ≈ *n* — something dramatic happens. The number of checks explodes exponentially. For *n* = *d* = 20, you need over 35 billion checks. For *n* = *d* = 50, the number exceeds the number of atoms in the observable universe.

## The Phase Transition

This is not merely an observation about a particular algorithm. It's a theorem — and now, a formally verified one.

The key result establishes a sharp *phase transition* in computational complexity:

**Fixed degree regime** (d constant): The certificate size is at most *n*, growing linearly with the number of variables. Lorentzian recognition is *tractable*.

**Unbounded degree regime** (d = n): The certificate size is at least 2^(*n*−2), growing exponentially. No polynomial-time algorithm can check all the required conditions.

The proof works by constructing an explicit injection: every binary string of length *k* can be encoded as a distinct multiindex of weight *k*. Since there are 2^*k* binary strings, there must be at least 2^*k* multiindices — and hence at least 2^*k* quadratic leaves to check. No shortcut can avoid this combinatorial explosion.

What makes this result deep is the complementary direction. It's not just that one particular algorithm is slow. The theorem proves that *any* certificate-based method — any scheme that works by checking conditions at the quadratic leaves of the derivative tree — must face this exponential blowup. The explosion is intrinsic to the mathematical structure.

## The Bridge to Satisfiability

The most surprising aspect of the new theory is its connection to Boolean satisfiability — the iconic hard problem of computer science.

A Boolean satisfiability (SAT) instance asks: given a list of constraints on yes/no variables, is there an assignment that satisfies all constraints simultaneously? This is the canonical NP-complete problem. Finding satisfying assignments is believed to be fundamentally hard; proving that *no* satisfying assignment exists (the "UNSAT" problem) is even harder — it sits in the complexity class coNP.

The newly proved *SAT-Obstruction Duality* theorem draws a precise parallel:

> A formula is unsatisfiable if and only if every possible assignment is "obstructed" — that is, every assignment falsifies at least one constraint.

This sounds obvious. But its significance lies in the structural mirror with Lorentzian recognition. In the derivative tree, every branch must be checked for a spectral condition. In SAT, every assignment must be checked for clause satisfaction. The branching structure is identical. The number of branches matches the number of assignments. The obstruction pattern in one domain maps to the obstruction pattern in the other.

This correspondence suggests something profound: Lorentzian recognition, for polynomials of unbounded degree, may be as hard as proving unsatisfiability of Boolean formulas. If this reduction can be made exact — if every SAT instance can be efficiently encoded as a Lorentzian recognition problem — it would establish that a central property from algebraic geometry is *coNP-hard*.

## The Spectral Bridge

There's a third pillar to this story, connecting through matrix theory.

Any symmetric matrix can be encoded as a degree-2 polynomial: just write *P_A*(*x*) = Σ *A*[*i*,*j*] *x_i* *x_j*. The Hessian of this polynomial — the matrix of second derivatives — turns out to be exactly *A* + *A*ᵀ. For a symmetric matrix, that's just 2*A*.

This means checking whether a matrix has "Lorentzian signature" (at most one positive eigenvalue) is *exactly the same* as checking whether the corresponding polynomial is Lorentzian. Eigenvalue problems reduce to Lorentzian recognition. Conversely, any hardness in eigenvalue checking transfers directly to polynomial recognition.

This spectral bridge isn't just a technical convenience. It reveals that Lorentzian recognition sits at the intersection of three mathematical worlds:

- **Algebraic geometry**: the theory of polynomial positivity and Hodge theory
- **Linear algebra**: eigenvalue problems and spectral analysis  
- **Computational complexity**: satisfiability, certificate complexity, and hardness

Each world contributes a different perspective. Together, they reveal that Lorentzian positivity is not merely a geometric property — it's a *computationally expressive language* capable of encoding hard problems.

## What Changes

If you're a mathematician working with Lorentzian polynomials, the message is clear: when the degree is bounded, breathe easy. Your algorithms will run in polynomial time, your certificates will be manageable, and your computations will finish.

But if you venture into the regime of unbounded degree — the regime relevant to many problems in combinatorics, statistical physics, and matroid theory — prepare for a fundamentally different landscape. The elegant recursive criterion that makes Lorentzian polynomials so appealing in theory becomes a computational barrier in practice.

This isn't a failure of cleverness. It's a feature of the mathematics. The derivative tree of a high-degree polynomial is rich enough to encode any Boolean decision problem. The positivity condition at each leaf is flexible enough to simulate any constraint. The tree structure is deep enough to require exponential exploration.

## Looking Forward

Several tantalizing questions emerge:

*Can the reduction be made exact?* If so, Lorentzian recognition for unbounded degree would be proved coNP-hard — the first complexity lower bound for a Hodge-theoretic positivity predicate.

*Are there approximation algorithms?* If exact recognition is hard, can we efficiently *approximate* Lorentzianity? The spectral bridge suggests that eigenvalue approximation techniques might transfer.

*What about other positivity notions?* Lorentzian polynomials are just one member of a family of Hodge-theoretic positivity concepts. Do others exhibit similar phase transitions?

*What are the implications for combinatorics?* Many combinatorial inequalities are proved by showing that certain polynomials are Lorentzian. If recognition is hard, does this mean the *proofs* of these inequalities are inherently complex?

This last question hints at a deep connection to proof complexity theory. A Lorentzian certificate is essentially a proof that a polynomial satisfies a positivity condition. If certificates must be exponentially large, then these proofs must be exponentially long — mirroring known lower bounds on resolution proofs for unsatisfiable SAT instances.

The boundary has been drawn. On one side: elegant, tractable geometry. On the other: the full power of computational hardness. Lorentzian positivity, it turns out, knows the difference between a bounded world and an unbounded one — and it changes its character accordingly.

That, in the end, is the deepest insight: mathematical positivity is not one thing. It is tame when constrained, wild when freed. And the transition between the two is as sharp as a theorem can make it.
