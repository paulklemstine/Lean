## Research Task: Quantitative algebraic-compositional universal approximation for EML networks under finite products and max-composition on compact metric spaces

Research Mode: PROVE

Work in a concrete compact domain first, so the quantitative statements can be made fully explicit in Lean without inventing a large new topological interface. A good target is a compact subset `K : Set ℝ` with `[CompactSpace K]` realized via the subtype, or even more concretely `K = Set.Icc a b` if the current EML API is interval-based. If the existing quantitative EML approximation theorems are already stated for a compact metric space `K`, keep that generality, but make every norm/error statement use the sup norm on bounded continuous functions.

The goal is to prove a reusable approximation calculus: quantitative approximation bounds should propagate through addition, scalar multiplication, multiplication, and `max`. The key point is not mere closure of the exact EML class, but explicit error propagation and explicit size/width growth of the constructed approximants.

### Precise theorem package to aim for

Use a concrete sup-distance on functions:
```lean
def supDist {α : Type*} (K : Set α) (f g : α → ℝ) : ℝ :=
  sSup ((fun x => |f x - g x|) '' K)
```
or, if the existing library already uses bounded continuous functions / `‖f - g‖`, phrase everything in that norm instead.

Introduce an approximation predicate carrying both error and size:
```lean
def ApproximableByEMLOn
    (K : Set α) (f : α → ℝ) (W : ℕ) (ε M : ℝ) : Prop :=
  ∃ F : α → ℝ, IsEMLNetOfWidth F W ∧
    (∀ x ∈ K, |f x - F x| ≤ ε) ∧
    (∀ x ∈ K, |F x| ≤ M)
```
If the existing EML development already has a notion of network realization and width, use its exact structure; the theorem should quantify width explicitly, not just existence in the class.

Then prove the following theorems, or the closest API-compatible variants.

#### 1. Linear combination closure with explicit error
```lean
theorem approximableByEMLOn_finset_sum
    {ι α : Type*} [Fintype ι]
    (K : Set α) (a : ι → ℝ) (f F : ι → α → ℝ)
    (W : ι → ℕ) (ε M : ι → ℝ)
    (hF : ∀ i, IsEMLNetOfWidth (F i) (W i))
    (herr : ∀ i x, x ∈ K → |f i x - F i x| ≤ ε i)
    (hbound : ∀ i x, x ∈ K → |F i x| ≤ M i) :
    ∃ G : α → ℝ, IsEMLNetOfWidth G (∑ i, W i) ∧
      (∀ x, x ∈ K →
        |(∑ i, a i * f i x) - G x| ≤ ∑ i, |a i| * ε i) ∧
      (∀ x, x ∈ K →
        |G x| ≤ ∑ i, |a i| * M i)
```
If exact width addition is not the right combinatorial measure in your EML encoding, replace `∑ i, W i` by the correct explicit upper bound.

A two-function corollary should also be stated:
```lean
theorem approximableByEMLOn_add
    (K : Set α) (f g F G : α → ℝ) (Wf Wg : ℕ) (εf εg Mf Mg : ℝ)
    ... :
    ∃ H : α → ℝ, IsEMLNetOfWidth H (Wf + Wg) ∧
      (∀ x, x ∈ K → |(f x + g x) - H x| ≤ εf + εg) ∧
      (∀ x, x ∈ K → |H x| ≤ Mf + Mg)
```

#### 2. Product closure with Leibniz-type error
This is the central algebraic quantitative lemma.

```lean
theorem approximableByEMLOn_mul
    (K : Set α) (f g F G : α → ℝ) (Wf Wg : ℕ)
    (εf εg Mf Mg Bf Bg : ℝ)
    (hF : IsEMLNetOfWidth F Wf)
    (hG : IsEMLNetOfWidth G Wg)
    (herrF : ∀ x, x ∈ K → |f x - F x| ≤ εf)
    (herrG : ∀ x, x ∈ K → |g x - G x| ≤ εg)
    (hboundF : ∀ x, x ∈ K → |F x| ≤ Mf)
    (hboundG : ∀ x, x ∈ K → |G x| ≤ Mg)
    (hboundf : ∀ x, x ∈ K → |f x| ≤ Bf)
    (hboundg : ∀ x, x ∈ K → |g x| ≤ Bg) :
    ∃ H : α → ℝ, IsEMLNetOfWidth H (mulWidthBound Wf Wg) ∧
      (∀ x, x ∈ K →
        |f x * g x - H x| ≤ Bf * εg + Mg * εf) ∧
      (∀ x, x ∈ K →
        |H x| ≤ Mf * Mg)
```

