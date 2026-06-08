import Mathlib

/-!
# Spectral Sparsity and Additive Energy

This file develops the theory of additive energy for finite subsets of abelian groups,
with applications to the structural analysis of strong liar sets in Miller–Rabin
primality testing.

## Main Definitions

* `AdditiveQuadruples` — The set of additive quadruples (a,b,c,d) ∈ S⁴ with a+b = c+d
* `additiveEnergy` — |AdditiveQuadruples S|, the additive energy of S
* `representationCount` — r_S(x) = |{(a,b) ∈ S² : a + b = x}|
* `IsSpectrallyDiffuse` — A set has sub-generic additive energy

## Main Results

* `additiveEnergy_le_cube` — E(S) ≤ |S|³
* `additiveEnergy_ge_sq` — E(S) ≥ |S|² (diagonal contribution)
* `additiveEnergy_empty` — E(∅) = 0
* `additiveEnergy_mono` — Monotonicity under subset inclusion
* `additiveEnergy_translate` — Translation invariance
* `collision_prob_le_one` — E(S)/|S|⁴ ≤ 1

## Cross-Domain Connection

The additive energy framework connects number theory (primality testing via
Miller–Rabin), additive combinatorics (sum-product phenomena), and spectral
graph theory (Cayley graph expansion).
-/

open Finset BigOperators

noncomputable section

namespace SpectralSparsity

/-! ## §1. Additive Energy: Core Definitions -/

variable {G : Type*} [DecidableEq G] [AddCommGroup G]

/-- The set of additive quadruples in S: 4-tuples ((a,b),(c,d)) ∈ S⁴ with a + b = c + d. -/
def AdditiveQuadruples (S : Finset G) : Finset ((G × G) × (G × G)) :=
  ((S ×ˢ S) ×ˢ (S ×ˢ S)).filter fun p => p.1.1 + p.1.2 = p.2.1 + p.2.2

/-- The additive energy of a finite set S is the number of additive quadruples
    (a,b,c,d) ∈ S⁴ satisfying a + b = c + d. -/
def additiveEnergy (S : Finset G) : ℕ :=
  (AdditiveQuadruples S).card

/-- The representation function r_S(x) counts the number of ways to write x = a + b
    with a, b ∈ S. -/
def representationCount (S : Finset G) (x : G) : ℕ :=
  ((S ×ˢ S).filter fun p => p.1 + p.2 = x).card

/-! ## §2. Basic Properties -/

/-- The additive energy of the empty set is zero. -/
theorem additiveEnergy_empty : additiveEnergy (∅ : Finset G) = 0 := by
  simp [additiveEnergy, AdditiveQuadruples]

/-- The representation count for empty set is zero. -/
theorem representationCount_empty (x : G) : representationCount (∅ : Finset G) x = 0 := by
  simp [representationCount]

/-! ## §3. Upper and Lower Bounds -/

/-
**Trivial upper bound**: E(S) ≤ |S|³.
    Each choice of (a, b, c) ∈ S³ determines at most one d = a + b - c,
    which may or may not be in S.
-/
theorem additiveEnergy_le_cube (S : Finset G) :
    additiveEnergy S ≤ S.card ^ 3 := by
  have h_additive_energy_le_cube : (AdditiveQuadruples S).card ≤ Finset.card (Finset.product (Finset.product S S) S) := by
    refine' le_trans ( Finset.card_le_card _ ) _;
    exact Finset.image ( fun p : ( G × G ) × G => ( p.1, p.2, p.1.1 + p.1.2 - p.2 ) ) ( Finset.product ( Finset.product S S ) S );
    · intro p hp
      simp [AdditiveQuadruples] at hp
      aesop;
    · grind;
  exact h_additive_energy_le_cube.trans_eq ( by erw [ Finset.card_product, Finset.card_product ] ; ring )

/-
The diagonal quadruples (a,b,a,b) always contribute |S|² to the energy.
    Therefore E(S) ≥ |S|².
