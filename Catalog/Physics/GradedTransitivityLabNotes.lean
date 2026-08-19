import Physics.GradedTransitivityGSet

/-!
# Lab notes: numerical data behind the graded-transitivity rationality theorems

The `#eval`s below are the experiments that guided the formal development; the recorded
outputs are reproduced in comments (and collected in `ComputationalEvidence.md`).

Three regimes were probed:

1. the trivial action on `Yₙ = Fin n`, where `t r Yₙ = n^{\underline r}` is a genuine
   degree-`r` polynomial (denominator exactly `(1 − q)^{r+1}`);
2. the free rotation action of `ZMod n` on `Fin n`, where `t r Yₙ = (n−1)^{\underline{r−1}}`
   — `1`-transitive for all `n ≥ 1` but never eventually `2`-transitive;
3. the binomial model `C(n+r, r)`, extremal for the denominator.

The finite-difference tables are the direct experimental confirmation of the coefficient
formula `[X^{n+s}]((1 − X)^s · gf a) = (Δ^s a) n`.
-/

namespace Physics.GradedTransitivity.LabNotes

open Physics.GradedTransitivity

/-- Forward difference on integer sequences (the operator behind `(1 − q)`). -/
def D (a : ℕ → ℤ) : ℕ → ℤ := fwdDiff 1 a

/-- `t r Yₙ` for the trivial action on `Fin n`. -/
def descSeq (r : ℕ) : ℕ → ℤ := fun n => (n.descFactorial r : ℤ)

-- [0, 0, 0, 6, 24, 60, 120, 210, 336, 504]
#eval (List.range 10).map (fun n => descSeq 3 n)
-- [0, 0, 6, 18, 36, 60, 90, 126, 168, 216]
#eval (List.range 10).map (fun n => (D^[1] (descSeq 3)) n)
-- [0, 6, 12, 18, 24, 30, 36, 42, 48, 54]
#eval (List.range 10).map (fun n => (D^[2] (descSeq 3)) n)
-- [6, 6, 6, 6, 6, 6, 6, 6, 6, 6]   (= 3! : the third difference is constant)
#eval (List.range 10).map (fun n => (D^[3] (descSeq 3)) n)
-- [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]   (the fourth difference vanishes)
#eval (List.range 10).map (fun n => (D^[4] (descSeq 3)) n)

/-- Orbit count for the (free) rotation action of `ZMod n` on `Fin n`. -/
def rotOrbits (r n : ℕ) : ℕ := if n = 0 then 0 else n.descFactorial r / n

-- [0, 1, 1, 1, 1, 1, 1, 1, 1, 1]   eventually 1-transitive
#eval (List.range 10).map (rotOrbits 1)
-- [0, 0, 1, 2, 3, 4, 5, 6, 7, 8]   linear growth: never eventually 2-transitive
#eval (List.range 10).map (rotOrbits 2)
-- [0, 0, 0, 2, 6, 12, 20, 30, 42, 56]
#eval (List.range 10).map (rotOrbits 3)

-- [1, 4, 10, 20, 35, 56, 84, 120, 165, 220]  (tetrahedral numbers, r = 3)
#eval (List.range 10).map (fun n => binomSeq 3 n)
-- [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]   third difference of the model is the all-ones series
#eval (List.range 10).map (fun n => (D^[3] (binomSeq 3)) n)
-- [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
#eval (List.range 10).map (fun n => (D^[4] (binomSeq 3)) n)

/-- A synthetic eventually `2`-transitive family: `t₂ = 0, 0, 2, 1, 1, 1, …`. -/
def evSeq : ℕ → ℤ := fun n => if n < 2 then 0 else if n = 2 then 2 else 1

-- [0, 0, 2, 1, 1, 1, 1, 1]
#eval (List.range 8).map evSeq
-- [0, 2, -1, 0, 0, 0, 0, 0]  one difference already kills the tail
#eval (List.range 8).map (fun n => (D^[1] evSeq) n)

/-! ### Machine-checked instances of the tables above -/

/-- The third difference of `n ↦ n^{\underline 3}` is the constant `3! = 6`. -/
theorem D3_descSeq3 (n : ℕ) (hn : n ≤ 6) : (D^[3] (descSeq 3)) n = 6 := by
  interval_cases n <;> rfl

/-- The fourth difference of `n ↦ n^{\underline 3}` vanishes on the sampled range. -/
theorem D4_descSeq3 (n : ℕ) (hn : n ≤ 6) : (D^[4] (descSeq 3)) n = 0 := by
  interval_cases n <;> rfl

/-- The third difference of the binomial model `C(n+3, 3)` is the all-ones sequence. -/
theorem D3_binom3 (n : ℕ) (hn : n ≤ 6) : (D^[3] (binomSeq 3)) n = 1 := by
  interval_cases n <;> rfl

end Physics.GradedTransitivity.LabNotes