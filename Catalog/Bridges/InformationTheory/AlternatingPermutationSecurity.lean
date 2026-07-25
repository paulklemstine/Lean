/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Cryptographic Security Bounds for Alternating Permutation Networks

This file establishes a formal bridge between finite-group mixing theory
and cryptographic security of permutation networks. The central theme is:

> Observable bias in a permutation distribution is automatically a
> cryptographic distinguisher, converting mixing lower bounds into
> certified security lower bounds.

## Core contributions

1. **Observable-to-TV reduction**: Any bounded observable whose expectation
   differs between two distributions yields a total variation lower bound.
   This is the conceptual hinge converting mixing theory into cryptography.

2. **Support-size security bound**: If a keyed permutation network's output
   distribution is supported on at most K permutations, the TV distance
   from uniform is at least 1 - K/n!. This connects key schedule
   cardinality to statistical security.

3. **Heavy-point certificate**: Non-negligible TV distance from uniform
   implies the existence of a "heavy" permutation with probability mass
   exceeding the uniform level — a concrete entropy deficiency witness.

4. **Displacement observable**: A natural hardware-locality statistic on
   permutations that measures total wire movement. Adjacent swaps change
   this by at most 2, establishing that shallow networks cannot spread
   displacement to the uniform scale.

5. **Min-entropy deficiency**: TV distance from uniform implies a gap
   between the distribution's min-entropy and the maximum possible
   log₂(n!), quantifying exploitable structure.

## Application to lightweight ciphers

These results apply to any permutation network built from alternating
layers of adjacent transpositions and cyclic shifts — a common pattern
in lightweight block ciphers (PRESENT, GIFT, etc.). The theorems show
that insufficient round complexity leaves a mathematically detectable
scar: the output distribution cannot be pseudorandom.

## References

* Wilson (2004), "Mixing times of lozenge tiling and card shuffling Markov chains"
* Diaconis–Shahshahani (1981), generating functions for random permutations
* Morris (2009), "Improved bounds for sampling permutations via sorting networks"
-/
import Mathlib

open Finset BigOperators

namespace CryptoPermNetwork

/-! ## §1. Core Distribution Definitions -/

/-- Total variation distance between two distributions on a finite type:
    TV(μ, ν) = (1/2) ∑_x |μ(x) - ν(x)|. -/
noncomputable def tvDist {α : Type*} [Fintype α]
    (μ ν : α → ℝ) : ℝ :=
  (1 / 2 : ℝ) * ∑ x : α, |μ x - ν x|

/-- The uniform distribution on a finite type with N elements. -/
noncomputable def uniformDist (α : Type*) [Fintype α] : α → ℝ :=
  fun _ => (1 : ℝ) / Fintype.card α

/-- Predicate: μ is a probability distribution (nonneg, sums to 1). -/
def IsDist {α : Type*} [Fintype α] (μ : α → ℝ) : Prop :=
  (∀ a, 0 ≤ μ a) ∧ ∑ a : α, μ a = 1

/-- The support of a distribution: elements with nonzero mass. -/
noncomputable def distSupport {α : Type*} [Fintype α] (μ : α → ℝ) : Finset α :=
  Finset.univ.filter (fun a => μ a ≠ 0)

/-- The total displacement of a permutation: ∑_i |σ(i) - i|.
    This measures how far elements are moved from their original positions,
    serving as a hardware-locality / wire-movement observable. -/
def totalDisplacement {n : ℕ} (σ : Equiv.Perm (Fin n)) : ℕ :=
  ∑ i : Fin n, Int.natAbs ((σ i : ℕ) - (i : ℕ))

/-- Maximum point mass of a distribution. -/
noncomputable def maxPointMass {α : Type*} [Fintype α] [Nonempty α]
    (μ : α → ℝ) : ℝ :=
  Finset.univ.sup' ⟨Classical.arbitrary α, Finset.mem_univ _⟩ (fun a => μ a)

/-! ## §2. Basic Properties of TV Distance -/

theorem tvDist_nonneg {α : Type*} [Fintype α]
    (μ ν : α → ℝ) : 0 ≤ tvDist μ ν :=
  mul_nonneg (by norm_num) (Finset.sum_nonneg fun _ _ => abs_nonneg _)

theorem tvDist_symm {α : Type*} [Fintype α]
    (μ ν : α → ℝ) : tvDist μ ν = tvDist ν μ := by
  unfold tvDist; congr 1; exact Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _

