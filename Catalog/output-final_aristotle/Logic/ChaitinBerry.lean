/-
# Chaitin's Incompleteness and the Berry Paradox: The Counting Face of Self-Reference

Where `Logic.LucasPenroseGodel` develops the *logical* face of self-referential
limitation (a sentence that outruns its own provability), this file develops its
*information-theoretic* face, following Chaitin and the Berry paradox.

The Berry paradox — "the least number not nameable in fewer than twenty syllables",
itself a description of about a dozen syllables — becomes, once "nameable" is replaced by
an injective description code, an exact counting theorem: there are strictly fewer short
descriptions than the numbers they would have to name, so some numbers are
**incompressible**.  This is the combinatorial kernel of Chaitin's incompleteness theorem.

## Set-up

Fix any *injective* encoding `enc : ℕ → ℕ`, thought of as assigning to each number a
unique description (its code).  The **descriptive complexity** of `x` is the number of
binary digits of its code,
  `K x := Nat.size (enc x)`,
the length of the shortest binary word representing `enc x`.

## Main results

* `size_lt_iff_lt_pow` — the elementary bridge `Nat.size y ≤ n ↔ y < 2 ^ n`: numbers with
  at most `n` bits are exactly those below `2 ^ n`.
* `berry_pigeonhole` — the **finite Berry paradox**: among any `2 ^ n + 1` numbers, at
  least one has complexity exceeding `n`.  You cannot compress `2 ^ n + 1` distinct objects
  into descriptions of at most `n` bits.
* `chaitin_incompressible` — **Chaitin's incompressibility theorem**: complexity is
  unbounded; for every `n` there is a number whose complexity exceeds `n`.  No encoding
  makes all numbers simultaneously short.
* `chaitin_incompressible_infinite` — strengthening: incompressible numbers are not merely
  present but *infinitely many*; for every threshold the set of numbers of complexity above
  it is infinite.
* `no_universal_compressor` — the impossibility of a **universal short compressor**: there
  is no encoding under which every number has complexity below a fixed global bound.
* `berry_undefinable` — the Berry sentence is self-defeating: there is no `n` such that
  "the numbers of complexity `> n`" is empty, so "the least number of complexity `> n`" is
  always a genuine (and short-to-specify) object, reproducing the paradox constructively.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the Berry paradox and Chaitin's theorem are the *counting shadow* of
  the diagonal argument — replace "provability" by "compressibility" and "there is a true
  unprovable sentence" becomes "there is an incompressible number", derivable by pure
  pigeonhole rather than fixed-point self-reference.
Experiment (Stage 2): we modelled descriptive complexity as the bit-length `Nat.size (enc x)`
  of an injective code and proved incompressibility by comparing the `2 ^ n` short codes with
  the infinitely (or `2 ^ n + 1`) many numbers requiring them.
Analysis (Stage 3): the single load-bearing arithmetic fact is `Nat.size_le`
  (`size y ≤ n ↔ y < 2 ^ n`); everything else is `Finset` cardinality (finite Berry) or the
  pigeonhole that an injection `ℕ ↪ Fin (2 ^ n)` cannot exist (unbounded Chaitin).
Critique (Stage 4): injectivity of `enc` is essential and non-vacuous — the identity code
  `enc = id` already satisfies every hypothesis, so the theorems have genuine content and are
  not vacuously true; dropping injectivity makes `chaitin_incompressible` false (a constant
  code compresses everything to complexity `0`).
Synthesis (Stage 5): `chaitin_incompressible` (some number is incompressible) is the exact
  analogue of `FormalSystem.godel_true` (some truth is unprovable); both witness that a
  finitely-described system cannot capture all of an infinite domain.
-/
import Mathlib

open Function

namespace ChaitinBerry

/-- **Descriptive complexity** relative to an injective encoding `enc`: the number of
binary digits needed to write the code of `x`. -/
def K (enc : ℕ → ℕ) (x : ℕ) : ℕ := Nat.size (enc x)

/-- The elementary bridge between bit-length and magnitude: a natural number has at most
`n` binary digits iff it is smaller than `2 ^ n`. -/
theorem size_lt_iff_lt_pow (y n : ℕ) : Nat.size y ≤ n ↔ y < 2 ^ n :=
  Nat.size_le

