## YOUR ASSIGNMENT: Algebraic tropicalization of EML function algebras via a tropical tensor-product universality for separable bivariate EML maps

**TARGET FILE**: `Bridges/EML/TropicalTensorProductUniversality.lean`

**RESEARCH MODE**: `prove`

### Precise theorem target

You should formalize a bivariate tropical Stone–Weierstrass / tensor-generation theorem in the strongest form that the current catalog infrastructure supports, but with a fallback chain of progressively weaker exact statements if the full completed-tensor-product formalization is too heavy.

The central mathematical idea is:

- one-variable EML subsemialgebras on `X` and `Y` already admit tropical Stone–Weierstrass density;
- pure tensors `a(x) ⊗ b(y)` should generate a product-space EML subsemialgebra on `X × Y`;
- finite tropical linear combinations of such pure tensors should be uniformly dense in the target bivariate algebra;
- this is the idempotent/tropical analogue of algebraic tensor-product universality.

Because Mathlib support for general compact-open semiring-valued function algebras and completed idempotent tensor products may be partial, define the theorem at the level of explicit approximants in sup norm / uniform approximation.

### Primary Lean theorem signature

A realistic primary target is an explicit approximation theorem for max-plus valued continuous maps on compact spaces. Use the strongest available existing structures from the catalog; if the previous files already define the relevant EML subsemialgebra predicates, reuse them verbatim. If not, work with a concrete standalone theorem over continuous functions.

A recommended exact theorem shape is:

```lean
theorem exists_uniform_approx_separable_tropical
    {X Y : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y] [CompactSpace Y]
    {A : Set C(X, ℝ)}
    {B : Set C(Y, ℝ)}
    (hA_const : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hB_const : ∀ c : ℝ, (fun _ : Y => c) ∈ B)
    (hA_sep : Function.SeparatesPoints A)
    (hB_sep : Function.SeparatesPoints B)
    (hA_dense :
      Dense (Subsemiring.closure ((A : Set C(X, ℝ)))))
    (hB_dense :
      Dense (Subsemiring.closure ((B : Set C(Y, ℝ)))))
    (f : C(X × Y, ℝ))
    (hf_eml : IsSeparableEMLMap f) :
    ∀ ε > 0, ∃ n : ℕ,
      ∃ a : Fin n → C(X, ℝ),
      ∃ b : Fin n → C(Y, ℝ),
      ∃ c : Fin n → ℝ,
        (∀ i, a i ∈ closure A) ∧
        (∀ i, b i ∈ closure B) ∧
        ‖f - ContinuousMap.mk
          (fun p => Finset.sup Finset.univ (fun i => c i + a i p.1 + b i p.2))
          (by continuity)‖ < ε
```

This exact signature may need adaptation because:

- `Function.SeparatesPoints` may not be the exact catalog predicate;
- `Subsemiring.closure` on `C(X, ℝ)` may not exist in the intended sense;
- the sup-expression over `Fin n` may be easier to encode using `Finset.univ.sup`;
- the norm on `C(X × Y, ℝ)` may require the `instNorm` already available for continuous maps on compact spaces;
- `IsSeparableEMLMap` likely needs to be introduced if not already defined.

If the above is too ambitious, define the separable class explicitly:

```lean
def SeparableTropicalApprox (X Y : Type*) [TopologicalSpace X] [TopologicalSpace Y] :=
  Set (C(X × Y, ℝ))
```

or better:

```lean
def IsFiniteSeparableTropical (f : C(X × Y, ℝ)) : Prop :=
  ∃ n : ℕ, ∃ a : Fin n → C(X, ℝ), ∃ b : Fin n → C(Y, ℝ), ∃ c : Fin n → ℝ,
    f = ContinuousMap.mk
      (fun p => Finset.sup Finset.univ (fun i => c i + a i p.1 + b i p.2))
      (by continuity)
```

Then prove density of this class.

### Stronger universality statement to aim for

If the infrastructure is already present for tropicalization and EML subsemialgebras, the theorem should be stated as a genuine tensor-product universality result:

```lean
theorem tropical_tensor_product_universal_dense
    {X Y S : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y] [CompactSpace Y]
    [CanonicallyOrderedCommSemiring S]
    [TopologicalSpace S] [OrderClosedTopology S]
    {A : Set C(X, S)} {B : Set C(Y, S)}
    (hA_sw : TropicalStoneWeierstrassHypotheses A)
    (hB_sw : TropicalStoneWeierstrassHypotheses B) :
    Dense
      (tropicalSpan
        {f | ∃ a ∈ A, ∃ b ∈ B,
            f = ContinuousMap.mk (fun p : X × Y => a p.1 * b p.2) (by continuity)})
```

