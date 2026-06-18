
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Rigorous formal foundations for the Collatz conj
**Domain**: Applications
**Mathematical framing**: # Future Directions

## Synthesis

This research cycle established rigorous formal foundations for the Collatz conjecture's proof-theoretic analysis. The key results — parity exclusion, density contraction, odd density bounds, and orbit merge — form a coherent picture of why the conjecture is hard: local contraction is guaranteed by combinatorial constraints, but global contraction requires bounding growth phases that depend unpredictably on the input.

The most promising cross-domain connection is between the **Generalized Collatz System (GCS) framework** and the **computational universality** results in the Catalog's `Computation/` directory. Conway's theorem that GCS families are Turing-complete connects directly to the oracle and computability structures in `Computation/GravityOracle.lean` and `Computation/InfoEfficientAlgorithms.lean`. The GCS encoding notion defined in this cycle could bridge dynamical systems (Algebra) with computability theory (Computation), creating a formal pathway from specific Collatz dynamics to proof-theoretic independence.

The direction with highest breakthrough potential is Direction 1 (Sharp Contraction Threshold), because it would close the gap between our sufficient condition (odd density < 1/2) and the necessary condition (odd density < log₂3) using only real-number arithmetic already available in Mathlib. This would be the tightest known formal bound on Collatz contraction, directly useful for any future proof attempt.

---

### Direction 1: Sharp Contraction Threshold via Real Logarithms

**Conjecture**: For any Collatz orbit of length k with j odd steps, if j/k < log(2)/log(3), then the orbit segment contracts (the end value is less than the start value for sufficiently large starting values). Specifically: for all ε > 0, there exists N₀ such that if n ≥ N₀ and j/k < log(2)/log(3) - ε, then T^k(n) < n.

**Test**: Formalize the real-valued inequality log(3)/log(2) · j < k - j in Lean 4 using Mathlib's `Real.log`. Prove that this implies 3^j < 2^(k-j) using `Real.rpow_lt_rpow` and related lemmas. Verify computationally for k = 100, j = 62 (which is below the threshold) vs j = 64 (above).

**Impact**: This would give the sharpest possible formal contraction criterion, replacing our current sufficient condition (2j < k, i.e., density < 1/2) with the optimal threshold (density < log₂(2)/log₂(3) ≈ 0.6309). Any future proof of Collatz via density arguments would need this bound.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (pow3_lt_pow2_double, density_contraction), `Catalog/Algebra/ParityCylinders.lean` (isDescentWord)

**Proof Strategy**: 
1. Define the real-valued contraction condition: `j * Real.log 3 < (k - j) * Real.log 2`.
2. Show equivalence with `(3 : ℝ)^j < (2 : ℝ)^(k-j)` using `Real.exp_log` and monotonicity.
3. Transfer to natural numbers: `(3 : ℝ)^j < (2 : ℝ)^(k-j)` implies `3^j < 2^(k-j)` in ℕ using `Nat.cast_lt`.
4. Apply to the orbit affine bound to get the contraction result.

**Domain Bridges**: Algebra (parity word theory) <-> Analysis (real logarithms) <-> Computation (contraction verification)

**Lineage**: Builds on `pow3_lt_pow2_double` and `density_contraction` from this cycle.

**Ambition**: extension

---

### Direction 2: Collatz Orbit Encoding of Finite Automata

**Conjecture**: For every deterministic finite automaton (DFA) with n states, there exists a Generalized Collatz System with modulus m = O(n!) that simulates the DFA's computation. Specifically, the GCS can be constructed so that its residue-class dynamics on a set of n distinguished values exactly mirrors the DFA's state transitions.

**Test**: Construct explicit GCS encodings for small DFAs (2-state, 3-state) and verify in Lean that the GCS dynamics on the embedded states matches the DFA transitions. Then prove the general construction for arbitrary n-state DFAs.

**Impact**: This would be a concrete, constructive version of Conway's universality theorem, restricted to finite automata. It would establish the precise modulus needed for encoding, which is relevant to understanding whether the standard Collatz modulus (m = 2) has any encoding power.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (GCS, GCS.Encodes, FiniteTransition), `Catalog/Computation/InfoEfficientAlgorithms.lean` (BSState)

**Proof Strategy**:
1. Define DFA as a `FiniteTransition` with input alphabet.
2. Use Chinese Remainder Theorem to construct residue classes that separate states.
3. Define affine rules that map each state's residue class to the successor state's class.
4. Prove the divisibility condition using CRT.
5. Verify the encoding property.

**Domain Bridges**: Algebra (GCS framework) <-> Computation (finite automata, Turing completeness) <-> Cryptography (CRT constructions)

