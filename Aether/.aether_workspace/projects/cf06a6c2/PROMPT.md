            ## Research Task: Carmichael's Theorem Composite Case via Fibonacci Lifting-the-Exponent

            Research Mode: SORRY_FILL

You are given Lean 4 files that contain `sorry` placeholders.
Your task is CRITICALLY IMPORTANT: fill ALL `sorry` placeholders
with complete, rigorous proofs. This closes known open problems.

Strategy:
1. READ the surrounding context — theorem statements and imports are hints
2. DO NOT change theorem statements — only fill the `sorry`
3. Break hard proofs into helper lemmas first
4. A proof with fewer sorries is better than one that doesn't compile


            ### Research Direction
            Close the remaining sorry in Speculative/AutoResearch/CarmichaelComposite.lean by proving that every composite-index Fibonacci number F_n (n > 12) admits a primitive prime divisor. The proof strategy synthesizes a Fibonacci-specific lifting-the-exponent lemma with entry point divisibility theory and exponential growth bounds to handle composite indices beyond the native_decide range [13, 10000].

            ### Precise Mathematical Framing
            Prove that for all composite n > 12, there exists a prime p dividing F_n such that p does not divide F_k for any k < n. Establish a Fibonacci LTE lemma giving ν_p(F_{mn}) = ν_p(F_m) + ν_p(n) when p | F_m and p ∤ m, then apply entry point factorization (fibEntryPt_dvd_of_fib_dvd) to show that non-primitive divisors exhaust only a proper subset of prime factors, forcing the existence of a primitive divisor via the exponential lower bound fib_exp_bound and the entry-point positivity lemma fibEntryPt_pos.

            ### Lean 4 Sketch
Speculative/AutoResearch/CarmichaelComposite.lean

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `entry_point_divides` : lemma entry_point_divides (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n)
     (file: Speculative/AutoResearch/CarmichaelComputational.lean)
  2. `non_primitive_to_proper_divisor` : lemma non_primitive_to_proper_divisor (p n : ℕ) (_hp : Nat.Prime p)
     (file: Speculative/AutoResearch/CarmichaelPrimitiveDivisor.lean)
  3. `fib_primitive_divisor_existence` : theorem fib_primitive_divisor_existence :
     (file: Speculative/AutoResearch/Fib_gcd_identity.lean)
  4. `prime_or_composite` : theorem prime_or_composite (n : ℕ) (hn : n > 1) :
     (file: Speculative/AutoResearch/NonArchimedeanFactoring.lean)
  5. `prime_has_divisor_one` : theorem prime_has_divisor_one (p : ℕ) (_hp : Nat.Prime p) :
     (file: Speculative/AutoResearch/QuantumE8ModularForms.lean)

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
            Fill existing `sorry` placeholders — do not change theorem statements.

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
Research mode: sorry_fill
