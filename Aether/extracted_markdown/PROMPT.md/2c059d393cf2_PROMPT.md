## YOUR ASSIGNMENT: Certified algorithmic extraction of tropical low-rank approximants from max-plus density

Work in the setting of compact metric spaces sampled by finite nets, and turn the nonconstructive max-plus density theorem into an explicit approximation pipeline with certified error and complexity bounds.

### Core definitions to introduce

You need a clean separation between:

1. **Abstract existence layer** on compact spaces, using the previously established density theorem.
2. **Computable finite-net layer** on finite samples, where witnesses are extracted by brute-force or finite optimization.
3. **Complexity layer** defining the tropical approximation rank.

A robust formalization path is:

```lean
/-- A single separable max-plus tensor term. -/
structure MaxPlusTerm (X Y : Type _) where
  c : ℝ
  a : X → ℝ
  b : Y → ℝ

/-- Evaluation of one separable max-plus tensor term. -/
def MaxPlusTerm.eval {X Y : Type _} (t : MaxPlusTerm X Y) : X → Y → ℝ :=
  fun x y => t.c + t.a x + t.b y

/-- Finite max of separable max-plus tensor terms. -/
def MaxPlusApprox {X Y : Type _} (ts : Finset (MaxPlusTerm X Y)) : X → Y → ℝ :=
  fun x y => ts.sup fun t => t.eval x y
```

For computable extraction on finite samples, use finite types:

```lean
/-- Tropical ε-rank on a finite grid: least number of max-plus separable terms
    needed to approximate `f` within `ε` in sup norm. -/
def tropicalRankEps
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (ε : ℝ) : ℕ :=
  sInf {n : ℕ | ∃ ts : Fin n → MaxPlusTerm X Y,
    ∀ x y, |f x y - Finset.univ.sup (fun i => (ts i).eval x y)| ≤ ε}
```

Since `sInf` on naturals can be annoying, a more Lean-friendly first version is:

```lean
def RealizesWithin
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (ε : ℝ) (n : ℕ) : Prop :=
  ∃ ts : Fin n → MaxPlusTerm X Y,
    ∀ x y, |f x y - Finset.univ.sup (fun i => (ts i).eval x y)| ≤ ε

def tropicalRankEps
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (ε : ℝ) : ℕ :=
  Nat.findGreatest (fun n => False) 0
```

But this placeholder is not useful. Better: define rank as a `Nat` chosen from existence plus minimization only after proving existence of some witness. A very workable alternative is:

```lean
def tropicalRankEpsSet
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (ε : ℝ) : Set ℕ :=
  {n | ∃ ts : Fin n → MaxPlusTerm X Y,
    ∀ x y, |f x y - Finset.univ.sup (fun i => (ts i).eval x y)| ≤ ε}
```

and prove nonemptiness first; define the actual rank later with `sInf`.

You should also define a version restricted to prescribed dictionaries `A : Finset (X → ℝ)` and `B : Finset (Y → ℝ)`:

```lean
structure DictTerm (X Y : Type _) where
  c : ℝ
  a : X → ℝ
  b : Y → ℝ

def InDict
    {X Y : Type _} (A : Finset (X → ℝ)) (B : Finset (Y → ℝ))
    (t : DictTerm X Y) : Prop :=
  t.a ∈ A ∧ t.b ∈ B
```

Then the approximation theorem should use terms drawn from `A,B`.

---

## Precise target theorems

### 1. Nonconstructive existence from density

First prove a clean existence theorem extracted from the density result.

A plausible Lean signature is:

