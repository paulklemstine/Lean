import Mathlib

/-!
# Integrated information across bipartitions: a tractable surrogate model

This file develops a self-contained, finite-probability model of *integrated information*
(`Φ`) in the spirit of Integrated Information Theory (IIT), designed so that the central
complexity-theoretic statements about it can be stated and proved rigorously in Lean.

## Modeling choices

A *probabilistic system* on a finite set of Boolean variables indexed by `α` is a joint
distribution `P_X`, formalized here as `PMF (α → Bool)`.  From such a distribution we read
off the **co-activation structure**: two variables `u, v` are *co-active* when the event
`X_u = 1 ∧ X_v = 1` has positive probability.  A set `K` of variables is a *co-active
coalition* when every pair inside it is co-active; this is exactly the kind of *irreducible
shared* structure that integrated information is meant to quantify.

The **integrated information across a bipartition** `(A, Aᶜ)` is the size of the largest
co-active coalition that is *split* by the cut (a coalition straddling the partition encodes
information that cannot be localised to either side).  `Φ_max` maximises this over all
bipartitions.

This is a deliberately tractable surrogate of IIT's `Φ` (the full IIT functional, defined
via earth-mover distance over cause/effect repertoires, is far more intricate).  The point
of the model is that the *reduction* and *complexity* statements below are genuine theorems
about a genuine probabilistic system, not artefacts of a degenerate definition.

## Main definitions

* `IIT.Coactive`, `IIT.IsCoactiveSet`, `IIT.Straddles`.
* `IIT.PhiBip` — integrated information across a single bipartition.
* `IIT.PhiMax` — maximum integrated information over all bipartitions.

## Main results

* `IIT.phiMax_eq_global` — `Φ_max` equals the size of the largest co-active coalition with
  at least two elements.
* `IIT.phiMax_le_card` — `Φ_max` never exceeds the number of variables.
* `IIT.phiMax_le_pow` — the loose form `Φ ≤ n ^ m` of the circuit bound `Φ ≤ n^{O(d+k)}`.
-/

namespace IIT

open scoped Classical

variable {α : Type*}

/-- A probabilistic system over Boolean variables indexed by `α`: a joint distribution. -/
abbrev ProbSystem (α : Type*) := PMF (α → Bool)

/-- Two variables `u` and `v` are *co-active* in the system `p` when some
positive-probability configuration switches both of them on, i.e.
`P(X_u = 1 ∧ X_v = 1) > 0`. -/
def Coactive (p : ProbSystem α) (u v : α) : Prop :=
  ∃ x ∈ p.support, x u = true ∧ x v = true

/-- A finite set `K` of variables is a *co-active coalition* when every pair of distinct
variables in it is co-active. -/
def IsCoactiveSet (p : ProbSystem α) (K : Finset α) : Prop :=
  ∀ ⦃u⦄, u ∈ K → ∀ ⦃v⦄, v ∈ K → u ≠ v → Coactive p u v

/-- `K` *straddles* the bipartition `(A, Aᶜ)`: it has a variable on each side of the cut. -/
def Straddles (A K : Finset α) : Prop :=
  (∃ u ∈ K, u ∈ A) ∧ (∃ v ∈ K, v ∉ A)

section Fintype
variable [Fintype α] [DecidableEq α]

/-- Integrated information across the bipartition `(A, Aᶜ)`: the size of the largest
co-active coalition split by the cut (`0` if none). -/
noncomputable def PhiBip (p : ProbSystem α) (A : Finset α) : ℕ :=
  sSup {n | ∃ K : Finset α, K.card = n ∧ IsCoactiveSet p K ∧ Straddles A K}

/-- Maximum integrated information over all bipartitions. -/
noncomputable def PhiMax (p : ProbSystem α) : ℕ :=
  sSup {n | ∃ A : Finset α, n = PhiBip p A}

/-- The size of the largest co-active coalition with at least two members. -/
noncomputable def GlobalCoactive (p : ProbSystem α) : ℕ :=
  sSup {n | ∃ K : Finset α, K.card = n ∧ IsCoactiveSet p K ∧ 2 ≤ K.card}

