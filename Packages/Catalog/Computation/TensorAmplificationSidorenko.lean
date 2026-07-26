/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tensor amplification and spectral transfer for Sidorenko-type inequalities

This file develops the **tensor-amplification framework** for Sidorenko-type inequalities in the
setting of *weighted graphs* (finite graphons represented by a square nonnegative matrix over an
arbitrary finite vertex space with the counting measure).  A weighted graph on a finite vertex
space `ι` is a matrix `A : Matrix ι ι ℝ`; its two fundamental homomorphism densities are

* the **edge density** `tEdge A = (∑ i j, A i j) / |ι|²`, the density of the single edge `K₂`, and
* the **cycle density** `tCycle k A = tr(Aᵏ) / |ι|ᵏ`, the density of the `k`-cycle `Cₖ`
  (the number of closed walks of length `k` is `tr(Aᵏ)`).

A weighted graph is said to satisfy the **Sidorenko property for `Cₖ`** when
`tEdge A ^ k ≤ tCycle k A`, i.e. the cycle density is at least the edge density raised to the
number of edges of the cycle.  This is the discrete, uniform-measure incarnation of Sidorenko's
conjecture (see Erdős–Simonovits 1984 and Sidorenko's programme; the graphon language is that of
Lovász–Szegedy 2006, and the amplification philosophy underlies Conlon–Fox–Sudakov 2010 and the
tensor-power arguments revisited by Li–Szegedy 2026).

## Main results

* `homCycle_kron` : **spectral transfer** — closed-walk counts are multiplicative under the tensor
  (Kronecker) product, `tr((A ⊗ B)ᵏ) = tr(Aᵏ)·tr(Bᵏ)`.  This is the algebraic heart of the whole
  framework: tensoring graphons multiplies their cycle spectra.
* `tCycle_kron`, `tEdge_kron` : both densities factor through the tensor product.
* `sidRatio_kron` : the **Sidorenko ratio** `tCycle k A / tEdge A ^ k` is *multiplicative* under the
  tensor product.
* `Sidorenko_kron` : **Transfer Principle I (structural closure)** — the class of weighted graphs
  satisfying the Sidorenko property for `Cₖ` is closed under tensor products.
* `sidRatio_amplify_gt` / `sidRatio_amplify_lt` : **Transfer Principle II (amplification)** — a
  strict surplus (`ratio > 1`) is strictly amplified by self-tensoring, while a strict deficit
  (`0 < ratio < 1`, a Sidorenko violation) is strictly amplified towards `0`.  Thus tensoring is a
  *contraction towards the two fixed points* `0` and `1`, and *any* violation, however small,
  witnesses arbitrarily large violations.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Sidorenko-type inequalities should be governed by a single scalar
  invariant, the Sidorenko ratio `tCycle / tEdge^k`, which is *multiplicative* under a natural
  product on graphons.  If so, the property "ratio ≥ 1" is automatically closed under that product,
  and strict surpluses/deficits must be amplified — turning any counterexample into a family of
  ever-worse counterexamples.
Experiment (Experimenter): Chose the tensor (Kronecker) product as the graphon product.  The
  spectral transfer lemma `tr((A ⊗ B)ᵏ) = tr(Aᵏ)·tr(Bᵏ)` follows from `(A ⊗ B)ᵏ = Aᵏ ⊗ Bᵏ`
  (proved by induction from `mul_kronecker_mul`) and `trace_kronecker`.  The edge count is
  multiplicative because a double sum over `ι × κ` factors as a product of double sums.  Density
  normalisations `|ι × κ| = |ι|·|κ|` (`Fintype.card_prod`) then make every density multiplicative,
  and `div_mul_div_comm` closes the ratio identity with no positivity hypotheses.
Analysis (Analyst): Closure `Sidorenko_kron` needs only nonnegativity of the edge densities (to
  multiply two `≤` inequalities), not strict positivity — a pleasantly weak hypothesis.  The
  amplification laws are exactly the statement that `x ↦ x²` fixes `{0,1}` and repels/attracts on
  either side of `1`.
Critique (Critic): No result is vacuous: multiplicativity is an identity with content, and the
  amplification lemmas carry genuine strict-inequality hypotheses.  The framework is honest about
  its scope — it establishes closure and amplification, and (in the companion file) supplies the
  base Sidorenko inequalities that seed the closure.
