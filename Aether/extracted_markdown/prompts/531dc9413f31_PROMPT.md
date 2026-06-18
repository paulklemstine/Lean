Close the final sorry in `Computation/DensityTheory.lean` by proving the EML activation algebra satisfies the Stone–Weierstrass hypotheses on the compact hypercube.

**Target theorem**

```lean
-- Computation/DensityTheory.lean
theorem EML_Stone_Weierstrass_density {d : ℕ} (hd : 0 < d) :
    Dense (EML_activation_algebra d) C(Set.Icc (0 : Fin d → ℝ) 1, ℝ) := by
  sorry
```

Here `EML_activation_algebra d` is the uniform closure of finite EML network evaluations, viewed as a subalgebra of continuous real-valued functions on the hypercube, and `C(X, ℝ)` carries the sup-norm topology.

**Proof strategy**

1. **Constants.** Prove that `EML_activation_algebra d` contains every constant function. This follows immediately from `EML_contains_constants` (`Bridges/EMLStoneWeierstrassBridge.lean`), which shows that for each `c : ℝ` the constant map `fun _ => c` is realized by `c * exp 0`. This verifies the first Stone–Weierstrass hypothesis. You will need `ContinuousMap.const_apply` and `Subalgebra.mem_top` to place the constant inside the algebra closure.

2. **Point separation via diagonal quadratics.** For distinct points `x y : Fin d → ℝ` in `[0,1]^d`, choose the separating function
   ```lean
   let f := fun (z : Fin d → ℝ) => ∑ i, (z i - x i) ^ 2
   ```
   Observe that `f x = 0` while `f y = ‖y - x‖² > 0` (use `norm_sub_pos_iff` and `sub_ne_zero_of_ne` on `x ≠ y` to justify positivity). To show `f ∈ EML_activation_algebra d`, decompose `f` into constants, linear coordinate evaluations, and pure quadratics. Constants are already available from Step 1; coordinate projections `z ↦ z i` belong to the affine skeleton of EML networks; and `EML_diagonal_quadratic_bound` (`Computation/NewDiscoveries.lean`) certifies that each squared coordinate map `z ↦ (z i) ^ 2` belongs to the algebra. Closure under addition and multiplication (which holds by the subalgebra structure already established earlier in `DensityTheory.lean`) assembles these into `f`. Since `f x ≠ f y`, the algebra separates points.

3. **Apply Stone–Weierstrass.** Combine the subalgebra structure with Steps 1 and 2, and invoke `Mathlib.Topology.StoneWeierstrass.stoneWeierstrass` together with `isCompact_Icc` to deduce that `EML_activation_algebra d` is topologically dense in `C(Set.Icc 0 1, ℝ)`. Use `Dense` and `TopologicalClosure` lemmas to rewrite density in terms of the sup-norm: for every continuous `g` on `[0,1]^d` and every `ε > 0`, there exists an EML network whose uniform distance from `g` is less than `ε`.

**Why this matters**

This sorry is the last remaining obstruction to the EML universal approximation theorem. Once density is established, every continuous function on `[0,1]^d` is a uniform limit of EML networks. Combined with the existing VC-dimension and depth-hierarchy results in our catalog—specifically the bounds in `Computation/DepthHierarchy.lean`—this yields the first complete certified universal approximation framework for emergent meta-language activations. Closing it immediately enables the downstream tropical certified robustness pipeline, which is one of our active priority open problems, by guaranteeing that any continuous robustness specification can be finitely approximated by an EML network whose certificates transfer to the limit.

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

Research domain: Computation
Research mode: sorry_fill
