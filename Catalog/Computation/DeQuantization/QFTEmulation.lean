import Computation.DeQuantization.CombRankGeneral
import Computation.QuantumClassicalBoundary.CoherentComb

/-!
# Tensor-train emulation of the QFT: what it costs before and after

This file closes the loop with the Factoring Lab's `CoherentComb.lean`, which
computes the *exact* quantum Fourier transform of the coherent comb
`∑_{j<m} |x₀ + j·r⟩` inside a register of dimension `n = m·r`
(`QuantumClassicalBoundary.combDFT`).

Cycles 1–2 (`CombSchmidtRank.lean`, `CombRankGeneral.lean`) computed the bond
dimension of the *input* comb.  Here we compute the bond dimension of the
*output* — the Dirac comb of period `m` produced by the QFT — and compare.

## Main results

* `combDFT_ne_zero_iff` — the transform is nonzero exactly on the multiples of
  `m` (a restatement of the lab's sharp-peak theorem in support form).
* `rank_diagonal_conj` — invertible diagonal rescalings on either side do not
  change the rank; hence *phases are free* for tensor-train purposes.
* `combDFTMatrix_rank_eq` — the QFT output has Schmidt rank exactly
  `min P (m / gcd(m,Q))` across the cut `n = P·Q`, i.e. the same law as the input
  with the period `r` replaced by the co-period `m = n/r`.
* `qft_bond_complementarity` — **the QFT cannot be expensive on both sides.**
  In the exact setting `n = m·r = P·Q` with `r ≤ Q` and `m ≤ Q`,

      (input bond dimension) · (output bond dimension) ≤ P = n / Q .

  For a balanced cut this means one of the two states has bond dimension at most
  `n^{1/4}`: for *exact* combs, "Theorem 3" (tensor-train QFT emulation) is true
  in a strong, quantitative sense.

## Why this does *not* de-quantize Shor

The hypothesis that makes the complementarity theorem work is `r ∣ n`, i.e. the
period divides the register size exactly.  Shor's algorithm runs on a binary
register `n = 2^L`, where an odd order `r` never divides `n`; the post-measurement
state is the *truncated* comb `{x < n : x ≡ x₀ (mod r)}` formalised by
`combMatrix`, and `qubit_comb_rank_eq_oddPart` shows its bond dimension is
`min (2^a, odd part of r)` — exponentially large.  The de-quantization boundary is
therefore *exactly* the divisibility `r ∣ n`, and Shor's algorithm lives on the
wrong side of it.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer, cycle 3): "QFT preserves bond dimension" — refuted as
  stated; the correct law is `r ↦ m = n/r` (`combDFTMatrix_rank_eq`), which is an
  *inversion*, not a preservation.
* Experiment (Experimenter): with `n = 12 = 3·4` and the cut `P = 3`, `Q = 4`, the
  input comb of period `r = 3` has rank `min(3, 3/gcd(3,4)) = 3` while the output
  comb of period `m = 4` has rank `min(3, 4/gcd(4,4)) = 1`; the product is
  `3 = P`, so the complementarity bound is attained.
* Critique (Critic): the naive "de-quantization" reading of the complementarity
  theorem is wrong, because it needs `r ∣ n`.  Removing that hypothesis breaks
  the theorem, not merely its proof: the truncated comb has bond dimension equal
  to the odd part of `r`, and its transform is a smeared Dirichlet kernel with
  full support.  Guarded statement retained.
-/

namespace DeQuantization

open QuantumClassicalBoundary

/-! ## Phases are free -/

/-- Rescaling rows and columns by nonzero scalars does not change the rank.
Consequently a tensor-train representation cannot be made cheaper (or more
expensive) by local single-qubit phase gates — exactly the gates the tensor-train
QFT applies to the core tensors. -/
theorem rank_diagonal_conj {P Q : ℕ} (d : Fin P → ℂ) (e : Fin Q → ℂ)
    (hd : ∀ i, d i ≠ 0) (he : ∀ j, e j ≠ 0) (X : Matrix (Fin P) (Fin Q) ℂ) :
    (Matrix.diagonal d * X * Matrix.diagonal e).rank = X.rank := by
  classical
  have hentry : ∀ (f : Fin P → ℂ) (g : Fin Q → ℂ) (Y : Matrix (Fin P) (Fin Q) ℂ) p q,
      (Matrix.diagonal f * Y * Matrix.diagonal g) p q = f p * Y p q * g q := by
    intro f g Y p q
    rw [Matrix.mul_diagonal, Matrix.diagonal_mul]
  refine le_antisymm ?_ ?_
  · exact le_trans (Matrix.rank_mul_le_left _ _)
      (Matrix.rank_mul_le_right (Matrix.diagonal d) X)
  · have hback : Matrix.diagonal (fun i => (d i)⁻¹) *
        (Matrix.diagonal d * X * Matrix.diagonal e) * Matrix.diagonal (fun j => (e j)⁻¹) = X := by
      ext p q
      rw [hentry, hentry, show (d p)⁻¹ * (d p * X p q * e q) * (e q)⁻¹
            = ((d p)⁻¹ * d p) * X p q * (e q * (e q)⁻¹) by ring,
        inv_mul_cancel₀ (hd p), mul_inv_cancel₀ (he q), one_mul, mul_one]
    calc X.rank = (Matrix.diagonal (fun i => (d i)⁻¹) *
            (Matrix.diagonal d * X * Matrix.diagonal e) *
            Matrix.diagonal (fun j => (e j)⁻¹)).rank := by rw [hback]
      _ ≤ (Matrix.diagonal (fun i => (d i)⁻¹) *
            (Matrix.diagonal d * X * Matrix.diagonal e)).rank := Matrix.rank_mul_le_left _ _
      _ ≤ (Matrix.diagonal d * X * Matrix.diagonal e).rank := Matrix.rank_mul_le_right _ _

