/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Matroid Minors and the Robertson-Seymour Conjecture for Representable Matroids

This file develops the theory of matroid minors, minor-closed properties, and the
connection to well-quasi-ordering. We formalize:

1. **Minor-closed properties**: A property of matroids is minor-closed if it is preserved
   under taking minors.
2. **Forbidden minor characterization**: If a class of matroids is WQO by the minor relation,
   then any minor-closed property is characterized by a finite set of forbidden minors.
3. **Representable matroids**: A matroid is F-representable if its independent sets correspond
   to linearly independent sets of vectors over F.
4. **Representability is minor-closed**: Deletion preserves representability.
5. **Duality and minors**: The dual of a minor is a minor of the dual.

## Main Results

* `MinorClosed`: Definition of minor-closed properties.
* `FRepresentable`: Definition of representable matroids over a field.
* `isRepresentable_delete`: Representability is preserved under deletion.
* `dual_isMinor_dual`: The dual of a minor is a minor of the dual.
* `wqo_forbidden_minor_finite`: WQO → finite forbidden minors for any minor-closed property.
* `ggw_implies_finite_excluded_minors`: GGW conjecture → finite excluded minors.

## References

* Geelen, Gerards, Whittle: "Towards a structure theory for matrices and matroids"
* Robertson, Seymour: "Graph Minors" series
* Oxley: "Matroid Theory"
-/

open Set Matroid

noncomputable section

variable {α : Type*}

/-! ## Minor-Closed Properties -/

/-- A property of matroids is **minor-closed** if whenever `M` satisfies the property
and `N` is a minor of `M`, then `N` also satisfies the property. -/
def MinorClosed (P : Matroid α → Prop) : Prop :=
  ∀ M N : Matroid α, P M → N ≤m M → P N

/-- A matroid `N` is a **forbidden minor** for a property `P` if `N` does not satisfy `P`,
but every proper minor of `N` does satisfy `P`. -/
def IsForbiddenMinor (P : Matroid α → Prop) (N : Matroid α) : Prop :=
  ¬ P N ∧ ∀ M : Matroid α, M <m N → P M

/-- The set of all forbidden minors for a minor-closed property. -/
def ForbiddenMinors (P : Matroid α → Prop) : Set (Matroid α) :=
  { N | IsForbiddenMinor P N }

/-- A matroid minor antichain is a set of matroids where no one is a minor of another. -/
def IsMinorAntichain (S : Set (Matroid α)) : Prop :=
  ∀ M N : Matroid α, M ∈ S → N ∈ S → M ≠ N → ¬(M ≤m N)

/-! ## Duality and Minors -/

/-
The dual of a minor is a minor of the dual. This is a fundamental structural result
in matroid theory connecting duality with the minor relation.

Proof: If `N = M ／ C ＼ D`, then `N✶ = (M ／ C ＼ D)✶ = (M ／ C)✶ ／ D`
and since contraction is defined as `M ／ C = (M✶ ＼ C)✶`, we have
`(M ／ C)✶ = M✶ ＼ C`, so `N✶ = (M✶ ＼ C) ／ D = M✶ ／ D ＼ C` (after commuting).
-/
theorem dual_isMinor_dual {M N : Matroid α} (h : N ≤m M) : N✶ ≤m M✶ := by
  obtain ⟨ C, D, h ⟩ := h;
  grind +suggestions

/-! ## Forbidden Minor Properties -/

/-- Every strict minor of a forbidden minor satisfies the property.
This is immediate from the definition. -/
theorem forbidden_minor_strict {P : Matroid α → Prop} (_hP : MinorClosed P)
    (N : Matroid α) (hN : IsForbiddenMinor P N) (M : Matroid α) (hM : M <m N) :
    P M :=
  hN.2 M hM

