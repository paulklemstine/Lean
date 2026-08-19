/-
# Two consequences: arbitrary alphabets, and the dimension of the invariants

Two extensions of the kernel-pattern theory.

* `KernelPattern.sameKernel_iff_exists_perm_general` removes every finiteness hypothesis
  on the alphabet: over an arbitrary type of values, two tuples have the same equality
  pattern if and only if they differ by a permutation of the values.  For an infinite
  alphabet the extension of a bijection between the (finite) value sets uses the
  cardinal identity `#sᶜ = #α`.

* `KernelPattern.finrank_invariants` computes the dimension of the space of
  `Equiv.Perm α`-invariant `K`-valued functions of an `n`-tuple: it is `Nat.bell n`
  whenever `n ≤ |α|`.  Concretely, a symmetric function of `n` arguments taken from a
  large enough alphabet is exactly a function of the equality pattern, and there are
  `Nat.bell n` of those.
-/
import Algebra.KernelPatterns.Core
import Algebra.KernelPatterns.Bell

namespace KernelPattern

open Cardinal

variable {α : Type*} {n : ℕ}

/-! ## Completeness over an arbitrary alphabet -/

theorem sameKernel_iff_exists_perm_infinite [DecidableEq α] [Infinite α] {x y : Fin n → α} :
    SameKernel x y ↔ ∃ σ : Equiv.Perm α, σ ∘ x = y := by
  classical
  refine ⟨fun h => ?_, ?_⟩
  · -- the value sets
    set S : Set α := Set.range x with hS
    set T : Set α := Set.range y with hT
    have hfinS : S.Finite := Set.finite_range x
    have hfinT : T.Finite := Set.finite_range y
    -- a bijection between the value sets
    have hxmem : ∀ a : S, ∃ i, x i = a.1 := fun a => a.2
    choose idx hidx using hxmem
    have hmemT : ∀ a : S, y (idx a) ∈ T := fun a => ⟨idx a, rfl⟩
    let f : S → T := fun a => ⟨y (idx a), hmemT a⟩
    have hinj : Function.Injective f := by
      intro a b hab
      have hy : y (idx a) = y (idx b) := congrArg Subtype.val hab
      have hx : x (idx a) = x (idx b) := (h (idx a) (idx b)).2 hy
      exact Subtype.ext (by rw [← hidx a, ← hidx b, hx])
    have hsurj : Function.Surjective f := by
      rintro ⟨b, i, rfl⟩
      have hmem : x i ∈ S := ⟨i, rfl⟩
      refine ⟨⟨x i, hmem⟩, ?_⟩
      have hxx : x (idx ⟨x i, hmem⟩) = x i := hidx ⟨x i, hmem⟩
      exact Subtype.ext ((h _ _).1 hxx)
    let e : S ≃ T := Equiv.ofBijective f ⟨hinj, hsurj⟩
    -- a bijection between the complements, by cardinal arithmetic
    have hlt : ∀ s : Set α, s.Finite → #s < #α := by
      intro s hs
      have : Finite s := hs.to_subtype
      have h1 : #s < ℵ₀ := lt_aleph0_of_finite s
      exact lt_of_lt_of_le h1 (aleph0_le_mk α)
    have hcompl : #(Sᶜ : Set α) = #(Tᶜ : Set α) := by
      rw [mk_compl_of_infinite S (hlt S hfinS), mk_compl_of_infinite T (hlt T hfinT)]
    obtain ⟨ec⟩ : Nonempty ((Sᶜ : Set α) ≃ (Tᶜ : Set α)) := Cardinal.eq.mp hcompl
    -- glue
    refine ⟨(Equiv.Set.sumCompl S).symm.trans ((e.sumCongr ec).trans (Equiv.Set.sumCompl T)), ?_⟩
    funext i
    have hmem : x i ∈ S := ⟨i, rfl⟩
    show (Equiv.Set.sumCompl T) ((e.sumCongr ec) ((Equiv.Set.sumCompl S).symm (x i))) = y i
    rw [Equiv.Set.sumCompl_symm_apply_of_mem (s := S) hmem]
    have hxx : x (idx ⟨x i, hmem⟩) = x i := hidx ⟨x i, hmem⟩
    have h2 : y (idx ⟨x i, hmem⟩) = y i := (h _ _).1 hxx
    simpa [e, f] using h2
  · rintro ⟨σ, rfl⟩
    exact (sameKernel_perm_comp σ x).symm

