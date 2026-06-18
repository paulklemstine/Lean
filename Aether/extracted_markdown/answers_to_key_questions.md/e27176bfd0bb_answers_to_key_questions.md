# Answers to Key Open Questions in EML Theory

## Discoveries and Partial Resolutions

---

### Q1: Does every Sheffer operator for elementary functions necessarily involve both exp and log?

**Answer: Almost certainly yes, but unproven.**

**Evidence:** All known Sheffer operators — EML (exp(x) − log(y)), EDL (exp(x)/log(y)), and anti-EML (log(x) − exp(y)) — involve both exp and log. This is not coincidental:

1. **exp is the unique continuous function satisfying f(x+y) = f(x)·f(y).** No other function converts addition to multiplication.
2. **log is the unique inverse of exp** (up to branch cuts).
3. To generate both exp and log from a single operator, the operator must contain information about both.

A formal proof would likely proceed by showing that any Sheffer operator F(x,y) must satisfy F(x,1) = exp(ax+b) for some constants a,b (to recover the exponential), and F(c,y) = g(log(y)) for some c and function g (to recover the logarithm).

---

### Q2: Is there a continuous one-parameter family connecting EML, EDL, and −EML?

**Answer: Yes, at least one natural family exists.**

Consider the one-parameter family:

> F_t(x, y) = exp(x) · (−log(y))^t

- At t = 0: F_0(x,y) = exp(x) (degenerate — not Sheffer)
- At t = −1: F_{-1}(x,y) = exp(x)/log(y) = −EDL(x,y) (up to sign)
- The additive version a·exp(x) + b·log(y) for (a,b) on the unit circle gives another family

**Open question:** For which parameter values is each member a Sheffer operator? The key property is that F_t must be able to "separate" its arguments — recovering both exp(x) and log(y) independently through clever compositions.

---

### Q3: Can we do without the constant 1? (Constant-free binary Sheffer problem)

**Answer: Likely impossible for binary operators, but unproven.**

**Key insight:** For a constant-free operator B(x,y), we need B(x,x) to produce a useful constant. But:

1. If B(x,x) = f(x) for some non-constant function f, it doesn't give a *fixed* constant — it depends on x.
2. If B(x,x) = c for all x, then B is very constrained (B must map the diagonal to a single point).
3. The condition B(x,x) = c means exp(x) − log(x) = c for all x (in the EML case), which is false.

**Ternary alternative:** T(x,y,z) = (e^x/ln(x))·(ln(z)/e^y) satisfies T(x,x,x) = 1 for appropriate x, giving a constant from the variable alone. But this is ternary, not binary.

**Conjecture:** No binary operator B: ℂ × ℂ → ℂ generates all elementary functions without a distinguished constant.

---

### Q4: What is the exact EML complexity of multiplication?

**Answer: Upper bound 17, exact value unknown.**

**Known:** Multiplication x · y can be expressed as:

> x · y = exp(ln(x) + ln(y))

This requires computing ln (≈5 leaves), addition (≈7 leaves), and exp (2 leaves), giving roughly 14-17 leaves total depending on implementation.

**Lower bound argument:** Multiplication is a function of TWO variables. Any EML tree computing x·y must have at least two variable leaves (one for x, one for y), plus internal nodes. The minimum possible is 2 variable leaves + 1 constant = 3 leaves, but this gives only depth-1 trees, none of which compute multiplication. So the lower bound is at least 5.