**Lineage**: Builds on GCS and FiniteTransition definitions from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Transfinite Orbit Measures and Goodstein Analogy

**Conjecture**: There exists an ordinal-valued measure μ : ℕ → Ordinal (below ε₀) such that for all n ≥ 2, μ(T(n)) < μ(n) in the standard Collatz map. If such a measure exists, the Collatz conjecture follows by transfinite induction, but the measure itself may require principles beyond PA (analogous to Goodstein's theorem).

**Test**: Define candidate measures combining stopping time, peak value, and bit-length. Test whether μ(T(n)) < μ(n) for n ≤ 10^6. The measure μ(n) = ω^(bit-length(n)) · (n mod 2^k) + lower-order terms is a natural starting point.

**Impact**: If a sub-ε₀ measure works, it would prove the Collatz conjecture using transfinite induction up to ε₀ (which is the proof-theoretic ordinal of PA). This would simultaneously prove Collatz and show it's provable in PA + transfinite induction, placing it at the same logical level as Goodstein's theorem. If no sub-ε₀ measure works, it would be strong evidence for independence from PA.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, peakValue, ComplexityClass), `Catalog/Logic/` (ordinal theory if available)

**Proof Strategy**:
1. Define ordinal-valued measures on ℕ using Cantor Normal Form.
2. Show that even steps decrease the measure (easy: bit-length decreases).
3. Show that odd steps increase bit-length by at most 1 but decrease a secondary component.
4. The challenge is finding a measure where the odd-step increase is compensated by subsequent even steps — this is where the parity exclusion theorem is crucial.

**Domain Bridges**: Algebra (Collatz dynamics) <-> Logic (ordinal arithmetic, proof theory) <-> Computation (well-founded recursion)

**Lineage**: Builds on ComplexityClass and stoppingTime from this cycle, and the parity exclusion theorem.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Analysis of Parity Words

**Conjecture**: The discrete Fourier transform of the parity word of a Collatz orbit of length k has spectral energy concentrated at frequency 1/2 (reflecting the parity exclusion alternation). Specifically, the spectral coefficient at frequency 1/2 satisfies |ĉ(1/2)| ≥ c·√k for some universal constant c > 0, and this spectral concentration is equivalent to the contraction property.

**Test**: Compute the DFT of parity words for orbits starting at n = 27 (a famously long orbit with 111 steps). Check whether the spectral peak at frequency 1/2 dominates. Compare with random binary words satisfying the no-consecutive-ones constraint.

**Impact**: A spectral characterization of contraction would connect Collatz dynamics to harmonic analysis, potentially enabling tools from analytic number theory (e.g., exponential sum estimates) to attack the conjecture. This bridges the combinatorial parity-word approach with the Fourier-analytic approach of Tao (2019).

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (orbitParity, oddSteps_le_half), `Catalog/MachineLearning/CollatzSpectral/` (existing spectral framework), `Catalog/Algebra/ParityCylinders.lean` (parityWord)

**Proof Strategy**:
1. Define the DFT on ParityWord: ĉ(f) = Σ w(i) · exp(2πi·f·i/k).
2. Use parity exclusion to show the alternating component is large.
3. Connect spectral energy to oddSteps/evenSteps ratio.
4. Prove that spectral concentration at f=1/2 implies the contraction bound.

**Domain Bridges**: Algebra (parity words) <-> Analysis (Fourier transform) <-> MachineLearning (spectral Collatz framework)

**Lineage**: Builds on orbitParity and oddSteps_le_half from this cycle; connects to `CollatzSpectral/` in the Catalog.

**Ambition**: extension

---

### Direction 5: Computational Lower Bounds on Collatz Independence

**Conjecture**: If the Collatz conjecture is independent of PA, then for infinitely many n, the stopping time of n exceeds any primitive recursive function of n. Conversely, if all stopping times are bounded by a fixed primitive recursive function, then the conjecture is provable in PA.

**Test**: Formalize the equivalence between "Collatz stopping times are primitive-recursively bounded" and "Collatz is provable in PA" using the connection between provably total functions and proof-theoretic ordinals. Test computationally: check whether stopping times for n ≤ 10^8 exceed n^(log log n), which is a candidate super-polynomial but sub-primitive-recursive bound.

**Impact**: This would give a precise computational criterion for independence: either stopping times are "tame" (primitive-recursively bounded) and the conjecture is provable, or they are "wild" (eventually exceeding any primitive recursive function) and the conjecture is independent. This transforms a metamathematical question into a concrete computational one.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, ComplexityClass, CollatzIndependenceConjecture), `Catalog/Computation/PadicValuationDepth.lean` (depth measures)

