import Novelty.StrangeAttractorInverseLimit

/-!
# Strange attractors as algebraic objects, II: periodic orbits are closed walks

The inverse-limit description of a symbolic attractor (see
`Novelty.StrangeAttractorInverseLimit`) turns dynamical questions into finite combinatorics.
Here we prove the basic dictionary entry:

> for `n ≥ 1`, the points of the orbit space fixed by the `n`-th power of the shift are in
> canonical bijection with the closed walks of length `n` in the finite directed graph.

`periodicEquivClosedWalk` is that bijection, and `card_periodic_eq_of_conjugate` shows the
resulting counts are invariants of topological conjugacy.  Together these make the
periodic-orbit counting function a genuine algebraic invariant of the attractor.
-/

namespace LorenzLimit

variable {V : Type*} {E : V → V → Bool}

/-- Being fixed by the `n`-th iterate of the shift is literal `n`-periodicity. -/
theorem periodic_iff (x : PathSpace E) (n : ℕ) :
    shift^[n] x = x ↔ ∀ k, x.1 (k + n) = x.1 k := by
  constructor
  · intro h k
    have := congrArg (fun y : PathSpace E => y.1 k) h
    simpa [shift_iterate_apply] using this
  · intro h
    apply PathSpace.ext
    intro k
    rw [shift_iterate_apply]
    exact h k

/-- A periodic orbit is determined by one period: values repeat with period `n`. -/
theorem periodic_add_mul (x : PathSpace E) (n : ℕ) (h : ∀ k, x.1 (k + n) = x.1 k) :
    ∀ m k, x.1 (k + n * m) = x.1 k := by
  intro m
  induction m with
  | zero => intro k; simp
  | succ m ih =>
      intro k
      have : k + n * (m + 1) = (k + n * m) + n := by ring
      rw [this, h (k + n * m), ih k]

theorem periodic_mod (x : PathSpace E) {n : ℕ} (h : ∀ k, x.1 (k + n) = x.1 k)
    (k : ℕ) : x.1 k = x.1 (k % n) := by
  conv_lhs => rw [← Nat.mod_add_div k n]
  exact periodic_add_mul x n h (k / n) (k % n)

variable (E)

/-- The closed walk traced out by one period of a periodic orbit. -/
def periodicToClosedWalk {n : ℕ} (x : PeriodicPoints E n) : ClosedWalk E n := by
  refine ⟨⟨fun i => x.1.1 i.val, fun i => x.1.2 i.val⟩, ?_⟩
  have h := (periodic_iff x.1 n).1 x.2 0
  simpa using h.symm

/-- The periodic orbit obtained by repeating a closed walk. -/
def closedWalkToPeriodic {n : ℕ} (hn : 0 < n) (w : ClosedWalk E n) : PeriodicPoints E n := by
  have key : ∀ k : ℕ, (k + 1) % n = (k % n + 1) % n := by
    intro k
    conv_lhs => rw [← Nat.mod_add_div k n]
    rw [show k % n + n * (k / n) + 1 = (k % n + 1) + n * (k / n) by ring,
      Nat.add_mul_mod_self_left]
  refine ⟨⟨fun k => w.1.1 ⟨k % n, Nat.lt_succ_of_lt (Nat.mod_lt _ hn)⟩, ?_⟩, ?_⟩
  · intro k
    show E (w.1.1 ⟨k % n, Nat.lt_succ_of_lt (Nat.mod_lt _ hn)⟩)
        (w.1.1 ⟨(k + 1) % n, Nat.lt_succ_of_lt (Nat.mod_lt _ hn)⟩) = true
    rcases lt_or_ge (k % n + 1) n with hlt | hge
    · have hmod : (k + 1) % n = k % n + 1 := by
        rw [key k, Nat.mod_eq_of_lt hlt]
      have hstep := w.1.2 ⟨k % n, by omega⟩
      have e1 : (⟨k % n, by omega⟩ : Fin n).castSucc = (⟨k % n, by omega⟩ : Fin (n + 1)) := rfl
      have e2 : (⟨k % n, by omega⟩ : Fin n).succ = (⟨k % n + 1, by omega⟩ : Fin (n + 1)) := rfl
      rw [e1, e2] at hstep
      have : (⟨(k + 1) % n, Nat.lt_succ_of_lt (Nat.mod_lt _ hn)⟩ : Fin (n + 1))
          = ⟨k % n + 1, by omega⟩ := by
        apply Fin.ext; simpa using hmod
      rw [this]
      exact hstep
    · -- the walk closes up
      have hkn : k % n + 1 = n := by
        have := Nat.mod_lt k hn
        omega
      have hmod : (k + 1) % n = 0 := by
        rw [key k, hkn, Nat.mod_self]
      have hstep := w.1.2 ⟨k % n, by omega⟩
      have e1 : (⟨k % n, by omega⟩ : Fin n).castSucc = (⟨k % n, by omega⟩ : Fin (n + 1)) := rfl
      have e2 : (⟨k % n, by omega⟩ : Fin n).succ = Fin.last n := by
        apply Fin.ext; simpa using hkn
      rw [e1, e2] at hstep
      have h0 : (⟨(k + 1) % n, Nat.lt_succ_of_lt (Nat.mod_lt _ hn)⟩ : Fin (n + 1))
          = (0 : Fin (n + 1)) := by
        apply Fin.ext; simp [hmod]
      rw [h0, w.2]
      exact hstep
  · apply (periodic_iff _ n).2
    intro k
    simp [Nat.add_mod_right]

