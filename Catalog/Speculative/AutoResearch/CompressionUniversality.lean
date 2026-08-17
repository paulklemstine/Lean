/-
Copyright (c) 2025. All rights reserved.

# Universal Description Systems, Derandomization, and Robustness of the
# Compression ⇋ One-Way-Function Equivalence

## Overview

This file is the second cycle of the Phase-B/M8 investigation begun in
`Shared.CompressionOneWayFunctions`.  There we proved

* the pigeonhole ceiling and its seeded (randomized) refinement, and
* the equivalence "inverting one-way functions ⇔ solving the
  compression-search (shortest-program) problem".

Here we build the missing structural layer and push the calibration further.

### 1. Self-delimiting codes and universality

`unaryTag`/`parseUnary` and `sdPair`/`parseSD` are prefix-free encodings with
verified parsing lemmas.  They yield:

* `K_univSys_le` — the **invariance theorem** in finitary form: a single
  universal decompressor simulates a whole family at an additive cost equal to
  the length of the index;
* `K_pairSys_le` — **subadditivity**: describing `x ++ y` costs at most
  `2·K x + 1 + K y`.

### 2. Derandomization: buying back randomness at the seed price

`derandomization_cost` shows that a seeded family of decompressors is simulated
by *one* deterministic decompressor at additive cost `2k + 1` for `k`-bit seeds.
Combined with `card_le_of_K_le_seeded` (which says randomness can never buy more
than `log₂|R| + 1` bits) this closes the loop: **the value of randomness for
compression is its seed length, and it is always purchasable deterministically
at that same price, up to a factor two.**

### 3. Most strings are incompressible

`density_incompressible`: for every decompressor, at most a `2^{-(c-1)}`
fraction of the strings of length `n` have complexity `≤ n - c`.

### 4. Robustness of the cryptographic equivalence

`inversion_iff_approx_compression`: the equivalence with inversion survives an
*arbitrary additive slack* `δ` in the compression task.  Finding descriptions
that are merely within `δ(n)` bits of optimal is still exactly as hard as
inverting one-way functions.  Consequently `owf_gap_universal` shows that
switching to a universal description system does not close the gap between
*existing* and *findable* descriptions.

No axioms beyond the standard three, and no `sorry`.
-/
import Shared.CompressionOneWayFunctions

namespace CompressionOWF

/-! ## Section 1: Self-delimiting codes -/

/-- The index `i` in unary, a separating `false`, then the program `p`. -/
def unaryTag (i : ℕ) (p : Str) : Str := List.replicate i true ++ (false :: p)

/-- Parse a unary prefix: returns the length of the leading run of `true`s and
the remainder after the separating `false`. -/
def parseUnary : Str → ℕ × Str
  | [] => (0, [])
  | false :: r => (0, r)
  | true :: r => ((parseUnary r).1 + 1, (parseUnary r).2)

lemma parseUnary_unaryTag (i : ℕ) (p : Str) : parseUnary (unaryTag i p) = (i, p) := by
  induction i with
  | zero => simp [unaryTag, parseUnary]
  | succ n ih =>
      have h : unaryTag (n + 1) p = true :: unaryTag n p := by
        simp [unaryTag, List.replicate_succ]
      rw [h]
      simp [parseUnary, ih]

lemma unaryTag_length (i : ℕ) (p : Str) : (unaryTag i p).length = i + 1 + p.length := by
  simp [unaryTag]; omega

/-- Self-delimiting pairing: the length of `p` in unary, then `p ++ q`. -/
def sdPair (p q : Str) : Str := unaryTag p.length (p ++ q)

/-- The matching parser for `sdPair`. -/
def parseSD (z : Str) : Str × Str :=
  ((parseUnary z).2.take (parseUnary z).1, (parseUnary z).2.drop (parseUnary z).1)

lemma parseSD_sdPair (p q : Str) : parseSD (sdPair p q) = (p, q) := by
  simp [parseSD, sdPair, parseUnary_unaryTag]

lemma sdPair_length (p q : Str) : (sdPair p q).length = 2 * p.length + 1 + q.length := by
  simp [sdPair, unaryTag_length]; omega

/-! ## Section 2: Universal decompressors and the invariance theorem -/

/-- The universal decompressor for a family `D` indexed by `ℕ`: the program
carries its index in unary. -/
def univSys (D : ℕ → Str → Str) : Str → Str :=
  fun z => D (parseUnary z).1 (parseUnary z).2

/-- **Invariance theorem.**  A single universal decompressor simulates every
member of the family at an additive cost of `i + 1` bits. -/
theorem K_univSys_le (D : ℕ → Str → Str) (i : ℕ) (y : Str) (hy : Describable (D i) y) :
    K (univSys D) y ≤ K (D i) y + i + 1 := by
  obtain ⟨p, hplen, hpy⟩ := exists_shortest hy
  have hdec : univSys D (unaryTag i p) = y := by
    simp [univSys, parseUnary_unaryTag, hpy]
  have := K_le_of_eq hdec
  rw [unaryTag_length] at this
  omega

