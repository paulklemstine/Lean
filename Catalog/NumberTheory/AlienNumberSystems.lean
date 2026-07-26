import Mathlib
import Applications.AlienNumberSystems.MixedRadix

/-!
# Alien Number Systems: Negative and Golden-Ratio Radices

This chapter studies two positional systems structurally unlike ordinary positive
integral bases. In base `-2`, a finite binary word is evaluated by Horner's rule.
In Fibonacci numeration, admissible words are encoded by Zeckendorf representations;
the identity `φ² = φ + 1` explains their connection with base `φ`.

The negative-base development proves existence and uniqueness from first principles.
It descends along `q = (r-n)/2`, where `r ∈ {0,1}` is the parity digit. Uniqueness
follows because parity forces the least significant digit and division by `-2` then
forces every remaining digit.

-- !-- Lab Notes -- !--
Hypothesis: Euclidean parity should provide a canonical descent for every integer in
base `-2`, while the golden-ratio relation should turn Zeckendorf's nonadjacent
Fibonacci indices into the combinatorial skeleton of phinary notation.

Experiment: the parity quotient was tested on positive and negative boundary cases.
In particular `-1` first moves to `1`, showing that plain absolute value is not a
decreasing measure. The interleaving measure `μ` below does decrease. Concrete examples
include `-13 = 110111₍₋₂₎` (least-significant digit first) and the Zeckendorf expansion
`100 = 89 + 8 + 3`.

Analysis: existence and uniqueness survive. The common structural pattern is a rewrite
system: parity removes one binary digit in base `-2`, whereas
`φⁿ + φⁿ⁺¹ = φⁿ⁺²` removes adjacent ones in base `φ`. This bridges integer division,
well-founded descent, algebraic number identities, and Fibonacci combinatorics.

Critique: the statement that every integer has a finite base-`φ` expansion using only
nonnegative powers is false; natural powers lie in `ℤ + ℤφ`, and negative powers are
needed for general integral phinary expansions. The exact verified boundary is that
every natural number has a unique nonconsecutive Fibonacci representation, together
with the algebraic carry law linking it to `φ`. Leading zeroes must also be excluded
for negabinary uniqueness; `Canonical` does so.

Synthesis: base `-2` is a complete canonical numeral system on `ℤ`; Zeckendorf
numeration is a complete canonical system on `ℕ`; and the golden-ratio carry identity
explains why the latter is the discrete shadow of an irrational radix. A broader
generalization is suggested by the catalog's mixed-radix evaluator: positive,
negative, and algebraic bases all use local normalization, but only positive radices
obtain uniqueness directly from positionwise bounds.
-- !-- End Lab Notes -- !--
-/

namespace AlienNumberSystems

/-- Integer value of one binary digit. -/
def digit (b : Bool) : ℤ := if b then 1 else 0

/-- Horner evaluation of a negabinary word, with the least-significant digit first. -/
def negaValue : List Bool → ℤ
  | [] => 0
  | b :: bs => digit b + (-2) * negaValue bs

@[simp] lemma negaValue_nil : negaValue [] = 0 := rfl

/-- A word is canonical when its most significant digit is not zero. -/
def Canonical (l : List Bool) : Prop := l.getLast? ≠ some false

/-- The signed interleaving measure `0,1,-1,2,-2,…` used for negabinary descent. -/
def negabinaryMeasure (n : ℤ) : ℕ :=
  (if 0 < n then 2 * n - 1 else -2 * n).toNat

lemma digit_injective {a b : Bool} (h : digit a = digit b) : a = b := by
  cases a <;> cases b <;> simp_all [digit]

/-- Reduction modulo two recovers the least-significant digit. -/
lemma negaValue_cons_emod (b : Bool) (bs : List Bool) :
    negaValue (b :: bs) % 2 = digit b := by
  by_cases hb : b = true <;> simp +decide [negaValue, digit, hb]

@[simp] lemma canonical_nil : Canonical [] := by simp [Canonical]

/-- Canonicality is inherited by tails. -/
lemma canonical_tail {a : Bool} {as : List Bool} (h : Canonical (a :: as)) :
    Canonical as := by
  cases as <;> simp_all +decide [Canonical]

