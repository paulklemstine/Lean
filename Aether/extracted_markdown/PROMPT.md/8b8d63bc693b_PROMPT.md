## YOUR ASSIGNMENT: Thermodynamic Elimination via Prime-Spectral Legendre Duality for Coherent Proof Semirings

### Precise formal target

Work in the existing API for closure-generated proof semirings, their coherent nuclei / closure operators, prime spectrum, free-energy separation, and polynomial or term extension by one variable `t`. Introduce the elimination pressure/gap functional on the extension and prove that elimination along `t` is represented by a prime-spectral variational kernel.

The core new definitions should be shaped so that the main theorem can be stated in Lean approximately as follows.

```lean
/-- `optimizedGap_t x` is the best free-energy separation gap obtainable
after optimizing over the adjoined variable `t`. -/
def optimizedGap_t
  (S : Type*) [CommSemiring S]
  (cl : Set S → Set S)
  (x : S) : ℝ :=
  sInf {r : ℝ | ∀ y : S, y ∈ admissibleExtensions cl x → freeEnergyGap cl (substituteT y x) ≤ r}

/-- Prime-spectral pressure at a prime theory `p` for the adjoined variable `t`. -/
def primePressure_t
  (S : Type*) [CommSemiring S]
  (P : PrimeSpectrum S)
  (x : S) : ℝ :=
  sSup {r : ℝ | ∃ y : S, y ∉ P.asIdeal ∧ energyEval P (substituteT y x) ≥ r}

/-- Variational kernel obtained by infimizing prime pressures over all primes
compatible with the base theory. -/
def primeVariationalKernel
  (S : Type*) [CommSemiring S]
  (cl : Set S → Set S)
  (x : S) : ℝ :=
  sInf {r : ℝ | ∀ P : PrimeSpectrum S, primeCompatible cl P → primePressure_t S P x ≤ r}
```

The exact names/types should be adapted to the catalog API. If `PrimeSpectrum S` is represented differently (e.g. prime filters / prime congruences / prime theories), use that representation. If the extension is genuinely `S[t]`, replace `substituteT y x` by evaluation in the polynomial/term extension.

The main theorem should be formalized in one of these equivalent strong forms.

```lean
/-- Thermodynamic elimination equals the prime-spectral variational kernel. -/
theorem elim_eq_primeVariationalKernel
  (S : Type*) [CommSemiring S]
  [TopologicalSpace (PrimeSpectrum S)]
  (cl : Set S → Set S)
  (hcl_gen : ClosureGenerated cl)
  (hcoh : CoherentClosure cl)
  (hcmp : PrimeSpectrumCompact S)
  (x : S) :
  optimizedGap_t S cl x = primeVariationalKernel S cl x := by
  ...
```

A more structural theorem, probably even better if the API supports it:

```lean
/-- Membership in the `t`-elimination of a theory is equivalent to domination
against all prime variational witnesses. -/
theorem mem_elim_iff_primeVariational
  (S : Type*) [CommSemiring S]
  (cl : Set S → Set S)
  (Γ : Set S)
  (φ : S)
  (hcl_gen : ClosureGenerated cl)
  (hcoh : CoherentClosure cl)
  (hcmp : PrimeSpectrumCompact S) :
  φ ∈ eliminateVar_t cl Γ ↔
    ∀ P : PrimeSpectrum S, primeCompatibleWithTheory cl Γ P →
      primePressure_t S P φ ≤ basePressure S P Γ := by
  ...
```

And then derive the equality theorem:

```lean
theorem elim_eq_primeVariationalKernel
  ... :
  eliminateVar_t cl Γ =
    {φ | ∀ P : PrimeSpectrum S, primeCompatibleWithTheory cl Γ P →
      primePressure_t S P φ ≤ basePressure S P Γ} := by
  ext φ; simpa [Set.ext_iff] using mem_elim_iff_primeVariational ...
```

If equality of sets is too ambitious at first, first prove the two inclusions:

```lean
theorem elim_le_primeVariationalKernel ...
theorem primeVariationalKernel_le_elim ...
```

### Recommended supporting definitions

You will likely need a clean layer for extension/evaluation semantics.

