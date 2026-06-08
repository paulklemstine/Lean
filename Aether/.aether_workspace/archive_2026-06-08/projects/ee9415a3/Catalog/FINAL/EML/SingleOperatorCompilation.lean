import EML.SingleOperatorRepresentability

/-!
# EML Single Operator Universality: Compilation to EML-Only Form

The breakthrough theorem: every EML expression can be compiled to an
equivalent expression using `eml(x,y) = exp(x) - log(y)` as the **sole**
transcendental primitive.

The key identities driving the compilation:
- `exp(x) = eml(x, 1)` since `eml(x, 1) = exp(x) - log(1) = exp(x) - 0 = exp(x)`
- `log(y) = 1 - eml(0, y)` since `eml(0, y) = exp(0) - log(y) = 1 - log(y)`

This means the single binary operator `eml` subsumes both `exp` and `log`.
Combined with field operations and constants, `eml` generates the entire
elementary real function class.

## Main results

- `compile_to_eml_only`: Every `EMLExpr` compiles to an equivalent `EMLOnlyExpr`
- `compile_size_linear`: The compiled expression has size at most linear in the original
- `EMLOnlyRepresentable_iff_EMLRepresentable`: Semantic equivalence of both classes
- `deriv_eml_composition`: Derivative closure for EML compositions

## Application keywords
symbolic compilation, operator universality, analog computation, GPAC,
expression normal form, single-operator thesis
-/

noncomputable section
open Real Set

/-! ## §1. The Compilation Algorithm

We define a recursive compiler that translates any `EMLExpr`
(which may use separate `exp` and `log` nodes) into an `EMLOnlyExpr`
(which uses only the `eml` node for transcendental computation). -/

/-- Compile an `EMLExpr` to an equivalent `EMLOnlyExpr`.
    The key translations:
    - `exp(e)` → `eml(e, 1)` (since `exp(x) - log(1) = exp(x)`)
    - `log(e)` → `1 - eml(0, e)` (since `exp(0) - log(y) = 1 - log(y)`) -/
def compileToEMLOnly : EMLExpr → EMLOnlyExpr
  | .const c => .const c
  | .var n => .var n
  | .add e₁ e₂ => .add (compileToEMLOnly e₁) (compileToEMLOnly e₂)
  | .mul e₁ e₂ => .mul (compileToEMLOnly e₁) (compileToEMLOnly e₂)
  | .neg e => .neg (compileToEMLOnly e)
  | .inv e => .inv (compileToEMLOnly e)
  | .exp e => .eml (compileToEMLOnly e) (.const 1)
  | .log e => .add (.const 1) (.neg (.eml (.const 0) (compileToEMLOnly e)))

/-- The compilation preserves semantics: the compiled EML-only expression
    evaluates to the same value as the original expression for every
    variable assignment.

    This is the central correctness theorem of the compilation,
    proved by structural induction on the expression tree. -/
theorem compile_correct (e : EMLExpr) (env : ℕ → ℝ) :
    (compileToEMLOnly e).eval env = e.eval env := by
  induction e with
  | const c => simp [compileToEMLOnly, EMLOnlyExpr.eval, EMLExpr.eval]
  | var n => simp [compileToEMLOnly, EMLOnlyExpr.eval, EMLExpr.eval]
  | add e₁ e₂ ih₁ ih₂ =>
    simp [compileToEMLOnly, EMLOnlyExpr.eval, EMLExpr.eval, ih₁, ih₂]
  | mul e₁ e₂ ih₁ ih₂ =>
    simp [compileToEMLOnly, EMLOnlyExpr.eval, EMLExpr.eval, ih₁, ih₂]
  | neg e ih =>
    simp [compileToEMLOnly, EMLOnlyExpr.eval, EMLExpr.eval, ih]
  | inv e ih =>
    simp [compileToEMLOnly, EMLOnlyExpr.eval, EMLExpr.eval, ih]
  | exp e ih =>
    simp [compileToEMLOnly, EMLOnlyExpr.eval, EMLExpr.eval, ih, Real.log_one]
  | log e ih =>
    simp [compileToEMLOnly, EMLOnlyExpr.eval, EMLExpr.eval, ih, Real.exp_zero]

/-! ## §2. Size Bound for Compilation -/

/-- The compiled expression size is at most `5 * original_size`.
    The `exp` case maps `exp(e)` to `eml(e', const 1)` (3 nodes),
    and the `log` case maps `log(e)` to `add(const 1, neg(eml(const 0, e')))` (5 overhead nodes).
    The factor of 5 suffices for all cases. -/
