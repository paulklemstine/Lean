/-
# The Reversible Verification Space–Heat Frontier

Future Direction 3 of the "Proof Complexity and Thermodynamic Cost" thread conjectured
that every finite proof verifier admits a reversible implementation with arbitrarily small
dissipated heat, at the price of a *history register*, and that the minimal history
capacity is controlled by the **largest verification fiber**.  This file proves exactly
that, in sharp (iff) form.

## Set-up

A finite verifier is a map `f : α → β` between finite types (input = (statement, proof)
pair or intermediate machine configuration; output = the retained result).  Its
**fibers** `fiber f b = f⁻¹(b)` are the sets of computational histories that the verifier
merges.  A *history register* of capacity `m` is a map `h : α → Fin m`; the
implementation `x ↦ (f x, h x)` is *reversible* precisely when it is injective.

## Main results

* `card_le_imageCard_mul_maxFiber` — the counting backbone: `|α| ≤ |im f| · maxFiber f`.
* `reversible_history_iff` — **the frontier, sharp form**: a history register of capacity
  `m` makes the verifier reversible **iff** `maxFiber f ≤ m`.  Fiber multiplicity is
  exactly the required ancillary memory.
* `erasedBits_reversible_implementation` — the reversible implementation erases **zero**
  bits, hence (`landauerCost_reversible_eq_zero`) dissipates no Landauer heat at any
  temperature: irreversibility, not computation, is what costs.
* `erasedBits_le_logb_maxFiber` — **memory–dissipation inequality**: the information the
  irreversible verifier destroys never exceeds `log₂` of the history capacity that would
  have saved it.  Erased heat is bounded by retained memory.
* `landauerCost_le_history_capacity` — the same statement in physical units: dissipated
  heat `≤ (history bits) · k_B T ln 2`.
* `constant_verifier_maxFiber` / `total_collapse_needs_full_history` — sharpness: a
  verifier that merges everything needs a history register as large as its entire input
  space, and then the inequality above is an equality (`erasedBits_constant_eq_logb`).

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): "logical information loss" (the entropy drop `erasedBits`) and
  "ancillary memory needed for reversibility" are two readings of one combinatorial
  quantity, the largest fiber.
Experiment (Stage 2): proved both directions of `reversible_history_iff`.  The hard
  direction is constructive: index each element of `α` by how many elements of its own
  fiber precede it in a fixed enumeration `Fintype.equivFin`; this rank function is a
  history register of capacity exactly `maxFiber f`.
Analysis (Stage 3): the two directions have different characters.  `→` is a one-line
  pigeonhole on a single fiber; `←` needs a *uniform* choice of intra-fiber index, which
  the rank construction supplies without any choice principle.  The bridge to
  thermodynamics is the multiplicative counting bound `|α| ≤ |im f| · maxFiber f`, which
  becomes additive after `log₂`.
Critique (Stage 4): the inequality `erasedBits f ≤ log₂ (maxFiber f)` is *not* an
  equality in general (unequal fibers make the left side smaller), so we prove the
  equality only in the sharp constant-verifier case; this is the honest boundary of the
  conjecture.  The `Nonempty α` hypotheses are load-bearing: for empty `α` the entropy
  `log₂ 0` conventions would make the statements meaningless rather than false.
Synthesis (Stage 5): the space–heat frontier for finite verifiers is exactly
  `history capacity ≥ maxFiber f`, and Landauer dissipation is squeezed underneath
  `log₂` of that capacity.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof

open Finset Real ThermoProof

namespace ReversibleFrontier

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- The verification fiber over `b`: all computational histories the verifier merges into
the single output `b`. -/
def fiber (f : α → β) (b : β) : Finset α := Finset.univ.filter (fun x => f x = b)

omit [DecidableEq α] [Fintype β] in
@[simp] lemma mem_fiber {f : α → β} {b : β} {x : α} : x ∈ fiber f b ↔ f x = b := by
  simp [fiber]

