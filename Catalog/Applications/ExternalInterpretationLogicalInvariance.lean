/-
# The Definability Boundary, III: Logical Invariance and Quantitative Meaning Loss

This file continues `Catalog/Applications/ExternalInterpretationDefinability.lean`
and `Catalog/Applications/ExternalInterpretationGraphs.lean`.

The previous files classified *unary* external interpretations.  Here we push the
classification to interpretations of **tuples**, where the answer becomes a sharp
syntactic statement: under the full symmetric group of a model of *any*
cardinality, an interpretation of finitely many coordinates is recoverable from
structural truth exactly when it depends only on the *kernel* of the tuple — i.e.
only on which coordinates are equal.  This is the formal form of the classical
dictum that the only purely logical (permutation-invariant) notions are the ones
built from equality.  The finiteness of the *arity* is essential and is shown to
be so.

* **Part A — Transport.**  `exists_perm_of_kernel_eq` : two finitely-indexed
  tuples with the same equality pattern are carried onto each other by a
  permutation of the carrier (built by extending the induced bijection between
  their finite ranges, splitting on whether the carrier is finite or infinite).
* **Part B — Logical invariance.**  `perm_tuple_recoverable_iff_kernel` : a tuple
  interpretation is recoverable iff it factors through the kernel; and
  `kernel_classification_fails_for_infinite_arity` shows that for infinitely many
  coordinates this fails — surjectivity of a sequence is recoverable but not
  kernel-determined.
* **Part C — Binary case and a concrete collision.**  `perm_pair_recoverable_iff`
  specialises to binary interpretations: only equality survives.  Consequently
  the *order* relation on `Fin 3` is not recoverable
  (`lt_not_recoverable`) — the meaning-collision phenomenon at the level of
  relations rather than points.
* **Part D — Quantitative meaning loss.**  `card_interpretations_split` factors
  the total number of interpretations as (recoverable ones) × (a pure loss
  factor), and `card_recoverable_lt` shows the loss is strict as soon as one
  orbit is non-trivial and there are at least two meanings.
-/

import Catalog.Applications.ExternalInterpretationDefinability

namespace ExternalInterpretationLogicalInvariance

open MulAction ExternalInterpretationDefinability

universe u v w

/-! ## Part A — Transporting tuples with the same equality pattern -/

/-- **Transport lemma.**  If two finitely-indexed tuples in an arbitrary type have
the same *kernel* (the same pattern of coincidences among coordinates), some
permutation of the type carries the first onto the second. -/
theorem exists_perm_of_kernel_eq {α : Type u} {ι : Type v} [Finite ι] (f g : ι → α)
    (hker : ∀ i j, f i = f j ↔ g i = g j) : ∃ σ : Equiv.Perm α, ∀ i, σ (f i) = g i := by
  classical
  have hinj : Function.Injective (fun a : (Set.range f) => g (Classical.choose a.2)) := by
    rintro ⟨a, ha⟩ ⟨b, hb⟩ hab
    have h1 : f (Classical.choose ha) = a := Classical.choose_spec ha
    have h2 : f (Classical.choose hb) = b := Classical.choose_spec hb
    have hf := (hker _ _).mpr hab
    simp only [Subtype.mk.injEq]
    rw [← h1, ← h2, hf]
  let emb : (Set.range f) ↪ α := ⟨fun a => g (Classical.choose a.2), hinj⟩
  have hex : ∃ σ : α ≃ α, ∀ x : (Set.range f), σ x = emb x := by
    cases finite_or_infinite α with
    | inl _ => exact Cardinal.extend_function_finite emb ⟨Equiv.refl α⟩
    | inr _ =>
      refine Cardinal.extend_function_of_lt emb ?_ ⟨Equiv.refl α⟩
      have hfin : (Set.range f).Finite := Set.finite_range f
      calc Cardinal.mk (Set.range f) < Cardinal.aleph0 := Cardinal.lt_aleph0_of_finite _
        _ ≤ Cardinal.mk α := Cardinal.aleph0_le_mk α
  obtain ⟨σ, hσ⟩ := hex
  refine ⟨σ, fun i => ?_⟩
  have hmem : f i ∈ Set.range f := ⟨i, rfl⟩
  have hval := hσ ⟨f i, hmem⟩
  simp only [emb, Function.Embedding.coeFn_mk] at hval
  rw [hval]
  exact (hker _ _).mp (Classical.choose_spec hmem)

/-! ## Part B — Logical invariance for tuple interpretations -/