/-! ## The support of the transformed comb -/

theorem zeta_ne_zero {n : ℕ} : zeta n ≠ 0 := Complex.exp_ne_zero _

/-- **Support form of the sharp-peak theorem**: the QFT of the comb is nonzero at
exactly the frequencies divisible by `m = n/r`. -/
theorem combDFT_ne_zero_iff {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 k : ℕ) :
    combDFT m r x0 k ≠ 0 ↔ m ∣ k := by
  rw [combDFT_eq hm hr]
  constructor
  · intro h
    by_contra hdvd
    exact h (by simp [hdvd])
  · intro hdvd
    have h1 : (if m ∣ k then (m : ℂ) else 0) = (m : ℂ) := by simp [hdvd]
    rw [h1]
    exact mul_ne_zero (pow_ne_zero _ zeta_ne_zero) (Nat.cast_ne_zero.2 hm)

/-! ## The output amplitude matrix across a cut -/

/-- The QFT output state, reshaped across the cut `k = p·Q + q`. -/
noncomputable def combDFTMatrix (m r x0 P Q : ℕ) : Matrix (Fin P) (Fin Q) ℂ :=
  Matrix.of fun p q => combDFT m r x0 ((p : ℕ) * Q + (q : ℕ))

/-- The output matrix is a diagonal rescaling of the `0/1` comb of period `m`. -/
theorem combDFTMatrix_eq_conj {m r x0 P Q : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) :
    combDFTMatrix m r x0 P Q =
      Matrix.diagonal (fun p : Fin P => (m : ℂ) * zeta (m * r) ^ (x0 * ((p : ℕ) * Q))) *
        combMatrix P Q m 0 *
      Matrix.diagonal (fun q : Fin Q => zeta (m * r) ^ (x0 * (q : ℕ))) := by
  classical
  ext p q
  rw [Matrix.mul_diagonal, Matrix.diagonal_mul]
  show combDFT m r x0 ((p : ℕ) * Q + (q : ℕ)) = _
  rw [combDFT_eq hm hr]
  have hsplit : x0 * ((p : ℕ) * Q + (q : ℕ)) = x0 * ((p : ℕ) * Q) + x0 * (q : ℕ) := by ring
  rw [hsplit, pow_add]
  have hdvd : (m ∣ (p : ℕ) * Q + (q : ℕ)) ↔ (((p : ℕ) * Q + (q : ℕ)) % m = 0 % m) := by
    rw [Nat.zero_mod]
    exact Nat.dvd_iff_mod_eq_zero
  by_cases h : m ∣ (p : ℕ) * Q + (q : ℕ)
  · rw [if_pos h]
    have : combMatrix P Q m 0 p q = 1 := by
      show (if _ then (1 : ℂ) else 0) = 1
      rw [if_pos (hdvd.1 h)]
    rw [this]
    ring
  · rw [if_neg h]
    have : combMatrix P Q m 0 p q = 0 := by
      show (if _ then (1 : ℂ) else 0) = 0
      rw [if_neg (fun hh => h (hdvd.2 hh))]
    rw [this]
    ring

