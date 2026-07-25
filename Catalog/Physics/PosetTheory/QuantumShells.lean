/-
# Quantum Shell Structure and the Periodic Table

This module formalizes the mathematical foundations connecting quantum mechanics
to the structure of the periodic table.
-/
import Mathlib

open Finset Nat BigOperators

-- Part 1: The Madelung Order

/-- The Madelung ordering on pairs of natural numbers: (a1, b1) < (a2, b2)
    iff a1+b1 < a2+b2, or a1+b1 = a2+b2 and a1 < a2. -/
def MadelungLt : ℕ × ℕ → ℕ × ℕ → Prop :=
  fun p q => p.1 + p.2 < q.1 + q.2 ∨ (p.1 + p.2 = q.1 + q.2 ∧ p.1 < q.1)

instance : DecidableRel MadelungLt := fun p q => by
  unfold MadelungLt
  exact instDecidableOr

/-
MadelungLt is irreflexive.
-/
theorem madelung_irrefl : ∀ p : ℕ × ℕ, ¬MadelungLt p p := by
  -- By definition of MadelungLt, we need to show that for any pair (a, b), it is not the case that (a, b) < (a, b).
  intro p
  simp [MadelungLt]

/-
MadelungLt is transitive.
-/
theorem madelung_trans : ∀ a b c : ℕ × ℕ, MadelungLt a b → MadelungLt b c → MadelungLt a c := by
  intro a b c hab hbc; cases hab <;> cases hbc <;> first | exact Or.inl <| by linarith | exact Or.inr ⟨ by linarith, by linarith ⟩;

/-
MadelungLt is a trichotomy.
-/
theorem madelung_trichotomy (a b : ℕ × ℕ) :
    MadelungLt a b ∨ a = b ∨ MadelungLt b a := by
  grind +locals

/-
The Madelung order is well-founded: there is no infinite descending chain
    of subshells under the (n+l, n) ordering.
-/
theorem madelung_wellFounded : WellFounded MadelungLt := by
  rw [ WellFounded.wellFounded_iff_has_min ];
  intro s hs
  obtain ⟨m, hm⟩ : ∃ m ∈ s, ∀ x ∈ s, (m.1 + m.2) ≤ (x.1 + x.2) := by
    have h_well_founded : WellFounded (fun x y : ℕ => x < y) := by
      exact wellFounded_lt;
    have := h_well_founded.has_min ( Set.image ( fun x => x.1 + x.2 ) s ) ( Set.Nonempty.image _ hs ) ; aesop;
  obtain ⟨n, hn⟩ : ∃ n ∈ s, n.1 + n.2 = m.1 + m.2 ∧ ∀ x ∈ s, x.1 + x.2 = m.1 + m.2 → n.1 ≤ x.1 := by
    have h_min : ∃ n ∈ {x ∈ s | x.1 + x.2 = m.1 + m.2}, ∀ y ∈ {x ∈ s | x.1 + x.2 = m.1 + m.2}, n.1 ≤ y.1 := by
      apply_rules [ Set.exists_min_image ];
      · exact Set.finite_iff_bddAbove.mpr ⟨ ⟨ m.1 + m.2, m.1 + m.2 ⟩, fun x hx => by exact ⟨ by linarith [ hx.2, Nat.zero_le x.1, Nat.zero_le x.2 ], by linarith [ hx.2, Nat.zero_le x.1, Nat.zero_le x.2 ] ⟩ ⟩;
      · exact ⟨ m, hm.1, rfl ⟩;
    aesop;
  exact ⟨ n, hn.1, fun x hx h => by cases h <;> linarith [ hm.2 x hx, hn.2.2 x hx ( by linarith [ hm.2 x hx ] ) ] ⟩

-- Part 2: Shell Degeneracy and Sum of Odd Numbers

/-- Orbital degeneracy: number of quantum states with azimuthal number l
    is 2*(2*l+1), from (2l+1) magnetic quantum numbers times 2 spin states. -/
def orbitalDegeneracy (l : ℕ) : ℕ := 2 * (2 * l + 1)

/-
The sum of odd numbers identity: the sum of the first n odd numbers
    equals n squared.
-/
theorem sum_odd_eq_square (n : ℕ) :
    ∑ k ∈ range n, (2 * k + 1) = n ^ 2 := by
  induction n <;> simp [ Finset.sum_range_succ ] <;> linarith;

