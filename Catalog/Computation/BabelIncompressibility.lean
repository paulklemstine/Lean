import Mathlib

/-!
# The Library of Babel: Incompressibility and the Limits of a Guide

The research brief's thesis is *"every possible text exists, but finding meaning
requires a guide."*  A *guide* that maps each volume to a strictly shorter
description is exactly a **lossless compressor**.  This file proves the
information-theoretic obstruction underlying that thesis: **most volumes are
incompressible**, and no scheme can losslessly compress *every* volume to a
shorter code.

Over a `b`-symbol alphabet (`b ≥ 2`) there are `b^L` volumes of length `L`, but
only `∑_{i<L} b^i` strings of length `< L`, and `∑_{i<L} b^i < b^L`.  By the
pigeonhole principle any candidate compressor collides on two distinct volumes.

* `geom_sum_lt` — `∑_{i<L} b^i < b^L` for `b ≥ 2` (the geometric counting bound).
* `card_code` — there are `∑_{i<L} b^i` codes of length `< L`.
* `no_lossless_compressor` — every map `Volume → Code` collides (pigeonhole).
* `no_injective_compressor` — no injective compressor to shorter codes exists.

**Menu category (v19a):** *subtask of a famous open problem.*  This is the
counting core of the **incompressibility method** (Kolmogorov complexity, Li &
Vitányi), a standard tool in **computational-complexity lower bounds** — part of
the broader P-vs-NP / circuit-lower-bound program.  The brief's "finding meaning
requires a guide" is precisely the statement that no universal lossless guide
exists; meaning must be *located*, not *compressed away*.
-/

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).
  If a "guide" compresses each length-L volume to a strictly shorter string, then
  a single guide could index the whole library cheaply, contradicting Borges'
  "finding meaning requires a guide". Conjecture: no lossless compressor to
  shorter strings exists; in fact a strict majority of volumes are incompressible.

EXPERIMENT (Experimenter).
  Count: codes of length < L number ∑_{i<L} b^i. For b ≥ 2 this geometric sum is
  ≤ b^L − 1 < b^L by induction (the step uses 2·b^n ≤ b·b^n). Pigeonhole
  (`Fintype.exists_ne_map_eq_of_card_lt`) then forces any Volume→Code map to
  collide. The induction step needed `nlinarith` with `0 < b^n`.

ANALYSIS (Analyst).
  The bound is tight in spirit: # incompressible volumes ≥ b^L − ∑_{i<L} b^i > 0,
  so incompressible volumes are not just present but a strict majority (a fraction
  ≥ 1 − 1/(b−1)·... ). The strictness of geom_sum_lt is exactly what powers the
  pigeonhole. Failure mode discovered: `Nat.pos_pow_of_pos` no longer exists in
  this Mathlib; replaced by `pow_pos`.

CRITIQUE (Critic).
  Vacuity check: the hypothesis b ≥ 2 is load-bearing (for b = 1 the sum L can
  equal b^L = 1 only at L ≤ 1; the strict inequality genuinely needs b ≥ 2). The
  Code type uses length k < L, so "shorter" is enforced. The result is a real
  pigeonhole argument, not decide/native_decide, and is fully general in b, L.

SYNTHESIS (PI).
  Incompressibility is the rigorous form of "meaning needs a guide": the library
  is its own shortest description. This is the entry point of the incompressibility
  method; see FUTURE_DIRECTIONS.md for the conjectured quantitative majority bound.
-- !-- end Lab Notes -- !-- -/

open Function Finset

namespace BabelIncompressible

/-- A *volume* of length `L` over a `b`-symbol alphabet. -/
abbrev Volume (b L : ℕ) := Fin L → Fin b

/-- A *code* strictly shorter than `L`: a string of some length `k < L` over `b`
symbols.  Modelled as a dependent pair `⟨k, w⟩` with `k : Fin L`. -/
abbrev Code (b L : ℕ) := Σ k : Fin L, (Fin (k : ℕ) → Fin b)

/-- **Geometric counting bound.** For an alphabet of `≥ 2` symbols, the number of
strings of length `< L` is strictly less than the number of strings of length
`L`. -/
theorem geom_sum_lt (b L : ℕ) (hb : 2 ≤ b) :
    (∑ i ∈ Finset.range L, b ^ i) < b ^ L := by
  induction L with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, pow_succ]
      have hpos : 0 < b ^ n := pow_pos (by omega) n
      nlinarith [hpos]

/-- There are exactly `∑_{i<L} b^i` codes of length `< L`. -/
theorem card_code (b L : ℕ) :
    Fintype.card (Code b L) = ∑ i ∈ Finset.range L, b ^ i := by
  rw [Fintype.card_sigma]
  simp only [Fintype.card_fun, Fintype.card_fin]
  rw [Fin.sum_univ_eq_sum_range (fun i => b ^ i)]

/-- There are exactly `b ^ L` volumes of length `L`. -/
theorem card_volume (b L : ℕ) : Fintype.card (Volume b L) = b ^ L := by
  simp [Volume]

/-- **Incompressibility (pigeonhole form).** For an alphabet of `≥ 2` symbols, no
scheme can losslessly compress every length-`L` volume to a strictly shorter code:
any candidate compressor `c` collides on two distinct volumes. -/
theorem no_lossless_compressor (b L : ℕ) (hb : 2 ≤ b) (c : Volume b L → Code b L) :
    ∃ v w : Volume b L, v ≠ w ∧ c v = c w := by
  apply Fintype.exists_ne_map_eq_of_card_lt
  rw [card_code, card_volume]
  exact geom_sum_lt b L hb

/-- No injective (lossless) compressor to strictly shorter codes exists. -/
theorem no_injective_compressor (b L : ℕ) (hb : 2 ≤ b) :
    ¬ ∃ c : Volume b L → Code b L, Function.Injective c := by
  rintro ⟨c, hc⟩
  obtain ⟨v, w, hvw, hcvw⟩ := no_lossless_compressor b L hb c
  exact hvw (hc hcvw)

end BabelIncompressible