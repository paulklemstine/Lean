# Future Directions: Tropical Arithmetic Statistics of Elliptic Curves

This document outlines concrete, theorem-oriented next steps opened by the tropical BSD prototype formalization. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## 1. Tropical Néron–Tate Height Formalization

**Objective:** Define a min-plus quadratic form on finite valuation profiles and prove tropical polarization identities.

**Hypothesis:** For valuation profiles $v_1, v_2 : S \to \mathbb{R}$, define the tropical height pairing
$$\langle v_1, v_2 \rangle_{\mathrm{trop}} := \inf_{n \in S} (v_1(n) + v_2(n)).$$
Then the tropical polarization identity holds:
$$4 \langle v_1, v_2 \rangle_{\mathrm{trop}} = \langle v_1 \oplus v_2, v_1 \oplus v_2 \rangle_{\mathrm{trop}} - \langle v_1 \ominus v_2, v_1 \ominus v_2 \rangle_{\mathrm{trop}},$$
under appropriate tropical addition/subtraction definitions.

**Proof Strategy:**
- Define tropical inner product as `S.inf' hS (fun n => v₁ n + v₂ n)`.
- Define tropical addition of profiles pointwise via `min`.
- Prove the polarization identity using `Finset.inf'` arithmetic.
- Show that tropical height is non-negative under a positivity hypothesis.

**Lean Signature:**
```lean
def tropicalHeightPairing (S : Finset ℕ) (hS : S.Nonempty) (v₁ v₂ : ℕ → ℝ) : ℝ :=
  S.inf' hS (fun n => v₁ n + v₂ n)
```

**Cross-Domain Connection:** Links tropical BSD to Arakelov geometry and height theory. The tropical height pairing would serve as the regulator term in a refined tropical BSD formula.

---

## 2. Tropical Selmer Bounds

**Objective:** Formalize a finite tropical Selmer obstruction and prove `tropicalRank ≤ tropicalSelmerRank`.

**Hypothesis:** Define a tropical Selmer group as a set of valuation profiles satisfying local constraints at each prime in a finite bad-reduction set. Prove that any set of tropically independent profiles satisfying the Selmer conditions has cardinality bounded by the number of independent local constraints.

**Proof Strategy:**
- Define `tropicalSelmerSet` as profiles satisfying `∀ p ∈ BadPrimes, localConstraint p v`.
- Define `tropicalSelmerRank` as the maximum cardinality of an independent subset.
- Prove the bound by a finite pigeonhole/dimension argument.

**Lean Signature:**
```lean
def tropicalSelmerRank (S BadPrimes : Finset ℕ) (v : ℕ → ℕ → ℝ)
    (localConstraint : ℕ → (ℕ → ℝ) → Prop) : ℕ :=
  -- maximum cardinality of independent profiles satisfying all local constraints
```

**Cross-Domain Connection:** Creates a tropical analogue of the Selmer group, opening routes to tropical descent and p-adic tropical bridges.

---

## 3. Newton Polygon Special-Value Machine

**Objective:** Relate tropical order of vanishing to slopes of a finite arithmetic Newton polygon derived from local Euler data.

**Hypothesis:** The tropical L-series $T_w(s) = \inf_{n \in S}(w(n) + (s-1)\log n)$ is a piecewise-linear function whose slopes at breakpoints are exactly the values $\log n$ for active $n$. The Newton polygon of this function at $s = 1$ encodes the tropical order of vanishing as the number of slope changes.

**Proof Strategy:**
- Formalize the lower envelope of a finite family of affine functions.
- Prove that breakpoints of the lower envelope correspond to changes in the minimizing index.
- Show that the tropical order of vanishing equals the number of breakpoints at $s = 1$.
- Connect breakpoint data to Newton polygon slopes.

**Lean Signature:**
```lean
def lowerEnvelope (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) (s : ℝ) : ℝ :=
  S.inf' hS (fun n => w n + (s - 1) * Real.log n)

theorem breakpoint_count_eq_tropicalOrder
    (S : Finset ℕ) (hS : S.Nonempty) (w : ℕ → ℝ) :
    -- number of affine branches active at s=1 minus 1
    -- equals tropical order of vanishing
```

