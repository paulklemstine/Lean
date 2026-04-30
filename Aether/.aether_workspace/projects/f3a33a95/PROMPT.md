            ## Research Task: Tropical Satake Isomorphism for GL₃

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
            Prove that the tropical spherical Hecke algebra H_trop(GL₃(F)//GL₃(O)) is isomorphic to the tropical representation ring of the Langlands dual group GL₃ via an explicit tropical Satake transform. The theorem identifies tropical Hecke operator eigenvalues on the Bruhat-Tits building of GL₃ with tropical Schur polynomials in the spectral coordinates, extending the project's verified GL₂ tropical Satake result to rank two.

            ### Precise Mathematical Framing
            For a non-archimedean local field F with ring of integers O, the spherical Hecke algebra H(GL₃(F)//GL₃(O)) has a basis indexed by dominant coweights λ ∈ X_+(T). We introduce the tropical Hecke algebra H_trop where convolution becomes tropical integration (min-plus convolution). The tropical Satake transform S_trop: H_trop → ℂ[Trop(ˇA/W)] sends each basis element T_λ to the tropical Schur polynomial s_λ^{trop}(x₁,x₂,x₃) = min_{σ∈S₃} ⟨λ+ρ, σ(x)⟩. We prove S_trop is a semiring isomorphism between H_trop and the tropical invariant ring, matching tropical orbital integrals on the geometric side to tropical characters on the spectral side. The proof strategy builds on the verified GL₂ tropical Satake base case and extends via tropical Gindikin-Karpelevich recursion on the affine flag variety for GL₃.

            ### Lean 4 Sketch
Tropical/Langlands/TropicalSatakeGL3.lean

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `spectral_tropical_bound` : theorem spectral_tropical_bound (a b c d : ℝ) :
     (file: Tropical/Bridges/SpectralIdempotentBridge.lean)
  2. `toeplitz_tropical_rank_bound` : theorem toeplitz_tropical_rank_bound (n : ℕ) (hn : 1 ≤ n) :
     (file: Tropical/Core/FiveFrontiers.lean)
  3. `tropical_spectral_bound` : theorem tropical_spectral_bound {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
     (file: Tropical/Core/TropicalDeepResearch.lean)
  4. `tropical_fundamental_theorem_of_arithmetic` : theorem tropical_fundamental_theorem_of_arithmetic {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
     (file: Tropical/Core/TropicalFactoring.lean)
  5. `tropical_mirror_theorem` : theorem tropical_mirror_theorem (a : ℝ) : max a a = a := max_self a
     (file: Tropical/Langlands/AlgebraicMirror.lean)

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

Research domain: Tropical
Research mode: prove
