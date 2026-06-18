# Summary of changes for run 691aafe0-114d-4e21-ab17-3796ad74feba
Chapter 7 — "The One-Way Corridor: Why Quantum Shortcuts Aren't Where You'd Expect" — has been written and saved to `Books/UNTITLED/Chapter7/Chapter7.md`.

**Contents (~4,500 words, 12 illustration placeholders):**

The chapter follows the blueprint's 10-section arc, woven into a unified narrative in Martin Gardner's warm, puzzle-driven voice:

1. **The Forking Labyrinth** — Opens with the labyrinth puzzle, recaps the Pythagorean-triple tree and the three inverse Berggren maps, setting up the (wrong) expectation that quantum parallelism helps at every fork.

2. **The Cancellation Trick** — Three elegant impossibility proofs showing that pairs of inverse maps produce components summing to zero, yielding the Determinism Theorem: at most one inverse image can have all-positive entries.

3. **A Parable of the Circular Library** — Grover's search algorithm explained as a library parable, with the precise query bound $Q \leq \lfloor\sqrt{S/M}\rfloor + 1$ and historical context (Grover 1996, the BBBV optimality proof).

4. **Searching for the Magic Depth** — Applies Grover not to the branching (which is deterministic) but to the depth axis, yielding $O(\sqrt{d^*})$ quantum complexity vs. $O(d^*)$ classical.

5. **Balanced Semiprimes and the Fourth-Root Barrier** — Derives the $N^{1/4}$ bound for balanced semiprimes via the inequality chain $\sqrt{d^*} \leq \sqrt{p} \leq N^{1/4}$, with comparison to Shor's algorithm.

6. **A Gallery of Dead Ends** — Worked numerical example for $N = 15$, showing all three inverse maps explicitly and the gcd revealing factor 3 at depth 1.

7. **Why Quantum Parallelism Fails at the Fork** — The philosophical heart: determinism defeats quantum branching; the novel-reading analogy; the real speedup lives on the depth axis.

8. **The Sum-to-Zero Principle** — Generalises the cancellation trick into a clean lemma, with connections to graph theory, physics, and alternating-sign matrices.

9. **The Complexity Ladder** — A ranked comparison table from trial division ($O(\sqrt{N})$) through quantum tree descent ($O(N^{1/4})$) to Shor ($O((\log N)^{2+\varepsilon})$), with the full inequality chain proved.

10. **Open Corridors** — Five open questions (existence, structured depth, multi-channel Grover, hybrid algorithms, physical realisability) closing with the labyrinth metaphor.

All mathematics uses $inline$ and $$display$$ LaTeX. No mentions of Lean, code, syntax, or formalization appear anywhere in the text.