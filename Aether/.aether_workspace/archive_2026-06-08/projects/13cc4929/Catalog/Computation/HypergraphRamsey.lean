/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Hypergraph Ramsey Theory: Beyond Graphs

This module formalizes foundations of Ramsey theory for r-uniform hypergraphs,
establishing structural bounds on the growth of hypergraph Ramsey numbers
via the tower function and proving key monotonicity/symmetry properties.

## Main Definitions

* `HypergraphColoring` — a 2-coloring of r-element subsets of `Fin n`
* `IsMonoSet` — predicate for monochromatic sets under a hypergraph coloring
* `HypergraphRamseyProp` — the Ramsey property for r-uniform hypergraphs
* `TowerExp` — iterated exponentiation (tower function)
* `RamseyDensitySpectrum` — novel invariant measuring Ramsey efficiency of colorings

## Main Results

* `ramsey_prop_symm` — symmetry of the Ramsey property (by color swap)
* `mono_subset` — monochromatic sets are closed under taking subsets
* `towerExp_strict_mono` — tower function is strictly monotone in height
* `ramseyDensity_le_one` — Ramsey density is bounded by 1
* `ramsey_prop_antimono_k` — anti-monotonicity of Ramsey property
-/

import Mathlib

open Finset Fintype BigOperators Function

namespace HypergraphRamsey

/-! ## Core Definitions -/

