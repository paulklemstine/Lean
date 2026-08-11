import Novelty.StrangeAttractorPeriodic

/-!
# Strange attractors as algebraic objects, III: the transfer matrix and the zeta function

This file makes the algebra of the attractor explicit.  For a finite directed graph with
edge relation `E` we introduce the adjacency (transfer) matrix over `ℕ` and prove the
fundamental counting theorem

* `adjMatrix_pow_apply` : `(A ^ n) i j` is the number of paths with `n` edges from `i` to `j`;
* `card_finPath_eq_sum` : the `n`-th finite approximant of the inverse limit has
  `∑ i j, (A ^ n) i j` elements;
* `card_closedWalk_eq_trace` : `trace (A ^ n)` counts the closed walks of length `n`, hence
  (via `Novelty.StrangeAttractorPeriodic`) the `n`-periodic points of the attractor;
* `trace_pow_eq_of_conjugate` : the sequence `n ↦ trace (A ^ n)` — the coefficient sequence
  of the Artin–Mazur zeta function — is a topological conjugacy invariant.

Thus the strange attractor, presented as an inverse limit of finite graphs, has a genuine
*matrix* attached to it, and its dynamical invariants are spectral data of that matrix.
-/

namespace LorenzLimit

variable {V : Type*} [Fintype V] [DecidableEq V] {E : V → V → Bool}

/-! ## Walks with prescribed endpoints -/

/-- Paths with `n` edges from `i` to `j`. -/
def WalkBetween (E : V → V → Bool) (n : ℕ) (i j : V) : Type _ :=
  {w : Fin (n + 1) → V //
    (∀ k : Fin n, E (w k.castSucc) (w k.succ) = true) ∧ w 0 = i ∧ w (Fin.last n) = j}

instance instFintypeWalkBetween (E : V → V → Bool) (n : ℕ) (i j : V) :
    Fintype (WalkBetween E n i j) := by
  unfold WalkBetween; infer_instance

