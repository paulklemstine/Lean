/-
  # The Periodic Table of Finite Groups

  This file establishes the foundational mathematical framework for a "periodic table"
  of finite groups, drawing rigorous parallels between chemical properties and
  group-theoretic invariants.

  ## Main Results

  1. **Derived–Central Series Inequality** (`derivedSeries_le_lowerCentralSeries`):
     The derived series is bounded above by the lower central series at every step.

  2. **Nilpotency Class Bounds Derived Depth** (`derivedDepth_le_nilpotencyClass`):
     For nilpotent groups, the derived depth is at most the nilpotency class.

  3. **Derived Series Product Decomposition** (`derivedSeries_prod`):
     The derived series of a product group equals the product of derived series.

  4. **Group Valence Theory**: Definition and properties of group valence
     (minimal normal subgroup count) as an analogue of chemical valence.
-/

import Mathlib

open Classical

/-! ## The Derived–Central Series Inequality -/

/-- The commutator of a subgroup with itself is contained in its commutator with ⊤. -/
theorem commutator_self_le_commutator_top {G : Type*} [Group G] (H : Subgroup G) :
    ⁅H, H⁆ ≤ ⁅H, ⊤⁆ :=
  Subgroup.commutator_mono le_rfl le_top

/-
**Derived–Central Series Inequality**: The derived series is bounded above by the
lower central series at every step. This follows by induction using commutator monotonicity:
- Base case: both series start at ⊤.
- Inductive step: `D(n+1) = ⁅D(n), D(n)⁆ ≤ ⁅γ(n), γ(n)⁆ ≤ ⁅γ(n), ⊤⁆ = γ(n+1)`.
-/
theorem derivedSeries_le_lowerCentralSeries (G : Type*) [Group G] (n : ℕ) :
    derivedSeries G n ≤ lowerCentralSeries G n := by
  induction' n with n ih;
  · exact le_rfl;
  · exact le_trans ( Subgroup.commutator_mono ih ih ) ( commutator_self_le_commutator_top _ )

/-! ## Derived Series Product Decomposition -/

/-
The derived series of a product group decomposes as the product of derived series.
This is proved by induction using the fact that commutators in a product decompose
component-wise.
-/
theorem derivedSeries_prod (G H : Type*) [Group G] [Group H] (n : ℕ) :
    derivedSeries (G × H) n = (derivedSeries G n).prod (derivedSeries H n) := by
  induction' n with n ih <;> simp_all +decide [ derivedSeries ];
  simp +decide [ Subgroup.commutator_prod_prod ]

/-! ## Derived Depth -/

/-- The derived depth (derived length) of a solvable group is the smallest n
such that the n-th derived subgroup is trivial. -/
noncomputable def derivedDepth (G : Type*) [Group G] [IsSolvable G] : ℕ :=
  Nat.find (IsSolvable.solvable (G := G))

/-- At the derived depth, the derived series reaches the bottom. -/
theorem derivedSeries_derivedDepth_eq_bot (G : Type*) [Group G] [IsSolvable G] :
    derivedSeries G (derivedDepth G) = ⊥ := by
  exact Nat.find_spec (IsSolvable.solvable (G := G))

/-- Before the derived depth, the derived series has not yet reached the bottom. -/
theorem derivedSeries_lt_derivedDepth (G : Type*) [Group G] [IsSolvable G]
    {n : ℕ} (hn : n < derivedDepth G) : derivedSeries G n ≠ ⊥ := by
  exact Nat.find_min (IsSolvable.solvable (G := G)) hn

/-! ## Nilpotency Class Bounds Derived Depth -/

/-
For nilpotent groups, the derived depth is at most the nilpotency class.
This follows from the Derived–Central Series Inequality: if the lower central
series reaches ⊥ at step c (nilpotency class), the derived series must also
have reached ⊥ by that step.
-/
theorem derivedDepth_le_nilpotencyClass (G : Type*) [Group G]
    [hN : Group.IsNilpotent G] :
    derivedDepth G ≤ Group.nilpotencyClass G := by
  by_contra h_contra;
  -- By the Derived–Central Series Inequality, derivedSeries G c ≤ lowerCentralSeries G c.
  have h_derived_le_lowerCentral : derivedSeries G (Group.nilpotencyClass G) ≤ lowerCentralSeries G (Group.nilpotencyClass G) := by
    apply derivedSeries_le_lowerCentralSeries;
  -- Since lowerCentralSeries G (Group.nilpotencyClass G) = ⊥, we have derivedSeries G (Group.nilpotencyClass G) = ⊥.
  have h_derived_eq_bot : derivedSeries G (Group.nilpotencyClass G) = ⊥ := by
    exact le_bot_iff.mp ( h_derived_le_lowerCentral.trans ( by simp +decide [ lowerCentralSeries_nilpotencyClass ] ) );
  exact h_contra ( Nat.find_le h_derived_eq_bot )

