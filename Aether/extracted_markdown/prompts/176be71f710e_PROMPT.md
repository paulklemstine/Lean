## Research Task: EML Stone–Weierstrass via lattice–algebra closure

Research Mode: PROVE

Work in a new file
`EML/StoneWeierstrassLattice.lean`.

The right formal target is a concrete Stone–Weierstrass theorem for a subclass
`A : Set C(X, ℝ)` of continuous real-valued functions on a compact space `X`,
assuming lattice closure (`⊔`, `⊓`), algebra closure (`*`), constants, and
point separation. The most Lean-friendly formulation is in terms of uniform
ε-approximation rather than abstract closure operators.

### Precise theorem statements

Use `X` as a compact topological space, preferably under
`[TopologicalSpace X] [CompactSpace X]`.
If Hausdorff/normality is needed for Urysohn-style separation or compactness
arguments, strengthen to `[T2Space X]` (and, if needed, `[NormalSpace X]`,
though compact Hausdorff should usually suffice through existing instances).

A first main theorem should look like:

```lean
theorem stoneWeierstrass_lattice_algebra_real
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    ∀ (f : C(X, ℝ)) (ε : ℝ), 0 < ε →
      ∃ g ∈ A, ‖f - g‖ < ε
```

Depending on available lemmas for the norm on `C(X, ℝ)`, you may want the
conclusion in pointwise sup-norm form:

```lean
theorem stoneWeierstrass_lattice_algebra_real_eps
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    ∀ (f : C(X, ℝ)) (ε : ℝ), 0 < ε →
      ∃ g ∈ A, ∀ x : X, |f x - g x| < ε
```

Then derive a closure/density corollary in whatever notion of closure is most
convenient in Mathlib. A robust target is:

```lean
theorem stoneWeierstrass_lattice_algebra_real_dense
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    Dense A
```

but this exact statement may not typecheck because `Dense` is for sets in the
ambient topological space and `A` need not already be topologically interpreted
in the right way. If needed, instead prove the ε-approximation theorem above
and package density afterwards using `Metric.mem_closure_iff` or the relevant
`mem_closure_iff` for pseudo-metric spaces.

A very useful intermediate lemma is the two-point interpolation/separation
upgrade:

```lean
theorem exists_mem_A_eq_of_ne
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    ∀ {x y : X}, x ≠ y → ∀ a b : ℝ, ∃ g ∈ A, g x = a ∧ g y = b
```

This lemma is the algebraic engine: from any separator `f` with `f x ≠ f y`,
form
`g = c₀ + c₁ * f`
where
`c₁ = (a - b) / (f x - f y)` and `c₀ = a - c₁ * f x`.
To make this formal, you will likely need closure of `A` under scalar
multiplication by real constants. Since only constants and multiplication are
assumed, derive scalar multiplication internally as multiplication by a
constant function:

```lean
lemma smul_mem_of_const_mul
    (hconst : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A) :
    ∀ (c : ℝ) ⦃f : C(X, ℝ)⦄, f ∈ A → c • f ∈ A
```

and also closure under affine combinations with constants:

```lean
lemma add_const_mul_mem
    ...
    : ∀ (a b : ℝ) ⦃f : C(X, ℝ)⦄, f ∈ A →
        (fun x => a + b * f x) ∈ A
```

If addition is not assumed and not derivable directly, avoid this formulation
at first and instead prove closure under positive/negative parts via lattice
operations, then recover addition using the vector lattice identity
`f + g = (f ⊔ g) + (f ⊓ g)`, but that still uses `+`. So a crucial early step is
to check whether your intended “EML-generated class” already lives naturally as
a subalgebra / additive subspace in the existing development. If yes, strengthen
the assumptions to include:

```lean
(hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
(hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
```

This is mathematically natural and likely necessary for a clean theorem.
If you can derive `hadd` and `hneg` from earlier EML closure results, do so and
state the main theorem with those hypotheses included. In practice, the cleanest
formal theorem is probably:

```lean
theorem stoneWeierstrass_sublattice_subalgebra_real
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hmul : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f * g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    ∀ (f : C(X, ℝ)) (ε : ℝ), 0 < ε → ∃ g ∈ A, ‖f - g‖ < ε
```

This is still fully aligned with the research direction, and is much more
realistic to formalize cleanly.

### Proof strategy

1. **Upgrade point separation to exact two-point interpolation.**  
   For `x ≠ y` and prescribed values `a b : ℝ`, pick `u ∈ A` with
   `u x ≠ u y`. Build an affine rescaling
   `g = α • u + β` so that `g x = a` and `g y = b`.
   This is the standard linear-algebra reduction from separation to
   interpolation. The key calculation is:
   - `α = (a - b) / (u x - u y)`
   - `β = a - α * u x`
   Then verify `g ∈ A` using constants, additive closure, negation, and
   multiplication by constants. This lemma is what lets you control values at
   selected points exactly.

2. **Construct local lower/upper approximants around each point.**  
   Fix `f : C(X, ℝ)`, `ε > 0`, and a point `x : X`.
   For every `y ≠ x`, use the two-point interpolation lemma to obtain
   `g_xy ∈ A` with
   `g_xy x = f x` and `g_xy y = f y`.
   By continuity of `f` and `g_xy`, the strict inequality
   `g_xy z > f z - ε` remains true on some open neighborhood `U_xy` of `y`,
   while still having `g_xy x < f x + ε` at the anchor point.
   Compactness of `X` lets you extract a finite subcover of the neighborhoods
   `U_xy` (together with possibly a neighborhood of `x` itself). Taking the
   finite infimum of the corresponding functions yields a single `g_x ∈ A`
   satisfying:
   - `g_x x > f x - ε`
   - `∀ z, g_x z ≤ f z + ε`
   or the symmetric variant with lower/upper bounds depending on how you set up
   inequalities.
   This is the core lattice step: finite `⊓` lets you patch finitely many local
   controls while preserving the global upper bound.

