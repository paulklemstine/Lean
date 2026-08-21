/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: the explicit Turán construction ↔ the quantitative extremal bound

Mathlib knows the *structural* Turán theorem: `SimpleGraph.isTuranMaximal_turanGraph` says the
Turán graph `turanGraph n r` (vertices `Fin n`, adjacency `v % r ≠ w % r`) maximises the number
of edges among `K_{r+1}`-free graphs, and `isTuranMaximal_iff_nonempty_iso_turanGraph` says it is
the unique such maximiser.  What Mathlib does *not* record is the **number**
`(1 - 1/r) · n² / 2`.

This file supplies exactly that missing quantitative half, by counting the explicit
construction rather than by any extremal/probabilistic argument:

* `card_residue_class` : when `r ∣ n`, each residue class mod `r` inside `Fin n` has exactly
  `n / r` elements.
* `turanGraph_degree` : hence `turanGraph n r` is `(n - n/r)`-regular.
* `two_mul_card_edgeFinset_turanGraph` : `2 · #edges (turanGraph n r) = n · (n - n/r)`, via the
  handshake lemma.
* `card_edgeFinset_turanGraph_real` : `#edges (turanGraph n r) = (1 - 1/r) · n² / 2` in `ℝ`.
* `turan_bound_real` : every `K_{r+1}`-free graph on `Fin n` has at most `(1 - 1/r) · n² / 2`
  edges (`r ∣ n`), and `turan_extremal_number` states this bound is *attained*, i.e. it is the
  extremal number: an `IsGreatest` statement.

The bridge is: an existence/optimality theorem (Mathlib's `IsTuranMaximal`) is converted into a
closed-form arithmetic value by evaluating an explicit combinatorial construction.

## Catalog connections
* `Bridges/GenTuranAsymptoticBridge.lean` : generalized Turán counting; this file provides the
  classical `r`-partite case with the exact constant.
* `Bridges/ErdosProbabilisticRamsey.lean` : the other half of the probabilistic-method trio.
-/
import Mathlib

open Finset SimpleGraph

namespace TuranExplicitCount

variable {n r : ℕ}

/-! ## Residue classes in `Fin n` -/

/-- If `r ∣ n` then the residue class of `c` mod `r` inside `Fin n` has exactly `n / r`
elements. -/
lemma card_residue_class (hr : 0 < r) (hdvd : r ∣ n) {c : ℕ} (hc : c < r) :
    #((univ : Finset (Fin n)).filter (fun w : Fin n => (w : ℕ) % r = c)) = n / r := by
  have hkey : #((univ : Finset (Fin n)).filter (fun w : Fin n => (w : ℕ) % r = c)) =
      #(univ : Finset (Fin (n / r))) := by
    refine Finset.card_bij' (fun w _ => (⟨(w : ℕ) / r, ?_⟩ : Fin (n / r)))
      (fun j _ => (⟨c + (j : ℕ) * r, ?_⟩ : Fin n)) ?_ ?_ ?_ ?_
    · exact Nat.div_lt_div_of_lt_of_dvd hdvd w.2
    · -- `c + j * r < n`
      obtain ⟨m, rfl⟩ := hdvd
      have hjm : (j : ℕ) < m := by
        have h2 : (j : ℕ) < r * m / r := j.2
        have h1 : r * m / r = m := Nat.mul_div_cancel_left _ hr
        omega
      calc c + (j : ℕ) * r < r + (j : ℕ) * r := by omega
        _ = ((j : ℕ) + 1) * r := by ring
        _ ≤ m * r := Nat.mul_le_mul_right r hjm
        _ = r * m := Nat.mul_comm _ _
    · intro w _; exact mem_univ _
    · intro j _
      simp only [mem_filter, mem_univ, true_and]
      rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hc]
    · intro w hw
      simp only [mem_filter, mem_univ, true_and] at hw
      apply Fin.ext
      simp only
      have hd : (w : ℕ) / r * r + (w : ℕ) % r = (w : ℕ) := Nat.div_add_mod' _ _
      omega
    · intro j _
      apply Fin.ext
      simp only
      rw [Nat.add_mul_div_right _ _ hr, Nat.div_eq_of_lt hc]
      omega
  rw [hkey, card_univ, Fintype.card_fin]

