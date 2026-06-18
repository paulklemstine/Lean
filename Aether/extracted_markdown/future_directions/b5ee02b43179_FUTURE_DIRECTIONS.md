# Future Directions: Duality-Driven Proof Transport in Tropical Computation

This document outlines five concrete research directions opened by the formalization of the min-plus/max-plus circuit duality theorem. Each direction is specific enough for a research team to pursue immediately, with clear hypotheses, proof strategies, and cross-domain connections.

---

## 1. Semiring-Isomorphism Transfer Theorem for Generic Circuit Languages

### Statement
Define a generic circuit language `Circuit(S)` parameterized by a semiring `S = (R, ⊕, ⊗)`, and prove that any semiring isomorphism `φ : S → T` induces a circuit translation `Φ : Circuit(S) → Circuit(T)` that preserves simulation complexity:

```
∀ s : ℕ → ℕ, SimulatesInS(s) ↔ SimulatesInT(s)
```

### Why It Matters
Our min-plus/max-plus duality is a special case: negation defines a semiring isomorphism `(ℝ, min, +) ≅ (ℝ, max, +)`. Generalizing to arbitrary semiring isomorphisms would yield a single meta-theorem covering tropical duality, Boolean duality (De Morgan), and algebraic circuit equivalences simultaneously.

### Proof Strategy
1. Define `GenericCircuit (α : Type) (op₁ op₂ : α → α → α)` as an inductive type.
2. Define evaluation and size functorially.
3. Given a bijection `φ : α → β` with `φ (op₁ a b) = op₁' (φ a) (φ b)` and `φ (op₂ a b) = op₂' (φ a) (φ b)`, construct `mapCircuit φ`.
4. Prove `eval ∘ mapCircuit φ = φ ∘ eval` by structural induction.
5. Size preservation is immediate; derive the simulation transfer.

### Cross-Domain Connection
This connects to categorical algebra (functors between Lawvere theories), circuit complexity (algebraic models of computation), and weighted automata (where different semirings model different resource metrics).

---

## 2. Tropical Circuit Lower Bounds Are Convention-Invariant

### Statement
Define a lower-bound predicate:

```
def HasLowerBound (f : (Fin n → ℝ) → ℝ) (b : ℕ) : Prop :=
  ∀ C : TropCircuit n, (∀ σ, C.eval σ = f σ) → b ≤ C.size
```

Prove that the same lower bound holds in the max-plus model:

```
theorem lower_bound_transfer (f : (Fin n → ℝ) → ℝ) (b : ℕ) :
    HasLowerBound f b →
    HasLowerBoundMax (fun σ => -f (dualVarAssign σ)) b
```

### Why It Matters
Circuit lower bounds are the holy grail of computational complexity. Proving that they are convention-invariant means researchers working in either the min-plus or max-plus tradition can cite each other's results directly. This eliminates a significant barrier to building cumulative lower-bound knowledge in tropical complexity.

### Proof Strategy
By contradiction: if a small max-plus circuit computes the dual function, dualize it to get a small min-plus circuit computing the original function, contradicting the lower bound. This is a direct application of `dual_involution` and `size_dual`.

### Cross-Domain Connection
Relates to monotone circuit complexity (Razborov, Alon–Boppana), arithmetic circuit lower bounds, and the general program of proving super-polynomial lower bounds in restricted models.

---

## 3. Weighted Automata Dualization Theorem

### Statement
Define min-plus and max-plus weighted automata over a finite alphabet `Σ`:

```
structure MinPlusWFA (Σ : Type) (n : ℕ) where
  init   : Fin n → ℝ
  trans  : Σ → Fin n → Fin n → ℝ
  accept : Fin n → ℝ
```

with semantics `⟦A⟧(w) = min over paths of (init cost + transition costs + accept cost)`.

Prove that negating all weights converts a min-plus WFA into a max-plus WFA computing the negated series:

```
theorem wfa_duality (A : MinPlusWFA Σ n) (w : List Σ) :
    evalMaxWFA (dualWFA A) w = - evalMinWFA A w
```

### Why It Matters
Weighted automata are the computational backbone of speech recognition, natural language processing, and formal verification of quantitative properties. The duality theorem means that algorithms developed for shortest-path (min-plus) automata—Dijkstra, Bellman-Ford, Viterbi—have automatic duals for longest-path (max-plus) problems in scheduling and critical path analysis.

