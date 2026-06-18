## YOUR ASSIGNMENT: Prime-Spectral Schrödinger Bridge for Closure-Generated Proof Semirings via Entropic Countermodel Transport

### TARGET THEOREM

The originally stated theorem
```lean
theorem derivable_iff_zero_entropic_bridge_cost
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (hK : MarkovKernel K)
  (x y : S) :
  derivable x y ↔ Tendsto (fun eps : ℝ => schrodingerCost eps K x y) atTop (nhds 0)
```
is conceptually right but almost certainly ill-typed as written: `eps : ℝ` with `atTop` does not express the zero-noise limit, and `schrodingerCost` must be tied to endpoint marginals extracted from `x` and `y`. You should first formalize the correct zero-temperature statement, then derive the advertised equivalence.

A robust Lean target is:

```lean
theorem derivable_iff_tendsto_schrodingerCost_zero
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (hK : IsMarkovKernel K)
  (x y : S) :
  derivable x y ↔
    Tendsto (fun ε : ℝ≥0 => schrodingerCost ε K x y) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0)
```

If the library setup prefers sequences rather than filters, prove the equivalent sequential version:

```lean
theorem derivable_iff_schrodingerCost_vanishes_along_inv
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (hK : IsMarkovKernel K)
  (x y : S) :
  derivable x y ↔
    Tendsto (fun n : ℕ => schrodingerCost (1 / (n + 1 : ℝ≥0)) K x y) atTop (nhds 0)
```

The genuinely breakthrough formulation is stronger and should be your real goal:

```lean
theorem schrodingerCost_zero_limit_eq_freeEnergyGap
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (hK : IsMarkovKernel K)
  (x y : S) :
  Tendsto (fun ε : ℝ≥0 => schrodingerCost ε K x y) (nhdsWithin 0 (Set.Ioi 0))
    (nhds (freeEnergyGap K x y))
```

together with the adequacy bridge

```lean
theorem derivable_iff_freeEnergyGap_zero
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (x y : S) :
  derivable x y ↔ freeEnergyGap K x y = 0
```

from which the desired theorem follows immediately by rewriting. If the catalog already contains a theorem of this shape, use it as the terminal reduction and focus your effort on the zero-noise convergence theorem.

### NECESSARY DEFINITIONS TO MAKE THE STATEMENT MATHEMATICALLY SHARP

You should make explicit the endpoint marginals associated to formulas/elements of the semiring. A good finite-state choice is:

```lean
def evalWeight {S : Type*} [CoherentClosureProofSemiring S]
  (x : S) (p : PrimeSpectrum S) : ℝ≥0∞ := ...

def normalizeOnFinite {α : Type*} [Fintype α] (w : α → ℝ≥0∞) : α → ℝ≥0∞ := ...

def sourceMarginal {S : Type*} [CoherentClosureProofSemiring S] [Fintype (PrimeSpectrum S)]
  (x : S) : PrimeSpectrum S → ℝ≥0∞ :=
  normalizeOnFinite (evalWeight x)

def targetMarginal {S : Type*} [CoherentClosureProofSemiring S] [Fintype (PrimeSpectrum S)]
  (y : S) : PrimeSpectrum S → ℝ≥0∞ :=
  normalizeOnFinite (evalWeight y)
```

Then define the static Schrödinger bridge objective on couplings:
```lean
def couplingHasMarginals
  {α : Type*} [Fintype α]
  (π : α → α → ℝ≥0∞) (μ ν : α → ℝ≥0∞) : Prop := ...

def relativeEntropyToKernel
  {α : Type*} [Fintype α]
  (π : α → α → ℝ≥0∞) (K : α → α → ℝ≥0∞) : ℝ≥0∞ := ...

def schrodingerObjective
  {α : Type*} [Fintype α]
  (ε : ℝ≥0) (K : α → α → ℝ≥0∞)
  (μ ν : α → ℝ≥0∞) (π : α → α → ℝ≥0∞) : ℝ≥0∞ := ...

def schrodingerCost
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  (ε : ℝ≥0) (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (x y : S) : ℝ≥0∞ :=
  sInf {c | ∃ π, couplingHasMarginals π (sourceMarginal x) (targetMarginal y) ∧
      schrodingerObjective ε K (sourceMarginal x) (targetMarginal y) π = c}
```