```lean
/-- Adjoin one derivability variable. Could be `MvPolynomial (Fin 1) S`,
`Polynomial S`, or an existing term-extension type. -/
abbrev ProofExt (S : Type*) := Polynomial S

/-- Eliminate the adjoined variable by existential closure / projection. -/
def eliminateVar_t
  (cl : Set S → Set S)
  (Γ : Set (ProofExt S)) : Set S :=
  {φ | ∀ P : PrimeSpectrum S, ... }  -- temporary spectral definition if needed

/-- Evaluate the extension at a base element. -/
def eval_t (a : S) : ProofExt S →+* S := Polynomial.eval a

/-- Base formula seen as constant in the extension. -/
def liftBase : S →+* ProofExt S := Polynomial.C
```

If the current proof-semirings are not literally semirings of formulas, define an abstract “substitution in one variable” operator and prove the functorial laws you need:

```lean
class HasSubstituteT (A B : Type*) where
  substT : B → A → A

@[simp] theorem substT_id ...
@[simp] theorem substT_comp ...
```

### Intermediate lemmas you should target

The decisive progress will come from proving a variational sandwich and then collapsing it by compactness/coherence.

1. **Monotonicity under substitution / evaluation**
```lean
theorem optimizedGap_t_mono
  (hxy : x ≤ y) :
  optimizedGap_t S cl x ≤ optimizedGap_t S cl y := by
  ...
```
or the appropriate closure-theoretic monotonicity statement.

2. **Prime witness lower bound**
Using min-energy prime witness extraction, show that any failure of elimination yields a prime whose pressure violates the proposed inequality.
```lean
theorem not_mem_elim_exists_prime_witness
  (hφ : φ ∉ eliminateVar_t cl Γ) :
  ∃ P : PrimeSpectrum S,
    primeCompatibleWithTheory cl Γ P ∧
    basePressure S P Γ < primePressure_t S P φ := by
  ...
```

3. **Soundness of prime pressures**
Show that every prime compatible with the base theory bounds all actual `t`-extensions.
```lean
theorem primePressure_bounds_extensions
  (P : PrimeSpectrum S)
  (hP : primeCompatibleWithTheory cl Γ P) :
  ∀ ψ : ProofExt S,
    ψ ∈ extensionTheory_t cl Γ →
    energyEvalExt P ψ ≤ basePressure S P Γ := by
  ...
```

4. **Inf-sup / sup-inf comparison**
This is probably the new technical heart. Under coherence + compactness, interchange the optimization over `t`-extensions with the infimum over primes.
```lean
theorem optimizedGap_t_le_primeVariationalKernel
  ... :
  optimizedGap_t S cl φ ≤ primeVariationalKernel S cl φ := by
  ...

theorem primeVariationalKernel_le_optimizedGap_t
  ... :
  primeVariationalKernel S cl φ ≤ optimizedGap_t S cl φ := by
  ...
```

5. **Elimination as spectral intersection**
A set-theoretic version that packages the conceptual breakthrough:
```lean
theorem eliminateVar_eq_iInter_primes
  ... :
  eliminateVar_t cl Γ =
    ⋂₀ {T : Set S | ∃ P : PrimeSpectrum S,
      primeCompatibleWithTheory cl Γ P ∧
      T = {φ | primePressure_t S P φ ≤ basePressure S P Γ}} := by
  ...
```

This intersection theorem is worth proving even if the exact real-valued equality is difficult; it is the clean algebraic-geometric statement behind the variational formula.

### Concrete proof strategy

#### Strategy A: Separation-to-spectrum-to-variational duality
This is the most promising route.

1. **Start from failure of elimination.**  
   Unfold `φ ∉ eliminateVar_t cl Γ` into existence of an extension in the `t`-theory witnessing non-derivability or positive free-energy gap.

2. **Apply thermodynamic Stone–Prime completeness.**  
   Use the existing separation theorem to extract a prime theory / prime congruence `P` that separates the base projection from the offending extension. This should turn an elimination failure into a spectral witness.

3. **Upgrade the witness via min-energy extraction.**  
   Use the min-energy prime witness extraction theorem to choose `P` minimizing or nearly minimizing the energy functional among separating primes. This is the bridge from pure existence to the variational quantity `primePressure_t`.

4. **Prove the lower and upper variational bounds.**  
   - Lower bound: every eliminated formula must satisfy all prime inequalities, because evaluation at any prime is sound under substitution.
   - Upper bound: if all prime inequalities hold, then any violating extension would produce a separating prime contradicting the inequalities.