**Proof Strategy**:
1. Formalize the concept of a "provably total function" in a proof system.
2. Show that if Collatz is provable in PA, then its stopping-time function is provably total in PA.
3. By the characterization of provably total functions of PA (those bounded by functions in the fast-growing hierarchy below ε₀), this gives a concrete bound.
4. Conversely, show that a primitive recursive bound on stopping times yields a PA proof.

**Domain Bridges**: Algebra (Collatz dynamics) <-> Computation (primitive recursion, fast-growing hierarchy) <-> Logic (proof-theoretic ordinals)

**Lineage**: Builds on stoppingTime and CollatzIndependenceConjecture from this cycle.

**Ambition**: grand_challenge

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/CollatzSharpContraction.lean
import Mathlib
import Computation.CollatzParityContraction

/-!
# Collatz Sharp Contraction Threshold via Real Logarithms

This file extends the density-contraction foundations of
`Catalog/Computation/CollatzParityContraction.lean` from the *naive* sufficient
condition (odd-step density `< 1/2`, i.e. `2j < k`) to the **optimal** contraction
threshold (density `< log 2 / log 3 ≈ 0.6309`).

The Collatz "shortcut" dynamics multiply an orbit value by `3` once per odd step and
divide by `2` once per even step. Over a segment with `j` factors of `3` and `m`
factors of `2`, the segment contracts exactly when `3 ^ j < 2 ^ m`. The classical
combinatorial argument (`CollatzParity.pow3_lt_pow2_of_two_mul_lt`) only resolves the
case `2j < m` (using `3 < 4 = 2²`). Here we characterize the inequality `3 ^ j < 2 ^ m`
*exactly* by a real-logarithmic linear inequality, which yields the sharp density
threshold and strictly dominates the naive bound.

## Main Results

1. `pow3_lt_pow2_iff_log` — the exact logarithmic characterization:
   `(3:ℝ)^j < 2^m ↔ j · log 3 < m · log 2`.
2. `pow3_lt_pow2_of_density` — sharp contraction criterion on ℕ: if the odd-step
   density satisfies `j · (log 3 / log 2) < m`, then `3 ^ j < 2 ^ m`.
3. `log_of_two_mul_lt` — the sharp criterion is implied by the naive one (`2j < m`),
   so it is a genuine generalization.
4. `sharp_threshold_strictly_stronger` — an explicit witness `(j, m) = (1, 2)` that
   the sharp criterion fires where the naive one does not.
5. `log3_div_log2_mem_Ioo` — the threshold constant `log 3 / log 2` lies strictly
   between `1` and `2`, locating the optimal density between the trivial bounds.

These build on `CollatzParity.T`, `CollatzParity.pow3_lt_pow2_of_two_mul_lt`,
and the parity exclusion bound `CollatzParity.oddCount_le_half_ceil`.
-/

namespace CollatzSharp

open Real

/-! ## Section 1: Exact Logarithmic Characterization -/

-- !-- Lab Notebook: pow3_lt_pow2_iff_log -- !--
-- !-- Hypothesis: 3^j < 2^m over ℝ should be exactly equivalent to the linear
--     log inequality j·log3 < m·log2, since log is a strict order-iso on (0,∞). -- !--
-- !-- Result: Proved by rewriting j·log3 = log(3^j), m·log2 = log(2^m) via Real.log_pow
--     and applying Real.log_lt_log_iff. -- !--
-- !-- Insight: This turns a multiplicative power comparison into an additive density
--     comparison — the conceptual move that makes the *sharp* threshold visible. -- !--
-- !-- Failure analysis: log_lt_log_iff needs positivity of BOTH arguments (not one);
--     supplying both via positivity fixed the initial single-hypothesis attempt. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Rewrite both sides as logs of powers (Real.log_pow), then strict monotonicity
--     of log on positives (Real.log_lt_log_iff) gives the equivalence. -- !--
/-- **Exact logarithmic characterization** of the power comparison underlying Collatz
    contraction: `(3:ℝ)^j < 2^m` holds iff the linear inequality
    `j · log 3 < m · log 2` holds. -/
theorem pow3_lt_pow2_iff_log (j m : ℕ) :
    (3 : ℝ) ^ j < (2 : ℝ) ^ m ↔ (j : ℝ) * Real.log 3 < (m : ℝ) * Real.log 2 := by
  rw [show (j : ℝ) * Real.log 3 = Real.log ((3 : ℝ) ^ j) from (Real.log_pow 3 j).symm,
      show (m : ℝ) * Real.log 2 = Real.log ((2 : ℝ) ^ m) from (Real.log_pow 2 m).symm]
  exact (Real.log_lt_log_iff (by positivity) (by positivity)).symm

