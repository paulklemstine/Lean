## Research Task: Tropical Satake support reconstruction for GL₃ via min-plus hypersimplex facet data implying convolution-faithfulness on the dominant chamber

**Research Mode: PROVE**

Develop a precise GL₃ support-reconstruction theorem for tropical Satake transforms of finitely supported dominant-coweight functions, and use it to deduce left-cancellation / convolution-faithfulness on the dominant chamber.

The goal is to upgrade “injectivity of the transform” to a genuinely polyhedral statement: the lower-facet data of the min-plus Newton polytope should recover the maximal dominant support, and then an induction on support size should recover the full support and the extremal coefficients. The final algebraic consequence should be a cancellation theorem for tropical convolution by a nonzero element.

---

### 1. Concrete setup to formalize

Work with dominant coweights for `GL₃` encoded as pairs `(a,b) : ℕ × ℕ`, corresponding to the coweight
\[
(a+b,\; b,\; 0),
\]
so dominance is built in by construction. This avoids quotient issues and keeps all combinatorics in `ℕ × ℕ`.

Define the tropical monomial attached to `(a,b)` by the linear form
\[
L_{(a,b)}(x,y) = a x + b y
\]
on the dominant chamber
\[
\{(x,y)\in \mathbb R^2 : 0 \le y \le x\}.
\]
For a finitely supported coefficient function
\[
f : (\mathbb N \times \mathbb N) \to \mathbb R \cup \{\infty\}
\]
with finite support and finite values on support, define its tropical Satake transform as the min-plus polynomial
\[
\operatorname{trop}(f)(x,y) := \inf_{(a,b)\in \operatorname{supp}(f)} \big(f(a,b) + a x + b y\big).
\]
Since support is finite, this is a finite `Finset.inf'` / `Finset.min'` construction.

A robust Lean model is to keep coefficients in `ℝ` first, and define
```lean
def TropCoeff := ℝ
def DomWt := ℕ × ℕ
def tropEval (f : DomWt →₀ TropCoeff) (x y : ℝ) : ℝ := ...
```
using `Finsupp` and a finite minimum over `f.support`.

Also define the product order on `DomWt`:
```lean
def DomWt.le (u v : DomWt) : Prop := u.1 ≤ v.1 ∧ u.2 ≤ v.2
```
and the set of maximal support elements:
```lean
def maximalSupport (f : DomWt →₀ ℝ) : Finset DomWt := ...
```
where `u ∈ maximalSupport f` iff `u ∈ f.support` and every `v ∈ f.support` with `u ≤ v` satisfies `v = u`.

This is the correct tropical analogue of “top support” on the dominant chamber: if `(x,y)` is deep in the chamber with `x ≫ y ≫ 0`, terms with larger `(a,b)` dominate the lower hull.

---

### 2. Precise theorem targets

You should aim for the following Lean-level statements, perhaps in this order.

#### A. Maximal-support separation by dominant directions
For distinct incomparable dominant weights, there is a dominant direction separating their linear forms.

A good exact signature is:
```lean
theorem dominant_direction_separates
    {u v : ℕ × ℕ}
    (hneq : u ≠ v)
    (hincomp : ¬ ((u.1 ≤ v.1 ∧ u.2 ≤ v.2) ∨ (v.1 ≤ u.1 ∧ v.2 ≤ u.2))) :
    ∃ p q : ℕ,
      q ≤ p ∧
      (u.1 : ℤ) * p + (u.2 : ℤ) * q ≠ (v.1 : ℤ) * p + (v.2 : ℤ) * q
```
and, more strongly, one of the two values is strictly larger:
```lean
theorem dominant_direction_strictly_orders
    {u v : ℕ × ℕ}
    (hneq : u ≠ v) :
    ∃ p q : ℕ, q ≤ p ∧
      ((u.1 : ℤ) * p + (u.2 : ℤ) * q < (v.1 : ℤ) * p + (v.2 : ℤ) * q ∨
       (v.1 : ℤ) * p + (v.2 : ℤ) * q < (u.1 : ℤ) * p + (u.2 : ℤ) * q)
```
This is the basic “facet normal exists” lemma in the discrete dominant chamber.

#### B. Every maximal support weight is exposed on some dominant ray
For a nonzero finitely supported `f`, each maximal support weight uniquely minimizes the tropical transform along some sufficiently deep dominant ray.

A usable formal statement:
```lean
theorem maximal_support_exposed
    (f : (ℕ × ℕ) →₀ ℝ)
    {u : ℕ × ℕ}
    (hu : u ∈ maximalSupport f) :
    ∃ p q : ℕ, q ≤ p ∧
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      ∀ v ∈ f.support,
        v ≠ u →
        f u + ((u.1 : ℝ) * (n*p) + (u.2 : ℝ) * (n*q))
          < f v + ((v.1 : ℝ) * (n*p) + (v.2 : ℝ) * (n*q))
```
This says `u` gives the unique active facet/monomial on a dominant cone.

