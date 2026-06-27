/-
# The unit-shift totient equation φ(n) = φ(n+1): Fermat family, structure, and bounds

This file develops three groups of results about the **unit-shift totient equation**
`φ(n) = φ(n+1)` and its counting function

  `S₁^φ(x) = #{ n ≤ x : φ(n) = φ(n+1) }`   (`TotientShift.S1phi`, defined in
  `Bridges/TotientUnitShift.lean`).

It is organised so that *proven theorems* are cleanly separated from
*conditional* and *open* statements.

## 1. Fermat-prime family construction (PROVEN, and a PROVEN conditional)

Let `Fₖ = 2^(2^k) + 1` be the `k`-th Fermat number (`Nat.fermatNumber`).  If the
first `m` Fermat numbers `F₀, …, F_{m-1}` are **all prime** (Fermat primes), then

  `N_m = ∏_{k<m} Fₖ`   satisfies   `φ(N_m) = φ(N_m + 1)`.

The mechanism is the classical identity `∏_{k<m} Fₖ = 2^(2^m) - 1`
(`Nat.prod_fermatNumber`), so `N_m + 1 = 2^(2^m)` is a pure power of two, and both
totients equal `2^(2^m - 1)`:
* `φ(N_m + 1) = φ(2^(2^m)) = 2^(2^m - 1)`;
* `φ(N_m) = ∏_{k<m} (Fₖ - 1) = ∏_{k<m} 2^(2^k) = 2^(∑_{k<m} 2^k) = 2^(2^m - 1)`.

This is `fermatFamily_totient_eq`.  Consequences:
* `fermatFamily_solution_2pow32`: unconditional concrete solution
  `n = 2^32 - 1 = 4294967295` (from the five known Fermat primes `3,5,17,257,65537`).
* `infinite_solutions_of_infinitely_many_fermat_initial_segments`: the **PROVEN
  conditional** that *if* arbitrarily long initial segments `F₀,…,F_{m-1}` are all
  prime, *then* the solution set is infinite.  This is conditional because, beyond
  `F₀,…,F₄`, no Fermat number is known to be prime.

## 2. Structural characterisation (PROVEN)

* `coprime_self_succ`: `n` and `n+1` are always coprime.
* `totient_shift_value_even'`: for `n ≥ 2` the common value `φ(n)` is even.
* `succ_not_prime_of_shift`: for `n ≥ 2`, `n+1` is **not** prime.
* `not_both_prime_of_shift`: `n` and `n+1` are never both prime.

Note: the often-quoted "necessary condition" that a solution `n` must be **odd**
is *false*: `n = 104` is an even solution (`φ(104) = φ(105) = 48`), recorded as
`even_solution_counterexample`.  We therefore do **not** state `n` odd as a theorem.

## 3. Upper bound and open problems (STATED, NOT proven here)

* `S1phi_le_self` (re-exported): the trivial unconditional bound `S₁^φ(x) ≤ x` is
  proven in `Bridges/TotientUnitShift.lean`.
* `PomeranceUpperBound`: a `Prop`-valued *statement* of the deep theorem of
  Pomerance (1979), `S₁^φ(x) ≪ x·exp{-(1/2 - o(1))√(log x · log₂ x)}`.  Its full
  proof needs the anatomy of integers, smooth-number estimates and sieve methods,
  and is **not** carried out here; the definition records the precise claim.
* `ErdosLowerBound` / `ErdosInfinitude`: `Prop`-valued statements of the matching
  lower bound and of the infinitude of solutions.  These are **OPEN** (Erdős);
  they are stated, never asserted as theorems.
-/
import Mathlib
import Bridges.TotientUnitShift

open Nat Finset

namespace TotientShift

/-! ## 1. The Fermat-prime family construction -/

/-- `fermatProd m = ∏_{k<m} Fₖ` is the product of the first `m` Fermat numbers.
By `Nat.prod_fermatNumber` this equals `2^(2^m) - 1`. -/
def fermatProd (m : ℕ) : ℕ := ∏ k ∈ Finset.range m, Nat.fermatNumber k

/-- `fermatProd m + 1` is the power of two `2^(2^m)`. -/
theorem fermatProd_succ (m : ℕ) : fermatProd m + 1 = 2 ^ (2 ^ m) := by
  unfold fermatProd
  rw [Nat.prod_fermatNumber]
  have h : 1 ≤ 2 ^ (2 ^ m) := Nat.one_le_two_pow
  simp only [Nat.fermatNumber]
  omega

/-- Each Fermat number minus one is the corresponding power of two:
`Fₖ - 1 = 2^(2^k)`. -/
theorem fermatNumber_sub_one (k : ℕ) : Nat.fermatNumber k - 1 = 2 ^ (2 ^ k) := by
  simp [Nat.fermatNumber]