/-- The natural-number power comparison `3^j < 2^m` is equivalent to the real
    logarithmic density inequality. -/
theorem nat_pow3_lt_pow2_iff_log (j m : ℕ) :
    3 ^ j < 2 ^ m ↔ (j : ℝ) * Real.log 3 < (m : ℝ) * Real.log 2 := by
  rw [← pow3_lt_pow2_iff_log]
  constructor
  · intro h; exact_mod_cast h
  · intro h; exact_mod_cast h

/-! ## Section 2: Sharp Contraction Criterion -/

-- !-- Lab Notebook: pow3_lt_pow2_of_density -- !--
-- !-- Hypothesis: The OPTIMAL density bound j/m < log2/log3 should suffice for
--     contraction 3^j < 2^m, beating the naive bound j/m < 1/2. -- !--
-- !-- Result: Proved by clearing the denominator log2 > 0 from
--     j·(log3/log2) < m to recover j·log3 < m·log2, then nat_pow3_lt_pow2_iff_log. -- !--
-- !-- Insight: log 3 / log 2 = log_2 3 ≈ 1.585; the density threshold is its
--     reciprocal ≈ 0.6309 — strictly larger than 1/2, so strictly more orbits qualify. -- !--
-- !-- Failure analysis: div_mul_cancel₀ requires the exact `a/b*b` shape; needed
--     mul_assoc first so the (log3/log2)*log2 cancellation pattern appeared. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Multiply the density hypothesis by log 2 > 0 and cancel to get j·log3 < m·log2,
--     then apply the logarithmic characterization. -- !--
/-- **Sharp contraction criterion.** If the odd-step "density count" satisfies
    `j · (log 3 / log 2) < m` — i.e. `j` factors of `3` are dominated by `m`
    factors of `2` at the optimal threshold `log 2 / log 3` — then `3 ^ j < 2 ^ m`.

    This strictly generalizes `CollatzParity.pow3_lt_pow2_of_two_mul_lt`, whose
    threshold is the suboptimal `1/2`. -/
theorem pow3_lt_pow2_of_density {j m : ℕ}
    (h : (j : ℝ) * (Real.log 3 / Real.log 2) < (m : ℝ)) :
    3 ^ j < 2 ^ m := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h' : (j : ℝ) * Real.log 3 < (m : ℝ) * Real.log 2 := by
    have hh := mul_lt_mul_of_pos_right h hlog2
    rwa [mul_assoc, div_mul_cancel₀ _ (ne_of_gt hlog2)] at hh
  exact (nat_pow3_lt_pow2_iff_log j m).mpr h'

/-! ## Section 3: The Sharp Criterion Dominates the Naive One -/

-- !-- Lab Notebook: log_of_two_mul_lt / sharp_threshold_strictly_stronger -- !--
-- !-- Hypothesis: Every segment captured by the naive bound 2j < m is captured by
--     the sharp log bound, but not conversely. -- !--
-- !-- Result: log_of_two_mul_lt proves the forward containment via log 3 < 2 log 2
--     (= log 4); the witness (1,2) shows strictness: 1·log3 < 2·log2 yet ¬(2·1 < 2). -- !--
-- !-- Insight: The naive bound is the rational underestimate 1/2 < log2/log3 of the
--     true threshold; the gap (1,2) realizes 3 < 4 — the single inequality 3 < 2² that
--     the naive proof actually uses, exposed as the first newly-captured case. -- !--
-- !-- Failure analysis: nlinarith needed the scaled product j·log3 ≤ j·(2 log2) AND
--     the strict integer slack 2j+1 ≤ m (not just 2j ≤ m) to close strictness at j=0. -- !--
-- !-- End Lab Notebook -- !--

-- !-- From log 3 < 2 log 2 and 2j+1 ≤ m, scale by j ≥ 0 and add log2 slack via nlinarith. -- !--
/-- The naive contraction condition `2j < m` implies the sharp logarithmic condition,
    so the sharp criterion captures every segment the naive one does. -/
theorem log_of_two_mul_lt {j m : ℕ} (h : 2 * j < m) :
    (j : ℝ) * Real.log 3 < (m : ℝ) * Real.log 2 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog34 : Real.log 3 < 2 * Real.log 2 := by
    have h3 : Real.log 3 < Real.log 4 := Real.log_lt_log (by norm_num) (by norm_num)
    have h4 : Real.log 4 = 2 * Real.log 2 := by
      rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
    linarith
  have hjm : (2 * (j : ℝ)) + 1 ≤ (m : ℝ) := by exact_mod_cast Nat.succ_le_of_lt h
  have hjnn : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
  nlinarith [mul_le_mul_of_nonneg_left (le_of_lt hlog34) hjnn, hlog2, hjm]

