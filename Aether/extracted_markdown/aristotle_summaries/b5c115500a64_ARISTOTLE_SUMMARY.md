# Summary of changes for run 85f8298a-daa7-4b2a-b13c-776fa164d69b
**Phase 1 Blueprint for Chapter 7 — Complete**

I have produced a detailed, section-by-section outline for Chapter 7, saved as `Chapter7_Blueprint.md` in the project root. Here is what it contains:

**Title**: *"The One-Way Corridor: Why Quantum Shortcuts Aren't Where You'd Expect"*

**10 Sections, ~50 pages planned:**

1. **"The Forking Labyrinth"** — Opens with a branching-maze puzzle; introduces the three inverse Berggren maps as "corridor maps" in a ternary tree.
2. **"The Cancellation Trick"** — The mathematical heart: three mutual-exclusion proofs (branches 1&2, 1&3, 2&3 can't both produce positive triples) culminating in the Determinism Theorem. Presented as short puzzles based on the sum-to-zero identity.
3. **"What Quantum Computers Actually Do"** — A library parable introduces Grover's query bound $O(\sqrt{S/M})$, with historical notes on Grover's 1996 discovery and the BBBV lower bound.
4. **"Searching for the Magic Depth"** — Applies Grover to the depth axis of the tree descent, reducing classical $O(d^*)$ to quantum $O(\sqrt{d^*})$.
5. **"Balanced Semiprimes and the Fourth-Root Barrier"** — For $N = pq$ with $p \approx q$, the quantum cost is $O(N^{1/4})$. Includes comparison with Shor's algorithm.
6. **"A Gallery of Dead Ends"** — Fully worked numerical examples ($N = 15$, $N = 21$) showing the descent step-by-step, with all three candidate parents displayed and the invalid ones crossed out.
7. **"Why Quantum Parallelism Fails at the Fork"** — A deeper philosophical treatment of why deterministic structure defeats quantum branching; the novel-reading analogy.
8. **"The Sum-to-Zero Principle"** — Generalises the cancellation trick into a standalone miniature theory with connections to graph theory and physics.
9. **"From Square Roots to Fourth Roots"** — A complexity ladder placing trial division, classical tree descent, quantum tree descent, and Shor's algorithm side by side.
10. **"Open Corridors"** — Five open questions (existence of valid branches, structured search beyond Grover, multi-channel Grover, hybrid algorithms, physical feasibility).

The blueprint includes **14 detailed `[ILLUSTRATION]` placeholders**, specifies where LaTeX-heavy mathematical reveals occur, and maps every section back to the proven theorems from the source material — all without any mention of formal verification or code. Written entirely in the Martin Gardner voice.