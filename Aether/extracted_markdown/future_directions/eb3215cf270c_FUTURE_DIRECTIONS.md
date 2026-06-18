# Future Directions: Tropical Brill-Noether Theory

## Synthesis

This cycle established two pillars of tropical Brill-Noether theory in Lean 4: the algebraic structure of the Brill-Noether number ρ(g,r,d), and the group-theoretic foundation of the graph Jacobian. The Brill-Noether number ρ(g,r,d) = g - (r+1)(g-d+r) was shown to satisfy Serre duality (ρ is invariant under the substitution (r,d) ↦ (g-1-d+r, 2g-2-d)), strict monotonicity in the degree parameter d (with increment exactly r+1 per unit), and a clean characterization of when ρ becomes negative. These are purely algebraic identities that hold independent of any geometric or graph-theoretic context.

On the graph-theoretic side, we constructed the Jacobian group Jac(G) = Div⁰(G)/Prin(G) as a quotient AddCommGroup, proving that the graph Laplacian has degree zero (the discrete divergence theorem), that linear equivalence is an equivalence relation via the Laplacian's additive structure, and that degree is preserved under linear equivalence. The Jacobian construction uses Mathlib's QuotientAddGroup infrastructure, with principal divisors forming a subgroup of degree-zero divisors.

The key structural insight is that Serre duality for ρ is a *purely combinatorial* identity — it holds at the level of integer arithmetic, before any geometry enters. This means the duality structure constraining tropical Brill-Noether theory is "hard-wired" into the definition of ρ itself.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|--------------|
| `brillNoether_serre_duality` | proved | ρ(g,r,d) = ρ(g, g-1-d+r, 2g-2-d) — combinatorial Serre duality |
| `brillNoether_increment` | proved | ρ(g,r,d+1) - ρ(g,r,d) = r+1 — exact linear growth rate |
| `brillNoether_strict_mono_d` | proved | ρ strictly increasing in d when r ≥ 0 — unique critical degree |
| `brillNoether_neg_high_genus` | proved | ρ < 0 when (r+1)(g-d+r) > g — emptiness criterion |
| `brillNoether_expand` | proved | ρ = (r+1)(d-r) - rg — alternative expansion |
| `brillNoether_zero_iff` | proved | ρ = 0 iff g = (r+1)(g-d+r) — boundary characterization |
| `laplacian_sum_zero` | proved | Discrete divergence theorem: deg(Δf) = 0 |
| `laplacianDiv_add` | proved | Laplacian is additive: Δ(f+g) = Δf + Δg |
| `linEquiv_equivalence` | proved | Linear equivalence is an equivalence relation |
| `linEquiv_preserves_degree` | proved | Degree is a class invariant under linear equivalence |
| `graphJacobian_addCommGroup` | proved | Jac(G) = Div⁰(G)/Prin(G) is an AddCommGroup |

## Research Directions

### Direction 1: Baker-Norine Riemann-Roch for Graphs

**Hypothesis**: For a divisor D on a connected graph G of genus g with canonical divisor K_G, rank(D) - rank(K_G - D) = deg(D) - g + 1.

**Test**: Formalize q-reduced divisors and Dhar's burning algorithm. Prove existence and uniqueness of q-reduced representatives in each linear equivalence class. Then the rank function is computable via the unique q-reduced form, and Riemann-Roch follows from a careful case analysis on the reduced representative of K_G - D.

**Why now**: We have the Jacobian group structure (linear equivalence is an equivalence relation with degree preservation), and the canonical divisor degree formula deg(K_G) = 2g-2 is already proved in the existing BakerNorine.lean. The missing piece is the q-reduced divisor theory.

**If true**: This would be, to our knowledge, the first complete formalization of a Riemann-Roch theorem for graphs in any proof assistant, connecting combinatorial chip-firing to algebraic geometry.

**If false**: The statement is a theorem (Baker-Norine 2007), so failure would indicate a formalization gap, likely in the definition of rank or the handling of the -1 convention.

### Direction 2: Matrix-Tree Theorem and Jacobian Cardinality

