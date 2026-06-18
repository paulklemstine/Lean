# Future Directions: Refined Ordinal Classification of EML Growth

## Synthesis

The refined ordinal classification establishes a two-dimensional address system ⟨k, d⟩ for EML expression growth rates, reaching ordinals below ω². This opens five natural research directions that collectively aim to (1) determine whether the classification is complete, (2) extend it to richer expression languages, and (3) connect it to deep structural questions in differential algebra and computational complexity. The directions form a coherent program: Conjectures 1–2 probe the boundaries of the current theory, Conjecture 3 extends it to logarithms, and Conjectures 4–5 connect to grand challenges in asymptotic algebra and complexity theory. Each direction builds on the formally verified theorems in `Catalog/Pythagorean/OrdinalClassification/RefinedRank.lean`.

---

## Direction 1: Completeness of the Refined Rank

**Conjecture:** If eval(e₁, x) / eval(e₂, x) → 0 as x → ∞ (with both positive for large x), then refinedExprRank(e₁) ≤ refinedExprRank(e₂).

**Test:** Search computationally for EML expressions e₁, e₂ where refinedExprRank(e₁) = refinedExprRank(e₂) but the ratio eval(e₁, x)/eval(e₂, x) → 0. Focus on expressions with the same rank ⟨k, d⟩ but different internal structure (e.g., exp(2x) vs exp(3x), both rank ⟨1, 0⟩). Enumerate all expressions up to size 8 and compute ratios at x = 100, 1000, 10000.

**Impact:** A positive answer would make the refined rank a *complete* invariant for the asymptotic ordering of EML expressions up to within-rank equivalence. A counterexample would precisely characterize the rank's blind spots, guiding the design of finer invariants.

**Catalog References:** `refinedExprRank` and structural theorems in `Catalog/Pythagorean/OrdinalClassification/RefinedRank.lean`; soundness theorem `refinedRank_soundness` in the same file.

**Proof Strategy:** If true, prove by structural induction on e₂, showing that any expression with domination over another must have at least as high a rank. The key difficulty is handling additive cancellation (where add(e₁, neg(e₂)) could have lower growth than either summand).