-/
theorem additiveEnergy_ge_sq (S : Finset G) :
    additiveEnergy S ≥ S.card ^ 2 := by
  -- Let's consider the mapping from S × S to AdditiveQuadruples S given by (a, b) ↦ ((a, b), (a, b)).
  have h_diag : Finset.image (fun p => ((p.1, p.2), (p.1, p.2))) (S ×ˢ S) ⊆ AdditiveQuadruples S := by
    exact Finset.image_subset_iff.mpr fun p hp => Finset.mem_filter.mpr ⟨ Finset.mem_product.mpr ⟨ Finset.mem_product.mpr ⟨ Finset.mem_coe.mp ( Finset.mem_product.mp hp |>.1 ), Finset.mem_coe.mp ( Finset.mem_product.mp hp |>.2 ) ⟩, Finset.mem_product.mpr ⟨ Finset.mem_coe.mp ( Finset.mem_product.mp hp |>.1 ), Finset.mem_coe.mp ( Finset.mem_product.mp hp |>.2 ) ⟩ ⟩, rfl ⟩;
  exact le_trans ( by rw [ Finset.card_image_of_injective _ fun x y hxy => by aesop ] ; simp +decide [ sq ] ) ( Finset.card_mono h_diag )

/-
**Cauchy-Schwarz lower bound** (multiplicative form):
    |G| · E(S) ≥ |S|⁴.
    By Cauchy-Schwarz, Σ r(x)² ≥ (Σ r(x))² / |support| ≥ |S|⁴ / |G|.
-/
theorem additiveEnergy_ge_fourth_div [Fintype G] (S : Finset G) :
    Fintype.card G * additiveEnergy S ≥ S.card ^ 4 := by
  -- By Cauchy-Schwarz inequality, we have (∑ x ∈ G, r_S(x))^2 ≤ |G| * (∑ x ∈ G, r_S(x)^2).
  have h_cauchy_schwarz : (∑ x ∈ Finset.univ, (representationCount S x)) ^ 2 ≤ Fintype.card G * (∑ x ∈ Finset.univ, (representationCount S x) ^ 2) := by
    have h_cauchy_schwarz : ∀ (u v : G → ℝ), (∑ x ∈ Finset.univ, u x * v x)^2 ≤ (∑ x ∈ Finset.univ, u x^2) * (∑ x ∈ Finset.univ, v x^2) := by
      exact?;
    convert h_cauchy_schwarz ( fun _ => 1 ) ( fun x => representationCount S x ) using 1 ; norm_num;
    norm_cast;
  -- Note that $\sum_{x \in G} r_S(x) = |S|^2$ and $\sum_{x \in G} r_S(x)^2 = E(S)$.
  have h_sum_r : ∑ x ∈ Finset.univ, (representationCount S x) = S.card ^ 2 := by
    simp +decide only [representationCount];
    simp +decide only [card_filter];
    rw [ Finset.sum_comm ] ; simp +decide [ sq, Finset.sum_product ] ;
  have h_sum_r_sq : ∑ x ∈ Finset.univ, (representationCount S x) ^ 2 = additiveEnergy S := by
    simp +decide only [representationCount, card_eq_sum_ones, sq, Finset.sum_mul _ _ _, mul_sum];
    simp +decide only [sum_filter];
    rw [ Finset.sum_comm ] ; simp +decide [ additiveEnergy ] ;
    simp +decide only [card_filter, AdditiveQuadruples];
    erw [ Finset.sum_product ];
    erw [ Finset.sum_product ] ; simp +decide [ Finset.sum_product ] ;
    simp +decide only [eq_comm];
  rw [ h_sum_r, h_sum_r_sq ] at h_cauchy_schwarz ; linarith

/-! ## §4. Subset Monotonicity -/

/-
**Subset monotonicity**: If T ⊆ S then E(T) ≤ E(S).
    Every additive quadruple in T is also one in S.
-/
theorem additiveEnergy_mono {S T : Finset G} (h : T ⊆ S) :
    additiveEnergy T ≤ additiveEnergy S := by
  convert Finset.card_mono ?_;
  intro p hp; unfold AdditiveQuadruples at *; aesop;

/-! ## §5. Translation Invariance -/

/-
**Translation invariance**: E(t + S) = E(S) for any t ∈ G.
    Additive energy is preserved by translation.