and then identify this generated algebra with the product-space tropicalization:

```lean
theorem tropicalization_product_eq_tensor_completion
    {X Y S : Type*} ...
    (hA : ...)
    (hB : ...) :
    tropicalization (productEMLSubalgebra A B)
      = completedIdempotentTensorProduct (tropicalization A) (tropicalization B)
```

This is the conceptual endpoint, but only attempt it if the necessary definitions already exist.

### Fallback theorem ladder

If the full theorem is not reachable in one pass, prove the following chain:

1. **Pure tensors are continuous**:
```lean
theorem continuous_pure_tensor
    {X Y S : Type*}
    [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace S]
    [Mul S]
    {a : C(X, S)} {b : C(Y, S)} :
    Continuous fun p : X × Y => a p.1 * b p.2
```

2. **Finite tropical sums of pure tensors form a subsemialgebra/subsemiring**:
```lean
def separableTropicalSubsemiring (A : Set C(X, ℝ)) (B : Set C(Y, ℝ)) :
    Set C(X × Y, ℝ) := ...
```

with closure under constants, tropical addition (`sup`/`max`), and tropical multiplication (`+` in max-plus coordinates).

3. **Rectangle separation lemma**: if `A` separates points of `X` and `B` separates points of `Y`, then pure tensors separate product points of `X × Y`.
A concrete statement:

```lean
theorem pure_tensors_separate_points
    {X Y : Type*}
    [TopologicalSpace X] [TopologicalSpace Y]
    {A : Set C(X, ℝ)} {B : Set C(Y, ℝ)}
    (hA_const : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hB_const : ∀ c : ℝ, (fun _ : Y => c) ∈ B)
    (hA_sep : Function.SeparatesPoints A)
    (hB_sep : Function.SeparatesPoints B) :
    Function.SeparatesPoints
      {f | ∃ a ∈ A, ∃ b ∈ B,
          f = ContinuousMap.mk (fun p : X × Y => a p.1 + b p.2) (by continuity)}
```

4. **Stone–Weierstrass on the product algebra generated by pure tensors**:
use the previously certified tropical Stone–Weierstrass theorem as a black box once the product-generated family is shown to satisfy its hypotheses.

This ladder is already mathematically meaningful and should lead to the final density theorem.

---

### Definitions you may need to introduce

If absent from the catalog, define explicit separable tropical approximants.

For max-plus over `ℝ`:

```lean
def pureTensorMaxPlus
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (a : C(X, ℝ)) (b : C(Y, ℝ)) : C(X × Y, ℝ) :=
  ContinuousMap.mk (fun p => a p.1 + b p.2) (by continuity)
```

```lean
def finiteSupSeparableMaxPlus
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (n : ℕ) (c : Fin n → ℝ) (a : Fin n → C(X, ℝ)) (b : Fin n → C(Y, ℝ)) :
    C(X × Y, ℝ) :=
  ContinuousMap.mk
    (fun p => Finset.sup Finset.univ (fun i => c i + a i p.1 + b i p.2))
    (by continuity)
```

If `Finset.sup` over `ℝ` is awkward because it needs an order-top element or nonempty witness, replace with `Finset.max'` on a nonempty finite set, or define recursively over lists. A robust alternative is to use `sSup` of a finite image set.

For min-plus, mirror with `inf`/`min` and additive constants.

If the prior files encode tropical semiring values directly rather than logarithmic `ℝ`, use those definitions instead. But if there is any friction, the logarithmic model on `ℝ` is likely the fastest route.

---

### Concrete proof strategy

#### Strategy A: Product Stone–Weierstrass via generated subalgebra
This is the most promising route if the catalog already has a Stone–Weierstrass theorem for idempotent semiring-valued EML maps.

1. Define the product generating family:
   - pure tensors `(x,y) ↦ a x ⊗ b y`,
   - or in max-plus coordinates `(x,y) ↦ a x + b y`.
2. Prove this family contains constants:
   - use constants in `A` and `B`,
   - e.g. `c = c + 0`, with one factor constant `c`, the other `0`.
3. Prove point separation on `X × Y`:
   - if `x₁ ≠ x₂`, separate using `A` and keep `B` constant;
   - if `y₁ ≠ y₂`, separate using `B` and keep `A` constant.
4. Form the tropical subsemialgebra generated by these pure tensors and invoke the existing tropical Stone–Weierstrass theorem on `X × Y`.
5. Conclude density in the ambient product EML algebra.

