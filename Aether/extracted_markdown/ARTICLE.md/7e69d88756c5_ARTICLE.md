# The Hidden Mathematics of Random Walks That Never Cross Themselves

## How a simple combinatorial puzzle connects to tropical geometry and reveals deep truths about mathematical constants

Imagine you're walking on a grid—the kind you might draw on graph paper. You can step north, south, east, or west, one square at a time. There's just one rule: you can never step on a square you've already visited. How many different walks of exactly 100 steps can you take?

This deceptively simple question—counting *self-avoiding walks*—has consumed mathematicians and physicists for nearly a century. It sounds like the kind of puzzle you might find in a recreational mathematics column, but it turns out to be one of the deepest unsolved problems in mathematical physics, with connections to polymer chemistry, statistical mechanics, and now, a surprising branch of mathematics called tropical geometry.

## The Connective Constant: A Number That Defines a Lattice

When mathematicians count self-avoiding walks on a grid, they discover something remarkable. Let $c_n$ denote the number of $n$-step self-avoiding walks starting from the origin. On the square lattice, the first few values are easy: $c_1 = 4$ (four directions to start), $c_2 = 12$ (four starts, three continuations each), and so on. But as $n$ grows, the counts explode—$c_{10}$ is already over 44 million.

Yet beneath this explosive growth lies a beautiful regularity. The sequence $c_n$ is *submultiplicative*: $c_{m+n} \leq c_m \cdot c_n$. Why? Because if you concatenate an $m$-step walk with an $n$-step walk, the result might cross itself, so not every pair of walks gives a valid longer walk. This inequality means the number of walks grows at most exponentially—but it also guarantees, through a classical result called Fekete's lemma, that the growth rate settles down to a precise constant.

That constant, $\mu$, is called the *connective constant* of the lattice. It satisfies $c_n \approx \mu^n$ as $n$ grows large (up to polynomial corrections). For the square lattice, numerical evidence suggests $\mu \approx 2.638$, but nobody has proved its exact value. For the hexagonal (honeycomb) lattice, however, a breakthrough came in 2012.

## The Honeycomb Breakthrough

In a celebrated result, Hugo Duminil-Copin and Stanislav Smirnov proved that the connective constant of the hexagonal lattice is exactly $\sqrt{2 + \sqrt{2}} \approx 1.848$. This number, sometimes called the Nienhuis constant after physicist Bernard Nienhuis who conjectured its value in 1982, is remarkable in several ways.

First, it's irrational. This might seem like a minor observation, but proving it reveals beautiful algebraic structure. If $\alpha = \sqrt{2 + \sqrt{2}}$, then $\alpha^2 = 2 + \sqrt{2}$, so $\alpha^2 - 2 = \sqrt{2}$, and squaring again gives $\alpha^4 - 4\alpha^2 + 2 = 0$. This quartic polynomial has no rational roots—the candidates $\pm 1$ and $\pm 2$ all fail a simple check—so $\alpha$ cannot be rational. The algebraic tower $\mathbb{Q} \subset \mathbb{Q}(\sqrt{2}) \subset \mathbb{Q}(\sqrt{2+\sqrt{2}})$ reveals the constant as a degree-4 algebraic number, occupying a precise position in the hierarchy of algebraic complexity.

Second, the proof of Duminil-Copin and Smirnov uses a stunning idea from complex analysis: they construct a *parafermionic observable* on the lattice that satisfies a discrete version of the Cauchy-Riemann equations. This observable is a weighted sum over self-avoiding walks with a phase factor encoding the winding angle—and it behaves like a holomorphic function precisely when the fugacity parameter equals $1/\sqrt{2+\sqrt{2}}$. The discrete holomorphicity pins down the exact critical point.

## Enter Tropical Geometry

Here is where the story takes an unexpected turn. In the past two decades, mathematicians have developed a new branch of geometry called *tropical geometry*, which replaces ordinary arithmetic with a strange alternative: addition becomes taking the maximum, and multiplication becomes addition. Under these exotic rules, polynomials become piecewise-linear functions, and curves become networks of line segments. The "tropical" name, incidentally, honors Brazilian mathematician Imre Simon, though the mathematics applies everywhere.

What does this have to do with self-avoiding walks? Consider the generating function $f(x) = \sum c_n x^n$. This power series converges when $|x| < 1/\mu$ and diverges when $|x| > 1/\mu$—the connective constant determines the radius of convergence. Now apply the tropical lens: replace each coefficient $c_n$ with its logarithm $v_n = \log c_n$, and consider the tropical power series $\text{trop}(f)(t) = \sup_n(nt + v_n)$. This is a supremum of linear functions—a piecewise-linear object, the kind tropical geometry is built to handle.

