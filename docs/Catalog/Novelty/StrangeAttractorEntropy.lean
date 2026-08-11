import Novelty.StrangeAttractorLorenzTemplate

/-!
# Strange attractors as algebraic objects, VI: entropy of the inverse limit

The finite graph approximants of a symbolic attractor grow submultiplicatively: cutting a
long path in two gives an injection into a product of shorter path sets.  By Fekete's
subadditivity lemma the growth rate

`h(E) = lim_{n → ∞} log (number of paths with n edges) / n`

therefore exists for **every** finite directed graph without dead ends.  This is the
topological entropy of the attractor, read off from the inverse-limit diagram.

* `card_finPath_add_le` : submultiplicativity of the approximant sizes;
* `entropy`, `tendsto_entropy` : the entropy exists as a genuine limit;
* `entropy_le_log_card`, `entropy_mono` : the entropy is bounded by `log #V` and is monotone
  under adding edges;
* `entropy_lorenzTemplate` : the Lorenz template attractor has entropy `log 2`;
* `entropy_prunedTemplate` : the pruned template has entropy `log φ`, the logarithm of the
  golden ratio — an arithmetic constant emerging from a dynamical invariant;
* `entropy_pruned_lt_lorenz` : the two entropies differ, re-proving the non-conjugacy of
  the two attractors by an analytic route independent of the periodic-orbit count.
-/

namespace LorenzLimit

open Filter Topology

variable {V : Type*} [Fintype V] {E : V → V → Bool}

/-! ## Submultiplicativity of the approximants -/

/-- Cut a path with `m + n` edges into its first `m` and last `n` edges. -/
def splitPath (m n : ℕ) (w : FinPath E (m + n)) : FinPath E m × FinPath E n :=
  (⟨fun i => w.1 ⟨i.val, by omega⟩, fun i => w.2 ⟨i.val, by omega⟩⟩,
   ⟨fun i => w.1 ⟨m + i.val, by omega⟩, fun i => w.2 ⟨m + i.val, by omega⟩⟩)

omit [Fintype V] in
theorem splitPath_injective (m n : ℕ) : Function.Injective (splitPath (E := E) m n) := by
  intro w w' hww
  apply FinPath.ext
  intro k
  rcases le_or_gt k.val m with hk | hk
  · have h := congrArg (fun p => p.1.1 ⟨k.val, by omega⟩) hww
    simpa using h
  · have h := congrArg (fun p => p.2.1 ⟨k.val - m, by omega⟩) hww
    simp only [splitPath] at h
    have e : m + (k.val - m) = k.val := by omega
    simp only [e] at h
    convert h using 2

/-- **Submultiplicativity.**  A path with `m + n` edges is determined by its first `m` and
its last `n` edges, so the finite approximants of the inverse limit satisfy
`N_{m+n} ≤ N_m · N_n`. -/
theorem card_finPath_add_le (m n : ℕ) :
    Fintype.card (FinPath E (m + n))
      ≤ Fintype.card (FinPath E m) * Fintype.card (FinPath E n) := by
  have h := Fintype.card_le_of_injective _ (splitPath_injective (E := E) m n)
  simpa using h

/-! ## Existence of the entropy -/

/-- The logarithmic path-counting sequence of the graph. -/
noncomputable def logCount (E : V → V → Bool) (n : ℕ) : ℝ :=
  Real.log (Fintype.card (FinPath E n))

theorem logCount_nonneg [Nonempty V] (h : NoDeadEnds E) (n : ℕ) : 0 ≤ logCount E n := by
  apply Real.log_nonneg
  exact_mod_cast finPath_card_pos h n

