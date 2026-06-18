## YOUR ASSIGNMENT: Thermodynamic Stone–Prime Completeness for Closure-Generated Proof Semirings via Free-Energy Separation

**TARGET FILE**: `Bridges/ThermodynamicStonePrimeCompleteness.lean`

### Core theorem to formalize and prove

Work toward a theorem of the following shape: derivability in a closure-generated proof semiring is equivalent to validity against all thermodynamic/Lawvere valuation states on the prime congruence spectrum, and non-derivability yields a separating prime together with a quantitative free-energy gap.

Because the exact structures already present in the library may vary, organize the file around the following definitions and theorem interfaces, adapting names to the imported infrastructure while preserving the mathematical content.

#### Primary semantic predicate
```lean
def ThermoValid
  {S : Type _} [Semiring S]
  (derivable : S → S → Prop)
  (State : Type _)
  (eval : State → S → ℝ)
  (beta : State → ℝ)
  (x y : S) : Prop :=
  ∀ ω : State, eval ω x ≤ eval ω y
```

If your thermodynamic semantics already packages `β` and prime points separately, use the more structured version:
```lean
def ThermoValidβ
  {S P : Type _} [Semiring S]
  (eval : P → ℝ → S → ℝ)
  (x y : S) : Prop :=
  ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y
```

#### Separation statement
The key theorem should have a precise Lean shape close to:
```lean
theorem thermodynamic_prime_separation
  {S P : Type _} [Semiring S]
  (derivable : S → S → Prop)
  (eval : P → ℝ → S → ℝ)
  (PrimePoint : P → Prop)
  (x y : S) :
  ¬ derivable x y →
  ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x
```

#### Strong completeness statement
Then derive:
```lean
theorem thermodynamic_stone_prime_completeness
  {S P : Type _} [Semiring S]
  (derivable : S → S → Prop)
  (sound : ∀ {x y : S}, derivable x y → ∀ p β, 0 ≤ β → eval p β x ≤ eval p β y)
  (separate : ∀ {x y : S}, ¬ derivable x y →
    ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
  (x y : S) :
  derivable x y ↔ ∀ p : P, ∀ β : ℝ, 0 ≤ β → eval p β x ≤ eval p β y
```

The proof should be completely clean: one direction is soundness, the other is by contradiction using the separating witness.

### Quantitative strengthening

Do not stop at plain completeness. Add a strong quantitative corollary expressing a strict semantic margin.

```lean
def FreeEnergyGap
  {S P : Type _} [Semiring S]
  (eval : P → ℝ → S → ℝ)
  (p : P) (β : ℝ) (x y : S) : ℝ :=
  eval p β x - eval p β y
```

Then prove:
```lean
theorem nonderivable_has_positive_freeEnergyGap
  {S P : Type _} [Semiring S]
  (derivable : S → S → Prop)
  (eval : P → ℝ → S → ℝ)
  (PrimePoint : P → Prop)
  {x y : S} :
  ¬ derivable x y →
  ∃ p : P, PrimePoint p ∧ ∃ β : ℝ, 0 ≤ β ∧ 0 < FreeEnergyGap eval p β x y
```

This should be a one-line corollary from the strict inequality witness and `sub_pos.mpr`.

### Finite/coherent fragment: algorithmic countermodel extraction

If the catalog already contains a finite spectral search theorem for coherent or finitely presented proof semirings, expose it as an algorithmic corollary:

```lean
theorem finite_temperature_countermodel_search
  {S P : Type _} [Semiring S] [Fintype P]
  (derivable : S → S → Prop)
  (eval : P → ℝ → S → ℝ)
  (PrimePoint : P → Prop)
  {x y : S} :
  ¬ derivable x y →
  ∃ p : P, PrimePoint p ∧
    ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x
```

