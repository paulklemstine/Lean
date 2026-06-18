You are repairing a failed partial attempt. Ignore the previous off-topic file entirely and create one new Lean file focused only on a minimal tropical foundation.

Target domain: Tropical / real-valued max-plus polynomial evaluation.

Deliverable:
- One self-contained Lean file, with no `sorry`, no declaration stubs, and no unrelated imports beyond what is needed from Mathlib.
- The file should compile on its own.

Mathematical scope:
Fix `n : ℕ` and coefficients `a : Fin (n+1) → ℝ`.
Define
- `piece (a : Fin (n+1) → ℝ) (i : Fin (n+1)) (x : ℝ) : ℝ := a i + (i : ℝ) * x`
- `tropPolyFun (a : Fin (n+1) → ℝ) (x : ℝ) : ℝ := Finset.sup Finset.univ (fun i => piece a i x)`

Because `Finset.sup` on `ℝ` needs order-theoretic support, choose the cleanest Mathlib-compatible formulation. If necessary, use the variant of `Finset.sup` requiring `[SemilatticeSup]` and a nonempty witness, or replace the definition with an equivalent finite-max construction that is easier to prove with. The goal is a clean, fully proved file, not adherence to a fragile exact encoding.

Required theorems:
1. Pointwise characterization:
   Prove a theorem unfolding `tropPolyFun` into the finite supremum/max of the affine pieces.
   This can be a simp-style theorem if the definition already unfolds directly.

2. Attainment:
   Prove that for every `x`, there exists `i : Fin (n+1)` such that
   `tropPolyFun a x = piece a i x`.
   Use finiteness of `Fin (n+1)` and a finite maximum/sup attainment lemma.

3. Coefficientwise monotonicity:
   If `h : ∀ i, a i ≤ b i`, prove
   `tropPolyFun a x ≤ tropPolyFun b x` for every `x`.
   This is the correct monotonicity statement to formalize. Do not attempt monotonicity in `x` unless you additionally impose and use hypotheses that make it true.

4. Convexity / Jensen inequality:
   Prove that for `0 ≤ t` and `t ≤ 1`,
   `tropPolyFun a (t*x + (1-t)*y) ≤ t * tropPolyFun a x + (1-t) * tropPolyFun a y`.
   Recommended proof strategy: first prove the affine identity for each piece,
   `piece a i (t*x + (1-t)*y) = t * piece a i x + (1-t) * piece a i y`,
   then bound each `piece a i x ≤ tropPolyFun a x` and `piece a i y ≤ tropPolyFun a y`, multiply by nonnegative scalars, add, and finally take the supremum/max over `i`.

Important correction to the earlier concept:
- The originally requested “monotonicity” is ambiguous and, as a function of `x`, false in general for arbitrary tropical polynomials because different affine pieces can have different slopes and coefficients. Therefore formalize coefficientwise monotonicity instead.
- If you want, you may add a short comment in the file explaining this choice, but do not expand the scope.

Implementation guidance:
- Prefer a very small number of lemmas with robust names.
- Use `Finset.mem_univ`, `Finset.le_sup`, `Finset.sup_le`, or analogous max lemmas depending on the chosen definition.
- If `Finset.sup` over `ℝ` becomes awkward, it is acceptable to define `tropPolyFun a x` via `Finset.max'` applied to the image/value set, as long as the required theorems are proved cleanly.
- Keep all notation explicit and avoid building new abstractions.
- No unrelated domains, no generalized semiring setup, no extra API beyond this file’s needs.

What success looks like:
A concise file that compiles and contains complete proofs of the four items above, establishing a trustworthy formal base for general-degree max-plus tropical polynomial evaluation on `ℝ`.