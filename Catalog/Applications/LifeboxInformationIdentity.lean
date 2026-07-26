import Mathlib

/-! # Rucker's Lifebox: Information-Theoretic Identity

This file formalizes several claims surrounding Rudy Rucker's *Lifebox* idea — that a
person's identity is determined by their *information content* (their input/output
behaviour) rather than by their physical substrate.

We make the following precise and prove them.

* **Person-equivalence = functional equivalence.** Two "systems" (functions from an input
  type to an output type) are *person-equivalent* when they produce the same output for
  every input.  We show this is an equivalence relation (`PersonEquiv.refl/symm/trans`,
  packaged as `personSetoid`).

* **Finite profiles ⇒ decidable.** If the complete stimulus space is finite and outputs
  have decidable equality, person-equivalence is decidable (`decidablePersonEquiv`,
  `finiteState_decidable`).  The separate `FiniteStateIdentity.lean` proves the stronger
  automata theorem for infinitely many finite input histories.

* **Contrarian: no finite test in general.** For an infinite input space (`ℕ`) *no* finite
  battery of tests can certify person-equivalence: for every finite set of probe inputs
  there are two distinct systems that agree on all of them (`no_finite_test`).  This is the
  precise sense in which the finiteness hypothesis above is *necessary*.

* **Quantum obstruction = no-cloning.** A digital Lifebox works by *copying* information.
  In the two-dimensional model there is **no** linear map `C : k² → k² ⊗ k²` with
  `C x = x ⊗ x` for every `x` (`no_cloning`). Hence a quantum state admits no universal
  linear "read-and-duplicate" device. We do **not**
  claim that this proves undecidability: no-cloning and undecidability are logically different
  notions, and no-cloning alone does not imply that an equivalence predicate is undecidable.

* **Description-space count.** Fixed-length `b`-bit descriptions number exactly `2 ^ b`
  (`card_identities`); instantiating the externally conjectured bound `b = 10 ^ 15` gives
  an explicit finite cardinality (`lifebox_bound`). This is not itself a theorem about
  machine-dependent Kolmogorov complexity.
-/

namespace Lifebox

/-! ## 1. Person-equivalence and the equivalence relation -/

/-- Two systems `f g : I → O` are **person-equivalent** if they produce the same output for
every input: identity is functional behaviour, not substrate. -/
def PersonEquiv {I O : Type*} (f g : I → O) : Prop := ∀ i, f i = g i

@[refl] theorem PersonEquiv.refl {I O : Type*} (f : I → O) : PersonEquiv f f := by
  exact fun _ => rfl

@[symm] theorem PersonEquiv.symm {I O : Type*} {f g : I → O}
    (h : PersonEquiv f g) : PersonEquiv g f := by
  exact fun i => h i ▸ rfl

theorem PersonEquiv.trans {I O : Type*} {f g h : I → O}
    (hfg : PersonEquiv f g) (hgh : PersonEquiv g h) : PersonEquiv f h := by
  exact fun i => hfg i ▸ hgh i

/-
Person-equivalence coincides with equality of functions (extensionality).
-/
theorem personEquiv_iff_eq {I O : Type*} (f g : I → O) :
    PersonEquiv f g ↔ f = g := by
  exact ⟨ fun h => funext h, fun h => h ▸ PersonEquiv.refl f ⟩

/-- Person-equivalence is an equivalence relation. -/
def personSetoid (I O : Type*) : Setoid (I → O) where
  r := PersonEquiv
  iseqv := ⟨PersonEquiv.refl, PersonEquiv.symm, PersonEquiv.trans⟩

/-! ## 2. Finite functional profiles have decidable person-equivalence -/

/-- If the stimulus space is finite and outputs have decidable equality, then
person-equivalence of complete functional profiles is decidable by exhaustive testing. -/
instance decidablePersonEquiv {I O : Type*} [Fintype I] [DecidableEq O]
    (f g : I → O) : Decidable (PersonEquiv f g) :=
  Fintype.decidableForallFintype

/-
For a finite complete stimulus space, person-equivalence is decided by computing the
finite set of *distinguishing stimuli* and checking that it is empty.
-/
theorem finiteState_decidable {I O : Type*} [Fintype I] [DecidableEq O]
    (f g : I → O) :
    PersonEquiv f g ↔ (Finset.univ.filter (fun i => f i ≠ g i)) = ∅ := by
  simp +decide [ Finset.ext_iff, PersonEquiv ]

/-! ## 3. Contrarian: for infinite input spaces, no finite test suffices -/

/-
**No finite test.** For any finite set `S` of probe inputs there exist two *distinct*
Boolean systems `f ≠ g` that agree on every probe in `S`.  Thus over an infinite input
space person-equivalence cannot be certified by any finite battery of tests — the finiteness
hypothesis in `finiteState_decidable` is essential.
-/
theorem no_finite_test (S : Finset ℕ) :
    ∃ f g : ℕ → Bool, (∀ i ∈ S, f i = g i) ∧ f ≠ g := by
  -- Define g as the constant function 0 and f as the function that is 0 everywhere except at n.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, n ∉ S := by
    exact Finset.exists_notMem _
  use fun i => if i = n then true else false, fun _ => false;
  exact ⟨ fun i hi => if_neg ( by aesop ), fun h => by simpa using congr_fun h n ⟩

