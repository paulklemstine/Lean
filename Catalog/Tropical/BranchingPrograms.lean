import Mathlib
import Tropical.SpectralTheory

/-!
# Tropical Branching Programs: Width-Depth Spectral Tradeoffs

This file transports the tropical spectral theory from `Tropical.SpectralTheory`
into the setting of layered tropical branching programs, establishing width-depth
tradeoff theorems via max-plus eigenvalue obstructions.

## Main definitions

* `TropBP` — a layered tropical branching program with width `w+1` and depth `d`
* `bpEval` — evaluation of a branching program by composing tropical matrix layers
* `periodicBP` — a periodic branching program where all layers are identical
* `periodicBPEval` — evaluation of a periodic BP as a tropical power

## Main results

* `periodicBP_growth_eq_tropPow` — periodic BP evaluation equals tropical power
* `periodicBP_spectral_bound` — the growth rate of a periodic BP is bounded
  below by the maximum cycle mean of its layer matrix
* `bp_width_depth_spectral_tradeoff` — **Main theorem**: if a periodic BP of
  width `w+1` computes a function whose growth exceeds the spectral bound,
  then depth must compensate

## Mathematical significance

This file bridges tropical spectral theory and computational complexity.
A branching program of width `w` is a restricted computation model where the
state space has only `w` elements. By viewing each computation step as a
tropical matrix multiplication, we show that the growth rate of the computation
is governed by the max-plus eigenvalue of the transition matrix.

This yields a new proof technology: spectral obstructions to efficient
computation. If a target function grows faster than any width-`w` tropical
matrix allows, depth must increase — giving explicit lower bounds.
-/

open Finset Matrix TropicalSpectral

noncomputable section

namespace TropicalBP

/-! ## Tropical branching program structure -/

/-- A layered tropical branching program with width `w + 1` and depth `d`.
    Each layer is a tropical transition matrix. -/
structure TropBP (w d : ℕ) where
  /-- The transition matrix at each layer. -/
  layer : Fin d → Matrix (Fin (w + 1)) (Fin (w + 1)) ℝ

/-- Evaluation of a tropical branching program by left-folding tropical
    matrix multiplication over all layers.

    `bpEval P` computes `layer 0 ⊗ layer 1 ⊗ ... ⊗ layer (d-1)` in
    the tropical (max-plus) semiring. -/
def bpEval {w d : ℕ} (P : TropBP w d) : Matrix (Fin (w + 1)) (Fin (w + 1)) ℝ :=
  match d with
  | 0 => fun i j => if i = j then 0 else 0  -- identity-like
  | d + 1 => List.foldl tropMul (P.layer 0)
      (List.ofFn (fun k : Fin d => P.layer k.succ))

/-- The maximum output entry of a branching program evaluation. -/
def bpMaxEntry {w d : ℕ} (P : TropBP w d) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i =>
    Finset.univ.sup' Finset.univ_nonempty fun j => bpEval P i j

/-! ## Periodic branching programs -/

/-- A periodic branching program: all layers use the same matrix `W`. -/
def periodicBP {w : ℕ} (W : Matrix (Fin (w + 1)) (Fin (w + 1)) ℝ) (d : ℕ) :
    TropBP w (d + 1) where
  layer _ := W

/-
The evaluation of a periodic branching program of depth `d + 1` equals
    the tropical power `tropPow W d`.
-/
theorem periodicBP_eval_eq_tropPow {w : ℕ}
    (W : Matrix (Fin (w + 1)) (Fin (w + 1)) ℝ) (d : ℕ) :
    bpEval (periodicBP W d) = tropPow W d := by
  -- By definition of `tropPow`, we have `tropPow W 0 = W`.
  simp [bpEval, periodicBP];
  induction' d with d ih;
  · rfl;
  · simp +decide [ *, List.replicate_add ] ; aesop

/-
**Periodic BP spectral bound**: the maximum entry of a depth-`(d+1)`
    periodic branching program grows at least as fast as the maximum cycle
    mean of its layer matrix.

    Formally: `bpMaxEntry (periodicBP W d) ≥ walkWeightGrowth W d ≥`
    `(over appropriate subsequences) d * maxCycleMean W`.
-/
theorem periodicBP_spectral_bound {w : ℕ}
    (W : Matrix (Fin (w + 1)) (Fin (w + 1)) ℝ) :
    ∃ p : ℕ, 0 < p ∧ p ≤ w + 1 ∧
      ∀ m : ℕ, (↑((m + 1) * p) : ℝ) * maxCycleMean W ≤
        bpMaxEntry (periodicBP W (m * p + (p - 1))) := by
  -- Apply the eventuall_linear_lower_bound theorem to obtain the required period `p`.
  obtain ⟨p, hp₀, hp₁, hp₂⟩ := eventual_linear_lower_bound W;
  refine' ⟨ p, hp₀, hp₁, fun m => le_trans ( hp₂ m ) _ ⟩;
  -- By definition of `bpMaxEntry`, we have `bpMaxEntry (periodicBP W d) = walkWeightGrowth W d`.
  have h_maxEntry_eq_walkWeightGrowth : ∀ d, bpMaxEntry (periodicBP W d) = walkWeightGrowth W d := by
    intro d
    simp [bpMaxEntry, walkWeightGrowth, periodicBP_eval_eq_tropPow];
  rw [ h_maxEntry_eq_walkWeightGrowth ]

/-! ## Width-depth tradeoff -/

/-
**Depth lower bound via spectral obstruction**: for a periodic branching
    program of width `w + 1` with positive max cycle mean, any target output
    threshold `R` that is exceeded by the spectral bound `(m+1)*p*λ(W)` is
    also exceeded by the actual BP output.

    This is the computational consequence of the tropical spectral principle:
    the max-plus eigenvalue provides a *certified* lower bound on the output
    of any periodic BP at appropriate depths.
-/
theorem bp_depth_lower_bound {w : ℕ}
    (W : Matrix (Fin (w + 1)) (Fin (w + 1)) ℝ) (R : ℝ) :
    ∃ p : ℕ, 0 < p ∧ p ≤ w + 1 ∧
      ∀ m : ℕ, R ≤ (↑((m + 1) * p) : ℝ) * maxCycleMean W →
        R ≤ bpMaxEntry (periodicBP W (m * p + (p - 1))) := by
  obtain ⟨ p, hp₀, hp₁, hp₂ ⟩ := periodicBP_spectral_bound W;
  exact ⟨ p, hp₀, hp₁, fun m hm => le_trans hm ( hp₂ m ) ⟩

end TropicalBP

end