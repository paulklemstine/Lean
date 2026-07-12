/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Applications.FibonacciMatrix

/-!
# Proof Automation II: `number_theory_decide` — small-case closer

Domain: Applications (Proof Automation for the Catalog).

Many number-theoretic arguments reduce a general statement to a handful of
*small concrete cases* (base cases of an induction, residue conditions modulo a
fixed `m`, primality / coprimality of explicit integers). This file develops the
custom tactic `number_theory_decide`, a robust closer for exactly such finite
goals, and shows how it interlocks with genuine structural reasoning.

The tactic tries, in order, `decide` (kernel decision procedure), `norm_num`
(with its primality / arithmetic extensions), and `omega` (linear integer/nat
arithmetic). Soundness is immediate: each component is a sound Lean tactic, so a
goal closed by `number_theory_decide` is true (`number_theory_decide_sound`
records a representative bundle of facts it discharges).

The headline structural result is **Pisano periodicity**: if `F p ≡ 0` and
`F (p+1) ≡ 1 (mod m)`, then the Fibonacci sequence is periodic modulo `m` with
period (dividing) `p`. Its proof is a two-track induction — genuinely not a
decision procedure — while the *hypotheses* for concrete `(m, p)` are verified by
`number_theory_decide`. We also connect to the Catalog's `FibonacciMatrix`
(Cassini's identity) by reducing it modulo `m`.

## Main results

* `number_theory_decide` — the custom tactic (a `macro`).
* `fib_pisano_step` / `fib_mod_periodic` — Pisano periodicity of `F` mod `m`.
* `fib_mod_two_period`, `fib_mod_three_period` — concrete periods 3 and 8.
* `cassini_mod` — Cassini's identity (from `FibonacciMatrix`) read modulo `m`.
-/

namespace Catalog.ProofAutomation.NumberTheory

set_option maxRecDepth 8000

/-! ## The custom tactic -/

/-- `number_theory_decide` closes small, concrete number-theoretic goals:
finite residue conditions, primality / coprimality of explicit numbers, and
linear arithmetic facts. It tries `decide`, then `norm_num`, then `omega`. -/
macro "number_theory_decide" : tactic =>
  `(tactic| first | decide | norm_num | omega)

/-! ## Soundness witness

`number_theory_decide` is a disjunction of sound Lean tactics, so it can only
close true goals. The following lemma is a representative bundle of the kinds of
facts it discharges — Korselt-style data for the Carmichael number `561`,
Fibonacci residues, and coprimality — each closed by the tactic itself. -/

/-- **Soundness sampler for `number_theory_decide`.** A representative bundle of
small-case facts, all closed by the tactic. (`561 = 3·11·17` is the smallest
Carmichael number; the conditions `(p-1) ∣ 560` are Korselt's criterion.) -/
theorem number_theory_decide_sound :
    ¬ Nat.Prime 561 ∧ Nat.Prime 17 ∧ Nat.gcd 561 560 = 1 ∧
    (3 - 1) ∣ 560 ∧ (11 - 1) ∣ 560 ∧ (17 - 1) ∣ 560 ∧
    (Nat.fib 3 : ZMod 2) = 0 ∧ (Nat.fib 4 : ZMod 2) = 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> number_theory_decide

/-! ## Pisano periodicity: structure + small-case closing

The next lemma is the genuine mathematical engine. It is proved by a two-track
induction on `n` that simultaneously tracks `F (n+p)` and `F (n+p+1)` modulo `m`,
using the Fibonacci recurrence `Nat.fib_add_two`. This is *not* decidable for
general `m, p`; only the two seed residues are. -/

/-- **Pisano step (paired form).** If `F p ≡ 0` and `F (p+1) ≡ 1 (mod m)`, then
for every `n`, both `F (n+p) ≡ F n` and `F (n+p+1) ≡ F (n+1)` modulo `m`. -/
theorem fib_pisano_step (m p : ℕ) (h0 : (Nat.fib p : ZMod m) = 0)
    (h1 : (Nat.fib (p + 1) : ZMod m) = 1) :
    ∀ n, ((Nat.fib (n + p) : ZMod m) = (Nat.fib n : ZMod m)) ∧
         ((Nat.fib (n + p + 1) : ZMod m) = (Nat.fib (n + 1) : ZMod m)) := by
  intro n
  induction n with
  | zero => simpa using ⟨h0, h1⟩
  | succ k ih =>
    obtain ⟨iha, ihb⟩ := ih
    refine ⟨?_, ?_⟩
    · have e : k + 1 + p = k + p + 1 := by ring
      rw [e, ihb]
    · have e : k + 1 + p + 1 = (k + p) + 2 := by ring
      rw [e, Nat.fib_add_two]
      push_cast
      rw [iha, ihb, show k + 1 + 1 = k + 2 by ring, Nat.fib_add_two]
      push_cast; ring

/-- **Pisano periodicity.** Under the seed conditions `F p ≡ 0`, `F (p+1) ≡ 1`
(mod `m`), the Fibonacci sequence is periodic modulo `m` with period `p`:
`F (n + p) ≡ F n (mod m)` for all `n`. -/
theorem fib_mod_periodic (m p : ℕ) (h0 : (Nat.fib p : ZMod m) = 0)
    (h1 : (Nat.fib (p + 1) : ZMod m) = 1) (n : ℕ) :
    (Nat.fib (n + p) : ZMod m) = (Nat.fib n : ZMod m) :=
  (fib_pisano_step m p h0 h1 n).1

/-- Fibonacci has period `3` modulo `2`. The seed residues are checked by
`number_theory_decide`; the periodicity is the structural `fib_mod_periodic`. -/
theorem fib_mod_two_period (n : ℕ) :
    (Nat.fib (n + 3) : ZMod 2) = (Nat.fib n : ZMod 2) :=
  fib_mod_periodic 2 3 (by number_theory_decide) (by number_theory_decide) n

/-- Fibonacci has period `8` modulo `3`. (`F 8 = 21 ≡ 0`, `F 9 = 34 ≡ 1` mod 3.) -/
theorem fib_mod_three_period (n : ℕ) :
    (Nat.fib (n + 8) : ZMod 3) = (Nat.fib n : ZMod 3) :=
  fib_mod_periodic 3 8 (by number_theory_decide) (by number_theory_decide) n

/-! ## Bridge to the Catalog: Cassini modulo `m`

We reuse `Catalog/Applications/FibonacciMatrix.lean`'s `fib_cassini`
(`F(n+2)·F(n) − F(n+1)² = (−1)^(n+1)`) and read it in `ZMod m`, then close a
concrete instance with `number_theory_decide`. -/

/-- **Cassini's identity modulo `m`.** Casting `FibonacciMatrix.fib_cassini` into
`ZMod m`. -/
theorem cassini_mod (m n : ℕ) :
    (Nat.fib (n + 2) : ZMod m) * (Nat.fib n : ZMod m)
        - (Nat.fib (n + 1) : ZMod m) ^ 2 = (-1) ^ (n + 1) := by
  have h := FibonacciMatrix.fib_cassini n
  have h2 := congrArg (fun z : ℤ => (z : ZMod m)) h
  push_cast at h2
  simpa using h2

/-- A concrete sanity instance of Cassini modulo `5` at `n = 4`, closed entirely
by the small-case tactic: `F 6 · F 4 − F 5² = 8·3 − 5² = -1 ≡ (-1)^5` in `ZMod 5`. -/
theorem cassini_mod_example : (Nat.fib 6 : ZMod 5) * (Nat.fib 4 : ZMod 5)
    - (Nat.fib 5 : ZMod 5) ^ 2 = (-1) ^ 5 := by
  number_theory_decide

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  Carmichael / Fibonacci-modular results in the Catalog repeatedly bottom out in
  "small concrete checks": Korselt residues `(p-1) ∣ (n-1)`, seed residues of a
  recurrence, primality of explicit numbers. We conjecture one closer tactic
  covers all of these, and that the genuine theorems around them (periodicity,
  Korselt) reduce to a structural core + such checks.

EXPERIMENT (Experimenter).
  `number_theory_decide := first | decide | norm_num | omega`. With
  `maxRecDepth 8000`, `decide` handles `¬ Prime 561` and `ZMod`-residues;
  `norm_num` covers primality of larger numbers; `omega` covers divisibility /
  linear facts. Proved Pisano periodicity by a PAIRED two-track induction
  (tracking `F(n+p)` and `F(n+p+1)` together) — a single-track induction does not
  close because the recurrence couples consecutive terms. Concrete periods 3
  (mod 2) and 8 (mod 3) drop out by feeding `number_theory_decide` the seeds.
  Imported the Catalog's `FibonacciMatrix.fib_cassini` and cast it to `ZMod m`.

ANALYSIS (Analyst).
  Survived: `fib_pisano_step`, `fib_mod_periodic`, the two concrete periods,
  `cassini_mod`, plus the soundness sampler. Key failure understood: naive
  single-variable induction is "true but unprovable as stated" — needs the paired
  invariant. Decide-first ordering matters: `norm_num` partially rewrites
  `ZMod` residues to e.g. `2 = 0` and then stalls, whereas `decide` evaluates
  them directly; hence `decide` precedes `norm_num`.

CRITIQUE (Critic).
  * Trivial? No: the main theorems use induction and a cast from the Catalog; the
    soundness sampler is a bundle (acceptable as a *witness*, not the headline).
  * 0 sorries? Yes.
  * Uses the Catalog? Yes — `FibonacciMatrix.fib_cassini` via `cassini_mod`.
  * Corner cases: `ZMod 0 = ℤ` and `ZMod 1` are degenerate but the periodicity
    statement remains TRUE there (in `ZMod 1` everything is `0`); no hidden
    falsehood. `number_theory_decide` only ever closes decidable/true goals.

SYNTHESIS (PI).
  The pattern "structural induction with a paired invariant + `number_theory_decide`
  on the seeds" is a reusable template for every Pisano-type periodicity and,
  prospectively, for Korselt-style Carmichael verifications.
-/

end Catalog.ProofAutomation.NumberTheory