variable {E}

theorem closedWalk_left_inv {n : ℕ} (hn : 0 < n) (x : PeriodicPoints E n) :
    closedWalkToPeriodic E hn (periodicToClosedWalk E x) = x := by
  apply Subtype.ext
  apply PathSpace.ext
  intro k
  have hper := (periodic_iff x.1 n).1 x.2
  exact (periodic_mod x.1 hper k).symm

theorem closedWalk_right_inv {n : ℕ} (hn : 0 < n) (w : ClosedWalk E n) :
    periodicToClosedWalk E (closedWalkToPeriodic E hn w) = w := by
  apply Subtype.ext
  apply FinPath.ext
  intro i
  show w.1.1 ⟨i.val % n, _⟩ = w.1.1 i
  rcases lt_or_ge i.val n with hlt | hge
  · have hi : (⟨i.val % n, Nat.lt_succ_of_lt (Nat.mod_lt _ hn)⟩ : Fin (n + 1)) = i :=
      Fin.ext (by simpa using Nat.mod_eq_of_lt hlt)
    rw [hi]
  · have hi : i.val = n := le_antisymm (by omega) hge
    have h0 : (⟨i.val % n, Nat.lt_succ_of_lt (Nat.mod_lt _ hn)⟩ : Fin (n + 1)) = 0 := by
      apply Fin.ext; simp [hi, Nat.mod_self]
    have hlast : i = Fin.last n := Fin.ext hi
    rw [h0, hlast]
    exact w.2

/-- **Periodic orbits are closed walks.**  For `n ≥ 1` the fixed points of the `n`-th power
of the shift on the orbit space are in canonical bijection with the closed walks of length
`n` in the graph. -/
def periodicEquivClosedWalk {n : ℕ} (hn : 0 < n) : PeriodicPoints E n ≃ ClosedWalk E n where
  toFun := periodicToClosedWalk E
  invFun := closedWalkToPeriodic E hn
  left_inv := closedWalk_left_inv hn
  right_inv := closedWalk_right_inv hn

/-- The `n`-periodic points form a finite set (`n ≥ 1`). -/
def fintypePeriodicPoints [Fintype V] [DecidableEq V] {n : ℕ} (hn : 0 < n) :
    Fintype (PeriodicPoints E n) :=
  Fintype.ofEquiv (ClosedWalk E n) (periodicEquivClosedWalk hn).symm

/-- The number of `n`-periodic orbit points is finite and equals the number of closed walks
of length `n`. -/
theorem card_periodic_eq_card_closedWalk [Fintype V] [DecidableEq V] {n : ℕ} (hn : 0 < n) :
    @Fintype.card (PeriodicPoints E n) (fintypePeriodicPoints hn)
      = Fintype.card (ClosedWalk E n) := by
  letI := fintypePeriodicPoints (E := E) hn
  exact Fintype.card_congr (periodicEquivClosedWalk hn)

/-! ## Conjugacy invariance -/

/-- A conjugacy intertwines all iterates of the shift. -/
theorem conjugate_iterate {W : Type*} {F : W → W → Bool} (φ : PathSpace E ≃ PathSpace F)
    (hφ : ∀ x, φ (shift x) = shift (φ x)) (n : ℕ) (x : PathSpace E) :
    φ (shift^[n] x) = shift^[n] (φ x) := by
  induction n generalizing x with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply, ih (shift x), hφ x, ← Function.iterate_succ_apply]

/-- **Periodic-orbit counts are conjugacy invariants.**  A shift-commuting bijection of two
symbolic orbit spaces restricts to a bijection of `n`-periodic points for every `n`. -/
def periodicEquivOfConjugate {W : Type*} {F : W → W → Bool} (φ : PathSpace E ≃ PathSpace F)
    (hφ : ∀ x, φ (shift x) = shift (φ x)) (n : ℕ) :
    PeriodicPoints E n ≃ PeriodicPoints F n where
  toFun x := ⟨φ x.1, by rw [← conjugate_iterate φ hφ n x.1, x.2]⟩
  invFun y := ⟨φ.symm y.1, by
    have h := conjugate_iterate φ hφ n (φ.symm y.1)
    rw [Equiv.apply_symm_apply] at h
    have : φ (shift^[n] (φ.symm y.1)) = φ (φ.symm y.1) := by rw [h, y.2, Equiv.apply_symm_apply]
    exact φ.injective this⟩
  left_inv x := by apply Subtype.ext; simp
  right_inv y := by apply Subtype.ext; simp

/-- Conjugate symbolic systems have the same number of closed walks of every positive
length: the periodic-orbit counting sequence is an algebraic invariant of the attractor. -/
theorem card_closedWalk_eq_of_conjugate {W : Type*} [Fintype V] [DecidableEq V] [Fintype W]
    [DecidableEq W] {F : W → W → Bool} (h : IsConjugate E F) {n : ℕ} (hn : 0 < n) :
    Fintype.card (ClosedWalk E n) = Fintype.card (ClosedWalk F n) := by
  obtain ⟨φ, hφ⟩ := h
  exact Fintype.card_congr
    ((periodicEquivClosedWalk hn).symm.trans
      ((periodicEquivOfConjugate φ hφ n).trans (periodicEquivClosedWalk hn)))

end LorenzLimit