# Summary of changes for run 2107ac31-760f-4760-8190-ca98e76ed860
Delivered a new, self-contained Lean 4 research file and the required research notes for the concept "Tropicalization of Berggren dynamics as a max-plus semigroup action."

**New file:** `Catalog/Bridges/TropicalBerggrenSemigroup.lean` (compiles cleanly, no `sorry`, no errors/warnings; axiom footprint is only `propext`, `Classical.choice`, `Quot.sound`). It builds an integer max-plus (tropical) shadow of the Berggren tree of primitive Pythagorean triples and proves how much classical structure survives tropicalization. It is complementary to the existing `Catalog/Tropical/BerggrenTropicalBridge.lean` (which works over ℝ with `Real.log` and an `O(log 3)` error): here everything is integer and exact, and it references the catalog foundations (`Algebra/BerggrenLorentz/Core`, `Cryptography/BerggrenLatticeReduction`, `Computation/QuantumBerggrenWalk`) in its proof sketches.

**Main theorems proved (all complete):**
- `tropMV_comp` / `tropMM_assoc` — the tropical matrix product realizes operator composition exactly and sign-free (the semigroup action law); associativity.
- `tropMV_mono` — every tropical operator is order-preserving.
- `tropAct_append` — the tropical word action is a homomorphism (mirror of the catalog `evalWord_append`).
- `subMV_le_linMV`, `linMV_le_three_subMV`, `berggrenB_growth_sandwich` — a logarithm-free two-sided growth sandwich bracketing the classical linear action within a factor n=3.
- `subIter_le_linIter` — the lower sandwich composes along an entire B-word with no constant loss (certified growth lower bound read from the word).
- `lorentz_trop_balance` (+ `_childA/B/C`, `_tight`) — a tropical Lorentz quasi-invariant `max(a²,b²) ≤ c² ≤ 2·max(a²,b²)`, invariant over the whole tree, with the factor 2 shown tight at the root.
- `tropAct_unfaithful` (negative result) and `subMV_not_le_linMV_A` (explicit counterexample) — the absolute-value tropicalization collapses all three generators (it sees only word length), and the lower sandwich fails for the signed generator A at the root, isolating sign data as the missing ingredient.

**Notes/deliverables:** Each major theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis), which also serves as its brief proof sketch. `FUTURE_DIRECTIONS.md` (at the project root) contains the required `## Synthesis` and `## Results Summary` sections plus 5 falsifiable research directions (sharp exponential base of the upper sandwich; a faithful signed tropical model; tropical Lorentz balance as a depth oracle; Kleene-star closure of the B-operator; generalization to higher-dimensional Lorentz trees), each with Hypothesis/Test/Why-now/If-true/If-false and a "key insight" statement.

A note for context: the project's `lakefile.toml` library globs (`Tropical.+`, `Bridges.+`, …) do not match the on-disk `Catalog/...` layout, so `lake build` does not pick up the catalog files; the new file was therefore verified directly through the Lean elaborator (full file, zero diagnostics) rather than via `lake build`.