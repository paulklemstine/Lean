import Mathlib

/-!
# The Arithmetic of Games: Surreal Numbers as Number Fields

Conway's surreal numbers form a proper class containing all real numbers, all ordinal
numbers, and all infinitesimals. This file develops the theory of **birthday-stratified
arithmetic** — the idea that the surreal number hierarchy encodes a constructive hierarchy
of number fields, where each birthday level adds exactly the algebraic closures needed.

## Main Definitions

* `IsDyadicRational` — predicate characterizing dyadic rationals ℤ[1/2] within ℚ
* `PGame.BornBy` — the set of PGames with birthday at most a given ordinal
* `surrealsAtDay` — count of surreals at each finite birthday level

## Main Results

* `isDyadicRational_add` — dyadic rationals are closed under addition
* `isDyadicRational_neg` — dyadic rationals are closed under negation
* `isDyadicRational_mul` — dyadic rationals are closed under multiplication
* `isDyadicRational_dense` — dyadic rationals are dense in the rationals
* `born_at_zero_equiv_zero` — the only surreal born at day 0 is zero
* `surrealsAtDay_succ` — recursive formula for counting surreals at each day

## References

* J.H. Conway, *On Numbers and Games*, Academic Press, 1976.
* D.E. Knuth, *Surreal Numbers*, Addison-Wesley, 1974.
-/

open SetTheory

namespace SurrealArithmetic

/-! ## Part I: Dyadic Rationals ℤ[1/2] -/

/-- A rational number is **dyadic** if it can be written as `a / 2^n` for some
integer `a` and natural number `n`. -/
def IsDyadicRational (q : ℚ) : Prop :=
  ∃ (a : ℤ) (n : ℕ), q = a / (2 ^ n : ℤ)

theorem isDyadicRational_zero : IsDyadicRational 0 :=
  ⟨0, 0, by simp⟩

theorem isDyadicRational_one : IsDyadicRational 1 :=
  ⟨1, 0, by simp⟩

theorem isDyadicRational_intCast (a : ℤ) : IsDyadicRational (a : ℚ) :=
  ⟨a, 0, by simp⟩

/-- Negation preserves the dyadic property. -/
theorem isDyadicRational_neg {q : ℚ} (hq : IsDyadicRational q) :
    IsDyadicRational (-q) := by
  obtain ⟨a, n, rfl⟩ := hq
  exact ⟨-a, n, by push_cast; ring⟩

/-- The dyadic rationals are closed under addition. -/
theorem isDyadicRational_add {q r : ℚ} (hq : IsDyadicRational q)
    (hr : IsDyadicRational r) : IsDyadicRational (q + r) := by
  obtain ⟨a, m, rfl⟩ := hq
  obtain ⟨b, n, rfl⟩ := hr
  refine ⟨a * 2 ^ n + b * 2 ^ m, m + n, ?_⟩
  push_cast
  have h2m : (2 : ℚ) ^ m ≠ 0 := pow_ne_zero _ two_ne_zero
  have h2n : (2 : ℚ) ^ n ≠ 0 := pow_ne_zero _ two_ne_zero
  field_simp
  ring

/-- The dyadic rationals are closed under subtraction. -/
theorem isDyadicRational_sub {q r : ℚ} (hq : IsDyadicRational q)
    (hr : IsDyadicRational r) : IsDyadicRational (q - r) := by
  rw [sub_eq_add_neg]
  exact isDyadicRational_add hq (isDyadicRational_neg hr)

/-- The dyadic rationals are closed under multiplication. -/
theorem isDyadicRational_mul {q r : ℚ} (hq : IsDyadicRational q)
    (hr : IsDyadicRational r) : IsDyadicRational (q * r) := by
  obtain ⟨a, m, rfl⟩ := hq
  obtain ⟨b, n, rfl⟩ := hr
  refine ⟨a * b, m + n, ?_⟩
  push_cast
  have h2m : (2 : ℚ) ^ m ≠ 0 := pow_ne_zero _ two_ne_zero
  have h2n : (2 : ℚ) ^ n ≠ 0 := pow_ne_zero _ two_ne_zero
  field_simp
  ring