A symmetric but slightly looser bound may be easier to prove:
```lean
|f x * g x - F x * G x| ≤ Bf * εg + Mg * εf
```
or
```lean
|f x * g x - F x * G x| ≤ Bf * εg + Bg * εf + εf * εg
```
depending on which side you use in the telescoping identity. Then invoke exact EML closure under multiplication to realize `H = F * G` as an EML network with explicit width bound. If exact multiplication is already a verified closure theorem for EML, use that theorem directly.

A finite-product version is highly desirable if feasible:
```lean
theorem approximableByEMLOn_finset_prod
    {ι α : Type*} [Fintype ι]
    (K : Set α) (f F : ι → α → ℝ) ...
    :
    ∃ G : α → ℝ, IsEMLNetOfWidth G (prodWidthBound W) ∧
      (∀ x, x ∈ K →
        |(∏ i, f i x) - G x| ≤ explicitProdErrorBound ...) ∧
      (∀ x, x ∈ K → |G x| ≤ ∏ i, M i)
```
Even a recursive bound over `Finset` is valuable.

#### 3. Max-composition via Lipschitz control
The clean quantitative statement is:
```lean
theorem approximableByEMLOn_max
    (K : Set α) (f g F G : α → ℝ) (Wf Wg : ℕ) (εf εg : ℝ)
    (hF : IsEMLNetOfWidth F Wf)
    (hG : IsEMLNetOfWidth G Wg)
    (herrF : ∀ x, x ∈ K → |f x - F x| ≤ εf)
    (herrG : ∀ x, x ∈ K → |g x - G x| ≤ εg) :
    ∃ H : α → ℝ, IsEMLNetOfWidth H (maxWidthBound Wf Wg) ∧
      (∀ x, x ∈ K →
        |max (f x) (g x) - H x| ≤ max εf εg)
```
A slightly weaker but easier bound
```lean
≤ εf + εg
```
is acceptable if needed, but the sharp `max εf εg` should be reachable from the fact that `(u,v) ↦ max u v` is 1-Lipschitz for the `ℓ∞` norm:
```lean
|max a b - max c d| ≤ max |a - c| |b - d|
```
This is the crucial inequality to formalize.

For the EML realization step, use one of the following routes, depending on what is already available:

1. **Exact route**: if EML already contains `max` or ReLU-like primitives, define
   ```lean
   max a b = b + relu (a - b)
   ```
   and use verified closure under addition/composition.

2. **Log-sum-exp bridge**: if exact `max` is unavailable but the catalog contains
   ```lean
   max(a,b) ≤ log(exp a + exp b) ≤ max(a,b) + log 2
   ```
   then first prove a normalized quantitative approximation
   ```lean
   |max a b - τ * log (exp (a/τ) + exp (b/τ))| ≤ τ * log 2
   ```
   for `τ > 0`, then combine with EML approximation of `exp`/`log` from the EML approximation library. This gives a nontrivial tropical-EML bridge and yields:
   ```lean
   ∀ δ > 0, ∃ H, IsEMLNetOfWidth H Wδ ∧
     ∀ x ∈ K, |max (f x) (g x) - H x| ≤ max εf εg + δ
   ```
   This approximate-max theorem is already a meaningful result if exact max closure is too ambitious in one pass.

#### 4. Unified compositional closure theorem
Package the previous lemmas into a generator-to-closure lifting principle. One good formulation is by induction on a syntax tree of expressions built from generators.

Define an expression type:
```lean
inductive EMLExpr (ι : Type*)
| var : ι → EMLExpr ι
| const : ℝ → EMLExpr ι
| add : EMLExpr ι → EMLExpr ι → EMLExpr ι
| mul : EMLExpr ι → EMLExpr ι → EMLExpr ι
| max : EMLExpr ι → EMLExpr ι → EMLExpr ι
```
with semantics
```lean
def EMLExpr.eval (v : ι → α → ℝ) : EMLExpr ι → α → ℝ
```
and structural complexity measures:
```lean
def EMLExpr.widthCost : EMLExpr ι → ℕ
def EMLExpr.errorProp :
    EMLExpr ι → (ι → ℝ) → (ι → ℝ) → ℝ
```
Then prove:
```lean
theorem approximableByEMLOn_expr
    (K : Set α) (φ : EMLExpr ι) (f F : ι → α → ℝ)
    (W : ι → ℕ) (ε M B : ι → ℝ)
    (hF : ∀ i, IsEMLNetOfWidth (F i) (W i))
    (herr : ∀ i x, x ∈ K → |f i x - F i x| ≤ ε i)
    (hboundF : ∀ i x, x ∈ K → |F i x| ≤ M i)
    (hboundf : ∀ i x, x ∈ K → |f i x| ≤ B i) :
    ∃ G : α → ℝ, IsEMLNetOfWidth G (φ.widthCost.fold W) ∧
      (∀ x, x ∈ K →
        |φ.eval f x - G x| ≤ φ.errorProp ε (fun i => max (M i) (B i))) 
```
You need not optimize the recursion perfectly; a clean structural upper bound is enough. This theorem is the real “calculus” statement: any finite algebra/max expression in approximable generators is approximable with explicit propagated error.