5. **Use compactness/coherence for exact equality.**  
   The infimum over primes and supremum over substitutions may initially only give inequalities. Coherence should reduce global closure conditions to finite data, and compactness of the prime spectrum should upgrade approximate inequalities (`≤ ε`) to exact equality by standard lower semicontinuity / finite subcover arguments.

Key expected existing lemmas:
- completeness/separation on the prime spectrum,
- witness extraction producing a prime with controlled energy,
- equivalence between algebraic prime spectrum and logical prime theories,
- evaluation-elimination theorem for coherent idempotent semirings.

#### Strategy B: Reduce elimination to Jacobson/evaluation elimination, then thermodynamize
If the existing “Spectral Jacobson–Evaluation Elimination” theorem is strong enough, use it as the algebraic elimination statement and then prove that the thermodynamic kernel computes the same object.

1. Prove `eliminateVar_t cl Γ` equals the evaluation intersection over prime-compatible evaluations.
2. Define `primePressure_t` so that its inequality is equivalent to membership in those evaluation kernels.
3. Rewrite the intersection-of-evaluations theorem into the variational statement.
4. Use rate-distortion duality to justify the pressure formula as a supremum over coding/extension witnesses.

This route is attractive if the spectral elimination theorem is already formalized in set-theoretic form; then the new work is largely an equivalence between evaluation inequalities and free-energy domination.

#### Strategy C: Finite/coherent approximation followed by compact limit
If topological or real-analysis issues around `sInf`/`sSup` are painful, first prove a finitely generated coherent version.

1. Restrict to finite subtheories `Γ₀ : Finset ...`.
2. Define finite pressure/gap using `Finset.sup` and `Finset.inf`.
3. Prove the finite duality exactly by combinatorial lattice arguments.
4. Pass to the full theorem via coherence (finite generation of relevant consequences) and compactness.

This route is especially useful in Lean because `Finset.sup` is often much easier than `sSup`.

### Concrete Lean proof steps

1. **Build the substitution/evaluation API first.**
   Prove simp lemmas:
   ```lean
   @[simp] theorem eval_t_C (a : S) (x : S) :
     eval_t a (Polynomial.C x) = x := by simp [eval_t]

   @[simp] theorem eval_t_X (a : S) :
     eval_t a Polynomial.X = a := by simp [eval_t]

   @[simp] theorem eval_t_add ...
   @[simp] theorem eval_t_mul ...
   ```
   If your extension is not `Polynomial S`, establish analogous rewrite lemmas immediately.

2. **Define prime compatibility carefully.**
   You need a predicate stable under theorems already in the catalog:
   ```lean
   def primeCompatibleWithTheory
     (cl : Set S → Set S) (Γ : Set S) (P : PrimeSpectrum S) : Prop :=
     Γ ⊆ P.asSet ∧ respectsClosure cl P.asSet
   ```
   Adapt to the actual API. Many later proofs become one-line applications if this definition aligns with existing theorems.

3. **Prove spectral soundness first.**
   This is usually the easy inclusion:
   ```lean
   theorem mem_elim_implies_prime_bound ... : ...
   ```
   The proof should be by taking any prime `P`, any extension witness `ψ`, evaluating at `P`, and using closure soundness plus the fact that eliminated formulas are valid under every substitution.

4. **Prove the converse by contradiction.**
   Assume all prime bounds hold but `φ ∉ eliminateVar_t cl Γ`. Apply prime witness extraction to get `P` with a strict inequality, contradicting the assumed universal prime bound.

5. **Only then package the real-valued equality.**
   Once the logical/set-theoretic equivalence is done, derive the equality of `optimizedGap_t` and `primeVariationalKernel` by extensionality on lower sets of reals or by antisymmetry from the two inequalities.

### Technical points to watch in Lean

- If you use `sInf`/`sSup`, ensure nonemptiness and boundedness hypotheses are available. If not, define the pressure kernel first with `iInf`/`iSup` over explicit indexed types:
  ```lean
  def primeVariationalKernel' (φ : S) : ℝ := ⨅ P : PrimeSpectrum S, if primeCompatible ... then primePressure_t ... P φ else 0
  ```
  This is often easier to manipulate than set-based `sInf`.