theorem logCount_subadditive [Nonempty V] (h : NoDeadEnds E) : Subadditive (logCount E) := by
  intro m n
  have hm : 0 < Fintype.card (FinPath E m) := finPath_card_pos h m
  have hn : 0 < Fintype.card (FinPath E n) := finPath_card_pos h n
  have hmn := card_finPath_add_le (E := E) m n
  have hmR : (0 : ℝ) < Fintype.card (FinPath E m) := by exact_mod_cast hm
  have hnR : (0 : ℝ) < Fintype.card (FinPath E n) := by exact_mod_cast hn
  have hstep : (Fintype.card (FinPath E (m + n)) : ℝ)
      ≤ (Fintype.card (FinPath E m) : ℝ) * (Fintype.card (FinPath E n) : ℝ) := by
    exact_mod_cast hmn
  calc logCount E (m + n) ≤ Real.log ((Fintype.card (FinPath E m) : ℝ)
        * (Fintype.card (FinPath E n) : ℝ)) := by
        have hpos : (0 : ℝ) < Fintype.card (FinPath E (m + n)) := by
          exact_mod_cast finPath_card_pos h (m + n)
        exact Real.log_le_log hpos hstep
    _ = logCount E m + logCount E n := Real.log_mul (ne_of_gt hmR) (ne_of_gt hnR)

theorem bddBelow_logCount [Nonempty V] (h : NoDeadEnds E) :
    BddBelow (Set.range fun n => logCount E n / n) := by
  refine ⟨0, ?_⟩
  rintro x ⟨n, rfl⟩
  exact div_nonneg (logCount_nonneg h n) (Nat.cast_nonneg n)

/-- **Topological entropy of a symbolic attractor.**  The exponential growth rate of the
finite graph approximants. -/
noncomputable def entropy [Nonempty V] (h : NoDeadEnds E) : ℝ := (logCount_subadditive h).lim

/-- The entropy really is the limit of `log N_n / n`. -/
theorem tendsto_entropy [Nonempty V] (h : NoDeadEnds E) :
    Tendsto (fun n : ℕ => logCount E n / n) atTop (𝓝 (entropy h)) :=
  (logCount_subadditive h).tendsto_lim (bddBelow_logCount h)

/-! ## General bounds and monotonicity of the entropy -/

theorem tendsto_succ_mul_div (c : ℝ) :
    Tendsto (fun n : ℕ => ((n : ℝ) + 1) * c / n) atTop (𝓝 c) := by
  have hlim : Tendsto (fun n : ℕ => c + c / n) atTop (𝓝 (c + 0)) :=
    tendsto_const_nhds.add (tendsto_const_div_atTop_nhds_zero_nat c)
  rw [add_zero] at hlim
  refine hlim.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with n hn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  field_simp

theorem card_finPath_le_pow (n : ℕ) :
    Fintype.card (FinPath E n) ≤ Fintype.card V ^ (n + 1) := by
  have h : Fintype.card (FinPath E n) ≤ Fintype.card (Fin (n + 1) → V) :=
    Fintype.card_le_of_injective (fun w => w.1) fun _ _ hw => Subtype.ext hw
  simpa using h

/-- **The entropy is at most `log #V`.**  A finite graph with `k` vertices cannot carry more
than `log k` of entropy; for the Lorenz template (`k = 2`) this bound is attained. -/
theorem entropy_le_log_card [Nonempty V] (h : NoDeadEnds E) :
    entropy h ≤ Real.log (Fintype.card V) := by
  refine le_of_tendsto_of_tendsto' (tendsto_entropy h)
    (tendsto_succ_mul_div (Real.log (Fintype.card V))) ?_
  intro n
  have hVpos : (0 : ℝ) < Fintype.card V := by
    have : 0 < Fintype.card V := Fintype.card_pos
    exact_mod_cast this
  have hpos : (0 : ℝ) < Fintype.card (FinPath E n) := by
    have := finPath_card_pos h n
    exact_mod_cast this
  have hle : (Fintype.card (FinPath E n) : ℝ) ≤ (Fintype.card V : ℝ) ^ (n + 1) := by
    have := card_finPath_le_pow (E := E) n
    exact_mod_cast this
  have hlog : logCount E n ≤ ((n : ℝ) + 1) * Real.log (Fintype.card V) := by
    have h1 : Real.log (Fintype.card (FinPath E n))
        ≤ Real.log ((Fintype.card V : ℝ) ^ (n + 1)) := Real.log_le_log hpos hle
    rwa [Real.log_pow, show ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 by push_cast; ring] at h1
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · have hnR : (0 : ℝ) < n := by exact_mod_cast hn
    gcongr

