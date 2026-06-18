# Future Directions: Tropical Non-Encodability and Semiring Complexity Theory

## Overview

The tropical non-encodability barrier theorem establishes that tropical (min-plus) sublevel sets cannot represent arbitrary CNF satisfiability. This opens several breakthrough-level research directions, each building on the formal infrastructure developed here.

---

## Direction 1: From Formulas to Circuits — Shared Subexpressions and DAG Complexity

**Current state:** The barrier theorem applies to tropical formulas (tree-structured expressions). The monotonicity proof extends trivially to circuits (DAGs with shared subexpressions), since evaluation semantics is compositional.

**Next step:** Formalize tropical circuits as DAGs and prove the monotonicity/sublevel-closure theorems in this setting. Define circuit *size* (number of gates) and *depth*, and establish:

```
theorem tropical_circuit_sublevel_downward_closed
  {n : ℕ} (C : TropCircuit n) (k : ℕ) :
  IsLowerSet {a : Fin n → ℕ | evalCircuit C a ≤ k}
```

**Why breakthrough:** This extends the barrier from exponential-size formulas to polynomial-size circuits, which is the setting relevant to complexity theory. It would show that even with the power of sharing (which can exponentially compress computation), tropical evaluation remains monotone.

**Technical challenges:** Defining DAG-structured circuits inductively in Lean requires care with sharing semantics. A topological-sort evaluation or an environment-based semantics may be needed.

**Estimated difficulty:** Medium. The mathematics is straightforward; the formalization requires good data structure choices.

---

## Direction 2: Tropical Support Complexity and Antichain Width Lower Bounds

**Current state:** We showed that tropical sublevel sets on Boolean vectors are order ideals. Order ideals are uniquely determined by their antichain of maximal elements.

**Next step:** Define *tropical support complexity* as a measure of how many incomparable "pieces" a tropical formula's sublevel set boundary has, and prove:

```
theorem support_complexity_le_size
  {n : ℕ} (φ : TropFormula n) (k : ℕ) :
  antichainWidth (sublevelBoundary φ k) ≤ φ.size
```

paired with:

```
theorem cnf_large_antichain_frontier
  (m : ℕ) : ∃ (n : ℕ) (F : CNF n),
    m ≤ antichainWidth (satBoundary F)
```

**Why breakthrough:** This would give a *quantitative* lower bound, not just an existential impossibility. It would show that representing certain CNF formulas as tropical sublevel sets requires formulas of size at least proportional to the antichain width of the SAT boundary — a combinatorial measure that can grow exponentially.

**Connection to Dedekind numbers:** The number of antichains of width ≤ w in {0,1}^n is related to the Dedekind numbers and Sperner theory. This connects tropical complexity to extremal combinatorics.

**Estimated difficulty:** Hard. The upper bound on support complexity requires careful analysis of how min and + operations compose antichain boundaries.

---

## Direction 3: Existential Projections — When Does Tropical Recover NP?

**Current state:** Our barrier applies to sublevel sets without projections. But in practice, many reductions introduce auxiliary variables: one asks whether ∃y. eval(φ, x, y) ≤ k.

**Next step:** Investigate whether existential projections of tropical sublevel sets can represent arbitrary NP predicates. Formally:

```
-- Can projected tropical sublevel sets capture SAT?
def projectedSublevel (φ : TropFormula (n + m)) (k : ℕ) : Set (Fin n → ℕ) :=
  {a | ∃ y : Fin m → ℕ, eval φ (Fin.append a y) ≤ k}
```

**Conjecture:** Projected tropical sublevel sets can represent arbitrary NP predicates (since shortest-path with existential choices captures NP).

**Why breakthrough:** If true, this precisely locates the boundary of the barrier: tropical computation without projections is trapped in the downward-closed world, but projections break out. This would formalize the intuition that "existential quantification is the source of computational hardness" in the tropical setting.

**Estimated difficulty:** Hard. Proving the positive direction (every NP predicate is a projected tropical sublevel set) requires constructing a reduction from 3-SAT to a tropical feasibility problem, likely through network flow or shortest-path formulations.

---

## Direction 4: Semiring Simulation Preorders

**Current state:** We have one instance of semiring non-simulation (tropical cannot simulate Boolean for sublevel encodings).

**Next step:** Define a general framework for comparing computational power of semirings:

```
-- Semiring S can simulate semiring T via sublevel sets
def SemiringSimulates (S T : Type) [Semiring S] [Semiring T] [LE S] : Prop :=
  ∀ (n : ℕ) (f : (Fin n → T) → T),
    T.computable f →
    ∃ (g : (Fin n → S) → S) (encode : T → S) (k : S),
      S.computable g ∧
      ∀ a, f a ≤ₜ k ↔ g (encode ∘ a) ≤ₛ k
```