A more evaluation-oriented corollary:
```lean
theorem maximal_support_attains_unique_min_on_ray
    (f : (ℕ × ℕ) →₀ ℝ)
    {u : ℕ × ℕ}
    (hu : u ∈ maximalSupport f) :
    ∃ p q : ℕ, q ≤ p ∧
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      tropEval f (n*p) (n*q)
        = f u + ((u.1 : ℝ) * (n*p) + (u.2 : ℝ) * (n*q))
```

#### C. Converse: exposed dominant rays recover maximal support
If a support element is uniquely minimizing along an unbounded dominant ray, then it is maximal in support.

```lean
theorem uniquely_exposed_implies_maximal
    (f : (ℕ × ℕ) →₀ ℝ)
    {u : ℕ × ℕ}
    (hex :
      ∃ p q : ℕ, q ≤ p ∧
      ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
        ∀ v ∈ f.support,
          v ≠ u →
          f u + ((u.1 : ℝ) * (n*p) + (u.2 : ℝ) * (n*q))
            < f v + ((v.1 : ℝ) * (n*p) + (v.2 : ℝ) * (n*q))) :
    u ∈ maximalSupport f
```

Together, A–C give the desired support/facet dictionary on the dominant chamber.

#### D. Recovery of maximal support from equality of tropical transforms
If two finitely supported tropical polynomials agree on all dominant points, then they have the same maximal support and same coefficients on maximal support.

```lean
theorem tropEval_eq_implies_same_maximal_support
    {f g : (ℕ × ℕ) →₀ ℝ}
    (hfg : ∀ x y : ℝ, 0 ≤ y → y ≤ x → tropEval f x y = tropEval g x y) :
    maximalSupport f = maximalSupport g
```

And the coefficient recovery theorem:
```lean
theorem tropEval_eq_implies_eq_on_maximal_support
    {f g : (ℕ × ℕ) →₀ ℝ}
    (hfg : ∀ x y : ℝ, 0 ≤ y → y ≤ x → tropEval f x y = tropEval g x y) :
    ∀ u, u ∈ maximalSupport f → f u = g u
```

#### E. Recursive peeling / full support reconstruction
Define deletion of the recovered maximal layer:
```lean
def eraseMaxLayer (f : (ℕ × ℕ) →₀ ℝ) : (ℕ × ℕ) →₀ ℝ := ...
```
where coefficients on `maximalSupport f` are set to zero.

Prove:
```lean
theorem support_card_eraseMaxLayer_lt
    (f : (ℕ × ℕ) →₀ ℝ)
    (hne : f ≠ 0) :
    (eraseMaxLayer f).support.card < f.support.card
```

Then prove by induction on `f.support.card`:

```lean
theorem tropEval_injective_on_finsupp
    {f g : (ℕ × ℕ) →₀ ℝ}
    (hfg : ∀ x y : ℝ, 0 ≤ y → y ≤ x → tropEval f x y = tropEval g x y) :
    f = g
```

This is the genuine GL₃ support-reconstruction theorem.

#### F. Tropical convolution-faithfulness on the dominant chamber
Define tropical convolution on `DomWt →₀ ℝ` by
\[
(f ⋆ g)(\lambda) = \min_{\mu+\nu=\lambda} (f(\mu)+g(\nu)),
\]
with addition on pairs componentwise. In Lean:
```lean
def tropConv (f g : (ℕ × ℕ) →₀ ℝ) : (ℕ × ℕ) →₀ ℝ := ...
```
or, if full `Finsupp` output is awkward, first prove equality after evaluation:
```lean
theorem tropEval_tropConv
    (f g : (ℕ × ℕ) →₀ ℝ) :
    ∀ x y, tropEval (tropConv f g) x y = tropEval f x y + tropEval g x y
```
This is the min-plus multiplicativity of the tropical transform.

Then cancellation follows:

```lean
theorem tropConv_left_cancel
    {f g h : (ℕ × ℕ) →₀ ℝ}
    (hf : f ≠ 0)
    (hconv : tropConv f g = tropConv f h) :
    g = h
```