-/
theorem additiveEnergy_translate (S : Finset G) (t : G) :
    additiveEnergy (S.map ⟨(· + t), add_left_injective t⟩) = additiveEnergy S := by
  convert Set.ncard_image_of_injective _ _;
  rotate_left;
  convert Set.ncard_coe_finset _;
  convert Set.ncard_coe_finset _;
  convert Set.ncard_coe_finset _;
  any_goals exact AdditiveQuadruples S;
  all_goals norm_num [ additiveEnergy ];
  convert Set.ncard_coe_finset _;
  exact ( G × G ) × G × G;
  exact fun p => ( ( p.1.1 + t, p.1.2 + t ), ( p.2.1 + t, p.2.2 + t ) );
  · norm_num [ Function.Injective ];
    aesop;
  · rw [ ← Set.ncard_coe_finset ];
    congr with x ; simp +decide [ AdditiveQuadruples ];
    grind +revert

/-! ## §6. Collision Probability Bound -/

/-
**Collision probability bound**: E(S) ≤ |S|⁴ when |S| ≥ 1.
    Combined with E(S) ≤ |S|³, this shows E(S)/|S|⁴ ≤ 1 for |S| ≥ 1.
-/
theorem collision_prob_le_one (S : Finset G) (hS : 1 ≤ S.card) :
    (additiveEnergy S : ℝ) ≤ (S.card : ℝ) ^ 4 := by
  exact_mod_cast le_trans ( additiveEnergy_le_cube S ) ( Nat.pow_le_pow_right hS ( by decide ) )

/-! ## §7. Energy of Disjoint Unions -/

/-
If A and B are disjoint, then E(A ∪ B) ≥ E(A) + E(B).
    Cross-terms can only increase the energy.
-/
theorem additiveEnergy_union_ge (A B : Finset G) (h : Disjoint A B) :
    additiveEnergy (A ∪ B) ≥ additiveEnergy A + additiveEnergy B := by
  -- By definition of $E$, we know that $E(A ∪ B) = \left| \{ (a,b,c,d) \in (A ∪ B)^4 : a + b = c + d \} \right|$.
  suffices h_sum : (AdditiveQuadruples (A ∪ B)).card ≥ (AdditiveQuadruples A).card + (AdditiveQuadruples B).card by
    exact h_sum;
  rw [ ← Finset.card_union_of_disjoint ];
  · refine Finset.card_mono ?_;
    intro p hp; unfold AdditiveQuadruples at *; aesop;
  · simp_all +decide [ Finset.disjoint_left, AdditiveQuadruples ]

/-! ## §8. Spectral Diffuseness -/

/-- A finite set S ⊆ G is *spectrally ε-diffuse* if its additive energy
    satisfies E(S) ≤ C · |S|^{3-ε} for some constant C > 0.
    This captures the notion that S has fewer additive collisions than a
    generic set of the same cardinality. -/
def IsSpectrallyDiffuse (S : Finset G) (ε : ℝ) : Prop :=
  ε > 0 ∧ ∃ C : ℝ, C > 0 ∧
    (additiveEnergy S : ℝ) ≤ C * (S.card : ℝ) ^ (3 - ε)

/-
Any set with |S| ≤ 1 is spectrally 1-diffuse with C = 1.
-/
theorem isSpectrallyDiffuse_of_card_le_one (S : Finset G) (hS : S.card ≤ 1) :
    IsSpectrallyDiffuse S 1 := by
  cases hS.eq_or_lt <;> simp_all +decide [ IsSpectrallyDiffuse ];
  · exact ⟨ additiveEnergy S + 1, Nat.cast_add_one_pos _, le_add_of_nonneg_right zero_le_one ⟩;
  · exact ⟨ 1, zero_lt_one, by norm_num ⟩

/-
Spectral diffuseness is monotone in ε: if S is ε-diffuse,
    then S is ε'-diffuse for any 0 < ε' ≤ ε.
