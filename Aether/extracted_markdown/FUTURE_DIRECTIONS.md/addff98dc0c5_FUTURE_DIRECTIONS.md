# Future Directions: ABC Conjecture Formalization Program

## Conjecture 1: Subpolynomial Growth of High-Quality ABC Triples

**Precise statement:** For each fixed rational quality threshold Q > 1, define N(X, Q) as the number of primitive ABC triples (a, b, c) with c ≤ X and quality q(a,b,c) = log(c)/log(rad(abc)) > Q. Then N(X, Q) = O(X^ε) for every ε > 0.

**Test:** Enumerate primitive triples up to X = 10^4, 10^5, 10^6, 10^7 and compute N(X, Q) for Q = 1.0, 1.2, 1.4. Plot log N(X,Q) vs log X. If the slope converges to 0, the conjecture is supported. If it stabilizes at a positive constant, the conjecture is falsified.

**Impact:** If true, this provides quantitative refinement of the ABC conjecture. If false for some Q > 1, it would suggest the ABC conjecture, while true, admits a slower-than-expected decay and the discrete formulation may need adjustment. Formal verification of the growth rate bound would strengthen the ABC consequence engine.

---

## Conjecture 2: No Primitive Fermat Solutions Beyond Computable Quality Threshold

**Precise statement:** Define Q_max(X) as the maximum observed ABC quality among all primitive triples with c ≤ X. Then for all n ≥ ⌈3 · Q_max(10^18)⌉ + 1, there exist no positive pairwise coprime (a, b, c) with a^n + b^n = c^n.

**Test:** Using the ABC@Home dataset of triples with c up to 10^18, determine Q_max. Current records suggest Q_max ≈ 1.6299 (the Reyssat triple). This would yield n ≥ 6. Cross-reference with the known proof of FLT for all n (by Wiles) to confirm this is consistent. The conjecture becomes interesting if we can push the quality search to larger bounds and get sharper cutoffs.

**Impact:** This makes the asymptotic FLT consequence of ABC fully explicit with a computable threshold. Formalizing this with concrete computed bounds would produce the first machine-verified explicit FLT bound from ABC.

---

## Conjecture 3: Radical-Height Duality for Elliptic Curves (Szpiro Interface)

**Precise statement:** For each elliptic curve E/ℚ with minimal discriminant Δ_E and conductor N_E, define the Szpiro ratio σ(E) = log|Δ_E| / log(N_E). The ABC conjecture implies σ(E) ≤ 6 + ε for all ε > 0 with finitely many exceptions. Conversely, the formal HeightRadicalBound structure should be instantiable with Szpiro data, producing verified consequences for Mordell curves.

**Test:** Implement a database query against the LMFDB elliptic curve data. For each curve, compute σ(E) and verify σ(E) < 6 + 0.5 = 6.5 for all curves with conductor ≤ 10^8. Any curve with σ > 6.5 would be a near-counterexample warranting investigation.

**Impact:** Extends the formal ABC consequence engine to algebraic geometry. The HeightRadicalBound interface is designed precisely for this: plug in Szpiro data as a new height inequality source and derive consequences automatically.

---

## Conjecture 4: Support Complexity Gap Characterization

**Precise statement:** Define the support complexity gap Γ(a,b,c) = ω(c) - ω(rad(abc)) for primitive ABC triples, where ω is the number of distinct prime factors. For quality > 1 triples, Γ < 0 (the output c has fewer prime factors than the full radical). Moreover, the magnitude |Γ| grows at most logarithmically with c.

**Test:** For all primitive triples with c ≤ 10^5, compute Γ(a,b,c) and plot Γ vs log(c). If Γ is bounded by C·log(log(c)) for some constant C, the conjecture holds. Tabulate for quality > 1 vs quality ≤ 1 triples separately.

**Impact:** This connects the ABC conjecture to information-theoretic lower bounds. If support complexity gap is indeed bounded, it suggests a formal analogy between arithmetic generation and data compression: you cannot "compress" prime support arbitrarily while maintaining additive closure. This is the bridge to coding theory.

---

## Conjecture 5: Radical Concentration on Small Primes for High-Quality Triples

**Precise statement:** For high-quality ABC triples (quality > 1), the largest prime factor of rad(abc) is O(c^{1/2}). More precisely, if P(n) denotes the largest prime factor of n, then for quality-1+ triples, P(abc) ≤ c^{0.6} holds in all observed cases.

**Test:** Enumerate primitive triples with c ≤ 10^6 and quality > 1. For each, compute P(abc)/c and check if it stays below c^{-0.4}. A single triple violating this would refute the conjecture. Systematic verification for c ≤ 10^6 provides strong evidence.

**Impact:** If true, this characterizes the "prime architecture" of high-quality triples. It would imply that the arithmetic responsible for ABC quality comes from repeated small primes, not large primes — which connects to the theory of smooth numbers and has applications to factoring algorithms and cryptographic hardness assumptions.
