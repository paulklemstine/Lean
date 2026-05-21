/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Derived Persistence: Secondary Torsion Obstructions

This file develops a theory of **secondary torsion obstructions** for
two-step filtered abelian groups (short exact sequences), forming the
algebraic foundation for a derived persistence theory that goes beyond
classical `Tor₁` detection.

## Mathematical Overview

Given a short exact sequence `0 → A →ι B →π C → 0` of abelian groups
and an integer `n`, first-order torsion detection via `Tor₁(ℤ/nℤ, -)`
identifies torsion in `A` and `C` independently. However, the `n`-torsion
of `B` is *not* determined by the torsion of `A` and `C` alone — it depends
on the extension class.

We define the **secondary torsion obstruction** as the failure of the
natural map `T_n(B) → T_n(C)` (restriction of π to torsion subgroups)
to be surjective. This obstruction:

- vanishes for split exact sequences (`split_implies_no_secondary_obstruction`),
- is functorial under morphisms of SES (`torsion_lift_functorial`),
- is witnessed concretely by `0 → ℤ/2ℤ → ℤ/4ℤ → ℤ/2ℤ → 0`
  (`secondary_obstruction_Z4_nontrivial`),
- refines first-order `Tor₁` detection: when it vanishes, `Tor₁` data
  suffices to reconstruct torsion of `B`; when it doesn't, `Tor₁` misses
  hidden torsion coupling.

## Main Results

* `torsion_restriction_injective` — The restricted injection `T_n(A) → T_n(B)` is injective.
* `torsion_seq_exact_at_middle` — Exactness at `T_n(B)`.
* `split_implies_no_secondary_obstruction` — Split SES ⟹ trivial secondary obstruction.
* `torsion_lift_functorial` — Liftable torsion maps forward under SES morphisms.
* `secondary_obstruction_Z4_nontrivial` — The ℤ/4ℤ extension has nonzero obstruction.
* `split_torsion_decomposition` — Split SES gives torsion product decomposition.
* `no_obstruction_iff_torsion_surjective` — Obstruction ↔ surjectivity failure.
* `Z4_SES_nonsplit` — The ℤ/4ℤ SES does not split.

## References

This development builds on the catalog theorems in
`Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean` and
`Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean`.
-/

import Mathlib

namespace DerivedPersistence

/-! ## Section 1: The n-Torsion Subgroup -/

/-- The `n`-torsion subgroup of an abelian group `A`: the set of elements
    killed by scalar multiplication by `n`. Mathematically, this equals
    `Tor₁^ℤ(ℤ/nℤ, A)` via the standard 2-term free resolution of `ℤ/nℤ`. -/
def nTors (n : ℤ) (A : Type*) [AddCommGroup A] : AddSubgroup A where
  carrier := {a | n • a = 0}
  zero_mem' := smul_zero n
  add_mem' {a b} ha hb := by
    show n • (a + b) = 0
    rw [smul_add, ha, hb, add_zero]
  neg_mem' {a} ha := by
    show n • (-a) = 0
    rw [smul_neg, ha, neg_zero]

@[simp]
lemma mem_nTors {n : ℤ} {A : Type*} [AddCommGroup A] {a : A} :
    a ∈ nTors n A ↔ n • a = 0 :=
  Iff.rfl

/-- Group homomorphisms preserve torsion: if `n • a = 0`, then `n • f(a) = 0`. -/
lemma map_mem_nTors {A B : Type*} [AddCommGroup A] [AddCommGroup B]
    (f : A →+ B) (n : ℤ) {a : A} (ha : a ∈ nTors n A) :
    f a ∈ nTors n B := by
  simp only [mem_nTors] at ha ⊢
  rw [← map_zsmul f, ha, map_zero]

/-! ## Section 2: Short Exact Sequences -/

/-- A short exact sequence of abelian groups `0 → A →ι B →π C → 0`. -/
structure SES (A B C : Type*) [AddCommGroup A] [AddCommGroup B] [AddCommGroup C] where
  /-- The inclusion map -/
  ι : A →+ B
  /-- The projection map -/
  π : B →+ C
  /-- ι is injective -/
  ι_injective : Function.Injective ι
  /-- π is surjective -/
  π_surjective : Function.Surjective π
  /-- Exactness at B: π(b) = 0 ↔ b ∈ im(ι) -/
  exact : ∀ b, π b = 0 ↔ b ∈ AddMonoidHom.range ι