/-- The **largest verification fiber**: the maximal multiplicity with which the verifier
merges distinct histories. -/
def maxFiber (f : α → β) : ℕ := Finset.univ.sup (fun b => (fiber f b).card)

omit [DecidableEq α] in
lemma card_fiber_le_maxFiber (f : α → β) (b : β) : (fiber f b).card ≤ maxFiber f :=
  Finset.le_sup (f := fun b => (fiber f b).card) (Finset.mem_univ b)

omit [DecidableEq α] in
lemma maxFiber_pos [Nonempty α] (f : α → β) : 0 < maxFiber f := by
  obtain ⟨x⟩ := (inferInstance : Nonempty α)
  have hx : x ∈ fiber f (f x) := by simp
  exact lt_of_lt_of_le (Finset.card_pos.2 ⟨x, hx⟩) (card_fiber_le_maxFiber f (f x))

omit [DecidableEq α] in
lemma maxFiber_le_card (f : α → β) : maxFiber f ≤ Fintype.card α := by
  refine Finset.sup_le fun b _ => ?_
  simpa [Finset.card_univ] using Finset.card_le_card (Finset.subset_univ (fiber f b))

/-- **The counting backbone.**  The input space is covered by the fibers over the image,
so `|α| ≤ |im f| · maxFiber f`. -/
theorem card_le_imageCard_mul_maxFiber (f : α → β) :
    Fintype.card α ≤ imageCard f * maxFiber f := by
  classical
  have hcover : (Finset.univ : Finset α) ⊆
      (Finset.univ.image f).biUnion (fun b => fiber f b) := by
    intro x _
    exact Finset.mem_biUnion.2 ⟨f x, Finset.mem_image_of_mem f (Finset.mem_univ x), by simp⟩
  calc Fintype.card α = (Finset.univ : Finset α).card := by simp [Finset.card_univ]
    _ ≤ ((Finset.univ.image f).biUnion (fun b => fiber f b)).card := Finset.card_le_card hcover
    _ ≤ ∑ b ∈ Finset.univ.image f, (fiber f b).card := Finset.card_biUnion_le
    _ ≤ ∑ _b ∈ Finset.univ.image f, maxFiber f :=
        Finset.sum_le_sum (fun b _ => card_fiber_le_maxFiber f b)
    _ = imageCard f * maxFiber f := by simp [imageCard]

/-! ## The space–heat frontier -/

/-- The **rank register**: index each history by the number of members of its own fiber
that precede it in a fixed enumeration of `α`.  This is the canonical minimal history
register. -/
noncomputable def rankRegister (f : α → β) (x : α) : ℕ :=
  ((fiber f (f x)).filter
    (fun y => (Fintype.equivFin α y : ℕ) < (Fintype.equivFin α x : ℕ))).card

omit [DecidableEq α] in
lemma rankRegister_lt (f : α → β) (x : α) : rankRegister f x < maxFiber f := by
  have hss : (fiber f (f x)).filter
      (fun y => (Fintype.equivFin α y : ℕ) < (Fintype.equivFin α x : ℕ)) ⊂ fiber f (f x) := by
    refine Finset.ssubset_iff_of_subset (Finset.filter_subset _ _) |>.2 ⟨x, by simp, ?_⟩
    simp
  exact lt_of_lt_of_le (Finset.card_lt_card hss) (card_fiber_le_maxFiber f (f x))