Then systematically map out the simulation preorder among:
- Boolean semiring ({0,1}, ∨, ∧)
- Tropical semiring (ℕ, min, +)
- Arithmetic semiring (ℤ, +, ×)
- Fuzzy/probabilistic semiring ([0,1], max, ×)
- The schedule algebra (ℝ ∪ {-∞}, max, +)

**Why breakthrough:** This would create the first systematic "complexity zoo" for semiring computation. Each non-simulation result is an unconditional barrier theorem. The structure of the preorder itself becomes an object of mathematical interest.

**Estimated difficulty:** Very hard (as a complete program), but individual pairs are tractable. The tropical-Boolean pair is done; the next natural target is Boolean vs. arithmetic (connecting to algebraic circuit complexity).

---

## Direction 5: Tropical Barriers Meet Monotone Complexity

**Current state:** Classical monotone circuit lower bounds (Razborov 1985, Alon-Boppana 1987) show that monotone Boolean circuits cannot efficiently compute certain functions. Our tropical barrier is philosophically similar but operates in a different algebraic setting.

**Next step:** Establish a formal comparison between tropical formula complexity and monotone Boolean circuit complexity:

1. Show that every tropical formula of size s can be simulated by a monotone Boolean circuit of size poly(s) on Boolean inputs (under the standard encoding 0 = false, 1 = true).

2. Conversely, show that tropical formulas are *strictly more restrictive* than monotone Boolean circuits, because they preserve the full metric order on ℕ, not just the Boolean comparison.

3. Derive tropical formula lower bounds for specific functions (e.g., the threshold function, the majority function) using Razborov's method of approximations adapted to the tropical setting.

**Why breakthrough:** This would embed tropical complexity into the classical monotone complexity landscape, allowing transfer of lower bound techniques. The tropical setting may actually be *easier* to prove lower bounds in, because the algebraic structure is richer.

**Connection to Razborov's method:** Razborov's approximation method works by replacing a Boolean function with a "smooth" approximation and tracking the error. In the tropical setting, the analogous tool might be replacing a piecewise-linear function with a smooth convex function and tracking the approximation error in the L∞ norm.

**Estimated difficulty:** Hard but highly promising. The comparison between tropical and monotone Boolean circuits is likely provable with current techniques.

---

## Concrete Milestones

### Short-term (1–3 months)
- [ ] Formalize tropical circuits (DAGs) and extend the barrier theorem.
- [ ] Define and compute antichain frontier width for families of CNF formulas.
- [ ] Prove the support-complexity upper bound for tropical formulas.
- [ ] Implement a tropical circuit simulator with complexity analysis.

### Medium-term (3–12 months)
- [ ] Characterize projected tropical sublevel sets (Direction 3).
- [ ] Establish the tropical-to-monotone-Boolean simulation (Direction 5).
- [ ] Prove tropical formula lower bounds for threshold and majority functions.
- [ ] Define semiring simulation preorder and classify 3–4 pairs.

### Long-term (1–3 years)
- [ ] Build a comprehensive Lean library for semiring complexity theory.
- [ ] Extend barriers to approximate encodings with quantitative error bounds.
- [ ] Connect tropical barriers to algebraic proof complexity (tropical Nullstellensatz).
- [ ] Investigate quantum semirings and their simulation relationships.

---

## Key Open Questions

1. **Is the existential projection of any polynomial-size tropical sublevel set an NP predicate?** (Almost certainly yes, but formal proof requires careful encoding.)

2. **Does every NP predicate arise as a projected polynomial-size tropical sublevel set?** (Likely yes, via network flow reductions.)

3. **Can tropical formula lower bounds be proved for explicit functions using Razborov-style approximations?** (This would be a significant advance in algebraic complexity theory.)

4. **Is there a "tropical natural proofs" barrier limiting what tropical lower bound methods can achieve?** (Speculative but important for understanding the limits of this approach.)

5. **Do tropical barriers compose?** (Can we combine multiple semiring non-simulation results to obtain stronger separations?)

---

## Impact Assessment

The tropical non-encodability theorem is the first formally verified result in what we propose to call *semiring complexity theory*. Its significance lies not in any single impossibility result, but in the paradigm it establishes:

- **Algebraic invariants as complexity barriers.** Instead of ad hoc arguments, we derive obstructions from the algebraic structure of computation.
- **Machine-checked certainty.** Formal verification eliminates the risk of subtle errors in barrier arguments.
- **Composability.** Each new semiring non-simulation result adds to a growing library of reusable obstructions.
- **Cross-domain connections.** The framework naturally connects complexity theory to order theory, convex geometry, statistical physics, and algebraic geometry.

This is not a one-time result but the foundation of a research program.