### Proof Strategy
1. Define `dualWFA` by negating `init`, `trans`, and `accept`.
2. Prove the duality for single transitions by `neg_add` and `neg_inf`.
3. Extend to paths by induction on word length.
4. Use the circuit duality as a template: the inductive structure is analogous.

### Cross-Domain Connection
Bridges tropical circuits to formal language theory, connects to Schützenberger's theorem (rational power series), and provides a formal foundation for dualizing algorithms in operations research.

---

## 4. Tropical Boolean Compilation Invariance

### Statement
Prove that a Boolean function representable by polynomial-size min-plus tropical circuits is also representable by polynomial-size max-plus tropical circuits:

```
theorem boolean_compilation_invariance
    (f : (Fin n → Bool) → Bool) (p : ℕ → ℕ) (hp : Polynomial p) :
    MinTropComputable f p → MaxTropComputable f p
```

where `MinTropComputable f p` means there exists a family of min-plus circuits of size `≤ p n` that correctly computes `f` under the Boolean encoding.

### Why It Matters
This connects tropical circuit complexity to classical Boolean circuit complexity. If monotone Boolean functions have the same complexity in both tropical conventions, it suggests that the algebraic structure of tropical semirings does not create artificial separations in computational power—a fundamental insight for complexity theory.

### Proof Strategy
1. Use the existing `BoolMonoFormula.toTropCircuit` translation.
2. Show that the Boolean encoding `{0, 1} → ℝ` is compatible with negation duality.
3. Apply `simulation_transfer_iff` to transport the compilation result.
4. Handle the encoding/decoding boundary carefully using `encodeBool`/`decodeBool`.

### Cross-Domain Connection
Connects to Valiant's algebraic complexity theory, monotone circuit lower bounds (Razborov), and the P vs. NP question in restricted models.

---

## 5. Convex-Analytic Tropical Duality (Legendre–Fenchel Shadow)

### Statement
Define tropical piecewise-linear functions and prove a sign-conjugacy theorem:

```
def TropPWL (n : ℕ) := (Fin n → ℝ) → ℝ

def tropicalConjugate (f : TropPWL n) : TropPWL n :=
  fun x => -f (fun i => -x i)

theorem conjugate_involution (f : TropPWL n) :
    tropicalConjugate (tropicalConjugate f) = f

theorem circuit_realizes_conjugate
    (C : TropCircuit n) :
    tropicalConjugate (C.eval) = (C.dual).eval ∘ id
```

Then connect to Legendre–Fenchel duality:

```
theorem tropical_fenchel_duality (f : TropPWL n) (hf : IsTropicallyConvex f) :
    tropicalConjugate (tropicalFenchelTransform f) = f
```

### Why It Matters
This reveals the circuit duality theorem as a shadow of convex duality in tropical geometry. The Legendre–Fenchel transform is fundamental in optimization, statistical mechanics, and information geometry. Proving that tropical circuit duality is a discrete computational instance of this continuous mathematical principle opens deep structural connections.

### Proof Strategy
1. Define `IsTropicallyConvex` as closure under tropical convex combinations.
2. Define the tropical Fenchel transform as `f*(y) = sup_x (⟨x, y⟩ - f(x))` in max-plus.
3. Prove involutivity for tropically convex functions using idempotent analysis.
4. Show that min-plus circuit evaluation defines a tropically convex function.
5. Connect `tropicalConjugate` to `TropCircuit.dual` via the semantic duality theorem.

### Cross-Domain Connection
Bridges to optimization theory (duality in linear/convex programming), information geometry (exponential families and Bregman divergences), and theoretical physics (Maslov dequantization and semiclassical limits).

---

## Meta-Direction: Building a Formal Tropical Complexity Theory

The five directions above converge on a single program: **building a machine-verified tropical complexity theory** where:

- Circuit models are defined once and specialized to conventions via isomorphism.
- Lower bounds transfer automatically across conventions.
- Algorithms dualize formally, producing verified dual algorithms.
- Connections to Boolean complexity, automata theory, and convex analysis are proved, not assumed.

This program has the potential to become the first complete formal complexity theory for a non-Boolean computational model, establishing a template for formalizing complexity theory more broadly.
