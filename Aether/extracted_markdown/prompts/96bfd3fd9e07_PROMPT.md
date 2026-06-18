## Research Task: Tropical certified robustness for multiclass residual piecewise-linear networks under ECOC decoding

Research Mode: PROVE

Formulate the decoder in a way that is fully Lean-friendly and prove a clean robustness theorem first in a purely combinatorial/Hamming form, then derive the analytic certificate from coordinatewise margin/Lipschitz hypotheses.

A good concrete setup is:

- an input type `α` with a metric or normed structure, preferably `α := EuclideanSpace ℝ (Fin n)` or `α := Fin n → ℝ`
- `m : ℕ` code bits, `C : Type` finite class set with `[Fintype C] [DecidableEq C]`
- codewords `code : C → Fin m → Bool` or equivalently `Fin m → SignType`; `Bool` is easiest for Hamming arguments
- bit scores `f : α → Fin m → ℝ`
- predicted bit at radius-0 point `x` given by `bitPred f x i := 0 ≤ f x i`
- ECOC agreement score
  ```lean
  def agreement (code : C → Fin m → Bool) (b : Fin m → Bool) (c : C) : ℕ :=
    ((Finset.univ.filter fun i => b i = code c i).card)
  ```
- decoder as strict argmax/uniqueness statement rather than an arbitrary `argmax`, since robustness is really a comparison theorem:
  ```lean
  def IsUniqueDecoder
    (code : C → Fin m → Bool) (b : Fin m → Bool) (c : C) : Prop :=
    ∀ d, d ≠ c → agreement code b c > agreement code b d
  ```

For the analytic side, define:
```lean
def bitPred (f : α → Fin m → ℝ) (x : α) (i : Fin m) : Bool := 0 ≤ f x i

def margin (f : α → Fin m → ℝ) (x : α) (i : Fin m) : ℝ := |f x i|

def CanFlipAtRadius
  (f : α → Fin m → ℝ) (K : Fin m → ℝ) (x : α) (r : ℝ) (i : Fin m) : Prop :=
  margin f x i ≤ K i * r
```
or, if you want the cleaner “certified preserved sign” formulation,
```lean
def StableBitAtRadius
  (f : α → Fin m → ℝ) (K : Fin m → ℝ) (x : α) (r : ℝ) (i : Fin m) : Prop :=
  K i * r < |f x i|
```
Then the key analytic lemma should say: if `f_i` is `K i`-Lipschitz and `K i * r < |f x i|`, then for every `y` with `dist y x ≤ r`, the sign of `f y i` equals the sign of `f x i`.

### Theorem 1: combinatorial ECOC robustness from a bit-flip budget

First prove a purely discrete theorem, independent of neural networks.

Suggested Lean signature:
```lean
theorem ecoc_unique_of_flip_budget
  {C : Type} [Fintype C] [DecidableEq C]
  {m : ℕ}
  (code : C → Fin m → Bool)
  (b b' : Fin m → Bool)
  (c : C)
  (hdec : IsUniqueDecoder code b c)
  (hbudget : ∀ d, d ≠ c →
    ((Finset.univ.filter fun i => b i ≠ b' i ∧ code c i ≠ code d i).card)
      < ((Finset.univ.filter fun i => code c i ≠ code d i).card) / 2 + (((Finset.univ.filter fun i => code c i ≠ code d i).card) % 2))
  : IsUniqueDecoder code b' c
```

But an even better theorem is one that avoids needing `hdec` as an extra hypothesis by assuming the exact codeword agreement at `x`:

```lean
theorem ecoc_unique_of_less_than_half_flips_on_each_disagreement
  {C : Type} [Fintype C] [DecidableEq C]
  {m : ℕ}
  (code : C → Fin m → Bool)
  (b : Fin m → Bool)
  (c : C)
  (hmatch : ∀ i, b i = code c i)
  (hbudget : ∀ d, d ≠ c →
    2 * ((Finset.univ.filter fun i => b i ≠ code c i ∧ code c i ≠ code d i).card)
      < ((Finset.univ.filter fun i => code c i ≠ code d i).card))
  : IsUniqueDecoder code b c
```

However, the most useful form for perturbation is:

```lean
theorem ecoc_stable_under_flip_budget
  {C : Type} [Fintype C] [DecidableEq C]
  {m : ℕ}
  (code : C → Fin m → Bool)
  (b₀ b : Fin m → Bool)
  (c : C)
  (hbase : ∀ i, b₀ i = code c i)
  (hbudget : ∀ d, d ≠ c →
    2 * ((Finset.univ.filter fun i => b i ≠ b₀ i ∧ code c i ≠ code d i).card)
      < ((Finset.univ.filter fun i => code c i ≠ code d i).card))
  : IsUniqueDecoder code b c
```

This is the exact coding-theoretic heart: among the coordinates where `c` and `d` differ, fewer than half are allowed to flip away from the baseline codeword of `c`.

