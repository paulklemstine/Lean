import Algebra.NonBacktracking.HashimotoTrace

/-!
# Reversal of non-backtracking walks and parity of the trace

Reversing a walk and flipping each of its darts is an involution on the set of rooted
closed non-backtracking walks. It has **no fixed point**: the root of the reversed walk
is the reversal of the root, and a dart is never equal to its own reversal. Consequently

`trace (B ^ n)` is even for every `n`.

For `n = 0` this recovers the classical handshake statement (the number of darts is even);
for `n ≥ 1` it says that closed non-backtracking walks come in genuinely distinct
clockwise/anticlockwise pairs.

## Main results

* `Hashimoto.even_card_of_involution` — a finset carrying a fixed-point-free involution
  has even cardinality (proved by summing the constant `1` over `ZMod 2`).
* `Hashimoto.revWalk_mem` — reversal preserves rooted closed non-backtracking walks.
* `Hashimoto.even_trace_hashimoto_pow` — `Even (trace (B ^ n))`.
-/

open Finset SimpleGraph List

namespace Hashimoto

/-! ## A parity tool -/

/-- A finset admitting a fixed-point-free involution has even cardinality. -/
theorem even_card_of_involution {α : Type*} (s : Finset α) (g : α → α)
    (hg : ∀ a ∈ s, g a ∈ s) (hinv : ∀ a ∈ s, g (g a) = a) (hne : ∀ a ∈ s, g a ≠ a) :
    Even s.card := by
  have h : ((s.card : ZMod 2)) = 0 := by
    have hsum : ((s.card : ZMod 2)) = ∑ _x ∈ s, (1 : ZMod 2) := by simp
    rw [hsum]
    refine Finset.sum_involution (fun a _ => g a) ?_ ?_ ?_ ?_
    · intro a _; decide
    · intro a ha _; exact hne a ha
    · intro a ha; exact hg a ha
    · intro a ha; exact hinv a ha
  exact even_iff_two_dvd.2 (Fin.natCast_eq_zero.mp h)

/-! ## Reversal of dart walks -/

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

/-- Reversal of a dart walk: reverse the order and flip every dart. -/
def revWalk (l : List G.Dart) : List G.Dart := (l.map SimpleGraph.Dart.symm).reverse

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
@[simp] lemma revWalk_revWalk (l : List G.Dart) : revWalk (revWalk l) = l := by
  simp [revWalk, ← List.map_reverse, List.map_map]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
@[simp] lemma length_revWalk (l : List G.Dart) : (revWalk l).length = l.length := by
  simp [revWalk]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Non-backtracking adjacency is reversed by flipping darts. -/
lemma nbAdj_symm_symm {d d' : G.Dart} : NBAdj G d'.symm d.symm ↔ NBAdj G d d' := by
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨h1.symm, fun h => h2 h.symm⟩
  · rintro ⟨h1, h2⟩
    exact ⟨h1.symm, fun h => h2 h.symm⟩

/-- Reversal preserves rooted closed non-backtracking walks. -/
theorem revWalk_mem {n : ℕ} {l : List G.Dart} (hl : l ∈ closedNBWalks G n) :
    revWalk l ∈ closedNBWalks G n := by
  rw [mem_closedNBWalks] at hl ⊢
  obtain ⟨hlen, hchain, hend⟩ := hl
  refine ⟨by simpa using hlen, ?_, ?_⟩
  · rw [revWalk, List.isChain_reverse, List.isChain_map]
    refine hchain.imp ?_
    intro a b hab
    exact nbAdj_symm_symm.2 hab
  · rw [revWalk, List.head?_reverse, List.getLast?_reverse]
    rw [List.getLast?_map, List.head?_map, hend]

/-- Reversal has no fixed point: the root of the reversed walk is the reversal of the
root, and no dart equals its own reversal. -/
theorem revWalk_ne {n : ℕ} {l : List G.Dart} (hl : l ∈ closedNBWalks G n) :
    revWalk l ≠ l := by
  rw [mem_closedNBWalks] at hl
  obtain ⟨hlen, -, hend⟩ := hl
  have hne : l ≠ [] := by intro h; rw [h] at hlen; simp at hlen
  obtain ⟨d, hd⟩ : ∃ d, l.head? = some d := by
    cases l with
    | nil => exact absurd rfl hne
    | cons a t => exact ⟨a, rfl⟩
  intro hEq
  have hhead : (revWalk l).head? = some d.symm := by
    rw [revWalk, List.head?_reverse, List.getLast?_map, ← hend, hd]
    rfl
  rw [hEq, hd] at hhead
  exact SimpleGraph.Dart.symm_ne d (by simpa using hhead.symm)

/-! ## The reversal intertwiner -/

/-- Dart reversal as an equivalence of the dart type. -/
def dartSymmEquiv (G : SimpleGraph V) : G.Dart ≃ G.Dart where
  toFun := SimpleGraph.Dart.symm
  invFun := SimpleGraph.Dart.symm
  left_inv := SimpleGraph.Dart.symm_symm
  right_inv := SimpleGraph.Dart.symm_symm

omit [Fintype V] in
/-- **Reversal conjugates `B` into its transpose.** Writing `J` for the permutation of
darts given by reversal, `J B J = Bᵀ`; this is the matrix form of the combinatorial fact
that reversing a non-backtracking walk gives a non-backtracking walk. -/
theorem hashimoto_submatrix_symm (G : SimpleGraph V) [DecidableRel G.Adj] :
    (hashimoto G).submatrix (dartSymmEquiv G) (dartSymmEquiv G) = (hashimoto G).transpose := by
  ext d d'
  simp only [Matrix.submatrix_apply, Matrix.transpose_apply, hashimoto_apply, dartSymmEquiv,
    Equiv.coe_fn_mk]
  by_cases h : NBAdj G d' d
  · rw [if_pos (nbAdj_symm_symm.2 h), if_pos h]
  · rw [if_neg (fun hc => h (nbAdj_symm_symm.1 hc)), if_neg h]

/-- **Parity of the non-backtracking trace.** For every `n`, the number of rooted closed
non-backtracking walks of length `n` — equivalently `trace (B ^ n)` — is even. -/
theorem even_trace_hashimoto_pow (G : SimpleGraph V) [DecidableRel G.Adj] (n : ℕ) :
    Even (hashimoto G ^ n).trace := by
  rw [trace_hashimoto_pow]
  exact even_card_of_involution _ revWalk (fun _ ha => revWalk_mem ha)
    (fun l _ => revWalk_revWalk l) (fun _ ha => revWalk_ne ha)

end Hashimoto