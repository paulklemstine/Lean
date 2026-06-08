/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certificate-to-Growth Mechanism for Finite Groups

This file develops the theory connecting algebraic generation certificates
to product-set growth in finite groups. The central result is that
certificate conditions — generation by a symmetric set — force strict
growth of product sets at every step before saturation.

## Key Insight

A generating set in a finite group acts as a **dynamic expansion witness**:
if any product power `A ^ k` has not yet filled the entire group, then the next
product power `A ^ (k + 1)` must be strictly larger. Certificate data, usually
viewed as a static algebraic witness, becomes a **dynamic expansion witness**.

## Main Definitions

* `ProductGrowthCertificate` — structure encoding a symmetric generating set
  with all data needed for growth analysis.
* `pairSymmSet` — the symmetric generator set `{1, g, g⁻¹, h, h⁻¹}` from a pair.

## Main Results

* `right_mul_stable_eq_univ` — a nonempty set stable under right multiplication
  by generators must be the entire group.
* `pow_absorbing_eq_univ` — if `A ^ k * A ⊆ A ^ k` and `A` generates `G`,
  then `A ^ k = Finset.univ`.
* `strict_growth_of_generating` — strict growth `|A ^ (k+1)| > |A ^ k|`
  whenever `A ^ k ≠ G` and `1 ∈ A`.
* `certified_pair_growth` — specialization to certified generator pairs.
* `cayley_ball_strict_growth` — strict growth of Cayley graph balls,
  bridging to geometric group theory and spectral expansion.

## References

* Helfgott, H. (2008). Growth and generation in SL_2(Z/pZ).
* Breuillard, Green, Tao (2012). The structure of approximate groups.
* Tao, T. (2015). Expansion in finite simple groups of Lie type.
-/

import Mathlib

open Finset Subgroup Pointwise

/-! ## Definitions -/

/-- A **product growth certificate** packages a symmetric generating set with all
the algebraic data needed to derive product-set growth bounds. This structure
encodes the insight that certificate conditions are not merely generation
certificates — they are the algebraic shadow of non-approximate-subgroup
behavior. Any set satisfying these conditions must exhibit strict growth
at every step before saturating to the full group. -/
structure ProductGrowthCertificate (G : Type*) [Group G] [Fintype G] where
  /-- The symmetric generating set -/
  carrier : Finset G
  /-- The carrier is nonempty -/
  carrier_nonempty : carrier.Nonempty
  /-- The identity belongs to the carrier (ensures monotonicity of powers) -/
  one_mem : (1 : G) ∈ carrier
  /-- The carrier is closed under inversion -/
  symm_closed : ∀ ⦃x⦄, x ∈ carrier → x⁻¹ ∈ carrier
  /-- The carrier generates the entire group -/
  generates : Subgroup.closure (↑carrier : Set G) = ⊤

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The symmetric generator set from a pair of group elements:
`{1, g, g⁻¹, h, h⁻¹}`. Includes `1` to ensure monotonicity of product
powers, making the k-th power equal to the Cayley ball of radius k. -/
def pairSymmSet (g h : G) : Finset G :=
  {1, g, g⁻¹, h, h⁻¹}

/-! ## Core Stability Theorem -/

/-
**Core Stability Theorem.** A nonempty finite set `S` that is closed under
right multiplication by every element of a generating set `A` must be the
entire group.

This is the algebraic engine behind all product-growth results. It converts
a generation certificate into a saturation guarantee.

