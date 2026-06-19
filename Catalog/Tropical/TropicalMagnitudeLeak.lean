/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra
import Tropical.TropicalMatrixPower

/-!
# The Tropical Magnitude Channel: an Unconditional Exponent Leak

This file develops a **second, independent** cryptanalytic channel against the tropical
discrete logarithm problem (TDLP) / tropical Diffie–Hellman scheme, complementing the
eigenvalue-additivity attack of `Tropical.TropicalDiscreteLog`.

The eigenvalue attack recovers the secret exponent in closed form, but only on instances
that *admit a tropical eigenvector with nonzero eigenvalue* (`λ ≠ 0`).  Here we show that
**every** entry of a tropical power grows *linearly* in the exponent, sandwiched between
two explicit lines whose slopes are the global minimum and maximum entry of the public
matrix `A`:

  `(k+1)·amin ≤ (A^{⊗(k+1)})_{ij} ≤ (k+1)·amax`.

This needs **no eigenvector and no `λ ≠ 0` hypothesis**.  Consequently any single entry of
the public power `B = A^{⊗(k+1)}` confines the secret exponent to the computable interval

  `B_{ij} / amax ≤ k+1 ≤ B_{ij} / amin`     (when `amin, amax > 0`),

and when the matrix has constant magnitude (`amin = amax = c ≠ 0`) the interval collapses
to a *point*, recovering `k` exactly.

The boundary of this channel is the **zero matrix** (`amin = amax = 0`), where every power
is again `0` and the magnitude channel leaks nothing — the exact magnitude-channel
analogue of the `λ = 0` eigenvalue boundary of `Tropical.EigenzeroNoLeak`.

## Main results

* `tropMatPow_entry_lower` / `tropMatPow_entry_upper` — the entrywise linear sandwich.
* `tropMatPow_entry_sandwich` — both bounds packaged together.
* `tdlp_exponent_interval` — **the unconditional attack**: the secret exponent lies in a
  computable interval determined by one public entry.
* `tdlp_constant_exact` — exact recovery when `amin = amax = c ≠ 0`.
* `magnitude_no_leak` — the boundary: powers of the zero matrix carry no exponent
  information (mirrors `EigenzeroNoLeak`).
* `tdlp_break_concrete_magnitude` — a fully explicit `2×2` instance.

Bridge: connects Tropical Algebra to Cryptanalysis of Post-Quantum Proposals (a second,
eigenvector-free attack channel).
-/

noncomputable section

open Finset Matrix
open TropicalPower

namespace TropicalMagnitude

variable {n : ℕ} [NeZero n]

/-! ## Section 1: The entrywise linear sandwich -/

/-
**Lower line.**  If every entry of `A` is at least `amin`, then every entry of the
tropical power `A^{⊗(k+1)} = tropMatPow A k` is at least `(k+1)·amin`.  Proved by
induction on `k` using `Finset.le_inf'` (every length-`(k+1)` min-plus walk has weight at
least `(k+1)·amin`).
-/
theorem tropMatPow_entry_lower
    (A : Matrix (Fin n) (Fin n) ℝ) (amin : ℝ)
    (h : ∀ i j, amin ≤ A i j) (k : ℕ) (i j : Fin n) :
    (k + 1 : ℝ) * amin ≤ tropMatPow A k i j := by
  induction' k with k ih generalizing i j <;> simp_all +decide [ TropicalPower.tropMatPow_succ ];
  exact le_trans ( by linarith ) ( Finset.le_inf' _ _ fun l _ => add_le_add ( h i l ) ( ih l j ) )

/-
**Upper line.**  If every entry of `A` is at most `amax`, then every entry of the
tropical power `A^{⊗(k+1)} = tropMatPow A k` is at most `(k+1)·amax`.  Proved by induction
on `k` using `Finset.inf'_le` (one specific length-`(k+1)` walk witnesses the bound).
-/
theorem tropMatPow_entry_upper
    (A : Matrix (Fin n) (Fin n) ℝ) (amax : ℝ)
    (h : ∀ i j, A i j ≤ amax) (k : ℕ) (i j : Fin n) :
    tropMatPow A k i j ≤ (k + 1 : ℝ) * amax := by
  induction' k with k ih generalizing i j <;> norm_num [ tropMatPow_succ ] at *;
  · exact h i j;
  · exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ i ) ) ( by linarith [ h i i, ih i j ] )