/-- Describability transfers to the universal system. -/
theorem describable_univSys (D : ℕ → Str → Str) (i : ℕ) (y : Str)
    (hy : Describable (D i) y) : Describable (univSys D) y := by
  obtain ⟨p, hp⟩ := hy
  exact ⟨unaryTag i p, by simp [univSys, parseUnary_unaryTag, hp]⟩

/-- Conversely, everything describable in the universal system is describable in
one member of the family. -/
theorem describable_univSys_iff (D : ℕ → Str → Str) (y : Str) :
    Describable (univSys D) y ↔ ∃ i, Describable (D i) y := by
  constructor
  · rintro ⟨z, hz⟩
    exact ⟨(parseUnary z).1, (parseUnary z).2, hz⟩
  · rintro ⟨i, hi⟩
    exact describable_univSys D i y hi

/-! ## Section 3: Subadditivity of complexity -/

/-- The product decompressor: split the program self-delimitingly and
concatenate the two outputs. -/
def pairSys (D₁ D₂ : Str → Str) : Str → Str :=
  fun z => D₁ (parseSD z).1 ++ D₂ (parseSD z).2

/-- **Subadditivity.**  Describing a concatenation costs at most the sum of the
two costs plus the self-delimiting overhead. -/
theorem K_pairSys_le (D₁ D₂ : Str → Str) (x y : Str)
    (hx : Describable D₁ x) (hy : Describable D₂ y) :
    K (pairSys D₁ D₂) (x ++ y) ≤ 2 * K D₁ x + 1 + K D₂ y := by
  obtain ⟨p, hplen, hpx⟩ := exists_shortest hx
  obtain ⟨q, hqlen, hqy⟩ := exists_shortest hy
  have hdec : pairSys D₁ D₂ (sdPair p q) = x ++ y := by
    simp [pairSys, parseSD_sdPair, hpx, hqy]
  have := K_le_of_eq hdec
  rw [sdPair_length] at this
  omega

/-! ## Section 4: Derandomization at the seed price -/

/-- A decompressor family indexed by *bit strings* (seeds), packaged into a
single decompressor by self-delimiting the seed. -/
def indexSys (D : Str → Str → Str) : Str → Str :=
  fun z => D (parseSD z).1 (parseSD z).2

/-- **Derandomization cost.**  A seeded family is simulated by one deterministic
decompressor at additive cost `2k + 1` for `k`-bit seeds.  Together with
`card_le_of_K_le_seeded` (randomness never buys more than `log₂|R| + 1` bits),
this pins the value of randomness for compression to the seed length. -/
theorem derandomization_cost (D : Str → Str → Str) (r y : Str)
    (hy : Describable (D r) y) :
    K (indexSys D) y ≤ 2 * r.length + 1 + K (D r) y := by
  obtain ⟨p, hplen, hpy⟩ := exists_shortest hy
  have hdec : indexSys D (sdPair r p) = y := by
    simp [indexSys, parseSD_sdPair, hpy]
  have := K_le_of_eq hdec
  rw [sdPair_length] at this
  omega

/-- Explicit form for `k`-bit seeds: whatever a `2^k`-seed randomized compressor
achieves at length `s`, a single deterministic decompressor achieves at length
`2k + 1 + s`. -/
theorem derandomization_of_seeded (D : Str → Str → Str) (k s : ℕ) (y : Str)
    (r : Str) (hr : r.length = k) (hy : Describable (D r) y) (hs : K (D r) y ≤ s) :
    Describable (indexSys D) y ∧ K (indexSys D) y ≤ 2 * k + 1 + s := by
  refine ⟨?_, ?_⟩
  · obtain ⟨p, hp⟩ := hy
    exact ⟨sdPair r p, by simp [indexSys, parseSD_sdPair, hp]⟩
  · have := derandomization_cost D r y hy
    omega

/-! ## Section 5: Most strings are incompressible -/

open scoped Classical in
/-- **Density of incompressibility.**  For any decompressor at most a
`2^{-(c-1)}` fraction of the `2^n` strings of length `n` can be compressed to
`n - c` bits. -/
theorem density_incompressible (D : Str → Str) (n c : ℕ) (hc : 1 ≤ c) (hcn : c ≤ n) :
    2 ^ (c - 1) *
        ((bitStrings n).filter (fun y => Describable D y ∧ K D y ≤ n - c)).card
      ≤ (bitStrings n).card := by
  set m := ((bitStrings n).filter (fun y => Describable D y ∧ K D y ≤ n - c)).card with hm
  have hbound : m ≤ 2 ^ (n - c + 1) - 1 := by
    refine card_le_of_K_le D (n - c) _ ?_
    intro y hy
    exact (Finset.mem_filter.1 hy).2
  have hsplit : 2 ^ (c - 1) * 2 ^ (n - c + 1) = 2 ^ n := by
    rw [← pow_add]
    congr 1
    omega
  calc 2 ^ (c - 1) * m ≤ 2 ^ (c - 1) * (2 ^ (n - c + 1) - 1) := by
        exact Nat.mul_le_mul_left _ hbound
    _ ≤ 2 ^ (c - 1) * 2 ^ (n - c + 1) := by
        exact Nat.mul_le_mul_left _ (Nat.sub_le _ _)
    _ = 2 ^ n := hsplit
    _ = (bitStrings n).card := (card_bitStrings n).symm

