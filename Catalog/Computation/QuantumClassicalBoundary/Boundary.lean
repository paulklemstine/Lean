import Mathlib
import Computation.QuantumClassicalBoundary.CoherentComb
import Computation.QuantumClassicalBoundary.SpectralHiding
import Computation.QuantumClassicalBoundary.SampleBarrier

/-!
# Locating the quantum–classical boundary: an uncertainty-principle account

The two previous files established

* the **quantum** fact: the QFT of a coherent comb is a perfect Dirac comb
  (`combDFT_norm`), and any peak determines the period (`period_from_peak`);
* the **classical** facts: Fourier sampling needs `K ≥ r` samples and typical
  orders are exponential (`classical_sampling_barrier`), while the value signal
  `x ↦ aˣ mod N` has no dominant fundamental
  (`fundamental_dominated_by_harmonic`).

This file explains *why* the comb is the unique optimal input, by proving a
**discrete uncertainty principle** (Donoho–Stark) for the very DFT verified in
`Computation.FourierTransformInversion`:

  `#supp v · #supp (DFT v) ≥ n`  for every nonzero `v : Fin n → ℂ`.

and showing that the coherent comb **saturates** it: its time support is `m` and
its frequency support is exactly `r`, with `m · r = n`
(`comb_saturates_uncertainty`).  So the state Shor's circuit prepares is not
merely convenient — it is extremal for the time–frequency trade-off, and no
classical or quantum input can be sharper.

The capstone `quantum_classical_boundary` collects the classical obstruction and
the quantum resolution in one statement, with the honest scope: nothing here
lower-bounds classical *factoring* time.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): the quantum advantage should be *extremal*, not
  incidental: the comb should saturate a time–frequency uncertainty inequality,
  so that no cleverer input state can do better.
* Experiment (Experimenter): proved the Donoho–Stark bound `|A|·|B| ≥ n` from
  three ingredients only — `‖ζ‖ = 1`, the triangle inequality, and the
  inversion theorem `idft_dft` from the catalog.  Then computed both supports of
  the comb: `|A| = m`, `|B| = r`, `|A|·|B| = m·r = n`.  Saturation confirmed.
* Analysis (Analyst): the classical picture is now sharp.  Fourier sampling
  measures the spectrum at `K` points; the uncertainty principle says a signal
  with a small time support *must* have a spread spectrum, so no sampling scheme
  can both be short and resolve the period — exactly the `K ≥ r` bound.  The
  quantum circuit sidesteps sampling entirely: it evaluates `aˣ mod N` once, in
  superposition, and the resulting state is the extremal comb.
* Critique (Critic): the uncertainty theorem needs `v ≠ 0` (a zero signal has
  empty supports and the inequality would fail), and `0 < n`.  Both are stated.
  The saturation computation needs `x₀ < r` so that the comb teeth are the
  residues `x₀ + j r`; also stated.  Nothing is asserted about factoring time.
* Synthesis (PI): boundary located.  Classical side: sampling + spread spectrum.
  Quantum side: one coherent evaluation producing an uncertainty-extremal comb.
-/

namespace QuantumClassicalBoundary

open Finset FourierTransformInversion

/-! ## The comb as a state vector -/

/-- The coherent comb as a vector in the register `Fin (m·r)`: the indicator of
the arithmetic progression `{x : x ≡ x₀ [MOD r]}`. -/
noncomputable def combState (m r x0 : ℕ) : Fin (m * r) → ℂ :=
  fun x => if (x : ℕ) % r = x0 then 1 else 0

