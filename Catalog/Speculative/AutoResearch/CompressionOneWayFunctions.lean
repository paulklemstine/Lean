/-
Copyright (c) 2025. All rights reserved.

# Compression and One-Way Functions

## Overview

This file develops a fully formal, finitary account of the folklore link between
**compression** (finding short descriptions of strings) and **cryptographic
hardness** (inverting one-way functions).  It is the Phase-B/Milestone-M8
component of the research programme *Compression Beyond the Pigeonhole Bound*:
its purpose is to calibrate exactly how far randomness (and, more generally,
computational power) can push a compressor.

The development has four layers.

### 1. Description systems and the pigeonhole ceiling

A *decompressor* is any map `D : Str → α` from bit strings to objects.  The
complexity `K D y` is the length of a shortest `D`-program for `y`.  The
counting theorem `card_le_of_K_le` says: at most `2^(s+1) - 1` objects have
complexity `≤ s`.  This is the information-theoretic ceiling; no amount of
computational power moves it.

### 2. Randomness: the seed-budget theorem

`card_le_of_K_le_seeded` shows that a *seeded* (randomized) family of
decompressors indexed by a finite seed space `R` compresses at most
`|R| * (2^(s+1) - 1)` objects to `s` bits, i.e. randomness buys at most
`log₂|R| + 1` bits.  `seeded_prefix_covers` gives a matching construction
achieving exactly `log₂|R|` bits.  Together (`randomness_gain_exact`) they pin
down the worst-case value of randomness for compression: **exactly the seed
length, and no more**.

### 3. Compression search ⇋ inversion

`ShortestFinder D A` is the *compression-search task*: `A` must output a
shortest `D`-program for every describable `y` (the finitary analogue of
solving MINKT / computing `K^t` with a witness).  `Inverts f A` is the
*inversion task*.  The two are shown to be equivalent relative to any class of
algorithms closed under length guarding and bounded search:

* `shortestFinder_inverts` : compression search is at least as hard as inversion;
* `searchFinder_correct`   : inverters for the length-guarded functions
  `guardFun f l` can be combined, by a bounded linear search over the guard
  length, into a genuine shortest-program finder;
* `inversion_iff_shortest_compression` : the two tasks are equivalent for a
  `SearchClosedClass`;
* `owf_iff_compression_hard` : **one-way functions exist iff the
  compression-search problem is hard**.

### 4. Consequences for achievable worst-case bounds

`owf_description_gap` isolates the phenomenon that motivates the whole
programme: under a one-way function, there are strings whose short descriptions
*provably exist* (indeed have length bounded by an allowed resource bound) and
which *no efficient algorithm ever outputs*.  Combined with the pigeonhole
ceiling this gives the calibration statement `compression_calibration`.

All results are proved from scratch; there are no axioms and no `sorry`.
-/
import Mathlib

namespace CompressionOWF

/-- Bit strings. -/
abbrev Str := List Bool

/-! ## Section 0: A concrete injective code for bit strings

We need the elementary fact that there are fewer than `2^(s+1)` bit strings of
length at most `s`.  Rather than importing a counting instance we build the
standard "leading one" numeral, which turns a bit string into a positive
natural number, injectively, with `natCode p < 2^(|p|+1)`. -/

/-- Binary code of a bit list as a positive natural number (leading-one convention). -/
def natCode : Str → ℕ
  | [] => 1
  | b :: t => 2 * natCode t + (if b then 1 else 0)

lemma natCode_pos (p : Str) : 0 < natCode p := by
  induction p with
  | nil => simp [natCode]
  | cons b t ih => simp only [natCode]; split <;> omega

lemma natCode_lt (p : Str) : natCode p < 2 ^ (p.length + 1) := by
  induction p with
  | nil => simp [natCode]
  | cons b t ih =>
      simp only [natCode, List.length_cons]
      have h : (2 : ℕ) ^ (t.length + 1 + 1) = 2 * 2 ^ (t.length + 1) := by ring
      rw [h]
      split <;> omega

