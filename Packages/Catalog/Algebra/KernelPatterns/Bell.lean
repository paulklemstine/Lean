/-
# Kernel patterns are counted by the Bell numbers

Combining `Algebra.KernelPatterns.Core` (the kernel of a tuple is a complete
`Equiv.Perm α`-invariant, encoded by an idempotent contracting retraction of the index
set) with `Algebra.KernelPatterns.SetoidCount` (equivalence relations on an `n`-element
set are counted by `Nat.bell n`), we obtain:

* `KernelPattern.patternEquivSetoid` — patterns on `n` letters *are* the equivalence
  relations on `Fin n`;
* `KernelPattern.card_pattern` — there are exactly `Nat.bell n` patterns;
* `KernelPattern.card_orbits_eq_bell` — for `n ≤ Fintype.card α` the symmetric group
  `Equiv.Perm α` has exactly `Nat.bell n` orbits on the set of `n`-tuples `Fin n → α`;
* the first six values `1, 1, 2, 5, 15, 52` (OEIS A000110), each verified by `decide`
  on the concrete finite type of patterns and matched against `Nat.bell`.
-/
import Algebra.KernelPatterns.Core
import Algebra.KernelPatterns.SetoidCount

namespace KernelPattern

variable {α : Type*} {n : ℕ}

/-! ## Patterns are equivalence relations -/

theorem kerSetoid_canon [DecidableEq α] (x : Fin n → α) : kerSetoid (canon x) = kerSetoid x :=
  sameKernel_iff_kerSetoid_eq.1 fun i j => canon_eq_iff x i j

/-- The pattern attached to an equivalence relation on `Fin n`: the canonical form of
the quotient map. -/
noncomputable def patternOfSetoid (s : Setoid (Fin n)) : Pattern n := by
  classical exact patternOf (fun i => Quotient.mk s i)

theorem kerSetoid_quotientMk (s : Setoid (Fin n)) :
    kerSetoid (fun i => Quotient.mk s i) = s := by
  refine Setoid.ext fun i j => ?_
  show (Quotient.mk s i = Quotient.mk s j) ↔ _
  exact Quotient.eq

/-- **Patterns are exactly the equivalence relations on the index set.** -/
noncomputable def patternEquivSetoid : Pattern n ≃ Setoid (Fin n) where
  toFun p := kerSetoid p.1
  invFun s := patternOfSetoid s
  left_inv := by
    classical
    rintro ⟨p, hp⟩
    apply Subtype.ext
    have hsame : SameKernel (fun i => Quotient.mk (kerSetoid p) i) p := by
      intro i j
      show (Quotient.mk (kerSetoid p) i = Quotient.mk (kerSetoid p) j) ↔ _
      exact Quotient.eq
    show canon (fun i => Quotient.mk (kerSetoid p) i) = p
    rw [sameKernel_iff_canon_eq.1 hsame, canon_eq_self_of_isPattern hp]
  right_inv := by
    classical
    intro s
    show kerSetoid (canon (fun i => Quotient.mk s i)) = s
    rw [kerSetoid_canon, kerSetoid_quotientMk]

/-- **The number of patterns on `n` letters is the `n`-th Bell number.** -/
theorem card_pattern (n : ℕ) : Fintype.card (Pattern n) = Nat.bell n := by
  have h1 : Nat.card (Pattern n) = Nat.card (Setoid (Fin n)) :=
    Nat.card_congr patternEquivSetoid
  rw [← Nat.card_eq_fintype_card, h1, ← numSetoid, numSetoid_eq_bell]

/-! ## Orbits of the symmetric group on tuples -/

/-- Two tuples are equivalent when they lie in the same `Equiv.Perm α`-orbit. -/
def permSetoid (α : Type*) (n : ℕ) : Setoid (Fin n → α) where
  r x y := ∃ σ : Equiv.Perm α, σ ∘ x = y
  iseqv := by
    refine ⟨fun x => ⟨1, rfl⟩, ?_, ?_⟩
    · rintro x y ⟨σ, rfl⟩
      exact ⟨σ⁻¹, by funext i; simp⟩
    · rintro x y z ⟨σ, rfl⟩ ⟨τ, rfl⟩
      exact ⟨τ * σ, by funext i; simp⟩

/-- The pattern map is constant on orbits, hence descends to the orbit space. -/
noncomputable def orbitPattern [DecidableEq α] : Quotient (permSetoid α n) → Pattern n :=
  Quotient.lift patternOf (by
    rintro x y ⟨σ, rfl⟩
    exact (Subtype.ext (canon_comp_of_injective σ.injective x) :
      patternOf (⇑σ ∘ x) = patternOf x).symm)

