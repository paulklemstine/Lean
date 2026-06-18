# Future Research Directions: Cognitive Dynamics and Periodic Orbits

## Synthesis

This cycle established a rigorous Lean 4 framework for modeling cognitive recurrence (déjà vu) as periodic orbit structure in dynamical systems on bounded intervals. The key discoveries were: (1) the Déjà Vu Inevitability Theorem — any continuous self-map of a closed interval into itself has periodic points of *every* period, not just fixed points; (2) topological conjugacy preserves the entire periodic orbit structure, making it a genuine invariant of the dynamics; (3) period-3 orbits force cascading recurrence in spatially separated regions of state space. All 18 theorems were machine-verified with zero sorry statements.

The most promising cross-domain connection is between the **topological conjugacy invariance** of periodic orbit structure and the **Orbit Signature** as a classifier of dynamical systems. The Orbit Signature is a multiset of minimal periods that uniquely characterizes the cycle structure of a finite dynamical system up to dynamical equivalence. This connects naturally to the Catalog's work on polynomial method bounds (`EML/PolynomialMethod/SchwartzZippel.lean`) — counting periodic points is fundamentally a root-counting problem for f^n(x) - x, and bounds on root density connect to the Schwartz-Zippel framework. The topological entropy of a continuous interval map provides an upper bound on the exponential growth rate of periodic point counts, linking to the Catalog's information-theoretic measures in `EML/AdvancedTheory.lean`.

