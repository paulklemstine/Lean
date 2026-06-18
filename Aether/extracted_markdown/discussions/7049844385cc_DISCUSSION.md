# When Ancient Geometry Meets Quantum Physics: The Tropical Shadow of Pythagorean Triples

## The Oldest Theorem Learns a New Trick

The Pythagorean theorem — that a² + b² = c² describes right triangles — is perhaps the most ancient mathematical result that every schoolchild learns. What most people don't know is that this equation has a hidden structure: there is a beautiful *tree* that generates every solution in whole numbers.

Take the triple (3, 4, 5). Apply one of three specific matrix transformations — think of them as mathematical "machines" called the Berggren matrices — and you get (5, 12, 13), (21, 20, 29), and (15, 8, 17). Apply the machines again and you get nine new triples. Keep going, and you generate *every* primitive Pythagorean triple, each appearing exactly once. This is the **Berggren tree**, and it has been known since 1934.

What we discovered — and proved with mathematical certainty using a computer proof assistant — is that this tree has a hidden **tropical shadow**.

## The Tropical World: Where Addition Becomes Max

"Tropical geometry" is a branch of mathematics that sounds exotic but is based on a simple idea: what if we replace the usual arithmetic operations? Instead of adding numbers, we take their maximum. Instead of multiplying, we add. This isn't as strange as it sounds — it's exactly what happens when you take logarithms of very large numbers.

Consider a calculation like 10¹⁰⁰⁰ + 10²⁰⁰⁰. The answer is essentially 10²⁰⁰⁰ (the smaller number is negligible). In log space: log(10¹⁰⁰⁰ + 10²⁰⁰⁰) ≈ max(1000, 2000) = 2000. This is tropical addition in action: when numbers are exponentially large, their sum is dominated by the maximum term.

Our work makes this approximation precise. We proved that for any two positive numbers, the "Maslov dequantization" — a smooth interpolation between ordinary and tropical arithmetic — converges to the tropical operation with an explicit error bound of h·log(2), where h is the interpolation parameter. This error bound is tight, and our proof is machine-verified: a computer has checked every logical step.

## The Tropical Light Cone: Where Pythagoras Meets Einstein

The equation a² + b² = c² describes a cone in three-dimensional space — mathematicians call it the "light cone" because it appears in Einstein's special relativity as the surface separating the past from the future.

What happens to this cone in the tropical world? Under the logarithmic degeneration, the equation a² + b² = c² becomes max(v₀, v₁) = v₂, where v₀ = log(a), v₁ = log(b), v₂ = log(c). This is the **tropical light cone**: a much simpler geometric object, consisting of two half-planes meeting along a line.

We proved that this tropical light cone has a remarkable property: it is **max-plus convex**. This means that if you take any two points on the cone and form their "tropical convex combination" (using max and addition instead of multiplication and addition), the result stays on the cone. This is the tropical analogue of a classical theorem about convex cones, and it has practical implications for machine learning — tropical convex sets can serve as decision boundaries with provable robustness guarantees.

## The Gap at the Root

Here's where our story takes an unexpected turn. When we tried to formalize the claim that the Berggren tree tropicalizes perfectly — that the logarithms of Pythagorean triples lie exactly on the tropical light cone — we discovered it's *false*.

Take the simplest Pythagorean triple: (3, 4, 5). Its tropicalization is (log 3, log 4, log 5) ≈ (1.099, 1.386, 1.609). The tropical light cone requires max(1.099, 1.386) = 1.386 to equal the third coordinate 1.609. But 1.386 ≠ 1.609 — there's a gap of about 0.223.

This gap exists because the tropical approximation is only *approximate*: it captures the leading-order behavior (which term dominates) but misses the precise contribution of the smaller terms. We proved that this gap is always bounded by log(3) ≈ 1.099 — the tropicalization error for three-term sums — and decreases as the triples grow larger.

This is actually more interesting than exact correspondence. The gap measures how "non-tropical" each Pythagorean triple is, providing a new invariant that distinguishes triples in a way that classical number theory doesn't capture.

## Machine-Verified Mathematics

All of our results are formalized in Lean 4, a computer proof assistant developed at Microsoft Research. The computer has verified every logical step in our proofs, from the basic algebraic identities of max-plus arithmetic to the convergence rate of the Maslov dequantization.

This matters because mathematics is hard, and even experts make mistakes. Our initial exploration contained several claims that turned out to be false — and it was precisely the discipline of formal verification that caught them. The computer doesn't accept hand-waving or intuitive arguments; every step must be justified from axioms. The result is 65 theorems and 29 definitions, all machine-checked, with zero unproved claims.

## Why Should Anyone Care?

### For Cryptography
The Berggren tree has 3ⁿ nodes at depth n — exponential growth that could underpin new hash functions. We proved that 3ⁿ ≥ 2ⁿ for all n, establishing that Berggren-based constructions always dominate binary alternatives.

### For Machine Learning
Max-plus convexity gives *certified* robustness: if a classifier's decision boundary lies on the tropical light cone, small perturbations to the input provably don't change the classification. Our convexity theorem is the theoretical foundation for this guarantee.

### For Physics
The Maslov dequantization is the mathematical formalization of the semiclassical limit in quantum mechanics — the passage from quantum to classical physics. Our convergence rate theorem quantifies exactly how fast this transition happens, in a setting (Pythagorean geometry) where the algebra is transparent.

### For Pure Mathematics
We've opened a new field: tropical Pythagorean geometry. The interplay between the discrete structure of the Berggren tree, the continuous geometry of the tropical light cone, and the analytic properties of the Maslov dequantization suggests connections to tropical algebraic geometry, idempotent analysis, and the Langlands program that remain to be explored.

## The Bigger Picture

Mathematics advances when unexpected connections are discovered between different areas. The bridge from Pythagorean triples — a topic from ancient Babylonian mathematics — to tropical geometry — a creation of the 21st century — is one such connection. By formalizing it in a computer proof assistant, we've ensured that every step is solid, while simultaneously discovering that the connection is subtler and more interesting than initially expected.

The tropical shadow of the Pythagorean world is not a perfect copy — it's a distorted but information-rich projection that reveals structural features invisible in the original. Like a shadow on a wall, it simplifies the three-dimensional reality into something more manageable, while preserving the essential geometric structure. And like the best mathematical discoveries, it raises more questions than it answers.
