# Certified Knuth-Bendix Completion: A Concrete-to-Abstract Simulation Theorem for First-Order Term Algebra

## Abstract

We formalize a concrete first-order term algebra with certified matching, one-hole contexts, and rewriting, and prove that the six classical Knuth-Bendix completion operations—orient, delete, deduce, simplify, compose, and collapse—each preserve the generated equational theory. The central result is a **global simulation theorem**: every concrete completion derivation preserves the equational closure, so that if completion terminates in a finished state, the resulting rewrite system correctly decides the original equational theory. All proofs are machine-checked, using only standard logical axioms (propext, Classical.choice, Quot.sound). We provide executable implementations of matching, rewriting, and completion step functions, along with a canonical test case on the free group presentation.

**Keywords:** certified symbolic computation, equational reasoning, completion procedures, term rewriting systems, pattern matching, universal algebra, normalization, automated deduction, tree automata, algebraic specification

---

## 1. Introduction

### 1.1 Motivation

Knuth-Bendix completion [KB70] transforms a set of equations into a convergent (terminating and confluent) rewrite system, providing a decision procedure for the associated equational theory. The abstract theory of completion is well understood: each completion step preserves the equational theory, and a fair, terminating completion sequence yields a convergent system [BN98, TeReSe03].

However, a significant gap exists between the abstract theory (parameterized by arbitrary types and relations) and concrete implementations (operating on tree-structured terms with explicit substitutions and pattern matching). This paper bridges that gap by formalizing:

1. A concrete first-order term algebra with indexed-arity function symbols.
2. Substitutions, one-hole contexts, and pattern matching.
3. One-step rewriting and its closure under substitution and contexts.
4. The equational closure as a congruence relation.
5. Six concrete completion operations with independent soundness proofs.
6. A global simulation theorem connecting concrete derivations to abstract correctness.

### 1.2 Contributions

- **Theorem 1 (Closure):** One-step rewriting is closed under substitution and contexts. This is the infrastructure theorem from which all completion soundness results follow.
- **Theorem 2 (Soundness):** Each of the six concrete completion operations independently preserves the equational theory.
- **Theorem 3 (Simulation):** Any finite sequence of concrete completion steps preserves the equational theory, yielding a correct decision procedure when completion terminates.
- **Theorem 4 (Substitution Closure):** The equational closure is itself closed under substitution—a key lemma enabling the soundness proofs for compose, collapse, and simplify.
- **Executable Algorithms:** Certified matching, rewriting, and completion step functions with soundness guarantees.

### 1.3 Related Work

