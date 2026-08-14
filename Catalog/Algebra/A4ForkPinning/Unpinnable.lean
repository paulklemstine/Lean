/-
# The pinning-content criterion, and absolutely unpinnable fields

The experiments of papers 65–75 all instantiate one structural statement: a
binary splitting fork is congruence-pinned **iff it factors through the
abelianisation of the Galois group** (Takagi: congruence conditions on `p` see
the Frobenius only through abelian quotients).  This file proves that criterion
in the form of a purely group-theoretic equivalence, and then reads off the two
extreme entries of the pinning-content table.

* `A4ForkPinning.FactorsThroughAb` — a fork factors through `G^ab`;
* `A4ForkPinning.factorsThroughAb_iff` — **the criterion**: `F` factors through
  `G^ab` iff `F` is invariant under translation by commutators;
* `A4ForkPinning.V4_fork_factors` — the `A₄` fork `F₀ = [σ ∈ V₄]` *does* factor
  (this is why it is pinned, by a **cubic** character since `|A₄^ab| = 3`);
* `A4ForkPinning.identity_fork_not_factors` — the finer fork `F₁ = [σ = e]` does
  **not** factor: no modulus whatsoever can pin it (it can only leak);
* `A4ForkPinning.commutator_alternating_five_eq_top` — `A₅` is perfect, and
* `A4ForkPinning.A5_absolutely_unpinnable`,
  `A4ForkPinning.A5_fork_factors_iff_constant` — over an `A₅`-field **every**
  non-trivial fork is absolutely unpinnable: the predicted last line of the table.
-/
import Algebra.A4ForkPinning.GroupA4

namespace A4ForkPinning

open Equiv Equiv.Perm

/-! ## The criterion -/

variable {G : Type*} [Group G]

/-- A fork `F : G → Prop` *factors through the abelianisation* if it is the pullback
of a predicate on `G^ab`.  By class field theory this is precisely the class of
forks that a congruence condition on `p` can detect. -/
def FactorsThroughAb (F : G → Prop) : Prop :=
  ∃ f : Abelianization G → Prop, ∀ g, F g ↔ f (Abelianization.of g)

/-- **The pinning-content criterion.**  A fork factors through `G^ab` exactly when it
is invariant under multiplication by commutators. -/
theorem factorsThroughAb_iff (F : G → Prop) :
    FactorsThroughAb F ↔ ∀ g c, c ∈ commutator G → (F (g * c) ↔ F g) := by
  constructor
  · rintro ⟨f, hf⟩ g c hc
    have hc1 : Abelianization.of c = 1 :=
      MonoidHom.mem_ker.1 (Abelianization.commutator_subset_ker _ hc)
    rw [hf, hf, map_mul, hc1, mul_one]
  · intro h
    refine ⟨fun x => ∃ g, Abelianization.of g = x ∧ F g, fun g => ⟨fun hg => ⟨g, rfl, hg⟩, ?_⟩⟩
    rintro ⟨g', hg', hF⟩
    have hmem : g'⁻¹ * g ∈ commutator G := QuotientGroup.eq.1 hg'
    have := h g' (g'⁻¹ * g) hmem
    rw [show g' * (g'⁻¹ * g) = g by group] at this
    exact this.2 hF

/-- A fork that factors through the abelianisation cannot separate two elements of the
same commutator coset. -/
theorem eq_of_factorsThroughAb {F : G → Prop} (hF : FactorsThroughAb F) (g c : G)
    (hc : c ∈ commutator G) : F (g * c) ↔ F g :=
  (factorsThroughAb_iff F).1 hF g c hc

/-! ## `A₄`: the `V₄`-fork factors, the identity fork does not -/

/-- The `V₄`-fork of `A₄` factors through `A₄^ab = C₃`: it is the fibre over `0` of the
cubic character, hence pinnable — and pinnable only by a cubic character. -/
theorem V4_fork_factors :
    FactorsThroughAb (fun g : alternatingGroup (Fin 4) => (g : Equiv.Perm (Fin 4)) ∈ V4) := by
  rw [factorsThroughAb_iff]
  intro g c hc
  have hcV : (c : Equiv.Perm (Fin 4)) ∈ V4 := by
    rw [commutator_alternatingGroup] at hc
    exact hc
  constructor
  · intro hgc
    have : (g : Equiv.Perm (Fin 4)) = ((g * c : alternatingGroup (Fin 4)) : Equiv.Perm (Fin 4))
        * (c : Equiv.Perm (Fin 4))⁻¹ := by
      push_cast; group
    rw [this]
    exact V4.mul_mem hgc (V4.inv_mem hcV)
  · intro hg
    have : ((g * c : alternatingGroup (Fin 4)) : Equiv.Perm (Fin 4))
        = (g : Equiv.Perm (Fin 4)) * (c : Equiv.Perm (Fin 4)) := rfl
    rw [this]
    exact V4.mul_mem hg hcV