```lean
theorem exists_maxplus_tensor_approx_of_eps
    {X Y : Type _}
    [TopologicalSpace X] [TopologicalSpace Y]
    [CompactSpace X] [CompactSpace Y]
    (A : Set (C(X, ℝ))) (B : Set (C(Y, ℝ)))
    (hA : separatesPoints A)
    (hB : separatesPoints B)
    (hAconst : ∀ c : ℝ, (ContinuousMap.const _ c) ∈ A)
    (hBconst : ∀ c : ℝ, (ContinuousMap.const _ c) ∈ B)
    (f : C(X × Y, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ n : ℕ, ∃ ts : Fin n → (ℝ × C(X, ℝ) × C(Y, ℝ)),
      ‖f - ContinuousMap.ofFun
        (fun p =>
          Finset.univ.sup (fun i =>
            (ts i).1 + (ts i).2.1 p.1 + (ts i).2.2 p.2))
        (by continuity)‖ < ε := by
  ...
```

If `ContinuousMap.ofFun` is cumbersome, define an explicit continuous map constructor from finite sup of continuous maps. You will likely need a lemma:

```lean
lemma continuous_finset_sup
    {α : Type _} [TopologicalSpace α]
    {s : Finset ι} {f : ι → α → ℝ}
    (hcont : ∀ i, Continuous (f i)) :
    Continuous (fun x => s.sup fun i => f i x)
```

possibly under `[DecidableEq ι]` and using induction on `Finset`.

This theorem is the bridge: it says density is not merely closure, but can always be witnessed by a finite tropical tensor expansion.

### 2. Finite-grid exact extractor

On finite types, build an explicit witness. Here the theorem should be fully constructive.

A strong and realistic target:

```lean
theorem exists_exact_maxplus_representation_finite
    {X Y : Type _} [Fintype X] [Fintype Y] [DecidableEq X] [DecidableEq Y]
    (f : X → Y → ℝ) :
    ∃ ts : Fin (Fintype.card X * Fintype.card Y) → MaxPlusTerm X Y,
      ∀ x y,
        f x y = Finset.univ.sup (fun i => (ts i).eval x y) := by
  ...
```

This is revolutionary because on a finite grid every matrix is exactly a max-plus sum of rank-1 separable atoms. The canonical witness is one term per pair `(x₀,y₀)`:

- `c = f x₀ y₀`
- `a x = if x = x₀ then 0 else -M`
- `b y = if y = y₀ then 0 else -M`

for sufficiently large `M`, so the target point dominates and all others are suppressed. Since the domain is finite, choose `M` from the finite range of `f`. A cleaner normalized form is even better:

- `a x = if x = x₀ then 0 else -D`
- `b y = if y = y₀ then 0 else -D`
- `c = f x₀ y₀`

with `D > max_{x,y,x',y'} |f x y - f x' y'|`.

Then:
- at `(x₀,y₀)` the term equals `f x₀ y₀`,
- elsewhere it is at most `f x₀ y₀ - D`,
- so the sup over all anchor pairs recovers exactly `f`.

This theorem is the finite combinatorial heart of the whole program.

### 3. Approximate extractor from finite ε-net

Now transfer from compact metric spaces to finite samples.

Define a sampled approximation theorem. A workable formulation:

```lean
theorem eval_constructApprox
    {X Y : Type _} [MetricSpace X] [MetricSpace Y]
    [CompactSpace X] [CompactSpace Y]
    (f : C(X × Y, ℝ))
    (S : Finset X) (T : Finset Y)
    (hS : IsClosed ((↑S : Set X)) := by sorry) -- or use explicit net structure instead
    (hcoverS : ∀ x : X, ∃ s ∈ S, dist x s ≤ δX)
    (hcoverT : ∀ y : Y, ∃ t ∈ T, dist y t ≤ δY)
    {ω : ℝ → ℝ}
    (hmod : ∀ p q, |f p - f q| ≤ ω (dist p q))
    (hωmono : Monotone ω)
    :
    ∃ ts : Fin (S.card * T.card) → MaxPlusTerm X Y,
      ∀ x y,
        |f (x,y) - Finset.univ.sup (fun i => (ts i).eval x y)|
          ≤ ω (δX + δY) := by
  ...
```