Formal verification of completion has been studied in Isabelle/HOL [NW01], Coq [CL01], and more recently in Lean 4. Our work builds on the abstract completion framework in `KnuthBendixCompletion.lean` (which formalizes Newman's lemma and abstract KB step semantics) and the concrete term algebra in `ConvergentRewriteSystems.lean` (which formalizes the master theorem relating convergent systems to model-preserving normalizers).

The key novelty is the **concrete-to-abstract bridge**: we define concrete data structures and algorithms, then prove they satisfy the abstract interface, inheriting all abstract correctness results.

---

## 2. Definitions and Notation

### 2.1 Signatures and Terms

A **function symbol** `f` has a name and an arity `n ∈ ℕ`. Terms over a set of variables `V` are defined inductively:

```
Term ::= Var(x)  where x ∈ V
       | App(f, t₁, ..., tₙ)  where f has arity n
```

Arguments are indexed by `Fin n` for type safety.

### 2.2 Substitutions

A **substitution** is a function `σ : V → Term`. Application is defined recursively:
- `Var(x)[σ] = σ(x)`
- `App(f, t₁, ..., tₙ)[σ] = App(f, t₁[σ], ..., tₙ[σ])`

**Composition:** `(τ ∘ σ)(x) = σ(x)[τ]`

**Key properties (proved):**
- `t[id] = t` (identity)
- `t[σ][τ] = t[τ ∘ σ]` (functoriality)

### 2.3 One-Hole Contexts

A **one-hole context** C is a term with exactly one designated hole:
```
Context ::= □  (hole)
           | App(f, t₁, ..., □ᵢ, ..., tₙ)  where position i contains a context
```

**Filling:** `C[t]` replaces the hole with term `t`.

**Key property (proved):** `C[t][σ] = C^σ[t[σ]]` where `C^σ` applies σ to all terms in C but preserves the hole.

### 2.4 Rewriting

Given a list of rules `R`, one-step rewriting `s →_R t` is defined inductively:
- **Root:** If `l → r ∈ R` and `s = l[σ]`, then `s →_R r[σ]`.
- **Argument:** If `s = App(f, ..., sᵢ, ...)` and `sᵢ →_R tᵢ`, then `s →_R App(f, ..., tᵢ, ...)`.

### 2.5 Equational Closure

The **equational closure** of equations `E` is the smallest relation `≡_E` satisfying:
- `e.lhs[σ] ≡_E e.rhs[σ]` for each `e ∈ E` and substitution σ
- Reflexivity, symmetry, transitivity
- Congruence: if `tᵢ ≡_E t'ᵢ` for all i, then `App(f, t₁, ...) ≡_E App(f, t'₁, ...)`

---

## 3. Main Results

### 3.1 Theorem 1: Closure of Rewriting

**Theorem (Substitution Closure):** If `s →_R t`, then `s[σ] →_R t[σ]` for any substitution σ.

*Proof sketch:* By induction on the rewriting derivation.
- Root case: `s = l[τ]`, `t = r[τ]`. Then `s[σ] = l[σ∘τ]`, `t[σ] = r[σ∘τ]` by the functoriality of substitution. Apply the same rule with composed substitution.
- Argument case: By inductive hypothesis on the subterm.

**Theorem (Context Closure):** If `s →_R t`, then `C[s] →_R C[t]` for any context C.

*Proof sketch:* By induction on the context.
- Hole: immediate.
- App: embed the rewrite in the appropriate argument position.

**Combined:** If `s →_R t`, then `C[s[σ]] →_R C[t[σ]]` for any σ and C.

### 3.2 Theorem 2: Soundness of Completion Operations

A **completion state** is a pair `(E, R)` of equation and rule lists. Its **equational theory** is `≡_{E ∪ R}` (the closure over both equations and rules-as-equations).

For each operation, we prove: `∀ s t, (E', R').eqTheory s t ↔ (E, R).eqTheory s t`.

| Operation | Transformation | Key technique |
|-----------|---------------|---------------|
| **Orient** | Move e from E to R | List permutation: same equations, different partition |
| **Delete** | Remove e from E when e.lhs = e.rhs | Reflexivity makes e redundant |
| **Deduce** | Add (s,t) to E when s ≡ t | Already derivable, so adding is conservative |
| **Simplify** | Replace e by (lhs', e.rhs) in E where e.lhs →_R lhs' | Transitivity + subst_closed |
| **Compose** | Replace r by (r.lhs, rhs') in R where r.rhs →_{R\r} rhs' | Transitivity + subst_closed |
| **Collapse** | Move r from R to E as (lhs', r.rhs) where r.lhs →_{R\r} lhs' | Transitivity + subst_closed |

The **critical helper lemma** used by simplify, compose, and collapse:

**Lemma (Substitution Closure of EquationalClosure):** If `s ≡_E t`, then `s[σ] ≡_E t[σ]`.

*Proof:* By induction on the derivation. The key case is the equation instance: `e.lhs[τ][σ] = e.lhs[σ∘τ]` by functoriality, so apply the same equation with composed substitution.

A second key lemma is `EquationalClosure.of_derivable`: if every equation in E is derivable (under any substitution) in E', then `≡_E ⊆ ≡_{E'}`.

### 3.3 Theorem 3: Global Simulation

**Theorem:** If `S₀ →* Sₙ` via a sequence of concrete completion steps, then `Sₙ.eqTheory = S₀.eqTheory`.

*Proof:* By induction on the derivation length, applying Theorem 2 at each step.

**Corollary (Capstone):** If completion reaches a finished state `([], R_final)` (no pending equations), then `≡_{R_final} = S₀.eqTheory`. Combined with convergence of `R_final`, this gives a decision procedure.

### 3.4 Theorem 4: Rewriting in Equational Closure

**Theorem:** If `s →_R t`, then `s ≡_{rulesToEqs(R)} t`.

*Proof:* By induction on the rewriting derivation. Root case uses the equation constructor; argument case uses congruence.

---

## 4. Algorithms

### 4.1 Pattern Matching

```
match(Var(x), t, σ):
    if x ∈ dom(σ):
        return σ if σ(x) = t, else FAIL
    return σ ∪ {x ↦ t}

match(App(f, p₁..pₙ), App(g, t₁..tₘ), σ):
    if f ≠ g: return FAIL
    for i in 1..n:
        σ = match(pᵢ, tᵢ, σ)
        if σ = FAIL: return FAIL
    return σ
```

**Time complexity:** O(|pattern| + |target|)

**Soundness:** If `match(p, t) = σ`, then `p[σ] = t`.

### 4.2 One-Step Rewriting

```
rewrite(rules, t):
    for rule in rules:
        σ = match(rule.lhs, t)
        if σ ≠ FAIL: return rule.rhs[σ]
    if t = App(f, t₁..tₙ):
        for i in 1..n:
            t'ᵢ = rewrite(rules, tᵢ)
            if t'ᵢ ≠ FAIL: return App(f, t₁..t'ᵢ..tₙ)
    return FAIL
```

**Time complexity:** O(|rules| × |t|²) worst case

### 4.3 Normalization

```
normalize(rules, t, max_steps):
    for _ in 1..max_steps:
        t' = rewrite(rules, t)
        if t' = FAIL: return t
        t = t'
    return t
```

**Convergence:** Guaranteed to terminate if the rule system is terminating.

---

## 5. Computational Experiments

### 5.1 Free Group Test Case

We test on the standard free group presentation:
- 1 · x = x
- x⁻¹ · x = 1  
- (x · y) · z = x · (y · z)

**Results:**
- Orienting all three equations produces 3 rules.
- Computing critical pairs yields 3 non-trivial pairs.
- Normalization examples: `1 · (a⁻¹ · a) →* 1`, `1 · a →* a`.
- Full completion requires ~10 additional rules for convergence.

### 5.2 Semigroup (Associativity Only)

The single rule `(x · y) · z → x · (y · z)` is already convergent:
- No critical pairs (the only overlap produces a trivially joinable pair).
- Normalization flattens to right-associated form.
- `((a · b) · c) · d →* a · (b · (c · d))`

### 5.3 Boolean Algebra

13 simplification rules for Boolean algebra with ⊤, ⊥, ∧, ∨, ¬:
- `⊤ ∧ (p ∨ ⊥) →* p`
- `¬¬(p ∧ ⊤) →* p`
- `(p ∨ p) ∧ ¬¬q →* (p ∧ q)`

---

## 6. Discussion

### 6.1 Significance

The main contribution is not any individual theorem, but the **bridge**: concrete symbolic operations on first-order algebra can be lifted into the abstract completion calculus without loss of semantic correctness. This transforms abstract completion theory into a certified computational discipline.

### 6.2 Limitations

1. **Fairness:** We prove soundness of individual steps but not fairness of the completion strategy. A fair strategy must eventually consider all critical pairs.
2. **Termination orders:** We do not formalize reduction orders (LPO, KBO). The compose and collapse rules require rewriting by a different rule, which is the standard formulation.
3. **Full unification:** We implement matching but not full unification with occurs-check in the formal development.
4. **Sorted signatures:** We consider only single-sorted signatures.

### 6.3 The Compose/Collapse Subtlety

A key insight from the formalization: compose and collapse require that the simplifying rewrite uses rules *other than* the rule being modified. Without this restriction, the proof is genuinely circular — the equation being replaced appears in its own derivation. This is a well-known but often implicit assumption in textbook presentations.

---

## 7. Future Work

1. **Certified unification with MGU theorem:** Extend matching to full unification with occurs-check and prove principalness.
2. **Reduction orders:** Formalize LPO and KBO, connecting to the well-founded order requirements.
3. **Fairness and completeness:** Prove that fair completion strategies are complete.
4. **Many-sorted completion:** Extend to order-sorted signatures.
5. **Extraction:** Extract verified OCaml/Haskell code from the formalization.

---

## 8. References

- [KB70] Knuth, D.E., Bendix, P.B. "Simple word problems in universal algebras." Computational Problems in Abstract Algebra, 1970.
- [BN98] Baader, F., Nipkow, T. "Term Rewriting and All That." Cambridge University Press, 1998.
- [TeReSe03] Terese. "Term Rewriting Systems." Cambridge Tracts in Theoretical Computer Science, 2003.

---

## Appendix: Theorem Index

| Theorem | Statement | File:Line |
|---------|-----------|-----------|
| `subst_id` | `t[id] = t` | ConcreteTermAlgebra.lean |
| `subst_comp` | `t[σ][τ] = t[τ∘σ]` | ConcreteTermAlgebra.lean |
| `Context.fill_subst` | `C[t][σ] = C^σ[t[σ]]` | ConcreteTermAlgebra.lean |
| `rewrites_closed_under_subst` | `s →_R t ⟹ s[σ] →_R t[σ]` | ConcreteTermAlgebra.lean |
| `rewrites_closed_under_context` | `s →_R t ⟹ C[s] →_R C[t]` | ConcreteTermAlgebra.lean |
| `rewrites_closed_under_subst_and_context` | Combined closure | ConcreteTermAlgebra.lean |
| `EquationalClosure.subst_closed` | `s ≡ t ⟹ s[σ] ≡ t[σ]` | ConcreteTermAlgebra.lean |
| `EquationalClosure.of_derivable` | Derivability implies containment | ConcreteTermAlgebra.lean |
| `rewrites_in_equational_closure` | `s →_R t ⟹ s ≡ t` | ConcreteTermAlgebra.lean |
| `concrete_orient_preserves_equational_theory` | Orient is sound | ConcreteTermAlgebra.lean |
| `concrete_delete_preserves_equational_theory` | Delete is sound | ConcreteTermAlgebra.lean |
| `concrete_deduce_preserves_equational_theory` | Deduce is sound | ConcreteTermAlgebra.lean |
| `concrete_simplify_preserves_equational_theory` | Simplify is sound | ConcreteTermAlgebra.lean |
| `concrete_compose_preserves_equational_theory` | Compose is sound | ConcreteTermAlgebra.lean |
| `concrete_collapse_preserves_equational_theory` | Collapse is sound | ConcreteTermAlgebra.lean |
| `concrete_step_preserves_eq_theory` | Unified step soundness | ConcreteTermAlgebra.lean |
| `concrete_completion_preserves_equational_theory` | Global simulation | ConcreteTermAlgebra.lean |
| `concrete_completion_correct` | Capstone theorem | ConcreteTermAlgebra.lean |
