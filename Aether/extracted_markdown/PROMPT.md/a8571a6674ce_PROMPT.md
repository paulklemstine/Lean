Create a complete Lean 4 file formalizing the finite-dimensional linear-algebraic rank-profile core for iterated endomorphisms.

Target file: `Catalog/LinearAlgebra/MetricFiltrationRankProfilesCore.lean`

Requirements:
1. Work over variables
   `variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]`
2. Define
   - `transEndo (T : ℕ → (V →ₗ[K] V)) (i : ℕ) : ℕ → (V →ₗ[K] V)` by recursion,
   - `rankEndo (T : ℕ → (V →ₗ[K] V)) (i k : ℕ) : ℕ := FiniteDimensional.finrank K (LinearMap.range (transEndo T i k))`.
3. Prove the basic recursion lemmas `transEndo_zero`, `transEndo_succ` and the key concatenation identity
   `transEndo_add (T : ℕ → (V →ₗ[K] V)) (i k l : ℕ) :
      transEndo T i (k + l) = (transEndo T (i + k) l).comp (transEndo T i k)`.
4. Prove the upper rank bound
   `rankEndo_submult (T : ℕ → (V →ₗ[K] V)) (i k l : ℕ) :
      rankEndo T i (k + l) ≤ min (rankEndo T i k) (rankEndo T (i + k) l)`
   using `transEndo_add` plus existing Mathlib lemmas such as `finrank_range_comp_le_left` and `finrank_range_comp_le_right` (or the exact available names).
5. Complete the previously missing main theorem:
   `rankEndo_sylvester (T : ℕ → (V →ₗ[K] V)) (i k l : ℕ) :
      rankEndo T i k + rankEndo T (i + k) l ≤ rankEndo T i (k + l) + FiniteDimensional.finrank K V`.
   Proof strategy: rewrite `rankEndo T i (k+l)` using `transEndo_add`, then apply an existing finite-dimensional Sylvester/Frobenius rank inequality for linear maps if available in Mathlib. If the exact theorem name differs, search Mathlib for lemmas about `finrank (range (g.comp f))` bounded below by `finrank (range f) + finrank (range g) - finrank V`, or an equivalent rearranged inequality. Use the library theorem directly rather than leaving a gap.
6. Keep the file self-contained, compiling, and free of `sorry`.
7. Include a short module docstring explaining that this is a reusable algebraic core for later filtration applications, but do not import or mention tropical geometry in the theorem statements.

Important guidance:
- Prefer the exact theorem names already in Mathlib; do not reprove generic rank inequalities from scratch unless absolutely necessary.
- If a theorem uses a different codomain/domain notation, specialize it carefully to endomorphisms of `V`.
- Use `Catalog/FINAL/` results only if genuinely relevant, but this task should mostly rely on Mathlib linear algebra.
- The objective is a robust, minimal core file that typechecks end-to-end.