#### Proof strategy
1. For fixed `d ≠ c`, let
   ```lean
   Dcd := Finset.univ.filter fun i => code c i ≠ code d i
   ```
   Partition `Dcd` into bits where `b i = code c i` and bits where `b i = code d i`. On `Dcd`, these are complementary because `code c i ≠ code d i`.
2. Show:
   ```lean
   agreement code b c - agreement code b d
   = Dcd.card - 2 * ((Dcd.filter fun i => b i ≠ code c i).card)
   ```
   or at least derive the strict positivity of this difference from the budget hypothesis.
3. Use the pointwise baseline assumption `hbase` to rewrite
   ```lean
   b i ≠ code c i
   ```
   as
   ```lean
   b i ≠ b₀ i
   ```
   on `Dcd`.
4. Conclude that if fewer than half of the bits in `Dcd` have flipped, then `agreement code b c > agreement code b d`.
5. Since this holds for every competitor `d`, obtain `IsUniqueDecoder code b c`.

The essential combinatorial lemma worth isolating is:
```lean
lemma agreement_gap_on_disagreement_set
  {u v b : Fin m → Bool} :
  agreement₂ b u - agreement₂ b v
    = ((Finset.univ.filter fun i => u i ≠ v i ∧ b i = u i).card : ℤ)
      - ((Finset.univ.filter fun i => u i ≠ v i ∧ b i = v i).card : ℤ)
```
where `agreement₂ b u := ((Finset.univ.filter fun i => b i = u i).card)`.
A nat-only variant is also fine if subtraction becomes annoying.

### Theorem 2: analytic sign-stability from coordinatewise margins and Lipschitz bounds

Now prove the per-bit certificate turning tropical/Lipschitz control into a no-flip statement.

Suggested signature:
```lean
theorem sign_stable_of_abs_lt_margin
  {α : Type} [PseudoMetricSpace α]
  (f : α → ℝ) (K r : ℝ) (x : α)
  (hLip : ∀ y, |f y - f x| ≤ K * dist y x)
  (hK : 0 ≤ K) (hr : 0 ≤ r)
  (hmargin : K * r < |f x|)
  :
  ∀ y, dist y x ≤ r → ((0 ≤ f y) ↔ (0 ≤ f x))
```

For vector-valued scores:
```lean
theorem bitPred_stable_of_coordinate_margin
  {α : Type} [PseudoMetricSpace α]
  {m : ℕ}
  (f : α → Fin m → ℝ)
  (K : Fin m → ℝ)
  (x : α) (r : ℝ)
  (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
  (hK : ∀ i, 0 ≤ K i)
  (hr : 0 ≤ r)
  (hmargin : ∀ i, K i * r < |f x i|)
  :
  ∀ y, dist y x ≤ r → ∀ i, bitPred f y i = bitPred f x i
```

#### Proof strategy
1. From `|f y - f x| ≤ K * dist y x ≤ K * r < |f x|`, derive `|f y - f x| < |f x|`.
2. Prove a scalar lemma: if `|a - b| < |a|`, then `a` and `b` have the same sign in the weak-Boolean sense `(0 ≤ a) ↔ (0 ≤ b)`. This can be shown by contradiction using `abs_sub_lt_iff`.
3. Apply this scalar lemma coordinatewise with `a = f x i`, `b = f y i`.
4. Rewrite `bitPred` by definition.
5. This gives a pointwise no-flip certificate for all bits satisfying the margin condition.

If the existing tropical residual-network theory already gives a certified radius
```lean
r_i^*(x) = |f x i| / (2 * K i)
```
or a theorem of the shape “for `dist y x ≤ r`, score variation is bounded by `K i * r`”, use that directly. The only real new ingredient is converting the coordinatewise score certificate into a decoder-level ECOC certificate.

### Theorem 3: ECOC robustness from preserved-sign majority on each competitor disagreement set

This is the main target theorem. State it so that the network output at `x` already matches the codeword of the predicted class.

Suggested signature:
```lean
theorem ecoc_decoder_robust_of_coordinate_certificates
  {α : Type} [PseudoMetricSpace α]
  {C : Type} [Fintype C] [DecidableEq C]
  {m : ℕ}
  (code : C → Fin m → Bool)
  (f : α → Fin m → ℝ)
  (K : Fin m → ℝ)
  (x : α) (r : ℝ) (c : C)
  (hbase : ∀ i, bitPred f x i = code c i)
  (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
  (hK : ∀ i, 0 ≤ K i)
  (hr : 0 ≤ r)
  (hsep : ∀ d, d ≠ c →
    2 * ((Finset.univ.filter fun i => code c i ≠ code d i ∧ |f x i| ≤ K i * r).card)
      < ((Finset.univ.filter fun i => code c i ≠ code d i).card))
  :
  ∀ y, dist y x ≤ r → IsUniqueDecoder code (bitPred f y) c
```

