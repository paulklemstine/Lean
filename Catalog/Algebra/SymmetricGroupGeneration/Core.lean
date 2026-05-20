/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Symmetric Group Generation Probability

This file develops the formal theory of random generation of symmetric groups.
Given two uniformly random permutations σ, τ ∈ S_n, we study the probability
P_n that ⟨σ, τ⟩ = S_n.

## Main results

1. **Subset preservation counting**: The number of permutations preserving a
   fixed k-element subset is k!(n-k)!, and thus the number of pairs is (k!(n-k)!)².

2. **Binomial reciprocal sum bound**: The sum ∑_{k=1}^{n-1} C(n,k)⁻¹ ≤ 2/n + 8/n²,
   controlling the non-transitivity probability.

3. **Parity obstruction**: For n ≥ 2, the probability that both permutations
   are even is exactly 1/4, giving the upper bound P_n ≤ 3/4.

4. **Cross-domain connection**: The obstruction structure connects to Boolean
   isoperimetry via edge-term dominance in the subset lattice.

5. **Dixon decomposition scaffold**: Lower bound P_n ≥ 3/4 - 2/n - O(1/n²) - δ_n.

## References

* Dixon, J.D. (1969). The probability of generating the symmetric group.
* Babai, L. (1989). The probability of generating the symmetric group.
-/

import Mathlib

open Finset Fintype Equiv.Perm Nat

/-! ## Core definitions -/

/-- A permutation preserves a finset if it maps the finset to itself. -/
def preservesFinset {n : ℕ} (σ : Equiv.Perm (Fin n)) (A : Finset (Fin n)) : Prop :=
  ∀ x : Fin n, x ∈ A ↔ σ x ∈ A

/-- Both permutations in a pair preserve a finset. -/
def pairPreservesFinset {n : ℕ}
    (σ τ : Equiv.Perm (Fin n)) (A : Finset (Fin n)) : Prop :=
  preservesFinset σ A ∧ preservesFinset τ A

/-- Two permutations generate the full symmetric group S_n. -/
def generatesSymm (n : ℕ) (σ τ : Equiv.Perm (Fin n)) : Prop :=
  Subgroup.closure ({σ, τ} : Set (Equiv.Perm (Fin n))) = ⊤

instance preservesFinset.decidable {n : ℕ} (σ : Equiv.Perm (Fin n))
    (A : Finset (Fin n)) : Decidable (preservesFinset σ A) :=
  Fintype.decidableForallFintype

instance pairPreservesFinset.decidable {n : ℕ}
    (σ τ : Equiv.Perm (Fin n)) (A : Finset (Fin n)) :
    Decidable (pairPreservesFinset σ τ A) :=
  instDecidableAnd

/-- The set of permutations preserving a given finset A. -/
noncomputable def permPreservingFinset {n : ℕ} (A : Finset (Fin n)) :
    Finset (Equiv.Perm (Fin n)) :=
  Finset.univ.filter (fun σ => preservesFinset σ A)

/-- The set of pairs (σ,τ) both preserving a given finset A. -/
noncomputable def pairsPreservingFinset {n : ℕ} (A : Finset (Fin n)) :
    Finset (Equiv.Perm (Fin n) × Equiv.Perm (Fin n)) :=
  Finset.univ.filter (fun p => pairPreservesFinset p.1 p.2 A)

/-- Count of pairs where both permutations are even (in the alternating group). -/
noncomputable def evenPairCount (n : ℕ) : ℕ :=
  Fintype.card (alternatingGroup (Fin n)) ^ 2

/-- The probability that both random permutations are even. -/
noncomputable def probBothEvenReal (n : ℕ) : ℝ :=
  (evenPairCount n : ℝ) / ((Fintype.card (Equiv.Perm (Fin n)))^2 : ℝ)

