/-
# Tropical Amplitude Amplification via Min-Plus Dynamics

This file develops a rigorous theory of tropical amplitude amplification —
the min-plus analogue of Grover's quantum search algorithm.

## Overview

In quantum computing, Grover's algorithm amplifies the amplitude of marked states
via alternating phase oracle and diffusion operators. Here we develop the tropical
(min-plus) counterpart: instead of amplitudes in a Hilbert space, we have *costs*
in ℕ (or ℤ), and instead of unitary rotations, we have *cost penalties* on unmarked
states. The key insight is that repeatedly penalizing unmarked states increases the
*gap* between marked and unmarked minima, eventually isolating the marked argmin.

## Main Results

1. **One-step gap amplification** (`oracleShift_markedMin`, `oracleShift_unmarkedMin`):
   The oracle shift preserves marked minima and increases unmarked minima by exactly `bonus`.

2. **Iterate closed form** (`iterate_oracleShift_eq`):
   After `t` rounds, the cost profile is `c i` for marked states and `c i + t * bonus`
   for unmarked states.

3. **Iterated gap formula** (`iterated_oracleShift_gap`):
   The gap grows linearly: `gap(t) = gap(0) + t * bonus`.

4. **Marked argmin dominance** (`amplification_marked_beats_unmarked`):
   After sufficiently many rounds, the marked argmin beats every unmarked state.

5. **Argmin certification** (`amplification_argmin_is_marked`):
   After sufficiently many rounds, the global minimum is achieved by a marked state.

6. **Gap-doubling via diffusion** (`tropGroverStep_gap_doubling`):
   A combined oracle + diffusion step doubles the gap, yielding exponential amplification.

## Connection to Existing Catalog

This builds on the distributivity laws:
- `tropical_plus_distributes_over_min` in `Tropical/CA/MinPlusExpr.lean`
- `plus_distributes_over_min` in `Tropical/Dequantization/Core.lean`

The oracle shift is the tropical analogue of a quantum phase oracle,
and the diffusion operator corresponds to the Grover diffusion/reflection.
-/

import Mathlib

namespace TropicalAmplification

/-! ## Basic Definitions -/

/-- The set of unmarked states: complement of `M` in `Fin n`. -/
def unmarkedFinset {n : ℕ} (M : Finset (Fin n)) : Finset (Fin n) :=
  Finset.univ \ M

/-- Minimum cost among marked states. -/
def markedMin {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty) (c : Fin n → ℕ) : ℕ :=
  M.inf' hM c

/-- Minimum cost among unmarked states. -/
def unmarkedMin {n : ℕ} (M : Finset (Fin n))
    (hU : (unmarkedFinset M).Nonempty) (c : Fin n → ℕ) : ℕ :=
  (unmarkedFinset M).inf' hU c

/-- The oracle shift: marked states keep their cost, unmarked states get a penalty of `bonus`.
    This is the tropical analogue of a quantum phase oracle: in the min-plus semiring,
    adding cost to unmarked states is equivalent to penalizing them. -/
def oracleShift {n : ℕ} (M : Finset (Fin n)) (bonus : ℕ) (c : Fin n → ℕ) : Fin n → ℕ :=
  fun i => if i ∈ M then c i else c i + bonus

/-- Global minimum of a cost profile over all of `Fin n`. -/
noncomputable def globalMin {n : ℕ} [NeZero n] (c : Fin n → ℕ) : ℕ :=
  Finset.univ.inf' Finset.univ_nonempty c

/-! ## Pointwise Behavior Lemmas -/

@[simp]
theorem oracleShift_marked {n : ℕ} (M : Finset (Fin n)) (bonus : ℕ)
    (c : Fin n → ℕ) (i : Fin n) (hi : i ∈ M) :
    oracleShift M bonus c i = c i := by
  simp [oracleShift, hi]

@[simp]
theorem oracleShift_unmarked {n : ℕ} (M : Finset (Fin n)) (bonus : ℕ)
    (c : Fin n → ℕ) (i : Fin n) (hi : i ∉ M) :
    oracleShift M bonus c i = c i + bonus := by
  simp [oracleShift, hi]

/-! ## Oracle Shift Preserves Marked Min -/

