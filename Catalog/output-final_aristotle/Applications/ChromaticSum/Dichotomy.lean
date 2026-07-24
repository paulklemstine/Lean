/-
# Chromatic Sum: quantitative dichotomy results, proofs and disproofs

Building on `Defs.lean`, this file records the *contrarian* portion of the
mission: we formulate several bold quantitative conjectures about the chromatic
sum `Σ(G)` and either **prove** or **disprove** them.

## Results proved

* `ChromaticSum.chromaticSum_top` — the chromatic sum of the complete graph
  `Kₙ` is exactly `n(n+1)/2` (the `n`‑th triangular number).  Every vertex must
  get a distinct positive colour, and `1,2,…,n` is optimal.
* `ChromaticSum.chromaticSum_top_eq_card_add_edges` — for the complete graph the
  formula `Σ(G) = |V| + |E(G)|` holds.
* `ChromaticSum.chromaticSum_P3` — the chromatic sum of the path `P₃` equals `4`.

## Results disproved

* `ChromaticSum.conj_card_add_edges_false` — the tempting closed form
  `Σ(G) = |V| + |E(G)|` (which is correct for edgeless graphs, single edges and
  *all* complete graphs) is **false in general**: it already fails for the path
  `P₃`, a forest, where `Σ = 4` but `|V| + |E| = 5`.
* `ChromaticSum.exists_proper_not_minimum` — a proper colouring using the optimal
  *number* of colours (`χ = 2`) need **not** achieve the chromatic sum: `P₃` has
  a proper 2‑colouring of colour sum `5 > 4 = Σ(P₃)`.

These disproofs illustrate exactly why chromatic sum is subtler than the
chromatic number, the phenomenon underlying the conjectured complexity dichotomy
for the Chromatic Sum problem on forest‑free graphs.
-/

import Mathlib
import Catalog.Applications.ChromaticSum.Defs

open Finset

namespace ChromaticSum

/-! ### The complete graph `Kₙ` -/

/-- On the complete graph, proper colourings are exactly the injective positive
colourings. -/
theorem proper_top_iff {n : ℕ} {c : Fin n → ℕ} :
    IsProperColoring (⊤ : SimpleGraph (Fin n)) c ↔
      (∀ i, 1 ≤ c i) ∧ Function.Injective c := by
  constructor
  · rintro ⟨hp, hadj⟩
    refine ⟨hp, ?_⟩
    intro u v h
    by_contra hne
    exact hadj ((SimpleGraph.top_adj u v).2 hne) h
  · rintro ⟨hp, hinj⟩
    refine ⟨hp, ?_⟩
    intro u v huv h
    exact (SimpleGraph.top_adj u v).1 huv (hinj h)

/-- Closed form for the sum of the first `n` positive integers. -/
theorem sum_range_add_one (n : ℕ) :
    ∑ i ∈ range n, (i + 1) = n * (n + 1) / 2 := by
  have h : 2 * (∑ i ∈ range n, (i + 1)) = n * (n + 1) := by
    induction n with
    | zero => rfl
    | succ k ih => rw [Finset.sum_range_succ, Nat.mul_add, ih]; ring
  omega