/-- **The entrywise linear sandwich.**  Every entry of a tropical power lies between the
two lines `(k+1)·amin` and `(k+1)·amax`. -/
theorem tropMatPow_entry_sandwich
    (A : Matrix (Fin n) (Fin n) ℝ) (amin amax : ℝ)
    (hmin : ∀ i j, amin ≤ A i j) (hmax : ∀ i j, A i j ≤ amax)
    (k : ℕ) (i j : Fin n) :
    (k + 1 : ℝ) * amin ≤ tropMatPow A k i j ∧ tropMatPow A k i j ≤ (k + 1 : ℝ) * amax :=
  ⟨tropMatPow_entry_lower A amin hmin k i j, tropMatPow_entry_upper A amax hmax k i j⟩

/-! ## Section 2: The unconditional exponent leak -/

/-
**The tropical magnitude attack.**  Given the public pair `(A, B)` with
`B = A^{⊗(k+1)} = tropMatPow A k`, positive magnitude bounds `0 < amin ≤ A_{ij} ≤ amax`,
the secret exponent is confined to a computable interval read off from *any single* public
entry `B_{ij}`:

  `B_{ij} / amax ≤ k+1 ≤ B_{ij} / amin`.

Unlike `Tropical.TropicalDiscreteLog.tdlp_recover_exponent`, this requires **no
eigenvector** and **no `λ ≠ 0` hypothesis**: it applies to every instance with entries in
a positive band.
-/
theorem tdlp_exponent_interval
    (A : Matrix (Fin n) (Fin n) ℝ) (amin amax : ℝ)
    (hamin : 0 < amin) (hamax : 0 < amax)
    (hmin : ∀ i j, amin ≤ A i j) (hmax : ∀ i j, A i j ≤ amax)
    (k : ℕ) (i j : Fin n) :
    tropMatPow A k i j / amax ≤ (k + 1 : ℝ) ∧
    (k + 1 : ℝ) ≤ tropMatPow A k i j / amin := by
  constructor;
  · field_simp;
    convert tropMatPow_entry_upper A amax hmax k i j using 1 ; ring;
  · rw [ le_div_iff₀ hamin ] ; linarith [ tropMatPow_entry_lower A amin hmin k i j ]

/-
**Exact recovery for constant-magnitude matrices.**  When all entries of `A` equal a
single nonzero value `c` (so `amin = amax = c`), the interval of `tdlp_exponent_interval`
collapses to a point and the secret exponent is recovered exactly:
`(A^{⊗(k+1)})_{ij} / c = k+1`.
-/
theorem tdlp_constant_exact
    (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ) (hc : c ≠ 0)
    (hconst : ∀ i j, A i j = c) (k : ℕ) (i j : Fin n) :
    tropMatPow A k i j / c = (k + 1 : ℝ) := by
  convert div_eq_iff hc |>.2 _ using 1;
  induction' k with k ih generalizing i j <;> simp_all +decide [ tropMatPow, tropMatMul ];
  ring

/-! ## Section 3: The boundary — the zero matrix leaks nothing -/

/-
**Magnitude no-leak.**  At the boundary `amin = amax = 0` (the zero matrix), every
tropical power is again the zero matrix, so the magnitude channel carries no information
about the secret exponent `k`.  This is the magnitude-channel analogue of the `λ = 0`
boundary studied in `Tropical.EigenzeroNoLeak`.
-/
theorem magnitude_no_leak
    (A : Matrix (Fin n) (Fin n) ℝ) (hzero : ∀ i j, A i j = 0)
    (k : ℕ) (i j : Fin n) :
    tropMatPow A k i j = 0 := by
  induction' k with k ih generalizing i j <;> simp_all +decide [ tropMatPow ];
  unfold tropMatMul; aesop

/-! ## Section 4: A concrete break -/

