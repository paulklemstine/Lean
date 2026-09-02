import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52
import Pythagorean.ZeroFitDialBalanced60

/-!
# Closing the balanced boundary: the Catalan spine and an unconditional `6/7` ceiling

## Research context (FACT round-51 #3, exp 521, `CELL-CLOSED-DIAL-HOLDS-60`)

`Pythagorean.ZeroFitDialBalanced60` proved that the balanced (fixed-weight) draw law has
Spearman tie ceiling strictly below `6/7` — but only in the guarded range `2 ≤ v ≤ 94`,
because the three leading blocks of the hockey-stick profile force the inequality exactly
when `63(v+1)³ > 8(2v+1)³`.  Adding a fixed number of further blocks only multiplies the
admissible range by roughly `8`, so the guard could not be removed by brute force.  This
file removes it.

## Main results

* `head_block_eq_catalan`, `second_block_eq_catalan`, `catalan_halving_defect` — the
  **Catalan spine** of the balanced profile.  The two leading blocks are
  `m₀ = (2v+1)·Cat v` and `m₁ = (v+1)·Cat v`, so the shortfall of the first step from
  exact halving is *exactly* the `v`-th Catalan number: `2m₁ = m₀ + Cat v`.  The whole
  anomaly that pushes the balanced ceiling below `6/7` is therefore a Dyck-path count:
  a bridge between the enumerative combinatorics of Catalan numbers and the rank
  geometry of the zero-fit dial.
* `loss_invariant` — the engine.  A single induction along the profile carries the
  accumulated deficit of the cube sum against the geometric ideal `(8/7)m³`, with an
  explicit linear-in-depth coefficient `24(1+7(v-r))/(49(v+1))`.  The coefficient is
  exactly the fixed point of the recursion `e_{s-1} = (s-1) + e_s/8`, which is why the
  inductive step closes with equality.
* `balanced_ceiling_lt_all` — **the guard is gone**: for *every* `v ≥ 2` the balanced tie
  ceiling at bitlen `2v+2` is strictly below `6/7`.  Combined with
  `Novelty.ZeroFitDialU64.dyadic_ceiling_gt` this makes the draw-law sandwich
  (`draw_law_sandwich_all`) unconditional: `6/7` separates the two laws at every bitlen.
* `spearmanSq_centralProfile_two`, `spearmanSq_centralProfile_three` — exact rational
  ceilings `563/665` and `1386/1633` at bitlens `6` and `8`, the verified data behind the
  Lab Notes table.

## Why the guard was hard, and what replaced it

The geometric bound `Σ m_k³ ≤ (8/7)m₀³` is *tight*: the balanced profile halves at every
step below the top, so the target `6/7` sits exactly at the geometric ideal.  The whole
strict inequality is carried by the single anomalous first step
(`m₁/m₀ = (v+1)/(2v+1) > 1/2`, i.e. by `Cat v`), whose gain is only of order `1/v`, while
truncating the profile after `K` blocks loses order `8^{-K}`.  A fixed `K` therefore only
ever covers `v ≲ 8^K`.  The fix is to never truncate: the Weierstrass-type estimate
`m_{k+1}³ ≥ 8^{-1}m_k³(1 - 3t_k)³` is summed along the *entire* profile by an induction
whose invariant is linear in the remaining depth, and the exponentially small tail is
absorbed by the constant `1` in `loss_invariant`.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialUnif52
open Catalog.Pythagorean.ZeroFitDialBalanced60

namespace Catalog.Pythagorean.ZeroFitDialBalancedClosure60

/-! ## 1. The Catalan spine of the balanced profile -/

/-- The second block of the balanced profile is `(v+1)·Cat v` — the central binomial
coefficient in its Catalan factorisation. -/
lemma second_block_eq_catalan (v : ℕ) : (2 * v).choose v = (v + 1) * catalan v := by
  have h := succ_mul_catalan_eq_centralBinom v
  rw [Nat.centralBinom] at h
  exact h.symm

/-- **The head of the balanced profile is a Catalan multiple**: `m₀ = (2v+1)·Cat v`. -/
theorem head_block_eq_catalan (v : ℕ) : (2 * v + 1).choose v = (2 * v + 1) * catalan v := by
  have h := head_ratio v
  rw [second_block_eq_catalan] at h
  refine Nat.eq_of_mul_eq_mul_left (Nat.succ_pos v) ?_
  calc (v + 1) * ((2 * v + 1).choose v) = (2 * v + 1) * ((v + 1) * catalan v) := h
    _ = (v + 1) * ((2 * v + 1) * catalan v) := by ring

