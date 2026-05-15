# Tropical Curry–Howard: Canonical Normalization of Min-Plus Proofs

## Abstract

We formalize a tropical proof calculus in which proof normalization is literally min-plus optimization. The calculus features four term constructors — atoms (weighted axioms), cuts (sequential composition), min (nondeterministic choice), and plus (parallel accumulation) — equipped with a reduction system combining distributive laws, idempotent collapse, and atomic evaluation. We establish six main theorems, all machine-verified: (1) soundness — every reduction step preserves tropical cost; (2) strong normalization — every reduction sequence terminates, via a polynomial interpretation; (3) normal form characterization — every normal form is an atom; (4) canonical normalization — every term reduces to `atom(cost(p))`, the unique canonical representative; (5) global confluence — all reduction paths converge; (6) uniqueness — the normalizer is a complete invariant of reduction equivalence. The framework establishes a rigorous Curry–Howard correspondence between proof normalization and shortest-path computation in idempotent semirings.

**Keywords**: tropical logic, Curry–Howard correspondence, min-plus algebra, idempotent semiring, cut elimination, confluence, strong normalization, canonical forms, shortest-path semantics, certified optimization

## 1. Introduction

### 1.1 Background and Motivation

The Curry–Howard correspondence [Curry 1934, Howard 1969] identifies mathematical proofs with typed programs and logical propositions with types. Under this correspondence, proof normalization (cut elimination in sequent calculus) corresponds to program evaluation (β-reduction in λ-calculus). This deep structural identity has been the foundation of modern type theory and proof assistants.

Separately, tropical mathematics [Maclagan–Sturmfels 2015, Litvinov 2007] replaces the classical arithmetic operations (×, +) with (min, +), creating an *idempotent semiring* — a structure where "addition" (min) satisfies x ⊕ x = x. This degenerate-looking arithmetic turns out to be the native language of optimization: shortest paths, dynamic programming, optimal control, and combinatorial optimization all admit natural formulations in tropical algebra.

The central contribution of this work is to bridge these two worlds formally: we construct a proof calculus whose normalization dynamics are governed by tropical algebra, and prove that normalization computes the unique optimal-cost proof representative.

### 1.2 Contributions

1. **A formal tropical proof calculus** (Section 3) with explicit cost semantics, reduction rules capturing distributivity, idempotent collapse, and atomic evaluation, and a congruence closure enabling reduction in arbitrary contexts.

2. **Soundness** (Section 4): Every reduction step preserves the tropical cost, establishing that normalization is a semantics-preserving transformation.

3. **Strong normalization** (Section 5): Termination of all reduction sequences, proved via a polynomial interpretation mapping cut/plus to multiplication and min to addition+1.

4. **Normal form characterization** (Section 6): Every normal form is an atom — a fully evaluated cost value. This is the key structural theorem showing the computation rules are complete.

5. **Canonical normalization and confluence** (Section 7): Every term reduces to `atom(cost(p))`, the unique canonical normal form. Global confluence follows as a corollary.

6. **Uniqueness, canonicality, and optimality** (Section 8): The normalizer is a complete invariant of reduction equivalence, and the canonical form has optimal cost among all convertible terms.

All results are machine-verified in Lean 4 with Mathlib, totaling approximately 500 lines of formally checked code with zero uses of `sorry`.

### 1.3 Related Work

**Proof normalization**: Cut elimination for classical and intuitionistic logic [Gentzen 1935, Prawitz 1965] establishes that proofs can be simplified to cut-free form. Our work adds a *cost semantics* to this process and shows the simplified form is unique and optimal.

**Weighted/quantitative type systems**: Quantitative type theory [Atkey 2018, McBride 2016] and bounded linear logic [Girard et al. 1992] track resource usage in types. Our approach is orthogonal: we add cost semantics to the proof term layer rather than the type layer.

**Tropical mathematics**: Maclagan and Sturmfels [2015] provide a comprehensive treatment of tropical geometry. Litvinov [2007] develops idempotent analysis. Our work applies tropical algebraic structure to proof theory, a connection not previously formalized.

