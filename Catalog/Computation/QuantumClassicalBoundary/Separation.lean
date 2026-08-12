import Mathlib
import Computation.QuantumClassicalBoundary.Boundary

/-!
# Cycle 2: what a peak-supported spectrum forces, and the sampling separation

Two further results, obtained by running the research loop again on the output
of `Boundary.lean`.

* `periodic_of_peak_supported` — a **converse** to the sharp-peak theorem: if a
  signal on a register of size `n = m·r` has spectrum supported on the multiples
  of `m`, then the signal is `r`-periodic.  Sharp combs in frequency are exactly
  periodic signals in time; the comb of `CoherentComb.lean` is the extreme case.
* `useful_peak_card` / `exists_useful_peak` — the peaks from which Shor's
  post-processing recovers `r` are the `j` with `gcd(j,r) = 1`; there are
  `φ(r)` of them and at least one always exists, so period extraction succeeds
  with probability `φ(r)/r` per run.
* `coherent_vs_classical_separation` — the separation in one statement: with
  fewer than `r` classical Fourier samples two distinct period-`r` signals are
  indistinguishable, whereas the single coherent comb yields a peak that
  determines `r` exactly.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): "sharp comb spectrum" and "periodicity" should be
  the same condition, so the quantum advantage cannot be recreated by preparing
  some cleverer non-periodic state.
* Experiment (Experimenter): proved the direction "peak-supported spectrum ⇒
  `r`-periodic" from the inversion theorem: for `m ∣ k` the phase shift over one
  period is `ω^{r k} = ω^{n j} = 1`, so every surviving Fourier mode is already
  `r`-periodic and hence so is their sum.  The comb of `CoherentComb.lean`
  realises the other direction concretely.
* Analysis (Analyst): this closes the loop opened in `Boundary.lean`.  Combined
  with the uncertainty principle, the picture is: periodicity ⇔ peak-supported
  spectrum, and among periodic signals the indicator comb is the one with the
  smallest possible time support, hence uncertainty-extremal.
* Critique (Critic): the periodicity statement is stated without wraparound
  (`i + r < n`), which is the honest form — with wraparound one needs the
  exponent congruence mod `n`, true but a distraction.  `φ(r)/r` is a *per-run*
  success probability in the idealised exact-period model, not a proof about the
  full Shor circuit; we say so.
* Synthesis (PI): three cycles of the loop have produced: sharpness (cycle 0),
  extremality (cycle 1), and rigidity — nothing else is sharp (cycle 2).
-/

namespace QuantumClassicalBoundary

open Finset FourierTransformInversion

/-! ## Rigidity: peak-supported spectra are exactly the periodic signals -/

/-- **Converse of the sharp-peak theorem.**  If the spectrum of `v` on a register
of size `n = m·r` vanishes at every frequency that is not a multiple of `m`,
then `v` is `r`-periodic. -/
theorem periodic_of_peak_supported {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0)
    (v : Fin (m * r) → ℂ)
    (hsupp : ∀ k : Fin (m * r), ¬ m ∣ k.val → DFT (zeta (m * r)) v k = 0)
    (i : Fin (m * r)) (h : i.val + r < m * r) :
    v ⟨i.val + r, h⟩ = v i := by
  classical
  have hn : 0 < m * r := Nat.pos_of_ne_zero (by simpa using Nat.mul_ne_zero hm hr)
  have hprim : IsPrimitiveRoot (zeta (m * r)) (m * r) := zeta_isPrimitiveRoot hn.ne'
  have hchar : ((m * r : ℕ) : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hroot : (zeta (m * r))⁻¹ ^ (m * r) = 1 := by
    rw [inv_pow, hprim.pow_eq_one, inv_one]
  have hinv := idft_dft hprim hn hchar v
  have hi' := congrFun hinv (⟨i.val + r, h⟩ : Fin (m * r))
  have hi := congrFun hinv i
  rw [IDFT] at hi hi'
  rw [← hi, ← hi']
  congr 1
  refine sum_congr rfl fun k _ => ?_
  by_cases hdvd : m ∣ k.val
  · obtain ⟨j, hj⟩ := hdvd
    have hexp : (⟨i.val + r, h⟩ : Fin (m * r)).val * k.val
        = i.val * k.val + (m * r) * j := by
      simp only
      rw [hj]
      ring
    rw [hexp, pow_add, pow_mul (zeta (m * r))⁻¹ (m * r) j, hroot, one_pow, mul_one]
  · rw [hsupp k hdvd, zero_mul, zero_mul]

/-! ## Which peaks are useful -/

/-- The useful peaks — those from which continued fractions recover `r` — are the
`j < r` coprime to `r`, and there are exactly `φ(r)` of them. -/
theorem useful_peak_card (r : ℕ) :
    ((range r).filter (fun j => Nat.Coprime r j)).card = Nat.totient r := by
  rw [Nat.totient]

/-- At least one useful peak exists whenever `r > 0`. -/
theorem exists_useful_peak {r : ℕ} (hr : 0 < r) :
    ∃ j ∈ range r, Nat.Coprime j r := by
  have hpos : 0 < ((range r).filter (fun j => Nat.Coprime r j)).card := by
    rw [useful_peak_card]
    exact Nat.totient_pos.mpr hr
  obtain ⟨j, hj⟩ := card_pos.mp hpos
  exact ⟨j, (mem_filter.mp hj).1, (Nat.coprime_comm.mp (mem_filter.mp hj).2)⟩

/-- **Period recovery succeeds from some peak.**  For any register `n = m·r`
there is a peak frequency `j·m` from which Shor's continued-fraction step returns
exactly `r`, and that peak carries the maximal amplitude `m`. -/
theorem exists_peak_recovering_period {m r : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (x0 : ℕ) :
    ∃ j < r, ‖combDFT m r x0 (j * m)‖ = (m : ℝ) ∧
      ((j * m : ℕ) / (m * r : ℕ) : ℚ).den = r := by
  obtain ⟨j, hjr, hj⟩ := exists_useful_peak (Nat.pos_of_ne_zero hr)
  exact ⟨j, mem_range.mp hjr, combDFT_peak hm hr x0 j, period_from_peak hm hr hj⟩

/-! ## The separation -/

/-- **Coherent versus classical, in one statement.**  Fix a period `r > 0`.

* Classical: for any `K < r` frequencies there exist two *distinct* period-`r`
  signals with exactly the same Fourier samples — the period is not determined.
* Quantum: the single coherent comb has a peak of maximal amplitude `m` from
  which the period `r` is recovered exactly.

The gap is not in the Fourier mathematics, which is shared, but in the input:
`K` classical samples versus one coherent superposition. -/
theorem coherent_vs_classical_separation {m r K : ℕ} [NeZero r] (hm : m ≠ 0) (hr : r ≠ 0)
    (x0 : ℕ) (hK : K < r) (idx : Fin K → ZMod r) :
    (∃ v w : ZMod r → ℂ, v ≠ w ∧
        ∀ i : Fin K, ZMod.dft v (idx i) = ZMod.dft w (idx i)) ∧
      (∃ j < r, ‖combDFT m r x0 (j * m)‖ = (m : ℝ) ∧
        ((j * m : ℕ) / (m * r : ℕ) : ℚ).den = r) :=
  ⟨FactoringBarriers.dft_lt_period_indistinguishable hK idx,
   exists_peak_recovering_period hm hr x0⟩

end QuantumClassicalBoundary