Create a clean standalone Lean 4 file formalizing the finite-dimensional linear-algebra core for rank profiles of iterated endomorphisms, and stop at the strongest results that can be completed entirely from existing Mathlib lemmas.

Target file: `Catalog/LinearAlgebra/MetricFiltrationRankProfilesCore.lean`

Mathematical setup:
- Work over variables `{K V : Type*}` with `[Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]`.
- Let `T : ℕ → (V →ₗ[K] V)` be a sequence of endomorphisms of one fixed finite-dimensional vector space.

Required contents:
1. Define `transEndo T i k : V →ₗ[K] V` as the composition of the `k` consecutive maps starting at `i`, with `transEndo T i 0 = LinearMap.id` and recursive step chosen so that the clean additive composition theorem below is easy to prove.
2. Define `rankEndo T i k : ℕ := Module.finrank K (LinearMap.range (transEndo T i k))`.
3. Prove basic simp lemmas for `transEndo`, including the zero case and one-step case if useful.
4. Prove the concatenation law
   `transEndo_add : transEndo T i (k + l) = (transEndo T (i + k) l).comp (transEndo T i k)`.
5. Using existing Mathlib rank/range lemmas for composition, prove the two separate inequalities
   - `rankEndo_le_left : rankEndo T i (k + l) ≤ rankEndo T i k`
   - `rankEndo_le_right : rankEndo T i (k + l) ≤ rankEndo T (i + k) l`
   with proofs that directly rewrite via `transEndo_add` and apply library lemmas such as `finrank_range_comp_le_left` / `finrank_range_comp_le_right` if those exact names exist, or the current equivalent lemmas in Mathlib.
6. Deduce
   `rankEndo_submult : rankEndo T i (k + l) ≤ min (rankEndo T i k) (rankEndo T (i + k) l)`.

Important constraints:
- Do NOT include unrelated experiments or Fibonacci material.
- Do NOT leave declarations without proofs.
- Do NOT attempt to prove a new general Sylvester/Frobenius inequality from first principles in this cycle.
- If a lower-bound theorem analogous to Sylvester is already present in Mathlib under a usable name, you may add one final theorem reusing it; otherwise omit that part entirely.
- Prefer theorem names and proof structure that align with existing Mathlib APIs rather than forcing a bespoke statement.
- The result should compile as a small reusable core file in `Catalog/LinearAlgebra/`.

Suggested proof strategy:
- Define `transEndo` recursively on `k`; usually a recursion where the successor appends `T (i+k)` on the left makes `transEndo_add` natural.
- Prove `transEndo_add` by induction on `l` or `k`, whichever best matches the recursive definition.
- For rank inequalities, unfold `rankEndo`, rewrite with `transEndo_add`, and apply the existing finite-dimensional inequality for the range of a composition.
- Keep the API minimal and robust.

Deliver only a finished formalization-quality file with complete proofs.