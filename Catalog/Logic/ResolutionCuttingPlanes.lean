import Mathlib
import Computation.PosetTheory.WidthToSize

/-!
# Resolution and Cutting Planes

This file builds on the catalog's resolution syntax in
`Computation.PosetTheory.WidthToSize`.  It supplies semantic soundness, the
unsatisfiability of the pigeonhole CNF, and a typed cutting-planes calculus with
soundness and a linear-size pigeonhole refutation.
-/

namespace ProofComplexity

open WidthToSize

namespace Resolution

/-- A resolution refutation is a resolution tree deriving the empty clause. -/
abbrev Refutation {ν : Type} [DecidableEq ν] (F : CNF ν) := ResTree F ∅

/-- Every clause derived by the catalog's resolution rules is satisfied by any
assignment satisfying all initial clauses. -/
theorem resolution_sound {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) (τ : ν → Bool) (hτ : CNF.Satisfied τ F) :
    Clause.Satisfied τ C := by
  induction t with
  | hyp C hC => exact hτ C hC
  | weaken C D hCD t ih =>
      obtain ⟨l, hl, he⟩ := ih
      exact ⟨l, hCD hl, he⟩
  | resolve x C D t₁ t₂ ih₁ ih₂ =>
      by_cases hx : τ x = true
      · obtain ⟨l, hl, he⟩ := ih₂
        simp only [Finset.mem_insert] at hl
        rcases hl with rfl | hl
        · simp [Lit.eval, hx] at he
        · exact ⟨l, Finset.mem_union_right C hl, he⟩
      · obtain ⟨l, hl, he⟩ := ih₁
        simp only [Finset.mem_insert] at hl
        rcases hl with rfl | hl
        · simp [Lit.eval, hx] at he
        · exact ⟨l, Finset.mem_union_left D hl, he⟩

/-- Consequently a resolution refutation certifies semantic unsatisfiability. -/
theorem refutation_implies_unsatisfiable {ν : Type} [DecidableEq ν] {F : CNF ν}
    (t : Refutation F) : CNF.Unsatisfiable F := by
  intro τ hτ
  exact Clause.not_satisfied_empty τ (resolution_sound t τ hτ)

/-- Each pigeon clause belongs to the pigeonhole CNF. -/
lemma pigeonClause_mem (m n : ℕ) (i : Fin m) :
    (Finset.univ.image fun j : Fin n => Lit.pos (i, j)) ∈ phpCNF m n := by
  apply Finset.mem_union_left
  simp [phpAtLeastOne]

/-- Each pairwise collision clause belongs to the pigeonhole CNF. -/
lemma collisionClause_mem (m n : ℕ) (j : Fin n) (i k : Fin m) (hik : i < k) :
    ({Lit.neg (i, j), Lit.neg (k, j)} : Clause (PHPVar m n)) ∈ phpCNF m n := by
  apply Finset.mem_union_right
  simp [phpAtMostOne]
  exact ⟨j, i, k, hik, rfl⟩

/-- A satisfying assignment chooses at least one occupied hole for every pigeon. -/
lemma occupied_hole {m n : ℕ} (τ : PHPVar m n → Bool)
    (hτ : CNF.Satisfied τ (phpCNF m n)) (i : Fin m) :
    ∃ j : Fin n, τ (i, j) = true := by
  obtain ⟨l, hl, he⟩ := hτ _ (pigeonClause_mem m n i)
  simp only [Finset.mem_image] at hl
  obtain ⟨j, _, rfl⟩ := hl
  exact ⟨j, he⟩

/-- Two pigeons selected by a satisfying assignment cannot use the same hole. -/
lemma selected_holes_ne {m n : ℕ} (τ : PHPVar m n → Bool)
    (hτ : CNF.Satisfied τ (phpCNF m n)) {i k : Fin m} (hik : i < k)
    {j : Fin n} (hi : τ (i, j) = true) (hk : τ (k, j) = true) : False := by
  obtain ⟨l, hl, he⟩ := hτ _ (collisionClause_mem m n j i k hik)
  simp only [Finset.mem_insert, Finset.mem_singleton] at hl
  rcases hl with rfl | rfl <;> simp [Lit.eval, hi, hk] at he