/-
The forbidden minors of a minor-closed property form an antichain under
the minor relation. No forbidden minor can be a minor of another forbidden minor.
-/
theorem forbiddenMinors_antichain {P : Matroid α → Prop} (_hP : MinorClosed P) :
    IsMinorAntichain (ForbiddenMinors P) := by
  intro M N hM hN hMN hMN';
  cases' hM with hM₁ hM₂;
  cases' hN with hN₁ hN₂;
  exact hM₁ ( hN₂ M ( lt_of_le_of_ne hMN' hMN ) )

/-! ## Representable Matroids -/

/-- A matroid `M` is **F-representable in dimension n** if there exists an assignment of
vectors in F^n to elements of the ground set such that the independent sets of M
correspond exactly to the linearly independent sets of vectors. -/
def FRepresentable (F : Type*) [Field F] (M : Matroid α) (n : ℕ) : Prop :=
  ∃ repr : α → Fin n → F, ∀ I : Set α, I ⊆ M.E →
    (M.Indep I ↔ LinearIndependent F (fun (x : I) => repr x))

/-- A matroid is representable over `F` if it has an `F`-representation of some dimension. -/
def IsRepresentable (F : Type*) [Field F] (M : Matroid α) : Prop :=
  ∃ n : ℕ, FRepresentable F M n

/-! ## Representability is Minor-Closed -/

/-
Deletion preserves representability: if `M` is `F`-representable, so is `M ＼ D`.
The representation is simply the restriction of the original representation
to the remaining elements.
-/
theorem representable_delete {F : Type*} [Field F] {M : Matroid α} {n : ℕ}
    (h : FRepresentable F M n) (D : Set α) :
    FRepresentable F (M ＼ D) n := by
  obtain ⟨repr, hrepr⟩ := h;
  refine' ⟨ repr, fun I hI => _ ⟩;
  simp_all +decide [ Matroid.delete_indep_iff ];
  grind

/-- Representability (as a property) is minor-closed for deletion. -/
theorem isRepresentable_delete {F : Type*} [Field F] {M : Matroid α}
    (h : IsRepresentable F M) (D : Set α) : IsRepresentable F (M ＼ D) := by
  obtain ⟨n, rep⟩ := h
  exact ⟨n, representable_delete rep D⟩

/-! ## Well-Quasi-Ordering and Forbidden Minors -/

/-
**Fundamental Theorem of Forbidden Minors**: If a class of matroids `C` is
well-quasi-ordered by the minor relation, then any minor-closed property `P`
has at most finitely many forbidden minors within `C`.

This is the abstract backbone of the Robertson-Seymour theorem and its matroid
generalizations. The proof is by contradiction: if the forbidden minors formed
an infinite set, we could extract an infinite sequence from them, contradicting
WQO (since forbidden minors form an antichain).
-/
theorem wqo_forbidden_minor_finite
    (C : Set (Matroid α))
    (hWQO : ∀ f : ℕ → Matroid α, (∀ i, f i ∈ C) →
      ∃ i j, i < j ∧ f i ≤m f j)
    (P : Matroid α → Prop)
    (_hP : MinorClosed P) :
    Set.Finite {N ∈ C | IsForbiddenMinor P N} := by
  contrapose! hWQO;
  obtain ⟨f, hf⟩ : ∃ f : ℕ → Matroid α, (∀ i, f i ∈ {N ∈ C | IsForbiddenMinor P N}) ∧ Function.Injective f := by
    have := hWQO.natEmbedding;
    exact ⟨ _, fun i => this i |>.2, Subtype.val_injective.comp this.injective ⟩;
  refine' ⟨ f, fun i => hf.1 i |>.1, fun i j hij h => _ ⟩;
  have := hf.1 i; have := hf.1 j; simp_all +decide [ IsForbiddenMinor ] ;
  exact absurd ( this ( f i ) ( lt_of_le_of_ne h ( hf.2.ne hij.ne ) ) ) ( by have := hf.1 i; tauto )

/-! ## The Geelen-Gerards-Whittle Conjecture -/

/-- **Conjecture (Geelen-Gerards-Whittle)**: For any finite field F_q, the class of
F_q-representable matroids is well-quasi-ordered by the minor relation.

This would generalize the Robertson-Seymour theorem from graphs
(F_2-representable matroids) to all finite fields. -/
def GGW_Conjecture (F : Type*) [Field F] [Fintype F] : Prop :=
  ∀ f : ℕ → Matroid α,
    (∀ i, IsRepresentable F (f i)) →
    ∃ i j, i < j ∧ f i ≤m f j

/-
If the GGW conjecture holds for representable matroids over F, then for any
minor-closed property P, the set of F-representable forbidden minors is finite.
-/
theorem ggw_implies_finite_excluded_minors
    (F : Type*) [Field F] [Fintype F]
    (hGGW : @GGW_Conjecture α F _ _)
    (P : Matroid α → Prop)
    (hP : MinorClosed P) :
    Set.Finite {N : Matroid α | IsRepresentable F N ∧ IsForbiddenMinor P N} := by
  convert wqo_forbidden_minor_finite { N | IsRepresentable F N } _ P hP using 1 ; aesop ( simp_config := { singlePass := true } ) ;

/-! ## Uniform Matroids -/

/-- The rank of a uniform matroid U(k,n) is min(k,n). -/
def uniformRank (k n : ℕ) : ℕ := min k n

/-- For uniform matroids, the rank is monotone in both parameters. -/
theorem uniform_rank_mono {k₁ k₂ n₁ n₂ : ℕ}
    (hk : k₁ ≤ k₂) (hn : n₁ ≤ n₂) :
    uniformRank k₁ n₁ ≤ uniformRank k₂ n₂ := by
  simp [uniformRank]; omega

/-! ## Matroid Connectivity -/

/-- A matroid is **connected** if for every pair of elements in the ground set,
there exists a dependent set containing both. -/
def MatroidConnected (M : Matroid α) : Prop :=
  ∀ e f : α, e ∈ M.E → f ∈ M.E → e ≠ f →
    ∃ C : Set α, M.Dep C ∧ e ∈ C ∧ f ∈ C

end