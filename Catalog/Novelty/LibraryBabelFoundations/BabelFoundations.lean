import Mathlib

/-!
# Library of Babel: Foundations of Universal Information Spaces

## Overview

We develop the combinatorial theory of universal information spaces — finite sets of
all strings over a fixed alphabet of fixed length. This formalizes Borges' Library of
Babel and proves deep structural results about information capacity, self-reference
impossibility, and the geometry of string spaces.

## Main Results

* `distributed_catalog_no_injection` — N-volume catalogs can distinguish at most (A^L)^N items
* `self_reference_fraction_bound` — Quantitative self-reference impossibility
* `catalog_schemes_exceed_decodable` — Diagonal argument: most schemes are unrepresentable
* `compression_survivors_bound` — Pigeonhole incompressibility
* `substring_at_position_count` — Exact count of volumes containing a pattern
* `hamming_bound_abstract` — Sphere-packing bound for separated codewords
* `agreement_count_sum` — Binomial theorem as information partition

## Building on Catalog

This deepens the results in `Catalog/Cryptography/LibraryOfBabel.lean`, particularly
extending `single_volume_addresses_library`, `catalog_impossibility`, and `no_catalog_embedding`
to their natural generalized forms.
-/

namespace BabelFoundations

open Fintype Finset Function BigOperators Nat

/-! ## Core Type -/

/-- A volume in a universal library: a string of length `L` over alphabet `Fin A`. -/
abbrev Volume (A L : ℕ) := Fin L → Fin A

/-- The library size is A^L. -/

theorem hammingDist_triangle {A L : ℕ} (x y z : Volume A L) :
    hammingDist x z ≤ hammingDist x y + hammingDist y z := by
  simp only [hammingDist]
  calc (univ.filter fun i => x i ≠ z i).card
      ≤ ((univ.filter fun i => x i ≠ y i) ∪ (univ.filter fun i => y i ≠ z i)).card := by
        apply Finset.card_le_card
        intro i
        simp only [mem_filter, mem_union, mem_univ, true_and]
        intro hxz
        by_cases hxy : x i = y i
        · right; rw [← hxy]; exact hxz
        · left; exact hxy
    _ ≤ (univ.filter fun i => x i ≠ y i).card + (univ.filter fun i => y i ≠ z i).card :=
        Finset.card_union_le _ _

/-! ## Hamming Sphere and Ball -/

/-- The Hamming sphere of radius r: volumes at exact distance r from center. -/
def hammingSphere {A L : ℕ} (c : Volume A L) (r : ℕ) : Finset (Volume A L) :=
  Finset.univ.filter fun v => hammingDist c v = r

/-- The Hamming ball of radius r: volumes at distance ≤ r from center. -/
def hammingBall {A L : ℕ} (c : Volume A L) (r : ℕ) : Finset (Volume A L) :=
  Finset.univ.filter fun v => hammingDist c v ≤ r

/-! ## Catalog Scheme Theory -/

/-- A catalog scheme assigns labels from `Fin D` to each volume. -/
abbrev CatalogScheme (A L D : ℕ) := Volume A L → Fin D

/-- The capacity of a distributed catalog of N volumes: total number of
    distinguishable states is (A^L)^N. -/

