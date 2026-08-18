import Mathlib
import Pythagorean.BerggrenGroupoid
import Probability.PRNGLFSRDetection

/-!
# Pythagorean triple streams are PRNG output: fingerprinting and seed recovery

This file is part of the research thread *"a surprising amount of real-world data
is PRNG output — detect it and recover the seed"*, instantiated at a family of
generators that occurs in genuinely real data: the **Barning–Berggren moves** on
Pythagorean triples.  Every tabulated list of Pythagorean triples, every
procedurally generated right-triangle mesh, and every walk down the Berggren tree
is the orbit of a deterministic three-state affine generator.

The bridge proved here is:

> **A Berggren orbit is an LFSR stream.**  Each of the three Berggren moves is a
> unimodular `3 × 3` integer matrix, so by Cayley–Hamilton *every* linear
> readout of its orbit satisfies a fixed order-3 linear recurrence.  Therefore
> the Berlekamp–Massey / linear-complexity detector of
> `Probability.PRNGLFSRDetection` fires on Pythagorean triple streams, and the
> seed is exactly the first three observed symbols.

Main contents.

* `bergGen`, `bergGen_stream` — a Berggren move viewed as a `PRNG` in the sense
  of `Probability.PRNGSeedRecovery`.
* `orbitA_closed_form`, `orbitC_closed_form` — the moves `A` and `C` are
  *unipotent*: their orbits are **quadratic polynomials in time**, given in
  closed form.  (`(3,4,5)` under `A` is `(2t+3, 2t²+6t+4, 2t²+6t+5)`.)
* `moveA_charpoly`, `moveB_charpoly`, `moveC_charpoly` — the Cayley–Hamilton
  relations `(S-1)³ = 0` for `A`, `C` and `S³ = 5S² + 5S - 1` for `B`.
* `satisfiesLFSR_of_charpoly` — a general transfer lemma: an order-3 matrix
  relation makes *every* linear readout an order-3 LFSR stream.
* `berggrenA_satisfiesLFSR`, `berggrenB_satisfiesLFSR`, `berggrenC_satisfiesLFSR`
  — the **fingerprints**: taps `![1,-3,3]` for the unipotent moves, `![-1,5,5]`
  for `B`.
* `berggrenA_seed_recovery`, `berggrenB_seed_recovery`, `berggrenC_seed_recovery`
  — the **falsifiability gate**: the seed read off the first three symbols
  regenerates the observed stream at *every* index, exactly.
* `bergGen_pref_injective`, `bergGen_decode_eq` — seed recovery for the triple
  stream itself is unique.
* `bergA_hypotenuse_alt_recurrence` etc. — the classical Pell recurrence
  `x(t+2) = 6x(t+1) - x(t)` for the `B`-branch hypotenuse, derived from the same
  matrix picture.
-/

namespace Catalog.Pythagorean.BerggrenPRNG

open Catalog.Probability.SeedRec BerggrenGroupoid

/-! ## Berggren moves as pseudorandom generators -/

/-- A Berggren move, viewed as a deterministic generator whose emitted symbol is
the whole current triple. -/
def bergGen (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ) : PRNG (ℤ × ℤ × ℤ) (ℤ × ℤ × ℤ) :=
  ⟨m, id⟩

@[simp] theorem bergGen_stream (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ) (p : ℤ × ℤ × ℤ) (t : ℕ) :
    (bergGen m).stream p t = m^[t] p := rfl

/-- Being a Pythagorean triple, as a predicate on points of `ℤ³`. -/
def IsPythagPt (q : ℤ × ℤ × ℤ) : Prop := IsPythag q.1 q.2.1 q.2.2

theorem moveA_isPythagPt {q : ℤ × ℤ × ℤ} (h : IsPythagPt q) : IsPythagPt (moveA q) :=
  bergA_pyth _ _ _ h

theorem moveB_isPythagPt {q : ℤ × ℤ × ℤ} (h : IsPythagPt q) : IsPythagPt (moveB q) :=
  bergB_pyth _ _ _ h

theorem moveC_isPythagPt {q : ℤ × ℤ × ℤ} (h : IsPythagPt q) : IsPythagPt (moveC q) :=
  bergC_pyth _ _ _ h