/-- **Entropy is monotone in the graph.**  Adding edges cannot decrease the exponential
growth rate of the inverse-limit approximants. -/
theorem entropy_mono [Nonempty V] {F : V → V → Bool} (hE : NoDeadEnds E) (hF : NoDeadEnds F)
    (hEF : ∀ u v, E u v = true → F u v = true) : entropy hE ≤ entropy hF := by
  refine le_of_tendsto_of_tendsto' (tendsto_entropy hE) (tendsto_entropy hF) ?_
  intro n
  have hinj : Function.Injective (fun w : FinPath E n =>
      (⟨w.1, fun i => hEF _ _ (w.2 i)⟩ : FinPath F n)) := by
    intro a b hab
    exact Subtype.ext (congrArg (fun z : FinPath F n => z.1) hab)
  have hcard : Fintype.card (FinPath E n) ≤ Fintype.card (FinPath F n) :=
    Fintype.card_le_of_injective _ hinj
  have hposE : (0 : ℝ) < Fintype.card (FinPath E n) := by
    have := finPath_card_pos hE n
    exact_mod_cast this
  have hcardR : (Fintype.card (FinPath E n) : ℝ) ≤ (Fintype.card (FinPath F n) : ℝ) := by
    exact_mod_cast hcard
  have hlog : logCount E n ≤ logCount F n := Real.log_le_log hposE hcardR
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · have hnR : (0 : ℝ) < n := by exact_mod_cast hn
    gcongr

/-! ## The entropy of the Lorenz template is `log 2` -/

theorem logCount_lorenz (n : ℕ) :
    logCount lorenzTemplate n = ((n : ℝ) + 1) * Real.log 2 := by
  rw [logCount, card_finPath_lorenz]
  push_cast
  rw [Real.log_pow]
  push_cast
  ring

theorem tendsto_logCount_lorenz :
    Tendsto (fun n : ℕ => logCount lorenzTemplate n / n) atTop (𝓝 (Real.log 2)) := by
  have hlim : Tendsto (fun n : ℕ => Real.log 2 + Real.log 2 / n) atTop
      (𝓝 (Real.log 2 + 0)) :=
    tendsto_const_nhds.add (tendsto_const_div_atTop_nhds_zero_nat (Real.log 2))
  rw [add_zero] at hlim
  refine hlim.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with n hn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  rw [logCount_lorenz]
  field_simp

/-- **The Lorenz template attractor has topological entropy `log 2`.** -/
theorem entropy_lorenzTemplate :
    entropy (Branching.noDeadEnds branching_lorenzTemplate) = Real.log 2 :=
  tendsto_nhds_unique (tendsto_entropy _) tendsto_logCount_lorenz

/-- The bound `entropy ≤ log #V` is sharp: the Lorenz template attains it. -/
theorem entropy_lorenz_eq_log_card :
    entropy (Branching.noDeadEnds branching_lorenzTemplate) = Real.log (Fintype.card Bool) := by
  rw [entropy_lorenzTemplate]
  norm_num

/-! ## The entropy of the pruned template is `log φ` -/