/-! ## The Turán graph is regular, and its edge count -/

/-- When `r ∣ n`, the Turán graph `turanGraph n r` is `(n - n/r)`-regular. -/
lemma turanGraph_degree (hr : 0 < r) (hdvd : r ∣ n) (v : Fin n) :
    (turanGraph n r).degree v = n - n / r := by
  classical
  have hcompl : (turanGraph n r).neighborFinset v =
      (univ : Finset (Fin n)) \ (univ.filter (fun w : Fin n => (w : ℕ) % r = (v : ℕ) % r)) := by
    ext w
    simp only [mem_neighborFinset, turanGraph_adj, mem_sdiff, mem_univ, mem_filter, true_and]
    exact ⟨fun h hcon => h hcon.symm, fun h hcon => h hcon.symm⟩
  rw [← card_neighborFinset_eq_degree, hcompl, Finset.card_sdiff, Finset.inter_univ, card_univ,
    Fintype.card_fin, card_residue_class hr hdvd (Nat.mod_lt _ hr)]

/-- Handshake count for the Turán graph: `2 · #edges = n · (n - n/r)`. -/
theorem two_mul_card_edgeFinset_turanGraph (hr : 0 < r) (hdvd : r ∣ n) :
    2 * #(turanGraph n r).edgeFinset = n * (n - n / r) := by
  classical
  have h := (turanGraph n r).sum_degrees_eq_twice_card_edges
  rw [← h]
  rw [Finset.sum_congr rfl (fun v _ => turanGraph_degree hr hdvd v)]
  simp [Finset.sum_const, card_univ, Fintype.card_fin]

