import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.SubshiftLanguage
import MachineLearning.GoldenMeanChaos
import MachineLearning.GoldenMeanRigidity

/-!
# An explicit transitive point of the golden-mean subshift

Ninth cycle of the research thread.  Cycle 5 proved topological transitivity in the "two open
sets are linked by an iterate" form.  The classical, stronger form of transitivity is the
existence of a single point whose forward orbit is dense.  This file constructs such a point
explicitly and proves it works.

The construction is the standard one, and it is again powered by *gluing with one spacer*
(`admissible_glue` of cycle 5): enumerate all finite binary words, discard the inadmissible
ones, and concatenate the survivors separated by a buffer letter `false`.  Because the only
forbidden word is `11`, the buffer is enough to keep the whole infinite concatenation
admissible, and by construction every admissible word occurs in it as a factor.

Together with cycle 5 this makes the Devaney chaos statement canonical: dense periodic points,
a dense orbit, and sensitive dependence.  We also observe that the subshift is *not* minimal —
the singleton `{allFalse}` is a proper nonempty closed invariant subset — so the dense orbit is
a genuinely stronger statement than the existence of *some* dense orbit closure.

## Main results

* `segs_admissible` — every finite stage of the concatenation is admissible and ends in the
  buffer letter.
* `transPoint_mem_goldenMean` — the concatenated stream lies in the subshift.
* `exists_shift_prefixOf_eq` — every admissible word occurs at a known position of the orbit.
* `denseOrbit_transPoint` — the forward orbit of `transPoint` is dense in the subshift.
* `goldenMean_not_minimal` — yet the subshift has a proper nonempty closed invariant subset.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Metric

/-! ## Concatenating admissible words -/

/-- If a word is empty or ends in `false`, anything admissible may be appended to it. -/
theorem admissible_append_of_last_false {u v : List Bool} (hu : Admissible u)
    (hv : Admissible v) (hlast : u = [] ∨ u.getLast? = some false) :
    Admissible (u ++ v) := by
  refine List.isChain_append.mpr ⟨hu, hv, ?_⟩
  intro x hx y _
  rcases hlast with rfl | h
  · simp at hx
  · rw [Option.mem_def, h, Option.some_inj] at hx
    subst hx
    simp

open Classical in
/-- The `n`-th admissible word of the enumeration: decode `n` as a finite word and keep it if
it is admissible, otherwise use the empty word. -/
noncomputable def segWord (n : ℕ) : List Bool :=
  if Admissible ((Encodable.decode (α := List Bool) n).getD []) then
    (Encodable.decode (α := List Bool) n).getD []
  else []

theorem segWord_admissible (n : ℕ) : Admissible (segWord n) := by
  classical
  unfold segWord
  split
  · assumption
  · exact admissible_nil

/-- The enumeration really does hit every admissible word. -/
theorem segWord_encode {w : List Bool} (hw : Admissible w) :
    segWord (Encodable.encode w) = w := by
  classical
  unfold segWord
  rw [Encodable.encodek]
  simp only [Option.getD_some]
  rw [if_pos hw]

/-- The finite stages of the concatenation, each ending in a buffer `false`. -/
noncomputable def segs : ℕ → List Bool
  | 0 => []
  | (n + 1) => segs n ++ segWord n ++ [false]

theorem segs_succ (n : ℕ) : segs (n + 1) = segs n ++ segWord n ++ [false] := rfl

/-- Every stage is admissible and either empty or ends in the buffer letter. -/
theorem segs_admissible : ∀ n : ℕ, Admissible (segs n) ∧ (segs n = [] ∨ (segs n).getLast? = some false)
  | 0 => ⟨admissible_nil, Or.inl rfl⟩
  | (n + 1) => by
      obtain ⟨hadm, hlast⟩ := segs_admissible n
      have h1 : Admissible (segs n ++ segWord n) :=
        admissible_append_of_last_false hadm (segWord_admissible n) hlast
      refine ⟨?_, Or.inr ?_⟩
      · rw [segs_succ]
        exact admissible_append_false h1
      · rw [segs_succ]
        simp

/-- Later stages extend earlier ones. -/
theorem segs_prefix : ∀ {n m : ℕ}, n ≤ m → ∃ t, segs m = segs n ++ t := by
  intro n m
  induction m with
  | zero =>
      intro h
      have hn : n = 0 := Nat.le_zero.mp h
      subst hn
      exact ⟨[], by simp⟩
  | succ m ih =>
      intro h
      rcases Nat.lt_or_ge n (m + 1) with hlt | hge
      · obtain ⟨t, ht⟩ := ih (by omega)
        exact ⟨t ++ segWord m ++ [false], by rw [segs_succ, ht]; simp⟩
      · have hn : n = m + 1 := by omega
        subst hn
        exact ⟨[], by simp⟩

/-- Each stage adds at least one letter, so stage `n` has length at least `n`. -/
theorem le_length_segs : ∀ n : ℕ, n ≤ (segs n).length
  | 0 => Nat.zero_le _
  | (n + 1) => by
      have ih := le_length_segs n
      rw [segs_succ]
      simp only [List.length_append, List.length_cons, List.length_nil]
      omega

/-- **The transitive point**: the infinite concatenation of all admissible words, separated by
buffer letters. -/
noncomputable def transPoint : Cantor := fun k => (segs (k + 1)).getD k false