If this is too heavy, a weaker but still meaningful route is to define `schrodingerCost` abstractly by the static free-energy functional already present in the catalog, and then prove the convergence theorem as a theorem about an already-defined quantity.

### PRECISE INTERMEDIATE LEMMAS

The proof should be organized around four structural lemmas. These are the real engine.

1. **Zero-cost witness from derivability**
```lean
theorem derivable_gives_diagonal_coupling
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (hK : IsMarkovKernel K)
  {x y : S} :
  derivable x y →
  ∀ ε > 0, schrodingerCost ε K x y = 0
```
or at least `≤ freeEnergyGap K x y`, followed by `freeEnergyGap = 0`.

2. **Strict positive gap from non-derivability**
```lean
theorem not_derivable_gives_positive_freeEnergyGap
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  {x y : S} :
  ¬ derivable x y → 0 < freeEnergyGap K x y
```
This is the semantic separation theorem that converts countermodels into an energetic barrier.

3. **Zero-noise convergence**
```lean
theorem schrodingerCost_tendsto_freeEnergyGap
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (hK : IsMarkovKernel K)
  (x y : S) :
  Tendsto (fun ε : ℝ≥0 => schrodingerCost ε K x y)
    (nhdsWithin 0 (Set.Ioi 0)) (nhds (freeEnergyGap K x y))
```

4. **Equivalence extraction**
```lean
theorem derivable_iff_tendsto_schrodingerCost_zero
  ...
```
by combining (2) and (3) with `derivable_iff_freeEnergyGap_zero`.

### PROOF STRATEGY

#### Strategy A: Reduce entirely to the existing thermodynamic adequacy theorem
This is the most promising route if the catalog already identifies `freeEnergyGap K x y` as the semantic obstruction to derivability.

1. Prove or locate:
   ```lean
   derivable x y ↔ freeEnergyGap K x y = 0
   ```
   This is the semantic adequacy theorem from the thermodynamic dual semantics.

2. Define `schrodingerCost ε K x y` as an entropic regularization of the same static optimization problem whose zero-temperature limit is `freeEnergyGap K x y`.

3. Prove two inequalities:
   - lower semicontinuity / Γ-liminf:
     ```lean
     freeEnergyGap K x y ≤ liminf (fun ε => schrodingerCost ε K x y)
     ```
   - recovery sequence / limsup:
     ```lean
     limsup (fun ε => schrodingerCost ε K x y) ≤ freeEnergyGap K x y
     ```
   In finite state spaces, these should collapse to elementary estimates using compactness of couplings.

4. Conclude the full limit:
   ```lean
   Tendsto ... (nhds (freeEnergyGap K x y))
   ```
   Then rewrite by adequacy.

This route is strongest because it turns the desired theorem into a corollary of a more universal variational principle.

#### Strategy B: Direct separation into derivable and non-derivable cases
Use if the free-energy convergence theorem is too hard to formalize globally.

1. If `derivable x y`, use adequacy to show all admissible endpoint marginals can be joined by a zero-action or asymptotically zero-action bridge. Conclude
   ```lean
   ∀ δ > 0, ∃ ε₀, ∀ ε < ε₀, schrodingerCost ε K x y < δ
   ```

2. If `¬ derivable x y`, extract a prime countermodel `p : PrimeSpectrum S` separating `x` from `y`.

3. Show any coupling transporting `sourceMarginal x` to `targetMarginal y` must place positive mass on transitions forbidden or penalized by the semantic kernel. Deduce a uniform lower bound:
   ```lean
   ∃ c > 0, ∀ ε > 0, c ≤ schrodingerCost ε K x y
   ```
   or at least for all sufficiently small `ε`.