### Proof strategy: concrete steps

1. **Build a sup-norm error API.**  
   First prove pointwise-to-uniform lemmas on compact domains:
   ```lean
   theorem sup_error_add ...
   theorem sup_error_smul ...
   theorem sup_error_mul ...
   theorem sup_error_max ...
   ```
   In particular, prove the elementary inequalities
   ```lean
   |(f+g) - (F+G)| ≤ |f-F| + |g-G|
   |f*g - F*G| ≤ |f|*|g-G| + |G|*|f-F|
   |max a b - max c d| ≤ max |a-c| |b-d|
   ```
   The multiplication estimate is the key algebraic lemma; use
   ```lean
   f*g - F*G = f*(g-G) + G*(f-F)
   ```
   or the symmetric variant with `F` instead of `f`.

2. **Exploit exact EML closure theorems to turn analytic bounds into realizers.**  
   If the catalog already proves that EML functions are closed under `+`, `*`, scalar multiplication, and certain compositions, invoke those exact closure theorems to define the approximant explicitly:
   - `H := fun x => F x + G x`
   - `H := fun x => F x * G x`
   - `H := fun x => max (F x) (G x)` or an EML-realized surrogate  
   Then separately prove the quantitative error bound by pointwise inequalities.

3. **Track width growth structurally.**  
   Width bookkeeping should be explicit and monotone:
   - for addition, typically `Wf + Wg`
   - for scalar multiplication, `Wf`
   - for multiplication, some `mulWidthBound Wf Wg`
   - for max, some `maxWidthBound Wf Wg`  
   If the current EML realization theorems provide depth/size instead of width, adapt the statements to that resource measure, but keep the bounds explicit and compositional.

4. **For `max`, use the sharp Lipschitz lemma rather than a loose triangle argument.**  
   The theorem
   ```lean
   |max a b - max c d| ≤ max |a-c| |b-d|
   ```
   is the right quantitative bridge. It makes the max constructor behave like a 1-Lipschitz operation on pairs, preserving approximation rates optimally. This is the conceptual link to tropical/max-plus structure.

5. **Package everything by structural recursion on expressions.**  
   Once the primitive closure lemmas are done, define a syntax of expressions and prove the general theorem by induction. The recursive step should combine:
   - realizability closure for the constructor,
   - the previously established error propagation inequality,
   - monotone width/error bound combinators.

### Significance

This theorem upgrades the existing EML approximation theory from isolated universal approximation statements to a true compositional calculus. That matters for three reasons:

1. **Reusable approximation architecture.**  
   Instead of re-proving approximation from scratch for every target function, one can derive quantitative EML approximants for any function built from basic approximable generators by finite algebraic and max operations.

2. **Bridge to tropical and idempotent structures.**  
   The `max` constructor connects the EML program to tropical/max-plus analysis. A quantitative `max`-closure theorem is exactly what is needed to compare EML models with tropical ReLU and log-sum-exp approximations already present in the library.

3. **Foundation for a full universal approximation theorem for generated algebras.**  
   Once generator classes are known to approximate coordinate functions or other separating families, this closure theorem gives a mechanism to propagate quantitative rates through the finitely generated algebra/max-envelope. It is the right intermediate result between Stone-Weierstrass existence and an implementable network-synthesis theorem.

### Lean-focused implementation advice

Place the file at:
```lean
EML/Quantitative/AlgebraicMaxClosure.lean
```

A practical theorem order is:

1. elementary real inequalities (`mul` and `max` error bounds),
2. pointwise approximation lemmas for `add`, `smul`, `mul`, `max`,
3. width-aware EML closure realizers,
4. finite-sum / finite-product corollaries,
5. expression-language lifting theorem.

If exact general compact metric spaces are cumbersome in the first pass, prove the full quantitative theorem on `K : Set ℝ` compact, or on `K = Set.Icc a b`, with a clean abstraction boundary so it can later be generalized. A complete theorem on intervals with explicit bounds is substantially better than an over-general statement left with `sorry`.

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

Research domain: EML
Research mode: prove
