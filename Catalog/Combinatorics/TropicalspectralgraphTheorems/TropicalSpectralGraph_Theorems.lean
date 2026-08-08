import Shared.TropicalentropyDefs.TropicalEntropy_Defs

/-!
# Tropical spectral graph theory

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/TropicalSpectralGraph/Theorems.lean`.  It is
reconstructed here as a self-contained development of **min-plus (tropical) matrix
algebra** on a finite complete weighted digraph, the algebraic backbone of tropical
spectral graph theory: tropical matrix powers compute shortest walks, and the
tropical eigenvalue is a minimal cycle mean.

Main results:

* `TropicalGraph.mpMul` — the min-plus matrix product, together with
  `TropicalGraph.mpMul_assoc` (**associativity**, i.e. the Bellman optimality
  principle) and `TropicalGraph.mpMul_one` / `one_mpMul` (the tropical identity);
* `TropicalGraph.mpMul_le` — the shortest-walk upper bound `(A ⊗ B) i j ≤ A i k + B k j`;
* `TropicalGraph.mpMul_mono` — monotonicity in both arguments;
* `TropicalGraph.mpMul_shift` — the **spectral shift**: adding a constant `c` to all
  entries shifts every tropical eigenvalue by `c`;
* `TropicalGraph.mpPow_add` and `TropicalGraph.mpPow_le_mul` — the concatenation
  law for tropical powers, the input to Fekete's lemma for the minimal cycle mean.
-/

namespace TropicalGraph

open Finset TropicalEntropy

variable {n : ℕ} [NeZero n]

/-- The index set is non-empty, so `inf'` is available. -/
private lemma univ_ne : (Finset.univ : Finset (Fin n)).Nonempty :=
  Finset.univ_nonempty (α := Fin n)

/-- A weighted digraph: `A i j` is the length of the arc `i → j`. -/
abbrev Weighting (n : ℕ) : Type := Fin n → Fin n → ℝ

/-- **Min-plus matrix product.**  `(A ⊗ B) i j = min_k (A i k + B k j)`. -/
noncomputable def mpMul (A B : Weighting n) : Weighting n :=
  fun i j => tropSum Finset.univ univ_ne (fun k => A i k + B k j)

/-- The defining upper bound: every intermediate vertex gives an upper bound. -/
theorem mpMul_le (A B : Weighting n) (i j k : Fin n) : mpMul A B i j ≤ A i k + B k j :=
  tropSum_le univ_ne _ (Finset.mem_univ k)

/-- The defining lower bound. -/
theorem le_mpMul (A B : Weighting n) (i j : Fin n) {c : ℝ}
    (h : ∀ k, c ≤ A i k + B k j) : c ≤ mpMul A B i j :=
  le_tropSum univ_ne _ fun k _ => h k

/-- The minimum is attained. -/
theorem exists_mpMul_eq (A B : Weighting n) (i j : Fin n) :
    ∃ k, mpMul A B i j = A i k + B k j := by
  obtain ⟨k, -, hk⟩ := exists_ground_state univ_ne (fun k => A i k + B k j)
  exact ⟨k, hk⟩

