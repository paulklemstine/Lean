# Summary of changes for run d0d1c419-fe24-4dd3-87bd-568a4ac893fd
## Chapter 3 Written: *Hyperbolic Shortcuts: How Pythagoras Learned to Factor*

I've written the complete Chapter 3 at `Books/UNTITLED/Chapter3/Chapter3.md` (~8,200 words), following the Phase 1 Blueprint and matching the warm, witty, Martin Gardner–style voice of Chapters 1 and 2. 

### Structure

The chapter is organized into **twelve sections** across four narrative acts, plus reader puzzles:

**Act I — The Ancient Trick**
- §1 *The Puzzle of the Broken Square* — Opens with the party trick of factoring 441 via the Pythagorean triple (21, 20, 29); states and proves the difference-of-squares identity; historical aside on Diophantus and Fermat.
- §2 *A Tree That Grows All Right Triangles* — Introduces the three Berggren matrices, verifies them on the root (3, 4, 5), and presents the ternary tree with biographical note on Berggren (1934).

**Act II — The Physics Hiding Inside the Arithmetic**
- §3 *The Light-Cone in the Living Room* — Reveals that Pythagorean triples are null vectors in Minkowski spacetime; proves the Berggren matrices satisfy $B_i^\top Q B_i = Q$ (integer Lorentz transformations); historical aside on Minkowski (1908).
- §4 *The Invariant That Refuses to Change* — Shows $Q(B_i \mathbf{v}) = Q(\mathbf{v})$ for all vectors, not just null vectors; the Pythagorean property propagates as a conserved quantity.

**Act III — Fast Travel and the Elevator**
- §5 *Paths, Addresses, and the Art of Navigation* — Defines tree addresses, path matrices, and the shortcut composition theorem; includes worked address-finding examples.
- §6 *Hyperbolic Shortcuts* — Repeated squaring for $O(\log k)$ navigation; connection to ancient Egyptian multiplication and RSA cryptography.
- §7 *The Elevator Going Up* — Inverse Berggren matrices via the Lorentz adjoint formula $B_i^{-1} = Q B_i^\top Q$; worked ascent algorithm from (39, 80, 89) to root.

**Act IV — The Punchline: Factoring**
- §8 *Why the Hypotenuse Always Grows* — Growth bounds on all three branches with proofs.
- §9 *Chebyshev's Secret Recurrence* — The middle-branch recurrence $c_{n+1} = 6c_n - c_{n-1}$; connection to Chebyshev polynomials and matrix characteristic polynomials.
- §10 *No Two Branches Bear the Same Fruit* — Branch disjointness proofs.
- §11 *Cracking Numbers on the Light Cone* — The GCD Factoring Theorem; worked examples with (21, 20, 29) and (65, 72, 97); connection to Fermat's method and the quadratic sieve.
- §12 *Epilogue: Through the Wormhole* — Synthesis and forward look to Chapter 4.

### Compliance with Directives
- **Gardner persona**: Puzzle hooks open every section; warm/witty tone throughout.
- **Hidden blueprint**: Zero mentions of Lean 4, code, or formal syntax.
- **LaTeX**: All math in `$inline$` and `$$display$$` format.
- **Illustrations**: 15 detailed `[ILLUSTRATION: {...}]` tags embedded throughout.
- **Length**: ~8,200 words — comprehensive and intellectually rich.
- **Mathematical accuracy**: All matrix computations, GCDs, recurrences, and determinants verified computationally.