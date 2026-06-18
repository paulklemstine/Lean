# Summary of changes for run 5eb5d6df-ba23-4d77-bf3a-328c6a4eea47
## Berggren Lattice Orbit Classification — Research Cycle Complete

I ran a full research loop (hypothesize → compute → prove → synthesize) on the modular orbit structure of the Berggren tree of primitive Pythagorean triples, extending the existing catalog (`Algebra/BerggrenLorentz/Core.lean`, `Pythagorean/BerggrenCompleteness.lean`). All Lean is fully verified with **0 sorries**, no `native_decide`, and only the standard axioms `propext, Classical.choice, Quot.sound`.

### Deliverables

**1. `Catalog/Cryptography/BerggrenOrbit.lean`** — Modular orbit classification.
- Berggren steps defined over an arbitrary commutative ring; each preserves the Lorentz form `a²+b²−c²` (light-cone invariance).
- `reach_pos_pythag`: every reachable triple is positive and Pythagorean.
- Reduction mod `n` commutes with the steps; a generic containment lemma (`reach_redT_mem`) propagates a step-closed residue set along the whole orbit (closure proved by `decide`).
- The reduced orbit was computed by BFS: sizes `1,4,2,12` for `n=2,3,4,5`. From these finite invariant sets I derived, intrinsically from the orbit, the classical Pythagorean congruence theorems: `reach_parity` (odd/even/odd legs), `reach_three_dvd_leg` (`3∣a∨3∣b`), `reach_four_dvd_evenleg` (`4∣b`), `reach_hyp_one_mod_four` (`c≡1 mod 4`), `reach_five_dvd_side` (`5∣` some side), and the capstone `reach_sixty_dvd_product` (`60 ∣ a·b·c`).

**2. `Catalog/Cryptography/BerggrenOrbitWords.lean`** — Word-level monoid structure (the key-exchange substrate).
- `Reach_iff_exists_word`: the orbit is exactly the set of word-encodings of the root.
- `reach_word_hyp_strictMono` + `applyWord_root_eq_root_iff_nil`: the hypotenuse is a strict Lyapunov function, giving acyclicity (only the empty word fixes the root) — the qualitative collision-resistance core of the encoding.
- `wordSign_append`: the orientation grading `w ↦ (−1)^{#B(w)}` is a `{±1}`-valued homomorphism (the public det-parity invariant).

**3. `Catalog/Cryptography/FUTURE_DIRECTIONS.md`** — Five precise, computationally-grounded conjectures, including: CRT-multiplicativity of orbit size; the odd-prime formula `|O(p)| = (p²−1)/2` (verified for p=3,5,7,11,13); the odd-prime-power tower `|O(pᵏ)| = p^{2(k−1)}(p²−1)/2`; the anomalous 2-adic tower; and exact-image/sparsity for key-space density.

Both files contain inline `-- !-- Lab Notes -- !--` blocks recording hypotheses, BFS experiment outcomes, insights, and failure analyses (e.g. predicate sets are not step-closed; `fin_cases` fails on cast residues — membership must be unfolded explicitly).

### Build note
The project's `lakefile.toml` was missing `srcDir`, so no module under `Catalog/` could resolve (the bare `lake build` failed before any source was even read). I added `srcDir = "Catalog"`, which makes the catalog buildable; both new modules then compile (`lake build Cryptography.BerggrenOrbit Cryptography.BerggrenOrbitWords` succeeds).