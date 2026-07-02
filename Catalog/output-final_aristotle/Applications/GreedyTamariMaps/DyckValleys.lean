/-
# Valleys and peaks of Dyck words (the greedy-Tamari lower-endpoint statistic)

This file studies the **valley statistic** on Dyck words, which is the combinatorial
statistic recording, for an interval `[x, y]` of a Tamari-type order on Dyck paths, the
number of valleys of the *lower endpoint* `x`.  A **valley** of a Dyck path is a factor
`DU` (a down step immediately followed by an up step); a **peak** is a factor `UD`.

We build on Mathlib's `DyckWord` (`Mathlib.Combinatorics.Enumerative.DyckWord`), reusing in
particular `DyckWord.head_eq_U`, `DyckWord.getLast_eq_D` and, in the companion file, the
enumeration `DyckWord.card_dyckWord_semilength_eq_catalan`.

## Main results

* `Applications.GreedyTamariMaps.peaksL_sub_valleysL`: the load-bearing invariant.  For any
  nonempty list of Dyck steps, `#peaks − #valleys = φ(head) − φ(last)` (as integers), where
  `φ U = 1` and `φ D = 0`.  Proved by a genuine two-step list induction.
* `Applications.GreedyTamariMaps.peaks_eq_valleys_succ`: for every nonempty Dyck word,
  `#peaks = #valleys + 1`.  This is the classical "peaks are one more than valleys" identity,
  here derived from the invariant together with `head_eq_U`/`getLast_eq_D`.
* `Applications.GreedyTamariMaps.valleys_le_semilength`: the valley count is bounded by the
  semilength (needed to organise the refined enumeration).
* `Applications.GreedyTamariMaps.refined_valley_enumeration`: the refined valley counts of
  Dyck words of semilength `n` sum over `k` to `catalan n` — the aggregate consistency the
  conjectured refinement must satisfy on the greedy-Tamari side.
* `Applications.GreedyTamariMaps.valleys_eq_zero_iff`: a Dyck word of semilength `n` has no
  valley iff it is exactly the minimal path `Uⁿ Dⁿ`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): On the greedy-Tamari side of the conjectured bijection the
  refining statistic is the valley count of the lower endpoint.  A robust, purely local
  identity should govern valleys: for every nonempty Dyck path `#peaks = #valleys + 1`.
  Surprising corollary tested: this needs *only* that the path starts with `U` and ends
  with `D`; the balance/positivity conditions are not used.
Experiment (Experimenter): Enumerated all Dyck paths of semilength ≤ 5 as `List Bool`,
  computed the valley distribution (Narayana rows `1`; `1,1`; `1,3,1`; `1,6,6,1`;
  `1,10,20,10,1`) and verified `peaks = valleys + 1` on every path.  See
  `ComputationalEvidence.md`.
Analysis (Analyst): The clean inductive invariant is the *signed* identity
  `peaks − valleys = φ(head) − φ(last)` with `φ U = 1`, `φ D = 0`; it holds for *all*
  lists of two-letter steps and specialises to `peaks = valleys + 1` once `head = U`,
  `last = D`.  The naive statement `peaks = valleys + 1` is NOT closed under taking tails,
  which is why the signed invariant (closed under peeling the head) is the right induction.
Critique (Critic): No result here is vacuous.  `peaks_eq_valleys_succ` is a real
  arithmetic consequence of a genuine induction (`rcases` on the two leading steps +
  `omega`), not `rfl`/`decide`.  The hypothesis `p ≠ 0` is load-bearing: the empty word
  has `peaks = valleys = 0`, so the `+1` fails there.
Synthesis (PI): `peaks_eq_valleys_succ` and `valleys_le_semilength` are the reusable
  substrate for the refined enumeration (companion file) and for any future formal
  bijection with bipartite planar maps.
-/
import Mathlib

namespace Applications.GreedyTamariMaps

open DyckStep List

/-- Number of **valleys** (`D` immediately followed by `U`) in a list of Dyck steps. -/
def valleysL : List DyckStep → ℕ
  | D :: U :: t => 1 + valleysL (U :: t)
  | _ :: t => valleysL t
  | [] => 0

/-- Number of **peaks** (`U` immediately followed by `D`) in a list of Dyck steps. -/
def peaksL : List DyckStep → ℕ
  | U :: D :: t => 1 + peaksL (D :: t)
  | _ :: t => peaksL t
  | [] => 0

/-- The valley count of a Dyck word. -/
def valleys (p : DyckWord) : ℕ := valleysL p.toList

/-- The peak count of a Dyck word. -/
def peaks (p : DyckWord) : ℕ := peaksL p.toList

/-- Weight `φ U = 1`, `φ D = 0`, used to state the signed peak/valley invariant. -/
def phi : DyckStep → ℤ
  | U => 1
  | D => 0