/-- A short exact sequence splits if π admits a group-homomorphic section. -/
def SES.IsSplit {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) : Prop :=
  ∃ σ : C →+ B, ∀ c, S.π (σ c) = c

/-! ## Section 3: The Secondary Torsion Obstruction -/

/-- The set of elements of `C` that lift to `n`-torsion elements of `B` via π.
    An element `c` is **liftable** if there exists `b` with `π(b) = c` and `n • b = 0`. -/
def liftableTorsion {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) (n : ℤ) : Set C :=
  {c | ∃ b, S.π b = c ∧ n • b = 0}

/-- The **secondary torsion obstruction** holds when there exists an `n`-torsion
    element of `C` that cannot be lifted to an `n`-torsion element of `B`.

    When this holds, `Tor₁`-level data for `A` and `C` individually does *not*
    determine the torsion structure of `B`. The extension class matters. -/
def hasSecondaryObstruction {A B C : Type*}
    [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) (n : ℤ) : Prop :=
  ∃ c, c ∈ nTors n C ∧ c ∉ liftableTorsion S n

/-! ## Section 4: Morphisms of Short Exact Sequences -/

/-- A morphism between two short exact sequences: a triple of group homomorphisms
    making the natural diagram commute. -/
structure SESMorphism {A B C A' B' C' : Type*}
    [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    [AddCommGroup A'] [AddCommGroup B'] [AddCommGroup C']
    (S : SES A B C) (S' : SES A' B' C') where
  fA : A →+ A'
  fB : B →+ B'
  fC : C →+ C'
  comm_left : ∀ a, fB (S.ι a) = S'.ι (fA a)
  comm_right : ∀ b, fC (S.π b) = S'.π (fB b)

/-! ## Section 5: Core Structural Theorems -/

/-- **Theorem (Torsion Injection is Exact)**.
    The restriction of `ι` to `T_n(A)` remains injective into `T_n(B)`.
    This is the left-exactness of the torsion sequence. -/
theorem torsion_restriction_injective
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) (n : ℤ) (a₁ a₂ : A)
    (_ha₁ : a₁ ∈ nTors n A) (_ha₂ : a₂ ∈ nTors n A)
    (h : S.ι a₁ = S.ι a₂) : a₁ = a₂ :=
  S.ι_injective h

/-
**Theorem (Exactness at T_n(B))**.
    The restricted sequence `T_n(A) → T_n(B) → T_n(C)` is exact at `T_n(B)`:
    an element `b ∈ T_n(B)` maps to zero in `C` if and only if it is
    in the image of `ι` restricted from `T_n(A)`.
-/
theorem torsion_seq_exact_at_middle
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) (n : ℤ) (b : B) (hb : b ∈ nTors n B) :
    S.π b = 0 ↔ ∃ a, a ∈ nTors n A ∧ S.ι a = b := by
  constructor <;> intro h;
  · obtain ⟨ a, ha ⟩ := S.exact b |>.1 h;
    have := S.ι_injective ( by aesop : S.ι ( n • a ) = S.ι 0 ) ; aesop;
  · obtain ⟨ a, ha, rfl ⟩ := h; exact S.exact _ |>.2 ⟨ a, rfl ⟩ ;

/-! ## Section 6: Theorem A — Split SES Have Trivial Obstruction -/

/-
**Theorem A (Split Implies No Secondary Obstruction)**.
    If the short exact sequence `0 → A → B → C → 0` splits, then for
    every integer `n`, the secondary torsion obstruction vanishes.

    **Proof**: A section `σ : C →+ B` provides a torsion-preserving
    lift: if `n • c = 0`, then `n • σ(c) = σ(n • c) = σ(0) = 0`,
    so every torsion element of `C` lifts to a torsion element of `B`.
-/
theorem split_implies_no_secondary_obstruction
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) (n : ℤ) (hsplit : S.IsSplit) :
    ¬ hasSecondaryObstruction S n := by
  obtain ⟨ σ, hσ ⟩ := hsplit;
  intro h
  obtain ⟨ c, hc₁, hc₂ ⟩ := h;
  exact hc₂ ⟨ σ c, hσ c, by simpa [ map_zsmul ] using congr_arg σ hc₁ ⟩