If a finite set of admissible temperatures is already available, strengthen further:
```lean
theorem finite_grid_countermodel_search
  {S P B : Type _} [Semiring S] [Fintype P] [Fintype B]
  (embedβ : B → ℝ)
  (eval : P → ℝ → S → ℝ)
  (derivable : S → S → Prop)
  {x y : S} :
  ¬ derivable x y →
  ∃ p : P, ∃ b : B, 0 ≤ embedβ b ∧ eval p (embedβ b) y < eval p (embedβ b) x
```

If the current library does not yet support discrete temperature grids, state this last result as a conjecture in a clearly isolated section.

---

## Mathematical definitions to instantiate from the existing infrastructure

Use the already-formalized Stone/prime/Lawvere/thermodynamic semantics as the source of truth. The new file should introduce only the minimal bridge definitions needed to state the theorem elegantly.

The intended semantic picture is:

- a prime point `p` in the prime congruence spectrum,
- a Lawvere valuation `V p : S → ℝ`,
- a thermodynamic deformation by inverse temperature `β`,
- a free-energy score `F p β x`,
- monotonicity of derivable entailments under `F`.

A good abstract interface is:
```lean
structure ThermoState (S P : Type _) where
  point : P
  beta : ℝ
  beta_nonneg : 0 ≤ beta
```

with evaluation
```lean
def thermoEval
  {S P : Type _} [Semiring S]
  (baseEval : P → S → ℝ)
  (energy : P → S → ℝ)
  (ω : ThermoState S P)
  (x : S) : ℝ :=
  baseEval ω.point x + ω.beta * energy ω.point x
```

If the existing thermodynamic semantics already uses `inf`, `sup`, `⊕`, `⊗`, or max-plus conventions, adapt the sign convention so that the completeness theorem still has the form “derivable iff all states satisfy the inequality”. The exact formula is less important than preserving:

1. derivable sequents are monotone under all states,
2. non-derivable sequents admit a separating state,
3. the separating state yields a strict positive gap.

---

## Proof architecture

### Strategy A: Direct assembly from soundness + prime separation + thermodynamic lift
This is likely the most promising route.

1. **Extract the prime separating witness**  
   Use the already-proved prime congruence spectrum theorem / constructive prime witness theorem to obtain:
   ```lean
   ¬ derivable x y → ∃ p, PrimePoint p ∧ ¬ semanticallyBelow p x y
   ```
   or an equivalent failure of order at a prime point.

2. **Lift prime separation to thermodynamic separation**  
   Show that the thermodynamic evaluation extends the Lawvere–Stone valuation at some admissible temperature, ideally `β = 0`.  
   The crucial bridge lemma should look like:
   ```lean
   lemma thermoEval_at_zero
     (eval0 : P → S → ℝ) (thermoEval : P → ℝ → S → ℝ) :
     ∀ p x, thermoEval p 0 x = eval0 p x
   ```
   Then any strict separation already present at the Stone/Lawvere level automatically becomes a thermodynamic separating witness by choosing `β = 0`.

3. **Upgrade strict failure to positive free-energy gap**  
   Convert
   ```lean
   eval p β y < eval p β x
   ```
   into
   ```lean
   0 < eval p β x - eval p β y
   ```
   using `sub_pos.mpr`.

4. **Prove the biconditional completeness theorem**  
   - forward direction: apply thermodynamic soundness,
   - reverse direction: contrapose using `thermodynamic_prime_separation`.

This route is strongest because it reduces the whole theorem to a compatibility lemma between the already-built Lawvere–Stone semantics and the thermodynamic deformation.

### Strategy B: Contrapositive via failure of universal validity
If the library more naturally gives semantic completeness than explicit prime witnesses:

1. Prove
   ```lean
   (¬ ∀ p β, 0 ≤ β → eval p β x ≤ eval p β y) →
   ¬ derivable x y
   ```
   by combining soundness with a violating witness.