/-- Removing the last edge identifies the walks from `i` to `j` of length `n + 1` whose
second-to-last vertex is `k` with the walks from `i` to `k` of length `n`. -/
def fiberEquiv (n : ℕ) (i j k : V) (hk : E k j = true) :
    {w : WalkBetween E (n + 1) i j // w.1 (Fin.castSucc (Fin.last n)) = k} ≃
      WalkBetween E n i k where
  toFun w := by
    refine ⟨Fin.init w.1.1, ?_, w.1.2.2.1, w.2⟩
    intro t
    have h := w.1.2.1 t.castSucc
    rw [Fin.succ_castSucc] at h
    exact h
  invFun v := by
    refine ⟨⟨Fin.snoc v.1 j, ?_, ?_, ?_⟩, ?_⟩
    · intro t
      rcases Fin.eq_castSucc_or_eq_last t with ⟨s, rfl⟩ | rfl
      · have h1 : (Fin.snoc v.1 j : Fin (n + 2) → V) (Fin.castSucc s).castSucc = v.1 s.castSucc :=
          Fin.snoc_castSucc (α := fun _ => V) j v.1 s.castSucc
        have h2 : (Fin.snoc v.1 j : Fin (n + 2) → V) (Fin.castSucc s).succ = v.1 s.succ := by
          rw [Fin.succ_castSucc]
          exact Fin.snoc_castSucc (α := fun _ => V) j v.1 s.succ
        rw [h1, h2]
        exact v.2.1 s
      · have h1 : (Fin.snoc v.1 j : Fin (n + 2) → V) (Fin.castSucc (Fin.last n))
            = v.1 (Fin.last n) := Fin.snoc_castSucc (α := fun _ => V) j v.1 (Fin.last n)
        have h2 : (Fin.snoc v.1 j : Fin (n + 2) → V) (Fin.last n).succ = j := by
          rw [Fin.succ_last]; exact Fin.snoc_last (α := fun _ => V) j v.1
        rw [h1, h2, v.2.2.2]
        exact hk
    · show (Fin.snoc v.1 j : Fin (n + 2) → V) (0 : Fin (n + 1)).castSucc = i
      rw [Fin.snoc_castSucc (α := fun _ => V) j v.1 0]
      exact v.2.2.1
    · exact Fin.snoc_last (α := fun _ => V) j v.1
    · show (Fin.snoc v.1 j : Fin (n + 2) → V) (Fin.castSucc (Fin.last n)) = k
      rw [Fin.snoc_castSucc (α := fun _ => V) j v.1 (Fin.last n)]
      exact v.2.2.2
  left_inv w := by
    apply Subtype.ext
    apply Subtype.ext
    show Fin.snoc (Fin.init w.1.1) j = w.1.1
    have hj : w.1.1 (Fin.last (n + 1)) = j := w.1.2.2.2
    conv_rhs => rw [← Fin.snoc_init_self w.1.1]
    rw [hj]
  right_inv v := by
    apply Subtype.ext
    exact Fin.init_snoc (α := fun _ => V) j v.1

theorem card_walkBetween_zero (i j : V) :
    Fintype.card (WalkBetween E 0 i j) = if i = j then 1 else 0 := by
  by_cases h : i = j
  · rw [if_pos h]
    apply Fintype.card_eq_one_iff.2
    refine ⟨⟨fun _ => i, fun t => absurd t.isLt (by omega), rfl, h⟩, ?_⟩
    intro y
    apply Subtype.ext
    funext t
    have h0 : t = 0 := Fin.ext (by omega)
    rw [h0]
    exact y.2.2.1
  · rw [if_neg h]
    apply Fintype.card_eq_zero_iff.2
    constructor
    intro y
    exact h (y.2.2.1.symm.trans y.2.2.2)

theorem card_walkBetween_succ (n : ℕ) (i j : V) :
    Fintype.card (WalkBetween E (n + 1) i j)
      = ∑ k : V, (if E k j = true then Fintype.card (WalkBetween E n i k) else 0) := by
  have h := Fintype.card_congr
    (Equiv.sigmaFiberEquiv
      (fun w : WalkBetween E (n + 1) i j => w.1 (Fin.castSucc (Fin.last n)))).symm
  rw [h, Fintype.card_sigma]
  refine Finset.sum_congr rfl ?_
  intro k _
  by_cases hk : E k j = true
  · rw [if_pos hk]
    exact Fintype.card_congr (fiberEquiv n i j k hk)
  · rw [if_neg hk]
    apply Fintype.card_eq_zero_iff.2
    constructor
    intro w
    apply hk
    have h1 := w.1.2.1 (Fin.last n)
    rw [Fin.succ_last, w.1.2.2.2, w.2] at h1
    exact h1

/-! ## The transfer matrix -/

/-- The adjacency (transfer) matrix of the finite directed graph, over `ℕ`. -/
def adjMatrix (E : V → V → Bool) : Matrix V V ℕ :=
  Matrix.of fun i j => if E i j = true then 1 else 0

/-- **Transfer-matrix theorem.**  The `(i, j)` entry of the `n`-th power of the adjacency
matrix counts the paths with `n` edges from `i` to `j`. -/
theorem adjMatrix_pow_apply (n : ℕ) (i j : V) :
    (adjMatrix E ^ n) i j = Fintype.card (WalkBetween E n i j) := by
  induction n generalizing j with
  | zero =>
      rw [pow_zero, Matrix.one_apply, card_walkBetween_zero]
  | succ n ih =>
      rw [pow_succ, Matrix.mul_apply, card_walkBetween_succ]
      refine Finset.sum_congr rfl ?_
      intro k _
      rw [ih k]
      by_cases hk : E k j = true <;> simp [adjMatrix, hk]

/-! ## Total path counts and the trace -/

/-- Recording the endpoints of a path splits the `n`-th approximant into walk sets. -/
def finPathFiberEquiv (n : ℕ) (i j : V) :
    {w : FinPath E n // (w.1 0, w.1 (Fin.last n)) = (i, j)} ≃ WalkBetween E n i j where
  toFun w := ⟨w.1.1, w.1.2, by
    have := congrArg Prod.fst w.2
    simpa using this, by
    have := congrArg Prod.snd w.2
    simpa using this⟩
  invFun v := ⟨⟨v.1, v.2.1⟩, by
    rw [Prod.ext_iff]
    exact ⟨v.2.2.1, v.2.2.2⟩⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- The `n`-th finite approximant of the inverse limit has `∑ i j, (A ^ n) i j` elements. -/
theorem card_finPath_eq_sum (n : ℕ) :
    Fintype.card (FinPath E n) = ∑ i : V, ∑ j : V, (adjMatrix E ^ n) i j := by
  have h := Fintype.card_congr
    (Equiv.sigmaFiberEquiv
      (fun w : FinPath E n => (w.1 0, w.1 (Fin.last n)))).symm
  rw [h, Fintype.card_sigma, Fintype.sum_prod_type]
  refine Finset.sum_congr rfl ?_
  intro i _
  refine Finset.sum_congr rfl ?_
  intro j _
  rw [adjMatrix_pow_apply]
  exact Fintype.card_congr (finPathFiberEquiv n i j)

/-- Closed walks split according to their base point. -/
def closedWalkFiberEquiv (n : ℕ) (i : V) :
    {w : ClosedWalk E n // w.1.1 0 = i} ≃ WalkBetween E n i i where
  toFun w := ⟨w.1.1.1, w.1.1.2, w.2, w.1.2 ▸ w.2⟩
  invFun v := ⟨⟨⟨v.1, v.2.1⟩, v.2.2.1.trans v.2.2.2.symm⟩, v.2.2.1⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- **The trace formula.**  The number of closed walks of length `n` is the trace of the
`n`-th power of the transfer matrix.  Combined with `card_periodic_eq_card_closedWalk`, the
trace counts the `n`-periodic points of the attractor. -/
theorem card_closedWalk_eq_trace (n : ℕ) :
    Fintype.card (ClosedWalk E n) = Matrix.trace (adjMatrix E ^ n) := by
  have h := Fintype.card_congr
    (Equiv.sigmaFiberEquiv (fun w : ClosedWalk E n => w.1.1 0)).symm
  rw [h, Fintype.card_sigma, Matrix.trace]
  refine Finset.sum_congr rfl ?_
  intro i _
  rw [Matrix.diag_apply, adjMatrix_pow_apply]
  exact Fintype.card_congr (closedWalkFiberEquiv n i)

/-- **Zeta-function rigidity.**  Conjugate symbolic attractors have transfer matrices with
identical power traces; i.e. the Artin–Mazur zeta function is a conjugacy invariant. -/
theorem trace_pow_eq_of_conjugate {W : Type*} [Fintype W] [DecidableEq W] {F : W → W → Bool}
    (h : IsConjugate E F) {n : ℕ} (hn : 0 < n) :
    Matrix.trace (adjMatrix E ^ n) = Matrix.trace (adjMatrix F ^ n) := by
  rw [← card_closedWalk_eq_trace, ← card_closedWalk_eq_trace]
  exact card_closedWalk_eq_of_conjugate h hn

end LorenzLimit