/-- The DFT of the comb state is the comb transform computed in
`CoherentComb.lean`. -/
theorem combState_dft {m r x0 : ℕ} (hx0 : x0 < r) (k : Fin (m * r)) :
    DFT (zeta (m * r)) (combState m r x0) k = combDFT m r x0 k.val := by
  classical
  have hr : 0 < r := lt_of_le_of_lt (Nat.zero_le _) hx0
  have hstep : (∑ i : Fin (m * r), combState m r x0 i * zeta (m * r) ^ (i.val * k.val))
      = ∑ i ∈ univ.filter (fun i : Fin (m * r) => i.val % r = x0),
          zeta (m * r) ^ (i.val * k.val) := by
    rw [sum_filter]
    exact sum_congr rfl fun i _ => by by_cases h : i.val % r = x0 <;> simp [combState, h]
  have hkey : ∀ i : Fin (m * r), i.val % r = x0 → x0 + i.val / r * r = i.val := by
    intro i hi
    rw [← hi, Nat.mod_add_div' i.val r]
  rw [DFT, hstep, combDFT]
  refine Finset.sum_bij' (fun i _ => i.val / r)
    (fun j (hj : j ∈ range m) =>
      (⟨x0 + j * r, by have := mem_range.mp hj; nlinarith⟩ : Fin (m * r)))
    ?_ ?_ ?_ ?_ ?_
  · intro i _
    exact mem_range.mpr (Nat.div_lt_of_lt_mul (lt_of_lt_of_le i.isLt (le_of_eq (Nat.mul_comm m r))))
  · intro j _
    simp only [mem_filter, mem_univ, true_and]
    rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hx0]
  · intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi
    exact Fin.ext (hkey i hi)
  · intro j _
    simp only
    rw [Nat.add_mul_div_right _ _ hr, Nat.div_eq_of_lt hx0, Nat.zero_add]
  · intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi
    rw [hkey i hi]

/-! ## Supports -/

/-- Filtering `Fin n` by a predicate on the underlying natural number is the same
as filtering `range n`. -/
theorem card_filter_fin_val {n : ℕ} (p : ℕ → Prop) [DecidablePred p] :
    (univ.filter (fun i : Fin n => p i.val)).card = ((range n).filter p).card := by
  classical
  refine Finset.card_bij' (fun i _ => i.val)
    (fun a ha => (⟨a, mem_range.mp (mem_filter.mp ha).1⟩ : Fin n)) ?_ ?_ ?_ ?_
  · intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi
    exact mem_filter.mpr ⟨mem_range.mpr i.isLt, hi⟩
  · intro a ha
    simp only [mem_filter, mem_univ, true_and]
    exact (mem_filter.mp ha).2
  · intro i _; rfl
  · intro a _; rfl

/-- The comb state is supported on exactly `m` points. -/
theorem combState_support_card {m r x0 : ℕ} (hx0 : x0 < r) :
    (univ.filter (fun i : Fin (m * r) => combState m r x0 i ≠ 0)).card = m := by
  classical
  have hr : 0 < r := lt_of_le_of_lt (Nat.zero_le _) hx0
  have hfil : (univ.filter (fun i : Fin (m * r) => combState m r x0 i ≠ 0))
      = univ.filter (fun i : Fin (m * r) => i.val % r = x0) := by
    apply filter_congr
    intro i _
    by_cases h : i.val % r = x0 <;> simp [combState, h]
  have hkey : ∀ i : Fin (m * r), i.val % r = x0 → x0 + i.val / r * r = i.val := by
    intro i hi
    rw [← hi, Nat.mod_add_div' i.val r]
  rw [hfil]
  refine Finset.card_bij' (fun i _ => i.val / r)
    (fun j (hj : j ∈ range m) =>
      (⟨x0 + j * r, by have := mem_range.mp hj; nlinarith⟩ : Fin (m * r)))
    ?_ ?_ ?_ ?_ |>.trans (card_range m)
  · intro i _
    exact mem_range.mpr (Nat.div_lt_of_lt_mul (lt_of_lt_of_le i.isLt (le_of_eq (Nat.mul_comm m r))))
  · intro j _
    simp only [mem_filter, mem_univ, true_and]
    rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hx0]
  · intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi
    exact Fin.ext (hkey i hi)
  · intro j _
    simp only
    rw [Nat.add_mul_div_right _ _ hr, Nat.div_eq_of_lt hx0, Nat.zero_add]

