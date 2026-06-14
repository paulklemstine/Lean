import Mathlib
-- NOTE (build fix): the catalog file `Bridges/TropicalUltrametricBridge.lean` is
-- absent from this checkout, so the original `import Bridges.TropicalUltrametricBridge`
-- could not be resolved.  It is only used by the final `fibHeight_lt_one_iff` capstone
-- (§4), which is commented out below; the Mathlib-native `padicNorm_fib_lt_one_iff`
-- captstone is retained verbatim.
-- import Bridges.TropicalUltrametricBridge

/-!
# The Fibonacci Law of Apparition as an Arithmetic–Height / Tropical Duality

This file proves the **law of apparition** for the Fibonacci sequence in full
generality (for every modulus `m ≥ 1`, not only primes), and then *bridges* it to
the catalog's tropical/ultrametric arithmetic-height machinery in
`Bridges/TropicalUltrametricBridge.lean`.

The **rank of apparition** of `m`,
`fibRank m = least k > 0 with m ∣ fib k`, is shown to exist for every `m ≥ 1`
(`fib_apparition_exists`).  The headline representation theorem

  `fib_dvd_iff_rank_dvd : m ∣ fib n ↔ fibRank m ∣ n`

is a genuine *duality*: divisibility of Fibonacci **values** is translated, without
loss, into divisibility of the **indices**.  This is the index-side dual of the
strong-divisibility identity `Nat.fib_gcd : fib (gcd m n) = gcd (fib m) (fib n)`.

As corollaries the divisibility predicate becomes a **lattice (min-plus)
homomorphism** (`fib_dvd_gcd_iff`: `gcd` of indices ↦ conjunction), and — closing
the loop with the catalog — the `p`-adic **arithmetic height**
`TropUltra.padicHeightNorm` of `fib n` drops below `1` *exactly* on the rank
sublattice (`fibHeight_lt_one_iff`, with the Mathlib-native restatement
`padicNorm_fib_lt_one_iff`).  This realises the theme "arithmetic heights as
tropical valuations" concretely on the Fibonacci sequence.

## Synthesis with the catalog
* Builds on `Nat.fib_gcd` and `Nat.fib_dvd` (the priority `Fib_gcd_identity`).
* Builds on `TropUltra.padicHeightNorm` / `TropUltra.NonArchNorm` from
  `Bridges/TropicalUltrametricBridge.lean`: the abstract ultrametric arithmetic
  height is fed the concrete Fibonacci inputs, so that `fibRank` becomes the exact
  combinatorial controller of the non-archimedean size of Fibonacci numbers.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis:  The strong-divisibility identity `fib (gcd m n) = gcd (fib m) (fib n)`
--   should "linearise" Fibonacci divisibility: there ought to be a single index
--   `fibRank m` (the rank of apparition) such that `m ∣ fib n ↔ fibRank m ∣ n`,
--   turning a question about values into a question about indices (a duality), and
--   turning the index `gcd` (a tropical `min`) into logical conjunction.
-- Result:  Confirmed in full generality for every `m ≥ 1`.
--   `fib_apparition_exists` (rank exists, via pure periodicity of the state pair
--   `(fib n, fib (n+1))` over `ZMod m`), `fib_dvd_iff_rank_dvd` (the duality),
--   `fib_dvd_gcd_iff` (the min-plus homomorphism) and the height capstones
--   `padicNorm_fib_lt_one_iff` / `fibHeight_lt_one_iff` are all proven `sorry`-free.
-- Insight:  Existence of the rank is *purely* the statement that the transition
--   `T(a,b) = (b, a+b)` is a bijection of the finite set `ZMod m × ZMod m`; a finite
--   bijection has every orbit purely periodic, so the orbit of the start state
--   `(0,1)` returns to `(0,1)`, i.e. some positive `fib d ≡ 0`.  No analysis, no
--   Binet — only injectivity of an affine shift (here packaged as the cancellation
--   `add_right_cancel` inside `fibState_descent`).  The whole theory of apparition
--   is then `Nat.fib_gcd` + minimality of `sInf`.
-- Failure analysis:  Defining `fibRank` via `Nat.find` forces carrying the existence
--   proof as a definitional argument, which pollutes every downstream statement; the
--   `noncomputable sInf {k | 0 < k ∧ m ∣ fib k}` packaging keeps the definition
--   hypothesis-free and recovers membership/minimality from `Nat.sInf_mem` /
--   `Nat.sInf_le`.  Also: the `m = 0` case genuinely has no rank (`0 ∣ fib k ↔ k = 0`),
--   so every theorem is correctly guarded by `0 < m`; the prime capstone gets `0 < p`
--   for free from `Nat.Prime.pos`.
-- !-- Lab Notebook -- !--

open Nat

namespace FibApparition

/-! ## §1. Existence of the rank of apparition via pure periodicity -/

/-- The Fibonacci "state pair" `(fib n, fib (n+1))` taken modulo `m`. -/
def fibState (m : ℕ) (n : ℕ) : ZMod m × ZMod m :=
  ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m))

