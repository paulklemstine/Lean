# Future Directions: EML Transcendence Theory

## Synthesis

This research cycle established a formal bridge between the EML function `eml(x,y) = exp(x) - log(y)` and transcendental number theory via Schanuel's conjecture. The key insight is that the EML function acts as a "transcendence pump" — under Schanuel, algebraic inputs produce transcendental outputs through the exponential, and this transcendence survives the subtraction of algebraic logarithmic terms via the Algebraic Displacement Theorem.

The most promising cross-domain connection discovered is the link between EML expression depth and transcendence degree. Depth-0 expressions are algebraic (unconditionally), depth-1 expressions are transcendental at nonzero algebraic inputs (under Schanuel), and higher depths potentially yield algebraically independent collections. This hierarchy mirrors complexity-theoretic hierarchies, suggesting deep connections between computational and number-theoretic structure.

The cycle's results connect three areas: (1) the EML functional calculus from the catalog's `EML/EMLv17Core.lean`, (2) Schanuel-type transcendence from `Algebra/Schanuel/Theorems.lean`, and (3) algebraic independence theory via Mathlib's `AlgebraicIndependent`. The composition theorem (Theorem 3.10) is the highest-breakthrough-potential result because it shows EML has an inherent tendency to generate transcendental numbers — a structural property that may generalize beyond the specific form exp - log.

---

### Direction 1: EML Transcendence Degree Hierarchy

**Conjecture**: Under Schanuel's conjecture, for each n ≥ 1, there exist EML expressions e₁, ..., eₙ of depth ≤ n such that {e₁.eval, ..., eₙ.eval} is algebraically independent over Q. Moreover, the minimum total depth required to generate an algebraically independent n-tuple grows at most linearly in n.

**Test**: For n = 3, construct explicit EML expressions at rational inputs whose evaluations are algebraically independent under Schanuel. A candidate triple: (exp(1), exp(√2), exp(√3)) — but √2 and √3 are not EML numbers of depth 0. Instead, try (exp(1), log(2), exp(exp(1))). Under Schanuel, {1, log 2} are Q-linearly independent, so Schanuel gives trdeg Q(1, log 2, e, 2) ≥ 2. One should be able to extract algebraic independence of (e, log 2) and extend to 3 elements using the iterated exponential.

**Impact**: If true, this establishes that the EML function can generate arbitrarily complex transcendental objects from rational seeds, with efficient depth bounds. This would be a complete characterization of the transcendence-generating capacity of EML. If false, it reveals fundamental limits on what EML composition can achieve.

**Catalog References**: `EML/EMLv17Core.lean`, `Algebra/Schanuel/Theorems.lean`, `EML/Transcendence/Advanced.lean`

**Proof Strategy**: 
1. Formalize n-point Schanuel consequences using the existing `SchanuelConjecture` definition
2. Build EML expressions for candidate tuples using the `EMLExpr` inductive type
3. Prove Q-linear independence of the exponent tuples (needed for Schanuel application)
4. Apply the generalized embedding argument from `schanuel_implies_exp_pair_algind` to n-tuples
5. Key lemma needed: `schanuel_implies_exp_n_tuple_algind` for arbitrary n

**Domain Bridges**: Transcendental Number Theory ↔ Complexity Theory (depth hierarchy), EML ↔ Algebra (algebraic independence)

**Lineage**: Extends `schanuel_implies_exp_pair_algind` and `depth_zero_algebraic` from this cycle

**Ambition**: grand_challenge

---

### Direction 2: Baker-Type Bounds for EML Linear Forms

**Conjecture**: For algebraic α₁, ..., αₙ (nonzero) and algebraic β₁, ..., βₙ (not all zero), the linear form L = β₁ log(α₁) + ... + βₙ log(αₙ) satisfies |L| > exp(-C · (log H)^{n+1}) where H = max height of the αᵢ and C depends only on n and the degrees of the algebraic numbers. Formalizing this for n = 1 or n = 2 in Lean would be a major achievement.

**Test**: Formalize the statement of Baker's theorem for n = 1: if α is algebraic, α ≠ 0,1, then |log α| > H(α)^{-C} for an effective constant C. Attempt to prove the case where α is a rational p/q. Even a formal statement without proof would be valuable for future work.

**Impact**: Baker's method is the only known unconditional approach to transcendence results. Formalizing even a single case would bridge the gap between Schanuel-conditional and unconditional results. If the formalization reveals obstacles, it illuminates what makes Baker's method hard to mechanize.

**Catalog References**: `Algebra/Schanuel/Theorems.lean`, `EML/Transcendence/Theorems.lean`