2. Then use classical logic:
   ```lean
   by_contra h
   ```
   to derive universal validity from `¬ ¬ derivable x y`, and conclude derivability by the known Stone/Lawvere completeness theorem.

3. Recover the strict witness theorem as a corollary by unpacking the negation of the universal quantifier.

This is useful if your semantic infrastructure is already expressed as “valid in all models”.

### Strategy C: Finite spectral search for coherent fragments
For the algorithmic corollary:

1. Import the finite-search theorem for prime witnesses.
2. Show that the witness returned by the finite search can be interpreted as a thermodynamic state, again often with `β = 0`.
3. Package the result as a computational existence theorem over `[Fintype P]`, or over a `Finset P`.

This strategy creates the algorithmic shadow of the completeness theorem and is important for the broader program.

---

## Key intermediate lemmas you should explicitly isolate

These lemmas are likely the real heart of the file. Prove them first.

### 1. Thermodynamic extension agrees with base valuation at zero temperature
```lean
lemma thermo_eval_beta_zero
  {S P : Type _} [Semiring S]
  (eval₀ : P → S → ℝ)
  (thermoEval : P → ℝ → S → ℝ)
  (hzero : ∀ p x, thermoEval p 0 x = eval₀ p x) :
  ∀ p x, thermoEval p 0 x = eval₀ p x := hzero
```

If the existing semantics uses a normalized free energy formula, prove the exact zero-temperature or unit-temperature specialization that recovers the previously formalized Stone/Lawvere semantics.

### 2. Prime witness induces thermodynamic witness
```lean
lemma prime_witness_to_thermo_witness
  {S P : Type _} [Semiring S]
  (eval₀ : P → S → ℝ)
  (thermoEval : P → ℝ → S → ℝ)
  (hzero : ∀ p x, thermoEval p 0 x = eval₀ p x)
  {x y : S} {p : P} :
  eval₀ p y < eval₀ p x →
  ∃ β : ℝ, 0 ≤ β ∧ thermoEval p β y < thermoEval p β x :=
by
  intro hsep
  refine ⟨0, le_rfl, ?_⟩
  simpa [hzero p x, hzero p y] using hsep
```

### 3. Universal thermodynamic validity implies base validity
```lean
lemma thermo_valid_implies_zero_valid
  {S P : Type _} [Semiring S]
  (eval : P → ℝ → S → ℝ)
  {x y : S} :
  (∀ p β, 0 ≤ β → eval p β x ≤ eval p β y) →
  ∀ p, eval p 0 x ≤ eval p 0 y :=
by
  intro h p
  simpa using h p 0 le_rfl
```

### 4. Strict inequality gives positive gap
```lean
lemma freeEnergyGap_pos_of_lt
  {S P : Type _} [Semiring S]
  (eval : P → ℝ → S → ℝ)
  {p : P} {β : ℝ} {x y : S} :
  eval p β y < eval p β x →
  0 < FreeEnergyGap eval p β x y :=
by
  intro h
  dsimp [FreeEnergyGap]
  exact sub_pos.mpr h
```

### 5. Biconditional from soundness and separation
```lean
lemma completeness_of_soundness_and_separation
  {S P : Type _} [Semiring S]
  (derivable : S → S → Prop)
  (eval : P → ℝ → S → ℝ)
  (sound :
    ∀ {x y : S}, derivable x y → ∀ p β, 0 ≤ β → eval p β x ≤ eval p β y)
  (separate :
    ∀ {x y : S}, ¬ derivable x y →
      ∃ p : P, ∃ β : ℝ, 0 ≤ β ∧ eval p β y < eval p β x)
  (x y : S) :
  derivable x y ↔ ∀ p β, 0 ≤ β → eval p β x ≤ eval p β y :=
by
  constructor
  · intro hxy
    exact sound hxy
  · intro hvalid
    by_contra hnd
    rcases separate hnd with ⟨p, β, hβ, hlt⟩
    exact not_lt_of_ge (hvalid p β hβ) hlt
```

