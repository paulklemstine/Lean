import Applications.AdjacentSumPolytopes.Growth

/-!
# An arctangent closed form for the odd-dimensional open counts

For slack `s = 1` the open adjacent-sum counts are Fibonacci numbers,
`#open(1, d) = F(d+3)` (`Growth.openCount_one`).  The *odd-dimensional* members of that
family — the counts of length `2i + 1`, i.e. `#open(1, 2i) = F(2i+3)` — satisfy a
Machin-type arctangent identity:

`∑_{i ≥ 0} arctan (1 / #open(1, 2i)) = π/4`.

The proof is a telescoping argument.  The Catalan-type Fibonacci identity
`F(m+1)F(m+2) − F(m)F(m+3) = (−1)^m`, specialised to even `m`, turns the arctangent
addition formula into

`arctan(1/F(2k+1)) + arctan(1/F(2k+2)) = arctan(1/F(2k))`,

so the partial sums collapse to `arctan(1/F(2)) − arctan(1/F(2N+2)) = π/4 − o(1)`.

## Main results

* `AdjSum.fib_catalan` : `F(m+1)F(m+2) − F(m)F(m+3) = (−1)^m` over `ℤ`, by induction.
* `AdjSum.arctan_fib_step` : the arctangent three-term identity above.
* `AdjSum.sum_arctan_fib_eq` : the exact partial sum
  `∑_{i < N} arctan(1/F(2i+3)) = π/4 − arctan(1/F(2N+2))`.
* `AdjSum.tendsto_sum_arctan_openCount` : **the closed form**
  `∑_{i ≥ 0} arctan(1 / #open(1, 2i)) = π/4`, stated for the lattice-point counts of the
  odd-dimensional open adjacent-sum sets.

-- !-- Lab Notes -- !--
* **Experiment.** The counts are `#open(1, 2i) = 2, 5, 13, 34, 89, 233, …`, and the partial
  sums of `arctan(1/·)` are `0.463648, 0.661043, 0.737815, 0.767218, 0.778454, 0.782746,
  …`, approaching `π/4 = 0.785398` with error exactly `arctan(1/F(2N+2))`
  (`0.321750, 0.124356, 0.047584, 0.018181, 0.006945, 0.002653`), as the proved
  partial-sum formula predicts.
* **Analysis.** The parity restriction is essential: for *odd* `m` the Catalan sign flips,
  so `F(m+1)F(m+2) − 1 = F(m)F(m+3) − 2` and the arctangent addition formula produces
  `arctan(F(m+3)/(F(m)F(m+3) − 2))`, which is not `arctan(1/F(m))`; only the
  odd-dimensional subfamily telescopes.
* **Critique.** The identity is stated as a limit of partial sums rather than as a `tsum`
  to avoid hiding a summability side condition; the exact partial-sum formula
  `sum_arctan_fib_eq` is the sharp, sorry-free content and the limit is its corollary.
-/

namespace AdjSum

open Filter Finset

/-- **Catalan-type Fibonacci identity.**  `F(m+1)F(m+2) − F(m)F(m+3) = (−1)^m`. -/
theorem fib_catalan (m : ℕ) :
    (Nat.fib (m + 1) : ℤ) * Nat.fib (m + 2) - Nat.fib m * Nat.fib (m + 3) = (-1) ^ m := by
  induction m with
  | zero => simp
  | succ k ih =>
    have h1 := Nat.fib_add_two (n := k)
    have h2 := Nat.fib_add_two (n := k + 1)
    have h3 := Nat.fib_add_two (n := k + 2)
    push_cast [h1, h2, h3] at *
    ring_nf
    ring_nf at ih
    linarith [ih]

/-- The even case of the Catalan identity, over `ℝ`. -/
theorem fib_catalan_even (k : ℕ) :
    (Nat.fib (2 * k + 1) : ℝ) * Nat.fib (2 * k + 2) - 1
      = (Nat.fib (2 * k) : ℝ) * Nat.fib (2 * k + 3) := by
  have h := fib_catalan (2 * k)
  have hsign : ((-1 : ℤ)) ^ (2 * k) = 1 := by
    rw [pow_mul]
    norm_num
  rw [hsign] at h
  have hR : (Nat.fib (2 * k + 1) : ℝ) * Nat.fib (2 * k + 2)
      - (Nat.fib (2 * k) : ℝ) * Nat.fib (2 * k + 3) = 1 := by exact_mod_cast h
  linarith