**Cross-Domain Connection:** Bridges tropical geometry with Newton polygon methods from $p$-adic analysis and algebraic geometry. Creates algorithmic tools for computing tropical invariants.

---

## 4. Tropical Tamagawa Product Formula

**Objective:** Package local bad-reduction data into a global idempotent residue theorem.

**Hypothesis:** For a finite set of primes $P = \{p_1, \ldots, p_k\}$ with local correction weights $c_{p_i} : S \to \mathbb{R}$, the global tropical correction is:
$$\mathrm{tRes}_1(T_{c_{p_1} \oplus \cdots \oplus c_{p_k}}) = \min_{1 \le i \le k} \mathrm{tRes}_1(T_{c_{p_i}}).$$

This follows from iterated application of `tropical_residue_min`.

**Proof Strategy:**
- Prove the $k$-fold version of `tropical_residue_min` by induction.
- Define the Tamagawa product as a fold over the bad primes.
- Show the fold commutes with `tropicalResidue` via associativity of `min`.

**Lean Signature:**
```lean
theorem tropical_residue_fold_min
    (S : Finset ℕ) (hS : S.Nonempty)
    (ws : List (ℕ → ℝ)) (hws : ws ≠ []) :
    tropicalResidue S hS (fun n => ws.foldl (fun acc w => min acc (w n)) (ws.head hws n))
    = ws.foldl (fun acc w => min acc (tropicalResidue S hS w)) (tropicalResidue S hS (ws.head hws))
```

**Cross-Domain Connection:** Directly models the Tamagawa number product from BSD. Creates a pathway from local arithmetic data to global tropical invariants, paralleling the adelic framework.

---

## 5. Algorithmic Arithmetic Certificates and Computational Experiments

**Objective:** Extract executable code computing tropical analytic rank from finite local data and compare with known rank examples from elliptic curve databases (e.g., Cremona's tables).

**Hypothesis:** For specific elliptic curves $E/\mathbb{Q}$ with known Mordell–Weil rank $r$, one can construct valuation profiles from reduction data at small primes such that the tropical BSD prototype theorem yields $r$ as the tropical analytic rank.

**Implementation Plan:**
- Write a verified function `computeTropicalOrder : Finset ℕ → (ℕ → ℝ) → ℕ` using `Decidable` instances.
- Extract to executable code via `#eval`.
- Compare outputs with Cremona's tables for curves of rank 0, 1, 2.
- Formalize correctness: the computed value equals `tropicalOrderAtOne`.

**Lean Signature:**
```lean
def computeTropicalOrder (S : List ℕ) (w : ℕ → Float) : ℕ :=
  -- efficient computation using List.foldl
```

**Cross-Domain Connection:** Creates the first formally verified arithmetic invariant computation tool. Opens routes to certified rank bounds, complexity analysis of arithmetic algorithms, and machine-assisted conjecture generation for elliptic curves.

---

## Cross-Cutting Themes

### Tropical Arithmetic Statistics
All five directions contribute to a new field: **tropical arithmetic statistics**, where:
- Ranks are tropical dimensions
- L-function zeros are lower-envelope corners
- Regulators are tropical heights
- Tamagawa numbers are local min-plus corrections
- BSD becomes a finite combinatorial identity

### Matroid-Theoretic Extensions
The tropical independence condition `valuationProfileIndependent` can be strengthened to a matroid structure. This connects to:
- Tropical Grassmannians and their combinatorics
- Matroid intersection algorithms for rank computation
- Tropical convexity and polyhedral geometry

### Statistical Mechanics Interpretation
The active set is a ground state, the tropical order is a degeneracy count, and the tropical residue is a ground-state energy. Extending this to positive temperature ($s \neq 1$) via log-sum-exp approximations would create a thermodynamic theory of L-functions.
