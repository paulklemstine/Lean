# The Hidden Tree Inside Every Right Triangle

## How a single mathematical operator reveals an infinite forest of Pythagorean triples — and a computer verified every step

*By the EML–Pythagorean Research Team*

---

Most people remember the Pythagorean theorem from school: in a right triangle with legs *a* and *b* and hypotenuse *c*, we have *a*² + *b*² = *c*². The most famous example is the 3-4-5 triangle. But here's something remarkable that few people know: there is an infinite tree — a family tree of sorts — that generates *every* right triangle with whole-number sides from that single ancestor (3, 4, 5). And we've just discovered that this tree has a secret life in the world of exponentials and logarithms.

## A Family Tree for Triangles

In 1934, Swedish mathematician Berggren discovered something beautiful. Starting from (3, 4, 5), you can apply three simple matrix transformations to produce three "children":

- **Child A:** (5, 12, 13)
- **Child B:** (21, 20, 29)
- **Child C:** (15, 8, 17)

Each child is itself a valid Pythagorean triple. Apply the same three transformations to each child, and you get nine grandchildren. Keep going, and you generate an infinite ternary tree.

The stunning fact, proved by Barning in 1963 and later by others: **every** primitive Pythagorean triple (one where the three sides share no common factor) appears exactly once in this tree. It's a complete genealogy of all right triangles.

## The Light Cone Connection

Why does this work? The answer lies in Einstein's physics — or rather, in the same mathematics that describes it.

Define the "Lorentz form" Q(a, b, c) = a² + b² − c². For a Pythagorean triple, Q = 0 — the triple lies on what physicists call the "null cone" or "light cone." The Berggren matrices are special: they preserve this form. In physics language, they're Lorentz transformations of the integer lattice.

This means the Berggren tree is really a discrete subgroup of the Lorentz group O(2,1;ℤ), the same mathematical structure that describes special relativity in 2+1 dimensions. Pythagorean triples are, quite literally, lightlike vectors in a discrete spacetime.

## One Operator to Rule Them All

Now comes the bridge. In 2025, physicist Andrzej Odrzywolek showed that a single binary operator can generate every function you learned in calculus — exponentials, logarithms, sines, cosines, and everything built from them. The operator is deceptively simple:

**eml(x, y) = eˣ − ln y**

That's it. From this one operation and the number 1, you can build all of mathematics' most important functions. For example:
- exp(x) = eml(x, 1)
- ln(z) = 1 − eml(0, z)
- e = eml(1, 1)

## Crossing the Bridge

Here's where things get exciting. The Pythagorean condition a² + b² = c² can be rewritten in logarithmic coordinates as:

**e^(2 ln a) + e^(2 ln b) = e^(2 ln c)**

Since each Berggren transformation is a polynomial in a, b, c — and polynomials are elementary functions — every step in the Berggren tree can be encoded as a finite tree of EML operations. A triple at depth *d* in the Berggren tree requires only O(*d*) EML nodes to compute.

This creates a bridge between two seemingly unrelated worlds:
- **The discrete world** of integer triples, matrices, and number theory
- **The continuous world** of exponentials, logarithms, and analysis

## What the Computer Proved

We didn't just conjecture these connections — we proved them with mathematical certainty using Lean 4, a computer proof assistant used by mathematicians worldwide. A computer verified, line by line, that:

✓ All three Berggren matrices preserve the Lorentz form
✓ Every path in the tree produces a valid Pythagorean triple
✓ The growth rate of the "fast lane" (B-branch) is exactly 3 + 2√2 ≈ 5.828
✓ The exponential function has no real fixed point (exp(x) > x always)
✓ The EML operator undergoes a bifurcation at y = e (Euler's number)
✓ The product of any two Pythagorean hypotenuses is itself a hypotenuse

These aren't just computational checks — they're absolute mathematical proofs, verified to the same standard as the most rigorous human proofs, but checked by machine.

## Surprising Discoveries

The formalization process itself led to new discoveries:

**The determinant surprise.** We expected all three Berggren matrices to have determinant +1 (preserving orientation). The computer revealed that B₂ has determinant −1 — it includes a hidden reflection. B₁ and B₃ have determinant +1.

**The golden speed limit.** The "fast lane" of the tree (repeatedly applying B₂) generates triples whose hypotenuses grow like powers of 3 + 2√2. This number is the larger root of x² − 6x + 1 = 0, the same equation that governs Pell numbers. The hypotenuses follow the recurrence c_{n+1} = 6c_n − c_{n-1}.

**The angle distribution.** As you go deeper in the tree, the average angle of the triples converges to 45° — but the distribution is *not* uniform. It's concentrated around 45° with a specific shape that we conjecture is related to the spectral properties of a "transfer operator" on the tree.

**The EML bifurcation.** The fixed points of the EML operator undergo a saddle-node bifurcation at y = e. Below this threshold, the dynamics always diverge; above it, there's a stable equilibrium. This connects to the Lambert W function, one of mathematics' most useful special functions.

## A Hyperbolic Forest

Perhaps the most beautiful visualization is geometric. The Lorentz form defines a model of hyperbolic geometry — the strange, curved geometry where parallel lines diverge. The Berggren tree creates a tessellation of the hyperbolic plane, like the mesmerizing tilings in M.C. Escher's *Circle Limit* woodcuts.

Each Pythagorean triple corresponds to a point at "infinity" in this hyperbolic world (a cusp on the boundary circle). The tree structure means these cusps are organized in a fractal pattern, dense on the circle but structured by the three Berggren generators.

## What Comes Next?

Our work opens 35+ research directions. Among the most exciting:

**Can we extend to 3D?** Pythagorean quadruples satisfy a² + b² + c² = d². Is there a Berggren-like tree for these? The mathematics would involve quaternions — the four-dimensional cousins of complex numbers — and the Lorentz group in 3+1 dimensions.

**What about the zeta function?** Summing c^(-s) over all primitive triples gives a "Berggren zeta function." Does it have the beautiful analytic properties of the Riemann zeta function?

**Can machines learn Diophantine equations?** The EML framework provides a natural "hypothesis class" for machine learning: train a neural network to find integer solutions by optimizing EML tree parameters.

## Why It Matters

This work illustrates a broader truth: mathematics is more interconnected than it appears. The Pythagorean theorem, taught to every schoolchild, connects to Gaussian integers (invented in the 1830s), the Lorentz group (1900s physics), hyperbolic geometry (1830s), and a brand-new universal operator (2025). Each connection illuminates the others.

The formal verification adds a new dimension. When a computer checks every logical step, we can be confident that our bridge stands on solid ground — and that the view from it is real.

---

*The complete Lean 4 proofs, Python demonstrations, and SVG visualizations are available in the project repository.*

---

### Sidebar: The Berggren Tree at a Glance

```
                    (3, 4, 5)
                   /    |    \
            (5,12,13) (21,20,29) (15,8,17)
            /  |  \    /  |  \    /  |  \
          ...  ...  ... ...  ... ...  ...  ...
```

- **Root:** (3, 4, 5) — the simplest primitive triple
- **Branching:** Each triple has exactly 3 children
- **Completeness:** Every primitive triple appears exactly once
- **Growth:** 3ⁿ triples at depth n; total of (3ⁿ⁺¹ − 1)/2 at depth ≤ n
- **B-branch speed:** Hypotenuses grow by factor ≈ 5.828 per step

### Sidebar: Machine-Verified Mathematics

Lean 4 is a *proof assistant* — software that checks mathematical proofs for correctness. Unlike a calculator that gives numerical answers, Lean verifies logical arguments step by step. If Lean accepts a proof, it is correct — period.

Our project contains 30+ verified theorems across 5 files totaling hundreds of lines of Lean code. The verification covers number theory, linear algebra, real analysis, and combinatorics — all unified by the EML–Pythagorean bridge.

### Sidebar: The EML Operator

| Function | EML Expression |
|----------|---------------|
| eˣ | eml(x, 1) |
| ln(x) | 1 − eml(0, x) |
| e | eml(1, 1) |
| x + y | log(eml(x,1) · eml(y,1)) |
| x · y | exp(1 − eml(0,x) + 1 − eml(0,y)) |
| sin(x) | Im(eml(ix, 1)) |