Synthesis (PI): A self-contained algebraic engine: one spectral-transfer identity generates two
  transfer principles (closure and amplification) for Sidorenko-type inequalities.
-/
import Mathlib

open Matrix BigOperators
open scoped Kronecker

namespace TensorSidorenko

variable {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]

/-- Homomorphism count of a single edge `K₂`: the sum of all edge weights. -/
def homEdge (A : Matrix ι ι ℝ) : ℝ := ∑ i, ∑ j, A i j

/-- Homomorphism count of the `k`-cycle `Cₖ`: the number of closed walks of length `k`,
equal to `tr(Aᵏ)`. -/
def homCycle (k : ℕ) (A : Matrix ι ι ℝ) : ℝ := trace (A ^ k)

/-- Edge density: `homEdge` normalised by the number of ordered vertex pairs. -/
noncomputable def tEdge (A : Matrix ι ι ℝ) : ℝ := homEdge A / (Fintype.card ι : ℝ) ^ 2

/-- Cycle density: `homCycle` normalised by the number of length-`k` vertex tuples. -/
noncomputable def tCycle (k : ℕ) (A : Matrix ι ι ℝ) : ℝ :=
  homCycle k A / (Fintype.card ι : ℝ) ^ k

/-- The Sidorenko ratio of a weighted graph for the cycle `Cₖ`. -/
noncomputable def sidRatio (k : ℕ) (A : Matrix ι ι ℝ) : ℝ := tCycle k A / (tEdge A) ^ k

/-- The Sidorenko property for the cycle `Cₖ`: the cycle density dominates the `k`-th power of the
edge density. -/
def Sidorenko (k : ℕ) (A : Matrix ι ι ℝ) : Prop := (tEdge A) ^ k ≤ tCycle k A

/-- Powers of a tensor product factor: `(A ⊗ B)ᵏ = Aᵏ ⊗ Bᵏ`. -/
theorem kron_pow (A : Matrix ι ι ℝ) (B : Matrix κ κ ℝ) (k : ℕ) :
    (A ⊗ₖ B) ^ k = (A ^ k) ⊗ₖ (B ^ k) := by
  induction k with
  | zero => simp
  | succ p ih => rw [pow_succ, pow_succ, pow_succ, ih, Matrix.mul_kronecker_mul]

/-- **Spectral transfer.** Closed-walk counts are multiplicative under the tensor product:
`tr((A ⊗ B)ᵏ) = tr(Aᵏ)·tr(Bᵏ)`.  Tensoring graphons multiplies their cycle spectra. -/
theorem homCycle_kron (k : ℕ) (A : Matrix ι ι ℝ) (B : Matrix κ κ ℝ) :
    homCycle k (A ⊗ₖ B) = homCycle k A * homCycle k B := by
  unfold homCycle
  rw [kron_pow, trace_kronecker]