This theorem says: among the bits relevant for separating `c` from `d`, strictly fewer than half are uncertified at radius `r`; therefore every perturbation in the ball preserves enough pairwise code agreement to keep `c` uniquely optimal.

A slightly stronger weighted version is also valuable if you can make it clean:

```lean
theorem ecoc_decoder_robust_of_weighted_margin_budget
  {α : Type} [PseudoMetricSpace α]
  {C : Type} [Fintype C] [DecidableEq C]
  {m : ℕ}
  (code : C → Fin m → Bool)
  (wt : Fin m → ℝ)
  (f : α → Fin m → ℝ)
  (K : Fin m → ℝ)
  (x : α) (r : ℝ) (c : C)
  (hwt_nonneg : ∀ i, 0 ≤ wt i)
  (hbase : ∀ i, bitPred f x i = code c i)
  (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
  (hK : ∀ i, 0 ≤ K i)
  (hr : 0 ≤ r)
  (hsep : ∀ d, d ≠ c →
    2 * ∑ i in (Finset.univ.filter fun i => code c i ≠ code d i ∧ |f x i| ≤ K i * r), wt i
      < ∑ i in (Finset.univ.filter fun i => code c i ≠ code d i), wt i)
  :
  ∀ y, dist y x ≤ r →
    ∀ d, d ≠ c →
      ∑ i in (Finset.univ.filter fun i => bitPred f y i = code c i ∧ code c i ≠ code d i), wt i
        >
      ∑ i in (Finset.univ.filter fun i => bitPred f y i = code d i ∧ code c i ≠ code d i), wt i
```

You may first prove the unweighted theorem and then derive the weighted version by replacing cardinalities with weighted sums over disagreement sets.

#### Proof strategy
1. For each `y` in the ball and each bit `i`, if `|f x i| > K i * r`, then by Theorem 2 the sign cannot flip, hence
   ```lean
   bitPred f y i = bitPred f x i = code c i.
   ```
2. Therefore any bit that differs from the baseline codeword on `y` must lie in the uncertified set
   ```lean
   U_r := {i | |f x i| ≤ K i * r }.
   ```
   On each pairwise disagreement set `D(c,d)`, the actual flips are contained in `D(c,d) ∩ U_r`.
3. The hypothesis `hsep` says that on every `D(c,d)`, the uncertified subset has cardinality strictly less than half of `D(c,d)`.
4. Apply Theorem 1 with baseline bit-vector `b₀ := bitPred f x` and perturbed bit-vector `b := bitPred f y`.
5. Conclude `IsUniqueDecoder code (bitPred f y) c` for all `y` with `dist y x ≤ r`.

### A useful corollary in terms of per-bit certified radii

If you define
```lean
def certRadius (f : α → Fin m → ℝ) (K : Fin m → ℝ) (x : α) (i : Fin m) : ℝ :=
  |f x i| / K i
```
or, if matching existing catalog normalization, `|f x i| / (2 * K i)`, then prove a reformulation:

```lean
theorem ecoc_decoder_robust_of_pairwise_radius_count
  {α : Type} [PseudoMetricSpace α]
  {C : Type} [Fintype C] [DecidableEq C]
  {m : ℕ}
  (code : C → Fin m → Bool)
  (f : α → Fin m → ℝ)
  (K : Fin m → ℝ)
  (x : α) (r : ℝ) (c : C)
  (hbase : ∀ i, bitPred f x i = code c i)
  (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
  (hK : ∀ i, 0 < K i)
  (hr : 0 ≤ r)
  (hcount : ∀ d, d ≠ c →
    2 * ((Finset.univ.filter fun i => code c i ≠ code d i ∧ certRadius f K x i ≤ r).card)
      < ((Finset.univ.filter fun i => code c i ≠ code d i).card))
  :
  ∀ y, dist y x ≤ r → IsUniqueDecoder code (bitPred f y) c
```

This is often the most interpretable theorem: robustness holds whenever, for every competing class, fewer than half of the code bits separating it from `c` have certified radius at most `r`.

### Significance

This theorem is the natural coding-theoretic extension of tropical certified robustness from one-vs-all or argmax logits to structured multiclass decoders. It shows that coordinatewise tropical margins do not merely certify individual bit stability; when aggregated through an ECOC code, they yield a strictly stronger decoder-level certificate governed by pairwise code distances. Formally, it bridges:
- local tropical/Lipschitz control of each residual score coordinate,
- combinatorial Hamming geometry of codewords,
- global stability of the final multiclass decision on an entire perturbation ball.

This matters because ECOC decoders are genuinely different from standard multiclass heads: robustness is no longer about preserving a single maximal logit, but about preserving enough pairwise code agreements against every competitor. A clean Lean formalization here would create a reusable theorem schema for certified robustness of structured decoders and should generalize further to weighted ECOC, abstention decoders, and product-code architectures.

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

Research domain: MachineLearning
Research mode: prove
