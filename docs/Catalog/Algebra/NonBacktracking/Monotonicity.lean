import Algebra.NonBacktracking.CycleMultiplicity

/-!
# Adding edges can only create closed non-backtracking walks

If `H ≤ G` then every closed non-backtracking walk of `H` is one of `G`, so the whole
non-backtracking trace sequence is monotone in the graph.

## Main results

* `Hashimoto.dartMap` — the inclusion of darts induced by `H ≤ G`;
* `Hashimoto.nbCycles_map_dartMap` — it carries cyclic non-backtracking words to cyclic
  non-backtracking words;
* `Hashimoto.trace_hashimoto_pow_mono` — `trace (B_H ^ n) ≤ trace (B_G ^ n)` for all `n`.
-/

open Finset SimpleGraph List

namespace Hashimoto

variable {V : Type*} [Fintype V] [DecidableEq V] {G H : SimpleGraph V}
  [DecidableRel G.Adj] [DecidableRel H.Adj]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] [DecidableRel H.Adj] in
/-- The inclusion of darts induced by an inclusion of graphs. -/
def dartMap (hle : H ≤ G) (d : H.Dart) : G.Dart := ⟨d.toProd, hle d.adj⟩

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] [DecidableRel H.Adj] in
lemma dartMap_injective (hle : H ≤ G) : Function.Injective (dartMap hle) := by
  intro d d' hdd
  rw [SimpleGraph.Dart.ext_iff]
  simpa [dartMap, SimpleGraph.Dart.ext_iff] using hdd

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] [DecidableRel H.Adj] in
lemma nbAdj_dartMap (hle : H ≤ G) {d d' : H.Dart} :
    NBAdj G (dartMap hle d) (dartMap hle d') ↔ NBAdj H d d' := Iff.rfl

/-- **Cyclic non-backtracking words are inherited by supergraphs.** -/
theorem nbCycles_map_dartMap (hle : H ≤ G) {n : ℕ} (hn : 1 ≤ n) {c : List H.Dart}
    (hc : c ∈ nbCycles H n) : c.map (dartMap hle) ∈ nbCycles G n := by
  rw [mem_nbCycles hn] at hc ⊢
  obtain ⟨hlen, hchain, hseam⟩ := hc
  refine ⟨by rw [List.length_map]; exact hlen, ?_, ?_⟩
  · rw [List.isChain_map]
    exact hchain.imp fun a b hab => (nbAdj_dartMap hle).2 hab
  · intro x hx y hy
    rw [List.getLast?_map] at hx
    rw [List.head?_map] at hy
    obtain ⟨dl, hdl, rfl⟩ : ∃ d, c.getLast? = some d ∧ dartMap hle d = x := by
      rcases hh : c.getLast? with _ | d
      · rw [hh] at hx; simp at hx
      · rw [hh] at hx; exact ⟨d, rfl, by simpa using hx⟩
    obtain ⟨d₀, hd₀, rfl⟩ : ∃ d, c.head? = some d ∧ dartMap hle d = y := by
      rcases hh : c.head? with _ | d
      · rw [hh] at hy; simp at hy
      · rw [hh] at hy; exact ⟨d, rfl, by simpa using hy⟩
    exact (nbAdj_dartMap hle).2 (hseam dl hdl d₀ hd₀)

/-- **Monotonicity of the non-backtracking trace.** Adding edges cannot destroy closed
non-backtracking walks: if `H ≤ G` then `trace (B_H ^ n) ≤ trace (B_G ^ n)` for every `n`. -/
theorem trace_hashimoto_pow_mono (hle : H ≤ G) (n : ℕ) :
    (hashimoto H ^ n).trace ≤ (hashimoto G ^ n).trace := by
  classical
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · rw [pow_zero, pow_zero, Matrix.trace_one, Matrix.trace_one]
    simpa using Fintype.card_le_of_injective _ (dartMap_injective hle)
  · rw [trace_hashimoto_pow_eq_card_nbCycles H hn, trace_hashimoto_pow_eq_card_nbCycles G hn]
    refine Finset.card_le_card_of_injOn (fun c => c.map (dartMap hle))
      (fun c hc => nbCycles_map_dartMap hle hn hc) ?_
    intro c _ c' _ hcc
    exact List.map_injective_iff.2 (dartMap_injective hle) hcc

end Hashimoto