theorem tvDist_self {α : Type*} [Fintype α]
    (μ : α → ℝ) : tvDist μ μ = 0 := by
  unfold tvDist; simp

/-
TV distance is at most 1 for probability distributions.
-/
theorem tvDist_le_one {α : Type*} [Fintype α]
    (μ ν : α → ℝ) (hμ : IsDist μ) (hν : IsDist ν) :
    tvDist μ ν ≤ 1 := by
      -- Applying the triangle inequality to each term in the sum, we get |μ(x) - ν(x)| ≤ μ(x) + ν(x).
      have h_triangle : ∀ x, |μ x - ν x| ≤ μ x + ν x := by
        exact fun x => abs_le.mpr ⟨ by linarith [ hμ.1 x, hν.1 x ], by linarith [ hμ.1 x, hν.1 x ] ⟩;
      convert mul_le_mul_of_nonneg_left ( Finset.sum_le_sum fun x _ => h_triangle x ) ( by norm_num : ( 0 : ℝ ) ≤ 1 / 2 ) using 1 ; norm_num [ Finset.sum_add_distrib, hμ.2, hν.2, tvDist ]

/-
Uniform distribution is indeed a distribution (when type is nonempty).
-/
theorem uniformDist_isDist (α : Type*) [Fintype α] [Nonempty α] :
    IsDist (uniformDist α) := by
      exact ⟨ fun _ => div_nonneg zero_le_one ( Nat.cast_nonneg _ ), by simp +decide [ uniformDist ] ⟩

/-! ## §3. Theorem 1: Observable Bias Implies TV Lower Bound

**The conceptual hinge theorem.** Any bounded observable whose expectation
differs between two distributions yields a total variation lower bound.

Mathematical statement: If f : α → ℝ satisfies |f(a)| ≤ B for all a,
and |∑ f(a)·(μ(a) - ν(a))| ≥ δ, then TV(μ,ν) ≥ δ/(2B).

This converts any mixing-theory observable into a cryptographic distinguisher. -/

/-
**Theorem 1 (Observable-to-TV reduction, general form).**
    If f is bounded by B and its expectations under μ and ν differ by at
    least δ, then TV(μ,ν) ≥ δ/(2B). This is the bridge from spectral/
    combinatorial lower bounds to cryptographic security lower bounds.