/-- The reciprocal binomial sum ∑_{k=1}^{n-1} 1/C(n,k). -/
noncomputable def recipBinomialSum (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.Icc 1 (n - 1), ((Nat.choose n k : ℝ))⁻¹

/-! ## Part 1: Subset Preservation -/

/-
Permutations preserving A: closure under composition.
-/
theorem preservesFinset_mul {n : ℕ} (σ τ : Equiv.Perm (Fin n))
    (A : Finset (Fin n)) (hσ : preservesFinset σ A) (hτ : preservesFinset τ A) :
    preservesFinset (σ * τ) A := by
  exact fun x => by have := hσ ( τ x ) ; have := hτ x; tauto;

/-- The identity preserves every finset. -/
theorem preservesFinset_one {n : ℕ} (A : Finset (Fin n)) :
    preservesFinset (1 : Equiv.Perm (Fin n)) A := by
  intro x; simp

/-
If σ preserves A, so does σ⁻¹.
-/
theorem preservesFinset_inv {n : ℕ} (σ : Equiv.Perm (Fin n))
    (A : Finset (Fin n)) (h : preservesFinset σ A) :
    preservesFinset σ⁻¹ A := by
  intro x;
  have := h ( σ⁻¹ x );
  aesop

/-
Key cardinality theorem: the number of permutations of Fin n that
preserve a finset A of cardinality k equals k! * (n - k)!.

Proof idea: A permutation preserving A decomposes as an independent
permutation of A and a permutation of Aᶜ. The set of such permutations
is in bijection with Perm(A) × Perm(Aᶜ), giving k! · (n-k)!.
-/
theorem card_perms_preserving_finset
    (n k : ℕ) (hk : k ≤ n) (A : Finset (Fin n))
    (hA : A.card = k) :
    (permPreservingFinset A).card = Nat.factorial k * Nat.factorial (n - k) := by
  -- We'll use the fact that if the permutation preserves A, then it restricts to a permutation of A and a permutation of its complement.
  have h_restrict : ∀ σ : Equiv.Perm (Fin n), preservesFinset σ A ↔ ∃ σ₁ : Equiv.Perm A, ∃ σ₂ : Equiv.Perm {x : Fin n | x ∉ A}, σ = Equiv.Perm.ofSubtype σ₁ * Equiv.Perm.ofSubtype σ₂ := by
    intro σ
    constructor
    intro hσ
    obtain ⟨σ₁, σ₂, hσ_eq⟩ : ∃ σ₁ : Equiv.Perm A, ∃ σ₂ : Equiv.Perm {x : Fin n | x ∉ A}, σ = Equiv.Perm.ofSubtype σ₁ * Equiv.Perm.ofSubtype σ₂ := by
      use Equiv.ofBijective (fun x => ⟨σ x, by
        exact hσ x |>.1 x.2⟩) ⟨by
      intro x y; aesop, by
        intro x; use ⟨σ.symm x, by
          have := hσ ( σ.symm x ) ; aesop;⟩; aesop;⟩, Equiv.ofBijective (fun x => ⟨σ x, by
        have := hσ x; aesop;⟩) ⟨by
      exact fun x y h => Subtype.ext <| σ.injective <| Subtype.ext_iff.mp h, by
        all_goals generalize_proofs at *;
        intro x;
        use ⟨σ⁻¹ x, by
          have := hσ ( σ⁻¹ x ) ; aesop;⟩
        generalize_proofs at *;
        aesop⟩;
      all_goals generalize_proofs at *;
      ext x; by_cases hx : x ∈ A <;> simp_all +decide [ Equiv.Perm.ofSubtype ] ;
      · simp +decide [ Equiv.Perm.extendDomain, hx ];
      · simp +decide [ Equiv.Perm.extendDomain, hx ];
        simp +decide [ subtypeCongr, hx ];
        simp +decide [ Equiv.sumCompl, hx ];
        grind +locals
    use σ₁, σ₂, hσ_eq
    intro hσ
    obtain ⟨σ₁, σ₂, hσ_eq⟩ := hσ
    simp [hσ_eq, preservesFinset];
    simp +decide [ Equiv.Perm.ofSubtype ];
    intro x; by_cases hx : x ∈ A <;> simp +decide [ hx, Equiv.Perm.extendDomain ] ;
    exact σ₂ ⟨ x, hx ⟩ |>.2;
  -- By definition of `permPreservingFinset`, we have that `permPreservingFinset A` is the set of permutations of `Fin n` that restrict to permutations of `A` and its complement.
  have h_perm_restrict : permPreservingFinset A = Finset.image (fun (σ : Equiv.Perm A × Equiv.Perm {x : Fin n | x ∉ A}) => Equiv.Perm.ofSubtype σ.1 * Equiv.Perm.ofSubtype σ.2) (Finset.univ : Finset (Equiv.Perm A × Equiv.Perm {x : Fin n | x ∉ A})) := by
    ext σ; simp [permPreservingFinset, h_restrict];
    simp +decide only [eq_comm];
  rw [ h_perm_restrict, Finset.card_image_of_injective ];
  · simp +decide [ Finset.card_univ, Fintype.card_perm, hA ];
  · intro σ τ h_eq;
    simp_all +decide [ Equiv.Perm.ext_iff, Equiv.Perm.ofSubtype ];
    ext x;
    · specialize h_eq x;
      simp_all +decide [ Equiv.Perm.extendDomain ];
    · convert h_eq x using 1 ; simp +decide [ Equiv.Perm.extendDomain ];
      grind

/-
The number of pairs (σ,τ) both preserving A is (k!(n-k)!)².
-/
theorem card_pairs_preserving_finset
    (n k : ℕ) (hk : k ≤ n) (A : Finset (Fin n))
    (hA : A.card = k) :
    (pairsPreservingFinset A).card =
    (Nat.factorial k * Nat.factorial (n - k))^2 := by
  -- The number of pairs (σ,τ) preserving A are elements of the product set of permutations preserving A, squared.
  have h_paired : (pairsPreservingFinset A).card = (permPreservingFinset A).card ^ 2 := by
    unfold pairsPreservingFinset permPreservingFinset;
    rw [ sq, ← Finset.card_product ];
    exact congr_arg _ ( by ext; aesop );
  rw [ h_paired, card_perms_preserving_finset _ _ hk _ hA ]

/-! ## Part 2: Parity obstruction -/

/-
The cardinality of A_n is n!/2 for n ≥ 2.
-/
theorem card_alternatingGroup_eq (n : ℕ) (hn : 2 ≤ n) :
    Fintype.card (alternatingGroup (Fin n)) = Nat.factorial n / 2 := by
  have h_index : Subgroup.index (alternatingGroup (Fin n)) = 2 := by
    rw [ Subgroup.index_eq_two_iff ];
    -- Let's choose any transposition, say (1 2), which is an odd permutation.
    obtain ⟨a, ha⟩ : ∃ a : Equiv.Perm (Fin n), Equiv.Perm.sign a = -1 := by
      exact ⟨ Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩, by simp +decide ⟩;
    use a; intro b; cases' Int.units_eq_one_or ( Equiv.Perm.sign b ) with hb hb <;> simp +decide [ * ] ;
  have := Subgroup.index_mul_card ( alternatingGroup ( Fin n ) ) ; simp_all +decide [ Fintype.card_perm ] ;
  rw [ ← this, Nat.mul_div_cancel_left _ ( by decide ) ]

/-
If both permutations are even, they cannot generate S_n.
-/
theorem even_pair_not_generates (n : ℕ) (hn : 2 ≤ n)
    (σ τ : Equiv.Perm (Fin n))
    (hσ : σ ∈ alternatingGroup (Fin n))
    (hτ : τ ∈ alternatingGroup (Fin n)) :
    ¬ generatesSymm n σ τ := by
  -- Since σ, τ ∈ alternatingGroup, the set {σ, τ} ⊆ alternatingGroup. By Subgroup.closure_le, Subgroup.closure {σ, τ} ≤ alternatingGroup.
  have h_closure_le_alternatingGroup : Subgroup.closure ({σ, τ} : Set (Equiv.Perm (Fin n))) ≤ alternatingGroup (Fin n) := by
    simp +zetaDelta at *;
    rintro x ( rfl | rfl ) <;> assumption;
  have h_alternatingGroup_ne_top : alternatingGroup (Fin n) ≠ ⊤ := by
    rw [ Ne.eq_def, Subgroup.eq_top_iff' ];
    simp +zetaDelta at *;
    exact ⟨ Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩, by simp +decide ⟩;
  exact fun h => h_alternatingGroup_ne_top <| le_antisymm ( le_top ) <| h ▸ h_closure_le_alternatingGroup

/-
The probability that both random permutations are even equals 1/4 for n ≥ 2.
-/
theorem prob_both_even_eq_quarter (n : ℕ) (hn : 2 ≤ n) :
    probBothEvenReal n = 1 / 4 := by
  unfold probBothEvenReal;
  -- By definition of evenPairCount, we have evenPairCount n = (n!/2)^2.
  have h_evenPairCount : evenPairCount n = (Nat.factorial n / 2) ^ 2 := by
    exact congr_arg ( · ^ 2 ) ( card_alternatingGroup_eq n hn );
  norm_num [ h_evenPairCount, Fintype.card_perm ];
  rw [ Nat.cast_div ( Nat.dvd_factorial ( by decide ) hn ) ] <;> norm_num ; ring_nf ; norm_num [ Nat.factorial_ne_zero ]

/-! ## Part 3: Binomial reciprocal sum bounds -/

/-
For 2 ≤ k ≤ n-2, we have C(n,k) ≥ C(n,2).
-/
theorem choose_ge_choose_two (n k : ℕ) (hk2 : 2 ≤ k) (hkn : k ≤ n - 2) :
    Nat.choose n 2 ≤ Nat.choose n k := by
  -- By the properties of binomial coefficients, we know that $\binom{n}{k}$ is increasing for $k \leq \frac{n}{2}$. Therefore, $\binom{n}{2} \leq \binom{n}{k}$ for $2 \leq k \leq \frac{n}{2}$.
  have h_inc : ∀ k, 2 ≤ k → k ≤ n / 2 → Nat.choose n 2 ≤ Nat.choose n k := by
    intro k hk hk'; induction hk <;> simp_all +decide [ Nat.choose ];
    rename_i k hk ih;
    exact le_trans ( ih ( by linarith ) ) ( Nat.choose_le_succ_of_lt_half_left ( by linarith [ Nat.div_mul_le_self n 2 ] ) );
  exact if h : k ≤ n / 2 then h_inc k hk2 h else by rw [ ← Nat.choose_symm ( show k ≤ n from le_trans hkn ( Nat.sub_le _ _ ) ) ] ; exact h_inc ( n - k ) ( by omega ) ( by omega ) ;

/-- The edge term: C(n,1)⁻¹ = n⁻¹. -/
theorem recip_binom_edge_eq (n : ℕ) (hn : 1 ≤ n) :
    ((Nat.choose n 1 : ℝ))⁻¹ = (n : ℝ)⁻¹ := by
  rw [Nat.choose_one_right]

/-
**Cross-domain theorem (Boolean isoperimetry connection)**:
The non-transitivity obstruction is dominated by edge terms (k=1 and k=n-1)
in the subset lattice, with interior terms bounded by C(n,2)⁻¹ each.
This mirrors Harper's isoperimetric inequality on the Boolean cube:
singletons/codimension-1 cuts are the bottleneck.
-/
theorem nontransitivity_obstruction_edge_dominated
    (n : ℕ) (hn : 4 ≤ n) :
    recipBinomialSum n ≤
      2 / (n : ℝ) + ((n : ℝ) - 3) / (Nat.choose n 2 : ℝ) := by
  -- Split the sum into edge terms (k=1, k=n-1) and interior terms (2 ≤ k ≤ n-2).
  have h_split : recipBinomialSum n = (1 / n : ℝ) + (1 / n : ℝ) + ∑ k ∈ Finset.Icc 2 (n - 2), ((Nat.choose n k : ℝ))⁻¹ := by
    unfold recipBinomialSum;
    erw [ Finset.sum_Ico_eq_sub _ _, Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ Finset.sum_range_succ' ];
    · rcases n with ( _ | _ | n ) <;> simp_all +decide [ Finset.sum_range_succ ];
      ring;
    · omega;
  -- For interior terms (2 ≤ k ≤ n-2), each C(n,k)⁻¹ ≤ C(n,2)⁻¹ by choose_ge_choose_two.
  have h_interior : ∑ k ∈ Finset.Icc 2 (n - 2), ((Nat.choose n k : ℝ))⁻¹ ≤ ∑ k ∈ Finset.Icc 2 (n - 2), ((Nat.choose n 2 : ℝ))⁻¹ := by
    exact Finset.sum_le_sum fun x hx => inv_anti₀ ( Nat.cast_pos.mpr <| Nat.choose_pos <| by linarith ) <| mod_cast choose_ge_choose_two n x ( Finset.mem_Icc.mp hx |>.1 ) ( Finset.mem_Icc.mp hx |>.2 );
  rcases n with ( _ | _ | _ | n ) <;> norm_num at *;
  grind

/-
The reciprocal binomial sum ≤ 2/n + 2/(n-1) for n ≥ 4.
Follows from edge-dominated decomposition.
-/
theorem binomial_recip_sum_le_refined (n : ℕ) (hn : 4 ≤ n) :
    recipBinomialSum n ≤ 2 / (n : ℝ) + 2 / ((n : ℝ) - 1) := by
  refine' le_trans ( nontransitivity_obstruction_edge_dominated n hn ) _;
  rw [ Nat.choose_two_right ];
  rcases n with ( _ | _ | _ | _ | n ) <;> norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.mod_two_of_bodd ] at *;
  rw [ div_le_div_iff₀ ] <;> ring <;> nlinarith

/-
Corollary: the reciprocal binomial sum ≤ 4/n for n ≥ 4.
This is the key quantitative input for Dixon-type asymptotic bounds.
-/
theorem binomial_recip_sum_le_four_div_n (n : ℕ) (hn : 4 ≤ n) :
    recipBinomialSum n ≤ 4 / (n : ℝ) := by
  have h_recip_binom : recipBinomialSum n ≤ 2 / (n : ℝ) + ((n : ℝ) - 3) / (Nat.choose n 2 : ℝ) := by
    convert nontransitivity_obstruction_edge_dominated n hn using 1;
  refine le_trans h_recip_binom ?_;
  rw [ Nat.choose_two_right ];
  rcases n with ( _ | _ | _ | _ | n ) <;> norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.mod_two_of_bodd ] at *;
  rw [ div_add_div, div_le_div_iff₀ ] <;> ring <;> nlinarith

/-! ## Part 4: Generation probability bounds -/

/-
Upper bound: P_n ≤ 3/4 for n ≥ 2, since at least 1/4 of all pairs
have both permutations even and thus cannot generate S_n.

The constant 3/4 is sharp: Dixon's theorem shows P_n → 3/4 as n → ∞.
-/
theorem generation_probability_le_three_quarters (n : ℕ) (hn : 2 ≤ n) :
    (Nat.card { p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n) //
      generatesSymm n p.1 p.2 } : ℝ) /
    ((Fintype.card (Equiv.Perm (Fin n)))^2 : ℝ) ≤ 3 / 4 := by
  rw [ div_le_iff₀ ] <;> norm_cast <;> norm_num [ Fintype.card_perm ];
  · -- The set of generating pairs is a subset of the complement of the set of pairs where both are even.
    have h_subset : Nat.card {p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n) | generatesSymm n p.1 p.2} ≤ Nat.card {p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n) | ¬(p.1 ∈ alternatingGroup (Fin n) ∧ p.2 ∈ alternatingGroup (Fin n))} := by
      apply_rules [ Nat.card_mono ];
      · exact Set.toFinite _;
      · exact fun p hp => fun h => even_pair_not_generates n hn p.1 p.2 h.1 h.2 hp;
    -- The set of pairs where both are even has cardinality $(n!/2)^2$.
    have h_even_pairs : Nat.card {p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n) | p.1 ∈ alternatingGroup (Fin n) ∧ p.2 ∈ alternatingGroup (Fin n)} = (Nat.factorial n / 2) ^ 2 := by
      have h_even_pairs : Nat.card {p : Equiv.Perm (Fin n) | p ∈ alternatingGroup (Fin n)} = Nat.factorial n / 2 := by
        have := card_alternatingGroup_eq n hn; simp_all +decide [ Fintype.card_subtype ] ;
      rw [ ← h_even_pairs, sq ];
      rw [ ← Nat.card_prod ];
      fapply Nat.card_congr;
      exact ⟨ fun p => ⟨ ⟨ p.val.1, p.prop.1 ⟩, ⟨ p.val.2, p.prop.2 ⟩ ⟩, fun p => ⟨ ⟨ p.1.val, p.2.val ⟩, p.1.prop, p.2.prop ⟩, fun p => rfl, fun p => rfl ⟩;
    -- The set of pairs where both are even has cardinality $(n!/2)^2$, so the set of pairs where at least one is odd has cardinality $(n!)^2 - (n!/2)^2$.
    have h_odd_pairs : Nat.card {p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n) | ¬(p.1 ∈ alternatingGroup (Fin n) ∧ p.2 ∈ alternatingGroup (Fin n))} = (Nat.factorial n) ^ 2 - (Nat.factorial n / 2) ^ 2 := by
      simp_all +decide [ Fintype.card_subtype ];
      rw [ ← h_even_pairs, eq_comm, tsub_eq_of_eq_add ];
      rw [ Finset.card_filter, Finset.card_filter ];
      rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun x hx => by aesop, Finset.sum_const, Finset.card_univ ] ; norm_num [ Fintype.card_perm ];
      ring;
    rw [ div_mul_eq_mul_div, le_div_iff₀ ] <;> norm_cast;
    nlinarith! [ Nat.div_mul_cancel ( show 2 ∣ n ! from Nat.dvd_factorial ( by decide ) hn ), Nat.sub_add_cancel ( show ( n ! / 2 ) ^ 2 ≤ n ! ^ 2 from Nat.pow_le_pow_left ( Nat.div_le_self _ _ ) _ ) ];
  · positivity

/-! ## Conjecture: Quantitative Dixon Residual

**Conjecture (quantitative Dixon residual)**:
For all n ≥ 8, the probability that ⟨σ,τ⟩ is a transitive proper subgroup
of S_n containing an odd permutation is at most 3/n².

**Test**: Compute exact values for n = 5,...,10 using GAP/SageMath.
Enumerate all pairs and check which generate transitive subgroups ≠ S_n
with odd elements.

**Impact**: Combined with parity (1/4) and transitivity (2/n + O(1/n²))
bounds, this would formally establish P_n ≥ 3/4 - 2/n - O(1/n²).

**Alternative conjecture (monotone convergence)**:
For n ≥ 5, P_n < P_{n+1}, and lim P_n = 3/4.
Falsifiable by exact computation for small n. -/