/-
# Bishop-style constructive real numbers

This file develops the elementary theory of Errett Bishop's *regular sequences of
rationals*, the standard presentation of the real numbers in constructive analysis
(Bishop–Bridges, *Constructive Analysis*, Chapter 2).

A Bishop real is a sequence `x : ℕ → ℚ` of rationals together with the **explicit
modulus** condition

  `|x m - x n| ≤ 1/(m+1) + 1/(n+1)`,

i.e. `x n` is an approximation of the number it denotes to within `1/(n+1)`.  No
appeal to a choice principle or to a modulus obtained non-effectively is needed:
the modulus of Cauchyness is built into the datum.

Main results:

* `Bishop.Reg.abs_toReal_sub_approx_le` : the classical real `toReal x` denoted by a
  regular sequence is approximated by `x.approx n` with the *explicit* error bound
  `1/(n+1)`.
* `Bishop.Reg.equiv_iff_toReal_eq` : Bishop's equality `∀ n, |x n - y n| ≤ 2/(n+1)`
  agrees with equality of the denoted classical reals; in particular it is an
  equivalence relation (a nontrivial fact constructively).
* `Bishop.Reg.exists_toReal_eq` : every classical real is denoted by a regular
  sequence (so nothing is lost by the constructive presentation).
* `Bishop.Reg.limit` : *constructive completeness*.  From a regular sequence of
  Bishop reals one builds, by an explicit diagonal formula, a Bishop real which is
  its limit, with the explicit error estimate `|lim - x k| ≤ 1/(k+1)`.
* `Bishop.equivReal` : the quotient of the Bishop reals by Bishop equality is in
  bijection with the classical reals — the comparison with classical mathematics.
-/

import Mathlib

namespace Bishop

open Filter Topology

/-- A **regular sequence of rationals** (a Bishop real): a sequence of rationals
carrying its own modulus of Cauchyness, `|x m - x n| ≤ 1/(m+1) + 1/(n+1)`. -/
structure Reg where
  /-- the `n`-th rational approximation, accurate to within `1/(n+1)`. -/
  approx : ℕ → ℚ
  /-- the explicit regularity (Cauchy modulus) condition. -/
  regular : ∀ m n : ℕ, |approx m - approx n| ≤ 1 / (m + 1) + 1 / (n + 1)

namespace Reg

lemma regular_real (x : Reg) (m n : ℕ) :
    |(x.approx m : ℝ) - (x.approx n : ℝ)| ≤ 1 / (m + 1) + 1 / (n + 1) := by
  have h := x.regular m n
  have h' : ((|x.approx m - x.approx n| : ℚ) : ℝ)
      ≤ (((1 : ℚ) / (m + 1) + 1 / (n + 1) : ℚ) : ℝ) := by exact_mod_cast h
  push_cast at h'
  exact h'

lemma cauchySeq (x : Reg) : CauchySeq (fun n => ((x.approx n : ℝ))) := by
  refine cauchySeq_of_le_tendsto_0 (fun N => 2 / (N + 1)) ?_ ?_
  · intro n m N hn hm
    have hb := x.regular_real n m
    have h1 : (1 : ℝ) / (n + 1) ≤ 1 / (N + 1) := by
      have : (N : ℝ) ≤ n := by exact_mod_cast hn
      exact one_div_le_one_div_of_le (by positivity) (by linarith)
    have h2 : (1 : ℝ) / (m + 1) ≤ 1 / (N + 1) := by
      have : (N : ℝ) ≤ m := by exact_mod_cast hm
      exact one_div_le_one_div_of_le (by positivity) (by linarith)
    have : dist ((x.approx n : ℝ)) ((x.approx m : ℝ)) = |(x.approx n : ℝ) - x.approx m| :=
      Real.dist_eq _ _
    rw [this]
    calc |(x.approx n : ℝ) - x.approx m| ≤ 1 / (n + 1) + 1 / (m + 1) := hb
      _ ≤ 1 / (N + 1) + 1 / (N + 1) := add_le_add h1 h2
      _ = 2 / (N + 1) := by ring
  · simpa using (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).const_mul (2 : ℝ)

