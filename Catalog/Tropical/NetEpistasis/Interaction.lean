/-
# Higher-order interactions: the Möbius decomposition of a pruning-cost profile

Pairwise epistasis is the second-order term of a complete hierarchy.  For a cost
profile `c` on subsets of layers, the *interaction coefficients* are the Möbius
transform

  `mob c A = ∑_{B ⊆ A} (-1)^{|A \ B|} c B`,

and `sum_mob` proves the inversion `c S = ∑_{A ⊆ S} mob c A`: every joint
ablation cost splits uniquely into a sum of pure interactions of all orders.

Specializing:
* order 1 is the solo cost (`mob_singleton`);
* order 2 *is* the epistasis measured by NET-60 (`epi_eq_mob`);
* order 3 gives the compounding law for the tail triple
  (`triple_compounding`): the excess of a triple over its solo sum is the sum of
  its three pairwise epistases plus one genuinely third-order term.

The proof of the inversion is by induction on `S`, generalizing over the profile
`c`; the inductive step uses that shifting a profile by `insert x` turns the
Möbius transform at `insert x A` into a difference of two transforms at `A`.
-/
import Tropical.NetEpistasis.Core

namespace NetEpistasis

open Finset

variable {n : ℕ}

/-- Möbius (pure interaction) coefficient of a cost profile at a layer set. -/
def mob (c : Finset (Fin n) → ℚ) (A : Finset (Fin n)) : ℚ :=
  ∑ B ∈ A.powerset, (-1 : ℚ) ^ (A \ B).card * c B

@[simp] lemma mob_empty (c : Finset (Fin n) → ℚ) : mob c ∅ = c ∅ := by
  simp [mob]

/-- Adding a fresh layer to the interaction set: the transform at `insert x A` is
the transform of the `x`-shifted profile minus the transform of the profile. -/
lemma mob_insert (c : Finset (Fin n) → ℚ) {x : Fin n} {A : Finset (Fin n)} (hx : x ∉ A) :
    mob c (insert x A) = mob (fun B => c (insert x B)) A - mob c A := by
  classical
  unfold mob
  rw [Finset.sum_powerset_insert hx]
  have h1 : ∀ B ∈ A.powerset,
      (-1 : ℚ) ^ (insert x A \ B).card * c B = -((-1 : ℚ) ^ (A \ B).card * c B) := by
    intro B hB
    have hBA : B ⊆ A := Finset.mem_powerset.mp hB
    have hcard : (insert x A \ B).card = (A \ B).card + 1 := by
      rw [Finset.insert_sdiff_of_notMem _ (fun h => hx (hBA h)),
        Finset.card_insert_of_notMem]
      simp only [Finset.mem_sdiff, not_and]
      intro h; exact absurd h hx
    rw [hcard, pow_succ]
    ring
  have h2 : ∀ B ∈ A.powerset,
      (-1 : ℚ) ^ (insert x A \ insert x B).card * c (insert x B)
        = (-1 : ℚ) ^ (A \ B).card * c (insert x B) := by
    intro B hB
    have hBA : B ⊆ A := Finset.mem_powerset.mp hB
    have hset : insert x A \ insert x B = A \ B := by
      ext y
      simp only [Finset.mem_sdiff, Finset.mem_insert, not_or]
      constructor
      · rintro ⟨h1 | h1, h2, h3⟩ <;> tauto
      · rintro ⟨h1, h2⟩
        exact ⟨Or.inr h1, fun h => hx (h ▸ h1), h2⟩
    rw [hset]
  rw [Finset.sum_congr rfl h1, Finset.sum_congr rfl h2, Finset.sum_neg_distrib]
  ring

/-- **Möbius inversion for pruning costs.**  Every joint ablation cost is the sum
of the pure interactions of all its sub-collections of layers. -/
theorem sum_mob (c : Finset (Fin n) → ℚ) (S : Finset (Fin n)) :
    ∑ A ∈ S.powerset, mob c A = c S := by
  classical
  induction S using Finset.induction_on generalizing c with
  | empty => simp
  | insert x S₀ hx ih =>
      rw [Finset.sum_powerset_insert hx]
      have hstep : ∀ A ∈ S₀.powerset,
          mob c (insert x A) = mob (fun B => c (insert x B)) A - mob c A := by
        intro A hA
        exact mob_insert c (fun h => hx (Finset.mem_powerset.mp hA h))
      rw [Finset.sum_congr rfl hstep, Finset.sum_sub_distrib, ih (fun B => c (insert x B))]
      ring

/-- First-order interaction: the solo cost. -/
lemma mob_singleton (c : Finset (Fin n) → ℚ) (i : Fin n) : mob c {i} = c {i} - c ∅ := by
  have h : ({i} : Finset (Fin n)) = insert i ∅ := rfl
  rw [h, mob_insert c (Finset.notMem_empty i)]
  simp

/-- Second-order interaction. -/
lemma mob_pair (c : Finset (Fin n) → ℚ) {a b : Fin n} (hab : a ≠ b) :
    mob c {a, b} = c {a, b} - c {a} - c {b} + c ∅ := by
  have hx : a ∉ ({b} : Finset (Fin n)) := by simpa using hab
  rw [show ({a, b} : Finset (Fin n)) = insert a {b} from rfl, mob_insert c hx,
    mob_singleton, mob_singleton]
  have h1 : (insert a ({b} : Finset (Fin n))) = {a, b} := rfl
  have h2 : (insert a (∅ : Finset (Fin n))) = {a} := rfl
  rw [h1, h2]
  ring

/-- Third-order interaction. -/
lemma mob_triple (c : Finset (Fin n) → ℚ) {a b d : Fin n} (hab : a ≠ b) (had : a ≠ d)
    (hbd : b ≠ d) :
    mob c {a, b, d}
      = c {a, b, d} - c {a, b} - c {a, d} - c {b, d} + c {a} + c {b} + c {d} - c ∅ := by
  have hx : a ∉ ({b, d} : Finset (Fin n)) := by
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or]
    exact ⟨hab, had⟩
  rw [show ({a, b, d} : Finset (Fin n)) = insert a {b, d} from rfl, mob_insert c hx,
    mob_pair _ hbd, mob_pair _ hbd]
  have h4 : (insert a (∅ : Finset (Fin n))) = {a} := rfl
  simp only [h4]
  ring

/-- **Pairwise epistasis is exactly the second-order Möbius coefficient** of the
pruning-cost profile. -/
theorem epi_eq_mob (N : PrunableNet n) {a b : Fin n} (hab : a ≠ b) :
    epi N {a} {b} = mob (cost N) {a, b} := by
  rw [mob_pair _ hab, cost_empty]
  simp only [epi, show ({a} ∪ {b} : Finset (Fin n)) = {a, b} from rfl]
  ring

/-- **Compounding law.**  The excess of a triple ablation over the sum of its
solo costs is the sum of its three pairwise epistases plus a genuine third-order
interaction.  This is why a triple can compound beyond its pairs. -/
theorem triple_compounding (N : PrunableNet n) {a b d : Fin n} (hab : a ≠ b) (had : a ≠ d)
    (hbd : b ≠ d) :
    cost N {a, b, d} - (cost N {a} + cost N {b} + cost N {d})
      = epi N {a} {b} + epi N {a} {d} + epi N {b} {d} + mob (cost N) {a, b, d} := by
  rw [mob_triple _ hab had hbd, epi_eq_mob N hab, epi_eq_mob N had, epi_eq_mob N hbd,
    mob_pair _ hab, mob_pair _ had, mob_pair _ hbd, cost_empty]
  ring

end NetEpistasis