Why this is best: it reduces the theorem to verifying hypotheses for an already-established density engine, and the product-space separation argument is elementary but decisive.

#### Strategy B: Explicit approximation from one-variable approximants
This is preferable if the catalog already contains explicit approximation schemes rather than abstract density.

1. Approximate the one-variable factor maps appearing in a separable representation of `f`.
2. Show approximation is stable under pure tensor formation:
   - bound `|(a+b) - (a'+b')| ≤ |a-a'| + |b-b'|`,
   - and similarly after adding coefficients.
3. Show approximation is stable under finite tropical sup:
   - use the key inequality
     ```lean
     |max u v - max u' v'| ≤ max |u-u'| |v-v'|
     ```
     and its finite-set version
     ```lean
     |sup_i F i - sup_i G i| ≤ sup_i |F i - G i|
     ```
4. Conclude that if each factor lies in the closure of `A` and `B`, then any finite tropical sum of pure tensors lies in the closure of the generated product algebra.
5. Deduce density of all separable EML maps.

This route gives algorithmic content: it produces explicit approximants from approximants of the factors.

#### Strategy C: Tensor-universality as an algebraic isomorphism
Attempt this only if the library infrastructure is strong enough.

1. Define an algebraic map from the idempotent tensor product of one-variable function semialgebras into `C(X × Y, S)`.
2. Prove well-definedness on generators and bilinearity/balancedness.
3. Prove image equals the semialgebra generated by pure tensors.
4. Use one-variable density theorems to show the image is dense in the target product algebra.
5. Upgrade to a completed tensor-product statement.

This is the most conceptually powerful result, but it may require more custom infrastructure than this cycle can absorb.

---

### Key intermediate lemmas to prove explicitly

You should expect the theorem to hinge on one or two “obvious but formalization-critical” lemmas. Prove them first.

1. **Pure tensor continuity**
```lean
theorem continuous_pureTensorMaxPlus
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (a : C(X, ℝ)) (b : C(Y, ℝ)) :
    Continuous fun p : X × Y => a p.1 + b p.2 := by
  continuity
```

2. **Constants belong to the product-generated algebra**
```lean
theorem const_mem_product_span
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    {A : Set C(X, ℝ)} {B : Set C(Y, ℝ)}
    (hA_const : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hB_const : ∀ c : ℝ, (fun _ : Y => c) ∈ B) :
    ∀ c : ℝ,
      (ContinuousMap.const (X × Y) c) ∈ productTropicalSpan A B := by
  ...
```

3. **Product separation lemma**
```lean
theorem separatesPoints_product_of_separatesPoints
    {X Y : Type*}
    [TopologicalSpace X] [TopologicalSpace Y]
    {A : Set C(X, ℝ)} {B : Set C(Y, ℝ)}
    (hA_const : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hB_const : ∀ c : ℝ, (fun _ : Y => c) ∈ B)
    (hA_sep : Function.SeparatesPoints A)
    (hB_sep : Function.SeparatesPoints B) :
    Function.SeparatesPoints (pureTensorFamily A B)
```

The proof should split on whether the differing coordinates are in `X` or `Y`.

4. **Finite sup Lipschitz lemma**
```lean
theorem finset_sup_le_sup_of_pointwise_le
    {α ι : Type*} [LinearOrder α] {s : Finset ι} {f g : ι → α}
    (h : ∀ i ∈ s, f i ≤ g i) :
    s.sup f ≤ s.sup g := ...
```

and a metric variant for approximation:
```lean
theorem dist_finset_sup_le
    {ι : Type*} {s : Finset ι} {f g : ι → ℝ}
    (hs : s.Nonempty) :
    |s.sup f - s.sup g| ≤ s.sup (fun i => |f i - g i|) := ...
```

This lemma is the engine for passing from factorwise approximation to approximation of tropical sums.

5. **Closure stability under tropical operations**
If the closure machinery is awkward, prove direct epsilon lemmas instead:
```lean
theorem approx_pureTensor_of_factor_approx ...
theorem approx_finiteSup_of_termwise_approx ...
```

These can be assembled into the main result without a heavy abstract closure API.

---

### Recommended file architecture

Organize the file into four sections:

1. `PureTensors`
   - definitions of pure tensors and finite tropical sums,
   - continuity lemmas.

2. `ProductSeparation`
   - constants,
   - separation of points on `X × Y`,
   - generated subalgebra hypotheses.

3. `ApproximationLemmas`
   - stability under addition / tropical multiplication,
   - finite sup perturbation bounds,
   - closure/density transport.