/-- **Logical invariance theorem.**  For a model `α` carrying no structure beyond
equality (so that the automorphism group is the full symmetric group), an
external interpretation of tuples with finitely many coordinates is recoverable
from structural truth exactly when it depends only on the kernel of the tuple:
only equality is logical. -/
theorem perm_tuple_recoverable_iff_kernel {α : Type u} {ι : Type v} [Finite ι] {V : Type w}
    (I : (ι → α) → V) :
    Recoverable (Equiv.Perm α) I ↔
      ∀ f g : ι → α, (∀ i j, f i = f j ↔ g i = g j) → I f = I g := by
  rw [recoverable_iff_orbitConstant]
  constructor
  · intro h f g hker
    obtain ⟨σ, hσ⟩ := exists_perm_of_kernel_eq f g hker
    refine h ⟨σ, ?_⟩
    funext i
    exact hσ i
  · rintro h f g ⟨σ, rfl⟩
    refine h f (σ • f) ?_
    intro i j
    constructor
    · intro hij
      show σ (f i) = σ (f j)
      rw [hij]
    · intro hij
      have : σ (f i) = σ (f j) := hij
      exact σ.injective this

/-- Restated: a recoverable tuple interpretation is determined by the kernel. -/
theorem kernel_determines {α : Type u} {ι : Type v} [Finite ι] {V : Type w}
    {I : (ι → α) → V} (h : Recoverable (Equiv.Perm α) I) {f g : ι → α}
    (hker : ∀ i j, f i = f j ↔ g i = g j) : I f = I g :=
  (perm_tuple_recoverable_iff_kernel I).mp h f g hker

/-! ## Part C — Binary interpretations: only equality survives -/

/-- **Binary logical invariance.**  A binary external interpretation of a
structureless model (of any cardinality) is recoverable from structural truth
exactly when it is a function of the equality pattern of the pair. -/
theorem perm_pair_recoverable_iff {α : Type u} {V : Type w} (I : α × α → V) :
    Recoverable (Equiv.Perm α) I ↔
      ∀ p q : α × α, (p.1 = p.2 ↔ q.1 = q.2) → I p = I q := by
  rw [recoverable_iff_orbitConstant]
  constructor
  · rintro h ⟨x, y⟩ ⟨u, v⟩ hpat
    have hk : ∀ i j : Fin 2,
        (![x, y] : Fin 2 → α) i = ![x, y] j ↔ (![u, v] : Fin 2 → α) i = ![u, v] j := by
      intro i j
      fin_cases i <;> fin_cases j
      · exact ⟨fun _ => rfl, fun _ => rfl⟩
      · exact hpat
      · exact ⟨fun hh => (hpat.mp hh.symm).symm, fun hh => (hpat.mpr hh.symm).symm⟩
      · exact ⟨fun _ => rfl, fun _ => rfl⟩
    obtain ⟨σ, hσ⟩ := exists_perm_of_kernel_eq (![x, y] : Fin 2 → α) ![u, v] hk
    refine h ⟨σ, ?_⟩
    have h0 := hσ 0
    have h1 := hσ 1
    simp only [Matrix.cons_val_zero, Matrix.cons_val_one] at h0 h1
    show ((σ x, σ y) : α × α) = (u, v)
    rw [h0, h1]
  · rintro h ⟨x, y⟩ q ⟨σ, rfl⟩
    refine h (x, y) (σ • (x, y)) ?_
    show x = y ↔ σ x = σ y
    exact ⟨fun hh => by rw [hh], fun hh => σ.injective hh⟩

/-- **Order is not logical.**  The strict-order interpretation of pairs from
`Fin 3` is not recoverable from structural truth: the pairs `(0,1)` and `(1,0)`
have the same equality pattern but opposite order values. -/
theorem lt_not_recoverable :
    ¬ Recoverable (Equiv.Perm (Fin 3)) (fun p : Fin 3 × Fin 3 => decide (p.1 < p.2)) := by
  intro h
  have hcl := (perm_pair_recoverable_iff _).mp h ((0 : Fin 3), (1 : Fin 3))
    ((1 : Fin 3), (0 : Fin 3)) (by decide)
  simp only at hcl
  exact absurd hcl (by decide)

/-- Equality itself *is* recoverable: it is the canonical logical relation. -/
theorem eq_recoverable {α : Type u} [DecidableEq α] :
    Recoverable (Equiv.Perm α) (fun p : α × α => decide (p.1 = p.2)) := by
  rw [perm_pair_recoverable_iff]
  rintro ⟨x, y⟩ ⟨u, v⟩ hpat
  simp only [decide_eq_decide]
  exact hpat

/-! ### Sharpness: the arity must be finite -/

/-- The surjectivity interpretation of infinite sequences of naturals. -/
def surjInterp : (ℕ → ℕ) → Prop := fun f => Function.Surjective f