lemma natCode_injective : Function.Injective natCode := by
  intro p
  induction p with
  | nil =>
      intro q hq
      cases q with
      | nil => rfl
      | cons b t =>
          exfalso
          have := natCode_pos t
          simp only [natCode] at hq
          split at hq <;> omega
  | cons a s ih =>
      intro q hq
      cases q with
      | nil =>
          exfalso
          have := natCode_pos s
          simp only [natCode] at hq
          split at hq <;> omega
      | cons b t =>
          simp only [natCode] at hq
          have hab : a = b := by
            by_contra h
            cases a <;> cases b <;> simp_all <;> omega
          subst hab
          have hst : natCode s = natCode t := by cases a <;> simp at hq <;> omega
          rw [ih hst]

/-! ## Section 1: Description systems and Kolmogorov-style complexity -/

section Complexity

variable {α : Type*}

/-- `y` is describable under the decompressor `D` if some program outputs it. -/
def Describable (D : Str → α) (y : α) : Prop := ∃ p : Str, D p = y

/-- Kolmogorov-style complexity of `y` relative to the decompressor `D`:
the length of a shortest `D`-program for `y` (`0` if `y` is not describable). -/
noncomputable def K (D : Str → α) (y : α) : ℕ :=
  sInf {n | ∃ p : Str, p.length = n ∧ D p = y}

lemma K_le_of_eq {D : Str → α} {p : Str} {y : α} (h : D p = y) : K D y ≤ p.length :=
  Nat.sInf_le ⟨p, rfl, h⟩

/-- A describable object has a program of length exactly `K D y`. -/
lemma exists_shortest {D : Str → α} {y : α} (h : Describable D y) :
    ∃ p : Str, p.length = K D y ∧ D p = y := by
  obtain ⟨p, hp⟩ := h
  have hne : {n | ∃ p : Str, p.length = n ∧ D p = y}.Nonempty := ⟨p.length, p, rfl, hp⟩
  obtain ⟨q, hq1, hq2⟩ := Nat.sInf_mem hne
  exact ⟨q, hq1, hq2⟩

lemma compressible_iff {D : Str → α} {y : α} {s : ℕ} :
    (∃ p : Str, p.length ≤ s ∧ D p = y) ↔ Describable D y ∧ K D y ≤ s := by
  constructor
  · rintro ⟨p, hlen, hp⟩
    exact ⟨⟨p, hp⟩, le_trans (K_le_of_eq hp) hlen⟩
  · rintro ⟨hd, hK⟩
    obtain ⟨p, hlen, hp⟩ := exists_shortest hd
    exact ⟨p, hlen ▸ hK, hp⟩

/-- **The pigeonhole ceiling.**  At most `2^(s+1) - 1` objects have
`D`-complexity at most `s`, for any decompressor `D` whatsoever. -/
theorem card_le_of_K_le (D : Str → α) (s : ℕ) (T : Finset α)
    (hT : ∀ y ∈ T, Describable D y ∧ K D y ≤ s) : T.card ≤ 2 ^ (s + 1) - 1 := by
  classical
  have key : ∀ y : α, ∃ p : Str, y ∈ T → (p.length ≤ s ∧ D p = y) := by
    intro y
    by_cases hy : y ∈ T
    · obtain ⟨p, hp1, hp2⟩ := compressible_iff.2 (hT y hy)
      exact ⟨p, fun _ => ⟨hp1, hp2⟩⟩
    · exact ⟨[], fun h => absurd h hy⟩
  choose prog hprog using key
  rw [← Finset.card_range (2 ^ (s + 1) - 1)]
  apply Finset.card_le_card_of_injOn (fun y => natCode (prog y) - 1)
  · intro y hy
    have h1 := (hprog y hy).1
    have h2 : natCode (prog y) < 2 ^ (s + 1) :=
      lt_of_lt_of_le (natCode_lt _) (Nat.pow_le_pow_right (by norm_num) (by omega))
    have h3 := natCode_pos (prog y)
    have : natCode (prog y) - 1 < 2 ^ (s + 1) - 1 := by omega
    simpa using this
  · intro y hy z hz h
    have h3 := natCode_pos (prog y)
    have h4 := natCode_pos (prog z)
    simp only at h
    have heq : natCode (prog y) = natCode (prog z) := by omega
    have := natCode_injective heq
    rw [← (hprog y hy).2, ← (hprog z hz).2, this]