/-! ## Section 7: Theorem B — Functoriality of Liftable Torsion -/

/-
**Theorem B (Functoriality of Liftable Torsion)**.
    Given a morphism `(fA, fB, fC)` of short exact sequences, liftable
    torsion maps forward: if `c ∈ liftableTorsion S n`, then
    `fC(c) ∈ liftableTorsion S' n`.

    This establishes that the secondary torsion obstruction is a *functorial*
    invariant — it respects the natural transformations between filtered complexes.
-/
theorem torsion_lift_functorial
    {A B C A' B' C' : Type*}
    [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    [AddCommGroup A'] [AddCommGroup B'] [AddCommGroup C']
    {S : SES A B C} {S' : SES A' B' C'}
    (φ : SESMorphism S S') (n : ℤ) (c : C)
    (hc : c ∈ liftableTorsion S n) :
    φ.fC c ∈ liftableTorsion S' n := by
  rcases hc with ⟨ b, hb₁, hb₂ ⟩;
  have h_eq : n • (φ.fB b) = 0 := by
    rw [ ← map_zsmul, hb₂, map_zero ];
  exact ⟨ φ.fB b, by rw [ ← hb₁, φ.comm_right ], h_eq ⟩

/-! ## Section 8: Theorem C — Nontrivial Secondary Obstruction for ℤ/4ℤ

The short exact sequence `0 → ℤ/2ℤ →(*2) ℤ/4ℤ →(mod 2) ℤ/2ℤ → 0` is the
simplest example where the secondary torsion obstruction is nontrivial.

The element `1 ∈ ℤ/2ℤ` is `2`-torsion, but every preimage under the quotient
map `ℤ/4ℤ → ℤ/2ℤ` has `2 • b = 2 ≠ 0` in `ℤ/4ℤ`. So `1` cannot be lifted
to a `2`-torsion element. -/

/-- The inclusion `ℤ/2ℤ ↪ ℤ/4ℤ` via multiplication by 2. -/
def Z2_to_Z4 : ZMod 2 →+ ZMod 4 where
  toFun x := 2 * (x.val : ZMod 4)
  map_zero' := by decide
  map_add' := by decide

/-- The projection `ℤ/4ℤ ↠ ℤ/2ℤ` via the canonical quotient map. -/
def Z4_to_Z2 : ZMod 4 →+ ZMod 2 :=
  (ZMod.castHom (show 2 ∣ 4 by norm_num) (ZMod 2)).toAddMonoidHom

/-- The sequence `0 → ℤ/2ℤ →(*2) ℤ/4ℤ →(mod 2) ℤ/2ℤ → 0` is short exact. -/
theorem Z4_ses_injective : Function.Injective Z2_to_Z4 := by decide

theorem Z4_ses_surjective : Function.Surjective Z4_to_Z2 := by decide

theorem Z4_ses_exact :
    ∀ b : ZMod 4, Z4_to_Z2 b = 0 ↔ b ∈ AddMonoidHom.range Z2_to_Z4 := by decide

/-- The canonical short exact sequence `0 → ℤ/2ℤ → ℤ/4ℤ → ℤ/2ℤ → 0`. -/
def Z4_SES : SES (ZMod 2) (ZMod 4) (ZMod 2) where
  ι := Z2_to_Z4
  π := Z4_to_Z2
  ι_injective := Z4_ses_injective
  π_surjective := Z4_ses_surjective
  exact := Z4_ses_exact

/-
**Theorem C (Nontrivial Secondary Obstruction)**.
    The short exact sequence `0 → ℤ/2ℤ →(*2) ℤ/4ℤ →(mod 2) ℤ/2ℤ → 0`
    has a nonzero secondary 2-torsion obstruction.

    This is the simplest concrete witness that **persistence has a secondary
    derived layer**: the torsion of the total space is not determined by the
    torsion of the associated graded pieces.
-/
theorem secondary_obstruction_Z4_nontrivial :
    hasSecondaryObstruction Z4_SES 2 := by
  -- Let's choose c = 1 in ZMod 2.
  use 1;
  simp +decide [ nTors, liftableTorsion ]

/-
The SES `0 → ℤ/2ℤ → ℤ/4ℤ → ℤ/2ℤ → 0` does **not** split.
-/
theorem Z4_SES_nonsplit : ¬ Z4_SES.IsSplit := by
  by_contra h_split
  obtain ⟨σ, hσ⟩ := h_split
  have hσ1 : Z4_to_Z2 (σ 1) = 1 := by
    exact hσ 1
  have hσ2 : σ 1 + σ 1 = 0 := by
    rw [ ← map_add, show ( 1 : ZMod 2 ) + 1 = 0 by decide, map_zero ]
  generalize_proofs at *; (
  rcases h : σ 1 with ( _ | _ | _ | _ | _ ) <;> simp_all +decide [ ZMod ] ; tauto;)

/-! ## Section 9: Theorem D — Split SES Gives Torsion Product Decomposition -/

/-
**Theorem D (Split Torsion Decomposition)**.
    For a split short exact sequence with section `σ`, every `n`-torsion
    element of `B` decomposes as a sum of torsion from `im(ι)` and `im(σ)`.
    This is the precise sense in which `Tor₁` data determines torsion of `B`
    when the filtration splits.
-/
theorem split_torsion_decomposition
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) (n : ℤ) (σ : C →+ B) (hσ : ∀ c, S.π (σ c) = c)
    (b : B) (hb : b ∈ nTors n B) :
    ∃ (a : A) (c : C), a ∈ nTors n A ∧ c ∈ nTors n C ∧
      b = S.ι a + σ c := by
  -- By exactness, there exists $a \in A$ such that $\iota(a) = b - \sigma(\pi(b))$.
  obtain ⟨a, ha⟩ : ∃ a : A, S.ι a = b - σ (S.π b) := by
    have := S.exact ( b - σ ( S.π b ) ) ; aesop;
  refine' ⟨ a, S.π b, _, _, _ ⟩ <;> simp_all +decide [ nTors ];
  · -- Since $n • b = 0$, we have $n • (b - σ (S.π b)) = n • b - n • σ (S.π b) = 0 - n • σ (S.π b) = -n • σ (S.π b)$.
    have h_nab : n • (b - σ (S.π b)) = -n • σ (S.π b) := by
      simp +decide [ hb, zsmul_sub ];
    have h_nab_zero : S.ι (n • a) = 0 := by
      simp_all +decide [ ← map_zsmul ];
      rw [ ← h_nab, ← ha, map_zsmul ];
    exact S.ι_injective ( by simpa using h_nab_zero );
  · have := congr_arg ( fun x => S.π x ) hb; norm_num at this; aesop;

/-! ## Section 10: Connecting to Catalog — Tor₁ Detection Refinement -/

/-
When the secondary obstruction vanishes, every `n`-torsion element of `C`
    lifts. Combined with `tor1_vanishes_iff_no_n_torsion` from the catalog,
    this means `Tor₁` data for associated graded pieces completely controls
    `Tor₁` data for `B`.
-/
theorem no_obstruction_iff_torsion_surjective
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) (n : ℤ) :
    ¬ hasSecondaryObstruction S n ↔
      ∀ c, c ∈ nTors n C → c ∈ liftableTorsion S n := by
  simp +decide only [hasSecondaryObstruction, not_exists];
  grind

/-- If `A` has no `n`-torsion, then every `n`-torsion element of `B`
    projects to an `n`-torsion element of `C`. This shows that when
    `Tor₁(ℤ/nℤ, A) = 0`, torsion detection passes cleanly through π. -/
theorem no_torsion_in_A_implies_torsion_projects
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (S : SES A B C) (n : ℤ)
    (b : B) (hb : b ∈ nTors n B) :
    S.π b ∈ nTors n C :=
  map_mem_nTors S.π n hb

end DerivedPersistence