theorem orbitPattern_mk [DecidableEq α] (x : Fin n → α) :
    orbitPattern (Quotient.mk (permSetoid α n) x) = patternOf x := rfl

theorem orbitPattern_injective [DecidableEq α] [Finite α] :
    Function.Injective (orbitPattern (α := α) (n := n)) := by
  intro X Y h
  induction X using Quotient.inductionOn with
  | _ x =>
    induction Y using Quotient.inductionOn with
    | _ y =>
      rw [orbitPattern_mk, orbitPattern_mk] at h
      exact Quotient.sound (patternOf_eq_iff_exists_perm.1 h)

theorem orbitPattern_surjective [DecidableEq α] [Finite α] (hn : n ≤ Nat.card α) :
    Function.Surjective (orbitPattern (α := α) (n := n)) := by
  have _inst : Fintype α := Fintype.ofFinite α
  rintro ⟨p, hp⟩
  obtain ⟨e⟩ : Nonempty (Fin n ↪ α) := by
    apply Function.Embedding.nonempty_of_card_le
    simpa [Nat.card_eq_fintype_card] using hn
  obtain ⟨f, hf⟩ : ∃ f : Fin n → α, Function.Injective f := ⟨e, e.injective⟩
  refine ⟨Quotient.mk (permSetoid α n) (f ∘ p), ?_⟩
  rw [orbitPattern_mk]
  exact Subtype.ext (by
    rw [patternOf_val, canon_comp_of_injective hf p, canon_eq_self_of_isPattern hp])

/-- **Orbit count**: if `n ≤ |α|`, the symmetric group of `α` has exactly `Nat.bell n`
orbits on the `n`-tuples over `α`; the complete invariant is the equality pattern. -/
theorem card_orbits_eq_bell (α : Type*) [DecidableEq α] [Finite α] (n : ℕ)
    (hn : n ≤ Nat.card α) : Nat.card (Quotient (permSetoid α n)) = Nat.bell n := by
  have hbij : Function.Bijective (orbitPattern (α := α) (n := n)) :=
    ⟨orbitPattern_injective, orbitPattern_surjective hn⟩
  rw [Nat.card_congr (Equiv.ofBijective _ hbij), Nat.card_eq_fintype_card, card_pattern]

/-! ## The first Bell numbers, by `decide`

The finite type `Pattern n` is decidable, so the values `1, 1, 2, 5, 15, 52`
(OEIS A000110) can be checked by kernel computation, and then transferred to
`Nat.bell` and to the orbit counts through the theorems above. -/

theorem card_pattern_zero : Fintype.card (Pattern 0) = 1 := by decide
theorem card_pattern_one : Fintype.card (Pattern 1) = 1 := by decide
theorem card_pattern_two : Fintype.card (Pattern 2) = 2 := by decide
theorem card_pattern_three : Fintype.card (Pattern 3) = 5 := by decide

set_option maxRecDepth 4000 in
theorem card_pattern_four : Fintype.card (Pattern 4) = 15 := by decide

set_option maxRecDepth 40000 in
theorem card_pattern_five : Fintype.card (Pattern 5) = 52 := by decide

/-- The first six Bell numbers, obtained by counting patterns with `decide`. -/
theorem bell_values :
    (Nat.bell 0, Nat.bell 1, Nat.bell 2, Nat.bell 3, Nat.bell 4, Nat.bell 5)
      = (1, 1, 2, 5, 15, 52) := by
  refine Prod.ext ?_ (Prod.ext ?_ (Prod.ext ?_ (Prod.ext ?_ (Prod.ext ?_ ?_))))
  · exact (card_pattern 0).symm.trans card_pattern_zero
  · exact (card_pattern 1).symm.trans card_pattern_one
  · exact (card_pattern 2).symm.trans card_pattern_two
  · exact (card_pattern 3).symm.trans card_pattern_three
  · exact (card_pattern 4).symm.trans card_pattern_four
  · exact (card_pattern 5).symm.trans card_pattern_five

/-- The symmetric group `S₅` has exactly `52` orbits on `5`-tuples of elements of
`Fin 5`. -/
theorem orbits_fin_five : Nat.card (Quotient (permSetoid (Fin 5) 5)) = 52 := by
  rw [card_orbits_eq_bell (Fin 5) 5 (by simp)]
  exact (card_pattern 5).symm.trans card_pattern_five

end KernelPattern