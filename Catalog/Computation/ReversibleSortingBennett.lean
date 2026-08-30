/-
# Reversible Sorting and Bennett's Theorem

This file formalizes the theory of reversible computation applied to sorting,
establishing the fundamental connection between computational reversibility,
information conservation, and thermodynamic cost.

## Key Concepts

* **Reversible computation witness**: A bijection that augments a function's output
  with auxiliary "history" data, making the overall map invertible.
* **Bennett's theorem** (finite version): Any function on a finite type can be made
  reversible by recording enough auxiliary information.
* **Landauer gap**: The thermodynamic cost difference between irreversible and
  reversible implementations of the same computation.
* **Fiber entropy**: The information content of the preimage structure of a function,
  which determines the minimum auxiliary data needed for reversibility.

## Main Results

* `RevWitness` : Structure for reversible computation witnesses
* `bennett_sigma_witness` : Any function admits a reversible decomposition (Bennett's theorem)
* `rev_witness_aux_lower_bound` : Lower bound on auxiliary space from fiber sizes
* `fiber_card_sum` : Partition identity for function fibers
* `landauer_gap_nonneg` : Irreversible computation always costs ≥ reversible
* `sorting_history_lower_bound` : Sorting needs ≥ n! auxiliary states for reversibility
* `rev_witness_compose` : Composition of reversible witnesses
-/

import Mathlib

open Finset Function Nat Real BigOperators

/-! ## Section 1: Reversible Computation Witnesses -/

/-- A reversible computation witness for a function `f : α → β` consists of
an auxiliary type `Aux` and a bijection `encode : α ≃ β × Aux` such that
the first component of `encode` agrees with `f`. This captures Bennett's
insight that any computation can be made reversible by recording the
"history" of the computation as auxiliary output.

Note: This requires `|β| · |Aux| = |α|` for finite types, so it only applies
when the codomain size divides the domain size (e.g., sorting, where |β| = 1). -/
structure RevWitness {α β : Type*} (f : α → β) where
  /-- The auxiliary "history" type -/
  Aux : Type*
  /-- The reversible encoding: a bijection from input to (output, history) -/
  encode : α ≃ β × Aux
  /-- The encoding's first component agrees with the original function -/
  consistent : ∀ a : α, (encode a).1 = f a

namespace RevWitness

/-- The decoding function: given output and history, recover the input -/
def decode {f : α → β} (w : RevWitness f) (p : β × Aux w) : α :=
  w.encode.symm p

/-- Decode is left inverse of encode -/
theorem decode_encode {f : α → β} (w : RevWitness f) (a : α) :
    w.decode (w.encode a) = a :=
  w.encode.symm_apply_apply a

/-- Encode is left inverse of decode -/
theorem encode_decode {f : α → β} (w : RevWitness f) (p : β × Aux w) :
    w.encode (w.decode p) = p :=
  w.encode.apply_symm_apply p

end RevWitness

/-! ## Section 2: Bennett's Theorem (Finite Version)

Bennett's fundamental result: any function on a finite type can be made
reversible by augmenting the output with auxiliary information drawn from
the function's fiber structure. The key construction uses the fiber
(preimage) of each output value as the auxiliary data. -/

/-- For a function `f : α → β` between finite types, the fibers partition the domain:
    ∑_{b ∈ β} |f⁻¹(b)| = |α|. This is the fundamental counting identity. -/
theorem fiber_card_sum {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) :
    ∑ b : β, (Finset.univ.filter (fun a => f a = b)).card = Fintype.card α := by
  simp +decide only [card_filter]
  rw [Finset.sum_comm]; simp +decide

/-- **Bennett's Reversible Witness Theorem** (sigma-type version):
Any function `f : α → β` can be decomposed as a bijection
`α ≃ Σ b : β, {a // f a = b}`, where the first component recovers `f`.

The auxiliary data for each output `b` is exactly which element of the
fiber `f⁻¹(b)` the input was — this is the minimum information needed
to make the computation reversible.

This is the formal statement of Bennett's 1973 result that any computation
can be made logically reversible at the cost of additional output data. -/
theorem bennett_sigma_witness {α β : Type*} [DecidableEq β] (f : α → β) :
    ∃ (e : α ≃ Σ b : β, {a : α // f a = b}),
      ∀ a, (e a).1 = f a :=
  ⟨(Equiv.sigmaFiberEquiv f).symm, fun _ => rfl⟩

/-- **Bennett's theorem for constant functions** (product-type version):
When the function maps to `Unit` (as sorting does), the sigma decomposition
simplifies to a product `α ≃ Unit × α`, giving a direct `RevWitness`. -/
def bennett_unit_witness (α : Type*) :
    RevWitness (fun (_ : α) => ()) where
  Aux := α
  encode := (Equiv.punitProd α).symm
  consistent := fun _ => rfl

/-! ## Section 3: Auxiliary Space Lower Bounds

The minimum auxiliary space for reversibility is determined by the
fiber structure of the function. If the largest fiber has size k,
the auxiliary type must have at least k elements. -/

/-- The maximum fiber size of a function: the size of the largest preimage set. -/
def maxFiberSize {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℕ :=
  Finset.sup Finset.univ (fun b => (Finset.univ.filter (fun a => f a = b)).card)

/-- A reversible witness for `f` requires auxiliary space at least as large
as the maximum fiber of `f`. If some output has k preimages, we need
at least k auxiliary values to distinguish them. -/
theorem rev_witness_aux_lower_bound {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β] (f : α → β)
    (Aux : Type*) [Fintype Aux] (e : α ≃ β × Aux)
    (hc : ∀ a, (e a).1 = f a) :
    maxFiberSize f ≤ Fintype.card Aux := by
  refine' Finset.sup_le _
  intro b _hb; rw [← Fintype.card_subtype]
  have h_fiber_map : Function.Injective (fun a : { x : α // f x = b } => (e a).2) := by
    intro a₁ a₂ h; have := e.injective (Prod.ext (by aesop) h); aesop
  exact Fintype.card_le_of_injective _ h_fiber_map

/-! ## Section 4: Thermodynamic Cost of Reversibility -/

/-- The Landauer cost of a computation that erases `bits_erased` bits of information. -/
noncomputable def landauerCost (kT : ℝ) (bits_erased : ℝ) : ℝ :=
  kT * Real.log 2 * bits_erased

/-- The information erased by a function on a finite type, measured in bits.
    This is log₂|α| - log₂|image(f)|, representing the information lost. -/
noncomputable def infoErased {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) : ℝ :=
  Real.logb 2 (Fintype.card α) - Real.logb 2 (Finset.card (Finset.image f Finset.univ))

/-- The Landauer gap: the Landauer cost of the irreversible implementation. -/
noncomputable def landauerGap {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (kT : ℝ) : ℝ :=
  landauerCost kT (infoErased f)

/-- **Landauer gap is non-negative**: irreversible computation always costs
    at least as much thermodynamic work as reversible computation. -/
theorem landauer_gap_nonneg {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (kT : ℝ) (hkT : 0 < kT) :
    0 ≤ landauerGap f kT := by
  refine mul_nonneg (mul_nonneg hkT.le <| Real.log_nonneg <| ?_) <| sub_nonneg.mpr ?_
  · norm_num
  · by_cases h : Finset.card (Finset.image f Finset.univ) = 0
    · simp_all +decide [Finset.ext_iff]
      simp +decide [Finset.card_eq_zero.mpr
        (show Finset.image f Finset.univ = ∅ by ext; aesop)]
      rw [Fintype.card_eq_zero_iff.mpr ⟨fun a => h a⟩]; norm_num
    · gcongr <;> norm_cast; exact Finset.card_image_le

/-! ## Section 5: Application to Sorting -/

/-- A sorting function collapses all permutations to a single output. -/
def sortingFunction (n : ℕ) : Equiv.Perm (Fin n) → Unit :=
  fun _ => ()

/-- The fiber of the sorting function is the full permutation group. -/
theorem sorting_max_fiber (n : ℕ) :
    (Finset.univ.filter (fun (σ : Equiv.Perm (Fin n)) =>
      sortingFunction n σ = ())).card = Fintype.card (Equiv.Perm (Fin n)) := by
  convert Finset.card_univ
  exact Finset.filter_true_of_mem fun _ _ => rfl

/-- **Sorting History Lower Bound**: Any reversible sorting implementation
    requires auxiliary space of at least n! states. -/
theorem sorting_history_lower_bound (n : ℕ)
    (Aux : Type*) [Fintype Aux]
    (e : Equiv.Perm (Fin n) ≃ Unit × Aux)
    (hc : ∀ σ, (e σ).1 = sortingFunction n σ) :
    Fintype.card (Equiv.Perm (Fin n)) ≤ Fintype.card Aux := by
  convert Fintype.card_le_of_injective _ _
  exacts [fun σ => (e σ).2,
    fun σ τ h => e.injective <| Prod.ext (hc σ ▸ hc τ ▸ rfl) h]

/-! ## Section 6: Composition of Reversible Witnesses -/

/-- Compose two reversible witnesses to get a witness for the composition. -/
noncomputable def RevWitness.compose {α β γ : Type*} {f : α → β} {g : β → γ}
    (wf : RevWitness f) (wg : RevWitness g) :
    RevWitness (g ∘ f) where
  Aux := wf.Aux × wg.Aux
  encode := by
    calc α ≃ β × wf.Aux := wf.encode
      _ ≃ (γ × wg.Aux) × wf.Aux := Equiv.prodCongr wg.encode (Equiv.refl _)
      _ ≃ γ × wg.Aux × wf.Aux := Equiv.prodAssoc _ _ _
      _ ≃ γ × (wf.Aux × wg.Aux) := Equiv.prodCongr (Equiv.refl _) (Equiv.prodComm _ _)
  consistent := by
    intro a
    simp [Equiv.trans, Equiv.prodCongr, Equiv.prodAssoc]
    rw [wg.consistent, wf.consistent]

/-- Composing reversible witnesses preserves correctness. -/
theorem rev_witness_compose_correct {α β γ : Type*} {f : α → β} {g : β → γ}
    (wf : RevWitness f) (wg : RevWitness g) :
    ∀ a : α, ((wf.compose wg).encode a).1 = g (f a) :=
  (wf.compose wg).consistent

/-- **Composition auxiliary space is multiplicative**: the auxiliary space
    for the composition has cardinality equal to the product of the
    component auxiliary spaces. -/
theorem compose_aux_card {α β γ : Type*} {f : α → β} {g : β → γ}
    (wf : RevWitness f) (wg : RevWitness g)
    [Fintype wf.Aux] [Fintype wg.Aux] :
    Fintype.card (wf.Aux × wg.Aux) =
    Fintype.card wf.Aux * Fintype.card wg.Aux :=
  Fintype.card_prod _ _

/-! ## Section 7: Entropy of Permutation Groups -/

/-- The cardinality of Sₙ = n! -/
theorem perm_card (n : ℕ) :
    Fintype.card (Equiv.Perm (Fin n)) = n.factorial := by
  rw [Fintype.card_perm]; aesop

/-- For n ≥ 2, the sorting function is non-injective. -/
theorem sorting_non_injective (n : ℕ) (hn : 2 ≤ n) :
    ¬ Injective (sortingFunction n) := by
  obtain ⟨a, b, hab⟩ : ∃ a b : Equiv.Perm (Fin n), a ≠ b := by
    exact ⟨Equiv.swap (⟨0, by linarith⟩ : Fin n) ⟨1, by linarith⟩,
           Equiv.refl _, by aesop⟩
  exact fun h => hab <| h <| by simp +decide [sortingFunction]

/-- The information erased by sorting n ≥ 1 elements equals log₂(n!). -/
theorem sorting_info_erased (n : ℕ) (hn : 1 ≤ n) :
    infoErased (sortingFunction n) = Real.logb 2 (n.factorial) := by
  unfold infoErased sortingFunction; norm_num [Fintype.card_perm]
  rw [Finset.image_const] <;> aesop

/-- The hypothesis `1 ≤ n` in `sorting_info_erased` is in fact unnecessary: the
    identity permutation already makes `Equiv.Perm (Fin 0)` nonempty, so the image of
    the constant sorting map is a singleton for every `n`.  This unconditional form is
    what downstream files use. -/
theorem sorting_info_erased_all (n : ℕ) :
    infoErased (sortingFunction n) = Real.logb 2 (n.factorial) := by
  unfold infoErased sortingFunction; norm_num [Fintype.card_perm]
  rw [Finset.image_const] <;> aesop

/-! ## Section 8: Bijection Reversibility -/

/-- For a bijection, every fiber has size ≤ 1. -/
theorem bijection_max_fiber_le {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : Bijective f) :
    maxFiberSize f ≤ 1 := by
  obtain ⟨g, _hg⟩ := hf
  exact Finset.sup_le fun x _ =>
    Finset.card_le_one.mpr fun a ha b hb => g <| by aesop

/-- The identity function erases no information. -/
theorem identity_info_erased (α : Type*) [Fintype α] [DecidableEq α]
    [Nonempty α] :
    infoErased (id : α → α) = 0 := by
  unfold infoErased
  simp +decide

/-- For a constant function on n > 1 elements, info erased equals log₂(n). -/
theorem constant_info_erased_eq {α : Type*} [Fintype α] [DecidableEq α]
    (hn : 1 < Fintype.card α) :
    infoErased (fun (_ : α) => ()) = Real.logb 2 (Fintype.card α) := by
  unfold infoErased
  rw [Finset.image_const (Finset.univ_nonempty_iff.mpr
    ⟨Classical.choose (Finset.card_pos.mp (pos_of_gt hn))⟩),
    Finset.card_singleton, Nat.cast_one, Real.logb_one, sub_zero]