/-- **Strict separation.** The sharp criterion fires at `(j, m) = (1, 2)` —
    `1 · log 3 < 2 · log 2` (equivalently `3 < 4`) — even though the naive bound
    `2 · 1 < 2` fails. Hence the sharp threshold is *strictly* stronger. -/
theorem sharp_threshold_strictly_stronger :
    ((1 : ℕ) : ℝ) * Real.log 3 < ((2 : ℕ) : ℝ) * Real.log 2 ∧ ¬ (2 * 1 < 2) := by
  refine ⟨?_, by norm_num⟩
  have : (3 : ℝ) ^ (1 : ℕ) < (2 : ℝ) ^ (2 : ℕ) := by norm_num
  exact (pow3_lt_pow2_iff_log 1 2).mp this

/-! ## Section 4: Locating the Threshold Constant -/

-- !-- Lab Notebook: log3_div_log2_mem_Ioo -- !--
-- !-- Hypothesis: The optimal contraction exponent log_2 3 = log3/log2 lies strictly
--     in (1, 2): above 1 (since
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Collatz Sharp Contraction Cycle

## Synthesis

This cycle sharpened the density-contraction foundations of the Collatz catalog. The
prior file `Catalog/Computation/CollatzParityContraction.lean` proved the *naive*
arithmetic core `pow3_lt_pow2_of_two_mul_lt`: if fewer than half the steps in an orbit
segment are odd (`2j < k`), then `3^j < 2^k` and the segment contracts. That bound is
suboptimal — it throws away everything between the rational `1/2` and the true threshold
`log 2 / log 3 ≈ 0.6309`. The new file `Catalog/Computation/CollatzSharpContraction.lean`
closes that gap by replacing the combinatorial inequality `3 < 4 = 2²` with an *exact*
logarithmic characterization.

The structural insight is that the multiplicative power comparison `3^j < 2^m` is, via
strict monotonicity of `Real.log` on the positives, *exactly equivalent* to the additive
linear inequality `j·log 3 < m·log 2` (`pow3_lt_pow2_iff_log`). Once contraction is
phrased additively, the optimal density threshold `log 2 / log 3` appears for free, and we
get the sharp criterion `pow3_lt_pow2_of_density`. We verified that this strictly dominates
the old bound: `log_of_two_mul_lt` shows every naively-captured segment is captured, and
`sharp_threshold_strictly_stronger` exhibits the explicit gap case `(j,m) = (1,2)` (i.e.
`3 < 4`) where the sharp criterion fires but the naive one does not. We also pinned the
threshold constant `log 3 / log 2` strictly inside `(1,2)` (`log3_div_log2_mem_Ioo`).

What did NOT close: lifting *segment* contraction `3^j < 2^m` to *orbit* contraction
`T^[k] n < n`. The obstruction is the additive `+1` accumulated at every odd step, which
contributes a geometric error term that only becomes negligible for large `n`. This is
recorded honestly as `sharp_orbit_contraction_conjecture` (the file's single `sorry`,
marked as an open conjecture, never a result). The cycle therefore isolates exactly where
the remaining difficulty lives: not in the power arithmetic (now optimal), but in the
affine error control of the orbit map.

## Results Summary

- `pow3_lt_pow2_iff_log`: proved — exact equivalence `(3:ℝ)^j < 2^m ↔ j·log 3 < m·log 2`, converting multiplicative contraction into additive density.
- `nat_pow3_lt_pow2_iff_log`: proved — the same equivalence transported to `ℕ` power comparisons.
- `pow3_lt_pow2_of_density`: proved — sharp contraction criterion: density below `log 2 / log 3` forces `3^j < 2^m`; strictly generalizes the naive `2j < k` bound.
- `log_of_two_mul_lt`: proved — the naive bound `2j < m` implies the sharp logarithmic bound (forward containment).
- `sharp_threshold_strictly_stronger`: proved — explicit witness `(1,2)` where the sharp criterion fires but the naive one fails (strict separation).
- `log3_div_log2_mem_Ioo`: proved — the optimal exponent `log 3 / log 2 = log₂ 3` lies strictly in `(1,2)`, locating the true density threshold above `1/2`.
- `sharp_orbit_contraction_conjecture`: conjecture (`sorry`) — realized-density
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
