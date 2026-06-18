# The Shape of Counting: How Polynomial Geometry Controls What Numbers Can Do

*A hidden law of mathematics links the curvature of abstract surfaces to the behavior of counting sequences — and it could reshape how we understand networks, materials, and data.*

---

When you flip ten coins, the number of ways to get exactly five heads is 252 — the largest entry in that familiar row of Pascal's triangle. Move one step to four heads (210) or six heads (also 210), and the count drops. The sequence swells in the middle, declines at the edges, and obeys a simple but powerful rule: at every position, the square of the count exceeds the product of its neighbors. Mathematicians call this *log-concavity*, and for centuries it was just an elegant curiosity about binomial coefficients.

Then, starting around 2018, a revolution began. Petter Brändén and June Huh — the latter soon to win a Fields Medal — discovered that log-concavity is not an accident of coin flips. It is a shadow cast by geometry. Specifically, it is the trace left behind when a higher-dimensional mathematical surface with a particular kind of curvature is sliced by a plane.

Now a new theorem pushes this connection further, revealing that the depth of curvature information carried by these surfaces translates directly into the *strength* of the counting inequalities below. The deeper the geometric structure, the more tightly the numbers are constrained. And those numbers count real things: spanning trees in networks, configurations in statistical mechanics, and bases of abstract combinatorial structures called matroids.

## The Inequality That Keeps Showing Up

To understand why this matters, consider a simple question: does a sequence of positive numbers 1, 3, 5, 4, 2 have a "nice shape"? One natural criterion is that it should rise, reach a peak, and fall — what statisticians call unimodality. But unimodality is weak; the sequence 1, 100, 2, 99, 3 is not unimodal, yet something about it still feels wild and unconstrained.

Log-concavity is the right notion of "nice shape." A sequence $a_0, a_1, \ldots, a_d$ is log-concave if $a_m^2 \geq a_{m-1} \cdot a_{m+1}$ for every interior index $m$. Intuitively, the sequence cannot jump up too sharply after dropping — each value acts as a geometric mean bound on its neighbors. Log-concavity implies unimodality (the sequence has a single peak), but it is far more restrictive.

The surprise is how often log-concavity appears in nature. The number of independent sets of size $k$ in a claw-free graph. The number of spanning forests of a given size. The coefficients of the chromatic polynomial. The number of bases of a matroid with a prescribed intersection pattern. Over and over, counting sequences that arise from combinatorial structures turn out to be log-concave, and for decades, proving this in individual cases required bespoke arguments — clever injections, algebraic manipulations, or probabilistic coupling.

Brändén and Huh's insight was that all these cases share a common geometric origin.

## Curvature in Polynomial Space

A *homogeneous polynomial* in several variables — say $P(x_1, x_2, \ldots, x_n) = \sum c_\alpha \, x_1^{\alpha_1} x_2^{\alpha_2} \cdots x_n^{\alpha_n}$ where all monomials have the same total degree — can be thought of as defining a surface in a high-dimensional space. The shape of that surface is controlled by its *Hessian matrix*, the array of all second partial derivatives.

A polynomial is called *Lorentzian* if its Hessian has a very specific signature: at most one positive eigenvalue. This is the same signature that appears in Einstein's spacetime metric — one time-like direction, the rest space-like — which is why the name evokes Lorentzian geometry. But here the context is purely algebraic.

The key theorem of Brändén and Huh says: if a homogeneous polynomial with nonnegative coefficients is Lorentzian, and you differentiate it repeatedly until you reach degree two, every such "derivative leaf" still has the Lorentzian signature. This recursive structure is powerful because differentiation and restriction to sub-planes correspond exactly to the kinds of projections that produce counting sequences.

## The New Bridge

The new result makes this correspondence explicit and quantitative. It introduces the concept of a *bivariate specialization*: take a multivariate Lorentzian polynomial and restrict it to a two-variable "slice" by substituting $x_i = u_i s + v_i t$ for chosen direction vectors $u$ and $v$. The result is a polynomial in two variables, $Q(s, t) = \sum_{m=0}^{d} a_m \, s^m \, t^{d-m}$, and the coefficients $a_0, a_1, \ldots, a_d$ form the counting sequence of interest.

The theorem then says:

> **If the original polynomial is Lorentzian to recursive depth $k$, then the bivariate specialization coefficients are $k$-fold log-concave.**

What is $k$-fold log-concavity? It is a tower of increasingly strict constraints:

- **1-fold**: the sequence itself is log-concave.
- **2-fold**: the sequence is log-concave, *and* the ratio sequence $r_m = a_{m+1}/a_m$ is also log-concave.
- **3-fold**: the ratio sequence's ratio sequence is also log-concave. And so on.