A transform-level version may be easier first:
```lean
theorem tropConv_faithful_on_dominant_chamber
    {f g h : (ℕ × ℕ) →₀ ℝ}
    (hf : f ≠ 0)
    (hconv : ∀ x y, 0 ≤ y → y ≤ x →
      tropEval (tropConv f g) x y = tropEval (tropConv f h) x y) :
    g = h
```
The point is that a nonzero `f` has finite tropical transform, so from
\[
\operatorname{trop}(f⋆g)=\operatorname{trop}(f)+\operatorname{trop}(g)
\]
and equality of convolutions, cancel the additive function `tropEval f` pointwise, then invoke injectivity.

---

### 3. Proof strategy: concrete steps

#### Step 1: Build the dominant-ray separation lemma
For any distinct `u = (a,b)` and `v = (c,d)`, consider
\[
(a-c)p + (b-d)q.
\]
Because `p,q` are constrained only by `0 ≤ q ≤ p`, you can choose:
- `q = 0` to detect difference in the first coordinate,
- `q = p` to detect difference in the sum `a+b`,
- or intermediate `q` when needed.

A useful elementary lemma is that if `u` and `v` are incomparable in product order, then either:
- `u.1 > v.1` and `u.2 < v.2`, or vice versa;
then choosing the ratio `q/p` sufficiently small or sufficiently close to `1` separates them. In Lean over naturals, avoid division: choose explicit integer pairs like `(p,q) = (v.2 - u.2 + 1, 1)` or similar after case splitting. The actual theorem only needs existence of some `p,q : ℕ` with `q ≤ p`.

This is the GL₃ replacement for “distinct slopes” in GL₂: hypersimplex/facet normals in rank 2 are encoded by dominant directions `0 ≤ q ≤ p`.

#### Step 2: Show maximal support weights are exactly the exposed ones
If `u` is maximal in support, then for each `v ≠ u` in support:
- either `v` is incomparable with `u`, and Step 1 gives a direction where `u·w > v·w`,
- or `v ≤ u` coordinatewise and `v ≠ u`, hence for any strictly positive dominant direction one has `v·w < u·w`.

Because support is finite, combine finitely many strict inequalities into one common direction `(p,q)` by intersecting finitely many open conditions on the slope `q/p`. After obtaining strict linear separation
\[
u\cdot w > v\cdot w \quad \forall v\neq u,
\]
convert it into eventual unique minimization of
\[
f(v)+v\cdot (n w)
\]
for large `n`. The key analytic lemma is finite-support asymptotic domination:
```lean
theorem eventually_linear_term_dominates_constant
    {A B : ℝ} {δ : ℝ} (hδ : 0 < δ) :
    ∃ N : ℕ, ∀ n ≥ N, A < B + n * δ
```
or a rearranged version. This lets strict slope separation overpower coefficient differences.

For the converse, if some `v > u` coordinatewise is in support, then along every dominant direction one has `u·w ≤ v·w`, and along every strictly interior direction one gets strict inequality eventually in favor of `v`; hence `u` cannot be uniquely exposed on an unbounded dominant ray. This proves “exposed iff maximal.”

#### Step 3: Recover coefficients on maximal support
Once `u` is uniquely active along a ray `(np,nq)`, evaluation gives
\[
\operatorname{trop}(f)(np,nq)=f(u)+n(u\cdot w).
\]
If `tropEval f = tropEval g` on the chamber and `u` is maximal for `f`, the same ray must eventually expose some term of `g`; by the converse theorem it must be maximal for `g`, and by uniqueness of the linear growth rate it must be the same `u`. Subtracting the known linear term yields
\[
f(u)=g(u).
\]
In Lean, this is just algebra after evaluating equality at sufficiently large `n`.

#### Step 4: Peel the maximal layer and induct on support size
Once maximal support and its coefficients are reconstructed, define `eraseMaxLayer f`. Prove:
- `eraseMaxLayer f` has strictly smaller support when `f ≠ 0`,
- tropical equality of `f` and `g` implies tropical equality of their peeled versions.

The second point is the subtle one. You do **not** need literal pointwise subtraction of tropical polynomials. Instead argue:
1. maximal layers coincide with equal coefficients;
2. therefore after removing them from both supports, the new maximal layers of the residual functions control the next asymptotic regime on dominant rays not already accounted for;
3. package this as an induction on support cardinality.

If direct “residual tropical polynomial” manipulation is awkward, an alternative is to prove:
```lean
theorem exists_maximal_support_disagreement_exposed
    {f g : (ℕ × ℕ) →₀ ℝ}
    (hne : f ≠ g) :
    ∃ u, u ∈ maximalSupport (f -? g in support sense) ∧ ...
```
But in Lean this may be more cumbersome. The cleaner route is induction using finite antichains and support-cardinality reduction.

