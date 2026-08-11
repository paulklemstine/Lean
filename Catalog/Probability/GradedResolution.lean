/-
# Graded modalities do not close the resolution gap

Conjecture 1 of the research thread asked for a finite modal language *with graded
modalities* whose theories classify finite pointed models up to isomorphism, and
Conjecture 4 predicted that adding the graded modality "at least `k` successors"
strictly increases resolution at each level `k`, separating in particular the
identity/swap pair of `Probability/ModalResolution.lean`.

This file **refutes** both predictions in the present framework and isolates what
does work instead.

Main results.

* `Graded.gsat` : the graded observational language — atoms, Boolean connectives and
  the counting modality `grade k φ` ("at least `k` successors of positive
  probability satisfy `φ`").
* `Graded.gsat_transport` : graded truth is invariant under *exact* structural
  analogies, so the language is sound for classification (the easy direction).
* `Graded.det_graded_iff` : **the counting modalities are blind on deterministic
  systems.**  For any two deterministic constant-atom systems — on arbitrary finite
  nonempty world sets, with arbitrary successor functions — every graded formula has
  the same truth value at every world of both systems.  So no amount of grading can
  separate them, at any level `k` and any depth.
* `Graded.gap_persists` : consequently the two-world pair "two self-loops versus one
  `2`-cycle" is graded-equivalent yet admits no structural analogy of defect `< 1`;
  the graded language does **not** classify pointed models up to isomorphism.
* `Graded.loop_separates` / `Graded.loopObs_transport` : the observation that *does*
  separate the pair is not a counting one but the self-reference observation
  `0 < step s s`, which is itself invariant under exact analogies.  So the missing
  resolution is a fixed-point phenomenon, not a multiplicity phenomenon.
-/
import Probability.AnalogyMetric

namespace Catalog.Probability.QuantitativeCopycat

open Finset

namespace Graded

/-! ## The graded observational language -/

/-- Graded modal formulas: atoms, negation, conjunction, and the counting modality
`grade k φ` — "at least `k` successors of positive probability satisfy `φ`". -/
inductive GForm (ι : Type*) : Type _
  | atom : ι → GForm ι
  | neg : GForm ι → GForm ι
  | conj : GForm ι → GForm ι → GForm ι
  | grade : ℕ → GForm ι → GForm ι

variable {ι S S' : Type*} [Fintype S] [Fintype S']

open Classical in
/-- Two-valued semantics of the graded language on a probabilistic modal structure:
an atom holds where its truth probability is positive, and `grade k φ` holds where at
least `k` successors of positive probability satisfy `φ`. -/
def gsat (M : PModalStructure ι S) : GForm ι → S → Prop
  | .atom p, s => 0 < M.val p s
  | .neg φ, s => ¬ gsat M φ s
  | .conj φ ψ, s => gsat M φ s ∧ gsat M ψ s
  | .grade k φ, s =>
      k ≤ (Finset.univ.filter (fun t => 0 < M.step s t ∧ gsat M φ t)).card

theorem gsat_atom (M : PModalStructure ι S) (p : ι) (s : S) :
    gsat M (.atom p) s ↔ 0 < M.val p s := Iff.rfl

theorem gsat_neg (M : PModalStructure ι S) (φ : GForm ι) (s : S) :
    gsat M (.neg φ) s ↔ ¬ gsat M φ s := Iff.rfl

theorem gsat_conj (M : PModalStructure ι S) (φ ψ : GForm ι) (s : S) :
    gsat M (.conj φ ψ) s ↔ (gsat M φ s ∧ gsat M ψ s) := Iff.rfl

open Classical in
theorem gsat_grade (M : PModalStructure ι S) (k : ℕ) (φ : GForm ι) (s : S) :
    gsat M (.grade k φ) s ↔
      k ≤ (Finset.univ.filter (fun t => 0 < M.step s t ∧ gsat M φ t)).card := Iff.rfl

/-! ## Exact analogies transport graded truth -/

/-- Along an exact analogy the transported kernels agree pointwise. -/
theorem step_eq_of_exact {M : PModalStructure ι S} {N : PModalStructure ι S'}
    (A : ApproxAnalogy M N 0) (s t : S) :
    N.step (A.toEquiv s) (A.toEquiv t) = M.step s t := by
  have hsum : ∑ u, N.step (A.toEquiv s) (A.toEquiv u) = 1 := by
    rw [Equiv.sum_comp A.toEquiv (fun v => N.step (A.toEquiv s) v)]
    exact N.step_sum (A.toEquiv s)
  have hd : overlapDefect (M.step s) (fun u => N.step (A.toEquiv s) (A.toEquiv u)) ≤ 0 :=
    A.defect s
  have h0 : overlapDefect (M.step s) (fun u => N.step (A.toEquiv s) (A.toEquiv u)) = 0 :=
    le_antisymm hd (overlapDefect_nonneg _ _ (M.step_sum s))
  have heq := (overlapDefect_eq_zero_iff (M.step s)
    (fun u => N.step (A.toEquiv s) (A.toEquiv u)) (M.step_sum s) hsum).1 h0
  exact (congrFun heq t).symm

/-- **Graded truth is invariant under exact structural analogies.**  (The sound
direction of any classification claim for the graded language.) -/
theorem gsat_transport {M : PModalStructure ι S} {N : PModalStructure ι S'}
    (A : ApproxAnalogy M N 0) (φ : GForm ι) (s : S) :
    gsat M φ s ↔ gsat N φ (A.toEquiv s) := by
  classical
  induction φ generalizing s with
  | atom p => simp only [gsat_atom, A.atoms p s]
  | neg φ ih => simp only [gsat_neg, ih s]
  | conj φ ψ ihφ ihψ => simp only [gsat_conj, ihφ s, ihψ s]
  | grade k φ ih =>
      simp only [gsat_grade]
      have hcard :
          (Finset.univ.filter (fun t => 0 < M.step s t ∧ gsat M φ t)).card
            = (Finset.univ.filter
                (fun u => 0 < N.step (A.toEquiv s) u ∧ gsat N φ u)).card := by
        refine Finset.card_equiv A.toEquiv fun t => ?_
        simp only [Finset.mem_filter, Finset.mem_univ, true_and]
        rw [step_eq_of_exact A s t, ih t]
      rw [hcard]

/-! ## Deterministic systems: counting sees nothing -/

variable (ι) in
/-- The deterministic system with successor function `succ` and all atoms true. -/
def detSys [DecidableEq S] (succ : S → S) : PModalStructure ι S where
  step s t := if t = succ s then 1 else 0
  step_nonneg s t := by split <;> norm_num
  step_sum s := by simp
  val _ _ := 1
  val_nonneg _ _ := by norm_num
  val_le_one _ _ := le_rfl

@[simp] theorem detSys_step [DecidableEq S] (succ : S → S) (s t : S) :
    (detSys ι succ).step s t = if t = succ s then 1 else 0 := rfl

@[simp] theorem detSys_val [DecidableEq S] (succ : S → S) (p : ι) (s : S) :
    (detSys ι succ).val p s = 1 := rfl

open Classical in
/-- In a deterministic system, the successors of `u` satisfying `φ` are either the
single world `succ u` or none at all. -/
theorem det_filter_card [DecidableEq S] (succ : S → S) (φ : GForm ι) (u : S) :
    (Finset.univ.filter
        (fun t => 0 < (detSys ι succ).step u t ∧ gsat (detSys ι succ) φ t)).card
      = if gsat (detSys ι succ) φ (succ u) then 1 else 0 := by
  classical
  by_cases h : gsat (detSys ι succ) φ (succ u)
  · rw [if_pos h]
    have hset : (Finset.univ.filter
        (fun t => 0 < (detSys ι succ).step u t ∧ gsat (detSys ι succ) φ t))
          = {succ u} := by
      ext t
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton,
        detSys_step]
      constructor
      · rintro ⟨hpos, -⟩
        by_contra hne
        rw [if_neg hne] at hpos
        exact lt_irrefl 0 hpos
      · rintro rfl
        exact ⟨by norm_num, h⟩
    rw [hset, Finset.card_singleton]
  · rw [if_neg h, Finset.card_eq_zero]
    ext t
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.notMem_empty,
      iff_false, detSys_step, not_and]
    intro hpos
    by_cases hne : t = succ u
    · subst hne; exact h
    · rw [if_neg hne] at hpos; exact absurd hpos (lt_irrefl 0)

/-- **Counting modalities are blind on deterministic systems.**  Any two
deterministic constant-atom systems — on arbitrary finite nonempty world sets and
with arbitrary successor functions — satisfy exactly the same graded formulas at
every pair of worlds. -/
theorem det_graded_iff [DecidableEq S] [DecidableEq S'] (succ : S → S) (succ' : S' → S')
    (φ : GForm ι) (s : S) (s' : S') :
    gsat (detSys ι succ) φ s ↔ gsat (detSys ι succ') φ s' := by
  classical
  induction φ generalizing s s' with
  | atom p => simp [gsat_atom]
  | neg φ ih => simp only [gsat_neg]; rw [ih s s']
  | conj φ ψ ihφ ihψ => simp only [gsat_conj]; rw [ihφ s s', ihψ s s']
  | grade k φ ih =>
      simp only [gsat_grade, det_filter_card]
      have hiff : gsat (detSys ι succ) φ (succ s) ↔ gsat (detSys ι succ') φ (succ' s') :=
        ih (succ s) (succ' s')
      by_cases h : gsat (detSys ι succ) φ (succ s)
      · rw [if_pos h, if_pos (hiff.1 h)]
      · rw [if_neg h, if_neg (fun hc => h (hiff.2 hc))]

/-! ## The gap persists: graded theories do not classify up to isomorphism -/

/-- Two self-loops (`succ = id`) versus one `2`-cycle (`succ = not`) admit no
structural analogy of defect `< 1`. -/
theorem det_id_not_analogy {ε : ℝ} (hε : ε < 1)
    (A : ApproxAnalogy (detSys ι (id : Bool → Bool)) (detSys ι (not : Bool → Bool)) ε) :
    False := by
  have h := A.defect true
  have hz : ∑ t, min ((detSys ι (id : Bool → Bool)).step true t)
      ((detSys ι (not : Bool → Bool)).step (A.toEquiv true) (A.toEquiv t)) = 0 := by
    refine Finset.sum_eq_zero fun t _ => ?_
    by_cases ht : t = true
    · subst ht
      have hne : A.toEquiv true ≠ !(A.toEquiv true) := by simp
      simp only [detSys_step, id, if_neg hne]
      simp
    · have ht' : t = false := by cases t <;> simp_all
      subst ht'
      have hnn : (0 : ℝ)
          ≤ (detSys ι (not : Bool → Bool)).step (A.toEquiv true) (A.toEquiv false) :=
        (detSys ι (not : Bool → Bool)).step_nonneg _ _
      have hz0 : (detSys ι (id : Bool → Bool)).step true false = 0 := by simp
      rw [hz0, min_eq_left hnn]
  rw [hz] at h
  linarith

/-- **The resolution gap survives grading.**  The pointed systems "two self-loops"
and "one `2`-cycle" satisfy exactly the same graded formulas at every world, yet no
structural analogy — not even an approximate one with defect `< 1` — relates them.
Hence a finite language of graded modalities does *not* classify finite pointed
models up to isomorphism. -/
theorem gap_persists (ι : Type*) :
    (∀ (φ : GForm ι) (s t : Bool),
        gsat (detSys ι (id : Bool → Bool)) φ s
          ↔ gsat (detSys ι (not : Bool → Bool)) φ t) ∧
      IsEmpty (ApproxAnalogy (detSys ι (id : Bool → Bool))
        (detSys ι (not : Bool → Bool)) 0) :=
  ⟨fun φ s t => det_graded_iff _ _ φ s t,
    ⟨fun A => det_id_not_analogy (by norm_num) A⟩⟩

/-! ## What does separate them: self-reference, not multiplicity -/

/-- The self-reference observation: the current world is a successor of itself. -/
def loopObs (M : PModalStructure ι S) (s : S) : Prop := 0 < M.step s s

/-- The self-reference observation is invariant under exact analogies, so it is a
legitimate structural observation. -/
theorem loopObs_transport {M : PModalStructure ι S} {N : PModalStructure ι S'}
    (A : ApproxAnalogy M N 0) (s : S) : loopObs M s ↔ loopObs N (A.toEquiv s) := by
  unfold loopObs
  rw [step_eq_of_exact A s s]

/-- ... and it separates the pair that all graded formulas confuse. -/
theorem loop_separates (s : Bool) :
    loopObs (detSys ι (id : Bool → Bool)) s ∧ ¬ loopObs (detSys ι (not : Bool → Bool)) s := by
  constructor
  · show (0 : ℝ) < (detSys ι (id : Bool → Bool)).step s s
    simp
  · show ¬ (0 : ℝ) < (detSys ι (not : Bool → Bool)).step s s
    have hne : s ≠ !s := by simp
    simp only [detSys_step, if_neg hne]
    exact lt_irrefl 0

end Graded

end Catalog.Probability.QuantitativeCopycat