**Rewriting theory**: Termination via polynomial interpretations [Lankford 1979, Hofbauer–Lautemann 1989] and Newman's lemma for confluence [Newman 1942] are standard tools. We instantiate these in the tropical setting and exploit the semantic characterization for a direct confluence proof.

## 2. Notation and Preliminaries

### 2.1 The Min-Plus Semiring

The **min-plus semiring** (ℕ, min, +, ∞, 0) satisfies:
- (ℕ, min, ∞) is a commutative idempotent monoid: min(a, a) = a.
- (ℕ, +, 0) is a commutative monoid.
- Distributivity: a + min(b, c) = min(a + b, a + c).
- Absorption: a + ∞ = ∞.

The idempotence of min is the algebraic property that drives canonical normalization.

### 2.2 Reflexive-Transitive Closure

For a relation R on a set A, we write R* for the reflexive-transitive closure (ReflTransGen R in Mathlib). We write a →* b to mean R*(a, b).

## 3. The Tropical Proof Calculus

### 3.1 Syntax

**Definition 3.1** (Tropical Proof Terms). The set TropProof is generated by:

```
p, q ::= atom(n)    -- atomic proof of cost n ∈ ℕ
       | cut(p, q)   -- sequential composition (cut rule)
       | tmin(p, q)  -- nondeterministic choice (minimum)
       | tplus(p, q) -- parallel accumulation (addition)
```

### 3.2 Cost Semantics

**Definition 3.2** (Tropical Cost). The cost function evaluates in the min-plus semiring:

```
cost(atom(n))    = n
cost(cut(p, q))  = cost(p) + cost(q)
cost(tmin(p, q)) = min(cost(p), cost(q))
cost(tplus(p, q))= cost(p) + cost(q)
```

### 3.3 Reduction System

**Definition 3.3** (One-Step Reduction, TropStep). The relation p → q is generated by:

**Distributive rules** (cut/plus distribute over min):
- cut(tmin(p,q), r) → tmin(cut(p,r), cut(q,r))
- cut(p, tmin(q,r)) → tmin(cut(p,q), cut(p,r))
- tplus(tmin(p,q), r) → tmin(tplus(p,r), tplus(q,r))
- tplus(p, tmin(q,r)) → tmin(tplus(p,q), tplus(p,r))

**Idempotent collapse**:
- tmin(p, p) → p

**Computation rules** (evaluate atoms):
- cut(atom(a), atom(b)) → atom(a + b)
- tplus(atom(a), atom(b)) → atom(a + b)
- tmin(atom(a), atom(b)) → atom(min(a, b))

**Congruence closure**: If p → q then:
- cut(p, r) → cut(q, r), cut(r, p) → cut(r, q)
- tmin(p, r) → tmin(q, r), tmin(r, p) → tmin(r, q)
- tplus(p, r) → tplus(q, r), tplus(r, p) → tplus(r, q)

**Definition 3.4** (Normal Form). A term p is in **normal form** if ¬∃q, p → q.

**Definition 3.5** (Canonical Normalizer). normalize(p) = atom(cost(p)).

### 3.4 Design Rationale

The computation rules (cut_atoms, tplus_atoms, tmin_atoms) are crucial for achieving unique canonical normal forms. Without them, normal forms would include compound expressions like cut(atom(2), atom(3)), and uniqueness would require associativity and commutativity rules (which break termination). The computation rules force all compound expressions to eventually evaluate to single atoms, yielding a simple and elegant normal form theory.

## 4. Soundness

**Theorem 4.1** (Step Preserves Cost). If p → q, then cost(q) = cost(p).

*Proof sketch*: By case analysis on the reduction rule.
- Distributive rules: Use the min-plus distributive law, e.g., cost(p) + min(cost(q), cost(r)) = min(cost(p) + cost(q), cost(p) + cost(r)).
- Idempotent collapse: Use min(a, a) = a.
- Computation rules: Direct computation.
- Congruence rules: By induction hypothesis. □

**Corollary 4.2** (RTC Preserves Cost). If p →* q, then cost(q) = cost(p).

## 5. Strong Normalization

### 5.1 Polynomial Interpretation

**Definition 5.1**. The interpretation function maps terms to natural numbers:

```
interp(atom(_))    = 2
interp(cut(p, q))  = interp(p) × interp(q)
interp(tmin(p, q)) = interp(p) + interp(q) + 1
interp(tplus(p, q))= interp(p) × interp(q)
```

**Lemma 5.2**. For all p, interp(p) ≥ 2.

*Proof*: By structural induction. Atoms have interp 2. For cut/tplus, interp(p)·interp(q) ≥ 2·2 = 4 ≥ 2. For tmin, interp(p)+interp(q)+1 ≥ 2+2+1 = 5 ≥ 2. □

**Theorem 5.3** (Strict Decrease). If p → q, then interp(q) < interp(p).

*Proof sketch*: By case analysis.
- **cut_tmin_left**: interp(tmin(cut(p,r), cut(q,r))) = ip·ir + iq·ir + 1 < (ip + iq + 1)·ir = interp(cut(tmin(p,q), r)), since 1 < ir (as ir ≥ 2).
- **min_idem**: interp(p) < interp(p) + interp(p) + 1 = interp(tmin(p,p)), since interp(p) ≥ 2.
- **cut_atoms**: interp(atom(a+b)) = 2 < 4 = 2·2 = interp(cut(atom(a), atom(b))).
- **Congruence rules**: Monotonicity of multiplication and addition with positive arguments. □

**Theorem 5.4** (Strong Normalization). The relation λa b. (b → a) is well-founded.

*Proof*: The function interp provides an embedding into (ℕ, <), which is well-founded. □

### 5.2 Complexity Analysis

The polynomial interpretation provides an upper bound on the length of any reduction sequence from p: at most interp(p) steps. Since interp involves iterated multiplication, this bound is exponential in the syntactic depth of the term. Whether tighter bounds exist is an open question related to proof complexity.

## 6. Normal Form Characterization

**Theorem 6.1** (Normal Forms Are Atoms). If Normal(p), then p = atom(n) for some n.

*Proof*: By structural induction on p.
- **atom(n)**: Already an atom.
- **cut(p, q)**: If Normal(cut(p,q)), then Normal(p) and Normal(q) (by contraposition with congruence rules). By IH, p = atom(a) and q = atom(b). But then cut_atoms applies, contradicting normality.
- **tmin(p, q)**: Similarly, p = atom(a) and q = atom(b) by IH. Then tmin_atoms applies, contradiction.
- **tplus(p, q)**: Similarly. □

**Corollary 6.2** (No Idempotent Min-Pairs). If Normal(p), then p ≠ tmin(q, q) for any q.

## 7. Canonical Normalization and Confluence

**Theorem 7.1** (Reduces to Normalize). For all p, p →* normalize(p) = atom(cost(p)).

*Proof*: By structural induction on p.
- **atom(n)**: normalize(atom(n)) = atom(n). Zero steps.
- **cut(p, q)**: By IH, p →* atom(cost(p)) and q →* atom(cost(q)). By congruence lifting, cut(p,q) →* cut(atom(cost(p)), atom(cost(q))). By cut_atoms, → atom(cost(p) + cost(q)) = atom(cost(cut(p,q))).
- **tmin(p, q)**: Similarly, via tmin_atoms.
- **tplus(p, q)**: Similarly, via tplus_atoms. □

**Theorem 7.2** (Global Confluence). For all p, q, r with p →* q and p →* r, there exists s with q →* s and r →* s.

*Proof*: By Theorem 7.1, q →* atom(cost(q)) and r →* atom(cost(r)). By Corollary 4.2, cost(q) = cost(p) = cost(r). Hence both reduce to the same atom. Take s = atom(cost(p)). □

**Remark**: This proof of confluence is non-standard. Rather than using Newman's lemma (local confluence + termination ⟹ confluence), we exploit the semantic characterization directly. Every term has a unique normal form determined entirely by its cost, so all reduction paths must converge. The strong normalization theorem is still essential — it guarantees that the reduction process terminates — but confluence is an independent consequence of the semantic invariant.

## 8. Uniqueness, Canonicality, and Optimality

**Definition 8.1** (Convertibility). Terms p and q are *convertible*, written Convertible(p, q), if ∃s, p →* s ∧ q →* s.

**Theorem 8.1** (Normal Form Fixpoint). If Normal(p) and p →* q, then p = q.