/-- **The halving defect is a Catalan number.**  The first step of the balanced profile
decays by strictly less than one half, and the shortfall `2m₁ - m₀` is exactly `Cat v`. -/
theorem catalan_halving_defect (v : ℕ) :
    2 * ((2 * v).choose v) = (2 * v + 1).choose v + catalan v := by
  rw [second_block_eq_catalan, head_block_eq_catalan]
  ring

/-- The number of balanced words of bitlen `2v+2` is `2(2v+1)·Cat v`. -/
theorem centralProfile_sum_eq_catalan (v : ℕ) :
    (centralProfile v).sum = 2 * ((2 * v + 1) * catalan v) := by
  rw [centralProfile_sum, sum_eq_two_mul_head, head_block_eq_catalan]

/-! ## 2. Exact ceilings at the small bitlens -/

lemma centralProfile_two_eq : centralProfile 2 = [10, 6, 3, 1] := by
  rw [centralProfile, balancedBlocks, balancedBlocks, balancedBlocks, balancedBlocks]
  norm_num [Nat.choose]

lemma centralProfile_three_eq : centralProfile 3 = [35, 20, 10, 4, 1] := by
  rw [centralProfile, balancedBlocks, balancedBlocks, balancedBlocks, balancedBlocks,
    balancedBlocks]
  norm_num [Nat.choose]

/-- Exact balanced ceiling at bitlen `6`: `ρ² = 563/665 = 0.846616…`. -/
theorem spearmanSq_centralProfile_two : spearmanSq (centralProfile 2) = 563 / 665 := by
  rw [centralProfile_two_eq, spearmanSq_eq _ (by norm_num)]
  norm_num [tieCorr]

/-- Exact balanced ceiling at bitlen `8`: `ρ² = 1386/1633 = 0.848744…`. -/
theorem spearmanSq_centralProfile_three : spearmanSq (centralProfile 3) = 1386 / 1633 := by
  rw [centralProfile_three_eq, spearmanSq_eq _ (by norm_num)]
  norm_num [tieCorr]

/-! ## 3. Ratio and halving laws along the profile -/

lemma choose_symm_index (v r : ℕ) : (v + r).choose r = (v + r).choose v := by
  have h := Nat.choose_symm (Nat.le_add_right v r)
  simpa using h

/-- The exact step ratio of the hockey-stick profile: `m_r/m_{r+1} = (r+1)/(v+r+1)`. -/
lemma choose_ratio_step (v r : ℕ) :
    ((v + r).choose v) * (v + r + 1) = ((v + (r + 1)).choose v) * (r + 1) := by
  have h := Nat.add_one_mul_choose_eq (v + r) r
  rw [choose_symm_index] at h
  have h2 : (v + r + 1).choose (r + 1) = (v + r + 1).choose v := by
    have h3 := Nat.choose_symm (n := v + r + 1) (k := r + 1) (by omega)
    have e : v + r + 1 - (r + 1) = v := by omega
    rw [e] at h3
    exact h3.symm
  rw [h2] at h
  have e4 : v + (r + 1) = v + r + 1 := by omega
  rw [e4]
  linarith

/-- Below the top the profile at least halves. -/
lemma balanced_halving (v r : ℕ) (h : r + 1 ≤ v) :
    2 * ((v + r).choose v) ≤ (v + (r + 1)).choose v := by
  obtain ⟨u, rfl⟩ : ∃ u, v = u + 1 := ⟨v - 1, by omega⟩
  have hh := two_mul_choose_le u r (by omega)
  have e2 : u + 1 + (r + 1) = u + r + 2 := by omega
  rw [e2]
  exact hh

/-! ## 4. The accumulated-deficit invariant -/