/-- **Seed-budget theorem.**  A randomized (seeded) family of decompressors with
seed space `R` compresses at most `|R| * (2^(s+1) - 1)` objects to `s` bits.
Thus randomness buys at most `log₂|R| + 1` bits in the worst case. -/
theorem card_le_of_K_le_seeded {R : Type*} [Fintype R] [DecidableEq R]
    (D : R → Str → α) (s : ℕ) (T : Finset α)
    (hT : ∀ y ∈ T, ∃ r : R, Describable (D r) y ∧ K (D r) y ≤ s) :
    T.card ≤ Fintype.card R * (2 ^ (s + 1) - 1) := by
  classical
  rcases Finset.eq_empty_or_nonempty T with rfl | ⟨y0, hy0⟩
  · simp
  obtain ⟨r0, -⟩ := hT y0 hy0
  have hne : Nonempty (R × Str) := ⟨(r0, [])⟩
  have key : ∀ y : α, ∃ rp : R × Str, y ∈ T → (rp.2.length ≤ s ∧ D rp.1 rp.2 = y) := by
    intro y
    by_cases hy : y ∈ T
    · obtain ⟨r, hr⟩ := hT y hy
      obtain ⟨p, hp1, hp2⟩ := compressible_iff.2 hr
      exact ⟨(r, p), fun _ => ⟨hp1, hp2⟩⟩
    · exact ⟨(Classical.arbitrary (R × Str)), fun h => absurd h hy⟩
  choose w hw using key
  have hcard : ((Finset.univ : Finset R) ×ˢ Finset.range (2 ^ (s + 1) - 1)).card
      = Fintype.card R * (2 ^ (s + 1) - 1) := by
    rw [Finset.card_product, Finset.card_range, Finset.card_univ]
  rw [← hcard]
  apply Finset.card_le_card_of_injOn (fun y => ((w y).1, natCode (w y).2 - 1))
  · intro y hy
    have h1 := (hw y hy).1
    have h2 : natCode (w y).2 < 2 ^ (s + 1) :=
      lt_of_lt_of_le (natCode_lt _) (Nat.pow_le_pow_right (by norm_num) (by omega))
    have h3 := natCode_pos (w y).2
    have h4 : natCode (w y).2 - 1 < 2 ^ (s + 1) - 1 := by omega
    simpa using h4
  · intro y hy z hz h
    have h3 := natCode_pos (w y).2
    have h4 := natCode_pos (w z).2
    simp only [Prod.mk.injEq] at h
    have hseed : (w y).1 = (w z).1 := h.1
    have heq : natCode (w y).2 = natCode (w z).2 := by omega
    have hprog := natCode_injective heq
    rw [← (hw y hy).2, ← (hw z hz).2, hseed, hprog]

end Complexity

/-! ## Section 2: The pigeonhole bound is attained, and randomness gains exactly
the seed length -/

/-- The finite set of all bit strings of a given length. -/
def bitStrings (n : ℕ) : Finset Str :=
  Finset.image (fun v : Fin n → Bool => List.ofFn v) Finset.univ

lemma mem_bitStrings {n : ℕ} {y : Str} : y ∈ bitStrings n ↔ y.length = n := by
  constructor
  · rintro hy
    obtain ⟨v, -, rfl⟩ := Finset.mem_image.1 hy
    simp
  · intro hy
    refine Finset.mem_image.2 ⟨fun i : Fin n => y[(i : ℕ)]'(by omega), Finset.mem_univ _, ?_⟩
    subst hy
    exact List.ofFn_getElem y

lemma card_bitStrings (n : ℕ) : (bitStrings n).card = 2 ^ n := by
  rw [bitStrings, Finset.card_image_of_injective _ List.ofFn_injective]
  simp

/-- **Incompressible strings exist.**  For any decompressor, some string of
length `s + 1` has complexity exceeding `s`: the pigeonhole ceiling is real. -/
theorem exists_incompressible (D : Str → Str) (s : ℕ) :
    ∃ y : Str, y.length = s + 1 ∧ ¬ (Describable D y ∧ K D y ≤ s) := by
  by_contra hcon
  push_neg at hcon
  have hall : ∀ y ∈ bitStrings (s + 1), Describable D y ∧ K D y ≤ s := by
    intro y hy
    exact hcon y (mem_bitStrings.1 hy)
  have h1 := card_le_of_K_le D s (bitStrings (s + 1)) hall
  rw [card_bitStrings] at h1
  have h2 : 0 < 2 ^ (s + 1) := Nat.two_pow_pos _
  omega