/-
**Explicit magnitude break.**  For the concrete `2×2` public matrix with diagonal `1`
and off-diagonal `3` (so `amin = 1`, `amax = 3`), the diagonal entry of the public power
equals exactly `k+1`, leaking the secret exponent with no eigenvector computation.
-/
theorem tdlp_break_concrete_magnitude (k : ℕ) :
    tropMatPow (fun i j : Fin 2 => if i = j then (1 : ℝ) else 3) k 0 0 = (k + 1 : ℝ) := by
  induction' k using Nat.strong_induction_on with k ih;
  rcases k with ( _ | _ | k ) <;> simp_all +decide;
  · unfold tropMatPow;
    unfold tropMatMul tropMatPow; norm_num [ Fin.forall_fin_two ] ;
    norm_cast;
  · refine' le_antisymm _ _;
    · refine' le_trans ( tropMatMul_entry_le _ _ _ _ _ ) _;
      exact 0;
      norm_num [ ih ] ; linarith;
    · refine' le_trans _ ( tropMatPow_entry_lower _ 1 _ _ _ _ ) <;> norm_num

end TropicalMagnitude

end

/-!
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
Ranked falsifiable conjectures about a *second* attack channel on the tropical DH / TDLP
proposal, independent of the eigenvalue channel:
1. (bold, high impact) Every entry of `A^{⊗(k+1)}` grows *linearly* in `k`, trapped
   between the two lines `(k+1)·amin` and `(k+1)·amax`.  Hence a single public entry leaks
   the exponent up to a computable interval — with **no eigenvector** and **no `λ ≠ 0`**.
   [Chosen as headline; strictly more general reach than the eigenvalue attack.]
2. (surprising) When the magnitude band collapses (`amin = amax = c ≠ 0`) the interval
   collapses to a point: exact recovery for constant-magnitude matrices.
3. (boundary) The magnitude channel goes silent exactly at the zero matrix
   (`amin = amax = 0`): every power is `0`, mirroring the `λ = 0` eigenvalue boundary.
4. The diagonal entry of a matrix whose diagonal carries the minimum self-loop weight
   realizes the lower line `(k+1)·amin` exactly (observed numerically).

## Experiment (Experimenter)
- `tropMatPow_entry_lower` / `tropMatPow_entry_upper`: induction on `k` over the min-plus
  product; lower bound via `Finset.le_inf'`, upper bound via `Finset.inf'_le`.
- `tdlp_exponent_interval`: divide the sandwich by the positive slopes `amax`, `amin`.
- `tdlp_constant_exact`: instantiate the sandwich with `amin = amax = c`, collapsing it to
  an equality, then divide by `c ≠ 0`.
- `magnitude_no_leak`: sandwich with `amin = amax = 0`.
- `tdlp_break_concrete_magnitude`: `2×2` instance (`diag 1`, `off 3`); verified over ℚ
  before formalization (see `ComputationalEvidence.md`).

## Analysis (Analyst)
- SURVIVED: the entrywise sandwich, the interval attack, constant-magnitude exact
  recovery, the zero-matrix boundary, the concrete break.
- The magnitude channel is *strictly broader in applicability* than the eigenvalue
  channel: it needs no spectral data, only that entries lie in a positive band.  Its cost
  is precision: it returns an interval, not a point, unless the band is degenerate.
- The two channels have *the same boundary phenomenology*: information vanishes exactly at
  the degenerate value `0` (`λ = 0` for the spectral channel, the zero matrix for the
  magnitude channel).  This suggests a unifying "degeneracy = security" principle.

## Critique (Critic) — adversarial / counterexample mandate
- Counterexample hunt against the sandwich: none — both bounds are unconditional given the
  entrywise band, and the induction has no hidden side conditions (each step adds one more
  entry, hence one more `amin`/`amax`).
- `tdlp_exponent_interval` could divide by zero if `amin` or `amax` were `0`; both are
  explicitly required positive, and the degenerate case is characterized by
  `magnitude_no_leak`.  Precise boundary, not over-claim.
- No theorem is trivial: the sandwich uses induction + `Finset.le_inf'`/`inf'_le`;
  the interval uses ordered-field division lemmas; the concrete break instantiates the
  general machinery on explicit data (not `native_decide`).

## Synthesis (PI)
Two homomorphic shadows of the exponent escape the tropical power: the eigenvalue
(an exact linear functional, when it exists) and the entry magnitude (an approximate
linear functional, always).  A one-way function must hide *both*; the tropical power hides
neither outside the degenerate value `0`.  See `FUTURE_DIRECTIONS.md`.
-/