/-- The catalog's pigeonhole CNF really is unsatisfiable when there are `n+1`
pigeons and `n` holes. -/
theorem pigeonhole_unsatisfiable (n : ℕ) :
    CNF.Unsatisfiable (phpCNF (n + 1) n) := by
  intro τ hτ
  classical
  let f : Fin (n + 1) → Fin n := fun i => Classical.choose (occupied_hole τ hτ i)
  have hf : ∀ i, τ (i, f i) = true := fun i => Classical.choose_spec (occupied_hole τ hτ i)
  have hinj : Function.Injective f := by
    intro i k heq
    apply le_antisymm
    · apply not_lt.mp
      intro hki
      exact selected_holes_ne τ hτ hki (hf k) (heq ▸ hf i)
    · apply not_lt.mp
      intro hik
      exact selected_holes_ne τ hτ hik (hf i) (heq ▸ hf k)
  have := Fintype.card_le_of_injective f hinj
  simp at this

/-- The established catalog lower bound, exposed at the semantic-refutation
interface.  This is the fully formal tree-resolution lower bound currently
available in the catalog. -/
theorem pigeonhole_tree_resolution_lower_bound (n : ℕ) (hn : 0 < n)
    (t : Refutation (phpCNF (n + 1) n)) : n + 1 ≤ t.size := by
  exact php_tree_size_lower_bound n hn t

end Resolution

namespace CuttingPlanes

variable {ν : Type} [Fintype ν] [DecidableEq ν]

/-- A linear integer inequality `bound ≤ ∑ x, coeff x * assignment x`. -/
@[ext] structure Inequality (ν : Type) where
  coeff : ν → ℤ
  bound : ℤ

/-- Boolean assignments interpreted as zero-one integer vectors. -/
def value (τ : ν → Bool) (q : Inequality ν) : ℤ :=
  ∑ x, q.coeff x * (if τ x then 1 else 0)

/-- Semantic satisfaction of a cutting-planes inequality. -/
def Satisfies (τ : ν → Bool) (q : Inequality ν) : Prop := q.bound ≤ value τ q

/-- Pointwise sum of inequalities. -/
def add (p q : Inequality ν) : Inequality ν where
  coeff x := p.coeff x + q.coeff x
  bound := p.bound + q.bound

/-- Multiplication by a nonnegative integer. -/
def scale (k : ℕ) (q : Inequality ν) : Inequality ν where
  coeff x := (k : ℤ) * q.coeff x
  bound := (k : ℤ) * q.bound

/-- The identically-zero left side with a positive lower bound is contradictory. -/
def Contradiction (q : Inequality ν) : Prop :=
  (∀ x, q.coeff x = 0) ∧ 0 < q.bound

/-- Cutting-planes derivations from a finite set of initial inequalities. -/
inductive Derivation (A : Finset (Inequality ν)) : Inequality ν → Type
  | hyp (q : Inequality ν) (hq : q ∈ A) : Derivation A q
  | add {p q : Inequality ν} : Derivation A p → Derivation A q → Derivation A (add p q)
  | scale (k : ℕ) {q : Inequality ν} : Derivation A q → Derivation A (scale k q)

/-- Number of nodes in a cutting-planes derivation. -/
def Derivation.size {A : Finset (Inequality ν)} {q : Inequality ν} :
    Derivation A q → ℕ
  | .hyp _ _ => 1
  | .add hp hq => 1 + hp.size + hq.size
  | .scale _ h => 1 + h.size

omit [Fintype ν] [DecidableEq ν] in
@[simp] theorem Derivation.size_add {A : Finset (Inequality ν)}
    {p q : Inequality ν} (hp : Derivation A p) (hq : Derivation A q) :
    (Derivation.add hp hq).size = 1 + hp.size + hq.size := by
  rfl

omit [Fintype ν] [DecidableEq ν] in
@[simp] theorem Derivation.size_hyp {A : Finset (Inequality ν)}
    (q : Inequality ν) (hq : q ∈ A) :
    (Derivation.hyp q hq).size = 1 := by
  rfl

omit [DecidableEq ν] in
/-- Addition preserves validity. -/
theorem satisfies_add (τ : ν → Bool) {p q : Inequality ν}
    (hp : Satisfies τ p) (hq : Satisfies τ q) : Satisfies τ (add p q) := by
  unfold Satisfies value at *
  change p.bound + q.bound ≤ ∑ x, (p.coeff x + q.coeff x) * (if τ x then 1 else 0)
  simp only [add_mul, Finset.sum_add_distrib]
  omega