/-- The seeded family of "prefix decompressors": the seed supplies the first
`k` bits, the program supplies the rest. -/
def prefixSys (r : Str) : Str → Str := fun p => r ++ p

/-- **Matching construction.**  With `2^k` seeds (all seeds of length `k`),
every string of length `k + s` is compressed to `s` bits. -/
theorem seeded_prefix_covers (k s : ℕ) (y : Str) (hy : y.length = k + s) :
    ∃ r : Str, r.length = k ∧ Describable (prefixSys r) y ∧ K (prefixSys r) y ≤ s := by
  refine ⟨y.take k, by simp [hy], ⟨y.drop k, by simp [prefixSys]⟩, ?_⟩
  have hlen : (y.drop k).length ≤ s := by simp [hy]
  exact le_trans (K_le_of_eq (show prefixSys (y.take k) (y.drop k) = y by simp [prefixSys])) hlen

/-- **Randomness helps exactly by the seed length.**

*Lower bound*: `2^k` seeds compress all `2^(k+s)` strings of length `k+s` down
to `s` bits — a gain of exactly `k` bits over the unseeded ceiling.

*Upper bound*: no seeded family with seed space `R` compresses more than
`|R| * (2^(s+1) - 1)` objects to `s` bits.

So the worst-case value of randomness for compression is the seed length, up to
one bit, and no computational assumption can change this. -/
theorem randomness_gain_exact (k s : ℕ) :
    (∀ y ∈ bitStrings (k + s), ∃ r : Str,
        r.length = k ∧ Describable (prefixSys r) y ∧ K (prefixSys r) y ≤ s)
    ∧ (bitStrings (k + s)).card = 2 ^ k * 2 ^ s
    ∧ (∀ (R : Type) (_ : Fintype R) (_ : DecidableEq R) (D : R → Str → Str) (T : Finset Str),
        (∀ y ∈ T, ∃ r : R, Describable (D r) y ∧ K (D r) y ≤ s) →
        T.card ≤ Fintype.card R * (2 ^ (s + 1) - 1)) := by
  refine ⟨fun y hy => seeded_prefix_covers k s y (mem_bitStrings.1 hy), ?_, ?_⟩
  · rw [card_bitStrings, pow_add]
  · intro R _ _ D T hT
    exact card_le_of_K_le_seeded D s T hT

/-! ## Section 3: Compression search and inversion -/

/-- `A` inverts `f`: on every value in the range of `f` it produces a preimage. -/
def Inverts (f A : Str → Str) : Prop := ∀ y : Str, Describable f y → f (A y) = y

/-- `A` solves the **compression-search problem** for the decompressor `D`: on
every describable `y` it outputs a *shortest* `D`-program for `y`. -/
def ShortestFinder (D A : Str → Str) : Prop :=
  ∀ y : Str, Describable D y → D (A y) = y ∧ (A y).length = K D y

/-- Compression search is at least as hard as inversion: a shortest-program
finder for the decompressor `f` is in particular an inverter for `f`. -/
theorem shortestFinder_inverts {D A : Str → Str} (h : ShortestFinder D A) : Inverts D A :=
  fun y hy => (h y hy).1

/-- The length-guarded version of `f`: programs longer than `l` are rejected
(and echoed back with a `false` tag), accepted outputs carry a `true` tag. -/
def guardFun (f : Str → Str) (l : ℕ) : Str → Str :=
  fun p => if p.length ≤ l then true :: f p else false :: p

/-- Bounded linear search: the least `l ≤ fuel` with `P l`, computed with `fuel`
steps. -/
def leastFrom (P : ℕ → Bool) : ℕ → ℕ
  | 0 => 0
  | fuel + 1 => if P 0 then 0 else leastFrom (fun k => P (k + 1)) fuel + 1

