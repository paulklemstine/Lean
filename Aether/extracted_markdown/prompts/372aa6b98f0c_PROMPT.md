## Research Task: GL3 tropical Satake robustness for error-correcting output-code Hecke score classifiers

Research Mode: PROVE

Develop a decoder-level certified robustness theory for multiclass ECOC classifiers built from GL3 tropical Satake score gaps. The goal is to lift the already-established single-gap / argmax / top-k robustness mechanism to a genuinely new ensemble-decoding architecture: binary error-correcting output codes with either hard Hamming decoding or soft signed-margin decoding.

The key point is that robustness should no longer be phrased bitwise in isolation. What must be proved is a comparison theorem saying that pairwise class separation decomposes over the code bits on which two codewords differ, and that the tropical Lipschitz control on each bit-gap propagates to a multiclass decoder-level certified radius. This is the natural next step if the GL3 tropical Satake scores are to support realistic multiclass architectures rather than only one-vs-one or top-k style rules.

### Concrete setup to formalize

Work over a finite class set `Fin n` and a finite bit set `Fin m`. Use real-valued score gaps.

A convenient starting point is the following concrete data:

```lean
open scoped BigOperators

def CodeMatrix (n m : ℕ) := Fin n → Fin m → Int

def ValidCodeMatrix (C : CodeMatrix n m) : Prop :=
  ∀ y j, C y j = 1 ∨ C y j = -1

def SignedBitScore
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (j : Fin m) (x : α) : ℝ :=
  (C y j : ℝ) * g j x

def disagreeBits (C : CodeMatrix n m) (y z : Fin n) : Finset (Fin m) :=
  Finset.univ.filter (fun j => C y j ≠ C z j)

def softScore
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (x : α) : ℝ :=
  ∑ j : Fin m, SignedBitScore C g y j x

def truncatedScore
    (τ : ℝ) (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (x : α) : ℝ :=
  ∑ j : Fin m, min (SignedBitScore C g y j x) τ

def hardBit
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (j : Fin m) (x : α) : Bool :=
  0 < SignedBitScore C g y j x

def hardScore
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (x : α) : ℕ :=
  ((Finset.univ.filter (fun j : Fin m => 0 < SignedBitScore C g y j x)).card)

def certMargin (g : Fin m → α → ℝ) (x : α) (j : Fin m) : ℝ :=
  |g j x|
```

For robustness under perturbations, it is convenient to abstract the metric hypothesis as:

```lean
variable {α : Type*} [PseudoMetricSpace α]

def BitGapLipschitzOn
    (g : Fin m → α → ℝ) (L : ℝ) : Prop :=
  ∀ j x x', |g j x - g j x'| ≤ L * dist x x'
```

If the GL3 tropical Satake development already gives an `‖x - x'‖∞`-style estimate on a concrete input space, instantiate `α` with that space and replace `dist` by the existing metric/norm notion. The crucial constant in the final theorem should be the already-verified per-gap perturbation constant, denoted below by `L`; in your intended application this is the tropical Hecke constant `2 * Kd`.

### Main theorem 1: pairwise soft-score comparison decomposes exactly over disagreeing bits

This is the structural lemma that makes the whole ECOC argument work.

A good exact statement is:

```lean
theorem softScore_diff_eq_sum_disagree
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (y z : Fin n) (x : α) :
    softScore C g y x - softScore C g z x
      = ∑ j in disagreeBits C y z, (2 * (C y j : ℝ)) * g j x := by
  sorry
```

Because `C y j, C z j ∈ {±1}`, if `C y j ≠ C z j` then necessarily `C z j = - C y j`, so the per-bit contribution doubles; if they agree, the contribution cancels. This exact decomposition is the algebraic bridge between code geometry and tropical margins.

A variant using certified margins rather than raw gaps is also useful:

```lean
theorem softScore_diff_lower_bound_by_margins
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (y z : Fin n) (x : α)
    (hpos : ∀ j ∈ disagreeBits C y z, 0 ≤ (C y j : ℝ) * g j x) :
    0 ≤ ∑ j in disagreeBits C y z, (2 : ℝ) * |g j x| ∧
    ∑ j in disagreeBits C y z, (2 : ℝ) * |g j x|
      ≤ softScore C g y x - softScore C g z x := by
  sorry
```

If the exact lower bound above is awkward, it is enough to prove the cleaner identity under the stronger sign condition
`∀ j ∈ disagreeBits C y z, (C y j : ℝ) * g j x = |g j x|`.

### Main theorem 2: certified robustness for soft ECOC decoding