The highest breakthrough potential lies in Direction 1 (formalizing Sharkovsky's full theorem), which would be a landmark achievement in formalized mathematics — the complete theorem has not been formalized in any proof assistant to date (as of 2024). Direction 3 (connecting cognitive resonance to the EML framework) offers the most novel cross-domain bridge.

---

### Direction 1: Full Sharkovsky Theorem in Lean 4

**Conjecture**: For a continuous map f: [a,b] → [a,b], if f has a periodic point of period m, then f has a periodic point of every period n where n ◁ m in the Sharkovsky ordering: 3 ◁ 5 ◁ 7 ◁ ... ◁ 2·3 ◁ 2·5 ◁ ... ◁ 4·3 ◁ 4·5 ◁ ... ◁ 8 ◁ 4 ◁ 2 ◁ 1.

**Test**: Define the Sharkovsky ordering as a total order on ℕ⁺. Prove that period 3 implies period 5 (the first non-trivial implication after period 3 → period 2, which we partially established). Then prove period 3 → period 7, and generalize. A disproof would consist of finding a continuous interval map with a period-m point but no period-n point for some n ◁ m.

**Impact**: The full Sharkovsky theorem has not been formalized in any proof assistant. A complete Lean 4 formalization would be a significant contribution to the formalized mathematics literature and would provide a foundation for all subsequent work on interval dynamics and symbolic dynamics.

**Catalog References**: `Speculative/DejaVu/Advanced.lean` (period3_implies_fixed_point, period3_forces_f2_recurrence)

**Proof Strategy**: The proof requires Markov partition theory for interval maps. Define a graph where vertices are subintervals and edges represent "f(I) covers J." A period-n point corresponds to a length-n cycle in this graph. The key lemma: if f has a period-3 orbit a < b < c with f(a)=b, f(b)=c, f(c)=a, then [b,c] covers both [a,b] and [b,c], and [a,b] covers [b,c]. This "covering graph" has adjacency matrix whose spectral radius determines the growth of periodic orbit counts. For each n, construct a specific cycle in the covering graph.

**Domain Bridges**: Dynamical systems ↔ Graph theory (Markov graphs), Dynamical systems ↔ Symbolic dynamics (shift spaces)

**Lineage**: Builds on this cycle's period3_implies_fixed_point, period3_fixed_in_bc, period3_forces_f2_recurrence, and period3_exists_preimage_of_b.

**Ambition**: grand_challenge

---

### Direction 2: Topological Entropy Formalization and Computation

**Conjecture**: The topological entropy of the logistic map f_r(x) = rx(1-x) equals log(2) at r = 4, and the function r ↦ h_top(f_r) is monotonically increasing on [0, 4].

**Test**: Define topological entropy as the exponential growth rate of the number of (n, ε)-separated sets. Prove that h_top(f_4) = log(2) using the topological conjugacy with the tent map T(x) = 1 - |2x - 1| via the conjugacy φ(x) = (2/π)²sin²(πx/2). The tent map has h_top = log(2) by direct computation of the number of fixed points of T^n. Verify monotonicity numerically for 100 values of r.

**Impact**: Would establish the first formalized computation of topological entropy for a specific map in Lean 4, connecting abstract ergodic theory to concrete dynamics. The conjugacy with the tent map would demonstrate the power of the topological conjugacy invariance theorem proved in this cycle.

**Catalog References**: `Speculative/DejaVu/Advanced.lean` (topological_conjugacy_preserves_periodic, logistic_r4_maps_unit_interval)

**Proof Strategy**: 
1. Formalize the tent map T(x) = min(2x, 2-2x) on [0,1].
2. Prove T^n has exactly 2^n fixed points (by induction: each "lap" of T^n produces two laps of T^{n+1}).
3. Define topological entropy as lim_{n→∞} (1/n) log(Fix(f^n)).
4. Prove h_top(T) = log(2).
5. Formalize the conjugacy φ between f_4 and T.
6. Use conjugacy invariance to transfer the entropy computation.

**Domain Bridges**: Dynamical systems ↔ Information theory (Shannon entropy), Dynamical systems ↔ EML (ensemble complexity in `EML/AdvancedTheory.lean`)

**Lineage**: Builds on this cycle's topological conjugacy theorems and logistic map properties.

**Ambition**: extension

---

### Direction 3: Cognitive Resonance and the EML Framework

**Conjecture**: The Cognitive Resonance Number CRN(f) of a finite dynamical system (S, f) with |S| = n satisfies CRN(f) ≥ n/d where d is the maximum depth (tail length) of any orbit. Moreover, CRN(f) = n if and only if f is a permutation.

**Test**: Prove the lower bound CRN(f) ≥ 1 (every finite system has at least one periodic point — this follows from pigeonhole). Prove CRN(f) = n iff f is bijective. Compute CRN for all maps on {0,1,2,3} (4^4 = 256 maps) and verify the lower bound computationally. Connect to the EML notion of ensemble complexity: conjecture that CRN(f) / n converges to a universal constant as n → ∞ for "random" maps.

**Impact**: Would establish a quantitative bridge between finite dynamical systems theory and the EML framework. The Cognitive Resonance Number could serve as a new complexity measure for automata and recurrent neural networks, complementing the existing EML invariants.

**Catalog References**: `EML/AdvancedTheory.lean` (ensembleComplexity, ensemble_complexity_additive), `EML/EMLv17Core.lean` (eml, emlDiag)

**Proof Strategy**:
1. Prove CRN(id) = n (every point is periodic under identity) — already established in this cycle.
2. Prove CRN(f) = n → f injective → f surjective (Fintype) → f bijective.
3. Prove CRN(f) ≤ n trivially.
4. For the lower bound, use the eventual periodicity theorem (this cycle's finite_eventually_periodic).
5. Connect to EML: define a "dynamical EML" measure as log(CRN(f)) / log(n) and study its distribution.

**Domain Bridges**: Dynamical systems ↔ EML (complexity measures), Finite dynamics ↔ Combinatorics (counting periodic orbits of maps on finite sets)

**Lineage**: Builds on this cycle's CognitiveResonanceNumber definition, finite_eventually_periodic, and OrbitSignature.

**Ambition**: extension

---

### Direction 4: Period-3 Implies Genuine Period-2 (The Missing Lemma)

**Conjecture**: For a continuous map f: ℝ → ℝ with a period-3 orbit a → b → c → a where a < b < c, there exists a point p with f(f(p)) = p and f(p) ≠ p (a genuine period-2 point, not merely an f²-fixed point that is also an f-fixed point).

**Test**: Prove this rigorously in Lean 4. The key obstacle in this cycle was establishing that f has no fixed point in a certain subinterval. The correct approach may use a sign-analysis argument: on [a,b], f(x) - x is positive at both endpoints (f(a) = b > a, f(b) = c > b), while f²(x) - x changes sign (f²(a) = c > a, f²(b) = a < b). If f(x) > x for all x ∈ [a,b], the conclusion is immediate. If f has a fixed point in (a,b), a more delicate argument involving the factorization f²(x) - x = (f(x) - x) · Q(x) + remainder may be needed.

**Impact**: Would complete the formalization of the first non-trivial case of Sharkovsky's theorem (period 3 → period 2). This is the key step missing from the current formalization and a prerequisite for the full Sharkovsky theorem (Direction 1).

**Catalog References**: `Speculative/DejaVu/Advanced.lean` (period3_forces_f2_recurrence, period3_fixed_in_bc)

**Proof Strategy**: 
Two approaches to try:
1. **Direct sign analysis**: Show that the zero of f²-id in (a,b) cannot coincide with a zero of f-id by analyzing the local behavior of (f²-id)/(f-id) near a common zero. This requires showing that at a common zero s, f'(s) ∈ {-1, 1} or the zero of f²-id has higher order.
2. **Markov partition**: Use the covering relations [b,c] ⊇ₘ [a,b] and [b,c] ⊇ₘ [b,c] and [a,b] ⊇ₘ [b,c] to construct a period-2 orbit via the graph-theoretic path b → a → b (going through [b,c] → [a,b] → [b,c]).

**Domain Bridges**: Real analysis ↔ Dynamical systems (sign analysis of iterates)

**Lineage**: Builds directly on this cycle's period3_forces_f2_recurrence (which finds an f²-fixed point) and period3_fixed_in_bc (which localizes the f-fixed point).

**Ambition**: extension

---

### Direction 5: Li-Yorke Chaos Formalization

**Conjecture**: For a continuous map f: [a,b] → [a,b] with a period-3 orbit, there exists an uncountable scrambled set S ⊆ [a,b] — a set where every pair of distinct points x, y has lim inf d(f^n(x), f^n(y)) = 0 and lim sup d(f^n(x), f^n(y)) > 0.

**Test**: Formalize the Li-Yorke definition of chaos (already partially done as CognitiveSystem.hasLiYorkeChaos in the Catalog). Prove the result for a specific explicit function (e.g., the tent map with slope 2) before attempting the general case. The Cantor set construction provides the uncountable scrambled set.

**Impact**: Would be the first formalization of the Li-Yorke theorem ("Period Three Implies Chaos") in any proof assistant. This is one of the most famous results in dynamical systems theory and would represent a major achievement in formalized mathematics.

**Catalog References**: `Speculative/DejaVu/Core.lean` (CognitiveSystem.hasLiYorkeChaos definition), `Speculative/DejaVu/Advanced.lean` (period3 theorems)

**Proof Strategy**:
1. Formalize symbolic dynamics: the shift space Σ₂ = {0,1}^ℕ with the shift map σ.
2. Construct a semiconjugacy from f to σ using the Markov partition from the period-3 orbit.
3. The scrambled set comes from sequences that are "non-periodic and non-eventually-periodic" — this is an uncountable subset of Σ₂ (complement of a countable set).
4. Transfer the scrambling property through the semiconjugacy.

**Domain Bridges**: Dynamical systems ↔ Descriptive set theory (uncountable sets), Dynamical systems ↔ Symbolic dynamics (shift spaces)

**Lineage**: Builds on this cycle's period-3 cascade theorems and the Li-Yorke chaos definition from the Catalog.

**Ambition**: grand_challenge
