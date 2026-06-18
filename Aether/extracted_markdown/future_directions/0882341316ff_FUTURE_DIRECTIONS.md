# Future Directions: Proof Compression Universality

## Hypothesis 1: Theory Exponent Hypothesis

**Conjecture.** For every consistent, recursively axiomatizable first-order theory *T* with cut-elimination, there exists a theory-specific *normalization exponent* α_T ∈ ℕ such that for every complete deterministic normalizer *N* of the Gentzen-style sequent calculus for *T*, and every "natural" family of theorems φ_n encoding combinatorial principles in *T*, the worst-case normalized proof size satisfies:

> |N(π)| = Θ(|π|^{α_T})

up to polynomial distortion depending on the normalizer, where |·| denotes proof size.

**Test.** Implement two normalizers (Gentzen cut-elimination and normalization-by-evaluation) for fragments of Peano Arithmetic. Measure normalized proof sizes on families of bounded induction instances, pigeonhole encodings, and Paris-Harrington statements. Fit the growth curves to power laws and compare exponents across normalizers. If α differs by more than the polynomial simulation degree, the hypothesis is refuted.

**Impact.** If true, this creates a new numerical invariant of formal theories—a "complexity fingerprint" analogous to critical exponents in statistical physics. Different theories would have measurably different normalization exponents, providing a quantitative taxonomy of mathematical theories by their proof-compression behavior.

---

## Hypothesis 2: Universality Class Hypothesis

**Conjecture.** The norm-polynomial equivalence classes of complete deterministic normalizers for a given proof system form finitely many equivalence classes (universality classes). That is, there exist only finitely many distinct asymptotic behaviors of normalization, and every normalizer falls into one of these classes.

**Test.** Enumerate all distinct normalization strategies for propositional sequent calculus on formulas of bounded connective depth ≤ d. For small d (d = 3, 4, 5), compute the norm-polynomial simulation parameters between all pairs. Check whether the resulting equivalence relation has finitely many classes and whether the number stabilizes as d grows. A counterexample would be an infinite family of normalizers no two of which are norm-polynomially equivalent.

**Impact.** If true, this implies that the "space" of normalizers has a rigid combinatorial structure, analogous to the finite number of universality classes in the renormalization group theory of phase transitions. It would mean that the landscape of proof normalization algorithms is fundamentally discrete, not continuous.

---

## Hypothesis 3: Semantic Rigidity Hypothesis

**Conjecture.** If two normalizers N₁ and N₂ for a proof system are *semantically equivalent* (i.e., for every proof π, the denotations of N₁(π) and N₂(π) in any categorical model of the proof system are equal), then N₁ and N₂ are norm-polynomially equivalent.

**Test.** Construct two semantically equivalent normalizers for the simply-typed lambda calculus (e.g., leftmost-outermost and rightmost-innermost reduction to normal form). Measure whether their normalized term sizes are polynomially related on Church-encoded natural numbers and combinatory expressions. A refutation would be a pair of semantically equivalent normalizers with provably superpolynomial separation on some term family.

**Impact.** This would establish that the phase invariance theorem extends beyond syntactic polynomial simulation to semantic equivalence—meaning that proof compression phases are truly *semantic* invariants of proofs, not syntactic artifacts. This bridges proof complexity and categorical semantics in a novel way.

---

## Hypothesis 4: Entropy Law for Proofs

**Conjecture.** There exists a function H (the "proof entropy") from statement families to ℝ≥0 ∪ {∞} such that for every complete deterministic normalizer N with polynomial simulation overhead at most k:

> lim sup_{n→∞} log(|N(π_n)|) / log(|π_n|) = H(φ) · k + O(1)

where π_n is the shortest proof of φ_n. That is, the logarithmic blowup ratio is (up to polynomial distortion) a conserved quantity depending only on the statement family.

**Test.** For propositional tautology families (pigeonhole, parity, Tseitin), compute the logarithmic blowup ratio under multiple normalizers. Check whether the ratios are related by a multiplicative constant (the simulation degree k). Refutation: two normalizers with the same polynomial simulation degree k that yield non-proportional logarithmic blowup ratios on the same family.

**Impact.** This would be a conservation law for proof information, analogous to Shannon's source coding theorem. It would mean that proofs carry a measurable, normalizer-independent quantity of "derivational information" that normalization merely redistributes but cannot create or destroy (up to polynomial distortion).

---

## Hypothesis 5: Phase Transition Sharpness Hypothesis

**Conjecture.** For parameterized theories T_ε (e.g., bounded arithmetic with induction up to depth ε·n), there exists a critical value ε* such that:
- For ε < ε*, normalization is polynomially bounded on all natural families.
- For ε > ε*, normalization exhibits superpolynomial blowup on at least one natural family.

The transition at ε* is *sharp* in the sense that there is no intermediate regime of sub-exponential but superpolynomial growth of width > 0 in the parameter space.

**Test.** Implement bounded arithmetic fragments IΣ_n for varying n. For each n, measure the maximum normalized proof size on bounded-depth tautologies. Plot the growth exponent as a function of n. A sharp phase transition would manifest as a sudden jump from polynomial to exponential growth. Refutation: a smooth, continuous increase in growth exponents over a range of n values.

**Impact.** This would be the first rigorous phase transition in proof complexity analogous to physical phase transitions. Combined with the phase invariance theorem, it would show that the transition point ε* is a normalizer-independent invariant of the parameterized theory—a new kind of mathematical constant characterizing the boundary between tractable and intractable proof normalization.