The primary robustness statement should say: if the pairwise aggregate certified advantage of the reference class against every competitor dominates the total perturbation budget on the disagreeing bits, then the decoder output is invariant on the entire ball.

A precise and Lean-friendly theorem is:

```lean
theorem soft_ecoc_robust_of_margin
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (y⋆ : Fin n) (x : α)
    (hr : 0 ≤ r)
    (hsep :
      ∀ z, z ≠ y⋆ →
        (∑ j in disagreeBits C y⋆ z, (2 : ℝ) * |g j x|)
          > (∑ j in disagreeBits C y⋆ z, (2 : ℝ) * L * r)) :
    ∀ x', dist x x' ≤ r →
      ∀ z, z ≠ y⋆ → softScore C g y⋆ x' > softScore C g z x' := by
  sorry
```

This theorem is already nontrivial and useful. It says that decoder robustness is controlled by a weighted code-distance, where the weight of bit `j` is the certified bit margin `|g j x|`, and each bit pays perturbation budget `L * r` on each of the two competing class scores, hence total pairwise erosion `2 * L * r` per disagreeing bit.

A cleaner corollary, matching the narrative “every active bit-gap exceeds `2Kd * r`,” is:

```lean
theorem soft_ecoc_robust_of_uniform_margin
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r γ : ℝ)
    (hL : BitGapLipschitzOn g L)
    (y⋆ : Fin n) (x : α)
    (hr : 0 ≤ r)
    (hγ : ∀ j, γ ≤ |g j x|)
    (hstrict : 2 * L * r < 2 * γ) :
    ∀ x', dist x x' ≤ r →
      ∀ z, z ≠ y⋆ → softScore C g y⋆ x' > softScore C g z x' := by
  sorry
```

This version is stronger than necessary but easy to apply: if every bit has margin at least `γ > Lr`, then every disagreeing bit contributes a positive residual advantage, and summing over any nonempty disagree set preserves strict positivity.

For the GL3 tropical Satake application, instantiate `L := 2 * Kd` if that is the existing certified gap Lipschitz constant. Then the residual per disagreeing bit is `2 * (|g_j x| - 2 * Kd * r)`.

### Main theorem 3: explicit certified radius from weighted code-distance

The previous theorem is a ball-invariance criterion. It is valuable to package it as an explicit radius lower bound.

Define:

```lean
def pairAdvantage
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y z : Fin n) (x : α) : ℝ :=
  ∑ j in disagreeBits C y z, (2 : ℝ) * |g j x|

def pairDisagreeCount
    (C : CodeMatrix n m) (y z : Fin n) : ℕ :=
  (disagreeBits C y z).card

def certifiedRadius
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (L : ℝ) (y : Fin n) (x : α) : ℝ :=
  sInf {r : ℝ | 0 ≤ r ∧ ∃ z, z ≠ y ∧ pairAdvantage C g y z x ≤ 2 * L * r * pairDisagreeCount C y z}
```

If `sInf` is annoying, use an existential lower-bound formulation instead. A practical theorem is:

```lean
theorem robust_of_radius_lt_min_ratio
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (y⋆ : Fin n) (x : α)
    (hr : 0 ≤ r)
    (hbound :
      ∀ z, z ≠ y⋆ →
        2 * L * r * (pairDisagreeCount C y⋆ z : ℝ)
          < pairAdvantage C g y⋆ z x) :
    ∀ x', dist x x' ≤ r →
      ∀ z, z ≠ y⋆ → softScore C g y⋆ x' > softScore C g z x' := by
  sorry
```

This is the exact “minimum weighted code-distance to competitors” statement in a Lean-manageable form.

### Optional theorem 4: hard Hamming decoding robustness from bit-sign preservation

For hard decoding, the clean route is not to compare cardinalities directly via a global Lipschitz inequality, but to prove that sufficiently large bit margins preserve each individual sign, and therefore preserve every per-class disagreement set exactly.

A precise theorem:

```lean
theorem sign_stable_of_gap_margin
    {m : ℕ}
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (x x' : α)
    (hx' : dist x x' ≤ r)
    (j : Fin m)
    (hj : L * r < |g j x|) :
    Real.sign (g j x') = Real.sign (g j x) := by
  sorry
```

Then deduce:

```lean
theorem hard_ecoc_robust_of_bit_sign_stability
    {n m : ℕ}
    (C : CodeMatrix n m)
    (hC : ValidCodeMatrix C)
    (g : Fin m → α → ℝ)
    (L r : ℝ)
    (hL : BitGapLipschitzOn g L)
    (y⋆ : Fin n) (x : α)
    (hmargin : ∀ j, L * r < |g j x|) :
    ∀ x', dist x x' ≤ r →
      ∀ y, hardScore C g y x' = hardScore C g y x := by
  sorry
```