/-! ## 4. Further consequences of extensional identity -/

/-- Re-encoding the input through a surjection cannot hide a behavioural difference. -/
theorem personEquiv_comp_iff_of_surjective {I J O : Type*} (e : J → I)
    (he : Function.Surjective e) (f g : I → O) :
    PersonEquiv (f ∘ e) (g ∘ e) ↔ PersonEquiv f g := by
  constructor
  · intro h i
    obtain ⟨j, rfl⟩ := he i
    exact h j
  · intro h j
    exact h (e j)

/-- An injective output encoding preserves and reflects person-equivalence. -/
theorem personEquiv_map_iff_of_injective {I O P : Type*} (e : O → P)
    (he : Function.Injective e) (f g : I → O) :
    PersonEquiv (e ∘ f) (e ∘ g) ↔ PersonEquiv f g := by
  constructor
  · intro h i
    exact he (h i)
  · intro h i
    exact congrArg e (h i)

/-- Combining two independent observation channels preserves equivalence exactly when
    both channels do. -/
theorem personEquiv_pair_iff {I O P : Type*} (f g : I → O) (u v : I → P) :
    PersonEquiv (fun i => (f i, u i)) (fun i => (g i, v i)) ↔
      PersonEquiv f g ∧ PersonEquiv u v := by
  constructor
  · intro h
    exact ⟨fun i => congrArg Prod.fst (h i), fun i => congrArg Prod.snd (h i)⟩
  · rintro ⟨hfg, huv⟩ i
    exact Prod.ext (hfg i) (huv i)

/-! ## 5. Quantum obstruction: the no-cloning theorem

A Lifebox duplicates a person by copying information. In the two-dimensional model
formalized below, there is no *linear* cloning map `x ↦ x ⊗ x`. -/

open scoped TensorProduct

/-
**No-cloning theorem.** Over any field `k`, there is no `k`-linear map
`C : k² → k² ⊗ k²` satisfying `C x = x ⊗ x` for every state `x`.  This rules out a universal linear duplicator.  It deliberately makes no
undecidability claim, because the no-cloning theorem by itself supplies none.
-/
theorem no_cloning (k : Type*) [Field k] :
    ¬ ∃ C : (k × k) →ₗ[k] (k × k) ⊗[k] (k × k), ∀ x, C x = x ⊗ₜ[k] x := by
  intro ⟨ C, hC ⟩;
  -- By linearity, $C(e_1 + e_2) = C(e_1) + C(e_2)$.
  have h_linear : C (1, 0) + C (0, 1) = C (1, 1) := by
    rw [ ← map_add ] ; norm_num;
  -- Define the bilinear map B : (k × k) →ₗ[k] (k × k) →ₗ[k] k by B a b = a.1 * b.2.
  set B : (k × k) →ₗ[k] (k × k) →ₗ[k] k := LinearMap.mk₂ k (fun a b => a.1 * b.2) (by
  simp +decide [ add_mul ]) (by
  simp +decide [ mul_assoc ]) (by
  simp +decide [ mul_add ]) (by
  simp +decide [ mul_left_comm ])
  generalize_proofs at *;
  -- Let g := TensorProduct.lift B : (k × k) ⊗[k] (k × k) →ₗ[k] k, so g (a ⊗ₜ b) = B a b = a.1 * b.2.
  set g : (k × k) ⊗[k] (k × k) →ₗ[k] k := TensorProduct.lift B;
  apply_fun g at h_linear ; simp_all +decide;
  simp +zetaDelta at *

/-! ## 6. Finite description-space counting -/

/-- Identities describable in `b` bits, modelled as bit-vectors `Fin b → Bool`. -/
abbrev Identity (b : ℕ) := Fin b → Bool

/-
**Finiteness / counting bound.** There are exactly `2 ^ b` identities describable in `b`
bits — a finite number.  This is the elementary fixed-length description counting principle.  It is not a
formalization of machine-dependent Kolmogorov complexity.
-/
theorem card_identities (b : ℕ) : Fintype.card (Identity b) = 2 ^ b := by
  simp [Identity]

/-
**Lifebox bound.** If one assumes Rucker's `~10^15`-bit hypothesis and models descriptions as
fixed-length bit-vectors, the number of possible descriptions is the finite quantity `2 ^ (10 ^ 15)`; in particular the type of such
identities is finite.
-/
theorem lifebox_bound :
    Fintype.card (Identity (10 ^ 15)) = 2 ^ (10 ^ 15) := by
  convert card_identities ( 10 ^ 15 )

end Lifebox