/-- Surjectivity is invariant under the symmetric group, hence recoverable. -/
theorem surjInterp_recoverable : Recoverable (Equiv.Perm ℕ) surjInterp := by
  rw [recoverable_iff_orbitConstant]
  rintro f g ⟨σ, rfl⟩
  have hiff : Function.Surjective f ↔ Function.Surjective (σ • f) := by
    constructor
    · intro hf n
      obtain ⟨m, hm⟩ := hf (σ.symm n)
      exact ⟨m, by show σ (f m) = n; rw [hm]; simp⟩
    · intro hf n
      obtain ⟨m, hm⟩ := hf (σ n)
      have : σ (f m) = σ n := hm
      exact ⟨m, σ.injective this⟩
  exact propext hiff

/-- **Sharpness of the kernel classification.**  For an infinite arity the
classification fails: surjectivity of a sequence is a recoverable interpretation
of `ℕ`-indexed tuples which is *not* determined by the kernel — the injective
sequences `n ↦ 2n` and `n ↦ n` share a kernel but differ in surjectivity.  So
the finiteness of the index type in `perm_tuple_recoverable_iff_kernel` cannot be
dropped. -/
theorem kernel_classification_fails_for_infinite_arity :
    Recoverable (Equiv.Perm ℕ) surjInterp ∧
      ¬ (∀ f g : ℕ → ℕ, (∀ i j, f i = f j ↔ g i = g j) → surjInterp f = surjInterp g) := by
  refine ⟨surjInterp_recoverable, ?_⟩
  intro h
  have hker : ∀ i j : ℕ, (2 * i = 2 * j) ↔ (id i = id j) := by
    intro i j
    show 2 * i = 2 * j ↔ i = j
    omega
  have heq := h (fun n => 2 * n) id hker
  have hid : surjInterp id := fun n => ⟨n, rfl⟩
  have hnot : ¬ surjInterp (fun n => 2 * n) := by
    intro hs
    obtain ⟨m, hm⟩ := hs 1
    have : 2 * m = 1 := hm
    omega
  rw [heq] at hnot
  exact hnot hid

/-! ## Part D — Quantitative meaning loss -/

variable {G : Type u} {M : Type v} {V : Type w} [Group G] [MulAction G M]

/-- There are never more orbits than elements. -/
theorem card_orbits_le [Fintype M] [Fintype (orbitRel.Quotient G M)] :
    Fintype.card (orbitRel.Quotient G M) ≤ Fintype.card M :=
  Fintype.card_le_of_surjective (Quotient.mk _) Quotient.mk_surjective

/-- **Meaning loss factorisation.**  The total number of external interpretations
splits as the number of recoverable ones times a pure loss factor
`|V| ^ (|M| − #orbits)`. -/
theorem card_interpretations_split [Fintype M] [Fintype V] [DecidableEq M]
    [DecidableEq (orbitRel.Quotient G M)] [Fintype (orbitRel.Quotient G M)]
    [Fintype {I : M → V // OrbitConstant G I}] :
    Fintype.card (M → V)
      = Fintype.card {I : M → V // OrbitConstant G I} *
          Fintype.card V ^ (Fintype.card M - Fintype.card (orbitRel.Quotient G M)) := by
  have hle : Fintype.card (orbitRel.Quotient G M) ≤ Fintype.card M := card_orbits_le
  rw [Fintype.card_fun, card_orbitConstant_eq_pow, ← pow_add]
  congr 1
  omega

/-- **Strict meaning loss.**  If some non-trivial orbit exists (two distinct
structurally indistinguishable elements) and there are at least two possible
meanings, then strictly fewer interpretations are recoverable than exist. -/
theorem card_recoverable_lt [Fintype M] [Fintype V] [DecidableEq M]
    [DecidableEq (orbitRel.Quotient G M)] [Fintype (orbitRel.Quotient G M)]
    [Fintype {I : M → V // OrbitConstant G I}]
    (hV : 2 ≤ Fintype.card V) {x y : M} (hne : x ≠ y) (hxy : Indist G x y) :
    Fintype.card {I : M → V // OrbitConstant G I} < Fintype.card (M → V) := by
  classical
  have hsurj : Function.Surjective (Quotient.mk (orbitRel G M)) := Quotient.mk_surjective
  have hnotinj : ¬ Function.Injective (Quotient.mk (orbitRel G M)) := by
    intro hinj
    exact hne (hinj (Quotient.sound (indist_iff_orbitRel.mp (indist_symm hxy))))
  have hlt : Fintype.card (orbitRel.Quotient G M) < Fintype.card M :=
    Fintype.card_lt_of_surjective_not_injective _ hsurj hnotinj
  rw [Fintype.card_fun, card_orbitConstant_eq_pow]
  exact Nat.pow_lt_pow_right hV hlt

end ExternalInterpretationLogicalInvariance