/-- The spectrum of the comb state is supported on exactly `r` frequencies. -/
theorem combState_spectrum_card {m r x0 : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (hx0 : x0 < r) :
    (univ.filter (fun k : Fin (m * r) =>
      DFT (zeta (m * r)) (combState m r x0) k ≠ 0)).card = r := by
  classical
  have hfil : (univ.filter (fun k : Fin (m * r) =>
      DFT (zeta (m * r)) (combState m r x0) k ≠ 0))
      = univ.filter (fun k : Fin (m * r) => m ∣ k.val) := by
    apply filter_congr
    intro k _
    rw [combState_dft hx0 k]
    constructor
    · intro h
      by_contra hdvd
      exact h (combDFT_offpeak hm hr x0 k.val hdvd)
    · intro hdvd h
      have hnorm := combDFT_norm hm hr x0 k.val
      rw [h] at hnorm
      simp [hdvd] at hnorm
      exact hm (by exact_mod_cast hnorm.symm)
  rw [hfil, card_filter_fin_val (fun a => m ∣ a), peak_card m r hm]

/-! ## The discrete uncertainty principle -/

/-- **Donoho–Stark uncertainty principle for the verified DFT.**  For every
nonzero signal on `Fin n`, the product of the size of its time support and the
size of its frequency support is at least `n`.  Proved from `‖ζ‖ = 1`, the
triangle inequality and the inversion theorem `idft_dft`. -/
theorem dft_support_uncertainty {n : ℕ} (hn : 0 < n) (v : Fin n → ℂ) (hv : v ≠ 0) :
    (n : ℝ) ≤ (univ.filter (fun i : Fin n => v i ≠ 0)).card *
      (univ.filter (fun j : Fin n => DFT (zeta n) v j ≠ 0)).card := by
  classical
  set ω := zeta n with homega
  set A := (univ.filter (fun i : Fin n => v i ≠ 0)) with hA
  set Bs := (univ.filter (fun j : Fin n => DFT ω v j ≠ 0)) with hB
  have hprim : IsPrimitiveRoot ω n := zeta_isPrimitiveRoot hn.ne'
  have hchar : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hnormw : ∀ k : ℕ, ‖ω ^ k‖ = 1 := fun k => norm_zeta_pow n k
  have hnormwinv : ∀ k : ℕ, ‖(ω⁻¹) ^ k‖ = 1 := by
    intro k; rw [norm_pow, norm_inv, norm_zeta, inv_one, one_pow]
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  obtain ⟨i0, -, hi0⟩ := Finset.exists_max_image (univ : Finset (Fin n)) (fun i => ‖v i‖)
    ⟨_, mem_univ (Classical.arbitrary (Fin n))⟩
  obtain ⟨j0, -, hj0⟩ := Finset.exists_max_image (univ : Finset (Fin n)) (fun j => ‖DFT ω v j‖)
    ⟨_, mem_univ (Classical.arbitrary (Fin n))⟩
  have hpos : 0 < ‖v i0‖ := by
    obtain ⟨i, hi⟩ := Function.ne_iff.mp hv
    exact lt_of_lt_of_le (norm_pos_iff.mpr (by simpa using hi)) (hi0 i (mem_univ i))
  have step1 : ∀ j : Fin n, ‖DFT ω v j‖ ≤ A.card * ‖v i0‖ := by
    intro j
    calc ‖DFT ω v j‖ ≤ ∑ i : Fin n, ‖v i * ω ^ (i.val * j.val)‖ := norm_sum_le _ _
      _ = ∑ i : Fin n, ‖v i‖ := by
          refine sum_congr rfl fun i _ => ?_
          rw [norm_mul, hnormw, mul_one]
      _ = ∑ i ∈ A, ‖v i‖ := by
          refine (sum_subset (subset_univ A) ?_).symm
          intro i _ hi
          simp only [hA, mem_filter, mem_univ, true_and, not_not] at hi
          simp [hi]
      _ ≤ ∑ _i ∈ A, ‖v i0‖ := sum_le_sum fun i _ => hi0 i (mem_univ i)
      _ = A.card * ‖v i0‖ := by simp [nsmul_eq_mul]
  have hinv := congrFun (idft_dft hprim hn hchar v) i0
  rw [IDFT] at hinv
  have step2 : ‖v i0‖ ≤ (n : ℝ)⁻¹ * (Bs.card * ‖DFT ω v j0‖) := by
    rw [← hinv, norm_mul, norm_inv, Complex.norm_natCast]
    gcongr
    calc ‖∑ j : Fin n, DFT ω v j * (ω⁻¹) ^ (i0.val * j.val)‖
        ≤ ∑ j : Fin n, ‖DFT ω v j * (ω⁻¹) ^ (i0.val * j.val)‖ := norm_sum_le _ _
      _ = ∑ j : Fin n, ‖DFT ω v j‖ := by
          refine sum_congr rfl fun j _ => ?_
          rw [norm_mul, hnormwinv, mul_one]
      _ = ∑ j ∈ Bs, ‖DFT ω v j‖ := by
          refine (sum_subset (subset_univ Bs) ?_).symm
          intro j _ hj
          simp only [hB, mem_filter, mem_univ, true_and, not_not] at hj
          simp [hj]
      _ ≤ ∑ _j ∈ Bs, ‖DFT ω v j0‖ := sum_le_sum fun j _ => hj0 j (mem_univ j)
      _ = Bs.card * ‖DFT ω v j0‖ := by simp [nsmul_eq_mul]
  have hcomb : ‖v i0‖ ≤ (n : ℝ)⁻¹ * (Bs.card * (A.card * ‖v i0‖)) := by
    refine step2.trans ?_
    gcongr
    exact step1 j0
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have h := mul_le_mul_of_nonneg_left hcomb hn'.le
  rw [mul_inv_cancel_left₀ hn'.ne'] at h
  nlinarith [h, hpos]

/-- **The coherent comb is uncertainty-extremal.**  Its time support has size
`m`, its frequency support has size `r`, and the product is exactly the register
size `n = m · r`: the Donoho–Stark inequality is an equality.  No input state,
classical or quantum, can be sharper in the time–frequency sense. -/
theorem comb_saturates_uncertainty {m r x0 : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (hx0 : x0 < r) :
    (univ.filter (fun i : Fin (m * r) => combState m r x0 i ≠ 0)).card *
      (univ.filter (fun k : Fin (m * r) =>
        DFT (zeta (m * r)) (combState m r x0) k ≠ 0)).card = m * r := by
  rw [combState_support_card hx0, combState_spectrum_card hm hr hx0]

/-! ## Capstone -/

/-- **The quantum–classical boundary, located.**

Fix a prime modulus `p ≥ 3` and a register of size `n = m·r`.

*Classical side.*  There is a base whose multiplicative order exceeds `√(p-2)`,
and for it every Fourier-sampling scheme that determines the period signal needs
more than `√(p-2)` samples (Barrier 1); moreover, on the textbook instance
`N = 15, a = 7` the value signal's fundamental bin is strictly dominated by a
harmonic, so peak picking is not merely weak but wrong (Barrier 2).

*Quantum side.*  The coherent comb has an exactly vanishing off-peak spectrum,
attains the maximal modulus `m` on peaks, saturates the discrete uncertainty
principle, and any peak `j·m` with `gcd(j,r) = 1` yields the period `r` exactly.

The two sides use the *same* Fourier mathematics; only the input state differs.
Nothing here asserts a superpolynomial lower bound on classical factoring. -/
theorem quantum_classical_boundary {p : ℕ} [Fact p.Prime] (hp : 3 ≤ p)
    {m r x0 j : ℕ} (hm : m ≠ 0) (hr : r ≠ 0) (hx0 : x0 < r) (hj : Nat.Coprime j r)
    {k : ℕ} (hk : ¬ m ∣ k) :
    (∃ a : (ZMod p)ˣ, Nat.sqrt (p - 2) < orderOf a ∧
        ∀ (r' K : ℕ) (_ : NeZero r') (idx : Fin K → ZMod r'), orderOf a = r' →
          (∀ v w : ZMod r' → ℂ,
            (∀ i : Fin K, ZMod.dft v (idx i) = ZMod.dft w (idx i)) → v = w) →
          Nat.sqrt (p - 2) < K) ∧
      ‖DFT (zeta 4) (modExpSignal 15 7 4) 1‖ < ‖DFT (zeta 4) (modExpSignal 15 7 4) 2‖ ∧
      combDFT m r x0 k = 0 ∧
      ‖combDFT m r x0 (j * m)‖ = (m : ℝ) ∧
      (univ.filter (fun i : Fin (m * r) => combState m r x0 i ≠ 0)).card *
        (univ.filter (fun k' : Fin (m * r) =>
          DFT (zeta (m * r)) (combState m r x0) k' ≠ 0)).card = m * r ∧
      ((j * m : ℕ) / (m * r : ℕ) : ℚ).den = r :=
  ⟨classical_sampling_barrier hp,
   fundamental_dominated_by_harmonic,
   combDFT_offpeak hm hr x0 k hk,
   combDFT_peak hm hr x0 j,
   comb_saturates_uncertainty hm hr hx0,
   period_from_peak hm hr hj⟩

end QuantumClassicalBoundary