/-
# Contrarian analysis of cycle persistence in `G_p`

Building on the independent edge-retention model of `Retention.lean`, this file
formulates several *bold conjectures* about persistence of cycles in a random
subgraph `G_p` and settles them — some are **proved**, one is **disproved**.

## Summary of results

* **DISPROVED** (`single_structure_fragility`): the naive conjecture *"for any
  fixed `p < 1`, one fixed cycle survives asymptotically almost surely as its
  length grows"* is **false**.  The survival probability of a fixed edge set of
  size `L` is exactly `p ^ L`, which tends to `0`.  Thus persistence of long
  cycles can never come from a *single* prescribed cycle; it must come from the
  graph containing *many* cycles.

* **PROVED** (`exists_survivor_of_pos`): the *first-moment persistence
  principle* — if the expected number of surviving members of a family `F` of
  cycles is positive, then some retention outcome keeps an entire member of `F`
  intact.  This is the positive engine behind persistence: enough candidate
  cycles guarantee a survivor.

* **PROVED** (`prob_survives_antitone`): survival probability is antitone in the
  edge set — longer cycles are (weakly) harder to keep, quantifying the tension
  the main theorem must overcome.

* **PROVED** (`exp_retained_edges`): the expected number of retained edges is
  exactly `p · |E|`.  With `p ≈ d / log n` and average degree `d`, this is the
  degree-scaling that makes the `d − εd` cycle-length target plausible.
-/
import Computation.PersistentCycles.Retention

open scoped BigOperators
open Classical

namespace PersistentCycles

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/--
Larger structures are (weakly) less likely to survive: survival probability
is antitone in the edge set, for `0 ≤ p ≤ 1`.
-/
theorem prob_survives_antitone {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {S T : Finset ι}
    (h : S ⊆ T) : Prob p (survives T) ≤ Prob p (survives S) := by
  convert prob_mono _ _ _;
  · exact hp0;
  · exact hp1;
  · exact fun ω hω e he => hω e ( h he )

/-
**Non-emptiness from positive expectation.**  If the expected number of
surviving members of a finite family `F` is strictly positive, then there is a
retention outcome under which some member of `F` survives entirely.  (The
all-edges-retained outcome witnesses this once `F ≠ ∅`, which positivity forces.)
-/
omit [Fintype ι] [DecidableEq ι] in
theorem exists_survivor_of_pos {p : ℝ} (F : Finset (Finset ι))
    (h : 0 < ∑ S ∈ F, p ^ S.card) : ∃ ω : ι → Bool, ∃ S ∈ F, survives S ω := by
  rcases F.eq_empty_or_nonempty with rfl | hF
  · simp at h
  · obtain ⟨S, hS⟩ := hF
    exact ⟨fun _ => true, S, hS, fun e _ => rfl⟩

/--
**Finite union bound over a family of cycles (genuine first moment).**  The
probability that *at least one* member of a finite family `F` of edge sets
survives is at most the sum of the individual survival probabilities
`∑ S ∈ F, p ^ |S|`.  This is the tool that turns a *small expected number* of
long cycles into *almost-sure absence* of any: when the right-hand side tends to
`0`, so does the probability that any long cycle persists.
-/
theorem prob_survivor_family_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (F : Finset (Finset ι)) :
    Prob p (fun ω => ∃ S ∈ F, survives S ω) ≤ ∑ S ∈ F, p ^ S.card := by
  induction' F using Finset.induction with a F hF ih;
  · simp +decide [ Prob ];
  · have h_union : Prob p (fun ω => ∃ S ∈ insert a F, survives S ω) ≤ Prob p (fun ω => survives a ω) + Prob p (fun ω => ∃ S ∈ F, survives S ω) := by
      convert prob_union_le hp0 hp1 _ _ using 2 ; aesop;
    rw [ Finset.sum_insert hF ] ; linarith [ prob_survives p a ] ;

/--
The expected number of retained edges equals `p · |E|`.  Interpreting `ι` as
the edge set, this is the exact linear scaling of the surviving average degree.
-/
theorem exp_retained_edges (p : ℝ) :
    ∑ ω : ι → Bool, weight p ω *
        ((Finset.univ.filter (fun e => ω e = true)).card : ℝ)
      = p * (Fintype.card ι : ℝ) := by
  -- For each fixed `e`, `∑ ω, weight p ω * (if ω e = true then 1 else 0) = ∑ ω, (if ω e = true then weight p ω else 0) = Prob p (survives {e}) = p ^ ({e}.card) = p ^ 1 = p`, using that `survives {e} ω ↔ ω e = true` (unfold `survives`, `Finset.forall_mem_singleton`) and `prob_survives`.
  have h_fixed_e : ∀ e : ι, ∑ ω : ι → Bool, ( PersistentCycles.weight p ω ) * (if ω e then 1 else 0) = p := by
    intro e;
    convert PersistentCycles.prob_survives p { e } using 1;
    · exact Finset.sum_congr rfl fun _ _ => by unfold survives; aesop;
    · simp +decide;
  convert Finset.sum_congr rfl fun e _ => h_fixed_e e using 1;
  rw [ Finset.sum_comm ];
  simp +decide [ Finset.sum_ite ];
  exacts [ Finset.sum_congr rfl fun _ _ => mul_comm _ _, by simp +decide [ mul_comm ] ]

/--
**Contrarian disproof.**  A *single fixed* cycle does **not** persist: for
any retention probability `p < 1`, the probability that a specified edge set of
size `L` (e.g. one prescribed Hamiltonian cycle on `L` edges) survives tends to
`0` as `L → ∞`.  Formally the probability equals `p ^ L → 0`.  Hence the naive
conjecture "every fixed long cycle survives a.a.s." is false.
-/
theorem single_structure_fragility {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p < 1) :
    Filter.Tendsto
      (fun L : ℕ => Prob (ι := Fin L) p (survives Finset.univ))
      Filter.atTop (nhds 0) := by
  convert tendsto_pow_atTop_nhds_zero_of_lt_one hp0 hp1 |> Filter.Tendsto.comp <| Filter.tendsto_id using 2 ; norm_num [ prob_survives ]

end PersistentCycles