## YOUR ASSIGNMENT: Tropical Riesz representation for idempotent EML linear functionals

Work in the compact-Hausdorff / max-plus prototype first, with codomain `WithBot ℝ`. The core objective is to turn the existing tropical Stone–Weierstrass approximation infrastructure into a genuine duality theorem: every suitably continuous max-plus linear functional on an EML function algebra is evaluation against a canonical maxitive measure, and that measure is uniquely reconstructed from the functional.

### Precise formal target

Start with a concrete function space:
```lean
def TropCont (X : Type*) [TopologicalSpace X] := C(X, WithBot ℝ)
```

Define the tropical algebraic structure pointwise:
- tropical addition = `sup`
- tropical scalar action by `WithBot ℝ` = pointwise addition
- constants as constant functions

Define a functional structure specialized to the max-plus setting:
```lean
structure TropicalFunctional (X : Type*) [TopologicalSpace X] where
  toFun        : TropCont X → WithBot ℝ
  map_sup'     : ∀ f g, toFun (fun x => sup (f x) (g x)) = sup (toFun f) (toFun g)
  map_const'   : ∀ c : WithBot ℝ, toFun (ContinuousMap.const _ c) = c
  map_addConst' :
    ∀ (c : WithBot ℝ) (f : TropCont X),
      toFun (fun x => c + f x) = c + toFun f
  monotone'    : ∀ {f g : TropCont X}, (∀ x, f x ≤ g x) → toFun f ≤ toFun g
```

If the constant-normalization `map_const'` is too strong at first, replace it by
```lean
map_const_zero' : toFun (ContinuousMap.const _ 0) = 0
```
and derive/assume the full constant formula from `map_addConst'`.

Then define the canonical maxitive content attached to a functional on closed sets:
```lean
def muClosed
  (Λ : TropicalFunctional X) (K : Set X) : WithBot ℝ :=
  sInf {a : WithBot ℝ | ∃ f : TropCont X,
    (∀ x ∈ K, a ≤ f x) ∧ Λ.toFun f = a}
```
This is a candidate “capacity from above.” If this is technically awkward, use the more robust envelope on compact sets:
```lean
def muCompact
  [CompactSpace X]
  (Λ : TropicalFunctional X) (K : Set X) : WithBot ℝ :=
  sInf {Λ.toFun f | (f : TropCont X) (hf : ∀ x ∈ K, (0 : WithBot ℝ) ≤ f x)}
```
but the best version is the indicator-envelope formula below.

A cleaner route is to define the measure by approximation of tropical indicators:
```lean
def admissibleAbove [TopologicalSpace X] (K : Set X) (f : TropCont X) : Prop :=
  ∀ x, x ∈ K → (0 : WithBot ℝ) ≤ f x

def muK [CompactSpace X]
  (Λ : TropicalFunctional X) (K : Set X) : WithBot ℝ :=
  sInf (Λ.toFun '' {f : TropCont X | admissibleAbove K f})
```

Then prove a representation theorem for a dense tropical subsemialgebra `A ⊆ TropCont X`. You will likely need a structure:
```lean
structure TropSubsemialgebra (X : Type*) [TopologicalSpace X] where
  carrier        : Set (TropCont X)
  sup_mem'       : ∀ {f g}, carrier f → carrier g → carrier (fun x => sup (f x) (g x))
  const_mem'     : ∀ c, carrier (ContinuousMap.const _ c)
  addConst_mem'  : ∀ c {f}, carrier f → carrier (fun x => c + f x)
  separatesPts'  : Prop
  dense'         : Dense carrier
```

### Main theorem: representation and uniqueness

A good first exact theorem is:

```lean
theorem tropical_riesz_compact_unique
  (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X]
  (Λ : TropicalFunctional X) :
  ∃! μ : Set X → WithBot ℝ,
    (∀ K L : Set X, IsCompact K → IsCompact L →
      μ (K ∪ L) = sup (μ K) (μ L)) ∧
    (∀ f : TropCont X,
      Λ.toFun f =
        sSup {a : WithBot ℝ | ∃ K : Set X, IsCompact K ∧ a ≤ μ K + sInf (f '' K)})
```