open Real in
theorem goldenRatio_le_two : (goldenRatio : ℝ) ≤ 2 := by
  have h5 : Real.sqrt 5 ≤ 3 := by
    rw [show (3 : ℝ) = Real.sqrt 9 by
      rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_le_sqrt (by norm_num)
  unfold Real.goldenRatio
  linarith

open Real in
/-- Fibonacci numbers dominate the powers of the golden ratio. -/
theorem goldenRatio_pow_le_fib (n : ℕ) :
    (goldenRatio : ℝ) ^ n ≤ Nat.fib (n + 2) := by
  have key : ∀ n : ℕ, (goldenRatio : ℝ) ^ n ≤ Nat.fib (n + 2) ∧
      (goldenRatio : ℝ) ^ (n + 1) ≤ Nat.fib (n + 3) := by
    intro n
    induction n with
    | zero =>
        constructor
        · simp
        · have : (Nat.fib 3 : ℝ) = 2 := by norm_num [Nat.fib]
          rw [this]
          simpa using goldenRatio_le_two
    | succ n ih =>
        obtain ⟨ha, hb⟩ := ih
        refine ⟨hb, ?_⟩
        have hfib : (Nat.fib (n + 4) : ℝ) = Nat.fib (n + 2) + Nat.fib (n + 3) := by
          have h : n + 4 = (n + 2) + 2 := by ring
          rw [h, Nat.fib_add_two]
          push_cast
          ring
        have hstep : (goldenRatio : ℝ) ^ (n + 1 + 1) = goldenRatio ^ n + goldenRatio ^ (n + 1) := by
          rw [show n + 1 + 1 = n + 2 by ring, pow_add, goldenRatio_sq]
          ring
        rw [show n + 1 + 3 = n + 4 by ring, hfib, hstep]
        linarith
  exact (key n).1

open Real in
/-- Fibonacci numbers are dominated by the powers of the golden ratio. -/
theorem fib_le_goldenRatio_pow (n : ℕ) : (Nat.fib (n + 1) : ℝ) ≤ goldenRatio ^ n := by
  have key : ∀ n : ℕ, (Nat.fib (n + 1) : ℝ) ≤ goldenRatio ^ n ∧
      (Nat.fib (n + 2) : ℝ) ≤ goldenRatio ^ (n + 1) := by
    intro n
    induction n with
    | zero =>
        refine ⟨by norm_num [Nat.fib], ?_⟩
        have : (Nat.fib 2 : ℝ) = 1 := by norm_num [Nat.fib]
        rw [this]
        simpa using one_lt_goldenRatio.le
    | succ n ih =>
        obtain ⟨ha, hb⟩ := ih
        refine ⟨hb, ?_⟩
        have hfib : (Nat.fib (n + 3) : ℝ) = Nat.fib (n + 1) + Nat.fib (n + 2) := by
          have h : n + 3 = (n + 1) + 2 := by ring
          rw [h, Nat.fib_add_two]
          push_cast
          ring
        have hstep : (goldenRatio : ℝ) ^ (n + 1 + 1) = goldenRatio ^ n + goldenRatio ^ (n + 1) := by
          rw [show n + 1 + 1 = n + 2 by ring, pow_add, goldenRatio_sq]
          ring
        rw [show n + 1 + 2 = n + 3 by ring, hfib, hstep]
        linarith
  exact (key n).1

open Real in
theorem logCount_pruned (n : ℕ) :
    logCount prunedTemplate (n + 1) = Real.log (Nat.fib (n + 4)) := by
  rw [logCount, card_finPath_pruned]

open Real in
theorem tendsto_logCount_pruned :
    Tendsto (fun n : ℕ => logCount prunedTemplate n / n) atTop (𝓝 (Real.log goldenRatio)) := by
  have hgpos : (0 : ℝ) < goldenRatio := goldenRatio_pos
  have hglog : 0 < Real.log goldenRatio := Real.log_pos one_lt_goldenRatio
  -- lower and upper comparison sequences
  have hzero : Tendsto (fun n : ℕ => Real.log goldenRatio / (n : ℝ)) atTop (𝓝 0) :=
    tendsto_const_div_atTop_nhds_zero_nat _
  have hzero2 : Tendsto (fun n : ℕ => 2 * Real.log goldenRatio / (n : ℝ)) atTop (𝓝 0) :=
    tendsto_const_div_atTop_nhds_zero_nat _
  have hlow : Tendsto (fun n : ℕ => Real.log goldenRatio - Real.log goldenRatio / n) atTop
      (𝓝 (Real.log goldenRatio)) := by
    simpa using (tendsto_const_nhds (x := Real.log goldenRatio) (f := atTop)).sub hzero
  have hhigh : Tendsto (fun n : ℕ => Real.log goldenRatio + 2 * Real.log goldenRatio / n) atTop
      (𝓝 (Real.log goldenRatio)) := by
    simpa using (tendsto_const_nhds (x := Real.log goldenRatio) (f := atTop)).add hzero2
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [eventually_gt_atTop 0] with n hn
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
    have hc : (0 : ℝ) < (m : ℝ) + 1 := by positivity
    have hcast : ((m + 1 : ℕ) : ℝ) = (m : ℝ) + 1 := by push_cast; ring
    have hbound : (goldenRatio : ℝ) ^ (m + 2) ≤ Nat.fib (m + 4) := by
      simpa [show m + 2 + 2 = m + 4 by ring] using goldenRatio_pow_le_fib (m + 2)
    have hlog : ((m : ℝ) + 2) * Real.log goldenRatio ≤ Real.log (Nat.fib (m + 4)) := by
      have h1 : Real.log ((goldenRatio : ℝ) ^ (m + 2)) ≤ Real.log (Nat.fib (m + 4)) :=
        Real.log_le_log (by positivity) hbound
      rwa [Real.log_pow, show ((m + 2 : ℕ) : ℝ) = (m : ℝ) + 2 by push_cast; ring] at h1
    rw [logCount_pruned, hcast, le_div_iff₀ hc]
    have hmul : (Real.log goldenRatio - Real.log goldenRatio / ((m : ℝ) + 1)) * ((m : ℝ) + 1)
        = (m : ℝ) * Real.log goldenRatio := by
      field_simp
      ring
    rw [hmul]
    nlinarith [hlog, hglog]
  · filter_upwards [eventually_gt_atTop 0] with n hn
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
    have hc : (0 : ℝ) < (m : ℝ) + 1 := by positivity
    have hcast : ((m + 1 : ℕ) : ℝ) = (m : ℝ) + 1 := by push_cast; ring
    have hbound : (Nat.fib (m + 4) : ℝ) ≤ goldenRatio ^ (m + 3) := by
      simpa [show m + 3 + 1 = m + 4 by ring] using fib_le_goldenRatio_pow (m + 3)
    have hlog : Real.log (Nat.fib (m + 4)) ≤ ((m : ℝ) + 3) * Real.log goldenRatio := by
      have hpos : (0 : ℝ) < Nat.fib (m + 4) := by
        have := Nat.fib_pos.2 (show 0 < m + 4 by omega)
        exact_mod_cast this
      have h1 : Real.log (Nat.fib (m + 4)) ≤ Real.log ((goldenRatio : ℝ) ^ (m + 3)) :=
        Real.log_le_log hpos hbound
      rwa [Real.log_pow, show ((m + 3 : ℕ) : ℝ) = (m : ℝ) + 3 by push_cast; ring] at h1
    rw [logCount_pruned, hcast, div_le_iff₀ hc]
    have hmul : (Real.log goldenRatio + 2 * Real.log goldenRatio / ((m : ℝ) + 1)) * ((m : ℝ) + 1)
        = ((m : ℝ) + 3) * Real.log goldenRatio := by
      field_simp
      ring
    rw [hmul]
    exact hlog

/-- **The pruned Lorenz template has topological entropy `log φ`.**  The golden ratio, an
arithmetic constant, is the growth rate of the finite graph approximants. -/
theorem entropy_prunedTemplate :
    entropy noDeadEnds_prunedTemplate = Real.log Real.goldenRatio :=
  tendsto_nhds_unique (tendsto_entropy _) tendsto_logCount_pruned

/-- **Entropy separates the two attractors.**  The pruned template has strictly smaller
entropy than the Lorenz template, an analytic proof of non-conjugacy independent of the
periodic-orbit count. -/
theorem entropy_pruned_lt_lorenz :
    entropy noDeadEnds_prunedTemplate
      < entropy (Branching.noDeadEnds branching_lorenzTemplate) := by
  rw [entropy_prunedTemplate, entropy_lorenzTemplate]
  apply Real.log_lt_log Real.goldenRatio_pos
  have h5 : Real.sqrt 5 < 3 := by
    rw [show (3 : ℝ) = Real.sqrt 9 by
      rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  unfold Real.goldenRatio
  linarith

end LorenzLimit