/-- The product of `(Fₖ - 1)` over the first `m` Fermat numbers is `2^(2^m - 1)`. -/
theorem prod_fermatNumber_sub_one (m : ℕ) :
    ∏ k ∈ Finset.range m, (Nat.fermatNumber k - 1) = 2 ^ (2 ^ m - 1) := by
  simp_rw [fermatNumber_sub_one]
  rw [Finset.prod_pow_eq_pow_sum]
  congr 1
  simpa using Nat.geomSum_eq (le_refl 2) m

/-- If `F₀, …, F_{m-1}` are all prime, the totient of their product factors as the
product of `(Fₖ - 1)`, since the Fermat numbers are pairwise coprime. -/
theorem totient_fermatProd (m : ℕ) (hp : ∀ k < m, (Nat.fermatNumber k).Prime) :
    Nat.totient (fermatProd m) = ∏ k ∈ Finset.range m, (Nat.fermatNumber k - 1) := by
  induction m with
  | zero => simp [fermatProd]
  | succ n ih =>
    have hcop : Nat.Coprime (∏ k ∈ range n, Nat.fermatNumber k) (Nat.fermatNumber n) := by
      apply Nat.Coprime.prod_left
      intro i hi
      exact Nat.coprime_fermatNumber_fermatNumber (by simp at hi; omega)
    have e1 : fermatProd (n + 1) =
        (∏ k ∈ range n, Nat.fermatNumber k) * Nat.fermatNumber n := by
      rw [fermatProd, Finset.prod_range_succ]
    rw [e1, Finset.prod_range_succ, Nat.totient_mul hcop,
        Nat.totient_prime (hp n (by omega))]
    congr 1
    exact ih (fun k hk => hp k (by omega))

/-- The totient of `2^(2^m)` is `2^(2^m - 1)`. -/
theorem totient_two_pow_pow (m : ℕ) :
    Nat.totient (2 ^ (2 ^ m)) = 2 ^ (2 ^ m - 1) := by
  rw [Nat.totient_prime_pow Nat.prime_two (pow_pos (by norm_num) m)]
  simp

/-- **Fermat-prime family construction.**  If the first `m` Fermat numbers are all
prime, then `n = ∏_{k<m} Fₖ` is a solution of the unit-shift totient equation
`φ(n) = φ(n+1)`. -/
theorem fermatFamily_totient_eq (m : ℕ) (hp : ∀ k < m, (Nat.fermatNumber k).Prime) :
    Nat.totient (fermatProd m) = Nat.totient (fermatProd m + 1) := by
  rw [totient_fermatProd m hp, prod_fermatNumber_sub_one, fermatProd_succ,
      totient_two_pow_pow]

/-- `fermatProd` is at least the index: `m ≤ fermatProd m`.  (Used to turn an
unbounded supply of indices into an unbounded supply of solutions.) -/
theorem le_fermatProd (m : ℕ) : m ≤ fermatProd m := by
  have hs := fermatProd_succ m
  have h2 : m + 1 ≤ 2 ^ (2 ^ m) := by
    calc m + 1 ≤ 2 ^ m := Nat.succ_le_of_lt Nat.lt_two_pow_self
      _ ≤ 2 ^ (2 ^ m) :=
        Nat.pow_le_pow_right (by norm_num) (Nat.le_of_lt Nat.lt_two_pow_self)
  omega

/-- **Conditional infinitude (PROVEN conditional).**  If arbitrarily long initial
segments of Fermat numbers are all prime, then the set of solutions of
`φ(n) = φ(n+1)` is infinite.  The hypothesis is exactly the (open) statement that
the initial-segment Fermat primality persists; the implication itself is proved. -/
theorem infinite_solutions_of_infinitely_many_fermat_initial_segments
    (h : ∀ M, ∃ m, M < m ∧ ∀ k < m, (Nat.fermatNumber k).Prime) :
    {n : ℕ | Nat.totient n = Nat.totient (n + 1)}.Infinite := by
  apply Set.infinite_of_forall_exists_gt
  intro M
  obtain ⟨m, hMm, hpr⟩ := h M
  refine ⟨fermatProd m, fermatFamily_totient_eq m hpr, ?_⟩
  calc M < m := hMm
    _ ≤ fermatProd m := le_fermatProd m

/-- **Unconditional concrete solution from the five known Fermat primes.**
Since `F₀,…,F₄ = 3,5,17,257,65537` are prime, `n = ∏_{k<5} Fₖ = 2^32 - 1 =
4294967295` satisfies `φ(n) = φ(n+1)` (both equal `2^31 = 2147483648`). -/
theorem fermatFamily_solution_2pow32 :
    Nat.totient 4294967295 = Nat.totient 4294967296 := by
  have hp : ∀ k < 5, (Nat.fermatNumber k).Prime := by
    intro k hk
    interval_cases k <;> (simp only [Nat.fermatNumber]; norm_num)
  have h := fermatFamily_totient_eq 5 hp
  have e : fermatProd 5 = 4294967295 := by decide
  rw [e] at h
  simpa using h