/-! ## Group Valence (Minimal Normal Subgroup Count) -/

/-- A normal subgroup N of G is an **atom** (minimal normal subgroup) if
N ≠ ⊥ and there is no normal subgroup strictly between ⊥ and N. -/
def Subgroup.IsMinimalNormal {G : Type*} [Group G] (N : Subgroup G) : Prop :=
  N.Normal ∧ N ≠ ⊥ ∧ ∀ K : Subgroup G, K.Normal → K ≤ N → K = ⊥ ∨ K = N

/-- The **group valence** is the number of minimal normal subgroups.
Analogous to chemical valence: it measures the group's "bonding capacity"
via its atomic normal structure. -/
noncomputable def groupValence (G : Type*) [Group G] : ℕ :=
  Set.ncard {N : Subgroup G | N.IsMinimalNormal}

/-
Simple groups have valence exactly 1: the only minimal normal subgroup is ⊤.
-/
theorem simple_group_valence_eq_one (G : Type*) [Group G] [Nontrivial G]
    [IsSimpleGroup G] : groupValence G = 1 := by
  convert Set.ncard_singleton ( ⊤ : Subgroup G );
  convert Set.ncard_eq_one.mpr _;
  · norm_num;
  · refine' ⟨ ⊤, _ ⟩;
    ext N; simp [Subgroup.IsMinimalNormal];
    constructor <;> intro hN;
    · cases' ‹IsSimpleGroup G› with h₁ h₂;
      cases h₂ N hN.1 <;> tauto;
    · have := ‹IsSimpleGroup G›.2; aesop;

/-! ## Periodic Table Entry Structure -/

/-- A periodic table entry for a finite group, encoding invariants that
parallel chemical properties. -/
structure GroupPeriodicEntry where
  /-- Order of the group (↔ atomic number). -/
  order : ℕ
  /-- Derived depth (↔ period/row number). -/
  period : ℕ
  /-- Group valence (↔ chemical valence). -/
  valence : ℕ
  /-- Order of the center (↔ nuclear stability). -/
  centerOrder : ℕ
  /-- Whether the group is solvable (↔ chemical stability). -/
  isSolvable : Bool
  /-- Whether the group is nilpotent (↔ noble gas property). -/
  isNilpotent : Bool

/-! ## Derived Depth of Product Groups -/

/-
The derived depth of a product equals the max of derived depths.
Uses the product decomposition theorem for the derived series.
-/
theorem derivedDepth_prod (G H : Type*) [Group G] [Group H]
    [IsSolvable G] [IsSolvable H] :
    derivedDepth (G × H) = max (derivedDepth G) (derivedDepth H) := by
  refine' le_antisymm ( Nat.le_of_not_lt fun h => _ ) _;
  · contrapose! h;
    refine' Nat.find_le _;
    simp +decide [ Subgroup.prod_eq_bot_iff, derivedSeries_prod, derivedSeries_derivedDepth_eq_bot ];
    exact ⟨ by exact Nat.le_induction ( by exact derivedSeries_derivedDepth_eq_bot G ) ( fun n hn ih => by rw [ derivedSeries_succ ] ; aesop ) _ ( le_max_left _ _ ), by exact Nat.le_induction ( by exact derivedSeries_derivedDepth_eq_bot H ) ( fun n hn ih => by rw [ derivedSeries_succ ] ; aesop ) _ ( le_max_right _ _ ) ⟩;
  · refine' max_le _ _;
    · refine' Nat.find_mono _;
      intro n hn; rw [ derivedSeries_prod ] at hn; simp_all +decide [ Subgroup.prod_eq_bot_iff ] ;
    · refine' Nat.find_mono _;
      intro n hn; rw [ derivedSeries_prod ] at hn; simp_all +decide [ Subgroup.prod_eq_bot_iff ] ;

/-! ## Quantitative Periodic Law Conjecture -/