omit [DecidableEq ν] in
/-- Nonnegative integral scaling preserves validity. -/
theorem satisfies_scale (τ : ν → Bool) (k : ℕ) {q : Inequality ν}
    (hq : Satisfies τ q) : Satisfies τ (scale k q) := by
  unfold Satisfies value at *
  change (k : ℤ) * q.bound ≤
    ∑ x, ((k : ℤ) * q.coeff x) * (if τ x then 1 else 0)
  have heq : (∑ x, ((k : ℤ) * q.coeff x) * (if τ x then 1 else 0)) =
      (k : ℤ) * ∑ x, q.coeff x * (if τ x then 1 else 0) := by
    rw [Finset.mul_sum]
    congr 1
    funext x
    ring
  rw [heq]
  exact mul_le_mul_of_nonneg_left hq (Int.natCast_nonneg k)

omit [DecidableEq ν] in
/-- Soundness of every cutting-planes derivation. -/
theorem cuttingPlanes_sound {A : Finset (Inequality ν)} {q : Inequality ν}
    (d : Derivation A q) (τ : ν → Bool)
    (hA : ∀ p ∈ A, Satisfies τ p) : Satisfies τ q := by
  induction d with
  | hyp q hq => exact hA q hq
  | add hp hq ihp ihq => exact satisfies_add τ ihp ihq
  | scale k h ih => exact satisfies_scale τ k ih

omit [DecidableEq ν] in
/-- A derived contradictory inequality proves that the initial inequalities
have no Boolean solution. -/
theorem refutation_implies_unsatisfiable {A : Finset (Inequality ν)}
    {q : Inequality ν} (d : Derivation A q) (hq : Contradiction q) :
    ∀ τ : ν → Bool, ¬ ∀ p ∈ A, Satisfies τ p := by
  intro τ hA
  have hs := cuttingPlanes_sound d τ hA
  rcases hq with ⟨hc, hb⟩
  unfold Satisfies value at hs
  simp [hc] at hs
  omega

/-- Sum a finite family of inequalities. -/
def sumIneq {ι : Type} (s : Finset ι) (q : ι → Inequality ν) : Inequality ν where
  coeff x := ∑ i ∈ s, (q i).coeff x
  bound := ∑ i ∈ s, (q i).bound

/-- The zero inequality. -/
def zero : Inequality ν where
  coeff _ := 0
  bound := 0

/-- A derivation for a finite sum, with the zero inequality supplied as a
standard harmless initial inequality. -/
noncomputable def derive_sum {ι : Type} [DecidableEq ι] (A : Finset (Inequality ν))
    (s : Finset ι) (q : ι → Inequality ν)
    (hz : zero ∈ A) (hmem : ∀ i ∈ s, q i ∈ A) :
    Derivation A (sumIneq s q) := by
  classical
  apply Classical.choice
  have aux : ∀ (s : Finset ι), (∀ i ∈ s, q i ∈ A) →
      Nonempty (Derivation A (sumIneq s q)) := by
    intro s
    induction s using Finset.induction_on with
    | empty =>
        intro _
        exact ⟨by simpa [sumIneq, zero] using Derivation.hyp zero hz⟩
    | @insert i s hi ih =>
        intro hs
        obtain ⟨ds⟩ := ih (fun j hj => hs j (by simp [hj]))
        have di : Derivation A (q i) := Derivation.hyp (q i) (hs i (by simp))
        refine ⟨?_⟩
        have da : Derivation A (add (q i) (sumIneq s q)) := Derivation.add di ds
        have heq : add (q i) (sumIneq s q) = sumIneq (insert i s) q := by
          cases qi : q i with
          | mk coeff bound =>
            simp only [add, sumIneq]
            congr
            · funext x
              simp [hi, qi]
            · simp [hi, qi]
        exact heq ▸ da
  exact aux s hmem

/-- Pigeon `i` occupies at least one hole. -/
def pigeonAxiom (m n : ℕ) (i : Fin m) : Inequality (Fin m × Fin n) where
  coeff p := if p.1 = i then 1 else 0
  bound := 1

/-- Hole `j` contains at most one pigeon, written with negated coefficients. -/
def holeAxiom (m n : ℕ) (j : Fin n) : Inequality (Fin m × Fin n) where
  coeff p := if p.2 = j then -1 else 0
  bound := -1

/-- The aggregate of all pigeon and hole inequalities. -/
def pigeonholeAggregate (m n : ℕ) : Inequality (Fin m × Fin n) :=
  add (sumIneq Finset.univ (pigeonAxiom m n))
    (sumIneq Finset.univ (holeAxiom m n))

/-- Every variable cancels in the aggregate pigeonhole inequality. -/
theorem pigeonholeAggregate_coeff (m n : ℕ) (p : Fin m × Fin n) :
    (pigeonholeAggregate m n).coeff p = 0 := by
  simp [pigeonholeAggregate, add, sumIneq, pigeonAxiom, holeAxiom]

