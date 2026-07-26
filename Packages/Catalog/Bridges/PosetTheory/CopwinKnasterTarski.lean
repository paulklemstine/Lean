/-
# A bridge: finite cop-win pruning ↔ Knaster–Tarski greatest fixed points

Implementations of the `k`-copwin recognition algorithm repeatedly *prune* a
finite candidate set of positions, deleting those that fail a local survival
test.  Two facts drive every such implementation:

* each round returns a **subset** of the current state space (the update is
  *contracting*), and
* refining the input can only refine the output (the update is *monotone*).

Under these two hypotheses the algorithm terminates and returns a distinguished
fixed candidate set.  This file proves that this *algorithmic* object is exactly
an *order-theoretic* object from lattice theory: the **greatest fixed point**
(à la Knaster–Tarski) of an associated monotone endomorphism of the complete
lattice `Set α`.

This is a genuine cross-domain bridge:

* **Left side (combinatorics / algorithm termination).**  A contracting update
  `F : Finset α → Finset α` iterated by `rounds` reaches a fixed point in at
  most `|S|` steps (`exists_fixed_round_le_card`), and that fixed point is the
  greatest fixed candidate set below `S` (`exists_greatest_fixed_kernel`).

* **Right side (order theory / fixed-point theory).**  On the complete lattice
  `Set α`, the map `G F S` is a bona fide `OrderHom`, and Mathlib's
  `OrderHom.gfp` gives its greatest fixed point via Knaster–Tarski.

* **The bridge.**  `gfp_eq_kernel` shows the coercion of the algorithmic kernel
  equals `OrderHom.gfp (G F S)`, and `gfp_computed_by_finite_iteration`
  strengthens this to: the abstract greatest fixed point is *computed* by the
  concrete finite pruning loop within `|S|` rounds.

The file is self-contained (depends only on Mathlib).
-/

import Mathlib

open Classical Finset

namespace CopwinKT

variable {α : Type*}

/-! ### The algorithmic side: finite pruning -/

/-- Iteration of one pruning round. -/
def rounds (F : Finset α → Finset α) : ℕ → Finset α → Finset α
  | 0, S => S
  | n + 1, S => F (rounds F n S)

/-- A contracting update never introduces a candidate. -/
def Contracting (F : Finset α → Finset α) : Prop := ∀ S, F S ⊆ S

/-- A monotone update preserves inclusion of candidate sets. -/
def MonotoneUpdate (F : Finset α → Finset α) : Prop := ∀ ⦃S T⦄, S ⊆ T → F S ⊆ F T

/-- Each later round is contained in the previous one. -/
lemma rounds_succ_subset (F : Finset α → Finset α) (hF : Contracting F) (n : ℕ) (S : Finset α) :
    rounds F (n + 1) S ⊆ rounds F n S := hF _

/-- Every round stays inside the initial candidate set. -/
lemma rounds_subset (F : Finset α → Finset α) (hF : Contracting F) (n : ℕ) (S : Finset α) :
    rounds F n S ⊆ S := by
  induction n with
  | zero => exact subset_rfl
  | succ n ih => exact (rounds_succ_subset F hF n S).trans ih

/-- If the first `n` rounds all change the candidate set, at least `n`
candidates have disappeared. -/
lemma card_rounds_add_le (F : Finset α → Finset α) (hF : Contracting F) (S : Finset α) (n : ℕ)
    (hchange : ∀ i < n, rounds F (i + 1) S ≠ rounds F i S) :
    (rounds F n S).card + n ≤ S.card := by
  induction' n with n ih <;> simp_all +decide [ rounds ]
  have h_card : #(F (rounds F n S)) < #(rounds F n S) :=
    Finset.card_lt_card ( lt_of_le_of_ne ( hF _ ) ( hchange _ le_rfl ) )
  linarith [ ih fun i hi => hchange i hi.le ]

/-- **Sharp finite stabilization.** Every contracting finite-state pruning
algorithm reaches a fixed point in at most as many rounds as there are initial
candidates. -/
theorem exists_fixed_round_le_card (F : Finset α → Finset α) (hF : Contracting F) (S : Finset α) :
    ∃ n ≤ S.card, rounds F (n + 1) S = rounds F n S := by
  by_contra! h
  convert card_rounds_add_le F hF S ( S.card + 1 ) _ using 1
  · grind
  · exact fun i hi => h i ( Nat.le_of_lt_succ hi )

/-- A fixed set contained in the candidates survives every round of monotone
pruning. -/
lemma fixed_subset_rounds (F : Finset α → Finset α) (hmono : MonotoneUpdate F)
    {T S : Finset α} (hfix : F T = T) (hTS : T ⊆ S) (n : ℕ) : T ⊆ rounds F n S := by
  induction' n with n ih
  · exact hTS
  · exact hfix ▸ hmono ih

/-- **Greatest fixed-kernel.** For a contracting monotone update, the bounded
stabilization result computes the greatest fixed candidate set below `S`. -/
theorem exists_greatest_fixed_kernel (F : Finset α → Finset α)
    (hcontract : Contracting F) (hmono : MonotoneUpdate F) (S : Finset α) :
    ∃ K ⊆ S, F K = K ∧ ∀ T ⊆ S, F T = T → T ⊆ K := by
  obtain ⟨ n, _, h ⟩ := exists_fixed_round_le_card F hcontract S
  exact ⟨rounds F n S, rounds_subset F hcontract n S, h,
    fun T hTS hT => fixed_subset_rounds F hmono hT hTS n⟩

/-! ### The order-theoretic side: a monotone map on the complete lattice `Set α` -/