This may be easier if you first define the sampled matrix
`fST : S → T → ℝ`, apply the finite exact representation theorem, and then extend each finite function on `S` and `T` to all of `X,Y` using nearest-net projection or piecewise constant extension. If continuity becomes a burden, first prove a **sampled certified approximation theorem** without continuity of the output, then later upgrade to continuous dictionary-based approximants.

A more practical theorem for current infrastructure is:

```lean
theorem approx_terms_bound_of_coveringNumber
    {X Y : Type _} [MetricSpace X] [MetricSpace Y]
    [CompactSpace X] [CompactSpace Y]
    (f : C(X × Y, ℝ)) {ε : ℝ} (hε : 0 < ε)
    (ω : ℝ → ℝ)
    (hmod : ∀ p q, |f p - f q| ≤ ω (dist p q))
    :
    ∃ N : ℕ, ∃ ts : Fin N → MaxPlusTerm X Y,
      (∀ x y,
        |f (x,y) - Finset.univ.sup (fun i => (ts i).eval x y)| < ε) ∧
      N ≤ coveringNumber X (ωinv (ε/2)) * coveringNumber Y (ωinv (ε/2)) := by
  ...
```

If `coveringNumber` and `ωinv` are not yet in the library, define a weaker but formalizable bound in terms of explicit finite nets supplied as data.

### 4. Tropical approximation complexity invariant

Define the invariant and prove its structural properties.

```lean
def tropicalRankEps
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (ε : ℝ) : ℕ :=
  sInf {n : ℕ | RealizesWithin f ε n}
```

Then prove:

```lean
theorem tropicalRankEps_mono
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) {ε₁ ε₂ : ℝ}
    (hε : ε₁ ≤ ε₂) :
    tropicalRankEps f ε₂ ≤ tropicalRankEps f ε₁ := by
  ...
```

```lean
theorem tropicalRankEps_subadditive
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f g : X → Y → ℝ) {ε₁ ε₂ : ℝ} :
    tropicalRankEps (fun x y => f x y + g x y) (ε₁ + ε₂)
      ≤ tropicalRankEps f ε₁ + tropicalRankEps g ε₂ := by
  ...
```

This second theorem may be too ambitious if your representation uses max of separable sums, because ordinary addition of two max-plus sums expands as pairwise sums of terms, giving a **multiplicative** bound:
`rank(f+g) ≤ rank(f) * rank(g)`.
That is actually more natural and stronger structurally for tropical algebra. So a better theorem is:

```lean
theorem tropicalRankEps_add_mul
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f g : X → Y → ℝ) {ε₁ ε₂ : ℝ} :
    tropicalRankEps (fun x y => f x y + g x y) (ε₁ + ε₂)
      ≤ tropicalRankEps f ε₁ * tropicalRankEps g ε₂ := by
  ...
```

Also prove max-subadditivity:

```lean
theorem tropicalRankEps_max_add
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f g : X → Y → ℝ) {ε₁ ε₂ : ℝ} :
    tropicalRankEps (fun x y => max (f x y) (g x y)) (max ε₁ ε₂)
      ≤ tropicalRankEps f ε₁ + tropicalRankEps g ε₂ := by
  ...
```

This one aligns perfectly with max-plus algebra: concatenate the term families for `f` and `g`.

---

## Concrete proof strategy

### Strategy A: Finite exact representation first, then compact approximation
This is the most promising route.

1. **Prove a finite exact decomposition theorem** for arbitrary `f : X → Y → ℝ` on finite `X,Y`.
   - Enumerate points of `X × Y`.
   - For each anchor `(x₀,y₀)`, build a sharply localized separable term.
   - Use a finite oscillation bound `D` to ensure off-anchor suppression.
   - Show the sup over all anchor terms equals `f` pointwise.

