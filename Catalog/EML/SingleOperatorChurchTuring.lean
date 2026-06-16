/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The EML Single-Operator Church–Turing Thesis: Closure, Examples, and Synthesis

Building on `EML.SingleOperatorRepresentability` (grammars and semantics) and
`EML.SingleOperatorCompilation` (the bidirectional compilation establishing
`EMLOnlyRepresentable f ↔ EMLRepresentable f`), this file develops the
*function-algebra* structure of the EML-representable class and assembles the
**single-operator Church–Turing synthesis**:

> The single binary primitive `eml(x, y) = exp(x) − log(y)`, together with the
> field operations `(+, ×, neg, inv)` and real constants, generates a class of
> real functions that is closed under all elementary constructions — including
> the operators `exp`, `log`, and `eml` themselves — and coincides exactly with
> the two-operator `{exp, log}`-elementary class.

## Main results

### Closure of the two-operator class `EMLRepresentable`
* `EMLRepresentable_const`, `EMLRepresentable_proj`
* `EMLRepresentable_add`, `EMLRepresentable_mul`, `EMLRepresentable_neg`,
  `EMLRepresentable_sub`, `EMLRepresentable_inv`
* `EMLRepresentable_exp`, `EMLRepresentable_log`

### Closure transferred to the single-operator class `EMLOnlyRepresentable`
* `EMLOnlyRepresentable_const`, `EMLOnlyRepresentable_proj`,
  `EMLOnlyRepresentable_add`, `EMLOnlyRepresentable_mul`,
  `EMLOnlyRepresentable_neg`, `EMLOnlyRepresentable_sub`,
  `EMLOnlyRepresentable_inv`, `EMLOnlyRepresentable_exp`,
  `EMLOnlyRepresentable_log`
* `EMLOnlyRepresentable_eml` — the single primitive is itself a closure operation

### Concrete representable functions
* `EMLOnlyRepresentable_sinh`, `EMLOnlyRepresentable_cosh`,
  `EMLOnlyRepresentable_pow_nat`

### Quantitative two-way bound
* `compileFromEMLOnly_size_bound` — single → two-operator costs a factor ≤ 4
  (complementing the `compile_size_bound` factor ≤ 5 in the other direction)

### Synthesis
* `single_operator_church_turing` — the omnibus closure-plus-equivalence theorem.
-/
import EML.SingleOperatorCompilation

noncomputable section
open Real

/-
-- !-- Lab Notes -- !--
HYPOTHESIS (H1). The EML-only class is a genuine function algebra: closed under
+, ×, neg, inv, and the transcendental closures exp/log, and additionally under
the defining primitive eml itself. If true, the "single-operator thesis" is not
merely a syntactic re-encoding trick but a statement that one binary primitive
captures the full elementary closure.

EXPERIMENT. Prove the closure lemmas in the *two-operator* language `EMLExpr`
(where exp and log are first-class, so each lemma is a one-node extension), then
transport every statement across the compilation equivalence
`EMLOnlyRepresentable_iff_EMLRepresentable`. This avoids re-deriving the
exp/log identities inside the single-operator language for each closure step.

OUTCOME. All closure lemmas go through with one-line structural proofs. The
transport strategy is decisive: it turns 9 single-operator closure proofs into
9 trivial corollaries of the equivalence. Insight: the equivalence theorem is a
"closure-transfer engine" — any property closed in one language and invariant
under compilation is automatically available in the other.

FAILURE ANALYSIS. The only friction is the canonical environment `emlEnv`:
`emlEnv x ↑i` reduces to `x i` only after applying `emlEnv_coe`; with *literal*
indices (e.g. `var 0` at `n = 1`) one must first reconcile `(0 : ℕ)` with
`↑(0 : Fin 1)`. Resolved by routing literal-index examples through `emlEnv_coe`.
-/

/-! ## §1. Reverse size bound: single-operator → two-operator -/

/-- Compiling a single-operator expression back to the two-operator language
    costs at most a factor of `4` in size. Each `eml` node expands to the
    four-node pattern `add (exp _) (neg (log _))`; all other nodes are
    size-preserving. Combined with `compile_size_bound` (factor ≤ 5 in the
    forward direction), the two languages are *polynomially* — indeed linearly —
    inter-translatable, the quantitative content of the single-operator thesis. -/