*Proof strategy:* We show `∀ g : G, ∀ s ∈ S, s * g ∈ S` by applying
`Subgroup.closure_induction` on `g ∈ ⟨A⟩ = G` with the property
`P(g) = ∀ s ∈ S, s * g ∈ S`. The inverse case uses that a finite injective
self-map is a bijection: the map `(· * x)` restricted to `S` is injective
(by right cancellation) and maps `S` into `S`, so it is surjective on `S`.
Once we know `S` is right-stable under all of `G`, picking any `s₀ ∈ S`
gives `g = s₀ * (s₀⁻¹ * g) ∈ S` for every `g`.
-/
theorem right_mul_stable_eq_univ
    (S : Finset G) (A : Finset G)
    (hne : S.Nonempty)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (hstable : ∀ s ∈ S, ∀ a ∈ A, s * a ∈ S) :
    S = Finset.univ := by
  -- Apply Subgroup.closure_induction' or closure_induction on g ∈ closure A for the property P(g) := ∀ s ∈ S, s * g ∈ S:
  have h_ind : ∀ g ∈ Subgroup.closure (A : Set G), ∀ s ∈ S, s * g ∈ S := by
    refine fun g hg ↦ Subgroup.closure_induction ( fun x hx ↦ ?_ ) ?_ ?_ ?_ hg;
    · grind +qlia;
    · aesop;
    · exact fun x y hx hy hx' hy' s hs => by simpa only [ mul_assoc ] using hy' _ ( hx' _ hs ) ;
    · intro x hx h hs
      have h_image : Finset.image (fun t => t * x) S = S := by
        exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr h ) ( by rw [ Finset.card_image_of_injective _ fun a b h => mul_right_cancel h ] );
      intro hs_mem; replace h_image := Finset.ext_iff.mp h_image hs; aesop;
  ext g; specialize h_ind ( hne.choose⁻¹ * g ) ( hgen.symm ▸ Subgroup.mem_top _ ) hne.choose hne.choose_spec; aesop;

/-! ## Absorption Implies Saturation -/

/-
**Absorption implies saturation.** If `A ^ k * A ⊆ A ^ k` (the k-th
product power absorbs right-multiplication by `A`) and `A` generates `G`,
then `A ^ k` must be the entire group.

This follows directly from `right_mul_stable_eq_univ` since the absorption
condition `A ^ k * A ⊆ A ^ k` is equivalent to saying that `A ^ k` is
right-stable under multiplication by elements of `A`.
-/
theorem pow_absorbing_eq_univ
    (A : Finset G)
    (hne : A.Nonempty)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    {k : ℕ} (hk : 1 ≤ k)
    (habsorb : A ^ k * A ⊆ A ^ k) :
    A ^ k = Finset.univ := by
  convert right_mul_stable_eq_univ ( A ^ k ) A ?_ hgen ?_;
  · exact Finset.nonempty_of_ne_empty ( by aesop );
  · exact fun s hs a ha => habsorb ( Finset.mul_mem_mul hs ha )

/-! ## Monotonicity and Strict Growth -/

/-
When `1 ∈ A`, the product powers are monotonically non-decreasing:
`A ^ k ⊆ A ^ (k + 1)`. This follows from
`A ^ (k + 1) = A ^ k * A ⊇ A ^ k * {1} = A ^ k`.
-/
theorem pow_subset_pow_succ
    (A : Finset G) (h1 : (1 : G) ∈ A) (k : ℕ) :
    A ^ k ⊆ A ^ (k + 1) := by
  exact fun x hx => by rw [ pow_succ ] ; exact Finset.mem_mul.mpr ⟨ x, by aesop ⟩ ;

/-
**Strict Growth Before Saturation (Theorem 2).** For a generating set
`A` with `1 ∈ A` in a finite group `G`, if `A ^ k ≠ G`, then
`|A ^ (k + 1)| > |A ^ k|`.

This is the deterministic growth law: a generating set cannot stall before
filling the group.