This exact formula may need refinement depending on available lemmas about `sInf (f '' K)`. If the `sInf` over image sets is cumbersome, specialize first to finite spaces, where the integral becomes an explicit maximum:
```lean
theorem tropical_riesz_finite
  (X : Type*) [Fintype X] [TopologicalSpace X] [DiscreteTopology X]
  (Λ : TropicalFunctional X) :
  ∃! w : X → WithBot ℝ,
    ∀ f : TropCont X,
      Λ.toFun f = Finset.sup Finset.univ (fun x => w x + f x)
```

This finite theorem is not a toy: it is the discrete tropical Riesz theorem and should be your first completely formalized milestone. Then globalize to compact spaces by defining
```lean
def μ_from_Λ (Λ : TropicalFunctional X) (K : Set X) : WithBot ℝ := ...
```
and proving
```lean
theorem tropical_riesz_compact
  (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X]
  (A : TropSubsemialgebra X)
  (hA_dense : Dense A.carrier)
  (hΛ_agrees_on_A : ...)
  :
  ∃ μ : Set X → WithBot ℝ,
    (∀ K L, IsCompact K → IsCompact L → μ (K ∪ L) = sup (μ K) (μ L)) ∧
    (∀ f : TropCont X, Λ.toFun f = tropicalIntegral μ f)
```

with an explicit integral definition such as
```lean
def tropicalIntegral (μ : Set X → WithBot ℝ) (f : TropCont X) : WithBot ℝ :=
  sSup {a : WithBot ℝ | ∃ K : Set X, IsCompact K ∧ a ≤ μ K + sInf (f '' K)}
```
or the dual upper-envelope version if that is easier to make monotone and max-plus linear.

### Strong reconstruction theorem from a generating subsemialgebra

This is the genuinely field-opening part. Prove that if `A` is separating and tropically Stone–Weierstrass dense, then the measure is already determined by the restriction of `Λ` to `A`:

```lean
theorem tropical_measure_reconstruction
  (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X]
  (A : TropSubsemialgebra X)
  (h_dense : Dense A.carrier)
  (Λ₁ Λ₂ : TropicalFunctional X)
  (h_eq :
    ∀ f : TropCont X, A.carrier f → Λ₁.toFun f = Λ₂.toFun f) :
  Λ₁ = Λ₂
```

and therefore:

```lean
theorem tropical_riesz_measure_unique_from_generator
  (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X]
  (A : TropSubsemialgebra X)
  (h_dense : Dense A.carrier)
  (μ₁ μ₂ : Set X → WithBot ℝ)
  (h_int_eq_on_A :
    ∀ f : TropCont X, A.carrier f →
      tropicalIntegral μ₁ f = tropicalIntegral μ₂ f) :
  μ₁ = μ₂
```

If equality of all set values is too strong initially, prove equality on compact sets first:
```lean
∀ K, IsCompact K → μ₁ K = μ₂ K
```

### Most promising proof architecture

#### Strategy A: finite-space tropical Hahn–Banach by explicit weights
This is the fastest route to a fully verified nontrivial theorem.

1. For finite `X`, define point masses by testing `Λ` on tropical basis functions:
   ```lean
   def deltaWeight (Λ : TropicalFunctional X) (x : X) : WithBot ℝ :=
     Λ.toFun (fun y => if y = x then 0 else ⊥)
   ```
   Then show
   ```lean
   Λ.toFun f = Finset.sup Finset.univ (fun x => deltaWeight Λ x + f x)
   ```
   by:
   - proving `deltaWeight Λ x + f x ≤ Λ.toFun f` using monotonicity and the basis inequality
   - proving the reverse inequality by writing `f` as a finite tropical supremum of shifted basis functions:
     ```lean
     f = fun y => Finset.sup Finset.univ (fun x => f x + basis x y)
     ```
2. Deduce uniqueness of weights by evaluating on basis functions.
3. Package finite subsets as compacta and define the induced maxitive measure:
   ```lean
   μ K = Finset.sup (K.toFinset) w
   ```
4. This theorem already gives an algorithmic normal form for every tropical functional.

This strategy is the best first target because it avoids hard topological extension issues and forces the correct representation formula.

#### Strategy B: compact-space representation via Urysohn separation + tropical Stone–Weierstrass
This is the main breakthrough route.

