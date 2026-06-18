            ## Research Task: Surjectivity of the Tropical Satake Transform for GL₂

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)


            ### Research Direction
            Complete the tropical Satake isomorphism for GL₂ by proving the tropical Satake transform is surjective onto the ring of Weyl-invariant tropical polynomials. Constructively exhibit the tropical Schur polynomials as the images of min-plus Hecke basis operators, establishing a bijection between the tropical Hecke algebra and the W-invariant tropical coordinate ring.

            ### Precise Mathematical Framing
            Build on the 22-theorem tropical Hecke algebra formalization for GL₂ and the existing injectivity result for the tropical Satake transform. Prove surjectivity by showing that tropical Schur polynomials generate the full ring of W-invariant tropical polynomials under min-plus addition and tropical multiplication, and that each Schur polynomial is the transform of an explicit Hecke operator. Use a Bruhat-order descent on the coweight lattice to reduce general W-invariant piecewise-linear functions to the Schur basis, then lift via the tropical Hecke algebra multiplication table already verified for GL₂.

            ### Lean 4 Sketch
theorem tropicalSatakeSurjective_GL2 {f : TropicalPolynomial (Coweight (ReflectionGroup GL₂))} (hf : IsWeylInvariant f) : ∃ h : TropicalHecke GL₂, tropicalSatakeTransform h = f

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_min_idem` : theorem tropical_min_idem (a : ℝ) : min a a = a := min_self a
     (file: Speculative/Other/NewTheorems.lean)
  2. `the_forbidden_theorem` : theorem the_forbidden_theorem (f : α → α → Prop) :
     (file: Speculative/Forbidden/TheForbiddenTheorem.lean)
  3. `tropical_satake_isomorphism_GL3` : theorem tropical_satake_isomorphism_GL3 :
     (file: Tropical/Langlands/TropicalSatakeGL3.lean)
  4. `tropical_schur_GL2_invariant` : theorem tropical_schur_GL2_invariant
     (file: Tropical/TraceFormula/ArthurSelbergGL2.lean)
  5. `tropical_satake_isomorphism_GL4` : theorem tropical_satake_isomorphism_GL4
     (file: Tropical/Tropical_Satake_Isomorphism_for_GL₄_via_Min_Plus_Hecke_Algebra_and_Tropical_Schur_Basis.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT




            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - A Scientific American style discussion section
               - Detailed proofs and explanations

            3. **FUTURE_DIRECTIONS.md** — YOUR recommendations for what to research next
               - Specific theorems or conjectures worth pursuing
               - Which existing catalog results could be extended and how
               - Cross-domain connections you noticed during this research
               - Open problems you encountered but couldn't solve
               - This report will guide the next research cycle

            4. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            5. **diagram.svg** — visualization of key mathematical structures

            The mathematics comes FIRST. Excellent proofs trump everything else.
            Produce novel, non-trivial theorems with complete Lean 4 proofs.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Speculative
Research mode: prove