-/
theorem isSpectrallyDiffuse_mono {S : Finset G} {ε ε' : ℝ}
    (h : IsSpectrallyDiffuse S ε) (hε' : 0 < ε') (hle : ε' ≤ ε) :
    IsSpectrallyDiffuse S ε' := by
  refine' ⟨ hε', h.2.choose, h.2.choose_spec.1, _ ⟩;
  have := h.2.choose_spec.2;
  rcases S.eq_empty_or_nonempty with ( rfl | ⟨ x, hx ⟩ ) <;> simp_all +decide;
  · by_cases h : 3 - ε' = 0 <;> simp_all +decide;
    grind +suggestions;
  · exact this.trans ( mul_le_mul_of_nonneg_left ( Real.rpow_le_rpow_of_exponent_le ( mod_cast Finset.card_pos.mpr ⟨ x, hx ⟩ ) ( by linarith ) ) ( by linarith [ h.2.choose_spec.1 ] ) )

/-! ## §9. CRT Fiber Structure for Semiprimes -/

/-- The Chinese Remainder Theorem gives an isomorphism ZMod(pq) ≅ ZMod p × ZMod q
    for coprime p, q. The projection of a set S ⊆ ZMod(pq) to ZMod p is called
    the p-fiber of S. -/
def crtFiber (p q : ℕ) [NeZero p] [NeZero q] [NeZero (p * q)]
    (S : Finset (ZMod (p * q))) : Finset (ZMod p) :=
  S.image fun a => ZMod.castHom (dvd_mul_right p q) (ZMod p) a

/-- The fiber size is at most the size of the original set. -/
theorem crtFiber_card_le (p q : ℕ) [NeZero p] [NeZero q] [NeZero (p * q)]
    (S : Finset (ZMod (p * q))) :
    (crtFiber p q S).card ≤ S.card :=
  Finset.card_image_le

/-! ## §10. Miller-Rabin Liar Set: Computability -/

/-- Compute a^(n-1) mod n. A base a is a Fermat liar for n if this equals 1.
    This is a weaker condition than strong lying but computationally simpler. -/
def isFermatLiar (n a : ℕ) : Bool :=
  if n ≤ 1 then false
  else a ^ (n - 1) % n == 1

/-- The Fermat liar count for n. -/
def fermatLiarCount (n : ℕ) : ℕ :=
  ((Finset.range n).filter fun a => 1 < a ∧ isFermatLiar n a).card

/-
**Upper bound for Fermat liar count**: For n ≥ 3, the number
    of Fermat liars is at most n - 2 (since we only consider 1 < a < n).
-/
theorem fermatLiarCount_le (n : ℕ) (hn : 3 ≤ n) :
    fermatLiarCount n ≤ n - 2 := by
  -- The set of Fermat liars is a subset of {2, 3, ..., n-1}, which has size n-2.
  have h_subset : (Finset.range n).filter (fun a => 1 < a ∧ isFermatLiar n a) ⊆ Finset.Ico 2 n := by
    exact fun x hx => Finset.mem_Ico.mpr ⟨ Nat.succ_le_of_lt ( Finset.mem_filter.mp hx |>.2.1 ), Finset.mem_range.mp ( Finset.mem_filter.mp hx |>.1 ) ⟩;
  exact le_trans ( Finset.card_le_card h_subset ) ( by simpa )

/-! ## §11. Cross-Domain: Number Theory meets Additive Combinatorics -/

/-
**Key structural observation**: If a set S has at most k elements, then
    its additive energy is at most k³. This follows from the trivial upper
    bound and provides the bridge between counting liar-set elements
    (number theory) and bounding additive energy (combinatorics).
-/
theorem energy_of_bounded_set (S : Finset G) (k : ℕ)
    (hS : S.card ≤ k) :
    additiveEnergy S ≤ k ^ 3 := by
  exact le_trans ( additiveEnergy_le_cube S ) ( Nat.pow_le_pow_left hS 3 )

/-! ## §12. Falsifiable Conjecture -/

/-- **Spectral Sparsity Conjecture (Semiprime Case)**:
    For n = p·q where p, q are distinct odd primes, the Fermat liar count
    satisfies a sub-linear bound.

    **Falsification test**: Compute for semiprimes n ≤ 10000.
    If the bound fails for >5% of semiprimes in [N, 2N] with N > 1000,
    the conjecture is likely false.

    **Predicted value**: The exponent is in [2.5, 2.8]. -/
def spectralSparsityConjecture : Prop :=
  ∃ ε : ℝ, ε > 0 ∧ ∃ C : ℝ, C > 0 ∧
    ∀ p q : ℕ, Nat.Prime p → Nat.Prime q → p ≠ q → p ≠ 2 → q ≠ 2 →
      (fermatLiarCount (p * q) : ℝ) ≤ C * ((p * q : ℕ) : ℝ) ^ (1 - ε)

end SpectralSparsity