1. Define the compact-set capacity
   ```lean
   μ_from_Λ K := sInf (Λ.toFun '' {f | ∀ x ∈ K, (0 : WithBot ℝ) ≤ f x})
   ```
   or a normalized variant using functions that dominate a tropical indicator of `K`.
2. Prove maxitivity on compact sets:
   ```lean
   μ_from_Λ (K ∪ L) = sup (μ_from_Λ K) (μ_from_Λ L)
   ```
   using:
   - `map_sup'`
   - compact-set separation/Urysohn-style approximation to build test functions concentrated near `K` and `L`
   - infimum comparison in both directions
3. Show lower bound:
   ```lean
   tropicalIntegral (μ_from_Λ) f ≤ Λ.toFun f
   ```
   by monotonicity from the fact that any compact-supported lower envelope is pointwise ≤ `f`.
4. Show upper bound:
   approximate `f` from below by tropical finite suprema of simple functions built from separating functions in the dense subsemialgebra `A`; then apply `map_sup'`, `map_addConst'`, and continuity/density.
5. Uniqueness:
   recover `μ(K)` as the infimum of `Λ(f)` over all `f` dominating the tropical indicator of `K`.

This is the most conceptually powerful strategy because it converts Stone–Weierstrass density into a duality theorem, not just an approximation theorem.

#### Strategy C: reconstruction-by-density as a functional extensionality theorem
This is the best route if the full measure-theoretic machinery becomes heavy.

1. First prove a purely functional theorem:
   ```lean
   theorem tropical_functional_ext_of_dense
     {Λ₁ Λ₂ : TropicalFunctional X}
     (h_dense : Dense A.carrier)
     (hA : ∀ f, A.carrier f → Λ₁.toFun f = Λ₂.toFun f) :
     Λ₁ = Λ₂
   ```
2. Use the existing tropical Stone–Weierstrass theorem to approximate any `f : TropCont X` by functions in `A`.
3. Prove that tropical functionals preserve these approximation limits. If genuine topological continuity is missing, add it as an axiom:
   ```lean
   upper_continuous' :
     ∀ {f : ℕ → TropCont X} {g : TropCont X},
       Monotone f →
       (∀ x, Tendsto (fun n => f n x) atTop (𝓝 (g x))) →
       Tendsto (fun n => toFun (f n)) atTop (𝓝 (toFun g))
   ```
4. Then define the representing measure only after uniqueness is established, using the envelope formula.
5. This path isolates the topological subtlety into one continuity hypothesis and still yields a major theorem.

### Concrete proof steps and key lemmas to aim for

1. **Tropical basis decomposition on finite spaces**
   ```lean
   lemma finite_tropical_decompose
     [Fintype X] (f : X → WithBot ℝ) :
     f = fun y => Finset.sup Finset.univ (fun x => f x + (if y = x then 0 else ⊥))
   ```
   This is the discrete analogue of writing a function as a sup of shifted Dirac profiles.

2. **Monotonicity from tropical linearity**
   If not assumed, derive monotonicity from `map_sup'`:
   ```lean
   lemma monotone_of_map_sup
     (hSup : ∀ f g, Λ (fun x => sup (f x) (g x)) = sup (Λ f) (Λ g)) :
     Monotone Λ
   ```
   since `f ≤ g` implies `sup f g = g`.

3. **Compact-set capacity maxitivity**
   ```lean
   lemma muCompact_union
     (K L : Set X) (hK : IsCompact K) (hL : IsCompact L) :
     μ_from_Λ Λ (K ∪ L) = sup (μ_from_Λ Λ K) (μ_from_Λ Λ L)
   ```

4. **Representation inequality pair**
   ```lean
   lemma tropicalIntegral_le_functional
     (f : TropCont X) :
     tropicalIntegral (μ_from_Λ Λ) f ≤ Λ.toFun f

   lemma functional_le_tropicalIntegral
     (f : TropCont X) :
     Λ.toFun f ≤ tropicalIntegral (μ_from_Λ Λ) f
   ```
   Their conjunction is the heart of the theorem.

5. **Uniqueness by compact-test reconstruction**
   ```lean
   lemma measure_eq_of_integral_eq
     (μ₁ μ₂ : Set X → WithBot ℝ)
     (hEq : ∀ f : TropCont X, tropicalIntegral μ₁ f = tropicalIntegral μ₂ f) :
     ∀ K, IsCompact K → μ₁ K = μ₂ K
   ```
   Prove by evaluating on approximants to the indicator of `K`.