theorem compileFromEMLOnly_size_bound (e : EMLOnlyExpr) :
    (compileFromEMLOnly e).size ≤ 4 * e.size := by
  induction e with
  | const _ => simp [compileFromEMLOnly, EMLExpr.size, EMLOnlyExpr.size]
  | var _ => simp [compileFromEMLOnly, EMLExpr.size, EMLOnlyExpr.size]
  | add e₁ e₂ ih₁ ih₂ =>
    simp [compileFromEMLOnly, EMLExpr.size, EMLOnlyExpr.size]; omega
  | mul e₁ e₂ ih₁ ih₂ =>
    simp [compileFromEMLOnly, EMLExpr.size, EMLOnlyExpr.size]; omega
  | neg e ih =>
    simp [compileFromEMLOnly, EMLExpr.size, EMLOnlyExpr.size]; omega
  | inv e ih =>
    simp [compileFromEMLOnly, EMLExpr.size, EMLOnlyExpr.size]; omega
  | eml e₁ e₂ ih₁ ih₂ =>
    simp [compileFromEMLOnly, EMLExpr.size, EMLOnlyExpr.size]; omega

/-! ## §2. Closure of the two-operator class `EMLRepresentable` -/

variable {n : ℕ}

/-- Constant functions are EML-representable. -/
theorem EMLRepresentable_const (c : ℝ) :
    EMLRepresentable (fun _ : Fin n → ℝ => c) :=
  ⟨EMLExpr.const c, fun _ => rfl⟩

/-- Coordinate projections are EML-representable. -/
theorem EMLRepresentable_proj (i : Fin n) :
    EMLRepresentable (fun x : Fin n → ℝ => x i) :=
  ⟨EMLExpr.var i, fun x => by simp [EMLExpr.eval]⟩

/-- The EML-representable class is closed under pointwise addition. -/
theorem EMLRepresentable_add {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) (hg : EMLRepresentable g) :
    EMLRepresentable (fun x => f x + g x) := by
  obtain ⟨e₁, h₁⟩ := hf; obtain ⟨e₂, h₂⟩ := hg
  exact ⟨EMLExpr.add e₁ e₂, fun x => by simp [EMLExpr.eval, h₁ x, h₂ x]⟩

/-- The EML-representable class is closed under pointwise multiplication. -/
theorem EMLRepresentable_mul {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) (hg : EMLRepresentable g) :
    EMLRepresentable (fun x => f x * g x) := by
  obtain ⟨e₁, h₁⟩ := hf; obtain ⟨e₂, h₂⟩ := hg
  exact ⟨EMLExpr.mul e₁ e₂, fun x => by simp [EMLExpr.eval, h₁ x, h₂ x]⟩

/-- The EML-representable class is closed under negation. -/
theorem EMLRepresentable_neg {f : (Fin n → ℝ) → ℝ} (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => -(f x)) := by
  obtain ⟨e, h⟩ := hf
  exact ⟨EMLExpr.neg e, fun x => by simp [EMLExpr.eval, h x]⟩

/-- The EML-representable class is closed under subtraction. -/
theorem EMLRepresentable_sub {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) (hg : EMLRepresentable g) :
    EMLRepresentable (fun x => f x - g x) := by
  have := EMLRepresentable_add hf (EMLRepresentable_neg hg)
  simpa [sub_eq_add_neg] using this

/-- The EML-representable class is closed under (total) inversion. -/
theorem EMLRepresentable_inv {f : (Fin n → ℝ) → ℝ} (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => (f x)⁻¹) := by
  obtain ⟨e, h⟩ := hf
  exact ⟨EMLExpr.inv e, fun x => by simp [EMLExpr.eval, h x]⟩

/-- The EML-representable class is closed under post-composition with `exp`. -/
theorem EMLRepresentable_exp {f : (Fin n → ℝ) → ℝ} (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => Real.exp (f x)) := by
  obtain ⟨e, h⟩ := hf
  exact ⟨EMLExpr.exp e, fun x => by simp [EMLExpr.eval, h x]⟩

/-- The EML-representable class is closed under post-composition with `log`. -/
theorem EMLRepresentable_log {f : (Fin n → ℝ) → ℝ} (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => Real.log (f x)) := by
  obtain ⟨e, h⟩ := hf
  exact ⟨EMLExpr.log e, fun x => by simp [EMLExpr.eval, h x]⟩

