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
            Extend the verified tropical Hecke algebra framework from GL₂ to GL₃ by proving that the min-plus convolution algebra on dominant coweights is isomorphic to the S₃-invariant tropical polynomial ring via the tropical Satake transform. This establishes the tropical Langlands correspondence for rank-2 general linear groups and opens the path to general GL_n through adjacent-transposition Weyl-group tactics rather than brute-force permutation enumeration.

            ### Precise Mathematical Framing
            Target theorem: The tropical Satake transform S_trop : H_trop(GL₃) → ℝ_max[Λ]^W is a min-plus algebra isomorphism, where H_trop is the compactly-supported min-plus convolution algebra on the affine Grassmannian Gr_GL₃ and ℝ_max[Λ]^W is the Weyl-group-invariant tropical polynomial ring on the coweight lattice. Proof strategy: (1) Formalize GL₃ tropical Hecke operators via min-plus matrix convolution over the tropicalized affine flag variety, avoiding explicit 6-fold S₃ case splits by proving Weyl invariance through adjacent transposition generators (s₁, s₂); (2) Construct tropical Schur polynomials for GL₃ dominant coweights (a,b,c) with a≥b≥c and prove they form a tropical basis of ℝ_max[Λ]^W; (3) Verify multiplicativity of S_trop by reducing the convolution of double-coset indicators to the tropical assignment problem on honeycombs / Berenstein-Zelevinsky triangles; (4) Prove strict convexity of the tropical Cartan decomposition Gr_GL₃ to obtain injectivity and surjectivity; (5) Connect to the existing Mathlib Tropical type and Finset-based universal constructions to handle the combinatorial explosion generically.

            ### Lean 4 Sketch
Tropical/Langlands/GL3Satake.lean with declarations tropicalSatakeTransformGL3, minPlusHeckeGL3_mul_comm, tropicalSchurGL3_basis, weylInvarianceAdjacentGenGL3, satakeMultTropicalGL3, tropicalCartanStrictConvexGL3, satakeBijectiveGL3

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `satake_extend_invariant` : theorem satake_extend_invariant (f : ℤ → ℤ → ℤ → α) :
     (file: Tropical/Langlands/TropicalSatakeGL3Algebra.lean)
  2. `tropical_satake_fundamental_coweights` : theorem tropical_satake_fundamental_coweights :
     (file: Tropical/TropicalSatake/Theorems.lean)
  3. `tropical_rank_bound` : theorem tropical_rank_bound (n m : ℕ) :
     (file: Tropical/Core/TropicalDeepResearch.lean)
  4. `tropical_and_bound` : theorem tropical_and_bound (c₁ c₂ : ℝ) (h₁ : 1 ≤ c₁) (h₂ : 1 ≤ c₂) :
     (file: Tropical/Oracles/OracleApplicationsFrontier.lean)
  5. `tropical_rank_le_dim` : theorem tropical_rank_le_dim (n : ℕ) (A : Fin n → Fin n → WithTop ℤ) :
     (file: Tropical/Core/HashInversion.lean)

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
            @Bridges/TropicalLanglands.lean
```lean
import Mathlib

/-! # CatalogBuild.Bridges.TropicalLanglands

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15
-/

noncomputable section

/-- Tree moves in the Berggren tree -/
inductive BerggrenMove
  | L  -- Apply M₁
  | M  -- Apply M₂
  | R  -- Apply M₃
  deriving DecidableEq, Repr

/-- A path in the Berggren tree -/
abbrev BerggrenPath := List BerggrenMove

/-- Apply a single Berggren move to a triple -/
def applyMove (m : BerggrenMove) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match m with
  | .L => (t.1 - 2*t.2.1 + 2*t.2.2,
           2*t.1 - t.2.1 + 2*t.2.2,
           2*t.1 - 2*t.2.1 + 3*t.2.2)
  | .M => (t.1 + 2*t.2.1 + 2*t.2.2,
           2*t.1 + t.2.1 + 2*t.2.2,
           2*t.1 + 2*t.2.1 + 3*t.2.2)
  | .R => (-t.1 + 2*t.2.1 + 2*t.2.2,
           -2*t.1 + t.2.1 + 2*t.2.2,
           -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- Apply a path (sequence of moves) to a triple -/
def applyPath (path : BerggrenPath) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  path.foldl (fun acc m => applyMove m acc) t

/-- Every move preserves the quadratic form a² + b² - c² -/
theorem applyMove_quad_form (m : BerggrenMove) (a b c : ℤ) :
    let t := applyMove m (a, b, c)
    t.1^2 + t.2.1^2 - t.2.2^2 = a^2 + b^2 - c^2 := by
  cases m <;> simp [applyMove] <;> ring

/-- Every move preserves the Pythagorean relation -/
theorem applyMove_preserves_pyth (m : BerggrenMove) (a b c : ℤ)
    (h : a^2 + b^2 = c^2) :
    let t := applyMove m (a, b, c)
    t.1^2 + t.2.1^2 = t.2.2^2 := by
  have := applyMove_quad_form m a b c
  omega

/-- The empty path is the identity -/
theorem applyPath_nil (t : ℤ × ℤ × ℤ) : applyPath [] t = t := rfl

/-- Concatenation of paths composes the actions -/
theorem applyPath_append (p q : BerggrenPath) (t : ℤ × ℤ × ℤ) :
    applyPath (p ++ q) t = applyPath q (applyPath p t) := by
  simp [applyPath, List.foldl_append]

/-- Under M₂, the hypotenuse strictly increases for positive triples -/
theorem move_M_hyp_increase (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (applyMove .M (a, b, c)).2.2 := by
  simp [applyMove]; linarith

/-- The root (3,4,5) children -/
theorem root_child_L : applyMove .L (3, 4, 5) = (5, 12, 13) := by decide

/-- [Section: # CatalogBuild.Bridges.TropicalLanglands
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15] -/
theorem root_child_M : applyMove .M (3, 4, 5) = (21, 20, 29) := by decide

/-- [Section: # CatalogBuild.Bridges.TropicalLanglands
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 15] -/
theorem root_child_R : applyMove .R (3, 4, 5) = (15, 8, 17) := by decide

/-- Grandchildren -/
theorem root_grandchild_LL :
    applyPath [.L, .L] (3, 4, 5) = (7, 24, 25) := by decide

theorem root_grandchild_LM :
    applyPath [.L, .M] (3, 4, 5) = (55, 48, 73) := by decide

theorem pyth_perimeter_even (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (hparity : (a % 2 = 0 ∧ b % 2 = 1) ∨ (a % 2 = 1 ∧ b % 2 = 0)) :
    2 ∣ (a + b + c) := by
  replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;

end

```


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
