/-
# The analogy distance is an attained metric

`Probability/QuantitativeCopycat.lean` introduced ε-approximate structural analogies
and `Probability/CopycatGroupoid.lean` showed that they form a groupoid graded by
total variation (`refl`, `symm`, `comp`).  Conjecture 3 of the previous cycle asked
whether

  `d(M, N) := inf { ε : ∃ ApproxAnalogy M N ε }`

is an *attained* metric on finite probabilistic systems modulo isomorphism.  This
file settles it, for systems on a common finite world set.

Main results.

* `analogyDist` : the infimum, realized as a `Finset.inf'` over the (finitely many)
  atom-preserving renamings; `analogyDist_mem_Icc` : it lies in `[0,1]`.
* `optimalAnalogy` : the infimum is **attained** — there is an honest
  `ApproxAnalogy M N (analogyDist M N)`.
* `analogyDist_le_iff` : consequently `∃ ApproxAnalogy M N ε ↔ analogyDist M N ≤ ε`,
  so `analogyDist` really is the least admissible defect (a minimum, not just an
  infimum).
* `analogyDist_self`, `analogyDist_comm`, `analogyDist_triangle` : the metric axioms,
  read off from the groupoid operations `refl`, `symm`, `comp`.
* `analogyDist_eq_zero_iff` : the zero set is exactly isomorphism — `d(M,N) = 0` iff
  some atom-preserving renaming carries the kernel of `M` to the kernel of `N`.  So
  `analogyDist` is a genuine metric on isomorphism classes.
* `optimal_transport_le` / `optimal_transport_linear` : the depth-`d` modulus of
  continuity of the map "system ↦ vector of truth probabilities" is
  `1 - (1 - d(M,N))^depth φ`, i.e. the transport theorem holds with the *optimal*
  renaming and the *optimal* constant.
* `Sharp.dist_eq` : the distance is computed exactly on the extremal two-state
  leaking family, `d(exactSys, leakySys ε) = ε`; together with `Sharp.transport_eq`
  this shows the modulus above is attained, so it *is* the modulus of continuity.
-/
import Probability.CopycatGroupoid

namespace Catalog.Probability.QuantitativeCopycat

open Finset

/-! ## Elementary facts about the overlap defect -/

variable {S : Type*} [Fintype S]

/-- The overlap defect of two nonnegative vectors is at most `1`. -/
theorem overlapDefect_le_one (P Q : S → ℝ) (hP : ∀ t, 0 ≤ P t) (hQ : ∀ t, 0 ≤ Q t) :
    overlapDefect P Q ≤ 1 := by
  have h : 0 ≤ ∑ t, min (P t) (Q t) :=
    Finset.sum_nonneg fun t _ => le_min (hP t) (hQ t)
  simp only [overlapDefect]
  linarith

/-- Two probability vectors have zero overlap defect exactly when they are equal. -/
theorem overlapDefect_eq_zero_iff (P Q : S → ℝ) (hP : ∑ t, P t = 1) (hQ : ∑ t, Q t = 1) :
    overlapDefect P Q = 0 ↔ P = Q := by
  constructor
  · intro h
    rw [overlapDefect_eq_half_l1 P Q hP hQ] at h
    have hsum : ∑ t, |P t - Q t| = 0 := by linarith
    have := (Finset.sum_eq_zero_iff_of_nonneg
      (fun t _ => abs_nonneg (P t - Q t))).1 hsum
    funext t
    have ht := this t (Finset.mem_univ t)
    have : P t - Q t = 0 := abs_eq_zero.1 ht
    linarith
  · rintro rfl
    simp only [overlapDefect, min_self]
    rw [hP]; ring

/-! ## The set of atom-preserving renamings -/

variable {ι : Type*} [DecidableEq S]

open Classical in
/-- The finite set of renamings of worlds preserving all atomic truth probabilities.
Every approximate analogy has its underlying bijection in this set. -/
noncomputable def AtomPerm (M N : PModalStructure ι S) : Finset (Equiv.Perm S) :=
  Finset.univ.filter (fun f => ∀ p s, N.val p (f s) = M.val p s)