/-- The pruning update lifted to a monotone endomorphism of the complete
lattice `Set α`: it restricts a set of vertices to the finite candidates in `S`,
then applies the finite update. -/
noncomputable def G (F : Finset α → Finset α) (S : Finset α) (hmono : MonotoneUpdate F) :
    Set α →o Set α where
  toFun X := ↑(F (S.filter (fun a => a ∈ X)))
  monotone' := by
    intro X Y hXY
    apply Finset.coe_subset.mpr
    apply hmono
    intro a ha
    rw [Finset.mem_filter] at *
    exact ⟨ha.1, hXY ha.2⟩

@[simp] lemma G_apply (F : Finset α → Finset α) (S : Finset α) (hmono : MonotoneUpdate F)
    (X : Set α) : G F S hmono X = ↑(F (S.filter (fun a => a ∈ X))) := rfl

/-- On a fixed kernel `T ⊆ S`, the lattice map `G` fixes `↑T`. -/
lemma G_fixes_kernel (F : Finset α → Finset α) (S : Finset α) (hmono : MonotoneUpdate F)
    {T : Finset α} (hTS : T ⊆ S) (hfix : F T = T) :
    G F S hmono (↑T) = ↑T := by
  have hfilt : S.filter (fun a => a ∈ (↑T : Set α)) = T := by
    ext a
    rw [Finset.mem_filter, Finset.mem_coe]
    exact ⟨fun h => h.2, fun h => ⟨hTS h, h⟩⟩
  rw [G_apply, Finset.filter_congr_decidable, hfilt, hfix]

/-! ### The bridge -/

/-- **Cross-domain bridge.** For a contracting, monotone finite pruning update
`F` and finite candidate set `S`, the coercion of the greatest fixed kernel `K`
equals the Knaster–Tarski greatest fixed point of the associated monotone map on
the complete lattice `Set α`.

Thus the *algorithmic* object produced by finite cop-win pruning coincides with
the *order-theoretic* `OrderHom.gfp`. -/
theorem gfp_eq_kernel (F : Finset α → Finset α) (hcontract : Contracting F)
    (hmono : MonotoneUpdate F) (S : Finset α)
    {K : Finset α} (hKS : K ⊆ S) (hKfix : F K = K)
    (hKmax : ∀ T ⊆ S, F T = T → T ⊆ K) :
    OrderHom.gfp (G F S hmono) = (↑K : Set α) := by
  apply le_antisymm
  · -- `gfp ≤ ↑K`: any post-fixed point `b` lives below `↑S`, hence is `↑T` for a
    -- finite `T ⊆ S` which is an `F`-fixed point, hence contained in `K`.
    apply OrderHom.gfp_le
    intro b hb
    have hbS : b ⊆ (↑S : Set α) := by
      refine hb.trans ?_
      rw [G_apply]; exact_mod_cast (hcontract _).trans (Finset.filter_subset _ _)
    set T := S.filter (fun a => a ∈ b) with hT
    have hTS : T ⊆ S := Finset.filter_subset _ _
    have hbT : b = (↑T : Set α) := by
      rw [hT]; ext a
      simp only [Finset.coe_filter, Set.mem_setOf_eq]
      exact ⟨fun ha => ⟨hbS ha, ha⟩, fun ha => ha.2⟩
    have hGb : G F S hmono b = ↑(F T) := by rw [G_apply, Finset.filter_congr_decidable, ← hT]
    have hbFT : b ⊆ (↑(F T) : Set α) := hGb ▸ hb
    have hTFT : T ⊆ F T := by rw [hbT] at hbFT; exact_mod_cast hbFT
    have hFTeq : F T = T := Finset.Subset.antisymm (hcontract _) hTFT
    rw [hbT]; exact_mod_cast hKmax T hTS hFTeq
  · -- `↑K ≤ gfp`: `↑K` is itself a fixed point of `G`.
    apply OrderHom.le_gfp
    rw [G_fixes_kernel F S hmono hKS hKfix]

/-- **Main bridge corollary.** The Knaster–Tarski greatest fixed point of the
lattice map `G` is *computed* by the finite pruning algorithm within `|S|`
rounds: there is `n ≤ |S|` with `gfp (G F S) = ↑(rounds F n S)` and
`rounds F n S` an `F`-fixed point.  This links the *existence* theorem of order
theory with the *effective computation* of algorithm termination. -/
theorem gfp_computed_by_finite_iteration (F : Finset α → Finset α) (hcontract : Contracting F)
    (hmono : MonotoneUpdate F) (S : Finset α) :
    ∃ n ≤ S.card, OrderHom.gfp (G F S hmono) = (↑(rounds F n S) : Set α)
      ∧ F (rounds F n S) = rounds F n S := by
  obtain ⟨n, hn, hfix⟩ := exists_fixed_round_le_card F hcontract S
  refine ⟨n, hn, ?_, hfix⟩
  exact gfp_eq_kernel F hcontract hmono S (rounds_subset F hcontract n S) hfix
    (fun T hTS hT => fixed_subset_rounds F hmono hT hTS n)

/-! ### A concrete instance -/

/-- Concrete instance of the bridge: intersecting with a fixed set `A` is
contracting and monotone, and its greatest fixed point is `↑(S ∩ A)`. -/
theorem gfp_inter_fixed (A : Finset ℕ) (S : Finset ℕ) :
    OrderHom.gfp (G (fun T => T ∩ A) S
        (fun _ _ h => Finset.inter_subset_inter_right h))
      = (↑(S ∩ A) : Set ℕ) := by
  apply gfp_eq_kernel (fun T => T ∩ A) (fun _ => Finset.inter_subset_left) _ S
  · exact Finset.inter_subset_left
  · rw [Finset.inter_assoc, Finset.inter_self]
  · intro T hTS hT
    rw [← hT]; exact Finset.inter_subset_inter hTS subset_rfl

end CopwinKT