lemma leastFrom_spec (P : ℕ → Bool) (fuel : ℕ) (h : ∃ l ≤ fuel, P l = true) :
    P (leastFrom P fuel) = true ∧ ∀ m < leastFrom P fuel, P m = false := by
  induction fuel generalizing P with
  | zero =>
      obtain ⟨l, hl, hP⟩ := h
      interval_cases l
      simp [leastFrom, hP]
  | succ n ih =>
      cases hb : P 0 with
      | true => simp [leastFrom, hb]
      | false =>
          have h' : ∃ l ≤ n, (fun k => P (k + 1)) l = true := by
            obtain ⟨l, hl, hP⟩ := h
            cases l with
            | zero => rw [hb] at hP; exact absurd hP (by simp)
            | succ m => exact ⟨m, by omega, hP⟩
          obtain ⟨hA, hB⟩ := ih (fun k => P (k + 1)) h'
          have hval : leastFrom P (n + 1) = leastFrom (fun k => P (k + 1)) n + 1 := by
            simp [leastFrom, hb]
          refine ⟨by rw [hval]; exact hA, ?_⟩
          intro m hm
          rw [hval] at hm
          cases m with
          | zero => exact hb
          | succ j => exact hB j (by omega)

/-- The compressor assembled from inverters `A l` for the guarded functions
`guardFun f l`: search for the least guard length that succeeds, then output the
program the corresponding inverter produced. -/
def searchFinder (f : Str → Str) (A : ℕ → Str → Str) (fuel : ℕ → ℕ) : Str → Str :=
  fun y =>
    A (leastFrom (fun l => decide (guardFun f l (A l (true :: y)) = true :: y)) (fuel y.length))
      (true :: y)

/-- **Inversion solves compression search.**  If every guarded function
`guardFun f l` can be inverted, then `searchFinder` outputs a *shortest*
`f`-program for every describable `y` whose complexity is within the fuel. -/
theorem searchFinder_correct (f : Str → Str) (A : ℕ → Str → Str) (fuel : ℕ → ℕ)
    (hA : ∀ l, Inverts (guardFun f l) (A l)) (y : Str) (hy : Describable f y)
    (hfuel : K f y ≤ fuel y.length) :
    f (searchFinder f A fuel y) = y ∧ (searchFinder f A fuel y).length = K f y := by
  have hsf : searchFinder f A fuel y =
      A (leastFrom (fun l => decide (guardFun f l (A l (true :: y)) = true :: y))
        (fuel y.length)) (true :: y) := rfl
  rw [hsf]
  set P : ℕ → Bool := fun l => decide (guardFun f l (A l (true :: y)) = true :: y) with hP
  have hkey : ∀ l, P l = true ↔ K f y ≤ l := by
    intro l
    constructor
    · intro hl
      have h : guardFun f l (A l (true :: y)) = true :: y := by simpa [hP] using hl
      set q := A l (true :: y) with hq
      by_cases hlen : q.length ≤ l
      · have hfq : f q = y := by
          simp only [guardFun, if_pos hlen] at h
          simpa using h
        exact le_trans (K_le_of_eq hfq) hlen
      · simp only [guardFun, if_neg hlen] at h
        exact absurd h (by simp)
    · intro hl
      obtain ⟨p, hplen, hpf⟩ := exists_shortest hy
      have hdesc : Describable (guardFun f l) (true :: y) := by
        refine ⟨p, ?_⟩
        have hp : p.length ≤ l := by omega
        simp [guardFun, hp, hpf]
      have := hA l (true :: y) hdesc
      simpa [hP] using this
  have hex : ∃ l ≤ fuel y.length, P l = true := ⟨K f y, hfuel, (hkey _).2 le_rfl⟩
  obtain ⟨hgot, hmin⟩ := leastFrom_spec P (fuel y.length) hex
  set l0 := leastFrom P (fuel y.length) with hl0
  have hKle : K f y ≤ l0 := (hkey l0).1 hgot
  have hl0le : l0 ≤ K f y := by
    by_contra hcon
    push_neg at hcon
    have hfalse := hmin (K f y) hcon
    rw [(hkey (K f y)).2 le_rfl] at hfalse
    exact absurd hfalse (by simp)
  have hl0eq : l0 = K f y := le_antisymm hl0le hKle
  have h : guardFun f l0 (A l0 (true :: y)) = true :: y := by simpa [hP] using hgot
  set q := A l0 (true :: y) with hq
  by_cases hlen : q.length ≤ l0
  · have hfq : f q = y := by
      simp only [guardFun, if_pos hlen] at h
      simpa using h
    refine ⟨hfq, ?_⟩
    have h1 : K f y ≤ q.length := K_le_of_eq hfq
    have h2 : q.length ≤ K f y := hl0eq ▸ hlen
    omega
  · simp only [guardFun, if_neg hlen] at h
    exact absurd h (by simp)