omit [DecidableEq ι] [DecidableEq κ] in
/-- The edge count is multiplicative under the tensor product. -/
theorem homEdge_kron (A : Matrix ι ι ℝ) (B : Matrix κ κ ℝ) :
    homEdge (A ⊗ₖ B) = homEdge A * homEdge B := by
  unfold homEdge
  simp only [Matrix.kroneckerMap_apply, Fintype.sum_prod_type]
  rw [Finset.sum_mul_sum]
  refine Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl (fun i' _ => ?_))
  rw [Finset.sum_mul_sum]

/-- Cycle density factors through the tensor product. -/
theorem tCycle_kron (k : ℕ) (A : Matrix ι ι ℝ) (B : Matrix κ κ ℝ) :
    tCycle k (A ⊗ₖ B) = tCycle k A * tCycle k B := by
  unfold tCycle
  rw [homCycle_kron, Fintype.card_prod]
  push_cast
  rw [mul_pow, div_mul_div_comm]

omit [DecidableEq ι] [DecidableEq κ] in
/-- Edge density factors through the tensor product. -/
theorem tEdge_kron (A : Matrix ι ι ℝ) (B : Matrix κ κ ℝ) :
    tEdge (A ⊗ₖ B) = tEdge A * tEdge B := by
  unfold tEdge
  rw [homEdge_kron, Fintype.card_prod]
  push_cast
  rw [mul_pow, div_mul_div_comm]

/-- The Sidorenko ratio is multiplicative under the tensor product. -/
theorem sidRatio_kron (k : ℕ) (A : Matrix ι ι ℝ) (B : Matrix κ κ ℝ) :
    sidRatio k (A ⊗ₖ B) = sidRatio k A * sidRatio k B := by
  unfold sidRatio
  rw [tCycle_kron, tEdge_kron, mul_pow, div_mul_div_comm]

omit [DecidableEq ι] in
/-- A nonnegative weighted graph has nonnegative edge count. -/
theorem homEdge_nonneg {A : Matrix ι ι ℝ} (hA : ∀ i j, 0 ≤ A i j) : 0 ≤ homEdge A := by
  unfold homEdge
  exact Finset.sum_nonneg (fun i _ => Finset.sum_nonneg (fun j _ => hA i j))

omit [DecidableEq ι] in
/-- A nonnegative weighted graph has nonnegative edge density. -/
theorem tEdge_nonneg {A : Matrix ι ι ℝ} (hA : ∀ i j, 0 ≤ A i j) : 0 ≤ tEdge A := by
  unfold tEdge
  exact div_nonneg (homEdge_nonneg hA) (by positivity)

/-- **Transfer Principle I (structural closure).** The class of weighted graphs satisfying the
Sidorenko property for `Cₖ` is closed under tensor products. -/
theorem Sidorenko_kron {k : ℕ} {A : Matrix ι ι ℝ} {B : Matrix κ κ ℝ}
    (hA : Sidorenko k A) (hB : Sidorenko k B)
    (hA0 : 0 ≤ tEdge A) (hB0 : 0 ≤ tEdge B) :
    Sidorenko k (A ⊗ₖ B) := by
  unfold Sidorenko at *
  rw [tCycle_kron, tEdge_kron, mul_pow]
  exact mul_le_mul hA hB (pow_nonneg hB0 k) (le_trans (pow_nonneg hA0 k) hA)

/-- **Transfer Principle I for even cycles.** For an *even* cycle length the Sidorenko property is
closed under tensor products with no positivity hypothesis whatsoever: an even power of the edge
density is automatically nonnegative, so the two Sidorenko inequalities multiply directly. -/
theorem Sidorenko_kron_even {k : ℕ} (hk : Even k) {A : Matrix ι ι ℝ} {B : Matrix κ κ ℝ}
    (hA : Sidorenko k A) (hB : Sidorenko k B) :
    Sidorenko k (A ⊗ₖ B) := by
  unfold Sidorenko at *
  rw [tCycle_kron, tEdge_kron, mul_pow]
  exact mul_le_mul hA hB (hk.pow_nonneg _) (le_trans (hk.pow_nonneg _) hA)

/-- Self-tensoring squares the Sidorenko ratio. -/
theorem sidRatio_self_kron (k : ℕ) (A : Matrix ι ι ℝ) :
    sidRatio k (A ⊗ₖ A) = (sidRatio k A) ^ 2 := by
  rw [sidRatio_kron, sq]

/-- **Transfer Principle II (amplification of surplus).** A strict Sidorenko surplus is strictly
amplified by self-tensoring. -/
theorem sidRatio_amplify_gt {k : ℕ} {A : Matrix ι ι ℝ} (h : 1 < sidRatio k A) :
    sidRatio k A < sidRatio k (A ⊗ₖ A) := by
  rw [sidRatio_self_kron, sq]
  nlinarith [h]

/-- **Transfer Principle II (amplification of deficit).** A strict Sidorenko *violation*
(`0 < ratio < 1`) is strictly amplified towards `0` by self-tensoring: violations compound. -/
theorem sidRatio_amplify_lt {k : ℕ} {A : Matrix ι ι ℝ}
    (h0 : 0 < sidRatio k A) (h1 : sidRatio k A < 1) :
    sidRatio k (A ⊗ₖ A) < sidRatio k A := by
  rw [sidRatio_self_kron, sq]
  nlinarith [h0, h1]

/-- The two fixed points of amplification: `ratio = 1` is preserved by self-tensoring
(the sharp/extremal case). -/
theorem sidRatio_fixed_one {k : ℕ} {A : Matrix ι ι ℝ} (h : sidRatio k A = 1) :
    sidRatio k (A ⊗ₖ A) = 1 := by
  rw [sidRatio_self_kron, h, one_pow]

end TensorSidorenko