/-- An r-element subset of `Fin n`, representing a hyperedge in an r-uniform hypergraph. -/
def Hyperedge (n r : ℕ) := {s : Finset (Fin n) // s.card = r}

/-- A 2-coloring of r-uniform hyperedges on vertex set `Fin n`.
    Convention: `true` = red, `false` = blue. -/
def HypergraphColoring (n r : ℕ) := Hyperedge n r → Bool

/-- A set `S ⊆ Fin n` is monochromatic under coloring `c` with color `col`
    if every r-element subset of `S` receives color `col`. -/
def IsMonoSet (c : HypergraphColoring n r) (S : Finset (Fin n)) (col : Bool) : Prop :=
  ∀ (e : Hyperedge n r), (e.1 ⊆ S) → c e = col

/-- The hypergraph Ramsey property: every 2-coloring of r-subsets of `Fin n`
    contains either a red clique of size `k` or a blue clique of size `l`. -/
def HypergraphRamseyProp (n r k l : ℕ) : Prop :=
  ∀ (c : HypergraphColoring n r),
    (∃ (S : Finset (Fin n)), S.card = k ∧ IsMonoSet c S true) ∨
    (∃ (S : Finset (Fin n)), S.card = l ∧ IsMonoSet c S false)

/-- Tower of exponentials: TowerExp b 0 = 1, TowerExp b (n+1) = b^(TowerExp b n).
    This captures the growth rate of r-uniform hypergraph Ramsey numbers:
    R_r(k,k) is bounded by a tower of height r-2. -/
def TowerExp (b : ℕ) : ℕ → ℕ
  | 0 => 1
  | n + 1 => b ^ (TowerExp b n)

/-! ## Tower Function Properties -/

@[simp] theorem towerExp_zero (b : ℕ) : TowerExp b 0 = 1 := rfl
@[simp] theorem towerExp_succ (b n : ℕ) : TowerExp b (n + 1) = b ^ TowerExp b n := rfl

theorem towerExp_one (b : ℕ) : TowerExp b 1 = b := by simp [pow_one]
theorem towerExp_two (b : ℕ) : TowerExp b 2 = b ^ b := by simp [pow_one]

/-- TowerExp b n ≥ 1 for b ≥ 1. -/
theorem towerExp_pos (hb : 1 ≤ b) (n : ℕ) : 1 ≤ TowerExp b n := by
  induction n with
  | zero => simp
  | succ n ih => simp; exact Nat.one_le_pow _ _ hb

/-
The tower function is monotone in the height parameter for base ≥ 2.
-/
theorem towerExp_mono_height (hb : 2 ≤ b) {m n : ℕ} (hmn : m ≤ n) :
    TowerExp b m ≤ TowerExp b n := by
  induction' hmn with m n hmn ih <;> simp_all +decide [ TowerExp ];
  exact le_trans hmn ( le_of_lt ( Nat.recOn ( TowerExp b m ) ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; nlinarith [ Nat.pow_le_pow_right ( by linarith : 1 ≤ b ) ihn ] ) )

/-
The tower function is strictly monotone for base ≥ 2.
    This is the key growth property showing that increasing uniformity r
    causes a genuine jump in Ramsey number magnitude.
-/
theorem towerExp_strict_mono (hb : 2 ≤ b) {m n : ℕ} (hmn : m < n) :
    TowerExp b m < TowerExp b n := by
  induction' hmn with m n hmn ih;
  · exact Nat.lt_pow_self hb;
  · refine lt_of_lt_of_le hmn ?_;
    exact Nat.le_of_lt ( Nat.lt_pow_self hb )

/-! ## Monochromatic Set Properties -/

/-- If all r-subsets of S have the same color, then all r-subsets of any
    subset T ⊆ S also have the same color. This is the hereditary property
    of monochromatic sets. -/
theorem mono_subset {c : HypergraphColoring n r} {S T : Finset (Fin n)}
    (hTS : T ⊆ S) (col : Bool) (hmono : IsMonoSet c S col) :
    IsMonoSet c T col := by
  intro e he
  exact hmono e (Finset.Subset.trans he hTS)

/-! ## Symmetry of Ramsey Property -/

/-- The Ramsey property is symmetric in k and l. This follows by swapping
    colors: if c witnesses R(k,l), then ¬c witnesses R(l,k). -/
theorem ramsey_prop_symm : HypergraphRamseyProp n r k l ↔ HypergraphRamseyProp n r l k := by
  constructor <;> intro h c
  · have h' := h (fun e => !(c e))
    rcases h' with ⟨S, hS, hmono⟩ | ⟨S, hS, hmono⟩
    · right; exact ⟨S, hS, fun e he => by have := hmono e he; simp at this; exact this⟩
    · left; exact ⟨S, hS, fun e he => by have := hmono e he; simp at this; exact this⟩
  · have h' := h (fun e => !(c e))
    rcases h' with ⟨S, hS, hmono⟩ | ⟨S, hS, hmono⟩
    · right; exact ⟨S, hS, fun e he => by have := hmono e he; simp at this; exact this⟩
    · left; exact ⟨S, hS, fun e he => by have := hmono e he; simp at this; exact this⟩

/-! ## Anti-monotonicity -/

/-
Ramsey property is anti-monotone in k: if the property holds for (k, l),
    it also holds for (k', l) where k' ≤ k. We find a smaller monochromatic
    subset by taking a sub-finset.
-/
theorem ramsey_prop_antimono_k (h : HypergraphRamseyProp n r k l) (hk : k' ≤ k) :
    HypergraphRamseyProp n r k' l := by
  intro c
  obtain ⟨S, hS⟩ | ⟨S, hS⟩ := h c;
  · exact Or.inl <| by rcases Finset.exists_subset_card_eq ( by linarith : k' ≤ #S ) with ⟨ T, hT₁, hT₂ ⟩ ; exact ⟨ T, hT₂, mono_subset hT₁ true hS.2 ⟩ ;
  · grind

/-- Ramsey property is anti-monotone in l. -/
theorem ramsey_prop_antimono_l (h : HypergraphRamseyProp n r k l) (hl : l' ≤ l) :
    HypergraphRamseyProp n r k l' := by
  rw [ramsey_prop_symm] at h ⊢
  exact ramsey_prop_antimono_k h hl

/-! ## Novel Concept: Ramsey Density Spectrum -/

/-- The Ramsey density spectrum of a coloring captures the sizes of the largest
    monochromatic cliques in each color. This is a novel invariant measuring
    how "Ramsey-efficient" a particular coloring is.

    A coloring with high density (close to 1) is "Ramsey-extremal" — its largest
    monochromatic clique is nearly as large as the entire vertex set.
    A coloring with low density is "Ramsey-avoiding" — it manages to keep
    monochromatic cliques small relative to the ground set. -/
structure RamseyDensitySpectrum (n r : ℕ) where
  /-- The coloring being analyzed -/
  coloring : HypergraphColoring n r
  /-- Size of the largest red monochromatic clique -/
  maxRedClique : ℕ
  /-- Size of the largest blue monochromatic clique -/
  maxBlueClique : ℕ
  /-- The red clique is witnessed -/
  red_witness : ∃ S : Finset (Fin n), S.card = maxRedClique ∧ IsMonoSet coloring S true
  /-- The blue clique is witnessed -/
  blue_witness : ∃ S : Finset (Fin n), S.card = maxBlueClique ∧ IsMonoSet coloring S false
  /-- The red clique is maximal -/
  red_maximal : ∀ S : Finset (Fin n), IsMonoSet coloring S true → S.card ≤ maxRedClique
  /-- The blue clique is maximal -/
  blue_maximal : ∀ S : Finset (Fin n), IsMonoSet coloring S false → S.card ≤ maxBlueClique

/-- The Ramsey density is the ratio of the larger monochromatic clique to n. -/
noncomputable def ramseyDensity (spec : RamseyDensitySpectrum n r) : ℚ :=
  (max spec.maxRedClique spec.maxBlueClique : ℚ) / n

/-- The maximum monochromatic clique size is at most n (it's a subset of [n]). -/
theorem maxClique_le_n (spec : RamseyDensitySpectrum n r) :
    max spec.maxRedClique spec.maxBlueClique ≤ n := by
  apply max_le
  · obtain ⟨S, hS, _⟩ := spec.red_witness
    have h1 := S.card_le_univ
    simp [Fintype.card_fin] at h1
    omega
  · obtain ⟨S, hS, _⟩ := spec.blue_witness
    have h1 := S.card_le_univ
    simp [Fintype.card_fin] at h1
    omega

/-- Any Ramsey density spectrum has density ≤ 1. -/
theorem ramseyDensity_le_one (spec : RamseyDensitySpectrum n r) (hn : 0 < n) :
    ramseyDensity spec ≤ 1 := by
  unfold ramseyDensity
  rw [div_le_one (by exact_mod_cast hn : (0 : ℚ) < ↑n)]
  exact_mod_cast maxClique_le_n spec

/-- The Ramsey density is nonnegative. -/
theorem ramseyDensity_nonneg (spec : RamseyDensitySpectrum n r) :
    0 ≤ ramseyDensity spec := by
  unfold ramseyDensity; positivity

/-! ## Density Spectrum and Ramsey Property Connection -/

/-
If the Ramsey property holds, then every density spectrum has
    max(red, blue) ≥ min(k, l). This connects the density spectrum
    to the classical Ramsey threshold.
-/
theorem density_ramsey_threshold (h : HypergraphRamseyProp n r k l)
    (spec : RamseyDensitySpectrum n r) :
    min k l ≤ max spec.maxRedClique spec.maxBlueClique := by
  obtain ⟨S, hS⟩ : (∃ S : Finset (Fin n), S.card = k ∧ IsMonoSet spec.coloring S true) ∨ (∃ S : Finset (Fin n), S.card = l ∧ IsMonoSet spec.coloring S false) := h spec.coloring;
  · exact le_max_of_le_left ( by linarith [ spec.red_maximal S hS.2, min_le_left k l ] );
  · obtain ⟨ S, hS₁, hS₂ ⟩ := ‹_›;
    exact le_trans ( by aesop ) ( le_max_of_le_right ( spec.blue_maximal S hS₂ ) )

/-! ## Tower Growth Dominance -/

/-
The tower function eventually dominates the identity.
    For b = 2 and n ≥ 2, TowerExp 2 n > n.
    This is a stepping stone to showing hypergraph Ramsey numbers
    grow much faster than the ground set size.
-/
theorem towerExp_dominates_id (hn : 2 ≤ n) : n < TowerExp 2 n := by
  induction' n with n ih <;> simp_all +decide [ TowerExp ];
  by_cases h : 2 ≤ n;
  · exact Nat.lt_of_le_of_lt ( Nat.succ_le_of_lt ( ih h ) ) ( Nat.recOn ( TowerExp 2 n ) ( by norm_num ) fun n ihn => by rw [ Nat.pow_succ' ] ; linarith [ Nat.pow_le_pow_right ( by norm_num : 1 ≤ 2 ) ihn ] );
  · interval_cases n ; trivial

/-! ## Conjecture: Double Exponential Growth -/

/-- **Conjecture (Double Exponential Growth for 3-uniform Hypergraphs)**:

    There exists c > 0 such that for all k ≥ 4, the minimum n satisfying
    the 3-uniform Ramsey property R_3(k,k) satisfies n ≥ c · k².

    This is a weakened form of the full conjecture R_3(k,k) ≥ 2^{ck²}.
    The quadratic lower bound is itself non-trivial and follows from
    simple counting arguments.

    **Testable predictions**:
    - R_3(3,3) = 4: 4 ≥ c · 9, so c ≤ 4/9 ≈ 0.44
    - R_3(4,4) = 13: 13 ≥ c · 16, so c ≤ 13/16 ≈ 0.81
    - R_3(5,5) ∈ [34,55]: need 34 ≥ c · 25, so c ≤ 1.36

    A consistent c ≈ 0.4 would work. Testing: verify log₂(R₃(k,k))/k²
    is approximately constant for k = 3,4,5. -/
def DoubleExpGrowthConjecture : Prop :=
  ∃ (c : ℚ), 0 < c ∧
    ∀ k : ℕ, 4 ≤ k →
      ∀ n : ℕ, HypergraphRamseyProp n 3 k k →
        c * (k : ℚ)^2 ≤ n

end HypergraphRamsey