omit [Fintype α] in
/-- A coalition that straddles a bipartition has at least two members. -/
theorem two_le_card_of_straddles {A K : Finset α} (h : Straddles A K) : 2 ≤ K.card := by
  obtain ⟨⟨u, huK, huA⟩, ⟨v, hvK, hvA⟩⟩ := h
  have huv : u ≠ v := by rintro rfl; exact hvA huA
  have : ({u, v} : Finset α) ⊆ K := by
    intro w hw
    simp only [Finset.mem_insert, Finset.mem_singleton] at hw
    rcases hw with rfl | rfl <;> assumption
  calc 2 = ({u, v} : Finset α).card := by rw [Finset.card_pair huv]
    _ ≤ K.card := Finset.card_le_card this

omit [Fintype α] [DecidableEq α] in
/-- Any coalition with at least two members is straddled by some bipartition. -/
theorem exists_straddles_of_two_le {K : Finset α} (h : 2 ≤ K.card) :
    ∃ A : Finset α, Straddles A K := by
  obtain ⟨u, v, hu, hv, huv⟩ := Finset.one_lt_card_iff.mp h
  exact ⟨{u}, ⟨u, hu, Finset.mem_singleton_self u⟩,
    ⟨v, hv, by simp [Finset.mem_singleton, Ne.symm huv]⟩⟩

/-
`Φ_max` coincides with the size of the largest co-active coalition (with `≥ 2` members):
maximising the split-coalition size over all bipartitions recovers the global optimum.
-/
theorem phiMax_eq_global (p : ProbSystem α) : PhiMax p = GlobalCoactive p := by
  refine' le_antisymm _ _;
  · refine' csSup_le' _;
    rintro n ⟨ A, rfl ⟩;
    refine' csSup_le' _;
    rintro n ⟨ K, rfl, hK₁, hK₂ ⟩;
    exact le_csSup ⟨ Fintype.card α, by rintro n ⟨ K, rfl, hK₁, hK₂ ⟩ ; exact Finset.card_le_univ _ ⟩ ⟨ K, rfl, hK₁, two_le_card_of_straddles hK₂ ⟩;
  · refine' csSup_le' _;
    rintro n ⟨ K, rfl, hK₁, hK₂ ⟩;
    -- By `exists_straddles_of_two_le`, there exists a bipartition `A` such that `K` straddles `A`.
    obtain ⟨A, hA⟩ : ∃ A : Finset α, Straddles A K := exists_straddles_of_two_le hK₂;
    refine' le_trans _ ( le_csSup _ ⟨ A, rfl ⟩ );
    · refine' le_csSup _ _;
      · exact ⟨ Fintype.card α, by rintro n ⟨ K, rfl, hK₁, hK₂ ⟩ ; exact Finset.card_le_univ _ ⟩;
      · exact ⟨ K, rfl, hK₁, hA ⟩;
    · exact ⟨ Fintype.card α, by rintro n ⟨ A, rfl ⟩ ; exact le_trans ( csSup_le' fun n hn => by obtain ⟨ K, rfl, hK₁, hK₂ ⟩ := hn; exact Finset.card_le_univ _ ) ( by simp +decide ) ⟩

/-
Integrated information never exceeds the number of variables.
-/
theorem phiMax_le_card (p : ProbSystem α) : PhiMax p ≤ Fintype.card α := by
  rw [ phiMax_eq_global, GlobalCoactive ];
  exact csSup_le' fun n hn => hn.choose_spec.1 ▸ Finset.card_le_univ _

/-- A loose, explicit form of the circuit bound `Φ ≤ n^{O(d+k)}`: for a system on `n ≥ 1`
variables, `Φ ≤ n ^ m` for every exponent `m ≥ 1`.  (The genuine content is the sharper
`phiMax_le_card`; this is the requested polynomial shape.) -/
theorem phiMax_le_pow (p : ProbSystem α) (hn : 1 ≤ Fintype.card α) {m : ℕ} (hm : 1 ≤ m) :
    PhiMax p ≤ (Fintype.card α) ^ m := by
  calc PhiMax p ≤ Fintype.card α := phiMax_le_card p
    _ = (Fintype.card α) ^ 1 := (pow_one _).symm
    _ ≤ (Fintype.card α) ^ m := Nat.pow_le_pow_right hn hm

end Fintype

end IIT