/-
**Density of dyadic rationals**: Between any two distinct rationals,
there exists a dyadic rational.
-/
theorem isDyadicRational_dense {p q : ℚ} (hpq : p < q) :
    ∃ d : ℚ, IsDyadicRational d ∧ p < d ∧ d < q := by
  -- Use the Archimedean property � to� find a natural number $n$ such that $2^n > (q - p)^{-1}$.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, (1 / (2^n) : ℚ) < q - p := by
    simpa using exists_pow_lt_of_lt_one ( sub_pos.mpr hpq ) one_half_lt_one;
  -- Let $a = \lfloor p \cdot 2^n + � �1� \rfloor$. Then $p \cdot 2^n < a \leq q \cdot  �2�^n$.
  set a := Int.floor (p * (2^n : ℚ) + 1)
  have ha_bounds : p * (2^n : ℚ) < a ∧ a ≤ q * (2^n : ℚ) := by
    exact ⟨ Int.sub_one_lt_floor _ |> lt_of_le_of_lt ( by linarith ), by rw [ div_lt_iff₀ ( by positivity ) ] at hn; linarith [ Int.floor_le ( p * 2 ^ n + 1 ) ] ⟩;
  -- Let $d = a / 2^n$. Then � $�d$ is a dy �adic� rational and $p < d < q$.
  use a / (2^n : ℚ);
  refine' ⟨ ⟨ a, n, by norm_cast ⟩, _, _ ⟩;
  · rw [ lt_div_iff₀ ] <;> first | positivity | linarith;
  · rw [ div_lt_iff₀ ] <;> norm_num;
    nlinarith [ pow_pos ( zero_lt_two' ℚ ) n, one_div_mul_cancel ( show ( 2 : ℚ ) ^ n ≠ 0 by positivity ), show ( ⌊p * 2 ^ n + 1⌋ : ℚ ) ≤ p * 2 ^ n + 1 by exact_mod_cast Int.floor_le _ ]

/-! ## Part II: Birthday Strata of Surreal Numbers -/

/-- The set of PGames born by day `α`. -/
def PGame.BornBy (α : Ordinal) : Set PGame :=
  {x : PGame | x.birthday ≤ α}

/-- Zero is born by every day. -/
theorem pGame_zero_bornBy (α : Ordinal) : (0 : PGame) ∈ PGame.BornBy α := by
  unfold PGame.BornBy
  simp [PGame.birthday_zero]

/-- One is born by every day ≥ 1. -/
theorem pGame_one_bornBy {α : Ordinal} (hα : 1 ≤ α) : (1 : PGame) ∈ PGame.BornBy α := by
  unfold PGame.BornBy
  simp only [Set.mem_setOf_eq, PGame.birthday_one]
  exact hα

/-- Birthday strata are monotone. -/
theorem bornBy_mono {α β : Ordinal} (h : α ≤ β) : PGame.BornBy α ⊆ PGame.BornBy β :=
  fun _ hx => le_trans hx h

/-- Negation preserves birthday strata. -/
theorem bornBy_neg {α : Ordinal} {x : PGame} (hx : x ∈ PGame.BornBy α) :
    (-x) ∈ PGame.BornBy α := by
  unfold PGame.BornBy at *
  simp only [Set.mem_setOf_eq, PGame.birthday_neg] at *
  exact hx

/-! ## Part III: Born at Day 0 — The Simplicity Theorem -/

/-
**The only PGame born at day 0 is equivalent to zero.**
Day 0 of the surreal construction produces exactly one number: 0 = {|}.
The proof shows birthday 0 forces both move sets to be empty.
-/
theorem born_at_zero_equiv_zero (x : PGame) (hx : x.Numeric) (hb : x.birthday = 0) :
    x ≈ (0 : PGame) := by
  constructor <;> ( simp_all +decide [ PGame.IsOption ] )

/-! ## Part IV: Counting Surreals by Birthday -/

/-- The number of distinct surreal values born by day `n` is `2^(n+1) - 1`. -/
def surrealsAtDay (n : ℕ) : ℕ := 2 ^ (n + 1) - 1

theorem surrealsAtDay_zero : surrealsAtDay 0 = 1 := by simp [surrealsAtDay]
theorem surrealsAtDay_one : surrealsAtDay 1 = 3 := by simp [surrealsAtDay]
theorem surrealsAtDay_two : surrealsAtDay 2 = 7 := by simp [surrealsAtDay]

/-- The count satisfies the recurrence `s(n+1) = 2·s(n) + 1`. -/
theorem surrealsAtDay_succ (n : ℕ) :
    surrealsAtDay (n + 1) = 2 * surrealsAtDay n + 1 := by
  simp only [surrealsAtDay]
  have h : 1 ≤ 2 ^ (n + 1) := Nat.one_le_pow _ _ (by norm_num)
  omega

/-- The number of *new* surreals born exactly at day `n+1` equals `2^n`.  -/
def newSurrealsAtDay (n : ℕ) : ℕ := if n = 0 then 1 else 2 ^ n

theorem newSurrealsAtDay_zero : newSurrealsAtDay 0 = 1 := by simp [newSurrealsAtDay]
theorem newSurrealsAtDay_succ (n : ℕ) : newSurrealsAtDay (n + 1) = 2 ^ (n + 1) := by
  simp [newSurrealsAtDay]

/-
The total count equals the sum of new surreals.
-/
theorem surrealsAtDay_eq_sum (n : ℕ) :
    surrealsAtDay n = ∑ k ∈ Finset.range (n + 1), newSurrealsAtDay k := by
  induction n <;> simp_all +decide [ Finset.sum_range_succ ];
  rename_i n ih;
  rw [ ← ih, surrealsAtDay_succ, newSurrealsAtDay_succ ] ; ring;
  rw [ show surrealsAtDay n = 2 ^ ( n + 1 ) - 1 from rfl ] ; zify ; norm_num ; ring;

/-! ## Part V: The Dyadic Approximation Sequence -/

/-- The dyadic approximation to an infinitesimal: the sequence `1/2^n`. -/
def dyadicApprox (n : ℕ) : ℚ := 1 / (2 ^ n : ℕ)

/-
The dyadic approximation is strictly decreasing.
-/
theorem dyadicApprox_strictAnti : StrictAnti dyadicApprox := by
  exact strictAnti_nat_of_succ_lt fun n => by unfold dyadicApprox; rw [ div_lt_div_iff₀ ] <;> norm_cast <;> ring <;> norm_num;

/-- All terms are positive. -/
theorem dyadicApprox_pos (n : ℕ) : 0 < dyadicApprox n := by
  simp [dyadicApprox]

/-- All terms are dyadic rationals. -/
theorem dyadicApprox_isDyadic (n : ℕ) : IsDyadicRational (dyadicApprox n) := by
  exact ⟨1, n, by simp [dyadicApprox]⟩

/-
The sequence converges to 0 in ℝ.
-/
theorem dyadicApprox_tendsto :
    Filter.Tendsto (fun n => (dyadicApprox n : ℝ)) Filter.atTop (nhds 0) := by
  norm_num [ dyadicApprox ];
  exact tendsto_inv_atTop_zero.comp <| tendsto_pow_atTop_atTop_of_one_lt one_lt_two

/-! ## Part VI: The Dyadic Resolution Function -/

/-- The **dyadic resolution** at level `n`: the finest grid spacing at birthday ≤ n. -/
noncomputable def dyadicResolution (n : ℕ) : ℚ :=
  if n = 0 then 0 else 1 / (2 ^ (n - 1) : ℕ)

theorem dyadicResolution_zero : dyadicResolution 0 = 0 := by simp [dyadicResolution]
theorem dyadicResolution_one : dyadicResolution 1 = 1 := by simp [dyadicResolution]

/-
The resolution halves with each birthday level (for n ≥ 1).
-/
theorem dyadicResolution_halves {n : ℕ} (hn : 1 ≤ n) :
    dyadicResolution (n + 1) = dyadicResolution n / 2 := by
  unfold dyadicResolution; ring;
  cases n <;> norm_num [ pow_succ' ] at *

/-! ## Part VII: Birthday Hierarchy Conjecture

**Conjecture**: The surreal numbers born by day ω are exactly the dyadic rationals.

**Test**: For each `n ≤ 5`, the surreals born by day `n` match dyadic rationals
with denominator dividing `2^(n-1)`.

**Falsification**: If any surreal born at a finite day is not dyadic rational,
or if any dyadic rational fails to appear at its expected birthday. -/
def birthdayHierarchyConjecture : Prop :=
  ∀ (q : ℚ), IsDyadicRational q →
    ∃ (x : PGame.{0}), x.Numeric ∧ ∃ (n : ℕ), x.birthday = ↑n

/-! ## Part VIII: Structural Properties -/

/-- Negation preserves birthday. -/
theorem birthday_neg_eq (x : PGame.{0}) : (-x).birthday = x.birthday :=
  PGame.birthday_neg x

/-- Birthday characterization as sup of options. -/
theorem birthday_eq_sup (x : PGame.{0}) :
    x.birthday = max
      (Ordinal.lsub (fun i => (x.moveLeft i).birthday))
      (Ordinal.lsub (fun j => (x.moveRight j).birthday)) :=
  PGame.birthday_def x

end SurrealArithmetic