/-! ## Section 4: Classes of algorithms, one-way functions, and the equivalence -/

/-- An abstract class of algorithms, closed under the two operations used by the
reduction: length guarding, and bounded search over the guard length.  The
predicate `AllowedFuel` models the admissible resource bounds (think:
polynomials); it must contain constants and the identity and be closed under
pointwise maximum. -/
structure SearchClosedClass where
  /-- The algorithms of the class. -/
  Comp : Set (Str → Str)
  /-- The admissible resource (fuel) bounds. -/
  AllowedFuel : (ℕ → ℕ) → Prop
  allowed_const : ∀ c : ℕ, AllowedFuel (fun _ => c)
  allowed_id : AllowedFuel (fun n => n)
  allowed_max : ∀ b₁ b₂, AllowedFuel b₁ → AllowedFuel b₂ →
    AllowedFuel (fun n => max (b₁ n) (b₂ n))
  guard_mem : ∀ f ∈ Comp, ∀ l : ℕ, guardFun f l ∈ Comp
  search_mem : ∀ f ∈ Comp, ∀ A : ℕ → Str → Str, (∀ l, A l ∈ Comp) →
    ∀ b, AllowedFuel b → searchFinder f A b ∈ Comp

/-- `f` is *honest* for the class: every describable value has a program whose
length is within an admissible bound.  (Real candidate one-way functions are
honest: preimages are of polynomially related length.) -/
def HonestIn (C : SearchClosedClass) (f : Str → Str) : Prop :=
  ∃ b, C.AllowedFuel b ∧ ∀ y : Str, Describable f y → K f y ≤ b y.length

/-- Guarded functions inherit honesty, with bound `max l n`. -/
lemma honest_guardFun (C : SearchClosedClass) (f : Str → Str) (l : ℕ) :
    HonestIn C (guardFun f l) := by
  refine ⟨fun n => max l n, C.allowed_max _ _ (C.allowed_const l) C.allowed_id, ?_⟩
  rintro y ⟨p, hp⟩
  show K (guardFun f l) y ≤ max l y.length
  have h1 : K (guardFun f l) y ≤ p.length := K_le_of_eq hp
  by_cases hlen : p.length ≤ l
  · exact le_trans h1 (le_trans hlen (le_max_left _ _))
  · have h2 : y.length = p.length + 1 := by
      rw [← hp]; simp [guardFun, if_neg hlen]
    exact le_trans h1 (le_trans (by omega : p.length ≤ y.length) (le_max_right l y.length))

/-- `f` is a one-way function for the class `C`. -/
def OneWayIn (C : SearchClosedClass) (f : Str → Str) : Prop :=
  f ∈ C.Comp ∧ HonestIn C f ∧ ∀ A ∈ C.Comp, ¬ Inverts f A

/-- The compression-search problem for `D` is hard for the class `C`. -/
def CompressionSearchHard (C : SearchClosedClass) (D : Str → Str) : Prop :=
  D ∈ C.Comp ∧ HonestIn C D ∧ ∀ A ∈ C.Comp, ¬ ShortestFinder D A

/-- **Main equivalence.**  For any class closed under length guarding and
bounded search, *inverting all honest functions* is equivalent to *solving the
compression-search (shortest-program) problem for all honest decompressors*.

This is the precise sense in which compression is the same task as inverting
one-way functions. -/
theorem inversion_iff_shortest_compression (C : SearchClosedClass) :
    (∀ f ∈ C.Comp, HonestIn C f → ∃ A ∈ C.Comp, Inverts f A) ↔
    (∀ f ∈ C.Comp, HonestIn C f → ∃ A ∈ C.Comp, ShortestFinder f A) := by
  constructor
  · intro hinv f hf hhon
    obtain ⟨b, hb, hbound⟩ := hhon
    have hstep : ∀ l : ℕ, ∃ A : Str → Str, A ∈ C.Comp ∧ Inverts (guardFun f l) A := by
      intro l
      obtain ⟨A, hA1, hA2⟩ :=
        hinv (guardFun f l) (C.guard_mem f hf l) (honest_guardFun C f l)
      exact ⟨A, hA1, hA2⟩
    choose A hAmem hAinv using hstep
    refine ⟨searchFinder f A b, C.search_mem f hf A hAmem b hb, ?_⟩
    intro y hy
    exact searchFinder_correct f A b hAinv y hy (hbound y hy)
  · intro hcomp f hf hhon
    obtain ⟨A, hA1, hA2⟩ := hcomp f hf hhon
    exact ⟨A, hA1, shortestFinder_inverts hA2⟩