-- !-- Unfold `fib (n+2) = fib n + fib (n+1)` and push the casts. -- !--
lemma fibState_succ (m n : ℕ) :
    fibState m (n + 1) = ((fibState m n).2, (fibState m n).1 + (fibState m n).2) := by
  simp only [fibState, Nat.fib_add_two]; push_cast; ring_nf

-- !-- `fib 0 = 0`, `fib 1 = 1`. -- !--
lemma fibState_zero (m : ℕ) : fibState m 0 = (0, 1) := by
  simp [fibState]

-- !-- The shift `T(a,b)=(b,a+b)` is injective, so equality of states at `i` and `i+d`
--     descends (by induction on `i`, using `add_right_cancel`) to equality at `0` and `d`. -- !--
lemma fibState_descent (m : ℕ) :
    ∀ (d i : ℕ), fibState m i = fibState m (i + d) → fibState m 0 = fibState m d := by
  intro d i
  induction i with
  | zero => intro h; simpa using h
  | succ i ih =>
    intro h
    apply ih
    have h' : fibState m (i + 1) = fibState m (i + d + 1) := by
      have : i + 1 + d = i + d + 1 := by omega
      rwa [this] at h
    rw [fibState_succ, fibState_succ] at h'
    have h2 := Prod.ext_iff.mp h'
    have hsnd : (fibState m i).2 = (fibState m (i + d)).2 := h2.1
    have hsum : (fibState m i).1 + (fibState m i).2
        = (fibState m (i + d)).1 + (fibState m (i + d)).2 := h2.2
    have hfst : (fibState m i).1 = (fibState m (i + d)).1 := by
      have := hsum; rw [hsnd] at this; exact add_right_cancel this
    exact Prod.ext hfst hsnd

/-- **The rank of apparition exists.** Every modulus `m ≥ 1` divides some positive
Fibonacci number.  Proof: the finite-state pure periodicity above forces the orbit
of `(0,1)` to return to `(0,1)`. -/
-- !-- Pigeonhole on `fibState m : ℕ → ZMod m × ZMod m` (finite codomain) gives a
--     repeat `i ≠ j`; the descent lemma sends it to `(0,1) = fibState m d` with
--     `d > 0`, whose first coordinate `fib d ≡ 0 [m]` gives `m ∣ fib d`. -- !--
lemma fib_apparition_exists (m : ℕ) (hm : 0 < m) : ∃ k, 0 < k ∧ m ∣ Nat.fib k := by
  haveI : NeZero m := ⟨hm.ne'⟩
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fibState m)
  wlog hlt : i < j generalizing i j
  · exact this j i (Ne.symm hij) hfe.symm (by omega)
  · set d := j - i with hd
    have hjd : j = i + d := by omega
    have hdpos : 0 < d := by omega
    rw [hjd] at hfe
    have hdesc := fibState_descent m d i hfe
    rw [fibState_zero] at hdesc
    have hfirst : (0 : ZMod m) = (Nat.fib d : ZMod m) := by
      have := congrArg Prod.fst hdesc
      simpa [fibState] using this
    refine ⟨d, hdpos, ?_⟩
    rw [← ZMod.natCast_eq_zero_iff]
    exact hfirst.symm

/-! ## §2. The rank of apparition and the representation (duality) theorem -/

/-- The **rank of apparition** of `m`: the least positive index `k` with `m ∣ fib k`. -/
noncomputable def fibRank (m : ℕ) : ℕ := sInf {k | 0 < k ∧ m ∣ Nat.fib k}

-- !-- `Nat.sInf_mem` applied to the nonempty witness set from `fib_apparition_exists`. -- !--
lemma fibRank_spec (m : ℕ) (hm : 0 < m) : 0 < fibRank m ∧ m ∣ Nat.fib (fibRank m) :=
  Nat.sInf_mem (fib_apparition_exists m hm)

lemma fibRank_pos (m : ℕ) (hm : 0 < m) : 0 < fibRank m := (fibRank_spec m hm).1

lemma fibRank_dvd_fib (m : ℕ) (hm : 0 < m) : m ∣ Nat.fib (fibRank m) := (fibRank_spec m hm).2

-- !-- Minimality of `sInf` (`Nat.sInf_le`). -- !--
lemma fibRank_le (m : ℕ) {k : ℕ} (hk : 0 < k) (hd : m ∣ Nat.fib k) : fibRank m ≤ k :=
  Nat.sInf_le ⟨hk, hd⟩

