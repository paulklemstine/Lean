/-
  # Evolutionary Paths in Combinatorics, and the Set ↔ Number Bridge

  A second instantiation of `Shared.EvolutionaryPathCore`:

  * `finsetSystem` : on finite sets, a **quotient step** deletes one element,
    `S --a--> S.erase a`.  Terminal objects are exactly the empty sets and the
    decomposition invariant is the underlying multiset of the finite set.

  The point of the file is the **bridge theorem** `decomp_primeProd`:
  the map `S ↦ ∏ p ∈ S, p` from finite sets of primes to natural numbers is a
  morphism of quotient systems from the combinatorial system to the arithmetic
  system of `Shared.EvolutionaryPathArithmetic`.  Functoriality of the
  decomposition invariant then transports the combinatorial computation
  `decomp S = S.val` into the number-theoretic statement that the prime
  factorisation of `∏ p ∈ S, p` is exactly `S` — every squarefree number is
  a "combinatorial" object whose evolutionary path is a deletion order.

  * `finsetSystem`, `finset_terminal_iff`, `finsetDecomp`, `finsetHeight`
  * `primeProd_step`, `decomp_primeProd`, `primeFactorsList_primeProd`
  * `squarefree_primeProd`, `primeProd_injective`
-/
import Shared.EvolutionaryPathArithmetic

namespace Shared.EvolutionaryPath

open Finset

section Finsets

variable {ι : Type*} [DecidableEq ι]

/-- A combinatorial quotient step: delete one element of a finite set. -/
def finsetStep (S : Finset ι) (a : ι) (T : Finset ι) : Prop := a ∈ S ∧ T = S.erase a

/-- The deletion quotient system on finite sets. -/
def finsetSystem : QuotientSystem (Finset ι) ι where
  step := finsetStep
  rank := Finset.card
  rank_lt := by
    rintro S a T ⟨ha, rfl⟩
    exact Finset.card_erase_lt_of_mem ha
  label_unique := by
    rintro S a b T ⟨ha, rfl⟩ ⟨-, hT⟩
    by_contra hne
    have hmem : a ∈ S.erase b := Finset.mem_erase.2 ⟨hne, ha⟩
    rw [← hT] at hmem
    exact Finset.notMem_erase a S hmem
  exchange := by
    rintro S a T₁ b T₂ ⟨ha, rfl⟩ ⟨hb, rfl⟩ hne
    have hab : a ≠ b := by rintro rfl; exact hne rfl
    exact ⟨(S.erase a).erase b,
      ⟨Finset.mem_erase.2 ⟨hab.symm, hb⟩, rfl⟩,
      ⟨Finset.mem_erase.2 ⟨hab, ha⟩, Finset.erase_right_comm⟩⟩

@[simp] theorem finsetSystem_step {S T : Finset ι} {a : ι} :
    (finsetSystem.step S a T) ↔ (a ∈ S ∧ T = S.erase a) := Iff.rfl

/-- The terminal objects of the deletion system are precisely the empty sets. -/
theorem finset_terminal_iff (S : Finset ι) : Terminal finsetSystem S ↔ S = ∅ := by
  constructor
  · intro h
    by_contra hS
    obtain ⟨a, ha⟩ := Finset.nonempty_iff_ne_empty.2 hS
    exact h a (S.erase a) ⟨ha, rfl⟩
  · rintro rfl a T ⟨ha, -⟩
    simp at ha

theorem terminal_empty : Terminal (finsetSystem (ι := ι)) ∅ :=
  (finset_terminal_iff (∅ : Finset ι)).2 rfl

/-- **Deletion decomposition.**  Every complete deletion path of `S` uses each
element of `S` exactly once: the invariant is the underlying multiset. -/
theorem finsetDecomp (S : Finset ι) : decomp finsetSystem S = S.val := by
  induction S using Finset.induction_on with
  | empty => simpa using (terminal_iff_decomp_zero (Q := finsetSystem (ι := ι)) ∅).1 terminal_empty
  | insert a S ha ih =>
      have hstep : finsetSystem.step (insert a S) a S :=
        ⟨Finset.mem_insert_self a S, (Finset.erase_insert ha).symm⟩
      rw [decomp_step hstep, ih, Finset.insert_val_of_notMem ha]

