# Summary of changes for run 48fdbc3c-ac4f-4c10-bb79-e8fa1f5490ec
## What I did

I investigated the cycle's "Close Proofs" target (fill the 3 `sorry` placeholders for the Fibonacci rank of apparition). A project-wide scan showed only **one** real `sorry` remained: the infinite tail (`n > 10000`) of Carmichael's composite-case theorem in `Catalog/Shared/CarmichaelProof.lean`. I also found that the catalog's apparent discharge of this tail (`Speculative.AutoResearch.fib_carmichael_large`) is **circular** — it just calls back into the same unproven lemma. This tail is the Fibonacci case of Zsygmondy's theorem and needs a cyclotomic-value lower bound absent from Mathlib, so it is a genuine research-level frontier rather than a quick fill; I documented it precisely (in code and in the future directions) instead of leaving a false/circular "proof".

### New, fully-proved deliverable (`sorry = 0`, axioms: `propext`, `Classical.choice`, `Quot.sound`)
New file `Catalog/Novelty/FibonacciApparitionGlue.lean` develops the rank of apparition `z(m)` as a **local-to-global sheaf** on the divisibility poset, building on (not reproving) the catalog's `Novelty.FibApparitionExistence` and `Applications.FibonacciPrimitiveDivisors`. Four theorems:
- `apparitionRank_dvd_of_dvd` — presheaf restriction map: `a ∣ b ⟹ z(a) ∣ z(b)`.
- `apparitionRank_lcm` — gluing law: `z(lcm a b) = lcm(z a, z b)` (obstruction-free).
- `apparitionRank_mul_of_coprime` — coprime/stalk reduction: `z(a·b) = lcm(z a, z b)`.
- `apparitionRank_eq_iff_isPrimitive` — cross-domain bridge: `z(m) = n ⟺ m` is a primitive divisor of `F_n`.

The file includes the required `-- !-- … -- !--` proof-sketch blocks and a Lab Notebook block.

### Supporting fixes
- `lakefile.toml`: added `srcDir = "Catalog"` (the library layout requires it) and declared the `Applications`/`Novelty` libraries so their proven modules can be imported.
- `Catalog/Shared/CarmichaelProof.lean`: removed a broken `import Shared.CarmichaelHelper` (the referenced file does not exist) so the file now compiles; annotated the remaining tail `sorry` with the precise mathematical obstruction and a pointer to the roadmap.
- `FUTURE_DIRECTIONS.md`: synthesis, results summary, and 5 falsifiable research directions (each with a "The key insight is…" sentence and a "Why now?" justification), led by a concrete cyclotomic-value roadmap for closing the Carmichael/Zsygmondy tail.

All new theorems and the touched files build successfully (verified via `lake build` of `Novelty.FibonacciApparitionGlue` and `Shared.CarmichaelProof`), and an axiom check confirms the four main results use only standard axioms.