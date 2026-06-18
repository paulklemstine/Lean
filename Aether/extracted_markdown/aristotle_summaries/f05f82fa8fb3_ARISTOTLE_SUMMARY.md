# Summary of changes for run 74c8dca9-c519-4f53-8eda-71efc47e4c93
Chapter 11 — *The Magnificent Sieve: How Squares Conspire to Break Numbers Apart* — has been written and saved to `Books/UNTITLED/Chapter11/Chapter11.md`.

**Summary of the chapter (~8,100 words, 10 sections, 16 embedded illustration tags):**

1. **The Puzzle of the Two Impostor Squares** — Opens with the hands-on puzzle of finding x, y such that n divides x² − y² but neither factor alone, using n = 8051 = 83 × 97. States the Splitting Principle theorem.

2. **Why the Trick Works** — The algebra of shared factors, the Cofactor Theorem, the GCD product bound, and a Venn-diagram explanation of how prime factors distribute between (x−y) and (x+y).

3. **Fermat's Method and Its Magnificent Slowness** — Historical motivation via Fermat's direct x² − y² = n search, analysis of why it's slow for unbalanced semiprimes, and the transition to the modern congruence-based relaxation.

4. **The Smooth Criminal** — Definition of B-smoothness, elementary properties (vacuous truth for 1, closure under multiplication, monotonicity), Dickman's function, and John Selfridge's coinage of the term.

5. **The Factor Base** — Definition, connection to smoothness, and the exponent vector representation that translates multiplicative structure into additive linear algebra.

6. **The Exponent Vector and the Magic of Modular Arithmetic** — The light-switch puzzle as motivation for F₂ arithmetic, the reduction of "find a perfect-square product" to "find a linear dependency over F₂ᵏ."

7. **The Birthday Bound** — The Guaranteed Dependency theorem (k+1 vectors in F₂ᵏ must be linearly dependent), its clean five-step proof, and its role as the algebraic certainty that powers every sieve. Historical note on Gauss, Dixon, and Pomerance.

8. **A Worked Example** — Step-by-step sieve of n = 15,347 with B = 13, including sieving table, exponent matrix construction, Gaussian elimination over F₂, and factor extraction.

9. **The Menagerie of Modern Sieves** — Dixon's random squares, the Quadratic Sieve, and the Number Field Sieve, with complexity expressions and the RSA-768 factoring milestone.

10. **Philosophical Coda** — Reflection on the interplay of number theory, combinatorics, and linear algebra; forward references to Chapters 12 and 13.

The chapter follows all directives: Martin Gardner's warm, puzzle-driven voice throughout; no references to formal verification, code, or syntax; LaTeX for all mathematical notation; and richly detailed [ILLUSTRATION] tags for every key concept.