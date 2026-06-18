Formalize a complete Lean 4 development of modular invariants of the Berggren orbit, focusing on finite-state orbit classification modulo small integers and removing speculative post-quantum claims. Use the existing Berggren/Lorentz formalization as the foundation.

Target file: `Catalog/Cryptography/BerggrenOrbit.lean` is acceptable if you want to preserve the cross-domain motivation, but the mathematical content should be number-theoretic/dynamical and fully self-contained.

Precise task:
1. Import and reuse the existing Berggren generator definitions and any already-proved Lorentz-form invariance / positivity lemmas from the catalog.
2. Define the three Berggren steps on integer triples if not already available under imported names.
3. Define an inductive predicate `Reach : ℤ × ℤ × ℤ → Prop` (or an equivalent structure) generated from the root `(3,4,5)` and closed under the three steps.
4. Prove foundational theorems for all reachable triples:
   - preservation of the Pythagorean equation `a^2 + b^2 = c^2`
   - positivity / nonnegativity as supported by available lemmas
5. For each modulus n = 2, 3, 4, 5:
   - define reduction of triples modulo n
   - define an explicit finite subset `S_n` of residue triples
   - prove the root reduces into `S_n`
   - prove `S_n` is closed under the three Berggren generators modulo n
   - conclude every reachable triple reduces into `S_n`
6. Deduce concrete divisibility corollaries from those finite residue classifications:
   - mod 2: `(a,b,c) ≡ (1,0,1)` and therefore `a` odd, `b` even, `c` odd
   - mod 3: `3 ∣ a ∨ 3 ∣ b`
   - mod 4: `4 ∣ b` and `c ≡ 1 [ZMOD 4]` / integer remainder formulation as convenient
   - mod 5: `5 ∣ a ∨ 5 ∣ b ∨ 5 ∣ c`
7. Prefer simple, explicit proofs over abstraction. A good strategy is brute-force finite checking on residue classes using `native_decide`, `fin_cases`, or explicit enumeration, provided the statements remain readable and robust.
8. Eliminate all placeholders and incomplete declarations. The file must typecheck end-to-end with no `sorry`.

Important scope control:
- Do NOT attempt a full word/orbit classification in the free monoid unless the necessary infrastructure is already in the catalog and the proof is short.
- Do NOT make cryptographic security claims or analogies to CSIDH in theorem statements.
- If a theorem inventory from the previous attempt is too ambitious, reduce to the strongest fully provable modular-invariant package.

Suggested theorem shape:
- `reach_pythag`
- `reach_pos` or `reach_nonneg`
- `reach_mod2`, `reach_parity`
- `reach_mod3`, `reach_three_dvd_leg`
- `reach_mod4`, `reach_four_dvd_evenleg`, `reach_hyp_one_mod_four`
- `reach_mod5`, `reach_five_dvd_side`
- optionally a generic lemma expressing the finite-state certification pattern

The key insight is that Berggren dynamics on primitive Pythagorean triples admits a finite-state shadow modulo small n, and these shadows are strong enough to recover classical divisibility laws intrinsically from the monoid action rather than from Euclid parametrization. Why now? The Berggren generators and Lorentz-form preservation are already formalized in the catalog, so the remaining work is a tractable Lean exercise in inductive reachability plus finite residue closure proofs.