4. `MainTheorems`
   - density of generated separable tropical maps,
   - optional tensor-product universality corollary.

This decomposition will keep any hard lemma isolated and reusable.

---

### Mathematical significance

This theorem is not a routine product extension. It is the missing multiplicative architecture in the tropical Stone–Weierstrass program.

Why it matters:

- The existing one-variable tropical approximation results certify expressive completeness for scalar or retract-valued EML maps on single spaces.
- This theorem upgrades that to a compositional multivariate calculus: higher-dimensional EML maps can be built from one-dimensional factors by tropical tensoring.
- In algebraic terms, it identifies product-space tropical function algebras with completed idempotent tensor products of one-variable algebras.
- In computational terms, it yields a constructive low-rank tropical approximation scheme: bivariate maps are approximated by finite tropical sums of separable terms. This is the idempotent analogue of low-rank matrix/tensor factorization.
- In EML/neural-network terms, it gives a rigorous approximation theorem for architectures assembled from rank-one tropical feature interactions.
- In physics/information language, it is a max-plus/min-plus analogue of partition-function factorization and interaction decomposition.

This result opens the door to:
- tropical nuclear rank and approximation complexity of EML maps,
- multivariate tropical Barron-type theorems,
- idempotent tensor categories of EML observables,
- algorithmic approximation schemes for high-dimensional decision surfaces.

---

### If the full theorem resists formalization

Do not stall. Prove the strongest exact special case and state the remaining conjecture precisely.

Best fallback target:

```lean
theorem tropical_stone_weierstrass_product_generated
    {X Y : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y] [CompactSpace Y] :
    Dense {f : C(X × Y, ℝ) | IsFiniteSeparableTropical f}
```

for the case where the one-variable algebras are the full continuous-function spaces `C(X, ℝ)` and `C(Y, ℝ)`.

If even that is too much, prove:

- pure tensors separate product points,
- finite tropical sums of pure tensors form a subsemiring/subalgebra,
- and invoke the catalog Stone–Weierstrass theorem to get density.

If there remains a genuine gap, state it exactly as:

```lean
conjecture tropical_tensor_product_universality
    {X Y S : Type*} ... : ...
```

with the precise missing hypothesis.

---

### Deliverable requirement

At the end of the file cycle, also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems. At least include:

1. a trivariate / `n`-fold tensor-product extension;
2. a tropical low-rank complexity notion and approximation bound;
3. a min-plus/max-plus duality theorem for tensor-generated EML algebras;
4. a retract-valued or manifold-valued extension;
5. an algorithmic extraction theorem converting density proofs into explicit approximation procedures.

### Catalog Reference Files
            @Computation/DensityTheory.lean
