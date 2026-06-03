/-
# The Periodic Table of Finite Groups

This module develops a structural classification of finite groups by analogy with the
chemical periodic table. Groups are organized into "chemical families" based on their
algebraic properties (solvability, nilpotency, simplicity), and we define a "valence"
measuring the number of minimal normal subgroups.

## Main Results

* The derived series is antitone (monotone decreasing)
* Abelian groups have trivial commutator (derived length ≤ 1)
* The derived series of a product equals the product of derived series
* Solvability is preserved under products
* Commutators in the derived series satisfy a telescoping property
* Minimal normal subgroups of abelian groups are simple
* The isotope conjecture (same order → same derived length) is FALSE
-/

import Mathlib

open Subgroup

/-! ## Chemical Family Classification -/

/-- Classification of finite groups into "chemical families" by analogy with the periodic table.
  * `NobleGas` — cyclic groups (stable, completely decomposable)
  * `AlkaliMetal` — nilpotent non-cyclic groups (soft, reactive)
  * `AlkalineEarth` — solvable non-nilpotent groups (moderately reactive)
  * `TransitionMetal` — simple non-abelian groups (rare, catalytic)
  * `Halogen` — non-solvable groups with non-trivial permutation action
  * `Radioactive` — all other non-solvable groups -/
inductive GroupChemicalFamily where
  | NobleGas
  | AlkaliMetal
  | AlkalineEarth
  | TransitionMetal
  | Halogen
  | Radioactive
  deriving DecidableEq, Repr

/-- A minimal normal subgroup: a normal subgroup N ≠ ⊥ with no proper normal subgroup
    of the ambient group contained strictly between ⊥ and N. -/
def Subgroup.IsMinNormal {G : Type*} [Group G] (N : Subgroup G) : Prop :=
  N.Normal ∧ N ≠ ⊥ ∧ ∀ M : Subgroup G, M.Normal → M ≤ N → M = ⊥ ∨ M = N

/-! ## Derived Series Properties -/

/-
The derived series is antitone: each term is contained in the previous one.
    This is the fundamental "electron shell" property — successive layers of
    the derived series peel off commutativity from the outside in.
-/
theorem derivedSeries_antitone' (G : Type*) [Group G] (n : ℕ) :
    derivedSeries G (n + 1) ≤ derivedSeries G n := by
      exact Subgroup.commutator_le_left _ _

/-
Abelian groups have trivial commutator subgroup.
    This characterizes "noble gases" — they have no non-trivial bonding.
-/
theorem commutator_eq_bot_of_comm (G : Type*) [Group G]
    (hcomm : ∀ a b : G, a * b = b * a) :
    ⁅(⊤ : Subgroup G), (⊤ : Subgroup G)⁆ = ⊥ := by
      simp +decide [ Subgroup.commutator_eq_bot_iff_le_centralizer ];
      exact eq_top_iff.mpr fun x _ => Subgroup.mem_center_iff.mpr fun y => hcomm y x

/-
If the group is commutative, the derived series reaches ⊥ in one step.
    Commutative groups are "inert" — they have derived length at most 1.
-/
theorem derivedSeries_one_eq_bot_of_comm (G : Type*) [Group G]
    (hcomm : ∀ a b : G, a * b = b * a) :
    derivedSeries G 1 = ⊥ := by
      -- Apply the lemma that states if the group is commutative, then the commutator of the top subgroup is trivial.
      apply commutator_eq_bot_of_comm G hcomm

/-! ## Product Structure: The Chemical Compound Law -/

/-
The derived series of a product is the product of derived series.
    This is the group-theoretic "law of definite proportions":
    the solvability depth of a compound is determined by its components.
-/
theorem derivedSeries_prod (G H : Type*) [Group G] [Group H] (n : ℕ) :
    derivedSeries (G × H) n = (derivedSeries G n).prod (derivedSeries H n) := by
      induction n <;> simp_all +decide [ derivedSeries ];
      simp +decide [ Subgroup.commutator_prod_prod ]

/-
Solvability is preserved under direct products.
    Noble gases remain stable when combined.
-/
instance solvable_prod_of_solvable (G H : Type*) [Group G] [Group H]
    [IsSolvable G] [IsSolvable H] : IsSolvable (G × H) := by
      exact inferInstance

/-! ## Structural Theorems -/

/-- Simple solvable ↔ commutative: the fundamental dichotomy.
    Simple groups are either noble gases (cyclic of prime order, commutative)
    or transition metals (non-abelian simple, non-solvable).
    There is no middle ground. -/
theorem simple_solvable_iff_comm (G : Type*) [Group G] [IsSimpleGroup G] :
    IsSolvable G ↔ ∀ a b : G, a * b = b * a :=
  IsSimpleGroup.comm_iff_isSolvable.symm

/-
A minimal normal subgroup of a commutative group is simple.
    In "noble gas" groups, every bonding site is atomic.