*Proof*: By induction on the reflexive-transitive closure. If zero steps, p = q. If p → r →* q for some r, this contradicts Normal(p). □

**Theorem 8.2** (Normal Form Uniqueness). If Normal(p), Normal(q), and p →* q, then p = q.

**Theorem 8.3** (Completeness). If p →* q, then normalize(p) = normalize(q).

*Proof*: normalize(p) = atom(cost(p)) = atom(cost(q)) = normalize(q), by Corollary 4.2. □

**Theorem 8.4** (Canonicality). If Convertible(p, q) and Normal(q), then normalize(p) = q.

*Proof*: From convertibility, ∃s with p →* s and q →* s. By Theorem 8.1, q = s. So p →* q. By cost preservation, cost(p) = cost(q). By Theorem 6.1, q = atom(n) for some n. Then cost(q) = n, so normalize(p) = atom(cost(p)) = atom(n) = q. □

**Theorem 8.5** (Optimality). For all p, q with Convertible(p, q), cost(normalize(p)) ≤ cost(q).

*Proof*: By cost preservation through the common reduct, cost(p) = cost(q). Hence cost(normalize(p)) = cost(p) = cost(q). □

### The Flagship Theorem

**Theorem 8.6** (Tropical Curry–Howard Canonical Normalization). For every tropical proof term p:
1. p →* normalize(p) [reachability]
2. Normal(normalize(p)) [normality]
3. cost(normalize(p)) = cost(p) [cost preservation]
4. For all q with p →* q and Normal(q), normalize(p) = q [uniqueness]

## 9. Algorithms

### 9.1 The Normalization Algorithm

```
function NORMALIZE(p):
    match p with
    | atom(n)     → return atom(n)
    | cut(p, q)   → return atom(COST(p) + COST(q))
    | tmin(p, q)  → return atom(min(COST(p), COST(q)))
    | tplus(p, q) → return atom(COST(p) + COST(q))

function COST(p):
    match p with
    | atom(n)     → return n
    | cut(p, q)   → return COST(p) + COST(q)
    | tmin(p, q)  → return min(COST(p), COST(q))
    | tplus(p, q) → return COST(p) + COST(q)
```

**Time complexity**: O(|p|) where |p| is the number of nodes in the term tree.
**Space complexity**: O(depth(p)) for the recursion stack.

### 9.2 Step-by-Step Reduction

An alternative implementation applies reduction rules one at a time until a normal form is reached. By strong normalization, this always terminates. By confluence, it always produces the same result regardless of the reduction strategy chosen.

```
function REDUCE_STEP(p):
    match p with
    | cut(tmin(a, b), r)        → return tmin(cut(a, r), cut(b, r))
    | cut(p, tmin(q, r))        → return tmin(cut(p, q), cut(p, r))
    | tmin(p, p) where p == p   → return p   // idempotent collapse
    | cut(atom(a), atom(b))     → return atom(a + b)
    | tmin(atom(a), atom(b))    → return atom(min(a, b))
    | tplus(atom(a), atom(b))   → return atom(a + b)
    // ... congruence: try reducing subterms
    | _ → return None  // already normal

function NORMALIZE_BY_REDUCTION(p):
    while REDUCE_STEP(p) is not None:
        p ← REDUCE_STEP(p)
    return p
```

**Time complexity**: O(interp(p)), which is at most exponential in depth(p).

## 10. Applications

### 10.1 Certified Shortest-Path Computation

A weighted directed graph G = (V, E, w) with source s and sink t can be encoded as a tropical proof term:

```
encodePaths(G, s, t) = tmin over all paths P from s to t of
    (tplus(atom(w(e₁)), tplus(atom(w(e₂)), ... atom(w(eₖ)))))
```

By the canonical normalization theorem, normalize(encodePaths(G, s, t)) = atom(shortestPathCost(G, s, t)). This provides a certified shortest-path algorithm: the normalization process is proven correct by construction.

### 10.2 Dynamic Programming Verification

Any dynamic programming recurrence of the form `dp[i] = min(dp[j] + cost(j, i))` can be expressed as tropical proof normalization. The optimal substructure property is exactly the distributive law, and the elimination of dominated subproblems is exactly idempotent collapse.