**Domain Bridges:** Hardy fields (Rosenlicht's growth comparison theorem), o-minimal theory (definable function growth bounds).

**Lineage:** Extends `refinedRank_soundness` from a soundness result to a soundness+completeness characterization.

**Ambition:** ★★★☆☆ — Solid extension. Expected to hold for "positive" expressions; likely false in general due to cancellation.

---

## Direction 2: Strict Ordering Within Blocks (Witness Existence)

**Conjecture:** For every k ≥ 0 and d₁ < d₂, there exist EML expressions e₁, e₂ with refinedExprRank(eᵢ) = ⟨k, dᵢ⟩ such that eval(e₁, x) / eval(e₂, x) → 0 as x → ∞.

**Test:** For k ∈ {0, 1, 2} and d₁ < d₂ ≤ 5, construct the canonical expressions x^{d₁}·iterExp(k,x) and x^{d₂}·iterExp(k,x) and verify the ratio converges to 0 numerically. Then formalize the proof that x^{d₂-d₁} → ∞ implies the ratio → 0.

**Impact:** Proves that the refined rank creates a *genuinely dense* stratification — every rank ⟨k, d⟩ is inhabited by expressions that are strictly separated from adjacent ranks. Without this, the rank might assign different labels to asymptotically equivalent expressions.

**Catalog References:** `iterExpExpr_rank`, `iterExpExpr_eval`, `iterExp_tendsto_atTop` in `RefinedRank.lean`.

**Proof Strategy:** For fixed k, the expressions x^{d₁}·iterExp(k,x) and x^{d₂}·iterExp(k,x) have ratio x^{d₁-d₂} → 0. Formalize using `Real.tendsto_exp_div_pow_atTop` from Mathlib and the iterated exponential divergence theorem.

**Domain Bridges:** Polynomial growth theory, real analysis (limits at infinity).

**Lineage:** Strengthens `mul_degree_additive_same_block` from a rank-computation fact to an analytic separation theorem.

**Ambition:** ★★☆☆☆ — Straightforward extension using existing Mathlib analysis.

---

## Direction 3: Logarithmic Extension to ω^ω

**Conjecture (Grand Challenge):** There exists a refined rank system ⟨k, d, l⟩ ∈ ℕ × ℕ × ℤ extending the current ⟨k, d⟩ with a logarithmic component l, classifying expressions in the language EML+log (adding log(e) to the grammar), reaching ordinals below ω^ω, with a sound ordering theorem.

**Test:** Define `logExprRank` for the extended language and verify soundness on test cases: log(x) should have rank below x; x·log(x) below x²; log(exp(x)) = x should have rank ⟨0, 1⟩. Check 50 randomly generated EML+log expressions of size ≤ 10 for rank consistency with numerical evaluation.

**Impact:** Would extend the classification from a 2-tier system (ω²) to a multi-tier system (ω^ω), capturing the full Levitz hierarchy of logarithmic-exponential functions. This is the natural next step in the ordinal analysis of growth rates.

**Catalog References:** `refinedExprRank`, `refinedRank_omegaCoeff_eq_emlDepth` in `RefinedRank.lean`; `HardyLevel'` in `Theorems.lean`.

**Proof Strategy:** Define the logarithmic component as a negative offset: log(x) has rank ⟨0, 1, -1⟩ (like x but "one log slower"). Composition with exp increments the exponential depth. The main difficulty is handling log(exp(e)) = e simplification, which requires a normalization step.

**Domain Bridges:** Transseries theory (van der Hoeven's formal logarithms), differential algebra (logarithmic derivatives), Hardy fields (compositional closure).

**Lineage:** Extends `refinedExprRank` to a richer expression language, preserving backward compatibility.

**Ambition:** ★★★★★ — Grand challenge. Requires substantial new formalization of logarithmic asymptotics.

---

## Direction 4: Tropical Semantics of Rank Computation

**Conjecture:** The refined rank computation `refinedExprRank` is the unique tropical semiring homomorphism from the EML expression algebra to (ℕ × ℕ, max, +) that maps var ↦ ⟨0, 1⟩ and eml(e) ↦ ⟨rank(e).k + 1, 0⟩.

**Test:** Verify that (ℕ × ℕ, max, +) with the lexicographic extension forms a tropical semiring. Check that `refinedExprRank` preserves tropical addition (= max for add) and tropical multiplication (= + for mul) on all expressions up to size 12. Search for alternative homomorphisms satisfying the same boundary conditions.

**Impact:** Would reveal that the rank computation is *uniquely determined* by the tropical algebraic structure — not just one possible classification, but the *only* classification consistent with the compositional rules. This would provide a strong canonicity result.

**Catalog References:** `mul_degree_additive_same_block`, `mul_cross_block_absorption` in `RefinedRank.lean`.

**Proof Strategy:** The degree-additivity theorem already shows mul corresponds to tropical multiplication within a block. The uniqueness proof would proceed by induction on expression size, showing that any homomorphism satisfying the boundary conditions must agree with `refinedExprRank`.

**Domain Bridges:** Tropical geometry (Mikhalkin, Itenberg), algebraic complexity theory (Valiant's VP/VNP), optimization (tropical linear algebra).

**Lineage:** Reinterprets the structural theorems (`mul_degree_additive_same_block`, `mul_cross_block_absorption`) as tropical algebra facts.

**Ambition:** ★★★★☆ — Paradigm-shifting if true. Would connect EML growth classification to tropical algebraic geometry.

---

## Direction 5: Effective Bounds in the Soundness Theorem

**Conjecture:** For EML expressions e₁, e₂ with refinedExprRank(e₁) < refinedExprRank(e₂), there exists a computable function N(e₁, e₂) such that for all x > N(e₁, e₂), eval(e₁, x) < eval(e₂, x). Moreover, N can be bounded by a function of the expression sizes and the rank gap.

**Test:** For each test case pair in `demo.py`, compute the smallest N where eval(e₁, x) < eval(e₂, x) for all x > N. Tabulate N against expression size and rank gap ⟨Δk, Δd⟩. Look for patterns: does N grow polynomially in expression size? Does N decrease with larger rank gaps?

**Impact:** Transforms the existential soundness theorem ("there exists N") into a *constructive* one with explicit bounds. This is essential for practical applications: a compiler needs to know *how large* inputs must be before the asymptotic ordering kicks in.

**Catalog References:** `refinedRank_soundness` (existential version) in `RefinedRank.lean`; `exp_exceeds_poly_eventually` in `Theorems.lean`.

**Proof Strategy:** Track the quantitative bounds through the soundness proof. The cross-block case uses `exp_exceeds_poly_eventually` which already provides an explicit N via `Real.tendsto_exp_div_pow_atTop`. The within-block case reduces to polynomial comparison, where N = 1 suffices for positive expressions.

**Domain Bridges:** Computational complexity (effective hierarchy theorems), numerical analysis (error bounds), program optimization (crossover points).

**Lineage:** Strengthens `refinedRank_soundness` from existential to constructive.

**Ambition:** ★★★☆☆ — Solid extension with direct practical applications.
