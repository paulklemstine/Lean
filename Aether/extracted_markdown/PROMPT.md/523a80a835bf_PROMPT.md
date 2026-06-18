## Research Task: Quantitative residual finiteness for Berggren/SPB finite balls and bounded collision extraction

Research Mode: PROVE

Work in the concrete Berggren/SPB embedding already formalized: the three positive Berggren generators as `SL(2, ℤ)` matrices generate a semigroup `S`. Strengthen the existing finite-quotient injectivity story to an explicit, radius-controlled statement.

The right target is not merely “there exists some finite quotient separating a finite set,” but a theorem with an explicit modulus built from an entrywise growth bound on the semigroup ball. The key mathematical point is simple but powerful: once all entries of all matrices in the radius-`L` ball are bounded in absolute value by `M(L)`, reduction modulo any `m > 2 * M(L)` is automatically injective on that ball, because two distinct bounded integers cannot become congruent mod such a large modulus.

### Concrete objects to define

Use the existing Berggren generators `A B C : Matrix (Fin 2) (Fin 2) ℤ` (or the corresponding `SpecialLinearGroup (Fin 2) ℤ` representatives if those are already packaged). Define:

```lean
def berggrenGens : Finset (Matrix (Fin 2) (Fin 2) ℤ) := {A, B, C}
```

or the analogous `Finset` in `SL(2,ℤ)` if multiplication is cleaner there.

Define the radius-`L` semigroup ball as the set of products of at most `L` generators. A workable Lean realization is via lists/words:

```lean
def BergWord := List (Matrix (Fin 2) (Fin 2) ℤ)

def wordEval : BergWord → Matrix (Fin 2) (Fin 2) ℤ
| [] => 1
| g :: w => g * wordEval w

def isBergWord (w : BergWord) : Prop := ∀ g ∈ w, g ∈ berggrenGens

def semigroupBall (L : ℕ) : Set (Matrix (Fin 2) (Fin 2) ℤ) :=
  {M | ∃ w, isBergWord w ∧ w.length ≤ L ∧ wordEval w = M}
```

If the catalog already has a semigroup subtype for the positive Berggren semigroup, use that instead, but keep the theorem statements entrywise and quantitative.

### First target: explicit entry growth bound on the ball

You need a concrete function `entryBound : ℕ → ℕ` such that every entry of every matrix in `semigroupBall L` has absolute value bounded by `entryBound L`. A clean approach is to use the maximum row-sum/operator-∞ norm. Define for a `2×2` integer matrix:

```lean
def matAbsMax (M : Matrix (Fin 2) (Fin 2) ℤ) : ℕ :=
  Finset.sup Finset.univ (fun i =>
    Finset.sup Finset.univ (fun j => Int.natAbs (M i j)))
```

Then prove submultiplicative control with a fixed generator constant `K`:

```lean
def berggrenStepBound : ℕ :=  -- choose explicit constant from A,B,C entries

theorem matAbsMax_mul_le
    (M N : Matrix (Fin 2) (Fin 2) ℤ) :
    matAbsMax (M * N) ≤ 2 * matAbsMax M * matAbsMax N := by
  ...
```

and in particular for each generator:

```lean
theorem matAbsMax_mul_gen_le
    {G : Matrix (Fin 2) (Fin 2) ℤ}
    (hG : G ∈ berggrenGens) (M : Matrix (Fin 2) (Fin 2) ℤ) :
    matAbsMax (M * G) ≤ berggrenStepBound * matAbsMax M := by
  ...
```

From this derive an explicit exponential bound:

```lean
def berggrenBallBound (L : ℕ) : ℕ := berggrenStepBound ^ L

theorem semigroupBall_entry_bound
    {L : ℕ} {M : Matrix (Fin 2) (Fin 2) ℤ}
    (hM : M ∈ semigroupBall L) :
    matAbsMax M ≤ berggrenBallBound L := by
  ...
```

If the identity matrix causes `matAbsMax 1 = 1`, the induction should close cleanly. You do not need the sharpest possible constant; a robust explicit bound is enough.

### Core quantitative separation lemma

This is the central finite-quotient mechanism and should be proved in a reusable form for arbitrary `2×2` integer matrices.

Let reduction mod `m` be entrywise reduction into `ZMod m`:

```lean
def reduceMod (m : ℕ) (M : Matrix (Fin 2) (Fin 2) ℤ) :
    Matrix (Fin 2) (Fin 2) (ZMod m) :=
  fun i j => (M i j : ZMod m)
```

Prove the bounded-separation lemma:

```lean
theorem reduceMod_injective_on_absBound
    {m Mbound : ℕ}
    (hm : 2 * Mbound < m)
    {X Y : Matrix (Fin 2) (Fin 2) ℤ}
    (hX : matAbsMax X ≤ Mbound)
    (hY : matAbsMax Y ≤ Mbound)
    (hxy : reduceMod m X = reduceMod m Y) :
    X = Y := by
  ...
```

A slightly weaker hypothesis `m > 2 * Mbound` is also fine. The proof should proceed entrywise:
1. From equality in `ZMod m`, deduce for each entry `m ∣ (X i j - Y i j)`.
2. Use the bounds to show `Int.natAbs (X i j - Y i j) ≤ 2 * Mbound`.
3. Since a nonzero multiple of `m` has absolute value at least `m`, the strict inequality `Int.natAbs (...) < m` forces the difference to be zero.
4. Conclude entrywise equality and hence matrix equality by extensionality.

If there is friction with integer divisibility lemmas, it may be cleaner to first prove an auxiliary lemma on integers:

```lean
theorem Int.eq_of_natAbs_sub_lt_of_modEq
    {a b : ℤ} {m Mbound : ℕ}
    (hm : 2 * Mbound < m)
    (ha : Int.natAbs a ≤ Mbound)
    (hb : Int.natAbs b ≤ Mbound)
    (hmod : (a : ZMod m) = (b : ZMod m)) :
    a = b := by
  ...
```

and then lift entrywise.

### Main theorem: injectivity on the radius-`L` ball

Package the quantitative residual-finiteness statement as follows.

```lean
def certifiedModulus (L : ℕ) : ℕ := 2 * berggrenBallBound L + 1
```

Then prove:

```lean
theorem reduceMod_injective_on_semigroupBall
    (L : ℕ) :
    Set.InjOn (reduceMod (certifiedModulus L)) (semigroupBall L) := by
  ...
```

Expanded form:

```lean
theorem semigroupBall_mod_separation
    (L : ℕ)
    {X Y : Matrix (Fin 2) (Fin 2) ℤ}
    (hX : X ∈ semigroupBall L)
    (hY : Y ∈ semigroupBall L)
    (hred : reduceMod (certifiedModulus L) X = reduceMod (certifiedModulus L) Y) :
    X = Y := by
  ...
```

This theorem is the quantitative residual-finiteness statement specialized to the Berggren semigroup ball. It should be fully explicit: the modulus is a concrete function of `L`, not merely existential.

### Semigroup-word collision extraction

Now turn the matrix-level injectivity into a semigroup collision theorem. If the SPB embedding already proves evaluation of positive words lands in the Berggren semigroup and cancellation/faithfulness properties are available, use them. The desired theorem is:

```lean
theorem bounded_collision_extraction
    {L : ℕ}
    {w₁ w₂ : BergWord}
    (hw₁ : isBergWord w₁) (hw₂ : isBergWord w₂)
    (hL₁ : w₁.length ≤ L) (hL₂ : w₂.length ≤ L)
    (hred :
      reduceMod (certifiedModulus L) (wordEval w₁) =
      reduceMod (certifiedModulus L) (wordEval w₂)) :
    wordEval w₁ = wordEval w₂ := by
  ...
```

If the catalog already has a theorem that word evaluation in the positive Berggren semigroup is injective modulo genuine semigroup equality, sharpen this to an actual word-level conclusion when available:

```lean
theorem bounded_collision_extraction_words
    {L : ℕ}
    {w₁ w₂ : BergWord}
    (hw₁ : isBergWord w₁) (hw₂ : isBergWord w₂)
    (hL₁ : w₁.length ≤ L) (hL₂ : w₂.length ≤ L)
    (hred :
      reduceMod (certifiedModulus L) (wordEval w₁) =
      reduceMod (certifiedModulus L) (wordEval w₂)) :
    wordEval w₁ = wordEval w₂ := by
  ...
```

and, if existing cancellation/unique-factorization lemmas are strong enough, possibly

```lean
    w₁ = w₂
```

but only claim literal word equality if it is genuinely justified by prior semigroup freeness results. Otherwise matrix equality is already substantial and correct.

### Recommended proof structure

1. **Norm bound for one multiplication step.**  
   Compute a uniform constant `berggrenStepBound` from the three generators. Since these are fixed `2×2` positive matrices, the bound can be obtained by finite case analysis on entries. Then induct on word length to show every radius-`L` product has entries bounded by `berggrenBallBound L`.

2. **Integer separation under large modulus.**  
   Prove the scalar lemma: if `|a|, |b| ≤ M` and `a ≡ b [ZMOD m]` with `m > 2M`, then `a = b`. The only nontrivial point is converting equality in `ZMod m` into divisibility of `a-b` by `m`, then using the absolute value bound to rule out nonzero multiples.

3. **Matrix separation by extensionality.**  
   Apply the scalar lemma to each of the four entries. Since the matrices are only `2×2`, `ext i j` is enough; no sophisticated linear algebra is needed.

4. **Injectivity on the semigroup ball.**  
   Combine the semigroup-ball entry bound with the matrix separation lemma using `m = certifiedModulus L`.

5. **Collision extraction.**  
   Any purported collision of reduced images from words of length `≤ L` lifts to actual equality in the semigroup image. If there is an ambient theorem saying distinct semigroup elements correspond to distinct protocol transcripts, invoke it here to obtain the cryptographic interpretation.

### Stronger optional theorem

If feasible, generalize from the radius-`L` ball to any finite subset with an explicit entry bound:

```lean
theorem reduceMod_injective_on_set_of_entryBound
    (m Mbound : ℕ)
    (hm : 2 * Mbound < m) :
    Set.InjOn (reduceMod m)
      {X : Matrix (Fin 2) (Fin 2) ℤ | matAbsMax X ≤ Mbound} := by
  ...
```

Then the Berggren-ball theorem becomes a one-line corollary from `semigroupBall_entry_bound`. This abstraction would make the result reusable for other matrix semigroups in the SPB/security development.

### Significance

This theorem turns residual finiteness from a qualitative existence fact into a certified finite-faithfulness bound indexed by protocol complexity. That is exactly what the SPB cryptographic program needs: a modulus `m(L)` that is guaranteed to preserve all distinctions among semigroup elements that can arise in transcripts of complexity at most `L`. It gives a mathematically rigorous “safe finite quotient” for bounded-length Diffie–Hellman-style executions, and it cleanly separates two adversarial outcomes:

- either a reduced collision within the certified ball lifts to a genuine semigroup equality, or
- the attack necessarily escaped the certified radius bound.

That bounded collision-extraction principle is much closer to an actual security reduction than an existential finite-quotient injectivity theorem, and it should integrate naturally with the existing SPB cancellation and semigroup embedding results.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Cryptography
Research mode: prove
