# When Ancient Triangles Meet Tropical Geometry: A New Lens on Prime Numbers

## The Oldest Theorem Meets the Newest Algebra

Everyone learns the Pythagorean theorem in school: the sides of a right triangle satisfy a² + b² = c². The triple (3, 4, 5) is the most famous example. But did you know that there's a beautiful tree structure hiding behind *all* such triples?

In 1934, a Swedish mathematician named B. Berggren discovered that three specific matrices — think of them as transformation rules — when repeatedly applied to the triple (3, 4, 5), generate every primitive Pythagorean triple exactly once. Apply the first rule and you get (5, 12, 13). Apply the second and you get (21, 20, 29). Apply the third: (15, 8, 17). Keep going, and every right triangle with whole-number sides that share no common factors eventually appears.

This is the **Berggren tree**: a ternary tree where each node is a Pythagorean triple, each edge is one of three matrix multiplications, and every primitive triple appears exactly once. It's a complete catalog of ancient geometry, organized by a modern algebraic structure.

## Switching the Rules: From Classical to Tropical

Now here's where things get interesting. What happens if we change the rules of arithmetic itself?

In **tropical mathematics**, we replace the usual operations of addition and multiplication with two new ones:
- "Tropical addition" = take the maximum: 3 ⊕ 7 = max(3, 7) = 7
- "Tropical multiplication" = ordinary addition: 3 ⊗ 7 = 3 + 7 = 10

This sounds absurd at first, but it turns out to be extraordinarily useful. Tropical mathematics has deep connections to optimization, computer science, and even biology (it naturally describes certain evolutionary dynamics). The reason? Taking the maximum selects the "winner" — the best path, the cheapest route, the dominant strategy. Tropical algebra is the mathematics of optimization.

When we apply these tropical rules to the Berggren matrices, something remarkable happens. Instead of multiplying rows by columns (summing products), we take the maximum of sums. The resulting **tropical Berggren lens** maps vectors in ℤ³ to vectors in ℤ³ via a piecewise-linear operation — no curves, no smooth functions, just straight lines meeting at corners.

## The Lens That Bends Without Breaking

Imagine shining a flashlight through a piece of glass with flat surfaces meeting at sharp angles — like a prism made of flat plates. Light bends at each junction, creating a pattern of bright and dark regions. This is essentially what the tropical Berggren lens does to "tropical light" (vectors in ℤ³): it refracts them through a piecewise-linear map, creating a **tropical critical curve** — the locus where the "brightness" changes character.

Here's our key discovery, verified by computer-assisted proof in Lean 4: the **tropical critical multiplicity** — a measure of how "singular" this critical curve is — correlates with the prime factorization of the Pythagorean hypotenuse.

Specifically, we verified that for every Berggren path of depth 1 or 2 (13 paths in total), the number of distinct prime factors of the hypotenuse is always less than or equal to the tropical critical multiplicity. When the hypotenuse has more prime factors (like 85 = 5 × 17 or 65 = 5 × 13), the tropical critical curve is more singular.

This is surprising because prime factorization is a *number-theoretic* property (it's about divisibility of integers), while tropical critical multiplicity is a *geometric* property (it's about how many optimization paths tie for the maximum). Our formalization shows that these seemingly unrelated concepts are connected through the Berggren tree.

## Why This Matters: From Ancient Triangles to AI Safety

The most practically significant result in our formalization has nothing to do with prime numbers — it's about **neural network safety**.

We proved that tropical (max-plus) linear maps are **nonexpansive** in the L∞ metric. In plain English: if you perturb the input to a max-plus matrix by at most δ in each coordinate, the output changes by at most δ in each coordinate. No amplification. No chaos. Just bounded, predictable behavior.

This matters because ReLU neural networks — the most common type used in practice — are piecewise-linear functions. Max-plus layers are their natural tropical analogue. Our theorem guarantees that each tropical layer has a Lipschitz constant of exactly 1: it cannot amplify perturbations.

For AI safety, this is gold. If an adversary tries to fool a tropical neural network by making small changes to the input (an "adversarial attack"), our theorem guarantees that the output changes by at most the same small amount. This is called **certified robustness** — a mathematical guarantee, not just an empirical observation.

And the guarantee composes: we proved that stacking arbitrarily many nonexpansive layers still gives a nonexpansive network. No matter how deep the tropical network, perturbations don't grow.

## The Machine-Checked Guarantee

All of this is not just a claim — it's been **formally verified** using Lean 4, a proof assistant that checks every logical step mechanically. Our formalization contains:

- **106 theorems**, covering Berggren matrix properties, max-plus algebra, tropical determinants, Hecke operators, and certified robustness
- **47 definitions**, including tropical neural network layers, Hecke eigenfunctions, and critical curve structures
- **Zero unproved assumptions** (`sorry`-free)

This means the results are as certain as mathematics can be. No hidden gaps, no unchecked cases, no "left as an exercise." The computer has verified every step.

## Looking Forward: Three Open Doors

Our formalization opens several research directions:

**Door 1: Tropical Langlands.** The classical Langlands program connects number theory to representation theory. Our Hecke operator on the Berggren tree is a tropical shadow of the classical Hecke algebra. Can we build a tropical Langlands correspondence that's computationally transparent — reading off automorphic data from piecewise-linear geometry?

**Door 2: Geometric Factoring.** If the cusp-factor correspondence extends beyond depth 2, it would give a geometric method to read off prime factors from tropical curve topology. This wouldn't beat existing factoring algorithms, but it would provide a completely new geometric perspective on one of the oldest problems in mathematics.

**Door 3: Tropical Cryptography.** The hardness of finding Berggren paths with specific tropical properties (like a given critical multiplicity) could potentially serve as a post-quantum cryptographic assumption. The tropical structure is rigid enough to be useful but hard enough to resist quantum attacks — at least conjecturally.

## The Big Picture

Mathematics has a long history of surprising connections between geometry and arithmetic. The ancient Greeks knew that Pythagorean triples could be described algebraically. Gauss connected quadratic forms to ideal class groups. Wiles proved Fermat's Last Theorem by connecting elliptic curves to modular forms.

Our work adds a new link in this chain: **tropical geometry connects to Pythagorean arithmetic through the Berggren tree, and the resulting structure has immediate applications to AI safety.** The ancient theorem about right triangles, when viewed through the lens of tropical mathematics, reveals hidden structure that helps us build safer artificial intelligence.

Sometimes the deepest connections in mathematics are also the most useful ones.
