Develop a complete Lean 4 file formalizing a geometric theory of unstoppable self-maps, but keep the scope tight and fully proved. Do not discuss Turing completeness, self-modifying code, or relative hardness of halting problems unless they are encoded as precise theorems already available in mathlib; instead, interpret the theme through deterministic dynamics.

Create a file `Catalog/Geometry/Unstoppable.lean` with the following structure.

1. Basic definitions for a self-map `f : X → X`:
   - `HaltsAt (f : X → X) (x : X) : Prop` meaning the forward orbit repeats, e.g. `∃ m < n, (f^[m]) x = (f^[n]) x`.
   - `PeriodicPoint (f : X → X) (x : X) : Prop` if useful as an equivalent notion.
   - `Unstoppable (f : X → X) : Prop` meaning every orbit is injective, equivalently no `x` satisfies `HaltsAt f x`.
   Prove the elementary equivalences carefully and keep the API minimal.

2. Main no-return criteria:
   - A strict-monotonicity theorem: if `φ : X → α` into a linear order satisfies `φ (f x) > φ x` for all `x`, then `f` has no periodic points / is unstoppable.
   - A constant-drift theorem over an additive ordered type: if `φ (f x) = φ x + c` for all `x` with `0 < c`, then `f` is unstoppable.
   - An orbit injectivity theorem under drift: prove `(fun n => (f^[n]) x)` is injective for every `x`.
   Prefer the cleanest typeclass assumptions that make the proof straightforward; specializing to `ℤ` or `ℝ` is acceptable if a more abstract statement becomes fragile.

3. Iteration lemmas:
   - Show that under a drift hypothesis with increment `c`, the `k`-th iterate has drift `k • c` (or the corresponding natural multiple), and deduce unstoppability of positive iterates.
   - If easier, prove this first for `ℤ`/`ℝ` targets.

4. Concrete geometric examples:
   - Translation on `ℤ`: `x ↦ x + a` is unstoppable when `a ≠ 0`.
   - Translation on `ℝ`: `x ↦ x + a` is unstoppable when `a > 0`, and optionally handle `a < 0` by using `-x` as the drift coordinate.
   - Translation on `ℝ × ℝ`: `(x,y) ↦ (x+1,y)` is unstoppable.
   - Glide reflection on `ℝ × ℝ`: `(x,y) ↦ (x+1,-y)` is unstoppable, using projection to the first coordinate as the escaping coordinate.
   Keep these examples elementary; avoid inner-product-space generality unless it is genuinely easy and already supported by the previous lemmas.

5. Finite-space obstruction:
   - Prove that if `X` is finite, then no self-map `f : X → X` is unstoppable. Equivalently, every orbit eventually repeats.
   This gives a clean contrast with the geometric examples.

Implementation guidance:
- Produce complete theorem statements and proofs only; no placeholders, no interrupted definitions, no `sorry`.
- Keep the file coherent and self-contained.
- Favor simple concrete targets (`ℤ`, `ℝ`, `ℝ × ℝ`) over ambitious abstraction.
- If there is any risk that a definition of `Unstoppable` via comments or notation becomes brittle, define it directly as orbit injectivity.
- Include short module documentation explaining the dynamical interpretation.

The goal is a robust formalization of a no-return/drift principle in dynamics, with geometric examples, not a speculative computability essay.