/-- The generated file is a genuine list of Pythagorean triples: the Lorentz form
is a conserved quantity of the generator. -/
theorem bergGen_stream_isPythagPt (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ)
    (hm : ∀ q, IsPythagPt q → IsPythagPt (m q)) (p : ℤ × ℤ × ℤ) (h : IsPythagPt p) (t : ℕ) :
    IsPythagPt ((bergGen m).stream p t) := by
  induction t with
  | zero => simpa using h
  | succ t ih =>
      have hstep : (bergGen m).stream p (t + 1) = m ((bergGen m).stream p t) := by
        simp [Function.iterate_succ_apply']
      rw [hstep]
      exact hm _ ih

/-! ## Closed forms: the unipotent branches are quadratic in time -/

/-- **Closed form for the `A`-branch.**  `moveA` is unipotent, so its orbit is a
quadratic polynomial in the time index; the first coordinate is even *linear*.
For the root `(3,4,5)` this is the classical family `(2t+3, 2t²+6t+4, 2t²+6t+5)`. -/
theorem orbitA_closed_form (a b c : ℤ) (t : ℕ) :
    moveA^[t] (a, b, c) =
      (a + 2 * (t : ℤ) * (c - b),
       b + 2 * (t : ℤ) * (a - b + c) + 2 * (t : ℤ) * ((t : ℤ) - 1) * (c - b),
       c + 2 * (t : ℤ) * (a - b + c) + 2 * (t : ℤ) * ((t : ℤ) - 1) * (c - b)) := by
  induction t with
  | zero => norm_num
  | succ t ih =>
      rw [Function.iterate_succ_apply', ih]
      simp only [moveA, bergA, Prod.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- **Closed form for the `C`-branch.**  `moveC` is unipotent as well; here it is
the *second* coordinate that is linear in time. -/
theorem orbitC_closed_form (a b c : ℤ) (t : ℕ) :
    moveC^[t] (a, b, c) =
      (a + 2 * (t : ℤ) * (-a + b + c) + 2 * (t : ℤ) * ((t : ℤ) - 1) * (c - a),
       b + 2 * (t : ℤ) * (c - a),
       c + 2 * (t : ℤ) * (-a + b + c) + 2 * (t : ℤ) * ((t : ℤ) - 1) * (c - a)) := by
  induction t with
  | zero => norm_num
  | succ t ih =>
      rw [Function.iterate_succ_apply', ih]
      simp only [moveC, bergC, Prod.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- The `A`-branch leg `a` is an arithmetic progression with common difference
`2(c-b)`: an immediately testable fingerprint. -/
theorem orbitA_fst_linear (a b c : ℤ) (t : ℕ) :
    (moveA^[t] (a, b, c)).1 = a + 2 * (t : ℤ) * (c - b) := by
  rw [orbitA_closed_form]

/-- The `C`-branch leg `b` is an arithmetic progression with common difference
`2(c-a)`. -/
theorem orbitC_snd_linear (a b c : ℤ) (t : ℕ) :
    (moveC^[t] (a, b, c)).2.1 = b + 2 * (t : ℤ) * (c - a) := by
  rw [orbitC_closed_form]

/-! ## Cayley–Hamilton relations: the order-3 fingerprints -/

/-- **`(S - 1)³ = 0` for the move `A`.**  The characteristic polynomial of the
Barning matrix `B₁` is `(λ-1)³`. -/
theorem moveA_charpoly (q : ℤ × ℤ × ℤ) :
    moveA (moveA (moveA q)) =
      (1 * q.1 + (-3) * (moveA q).1 + 3 * (moveA (moveA q)).1,
       1 * q.2.1 + (-3) * (moveA q).2.1 + 3 * (moveA (moveA q)).2.1,
       1 * q.2.2 + (-3) * (moveA q).2.2 + 3 * (moveA (moveA q)).2.2) := by
  obtain ⟨a, b, c⟩ := q
  simp only [moveA, bergA, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- **`S³ = 5S² + 5S - 1` for the move `B`.**  The characteristic polynomial of
`B₂` is `λ³ - 5λ² - 5λ + 1 = (λ+1)(λ² - 6λ + 1)`: the Pell factor is visible. -/
theorem moveB_charpoly (q : ℤ × ℤ × ℤ) :
    moveB (moveB (moveB q)) =
      ((-1) * q.1 + 5 * (moveB q).1 + 5 * (moveB (moveB q)).1,
       (-1) * q.2.1 + 5 * (moveB q).2.1 + 5 * (moveB (moveB q)).2.1,
       (-1) * q.2.2 + 5 * (moveB q).2.2 + 5 * (moveB (moveB q)).2.2) := by
  obtain ⟨a, b, c⟩ := q
  simp only [moveB, bergB, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- **`(S - 1)³ = 0` for the move `C`.** -/
theorem moveC_charpoly (q : ℤ × ℤ × ℤ) :
    moveC (moveC (moveC q)) =
      (1 * q.1 + (-3) * (moveC q).1 + 3 * (moveC (moveC q)).1,
       1 * q.2.1 + (-3) * (moveC q).2.1 + 3 * (moveC (moveC q)).2.1,
       1 * q.2.2 + (-3) * (moveC q).2.2 + 3 * (moveC (moveC q)).2.2) := by
  obtain ⟨a, b, c⟩ := q
  simp only [moveC, bergC, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- **Transfer lemma (Cayley–Hamilton ⟹ LFSR fingerprint).**  If a self-map of
`ℤ³` satisfies an order-3 linear relation, then *every* linear readout
`u·a + v·b + w·c` of every orbit satisfies the order-3 linear recurrence with the
same taps — i.e. the linear complexity of the observed stream is at most `3`,
whatever the observation functional is. -/
theorem satisfiesLFSR_of_charpoly (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ) (t₀ t₁ t₂ : ℤ)
    (h : ∀ q : ℤ × ℤ × ℤ, m (m (m q)) =
      (t₀ * q.1 + t₁ * (m q).1 + t₂ * (m (m q)).1,
       t₀ * q.2.1 + t₁ * (m q).2.1 + t₂ * (m (m q)).2.1,
       t₀ * q.2.2 + t₁ * (m q).2.2 + t₂ * (m (m q)).2.2))
    (u v w : ℤ) (p : ℤ × ℤ × ℤ) :
    SatisfiesLFSR ![t₀, t₁, t₂]
      (fun t => u * (m^[t] p).1 + v * (m^[t] p).2.1 + w * (m^[t] p).2.2) := by
  intro t
  have e1 : m^[t + 1] p = m (m^[t] p) := by
    rw [Function.iterate_succ_apply']
  have e2 : m^[t + 2] p = m (m (m^[t] p)) := by
    rw [show t + 2 = (t + 1) + 1 from rfl, Function.iterate_succ_apply', e1]
  have e3 : m^[t + 3] p = m (m (m (m^[t] p))) := by
    rw [show t + 3 = (t + 2) + 1 from rfl, Function.iterate_succ_apply', e2]
  simp only [Fin.sum_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons, Fin.val_zero, Fin.val_one, Fin.val_two, Nat.add_zero]
  rw [e1, e2, e3, h (m^[t] p)]
  ring

/-- **Fingerprint of the `A`-branch.**  Any linear readout of a `moveA` orbit is
an order-3 LFSR stream with taps `![1, -3, 3]` (vanishing third difference). -/
theorem berggrenA_satisfiesLFSR (u v w : ℤ) (p : ℤ × ℤ × ℤ) :
    SatisfiesLFSR ![1, -3, 3]
      (fun t => u * (moveA^[t] p).1 + v * (moveA^[t] p).2.1 + w * (moveA^[t] p).2.2) :=
  satisfiesLFSR_of_charpoly moveA 1 (-3) 3 moveA_charpoly u v w p

/-- **Fingerprint of the `B`-branch**: taps `![-1, 5, 5]`. -/
theorem berggrenB_satisfiesLFSR (u v w : ℤ) (p : ℤ × ℤ × ℤ) :
    SatisfiesLFSR ![-1, 5, 5]
      (fun t => u * (moveB^[t] p).1 + v * (moveB^[t] p).2.1 + w * (moveB^[t] p).2.2) :=
  satisfiesLFSR_of_charpoly moveB (-1) 5 5 moveB_charpoly u v w p

/-- **Fingerprint of the `C`-branch**: taps `![1, -3, 3]`, as for `A`. -/
theorem berggrenC_satisfiesLFSR (u v w : ℤ) (p : ℤ × ℤ × ℤ) :
    SatisfiesLFSR ![1, -3, 3]
      (fun t => u * (moveC^[t] p).1 + v * (moveC^[t] p).2.1 + w * (moveC^[t] p).2.2) :=
  satisfiesLFSR_of_charpoly moveC 1 (-3) 3 moveC_charpoly u v w p

/-! ## The falsifiability gate: three symbols regenerate the stream -/

/-- **Exact reproduction, `A`-branch.**  The LFSR seed read off the first three
observed symbols regenerates the entire Berggren-`A` readout stream, at every
index: a length-`n` file collapses to three integers. -/
theorem berggrenA_seed_recovery (u v w : ℤ) (p : ℤ × ℤ × ℤ) :
    ∀ t, (lfsrPRNG (K := ℤ) ![1, -3, 3]).stream
        (fun i : Fin 3 =>
          u * (moveA^[(i : ℕ)] p).1 + v * (moveA^[(i : ℕ)] p).2.1 +
            w * (moveA^[(i : ℕ)] p).2.2) t
      = u * (moveA^[t] p).1 + v * (moveA^[t] p).2.1 + w * (moveA^[t] p).2.2 :=
  lfsr_exact_reproduction _ _ (berggrenA_satisfiesLFSR u v w p)

/-- **Exact reproduction, `B`-branch.** -/
theorem berggrenB_seed_recovery (u v w : ℤ) (p : ℤ × ℤ × ℤ) :
    ∀ t, (lfsrPRNG (K := ℤ) ![-1, 5, 5]).stream
        (fun i : Fin 3 =>
          u * (moveB^[(i : ℕ)] p).1 + v * (moveB^[(i : ℕ)] p).2.1 +
            w * (moveB^[(i : ℕ)] p).2.2) t
      = u * (moveB^[t] p).1 + v * (moveB^[t] p).2.1 + w * (moveB^[t] p).2.2 :=
  lfsr_exact_reproduction _ _ (berggrenB_satisfiesLFSR u v w p)

/-- **Exact reproduction, `C`-branch.** -/
theorem berggrenC_seed_recovery (u v w : ℤ) (p : ℤ × ℤ × ℤ) :
    ∀ t, (lfsrPRNG (K := ℤ) ![1, -3, 3]).stream
        (fun i : Fin 3 =>
          u * (moveC^[(i : ℕ)] p).1 + v * (moveC^[(i : ℕ)] p).2.1 +
            w * (moveC^[(i : ℕ)] p).2.2) t
      = u * (moveC^[t] p).1 + v * (moveC^[t] p).2.1 + w * (moveC^[t] p).2.2 :=
  lfsr_exact_reproduction _ _ (berggrenC_satisfiesLFSR u v w p)

/-! ## Seed recovery for the triple stream itself -/

/-- The very first emitted symbol *is* the seed, so seeds are recoverable from a
prefix of any positive length. -/
theorem bergGen_pref_injective (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ) {n : ℕ} (hn : 0 < n) :
    Function.Injective ((bergGen m).pref n) := by
  intro p q h
  have := congrFun h ⟨0, hn⟩
  simpa [PRNG.pref] using this

/-- **Uniqueness of the recovered seed.**  Whatever seed the decoder returns for
an observed Berggren file, it is *the* seed that produced it. -/
theorem bergGen_decode_eq (m : ℤ × ℤ × ℤ → ℤ × ℤ × ℤ) {n : ℕ} (hn : 0 < n)
    {p : ℤ × ℤ × ℤ} (h : SeedCompressible (bergGen m) n ((bergGen m).pref n p)) :
    (bergGen m).decode h = p :=
  (bergGen m).decode_eq_of_injective (bergGen_pref_injective m hn) h

/-- Backwards seed recovery for the `A`-branch: the inverse move run for the same
number of steps returns the seed exactly. -/
theorem moveA'_recovers_seed (p : ℤ × ℤ × ℤ) (t : ℕ) : moveA'^[t] (moveA^[t] p) = p := by
  induction t with
  | zero => simp
  | succ t ih =>
      rw [Function.iterate_succ_apply' (f := moveA), Function.iterate_succ_apply (f := moveA'),
        moveA'_moveA, ih]

/-- Backwards seed recovery for the `B`-branch. -/
theorem moveB'_recovers_seed (p : ℤ × ℤ × ℤ) (t : ℕ) : moveB'^[t] (moveB^[t] p) = p := by
  induction t with
  | zero => simp
  | succ t ih =>
      rw [Function.iterate_succ_apply' (f := moveB), Function.iterate_succ_apply (f := moveB'),
        moveB'_moveB, ih]

/-- Backwards seed recovery for the `C`-branch. -/
theorem moveC'_recovers_seed (p : ℤ × ℤ × ℤ) (t : ℕ) : moveC'^[t] (moveC^[t] p) = p := by
  induction t with
  | zero => simp
  | succ t ih =>
      rw [Function.iterate_succ_apply' (f := moveC), Function.iterate_succ_apply (f := moveC'),
        moveC'_moveC, ih]

/-! ## The Pell factor of the `B`-branch -/

/-- On the `B`-branch the pair `(a+b, c)` evolves by the matrix `!![3,4;2,3]`,
whose characteristic polynomial is `λ² - 6λ + 1`.  Hence the hypotenuse obeys the
classical Pell recurrence `c(t+2) = 6 c(t+1) - c(t)` — the order-2 fingerprint
refining the order-3 one. -/
theorem bergB_hypotenuse_pell (p : ℤ × ℤ × ℤ) (t : ℕ) :
    (moveB^[t + 2] p).2.2 = 6 * (moveB^[t + 1] p).2.2 - (moveB^[t] p).2.2 := by
  have e1 : moveB^[t + 1] p = moveB (moveB^[t] p) := by
    rw [Function.iterate_succ_apply']
  have e2 : moveB^[t + 2] p = moveB (moveB (moveB^[t] p)) := by
    rw [show t + 2 = (t + 1) + 1 from rfl, Function.iterate_succ_apply', e1]
  rw [e1, e2]
  simp only [moveB, bergB]
  ring

/-- The leg-sum on the `B`-branch obeys the same Pell recurrence. -/
theorem bergB_legsum_pell (p : ℤ × ℤ × ℤ) (t : ℕ) :
    (moveB^[t + 2] p).1 + (moveB^[t + 2] p).2.1 =
      6 * ((moveB^[t + 1] p).1 + (moveB^[t + 1] p).2.1) -
        ((moveB^[t] p).1 + (moveB^[t] p).2.1) := by
  have e1 : moveB^[t + 1] p = moveB (moveB^[t] p) := by
    rw [Function.iterate_succ_apply']
  have e2 : moveB^[t + 2] p = moveB (moveB (moveB^[t] p)) := by
    rw [show t + 2 = (t + 1) + 1 from rfl, Function.iterate_succ_apply', e1]
  rw [e1, e2]
  simp only [moveB, bergB]
  ring

/-- One `B`-step negates the leg difference. -/
theorem moveB_legdiff_step (q : ℤ × ℤ × ℤ) :
    (moveB q).2.1 - (moveB q).1 = -(q.2.1 - q.1) := by
  simp only [moveB, bergB]
  ring

/-- The leg *difference* on the `B`-branch spans the eigenline of eigenvalue `-1`:
it merely alternates in sign.  This is the cheapest fingerprint of the branch. -/
theorem bergB_legdiff_alternates (a b c : ℤ) (t : ℕ) :
    (moveB^[t] (a, b, c)).2.1 - (moveB^[t] (a, b, c)).1 = (-1 : ℤ) ^ t * (b - a) := by
  induction t with
  | zero => simp
  | succ t ih =>
      rw [Function.iterate_succ_apply', moveB_legdiff_step, ih, pow_succ]
      ring

end Catalog.Pythagorean.BerggrenPRNG