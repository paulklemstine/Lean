# Future Directions: Algorithmic Fairness Impossibility Theorems

## 1. Quantitative Calibration-Odds Tradeoff Bounds

The current `ppv_diff_mul_denoms` identity gives the exact PPV gap as `tpr * fpr * Δp / (D₁ * D₂)`. A natural next step is to derive tight **upper and lower bounds** on the calibration gap in terms of the base rate gap Δp and classifier accuracy parameters, without requiring knowledge of the exact denominators. The key insight is that the denominator product `D₁ * D₂` can be bounded using the constraint `0 < p < 1`, yielding bounds like `tpr * fpr * Δp ≤ PPV_gap ≤ tpr * fpr * Δp / (min(tpr,fpr))²`. Why now? The algebraic identity is already formalized; bounding the denominators requires only elementary inequality reasoning that Lean automation handles well.

## 2. Multi-Group Impossibility: Pairwise Implies Global

Chouldechova's theorem is stated for two groups. For k ≥ 3 groups with distinct base rates, can we formalize that **no single classifier achieves equalized odds and equal calibration across all k groups simultaneously**? The key insight is that the pairwise impossibility for any two groups with distinct base rates immediately lifts to the multi-group setting by existential quantification — if there exist two groups with different base rates, equalized odds forces different PPVs for those two groups, violating calibration. Why now? The two-group result is complete; the multi-group extension is a clean structural argument over `Finset` that leverages the existing theorem without new algebraic content.

## 3. False Negative Rate (FNR) Dual Impossibility

The current formalization addresses PPV (positive predictive value). The dual statement concerns the **false omission rate** FOR = FNR · p / (FNR · p + TNR · (1-p)), which by symmetric algebra is also strictly monotone in the base rate. Formalizing this dual impossibility and proving that **both** PPV and FOR must simultaneously differ across groups would yield a stronger impossibility: no non-trivial classifier can achieve equal calibration in *either* direction under equalized odds. The key insight is that FOR satisfies an identical algebraic identity with FNR replacing TPR and TNR replacing FPR, so the proof is a symmetric application of the same technique. Why now? The algebraic machinery (ppv_diff_mul_denoms, ppvDenom_pos) generalizes immediately; only the definitions need duplication.

## 4. Individual Fairness vs. Statistical Parity: Lipschitz Impossibility

Individual fairness (Dwork et al., 2012) requires that a classifier f be Lipschitz: d(f(x), f(y)) ≤ L · d(x, y) for a task-specific metric. Statistical parity requires E[f | group A] = E[f | group B]. Conjecture: if the group-conditional feature distributions have different means μ_A ≠ μ_B and the metric respects Euclidean distance, then **no L-Lipschitz classifier achieves statistical parity unless L = 0** (constant classifier). The key insight is that Lipschitz continuity constrains the classifier's output to track the input, so different input distributions force different output distributions. Why now? Formalizing this requires only basic measure theory from Mathlib (MeasureTheory.Integral) and the Lipschitz API, both mature.

## 5. Approximate Fairness: ε-Relaxation Tradeoffs

In practice, exact fairness is relaxed to approximate fairness: |PPV₁ - PPV₂| ≤ ε. Given the identity PPV_gap = tpr * fpr * Δp / (D₁ * D₂), one can derive that achieving ε-calibration under equalized odds requires either (a) near-perfect classification (tpr ≈ 1, fpr ≈ 0), (b) near-equal base rates (Δp ≈ 0), or (c) large ε. Formalizing the **exact tradeoff surface** {(tpr, fpr, Δp, ε) : ε-calibration achievable} as a semialgebraic set would provide the first machine-verified characterization of the fairness-accuracy Pareto frontier. The key insight is that the tradeoff surface is defined by a single polynomial inequality derived from the algebraic identity, making it amenable to `polyrith` or `nlinarith`. Why now? The algebraic identity is formalized; the remaining step is packaging the inequality and proving properties of the resulting set.