4. This directly yields failure of convergence to `0`.

This route avoids proving the exact limiting value, but still proves the target equivalence.

#### Strategy C: Finite-dimensional convex optimization / Sinkhorn duality
Use if you want an algorithmic theorem with computational shadow.

1. Express the bridge cost through dual potentials `φ ψ`:
   ```lean
   schrodingerCost ε K x y =
     sup { dualObjective ε K μ ν φ ψ | admissibleDual ... }
   ```
2. Show the dual objective converges pointwise to the free-energy gap / support functional.

3. Use finite-dimensional compactness to exchange `sup` and limit.

4. Deduce both convergence and an explicit iterative algorithm for computing witnesses/countermodels.

This route is harder in Lean but opens the strongest downstream program: certified Sinkhorn proof search and countermodel interpolation.

### CONCRETE PROOF STEPS IN LEAN

1. **Finite-state infrastructure**
   Establish basic summation lemmas over `PrimeSpectrum S`:
   ```lean
   lemma sum_normalizeOnFinite_eq_one ...
   lemma coupling_row_sum ...
   lemma coupling_col_sum ...
   ```
   You will likely need `Finset.univ.sum` identities and positivity facts in `ℝ≥0∞`.

2. **Monotonicity / nonnegativity of the entropic cost**
   Prove:
   ```lean
   theorem schrodingerCost_nonneg ... : 0 ≤ schrodingerCost ε K x y
   theorem schrodingerCost_mono_eps ... :
     ε₁ ≤ ε₂ → schrodingerCost ε₁ K x y ≤ schrodingerCost ε₂ K x y
   ```
   or the reverse inequality depending on normalization. Monotonicity often makes the limit argument much easier.

3. **Comparison with free-energy gap**
   Prove a sandwich estimate of the form
   ```lean
   theorem freeEnergyGap_le_schrodingerCost ...
   theorem schrodingerCost_le_freeEnergyGap_plus_entropy_term ...
   ```
   where the entropy term tends to `0` as `ε → 0+`. On a finite space, this can often be bounded by
   ```lean
   ε * C
   ```
   for a constant `C` depending only on `Fintype.card (PrimeSpectrum S)`.

4. **Zero-noise limit**
   From the sandwich estimate, deduce:
   ```lean
   have h₁ : Tendsto (fun ε => freeEnergyGap K x y) ... := tendsto_const_nhds
   have h₂ : Tendsto (fun ε => ε * C) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := ...
   ```
   Then apply order convergence / squeeze.

5. **Semantic equivalence**
   Finish with:
   ```lean
   constructor
   · intro hderiv
     have hgap : freeEnergyGap K x y = 0 := ...
     simpa [hgap] using schrodingerCost_tendsto_freeEnergyGap K hK x y
   · intro hlim
     by_contra hnd
     have hpos : 0 < freeEnergyGap K x y := not_derivable_gives_positive_freeEnergyGap K hnd
     have hlim' := schrodingerCost_tendsto_freeEnergyGap K hK x y
     -- contradiction: uniqueness of limits in Hausdorff spaces
   ```

### KEY LEMMAS AND LIBRARY TOOLS TO LOOK FOR

You should search for and exploit the following patterns in Mathlib:

- `Tendsto`, `nhdsWithin`, `Set.Ioi`, `atTop`
- uniqueness of limits in `T2Space`
- `ENNReal` arithmetic lemmas:
  - `ENNReal.add_lt_add`
  - `ENNReal.mul_lt_top`
  - coercions from `ℝ≥0`
- finite sums:
  - `Finset.sum_nonneg`
  - `Finset.sum_le_sum`
- infimum / minimization on finite sets if you discretize couplings
- compactness is avoidable if couplings are represented on a finite type and you prove existence via finite enumeration or by using an already-defined minimizer theorem from the catalog