/-- All complete deletion paths of `S` have length `#S`. -/
theorem finsetHeight (S : Finset ι) : height (Q := finsetSystem) S = S.card := by
  simp [height, finsetDecomp]

end Finsets

section Bridge

/-- The product of a finite set of primes. -/
def primeProd (S : Finset Nat.Primes) : ℕ := ∏ p ∈ S, (p : ℕ)

theorem primeProd_pos (S : Finset Nat.Primes) : 0 < primeProd S :=
  Finset.prod_pos fun p _ => p.2.pos

@[simp] theorem primeProd_empty : primeProd ∅ = 1 := by simp [primeProd]

/-- Deleting a prime from a set of primes is the same as dividing the product by
that prime: `primeProd` is a morphism of quotient systems. -/
theorem primeProd_step {S T : Finset Nat.Primes} {p : Nat.Primes}
    (h : finsetSystem.step S p T) : natSystem.step (primeProd S) (p : ℕ) (primeProd T) := by
  obtain ⟨hp, rfl⟩ := h
  refine ⟨p.2, primeProd_pos _, ?_⟩
  exact (Finset.mul_prod_erase S (fun q : Nat.Primes => (q : ℕ)) hp).symm

theorem primeProd_terminal {S : Finset Nat.Primes} (h : Terminal finsetSystem S) :
    Terminal natSystem (primeProd S) := by
  rw [(finset_terminal_iff S).1 h, primeProd_empty]
  exact terminal_one

/-- **Bridge theorem.**  The arithmetic decomposition of a product of distinct
primes is the combinatorial decomposition of the index set, transported along
the inclusion `Nat.Primes → ℕ`. -/
theorem decomp_primeProd (S : Finset Nat.Primes) :
    decomp natSystem (primeProd S) = S.val.map (fun p : Nat.Primes => (p : ℕ)) := by
  rw [decomp_map (Q := finsetSystem) (R := natSystem) primeProd (fun p : Nat.Primes => (p : ℕ))
      (fun h => primeProd_step h) (fun h => primeProd_terminal h) S, finsetDecomp]

/-- Consequently, the prime factorisation of `∏ p ∈ S, p` is exactly `S`. -/
theorem primeFactorsList_primeProd (S : Finset Nat.Primes) :
    ((primeProd S).primeFactorsList : Multiset ℕ)
      = S.val.map (fun p : Nat.Primes => (p : ℕ)) := by
  rw [← natDecomp_eq_primeFactorsList (primeProd_pos S), decomp_primeProd]

/-- A product of distinct primes is squarefree — proved through the evolutionary
bridge rather than by a direct multiplicative computation. -/
theorem squarefree_primeProd (S : Finset Nat.Primes) : Squarefree (primeProd S) := by
  rw [Nat.squarefree_iff_factorization_le_one (primeProd_pos S).ne']
  intro p
  have hcount : (decomp natSystem (primeProd S)).count p = (primeProd S).factorization p :=
    natDecomp_count_eq_factorization (primeProd_pos S) p
  rw [← hcount, decomp_primeProd]
  by_cases hp : p.Prime
  · have hinj : Function.Injective (fun q : Nat.Primes => (q : ℕ)) := fun a b hab =>
      Subtype.ext hab
    have : (S.val.map (fun q : Nat.Primes => (q : ℕ))).Nodup :=
      S.nodup.map hinj
    exact Multiset.nodup_iff_count_le_one.1 this p
  · have : p ∉ S.val.map (fun q : Nat.Primes => (q : ℕ)) := by
      simp only [Multiset.mem_map]
      rintro ⟨q, -, rfl⟩
      exact hp q.2
    simp [Multiset.count_eq_zero_of_notMem this]

/-- The prime-product map is injective: distinct finite sets of primes have
distinct products.  (Uniqueness of factorisation, read through the bridge.) -/
theorem primeProd_injective : Function.Injective primeProd := by
  intro S T h
  have hS := decomp_primeProd S
  have hT := decomp_primeProd T
  rw [h, hT] at hS
  have hinj : Function.Injective (fun q : Nat.Primes => (q : ℕ)) := fun a b hab => Subtype.ext hab
  have : S.val = T.val := Multiset.map_injective hinj hS.symm
  exact Finset.val_injective this

end Bridge

end Shared.EvolutionaryPath