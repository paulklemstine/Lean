/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Detecting Seed-Compressible Files and Routing Them

This file joins the two halves of the "PRNG-generated real-world data" question:
the *seed-recovery* theory of `MachineLearning.PRNGSeedRecoveryLFSR` and the
*counting limits* of `MachineLearning.PRNGCompressionBound`.

A file is modelled as `Bits N` (an `N`-bit string).  It is **`L`-seed
compressible** when some binary LFSR of order `L` — that is, `2L` bits of taps
and seed — emits it verbatim.

## Main results

* `seedCompressible_iff_decodable` — **the falsifiability gate**: a file is
  `L`-seed compressible *iff* a `2L`-bit program makes the fixed decoder
  `lfsrDecoder` output the file exactly, bit for bit.
* `KC_lfsrDecoder_le` — detection pays: such a file has description complexity
  at most `2L`, independently of its length `N`.
* `card_seedCompressible_le` — at most `4 ^ L` of the `2 ^ N` files are `L`-seed
  compressible: the detector's search space, and its false-positive budget.
* `seedCompressible_rare` — the seed-compressible fraction is `2 ^ (2L - N)`.
* `exists_not_seedCompressible` — as soon as `2L < N` the detector must reject
  something, so the classifier is not vacuous.
* `classifier_dichotomy` — for any decoder `D` at all there are files that are
  *neither* seed-compressible *nor* `d`-bit compressible by `D`: the router's
  two boxes ("seed-compressible" / "model-compressible") do not cover the space.
* `not_seedCompressible_and_hard_64` — a concrete instance of the dichotomy at
  `N = 64`, `L = 8`, `d = 4`.
* `card_seedCompressible_le_sharp` — the naive `4 ^ L` count is never tight:
  all zero-seed registers collapse to the same file.
* `isSeedCompressible_of_periodic` — a real corpus that the detector does catch:
  every `p`-periodic file is seed compressible with a `2p`-bit description.
* `detector_sound_from_2L_bits`, `lfsrBits_eq_of_agree_two_mul` — a `2L`-bit
  observation window is enough: fitting `2L` bits of an `L`-seed-compressible
  file forces exact reproduction of the whole file.

## Application keywords

PRNG detection, seed recovery, LFSR fingerprinting, Kolmogorov complexity,
compression benchmark, classifier
-/

import MachineLearning.PRNGCompressionBound
import MachineLearning.PRNGSeedRecoveryLFSR
import MachineLearning.PRNGBerlekampMassey

open Finset PRNGCompression

namespace PRNGSeed

/-! ### Bits versus `GF(2)` -/

/-- The bit `b` as an element of `GF(2)`. -/
def toZ2 (b : Bool) : ZMod 2 := if b then 1 else 0

/-- An element of `GF(2)` as a bit. -/
def ofZ2 (z : ZMod 2) : Bool := decide (z = 1)

@[simp] lemma ofZ2_toZ2 (b : Bool) : ofZ2 (toZ2 b) = b := by
  cases b <;> decide

/-- The binary output stream of the order-`L` LFSR with taps `c` and seed
`init`, both given as bit vectors. -/
def lfsrBits (L : ℕ) (c init : Fin L → Bool) : ℕ → Bool := fun n =>
  ofZ2 (lfsrRun (fun i => toZ2 (c i)) (fun i => toZ2 (init i)) n)

/-! ### The detector and its decoder -/

/-- A file `w : Bits N` is `L`-seed compressible when some order-`L` binary LFSR
emits it. -/
def IsSeedCompressible (N L : ℕ) (w : Bits N) : Prop :=
  ∃ c init : Fin L → Bool, ∀ i : Fin N, w i = lfsrBits L c init (i : ℕ)

