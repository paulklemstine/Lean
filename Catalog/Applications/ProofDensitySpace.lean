/-
Copyright (c) 2025. All rights reserved.

# Proof Density Spaces and Phase Transitions in Provability

This file introduces the **ProofDensitySpace** — a novel mathematical structure
that models the combinatorial landscape of formal proof systems through the lens
of density theory.

## Main Contributions

1. **ProofDensitySpace** — A structure capturing the essential counting parameters
   of a formal system: alphabet size, statement counts, provable counts, and
   proof length bounds at each complexity level.

2. **Counting Incompleteness Theorem** — A purely combinatorial proof that
   statement-counting exceeding proof-counting forces unprovable statements.

3. **Phase Transition at Completeness Threshold** — When provability density
   drops from 1 to strictly less than 1, marking a sharp transition.

4. **Proof Dimension Theory** — Connecting fractal dimension of proof space
   to incompleteness.

5. **Gap Amplification** — Small incompleteness gaps amplify exponentially.
-/

import Mathlib

open Nat Finset

/-! ## §1. The ProofDensitySpace Structure -/

/-- A **ProofDensitySpace** captures the counting structure of a formal proof system.

- `b` : alphabet size (≥ 2)
- `stmtCount n` : number of well-formed statements of length exactly `n`
- `provableCount n` : number of provable statements of length exactly `n`
- `proofBound n` : maximum proof length for provable statements of length `n`
-/
structure ProofDensitySpace where
  b : ℕ
  stmtCount : ℕ → ℕ
  provableCount : ℕ → ℕ
  proofBound : ℕ → ℕ
  alphabet_ge_two : 2 ≤ b
  provable_le_stmt : ∀ n, provableCount n ≤ stmtCount n
  stmt_le_alphabet : ∀ n, stmtCount n ≤ b ^ n
  provable_le_proofs : ∀ n, provableCount n ≤ b ^ (proofBound n)

namespace ProofDensitySpace

variable (P : ProofDensitySpace)

/-! ## §2. Basic Definitions -/

/-- The **unprovability gap** at length n. -/
def unprovableGap (P : ProofDensitySpace) (n : ℕ) : ℕ :=
  P.stmtCount n - P.provableCount n

/-- The cumulative statement count up to length n. -/
def cumulativeStmtCount (P : ProofDensitySpace) (n : ℕ) : ℕ :=
  ∑ i ∈ range (n + 1), P.stmtCount i

/-- The cumulative provable count up to length n. -/
def cumulativeProvableCount (P : ProofDensitySpace) (n : ℕ) : ℕ :=
  ∑ i ∈ range (n + 1), P.provableCount i

/-
Cumulative provable count is at most cumulative statement count.
-/

theorem phase_transition_at_threshold (nc : ℕ)
    (h : HasCompletenessThreshold P nc)
    (hpos : 0 < P.stmtCount (nc + 1)) :
    provabilityDensity P nc = 1 ∧ provabilityDensity P (nc + 1) < 1 := by
  constructor;
  · unfold ProofDensitySpace.provabilityDensity;
    have := h.1 nc le_rfl; aesop;
  · unfold ProofDensitySpace.provabilityDensity;
    rw [ if_neg hpos.ne', div_lt_one ] <;> norm_cast ; linarith [ h.2 ]

/-! ## §6. Dimension-Incompleteness Bridge -/

/-
**Dimension-Incompleteness Bridge**: If provable count at scale n
    is bounded by b^k with k < n, and the system is fully expressive,
    then the system is incomplete at scale n.
-/

theorem dimension_incompleteness_bridge (n k : ℕ) (hk : k < n)
    (hbound : P.provableCount n ≤ P.b ^ k)
    (hstmt : P.b ^ n ≤ P.stmtCount n) :
    P.provableCount n < P.stmtCount n := by
  exact lt_of_le_of_lt hbound ( lt_of_lt_of_le ( pow_lt_pow_right₀ ( by linarith [ P.alphabet_ge_two ] ) hk ) hstmt )

/-! ## §7. Gap Amplification -/

/-
**Gap Amplification**: If stmtCount grows by factor b while
    provableCount grows by at most factor b, the absolute gap is amplified.
-/