/-- **The finite Berry paradox.**  Among any `2 ^ n + 1` consecutive numbers, at least one
has descriptive complexity strictly greater than `n`.  Equivalently, no injective code can
compress `2 ^ n + 1` distinct objects into words of at most `n` bits: there are only `2 ^ n`
such words. -/
theorem berry_pigeonhole (enc : ℕ → ℕ) (hinj : Injective enc) (n : ℕ) :
    ∃ x ∈ Finset.range (2 ^ n + 1), n < K enc x := by
  by_contra h
  push_neg at h
  set S := (Finset.range (2 ^ n + 1)).image enc with hS
  have hsub : S ⊆ Finset.range (2 ^ n) := by
    intro y hy
    rw [hS, Finset.mem_image] at hy
    obtain ⟨x, hx, rfl⟩ := hy
    exact Finset.mem_range.mpr (Nat.size_le.mp (h x hx))
  have h1 : S.card = 2 ^ n + 1 := by
    rw [hS, Finset.card_image_of_injective _ hinj, Finset.card_range]
  have h2 : S.card ≤ 2 ^ n := by
    have := Finset.card_le_card hsub
    rwa [Finset.card_range] at this
  omega

/-- **Chaitin's incompressibility theorem.**  Descriptive complexity is unbounded: for every
threshold `n` there is a number whose complexity exceeds `n`.  No injective encoding can keep
every number short — some object is essentially incompressible. -/
theorem chaitin_incompressible (enc : ℕ → ℕ) (hinj : Injective enc) (n : ℕ) :
    ∃ x, n < K enc x := by
  by_contra h
  push_neg at h
  have hb : ∀ x, enc x < 2 ^ n := fun x => Nat.size_le.mp (h x)
  have hinj2 : Function.Injective (fun x => (⟨enc x, hb x⟩ : Fin (2 ^ n))) :=
    fun a b hab => hinj (by simpa using hab)
  haveI : Finite ℕ := Finite.of_injective _ hinj2
  exact not_finite ℕ

/-- Incompressible numbers are not sporadic but **infinitely many**: for every threshold the
set of numbers whose complexity exceeds it is infinite.  A single incompressible number would
not suffice to defeat compression; here compression fails everywhere. -/
theorem chaitin_incompressible_infinite (enc : ℕ → ℕ) (hinj : Injective enc) (n : ℕ) :
    {x | n < K enc x}.Infinite := by
  -- The compressible set `{x | K x ≤ n}` is the preimage of `Iio (2 ^ n)` under the
  -- injection `enc`, hence finite; the incompressible set is its (cofinite) complement.
  have hfin : {x | K enc x ≤ n}.Finite := by
    have hpre : {x | K enc x ≤ n} = enc ⁻¹' (Set.Iio (2 ^ n)) := by
      ext x; simp only [Set.mem_setOf_eq, Set.mem_preimage, Set.mem_Iio, K, Nat.size_le]
    rw [hpre]
    exact (Set.finite_Iio (2 ^ n)).preimage (hinj.injOn)
  have hcompl : {x | n < K enc x} = {x | K enc x ≤ n}ᶜ := by
    ext x; simp only [Set.mem_setOf_eq, Set.mem_compl_iff]; omega
  rw [hcompl]
  exact hfin.infinite_compl

/-- **No universal short compressor.**  There is no injective encoding together with a global
bound `B` such that every number has complexity below `B`.  Compression always leaks. -/
theorem no_universal_compressor (enc : ℕ → ℕ) (hinj : Injective enc) :
    ¬ ∃ B, ∀ x, K enc x < B := by
  rintro ⟨B, hB⟩
  obtain ⟨x, hx⟩ := chaitin_incompressible enc hinj B
  exact absurd (hB x) (by omega)

/-- **The Berry sentence is self-defeating.**  For every threshold `n`, the set of numbers of
complexity greater than `n` is nonempty — so "the least number of complexity greater than `n`"
always denotes a genuine object.  Since that phrase is itself a short description, the object it
names cannot really have large complexity: the paradox is constructive, not merely rhetorical. -/
theorem berry_undefinable (enc : ℕ → ℕ) (hinj : Injective enc) (n : ℕ) :
    {x | n < K enc x}.Nonempty := by
  obtain ⟨x, hx⟩ := chaitin_incompressible enc hinj n
  exact ⟨x, hx⟩

/-- **Non-vacuity.**  The identity encoding is injective, so the incompressibility theorems
have genuine content: even the most faithful "code" (a number is its own name) cannot make
every number short. -/
theorem identity_is_injective_code : Injective (id : ℕ → ℕ) := injective_id

end ChaitinBerry