If `ℝ≥0∞` becomes too painful for entropy, it is acceptable to formalize the main convergence theorem first in `ℝ` under a finiteness/strict positivity assumption on all relevant masses, and then derive the `ℝ≥0∞` corollary.

### STRONGEST SPECIAL CASE IF THE FULL THEOREM STALLS

If the full theorem over arbitrary coherent closure-generated proof semirings is too ambitious, prove the finite discrete special case where `PrimeSpectrum S` is explicitly a finite type and all marginals have full support.

For example:

```lean
theorem derivable_iff_tendsto_schrodingerCost_zero_finite_full_support
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (hfullx : ∀ p, sourceMarginal x p ≠ 0)
  (hfully : ∀ p, targetMarginal y p ≠ 0)
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ)
  (hK : IsStrictlyPositiveMarkovKernel K)
  (x y : S) :
  derivable x y ↔
    Tendsto (fun ε : ℝ => schrodingerCostReal ε K x y) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0)
```

Even this special case would already establish the stochastic-control semantics of derivability in a mathematically meaningful regime.

### WHY THIS MATTERS

This theorem is not an ornamental variant of existing thermodynamic semantics. It identifies proof theory with a zero-noise stochastic control problem on the prime spectrum. That changes the ontology of the subject.

- `derivable x y` becomes not merely a yes/no semantic fact, but the statement that the minimal entropic action between premise and conclusion collapses to zero.
- `¬ derivable x y` yields more than a static countermodel: it yields a whole interpolating Gibbs flow of countermodels, a dynamic obstruction witnessing why derivation fails.
- The free-energy gap from the existing program is reinterpreted as the endpoint value function of a Schrödinger bridge. This imports the full algorithmic machinery of entropic optimal transport—especially Sinkhorn iteration—into proof search, countermodel generation, and semantic interpolation.
- Once formalized, this opens a new computational pipeline: certified approximate proof search by entropic scaling, with a principled zero-temperature limit recovering exact derivability.
- Cross-domain significance: this links proof theory, statistical mechanics, and optimal transport in the same way Wasserstein geometry linked PDE, probability, and machine learning. If successful, it suggests a future “transport semantics” of logic where inference is studied via flows, geodesics, and entropy production.

### IF YOU CANNOT COMPLETE THE MAIN THEOREM

Then prove the following conjectural stepping stone precisely:

```lean
theorem schrodingerCost_zero_limit_eq_freeEnergyGap_finite
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (hK : IsMarkovKernel K)
  (x y : S) :
  Tendsto (fun ε : ℝ≥0 => schrodingerCost ε K x y)
    (nhdsWithin 0 (Set.Ioi 0)) (nhds (freeEnergyGap K x y))
```

and state the remaining conjecture:

```lean
conjecture derivable_iff_tendsto_schrodingerCost_zero_general
  {S : Type*}
  [CoherentClosureProofSemiring S]
  [Fintype (PrimeSpectrum S)]
  [DecidableEq (PrimeSpectrum S)]
  (K : PrimeSpectrum S → PrimeSpectrum S → ℝ≥0∞)
  (hK : IsMarkovKernel K)
  (x y : S) :
  derivable x y ↔
    Tendsto (fun ε : ℝ≥0 => schrodingerCost ε K x y)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 0)
```

### DELIVERABLES

1. The strongest proved theorem with exact Lean type signature.
2. Any new supporting definitions (`sourceMarginal`, `targetMarginal`, `schrodingerCost`, bridge admissibility).
3. 3–5 core lemmas proved cleanly with minimal `sorry`.
4. A `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps, such as:
   - dynamic Benamou–Brenier style proof-flow semantics on prime spectra,
   - certified Sinkhorn algorithms for countermodel interpolation,
   - large-deviation principles for rare semantic transitions,
   - tropical/zero-temperature limits connecting entropic proof transport to idempotent semantics,
   - quantum-channel analogues of proof kernels and noncommutative countermodel transport.

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
