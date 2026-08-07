import Applications.AdjacentSumPolytopes.Recurrence

/-!
# Exponential growth of the adjacent-sum counts, and the two-state Fibonacci model

The recurrences of `Applications.AdjacentSumPolytopes.Recurrence` say *nothing* about
the size of the counts.  Here we bracket the growth of both parity classes by explicit
exponentials, using only entrywise nonnegativity of the transfer matrix — no
Perron–Frobenius theory is required:

`(⌊s/2⌋+1)^(d+1) ≤ #(cyclic points of length d+1) ≤ (s+1)^(d+1)`,
`(⌊s/2⌋+1)^(d+2) ≤ #(open points of length d+2)  ≤ (s+1)^(d+2)`.

The lower bound comes from the *core block* of states `a` with `2a ≤ s`: any two such
states are compatible, so the all-ones matrix on that block is entrywise below the
transfer matrix.  The upper bound compares with the all-ones matrix on all states.

Consequently the dominant real pole `1/λ_s` of the shared denominator satisfies
`1/(s+1) ≤ 1/λ_s ≤ 1/(⌊s/2⌋+1)`; in particular the counts grow strictly exponentially
as soon as `s ≥ 2` (`cycCount_two_pow_le`).

We also identify the two-state (`s = 1`) case completely: the open counts are Fibonacci
numbers and the cyclic counts are Lucas numbers.

-- !-- Lab Notes -- !--
* **Hypothesis.** The all-ones block on `{a : 2a ≤ s}` should already give the right
  order of growth; the true growth constant `λ_s` should sit strictly between
  `⌊s/2⌋+1` and `s+1` for `s ≥ 2`.
* **Experiment.** Cyclic counts for `s = 2` are `2, 6, 11, 26, 57, 129, 289, 650`;
  successive ratios `2.36, 2.26, 2.25, ...` approach the dominant root of
  `x³ − 2x² − x + 1`, which lies strictly between `⌊2/2⌋+1 = 2` and `3`.  For `s = 3`:
  `2, 10, 23, 70, 197, 571, 1640` with ratios approaching `≈ 2.87 ∈ (2, 4)`.
* **Analysis.** The block bound is tight in order of magnitude but not in constant;
  the ratio `λ_s/(⌊s/2⌋+1)` appears to converge, which we record as a conjecture.
* **Critique.** The bounds hold for every `s` and every `d` with no hypotheses, and are
  *strict* exponentials (base `≥ 2`) exactly when `s ≥ 2`; for `s = 0` both bounds
  collapse to `1`, correctly, since the only lattice point is the origin.
-/

namespace AdjSum

open Finset Matrix

/-! ## Monotonicity of powers of nonnegative matrices -/

/-- Entrywise monotonicity of matrix powers over `ℕ`. -/
theorem pow_entry_le_pow_entry {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℕ)
    (h : ∀ i j, A i j ≤ B i j) (d : ℕ) (i j : Fin n) : (A ^ d) i j ≤ (B ^ d) i j := by
  induction d generalizing i j with
  | zero => simp
  | succ d ih =>
      rw [pow_succ, pow_succ, Matrix.mul_apply, Matrix.mul_apply]
      exact Finset.sum_le_sum (fun k _ => Nat.mul_le_mul (ih i k) (h k j))

lemma trace_eq_sum {n : ℕ} (A : Matrix (Fin n) (Fin n) ℕ) : A.trace = ∑ i, A i i := rfl

/-! ## All-ones blocks -/

/-- The all-ones matrix supported on the block `H × H`. -/
def blockMat {n : ℕ} (H : Finset (Fin n)) : Matrix (Fin n) (Fin n) ℕ :=
  fun a b => if a ∈ H ∧ b ∈ H then 1 else 0

lemma blockMat_mul_self {n : ℕ} (H : Finset (Fin n)) :
    blockMat H * blockMat H = H.card • blockMat H := by
  ext a b
  rw [Matrix.mul_apply, Matrix.smul_apply, smul_eq_mul]
  by_cases ha : a ∈ H
  · by_cases hb : b ∈ H
    · have key : ∀ c : Fin n, blockMat H a c * blockMat H c b = if c ∈ H then 1 else 0 := by
        intro c; by_cases hc : c ∈ H <;> simp [blockMat, ha, hb, hc]
      simp_rw [key]
      rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, smul_eq_mul, mul_one]
      simp [blockMat, ha, hb]
    · simp [blockMat, hb]
  · simp [blockMat, ha]

/-- Powers of an all-ones block: `Bᵈ⁺¹ = |H|ᵈ • B`. -/
theorem blockMat_pow {n : ℕ} (H : Finset (Fin n)) (d : ℕ) :
    blockMat H ^ (d + 1) = (H.card ^ d) • blockMat H := by
  induction d with
  | zero => simp
  | succ d ih => rw [pow_succ, ih, Matrix.smul_mul, blockMat_mul_self, smul_smul, pow_succ]

