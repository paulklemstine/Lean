import Mathlib

/-!
# A coefficientwise bridge from group characters to moonshine series

The proposed product of all McKay--Thompson series is not presently a theorem, and in its
literal form it has basic normalization problems (recorded in `FUTURE_DIRECTIONS.md`).  This
file instead proves a rigorous bridge fundamental to the interpretation of moonshine
coefficients.

A graded finite `G`-set `X n` has a fixed-point (permutation-character) series for every
`g : G`.  The coefficientwise average of these series is exactly the orbit-counting series.
Thus a family of character-like q-expansions determines an enumerative generating function.
This is Burnside's lemma lifted, simultaneously in every grade, to formal q-series represented
by their coefficient functions.
-/

namespace MonsterMoonshineBridge

/-- A formal q-series over `ℕ`, represented by its coefficient function. -/
abbrev NatQSeries := ℕ → ℕ

variable (G : Type*) [Group G]
variable (X : ℕ → Type*) [∀ n, MulAction G (X n)]

section FixedPoint

variable [∀ n (g : G), Fintype (MulAction.fixedBy (X n) g)]

/-- The permutation-character coefficient at grade `n`: the number of points fixed by `g`. -/
def fixedPointCoefficient (g : G) (n : ℕ) : ℕ :=
  Fintype.card (MulAction.fixedBy (X n) g)

/-- The fixed-point q-series attached to a group element. -/
def fixedPointSeries (g : G) : NatQSeries :=
  fun n => fixedPointCoefficient G X g n

section OrbitCounting

variable [Fintype G]
variable [∀ n, Fintype (MulAction.orbitRel.Quotient G (X n))]

/-- The coefficient counting `G`-orbits in the `n`th graded piece. -/
def orbitCoefficient (n : ℕ) : ℕ :=
  Fintype.card (MulAction.orbitRel.Quotient G (X n))

/-- The orbit-counting q-series of the graded action. -/
def orbitSeries : NatQSeries :=
  fun n => orbitCoefficient G X n

/-- **Character theory–generating function bridge, coefficient form.**
At every grade, the sum of permutation-character values equals the group order times the
number of orbits. -/
theorem sum_fixedPointCoefficient_eq_card_mul_orbits (n : ℕ) :
    (∑ g : G, fixedPointCoefficient G X g n) =
      Fintype.card G * orbitCoefficient G X n := by
  rw [Nat.mul_comm]
  exact MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G (X n)

/-- **Main connector theorem.** Summing all fixed-point/McKay--Thompson q-series
coefficientwise gives `|G|` times the orbit-generating series.  This is an exact identity of
formal q-expansions and needs no analytic convergence assumption. -/
theorem sum_fixedPointSeries_eq_card_smul_orbitSeries :
    (fun n => ∑ g : G, fixedPointSeries G X g n) =
      (fun n => Fintype.card G * orbitSeries G X n) := by
  funext n
  exact sum_fixedPointCoefficient_eq_card_mul_orbits G X n

/-- The average fixed-point coefficient is the orbit count. -/
theorem average_fixedPointCoefficient_eq_orbits (n : ℕ) :
    (∑ g : G, fixedPointCoefficient G X g n) / Fintype.card G =
      orbitCoefficient G X n := by
  rw [sum_fixedPointCoefficient_eq_card_mul_orbits G X n]
  exact Nat.mul_div_right _ (Fintype.card_pos_iff.mpr (show Nonempty G from ⟨1⟩))

end OrbitCounting

/-- A fixed-point coefficient, like a character value, is constant on conjugacy classes. -/
theorem fixedPointCoefficient_conj_invariant (g h : G) (n : ℕ) :
    fixedPointCoefficient G X (h * g * h⁻¹) n = fixedPointCoefficient G X g n := by
  let e : MulAction.fixedBy (X n) g ≃ MulAction.fixedBy (X n) (h * g * h⁻¹) :=
    { toFun := fun x => ⟨h • x, by
        rw [MulAction.mem_fixedBy]
        rw [mul_smul, mul_smul, inv_smul_smul]
        exact congrArg (fun y => h • y) (MulAction.mem_fixedBy.mp x.property)⟩
      invFun := fun x => ⟨h⁻¹ • x, by
        rw [MulAction.mem_fixedBy]
        have hx := MulAction.mem_fixedBy.mp x.property
        calc
          g • (h⁻¹ • x.1) = h⁻¹ • ((h * g * h⁻¹) • x.1) := by simp [mul_smul]
          _ = h⁻¹ • x.1 := congrArg (fun y => h⁻¹ • y) hx⟩
      left_inv := fun x => by ext; simp
      right_inv := fun x => by ext; simp }
  exact (Fintype.card_congr e).symm

/-- Consequently the entire fixed-point q-series is conjugacy invariant. -/
theorem fixedPointSeries_conj_invariant (g h : G) :
    fixedPointSeries G X (h * g * h⁻¹) = fixedPointSeries G X g := by
  funext n
  exact fixedPointCoefficient_conj_invariant G X g h n

end FixedPoint

end MonsterMoonshineBridge