/-- **The Schmidt rank of the QFT output.**  Across the cut `n = P·Q` the
transformed comb has rank `min P (m / gcd(m,Q))`: the same law as for the input
comb, with the period `r` replaced by the co-period `m = n/r`. -/
theorem combDFTMatrix_rank_eq {m r x0 P Q : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (hmQ : m ≤ Q) :
    (combDFTMatrix m r x0 P Q).rank = min P (reducedPeriod m Q) := by
  have hm0 : 0 < m := Nat.pos_of_ne_zero hm
  rw [combDFTMatrix_eq_conj hm hr]
  rw [rank_diagonal_conj _ _
      (fun p => mul_ne_zero (Nat.cast_ne_zero.2 hm) (pow_ne_zero _ zeta_ne_zero))
      (fun q => pow_ne_zero _ zeta_ne_zero)]
  exact combMatrix_rank_eq_min hm0 hmQ

/-- Direct support-based lower bound on the output rank, independent of the
diagonal-conjugation route (kept because it is the argument that generalises to
approximate combs, where no exact factorisation of the phases is available). -/
theorem combDFTMatrix_rank_ge {m r x0 P Q : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (hmQ : m ≤ Q) :
    min P (reducedPeriod m Q) ≤ (combDFTMatrix m r x0 P Q).rank := by
  refine rank_ge_of_comb_support (x0 := 0) (Nat.pos_of_ne_zero hm) hmQ _ (fun p q => ?_)
  rw [Nat.zero_mod, ← Nat.dvd_iff_mod_eq_zero]
  exact combDFT_ne_zero_iff hm hr x0 _

/-! ## Complementarity: the QFT cannot be expensive on both sides -/

/-- `Q ∣ r·m` forces `Q ≤ gcd(r,Q) · gcd(m,Q)`. -/
theorem gcd_mul_gcd_ge {r m Q : ℕ} (hQ : 0 < Q) (hdvd : Q ∣ r * m) :
    Q ≤ Nat.gcd r Q * Nat.gcd m Q := by
  have h1 : Nat.gcd Q (r * m) ∣ Nat.gcd Q r * Nat.gcd Q m := Nat.gcd_mul_right_dvd_mul_gcd Q r m
  have h2 : Nat.gcd Q (r * m) = Q := Nat.gcd_eq_left hdvd
  rw [h2] at h1
  have h3 : Nat.gcd Q r * Nat.gcd Q m = Nat.gcd r Q * Nat.gcd m Q := by
    rw [Nat.gcd_comm Q r, Nat.gcd_comm Q m]
  rw [h3] at h1
  exact Nat.le_of_dvd (Nat.mul_pos (Nat.gcd_pos_of_pos_right r hQ)
    (Nat.gcd_pos_of_pos_right m hQ)) h1

/-- The product of the reduced periods of `r` and of `m = n/r` is at most `P`. -/
theorem reducedPeriod_mul_reducedPeriod_le {r m P Q : ℕ} (hQ : 0 < Q) (hn : r * m = P * Q) :
    reducedPeriod r Q * reducedPeriod m Q ≤ P := by
  have hdvd : Q ∣ r * m := ⟨P, by rw [hn, Nat.mul_comm]⟩
  have hgg : Q ≤ Nat.gcd r Q * Nat.gcd m Q := gcd_mul_gcd_ge hQ hdvd
  have hmul : (reducedPeriod r Q * reducedPeriod m Q) * (Nat.gcd r Q * Nat.gcd m Q)
      = P * Q := by
    calc (reducedPeriod r Q * reducedPeriod m Q) * (Nat.gcd r Q * Nat.gcd m Q)
        = (reducedPeriod r Q * Nat.gcd r Q) * (reducedPeriod m Q * Nat.gcd m Q) := by ring
      _ = r * m := by rw [reducedPeriod_mul_gcd, reducedPeriod_mul_gcd]
      _ = P * Q := hn
  by_contra hcon
  push_neg at hcon
  have h1 : (P + 1) * Q ≤ (reducedPeriod r Q * reducedPeriod m Q) * (Nat.gcd r Q * Nat.gcd m Q) :=
    Nat.mul_le_mul hcon hgg
  rw [hmul] at h1
  nlinarith [h1]

/-- **Complementarity theorem.**  For an exact comb of period `r` in a register of
size `n = m·r`, cut as `n = P·Q` with both the period and the co-period fitting
inside the right block, the *product* of the tensor-train bond dimensions of the
state before and after the quantum Fourier transform is at most `P = n/Q`.

For a balanced cut (`P = Q = √n`) this says that at least one of the two states
has bond dimension `≤ n^{1/4}`: an exact comb cannot be tensor-train-hard both in
position space and in frequency space.  This is the precise (and provable) form
of the "tensor-train QFT emulation" claim — and it is available only under the
divisibility hypothesis `r ∣ n`, which Shor's binary register violates. -/
theorem qft_bond_complementarity {m r x0 P Q : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (hQ : 0 < Q)
    (hn : r * m = P * Q) (hrQ : r ≤ Q) (hmQ : m ≤ Q) :
    (combMatrix P Q r x0).rank * (combDFTMatrix m r x0 P Q).rank ≤ P := by
  rw [combMatrix_rank_eq_min (Nat.pos_of_ne_zero hr) hrQ,
    combDFTMatrix_rank_eq hm hr hmQ]
  exact le_trans
    (Nat.mul_le_mul (min_le_right P (reducedPeriod r Q)) (min_le_right P (reducedPeriod m Q)))
    (reducedPeriod_mul_reducedPeriod_le hQ hn)

end DeQuantization