/-
**Quantitative Periodic Law Conjecture**: For every nontrivial finite solvable
group G, the derived depth satisfies `derivedDepth(G) ≤ Ω(|G|)`, where Ω is
the number of prime factors counted with multiplicity.

The intuition is that each step of the derived series "consumes" at least one
prime factor: the quotient D(i)/D(i+1) is a nontrivial abelian group (for
solvable G) and hence has order ≥ 2. So the number of steps is bounded
by log₂(|G|) ≤ Ω(|G|).
-/
theorem quantitative_periodic_law_conjecture
    (G : Type*) [Group G] [Fintype G] [IsSolvable G] [Nontrivial G] :
    derivedDepth G ≤ (Fintype.card G).primeFactorsList.length := by
  have h_derived_series_length : ∀ n, derivedSeries G n ≠ ⊥ → (Fintype.card (derivedSeries G n)).primeFactorsList.length ≥ derivedDepth G - n := by
    intro n hn_nontrivial
    have h_derived_series_step : ∀ i, derivedSeries G (n + i) ≠ ⊥ → (Fintype.card (derivedSeries G (n + i))).primeFactorsList.length ≥ (Fintype.card (derivedSeries G (n + i + 1))).primeFactorsList.length + 1 := by
      intro i hi_nontrivial
      have h_derived_series_step : (Fintype.card (derivedSeries G (n + i + 1))) ∣ (Fintype.card (derivedSeries G (n + i))) ∧ (Fintype.card (derivedSeries G (n + i + 1))) < (Fintype.card (derivedSeries G (n + i))) := by
        have h_derived_series_step : derivedSeries G (n + i + 1) < derivedSeries G (n + i) := by
          refine' lt_of_le_of_ne _ _;
          · exact Subgroup.commutator_le_left _ _;
          · intro h_eq
            have h_derived_series_stabilize : ∀ j ≥ n + i, derivedSeries G j = derivedSeries G (n + i) := by
              intro j hj; induction hj <;> simp_all +decide [ derivedSeries ] ;
            have h_derived_series_stabilize : derivedSeries G (derivedDepth G) = derivedSeries G (n + i) := by
              apply h_derived_series_stabilize;
              contrapose! hi_nontrivial;
              exact Nat.le_induction ( by exact derivedSeries_derivedDepth_eq_bot G ) ( fun k hk ih => by simp_all +decide [ derivedSeries ] ) _ hi_nontrivial.le;
            exact hi_nontrivial ( h_derived_series_stabilize.symm.trans ( derivedSeries_derivedDepth_eq_bot G ) );
        exact ⟨ by simpa using Subgroup.card_dvd_of_le h_derived_series_step.le, by simpa using Set.card_lt_card h_derived_series_step ⟩;
      obtain ⟨ k, hk ⟩ := h_derived_series_step.1;
      rcases k with ( _ | _ | k ) <;> simp_all +decide;
      have h_prime_factors : ∀ {a b : ℕ}, 0 < a → 0 < b → (a * b).primeFactorsList.length = a.primeFactorsList.length + b.primeFactorsList.length := by
        intros a b ha hb;
        rw [ ← Multiset.coe_card, ← Multiset.coe_card, ← Multiset.coe_card ];
        rw [ ← Multiset.card_add ];
        congr 1;
        ext p;
        simp +decide [ Nat.primeFactorsList, ha.ne', hb.ne' ];
      rw [ h_prime_factors ] <;> norm_num;
      · exact List.length_pos_iff.mpr ( by aesop );
      · exact Fintype.card_pos_iff.mpr ⟨ 1 ⟩;
    -- By induction on $i$, we can show that the length of the prime factors list of the derived series at step $n+i$ is at least $d-i$.
    have h_induction : ∀ i ≤ derivedDepth G - n, (Fintype.card (derivedSeries G (n + i))).primeFactorsList.length ≥ (Fintype.card (derivedSeries G (n + (derivedDepth G - n)))).primeFactorsList.length + (derivedDepth G - n - i) := by
      intro i hi
      induction' h : derivedDepth G - n - i with k hk generalizing i;
      · rw [ Nat.sub_eq_iff_eq_add ] at h <;> aesop;
      · specialize hk ( i + 1 ) ( by omega ) ( by omega );
        grind +suggestions;
    specialize h_induction 0 ; simp_all +decide;
    grind;
  specialize h_derived_series_length 0 ; aesop