/-- The canonical seed decoder: read `L` tap bits and `L` seed bits off the
program and run the register for `N` steps. -/
def lfsrDecoder (N L : ℕ) (p : List Bool) : Bits N := fun i =>
  lfsrBits L (fun j : Fin L => p.getD (j : ℕ) false)
    (fun j : Fin L => p.getD (L + (j : ℕ)) false) (i : ℕ)

/-- The `2L`-bit program encoding taps and seed. -/
def seedProgram {L : ℕ} (c init : Fin L → Bool) : List Bool :=
  List.ofFn c ++ List.ofFn init

@[simp] lemma seedProgram_length {L : ℕ} (c init : Fin L → Bool) :
    (seedProgram c init).length = 2 * L := by
  simp [seedProgram, two_mul]

lemma seedProgram_getD_left {L : ℕ} (c init : Fin L → Bool) (j : Fin L) :
    (seedProgram c init).getD (j : ℕ) false = c j := by
  have hj : (j : ℕ) < (List.ofFn c).length := by simp
  simp [seedProgram, List.getD_eq_getElem?_getD, List.getElem?_append_left hj]

lemma seedProgram_getD_right {L : ℕ} (c init : Fin L → Bool) (j : Fin L) :
    (seedProgram c init).getD (L + (j : ℕ)) false = init j := by
  have hj : (List.ofFn c).length ≤ L + (j : ℕ) := by simp
  simp [seedProgram, List.getD_eq_getElem?_getD]

lemma lfsrDecoder_seedProgram (N : ℕ) {L : ℕ} (c init : Fin L → Bool) :
    lfsrDecoder N L (seedProgram c init) = fun i : Fin N => lfsrBits L c init (i : ℕ) := by
  funext i
  simp only [lfsrDecoder, seedProgram_getD_left, seedProgram_getD_right]

/-- **The falsifiability gate.**  A file is `L`-seed compressible exactly when
some program drives the fixed decoder to reproduce the file *bit for bit*.
Nothing weaker (statistical similarity, matching prefixes) is accepted. -/
theorem seedCompressible_iff_decodable (N L : ℕ) (w : Bits N) :
    IsSeedCompressible N L w ↔ ∃ p : List Bool, lfsrDecoder N L p = w := by
  constructor
  · rintro ⟨c, init, h⟩
    refine ⟨seedProgram c init, ?_⟩
    rw [lfsrDecoder_seedProgram]
    funext i
    exact (h i).symm
  · rintro ⟨p, hp⟩
    refine ⟨fun j : Fin L => p.getD (j : ℕ) false,
      fun j : Fin L => p.getD (L + (j : ℕ)) false, fun i => ?_⟩
    rw [← hp]
    rfl

/-- **Detection pays.**  A seed-compressible file has description complexity at
most `2L` bits — the taps plus the seed — no matter how long the file is. -/
theorem KC_lfsrDecoder_le {N L : ℕ} {w : Bits N} (h : IsSeedCompressible N L w) :
    KC (lfsrDecoder N L) w ≤ 2 * L := by
  obtain ⟨c, init, hci⟩ := h
  have hdec : lfsrDecoder N L (seedProgram c init) = w := by
    rw [lfsrDecoder_seedProgram]
    funext i
    exact (hci i).symm
  have := KC_le_of_decodes (D := lfsrDecoder N L) hdec
  simpa using this

/-! ### How much data can possibly be seed-compressible -/

open Classical in
/-- The seed-compressible files of length `N` and order `L`. -/
noncomputable def seedCompressibleFinset (N L : ℕ) : Finset (Bits N) :=
  univ.filter (fun w => IsSeedCompressible N L w)