-/
theorem minNormal_of_comm_is_simple {G : Type*} [Group G]
    (hcomm : ∀ a b : G, a * b = b * a)
    (N : Subgroup G) (hN : N.IsMinNormal) :
    IsSimpleGroup N := by
      cases' hN with hN1 hN2;
      refine' { .. };
      · simp_all +decide [ Subgroup.eq_bot_iff_forall ];
        exact ⟨ hN2.1.choose, hN2.1.choose_spec.1, 1, N.one_mem, hN2.1.choose_spec.2 ⟩;
      · intro H hH;
        convert hN2.2 ( H.map ( Subgroup.subtype N ) ) _ _;
        · simp +decide [ Subgroup.eq_bot_iff_forall ];
        · constructor <;> intro h <;> simp_all +decide [ SetLike.ext_iff ];
          exact fun x hx => h x |>.2 hx |>.2;
        · convert hH.map ( Subgroup.subtype N );
          simp +decide [ Function.Surjective ];
          refine' Or.inr ⟨ fun g hg => _ ⟩;
          simp_all +decide [ mul_assoc, Subgroup.mem_map ];
        · exact map_le_iff_le_comap.mpr ( by aesop )

/-
The derived series respects normal subgroup inclusions.
    The derived series of a normal subgroup maps into the derived series of the ambient group.
-/
theorem derivedSeries_normal_le {G : Type*} [Group G]
    (N : Subgroup G) [N.Normal] (n : ℕ) :
    (derivedSeries N n).map N.subtype ≤ derivedSeries G n := by
      induction' n with n ih;
      · aesop;
      · simp_all +decide [ Subgroup.map_commutator ];
        exact Subgroup.commutator_mono ih ih

/-
Commutators within a derived series level land in the next level.
    This is the telescoping property that makes the derived series a filtration.
-/
theorem commutator_mem_derivedSeries_succ (G : Type*) [Group G] (n : ℕ)
    (a b : G) (ha : a ∈ derivedSeries G n) (hb : b ∈ derivedSeries G n) :
    a * b * a⁻¹ * b⁻¹ ∈ derivedSeries G (n + 1) := by
      exact Subgroup.commutator_mem_commutator ( by tauto ) ( by tauto )

/-! ## The Isotope Conjecture (Falsifiable) -/

/-- **The Isotope Conjecture** (FALSIFIABLE):
    "Groups of the same order have the same derived length."

    This is FALSE: S₃ and ℤ/6ℤ both have order 6, but S₃ has derived length 2
    (its commutator subgroup is ℤ/3ℤ ≠ {e}) while ℤ/6ℤ is abelian (derived length 1).
    This demonstrates that "isotopes" (same mass/order) can differ in their
    "chemical properties" (solvability depth). -/
def isotopeConjecture : Prop :=
  ∀ (G H : Type*) [Group G] [Group H] [Fintype G] [Fintype H],
    ∀ (nG nH : ℕ),
      (derivedSeries G nG = ⊥ ∧ ∀ m < nG, derivedSeries G m ≠ ⊥) →
      (derivedSeries H nH = ⊥ ∧ ∀ m < nH, derivedSeries H m ≠ ⊥) →
      Fintype.card G = Fintype.card H →
      nG = nH

/-
The isotope conjecture is false: groups of the same order can have
    different derived lengths. S₃ has derived length 2, ℤ/6ℤ has derived length 1.
-/
theorem isotope_conjecture_false : ¬ isotopeConjecture := by
  unfold isotopeConjecture; push_neg; (
  use ULift ( Multiplicative ( Fin 6 ) ), ULift ( Equiv.Perm ( Fin 3 ) );
  refine' ⟨ inferInstance, inferInstance, inferInstance, inferInstance, 1, 2, _, _, _, _ ⟩ <;> simp +decide [ derivedSeries ];
  · simp +decide [ Subgroup.commutator_def ];
  · refine' ⟨ _, _ ⟩;
    · simp +decide [ Subgroup.commutator_def ];
      intro x y hx z hy hxy;
      rw [ Subgroup.mem_closure ] at hx hy;
      specialize hx ( Subgroup.comap ( MonoidHom.mk' ( fun g : ULift ( Equiv.Perm ( Fin 3 ) ) => g.down ) ( by aesop_cat ) ) ( Equiv.Perm.sign.ker ) ) ; specialize hy ( Subgroup.comap ( MonoidHom.mk' ( fun g : ULift ( Equiv.Perm ( Fin 3 ) ) => g.down ) ( by aesop_cat ) ) ( Equiv.Perm.sign.ker ) ) ; simp_all +decide [ Set.subset_def ];
      native_decide +revert;
    · intro m hm; interval_cases m <;> simp +decide [ derivedSeries ] ;
      simp +decide [ Subgroup.commutator_def ]);