/-- **Completeness over an arbitrary alphabet**: with no finiteness assumption whatsoever,
the equality pattern is a complete invariant for the action of the symmetric group of the
alphabet on tuples. -/
theorem sameKernel_iff_exists_perm_general [DecidableEq α] {x y : Fin n → α} :
    SameKernel x y ↔ ∃ σ : Equiv.Perm α, σ ∘ x = y := by
  rcases finite_or_infinite α with _ | _
  · exact sameKernel_iff_exists_perm
  · exact sameKernel_iff_exists_perm_infinite

/-- A concrete instance over the infinite alphabet `ℕ`: the tuples `(0,0,1)` and
`(5,5,7)` have the same equality pattern, hence differ by a permutation of `ℕ`. -/
theorem exists_perm_nat_example :
    ∃ σ : Equiv.Perm ℕ, σ ∘ ![0, 0, 1] = ![5, 5, 7] := by
  refine sameKernel_iff_exists_perm_general.1 ?_
  intro i j
  fin_cases i <;> fin_cases j <;> simp

/-! ## The space of symmetric functions of a tuple -/

section Invariants

variable (K : Type*) [Field K] (β : Type*) (m : ℕ)

/-- The `K`-valued functions of an `m`-tuple that are invariant under relabelling the
values by a permutation of the alphabet. -/
def invariants : Submodule K ((Fin m → β) → K) where
  carrier := {f | ∀ (σ : Equiv.Perm β) (x : Fin m → β), f (σ ∘ x) = f x}
  add_mem' hf hg := fun σ x => by
    simp only [Pi.add_apply, hf σ x, hg σ x]
  zero_mem' := fun _ _ => rfl
  smul_mem' c _ hf := fun σ x => by
    simp only [Pi.smul_apply, hf σ x]

variable {K β m}

theorem mem_invariants {f : (Fin m → β) → K} :
    f ∈ invariants K β m ↔ ∀ (σ : Equiv.Perm β) (x : Fin m → β), f (σ ∘ x) = f x := Iff.rfl

/-- Invariant functions of a tuple are the same thing as functions on the orbit space. -/
def invariantsEquiv : (Quotient (permSetoid β m) → K) ≃ₗ[K] invariants K β m where
  toFun g := ⟨fun x => g (Quotient.mk (permSetoid β m) x), by
    intro σ x
    exact congrArg g (Quotient.sound ⟨σ⁻¹, by funext i; simp⟩)⟩
  map_add' _ _ := rfl
  map_smul' _ _ := rfl
  invFun F := Quotient.lift F.1 (by
    rintro a b ⟨σ, rfl⟩
    exact (F.2 σ a).symm)
  left_inv g := by
    funext X
    induction X using Quotient.inductionOn with
    | _ x => rfl
  right_inv F := by
    apply Subtype.ext
    funext x
    rfl

/-- **The dimension of the space of symmetric functions**: for `m ≤ |β|`, the
`Equiv.Perm β`-invariant `K`-valued functions of an `m`-tuple form a space of dimension
`Nat.bell m`; the invariants are exactly the functions of the equality pattern. -/
theorem finrank_invariants [DecidableEq β] [Finite β] (hm : m ≤ Nat.card β) :
    Module.finrank K (invariants K β m) = Nat.bell m := by
  have _inst : Fintype (Quotient (permSetoid β m)) := Fintype.ofFinite _
  rw [← LinearEquiv.finrank_eq (invariantsEquiv (K := K) (β := β) (m := m)),
    Module.finrank_fintype_fun_eq_card, ← Nat.card_eq_fintype_card,
    card_orbits_eq_bell β m hm]

end Invariants

end KernelPattern