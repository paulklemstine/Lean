/-
# Doppelgänger Phase-Lock — the topology of locking stimulus streams

Real environments do not hand the agents a finite word; they hand them an infinite
stimulus stream `x : ℕ → I`.  Equip the stream space with the product topology of the
discrete stimulus alphabet (the Cantor topology).  The **lock set**

`LockSet δ = {x | some finite prefix of x phase-locks the two agents}`

is then a topological object, and this file determines its topological type exactly:

* it is always **open** — locking is a finitary, observable event: it is decided by a
  finite prefix, so it survives every sufficiently small perturbation of the stream;
* it is **dense** as soon as the agent is phase-locking at all — any experiment, no matter
  how it has been constrained on finitely many observations, can still be continued into a
  locking stream;
* consequently it is either **empty** (non-locking agent) or **open and dense**, with
  nowhere-dense complement: a topological zero–one law for doppelgänger telepathy.

## Main results

* `Doppelganger.isOpen_lockSet`
* `Doppelganger.dense_lockSet`
* `Doppelganger.lockSet_eq_empty_iff`
* `Doppelganger.lockSet_dichotomy` — the zero–one law.
* `Doppelganger.interior_compl_lockSet` — nowhere-density of the failure set.
-/
import Applications.DoppelgangerPhaseLock.Core

namespace Doppelganger

variable {S I : Type*}

/-- The set of infinite stimulus streams that phase-lock the doppelgänger pair after
finitely many observations. -/
def LockSet (δ : S → I → S) : Set (ℕ → I) := {x | ∃ n, Locks δ (pre x n)}

/-- Splice: follow the stream `x` for `N` observations, then observe the word `w`
(and the filler stimulus `c` afterwards). -/
def splice (x : ℕ → I) (N : ℕ) (w : List I) (c : I) : ℕ → I :=
  fun k => if k < N then x k else w.getD (k - N) c

@[simp] lemma getElem_pre (y : ℕ → I) (n k : ℕ) (h : k < (pre y n).length) :
    (pre y n)[k] = y k := by
  simp only [pre] at h ⊢
  simp [List.getElem_ofFn]

lemma pre_congr {x y : ℕ → I} {n : ℕ} (h : ∀ i < n, y i = x i) : pre y n = pre x n := by
  unfold pre
  congr 1
  funext i
  exact h i i.isLt

lemma pre_splice (x : ℕ → I) (N : ℕ) (w : List I) (c : I) :
    pre (splice x N w c) (N + w.length) = pre x N ++ w := by
  apply List.ext_getElem
  · simp
  · intro k h1 h2
    have hlenL : (pre x N).length = N := by simp
    have hk1 : k < N + w.length := by simpa using h1
    rw [getElem_pre]
    by_cases hk : k < N
    · rw [List.getElem_append_left (by omega), getElem_pre]
      simp [splice, hk]
    · rw [List.getElem_append_right (by omega)]
      simp only [splice, if_neg hk, hlenL]
      rw [List.getD_eq_getElem _ _ (by omega)]

/-- Locking a stream is inherited from its shift: if the doppelgängers lock along the
stream from which the first stimulus has been deleted, they lock along the stream. -/
theorem mem_lockSet_of_shift (δ : S → I → S) (x : ℕ → I)
    (h : (fun k => x (k + 1)) ∈ LockSet δ) : x ∈ LockSet δ := by
  obtain ⟨n, hn⟩ := h
  refine ⟨n + 1, ?_⟩
  have hsplit : pre x (n + 1) = [x 0] ++ pre (fun k => x (k + 1)) n := by
    apply List.ext_getElem
    · simp
    · intro k h1 h2
      rw [getElem_pre]
      match k with
      | 0 => simp
      | (j + 1) =>
          rw [List.getElem_append_right (by simp)]
          simp
  rw [hsplit]
  exact hn.append_left δ _

section Topology

variable [TopologicalSpace I] [DiscreteTopology I]

/-- **Locking is an open (finitely observable) event.** -/
theorem isOpen_lockSet (δ : S → I → S) : IsOpen (LockSet δ) := by
  rw [isOpen_iff_forall_mem_open]
  rintro x ⟨n, hn⟩
  refine ⟨⋂ i ∈ Finset.range n, (fun y : ℕ → I => y i) ⁻¹' {x i}, ?_, ?_, ?_⟩
  · intro y hy
    simp only [Set.mem_iInter, Set.mem_preimage, Set.mem_singleton_iff, Finset.mem_range] at hy
    exact ⟨n, by rw [pre_congr (fun i hi => hy i hi)]; exact hn⟩
  · exact isOpen_biInter_finset (fun i _ => (isOpen_discrete _).preimage (continuous_apply i))
  · simp

omit [DiscreteTopology I] in
/-- **Locking streams are dense.**  For a phase-locking agent, *any* finite record of
observations can be continued into a stream along which the two separated agents
synchronize. -/
theorem dense_lockSet (δ : S → I → S) (h : PhaseLocking δ) : Dense (LockSet δ) := by
  obtain ⟨w, hw⟩ := h
  rw [dense_iff_inter_open]
  intro U hU hne
  obtain ⟨x, hx⟩ := hne
  obtain ⟨F, u, hu, hsub⟩ := isOpen_pi_iff.mp hU x hx
  set N := (F.sup id) + 1 with hN
  refine ⟨splice x N w (x 0), hsub ?_, ⟨N + w.length, ?_⟩⟩
  · intro a ha
    have hlt : a < N := by
      have hle : a ≤ F.sup id := Finset.le_sup (f := id) (by simpa using ha)
      omega
    simp only [splice, if_pos hlt]
    exact (hu a (by simpa using ha)).2
  · rw [pre_splice]
    exact hw.append_left δ (pre x N)

omit [TopologicalSpace I] [DiscreteTopology I] in
/-- The lock set is empty exactly for non-locking agents. -/
theorem lockSet_eq_empty_iff [Nonempty I] (δ : S → I → S) :
    LockSet δ = ∅ ↔ ¬ PhaseLocking δ := by
  constructor
  · intro hempty ⟨w, hw⟩
    have : splice (fun _ => Classical.arbitrary I) 0 w (Classical.arbitrary I) ∈ LockSet δ := by
      refine ⟨0 + w.length, ?_⟩
      rw [pre_splice]
      exact hw.append_left δ _
    rw [hempty] at this
    exact this
  · intro hno
    ext x
    simp only [Set.mem_empty_iff_false, iff_false]
    rintro ⟨n, hn⟩
    exact hno ⟨pre x n, hn⟩

/-- **Topological zero–one law for doppelgänger telepathy.**  The set of stimulus streams
that synchronize the two separated agents is either empty (when the agent design forbids
locking) or open *and* dense — there is no intermediate, "thin but nonempty", regime. -/
theorem lockSet_dichotomy [Nonempty I] (δ : S → I → S) :
    (LockSet δ = ∅) ∨ (IsOpen (LockSet δ) ∧ Dense (LockSet δ)) := by
  by_cases h : PhaseLocking δ
  · exact Or.inr ⟨isOpen_lockSet δ, dense_lockSet δ h⟩
  · exact Or.inl ((lockSet_eq_empty_iff δ).mpr h)

omit [DiscreteTopology I] in
/-- For a phase-locking agent the set of *failing* stimulus streams has empty interior:
failure of telepathy is a nowhere-dense phenomenon. -/
theorem interior_compl_lockSet (δ : S → I → S) (h : PhaseLocking δ) :
    interior (LockSet δ)ᶜ = ∅ := (dense_lockSet δ h).interior_compl

end Topology

end Doppelganger