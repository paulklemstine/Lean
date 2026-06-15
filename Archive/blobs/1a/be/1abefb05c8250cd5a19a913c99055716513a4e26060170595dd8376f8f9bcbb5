Develop one self-contained Lean 4 file formalizing valuation profiles for generating functions and proving the core lax-monoidal inequalities. Do not include unrelated material. The goal is a finished formalization, not a sketch.

Problem focus:
Formalize the map from coefficient sequences to tropical valuation profiles. Let coefficients live in a type K carrying enough algebraic structure to state an additive valuation v : K → WithTop ℤ satisfying at least:
- v 0 = ⊤
- v (a * b) = v a + v b
- v (a + b) ≥ min (v a) (v b)
Optionally include a hypothesis controlling natural-number scalars, e.g. v (n : K) ≥ 0 or a specialized lemma for Nat.choose.

Definitions to implement:
1. A type of sequences `Seq K := ℕ → K`.
2. Pointwise addition on sequences.
3. The binomial/Day convolution
   `(f ⋆ g) n = ∑ k in Finset.range (n+1), (Nat.choose n k : K) * f k * g (n-k)`.
4. The valuation profile
   `vprofile (f : Seq K) : ℕ → WithTop ℤ := fun n => v (f n)`.

Main theorems to prove completely:
A. `vprofile_add_ge`:
   for all f g n,
   `min ((vprofile f) n) ((vprofile g) n) ≤ (vprofile (f + g)) n`
   or equivalently the valuation-form inequality in your chosen order convention.

B. A finite-sum lower bound lemma for valuations:
   if every term of a finite sum has valuation at least α, then the whole sum has valuation at least α.
   This should be proved cleanly and then reused.

C. `vprofile_binConv_ge`:
   for all f g n and each k ≤ n,
   `vprofile (f ⋆ g) n ≥ v (Nat.choose n k : K) + (vprofile f k) + (vprofile g (n-k))`,
   or a packaged infimum/min-lower-bound statement over all k in `Finset.range (n+1)`.
   The proof should expand the convolution, apply the finite-sum lower bound, and use multiplicativity of v.

D. Corollary `vprofile_binConv_ge_simple`:
   under an extra assumption that `v (Nat.choose n k : K) ≥ 0`, deduce
   `vprofile (f ⋆ g) n ≥ (vprofile f k) + (vprofile g (n-k))`
   for each k ≤ n, or the corresponding infimum statement.

E. Package the result as a lax monoidal statement in preorder form: coefficientwise, `vprofile` sends addition to a lower bound by tropical `min`, and convolution to a lower bound by tropical convolution. Keep this theorem precise and minimal.

Implementation guidance:
- Prefer a small bespoke structure/class for the valuation axioms actually needed, rather than importing a large abstract valuation hierarchy if that complicates the proof.
- Use `WithTop ℤ` consistently for codomain values.
- Keep theorem statements aligned with what Lean can prove cleanly for finite sums over `Finset.range (n+1)`.
- If the fully general scalar lemma for `Nat.choose` is awkward, parameterize the convolution theorem by a hypothesis giving the needed lower bound on each scalar coefficient.
- The file must compile and contain complete proofs, with one coherent narrative.

What to avoid:
- No contingency-table, Markov basis, or unrelated algebraic-statistics material.
- No incomplete theorem headers, placeholders, or mixed fragments from earlier experiments.
- No broad narrative claims unsupported by the code.

Expected deliverable:
A single coherent file whose main mathematical contribution is the formal theorem that valuation profiles define a lax monoidal map from the sequence algebra with binomial convolution to tropical valuation profiles, expressed as explicit coefficientwise inequalities.