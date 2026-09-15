import Cryptography.NonabelianTypeChannel.LogValues

/-!
# The semiprime level: the pair law with the class-level type map

A semiprime `N = p q` presents the arithmetic reader with

* the **residue** of `N`, which by multiplicativity of the abelian characters is the
  *product* of the two Frobenius cosets, and
* the **unordered pair of splitting types** of `p` and `q` — unordered, because a
  factorisation-shape reader of `N` has no way of saying which factor carried which
  shape.

Modelling the two Frobenius elements as an independent uniform pair `(x, y) ∈ G × G`
(Chebotarev for the two factors), this file evaluates the semiprime channel

  `I₂ = I( coset(x·y) ; {T x, T y} )`

exactly, for all six fields, and proves the **which-factor wall**: replacing the
unordered pair `{T x, T y}` by the *ordered* pair `(T x, T y)` does not change the
channel by a single bit.  The reader learns nothing extra from being told which
factor carried which shape.

## The semiprime table (with `L3 = log₂ 3`, `L5 = log₂ 5`)

| field | `I₂` | numerically |
|---|---|---|
| `S₃` | `1` | `1.0000` |
| `S₄` | `1` | `1.0000` |
| `A₄` | `L3 - 10/9` | `0.47385` |
| `D₄` | `39/16 - (3/4)·L3 + (5/64)·L5` | `1.43018` |
| `V₄` | `19/8 - (21/16)·L3` | `0.29474` |
| `C₄` | `5/4` | `1.25000` |

The `S₃`/`S₄` rows are the **`C₂` cap at the semiprime level**: a five-type `S₄` field
still cannot push more than the one bit of its abelianization through a semiprime,
while `D₄`, whose abelianization is two-dimensional, goes above one bit.
-/

namespace TypeChannel

open Finset Real

set_option maxRecDepth 4000000
set_option maxHeartbeats 4000000

/-- A numeric code for the splitting type, so that pairs of types can be ordered. -/
def typeCode {n : ℕ} (g : Equiv.Perm (Fin n)) : ℕ :=
  10 * (splitType g).1 + (splitType g).2

/-- The unordered pair of splitting types of the two prime factors. -/
def symType {n : ℕ} (p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n)) : ℕ × ℕ :=
  (min (typeCode p.1) (typeCode p.2), max (typeCode p.1) (typeCode p.2))

/-- The ordered pair of splitting types: the readout of someone who is *also* told
which factor is which. -/
def ordType {n : ℕ} (p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n)) : ℕ × ℕ :=
  (typeCode p.1, typeCode p.2)

/-- The residue readout of the semiprime: the coset of the product. -/
def prodCoset {n : ℕ} (c : Equiv.Perm (Fin n) → ℕ)
    (p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n)) : ℕ := c (p.1 * p.2)

/-! ### `S₃`: the semiprime channel is the one bit of `C₂` -/

theorem S3_semi_entropy_coset : entropy (S3 ×ˢ S3) (prodCoset signIdx) = 1 := by
  have hcard : (S3 ×ˢ S3).card = 36 := by decide
  rw [entropy_eq_sumList (A := [0,1]) (L := [18,18]) (by decide) (by decide) (by decide),
    hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat]
  rw [neg_prob_logb_real 18 36 (by norm_num) (by norm_num), logb2_eighteen, logb2_thirtysix]
  ring

/-- Both the unordered and the ordered type pair determine the residue of the
semiprime, so both channels are exactly one bit. -/
theorem S3_semi_channel : mutualInfo (S3 ×ˢ S3) (prodCoset signIdx) symType = 1 := by
  have hdet : ∀ p ∈ S3 ×ˢ S3, prodCoset signIdx p =
      (fun s : ℕ × ℕ => ((if s.1 = 12 then 1 else 0) + (if s.2 = 12 then 1 else 0)) % 2)
        (symType p) := by decide
  rw [mutualInfo_eq_left_of_factors
    (φ := fun s : ℕ × ℕ => ((if s.1 = 12 then 1 else 0) + (if s.2 = 12 then 1 else 0)) % 2)
    hdet, S3_semi_entropy_coset]

