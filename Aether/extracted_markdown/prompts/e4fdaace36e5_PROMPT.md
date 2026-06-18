Formalize a self-contained Lean 4 development around the threshold-profile valuation on finite binary vectors and linear codes, using the partial `CodeThresholdValuation` idea but stripping away unrelated claims and any Mandelbrot motivation.

Target file: `Catalog/Speculative/AutoResearch/CodeThresholdValuation.lean`.

Primary task: define and prove a concrete nonarchimedean valuation theory for binary words `Fin n → ZMod 2`, then package it categorically.

Required mathematical content:

1. Define `support : (Fin n → ZMod 2) → Finset (Fin n)` in whatever way is most convenient from Mathlib, and define
   `tprof : (Fin n → ZMod 2) → ℕ`
   so that `tprof x` is the least threshold `t` with every nonzero coordinate of `x` lying in positions `< t`. It is acceptable to implement this equivalently as the supremum/max of the support plus 1, with the convention `tprof 0 = 0`.

2. Prove the core valuation theorems:
   - `tprof_zero : tprof 0 = 0`
   - `tprof_eq_zero_iff : tprof x = 0 ↔ x = 0`
   - `tprof_add_le : tprof (x + y) ≤ max (tprof x) (tprof y)`
   - `tprof_add_eq_of_ne : tprof x ≠ tprof y → tprof (x + y) = max (tprof x) (tprof y)`
   The last theorem should be the sharp ultrametric/isoceles law. If the exact formulation is awkward, a pair of inequalities implying equality is fine.

3. Prove a few basic comparison lemmas that are genuinely useful and easy to verify, such as:
   - `tprof_le_length : tprof x ≤ n`
   - `mem_support_lt_tprof : i ∈ support x → (i : ℕ) < tprof x`
   - optionally `wt_le_tprof` if Hamming weight is already available cleanly; otherwise omit it rather than introducing unnecessary overhead.

4. Define a structure of threshold-valued code objects. Keep this minimal and robust. For example, an object can be a submodule/code `C ≤ (Fin n → ZMod 2)` together with the inherited `tprof`, or simply the ambient space if submodule packaging becomes cumbersome. The key is to define morphisms as linear maps that are nonexpansive for `tprof`:
   `tprof (f x) ≤ tprof x`.
   Then prove identity and composition laws.

5. If the catalog contains a suitable ultrametric/tropical object interface, construct a functor into it. If that interface is too heavy or brittle, weaken the goal: define your own lightweight category/structure of additive ultrametric objects and give the functor there. The emphasis is on a complete, correct formal bridge, not on forcing compatibility with a difficult API.

6. Keep the file tightly scoped. Do not include unrelated theorem statements, copied notes, or speculative claims. Every declaration in the file should support the valuation theory or the categorical packaging.

Proof strategy:
- Realize `tprof` through the maximum support index plus one; this makes the support lemmas and ultrametric inequality natural.
- For `tprof_add_le`, use that over `ZMod 2`, a coordinate of `x+y` can only be nonzero if at least one of the corresponding coordinates of `x` or `y` is nonzero, so the support of `x+y` is contained in `support x ∪ support y`.
- For `tprof_add_eq_of_ne`, show that if one profile is strictly larger, then the top active coordinate of the larger-profile vector cannot be canceled by the smaller-profile vector because the latter has no support that high.
- Prefer elementary finset/`Fin n` arguments over abstract machinery.

Deliverable standard:
- One compilable Lean file.
- Sorry-free.
- Clear theorem names and comments.
- If a stronger categorical functor is infeasible, provide the full valuation theory plus a smaller functorial packaging that compiles cleanly.

This is a formalization project, not an exploratory research essay. The result should be a precise, verified bridge from binary codewords to a nonarchimedean/tropical-style valuation framework.