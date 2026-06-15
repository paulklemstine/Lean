Complete the partial formalization by producing a single compiling Lean 4 file that only contains the essential theorem package for the max-plus-depth to multiplicative-shadow bridge.

Target file idea:
`Catalog/Bridges/FunctorialDepthTropicalLipschitz.lean`

Scope restrictions:
- Keep the development small and self-contained.
- Use only elementary `Nat` arithmetic and the existing valuation-depth composition result from the catalog.
- Avoid category-theoretic language, abstract functorial packaging, or ambitious logarithm recovery statements unless they are already immediate from imported lemmas.
- Remove any unrelated trailing declarations.
- No `sorry`, no placeholders, no incomplete declarations.

Required contents:

1. Define
```lean
structure MaxPlusDepthSystem (α : Type*) where
  comp : α → α → α
  depth : α → Nat
  depth_comp_le : ∀ f g, depth (comp f g) ≤ max (depth f) (depth g) + 1
```

2. In its namespace, define
```lean
shadow (S : MaxPlusDepthSystem α) (b : Nat) (f : α) : Nat := b ^ S.depth f
iter (S : MaxPlusDepthSystem α) : Nat → α → α
| 0, f => f
| n+1, f => S.comp (iter n f) f
```
and prove the simp lemma
```lean
iter_succ
```
for the recursive equation.

3. Prove the arithmetic support lemmas you actually need, preferably in the most robust form for `Nat`:
- `pow_le_pow_of_le` with assumptions `a ≤ b` and exponent monotonicity conditions needed by `Nat.pow_le_pow_right`
- `pow_max_eq_max_pow` for naturals under hypothesis `1 ≤ b`

If a standard Mathlib lemma already exists, use it instead of reproving a duplicate.

4. Prove the main bridge theorem
```lean
shadow_comp_le
```
with statement essentially
```lean
1 ≤ b →
S.shadow b (S.comp f g) ≤ b * max (S.shadow b f) (S.shadow b g)
```
The proof strategy should be:
- apply `Nat.pow_le_pow_right` to `S.depth_comp_le f g`
- rewrite `b ^ (max ... + 1)` as `b * b ^ max ...`
- rewrite `b ^ max ...` as `max (b ^ depth f) (b ^ depth g)` using `pow_max_eq_max_pow`

5. Prove the iteration depth bound
```lean
depth_iter_succ_le : S.depth (S.iter n f) ≤ S.depth f + n
```
(or equivalent indexing convention matching your `iter` definition).
Do this by induction on `n`, using the inequality
`max (S.depth (S.iter n f)) (S.depth f) ≤ S.depth f + n` after rewriting with the induction hypothesis.
Be careful with the exact successor arithmetic; choose the cleanest final statement that compiles.

6. Deduce the multiplicative iterate bound
```lean
shadow_iter_le : 1 ≤ b → S.shadow b (S.iter n f) ≤ b ^ n * S.shadow b f
```
from `depth_iter_succ_le` by monotonicity of `Nat.pow` and exponent arithmetic.

7. Add one concrete adapter from the valuation-depth catalog. Use the existing notion already available in `Computation/PadicValuationDepth` (or the exact imported file name if different in the current tree) to build a `MaxPlusDepthSystem` on endomorphisms. Then state and prove one instantiated corollary, e.g. the specialized `shadow_comp_le` for valuation depth under ordinary function composition.

Important guidance:
- Prefer catalog results in `Catalog/FINAL/` if there is a finalized valuation-depth file there; otherwise use the actual existing source that provides the composition-depth inequality.
- If the exact theorem names in the valuation-depth file differ, adapt to the local API rather than forcing the names from the failed attempt.
- Do not include `log_shadow` unless there is already a direct, easy lemma making it trivial. The goal is a complete file, not maximal ambition.
- Keep theorem names stable and descriptive so this file can serve as a reusable bridge.

Expected output:
- A complete Lean file that compiles.
- The file should contain only the structure, definitions, six core lemmas/theorems above (with `log_shadow` omitted unless trivial), and the ultrametric/valuation-depth adapter.

The key insight is that the additive tropical inequality `depth(comp f g) ≤ max(depth f, depth g) + 1` can be turned into a multiplicative Lipschitz-style estimate simply by exponentiating with base `b ≥ 1`, and this remains stable under iteration. Why now? The previous attempt already identified the right theorem package, and the remaining work is a focused cleanup using standard `Nat` arithmetic plus one existing valuation-depth composition theorem from the catalog.