2. **Derive finite ε-rank existence** immediately:
   - Exact representation gives `RealizesWithin f ε (card X * card Y)` for every `ε > 0`.
   - Hence `tropicalRankEpsSet f ε` is nonempty.
   - This allows a clean `sInf` definition and basic order properties.

3. **Lift to compact metric spaces via finite nets**:
   - Choose finite `δX`- and `δY`-nets `S,T`.
   - Restrict `f` to `S × T`.
   - Apply the finite exact theorem on the sample grid.
   - Extend the resulting terms from the net to all of `X,Y` using selected nearest-net points or dictionary interpolation.
   - Bound the total error by the modulus of continuity of `f`.

4. **Recover the abstract density theorem as a corollary**:
   - Once you have explicit finite-net approximants with certified error, the closure theorem becomes computationally witnessed.
   - This turns a pure existence result into a certified algorithm.

Key lemmas you will likely need:
- finite sup continuity / evaluation lemmas,
- existence of finite oscillation bounds for functions on finite types,
- `Finset.sup` manipulations,
- pointwise error propagation under `max`,
- cardinality bookkeeping for concatenated or product-indexed term families.

### Strategy B: Extract directly from Stone–Weierstrass closure
This is conceptually elegant but likely harder in Lean.

1. Identify the algebra/lattice generated by separable max-plus tensors.
2. Show every element of the generated closure can be represented by a finite `sup` of basic terms.
3. Use the density theorem to obtain approximants inside this generated set.
4. Normalize the generated expression into a canonical finite family of terms.

This is beautiful if the closure theorem already exposes an inductive grammar of generated functions. If not, Strategy A is much more implementable.

### Strategy C: Dictionary-restricted approximation
If the catalog already has finite separating families `A` and `B`, work relative to them.

1. Approximate the target by an element in the max-plus algebra generated by `A` and `B`.
2. Prove a normal form theorem: every finitely generated element equals a finite sup of terms `c + a + b` with `a ∈ A`, `b ∈ B`.
3. Define a computable search over finite coefficient vectors.
4. Obtain a certified witness by finite enumeration on finite samples.

This is the right route if your existing density theorem is phrased in terms of generated EML algebras rather than arbitrary continuous functions.

---

## Important intermediate lemmas to isolate

These are likely the real proof bottlenecks; isolate them cleanly.

```lean
lemma finite_range_bdd
    {X : Type _} [Fintype X] (f : X → ℝ) :
    ∃ M, ∀ x, f x ≤ M
```

```lean
lemma exists_separation_constant
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) :
    ∃ D > 0, ∀ x y x' y',
      f x y - D ≤ f x' y' + D
```

But better: directly define
`D = (sup f) - (inf f) + 1`.

```lean
lemma anchor_term_le_off_anchor
    {X Y : Type _} [Fintype X] [Fintype Y] [DecidableEq X] [DecidableEq Y]
    (f : X → Y → ℝ) (D : ℝ) (hD : ...)
    (x₀ : X) (y₀ : Y) :
    let t := anchoredTerm f D x₀ y₀
    in
    t.eval x₀ y₀ = f x₀ y₀ ∧
    (∀ (x ≠ x₀) y, t.eval x y ≤ f x₀ y₀ - D) ∧
    (∀ x (y ≠ y₀), t.eval x y ≤ f x₀ y₀ - D)
```

```lean
lemma sup_anchor_terms_eq
    {X Y : Type _} [Fintype X] [Fintype Y] [DecidableEq X] [DecidableEq Y]
    (f : X → Y → ℝ) :
    ∃ ts : Fin (Fintype.card X * Fintype.card Y) → MaxPlusTerm X Y,
      ∀ x y, Finset.univ.sup (fun i => (ts i).eval x y) = f x y
```

```lean
lemma realizesWithin_of_exact
    {X Y : Type _} [Fintype X] [Fintype Y]
    (f : X → Y → ℝ) (n : ℕ)
    (h : ∃ ts : Fin n → MaxPlusTerm X Y,
      ∀ x y, f x y = Finset.univ.sup (fun i => (ts i).eval x y)) :
    RealizesWithin f ε n
```