and therefore any unique hard-decoder winner at `x` remains the unique winner on the ball. If uniqueness is cumbersome, prove score preservation first and state the winner-invariance corollary separately.

### Proof strategy

1. **Algebraic ECOC comparison identity.**  
   Expand
   `softScore C g y x - softScore C g z x`
   as a sum over all bits. Split the sum into the filter where `C y j = C z j` and the complementary filter where they differ. On equal bits the term is zero. On disagreeing bits use `hC` and the fact that two distinct elements of `{1, -1}` are negatives of one another. This gives the exact factor `2 * (C y j : ℝ) * g j x`.

2. **Turn exact comparison into margin lower bounds.**  
   Under the natural correctness/sign condition for the reference class on disagreeing bits,
   `(C y⋆ j : ℝ) * g j x = |g j x|`,
   the pairwise soft-score gap is exactly the weighted sum of certified margins. If proving equality everywhere is awkward, a lower bound suffices. This is the code-distance decomposition: class separation is the sum of bit separations over the Hamming support of the codeword difference.

3. **Propagate perturbations through each bit-gap.**  
   From `hL` and `dist x x' ≤ r`, derive
   `|g j x' - g j x| ≤ L * r`.
   Then show
   `|(C y j : ℝ) * g j x' - (C y j : ℝ) * g j x| ≤ L * r`
   because `|C y j : ℝ| = 1`. Summing over disagreeing bits yields erosion at most
   `L * r * card(disagreeBits ...)` for each class score, hence at most
   `2 * L * r * card(disagreeBits ...)` for the pairwise score difference.

4. **Pairwise-to-multiclass reduction.**  
   Once you have for every competitor `z ≠ y⋆` the strict inequality
   `softScore y⋆ x' > softScore z x'`,
   the decoder output is stable on the whole ball. This reduction is completely finite and should be easy over `Fin n`. If you want a concrete decoder function, use `Finset.argmax` on `Finset.univ` with a tie-breaking convention; but proving strict pairwise dominance is already the essential mathematical content.

5. **Hard-decoding via sign preservation.**  
   For the Hamming decoder, first prove the scalar lemma:
   if `|t' - t| < |t|`, then `Real.sign t' = Real.sign t`. Apply this with `t = g j x`, `t' = g j x'`. Once each bit sign is fixed on the ball, every class’s hard bit-agreement pattern is fixed, hence hard Hamming scores are constant. This avoids delicate direct combinatorics on cardinality under perturbation.

### Lean-specific suggestions

- Use `Finset.sum_filter` and partition by `if h : C y j = C z j then ... else ...`.
- The lemma “if `a, b ∈ ({1, -1} : Set Int)` and `a ≠ b`, then `(b : ℝ) = - (a : ℝ)`” is worth isolating early.
- You will likely need:
  - `abs_mul`, `abs_of_nonneg`, `abs_of_nonpos`
  - `Finset.sum_nonneg`
  - `Finset.card_pos.mpr`
  - `by_cases h : C y j = C z j`
  - coercion facts from `Int` to `ℝ`
- For strict positivity after summing residual margins, it is often cleaner to prove each summand is positive and then use `Finset.sum_pos` on a nonempty disagree set. Nonemptiness follows from `z ≠ y⋆` together with an injectivity/separation assumption on codewords:
  ```lean
  def CodeInjective (C : CodeMatrix n m) : Prop :=
    Function.Injective C
  ```
  Then add `hinj : CodeInjective C` and prove `disagreeBits C y z` is nonempty when `y ≠ z`.

### Why this matters

This theorem would be the first robust multiclass decoding result in the GL3 tropical Satake program that genuinely uses code geometry rather than a flat argmax rule. It shows that tropical Hecke score certificates are compositional: per-bit certified margins aggregate through an ECOC decoder exactly according to weighted Hamming separation. That is mathematically meaningful because it identifies the right invariant at decoder level — a weighted code-distance induced by tropical margins — and not merely a worst-bit bound.

It also creates a reusable bridge between tropical representation-theoretic score constructions and modern robust multiclass learning theory. Once formalized, this result should become the template for further ensemble decoders: truncated margins, abstaining decoders, list decoding, and eventually q-ary tropical codebooks. The weighted-distance theorem is the central object; proving it rigorously in Lean would be a substantial and novel step.

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

Research domain: Bridges
Research mode: prove