/-- The exact edge count of the Turán graph as a real number: `(1 - 1/r) · n² / 2`. -/
theorem card_edgeFinset_turanGraph_real (hr : 0 < r) (hdvd : r ∣ n) :
    (#(turanGraph n r).edgeFinset : ℝ) = (1 - 1 / r) * n ^ 2 / 2 := by
  have hnat := two_mul_card_edgeFinset_turanGraph hr hdvd
  have hle : n / r ≤ n := Nat.div_le_self _ _
  have hcast : (2 : ℝ) * (#(turanGraph n r).edgeFinset : ℝ) = (n : ℝ) * ((n : ℝ) - (n / r : ℕ)) := by
    have := congrArg (fun m : ℕ => (m : ℝ)) hnat
    push_cast [Nat.cast_sub hle] at this
    exact this
  have hrne : (r : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hr.ne'
  rw [Nat.cast_div hdvd hrne] at hcast
  field_simp at hcast ⊢
  nlinarith [hcast]

/-! ## The general (non-divisible) edge count of the Turán graph -/

/-- The number of vertices of `Fin n` in the residue class `i` mod `r`. -/
def classSize (n r i : ℕ) : ℕ :=
  #((univ : Finset (Fin n)).filter (fun w : Fin n => (w : ℕ) % r = i))

/-- Every vertex of the Turán graph is adjacent to all vertices outside its own residue class:
`degree v + (size of the class of v) = n`.  No divisibility is assumed. -/
lemma degree_add_classSize (v : Fin n) :
    (turanGraph n r).degree v + classSize n r ((v : ℕ) % r) = n := by
  classical
  have hcompl : (turanGraph n r).neighborFinset v =
      (univ : Finset (Fin n)) \ (univ.filter (fun w : Fin n => (w : ℕ) % r = (v : ℕ) % r)) := by
    ext w
    simp only [mem_neighborFinset, turanGraph_adj, mem_sdiff, mem_univ, mem_filter, true_and]
    exact ⟨fun h hcon => h hcon.symm, fun h hcon => h hcon.symm⟩
  have hle : classSize n r ((v : ℕ) % r) ≤ n := by
    have := card_le_card (subset_univ
      ((univ : Finset (Fin n)).filter (fun w : Fin n => (w : ℕ) % r = (v : ℕ) % r)))
    simpa [classSize, card_univ] using this
  have hdeg : (turanGraph n r).degree v = n - classSize n r ((v : ℕ) % r) := by
    rw [← card_neighborFinset_eq_degree, hcompl, Finset.card_sdiff, Finset.inter_univ, card_univ,
      Fintype.card_fin]
    rfl
  omega

/-- Grouping the vertices by residue class turns `∑_v |class of v|` into `∑_i |class i|²`. -/
lemma sum_classSize_sq (hr : 0 < r) :
    ∑ v : Fin n, classSize n r ((v : ℕ) % r) = ∑ i ∈ range r, (classSize n r i) ^ 2 := by
  classical
  have hmaps : ∀ v ∈ (univ : Finset (Fin n)), (v : ℕ) % r ∈ range r :=
    fun v _ => mem_range.2 (Nat.mod_lt _ hr)
  rw [← Finset.sum_fiberwise_of_maps_to hmaps (fun v : Fin n => classSize n r ((v : ℕ) % r))]
  refine Finset.sum_congr rfl ?_
  intro i _
  have hconst : ∑ v ∈ (univ : Finset (Fin n)).filter (fun v : Fin n => (v : ℕ) % r = i),
      classSize n r ((v : ℕ) % r)
      = ∑ _v ∈ (univ : Finset (Fin n)).filter (fun v : Fin n => (v : ℕ) % r = i),
        classSize n r i := by
    refine Finset.sum_congr rfl ?_
    intro v hv
    rw [(mem_filter.1 hv).2]
  rw [hconst, sum_const, smul_eq_mul]
  simp [classSize, sq]

/-- **The edge count of the Turán graph, in general.**  `2 · #edges + ∑_i |class i|² = n²`, with no
divisibility hypothesis; when `r ∣ n` all classes have size `n/r` and this specializes to
`two_mul_card_edgeFinset_turanGraph`. -/
theorem two_mul_card_edgeFinset_turanGraph_general (hr : 0 < r) :
    2 * #(turanGraph n r).edgeFinset + ∑ i ∈ range r, (classSize n r i) ^ 2 = n ^ 2 := by
  classical
  have hsum : ∑ v : Fin n, ((turanGraph n r).degree v + classSize n r ((v : ℕ) % r))
      = ∑ _v : Fin n, n := Finset.sum_congr rfl (fun v _ => degree_add_classSize v)
  rw [Finset.sum_add_distrib, (turanGraph n r).sum_degrees_eq_twice_card_edges,
    sum_classSize_sq hr] at hsum
  simpa [sum_const, card_univ, Fintype.card_fin, sq] using hsum

/-! ## Turán's theorem, quantitatively -/

/-- **Turán's theorem (quantitative form).**  If `r ∣ n`, every `K_{r+1}`-free graph on `n`
vertices has at most `(1 - 1/r) · n² / 2` edges. -/
theorem turan_bound_real (hr : 0 < r) (hdvd : r ∣ n) (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] (hG : G.CliqueFree (r + 1)) :
    (#G.edgeFinset : ℝ) ≤ (1 - 1 / r) * n ^ 2 / 2 := by
  have hmax := (isTuranMaximal_turanGraph (n := n) hr).2 hG
  have := card_edgeFinset_turanGraph_real (n := n) hr hdvd
  calc (#G.edgeFinset : ℝ) ≤ (#(turanGraph n r).edgeFinset : ℝ) := by exact_mod_cast hmax
    _ = (1 - 1 / r) * n ^ 2 / 2 := this

/-- **The extremal number is attained.**  For `r ∣ n`, `n·(n - n/r)/2` is the greatest edge count
of a `K_{r+1}`-free graph on `Fin n`, and the Turán graph attains it. -/
theorem turan_extremal_number (hr : 0 < r) (hdvd : r ∣ n) :
    IsGreatest {m : ℕ | ∃ (G : SimpleGraph (Fin n)) (_ : DecidableRel G.Adj),
      G.CliqueFree (r + 1) ∧ #G.edgeFinset = m} (n * (n - n / r) / 2) := by
  classical
  have hcount := two_mul_card_edgeFinset_turanGraph (n := n) hr hdvd
  have hval : #(turanGraph n r).edgeFinset = n * (n - n / r) / 2 := by omega
  constructor
  · exact ⟨turanGraph n r, inferInstance, turanGraph_cliqueFree hr, hval⟩
  · rintro m ⟨G, hGdec, hGfree, rfl⟩
    have hmax := (isTuranMaximal_turanGraph (n := n) hr).2 hGfree
    omega

end TuranExplicitCount