#### Step 5: Deduce convolution-faithfulness via transform multiplicativity
For tropical convolution,
\[
\operatorname{trop}(f⋆g) = \operatorname{trop}(f) + \operatorname{trop}(g)
\]
pointwise on the chamber. This should be proved by unfolding the minimum over decompositions:
\[
\min_{\lambda=\mu+\nu}(f(\mu)+g(\nu)+\langle \lambda,x\rangle)
=
\min_\mu(f(\mu)+\langle \mu,x\rangle)+\min_\nu(g(\nu)+\langle \nu,x\rangle).
\]
Because support is finite, this is a finite-min distributivity lemma over `Finset.product`.

Then if `f ⋆ g = f ⋆ h`, evaluating gives
\[
\trop(f)+\trop(g)=\trop(f)+\trop(h).
\]
Cancel the common real-valued summand pointwise:
```lean
have : ∀ x y, 0 ≤ y → y ≤ x → tropEval g x y = tropEval h x y := by
  intro x y hy0 hyx
  have h1 := congrArg (fun t => t - tropEval f x y) (hconv_eval x y hy0 hyx)
  linarith
```
and conclude `g = h` from injectivity. The assumption `hf : f ≠ 0` matters to exclude degenerate empty-support conventions and to ensure the transform is the genuine finite minimum of at least one affine function.

---

### 4. Important supporting lemmas to isolate

These are worth stating separately because they are the real combinatorial engine.

```lean
theorem not_maximal_iff_exists_strictly_larger
    (f : (ℕ × ℕ) →₀ ℝ) {u : ℕ × ℕ} (hu : u ∈ f.support) :
    u ∉ maximalSupport f ↔
      ∃ v ∈ f.support, u.1 ≤ v.1 ∧ u.2 ≤ v.2 ∧ u ≠ v
```

```lean
theorem strict_domination_along_ray
    {u v : ℕ × ℕ} {p q : ℕ}
    (hsep : (u.1 : ℤ) * p + (u.2 : ℤ) * q >
            (v.1 : ℤ) * p + (v.2 : ℤ) * q) :
    ∃ N : ℕ, ∀ n ≥ N,
      f u + ((u.1 : ℝ) * (n*p) + (u.2 : ℝ) * (n*q))
        <
      f v + ((v.1 : ℝ) * (n*p) + (v.2 : ℝ) * (n*q))
```
with the inequality direction adjusted to your min-plus convention.

```lean
theorem finite_support_has_maximal_element
    (f : (ℕ × ℕ) →₀ ℝ) (hne : f ≠ 0) :
    ∃ u, u ∈ maximalSupport f
```
This is a finite-poset lemma for product order on `ℕ × ℕ`.

```lean
theorem maximalSupport_nonempty_iff
    (f : (ℕ × ℕ) →₀ ℝ) :
    maximalSupport f = ∅ ↔ f = 0
```

```lean
theorem tropEval_eq_of_support_eq_and_coeff_eq
    {f g : (ℕ × ℕ) →₀ ℝ}
    (hs : f.support = g.support)
    (hc : ∀ u ∈ f.support, f u = g u) :
    tropEval f = tropEval g
```
This is elementary but useful when closing the induction.

---

### 5. Why this matters

This theorem is not just another injectivity statement. It identifies the exact GL₃ combinatorial mechanism behind tropical Satake rigidity: dominant support is encoded in the lower-facet geometry of the min-plus Newton polytope, and rank-2 chamber directions already suffice to reconstruct it. That is the first genuinely polyhedral reconstruction theorem in the GL₃ tropical Hecke setting.

The significance for the broader program is threefold:

1. **Conceptual upgrade from injectivity to geometry.**  
   Instead of merely showing that equal transforms imply equal functions, you show how support is read off from exposed dominant facets and how coefficients are recovered asymptotically. This is the right tropical analogue of recovering highest weights from Newton data.

2. **A GL₃ prototype for higher-rank tropical Satake theory.**  
   GL₂ relies on edge slopes; GL₃ requires facet/hypersimplex combinatorics. Formalizing this successfully should clarify the pattern for `GL_n`, where maximal support should correspond to exposed cells of the lower hull over the dominant Weyl chamber.

3. **A strong algebraic payoff: convolution-faithfulness.**  
   Once transform multiplicativity and support reconstruction are in place, cancellation by any nonzero element becomes formal. This gives a robust tropical semiring analogue of domain-like behavior for the dominant-chamber Hecke algebra and should be a key tool for any later work on tropical Satake equivalence, tropical canonical bases, or higher-rank tropical representation growth.

The ideal outcome is a file containing:
- the dominant-ray exposure lemmas,
- maximal-support reconstruction,
- coefficient recovery,
- induction to full injectivity,
- and the convolution left-cancellation theorem.

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

Research domain: Tropical
Research mode: prove
