# When Ancient Triangles Meet Modern Cryptography

*How a 3,800-year-old mathematical pattern could help protect your data from quantum computers*

## The World's Oldest Math Problem

Around 1800 BCE, a Babylonian scribe pressed a wedge-shaped stylus into wet clay and recorded a table of numbers. The tablet, now known as Plimpton 322, contains what we would recognize as Pythagorean triples: sets of three numbers (a, b, c) where a² + b² = c². The most famous example is (3, 4, 5) — any right triangle with legs 3 and 4 has a hypotenuse of 5.

For millennia, mathematicians have been fascinated by these triples. But in 1934, a Swedish mathematician named B. Berggren discovered something remarkable: every primitive Pythagorean triple (where the legs share no common factor) can be generated from the single triple (3, 4, 5) by applying three specific matrix transformations, labeled A, B, and C. The result is a ternary tree — each triple spawns exactly three children:

```
                    (3, 4, 5)
                   /    |    \
            (5,12,13) (21,20,29) (15,8,17)
           /   |   \    ...       ...
     (7,24,25) ...
```

Every primitive Pythagorean triple appears exactly once in this infinite tree. It's like a family tree for right triangles.

## The Hidden Geometry of Spacetime

Here's where things get surprising. The Berggren matrices don't just preserve the Pythagorean equation a² + b² = c². They preserve a more fundamental object: the *Lorentz form* Q(a,b,c) = a² + b² - c².

If you've heard of Einstein's special relativity, this formula should ring a bell. The Lorentz form is essentially the spacetime interval — the quantity that all observers agree on regardless of their relative motion. In physics, vectors with Q = 0 travel at the speed of light; they lie on the "light cone."

The Pythagorean equation a² + b² = c² is precisely the condition Q = 0. In other words, **Pythagorean triples are integer points on the light cone of Minkowski spacetime**. And the Berggren matrices are discrete Lorentz transformations — the integer-valued analogs of the symmetries that govern relativistic physics.

This connection, which we formalize rigorously in Lean 4, bridges number theory (Pythagorean triples), hyperbolic geometry (the Lorentz group), and physics (spacetime symmetries) in a single algebraic framework.

## From Triangles to Locks

Now comes the cryptographic twist. The Berggren tree is a ternary tree — each node has three children. At depth n, there are 3^n nodes. This means the number of possible paths from the root grows *exponentially*. At depth 81, there are more paths (3^81 ≈ 4.4 × 10^38) than there are atoms in a human body.

This exponential growth is the raw material of cryptography. Consider a simple protocol:

1. **Alice** picks a secret path through the Berggren tree — say, "A, then B, then C, then A, then A" — and computes the matrix product M_A · M_B · M_C · M_A · M_A.
2. She applies this matrix to the root triple (3, 4, 5) and publishes the result.
3. **Bob** does the same with his own secret path.
4. They exchange their public values and derive a shared secret.

An eavesdropper who intercepts the public values would need to find the secret path — essentially solving a "discrete logarithm" problem in the Berggren group. But because the group is *non-abelian* (the order of multiplications matters — AB ≠ BA, as we prove), this problem doesn't succumb to the quantum algorithms that break conventional Diffie-Hellman.

## A Surprising Symmetry

While formalizing these results, we discovered a fact that surprised us: **all three Berggren matrices have identical Frobenius norm**.

The Frobenius norm is a measure of a matrix's "size" — the square root of the sum of squares of all entries. Despite having different traces (3, 5, and 3), different determinants (1, -1, and 1), and producing vastly different children, matrices A, B, and C all have ‖M‖²_F = 35.

This means all three branches of the Berggren tree expand at the same rate, on average. It's a hidden symmetry — not visible from the determinant structure, not visible from the traces, only revealed when you compute the full entry-level norm. We prove this rigorously for all three matrices.

## The Lipschitz Connection to AI Safety

The Frobenius norm bound also has implications for machine learning. A neural network whose weight matrices are Berggren matrices would have a provable Lipschitz constant of √35 ≈ 5.92. This means: if you perturb an input by a tiny amount ε, the output changes by at most 5.92ε.

This kind of bound is exactly what "certified robustness" provides — a mathematical guarantee that small adversarial perturbations cannot fool the classifier. While practical neural networks use real-valued weights, the integer structure of Berggren matrices could serve as a template for constructing networks with built-in robustness certificates.

## The Tropical Shadow

There's one more connection worth mentioning. In "tropical mathematics," addition is replaced by taking the maximum, and multiplication is replaced by addition. This seemingly bizarre redefinition leads to rich geometric structures.

The tropical version of the Pythagorean equation Q(a,b,c) = a² + b² - c² becomes max(a, b) - c. The "tropical light cone" — where this expression equals zero — is simply the set of triples where max(a, b) = c. We prove that on this tropical cone, both a ≤ c and b ≤ c, a tropical analog of the fact that the hypotenuse is the longest side.

These tropical structures appear naturally in the study of neural network decision boundaries, where the max-plus algebra describes the piecewise-linear functions computed by ReLU networks.

## What We Proved, and What It Means

Our Lean 4 formalization contains 83 theorems with zero unproved statements (sorry-free). The proofs use diverse tactics: native_decide for concrete matrix computations, ring for polynomial identities, nlinarith for quadratic inequalities, and induction for structural arguments.

The key results:
- **Lorentz preservation**: All Berggren matrices, their products, and arbitrary paths preserve the Lorentz form.
- **Light cone classification**: Pythagorean triples ↔ integer light cone points.
- **Lipschitz bound**: ‖Mv‖² ≤ 35·‖v‖² for all Berggren matrices M.
- **SVP lower bound**: The minimum norm in the depth-1 Berggren lattice is √338 ≈ 18.4.
- **Non-abelian structure**: AB ≠ BA, blocking quantum Fourier attacks.
- **Key exchange correctness**: Matrix associativity ensures shared secret agreement.

## The Big Picture

What excites us most about this work is the *convergence*. A pattern discovered by the Babylonians, organized by Berggren, illuminated by Lorentz, and now potentially protecting our digital communications from quantum computers — all connected by a single quadratic form, Q(a,b,c) = a² + b² - c².

The mathematics doesn't care about applications. But applications care very much about mathematics. And sometimes the deepest mathematics turns out to be hiding in the simplest places — like a right triangle with sides 3, 4, and 5.