**Proof Strategy**:
1. Define "height" of an algebraic number (polynomial height or Weil height)
2. State Baker's theorem for linear forms in logarithms
3. For the n=1 case, use the auxiliary function method or Gel'fond-Schneider approach
4. Connect to EML: Baker's bound gives effective lower bounds on |eml(x,y)| for algebraic x,y
5. Key challenge: the analytic estimates (Cauchy's integral formula, interpolation determinants)

**Domain Bridges**: Transcendental Number Theory ↔ Analytic Number Theory (Baker's method uses complex analysis), EML ↔ Diophantine Approximation

**Lineage**: Extends `schanuel_exp_transcendental_real` toward unconditional results

**Ambition**: grand_challenge

---

### Direction 3: Tropical EML and Idempotent Transcendence

**Conjecture**: Define the "tropical EML" function as `trop_eml(x, y) = max(x, -y)` (the tropical analog where exp → id and log → id in the max-plus semiring). The algebraic-independence structure of EML over Q has a tropical shadow: the "tropical algebraic independence" of trop_eml values at rational inputs corresponds to generic position conditions in tropical geometry.

**Test**: Define tropical EML expressions (replace exp with id and log with id in the EMLExpr tree, with arithmetic replaced by (max, +)). Prove that the tropical analog of the Algebraic Displacement Theorem holds: a "tropically transcendental" element (not the root of any tropical polynomial) shifted by a "tropically algebraic" element remains tropically transcendental. The key example: is max(1, -2) = 1 tropically transcendental?

**Impact**: If the tropical analog works, it provides a combinatorial model for EML transcendence that may be easier to analyze than the analytic original. The tropical setting eliminates convergence issues and makes algebraic independence decidable. If the analog fails, it identifies exactly where the analytic structure of exp/log is essential.

**Catalog References**: `Bridges/EMLTropicalSemiring.lean`, `Tropical/` directory, `EML/Transcendence/Defs.lean`

**Proof Strategy**:
1. Define tropical EML expressions by modifying the `EMLExpr` evaluator
2. Define "tropical algebraic" (root of a tropical polynomial = piecewise linear function)
3. Prove or disprove the tropical displacement theorem
4. Compare the tropical and classical depth hierarchies
5. Key connection: use the Maslov dequantization (lim_{h→0} h·log(exp(x/h) + exp(y/h)) = max(x,y))

**Domain Bridges**: Tropical Geometry ↔ Transcendental Number Theory, EML ↔ Tropical Semirings (via `Bridges/EMLTropicalSemiring.lean`)

**Lineage**: Extends `eml_bridge_recovers_exp` from the catalog and the transcendence framework from this cycle

**Ambition**: extension

---

### Direction 4: EML Field Structure and Inverse Closure

**Conjecture**: The class of EML numbers, extended with multiplicative inverses (x ↦ 1/x for x ≠ 0), forms a field. Moreover, this field is a proper subfield of ℝ — there exist real numbers that are not EML numbers.

**Test**: 
1. Extend `EMLExpr` with an `inv` constructor and prove field axioms.
2. Show that the EML field is countable (since expressions are finite trees over Q, which is countable).
3. Since ℝ is uncountable, the EML field is a proper subfield.
4. Investigate whether specific numbers (like Liouville's constant or the Champernowne constant) are EML numbers.

**Impact**: If the EML field is proper, it gives a natural "computability boundary" for transcendental number generation. Numbers inside the field are "EML-computable" while those outside are not — a hierarchy within the transcendentals analogous to the computability hierarchy.

**Catalog References**: `EML/Transcendence/Advanced.lean` (ring closure results), `EML/EMLv17Core.lean`

**Proof Strategy**:
1. Add `inv : EMLExpr → EMLExpr` with eval(inv e) = 1/(eval e) (or 0 if eval e = 0)
2. Prove multiplicative inverse: for e.eval ≠ 0, (mul e (inv e)).eval = 1
3. Prove countability using `Countable EMLExpr` (inductive types over countable bases are countable)
4. Conclude proper subfield by cardinality argument
5. For non-EML numbers: show that not every element of ℝ is in the countable EML field

**Domain Bridges**: Field Theory ↔ Computability Theory (countability argument), EML ↔ Descriptive Set Theory

**Lineage**: Extends the ring closure results from this cycle (eml_number_add_closed, etc.)

**Ambition**: extension

---

### Direction 5: Conditional Equivalence of EML and EL Number Classes

**Conjecture**: Under Schanuel's conjecture, every real number that can be expressed using exp, log, and rational arithmetic (an "EL number") can also be expressed using the EML function and rational arithmetic. In other words, the EML operation `eml(x,y) = exp(x) - log(y)` combined with rational arithmetic is as expressive as having exp and log separately.

**Test**: Show that from eml(x, y) = exp(x) - log(y), we can recover:
- exp(x) = eml(x, 1) (since log(1) = 0)
- log(y) = eml(0, y) - 1... wait, eml(0, y) = exp(0) - log(y) = 1 - log(y), so log(y) = 1 - eml(0, y)
This is unconditional! The key question is whether Schanuel adds anything to the equivalence.

**Impact**: If unconditionally true (as the test suggests), this simplifies the theory: EML is exactly as powerful as separate exp + log. The "merged" nature of EML does not restrict or enhance the class. Under Schanuel, this equivalence combined with the transcendence results gives a complete characterization of which EML numbers are transcendental.

**Catalog References**: `EML/Transcendence/Defs.lean` (EMLExpr, IsEMLNumber), `EML/EMLv17Core.lean`

**Proof Strategy**:
1. Show exp(x) = eml(x, 1) — already proved (eml_at_one)
2. Show log(y) = 1 - eml(0, y) for y > 0
3. Combine: any expression using exp and log separately can be rewritten using eml and arithmetic
4. For the converse: eml(x,y) = exp(x) - log(y) is obviously expressible with separate exp and log
5. Formalize as `IsEMLNumber x ↔ IsELNumber x` for a suitable definition of ELNumber

**Domain Bridges**: Computability ↔ Number Theory (expressiveness of operations), EML ↔ Model Theory (definability)

**Lineage**: Extends `eml_at_one_transcendental` and the EML expression framework from this cycle

**Ambition**: extension