/-
**Signed peak/valley invariant.**  For any nonempty list of Dyck steps,
`#peaks − #valleys = φ(head) − φ(last)`.  This is the induction-friendly form of the
classical "one more peak than valley" identity.
-/
theorem peaksL_sub_valleysL (l : List DyckStep) (h : l ≠ []) :
    (peaksL l : ℤ) - valleysL l = phi (l.head h) - phi (l.getLast h) := by
  induction' l with a l ih;
  · contradiction;
  · rcases l with ( _ | ⟨ b, l ⟩ ) <;> simp_all +decide;
    · cases a <;> trivial;
    · rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> simp_all +decide [ peaksL, valleysL ];
      · unfold phi at * ; linarith;
      · unfold phi at * ; linarith!

/-
**Peaks are one more than valleys.**  For every nonempty Dyck word,
`#peaks = #valleys + 1`.
-/
theorem peaks_eq_valleys_succ (p : DyckWord) (hp : p ≠ 0) :
    peaks p = valleys p + 1 := by
  obtain ⟨l, hl⟩ : ∃ l : List DyckStep, p = l ∧ l ≠ [] := by
    exact ⟨ p.toList, rfl, by simpa [ DyckWord.toList_ne_nil ] using hp ⟩;
  convert peaksL_sub_valleysL l hl.2 using 1;
  simp +decide [ ← hl.1 ];
  rw [ DyckWord.head_eq_U p, DyckWord.getLast_eq_D p ] ; simp +decide [ phi ];
  constructor <;> intro h <;> linarith!

/-
The valley count of a list of Dyck steps is at most the number of `U` steps.
-/
theorem valleysL_le_count_U (l : List DyckStep) : valleysL l ≤ l.count U := by
  induction' n : l.length using Nat.strong_induction_on with n ih generalizing l;
  rcases l with ( _ | ⟨ a, _ | ⟨ b, l ⟩ ⟩ ) <;> simp_all +decide;
  · cases a <;> trivial;
  · rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> simp +arith +decide [ valleysL ];
    · grind;
    · grind +suggestions;
    · grind;
    · specialize ih ( l.length + 1 ) ( by linarith ) ( D :: l ) ; aesop

/-
The valley count of a Dyck word is bounded by its semilength.
-/
theorem valleys_le_semilength (p : DyckWord) : valleys p ≤ p.semilength := by
  convert valleysL_le_count_U p.toList using 1

open Finset in
/-- The number of Dyck words of semilength `n` whose lower-endpoint valley count is `k`. -/
noncomputable def refinedValleyCount (n k : ℕ) : ℕ :=
  (Finset.univ.filter
    (fun q : { p : DyckWord // p.semilength = n } => valleys q.1 = k)).card

/-
**Aggregate consistency of the refined valley enumeration.**  Summing the refined
valley counts over all valley numbers `k ∈ {0, …, n}` recovers the total number of Dyck
words of semilength `n`, namely `catalan n` (Mathlib's
`DyckWord.card_dyckWord_semilength_eq_catalan`).  This is the identity any correct
refinement of the greedy-Tamari lower endpoints by valley count must satisfy.
-/
theorem refined_valley_enumeration (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), refinedValleyCount n k = catalan n := by
  rw [ ← DyckWord.card_dyckWord_semilength_eq_catalan ];
  unfold refinedValleyCount;
  rw [ ← Finset.card_eq_sum_card_fiberwise ];
  · rfl;
  · exact fun q _ => Finset.mem_range.mpr ( Nat.lt_succ_of_le ( valleys_le_semilength _ |> le_trans <| by aesop ) )

/-
A list of Dyck steps has no valley (`D` followed by `U`) iff every `U` precedes every
`D`, i.e. it is `Uᵃ Dᵇ` with `a = #U` and `b = #D`.
-/
theorem valleysL_eq_zero_iff (l : List DyckStep) :
    valleysL l = 0 ↔
      l = List.replicate (l.count U) U ++ List.replicate (l.count D) D := by
  constructor;
  · intro h;
    induction' n : l.length using Nat.strong_induction_on with n ih generalizing l;
    rcases l with ( _ | ⟨ x, _ | ⟨ y, l ⟩ ⟩ ) <;> simp_all +decide;
    · cases x <;> trivial;
    · rcases x with ( _ | _ | x ) <;> rcases y with ( _ | _ | y ) <;> simp_all +decide [ valleysL ];
      · grind +splitImp;
      · grind;
      · specialize ih ( l.length + 1 ) ( by linarith ) ( D :: l ) ; simp_all +decide;
        cases h : count U l <;> cases h' : count D l <;> simp_all +decide [ List.replicate ];
  · intro hl
    rw [hl];
    induction' count U l with a ha;
    · induction' count D l with b hb <;> simp +decide [ *, List.replicate ];
      cases b <;> tauto;
    · convert ha using 1

/-
**The unique minimal lower endpoint.**  A Dyck word of semilength `n` has no valley iff
it is exactly the staircase-free path `Uⁿ Dⁿ`.
-/
theorem valleys_eq_zero_iff (p : DyckWord) :
    valleys p = 0 ↔
      p.toList = List.replicate p.semilength U ++ List.replicate p.semilength D := by
  convert valleysL_eq_zero_iff p.toList;
  convert p.count_U_eq_count_D.symm using 1;
  · exact p.count_U_eq_count_D
  · convert p.count_U_eq_count_D.symm using 1

end Applications.GreedyTamariMaps