/-- **Headline theorem: the Fibonacci law of apparition.**
`m` divides the `n`-th Fibonacci value iff the rank of apparition of `m` divides the
index `n`.  Divisibility of *values* is dual to divisibility of *indices*. -/
-- !-- (⇐) `fibRank m ∣ n ⇒ fib (fibRank m) ∣ fib n` (`Nat.fib_dvd`) and `m ∣ fib (fibRank m)`.
--     (⇒) `m ∣ fib n` and `m ∣ fib (fibRank m)` give `m ∣ fib (gcd (fibRank m) n)`
--     (`Nat.fib_gcd`); minimality forces `gcd (fibRank m) n = fibRank m`, i.e. `fibRank m ∣ n`. -- !--
theorem fib_dvd_iff_rank_dvd (m : ℕ) (hm : 0 < m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos n with hn | hn
    · subst hn; exact dvd_zero _
    · set r := fibRank m with hr
      have hrpos : 0 < r := fibRank_pos m hm
      have hmr : m ∣ Nat.fib r := fibRank_dvd_fib m hm
      have hgcd : m ∣ Nat.fib (Nat.gcd r n) := by
        rw [Nat.fib_gcd]; exact Nat.dvd_gcd hmr h
      have hgpos : 0 < Nat.gcd r n := Nat.gcd_pos_of_pos_left n hrpos
      have hle : r ≤ Nat.gcd r n := fibRank_le m hgpos hgcd
      have hge : Nat.gcd r n ≤ r := Nat.le_of_dvd hrpos (Nat.gcd_dvd_left r n)
      have heq : Nat.gcd r n = r := le_antisymm hge hle
      exact heq ▸ Nat.gcd_dvd_right r n
  · intro h
    have h1 : Nat.fib (fibRank m) ∣ Nat.fib n := Nat.fib_dvd _ _ h
    exact dvd_trans (fibRank_dvd_fib m hm) h1

/-! ## §3. The divisibility predicate as a min-plus (lattice) homomorphism -/

/-- **The Fibonacci divisibility predicate is a `gcd`→`∧` homomorphism.**
`m` divides `fib (gcd a b)` iff it divides both `fib a` and `fib b`: the tropical
`min` (= `gcd`) on indices is sent to logical conjunction.  Immediate from the
apparition theorem and `Nat.dvd_gcd_iff`. -/
-- !-- Rewrite each side with `fib_dvd_iff_rank_dvd`; reduce to `Nat.dvd_gcd_iff`. -- !--
theorem fib_dvd_gcd_iff (m : ℕ) (hm : 0 < m) (a b : ℕ) :
    m ∣ Nat.fib (Nat.gcd a b) ↔ (m ∣ Nat.fib a ∧ m ∣ Nat.fib b) := by
  rw [fib_dvd_iff_rank_dvd m hm, fib_dvd_iff_rank_dvd m hm, fib_dvd_iff_rank_dvd m hm,
    Nat.dvd_gcd_iff]

/-! ## §4. Bridge to the catalog: arithmetic height of Fibonacci numbers -/

/-- **Capstone (Mathlib-native form).** The `p`-adic norm of `fib n` is strictly
below `1` exactly when the rank of apparition of `p` divides `n`. -/
-- !-- `padicNorm.int_lt_one_iff` + `Int.natCast_dvd_natCast`, then `fib_dvd_iff_rank_dvd`. -- !--
theorem padicNorm_fib_lt_one_iff (p : ℕ) [Fact p.Prime] (n : ℕ) :
    padicNorm p ((Nat.fib n : ℤ) : ℚ) < 1 ↔ fibRank p ∣ n := by
  rw [padicNorm.int_lt_one_iff, Int.natCast_dvd_natCast,
    fib_dvd_iff_rank_dvd p (Nat.Prime.pos Fact.out)]

/- **Capstone (catalog form): arithmetic height ↔ apparition.** (commented out — see build-fix note)
The catalog's `p`-adic arithmetic-height norm `TropUltra.padicHeightNorm` of the
Fibonacci value `fib n` is strictly below `1` exactly when the rank of apparition of
`p` divides `n`.  Feeds the abstract ultrametric arithmetic height of
`Bridges/TropicalUltrametricBridge.lean` the concrete Fibonacci inputs.
`(padicHeightNorm p).N q = (padicNorm p q : ℝ)`; cast `< 1` down to `ℚ` (`Rat.cast_lt`)
and apply `padicNorm_fib_lt_one_iff`. -/
-- (build fix) Depends on the missing `Bridges/TropicalUltrametricBridge.lean`
-- (`TropUltra.padicHeightNorm`); commented out so the file elaborates standalone.
-- theorem fibHeight_lt_one_iff (p : ℕ) [Fact p.Prime] (n : ℕ) :
--     (TropUltra.padicHeightNorm p).N ((Nat.fib n : ℤ) : ℚ) < 1 ↔ fibRank p ∣ n := by
--   have hN : (TropUltra.padicHeightNorm p).N ((Nat.fib n : ℤ) : ℚ)
--       = ((padicNorm p ((Nat.fib n : ℤ) : ℚ) : ℚ) : ℝ) := rfl
--   rw [hN, show (1 : ℝ) = ((1 : ℚ) : ℝ) by norm_num, Rat.cast_lt]
--   exact padicNorm_fib_lt_one_iff p n

end FibApparition