/-- **The arctangent three-term identity.**  Consecutive odd-index Fibonacci arctangents
telescope. -/
theorem arctan_fib_step {k : ℕ} (hk : 1 ≤ k) :
    Real.arctan (1 / (Nat.fib (2 * k + 1) : ℝ))
        + Real.arctan (1 / (Nat.fib (2 * k + 2) : ℝ))
      = Real.arctan (1 / (Nat.fib (2 * k) : ℝ)) := by
  have h0 : (0 : ℝ) < Nat.fib (2 * k) := by
    exact_mod_cast Nat.fib_pos.mpr (by omega)
  have h1 : (1 : ℝ) ≤ Nat.fib (2 * k + 1) := by
    exact_mod_cast Nat.fib_pos.mpr (by omega)
  have h2 : (2 : ℝ) ≤ Nat.fib (2 * k + 2) := by
    have hmono : Nat.fib 4 ≤ Nat.fib (2 * k + 2) := Nat.fib_mono (by omega)
    have h4 : Nat.fib 4 = 3 := by norm_num
    rw [h4] at hmono
    have : (3 : ℝ) ≤ Nat.fib (2 * k + 2) := by exact_mod_cast hmono
    linarith
  have h1pos : (0 : ℝ) < Nat.fib (2 * k + 1) := by linarith
  have h2pos : (0 : ℝ) < Nat.fib (2 * k + 2) := by linarith
  have hsucc : (Nat.fib (2 * k + 3) : ℝ)
      = (Nat.fib (2 * k + 1) : ℝ) + Nat.fib (2 * k + 2) := by
    have := Nat.fib_add_two (n := 2 * k + 1)
    exact_mod_cast this
  have hcat := fib_catalan_even k
  have hxy : (1 / (Nat.fib (2 * k + 1) : ℝ)) * (1 / (Nat.fib (2 * k + 2) : ℝ)) < 1 := by
    rw [div_mul_div_comm, one_mul, div_lt_one (by positivity)]
    nlinarith
  have hne : (1 : ℝ) - (1 / (Nat.fib (2 * k + 1) : ℝ)) * (1 / (Nat.fib (2 * k + 2) : ℝ)) ≠ 0 := by
    linarith
  rw [Real.arctan_add hxy]
  congr 1
  rw [div_eq_div_iff hne h0.ne']
  field_simp
  nlinarith [hcat, hsucc]

/-- **Exact partial sums.**  The telescoping identity in closed form. -/
theorem sum_arctan_fib_eq (N : ℕ) :
    ∑ i ∈ Finset.range N, Real.arctan (1 / (Nat.fib (2 * i + 3) : ℝ))
      = Real.pi / 4 - Real.arctan (1 / (Nat.fib (2 * N + 2) : ℝ)) := by
  have hterm : ∀ i : ℕ,
      Real.arctan (1 / (Nat.fib (2 * i + 2) : ℝ))
        - Real.arctan (1 / (Nat.fib (2 * (i + 1) + 2) : ℝ))
        = Real.arctan (1 / (Nat.fib (2 * i + 3) : ℝ)) := by
    intro i
    have hstep := arctan_fib_step (k := i + 1) (by omega)
    have he1 : 2 * (i + 1) + 1 = 2 * i + 3 := by ring
    have he2 : 2 * (i + 1) + 2 = 2 * i + 2 + 2 := by ring
    have he3 : 2 * (i + 1) = 2 * i + 2 := by ring
    rw [he1, he3] at hstep
    rw [he2]
    linarith [hstep]
  have hsum := Finset.sum_range_sub'
    (f := fun i : ℕ => Real.arctan (1 / (Nat.fib (2 * i + 2) : ℝ))) N
  rw [← Finset.sum_congr rfl (fun i _ => hterm i)] at *
  rw [hsum]
  have hzero : Real.arctan (1 / (Nat.fib (2 * 0 + 2) : ℝ)) = Real.pi / 4 := by
    norm_num
  rw [hzero]

/-- The tail of the telescoping sum vanishes. -/
theorem tendsto_arctan_fib_tail :
    Tendsto (fun N : ℕ => Real.arctan (1 / (Nat.fib (2 * N + 2) : ℝ))) atTop (nhds 0) := by
  have hinv : Tendsto (fun N : ℕ => (1 : ℝ) / (Nat.fib (2 * N + 2) : ℝ)) atTop (nhds 0) := by
    refine squeeze_zero' ?_ ?_ tendsto_one_div_atTop_nhds_zero_nat
    · filter_upwards [eventually_ge_atTop 1] with N hN
      have : (0 : ℝ) < Nat.fib (2 * N + 2) := by exact_mod_cast Nat.fib_pos.mpr (by omega)
      positivity
    · filter_upwards [eventually_ge_atTop 2] with N hN
      have hle : (2 * N + 2 : ℕ) ≤ Nat.fib (2 * N + 2) := Nat.le_fib_self (by omega)
      have hN' : (N : ℝ) ≤ (Nat.fib (2 * N + 2) : ℝ) := by
        have : (N : ℕ) ≤ Nat.fib (2 * N + 2) := le_trans (by omega) hle
        exact_mod_cast this
      have hNpos : (0 : ℝ) < N := by
        have : (2 : ℝ) ≤ N := by exact_mod_cast hN
        linarith
      exact one_div_le_one_div_of_le hNpos hN'
  have hcont : Tendsto Real.arctan (nhds 0) (nhds 0) := by
    have h := Real.continuous_arctan.tendsto (0 : ℝ)
    rwa [Real.arctan_zero] at h
  exact hcont.comp hinv

/-- **Arctangent closed form, Fibonacci version.** -/
theorem tendsto_sum_arctan_fib :
    Tendsto (fun N : ℕ => ∑ i ∈ Finset.range N, Real.arctan (1 / (Nat.fib (2 * i + 3) : ℝ)))
      atTop (nhds (Real.pi / 4)) := by
  have h := (tendsto_const_nhds (x := Real.pi / 4) (f := atTop (α := ℕ))).sub
    tendsto_arctan_fib_tail
  rw [sub_zero] at h
  exact h.congr (fun N => (sum_arctan_fib_eq N).symm)

/-- **Arctangent closed form for the odd-dimensional open adjacent-sum counts.**  The
arctangent series over the open lattice-point counts of odd dimension sums to `π/4`. -/
theorem tendsto_sum_arctan_openCount :
    Tendsto (fun N : ℕ => ∑ i ∈ Finset.range N, Real.arctan (1 / (openCount 1 (2 * i) : ℝ)))
      atTop (nhds (Real.pi / 4)) := by
  refine tendsto_sum_arctan_fib.congr (fun N => ?_)
  refine Finset.sum_congr rfl (fun i _ => ?_)
  have : openCount 1 (2 * i) = Nat.fib (2 * i + 3) := openCount_one (2 * i)
  rw [this]

end AdjSum