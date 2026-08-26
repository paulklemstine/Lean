import Mathlib

/-!
# Knee invariance: the demand-multiset calculus of budget curves (NET-70)

This file formalises the *combinatorial* content behind the NET-70 measurement
(`MATH-READS-AS-PROSE`):

> A domain jump from English prose to classical mathematical text leaves the
> retention knee `k*` **exactly** where it was (`16` at ctx 512, `20` at ctx
> 1024) even though the full-model accuracy drops by ~12 points
> (`0.4460 → 0.3262` at 512, `0.4612 → 0.3418` at 1024).

The abstraction is the *demand profile*.  A workload is a finite family of
prediction windows; window `i` carries

* a **demand** `r i : ℕ`, the smallest key budget at which the truncated model
  still reproduces the full model's prediction on that window, and
* a **correctness bit** `correct i : Bool`, whether the *full* model's
  prediction on that window is right.

Everything the sweep measures is then read off two derived objects:

* the **agreement curve** `Workload.agree D k = #{i | r i ≤ k} / n`, whose knee
  at a gate `g` is `knee (D.agree) g = sInf {k | g ≤ agree k}`;
* the **accuracy** `Workload.acc D = #{i | correct i} / n`.

The theorems below say, in increasing strength, that these two are *orthogonal
coordinates*:

* `knee_le_iff` — the knee is the left adjoint of the curve (a Galois
  connection); this is the structural reason all later monotonicity facts hold.
* `agree_eq_of_demandMultiset_eq`, `knee_eq_of_demandMultiset_eq` — the entire
  sweep is a function of the **demand multiset** alone: the correctness bits are
  invisible to it.  This is P3 ("knees match despite the accuracy gap") in its
  exact form.
* `decoupling_surjective` — the joint invariant `D ↦ (knee curve, accuracy)` is
  **surjective**: for any target knee `k ≥ 1` and any achievable accuracy value
  there is a workload realising both.  Difficulty and sparsity are therefore
  independent coordinates, not merely uncorrelated in the measured sample.
* `knee_antitone_of_demand_le` — pointwise cheaper demands can only lower the
  knee (the `code < prose` direction of the deployment table).
* `knee_shift` — the **shape-preservation law**: shifting a curve by a scale
  increment `δ` shifts its knee by exactly `δ`, at *every* gate.