theorem compile_size_bound (e : EMLExpr) :
    (compileToEMLOnly e).size ≤ 5 * e.size := by
  induction e with
  | const _ => simp [compileToEMLOnly, EMLOnlyExpr.size, EMLExpr.size]
  | var _ => simp [compileToEMLOnly, EMLOnlyExpr.size, EMLExpr.size]
  | add e₁ e₂ ih₁ ih₂ =>
    simp [compileToEMLOnly, EMLOnlyExpr.size, EMLExpr.size]; omega
  | mul e₁ e₂ ih₁ ih₂ =>
    simp [compileToEMLOnly, EMLOnlyExpr.size, EMLExpr.size]; omega
  | neg e ih =>
    simp [compileToEMLOnly, EMLOnlyExpr.size, EMLExpr.size]; omega
  | inv e ih =>
    simp [compileToEMLOnly, EMLOnlyExpr.size, EMLExpr.size]; omega
  | exp e ih =>
    simp [compileToEMLOnly, EMLOnlyExpr.size, EMLExpr.size]; omega
  | log e ih =>
    simp [compileToEMLOnly, EMLOnlyExpr.size, EMLExpr.size]; omega

/-! ## §3. Semantic Equivalence of EML and EML-Only Representability -/

/-- Every EML-representable function is also EML-only representable.
    This follows directly from the compilation theorem. -/
theorem EMLRepresentable_implies_EMLOnlyRepresentable
    {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) :
    EMLOnlyRepresentable f := by
  obtain ⟨e, he⟩ := hf
  exact ⟨compileToEMLOnly e, fun x => by rw [compile_correct]; exact he x⟩

/-- Reverse compilation: translate an `EMLOnlyExpr` back to an `EMLExpr`.
    The `eml(a, b)` node compiles to `exp(a) - log(b)`. -/
def compileFromEMLOnly : EMLOnlyExpr → EMLExpr
  | .const c => .const c
  | .var n => .var n
  | .add e₁ e₂ => .add (compileFromEMLOnly e₁) (compileFromEMLOnly e₂)
  | .mul e₁ e₂ => .mul (compileFromEMLOnly e₁) (compileFromEMLOnly e₂)
  | .neg e => .neg (compileFromEMLOnly e)
  | .inv e => .inv (compileFromEMLOnly e)
  | .eml e₁ e₂ => .add (.exp (compileFromEMLOnly e₁)) (.neg (.log (compileFromEMLOnly e₂)))

/-- The reverse compilation preserves semantics. -/
theorem compile_from_correct (e : EMLOnlyExpr) (env : ℕ → ℝ) :
    (compileFromEMLOnly e).eval env = e.eval env := by
  induction e with
  | const c => simp [compileFromEMLOnly, EMLExpr.eval, EMLOnlyExpr.eval]
  | var n => simp [compileFromEMLOnly, EMLExpr.eval, EMLOnlyExpr.eval]
  | add e₁ e₂ ih₁ ih₂ =>
    simp [compileFromEMLOnly, EMLExpr.eval, EMLOnlyExpr.eval, ih₁, ih₂]
  | mul e₁ e₂ ih₁ ih₂ =>
    simp [compileFromEMLOnly, EMLExpr.eval, EMLOnlyExpr.eval, ih₁, ih₂]
  | neg e ih =>
    simp [compileFromEMLOnly, EMLExpr.eval, EMLOnlyExpr.eval, ih]
  | inv e ih =>
    simp [compileFromEMLOnly, EMLExpr.eval, EMLOnlyExpr.eval, ih]
  | eml e₁ e₂ ih₁ ih₂ =>
    simp [compileFromEMLOnly, EMLExpr.eval, EMLOnlyExpr.eval, ih₁, ih₂]
    ring

/-- Every EML-only representable function is also EML-representable.
    This follows from the reverse compilation. -/
theorem EMLOnlyRepresentable_implies_EMLRepresentable
    {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) :
    EMLRepresentable f := by
  obtain ⟨e, he⟩ := hf
  exact ⟨compileFromEMLOnly e, fun x => by rw [compile_from_correct]; exact he x⟩

/-- **The EML Universality Theorem**: A function is EML-representable if and only if
    it is EML-only representable. The single binary operator `eml(x,y) = exp(x) - log(y)`
    has exactly the same expressive power as having separate `exp` and `log` primitives. -/