theorem mem_AtomPerm {M N : PModalStructure ι S} {f : Equiv.Perm S} :
    f ∈ AtomPerm M N ↔ ∀ p s, N.val p (f s) = M.val p s := by
  classical
  simp [AtomPerm]

omit [DecidableEq S] in
/-- The transported kernel of `N` is again a probability vector. -/
theorem step_comp_sum (N : PModalStructure ι S) (f : Equiv.Perm S) (s : S) :
    ∑ t, N.step (f s) (f t) = 1 := by
  rw [Equiv.sum_comp f (fun u => N.step (f s) u)]
  exact N.step_sum (f s)

/-! ## The analogy distance -/

variable [Nonempty S]

/-- The cost of a renaming: the worst-case one-step overlap defect it produces. -/
noncomputable def analogyCost (M N : PModalStructure ι S) (f : Equiv.Perm S) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty
    (fun s => overlapDefect (M.step s) (fun t => N.step (f s) (f t)))

omit [DecidableEq S] in
theorem analogyCost_nonneg (M N : PModalStructure ι S) (f : Equiv.Perm S) :
    0 ≤ analogyCost M N f := by
  obtain ⟨s⟩ := ‹Nonempty S›
  refine le_trans ?_ (Finset.le_sup' _ (Finset.mem_univ s))
  exact overlapDefect_nonneg _ _ (M.step_sum s)

omit [DecidableEq S] in
theorem analogyCost_le_one (M N : PModalStructure ι S) (f : Equiv.Perm S) :
    analogyCost M N f ≤ 1 :=
  Finset.sup'_le _ _ fun s _ =>
    overlapDefect_le_one _ _ (fun t => M.step_nonneg s t)
      (fun t => N.step_nonneg (f s) (f t))

omit [DecidableEq S] in
theorem overlapDefect_le_analogyCost (M N : PModalStructure ι S) (f : Equiv.Perm S) (s : S) :
    overlapDefect (M.step s) (fun t => N.step (f s) (f t)) ≤ analogyCost M N f := by
  unfold analogyCost
  exact Finset.le_sup'
    (fun s => overlapDefect (M.step s) (fun t => N.step (f s) (f t))) (Finset.mem_univ s)

/-- **The analogy distance.** The least defect of an approximate structural analogy
between `M` and `N`; the junk value `1` is used when no atom-preserving renaming
exists at all (in which case there is no analogy of any defect). -/
noncomputable def analogyDist (M N : PModalStructure ι S) : ℝ :=
  if h : (AtomPerm M N).Nonempty then (AtomPerm M N).inf' h (analogyCost M N) else 1

theorem analogyDist_nonneg (M N : PModalStructure ι S) : 0 ≤ analogyDist M N := by
  unfold analogyDist
  split
  · exact Finset.le_inf' _ _ fun f _ => analogyCost_nonneg M N f
  · norm_num

theorem analogyDist_le_one (M N : PModalStructure ι S) : analogyDist M N ≤ 1 := by
  unfold analogyDist
  split
  · rename_i h
    obtain ⟨f, hf⟩ := h
    exact le_trans (Finset.inf'_le _ hf) (analogyCost_le_one M N f)
  · exact le_rfl

theorem analogyDist_mem_Icc (M N : PModalStructure ι S) :
    analogyDist M N ∈ Set.Icc (0 : ℝ) 1 :=
  ⟨analogyDist_nonneg M N, analogyDist_le_one M N⟩

/-- Any approximate analogy witnesses an upper bound for the distance. -/
theorem analogyDist_le_of_analogy {M N : PModalStructure ι S} {ε : ℝ}
    (A : ApproxAnalogy M N ε) : analogyDist M N ≤ ε := by
  have hmem : A.toEquiv ∈ AtomPerm M N := mem_AtomPerm.2 A.atoms
  have hne : (AtomPerm M N).Nonempty := ⟨_, hmem⟩
  have hcost : analogyCost M N A.toEquiv ≤ ε :=
    Finset.sup'_le _ _ fun s _ => A.defect s
  unfold analogyDist
  rw [dif_pos hne]
  exact le_trans (Finset.inf'_le _ hmem) hcost

/-- A renaming realizing the infimum. -/
noncomputable def optimalPerm (M N : PModalStructure ι S)
    (h : (AtomPerm M N).Nonempty) : Equiv.Perm S :=
  (Finset.exists_mem_eq_inf' h (analogyCost M N)).choose

theorem optimalPerm_mem (M N : PModalStructure ι S) (h : (AtomPerm M N).Nonempty) :
    optimalPerm M N h ∈ AtomPerm M N :=
  (Finset.exists_mem_eq_inf' h (analogyCost M N)).choose_spec.1

theorem analogyDist_eq_cost_optimalPerm (M N : PModalStructure ι S)
    (h : (AtomPerm M N).Nonempty) :
    analogyDist M N = analogyCost M N (optimalPerm M N h) := by
  unfold analogyDist
  rw [dif_pos h]
  exact (Finset.exists_mem_eq_inf' h (analogyCost M N)).choose_spec.2

/-- **The infimum is attained**: there is an honest approximate analogy whose defect
is exactly the analogy distance. -/
noncomputable def optimalAnalogy (M N : PModalStructure ι S)
    (h : (AtomPerm M N).Nonempty) : ApproxAnalogy M N (analogyDist M N) where
  toEquiv := optimalPerm M N h
  atoms := mem_AtomPerm.1 (optimalPerm_mem M N h)
  defect s := by
    have h1 : overlapDefect (M.step s)
        (fun t => N.step (optimalPerm M N h s) (optimalPerm M N h t))
          ≤ analogyCost M N (optimalPerm M N h) :=
      overlapDefect_le_analogyCost M N _ s
    have h2 := analogyDist_eq_cost_optimalPerm M N h
    have : overlapDefect (M.step s)
        (fun t => N.step (optimalPerm M N h s) (optimalPerm M N h t))
          ≤ analogyDist M N := by linarith
    exact this

/-- The distance is *the least* admissible defect: an ε-analogy exists iff `ε` is at
least the analogy distance. -/
theorem analogyDist_le_iff (M N : PModalStructure ι S) (h : (AtomPerm M N).Nonempty)
    (ε : ℝ) : Nonempty (ApproxAnalogy M N ε) ↔ analogyDist M N ≤ ε := by
  constructor
  · rintro ⟨A⟩; exact analogyDist_le_of_analogy A
  · intro hle
    exact ⟨(optimalAnalogy M N h).mono hle⟩

/-! ## The metric axioms -/

theorem analogyDist_self (M : PModalStructure ι S) : analogyDist M M = 0 :=
  le_antisymm (analogyDist_le_of_analogy (ApproxAnalogy.refl M)) (analogyDist_nonneg M M)

omit [Nonempty S] in
theorem atomPerm_nonempty_symm {M N : PModalStructure ι S} (h : (AtomPerm M N).Nonempty) :
    (AtomPerm N M).Nonempty := by
  obtain ⟨f, hf⟩ := h
  refine ⟨f.symm, mem_AtomPerm.2 fun p u => ?_⟩
  have := mem_AtomPerm.1 hf p (f.symm u)
  rw [Equiv.apply_symm_apply] at this
  exact this.symm

theorem analogyDist_comm (M N : PModalStructure ι S) :
    analogyDist M N = analogyDist N M := by
  by_cases h : (AtomPerm M N).Nonempty
  · have h' : (AtomPerm N M).Nonempty := atomPerm_nonempty_symm h
    refine le_antisymm ?_ ?_
    · exact analogyDist_le_of_analogy (optimalAnalogy N M h').symm
    · exact analogyDist_le_of_analogy (optimalAnalogy M N h).symm
  · have h' : ¬ (AtomPerm N M).Nonempty := fun hc => h (atomPerm_nonempty_symm hc)
    unfold analogyDist
    rw [dif_neg h, dif_neg h']

theorem analogyDist_triangle (M N K : PModalStructure ι S)
    (h₁ : (AtomPerm M N).Nonempty) (h₂ : (AtomPerm N K).Nonempty) :
    analogyDist M K ≤ analogyDist M N + analogyDist N K :=
  analogyDist_le_of_analogy ((optimalAnalogy M N h₁).comp (optimalAnalogy N K h₂))

/-! ## The zero set is isomorphism -/

/-- An **isomorphism** of probabilistic modal structures: an atom-preserving renaming
that carries the kernel of `M` onto the kernel of `N`. -/
structure PIso (M N : PModalStructure ι S) where
  /-- The underlying renaming of worlds. -/
  toEquiv : Equiv.Perm S
  atoms : ∀ p s, N.val p (toEquiv s) = M.val p s
  steps : ∀ s t, N.step (toEquiv s) (toEquiv t) = M.step s t

/-- An isomorphism is an exact analogy. -/
def PIso.toAnalogy {M N : PModalStructure ι S} (F : PIso M N) : ApproxAnalogy M N 0 where
  toEquiv := F.toEquiv
  atoms := F.atoms
  defect s := by
    have h : ∑ t, min (M.step s t) (N.step (F.toEquiv s) (F.toEquiv t)) = 1 := by
      have : ∀ t, min (M.step s t) (N.step (F.toEquiv s) (F.toEquiv t)) = M.step s t := by
        intro t; rw [F.steps s t, min_self]
      rw [Finset.sum_congr rfl fun t _ => this t]
      exact M.step_sum s
    rw [h]; norm_num

/-- **The zero set of the analogy distance is exactly isomorphism.**  Hence
`analogyDist` descends to a genuine metric on isomorphism classes. -/
theorem analogyDist_eq_zero_iff (M N : PModalStructure ι S) (h : (AtomPerm M N).Nonempty) :
    analogyDist M N = 0 ↔ Nonempty (PIso M N) := by
  constructor
  · intro h0
    set A := optimalAnalogy M N h with hA
    have hdef : ∀ s, overlapDefect (M.step s)
        (fun t => N.step (A.toEquiv s) (A.toEquiv t)) ≤ 0 := by
      intro s
      have h1 : overlapDefect (M.step s)
          (fun t => N.step (A.toEquiv s) (A.toEquiv t)) ≤ analogyDist M N := A.defect s
      linarith
    refine ⟨{ toEquiv := A.toEquiv, atoms := A.atoms, steps := ?_ }⟩
    intro s t
    have hz : overlapDefect (M.step s) (fun t => N.step (A.toEquiv s) (A.toEquiv t)) = 0 :=
      le_antisymm (hdef s) (overlapDefect_nonneg _ _ (M.step_sum s))
    have heq := (overlapDefect_eq_zero_iff (M.step s)
      (fun t => N.step (A.toEquiv s) (A.toEquiv t)) (M.step_sum s)
      (step_comp_sum N A.toEquiv s)).1 hz
    exact (congrFun heq t).symm
  · rintro ⟨F⟩
    exact le_antisymm (analogyDist_le_of_analogy F.toAnalogy) (analogyDist_nonneg M N)

/-! ## Modulus of continuity with the optimal renaming -/

/-- **Optimal transport bound.**  With the *optimal* renaming, depth-`d` truth
probabilities move by at most `1 - (1 - d(M,N))^d`. -/
theorem optimal_transport_le (M N : PModalStructure ι S) (h : (AtomPerm M N).Nonempty)
    (φ : PForm ι) (s : S) :
    |M.eval φ s - N.eval φ ((optimalAnalogy M N h).toEquiv s)|
      ≤ 1 - (1 - analogyDist M N) ^ φ.depth :=
  M.transport_le N (analogyDist_nonneg M N) (analogyDist_le_one M N)
    (optimalAnalogy M N h) φ s

/-- The linear form of the optimal transport bound. -/
theorem optimal_transport_linear (M N : PModalStructure ι S) (h : (AtomPerm M N).Nonempty)
    (φ : PForm ι) (s : S) :
    |M.eval φ s - N.eval φ ((optimalAnalogy M N h).toEquiv s)|
      ≤ φ.depth * analogyDist M N :=
  le_trans (optimal_transport_le M N h φ s)
    (one_sub_pow_le_depth_mul _ (le_trans (analogyDist_le_one M N) (by norm_num)) _)

/-- Structures at analogy distance `0` are modally indistinguishable along the
optimal renaming. -/
theorem eval_eq_of_analogyDist_eq_zero (M N : PModalStructure ι S)
    (h : (AtomPerm M N).Nonempty) (h0 : analogyDist M N = 0) (φ : PForm ι) (s : S) :
    M.eval φ s = N.eval φ ((optimalAnalogy M N h).toEquiv s) := by
  have hb := optimal_transport_le M N h φ s
  have hz : (1 : ℝ) - (1 - analogyDist M N) ^ φ.depth = 0 := by
    rw [h0]; simp
  rw [hz] at hb
  exact sub_eq_zero.1 (abs_eq_zero.1 (le_antisymm hb (abs_nonneg _)))


/-! ## The distance is computed exactly on the extremal family -/

namespace Sharp

variable {ι : Type*} [Nonempty ι] {ε : ℝ}

/-- In the extremal two-state family the atomic valuation pins the renaming down:
the identity is the only atom-preserving bijection. -/
theorem atomPerm_eq_refl (h0 : 0 ≤ ε) (h1 : ε ≤ 1) {f : Equiv.Perm Bool}
    (hf : f ∈ AtomPerm (exactSys ι) (leakySys ι ε h0 h1)) : f = Equiv.refl Bool := by
  obtain ⟨p⟩ := ‹Nonempty ι›
  have h := mem_AtomPerm.1 hf p
  ext s
  have hs := h s
  simp only [leakySys_val, exactSys_val] at hs
  rcases hb : f s with _ | _ <;> cases s <;> rw [hb] at hs <;> simp at hs ⊢

omit [Nonempty ι] in
/-- The one-step overlap defect of the extremal family at the leaking world is
exactly `ε`. -/
theorem overlapDefect_true (h0 : 0 ≤ ε) (h1 : ε ≤ 1) :
    overlapDefect ((exactSys ι).step true)
      (fun t => (leakySys ι ε h0 h1).step true t) = ε := by
  simp only [overlapDefect, Fintype.sum_bool, exactSys_step, leakySys_step]
  norm_num [min_def]
  split_ifs <;> linarith

/-- **The analogy distance of the extremal family is exactly `ε`.**  Combined with
`Sharp.transport_eq` this shows that the modulus `1 - (1 - d(M,N))^depth` of
`optimal_transport_le` is attained: it is the exact modulus of continuity. -/
theorem dist_eq (h0 : 0 ≤ ε) (h1 : ε ≤ 1) :
    analogyDist (exactSys ι) (leakySys ι ε h0 h1) = ε := by
  refine le_antisymm (analogyDist_le_of_analogy (analogy ι h0 h1)) ?_
  have hne : (AtomPerm (exactSys ι) (leakySys ι ε h0 h1)).Nonempty :=
    ⟨(analogy ι h0 h1).toEquiv, mem_AtomPerm.2 (analogy ι h0 h1).atoms⟩
  have hfr : optimalPerm (exactSys ι) (leakySys ι ε h0 h1) hne = Equiv.refl Bool :=
    atomPerm_eq_refl h0 h1 (optimalPerm_mem (exactSys ι) (leakySys ι ε h0 h1) hne)
  have hcost := analogyDist_eq_cost_optimalPerm (exactSys ι) (leakySys ι ε h0 h1) hne
  rw [hcost, hfr]
  have hle :=
    overlapDefect_le_analogyCost (exactSys ι) (leakySys ι ε h0 h1) (Equiv.refl Bool) true
  simp only [Equiv.refl_apply] at hle
  rw [overlapDefect_true h0 h1] at hle
  exact hle

end Sharp

end Catalog.Probability.QuantitativeCopycat