/-- The value of the transitive point can be read off any sufficiently long stage. -/
theorem transPoint_eq_getD {k m : ℕ} (h : k < (segs m).length) :
    transPoint k = (segs m).getD k false := by
  rcases Nat.le_total m (k + 1) with hle | hle
  · obtain ⟨t, ht⟩ := segs_prefix hle
    show (segs (k + 1)).getD k false = _
    rw [ht, getD_append_left h]
  · obtain ⟨t, ht⟩ := segs_prefix hle
    show (segs (k + 1)).getD k false = _
    rw [ht, getD_append_left (by have := le_length_segs (k + 1); omega)]

/-- The concatenated stream lies in the golden-mean subshift. -/
theorem transPoint_mem_goldenMean : transPoint ∈ GoldenMean := by
  intro k hk
  have hlen : k + 1 + 1 ≤ (segs (k + 2)).length := le_length_segs (k + 2)
  have h1 : transPoint k = (segs (k + 2)).getD k false :=
    transPoint_eq_getD (by omega)
  have h2 : transPoint (k + 1) = (segs (k + 2)).getD (k + 1) false :=
    transPoint_eq_getD (by omega)
  rw [h1, h2] at hk
  exact admissible_getD (segs_admissible (k + 2)).1 k (by omega) hk

/-! ## The orbit is dense -/

/-- **Every admissible word occurs in the orbit**, at the position where the enumeration placed
it. -/
theorem exists_shift_prefixOf_eq {w : List Bool} (hw : Admissible w) :
    ∃ j : ℕ, prefixOf w.length (shift^[j] transPoint) = w := by
  classical
  refine ⟨(segs (Encodable.encode w)).length, ?_⟩
  have hseg : segs (Encodable.encode w + 1)
      = segs (Encodable.encode w) ++ (w ++ [false]) := by
    rw [segs_succ, segWord_encode hw, List.append_assoc]
  have hlen : (segs (Encodable.encode w + 1)).length
      = (segs (Encodable.encode w)).length + (w.length + 1) := by
    rw [hseg]; simp
  have hagree : AgreeTo w.length
      (shift^[(segs (Encodable.encode w)).length] transPoint) (extend w) := by
    intro k hk
    have hbound : k + (segs (Encodable.encode w)).length
        < (segs (Encodable.encode w + 1)).length := by omega
    rw [shift_iterate_apply, transPoint_eq_getD hbound, hseg]
    have hkj : k + (segs (Encodable.encode w)).length
        = (segs (Encodable.encode w)).length + k := by omega
    rw [hkj, getD_append_right, getD_append_left hk]
    rfl
  rw [(prefixOf_eq_iff_agreeTo _ _ _).mpr hagree]
  exact prefixOf_extend w

/-- **The forward orbit of `transPoint` is dense in the golden-mean subshift.**  This is
topological transitivity in its strongest, classical form. -/
theorem denseOrbit_transPoint {x : Cantor} (hx : x ∈ GoldenMean) {ε : ℝ} (hε : 0 < ε) :
    ∃ j : ℕ, dist x (shift^[j] transPoint) < ε := by
  obtain ⟨n, hn⟩ := exists_two_zpow_lt hε
  have hw : Admissible (prefixOf n x) :=
    ((mem_goldenWords n _).mp (prefixOf_mem_goldenWords n hx)).2
  obtain ⟨j, hj⟩ := exists_shift_prefixOf_eq hw
  refine ⟨j, lt_of_le_of_lt ((dist_le_iff_prefixOf_eq n x _).mpr ?_) hn⟩
  rw [← hj, length_prefixOf]

/-- The whole subshift lies in the closure of the orbit of the single point `transPoint`. -/
theorem goldenMean_subset_closure_orbit :
    GoldenMean ⊆ closure (Set.range (fun j : ℕ => shift^[j] transPoint)) := by
  intro x hx
  rw [Metric.mem_closure_iff]
  intro ε hε
  obtain ⟨j, hj⟩ := denseOrbit_transPoint hx hε
  exact ⟨shift^[j] transPoint, ⟨j, rfl⟩, hj⟩

/-! ## …but the system is not minimal -/

/-- **The golden-mean subshift is not minimal.**  The fixed point `allFalse` spans a proper
nonempty closed invariant subset, so having a dense orbit is strictly weaker than every orbit
being dense. -/
theorem goldenMean_not_minimal :
    ∃ Y : Set Cantor, Y ⊆ GoldenMean ∧ Y.Nonempty ∧ Y ≠ GoldenMean ∧ IsClosed Y ∧
      Set.MapsTo shift Y Y := by
  refine ⟨{allFalse}, ?_, ⟨allFalse, rfl⟩, ?_, isClosed_singleton, ?_⟩
  · rintro y rfl
    exact allFalse_mem_goldenMean
  · intro hEq
    have hmem : extend [true] ∈ GoldenMean :=
      extend_mem_goldenMean _ (admissible_singleton true)
    rw [← hEq, Set.mem_singleton_iff] at hmem
    have := congrFun hmem 0
    simp [extend, allFalse] at this
  · rintro y rfl
    have : shift allFalse = allFalse := by
      funext k; rfl
    rw [this]
    exact rfl

end FractalTruthCompactness