theorem trace_blockMat_pow {n : ℕ} (H : Finset (Fin n)) (d : ℕ) :
    Matrix.trace (blockMat H ^ (d + 1)) = H.card ^ (d + 1) := by
  rw [blockMat_pow, Matrix.trace_smul, smul_eq_mul, pow_succ]
  congr 1
  rw [trace_eq_sum]
  have key : ∀ a : Fin n, blockMat H a a = if a ∈ H then 1 else 0 := by
    intro a; by_cases ha : a ∈ H <;> simp [blockMat, ha]
  simp_rw [key]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, smul_eq_mul, mul_one]

theorem sum_blockMat_pow {n : ℕ} (H : Finset (Fin n)) (d : ℕ) :
    ∑ a, ∑ b, (blockMat H ^ (d + 1)) a b = H.card ^ (d + 2) := by
  rw [blockMat_pow]
  have hrow : ∀ a : Fin n, ∑ b, ((H.card ^ d) • blockMat H) a b
      = if a ∈ H then H.card ^ d * H.card else 0 := by
    intro a
    by_cases ha : a ∈ H
    · have key : ∀ b : Fin n, ((H.card ^ d) • blockMat H) a b
          = if b ∈ H then H.card ^ d else 0 := by
        intro b; by_cases hb : b ∈ H <;> simp [blockMat, ha, hb]
      simp_rw [key]
      rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, smul_eq_mul, if_pos ha,
        mul_comm]
    · have key : ∀ b : Fin n, ((H.card ^ d) • blockMat H) a b = 0 := by
        intro b; simp [blockMat, ha]
      simp_rw [key]
      simp [ha]
  simp_rw [hrow]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, smul_eq_mul]
  ring

/-! ## The core block of mutually compatible states -/

/-- The set of states `a` with `2a ≤ s`: any two of them are compatible. -/
def coreStates (s : ℕ) : Finset (Fin (s + 1)) :=
  Finset.univ.filter (fun a : Fin (s + 1) => 2 * (a : ℕ) ≤ s)

theorem card_coreStates (s : ℕ) : (coreStates s).card = s / 2 + 1 := by
  rw [coreStates, ← Finset.card_range (s / 2 + 1)]
  refine Finset.card_nbij' (fun a => (a : ℕ)) (fun i => (⟨min i s, by omega⟩ : Fin (s + 1)))
    ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.coe_filter, Set.mem_setOf_eq] at ha
    simp only [Finset.coe_range, Set.mem_Iio]
    omega
  · intro i hi
    simp only [Finset.coe_range, Set.mem_Iio] at hi
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and]
    omega
  · intro a ha
    simp only [Finset.coe_filter, Set.mem_setOf_eq] at ha
    refine Fin.ext ?_
    have := a.isLt
    simp only
    omega
  · intro i hi
    simp only [Finset.coe_range, Set.mem_Iio] at hi
    simp only
    omega

theorem blockMat_coreStates_le (s : ℕ) (a b : Fin (s + 1)) :
    blockMat (coreStates s) a b ≤ adjMat s a b := by
  by_cases h : a ∈ coreStates s ∧ b ∈ coreStates s
  · obtain ⟨ha, hb⟩ := h
    simp only [coreStates, Finset.mem_filter, Finset.mem_univ, true_and] at ha hb
    have hab : (a : ℕ) + (b : ℕ) ≤ s := by omega
    rw [adjMat_apply, if_pos hab]
    simp only [blockMat]
    split <;> simp
  · simp [blockMat, h]

theorem adjMat_le_blockMat_univ (s : ℕ) (a b : Fin (s + 1)) :
    adjMat s a b ≤ blockMat (Finset.univ : Finset (Fin (s + 1))) a b := by
  simp only [blockMat, adjMat_apply, Finset.mem_univ, and_self, if_true]
  split <;> simp

/-! ## Exponential bounds -/

/-- **Lower exponential bound, cyclic class.** -/
theorem cycCount_lower (s d : ℕ) : (s / 2 + 1) ^ (d + 1) ≤ cycCount s d := by
  have h1 : (s / 2 + 1) ^ (d + 1) = Matrix.trace (blockMat (coreStates s) ^ (d + 1)) := by
    rw [trace_blockMat_pow, card_coreStates]
  rw [cycCount, card_cycSet, h1, trace_eq_sum, trace_eq_sum]
  refine Finset.sum_le_sum (fun a _ => ?_)
  exact pow_entry_le_pow_entry _ _ (blockMat_coreStates_le s) (d + 1) a a

