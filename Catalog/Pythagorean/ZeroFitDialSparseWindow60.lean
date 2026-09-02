import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52
import Pythagorean.ZeroFitDialBalanced60
import Pythagorean.ZeroFitDialWeightEnvelope60
import Pythagorean.ZeroFitDialBalancedClosure60
import Pythagorean.ZeroFitDialHalfWeightBoundary60

/-!
# Closing the window: the zero-fit dial has exactly one phase boundary

## Research context (FACT round-51 #3, exp 521, `CELL-CLOSED-DIAL-HOLDS-60`)

`Pythagorean.ZeroFitDialHalfWeightBoundary60` trapped the sign change of `ρ² - 6/7` for the
fixed-weight draw laws (weight `w = v+1` on bitlen `b = v+1+r`) between two guards:

* `half_weight_boundary` — weight at least half (`r ≤ v+1`) forces `ρ² ≤ 6/7`;
* `sparse_ceiling_gt` — weight fraction at most one third (`r ≥ 2v+2`) forces `ρ² > 6/7`.

The undecided window was `1/3 < w/b < 1/2`, i.e. `v+2 ≤ r ≤ 2v+1`.  This file closes it.

## Main results

* `geom_cube_bound` — the **exact geometric envelope** of the hockey-stick profile.  The
  block ratio `m_{j-1}/m_j = j/(v+j)` increases with `j`, so the whole tail is dominated by
  the geometric series with the *largest* ratio `q = r/(v+r)`:
  `Σⱼ mⱼ³ ≤ m₀³ / (1 - q³)`, stated division-free as
  `cubeSum · ((v+r)³ - r³) ≤ m₀³ (v+r)³`.
  This replaces the crude bound `Σⱼ mⱼ³ ≤ m₀² n` used on the sparse side in cycle 5, and it
  is *sharp to first order* exactly at the phase boundary.
* `window_ceiling_gt` — for **every** `r ≥ v+2` (`v ≥ 1`) the ceiling is strictly above
  `6/7`.  The proof feeds the geometric envelope and the exact head-to-total ratio
  `n(v+1) = m₀(v+r+1)` into the degree-6 polynomial inequality
  `7 (v+1)³ (v+r)³ < (v+r+1)³ ((v+r)³ - r³)` (`window_algebra`), whose difference has
  *strictly positive coefficients* after the substitution `v = a+1`, `r = a+3+s`.
* `dial_sign_iff` and `half_weight_dichotomy` — the capstone: for every fixed-weight draw
  law the sign of `ρ² - 6/7` is decided by the weight fraction alone, and the single phase
  boundary sits exactly at half weight `2w = b`.

## Why the constant `7` is not an accident

Writing `r = c·v` and letting `v → ∞`, the geometric envelope gives
`ρ² > 6/7` as soon as `(1+c)³ - c³ = 3c² + 3c + 1 > 7`, i.e. `c > 1`.  The threshold `c = 1`
is exactly the half-weight line, so the crude-looking geometric estimate is in fact
*asymptotically exact* at the boundary: the tie-attenuation constant `6/7` of the dial and
the half-weight line are two faces of the identity `3·1² + 3·1 + 1 = 7`.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Pythagorean.ZeroFitDialBalanced60
open Catalog.Pythagorean.ZeroFitDialHalfWeightBoundary60

namespace Catalog.Pythagorean.ZeroFitDialSparseWindow60

/-! ## 1. The block recursion -/