/-- The classical real number denoted by a regular sequence. -/
noncomputable def toReal (x : Reg) : ℝ := limUnder atTop (fun n => ((x.approx n : ℝ)))

lemma tendsto_toReal (x : Reg) :
    Tendsto (fun n => ((x.approx n : ℝ))) atTop (𝓝 x.toReal) :=
  x.cauchySeq.tendsto_limUnder

/-- **Explicit modulus.**  The `n`-th rational approximation of a Bishop real is
within `1/(n+1)` of the real number it denotes. -/
theorem abs_toReal_sub_approx_le (x : Reg) (n : ℕ) :
    |x.toReal - (x.approx n : ℝ)| ≤ 1 / (n + 1) := by
  have h1 : Tendsto (fun j : ℕ => |(x.approx j : ℝ) - (x.approx n : ℝ)|) atTop
      (𝓝 |x.toReal - (x.approx n : ℝ)|) :=
    (x.tendsto_toReal.sub tendsto_const_nhds).abs
  have h2 : Tendsto (fun j : ℕ => (1 : ℝ) / (j + 1) + 1 / (n + 1)) atTop
      (𝓝 (0 + 1 / (n + 1))) :=
    (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).add tendsto_const_nhds
  have := le_of_tendsto_of_tendsto' h1 h2 (fun j => x.regular_real j n)
  simpa using this

/-- If the rational approximations of a Bishop real converge to `r` at the canonical
rate (up to a constant), then the Bishop real denotes `r`. -/
theorem toReal_eq_of_approx_le (x : Reg) (r C : ℝ)
    (h : ∀ n : ℕ, |(x.approx n : ℝ) - r| ≤ C * (1 / ((n : ℝ) + 1))) : x.toReal = r := by
  have key : ∀ n : ℕ, |x.toReal - r| ≤ (1 + C) * (1 / ((n : ℝ) + 1)) := by
    intro n
    have h1 := x.abs_toReal_sub_approx_le n
    have h2 := h n
    have h3 : |x.toReal - r| ≤ |x.toReal - (x.approx n : ℝ)| + |(x.approx n : ℝ) - r| :=
      abs_sub_le _ _ _
    have h4 : (1 : ℝ) / ((n : ℝ) + 1) = 1 * (1 / ((n : ℝ) + 1)) := by ring
    rw [h4] at h1
    nlinarith [h1, h2, h3]
  have hlim : Tendsto (fun n : ℕ => (1 + C) * ((1 : ℝ) / (n + 1))) atTop (𝓝 ((1 + C) * 0)) :=
    (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).const_mul (1 + C)
  have h0 : |x.toReal - r| ≤ 0 := by
    have := le_of_tendsto_of_tendsto' (tendsto_const_nhds
      (x := |x.toReal - r|) (f := atTop (α := ℕ))) hlim key
    simpa using this
  have := abs_eq_zero.mp (le_antisymm h0 (abs_nonneg _))
  linarith

/-- Bishop's equality of real numbers: `x = y` means `|x n - y n| ≤ 2/(n+1)` for all
`n`.  (Constructively this is a *definition*, not a derived notion.) -/
def Equiv (x y : Reg) : Prop := ∀ n : ℕ, |x.approx n - y.approx n| ≤ 2 / (n + 1)