omit [Fintype β] in
/-- The rank register separates every fiber: pairing the verifier's output with the rank
is injective. -/
theorem rankRegister_pairing_injective (f : α → β) :
    Function.Injective (fun x => (f x, rankRegister f x)) := by
  intro x y hxy
  simp only [Prod.mk.injEq] at hxy
  obtain ⟨hf, hr⟩ := hxy
  by_contra hne
  -- the enumeration ranks of `x` and `y` are distinct
  have hidx : (Fintype.equivFin α x : ℕ) ≠ (Fintype.equivFin α y : ℕ) := by
    intro h
    exact hne ((Fintype.equivFin α).injective (Fin.ext h))
  -- WLOG the one with smaller rank has strictly smaller count
  have key : ∀ u v : α, f u = f v → (Fintype.equivFin α u : ℕ) < (Fintype.equivFin α v : ℕ) →
      rankRegister f u < rankRegister f v := by
    intro u v huv hlt
    have hsub : (fiber f (f u)).filter
        (fun y => (Fintype.equivFin α y : ℕ) < (Fintype.equivFin α u : ℕ)) ⊂
        (fiber f (f v)).filter
        (fun y => (Fintype.equivFin α y : ℕ) < (Fintype.equivFin α v : ℕ)) := by
      refine Finset.ssubset_iff_of_subset (fun z hz => ?_) |>.2 ⟨u, ?_, ?_⟩
      · rw [Finset.mem_filter] at hz ⊢
        exact ⟨by rw [mem_fiber] at hz ⊢; rw [← huv]; exact hz.1, lt_trans hz.2 hlt⟩
      · rw [Finset.mem_filter]
        exact ⟨by simp [huv], hlt⟩
      · simp
    exact Finset.card_lt_card hsub
  rcases lt_or_gt_of_ne hidx with h | h
  · exact absurd hr (Nat.ne_of_lt (key x y hf h))
  · exact absurd hr.symm (Nat.ne_of_lt (key y x hf.symm h))

/-- **The reversible verification space–heat frontier (sharp form).**  A history register
of capacity `m` renders the finite verifier `f` logically reversible **iff** `m` is at
least the size of the largest verification fiber. -/
theorem reversible_history_iff (f : α → β) (m : ℕ) :
    (∃ h : α → Fin m, Function.Injective (fun x => (f x, h x))) ↔ maxFiber f ≤ m := by
  constructor
  · rintro ⟨h, hinj⟩
    refine Finset.sup_le fun b _ => ?_
    have hmap : ∀ x ∈ fiber f b, h x ∈ (Finset.univ : Finset (Fin m)) := by simp
    have hinjOn : ∀ x ∈ fiber f b, ∀ y ∈ fiber f b, h x = h y → x = y := by
      intro x hx y hy hxy
      rw [mem_fiber] at hx hy
      exact hinj (by simp [hx, hy, hxy])
    calc (fiber f b).card ≤ (Finset.univ : Finset (Fin m)).card :=
          Finset.card_le_card_of_injOn h hmap hinjOn
      _ = m := by simp
  · intro hm
    refine ⟨fun x => ⟨rankRegister f x, lt_of_lt_of_le (rankRegister_lt f x) hm⟩, ?_⟩
    intro x y hxy
    simp only [Prod.mk.injEq, Fin.mk.injEq] at hxy
    exact rankRegister_pairing_injective f (by simp [hxy.1, hxy.2])

/-- The minimal history capacity `maxFiber f` is achievable. -/
theorem exists_reversible_history (f : α → β) :
    ∃ h : α → Fin (maxFiber f), Function.Injective (fun x => (f x, h x)) :=
  (reversible_history_iff f (maxFiber f)).2 le_rfl

omit [DecidableEq α] [Fintype β] in
/-- **Zero dissipation of the reversible implementation.**  Any history register making the
verifier injective erases exactly zero bits. -/
theorem erasedBits_reversible_implementation [Nonempty α] (f : α → β) {m : ℕ}
    (h : α → Fin m) (hinj : Function.Injective (fun x => (f x, h x))) :
    erasedBits (fun x => (f x, h x)) = 0 :=
  (erasedBits_eq_zero_iff_injective _).2 hinj

omit [DecidableEq α] [Fintype β] in
/-- Physically: the reversible implementation dissipates no Landauer heat, at any
temperature. -/
theorem landauerCost_reversible_eq_zero [Nonempty α] (f : α → β) {m : ℕ}
    (h : α → Fin m) (hinj : Function.Injective (fun x => (f x, h x))) (kB T : ℝ) :
    landauerCost (erasedBits (fun x => (f x, h x))) kB T = 0 := by
  rw [erasedBits_reversible_implementation f h hinj]
  simp [landauerCost]