theorem incompressible_ge_compressible (A L M : ℕ) (hA : 2 ≤ A) (hM : M < L)
    (compress : Volume A L → Volume A M)
    (decompress : Volume A M → Volume A L) :
    (Finset.univ.filter fun v : Volume A L => decompress (compress v) ≠ v).card ≥
    (Finset.univ.filter fun v : Volume A L => decompress (compress v) = v).card := by
  -- Since $A \geq 2$ and $M < L$, we have $A^L \geq 2 \cdot A^M$.
  have h_pigeonhole : A ^ L ≥ 2 * A ^ M := by
    rw [ show A ^ L = A ^ M * A ^ ( L - M ) by rw [ ← pow_add, Nat.add_sub_cancel' hM.le ] ] ; nlinarith [ pow_pos ( zero_lt_two.trans_le hA ) M, pow_le_pow_right₀ ( by linarith : 1 ≤ A ) ( Nat.sub_pos_of_lt hM ) ];
  have h_survivors : (Finset.univ.filter fun v : Volume A L => decompress (compress v) = v).card ≤ A ^ M := by
    convert compression_survivors_bound A L M compress decompress using 1;
  have := Finset.card_add_card_compl ( Finset.filter ( fun v => decompress ( compress v ) = v ) Finset.univ ) ; simp_all +decide ; linarith;

/-! ## Covering Numbers -/

/-
**Hamming Bound (Sphere-Packing Bound)**: If Hamming balls of radius r
    around codewords are pairwise disjoint, the union has cardinality
    equal to the number of codewords times the ball size. Since balls
    are subsets of the library, this gives a bound on codeword count.
-/

theorem sphere_size_sum (A L : ℕ) (hA : 1 ≤ A) :
    ∑ k ∈ Finset.range (L + 1), sphereSize A L k = A ^ L := by
  rw [ show A = ( A - 1 ) + 1 by rw [ Nat.sub_add_cancel hA ] ] ; rw [ add_pow ] ; simp +decide [ sphereSize, mul_comm ] ;

/-! ## Novel: Information Deficiency of Compression

The **information deficiency** of a compression scheme measures how many
volumes are lost. This bridges incompressibility theory and coding theory. -/

/-- The information deficiency: the number of volumes not recoverable
    through a compression-decompression cycle. -/
noncomputable def infoDeficiency (A L M : ℕ)
    (compress : Volume A L → Volume A M)
    (decompress : Volume A M → Volume A L) : ℕ :=
  (Finset.univ.filter fun v : Volume A L =>
    decompress (compress v) ≠ v).card

/-
The deficiency is always at least A^L - A^M.
-/

theorem periodic_volume_count {A L p : ℕ} (hA : 1 ≤ A) (hp : 0 < p)
    (hdvd : p ∣ L) (hpL : p ≤ L) :
    (periodicVolumes A L p).card = A ^ p := by
  -- Define the embedding φ : (Fin p → Fin A) → Volume A L by φ(f)(i) = f(⟨i.val % p, by omega⟩)
  set phi : (Fin p → Fin A) → Volume A L := fun f i => f ⟨i.val % p, Nat.mod_lt _ hp⟩;
  -- Show that phi is a bijection between the set of functions from Fin p to Fin A and the set of p-periodic volumes.
  have h_bij : Finset.image phi (Finset.univ : Finset (Fin p → Fin A)) = periodicVolumes A L p := by
    ext v; simp [phi, periodicVolumes];
    constructor;
    · rintro ⟨ f, rfl ⟩ i hi; simp +decide [ Nat.mod_eq_of_lt ( show ( i : ℕ ) < p from _ ) ] ;
    · intro hv
      use fun i => v ⟨i.val, by
        exact?⟩
      generalize_proofs at *;
      ext ⟨ i, hi ⟩ ; induction' i using Nat.strong_induction_on with i ih;
      by_cases hi' : i < p;
      · simp +decide [ Nat.mod_eq_of_lt hi' ];
      · specialize ih ( i - p ) ( Nat.sub_lt ( by linarith ) hp ) ( Nat.lt_of_le_of_lt ( Nat.sub_le _ _ ) hi ) ; simp_all +decide [ Nat.mod_eq_sub_mod ( le_of_not_gt hi' ) ] ;
  rw [ ← h_bij, Finset.card_image_of_injOn, Finset.card_univ ];
  · norm_num;
  · simp +zetaDelta at *;
    exact fun f g hfg => funext fun i => by simpa [ Nat.mod_eq_of_lt ( show i.val < p from i.2 ) ] using congr_fun hfg ⟨ i.val, by linarith [ Fin.is_lt i ] ⟩ ;

end BabelFoundations