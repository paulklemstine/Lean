import Mathlib

/-!
# Seed-compressibility: a generic framework for PRNG detection and seed recovery

This file develops the abstract theory behind the question *"is this file PRNG
output, and if so, what was the seed?"*.

A deterministic pseudorandom generator is a pair `(step, out)` on a state space
`S` producing a symbol stream in `α`.  A finite word `x : Fin n → α` is
**seed-compressible** for the generator if some seed reproduces it exactly:
this is the falsifiability gate of the research programme (the decompressed
output must equal the file bit-for-bit).

Main contents.

* `PRNG`, `PRNG.stream`, `PRNG.pref` — generator, its output stream, its
  length-`n` prefix (the "file" it would produce).
* `SeedCompressible` — the exact-reproduction predicate.
* `PRNG.compressible` — the finite set of seed-compressible words.
* `PRNG.card_compressible_le` — **pigeonhole ceiling**: at most `|S|` of the
  `|α|ⁿ` words are seed-compressible.
* `PRNG.exists_not_seedCompressible` — hence, as soon as `|S| < |α|ⁿ`, some
  file is *not* seed-compressible: seed compression cannot beat the counting
  bound.
* `PRNG.density_le` — the density of seed-compressible files, i.e. the false
  positive rate of an ideal detector on uniformly random data.
* `PRNG.decode`, `PRNG.decode_pref` — the seed-recovery decoder and its exact
  round-trip guarantee.
* `PRNG.stream_eq_of_pref_eq_of_injective` — **extrapolation soundness**: if the
  prefix map is injective, agreement on the observed window forces agreement
  forever.
-/

namespace Catalog.Probability.SeedRec

universe u v

/-- A deterministic pseudorandom generator: a state transition together with an
output function. -/
structure PRNG (S : Type u) (α : Type v) where
  /-- The state transition of the generator. -/
  step : S → S
  /-- The output (extraction) function. -/
  out : S → α

variable {S : Type u} {α : Type v}

/-- The infinite output stream of the generator started at seed `s`. -/
def PRNG.stream (g : PRNG S α) (s : S) (t : ℕ) : α := g.out (g.step^[t] s)

/-- The length-`n` prefix produced from seed `s` — the "file" the generator writes. -/
def PRNG.pref (g : PRNG S α) (n : ℕ) (s : S) : Fin n → α := fun i => g.stream s i

@[simp] theorem PRNG.stream_zero (g : PRNG S α) (s : S) : g.stream s 0 = g.out s := rfl

theorem PRNG.stream_succ (g : PRNG S α) (s : S) (t : ℕ) :
    g.stream s (t + 1) = g.stream (g.step s) t := by
  simp [PRNG.stream, Function.iterate_succ_apply]

theorem PRNG.stream_add (g : PRNG S α) (s : S) (t k : ℕ) :
    g.stream s (t + k) = g.stream (g.step^[t] s) k := by
  simp only [PRNG.stream, Nat.add_comm t k, Function.iterate_add_apply]

/-- `x` is seed-compressible for `g` if some seed reproduces it exactly. -/
def SeedCompressible (g : PRNG S α) (n : ℕ) (x : Fin n → α) : Prop :=
  ∃ s : S, g.pref n s = x

theorem seedCompressible_iff (g : PRNG S α) (n : ℕ) (x : Fin n → α) :
    SeedCompressible g n x ↔ ∃ s : S, ∀ i : Fin n, g.stream s i = x i := by
  simp [SeedCompressible, funext_iff, PRNG.pref]

section Finite

variable [Fintype S] [Fintype α] [DecidableEq α]

/-- The finite set of all seed-compressible words of length `n`. -/
def PRNG.compressible (g : PRNG S α) (n : ℕ) : Finset (Fin n → α) :=
  Finset.univ.image (g.pref n)

omit [Fintype α] in
@[simp] theorem PRNG.mem_compressible {g : PRNG S α} {n : ℕ} {x : Fin n → α} :
    x ∈ g.compressible n ↔ SeedCompressible g n x := by
  simp [PRNG.compressible, SeedCompressible, eq_comm]

omit [Fintype α] in
/-- **Pigeonhole ceiling for seed compression.** At most `|S|` words of any
length are reproducible from a seed. -/
theorem PRNG.card_compressible_le (g : PRNG S α) (n : ℕ) :
    (g.compressible n).card ≤ Fintype.card S := by
  simpa [PRNG.compressible, Finset.card_univ] using
    Finset.card_image_le (s := (Finset.univ : Finset S)) (f := g.pref n)

/-- As soon as the seed space is smaller than the file space, some file is not
seed-compressible. -/
theorem PRNG.exists_not_seedCompressible (g : PRNG S α) (n : ℕ)
    (h : Fintype.card S < Fintype.card α ^ n) :
    ∃ x : Fin n → α, ¬ SeedCompressible g n x := by
  by_contra hc
  push_neg at hc
  have hsub : (Finset.univ : Finset (Fin n → α)) ⊆ g.compressible n := by
    intro x _
    simpa using hc x
  have hcard : Fintype.card α ^ n ≤ (g.compressible n).card := by
    have := Finset.card_le_card hsub
    simpa [Finset.card_univ, Fintype.card_fun] using this
  exact absurd (hcard.trans (g.card_compressible_le n)) (by omega)

/-- **False-positive density.** The fraction of length-`n` files accepted by a
perfect seed-compressibility detector is at most `|S| / |α|ⁿ`. -/
theorem PRNG.density_le (g : PRNG S α) (n : ℕ) (hα : 0 < Fintype.card α) :
    ((g.compressible n).card : ℚ) / (Fintype.card α ^ n : ℚ)
      ≤ (Fintype.card S : ℚ) / (Fintype.card α ^ n : ℚ) := by
  have hcard : (0 : ℚ) < (Fintype.card α : ℚ) := by exact_mod_cast hα
  have hpos : (0 : ℚ) < (Fintype.card α : ℚ) ^ n := by positivity
  gcongr
  exact_mod_cast g.card_compressible_le n

end Finite

/-- Seed recovery: a decoder that produces a seed reproducing the observed file. -/
noncomputable def PRNG.decode (g : PRNG S α) {n : ℕ} {x : Fin n → α}
    (h : SeedCompressible g n x) : S := h.choose

/-- **Exact reproduction gate.** The recovered seed reproduces the observed
file bit-for-bit. -/
@[simp] theorem PRNG.decode_pref (g : PRNG S α) {n : ℕ} {x : Fin n → α}
    (h : SeedCompressible g n x) : g.pref n (g.decode h) = x := h.choose_spec

/-- **Extrapolation soundness.** If the length-`n` prefix map is injective then
two seeds agreeing on the observed window generate the *same infinite stream*:
seed recovery from `n` symbols determines the whole file, of any length. -/
theorem PRNG.stream_eq_of_pref_eq_of_injective (g : PRNG S α) {n : ℕ}
    (hinj : Function.Injective (g.pref n)) {s s' : S} (h : g.pref n s = g.pref n s') :
    ∀ t, g.stream s t = g.stream s' t := by
  intro t; rw [hinj h]

/-- With an injective prefix map the recovered seed is *the* seed: uniqueness of
seed recovery. -/
theorem PRNG.decode_eq_of_injective (g : PRNG S α) {n : ℕ}
    (hinj : Function.Injective (g.pref n)) {s : S}
    (h : SeedCompressible g n (g.pref n s)) : g.decode h = s :=
  hinj (g.decode_pref h)

end Catalog.Probability.SeedRec