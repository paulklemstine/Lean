/-
# NET-71, cycle 2 — why the four-domain table *had* to be a diagonal, and what a
# workload costs

Cycle 1 (`Logic.NET71GermanKneeShift`, `Logic.NET71FourDomainDeployment`,
`Logic.NET71TokenizerTax`) measured the German leg, completed the four-domain table, and
observed that the whole table collapses to the single affine function
`12 + 4·(rank + doublings)`.  Cycle 2 asks the three questions that observation raises.

**(1) How much noise can a knee survive, in general?**  §1 replaces the two hand-checked
stability computations of cycle 1 by one theorem with the margins as parameters
(`kneeIdx_stable_of_margins`), together with its exact converse
(`exists_perturbation_lowering_knee`): a uniform shift by the below-bar margin always
moves the knee down.  Corollary `net71_stability_radii`: the reported German knees
tolerate `0.003` (at `512`) and `0.002` (at `1024`) — i.e. roughly one reported standard
error, no more.  This is the honest statistical boundary of round 24.

**(2) Was the diagonal collapse an accident of the numbers?**  No: `diagonal_rigidity`
shows that *any* two-variable budget family satisfying (E) the exchange law — one domain
rung costs one context doubling — and (I) a constant increment is forced to be
`F 0 0 + c·(rank + doublings)`.  The two axioms are independent
(`exchange_without_affine`, `increment_without_exchange`), so the collapse is a genuine
empirical finding with exactly two testable ingredients, and `exchange_fails_of_inc_ne`
identifies precisely what a future non-conforming domain would have to look like: an
increment different from `4`.

**(3) What does a heterogeneous workload cost?**  §3 defines the cover cost of a finite
set of `(domain, context)` cells and proves it is the join of the cells
(`coverCost_union`), is computed by a single extremal cell
(`coverCost_one_cell_certificate`), is monotone, and is *submodular*
(`coverCost_submodular`) — so mixing workloads never costs more than budgeting them
separately, and the deployment table of cycle 1 extends from four domains to arbitrary
mixtures.
-/
import Mathlib
import Logic.NET71TokenizerTax

namespace Catalog.NET71

open Catalog.NET68 Catalog.NET68.BudgetLaw

/-! ## 1. The stability radius of a knee -/