Each additional level squeezes the sequence more tightly. A $k$-fold log-concave sequence is not just unimodal — it is smooth, well-behaved, and highly constrained in its shape. The theorem says that geometric depth (recursive Lorentzianity) translates directly into combinatorial rigidity ($k$-fold log-concavity).

## The Engine Room: A Reversed Inequality

The proof mechanism is beautiful in its economy. At the heart of Lorentzian geometry lies a *reversed Cauchy–Schwarz inequality*: for vectors in the positive cone of a Lorentzian form, the bilinear pairing satisfies $B(x, y)^2 \geq Q(x) \cdot Q(y)$ — the inequality goes the "wrong" way compared to the usual Cauchy–Schwarz.

Applied to the standard basis vectors of a two-dimensional slice, this reversed inequality becomes exactly Newton's inequality for the coefficients: $a_m^2 \geq a_{m-1} \cdot a_{m+1}$. Each step of differentiation in the recursive Lorentzian structure produces a new polynomial that is still Lorentzian, and the same argument applies to its coefficient sequence — which is precisely the *ratio transform* of the original sequence. Induction on the recursive depth gives $k$-fold log-concavity.

## Why It Matters Beyond Mathematics

The significance of this bridge extends well beyond abstract algebra.

**Network science.** The Kirchhoff polynomial of a graph — whose terms encode spanning trees — is known to be Lorentzian. Specializing this polynomial to two variables by partitioning edges into two groups produces coefficients that count spanning trees by their usage profile across the partition. The bridge theorem immediately implies these profile counts are log-concave. This is a quantitative statement about the distribution of spanning trees in networks, relevant to electrical network theory, random graph models, and combinatorial optimization.

**Statistical mechanics.** In the Ising model of ferromagnetism, the partition function decomposes into sectors by magnetization — the number of "up" spins. For ferromagnetic systems (positive coupling), the generating polynomial in edge variables is Lorentzian. The bridge theorem implies that the magnetization-sector partition weights are log-concave, a result connected to the thermodynamic stability of these systems and the suppression of large fluctuations.

**Matroid theory.** Mason's conjecture (now a theorem) says that the number of independent sets of each size in a matroid forms a log-concave sequence. The bridge theorem upgrades this: if the matroid's basis generating polynomial has recursive Lorentzian depth $k$, the sequence is $k$-fold log-concave, imposing far stronger shape constraints on the combinatorial data.

## A New Frontier

The most provocative aspect of this work is the conjecture it raises. The proven theorem requires recursive Lorentzian depth $k$ to guarantee $k$-fold log-concavity. But computational experiments suggest that many naturally occurring Lorentzian polynomials — products of linear forms, uniform matroid polynomials, Kirchhoff polynomials — satisfy much deeper log-concavity than the recursive depth alone would predict. Binomial coefficients, for instance, appear to be $k$-fold log-concave for *all* $k$ up to the support boundary.

Is there a universal phenomenon at work? Are naturally arising Lorentzian polynomials always maximally log-concave, even beyond what the current theory can prove? If so, the bridge theorem is not just a neat correspondence — it is the tip of a much larger iceberg, one where the geometric structure of polynomials imposes arithmetic constraints far more powerful than anyone has yet proven.

The tools for investigating this frontier now exist. The bridge theorem converts a structural certification (checking the Lorentzian condition) into an inequality-production mechanism (outputting log-concavity bounds). Feed in a polynomial, choose a bivariate slice, and out comes a certified shape constraint on the resulting counting sequence. It is a machine for turning geometry into combinatorics.

## The Bigger Picture

For three centuries, mathematicians have observed that counting sequences in combinatorics tend to be well-behaved: unimodal, log-concave, sometimes even "ultra-log-concave" (log-concave even after normalizing by binomial coefficients). Explaining *why* required tools from algebraic geometry, representation theory, and the theory of matroids, culminating in the Fields Medal–winning work of Huh and collaborators.

The new bridge theorem closes a gap in this story. It says precisely *how much* geometric information is needed to guarantee *how much* counting-sequence regularity. One level of Lorentzian curvature gives one level of log-concavity. Two levels give two. The translation is exact.

This is what mathematics does at its best: it finds hidden correspondences between seemingly unrelated domains and makes them precise. The curvature of a polynomial surface, defined by the eigenvalues of a matrix of second derivatives, controls the shape of a sequence of integers that count spanning trees, matroid bases, or statistical-mechanical configurations. The bridge is real, and it is now proven.

The numbers know what the geometry tells them.