/-- Consecutive heads of the hockey-stick profile: `m_r (v+r+1) = m_{r+1} (r+1)`, where
`m_j = C(v+j, v)`. -/
lemma choose_head_step (v r : ℕ) :
    ((v + r).choose v) * (v + r + 1) = ((v + (r + 1)).choose v) * (r + 1) := by
  have h1 : (v + r).choose v = (v + r).choose r := by
    have h := Nat.choose_symm (n := v + r) (k := v) (by omega)
    have e : v + r - v = r := by omega
    rw [e] at h
    omega
  have h2 : (v + (r + 1)).choose v = (v + r + 1).choose (r + 1) := by
    have h := Nat.choose_symm (n := v + r + 1) (k := r + 1) (by omega)
    have e : v + r + 1 - (r + 1) = v := by omega
    rw [e] at h
    have e2 : v + (r + 1) = v + r + 1 := by omega
    rw [e2]
    omega
  rw [h1, h2, mul_comm]
  exact Nat.add_one_mul_choose_eq (v + r) r

/-! ## 2. The geometric envelope -/

/-- One induction step of the geometric envelope, as pure algebra.  `V = v+r`, `R = r`,
`M = m_r`, `M' = m_{r+1}`, `T` the cube sum of the shorter profile.  The monotonicity of the
block ratio enters through `R ≤ V`. -/
lemma geom_step_algebra (T M M' V R : ℚ) (hT : 0 ≤ T) (hR : 0 ≤ R) (hRV : R ≤ V)
    (hV : 0 < V) (hstep : M * (V + 1) = M' * (R + 1))
    (ih : T * (V ^ 3 - R ^ 3) ≤ M ^ 3 * V ^ 3) :
    (M' ^ 3 + T) * ((V + 1) ^ 3 - (R + 1) ^ 3) ≤ M' ^ 3 * (V + 1) ^ 3 := by
  -- the ratio `j/(v+j)` increases: `(V+1)R ≤ V(R+1)`
  have hbase : (V + 1) * R ≤ V * (R + 1) := by nlinarith
  have h3 : ((V + 1) * R) ^ 3 ≤ (V * (R + 1)) ^ 3 :=
    pow_le_pow_left₀ (by positivity) hbase 3
  have hmono : V ^ 3 * ((V + 1) ^ 3 - (R + 1) ^ 3) ≤ (V + 1) ^ 3 * (V ^ 3 - R ^ 3) := by
    nlinarith [h3]
  -- transport the inductive bound along the ratio comparison
  have s1 : T * ((V + 1) ^ 3 - (R + 1) ^ 3) * V ^ 3
      ≤ T * (V ^ 3 - R ^ 3) * (V + 1) ^ 3 := by
    nlinarith [mul_le_mul_of_nonneg_left hmono hT]
  have s2 : T * (V ^ 3 - R ^ 3) * (V + 1) ^ 3 ≤ M ^ 3 * V ^ 3 * (V + 1) ^ 3 :=
    mul_le_mul_of_nonneg_right ih (by positivity)
  have s3 : M ^ 3 * V ^ 3 * (V + 1) ^ 3 = M' ^ 3 * (R + 1) ^ 3 * V ^ 3 := by
    have hc : (M * (V + 1)) ^ 3 = (M' * (R + 1)) ^ 3 := by rw [hstep]
    linear_combination V ^ 3 * hc
  have hcancel : T * ((V + 1) ^ 3 - (R + 1) ^ 3) ≤ M' ^ 3 * (R + 1) ^ 3 := by
    have hpos : (0 : ℚ) < V ^ 3 := by positivity
    have hchain : T * ((V + 1) ^ 3 - (R + 1) ^ 3) * V ^ 3
        ≤ M' ^ 3 * (R + 1) ^ 3 * V ^ 3 := by
      calc T * ((V + 1) ^ 3 - (R + 1) ^ 3) * V ^ 3
          ≤ T * (V ^ 3 - R ^ 3) * (V + 1) ^ 3 := s1
        _ ≤ M ^ 3 * V ^ 3 * (V + 1) ^ 3 := s2
        _ = M' ^ 3 * (R + 1) ^ 3 * V ^ 3 := s3
    exact le_of_mul_le_mul_right hchain hpos
  nlinarith [hcancel]

/-- **The geometric envelope of the hockey-stick profile.**  For a fixed-weight law with
weight `v+1 ≥ 2` on `v+1+r` bits, the cube sum of the trailing-zero blocks obeys
`Σⱼ mⱼ³ · ((v+r)³ - r³) ≤ m₀³ (v+r)³`, i.e. `Σⱼ mⱼ³ ≤ m₀³/(1 - q³)` with `q = r/(v+r)` the
largest block ratio.  Equality holds in the limit of a genuinely geometric profile. -/
lemma geom_cube_bound (v : ℕ) (hv : 1 ≤ v) (r : ℕ) :
    cubeSum (balancedBlocks v r) * (((v : ℚ) + r) ^ 3 - (r : ℚ) ^ 3)
      ≤ ((((v + r).choose v : ℕ)) : ℚ) ^ 3 * ((v : ℚ) + r) ^ 3 := by
  have hvQ : (1 : ℚ) ≤ (v : ℚ) := by exact_mod_cast hv
  induction r with
  | zero => simp [balancedBlocks, cubeSum]
  | succ r ih =>
      have hrQ : (0 : ℚ) ≤ (r : ℚ) := Nat.cast_nonneg r
      have hstep : ((((v + r).choose v : ℕ)) : ℚ) * (((v : ℚ) + r) + 1)
          = ((((v + (r + 1)).choose v : ℕ)) : ℚ) * ((r : ℚ) + 1) := by
        have hc := (Nat.cast_inj (R := ℚ)).2 (choose_head_step v r)
        push_cast at hc
        linear_combination hc
      have hkey := geom_step_algebra (cubeSum (balancedBlocks v r))
        ((((v + r).choose v : ℕ)) : ℚ) ((((v + (r + 1)).choose v : ℕ)) : ℚ)
        ((v : ℚ) + r) (r : ℚ) (cubeSum_nonneg _) hrQ (by linarith) (by linarith) hstep ih
      rw [balancedBlocks, cubeSum_cons]
      push_cast
      push_cast at hkey
      linarith [hkey]

/-! ## 3. The window inequality -/

/-- The degree-6 polynomial inequality that decides the window, in its **quantitative**
form.  With `v = a+1` and `r = a+3+s` (`a, s ≥ 0`, i.e. `v ≥ 1` and `r ≥ v+2`), writing
`P = v+1`, `V = v+r`, `R = r`, the difference `2P (V+1)³(V³ - R³) - 7(2P+1) P³ V³` has all
coefficients nonnegative and constant term `580`.  So the window inequality
`7 P³V³ < (V+1)³(V³-R³)` holds with a *quantified* margin factor `(2P+1)/(2P)`. -/
lemma window_algebra_sharp (a s : ℕ) :
    7 * (2 * (a : ℚ) + 5) * ((a : ℚ) + 2) ^ 3 * (2 * (a : ℚ) + 4 + s) ^ 3
      ≤ (2 * (a : ℚ) + 4)
        * ((2 * (a : ℚ) + 5 + s) ^ 3 * ((2 * (a : ℚ) + 4 + s) ^ 3 - ((a : ℚ) + 3 + s) ^ 3)) := by
  set A := (a : ℚ) with hA
  set S := (s : ℚ) with hS
  have hpos : (0 : ℚ) <
      (580 + 8160 * S + 6660 * S ^ 2 + 2028 * S ^ 3 + 264 * S ^ 4 + 12 * S ^ 5)
      + A * (5022 + 29004 * S + 19314 * S ^ 2 + 4822 * S ^ 3 + 504 * S ^ 4 + 18 * S ^ 5)
      + A ^ 2 * (9426 + 39126 * S + 20880 * S ^ 2 + 4002 * S ^ 3 + 294 * S ^ 4 + 6 * S ^ 5)
      + A ^ 3 * (7854 + 26592 * S + 10788 * S ^ 2 + 1409 * S ^ 3 + 54 * S ^ 4)
      + A ^ 4 * (3370 + 9774 * S + 2700 * S ^ 2 + 180 * S ^ 3)
      + A ^ 5 * (732 + 1860 * S + 264 * S ^ 2)
      + A ^ 6 * (64 + 144 * S) := by
    have hA0 : (0 : ℚ) ≤ A := by rw [hA]; positivity
    have hS0 : (0 : ℚ) ≤ S := by rw [hS]; positivity
    positivity
  nlinarith [hpos]

/-- Assembling the geometric envelope, the head-to-total ratio and the quantitative window
inequality: `7 Σⱼ mⱼ³ (2P+1) ≤ 2P n³`, i.e. the cube sum falls short of the tie-free value
by a factor `1 - 1/(2P+1)`.  Here `P = v+1`, `V = v+r`, `R = r`, `N = n`, `M = m₀`,
`C = Σⱼ mⱼ³`. -/
lemma sparse_gap_algebra (C N M V R P : ℚ) (hN : 2 ≤ N) (hP : 1 ≤ P) (hV : 0 < V)
    (hVR : 0 < V ^ 3 - R ^ 3)
    (hgeom : C * (V ^ 3 - R ^ 3) ≤ M ^ 3 * V ^ 3)
    (hratio : N * P = M * (V + 1))
    (hwin : 7 * (2 * P + 1) * P ^ 3 * V ^ 3 ≤ 2 * P * ((V + 1) ^ 3 * (V ^ 3 - R ^ 3))) :
    7 * C * (2 * P + 1) ≤ 2 * P * N ^ 3 := by
  have hN0 : (0 : ℚ) < N := by linarith
  have hV1 : (0 : ℚ) < (V + 1) ^ 3 := by positivity
  have hcube : (M * (V + 1)) ^ 3 = (N * P) ^ 3 := by rw [hratio]
  have h1 : 7 * C * ((V ^ 3 - R ^ 3) * (V + 1) ^ 3) ≤ 7 * (M ^ 3 * V ^ 3) * (V + 1) ^ 3 := by
    nlinarith [mul_le_mul_of_nonneg_right hgeom (le_of_lt hV1)]
  have h2 : 7 * (M ^ 3 * V ^ 3) * (V + 1) ^ 3 = N ^ 3 * (7 * P ^ 3 * V ^ 3) := by
    linear_combination 7 * V ^ 3 * hcube
  have h3 : N ^ 3 * ((7 * (2 * P + 1)) * P ^ 3 * V ^ 3)
      ≤ N ^ 3 * (2 * P * ((V + 1) ^ 3 * (V ^ 3 - R ^ 3))) :=
    mul_le_mul_of_nonneg_left hwin (by positivity)
  have hchain : (7 * C * (2 * P + 1)) * ((V ^ 3 - R ^ 3) * (V + 1) ^ 3)
      ≤ (2 * P * N ^ 3) * ((V ^ 3 - R ^ 3) * (V + 1) ^ 3) := by
    have hmul : (7 * C * ((V ^ 3 - R ^ 3) * (V + 1) ^ 3)) * (2 * P + 1)
        ≤ (7 * (M ^ 3 * V ^ 3) * (V + 1) ^ 3) * (2 * P + 1) :=
      mul_le_mul_of_nonneg_right h1 (by linarith)
    nlinarith [hmul, h2, h3]
  have hpos : (0 : ℚ) < (V ^ 3 - R ^ 3) * (V + 1) ^ 3 := by positivity
  exact le_of_mul_le_mul_right hchain hpos

/-! ## 4. Closing the window, quantitatively -/

/-- **The window is closed, with a rate.**  For every fixed-weight draw law strictly below
half weight — weight `v+1` on `v+1+r` bits with `v ≥ 1` and `r ≥ v+2` — the trailing-zero
Spearman ceiling exceeds `6/7` by at least `1/(7(2v+3))`.

The rate is of the right order: the exact-rational sweep in the Lab Notes shows
`v(ρ² - 6/7) → 54/343 = 0.1574…` along `r = v+2`, while the proved bound gives
`v(ρ² - 6/7) > v/(7(2v+3)) → 1/14 = 0.0714…`. -/
theorem window_gap_quantitative (v r : ℕ) (hv : 1 ≤ v) (hr : v + 2 ≤ r) :
    6 / 7 + 1 / (7 * (2 * (v : ℚ) + 3)) < spearmanSq (balancedBlocks v r) := by
  obtain ⟨a, rfl⟩ : ∃ a, v = a + 1 := ⟨v - 1, by omega⟩
  obtain ⟨s, rfl⟩ : ∃ s, r = a + 3 + s := ⟨r - (a + 3), by omega⟩
  set v := a + 1 with hvdef
  set r := a + 3 + s with hrdef
  have hsum : (balancedBlocks v r).sum = (v + 1 + r).choose (v + 1) := balancedBlocks_sum v r
  have hsum2 : 2 ≤ (balancedBlocks v r).sum := by
    rw [hsum]
    have h := Nat.choose_le_choose (v + 1) (by omega : v + 1 + 1 ≤ v + 1 + r)
    have e : (v + 1 + 1).choose (v + 1) = v + 2 := by rw [Nat.choose_succ_self_right]
    omega
  have hNQ : (2 : ℚ) ≤ (((balancedBlocks v r).sum : ℕ) : ℚ) := by exact_mod_cast hsum2
  have hratio : (((balancedBlocks v r).sum : ℕ) : ℚ) * ((v : ℚ) + 1)
      = ((((v + r).choose v : ℕ)) : ℚ) * (((v : ℚ) + r) + 1) := by
    rw [hsum]
    have hc := (Nat.cast_inj (R := ℚ)).2 (sum_head_ratio v r)
    push_cast at hc
    linear_combination hc
  have hgeom := geom_cube_bound v (by omega) r
  have hvc : (v : ℚ) = (a : ℚ) + 1 := by rw [hvdef]; push_cast; ring
  have hrc : (r : ℚ) = (a : ℚ) + 3 + s := by rw [hrdef]; push_cast; ring
  have hv0 : (0 : ℚ) < (v : ℚ) := by rw [hvc]; positivity
  have hVR : (0 : ℚ) < ((v : ℚ) + r) ^ 3 - (r : ℚ) ^ 3 := by
    have hr0 : (0 : ℚ) ≤ (r : ℚ) := Nat.cast_nonneg r
    have e : ((v : ℚ) + r) ^ 3 - (r : ℚ) ^ 3
        = (v : ℚ) * (((v : ℚ) + r) ^ 2 + ((v : ℚ) + r) * (r : ℚ) + (r : ℚ) ^ 2) := by ring
    rw [e]
    have hb : (0 : ℚ) < ((v : ℚ) + r) ^ 2 + ((v : ℚ) + r) * (r : ℚ) + (r : ℚ) ^ 2 := by
      nlinarith [hv0, hr0]
    exact mul_pos hv0 hb
  have hwin : 7 * (2 * ((v : ℚ) + 1) + 1) * ((v : ℚ) + 1) ^ 3 * ((v : ℚ) + r) ^ 3
      ≤ 2 * ((v : ℚ) + 1)
        * ((((v : ℚ) + r) + 1) ^ 3 * (((v : ℚ) + r) ^ 3 - (r : ℚ) ^ 3)) := by
    have h := window_algebra_sharp a s
    rw [hvc, hrc]
    nlinarith [h]
  have hgap := sparse_gap_algebra (cubeSum (balancedBlocks v r))
    (((balancedBlocks v r).sum : ℕ) : ℚ) ((((v + r).choose v : ℕ)) : ℚ)
    ((v : ℚ) + r) (r : ℚ) ((v : ℚ) + 1) hNQ (by linarith) (by linarith [Nat.cast_nonneg (α := ℚ) r])
    hVR hgeom hratio hwin
  have hW : (0 : ℚ) < 7 * (2 * (v : ℚ) + 3) := by positivity
  have hrw : (1 : ℚ) - (6 / 7 + 1 / (7 * (2 * (v : ℚ) + 3)))
      = (2 * (v : ℚ) + 2) / (7 * (2 * (v : ℚ) + 3)) := by
    field_simp
    ring
  rw [lt_spearmanSq_iff _ hsum2, hrw, ← mul_div_assoc, lt_div_iff₀ hW]
  nlinarith [hgap, hNQ, hv0]

/-- **The window is closed.**  For every fixed-weight draw law strictly below half weight —
weight `v+1` on `v+1+r` bits with `v ≥ 1` and `r ≥ v+2` — the trailing-zero Spearman
ceiling is strictly above `6/7`.  This covers the whole previously undecided band
`1/3 < w/b < 1/2` and, with `sparse_ceiling_gt` of cycle 5 as a special case, the entire
sparse half of the weight axis. -/
theorem window_ceiling_gt (v r : ℕ) (hv : 1 ≤ v) (hr : v + 2 ≤ r) :
    6 / 7 < spearmanSq (balancedBlocks v r) := by
  have h := window_gap_quantitative v r hv hr
  have hpos : (0 : ℚ) < 1 / (7 * (2 * (v : ℚ) + 3)) := by positivity
  linarith

/-! ## 5. The capstone: one boundary, at half weight -/

/-- **The sign of `ρ² - 6/7` is decided by the weight fraction alone.**  For a fixed-weight
draw law of weight `v+1 ≥ 2` on bitlen `v+1+r ≥ v+2`, the ceiling exceeds the universal
tie-attenuation constant `6/7` exactly when the weight is strictly below half. -/
theorem dial_sign_iff (v r : ℕ) (hv : 1 ≤ v) (h1 : 1 ≤ r) :
    6 / 7 < spearmanSq (balancedBlocks v r) ↔ v + 2 ≤ r := by
  constructor
  · intro h
    by_contra hc
    have hle := half_weight_boundary v r hv h1 (by omega)
    linarith
  · intro h
    exact window_ceiling_gt v r hv h

/-- The same statement in the coordinates of the draw law: weight `w = v+1`, bitlen
`b = v+1+r`.  The dial's tie attenuation crosses `6/7` exactly at half weight `2w = b`. -/
theorem half_weight_dichotomy (v r : ℕ) (hv : 1 ≤ v) (h1 : 1 ≤ r) :
    (v + 1 + r ≤ 2 * (v + 1) → spearmanSq (balancedBlocks v r) ≤ 6 / 7)
      ∧ (2 * (v + 1) < v + 1 + r → 6 / 7 < spearmanSq (balancedBlocks v r)) := by
  refine ⟨fun h => half_weight_boundary v r hv h1 (by omega), fun h => ?_⟩
  exact window_ceiling_gt v r hv (by omega)

/-- The deployment reading, revisited.  Whatever the weight fraction of the draw law, the
recorded band `[0.55, 0.85]` never touches the sparse regime: below half weight the ceiling
is above `6/7 = 0.857…`, so `0.85² = 0.7225 < 6/7` leaves genuine headroom, and the
observed `ρ = 0.669` is far from ceiling-limited. -/
theorem sparse_regime_has_headroom (v r : ℕ) (hv : 1 ≤ v) (hr : v + 2 ≤ r)
    (rho : ℚ) (hlo : 55 / 100 ≤ rho) (hhi : rho ≤ 85 / 100) :
    rho ^ 2 < spearmanSq (balancedBlocks v r) := by
  have h := window_ceiling_gt v r hv hr
  nlinarith [h, hlo, hhi]

/-!
## Lab Notes (cycles 6–7)

Exact rational check of the geometric envelope `Σⱼ mⱼ³ ≤ m₀³ (v+r)³ / ((v+r)³ - r³)` and of
the window inequality `7(v+1)³(v+r)³ < (v+r+1)³((v+r)³ - r³)` at the boundary `r = v+2`:

| `v` | `r = v+2` | envelope slack `m₀³(v+r)³ − C·((v+r)³−r³)` | window ratio `(v+r+1)³((v+r)³−r³) / (7(v+1)³(v+r)³)` |
|-----|-----------|--------------------------------------------|------------------------------------------------------|
| 1 | 3 | > 0 | 4625/3584 = 1.2905 |
| 2 | 4 | > 0 | 52136/40824 = 1.2771 |
| 10 | 12 | > 0 | 108529640/99207416 = 1.0940 |
| 20 | 22 | > 0 | 5043924080/4802902776 = 1.0502 |
| 100 | 102 | > 0 | 1.0106 |

The ratio decreases towards `1` as `v → ∞`: at `r = v+2` the window inequality reads
`7 + 7.5/(v+1) + O(v⁻²) > 7`, so the estimate is tight to first order — which is precisely
why the phase boundary lands on the single lattice step `r = v+1 → r = v+2` and not
somewhere in the interior of the weight axis.

Asymptotic bookkeeping with `r = c·v`, `v → ∞`:

```
(1+c)³ − c³ = 3c² + 3c + 1   >   7   ⟺   c > 1   ⟺   weight fraction < 1/2.
```

So the two constants of the story — the tie-attenuation ceiling `6/7` and the half-weight
line — are the same statement: `3·1² + 3·1 + 1 = 7`.

Cross-check of `dial_sign_iff` by exact rational sweep, `1 ≤ v ≤ 40`, `1 ≤ r ≤ 6v+5`:
0 violations (no `r ≤ v+1` with `ρ² > 6/7`, no `r ≥ v+2` with `ρ² ≤ 6/7`), matching the
table in `Pythagorean.ZeroFitDialHalfWeightBoundary60`.  The geometric envelope
`geom_cube_bound` was checked exactly on the same sweep: 0 violations.

**The scaling law across the boundary (cycle 7).**  Put `r = v+1+k`, so `k = 0` is the
balanced law and `k ≥ 1` is the sparse side.  Exact rational values of
`343·v·(ρ²(v, v+1+k) − 6/7)`:

| `k` | `v = 50` | `v = 100` | `v = 200` | `v = 400` | `v = 800` | limit |
|-----|----------|-----------|-----------|-----------|-----------|-------|
| −2 | −137.36 | −136.18 | −135.59 | −135.29 | −135.15 | −135 |
| −1 | −71.966 | −71.984 | −71.992 | −71.996 | −71.998 | −72 |
| 0 | −8.9958 | −8.9980 | −8.9990 | −8.9995 | −8.9998 | −9 |
| 1 | 51.671 | 52.813 | 53.401 | 53.699 | 53.849 | 54 |
| 2 | 110.14 | 113.48 | 115.21 | 116.10 | 116.55 | 117 |
| 3 | 166.52 | 173.02 | 176.45 | 178.21 | 179.10 | 180 |

The limits are `63k − 9`, an arithmetic progression of common difference `63 = 9·7`:

```
lim_{v→∞} v (ρ²(v, v+1+k) − 6/7) = 9(7k − 1)/343.
```

At `k = 0` this recovers the Catalan deficit constant `−9/343` of
`Pythagorean.ZeroFitDialBalancedClosure60`, and the zero of the law sits at the *fractional*
index `k = 1/7` — between the two lattice points `k = 0` and `k = 1`.  That is the
quantitative reason `dial_sign_iff` flips exactly at `r = v+2`, and why no fixed-weight law
can sit asymptotically *on* the constant `6/7`.

`window_gap_quantitative` proves the sparse half of this picture with an explicit rate:
`ρ² − 6/7 > 1/(7(2v+3))`, i.e. `v(ρ² − 6/7) > 1/14 − o(1) = 0.0714…`, against the true
`k = 1` value `54/343 = 0.1574…` — the same order, within a factor `2.2`.
-/

end Catalog.Pythagorean.ZeroFitDialSparseWindow60