/-- A finite set of positive natural numbers of cardinality `k` has sum at least
`1 + 2 + ⋯ + k`: the range `{1,…,k}` minimises the sum. -/
theorem fin_sum_ge (t : Finset ℕ) (hpos : ∀ x ∈ t, 1 ≤ x) :
    ∑ i ∈ range t.card, (i + 1) ≤ ∑ x ∈ t, x := by
  induction t using Finset.strongInduction with
  | _ t ih =>
    rcases t.eq_empty_or_nonempty with rfl | hne
    · simp
    · set m := t.max' hne with hm
      have hmem : m ∈ t := t.max'_mem hne
      have hsub : t ⊆ Finset.Icc 1 m := by
        intro x hx
        simp only [Finset.mem_Icc]
        exact ⟨hpos x hx, t.le_max' x hx⟩
      have hcardle : t.card ≤ m := by
        have := Finset.card_le_card hsub
        simpa [Nat.card_Icc] using this
      have ht' : (t.erase m).card = t.card - 1 := by
        rw [Finset.card_erase_of_mem hmem]
      have hih := ih (t.erase m) (Finset.erase_ssubset hmem)
        (fun x hx => hpos x (Finset.mem_of_mem_erase hx))
      rw [ht'] at hih
      have hsum : ∑ x ∈ t, x = (∑ x ∈ t.erase m, x) + m := by
        rw [Finset.sum_erase_add t _ hmem]
      have hcard1 : 1 ≤ t.card := Finset.card_pos.mpr hne
      have hstep : ∑ i ∈ range t.card, (i + 1)
          = (∑ i ∈ range (t.card - 1), (i + 1)) + t.card := by
        conv_lhs => rw [show t.card = (t.card - 1) + 1 from by omega, Finset.sum_range_succ]
        omega
      rw [hsum, hstep]
      exact Nat.add_le_add hih hcardle

/-- **Lower bound at the heart of the complete‑graph computation.** Any injective
colouring with positive colours has colour sum at least the `n`‑th triangular
number: the `n` distinct positive colours cannot beat `1 + 2 + ⋯ + n`. -/
theorem colorSum_injective_ge (n : ℕ) (c : Fin n → ℕ)
    (hpos : ∀ i, 1 ≤ c i) (hinj : Function.Injective c) :
    n * (n + 1) / 2 ≤ colorSum c := by
  classical
  have hcard : (Finset.image c Finset.univ).card = n := by
    rw [Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_fin]
  have hsum : ∑ x ∈ Finset.image c Finset.univ, x = colorSum c := by
    rw [Finset.sum_image (fun a _ b _ h => hinj h)]; rfl
  have hposset : ∀ x ∈ Finset.image c Finset.univ, 1 ≤ x := by
    intro x hx
    rw [Finset.mem_image] at hx
    obtain ⟨i, _, rfl⟩ := hx
    exact hpos i
  have hkey := fin_sum_ge (Finset.image c Finset.univ) hposset
  rw [hcard, hsum, sum_range_add_one] at hkey
  exact hkey

/-- **The chromatic sum of the complete graph `Kₙ` is the `n`‑th triangular
number `n(n+1)/2`.** -/
theorem chromaticSum_top (n : ℕ) :
    chromaticSum (⊤ : SimpleGraph (Fin n)) = n * (n + 1) / 2 := by
  classical
  apply le_antisymm
  · have hd : IsProperColoring (⊤ : SimpleGraph (Fin n)) (fun i => (i : ℕ) + 1) := by
      refine ⟨fun i => by dsimp only; omega, ?_⟩
      intro u v huv h
      have hne : u ≠ v := (SimpleGraph.top_adj u v).1 huv
      apply hne
      have h' : (u : ℕ) + 1 = (v : ℕ) + 1 := h
      exact Fin.ext (by omega)
    have hval : colorSum (fun i : Fin n => (i : ℕ) + 1) = n * (n + 1) / 2 := by
      unfold colorSum
      rw [Fin.sum_univ_eq_sum_range (fun i => i + 1) n]
      exact sum_range_add_one n
    calc chromaticSum (⊤ : SimpleGraph (Fin n))
          ≤ colorSum (fun i : Fin n => (i : ℕ) + 1) := chromaticSum_le_colorSum hd
      _ = n * (n + 1) / 2 := hval
  · apply le_chromaticSum
    intro c hc
    obtain ⟨hpos, hinj⟩ := proper_top_iff.1 hc
    exact colorSum_injective_ge n c hpos hinj

/-- For the complete graph the naive closed form `Σ(G) = |V| + |E(G)|` is
correct. -/
theorem chromaticSum_top_eq_card_add_edges (n : ℕ) :
    chromaticSum (⊤ : SimpleGraph (Fin n)) =
      Fintype.card (Fin n) + (⊤ : SimpleGraph (Fin n)).edgeFinset.card := by
  rw [chromaticSum_top, Fintype.card_fin,
    SimpleGraph.card_edgeFinset_top_eq_card_choose_two, Fintype.card_fin,
    Nat.choose_two_right]
  rcases n with _ | k
  · rfl
  · simp only [Nat.add_sub_cancel]
    have hab : (k + 1) * (k + 1 + 1) = (k + 1) * k + 2 * (k + 1) := by ring
    have hb : 2 ∣ (k + 1) * k := by
      rw [Nat.mul_comm]; exact (Nat.even_mul_succ_self k).two_dvd
    omega

/-! ### The path `P₃` — a forest where the naive formula fails -/

/-- The path on three vertices `0 — 1 — 2` (equivalently, the star `K_{1,2}`),
with centre `1`. -/
def P3 : SimpleGraph (Fin 3) where
  Adj i j := (i = 0 ∧ j = 1) ∨ (i = 1 ∧ j = 0) ∨ (i = 1 ∧ j = 2) ∨ (i = 2 ∧ j = 1)
  symm := by
    intro i j h
    rcases h with ⟨a, b⟩ | ⟨a, b⟩ | ⟨a, b⟩ | ⟨a, b⟩ <;> subst a <;> subst b <;> tauto
  loopless := ⟨by
    intro i h
    rcases h with ⟨a, b⟩ | ⟨a, b⟩ | ⟨a, b⟩ | ⟨a, b⟩ <;> subst a <;> exact absurd b (by decide)⟩

instance : DecidableRel P3.Adj := fun i j => by
  unfold P3; dsimp only; infer_instance

theorem P3_adj_01 : P3.Adj 0 1 := by left; exact ⟨rfl, rfl⟩

theorem P3_adj_12 : P3.Adj 1 2 := by right; right; left; exact ⟨rfl, rfl⟩

/-- **The chromatic sum of `P₃` is `4`.**  The optimum colours the two
end‑vertices `1` and the centre `2` (sum `1 + 2 + 1`), beating the naive
"centre gets colour 1" colouring (sum `1 + 2 + 2 = 5`). -/
theorem chromaticSum_P3 : chromaticSum P3 = 4 := by
  apply le_antisymm
  · have hc : IsProperColoring P3 (![1, 2, 1]) := by
      constructor
      · decide
      · decide
    calc chromaticSum P3 ≤ colorSum (![1, 2, 1]) := chromaticSum_le_colorSum hc
      _ = 4 := by unfold colorSum; rw [Fin.sum_univ_three]; rfl
  · apply le_chromaticSum
    intro c hc
    have h01 : c 0 ≠ c 1 := hc.2 P3_adj_01
    have h12 : c 1 ≠ c 2 := hc.2 P3_adj_12
    have p0 := hc.1 0
    have p1 := hc.1 1
    have p2 := hc.1 2
    unfold colorSum
    rw [Fin.sum_univ_three]
    omega

/-! ### Contrarian conjectures: disproofs -/

/-- **Disproof of `Σ(G) = |V| + |E(G)|`.**  Despite holding for edgeless graphs,
single edges and *every* complete graph (`chromaticSum_top_eq_card_add_edges`),
this closed form is false in general: it fails for the path `P₃`, a forest, where
`Σ(P₃) = 4` but `|V| + |E| = 3 + 2 = 5`. -/
theorem conj_card_add_edges_false :
    ¬ ∀ (V : Type) [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj],
        chromaticSum G = Fintype.card V + G.edgeFinset.card := by
  intro h
  have hP := h (Fin 3) P3
  rw [chromaticSum_P3] at hP
  have hcard : Fintype.card (Fin 3) = 3 := by simp
  have hedges : P3.edgeFinset.card = 2 := by decide
  rw [hcard, hedges] at hP
  omega

/-- **Disproof that every `χ`‑colouring is a minimum‑sum colouring.**  There is a
proper colouring of `P₃` that uses only `χ(P₃) = 2` colours yet has colour sum
`5`, strictly larger than the chromatic sum `4`.  Thus minimising the *number* of
colours does not minimise the *sum* of colours. -/
theorem exists_proper_not_minimum :
    ∃ c : Fin 3 → ℕ, IsProperColoring P3 c ∧ chromaticSum P3 < colorSum c := by
  refine ⟨![2, 1, 2], ?_, ?_⟩
  · constructor
    · decide
    · decide
  · rw [chromaticSum_P3]
    show 4 < colorSum (![2, 1, 2])
    decide

end ChromaticSum