/-- Bishop equality of regular sequences coincides with equality of the denoted
classical reals. -/
theorem equiv_iff_toReal_eq (x y : Reg) : Equiv x y ↔ x.toReal = y.toReal := by
  constructor
  · intro h
    have key : ∀ n : ℕ, |x.toReal - y.toReal| ≤ 4 / (n + 1) := by
      intro n
      have hxy : |(x.approx n : ℝ) - (y.approx n : ℝ)| ≤ 2 / (n + 1) := by
        have := h n
        have h' : ((|x.approx n - y.approx n| : ℚ) : ℝ) ≤ (((2 : ℚ) / (n + 1) : ℚ) : ℝ) := by
          exact_mod_cast this
        push_cast at h'
        exact h'
      have hx := x.abs_toReal_sub_approx_le n
      have hy := y.abs_toReal_sub_approx_le n
      calc |x.toReal - y.toReal|
          ≤ |x.toReal - (x.approx n : ℝ)| + |(x.approx n : ℝ) - y.toReal| :=
            abs_sub_le _ _ _
        _ ≤ |x.toReal - (x.approx n : ℝ)|
              + (|(x.approx n : ℝ) - (y.approx n : ℝ)| + |(y.approx n : ℝ) - y.toReal|) :=
            add_le_add le_rfl (abs_sub_le _ _ _)
        _ ≤ 1 / (n + 1) + (2 / (n + 1) + 1 / (n + 1)) :=
            add_le_add hx (add_le_add hxy (by rw [abs_sub_comm]; exact hy))
        _ = 4 / (n + 1) := by ring
    have hlim : Tendsto (fun n : ℕ => (4 : ℝ) / (n + 1)) atTop (𝓝 0) := by
      simpa using (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).const_mul (4 : ℝ)
    have : |x.toReal - y.toReal| ≤ 0 :=
      le_of_tendsto_of_tendsto' tendsto_const_nhds hlim key
    have : x.toReal - y.toReal = 0 := by
      have := abs_nonneg (x.toReal - y.toReal)
      have h0 : |x.toReal - y.toReal| = 0 := le_antisymm ‹|x.toReal - y.toReal| ≤ 0› this
      exact abs_eq_zero.mp h0
    linarith
  · intro h n
    have hx := x.abs_toReal_sub_approx_le n
    have hy := y.abs_toReal_sub_approx_le n
    have : |(x.approx n : ℝ) - (y.approx n : ℝ)| ≤ 2 / (n + 1) := by
      calc |(x.approx n : ℝ) - (y.approx n : ℝ)|
          ≤ |(x.approx n : ℝ) - x.toReal| + |x.toReal - (y.approx n : ℝ)| := abs_sub_le _ _ _
        _ ≤ 1 / (n + 1) + 1 / (n + 1) := by
            gcongr
            · rw [abs_sub_comm]; exact hx
            · rw [h]; exact hy
        _ = 2 / (n + 1) := by ring
    have : ((|x.approx n - y.approx n| : ℚ) : ℝ) ≤ (((2 : ℚ) / (n + 1) : ℚ) : ℝ) := by
      push_cast
      simpa using this
    exact_mod_cast this

lemma equiv_refl (x : Reg) : Equiv x x := (equiv_iff_toReal_eq x x).2 rfl

lemma equiv_symm {x y : Reg} (h : Equiv x y) : Equiv y x :=
  (equiv_iff_toReal_eq y x).2 ((equiv_iff_toReal_eq x y).1 h).symm

/-- Transitivity of Bishop equality (the constructive "3ε" argument). -/
lemma equiv_trans {x y z : Reg} (h₁ : Equiv x y) (h₂ : Equiv y z) : Equiv x z :=
  (equiv_iff_toReal_eq x z).2
    (((equiv_iff_toReal_eq x y).1 h₁).trans ((equiv_iff_toReal_eq y z).1 h₂))