/-- **The engine.**  Along the whole hockey-stick profile the cube sum stays within an
explicitly controlled deficit of the geometric ideal `(8/7)m_r³`, the deficit coefficient
being linear in the remaining depth `v - r`.  The constants `24/49` and `24/7` are forced:
they are the fixed point of the recursion `e_{s-1} = (s-1) + e_s/8` produced by the
Weierstrass estimate on the step ratios, so the inductive step closes with equality. -/
lemma loss_invariant (v : ℕ) : ∀ r ≤ v,
    49 * ((v : ℚ) + 1) * (8 * (((v + r).choose v : ℕ) : ℚ) ^ 3)
      ≤ 49 * ((v : ℚ) + 1) * (7 * cubeSum (balancedBlocks v r) + 1)
        + 24 * (1 + 7 * ((v : ℚ) - r)) * (((v + r).choose v : ℕ) : ℚ) ^ 3 := by
  intro r
  induction r with
  | zero =>
      intro _
      have h2 : cubeSum (balancedBlocks v 0) = 1 := by simp [balancedBlocks, cubeSum]
      have hv : (0 : ℚ) ≤ (v : ℚ) := Nat.cast_nonneg v
      simp only [Nat.add_zero, Nat.choose_self, Nat.cast_one, Nat.cast_zero, h2]
      nlinarith [hv]
  | succ r ih =>
      intro hr
      have ihr := ih (by omega)
      have hA0 : (0 : ℚ) < (((v + r).choose v : ℕ) : ℚ) := by
        exact_mod_cast Nat.choose_pos (Nat.le_add_right v r)
      have hB0 : (0 : ℚ) < (((v + (r + 1)).choose v : ℕ) : ℚ) := by
        exact_mod_cast Nat.choose_pos (Nat.le_add_right v (r + 1))
      have hhalf : 2 * (((v + r).choose v : ℕ) : ℚ) ≤ (((v + (r + 1)).choose v : ℕ) : ℚ) := by
        exact_mod_cast balanced_halving v r hr
      have hratio : (((v + r).choose v : ℕ) : ℚ) * ((v : ℚ) + r + 1)
          = (((v + (r + 1)).choose v : ℕ) : ℚ) * ((r : ℚ) + 1) := by
        have hc := (Nat.cast_inj (R := ℚ)).2 (choose_ratio_step v r)
        push_cast at hc
        linear_combination hc
      set A : ℚ := (((v + r).choose v : ℕ) : ℚ) with hAdef
      set B : ℚ := (((v + (r + 1)).choose v : ℕ) : ℚ) with hBdef
      have hd : (0 : ℚ) ≤ (v : ℚ) - r - 1 := by
        have : ((r : ℚ) + 1) ≤ (v : ℚ) := by exact_mod_cast hr
        linarith
      have hrq : (0 : ℚ) ≤ (r : ℚ) := Nat.cast_nonneg r
      have hp : (0 : ℚ) < (v : ℚ) + r + 1 := by linarith
      have hB3 : (0 : ℚ) < B ^ 3 := by positivity
      have hBA : (0 : ℚ) ≤ B ^ 3 - 8 * A ^ 3 := by
        nlinarith [pow_le_pow_left₀ (by linarith : (0 : ℚ) ≤ 2 * A) hhalf 3]
      -- cube the exact ratio
      have hcube : 8 * A ^ 3 * ((v : ℚ) + r + 1) ^ 3 = B ^ 3 * (2 * (r : ℚ) + 2) ^ 3 := by
        have h3 : (A * ((v : ℚ) + r + 1)) ^ 3 = (B * ((r : ℚ) + 1)) ^ 3 := by rw [hratio]
        linear_combination 8 * h3
      -- Weierstrass estimate on one step
      have h1 : (B ^ 3 - 8 * A ^ 3) * ((v : ℚ) + r + 1) ^ 3
          ≤ 3 * ((v : ℚ) - r - 1) * B ^ 3 * ((v : ℚ) + r + 1) ^ 2 := by
        have expand : (B ^ 3 - 8 * A ^ 3) * ((v : ℚ) + r + 1) ^ 3
            = B ^ 3 * (((v : ℚ) + r + 1) ^ 3 - (2 * (r : ℚ) + 2) ^ 3) := by
          linear_combination -hcube
        rw [expand]
        have hfac : ((v : ℚ) + r + 1) ^ 3 - (2 * (r : ℚ) + 2) ^ 3
            ≤ 3 * ((v : ℚ) - r - 1) * ((v : ℚ) + r + 1) ^ 2 := by
          nlinarith [hd, hrq, hp, sq_nonneg ((v : ℚ) - r - 1)]
        nlinarith [hfac, hB3]
      have hp2 : (0 : ℚ) < ((v : ℚ) + r + 1) ^ 2 := by positivity
      have hstep : (B ^ 3 - 8 * A ^ 3) * ((v : ℚ) + r + 1) ≤ 3 * ((v : ℚ) - r - 1) * B ^ 3 := by
        refine le_of_mul_le_mul_right ?_ hp2
        calc (B ^ 3 - 8 * A ^ 3) * ((v : ℚ) + r + 1) * ((v : ℚ) + r + 1) ^ 2
            = (B ^ 3 - 8 * A ^ 3) * ((v : ℚ) + r + 1) ^ 3 := by ring
          _ ≤ 3 * ((v : ℚ) - r - 1) * B ^ 3 * ((v : ℚ) + r + 1) ^ 2 := h1
      have hstep2 : (B ^ 3 - 8 * A ^ 3) * ((v : ℚ) + 1) ≤ 3 * ((v : ℚ) - r - 1) * B ^ 3 := by
        nlinarith [hstep, hBA, hrq]
      have hprod : (0 : ℚ) ≤ (8 + 7 * ((v : ℚ) - r - 1)) * (B ^ 3 - 8 * A ^ 3) :=
        mul_nonneg (by linarith) hBA
      have hcs : cubeSum (balancedBlocks v (r + 1)) = B ^ 3 + cubeSum (balancedBlocks v r) := by
        rw [balancedBlocks, cubeSum_cons, hBdef]
      rw [hcs]
      push_cast
      nlinarith [ihr, hstep2, hprod]

