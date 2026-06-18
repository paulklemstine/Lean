            ## Research Task: Tropical p-adic Valuation Bounds and Lifting-the-Exponent for Fibonacci Primitive Divisors

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
            Close the open sorry `fib_composite_has_primitive` by formalizing the Lifting-the-Exponent (LTE) lemma for the Fibonacci sequence at odd prime indices and applying it to prove that every composite-index Fibonacci number F_n (with n > 12) possesses a primitive prime divisor. The proof strategy combines: (1) entry point theory (z(p) dividing n iff p | F_n), (2) tropical p-adic valuation calculus (v_p satisfies the min-plus ultrametric inequality), and (3) growth bounds showing F_n strictly exceeds the product of all Fibonacci numbers indexed by proper divisors of n. This resolves the Carmichael composite case beyond the verified computational range n ∈ [13,10000] and completes the formal proof of Carmichael's theorem on primitive divisors.

            ### Precise Mathematical Framing
            Carmichael's theorem states that every Fibonacci number F_n with n ≠ 1, 2, 6, 12 has a primitive prime divisor. The remaining formalization gap is the composite-index case for n > 10000, which cannot be settled by native_decide alone. The proof proceeds by establishing a Fibonacci-specific LTE lemma: for an odd prime p dividing F_k, the p-adic valuation obeys v_p(F_{nk}) = v_p(F_k) + v_p(n) when p does not divide n. Because the p-adic valuation v_p is a tropical semiring homomorphism (satisfying v_p(a+b) ≥ min(v_p(a), v_p(b))), this bridges tropical convexity with number-theoretic divisibility. Together with the entry point bound z(p) ≤ p + 1 and the growth estimate log(F_n) = Θ(n), one shows that the prime factors of proper divisors of n cannot exhaust the prime support of F_n, forcing a primitive divisor. This connects the verified tropical semiring infrastructure, the Algebra-EML valuation bridge, and classical Lucas sequence theory.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `prime_gap_72_all_composite` : theorem prime_gap_72_all_composite :
     (file: Algebra/Factoring/NewTheoremsV16.lean)
  2. `min_divisor_bound` : theorem min_divisor_bound (n : ℕ) (hn : 1 < n) (hc : ¬ Nat.Prime n) :
     (file: Algebra/Factoring/BridgeTheorems.lean)
  3. `divisor_gap_theorem` : theorem divisor_gap_theorem (d e : ℤ) :
     (file: Algebra/Factoring/FactoringViaBerggren.lean)
  4. `euclid_sum_bounds_product` : theorem euclid_sum_bounds_product (m n : ℤ) (hm : 0 < m) (hn : 0 < n) (hmn : n < m) :
     (file: Algebra/IntegerEnergy/OpenProblems.lean)
  5. `tropical_valuation_additive` : theorem tropical_valuation_additive (p a b : ℕ) (hp : Nat.Prime p)
     (file: Algebra/Algebra/OpenDirections.lean)

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



Recent successful concepts: Tropical Certified Robustness for Multi-Class ReLU Networks, Lifting-the-Exponent Lemma for Fibonacci and Primitive Prime Divisors of Composite-Index Fibonacci Numbers, Tropical Satake Isomorphism for GL₄ via Min-Plus Hecke Algebra and Tropical Schur Basis


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

Research domain: Algebra
Research mode: sorry_fill