/-- Every classical real number is denoted by a regular sequence: the constructive
presentation loses nothing. -/
theorem exists_toReal_eq (r : ℝ) : ∃ x : Reg, x.toReal = r := by
  have hchoice : ∀ n : ℕ, ∃ q : ℚ, |r - (q : ℝ)| < 1 / (2 * (n + 1)) := by
    intro n
    exact exists_rat_near r (by positivity)
  choose q hq using hchoice
  have hreg : ∀ m n : ℕ, |q m - q n| ≤ 1 / (m + 1) + 1 / (n + 1) := by
    intro m n
    have hm := hq m
    have hn := hq n
    have : |((q m : ℝ)) - (q n : ℝ)| ≤ 1 / (m + 1) + 1 / (n + 1) := by
      have h1 : |((q m : ℝ)) - (q n : ℝ)| ≤ |(q m : ℝ) - r| + |r - (q n : ℝ)| :=
        abs_sub_le _ _ _
      have h2 : |(q m : ℝ) - r| < 1 / (2 * (m + 1)) := by
        rw [abs_sub_comm]; exact hm
      have h3 : (1 : ℝ) / (2 * (m + 1)) ≤ 1 / (m + 1) := by
        have : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
        exact one_div_le_one_div_of_le (by positivity) (by linarith)
      have h4 : (1 : ℝ) / (2 * (n + 1)) ≤ 1 / (n + 1) := by
        have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
        exact one_div_le_one_div_of_le (by positivity) (by linarith)
      linarith
    have h' : ((|q m - q n| : ℚ) : ℝ) ≤ (((1 : ℚ) / (m + 1) + 1 / (n + 1) : ℚ) : ℝ) := by
      push_cast
      simpa using this
    exact_mod_cast h'
  refine ⟨⟨q, hreg⟩, ?_⟩
  set x : Reg := ⟨q, hreg⟩ with hx
  have key : ∀ n : ℕ, |x.toReal - r| ≤ 2 / (n + 1) := by
    intro n
    have h1 := x.abs_toReal_sub_approx_le n
    have h2 := hq n
    have hxa : x.approx n = q n := rfl
    rw [hxa] at h1
    have h3 : |(q n : ℝ) - r| ≤ 1 / (n + 1) := by
      rw [abs_sub_comm]
      have h4 : (1 : ℝ) / (2 * (n + 1)) ≤ 1 / (n + 1) := by
        have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
        exact one_div_le_one_div_of_le (by positivity) (by linarith)
      linarith [h2]
    calc |x.toReal - r| ≤ |x.toReal - (q n : ℝ)| + |(q n : ℝ) - r| := abs_sub_le _ _ _
      _ ≤ 1 / (n + 1) + 1 / (n + 1) := add_le_add h1 h3
      _ = 2 / (n + 1) := by ring
  have hlim : Tendsto (fun n : ℕ => (2 : ℝ) / (n + 1)) atTop (𝓝 0) := by
    simpa using (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).const_mul (2 : ℝ)
  have h0 : |x.toReal - r| ≤ 0 := le_of_tendsto_of_tendsto' tendsto_const_nhds hlim key
  have := abs_eq_zero.mp (le_antisymm h0 (abs_nonneg _))
  linarith [this]

/-! ## Constructive completeness

A *regular sequence of reals* is a sequence `x : ℕ → Reg` with
`|x k - x l| ≤ 1/(k+1) + 1/(l+1)`.  Bishop's completeness theorem builds its limit
by an explicit diagonal formula, together with an explicit rate of convergence. -/

/-- A sequence of Bishop reals which is Cauchy with the canonical explicit modulus. -/
def IsRegularSeqOfReals (x : ℕ → Reg) : Prop :=
  ∀ k l : ℕ, |(x k).toReal - (x l).toReal| ≤ 1 / (k + 1) + 1 / (l + 1)