```lean
import Mathlib

/-! # CatalogBuild.Computation.DensityTheory

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15
-/


noncomputable section

/-- The EML operation. -/
def EMLd (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- EML closure at depth n: start from seed set S and apply EMLd n times. -/
def EMLClosure : ℕ → Set ℝ → Set ℝ
  | 0, S => S
  | n + 1, S => EMLClosure n S ∪ {z | ∃ a ∈ EMLClosure n S, ∃ b ∈ EMLClosure n S, z = EMLd a b}

/-- The full EML closure (union over all depths). -/
def fullEMLClosure (S : Set ℝ) : Set ℝ := ⋃ n, EMLClosure n S




/-- 1 is in the seed set. -/
theorem one_in_closure : (1 : ℝ) ∈ EMLClosure 0 {1} := by
  simp [EMLClosure]




/-- EML closure is monotone in depth. -/
theorem EMLClosure_mono (S : Set ℝ) (n : ℕ) :
    EMLClosure n S ⊆ EMLClosure (n + 1) S := by
  intro x hx
  simp [EMLClosure]
  exact Or.inl hx




/-- Log-split: EML(x, y·z) = EML(x, y) - ln(z) for y, z > 0. -/
theorem EMLd_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    EMLd x (y * z) = EMLd x y - Real.log z := by
  simp [EMLd, Real.log_mul hy.ne' hz.ne']; ring




/-- EML(x, 1) = exp(x). -/
theorem EMLd_exp (x : ℝ) : EMLd x 1 = Real.exp x := by
  simp [EMLd, Real.log_one]




/-- EML(0, x) = 1 - ln(x). -/
theorem EMLd_one_minus_log (x : ℝ) : EMLd 0 x = 1 - Real.log x := by
  simp [EMLd]




/-- EML(0, x) maps values in (1, e) to (0, 1). -/
theorem EMLd_maps_to_unit_interval (x : ℝ) (hx1 : 1 < x) (hxe : x < Real.exp 1) :
    0 < EMLd 0 x ∧ EMLd 0 x < 1 := by
  constructor
  · simp [EMLd]
    have : Real.log x < 1 := by
      rwa [← Real.log_exp 1, Real.log_lt_log_iff (by linarith) (Real.exp_pos 1)]
    linarith
  · simp [EMLd]
    linarith [Real.log_pos hx1]




/-- exp maps any positive value to a value > 1. -/
theorem EMLd_amplifies (x : ℝ) (hx : 0 < x) :
    EMLd x 1 > 1 := by
  simp [EMLd, Real.log_one]
  linarith [Real.add_one_le_exp x]




/-- The composition EML(EML(0, x), 1) = exp(1 - ln(x)) = e/x for x > 0. -/
theorem EMLd_inv_scaled (x : ℝ) (hx : 0 < x) :
    EMLd (EMLd 0 x) 1 = Real.exp 1 / x := by
  simp [EMLd, Real.log_one, Real.exp_sub, Real.exp_log hx]




/-- ln recovery: EML(0, exp(EML(0, x))) = ln(x). -/
theorem EMLd_recovers_ln (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 x)) = Real.log x := by
  simp [EMLd, Real.log_exp]




/-- Double negation: EML(0, exp(EML(0, exp(x)))) = x. -/
theorem EMLd_double_neg (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 (Real.exp x))) = x := by
  simp [EMLd, Real.log_exp]




/-- Shift identity: EML(x + c, 1) = exp(c) · exp(x). -/
theorem EMLd_shift (x c : ℝ) :
    EMLd (x + c) 1 = Real.exp c * Real.exp x := by
  simp [EMLd, Real.log_one, Real.exp_add, mul_comm]




/-- [Section: # CatalogBuild.Computation.DensityTheory
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15] -/
theorem e_irrational : Irrational (Real.exp 1) := by
  by_contra h;
  -- Assume that $e$ is rational, so there exist positive integers $p$ and $q$ such that $e = p/q$.
  obtain ⟨p, q, hpq⟩ : ∃ p q : ℕ, p > 0 ∧ q > 0 ∧ Real.exp 1 = p / q := by
    -- Since $e$ is not irrational, it must be rational. Therefore, there exist positive integers $p$ and $q$ such that $e = p/q$.
    obtain ⟨p, q, hpq⟩ : ∃ p q : ℤ, p > 0 ∧ q > 0 ∧ Real.exp 1 = p / q := by
      obtain ⟨ q, hq ⟩ := Classical.not_not.mp h;
      exact ⟨ q.num, q.den, mod_cast Rat.num_pos.mpr ( show 0 < q by exact_mod_cast hq.symm ▸ Real.exp_pos 1 ), mod_cast q.pos, by simpa only [ Rat.cast_def ] using hq.symm ⟩;
    cases p <;> cases q <;> aesop;
  -- Multiply both sides of the equation $e = p/q$ by $q!$ to obtain $q! \cdot e = p \cdot (q-1)! + p \cdot (q-2)! + \cdots + p + \frac{p}{q+1} + \cdots$.
  have h_mul_factorial : q.factorial * Real.exp 1 = ∑ k ∈ Finset.range (q + 1), (q.factorial : ℝ) / (k.factorial : ℝ) + ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) := by
    have h_mul_factorial : q.factorial * Real.exp 1 = ∑' k : ℕ, (q.factorial : ℝ) / ((k).factorial : ℝ) := by
      norm_num [ div_eq_mul_inv, Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum ];
      rw [ NormedSpace.exp_eq_tsum_div, ← tsum_mul_left ] ; exact tsum_congr fun _ => by ring;
    rw [ h_mul_factorial, ← Summable.sum_add_tsum_nat_add ];
    congr! 2;
    · ac_rfl;
    · exact Summable.mul_left _ <| by simpa using Real.summable_pow_div_factorial 1;
  -- The series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ is strictly less than 1.
  have h_series_lt_one : ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) < 1 := by
    -- We can bound the series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ above by a geometric series.
    have h_geo_series : ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) ≤ ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1).factorial : ℝ) * (1 / (q + 2)) ^ k := by
      refine' Summable.tsum_le_tsum _ _ _;
      · field_simp;
        intro i; rw [ div_pow ] ; rw [ mul_div, le_div_iff₀ ] <;> norm_cast <;> induction' i with i ih <;> norm_num [ Nat.factorial, pow_succ' ] at *;
        nlinarith [ Nat.factorial_succ ( q + 1 + i ) ];
-- ... (truncated, full file has 181 lines)
```


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