theorem S3_semi_channel_ordered : mutualInfo (S3 ×ˢ S3) (prodCoset signIdx) ordType = 1 := by
  have hdet : ∀ p ∈ S3 ×ˢ S3, prodCoset signIdx p =
      (fun s : ℕ × ℕ => ((if s.1 = 12 then 1 else 0) + (if s.2 = 12 then 1 else 0)) % 2)
        (ordType p) := by decide
  rw [mutualInfo_eq_left_of_factors
    (φ := fun s : ℕ × ℕ => ((if s.1 = 12 then 1 else 0) + (if s.2 = 12 then 1 else 0)) % 2)
    hdet, S3_semi_entropy_coset]

/-- The which-factor wall for `S₃`: knowing which factor carried which type adds
nothing. -/
theorem S3_which_factor_wall :
    mutualInfo (S3 ×ˢ S3) (prodCoset signIdx) ordType
      = mutualInfo (S3 ×ˢ S3) (prodCoset signIdx) symType := by
  rw [S3_semi_channel, S3_semi_channel_ordered]

/-! ### `S₄`: the `C₂` cap survives at the semiprime level -/

theorem S4_semi_entropy_coset : entropy (S4 ×ˢ S4) (prodCoset signIdx) = 1 := by
  have hcard : (S4 ×ˢ S4).card = 576 := by decide
  rw [entropy_eq_sumList (A := [0,1]) (L := [288,288]) (by decide) (by decide) (by decide),
    hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat]
  rw [neg_prob_logb_real 288 576 (by norm_num) (by norm_num), logb2_twoeightyeight,
    logb2_fiveseventysix]
  ring

/-- **The semiprime `C₂` cap.**  `S₄` has five splitting types and fifteen unordered
type pairs, yet its semiprime channel is exactly the one bit of its abelianization. -/
theorem S4_semi_channel : mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) symType = 1 := by
  have hdet : ∀ p ∈ S4 ×ˢ S4, prodCoset signIdx p =
      (fun s : ℕ × ℕ => ((if s.1 = 0 ∨ s.1 = 22 then 1 else 0)
        + (if s.2 = 0 ∨ s.2 = 22 then 1 else 0)) % 2) (symType p) := by decide
  rw [mutualInfo_eq_left_of_factors
    (φ := fun s : ℕ × ℕ => ((if s.1 = 0 ∨ s.1 = 22 then 1 else 0)
      + (if s.2 = 0 ∨ s.2 = 22 then 1 else 0)) % 2) hdet, S4_semi_entropy_coset]

theorem S4_semi_channel_ordered : mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) ordType = 1 := by
  have hdet : ∀ p ∈ S4 ×ˢ S4, prodCoset signIdx p =
      (fun s : ℕ × ℕ => ((if s.1 = 0 ∨ s.1 = 22 then 1 else 0)
        + (if s.2 = 0 ∨ s.2 = 22 then 1 else 0)) % 2) (ordType p) := by decide
  rw [mutualInfo_eq_left_of_factors
    (φ := fun s : ℕ × ℕ => ((if s.1 = 0 ∨ s.1 = 22 then 1 else 0)
      + (if s.2 = 0 ∨ s.2 = 22 then 1 else 0)) % 2) hdet, S4_semi_entropy_coset]

theorem S4_which_factor_wall :
    mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) ordType
      = mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) symType := by
  rw [S4_semi_channel, S4_semi_channel_ordered]

/-! ### `A₄` -/

theorem A4_semi_entropy_coset : entropy (A4 ×ˢ A4) (prodCoset pairIdx) = logb 2 3 := by
  have hcard : (A4 ×ˢ A4).card = 144 := by decide
  rw [entropy_eq_sumList (A := [0,1,2]) (L := [48,48,48]) (by decide) (by decide) (by decide),
    hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat]
  rw [neg_prob_logb_real 48 144 (by norm_num) (by norm_num), logb2_fortyeight,
    logb2_onefortyfour]
  ring

