## Research Task: GL3 tropical Satake to ECOC robustness theorem for Hecke score ensembles

Research Mode: PROVE

Formulate and prove a robust ECOC decoding theorem built on the already-established tropical margin/Lipschitz control for individual GL3 tropical Hecke score maps. The goal is to pass from coordinatewise certified stability of finitely many Hecke-derived classifiers to global multiclass prediction invariance under nearest-codeword decoding.

### Core objects to formalize

Work with:
- a finite class set `C := Fin n`
- a finite alphabet of coordinate predictions; for the cleanest first theorem, take binary coordinates `Bool`
- codewords `code : Fin n → Fin m → Bool`
- a family of real-valued score gaps `gap : Fin m → α → ℝ`
- coordinate Lipschitz constants `L : Fin m → ℝ`
- a perturbation relation `Perturb : α → α → ℝ → Prop`

Interpret coordinate `j` as predicting the bit
`bit j x := 0 ≤ gap j x`
or equivalently `decide (0 ≤ gap j x)` after choosing a concrete Bool encoding.

The intended GL3 tropical Hecke specialization is:
- each `gap j x` is the tropical Satake score difference between the code bit prescribed for the target class and the opposite bit, reconstructed from bounded-support dominant-coweight test data;
- each `L j` is a certified Lipschitz bound coming from the existing tropical/Hecke finite test-family machinery.

### Precise theorem statements to aim for

First prove the coding lemma in a clean combinatorial form.

```lean
def hammingDist {m : ℕ} (u v : Fin m → Bool) : ℕ :=
  ((Finset.univ.filter fun j => u j ≠ v j).card)

def codeDist {n m : ℕ} (code : Fin n → Fin m → Bool) : ℕ :=
  sInf {d : ℕ | ∃ c c' : Fin n, c ≠ c' ∧ hammingDist (code c) (code c') = d}

def nearestUnique
    {n m : ℕ} (code : Fin n → Fin m → Bool) (y : Fin m → Bool) (c : Fin n) : Prop :=
  ∀ c' : Fin n, c' ≠ c → hammingDist y (code c) < hammingDist y (code c')
```

A more usable distance hypothesis should avoid `sInf`; define instead:

```lean
def MinDistAtLeast {n m : ℕ} (code : Fin n → Fin m → Bool) (δ : ℕ) : Prop :=
  ∀ c c' : Fin n, c ≠ c' → δ ≤ hammingDist (code c) (code c')
```

Then prove:

```lean
theorem nearest_codeword_unique_of_lt_half_minDist
    {n m δ : ℕ} {code : Fin n → Fin m → Bool}
    (hδ : MinDistAtLeast code δ)
    {c : Fin n} {y : Fin m → Bool}
    (hy : hammingDist y (code c) < δ / 2) :
    nearestUnique code y c
```

Because `Nat.div` is awkward, you will likely want the stronger and cleaner hypothesis

```lean
(hy : 2 * hammingDist y (code c) < δ)
```

and conclude uniqueness by triangle inequality for Hamming distance:
`dist(code c, code c') ≤ dist(code c, y) + dist(y, code c')`.

Next define coordinatewise stability from a signed margin inequality.

```lean
def CoordStable
    {m : ℕ} {α : Type*}
    (gap : Fin m → α → ℝ)
    (Perturb : α → α → ℝ → Prop)
    (L : Fin m → ℝ) : Prop :=
  ∀ j x x' r, Perturb x x' r →
    |gap j x' - gap j x| ≤ L j * r
```

For a fixed class `c`, define the clean coordinate prediction induced by the code bit:

```lean
def agreesWithCode
    {n m : ℕ} {α : Type*}
    (code : Fin n → Fin m → Bool)
    (gap : Fin m → α → ℝ) (c : Fin n) (x : α) (j : Fin m) : Prop :=
  if code c j then 0 ≤ gap j x else gap j x ≤ 0
```

A strict-margin version is more useful:

```lean
def strictAgreesWithCode
    {n m : ℕ} {α : Type*}
    (code : Fin n → Fin m → Bool)
    (gap : Fin m → α → ℝ) (c : Fin n) (x : α) (j : Fin m) (r : ℝ) (L : Fin m → ℝ) : Prop :=
  if code c j then L j * r < gap j x else L j * r < - gap j x
```

Prove the coordinate stability lemma:

```lean
theorem bit_fixed_of_margin
    {α : Type*} {Perturb : α → α → ℝ → Prop}
    {gap : Fin m → α → ℝ} {L : Fin m → ℝ}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {x x' : α} {r : ℝ} (hr : 0 ≤ r) (hxx' : Perturb x x' r)
    {j : Fin m}
    (hmargin_pos : L j * r < gap j x) :
    0 < gap j x'
```