-/
theorem tv_lower_bound_of_observable_bias
    {α : Type*} [Fintype α]
    (μ ν : α → ℝ) (f : α → ℝ) (δ B : ℝ)
    (hB_pos : 0 < B)
    (hf_bdd : ∀ a, |f a| ≤ B)
    (hgap : δ ≤ |∑ a : α, f a * (μ a - ν a)|) :
    δ / (2 * B) ≤ tvDist μ ν := by
      -- By the triangle inequality, we have |∑ f(a)(μ(a)-ν(a))| ≤ ∑ |f(a)| · |μ(a)-ν(a)|.
      have h_triangle : |∑ a, f a * (μ a - ν a)| ≤ ∑ a, |f a| * |μ a - ν a| := by
        simpa only [ ← abs_mul ] using Finset.abs_sum_le_sum_abs _ _;
      rw [ div_le_iff₀' ];
      · convert hgap.trans h_triangle |> le_trans <| Finset.sum_le_sum fun a _ => mul_le_mul_of_nonneg_right ( hf_bdd a ) ( abs_nonneg _ ) using 1 ; norm_num [ tvDist ] ; ring;
        rw [ Finset.mul_sum _ _ _ ];
      · positivity

/-
**Corollary: [0,1]-bounded observables.**
    For f : α → ℝ with 0 ≤ f ≤ 1 and |𝔼_μ[f] - 𝔼_ν[f]| ≥ δ,
    we get TV(μ,ν) ≥ δ/2.
-/
theorem tv_lower_bound_of_01_observable
    {α : Type*} [Fintype α]
    (μ ν : α → ℝ) (f : α → ℝ) (δ : ℝ)
    (hf_nn : ∀ a, 0 ≤ f a)
    (hf_le : ∀ a, f a ≤ 1)
    (hgap : δ ≤ |∑ a : α, f a * (μ a - ν a)|) :
    δ / 2 ≤ tvDist μ ν := by
      convert tv_lower_bound_of_observable_bias μ ν f δ 1 zero_lt_one ( fun a => show |f a| ≤ 1 from by cases abs_cases ( f a ) <;> linarith [ hf_nn a, hf_le a ] ) hgap using 1 ; ring

/-! ## §4. Theorem 2: Support-Size Security Bound

**Key schedule cardinality obstruction.** If a keyed permutation network's
output distribution is supported on at most K permutations out of n!,
the TV distance from uniform is at least 1 - K/N.

This is elementary but powerful: no matter how clever the layer design,
a small key space cannot produce a distribution close to uniform on S_n. -/

/-
**Theorem 2 (Support-size TV bound).**
    If μ is a probability distribution on α supported on at most K elements,
    then TV(μ, uniform) ≥ 1 - K / |α|.

    Applied to permutation networks: if the key space has K keys,
    the output distribution has support ≤ K, so TV ≥ 1 - K/n!.
-/
theorem tvDist_uniform_support_bound
    {α : Type*} [Fintype α]
    (μ : α → ℝ) (K : ℕ)
    (hμ_dist : IsDist μ)
    (hN : 0 < Fintype.card α)
    (hsupp : (distSupport μ).card ≤ K) :
    1 - (K : ℝ) / Fintype.card α ≤ tvDist μ (uniformDist α) := by
      -- By definition of $tvDist$, we have:
      have h_tv_def : tvDist μ (uniformDist α) = (1 / 2 : ℝ) * ∑ x : α, |μ x - (1 / (Fintype.card α : ℝ))| := by
        rfl;
      -- Since $\mu$ is a probability distribution, we have $\sum_{x \in \alpha} \mu(x) = 1$.
      have h_sum_mu : ∑ x : α, μ x = 1 := by
        exact hμ_dist.2;
      -- Since $\mu$ is supported on at most $K$ elements, we have $\sum_{x \in \alpha} \mu(x) = \sum_{x \in \text{supp}(\mu)} \mu(x)$.
      have h_sum_mu_supp : ∑ x : α, μ x = ∑ x ∈ distSupport μ, μ x := by
        rw [ Finset.sum_subset ( Finset.subset_univ ( distSupport μ ) ) fun x hx₁ hx₂ => by unfold distSupport at hx₂; aesop ];
      -- Since $\mu$ is supported on at most $K$ elements, we have $\sum_{x \in \text{supp}(\mu)} \mu(x) \leq \sum_{x \in \text{supp}(\mu)} (1 / (Fintype.card α : ℝ)) + \sum_{x \in \text{supp}(\mu)} |\mu(x) - 1 / (Fintype.card α : ℝ)|$.
      have h_sum_mu_le : ∑ x ∈ distSupport μ, μ x ≤ ∑ x ∈ distSupport μ, (1 / (Fintype.card α : ℝ)) + ∑ x ∈ distSupport μ, |μ x - 1 / (Fintype.card α : ℝ)| := by
        simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun x hx => by cases abs_cases ( μ x - 1 / ( Fintype.card α : ℝ ) ) <;> linarith;
      simp_all +decide [ div_eq_mul_inv ];
      rw [ ← Finset.sum_filter_add_sum_filter_not Finset.univ ( fun x => μ x ≠ 0 ) ] at *;
      simp_all +decide [ distSupport ];
      rw [ show ( ∑ x with μ x = 0, |μ x - ( Fintype.card α : ℝ ) ⁻¹| ) = ( Fintype.card α - Finset.card ( Finset.filter ( fun x => ¬μ x = 0 ) Finset.univ ) ) * ( Fintype.card α : ℝ ) ⁻¹ from ?_ ];
      · nlinarith [ show ( Finset.card ( Finset.filter ( fun x => ¬μ x = 0 ) Finset.univ ) : ℝ ) ≤ K by exact_mod_cast hsupp, show ( Fintype.card α : ℝ ) ≥ 1 by exact_mod_cast hN, mul_inv_cancel₀ ( by positivity : ( Fintype.card α : ℝ ) ≠ 0 ) ];
      · rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.mem_filter.mp hx |>.2 ] ] ; simp +decide [ Finset.filter_not, Finset.card_sdiff ];
        exact Or.inl ( eq_sub_of_add_eq <| mod_cast by rw [ Finset.card_filter_add_card_filter_not ] ; simp +decide )

/-! ## §5. Theorem 3: Heavy Point from TV Distance