/-- A canonical word evaluating to zero is empty. -/
lemma negaValue_eq_zero_of_canonical :
    ∀ {l : List Bool}, Canonical l → negaValue l = 0 → l = [] := by
  intro l
  induction' l with b l ih
  · tauto
  · grind +locals

/-- Canonical negabinary evaluation is injective. -/
theorem negabinary_unique :
    ∀ {as bs : List Bool}, Canonical as → Canonical bs →
      negaValue as = negaValue bs → as = bs := by
  intros as bs has hbs hval
  induction' as with a as ih generalizing bs <;>
    induction' bs with b bs ih' <;> simp_all +decide
  · grind +suggestions
  · grind +suggestions
  · grind +suggestions

/-- The parity quotient strictly decreases the signed interleaving measure. -/
lemma parity_measure_decreases {n : ℤ} (hn : n ≠ 0) :
    negabinaryMeasure ((n % 2 - n) / 2) < negabinaryMeasure n := by
  unfold negabinaryMeasure
  split_ifs <;> omega

/-- Every integer admits a finite canonical negabinary representation. -/
theorem negabinary_exists (n : ℤ) :
    ∃ ds : List Bool, Canonical ds ∧ negaValue ds = n := by
  induction' h : negabinaryMeasure n using Nat.strong_induction_on with N ih generalizing n
  by_cases hn : n = 0
  · exact ⟨[], by simp [hn]⟩
  · obtain ⟨ds, hds⟩ : ∃ ds : List Bool, Canonical ds ∧
        negaValue ds = (n % 2 - n) / 2 := by
      exact ih _ (by simpa [h] using parity_measure_decreases hn) _ rfl
    refine ⟨decide (n % 2 = 1) :: ds, ?_, ?_⟩ <;>
      simp_all +decide [Canonical, negaValue, digit]
    · cases ds <;> simp_all +decide [List.getLast?]
      omega
    · grind +locals

/-- Every integer has exactly one canonical base `-2` expansion. -/
theorem negabinary_existsUnique (n : ℤ) :
    ∃! ds : List Bool, Canonical ds ∧ negaValue ds = n := by
  obtain ⟨ds, hcanon, hval⟩ := negabinary_exists n
  use ds
  simp [hcanon, hval]
  exact fun ys hy hyval => negabinary_unique hy hcanon (hyval.trans hval.symm)

/-- The concrete word `110111` in base `-2` represents `-13` (digits listed least first). -/
example : negaValue [true, true, true, false, true, true] = -13 := by
  norm_num [negaValue, digit]

/-- This concrete word is canonical. -/
example : Canonical [true, true, true, false, true, true] := by
  norm_num [Canonical]

/-- The golden ratio's defining relation gives the phinary carry `011 → 100`. -/
theorem goldenRatio_carry (n : ℕ) :
    Real.goldenRatio ^ n + Real.goldenRatio ^ (n + 1) = Real.goldenRatio ^ (n + 2) := by
  grind +qlia

/-- Every natural number has a unique nonconsecutive Fibonacci representation. -/
theorem fibonacci_numeration_existsUnique (n : ℕ) :
    ∃! l : List ℕ, l.IsZeckendorfRep ∧ (l.map Nat.fib).sum = n := by
  refine ⟨Nat.zeckendorf n, ⟨Nat.isZeckendorfRep_zeckendorf n,
    Nat.sum_zeckendorf_fib n⟩, ?_⟩
  intro l hl
  rw [← hl.2]
  exact (Nat.zeckendorf_sum_fib hl.1).symm

/-- The Zeckendorf representation of `100` is the nonconsecutive sum `89 + 8 + 3`. -/
example : Nat.zeckendorf 100 = [11, 6, 4] := by
  norm_num [Nat.zeckendorf, Nat.greatestFib]

/-- Its represented value is exactly `100`. -/
example : ((Nat.zeckendorf 100).map Nat.fib).sum = 100 := by
  exact Nat.sum_zeckendorf_fib 100

/-- Uniform positive bases remain a specialization of the catalog's mixed-radix evaluator. -/
example : MixedRadix.mval (List.replicate 3 10) [3, 2, 7] = Nat.ofDigits 10 [3, 2, 7] := by
  exact MixedRadix.uniformBase.mval_replicate_eq_ofDigits 10 [3, 2, 7] 3 (by norm_num)

end AlienNumberSystems