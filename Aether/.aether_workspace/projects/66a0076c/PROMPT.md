**Goal.** Establish that the uniform closure of EML-generated functions on any nonempty compact subset of `Fin n → ℝ` is the full space of continuous real-valued functions, thereby resolving the open `EMLClosure` sorry targets.

**Theorem statement.** 

```lean
theorem eml_stoneWeierstrass {n : ℕ} (hn : 1 ≤ n) (K : Set (Fin n → ℝ))
    (hK : IsCompact K) (hKne : K.Nonempty) :
    let generators : Set C(K, ℝ) :=
      {f | ∃ (w : Fin n → ℝ) (b : ℝ),
        f = ⟨λ x => Real.exp (∑ i, w i * x.1 i + b), by continuity⟩ ∨
        f = ⟨λ x => (1 + Real.exp (-(∑ i, w i * x.1 i + b)))⁻¹, by continuity⟩ ∨
        (f = ⟨λ x => Real.log (∑ i, w i * x.1 i + b), by continuity⟩ ∧
         ∀ x ∈ K, 0 < ∑ i, w i * x.1 i + b)}
    let A := Subalgebra.adjoin ℝ generators
    SeparatesPoints (A : Set C(K, ℝ)) ∧ Dense (A : Set C(K, ℝ)) := by
```

**Proof strategy.**

*Step 1. Constants belong to `A` via the ℝ-subalgebra structure.*  
The generator with `w = 0` and `b = 0` yields `⟨λ _ => Real.exp 0, by continuity⟩ = ⟨λ _ => 1, continuous_const⟩`. Because `A = Subalgebra.adjoin ℝ generators` is an ℝ-subalgebra of `C(K, ℝ)`, it contains the scalar image of ℝ. Explicitly, for any `c : ℝ`, `c • 1 = ⟨λ _ => c, continuous_const⟩` belongs to `A` by `Subalgebra.smul_mem`.  
Key lemmas: `Real.exp_zero`, `Subalgebra.smul_mem`, `continuous_const`.

*Step 2. `A` separates points using an explicit self-dual linear functional.*  
For distinct `x, y ∈ K`, define `v : Fin n → ℝ` by `v i := x.1 i - y.1 i`. Since `x ≠ y`, there exists `i` with `v i ≠ 0`, hence `∑ i, v i * v i > 0`. Consider the generator  
`g := ⟨λ z => Real.exp (∑ i, v i * z.1 i), by continuity⟩`  
(take `w := v`, `b := 0`). Compute:
```
∑ i, v i * x.1 i - ∑ i, v i * y.1 i = ∑ i, v i * (x.1 i - y.1 i) = ∑ i, v i² > 0
```
By strict monotonicity of `Real.exp` (`Real.exp_strictMono`), `g x ≠ g y`. Since `g ∈ generators`, we have `g ∈ A` by `Subalgebra.subset_adjoin`. Thus `A` separates points of `K`.  
Key lemmas: `Finset.sum_sub_distrib`, `Real.exp_strictMono`, `ne_of_gt`, `Subalgebra.subset_adjoin`.

*Step 3. Invoke Stone–Weierstrass for density.*  
The subtype `K` is compact (`hK`) and nonempty (`hKne`). The set `A` is an ℝ-subalgebra of `C(K, ℝ)`, contains all constant functions (Step 1), and separates points (Step 2). Apply the Stone–Weierstrass theorem (in Mathlib, `Subalgebra.topologicalClosure_eq_top_of_separatesPoints` or the `stoneWeierstrass` formulation in `Mathlib.Topology.StoneWeierstrass`) to conclude that `A` is topologically dense in `C(K, ℝ)`.  
Key lemmas: `IsCompact.compactSpace` (to promote `IsCompact K` to `CompactSpace K`), `Subalgebra.topologicalClosure_eq_top_of_separatesPoints`, `Dense.eq_top_of_isClosed`.

**Why this matters.**  
This theorem resolves the open `EMLClosure` sorry targets by proving that the EML family satisfies the Stone–Weierstrass hypotheses, yielding a genuine universal approximation theorem inside Lean 4. It creates a rigorous cross-domain bridge from the algebraic EML structure (grounded in `eml_log_exp` from `EMLv17Core.lean`) to classical analysis: any continuous function on a compact domain can be uniformly approximated by finite EML expressions. Consequently, the verified EML kernel inherits the full expressive power of universal approximators, enabling you to lift compactness results such as `eml_cross_modal_compact` (`MultiModalTheory.lean`) and `eml_domain_proj_compact` (`TransferLearningTheory.lean`) into density and approximation guarantees for transfer learning and multi-modal inference without ever leaving the proof assistant.

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