This lemma is mathematically central and should likely survive as reusable infrastructure.

---

## Lean tactics and implementation guidance

- Expect the main theorem to be short once the bridge lemmas are isolated.
- Use `by_contra`, `push_neg`, and `rcases` aggressively for the separation direction.
- For inequality transport, `simpa`, `linarith`, and `nlinarith` may help, but many goals should close with `exact`, `sub_pos.mpr`, and `not_lt_of_ge`.
- If the thermodynamic semantics lives in `ℝ≥0∞`, tropical numbers, or order duals, first prove an order-embedding lemma into `ℝ` or restate the theorem in the ambient ordered codomain. Do not fight coercions inside the main proof.
- If some imported theorem is stated with `≤` on the opposite side, normalize immediately with a helper lemma rather than carrying sign confusion through the file.

---

## What to do if the full theorem is blocked

If the exact thermodynamic deformation is too rigid to prove separation for arbitrary `β`, prove the decisive special case:

```lean
theorem thermodynamic_stone_prime_completeness_beta_zero
  {S P : Type _} [Semiring S]
  (derivable : S → S → Prop)
  (eval : P → ℝ → S → ℝ)
  (sound : ∀ {x y : S}, derivable x y → ∀ p β, 0 ≤ β → eval p β x ≤ eval p β y)
  (stone_complete :
    ∀ {x y : S}, (∀ p, eval p 0 x ≤ eval p 0 y) → derivable x y)
  (x y : S) :
  derivable x y ↔ ∀ p β, 0 ≤ β → eval p β x ≤ eval p β y
```

This is already a real theorem: it shows the thermodynamic semantics is conservative over the Stone semantics, hence complete.

If even that is blocked, prove the separation lemma alone:
```lean
theorem nonderivable_has_thermo_countermodel ...
```
and leave the biconditional as a clearly stated final conjecture.

---

## Why this theorem matters

This result is the hinge connecting three semantic regimes that are too often formalized separately:

1. **Prime spectral semantics** gives geometric witnesses of non-derivability.
2. **Lawvere/max-plus semantics** turns entailment into quantitative order comparison.
3. **Thermodynamic semantics** introduces inverse temperature and free energy, importing variational principles into proof theory.

The breakthrough is not merely another completeness theorem. It shows that proof failure is detectable as a strictly positive free-energy defect at a prime state. That is a new kind of completeness: not just truth-preservation, but quantitative energetic separation. This opens the door to:

- optimization-based proof search,
- entropy/free-energy heuristics for countermodel extraction,
- tropical and max-plus interpretations of logical entailment,
- finite-temperature semantics as a bridge between symbolic logic and statistical mechanics.

Algorithmically, the finite-search corollary means non-derivability can be witnessed by a concrete spectral/thermodynamic certificate. Conceptually, it upgrades Stone duality from a static representation theorem to a variational semantics of proof.

---

## Deliverables in the file

1. A minimal bridge definition for thermodynamic validity/free-energy gap.
2. A lemma showing thermodynamic semantics recovers the existing Stone/Lawvere semantics at a distinguished temperature (preferably `β = 0`).
3. A prime-to-thermodynamic separation theorem.
4. The main strong completeness biconditional.
5. A quantitative positive-gap corollary.
6. If possible, a finite/coherent fragment countermodel-search theorem.
7. At the end, add a precise conjecture only if a final strengthening remains open.

---

## FUTURE_DIRECTIONS.md

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, such as:

- a Hahn–Banach-style thermodynamic separation theorem for enriched proof semimodules,
- a tropical large-deviations semantics for proof complexity,
- finite-temperature completeness for weighted/modal proof semirings,
- an algorithm extracting minimal-energy countermodels from finite spectra,
- a variational duality theorem connecting derivability gaps to entropy minimizers.

Make these next steps precise enough that they can become the next theorem files.

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
