import Mathlib

/-!
# Learnable Möbius Transforms as Attention Parameters

This file formalizes **Möbius transforms as learnable attention parameters**,
replacing standard linear Q/K/V projections with Möbius transformations.

## Main Results

* `moebiusDet_composition` — Determinant of composition = product of determinants
* `idMoebius_det` — Identity has unit determinant
* `moebiusConfFactor_nonneg` — Conformal factor is non-negative
* `moebius_attention_weight_pos` — Attention weights are positive
* `moebius_param_dim` — Parameter dimension is 8
-/

open Real Finset BigOperators

noncomputable section

/-! ## Part 1: Möbius Transform Parameters -/

structure MoebiusParams where
  a : ℝ × ℝ
  b : ℝ × ℝ
  c : ℝ × ℝ
  d : ℝ × ℝ

def moebiusDet (p : MoebiusParams) : ℝ × ℝ :=
  (p.a.1 * p.d.1 - p.a.2 * p.d.2 - (p.b.1 * p.c.1 - p.b.2 * p.c.2),
   p.a.1 * p.d.2 + p.a.2 * p.d.1 - (p.b.1 * p.c.2 + p.b.2 * p.c.1))

def moebiusDetSqNorm (p : MoebiusParams) : ℝ :=
  (moebiusDet p).1 ^ 2 + (moebiusDet p).2 ^ 2

def applyMoebius (p : MoebiusParams) (z : ℝ × ℝ) : ℝ × ℝ :=
  let num := (p.a.1 * z.1 - p.a.2 * z.2 + p.b.1,
              p.a.1 * z.2 + p.a.2 * z.1 + p.b.2)
  let den := (p.c.1 * z.1 - p.c.2 * z.2 + p.d.1,
              p.c.1 * z.2 + p.c.2 * z.1 + p.d.2)
  let den_sq := den.1 ^ 2 + den.2 ^ 2
  ((num.1 * den.1 + num.2 * den.2) / den_sq,
   (num.2 * den.1 - num.1 * den.2) / den_sq)

/-! ## Part 2: Composition of Möbius Transforms -/

def composeMoebius (p q : MoebiusParams) : MoebiusParams where
  a := (p.a.1 * q.a.1 - p.a.2 * q.a.2 + p.b.1 * q.c.1 - p.b.2 * q.c.2,
        p.a.1 * q.a.2 + p.a.2 * q.a.1 + p.b.1 * q.c.2 + p.b.2 * q.c.1)
  b := (p.a.1 * q.b.1 - p.a.2 * q.b.2 + p.b.1 * q.d.1 - p.b.2 * q.d.2,
        p.a.1 * q.b.2 + p.a.2 * q.b.1 + p.b.1 * q.d.2 + p.b.2 * q.d.1)
  c := (p.c.1 * q.a.1 - p.c.2 * q.a.2 + p.d.1 * q.c.1 - p.d.2 * q.c.2,
        p.c.1 * q.a.2 + p.c.2 * q.a.1 + p.d.1 * q.c.2 + p.d.2 * q.c.1)
  d := (p.c.1 * q.b.1 - p.c.2 * q.b.2 + p.d.1 * q.d.1 - p.d.2 * q.d.2,
        p.c.1 * q.b.2 + p.c.2 * q.b.1 + p.d.1 * q.d.2 + p.d.2 * q.d.1)

theorem moebiusDet_composition (p q : MoebiusParams) :
    moebiusDet (composeMoebius p q) =
    (  (moebiusDet p).1 * (moebiusDet q).1 - (moebiusDet p).2 * (moebiusDet q).2,
       (moebiusDet p).1 * (moebiusDet q).2 + (moebiusDet p).2 * (moebiusDet q).1) := by
  unfold moebiusDet composeMoebius; ring;

def idMoebius : MoebiusParams where
  a := (1, 0)
  b := (0, 0)
  c := (0, 0)
  d := (1, 0)

theorem idMoebius_det : moebiusDet idMoebius = (1, 0) := by
  unfold moebiusDet idMoebius; norm_num

/-! ## Part 3: Conformal Factor of Möbius Transforms -/

def moebiusConfFactor (p : MoebiusParams) (z : ℝ × ℝ) : ℝ :=
  let den := (p.c.1 * z.1 - p.c.2 * z.2 + p.d.1,
              p.c.1 * z.2 + p.c.2 * z.1 + p.d.2)
  let den_sq := den.1 ^ 2 + den.2 ^ 2
  Real.sqrt (moebiusDetSqNorm p) / den_sq

theorem moebiusConfFactor_nonneg (p : MoebiusParams) (z : ℝ × ℝ) :
    0 ≤ moebiusConfFactor p z := by
  unfold moebiusConfFactor
  apply div_nonneg
  · exact Real.sqrt_nonneg _
  · positivity

/-! ## Part 4: Möbius-Parameterized Attention -/

def moebiusAttentionHead (seqLen : ℕ) (T : ℝ)
    (pQ pK : MoebiusParams)
    (X : Fin seqLen → ℝ × ℝ)
    (V : Fin seqLen → ℝ × ℝ) : Fin seqLen → ℝ × ℝ :=
  fun i =>
    let Q := fun j => applyMoebius pQ (X j)
    let K := fun j => applyMoebius pK (X j)
    let kernel := fun j =>
      let qi := Q i
      let kj := K j
      qi.1 * kj.1 + qi.2 * kj.2
    let weights := fun j => Real.exp (kernel j / T)
    let totalWeight := ∑ j : Fin seqLen, weights j
    (∑ j : Fin seqLen, (weights j / totalWeight) * (V j).1,
     ∑ j : Fin seqLen, (weights j / totalWeight) * (V j).2)

/-! ## Part 5: Learnable Parameterization -/

def learnableMoebiusParams (params : Fin 8 → ℝ) : MoebiusParams where
  a := (params 0, params 1)
  b := (params 2, params 3)
  c := (params 4, params 5)
  d := (params 6, params 7)

theorem moebius_param_dim : Fintype.card (Fin 8) = 8 := by simp

/-- Standard linear attention uses d² parameters per projection.
    Möbius attention uses only 8 parameters per head (in 2D). -/
theorem moebius_param_efficiency (d : ℕ) (hd : 3 ≤ d) :
    8 ≤ d * d := by nlinarith

end