lemma diag_regular {x : ℕ → Reg} (hx : IsRegularSeqOfReals x) (m n : ℕ) :
    |(x (2 * m + 1)).approx (2 * m + 1) - (x (2 * n + 1)).approx (2 * n + 1)|
      ≤ 1 / (m + 1) + 1 / (n + 1) := by
  have key : ∀ j : ℕ, |((x (2 * j + 1)).approx (2 * j + 1) : ℝ) - (x (2 * j + 1)).toReal|
      ≤ 1 / (2 * (j : ℝ) + 2) := by
    intro j
    have h := (x (2 * j + 1)).abs_toReal_sub_approx_le (2 * j + 1)
    rw [abs_sub_comm] at h
    have : ((2 * j + 1 : ℕ) : ℝ) + 1 = 2 * (j : ℝ) + 2 := by push_cast; ring
    rwa [this] at h
  have hm := key m
  have hn := key n
  have hmn := hx (2 * m + 1) (2 * n + 1)
  have e1 : ((2 * m + 1 : ℕ) : ℝ) + 1 = 2 * (m : ℝ) + 2 := by push_cast; ring
  have e2 : ((2 * n + 1 : ℕ) : ℝ) + 1 = 2 * (n : ℝ) + 2 := by push_cast; ring
  rw [e1, e2] at hmn
  have hR : |((x (2 * m + 1)).approx (2 * m + 1) : ℝ)
        - ((x (2 * n + 1)).approx (2 * n + 1) : ℝ)| ≤ 1 / (m + 1) + 1 / (n + 1) := by
    have h1 : |((x (2 * m + 1)).approx (2 * m + 1) : ℝ)
          - ((x (2 * n + 1)).approx (2 * n + 1) : ℝ)|
        ≤ |((x (2 * m + 1)).approx (2 * m + 1) : ℝ) - (x (2 * m + 1)).toReal|
          + |(x (2 * m + 1)).toReal - ((x (2 * n + 1)).approx (2 * n + 1) : ℝ)| :=
      abs_sub_le _ _ _
    have h2 : |(x (2 * m + 1)).toReal - ((x (2 * n + 1)).approx (2 * n + 1) : ℝ)|
        ≤ |(x (2 * m + 1)).toReal - (x (2 * n + 1)).toReal|
          + |(x (2 * n + 1)).toReal - ((x (2 * n + 1)).approx (2 * n + 1) : ℝ)| :=
      abs_sub_le _ _ _
    have hn' : |(x (2 * n + 1)).toReal - ((x (2 * n + 1)).approx (2 * n + 1) : ℝ)|
        ≤ 1 / (2 * (n : ℝ) + 2) := by rw [abs_sub_comm]; exact hn
    have hmpos : (0 : ℝ) < (m : ℝ) + 1 := by positivity
    have hnpos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    have ea : (1 : ℝ) / (2 * (m : ℝ) + 2) = (1 / ((m : ℝ) + 1)) / 2 := by
      rw [div_div]; ring_nf
    have eb : (1 : ℝ) / (2 * (n : ℝ) + 2) = (1 / ((n : ℝ) + 1)) / 2 := by
      rw [div_div]; ring_nf
    rw [ea] at hm hmn
    rw [eb] at hn' hmn
    linarith
  have h' : ((|(x (2 * m + 1)).approx (2 * m + 1) - (x (2 * n + 1)).approx (2 * n + 1)| : ℚ) : ℝ)
      ≤ (((1 : ℚ) / (m + 1) + 1 / (n + 1) : ℚ) : ℝ) := by
    push_cast
    simpa using hR
  exact_mod_cast h'

/-- **Constructive completeness (Bishop).**  The limit of a regular sequence of
Bishop reals, given by the explicit diagonal `n ↦ (x_{2n+1})_{2n+1}`. -/
def limit {x : ℕ → Reg} (hx : IsRegularSeqOfReals x) : Reg where
  approx n := (x (2 * n + 1)).approx (2 * n + 1)
  regular := diag_regular hx