/-- An explicit non-trivial element of `V₄`: the double transposition `(01)(23)`. -/
def dbl : Equiv.Perm (Fin 4) := Equiv.swap 0 1 * Equiv.swap 2 3

theorem dbl_mem_V4 : dbl ∈ V4 := by decide

theorem dbl_ne_one : dbl ≠ 1 := by decide

theorem dbl_even : Equiv.Perm.sign dbl = 1 := by decide

/-- **The identity fork is not pinnable.**  `F₁ = [Frob = e]` does not factor through
`A₄^ab`, because `e` and the double transposition `(01)(23)` lie in the same
commutator coset.  Hence no modulus can determine it — it can only *leak*, as
quantified by `info_mod9_identity_fork`. -/
theorem identity_fork_not_factors :
    ¬ FactorsThroughAb (fun g : alternatingGroup (Fin 4) => g = 1) := by
  intro hF
  have hc : (⟨dbl, mem_alternatingGroup.2 dbl_even⟩ : alternatingGroup (Fin 4))
      ∈ commutator (alternatingGroup (Fin 4)) := by
    rw [commutator_alternatingGroup]
    exact dbl_mem_V4
  have h := eq_of_factorsThroughAb hF 1 _ hc
  rw [one_mul] at h
  have hone : (⟨dbl, mem_alternatingGroup.2 dbl_even⟩ : alternatingGroup (Fin 4)) = 1 :=
    h.2 rfl
  exact dbl_ne_one (congrArg Subtype.val hone)

/-! ## `A₅`: absolutely unpinnable -/

/-- Two non-commuting even permutations of `Fin 5`. -/
def a5x : Equiv.Perm (Fin 5) := Equiv.swap 0 1 * Equiv.swap 1 2

/-- A second one, chosen to move the support of `a5x`. -/
def a5y : Equiv.Perm (Fin 5) := Equiv.swap 2 3 * Equiv.swap 3 4

theorem a5x_even : Equiv.Perm.sign a5x = 1 := by decide

theorem a5y_even : Equiv.Perm.sign a5y = 1 := by decide

theorem a5_noncomm : a5x * a5y ≠ a5y * a5x := by decide

/-- **`A₅` is perfect**: its commutator subgroup is everything, so `A₅^ab` is trivial. -/
theorem commutator_alternating_five_eq_top :
    commutator (alternatingGroup (Fin 5)) = ⊤ := by
  rcases (IsSimpleGroup.eq_bot_or_eq_top_of_normal (commutator (alternatingGroup (Fin 5)))
    (by infer_instance)) with h | h
  · exfalso
    have hcenter := (commutator_eq_bot_iff_center_eq_top _).1 h
    have hcomm : ∀ a b : alternatingGroup (Fin 5), a * b = b * a := by
      intro a b
      have hb : b ∈ Subgroup.center (alternatingGroup (Fin 5)) := by
        rw [hcenter]; exact Subgroup.mem_top b
      exact Subgroup.mem_center_iff.1 hb a
    exact a5_noncomm (congrArg Subtype.val
      (hcomm ⟨a5x, mem_alternatingGroup.2 a5x_even⟩ ⟨a5y, mem_alternatingGroup.2 a5y_even⟩))
  · exact h

/-- **Absolute unpinnability of an `A₅`-field.**  Every homomorphism from `A₅` to an
abelian group is trivial, so no Dirichlet character can see any fork at all. -/
theorem A5_absolutely_unpinnable {A : Type*} [CommGroup A]
    (psi : (alternatingGroup (Fin 5)) →* A) (g : alternatingGroup (Fin 5)) : psi g = 1 := by
  have hker : commutator (alternatingGroup (Fin 5)) ≤ psi.ker :=
    Abelianization.commutator_subset_ker psi
  rw [commutator_alternating_five_eq_top] at hker
  exact hker (Subgroup.mem_top g)

/-- Consequently the *only* forks of an `A₅`-field that factor through the
abelianisation are the two constant ones: the last line of the pinning-content table
(`C₂`, `C₃`, `S₃`, `S₄`, `A₄` pin something; `A₅` pins nothing). -/
theorem A5_fork_factors_iff_constant (F : alternatingGroup (Fin 5) → Prop) :
    FactorsThroughAb F ↔ ∀ g h, (F g ↔ F h) := by
  rw [factorsThroughAb_iff]
  constructor
  · intro hF g h
    have := hF g (g⁻¹ * h) (by rw [commutator_alternating_five_eq_top]; exact Subgroup.mem_top _)
    rw [show g * (g⁻¹ * h) = h by group] at this
    exact this.symm
  · intro hF g c _
    exact hF (g * c) g

end A4ForkPinning