theorem A4_semi_entropy_symType :
    entropy (A4 ×ˢ A4) symType = -(35/72) + 3/2 * logb 2 3 := by
  have hcard : (A4 ×ˢ A4).card = 144 := by decide
  rw [entropy_eq_sumList (A := [(4,4),(4,10),(4,40),(10,10),(10,40),(40,40)])
    (L := [9,48,6,64,16,1]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 9 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 48 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 6 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 64 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 16 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 144 (by norm_num) (by norm_num)]
  rw [logb2_nine, logb2_fortyeight, logb2_six, logb2_sixtyfour, logb2_sixteen,
    logb2_onefortyfour]
  norm_num
  ring

theorem A4_semi_entropy_joint :
    entropy (A4 ×ˢ A4) (pairObs (prodCoset pairIdx) symType) = 5/8 + 3/2 * logb 2 3 := by
  have hcard : (A4 ×ˢ A4).card = 144 := by decide
  rw [entropy_eq_sumList
    (A := [(0,(4,4)),(0,(4,40)),(0,(10,10)),(0,(40,40)),(1,(4,10)),(1,(10,10)),(1,(10,40)),
      (2,(4,10)),(2,(10,10)),(2,(10,40))])
    (L := [9,6,32,1,24,16,8,24,16,8]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 9 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 6 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 32 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 24 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 16 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 8 144 (by norm_num) (by norm_num)]
  rw [logb2_nine, logb2_six, logb2_thirtytwo, logb2_twentyfour, logb2_sixteen, logb2_eight,
    logb2_onefortyfour]
  norm_num
  ring

theorem A4_semi_channel :
    mutualInfo (A4 ×ˢ A4) (prodCoset pairIdx) symType = logb 2 3 - 10/9 := by
  rw [mutualInfo, A4_semi_entropy_coset, A4_semi_entropy_symType, A4_semi_entropy_joint]
  ring

theorem A4_semi_entropy_ordType : entropy (A4 ×ˢ A4) ordType = 3/2 * logb 2 3 := by
  have hcard : (A4 ×ˢ A4).card = 144 := by decide
  rw [entropy_eq_sumList (A := [(4,4),(4,10),(4,40),(10,4),(10,10),(10,40),(40,4),(40,10),(40,40)])
    (L := [9,24,3,24,64,8,3,8,1]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 9 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 24 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 3 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 64 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 8 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 144 (by norm_num) (by norm_num)]
  rw [logb2_nine, logb2_twentyfour, logb2_sixtyfour, logb2_eight, logb2_onefortyfour]
  norm_num
  ring

theorem A4_semi_entropy_ordJoint :
    entropy (A4 ×ˢ A4) (pairObs (prodCoset pairIdx) ordType) = 10/9 + 3/2 * logb 2 3 := by
  have hcard : (A4 ×ˢ A4).card = 144 := by decide
  rw [entropy_eq_sumList
    (A := [(0,(4,4)),(0,(4,40)),(0,(10,10)),(0,(40,4)),(0,(40,40)),
      (1,(4,10)),(1,(10,4)),(1,(10,10)),(1,(10,40)),(1,(40,10)),
      (2,(4,10)),(2,(10,4)),(2,(10,10)),(2,(10,40)),(2,(40,10))])
    (L := [9,3,32,3,1,12,12,16,4,4,12,12,16,4,4]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 9 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 3 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 32 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 12 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 16 144 (by norm_num) (by norm_num),
    neg_prob_logb_real 4 144 (by norm_num) (by norm_num)]
  rw [logb2_nine, logb2_thirtytwo, logb2_twelve, logb2_sixteen, logb2_four,
    logb2_onefortyfour]
  norm_num
  ring

/-- The which-factor wall for `A₄`. -/
theorem A4_which_factor_wall :
    mutualInfo (A4 ×ˢ A4) (prodCoset pairIdx) ordType
      = mutualInfo (A4 ×ˢ A4) (prodCoset pairIdx) symType := by
  rw [mutualInfo, mutualInfo, A4_semi_entropy_coset, A4_semi_entropy_symType,
    A4_semi_entropy_joint, A4_semi_entropy_ordType, A4_semi_entropy_ordJoint]
  ring

/-! ### `D₄` -/

theorem D4_semi_entropy_coset : entropy (D4 ×ˢ D4) (prodCoset d4Idx) = 2 := by
  have hcard : (D4 ×ˢ D4).card = 64 := by decide
  rw [entropy_eq_sumList (A := [0,1,2,3]) (L := [16,16,16,16])
    (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat]
  rw [neg_prob_logb_real 16 64 (by norm_num) (by norm_num), logb2_sixteen, logb2_sixtyfour]
  ring

theorem D4_semi_entropy_symType :
    entropy (D4 ×ˢ D4) symType = 137/32 - 3/4 * logb 2 3 := by
  have hcard : (D4 ×ˢ D4).card = 64 := by decide
  rw [entropy_eq_sumList
    (A := [(0,0),(0,4),(0,22),(0,40),(4,4),(4,22),(4,40),(22,22),(22,40),(40,40)])
    (L := [4,12,8,4,9,12,6,4,4,1]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 4 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 12 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 8 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 9 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 6 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 64 (by norm_num) (by norm_num)]
  rw [logb2_four, logb2_twelve, logb2_eight, logb2_nine, logb2_six, logb2_sixtyfour]
  norm_num
  ring

theorem D4_semi_entropy_joint :
    entropy (D4 ×ˢ D4) (pairObs (prodCoset d4Idx) symType) = 123/32 - 5/64 * logb 2 5 := by
  have hcard : (D4 ×ˢ D4).card = 64 := by decide
  rw [entropy_eq_sumList
    (A := [(0,(0,0)),(0,(4,4)),(0,(4,40)),(0,(22,22)),(0,(40,40)),
      (1,(0,4)),(1,(4,22)),(1,(22,40)),
      (2,(0,22)),(2,(4,4)),(2,(4,40)),
      (3,(0,4)),(3,(0,40)),(3,(4,22))])
    (L := [4,5,2,4,1,8,4,4,8,4,4,4,4,8]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 4 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 5 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 2 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 8 64 (by norm_num) (by norm_num)]
  rw [logb2_four, logb2_two, logb2_eight, logb2_sixtyfour]
  norm_num
  ring

/-- The `D₄` semiprime channel exceeds one bit — a non-abelian field whose semiprime
channel is richer than any quadratic one, exactly as its `C₂ × C₂` abelianization
predicts. -/
theorem D4_semi_channel : mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) symType
    = 39/16 - 3/4 * logb 2 3 + 5/64 * logb 2 5 := by
  rw [mutualInfo, D4_semi_entropy_coset, D4_semi_entropy_symType, D4_semi_entropy_joint]
  ring

theorem D4_semi_entropy_ordType : entropy (D4 ×ˢ D4) ordType = 5 - 3/4 * logb 2 3 := by
  have hcard : (D4 ×ˢ D4).card = 64 := by decide
  rw [entropy_eq_sumList
    (A := [(0,0),(0,4),(0,22),(0,40),(4,0),(4,4),(4,22),(4,40),
      (22,0),(22,4),(22,22),(22,40),(40,0),(40,4),(40,22),(40,40)])
    (L := [4,6,4,2,6,9,6,3,4,6,4,2,2,3,2,1]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 4 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 6 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 2 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 9 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 3 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 64 (by norm_num) (by norm_num)]
  rw [logb2_four, logb2_six, logb2_two, logb2_nine, logb2_sixtyfour]
  norm_num
  ring

theorem D4_semi_entropy_ordJoint :
    entropy (D4 ×ˢ D4) (pairObs (prodCoset d4Idx) ordType) = 73/16 - 5/64 * logb 2 5 := by
  have hcard : (D4 ×ˢ D4).card = 64 := by decide
  rw [entropy_eq_sumList
    (A := [(0,(0,0)),(0,(4,4)),(0,(4,40)),(0,(22,22)),(0,(40,4)),(0,(40,40)),
      (1,(0,4)),(1,(4,0)),(1,(4,22)),(1,(22,4)),(1,(22,40)),(1,(40,22)),
      (2,(0,22)),(2,(4,4)),(2,(4,40)),(2,(22,0)),(2,(40,4)),
      (3,(0,4)),(3,(0,40)),(3,(4,0)),(3,(4,22)),(3,(22,4)),(3,(40,0))])
    (L := [4,5,1,4,1,1,4,4,2,2,2,2,4,4,2,4,2,2,2,2,4,4,2])
    (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 4 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 5 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 64 (by norm_num) (by norm_num),
    neg_prob_logb_real 2 64 (by norm_num) (by norm_num)]
  rw [logb2_four, logb2_two, logb2_sixtyfour]
  norm_num
  ring

/-- The which-factor wall for `D₄`. -/
theorem D4_which_factor_wall :
    mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) ordType
      = mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) symType := by
  rw [mutualInfo, mutualInfo, D4_semi_entropy_coset, D4_semi_entropy_symType,
    D4_semi_entropy_joint, D4_semi_entropy_ordType, D4_semi_entropy_ordJoint]
  ring

/-! ### `V₄` (abelian control) -/

theorem V4_semi_entropy_coset : entropy (V4 ×ˢ V4) (prodCoset rootIdx) = 2 := by
  have hcard : (V4 ×ˢ V4).card = 16 := by decide
  rw [entropy_eq_sumList (A := [0,1,2,3]) (L := [4,4,4,4])
    (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat]
  rw [neg_prob_logb_real 4 16 (by norm_num) (by norm_num), logb2_four, logb2_sixteen]
  ring

theorem V4_semi_entropy_symType :
    entropy (V4 ×ˢ V4) symType = 29/8 - 3/2 * logb 2 3 := by
  have hcard : (V4 ×ˢ V4).card = 16 := by decide
  rw [entropy_eq_sumList (A := [(4,4),(4,40),(40,40)]) (L := [9,6,1])
    (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 9 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 6 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 16 (by norm_num) (by norm_num)]
  rw [logb2_nine, logb2_six, logb2_sixteen]
  norm_num
  ring

theorem V4_semi_entropy_joint :
    entropy (V4 ×ˢ V4) (pairObs (prodCoset rootIdx) symType) = 13/4 - 3/16 * logb 2 3 := by
  have hcard : (V4 ×ˢ V4).card = 16 := by decide
  rw [entropy_eq_sumList
    (A := [(0,(4,4)),(0,(40,40)),(1,(4,4)),(1,(4,40)),(2,(4,4)),(2,(4,40)),
      (3,(4,4)),(3,(4,40))])
    (L := [3,1,2,2,2,2,2,2]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 3 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 2 16 (by norm_num) (by norm_num)]
  rw [logb2_two, logb2_sixteen]
  norm_num
  ring

theorem V4_semi_channel :
    mutualInfo (V4 ×ˢ V4) (prodCoset rootIdx) symType = 19/8 - 21/16 * logb 2 3 := by
  rw [mutualInfo, V4_semi_entropy_coset, V4_semi_entropy_symType, V4_semi_entropy_joint]
  ring

theorem V4_semi_entropy_ordType : entropy (V4 ×ˢ V4) ordType = 4 - 3/2 * logb 2 3 := by
  have hcard : (V4 ×ˢ V4).card = 16 := by decide
  rw [entropy_eq_sumList (A := [(4,4),(4,40),(40,4),(40,40)]) (L := [9,3,3,1])
    (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 9 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 3 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 16 (by norm_num) (by norm_num)]
  rw [logb2_nine, logb2_sixteen]
  norm_num
  ring

theorem V4_semi_entropy_ordJoint :
    entropy (V4 ×ˢ V4) (pairObs (prodCoset rootIdx) ordType) = 29/8 - 3/16 * logb 2 3 := by
  have hcard : (V4 ×ˢ V4).card = 16 := by decide
  rw [entropy_eq_sumList
    (A := [(0,(4,4)),(0,(40,40)),(1,(4,4)),(1,(4,40)),(1,(40,4)),(2,(4,4)),(2,(4,40)),
      (2,(40,4)),(3,(4,4)),(3,(4,40)),(3,(40,4))])
    (L := [3,1,2,1,1,2,1,1,2,1,1]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 3 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 2 16 (by norm_num) (by norm_num)]
  rw [logb2_two, logb2_sixteen]
  norm_num
  ring

/-- The which-factor wall for `V₄`. -/
theorem V4_which_factor_wall :
    mutualInfo (V4 ×ˢ V4) (prodCoset rootIdx) ordType
      = mutualInfo (V4 ×ˢ V4) (prodCoset rootIdx) symType := by
  rw [mutualInfo, mutualInfo, V4_semi_entropy_coset, V4_semi_entropy_symType,
    V4_semi_entropy_joint, V4_semi_entropy_ordType, V4_semi_entropy_ordJoint]
  ring

/-! ### `C₄` (abelian control, paper 78) -/

theorem C4_semi_entropy_coset : entropy (C4 ×ˢ C4) (prodCoset rootIdx) = 2 := by
  have hcard : (C4 ×ˢ C4).card = 16 := by decide
  rw [entropy_eq_sumList (A := [0,1,2,3]) (L := [4,4,4,4])
    (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat]
  rw [neg_prob_logb_real 4 16 (by norm_num) (by norm_num), logb2_four, logb2_sixteen]
  ring

theorem C4_semi_entropy_symType : entropy (C4 ×ˢ C4) symType = 19/8 := by
  have hcard : (C4 ×ˢ C4).card = 16 := by decide
  rw [entropy_eq_sumList (A := [(0,0),(0,4),(0,40),(4,4),(4,40),(40,40)]) (L := [4,4,4,1,2,1])
    (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 4 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 2 16 (by norm_num) (by norm_num)]
  rw [logb2_four, logb2_two, logb2_sixteen]
  norm_num

theorem C4_semi_entropy_joint :
    entropy (C4 ×ˢ C4) (pairObs (prodCoset rootIdx) symType) = 25/8 := by
  have hcard : (C4 ×ˢ C4).card = 16 := by decide
  rw [entropy_eq_sumList
    (A := [(0,(0,0)),(0,(4,4)),(0,(40,40)),(1,(0,4)),(1,(0,40)),(2,(0,0)),(2,(4,40)),
      (3,(0,4)),(3,(0,40))])
    (L := [2,1,1,2,2,2,2,2,2]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 2 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 16 (by norm_num) (by norm_num)]
  rw [logb2_two, logb2_sixteen]
  norm_num

/-- The `C₄` semiprime channel is exactly `5/4` — the paper-78 abelian pair law. -/
theorem C4_semi_channel : mutualInfo (C4 ×ˢ C4) (prodCoset rootIdx) symType = 5/4 := by
  rw [mutualInfo, C4_semi_entropy_coset, C4_semi_entropy_symType, C4_semi_entropy_joint]
  ring

theorem C4_semi_entropy_ordType : entropy (C4 ×ˢ C4) ordType = 3 := by
  have hcard : (C4 ×ˢ C4).card = 16 := by decide
  rw [entropy_eq_sumList
    (A := [(0,0),(0,4),(0,40),(4,0),(4,4),(4,40),(40,0),(40,4),(40,40)])
    (L := [4,2,2,2,1,1,2,1,1]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 4 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 2 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 16 (by norm_num) (by norm_num)]
  rw [logb2_four, logb2_two, logb2_sixteen]
  norm_num

theorem C4_semi_entropy_ordJoint :
    entropy (C4 ×ˢ C4) (pairObs (prodCoset rootIdx) ordType) = 15/4 := by
  have hcard : (C4 ×ˢ C4).card = 16 := by decide
  rw [entropy_eq_sumList
    (A := [(0,(0,0)),(0,(4,4)),(0,(40,40)),(1,(0,4)),(1,(0,40)),(1,(4,0)),(1,(40,0)),
      (2,(0,0)),(2,(4,40)),(2,(40,4)),(3,(0,4)),(3,(0,40)),(3,(4,0)),(3,(40,0))])
    (L := [2,1,1,1,1,1,1,2,1,1,1,1,1,1]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 2 16 (by norm_num) (by norm_num),
    neg_prob_logb_real 1 16 (by norm_num) (by norm_num)]
  rw [logb2_two, logb2_sixteen]
  norm_num

/-- The which-factor wall for `C₄`. -/
theorem C4_which_factor_wall :
    mutualInfo (C4 ×ˢ C4) (prodCoset rootIdx) ordType
      = mutualInfo (C4 ×ˢ C4) (prodCoset rootIdx) symType := by
  rw [mutualInfo, mutualInfo, C4_semi_entropy_coset, C4_semi_entropy_symType,
    C4_semi_entropy_joint, C4_semi_entropy_ordType, C4_semi_entropy_ordJoint]
  ring

/-! ### The semiprime comparison -/

/-- At the semiprime level, too, the non-abelian `D₄` channel beats the abelian `V₄`
channel, and beats the one-bit `C₂` ceiling that caps `S₃` and `S₄`. -/
theorem semiprime_reversal :
    mutualInfo (V4 ×ˢ V4) (prodCoset rootIdx) symType
      < mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) symType ∧
    mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) symType
      < mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) symType := by
  have h3 := logb2_three_lt_two
  have h3' := logb2_three_gt_one
  have h5 := logb2_five_gt_two
  rw [V4_semi_channel, D4_semi_channel, S4_semi_channel]
  constructor <;> linarith

end TypeChannel