/-- **Explicit rate of convergence.**  The limit constructed above satisfies
`|lim - x k| ≤ 1/(k+1)`: the sequence converges with the canonical modulus. -/
theorem limit_spec {x : ℕ → Reg} (hx : IsRegularSeqOfReals x) (k : ℕ) :
    |(limit hx).toReal - (x k).toReal| ≤ 1 / (k + 1) := by
  have key : ∀ n : ℕ, |(limit hx).toReal - (x k).toReal|
      ≤ 2 * (1 / ((n : ℝ) + 1)) + 1 / (k + 1) := by
    intro n
    have h1 := (limit hx).abs_toReal_sub_approx_le n
    have happrox : (limit hx).approx n = (x (2 * n + 1)).approx (2 * n + 1) := rfl
    rw [happrox] at h1
    have h2 := (x (2 * n + 1)).abs_toReal_sub_approx_le (2 * n + 1)
    have e1 : ((2 * n + 1 : ℕ) : ℝ) + 1 = 2 * (n : ℝ) + 2 := by push_cast; ring
    rw [e1] at h2
    have h3 := hx (2 * n + 1) k
    rw [e1] at h3
    have ea : (1 : ℝ) / (2 * (n : ℝ) + 2) = (1 / ((n : ℝ) + 1)) / 2 := by
      rw [div_div]; ring_nf
    rw [ea] at h2 h3
    have h4 : |(limit hx).toReal - (x k).toReal|
        ≤ |(limit hx).toReal - ((x (2 * n + 1)).approx (2 * n + 1) : ℝ)|
          + |((x (2 * n + 1)).approx (2 * n + 1) : ℝ) - (x k).toReal| := abs_sub_le _ _ _
    have h5 : |((x (2 * n + 1)).approx (2 * n + 1) : ℝ) - (x k).toReal|
        ≤ |((x (2 * n + 1)).approx (2 * n + 1) : ℝ) - (x (2 * n + 1)).toReal|
          + |(x (2 * n + 1)).toReal - (x k).toReal| := abs_sub_le _ _ _
    have h2' : |((x (2 * n + 1)).approx (2 * n + 1) : ℝ) - (x (2 * n + 1)).toReal|
        ≤ (1 / ((n : ℝ) + 1)) / 2 := by rw [abs_sub_comm]; exact h2
    linarith
  have hlim : Tendsto (fun n : ℕ => 2 * ((1 : ℝ) / (n + 1)) + 1 / (k + 1)) atTop
      (𝓝 (2 * 0 + 1 / (k + 1))) :=
    ((tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).const_mul (2 : ℝ)).add
      tendsto_const_nhds
  have := le_of_tendsto_of_tendsto' (tendsto_const_nhds
    (x := |(limit hx).toReal - (x k).toReal|) (f := atTop (α := ℕ))) hlim key
  simpa using this

end Reg

/-- Bishop equality as a setoid on regular sequences. -/
def bishopSetoid : Setoid Reg where
  r := Reg.Equiv
  iseqv := ⟨Reg.equiv_refl, Reg.equiv_symm, Reg.equiv_trans⟩

/-- The type of Bishop reals: regular sequences modulo Bishop equality. -/
def BishopReal : Type := Quotient bishopSetoid

/-- The map sending a Bishop real to the classical real it denotes. -/
noncomputable def toRealQuot : BishopReal → ℝ :=
  Quotient.lift Reg.toReal (fun _ _ h => (Reg.equiv_iff_toReal_eq _ _).1 h)

/-- **Comparison with classical analysis.**  The Bishop reals, modulo Bishop
equality, are in canonical bijection with the classical real numbers. -/
noncomputable def equivReal : BishopReal ≃ ℝ := by
  refine Equiv.ofBijective toRealQuot ⟨?_, ?_⟩
  · refine Quotient.ind₂ (fun a b h => ?_)
    exact Quotient.sound ((Reg.equiv_iff_toReal_eq a b).2 h)
  · intro r
    obtain ⟨x, hx⟩ := Reg.exists_toReal_eq r
    exact ⟨Quotient.mk _ x, hx⟩

end Bishop