/-- **Upper exponential bound, cyclic class.** -/
theorem cycCount_upper (s d : ℕ) : cycCount s d ≤ (s + 1) ^ (d + 1) := by
  have h1 : ((s : ℕ) + 1) ^ (d + 1)
      = Matrix.trace (blockMat (Finset.univ : Finset (Fin (s + 1))) ^ (d + 1)) := by
    rw [trace_blockMat_pow, Finset.card_univ, Fintype.card_fin]
  rw [cycCount, card_cycSet, h1, trace_eq_sum, trace_eq_sum]
  refine Finset.sum_le_sum (fun a _ => ?_)
  exact pow_entry_le_pow_entry _ _ (adjMat_le_blockMat_univ s) (d + 1) a a

/-- **Lower exponential bound, open class.** -/
theorem openCount_lower (s d : ℕ) : (s / 2 + 1) ^ (d + 2) ≤ openCount s (d + 1) := by
  have h1 : (s / 2 + 1) ^ (d + 2) = ∑ a, ∑ b, (blockMat (coreStates s) ^ (d + 1)) a b := by
    rw [sum_blockMat_pow, card_coreStates]
  rw [openCount, card_openSet, h1]
  refine Finset.sum_le_sum (fun a _ => Finset.sum_le_sum (fun b _ => ?_))
  exact pow_entry_le_pow_entry _ _ (blockMat_coreStates_le s) (d + 1) a b

/-- **Upper exponential bound, open class.** -/
theorem openCount_upper (s d : ℕ) : openCount s (d + 1) ≤ (s + 1) ^ (d + 2) := by
  have h1 : ((s : ℕ) + 1) ^ (d + 2)
      = ∑ a, ∑ b, (blockMat (Finset.univ : Finset (Fin (s + 1))) ^ (d + 1)) a b := by
    rw [sum_blockMat_pow, Finset.card_univ, Fintype.card_fin]
  rw [openCount, card_openSet, h1]
  refine Finset.sum_le_sum (fun a _ => Finset.sum_le_sum (fun b _ => ?_))
  exact pow_entry_le_pow_entry _ _ (adjMat_le_blockMat_univ s) (d + 1) a b

/-- Strict exponential growth for `s ≥ 2`: the cyclic counts are at least `2^(d+1)`. -/
theorem cycCount_two_pow_le (s d : ℕ) (hs : 2 ≤ s) : 2 ^ (d + 1) ≤ cycCount s d :=
  le_trans (Nat.pow_le_pow_left (by omega) (d + 1)) (cycCount_lower s d)

/-! ## The two-state model: Fibonacci and Lucas numbers -/

theorem adjMat_one_eq : adjMat 1 = !![1, 1; 1, 0] := by
  ext a b
  fin_cases a <;> fin_cases b <;> simp [adjMat]

/-- The powers of the two-state transfer matrix are the Fibonacci matrices. -/
theorem adjMat_one_pow (n : ℕ) :
    adjMat 1 ^ (n + 1) = !![Nat.fib (n + 2), Nat.fib (n + 1); Nat.fib (n + 1), Nat.fib n] := by
  induction n with
  | zero => rw [pow_one, adjMat_one_eq]; norm_num
  | succ n ih =>
      rw [pow_succ, ih, adjMat_one_eq]
      ext i j
      fin_cases i <;> fin_cases j <;>
        simp [Matrix.mul_apply, Fin.sum_univ_two, Nat.fib_add_two] <;> ring

/-- **Two-state cyclic counts are Lucas numbers**: `#cyclic = F(d+2) + F(d)`. -/
theorem cycCount_one (d : ℕ) : cycCount 1 d = Nat.fib (d + 2) + Nat.fib d := by
  rw [cycCount, card_cycSet, adjMat_one_pow d, Matrix.trace_fin_two]
  simp

/-- **Two-state open counts are Fibonacci numbers**: `#open = F(d+3)`. -/
theorem openCount_one (d : ℕ) : openCount 1 d = Nat.fib (d + 3) := by
  rw [openCount, card_openSet]
  match d with
  | 0 =>
      simp only [pow_zero, Matrix.one_apply]
      decide
  | (n + 1) =>
      rw [adjMat_one_pow n]
      have e1 : Nat.fib (n + 4) = Nat.fib (n + 2) + Nat.fib (n + 3) := by
        rw [show n + 4 = (n + 2) + 2 from by omega]; exact Nat.fib_add_two
      have e2 : Nat.fib (n + 3) = Nat.fib (n + 1) + Nat.fib (n + 2) := by
        rw [show n + 3 = (n + 1) + 2 from by omega]; exact Nat.fib_add_two
      have e3 : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
      rw [show n + 1 + 3 = n + 4 from by omega]
      simp [Fin.sum_univ_two]
      omega

end AdjSum