/-- Its lower bound is `m-n`. -/
theorem pigeonholeAggregate_bound (m n : ℕ) :
    (pigeonholeAggregate m n).bound = (m : ℤ) - (n : ℤ) := by
  simp [pigeonholeAggregate, add, sumIneq, pigeonAxiom, holeAxiom]
  omega

/-- Cutting planes has a direct pigeonhole refutation: summing the `m` pigeon
inequalities and `n` hole inequalities yields `m-n ≤ 0`, contradictory for
`n < m`. -/
theorem pigeonhole_refutation (m n : ℕ) (h : n < m)
    (A : Finset (Inequality (Fin m × Fin n)))
    (hz : zero ∈ A)
    (hp : ∀ i : Fin m, pigeonAxiom m n i ∈ A)
    (hh : ∀ j : Fin n, holeAxiom m n j ∈ A) :
    ∃ q, Nonempty (Derivation A q) ∧ Contradiction q := by
  let dp := derive_sum A Finset.univ (pigeonAxiom m n) hz (by simpa using hp)
  let dh := derive_sum A Finset.univ (holeAxiom m n) hz (by simpa using hh)
  refine ⟨pigeonholeAggregate m n, ⟨Derivation.add dp dh⟩, ?_⟩
  constructor
  · exact pigeonholeAggregate_coeff m n
  · rw [pigeonholeAggregate_bound]
    exact sub_pos.mpr (by exact_mod_cast h)

omit [Fintype ν] [DecidableEq ν] in
/-- A finite sum has a derivation with at most two nodes per summand,
plus its zero leaf. -/
theorem exists_sum_derivation_size {ι : Type} [DecidableEq ι]
    (A : Finset (Inequality ν)) (s : Finset ι) (q : ι → Inequality ν)
    (hz : zero ∈ A) (hmem : ∀ i ∈ s, q i ∈ A) :
    Nonempty {d : Derivation A (sumIneq s q) // d.size ≤ 2 * s.card + 1} := by
  classical
  induction s using Finset.induction_on with
  | empty =>
      have heq : sumIneq (∅ : Finset ι) q = zero := by
        ext x <;> simp [sumIneq, zero]
      rw [heq]
      exact ⟨⟨Derivation.hyp zero hz, by simp [Derivation.size]⟩⟩
  | @insert i s hi ih =>
      obtain ⟨⟨ds, hsize⟩⟩ := ih (fun j hj => hmem j (by simp [hj]))
      let di : Derivation A (q i) := Derivation.hyp (q i) (hmem i (by simp))
      have heq : add (q i) (sumIneq s q) = sumIneq (insert i s) q := by
        cases qi : q i with
        | mk coeff bound =>
          simp only [add, sumIneq]
          congr
          · funext x
            simp [hi, qi]
          · simp [hi, qi]
      rw [← heq]
      refine ⟨⟨Derivation.add di ds, ?_⟩⟩
      rw [Derivation.size_add]
      have hdi : di.size = 1 := by
        unfold di
        exact Derivation.size_hyp _ _
      rw [hdi]
      simp [hi]
      omega

/-- Explicit linear node bound for the direct cutting-planes pigeonhole refutation. -/
theorem pigeonhole_refutation_size (m n : ℕ) (h : n < m)
    (A : Finset (Inequality (Fin m × Fin n)))
    (hz : zero ∈ A)
    (hp : ∀ i : Fin m, pigeonAxiom m n i ∈ A)
    (hh : ∀ j : Fin n, holeAxiom m n j ∈ A) :
    Nonempty (Σ q, {d : Derivation A q // Contradiction q ∧
      d.size ≤ 2 * (m + n) + 3}) := by
  obtain ⟨⟨dp, hpSize⟩⟩ :=
    exists_sum_derivation_size A Finset.univ (pigeonAxiom m n) hz (by simpa using hp)
  obtain ⟨⟨dh, hhSize⟩⟩ :=
    exists_sum_derivation_size A Finset.univ (holeAxiom m n) hz (by simpa using hh)
  let d : Derivation A (pigeonholeAggregate m n) := Derivation.add dp dh
  refine ⟨⟨pigeonholeAggregate m n, ⟨d, ?_, ?_⟩⟩⟩
  · exact ⟨pigeonholeAggregate_coeff m n, by
      rw [pigeonholeAggregate_bound]
      exact sub_pos.mpr (by exact_mod_cast h)⟩
  · dsimp [d, Derivation.size]
    simp only [Finset.card_univ, Fintype.card_fin] at hpSize hhSize
    omega

end CuttingPlanes

end ProofComplexity