/-! ## §3. Closure transferred to the single-operator class -/

/-- Constants are single-operator representable. -/
theorem EMLOnlyRepresentable_const (c : ℝ) :
    EMLOnlyRepresentable (fun _ : Fin n → ℝ => c) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2 (EMLRepresentable_const c)

/-- Coordinate projections are single-operator representable. -/
theorem EMLOnlyRepresentable_proj (i : Fin n) :
    EMLOnlyRepresentable (fun x : Fin n → ℝ => x i) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2 (EMLRepresentable_proj i)

/-- Single-operator representability is closed under addition. -/
theorem EMLOnlyRepresentable_add {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) (hg : EMLOnlyRepresentable g) :
    EMLOnlyRepresentable (fun x => f x + g x) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2
    (EMLRepresentable_add ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hf)
      ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hg))

/-- Single-operator representability is closed under multiplication. -/
theorem EMLOnlyRepresentable_mul {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) (hg : EMLOnlyRepresentable g) :
    EMLOnlyRepresentable (fun x => f x * g x) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2
    (EMLRepresentable_mul ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hf)
      ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hg))

/-- Single-operator representability is closed under negation. -/
theorem EMLOnlyRepresentable_neg {f : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) :
    EMLOnlyRepresentable (fun x => -(f x)) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2
    (EMLRepresentable_neg ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hf))

/-- Single-operator representability is closed under subtraction. -/
theorem EMLOnlyRepresentable_sub {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) (hg : EMLOnlyRepresentable g) :
    EMLOnlyRepresentable (fun x => f x - g x) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2
    (EMLRepresentable_sub ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hf)
      ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hg))

/-- Single-operator representability is closed under inversion. -/
theorem EMLOnlyRepresentable_inv {f : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) :
    EMLOnlyRepresentable (fun x => (f x)⁻¹) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2
    (EMLRepresentable_inv ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hf))

/-- Single-operator representability is closed under `exp` — even though the
    single-operator language has no `exp` node, it is recovered through `eml`. -/
theorem EMLOnlyRepresentable_exp {f : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) :
    EMLOnlyRepresentable (fun x => Real.exp (f x)) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2
    (EMLRepresentable_exp ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hf))

/-- Single-operator representability is closed under `log`, again recovered
    purely through `eml`. -/
theorem EMLOnlyRepresentable_log {f : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) :
    EMLOnlyRepresentable (fun x => Real.log (f x)) :=
  (EMLOnlyRepresentable_iff_EMLRepresentable).2
    (EMLRepresentable_log ((EMLOnlyRepresentable_iff_EMLRepresentable).1 hf))

/-- **The primitive is a closure operation.** Single-operator representability
    is closed under the defining binary primitive
    `eml(f, g) = exp(f) − log(g)`. -/
theorem EMLOnlyRepresentable_eml {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLOnlyRepresentable f) (hg : EMLOnlyRepresentable g) :
    EMLOnlyRepresentable (fun x => Real.exp (f x) - Real.log (g x)) :=
  EMLOnlyRepresentable_sub (EMLOnlyRepresentable_exp hf) (EMLOnlyRepresentable_log hg)

/-! ## §4. Concrete single-operator representable functions

These witness that nontrivial transcendental functions live in the
single-operator class, with explicit `eml`-free `EMLExpr` constructions whose
representability transfers to the single-operator language automatically. -/

/-- `sinh` is single-operator representable. -/
theorem EMLOnlyRepresentable_sinh :
    EMLOnlyRepresentable (fun x : Fin 1 → ℝ => Real.sinh (x 0)) := by
  refine (EMLOnlyRepresentable_iff_EMLRepresentable).2 ?_
  refine ⟨EMLExpr.mul (.const (1/2))
    (.add (.exp (.var 0)) (.neg (.exp (.neg (.var 0))))), fun x => ?_⟩
  have hx : emlEnv x 0 = x 0 := by simpa using emlEnv_coe x (0 : Fin 1)
  simp only [EMLExpr.eval, Real.sinh_eq]
  rw [hx]; ring