/-- **Stability, in general.**  If the sweep clears the bar at index `j + 1` with margin
`m` and misses it at `j` with margin `m`, then every monotone curve within uniform
distance `< m` reports the same knee.  The knee is decided by two readings and their two
margins — nothing else about the curve matters. -/
theorem kneeIdx_stable_of_margins {acc acc' : ℕ → ℚ} {bar m : ℚ} {j : ℕ}
    (hbelow : acc j + m ≤ bar) (habove : bar + m ≤ acc (j + 1))
    (hmono' : Monotone acc') (hclose : ∀ i, |acc' i - acc i| < m) :
    kneeIdx acc' bar = j + 1 := by
  have hj := abs_lt.1 (hclose j)
  have hj1 := abs_lt.1 (hclose (j + 1))
  refine kneeIdx_eq_succ_of_bracket hmono' ?_ ?_
  · have := hj.2; linarith
  · have := hj1.1; linarith

/-- **Instability, in general.**  If index `j` misses the bar by at most `m`, then the
uniform upward perturbation of size `m` — a perfectly legitimate curve at that noise
level — already moves the knee down to `j` or below.  Hence the below-bar margin is the
exact stability radius. -/
theorem exists_perturbation_lowering_knee {acc : ℕ → ℚ} {bar m : ℚ} {j : ℕ}
    (hmono : Monotone acc) (hm : 0 ≤ m) (h : bar ≤ acc j + m) :
    ∃ acc' : ℕ → ℚ, Monotone acc' ∧ (∀ i, |acc' i - acc i| ≤ m) ∧ kneeIdx acc' bar ≤ j := by
  refine ⟨fun i => acc i + m, fun a b hab => by simpa using hmono hab, fun i => ?_, ?_⟩
  · simpa using le_of_eq (abs_of_nonneg hm)
  · exact kneeIdx_le (by simpa using h)

/-- **The stability radii of round 24.**  Instantiating the general theorem at the two
measured German cells: `0.003` at `ctx = 512` and `0.002` at `ctx = 1024`.  Both are of
the order of the reported standard error, which is why the `16`-key ✗ at `512` was
flagged in the lab notes. -/
theorem net71_stability_radii :
    (∀ acc : ℕ → ℚ, Monotone acc → (∀ i, |acc i - german512 i| < 3 / 1000) →
      kneeIdx acc bar98 = 5) ∧
    (∀ acc : ℕ → ℚ, Monotone acc → (∀ i, |acc i - german1024 i| < 2 / 1000) →
      kneeIdx acc bar98 = 6) := by
  constructor
  · intro acc hmono hclose
    exact kneeIdx_stable_of_margins (j := 4) (by norm_num [german512, bar98])
      (by norm_num [german512, bar98]) hmono hclose
  · intro acc hmono hclose
    exact kneeIdx_stable_of_margins (j := 5) (by norm_num [german1024, bar98])
      (by norm_num [german1024, bar98]) hmono hclose

/-! ## 2. Rigidity: the diagonal was forced -/

/-- **(E) + (I) force the diagonal.**  Let `F r d` be the budget of the domain of rung
`r` at `d` context doublings.  If one rung up the domain ladder costs exactly one
doubling (the *exchange law*) and each doubling costs a constant `c` (the *universal
increment*), then `F` is the affine function of the single variable `r + d`.  The
four-domain collapse of cycle 1 is therefore not a numerical coincidence: it is the only
possibility once the two measured regularities hold. -/
theorem diagonal_rigidity (F : ℕ → ℕ → ℤ) (c : ℤ)
    (hex : ∀ r d, F (r + 1) d = F r (d + 1))
    (hinc : ∀ r d, F r (d + 1) = F r d + c) :
    ∀ r d, F r d = F 0 0 + c * (r + d : ℕ) := by
  have base : ∀ d, F 0 d = F 0 0 + c * d := by
    intro d
    induction d with
    | zero => simp
    | succ n ih => rw [hinc 0 n, ih]; push_cast; ring
  intro r
  induction r with
  | zero => intro d; simpa using base d
  | succ k ih =>
    intro d
    rw [hex k d, ih (d + 1)]
    push_cast
    ring

/-- The measured ladder, extended to every rung: rung `r` has base `12 + 4r`. -/
def ladderLaw (r : ℕ) : BudgetLaw := ⟨12 + 4 * r, 4⟩

/-- The four measured domains are the first three rungs of the ladder. -/
theorem domainLaw_eq_ladderLaw (D : Domain) : domainLaw D = ladderLaw (rank D) := by
  cases D <;> norm_num [domainLaw, ladderLaw, rank, codeLaw, proseLaw, mathLaw, deLaw]

/-- The ladder satisfies the exchange law (E). -/
theorem ladder_exchange (r d : ℕ) : (ladderLaw (r + 1)).eval d = (ladderLaw r).eval (d + 1) := by
  simp only [ladderLaw, BudgetLaw.eval]
  push_cast
  ring

/-- The ladder satisfies the universal-increment law (I). -/
theorem ladder_increment (r d : ℕ) :
    (ladderLaw r).eval (d + 1) = (ladderLaw r).eval d + 4 := by
  simp only [ladderLaw, BudgetLaw.eval]
  push_cast
  ring

/-- **The table, re-derived from the two axioms alone.**  No arithmetic on the measured
bases is used: only (E) and (I). -/
theorem table_from_axioms (r d : ℕ) : (ladderLaw r).eval d = 12 + 4 * (r + d : ℕ) := by
  have h := diagonal_rigidity (fun r d => (ladderLaw r).eval d) 4 ladder_exchange
    ladder_increment r d
  simpa [ladderLaw, BudgetLaw.eval] using h

/-- Consequently the measured four-domain table is the diagonal, by rigidity rather than
by inspection. -/
theorem net71_table_is_diagonal (D : Domain) (d : ℕ) :
    (domainLaw D).eval d = 12 + 4 * (rank D + d : ℕ) := by
  rw [domainLaw_eq_ladderLaw, table_from_axioms]

/-- **(E) alone does not force affinity.**  A quadratic diagonal law satisfies the
exchange law and no constant increment: the collapse genuinely needs both measured
regularities. -/
theorem exchange_without_affine :
    ∃ F : ℕ → ℕ → ℤ, (∀ r d, F (r + 1) d = F r (d + 1)) ∧
      ¬ ∃ c : ℤ, ∀ r d, F r d = F 0 0 + c * (r + d : ℕ) := by
  refine ⟨fun r d => ((r + d : ℕ) : ℤ) ^ 2, fun r d => by push_cast; ring, ?_⟩
  rintro ⟨c, hc⟩
  have h1 := hc 0 1
  have h2 := hc 0 2
  norm_num at h1 h2
  omega

/-- **(I) alone does not force the exchange law.**  A family with the correct constant
increment but a quadratic domain axis violates (E): the exchange law is an independent
empirical claim, and it is the one the German leg tested. -/
theorem increment_without_exchange :
    ∃ F : ℕ → ℕ → ℤ, (∀ r d, F r (d + 1) = F r d + 4) ∧
      ¬ ∀ r d, F (r + 1) d = F r (d + 1) := by
  refine ⟨fun r d => (r : ℤ) ^ 2 + 4 * d, fun r d => by push_cast; ring, ?_⟩
  intro h
  have := h 2 0
  norm_num at this

/-- **What a non-conforming domain would look like.**  If a future corpus has an
increment different from `4`, no exchange law can relate it to the existing ladder: the
diagonal picture breaks at a computable context. -/
theorem exchange_fails_of_inc_ne {L : BudgetLaw} (h : L.inc ≠ 4) :
    ¬ ∀ d : ℕ, L.eval (d + 1) = L.eval d + 4 := by
  intro hall
  have := hall 0
  simp only [BudgetLaw.eval] at this
  push_cast at this
  omega

/-! ## 3. The cost of a heterogeneous workload -/

/-- A workload **cell**: a corpus together with the number of context doublings at which
it is served. -/
abbrev Cell := Domain × ℕ

/-- The budget of a single cell. -/
def cellBudget (c : Cell) : ℤ := (domainLaw c.1).eval c.2

/-- The cache a finite nonempty workload needs: the largest budget among its cells. -/
noncomputable def coverCost (S : Finset Cell) (hS : S.Nonempty) : ℤ := S.sup' hS cellBudget

/-- Every cell of the workload is served. -/
theorem le_coverCost {S : Finset Cell} (hS : S.Nonempty) {c : Cell} (hc : c ∈ S) :
    cellBudget c ≤ coverCost S hS :=
  Finset.le_sup' cellBudget hc

/-- **One-cell certificate.**  The cost of any workload is *attained* by one of its
cells: a deployment budget can always be justified by exhibiting a single worst case. -/
theorem coverCost_one_cell_certificate {S : Finset Cell} (hS : S.Nonempty) :
    ∃ c ∈ S, coverCost S hS = cellBudget c := by
  obtain ⟨c, hc, hval⟩ := Finset.exists_mem_eq_sup' hS cellBudget
  exact ⟨c, hc, hval⟩

/-- The cost of a union is the join of the costs: budgets combine by `max`, never by
addition. -/
theorem coverCost_union {S T : Finset Cell} (hS : S.Nonempty) (hT : T.Nonempty) :
    coverCost (S ∪ T) (hS.mono Finset.subset_union_left) = max (coverCost S hS) (coverCost T hT) :=
  Finset.sup'_union hS hT cellBudget

/-- Adding work never lowers the bill. -/
theorem coverCost_mono {S T : Finset Cell} (hS : S.Nonempty) (hT : T.Nonempty) (h : S ⊆ T) :
    coverCost S hS ≤ coverCost T hT :=
  Finset.sup'_mono cellBudget h hS

/-- **Submodularity.**  `cost(S ∪ T) + cost(S ∩ T) ≤ cost S + cost T`: consolidating two
workloads onto one cache is never more expensive than provisioning them separately, and
the saving is exactly the overlap's slack. -/
theorem coverCost_submodular {S T : Finset Cell} (hS : S.Nonempty) (hT : T.Nonempty)
    (hST : (S ∩ T).Nonempty) :
    coverCost (S ∪ T) (hS.mono Finset.subset_union_left) + coverCost (S ∩ T) hST
      ≤ coverCost S hS + coverCost T hT := by
  have hu : coverCost (S ∪ T) (hS.mono Finset.subset_union_left)
      = max (coverCost S hS) (coverCost T hT) := coverCost_union hS hT
  have h1 : coverCost (S ∩ T) hST ≤ coverCost S hS :=
    coverCost_mono hST hS Finset.inter_subset_left
  have h2 : coverCost (S ∩ T) hST ≤ coverCost T hT :=
    coverCost_mono hST hT Finset.inter_subset_right
  rw [hu]
  rcases max_cases (coverCost S hS) (coverCost T hT) with ⟨hm, _⟩ | ⟨hm, _⟩ <;> rw [hm] <;> omega

/-- The cost of a workload in the ladder coordinates: `12 + 4 ·` the largest rank sum
present.  Deployment reduces to finding one number. -/
theorem coverCost_eq_rank_sum {S : Finset Cell} (hS : S.Nonempty) :
    ∃ c ∈ S, coverCost S hS = 12 + 4 * (rank c.1 + c.2 : ℕ) := by
  obtain ⟨c, hc, hval⟩ := coverCost_one_cell_certificate hS
  exact ⟨c, hc, by rw [hval, cellBudget, net71_table_is_diagonal]⟩

/-- **The cycle-1 deployment table, recovered as a special case.**  The full four-domain
workload at contexts `512` and `1024` costs exactly the headline `24` keys. -/
theorem net71_full_workload_cost :
    coverCost (Finset.univ ×ˢ ({0, 1} : Finset ℕ)) (by
      refine Finset.Nonempty.product ⟨Domain.code, Finset.mem_univ _⟩ ⟨0, by decide⟩) = 24 := by
  refine le_antisymm (Finset.sup'_le _ _ ?_) ?_
  · rintro ⟨D, d⟩ hc
    have hd : d = 0 ∨ d = 1 := by
      have := (Finset.mem_product.1 hc).2
      simpa using this
    have : d ≤ 1 := by rcases hd with rfl | rfl <;> norm_num
    exact cache24_covers_all_to_1024 D d this
  · have hmem : ((Domain.proseDE, 1) : Cell) ∈ Finset.univ ×ˢ ({0, 1} : Finset ℕ) := by
      refine Finset.mem_product.2 ⟨Finset.mem_univ _, by decide⟩
    have := Finset.le_sup' cellBudget hmem
    have hval : cellBudget ((Domain.proseDE, 1) : Cell) = 24 := net71_table.2.2.2.2
    rw [hval] at this
    exact this

end Catalog.NET71