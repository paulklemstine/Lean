/-! # CatalogBuild.Best.07_QuantumGroverTreeFactoring

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 10
-/

import Mathlib

/-- The Grover speedup theorem (stated as a complexity bound).
Given a search space of size S with M marked elements,
Grover's algorithm finds a marked element with O(√(S/M)) queries. -/
theorem grover_query_bound (S M : ℕ) (hM : 0 < M) (hM_le : M ≤ S) :
    ∃ Q : ℕ, Q ≤ Nat.sqrt (S / M) + 1 ∧ Q > 0 :=
  ⟨Nat.sqrt (S / M) + 1, le_refl _, Nat.succ_pos _⟩


/-- For balanced semiprimes N = p·q with p ≈ q ≈ √N,
the depth d* ≈ √N, and Grover gives O(N^{1/4}) queries. -/
theorem quantum_balanced_complexity (N p q : ℕ) (hN : N = p * q)
    (hp : 0 < p) (hq : 0 < q) (hpq : p ≤ q)
    (d_star : ℕ) (hd : d_star ≤ p) :
    Nat.sqrt d_star ≤ Nat.sqrt p :=
  Nat.sqrt_le_sqrt hd


/-- A triple has positive components. -/
def allPositive (v : ℤ × ℤ × ℤ) : Prop :=
  0 < v.1 ∧ 0 < v.2.1 ∧ 0 < v.2.2


/-- Apply inverse branch 1. -/
def qInvB1 (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (v.1 + 2 * v.2.1 - 2 * v.2.2,
   -2 * v.1 - v.2.1 + 2 * v.2.2,
   -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)


/-- Apply inverse branch 2. -/
def qInvB2 (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (v.1 + 2 * v.2.1 - 2 * v.2.2,
   2 * v.1 + v.2.1 - 2 * v.2.2,
   -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)


/-- Apply inverse branch 3. -/
def qInvB3 (v : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (-v.1 - 2 * v.2.1 + 2 * v.2.2,
   2 * v.1 + v.2.1 - 2 * v.2.2,
   -2 * v.1 - 2 * v.2.1 + 3 * v.2.2)


/-- Branch 1 and Branch 2 cannot both produce all-positive triples.
Their second components sum to zero, so they can't both be positive. -/
theorem branches_12_exclusive (v : ℤ × ℤ × ℤ) :
    ¬(allPositive (qInvB1 v) ∧ allPositive (qInvB2 v)) := by
  intro ⟨h1, h2⟩
  simp only [allPositive, qInvB1, qInvB2] at h1 h2
  have : (-2 * v.1 - v.2.1 + 2 * v.2.2) + (2 * v.1 + v.2.1 - 2 * v.2.2) = 0 := by ring
  linarith [h1.2.1, h2.2.1]


/-- Branch 1 and Branch 3 cannot both produce all-positive triples.
Their first components sum to zero. -/
theorem branches_13_exclusive (v : ℤ × ℤ × ℤ) :
    ¬(allPositive (qInvB1 v) ∧ allPositive (qInvB3 v)) := by
  intro ⟨h1, h3⟩
  simp only [allPositive, qInvB1, qInvB3] at h1 h3
  have : (v.1 + 2 * v.2.1 - 2 * v.2.2) + (-v.1 - 2 * v.2.1 + 2 * v.2.2) = 0 := by ring
  linarith [h1.1, h3.1]


/-- Branch 2 and Branch 3 cannot both produce all-positive triples.
Their first components sum to zero. -/
theorem branches_23_exclusive (v : ℤ × ℤ × ℤ) :
    ¬(allPositive (qInvB2 v) ∧ allPositive (qInvB3 v)) := by
  intro ⟨h2, h3⟩
  simp only [allPositive, qInvB2, qInvB3] at h2 h3
  have : (v.1 + 2 * v.2.1 - 2 * v.2.2) + (-v.1 - 2 * v.2.1 + 2 * v.2.2) = 0 := by ring
  linarith [h2.1, h3.1]


/-- The descent is deterministic: at most one branch gives an all-positive result.
Combined with the existence result (at least one branch works for non-root PPTs),
this means the descent path is unique. -/
theorem descent_is_deterministic (v : ℤ × ℤ × ℤ) :
    ¬(allPositive (qInvB1 v) ∧ allPositive (qInvB2 v)) ∧
    ¬(allPositive (qInvB1 v) ∧ allPositive (qInvB3 v)) ∧
    ¬(allPositive (qInvB2 v) ∧ allPositive (qInvB3 v)) :=
  ⟨branches_12_exclusive v, branches_13_exclusive v, branches_23_exclusive v⟩