/-- `cosh` is single-operator representable. -/
theorem EMLOnlyRepresentable_cosh :
    EMLOnlyRepresentable (fun x : Fin 1 → ℝ => Real.cosh (x 0)) := by
  refine (EMLOnlyRepresentable_iff_EMLRepresentable).2 ?_
  refine ⟨EMLExpr.mul (.const (1/2))
    (.add (.exp (.var 0)) (.exp (.neg (.var 0)))), fun x => ?_⟩
  have hx : emlEnv x 0 = x 0 := by simpa using emlEnv_coe x (0 : Fin 1)
  simp only [EMLExpr.eval, Real.cosh_eq]
  rw [hx]; ring

/-- Every fixed natural power `x ↦ (x i)^k` is single-operator representable. -/
theorem EMLOnlyRepresentable_pow_nat (i : Fin n) (k : ℕ) :
    EMLOnlyRepresentable (fun x : Fin n → ℝ => (x i) ^ k) := by
  induction k with
  | zero => simpa using EMLOnlyRepresentable_const (n := n) 1
  | succ m ih =>
    have := EMLOnlyRepresentable_mul ih (EMLOnlyRepresentable_proj i)
    simpa [pow_succ] using this

/-! ## §5. Synthesis: the single-operator Church–Turing thesis -/

/-- **The EML single-operator Church–Turing synthesis.**

For functions `f, g : (Fin n → ℝ) → ℝ`, the single-operator class
`EMLOnlyRepresentable` (generated by the *sole* transcendental primitive
`eml(x,y) = exp(x) − log(y)` together with the field operations and constants)

1. coincides with the two-operator `{exp, log}`-elementary class
   (`EMLRepresentable`);
2. contains all constants and coordinate projections;
3. is closed under `+`, `×`, `neg`, `−`, `inv`;
4. is closed under `exp`, `log`, and the primitive `eml` itself.

Thus a single binary operator suffices to generate the full elementary closure:
the bracketed statement is the formal content of the single-operator thesis. -/
theorem single_operator_church_turing (n : ℕ) :
    (∀ f : (Fin n → ℝ) → ℝ, EMLOnlyRepresentable f ↔ EMLRepresentable f)
    ∧ (∀ c : ℝ, EMLOnlyRepresentable (fun _ : Fin n → ℝ => c))
    ∧ (∀ i : Fin n, EMLOnlyRepresentable (fun x : Fin n → ℝ => x i))
    ∧ (∀ f g : (Fin n → ℝ) → ℝ, EMLOnlyRepresentable f → EMLOnlyRepresentable g →
        EMLOnlyRepresentable (fun x => f x + g x))
    ∧ (∀ f g : (Fin n → ℝ) → ℝ, EMLOnlyRepresentable f → EMLOnlyRepresentable g →
        EMLOnlyRepresentable (fun x => f x * g x))
    ∧ (∀ f : (Fin n → ℝ) → ℝ, EMLOnlyRepresentable f →
        EMLOnlyRepresentable (fun x => -(f x)))
    ∧ (∀ f : (Fin n → ℝ) → ℝ, EMLOnlyRepresentable f →
        EMLOnlyRepresentable (fun x => (f x)⁻¹))
    ∧ (∀ f : (Fin n → ℝ) → ℝ, EMLOnlyRepresentable f →
        EMLOnlyRepresentable (fun x => Real.exp (f x)))
    ∧ (∀ f : (Fin n → ℝ) → ℝ, EMLOnlyRepresentable f →
        EMLOnlyRepresentable (fun x => Real.log (f x)))
    ∧ (∀ f g : (Fin n → ℝ) → ℝ, EMLOnlyRepresentable f → EMLOnlyRepresentable g →
        EMLOnlyRepresentable (fun x => Real.exp (f x) - Real.log (g x))) :=
  ⟨fun _ => EMLOnlyRepresentable_iff_EMLRepresentable,
   EMLOnlyRepresentable_const,
   EMLOnlyRepresentable_proj,
   fun _ _ => EMLOnlyRepresentable_add,
   fun _ _ => EMLOnlyRepresentable_mul,
   fun _ => EMLOnlyRepresentable_neg,
   fun _ => EMLOnlyRepresentable_inv,
   fun _ => EMLOnlyRepresentable_exp,
   fun _ => EMLOnlyRepresentable_log,
   fun _ _ => EMLOnlyRepresentable_eml⟩

end