/-! ## Section 6: Robustness of the cryptographic equivalence -/

/-- An *approximate* compression-search solver: it must output a valid program
whose length is within `δ` of optimal. -/
def ApproxShortestFinder (D A : Str → Str) (δ : ℕ → ℕ) : Prop :=
  ∀ y : Str, Describable D y → D (A y) = y ∧ (A y).length ≤ K D y + δ y.length

theorem approxFinder_inverts {D A : Str → Str} {δ : ℕ → ℕ}
    (h : ApproxShortestFinder D A δ) : Inverts D A :=
  fun y hy => (h y hy).1

theorem shortestFinder_isApprox {D A : Str → Str} (δ : ℕ → ℕ)
    (h : ShortestFinder D A) : ApproxShortestFinder D A δ := by
  intro y hy
  obtain ⟨h1, h2⟩ := h y hy
  exact ⟨h1, by omega⟩

/-- **Robustness of the equivalence.**  For *any* additive slack `δ`, solving the
approximate compression-search problem for all honest decompressors of a class
is equivalent to inverting all honest functions of that class.  Approximation
does not make short-program finding easier than breaking one-way functions. -/
theorem inversion_iff_approx_compression (C : SearchClosedClass) (δ : ℕ → ℕ) :
    (∀ f ∈ C.Comp, HonestIn C f → ∃ A ∈ C.Comp, Inverts f A) ↔
    (∀ f ∈ C.Comp, HonestIn C f → ∃ A ∈ C.Comp, ApproxShortestFinder f A δ) := by
  constructor
  · intro hinv f hf hhon
    obtain ⟨A, hA1, hA2⟩ := (inversion_iff_shortest_compression C).1 hinv f hf hhon
    exact ⟨A, hA1, shortestFinder_isApprox δ hA2⟩
  · intro happ f hf hhon
    obtain ⟨A, hA1, hA2⟩ := happ f hf hhon
    exact ⟨A, hA1, approxFinder_inverts hA2⟩

/-- **One-way functions ⇔ hardness of approximate compression search.** -/
theorem owf_iff_approx_compression_hard (C : SearchClosedClass) (δ : ℕ → ℕ) :
    (∃ f, OneWayIn C f) ↔
    (∃ D, D ∈ C.Comp ∧ HonestIn C D ∧ ∀ A ∈ C.Comp, ¬ ApproxShortestFinder D A δ) := by
  constructor
  · rintro ⟨f, hf, hhon, hhard⟩
    exact ⟨f, hf, hhon, fun A hA hS => hhard A hA (approxFinder_inverts hS)⟩
  · rintro ⟨D, hD, hhon, hhard⟩
    by_contra hcon
    push_neg at hcon
    have hinv : ∀ f ∈ C.Comp, HonestIn C f → ∃ A ∈ C.Comp, Inverts f A := by
      intro f hf hh
      have hnot := hcon f
      rw [OneWayIn] at hnot
      simp only [hf, hh, true_and, not_forall] at hnot
      obtain ⟨A, hA⟩ := hnot
      simp only [not_not] at hA
      exact ⟨A, hA.1, hA.2⟩
    obtain ⟨A, hA1, hA2⟩ :=
      (inversion_iff_approx_compression C δ).1 hinv D hD hhon
    exact hhard A hA1 hA2

/-- **Universality does not close the gap.**  If `f` is one-way for `C` and `f`
occurs in a family `D`, then for every algorithm of the class there is a string
whose description is short *even in the universal system* (within `i + 1` bits
of its `f`-complexity) and which the algorithm still fails to describe. -/
theorem owf_gap_universal (C : SearchClosedClass) (f : Str → Str) (hf : OneWayIn C f)
    (D : ℕ → Str → Str) (i : ℕ) (hDi : D i = f) :
    ∃ b, C.AllowedFuel b ∧ ∀ A ∈ C.Comp, ∃ y : Str,
      Describable f y ∧ K (univSys D) y ≤ b y.length + i + 1 ∧ f (A y) ≠ y := by
  obtain ⟨b, hb, hgap⟩ := owf_description_gap C f hf
  refine ⟨b, hb, ?_⟩
  intro A hA
  obtain ⟨y, hy1, hy2, hy3⟩ := hgap A hA
  refine ⟨y, hy1, ?_, hy3⟩
  have hDy : Describable (D i) y := by rw [hDi]; exact hy1
  have h1 := K_univSys_le D i y hDy
  rw [hDi] at h1
  omega

end CompressionOWF