/-- **One-way functions exist iff compression search is hard.**

Left to right: a one-way function is itself a decompressor whose
shortest-program problem is unsolvable in the class.  Right to left: if every
honest function were invertible, the bounded-search reduction would solve every
compression-search problem. -/
theorem owf_iff_compression_hard (C : SearchClosedClass) :
    (∃ f, OneWayIn C f) ↔ (∃ D, CompressionSearchHard C D) := by
  constructor
  · rintro ⟨f, hf, hhon, hhard⟩
    exact ⟨f, hf, hhon, fun A hA hS => hhard A hA (shortestFinder_inverts hS)⟩
  · rintro ⟨D, hD, hhon, hhard⟩
    by_contra hcon
    push_neg at hcon
    have hinv : ∀ f ∈ C.Comp, HonestIn C f → ∃ A ∈ C.Comp, Inverts f A := by
      intro f hf hh
      have := hcon f
      rw [OneWayIn] at this
      simp only [hf, hh, true_and, not_forall] at this
      obtain ⟨A, hA⟩ := this
      simp only [not_not] at hA
      obtain ⟨hA1, hA2⟩ := hA
      exact ⟨A, hA1, hA2⟩
    obtain ⟨A, hA1, hA2⟩ :=
      (inversion_iff_shortest_compression C).1 hinv D hD hhon
    exact hhard A hA1 hA2

/-! ## Section 5: Consequences for achievable worst-case bounds -/

/-- **The description gap under a one-way function.**  If `f` is one-way for the
class `C`, then for *every* algorithm `A` of the class there is a string `y`
which has a short description (of length within an admissible bound) that `A`
fails to produce.  Short descriptions exist; they are not findable. -/
theorem owf_description_gap (C : SearchClosedClass) (f : Str → Str) (hf : OneWayIn C f) :
    ∃ b, C.AllowedFuel b ∧ ∀ A ∈ C.Comp, ∃ y : Str,
      Describable f y ∧ K f y ≤ b y.length ∧ f (A y) ≠ y := by
  obtain ⟨-, ⟨b, hb, hbound⟩, hhard⟩ := hf
  refine ⟨b, hb, ?_⟩
  intro A hA
  have := hhard A hA
  rw [Inverts] at this
  push_neg at this
  obtain ⟨y, hy1, hy2⟩ := this
  exact ⟨y, hy1, hbound y hy1, hy2⟩

/-- **Calibration theorem.**  The three regimes of compression, in one
statement, for any class `C` and any target length `s`:

1. *Information-theoretic ceiling* (unconditional): at most `2^(s+1) - 1`
   strings can be compressed to `s` bits by any decompressor, and some string of
   length `s+1` is not compressible at all;
2. *Randomness*: a seeded family with seed space `R` raises this only to
   `|R| * (2^(s+1) - 1)`, and the gain `log₂|R|` is achieved;
3. *Computational boundary*: if a one-way function exists for `C`, there are
   strings with short descriptions that no algorithm of `C` ever outputs.

Together: randomness helps compression exactly up to the seed length, and
efficient compression additionally stops at the cryptographic hardness
boundary. -/
theorem compression_calibration (C : SearchClosedClass) (s k : ℕ)
    (hOWF : ∃ f, OneWayIn C f) :
    (∀ (D : Str → Str) (T : Finset Str),
        (∀ y ∈ T, Describable D y ∧ K D y ≤ s) → T.card ≤ 2 ^ (s + 1) - 1)
    ∧ (∀ D : Str → Str, ∃ y : Str, y.length = s + 1 ∧ ¬ (Describable D y ∧ K D y ≤ s))
    ∧ (∀ y ∈ bitStrings (k + s), ∃ r : Str,
        r.length = k ∧ Describable (prefixSys r) y ∧ K (prefixSys r) y ≤ s)
    ∧ (∃ D, CompressionSearchHard C D) := by
  refine ⟨fun D T hT => card_le_of_K_le D s T hT, fun D => exists_incompressible D s,
    fun y hy => seeded_prefix_covers k s y (mem_bitStrings.1 hy), ?_⟩
  exact (owf_iff_compression_hard C).1 hOWF