The convergence of this tropical power series—whether the supremum is finite—is determined by the *tropical growth rate*, which is the limit of $v_n/n = \log(c_n)/n$. And here's the bridge: this tropical growth rate is exactly $\log \mu$, the logarithm of the connective constant. The tropical power series converges precisely when $t < -\log \mu$ and diverges when $t > -\log \mu$.

This means the connective constant lives naturally in two worlds. In the classical world, it's the reciprocal of the radius of convergence of a generating function—an analytic object. In the tropical world, it's the critical slope of a piecewise-linear function—a geometric object. The passage between these two perspectives isn't just a change of notation; it opens new avenues for understanding.

## Fekete's Lemma: The Engine Room

The mathematical engine that makes all of this work is Fekete's lemma, a result from 1923 that deserves to be better known. In its simplest form, it says: if a sequence $a_n$ satisfies $a_{m+n} \leq a_m + a_n$ (subadditivity), then the ratio $a_n/n$ converges to its infimum.

For self-avoiding walks, take $a_n = \log c_n$. Submultiplicativity of $c_n$ translates to subadditivity of $a_n$. Fekete's lemma then guarantees that $\log(c_n)/n$ converges—and its limit is $\log \mu$, the tropical growth rate.

The proof of Fekete's lemma is itself a gem. The key idea uses the division algorithm: write $n = qd + r$ where $0 \leq r < d$. Then by subadditivity applied repeatedly, $a_n \leq q \cdot a_d + a_r$. Dividing by $n$, the term $q/n \approx 1/d$, and the remainder $a_r/n \to 0$ as $n \to \infty$. So $\limsup a_n/n \leq a_d/d$ for every $d$, which means $\limsup a_n/n \leq \inf a_d/d$. The reverse inequality is trivial, so the limit exists and equals the infimum.

This clean argument—elementary yet powerful—is the foundation stone. Without it, neither the connective constant nor the tropical convergence criterion would be well-defined.

## The Bigger Picture

The connection between self-avoiding walks and tropical geometry is part of a larger trend in mathematics: seemingly unrelated fields turn out to share deep structural similarities. Tropical geometry has already transformed algebraic geometry, combinatorics, and optimization. Its appearance in statistical mechanics suggests that the piecewise-linear world may have more to say about phase transitions and critical phenomena.

One tantalizing direction involves the *tropical spectral theory* of transfer matrices. In statistical mechanics, the partition function of a system can often be computed as the leading eigenvalue of a transfer matrix. In the tropical limit, eigenvalues become the slopes of piecewise-linear functions, and spectral gaps become combinatorial quantities. Could this framework provide new tools for computing or bounding connective constants on lattices where the exact value is unknown?

Another direction connects to the *algebraic* properties of the Nienhuis constant. The minimal polynomial $x^4 - 4x^2 + 2 = 0$ can be "tropicalized" into the piecewise-linear function $\max(4t, 2t + \log 4, \log 2)$. The tropical roots of this function—the points where the maximum is achieved by multiple terms—encode the same algebraic structure in a combinatorial language. Understanding these tropical roots could reveal why certain lattice constants are algebraic while others might be transcendental.

## Why It Matters

Self-avoiding walks aren't just a mathematical curiosity. They model real polymers—long chain molecules that can't occupy the same space twice. The connective constant determines the number of configurations available to a polymer of a given length, which in turn governs its physical properties: how it folds, how it interacts with solvents, how it responds to temperature changes.

The tropical perspective adds a new computational toolkit. Piecewise-linear optimization is computationally much friendlier than nonlinear optimization, and tropical methods have already found applications in scheduling, network analysis, and machine learning. If the tropical framework can be developed further for self-avoiding walk problems, it might provide practical algorithms for polymer simulation alongside theoretical insights.

Mathematics at its best reveals unexpected connections between different ways of thinking about the world. The bridge between random walks, algebraic number theory, and tropical geometry is a beautiful example of this phenomenon—a reminder that the most productive ideas often come from crossing disciplinary boundaries.

---

*The mathematical results described in this article were established through rigorous formal proofs, building a chain from elementary combinatorial bounds through real analysis to tropical algebra. The work connects to a broader research program exploring how tropical geometry illuminates problems in statistical mechanics and combinatorics.*
