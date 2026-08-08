/-
# Explicit divisor classes on complete graphs

Instantiating the Baker–Norine theory on `K_n`.
-/
import Combinatorics.TropicalRiemannRoch.Clifford

namespace TropicalRR

open Finset

section CompleteGraph

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]

omit [Fintype V] in
/-- The complete graph is connected. -/
lemma top_connected : (⊤ : SimpleGraph V).Connected := by
  rw [SimpleGraph.connected_iff]
  refine ⟨fun u v => ?_, ‹Nonempty V›⟩
  by_cases h : u = v
  · exact h ▸ SimpleGraph.Reachable.refl u
  · exact SimpleGraph.Adj.reachable ((SimpleGraph.top_adj u v).2 h)

omit [Nonempty V] in
/-- The genus of `K_n` is `C(n,2) - n + 1`. -/
theorem genus_top :
    genus (⊤ : SimpleGraph V) = ((Fintype.card V).choose 2 : ℤ) - (Fintype.card V : ℤ) + 1 := by
  rw [genus, SimpleGraph.card_edgeFinset_top_eq_card_choose_two]

/-- The canonical divisor of `K_n` is the constant divisor `n - 3`. -/
theorem canonical_top :
    canonical (⊤ : SimpleGraph V) = fun _ => (Fintype.card V : ℤ) - 3 := by
  funext v
  have hd : (⊤ : SimpleGraph V).degree v = Fintype.card V - 1 :=
    SimpleGraph.complete_graph_degree v
  have hpos : 1 ≤ Fintype.card V := Fintype.card_pos
  simp only [canonical, hd]
  omega

omit [Nonempty V] in
/-- On the complete graph every vertex is adjacent to every other one, so the in-degree of
`v` for the orientation given by `t` is just the number of vertices of smaller rank. -/
theorem nu_top (t : V → ℕ) (v : V) :
    nu (⊤ : SimpleGraph V) t v = ((Finset.univ.filter (fun w => t w < t v)).card : ℤ) - 1 := by
  have : below (⊤ : SimpleGraph V) t v = Finset.univ.filter (fun w => t w < t v) := by
    ext w
    simp only [below, Finset.mem_filter, SimpleGraph.mem_neighborFinset, SimpleGraph.top_adj,
      Finset.mem_univ, true_and]
    constructor
    · rintro ⟨-, h⟩; exact h
    · intro h
      refine ⟨fun hvw => ?_, h⟩
      rw [hvw] at h
      omega
  rw [nu, this]

end CompleteGraph

section Kn

variable {n : ℕ} [NeZero n]

/-- The standard ranking of `Fin n`. -/
def finRank : Fin n → ℕ := fun i => (i : ℕ)

omit [NeZero n] in
lemma finRank_injective : Function.Injective (finRank (n := n)) := by
  intro a b h
  exact Fin.ext h

omit [NeZero n] in
/-- **An explicit maximal non-winnable divisor class on `K_n`.**  The divisor sending the
`i`-th vertex to `i - 1` is the acyclic-orientation divisor of the standard ordering. -/
theorem nu_finRank (i : Fin n) :
    nu (⊤ : SimpleGraph (Fin n)) finRank i = (i : ℤ) - 1 := by
  rw [nu_top]
  congr 1
  have h : (Finset.univ.filter (fun w : Fin n => finRank w < finRank i)) = Finset.Iio i := by
    ext w
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_Iio, finRank,
      Fin.lt_def]
  rw [h, Fin.card_Iio]

omit [NeZero n] in
/-- Its degree is `g - 1`. -/
theorem degD_nu_finRank :
    degD (nu (⊤ : SimpleGraph (Fin n)) finRank) = genus (⊤ : SimpleGraph (Fin n)) - 1 :=
  degD_nu _ _ finRank_injective

/-- It is not winnable: its Baker–Norine rank is `-1`, even though its degree is `g - 1 ≥ 0`
as soon as the genus is positive. -/
theorem rank_nu_finRank :
    rank (⊤ : SimpleGraph (Fin n)) (nu (⊤ : SimpleGraph (Fin n)) finRank) = -1 := by
  rw [rank_eq_neg_one_iff]
  exact nu_not_winnable _ _

/-- **Riemann–Roch on the complete graph.** -/
theorem riemann_roch_completeGraph (D : Divisor (Fin n)) :
    rank (⊤ : SimpleGraph (Fin n)) D
        - rank (⊤ : SimpleGraph (Fin n)) (canonical (⊤ : SimpleGraph (Fin n)) - D)
      = degD D - (((n.choose 2 : ℤ)) - (n : ℤ) + 1) + 1 := by
  have h := riemann_roch (⊤ : SimpleGraph (Fin n)) top_connected D
  rw [genus_top] at h
  simpa using h

/-- Every divisor of degree at least the genus is winnable on `K_n`. -/
theorem winnable_of_degD_ge_genus_completeGraph {D : Divisor (Fin n)}
    (h : ((n.choose 2 : ℤ)) - (n : ℤ) + 1 ≤ degD D) :
    Winnable (⊤ : SimpleGraph (Fin n)) D := by
  have hr := riemann_inequality (⊤ : SimpleGraph (Fin n)) top_connected D
  rw [genus_top] at hr
  simp only [Fintype.card_fin] at hr
  have : ¬ rank (⊤ : SimpleGraph (Fin n)) D = -1 := by omega
  by_contra hw
  exact this ((rank_eq_neg_one_iff _ D).2 hw)

end Kn

end TropicalRR