/-- The equivalence is not vacuous: classes satisfying the closure axioms exist
(e.g. the class of *all* functions, with all fuel bounds allowed).  In that
class no one-way function exists, and — consistently with the main theorem —
every honest decompressor admits a shortest-program finder. -/
def fullClass : SearchClosedClass where
  Comp := Set.univ
  AllowedFuel := fun _ => True
  allowed_const := fun _ => trivial
  allowed_id := trivial
  allowed_max := fun _ _ _ _ => trivial
  guard_mem := fun _ _ _ => Set.mem_univ _
  search_mem := fun _ _ _ _ _ _ => Set.mem_univ _

theorem fullClass_no_owf : ¬ ∃ f, OneWayIn fullClass f := by
  rintro ⟨f, -, -, hhard⟩
  classical
  refine hhard (fun y => if h : Describable f y then h.choose else []) trivial ?_
  intro y hy
  simp only [dif_pos hy]
  exact hy.choose_spec

theorem fullClass_compression_easy :
    ∀ f ∈ fullClass.Comp, HonestIn fullClass f → ∃ A ∈ fullClass.Comp, ShortestFinder f A := by
  intro f hf hhon
  refine (inversion_iff_shortest_compression fullClass).1 ?_ f hf hhon
  intro g _ _
  classical
  refine ⟨fun y => if h : Describable g y then h.choose else [], trivial, ?_⟩
  intro y hy
  simp only [dif_pos hy]
  exact hy.choose_spec

/-! ### A class in which a one-way function genuinely exists

The equivalence would be vacuous if the closure axioms of `SearchClosedClass`
forced every function to be invertible.  They do not: the class of
length-nondecreasing algorithms is closed under guarding and bounded search, and
the tagging function `p ↦ true :: p` is one-way for it (any inverter must delete
a bit, which the class forbids).  Consequently, by `owf_iff_compression_hard`,
the compression-search problem is hard for that class as well. -/

/-- Algorithms that never shorten their input. -/
def lengthClass : SearchClosedClass where
  Comp := {g : Str → Str | ∀ p : Str, p.length ≤ (g p).length}
  AllowedFuel := fun _ => True
  allowed_const := fun _ => trivial
  allowed_id := trivial
  allowed_max := fun _ _ _ _ => trivial
  guard_mem := by
    intro f hf l p
    by_cases hp : p.length ≤ l
    · have := hf p
      simp only [guardFun, if_pos hp, List.length_cons]
      omega
    · simp [guardFun, if_neg hp]
  search_mem := by
    intro f _ A hA b _ y
    have := hA (leastFrom
      (fun l => decide (guardFun f l (A l (true :: y)) = true :: y)) (b y.length)) (true :: y)
    simp only [List.length_cons] at this
    exact le_trans (by omega) this

/-- The tagging function: prepend a `true` bit. -/
def tagTrue : Str → Str := fun p => true :: p

/-- `tagTrue` is a one-way function for `lengthClass`: inverting it requires
deleting a bit, which no algorithm of the class can do. -/
theorem tagTrue_oneway : OneWayIn lengthClass tagTrue := by
  refine ⟨fun p => by simp [tagTrue], ⟨fun n => n, trivial, ?_⟩, ?_⟩
  · rintro y ⟨p, hp⟩
    have h1 : K tagTrue y ≤ p.length := K_le_of_eq hp
    have h2 : y.length = p.length + 1 := by rw [← hp]; simp [tagTrue]
    show K tagTrue y ≤ y.length
    omega
  · intro A hA hinv
    have hdesc : Describable tagTrue [true] := ⟨[], rfl⟩
    have h := hinv [true] hdesc
    have hlen : ([true] : Str).length ≤ (A [true]).length := hA [true]
    have : A [true] = [] := by
      have := h
      simp only [tagTrue, List.cons.injEq] at this
      exact this.2
    rw [this] at hlen
    simp at hlen

/-- Consequently the compression-search problem is hard for `lengthClass`:
there is a decompressor of the class for which no algorithm of the class ever
outputs shortest programs. -/
theorem lengthClass_compression_hard : ∃ D, CompressionSearchHard lengthClass D :=
  (owf_iff_compression_hard lengthClass).1 ⟨tagTrue, tagTrue_oneway⟩

end CompressionOWF