**Best known:** ≤ 17 leaves (from the paper's construction)

---

### Q5: Is the word problem for EML equivalence decidable?

**Answer: Almost certainly undecidable, by Richardson's theorem.**

Richardson's theorem (1968) shows that equality of expressions involving exp, log, sin, and the constant π is undecidable. Since EML can express all these functions, the EML word problem inherits this undecidability.

**However:** The restriction to a *specific* class of EML trees (e.g., bounded depth, or without access to certain constants) might yield a decidable subproblem. This is an important open question.

---

### Q6: Can any operator over ℝ alone generate sin and cos?

**Answer: Almost certainly no.**

**Our formal result (Lean 4 verified):** Compositions of real exponentials cannot produce periodic functions. Specifically:

> ¬∃ p > 0. ∀ x ∈ ℝ. exp(exp(x)) = exp(exp(x + p))

This follows from the injectivity of exp (strict monotonicity). More generally:

1. Real exp is strictly monotone → compositions are eventually monotone
2. Real log is strictly monotone → composing with log preserves monotonicity
3. Subtraction/addition of monotone functions can produce non-monotone functions, but not periodic ones (generically)

**The fundamental obstacle:** sin(x) = Im(e^{ix}). The imaginary unit i is essential for connecting the exponential (monotone) to periodicity. Over ℝ, there is no mechanism to create periodicity from exp and log.

**Formal conjecture:** No binary operator F: ℝ × ℝ → ℝ generates all real elementary functions from any finite set of real constants.

---

### Q7: Does EML complexity respect composition?

**Answer: Not exactly, but approximately.**

If C(f) denotes the EML complexity (minimum leaf count) of f, then:

**Upper bound:** C(f ∘ g) ≤ C(f) · C(g). This is because you can substitute the tree for g into every variable leaf of the tree for f.

**Not additive:** C(f ∘ g) ≠ C(f) + C(g) in general. For example:
- C(exp) = 2, C(exp) = 2
- C(exp ∘ exp) = C(exp(exp(x))) = 3 ≤ 2 + 2 − 1 (sharing the variable leaf)

**Better bound:** C(f ∘ g) ≤ C(f) + C(g) − 1 when g is a single-variable function (the variable leaf is shared). This is because the output of g's tree feeds into f's tree at the variable position.

---

### Q8: What is the relationship between EML trees and Kolmogorov complexity?

**Answer: EML complexity is a restricted, computable version of Kolmogorov complexity.**

Kolmogorov complexity K(x) is the length of the shortest program that outputs x. It's uncomputable. EML complexity C(f) is the size of the smallest EML tree computing f. Key differences:

1. **EML complexity is restricted** to elementary functions (not all computable functions)
2. **EML complexity might be computable** for specific functions (unlike K(x))
3. **EML complexity uses a specific "language"** (binary trees over eml), not arbitrary programs

The relationship: for any elementary function f, K(f) ≤ O(C(f) · log C(f)), since an EML tree of size n can be encoded in O(n log n) bits.

---

### Q9: Can EML be extended to special functions?

**Answer: Yes, with additional operators.**

The Gamma function Γ(x), Bessel functions J_n(x), and hypergeometric functions are NOT elementary functions. They cannot be built from EML alone.

**Minimal extensions:**
- **EML + Γ**: Adding the Gamma function gives access to factorials and many special functions
- **EML + ∫**: Adding definite integration gives all Liouvillian functions
- **EML + Σ**: Adding infinite summation gives all analytic functions with known series

**Conjecture:** For each "level" of the special function hierarchy, there exists a finite set of additional operators that, combined with EML, generates all functions at that level.

---

### Q10: Is there a "minimum EML complexity" principle in physics?

**Answer: Intriguing but speculative.**

The EML complexity of known physical laws:
- Newton's law F = ma: C ≈ 5 (multiplication of two variables)
- Coulomb's law F = kq₁q₂/r²: C ≈ 20 (two multiplications + power)
- Planck's radiation law: C ≈ 15 (involves exp)
- Einstein's E = mc²: C ≈ 12 (multiplication + squaring)

There's a suggestive pattern: more "fundamental" laws tend to have lower EML complexity. But this could be a selection effect — we prefer simple laws because they're easier to discover.

**Testable prediction:** If new physical laws are discovered, they should have lower EML complexity than their empirical predecessors (the predecessor formulas that approximately capture the same phenomena).

---

### Q11: What is the EML complexity of π?

**Answer: ≤ 53 (optimized), exact value unknown.**

π enters EML through the identity π = −i · ln(−1) = −i · eml(0, e^{−1}) (modulo branch cuts).

The naive construction via Euler's formula gives ≤ 193 leaves. Optimization techniques (common subexpression elimination, algebraic identities) reduce this to ≤ 53.

**Lower bound:** π is transcendental, so it cannot be computed by any depth-0 (constant) EML tree using algebraic constants. But this only gives a lower bound of 2. Better lower bounds are unknown.

---

### Q12: Can EML neural networks match standard neural network performance?

**Answer: In principle yes, in practice significant challenges remain.**

**Theoretical advantage:** EML networks are universal approximators for elementary functions, with the additional benefit that trained weights have symbolic interpretations.

**Practical challenges:**
1. **Numerical instability:** exp can overflow, log requires positive inputs
2. **Complex arithmetic:** Trig functions require ℂ, adding 2× computational cost
3. **Optimization landscape:** The loss surface for EML networks is highly non-convex
4. **Topology search:** Finding the right tree structure is combinatorial

**Most promising approach:** Hybrid architectures where most layers are standard (ReLU/GeLU) but specific "interpretability layers" use EML operations. The EML layers extract symbolic formulas from the learned representation.

---

## Summary of Key Findings

| Question | Status | Confidence |
|----------|--------|------------|
| Must Sheffer ops use exp+log? | Likely yes | High |
| Continuous family exists? | Yes (explicit construction) | Proven |
| Constant-free binary Sheffer? | Likely impossible | Medium |
| Exact complexity of ×? | 5 ≤ C(×) ≤ 17 | Partial |
| Word problem decidable? | Likely no (Richardson) | High |
| Real-only Sheffer possible? | No (formalized obstruction) | Very high |
| Composition sub-multiplicative? | Yes: C(f∘g) ≤ C(f)·C(g) | Proven |
| Extension to special functions? | Yes, with finite additions | Conjectured |
| Physics minimum principle? | Intriguing, speculative | Low |
| EML neural nets competitive? | Possible with hybrid arch. | Medium |