open Classical in
/-- **The detector's search space.**  At most `4 ^ L` files of any length are
`L`-seed compressible: `2 ^ L` tap vectors times `2 ^ L` seeds.  This is also
the false-positive budget of any *sound* detector. -/
theorem card_seedCompressible_le (N L : ℕ) :
    (seedCompressibleFinset N L).card ≤ 4 ^ L := by
  classical
  have hsub : seedCompressibleFinset N L ⊆
      (univ : Finset ((Fin L → Bool) × (Fin L → Bool))).image
        (fun t : (Fin L → Bool) × (Fin L → Bool) =>
          (fun i : Fin N => lfsrBits L t.1 t.2 (i : ℕ))) := by
    intro w hw
    simp only [seedCompressibleFinset, mem_filter] at hw
    obtain ⟨c, init, hci⟩ := hw.2
    refine mem_image.mpr ⟨(c, init), mem_univ _, ?_⟩
    funext i
    exact (hci i).symm
  refine le_trans (card_le_card hsub) (le_trans card_image_le ?_)
  rw [card_univ]
  simp only [Fintype.card_prod, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
  rw [show (4 : ℕ) = 2 * 2 from rfl, mul_pow]

@[simp] lemma lfsrBits_zero_seed (L : ℕ) (c : Fin L → Bool) (n : ℕ) :
    lfsrBits L c (fun _ => false) n = false := by
  have h : (fun i : Fin L => toZ2 ((fun _ => false : Fin L → Bool) i)) = fun _ => (0 : ZMod 2) := by
    funext i; simp [toZ2]
  rw [lfsrBits, h, lfsrRun_zero_seed]
  decide

open Classical in
/-- **The naive count is not tight.**  All `2 ^ L` zero-seed registers emit the
same (all-zero) file, so at most `4 ^ L - 2 ^ L + 1` files are `L`-seed
compressible.  Experimentally the true count is smaller still (43 of the 64
order-3 parameter pairs give distinct streams), which is why the detector's
false-positive budget is a strict overestimate. -/
theorem card_seedCompressible_le_sharp (N L : ℕ) :
    (seedCompressibleFinset N L).card + 2 ^ L ≤ 4 ^ L + 1 := by
  classical
  set A : Finset ((Fin L → Bool) × (Fin L → Bool)) :=
    univ.filter (fun t => t.2 ≠ fun _ => false) with hAdef
  set f : (Fin L → Bool) × (Fin L → Bool) → Bits N :=
    fun t => (fun i : Fin N => lfsrBits L t.1 t.2 (i : ℕ)) with hf
  set z : Bits N := (fun _ => false) with hz
  have hsub : seedCompressibleFinset N L ⊆ insert z (A.image f) := by
    intro w hw
    simp only [seedCompressibleFinset, mem_filter] at hw
    obtain ⟨c, init, hci⟩ := hw.2
    by_cases h0 : init = fun _ => false
    · have hwz : w = z := by
        funext i
        rw [hci i, h0, hz]
        exact lfsrBits_zero_seed L c (i : ℕ)
      rw [hwz]
      exact mem_insert_self _ _
    · refine mem_insert_of_mem (mem_image.mpr ⟨(c, init), ?_, ?_⟩)
      · simp only [hAdef, mem_filter]
        exact ⟨mem_univ _, h0⟩
      · exact funext fun i => (hci i).symm
  have hcardA : A.card + 2 ^ L = 4 ^ L := by
    have hcompl :
        (univ.filter
            (fun t : (Fin L → Bool) × (Fin L → Bool) => ¬ (t.2 ≠ fun _ => false)))
          = univ ×ˢ ({fun _ => false} : Finset (Fin L → Bool)) := by
      ext t
      constructor
      · intro ht
        simp only [mem_filter, not_not] at ht
        exact Finset.mem_product.mpr ⟨mem_univ _, mem_singleton.mpr ht.2⟩
      · intro ht
        have h2 := (Finset.mem_product.mp ht).2
        simp only [mem_filter, mem_univ, true_and, not_not]
        exact mem_singleton.mp h2
    have hsplit := Finset.card_filter_add_card_filter_not
      (s := (univ : Finset ((Fin L → Bool) × (Fin L → Bool))))
      (p := fun t => t.2 ≠ fun _ => false)
    rw [hcompl, Finset.card_product] at hsplit
    have hcard : (univ : Finset ((Fin L → Bool) × (Fin L → Bool))).card = 4 ^ L := by
      rw [card_univ]
      simp only [Fintype.card_prod, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
      rw [show (4 : ℕ) = 2 * 2 from rfl, mul_pow]
    have hcu : (univ : Finset (Fin L → Bool)).card = 2 ^ L := by
      rw [card_univ]
      simp
    rw [hcu, hcard] at hsplit
    simpa [hAdef] using hsplit
  have h1 : (seedCompressibleFinset N L).card ≤ A.card + 1 := by
    refine le_trans (card_le_card hsub) ?_
    refine le_trans (card_insert_le _ _) ?_
    exact Nat.succ_le_succ card_image_le
  omega

/-- **Seed-compressible data is exponentially rare.**  Out of `2 ^ N` files at
most a `2 ^ (2L - N)` fraction can be produced by an order-`L` LFSR. -/
theorem seedCompressible_rare (N L : ℕ) (h : 2 * L ≤ N) :
    (seedCompressibleFinset N L).card * 2 ^ (N - 2 * L) ≤ 2 ^ N := by
  classical
  have h1 : (seedCompressibleFinset N L).card ≤ 2 ^ (2 * L) := by
    have h4 : (4 : ℕ) ^ L = 2 ^ (2 * L) := by
      rw [show (4 : ℕ) = 2 ^ 2 from rfl, ← pow_mul, mul_comm]
    rw [← h4]
    exact card_seedCompressible_le N L
  calc (seedCompressibleFinset N L).card * 2 ^ (N - 2 * L)
      ≤ 2 ^ (2 * L) * 2 ^ (N - 2 * L) := Nat.mul_le_mul_right _ h1
    _ = 2 ^ N := by rw [← pow_add]; congr 1; omega

/-- **The classifier is not vacuous.**  Once the file is longer than the seed
budget, some file is rejected by the detector. -/
theorem exists_not_seedCompressible (N L : ℕ) (h : 2 * L < N) :
    ∃ w : Bits N, ¬ IsSeedCompressible N L w := by
  classical
  by_contra hcon
  push_neg at hcon
  have huniv : (univ : Finset (Bits N)) ⊆ seedCompressibleFinset N L := by
    intro w _
    simp only [seedCompressibleFinset, mem_filter]
    exact ⟨mem_univ _, hcon w⟩
  have hc : (2 : ℕ) ^ N ≤ 2 ^ (2 * L) := by
    have h1 := card_le_card huniv
    have h2 := card_seedCompressible_le N L
    rw [card_univ, card_bits] at h1
    calc (2 : ℕ) ^ N ≤ 4 ^ L := le_trans h1 h2
      _ = 2 ^ (2 * L) := by
          rw [show (4 : ℕ) = 2 ^ 2 from rfl, ← pow_mul]
  have : (2 : ℕ) ^ (2 * L) < 2 ^ N := Nat.pow_lt_pow_right (by omega) h
  omega

/-! ### A concrete corpus: periodic files are seed-compressible -/

/-- The binary repeating register reproduces its seed cyclically. -/
theorem lfsrBits_unitTap (p : ℕ) (hp : 0 < p) (init : Fin p → Bool) (n : ℕ) :
    lfsrBits p (fun i => ofZ2 (unitTap p i)) init n = init ⟨n % p, Nat.mod_lt _ hp⟩ := by
  have htap : (fun i : Fin p => toZ2 (ofZ2 (unitTap p i : ZMod 2))) = unitTap p := by
    funext i
    by_cases h : (i : ℕ) = 0 <;> simp [unitTap, ofZ2, toZ2, h]
  rw [lfsrBits, htap, lfsrRun_unitTap p hp]
  exact ofZ2_toZ2 _

/-- **Every periodic file is seed-compressible.**  A file of length `N` whose
bits depend only on the index modulo `p` is produced by the order-`p` register
with taps `(1,0,…,0)` — hence, by `KC_lfsrDecoder_le`, it has a `2p`-bit
description.  Periodic and run-structured data in real corpora therefore lands
in the seed-compressible box of the router. -/
theorem isSeedCompressible_of_periodic {N p : ℕ} (hp : 0 < p) (w : Bits N)
    (hper : ∀ i : Fin N, ∀ h : (i : ℕ) % p < N, w i = w ⟨(i : ℕ) % p, h⟩) :
    IsSeedCompressible N p w := by
  by_cases hpN : p ≤ N
  · refine ⟨fun i => ofZ2 (unitTap p i), fun j : Fin p => w ⟨(j : ℕ), lt_of_lt_of_le j.isLt hpN⟩, ?_⟩
    intro i
    rw [lfsrBits_unitTap p hp]
    have hlt : (i : ℕ) % p < N := lt_of_lt_of_le (Nat.mod_lt _ hp) hpN
    exact hper i hlt
  · -- if the period exceeds the file length the file is its own seed
    push_neg at hpN
    refine ⟨fun i => ofZ2 (unitTap p i), fun j : Fin p => if h : (j : ℕ) < N then w ⟨j, h⟩ else false, ?_⟩
    intro i
    rw [lfsrBits_unitTap p hp]
    have hiN : (i : ℕ) < p := lt_trans i.isLt hpN
    have hmod : (i : ℕ) % p = (i : ℕ) := Nat.mod_eq_of_lt hiN
    simp only [hmod, dif_pos i.isLt]

/-! ### Sample complexity of detection over `GF(2)` -/

lemma ofZ2_injective : Function.Injective ofZ2 := by
  decide

/-- Binary streams have complexity at most `L` when they come from an order-`L`
register. -/
lemma complexityLE_lfsrRun_toZ2 {L : ℕ} (c init : Fin L → Bool) :
    ComplexityLE L (lfsrRun (fun i => toZ2 (c i)) (fun i => toZ2 (init i))) :=
  ⟨_, lfsrRun_isLinRec _ _⟩

/-- **`2L` bits are enough to identify a binary register's output.**  Two
order-`L` binary LFSRs whose outputs agree on the first `2L` bits produce the
same infinite bitstream. -/
theorem lfsrBits_eq_of_agree_two_mul {L : ℕ} (c init c' init' : Fin L → Bool)
    (h : ∀ i : ℕ, i < 2 * L → lfsrBits L c init i = lfsrBits L c' init' i) (n : ℕ) :
    lfsrBits L c init n = lfsrBits L c' init' n := by
  have hstream :
      lfsrRun (fun i => toZ2 (c i)) (fun i => toZ2 (init i))
        = lfsrRun (fun i => toZ2 (c' i)) (fun i => toZ2 (init' i)) := by
    refine eq_of_complexityLE_of_agree_two_mul (complexityLE_lfsrRun_toZ2 c init)
      (complexityLE_lfsrRun_toZ2 c' init') ?_
    intro i hi
    exact ofZ2_injective (h i hi)
  show ofZ2 _ = ofZ2 _
  rw [congrFun hstream n]

/-- **A `2L`-bit observation window is a sound detector.**  If a file really is
`L`-seed compressible and a candidate register reproduces its first `2L` bits,
then that register reproduces the whole file.  Combined with
`seedCompressible_iff_decodable`, this is the practical recovery guarantee:
fit on `2L` bits, then replay and the replay is exact. -/
theorem detector_sound_from_2L_bits {N L : ℕ} (hNL : 2 * L ≤ N) (w : Bits N)
    (hw : IsSeedCompressible N L w) (c init : Fin L → Bool)
    (hfit : ∀ i : Fin N, (i : ℕ) < 2 * L → w i = lfsrBits L c init (i : ℕ)) :
    ∀ i : Fin N, w i = lfsrBits L c init (i : ℕ) := by
  obtain ⟨c', init', hci⟩ := hw
  intro i
  rw [hci i]
  refine (lfsrBits_eq_of_agree_two_mul c' init' c init ?_ (i : ℕ))
  intro j hj
  have hjN : j < N := lt_of_lt_of_le hj hNL
  have h1 := hci ⟨j, hjN⟩
  have h2 := hfit ⟨j, hjN⟩ hj
  rw [← h1, h2]

/-! ### Routing: the two boxes do not cover the space -/

open Classical in
/-- **Dichotomy for the router.**  Fix any decompressor `D` ("the model-based
branch").  If the seed budget `2L` and the modelling gain `d` are small enough
compared with the file length, some file is *neither* seed-compressible *nor*
compressible by `d` bits under `D`.  So a router with only the two boxes
"seed-compressible" and "model-compressible" necessarily leaves data behind:
the pigeonhole bound survives the addition of PRNG detection. -/
theorem classifier_dichotomy {N : ℕ} (L d : ℕ) (D : List Bool → Bits N)
    (hD : Function.Surjective D)
    (hbudget : 2 ^ d * 2 ^ (2 * L) + 2 ^ (N + 1) < 2 ^ d * 2 ^ N) :
    ∃ w : Bits N, ¬ IsSeedCompressible N L w ∧ ¬ (KC D w + d ≤ N) := by
  classical
  set A := seedCompressibleFinset N L with hA
  set B := univ.filter (fun w : Bits N => KC D w + d ≤ N) with hB
  have hcardA : A.card ≤ 2 ^ (2 * L) := by
    have h4 : (4 : ℕ) ^ L = 2 ^ (2 * L) := by
      rw [show (4 : ℕ) = 2 ^ 2 from rfl, ← pow_mul, mul_comm]
    rw [hA, ← h4]
    exact card_seedCompressible_le N L
  have hcardB : 2 ^ d * B.card ≤ 2 ^ (N + 1) := KC_compressible_count d D hD
  have hlt : (A ∪ B).card < (univ : Finset (Bits N)).card := by
    have h1 : (A ∪ B).card ≤ A.card + B.card := card_union_le _ _
    have h2 : 2 ^ d * (A.card + B.card) < 2 ^ d * 2 ^ N := by
      calc 2 ^ d * (A.card + B.card) = 2 ^ d * A.card + 2 ^ d * B.card := by ring
        _ ≤ 2 ^ d * 2 ^ (2 * L) + 2 ^ (N + 1) := by
            exact Nat.add_le_add (Nat.mul_le_mul_left _ hcardA) hcardB
        _ < 2 ^ d * 2 ^ N := hbudget
    have h3 : A.card + B.card < 2 ^ N :=
      lt_of_mul_lt_mul_left h2 (Nat.zero_le _)
    rw [card_univ, card_bits]
    omega
  obtain ⟨w, -, hw⟩ := Finset.exists_mem_notMem_of_card_lt_card hlt
  refine ⟨w, fun hs => hw ?_, fun hk => hw ?_⟩
  · refine mem_union_left _ ?_
    rw [hA]
    simp only [seedCompressibleFinset, mem_filter]
    exact ⟨mem_univ _, hs⟩
  · refine mem_union_right _ ?_
    rw [hB]
    simp only [mem_filter]
    exact ⟨mem_univ _, hk⟩

/-- A concrete instance of the dichotomy: among 64-bit files, whatever
decompressor is used on the model branch, some file is neither the output of an
order-8 LFSR (a 16-bit seed) nor compressible by 4 bits. -/
theorem not_seedCompressible_and_hard_64 (D : List Bool → Bits 64)
    (hD : Function.Surjective D) :
    ∃ w : Bits 64, ¬ IsSeedCompressible 64 8 w ∧ ¬ (KC D w + 4 ≤ 64) := by
  refine classifier_dichotomy 8 4 D hD ?_
  norm_num

end PRNGSeed