*Proof:* By contraposition. If `|A ^ (k+1)| ≤ |A ^ k|`, then since
`A ^ k ⊆ A ^ (k+1)` (monotonicity from `1 ∈ A`) and both are finite,
`A ^ k = A ^ (k+1) = A ^ k * A`. By `pow_absorbing_eq_univ`,
`A ^ k = Finset.univ`, contradicting `hproper`.
-/
theorem strict_growth_of_generating
    (A : Finset G)
    (hne : A.Nonempty)
    (h1 : (1 : G) ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    {k : ℕ} (hk : 1 ≤ k)
    (hproper : A ^ k ≠ Finset.univ) :
    (A ^ k).card < (A ^ (k + 1)).card := by
  contrapose! hproper;
  convert pow_absorbing_eq_univ A hne hgen hk _;
  have h_eq : A ^ k * A = A ^ (k + 1) := by
    rw [ pow_succ ];
  exact h_eq.symm ▸ Finset.eq_of_subset_of_card_le ( pow_subset_pow_succ A h1 k ) ( by linarith ) ▸ Finset.Subset.refl _

/-! ## Certified Pair Growth -/

omit [Fintype G] in
theorem pairSymmSet_one_mem (g h : G) : (1 : G) ∈ pairSymmSet g h := by
  simp [pairSymmSet]

theorem pairSymmSet_nonempty (g h : G) : (pairSymmSet g h).Nonempty :=
  ⟨1, pairSymmSet_one_mem g h⟩

theorem pairSymmSet_symm_closed (g h : G) :
    ∀ ⦃x⦄, x ∈ pairSymmSet g h → x⁻¹ ∈ pairSymmSet g h := by
  simp +decide [ pairSymmSet ]

omit [Fintype G] in
theorem pairSymmSet_closure (g h : G)
    (hgen : Subgroup.closure ({g, h} : Set G) = ⊤) :
    Subgroup.closure (↑(pairSymmSet g h) : Set G) = ⊤ := by
  simp_all +decide [ pairSymmSet ];
  simp_all +decide [ Subgroup.closure, Set.insert_subset_iff ]

/-- Construct a `ProductGrowthCertificate` from a certified generating pair. -/
def ProductGrowthCertificate.ofPair (g h : G)
    (hgen : Subgroup.closure ({g, h} : Set G) = ⊤) :
    ProductGrowthCertificate G where
  carrier := pairSymmSet g h
  carrier_nonempty := pairSymmSet_nonempty g h
  one_mem := pairSymmSet_one_mem g h
  symm_closed := pairSymmSet_symm_closed g h
  generates := pairSymmSet_closure g h hgen

/-
**Certified Pair Growth (Theorem 3).** If `g, h` generate `G` and
`(pairSymmSet g h) ^ k ≠ G`, then the next product power is strictly larger.

This theorem turns a static generation certificate into a dynamic growth
witness: certified pairs cannot exhibit approximate-subgroup behavior at
any scale.
-/
theorem certified_pair_growth
    (g h : G)
    (hgen : Subgroup.closure ({g, h} : Set G) = ⊤)
    {k : ℕ} (hk : 1 ≤ k)
    (hproper : (pairSymmSet g h) ^ k ≠ Finset.univ) :
    ((pairSymmSet g h) ^ k).card < ((pairSymmSet g h) ^ (k + 1)).card := by
  -- Apply the strict_growth_of_generating theorem with the given hypotheses.
  apply strict_growth_of_generating (pairSymmSet g h) (pairSymmSet_nonempty g h) (pairSymmSet_one_mem g h) (pairSymmSet_closure g h hgen) hk hproper

/-! ## Cross-Domain Bridge: Cayley Ball Growth -/

/-- The k-th Cayley ball: elements reachable from 1 by at most `k` generator
steps in the Cayley graph. Defined recursively:
`B₀ = {1}`, `B_{k+1} = B_k ∪ (B_k * A)`. -/
def cayleyBall (A : Finset G) : ℕ → Finset G
  | 0 => {1}
  | n + 1 => cayleyBall A n ∪ (cayleyBall A n * A)

omit [Fintype G] in
theorem cayleyBall_mono (A : Finset G) (k : ℕ) :
    cayleyBall A k ⊆ cayleyBall A (k + 1) := by
  exact Finset.subset_union_left

omit [Fintype G] in
theorem cayleyBall_nonempty (A : Finset G) (k : ℕ) :
    (cayleyBall A k).Nonempty := by
  induction' k with k ih;
  · exact ⟨ 1, Finset.mem_singleton_self _ ⟩;
  · exact ⟨ _, Finset.mem_union_left _ ih.choose_spec ⟩

/-
**Cayley Ball Strict Growth (Theorem 4, Cross-Domain Bridge).**
If the Cayley ball of radius `k` has not yet filled the group, then the
ball of radius `k + 1` is strictly larger.

This recasts certificate growth as **geometric expansion** in the Cayley
graph: the product-growth theorems become statements about metric ball
growth in a group-theoretic metric space. This bridges to:
- additive combinatorics (sum-product phenomena),
- geometric group theory (Gromov's polynomial growth theorem),
- spectral graph theory (Cayley graph expanders),
- random walk mixing (Bourgain–Gamburd theory).
-/
theorem cayley_ball_strict_growth
    (A : Finset G)
    (_hne : A.Nonempty)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    {k : ℕ}
    (hproper : cayleyBall A k ≠ Finset.univ) :
    (cayleyBall A k).card < (cayleyBall A (k + 1)).card := by
  refine' Finset.card_lt_card _;
  refine' ⟨ cayleyBall_mono A k, _ ⟩; simp_all +decide [ Finset.subset_iff ] ;
  contrapose! hproper; simp_all +decide [ cayleyBall ] ;
  refine' right_mul_stable_eq_univ _ _ _ _ _;
  exact A;
  · exact cayleyBall_nonempty A k;
  · exact hgen;
  · exact fun s hs a ha => hproper _ ( Or.inr ( Finset.mul_mem_mul hs ha ) )

/-
**Diameter bound.** The Cayley graph of `(G, A)` has diameter at most
`|G| - 1`: every element is reachable from the identity in at most
`|G| - 1` steps. This follows from strict growth at each step.
-/
theorem cayley_diameter_bound
    (A : Finset G)
    (hne : A.Nonempty)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤) :
    cayleyBall A (Fintype.card G - 1) = Finset.univ := by
  by_contra hgen;
  -- By induction using cayley_ball_strict_growth at each step up to Fintype.card G - 1, we get (cayleyBall A n).card ≥ n + 1 for n ≤ Fintype.card G - 1.
  have h_ind : ∀ n ≤ Fintype.card G - 1, (cayleyBall A n).card ≥ n + 1 := by
    intro n hn
    induction' n with n ih;
    · exact Finset.card_pos.mpr ⟨ 1, by simp +decide [ cayleyBall ] ⟩;
    · refine' Nat.succ_le_of_lt ( lt_of_le_of_lt ( ih ( Nat.le_of_succ_le hn ) ) ( cayley_ball_strict_growth A hne ‹_› _ ) );
      contrapose! hgen;
      refine' Nat.le_induction _ _ _ ( show n + 1 ≤ Fintype.card G - 1 from hn ) <;> simp_all +decide [ cayleyBall ];
  exact hgen ( Finset.eq_univ_of_forall fun x => by have := Finset.eq_of_subset_of_card_le ( Finset.subset_univ ( cayleyBall A ( Fintype.card G - 1 ) ) ) ( by simpa using h_ind ( Fintype.card G - 1 ) le_rfl |> fun h => by linarith [ Nat.sub_add_cancel ( show 1 ≤ Fintype.card G from Fintype.card_pos ) ] ) ; aesop )

/-! ## Growth Certificate Theorem -/

/-- **Main Certificate-to-Growth Theorem.** Every `ProductGrowthCertificate`
produces strict growth at every step before saturation. This is the formal
statement that certificate conditions are growth witnesses. -/
theorem ProductGrowthCertificate.strict_growth
    (cert : ProductGrowthCertificate G)
    {k : ℕ} (hk : 1 ≤ k)
    (hproper : cert.carrier ^ k ≠ Finset.univ) :
    (cert.carrier ^ k).card < (cert.carrier ^ (k + 1)).card :=
  strict_growth_of_generating cert.carrier cert.carrier_nonempty
    cert.one_mem cert.generates hk hproper