/-! ## The memory–dissipation inequality -/

/-- **Memory–dissipation inequality.**  The information destroyed by an irreversible
verifier is at most `log₂` of the history capacity that would have preserved it: erased
heat is controlled by the largest fiber. -/
theorem erasedBits_le_logb_maxFiber [Nonempty α] (f : α → β) :
    erasedBits f ≤ Real.logb 2 (maxFiber f) := by
  have hI : (0:ℕ) < imageCard f := imageCard_pos f
  have hM : (0:ℕ) < maxFiber f := maxFiber_pos f
  have hcount : (Fintype.card α : ℝ) ≤ (imageCard f : ℝ) * (maxFiber f : ℝ) := by
    exact_mod_cast card_le_imageCard_mul_maxFiber f
  have hIR : (0:ℝ) < (imageCard f : ℝ) := by exact_mod_cast hI
  have hMR : (0:ℝ) < (maxFiber f : ℝ) := by exact_mod_cast hM
  have hαR : (0:ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast this
  have hlog : Real.logb 2 (Fintype.card α) ≤
      Real.logb 2 ((imageCard f : ℝ) * (maxFiber f : ℝ)) :=
    (Real.logb_le_logb (b := 2) (by norm_num) hαR (by positivity)).2 hcount
  rw [Real.logb_mul (ne_of_gt hIR) (ne_of_gt hMR)] at hlog
  unfold erasedBits
  linarith

/-- The same bound in physical units: at temperature `T` the heat dissipated by the
irreversible verifier is at most `(history bits) · k_B T ln 2`. -/
theorem landauerCost_le_history_capacity [Nonempty α] (f : α → β) {kB T : ℝ}
    (hk : 0 ≤ kB) (hT : 0 ≤ T) :
    landauerCost (erasedBits f) kB T ≤ landauerCost (Real.logb 2 (maxFiber f)) kB T := by
  unfold landauerCost
  have hlog : (0:ℝ) ≤ Real.log 2 := le_of_lt (Real.log_pos (by norm_num))
  have hfac : (0:ℝ) ≤ kB * T * Real.log 2 := by positivity
  exact mul_le_mul_of_nonneg_right (erasedBits_le_logb_maxFiber f) hfac

/-! ## Sharpness: total collapse needs a full history -/

omit [DecidableEq α] in
/-- A verifier that returns the same answer on every input has one fiber, of full size. -/
theorem constant_verifier_maxFiber [Nonempty α] [Nonempty β] (c : β) :
    maxFiber (fun _ : α => c) = Fintype.card α := by
  refine le_antisymm (maxFiber_le_card _) ?_
  have h : fiber (fun _ : α => c) c = Finset.univ := by
    ext x; simp
  calc Fintype.card α = (fiber (fun _ : α => c) c).card := by rw [h]; simp [Finset.card_univ]
    _ ≤ maxFiber (fun _ : α => c) := card_fiber_le_maxFiber _ c

/-- **Sharpness of the frontier.**  Making a totally collapsing verifier reversible requires
a history register with as many states as the whole input space — no compression of the
history is possible. -/
theorem total_collapse_needs_full_history [Nonempty α] [Nonempty β] (c : β) (m : ℕ)
    (h : ∃ g : α → Fin m, Function.Injective (fun x => ((fun _ : α => c) x, g x))) :
    Fintype.card α ≤ m := by
  have := (reversible_history_iff (fun _ : α => c) m).1 h
  rwa [constant_verifier_maxFiber (α := α) c] at this

omit [DecidableEq α] in
/-- For a totally collapsing verifier the memory–dissipation inequality is an **equality**:
every retained history bit is a bit that would otherwise have been dissipated. -/
theorem erasedBits_constant_eq_logb [Nonempty α] [Nonempty β] (c : β) :
    erasedBits (fun _ : α => c) = Real.logb 2 (maxFiber (fun _ : α => c)) := by
  rw [constant_verifier_maxFiber (α := α) c, erasedBits_const]

end ReversibleFrontier