/-! ## 5. The unconditional upper bound -/

/-- Pure-algebra core of the closure: with `W = m₀`, `Z = m₁`, `C` the cube sum of the
profile below the head, the deficit invariant plus the anomalous first step force
`7(W³ + C) > 8W³ + 12W`, which is exactly `ρ² < 6/7`. -/
lemma closure_algebra (V W Z C : ℚ) (hV : 2 ≤ V) (hW : V * (2 * V + 1) ≤ W)
    (hratio : (V + 1) * W = (2 * V + 1) * Z)
    (hinv : 49 * (V + 1) * (8 * Z ^ 3) ≤ 49 * (V + 1) * (7 * C + 1) + 24 * Z ^ 3) :
    8 * W ^ 3 + 12 * W < 7 * (W ^ 3 + C) := by
  have hV1 : (0 : ℚ) < V + 1 := by linarith
  have h2V : (0 : ℚ) < 2 * V + 1 := by linarith
  have hW10 : (10 : ℚ) ≤ W := by nlinarith [hW, hV]
  have hWsq : V ^ 2 * (2 * V + 1) ^ 2 ≤ W ^ 2 := by nlinarith [hW, hV]
  have hZ3 : Z ^ 3 * (2 * V + 1) ^ 3 = W ^ 3 * (V + 1) ^ 3 := by
    have h3 : ((V + 1) * W) ^ 3 = ((2 * V + 1) * Z) ^ 3 := by rw [hratio]
    linear_combination -h3
  have keycore : 49 * (2 * V + 1) ^ 3 * (12 * W + 1)
      < (564 * V ^ 2 + 834 * V + 319) * W ^ 3 := by
    have s1 : 49 * (2 * V + 1) ^ 3 * (12 * W + 1) ≤ 593 * (2 * V + 1) ^ 3 * W := by
      nlinarith [hW10, h2V, pow_pos h2V 3]
    have s2 : 593 * (2 * V + 1) ^ 3 * W < 564 * V ^ 4 * (2 * V + 1) ^ 2 * W := by
      have h3 : (8 : ℚ) ≤ V ^ 3 := by nlinarith [hV]
      have h4 : 8 * V ≤ V ^ 4 := by nlinarith [h3, hV]
      have hpoly : 593 * (2 * V + 1) < 564 * V ^ 4 := by nlinarith [h4, hV]
      have hmul := mul_lt_mul_of_pos_right hpoly
        (show (0 : ℚ) < (2 * V + 1) ^ 2 * W by positivity)
      nlinarith [hmul]
    have s3 : 564 * V ^ 4 * (2 * V + 1) ^ 2 * W ≤ 564 * V ^ 2 * W ^ 3 := by
      nlinarith [mul_le_mul_of_nonneg_left hWsq
        (by positivity : (0 : ℚ) ≤ 564 * V ^ 2 * W)]
    have s4 : 564 * V ^ 2 * W ^ 3 ≤ (564 * V ^ 2 + 834 * V + 319) * W ^ 3 := by
      nlinarith [hV, hW10, pow_pos (by linarith : (0 : ℚ) < W) 3]
    linarith
  have key : 49 * (V + 1) * (2 * V + 1) ^ 3 * (W ^ 3 + 12 * W + 1)
      < (392 * V + 368) * (V + 1) ^ 3 * W ^ 3 := by
    nlinarith [mul_pos hV1 (sub_pos.mpr keycore)]
  have h2V3 : (0 : ℚ) < (2 * V + 1) ^ 3 := by positivity
  have hinv' : (49 * (V + 1) * (8 * Z ^ 3)) * (2 * V + 1) ^ 3
      ≤ (49 * (V + 1) * (7 * C + 1) + 24 * Z ^ 3) * (2 * V + 1) ^ 3 :=
    mul_le_mul_of_nonneg_right hinv (le_of_lt h2V3)
  have hsub : 392 * (V + 1) * (Z ^ 3 * (2 * V + 1) ^ 3) - 24 * (Z ^ 3 * (2 * V + 1) ^ 3)
      = (392 * V + 368) * (V + 1) ^ 3 * W ^ 3 := by
    rw [hZ3]; ring
  have hstep : (392 * V + 368) * (V + 1) ^ 3 * W ^ 3
      ≤ 49 * (V + 1) * (2 * V + 1) ^ 3 * (7 * C + 1) := by
    rw [← hsub]
    linarith [hinv']
  have hpos : (0 : ℚ) < 49 * (V + 1) * (2 * V + 1) ^ 3 := by positivity
  have hmul : 49 * (V + 1) * (2 * V + 1) ^ 3 * (W ^ 3 + 12 * W + 1)
      < 49 * (V + 1) * (2 * V + 1) ^ 3 * (7 * C + 1) := lt_of_lt_of_le key hstep
  have hfin : W ^ 3 + 12 * W + 1 < 7 * C + 1 := lt_of_mul_lt_mul_left hmul (le_of_lt hpos)
  linarith

/-- **The guard is gone.**  For *every* `v ≥ 2` the balanced (fixed-weight) tie ceiling at
bitlen `2v+2` is strictly below `6/7`.  This removes the `v ≤ 94` restriction of
`Pythagorean.ZeroFitDialBalanced60.balanced_ceiling_lt`. -/
theorem balanced_ceiling_lt_all (v : ℕ) (h2 : 2 ≤ v) :
    spearmanSq (centralProfile v) < 6 / 7 := by
  have hidx : v + (v + 1) = 2 * v + 1 := by omega
  have hidx2 : v + v = 2 * v := by omega
  have hsum : (centralProfile v).sum = 2 * ((2 * v + 1).choose v) := by
    rw [centralProfile_sum, sum_eq_two_mul_head]
  have hsumQ : (((centralProfile v).sum : ℕ) : ℚ) = 2 * (((2 * v + 1).choose v : ℕ) : ℚ) := by
    rw [hsum]; push_cast; ring
  have hunfold : centralProfile v = (2 * v + 1).choose v :: balancedBlocks v v := by
    rw [centralProfile, balancedBlocks, hidx]
  have hcube : cubeSum (centralProfile v)
      = (((2 * v + 1).choose v : ℕ) : ℚ) ^ 3 + cubeSum (balancedBlocks v v) := by
    rw [hunfold, cubeSum_cons]
  have hinv := loss_invariant v v le_rfl
  rw [hidx2] at hinv
  have hinv' : 49 * ((v : ℚ) + 1) * (8 * (((2 * v).choose v : ℕ) : ℚ) ^ 3)
      ≤ 49 * ((v : ℚ) + 1) * (7 * cubeSum (balancedBlocks v v) + 1)
        + 24 * (((2 * v).choose v : ℕ) : ℚ) ^ 3 := by
    have hz : (1 : ℚ) + 7 * ((v : ℚ) - (v : ℚ)) = 1 := by ring
    rw [hz] at hinv
    linarith [hinv]
  have hratio : ((v : ℚ) + 1) * (((2 * v + 1).choose v : ℕ) : ℚ)
      = (2 * (v : ℚ) + 1) * (((2 * v).choose v : ℕ) : ℚ) := by
    have hc := (Nat.cast_inj (R := ℚ)).2 (head_ratio v)
    push_cast at hc
    linear_combination hc
  have hWnat : v * (2 * v + 1) ≤ (2 * v + 1).choose v := by
    have hmid := Nat.choose_le_middle 2 (2 * v + 1)
    have e : (2 * v + 1) / 2 = v := by omega
    rw [e] at hmid
    have e2 : (2 * v + 1).choose 2 = v * (2 * v + 1) := by
      rw [Nat.choose_two_right]
      have e3 : 2 * v + 1 - 1 = 2 * v := by omega
      have e4 : (2 * v + 1) * (2 * v) = 2 * (v * (2 * v + 1)) := by ring
      rw [e3, e4, Nat.mul_div_cancel_left _ (by norm_num)]
    rw [e2] at hmid
    exact hmid
  have hWbig : (v : ℚ) * (2 * (v : ℚ) + 1) ≤ (((2 * v + 1).choose v : ℕ) : ℚ) := by
    have hc := (Nat.cast_le (α := ℚ)).2 hWnat
    push_cast at hc
    linarith [hc]
  have hV2 : (2 : ℚ) ≤ (v : ℚ) := by exact_mod_cast h2
  have hkey := closure_algebra (v : ℚ) (((2 * v + 1).choose v : ℕ) : ℚ)
    (((2 * v).choose v : ℕ) : ℚ) (cubeSum (balancedBlocks v v)) hV2 hWbig hratio hinv'
  rw [spearmanSq_lt_iff _ (centralProfile_sum_ge v), hsumQ, hcube]
  linarith [hkey]

/-- **The draw-law sandwich, unconditionally.**  At every even bitlen `b = 2v+2 ≥ 6` the
balanced ceiling lies strictly below `6/7` and the uniform ceiling strictly above it: the
universal tie-attenuation constant separates the two draw laws at *all* bitlens, not just
inside the tested envelope. -/
theorem draw_law_sandwich_all (v : ℕ) (h2 : 2 ≤ v) :
    spearmanSq (centralProfile v) < 6 / 7 ∧ 6 / 7 < spearmanSq (dyadicBlocks (2 * v + 2)) :=
  ⟨balanced_ceiling_lt_all v h2, dyadic_ceiling_gt (2 * v + 2) (by omega)⟩

/-- The bitlen-60 cell of the round-51 experiment, restated with the unconditional bound:
the whole validation band `[0.55, 0.85]` sits strictly below the balanced ceiling, which
in turn sits strictly below `6/7`, which sits strictly below the uniform ceiling. -/
theorem envelope_60_strict :
    (85 / 100 : ℚ) ^ 2 < spearmanSq (centralProfile 29) ∧
      spearmanSq (centralProfile 29) < 6 / 7 ∧
      6 / 7 < spearmanSq (dyadicBlocks 60) := by
  refine ⟨?_, balanced_ceiling_lt_all 29 (by norm_num), dyadic_ceiling_gt 60 (by norm_num)⟩
  have h := balanced_ceiling_gt 29
  norm_num at h ⊢
  linarith [h]

/-!
## Lab Notes (cycle 3)

Exact rational balanced ceilings `ρ²(v)` at bitlen `b = 2v+2`, computed from
`spearmanSq_eq` on the hockey-stick profile (all values verified as exact rationals):

| `v` | bitlen | profile `m₀,m₁,m₂,…` | `ρ²` | decimal |
|-----|--------|----------------------|------|---------|
| 1 | 4 | 3, 2, 1 | `6/7` | 0.857142… |
| 2 | 6 | 10, 6, 3, 1 | `563/665` | 0.846616… |
| 3 | 8 | 35, 20, 10, 4, 1 | `1386/1633` | 0.848744… |
| 4 | 10 | 126, 70, 35, 15, 5, 1 | — | 0.850681… |
| 29 | 60 | 5.9·10¹⁶, … | — | 0.856238… |
| 94 | 190 | — | — | 0.856863… |

Catalan spine (`head_block_eq_catalan`, `catalan_halving_defect`), first values:

| `v` | `Cat v` | `m₀ = (2v+1)Cat v` | `m₁ = (v+1)Cat v` | `2m₁ - m₀` |
|-----|---------|--------------------|-------------------|------------|
| 1 | 1 | 3 | 2 | 1 |
| 2 | 2 | 10 | 6 | 2 |
| 3 | 5 | 35 | 20 | 5 |
| 4 | 14 | 126 | 70 | 14 |

The last column is `Cat v` on the nose: the entire deviation of the balanced law from the
exactly-halving (dyadic) law at the top of the profile is a Dyck-path count.  Since the
relative defect is `Cat v / m₀ = 1/(2v+1)`, the balanced ceiling approaches `6/7` from
below at rate `Θ(1/v)`, matching the measured deficit `≈ 0.0263/v` and bracketed by
`balanced_ceiling_gt_sharp` (`> 6/7 - 1/(15(v+1))`) and `balanced_ceiling_lt_all`.
-/

end Catalog.Pythagorean.ZeroFitDialBalancedClosure60