**Hypothesis**: |Jac(G)| = κ(G), the number of spanning trees of G.

**Test**: Show that Jac(G) is finite for connected graphs by proving the Laplacian restricted to non-root vertices has trivial kernel (using the matrix-tree theorem). Then compute |Jac(G)| for small examples (K₃, K₄, cycles) and verify against known spanning tree counts.

**Why now**: The Jacobian is now constructed as a quotient group. The Laplacian's kernel on degree-zero divisors modulo constants determines the group's rank. The key insight is that finiteness of the Jacobian is equivalent to the reduced Laplacian having full rank, which is exactly the condition for a connected graph.

**If true**: Gives a concrete computational handle on the Jacobian, connecting chip-firing to enumerative graph theory and the Kirchhoff matrix-tree theorem.

**If false**: Would indicate that our Jacobian definition doesn't correctly quotient by all principal divisors — a fixable formalization issue.

### Direction 3: Tropical Brill-Noether Existence via CDPR Construction

**Hypothesis**: For a generic chain of loops Γ with genus g and integers r,d with ρ(g,r,d) ≥ 0, there exists a divisor D on Γ with deg(D) = d and rank(D) ≥ r.

**Test**: Formalize the Cools-Draisma-Payne-Robeva allocation construction. Show that when ρ ≥ 0, a valid CDPR allocation exists (this is the combinatorial content). Then construct the corresponding divisor on the chain of loops and prove its rank is at least r using the metric structure.

**Why now**: The Brill-Noether number and its monotonicity are formalized. The key insight is that strict monotonicity in d means ρ ≥ 0 defines a half-line {d ≥ d₀} for each (g,r), and the CDPR construction provides an explicit witness at the boundary d₀. The genericity condition on loop lengths prevents rank from accidentally exceeding r.

**If true**: Completes the tropical proof of the Brill-Noether existence theorem, the first formalized proof of this result.

**If false**: Would likely indicate that the genericity condition needs strengthening, or that the rank computation on metric graphs requires additional infrastructure.

### Direction 4: Chip-Firing Dynamics and Stabilization

**Hypothesis**: Every divisor on a connected graph is linearly equivalent to a unique q-reduced divisor (for any fixed vertex q).

**Test**: Prove termination of Dhar's burning algorithm. Show that the algorithm produces a q-reduced divisor from any input. Prove uniqueness by showing that two distinct q-reduced divisors in the same equivalence class lead to a contradiction via the superstable characterization.

**Why now**: Linear equivalence is an equivalence relation (proved), and the Jacobian structure gives a quotient. The key insight is that q-reduced divisors provide canonical representatives — existence gives a section of the quotient map, and uniqueness shows it's injective, thus the Jacobian bijects with q-reduced divisors of degree zero.

**If true**: Makes the rank function computationally effective and gives a concrete description of Jacobian elements as q-reduced divisors.

**If false**: Would be surprising (this is a well-established theorem). Failure would indicate issues with the formalization of the burning algorithm on finite graphs.

### Direction 5: Serre Duality at the Level of Divisor Rank

**Hypothesis**: For any divisor D on a graph G of genus g, rank(D) + rank(K_G - D) ≥ deg(D) - g (a weak form of Riemann-Roch as an inequality, without the full equality).

**Test**: Prove the Riemann-Roch inequality using only effective divisor counting and the canonical degree formula. This avoids the full q-reduced divisor machinery while still giving a non-trivial constraint on ranks.

**Why now**: We have deg(K_G) = 2g-2, degree preservation under linear equivalence, and the rank definition. The key insight is that the inequality direction rank(D) ≥ deg(D) - g + 1 (Riemann's inequality) should be provable using only the effective divisor criterion and a pigeonhole argument on the Jacobian, without needing the full Baker-Norine machinery.

**If true**: Gives an accessible intermediate result toward full Riemann-Roch, with applications to tropical curve gonality bounds.

**If false**: Would indicate that the inequality direction itself requires the q-reduced divisor theory, making it no simpler than the full equality.