### 10.3 Resource-Aware Program Verification

In a resource-aware programming language, function calls carry costs. A program's execution trace is a tropical proof term, and normalization computes the optimal execution cost. This connects to amortized complexity analysis and bounded linear type systems.

## 11. Discussion

### 11.1 The Role of Computation Rules

The addition of computation rules (cut_atoms, tplus_atoms, tmin_atoms) is a deliberate design choice that significantly simplifies the normal form theory. Without them, normal forms would include non-atomic terms like cut(atom(2), atom(3)), and proving uniqueness would require handling associativity and commutativity of min — which introduces non-terminating rewrite rules.

The computation rules resolve this by ensuring that every compound term eventually evaluates to a single atom. This is analogous to the distinction between weak head normal forms and full normal forms in λ-calculus: our computation rules force full evaluation, yielding a simpler uniqueness theorem.

### 11.2 Confluence via Semantics vs. Newman's Lemma

Our proof of confluence is unusual in the rewriting theory literature. Rather than establishing local confluence and applying Newman's lemma, we prove confluence directly from the semantic invariant: every term reduces to atom(cost(p)), and cost is preserved by reduction. This yields a shorter and more illuminating proof, but it is specific to systems where the normal form is uniquely determined by a semantic invariant.

For extensions of the calculus where normal forms carry more structure (e.g., typed terms with subformula property), Newman's lemma approach may be necessary. The strong normalization theorem we establish provides the termination ingredient for such future applications.

### 11.3 Limitations

1. **Cost equality, not strict decrease**: In our system, every reduction step preserves cost exactly. There is no notion of "cost improvement" through normalization — the cost is an invariant, not an objective to minimize. The optimization interpretation arises from the fact that min selects the cheapest among alternatives, not that reduction makes things cheaper.

2. **Untyped calculus**: The current system is untyped — there are no propositions, only proof terms with costs. A full Curry–Howard correspondence requires a type system where propositions carry tropical structure.

3. **Finite costs only**: We work over ℕ. Extension to ℝ≥0∞ would enable unreachable-proof semantics and connections to tropical analytic geometry.

## 12. Future Work

See FUTURE_DIRECTIONS.md for detailed technical roadmap. Key directions include:
1. Extension to ℝ≥0∞ cost semantics for unreachable proofs.
2. Typed sequent calculus with tropical cut elimination.
3. Graph-theoretic representation theorem (proofs ↔ DAGs).
4. Tropical proof complexity invariants.
5. Connection to Viterbi decoding and weighted automata.

## References

- Atkey, R. (2018). Syntax and semantics of quantitative type theory. LICS 2018.
- Curry, H.B. (1934). Functionality in combinatory logic. Proc. Nat. Acad. Sci. USA, 20(11), 584–590.
- Gentzen, G. (1935). Untersuchungen über das logische Schließen. Mathematische Zeitschrift, 39, 176–210, 405–431.
- Girard, J.-Y., Scedrov, A., Scott, P.J. (1992). Bounded linear logic. Theoretical Computer Science, 97(1), 1–66.
- Hofbauer, D., Lautemann, C. (1989). Termination proofs and the length of derivations. LNCS 355, 167–177.
- Howard, W.A. (1969/1980). The formulae-as-types notion of construction. In: To H.B. Curry: Essays on Combinatory Logic, Lambda Calculus and Formalism, Academic Press.
- Lankford, D.S. (1979). On proving term rewriting systems are Noetherian. Technical Report, Louisiana Tech University.
- Litvinov, G.L. (2007). Maslov dequantization, idempotent and tropical mathematics. Journal of Mathematical Sciences, 140(3), 349–386.
- Maclagan, D., Sturmfels, B. (2015). Introduction to Tropical Geometry. Graduate Studies in Mathematics, vol. 161, AMS.
- McBride, C. (2016). I got plenty o' nuttin'. In: A List of Successes That Can Change the World, LNCS 9600.
- Newman, M.H.A. (1942). On theories with a combinatorial definition of "equivalence." Annals of Mathematics, 43(2), 223–243.
- Prawitz, D. (1965). Natural Deduction: A Proof-Theoretical Study. Almqvist & Wiksell.