and the negative analogue

```lean
theorem bit_fixed_of_margin_neg
    {α : Type*} {Perturb : α → α → ℝ → Prop}
    {gap : Fin m → α → ℝ} {L : Fin m → ℝ}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {x x' : α} {r : ℝ} (hr : 0 ≤ r) (hxx' : Perturb x x' r)
    {j : Fin m}
    (hmargin_neg : L j * r < - gap j x) :
    gap j x' < 0
```

These are the bridge from tropical margin lower bounds to invariant coordinate bits.

Now package the robust decoding theorem. Define the predicted bit vector:

```lean
def predBits {m : ℕ} {α : Type*} (gap : Fin m → α → ℝ) (x : α) : Fin m → Bool :=
  fun j => decide (0 ≤ gap j x)
```

Define the “bad coordinates” for class `c` at input `x` and radius `r`:

```lean
def badCoords
    {n m : ℕ} {α : Type*}
    (code : Fin n → Fin m → Bool)
    (gap : Fin m → α → ℝ) (L : Fin m → ℝ)
    (c : Fin n) (x : α) (r : ℝ) : Finset (Fin m) :=
  Finset.univ.filter fun j =>
    if code c j then gap j x ≤ L j * r else -gap j x ≤ L j * r
```

The good coordinates are those whose margin dominates the perturbation budget, hence cannot flip.

A main theorem should look like:

```lean
theorem ecoc_robust_of_coordinate_margins
    {n m δ : ℕ} {α : Type*}
    {code : Fin n → Fin m → Bool}
    {gap : Fin m → α → ℝ}
    {L : Fin m → ℝ}
    {Perturb : α → α → ℝ → Prop}
    (hδ : MinDistAtLeast code δ)
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {c : Fin n} {x : α} {r : ℝ}
    (hr : 0 ≤ r)
    (hclean : predBits gap x = code c)
    (hbad : 2 * (badCoords code gap L c x r).card < δ)
    :
    ∀ x', Perturb x x' r → nearestUnique code (predBits gap x') c
```

This theorem says: if fewer than `δ/2` coordinates lack sufficient margin at the clean point, then every admissible perturbation preserves unique nearest-codeword decoding to class `c`.

A slightly stronger and often easier-to-use variant is to avoid `hclean : predBits gap x = code c` by baking the sign constraints into the bad-set definition and assuming exact code agreement coordinatewise outside the bad set. But the above is the most natural target.

### Weighted / pairwise margin strengthening

After the unweighted binary theorem, prove a refined rival-wise statement that better matches the “pairwise tropical Satake margins” formulation.

For each class pair define the disagreement set:
```lean
def disagreeSet {n m : ℕ} (code : Fin n → Fin m → Bool) (c c' : Fin n) : Finset (Fin m) :=
  Finset.univ.filter fun j => code c j ≠ code c' j
```

Then define the pairwise robust margin count:
```lean
def robustDisagreeCount
    {n m : ℕ} {α : Type*}
    (code : Fin n → Fin m → Bool)
    (gap : Fin m → α → ℝ) (L : Fin m → ℝ)
    (c : Fin n) (x : α) (r : ℝ) (c' : Fin n) : ℕ :=
  ((disagreeSet code c c').filter fun j =>
    if code c j then L j * r < gap j x else L j * r < - gap j x).card
```

Target theorem:

```lean
theorem ecoc_robust_of_pairwise_majority_margins
    {n m : ℕ} {α : Type*}
    {code : Fin n → Fin m → Bool}
    {gap : Fin m → α → ℝ}
    {L : Fin m → ℝ}
    {Perturb : α → α → ℝ → Prop}
    (hLip : ∀ j x x' r, Perturb x x' r → |gap j x' - gap j x| ≤ L j * r)
    {c : Fin n} {x : α} {r : ℝ}
    (hr : 0 ≤ r)
    (hclean : predBits gap x = code c)
    (hpair :
      ∀ c', c' ≠ c →
        2 * ((disagreeSet code c c').card - robustDisagreeCount code gap L c x r c')
          < (disagreeSet code c c').card)
    :
    ∀ x', Perturb x x' r →
      nearestUnique code (predBits gap x') c
```

Interpretation: for each rival `c'`, strictly more than half of the coordinates on which `c` and `c'` differ have enough certified margin to remain fixed, so after perturbation `predBits gap x'` is still closer to `code c` than to `code c'`. This avoids introducing a global minimum distance and is closer to the rival-wise Satake margin picture.

If subtraction on naturals becomes annoying, reformulate with an explicit lower bound:
```lean
2 * robustDisagreeCount ... > (disagreeSet code c c').card
```