### Lean design guidance

Prefer a staged file architecture:

- `TropicalFunctional/Basic.lean`
  - `TropCont`
  - `TropicalFunctional`
  - basic lemmas: extensionality, monotonicity, preservation of finite sup

- `TropicalFunctional/FiniteRiesz.lean`
  - finite-space basis functions
  - discrete representation theorem
  - uniqueness of weights

- `TropicalFunctional/Capacity.lean`
  - `μ_from_Λ`
  - maxitivity on compact sets
  - monotonicity in the set argument

- `TropicalFunctional/CompactRiesz.lean`
  - integral definition
  - representation theorem
  - uniqueness/reconstruction from dense subsemialgebra

Useful exact theorem shapes:
```lean
theorem TropicalFunctional.ext
  {Λ₁ Λ₂ : TropicalFunctional X}
  (h : ∀ f, Λ₁.toFun f = Λ₂.toFun f) : Λ₁ = Λ₂
```

```lean
theorem map_iSup_finset
  (Λ : TropicalFunctional X) (s : Finset ι) (f : ι → TropCont X) :
  Λ.toFun (fun x => s.sup fun i => f i x) = s.sup fun i => Λ.toFun (f i)
```
for finite suprema, proved by induction on `Finset`.

```lean
theorem finite_representation_formula
  [Fintype X] [DiscreteTopology X]
  (Λ : TropicalFunctional X) (f : TropCont X) :
  Λ.toFun f = Finset.sup Finset.univ (fun x => deltaWeight Λ x + f x)
```

### What to do if the full compact theorem resists formalization

Prove the strongest complete theorem in one of these forms:

1. **Finite-space theorem with uniqueness and algorithmic reconstruction**  
   This is already a publishable formal milestone:
   every tropical linear functional is a Shilkret integral against a unique weight.

2. **Compact theorem under an added continuity axiom**  
   Add monotone-sequence continuity to `TropicalFunctional` and prove representation under that hypothesis.

3. **Representation on a dense subsemialgebra only**
   ```lean
   ∀ f ∈ A, Λ f = tropicalIntegral μ f
   ```
   then state the extension to all continuous functions as a precise conjecture.

If necessary, state the remaining conjecture exactly:

```lean
conjecture tropical_riesz_compact_full
  (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X]
  (Λ : TropicalFunctional X)
  (h_cont : UpperContinuous Λ) :
  ∃! μ : Set X → WithBot ℝ,
    IsMaxitiveOnCompacts μ ∧
    ∀ f : TropCont X, Λ.toFun f = tropicalIntegral μ f
```

### Why this matters

This theorem upgrades tropical Stone–Weierstrass from approximation technology to duality theory. It says the “states” on an idempotent EML function algebra are not mysterious: they are geometric objects, maxitive measures. That is the tropical analogue of the classical passage from commutative function algebras to measure representation, and it creates a rigorous algebraic tropicalization of EML observables.

This opens at least four directions immediately:

1. **Tropical spectral theory for EML algebras**  
   Once linear functionals are measures, one can define tropical spectra, Choquet boundaries, and idempotent state spaces.

2. **Algorithmic tropical inference**  
   The finite theorem gives an explicit recovery algorithm for a functional from point weights; this is a max-plus analogue of learning a linear form from evaluations.

3. **Connections to optimization and control**  
   Maxitive integrals are Bellman-type aggregators. A formal Riesz theorem makes dynamic programming functionals part of the same algebraic universe as EML approximation.

4. **Foundations for tropical probability / information**  
   Representation by maxitive measures is the correct entry point for defining tropical expectation, entropy-like functionals, and data-processing inequalities in idempotent settings.

Produce a `FUTURE_DIRECTIONS.md` with 3–5 concrete next targets, for example:
- tropical Choquet theory on compact spaces
- Radon-style regularity for maxitive measures
- duality between tropical ideals of functions and supports of maxitive measures
- categorical functoriality of `Λ ↦ μ_Λ`
- finite/infinite approximation schemes with certified reconstruction bounds

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