```lean
lemma tropicalRankEps_nonempty
    {X Y : Type _} [Fintype X] [Fintype Y] [DecidableEq X] [DecidableEq Y]
    (f : X → Y → ℝ) (hε : 0 ≤ ε) :
    (tropicalRankEpsSet f ε).Nonempty
```

---

## Lean engineering guidance

- Prefer **finite types** and `Fin n → ...` over arbitrary `Finset`-indexed families for the first implementation. `Fin` makes cardinality and witness extraction cleaner.
- If `Finset.sup` over `ℝ` causes typeclass friction due to no top element, use `sup'` with a proof of nonemptiness:
  ```lean
  Finset.sup' Finset.univ Finset.univ_nonempty ...
  ```
  or define approximants for `n+1` terms to avoid empty-family edge cases.
- For exact finite representation, index terms by `X × Y` using `Fintype.equivFin`.
- Use `Classical` locally if needed for choosing nearest-net points.
- Keep the noncomputable compact-space theorem separate from the executable finite-grid extractor. This distinction matters.

---

## Why this matters

This is not “just” an approximation theorem. It upgrades a closure statement into a **certified tropical compiler**:

- It gives an explicit algorithmic shadow of the max-plus Stone–Weierstrass theorem.
- It introduces a new complexity invariant `tropicalRankEps(f)` that can organize an entire theory of tropical compressibility, analogous to classical nonlinear widths and matrix rank, but adapted to EML/max-plus geometry.
- It creates a formal bridge between:
  - tropical functional analysis,
  - constructive approximation theory,
  - low-rank factorization,
  - and algorithmic representation learning.

On finite grids, the exact decomposition theorem says every real matrix is a max-plus superposition of separable potentials. That is a foundational structural statement for tropical analogues of:
- matrix factorization,
- attention-style score decomposition,
- morphological image operators,
- and idempotent signal processing.

On compact spaces, the finite-net extraction theorem gives a certified route from abstract density to executable approximants. This is the first step toward a full formal theory of:
- tropical Kolmogorov widths,
- certified compression of continuous kernels,
- and eventually tropical analogues of Mercer/SVD decompositions.

If a full covering-number theorem is too ambitious in one pass, prioritize:
1. finite exact representation,
2. ε-rank existence/nonemptiness,
3. monotonicity and max/add structural inequalities,
4. then the compact finite-net approximation theorem.

---

## Minimum viable theorem package

If you need to stage the work, the strongest acceptable milestone package is:

```lean
theorem exists_exact_maxplus_representation_finite ...
theorem tropicalRankEps_nonempty ...
theorem tropicalRankEps_mono ...
theorem tropicalRankEps_max_add ...
```

with a precise conjectural next theorem:

```lean
conjecture approx_terms_bound_of_coveringNumber
    {X Y : Type _} [MetricSpace X] [MetricSpace Y]
    [CompactSpace X] [CompactSpace Y]
    (f : C(X × Y, ℝ)) :
    ∃ C : ℕ → ℕ → ℕ, ∀ ε > 0,
      tropicalRankEps_continuous f ε ≤
        C (coveringNumber X (ε/4)) (coveringNumber Y (ε/4))
```

State any missing notions explicitly and formalize the strongest version you can support now.

---

## FUTURE_DIRECTIONS.md

Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps. They must be specific and theorem-level. Include at least:
1. a tropical singular-value / width theory based on `tropicalRankEps`,
2. a dictionary-restricted approximation theorem with explicit search complexity,
3. a continuous-kernel compression theorem for Lipschitz `f : X × Y → ℝ`,
4. a comparison theorem between tropical ε-rank and classical nonnegative/Boolean/max-plus matrix ranks on finite spaces.

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

Research domain: Computation
Research mode: prove