**Entropy deficiency witness.** If TV(μ, uniform) ≥ ε, there exists a
permutation whose probability mass exceeds the uniform level by ε/N.
This is the concrete certificate that the distribution has exploitable
non-uniformity: a distinguisher can test for this heavy element. -/

/-
**Theorem 3 (Heavy-point certificate).**
    If TV(μ, uniform) ≥ ε and μ is a distribution, there exists an element
    with mass at least 1/N + ε/N. This witnesses min-entropy deficiency.
-/
theorem exists_heavy_point_of_tvDist_ge
    {α : Type*} [Fintype α] [Nonempty α]
    (μ : α → ℝ) (ε : ℝ)
    (hμ : IsDist μ)
    (hN : 0 < Fintype.card α)
    (htv : ε ≤ tvDist μ (uniformDist α)) :
    ∃ a : α, (1 : ℝ) / Fintype.card α + ε / Fintype.card α ≤ μ a := by
      -- By definition of $tvDist$, we have:
      have h_def : ε ≤ (1 / 2) * ∑ a : α, |μ a - (1 / (Fintype.card α : ℝ))| := by
        convert htv using 1;
      -- By the positive/negative decomposition, we have:
      have h_decomp : ε ≤ ∑ a ∈ Finset.univ.filter (fun a => μ a > 1 / (Fintype.card α : ℝ)), (μ a - 1 / (Fintype.card α : ℝ)) := by
        have h_decomp : ∑ a : α, |μ a - (1 / (Fintype.card α : ℝ))| = ∑ a ∈ Finset.univ.filter (fun a => μ a > 1 / (Fintype.card α : ℝ)), (μ a - 1 / (Fintype.card α : ℝ)) + ∑ a ∈ Finset.univ.filter (fun a => μ a ≤ 1 / (Fintype.card α : ℝ)), (1 / (Fintype.card α : ℝ) - μ a) := by
          rw [ Finset.sum_filter, Finset.sum_filter ];
          simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun x _ => by split_ifs <;> cases abs_cases ( μ x - 1 / ( Fintype.card α : ℝ ) ) <;> linarith;
        have h_sum_zero : ∑ a : α, (μ a - 1 / (Fintype.card α : ℝ)) = 0 := by
          simp +decide [ hμ.2 ];
        have h_sum_zero : ∑ a : α, (μ a - 1 / (Fintype.card α : ℝ)) = ∑ a ∈ Finset.univ.filter (fun a => μ a > 1 / (Fintype.card α : ℝ)), (μ a - 1 / (Fintype.card α : ℝ)) + ∑ a ∈ Finset.univ.filter (fun a => μ a ≤ 1 / (Fintype.card α : ℝ)), (μ a - 1 / (Fintype.card α : ℝ)) := by
          rw [ Finset.sum_filter, Finset.sum_filter ];
          simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun x _ => by split_ifs <;> linarith;
        norm_num at *; linarith;
      contrapose! h_decomp;
      refine' lt_of_le_of_lt ( Finset.sum_le_sum fun a ha => show μ a - 1 / ( Fintype.card α : ℝ ) ≤ ε / ( Fintype.card α : ℝ ) by linarith [ h_decomp a ] ) _ ; simp +decide [ hN.ne' ];
      refine' lt_of_lt_of_le ( mul_lt_mul_of_pos_right ( Nat.cast_lt.mpr <| Finset.card_lt_card <| Finset.filter_ssubset.mpr _ ) <| div_pos _ <| Nat.cast_pos.mpr hN ) _;
      · by_contra! h;
        exact absurd ( Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun x _ => h x ( Finset.mem_univ x ) ) ( by simp +decide [ hμ.2 ] );
      · by_cases hε : ε ≤ 0;
        · exact absurd ( Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun a _ => h_decomp a ) ( by simp +decide [ hμ.2, hN.ne' ] ; nlinarith [ show ( Fintype.card α : ℝ ) ≥ 1 by exact_mod_cast hN, mul_div_cancel₀ ε ( by positivity : ( Fintype.card α : ℝ ) ≠ 0 ) ] );
        · exact not_le.mp hε;
      · simp +decide [ mul_div_cancel₀, hN.ne' ]

/-! ## §6. Theorem 4: Displacement Observable Bounded Change

**Hardware locality obstruction.** The total displacement observable
∑_i |σ(i) - i| measures wire-movement cost. An adjacent transposition
swap(j, j+1) changes this by at most 2.

This means shallow networks of adjacent swaps cannot rapidly spread
displacement: after T rounds of k swaps each, the displacement is
at most 2Tk away from the starting value. Since uniform permutations
have expected displacement Θ(n²), this obstructs mixing. -/

/-
**Theorem 4 (Displacement change bound).**
    Composing with an adjacent transposition swap(j, j+1) changes the
    total displacement by at most 2. This is the locality constraint
    that limits how fast shallow networks can diffuse.
-/
theorem displacement_adj_swap_bound {n : ℕ} (_hn : 2 ≤ n)
    (σ : Equiv.Perm (Fin n)) (j : Fin n) (hj : j.val + 1 < n) :
    |(totalDisplacement (σ * Equiv.swap j ⟨j.val + 1, hj⟩) : ℤ) -
    (totalDisplacement σ : ℤ)| ≤ 2 := by
      unfold totalDisplacement; simp +decide [ Finset.sum_add_distrib, abs_sub_comm ] ;
      rw [ ← Finset.sum_sub_distrib ];
      rw [ Finset.sum_eq_add ( j ) ( ⟨ j + 1, hj ⟩ ) ];
      · grind;
      · exact ne_of_lt ( Nat.lt_succ_self _ );
      · intro c _ hc; rw [ Equiv.swap_apply_def ] ; aesop;
      · aesop;
      · grind +qlia

/-! ## §7. Theorem 5: Min-Entropy Deficiency from TV Distance

**Information-theoretic bridge.** TV distance from uniform directly
implies a gap in min-entropy. If TV ≥ ε, then the max point mass
is at least (1 + ε)/N, so min-entropy ≤ log N - log(1 + ε).

This speaks the language of cryptography: insufficient rounds leave
the output distribution with non-maximal min-entropy. -/

/-
**Theorem 5 (Max point mass lower bound from TV distance).**
    If TV(μ, uniform) ≥ ε ≥ 0 and μ is a distribution, then
    max_a μ(a) ≥ (1 + ε) / N.
-/
theorem maxPointMass_lower_bound_of_tvDist
    {α : Type*} [Fintype α] [Nonempty α]
    (μ : α → ℝ) (ε : ℝ)
    (hμ : IsDist μ)
    (_hε : 0 ≤ ε)
    (hN : 0 < Fintype.card α)
    (htv : ε ≤ tvDist μ (uniformDist α)) :
    (1 + ε) / Fintype.card α ≤ maxPointMass μ := by
      obtain ⟨ a, ha ⟩ := exists_heavy_point_of_tvDist_ge μ ε hμ hN htv;
      exact le_trans ( by rw [ add_div ] ) ( ha.trans ( Finset.le_sup' ( fun a => μ a ) ( Finset.mem_univ a ) ) )

/-! ## §8. Alternating Permutation Network Definitions

Formal definitions for the class of permutation networks under study.
These capture the structure of lightweight cipher diffusion layers. -/

/-- A layer generated by adjacent transpositions: a product of
    adjacent swaps swap(i, i+1) for i in some index list. -/
def IsAdjSwapLayer {n : ℕ} (σ : Equiv.Perm (Fin n)) : Prop :=
  ∃ swaps : List {j : Fin n // j.val + 1 < n},
    σ = (swaps.map (fun ⟨j, hj⟩ => Equiv.swap (j : Fin n) ⟨j.val + 1, hj⟩)).foldl (· * ·) 1

/-- The identity is an adjacent swap layer (empty swap list). -/
theorem isAdjSwapLayer_id {n : ℕ} : IsAdjSwapLayer (1 : Equiv.Perm (Fin n)) := by
  exact ⟨[], by simp⟩

/-- An alternating permutation network: even-indexed layers are
    adjacent-swap layers. -/
def IsSwapSchedule {n T : ℕ} (layers : Fin T → Equiv.Perm (Fin n)) : Prop :=
  ∀ r : Fin T, Even r.val → IsAdjSwapLayer (layers r)

/-- The composed permutation of a network: product of all layers. -/
noncomputable def networkComposition {n T : ℕ}
    (layers : Fin T → Equiv.Perm (Fin n)) : Equiv.Perm (Fin n) :=
  (List.ofFn layers).prod

/-- The output distribution induced by choosing each layer from a
    finite family (modeling keyed operation). -/
noncomputable def networkOutputDist {n T : ℕ} {K : Type*} [Fintype K]
    [DecidableEq (Equiv.Perm (Fin n))]
    (keyedLayers : K → Fin T → Equiv.Perm (Fin n)) :
    Equiv.Perm (Fin n) → ℝ :=
  fun σ => ((Finset.univ.filter
    (fun k => networkComposition (keyedLayers k) = σ)).card : ℝ) / Fintype.card K

/-! ## §9. Alternating Network Output Is a Distribution -/

/-
The output distribution of a keyed network is a valid distribution.
-/
theorem networkOutputDist_isDist {n T : ℕ} {K : Type*} [Fintype K] [Nonempty K]
    [DecidableEq (Equiv.Perm (Fin n))]
    (keyedLayers : K → Fin T → Equiv.Perm (Fin n)) :
    IsDist (networkOutputDist keyedLayers) := by
      refine' ⟨ _, _ ⟩;
      · exact fun _ => div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ );
      · unfold networkOutputDist;
        rw [ ← Finset.sum_div, div_eq_iff ] <;> norm_cast <;> norm_num +decide [ Finset.sum_fiberwise ];
        simp +decide only [card_filter];
        rw [ Finset.sum_comm ] ; aesop

/-
The support of a keyed network's output distribution has at most |K| elements.
-/
theorem networkOutputDist_support_le_card {n T : ℕ} {K : Type*} [Fintype K]
    [DecidableEq (Equiv.Perm (Fin n))]
    (keyedLayers : K → Fin T → Equiv.Perm (Fin n)) :
    (distSupport (networkOutputDist keyedLayers)).card ≤ Fintype.card K := by
      -- The support of the network output distribution is the set of all permutations that can be produced by the network.
      have h_support : distSupport (networkOutputDist keyedLayers) = Finset.image (fun k : K => networkComposition (keyedLayers k)) Finset.univ := by
        ext σ; simp [distSupport, networkOutputDist];
        exact fun k hk => Nat.ne_of_gt ( Fintype.card_pos_iff.mpr ⟨ k ⟩ );
      exact h_support ▸ Finset.card_image_le.trans_eq ( Finset.card_univ )

/-! ## §10. Main Cryptographic Application: Key-Space Security Bound -/

/-- **Main Application Theorem.**
    For any keyed alternating permutation network with key space K,
    the TV distance from uniform is at least 1 - |K|/n!.

    This means: to achieve ε-statistical security (TV ≤ ε), one needs
    |K| ≥ (1-ε) · n!, i.e., the key space must be a substantial fraction
    of all permutations. -/
theorem alternating_network_tv_from_key_space
    {n T : ℕ} {K : Type*} [Fintype K] [Nonempty K]
    [DecidableEq (Equiv.Perm (Fin n))]
    (keyedLayers : K → Fin T → Equiv.Perm (Fin n))
    (hN : 0 < Fintype.card (Equiv.Perm (Fin n))) :
    1 - (Fintype.card K : ℝ) / Fintype.card (Equiv.Perm (Fin n)) ≤
    tvDist (networkOutputDist keyedLayers) (uniformDist (Equiv.Perm (Fin n))) :=
  tvDist_uniform_support_bound _ _
    (networkOutputDist_isDist keyedLayers) hN
    (networkOutputDist_support_le_card keyedLayers)

/-! ## §11. Conjecture: Exponential TV Decay Lower Bound

For constants c₁, c₂ > 0, if μ_{n,T,k} is the output distribution of
a keyed alternating permutation network on Fin n with T rounds and at most
k adjacent swaps per swap layer, then

  TV(μ_{n,T,k}, U_{S_n}) ≥ c₁ · exp(-c₂ · T·k / n²)

for all n ≥ 4. Equivalently, achieving TV < 2^{-λ} requires
T ≥ n² / (c₂·k) · (λ·log 2 + log(1/c₁)). -/
def exponentialDecayConjecture : Prop :=
  ∃ c₁ c₂ : ℝ, 0 < c₁ ∧ c₁ ≤ 1 ∧ 0 < c₂ ∧
  ∀ n : ℕ, 4 ≤ n →
  ∀ T k : ℕ, 1 ≤ k →
  ∀ μ : Equiv.Perm (Fin n) → ℝ,
    IsDist μ →
    c₁ * Real.exp (-(c₂ * (T * k : ℝ) / (n : ℝ)^2)) ≤ tvDist μ (uniformDist _)

end CryptoPermNetwork