import Catalog.NumberTheory.PrimeFractalHausdorff

/-!
# No fractal dust: the metric structure of twin primes in the prime fractal

The mission's conjecture rests on the picture that "twin primes create a fractal
dust that increases the dimension".  Here we show that the picture is wrong in
a precise, structural way.

* `twin_dist_le` — a twin pair `(p, p+2)` sits at `d`-distance at most
  `2 / (p (log p)^2)`, *not* `∼ 1 / (p log p)` as the mission asserts: the
  mission's heuristic overestimates the twin scale by a factor `log p`.
* `finite_of_le_logInv` — only finitely many primes lie above any positive
  height, so
* `primeFractal_isolated` — **every point of the prime fractal is isolated**.
  A countable, uniformly discrete-away-from-`0` set carries no dust at any
  scale: the accumulation happens only at the single point `0`.
* `zero_mem_closure_iff_infinite` — for any family `T` of primes, `0` is in the
  closure of the corresponding subfractal iff `T` is infinite.  Applied to the
  twin primes (`twin_conjecture_iff_zero_mem_closure`) this turns the twin
  prime conjecture into a purely metric statement about a single point of `ℝ`
  — and that point contributes nothing to any dimension.
-/

namespace PrimeFractal

open Filter Topology

/-- **Corrected twin scale.** A twin pair is at `d`-distance at most `2 / (p (log p)^2)`. -/
theorem twin_dist_le {p : ℕ} (hp : 2 ≤ p) :
    dist (logInv p) (logInv (p + 2)) ≤ 2 / ((p : ℝ) * (Real.log p) ^ 2) := by
  have hP : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hP0 : (0 : ℝ) < (p : ℝ) := by linarith
  have hcast : ((p + 2 : ℕ) : ℝ) = (p : ℝ) + 2 := by push_cast; ring
  have ha0 : 0 < Real.log p := Real.log_pos (by linarith)
  have hb0 : 0 < Real.log ((p : ℝ) + 2) := Real.log_pos (by linarith)
  have hab : Real.log p ≤ Real.log ((p : ℝ) + 2) :=
    Real.log_le_log hP0 (by linarith)
  -- `log (p+2) - log p ≤ 2 / p`
  have hstep : Real.log ((p : ℝ) + 2) - Real.log p ≤ 2 / (p : ℝ) := by
    have hdiv : Real.log (((p : ℝ) + 2) / (p : ℝ)) ≤ ((p : ℝ) + 2) / (p : ℝ) - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_div (by linarith) (ne_of_gt hP0)] at hdiv
    have : ((p : ℝ) + 2) / (p : ℝ) - 1 = 2 / (p : ℝ) := by field_simp; ring
    linarith [hdiv, this.le, this.ge]
  have hdist : dist (logInv p) (logInv (p + 2))
      = 1 / Real.log p - 1 / Real.log ((p : ℝ) + 2) := by
    rw [Real.dist_eq, logInv, logInv, hcast, abs_of_nonneg]
    have h1 : 1 / Real.log ((p : ℝ) + 2) ≤ 1 / Real.log p :=
      one_div_le_one_div_of_le ha0 hab
    linarith
  rw [hdist]
  have hkey : 1 / Real.log p - 1 / Real.log ((p : ℝ) + 2)
      = (Real.log ((p : ℝ) + 2) - Real.log p) / (Real.log p * Real.log ((p : ℝ) + 2)) := by
    field_simp
  rw [hkey, div_le_div_iff₀ (by positivity) (by positivity)]
  have hsq : (Real.log p) ^ 2 ≤ Real.log p * Real.log ((p : ℝ) + 2) := by nlinarith
  have hnum : Real.log ((p : ℝ) + 2) - Real.log p ≤ 2 / (p : ℝ) := hstep
  have h2p : (2 : ℝ) / (p : ℝ) * ((p : ℝ) * (Real.log p) ^ 2) = 2 * (Real.log p) ^ 2 := by
    field_simp
  calc (Real.log ((p : ℝ) + 2) - Real.log p) * ((p : ℝ) * (Real.log p) ^ 2)
      ≤ (2 / (p : ℝ)) * ((p : ℝ) * (Real.log p) ^ 2) := by
        apply mul_le_mul_of_nonneg_right hnum (by positivity)
    _ = 2 * (Real.log p) ^ 2 := h2p
    _ ≤ 2 * (Real.log p * Real.log ((p : ℝ) + 2)) := by linarith

/-- Above any positive height there are only finitely many primes. -/
theorem finite_of_le_logInv {t : ℝ} (ht : 0 < t) :
    {p : ℕ | p.Prime ∧ t ≤ logInv p}.Finite := by
  refine Set.Finite.subset (Set.finite_Iic ⌈Real.exp (1 / t)⌉₊) ?_
  rintro p ⟨hp, hpt⟩
  have hP : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp.two_le
  have hlog : 0 < Real.log p := Real.log_pos (by linarith)
  have hle : Real.log p ≤ 1 / t := by
    rw [logInv] at hpt
    rw [le_div_iff₀ ht]
    rw [le_div_iff₀ hlog] at hpt
    linarith
  have : (p : ℝ) ≤ Real.exp (1 / t) := by
    have := Real.exp_le_exp.mpr hle
    rwa [Real.exp_log (by linarith)] at this
  simp only [Set.mem_Iic]
  have hceil : (p : ℝ) ≤ (⌈Real.exp (1 / t)⌉₊ : ℝ) := le_trans this (Nat.le_ceil _)
  exact_mod_cast hceil