/-! ## 2. Structural characterisation of solutions -/

/-- Consecutive integers are coprime. -/
theorem coprime_self_succ (n : ℕ) : Nat.Coprime n (n + 1) := by
  simpa using Nat.coprime_succ_self_left (n := n)

/-- For `n ≥ 2`, the common totient value of a solution is even. -/
theorem totient_shift_value_even' {n : ℕ} (hn : 2 ≤ n)
    (h : Nat.totient n = Nat.totient (n + 1)) : Even (Nat.totient n) := by
  rw [h]; exact Nat.totient_even (by omega)

/-- For `n ≥ 2`, a solution forces `n+1` to be composite: if `n+1` were prime then
`φ(n+1) = n`, but `φ(n) ≤ n-1 < n`, a contradiction. -/
theorem succ_not_prime_of_shift {n : ℕ} (hn : 2 ≤ n)
    (h : Nat.totient n = Nat.totient (n + 1)) : ¬ (n + 1).Prime := by
  intro hp
  rw [Nat.totient_prime hp] at h
  have hlt := Nat.totient_lt n (by omega)
  omega

/-- `n` and `n+1` can never both be prime while solving `φ(n) = φ(n+1)`. -/
theorem not_both_prime_of_shift {n : ℕ} (hn : 2 ≤ n)
    (h : Nat.totient n = Nat.totient (n + 1)) : ¬ (n.Prime ∧ (n + 1).Prime) := by
  rintro ⟨_, hp1⟩
  exact succ_not_prime_of_shift hn h hp1

/-- The condition "a solution `n` must be odd" is **false**: `n = 104` is an even
solution, `φ(104) = φ(105) = 48`. -/
theorem even_solution_counterexample :
    Even 104 ∧ Nat.totient 104 = Nat.totient 105 :=
  ⟨by decide, ghp_104⟩

/-! ## 3. The deep upper bound and the open problems (statements only) -/

/-- **Statement** of Pomerance's upper bound (1979), refined by later authors:
`S₁^φ(x) ≪ x · exp{ -(1/2 - o(1)) · √(log x · log₂ x) }`.  Formally: there is a
function `ε(x) → 0` and a threshold `x₀` such that for all `x ≥ x₀`,
`S₁^φ(⌊x⌋) ≤ x · exp(-(1/2 - ε x)·√(log x · log(log x)))`.

This is a `Prop`-valued *definition recording the claim*; its proof requires the
anatomy of integers, smooth-number counts and sieve methods, and is **not** carried
out in this file. -/
def PomeranceUpperBound : Prop :=
  ∃ ε : ℝ → ℝ, Filter.Tendsto ε Filter.atTop (nhds 0) ∧ ∃ x₀ : ℝ, ∀ x : ℝ, x₀ ≤ x →
    (S1phi ⌊x⌋₊ : ℝ) ≤
      x * Real.exp (-(1 / 2 - ε x) * Real.sqrt (Real.log x * Real.log (Real.log x)))

/-- **Statement** of the conjectural matching lower bound (Erdős / Graham–Holt–
Pomerance): `S₁^φ(x) ≥ C · x · exp{ -(1/2 + o(1)) · √(log x · log₂ x) }`.  This is
**OPEN** and is only stated here, never proven. -/
def ErdosLowerBound : Prop :=
  ∃ ε : ℝ → ℝ, Filter.Tendsto ε Filter.atTop (nhds 0) ∧ ∃ C : ℝ, 0 < C ∧
    ∃ x₀ : ℝ, ∀ x : ℝ, x₀ ≤ x →
      C * x * Real.exp (-(1 / 2 + ε x) * Real.sqrt (Real.log x * Real.log (Real.log x)))
        ≤ (S1phi ⌊x⌋₊ : ℝ)

/-- **Statement** of Erdős's conjecture that the unit-shift totient equation has
infinitely many solutions.  This is **OPEN** and is only stated here. -/
def ErdosInfinitude : Prop :=
  {n : ℕ | Nat.totient n = Nat.totient (n + 1)}.Infinite

/-- Sanity check linking the two open statements: the conditional infinitude we
proved shows `ErdosInfinitude` would follow from persistent Fermat primality. -/
theorem erdosInfinitude_of_fermat_initial_segments
    (h : ∀ M, ∃ m, M < m ∧ ∀ k < m, (Nat.fermatNumber k).Prime) :
    ErdosInfinitude :=
  infinite_solutions_of_infinitely_many_fermat_initial_segments h

end TotientShift