/-- The oracle shift does not change the minimum over marked states. -/
theorem oracleShift_markedMin {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty)
    (bonus : ℕ) (c : Fin n → ℕ) :
    markedMin M hM (oracleShift M bonus c) = markedMin M hM c := by
  unfold markedMin oracleShift; aesop

/-! ## Oracle Shift Increases Unmarked Min -/

/-
The oracle shift increases the unmarked minimum by exactly `bonus`.
-/
theorem oracleShift_unmarkedMin {n : ℕ} (M : Finset (Fin n))
    (hU : (unmarkedFinset M).Nonempty) (bonus : ℕ) (c : Fin n → ℕ) :
    unmarkedMin M hU (oracleShift M bonus c) = unmarkedMin M hU c + bonus := by
  refine' le_antisymm _ _;
  · simp +decide [ unmarkedMin, oracleShift ];
    exact Exists.elim ( Finset.exists_mem_eq_inf' hU c ) fun x hx => ⟨ x, by aesop ⟩;
  · simp +decide [ unmarkedMin ];
    intro i hi; rw [ oracleShift ] ; split_ifs <;> simp_all +decide [ unmarkedFinset ] ;
    exact ⟨ i, by assumption, le_rfl ⟩

/-! ## One-Step Gap Amplification -/

/-- Combined one-step result: oracle shift preserves marked min and shifts unmarked min. -/
theorem oracleShift_gap_increases {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty)
    (hU : (unmarkedFinset M).Nonempty) (bonus : ℕ) (c : Fin n → ℕ) :
    unmarkedMin M hU (oracleShift M bonus c) = unmarkedMin M hU c + bonus ∧
    markedMin M hM (oracleShift M bonus c) = markedMin M hM c := by
  exact ⟨oracleShift_unmarkedMin M hU bonus c, oracleShift_markedMin M hM bonus c⟩

/-! ## Iterate Closed Form -/

/-
After `t` iterations of `oracleShift M bonus`, the cost profile is unchanged on marked
    states and increased by `t * bonus` on unmarked states.
-/
theorem iterate_oracleShift_eq {n : ℕ} (M : Finset (Fin n)) (bonus t : ℕ) (c : Fin n → ℕ) :
    ((oracleShift M bonus)^[t] c) =
      fun i => if i ∈ M then c i else c i + t * bonus := by
  induction t <;> simp_all +decide [ Function.iterate_succ_apply' ];
  -- By definition of oracleShift, we can split into cases based on whether i is in M or not.
  funext i; simp [oracleShift];
  grind

/-- Corollary: value at a marked state after `t` iterations. -/
theorem iterate_oracleShift_marked {n : ℕ} (M : Finset (Fin n)) (bonus t : ℕ)
    (c : Fin n → ℕ) (i : Fin n) (hi : i ∈ M) :
    ((oracleShift M bonus)^[t] c) i = c i := by
  have := congr_fun (iterate_oracleShift_eq M bonus t c) i
  simp [hi] at this
  exact this

/-- Corollary: value at an unmarked state after `t` iterations. -/
theorem iterate_oracleShift_unmarked {n : ℕ} (M : Finset (Fin n)) (bonus t : ℕ)
    (c : Fin n → ℕ) (i : Fin n) (hi : i ∉ M) :
    ((oracleShift M bonus)^[t] c) i = c i + t * bonus := by
  have := congr_fun (iterate_oracleShift_eq M bonus t c) i
  simp [hi] at this
  exact this

/-! ## Iterated Gap Formula -/

/-
The marked minimum after `t` iterations equals the original marked minimum.
-/
theorem iterate_markedMin {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty)
    (bonus t : ℕ) (c : Fin n → ℕ) :
    markedMin M hM ((oracleShift M bonus)^[t] c) = markedMin M hM c := by
  convert oracleShift_markedMin M hM ( t * bonus ) c using 1;
  exact congr_arg ( fun f => markedMin M hM f ) ( iterate_oracleShift_eq M bonus t c )

/-
The unmarked minimum after `t` iterations equals the original plus `t * bonus`.
-/
theorem iterate_unmarkedMin {n : ℕ} (M : Finset (Fin n))
    (hU : (unmarkedFinset M).Nonempty) (bonus t : ℕ) (c : Fin n → ℕ) :
    unmarkedMin M hU ((oracleShift M bonus)^[t] c) = unmarkedMin M hU c + t * bonus := by
  -- By definition of `unmarkedMin`, we have:
  unfold unmarkedMin;
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' hU ( fun i => c i );
    grind +suggestions;
  · intro i hi; rw [ iterate_oracleShift_unmarked M bonus t c i ( Finset.mem_sdiff.mp hi |>.2 ) ] ; exact add_le_add ( Finset.inf'_le _ hi ) le_rfl;

/-- The gap after `t` iterations: `gap(t) = unmarkedMin(t) - markedMin(t)`.
    When `markedMin ≤ unmarkedMin` (the gap is non-negative initially),
    the gap grows by exactly `t * bonus`. -/
theorem iterated_oracleShift_gap {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty)
    (hU : (unmarkedFinset M).Nonempty) (bonus t : ℕ) (c : Fin n → ℕ)
    (hle : markedMin M hM c ≤ unmarkedMin M hU c) :
    unmarkedMin M hU ((oracleShift M bonus)^[t] c) -
      markedMin M hM ((oracleShift M bonus)^[t] c) =
    (unmarkedMin M hU c - markedMin M hM c) + t * bonus := by
  rw [iterate_markedMin, iterate_unmarkedMin]
  omega

/-! ## Marked Argmin Dominates All Unmarked States -/

/-
After sufficiently many rounds, the marked argmin (the state achieving `markedMin`)
    has strictly lower cost than every unmarked state. This is the correct formulation
    of tropical amplification: the *best* marked state eventually dominates all unmarked states.

    The hypothesis `markedMin M hM c < unmarkedMin M hU c + t * bonus` ensures enough
    rounds have passed. Note this is strictly weaker than requiring all marked states
    to beat all unmarked states.
-/
theorem amplification_marked_beats_unmarked {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty)
    (hU : (unmarkedFinset M).Nonempty) (bonus t : ℕ) (c : Fin n → ℕ)
    (h : markedMin M hM c < unmarkedMin M hU c + t * bonus) :
    ∀ j, j ∉ M →
      markedMin M hM ((oracleShift M bonus)^[t] c) <
        ((oracleShift M bonus)^[t] c) j := by
  -- By definition of `iterate_oracleShift_eq`, we have:
  have h_iterated : ∀ j, (oracleShift M bonus)^[t] c j = if j ∈ M then c j else c j + t * bonus := by
    exact fun j => congr_fun ( iterate_oracleShift_eq M bonus t c ) j;
  intro j hj; have := iterate_markedMin M hM bonus t c; have := iterate_unmarkedMin M hU bonus t c; simp_all +decide [ Finset.inf'_le, Finset.le_inf' ] ;
  exact h.trans_le ( Nat.add_le_add_right ( Finset.inf'_le _ <| by unfold unmarkedFinset; aesop ) _ )

/-! ## Argmin Certification -/

/-
After amplification, the global minimum over the full space equals the marked minimum.
    This means the argmin is guaranteed to lie in the marked set.
-/
theorem amplification_argmin_is_marked {n : ℕ} [NeZero n]
    (M : Finset (Fin n)) (hM : M.Nonempty)
    (hU : (unmarkedFinset M).Nonempty) (bonus t : ℕ) (c : Fin n → ℕ)
    (h : markedMin M hM c < unmarkedMin M hU c + t * bonus) :
    globalMin ((oracleShift M bonus)^[t] c) =
      markedMin M hM ((oracleShift M bonus)^[t] c) := by
  -- Apply the definition of `globalMin` and `markedMin`.
  unfold globalMin markedMin;
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · exact fun i hi => ⟨ i, le_rfl ⟩;
  · intro b; cases' em ( b ∈ M ) with hb hb <;> simp_all +decide [ iterate_oracleShift_eq ] ;
    · exact ⟨ b, hb, by rw [ if_pos hb ] ⟩;
    · have := Finset.exists_min_image M c hM;
      obtain ⟨ x, hx₁, hx₂ ⟩ := this; use x; simp_all +decide [ markedMin ] ;
      exact le_trans ( hx₂ _ h.choose_spec.1 ) ( by linarith [ h.choose_spec.2, show unmarkedMin M hU c ≤ c b from Finset.inf'_le _ ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ _, hb ⟩ ) ] )

/-! ## Separation with Explicit Round Bound -/

/-
Given an initial cost profile where the maximum marked cost is `cmax_m` and the minimum
    unmarked cost is `cmin_u`, after `t` rounds with `t * bonus > cmax_m - cmin_u`,
    every marked state beats every unmarked state.
-/
theorem full_separation_with_max {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty)
    (hU : (unmarkedFinset M).Nonempty) (bonus t : ℕ) (c : Fin n → ℕ)
    (h : ∀ i ∈ M, c i < unmarkedMin M hU c + t * bonus) :
    ∀ i ∈ M, ∀ j ∉ M,
      ((oracleShift M bonus)^[t] c) i < ((oracleShift M bonus)^[t] c) j := by
  -- By definition of `oracleShift`, we know that after `t` rounds, the cost of a marked state `i` is `c i`, and the cost of an unmarked state `j` is `c j + t * bonus`.
  intros i hi j hj
  have h_cost_i : (oracleShift M bonus)^[t] c i = c i := by
    exact iterate_oracleShift_marked M bonus t c i hi
  have h_cost_j : (oracleShift M bonus)^[t] c j = c j + t * bonus := by
    exact iterate_oracleShift_unmarked M bonus t c j hj;
  linarith [ h i hi, show unmarkedMin M hU c ≤ c j from Finset.inf'_le _ <| Finset.mem_sdiff.mpr ⟨ Finset.mem_univ j, hj ⟩ ]

/-! ## Gap Doubling via Diffusion (ℤ version)

For the diffusion operator, we switch to ℤ to avoid natural number subtraction issues.
The diffusion step doubles distances from the global minimum, creating exponential
gap growth when combined with the oracle shift. -/

/-- Oracle shift on integer-valued cost profiles. -/
def oracleShiftZ {n : ℕ} (M : Finset (Fin n)) (bonus : ℤ) (c : Fin n → ℤ) : Fin n → ℤ :=
  fun i => if i ∈ M then c i else c i + bonus

/-- Global minimum over ℤ-valued cost profiles. -/
noncomputable def globalMinZ {n : ℕ} [NeZero n] (c : Fin n → ℤ) : ℤ :=
  Finset.univ.inf' Finset.univ_nonempty c

/-- Marked minimum over ℤ-valued cost profiles. -/
noncomputable def markedMinZ {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty)
    (c : Fin n → ℤ) : ℤ :=
  M.inf' hM c

/-- Unmarked minimum over ℤ-valued cost profiles. -/
noncomputable def unmarkedMinZ {n : ℕ} (M : Finset (Fin n))
    (hU : (unmarkedFinset M).Nonempty) (c : Fin n → ℤ) : ℤ :=
  (unmarkedFinset M).inf' hU c

/-- The tropical diffusion operator: doubles the distance of every cost from the global minimum.
    `diffuseZ c i = μ + 2 * (c i - μ) = 2 * c i - μ` where `μ = globalMinZ c`. -/
noncomputable def diffuseZ {n : ℕ} [NeZero n] (c : Fin n → ℤ) : Fin n → ℤ :=
  let μ := globalMinZ c
  fun i => 2 * c i - μ

/-- The combined tropical Grover step: oracle shift followed by diffusion. -/
noncomputable def tropGroverStep {n : ℕ} [NeZero n]
    (M : Finset (Fin n)) (bonus : ℤ) (c : Fin n → ℤ) : Fin n → ℤ :=
  diffuseZ (oracleShiftZ M bonus c)

@[simp]
theorem oracleShiftZ_marked {n : ℕ} (M : Finset (Fin n)) (bonus : ℤ)
    (c : Fin n → ℤ) (i : Fin n) (hi : i ∈ M) :
    oracleShiftZ M bonus c i = c i := by
  simp [oracleShiftZ, hi]

@[simp]
theorem oracleShiftZ_unmarked {n : ℕ} (M : Finset (Fin n)) (bonus : ℤ)
    (c : Fin n → ℤ) (i : Fin n) (hi : i ∉ M) :
    oracleShiftZ M bonus c i = c i + bonus := by
  simp [oracleShiftZ, hi]

/-
The oracle shift on ℤ preserves marked minimum.
-/
theorem oracleShiftZ_markedMin {n : ℕ} (M : Finset (Fin n)) (hM : M.Nonempty)
    (bonus : ℤ) (c : Fin n → ℤ) :
    markedMinZ M hM (oracleShiftZ M bonus c) = markedMinZ M hM c := by
  refine' le_antisymm _ _ <;> simp_all +decide [ markedMinZ ]

/-
The oracle shift on ℤ increases unmarked minimum by exactly `bonus`.
-/
theorem oracleShiftZ_unmarkedMin {n : ℕ} (M : Finset (Fin n))
    (hU : (unmarkedFinset M).Nonempty) (bonus : ℤ) (c : Fin n → ℤ) :
    unmarkedMinZ M hU (oracleShiftZ M bonus c) = unmarkedMinZ M hU c + bonus := by
  nontriviality;
  unfold unmarkedMinZ oracleShiftZ;
  nontriviality;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' hU fun x => c x;
    exact ⟨ i, hi.1, by rw [ if_neg ( Finset.mem_sdiff.mp hi.1 |>.2 ) ] ; linarith! ⟩;
  · intro i hi; split_ifs <;> simp_all +decide [ Finset.mem_sdiff, Finset.mem_univ ] ;
    · exact absurd ‹_› ( Finset.mem_sdiff.mp hi |>.2 );
    · exact ⟨ i, hi, le_rfl ⟩

/-
Diffusion preserves the global minimum:
    since `diffuseZ c i = 2 * c i - μ` and the minimum of `c` is `μ`,
    the minimum of `diffuseZ c` is `2 * μ - μ = μ`.
-/
theorem diffuseZ_globalMin {n : ℕ} [NeZero n] (c : Fin n → ℤ) :
    globalMinZ (diffuseZ c) = globalMinZ c := by
  refine' le_antisymm _ _ <;> simp_all +decide [ globalMinZ ];
  · intro b;
    unfold diffuseZ;
    exact ⟨ Classical.choose ( Finset.exists_min_image Finset.univ ( fun i => c i ) Finset.univ_nonempty ), by linarith [ Classical.choose_spec ( Finset.exists_min_image Finset.univ ( fun i => c i ) Finset.univ_nonempty ) |>.2 b ( Finset.mem_univ b ), show globalMinZ c = c ( Classical.choose ( Finset.exists_min_image Finset.univ ( fun i => c i ) Finset.univ_nonempty ) ) from by exact le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ( Finset.le_inf' _ _ fun i hi => Classical.choose_spec ( Finset.exists_min_image Finset.univ ( fun i => c i ) Finset.univ_nonempty ) |>.2 i hi ) ] ⟩;
  · intro b; use b; unfold diffuseZ;
    linarith [ show globalMinZ c ≤ c b from Finset.inf'_le _ ( Finset.mem_univ _ ) ]

/-
When marked min equals global min and bonus ≥ 0,
    the global min after oracle shift equals the marked min.
    This is because oracle shift only adds to unmarked costs.
-/
theorem oracleShiftZ_globalMin_eq_markedMin {n : ℕ} [NeZero n]
    (M : Finset (Fin n)) (hM : M.Nonempty) (bonus : ℤ) (c : Fin n → ℤ)
    (hbonus : 0 ≤ bonus)
    (hmin : markedMinZ M hM c = globalMinZ c) :
    globalMinZ (oracleShiftZ M bonus c) = markedMinZ M hM c := by
  refine' le_antisymm _ _;
  · simp +decide [ globalMinZ, markedMinZ ];
    exact fun i hi => ⟨ i, by unfold oracleShiftZ; aesop ⟩;
  · refine' hmin ▸ le_trans _ ( Finset.le_inf' _ _ _ );
    exact le_rfl;
    intro i hi; by_cases hi' : i ∈ M <;> simp_all +decide [ globalMinZ ] ;
    · use i;
    · exact ⟨ i, by linarith ⟩

/-
Diffusion on ℤ preserves marked minimum when markedMin = globalMin.
    Since diffuseZ maps c i ↦ 2 * c i - μ, and for the marked argmin c i = μ,
    we get diffuseZ c i = μ. So the marked min after diffusion is μ.
-/
theorem diffuseZ_markedMin_eq {n : ℕ} [NeZero n]
    (M : Finset (Fin n)) (hM : M.Nonempty) (c : Fin n → ℤ)
    (hmin : markedMinZ M hM c = globalMinZ c) :
    markedMinZ M hM (diffuseZ c) = globalMinZ c := by
  unfold markedMinZ globalMinZ at *;
  refine' le_antisymm _ _;
  · -- Since markedMinZ M hM c = globalMinZ c, there exists an i₀ ∈ M such that c i₀ = globalMinZ c.
    obtain ⟨i₀, hi₀⟩ : ∃ i₀ ∈ M, c i₀ = Finset.univ.inf' (Finset.univ_nonempty) c := by
      have := Finset.exists_mem_eq_inf' hM c; aesop;
    refine' le_trans ( Finset.inf'_le _ hi₀.1 ) _;
    unfold diffuseZ; linarith!;
  · simp +decide [ diffuseZ ];
    exact fun i hi => ⟨ i, by linarith [ show globalMinZ c ≤ c i from Finset.inf'_le _ ( Finset.mem_univ i ) ] ⟩

/-
Diffusion doubles the unmarked-marked gap.
    Since diffuseZ maps c i ↦ 2 * c i - μ where μ = globalMinZ c,
    if markedMin = μ, then:
    - markedMin(diffuseZ c) = 2μ - μ = μ
    - unmarkedMin(diffuseZ c) = 2 * unmarkedMin - μ
    So gap_new = (2 * unmarkedMin - μ) - μ = 2 * (unmarkedMin - μ) = 2 * gap_old.
-/
theorem diffuseZ_doubles_gap {n : ℕ} [NeZero n]
    (M : Finset (Fin n)) (hM : M.Nonempty)
    (hU : (unmarkedFinset M).Nonempty)
    (c : Fin n → ℤ)
    (hmin : markedMinZ M hM c = globalMinZ c) :
    unmarkedMinZ M hU (diffuseZ c) - markedMinZ M hM (diffuseZ c) =
      2 * (unmarkedMinZ M hU c - markedMinZ M hM c) := by
  -- By definition of `diffuseZ`, we know that `unmarkedMinZ M hU (diffuseZ c)` is the infimum of `2 * c i - μ` over the unmarked set.
  have h_unmarkedMin_diffuse : unmarkedMinZ M hU (diffuseZ c) = 2 * unmarkedMinZ M hU c - globalMinZ c := by
    unfold unmarkedMinZ diffuseZ;
    refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
    · exact Finset.exists_min_image _ _ hU;
    · exact fun i hi => ⟨ i, hi, le_rfl ⟩;
  linarith [ diffuseZ_markedMin_eq M hM c hmin ]

/-
**Gap-doubling theorem**: When the marked minimum equals the global minimum
    and the bonus is non-negative, one tropical Grover step doubles the gap plus
    adds twice the bonus.

    Specifically: `gap_new = 2 * (gap_old + bonus)`.

    This is the tropical analogue of Grover's amplitude amplification: each round
    doubles the gap, leading to exponential separation in `O(log(1/gap₀))` rounds.
-/
theorem tropGroverStep_gap_doubling {n : ℕ} [NeZero n]
    (M : Finset (Fin n)) (hM : M.Nonempty)
    (hU : (unmarkedFinset M).Nonempty) (bonus : ℤ) (c : Fin n → ℤ)
    (hbonus : 0 ≤ bonus)
    (hmin : markedMinZ M hM c = globalMinZ c) :
    unmarkedMinZ M hU (tropGroverStep M bonus c) -
      markedMinZ M hM (tropGroverStep M bonus c) =
    2 * (unmarkedMinZ M hU c - markedMinZ M hM c + bonus) := by
  convert diffuseZ_doubles_gap M hM hU _ _ using 1;
  · rw [ oracleShiftZ_unmarkedMin, oracleShiftZ_markedMin ] ; ring;
  · rw [ oracleShiftZ_globalMin_eq_markedMin M hM bonus c hbonus hmin, oracleShiftZ_markedMin M hM bonus c ]

end TropicalAmplification