/-- **Every point of the prime fractal is isolated.**  There is no dust: the primes
form a uniformly discrete set away from `0`. -/
theorem primeFractal_isolated {x : ℝ} (hx : x ∈ primeFractal) :
    ∃ ε > 0, ∀ y ∈ primeFractal, |y - x| < ε → y = x := by
  obtain ⟨q, hq, rfl⟩ := hx
  set x : ℝ := logInv q with hxdef
  have hx0 : 0 < x := logInv_pos hq
  -- the points of the fractal above `x/2` form a finite set
  have hfin : (logInv '' {p : ℕ | p.Prime ∧ x / 2 ≤ logInv p}).Finite :=
    (finite_of_le_logInv (by linarith)).image _
  set F : Set ℝ := (logInv '' {p : ℕ | p.Prime ∧ x / 2 ≤ logInv p}) \ {x} with hFdef
  have hFfin : F.Finite := hfin.diff
  have hxF : x ∉ F := by simp [hFdef]
  have hopen : IsOpen Fᶜ := hFfin.isClosed.isOpen_compl
  obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.mp hopen x hxF
  refine ⟨min ε (x / 2), by positivity, ?_⟩
  rintro y ⟨p, hp, rfl⟩ hlt
  have h1 : |logInv p - x| < ε := lt_of_lt_of_le hlt (min_le_left _ _)
  have h2 : |logInv p - x| < x / 2 := lt_of_lt_of_le hlt (min_le_right _ _)
  have hge : x / 2 ≤ logInv p := by
    rw [abs_lt] at h2
    linarith [h2.1]
  by_contra hne
  have hmem : logInv p ∈ F := by
    refine ⟨⟨p, ⟨hp, hge⟩, rfl⟩, ?_⟩
    simpa using hne
  have : logInv p ∈ Metric.ball x ε := by
    rw [Metric.mem_ball, Real.dist_eq]
    exact h1
  exact (hball this) hmem

/-- For any family `T` of primes, `0` lies in the closure of the corresponding
subfractal exactly when `T` is infinite. -/
theorem zero_mem_closure_iff_infinite {T : Set ℕ} (hT : ∀ p ∈ T, Nat.Prime p) :
    (0 : ℝ) ∈ closure (logInv '' T) ↔ T.Infinite := by
  constructor
  · intro h0
    by_contra hfin
    rw [Set.not_infinite] at hfin
    have hclosed : IsClosed (logInv '' T) := (hfin.image _).isClosed
    rw [hclosed.closure_eq] at h0
    obtain ⟨p, hpT, hp0⟩ := h0
    have hpos := logInv_pos (hT p hpT)
    rw [hp0] at hpos
    exact lt_irrefl 0 hpos
  · intro hinf
    rw [Metric.mem_closure_iff]
    intro ε hε
    obtain ⟨p, hpT, hplarge⟩ := hinf.exists_gt ⌈Real.exp (1 / ε)⌉₊
    have hprime := hT p hpT
    have hP : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hprime.two_le
    have hlog : 0 < Real.log p := Real.log_pos (by linarith)
    have hexp : Real.exp (1 / ε) < (p : ℝ) := by
      have h1 : Real.exp (1 / ε) ≤ (⌈Real.exp (1 / ε)⌉₊ : ℝ) := Nat.le_ceil _
      have h2 : ((⌈Real.exp (1 / ε)⌉₊ : ℕ) : ℝ) < (p : ℝ) := by exact_mod_cast hplarge
      linarith
    have hloglt : 1 / ε < Real.log p := by
      have := Real.log_lt_log (Real.exp_pos _) hexp
      rwa [Real.log_exp] at this
    refine ⟨logInv p, ⟨p, hpT, rfl⟩, ?_⟩
    rw [Real.dist_eq, zero_sub, abs_neg, abs_of_pos (logInv_pos hprime), logInv,
      div_lt_iff₀ hlog]
    rw [div_lt_iff₀ hε] at hloglt
    linarith

/-- **The twin prime conjecture as a metric statement.**  There are infinitely many twin
primes iff `0` is in the closure of the twin prime fractal.  Even so, the twin
subfractal has Hausdorff dimension `0` (`dimH_twinPrimeFractal`) and every one of its
points is isolated: the "twin prime dust" does not exist. -/
theorem twin_conjecture_iff_zero_mem_closure :
    {p : ℕ | p.Prime ∧ (p + 2).Prime}.Infinite ↔ (0 : ℝ) ∈ closure twinPrimeFractal := by
  rw [twinPrimeFractal, zero_mem_closure_iff_infinite (fun p hp => hp.1)]

/-- Whatever the twin primes do, every point of the twin subfractal is isolated. -/
theorem twinPrimeFractal_isolated {x : ℝ} (hx : x ∈ twinPrimeFractal) :
    ∃ ε > 0, ∀ y ∈ twinPrimeFractal, |y - x| < ε → y = x := by
  have hsub : twinPrimeFractal ⊆ primeFractal := by
    rintro y ⟨p, hp, rfl⟩
    exact ⟨p, hp.1, rfl⟩
  obtain ⟨ε, hε, h⟩ := primeFractal_isolated (hsub hx)
  exact ⟨ε, hε, fun y hy hlt => h y (hsub hy) hlt⟩

end PrimeFractal