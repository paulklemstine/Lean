/-
  # The Periodic Table as Spectral Theory

  We formalize the mathematical structure underlying the periodic table of elements,
  showing that the shell structure of quantum mechanics (eigenvalue degeneracies)
  determines the architecture of the periodic table.

  ## Key Results

  1. The degeneracy of quantum shell n is 2n², proved via the identity Σ(2l+1) = n²
  2. The Aufbau (n+l) filling rule defines a well-ordering on quantum subshells
  3. Period lengths in the periodic table are exactly twice the squares
  4. Nuclear magic numbers arise from harmonic oscillator shell closures
  5. Abstract spectral periodic table framework with monotonicity
-/

import Mathlib

open Finset

/-! ## Section 1: Quantum Shell Degeneracy

The angular momentum states in quantum shell n (principal quantum number)
have total degeneracy 2n². This follows from:
- l ranges from 0 to n-1 (angular momentum quantum number)
- Each l-subshell has (2l+1) magnetic substates
- Spin doubles the count
- Sum: 2 * Σ_{l=0}^{n-1} (2l+1) = 2n²
-/

/-- The number of magnetic substates for angular momentum quantum number l. -/
def subshellDegeneracy (l : ℕ) : ℕ := 2 * l + 1

/-- Total orbital degeneracy of shell n: sum of (2l+1) for l = 0..n-1. -/
def orbitalDegeneracy (n : ℕ) : ℕ := ∑ l ∈ range n, subshellDegeneracy l

/-- Total degeneracy including spin: 2 × orbitalDegeneracy. -/
def shellDegeneracy (n : ℕ) : ℕ := 2 * orbitalDegeneracy n

/-
The sum of the first n odd numbers equals n².
    This is the mathematical foundation of shell degeneracy.
-/
theorem sum_odd_eq_sq (n : ℕ) : ∑ k ∈ range n, (2 * k + 1) = n ^ 2 := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-- Orbital degeneracy of shell n equals n². -/
theorem orbitalDegeneracy_eq_sq (n : ℕ) : orbitalDegeneracy n = n ^ 2 :=
  sum_odd_eq_sq n

/-- The fundamental shell degeneracy theorem:
    Shell n has exactly 2n² quantum states (including spin). -/
theorem shellDegeneracy_eq (n : ℕ) : shellDegeneracy n = 2 * n ^ 2 := by
  unfold shellDegeneracy
  rw [orbitalDegeneracy_eq_sq]

/-! ## Section 2: Aufbau Principle and Madelung's Rule

The Aufbau principle states that electron subshells fill in order of increasing
(n+l), with ties broken by increasing n. This defines a total ordering on
quantum number pairs (n, l) where 0 ≤ l < n.
-/

/-- A quantum subshell is specified by principal quantum number n and
    angular momentum quantum number l, with the constraint l < n and n ≥ 1. -/
structure Subshell where
  n : ℕ
  l : ℕ
  hn : 0 < n
  hl : l < n

/-- The Madelung number n + l, which determines the filling order. -/
def Subshell.madelung (s : Subshell) : ℕ := s.n + s.l

/-- The Madelung ordering: compare by (n+l), then by n. -/
def Subshell.madelungLt (s t : Subshell) : Prop :=
  s.madelung < t.madelung ∨ (s.madelung = t.madelung ∧ s.n < t.n)

/-- Number of electrons in a subshell (n, l): each has 2(2l+1) states. -/
def Subshell.capacity (s : Subshell) : ℕ := 2 * (2 * s.l + 1)

/-
The Madelung ordering is irreflexive.
-/
theorem madelungLt_irrefl (s : Subshell) : ¬ s.madelungLt s := by
  exact fun h => by cases h <;> linarith;

/-
The Madelung ordering is transitive.
-/
theorem madelungLt_trans (a b c : Subshell) :
    a.madelungLt b → b.madelungLt c → a.madelungLt c := by
  grind +locals

/-! ## Section 3: Nuclear Magic Numbers

In nuclear physics, magic numbers (2, 8, 20, 28, 50, 82, 126) represent
nucleon counts at which nuclei are exceptionally stable. These arise from
the harmonic oscillator shell model with spin-orbit coupling.

The 3D harmonic oscillator has shells labeled by N,
with degeneracy (N+1)(N+2) (with spin).
-/

/-- Harmonic oscillator shell degeneracy (with nucleon spin) for shell N. -/
def HOShellDegeneracy (N : ℕ) : ℕ := (N + 1) * (N + 2)

/-- Cumulative nucleon count for harmonic oscillator shells 0..N. -/
def cumulativeHO (N : ℕ) : ℕ := ∑ k ∈ range (N + 1), HOShellDegeneracy k

/-
Closed-form for cumulative harmonic oscillator shell filling:
    Σ_{k=0}^{N} (k+1)(k+2) = (N+1)(N+2)(N+3)/3
-/
theorem cumulativeHO_formula (N : ℕ) :
    3 * cumulativeHO N = (N + 1) * (N + 2) * (N + 3) := by
  unfold cumulativeHO;
  induction N <;> simp_all +decide [ Finset.sum_range_succ, HOShellDegeneracy ] ; linarith

/-
The first three harmonic oscillator magic numbers match nuclear magic numbers
    (before spin-orbit effects become significant at N=3).