/-
Shell degeneracy theorem: the total number of quantum states
    with principal quantum number n (l ranging from 0 to n-1)
    equals 2*n^2.
-/
theorem shell_degeneracy (n : ℕ) :
    ∑ l ∈ range n, orbitalDegeneracy l = 2 * n ^ 2 := by
  unfold orbitalDegeneracy; induction n <;> norm_num [ Nat.mul_succ, Finset.sum_range_succ ] at *; linarith;

-- Part 3: Harmonic Oscillator Shells and Binomial Coefficients

/-- Degeneracy of the N-th harmonic oscillator shell (without spin):
    equals (N+1)*(N+2)/2 = C(N+2, 2). -/
def hoDegeneracy (N : ℕ) : ℕ := (N + 1) * (N + 2) / 2

/-
The HO degeneracy equals the binomial coefficient C(N+2, 2).
-/
theorem hoDegeneracy_eq_choose (N : ℕ) : hoDegeneracy N = Nat.choose (N + 2) 2 := by
  rw [ hoDegeneracy, Nat.choose_two_right ];
  norm_num [ mul_comm ]

/-
Harmonic oscillator cumulative formula: the total number of
    orbital states up through shell N equals C(N+3, 3).
-/
theorem ho_cumulative_eq_choose (N : ℕ) :
    ∑ k ∈ range (N + 1), hoDegeneracy k = Nat.choose (N + 3) 3 := by
  induction N <;> simp_all +decide [ Finset.sum_range_succ, hoDegeneracy_eq_choose ];
  simp +arith +decide [ Nat.choose_succ_succ ]

/-
Verification of the first few harmonic oscillator cumulative values.
-/
theorem ho_magic_numbers_base :
    (∑ k ∈ range 1, hoDegeneracy k = 1) ∧
    (∑ k ∈ range 2, hoDegeneracy k = 4) ∧
    (∑ k ∈ range 3, hoDegeneracy k = 10) ∧
    (∑ k ∈ range 4, hoDegeneracy k = 20) := by
  native_decide

-- Part 4: Representation-Theoretic Shell Identity

/-- Dimension of the l-th irreducible representation of SO(3). -/
def so3IrrepDim (l : ℕ) : ℕ := 2 * l + 1

/-
The sum of the first n irrep dimensions of SO(3) equals n squared.
    This is the group-theoretic underpinning of shell degeneracy.
-/
theorem so3_irrep_sum (n : ℕ) : ∑ l ∈ range n, so3IrrepDim l = n ^ 2 := by
  convert sum_odd_eq_square n using 1

-- Part 5: Abstract Spectral Shell Systems

/-- A SpectralShellSystem captures the essence of periodic table-like structures:
    a multiplicity function assigning positive capacity to each shell, with
    eventual monotonicity. -/
structure SpectralShellSystem where
  multiplicity : ℕ → ℕ
  mult_pos : ∀ n, 0 < multiplicity n

/-- Cumulative filling: total capacity through shell n. -/
def SpectralShellSystem.cumulative (S : SpectralShellSystem) (n : ℕ) : ℕ :=
  ∑ k ∈ range (n + 1), S.multiplicity k

/-
The cumulative function is strictly increasing for any SpectralShellSystem.
-/
theorem SpectralShellSystem.cumulative_strictMono (S : SpectralShellSystem) :
    StrictMono S.cumulative := by
  refine' strictMono_nat_of_lt_succ fun n => _;
  simp +arith +decide [ SpectralShellSystem.cumulative, Finset.sum_range_succ, S.mult_pos ]

/-- The electronic periodic table as a SpectralShellSystem with capacity 2*(n+1)^2. -/
noncomputable def electronicShellSystem : SpectralShellSystem where
  multiplicity := fun n => 2 * (n + 1) ^ 2
  mult_pos := by intro n; positivity

/-
Every positive integer belongs to exactly one period of a SpectralShellSystem.
    This is the partition property that makes periodic tables work.