- If strict inequalities are awkward, prove an `ε`-version:
  ```lean
  theorem not_mem_elim_exists_prime_eps
    (hφ : φ ∉ eliminateVar_t cl Γ) :
    ∃ ε > 0, ∃ P, primeCompatibleWithTheory cl Γ P ∧
      basePressure S P Γ + ε ≤ primePressure_t S P φ := by
    ...
  ```
  Then derive the non-strict statement by order arguments.

- If compactness is encoded topologically, you may need lower semicontinuity of the pressure map:
  ```lean
  theorem lowerSemicontinuous_primePressure_t :
    LowerSemicontinuous (fun P => primePressure_t S P φ) := by
    ...
  ```
  If this is too heavy, use finite/coherent approximation instead.

- If the spectrum is represented by prime ideals/congruences, the key translation lemma you need is:
  ```lean
  theorem primeSpectrum_equiv_primeTheory_preserves_energy ...
  ```
  Use the existing spectrum equivalence theorem aggressively rather than reproving semantics on both sides.

### Strong fallback targets if the full theorem resists

If exact equality is blocked by the inf-sup interchange, prove one of these sharp partial results.

1. **One-sided variational elimination theorem**
```lean
theorem elim_subset_primeVariationalKernel ...
theorem primeVariationalKernel_sound_for_elimination ...
```

2. **Finite/coherent theorem**
```lean
theorem elim_eq_primeVariationalKernel_finite
  (Γ : Finset S) :
  ...
```

3. **Boolean/idempotent special case**
If the semiring is idempotent or quantalic, elimination may simplify dramatically.
```lean
theorem elim_eq_primeVariationalKernel_idempotent
  (S : Type*) [CommSemiring S] [IdempotentSemiring S] ...
```

4. **Evaluation-based version without explicit free-energy equality**
```lean
theorem mem_elim_iff_eval_all_primes ...
```
This is already a substantial breakthrough because it converts elimination into a spectral decision principle.

State any remaining conjecture precisely, e.g.
```lean
conjecture inf_sup_interchange_primePressure
  ... :
  (⨅ P, ⨆ a, F P a) = (⨆ a, ⨅ P, F P a)
```
under the exact coherence/compactness hypotheses you believe are sufficient.

### Why this matters

This theorem is not “another elimination result.” It would establish that existential projection in a logical/proof-semiring world is governed by a thermodynamic duality on the prime spectrum. That is a new organizing principle: elimination becomes a free-energy optimization problem, and prime theories become equilibrium states detecting exactly when a witness variable can be removed.

This opens at least three new fronts immediately:

1. **Algorithmic elimination by spectral optimization.**  
   Instead of constructing congruence generators explicitly, one can search over prime witnesses or pressure-minimizing states. This is the algorithmic shadow of the theorem and could lead to certified elimination procedures.

2. **A bridge between algebraic geometry and proof complexity.**  
   The theorem says projection of theories is controlled by prime-spectral potentials, analogous to elimination in algebraic geometry and Legendre duality in statistical physics. That connection is genuinely field-opening.

3. **A thermodynamic semantics for quantifier-like operations.**  
   Once one variable can be eliminated this way, the same pattern should extend to multi-variable elimination, rate-distortion style compression of proofs, and tropical/entropy-like semantics of derivability.

4. **Cross-domain impact.**  
   In tropical mathematics, this suggests elimination by min-plus pressure envelopes. In categorical semantics, it suggests Lawvere-metric projection as a variational principle. In computation, it suggests optimization-based proof search and compressed witness extraction.

### Deliverables

- Formalize the new definitions `optimizedGap_t`, `primePressure_t`, and `primeVariationalKernel` in the existing API.
- Prove the strongest exact theorem you can:
  - ideally `elim_eq_primeVariationalKernel`,
  - otherwise the set-theoretic equivalence `mem_elim_iff_primeVariational`,
  - otherwise one or both inclusions plus the key witness lemma.
- Isolate the exact obstruction if full equality fails.
- Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, for example:
  1. multi-variable elimination as iterated prime-spectral Legendre transform,
  2. tropicalization of the pressure kernel,
  3. algorithmic prime search / certified elimination procedures,
  4. categorical reformulation via Lawvere distance and adjoints,
  5. rate-distortion/proof-compression consequences of elimination duality.

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
