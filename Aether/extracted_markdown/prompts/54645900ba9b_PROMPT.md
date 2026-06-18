            ## Research Task: Berggren-Lorentz Quantum Gates via Tropical Light-Cone Dynamics

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
            Prove that the three Berggren matrices generate a discrete subgroup of SO(2,1;Z) preserving the Lorentz form a²+b²-c², and that their tropicalization yields piecewise-linear dynamics on the max-plus light cone whose periodic orbits correspond to primitive Pythagorean triples. Establish the quantum circuit representation of these matrices as unitary gates on the Bloch sphere via the Stereographic Pythagorean Bridge.

            ### Precise Mathematical Framing
            Formalize the Berggren matrices B₁,B₂,B₃ (already declared in the catalog) as elements of SL(3,Z) acting on the cone C = {(a,b,c)∈Z³_{>0} : a²+b²=c²}. Prove that each Bᵢ satisfies Bᵢ^T Λ Bᵢ = Λ where Λ = diag(1,1,-1), giving an explicit embedding of the Berggren tree into the isometry group of Minkowski space R^{2,1}. Next, tropicalize the action via Maslov dequantization: replace matrix multiplication by min-plus matrix product (A ⊙ v)_j = min_k (A_{jk} + v_k), where entries of Aᵢ are derived from Bᵢ. Prove that the tropical fixed-point equation v = Bᵢ^trop ⊙ v has as its finite solutions exactly the log-coordinates of primitive Pythagorean triples. Finally, push the Berggren action forward to the circle S¹ via the SPB map (a/c, b/c) ↦ e^{iθ} and prove that the induced operators U(Bᵢ) = exp(i θᵢ σ_z) constitute a unitary representation on a single qubit, yielding a Pythagorean-parameterized universal quantum gate set.

            ### Lean 4 Sketch
TropicalBerggrenAnalysis.lean

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `berggren_word_lorentz` : theorem berggren_word_lorentz (word : List (Matrix (Fin 3) (Fin 3) ℤ))
     (file: Pythagorean/Berggren/BerggrenLorentzGroup.lean)
  2. `berggren_A_preserves_lorentz` : theorem berggren_A_preserves_lorentz :
     (file: Pythagorean/Berggren/TropicalPAdicBerggren.lean)
  3. `berggren_quantum_state` : theorem berggren_quantum_state {X : Type*} [Inhabited X] :
     (file: Pythagorean/Main.lean)
  4. `berggren_preserves_lorentz` : theorem berggren_preserves_lorentz (a b c : ℤ) :
     (file: Pythagorean/ThreeRoads/AdvancedTheorems.lean)
  5. `poincare_sphere_is_light_cone` : theorem poincare_sphere_is_light_cone (S₀ S₁ S₂ S₃ : ℝ) :
     (file: Algebra/DivisionAlgebras/Channel5Sedenions.lean)

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



Recent successful concepts: Primitive Prime Divisors for Composite Fibonacci Indices via Lifting-The-Exponent, Primitive Prime Divisors of Composite-Index Fibonacci Numbers via LTE and Entry Point Theory, algebra_physics_bridge_theorem


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

Research domain: Pythagorean
Research mode: prove