-/
theorem ho_matches_magic_first_three :
    [cumulativeHO 0, cumulativeHO 1, cumulativeHO 2] = [2, 8, 20] := by
  native_decide

/-! ## Section 4: Spectral Shell Theory -/

/-- A shell spectrum is a function assigning a positive degeneracy to each shell index. -/
structure ShellSpectrum where
  degeneracy : ℕ → ℕ
  pos : ∀ n, 0 < n → 0 < degeneracy n

/-- The hydrogen-like shell spectrum with degeneracy 2n². -/
noncomputable def hydrogenSpectrum : ShellSpectrum where
  degeneracy := fun n => 2 * n ^ 2
  pos := fun n hn => by positivity

/-- The harmonic oscillator shell spectrum with degeneracy (N+1)(N+2). -/
def harmonicSpectrum : ShellSpectrum where
  degeneracy := HOShellDegeneracy
  pos := fun n hn => by unfold HOShellDegeneracy; positivity

/-- The periodic table induced by a shell spectrum. -/
def ShellSpectrum.cumulativeFilling (S : ShellSpectrum) (N : ℕ) : ℕ :=
  ∑ k ∈ range (N + 1), S.degeneracy k

/-- An element Z is a "noble gas" in spectrum S if Z equals the cumulative
    filling at some shell boundary. -/
def ShellSpectrum.isNobleGas (S : ShellSpectrum) (Z : ℕ) : Prop :=
  ∃ N, S.cumulativeFilling N = Z

/-
Sum of squares formula: 6 * Σ_{k=0}^{n} k² = n(n+1)(2n+1)
-/
theorem sum_sq_formula (n : ℕ) :
    6 * ∑ k ∈ range (n + 1), k ^ 2 = n * (n + 1) * (2 * n + 1) := by
  induction n <;> norm_num [ Finset.sum_range_succ ] at * ; linarith

/-! ## Section 5: Period Structure

The period lengths of the periodic table follow the pattern
2, 8, 8, 18, 18, 32, 32 — each value appears twice (except the first).
Each period length is of the form 2n². -/

def periodicTablePeriodLengths : List ℕ := [2, 8, 8, 18, 18, 32, 32]

/-
Each period length is of the form 2n² for some n.
-/
theorem period_lengths_are_twice_squares :
    ∀ p, p ∈ periodicTablePeriodLengths → ∃ n, p = 2 * n ^ 2 := by
  -- We can verify each element in the list directly.
  intro p hp
  fin_cases hp <;> [exact ⟨1, rfl⟩; exact ⟨2, rfl⟩; exact ⟨2, rfl⟩; exact ⟨3, rfl⟩; exact ⟨3, rfl⟩; exact ⟨4, rfl⟩; exact ⟨4, rfl⟩]

/-- Noble gas atomic numbers are cumulative sums of period lengths. -/
def nobleGasNumbers : List ℕ := [2, 10, 18, 36, 54, 86, 118]

/-
The noble gas numbers match the partial sums of period lengths.
-/
theorem noble_gas_are_partial_sums :
    nobleGasNumbers = (List.scanl (· + ·) 0 periodicTablePeriodLengths).tail := by
  native_decide +revert

/-! ## Section 6: The Spectral Periodicity Theorem

The "periodicity" of the periodic table is NOT periodic in the usual sense.
The period lengths grow. We prove the pairing property. -/

/-- The k-th period length in the idealized periodic table (Madelung rule).
    Period 0 has length 2·1²=2, periods 1,2 have length 2·2²=8, etc. -/
def idealPeriodLength (k : ℕ) : ℕ := 2 * ((k + 2) / 2) ^ 2

/-
Period lengths repeat in pairs: period 2k and 2k+1 have the same length.
    This is the mathematical origin of the "double periodicity" of the periodic table.
-/
theorem period_pairing (k : ℕ) :
    idealPeriodLength (2 * k) = idealPeriodLength (2 * k + 1) := by
  unfold idealPeriodLength; norm_num [ Nat.add_div ] ;

/-
Each pair of periods has length 2(k+1)².
-/
theorem period_pair_value (k : ℕ) :
    idealPeriodLength (2 * k) = 2 * (k + 1) ^ 2 := by
  convert period_pairing k using 1 ; ring;
  unfold idealPeriodLength; norm_num [ Nat.add_div ] ; ring;

/-! ## Section 7: Spectral Periodic Table — Abstract Framework -/

/-- A spectral periodic table: eigenvalue multiplicities determine element grouping. -/
structure SpectralPeriodicTable where
  multiplicity : ℕ → ℕ
  cumulative : ℕ → ℕ
  cumulative_eq : ∀ n, cumulative n = ∑ k ∈ range (n + 1), multiplicity k
  mult_pos : ∀ n, 0 < n → 0 < multiplicity n

/-
Cumulative filling grows: adding a positive-multiplicity shell increases the count.
-/
theorem spectral_cumulative_growth (T : SpectralPeriodicTable) (n : ℕ) (hn : 0 < n) :
    T.cumulative (n - 1) < T.cumulative n := by
  rcases n <;> simp_all +decide [ T.cumulative_eq ];
  simp +arith +decide [ Finset.sum_range_succ, T.mult_pos ]