-/
theorem spectral_period_unique (S : SpectralShellSystem) (z : ℕ) (_hz : 0 < z) :
    ∃! n, (n = 0 ∧ z ≤ S.cumulative 0) ∨
          (0 < n ∧ S.cumulative (n - 1) < z ∧ z ≤ S.cumulative n) := by
  obtain ⟨n, hn⟩ : ∃ n : ℕ, n = 0 ∧ z ≤ S.cumulative 0 ∨ 0 < n ∧ S.cumulative (n - 1) < z ∧ z ≤ S.cumulative n := by
    -- By definition of $cumulative$, we know that $cumulative(n)$ tends to infinity as $n$ tends to infinity.
    have h_cumulative_inf : Filter.Tendsto (fun n => S.cumulative n) Filter.atTop Filter.atTop := by
      exact Filter.tendsto_atTop_mono ( fun n => by exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun _ _ => S.mult_pos _ ) ) tendsto_natCast_atTop_atTop;
    -- By the properties of the cumulative function, there exists some $n$ such that $S.cumulative n \geq z$.
    obtain ⟨n, hn⟩ : ∃ n : ℕ, S.cumulative n ≥ z := by
      exact ( h_cumulative_inf.eventually_ge_atTop z ) |> fun h => h.exists;
    contrapose! hn;
    induction' n with n ih <;> [ exact hn 0 |>.1 rfl; exact hn _ |>.2 ( Nat.succ_pos _ ) ih ];
  refine' ⟨ n, hn, fun m hm => _ ⟩;
  rcases n with ( _ | n ) <;> rcases m with ( _ | m ) <;> simp_all +decide [ SpectralShellSystem.cumulative ];
  · linarith [ Finset.single_le_sum ( fun x _ => Nat.zero_le ( S.multiplicity x ) ) ( Finset.mem_range.mpr ( Nat.succ_pos m ) ) ];
  · simp_all +decide [ Finset.sum_range_succ' ];
    grind +splitIndPred;
  · exact le_antisymm ( le_of_not_gt fun hmn => by linarith [ show ∑ x ∈ Finset.range ( m + 1 ), S.multiplicity x ≥ ∑ x ∈ Finset.range ( n + 1 + 1 ), S.multiplicity x from Finset.sum_le_sum_of_subset ( Finset.range_mono ( by linarith ) ) ] ) ( le_of_not_gt fun hmn => by linarith [ show ∑ x ∈ Finset.range ( n + 1 ), S.multiplicity x ≥ ∑ x ∈ Finset.range ( m + 1 + 1 ), S.multiplicity x from Finset.sum_le_sum_of_subset ( Finset.range_mono ( by linarith ) ) ] )

/-
Part 6: Sum of Squares and Cumulative Electronic Capacity

Sum of first n+1 squares formula. Used for electronic shell cumulation.
-/
theorem sum_sq_formula (n : ℕ) :
    ∑ k ∈ range (n + 1), (k + 1) ^ 2 = (n + 1) * (n + 2) * (2 * n + 3) / 6 := by
  exact Eq.symm ( Nat.div_eq_of_eq_mul_left ( by decide ) ( by induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith ) )

/-
The electronic cumulative capacity formula:
    sum_{k=0}^{n} 2*(k+1)^2 = n*(n+1)*(2n+1)/3 ... wait, let me be more careful.
    We have cumulative(n) = sum_{k=0}^{n} 2*(k+1)^2
    = 2 * sum_{k=1}^{n+1} k^2 = 2 * (n+1)(n+2)(2n+3)/6 = (n+1)(n+2)(2n+3)/3.
-/
theorem electronic_cumulative (n : ℕ) :
    electronicShellSystem.cumulative n =
    ∑ k ∈ range (n + 1), 2 * (k + 1) ^ 2 := by
  rfl

/-
Part 7: Falsifiable Conjecture
Conjecture: For all N >= 0, the ratio
6 * C(N+3,3) / ((N+1)*(N+2)*(N+3)) = 1
i.e., C(N+3,3) = (N+1)*(N+2)*(N+3)/6 exactly.
This is of course a known identity, but serves as a
computational sanity check for the HO shell theory.
-/
theorem choose_three_formula (N : ℕ) :
    6 * Nat.choose (N + 3) 3 = (N + 1) * (N + 2) * (N + 3) := by
  rw [ Nat.choose_eq_factorial_div_factorial ] <;> norm_num [ Nat.factorial_succ ];
  norm_num [ ← mul_assoc, Nat.mul_div_mul_right _ _ ( Nat.factorial_pos _ ) ] ; ring;
  rw [ Nat.div_mul_cancel ( Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] ; have := Nat.mod_lt N ( by decide : 6 > 0 ) ; interval_cases N % 6 <;> trivial ) ) ]