* `knee_mix_le_max`, `min_le_knee_mix` — corpus mixing cannot move the knee
  outside the interval spanned by its constituents (barrier (c): "one corpus
  mix").
* `knee_le_of_markov` — a Markov/quantile bridge: the knee is bounded by
  `meanDemand / (1 - gate)`, so a thin demand tail forces a small budget.

None of these mention the accuracy at all — which is the point.
-/

namespace Combinatorics.KneeInvariance

open Finset

/-! ## The knee of a curve -/

/-- The **knee** of a curve `A` at gate `g`: the least budget whose retained
quality reaches the gate.  (`0` if the gate is never reached, by `Nat.sInf`.) -/
noncomputable def knee (A : ℕ → ℚ) (g : ℚ) : ℕ := sInf {k | g ≤ A k}

theorem knee_mem {A : ℕ → ℚ} {g : ℚ} (h : ∃ m, g ≤ A m) : g ≤ A (knee A g) :=
  Nat.sInf_mem (by simpa [Set.Nonempty] using h)

theorem knee_le {A : ℕ → ℚ} {g : ℚ} {k : ℕ} (h : g ≤ A k) : knee A g ≤ k :=
  Nat.sInf_le h

theorem lt_knee_imp {A : ℕ → ℚ} {g : ℚ} {k : ℕ} (h : k < knee A g) : A k < g := by
  by_contra hc
  exact absurd (knee_le (not_lt.mp hc)) (not_le.mpr h)

/-- **Galois adjunction.**  For a monotone curve whose gate is reachable, the
knee is the left adjoint of the curve: `knee A g ≤ k ↔ g ≤ A k`.  Every
monotonicity statement in this file is an instance of this. -/
theorem knee_le_iff {A : ℕ → ℚ} (hA : Monotone A) {g : ℚ} (hne : ∃ m, g ≤ A m)
    {k : ℕ} : knee A g ≤ k ↔ g ≤ A k :=
  ⟨fun h => le_trans (knee_mem hne) (hA h), knee_le⟩

/-- The knee is monotone in the gate. -/
theorem knee_mono_gate {A : ℕ → ℚ} {g₁ g₂ : ℚ} (h : g₁ ≤ g₂)
    (hne : ∃ m, g₂ ≤ A m) : knee A g₁ ≤ knee A g₂ :=
  knee_le (le_trans h (knee_mem hne))

/-- A pointwise better curve has a smaller (or equal) knee. -/
theorem knee_antitone_curve {A B : ℕ → ℚ} (h : ∀ k, A k ≤ B k) {g : ℚ}
    (hne : ∃ m, g ≤ A m) : knee B g ≤ knee A g :=
  knee_le (le_trans (knee_mem hne) (h _))

/-- Characterisation used for the concrete tables: a witness above the gate
together with sub-gate values everywhere below pins the knee exactly. -/
theorem knee_eq_of {A : ℕ → ℚ} {g : ℚ} {k : ℕ} (hk : g ≤ A k)
    (hlt : ∀ j < k, A j < g) : knee A g = k := by
  refine le_antisymm (knee_le hk) ?_
  by_contra hc
  exact absurd (knee_mem ⟨k, hk⟩) (not_le.mpr (hlt _ (not_le.mp hc)))

/-- **Difficulty is a reparametrisation.**  Distorting the quality axis by any
strictly monotone map `ψ` (and transporting the gate along it) leaves the knee
exactly where it was.  This is the abstract form of P3: the knee sees the
*order* of the curve, never its values, so an arbitrary accuracy handicap on the
domain cannot move it. -/
theorem knee_conjugate {A : ℕ → ℚ} {psi : ℚ → ℚ} (hpsi : StrictMono psi) (g : ℚ) :
    knee (fun k => psi (A k)) (psi g) = knee A g := by
  unfold knee
  congr 1
  ext k
  simp [Set.mem_setOf_eq, hpsi.le_iff_le]

/-! ## Workloads: demand profiles with correctness bits -/

/-- A **workload**: `n` prediction windows, each with a key-budget demand and a
bit recording whether the full model is correct there. -/
structure Workload (n : ℕ) where
  /-- Least key budget preserving the full model's prediction on window `i`. -/
  demand : Fin n → ℕ
  /-- Whether the full model's prediction on window `i` is correct. -/
  correct : Fin n → Bool

variable {n : ℕ}

/-- Number of windows served by budget `k`. -/
def agreeCount (D : Workload n) (k : ℕ) : ℕ :=
  (univ.filter fun i => D.demand i ≤ k).card

/-- The measured agreement curve: fraction of windows served by budget `k`. -/
def Workload.agree (D : Workload n) (k : ℕ) : ℚ := (agreeCount D k : ℚ) / n

/-- The measured full-model accuracy. -/
def Workload.acc (D : Workload n) : ℚ :=
  ((univ.filter fun i => D.correct i = true).card : ℚ) / n

/-- The number of `Fin n` indices below a threshold `m ≤ n` is `m`. -/
theorem card_filter_val_lt {n m : ℕ} (hm : m ≤ n) :
    (univ.filter fun i : Fin n => (i : ℕ) < m).card = m := by
  have hcard : (univ.filter fun i : Fin n => (i : ℕ) < m)
      = (Finset.range m).attachFin (fun a ha => lt_of_lt_of_le (mem_range.mp ha) hm) := by
    ext i
    simp [Finset.mem_attachFin]
  rw [hcard, Finset.card_attachFin, Finset.card_range]

/-- The **demand multiset** of a workload — the only thing the sweep sees. -/
def demandMultiset (D : Workload n) : Multiset ℕ := Multiset.map D.demand univ.val

theorem agreeCount_mono (D : Workload n) : Monotone (agreeCount D) := by
  intro a b hab
  exact card_le_card (by
    intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi ⊢
    exact hi.trans hab)

theorem agree_mono (D : Workload n) : Monotone D.agree := by
  intro a b hab
  unfold Workload.agree
  by_cases hn : (n : ℚ) = 0
  · simp [hn]
  · have hpos : (0 : ℚ) < n := lt_of_le_of_ne (by positivity) (Ne.symm hn)
    have : ((agreeCount D a : ℚ)) ≤ (agreeCount D b : ℚ) := by
      exact_mod_cast agreeCount_mono D hab
    gcongr

theorem agree_nonneg (D : Workload n) (k : ℕ) : 0 ≤ D.agree k := by
  unfold Workload.agree; positivity

theorem agree_le_one (D : Workload n) (k : ℕ) : D.agree k ≤ 1 := by
  unfold Workload.agree
  rcases Nat.eq_zero_or_pos n with hn | hn
  · simp [hn]
  · rw [div_le_one (by exact_mod_cast hn)]
    exact_mod_cast le_trans (card_filter_le _ _) (by simp)

/-- Any gate `≤ 1` is reachable: a budget as large as every demand serves all
windows. -/
theorem agree_gate_reachable (D : Workload n) (hn : 0 < n) {g : ℚ} (hg : g ≤ 1) :
    ∃ m, g ≤ D.agree m := by
  classical
  refine ⟨∑ i, D.demand i, le_trans hg (le_of_eq ?_)⟩
  have hcard : (univ.filter fun i => D.demand i ≤ ∑ j, D.demand j) = univ := by
    apply filter_true_of_mem
    intro i _
    exact single_le_sum (f := D.demand) (fun j _ => Nat.zero_le _) (mem_univ i)
  unfold Workload.agree agreeCount
  rw [hcard]
  simp only [card_univ, Fintype.card_fin]
  field_simp

/-! ## Invariance: the sweep only sees the demand multiset -/

theorem agreeCount_eq_countP (D : Workload n) (k : ℕ) :
    agreeCount D k = Multiset.countP (fun d => d ≤ k) (demandMultiset D) := by
  classical
  unfold agreeCount demandMultiset
  rw [Multiset.countP_map]
  rfl

/-- **The sweep is a function of the demand multiset.**  Two workloads with the
same multiset of demands have identical agreement curves — whatever their
correctness bits, hence whatever their accuracies. -/
theorem agree_eq_of_demandMultiset_eq {m : ℕ} (D : Workload n) (E : Workload m)
    (hnm : n = m) (h : demandMultiset D = demandMultiset E) :
    D.agree = E.agree := by
  funext k
  unfold Workload.agree
  rw [agreeCount_eq_countP, agreeCount_eq_countP, h, hnm]

/-- **P3, exactly.**  Equal demand multisets ⇒ equal knees at *every* gate, with
no constraint whatsoever relating the two accuracies. -/
theorem knee_eq_of_demandMultiset_eq {m : ℕ} (D : Workload n) (E : Workload m)
    (hnm : n = m) (h : demandMultiset D = demandMultiset E) (g : ℚ) :
    knee D.agree g = knee E.agree g := by
  rw [agree_eq_of_demandMultiset_eq D E hnm h]

/-- **Rebitting.**  Any workload can have its accuracy moved to an arbitrary
achievable value `j / n` without disturbing a single point of its sweep — in
particular without moving any knee.  Prediction difficulty is a free coordinate
on top of a fixed sparsity structure. -/
theorem exists_rebitting (D : Workload n) {j : ℕ} (hj : j ≤ n) :
    ∃ E : Workload n, E.agree = D.agree ∧ E.acc = (j : ℚ) / n := by
  refine ⟨⟨D.demand, fun i => (i : ℕ) < j⟩, rfl, ?_⟩
  have hset : (univ.filter fun i : Fin n => (decide ((i : ℕ) < j)) = true)
      = univ.filter fun i : Fin n => (i : ℕ) < j := by
    apply filter_congr; intro i _; simp
  unfold Workload.acc
  simp only [hset]
  congr 1
  rw [card_filter_val_lt hj]

/-! ## Full decoupling: knee and accuracy are independent coordinates -/

/-- The **flat workload**: every window demands exactly `k` keys, and the first
`j` windows are predicted correctly. -/
def flat (n k j : ℕ) : Workload n where
  demand := fun _ => k
  correct := fun i => (i : ℕ) < j

theorem flat_agree_of_lt {n k j : ℕ} {b : ℕ} (h : b < k) : (flat n k j).agree b = 0 := by
  have : (univ.filter fun i : Fin n => (flat n k j).demand i ≤ b) = ∅ := by
    apply filter_false_of_mem
    intro i _
    exact not_le.mpr h
  unfold Workload.agree agreeCount
  rw [this]
  simp

theorem flat_agree_of_ge {n k j : ℕ} (hn : 0 < n) {b : ℕ} (h : k ≤ b) :
    (flat n k j).agree b = 1 := by
  have : (univ.filter fun i : Fin n => (flat n k j).demand i ≤ b) = univ :=
    filter_true_of_mem fun i _ => h
  unfold Workload.agree agreeCount
  rw [this]
  simp only [card_univ, Fintype.card_fin]
  field_simp

theorem flat_knee {n k j : ℕ} (hn : 0 < n) {g : ℚ} (hg0 : 0 < g) (hg1 : g ≤ 1) :
    knee (flat n k j).agree g = k :=
  knee_eq_of (by rw [flat_agree_of_ge hn (le_refl k)]; exact hg1)
    (fun b hb => by rw [flat_agree_of_lt hb]; exact hg0)

theorem flat_acc {n j : ℕ} (k : ℕ) (hj : j ≤ n) :
    (flat n k j).acc = (j : ℚ) / n := by
  have : (univ.filter fun i : Fin n => (flat n k j).correct i = true)
      = univ.filter fun i : Fin n => (i : ℕ) < j := by
    apply filter_congr; intro i _; simp [flat]
  unfold Workload.acc
  rw [this]
  congr 1
  rw [card_filter_val_lt hj]

/-- **Full decoupling / surjectivity.**  For every window count `n > 0`, every
budget `k`, and every achievable accuracy `j / n`, there is a workload whose
knee is exactly `k` at *every* admissible gate and whose accuracy is exactly
`j / n`.  The pair (sparsity structure, prediction difficulty) can therefore be
prescribed independently: no inequality links them.  P1 (`harder ⇒ more keys`)
is refuted in the strongest possible sense. -/
theorem decoupling_surjective (n k j : ℕ) (hn : 0 < n) (hj : j ≤ n) :
    ∃ D : Workload n,
      (∀ g : ℚ, 0 < g → g ≤ 1 → knee D.agree g = k) ∧ D.acc = (j : ℚ) / n :=
  ⟨flat n k j, fun _ h0 h1 => flat_knee hn h0 h1, flat_acc k hj⟩

/-- The measured NET-70 shape: two workloads with **identical knees at every
gate** and an accuracy gap of exactly the measured `0.4460 - 0.3262 = 0.1198`
at ctx 512. -/
theorem net70_measured_decoupling :
    ∃ (P M : Workload 10000),
      (∀ g : ℚ, 0 < g → g ≤ 1 → knee P.agree g = 16 ∧ knee M.agree g = 16) ∧
      P.acc - M.acc = (1198 : ℚ) / 10000 := by
  refine ⟨flat 10000 16 4460, flat 10000 16 3262, ?_, ?_⟩
  · exact fun g h0 h1 => ⟨flat_knee (by norm_num) h0 h1, flat_knee (by norm_num) h0 h1⟩
  · rw [flat_acc 16 (by norm_num), flat_acc 16 (by norm_num)]
    norm_num

/-! ## Demand domination: the `code < prose` direction -/

/-- Pointwise cheaper demands can only lower the knee. -/
theorem knee_antitone_of_demand_le (D E : Workload n) (h : ∀ i, D.demand i ≤ E.demand i)
    {g : ℚ} (hne : ∃ m, g ≤ E.agree m) : knee D.agree g ≤ knee E.agree g := by
  refine knee_antitone_curve (fun k => ?_) hne
  unfold Workload.agree
  rcases Nat.eq_zero_or_pos n with hn | hn
  · simp [hn]
  have : agreeCount E k ≤ agreeCount D k := by
    apply card_le_card
    intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi ⊢
    exact le_trans (h i) hi
  have hpos : (0 : ℚ) < n := by exact_mod_cast hn
  have h' : ((agreeCount E k : ℚ)) ≤ (agreeCount D k : ℚ) := by exact_mod_cast this
  gcongr

/-! ## Shape preservation: the scale increment shifts the knee rigidly -/

/-- **Shape-preservation law.**  If the curve at the larger context is the
smaller-context curve translated by an increment `δ`, then the knee translates by
exactly `δ` — at every gate.  (NET-67: "increments are set by scale, shape is
preserved everywhere".) -/
theorem knee_shift (A : ℕ → ℚ) (δ : ℕ) {g : ℚ} (hne : ∃ m, g ≤ A m) (h0 : A 0 < g) :
    knee (fun k => A (k - δ)) g = knee A g + δ := by
  obtain ⟨m, hm⟩ := hne
  refine knee_eq_of (by simpa using knee_mem ⟨m, hm⟩) ?_
  intro b hb
  by_cases hbd : b < δ
  · have : b - δ = 0 := by omega
    simpa [this] using h0
  · exact lt_knee_imp (by omega)

/-! ## Corpus mixing -/

/-- Mixing two curves with weights `θ, 1-θ`. -/
def mixCurve (θ : ℚ) (A B : ℕ → ℚ) : ℕ → ℚ := fun k => θ * A k + (1 - θ) * B k

/-- A mixed corpus never needs more keys than its most demanding constituent. -/
theorem knee_mix_le_max {A B : ℕ → ℚ} (hA : Monotone A) (hB : Monotone B)
    {θ g : ℚ} (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1)
    (hgA : ∃ m, g ≤ A m) (hgB : ∃ m, g ≤ B m) :
    knee (mixCurve θ A B) g ≤ max (knee A g) (knee B g) := by
  set k := max (knee A g) (knee B g) with hk
  have hAk : g ≤ A k := (knee_le_iff hA hgA).mp (le_max_left _ _)
  have hBk : g ≤ B k := (knee_le_iff hB hgB).mp (le_max_right _ _)
  refine knee_le ?_
  have : θ * g + (1 - θ) * g ≤ θ * A k + (1 - θ) * B k := by
    have h1 : θ * g ≤ θ * A k := by nlinarith
    have h2 : (1 - θ) * g ≤ (1 - θ) * B k := by nlinarith
    linarith
  simpa [mixCurve] using by linarith [this]

/-- ... and never fewer than its least demanding one. -/
theorem min_le_knee_mix {A B : ℕ → ℚ} {θ g : ℚ} (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1)
    (hne : ∃ m, g ≤ mixCurve θ A B m) :
    min (knee A g) (knee B g) ≤ knee (mixCurve θ A B) g := by
  set k := knee (mixCurve θ A B) g with hk
  have hmix : g ≤ θ * A k + (1 - θ) * B k := knee_mem hne
  by_contra hc
  push_neg at hc
  have hA : A k < g := lt_knee_imp (lt_of_lt_of_le hc (min_le_left _ _))
  have hB : B k < g := lt_knee_imp (lt_of_lt_of_le hc (min_le_right _ _))
  rcases eq_or_lt_of_le hθ0 with hθ | hθ
  · rw [← hθ] at hmix
    simp only [zero_mul, sub_zero, one_mul, zero_add] at hmix
    linarith
  · have h1 : θ * A k < θ * g := by nlinarith
    have h2 : (1 - θ) * B k ≤ (1 - θ) * g := by nlinarith
    nlinarith

/-! ## A Markov bridge: thin demand tails force small budgets -/

/-- Markov's inequality for demands: the number of windows demanding more than
`k` keys is at most `(∑ demands) / (k+1)`. -/
theorem tail_card_mul_le_sum (D : Workload n) (k : ℕ) :
    (univ.filter fun i => k < D.demand i).card * (k + 1) ≤ ∑ i, D.demand i := by
  classical
  calc (univ.filter fun i => k < D.demand i).card * (k + 1)
      = ∑ _i ∈ univ.filter (fun i => k < D.demand i), (k + 1) := by
        rw [sum_const, smul_eq_mul]
    _ ≤ ∑ i ∈ univ.filter (fun i => k < D.demand i), D.demand i := by
        refine sum_le_sum fun i hi => ?_
        simp only [mem_filter] at hi
        omega
    _ ≤ ∑ i, D.demand i := sum_le_sum_of_subset (filter_subset _ _)

theorem agreeCount_add_tail (D : Workload n) (k : ℕ) :
    agreeCount D k + (univ.filter fun i => k < D.demand i).card = n := by
  classical
  have h : (univ.filter fun i => k < D.demand i)
      = univ.filter fun i => ¬ (D.demand i ≤ k) := by
    apply filter_congr; intro i _; simp
  unfold agreeCount
  rw [h, card_filter_add_card_filter_not]
  simp

/-- **Markov bound on the knee.**  If the total demand is small enough relative
to the slack `1 - g` above the gate, the knee is at most `k`.  Equivalently
`k* ≲ meanDemand / (1 - g)`: a thin demand tail is *sufficient* for a small
budget, no matter how hard the text is to predict. -/
theorem knee_le_of_markov (D : Workload n) (hn : 0 < n) {g : ℚ} {k : ℕ}
    (h : ((∑ i, D.demand i : ℕ) : ℚ) ≤ (1 - g) * n * (k + 1)) :
    knee D.agree g ≤ k := by
  classical
  set T := (univ.filter fun i => k < D.demand i).card with hT
  have hnQ : (0 : ℚ) < n := by exact_mod_cast hn
  have h1 : (T : ℚ) * (k + 1) ≤ ((∑ i, D.demand i : ℕ) : ℚ) := by
    have := tail_card_mul_le_sum D k
    exact_mod_cast this
  have hk1 : (0 : ℚ) < (k : ℚ) + 1 := by positivity
  have h2 : (T : ℚ) ≤ (1 - g) * n := by
    have := h1.trans h
    nlinarith
  have h3 : agreeCount D k + T = n := agreeCount_add_tail D k
  have h4 : ((agreeCount D k : ℚ)) = n - T := by
    have : ((agreeCount D k : ℕ) : ℚ) + (T : ℚ) = (n : ℚ) := by exact_mod_cast h3
    linarith
  refine knee_le ?_
  unfold Workload.agree
  rw [le_div_iff₀ hnQ, h4]
  nlinarith

/-! ## Realisability: every measured count profile comes from a workload -/

/-- The workload synthesised from a **count profile** `t` (`t k` = number of
windows served by budget `k`) and an accuracy numerator `j`. -/
noncomputable def ofCountProfile (n : ℕ) (t : ℕ → ℕ) (j : ℕ) : Workload n where
  demand := fun i => sInf {k | (i : ℕ) < t k}
  correct := fun i => (i : ℕ) < j

theorem ofCountProfile_demand_le_iff {n : ℕ} {t : ℕ → ℕ} (ht : Monotone t) {j : ℕ}
    (hsat : ∀ i : Fin n, ∃ k, (i : ℕ) < t k) (i : Fin n) (k : ℕ) :
    (ofCountProfile n t j).demand i ≤ k ↔ (i : ℕ) < t k := by
  constructor
  · intro h
    have hmem : (i : ℕ) < t (sInf {k | (i : ℕ) < t k}) :=
      Nat.sInf_mem (by simpa [Set.Nonempty] using hsat i)
    exact lt_of_lt_of_le hmem (ht h)
  · intro h
    exact Nat.sInf_le h

/-- **Realisation theorem.**  Every monotone count profile that is bounded by the
window count and eventually saturates it is the exact agreement profile of an
honest workload — with any prescribed accuracy.  Measured sweeps are therefore
not idealisations: they are attained. -/
theorem ofCountProfile_agreeCount {n : ℕ} {t : ℕ → ℕ} (ht : Monotone t)
    (hle : ∀ k, t k ≤ n) (hsat : ∃ K, t K = n) (j k : ℕ) :
    agreeCount (ofCountProfile n t j) k = t k := by
  have hsat' : ∀ i : Fin n, ∃ k, (i : ℕ) < t k := by
    obtain ⟨K, hK⟩ := hsat
    exact fun i => ⟨K, by rw [hK]; exact i.isLt⟩
  have hset : (univ.filter fun i : Fin n => (ofCountProfile n t j).demand i ≤ k)
      = univ.filter fun i : Fin n => (i : ℕ) < t k := by
    apply filter_congr
    intro i _
    simp [ofCountProfile_demand_le_iff ht hsat' i k]
  unfold agreeCount
  rw [hset, card_filter_val_lt (hle k)]

theorem ofCountProfile_agree {n : ℕ} {t : ℕ → ℕ} (ht : Monotone t)
    (hle : ∀ k, t k ≤ n) (hsat : ∃ K, t K = n) (j k : ℕ) :
    (ofCountProfile n t j).agree k = (t k : ℚ) / n := by
  unfold Workload.agree
  rw [ofCountProfile_agreeCount ht hle hsat]

theorem ofCountProfile_acc {n : ℕ} (t : ℕ → ℕ) {j : ℕ} (hj : j ≤ n) :
    (ofCountProfile n t j).acc = (j : ℚ) / n := by
  have hset : (univ.filter fun i : Fin n => (decide ((i : ℕ) < j)) = true)
      = univ.filter fun i : Fin n => (i : ℕ) < j := by
    apply filter_congr; intro i _; simp
  unfold Workload.acc ofCountProfile
  simp only [hset]
  congr 1
  rw [card_filter_val_lt hj]

/-- The knee of a realised workload, read straight off the count profile: it is
the least budget serving at least a `g`-fraction of the windows. -/
theorem ofCountProfile_knee {n : ℕ} {t : ℕ → ℕ} (ht : Monotone t)
    (hle : ∀ k, t k ≤ n) (hsat : ∃ K, t K = n) (j : ℕ) {g : ℚ} {k : ℕ}
    (hn : 0 < n) (hk : g * n ≤ t k) (hlt : ∀ b < k, (t b : ℚ) < g * n) :
    knee (ofCountProfile n t j).agree g = k := by
  have hnQ : (0 : ℚ) < n := by exact_mod_cast hn
  refine knee_eq_of ?_ ?_
  · rw [ofCountProfile_agree ht hle hsat, le_div_iff₀ hnQ]
    linarith
  · intro b hb
    rw [ofCountProfile_agree ht hle hsat, div_lt_iff₀ hnQ]
    linarith [hlt b hb]

end Combinatorics.KneeInvariance