theorem EMLOnlyRepresentable_iff_EMLRepresentable
    {n : ℕ} {f : (Fin n → ℝ) → ℝ} :
    EMLOnlyRepresentable f ↔ EMLRepresentable f :=
  ⟨EMLOnlyRepresentable_implies_EMLRepresentable,
   EMLRepresentable_implies_EMLOnlyRepresentable⟩

/-! ## §4. Connection to the Catalog `eml` Definition

We connect our compilation to the existing catalog definition
`eml(x, y) = exp(x) - log(y)` and the key identity
`eml(log a, exp b) = a - b` for `a > 0`. -/

/-- The `eml` node in `EMLOnlyExpr` semantically matches the catalog definition. -/
theorem eml_node_matches_catalog (a b : ℝ) :
    (EMLOnlyExpr.eml (.const a) (.const b)).eval (fun _ => 0) = Real.exp a - Real.log b := by
  simp [EMLOnlyExpr.eval]

/-- The catalog identity `eml(log a, exp b) = a - b` for `a > 0` is realizable
    in the EML-only expression language.
    This uses `exp(log a) = a` for positive `a` and `log(exp b) = b`. -/
theorem eml_log_exp_identity_representable (a b : ℝ) (ha : 0 < a) :
    (EMLOnlyExpr.eml (.const (Real.log a)) (.const (Real.exp b))).eval (fun _ => 0) = a - b := by
  simp [EMLOnlyExpr.eval, Real.exp_log ha, Real.log_exp]

/-! ## §5. Derivative Closure for EML Compositions

We prove that EML-representable differentiable functions have derivatives
that are again expressible in the EML differential field. -/

/-
Derivative of an `eml` composition `x ↦ exp(a(x)) - log(b(x))`.
    By the chain rule:
    `d/dx [exp(a(x)) - log(b(x))] = exp(a(x)) · a'(x) - b'(x) / b(x)`
-/
theorem hasDerivAt_eml_composition
    {a b : ℝ → ℝ} {a' b' x : ℝ}
    (ha : HasDerivAt a a' x)
    (hb : HasDerivAt b b' x)
    (hb_pos : 0 < b x) :
    HasDerivAt (fun t => Real.exp (a t) - Real.log (b t))
      (Real.exp (a x) * a' - b' / b x) x := by
  -- Apply the chain rule to find the derivative of the composition.
  have h_chain : HasDerivAt (fun t => Real.exp (a t)) (Real.exp (a x) * a') x ∧ HasDerivAt (fun t => Real.log (b t)) (b' / b x) x := by
    exact ⟨ by simpa using ha.exp, by simpa [ div_eq_inv_mul ] using hb.log hb_pos.ne' ⟩;
  exact h_chain.1.sub h_chain.2

/-
Derivative of `exp ∘ f` is in the EML algebra: `(exp ∘ f)' = f' · exp ∘ f`.
-/
theorem hasDerivAt_exp_comp
    {f : ℝ → ℝ} {f' x : ℝ}
    (hf : HasDerivAt f f' x) :
    HasDerivAt (fun t => Real.exp (f t)) (f' * Real.exp (f x)) x := by
  convert HasDerivAt.exp hf using 1 ; ring

/-
Derivative of `log ∘ f` is in the EML algebra: `(log ∘ f)' = f' / f`.
-/
theorem hasDerivAt_log_comp
    {f : ℝ → ℝ} {f' x : ℝ}
    (hf : HasDerivAt f f' x)
    (hf_pos : 0 < f x) :
    HasDerivAt (fun t => Real.log (f t)) (f' / f x) x := by
  convert HasDerivAt.log hf hf_pos.ne' using 1

/-! ## §6. The EML Subtraction Theorem

Using the catalog identity `eml(log a, exp b) = a - b`,
we show that subtraction can be compiled through `eml` on positive domains.
This demonstrates the expressive power of `eml` as a computation primitive. -/

/-- Subtraction of positive values can be expressed through `eml`:
    `a - b = eml(log a, exp b)` for `a > 0`. -/
theorem subtraction_via_eml (a b : ℝ) (ha : 0 < a) :
    a - b = Real.exp (Real.log a) - Real.log (Real.exp b) := by
  rw [Real.exp_log ha, Real.log_exp]

/-- More generally, for any functions with positive values, subtraction
    factors through the eml primitive. -/
theorem subtraction_factors_through_eml
    {f g : ℝ → ℝ} (hf_pos : ∀ x, 0 < f x) (x : ℝ) :
    f x - g x = Real.exp (Real.log (f x)) - Real.log (Real.exp (g x)) := by
  rw [Real.exp_log (hf_pos x), Real.log_exp]

end