### Proof strategy

1. **Coordinate sign preservation from Lipschitz control.**  
   For each coordinate `j`, combine
   `|gap j x' - gap j x| ≤ L j * r`
   with either `L j * r < gap j x` or `L j * r < - gap j x`.
   Use
   `gap j x' ≥ gap j x - |gap j x' - gap j x|`
   and
   `gap j x' ≤ gap j x + |gap j x' - gap j x|`
   to prove the sign of `gap j` cannot change. In Lean, `nlinarith` should dispatch these after extracting the two inequalities from `abs_le.mp`.

2. **Bound the number of flipped coordinates by the bad-set cardinality.**  
   Show:
   ```lean
   hammingDist (predBits gap x') (code c) ≤ (badCoords code gap L c x r).card
   ```
   because every coordinate outside `badCoords` is certified fixed by Step 1, and `hclean` identifies the clean prediction with `code c`. The cleanest proof is by rewriting Hamming distance as the card of a filtered `Finset.univ` and proving pointwise implication:
   if a coordinate differs at `x'`, then it must have been bad at `x`.

3. **Invoke Hamming nearest-codeword uniqueness.**  
   From Step 2 and `2 * card(badCoords ...) < δ`, derive
   `2 * hammingDist (predBits gap x') (code c) < δ`.
   Then apply `nearest_codeword_unique_of_lt_half_minDist`.

4. **Pairwise version via disagreement counting.**  
   For each rival `c' ≠ c`, restrict attention to `disagreeSet code c c'`.
   Coordinates outside this set contribute equally to distances from `code c` and `code c'`, so only disagreement coordinates matter. If strictly more than half of them are fixed in favor of `c`, then
   ```lean
   hammingDist (predBits gap x') (code c) <
   hammingDist (predBits gap x') (code c')
   ```
   This yields `nearestUnique` directly rival-by-rival, bypassing a separate minimum-distance theorem.

5. **GL3 tropical Hecke specialization.**  
   After the abstract theorem is in place, instantiate `gap j x` with the difference of two GL3 tropical Satake/Hecke scores already known to satisfy:
   - finite reconstruction from dominant-coweight test families,
   - explicit margin positivity criteria,
   - Lipschitz bounds under the perturbation model.
   The specialization theorem should have the same shape as `ecoc_robust_of_coordinate_margins`, with hypotheses expressed in terms of the existing GL3 margin theorem rather than arbitrary `gap`.

### Lean implementation advice

- Prefer the binary-code theorem first. Ternary ECOC can be handled later by replacing `Bool` with `Fin 3` and decomposing each ternary symbol into pairwise score-gap certificates.
- Define Hamming distance on functions `Fin m → Bool` via filtered cardinality of `Finset.univ`; this makes finite counting lemmas straightforward.
- You will likely need a Hamming triangle inequality:
  ```lean
  theorem hammingDist_triangle
      {m : ℕ} (u v w : Fin m → Bool) :
      hammingDist u w ≤ hammingDist u v + hammingDist v w
  ```
  Prove it by showing the mismatch set for `(u,w)` is contained in the union of mismatch sets for `(u,v)` and `(v,w)`, then use `Finset.card_union_le`.
- A useful exact decomposition for pairwise proofs is:
  ```lean
  hammingDist y (code c') =
    hammingDist y (code c) +
    ((disagreeSet code c c').filter ...).card
    - ...
  ```
  but in Lean, an inequality proof by partitioning `disagreeSet` into fixed vs. unfixed coordinates is often easier than chasing exact formulas with `Nat` subtraction.
- When using `decide (0 ≤ gap j x)`, convert Bool equalities to propositions with `by_cases h : 0 ≤ gap j x`; simp [predBits, h]`.
- For strict inequalities over reals, `linarith`/`nlinarith` should be enough once the absolute-value bounds are unpacked.

### Significance

This theorem is a genuine cross-domain bridge: it upgrades single-score tropical Satake margin certification into multiclass certified robustness via coding theory. The novelty is that the base classifiers are not arbitrary piecewise-linear networks but structured GL3 tropical Hecke score maps arising from finite dominant-coweight test families. Proving this establishes a reusable abstraction layer:
- **representation-theoretic tropical margins** give coordinatewise stability,
- **coding distance** amplifies those local certificates into multiclass robustness,
- **nearest-codeword decoding** converts several weak Hecke classifiers into a provably stable ensemble.

This would materially advance the tropical Hecke/robustness program by showing that Satake-style margin theorems compose nontrivially, and it provides the right formal infrastructure for later ternary Hecke symbols, GLn generalizations, and certified robustness statements for structured ensembles beyond generic neural networks.

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