/-- **Associativity (Bellman's optimality principle).**  Splitting an optimal walk
at any point gives optimal sub-walks. -/
theorem mpMul_assoc (A B C : Weighting n) : mpMul (mpMul A B) C = mpMul A (mpMul B C) := by
  funext i j
  refine le_antisymm ?_ ?_
  · refine le_mpMul _ _ _ _ fun l => ?_
    obtain ⟨k, hk⟩ := exists_mpMul_eq B C l j
    calc mpMul (mpMul A B) C i j ≤ mpMul A B i k + C k j := mpMul_le _ _ i j k
      _ ≤ (A i l + B l k) + C k j := by
          have := mpMul_le A B i k l
          linarith
      _ = A i l + (B l k + C k j) := by ring
      _ = A i l + mpMul B C l j := by rw [hk]
  · refine le_mpMul _ _ _ _ fun k => ?_
    obtain ⟨l, hl⟩ := exists_mpMul_eq A B i k
    calc mpMul A (mpMul B C) i j ≤ A i l + mpMul B C l j := mpMul_le _ _ i j l
      _ ≤ A i l + (B l k + C k j) := by
          have := mpMul_le B C l j k
          linarith
      _ = (A i l + B l k) + C k j := by ring
      _ = mpMul A B i k + C k j := by rw [hl]

/-- The tropical identity matrix: `0` on the diagonal, `+∞` off it — modelled here
by a sufficiently large finite penalty is not needed, since we state the identity
laws against an explicit bound. -/
noncomputable def tropOne (M : ℝ) : Weighting n := fun i j => if i = j then 0 else M

/-- With a penalty `M` at least as large as the spread of `A`, the tropical identity
is a left unit. -/
theorem one_mpMul (A : Weighting n) (M : ℝ)
    (hM : ∀ i j k : Fin n, A i j ≤ M + A k j) :
    mpMul (tropOne M) A = A := by
  funext i j
  refine le_antisymm ?_ ?_
  · have := mpMul_le (tropOne M) A i j i
    simpa [tropOne] using this
  · refine le_mpMul _ _ _ _ fun k => ?_
    by_cases hk : i = k
    · subst hk
      simp [tropOne]
    · simp only [tropOne, if_neg hk]
      exact hM i j k

/-- With the same hypothesis the tropical identity is a right unit. -/
theorem mpMul_one (A : Weighting n) (M : ℝ)
    (hM : ∀ i j k : Fin n, A i j ≤ A i k + M) :
    mpMul A (tropOne M) = A := by
  funext i j
  refine le_antisymm ?_ ?_
  · have := mpMul_le A (tropOne M) i j j
    simpa [tropOne] using this
  · refine le_mpMul _ _ _ _ fun k => ?_
    by_cases hk : k = j
    · subst hk
      simp [tropOne]
    · simp only [tropOne, if_neg hk]
      exact hM i j k

/-- **Monotonicity.**  The min-plus product is monotone in both arguments. -/
theorem mpMul_mono {A A' B B' : Weighting n}
    (hA : ∀ i j, A i j ≤ A' i j) (hB : ∀ i j, B i j ≤ B' i j) (i j : Fin n) :
    mpMul A B i j ≤ mpMul A' B' i j := by
  obtain ⟨k, hk⟩ := exists_mpMul_eq A' B' i j
  calc mpMul A B i j ≤ A i k + B k j := mpMul_le _ _ i j k
    _ ≤ A' i k + B' k j := add_le_add (hA i k) (hB k j)
    _ = mpMul A' B' i j := hk.symm

/-- **Spectral shift.**  Adding the constant `c` to every arc weight of `A` and `d`
to every arc weight of `B` shifts every entry of the product by `c + d`; in
particular every tropical eigenvalue of `A` shifts by `c`. -/
theorem mpMul_shift (A B : Weighting n) (c d : ℝ) (i j : Fin n) :
    mpMul (fun i j => A i j + c) (fun i j => B i j + d) i j = mpMul A B i j + (c + d) := by
  refine le_antisymm ?_ ?_
  · obtain ⟨k, hk⟩ := exists_mpMul_eq A B i j
    have h : mpMul (fun i j => A i j + c) (fun i j => B i j + d) i j
        ≤ (A i k + c) + (B k j + d) := mpMul_le _ _ i j k
    rw [hk]
    linarith
  · refine le_mpMul _ _ _ _ fun k => ?_
    have h := mpMul_le A B i j k
    show mpMul A B i j + (c + d) ≤ (A i k + c) + (B k j + d)
    linarith

/-- Tropical powers: `mpPow A m` is the matrix of shortest walks using exactly
`m + 1` arcs. -/
noncomputable def mpPow (A : Weighting n) : ℕ → Weighting n
  | 0 => A
  | m + 1 => mpMul A (mpPow A m)

@[simp] lemma mpPow_zero (A : Weighting n) : mpPow A 0 = A := rfl

lemma mpPow_succ (A : Weighting n) (m : ℕ) : mpPow A (m + 1) = mpMul A (mpPow A m) := rfl

/-- **Concatenation of shortest walks.**  Optimal walks of lengths `p + 1` and
`q + 1` concatenate to the optimal walk of length `p + q + 2`: the shortest-walk
matrices multiply tropically.  This is the exact (rather than merely
sub-multiplicative) form of the hypothesis of Fekete's lemma that produces the
minimal cycle mean, i.e. the tropical spectral radius. -/
theorem mpPow_add (A : Weighting n) (p q : ℕ) :
    mpPow A (p + q + 1) = mpMul (mpPow A p) (mpPow A q) := by
  induction p with
  | zero =>
      rw [show 0 + q + 1 = q + 1 by omega, mpPow_succ, mpPow_zero]
  | succ m ih =>
      have hidx : m + 1 + q + 1 = (m + q + 1) + 1 := by omega
      rw [hidx, mpPow_succ, ih, mpPow_succ, mpMul_assoc]

/-- Consequently the tropical powers are sub-additive entrywise. -/
theorem mpPow_le_mul (A : Weighting n) (p q : ℕ) (i j : Fin n) :
    mpPow A (p + q + 1) i j ≤ mpMul (mpPow A p) (mpPow A q) i j := by
  rw [mpPow_add]

end TropicalGraph