3. **Patch finitely many anchor-point approximants using finite suprema.**  
   The open sets on which `g_x > f - ε` cover `X` as `x` varies.
   By compactness, extract finitely many points `x₁, …, x_n` so that the
   corresponding neighborhoods cover `X`.
   Define
   `g = g_{x₁} ⊔ ... ⊔ g_{x_n}`.
   Since `A` is closed under finite suprema, `g ∈ A`. Then:
   - from the global upper bounds on each `g_x`, deduce `g ≤ f + ε`;
   - from the local lower bound on the covering neighborhood of each point,
     deduce `f - ε ≤ g`.
   Hence `∀ z, |f z - g z| ≤ ε`, and by shrinking constants slightly in the
   construction you can obtain strict `< ε`.

4. **Package the pointwise estimate into the sup norm.**  
   Use the norm on `C(X, ℝ)`:
   `‖f - g‖ = sSup {‖(f - g) x‖ | x : X}` (or the relevant Mathlib theorem),
   and show that the pointwise estimate implies `‖f - g‖ ≤ ε`, then improve to
   `< ε` by running the argument with `ε/2`.
   This “ε/2 trick” is usually much cleaner in Lean than managing strict
   inequalities throughout the compactness patching stage.

5. **Derive the closure/density corollary.**  
   From `∀ ε > 0, ∃ g ∈ A, ‖f - g‖ < ε`, conclude `f ∈ closure A`. If desired,
   state the final theorem as:
   ```lean
   theorem stoneWeierstrass_sublattice_subalgebra_real_closure :
     closure A = Set.univ
   ```
   or
   ```lean
   theorem stoneWeierstrass_sublattice_subalgebra_real_dense :
     Dense A
   ```
   depending on whichever interface is smoother in Mathlib.

### Important intermediate lemmas to formalize

These are worth proving separately because they will likely be reused in EML
applications.

```lean
lemma sup_mem_finset
    {X : Type*} [TopologicalSpace X]
    (A : Set C(X, ℝ))
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A) :
    ∀ (s : Finset C(X, ℝ)), (∀ f ∈ s, f ∈ A) → s.Nonempty →
      s.sup id ∈ A
```

```lean
lemma inf_mem_finset
    {X : Type*} [TopologicalSpace X]
    (A : Set C(X, ℝ))
    (hinf : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A) :
    ∀ (s : Finset C(X, ℝ)), (∀ f ∈ s, f ∈ A) → s.Nonempty →
      s.inf id ∈ A
```

If `Finset.sup`/`Finset.inf` is awkward for `C(X, ℝ)`, define recursive finite
sup/inf over lists or finite sets and prove closure inductively.

Also useful:

```lean
lemma exists_between_two_points
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    ...
    {x y : X} (hxy : x ≠ y) (a b : ℝ) :
    ∃ g ∈ A, g x = a ∧ g y = b
```

```lean
lemma exists_upper_approx_at_point
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    ...
    (f : C(X, ℝ)) (ε : ℝ) (hε : 0 < ε) (x : X) :
    ∃ g ∈ A,
      g x > f x - ε ∧ ∀ z : X, g z ≤ f z + ε
```

and then the dual lower version if needed, though one-sided local approximants
plus finite sup often suffice.

### Lean-specific implementation advice

- `C(X, ℝ)` should be `ContinuousMap X ℝ`; use the notation already active in
  Mathlib.
- Pointwise `sup`/`inf` on `C(X, ℝ)` should come from the lattice structure on
  continuous maps into a linear order with order-closed topology; verify the
  exact instances available for `ℝ`.
- The compactness step will likely go through `isOpen_iff_mem_nhds`,
  `CompactSpace`, `FiniteSubcover`, or `Compact.elim_finite_subcover`.
  Expect this to be the most technical part.
- For closure/density, the metric-space interface on continuous maps is usually
  easier than general topological closure statements.
- If strict inequalities cause friction, prove the approximation theorem with
  `≤ ε` first, then conclude the `< ε` version by applying it to `ε/2`.

### Significance

This theorem is the right abstract universal approximation principle for the EML
program. Existing closure/compositional results show that specific EML
architectures generate classes stable under certain operations; the missing step
is a theorem that turns those closure properties plus point-separation into
uniform density in `C(X, ℝ)`. Once formalized, many future approximation results
for concrete EML models will reduce to checking four structural axioms:
constants, algebra closure, lattice closure, and separation of points. In other
words, this theorem converts architecture-specific approximation arguments into
a reusable meta-theorem, exactly analogous to how classical Stone–Weierstrass
organizes large parts of approximation theory.

If the fully minimal hypothesis set `{constants, multiplication, max, min,
separation}` turns out too weak to derive the affine interpolation step cleanly
inside Lean, prove the theorem first for a sublattice subalgebra closed under
`+` and `-`, and then add a follow-up theorem showing that the intended EML
class satisfies those stronger closure hypotheses. That still delivers the
essential universal approximation theorem for the research program.

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
